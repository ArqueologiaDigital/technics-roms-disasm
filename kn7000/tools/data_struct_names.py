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
    "TechniChordBlock_Records": ("TechniChordVoicingBlock", {0: "below"}),
    "TechniChordHymn_Records": ("TechniChordVoicingHymn", {0: "below"}),
    "TechniChordTheatre_Records": ("TechniChordVoicingTheatre", {0: "below"}),
}


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
        return None, {}, None
    return (e + (None,))[:3]


# Pointed-record kinds whose records are not one size: `tail` = (element width, signed, offset):
# each record is its fields up to `offset`, then elements of that width up to the next label or
# to what its own pointer fields point at (its name string, stored right after it).
OPTIONS = {
    # NoteConvTable: +0 name, then s8 delta[41][12] (0x1F0 bytes, the melody rules) or
    # [41][12][12] (0x1714 bytes, the chord rules); func_48436229 indexes them from +4
    "NoteConvRules_p4": {"tail": (1, True, 4)},
}



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
