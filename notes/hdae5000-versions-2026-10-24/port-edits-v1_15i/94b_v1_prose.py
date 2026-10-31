#!/usr/bin/env python3
"""Block comments of the v1 trees that still described v2.x (2026-10-31, lane open3/kn5000-ports).

The port copied v2.01i's prose; 92_stale_comments.py fixes the quoted addresses and counts it can
recompute, not the features.  These replacements say what v1.x has, each checked in the v1 code:

- parts: eight, LSW .. MD (no TLX, no "TLhd" signature, no "LYRICS" name): HDAE5000_Song_CheckFreeSpace
  tests bits 0-7, HDAE5000_PPORT_Svc13_SendInfosAboutSong copies eight present bytes and calls no
  TLX describer;
- settings sector: three setting bytes QuickLoadMode, LoadByNumberMode, JumpAfterLoad
  (HDAE5000_HD_BuildSettingsSector stores three 0x01 bytes, then 0xFFFFFFFF);
- ten class records (no TtlScreenR3, LyricBox, FDFileSelect): HDAE5000_RECORD_TABLE;
- no FilePanel picture and no Alloc_Memory_3 (00_no_filepanel_picture.py);
- no lyric settings (LyricJumpEditCheck) before WriteConfirmEditCheck;
- the CODE SECTION 1 list and the record-table EVIDENCE block quoted v2.06i addresses: the list is by
  name now, and the evidence block says which ROM its figures are of.

Each replacement is applied where its old text is; where only its new text is (v1.10i, which
`../port-edits-v1_10i/replay.sh` makes from the v1.15i tree that already has them), it is skipped.
Run with PORT_TREE=hdae5000_v1_10i for v1.10i.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _edit  # noqa: E402

EDITS = {
    "hdae5000_data_tables.s": [
        (b";                                13 records (e.g. record 7 -> HDAE5000_TtlScreenR3Proc\n"
         b";                                at 0x280645, byte-identical address)\n",
         b";                                10 records in v1.x (e.g. record 6 -> HDAE5000_TtlScreenR2Proc;\n"
         b";                                v2.x has 13: TtlScreenR3, LyricBox, FDFileSelect)\n"),
        (b";  HDAE5000_TtlScreenRProc / _TtlScreenR2Proc / _TtlScreenR3Proc, which sat in\n",
         b";  HDAE5000_TtlScreenRProc / _TtlScreenR2Proc (v1.x has no _TtlScreenR3Proc), which sat in\n"),
        (b"; EVIDENCE.  Every claim above is checked by the committed probe\n"
         b"; hdae5000/tools/verify_record_table.py, run from the repo root; it reads\n"
         b"; original_ROMs/hd-ae5000_v2_06i.ic4 at load base 0x280000 and nothing else:\n",
         b"; EVIDENCE (of the v2.06i ROM, whose 13 records this block was written for; v1.x has 10 and\n"
         b"; the gate's byte compare checks them).  The committed probe\n"
         b"; hdae5000/tools/verify_record_table.py, run from the repo root, reads\n"
         b"; original_ROMs/hd-ae5000_v2_06i.ic4 at load base 0x280000 and nothing else:\n"),
        (b";   at offset 5; TM files start with \"KN5000 SOUND RAM\" (16 bytes), TLX files with \"TLhd\".\n",
         b";   at offset 5; TM files start with \"KN5000 SOUND RAM\" (16 bytes).  (v2.x adds TLX, \"TLhd\".)\n"),
    ],
    "hdae5000_hd_driver.s": [
        (b"; the nine 14-byte names of HDAE5000_PartNames_Text (\"CURRENT PANEL\" ...\n"
         b"; \"LYRICS\", parts LSW..TLX), each part whose bit is clear in the mask is\n",
         b"; the eight 14-byte names of HDAE5000_PartNames_Text (\"CURRENT PANEL\" ...,\n"
         b"; parts LSW..MD; v1.x has no LYRICS part), each part whose bit is clear in the mask is\n"),
        (b"; 0 \"---\", 1 \"NO \", 2 \"YES\"; parts LSW..TLX.  Records: HDAE5000_RAM_SaveOptions\n",
         b"; 0 \"---\", 1 \"NO \", 2 \"YES\"; parts LSW..MD.  Records: HDAE5000_RAM_SaveOptions\n"),
        (b"; v2.01i has no LyricForeColorCheck / LyricBackColorCheck (the lyric colour\n"
         b"; settings of v2.06i): WriteConfirmEditCheck follows LyricJumpEditCheck.\n",
         b"; v1.x has none of the lyric settings (LyricJumpEditCheck; v2.06i's LyricForeColorCheck /\n"
         b"; LyricBackColorCheck): WriteConfirmEditCheck follows WriteProtectEditCheck.\n"),
        (b"\t; Show the nine save-option flags (0x22AA4E..56) as \"---\"/\"NO \"/\"YES\"\n"
         b"\t; (pointer table 0x2E2922) in the objects \"RAM_EDIT_LSW\"..\"RAM_EDIT_TLX\"\n",
         b"\t; Show the eight save-option flags (HDAE5000_RAM_SaveOptions+2..+9) as \"---\"/\"NO \"/\"YES\"\n"
         b"\t; (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES) in the objects \"RAM_EDIT_LSW\"..\"RAM_EDIT_MD\"\n"),
    ],
    "hdae5000_filesystem.s": [
        (b"; Show the nine delete-option flags (HDAE5000_RAM_DeleteOptions+2..+10) as the\n",
         b"; Show the eight delete-option flags (HDAE5000_RAM_DeleteOptions+2..+9) as the\n"),
    ],
    "hdae5000_init_data.s": [
        (b";   Lyrics/file-select message vocabulary shared with the main CPU; count in\n",
         b";   file-select message vocabulary shared with the main CPU (no MT_SelectAll in v1.x); count in\n"),
    ],
    "hdae5000_ui_display.s": [
        (b"; a constant lookup, the fifth of five alike -- Logo, DriveMech, FilePanel,\n"
         b"; Icon and this one).",
         b"; a constant lookup, the fourth of four alike -- Logo, DriveMech, Icon and this\n"
         b"; one; v1.x has no FilePanel picture)."),
        (b"\t\t\t\t\t; IvHddNaming, HDTitleMenu, TtlScreenR2, TtlScreenR3,\n"
         b"\t\t\t\t\t; AcWindowPage1, IvScreenR2, AcLanguageText1, LyricBox, FDFileSelect\n",
         b"\t\t\t\t\t; IvHddNaming, HDTitleMenu, TtlScreenR2,\n"
         b"\t\t\t\t\t; AcWindowPage1, IvScreenR2, AcLanguageText1\n"),
        (b"; The mask of the parts a song holds: bit k for part k (LSW PMT SQT CMP TM MSP\n"
         b"; RCM MD TLX) whose first-cluster slot is not 0xFFFFFFFF.\n",
         b"; The mask of the parts a song holds: bit k for part k (LSW PMT SQT CMP TM MSP\n"
         b"; RCM MD) whose first-cluster slot is not 0xFFFFFFFF.\n"),
        (b"; (TM), \"H\\0K\" (MSP, RCM), \"HK\" (MD), \"TLhd\" (TLX); compared with\n",
         b"; (TM), \"H\\0K\" (MSP, RCM), \"HK\" (MD); compared with\n"),
        (b"; _cmp_sv_mae, _msp_sv_mae; TM counts 0x72AA bytes, TLX 0x5000), converts each\n",
         b"; _cmp_sv_mae, _msp_sv_mae; TM counts 0x72AA bytes; parts 0-7), converts each\n"),
        (b"; part 8, and HDAE5000_TlxPart_Describe for the lyrics (+0xBF).  When\n"
         b"; HDAE5000_HD_GetSongInfo finds the song, the mask, both names and the nine\n"
         b"; present bytes come from it.\n",
         b"; part 8 (v1.x has no lyrics part, so no TLX description).  When\n"
         b"; HDAE5000_HD_GetSongInfo finds the song, the mask, both names and the eight\n"
         b"; present bytes come from it.\n"),
        (b";    sector 1 (7), signature (8), its six setting bytes to QuickLoadMode ..\n"
         b";    LyricBackColor, free clusters (9), tables (10).\n",
         b";    sector 1 (7), signature (8), its three setting bytes to QuickLoadMode,\n"
         b";    LoadByNumberMode, JumpAfterLoad, free clusters (9), tables (10).\n"),
        (b"; signature AA55AA55 F4F1F2F3, the 112-byte HDAE5000_Version_Info, the six\n"
         b"; setting bytes = 1 (also stored to QuickLoadMode .. LyricBackColor), then\n",
         b"; signature AA55AA55 F4F1F2F3, the 112-byte HDAE5000_Version_Info, the three\n"
         b"; setting bytes = 1 (also stored to QuickLoadMode, LoadByNumberMode, JumpAfterLoad), then\n"),
        (b"; Read sector 1 into HDAE5000_RAM_HdSettingsSector and restore the six setting\n"
         b"; bytes it carries at +120 into QuickLoadMode .. LyricBackColor -- the\n",
         b"; Read sector 1 into HDAE5000_RAM_HdSettingsSector and restore the three setting\n"
         b"; bytes it carries at +120 into QuickLoadMode, LoadByNumberMode, JumpAfterLoad -- the\n"),
        (b"\t; data), six setting bytes copied from sector 1's image (0x2006A0) to\n"
         b"\t; 0x229DA9..AE, blank tables (HDAE5000_HD_InitTables).",
         b"\t; data), three setting bytes copied from sector 1's image\n"
         b"\t; (HDAE5000_RAM_HdSettingsSector+120) to QuickLoadMode, LoadByNumberMode,\n"
         b"\t; JumpAfterLoad, blank tables (HDAE5000_HD_InitTables)."),
        (b"; the six setting bytes QuickLoadMode .. LyricBackColor at +120, a\n",
         b"; the three setting bytes QuickLoadMode, LoadByNumberMode, JumpAfterLoad at +120, a\n"),
    ],
    "hd-ae5000_v1_15i.s": [
        (b"; \"QUICK LOAD MODE\" (TitleInfo); one of the six setting bytes of sector 1",
         b"; \"QUICK LOAD MODE\" (TitleInfo); one of the three setting bytes of sector 1"),
        (b"; nine 14-byte tab-ended part names + NUL (0x7F bytes), HDAE5000_PartList_Build",
         b"; eight 14-byte tab-ended part names + NUL (v1.x; v2.x nine, 0x7F bytes), HDAE5000_PartList_Build"),
        (b"; CODE SECTION 1 (0x280020 - 0x28F575)\n",
         b"; CODE SECTION 1 (from HDAE5000_Handler_Registration; the addresses are in the ELF)\n"),
        (b";   0x280020  Handler_Registration - Register 11 handlers with main CPU workspace\n"
         b";   0x28030E  Alloc_Memory_1 - Bitmap resource descriptor, HDAE5000_Bitmap_TitleLogo\n"
         b";                             (A1 = 0x2A898E bitmap data, not a palette)\n"
         b";   0x28033B  Alloc_Memory_2 - Bitmap resource descriptor, HDAE5000_Bitmap_DriveMech\n"
         b";                             (A1 = 0x2BB98E bitmap data, not a palette)\n"
         b";   0x280368  Alloc_Memory_3 - Bitmap resource descriptor, HDAE5000_Bitmap_FilePanel\n"
         b";                             (A1 = 0x2CE98E bitmap data, not a palette)\n"
         b";   0x280395  BitmapHdd_icon - Bitmap resource descriptor, HDAE5000_Bitmap_HddIcon\n"
         b";                             (A1 = 0x2E198E bitmap data, not a palette; unlike\n"
         b";                              its three neighbours this one carries the\n"
         b";                              firmware's own registry name)\n"
         b";   0x2803C2  HDAE5000_UiState_Reset - (was Register_Frame; see its header)\n"
         b";   0x28F543  Alloc_Memory - Bitmap resource descriptor for the boot splash\n"
         b";                             (A1 = 0x2E61CE HDAE5000_Bitmap_BootSplash, A2 = 320,\n"
         b";                              A3 = 240 -- bitmap data, not a palette)\n",
         b";   Handler_Registration - register the module's handlers with the main CPU workspace\n"
         b";   Alloc_Memory_1 - Bitmap resource descriptor, HDAE5000_Bitmap_TitleLogo\n"
         b";   Alloc_Memory_2 - Bitmap resource descriptor, HDAE5000_Bitmap_DriveMech\n"
         b";   BitmapHdd_icon - Bitmap resource descriptor, HDAE5000_Bitmap_HddIcon (unlike its\n"
         b";                    two neighbours it carries the firmware's own registry name; v1.x\n"
         b";                    has no Alloc_Memory_3 / FilePanel picture)\n"
         b";   HDAE5000_UiState_Reset - (was Register_Frame; see its header)\n"
         b";   Alloc_Memory - Bitmap resource descriptor for the boot splash\n"
         b";                  (HDAE5000_Bitmap_BootSplash, 320 x 240 -- bitmap data, not a palette)\n"),
    ],
}


def main():
    done = skipped = 0
    for f, pairs in EDITS.items():
        if f.startswith("hd-ae5000_"):
            f = os.path.basename(_edit.TREE.replace("hdae5000_", "hd-ae5000_")) + ".s"
        s = _edit.read(f)
        for old, new in pairs:
            if s.count(old) == 1:
                s = s.replace(old, new)
                done += 1
            elif s.count(old) == 0 and new in s:
                skipped += 1
            else:
                sys.exit("%s: %r occurs %d times" % (f, old[:70], s.count(old)))
        _edit.write(f, s)
    print("v1 prose: %d comments corrected, %d already" % (done, skipped))


if __name__ == "__main__":
    main()
