#!/usr/bin/env python3
"""ram_block_delta_review.py -- which RAM names did name_kn5000_ram.py's block-delta fallback alone place, and
did any of them reach the source?

QUESTION IT ANSWERS
  scripts/tools/name_kn5000_ram.py places a v9 / v7 RAM name by unanimous votes from matching v10 code.  Its
  older fallback (now behind --infer-block-delta) also placed names with NO vote, from the common delta of
  their voted neighbours.  For every name only that fallback would place, this probe prints:
    guess   the address the fallback gives it in the tree
    v10     its v10 address
    equ     the tree's own `.equ` value for it (constants files the script reads), and whether that line
            carries the script's "derived from v10's uses" comment
    used    how many code lines of the tree spell the name (outside `.equ` lines)
  A guess that equals the tree's `.equ` while no code line uses the name changed nothing but that line.

RUN (repository root; a dry run of the script per tree, a few minutes)
  python3 notes/misc-2026-10-31/probes/ram_block_delta_review.py
"""
import ast
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
EQU = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+)(.*)$')


def equs(tree):
    out = {}
    for f in glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True):
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            m = EQU.match(l)
            if m:
                out[m.group(1)] = (int(m.group(2), 16), "derived from v10's uses" in m.group(3),
                                   os.path.relpath(f, ROOT))
    return out


def uses(tree, names):
    rx = re.compile(r'\b(' + "|".join(map(re.escape, names)) + r')\b')
    c = {n: 0 for n in names}
    for f in glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True):
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            if l.lstrip().startswith(".equ"):
                continue
            for n in rx.findall(l.split(";")[0]):
                c[n] += 1
    return c


def main():
    v10 = equs("v10")
    for tree in ("v9", "v7"):
        r = subprocess.run([sys.executable, os.path.join(ROOT, "scripts/tools/name_kn5000_ram.py"), "--tree", tree],
                           cwd=ROOT, capture_output=True, text=True)
        m = re.search(r'block-delta guesses \([^)]*\): (\{.*\})', r.stdout)
        if not m:
            sys.exit("%s: no block-delta line in the script's output:\n%s%s" % (tree, r.stdout[-2000:], r.stderr[-2000:]))
        guesses = {k: int(v, 16) for k, v in ast.literal_eval(m.group(1)).items()}
        own = equs(tree)
        used = uses(tree, list(guesses)) if guesses else {}
        changed = 0
        print("%s: %d names only the block-delta fallback places" % (tree, len(guesses)))
        print("  %-26s %-8s %-8s %-8s %-8s %s" % ("name", "guess", "v10", "equ", "derived", "code uses"))
        for n in sorted(guesses):
            e = own.get(n)
            print("  %-26s 0x%04x   0x%04x   %-8s %-8s %d" % (
                n, guesses[n], v10[n][0] if n in v10 else -1, "0x%04x" % e[0] if e else "-",
                ("yes" if e[1] else "no") if e else "-", used[n]))
            changed += bool(used[n]) or bool(e and e[0] != v10.get(n, (None,))[0])
        print("  names whose tree value differs from v10's or that code uses: %d" % changed)


if __name__ == "__main__":
    main()
