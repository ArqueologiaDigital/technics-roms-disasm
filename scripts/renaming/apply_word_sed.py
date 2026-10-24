#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""Apply a rename .sed script made only of `s/\\bOLD\\b/NEW/g` lines, byte-safely.

Question it answers: "what does `sed -i -f SCRIPT FILE...` do to these files?" -- the
same edit, for environments where sed -f cannot be run, and for files that hold bytes
that are not UTF-8 (the .s files of this tree): every file is read and written as
bytes. Any other kind of line in the script is an error.  Prints the replacement
count per file.

    python3 scripts/renaming/apply_word_sed.py scripts/renaming/rename_X.sed FILE...
"""
import re
import sys

rules = []
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    m = re.fullmatch(r"s/\\b(\w+)\\b/(\w+)/g", line)
    if not m:
        sys.exit(f"apply_word_sed: not a whole-word rename: {line}")
    rules.append((re.compile(rb"\b" + m.group(1).encode() + rb"\b"), m.group(2).encode()))
for path in sys.argv[2:]:
    data = open(path, "rb").read()
    n = 0
    for rx, new in rules:
        data, k = rx.subn(new, data)
        n += k
    if n:
        open(path, "wb").write(data)
    print(f"{n:6d}  {path}")
