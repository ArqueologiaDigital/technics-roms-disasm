#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""gen_table_styles.py -- the table flash's style data, typed event by event.

Used by tools/gen_table_s.py for two directory segments of the table flash (builds 84
and 83), both in the "Technics Rhythms" style format that notes/ic18-rhythm-rom.md
documents for IC18 (lane kn7000-ic18; the same macro names are used here):

  * segment 59, BuiltinStyleSubTable (TableRomStyleSubTablePtr 0x4843D797): u24BE
    offsets to the styles the style-ID index sends to the table ROM (index entry
    0x4000 + n = style n; StyleBuiltinNameResolve 0x48433ABF), then the styles: each a
    0xC6-byte record and its 20 variation records, each with its set-up events and its
    event stream;
  * segment 83, TechnicsRhythmsTable (TableRomStyleResourcePtr 0x4843D7A8): a copy of
    IC18's header, count block, style-ID index, style table and count-in table, which
    StyleBuiltinNameTableInit re-points the index at (notes/ic18-rhythm-rom.md, "The
    table ROM's copy").  Its style-table offsets point into IC18, not into this image.

Each style goes to its own include file, src/table/styles/<Name>.s (a build whose
style differs from the file already there gets src/table/styles/b<build>/<Name>.s).
Every event is one macro line (src/table/style_macros.inc); every stream is checked
as notes/ic18-rhythm-rom.md describes (opens with a beat marker, ends with 0xF5,
bars x beats markers, every event the length RhyEventLenByStatus 0x484403D5 gives).
"""
import os
import re
import struct

PART_NAMES = ["Drum", "Bass", "Acc1", "Acc2", "Acc3", "Acc4", "Acc5", "Perc"]
SLOT_NAMES = ["Var1", "Var1Fill1", "Var1Fill2", "Var2", "Var2Fill1", "Var2Fill2",
              "Var3", "Var3Fill1", "Var3Fill2", "Var4", "Var4Fill1", "Var4Fill2",
              "Intro1A", "Intro1B", "Intro2A", "Intro2B",
              "Ending1A", "Ending1B", "Ending2A", "Ending2B"]
MACROS = "src/table/style_macros.inc"
STYLE_DIR = "styles"            # under the --jpg-dir (src/table)


def u16be(d, o):
    return (d[o] << 8) | d[o + 1]


def u24be(d, o):
    return (d[o] << 16) | (d[o + 1] << 8) | d[o + 2]


def ev_len(d, o):
    """RhyEventLenByStatus / RhySysexLen (program 941 0x484403D5 / 0x484403CD)."""
    s = d[o]
    if s == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(s & 0xF0, 1)


def hx(v):
    return f"0x{v:02x}"


def event_lines(d, s, e, what, beats_wanted=None):
    """The events d[s:e], one macro per line; checks the stream grammar."""
    out, p, beats, last = [], s, 0, -1
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        a = list(d[p + 1:p + n])
        if c != 0xF5 and c >= 0x80 and any(b >= 0x80 for b in (a[1:] if c == 0xF0 else a)):
            raise SystemExit(f"{what}: data byte >= 0x80 in event at {p:#x}")
        if c < 0x80:
            if c > 95 or c < last:
                raise SystemExit(f"{what}: position byte {c} at {p:#x}")
            last = c
            out.append(f"\tev_at\t{c}")
        elif c == 0xF4:
            beats, last = beats + 1, -1
            out.append("\tev_beat")
        elif c == 0xF5:
            out.append("\tev_end")
        elif c == 0xF0:
            out.append(f"\tev_sysex\t{a[0]}")
            out.append(f"\t.byte\t{', '.join(hx(x) for x in a[1:])}")
        elif c & 0xF0 == 0x90:
            out.append(f"\tev_note\t{c & 15}, {a[0]}, {a[1]}, {a[2]}, {a[3]}, {a[4]}")
        elif c & 0xF0 == 0xB0:
            out.append(f"\tev_cc\t{c & 15}, {a[0]}, {a[1]}")
        elif c & 0xF0 == 0xC0:
            out.append(f"\tev_pc\t{c & 15}, {hx(a[0])}, {hx(a[1])}, {hx(a[2])}")
        elif c & 0xF0 == 0xD0:
            out.append(f"\tev_press\t{c & 15}, {a[0]}")
        elif c & 0xF0 == 0xE0:
            out.append(f"\tev_bend\t{c & 15}, {a[0]}, {a[1]}")
        else:
            raise SystemExit(f"{what}: event {c:#x} at {p:#x} has no type")
        p += n
    if p != e:
        raise SystemExit(f"{what}: events overrun the end ({p:#x} != {e:#x})")
    if beats_wanted is not None:
        if d[s] != 0xF4 or d[e - 1] != 0xF5:
            raise SystemExit(f"{what}: stream does not open with F4 / end with F5")
        if beats != beats_wanted:
            raise SystemExit(f"{what}: {beats} beat markers, want {beats_wanted}")
    return out


def label_of(name, used):
    base = name.replace("&", "And").replace("'n'", "n").replace("'", "")
    base = re.sub(r"[^A-Za-z0-9]", "", base)
    lab, n = "Style_" + base, 2
    while lab in used:
        lab = f"Style_{base}_{n}"
        n += 1
    used.add(lab)
    return lab


def variation(d, o, v, what):
    """-> (lines, end) for the variation record at file offset o, labelled v."""
    bars, beats = d[o] + 1, d[o + 1] + 1
    if d[o + 1] > 7:
        raise SystemExit(f"{what}: meter byte {d[o + 1]:#x}")
    L = u16be(d, o + 4)
    S = u24be(d, o + 6 + L)
    s = o + 9 + L
    lines = [f"{v}:", f"\tvar_head\t{v}, {bars}, {beats}, {hx(d[o + 2])}, {hx(d[o + 3])}"]
    setup = event_lines(d, o + 6, o + 6 + L, what + " set-up")
    if any(not (x.startswith("\tev_cc") or x.startswith("\tev_pc")) for x in setup):
        raise SystemExit(f"{what}: a set-up event other than CC / program change")
    lines += setup
    lines += [f"\tvar_events\t{v}",
              f"{v}_Events:\t\t# {bars} bars of {beats} beats, {S} bytes"]
    lines += event_lines(d, s, s + S, what, bars * beats)
    lines.append(f"\tvar_end\t{v}")
    return lines, s + S


def style_file(d, o, lab, what, heading):
    """-> (text of the include file for the style record at file offset o, its end)."""
    nm = d[o:o + 13]
    offs = [u24be(d, o + 0x8A + 3 * j) for j in range(20)]
    if d[o + 0x89] != 1 or min(offs) != 0xC6 or len(set(offs)) != 20:
        raise SystemExit(f"{what}: unexpected record layout")
    L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#",
         f"# {heading}",
         "# GENERATED by tools/gen_table_styles.py (make table-src) -- the format is",
         "# notes/ic18-rhythm-rom.md; the macros are src/table/style_macros.inc.",
         "",
         f"{lab}:",
         f'\t.ascii\t"{nm.decode("ascii")}"',
         f"\tstyle_units\t{', '.join(hx(x) for x in d[o + 13:o + 17])}"]
    for p in range(8):
        f = d[o + 0x11 + 15 * p:o + 0x11 + 15 * p + 15]
        vals = [hx(f[0]), str(f[1]), hx(f[2]), hx(f[3]), hx(f[4])] + [str(x) for x in f[5:]]
        L.append(f"\tstyle_part\t{', '.join(vals)}\t# {PART_NAMES[p]}")
    L += ["\t.byte\t1\t\t\t# 1 in every style; no reader found", f"\tstyle_slots\t{lab}"]
    pos = o + 0xC6
    for off in sorted(offs):
        j = offs.index(off)
        if o + off != pos:
            raise SystemExit(f"{what}: gap before slot {j}")
        lines, pos = variation(d, pos, f"{lab}_{SLOT_NAMES[j]}", f"{what} slot {j}")
        L += [""] + lines
    return "\n".join(L) + "\n", pos


def put_style(jpg_dir, build, name, text):
    """Write the include file for a style; -> the path the source includes.  The plain
    name belongs to the first build that wrote it; another build's different style of
    the same name goes to styles/b<build>/."""
    for rel in (f"{STYLE_DIR}/{name}.s", f"{STYLE_DIR}/b{build}/{name}.s"):
        path = os.path.join(jpg_dir, rel)
        if os.path.exists(path):
            if open(path).read() == text:
                return path
            continue
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, "w").write(text)
        return path
    raise SystemExit(f"gen_table_styles: {name}: both include files exist with other text")


def subtable_names(d, s):
    """-> the style names of a segment-59 sub-table at file offset s."""
    n = u24be(d, s) // 3
    return [d[s + u24be(d, s + 3 * k):s + u24be(d, s + 3 * k) + 13].decode("ascii") for k in range(n)]


def style_subtable(d, s, e, label, jpg_dir, build):
    """Segment 59 -> its lines in the table source (and the per-style include files)."""
    n = u24be(d, s) // 3
    offs = [u24be(d, s + 3 * k) for k in range(n)]
    used = set()
    labs = [label_of(nm.strip(), used) for nm in subtable_names(d, s)]
    B = ["    # u24BE offsets from the segment start, one per style: index entry 0x4000 + n",
         "    # of the style-ID index sends a style-ID to style n (StyleBuiltinNameResolve)."]
    for k in range(n):
        B.append(f"    .be24\t{labs[k]} - {label}\t# style {k}")
    pos = s + 3 * n
    for k in range(n):
        o = s + offs[k]
        if o != pos:
            raise SystemExit(f"{label}: style {k} does not follow the one before")
        nm = d[o:o + 13].decode("ascii").strip()
        text, pos = style_file(d, o, labs[k], f"table {build} style {k}",
                               f'Table ROM style {k}: "{nm}" '
                               f"(BuiltinStyleSubTable, index entry 0x4000 + {k}).")
        path = put_style(jpg_dir, build, labs[k][6:], text)
        B.append(f'    .include\t"{path}"')
    if d[pos:e] != bytes(e - pos):
        raise SystemExit(f"{label}: non-zero bytes after the last style")
    if e > pos:
        B.append(f"    .space\t{e - pos}, 0x00")
    return B


def rhythms_copy(d, s, e, label, sub_names):
    """Segment 83 (build 84): the copy of IC18's header, count block, index, style table
    and count-in table.  Offsets inside the copy are label differences; the style and
    count-in offsets point into IC18 and stay numbers."""
    if d[s:s + 16] != b"Technics Rhythms":
        raise SystemExit(f"{label}: no signature")
    o_cnt, o_idx, o_sty, o_cin, o_fb = (u24be(d, s + x) for x in (0x18, 0x1B, 0x1E, 0x21, 0x24))
    if (o_cnt, o_idx, o_sty) != (0x27, 0x33, 0x1033) or u16be(d, s + 0x10) or u24be(d, s + 0x12) \
            or u24be(d, s + 0x15):
        raise SystemExit(f"{label}: unexpected header")
    count = u16be(d, s + o_cnt + 2)
    nsty = (o_cin - o_sty) // 3
    end_cin = o_cin + 24
    if s + end_cin > e or d[s + end_cin:e] != bytes(e - s - end_cin):
        raise SystemExit(f"{label}: unexpected tail")
    used = set()
    tlabs = [label_of(nm.strip(), used) for nm in sub_names]
    B = ['    .ascii\t"Technics Rhythms"\t# strncmp with the firmware\'s 0x4872980C',
         "    .be16\t0\t\t# checksum: zeroed in this copy (IC18 has 0xE2DA)",
         "    .be24\t0\t\t# checksum start: zeroed",
         "    .be24\t0\t\t# checksum length: zeroed",
         f"    .be24\tTrCopyCountBlock - {label}",
         f"    .be24\tTrCopyStyleIndex - {label}\t# -> 0x50034B7C (StyleBuiltinNameTableInit)",
         f"    .be24\tTrCopyStyleTable - {label}",
         f"    .be24\tTrCopyCountInTable - {label}",
         f"    .be24\t0x{o_fb:06x}\t# the fallback style: IC18's style 0 (an IC18 offset)",
         "TrCopyCountBlock:",
         "    .be16\t0",
         f"    .be16\t{count}\t\t# the rhythm count (IC18 has 220; this copy adds a 52nd table style)",
         "    .be16\t96\t\t# [INFERENCE] ticks a beat",
         f"    .byte\t{', '.join(str(x) for x in d[s + o_cnt + 6:s + o_idx])}\t# [INFERENCE] the format's dimensions",
         "",
         "# The style-ID index: entry ((id & 0x0F00) >> 1) | (id & 0x7F) serves style-ID id.",
         f"# Below {count}: style n of IC18's style table; 0x8000 + n: entry n; 0x4000 + n: style n",
         "# of this image's BuiltinStyleSubTable.",
         "TrCopyStyleIndex:"]
    for i in range(0x800):
        v = u16be(d, s + o_idx + 2 * i)
        sid = ((i & 0x780) << 1) | (i & 0x7F)
        if v < count:
            B.append(f"    sidx_style\t{v}\t\t# id 0x{sid:03x}: IC18 style {v}")
        elif v >> 14 == 2:
            t = v & 0x7FF
            B.append(f"    sidx_alias\t0x{t:03x}\t# id 0x{sid:03x} -> id 0x{((t & 0x780) << 1) | (t & 0x7F):03x}")
        elif v >> 14 == 1:
            t = v & 0x3FFF
            nm = f" {tlabs[t]}" if t < len(tlabs) else ""
            B.append(f"    sidx_table\t{t}\t\t# id 0x{sid:03x}: BuiltinStyleSubTable style {t}{nm}")
        else:
            raise SystemExit(f"{label}: index entry {i}: {v:#x}")
    B += ["", "# IC18's style table: offsets into IC18's resource (0x40010000), not into this image.",
          "TrCopyStyleTable:"]
    for k in range(nsty):
        B.append(f"    .be24\t0x{u24be(d, s + o_sty + 3 * k):06x}\t# IC18 style {k}")
    B += ["# IC18's count-in table (offsets into IC18).", "TrCopyCountInTable:"]
    for k in range(8):
        B.append(f"    .be24\t0x{u24be(d, s + o_cin + 3 * k):06x}\t# IC18 count-in, {k + 1} beats")
    if e > s + end_cin:
        B.append(f"    .space\t{e - s - end_cin}, 0x00")
    return B


def technics_pads(d, s, e, label, jpg_dir, build, inline=False):
    """Segment 4, "Technics Pads": the built-in PERFORMANCE PAD bank.  Same resource
    shape as "Technics Rhythms": TechnicsPadsResourceParse (0x48433F4A) checks the
    16-byte name and reads the u24BE offsets at +0x18 (count block; its u16 at +2 is the
    pad count -> 0x50034C24), +0x1B (the pad-ID index -> 0x50034C2C) and +0x1E (the pad
    table -> 0x50034C30).  func_4843443E looks a pad up: index entry < count = pad n,
    0x8000 + n = entry n, 0x4000 + n = pad n of the resource at 0x50034C38 (none here);
    a pad table entry is a u24BE offset from the resource.  Each pad goes to its own
    include file src/table/pads/<Name>.s; with `inline` (a program image's own copy,
    tools/gen_data_s.py pads()) the pads' lines follow the table instead."""
    if d[s:s + 16] != b"Technics Pads   " or d[s + 16:s + 0x18] != bytes(8):
        raise SystemExit(f"{label}: unexpected header")
    o_cnt, o_idx, o_tab = (u24be(d, s + x) for x in (0x18, 0x1B, 0x1E))
    count = u16be(d, s + o_cnt + 2)
    nidx = (o_tab - o_idx) // 2
    if (o_cnt, o_idx) != (0x21, 0x2B) or u16be(d, s + o_cnt) != 0 or u16be(d, s + o_cnt + 4) != 96:
        raise SystemExit(f"{label}: unexpected count block")
    offs = [u24be(d, s + o_tab + 3 * k) for k in range(count)]
    used = set()
    labs = []
    for k in range(count):
        nm = d[s + offs[k]:s + offs[k] + 16]
        if not all(0x20 <= b < 0x7F and b not in b'"\\' for b in nm):
            raise SystemExit(f"{label}: pad {k} name {nm!r}")
        labs.append("Pad_" + label_of(nm.decode("ascii").strip(), used)[6:])
    B = ['    .ascii\t"Technics Pads   "\t# strncmp with the firmware\'s 0x485B6B68',
         "    .space\t8, 0x00\t\t# zero (IC18's style resource keeps its checksum here)",
         f"    .be24\tPadCountBlock - {label}",
         f"    .be24\tPadIndex - {label}\t# -> 0x50034C2C",
         f"    .be24\tPadTable - {label}\t# -> 0x50034C30",
         "PadCountBlock:",
         "    .be16\t0",
         f"    .be16\t{count}\t\t# the pad count -> 0x50034C24; the index's limit",
         "    .be16\t96\t\t# [INFERENCE] ticks a beat, as in the style format",
         f"    .byte\t{', '.join(str(x) for x in d[s + o_cnt + 6:s + o_idx])}\t# [INFERENCE] dimensions"
         " (name length 16 ...); nothing reads them",
         "",
         f"# The pad-ID index: {nidx} entries, entry ((id & 0x0700) >> 1) | (id & 0x7F) (func_48434591)",
         "# serves pad-ID id; an entry below the count is pad n, 0x8000 + n sends the ID to entry n.",
         "PadIndex:"]
    for i in range(nidx):
        v = u16be(d, s + o_idx + 2 * i)
        if v < count:
            B.append(f"    sidx_style\t{v}\t\t# {labs[v]}")
        elif v >> 14 == 2:
            B.append(f"    sidx_alias\t0x{v & 0x7FF:03x}")
        elif v >> 14 == 1:
            B.append(f"    sidx_table\t{v & 0x3FFF}")
        else:
            raise SystemExit(f"{label}: index entry {i}: {v:#x}")
    B += ["", "PadTable:"]
    for k in range(count):
        B.append(f"    .be24\t{labs[k]} - {label}\t# pad {k}")
    pos = s + o_tab + 3 * count
    for k in range(count):
        o = s + offs[k]
        if o != pos:
            raise SystemExit(f"{label}: pad {k} does not follow the one before")
        v = labs[k]
        bars, beats = d[o + 16] + 1, d[o + 17] + 1
        S = u24be(d, o + 0x34)
        st = o + 0x37
        nm = d[o:o + 16].decode("ascii")
        L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
             "# Licensed under the terms of the GNU General Public License v3 or later",
             "#",
             f'# "Technics Pads" pad {k}: "{nm.strip()}" (TechnicsPadsResource, pad table entry {k}).',
             "# GENERATED by tools/gen_table_styles.py (make table-src); macros src/table/style_macros.inc.",
             "",
             f"{v}:",
             f'\t.ascii\t"{nm}"',
             f"\tpad_head\t{bars}, {beats}, {d[o + 18]}, {d[o + 19]}, {d[o + 20]}, {hx(d[o + 21])}"]
        for p in range(2):
            f = d[o + 0x16 + 15 * p:o + 0x16 + 15 * p + 15]
            vals = [hx(f[0]), str(f[1]), hx(f[2]), hx(f[3]), hx(f[4])] + [str(x) for x in f[5:]]
            L.append(f"\tstyle_part\t{', '.join(vals)}\t# set-up {p}")
        L += [f"\tpad_events\t{v}", f"{v}_Events:\t\t# {bars} bars of {beats} beats, {S} bytes"]
        # (inline: a program's copy, whose pads may stop a beat marker short -- the KN6000 v7.1's pad 3
        # has 15 for 4 x 4; the grammar is still checked)
        L += event_lines(d, st, st + S, f"{label} pad {k}", None if inline else bars * beats)
        L.append(f"\tvar_end\t{v}")
        if inline:
            B += [""] + L[3:4] + L[6:]
            pos = st + S
            continue
        rel = f"pads/{v[4:]}.s"
        path = os.path.join(jpg_dir, rel)
        text = "\n".join(L) + "\n"
        if os.path.exists(path) and open(path).read() != text:
            raise SystemExit(f"{path} exists with other text")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, "w").write(text)
        B.append(f'    .include\t"{path}"')
        pos = st + S
    if pos < e and not inline and e % 4 == 0 and e - pos == -pos % 4 and d[pos:e] == bytes(e - pos):
        # every directory offset is a multiple of 4: the fill takes the next segment there
        B.append("    .align\t4, 0x00\t# fill to the next segment, which starts on a multiple of 4 as all 84 do;"
                 " TechnicsPadsResourceParse reads only the count, so nothing reads it")
    elif pos < e:
        B.append(f"    .byte\t{', '.join(hx(x) for x in d[pos:e])}\t# after the last pad; nothing reads it")
    return B


