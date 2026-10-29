#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates a byte-exact source for a KN7000 table-flash image (CPU 0x48000000).
#
#   * the uint32 offset directory at 0x0 as .long <segment> - TableRomDirectory rows;
#   * every asset segment under the label and header comment tools/table_segments.py
#     gives it: a JPEG segment as .incbin of its file in src/table/ (written there
#     with --jpg-dir; a file already there must hold the same bytes, so two builds
#     share one copy), a 4-byte text marker as .ascii/.asciz, the GUI resource
#     header as .long <table> rows, the rest as .incbin_range; with --compare each segment is marked
#     "unchanged" or "CHANGED" against the same segment of another build;
#   * with --plugin: the SP7001 XAPR plug-in appended after the directory image,
#     as real MN10300 assembly for its code (unidasm mnemonics re-encoded by the
#     repo's mn10300_asm encoder; anything it can't reproduce stays a .byte escape),
#     its header slots and MILK reflection tables as .long <name> rows, and its
#     keystream records and known strings as bytes with the text in a comment.
#
# The result assembles with tools/kn7asm.py; `make verify-sp7001` checks it is
# byte-identical to the dump.
#
# Usage:
#   gen_table_s.py --rom T.rom --out T.s [--jpg-dir src/table]
#                  [--compare OTHER.rom --compare-label NAME]
#                  [--plugin LO:HI --plugin-code LO:HI] [--sym F.sym ...] [--title ...]
import argparse
import hashlib
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_program_s as G     # noqa: E402  (disasm_function, encoder, name_target)
import gen_symbols as GS      # noqa: E402  (find_tables)
import table_segments as TS   # noqa: E402  (what each directory segment is)
import table_png as TP        # noqa: E402  (raw pictures <-> indexed PNG files)
import gen_table_styles as TST  # noqa: E402  (the "Technics Rhythms" style data)
import gen_table_voices as TV   # noqa: E402  (the 'JK' internal voice archive)

BASE = 0x48000000


def u32(d, o):
    return struct.unpack_from("<I", d, o)[0]


def directory(d):
    first = u32(d, 0)
    ents = [first]
    for i in range(1, first // 4):
        v = u32(d, 4 * i)
        if v <= ents[-1] or v > len(d):
            break
        ents.append(v)
    return ents                      # segment i = [ents[i], ents[i+1])


def load_syms(paths):
    """-> {cpu: (name, note)} from .sym files (first definition of an address wins)."""
    out = {}
    for p in paths:
        for line in open(p):
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)(.*)$", line.rstrip("\n"))
            if m:
                note = m.group(3).split(";", 1)[1].strip() if ";" in m.group(3) else ""
                out.setdefault(int(m.group(1), 16), (m.group(2), note))
    return out


def hexbytes(bs):
    return ", ".join(f"0x{b:02X}" for b in bs)


def text(bs):
    s = bs.decode("latin1")
    return "".join(c if 32 <= ord(c) < 127 and c not in "#;" else f"\\x{ord(c):02X}" for c in s)



def lowhex(line):
    """Hex numbers in a comment line in lowercase (the tree's notation rule)."""
    return re.sub(r"0x[0-9A-Fa-f]+", lambda m: m.group(0).lower(), line)


def jpeg_split(seg, start):
    """-> (jpeg, pad) when `seg` (at file offset `start`) is one JPEG (FF D8 .. FF D9)
    followed only by the zero bytes that pad it to a 4-byte boundary, else None."""
    end = seg.rfind(b"\xff\xd9") + 2
    if seg[:2] != b"\xff\xd8" or end < 4:
        return None
    jpeg, pad = seg[:end], seg[end:]
    if pad != bytes(len(pad)) or len(pad) != -(start + end) % 4:
        return None
    return jpeg, pad


def jpeg_dims(jpeg):
    i = 2
    while i + 9 <= len(jpeg):
        mark, ln = jpeg[i + 1], struct.unpack_from(">H", jpeg, i + 2)[0]
        if mark in (0xC0, 0xC1, 0xC2):
            h, w = struct.unpack_from(">HH", jpeg, i + 5)
            return w, h
        i += 2 + ln
    return None


def put_jpeg(jpg_dir, name, jpeg):
    """Write <jpg_dir>/<name> unless it is already there; it must hold these bytes."""
    path = os.path.join(jpg_dir, name)
    if os.path.exists(path):
        if open(path, "rb").read() != jpeg:
            sys.exit(f"gen_table_s: {path} exists with other bytes than this build's segment")
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "wb").write(jpeg)


PNG_OUT = "build/table_png"     # where `make` puts the bytes tools/table_png.py makes from the PNGs


def png_item(jpg_dir, rel, fmt, raw, what):
    """Keep `raw` as the PNG <jpg_dir>/<rel>.png (tools/table_png.py) and return the
    .incbin line of the bytes `make` rebuilds from it."""
    TP.write_item(os.path.join(jpg_dir, rel + ".png"), fmt, raw)
    return (f'    .incbin\t"{PNG_OUT}/{rel}.bin"   # census: generated -- tools/table_png.py '
            f"from {jpg_dir}/{rel}.png ({what})")


def tail_lines(d, a, b):
    """Bytes after an item up to the next one: zero fill, or 0xFF up to a 4-byte boundary."""
    gap = d[a:b]
    if gap and gap == b"\xff" * len(gap) and len(gap) < 4 and b % 4 == 0:
        return ["    .align\t4, 0xff"]
    assert gap == bytes(b - a), f"GUI tables: unexpected bytes at 0x{a:x}..0x{b:x}"
    return [f"    .space\t{b - a}, 0x00"] if b > a else []


