# rename_wsa1_wxn.sed -- tracker kn5000-wxn, the WSA1 naming leads of 2026-10-06/07 (lane open6/kn5000-d, 2026-11-02).
# Applied by this sub-lane itself (it owns wsa1/) to the prom_a / prom_b sources and exports.syms; evidence per rule
# in notes/open6-kn5000-d/wsa1/README.md.  Order matters: the +0x200 / +0x280 row operands and the _Skip local go
# before the rules that would otherwise rewrite their prefix.
#
# Lead 1.  Rows 4 and 5 of the 6 x 32 key matrix at 0xFF3D39 are the floppy-format screens 0x50 / 0x51, not pages 4/5
# of MIDI FILE SAVE: PanelButtonDispatch_FloppyDiskFormatSelectType (0xFF6550, the BUTTON method of screen 0x50)
# reads base +0x200 = row 4, PanelButtonDispatch_FloppyDiskFormatAreYouSure (0xFF66AA, screen 0x51) reads +0x280 =
# row 5; MIDI FILE SAVE (screen 0x4E) has pages 0..3 only (ScreenEnterPages_MidiFileSave).  The rows get labels.
s/\bDispatch_FF3D39+0x200\b/ScreenButtonHandlers_FloppyDiskFormatSelectType/g
s/\bDispatch_FF3D39+0x280\b/ScreenButtonHandlers_FloppyDiskFormatAreYouSure/g
s/\bDispatch_FF3D39\b/ScreenButtonHandlers_MidiFileSave/g
# row 4 (screen 0x50): row 3 key = 2DD (clears (0x21E8) bit 3), row 4 key = 2HD (sets it), both -> screen 0x51
s/\bLcdKeyRow3_MidiFileSave_Page4\b/LcdKeyRow3_FloppyDiskFormatSelectType/g
s/\bLcdKeyRow4_MidiFileSave_Page4\b/LcdKeyRow4_FloppyDiskFormatSelectType/g
s/\bExitKey_MidiFileSave_Page4\b/ExitKey_FloppyDiskFormatSelectType/g
# row 5 (screen 0x51): row 3 key = YES (formats), row 4 key = NO (back to screen 0x50)
s/\bLcdKeyRow3_MidiFileSave_Page5\b/LcdKeyRow3_FloppyDiskFormatAreYouSure/g
s/\bLcdKeyRow4_MidiFileSave_Page5\b/LcdKeyRow4_FloppyDiskFormatAreYouSure/g
s/\bExitKey_MidiFileSave_Page5\b/ExitKey_FloppyDiskFormatAreYouSure/g
# prom_a 0xFE1C98 `calr DiskFormat_Execute / calr Ring_InitTenOfFourteen / ret`, the twin of DiskSaveFile_Execute_Entry,
# and its prom_b directory slot
s/\bT_MidiFileSave_Page5_LcdKeyRow3\b/T_DiskFormat_Execute_Entry/g
s/\bMidiFileSave_Page5_LcdKeyRow3\b/DiskFormat_Execute_Entry/g
#
# Lead 2.  0xFBE135 is the callback ScreenEnterBody_CombiEditMixer posts (T_CallbackQueue_Post) to paint the MIXER
# page frame; it was a `.L` local of CombiEditMixer_ShowOtherParts, after that routine's `ret` and a stray `ret`.
s/\.LFBE135\b/CombiEditMixer_PaintPageFrame/g
#
# Lead 3.  0xF77EE7-0xF77FE8 is a third copy (copy E) of the SMF writer's file layer (copy A at 0xF7659B, copy D at
# 0xF77D00, every routine at the same offset); nothing outside it reaches it (probes/smf_copy_e_refs.py).  Named
# <copy-A name>_Copy2 like its siblings InputStream_*_Copy2 (wsa1/notes/wsa1_exact_copy_names.py's convention).
s/\bSmfOut_WriteFirstWindow_Skip\b/SmfWrite_WriteLastWindowAndClose_Copy2_Skip/g
s/\bSmfOut_WriteFirstWindow\b/SmfWrite_WriteFirstWindow_Copy2/g
s/\bsub_F77FD6\b/SmfWrite_SetOutputWindow_Copy2/g
s/\bsub_F77F2A_Skip\b/SmfWrite_CreateFileWithFirstWindow_Copy2_Skip/g
s/\bsub_F77F2A_Return\b/SmfWrite_CreateFileWithFirstWindow_Copy2_Return/g
