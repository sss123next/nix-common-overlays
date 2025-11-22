{ inputs }:
self: super: {
  monkeysAudio =
    with super;
    monkeysAudio.overrideAttrs (oldAttrs: rec {
      version = "11.87";
  src = fetchzip { 
    url = "https://monkeysaudio.com/files/MAC_1187_SDK.zip"; 
    hash = "sha256-m6CG0Ar6w2fF4h3CjVsdjWWHxau2Cl3iqxh4JLH+91k="; 
    stripRoot = false; 
  }; 

    });
}
