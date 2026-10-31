#!/usr/bin/env python3
"""gen_rhythm_data_s.py -- write the first source tree of the KN5000 rhythm data ROM IC14 (rhythm_data/).

QUESTION IT ANSWERS
  "Can every byte of IC14 be written as typed records -- style records, track pointer tables and event
   streams -- that reassemble to the descrambled image byte for byte?"  It parses the image with the event
   grammar of the main CPU's accompaniment reader, refuses to write anything if a single byte is left
   unexplained, and writes rhythm_data/*.s.  After that first run the .s files are the authoritative source
   (edit them, not this script); the script stays as the record of how they were derived.  --check
   regenerates into a scratch directory ($TMPDIR) and lists the files that differ from the committed tree;
   they will start to differ once someone improves the source by hand, which is allowed.

INPUT
  The DESCRAMBLED image (A19/A21 swap undone), SHA-1 fef7f1927935d8fdada2afbdbfac29aac56e1c3c, which
  `make original_ROMs/kn5000_rhythm_data_rom.ic14` copies from the private romset (git-ignored).

LAYOUT IT WRITES (every claim is cited in notes/rhythm-data-ic14-2026-10-29/README.md)
  0x000000-0x064FFF  202 style records of 2 KB, each two 1 KB halves ("..1n" / "..1v" in their id string)
  0x065000-0x3787FF  28,400 tracks (80 FF FF FF FF 87, events, 83 87) in 64 KB banks 6..0x37, FF to each
                     bank's end
  0x378800-0x3FFFFF  erased (FF)

USAGE
  python3 scripts/generators/gen_rhythm_data_s.py [--rom original_ROMs/kn5000_rhythm_data_rom.ic14]
          [--out rhythm_data] [--stats | --check]
"""
import argparse
import collections
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SHA1 = "fef7f1927935d8fdada2afbdbfac29aac56e1c3c"

HALF = 0x400
REC = 0x800
N_RECORD_BYTES = 0x65000
BANK = 0x10000
FIRST_BANK, LAST_BANK = 6, 0x37
ROM_SIZE = 0x400000

TRK_HEAD = bytes.fromhex("80ffffffff87")
EV_LEN = {0x81: 1, 0x90: 6, 0x91: 8, 0xd1: 3, 0xd2: 3, 0xd3: 3, 0xd4: 3, 0xd5: 3}
CC_NAME = {0xd1: "cc_mod", 0xd2: "cc_bend", 0xd3: "cc_damper", 0xd4: "cc_pan", 0xd5: "cc_expr"}

LANES = ["Drum", "Drum2", "Bass", "Acc1", "Acc2", "Acc3"]
SOUND_PARTS = ["DRUM", "BASS", "ACCOMP1", "ACCOMP2", "ACCOMP3"]
TIMESIG = {6: "TIMESIG_3_4", 7: "TIMESIG_4_4", 9: "TIMESIG_6_4", 11: "TIMESIG_8_4"}
N_SLOTS = 19


# AccVoice_LocatorTable is not in this ROM: the (bank, program) -> record map comes from the program ROM.
LOCATOR_SYM = 0xE45142      # RhythmROM_BankProgramLocators [bank 8][program 128] {u16 hi, u16 lo}
REMAP_SYM = 0xE4638A        # VoiceParam_BankProgramWords [bank 8][program 128] -> u16 bank << 8 | program
PANEL_MAP_SYM = 0xE4935F    # AccStyle_PanelRhythmTable [program 128][bank 8] -> u16 number << 8 | group
NAMES13_SYM = 0xE47147      # AccVoice_RomRecords13 [group * 20 + number] 13-char style names
GROUPS16_SYM = 0xE47047     # AccVoice_RomRecords16 [group] 16-char rhythm-group names


