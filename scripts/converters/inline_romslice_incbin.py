#!/usr/bin/env python3
r"""Replace a v7 romslice `.incbin` with the same bytes as `.byte` rows.

QUESTION ANSWERED
    v7 sources hold some routines as `.incbin "includes/romslices/<name>.bin"`,
    which no re-framing tool can see into.  This step spells the slice's bytes
    as `.byte` rows in place (16 per row), so scripts/analysis/
    reframe_v7_runs_crosscheck_v10.py can then turn them into instructions
    where v10 confirms the framing.  It changes no byte of the image (`make
    gate` proves it) and does not delete the .bin (other lanes may own it;
    list the orphans with --orphans).

RUN
    python3 scripts/converters/inline_romslice_incbin.py [--only NAME_PART] v7/maincpu/ui/bitmap_out_routines.s [...]
    python3 scripts/converters/inline_romslice_incbin.py --orphans v7/maincpu/ui/bitmap_out_routines.s
"""
import argparse
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# `[Label:]\t.incbin "includes/romslices/X.bin"[, offset, length]` (the label and the range were added
# 2026-10-24 for v7's last verbatim slices: the label is kept on its own line)
INC = re.compile(r'^(?:([A-Za-z_.$][\w.$]*):)?\s*\.incbin\s+"(includes/romslices/[^"]+)"'
                 r'(?:\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*,\s*(0x[0-9a-fA-F]+|\d+))?\s*$')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--orphans", action="store_true")
    ap.add_argument("--only", action="append", default=[],
                    help="inline only slices whose file name contains this text (repeatable)")
    ap.add_argument("files", nargs="+")
    a = ap.parse_args()
    for rel in a.files:
        path = os.path.join(ROOT, rel)
        base = os.path.dirname(path)
        while not os.path.basename(base) == "maincpu":
            base = os.path.dirname(base)
        lines = open(path, "rb").read().decode("latin-1").split("\n")
        out, n = [], 0
        slices = []
        for ln in lines:
            m = INC.match(ln)
            if m and a.only and not any(o in m.group(2) for o in a.only):
                m = None
            if not m:
                out.append(ln)
                continue
            data = open(os.path.join(base, m.group(2)), "rb").read()
            if m.group(3) is not None:
                off, size = int(m.group(3), 0), int(m.group(4), 0)
                data = data[off:off + size]
            slices.append(m.group(2))
            if m.group(1):
                out.append(m.group(1) + ":")
            for k in range(0, len(data), 16):
                out.append("\t.byte " + ", ".join("0x%02x" % b for b in data[k:k + 16]))
            n += len(data)
        if a.orphans:
            for s in slices:
                users = [f for f in glob.glob(os.path.join(base, "**", "*.s"), recursive=True)
                         if s in open(f, "rb").read().decode("latin-1")]
                print("%s: used by %d file(s)" % (s, len(users)))
            continue
        open(path, "wb").write("\n".join(out).encode("latin-1"))
        print("%s: %d romslice(s), %d bytes inlined: %s" % (rel, len(slices), n, ", ".join(slices)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
