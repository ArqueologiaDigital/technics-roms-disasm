# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""data_struct_names.py -- names for the record kinds and fields tools/data_structs.py finds.

Keyed by the array's label (the same in every program build: the labels port)
and its stride.  Each entry: (kind name, {field offset: field name}), with the
evidence for each name in the comment above it.  A field not named here is named
by auto_name() from what the code does with it (lane mn10300-formats, 2026-10-31), or keeps its
offset name (f<off>, p<off>, s<off>, x<off>).
"""

NAMES = {
    # StyleRecordTable: the built-in Music Stylist setups, 270 styles x 4 (func_4847F638 0x4847F638
    # ends the built-ins at 1080 = 0x438).  Fields cross-checked over all records against the lists
    # they index (lane notes, data-rest/README.md).
    "StyleRecordTable": ("MusicStylistSetup", {
        0: "panel",       # -> its MusicStylistPanelData; func_4847F504 / func_4847F638 hand it to func_4C02AC68 / func_4C02AC28
        4: "name",        # 16 characters: MssNameFunc 0x4847AFDD, func_4847B14B, func_4847B18C strncpy / memcpy 16
        8: "genre",       # StyleGenreTable + genre * 8: func_4847BA42, func_4847C471, AcCtgOrgTitleMenuProc
        10: "style",      # that genre's style list + style * 8: func_4847BC39, func_4847C4F0
        12: "setup",      # 0..3, the record's place in its style's list: func_4847C4F0 steps it
        14: "era",        # matched against the era table's +8 (func_4847D644); 0xFFFF: under no era
        16: "era_pos",    # place in that era's list: func_4847D644 shows page pos / 9 + 1, row pos % 9 + 1
        18: "letter",     # func_4847C9A7_Records (the alphabet index) + letter * 8: func_4847C9A7, func_4847D187
        20: "letter_pos", # place in that letter's list: func_4847D083, func_4847D160 page it by 9
    }),
    # what MusicStylistSetup.panel points at: func_4C02AD3C merges it through mask tables into the
    # parameter RAM at 0x84000000; func_4847B17D reads the tempo, b[0x76] << 8 | b[0x75]
    "StyleRecordTable_p0": ("MusicStylistPanelData", {117: "tempo_lo", 118: "tempo_hi"}),
    # 11 genres and a null entry: func_4847B61D joins +0's names with '|'; +4 the genre's style list
    "StyleGenreTable": ("StyleGenre", {0: "name", 4: "styles"}),
    # the era list (func_4847D644 0x4847D644 walks it, stride 12, comparing +8 with the setup's era;
    # func_4847D639 reads the first era's +4): 9 eras, "Pre1920" .. "1990s>"
    "func_4847D644_Records": ("StyleEra", {0: "name", 4: "setups", 8: "era"}, "StyleEraTable"),
    # the alphabet index (func_4847C9A7 memcpys 1 byte of +0, func_4847C977 counts +4's 0xFFFF-ended list)
    "func_4847C9A7_Records": ("StyleLetter", {0: "letter", 4: "setups"}, "StyleAlphabetTable"),
    "StyleGenreTable_p4": ("GenreStyle", {0: "name", 4: "setups"}),
    # (lane callee-walk) what callers hand cre_tsk in a0 (the kernel's micro-ITRON cre_tsk 0x4C03D0C8;
    # kn7000.sym: a0 = &T_CTSK {exinf, tskatr, task, itskpri (16-bit) at +0x0C, stksz at +0x10});
    # the reads are func_4C03D154's, which cre_tsk hands it to: +0 u32, +8 the entry, +0xC u16, +0x10 u32
    "cre_tsk_ArgA0": ("T_CTSK", {0: "exinf", 4: "tskatr", 8: "task", 12: "itskpri", 16: "stksz"}),

    "TtMessage_Table": ("MessageBoxDef", {
        0: "kind",        # IvMessageProc 0x48489ED7 indexes IvMessageProc_Table[kind]; TtMessage maps 1/2/3 to title types
        4: "error_no",    # MessageHeader 0x4848A3E1 prints "%s %02d!" with it for kind 3; 0xFFFF none
        8: "header",      # per-language string pointers: MessageHeader `mov (8, a0), a0`
        12: "text",       # per-language string pointers: MessageText 0x4848A368 on MT_GetLanguagePtr
    }),
    "TtNormal_Table": ("HomePagePart", {
        0: "view",        # TtNormal 0x48493ACE / IvCustomizeHpProc pass it to GetViewInstance / SubView; -1 ends
        4: "part_no",     # equals the index; nothing reads it
        8: "name",        # AcHpPartsListProc 0x48496238 strcpys it into the list
    }),
    "func_48436229_Records": ("NoteConvRule", {
        0: "is_melody",   # func_48436229: non-zero selects the 1-D melody table (loc_4843639E)
        1: "alt_chord",   # [INFERENCE] func_484361D8 returns it (the caller at 0x4843CF52 then takes func_4844DDC6's chord)
        2: "no_third_adj",# [INFERENCE] func_484361F3
        3: "no_transpose",# [INFERENCE] func_4843620E
        4: "table",       # the rule's MelodyConvTable / ChordConvTable, 0: thru
    }, "NoteConvRules"),
    # what NoteConvRule.table points at: {name; s8 delta[41][12]} (0x1F0 bytes) or
    # {name; s8 delta[41][12][12]} (0x1714 bytes), indexed (type - 1) * 12 + note % 12 or
    # (type - 1) * 0x90 + (root - 1) * 12 + note % 12 (func_48436229 loc_4843639E / loc_484363E3)
    "NoteConvRules_p4": ("NoteConvTable", {0: "name"}),
    # func_4C01BB1A walks it by the nibbles of a 24-bit resource id from bit 20: +0 a child array or
    # a leaf record, +4 non-zero for an inner node, +5 the child count (the nibble must be below it)
    "ResourceIdTrie": ("ResourceTrieNode", {0: "node", 4: "inner", 5: "children"}),
    # GetEditSwPointInit 0x48417B30: entry id & 0x1F (bit 7 selects the bank at +128); screen pixels
    "GetEditSwPointInit_Table": ("EditSwPoint", {0: "x", 2: "y"}),
    "func_4844D0F8_Table": ("ChordRecogEntry", {0: "chord_type", 1: "root_flags"}, "ChordRecogTable"),
    "func_4844D297_Table": ("ChordRecogEntry2", {0: "chord_type", 1: "root_flags"}, "ChordRecogTable2"),
    # (lane mn10300-data2) the same two kinds under the labels they now have: the generator looks a kind up by
    # the array's current label, which is ChordRecogTable / ChordRecogTable2 since the rename above
    "ChordRecogTable": ("ChordRecogEntry", {0: "chord_type", 1: "root_flags"}),
    "ChordRecogTable2": ("ChordRecogEntry2", {0: "chord_type", 1: "root_flags"}),
    "TechniChordBlock_Records": ("TechniChordVoicingBlock", {0: "below"}),
    "TechniChordHymn_Records": ("TechniChordVoicingHymn", {0: "below"}),
    "TechniChordTheatre_Records": ("TechniChordVoicingTheatre", {0: "below"}),
    # (lane mn10300-data2, N-2468beef) the flash chips the custom-data flash routines know, 32 bytes each:
    # FlashReadAutoselect 0x4847F980 compares +0 / +2 with the autoselect reads (the JEDEC manufacturer and
    # device codes); FlashProgram128Words 0x4847F9F7 `asl 5` / `add FlashChipIdTable` / `movhu (4, a0), d0`
    # bounds its sector loop with +4 (`cmp d2, d0` / `bgt`) and walks the sector table at +8 (`mov (8, a0)`;
    # FlashSectorErase 0x4847F75A `mov (8, a0), a0` too)
    "FlashChipIdTable": ("FlashChip", {0: "maker_id", 2: "device_id", 4: "nsectors", 8: "sectors"}),
    # DiskLoadDispatch 0x4852CFE4: `asl 3` / `movbu (d0, a2), d0` hands +0 to func_4852FAF0 and func_4852FC0E
    # (does the disk hold files of this kind?) and compares it with 7; then calls +4 (`mov (4, a0), a1` /
    # `calls (a1)`): the loader of that kind of file
    "DiskFileHandlerTable": ("DiskFileHandler", {0: "file_kind", 4: "proc"}),
    # PanelSelfTestScanEntry 0x484A0D07: `movbu (d1, a2), d2` / `cmp 0xf0, d0` ... `cmp 0xf6, d0` picks the
    # test case by +0; the case then uses +1 (`movbu (1, a2), d3`) -- kn7000_manual.sym: switch# -> [LED reg, value]
    "PanelSwitchClassTable": ("PanelTestSwitch", {0: "test_class", 1: "test_arg"}),
    # (lane mn10300-data3, N-2468beef) the C library's locale categories (ANSI C struct lconv): localeconv
    # 0x4C00206A copies the current numeric category's +4 / +8 / +0xC to the static lconv's decimal_point /
    # thousands_sep / grouping (0x50008270 / 74 / 78) and the monetary category's +4 .. +0x1C (pointers) and
    # +0x20 .. +0x27 (bytes) to its int_curr_symbol .. negative_sign (0x5000827C .. 94) and int_frac_digits ..
    # n_sign_posn (0x50008298 .. 9F), the C89 order; +0 the category's locale name, which localeconv skips
    "localeconv_Records": ("LconvMonetary", {
        0: "locale", 4: "int_curr_symbol", 8: "currency_symbol", 12: "mon_decimal_point", 16: "mon_thousands_sep",
        20: "mon_grouping", 24: "positive_sign", 28: "negative_sign", 32: "int_frac_digits", 33: "frac_digits",
        34: "p_cs_precedes", 35: "p_sep_by_space", 36: "n_cs_precedes", 37: "n_sep_by_space", 38: "p_sign_posn",
        39: "n_sign_posn"}),
    "localeconv_Records_2": ("LconvNumeric", {0: "locale", 4: "decimal_point", 8: "thousands_sep", 12: "grouping"}),
    # DrawStringCentered 0x48425896's a1: the point the text is centred on, copied to the text position and
    # moved left by half the text width (`movhu (a0)` / `movhu (2, a0)`, LibDiv32, `sub d0, d2`)
    "DrawStringCentered_ArgA1": ("TextCentre", {0: "x", 2: "y"}),
    # DrawBitmapSP2 0x484248DE / Draw2BpFile 0x4842829F: a0 = the point the bitmap is drawn at, read as x / y by
    # the _Impl routines they hand it on to (DrawIcons, DrawIcons_Impl `movhu (a0)` / `movhu (2, a0)`)
    "DrawBitmapSP2_ArgA0": ("BitmapOrigin", {0: "x", 2: "y"}),
    "Draw2BpFile_ArgA0": ("BmpFileOrigin", {0: "x", 2: "y"}),
    # the voice directory's hash chains: VoiceDir*Find take the bucket from VoiceDir*Find_Table[hash], compare
    # the key at +4 (`mov (4, a2), d1` / `movhu (4, a2), d1`, then the KeyEqual routine) and follow +0 (`mov
    # (a2), a2`) to the next node; VoiceDirPartRefFind answers the node + 8 (`mov 8, a0` / `add a2, a0`)
    "VoiceDirPartRefFind_Table_p0": ("VoiceDirPartRefNode", {0: "next", 4: "key", 8: "value"}),
    "VoiceDirRemapFind_Table_p0": ("VoiceDirRemapNode", {0: "next", 4: "key"}),
    "VoiceDirRefFind_Table_p0": ("VoiceDirRefNode", {0: "next", 4: "key"}),
    "VoiceDirIndexFind_Table_p0": ("VoiceDirIndexNode", {0: "next", 4: "key"}),
    "VoiceDirClassFind_Table_p0": ("VoiceDirClassNode", {0: "next", 4: "key"}),
    # GetGenreName 0x48435A9F memcpys 16 bytes of the genre's record (then a NUL at +0x10); GetGenreStyleCount
    # 0x48435AD9 answers +0x11; func_48435AFF bounds the style index by +0x11 and reads the style's word from
    # +0x14's list (`mov (0x14, a0), a0` / `asl2` / `mov (d0, a0), d0`)
    "GenreStyleTable": ("GenreStyleEntry", {0: "name", 17: "style_count", 20: "styles"}),
    # GetEditSwPointInit 0x48417B30's second bank (entry id bit 7 set: `lsr 7` / `and 1`), the same {x, y} as
    # GetEditSwPointInit_Table's: its label in the builds since the table split
    "GetEditSwPointInit_Records": ("EditSwPoint", {0: "x", 2: "y"}),
    "GetEditSwPointInit_Table_2": ("EditSwPoint", {0: "x", 2: "y"}),
    # (lane mn10300-data4, N-2468beef) the tone-type feature records (kn7000_manual.sym "LFO EDIT group loaders"):
    # one per tone type (the tone descriptor's +0x44 & 0xF), 39 bytes = a 19-byte head and four 5-byte EG segment
    # entries from +0x13.  The head's four LFO triples at +0 / +3 / +6 / +9 (t<k>_a, _b, _c, the fourth with a _d)
    # are what TgPartEditLfoLoadA..H project onto the part's 8-byte LFO block (SOUND EDIT record +0x45): A
    # (groups 0..3) := t0_a, t0_b, seg1_c, seg1_e, seg1_param, -, lfo_p6, lfo_p7; B := t0_a, t0_b, t1_a, t1_b,
    # seg1_c, seg1_e, lfo_p6, lfo_p7; C := t2_a, t2_b, t2_c, seg1_param; D := t0_a, t0_b, t1_a, t1_b; E := seg1_e,
    # seg1_c, seg1_b, seg1_param; F := t3_a .. t3_d; G / H := seg0_flags bit 7, t0_flags & 0x3F, t0_a; every loader
    # puts lfo_p6 / lfo_p7 (+0x0E / +0x12) at block +6 / +7.  The segments: TgVoiceEgSegParamGet / TgVoiceEgSegFlagTest
    # test the flag byte +0x13 + seg * 5 (seg<k>_flags) against a mask table, TgPartToneTypeParamGet answers byte
    # +0x16 + sel * 5 (seg<k>_param), TgPartEgRampBuild reads +0x14 / +0x15 (seg0_b, seg0_c).  +5 (note_flags) is
    # read by TgKitElemNoteOn / TgElemNoteOnFresh at note-on [INFERENCE: what each LFO value is (speed, depth,
    # delay) is not traced]
    "TgPartEditLfoLoadA_Records": ("ToneTypeFeature", {
        0: "t0_a", 1: "t0_b", 2: "t0_flags", 3: "t1_a", 4: "t1_b", 5: "note_flags", 6: "t2_a", 7: "t2_b", 8: "t2_c",
        9: "t3_a", 10: "t3_b", 11: "t3_c", 12: "t3_d", 14: "lfo_p6", 18: "lfo_p7", 19: "seg0_flags", 20: "seg0_b",
        21: "seg0_c", 22: "seg0_param", 24: "seg1_flags", 25: "seg1_b", 26: "seg1_c", 27: "seg1_param", 28: "seg1_e"}),
}
# (lane mn10300-data3, N-2468beef) kinds whose array labels differ by build or model (the reader routines are
# address-named): (label pattern, (kind, fields)), looked up after the exact keys.
import re as _re
NAMES_RE = [
    # the one-touch / panel-memory field maps: {offset in the live panel parameters, offset in the record,
    # mask}.  941 func_4C02A0C4 (KN6000 func_4C04B9F8) stores live[+0] & +2 into record[+1] (`movbu (a1)` /
    # `movbu (1, a1)` / `movbu (2, a1)` / `and d0, d1` / `movbu d1, (d2, a0)`, `add 3, a1`); the merger
    # (941 func_4C02AD3C, KN2400 func_50157736) the other way, live[+0] = live[+0] & ~mask | record[+1] & mask
    (_re.compile(r"func_4C02A0C4_(Records|Table)(_\d+)?|func_4C02A11E_(Records|Table)(_\d+)?|func_4C02A0B1_(Records|Table)(_\d+)?"
                 r"|func_4C02AD(3C|96|29)_Table(_\d+)?|func_4C04B9F8_entry_L[0-9a-f]+_Table(_\d+)?"
                 r"|func_4C04BB68_entry_L[0-9a-f]+_Table(_\d+)?|func_4C04C58C_entry_L[0-9a-f]+_Table(_\d+)?"
                 r"|func_4C04C6FC_entry_L[0-9a-f]+_Table(_\d+)?|func_50157736_Table(_\d+)?"),
     (3, ("PanelMemFieldMap", {0: "param_off", 1: "rec_off", 2: "mask"}))),
    # (lane mn10300-data4, N-2468beef) the SX-KN6000 / KN6500 voice register image (0xA0 bytes a slot, the shadow
    # at 0x50043100 + slot * 0xA0): func_4C0948CB 0x4C0948CB (KN6500 func_4C094795) writes it field by field to the
    # MAIN TG, word (slot << 20) | (class << 16) | field through func_4C09465B (KN6500 func_4C094525), the latch
    # to 0x98050000 / 0x98050002.  Each field is named by the class it is written to (tg_<class>, hex); +0x7C is
    # the pitch's 17th bit (`and 0x00018000` / `or 0x58004000`: class 0x5800, the gate-on pitch plane); the
    # writes the routine makes after the gate word (0x87FF, class 0) are in this order.  Probe:
    # kn7000/notes/mn10300-data4-probes/tg_image_regs.py.  What each class does is the TG's register map:
    # kn7000_mame notes/kn6000-tonegen-spec.md pins only the EG [rate|level] pairs at classes 4/5, 8/9, 0xC/0xD
    # and the plane 0x20 send matrix (0x8000 .. 0x9000) [the rest unknown].
    (_re.compile(r"func_4C0948CB_ArgA0|func_4C094795_ArgA0"), (0xA0, ("TgVoiceRegImage", {2: "tg_0001", 4: "tg_0002", 6: "tg_0003", 8: "tg_0004", 12: "tg_0005", 16: "tg_0006", 18: "tg_0007", 20: "tg_0008", 24: "tg_0009", 28: "tg_000a", 30: "tg_000b", 32: "tg_000c", 36: "tg_000d", 40: "tg_000e", 42: "tg_000f", 44: "tg_0400", 46: "tg_0401", 48: "tg_0800", 50: "tg_0804", 52: "tg_0808", 54: "tg_080c", 56: "tg_0801", 58: "tg_0805", 60: "tg_0809", 62: "tg_080d", 64: "tg_1000", 68: "tg_1400", 72: "tg_1800", 76: "tg_1c00", 80: "tg_2000", 84: "tg_2400", 88: "tg_2800", 92: "tg_2c00", 96: "tg_3000", 100: "tg_4000", 104: "tg_4400", 108: "tg_4800", 112: "tg_4c00", 120: "tg_5400", 124: "pitch_hi", 128: "tg_5c00", 132: "tg_6000", 136: "tg_6400", 140: "tg_8000", 144: "tg_8400", 148: "tg_8800", 152: "tg_8c00", 156: "tg_9000"}))),
    # (lane mn10300-data4, N-2468beef) the SX-KN6000 / KN6500 RAM test's regions: RamTestFunc (test mode) calls
    # func_4C0506C7 (KN6500 func_4C050837), which writes 0x5A5A5A5A / 0xA5A5A5A5 over each word pair from +0 (`mov
    # (a0), a2`) for +4 >> 3 passes (`mov (4, a0), d3` / `lsr 3, d3`) and ORs +8 (a halfword failed low) or +9
    # (high) into its answer; only record 0 is tested (`cmp 1, d0` ends the loop)
    (_re.compile(r"func_4C0506C7_entry_L4_Records|func_4C050837_entry_L4_Records"), (12, ("RamTestRegion", {0: "base", 4: "length"}))),
    # its byte twin, func_4C050787 (KN6500 func_4C0508F7): 0x5A / 0xA5 over each byte from +0 for +4 >> 1 byte
    # pairs, +8 ORed into the answer on a failure (RamTestFunc shifts it 2 left over the word test's bits)
    (_re.compile(r"func_4C050787_entry_L4_Records|func_4C0508F7_entry_L4_Records"), (12, ("RamTestByteRegion", {0: "base", 4: "length", 8: "fail_bit"}))),
    # the EQ edit boxes' value labels: EQQEditCheck 0x4856B28E / EQGainEditCheck / EQFcEditCheck strcpy the
    # entry the value picks into the box's text (`call strcpy_entry`)
    (_re.compile(r"EQ\w*EditCheck(_L[0-9a-f]+)?_Records(_\d+)?"), (None, ("EqEditLabel", {0: "label"}))),
]


# The sibling firmwares (gen_data_s.py profiles kn6000, kn6500, kn2400): the same kinds of record,
# under the names their manual symbol files give the arrays (<model>_manual.sym, data section), with
# each field's evidence from that firmware's own code.  Looked up before NAMES.
_KN6000_STYLES = {
    # StyleRecordTable (0x4C3DF8EC, 1000 x 24 bytes): the built-in Music Stylist setups, the KN7000's
    # MusicStylistSetup field for field (the readers below are KN6000 v7.1's)
    "StyleRecordTable": ("MusicStylistSetup", {
        0: "panel",       # -> its 144-byte one-touch record: func_4C16B6B5 0x4C16B6FD loads it and calls
                          # func_4C04C476, which hands it to func_4C04C58C (merges it into 0x84000036..
                          # through the triple tables) -- func_4C04C552 answers its size, 0x90
        4: "name",        # 16 characters: MssNameFunc_L121 0x4C1637F8, func_4C163899 strncpy / memcpy 16
        8: "genre",       # StyleGenreTable + genre * 8: func_4C1640C8 0x4C1640C8 `movhu (8, a1), d0`
        10: "style",      # that genre's style list + style * 8: func_4C1640C8 `movhu (0xa, a0), d1`
        12: "setup",      # 0..3, the record's place in its style's list: func_4C1649B6, func_4C164AAC
        14: "era",        # 0xFFFF: under no era (func_4C165A19 0x4C165A19 `cmp 0xffff, d1`)
        16: "era_pos",    # func_4C16619A 0x4C1661EA divides it by 9 (LibDiv32): page and row
        18: "letter",     # StyleAlphabetTable + letter * 8: func_4C164F3F 0x4C164F3F `movhu (0x12, a0), d2`
        20: "letter_pos", # func_4C164F3F `movhu (0x14, a1), d3`, func_4C1655C7
    }),
    # 10 genres and a null entry: func_4C1640C8 0x4C164109 `mov (4, a0), a3` takes +4's style list
    "StyleGenreTable": ("StyleGenre", {0: "name", 4: "styles"}),
    # func_4C165A19 0x4C165AA1 walks it (stride 12, +8 compared with the setup's era): 10 eras
    "StyleEraTable": ("StyleEra", {0: "name", 4: "setups", 8: "era"}),
    # func_4C164F3F memcpys 1 byte of +0; func_4C165012 counts +4's list to its 0
    "StyleAlphabetTable": ("StyleLetter", {0: "letter", 4: "setups"}),
    # func_4C05805C 0x4C05805C, the KN7000's func_48436229 instruction for instruction: +0 non-zero
    # selects the 1-D melody table (loc 0x4C05818F), +1 / +2 / +3 are answered by func_4C05800B /
    # func_4C058026 / func_4C058041 as on the KN7000 (func_484361D8 / F3 / 620E), +4 the table
    "NoteConvRules": ("NoteConvRule", {
        0: "is_melody", 1: "alt_chord", 2: "no_third_adj", 3: "no_transpose", 4: "table"}),
    "NoteConvRules_p4": ("NoteConvTable", {0: "name"}),
}
# (the KN6500 v1.3 runs the same Music Stylist code 0x4C0..: StyleRecordTable 1080 records, read by
# func_4C164..; the kinds and fields are the KN6000's -- lane notes, kn6000/notes/siblings-data-final/)
MODEL_NAMES = {"kn6000": _KN6000_STYLES, "kn6500": _KN6000_STYLES}
# The KN2400 v1.1: the same 24-byte setup, in two sets of lists, one for the KN2600 / PR54 and one
# for the KN2400 (lane mn10300-formats: MssSetupGet 0x48641CCD, MssGenreGet 0x48641D2F, MssLetterGet
# 0x48641D5E and MssEraGet 0x48641D8D pick the KN2400's when KnprModelGet 0x487055C4, the board
# strap 0x98070000, answers 1; kn2400_manual.sym).
# Readers: +0 func_4863EA37, +4 MssNameFunc_Lcb 0x4863E96A, +8 AcCategoryListBoxProc_L59, +10
# func_4863F175, +12 func_4863F565, +14 func_4864001D, +16 func_4864001D_entry_L33, +18 / +20
# func_4863F880 (data_readers, through MssSetupGet's return value)
_KN2400_SETUP = ("MusicStylistSetup", {0: "panel", 4: "name", 8: "genre", 10: "style", 12: "setup", 14: "era",
                                       16: "era_pos", 18: "letter", 20: "letter_pos"})
# the genre list (MssGenreGet's records): +0 the genre's name, read by func_4863ED40_entry_L6 0x4863ED4C
# and func_4863EF80 (`mov (a0), d1`, passed on as the string); +4 its setup list, read by
# func_4863EFAC_entry_Lf 0x4863EFBE and func_4863F175 (`mov (4, a0), a3`, indexed by the style)
_KN2400_GENRE = ("StyleGenre", {0: "name", 4: "styles"})
# the alphabet index (MssLetterGet's records): +0 the letter's string, read by func_4863F880 and
# func_4863F92F_entry_L1 0x4863F935; +4 the list of its setups, read by func_4863F880 / func_4863F985
_KN2400_LETTER = ("StyleLetter", {0: "letter", 4: "setups"})
# the era list (MssEraGet's records): +0 the era's name (func_4864001D_entry_L33 0x48640055), +4 its
# setups (func_4864000C, func_4864001D_entry_L4f), +8 the era number func_4864001D compares with
# MusicStylistSetup.era (`movhu (8, a0), d0` at L4f 0x48640071)
_KN2400_ERA = ("StyleEra", {0: "name", 4: "setups", 8: "era"})
MODEL_NAMES["kn2400"] = {"StyleRecordTable": _KN2400_SETUP, "StyleRecordTableKN2400": _KN2400_SETUP,
                         "StyleGenreTable": _KN2400_GENRE, "StyleGenreTableKN2400": _KN2400_GENRE,
                         "StyleAlphabetTable": _KN2400_LETTER, "StyleAlphabetTableKN2400": _KN2400_LETTER,
                         "StyleEraTable": _KN2400_ERA, "StyleEraTableKN2400": _KN2400_ERA,
                         # func_50173F49 (code linked for RAM 0x50120000), the KN7000's func_48436229: +4 loaded at
                         # func_50173F49_entry_L13 0x50173F61, read `movbu (d0, a0)` at L170 / L1b5; +1 / +2 / +3
                         # answered by func_50173EF8 / func_50173F13 / func_50173F2E
                         "NoteConvRules": _KN6000_STYLES["NoteConvRules"],
                         "NoteConvRules_p4": _KN6000_STYLES["NoteConvRules_p4"]}

# Pointer fields whose targets are records although the reader walk does not follow the pointer
# (it is kept in a register across labels): (array label, field offset) -> the instruction that
# reads through it, and the read: (function, cpu, instruction, target offset, width, signed).
# gen_data_s.ptr_records() takes each as a computed-offset read of the target at that offset.
_KN6000_POINTED = {
    # func_4C05805C 0x4C058074 `mov (4, a0), d2`, then at loc 0x4C05818F / 0x4C0581B5 d2 + 4 +
    # (type - 1) * 12 (or * 0x90 + (root - 1) * 12) + note % 12, `movbu (d0, a0)` and `extb`
    ("NoteConvRules", 4): ("func_4C05805C_entry_L13", 0x4C058074, "mov (4, a0), d2 ... movbu (d1, a0), d0", 4, 1, True),
}
# the KN6500 v1.3: the same routine at func_4C058353 (its label L13 at 0x4C05836B)
_KN6500_POINTED = {
    ("NoteConvRules", 4): ("func_4C058353_entry_L13", 0x4C05836B, "mov (4, a0), d2 ... movbu (d1, a0), d0", 4, 1, True),
}
MODEL_POINTED = {"kn6000": _KN6000_POINTED, "kn6500": _KN6500_POINTED}

# (lane mn10300-data4) kinds whose curated names apply only to fields a reader of the build reads (data_structs
# name_fields): ToneTypeFeature's names come from the KN7000's loaders, and a sibling's bytes no reader touches
# that cover one of those offsets (KN6000 +5, +20..+24) keep their offset name
READ_FIELDS_ONLY = {"ToneTypeFeature"}

MODEL = None    # gen_data_s.configure() sets the profile


def lookup(label, stride):
    return lookup3(label, stride)[:2]


def options(label):
    """Layout options of a pointed-record kind (OPTIONS below)."""
    return OPTIONS.get(label, {})


def pointed():
    """{(array label, field offset): (function, cpu, instruction)} for the current profile."""
    return MODEL_POINTED.get(MODEL, {})


def lookup3(label, stride):
    """(kind name, {offset: field name}, new label or None) for the array `label`."""
    mn = MODEL_NAMES.get(MODEL, {})
    e = mn.get((label, stride)) or mn.get(label) or NAMES.get((label, stride)) or NAMES.get(label)
    if e is None:
        e = next((k for rx, (st, k) in NAMES_RE if rx.fullmatch(label or "") and st in (None, stride)), None)
    if e is None:
        return None, {}, None
    return (e + (None,))[:3]


# Pointed-record kinds whose records are not one size: `tail` = (element width, signed, offset):
# each record is its fields up to `offset`, then elements of that width up to the next label or
# to what its own pointer fields point at (its name string, stored right after it).
OPTIONS = {
    # NoteConvTable: +0 name, then s8 delta[41][12] (0x1F0 bytes, the melody rules) or
    # [41][12][12] (0x1714 bytes, the chord rules); func_48436229 indexes them from +4
    "NoteConvRules_p4": {"tail": (1, True, 4)},
    # (lane mn10300-data2) the record count a reader's index cannot exceed, when the bound is in a callee the
    # index rule does not follow: func_4844D297 indexes ChordRecogTable2 by func_4844D680's answer, the chord's
    # interval mask, which that routine builds by or-ing one of the bits 0x01 .. 0x400 per note (its jump table
    # func_4844D680_Table, cases 0..10) or answers 0xFFFF (refused before the index): 0 .. 2047.  The table
    # ends exactly where the next one (func_484375EA_Table) starts, 4,096 bytes on, as ChordRecogTable's 2,048
    # records do.
    "ChordRecogTable2": {"count": (2048, "the index is func_4844D680's 11-bit interval mask (bits 0x01 .. 0x400)")},
}
# (lane mn10300-data3) the same table in the other builds and the siblings, under their labels: the reader is
# func_4844D297's code instruction for instruction (942 func_4844D286, 935 / 893 func_4844D255, KN6000
# func_4C09D886, KN6500 func_4C09D607, KN2400 func_4860E29C), its index the answer of the twin of
# func_4844D680 (KN6000 func_4C09DC6F: the same jump table of bits 0x01 .. 0x400); each table ends 4,096 bytes
# on, where the next item starts (942 func_484375D9_Table, KN6000 / KN6500 User02_ApFunctions, KN2400
# func_501752A3_Table)
for _l in ("func_4844D286_Table", "func_4844D255_Table", "func_4C09D886_entry_L6e_Table",
           "func_4C09D607_entry_L6e_Table", "func_4860E29C_Table"):
    OPTIONS[_l] = OPTIONS["ChordRecogTable2"]
    NAMES[_l] = ("ChordRecogEntry2", {0: "chord_type", 1: "root_flags"})
# and the first table (941 ChordRecogTable, read by func_4844D0F8 the same way)
for _l in ("func_4844D0E7_Table", "func_4844D0B6_Table", "func_4C09D6E7_entry_L4b_Table",
           "func_4C09D468_entry_L4b_Table", "func_4860E0FD_Table"):
    NAMES[_l] = ("ChordRecogEntry", {0: "chord_type", 1: "root_flags"})



# -- names from the field's use (lane mn10300-formats, 2026-10-31) -----------------------------------
# A field the curated tables above do not name gets the name of what the code does with it, when
# that is clear (tools/data_field_uses.py has the rules and the evidence each name stands for):
#   proc        called through (`calls (aN)` / `jmp (aN)`), or a pointer every record points into code
#   text        a pointer every record points at a NUL-terminated string
#   key         compared with a value the reading routine was given, then beq / bne (a lookup key);
#               also before a backward beq / bne (a search loop: go on until the key matches)
#   count       compared with a register before a backward ordered branch (blt, bcs ...: a loop bound)
#   index       scaled (asl / mulu) or used as an index register: an index into a table
#   flags       bits tested or masked with constants
#   kind        compared with several constants (a switch on it)
#   <param>     handed to a routine whose parameter is known (data_field_uses.PARAMS: view, title,
#               event, object, icon, size, flag, param_key ...)
#   <F>_<reg>   handed to the named routine F in register reg (its own code says no more)
#   <prefix>    compared with a symbolic constant: event (EV_*), message (MT_*), title (TT_*) ...
#   x / y       compared only with the LCD's width (640, 639) / height (240, 239): a column / row
#   addr        a number field (not every value a data address) the code uses as a pointer
# Lane mn10300-rest (2026-10-31) made the use walk follow the reading instruction's own place
# (tools/data_readers.py Access.pos), a value parked in the frame to its reloads, and an
# unconditional branch to its target; where the places of a field's readers still disagree, the uses
# of all of them name it together by the precedence above (data_field_uses.name_for_all).
AUTO_NAMES = True
_CI = {}


def _G():
    """The configured gen_data_s module (it usually runs as __main__)."""
    import sys
    m = sys.modules.get("__main__")
    if hasattr(m, "code_glob") and hasattr(m, "P"):
        return m
    import gen_data_s
    return gen_data_s


def _code_index(gen):
    G = _G()
    import data_field_uses as DFU
    k = G.code_glob()
    if k not in _CI:
        _CI[k] = DFU.CodeIndex(k)
    return _CI[k]


def auto_name(g, f):
    """A name for field f of record kind g from what the code does with it, or None."""
    gen = getattr(g, "gen", None)
    if not AUTO_NAMES or gen is None or f.kind in ("bytes", "text"):
        return None
    import data_field_uses as DFU
    if f.kind == "ptr":
        offs = getattr(g, "rec_offs", None) or []
        vals = [int.from_bytes(gen.rom[o + f.off:o + f.off + 4], "little") for o in offs]
        vals = [v for v in vals if v]
        if vals:
            if not hasattr(gen, "_code_addrs"):
                gen._code_addrs = set(gen.code_labels.values())
            # (code_labels holds every label file's names, data ones too: a code target is outside the data)
            if all((gen.in_code(v) or v in gen._code_addrs) and not gen.in_data(v) for v in vals):
                return "proc"
            if all(gen.in_data(v) and _is_str(gen, v) for v in vals):
                return "text"
    ci = _code_index(gen)
    near = tuple(x for x in {getattr(g, "label", None)} if x)
    occ = []
    for a in f.accs:
        if a.width and a.rw == "ld" and a.func and a.insn:
            occ += ci.uses(a.func, a.insn, near=near, pos=getattr(a, "pos", None))
    return DFU.name_for_all(occ, f.kind)


def _is_str(gen, v):
    o = v - gen_base(gen)
    rom = gen.rom
    if not (0 <= o < len(rom)):
        return False
    e = rom.find(b"\0", o, o + 256)
    if e <= o:
        return False
    bs = rom[o:e]
    return sum(1 for c in bs if 0x20 <= c < 0x7F) >= max(1, int(len(bs) * 0.8)) and all(c >= 0x09 for c in bs)


def gen_base(gen):
    return _G().BASE
