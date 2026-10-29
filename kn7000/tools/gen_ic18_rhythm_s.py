#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/ic18/rhythm.s: IC18 (C3CBND000046) from 0x10000 to the end of the
# chip, the built-in "Technics Rhythms" style resource the firmware reads at
# 0x40010000, typed record by record. notes/ic18-rhythm-rom.md is the format;
# this is how the source is made from the image.
#
# Every field is written as what the firmware reads it as (big-endian: the
# firmware reads this resource through LoadU16BE / LoadU24BE / SumU16BE, although
# the MN10300 itself is little-endian):
#
#   * the header, the count block, the 2048-entry style-ID index, the 169-entry
#     style table and the 8-entry count-in table, with every offset spelled
#     symbolically (`.be24 Label - TechnicsRhythms`);
#   * each of the 169 styles: its name, its two sound-unit keys, its eight part
#     set-ups (one macro per record, every field named), its 20 slot offsets,
#     then its 20 variation records in the order they sit in the chip: header,
#     set-up events (typed, one macro per event), the event stream;
#   * the eight count-in patterns, events and all;
#   * an older build's leftovers past the last style, the erased flash and the
#     version string.
#
# Only the event streams of the 169 styles and of the leftovers are pulled from
# the reference image (`.incbin_range`), each labelled and declared
# `census: opaque -- sequence: ...`: they are the ROM's music, 3.9 MB of it, which
# this public repository does not carry in bulk. Their grammar is decoded and
# checked event by event by the generator (and by
# notes/ic18-rhythm-rom-probes/ic18_rhythm_probe.py): every stream opens with a
# beat marker, ends with 0xF5, holds bars x beats markers, and every event has
# the length RhyEventLenByStatus gives it.
#
# Inputs: the IC18 reference (baserom/kn7000_ic18.rom); program 941
# (baserom/kn7000_program.rom), for the rhythm group lists that give each style
# its group, its place in it and its style-ID; table 84 (baserom/kn7000_table.rom),
# for the names of the 51 styles that live there, which the index points to.
#
#   python3 tools/gen_ic18_rhythm_s.py --rom baserom/kn7000_ic18.rom \
#       --program baserom/kn7000_program.rom --table baserom/kn7000_table.rom \
#       --out src/ic18/rhythm.s
import argparse
import hashlib
import re
import struct
import sys

IC18_SHA1 = "2dc71f5082063cd6b21e4ed16acd67e9d326a79f"
BASE = 0x10000                  # file offset of the resource (CPU 0x40010000)
CPU = 0x40000000                # CPU address of file offset 0
PROGRAM_BASE = 0x48400000
GENRE_TABLE = 0x48735EE4        # RhythmGenreNameTable, program 941
TABLE_STYLE_SUBTABLE_DIR = 0xEC  # TableRomStyleSubTablePtr: table ROM + *(0x480000EC)
REF = "baserom/kn7000_ic18.rom"

PART_NAMES = ["Drum", "Bass", "Acc1", "Acc2", "Acc3", "Acc4", "Acc5", "Perc"]
SLOT_NAMES = ["Var1", "Var1Fill1", "Var1Fill2", "Var2", "Var2Fill1", "Var2Fill2",
              "Var3", "Var3Fill1", "Var3Fill2", "Var4", "Var4Fill1", "Var4Fill2",
              "Intro1A", "Intro1B", "Intro2A", "Intro2B",
              "Ending1A", "Ending1B", "Ending2A", "Ending2B"]


class Img:
    def __init__(self, data):
        self.d = data

    def u16(self, o):
        return (self.d[o] << 8) | self.d[o + 1]

    def u24(self, o):
        return (self.d[o] << 16) | (self.d[o + 1] << 8) | self.d[o + 2]


def ev_len(d, o):
    """RhyEventLenByStatus / RhySysexLen (program 941 0x484403D5 / 0x484403CD)."""
    s = d[o]
    if s == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(s & 0xF0, 1)


