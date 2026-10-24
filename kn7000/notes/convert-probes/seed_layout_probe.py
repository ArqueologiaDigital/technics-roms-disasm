#!/usr/bin/env python3
"""seed_layout_probe.py -- does a kn7asm label seed lead the passes to the right layout?

QUESTION IT ANSWERS
  kn7asm --labels FILE seeds the first pass with a previous build's label
  addresses.  After a relabelling (2026-10-24: the register-save prologue pass of
  gen_program_s) the seed from the build before made the passes settle on a
  layout 3 bytes too long from 0x48507A39 on: a `beq` whose target sits at the
  edge of its 8-bit reach (+0x7F) was encoded in its relaxed `bne +5; jmp` form,
  and with the 3 extra bytes the target stays out of reach, so that layout is
  consistent too.  This assembles SOURCE with SEED the way kn7asm does, prints
  each pass (length, placeholders, forward estimates that missed, first error),
  and compares the output with the reference image: the first differing byte,
  and with GOOD_LABELS (a clean build's --labels output) the first label that
  moved.  Run it on a kn7asm that has the restart (seeded pass not exact ->
  start over without the seed) and the output matches; without the restart
  (kn7asm at 056915a81) the pre-relabelling labels give the bad layout above.

RUN (from kn7000/)
  python3 notes/convert-probes/seed_layout_probe.py SOURCE SEED REF_ROM [GOOD_LABELS]
  e.g. src/program.s build/kn7000_program.labels baserom/kn7000_program.rom
"""
import sys

sys.path.insert(0, "tools")
import kn7asm  # noqa: E402


def main():
    src, seed, ref_path = sys.argv[1:4]
    good_path = sys.argv[4] if len(sys.argv) > 4 else None
    A = kn7asm.Assembler(".")
    A.seed(seed)
    start = A.start_pass
    n = [0]

    def traced():
        if n[0]:
            print(f"pass {n[0]}: length {len(A.out):#x}, placeholders {len(A.guessed)}, "
                  f"forward estimates missed {sum(1 for k, v in A.assumed.items() if A.symbols.get(k) != v)}, "
                  f"first error: {A.problem and A.problem[0]}")
        n[0] += 1
        start()
    A.start_pass = traced
    try:
        A.assemble(src)
        print(f"pass {n[0]}: exact, no error")
    except kn7asm.AsmError as e:
        print(f"pass {n[0]}: exact, ERROR {e}")
    ref = open(ref_path, "rb").read()
    out = bytes(A.out)
    i = next((k for k in range(min(len(out), len(ref))) if out[k] != ref[k]), None)
    if i is None and len(out) == len(ref):
        print("output == reference")
        return
    i = i if i is not None else min(len(out), len(ref))
    print(f"first differing byte at file offset {i:#x}; output length {len(out):#x}, reference {len(ref):#x}")
    if good_path:
        good = {nm: int(v, 16) for nm, v in (ln.split() for ln in open(good_path))}
        moved = sorted((good[nm], nm, a) for nm, a in A.labels.items() if nm in good and good[nm] != a)
        if moved:
            g, nm, a = moved[0]
            print(f"first moved label: {nm} at {a:#x}, a clean build puts it at {g:#x}")


if __name__ == "__main__":
    main()