MACROS = """\
; =============================================================================
; KN5000 RHYTHM DATA ROM IC14 -- RECORD AND EVENT MACROS
; =============================================================================
; First written by scripts/generators/gen_rhythm_data_s.py; this file is now the source.
; Readers are main-CPU v10 routines (the same code is in v9 and v7); their addresses are in
; symbols/maincpu_v10_symbols_reference.txt.  Evidence and open questions:
; notes/rhythm-data-ic14-2026-10-29/README.md.

; -----------------------------------------------------------------------------
; TRACKS (the pattern banks)
; -----------------------------------------------------------------------------
; A track is one part's pattern for one slot.  The reader (AccVoice_ProcessEventLoop) is handed
; XHL = AccVoice_TableLookup(bank) = bank base + 0x8000 and IY = (slot word - 0x8000 + 6) by
; AccPart_GetParamAddr, so it starts 6 bytes into the track, past this header.
;   +0  0x80          start marker
;   +1  prev          u16 page link (0xffff: none)
;   +3  next          u16 page link: AccBuf_Advance, on a 0x87 byte, continues at the page
;                     the word at header +3 names (AccWave_BankResolve), offset 6
;   +5  0x87          page-end marker; every ROM track ends with one too (trk_end), so the
;                     links are never followed here: all 28,400 headers are 0xffff, 0xffff
.macro	trk_begin prev=0xffff, next=0xffff
	.byte	0x80
	.short	\\prev, \\next
	.byte	0x87
.endm

; 0x83 = end of the pattern (AccVoice_HandleMarker83: loop, next pick or stop), then the 0x87
; page-end marker.
.macro	trk_end
	.byte	0x83, 0x87
.endm

; 0x81: one beat passes (AccVoice_HandleBarEndEvent; 96 ticks per beat, AccTempo_PositionCompare).
.macro	beat count=1
	.rept	\\count
	.byte	0x81
	.endr
.endm

; 0x90 note (AccMidi_ParseCommon -> ACC_EVENT+0..+5): tick within the beat (0..95), note
; number, velocity, duration = dur_beats * 96 + dur_ticks.  Parts 4..32 check the note
; against 0x78 (Rhythm_CheckVelocityThreshold); the two drum parts do not.
.macro	note tick, key, vel, dur_ticks, dur_beats
	.byte	0x90, \\tick, \\key, \\vel, \\dur_ticks, \\dur_beats
.endm

; 0x91 note with two more bytes (AccMidi_ParseNoteOn stores them at RAM 0x3433 / 0x3434).
; What the two mean is not established (docs/accompaniment-style-format.md, NOTE2).
.macro	note2 tick, key, vel, dur_ticks, dur_beats, ext1, ext2
	.byte	0x91, \\tick, \\key, \\vel, \\dur_ticks, \\dur_beats, \\ext1, \\ext2
.endm

; 0xD1..0xD5: controller events, 3 bytes (AccMidi_ParseDType: status & 0x0f = selector into
; ACC_EVENT+2, tick, value).  Selector meanings from SeqPerformance_EventDispatch
; (docs/accompaniment-style-format.md): 1 modulation (CC 1), 2 pitch bend, 3 damper (CC 64),
; 4 pan (CC 10), 5 expression (CC 11).
.macro	cc_mod tick, value
	.byte	0xd1, \\tick, \\value
.endm
.macro	cc_bend tick, value
	.byte	0xd2, \\tick, \\value
.endm
.macro	cc_damper tick, value
	.byte	0xd3, \\tick, \\value
.endm
.macro	cc_pan tick, value
	.byte	0xd4, \\tick, \\value
.endm
.macro	cc_expr tick, value
	.byte	0xd5, \\tick, \\value
.endm

; -----------------------------------------------------------------------------
; STYLE RECORDS: 2 KB, two 1 KB halves of this layout
; -----------------------------------------------------------------------------
;   +0x000  style_section_map   280 B   which slots each section plays, per part
;   +0x118  part_tracks x 6     228 B   19 track slots per part
;   +0x1fc  style_gap_1fc        76 B   FF
;   +0x248  8 sound blocks      392 B   5 part_sound + sound_block_end each
;   +0x3d0  style_tail           48 B   time signature, pattern bank, velocities, id
; The parts are the six one-hot part bits 1, 2, 4, 8, 16, 32 (ACC_PART_BIT) in this order.

; One section's pattern picks: up to four slot numbers played in turn, then 0x83, at which
; AccPart_IncrementIndex returns to the first pick of the group.  A pick p selects the part's
; track slot p (AccPart_LookupBoundVoiceParam: word p of AccPart_LookupBoundVoiceParam_Data).
.macro	sec_picks p0, p1, p2, p3
	.byte	\\p0, \\p1, \\p2, \\p3, 0x83
.endm

; +0x000: 7 blocks of 40 bytes.  AccStyle_ReadParamOffset reads block 0 for parts 1 and 2 and
; blocks 1..4 for parts 4, 8, 16, 32 (+40, +80, +120, +160); the slot index is the section's
; group of five (AccStyle_ReadParamOffset_Data: slots 0..19 in half 0, 0x400.. in half 1).
; The second 20 bytes of each block are read only by AccStyle_ByteDataBlock (+20 .. +180),
; which nothing in v10 calls; blocks 5 and 6 have no reader.  The map is the same in all 404
; halves of this ROM, so it is spelled once here.
.macro	style_section_map
	.rept	7
%s	.endr
.endm

; +0x118 + 0x26 * part: the part's 19 track slots, each the track's offset in the 64 KB pattern
; bank this half names at +0x3d1 (AccPart_GetParamAddr; AccVoice_TableLookup adds the bank).
;   slots 0..7    picked by the section map
;   slots 12..15  AccVoice_ComputeParamAddr: 0x18/0x1a (section slot < 15), 0x1c/0x1e (< 20),
;                 the same +0x400 in half 1; the second of each pair when RAM 0x3309 bit 0 is 0
;   slots 16..18  AccVoice_SelectPartOffset (0x20, 0x22, 0x420: RAM 0x32ff bits 0/1),
;                 AccVoice_Reset_SelectMode (0x330a), AccVoice_ThirdLayer_SelectMode (0x24/0x424)
;   slots 8..11   no reader: every offset handed to AccPart_GetParamAddr is a section-map pick
;                 (0..7), 0x18..0x1e, 0x20, 0x22, 0x24 or their +0x400 twins
;                 (notes/kn5000-a-2026-10-31/probes/ic14_slot_readers.py); leftover bars
; Measured over all 404 halves x 6 parts (probes/slot_bars_probe.py): every track in slots
; 0..15 and 17 is exactly one bar; slots 16 and 18 hold 1..8 bars.  [INFERENCE] 12..15 are the
; fill-ins (AccPedal_DirectionA picks the pair member) and 16 / 18 intro / ending patterns.
.macro	part_tracks bank, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18
	.short	\\s0 - (RhythmData_Base + (\\bank << 16)), \\s1 - (RhythmData_Base + (\\bank << 16))
	.short	\\s2 - (RhythmData_Base + (\\bank << 16)), \\s3 - (RhythmData_Base + (\\bank << 16))
	.short	\\s4 - (RhythmData_Base + (\\bank << 16)), \\s5 - (RhythmData_Base + (\\bank << 16))
	.short	\\s6 - (RhythmData_Base + (\\bank << 16)), \\s7 - (RhythmData_Base + (\\bank << 16))
	.short	\\s8 - (RhythmData_Base + (\\bank << 16)), \\s9 - (RhythmData_Base + (\\bank << 16))
	.short	\\s10 - (RhythmData_Base + (\\bank << 16)), \\s11 - (RhythmData_Base + (\\bank << 16))
	.short	\\s12 - (RhythmData_Base + (\\bank << 16)), \\s13 - (RhythmData_Base + (\\bank << 16))
	.short	\\s14 - (RhythmData_Base + (\\bank << 16)), \\s15 - (RhythmData_Base + (\\bank << 16))
	.short	\\s16 - (RhythmData_Base + (\\bank << 16)), \\s17 - (RhythmData_Base + (\\bank << 16))
	.short	\\s18 - (RhythmData_Base + (\\bank << 16))
.endm

.macro	style_gap_1fc
	.fill	76, 1, 0xff
.endm

; +0x248 + 0x31 * block: a section's part sounds.  AccVoice_LoadTuningBlock copies block
; (AccPart_VoiceParamOffsets_*: 0x00, 0x31, ... 0x157, + 0x400 in half 1) to RAM 0x3246, and
; RhythmROM_PatternDisp_Handle90 copies its five records (RhythmROM_PatternDisp_BufOffsets).
; The records are DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3: the Sound Arranger
; (AccTuning_LoadFromROM) overwrites record n's program / bank from its arrangement pair n.
;   +0 program    +1 bank (7 bits)
;   +2 forced     both loaders overwrite it with 0x40 / 0x0c / 0x74 / 0x40 in records 1..4
;   +3 bank_msb   AccTuning_LoadFromROM stores bit 7 of the arrangement's bank byte here
;   +4 voice4     byte 4 of the part's 5-byte voice record (RAM 0x3214 + 5 * record + 4) and of the
;                 0xC0 record RhythmPartN_ProcessRingBuf appends to the channel ring buffer; nothing
;                 reads it on its own (the AccVoiceReg_WritePartN take bytes 0, 1 and 3)
;   +5 turnover   RhythmPartN_LoadAndStore -> RAM 0x32c3 + record - 1 -> 0x32cb (Rhythm_SetupChannel_Dn):
;                 Rhythm_TransposeNote moves a transposition above it an octave down, and
;                 Rhythm_CrossVoiceCorrect bases its lower limit 0x332e on it
;   +6 ceiling    -> RAM 0x32c7 + record - 1 -> 0x32cc: Rhythm_TransposeNote folds a note at or above it
;                 down by octaves (only when it is 12 or more; 127 = no folding)
.macro	part_sound program, bank, forced, bank_msb, voice4, turnover, ceiling
	.byte	\\program, \\bank, \\forced, \\bank_msb, \\voice4, \\turnover, \\ceiling
.endm
.macro	sound_block_end
	.fill	14, 1, 0xff
.endm

; Time-signature codes (+0x3d0): the index of TimeSig_DisplayStrings, whose names they are;
; AccTone_LookupByProgram_Table holds the beats per bar.  Measured: every track in slots
; 0..15 and 17 of a half is exactly one bar of its half's code (probes/slot_bars_probe.py).
.equ	TIMESIG_3_4, 6
.equ	TIMESIG_4_4, 7
.equ	TIMESIG_6_4, 9
.equ	TIMESIG_8_4, 11

; +0x3d0: the half's tail.
;   +0x3d0 time_sig      AccStyle_ReadVoiceParam: beats per bar through AccTone_LookupByProgram_Table;
;                        Rhythm_LoadCurrentTimeSig: index into TimeSig_DisplayStrings (RAM 0x34f0)
;   +0x3d1 bank          the 64 KB pattern bank of this half's tracks (AccStyle_SetupPartAddresses ->
;                        ACC_STYLE_BANK, AccVoice_TableLookup)
;   +0x3d2 v<s>a, v<s>b  per section s of the half: Rhythm_LookupTuningRange -> RAM 0x333f / 0x3340,
;                        the two velocity settings AccMidi_SelectVelocitySource chooses between
;   +0x3da flag          AccStyle_ReadVoiceParam W -> RAM 0x32ef (written, no reader in v10)
;   +0x3db id            8 ASCII characters, "<style id>1n" / "<style id>1v"; no reader found
;   +0x3e3 m0, m1, 0, m3, w0..w3 (u16), c0..c3   16 bytes no code reads: no displacement 0x3e3..0x3f2
;                        (or +0x400) off any base and no copy of the tail to RAM in v10; authoring
;                        metadata (ic14_slot_readers.py lists the search)
;   +0x3f3 13 zero bytes
.macro	style_tail time_sig, bank, v0a, v0b, v1a, v1b, v2a, v2b, v3a, v3b, flag, id, m0, m1, m3, w0, w1, w2, w3, c0, c1, c2, c3
	.byte	\\time_sig, \\bank, \\v0a, \\v0b, \\v1a, \\v1b, \\v2a, \\v2b, \\v3a, \\v3b, \\flag
	.ascii	"\\id"
	.byte	\\m0, \\m1, 0, \\m3
	.short	\\w0, \\w1, \\w2, \\w3
	.byte	\\c0, \\c1, \\c2, \\c3
	.fill	13, 1, 0
.endm
"""


