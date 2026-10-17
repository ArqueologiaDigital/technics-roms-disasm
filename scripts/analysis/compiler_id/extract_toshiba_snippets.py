#!/usr/bin/env python3
"""extract_toshiba_snippets.py -- pull the TLCS-900 instruction sequences srccmp.py compares out of Toshiba's sources.

QUESTION IT ANSWERS
  srccmp.py compares a Toshiba runtime source with the ROM.  The .ASM / .MAC library files can be fed to it
  directly; three sequences live inside C files as __asm("...") / __ASM("...") strings and are pulled out here:
    stc94ml_farea.asm  -- `_startup`'s f_area initialisation (CUSTOMIZ/C900_H2/STC94ML.C, `ld xde,startof(f_area)`
                          .. `FA1:`)
    stc94ml_fdata.asm  -- `_startup`'s f_data copy (`ld xde,__DataRAM` .. `FD1:`)
    memcpy900.asm      -- the TLCS-900 inline-assembly `memcpy` of LIB/SRC/_MEMCPY.C
  Toshiba's code is not committed to this repository; regenerate the snippets from the package instead.

RUN
  python3 -I scripts/analysis/compiler_id/extract_toshiba_snippets.py T900_DIR OUTDIR
  (T900_DIR = the T900/ directory of an extracted T900.zip; see README.md for its URL and sha256)
"""
import os
import re
import sys


def asm_lines(path, start, end):
    """The __asm/__ASM strings from the one starting with `start` to `end` (None: to the last one of the file)."""
    out, on = [], False
    for line in open(path, encoding="latin-1"):
        m = re.search(r'__(?:asm|ASM)\("([^"]*)"\)', line)
        if not m:
            continue
        s = m.group(1).strip()
        if s.startswith(start):
            on = True
        if on and end is not None and s == end:
            return out + ([s] if not s.startswith(";") else [])
        if on and not s.startswith(";"):
            out.append(s.split(";", 1)[0].rstrip())
    raise SystemExit("%s: no %r .. %r block" % (path, start, end))


def main():
    t900, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    stc = os.path.join(t900, "CUSTOMIZ", "C900_H2", "STC94ML.C")
    jobs = {
        "stc94ml_farea.asm": asm_lines(stc, "ld\txde,startof(f_area)", "FA1:"),
        "stc94ml_fdata.asm": asm_lines(stc, "ld\txde,__DataRAM", "FD1:"),
        "memcpy900.asm": asm_lines(os.path.join(t900, "LIB", "SRC", "_MEMCPY.C"), "ld\t\tBC,(XSP+12)", ";; ret"),
    }
    for name, lines in jobs.items():
        with open(os.path.join(outdir, name), "w") as f:
            f.write("\n".join(lines) + "\n")
        print("%-20s %d lines" % (name, len(lines)))


if __name__ == "__main__":
    main()
