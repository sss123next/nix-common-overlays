//! A credential store wrapper that caches loaded secrets for the session
//! lifetime, reducing D-Bus round-trips to the Secret Service keychain.
//! The cache can be disabled at runtime via
//! [`CachingCredentialStore::set_caching_enabled`].

use super::{CredentialStore, CredentialStoreHandle, Slot};
use crate::error::Result;
use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Mutex;

/// Key used internally for the cache: (account_id, slot discriminant + dynamic payload).
#[derive(Clone, Debug, Hash, PartialEq, Eq)]
struct CacheKey(i64, String);

fn cache_key(account_id: i64, slot: &Slot) -> CacheKey {
    CacheKey(account_id, slot.key().into_owned())
}

/// A [`CredentialStore`] decorator that caches loaded secrets in memory.
///
/// - **`load()`** returns the cached value when caching is enabled and the
///   value is present; otherwise it fetches from the inner store and, if
///   caching is enabled, stores the result in the cache.
/// - **`store()`**, **`delete()`**, and **`delete_all()`** always delegate to
///   the inner store and then synchronise (invalidate / update) the cache.
///
/// The cache is **not** persisted — it lives for the duration of the process.
pub struct CachingCredentialStore {
    inner: CredentialStoreHandle,
    enabled: AtomicBool,
    cache: Mutex<HashMap<CacheKey, String>>,
}

impl CachingCredentialStore {
    /// Wrap `inner` with caching enabled by default.
    pub fn new(inner: CredentialStoreHandle) -> Self {
        Self {
            inner,
            enabled: AtomicBool::new(true),
            cache: Mutex::new(HashMap::new()),
        }
    }

    /// Whether the cache is consulted on `load()`.
    pub fn caching_enabled(&self) -> bool {
        self.enabled.load(Ordering::Relaxed)
    }

    /// Enable or disable the cache at runtime.  When disabled, every `load()`
    /// call passes through to the inner store; existing cached entries are
    /// kept and will be reused if caching is re-enabled.
    pub fn set_caching_enabled(&self, enabled: bool) {
        self.enabled.store(enabled, Ordering::Release);
    }

    /// Discard all cached entries (e.g. after a credential change outside the
    /// app's control).
    pub fn clear_cache(&self) {
        self.cache.lock().unwrap_or_else(|e| e.into_inner()).clear();
    }
}

impl CredentialStore for CachingCredentialStore {
    fn store(&self, account_id: i64, slot: Slot, secret: &str) -> Result<()> {
        self.inner.store(account_id, slot, secret)?;
        if self.enabled.load(Ordering::Acquire) {
            let mut cache = self.cache.lock().unwrap_or_else(|e| e.into_inner());
            cache.insert(cache_key(account_id, &slot), secret.to_owned());
        }
        Ok(())
    }

    fn load(&self, account_id: i64, slot: Slot) -> Result<String> {
        if self.enabled.load(Ordering::Acquire) {
            let key = cache_key(account_id, &slot);
            // Check cache; if hit, return early without blocking on inner.
            let cache = self.cache.lock().unwrap_or_else(|e| e.into_inner());
            if let Some(cached) = cache.get(&key) {
                return Ok(cached.clone());
            }
            // Cache miss — drop the lock before calling the inner store to
            // avoid holding it across a blocking D-Bus round-trip.
            drop(cache);
        }
        let secret = self.inner.load(account_id, slot)?;
        if self.enabled.load(Ordering::Acquire) {
            let mut cache = self.cache.lock().unwrap_or_else(|e| e.into_inner());
            cache.insert(cache_key(account_id, &slot), secret.clone());
        }
        Ok(secret)
    }

    fn delete(&self, account_id: i64, slot: Slot) -> Result<()> {
        self.inner.delete(account_id, slot)?;
        if self.enabled.load(Ordering::Acquire) {
            let mut cache = self.cache.lock().unwrap_or_else(|e| e.into_inner());
            cache.remove(&cache_key(account_id, &slot));
        }
        Ok(())
    }

