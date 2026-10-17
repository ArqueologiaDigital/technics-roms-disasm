#!/usr/bin/env python3
"""align_md_tables.py -- re-pad GitHub-flavoured Markdown tables to aligned, space-padded columns.

QUESTION IT ANSWERS / WHAT IT DOES
  The owner reads .md files raw, so every table must use aligned columns (`| cell   |`, separator dashes the full
  padded width), never the compact `|a|b|` form.  This rewrites every table that starts inside a line range of a
  file: each column is padded to its widest cell, left-aligned, one space either side; a separator
  row keeps its `:` alignment markers.  A `|` inside backticks is
  kept as cell text.  Lines outside tables are not touched.

RUN
  python3 scripts/tools/align_md_tables.py FILE                 # all tables of FILE
  python3 scripts/tools/align_md_tables.py FILE --lines 234-385 # only tables that start in that range
  python3 scripts/tools/align_md_tables.py FILE --check         # exit 1 if a table would change
"""
import argparse
import re
import sys


def split_row(line):
    """Cells of a `| a | b |` row; pipes inside `code spans` do not split."""
    s = line.strip()
    assert s.startswith("|") and s.endswith("|"), line
    cells, cur, tick = [], "", False
    for ch in s[1:-1]:
        if ch == "`":
            tick = not tick
        if ch == "|" and not tick:
            cells.append(cur.strip())
            cur = ""
        else:
            cur += ch
    cells.append(cur.strip())
    return cells


def is_sep(cells):
    return all(re.fullmatch(r":?-+:?", c) for c in cells)


def align(rows):
    cells = [split_row(r) for r in rows]
    n = max(len(c) for c in cells)
    cells = [c + [""] * (n - len(c)) for c in cells]
    w = [max(len(c[i]) for c in cells if not is_sep(c)) for i in range(n)]
    out = []
    for c in cells:
        if is_sep(c):
            # keep each column's alignment markers (:--- left, ---: right, :---: centre)
            def dash(i):
                s = c[i]
                lead, tail = s.startswith(":"), s.endswith(":") and len(s) > 1
                return (":" if lead else "-") + "-" * w[i] + (":" if tail else "-")
            out.append("|" + "|".join(dash(i) for i in range(n)) + "|")
        else:
            out.append("| " + " | ".join(c[i].ljust(w[i]) for i in range(n)) + " |")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("file")
    ap.add_argument("--lines", default=None, help="A-B: only tables whose first line is in A..B (1-based)")
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    lo, hi = (map(int, a.lines.split("-")) if a.lines else (1, 10 ** 9))
    text = open(a.file, encoding="utf-8").read()
    L = text.split("\n")
    out, i, changed = [], 0, 0
    while i < len(L):
        if L[i].lstrip().startswith("|") and L[i].rstrip().endswith("|") and lo <= i + 1 <= hi:
            j = i
            while j < len(L) and L[j].lstrip().startswith("|") and L[j].rstrip().endswith("|"):
                j += 1
            new = align(L[i:j])
            changed += sum(1 for x, y in zip(L[i:j], new) if x != y)
            out += new
            i = j
        else:
            out.append(L[i])
            i += 1
    if a.check:
        print("%s: %d table lines would change" % (a.file, changed))
        sys.exit(1 if changed else 0)
    if changed:
        open(a.file, "w", encoding="utf-8").write("\n".join(out))
    print("%s: %d table lines re-padded" % (a.file, changed))


if __name__ == "__main__":
    main()
