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


def _segments():
    s = {}
    s[0] = ("GuiResourceTables", "gui", None, [
        "The GUI's drawing resources. InitializeResource copies the five header words to",
        "BitmapTablePtr, FrameTablePtr, IconTablePtr, FontTablePtr and 0x50122DBC",
        "(annotations/gfx_draw.ann): the bitmap, frame-piece and icon tables hold",
        "{s16 width, s16 height, u8 *pixels} entries, the font table 0x14-byte descriptors;",
        "the fifth word is 0. The pointers are CPU addresses, not offsets."])
    s[1] = ("SramRecordDefaultsZZZJ", "raw", None, [
        "'ZZZJ', 0x00, 'K', 0x00, 0xDC (the 8-byte signature the reader compares with the",
        "program's copy), then 220 records of 0x18 bytes from +0x10, which fill the segment.",
        "Read through TableRomSeg01PtrSize by the unnamed routine at 0x4843FB65: it copies",
        "records lo..hi over the battery-SRAM table at 0x84030FF8 (same stride), or a",
        "program-ROM default record when the signature does not match.",
        "TODO: what the 220 records configure."])
    s[2] = ("FactoryMemStyleContainer", "raw", None, [
        "The factory MEMORY-style container ('TCMP'): MemStyleAreaLoadFactory copies it",
        "whole (through TableRomSeg02PtrSize) to MEM_STYLE_AREA 0x50180000 when it starts",
        "with 'TCMP'. Format: notes/tcmp-container-synthesis.md."])
    s[3] = ("FactoryMemPadContainer", "raw", None, [
        "The factory PERFORMANCE PAD user memory ('TPAD'): the routine at 0x48432175 clears the",
        "0xA000 bytes at 0x501F91A0 and, when this segment (TableRomSeg03PtrSize) starts",
        "with 'TPAD', copies it in; otherwise it builds an empty container",
        "(notes/work-ram-map.md, 0x501F91A0)."])
    s[4] = ("TechnicsPadsResource", "raw", None, [
        "The built-in \"Technics Pads\" bank resource (16-byte space-padded name first).",
        "The routine at 0x484342B4 stores its address (TableRomSeg04Ptr) in 0x50007760 and,",
        "when 0x48433F4F rejects it, uses the program ROM's own \"Technics Pads\" copy",
        "instead. Same header shape as TechnicsRhythmsTable (segment 83)."])
    s[5] = ("OpeningAnimationFrames", "raw", None, [
        "The boot opening screen's animation: OpeningFrameDraw draws frame n from u32",
        "offset n of this segment; 0 = no frame (it then stores -2 in the u16 at",
        "0x5006B5A8)."])
    s[6] = ("InternalVoiceArchive", "raw", None, [
        "'JK': the INTERNAL (class 0) voice archive. VoiceArchiveScanBoot puts it in slot 0",
        "of the bank-source arrays, and the Voice*LookupInternal routines hash into it",
        "(kn7000_manual.sym, the five bank sources)."])
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
    s[55] = ("RhythmImages", "raw", None, [
        "AcRhyImageProc's pictures: u32 offsets from the segment start, indexed by the u16",
        "at 0x5006B7D8; 0 = none."])
    s[56] = ("SoundImages", "raw", None, [
        "AcSndImageProc's pictures: u32 offsets from the segment start, indexed by the u16",
        "at 0x5006B80E; 0 = none."])
    s[57] = ("UserHpMenuData", "raw", None, [
        "Read by AcUserHpMenuProc: u32 offsets from the segment start, indexed by item.",
        "TODO: the format of the entries."])
    s[58] = ("TcdImages", "raw", None, [
        "Read by AcTcdImageProc: u32 offsets from the segment start; 0 = none.",
        "TODO: the format of the 2400-byte entries."])
    s[59] = ("BuiltinStyleSubTable", "raw", None, [
        "The built-in styles' secondary sub-table: TableRomStyleSubTablePtr returns it and",
        "StyleBuiltinNameTableInit caches it in 0x50034B90 (kn7000_manual.sym, style-name",
        "module). TODO: its record format."])
    s[67] = ("HelpTexts", "raw", None, [
        "The HELP function's texts in four languages, English first ('After pressing the",
        "HELP button, ...'). InitializeBlock15 takes the u32 at +4 * (u16 at 0x500D3584)",
        "as the offset of a language's index of 12-byte entries; the four indexes sit at",
        "the end of the segment."])
    for slot in (68, 69, 70):
        s[slot] = (f"UnreadBuildMarker{slot}", "marker", None, [
            "A build number, ASCII digits and a line feed. No program code reads this slot;",
            "notes/sp7001-build-diff.md compares it across builds."])
    s[71] = ("UnreadMarker71", "marker", None, [
        "'27' and a line feed, like the demo placeholders. No program code reads this slot."])
    s[72] = ("OrganTabImages", "raw", None, [
        "AcOrganTabProc's pictures: u32 offsets from the segment start; each entry is a",
        "Windows BMP ('BM')."])
    s[83] = ("TechnicsRhythmsTable", "raw", None, [
        "A truncated in-flash copy of the built-in \"Technics Rhythms\" style resource.",
        "TableRomStyleResourcePtr returns it; StyleBuiltinNameTableInit re-points the",
        "style-name table here when it carries the signature (kn7000_manual.sym)."])
    return s


SEGMENTS = _segments()

# Build 83 (the SP7001 table): segment 83 is a 4-byte stub.
BUILD_OVERRIDES = {
    "83": {
        83: ("TechnicsRhythmsStub", "marker", None, [
            "'DMY' and a NUL in place of the \"Technics Rhythms\" copy of build 84",
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