    fn delete_all(&self, account_id: i64) -> Result<()> {
        self.inner.delete_all(account_id)?;
        if self.enabled.load(Ordering::Acquire) {
            let mut cache = self.cache.lock().unwrap_or_else(|e| e.into_inner());
            cache.retain(|k, _| k.0 != account_id);
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;

    /// Minimal in-memory store for unit tests.
    struct MemoryStore(std::sync::Mutex<std::collections::HashMap<(i64, Slot), String>>);

    impl CredentialStore for MemoryStore {
        fn store(&self, account_id: i64, slot: Slot, secret: &str) -> Result<()> {
            self.0
                .lock()
                .unwrap()
                .insert((account_id, slot), secret.into());
            Ok(())
        }
        fn load(&self, account_id: i64, slot: Slot) -> Result<String> {
            self.0
                .lock()
                .unwrap()
                .get(&(account_id, slot))
                .cloned()
                .ok_or_else(|| crate::error::CoreError::Auth("no stored credential".into()))
        }
        fn delete(&self, account_id: i64, slot: Slot) -> Result<()> {
            self.0.lock().unwrap().remove(&(account_id, slot));
            Ok(())
        }
        fn delete_all(&self, account_id: i64) -> Result<()> {
            self.0
                .lock()
                .unwrap()
                .retain(|(id, _), _| *id != account_id);
            Ok(())
        }
    }

    #[test]
    fn cache_hits_on_repeated_load() {
        let inner = Arc::new(MemoryStore(std::sync::Mutex::new(
            std::collections::HashMap::new(),
        )));
        let caching = CachingCredentialStore::new(inner.clone() as CredentialStoreHandle);

        caching.store(1, Slot::Password, "s3kr1t").unwrap();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "s3kr1t");

        // Second load hits the cache; a change in the inner store stays invisible.
        inner.store(1, Slot::Password, "changed").unwrap();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "s3kr1t");

        // Disabling caching bypasses the cache.
        caching.set_caching_enabled(false);
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "changed");

        // Re-enabling picks up the previous cached value (still stale).
        caching.set_caching_enabled(true);
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "s3kr1t");

        // Clearing the cache forces a fresh load.
        caching.clear_cache();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "changed");
    }

    #[test]
    fn store_updates_cache() {
        let inner = Arc::new(MemoryStore(std::sync::Mutex::new(
            std::collections::HashMap::new(),
        )));
        let caching = CachingCredentialStore::new(inner.clone() as CredentialStoreHandle);

        caching.store(1, Slot::Password, "first").unwrap();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "first");

        // store() updates both inner and cache.
        caching.store(1, Slot::Password, "second").unwrap();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "second");

        // Inner change without going through cache is invisible (as expected).
        inner.store(1, Slot::Password, "third").unwrap();
        caching.clear_cache();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "third");
    }

    #[test]
    fn delete_removes_from_cache() {
        let inner = Arc::new(MemoryStore(std::sync::Mutex::new(
            std::collections::HashMap::new(),
        )));
        let caching = CachingCredentialStore::new(inner.clone() as CredentialStoreHandle);

        caching.store(1, Slot::Password, "s3kr1t").unwrap();
        assert_eq!(caching.load(1, Slot::Password).unwrap(), "s3kr1t");

        caching.delete(1, Slot::Password).unwrap();
        assert!(caching.load(1, Slot::Password).is_err());
    }

    #[test]
    fn delete_all_clears_account_cache() {
        let inner = Arc::new(MemoryStore(std::sync::Mutex::new(
            std::collections::HashMap::new(),
        )));
        let caching = CachingCredentialStore::new(inner.clone() as CredentialStoreHandle);

        caching.store(1, Slot::Password, "pw1").unwrap();
        caching.store(1, Slot::RefreshToken, "rt1").unwrap();
        caching.store(2, Slot::Password, "pw2").unwrap();

        assert!(caching.load(1, Slot::Password).is_ok());
        assert!(caching.load(1, Slot::RefreshToken).is_ok());

        caching.delete_all(1).unwrap();
        assert!(caching.load(1, Slot::Password).is_err());
        assert!(caching.load(1, Slot::RefreshToken).is_err());
        assert!(caching.load(2, Slot::Password).is_ok());
    }
}
