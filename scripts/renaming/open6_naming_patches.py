#!/usr/bin/env python3
"""Headers, comment fixes and data respellings that go with the rename_open6_*.sed scripts (lane open6/kn5000-d naming).

QUESTION IT ANSWERS / WHAT IT DOES
  The sed scripts rename labels; this applies the edits a sed line cannot: header comments for the renamed
  routines, stale comments rewritten, and one table that was spelled as code respelled as typed `.byte` rows.
  Every edit is a byte-exact text replacement; a tree where the text is not found exactly the expected number
  of times is reported and left alone (one line per edit and tree).  Nothing here changes a ROM byte: `make
  gate` must stay byte-identical afterwards.  Evidence for every name and comment:
  notes/open6-kn5000-d/naming/README.md.

RUN (repository root), after the matching sed script has been applied to v10 v9 v7 v6 v5 maincpu:
  python3 scripts/renaming/open6_naming_patches.py --j8z        # kn5000-j8z (maincpu trees)
  python3 scripts/renaming/open6_naming_patches.py --j8z-v142   # kn5000-j8z (v142 sub-CPU; then regenerate
                                                                #  v141 / v140 with scripts/generators/)
  python3 scripts/renaming/open6_naming_patches.py --style      # N-edb08959
  python3 scripts/renaming/open6_naming_patches.py --zc1        # kn5000-zc1
Each phase is one-shot: a second run finds nothing to replace and says so.
"""
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ["v10", "v9", "v7", "v6", "v5"]
REPORT = []


def path(tree, rel):
    if tree.startswith("v14"):
        return os.path.join(REPO, tree, "subcpu", rel)
    return os.path.join(REPO, tree, "maincpu", rel)


def find_file(tree, label):
    """The .s file of `tree` that defines `label:` in column 0."""
    root = os.path.dirname(path(tree, "x"))
    rx = re.compile(rb"^" + re.escape(label.encode()) + rb":", re.M)
    for dp, _, fs in os.walk(root):
        for f in sorted(fs):
            if f.endswith(".s"):
                p = os.path.join(dp, f)
                if rx.search(open(p, "rb").read()):
                    return os.path.relpath(p, root)
    return None


def regex(rel, pattern, new, trees=TREES, tag=None):
    rx = re.compile(pattern.encode("latin-1"), re.M)
    for t in trees:
        r = rel(t) if callable(rel) else rel
        p = path(t, r) if r else None
        if not p or not os.path.exists(p):
            REPORT.append("%-5s %-60s no file" % (t, tag or r))
            continue
        b = open(p, "rb").read()
        found = rx.findall(b)
        if len(found) != 1:
            REPORT.append("%-5s %-60s found %d: SKIPPED" % (t, tag or r, len(found)))
            continue
        nb = rx.sub(lambda m: new.encode("latin-1"), b)
        if nb == b:
            REPORT.append("%-5s %-60s already done" % (t, tag or r))
            continue
        open(p, "wb").write(nb)
        REPORT.append("%-5s %-60s ok" % (t, tag or r))


def header(label, text, trees=TREES):
    """Replace the comment lines directly above `label:` (none is fine) with `text` (first line gets the label)."""
    body = text.strip("\n").split("\n")
    lines = "".join(("; %s: " % label if i == 0 else ";   ") + l.rstrip() + "\n" for i, l in enumerate(body))
    for t in trees:
        rel = find_file(t, label)
        if rel is None:
            REPORT.append("%-5s %-60s label not found" % (t, label))
            continue
        regex(rel, r"(?:^;[^\n]*\n)*^%s:" % re.escape(label), lines + label + ":", [t], tag=label)


def replace(rel, old, new, count=1, trees=TREES, tag=None):
    for t in trees:
        r = rel(t) if callable(rel) else rel
        p = path(t, r) if r else None
        if not p or not os.path.exists(p):
            REPORT.append("%-5s %-60s no file" % (t, tag or r))
            continue
        b = open(p, "rb").read()
        n = b.count(old.encode("latin-1"))
        if n != count:
            REPORT.append("%-5s %-60s found %d, want %d: SKIPPED" % (t, tag or r, n, count))
            continue
        open(p, "wb").write(b.replace(old.encode("latin-1"), new.encode("latin-1")))
        REPORT.append("%-5s %-60s ok" % (t, tag or r))


