#!/usr/bin/env python3
"""doc_symbol_check.py -- which backticked names in a WSA1 note are not symbols any more?

QUESTION ANSWERED: CLAUDE.md's Symbol Name Synchronization policy says every symbol a
document names must exist in the current source.  For each Markdown file given, this lists
every `backticked` identifier that LOOKS like a symbol (has an underscore or an inner capital,
and is not a path, a mnemonic or a register) and is not defined by any of the four linked
WSA1 images.

"Defined" means present in `llvm-nm` of wsa1/rebuilt_ROMs/wsa1_prom_{a,b,c,d}.llvm.elf --
labels and absolute `.equ`/`.set` constants alike -- so build first (`make -C wsa1 all`).
A name reported here is a CANDIDATE: it may be a C identifier, a MAME function or a file
stem that the heuristic took for a label.  Read each one before changing the note.

RUN (inside wsa1/):
    python3 scripts/analysis/doc_symbol_check.py notes/WSA1-EMULATION-DISASM-GAPS.md
Exit status 1 when any candidate is reported.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.join(os.environ.get("PROJECTS_ROOT", os.path.expanduser("~/compartilhado")),
                  "llvm-project", "build", "bin", "llvm-nm")
ELFS = ["rebuilt_ROMs/wsa1_prom_%s.llvm.elf" % k for k in "abcd"]
TICK = re.compile(r'`([A-Za-z_][A-Za-z0-9_]*)`')
REGISTERS = {"xwa", "xbc", "xde", "xhl", "xix", "xiy", "xiz", "xsp", "wa", "bc", "de", "hl",
             "ix", "iy", "iz", "sp", "sr", "pc"}


def defined_names():
    names = set()
    for e in ELFS:
        path = os.path.join(ROOT, e)
        if not os.path.exists(path):
            sys.exit("missing %s: run `make -C wsa1 all` first" % path)
        out = subprocess.run([NM, "--defined-only", path], check=True,
                             capture_output=True, text=True).stdout
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 3:
                names.add(parts[2])
    return names


def looks_like_symbol(w):
    if w.lower() in REGISTERS:
        return False
    return "_" in w.strip("_") or re.search(r'[a-z][A-Z]', w) is not None


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    names = defined_names()
    bad = 0
    for md in sys.argv[1:]:
        with open(md, encoding="utf-8") as fh:
            lines = fh.read().split("\n")
        seen = set()
        for n, line in enumerate(lines, 1):
            for w in TICK.findall(line):
                if w in seen or w in names or not looks_like_symbol(w):
                    continue
                seen.add(w)
                bad += 1
                print("%s:%d: `%s` is not defined in any WSA1 image" % (md, n, w))
    print("%d candidate(s)" % bad)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
