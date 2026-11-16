# The SMF DIRECT PLAY toggles' RAM cells in the v6 tree (rename_smf_direct_play.sed has the routines):
# PLAY AS (GM / TECH) at 0x888a and MIDI OUT (on / off) at 0x888c.  The C names (ram_<hex>) and the absolute
# operands, hex or decimal, take the names; shared/ram_variables.s defines them for this tree.
s/\bram_888a\b/SmfPlayAsGm/g
s/(0x888a:16)/(SmfPlayAsGm:16)/g
s/(34954:16)/(SmfPlayAsGm:16)/g
s/\bram_888c\b/SmfMidiOut_OnOff/g
s/(0x888c:16)/(SmfMidiOut_OnOff:16)/g
s/(34956:16)/(SmfMidiOut_OnOff:16)/g
