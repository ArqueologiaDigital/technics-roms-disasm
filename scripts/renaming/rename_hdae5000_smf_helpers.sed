# rename_hdae5000_smf_helpers.sed -- the HD-AE5000's Standard MIDI File header check, misnamed by the conversion.
#
# HDAE5000_Filename_Validate reverses the four bytes of XWA (a big-endian SMF long -> native), unrolled; it
# validates no file name.  HDAE5000_Extension_Check swaps the two bytes of WA (an SMF word); it checks no
# extension.  HDAE5000_Config_Init checks a 14-byte SMF header: "MThd" (0x4D546864 after the swap), length 6,
# format <= 1, the track count, division bit 15 (SMPTE) clear -> 0 / -1..-4.  The code after Extension_Check's
# ret (.Lec_main, referenced by nothing) opens a floppy file "rb", reads its first 14 bytes into RAM 0x230EAC
# and runs that check.
#
# Run (repository root):  LC_ALL=C sed -i -f scripts/renaming/rename_hdae5000_smf_helpers.sed hdae5000/*.s
s/\bHDAE5000_Filename_Validate\b/HDAE5000_Smf_SwapBytes32/g
s/\bHDAE5000_Extension_Check\b/HDAE5000_Smf_SwapBytes16/g
s/\bHDAE5000_Config_Init\b/HDAE5000_Smf_CheckHeader/g
s/\bHDAE5000_Str_Rb_Extension_Check\b/HDAE5000_Str_Rb_Smf_ReadHeader/g
s/^\.Lec_main:\(.*\)$/HDAE5000_Smf_ReadHeader:/