def gui_resource_tables(d, s, e, ROMQ, jpg_dir):
    """Segment 0: five header words (four table pointers and a 0) copied out by
    InitializeResource, zeros, then the four tables. The bitmap, frame-piece and icon
    tables are {s16 width, s16 height, u8 *pixels} rows ended by an all-zero row, the
    font table 0x14-byte descriptors ended by an all-zero one; then the pixel and
    glyph data the rows point at, each item a PNG in <jpg_dir>/gui/ (tools/table_png.py).
    All pointers are CPU addresses."""
    tabs = ["ResBitmapTable", "ResFrameTable", "ResIconTable", "ResFontTable"]
    ptrs = [u32(d, s + 4 * k) for k in range(5)]
    offs = [p - BASE for p in ptrs[:4]]
    assert ptrs[4] == 0 and offs == sorted(offs) and s + 20 <= offs[0] and offs[-1] < e, "GUI header"
    B = [f"    .long\t{', '.join(tabs)}, 0"]
    cur = s + 20

    def fill(to):
        assert d[cur:to] == bytes(to - cur), f"GUI tables: non-zero bytes at 0x{cur:x}"
        return [f"    .space\t0x{to - cur:x}, 0x00"] if to > cur else []

    bounds = offs + [e]
    for t, (tab, o) in enumerate(zip(tabs, offs)):
        B += fill(o)
        B.append(f"{tab}:")
        hi = BASE + bounds[t + 1]
        items = []                                   # (cpu address, label, size, png rel, fmt, what)
        if tab != "ResFontTable":
            stem, file = {"ResBitmapTable": ("ResBitmap", "bitmap"), "ResFrameTable": ("ResFrame", "frame"),
                          "ResIconTable": ("ResIcon", "icon")}[tab]
            rows = []
            while True:
                w, h, p = struct.unpack_from("<hhI", d, o + 8 * len(rows))
                if (w, h, p) == (0, 0, 0):
                    break
                assert BASE + o < p < hi, f"{tab}[{len(rows)}] points outside its table's area"
                rows.append((w, h, p))
            first = {}
            for k, (w, h, p) in enumerate(rows):
                if p in first:
                    continue                         # a shared block keeps the first row's name
                first[p] = f"{stem}{k:03d}"
                if stem == "ResIcon":                # DrawIcons_Impl: always 24 x 24, 4 bpp
                    items.append((p, first[p], 288, f"gui/{file}_{k:03d}", "p4 24 24", "24x24, 4 bpp"))
                else:                                # one byte per pixel, rows padded to even
                    items.append((p, first[p], (w + (w & 1)) * h, f"gui/{file}_{k:03d}",
                                  f"p8 {w} {h}", f"{w}x{h}, 8 bpp"))
            for w, h, p in rows:
                B += [f"    .word\t{w}, {h}", f"    .long\t{first[p]}"]
            B.append("    .long\t0, 0   # end of the table")
            cur = o + 8 * (len(rows) + 1)
        else:
            k, fonts = 0, []
            while True:
                w, h, desc, cols, gl, kern, dbcs = struct.unpack_from("<HHhHIII", d, o + 0x14 * k)
                if gl == 0:
                    assert d[o + 0x14 * k:o + 0x14 * (k + 1)] == bytes(0x14), "font table end"
                    break
                assert dbcs == 0, f"font {k}: a Shift-JIS table (not handled)"
                row = [f"ResFont{k:02d}Glyphs", f"ResFont{k:02d}Kern" if kern else "0", "0"]
                B += [f"    .word\t{w}, {h}, {desc}, {cols}", f"    .long\t{', '.join(row)}"]
                fonts.append((k, w, h, cols, gl, kern))
                k += 1
            B.append("    .space\t0x14, 0x00   # end of the table")
            cur = o + 0x14 * (k + 1)
            starts = sorted([f[4] for f in fonts] + [f[5] for f in fonts if f[5]]) + [hi]
            nxt = lambda p: starts[starts.index(p) + 1]          # noqa: E731
            for k, w, h, cols, gl, kern in fonts:
                if kern:                             # proportional: {u8 width, 0, u16 offset} from 0x20
                    n = (nxt(kern) - kern) // 4
                    ents = [struct.unpack_from("<BBH", d, kern - BASE + 4 * c) for c in range(n)]
                    offs_k = [x[2] for x in ents] + [nxt(gl) - gl]
                    assert offs_k == sorted(offs_k) and offs_k[0] == 0, f"font {k}: glyphs out of order"
                    widths = [(offs_k[c + 1] - offs_k[c]) // h for c in range(n)]
                    assert all((offs_k[c + 1] - offs_k[c]) % h == 0 for c in range(n))
                    fmt = f"font 0 {h} {n} columns={','.join(map(str, widths))}"
                    items.append((gl, f"ResFont{k:02d}Glyphs", offs_k[-1], f"gui/font_{k:02d}", fmt,
                                  f"{n} proportional 1-bpp glyphs from 0x20, {h} high"))
                    items.append((kern, f"ResFont{k:02d}Kern", 4 * n, None, ents, None))
                else:
                    n = (nxt(gl) - gl) // (cols * h)
                    items.append((gl, f"ResFont{k:02d}Glyphs", n * cols * h, f"gui/font_{k:02d}",
                                  f"font {cols} {h} {n}", f"{n} 1-bpp glyphs from 0x20, {8 * cols}x{h}"))
        items.sort()
        B += fill(items[0][0] - BASE)
        for n_, (p, lab, size, rel, fmt, what) in enumerate(items):
            end = items[n_ + 1][0] if n_ + 1 < len(items) else hi
            a = p - BASE
            assert a + size <= end - BASE, f"{lab}: overlaps the next item"
            B.append(f"{lab}:")
            if rel is None:                          # a kern table
                B.append("    # {u8 advance width, u8 0, u16 offset of the glyph from ResFontNNGlyphs}")
                for c, (wd, z, off) in enumerate(fmt):
                    ch = chr(0x20 + c)
                    shown = repr(ch) if 0x20 + c < 0x7F else f"0x{0x20 + c:02x}"
                    B += [f"    .byte\t{wd}, {z}", f"    .word\t{off}   # {shown}"]
            else:
                B.append(png_item(jpg_dir, rel, fmt, d[a:a + size], what))
            B += tail_lines(d, a + size, end - BASE)
        cur = bounds[t + 1]
    return B


def bmp_dims(bmp):
    """-> (width, height, bits per pixel) of a Windows BMP."""
    w, h = struct.unpack_from("<ii", bmp, 18)
    return w, h, struct.unpack_from("<H", bmp, 28)[0]


def item_file(it):
    """-> (kind, file bytes, zero padding after them) when the item is one JPEG
    (FF D8 .. FF D9) or one Windows BMP (by its size field) followed only by zeros."""
    if it[:2] == b"\xff\xd8":
        kind, n = "jpg", it.rfind(b"\xff\xd9") + 2
    elif it[:2] == b"BM":
        kind, n = "bmp", u32(it, 2)
    else:
        return None
    if not 4 <= n <= len(it) or it[n:] != bytes(len(it) - n):
        return None
    return kind, it[:n], len(it) - n


def label_slot(label):
    """-> the directory slot whose segment carries `label` (build 84's names)."""
    return next(i for i, v in TS.SEGMENTS.items() if v[0] == label)


def offset_group(d, s, e, label, ROMQ, jpg_dir, group):
    """A segment that opens with u32 offsets (from its start; 0 = empty slot) to its
    items: the table as .long <item> - <segment>, then each item once, under the label
    of the first slot that points at it; JPEG and BMP items as files in
    <jpg_dir>/<subdir>/."""
    prefix, subdir, stems = group
    seg = d[s:e]
    first, k = len(seg), 0               # the table ends where its lowest item starts
    while 4 * k < first:
        first = min(first, u32(seg, 4 * k) or first)
        k += 1
    assert first % 4 == 0, f"{label}: table end not word-aligned"
    slots = [u32(seg, 4 * k) for k in range(first // 4)]
    items = sorted(set(o for o in slots if o))
    assert items[0] == first and items[-1] < len(seg), f"{label}: offsets out of the segment"
    name = {}
    for k, o in enumerate(slots):
        if o:
            name.setdefault(o, f"{prefix}{k:02d}")
    B = [f"    .long\t{name[o]} - {label}" if o else "    .long\t0" for o in slots]
    for n, o in enumerate(items):
        end = items[n + 1] if n + 1 < len(items) else len(seg)
        it = seg[o:end]
        lab = name[o]
        users = [k for k, v in enumerate(slots) if v == o]
        B.append("")
        if len(users) > 1:
            B.append(f"# slots {', '.join(map(str, users))}")
        B.append(f"{lab}:")
        f = item_file(it) if subdir and label_slot(label) not in TS.PNG_GROUPS else None
        png = TS.PNG_GROUPS.get(label_slot(label))
        if png:
            slot = int(lab[len(prefix):])
            if png[0] == "b1":
                w, h = png[1], png[2]
                size, fmt, what = w * h // 8, f"b1 {w} {h}", f"{w}x{h}, 1 bpp"
            else:
                rb = png[1][slot]
                h = len(it) // rb
                size, fmt, what = rb * h, f"p2 {4 * rb} {h}", f"{4 * rb}x{h}, 2 bpp"
            B.append(png_item(jpg_dir, f"{subdir}/{slot:02d}", fmt, it[:size], what))
            assert it[size:] == bytes(len(it) - size), f"{lab}: non-zero bytes after the picture"
            if len(it) > size:
                B.append(f"    .space\t{len(it) - size}, 0x00")
        elif f:
            kind, data, pad = f
            slot = int(lab[len(prefix):])
            fn = f"{subdir}/{slot:02d}_{stems[slot]}.{kind}"
            put_jpeg(jpg_dir, fn, data)
            if kind == "jpg":
                w, h = jpeg_dims(data)
                what = f"{w}x{h} JPEG"
            else:
                w, h, bpp = bmp_dims(data)
                what = f"{w}x{h} {bpp}-bpp BMP"
            B.append(f'    .incbin\t"{jpg_dir}/{fn}"   # {what}, {len(data)} bytes')
            if pad:
                B.append(f"    .space\t{pad}, 0x00")
        else:
            assert not subdir, f"{lab}: item is neither a JPEG nor a BMP"
            B.append(f"    .incbin_range\t{ROMQ}, 0x{s + o:06x}, 0x{s + end:06x}")
    return B


def asm_string(bs):
    """A .ascii operand for `bs`: printable ASCII as is, the rest as \\xHH."""
    out = ""
    for b in bs:
        c = chr(b)
        out += ("\\" + c) if c in '"\\' else c if 0x20 <= b < 0x7F else f"\\x{b:02x}"
    return f'"{out}"'


def string_lines(bs, width=96):
    """The string `bs` (without its NUL) as .ascii lines and a final .asciz: a line
    ends after each '~0d' (the help texts' new line) or near `width` at a space."""
    parts, cur = [], b""
    i = 0
    while i < len(bs):
        cur += bs[i:i + 1]
        i += 1
        if cur.endswith(b"~0d") or (len(cur) >= width and cur.endswith(b" ")):
            parts.append(cur)
            cur = b""
    if cur or not parts:
        parts.append(cur)
    return ([f"    .ascii\t{asm_string(p)}" for p in parts[:-1]] +
            [f"    .asciz\t{asm_string(parts[-1])}"])


def gap_lines(seg, a, b):
    """Bytes nothing points at: 0xFF up to a 4-byte boundary, or a .byte row."""
    gap = seg[a:b]
    if gap == b"\xff" * len(gap) and len(gap) < 4 and b % 4 == 0:
        return ["    .align\t4, 0xff"]
    return [f"    .byte\t{', '.join(f'0x{x:02x}' for x in gap)}"]


def help_texts(d, s, e, label):
    """Segment 67: four language offsets and a 0, then texts and page lists, then the
    four 100-entry topic indexes; every offset is from the segment start."""
    seg = d[s:e]
    langs = [u32(seg, 4 * k) for k in range(len(TS.HELP_LANGS))]
    assert u32(seg, 16) == 0
    nul = lambda o: seg.index(0, o) + 1          # noqa: E731
    pages_n = {}
    for L in langs:
        for k in range(TS.HELP_TOPICS):
            topic, n, pt, ti = struct.unpack_from("<HHII", seg, L + 12 * k)
            assert topic == k
            pages_n[pt] = max(pages_n.get(pt, 0), n)
    items = {}                                     # offset -> (end, kind, label, data)

    def add(off, end, kind, lab, data=None):
        if off not in items:
            items[off] = (end, kind, lab, data)
        assert items[off][:2] == (end, kind), f"HelpTexts: two readings of 0x{off:x}"
        return items[off][2]

    rows, list_label = {}, {}
    for (lang, ab), L in zip(TS.HELP_LANGS, langs):
        add(L, L + 12 * TS.HELP_TOPICS, "index", f"HelpIndex{lang}", ab)
    for (lang, ab), L in zip(TS.HELP_LANGS, langs):
        for k in range(TS.HELP_TOPICS):
            topic, n, pt, ti = struct.unpack_from("<HHII", seg, L + 12 * k)
            tl = add(ti, nul(ti), "str", f"HelpTitle{ab}{k:02d}")
            m = pages_n[pt]
            term = u32(seg, pt + 4 * m) == 0      # most lists end with a 0 word
            pl = list_label.setdefault(pt, f"HelpPages{ab}{k:02d}")
            for j in range(m + term):              # lists may share words: one item each
                add(pt + 4 * j, pt + 4 * j + 4, "word", None)
            for j in range(m):
                so = u32(seg, pt + 4 * j)
                if so:
                    add(so, nul(so), "str", f"HelpText{ab}{k:02d}_{j}")
            rows.setdefault(L, []).append((k, n, pl, tl))
    B = [f"    .long\t{', '.join(f'HelpIndex{lang} - {label}' for lang, _ab in TS.HELP_LANGS)}",
         "    .long\t0"]
    cur = 20
    for off in sorted(items):
        end, kind, lab, data = items[off]
        assert off >= cur, f"HelpTexts: 0x{off:x} overlaps the item before it"
        if off > cur:
            B += gap_lines(seg, cur, off)
        if kind == "word":
            if off in list_label:
                B.append(f"{list_label[off]}:")
            so = u32(seg, off)
            B.append(f"    .long\t{items[so][2]} - {label}" if so else "    .long\t0")
            cur = end
            continue
        B.append(f"{lab}:")
        if kind == "str":
            B += string_lines(seg[off:end - 1])
        else:
            for k, n, pl, tl in rows[off]:
                B.append(f"    .word\t{k}, {n}")
                B.append(f"    .long\t{pl} - {label}, {tl} - {label}")
        cur = end
    if cur < len(seg):
        B += gap_lines(seg, cur, len(seg))
    return B


def directory_image(d, dirents, ROMQ, jpg_dir, other, compare_label):
    """-> (body lines, segments changed vs `other`) for the directory and its segments."""
    nseg = len(dirents) - 1
    build = d[dirents[7]:dirents[8]].split(b"\n")[0].decode("ascii")
    segs = TS.segment_table(build)
    B = ["", "# ---- the offset directory ----",
         "# Segment i starts at TableRomDirectory + dir[i]; the last entry is the end of the",
         "# directory image. The firmware reaches segment i with",
         "# `mov (TableRomDirectory + 4 * i), Rn` then `add TABLE_ROM_BASE, Rn`.",
         "TableRomDirectory:"]
    for i in range(nseg):
        B.append(f"    .long\t{segs[i][0]} - TableRomDirectory")
    B.append("    .long\tTableRomImageEnd - TableRomDirectory")
    pad = d[4 * len(dirents):dirents[0]]
    assert set(pad) <= {0}, "directory padding is not zero"
    B += [f"    .space\t0x{dirents[0]:x} - {len(dirents)} * 4, 0x00",
          f"    .org\t0x{dirents[0]:06x}"]

    changed = 0
    for i in range(nseg):
        s, e = dirents[i], dirents[i + 1]
        seg = d[s:e]
        label, kind, jpg, notes = segs[i]
        note = ""
        if other:
            od, oe = other
            if i + 1 < len(oe):
                same = od[oe[i]:oe[i + 1]] == seg
                note = (f"; unchanged vs {compare_label}" if same else
                        f"; CHANGED vs {compare_label} (was 0x{oe[i + 1] - oe[i]:x} bytes)")
                changed += not same
            else:
                note = f"; not in {compare_label}"
                changed += 1
        B += ["", f"# dir[{i}], 0x{e - s:x} bytes{note}."] + [f"# {lowhex(n)}" for n in notes] + [f"{label}:"]
        if kind == "jpeg":
            jp = jpeg_split(seg, s)
            assert jp, f"segment {i} ({label}) is not a padded JPEG"
            jpeg, pad = jp
            w, h = jpeg_dims(jpeg)
            put_jpeg(jpg_dir, jpg, jpeg)
            B.append(f'    .incbin\t"{jpg_dir}/{jpg}"   # {w}x{h} JPEG, {len(jpeg)} bytes')
            if pad:
                B.append("    .align\t4")
        elif kind == "marker":
            assert len(seg) == 4, f"segment {i} ({label}) is not a 4-byte marker"
            text, op = (seg[:-1], ".asciz") if seg.endswith(b"\0") else (seg, ".ascii")
            assert b"\0" not in text, f"segment {i} ({label}): a NUL inside the marker text"
            B.append(f"    {op}\t" + asm_string(text).replace("\\x0a", "\\n"))
        elif kind == "gui":
            B += gui_resource_tables(d, s, e, ROMQ, jpg_dir)
        elif kind == "help":
            B += help_texts(d, s, e, label)
        elif kind == "tpad":
            B += TST.tpad_container(d, s, e, label)
        elif kind == "tcmp":
            B += TST.tcmp_container(d, s, e, label)
        elif kind == "zzzj":
            B += TST.sram_record_defaults(d, s, e, label)
        elif kind == "voices":
            body = TV.internal_voice_archive(d, s, e, label, ROMQ.strip('"'))
            rel = os.path.join(jpg_dir, "voices", "internal_archive.s")
            text = "\n".join(["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
                              "# Licensed under the terms of the GNU General Public License v3 or later",
                              "#", "# Table segment 6, the INTERNAL 'JK' voice archive (InternalVoiceArchive).",
                              "# GENERATED by tools/gen_table_voices.py (make table-src); format notes in",
                              "# notes/table-semantics-2026-10-29.md.", ""] + body) + "\n"
            if build != "84":     # its passthroughs name this build's reference image
                rel = os.path.join(jpg_dir, "voices", f"internal_archive_b{build}.s")
            os.makedirs(os.path.dirname(rel), exist_ok=True)
            open(rel, "w").write(text)
            B.append(f'    .include\t"{rel}"')
        elif kind == "pads":
            B += TST.technics_pads(d, s, e, label, jpg_dir, build)
        elif kind == "styles":
            B += TST.style_subtable(d, s, e, label, jpg_dir, build)
        elif kind == "rhythms":
            ss = dirents[59]
            B += TST.rhythms_copy(d, s, e, label, TST.subtable_names(d, ss))
        elif kind == "offtab":
            B += offset_group(d, s, e, label, ROMQ, jpg_dir, TS.GROUPS[i])
        else:
            B.append(f"    .incbin_range\t{ROMQ}, 0x{s:06x}, 0x{e:06x}")
    B += ["", "TableRomImageEnd:"]
    return B, changed


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", default="KN7000 table flash image - byte-exact.")
    ap.add_argument("--jpg-dir", default="src/table",
                    help="where the JPEG segments are kept (as the source's .incbin paths name them)")
    ap.add_argument("--compare", help="another build's table image (per-segment equality)")
    ap.add_argument("--compare-label", default="the other build")
    ap.add_argument("--plugin", help="file range LO:HI of an appended XAPR plug-in")
    ap.add_argument("--plugin-code", help="file range LO:HI of the plug-in's code")
    ap.add_argument("--sym", nargs="*", default=[],
                    help=".sym files: the plug-in's own names first, then everything it calls")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../mame-sony-video/unidasm"))
    a = ap.parse_args()

    d = open(a.rom, "rb").read()
    ROMQ = f'"{a.rom}"'
    dirents = directory(d)
    nseg = len(dirents) - 1
    other = None
    if a.compare:
        od = open(a.compare, "rb").read()
        oe = directory(od)
        other = (od, oe)

    L = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
         "# Licensed under the terms of the GNU General Public License v3 or later",
         "#",
         f"# {a.title}",
         f"# GENERATED by tools/gen_table_s.py -- do not edit by hand.",
         "#",
         f"# Layout: a {len(dirents)}-entry uint32 offset directory at 0x0 (dir[0] = 0x{dirents[0]:X},",
         f"# dir[{nseg}] = 0x{dirents[-1]:X} = end of the directory image), zero padding to",
         f"# 0x{dirents[0]:X}, then {nseg} asset segments. Segment names and comments come from",
         "# tools/table_segments.py; the JPEG segments are files in src/table/.",
         f"# Reference image: {os.path.basename(a.rom)}, SHA-1 {hashlib.sha1(d).hexdigest()}."]
    body, changed = directory_image(d, dirents, ROMQ, a.jpg_dir, other, a.compare_label)
    cur = dirents[-1]

    used, equ = set(), {}
    if a.plugin:
        plo, phi = (int(x, 0) for x in a.plugin.split(":"))
        clo, chi = (int(x, 0) for x in a.plugin_code.split(":"))
        if set(d[cur:plo]) != {0xFF}:
            sys.exit("gen_table_s: gap before the plug-in is not erased flash")
        body += ["", "# ---- erased flash (0xFF) between the directory image and the plug-in ----",
                 f"    .space 0x{plo:06X} - 0x{cur:06X}, 0xFF", f"    .org 0x{plo:06X}"]
        pb, pc = plugin(d, plo, phi, clo, chi, a, ROMQ, used, equ)
        L += pc
        body += pb
        cur = phi
    if set(d[cur:]) <= {0xFF} and cur < len(d):
        body += ["", "# ---- erased flash (0xFF) to the end of the device ----",
                 f"    .space 0x{len(d):06X} - 0x{cur:06X}, 0xFF"]
    elif cur < len(d):
        body.append(f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{len(d):06X}")
    body.append(f".org 0x{len(d):06x}   # end of image")

    L += ["", f'.include "{TST.MACROS}"   # the style format\'s record and event macros',
          "", ".equ TABLE_ROM_BASE, 0x48000000",
          ".mnbase 0x48000000   # CPU address of output offset 0 (for PC-relative ops)"]
    if equ:
        L += ["", f"# {len(equ)} symbols referenced by the plug-in source (CPU addresses)"]
        for nm, v in sorted(equ.items(), key=lambda kv: kv[1]):
            L.append(f".equ {nm}, 0x{v:08X}")
    open(a.out, "w").write("\n".join(L + body) + "\n")
    print(f"wrote {a.out}: {nseg} segments" + (f" ({changed} changed vs {a.compare_label})" if other else "")
          + (f", plug-in 0x{plo:06X}..0x{phi:06X}" if a.plugin else ""))


def code_entries(d, rom, unidasm, base, clo, chi, names, labels=(), extra=()):
    """Entry points of the MN10300 code in file range [clo, chi) of an image linked
    at `base`: the named starts in `names` (except in-code labels and *_entry
    register-save entries), every `call`/`calls` target inside the range, and any
    `extra` addresses (e.g. function pointers found in data). A target 3 bytes past
    an `add -N, sp` frame setup is that function's register-save entry, not a new
    function. Updates `names` with func_<ADDR> / *_entry labels; returns sorted CPU
    addresses."""
    import subprocess
    raw = subprocess.run([unidasm, rom, "-arch", "mn10300", "-basepc", f"0x{base + clo:x}",
                          "-skip", f"0x{clo:x}", "-count", str(chi - clo)],
                         capture_output=True, text=True).stdout
    targets = {int(t, 16) for t in re.findall(r"\scalls?\s+0x([0-9a-f]+)", raw)} | set(extra)
    starts = {c for c in names if clo <= c - base < chi and c not in labels
              and not names[c].endswith("_entry")}
    for t in sorted(targets):
        o = t - base
        if not clo <= o < chi or t in starts:
            continue
        if d[o - 3:o - 1] == b"\xf8\xfe" and (t - 3) in starts:      # X+3 entry of a named X
            names.setdefault(t, names[t - 3] + "_entry")
        elif d[o - 3:o - 1] == b"\xf8\xfe":                         # unnamed X with an +3 entry
            starts.add(t - 3)
            names.setdefault(t - 3, f"func_{t - 3:08X}")
            names.setdefault(t, f"func_{t - 3:08X}_entry")
        elif t not in names or not names[t].endswith("_entry"):
            starts.add(t)
            names.setdefault(t, f"func_{t:08X}")
    return sorted(starts | {base + clo})


def emit_code(d, base, clo, chi, starts, names, notes, ROMQ, used):
    """MN10300 assembly for [clo, chi), split at `starts`: each chunk's mnemonics
    come from unidasm and are kept only where the repo's encoder reproduces the
    exact bytes (else a .byte escape); a chunk whose decode runs off its end stays
    .incbin_range. Returns (lines, chunks converted, chunks kept raw)."""
    B, nconv, nfail = [], 0, 0
    bounds = list(starts) + [base + chi]
    for i, s in enumerate(bounds[:-1]):
        e = bounds[i + 1]
        so, eo = s - base, e - base
        nm = names.get(s, f"func_{s:08X}")
        B.append(f"# {nm}  (CPU 0x{s:08X})")
        if notes.get(s):
            B.append(f"#   {notes[s]}")
        ins = G.disasm_function(d, so, eo, base)
        if ins is None:
            B.append(f".incbin_range {ROMQ}, 0x{so:06X}, 0x{eo:06X}   # decode misaligned: kept raw")
            nfail += 1
            continue
        nconv += 1
        for off, bs, mn, ops in ins:
            cpu = base + off
            if cpu != s and cpu in names:
                kind = ("register-save `call` entry" if names[cpu].endswith("_entry") else
                        notes.get(cpu, "label"))
                B.append(f"# {names[cpu]}:   ({kind})")
                used.add(cpu)
            try:
                enc = G.ASM.encode(mn, ops, cpu)
            except G.ASM.EncError:
                enc = None
            if enc == bs:
                if mn in G.CALL_MNEMS:
                    ops = G.name_target(ops, names, used)
                B.append(f"    {mn:8s}{ops}".rstrip())
            else:
                B.append(f"    .byte {hexbytes(bs)}   # {mn} {ops}".rstrip())
    return B, nconv, nfail


def _asm_str(bs):
    return "".join("\\" + chr(c) if chr(c) in '"\\' else chr(c) if 0x20 <= c < 0x7F else f"\\x{c:02x}"
                   for c in bs)


def typed_gap(d, lo, hi, base, ptr_ok, nm_or_hex):
    """The bytes d[lo:hi] between recognised strings and pointer tables, as typed rows:
    0x00/0xFF fill as .space, NUL-terminated text as .asciz, UTF-16LE character tables
    (the C runtime's and the naming dialogs' character sets) as .word rows, 4-aligned
    pointers into the image as .long, 8-aligned IEEE doubles (the printf/strtod power
    tables) as .long lo, hi with the value, anything else as a commented .byte row.
    -> None when more than a tenth of the gap (and over 16 bytes) is not understood:
    the caller then keeps the gap a passthrough, which the census still counts."""
    out, o, unknown = [], lo, 0

    def printable(c):
        return 0x20 <= c < 0x7F

    def is_double(p):
        if p % 4 or p + 8 > hi:
            return False
        v = struct.unpack_from("<d", d, p)[0]
        return v == v and 1e-300 < abs(v) < 1e300 and float(f"{v:.15g}") == v

    while o < hi:
        b = d[o]
        cls = d[o + 1:o + 129]
        if o + 129 <= hi and b == 0 and cls[0x20] == 0xA0 and cls[0x30] == 0x8C and cls[0x41] == 0x89 \
                and cls[0x61] == 0x8A and cls[0] == 0x10:
            out.append("    # the C runtime's character-class table (ctype): an entry for EOF, then one")
            out.append("    # per character 0x00-0x7F: 0x10 control, 0x30 control + space, 0xA0 blank,")
            out.append("    # 0xC0 punctuation, 0x8C digit, 0x89 / 0x81 upper (hex / other), 0x8A / 0x82 lower")
            out.append("    .byte 0x00   # EOF")
            for i in range(0, 128, 16):
                out.append(f"    .byte {hexbytes(cls[i:i + 16])}   # 0x{i:02x}-0x{i + 15:02x}")
            o += 129
            continue
        if b in (0x00, 0xFF):
            e = o
            while e < hi and d[e] == b:
                if b == 0 and is_double(e):
                    break                    # a double's zero low bytes are not fill
                e += 1
            if e == o:                       # a double starts right here
                e = o + 8
                lo32, hi32 = struct.unpack_from("<II", d, o)
                out.append(f"    .long 0x{lo32:08X}, 0x{hi32:08X}   # double {struct.unpack_from('<d', d, o)[0]:.15g}")
                o = e
                continue
            out.append(f"    .space {e - o}, 0x{b:02X}")
            o = e
            continue
        if o % 4 == 0 and o + 4 <= hi and ptr_ok(struct.unpack_from("<I", d, o)[0]):
            out.append(f"    .long {nm_or_hex(struct.unpack_from('<I', d, o)[0])}")
            o += 4
            continue
        e = o
        while e < hi and printable(d[e]):
            e += 1
        if e - o >= 2 and e < hi and d[e] == 0:
            out.append(f'    .asciz "{_asm_str(d[o:e])}"')
            o = e + 1
            continue
        if True:
            e = o
            while e + 2 <= hi and printable(d[e]) and d[e + 1] == 0:
                e += 2
            if e - o >= 2:
                chars = d[o:e:2]
                for i in range(0, len(chars), 16):
                    seg = chars[i:i + 16]
                    out.append(f"    .word {', '.join(f'0x{c:04X}' for c in seg)}   "
                               f"# UTF-16 \"{_asm_str(seg).replace('#', '?')}\"")
                o = e
                continue
        if o % 4 == 0 and o + 8 <= hi:
            if is_double(o):
                rows = []
                while is_double(o) or (o % 4 == 0 and o + 8 <= hi and   # inside a table: any finite value
                                       1e-300 < abs(struct.unpack_from("<d", d, o)[0]) < 1e300):
                    v = struct.unpack_from("<d", d, o)[0]
                    lo32, hi32 = struct.unpack_from("<II", d, o)
                    rows.append(f"    .long 0x{lo32:08X}, 0x{hi32:08X}   # double {v!r}")
                    o += 8
                out += rows
                continue
        if o % 4 == 0 and o + 4 <= hi and ptr_ok(struct.unpack_from("<I", d, o)[0]):
            out.append(f"    .long {nm_or_hex(struct.unpack_from('<I', d, o)[0])}")
            o += 4
            continue
        if o % 4 == 0 and o + 16 <= hi:   # a run of u32 words that differ only in their low byte
            w0 = struct.unpack_from("<I", d, o)[0]
            e = o
            while e + 4 <= hi and struct.unpack_from("<I", d, e)[0] >> 8 == w0 >> 8 and w0 >> 8:
                e += 4
            if e - o >= 16:
                for p in range(o, e, 4):
                    out.append(f"    .long 0x{struct.unpack_from('<I', d, p)[0]:08X}   # u32 table (CPU 0x{base + p:08X})")
                o = e
                continue
        if o % 4 == 0 and o + 4 <= hi and 0 < struct.unpack_from("<I", d, o)[0] < 0x10000:
            out.append(f"    .long 0x{struct.unpack_from('<I', d, o)[0]:08X}")
            o += 4
            continue
        e = o + 1
        while e < hi and d[e] not in (0x00, 0xFF) and not (e % 4 == 0 and e + 4 <= hi and
                                                            ptr_ok(struct.unpack_from("<I", d, e)[0])):
            e += 1
        out.append(f"    .byte {hexbytes(d[o:e])}   # data (CPU 0x{base + o:08X})")
        unknown += e - o
        o = e
    if unknown > 16 and unknown * 10 > hi - lo:
        return None                          # mostly not understood: the caller keeps it raw
    return out


def plugin(d, plo, phi, clo, chi, a, ROMQ, used, equ):
    """Returns (body lines, extra header-comment lines) for the XAPR plug-in."""
    syms = load_syms(a.sym)
    own = {cpu for cpu in syms if plo <= cpu - BASE < phi}
    names = {cpu: nm for cpu, (nm, _n) in syms.items()}
    # one CPU address per name: a name that also exists elsewhere (e.g. in the
    # program image) keeps it for the plug-in's own address, others get a suffix
    by_name = {}
    for cpu, nm in sorted(names.items(), key=lambda kv: (kv[0] not in own, kv[0])):
        if nm in by_name and by_name[nm] != cpu:
            names[cpu] = f"{nm}_at_{cpu:08X}"
        else:
            by_name[nm] = cpu
    notes = {cpu: n for cpu, (_nm, n) in syms.items()}
    labels = {cpu for cpu, n in notes.items() if n.startswith("label:")}

    G.ROM, G.UNIDASM = a.rom, a.unidasm
    starts = code_entries(d, a.rom, a.unidasm, BASE, clo, chi, names, labels)
    names.setdefault(BASE + clo, f"plugin_code_{BASE + clo:08X}")

    B = ["", "# ============================================================================",
         "# SP7001 XAPR plug-in (the Key Soft Service 'KSS' application resident in",
         "# table flash). Program build 942 validates it with PlugInProbe and calls its",
         "# header slots; see kn7000_sp7001_new.sym and notes/sp7001-build-diff.md.",
         "# ============================================================================"]

    def nm_or_hex(v):
        if v in names:
            used.add(v)
            return names[v]
        return f"0x{v:08X}"

    # ---- header ----
    B += ["", f"# XaprHeader  (CPU 0x{BASE + plo:08X})",
          f"    .byte {hexbytes(d[plo:plo + 4])}   # '{text(d[plo:plo + 4])}' magic"]
    for o in range(plo + 4, clo, 4):
        v = u32(d, o)
        B.append(f"    .long {nm_or_hex(v)}   # +0x{o - plo:02X}")

    # ---- code ----
    lines, nconv, nfail = emit_code(d, BASE, clo, chi, starts, names, notes, ROMQ, used)
    B += lines

    # ---- data: reflection tables, keystream, known strings, the rest raw ----
    special = {}                                   # file off -> (end, lines)
    GS.PROGRAM_BASE = BASE
    GS._is_code = lambda v: clo <= v - BASE < chi
    for code_arr, name_arr, n in GS.find_tables(d, GS._ident_offsets(d)):
        if not chi <= code_arr < phi:
            continue
        rows = [f"# MILK reflection table: {n} code pointers, NUL, {n} name pointers (CPU 0x{BASE + code_arr:08X})"]
        for k in range(n):
            rows.append(f"    .long {nm_or_hex(u32(d, code_arr + 4 * k))}")
        rows.append("    .long 0")
        for k in range(n):
            p = u32(d, name_arr + 4 * k) - BASE
            rows.append(f"    .long 0x{u32(d, name_arr + 4 * k):08X}   # -> \"{text(d[p:d.index(0, p)])}\"")
        special[code_arr] = (name_arr + 4 * n, rows)
    for cpu, (nm, note) in syms.items():
        o = cpu - BASE
        if not chi <= o < phi - 4 or o in special:      # header/footer handled apart
            continue
        if nm == "KssKeystreamRecords":
            rows, p = [f"# {nm}  (CPU 0x{cpu:08X})", f"#   {note}"], o
            while d[p + 20] == 0 and all(c in b"0123456789abcdefghijklmnopqrstuvwxyz" for c in d[p:p + 20]):
                rows.append(f"    .byte {hexbytes(d[p:p + 21])}   # \"{text(d[p:p + 20])}\"")
                p += 21
            special[o] = (p, rows)
            used.add(cpu)
        elif note.startswith("'") or note.startswith('"'):
            end = d.index(0, o) + 1
            rows = [f"# {nm}  (CPU 0x{cpu:08X})", f"    .byte {hexbytes(d[o:end])}   # \"{text(d[o:end - 1])}\""]
            special[o] = (end, rows)
            used.add(cpu)
    foot = phi - 4
    B += ["", "# ---- plug-in data: strings, widget/descriptor tables ----"]
    cur = chi
    for o in sorted(special):
        end, rows = special[o]
        if o < cur:
            continue
        if cur < o:
            B.extend(typed_gap(d, cur, o, BASE, lambda w: BASE + plo <= w < BASE + phi, nm_or_hex)
                     or [f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{o:06X}"])
        B += rows
        cur = end
    if cur < foot:
        B.extend(typed_gap(d, cur, foot, BASE, lambda w: BASE + plo <= w < BASE + phi, nm_or_hex)
                 or [f".incbin_range {ROMQ}, 0x{cur:06X}, 0x{foot:06X}"])
    B += [f"# XaprFooter  (CPU 0x{BASE + foot:08X})",
          f"    .byte {hexbytes(d[foot:phi])}   # '{text(d[foot:phi])}' magic (checked by PlugInProbe)"]

    for v in used:
        equ[names[v]] = v
    for cpu in own:                               # document every plug-in name
        if names[cpu] not in equ:
            equ[names[cpu]] = cpu
    hdr = [f"# Plug-in: {nconv} code chunks converted to MN10300 assembly"
           + (f", {nfail} kept raw (misaligned decode)" if nfail else "") + "."]
    print(f"gen_table_s: plug-in code {nconv} chunks converted, {nfail} raw; "
          f"{len(special)} typed data blocks")
    return B, hdr


if __name__ == "__main__":
    main()