# ----------------------------------------------------------------------------------------------- kn5000-j8z
GROUP_BASE = """\
; StyleSection_GroupBaseTable: 30 x u8, one per style section (STYLE_SECTION 0..29, in the record order of
;   scripts/build/style_bank_layout.py SECTION_ROLE): the section index of the first VARIATION of the
;   section's group -- 0 for group A, 4 for B, 8 for C.  No reader found: no 24- or 32-bit value and no
;   LDAR in v5..v10 points into it (notes/open6-kn5000-d/naming/probes/table_reader_scan.py).  Until
;   2026-11-02 the bytes were spelled as nop / max / ld (P2:8) instructions (RhythmProc_ChannelMapTable).
StyleSection_GroupBaseTable:
	.byte	0, 0, 0, 0		; A-VARIATION 1..4
	.byte	4, 4, 4, 4		; B-VARIATION 1..4
	.byte	8, 8, 8, 8		; C-VARIATION 1..4
	.byte	0, 0, 0, 0, 0, 0	; A-INTRO 1, 2, A-FILL IN 1, 2, A-ENDING 1, 2
	.byte	4, 4, 4, 4, 4, 4	; B-INTRO 1, 2 .. B-ENDING 1, 2
	.byte	8, 8, 8, 8, 8, 8	; C-INTRO 1, 2 .. C-ENDING 1, 2
"""

DSP_SLOT = {"61": 0, "63": 1, "65": 2, "66": 3, "64": 4}