def u16(b, o):
    return b[o] | (b[o + 1] << 8)


def parse_tracks(d, a, b):
    """Tracks from a to the FF fill at the end of the region.  Returns [(start, end, events)], fill start."""
    p = a
    out = []
    while p < b and d[p] != 0xff:
        if d[p:p + 6] != TRK_HEAD:
            sys.exit("track header expected at 0x%06X, found %s" % (p, d[p:p + 6].hex()))
        s = p
        p += 6
        ev = []
        while True:
            o = d[p]
            if o == 0x83:
                if d[p + 1] != 0x87:
                    sys.exit("0x83 not followed by 0x87 at 0x%06X" % p)
                p += 2
                break
            if o not in EV_LEN:
                sys.exit("unknown event 0x%02X at 0x%06X" % (o, p))
            ev.append(d[p:p + EV_LEN[o]])
            p += EV_LEN[o]
        out.append((s, p, ev))
    fill = p
    if d[fill:b] != b"\xff" * (b - fill):
        sys.exit("region 0x%06X-0x%06X: bytes after the last track are not all FF" % (fill, b))
    return out, fill


def ev_line(e):
    o = e[0]
    if o == 0x90:
        return "\tnote\t%d, %d, %d, %d, %d" % tuple(e[1:6])
    if o == 0x91:
        return "\tnote2\t%d, %d, %d, %d, %d, %d, %d" % tuple(e[1:8])
    if o in CC_NAME:
        return "\t%s\t%d, %d" % (CC_NAME[o], e[1], e[2])
    raise ValueError(o)


