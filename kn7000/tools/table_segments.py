# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# What each of the 84 segments of the KN7000 table flash is: its label, the file a JPEG
# segment is kept in (src/table/), and the header comment tools/gen_table_s.py writes
# above it. Builds 84 (kn7000_table.rom) and 83 (the SP7001 table) share the layout
# segment for segment; BUILD_OVERRIDES holds what differs.
#
# The reader named for a segment is the program-941 code that loads its directory slot
# (notes/table-rom-probes/dir_slot_readers.py lists them all); RAM names come from
# annotations/gfx_draw.ann, kn7000_manual.sym and notes/work-ram-map.md.

# The Feature Demo's pictures. DemoJpgDataXn (recovered MILK name) returns the segment's
# address for message 0x600E6 and 0 for any other; the 4-byte '27' placeholders are
# returned the same way.  (slot, Xn, file stem or None, what the picture shows)
DEMO = [
    (9,  "A1", "welcome",               "'Welcome to SX-KN7000' over a glass hall"),
    (10, "A2", "city_street",           "a crowded city street, 'SX-KN7000' top right"),
    (11, "A3", "logo_globe",            "the KN7000 logo flying past the Earth"),
    (12, "A4", "logo_light_rays",       "the KN7000 logo in pink light rays"),
    (13, "A5", "logo_lions",            "'KN7000' over a pride of lions"),
    (14, "A6", "logo_mountains",        "the KN7000 logo over pink mountains"),
    (73, "A7", "future_keyboard",       "'Future Keyboard!' and 'KN7000' over a night peak"),
    (15, "B1", "sd_card",               "the SD logo and an SD card held in two fingers"),
    (16, "B2", "laptop",                "a laptop showing a lake"),
    (17, "B3", "sd_audio_player",       "a Panasonic SD audio player and a listener"),
    (18, "B4", "digital_camera",        "a compact digital camera in a hand"),
    (19, "C1", "church_organ",          "a church interior with a pipe organ"),
    (44, "C2", "organ_manuals",         "the keyboards of a drawbar organ"),
    (45, "C3", "organ_tabs",            "organ stop tabs 16' Flu .. 8' Vn"),
    (46, "C4", "organ_tabs_italic",     "the same stop tabs, italic captions"),
    (20, "D1", "organ_title_1",         "the word ORGAN, letters set one way"),
    (21, "D2", "organ_title_2",         "the word ORGAN, letters set another way"),
    (22, "D3", "organ_title_3",         "the word ORGAN, a third letter setting"),
    (23, "D4", "accordion_title_1",     "'Accordion', small red lettering"),
    (60, "D5", "accordion_title_2",     "'Accordion', larger red lettering"),
    (74, "D6", "accordion_title_3",     "'Accordion', red lettering on an arc"),
    (75, "D7", "harmonica_title_1",     "'Harmonica', script lettering"),
    (76, "D8", "harmonica_title_2",     "'Harmonica', script lettering"),
    (77, "D9", "harmonica_title_3",     "'Harmonica', script lettering"),
    (78, "D10", "vocal_title_1",        "'Vocal', small, bottom right"),
    (79, "D11", "vocal_title_2",        "'Vocal', medium"),
    (80, "D12", "vocal_title_3",        "'Vocal', large"),
    (81, "D13", "technics_packages",    "two boxed Technics products"),
    (82, "D14", "sound_excellence",     "'Technics Sound Excellence!' in four languages"),
    (24, "E1", "drum_notes",            "a drum with musical notes rising from it"),
    (25, "E2", "favorites_screen",      "the FAVORITES screen"),
    (26, "E3", "rhythm_screen",         "the RHYTHM screen, style 8 Beat Rock"),
    (27, "F1", "cartoon_band",          "a cartoon four-piece band"),
    (28, "F2", "panel_buttons_sketch",  "a sketch of rows of panel buttons"),
    (29, "F3", "musical_category_screen", "the MUSICAL CATEGORY screen, style Disco Hustling"),
    (30, "F4", "musicians_collage",     "a collage of singers and players"),
    (31, "G1", "song_cue_diagram",      "Intro / Theme A / Theme B / Ending with cue points"),
    (32, "G2", "laptop_software",       "a laptop running PC software"),
    (33, "G3", "camera",                "a digital camera held in a hand"),
    (34, "G4", "player_dream",          "hands on a keyboard and a dreaming face"),
    (35, "H1", "usb_plug",              "a USB plug"),
    (36, "H2", "song_manager",          "the 'Song Manager' PC program window"),
    (61, "H3", "audio_recorder",        "an 'Audio Recorder' Windows XP program window"),
    (62, "H4", "singer_keyboard",       "a singer at a keyboard"),
    (37, "I1", "cartoon_big_band",      "a cartoon big band"),
    (38, "I2", "hand_on_keys",          "a sketch of a hand on the keys"),
    (39, "I3", "smf_lyrics_screen",     "the SMF DIRECT PLAY screen with lyrics, 'When The Saints'"),
    (40, "J2", "display_sketch",        "a sketch of the instrument's display"),
    (41, "J3", "hand_on_panel",         "a hand pressing panel buttons"),
    (42, "J4", "chord_question",        "chord names, a hand on the keys and a question mark"),
    (43, "J5", "help_book",             "a book with a question mark"),
    (47, "K1", "sd_logo",               "the SD logo"),
    (48, "K2", "theatre_organ",         "a theatre-organ console"),
    (49, "K3", "organ_stylist_screen",  "the ORGAN STYLIST screen, style Swing Tonewheels"),
    (50, "K4", "keyboard_notes",        "a keyboard with notes streaming out"),
    (51, "L1", None, None),
    (52, "L2", None, None),
    (53, "L3", None, None),
    (54, "L4", None, None),
    (63, "L5", "laptop_flower_picture", "a laptop showing a flower photo"),
    (64, "L6", "feature_words",         "handwritten Composer, Memory, Sound, PerPads, MSA, Style"),
    (65, "L7", None, None),
    (66, "L8", None, None),
]


