#!/usr/bin/env python3
"""padtables.py -- re-align every Markdown table read from stdin and print to stdout (same logic as
repad.py, but without touching any file)."""
import re, sys
lines = sys.stdin.read().split("\n")
out, block = [], []
def flush():
    if not block: return
    rows = [[c.strip() for c in l.strip().strip("|").split(" | ")] for l in block]
    rows = [r for r in rows if not all(re.fullmatch(r"-+", c.replace("|", "-")) for c in r)]
    n = max(len(r) for r in rows)
    rows = [r + [""] * (n - len(r)) for r in rows]
    w = [max(len(r[i]) for r in rows) for i in range(n)]
    f = lambda r: "| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |"
    out.extend([f(rows[0]), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [f(r) for r in rows[1:]])
    block.clear()
for l in lines:
    if l.startswith("|"): block.append(l)
    else: flush(); out.append(l)
flush()
sys.stdout.write("\n".join(out))
