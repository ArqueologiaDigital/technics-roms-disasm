# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""data_struct_names.py -- names for the record kinds and fields tools/data_structs.py finds.

Keyed by the array's label (the same in every program build: the labels port)
and its stride.  Each entry: (kind name, {field offset: field name}), with the
evidence for each name in the comment above it.  A field not named here keeps
its offset name (f<off>, p<off>, s<off>, x<off>).
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



def lookup(label, stride):
    return lookup3(label, stride)[:2]


def options(label):
    """Layout options of a pointed-record kind (OPTIONS below)."""
    return OPTIONS.get(label, {})


def lookup3(label, stride):
    """(kind name, {offset: field name}, new label or None) for the array `label`."""
    e = NAMES.get((label, stride)) or NAMES.get(label)
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