# Groups whose items are raw pictures kept as indexed PNGs (tools/table_png.py): per
# segment, the format and, for 2-bpp items, each item's row length in bytes (by the
# number of the first slot that points at it).
#  57: AcUserHpMenuProc draws item d0 with DrawBitmapSPFast4 (2 bpp, colours 0x485FA224)
#      in a box GetBox takes from the item's view (table 0x485F921C, 12-byte rows: view
#      id, item); the box sizes are in the view resources, not traced.  The row lengths
#      below are an INFERENCE: heights a multiple of the 13-pixel text line, the row
#      length whose rows repeat most, checked by eye (all 47 pictures show coherent
#      panels, notes/table-semantics-2026-10-29.md); slot 47 overridden to 40 (at 80 it
#      shows two half-panels side by side).  Any row length gives the same bytes back.
#  58: AcTcdImageProc draws the item with DrawBitmapSP2(width 240, height 80): 1 bpp.
PNG_GROUPS = {
    57: ("p2", {0: 80, 1: 80, 2: 80, 3: 80, 4: 80, 5: 80, 6: 80, 7: 80, 8: 80, 9: 80, 10: 80,
                11: 40, 12: 40, 15: 40, 16: 30, 17: 40, 18: 30, 19: 45, 20: 35, 21: 45, 22: 35,
                23: 45, 24: 35, 25: 45, 26: 35, 27: 15, 28: 10, 29: 20, 30: 15, 31: 10, 32: 15,
                33: 15, 34: 40, 35: 15, 36: 40, 37: 40, 38: 40, 39: 40, 40: 40, 41: 20, 42: 40,
                43: 40, 44: 40, 45: 40, 46: 40, 47: 40, 48: 40}),
    58: ("b1", 240, 80),
}


