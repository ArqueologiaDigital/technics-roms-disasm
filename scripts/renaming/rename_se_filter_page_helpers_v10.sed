# v10: the filter pages' shared drawing helpers (they carried SeMenu_Utility_* guesses: SearchByte, FormatNumber,
# FormatSigned).  Read from the code (audio/sound_editor_ui.s) and the lists they draw:
#  - SeMenu_Utility_SearchByte, called by the filter pages' static-screen routines, draws SeScreenData_0x1682 -- the
#    FILTER page header: "FILTER", "SOUND EDIT", the ENV / FILTER / LFO side tabs -- to 0x173B, or only its first
#    38 bytes when (1710) = 1;
#  - SeMenu_Utility_FormatNumber_End draws a caption list highlighted (COLORBLIT_MODE 2) and then the bound record
#    SeMenu_Utility_FormatSigned_Records, whose value table is SeValText_FilterTypes (LPF+EQ .. THRU): the filter
#    type field;
#  - SeMenu_Utility_FormatNumber_Loop draws the first record (5 bytes) of se_setup_nav_full, its "M0DE" caption.
s/\bSeMenu_Utility_FormatSigned_Records\b/SeFil_FilterTypeField_Record/g
s/\bSeMenu_Utility_FormatNumber_Loop\b/SeFil_DrawModeCaption/g
s/\bSeMenu_Utility_FormatNumber_End\b/SeFil_DrawFilterTypeField/g
s/\bSeMenu_Utility_FormatNumber_Data\b/SeFil_DrawFilterTypeField_Skip/g
s/\bSeMenu_Utility_FormatSigned\b/SeFil_DrawFilterTypeField_Join/g
s/\bSeMenu_Utility_SearchByte_End\b/SeFil_DrawPageHeader_Skip/g
s/\bSeMenu_Utility_SearchByte\b/SeFil_DrawPageHeader/g
s/\bSeMenu_Utility_FormatNumber\b/SeFil_DrawPageHeader_Join/g
s/\bSeScreenData_0x1682\b/SeFil_PageHeader_Records/g