J8Z_HEADERS = [
    ("PanelMem_InitAllFromFactory", """\
Resets PANEL MEMORY to the factory state: PanelMem_HeaderTemplate ("HK", record size 960, 80 records) to
0x1ED350, the 0xA0 bytes at table data 0x99EC00 to 0x1ED360, every panel memory 0..79 rebuilt by
PanelMem_InitFromFactory, then PanelMem_ApplyFixups.  Basis: callers + body -- MainSysControl's INITIAL
SETTING case 4 PANEL MEMORY (MainSysCtrl_OnInitPanelMemory), Audio_ReinitDisplay and the full re-init after a
panel transfer call it."""),
    ("PanelMem_InitFromFactory", """\
WA = panel memory 0..79: clears its 960-byte record at 0x1ED400 + 960 * WA and fills it from the factory
image at table data 0x99ECA0 + 0x2A2 * WA: its first 0x7C bytes, then 0x11E bytes of SndParamRam_DefaultImage
+ 0x7C, then its remaining 0x226 bytes.  WA >= 80 does nothing.  Basis: callers + body --
PanelMem_InitAllFromFactory loops it over 0..79, and a memory that fails PanelTlv_ValidatePanelMemory is
rebuilt with it."""),
    ("PanelMem_ApplyFixups", """\
Applies PanelMem_FixupRecords (one 6-byte record: u16 memory, 0x50 = all 80; TLV tag; payload offset; OR
value; AND-NOT mask) to the panel memories at 0x1ED400: payload[offset] = (payload[offset] & ~mask) | value
in the tag's record (PanelTlv_PayloadOfTag).  Basis: body + PanelMem_FixupRecords."""),
    ("Composer_ResetStyleImage", """\
Resets the Composer's style image (RHYTHM_PATTERN_BUF_A, 0x94800) to the built-in empty style (AccDemo_Init)
and recounts its free blocks (AccPatch_CountAvailableSlots); XIZ preserved.  Basis: callers + body --
MainSysControl's INITIAL SETTING case 5 COMPOSER (MainSysCtrl_OnInitComposer), the MIDI transfer recovery
of the style-image groups (MidiSysEx_RecoverAbortedXferGroup) and the style-image checks of the
accompaniment engine and the floppy loader call it; entry 2 of AccPatch_InitFuncTable."""),
    ("SeqSong_ResetAll", """\
Re-initialises the sequencer's song memory: for every song slot 0..10 DataBuf_InitSlotFromPreset, then the
slot's defaults (Part_InitVoiceDefaults, Part_WriteWord / Part_WriteByte from +0x1C to +0x112, the voice
sub-blocks, VoiceChannels_InitPanFromPreset), then the panel indicator bit 0x4C.  Basis: callers + body --
MainSysControl's INITIAL SETTING case 6 SEQUENCER (MainSysCtrl_OnInitSequencer),
MainPreControl_OnExitPresentation, SeqInit_JumpToPartInit and SeqLoad_JumpInitFromPreset."""),
    ("MspUser_ResetToFactory", """\
MspUser_InitFromFactory with XIZ preserved.  Basis: callers -- MainSysControl's INITIAL SETTING case 7 MSP
USER (MainSysCtrl_OnInitMspUser), the MIDI transfer recovery of the accompaniment-block groups 18-21 and
MspLoadAuto_CheckAndInit after a failed load."""),
    ("MspUser_InitFromFactory", """\
Re-initialises the accompaniment block area (MSP user data) at 0x1E8800: Voice_InitBankTables, then
Voice_FactoryPresetData (0xF0 words) to 0x1E8820, 0x60 zero words to 0x1E8A00 and MSP_FACTORY_DEFAULTS (0xA80
words) to the block pool 0x1E8B00, and recounts the free blocks (CountAvailableVoiceSlots).  Basis: body."""),
    ("SoundRam_ComputeChecksum", """\
HL = the complemented 16-bit sum of the 0x24B8 words from 0x1E0010, the checksum SoundRam_WriteChecksum
stores at 0x1E72A8.  Basis: body."""),
    ("SoundRam_InitPhase0_SendImage", """\
Init phase 0 of the sound-RAM subsystem (slot 0 of SoundRam_InitFuncTable): when the 16-byte id at 0x1E0000
is SoundRam_Id_KN5000 and SoundRam_ComputeChecksum equals the word at 0x1E72A8, bulk-transfers the 0x72AA-byte
image to sub-CPU 0x7800 (InterCPU_E1_Bulk_Transfer); otherwise sends COMM_BuildAndSendPacket(0xFF, 0xFF)
[INFERENCE: "no user sound image"].  Basis: body."""),
    ("SoundRam_InitPhase2_ResetIfRamLost", """\
Init phase 2 (slot 2 of SoundRam_InitFuncTable): when the backup-RAM status byte 0x1E53E
(SubCPU_Payload_GetErrorFlag) is 0xFF -- set by SubCPU_Payload_Verify when the RAM checksums fail, and by
MainSysControl (SubCPU_PayloadErrorStore) before every INITIAL SETTING case -- sends
COMM_BuildAndSendPacket(0xFF, 0xFF), the packet SoundRam_InitPhase0_SendImage sends when there is no valid
image.  Basis: callers + body -- MainSysControl's case 8 SOUND MEMORY (MainSysCtrl_OnInitSoundMemory) and
the MIDI transfer recovery of the sound-RAM groups call it directly."""),
    ("PanelTag70_ApplyFields", """\
SwbtWr listener of panel record 0x70: payload byte 0 bit 2 and byte 2 (all bits) go to
SndParam_ApplyEventField; bytes 1, 3 and 4 are ignored.  Basis: callers (SwbtB2_Code70_Listeners) + body."""),
    ("PanelTag92_ApplyFields", """\
SwbtWr listener of panel record 0x92: byte 0 (all bits), byte 1 bits 0-3 and bit 7 (two calls) and bytes
2..13 (all bits) go to SndParam_ApplyEventField.  Basis: callers (SwbtB2_Code92_Listeners) + body."""),
    ("PanelTag98_ApplyFieldsAndVolume", """\
SwbtWr listener of panel record 0x98: byte 2 bit 7 goes to SndParam_ApplyEventField; byte 4 is sent to part
25 as CC 7 (volume; 0 when its bit 7 is set); bytes 1 and 3 are ignored.  Basis: callers
(SwbtB2_Code98_Listeners) + body."""),
    ("PanelTagAE_ApplyFields", """\
SwbtWr listener of panel record 0xAE: every changed payload byte, bit 7 cleared, goes to
SndParam_ApplyEventField.  PanelTagB1 / B2 / B4 / B5_ApplyFields do the same for 0xB1, 0xB2, 0xB4, 0xB5.
Basis: callers (SwbtB2_CodeAE_Listeners ..) + body."""),
    ("PanelTagB0_ApplyFields", """\
SwbtWr listener of panel record 0xB0: bytes 0, 1 and 3 (all bits) go to SndParam_ApplyEventField.  Basis:
callers (SwbtB2_CodeB0_Listeners) + body."""),
    ("PanelTagB3_ApplyFields", """\
SwbtWr listener of panel record 0xB3: every changed payload byte except 16..20, bit 7 cleared, goes to
SndParam_ApplyEventField.  Basis: callers (SwbtB2_CodeB3_Listeners) + body."""),
    ("PanelTag43_ApplyFields", """\
SwbtWr listener of panel record 0x43: byte 0 bit 7, and byte 1 bits 0-6 and bit 7 (two calls), go to
SndParam_ApplyEventField.  Basis: callers (SwbtB2_Code43_Listeners) + body."""),
    ("SoundRam_ConvertNibbleMap", """\
16 x u8: maps a 4-bit field of an older model's sound record to a 2-bit code (1 1 1 1 1 1 0 0 / 1 2 3 1 1
1 1 1); SoundRam_ConvertSounds_Helper looks up the high nibbles of record bytes +18 and +19 and the low
nibble of +19 in it and packs the three codes into byte +17.  Basis: reader + bytes."""),
]

