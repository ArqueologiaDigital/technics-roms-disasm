"""The data of the code 04 deleted: switch tables, their format strings, class records and
registry entries (hdae5000_data_tables.s, hdae5000_init_data.s).

  * the compiled switch tables of SfxTlxBitCheck, LyricJumpEditCheck,
    LBNTlxBitCheck_Unregistered, DelTlxEditCheck, LyricBoxProc (two) and FDFileSelectProc,
    with the "%s" / "%1d" format strings only those routines push;
  * BitmapButt01's 42 x 15 picture and its palette (HDAE5000_Palette_Button01 /
    _Bitmap_Button01): status showed its 1,654 bytes against none in v1.15i;
  * HDAE5000_RECORD_TABLE's records for TtlScreenR3, LyricBox and FDFileSelect: v1.15i's
    table (registered as 0x16A, 0x297f62) has 10 records, SelectList .. AcLanguageText1;
  * the three class procedures in HDAE5000_ClassProc_Table, and SfxTlxBitCheck /
    DelTlxEditCheck / BitmapButt01 (HDAE5000_Alloc_Memory_3) / LyricJumpEditCheck in
    HDAE5000_ObjHandler_Table (v1.15i's ApFunction name table, 0x42A, has none of them).
Their names in the string pools go with 07, once 06 has made those strings labels.
"""
from _edit import delete_block, delete_lines, delete_record

for lab in ["HDAE5000_Fmt_s_SfxTlxBitCheck", "HDAE5000_SfxTlxBitCheck_CaseTable", "HDAE5000_Fmt_1d",
            "HDAE5000_LyricJumpEditCheck_CaseTable", "HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered",
            "HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable", "HDAE5000_Fmt_s_DelTlxEditCheck",
            "HDAE5000_DelTlxEditCheck_CaseTable", "HDAE5000_LyricBoxProc_CaseTable2",
            "HDAE5000_LyricBoxProc_CaseTable1", "HDAE5000_Fmt_s_s_FDFileSelectProc",
            "HDAE5000_FDFileSelectProc_KeyCaseTable", "HDAE5000_Palette_Button01",
            "HDAE5000_Bitmap_Button01"]:
    print("deleted", lab, len(delete_block("hdae5000_data_tables.s", lab)), "lines")
for lab in ["HDAE5000_Record_TtlScreenR3", "HDAE5000_Record_LyricBox", "HDAE5000_Record_FDFileSelect"]:
    delete_record("hdae5000_data_tables.s", lab)
delete_lines("hdae5000_init_data.s", [
    b"\t.long HDAE5000_TtlScreenR3Proc", b"\t.long HDAE5000_LyricBoxProc", b"\t.long HDAE5000_FDFileSelectProc"] +
    [b"\t.long HDAE5000_" + p + n for n in (b"SfxTlxBitCheck", b"DelTlxEditCheck", b"BitmapButt01",
                                           b"LyricJumpEditCheck") for p in (b"", b"Str_")])
print("ok")
