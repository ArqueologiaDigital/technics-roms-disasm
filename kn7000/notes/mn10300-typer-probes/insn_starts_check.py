#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""insn_starts_check.py -- does gen_data_s.py's instruction-start oracle agree with the assembler?

QUESTION IT ANSWERS
  "For every byte that an MN10300 tree emits as an instruction, does tools/mn10300_insn_len.oracle() --
   the length decoder of the KN7000 MAME core, decoding forward from the code's function headers and
   entry / branch labels, which gen_data_s.py now asks before it types a word as a pointer into code --
   say 'instruction start' exactly where kn7asm assembled one, and 'inside an instruction' everywhere
   else?"  A disagreement would let a pointer field keep a mid-instruction value, or drop a real one.

HOW
  Assembles the tree with kn7asm (the Recorder of ../code-island-probes/code_in_data.py: which output bytes
  each instruction line emits, at which CPU address), builds the oracle from the same inputs gen_data_s.py
  gives it (the profile's reference image, base, converted code and label files), and asks it about every
  CPU address of every emitted instruction byte.  Prints per tree: instruction bytes checked, agreed, the
  ones it cannot decide (no anchor within reach: not counted as wrong, gen_data_s then keeps its old test),
  and the first disagreements.

RUN (from the repository root, after `make -C kn7000 verify ...` for the KN7000 builds' labels)
  python3 kn7000/notes/mn10300-typer-probes/insn_starts_check.py [tree ...]
Takes about a minute per KN7000 build (a full assembly).
"""
import os, re, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "notes", "code-island-probes"))
import code_in_data as CID  # noqa: E402
import mn10300_insn_len as IL  # noqa: E402

PROFILE = {"kn7000-941": "941", "kn7000-sp7001": "sp7001", "kn7000-b935": "b935", "kn7000-b893": "b893",
           "kn6000": "kn6000", "kn6500": "kn6500", "kn2400": "kn2400", "hdsx3": "hdsx3"}


def inputs(profile):
    import gen_data_s as G
    G.configure(profile)
    P = G.P
    labs = P["labels"] if isinstance(P["labels"], list) else [P["labels"]]
    pairs = []
    for lf in labs:
        for line in open(os.path.join(G.KN7, lf)):
            mo = re.match(r"\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+)", line)
            if mo:
                pairs.append((mo.group(1), int(mo.group(2), 16)))
            elif not lf.endswith(".inc") and line.strip():
                n, v = line.split()
                pairs.append((n, int(v, 16)))
    import glob
    rom = open(os.path.join(G.KN7, P["rom"]), "rb").read()
    return rom, G.BASE, sorted(glob.glob(G.code_glob())), pairs


def main():
    trees = sys.argv[1:] or list(PROFILE)
    for name in trees:
        t0 = time.time()
        rom, base, files, pairs = inputs(PROFILE[name])
        orc = IL.oracle(rom, base, files, pairs)
        tdir, src, seed = CID.TREES[name]
        bdir = os.path.join(ROOT, tdir)
        asm = CID.Recorder(bdir)
        if seed and os.path.exists(os.path.join(bdir, seed)):
            asm.seed(os.path.join(bdir, seed))
        cwd = os.getcwd()
        os.chdir(bdir)
        try:
            asm.assemble(src)
        finally:
            os.chdir(cwd)
        n = agree = undecided = 0
        bad = []
        for off, end, cpu, mn, _ops, path, line in asm.insns:
            for k in range(end - off):
                v = cpu + k
                r = orc.is_start(v)
                n += 1
                if r is None:
                    undecided += 1
                elif r == (k == 0):
                    agree += 1
                elif len(bad) < 10:
                    bad.append(f"    {v:#010x} oracle {'start' if r else 'inside'}, kn7asm {'start' if k == 0 else 'inside'} "
                               f"({mn} at {cpu:#010x}, {os.path.relpath(path, ROOT) if os.path.isabs(path) else path}:{line})")
                else:
                    bad.append(None)
        nbad = len(bad)
        print(f"== {name}: {n} instruction bytes ({len(asm.insns)} instructions), {agree} agree, {nbad} disagree, "
              f"{undecided} undecided (no anchor within {orc.span:#x})  [{time.time() - t0:.0f} s]")
        for b in bad:
            if b:
                print(b)
    return 0


if __name__ == "__main__":
    sys.exit(main())
