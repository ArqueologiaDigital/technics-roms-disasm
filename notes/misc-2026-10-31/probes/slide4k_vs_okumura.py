#!/usr/bin/env python3
"""slide4k_vs_okumura.py -- does Okumura's LZSS.C (N = 4096, F = 18) also make the KN5000's SLIDE4K decisions?

QUESTION IT ANSWERS
  slide8k_vs_lzss_j.py shows the SLIDE8K help streams are lzss_j.encode's output.  lzss_j.py's docstring says
  SLIDE4K is "the same coder with N = 4096, F = 18, a 4-bit length".  This probe re-encodes every SLIDE4K demo
  stream -- the 19 demo presets (original_ROMs/demo_preset_NN_compressed.original.bin, no header: the size is
  read from the 11-byte "SLIDE4K" header in front of the slice in original_ROMs/kn5000_table_data.rom) and the three Sub-CPU update images (original_ROMs/kn5000_subprogram_v14N_compressed.rom,
  11-byte header with the size) -- with lzss_j's encoder
  re-parameterised to N = 4096, F = 18, 4-bit length, and compares the decisions with the factory stream's.
  A finding only: compress_lzss.py still replays (this probe changes no build rule).

RUN (repository root)
  python3 notes/misc-2026-10-31/probes/slide4k_vs_okumura.py
"""
import glob
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "floppy/tools/kd"))
import lzss_j  # noqa: E402

lzss_j.N, lzss_j.F, lzss_j.LENBITS = 0x1000, 18, 4


def items(c, n, lenbits):
    out, i, got = [], 0, 0
    while got < n and i < len(c):
        f = c[i]
        i += 1
        for b in range(8):
            if got >= n or i >= len(c):
                break
            if f >> b & 1:
                out.append(("L", c[i]))
                i += 1
                got += 1
            else:
                if i + 1 >= len(c):          # a reference cut by the end of a headerless slice
                    return out, len(c) + 1
                lo, hi = c[i], c[i + 1]
                i += 2
                ln = (hi & ((1 << lenbits) - 1)) + 3
                out.append(("R", lo | (hi >> lenbits) << 8, ln))
                got += ln
    return out, i


def plain_of(c, n):
    """Decode c to n bytes (n = None: to the end of c, dropping a reference cut short by the slice's end)."""
    w = bytearray(0x1000)
    wp, out = 0x1000 - 18, bytearray()
    its, used = items(c, n if n is not None else 1 << 30, 4)
    if n is None and its and its[-1][0] == "R" and used > len(c):
        its = its[:-1]
    for it in its:
        for k in range(1 if it[0] == "L" else it[2]):
            x = it[1] if it[0] == "L" else w[(it[1] + k) & 0xFFF]     # byte by byte: a reference may overlap
            out.append(x)
            w[wp] = x
            wp = (wp + 1) & 0xFFF
    return bytes(out if n is None else out[:n]), used


def main():
    same = 0
    files = (sorted(glob.glob(os.path.join(ROOT, "original_ROMs", "demo_preset_*_compressed.original.bin")))
             + sorted(glob.glob(os.path.join(ROOT, "original_ROMs", "kn5000_subprogram_v14?_compressed.rom"))))
    rom = open(os.path.join(ROOT, "original_ROMs", "kn5000_table_data.rom"), "rb").read()
    for p in files:
        raw = open(p, "rb").read()
        if raw[:7] == b"SLIDE4K":
            n, c = int.from_bytes(raw[8:11], "big"), raw[11:]
        else:
            at = rom.find(raw[:64]) - 11
            assert at >= 0 and rom[at:at + 7] == b"SLIDE4K", p
            n, c = int.from_bytes(rom[at + 8:at + 11], "big"), raw
        plain, used = plain_of(c, n)
        n = len(plain)
        enc = lzss_j.encode(plain)
        a, _ = items(c, n, 4)
        b, _ = items(enc, n, 4)
        k = next((j for j in range(min(len(a), len(b))) if a[j] != b[j]), None)
        ok = a == b
        diff = "" if ok else " (factory %s, encode %s)" % (a[k:k + 2], b[k:k + 2])
        same += ok
        print("%s  %6d B -> factory %6d B (%d read), encode %6d B: %s"
              % (os.path.basename(p), n, len(c), used, len(enc),
                 "SAME DECISIONS" if ok else "first difference at item %s of %d%s" % (k, len(a), diff)))
    print("%d of %d streams: lzss_j.encode (N=4096, F=18) makes the factory decisions" % (same, len(files)))


if __name__ == "__main__":
    main()
