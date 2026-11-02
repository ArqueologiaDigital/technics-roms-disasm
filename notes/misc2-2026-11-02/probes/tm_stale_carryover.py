#!/usr/bin/env python3
"""tm_stale_carryover.py -- where do the 38 stale .TM checksum words of the KN6000 floppies come from?

QUESTION IT ANSWERS (register row N-4c66be6c)
  A KN6000 .TM file ends with RAM's sound checksum word (~LE16 sum of the 40 sound records, func_4C07D7C1)
  as it was at save time; 12 of the 50 softlist .TM files match their own records, 38 do not
  (notes/floppy-leftovers-2026-10-31, tm_tail.py).  This prints, per disk in file order, whether each word
  matches, and for a stale one whether it is the true checksum of another file's records.
  Measured 2026-11-02:
    * by disk: ca6000s 4/4, ca6dim 5/5, ca6tm01 1/1, ca6tm02 1/1 match; ca6001 1/6; ca6002..ca6010 0/31.
    * the stale words are few and shared: 0xB0C5 in 24 files on 8 disks, 0xEC4E in 8 (ca6003, ca6005),
      0x769A in 3, 0x1207 in 3 (ca6008).
    * 0x769A is the TRUE checksum of ca6001/03MARSH1.TM, and the three files that keep it are the three after
      it on that disk (04MARCH2, 05WALZER, 06(DEMO)).
  Reading: the word is the last checksum RAM computed (after a .TM load, PostTmTransLoad -> func_4C07DEC8; at
  power-on, func_4C07DD55), carried into later saves because the sounds were changed afterwards by a path
  that does not recompute it.  [INFERENCE] 0xB0C5 is the power-on default set's checksum (untestable here: the
  defaults are the table flash's 'JK' archive +0x3C records, func_4C07C87F, and no KN6000 table image is in
  hand; the KN7000's 40 default records give 0xFDC2).

RUN (repository root; the floppy references built, make -C floppy refs-kn6000)
  python3 notes/misc2-2026-11-02/probes/tm_stale_carryover.py
"""
import collections
import glob
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
KB = 0x10 + 40 * 0x2C8          # the 40 sound records end here; the checksum covers +0x10..KB


def checksum(p):
    return ~sum(p[i] | p[i + 1] << 8 for i in range(0x10, KB, 2)) & 0xFFFF


def main():
    files = sorted(glob.glob(os.path.join(ROOT, "floppy", "build", "kn6000", "*", "*.tm.p1.ref")))
    rec = []
    for f in files:
        p = open(f, "rb").read()
        if p[:16] != b"KN6000 SOUND RAM":
            continue
        rec.append((f.split(os.sep)[-2], os.path.basename(f).split(".")[0], p[-2] | p[-1] << 8, checksum(p)))
    owner = {s: "%s/%s" % (d, n) for d, n, _, s in rec}
    per = collections.defaultdict(list)
    for d, n, w, s in rec:
        per[d].append((n, w, s))
    for d in sorted(per):
        ok = sum(w == s for _, w, s in per[d])
        print("%-8s %d / %d match" % (d, ok, len(per[d])))
        for n, w, s in per[d]:
            if w != s:
                print("    %-12s word 0x%04X, own 0x%04X%s" % (n, w, s,
                      ("  = the checksum of " + owner[w]) if w in owner else ""))
    words = collections.Counter(w for _, _, w, s in rec if w != s)
    print("stale words: " + ", ".join("0x%04X x%d" % kv for kv in words.most_common()))


if __name__ == "__main__":
    main()