def check_stream(d, s, e, beats_wanted, what):
    """The stream d[s:e] parses as events: opens with 0xF4, ends with 0xF5 at
    e-1, every data byte < 0x80, every position byte 0..95 and rising within a
    beat, and bars*beats 0xF4 markers."""
    if d[s] != 0xF4 or d[e - 1] != 0xF5:
        raise SystemExit(f"{what}: stream does not open with F4 / end with F5")
    p, beats, last = s, 0, -1
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        if c == 0xF4:
            beats, last = beats + 1, -1
        elif c < 0x80:
            if c > 95 or c < last:
                raise SystemExit(f"{what}: position byte {c} at {p:#x}")
            last = c
        elif c != 0xF5 and any(b >= 0x80 for b in d[p + 1:p + n]):
            raise SystemExit(f"{what}: data byte >= 0x80 in event at {p:#x}")
        p += n
    if p != e:
        raise SystemExit(f"{what}: events overrun the stream end ({p:#x} != {e:#x})")
    if beats != beats_wanted:
        raise SystemExit(f"{what}: {beats} beat markers, want {beats_wanted}")


def label_of(name, used):
    base = name.replace("&", "And").replace("'n'", "n").replace("'", "")
    base = re.sub(r"[^A-Za-z0-9]", "", base)
    lab = "Style_" + base
    n = 2
    while lab in used:
        lab = f"Style_{base}_{n}"
        n += 1
    used.add(lab)
    return lab


def sid_of_entry(i):
    """Index entry i <- style-ID: StyleNameSourceSet folds the ID with
    ((id & 0x0F00) >> 1) | (id & 0x7F)."""
    return ((i & 0x780) << 1) | (i & 0x7F)


def hx(v):
    return f"0x{v:02x}"


def setup_lines(d, s, e, what):
    out = []
    p = s
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        a = list(d[p + 1:p + n])
        if c & 0xF0 == 0xB0:
            out.append(f"\tev_cc\t{c & 15}, {a[0]}, {a[1]}")
        elif c & 0xF0 == 0xC0:
            out.append(f"\tev_pc\t{c & 15}, {hx(a[0])}, {hx(a[1])}, {hx(a[2])}")
        else:
            raise SystemExit(f"{what}: set-up event {c:#x} not typed")
        p += n
    if p != e:
        raise SystemExit(f"{what}: set-up events overrun")
    return out


