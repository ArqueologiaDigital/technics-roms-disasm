#!/usr/bin/env python3
"""wsa1_f7df_runs.py -- what are the 0xDF / 0xF7 bytes in the WSA1R qsdisk's 01WORKS_.SEQ block 838?

QUESTION IT ANSWERS (register rows N-391cb1d1 / O-wsa1-floppy-unknown-dump-66b9a5)
  The 250 bytes of block 838 after its 0x82 parse as no song event.  This finds, on all nine WSA1R disks,
  every run of >= 32 bytes made only of 0xFF, 0xF7 and 0xDF (with >= 8 not 0xFF), says which file and which
  .SEQ block holds it (numbered as the source numbers them: block n is file offset (n - 1) x 256, a 5-byte
  header and 251 bytes), and per run prints, for each file offset mod 4, which values occur.  If the
  bytes are left-over RAM contents that nothing wrote, their pattern should follow the RAM address, not the
  song data: the same phase pattern in every run, in a block the song chains do not reach.
  Measured 2026-11-02 (qsdisk only; the other eight disks have none), three runs, all in 01WORKS_.SEQ:
    block 245 +68, 188 B: FF FF FF F7 by offset mod 4, the last block of a live chain, after its 0x82 and
    some stale events;
    block 837 +7, 249 B, the last block of a live chain, right after its 0x82: DF / F7 by offset parity, some
    bytes FF;
    block 838 +6, 250 B, after the 0x82 of a block in no chain: exactly DF F7 repeated 125 times (DF at even
    file offsets).  Every byte is 0xFF with bit 3 and/or bit 5 cleared, nothing else.  No WSA1R source
    holds 0xF7DF / 0xDFF7 as a constant (`command grep -rni "0xf7df|0xdff7" wsa1`).
  Reading: [INFERENCE] RAM of the block store holding a pattern nothing wrote (power-on contents) after the
  blocks' 0x82; not song data, not a copy.  Block 838's run is spelled as `.rept 125` of `0xdf, 0xf7`
  (floppy/wsa1/formats.py), no longer opaque.

RUN (repository root; the floppy references built: make -C floppy refs-wsa1)
  python3 notes/misc2-2026-11-02/probes/wsa1_f7df_runs.py
"""
import collections
import glob
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "floppy", "tools"))
import fat12lib  # noqa: E402

S = {0xFF, 0xF7, 0xDF}


def file_map(img):
    """(start, end, path, file offset of start) of every cluster of every file."""
    out = []
    for c, (e, k) in img.owner.items():
        o = img.cluster_offset(c)
        out.append((o, o + img.bpb.cluster_bytes, e.path() if callable(getattr(e, "path", None)) else str(e),
                    k * img.bpb.cluster_bytes))
    return sorted(out)


def main():
    for p in sorted(glob.glob(os.path.join(ROOT, "floppy", "wsa1", "baserom", "*.img"))):
        d = open(p, "rb").read()
        img = fat12lib.Image(d)
        fm = file_map(img)
        i, runs = 0, []
        while i < len(d):
            if d[i] in S:
                j = i
                while j < len(d) and d[j] in S:
                    j += 1
                if j - i >= 32 and sum(x != 0xFF for x in d[i:j]) >= 8:
                    runs.append((i, j - i))
                i = j
            else:
                i += 1
        print("%s: %d runs" % (os.path.basename(p), len(runs)))
        for o, n in runs:
            where = [(path, fo + (o - a)) for a, b, path, fo in fm if a <= o < b]
            path, fo = where[0] if where else ("(no file)", None)
            blk = "" if fo is None or not path.upper().endswith(".SEQ") else \
                "  block %d +%d" % (fo // 256 + 1, fo % 256)
            ph = collections.defaultdict(collections.Counter)
            for k in range(n):
                q = (fo + k) if fo is not None else (o + k)
                ph[q % 4][d[o + k]] += 1
            bits = collections.Counter()
            for x in d[o:o + n]:
                bits[(~x) & 0xFF] += 1
            print("  image 0x%06X, %3d B, %s file +0x%X%s" % (o, n, path, fo if fo is not None else -1, blk))
            print("     cleared-bit masks: %s" % ", ".join("0x%02X x%d" % kv for kv in sorted(bits.items())))
            print("     by (file offset mod 4): %s" % "; ".join(
                "%d: %s" % (r, " ".join("%02X x%d" % kv for kv in sorted(ph[r].items()))) for r in range(4)))


if __name__ == "__main__":
    main()
