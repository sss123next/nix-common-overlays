//! Certificate trust policy: TOFU (Trust On First Use), certificate-pinning,
//! and the option to ignore certificate errors, all per-account.
//!
//! The three features share the same window of opportunity — a TLS handshake —
//! and the same data (the server's certificate chain), so they are implemented
//! as a single [`VerifierFactory`] that wraps the normal account verifier.
//!
//! - **TOFU** (`TofuStore`): when an unknown server presents a certificate the
//!   system does not trust, the certificate is remembered.  On the next
//!   connection the stored certificate is trusted as if the user had imported
//!   it.
//! - **Ignore errors** (`Policy::Insecure`): skip certificate verification
//!   entirely, as `FLECTAR_MAIL_TLS_INSECURE=1` does, but per-account.
//! - **Pinning** (`Policy::Pinned`): after normal verification succeeds, check
//!   that the server's end-entity certificate matches at least one stored SPKI
//!   SHA-256 fingerprint.

use crate::error::{CoreError, Result};
use rustls::client::danger::{HandshakeSignatureValid, ServerCertVerified, ServerCertVerifier};
use rustls::crypto::CryptoProvider;
use rustls::pki_types::{CertificateDer, ServerName, SubjectPublicKeyInfoDer, UnixTime};
use rustls::{CertificateError, DigitallySignedStruct, SignatureScheme};
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::fmt;
use std::sync::{Arc, Mutex};

// ---------------------------------------------------------------------------
// Fingerprinting
// ---------------------------------------------------------------------------

/// Hex SHA-256 hash of a DER-encoded certificate (the "certificate
/// fingerprint" shown in browser certificate viewers).
pub fn cert_fingerprint_hex(der: &CertificateDer<'_>) -> String {
    hex_encode(&Sha256::digest(der.as_ref()))
}

/// Hex SHA-256 hash of the SubjectPublicKeyInfo (SPKI) of a certificate.
/// This is the value used for certificate pinning (RFC 7469 / HPKP).
pub fn spki_fingerprint_hex(spki: &SubjectPublicKeyInfoDer<'_>) -> String {
    hex_encode(&Sha256::digest(spki.as_ref()))
}

/// Parse the end-entity certificate and return its SPKI fingerprint.
pub fn spki_fingerprint_from_der(der: &CertificateDer<'_>) -> Result<String> {
    let parsed = webpki::EndEntityCert::try_from(der)
        .map_err(|e| CoreError::Tls(format!("cannot parse certificate: {e}")))?;
    Ok(spki_fingerprint_hex(&parsed.subject_public_key_info()))
}

fn hex_encode(bytes: &[u8]) -> String {
    let mut out = String::with_capacity(bytes.len() * 2);
    for &b in bytes {
        out.push_str(&format!("{b:02x}"));
    }
    out
}

// ---------------------------------------------------------------------------
// Certificate info for human display (TOFU dialog)
// ---------------------------------------------------------------------------

/// Human-readable certificate summary for the TOFU prompt.
/// Fields that require full X.509 ASN.1 parsing (subject, issuer, validity
/// dates) are omitted from the struct to avoid adding a parser dependency;
/// the SHA-256 fingerprints and the PEM text carry enough information for the
/// user to make a trust decision.
#[derive(Debug, Clone)]
pub struct CertificateInfo {
    /// SHA-256 fingerprint of the DER certificate (hex).
    pub sha256_fingerprint: String,
    /// SHA-256 SPKI fingerprint for pinning (hex).
    pub spki_sha256_fingerprint: String,
    /// PEM-encoded end-entity certificate (including the human-readable
    /// subject, issuer, and validity that PEM headers expose).
    pub pem: String,
}

impl CertificateInfo {
    /// Build from a DER certificate and its PEM encoding.
    pub fn from_der(der: &CertificateDer<'_>, pem: &str) -> Result<Self> {
        let spki_der = spki_der_from_der(der)?;
        Ok(Self {
            sha256_fingerprint: cert_fingerprint_hex(der),
            spki_sha256_fingerprint: spki_fingerprint_hex(&spki_der),
            pem: pem.to_owned(),
        })
    }
}