def stream_lines(d, s, e):
    """Fully typed events (used for the eight short count-in patterns)."""
    out = []
    p = s
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        a = list(d[p + 1:p + n])
        if c == 0xF4:
            out.append("\tev_beat")
        elif c == 0xF5:
            out.append("\tev_end")
        elif c < 0x80:
            out.append(f"\tev_at\t{c}")
        elif c & 0xF0 == 0x90:
            out.append(f"\tev_note\t{c & 15}, {a[0]}, {a[1]}, {a[2]}, {a[3]}, {a[4]}")
        else:
            raise SystemExit(f"count-in event {c:#x} not typed")
        p += n
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", required=True)
    ap.add_argument("--program", required=True)
    ap.add_argument("--table", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    data = open(args.rom, "rb").read()
    if hashlib.sha1(data).hexdigest() != IC18_SHA1:
        raise SystemExit(f"{args.rom}: not the IC18 reference (SHA-1 {IC18_SHA1})")
    im = Img(data)
    d = data
    prog = open(args.program, "rb").read()
    table = open(args.table, "rb").read()

    # ---- header -----------------------------------------------------------
    if d[BASE:BASE + 16] != b"Technics Rhythms":
        raise SystemExit("no signature at 0x10000")
    ck = im.u16(BASE + 0x10)
    ck_start, ck_len = im.u24(BASE + 0x12), im.u24(BASE + 0x15)
    o_count, o_index, o_styles, o_countin, o_fallback = (im.u24(BASE + x) for x in (0x18, 0x1B, 0x1E, 0x21, 0x24))
    calc = sum(struct.unpack_from(f">{ck_len}H", d, BASE + ck_start)) & 0xFFFF
    if calc != ck:
        raise SystemExit("checksum does not match")
    if (o_count, o_index) != (0x27, 0x33) or o_styles != o_index + 0x1000:
        raise SystemExit("unexpected header layout")
    count = im.u16(BASE + o_count + 2)
    nstyles = (o_countin - o_styles) // 3
    styles = [im.u24(BASE + o_styles + 3 * i) for i in range(nstyles)]
    countins = [im.u24(BASE + o_countin + 3 * k) for k in range(8)]
    if countins[0] != o_countin + 24 or styles[0] != o_fallback:
        raise SystemExit("unexpected table layout")
    index = [im.u16(BASE + o_index + 2 * i) for i in range(0x800)]

    # ---- program 941: the rhythm groups -------------------------------------
    genre_of = {}
    go = GENRE_TABLE - PROGRAM_BASE
    for g in range(16):
        rec = prog[go + g * 0x18:go + g * 0x18 + 0x18]
        gname = rec[:16].decode("ascii").strip()
        n = rec[0x11]
        ptr = struct.unpack_from("<I", rec, 0x14)[0] - PROGRAM_BASE
        for k in range(n):
            sid = struct.unpack_from("<I", prog, ptr + 4 * k)[0]
            if sid & 0x00700000:   # a MEMORY or CUSTOM style (StyleNameSourceSet)
                continue
            i = ((sid & 0xF00) >> 1) | (sid & 0x7F)
            e = index[i]
            if e >> 14 == 2:
                e = index[e & 0x7FF]
            if e < nstyles and e not in genre_of:
                genre_of[e] = (gname, k + 1, n, sid)
    # ---- table 84: the styles the index sends to the table ROM ---------------
    sub = struct.unpack_from("<I", table, TABLE_STYLE_SUBTABLE_DIR)[0]
    tnames = []
    for k in range(64):
        off = (table[sub + 3 * k] << 16) | (table[sub + 3 * k + 1] << 8) | table[sub + 3 * k + 2]
        nm = table[sub + off:sub + off + 13]
        if off == 0 or sub + off + 13 > len(table) or not all(0x20 <= b < 0x7F for b in nm):
            break
        tnames.append(nm.decode("ascii"))

    # ---- styles ---------------------------------------------------------------
    used = set()
    out = []
    w = out.append
    labels = []
    for i, r in enumerate(styles):
        nm = d[BASE + r:BASE + r + 13]
        if not all(0x20 <= b < 0x7F and b != 0x22 and b != 0x5C for b in nm):
            raise SystemExit(f"style {i}: name {nm!r} is not plain ASCII")
        labels.append(label_of(nm.decode("ascii").strip(), used))
    ends = styles[1:] + [None]

    def var_record(lab, o, slotname, what):
        """o = file offset of a variation record -> its source lines and its end."""
        bars, beats = d[o] + 1, d[o + 1] + 1
        if d[o + 1] > 7:
            raise SystemExit(f"{what}: meter byte {d[o + 1]:#x}")
        L = im.u16(o + 4)
        S = im.u24(o + 6 + L)
        s = o + 9 + L
        e = s + S
        check_stream(d, s, e, bars * beats, what)
        v = f"{lab}_{slotname}" if slotname else lab
        lines = [f"{v}:",
                 f"\tvar_head\t{v}, {bars}, {beats}, {hx(d[o + 2])}, {hx(d[o + 3])}"]
        lines += setup_lines(d, o + 6, o + 6 + L, what)
        lines.append(f"\tvar_events\t{v}")
        return v, s, e, lines, bars, beats

    style_src = []
    for i, r in enumerate(styles):
        o = BASE + r
        lab = labels[i]
        nm = d[o:o + 13].decode("ascii")
        g = genre_of.get(i)
        offs = [im.u24(o + 0x8A + 3 * j) for j in range(20)]
        if d[o + 0x89] != 1 or min(offs) != 0xC6 or len(set(offs)) != 20:
            raise SystemExit(f"style {i}: unexpected record layout")
        S = style_src.append
        S("")
        S("# " + "-" * 92)
        if g:
            S(f'# Style {i}: "{nm.strip()}", {g[0]} {g[1]} of {g[2]}, style-ID 0x{g[3]:03x}')
        else:
            S(f'# Style {i}: "{nm.strip()}"')
        S(f"{lab}:")
        S(f'\t.ascii\t"{nm}"')
        S(f"\tstyle_units\t{hx(d[o + 13])}, {hx(d[o + 14])}, {hx(d[o + 15])}, {hx(d[o + 16])}")
        for p in range(8):
            f = d[o + 0x11 + 15 * p:o + 0x11 + 15 * p + 15]
            vals = [hx(f[0]), str(f[1]), hx(f[2]), hx(f[3]), hx(f[4])] + [str(x) for x in f[5:]]
            S(f"\tstyle_part\t{', '.join(vals)}\t# {PART_NAMES[p]}")
        S("\t.byte\t1\t\t\t# TODO: 1 in every style; no reader found")
        S(f"\tstyle_slots\t{lab}")
        pos = o + 0xC6
        for off in sorted(offs):
            j = offs.index(off)
            if o + off != pos:
                raise SystemExit(f"style {i}: gap before slot {j}")
            v, s, e, lines, bars, beats = var_record(lab, o + off, SLOT_NAMES[j], f"style {i} slot {j}")
            style_src += lines
            S(f'{v}_Events:\t.incbin_range\t"{REF}", 0x{s:06x}, 0x{e:06x}'
              f"\t# census: opaque -- sequence: {bars} bars of {beats} beats, {e - s} bytes of pattern events")
            S(f"\tvar_end\t{v}")
            pos = e
        nxt = BASE + ends[i] if ends[i] is not None else None
        if nxt is not None and pos != nxt:
            raise SystemExit(f"style {i}: ends at {pos:#x}, next starts at {nxt:#x}")
    last_end = pos

    # ---- the leftovers past the last style ------------------------------------
    old_slots = ["Var3", "Var3Fill1", "Var3Fill2", "Var4", "Var4Fill1", "Var4Fill2",
                 "Intro2A", "Intro2B", "Ending2A", "Ending2B"]
    tail_src = []
    T = tail_src.append
    f0_end = d.index(b"\xf5", last_end) + 1
    T("")
    T("# " + "=" * 92)
    T("# Past the last style: an older build's data, which nothing in the directory reaches.")
    T("# First the end of an event stream whose start the current data overwrote, then ten whole")
    T("# variation records of a style that is not in this build. [INFERENCE] By their bar counts")
    T("# (4,1,1, 4,1,1, then two equal pairs) and the order every style here stores its slots in,")
    T("# they are slots Var3..Var4Fill2, Intro2A/B and Ending2A/B of that style, and the fragment")
    T("# before them the end of its Var2Fill2. Then two shorter fragments of event streams, the")
    T("# second a copy of the first one's last 135 bytes.")
    T(f'OldBuildStyle_Var2Fill2_Tail:\t.incbin_range\t"{REF}", 0x{last_end:06x}, 0x{f0_end:06x}'
      f"\t# census: opaque -- sequence: the end of an older build's pattern events, cut at its start")
    pos = f0_end
    for k, sl in enumerate(old_slots):
        v, s, e, lines, bars, beats = var_record("OldBuildStyle", pos, sl, f"leftover {k}")
        tail_src += lines
        T(f'{v}_Events:\t.incbin_range\t"{REF}", 0x{s:06x}, 0x{e:06x}'
          f"\t# census: opaque -- sequence: {bars} bars of {beats} beats, {e - s} bytes of pattern events")
        T(f"\tvar_end\t{v}")
        pos = e
    used_end = len(d[:0x3FFFE8].rstrip(b"\xff"))
    f1_end = d.index(b"\xf5", pos) + 1
    if d[f1_end:used_end] != d[f1_end - (used_end - f1_end):f1_end]:
        raise SystemExit("the last fragment is not a copy of the end of the one before")
    T(f'OldBuildFragment1:\t.incbin_range\t"{REF}", 0x{pos:06x}, 0x{f1_end:06x}'
      f"\t# census: opaque -- sequence: older pattern events, starting inside a note event")
    T(f'OldBuildFragment2:\t.incbin_range\t"{REF}", 0x{f1_end:06x}, 0x{used_end:06x}'
      f"\t# census: opaque -- sequence: the last {used_end - f1_end} bytes of OldBuildFragment1 again")
    if d[used_end:0x3FFFE8] != b"\xff" * (0x3FFFE8 - used_end):
        raise SystemExit("not erased before the version string")
    ver = d[0x3FFFE8:0x3FFFF2]
    if ver != b"jkr_33.ssf" or d[0x3FFFF2:0x3FFFF8] != bytes(6) or d[0x3FFFF8:] != b"\xff" * 8:
        raise SystemExit("unexpected top of chip")
    T("")
    T(f"\t.space\t0x{0x3FFFE8 - used_end:x}, 0xff\t\t# erased")
    T("# The version of this data: AcRhythmVerBoxProc (program 941) reads the two digits at")
    T("# 0x3FFFEC and shows them as RHYTHM 33 on the SP7001 DEBUG TOOLS screen.")
    T("RhythmRomVersion:")
    T('\t.ascii\t"jkr_33.ssf"')
    T("\t.space\t6\t\t\t# NUL padding to 16 bytes")
    T("\t.space\t8, 0xff\t\t\t# erased")
    T(".org 0x400000")

    # ---- the directory ----------------------------------------------------------
    w("# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>")
    w("# Licensed under the terms of the GNU General Public License v3 or later")
    w("#")
    w("# IC18 (C3CBND000046) from 0x10000 to the end: the built-in \"Technics Rhythms\" style")
    w("# resource, which the firmware finds at 0x40010000 (StyleResourceWindowProbe, its third")
    w("# window) and opens with StyleBuiltinNameTableInit. GENERATED by tools/gen_ic18_rhythm_s.py")
    w("# (`make ic18-rhythm-src`); notes/ic18-rhythm-rom.md is the format and its evidence.")
    w(f"#   {nstyles} styles x 20 variations, 8 count-in patterns; {count} rhythms in all with the")
    w(f"#   {count - nstyles} that live in the table ROM.")
    w("#")
    w("# Every multi-byte field is BIG-endian (.be16/.be24): the firmware reads this resource")
    w("# through LoadU16BE / LoadU24BE / SumU16BE, although the MN10300 is little-endian.")
    w("# Offsets are from the resource start, TechnicsRhythms.")
    w("#")
    w("# The event streams of the styles are pulled from the reference image, one labelled")
    w("# .incbin_range each: they are the ROM's music, which this public repository does not")
    w("# carry in bulk. The generator checks every one of them event by event.")
    w("")
    w(".mnbase 0x40000000")
    w("")
    w("# ---- record macros ----------------------------------------------------------------")
    w("# A part set-up (15 bytes): each byte is the value of one controller, in the order of")
    w("# the firmware's field table 0x485B77D4 (CC -> field map 0x485B781C). The firmware")
    w("# copies the eight of a style into the part table 0x5003A37C (func_4844187A); the")
    w("# set-up events of a variation then overwrite single fields (func_48441EB4).")
    w("#   mode     CC97; 0x00 on the two drum parts, 0x08 on the others   [INFERENCE: role]")
    w("#   volume   CC7")
    w("#   prog, bank_lsb, bank_msb   the three data bytes of the part's program change")
    w("#            (StyleRecordToTemplate); bank_msb is 0x26 on the drum parts, 0x20 on the")
    w("#            others. [INFERENCE] the names of the two bank bytes")
    w("#   cc94     CC94          reverb   CC91          chorus   CC93          pan   CC10")
    w("#   cc96, cc82, cc83, cc80, cc81, cc92   those controllers")
    w(".macro style_part mode, volume, prog, bank_lsb, bank_msb, cc94, reverb, chorus, pan, cc96, cc82, cc83, cc80, cc81, cc92")
    w("\t.byte\t\\mode, \\volume, \\prog, \\bank_lsb, \\bank_msb, \\cc94, \\reverb, \\chorus, \\pan")
    w("\t.byte\t\\cc96, \\cc82, \\cc83, \\cc80, \\cc81, \\cc92")
    w(".endm")
    w("# The two sound-unit keys of a style (record +0x0D, 4 bytes; func_484420EF): each pair is")
    w("# a 14-bit value, 7 bits a byte, low byte first (bit 6 of the second byte adds 0x10000);")
    w("# they are stored to parameter keys 0xB044 and 0xB054, the sound-unit groups 0xB040 and")
    w("# 0xB050 (SndUnitRefreshGroups56). Bit 7 of the second byte goes to key 0xB001.")
    w(".macro style_units unit5_lo, unit5_hi, unit6_lo, unit6_hi")
    w("\t.byte\t\\unit5_lo, \\unit5_hi, \\unit6_lo, \\unit6_hi")
    w(".endm")
    w("# The 20 slot offsets of a style (record +0x8A, from the record): StyleNameCommit loads")
    w("# them into 0x50034BCC[]. Slots 0-11 are four variations, each a main pattern and two")
    w("# fill-ins (only slot % 3 == 0 has a name in a MEMORY style: MemStyleVarCopy); 12-19 are")
    w("# four A/B pairs, 12-15 intros, 16-19 endings (func_4844232B tells (slot - 12) % 4 < 2,")
    w("# number 1, from number 2). [INFERENCE] the intro/ending and fill-in roles")
    w(".macro style_slots s")
    w("\t.be24\t\\s_Var1 - \\s, \\s_Var1Fill1 - \\s, \\s_Var1Fill2 - \\s")
    w("\t.be24\t\\s_Var2 - \\s, \\s_Var2Fill1 - \\s, \\s_Var2Fill2 - \\s")
    w("\t.be24\t\\s_Var3 - \\s, \\s_Var3Fill1 - \\s, \\s_Var3Fill2 - \\s")
    w("\t.be24\t\\s_Var4 - \\s, \\s_Var4Fill1 - \\s, \\s_Var4Fill2 - \\s")
    w("\t.be24\t\\s_Intro1A - \\s, \\s_Intro1B - \\s, \\s_Intro2A - \\s, \\s_Intro2B - \\s")
    w("\t.be24\t\\s_Ending1A - \\s, \\s_Ending1B - \\s, \\s_Ending2A - \\s, \\s_Ending2B - \\s")
    w(".endm")
    w("# A variation record (StyleRecordBindBuiltin): bars - 1 (-> 0x50122DCE), beats a bar - 1")
    w("# (-> 0x50122DCF; StyleBoundRecByteCfLow3), two part numbers for the sound units (0xFF =")
    w("# none; func_48442164, key 0xB048 [INFERENCE: the role]), the length of the set-up")
    w("# events, the events; then the length of the event stream and the stream.")
    w(".macro var_head v, bars, beats, unit_part_a, unit_part_b")
    w("\t.byte\t\\bars - 1, \\beats - 1, \\unit_part_a, \\unit_part_b")
    w("\t.be16\t\\v_SetupEnd - \\v_Setup")
    w("\\v_Setup:")
    w(".endm")
    w(".macro var_events v")
    w("\\v_SetupEnd:")
    w("\t.be24\t\\v_EventsEnd - \\v_Events")
    w(".endm")
    w(".macro var_end v")
    w("\\v_EventsEnd:")
    w(".endm")
    w("# Events (RhyEventLenByStatus): the low nibble of a status byte is the part, 0-7.")
    w(".macro ev_cc part, ctl, value")
    w("\t.byte\t0xb0 + \\part, \\ctl, \\value")
    w(".endm")
    w(".macro ev_pc part, prog, bank_lsb, bank_msb")
    w("\t.byte\t0xc0 + \\part, \\prog, \\bank_lsb, \\bank_msb")
    w(".endm")
    w("# A note: key, velocity, then three bytes. [INFERENCE] gate_lo/gate_hi a 14-bit length")
    w("# and `rule` the chord-adaptation class: it is 0 on every note of the two drum parts.")
    w(".macro ev_note part, key, velocity, gate_lo, gate_hi, rule")
    w("\t.byte\t0x90 + \\part, \\key, \\velocity, \\gate_lo, \\gate_hi, \\rule")
    w(".endm")
    w("# A position byte: the tick in the beat (0-95, 96 a beat) of the events after it.")
    w(".macro ev_at tick")
    w("\t.byte\t\\tick")
    w(".endm")
    w(".macro ev_beat")
    w("\t.byte\t0xf4")
    w(".endm")
    w(".macro ev_end")
    w("\t.byte\t0xf5")
    w(".endm")
    w(".macro sidx_style no")
    w("\t.be16\t\\no")
    w(".endm")
    w(".macro sidx_alias entry")
    w("\t.be16\t0x8000 + \\entry")
    w(".endm")
    w(".macro sidx_table no")
    w("\t.be16\t0x4000 + \\no")
    w(".endm")
    w("")
    w("# ---- the header (StyleBuiltinNameTableInit, StyleResourceVerify) -----------------")
    w(".org 0x10000")
    w("TechnicsRhythms:")
    w('\t.ascii\t"Technics Rhythms"\t\t# strncmp with the firmware\'s 0x4872980C')
    w(f"\t.be16\t0x{ck:04x}\t\t\t# SumU16BE of the halfwords below, StyleResourceVerify")
    w(f"\t.be24\t0x{ck_start:06x}\t\t\t# checksum start, from TechnicsRhythms: file 0x{BASE + ck_start:x}, inside a stream")
    w(f"\t.be24\t0x{ck_len:06x}\t\t\t# checksum length in halfwords (2 MB)")
    w("\t.be24\tRhythmCountBlock - TechnicsRhythms")
    w("\t.be24\tRhythmStyleIndex - TechnicsRhythms\t# -> 0x50034B7C")
    w("\t.be24\tRhythmStyleTable - TechnicsRhythms\t# -> 0x50034B80")
    w("\t.be24\tRhythmCountInTable - TechnicsRhythms\t# -> 0x50034B84")
    w(f"\t.be24\t{labels[0]} - TechnicsRhythms\t# -> 0x50034B88, the fallback style")
    w("RhythmCountBlock:")
    blk = d[BASE + o_count:BASE + o_index]
    if im.u16(BASE + o_count) != 0 or im.u16(BASE + o_count + 4) != 96:
        raise SystemExit("unexpected count block")
    w("\t.be16\t0\t\t\t# TODO: not read")
    w(f"\t.be16\t{count}\t\t\t# the rhythm count -> 0x50034B74; the index's limit")
    w("\t.be16\t96\t\t\t# [INFERENCE] ticks a beat: every position byte of every stream is 0..95")
    w(f"\t.byte\t{', '.join(str(x) for x in blk[6:])}\t# [INFERENCE] name length 13, 8 parts, 4 variations, 2 fill-ins, 2 intros,")
    w("\t\t\t\t\t# 2 endings (4 + 4x2 + 2x2 + 2x2 = 20 slots); nothing reads them")
    w("")
    w("# ---- the style-ID index (StyleBuiltinNameResolve) --------------------------------")
    w("# 2048 entries; entry ((id & 0x0F00) >> 1) | (id & 0x7F) serves style-ID id. An entry")
    w(f"# below {count} is a style of this table, 0x8000 + n sends the ID to entry n, 0x4000 + n to")
    w("# style n of the table ROM's secondary sub-table (TableRomStyleSubTablePtr). Every ID")
    w("# resolves to some style.")
    for i, r in enumerate(styles):
        w(f".equ SNo_{labels[i][6:]}, {i}")
    w("RhythmStyleIndex:")
    for i, e in enumerate(index):
        if i % 128 == 0:
            w(f"# style-IDs 0x{sid_of_entry(i):03x}-0x{sid_of_entry(i + 127):03x}")
        sid = sid_of_entry(i)
        if e < nstyles:
            w(f"\tsidx_style\tSNo_{labels[e][6:]}\t# id 0x{sid:03x}")
        elif e >> 14 == 2:
            t = e & 0x7FF
            w(f"\tsidx_alias\t0x{t:03x}\t\t# id 0x{sid:03x} -> id 0x{sid_of_entry(t):03x}")
        elif e >> 14 == 1:
            t = e & 0x3FFF
            nm = f' "{tnames[t].strip()}"' if t < len(tnames) else ""
            w(f"\tsidx_table\t{t}\t\t# id 0x{sid:03x}: table ROM style {t}{nm}")
        else:
            raise SystemExit(f"index entry {i}: {e:#x}")
    w("")
    w("# ---- the style table: 3-byte offsets (StyleBuiltinNameResolve) -------------------")
    w("RhythmStyleTable:")
    for i in range(nstyles):
        w(f"\t.be24\t{labels[i]} - TechnicsRhythms")
    w("")
    w("# ---- the count-in patterns, one per meter (StyleVariationNameGet) ---------------")
    w("# Slot 20 of StyleRecordSlotSelect: the low 3 bits of the bound variation's meter byte")
    w("# pick one (unless resource 0xD00A answers, then the program's table 0x48736078).")
    w("RhythmCountInTable:")
    for k in range(8):
        w(f"\t.be24\tCountIn_{k + 1}Beats - TechnicsRhythms")
    pos = BASE + o_countin + 24
    for k in range(8):
        o = BASE + countins[k]
        if o != pos:
            raise SystemExit(f"count-in {k} does not follow the one before")
        v, s, e, lines, bars, beats = var_record(f"CountIn_{k + 1}Beats", o, None, f"count-in {k}")
        if (bars, beats) != (1, k + 1):
            raise SystemExit(f"count-in {k}: {bars} bars of {beats}")
        out += lines
        w(f"{v}_Events:")
        out += stream_lines(d, s, e)
        w(f"\tvar_end\t{v}")
        pos = e
    if pos != BASE + styles[0]:
        raise SystemExit("count-in patterns do not end at the first style")
    out += style_src
    out += tail_src
    open(args.out, "w").write("\n".join(out) + "\n")
    print(f"{args.out}: {len(out)} lines, {nstyles} styles, {len(genre_of)} in a rhythm group,"
          f" {len(tnames)} table-ROM names")


if __name__ == "__main__":
    sys.exit(main())
