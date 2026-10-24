#!/usr/bin/env python3
"""hdae5000_numeric_ram_operands.py -- how many HD-AE5000 operands still spell a RAM address as a number?

QUESTION IT ANSWERS
  hdae5000/*.s addresses its SRAM (0x200000-0x23FFFF) either by a name (HDAE5000_RAM_*, written by
  scripts/converters/hdae5000_symbolize_ram.py) or by a bare number.  This counts the bare numbers: every hex or
  6+-digit decimal operand in an instruction (directives and comments excluded) whose value lies in that range,
  in total, per file, and the most-used addresses with the routines that use them -- the to-do list for naming
  the rest.

RUN (repository root)
  python3 scripts/analysis/hdae5000_numeric_ram_operands.py [N]          # summary + the N most-used (default 40)
  python3 scripts/analysis/hdae5000_numeric_ram_operands.py N --rev REV  # the same for a commit's tree
"""
import collections
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUM = re.compile(r"(?<![\w.$+\-])(0x[0-9a-fA-F]+|\d{6,})(?![\w.$])")
DEF = re.compile(r'^([A-Za-z_][\w$]*):')
LO, HI = 0x200000, 0x240000


def read(p, rev):
    if rev:
        return subprocess.run(["git", "-C", ROOT, "show", "%s:%s" % (rev, os.path.relpath(p, ROOT))],
                              capture_output=True, check=True).stdout
    return open(p, "rb").read()


def main():
    a = sys.argv[1:]
    rev = a[a.index("--rev") + 1] if "--rev" in a else None
    nums = [x for x in a if x.isdigit()]
    lim = int(nums[0]) if nums else 40
    cnt, users, per_file = collections.Counter(), collections.defaultdict(collections.Counter), collections.Counter()
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        cur = None
        for ln in read(p, rev).decode("latin-1").split("\n"):
            m = DEF.match(ln)
            if m and not (cur and m.group(1).startswith(cur + "_")):
                cur = m.group(1)
            code = ln.split(";")[0]
            if m:
                code = code[m.end():]
            s = code.strip()
            if not s or s.startswith("."):
                continue
            for x in NUM.findall(code):
                v = int(x, 16) if x.lower().startswith("0x") else int(x)
                if LO <= v < HI:
                    cnt[v] += 1
                    users[v][cur] += 1
                    per_file[os.path.basename(p)] += 1
    print("numeric RAM operands: %d (%d distinct addresses)" % (sum(cnt.values()), len(cnt)))
    for f, n in sorted(per_file.items()):
        print("  %-28s %5d" % (f, n))
    for v, c in cnt.most_common(lim):
        print("  0x%06x %4d  %s" % (v, c, ", ".join("%s x%d" % kv for kv in users[v].most_common(4))))


if __name__ == "__main__":
    main()
