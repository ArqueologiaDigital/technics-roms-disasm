#!/usr/bin/env python3
"""Comment, header and respelling patches that go with rename_open4_naming.sed (kn5000-nl6 leads).

QUESTION IT ANSWERS / WHAT IT DOES
  The sed script renames labels; this applies the edits a sed line cannot: headers for the renamed
  routines, stale comments removed, duplicate labels merged, three data blocks respelled (one spelled as
  code, one as faux instructions, one as `.byte` pointers), a misframed instruction run re-framed, and
  the labels of six unlabelled sound-RAM record helpers placed.  Every edit is a byte-exact replacement
  of a known text; a tree where the text is not found exactly the expected number of times is reported
  and left alone (the run prints one line per edit and tree).  Nothing here changes a ROM byte: `make
  gate` must stay byte-identical afterwards.  Evidence for every name and comment:
  notes/open4-kn5000-b/naming/README.md.

RUN (repository root, KN5000 maincpu trees v10 v9 v7 v6 v5):
  python3 scripts/renaming/open4_naming_patches.py --pre          # before the sed (old names)
  for t in v10 v9 v7 v6 v5; do command grep -rlZ --include='*.s' --include='*.c' -E '<old names>' $t/maincpu \\
      | xargs -0 sed -i -f scripts/renaming/rename_open4_naming.sed; done
  python3 scripts/renaming/open4_naming_patches.py --post         # after the sed (new names)
Both phases are one-shot: a second run finds nothing to replace and says so.
"""
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ["v10", "v9", "v7", "v6", "v5"]
REPORT = []


def path(tree, rel):
    return os.path.join(REPO, tree, "maincpu", rel)


def replace(rel, old, new, count=1, trees=TREES, tag=None):
    old, new = old.encode("latin-1"), new.encode("latin-1")
    for t in trees:
        p = path(t, rel)
        if not os.path.exists(p):
            REPORT.append("%-5s %-44s no file" % (t, tag or rel))
            continue
        b = open(p, "rb").read()
        n = b.count(old)
        if n != count:
            REPORT.append("%-5s %-44s found %d, want %d: SKIPPED" % (t, tag or rel, n, count))
            continue
        open(p, "wb").write(b.replace(old, new))
        REPORT.append("%-5s %-44s ok" % (t, tag or rel))


def regex(rel, pattern, new, trees=TREES, tag=None):
    rx = re.compile(pattern.encode("latin-1"), re.M)
    for t in trees:
        p = path(t, rel)
        if not os.path.exists(p):
            REPORT.append("%-5s %-44s no file" % (t, tag or rel))
            continue
        b = open(p, "rb").read()
        found = rx.findall(b)
        if len(found) != 1:
            REPORT.append("%-5s %-44s found %d: SKIPPED" % (t, tag or rel, len(found)))
            continue
        open(p, "wb").write(rx.sub(lambda m: new.encode("latin-1"), b))
        REPORT.append("%-5s %-44s ok" % (t, tag or rel))


def header(rel, label, text, trees=TREES):
    """Replace the comment lines directly above `label:` (none is fine) with `text`."""
    lines = "".join(("; " if i == 0 else ";   ") + l.rstrip() + "\n" for i, l in enumerate(text.strip("\n").split("\n")))
    regex(rel, r"(?:^;[^\n]*\n)*^%s:" % re.escape(label), lines + label + ":", trees, tag=rel + " " + label)


def pre():
    for t, f in (("v10", "kn5000_v10_program.s"), ("v9", "kn5000_v9_program.s")):
        replace(f, "\t.set HdaeRom_DispatchOffsetTable, COMM_InitFuncTable + 540\n"
                   "\t.set HdaeRom_AltDispatchOffsetTable, COMM_InitFuncTable + 552\n", "", trees=[t])
    replace("sequencer/accompaniment_engine.s", "; MspMenuTtlFunc case 2\nMspMenuTtl_Case2:\n", "")
    replace("storage/flash_floppy_handlers.s", "; SndArgGridBnk case 3\nSndArg_GridBnk_Case3:\n", "")
    replace("audio/sound_editor_ui.s", "\tld\txiz, SeMenu_ShowConfirmDialog_Code\nSeMenu_ShowConfirmDialog_Data_Code_Loop2:\n",
            "\tld\txiz, SeMenu_KeyboardOctave_BlackKeyX\nSeMenu_DrawKeyboardOctave_BlackKeyLoop:\n")
    replace("audio/sound_editor_ui.s", "\tjr\tnz, SeMenu_ShowConfirmDialog_Data_Code_Loop2\n",
            "\tjr\tnz, SeMenu_DrawKeyboardOctave_BlackKeyLoop\n")