# v10's headers of the PanelTag60 / PanelTag72 listeners, carried to v7 / v6 / v5 where they were HdaeRom_*.
PANELTAG60_72 = [
    ("PanelTag60_ApplyEffectOnOff", """\
SwbtWr listener of panel record 0x60: for payload +1 applies bits 7, 6 and 5 (DIGITAL
REVERB, ACOUSTIC ILLUSION and EQUALIZER on/off) one at a time through SndParam_ApplyEventField. Basis: callers +
body."""),
    ("PanelTag72_ApplyPartMix", """\
SwbtWr listener of panel record 0x72: +3 is sent to parts 0x17 and 0x18 as CC 7 (volume; 0
when bit 7 is set), +7 as CC 91 (reverb send). Basis: callers + body; nothing to do with the HDAE ROM."""),
]


def j8z():
    regex("sequencer/accompaniment_engine.s",
          r"^StyleSection_GroupBaseTable:\n(?:\t(?:nop|max|ld \(P[02]:8\), [08]:io)\n)+\t\.fill 6, 1, 0x08\n",
          GROUP_BASE, tag="StyleSection_GroupBaseTable respelled")
    for label, text in J8Z_HEADERS:
        header(label, text)
    for tag, slot in sorted(DSP_SLOT.items()):
        header("PanelTag%s_ApplyDspSlot" % tag, """\
SwbtWr listener of panel record 0x%s (DSP slot %d): a change of payload byte 0..24 (event +1) with a
non-zero mask (+3) is applied as a change of byte 0 through SndParam_ApplyEventField [INFERENCE: so the whole
slot is re-sent].  Basis: callers (SwbtB2_Code%s_Listeners) + body; floppy/kn5000/panel_fields.py names
records 0x61 / 0x63 / 0x65 / 0x66 / 0x64 the DSP slots 0..4.""" % (tag, slot, tag))
    for label, text in PANELTAG60_72:
        header(label, text, trees=["v7", "v6", "v5"])


def j8z_v142():
    header("TVF_Emit_Registers_Type2", """\
TVF_Emit_Registers for the type-2 voices (class (voice+1) & 0x3C = 0x10): the same six cases, with
the mode from (tonerec+0x0F) & 7 instead of (tonerec+0x36) & 7 and the offsets in
TVF_Emit_Registers_Type2_CaseOffsets; it writes the same staging words 0x0451D4 / 0x0451D6, which
ToneGen_WriteVoice_TvfPair sends to TG registers 0x100 / 0x140 (the TVF pair).  In: XWA = per-voice record.
The A/B pair mirrors the two parameter groups of the tone record (cluster 0x0F..0x16 vs 0x36..0x3C,
0x4D..0x50).  Basis: callers + body -- TVF_Refresh_Sounding_Voices calls it for class 0x10 and
TVF_Emit_Registers for 4 / 0x20; Voice_Init_Type2 calls it.  (Was Voice_PanReg_WriteDispatchB.)""",
           trees=["v142"])


# ----------------------------------------------------------------------------------------------- N-edb08959
TIME_SIG = ["1/2", "2/2", "3/2", "4/2", "1/4", "2/4", "3/4", "4/4", "5/4", "6/4", "7/4", "8/4",
            "1/8", "2/8", "3/8", "4/8", "-", "-", "-", "-"]
STYLE_PAIRS = [(0x00, 0x00), (0x58, 0x02), (0x08, 0x02), (0x18, 0x03),
               (0x00, 0x00), (0x00, 0x00), (0x09, 0x01), (0x58, 0x02),
               (0x00, 0x00), (0x08, 0x02), (0x00, 0x00), (0x18, 0x03),
               (0x00, 0x00), (0x00, 0x00), (0x09, 0x01), (0x58, 0x02),
               (0x00, 0x00), (0x08, 0x02), (0x00, 0x00), (0x18, 0x03)]