# The preset rhythms the 'ZZZJ' records follow: GenreStyleTable (941 0x48735EE4, 942
# 0x48736F08), genres 0..13 with their style counts (+0x11).  StyleIdToPresetOrdinal
# (func_4843FACD) numbers a rhythm by the counts of the genres before its own; CUSTOM (14)
# and MEMORY (15) have no record.  notes/mn10300-names-probes/songtable_zzzj.py checks it.
ZZZJ_GENRES = [("8&16 BEAT", 10), ("ROCK & POP", 16), ("BALLAD", 16), ("JAZZ & SWING", 20),
               ("BALLROOM", 16), ("MOVIE & SHOW", 20), ("ENTERTAINER", 14), ("ORGANIST", 10),
               ("60s & 70s", 13), ("MODERN DANCE", 14), ("SOUL & R&B", 19), ("COUNTRY&WESTERN", 14),
               ("MARCH & WALTZ", 12), ("LATIN & WORLD", 26)]
# A record's eight entries: 0x485B73A0 maps M3 parts 0x13..0x1A to entries 3, 4, 5, 6, 7, 2, 0, 1,
# 0x485B7396 the style parts (Drum, Bass, Acc1-5, Perc) to entries 0, 2, 3, 4, 5, 6, 7, 1.
ZZZJ_PARTS = ["Drum", "Perc", "Bass", "Acc1", "Acc2", "Acc3", "Acc4", "Acc5"]


