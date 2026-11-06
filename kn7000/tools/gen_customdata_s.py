#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""gen_customdata_s.py -- write the kn7asm source of a factory custom-data flash image.

The image is the CUSTOM STYLE memory: the KN7000's IC21 bank at 0x96820000 (an .AST file of
the custom1/custom2/idd7000 floppies, inflated), or the KN6000/KN6500's (idd6000's
01CTMINI.AST).  Its format is in kn7000/notes/custom-data-ic21.md; the record macros are in
kn7000/src/customdata/customdata.inc.

What the source spells out, as records (macros of src/customdata/customdata.inc and the shared
src/include/panel_memory.inc / voice_record.inc), one include file per record:
  * the directory (block 0): signature, the 20 slot descriptors, the 60-entry block map;
  * every slot record and every complete stale record (a record in a free block that no slot
    points at): its header with symbolic offsets and sizes, the four one-touch-setting panel
    memories, the custom-sound block (header bytes, 128 voice references, 128 voice records),
    the "TCMP" container (header, style record, 20 variation records with their part set-ups,
    the event streams one event per line) and the "TPAD" container (header, bank, six pads,
    their streams);
  * erased flash as `.space N, 0xff`.
The residue (stale bytes past a record's end and in free blocks) goes to its own include file,
typed by class Cover: spans that repeat a typed record of the --corpus images (same record-
relative offset first, then any offset) are spelled with that record's lines; whole event
streams, variation records and pad records that no record holds, and runs of events, with their
macros; only splinters that match nothing and do not parse stay `.incbin_range` of the
(git-ignored) reference, declared opaque.

Every item is checked here: the generator models each macro's bytes and compares them with
the image, so a source it writes either rebuilds the image or the generator stops.

Usage:
  gen_customdata_s.py --rom IMAGE --ref REF_PATH_IN_SOURCE --out FILE.s --model kn7000|kn6000
                      --include PATH_OF_customdata.inc --title TEXT [--title TEXT ...]

A bank inside a larger image (a whole-chip read, kn7000/src/ic21own/): --base OFFSET takes the bank
from IMAGE at OFFSET, and every `.org` and `.incbin_range` the source holds is that image's offset
(the reference is the whole image); --part writes the bank as a part of a larger source, which
includes the macro files itself, so the part has no `.include` of them.
"""
import argparse
import os
import re
import struct
import sys

BLOCK = 0x8000
NBLOCKS = 60
NSLOTS = 20
OTS_SIZE = {"kn7000": 0xA0, "kn6000": 0x90}
DEP_STRIDE = [0x42] * 5 + [0x2C8, 0x48A7]
DEP_NAME = ["Dep42a", "Dep42b", "Dep42c", "Dep42d", "Dep42e", "SoundEdit", "Voices"]

TCMP_TAIL = bytes([0x00, 0x60, 0x0D, 0x08, 0x04, 0x02, 0x02, 0x01, 0x02, 0x0F])
TPAD_TAIL = bytes([0x00, 0x60, 0x10, 0x06, 0x10, 0x02, 0x00, 0x00, 0x00, 0x0F])


def u24(b, o):
    return b[o] << 16 | b[o + 1] << 8 | b[o + 2]


def be24(v):
    return bytes([(v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF])


def ev_len(d, o):
    """RhyEventLenByStatus / RhySysexLen (program 941 0x484403D5 / 0x484403CD)."""
    c = d[o]
    if c == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(c & 0xF0, 1)


def event_line(d, p, e):
    """(line, length) of the event at d[p], or None when the bytes there are no event the
    firmware's stream reader takes (RhyEventLenByStatus) or it runs past e."""
    c = d[p]
    n = ev_len(d, p)
    if p + n > e:
        return None
    a = d[p + 1:p + n]
    k = c & 0xF0
    if c >= 0x80 and c != 0xF0 and any(x >= 0x80 for x in a):
        return None
    if c == 0xF4:
        return "\tev_beat", 1
    if c == 0xF5:
        return "\tev_end", 1
    if c < 0x80:
        return (f"\tev_at\t{c}", 1) if c <= 95 else None
    if k == 0x90:
        return f"\tev_note\t{c & 15}, {a[0]}, {a[1]}, {a[2]}, {a[3]}, {a[4]}", n
    if k == 0xB0:
        return f"\tev_cc\t{c & 15}, {a[0]}, {a[1]}", n
    if k == 0xC0:
        return f"\tev_pc\t{c & 15}, {a[0]:#04x}, {a[1]:#04x}, {a[2]:#04x}", n
    if k == 0xD0:
        return f"\tev_press\t{c & 15}, {a[0]}", n
    if k == 0xE0:
        return f"\tev_bend\t{c & 15}, {a[0]}, {a[1]}", n
    if c == 0xF0 and n == 6:
        return "\tev_sysex4\t" + ", ".join(f"{x:#04x}" for x in a[1:]), n
    return None


def parse_events(d, s, e):
    """[(line, length)] for d[s:e] when it parses exactly as events, else None."""
    out, p = [], s
    while p < e:
        ev = event_line(d, p, e)
        if ev is None:
            return None
        out.append(ev)
        p += ev[1]
    return out


def event_lines(d, s, e, what):
    """One ev_* line per event of the stream d[s:e]; checked to parse to its end."""
    out = []
    p = s
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        a = d[p + 1:p + n]
        if any(x >= 0x80 for x in a) and c != 0xF0:
            raise SystemExit(f"{what}: data byte >= 0x80 at {p:#x}")
        k = c & 0xF0
        if c == 0xF4:
            out.append("\tev_beat")
        elif c == 0xF5:
            out.append("\tev_end")
        elif c < 0x80:
            out.append(f"\tev_at\t{c}")
        elif k == 0x90:
            out.append(f"\tev_note\t{c & 15}, {a[0]}, {a[1]}, {a[2]}, {a[3]}, {a[4]}")
        elif k == 0xB0:
            out.append(f"\tev_cc\t{c & 15}, {a[0]}, {a[1]}")
        elif k == 0xC0:
            out.append(f"\tev_pc\t{c & 15}, {a[0]:#04x}, {a[1]:#04x}, {a[2]:#04x}")
        elif k == 0xD0:
            out.append(f"\tev_press\t{c & 15}, {a[0]}")
        elif k == 0xE0:
            out.append(f"\tev_bend\t{c & 15}, {a[0]}, {a[1]}")
        elif c == 0xF0 and n == 6:
            out.append("\tev_sysex4\t" + ", ".join(f"{x:#04x}" for x in a[1:]))
        else:
            raise SystemExit(f"{what}: event {c:#x} (length {n}) at {p:#x} has no macro")
        out[-1] = (out[-1], n)
        p += n
    if p != e:
        raise SystemExit(f"{what}: events overrun the stream end")
    if d[e - 1] != 0xF5 or d[s] != 0xF4:
        raise SystemExit(f"{what}: stream does not run F4 .. F5")
    return out


def part_setup(b):
    return "PART_SETUP " + ", ".join(str(x) if i not in (0, 2, 3, 4) else f"{x:#04x}" for i, x in enumerate(b))


def qstr(b):
    """A kn7asm string literal for bytes b (printable ASCII as is, the rest as \\xHH)."""
    out = []
    for c in b:
        if c == 0x22:
            out.append('\\"')
        elif c == 0x5C:
            out.append("\\\\")
        elif 0x20 <= c <= 0x7E:
            out.append(chr(c))
        else:
            out.append(f"\\x{c:02X}")
    return '"' + "".join(out) + '"'


def printable(b):
    return b.decode("latin1").rstrip("\0 ").strip()


class Out:
    def __init__(self, ref, data, base=0):
        self.lines = []
        self.ref = ref
        self.data = data
        self.base = base      # offset of the bank in the reference (--base): added to .org / .incbin_range
        self.pos = 0          # image offset the next emitted byte has
        self.trace = []       # (pos, length, text, comment) of every emitted item
        self.labels = {}      # label -> image offset

    def w(self, s=""):
        m = re.fullmatch(r"(\w+):", s)
        if m:
            self.labels[m.group(1)] = self.pos
        self.lines.append(s)

    def emit(self, label, text, model, comment=None):
        """A line that produces exactly `model` bytes at the current offset (checked)."""
        got = self.data[self.pos:self.pos + len(model)]
        if got != model:
            raise SystemExit(f"model mismatch at {self.pos:#x} for {text!r}: {got.hex()} != {model.hex()}")
        lab = f"{label}:" if label else ""
        if label:
            self.labels[label] = self.pos
        line = f"{lab}\t{text}" if lab else f"\t{text}"
        if comment:
            line += f"\t# {comment}"
        self.lines.append(line)
        self.trace.append((self.pos, len(model), text, comment))
        self.pos += len(model)

    def raw(self, items, n):
        """(line, length) items already checked to produce the next n bytes."""
        for line, k in items:
            self.lines.append(line)
            self.trace.append((self.pos, k, line.strip(), None))
            self.pos += k

    def incbin(self, label, n, comment, census=None):
        a, b = self.base + self.pos, self.base + self.pos + n
        if census:
            self.w(f"\t# census: {census}")
        lab = f"{label}:" if label else ""
        self.w(f'{lab}\t.incbin_range "{self.ref}", {a:#x}, {b:#x}\t# {comment}')
        self.pos += n

    def fill_ff(self, n, comment="erased flash"):
        if n:
            if set(self.data[self.pos:self.pos + n]) != {0xFF}:
                raise SystemExit(f"not erased at {self.pos:#x}+{n:#x}")
            self.w(f"\t.space {n:#x}, 0xff\t# {comment}")
            self.pos += n

    def bytes_run(self, b, comment=None):
        """Small irregular bytes: .ascii for text runs, .space for zero runs, else .byte."""
        i, first = 0, True
        while i < len(b):
            j = i
            while j < len(b) and 0x20 <= b[j] <= 0x7E:
                j += 1
            if j - i >= 4:
                self.emit(None, f".ascii {qstr(b[i:j])}", b[i:j], comment if first else None)
                i, first = j, False
                continue
            j = i
            while j < len(b) and b[j] == 0:
                j += 1
            if j - i >= 4:
                self.emit(None, f".space {j - i}", b[i:j], comment if first else None)
                i, first = j, False
                continue
            j = i
            while j < len(b) and j - i < 16:
                if 0x20 <= b[j] <= 0x7E and len(b) - j >= 4 and all(0x20 <= x <= 0x7E for x in b[j:j + 4]):
                    break
                if b[j] == 0 and b[j:j + 4] == bytes(4):
                    break
                j += 1
            j = max(j, i + 1)
            self.emit(None, ".byte " + ", ".join(f"{x:#04x}" for x in b[i:j]), b[i:j], comment if first else None)
            i, first = j, False


def parse_record(d, base, model):
    """Parse the slot record at image offset `base`; raises ValueError when it is not one."""
    if base + 0x100 > len(d):
        raise ValueError("short")
    h = d[base:base + 0x100]
    size = struct.unpack_from("<I", h, 0)[0]
    if not 0x100 < size <= NBLOCKS * BLOCK or base + size > len(d):
        raise ValueError("size")
    deps = [struct.unpack_from("<II", h, 0x54 + 8 * k) for k in range(7)]
    secs = [struct.unpack_from("<II", h, o) for o in (0x8C, 0x94, 0x9C)]
    pos = 0x100
    for k, (off, cnt) in enumerate(deps):
        if cnt:
            if off != pos:
                raise ValueError("dep offset")
            pos += cnt * DEP_STRIDE[k]
        elif off:
            raise ValueError("dep offset without count")
    for off, sz in secs:
        if off != pos:
            raise ValueError("section offset")
        pos += sz
    if pos != size:
        raise ValueError("sections do not add up")
    if secs[0][1] != 4 * OTS_SIZE[model]:
        raise ValueError("OTS size")
    rec = d[base:base + size]
    for (off, sz), sig, nrec, rs, so, heap in ((secs[1], b"TCMP", 20, 0xE0, 0x15, 0x1270),
                                              (secs[2], b"TPAD", 6, 0x60, 0x1D, 0x2E0)):
        c = rec[off:off + sz]
        if c[:4] != sig or u24(c, 0x10) != sz or u24(c, 0x13) != sz:
            raise ValueError("container")
        p = heap
        for i in range(nrec):
            s = u24(c, (0xF0 if sig == b"TCMP" else 0xA0) + i * rs + so)
            if s != p or c[s] != i or c[s + 4] != 0xF4:
                raise ValueError("stream")
            p = s + 4 + u24(c, s + 1)
            if c[p - 1] != 0xF5:
                raise ValueError("stream end")
        if p != sz:
            raise ValueError("heap")
    return size, deps, secs


PM_PART_MASKS = [None, None, None, 0xFF, 0xDF, 0x03, 0xFF, 0xFF, 0xFF, 0x7F, 0xFF, 0x7F, 0x7F, 0x7F,
                 0x7F, 0x7F, 0x7F, 0xFF, 0x0F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x3F]
MASK_MISS = []
TAIL_OLD = []
CONVERTED = []
# The largest count of a live stream in the ten KN7000 banks is 0x23B9 (probe stream_rules.py); a
# "header" whose count exceeds one 32 KB block is taken for event bytes, not for a cut stream.
MAX_STREAM = 0x8000
# +0x90..+0x9F of func_48485B52_Block (program 941 0x48738FB8), the default 0xA0-byte setting that
# func_48485B52 copies a KN6000 setting's 0x90 bytes over (PM_CONVERT_TAIL in panel_memory.inc)
CONVERT_TAIL = bytes([0x17, 0, 0, 0x17, 0, 0, 0x06, 0, 0, 0x17, 0, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])


def masked(vals, masks, what):
    for v, m in zip(vals, masks):
        if m is not None and v & ~m:
            MASK_MISS.append(what)
    return ", ".join(f"{v:#04x}" for v in vals)


def gen_ots(o, r, lab, i, model):
    """One one-touch-setting panel memory (macros of src/include/panel_memory.inc)."""
    o.emit(lab, "PM_PART " + masked(r[0:0x1A], PM_PART_MASKS, lab), r[0:0x1A], f"setting {i + 1}: part 0")
    for k in (1, 2):
        o.emit(None, "PM_PART " + masked(r[0x1A * k:0x1A * (k + 1)], PM_PART_MASKS, lab), r[0x1A * k:0x1A * (k + 1)],
               f"part {k}")
    o.emit(None, "PM_ENTRIES " + ", ".join(f"{x:#04x}" for x in r[0x4E:0x56]), r[0x4E:0x56])
    o.emit(None, "PM_PART " + masked(r[0x56:0x70], PM_PART_MASKS, lab), r[0x56:0x70], "part 3")
    st = r[0x70:0x77]
    if st[1:3] != b"\x00\x20" or st[4] & 0xCF:
        raise SystemExit(f"{lab}: +0x70 {st.hex()} does not fit PM_STYLE")
    o.emit(None, f"PM_STYLE {st[0]}, {st[3]:#04x}, {st[4] >> 4}, {st[5]:#04x}, {st[6]:#04x}", st,
           "the CUSTOM slot, the setting's number")
    o.emit(None, "PM_SET77 " + masked(r[0x77:0x7A], [0x07, 0x01, 0xFF], lab), r[0x77:0x7A])
    o.emit(None, "PM_FX " + masked(r[0x7A:0x88], [0x88] + [None] * 13, lab), r[0x7A:0x88])
    o.emit(None, "PM_SET88 " + masked(r[0x88:0x8C], [0x04, 0xFF, 0x0F, 0xFF], lab), r[0x88:0x8C])
    o.emit(None, "PM_SET8C " + ", ".join(f"{x:#04x}" for x in r[0x8C:0x8E]), r[0x8C:0x8E])
    if model == "kn7000":
        tails = [r[0x8F + 3 * k:0x92 + 3 * k] for k in range(4)]
        if r[0x8E:0x90] == b"\xff\xff" and r[0x90:0xA0] == CONVERT_TAIL:
            # func_48485B52 (KN6000 file -> KN7000 slot): the 0x90-byte KN6000 setting copied over the
            # default func_48485B52_Block, so the KN6000 record's last two bytes, then the default's tail
            CONVERTED.append(lab)
            o.emit(None, "PM_KN6000_END", r[0x8E:0x90],
                   "+0x8E..+0x8F: a KN6000 setting's end; func_48485B52 converted this setting from a KN6000 file")
            o.emit(None, "PM_CONVERT_TAIL", r[0x90:0xA0], "+0x90..+0x9F: func_48485B52_Block's, the default it copied over")
            return
        if all(t[0] & ~0x07 == 0 for t in tails):
            o.emit(None, f".byte {r[0x8E]:#04x}", r[0x8E:0x8F], "+0x8E: not written by func_4C02A0C4")
            for k, t in enumerate(tails):
                o.emit(None, "PM_PART_TAIL " + ", ".join(f"{x:#04x}" for x in t), t, f"part {k}")
        else:
            TAIL_OLD.append(lab)
            o.bytes_run(r[0x8E:0x9B], "+0x8E..+0x9A: not what programs 893 and 941 write here (PM_PART_TAIL x4: its "
                                      "p23 masks 0x07 do not hold; their writers and tables are the same), so the bytes "
                                      "of a writer older than program 893")
        o.emit(None, ".space 5, 0xff", r[0x9B:0xA0])
    else:
        o.emit(None, ".space 2, 0xff", r[0x8E:0x90])


def gen_record(o, d, base, lab, model, place, slot_of, title):
    """Emit one slot record (or stale record) at image offset base, labelled lab."""
    size, deps, secs = parse_record(d, base, model)
    rec = d[base:base + size]
    o.w()
    o.w(f"# ---- {title}")
    o.w(f".org {o.base + base:#x}")
    o.emit(lab, f"CSTREC_SIZE {lab}_End - {lab}", rec[0:4])
    names = [rec[4 + 16 * i:20 + 16 * i] for i in range(5)]
    o.emit(None, f"CSTREC_NAME {qstr(names[0])}", names[0], "style name")
    for i in range(1, 5):
        o.emit(None, f"CSTREC_NAME {qstr(names[i])}", names[i], f"one touch setting {i}")
    for k, (off, cnt) in enumerate(deps):
        txt = f"CSTREC_DEPS {lab}_{DEP_NAME[k]} - {lab}, {cnt}" if cnt else "CSTREC_DEPS 0, 0"
        o.emit(None, txt, rec[0x54 + 8 * k:0x5C + 8 * k], f"{DEP_STRIDE[k]:#x}-byte records" if k == 0 or cnt else None)
    for (off, sz), nm in zip(secs, ("Ots", "Tcmp", "Tpad")):
        o.emit(None, f"CSTREC_SECTION {lab}_{nm} - {lab}, {lab}_{nm}_End - {lab}_{nm}",
               rec[0x8C:0x94] if nm == "Ots" else rec[0x94:0x9C] if nm == "Tcmp" else rec[0x9C:0xA4])
    written = f"{rec[0xA4]}, {rec[0xA5]}"
    if slot_of is None:
        why = "as when it was written"
    elif written == place:
        why = "as in the directory"
    else:                         # the record was written for other blocks (a slot copied from another)
        why = f"as when it was written; the directory places it at {place}"
    o.emit(None, f"CSTREC_PLACE {written}", rec[0xA4:0xA6], why)
    o.bytes_run(rec[0xA6:0x100], "+0xA6..+0xFF: RAM residue of the writer's buffer, not read")
    # dependency sections
    for k, (off, cnt) in enumerate(deps):
        if not cnt:
            continue
        if k == 6 and cnt == 1:
            vb = rec[off:off + 0x48A7]
            o.w(f"# the custom-sound block (CustomVoiceRecFetch 0x4844A42F): a TABLE tone, a user kit -- the")
            o.w(f"# tone head (0x27 bytes), one voice reference per note (TgNoteOnTableTone), 128 voice records")
            o.w(f"# of 0x8E bytes (customdata.inc, CSOUND_HEAD)")
            o.w(f"{lab}_{DEP_NAME[k]}:")
            o.emit(None, f"CSOUND_HEAD {qstr(vb[0:16])}, " + ", ".join(f"{x:#04x}" for x in vb[16:0x27]),
                   vb[0:0x27], "the kit's tone head: name, class 0x40 (TABLE), 22 bytes as every factory kit")
            for i in range(128):
                t = vb[0x27 + 3 * i:0x2A + 3 * i]
                o.emit(None, f"VOICE_REF {t[0]:#04x}, {t[1]:#04x}, {t[2]:#04x}", t, f"note {i}" if i % 16 == 0 else None)
            for i in range(128):
                v = vb[0x1A7 + 0x8E * i:0x1A7 + 0x8E * (i + 1)]
                o.emit(f"{lab}_Voice{i:03d}", f"VOICE_HEAD {qstr(v[0:13])}, {v[13]:#04x}, {v[14]:#04x}, {v[15]:#04x}",
                       v[0:16], f"voice {i}")
                for k in range(2):
                    b = v[0x10 + 0x1C * k:0x2C + 0x1C * k]
                    o.emit(None, "VOICE_SUB " + ", ".join(f"{x:#04x}" for x in b), b, f"sub-record {k}")
                for k in range(2):
                    b = v[0x48 + 0x23 * k:0x6B + 0x23 * k]
                    o.emit(None, "VOICE_ELEM " + ", ".join(f"{x:#04x}" for x in b), b, f"element {k}")
            continue
        o.incbin(f"{lab}_{DEP_NAME[k]}", cnt * DEP_STRIDE[k], f"{cnt} x {DEP_STRIDE[k]:#x}-byte records")
    # one touch settings
    ots = OTS_SIZE[model]
    o.w(f"{lab}_Ots:")
    for i in range(4):
        r = rec[secs[0][0] + i * ots:secs[0][0] + (i + 1) * ots]
        gen_ots(o, r, f"{lab}_Ots{i + 1}", i, model)
    o.w(f"{lab}_Ots_End:")
    # TCMP
    t0, tsz = secs[1]
    t = rec[t0:t0 + tsz]
    T = f"{lab}_Tcmp"
    hdr = (b"TCMP" + bytes(12) + be24(tsz) * 2 + b"\0\x01" + TCMP_TAIL + bytes(14) + b" " * 64)
    o.emit(T, f"TCMP_HEADER {T}_End - {T}", hdr)
    sr = t[0x70:0xF0]
    model_sr = sr[0:0x50] + bytes(range(20)) + bytes(12) + sr[0x70:0x74] + bytes(12)
    if model_sr != sr:
        raise SystemExit(f"style record at {o.pos:#x} does not fit TCMP_STYLE")
    vn = [qstr(sr[0x10 + 16 * i:0x20 + 16 * i]) for i in range(4)]
    o.emit(f"{T}_Style", f"TCMP_STYLE {qstr(sr[0:16])}, {', '.join(vn)}, "
           f"{(sr[0x70] << 8 | sr[0x71]):#06x}, {(sr[0x72] << 8 | sr[0x73]):#06x}", sr)
    for v in range(20):
        r = t[0xF0 + v * 0xE0:0x1D0 + v * 0xE0]
        so = u24(r, 0x15)
        model_v = (r[0:12] + bytes(4) + r[0x10:0x12] + bytes(3) + be24(so) + r[0x18:0x1A] + bytes(6))
        if model_v != r[0:0x20]:
            raise SystemExit(f"variation record at {o.pos:#x} does not fit TCMP_VAR")
        args = [f"{x:#04x}" for x in r[0:4]] + [f"{x:#04x}" for x in r[4:12]] + \
               [str(r[0x10]), str(r[0x11]), f"{T}_Stream{v:02d} - {T}", f"{r[0x18]:#04x}", f"{r[0x19]:#04x}"]
        bars = (r[0x10] + 1) * ((r[0x11] & 7) + 1)
        o.emit(f"{T}_Var{v:02d}", "TCMP_VAR " + ", ".join(args), model_v, f"variation {v}: {bars} bars")
        for k in range(8):
            o.emit(None, part_setup(r[0x20 + 0x18 * k:0x38 + 0x18 * k]), r[0x20 + 0x18 * k:0x38 + 0x18 * k],
                   f"part {k}")
    for v in range(20):
        so = u24(t, 0xF0 + v * 0xE0 + 0x15)
        n = u24(t, so + 1)
        nxt = f"{T}_Stream{v + 1:02d}" if v < 19 else f"{T}_End"
        o.emit(f"{T}_Stream{v:02d}", f"STREAM_HEADER {v}, {nxt} - {T}_Stream{v:02d} - 4", t[so:so + 4])
        o.raw(event_lines(t, so + 4, so + 4 + n, f"{T} variation {v}"), n)
    o.w(f"{T}_End:")
    # TPAD
    p0, psz = secs[2]
    p = rec[p0:p0 + psz]
    P = f"{lab}_Tpad"
    hdr = (b"TPAD" + bytes(12) + be24(psz) * 2 + b"\0\x01" + TPAD_TAIL + bytes(14) + b" " * 64)
    o.emit(P, f"TPAD_HEADER {P}_End - {P}", hdr)
    bank = p[0x70:0xA0]
    model_b = bank[0:16] + bytes(sum(([0, i, 0x20] for i in range(6)), [])) + bytes(14)
    if model_b != bank:
        raise SystemExit(f"bank record at {o.pos:#x} does not fit TPAD_BANK")
    o.emit(f"{P}_Bank", f"TPAD_BANK {qstr(bank[0:16])}", bank)
    for i in range(6):
        r = p[0xA0 + i * 0x60:0x100 + i * 0x60]
        so = u24(r, 0x1D)
        model_p = r[0:0x1D] + be24(so) + bytes(8)
        if model_p != r[0:0x28] or r[0x58:0x60] != bytes(8):
            raise SystemExit(f"pad record at {o.pos:#x} does not fit TPAD_PAD")
        args = [qstr(r[0:16])] + [f"{x:#04x}" for x in r[0x10:0x1D]] + [f"{P}_Stream{i} - {P}"]
        o.emit(f"{P}_Pad{i}", "TPAD_PAD " + ", ".join(args), model_p, f"pad {i + 1}")
        for k in range(2):
            o.emit(None, part_setup(r[0x28 + 0x18 * k:0x40 + 0x18 * k]), r[0x28 + 0x18 * k:0x40 + 0x18 * k],
                   f"part {k}")
        o.emit(None, ".space 8", bytes(8))
    for i in range(6):
        so = u24(p, 0xA0 + i * 0x60 + 0x1D)
        n = u24(p, so + 1)
        nxt = f"{P}_Stream{i + 1}" if i < 5 else f"{P}_End"
        o.emit(f"{P}_Stream{i}", f"STREAM_HEADER {i}, {nxt} - {P}_Stream{i} - 4", p[so:so + 4])
        o.raw(event_lines(p, so + 4, so + 4 + n, f"{P} pad {i}"), n)
    o.w(f"{P}_End:")
    o.w(f"{lab}_End:")
    return size


OPAQUE_WHY = ["unknown-dump: residue of an earlier write that no typed record of the nine sets holds "
              "(no 32-byte match at any offset) and that does not parse as events (probe residue_cover.py)"]
# (a list so that --opaque-why can replace the text)
COVER_STATS = {"donor": 0, "stream": 0, "events": 0, "opaque": 0}


def residue(o, d, end, what, cover, base=None, put=None, name=None):
    """The non-erased bytes from o.pos up to the last non-0xFF byte before `end`: typed from the
    records whose bytes they repeat, parsed as event streams, else declared opaque; then the
    erased rest."""
    e = end
    while e > o.pos and d[e - 1] == 0xFF:
        e -= 1
    if e > o.pos:
        if cover is None:
            o.pos = e                      # a dry run (building the corpus): the residue is not needed
        else:
            main_lines, o.lines = o.lines, []
            o.w(f"# {what}: stale bytes of earlier writes, {e - o.pos:#x} bytes from {o.pos:#x}")
            cover.emit(o, d, o.pos, e, base)
            body, o.lines = o.lines, main_lines
            o.w(f'.include "{put(name, body)}"')
    o.fill_ff(end - o.pos)


NUM_ARG = re.compile(r"[0-9a-fA-Fx\s+\-()]+")


def numeric(text, labels):
    """A donor's line with its label names replaced by their values and each argument folded to
    one number, so it can stand anywhere."""
    t = re.sub(r"\b[A-Za-z_]\w*\b", lambda m: hex(labels[m.group(0)]) if m.group(0) in labels else m.group(0), text)
    parts = t.split(None, 1)
    if len(parts) < 2:
        return t
    args = []
    for a in re.findall(r'"(?:[^"\\]|\\.)*"|[^,]+', parts[1]):
        a = a.strip()
        if NUM_ARG.fullmatch(a) and re.search(r"[+\-]", a):
            v = eval(a, {"__builtins__": {}}, {})
            a = f"{v:#x}"
        args.append(a)
    return parts[0] + " " + ", ".join(args)


class Cover:
    """Types residue from a corpus of typed records (every record of every set given)."""
    K = 32

    def __init__(self, corpus):
        self.recs = corpus            # [(name, data, base, size, items, labels)]
        self.idx = {}
        for ci, (name, data, base, size, items, labels) in enumerate(corpus):
            for off in range(0, size - self.K + 1, 8):
                self.idx.setdefault(data[base + off:base + off + self.K], (ci, off))

    def match(self, d, p, e):
        best = None
        for j in range(8):
            if p + j + self.K > e:
                break
            h = self.idx.get(bytes(d[p + j:p + j + self.K]))
            if h is None:
                continue
            ci, off = h[0], h[1] - j
            if off < 0:
                continue
            name, data, base, size, _, _ = self.recs[ci]
            n = 0
            lim = min(e - p, size - off)
            while n < lim and data[base + off + n] == d[p + n]:
                n += 1
            if n >= self.K and (best is None or n > best[2]):
                best = (ci, off, n)
        return best

    def same_offset(self, d, p, e, rel):
        """The longest match for d[p:e] in a record at the same record-relative offset `rel`."""
        best = None
        for ci, (name, data, base, size, _, _) in enumerate(self.recs):
            if rel >= size or data[base + rel:base + rel + self.K] != d[p:p + self.K]:
                continue
            n, lim = 0, min(e - p, size - rel)
            while n < lim and data[base + rel + n] == d[p + n]:
                n += 1
            if best is None or n > best[2]:
                best = (ci, rel, n)
        return best

    # Macros whose arguments are the item's bytes one to one, so the same line can be spelled from
    # other bytes; ranges[(kind, length)] = the (min, max) of each byte over the corpus's items.
    REFORMAT = ("PART_SETUP", "PM_PART", "PM_PART_TAIL", "PM_ENTRIES", "PM_STYLE", "PM_SET77", "PM_FX", "PM_SET88",
                "PM_SET8C", "STREAM_HEADER", "TCMP_VAR", "TCMP_STYLE", "TPAD_PAD", ".ascii")

    def ranges_of(self):
        if hasattr(self, "_ranges"):
            return self._ranges
        r = {}
        for name, data, base, size, items, labels in self.recs:
            for pos, k, text, _ in items:
                kind = text.split(None, 1)[0]
                if kind not in self.REFORMAT:
                    continue
                b = data[pos:pos + k]
                cur = r.get((kind, k))
                r[(kind, k)] = [(x, x) for x in b] if cur is None else \
                    [(min(lo, x), max(hi, x)) for (lo, hi), x in zip(cur, b)]
        self._ranges = r
        return r

    def reformat(self, kind, d, r, k, e):
        """The donor line `kind` (k bytes) spelled from the residue's bytes d[r:r+k], when they have
        the shape the corpus's items of that macro have: (text, length), else None.  An event line
        starts a run of events instead: (lines, length)."""
        if kind.startswith("ev_"):
            q, nst = self.run_end(d, r, e)
            return (parse_events(d, r, q), q - r) if q > r and nst >= 1 else None
        if kind not in self.REFORMAT or r + k > e:
            return None
        b = d[r:r + k]
        rg = self.ranges_of().get((kind, k))
        if kind == ".ascii":
            return (f".ascii {qstr(b)}", k) if all(0x20 <= x <= 0x7E for x in b) else None
        if kind == ".byte" and k == 1:        # a one-byte field line (e.g. +0x8E of a setting)
            return f".byte {b[0]:#04x}", k
        in_range = rg is not None and all(lo <= x <= hi for (lo, hi), x in zip(rg, b))
        if not in_range and not (kind == "PART_SETUP" and max(b) <= 0x7F):
            return None
        if kind == "PART_SETUP" and k == 24:
            return part_setup(b), k
        if kind in ("PM_PART", "PM_PART_TAIL", "PM_ENTRIES", "PM_SET77", "PM_FX", "PM_SET88", "PM_SET8C"):
            return f"{kind} " + ", ".join(f"{x:#04x}" for x in b), k
        if kind == "PM_STYLE" and k == 7 and b[1:3] == b"\x00\x20" and not b[4] & 0xCF:
            return f"PM_STYLE {b[0]}, {b[3]:#04x}, {b[4] >> 4}, {b[5]:#04x}, {b[6]:#04x}", k
        if kind == "STREAM_HEADER" and k == 4:
            return f"STREAM_HEADER {b[0]}, {u24(b, 1):#x}", k
        if kind == "TCMP_VAR" and k == 0x20 and b[0x0C:0x10] == bytes(4) and b[0x12:0x15] == bytes(3) \
                and b[0x1A:0x20] == bytes(6):
            args = [f"{x:#04x}" for x in b[0:12]] + [str(b[0x10]), str(b[0x11]), f"{u24(b, 0x15):#x}",
                                                     f"{b[0x18]:#04x}", f"{b[0x19]:#04x}"]
            return "TCMP_VAR " + ", ".join(args), k
        if kind == "TCMP_STYLE" and k == 0x80 and b[0x50:0x64] == bytes(range(20)) and b[0x64:0x70] == bytes(12) \
                and b[0x74:0x80] == bytes(12):
            vn = [qstr(b[0x10 + 16 * i:0x20 + 16 * i]) for i in range(4)]
            return (f"TCMP_STYLE {qstr(b[0:16])}, {', '.join(vn)}, {(b[0x70] << 8 | b[0x71]):#06x}, "
                    f"{(b[0x72] << 8 | b[0x73]):#06x}"), k
        if kind == "TPAD_PAD" and k == 0x28 and b[0x20:0x28] == bytes(8):
            args = [qstr(b[0:16])] + [f"{x:#04x}" for x in b[0x10:0x1D]] + [f"{u24(b, 0x1D):#x}"]
            return "TPAD_PAD " + ", ".join(args), k
        return None

    def put_reformat(self, o, d, r, got, kind, note):
        text, n = got
        if isinstance(text, list):
            o.w(f"\t# stale events of an earlier write, at an event boundary of the donor record: {note}")
            o.raw(text, n)
        else:
            o.emit(None, text, d[r:r + n], f"stale `{kind}` of an earlier write, other values than the donor's "
                                            f"line at the same place: {note}")
        COVER_STATS["shaped"] = COVER_STATS.get("shaped", 0) + n

    def follow(self, o, d, m, r, e, tail):
        """Donor match m ended at residue offset r in the middle of the donor line `tail` = (pos, k,
        text): spell that line, and the donor's next lines in place, from the residue's own bytes as
        long as they keep the line's shape (reformat); a line whose bytes equal the donor's keeps its
        text.  When the partial line itself does not keep its shape, its matched bytes are spelled as
        bytes, as before.  Returns the new residue offset."""
        ci, off, n = m
        name, data, base, size, items, labels = self.recs[ci]
        shift = (r - n) - (base + off)      # residue offset = donor offset + shift
        note = f"{name} +{off + n:#x}.."
        pos0, k0, text0 = tail
        q0 = pos0 + shift
        got = self.reformat(text0.split(None, 1)[0], d, q0, k0, e)
        if got is None:
            o.bytes_run(data[pos0:pos0 + (r - q0)], f"stale tail of an earlier write; same bytes as {name} "
                        f"+{pos0 - base:#x}..; bytes 0..{r - q0 - 1} of `{text0.split(None, 1)[0]}`")
            COVER_STATS["donor"] += r - q0
            return r
        self.put_reformat(o, d, q0, got, text0.split(None, 1)[0], note)
        r = q0 + got[1]
        if text0.startswith("ev_"):
            return r
        for pos, k, text, comment in items:
            if pos <= pos0:
                continue
            q = pos + shift
            if q != r or q + k > e:
                break
            kind = text.split(None, 1)[0]
            if data[pos:pos + k] == d[q:q + k]:
                o.emit(None, numeric(text, labels), d[q:q + k], f"stale tail of an earlier write; same bytes as {note}")
                COVER_STATS["donor"] += k
                r = q + k
                continue
            got = self.reformat(kind, d, q, k, e)
            if got is None:
                break
            self.put_reformat(o, d, q, got, kind, note)
            r = q + got[1]
            if kind.startswith("ev_"):
                break                        # events realign; the main loop goes on from here
        return r

    def emit(self, o, d, s, e, base=None):
        p, gap = s, s
        while p < e:
            m = None
            if base is not None and p == gap and p + self.K <= e:
                m = self.same_offset(d, p, e, p - base)
            if m is None:
                m = self.match(d, p, e) if p + self.K <= e else None
            if m is None:
                p += 1
                continue
            p0 = p
            h = self.head(m, d, p, gap, e)
            if h is not None:
                r0, got, kind, note = h
                if gap < r0:
                    self.gap(o, d, gap, r0)
                self.put_reformat(o, d, r0, got, kind, note)
                p = gap = r0 + got[1]
                if p > p0:
                    continue
                m = self.trim(m, p - p0)
            else:
                st = self.straddle(m, d, p, gap, e) if gap < p else None
                if st is not None:
                    t, q = st
                    if gap < t:
                        self.gap(o, d, gap, t)
                    o.w("\t# stale events of an earlier write: the last one runs into the next piece, which "
                        "starts there on a line boundary of the donor record")
                    o.raw(parse_events(d, t, q), q - t)
                    COVER_STATS["events"] += q - t
                    m = self.trim(m, q - p)
                    p = q
                elif gap < p:
                    self.gap(o, d, gap, p)
            p = self.donor(o, m, d, p, e)
            gap = p
        if gap < e:
            self.gap(o, d, gap, e)

    def head(self, m, d, p, gap, e):
        """When donor match m starts mid-line and that line's start lies in the gap before it, the
        line spelled from the residue's bytes: (start, reformat result, kind, note), else None."""
        ci, off, n = m
        name, data, base, size, items, labels = self.recs[ci]
        a = base + off
        for pos, k, text, comment in items:
            if pos < a < pos + k:
                r0 = p - (a - pos)
                if r0 < gap:
                    return None
                kind = text.split(None, 1)[0]
                got = self.reformat(kind, d, r0, k, e)
                return None if got is None else (r0, got, kind, f"{name} +{pos - base:#x}..")
            if pos >= a:
                return None
        return None

    def straddle(self, m, d, p, gap, e):
        """The gap before donor match m (at residue offset p) ends with the start of an event whose
        rest is the match's first bytes: (t, q) when d[t:q] (gap <= t < p < q <= p + 6) parses as
        events (a position byte followed by its status event, or a status event), and the donor has a
        line starting at q's place; else None."""
        ci, off, n = m
        name, data, base, size, items, labels = self.recs[ci]
        starts = {pos for pos, k, text, comment in items}
        for t in range(max(gap, p - 6), p):
            c = d[t]
            if c in (0xF4, 0xF5):
                continue
            q, last = t, -1
            while q <= p:
                ev = event_line(d, q, len(d))
                if ev is None:
                    break
                if d[q] < 0x80 and (q + 1 >= len(d) or d[q + 1] < 0x80 or d[q + 1] in (0xF4, 0xF5)):
                    break
                q += ev[1]
            if p < q <= min(p + 6, p + n) and (base + off + (q - p)) in starts and parse_events(d, t, q):
                return t, q
        return None

    @staticmethod
    def trim(m, k):
        ci, off, n = m
        return ci, off + k, n - k

    def donor(self, o, m, d, p, e):
        """Spell donor match m at residue offset p with the donor's lines; when it ends mid-line,
        follow the donor's structure (follow).  Returns the new residue offset."""
        ci, off, n = m
        if n <= 0:
            return p
        name, data, base, size, items, labels = self.recs[ci]
        a, b = base + off, base + off + n
        first = True
        note = f"stale tail of an earlier write; same bytes as {name} +{off:#x}..+{off + n:#x}"
        tail = None
        for pos, k, text, comment in items:
            if pos + k <= a or pos >= b:
                continue
            lo, hi = max(pos, a), min(pos + k, b)
            if lo == pos and hi == pos + k:
                o.emit(None, numeric(text, labels), data[pos:pos + k], note if first else None)
            elif hi < pos + k and p + n < e and not (first and lo > pos):
                tail = (pos, k, text)        # the line the match ends in: follow() spells it
                break
            else:
                o.bytes_run(data[lo:hi], (note + "; " if first else "") + f"bytes {lo - pos}..{hi - pos - 1} of `"
                            + text.split(None, 1)[0] + "`")
            first = False
        r = p + n
        if tail is None:
            COVER_STATS["donor"] += n
            nxt = next(((pos, k, text) for pos, k, text, comment in items if pos == b), None)
            if nxt is not None and r < e:      # the match ended on a line boundary: follow from the next line
                r = self.follow(o, d, m, r, e, nxt)
            return r
        COVER_STATS["donor"] += tail[0] - a if tail[0] > a else 0
        return self.follow(o, d, m, r, e, tail)

    @staticmethod
    def stream_at(d, h, e):
        """The length of a whole event stream {index, u24 count, F4 .. F5} at h, or None."""
        if h + 5 > e or d[h] >= 20:
            return None
        n = u24(d, h + 1)
        if n < 2 or h + 4 + n > e or d[h + 4] != 0xF4 or d[h + 3 + n] != 0xF5:
            return None
        return 4 + n if parse_events(d, h + 4, h + 4 + n) is not None else None

    @staticmethod
    def var_at(d, x, e):
        """True when d[x:x+0xE0] has the shape of a TCMP variation record: its zero fields, per-part
        bytes in {0, 1, 0x10, 0x11} and eight part set-ups with CC94 = 64 and CC96 = 12."""
        if x + 0xE0 > e or d[x + 0x0C:x + 0x10] != bytes(4) or d[x + 0x12:x + 0x15] != bytes(3) \
                or d[x + 0x1A:x + 0x20] != bytes(6) or any(b not in (0, 1, 0x10, 0x11) for b in d[x + 4:x + 12]):
            return False
        return all(d[x + 0x20 + 0x18 * k + 5] == 0x40 and d[x + 0x20 + 0x18 * k + 9] == 0x0C for k in range(8))

    @staticmethod
    def pad_at(d, x, e):
        """True when d[x:x+0x60] has the shape of a TPAD pad record: a printable 16-byte name, its
        zero fields and two part set-ups with CC94 = 64."""
        if x + 0x60 > e or any(not (0x20 <= b <= 0x7E) for b in d[x:x + 16]) \
                or d[x + 0x20:x + 0x28] != bytes(8) or d[x + 0x58:x + 0x60] != bytes(8):
            return False
        return d[x + 0x28 + 5] == 0x40 and d[x + 0x40 + 5] == 0x40

    def cut_stream_at(self, d, h, e):
        """The length of a stream's start at h whose end the next write cut: {index < 20, u24
        count, F4} right after a stream's end (F5: streams are contiguous) and events that parse,
        with the stream rules, for 16 bytes or more or up to e; or None."""
        if h + 5 > e or d[h] >= 20 or d[h + 4] != 0xF4 or u24(d, h + 1) > MAX_STREAM or self.stream_at(d, h, e) \
                or d[h - 1] != 0xF5:
            return None
        q, nst = self.run_end(d, h + 4, e)
        return q - h if (q - h - 4 >= 16 and nst >= 2) or (q == e and nst >= 1) else None

    @staticmethod
    def head_at(d, h, e):
        """A stream header {index < 20, u24 count} whose stream goes on in the next piece: the F4
        that starts every stream follows it (d[h + 4], also past e)."""
        return h + 4 == e and h + 4 < len(d) and d[h] < 20 and d[h + 4] == 0xF4 and 2 <= u24(d, h + 1) <= MAX_STREAM \
            and d[h - 1] == 0xF5

    @staticmethod
    def container_at(d, h, e):
        """The length of a "TCMP" / "TPAD" container header at h (signature, zero descriptor, equal
        u24BE length and top), whole (0x70) or cut by e (0x16 bytes or more), else None."""
        if h + 0x16 > e or d[h:h + 4] not in (b"TCMP", b"TPAD") or d[h + 4:h + 0x10] != bytes(12) \
                or d[h + 0x10:h + 0x13] != d[h + 0x13:h + 0x16]:
            return None
        return min(0x70, e - h)

    @staticmethod
    def pad_head_at(d, x, e):
        """True when d[x:x+0x28] is the first 0x28 bytes of a TPAD pad record (TPAD_PAD): a printable
        16-byte name and the eight zero bytes at +0x20."""
        return x + 0x28 <= e and all(0x20 <= b <= 0x7E for b in d[x:x + 16]) and d[x + 0x20:x + 0x28] == bytes(8) \
            and any(b != 0x20 for b in d[x:x + 16])

    def gap(self, o, d, s, e):
        """Bytes no record holds: whole streams and variation records, the tail of a stream before
        one, the cut start of a stream, container and pad headers, events, else opaque."""
        p = s
        while p < e:
            h = next((x for x in range(p, e) if self.stream_at(d, x, e) or self.var_at(d, x, e)
                      or self.pad_at(d, x, e) or self.cut_stream_at(d, x, e) or self.head_at(d, x, e)
                      or self.container_at(d, x, e) or self.pad_head_at(d, x, e)), None)
            if h is None:
                self.events_or_opaque(o, d, p, e, tail=False)
                return
            if h > p:
                self.events_or_opaque(o, d, p, h, tail=True)
            if self.var_at(d, h, e):
                r = d[h:h + 0xE0]
                args = [f"{x:#04x}" for x in r[0:12]] + [str(r[0x10]), str(r[0x11]), f"{u24(r, 0x15):#x}",
                                                        f"{r[0x18]:#04x}", f"{r[0x19]:#04x}"]
                o.emit(None, "TCMP_VAR " + ", ".join(args), r[0:0x20],
                       "stale variation record of an earlier write (no record holds it; it has the record's shape)")
                for k in range(8):
                    o.emit(None, part_setup(r[0x20 + 0x18 * k:0x38 + 0x18 * k]), r[0x20 + 0x18 * k:0x38 + 0x18 * k])
                COVER_STATS["var"] = COVER_STATS.get("var", 0) + 0xE0
                p = h + 0xE0
                continue
            if self.pad_at(d, h, e):
                r = d[h:h + 0x60]
                args = [qstr(r[0:16])] + [f"{x:#04x}" for x in r[0x10:0x1D]] + [f"{u24(r, 0x1D):#x}"]
                o.emit(None, "TPAD_PAD " + ", ".join(args), r[0:0x28],
                       "stale pad record of an earlier write (no record holds it; it has the record's shape)")
                for k in range(2):
                    o.emit(None, part_setup(r[0x28 + 0x18 * k:0x40 + 0x18 * k]), r[0x28 + 0x18 * k:0x40 + 0x18 * k])
                o.emit(None, ".space 8", bytes(8))
                COVER_STATS["pad"] = COVER_STATS.get("pad", 0) + 0x60
                p = h + 0x60
                continue
            if not (self.var_at(d, h, e) or self.pad_at(d, h, e) or self.stream_at(d, h, e)
                    or self.cut_stream_at(d, h, e)):
                if self.container_at(d, h, e):
                    n = self.container_at(d, h, e)
                    sig = d[h:h + 4].decode()
                    if n == 0x70:
                        model = (d[h:h + 4] + bytes(12) + d[h + 0x10:h + 0x16] + b"\x00\x01"
                                 + (bytes([0, 0x60, 0x0D, 8, 4, 2, 2, 1, 2, 0x0F]) if sig == "TCMP"
                                    else bytes([0, 0x60, 0x10, 6, 0x10, 2, 0, 0, 0, 0x0F])) + bytes(14) + b" " * 64)
                        if model == d[h:h + 0x70]:
                            o.emit(None, f"{sig}_HEADER {u24(d, h + 0x10):#x}", model,
                                   f"stale {sig} container header of an earlier write (no record holds it)")
                            COVER_STATS["shaped"] = COVER_STATS.get("shaped", 0) + n
                            p = h + n
                            continue
                    o.bytes_run(d[h:h + min(n, 0x16)], f"stale start of a {sig}_HEADER of an earlier write: signature, "
                                f"zero descriptor, length and top {u24(d, h + 0x10):#x} (cut by the next piece)")
                    COVER_STATS["shaped"] = COVER_STATS.get("shaped", 0) + min(n, 0x16)
                    p = h + min(n, 0x16)
                    continue
                if self.head_at(d, h, e):
                    o.emit(None, f"STREAM_HEADER {d[h]}, {u24(d, h + 1):#x}", d[h:h + 4],
                           "stale stream header of an earlier write; its stream (from the F4 after it) is the next piece")
                    COVER_STATS["stream"] += 4
                    p = h + 4
                    continue
                r = d[h:h + 0x28]
                args = [qstr(r[0:16])] + [f"{x:#04x}" for x in r[0x10:0x1D]] + [f"{u24(r, 0x1D):#x}"]
                o.emit(None, "TPAD_PAD " + ", ".join(args), r,
                       "stale first 0x28 bytes of a pad record of an earlier write (name, settings, stream offset, zeros)")
                COVER_STATS["pad"] = COVER_STATS.get("pad", 0) + 0x28
                p = h + 0x28
                continue
            n = self.stream_at(d, h, e)
            if not n:
                n = self.cut_stream_at(d, h, e)
                o.emit(None, f"STREAM_HEADER {d[h]}, {u24(d, h + 1):#x}", d[h:h + 4],
                       f"stale start of a stream of an earlier write, cut after {n - 4:#x} of its {u24(d, h + 1):#x} "
                       "bytes by the next write (no record holds it; it parses as events)")
                o.raw(parse_events(d, h + 4, h + n), n - 4)
                COVER_STATS["stream"] += n
                p = h + n
                continue
            o.emit(None, f"STREAM_HEADER {d[h]}, {n - 4:#x}", d[h:h + 4],
                   "stale stream of an earlier write (no record holds it; it parses as events)")
            o.raw(parse_events(d, h + 4, h + n), n - 4)
            COVER_STATS["stream"] += n
            p = h + n

    @staticmethod
    def run_end(d, p, e):
        """How far events parse from p, with the stream rules the firmware's own streams keep: a
        position byte (0..95) is followed by an event, and positions do not fall within a beat (the
        live streams of the ten KN7000 banks repeat a position 43,611 times and lower one once,
        probe kn7000/notes/ic21-own-probes/stream_rules.py).  Returns (end, number of status events)."""
        q, last, nst, ok = p, -1, 0, p
        while q < e:
            ev = event_line(d, q, e)
            if ev is None:
                break
            c = d[q]
            if c < 0x80:
                if c < last or q + 1 >= e or d[q + 1] < 0x80 or d[q + 1] in (0xF4, 0xF5):
                    break
                last = c
            elif c == 0xF4:
                last = -1
            else:
                nst += 1
            q += ev[1]
            if c >= 0x80:
                ok = q
            if c == 0xF5:
                break
        return ok, nst

    @staticmethod
    def exact_events(d, s, e):
        """True when d[s:e] parses exactly as events, a position byte (0..95) being followed by a
        status event (looking at d[e] for the last one) and positions not falling within a beat."""
        items = parse_events(d, s, e)
        if not items:
            return False
        q, last = s, -1
        for line, k in items:
            c = d[q]
            if c < 0x80:
                nxt = d[q + 1] if q + 1 < len(d) else 0
                if c < last or nxt < 0x80 or nxt in (0xF4, 0xF5):
                    return False
                last = c
            elif c == 0xF4:
                last = -1
            q += k
        return True

    def events_or_opaque(self, o, d, s, e, tail):
        """d[s:e], which no record holds and which holds no whole stream: runs of at least 16 bytes
        and two status events that parse as events (ev_*), the rest opaque."""
        p, opq = s, s
        # a short piece that parses exactly as events, the position rule looking past e: its
        # neighbours are typed bytes of the same stream (two donor pieces, or a donor and the end)
        if e - s <= 16 and self.exact_events(d, s, e):
            o.w("\t# stale events of an earlier write between two typed pieces: they parse exactly as events")
            o.raw(parse_events(d, s, e), e - s)
            COVER_STATS["events"] += e - s
            return
        # right after a stream's end (F5): the data bytes of an event of an earlier, longer stream
        # whose status byte the newer stream overwrote, when events parse after them
        if s > 0 and d[s - 1] == 0xF5:
            for k in range(1, 6):
                if s + k < e and all(x < 0x80 for x in d[s:s + k]):
                    q, nst = self.run_end(d, s + k, e)
                    if q - (s + k) >= 6 and nst >= 1:
                        o.emit(None, ".byte " + ", ".join(f"{x:#04x}" for x in d[s:s + k]), d[s:s + k],
                               f"[INFERENCE] the last {k} data byte(s) of an event of an earlier, longer stream; its "
                               "status byte lies under the newer stream that ends just before")
                        COVER_STATS["events"] += k
                        p = opq = s + k
                        break
        while p < e:
            q, nst = self.run_end(d, p, e)
            if q < e and q + 1 == e and d[q] < 0x80 and e < len(d) and 0x80 <= d[e] < 0xF4 and q > p:
                q = e                         # a last position byte whose event is the next piece's first
            short_bounded = q == e and nst >= 1 and e - p <= 16 and e < len(d) and 0x80 <= d[e] < 0xF4
            if (q - p >= 16 and nst >= 2) or (q - p >= 2 and nst >= 1 and d[q - 1] == 0xF5) or short_bounded:
                if opq < p:
                    o.incbin(None, p - opq, "stale bytes of an earlier write", census=f"opaque -- {OPAQUE_WHY[0]}")
                    COVER_STATS["opaque"] += p - opq
                o.w("\t# stale events of an earlier write: no record holds them; they parse as events")
                o.raw(parse_events(d, p, q), q - p)
                COVER_STATS["events"] += q - p
                p = opq = q
            else:
                p += 1
        if opq < e and e % BLOCK == 0 and 0x80 <= d[opq] < 0xF4 and opq + ev_len(d, opq) > e \
                and all(x < 0x80 for x in d[opq + 1:e]):
            o.emit(None, ".byte " + ", ".join(f"{x:#04x}" for x in d[opq:e]), d[opq:e],
                   f"the first {e - opq} byte(s) of an event of an earlier write, cut by the end of the record's last block")
            COVER_STATS["events"] += e - opq
            opq = e
        if opq < e:
            o.incbin(None, e - opq, "stale bytes of an earlier write", census=f"opaque -- {OPAQUE_WHY[0]}")
            COVER_STATS["opaque"] += e - opq


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", required=True)
    ap.add_argument("--ref", required=True, help="the reference path as the source names it")
    ap.add_argument("--out", required=True)
    ap.add_argument("--model", choices=sorted(OTS_SIZE), required=True)
    ap.add_argument("--include", required=True)
    ap.add_argument("--title", action="append", default=[])
    ap.add_argument("--shared", default="src/include",
                    help="directory of panel_memory.inc / voice_record.inc as the source names it")
    ap.add_argument("--inc-dir", help="directory of the per-record include files, as the source names it"
                                      " and relative to the current directory (default: --out without .s)")
    ap.add_argument("--corpus", nargs="*", default=[],
                    help="images (NAME=PATH) whose records type the residue; the image itself is added")
    ap.add_argument("--base", type=lambda v: int(v, 0), default=0,
                    help="offset of the bank in --rom (a whole-chip image); .org / .incbin_range are --rom offsets")
    ap.add_argument("--part", action="store_true",
                    help="a part of a larger source that includes the macro files itself")
    ap.add_argument("--opaque-why", help="the reason of the residue's census: opaque markers")
    a = ap.parse_args()
    if a.opaque_why:
        OPAQUE_WHY[0] = a.opaque_why

    def load(path):
        data = open(path, "rb").read()
        return data[a.base:a.base + NBLOCKS * BLOCK] if path == a.rom else data
    corpus = []
    me = os.path.basename(a.out)[:-2]
    for spec in [c for c in a.corpus if c.split("=", 1)[0] != me] + [f"{me}={a.rom}"]:
        name, path = spec.split("=", 1)
        data = load(path)
        oc, _, _ = generate(a, data, None, dry=True)
        for lab, base, size, items in oc.records:
            corpus.append((f"{name} {lab}", data, base, size, items, oc.labels))
    cover = Cover(corpus)
    MASK_MISS.clear()
    TAIL_OLD.clear()
    CONVERTED.clear()
    o, written, inc_dir = generate(a, load(a.rom), cover)
    open(a.out, "w").write("\n".join(o.lines) + "\n")
    for f in sorted(os.listdir(inc_dir)):
        if f.endswith(".inc") and f not in written:
            os.remove(os.path.join(inc_dir, f))
    print(f"wrote {a.out}: {len(o.lines)} lines; {len(MASK_MISS)} stored bytes outside their field mask, "
          f"{len(TAIL_OLD)} settings without the 941 part tails, {len(CONVERTED)} converted from KN6000 settings; "
          f"residue bytes {COVER_STATS}")


def generate(a, d, cover, dry=False):
    """The image source's lines (o.lines) and its records' traces (o.records); a dry run writes no
    include files and skips the residue."""
    if len(d) != NBLOCKS * BLOCK:
        sys.exit(f"image: {len(d):#x} bytes, expected {NBLOCKS * BLOCK:#x}")
    o = Out(a.ref, d, a.base)
    o.records = []
    inc_dir = a.inc_dir or a.out[:-2]
    if not dry:
        os.makedirs(inc_dir, exist_ok=True)
    written = set()

    def record(lab, *args):
        """gen_record into its own include file, which the image source includes."""
        main_lines = o.lines
        o.lines = []
        t0 = len(o.trace)
        size = gen_record(o, d, *args[:1], lab, *args[1:])
        o.records.append((lab, args[0], size, o.trace[t0:]))
        body, o.lines = o.lines, main_lines
        if dry:
            return
        o.w()
        o.w(f'.include "{put(lab, body)}"')

    def put(name, body):
        path = os.path.join(inc_dir, f"{name}.inc")
        with open(path, "w") as f:
            f.write(f"# {name}: part of {os.path.basename(a.out)}; GENERATED by "
                    f"kn7000/tools/gen_customdata_s.py\n" + "\n".join(body) + "\n")
        written.add(f"{name}.inc")
        return path
    o.w("# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>")
    o.w("# Licensed under the terms of the GNU General Public License v3 or later")
    o.w("#")
    for t in a.title:
        o.w(f"# {t}")
    o.w("# GENERATED by kn7000/tools/gen_customdata_s.py from the reference image; the format is in")
    o.w("# kn7000/notes/custom-data-ic21.md, the macros in kn7000/src/customdata/customdata.inc.")
    o.w("# Everything is typed. Only residue that matches no typed record and does not parse (census:")
    if a.part:
        o.w("# opaque) is an .incbin_range of the reference, which the Makefile copies (git-ignored,")
        o.w(f"# SHA-1 checked). The including source holds the macro files; offsets are those of the")
        o.w(f"# whole reference image, in which this bank starts at {a.base:#x}.")
        o.w()
    else:
        o.w("# opaque) is an .incbin_range of the reference, which the Makefile makes (git-ignored,")
        o.w("# SHA-1 checked) from the softlist floppy's .AST file.")
        o.w()
        o.w(f'.include "{a.include}"')
        o.w(f'.include "{a.shared}/panel_memory.inc"')
        o.w(f'.include "{a.shared}/voice_record.inc"')
        o.w()
    # which block starts which slot
    slots = {}
    for s in range(NSLOTS):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if st:
            slots[st] = (s, n)
    o.w("# ---- block 0: the directory")
    if a.part:
        o.w(f".org {a.base:#x}")
    o.emit("CustDir", "CUSTDIR_SIGNATURE", b"IK")
    for s in range(NSLOTS):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if st:
            txt = f"CUSTDIR_SLOT {st}, {n}"
            name = printable(d[st * BLOCK + 4:st * BLOCK + 20])
            o.emit(None, txt, bytes([st, n]), f"slot {s}: {name}")
        else:
            o.emit(None, "CUSTDIR_SLOT 0, 0", bytes(2), f"slot {s}: empty")
    for k in range(0, NBLOCKS, 10):
        m = d[0x2A + k:0x34 + k]
        o.emit(None, "CUSTDIR_BLOCKS " + ", ".join(str(x) for x in m), m, f"blocks {k}..{k + 9}")
    o.fill_ff(BLOCK - o.pos, "erased: the rest of the directory block")
    b = 1
    while b < NBLOCKS:
        start = b * BLOCK
        if b in slots:
            s, n = slots[b]
            name = printable(d[start + 4:start + 20])
            record(f"Slot{s:02d}", start, a.model, f"{b}, {n}", s,
                       f"slot {s}: \"{name}\", " + (f"block {b}" if n == 1 else f"blocks {b}..{b + n - 1}"))
            residue(o, d, start + n * BLOCK, "residue past the record's end", cover, start, put, f"Slot{s:02d}_Residue")
            b += n
            continue
        if d[0x2A + b]:
            sys.exit(f"block {b} marked used but no slot starts there")
        # a free block: erased, a complete stale record, or partial stale data
        if set(d[start:start + BLOCK]) == {0xFF}:
            o.fill_ff(BLOCK, f"block {b}: free, erased")
            b += 1
            continue
        # A KN7000 bank can also hold a stale record in the KN6000 layout (0x90-byte one-touch
        # settings): AstLoadHandler / LoadCst load a KN6000 file's records as they are, then
        # func_48485B52 rebuilds each one in the KN7000 layout into newly allocated blocks
        # (kn7000/notes/ic21-own/README.md); the original stays in its old, freed blocks.
        rec_model = a.model
        try:
            try:
                size, _, _ = parse_record(d, start, a.model)
            except ValueError as e:
                if a.model != "kn7000" or str(e) != "OTS size":
                    raise
                size, _, _ = parse_record(d, start, "kn6000")
                rec_model = "kn6000"
            n = (size + BLOCK - 1) // BLOCK
            if any(d[0x2A + x] for x in range(b, b + n)) or b + n > NBLOCKS:
                raise ValueError("overlaps a live block")
        except ValueError:
            o.w()
            o.w(f"# ---- block {b}: free, holding part of an older record (its start was overwritten)")
            residue(o, d, start + BLOCK, f"block {b}: stale data of an overwritten record", cover, None, put,
                    f"Block{b:02d}_Residue")
            b += 1
            continue
        name = printable(d[start + 4:start + 20])
        rec = d[start:start + 0x100]
        layout = "" if rec_model == a.model else (
            " in the KN6000 layout (0x90-byte one-touch settings): a record loaded from a KN6000 file, "
            "left behind when func_48485B52 rebuilt it in the KN7000 layout")
        record(f"Stale{b:02d}", start, rec_model, f"{rec[0xA4]}, {rec[0xA5]}", None,
                   f"blocks {b}..{b + n - 1}: free, holding a complete older record \"{name}\" that no slot points at"
                   + layout)
        residue(o, d, start + n * BLOCK, "residue past the stale record's end", cover, start, put, f"Stale{b:02d}_Residue")
        b += n
    if o.pos != len(d) and not dry:
        sys.exit(f"emitted {o.pos:#x} bytes, image is {len(d):#x}")
    return o, written, inc_dir


if __name__ == "__main__":
    main()
