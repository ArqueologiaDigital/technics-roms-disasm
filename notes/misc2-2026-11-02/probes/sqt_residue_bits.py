#!/usr/bin/env python3
"""sqt_residue_bits.py -- are the KN6000 / KN7000 .SQT bytes no event order explains song data, or RAM nothing wrote?

QUESTION IT ANSWERS (register rows N-e140c8dc, O-kn6000- / O-kn7000-floppy-unknown-dump-397763)
  floppy/tools/kd/kn_sqt.py declares opaque the stale cell bytes that neither the tick-first nor the KN5000
  event order parses (126 declarations, 1,768 B on the KN6000 disks; 96, 5,270 B on the KN7000's).  Song
  events have no reason to depend on the byte's address; RAM that nothing wrote keeps a power-on pattern that
  does (as the WSA1R's block store does, wsa1_f7df_runs.py).  This reads every declaration's bytes from the
  built references and prints, per model: count, bytes, the most common values, the mean number of set bits
  by file offset mod 8 over the declarations of >= 32 bytes, the same over every other byte of the same files
  (the control), and the most common short (< 16 B) declarations.
  Measured 2026-11-02:
    KN7000, the 36 declarations of >= 32 B (4,997 of the 5,270 B; 65 of all 96 declarations are in
      organs/01ORGANS.SQT): mean set bits by offset mod 8 = 3.23 3.27 3.57 3.62 4.74 4.76 4.46 4.58, against
      2.52 2.50 2.41 2.53 2.43 2.47 2.48 2.47 for every other byte of the same files (the control).  That is an
      address-tied bias with period 8, at almost twice the song data's density.  [INFERENCE] power-on RAM
      contents of the song cells, not events.
    KN7000, the other 60 (273 B), and the KN6000's 119 of < 32 B (498 B): event fragments (0x90 note statuses,
      0x81 beats), mostly followed by 0x81 / 0x80 / 0xFF: events cut where neither order resynchronises.
    KN6000, the 7 of >= 32 B (1,270 B): no phase bias (5.47..5.74 set bits by phase) but mostly 0xFF (823 of
      the model's 1,768 opaque bytes are 0xFF) with 0x80 / 0x40 / 0x90 runs: not explained here.

RUN (repository root; floppy references built: make -C floppy refs-kn6000 refs-kn7000)
  python3 notes/misc2-2026-11-02/probes/sqt_residue_bits.py
"""
import collections
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
INC = re.compile(r'\.incbin\s+"([^"]+)",\s*(0x[0-9a-fA-F]+|\d+),\s*(\d+)')


def declarations(model):
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, "floppy", model, "*", "payload", "*.SQT.p*.s"))):
        disk = f.split(os.sep)[-3]
        L = open(f, "rb").read().decode("latin-1").split("\n")
        for i, line in enumerate(L):
            if "census: opaque" in line:
                m = INC.search(L[i + 1])
                ref = os.path.join(ROOT, "floppy", "build", model, disk, m.group(1))
                d = open(ref, "rb").read()
                o, n = int(m.group(2), 0), int(m.group(3))
                out.append((disk, os.path.basename(f), o, n, d))
    return out


def bits(x):
    return bin(x).count("1")


def main():
    for model in ("kn6000", "kn7000"):
        R = declarations(model)
        allb = b"".join(d[o:o + n] for _, _, o, n, d in R)
        print("%s: %d declarations, %d B; most common values %s" % (
            model, len(R), len(allb), ", ".join("0x%02X x%d" % kv for kv in collections.Counter(allb).most_common(6))))
        acc = collections.defaultdict(list)
        for _, _, o, n, d in R:
            if n >= 32:
                for j in range(n):
                    acc[(o + j) % 8].append(bits(d[o + j]))
        print("  set bits by offset mod 8, declarations >= 32 B: " +
              " ".join("%.2f" % (sum(acc[q]) / len(acc[q])) for q in range(8)))
        files = {}
        for disk, fn, o, n, d in R:
            files.setdefault((disk, fn), (d, []))[1].append((o, n))
        ctl = collections.defaultdict(list)
        for d, spans in files.values():
            mask = bytearray(len(d))
            for o, n in spans:
                mask[o:o + n] = b"\1" * n
            for j, x in enumerate(d):
                if not mask[j]:
                    ctl[j % 8].append(bits(x))
        print("  set bits by offset mod 8, the rest of those files (control): " +
              " ".join("%.2f" % (sum(ctl[q]) / len(ctl[q])) for q in range(8)))
        print("  declarations per file (top): " + ", ".join(
            "%s/%s x%d" % (k[0], k[1].split(".")[0], v) for k, v in
            collections.Counter((disk, fn) for disk, fn, _, _, _ in R).most_common(3)))
        small = collections.Counter(d[o:o + n] for _, _, o, n, d in R if n < 16)
        print("  %d declarations < 16 B; most common: %s" % (sum(small.values()), ", ".join(
            "%s x%d" % (b.hex(), v) for b, v in small.most_common(5))))


if __name__ == "__main__":
    main()