def sram_record_defaults(d, s, e, label):
    """Segment 1: the 8-byte signature 'ZZZJ', 0, 'K', then the u16BE record count 220, that
    SramRecordsLoadFactory (0x4843FB65) compares with the program's copy 0x485B7370, 8 zero
    bytes, then 220 records of 0x18 bytes that it copies over the battery-SRAM table
    0x84030FF8.  They are the SOUND ARRANGER's factory settings: one record per preset
    rhythm (ZZZJ_GENRES), one {program, bank LSB, bank MSB} entry per accompaniment part
    (ZZZJ_PARTS).  Bit 7 of entry 0's program byte: the arranger is ON for that rhythm
    (SndArgOnSet 0x4843FCE6 / SndArgIsOn 0x4843FCA2); bit 7 of entries 2..7: the part's
    CC94 is 127 instead of 0 (SndArgTemplateApply 0x4843FFD0 writes the part template's
    field 5; SndArgPartVoiceSet 0x4843FECE takes it from the part's 0x00B0005E)."""
    sig = d[s:s + 8]
    if sig[:4] != b"ZZZJ" or sig[4:7] != b"\x00K\x00" or d[s + 8:s + 16] != bytes(8):
        raise SystemExit(f"{label}: unexpected header")
    n = sig[7]
    if s + 0x10 + 24 * n != e:
        raise SystemExit(f"{label}: {n} records do not fill the segment")
    if sum(c for _g, c in ZZZJ_GENRES) != n:
        raise SystemExit(f"{label}: {n} records but the preset genres hold {sum(c for _g, c in ZZZJ_GENRES)}")
    B = ['    .ascii\t"ZZZJ"', '    .byte\t0', '    .ascii\t"K"',
         f"    .be16\t{n}\t\t# record count (func_48440158 reads the SRAM copy's as a u16BE; 'ZZZI' marks an older one)",
         "    .space\t8, 0x00"]
    rhythms = [(g, k + 1, c) for g, c in ZZZJ_GENRES for k in range(c)]
    for r in range(n):
        o = s + 0x10 + 24 * r
        g, k, c = rhythms[r]
        B.append(f"SramRecordDefault{r:03d}:\t\t# preset rhythm {r}: {g}, rhythm {k} of {c}")
        for t in range(8):
            a, b, c3 = d[o + 3 * t:o + 3 * t + 3]
            note = ZZZJ_PARTS[t]
            if a & 0x80:
                note += ": arranger ON" if t == 0 else (": CC94 127" if t > 1 else ": bit 7 (cleared on write)")
            B.append(f"    zzzj_voice\t{hx(a)}, {hx(b)}, {hx(c3)}\t# {note}")
    return B


