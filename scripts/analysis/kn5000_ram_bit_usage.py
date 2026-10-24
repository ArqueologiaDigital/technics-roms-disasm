#!/usr/bin/env python3
"""kn5000_ram_bit_usage.py -- who sets, clears, toggles and tests each bit of a KN5000 RAM flag byte?

QUESTION THIS ANSWERS
  A flag byte can only be named once its bits are understood.  For each address given this lists, per bit,
  the routines (nearest label that is not a _Skip / _Loop ... join label) that set it (`set n` or `or (A), m`),
  clear it (`res n` or `and (A), m`), toggle it (`chg`, `xor (A), m`) or test it (`bit n`), plus the other
  instruction shapes that touch the byte as a whole.  Numeric operands and names both count when --name is
  given.

USAGE
  python3 scripts/analysis/kn5000_ram_bit_usage.py [--tree v10] [--name NAME] 0x287b [0x32f4 ...]
"""
import argparse
import collections
import glob
import re

JOIN = re.compile(r'_(Skip|Join|Loop|Return|Exit|Done|Next|Ret|Cont|Continue|End)\d*$')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", default="v10")
    ap.add_argument("--name")
    ap.add_argument("addrs", nargs="+")
    a = ap.parse_args()
    lines = []
    for f in sorted(glob.glob(a.tree + "/maincpu/**/*.s", recursive=True)):
        cur = "?"
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            m = re.match(r'^([A-Za-z_]\w*):', l)
            if m and not JOIN.search(m.group(1)):
                cur = m.group(1)
            lines.append((cur, re.sub(r'\s+', ' ', l.split(";")[0]).strip()))
    for x in a.addrs:
        A = int(x, 16)
        alt = "|" + re.escape(a.name) if a.name else ""
        sp = r'\((?:0x0*%x|%d%s)(?::8|:16|:24)?\)' % (A, A, alt)
        d = collections.defaultdict(lambda: collections.defaultdict(set))
        other = collections.Counter()
        for cur, c in lines:
            if not re.search(sp, c, re.I):
                continue
            m = re.match(r'^(set|res|bit|chg|tset) (\d+), ' + sp + '$', c, re.I)
            if m:
                d[int(m.group(2))][m.group(1).lower()].add(cur)
                continue
            m = re.match(r'^(or|and|xor) ' + sp + r', (0x[0-9a-f]+|\d+)$', c, re.I)
            if m:
                v, op = int(m.group(2), 0), m.group(1).lower()
                for b in range(8):
                    if op == "or" and v >> b & 1:
                        d[b]["set"].add(cur)
                    if op == "and" and not v >> b & 1:
                        d[b]["res"].add(cur)
                    if op == "xor" and v >> b & 1:
                        d[b]["chg"].add(cur)
                continue
            other[re.sub(r'(0x[0-9a-fA-F]+|\b\d+\b)', 'N', c)] += 1
        print("=== %s" % x)
        for b in sorted(d):
            for k in ("set", "res", "chg", "tset", "bit"):
                if d[b][k]:
                    print("  b%d %-4s %3d: %s" % (b, k, len(d[b][k]), " ".join(sorted(d[b][k])[:8])))
        print("  other:", other.most_common(6))


if __name__ == "__main__":
    main()
