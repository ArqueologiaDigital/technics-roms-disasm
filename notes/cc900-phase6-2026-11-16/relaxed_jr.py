#!/usr/bin/env python3
"""relaxed_jr.py OBJ NM_OUTPUT GENERATED_DIR

Which compiled (cc900) functions does llvm-mc relax -- a `jr` in the generated source that comes out as `jrl`?

QUESTION ANSWERED / WHY: `llvm-mc -stats` reported 31 relaxed instructions in the r18 v10 build, and the gate stopped
at `.org 0xf97d8d` one byte past it although the same source without that `.org` is byte-identical to the ROM.
In the first layout pass every relaxable `jr` counts 2 bytes, so the `.org` pads for the bytes the relaxations will
add later; a hand-written `jr` that crosses the `.org` (FDC routines, `jr nz` +116 at 0xf97d6b) then sees its
target that much further away, is relaxed to `jrl` for good, and the content overruns the `.org`.  A generated
function that names `jr` where the ROM has `jrl` adds to that pending growth; spelling it `jrl` removes it.
For each function with a file GENERATED_DIR/<name>.s, this compares the number of `jrl` lines in the file with the
number of `jrl` the object holds between its label and the next label of NM_OUTPUT (`llvm-nm` of OBJ).
"""
import os
import re
import subprocess
import sys

OBJDUMP = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-objdump')


def main():
    obj, nm, gdir = sys.argv[1:4]
    syms = []
    for line in open(nm):
        p = line.split()
        if len(p) == 3 and p[1] in 'tT':
            syms.append((int(p[0], 16), p[2]))
    syms.sort()
    gen = {f[:-2] for f in os.listdir(gdir) if f.endswith('.s')}
    total = 0
    for i, (a, n) in enumerate(syms):
        if n not in gen:
            continue
        src = open(os.path.join(gdir, n + '.s'), 'rb').read().decode('latin-1')
        want = len(re.findall(r'^\s*jrl\b', src, re.M))
        end = next((b for b, _ in syms[i + 1:] if b > a), a + 1)
        # the function's compiled body: up to the first label that is not one of its own .set labels is enough
        out = subprocess.run([OBJDUMP, '-d', '--start-address=%#x' % a, '--stop-address=%#x' % end, obj],
                             capture_output=True, text=True).stdout
        got = len(re.findall(r'\tjrl\t', out))
        if got > want:
            print('%06x %s: %d jrl in the object, %d in the generated source' % (a + 0xe00000, n, got, want))
            total += got - want
    print('relaxed in generated functions:', total)


if __name__ == '__main__':
    main()
