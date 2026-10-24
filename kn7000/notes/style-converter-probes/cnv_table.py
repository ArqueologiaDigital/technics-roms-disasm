#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# The per-converter table of notes/style-converter.md ("The disassembly"), read
# from the headers tools/gen_cnv_s.py writes into src/cnv/*.s, plus the
# directives each source is made of (a count of .incbin must be 0).
#   python3 -I cnv_table.py ../../src/cnv/*.s
import re
import sys

rows = []
for p in sys.argv[1:]:
    t = open(p, encoding="latin1").read()
    g = lambda rx: re.search(rx, t).group(1)                           # noqa: E731
    lines = t.split("\n")
    code = lines.index(next(x for x in lines if x.startswith("# ") and " code " in x and "====" in x))
    ro = lines.index(next(x for x in lines if ".rodata" in x and "====" in x))
    in_code = lines[code:ro]
    rows.append([
        g(r"# (\S+)\.CNV -- "),
        g(r"#   (\d+) bytes"),
        g(r"#   code .*?(\d+) instructions"),
        g(r"in (\d+) routines"),
        g(r"(\d+) with no caller"),
        g(r"(\d+) copies of named"),
        g(r"(\d+) the same in all"),
        g(r"(\d+) strings and text"),
        str(sum(x.lstrip().startswith(".incbin") for x in lines)),
        str(sum(x.startswith("    .byte") for x in in_code)),
        g(r"SHA-1 ([0-9a-f]{8})"),
    ])
head = ["converter", "bytes", "instructions", "routines", "no caller", "firmware copies",
        "in all seven", "strings", ".incbin", ".byte in code", "SHA-1"]
w = [max(len(r[i]) for r in rows + [head]) for i in range(len(head))]
print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
print("|" + "|".join("-" * (x + 2) for x in w) + "|")
for r in rows:
    print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |")
