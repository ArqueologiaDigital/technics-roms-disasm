#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "how many routines did lane open14/kn7000-subsystems name in program 941, per address
# range (subsection of its kn7000_manual.sym section) and per evidence class?"
#
# Reads the section that starts "; ---- lane open14/kn7000-subsystems" in kn7000/kn7000_manual.sym
# (it ends at the next "; ====" / "; ----" header); every row's comment starts "[CLASS+CLASS]".
# A row with two classes counts once in each.  Prints an aligned Markdown table.
#
#     python3 -I kn7000/notes/kn7000-subsystems-probes/name_tally.py
#
# (run from the repository root).
import collections
import re

CLS = ["STR", "TABLE", "WRAP", "CALLEE", "CALLER", "RAM", "IO", "BODY"]


def main():
    sec, rows, on = None, collections.OrderedDict(), False
    for line in open("kn7000/kn7000_manual.sym", encoding="utf-8"):
        if line.startswith("; ---- lane open14/kn7000-subsystems"):
            on = True
            continue
        if on and (line.startswith("; ====") or line.startswith("; ---- ")):
            break
        if not on:
            continue
        m = re.match(r"; -- (.*?) \(\d+ names\)", line)
        if m:
            sec = m.group(1).split(":")[0].split(" (")[0]
            rows[sec] = collections.Counter()
            continue
        m = re.match(r"0x[0-9A-F]{8}\s+\w+\s+; \[([A-Z+]+)\]", line)
        if m and sec:
            rows[sec]["names"] += 1
            for c in m.group(1).split("+"):
                rows[sec][c] += 1
    hdr = ["range", "names"] + CLS
    tab = [[k, str(v["names"])] + [str(v[c]) for c in CLS] for k, v in rows.items()]
    tot = collections.Counter()
    for v in rows.values():
        tot.update(v)
    tab.append(["total", str(tot["names"])] + [str(tot[c]) for c in CLS])
    w = [max(len(r[i]) for r in [hdr] + tab) for i in range(len(hdr))]
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(hdr)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in tab:
        print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(r)) + " |")


if __name__ == "__main__":
    main()
