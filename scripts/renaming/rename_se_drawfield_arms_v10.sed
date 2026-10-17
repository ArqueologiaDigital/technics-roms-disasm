# v10: the per-field arms of four sound-editor field-redraw routines keep their structural names (field 0 =
# SetupPath, the indexed bound record = DefaultPath, the part radio buttons = CallHelper) but take the routine
# they belong to as prefix.  The old prefixes (PatchEdit, NameEdit, EqEdit, BankEdit) were wrong guesses for
# SeTonTon1 / SeEasy / SeCtr2 / SeTonHyb1 _DrawField (scripts/renaming/name_se_title_methods.py).
s/\bSeMenu_PatchEdit_SetupPath_Records2\b/SeTonTon1_DrawField_SetupPath_Records2/g
s/\bSeMenu_BankEdit_SetupPath_Records2\b/SeTonHyb1_DrawField_SetupPath_Records2/g
s/\bSeMenu_NameEdit_SetupPath_Records2\b/SeEasy_DrawField_SetupPath_Records2/g
s/\bSeMenu_PatchEdit_SetupPath_Records\b/SeTonTon1_DrawField_SetupPath_Records/g
s/\bSeMenu_BankEdit_SetupPath_Records\b/SeTonHyb1_DrawField_SetupPath_Records/g
s/\bSeMenu_NameEdit_SetupPath_Records\b/SeEasy_DrawField_SetupPath_Records/g
s/\bSeMenu_EqEdit_SetupPath_Records2\b/SeCtr2_DrawField_SetupPath_Records2/g
s/\bSeMenu_EqEdit_SetupPath_Records\b/SeCtr2_DrawField_SetupPath_Records/g
s/\bSeMenu_PatchEdit_DefaultPath\b/SeTonTon1_DrawField_DefaultPath/g
s/\bSeMenu_NameEdit_DefaultPath\b/SeEasy_DrawField_DefaultPath/g
s/\bSeMenu_PatchEdit_CallHelper\b/SeTonTon1_DrawField_CallHelper/g
s/\bSeMenu_PatchEdit_SetupPath\b/SeTonTon1_DrawField_SetupPath/g
s/\bSeMenu_BankEdit_SetupPath\b/SeTonHyb1_DrawField_SetupPath/g
s/\bSeMenu_EqEdit_DefaultPath\b/SeCtr2_DrawField_DefaultPath/g
s/\bSeMenu_NameEdit_SetupPath\b/SeEasy_DrawField_SetupPath/g
s/\bSeMenu_EqEdit_SetupPath\b/SeCtr2_DrawField_SetupPath/g
s/\bSeMenu_PatchEdit_Return\b/SeTonTon1_DrawField_Return/g
s/\bSeMenu_BankEdit_Return\b/SeTonHyb1_DrawField_Return/g
s/\bSeMenu_NameEdit_Return\b/SeEasy_DrawField_Return/g
s/\bSeMenu_EqEdit_Return\b/SeCtr2_DrawField_Return/g
