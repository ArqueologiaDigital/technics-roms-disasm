#!/usr/bin/env python3
"""slide8k_vs_lzss_j.py -- is the SX-KN7000 'J KD' LZSS the KN5000's SLIDE8K, encoder included?

QUESTION IT ANSWERS
  floppy/tools/kd/lzss_j.py decodes and re-encodes every 'J KD' part bit for bit (Okumura LZSS.C, N = 8192,
  F = 10, 3-bit length).  scripts/build/compress_slide8k.py packs the KN5000 table data's six SLIDE8K help
  databases by REPLAYING the factory decisions read from original_ROMs/help_db_<lang>_compressed.original.bin.
  For each of the six streams this probe:
    1. decodes it with lzss_j.decode (0x9000 bytes, the header's size) and with decompress_slide8k.py, and
       checks the two outputs agree (same format);
    2. re-encodes the decoded bytes (german_stale: only its first 0x55E0, where help_databases.s says the
       block was cut) with lzss_j.encode (no reference) and compares with the factory stream:
       how many leading bytes agree, whether the factory stream = encode() + a tail, and where they part.
  If every stream re-encodes byte-exact (up to the pad byte and the unread high bits of the last flag byte
  that compress_slide8k.py's docstring describes), compress_slide8k.py could drop the reference.

RUN (repository root)
  python3 notes/misc-2026-10-31/probes/slide8k_vs_lzss_j.py
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "floppy/tools/kd"))
sys.path.insert(0, os.path.join(ROOT, "scripts/build"))
import lzss_j                      # noqa: E402
import decompress_slide8k as d8    # noqa: E402

SIZE = 0x9000
LANGS = ["english", "german", "french", "spanish", "indonesian", "german_stale"]
CUT = {"german_stale": 0x55E0}     # table_data/help_databases.s: the stale block's stream is intact to here


def decisions(c, n):
    """The literal / reference items of stream c up to n output bytes, and the bytes consumed."""
    items, i, got = [], 0, 0
    while got < n and i < len(c):
        f = c[i]
        i += 1
        for b in range(8):
            if got >= n or i >= len(c):
                break
            if f >> b & 1:
                items.append(("L", c[i]))
                i += 1
                got += 1
            else:
                lo, hi = c[i], c[i + 1]
                i += 2
                ln = (hi & 7) + 3
                items.append(("R", lo | (hi >> 3) << 8, ln))
                got += ln
    return items, i


def main():
    allx = True
    for lang in LANGS:
        ref = open(os.path.join(ROOT, "original_ROMs", "help_db_%s_compressed.original.bin" % lang), "rb").read()
        plain, used = lzss_j.decode(ref, SIZE)
        other, _ = d8.decompress_slide8k(d8.MAGIC + SIZE.to_bytes(3, "big") + ref)
        same_fmt = bytes(plain) == bytes(other)[:len(plain)]
        if lang in CUT:
            plain = plain[:CUT[lang]]
        enc = lzss_j.encode(bytes(plain))
        a, ua = decisions(ref, len(plain))
        b, ub = decisions(enc, len(plain))
        k = next((j for j in range(min(len(a), len(b))) if a[j] != b[j]), min(len(a), len(b)))
        same_items = a == b
        prefix = next((j for j in range(min(len(ref), len(enc))) if ref[j] != enc[j]), min(len(ref), len(enc)))
        print("%-12s plain %5d B (%s), factory stream %5d B (%d read), encode() %5d B; items %d vs %d, "
              "first differing item %s; byte prefix equal %d; %s"
              % (lang, len(plain), "formats agree" if same_fmt else "FORMATS DIFFER", len(ref), used, len(enc),
                 len(a), len(b), "none" if same_items else k, prefix,
                 "SAME DECISIONS" if same_items else "factory %s / encode %s" % (a[k:k + 2], b[k:k + 2])))
        allx &= same_items
    print("verdict:", "lzss_j.encode makes the factory decisions for every stream" if allx
          else "lzss_j.encode does NOT reproduce every factory stream")
    return 0 if allx else 1


if __name__ == "__main__":
    sys.exit(main())
