#!/usr/bin/env python3
"""v7_converter_rerun_check.py -- does v7_byte_region_to_insns.py now write a region exactly as the tree has it?

QUESTION IT ANSWERS
  scripts/converters/v7_byte_region_to_insns.py used to print llvm-objdump's spelling, which step 8 of
  analysis/v7-harmonize-2026-10-24 then respelled by hand-run post-process.  Since 2026-10-31 the converter
  calls the same respelling itself.  For each LABEL given, this probe takes the current tree's block (LABEL up
  to the next column-0 label), puts the dump's bytes of that block back as `.byte` rows in the file, runs the
  converter on it (dry run: it prints the lines it would write), restores the file byte for byte, and compares
  the printed lines with the block's instruction lines in the tree (comments dropped on both sides).
  "IDENTICAL" for a label means a re-run of the converter reproduces the committed spelling.

RUN (repository root, after `make all`: the converter reads rebuilt_ROMs/kn5000_v7_program.llvm.elf)
  python3 notes/misc-2026-10-31/probes/v7_converter_rerun_check.py v7/maincpu/FILE.s LABEL [LABEL ...]
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "converters"))
import v7_byte_region_to_insns as C  # noqa: E402

LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):')


def code_of(l):
    c = l.split(";")[0].rstrip()
    return c if c.strip() and not LABEL.match(c) else None


def main():
    rel, labels = sys.argv[1], sys.argv[2:]
    path = os.path.join(ROOT, rel)
    tree = C.tree_of(path)
    by, _ = C.syms(tree)
    rom = open(os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % tree), "rb").read()
    orig = open(path, "rb").read()
    bad = 0
    for lab in labels:
        L = orig.decode("latin-1").split("\n")
        i = next(k for k, l in enumerate(L) if LABEL.match(l) and LABEL.match(l).group(1) == lab)
        j = next(k for k in range(i + 1, len(L)) if LABEL.match(L[k]))
        nxt = LABEL.match(L[j]).group(1)
        lo, hi = by[lab], by[nxt]
        want = [code_of(l) for l in L[i + 1:j]]
        want = [w for w in want if w]
        data = rom[lo - 0xE00000:hi - 0xE00000]
        rows = ["\t.byte\t" + ", ".join("0x%02x" % b for b in data[k:k + 16]) for k in range(0, len(data), 16)]
        M = L[:i + 1] + rows + L[j:]
        try:
            open(path, "wb").write("\n".join(M).encode("latin-1"))
            r = subprocess.run([sys.executable, os.path.join(ROOT, "scripts/converters/v7_byte_region_to_insns.py"),
                                rel, lab, "--auto-indexed"], cwd=ROOT, capture_output=True, text=True)
        finally:
            open(path, "wb").write(orig)
        got = [l.rstrip() for l in r.stdout.split("\n") if l.strip()]
        if r.returncode:
            print("%s: converter refused: %s" % (lab, r.stderr.strip()[-300:]))
            bad += 1
            continue
        same = got == want
        bad += not same
        print("%s: %d bytes, %d instructions: %s" % (lab, len(data), len(want), "IDENTICAL" if same else "DIFFERS"))
        if not same:
            for a, b in zip(want, got):
                if a != b:
                    print("  tree:      %r\n  converter: %r" % (a, b))
            if len(want) != len(got):
                print("  %d lines in the tree, %d from the converter" % (len(want), len(got)))
    assert open(path, "rb").read() == orig
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