def part_lines(blk, what):
    """A 0x18-byte part block of a MEMORY variation record: the 15 style_part fields, then
    9 bytes (part_more) that no firmware routine reads or writes: StyleRecordBindMem points
    0x50034BAC[] at the blocks and func_4844187A copies 15 bytes of each into the part
    template, and func_48441EB4 writes 15; they are 0 in every TCMP block of tables 84/83
    and of the IC21 images (notes/mn10300-names-probes/songtable_part_more.py)."""
    f = blk
    vals = [hx(f[0]), str(f[1]), hx(f[2]), hx(f[3]), hx(f[4])] + [str(x) for x in f[5:15]]
    return [f"\tstyle_part\t{', '.join(vals)}\t# {what}",
            f"\tpart_more\t{', '.join(str(x) for x in f[15:24])}"]


def tcmp_container(d, s, e, label):
    """Segment 2: the factory MEMORY-style container 'TCMP' (notes/tcmp-container-synthesis.md,
    kn7000_manual.sym "TCMP STYLE CONTAINER"): a 0x70-byte header, N style records of 0x80,
    N x 20 variation records of 0xE0, then the event-stream heap; each heap item is the
    variation's index, a u24BE length and the events.  MemStyleAreaLoadFactory copies it
    whole to MEM_STYLE_AREA 0x50180000."""
    c = d[s:e]
    if c[:6] != b"TCMP\0\0":
        raise SystemExit(f"{label}: no 'TCMP'")
    n = u16be(c, 0x16)
    top = u24be(c, 0x13)
    if u24be(c, 0x08) != 0x70 or c[0x22:0x30] != bytes(14) or c[0x30:0x70] != b" " * 0x40:
        raise SystemExit(f"{label}: unexpected header")
    P = "Tcmp"
    B = ['    .ascii\t"TCMP"\t\t# MemStyleAreaSignatureVerify: strncmp with 0x487312E8',
         "    .be16\t0\t\t# sub-signature (0x487312EC)",
         f"    .be16\t0x{u16be(c, 6):04x}\t\t# SumU16BE of the checksum range (MemStyleAreaChecksumVerify)",
         f"    .be24\t{P}StyleRecords - {label}\t# checksum start (0x70)",
         f"    .be24\t0x{u24be(c, 0x0B):04x}\t\t# checksum length in halfwords: the N = 3 record block",
         f"    .be16\t{u16be(c, 0x0E)}",
         f"    .be24\t0x{u24be(c, 0x10):06x}\t# the MEMORY area's length (MemStyleAllocFits)",
         f"    .be24\t{P}HeapEnd - {label}\t# the bump allocator's top (MemStyleAllocOffsetGet)",
         f"    .be16\t{n}\t\t# style count N",
         f"    .be16\t{u16be(c, 0x18)}\t\t# [INFERENCE] ticks a beat, as in the style format",
         f"    .byte\t{', '.join(str(x) for x in c[0x1A:0x22])}\t# [INFERENCE] the format's dimensions",
         "    .space\t14, 0x00",
         "    .space\t0x40, 0x20\t# ASCII spaces (the ROM template 0x487312E8 has them too)",
         f"{P}StyleRecords:"]
    for k in range(n):
        r = 0x70 + 0x80 * k
        rec = c[r:r + 0x80]
        names = [rec[16 * i:16 * i + 16] for i in range(5)]
        if any(x[13:] != bytes(3) for x in names) or rec[0x64:0x70] != bytes(12) or rec[0x74:] != bytes(12):
            raise SystemExit(f"{label}: style record {k}")
        B.append(f"{P}Style{k}:\t\t# MemStyleRecPtr {k}")
        B.append(f'\t.ascii\t"{names[0][:13].decode("ascii")}"\t# the style name')
        B.append("\t.space\t3, 0x00")
        for i in range(1, 5):
            B.append(f'\t.ascii\t"{names[i][:13].decode("ascii")}"\t# variation {i} name (slot {3 * (i - 1)};'
                     " MemStyleVarCopy)")
            B.append("\t.space\t3, 0x00")
        B.append(f"\t.byte\t{', '.join(str(x) for x in rec[0x50:0x64])}\t# the 20 slots' variation records")
        B.append("\t.space\t12, 0x00")
        B.append(f"\tstyle_units\t{', '.join(hx(x) for x in rec[0x70:0x74])}")
        B.append("\t.space\t12, 0x00")
    vrec = 0x70 + 0x80 * n
    streams = {}
    for v in range(20 * n):
        r = vrec + 0xE0 * v
        h = c[r:r + 0x20]
        streams[u24be(c, r + 0x15)] = v
        B += [f"{P}Var{v:02d}:\t\t# MemStyleVarRecPtr {v}: style {v // 20} slot {v % 20} ({SLOT_NAMES[v % 20]})",
              f"\t.byte\t{', '.join(hx(x) for x in h[0:3])}\t# +0x00 the source pattern: style-ID index entry,"
              " 7 bits + the rest (func_4843B5DB / func_4843B8D7 copy a preset's; func_4843511C reads it)",
              f"\t.byte\t{hx(h[3])}\t\t# +0x03 RECORD KEY/CHORD: bits 0-3 the key, bit 4 Min (MainCMP_SetCmpRecordChord ->"
              " func_4843C186); func_4843C149 takes bit 4 from the A/B parity in slots >= 12 (0x485b6d74)",
              f"\t.byte\t{', '.join(hx(x) for x in h[4:12])}\t# +0x04 one byte a part (MemStyleVarRecInit clamps them to 1 in slots >= 12)",
              f"\t.byte\t{', '.join(hx(x) for x in h[12:16])}\t# +0x0c: no reader found",
              f"\t.byte\t{h[16] + 1} - 1, {h[17] + 1} - 1\t# bars - 1, beats a bar - 1 (MemStyleVarBarCount)",
              f"\t.byte\t{', '.join(hx(x) for x in h[18:21])}\t# +0x12: no reader found",
              f"\t.be24\t{P}Stream{v:02d} - {label}\t# the stream in the heap (MemStyleRecData)",
              f"\t.byte\t{hx(h[24])}, {hx(h[25])}\t# +0x18 EFFECT PART 1 / 2, 0xff none (MainCMP_SetCmpEffectPart -> func_4843C10D;"
              " func_4843C0ED, func_4843CB41)",
              f"\t.byte\t{', '.join(hx(x) for x in h[26:32])}\t# +0x1a: no reader found"]
        for p in range(8):
            B += part_lines(c[r + 0x20 + 0x18 * p:r + 0x38 + 0x18 * p], PART_NAMES[p])
    pos = vrec + 0xE0 * 20 * n
    B.append(f"{P}Heap:")
    for o in sorted(streams):
        v = streams[o]
        if o != pos or c[o] != v:
            raise SystemExit(f"{label}: heap item of variation {v}")
        L = u24be(c, o + 1)
        rv = vrec + 0xE0 * v
        bars, beats = c[rv + 0x10] + 1, c[rv + 0x11] + 1
        B += [f"{P}Stream{v:02d}:", f"\t.byte\t{v}\t\t# the variation's index (MemStyleAreaStreamsVerify)",
              f"\t.be24\t{P}Stream{v:02d}_End - {P}Stream{v:02d}_Events",
              f"{P}Stream{v:02d}_Events:\t\t# {bars} bars of {beats} beats, {L} bytes"]
        B += event_lines(c, o + 4, o + 4 + L, f"{label} stream {v}", bars * beats)
        B.append(f"{P}Stream{v:02d}_End:")
        pos = o + 4 + L
    if pos != top:
        raise SystemExit(f"{label}: heap ends at {pos:#x}, top {top:#x}")
    B.append(f"{P}HeapEnd:")
    if c[pos:] != bytes(len(c) - pos):
        raise SystemExit(f"{label}: bytes after the heap")
    if len(c) > pos:
        B.append(f"    .space\t{len(c) - pos}, 0x00")
    return B