def lane_line(lane, bank, names):
    return "\tpart_tracks\t0x%02x, %s" % (bank, ", ".join(names))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default=os.path.join(ROOT, "original_ROMs/kn5000_rhythm_data_rom.ic14"))
    ap.add_argument("--program", default=os.path.join(ROOT, "original_ROMs/kn5000_v10_program.rom"))
    ap.add_argument("--out", default=os.path.join(ROOT, "rhythm_data"))
    ap.add_argument("--stats", action="store_true")
    ap.add_argument("--check", action="store_true",
                    help="regenerate into a scratch directory and list the files that differ from --out")
    a = ap.parse_args()
    if a.check:
        import filecmp
        import subprocess
        import tempfile
        with tempfile.TemporaryDirectory(prefix="gen_rhythm_") as td:
            subprocess.run([sys.executable, __file__, "--rom", a.rom, "--program", a.program, "--out", td],
                           check=True, stdout=subprocess.DEVNULL)
            diff = []
            for dp, _, fs in os.walk(td):
                for f in fs:
                    rel = os.path.relpath(os.path.join(dp, f), td)
                    mine = os.path.join(a.out, rel)
                    if not os.path.exists(mine) or not filecmp.cmp(os.path.join(dp, f), mine, shallow=False):
                        diff.append(rel)
            print("generator output == %s" % a.out if not diff else "differs from the generator: " + " ".join(sorted(diff)))
            sys.exit(1 if diff else 0)
    d = open(a.rom, "rb").read()
    if hashlib.sha1(d).hexdigest() != SHA1:
        sys.exit("%s: SHA-1 is not %s (is it the raw read? descramble it first)" % (a.rom, SHA1))
    prog = open(a.program, "rb").read()

    # ---- (bank, program) selection of each record, from RhythmROM_BankProgramLocators (v10 = v9 = v7)
    # A zero locator is a valid pointer: it addresses the record at offset 0.  VoiceParam_BankProgramWords (the
    # remap VoiceParam_ClampAndStore applies to the pending style) sends every (bank, program) to a slot with a
    # non-zero locator except (0, 89) and (0, 90), which it sends to (0, 90), whose locator is 0.
    P = lambda a: a - 0xE00000
    loc = {}
    for bank in range(8):
        for pr in range(128):
            o = P(LOCATOR_SYM) + (bank * 128 + pr) * 4
            loc[(bank, pr)] = ((u16(prog, o) & 0xff) << 16) | u16(prog, o + 2)
    reached = set()
    for i in range(1024):
        w = u16(prog, P(REMAP_SYM) + 2 * i)
        reached.add((w >> 8, w & 0x7f))
    sel = collections.defaultdict(list)
    for key in sorted(loc):
        if loc[key] or key in reached:
            sel[loc[key]].append(key)
    unremapped = {o for o, keys in sel.items() if not any(k in reached for k in keys)}

    def panel(bank, pr):
        w = u16(prog, P(PANEL_MAP_SYM) + (pr * 8 + bank) * 2)
        g, n = w & 0xff, w >> 8
        name = prog[P(NAMES13_SYM) + (g * 20 + n) * 13:][:13].decode("latin-1").strip()
        grp = prog[P(GROUPS16_SYM) + g * 16:][:16].decode("latin-1").strip()
        return '%s %d "%s"' % (grp, n, name)

    # ---- tracks
    regions = [(N_RECORD_BYTES, (FIRST_BANK + 1) * BANK)] + \
              [(b * BANK, (b + 1) * BANK) for b in range(FIRST_BANK + 1, LAST_BANK + 1)]
    tracks = {}
    region_tracks = []
    for ra, rb in regions:
        tr, fill = parse_tracks(d, ra, rb)
        region_tracks.append((ra, rb, tr, fill))
        for s, e, ev in tr:
            tracks[s] = (e, ev)
    end_data = region_tracks[-1][3]
    if d[end_data:] != b"\xff" * (ROM_SIZE - end_data):
        sys.exit("bytes after the last bank are not all FF")

    # ---- records
    secmap = d[0:0x118]
    ids = []
    recs = []
    for r in range(0, N_RECORD_BYTES, REC):
        halves = []
        for h in (0, 1):
            base = r + h * HALF
            x = d[base:base + HALF]
            if x[0:0x118] != secmap:
                sys.exit("section map differs at 0x%06X" % base)
            if x[0x1fc:0x248] != b"\xff" * 0x4c:
                sys.exit("fill at +0x1FC differs at 0x%06X" % base)
            for k in range(8):
                blk = x[0x248 + 0x31 * k:0x248 + 0x31 * (k + 1)]
                if blk[35:] != b"\xff" * 14:
                    sys.exit("sound block tail differs at 0x%06X" % (base + 0x248 + 0x31 * k))
            if x[0x3f3:] != b"\0" * 13:
                sys.exit("tail zeros differ at 0x%06X" % base)
            ident = x[0x3db:0x3e3].decode("ascii")
            if ident[-1] != "nv"[h]:
                sys.exit("id %r at 0x%06X does not end in %s" % (ident, base, "nv"[h]))
            halves.append(x)
        sid = halves[0][0x3db:0x3e1].decode("ascii")
        if halves[1][0x3db:0x3e1].decode("ascii") != sid:
            sys.exit("halves of 0x%06X disagree on the id" % r)
        ids.append(sid)
        recs.append((r, sid, halves))
    if len(set(ids)) != len(ids):
        sys.exit("record ids are not unique")

    # ---- name tracks after their first reference (record order, half, lane, slot)
    tname = {}
    refcount = collections.Counter()
    for r, sid, halves in recs:
        for h, x in enumerate(halves):
            bank = x[0x3d1]
            for lane in range(6):
                for s in range(N_SLOTS):
                    t = bank * BANK + u16(x, 0x118 + 0x26 * lane + 2 * s)
                    if t not in tracks:
                        sys.exit("record 0x%06X half %d lane %d slot %d -> 0x%06X is not a track start"
                                 % (r, h, lane, s, t))
                    refcount[t] += 1
                    tname.setdefault(t, "Trk_%s_%s_%s_S%02d" % (sid, "NV"[h], LANES[lane], s))
    if set(tname) != set(tracks):
        sys.exit("%d tracks have no reference" % (len(tracks) - len(tname)))

    if a.stats:
        ops = collections.Counter(e[0] for _, ev in tracks.values() for e in ev)
        print("records %d, tracks %d, events %d, references %d" % (len(recs), len(tracks),
              sum(ops.values()), sum(refcount.values())))
        print({hex(k): v for k, v in sorted(ops.items())})
        return

    os.makedirs(os.path.join(a.out, "patterns"), exist_ok=True)
    blocks = {secmap[40 * k:40 * k + 40] for k in range(7)}
    if len(blocks) != 1:
        sys.exit("the 7 section-map blocks differ")
    blk = secmap[:40]
    rows = "".join("\tsec_picks\t%d, %d, %d, %d\n" % tuple(blk[5 * i:5 * i + 4]) for i in range(8))
    if any(blk[5 * i + 4] != 0x83 for i in range(8)):
        sys.exit("section-map rows do not end in 0x83")
    open(os.path.join(a.out, "rhythm_macros.inc"), "w").write(MACROS % rows)
    gen_note = "; First written by scripts/generators/gen_rhythm_data_s.py; this file is now the source.\n"

    # ---- style_records.s
    L = []
    L.append("; =============================================================================")
    L.append("; KN5000 RHYTHM DATA ROM IC14 -- STYLE RECORDS (0x400000-0x464FFF)")
    L.append("; =============================================================================")
    L.append(gen_note.rstrip())
    L.append("; 202 records of 2 KB, one per style.  A style is selected by (bank, program) (panel bytes 0xFC5B /")
    L.append("; 0xFC5A): VoiceParam_BankProgramWords remaps the pair, RhythmROM_BankProgramLocators gives the record.")
    L.append("; 201 records have a non-zero locator; the record at 0x400000 (8br86d, \"8Bt Standard\") is the one")
    L.append("; that locator [bank 0][program 90] = 0 addresses.  Its first 12 bytes are what RhythmROM_ValidateHeader")
    L.append("; checks (every record starts with them).")
    L.append("; Labels: Style_B<bank>P<program>_<id>, the (bank, program) that selects the record; <id> is the")
    L.append("; record's own id at +0x3DB without its trailing \"1n\" / \"1v\".  The comment above each record gives")
    L.append("; the panel's name for it: AccStyle_PanelRhythmTable maps (program, bank) to (rhythm group, number),")
    L.append("; AccVoice_RomRecords16 names the group and AccVoice_RomRecords13 the style (AccVoice_ComputedCopy).")
    L.append("; Each record is two halves (style_half); half 0 serves sections 0-3, half 1 sections 4-7")
    L.append("; (AccStyle_ReadParamOffset_Data: slot offsets 0..19, then 0x400..0x413).  Record layout:")
    L.append("; rhythm_macros.inc.")
    L.append("")
    for r, sid, halves in recs:
        who = sel.get(r, [])
        if not who:
            sys.exit("record 0x%06X (%s) is selected by no (bank, program)" % (r, sid))
        label = "Style_" + "_".join("B%dP%03d" % (b, p) for b, p in who) + "_" + sid
        for b, p in who:
            L.append("; %s: bank %d, program %d%s -> panel %s" % (sid, b, p, " (locator 0)" if r == 0 else "",
                                                                 panel(b, p)))
        if r in unremapped:
            L.append("; (no entry of VoiceParam_BankProgramWords, the remap SeqTick_ReadControlState applies through")
            L.append(";  VoiceParam_ClampAndStore, leads here; a reader that indexes the locators without it, such as")
            L.append(";  Rhythm_LoadCurrentTimeSig, would reach it)")
        for h, x in enumerate(halves):
            lab = label if h == 0 else label + "_V"
            bank = x[0x3d1]
            L.append("%s:" % lab)
            L.append("\tstyle_section_map")
            for lane in range(6):
                names = [tname[bank * BANK + u16(x, 0x118 + 0x26 * lane + 2 * s)] for s in range(N_SLOTS)]
                L.append(lane_line(lane, bank, names) + "\t; %s" % LANES[lane])
            L.append("\tstyle_gap_1fc")
            for k in range(8):
                blk = x[0x248 + 0x31 * k:0x248 + 0x31 * (k + 1)]
                L.append("\t; sound block %d" % k)
                for i, part in enumerate(SOUND_PARTS):
                    L.append("\tpart_sound\t%d, %d, 0x%02x, %d, %d, %d, %d\t; %s" % (tuple(blk[7 * i:7 * i + 7]) + (part,)))
                L.append("\tsound_block_end")
            t = x[0x3d0:0x3f3]
            vel = ", ".join("%d" % v for v in t[2:10])
            if t[21] != 0:
                sys.exit("+0x3E5 is not 0 at 0x%06X" % (r + h * HALF))
            L.append("\tstyle_tail\t%s, 0x%02x, %s, %d, \"%s\", %d, %d, %d, 0x%04x, 0x%04x, 0x%04x, 0x%04x, %d, %d, %d, %d"
                     % (TIMESIG[t[0]], t[1], vel, t[10], x[0x3db:0x3e3].decode("ascii"), t[19], t[20], t[22],
                        u16(t, 23), u16(t, 25), u16(t, 27), u16(t, 29), t[31], t[32], t[33], t[34]))
        L.append("")
    open(os.path.join(a.out, "style_records.s"), "w").write("\n".join(L) + "\n")

    # ---- banks
    incs = []
    for ra, rb, tr, fill in region_tracks:
        bank = ra // BANK
        fn = "patterns/bank_%02x.s" % bank
        incs.append(fn)
        P = []
        P.append("; =============================================================================")
        P.append("; KN5000 RHYTHM DATA ROM IC14 -- PATTERN BANK 0x%02X (0x%06X-0x%06X)" %
                 (bank, 0x400000 + bank * BANK, 0x400000 + bank * BANK + BANK - 1))
        P.append("; =============================================================================")
        P.append(gen_note.rstrip())
        if ra != bank * BANK:
            P.append("; The bank's first 0x%X bytes are style records (style_records.s); its tracks start here."
                     % (ra - bank * BANK))
        P.append("; %d tracks; a style record whose +0x3D1 byte is 0x%02X addresses them as (track - bank base)."
                 % (len(tr), bank))
        P.append("; Each track is named after its first reference: Trk_<style id>_<N|V half>_<part>_S<slot>.")
        P.append("")
        for s, e, ev in tr:
            P.append("%s:" % tname[s])
            P.append("\ttrk_begin")
            i = 0
            while i < len(ev):
                if ev[i][0] == 0x81:
                    j = i
                    while j < len(ev) and ev[j][0] == 0x81:
                        j += 1
                    P.append("\tbeat" if j - i == 1 else "\tbeat\t%d" % (j - i))
                    i = j
                    continue
                P.append(ev_line(ev[i]))
                i += 1
            P.append("\ttrk_end")
        P.append("")
        P.append("; unused rest of the bank: erased (FF), %d bytes" % (rb - fill))
        P.append("\t.balign\t0x10000, 0xff")
        open(os.path.join(a.out, fn), "w").write("\n".join(P) + "\n")

    T = []
    T.append("; =============================================================================")
    T.append("; KN5000 RHYTHM DATA ROM IC14 (4 MB mask ROM, main CPU 0x400000-0x7FFFFF)")
    T.append("; =============================================================================")
    T.append(gen_note.rstrip())
    T.append("; Builds the DESCRAMBLED image (SHA-1 %s);" % SHA1)
    T.append("; scripts/build/rhythm_rom_address_swap.py turns it into the chip's raw read (A19/A21 swapped).")
    T.append("; Format and evidence: notes/rhythm-data-ic14-2026-10-29/README.md.")
    T.append("")
    T.append("\t.include\t\"rhythm_macros.inc\"")
    T.append("")
    T.append("\t.section\t.text")
    T.append("RhythmData_Base:")
    T.append("\t.include\t\"style_records.s\"")
    for fn in incs:
        T.append("\t.include\t\"%s\"" % fn)
    T.append("")
    T.append("; Banks 0x%02X-0x3F: erased (FF).  AccVoice_OffsetTable has 64 bank entries, but no record names a"
             % ((end_data + BANK - 1) // BANK))
    T.append("; bank above 0x%02X and the bank 0x%02X tracks end at 0x%06X." % (LAST_BANK, LAST_BANK, 0x400000 + end_data))
    T.append("RhythmData_Erased:")
    T.append("\t.fill\t%d, 1, 0xff" % (ROM_SIZE - ((end_data + BANK - 1) // BANK) * BANK))
    open(os.path.join(a.out, "kn5000_rhythm_data.s"), "w").write("\n".join(T) + "\n")
    print("wrote %s: %d records, %d tracks, %d bank files" % (a.out, len(recs), len(tracks), len(incs)))


if __name__ == "__main__":
    main()