def post():
    # --- SeqState_Case4 neighbourhood: the "Sequencer state case N" comments are not switch cases.
    for n in range(5):
        replace("sequencer/sequencer_engine.s", "; Sequencer state case %d\n" % n, "", tag="seq-state-case-%d" % n)

    # --- one-panel-memory single load
    header("demo/file_demo_proc.s", "SingleLoad_LoadPanelMemory",
           "SingleLoad_LoadPanelMemory: Single-loads one panel memory of the selected .PMT file, memory WA of the file\n"
           "into memory BC: checks the file signature, then reads one entry (entry size at RAM 0x1ED35D) from file\n"
           "176 + WA * size into 0x1ED350 + 176 + BC * size between PanelMemory_PreSlotLoad and\n"
           "PanelMemory_PostSlotLoad; returns HL = read result, 0xFF98 with no file selected, 0xFF9A on a wrong\n"
           "signature. Basis: callers + body -- SingleLoadDst_PanelMemListProc runs it for parameter 10 when the ALL\n"
           "flag is clear, with WA = SLOAD_SRC_PMEM_POS and BC = SLOAD_DST_PMEM_POS (SingleLoad_LoadPanelMemBank is\n"
           "the ALL-mode bank load).")

    # --- file_io/wallpaper.s: the single-load helpers after FmmWallpaperLoadFunc
    regex("file_io/wallpaper.s", r"^; -{20,}\n; Wallpaper Name Getter Routines\n(?:;[^\n]*\n)*?; -{20,}\n",
          "; -----------------------------------------------------------------------------\n"
          "; Single-load helpers.  Only FmmWallpaperLoadFunc above is wallpaper code; the routines below scan\n"
          "; the single-load areas and fetch the names the SINGLE LOAD source and destination lists show (file\n"
          "; buffer 0x1ED350, sound RAM 0x1E0000, the composer records 0x948A0, ROM name tables).  Callers:\n"
          "; file_io/single_load.s.  XWA = destination buffer, E = the marker byte stored first.\n"
          "; -----------------------------------------------------------------------------\n", tag="wallpaper block")
    W = "file_io/wallpaper.s"
    header(W, "SingleLoad_ScanAreas",
           "SingleLoad_ScanAreas: Sets bit SingleLoad_AreaFlagBits[n] of RAM 0x89F6 for each single-load area n = 0..3\n"
           "that is present: considered when CheckFileSystemStatus's flag word has that bit; checked with\n"
           "FileIO_ValidateAndOpenFile (value 3), signature + region (2) or the signature (other); when the current\n"
           "area SINGLE_LOAD_AREA is 4 or more it is set to the area just found. Basis: callers + body -- the\n"
           "SINGLE LOAD entry in file_io/single_load.s calls it before SingleLoad_FindNextArea.")
    header(W, "SingleLoad_FindNextArea",
           "SingleLoad_FindNextArea: Steps SINGLE_LOAD_AREA round-robin to the next area whose bit is set in RAM 0x89F6\n"
           "(SingleLoad_ScanAreas); L = 1 when one was found, 0 when none is present or the area is 4 or more. Basis:\n"
           "callers + body.")
    header(W, "SingleLoad_GetFileBankName",
           "SingleLoad_GetFileBankName: Writes E, then the 16-byte name of panel-memory bank BC of the loaded .PMT file\n"
           "(0x1ED350 + 16 + 16 * BC) to XWA, trimmed and padded to 16 (TrimAndPadSmfFilename). Basis: callers --\n"
           "the panel-memory bank lists of file_io/single_load.s.")
    header(W, "SingleLoad_GetFileMemoryName",
           "SingleLoad_GetFileMemoryName: Writes E, then the name of panel memory BC of the loaded .PMT file\n"
           "(0x1ED350 + entry size (+13) * BC + 178) to XWA, padded to 16. Basis: callers -- the panel-memory item\n"
           "rows of the single-load destination list.")
    header(W, "SingleLoad_GetComposerBankName",
           "SingleLoad_GetComposerBankName: Writes E, then SingleLoad_MemoryBankNames[BC] (\"MEMORY-A\" / \"-B\" / \"-C\")\n"
           "to XWA, padded to 16. Basis: callers -- the COMPOSER source and destination lists (BC = position / 10).")
    header(W, "SingleLoad_GetVariationName",
           "SingleLoad_GetVariationName: Returns XHL = PtrTbl_VariationNames[WA] (\"VARI 1\"..\"VARI 4\", then empty).\n"
           "Basis: callers -- the COMPOSER single-load lists (WA = item mod items per bank).")
    header(W, "SingleLoad_GetComposerSectionName",
           "SingleLoad_GetComposerSectionName: Writes the marker (stack word), then the name of section DE of composer\n"
           "bank BC to XWA: sections 0-3 (VARI 1-4) from the 96-byte composer records at RAM 0x948A0 + 96 * (4 * BC +\n"
           "DE) (13 bytes), sections 4-9 from SingleLoad_StyleSectionNames (INTRO 1 .. ENDING 2); padded to 16; pops\n"
           "the marker word (retd 2). Basis: callers -- SingleLoadSrc_ComposerDrawPatternSlot and\n"
           "SingleLoadDst_DrawComposerItemRows.")
    header(W, "SingleLoad_GetSoundMemBankName",
           "SingleLoad_GetSoundMemBankName: Writes E, then SingleLoad_SoundMemBankNames[BC] (\"MEMORY A\", \"MEMORY B\",\n"
           "\"USER KIT\") to XWA, padded to 16. Basis: callers -- the SOUND MEMORY source and destination lists (BC =\n"
           "position / 20).")
    header(W, "SingleLoad_GetSoundRamName",
           "SingleLoad_GetSoundRamName: Writes E, then the 16-byte name of sound-RAM sound BC (0x1E0000 + 16 + 470 * BC)\n"
           "to XWA, padded to 16. Basis: callers -- the SOUND MEMORY destination list.")
    header(W, "SingleLoad_GetUserKitName",
           "SingleLoad_GetUserKitName: Writes E, then the 16-byte USER KIT name in sound RAM (0x1E4980) to XWA, padded to\n"
           "16; BC is not used. Basis: callers -- the SOUND MEMORY destination list's USER KIT row.")
    header(W, "SingleLoad_GetUserKitEntryName",
           "SingleLoad_GetUserKitEntryName: Writes E and a space, then the 13-byte name of USER KIT entry BC (0x1E4AA7 +\n"
           "80 * BC) to XWA, padded to 15. Basis: callers -- the SOUND MEMORY destination list past the 2 x 20 sounds.")

    # --- value-map lookups
    header("audio/note_voice_mapping.s", "SndParam_ValueMapLookup",
           "SndParam_ValueMapLookup: Zero-extends WA (selector), BC (value) and DE (map row) and tail-jumps to\n"
           "SndParam_OffsetHandler, the SndParam_ValueMapGrid lookup. Basis: callers + body --\n"
           "SndParam_ValueMapLookupSel1/Sel2 and three accompaniment-engine sites call it.")
    header("display/scoop_display.s", "SndParam_ValueMapLookupSel1",
           "SndParam_ValueMapLookupSel1: Value-map lookup with selector 1: A = value, C = map row -> BC = value, DE = row,\n"
           "WA = 1, then SndParam_ValueMapLookup. Basis: callers + body -- DisplayMode_Handler_3_Helper2 wraps it.")
    header("display/scoop_display.s", "SndParam_ValueMapLookupSel2",
           "SndParam_ValueMapLookupSel2: Value-map lookup with selector 2 (column 5 of the SndParam_ValueMapGrid row):\n"
           "A = value, C = map row -> BC, DE, WA = 2, then SndParam_ValueMapLookup. Basis: callers + body --\n"
           "PerfMode_LookupValueMapColumn5 wraps it.")

    # --- sequencer error maps
    S = "sequencer/sequencer_engine.s"
    header(S, "SeqError_MapViaTableE",
           "SeqError_MapViaTableE: GLOBAL_ERROR_CODE = SeqError_MapTableE[SEQ_ERROR_CODE] (SeqError_MapToGlobal). Basis:\n"
           "callers + body -- the velocity-edit exit (SeqPart_VelEditReturn).")
    header(S, "SeqError_MapToGlobal",
           "SeqError_MapToGlobal: GLOBAL_ERROR_CODE = (XWA)[SEQ_ERROR_CODE]: translates the sequencer's error code into\n"
           "the global one through the table each SeqError_MapViaTable* entry above loads. Basis: callers + body.")

    # --- ArrowProc's painters
    U = "ui/ui_control_panel.s"
    for lab, axis in (("Arrow_DrawHorizontal", "width"), ("Arrow_DrawVertical", "height")):
        header(U, lab,
               "%s: Paints ArrowProc's arrow into the client box at XWA (four words): DE percent of the box %s is the\n"
               "head, a fan of DrawLineHelper lines one pixel apart that widen towards the base, the rest is the\n"
               "shaft on the box's centre line; BC and the two pushed words go to DrawLineHelper, the first pushed\n"
               "word also picks the pointing direction (1, 2, 3) (retd 4). Basis: callers + body -- ArrowProc's\n"
               "EVT_PAINT calls %s with DE = instance +28 and BC = view +22." % (lab, axis, "it when view word +24 is 0" if axis == "width" else "it when view word +24 is set"))

    # --- FDD test title
    T = "factory_test/test_init.s"
    header(T, "FDTest_Format2ddAndLabel",
           "FDTest_Format2ddAndLabel: Switch 4 of the FDD test title: format_FD(2) (a 2DD disk), then\n"
           "FileIO_CheckPathAndVolumeLabel(\"TEST_HAMA\"); HL = 0. Basis: callers + body.")
    header(T, "FDTest_Format2hdAndLabel",
           "FDTest_Format2hdAndLabel: Switch 5 of the FDD test title: format_FD(3) (a 2HD disk), then\n"
           "FileIO_CheckPathAndVolumeLabel(\"TESTHAMA2HD\"); HL = 0. Basis: callers + body.")
    header(T, "TestTitleFunc",
           "TestTitleFunc: Main function of the two FDD test titles (RegTitleHama above). EVT_SW_IN: XDE = switch 0..7\n"
           "through TestTitleFunc_SwitchCaseTable -- 0 TBIOS test (FDTest_ProbeDiskFormat), 1 stop the test loop, 2\n"
           "one test pass and re-arm, 3 DIR listing, 4 / 5 format a 2DD / 2HD disk, 6 list A:\\HAMA\\*.LSW, 7\n"
           "nothing. EVT_ACTIVATE_STATE: XDE = 2..7 through TestTitleFunc_StateCaseTable prints \"Title new\", \"old\",\n"
           "\"Inactivate\", \"Activate\", \"INTERUPT\", \"INTERUPT RETURN\". Returns XHL = 0. Basis: callers + body + the\n"
           "two case tables (factory_test/fd_test_data.s).")
    header(T, "TestTitleFunc_OnTitleNew",
           "TestTitleFunc_OnTitleNew: EVT_ACTIVATE_STATE phase 2: prints \"Title new\"; also the base of the phase\n"
           "switch (TestTitleFunc_StateCaseTable).")
    header(T, "TestTitleFunc_OnTitleOld",
           "TestTitleFunc_OnTitleOld: EVT_ACTIVATE_STATE phase 3: prints \"Title old\".")
    header(T, "TestTitleFunc_OnTbiosTest",
           "TestTitleFunc_OnTbiosTest: Switch 0 of the FDD test title: prints \"TBIOS Test\" and runs\n"
           "FDTest_ProbeDiskFormat; also the base of the switch (TestTitleFunc_SwitchCaseTable).")
    regex("factory_test/fd_test_code.s",
          r"^;   2\. When the title system activates one of these titles \(exact user-facing\n(?:;[^\n]*\n)*?;        4 = DIR \(directory listing\)\n",
          ";   2. When the title system activates one of these titles (exact user-facing\n"
          ";      menu path not yet traced; likely a hidden service/diagnostic mode),\n"
          ";      TestTitleFunc gets EVT_ACTIVATE_STATE with XDE = 2..7 and prints\n"
          ";      \"Title new\" / \"old\" / \"Inactivate\" / \"Activate\" / \"INTERUPT\" /\n"
          ";      \"INTERUPT RETURN\".\n"
          ";\n"
          ";   3. Its switches arrive as EVT_SW_IN with XDE = switch number:\n"
          ";        0 = TBIOS Test               4 = format 2DD (\"TEST_HAMA\")\n"
          ";        1 = STOP FDD TEST            5 = format 2HD (\"TESTHAMA2HD\")\n"
          ";        2 = START FDD TEST LOOP      6 = list A:\\HAMA\\*.LSW\n"
          ";        3 = DIR (directory listing)  7 = nothing\n", tag="fd_test_code.s banner")

    # --- SqplyFunc / EqOnOffFuncToggleProc
    replace("sequencer/sequencer_ui.s", "; SqplyFunc format dispatch\nEqOnOff_ReturnZero:\n", "EqOnOff_ReturnZero:\n")
    replace("sequencer/sequencer_ui.s", "; SqplyFunc format entry\nEqOnOff_Epilogue:\n", "EqOnOff_Epilogue:\n")

    # --- seq-to-composer TRANSPOSE / memory number
    A = "sequencer/accompaniment_engine.s"
    header(A, "SeqToComposer_StepTranspose",
           "SeqToComposer_StepTranspose: TRANSPOSE parameter (0x82) of the sequencer-to-composer page: steps RAM 0x398E\n"
           "up (A = 0, at most 49) or down (at least 1) and sets bit 4 of 0xE3E0. 0x398E is 25 for no transpose\n"
           "(-24..+24 semitones). Basis: callers + readers -- PsS2cTrans paints PtrTbl_TransposeStrs[(0x398E)], the\n"
           "0x90 note path adds (0x398E) - 25 to the key, the page's init writes 25.")
    header(A, "SeqToComposer_IncMemoryNo",
           "SeqToComposer_IncMemoryNo: Only for A = 0: records the change for the display (Tempo_DisplayParamCommon, A\n"
           "= 9, C = 8) and steps the destination composer memory number 0x398F up, at most to 29, setting bit 4 of\n"
           "0xE3E0. Basis: callers + readers -- S2cMemNoBox paints (0x398F), SeqRec_ValidateDone and the voice-slot\n"
           "init read the composer record at 0x94860 + 96 * (0x398F).")
    header(A, "SeqToComposer_DecMemoryNo",
           "SeqToComposer_DecMemoryNo: Only for A = 0: as SeqToComposer_IncMemoryNo, stepping 0x398F down to 0.")

    # --- sound-RAM image conversion (NOT the HD-AE5000)
    N = "audio/note_voice_mapping.s"
    header(N, "SoundRam_IdentifyImage",
           "SoundRam_IdentifyImage: Compares the 16-byte id at XWA with SoundRam_Id_KN5000 / _KN1500 / _KN3000 /\n"
           "_KN2000 / _MKA / _MKB and returns L = 6, 5, 4, 1, 2, 3, or 0 for none. Basis: body.")
    header(N, "SoundRam_WriteChecksum",
           "SoundRam_WriteChecksum: Stores the complemented 16-bit sum of the 0x24B8 words from 0x1E0010 at\n"
           "0x1E72A8 (the image's checksum word); HL = 0. Basis: body + SoundRam_WriteIdAndChecksum.")
    replace(N, "; HDAE ROM data dispatch handler\nSoundRam_ConvertSounds:\n", "SoundRam_ConvertSounds:\n")
    header(N, "SoundRam_ConvertSounds",
           "SoundRam_ConvertSounds: Converts the sound records of the SOUND RAM image at 0x1E0000 when it is an older\n"
           "model's (SoundRam_IdentifyImage): KN2000, MKA and MKB records (SoundRam_ConvertSounds_Kn2000MkaMkb) and\n"
           "KN1500 records (SoundRam_ConvertSounds_Kn1500); a KN3000 or KN5000 image needs none; an unknown one\n"
           "returns HL = 0xFF9A. With A = C = 0xFF it walks all 40 sounds (other A, C: not traced). Basis: callers + body -- PostTmLoad,\n"
           "PostTmLoadEntry and TmFlashWrite_ValidateParams call it before SoundRam_ConvertUserKit and\n"
           "SoundRam_WriteIdAndChecksum.  (Named HdaeRom_DataHandler until 2026-10-31: it has nothing to do with the\n"
           "HD-AE5000.)")
    replace(N, "; HDAE5000 extension ROM data dispatch (6-entry, table SoundRam_ConvertSounds_CaseTable)\n", "",
            tag="ConvertSounds case comment")
    replace(N, "; HDAE ROM alt dispatch handler\nSoundRam_ConvertUserKit:\n", "SoundRam_ConvertUserKit:\n")
    header(N, "SoundRam_ConvertUserKit",
           "SoundRam_ConvertUserKit: Converts the USER KIT part of the SOUND RAM image at 0x1E0000: a KN3000 image\n"
           "through SoundRam_ConvertKn3000UserKit (result 0), a KN5000 one needs nothing (0), the others have no kit\n"
           "(0xFF9A); then stamps the KN5000 id and checksum like SoundRam_WriteIdAndChecksum and returns HL = the\n"
           "result. Basis: callers + body (case table SoundRam_ConvertUserKit_CaseTable).  (Was HdaeRom_AltHandler.)")
    replace(N, "; HDAE5000 extension ROM alt dispatch (6-entry, table SoundRam_ConvertUserKit_CaseTable)\n", "",
            tag="ConvertUserKit case comment")
    header(N, "SoundRam_ConvertKn3000UserKit",
           "SoundRam_ConvertKn3000UserKit: KN3000 image at XWA: moves the bytes from +0x4991 up to +0x72A7 one byte\n"
           "up, then for the 128 kit entries at +0x49A7 sets bits 5..4 of entry byte +1 to 0b10. Basis: body; what the\n"
           "two fields mean is not established.")
    # the six unlabelled record helpers after TmFlash_BulkTransferToSubCPU
    hdr = lambda name, text: "; %s: %s\n%s:\n" % (name, text, name)
    replace(N, "\tjp\tTmFlash_Return\n\tld\txwa, 0x1e0000\n\tcalr\tSoundRam_IdentifyImage\n\tldw\twa, 0xff9a\n",
            "\tjp\tTmFlash_Return\n" + hdr("SoundRam_CheckKn5000Image",
            "HL = 0 when the image at 0x1E0000 is a KN5000 one,\n;   else 0xFF9A. Basis: body.")
            + "\tld\txwa, 0x1e0000\n\tcalr\tSoundRam_IdentifyImage\n\tldw\twa, 0xff9a\n", tag="CheckKn5000Image")
    replace(N, "SoundRam_CheckKn5000Image_Store:\n\tld\thl, wa\n\tret\n",
            "SoundRam_CheckKn5000Image_Store:\n\tld\thl, wa\n\tret\n" + hdr("SoundRam_CheckKnownImage",
            "HL = 0 when the image at 0x1E0000 has any of the six\n;   known ids, else 0xFF9A. Basis: body."), tag="CheckKnownImage")
    replace(N, "SoundRam_CheckKnownImage_Fail:\n\tldw\thl, 0xff9a\n\tret\n",
            "SoundRam_CheckKnownImage_Fail:\n\tldw\thl, 0xff9a\n\tret\n" + hdr("SoundRam_GetSoundRecordPtr",
            "XHL = 0x1E0000 + 16 + 470 * WA, sound record WA of\n;   the KN5000 image. Basis: body."), tag="GetSoundRecordPtr")
    replace(N, "\tadd\txhl, xwa\n\tret\n\tdec\t4, xsp\n\tpushw\tiz\n\tld\tiz, bc\n",
            "\tadd\txhl, xwa\n\tret\n" + hdr("SoundRam_GetRecordAddress",
            "XHL = address of sound record BC in the image at XWA,\n;   by its model: 16 + 470 * BC (KN5000,"
            " KN3000), 16 + 289 * BC (KN1500), 80 + 144 * BC (KN2000, MKA, MKB),\n;   0xFFFFFF9A for an unknown image."
            " Basis: body (case table SoundRam_GetRecordAddress_CaseTable).")
            + "\tdec\t4, xsp\n\tpushw\tiz\n\tld\tiz, bc\n", tag="GetRecordAddress")
    replace(N, "SoundRam_GetRecordAddress_Epilogue:\n\tpopw\tiz\n\tinc\t4, xsp\n\tret\n",
            "SoundRam_GetRecordAddress_Epilogue:\n\tpopw\tiz\n\tinc\t4, xsp\n\tret\n" + hdr("SoundRam_GetSoundSlot",
            "For sound WA < 40 of the KN5000 image: (XBC) = its\n;   address 0x1E0010 + 470 * WA, (XDE) = 470, HL = 0;"
            " else HL = 0xFF38. Basis: body."), tag="GetSoundSlot")
    replace(N, "SoundRam_GetSoundSlot_Epilogue:\n\tpop\txiz\n\tinc\t4, xsp\n\tret\n",
            "SoundRam_GetSoundSlot_Epilogue:\n\tpop\txiz\n\tinc\t4, xsp\n\tret\n" + hdr("SoundRam_GetRecordOffsetAndSize",
            "For sound BC of the image at XWA: (XDE) = the record's\n;   offset in the image and (stack word) = its size,"
            " by model (470 KN5000 / KN3000, 289 KN1500, 144 KN2000 /\n;   MKA / MKB); HL = 0, or 0xFF9A for an"
            " unknown image (retd 4). Basis: body (SoundRam_GetRecordOffsetAndSize_CaseTable)."),
            tag="GetRecordOffsetAndSize")
    WD = "ui_widgets/widget_dispatch.s"
    regex(WD, r"^; 6 x s16 switch offsets\.  HdaeRom_DataHandler \(0x[0-9A-F]+\): [^\n]*\n;[^\n]*\n(?=SoundRam_ConvertSounds_CaseTable:)",
          "; SoundRam_ConvertSounds_CaseTable: 6 x s16 case offsets of SoundRam_ConvertSounds's switch on image id - 1\n"
          ";   (KN2000, MKA, MKB, KN3000, KN1500, KN5000), relative to SoundRam_ConvertSounds_Kn1500.\n", tag="ConvertSounds table")
    regex(WD, r"^; 6 x s16 switch offsets\.  HdaeRom_AltHandler \(0x[0-9A-F]+\): [^\n]*\n;[^\n]*\n(?=SoundRam_ConvertUserKit_CaseTable:)",
          "; SoundRam_ConvertUserKit_CaseTable: 6 x s16 case offsets of SoundRam_ConvertUserKit's switch on image id - 1,\n"
          ";   relative to SoundRam_ConvertUserKit_Kn3000.\n", tag="ConvertUserKit table")
    regex(WD, r"^; 6 x s16 switch offsets\.  TmFlash_BulkTransferToSubCPU_Skip2 [^\n]*\n;[^\n]*\n(?=SoundRam_GetRecordAddress_CaseTable:)",
          "; SoundRam_GetRecordAddress_CaseTable: 6 x s16 case offsets of SoundRam_GetRecordAddress's switch on image\n"
          ";   id - 1, relative to SoundRam_GetRecordAddress_Kn5000Kn3000.\n", tag="GetRecordAddress table")
    regex(WD, r"^; 6 x s16 switch offsets\.  TmFlash_BulkTransferToSubCPU_Epilogue2 [^\n]*\n;[^\n]*\n(?=SoundRam_GetRecordOffsetAndSize_CaseTable:)",
          "; SoundRam_GetRecordOffsetAndSize_CaseTable: 6 x s16 case offsets of SoundRam_GetRecordOffsetAndSize's switch\n"
          ";   on image id - 1, relative to SoundRam_GetRecordOffsetAndSize_Kn5000Kn3000.\n", tag="GetRecordOffsetAndSize table")

    # --- sound editor
    replace("audio/semenu_routines.s", "SeMenu_DrawEnvGraphLine (a line clamped to y 59..146)",
            "SeMenu_DrawEnvGraphLine (which offsets and clips the line to y 59..146 on title 0x37 only)")
    regex("audio/sound_editor_ui.s", r"^SeMenu_KeyboardOctave_BlackKeyX:\n(?:\t[^\n]*\n)+?(?=; SeMenu_DrawSelectedPartEnvCurve:)",
          "; SeMenu_KeyboardOctave_BlackKeyX: 5 x {x1, x2}: the x offsets of the five black keys in one 28-px octave\n"
          ";   of the sound editor's mini keyboard (C#, D#, F#, G#, A#). Basis: reader + bytes --\n"
          ";   SeMenu_DrawKeyboardOctave draws each as an op-09 line from (IX + x1, IY + 1) to (IX + x2, IY + 7).\n"
          ";   (Was disassembled as 13 dead instruction lines, SeMenu_ShowConfirmDialog_Code.)\n"
          "SeMenu_KeyboardOctave_BlackKeyX:\n"
          "\t.short\t3, 5\n\t.short\t7, 9\n\t.short\t15, 17\n\t.short\t19, 21\n\t.short\t23, 25\n", tag="black-key table")

    # --- DkMdlyPly
    replace("ui/ui_playback_modes.s", "; DkMdlyPly send audio command\nDkMdlyPly_FindLowestSetBit:\n",
            "; DkMdlyPly_FindLowestSetBit: HL = the index (0..15) of the lowest bit of WA that is set, by\n"
            ";   DkMdlyPly_BitMaskByIndex; 16 when none is. Sends nothing. Basis: body + its one caller.\n"
            "DkMdlyPly_FindLowestSetBit:\n")

    # --- MainSysControl
    MSC = "display/graphics_text_vga.s"
    regex(MSC, r"^; MainSysControl dispatch table\nMainSysCtrl_DispatchTable:\n\t; --- Dispatch table: 9 call entries \(54 bytes\) ---\n",
          "; MainSysControl's EVT_SYS_INI cases, in the order of the INITIAL SETTING list (widget 0x410002): 0\n"
          "; PERFORMANCE (this first block), 1 CURRENT PANEL, 2 PART SETTING, 3 MIDI SETTING, 4 PANEL MEMORY,\n"
          "; 5 COMPOSER, 6 SEQUENCER, 7 MSP USER, 8 SOUND MEMORY (MainSysControl_CaseTable).\n"
          "MainSysCtrl_DispatchTable:\n", tag="MainSysCtrl")

    # --- fade level
    header(N, "COMM_SendFadeLevel",
           "COMM_SendFadeLevel: Set-if-changed sender of the FADE IN/OUT level: stores A in 0xE353 and sends it as\n"
           "COMM packet type 6 (sub-CPU DSP_Set_FadeLevel). Basis: callers + body + receiver.")

    # --- respellings
    replace("audio/sprintf_core.s", "\tlda\txbc, (P2CR:8)\n", "\tlda\txbc, (10:8)\n", count=5)
    replace("audio/sprintf_core.s", "\tlda\txbc, (P2:8)\n", "\tlda\txbc, (8:8)\n", count=1)
    replace("boot/system_handlers.s", "\t.byte\t0xdc, 0x38, 0xff, 0x07\t; minc1 0x07ff,IX\n", "\tminc1_16\tix, 0x7ff\n")
    replace("sequencer/accompaniment_engine.s", "\tjr AccPatch_SeqDispatch_Main\n" + "\tadc wa, (xwa)\n" * 6,
            "\tjr AccPatch_SeqDispatch_Main\n\t.fill\t12, 1, 0x90\t; filler between the vector's two jumps\n")
    regex("sequencer/accompaniment_engine.s", r"^RhythmBuf_BarQuartersByTimeSig:\n(?:\t[^\n]*\n)+?\t\.byte 0x08\n",
          "RhythmBuf_BarQuartersByTimeSig:\n"
          "\t.byte\t2, 4, 6, 8\t; 1/2 .. 4/2\n"
          "\t.byte\t1, 2, 3, 4, 5, 6, 7, 8\t; 1/4 .. 8/4\n"
          "\t.byte\t1, 2, 3, 4, 5, 6, 7, 8\t; 2/8 .. 16/8\n", tag="bar-length table")
    replace(N, "\t.byte 0xf3, 0xe1\n\tld\tl, 1:opc\n\tldw\twa, 0x3ab8\n\tldw\twa, 0xf6e8\n",
            "\tlda\txwa, (xwa+295)\n\tlda\txwa, (xwa+58)\n\tcp\txiz, xwa\n", tag="re-framed lda/lda/cp")
    regex("audio/audio_control_engine.s", r"^MidiStream_PartEventMapTable:\n(?:\t\.(?:byte|fill)[^\n]*\n){22}",
          "MidiStream_PartEventMapTable:\n"
          "\t.long\t0xffffffff\n\t.long\tMidiStream_PartEventMap_Acp1\n\t.long\tMidiStream_PartEventMap_Acp2\n"
          "\t.long\t0xffffffff\n\t.long\tMidiStream_PartEventMap_Acp3\n\t.long\t0xffffffff, 0xffffffff, 0xffffffff\n"
          "\t.long\tMidiStream_PartEventMap_Bass\n\t.long\t0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff\n"
          "\t.long\t0xffffffff, 0xffffffff, 0xffffffff\n"
          + "".join("MidiStream_PartEventMap_%s:\t; part record 0x%02x\n"
                    "\t.byte\t0xb1, 0x%02x, 0x7f, 0x01\n\t.byte\t0xb2, 0x%02x, 0x7f, 0x00\n\t.byte\t0xb3, 0x%02x, 0x7f, 0x02\n"
                    "\t.byte\t0x%02x, 0x04, 0x08, 0x03\n\t.byte\t0x%02x, 0x08, 0x7f, 0x04\n\t.fill\t8, 1, 0xff\n"
                    % (nm, r, r, r, r, r, r) for nm, r in (("Acp1", 0x10), ("Acp2", 0x11), ("Acp3", 0x12), ("Bass", 0x13))),
          tag="PartEventMapTable")