def default_style_table():
    rows = "".join("\t.byte\t0x%02x, 0x%02x\t; %s\n" % (n, g, TIME_SIG[i] if i < 16 else "(no time signature reaches it)")
                   for i, (n, g) in enumerate(STYLE_PAIRS))
    return ("; AccPatch_DefaultStyleByTimeSig: The PANEL_STYLE pair {style number, style group} a section record gets at\n"
            ";   +0x10 / +0x11 when it is set up for TIME SIGNATURE n (AccPatch_SetVoiceAndInit reads the word at\n"
            ";   2 * STYLE_SECTION_TIME_SIG; time signatures in the order of RamInit_TimeSigPtrs); {0, 0} = none.  The last\n"
            ";   four entries are beyond index 15.  Basis: readers + bytes (notes/kn5000-style-2026-10-31/README.md, rec +0x10).\n"
            "AccPatch_DefaultStyleByTimeSig:\n" + rows)


STYLE_HEADERS = [
    ("Composer_SetPassword", """\
Stores WA as the Composer password, word +0x0E of the style image (0x9480E).  Basis: callers + body --
Password_ClearAndSetSlot (EVT_SET_PASSWORD, FmmPasswordFunc) stores the entered password with it after
ClearAllSongSlots (notes/kn5000-style-2026-10-31/README.md, hdr +0x0e)."""),
    ("Composer_GetPassword", """\
HL = the Composer password, word +0x0E of the style image (0x9480E).  Basis: body + Composer_SetPassword."""),
    ("Composer_IsPassword", """\
HL = 1 when WA equals the Composer password (Composer_GetPassword), else 0.  Basis: callers + body -- the
password delete / save handlers compare the entered value with it."""),
    ("Composer_HasPassword", """\
HL = 1 when a Composer password is set (Composer_GetPassword non-zero), else 0.  Basis: body -- the
EVT_SET_PASSWORD handler refuses a new password while one is set."""),
    ("ComposerChordMap_GetRecord", """\
XIY = RHYTHM_PATTERN_BUF_A + 0xBA0 + 32 * (0x390A): the 32-byte COMPOSER CHORD MAP record selected by 0x390A
(style image +0xBA0, chord_map[5]).  Basis: callers + body -- the chord-map step code stores PANEL_STYLE & 15
in 0x390A, calls it and copies four bytes of the record to 0x390E."""),
    ("CmpRecSet_RowHandlers", """\
15 x u32: the RECORD SETTING page's row handlers, entry = cursor row - 1 (CmpRecSet_DispatchRow): MEASURE,
TIME SIGNATURE, KEY, CHORD (minor bit), BASS TYPE (7th bit 6), ACCOMP TYPE (7th bit 5), the rhythm program and
the rhythm bank; the rest CmpRecSet_NopRow.  Handlers 0-5 step their field up, or down when bit 7 of W is set.
Basis: readers + bodies (record +0x0E/+0x0F fields, notes/kn5000-style-2026-10-31/README.md)."""),
]


def style():
    regex("sequencer/accompaniment_engine.s",
          r"^AccPatch_DefaultStyleByTimeSig:\n(?:\t\.byte [^\n]*\n){5}", default_style_table(),
          tag="AccPatch_DefaultStyleByTimeSig respelled")
    replace("sequencer/accompaniment_engine.s",
            "; Runs AccPatch_SyncVoice_Bass, _Acc1, _Acc2, _Acc3 and _Bass on the current patch slot.",
            "; Runs AccPatch_SyncVoice_Bass, _Acc1, _Acc2, _Acc3 and _Drum on the current patch slot.",
            tag="AccPatch_SyncAllVoiceParams comment")
    for label, text in STYLE_HEADERS:
        header(label, text)