# Segments that open with a table of u32 offsets from the segment start, one per slot
# (0 = empty slot), to their items. Per segment: the label prefix of an item (+ the
# number of the first slot that points at it), the subdirectory of src/table/ its JPEG
# or BMP items are kept in (None: the items stay .incbin_range), and {slot: what the
# picture shows} for those files.
GROUPS = {
    5: ("OpeningFrame", "opening", {
        0: "notes_over_earth_1", 1: "notes_over_earth_2", 2: "metal_drops",
        3: "metal_drops_dark", 4: "logo_chrome_1", 5: "logo_chrome_2"}),
    55: ("RhythmImage", "rhythm", {
        0: "band_silhouettes", 1: "female_singer", 2: "sunset_couple", 3: "big_band",
        4: "ballroom_dancers", 5: "film_camera", 6: "synth_player", 7: "organist",
        8: "cartoon_band", 9: "dancer_silhouette", 10: "soul_singer",
        11: "country_guitarists", 12: "marching_band", 13: "world_instruments",
        14: "music_chest", 15: "bank_box"}),
    56: ("SoundImage", "sound", {
        1: "grand_piano", 2: "electric_piano", 3: "stage_piano", 4: "harpsichord",
        5: "acoustic_guitar", 6: "electric_guitar", 7: "string_section", 8: "violin",
        9: "lips", 10: "trombone_trumpet", 11: "trumpet", 12: "xylophone",
        13: "harp_timpani", 14: "steel_drum", 15: "banjo_koto", 16: "recorder",
        17: "pipe_organ", 18: "home_organ", 19: "accordion_red_1", 20: "harmonica",
        21: "saxophone", 22: "flute", 23: "oboe_bassoon", 24: "clarinet",
        25: "keyboard_notes", 26: "instruments_notes", 27: "synthesizer",
        28: "double_bass", 29: "electric_bass", 30: "analog_synth", 31: "drum_kit",
        32: "sound_effects", 33: "snare_drum", 34: "percussion", 35: "accordion_red_2",
        37: "bank_box", 38: "accordion_purple", 39: "accordion_green"}),
    57: ("UserHpMenuEntry", "user_hp_menu", {}),
    58: ("TcdImage", "tcd", {}),
    72: ("OrganTab", "organ_tab", {
        0: "16_flu", 1: "8_flu", 2: "4_flu", 3: "2_2-3_flu", 4: "2_flu", 5: "1_flu",
        6: "16_tb", 7: "8_kn", 8: "8_cl", 9: "8_vn",
        10: "16_flu_italic", 11: "8_flu_italic", 12: "4_flu_italic", 13: "2_2-3_flu_italic",
        14: "2_flu_italic", 15: "1_flu_italic", 16: "16_tb_italic", 17: "8_kn_italic",
        18: "8_cl_italic", 19: "8_vn_italic",
        20: "16_tib", 21: "8_tib", 22: "4_tib", 23: "2_2-3_tib", 24: "2_tib", 25: "1_tib",
        30: "16_tib_italic", 31: "8_tib_italic", 32: "4_tib_italic", 33: "2_2-3_tib_italic",
        34: "2_tib_italic", 35: "1_tib_italic",
        45: "1_3-5_tib", 46: "8_vox", 47: "8_tp", 48: "8_eh", 49: "8_str",
        55: "1_3-5_tib_italic", 56: "8_vox_italic", 57: "8_tp_italic", 58: "8_eh_italic",
        59: "8_str_italic"}),
}


# HelpTexts (segment 67): the four index tables, in header order.
HELP_LANGS = [("English", "En"), ("German", "De"), ("French", "Fr"), ("Spanish", "Es")]
HELP_TOPICS = 100

