# The SMF DIRECT PLAY toggles' RAM cells in the v10 and v9 trees (rename_smf_direct_play.sed has the routines):
# PLAY AS (GM / TECH) at 0x8942 and MIDI OUT (on / off) at 0x8944.  The C names (ram_<hex>) and the absolute
# operands, hex or decimal, take the names; shared/ram_variables.s defines them for this tree.
s/\bram_8942\b/SmfPlayAsGm/g
s/(0x8942:16)/(SmfPlayAsGm:16)/g
s/(35138:16)/(SmfPlayAsGm:16)/g
s/\bram_8944\b/SmfMidiOut_OnOff/g
s/(0x8944:16)/(SmfMidiOut_OnOff:16)/g
s/(35140:16)/(SmfMidiOut_OnOff:16)/g
