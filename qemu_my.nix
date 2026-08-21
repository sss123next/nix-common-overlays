{ inputs }:
self: super: {
  qemu_my =
    with super;
    (qemu_full.override {
      guestAgentSupport = false;
      jackSupport = false;
      gtkSupport = false;
      vncSupport = false;
      smartcardSupport = false;
      spiceSupport = true;
      usbredirSupport = true;
      xenSupport = false;
      cephSupport = false;
      openGLSupport = false;
      virglSupport = true;
      libiscsiSupport = false;
      smbdSupport = false;
      tpmSupport = false;
      canokeySupport = false;
      hostCpuOnly = true;
      sdlSupport = false;
    });
}
