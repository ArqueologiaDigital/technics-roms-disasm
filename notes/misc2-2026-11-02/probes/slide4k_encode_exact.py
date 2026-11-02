#!/usr/bin/env python3
"""slide4k_encode_exact.py -- does lzss_j.encode (N = 4096, F = 18) make every factory SLIDE4K stream BYTE?

QUESTION IT ANSWERS
  notes/misc-2026-10-31/probes/slide4k_vs_okumura.py showed the factory decisions are lzss_j.encode's.  For the
  build to drop its reference streams (register row N-700df83b) the encoder must give every byte the decoder
  reads, and the bytes after the stream must be accounted for.  For each of the 19 in-ROM demo blocks
  (original_ROMs/demo_preset_NN_compressed.original.bin, header read from original_ROMs/kn5000_table_data.rom)
  and the three Sub-CPU update images (original_ROMs/kn5000_subprogram_v14N_compressed.rom) it decodes the
  stream, re-encodes the plain bytes with scripts/build/compress_lzss.py's compress_slide4k() and prints:
    EXACT        encode() == the factory stream, every byte
    PAD 0xNN     encode() + that one byte == the slice; the slice ends on an even ROM address (alignment pad)
    TAIL n       encode() is a prefix and n more bytes follow (demo songs 17 and 18: slide4k_stale_tails.py)
  It also prints, per demo block, the ROM address right after the slice and the byte there.
  Measured 2026-11-02: 14 EXACT (11 demo blocks and the 3 update images), 6 PAD (01, 06, 07, 08, 10, 12: 0x00,
  0x7D, 0x7D, 0xC5, 0x43, 0x0B), 2 TAIL (17: 15,957 B, 18: 75 B).  Every block that another block follows ends
  before an even address (the next "SLIDE4K", byte 0x53); block 00's stream ends before an odd one, and its pad
  is the 0xFF that the source's `.org` writes.

RUN (repository root)
  python3 notes/misc2-2026-11-02/probes/slide4k_encode_exact.py
"""
import glob
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts/build"))
import compress_lzss  # noqa: E402

lzss_j = None


def main():
    global lzss_j
    compress_lzss.compress_slide4k(b"")          # sets lzss_j's SLIDE4K parameters
    import lzss_j as L
    lzss_j = L
    rom = open(os.path.join(ROOT, "original_ROMs/kn5000_table_data.rom"), "rb").read()
    files = (sorted(glob.glob(os.path.join(ROOT, "original_ROMs", "demo_preset_*_compressed.original.bin")))
             + sorted(glob.glob(os.path.join(ROOT, "original_ROMs", "kn5000_subprogram_v14?_compressed.rom"))))
    tally = {}
    for p in files:
        raw = open(p, "rb").read()
        where = ""
        if raw[:7] == b"SLIDE4K":
            n, c = int.from_bytes(raw[8:11], "big"), raw[11:]
        else:
            at = rom.find(raw[:64]) - 11
            assert at >= 0 and rom[at:at + 7] == b"SLIDE4K", p
            n, c = int.from_bytes(rom[at + 8:at + 11], "big"), raw
            end = 0x800000 + at + 11 + len(c)
            where = "  slice ends before 0x%06X (%s), byte there 0x%02X" % (end, "even" if end % 2 == 0 else "ODD",
                                                                     rom[at + 11 + len(c)])
        plain, used = lzss_j.decode(c, n)
        e = compress_lzss.compress_slide4k(plain)
        if e == c:
            r = "EXACT"
        elif c.startswith(e) and len(c) == len(e) + 1:
            r = "PAD 0x%02X" % c[-1]
        elif c.startswith(e):
            r = "TAIL %d" % (len(c) - len(e))
        else:
            r = "DIFFERENT"
        tally[r.split()[0]] = tally.get(r.split()[0], 0) + 1
        print("%-40s %7d B plain, stream %6d B: %-10s%s" % (os.path.basename(p), n, len(e), r, where))
    print(", ".join("%s %d" % kv for kv in sorted(tally.items())))
    return 0 if "DIFFERENT" not in tally else 1


if __name__ == "__main__":
    sys.exit(main())