# ----------------------------------------------------------------------------------------------- kn5000-zc1
# The song-data cursor: track = (SEQ_CURSOR_TRACK) 1-based; block number (u16) at 0x0C9E + 2 * (track - 1),
# offset (u8, 5..255) at 0x0CBE + track - 1, into 256-byte blocks at (SEQ_BLOCK_POOL) + 256 * (block - 1)
# (5-byte header: flags, previous link +1, next link +3, 0xFFFF = none).
ZC1_HEADERS = [
    ("SeqBlock_Select", """\
SEQ_BLOCK_PTR = (SEQ_BLOCK_POOL) + 256 * (IY - 1): selects song block IY (1-based).  Out: XHL = 0.
Basis: body; every song-data routine calls it before reading (SEQ_BLOCK_PTR)."""),
    ("SeqTrack_WordIndex", """\
IZ = 2 * ((SEQ_CURSOR_TRACK) - 1), the index of the cursor track's word in the cursor block table 0x0C9E
(IZ / 2 indexes the offset table 0x0CBE).  Preserves WA.  Basis: body."""),
    ("SeqTrack_TripleIndex", """\
IZ = 3 * ((SEQ_CURSOR_TRACK) - 1), the index of the cursor track's 3-byte entry (track table 0xF250).
Preserves WA.  Basis: body."""),
    ("SeqTrack_ReadCursorByte", """\
Reads the byte at the cursor track's song-data cursor: block (0x0C9E)[track] (SeqBlock_Select), offset
(0x0CBE)[track].  Out: WA = the byte (W = 0), XHL = the block, IZ = SeqTrack_WordIndex.  Basis: body;
SeqTrack_WriteCursorByte is its write twin."""),
    ("SeqTrack_PeekAhead", """\
Reads the byte (0x0DF5) bytes past the cursor without moving it: in the cursor block, or byte 5 of the next
block (link +3) past offset 255.  Out: A = the byte, W = 0xFF when there is no next block.  Basis: body;
SeqTrack_PeekNextByte / SeqTrack_PeekSecondByte set 0x0DF5 = 1 / 2."""),
    ("SeqTrack_PeekNextByte_SaveRegs", """\
A = E, then SeqTrack_PeekNextByte with XIY, XIZ and XHL preserved.  Basis: body."""),
    ("SeqTrack_ReadCursorByteOfTrack", """\
A = the byte at the song-data cursor of track E (1-based), without changing SEQ_CURSOR_TRACK; XHL and DE
preserved.  Basis: body (SeqTrack_ReadCursorByte for an explicit track)."""),
    ("SeqEvent_CheckStatusByte", """\
W = 0 when A can start a stored event -- 0x80..0x86 except 0x83, or 0x90..0xD3 except 0xA0..0xAF -- else W =
0xFF.  Basis: body; SeqTrack_StepEvent skips bytes while it returns 0xFF."""),
    ("SeqTrack_StepEvent", """\
Moves the song-data cursor to the next event (W = 0) or the previous one (W = 1): walks the bytes, following
the block links (+3 forward, +1 back), until SeqEvent_CheckStatusByte accepts one; each 0x81 marker passed
adjusts SQSTEP_WRAP_COUNT (+1 forward unless a peek finds the chain end or 0x82; SeqTrack_DecWrapCount back).
Stores the new cursor and the number of bytes moved in 0x0DCC.  Out: W = 0 moved, 0xFF at the end / start of
the track.  Basis: body."""),
    ("SeqTrack_NextEvent", """\
SeqTrack_StepEvent forward, unless the cursor is at the end: W = 0xFF when the next byte is past the block
chain (SeqTrack_PeekNextByte) or is 0x82, or when the cursor byte is 0x84; otherwise W = 0 and the cursor
moved.  Basis: body."""),
    ("SeqTrack_NextEventKeepWrapCount", """\
SeqTrack_NextEvent with SQSTEP_WRAP_COUNT (0x0D58) saved and restored around it.  Basis: body."""),
    ("SeqTrack_PrevEvent", """\
SeqTrack_StepEvent with W = 1: one event back.  Basis: body."""),
    ("SeqTrack_PrevEventKeepWrapCount", """\
SeqTrack_PrevEvent with SQSTEP_WRAP_COUNT (0x0D58) saved and restored; W = 255 at the start of the track.
Backward twin of SeqTrack_NextEventKeepWrapCount.  Basis: callers + body -- ScoopDisp_SeekBackWrapMarkers
walks back to the preceding 0x81 with it."""),
    ("SeqTrack_DecWrapCount", """\
SQSTEP_WRAP_COUNT - 1, not below 0; XIY preserved.  Basis: body (SeqTrack_StepEvent's backward 0x81 case)."""),
    ("SeqTrack_WriteBytesAtCursor", """\
Copies BC bytes from the pointer at 0x1101 to the song-data cursor and advances the cursor past them,
continuing at byte 5 of the next block (link +3) when the block is full; BC = 0 does nothing.  Basis: callers +
body -- the step-edit insert paths (and demo/demo_seq_bridge.s) call Scoop_EventHandler_Scroll first to open
the gap."""),
    ("SeqTrack_DeleteBytesAtCursor", """\
Deletes W bytes at the song-data cursor: computes the span's end (0x28BA block, 0x28BC offset), moves the rest
of the track down (Scoop_EventHandler_SpecialMode) [INFERENCE] and frees the blocks that become empty
(MemConfig_Handler_1_Helper5).  Basis: callers + body -- SqStep_DeleteEventAtCursor passes the event length
SeqTrack_StepEvent measured (0x0DCC)."""),
    ("SeqCursor_Save", """\
Saves the cursor track's song-data cursor into snapshot slot A (0..7; 8 bytes at 0x0DFF + 8 * A): block word,
offset, SQSTEP_CLOCK, SQSTEP_WRAP_COUNT, SQSTEP_UNITS.  Registers preserved; SeqCursor_Restore writes them
back.  Basis: body."""),
    ("SeqCursor_Restore", """\
Restores the song-data cursor from snapshot slot A (0..7) written by SeqCursor_Save (VoiceState_RestoreEntry,
VoiceState_RestoreDone); WA, XHL, XIZ and XIY preserved.  Basis: body."""),
    ("SeqTrack_CheckEventFollows", """\
W = 255 when an event other than the end markers follows the cursor within 6 bytes (0x81 markers skipped), W
= 0 when 0x82 / 0x84 or nothing comes first, and when the cursor byte itself is 0x84 (then BC = 2, at once).
The cursor is restored from snapshot slot 7.  Basis: body; the step-edit field writers (SqStep_WritePopupValueToEvent
and its siblings) only write when it returns non-zero."""),
    ("SqStep_WritePopupValueToEvent", """\
When SeqTrack_CheckEventFollows allows it: saves the cursor (slot 0), moves it (PERF_STEP_FIELD) bytes on,
writes (POPUP_VALUE) there (SeqTrack_WriteCursorByte) and restores the cursor.  Basis: callers + body -- the
VoiceParam_Case* pop-up handlers call it after storing the edited value."""),
    ("SqStep_RebuildGridRows", """\
When bit 0 of 0x0DD3 is set (clears it): rebuilds the step-edit grid around the cursor -- backs up to the
start of the displayed row (SqStep_GetBeatInGridRow, SeqTrack_SkipWrapMarkers), finds its end, builds the row
bitmap (SqStep_BuildCurrentRowBitmap) and the rows above and below (SqStep_SetupPrevGridRow /
SqStep_SetupNextGridRow), and redraws regions 1, 2, 4 and 5; the cursor is restored.  Basis: callers + body."""),
    ("SqStep_ShowCursorEventPopup", """\
Shows the pop-up for the event at the song-data cursor, by its status byte: 0x9n note (SqStep_AuditionCursorNotes
too), 0xBn control (ParamPopup_* per controller), 0xCn program, 0x8n markers, 0xDn; the 0x81 / clock cases go to
SqStep_ShowCursorMarkerPopup.  Basis: body."""),
    ("SqStep_ShowCursorMarkerPopup", """\
Counts the 0x81 markers at the cursor (stepping over them, 0x0D62) and shows the beat count
(DisplayStr_ShowBeatCount), or at a 0x82 / 0x84 marker the section name (SQSTEP_STYLE_SECTION = 8 / 9,
DisplayStr_CopyStyleSectionName).  Basis: body."""),
    ("SqStep_AuditionCursorNotes", """\
When the cursor event is a note (0x90): saves the cursor (slot 1), flushes SeqBuf and sends note-offs, then
writes the notes that start at the same clock into SeqBuf (status, note, velocity 64, track) so they sound;
restores the cursor.  Basis: body."""),
]


def zc1():
    for label, text in ZC1_HEADERS:
        header(label, text)


PHASES = {"--j8z": j8z, "--j8z-v142": j8z_v142, "--style": style, "--zc1": zc1}

if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in PHASES:
        sys.exit(__doc__)
    PHASES[sys.argv[1]]()
    print("\n".join(REPORT))