MERGED = ["SndParam_Registry", "SndParam_ReadHandlers", "SndParam_RegisterHandlers", "SndParam_Register2Handlers",
          "SndParam_EncodeHandlers", "SndParam_WriteHandlers", "AcChordBoxProc", "DirmdEmulator"]


def dedupe():
    """After the sed: an alias merged into its semantic label leaves the label defined twice, a few lines
    apart with only comments, blank lines or `.set` between; drop the second definition."""
    for t in TREES:
        root = os.path.join(REPO, t, "maincpu")
        for dp, _, fs in os.walk(root):
            for f in fs:
                if not f.endswith(".s"):
                    continue
                p = os.path.join(dp, f)
                b = open(p, "rb").read()
                changed = False
                for lab in MERGED:
                    rx = re.compile((r"(^%s:[ \t]*\n)((?:[ \t]*\n|;[^\n]*\n|\t\.set[^\n]*\n)*)^%s:[ \t]*\n"
                                     % (lab, lab)).encode(), re.M)
                    b2, n = rx.subn(lambda m: m.group(1) + m.group(2), b)
                    if n:
                        b, changed = b2, True
                        REPORT.append("%-5s %-44s merged %s" % (t, os.path.relpath(p, root), lab))
                if changed:
                    open(p, "wb").write(b)