def tpad_container(d, s, e, label):
    """Segment 3: the factory PERFORMANCE PAD user memory 'TPAD' (MemPadAreaLoadFactory
    0x48432175 copies it to 0x501F91A0 when it starts with 'TPAD').  Read here by its
    likeness to 'TCMP': a 0x70-byte header of the same shape, five bank records of 0x30
    (a 16-byte name, six 3-byte pad references), user pad records of 0x60 up to the heap,
    then the heap of event streams, each item the record's index, a u24BE length and the
    events (the same grammar as the styles').  [INFERENCE] The field roles beyond the
    header's and the streams' are read from the data, not from the code."""
    c = d[s:e]
    if c[:6] != b"TPAD\0\0" or c[0x22:0x30] != bytes(14) or c[0x30:0x70] != b" " * 0x40:
        raise SystemExit(f"{label}: unexpected header")
    top = u24be(c, 0x13)
    P = "Tpad"
    B = ['    .ascii\t"TPAD"\t\t# MemPadAreaLoadFactory: compared with 0x48729858',
         "    .be16\t0",
         f"    .be16\t0x{u16be(c, 6):04x}\t\t# SumU16BE of the range below (measured: notes/table-semantics-probes)",
         f"    .be24\t{P}UserBanks - {label}\t# checksum start: the user banks",
         f"    .be24\t0x{u24be(c, 0x0B):04x}\t\t# checksum length in halfwords: up to the heap",
         f"    .be16\t{u16be(c, 0x0E)}",
         f"    .be24\t0x{u24be(c, 0x10):06x}\t# the area's length (0xA000, MemPadAreaLoadFactory's memset)",
         f"    .be24\t{P}HeapEnd - {label}\t# [INFERENCE] the allocator's top, as TCMP's",
         f"    .be16\t{u16be(c, 0x16)}\t\t# [INFERENCE] the user bank count",
         f"    .be16\t{u16be(c, 0x18)}\t\t# [INFERENCE] ticks a beat",
         f"    .byte\t{', '.join(str(x) for x in c[0x1A:0x22])}\t# [INFERENCE] the format's dimensions",
         "    .space\t14, 0x00",
         "    .space\t0x40, 0x20\t# ASCII spaces, as in TCMP"]
    r = 0x70
    for b in range(5):
        if b == 2:
            B.append(f"{P}UserBanks:")
        rec = c[r:r + 0x30]
        if rec[0x22:] != bytes(14):
            raise SystemExit(f"{label}: bank {b}")
        B.append(f"{P}Bank{b}:")
        B.append(f'\t.ascii\t"{rec[:16].decode("ascii")}"')
        for i in range(6):
            a1, a2, fl = rec[16 + 3 * i:19 + 3 * i]
            B.append(f"\ttpad_ref\t{hx(a1)}, {hx(a2)}, {hx(fl)}")
        B.append("\t.space\t14, 0x00")
        r += 0x30
    if u24be(c, 0x08) != 0xD0:
        raise SystemExit(f"{label}: checksum start")
    recs = []
    while all(0x20 <= x < 0x7F for x in c[r:r + 16]) and r + 0x60 <= len(c):
        recs.append(r)
        r += 0x60
    heap = r
    streams = {}
    for k, r in enumerate(recs):
        h = c[r:r + 0x60]
        if h[0x12:0x14] != bytes(2) or h[0x16:0x18] != bytes(2) or h[0x1B] or h[0x1C] or h[0x20:0x28] != bytes(8):
            raise SystemExit(f"{label}: pad record {k}")
        streams[u24be(h, 0x1D)] = k
        B += [f"{P}Pad{k:02d}:",
              f'\t.ascii\t"{h[:16].decode("ascii")}"',
              f"\t.byte\t{hx(h[16])}, {hx(h[17])}, 0\t# +0x10 the built-in pad it was copied from: ID & 0x7f, ID >> 7, 0"
              " (func_48431D21)",
              f"\t.byte\t{hx(h[19])}\t\t# +0x13 RECORD KEY/CHORD: bits 0-3 the key, bit 4 Min (MainPAD_SetUserPadRecordChord"
              " -> func_484325B4; func_4843259F)",
              f"\t.byte\t{hx(h[20])}, {hx(h[21])}, 0, 0\t# [INFERENCE] per-part flags, as TCMP's +0x04 bytes; no reader found",
              f"\t.byte\t{h[24] + 1} - 1, {h[25] + 1} - 1, {h[26]}, 0, 0\t# bars - 1, beats - 1, flags (pad_head's): bit 0 LOOP,"
              " bit 1 SYNCHRO (MainPAD_SetUserPadLoop / MainPAD_SetUserPadSync); [INFERENCE] bit 2 a"
              " fixed-chord pad, bit 3 Min",
              f"\t.be24\t{P}Stream{k:02d} - {label}\t# the stream in the heap",
              "\t.space\t8, 0x00"]
        for p in range(2):
            B += part_lines(h[0x28 + 0x18 * p:0x40 + 0x18 * p], f"set-up {p}")
        B.append(f"\t.byte\t{', '.join(hx(x) for x in h[0x58:0x60])}")
    pos = heap
    B.append(f"{P}Heap:")
    for o in sorted(streams):
        k = streams[o]
        r = recs[k]
        if o != pos or c[o] != k:
            raise SystemExit(f"{label}: heap item of pad {k}")
        L = u24be(c, o + 1)
        bars, beats = c[r + 24] + 1, c[r + 25] + 1
        B += [f"{P}Stream{k:02d}:", f"\t.byte\t{k}\t\t# the pad record's index",
              f"\t.be24\t{P}Stream{k:02d}_End - {P}Stream{k:02d}_Events",
              f"{P}Stream{k:02d}_Events:\t\t# {bars} bars of {beats} beats, {L} bytes"]
        B += event_lines(c, o + 4, o + 4 + L, f"{label} stream {k}", bars * beats)
        B.append(f"{P}Stream{k:02d}_End:")
        pos = o + 4 + L
    if pos != top:
        raise SystemExit(f"{label}: heap ends at {pos:#x}, top {top:#x}")
    B.append(f"{P}HeapEnd:")
    if c[pos:] != bytes(len(c) - pos):
        raise SystemExit(f"{label}: bytes after the heap")
    if len(c) > pos:
        B.append(f"    .space\t{len(c) - pos}, 0x00")
    return B