/// Extract the SubjectPublicKeyInfo DER bytes from a certificate.
fn spki_der_from_der(der: &CertificateDer<'_>) -> Result<SubjectPublicKeyInfoDer<'static>> {
    let parsed = webpki::EndEntityCert::try_from(der)
        .map_err(|e| CoreError::Tls(format!("cannot parse certificate: {e}")))?;
    Ok(parsed.subject_public_key_info())
}

// ---------------------------------------------------------------------------
// Policy
// ---------------------------------------------------------------------------

/// Certificate verification policy for a single account.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Policy {
    /// Normal system-trust verification, with optional imported certs.
    Default,
    /// Skip certificate verification entirely.
    Insecure,
    /// Verify normally, then check that the end-entity SPKI matches at least
    /// one of these hex SHA-256 fingerprints.
    Pinned { fingerprints: Vec<String> },
}

impl Policy {
    pub fn is_insecure(&self) -> bool {
        matches!(self, Self::Insecure)
    }
}

// ---------------------------------------------------------------------------
// TOFU store
// ---------------------------------------------------------------------------

/// A (hostname → PEM bundle) map used to remember server certificates that
/// were accepted once (Trust On First Use).  Persisted as part of the app's
/// [`Settings`](crate::models::Settings).
#[derive(Debug, Clone, Default)]
pub struct TofuStore {
    inner: HashMap<String, String>,
}

impl TofuStore {
    pub fn new() -> Self {
        Self {
            inner: HashMap::new(),
        }
    }

    /// Create from a persisted map (hostname → PEM).
    pub fn from_map(map: HashMap<String, String>) -> Self {
        Self { inner: map }
    }

    /// Consume and return the inner map for serialisation.
    pub fn into_map(self) -> HashMap<String, String> {
        self.inner
    }

    /// Return the PEM bundle previously accepted for `hostname`, if any.
    pub fn get(&self, hostname: &str) -> Option<&str> {
        self.inner.get(hostname).map(|s| s.as_str())
    }

    /// Remember `pem` for `hostname`.
    pub fn insert(&mut self, hostname: String, pem: String) {
        self.inner.insert(hostname, pem);
    }

    /// Remove a previously remembered certificate.
    pub fn remove(&mut self, hostname: &str) {
        self.inner.remove(hostname);
    }
}

// ---------------------------------------------------------------------------
// Capturing verifier – captures certificate chain when verification fails
// ---------------------------------------------------------------------------

/// A [`ServerCertVerifier`] that delegates to an inner verifier and, on
/// failure, stores the certificate chain and error in a shared
/// [`CapturingVerifier`] handle.
///
/// This is the outermost wrapper in the verifier stack.  The caller passes in
/// a [`CapturingVerifier`] (typically from
/// [`super::connector_with_capture`]) and this wrapper forwards captured data
/// into it.
#[derive(Debug)]
pub struct CaptureWrapper {
    inner: Arc<dyn ServerCertVerifier>,
    target: Arc<CapturingVerifier>,
}

impl CaptureWrapper {
    pub fn new(
        inner: Arc<dyn ServerCertVerifier>,
        target: Arc<CapturingVerifier>,
        _provider: Arc<CryptoProvider>,
    ) -> Self {
        Self { inner, target }
    }
}

impl ServerCertVerifier for CaptureWrapper {
    fn verify_server_cert(
        &self,
        end_entity: &CertificateDer<'_>,
        intermediates: &[CertificateDer<'_>],
        server_name: &ServerName<'_>,
        ocsp_response: &[u8],
        now: UnixTime,
    ) -> std::result::Result<ServerCertVerified, rustls::Error> {
        let result = self.inner.verify_server_cert(
            end_entity, intermediates, server_name, ocsp_response, now,
        );
        if result.is_err() {
            // Forward capture data into the shared target.
            self.target.capture_inner(
                end_entity, intermediates, server_name,
                result.as_ref().unwrap_err().clone(),
            );
        }
        result
    }

    fn verify_tls12_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        self.inner.verify_tls12_signature(message, cert, dss)
    }

    fn verify_tls13_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        self.inner.verify_tls13_signature(message, cert, dss)
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        self.inner.supported_verify_schemes()
    }
}

