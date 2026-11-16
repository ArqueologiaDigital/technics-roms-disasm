# The SMF DIRECT PLAY toggles' RAM cells in the v7 tree (rename_smf_direct_play.sed has the routines):
# PLAY AS (GM / TECH) at 0x88a6 and MIDI OUT (on / off) at 0x88a8.  The C names (ram_<hex>) and the absolute
# operands, hex or decimal, take the names; shared/ram_variables.s defines them for this tree.
s/\bram_88a6\b/SmfPlayAsGm/g
s/(0x88a6:16)/(SmfPlayAsGm:16)/g
s/(34982:16)/(SmfPlayAsGm:16)/g
s/\bram_88a8\b/SmfMidiOut_OnOff/g
s/(0x88a8:16)/(SmfMidiOut_OnOff:16)/g
s/(34984:16)/(SmfMidiOut_OnOff:16)/g