def v142():
    """Sub-CPU v1.42 leads (v1.41 / v1.40 are regenerated from it by their create_* scripts)."""
    def rep(rel, old, new, count=1, tag=None):
        p = os.path.join(REPO, "v142", "subcpu", rel)
        b = open(p, "rb").read()
        old_b, new_b = old.encode("latin-1"), new.encode("latin-1")
        n = b.count(old_b)
        if n != count:
            REPORT.append("v142  %-44s found %d, want %d: SKIPPED" % (tag or rel, n, count))
            return
        open(p, "wb").write(b.replace(old_b, new_b))
        REPORT.append("v142  %-44s ok" % (tag or rel))
    M = "kn5000_subprogram_v142.s"
    b = open(os.path.join(REPO, "v142", "subcpu", M), "rb").read()
    open(os.path.join(REPO, "v142", "subcpu", M), "wb").write(b.replace(b"ToneGen_WriteVoice_Pan_Pair", b"ToneGen_WriteVoice_TvfPair"))
    rep(M, "; WA = voice, XBC = source record (always 0x0451CC at the call sites).\n"
           "; Writes TG register 0x04 (latch voice+0x0100) from XBC+0x08 and register 0x05\n"
           "; (latch voice+0x0140) from XBC+0x0A.  Both call sites (0x028FC6, 0x028FDA) invoke it\n"
           "; immediately after TVF_Emit_Registers (0x024444) / _DispatchB (0x024554), which is\n"
           "; what identifies registers 4/5 as the stereo pan pair.\n",
        "; ToneGen_WriteVoice_TvfPair: Writes voice WA's TVF (filter) register pair: TG 0x100 + voice <- (XBC + 8) and\n"
        ";   0x140 + voice <- (XBC + 10), each latch / data write with P6.7 low / high and a three-`nop` settling gap.\n"
        ";   Basis: callers + body -- TVF_Refresh_Sounding_Voices calls it with XBC = the staging record 0x0451CC right\n"
        ";   after TVF_Emit_Registers / Voice_PanReg_WriteDispatchB put the clamped cutoff word and the second filter\n"
        ";   word at staging +8 / +10; 0x100 / 0x140 is the filter pair (tone-generator.md).  Was\n"
        ";   ToneGen_WriteVoice_Pan_Pair: those registers are not the pan.\n", tag="TvfPair header")
    rep(M, "; 4 and 5 via ToneGen_WriteVoice_TvfPair with XBC = the staging record 0x0451CC.\n",
        "; 0x100/0x140 + voice (the filter pair) via ToneGen_WriteVoice_TvfPair with XBC = the staging record 0x0451CC.\n",
        tag="TVF_Refresh old comment")
    rep(M, " (The twin's 'Pan' name is contradicted by the same evidence.)", "", tag="TvfRegs_Dup header")
    rep(M, "; Entry: XWA = destination address (in main CPU memory)\n"
           ";        XDE = source address (in sub CPU memory)\n",
        "; Entry: XWA = source address in sub CPU memory (kept at (0x1110): the phase-2 DMA source)\n"
        ";        XDE = destination address in main CPU memory (stored at (0x10DE) with BC: the\n"
        ";              6-byte header phase 1 sends, DMA channel 2 source register 0x08 = 0x10DE)\n", tag="E1 header")
    rep(M, "; A stray one-byte `ret` immediately after DSP_System_Init's tail-jump.  No caller and no\n"
           "; table reference anywhere in the authoritative source -- alignment padding or dead code.\n", "",
        tag="NullStub stale comment")
    for q, eng in (("1K", "FIFO_Engine1K_Put"), ("256", "FIFO_Engine256_Put"), ("512", "FIFO_Engine512_Put")):
        b = open(os.path.join(REPO, "v142", "subcpu", M), "rb").read()
        rx = re.compile((r"(^FIFO%s_PutBytes:\n(?:\t[^\n]*\n)*?)\tld\ta, \(xiy\)\n\tcalr\t%s\n\tinc\t1, xiy\n\tdjnz16\tbc, -10\n"
                         % (q, eng)).encode(), re.M)
        b2, n = rx.subn(lambda m: m.group(1) + ("FIFO%s_PutBytes_Loop:\n\tld\ta, (xiy)\n\tcalr\t%s\n\tinc\t1, xiy\n"
                                                "\tdjnz16\tbc, FIFO%s_PutBytes_Loop\n" % (q, eng, q)).encode(), b)
        REPORT.append("v142  FIFO%s_PutBytes loop label                %s" % (q, "ok" if n == 1 else "found %d: SKIPPED" % n))
        if n == 1:
            open(os.path.join(REPO, "v142", "subcpu", M), "wb").write(b2)
    D = "subcpu_data_tables.s"
    rep(D, "; --- 0x0121bd  15 x u16 dispatch offsets for sub-commands 0x17-0x25 of command 0x2C.\n"
           "; CmdHandler2C_JumpDispatch computes `jp (CmdHandler2C_TableData + offs[subcmd - 0x17])`.\n",
        "; --- 15 x u16 dispatch offsets for the global sub-commands of command 0x2C: entries 0-8 are\n"
        "; sub-commands 0x00-0x08 (index = sub-command), entries 9-14 are 0x20-0x25 (index = sub-command\n"
        "; - 0x17); 0x09-0x1F are rejected before the table.  CmdHandler2C_JumpDispatch computes\n"
        "; `jp (CmdHandler2C_TableData + offs[index])`.\n", tag="2C table header")
    p = os.path.join(REPO, "v142", "subcpu", D)
    b = open(p, "rb").read()
    i = b.find(b"CmdHandler2C_DispatchOffsets:\n")
    j = b.find(b"\n\n", i)
    blk = b[i:j]
    for k in range(9):
        blk = blk.replace(b"; sub-cmd 0x%02x\n" % (0x17 + k), b"; sub-cmd 0x%02x\n" % k, 1)
    open(p, "wb").write(b[:i] + blk + b[j:])
    REPORT.append("v142  2C entries 0-8 relabelled                  ok")


def main():
    if "--pre" in sys.argv:
        pre()
    elif "--post" in sys.argv:
        dedupe()
        post()
    elif "--v142" in sys.argv:
        v142()
    elif "--dedupe" in sys.argv:
        dedupe()
    else:
        sys.exit(__doc__)
    print("\n".join(REPORT))


if __name__ == "__main__":
    main()
