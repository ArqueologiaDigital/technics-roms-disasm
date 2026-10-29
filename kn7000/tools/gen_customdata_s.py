#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""gen_customdata_s.py -- write the kn7asm source of a factory custom-data flash image.

The image is the CUSTOM STYLE memory: the KN7000's IC21 bank at 0x96820000 (an .AST file of
the custom1/custom2/idd7000 floppies, inflated), or the KN6000/KN6500's (idd6000's
01CTMINI.AST).  Its format is in kn7000/notes/custom-data-ic21.md; the record macros are in
kn7000/src/customdata/customdata.inc.

What the source spells out, as records:
  * the directory (block 0): signature, the 20 slot descriptors, the 60-entry block map;
  * every slot record and every complete stale record (a record in a free block that no
    slot points at): its 0x100-byte header with symbolic offsets and sizes, the "TCMP"
    container header, style record and 20 variation records, the "TPAD" container header,
    bank record and six pad records, every stream header;
  * erased flash as `.space N, 0xff`.
What stays an `.incbin_range` of the (git-ignored) reference, one labelled item each:
  the one-touch-setting panel records, the variation and pad part blocks, the event
  streams, the custom-sound block, and -- declared opaque -- the residue past a record's
  end and the partial stale data in free blocks.

Every item is checked here: the generator models each macro's bytes and compares them with
the image, so a source it writes either rebuilds the image or the generator stops.

Usage:
  gen_customdata_s.py --rom IMAGE --ref REF_PATH_IN_SOURCE --out FILE.s --model kn7000|kn6000
                      --include PATH_OF_customdata.inc --title TEXT [--title TEXT ...]
