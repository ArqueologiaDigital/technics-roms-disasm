#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Prints the conversion-figures table the MN10300 sibling READMEs quote
# (kn2400, kn6000, kn6500, hdsx3: "The source"), as an aligned Markdown table,
# from the notes/conversion-stats.txt that gen_image_s.py --stats writes. The
# README tables are pasted from this output, never typed by hand.
#
# Usage: stats_table_md.py <tree>/notes/conversion-stats.txt
import re
import sys


def n(v):
    return f"{int(v):,}"


def main():
    st = {}
    for line in open(sys.argv[1]):
        m = re.match(r"(.*?)\s{2,}(\S.*)$", line.rstrip()) or re.match(r"(\D+?) (\d.*)$", line.rstrip())
        if m:
            st[m.group(1).strip()] = m.group(2)
    e = re.match(r"(\d+) \((\d+) named, (\d+) derived <name>_entry, (\d+) func_\)", st["entries"])
    b = re.match(r"(\d+) \(.*?, ([\d.]+)% of code ranges\)", st["bytes emitted as code"])
    i = re.match(r"(\d+) \(\+(\d+) \.byte escapes\)", st["instructions"])
    left = re.match(r"(\d+) \(in (\d+) \.incbin_range pieces\)", st["code-range bytes left binary"])
    rows = [("measure", "value"),
            ("entries", f"{n(e[1])} ({n(e[2])} named, {n(e[3])} derived `<name>_entry`, "
                        f"{n(e[4])} `func_`)"),
            ("bytes emitted as code", f"{n(b[1])}: {b[2]}% of the code-range bytes"),
            ("instructions", f"{n(i[1])}, plus {n(i[2])} `.byte` escapes"),
            ("local branch labels", n(st["local labels"])),
            ("code-range bytes left binary", f"{n(left[1])}, in {n(left[2])} `.incbin_range` pieces")]
    w = [max(len(r[k]) for r in rows) for k in (0, 1)]
    out = [f"| {rows[0][0]:<{w[0]}} | {rows[0][1]:<{w[1]}} |", f"|{'-' * (w[0] + 2)}|{'-' * (w[1] + 2)}|"]
    out += [f"| {a:<{w[0]}} | {v:<{w[1]}} |" for a, v in rows[1:]]
    print("\n".join(out))


if __name__ == "__main__":
    main()
