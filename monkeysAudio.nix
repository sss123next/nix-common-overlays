{ inputs }:
self: super: {
  monkeysAudio =
    with super;
    monkeysAudio.overrideAttrs (oldAttrs: rec {
      version = "11.87";
  src = fetchzip { 
    url = "https://monkeysaudio.com/files/MAC_1187_SDK.zip"; 
    hash = ""; 
    stripRoot = false; 
  }; 

    });
}
