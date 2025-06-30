{ inputs }:
self: super: {
  retroarch_my =
    with super;
    retroarch.withCores (
      cores: with cores; [
        beetle-gba
        beetle-psx
        beetle-psx-hw
        beetle-saturn
        beetle-supafaust
        beetle-supergrafx
        beetle-vb
        blastem
        bsnes
        bsnes-hd
        bsnes-mercury-balanced
        citra
        desmume
        dolphin
        #     easyrpg
        fceumm
        flycast
        genesis-plus-gx
        gambatte
        gpsp
        melonds
        mesen
        mesen-s
        meteor
        mgba
        mrboom
        mupen64plus
        nestopia
        parallel-n64
        pcsx-rearmed
        pcsx2
        picodrive
        ppsspp
        quicknes
        sameboy
        smsplus-gx
        snes9x
        snes9x2005-plus
        swanstation
        tgbdual
        vba-m
        vba-next
        vecx
        yabause
      ]
    );
}
