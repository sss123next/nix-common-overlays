{ inputs }:
self: super: {
  monkeysAudio =
    with super;
    monkeysAudio.overrideAttrs (oldAttrs: rec {
      version = "11.87";
  src = fetchzip { 
    url = "https://monkeysaudio.com/files/MAC_${builtins.concatStringsSep "" (lib.strings.splitString "." super.version)}_SDK.zip"; 
    hash = ""; 
    stripRoot = false; 
  }; 

    });
}
