#!/usr/bin/env python3
"""hdae5000_ram_users.py -- who uses a given HD-AE5000 RAM address (still spelled as a number)?

QUESTION IT ANSWERS
  Before an SRAM address gets a name in scripts/converters/hdae5000_symbolize_ram.py, its role has to be read
  from the code that uses it.  This lists, for an address or an address range, every instruction operand in
  hdae5000/*.s whose value falls there (hex or 6+-digit decimal; directives and comments excluded), with the
  nearest label above the line -- or, with --summary, one line per address with the routines using it.  Only
  numbers are found: an address already named is spelled by its name.  For the names, grep the name.

RUN (repository root)
  python3 scripts/analysis/hdae5000_ram_users.py 22a000-22a040 23a06e        # every use, with its label
  python3 scripts/analysis/hdae5000_ram_users.py --summary 230430-230880     # per address: count, routines
"""
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUM = re.compile(r"(?<![\w.$+\-])(0x[0-9a-fA-F]+|\d{6,})(?![\w.$])")
DEF = re.compile(r'^([.A-Za-z_][\w$.]*):')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    want = set()
    for a in args:
        if "-" in a:
            lo, hi = a.split("-")
            want |= set(range(int(lo, 16), int(hi, 16) + 1))
        else:
            want.add(int(a, 16))
    summary = collections.defaultdict(collections.Counter)
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        lines = open(p, "rb").read().decode("latin-1").split("\n")
        label = routine = None
        for i, ln in enumerate(lines):
            m = DEF.match(ln)
            if m:
                label = m.group(1)
                if not label.startswith(".L") and not (routine and label.startswith(routine + "_")):
                    routine = label
            code = ln.split(";")[0]
            if m:
                code = code[m.end():]
            if not code.strip() or code.strip().startswith("."):
                continue
            hit = [int(x, 16) if x.lower().startswith("0x") else int(x) for x in NUM.findall(code)]
            hit = [v for v in hit if v in want]
            if not hit:
                continue
            if "--summary" in sys.argv:
                for v in hit:
                    summary[v][(routine or "?").replace("HDAE5000_", "")] += 1
            else:
                print("%-24s %6d  %-50s %s" % (os.path.basename(p), i + 1, (label or "?")[:50], code.strip()[:70]))
    for v in sorted(summary):
        print("0x%06x %4d  %s" % (v, sum(summary[v].values()),
                                  ", ".join("%s x%d" % kv for kv in summary[v].most_common())))


if __name__ == "__main__":
    main()
