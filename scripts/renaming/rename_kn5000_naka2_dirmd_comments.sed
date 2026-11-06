# lane open12/kn5000-naka2: GUI_DisplayStructData (a label 6 bytes into NakaWidget_seamplfo1) is gone from
# v10 / v9 / v7 (naka_move_dirmd_screens_to_asm.py); the comments that named it.  Not for v6 / v5.
/^;/s/^; GUI_DisplayStructData \.\. the end of ToneGen_ParamTable:/; NakaWidget_sefillpq1 .. the end of ToneGen_ParamTable:/
/^;/s/(GUI_FormatStrings, GUI_DisplayStructData,/(GUI_FormatStrings, the IvDirmdScreen records after it,/