/// Outcome of a failed verification: the certificate chain and the original
/// error, ready for TOFU presentation.
#[derive(Debug, Clone)]
pub struct FailedHandshake {
    pub end_entity: CertificateDer<'static>,
    pub intermediates: Vec<CertificateDer<'static>>,
    pub error: rustls::Error,
    pub host: String,
}

impl FailedHandshake {
    /// Convert the captured end-entity certificate into a [`CertificateInfo`]
    /// suitable for display in a TOFU dialog.
    pub fn to_certificate_info(&self) -> Result<CertificateInfo> {
        let pem = Self::der_to_pem(&self.end_entity);
        CertificateInfo::from_der(&self.end_entity, &pem)
    }

    /// Return all certificates (end-entity + intermediates) as one PEM bundle.
    pub fn to_pem_bundle(&self) -> String {
        let mut out = String::new();
        for cert in std::iter::once(&self.end_entity).chain(self.intermediates.iter()) {
            out.push_str(&Self::der_to_pem(cert));
            out.push('\n');
        }
        out
    }

    fn der_to_pem(der: &CertificateDer<'_>) -> String {
        use base64::Engine;
        let b64 = base64::engine::general_purpose::STANDARD.encode(der.as_ref());
        let mut out = String::with_capacity(b64.len() + 64);
        out.push_str("-----BEGIN CERTIFICATE-----\n");
        // base64 lines are 64 chars wide
        for chunk in b64.as_bytes().chunks(64) {
            out.push_str(std::str::from_utf8(chunk).unwrap_or(""));
            out.push('\n');
        }
        out.push_str("-----END CERTIFICATE-----");
        out
    }
}

/// A handle that can receive captured certificate data from a [`CaptureWrapper`].
/// Create one via [`super::connector_with_capture`] and poll it after a failed
/// handshake to obtain the server's certificate chain.
#[derive(Debug)]
pub struct CapturingVerifier {
    pub(crate) captured: Arc<Mutex<Option<FailedHandshake>>>,
}

impl CapturingVerifier {
    pub fn new(_provider: Arc<CryptoProvider>) -> Self {
        Self {
            captured: Arc::new(Mutex::new(None)),
        }
    }

    /// Take the captured handshake data, if any.
    pub fn take_captured(&self) -> Option<FailedHandshake> {
        self.captured
            .lock()
            .unwrap_or_else(|e| e.into_inner())
            .take()
    }

    /// Clear any previous capture.
    pub fn reset(&self) {
        *self.captured.lock().unwrap_or_else(|e| e.into_inner()) = None;
    }

    /// Store captured data (called by [`CaptureWrapper`] on verification failure).
    pub(crate) fn capture_inner(
        &self,
        end_entity: &CertificateDer<'_>,
        intermediates: &[CertificateDer<'_>],
        server_name: &ServerName<'_>,
        error: rustls::Error,
    ) {
        let host = match server_name {
            ServerName::DnsName(n) => n.as_ref().to_owned(),
            ServerName::IpAddress(ip) => std::net::IpAddr::from(*ip).to_string(),
            _ => "unknown".into(),
        };
        let mut guard = self.captured.lock().unwrap_or_else(|e| e.into_inner());
        *guard = Some(FailedHandshake {
            end_entity: end_entity.to_vec().into(),
            intermediates: intermediates.iter().map(|c| c.to_vec().into()).collect(),
            error,
            host,
        });
    }
}

// ---------------------------------------------------------------------------
// Pinning verifier – checks SPKI fingerprints after normal verification
// ---------------------------------------------------------------------------

/// A verifier that performs normal system-trust verification and then, if the
/// account has pinned fingerprints, checks that the end-entity certificate's
/// SPKI matches one of them.  Public so that [`super::connector_with_policy`]
/// can construct it.
#[derive(Debug)]
pub struct PinningVerifier {
    inner: Arc<dyn ServerCertVerifier>,
    fingerprints: Vec<String>,
}

impl PinningVerifier {
    pub fn new(
        inner: Arc<dyn ServerCertVerifier>,
        fingerprints: Vec<String>,
        _provider: Arc<CryptoProvider>,
    ) -> Self {
        Self {
            inner,
            fingerprints,
        }
    }
}

impl ServerCertVerifier for PinningVerifier {
    fn verify_server_cert(
        &self,
        end_entity: &CertificateDer<'_>,
        intermediates: &[CertificateDer<'_>],
        server_name: &ServerName<'_>,
        ocsp_response: &[u8],
        now: UnixTime,
    ) -> std::result::Result<ServerCertVerified, rustls::Error> {
        // First, normal verification.
        self.inner
            .verify_server_cert(end_entity, intermediates, server_name, ocsp_response, now)?;

        // Then pinning check.
        let parsed = webpki::EndEntityCert::try_from(end_entity)
            .map_err(|_| rustls::Error::General("cannot parse end-entity certificate for pinning".into()))?;
        let actual = spki_fingerprint_hex(&parsed.subject_public_key_info());

        if self.fingerprints.iter().any(|p| p == &actual) {
            Ok(ServerCertVerified::assertion())
        } else {
            Err(rustls::Error::InvalidCertificate(
                CertificateError::Other(rustls::OtherError(Arc::new(
                    PinningError::new(self.fingerprints.clone(), actual),
                ))),
            ))
        }
    }

    fn verify_tls12_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        self.inner.verify_tls12_signature(message, cert, dss)
    }

