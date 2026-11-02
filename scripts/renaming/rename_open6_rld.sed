# kn5000-rld, lane open6/kn5000-d naming (2026-11-02): the generic labels among the 100 "not reviewed" records of
# analysis/kn5000-naming/proposals-2026-10-07-generic-g{1,3,5}.json that still carry their generic name
# (notes/open6-kn5000-d/naming/probes/rld_record_status.py; 90 others were renamed by later lanes).  Applied to
# the .s/.c/.h/.ld files of v10/v9/v7/v6/v5 maincpu.  Evidence: notes/open6-kn5000-d/naming/rld-verdicts.md.
#
# Sound-editor filter pages: static record lists (se_setup_nav_full.c / se_setup_ctrl_list.c), named from their
# contents.  "MODE" field (SeFil_DrawFilterTypeField, COLORBLIT_MODE 2):
s/\bSeMenu_Utility_FormatNumber_Data_2\b/SeFil_FilterTypeField_StaticRecords/g
# "PAGE1/2" (SeFilLpq1_DrawStaticScreen_End, drawn unless SEMENU_PART_MODE = 1):
s/\bSeMenu_Utility_CompareBlock_Data\b/SeFil_PageOfTwo_StaticRecords/g
# FILTER: / CUTOFF / EQUALIZER / FREQ / RESO / TOUCH / CURVE / RANGE / GAIN, the 12 dB pages' captions:
s/\bSeMenu_Utility_CompareBlock_Data_2\b/SeFil12dB_Caption_StaticRecords/g
# FILTER: / CUTOFF / RESO / TOUCH / CURVE, the 24 dB pages' captions (SeFilL241 / SeFilH241):
s/\bSeMenu_Utility_CompareBlock_Data_3\b/SeFil24dB_Caption_StaticRecords/g
# Clears bit 1 of 0x347A (and bit 0 of 0x28A6) in demo mode; otherwise, with it set and 0x3283 & 3 = 0, clears
# 0x3479 and stops the replay (AccReplay_FullStop).
s/\bAccPos_ClearOnStart_Padding_Sub/AccReplay_HandlePendingStop/g
# Bit 0 of 0x341F set: re-points 0x3426 at the style-section record (0x3421) and re-applies it, then clears the bit.
s/\bAccTone_JumpTableData_Data\b/AccSection_ApplyPendingChange/g
# v7 / v6 / v5 still carry the old generic names of labels v10 / v9 renamed (same reader, same bytes):
s/\bSC0Init_Entry\b/SC0_InitSerialPort/g
s/\bFileIO_BytecodeData_Data_13\b/PanelButton_MspBank17FuncCodes/g
s/\bS2c_GridCheck_Dispatch_Data\b/S2cGridCheck_PartTrackAddrs/g
