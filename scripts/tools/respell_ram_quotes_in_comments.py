#!/usr/bin/env python3
"""respell_ram_quotes_in_comments.py -- comments that quote a named RAM variable as "(0xNNNN)" name it instead.

QUESTION IT ANSWERS / JOB IT DOES (open item N-b5219071, notes/ram-naming-2026-10-24/README.md follow-up 3)
  Routine headers were written before the RAM lanes named the variables, so they say "(0x0D57)" where the code
  now says (SQSTEP_CLOCK).  For every `;` comment of a tree's .s files this rewrites a parenthesised address
  "(0xNNNN)" (also "(0xNNNN:16)") to "(NAME)" when:
    * NNNN is in RAM (0x0400 .. 0x3ffff), and
    * the tree defines exactly one .equ with that value among the RAM name files (shared/ram_variables*.s,
      shared/ram_panel_records.s, and every other `.equ NAME, value` whose value is in that range), and
    * the name is not an alias set (two names with one value are left alone: the comment may mean either).
  Run on v10 and v9 only (their RAM equates agree, 574 of 574): v7 / v6 / v5 place many variables lower and
  their headers were often copied from v10 (the "[v10]" ones), so a quoted number there may be v10's address.
  A bare number (no parentheses) is left: it may be a count, a value or an address.  Comments only: no byte
  changes (make gate).  --dry-run counts.
RUN
  python3 scripts/tools/respell_ram_quotes_in_comments.py --tree v10 [--dry-run]
"""
import argparse
import collections
import glob
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EQU = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;|$)')
QUOTE = re.compile(r'\((0x[0-9a-fA-F]{3,5})(:16|:24)?\)')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    files = sorted(glob.glob(os.path.join(REPO, a.tree, "maincpu", "**", "*.s"), recursive=True))
    names = collections.defaultdict(set)
    for f in files:
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            m = EQU.match(l)
            if m:
                v = int(m.group(2), 0)
                if 0x400 <= v <= 0x3ffff:
                    names[v].add(m.group(1))
    st = collections.Counter()
    for f in files:
        L = open(f, "rb").read().decode("latin-1").split("\n")
        ch = False
        for i, l in enumerate(L):
            if ";" not in l or EQU.match(l):
                continue
            code, sep, cmt = l.partition(";")

            def sub(m):
                v = int(m.group(1), 16)
                ns = names.get(v)
                if not ns:
                    st["no name"] += 1
                    return m.group(0)
                if len(ns) > 1:
                    st["several names"] += 1
                    return m.group(0)
                st["named"] += 1
                return "(%s)" % next(iter(ns))
            new = QUOTE.sub(sub, cmt)
            if new != cmt:
                L[i] = code + sep + new
                ch = True
        if ch and not a.dry_run:
            open(f, "wb").write("\n".join(L).encode("latin-1"))
    print("%s: %s%s" % (a.tree, dict(st), " (dry run)" if a.dry_run else ""))


if __name__ == "__main__":
    main()