"""
import argparse
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
    def __init__(self, ref, data):
        self.lines = []
        self.ref = ref
        self.data = data
        self.pos = 0          # image offset the next emitted byte has

    def w(self, s=""):
        self.lines.append(s)

    def emit(self, label, text, model, comment=None):
        """A line that produces exactly `model` bytes at the current offset (checked)."""
        got = self.data[self.pos:self.pos + len(model)]
        if got != model:
            raise SystemExit(f"model mismatch at {self.pos:#x} for {text!r}: {got.hex()} != {model.hex()}")
        lab = f"{label}:" if label else ""
        line = f"{lab}\t{text}" if lab else f"\t{text}"
        if comment:
            line += f"\t# {comment}"
        self.lines.append(line)
        self.pos += len(model)

    def incbin(self, label, n, comment, census=None):
        a, b = self.pos, self.pos + n
        if census:
            self.w(f"\t# census: {census}")
        lab = f"{label}:" if label else ""
        self.w(f'{lab}\t.incbin_range "{self.ref}", {a:#x}, {b:#x}\t# {comment}')
        self.pos = b

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


def gen_record(o, d, base, lab, model, place, slot_of, title):
    """Emit one slot record (or stale record) at image offset base, labelled lab."""
    size, deps, secs = parse_record(d, base, model)
    rec = d[base:base + size]
    o.w()
    o.w(f"# ---- {title}")
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
    o.emit(None, f"CSTREC_PLACE {place}", rec[0xA4:0xA6],
           "as in the directory" if slot_of is not None else "as when it was written")
    o.bytes_run(rec[0xA6:0x100], "+0xA6..+0xFF: RAM residue of the writer's buffer, not read")
    # dependency sections
    for k, (off, cnt) in enumerate(deps):
        if not cnt:
            continue
        o.incbin(f"{lab}_{DEP_NAME[k]}", cnt * DEP_STRIDE[k],
                 f"{cnt} x {DEP_STRIDE[k]:#x}-byte " + ("custom-sound block: 0x27 header, 128 x 3-byte "
                                                        "{program, bank LSB, bank MSB}, 128 x 0x8E voice records "
                                                        "(CustomVoiceRecFetch 0x4844A42F)" if k == 6 else "records"))
    # one touch settings
    ots = OTS_SIZE[model]
    o.w(f"{lab}_Ots:")
    for i in range(4):
        r = rec[secs[0][0] + i * ots:secs[0][0] + (i + 1) * ots]
        if model == "kn7000":
            o.incbin(f"{lab}_Ots{i + 1}", 0x70, f"one touch setting {i + 1}: panel memory")
            o.emit(None, f".byte {r[0x70]}", r[0x70:0x71],
                   "+0x70 its style's CUSTOM slot")
            o.incbin(None, ots - 0x71, "panel memory +0x71..")
        else:
            o.incbin(f"{lab}_Ots{i + 1}", ots, f"one touch setting {i + 1}: panel memory")
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
        o.incbin(None, 0xC0, "part blocks 0..7 (0x18 each)")
    for v in range(20):
        so = u24(t, 0xF0 + v * 0xE0 + 0x15)
        n = u24(t, so + 1)
        nxt = f"{T}_Stream{v + 1:02d}" if v < 19 else f"{T}_End"
        o.emit(f"{T}_Stream{v:02d}", f"STREAM_HEADER {v}, {nxt} - {T}_Stream{v:02d} - 4", t[so:so + 4])
        o.incbin(None, n, f"variation {v} events")
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
        o.incbin(None, 0x30, "part blocks 0..1 (0x18 each)")
        o.emit(None, ".space 8", bytes(8))
    for i in range(6):
        so = u24(p, 0xA0 + i * 0x60 + 0x1D)
        n = u24(p, so + 1)
        nxt = f"{P}_Stream{i + 1}" if i < 5 else f"{P}_End"
        o.emit(f"{P}_Stream{i}", f"STREAM_HEADER {i}, {nxt} - {P}_Stream{i} - 4", p[so:so + 4])
        o.incbin(None, n, f"pad {i + 1} events")
    o.w(f"{P}_End:")
    o.w(f"{lab}_End:")
    return size


def residue(o, d, end, what):
    """Non-erased bytes from o.pos up to the last non-0xFF byte before `end`, as opaque."""
    e = end
    while e > o.pos and d[e - 1] == 0xFF:
        e -= 1
    if e > o.pos:
        o.incbin(None, e - o.pos, what,
                 census=f"opaque -- unknown-dump: {what}; no accessor reads it (probe slack_origin.py)")
    o.fill_ff(end - o.pos)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", required=True)
    ap.add_argument("--ref", required=True, help="the reference path as the source names it")
    ap.add_argument("--out", required=True)
    ap.add_argument("--model", choices=sorted(OTS_SIZE), required=True)
    ap.add_argument("--include", required=True)
    ap.add_argument("--title", action="append", default=[])
    a = ap.parse_args()
    d = open(a.rom, "rb").read()
    if len(d) != NBLOCKS * BLOCK:
        sys.exit(f"{a.rom}: {len(d):#x} bytes, expected {NBLOCKS * BLOCK:#x}")
    o = Out(a.ref, d)
    o.w("# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>")
    o.w("# Licensed under the terms of the GNU General Public License v3 or later")
    o.w("#")
    for t in a.title:
        o.w(f"# {t}")
    o.w("# GENERATED by kn7000/tools/gen_customdata_s.py from the reference image; the format is in")
    o.w("# kn7000/notes/custom-data-ic21.md, the macros in kn7000/src/customdata/customdata.inc.")
    o.w("# The bulk items are .incbin_range of the reference, which the Makefile makes (git-ignored,")
    o.w("# SHA-1 checked) from the softlist floppy's .AST file.")
    o.w()
    o.w(f'.include "{a.include}"')
    o.w()
    # which block starts which slot
    slots = {}
    for s in range(NSLOTS):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if st:
            slots[st] = (s, n)
    o.w("# ---- block 0: the directory")
    o.emit("CustDir", "CUSTDIR_SIGNATURE", b"IK")
    for s in range(NSLOTS):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if st:
            txt = f"CUSTDIR_SLOT (Slot{s:02d} - CustDir) / CUSTOM_BLOCK, {n}"
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
            gen_record(o, d, start, f"Slot{s:02d}", a.model, f"(Slot{s:02d} - CustDir) / CUSTOM_BLOCK, {n}", s,
                       f"slot {s}: \"{name}\", " + (f"block {b}" if n == 1 else f"blocks {b}..{b + n - 1}"))
            residue(o, d, start + n * BLOCK, "residue past the record's end")
            b += n
            continue
        if d[0x2A + b]:
            sys.exit(f"block {b} marked used but no slot starts there")
        # a free block: erased, a complete stale record, or partial stale data
        if set(d[start:start + BLOCK]) == {0xFF}:
            o.fill_ff(BLOCK, f"block {b}: free, erased")
            b += 1
            continue
        try:
            size, _, _ = parse_record(d, start, a.model)
            n = (size + BLOCK - 1) // BLOCK
            if any(d[0x2A + x] for x in range(b, b + n)) or b + n > NBLOCKS:
                raise ValueError("overlaps a live block")
        except ValueError:
            o.w()
            o.w(f"# ---- block {b}: free, holding part of an older record (its start was overwritten)")
            residue(o, d, start + BLOCK, f"block {b}: stale data of an overwritten record")
            b += 1
            continue
        name = printable(d[start + 4:start + 20])
        rec = d[start:start + 0x100]
        gen_record(o, d, start, f"Stale{b:02d}", a.model, f"{rec[0xA4]}, {rec[0xA5]}", None,
                   f"blocks {b}..{b + n - 1}: free, holding a complete older record \"{name}\" that no slot points at")
        residue(o, d, start + n * BLOCK, "residue past the stale record's end")
        b += n
    if o.pos != len(d):
        sys.exit(f"emitted {o.pos:#x} bytes, image is {len(d):#x}")
    open(a.out, "w").write("\n".join(o.lines) + "\n")
    print(f"wrote {a.out}: {len(o.lines)} lines")


if __name__ == "__main__":
    main()
