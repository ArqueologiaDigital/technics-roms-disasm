#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""program_rhythm.py -- the program image's own "Technics Rhythms" resource, typed with IC18's macros.

QUESTION ANSWERED
-----------------
"What is the style resource the program carries at TechnicsRhythmsResource
(941: CPU 0x48729988), and can it be written like IC18's?"  It has the format of
IC18's resource (kn7000/notes/ic18-rhythm-rom.md: a 16-character signature, a
checksum, five 3-byte big-endian offsets, the count block, the 2048-entry
style-ID index, the style table, the count-in table and patterns, then each
style's record and its 20 variations), but only ONE style, "8 Beat 1" -- the
fallback the firmware uses when IC18 does not answer.  The record and event
syntax is IC18's: tools/gen_ic18_rhythm_s.py's helpers and the macro block of
src/ic18/rhythm.s (copied by gen_data_s.py to <data dir>/rhythm_macros.inc).

Used by tools/gen_data_s.py: emit(rom, off, base_label) -> (lines, size).
Checked as it is written: the checksum, every offset, every stream (beats,
event lengths), the tiling of count-ins and styles.
"""
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ic18_rhythm_s as R  # noqa: E402

KN7 = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def macro_block():
    """The record and event macros of src/ic18/rhythm.s, verbatim (from its
    "record macros" banner to the header)."""
    L = open(os.path.join(KN7, "src", "ic18", "rhythm.s")).read().split("\n")
    a = next(i for i, x in enumerate(L) if x.startswith("# ---- record macros"))
    b = next(i for i, x in enumerate(L) if x.startswith("# ---- the header"))
    return L[a:b]


def emit(d, base, lab):
    """Lines and byte size of the resource at file offset `base` of image `d`,
    labelled `lab` (the resource's start); its parts are named lab_<part>."""
    im = R.Img(d)
    if d[base:base + 16] != b"Technics Rhythms":
        raise ValueError("no Technics Rhythms signature")
    ck = im.u16(base + 0x10)
    ck_start, ck_len = im.u24(base + 0x12), im.u24(base + 0x15)
    o_count, o_index, o_styles, o_countin, o_fallback = (im.u24(base + x) for x in (0x18, 0x1B, 0x1E, 0x21, 0x24))
    if sum(struct.unpack_from(f">{ck_len}H", d, base + ck_start)) & 0xFFFF != ck:
        raise ValueError("checksum does not match")
    if (o_count, o_index) != (0x27, 0x33) or o_styles != o_index + 0x1000:
        raise ValueError("unexpected header layout")
    count = im.u16(base + o_count + 2)
    nstyles = (o_countin - o_styles) // 3
    styles = [im.u24(base + o_styles + 3 * i) for i in range(nstyles)]
    countins = [im.u24(base + o_countin + 3 * k) for k in range(8)]
    if countins[0] != o_countin + 24 or styles[0] != o_fallback:
        raise ValueError("unexpected table layout")
    index = [im.u16(base + o_index + 2 * i) for i in range(0x800)]
    used = set()
    labels = [lab + "_" + R.label_of(d[base + r:base + r + 13].decode("ascii").strip(), used) for r in styles]

    def var_record(v, o, what):
        bars, beats = d[o] + 1, d[o + 1] + 1
        L = im.u16(o + 4)
        S = im.u24(o + 6 + L)
        s = o + 9 + L
        e = s + S
        R.check_stream(d, s, e, bars * beats, what)
        lines = [f"{v}:\t# {bars} bars of {beats} beats",
                 f"\tvar_head\t{v}, {bars}, {beats}, {R.hx(d[o + 2])}, {R.hx(d[o + 3])}"]
        lines += R.event_lines(d, o + 6, o + 6 + L)
        lines.append(f"\tvar_events\t{v}")
        lines += R.event_lines(d, s, e)
        lines.append(f"\tvar_end\t{v}")
        return lines, e, bars, beats

    out = []
    w = out.append
    w("# ---- the program's own \"Technics Rhythms\" resource (IC18's format: notes/ic18-rhythm-rom.md;")
    w("#      the macros are src/ic18/rhythm.s's, in rhythm_macros.inc).  One style, the fallback the")
    w("#      firmware binds when IC18 does not answer (StyleResourceVerify / StyleBuiltinNameTableInit).")
    w(f"{lab}:")
    w('\t.ascii\t"Technics Rhythms"')
    w(f"\t.be16\t0x{ck:04x}\t\t\t# SumU16BE of the halfwords below (StyleResourceVerify)")
    w(f"\t.be24\t0x{ck_start:06x}\t\t\t# checksum start, from {lab}")
    w(f"\t.be24\t0x{ck_len:06x}\t\t\t# checksum length in halfwords")
    w(f"\t.be24\t{lab}_CountBlock - {lab}")
    w(f"\t.be24\t{lab}_StyleIndex - {lab}")
    w(f"\t.be24\t{lab}_StyleTable - {lab}")
    w(f"\t.be24\t{lab}_CountInTable - {lab}")
    w(f"\t.be24\t{labels[0]} - {lab}\t# the fallback style")
    w(f"{lab}_CountBlock:")
    blk = d[base + o_count:base + o_index]
    w(f"\t.be16\t{im.u16(base + o_count)}, {count}, {im.u16(base + o_count + 4)}\t# 0, the rhythm count, ticks a beat")
    w(f"\t.byte\t{', '.join(str(x) for x in blk[6:])}")
    for i in range(nstyles):
        w(f".equ {lab}_SNo{i}, {i}")
    w(f"{lab}_StyleIndex:\t# 2048 entries (StyleBuiltinNameResolve): style n, 0x8000 + alias, 0x4000 + table-ROM style")
    for i, e in enumerate(index):
        sid = R.sid_of_entry(i)
        if e < nstyles:
            w(f"\tsidx_style\t{lab}_SNo{e}\t# id 0x{sid:03x}")
        elif e >> 14 == 2:
            w(f"\tsidx_alias\t0x{e & 0x7FF:03x}\t\t# id 0x{sid:03x} -> id 0x{R.sid_of_entry(e & 0x7FF):03x}")
        elif e >> 14 == 1:
            w(f"\tsidx_table\t{e & 0x3FFF}\t\t# id 0x{sid:03x}: table ROM style {e & 0x3FFF}")
        else:
            raise ValueError(f"index entry {i}: {e:#x}")
    w(f"{lab}_StyleTable:")
    for i in range(nstyles):
        w(f"\t.be24\t{labels[i]} - {lab}")
    w(f"{lab}_CountInTable:")
    for k in range(8):
        w(f"\t.be24\t{lab}_CountIn_{k + 1}Beats - {lab}")
    pos = base + o_countin + 24
    for k in range(8):
        o = base + countins[k]
        if o != pos:
            raise ValueError(f"count-in {k} does not follow the one before")
        lines, pos, bars, beats = var_record(f"{lab}_CountIn_{k + 1}Beats", o, f"count-in {k}")
        out += lines
    for i, r in enumerate(styles):
        o = base + r
        if o != pos:
            raise ValueError(f"style {i} does not follow")
        nm = d[o:o + 13].decode("ascii")
        offs = [im.u24(o + 0x8A + 3 * j) for j in range(20)]
        if d[o + 0x89] != 1 or min(offs) != 0xC6 or len(set(offs)) != 20:
            raise ValueError(f"style {i}: unexpected record layout")
        sl = labels[i]
        w(f'# Style {i}: "{nm.strip()}"')
        w(f"{sl}:")
        w(f'\t.ascii\t"{nm}"')
        w(f"\tstyle_units\t{R.hx(d[o + 13])}, {R.hx(d[o + 14])}, {R.hx(d[o + 15])}, {R.hx(d[o + 16])}")
        for p in range(8):
            f = d[o + 0x11 + 15 * p:o + 0x11 + 15 * p + 15]
            vals = [R.hx(f[0]), str(f[1]), R.hx(f[2]), R.hx(f[3]), R.hx(f[4])] + [str(x) for x in f[5:]]
            w(f"\tstyle_part\t{', '.join(vals)}\t# {R.PART_NAMES[p]}")
        w("\t.byte\t1\t\t\t# TODO: 1 in every style; no reader found")
        w(f"\tstyle_slots\t{sl}")
        pos = o + 0xC6
        for off in sorted(offs):
            j = offs.index(off)
            if o + off != pos:
                raise ValueError(f"style {i}: gap before slot {j}")
            lines, pos, _b, _t = var_record(f"{sl}_{R.SLOT_NAMES[j]}", o + off, f"style {i} slot {j}")
            out += lines
    return out, pos - base