def _segments():
    s = {}
    s[0] = ("GuiResourceTables", "gui", None, [
        "The GUI's drawing resources. InitializeResource copies the five header words to",
        "BitmapTablePtr, FrameTablePtr, IconTablePtr, FontTablePtr and 0x50122DBC",
        "(annotations/gfx_draw.ann); the fifth word is 0. The bitmap, frame-piece and icon",
        "tables are {s16 width, s16 height, u8 *pixels} rows (DrawBitmap_Impl and friends",
        "index them by number), the font table 0x14-byte descriptors {u16 width, u16",
        "height, s16 descent, u16 byte columns per glyph, glyphs, kern table, Shift-JIS",
        "table} (gfx_draw.ann, at the string renderer); each table ends with an all-zero",
        "row and is followed by the data its rows point at. The pointers are CPU",
        "addresses, not offsets."])
    s[1] = ("SramRecordDefaultsZZZJ", "zzzj", None, [
        "'ZZZJ', 0x00, 'K', 0x00, 0xDC (the 8-byte signature the reader compares with the",
        "program's copy 0x485B7370), 8 zero bytes, then 220 records of 0x18 bytes, which fill",
        "the segment. Read through TableRomSeg01PtrSize by SramRecordsLoadFactory: it copies",
        "records lo..hi over the battery-SRAM table at 0x84030FF8 (same stride), or a",
        "program-ROM default record (0x485B737E) when the signature does not match. Each record",
        "is eight 3-byte entries (zzzj_voice, src/table/style_macros.inc). TODO: what the 220",
        "records configure."])
    s[2] = ("FactoryMemStyleContainer", "tcmp", None, [
        "The factory MEMORY-style container ('TCMP'): MemStyleAreaLoadFactory copies it",
        "whole (through TableRomSeg02PtrSize) to MEM_STYLE_AREA 0x50180000 when it starts",
        "with 'TCMP'. Format: notes/tcmp-container-synthesis.md and kn7000_manual.sym (the",
        "TCMP section); typed by tools/gen_table_styles.py, events one per line."])
    s[3] = ("FactoryMemPadContainer", "tpad", None, [
        "The factory PERFORMANCE PAD user memory ('TPAD'): MemPadAreaLoadFactory clears the",
        "0xA000 bytes at 0x501F91A0 and, when this segment (TableRomSeg03PtrSize) starts",
        "with 'TPAD', copies it in; otherwise it builds an empty container",
        "(notes/work-ram-map.md, 0x501F91A0). Typed by tools/gen_table_styles.py by its",
        "likeness to 'TCMP' (notes/table-semantics-2026-10-29.md); events one per line."])
    s[4] = ("TechnicsPadsResource", "pads", None, [
        "The built-in \"Technics Pads\" PERFORMANCE PAD bank: 120 pads, each a 16-byte name,",
        "a bars/beats header, two part set-ups and an event stream in the style format of",
        "notes/ic18-rhythm-rom.md. TechnicsPadsResourceInit stores its address",
        "(TableRomSeg04Ptr) in 0x50007760 and TechnicsPadsResourceParse reads its header; when",
        "the parse fails the program ROM's own copy (0x4872FE4C) is used. Each pad is an",
        "include file src/table/pads/<Name>.s (tools/gen_table_styles.py)."])
    s[5] = ("OpeningAnimationFrames", "offtab", None, [
        "The boot opening screen's animation: OpeningFrameDraw draws frame n from u32",
        "offset n of this segment; 0 = no frame (it then stores -2 in the u16 at",
        "0x5006B5A8)."])
    s[6] = ("InternalVoiceArchive", "voices", None, [
        "'JK': the INTERNAL (class 0) voice archive. VoiceArchiveScanBoot puts it in slot 0",
        "of the bank-source arrays, and the Voice*LookupInternal routines hash into it",
        "(kn7000_manual.sym, the five bank sources). Typed as far as traced in",
        "src/table/voices/ (tools/gen_table_voices.py)."])
    s[7] = ("TableVersion", "marker", None, [
        "The table build number, ASCII digits and a line feed. The boot code parses the",
        "digits into the u16 at 0x50007DC8, which AcTableVerBoxProc shows as TABLE on the",
        "SOFT VERSION screen."])
    s[8] = ("SeparatorZZZ", "marker", None, [
        "'ZZZ' and a line feed. No program code reads this slot."])
    for slot, xn, stem, what in DEMO:
        if stem is None:
            s[slot] = (f"DemoJpg{xn}Placeholder", "marker", None, [
                f"Not a picture: the 4-byte '27' + line feed that DemoJpgData{xn} returns in",
                "place of a JPEG. TODO: whether the demo ever asks for it."])
        else:
            s[slot] = (f"DemoJpg{xn}", "jpeg", f"demo_{xn.lower()}_{stem}.jpg", [
                f"Feature Demo picture {xn}, returned by DemoJpgData{xn}: {what}."])
    s[55] = ("RhythmImages", "offtab", None, [
        "AcRhyImageProc's pictures: u32 offsets from the segment start, indexed by the u16",
        "at 0x5006B7D8; 0 = none."])
    s[56] = ("SoundImages", "offtab", None, [
        "AcSndImageProc's pictures: u32 offsets from the segment start, indexed by the u16",
        "at 0x5006B80E; 0 = none."])
    s[57] = ("UserHpMenuData", "offtab", None, [
        "Read by AcUserHpMenuProc (func_48496B28): u32 offsets from the segment start,",
        "indexed by item; 0 = none (DrawBox instead). Each entry is a 2-bpp picture of a",
        "USER HP menu panel, drawn with DrawBitmapSPFast4 (four 2-bit pixels per byte,",
        "leftmost in bits 7-6, rows of (width + 3) / 4 bytes) in the colours at 0x485FA224,",
        "0x485FA234 or 0x485FA244 (palette first 0x20 / 0x24 / 0x28) by state. Kept as",
        "PNGs in src/table/user_hp_menu/ (tools/table_png.py)."])
    s[58] = ("TcdImages", "offtab", None, [
        "Read by AcTcdImageProc: u32 offsets from the segment start, picked through the",
        "u16 table 0x485EC940 by GetM3EmVal(0x8081); 0 = none. Each entry is a 240 x 80",
        "1-bpp picture drawn with DrawBitmapSP2 (fg 0xFF, bg 0): 30-byte MSB-first rows.",
        "Kept as PNGs in src/table/tcd/ (tools/table_png.py)."])
    s[59] = ("BuiltinStyleSubTable", "styles", None, [
        "The built-in styles the style-ID index sends to the table ROM (index entry",
        "0x4000 + n = style n; StyleBuiltinNameResolve): TableRomStyleSubTablePtr returns",
        "it and StyleBuiltinNameTableInit caches it in 0x50034B90. u24BE offsets, then the",
        "styles in the \"Technics Rhythms\" format of notes/ic18-rhythm-rom.md, each in",
        "its own include file src/table/styles/<Name>.s, typed event by event",
        "(tools/gen_table_styles.py; macros src/table/style_macros.inc)."])
    s[67] = ("HelpTexts", "help", None, [
        "The HELP function's texts in four languages, English first ('After pressing the",
        "HELP button, ...'). InitializeBlock15 takes the u32 at +4 * (u16 at 0x500D3584)",
        "as the offset of a language's index of 12-byte entries; the four indexes sit at",
        "the end of the segment. An index has one entry per topic: u16 topic number, u16",
        "page count, then the offsets of the topic's page list (u32 text offsets, mostly",
        "ended by a 0) and of its title. Texts are NUL-terminated Latin-1 with the",
        "firmware's '~hh' escapes ('~0d' = new line), padded with 0xFF to 4 bytes."])
    for slot in (68, 69, 70):
        s[slot] = (f"UnreadBuildMarker{slot}", "marker", None, [
            "A build number, ASCII digits and a line feed. No program code reads this slot;",
            "notes/sp7001-build-diff.md compares it across builds."])
    s[71] = ("UnreadMarker71", "marker", None, [
        "'27' and a line feed, like the demo placeholders. No program code reads this slot."])
    s[72] = ("OrganTabImages", "offtab", None, [
        "AcOrganTabProc's drawbar tab pictures: u32 offsets from the segment start; each",
        "entry is a whole Windows BMP ('BM'), and 18 slots reuse another slot's picture."])
    s[83] = ("TechnicsRhythmsTable", "rhythms", None, [
        "A copy of IC18's \"Technics Rhythms\" header, count block, style-ID index, style",
        "table and count-in table, without the styles (notes/ic18-rhythm-rom.md, \"The",
        "table ROM's copy\"). TableRomStyleResourcePtr returns it; StyleBuiltinNameTableInit",
        "re-points the index (0x50034B7C) here when it carries the signature. The style and",
        "count-in offsets are IC18's (tools/gen_table_styles.py)."])
    return s


SEGMENTS = _segments()

# Build 83 (the SP7001 table): segment 83 is a 4-byte stub.
BUILD_OVERRIDES = {
    "83": {
        83: ("TechnicsRhythmsStub", "marker", None, [
            "'DMY' and a line feed in place of the \"Technics Rhythms\" copy of build 84",
            "(notes/sp7001-build-diff.md)."]),
    },
}


def segment_table(build):
    """-> {slot: (label, kind, jpg file or None, comment lines)} for table build `build`
    (the ASCII number in segment 7)."""
    s = dict(SEGMENTS)
    s.update(BUILD_OVERRIDES.get(build, {}))
    assert len(s) == 84 and len({v[0] for v in s.values()}) == 84, "segment labels must be unique"
    return s