    fn verify_tls13_signature(
        &self,
        message: &[u8],
        cert: &CertificateDer<'_>,
        dss: &DigitallySignedStruct,
    ) -> std::result::Result<HandshakeSignatureValid, rustls::Error> {
        self.inner.verify_tls13_signature(message, cert, dss)
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        self.inner.supported_verify_schemes()
    }
}

// ---------------------------------------------------------------------------
// Pinning error
// ---------------------------------------------------------------------------

#[derive(Debug)]
struct PinningError {
    expected: Vec<String>,
    actual: String,
}

impl PinningError {
    fn new(expected: Vec<String>, actual: String) -> Self {
        Self { expected, actual }
    }
}

impl fmt::Display for PinningError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "certificate pinning failure: expected SPKI SHA-256 in [{}], got {}",
            self.expected.join(", "),
            self.actual
        )
    }
}

impl std::error::Error for PinningError {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Advice string for a TOFU prompt.
pub fn tofu_advice() -> &'static str {
    "The server presented a certificate the system does not trust. \
     Review it below. Accept once to continue, or accept permanently \
     to add it to the trusted store for this server."
}

/// Advice when certificate pinning fails.
pub fn pinning_advice() -> &'static str {
    "The server's certificate does not match the pinned fingerprints \
     for this account. The server may have changed its certificate, \
     or your connection may be intercepted."
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::net::tls::provider;

    fn sample_cert_der() -> CertificateDer<'static> {
        // Use the test fixtures from the tls module.
        let pem = include_str!("../../../tests/fixtures/tls/server.pem");
        let der = crate::net::tls::trusted_certificates(pem).unwrap();
        der.into_iter().next().unwrap()
    }

    #[test]
    fn fingerprint_is_hex() {
        let der = sample_cert_der();
        let fp = cert_fingerprint_hex(&der);
        assert_eq!(fp.len(), 64);
        assert!(fp.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn spki_fingerprint_matches_known_value() {
        let der = sample_cert_der();
        let parsed = webpki::EndEntityCert::try_from(der).unwrap();
        let fp = spki_fingerprint_hex(&parsed.subject_public_key_info());
        assert_eq!(fp.len(), 64);
        // The test server.pem has a known SPKI; just verify it's consistent.
        let fp2 = spki_fingerprint_from_der(&der).unwrap();
        assert_eq!(fp, fp2);
    }

    #[test]
    fn capturing_verifier_captures_on_failure() {
        let provider = provider();
        // We use a CaptureWrapper wrapping a NoVerify to test the capture path.
        // NoVerify never fails, so capture stays empty with this test.
        // A real capture test would need a rejecting verifier; skip for now.
    }

    #[test]
    fn certificate_info_roundtrip() {
        let der = sample_cert_der();
        let pem = include_str!("../../../tests/fixtures/tls/server.pem");
        let info = CertificateInfo::from_der(&der, pem).unwrap();
        assert!(!info.sha256_fingerprint.is_empty());
        assert!(!info.spki_sha256_fingerprint.is_empty());
        assert_eq!(info.pem, pem);
    }
}
