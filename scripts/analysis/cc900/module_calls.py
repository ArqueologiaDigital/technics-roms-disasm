#!/usr/bin/env python3
"""Which callees of a firmware C file's functions does the ROM reach relatively -- its `cc900-module:` list?

QUESTION ANSWERED: asm900 assembles V4.23's `cal` / `j` to calr / jr / jrl only for a target in the same section of
the same original module (probe calrel, notes/cc900-phase6-2026-11-16/README.md), so the ROM's own encoding says
which callees shared a function's module.  For every function a C file defines (cc900-name mapped to the tree's
label), this disassembles the built image over the function's bytes and lists each calr / jr / jrl whose target is
another routine (a symbols-reference label outside the function).  It prints the `cc900-module:` comment that makes
the build give those calls their relative form, and, separately, the absolute call / jp targets (the externs).  The
evidence is the image: run it on a tree built from the hand assembly (or with the C already giving the ROM's bytes).

usage: python3 -B scripts/analysis/cc900/module_calls.py TREE FILE.c    (TREE: v10 .. v5, v142 / v141 / v140, hdae5000[_v2_01i ...])
Needs rebuilt_ROMs/kn5000_<TREE>_program.llvm.elf (`make`).  A function's extent runs from its label to the next
routine (a call / calr target anywhere in the image, or another function of the file); only the callees the C
itself calls are listed (a jr into the routine's own inner label is no call).
"""
import bisect
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import cc900_firmware_c as fw                                # noqa: E402

OBJDUMP = os.path.join(fw.LLVM_BIN, 'llvm-objdump')
LINE = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(\w+)\t(.*)$')


def rel_target(addr, nbytes, mnem, ops):
    """the absolute target of a calr / jr / jrl as llvm-objdump prints it (the displacement), else None"""
    d = int(ops.split(',')[-1].strip(), 0)
    if mnem == 'jr':
        d = d - 0x100 if d >= 0x80 else d
    elif mnem in ('jrl', 'calr'):
        d = d - 0x10000 if d >= 0x8000 else d
    else:
        return None
    return addr + nbytes + d


# the image's ELF and the tree directory (for its symbols reference), when not a main-CPU version
IMAGE_ELF = {'v142': 'kn5000_subprogram_v142.llvm.elf', 'v141': 'kn5000_subprogram_v141.llvm.elf',
             'v140': 'kn5000_subprogram_v140.llvm.elf', 'hdae5000': 'hd-ae5000_v2_06i.llvm.elf',
             'hdae5000_v2_01i': 'hd-ae5000_v2_01i.llvm.elf', 'hdae5000_v1_15i': 'hd-ae5000_v1_15i.llvm.elf',
             'hdae5000_v1_10i': 'hd-ae5000_v1_10i.llvm.elf'}
TREE_DIR = {'v142': 'v142/subcpu', 'v141': 'v141/subcpu', 'v140': 'v140/subcpu', 'hdae5000': 'hdae5000',
            'hdae5000_v2_01i': 'hdae5000_v2_01i', 'hdae5000_v1_15i': 'hdae5000_v1_15i',
            'hdae5000_v1_10i': 'hdae5000_v1_10i'}

C_WORDS = {'if', 'while', 'for', 'switch', 'return', 'sizeof', 'do', 'else'}


def c_callees(path, lm):
    """the tree labels FILE.c's function bodies call (identifiers before `(`), cc900-name mapped"""
    src = open(path, 'rb').read().decode('latin-1')
    src = re.sub(r'/\*.*?\*/', ' ', src, flags=re.S)
    out, depth, body = set(), 0, []
    for ch in src:                                   # the text inside function bodies only
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
        elif depth:
            body.append(ch)
    for n in re.findall(r'\b([A-Za-z_]\w*)\s*\(', ''.join(body)):
        if n not in C_WORDS:
            out.add(lm.get(n, n))
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    tree, path = sys.argv[1], sys.argv[2]
    elf = os.path.join(REPO, 'rebuilt_ROMs', IMAGE_ELF.get(tree, 'kn5000_%s_program.llvm.elf' % tree))
    ref = fw.tree_addresses(TREE_DIR.get(tree, '%s/maincpu' % tree))
    by_addr = {}
    for n, a in ref.items():
        by_addr.setdefault(a, n)
    lm = fw.label_map(path)
    callees = c_callees(path, lm)      # only what the C calls counts: a jr to an inner label of the routine is no call
    fns = [lm.get(c, c) for c in fw.c_functions(path)]
    # the whole image, once: every instruction, and the routines (call / calr targets, and the C's functions), whose
    # starts bound a function's extent (the symbols reference also holds inner labels)
    insns = []
    out = subprocess.run([OBJDUMP, '-d', elf], capture_output=True, text=True, check=True).stdout
    for line in out.splitlines():
        m = LINE.match(line)
        if m:
            insns.append((int(m.group(1), 16), len(m.group(2).split()), m.group(3), m.group(4)))
    routines = {ref[f] for f in fns if f in ref}
    for addr, nb, mnem, ops in insns:
        if mnem == 'calr':
            routines.add(rel_target(addr, nb, mnem, ops))
        elif mnem == 'call' and ops.strip().isdigit():
            routines.add(int(ops.strip()))
    starts = sorted(routines)
    local, absolute = set(), set()
    for fn in fns:
        if fn not in ref:
            sys.stderr.write('%s: not in the symbols reference\n' % fn)
            continue
        lo = ref[fn]
        hi = next((x for x in starts if x > lo), lo + 0x10000)
        i = bisect.bisect_left(insns, (lo,))
        while i < len(insns) and insns[i][0] < hi:
            addr, nb, mnem, ops = insns[i]
            i += 1
            if mnem in ('calr', 'jr', 'jrl'):
                t = rel_target(addr, nb, mnem, ops)
                if t is not None and not lo <= t < hi and by_addr.get(t) in callees:
                    local.add(by_addr[t])
            elif mnem in ('call', 'jp') and ops.strip().isdigit():
                t = int(ops.strip())
                if by_addr.get(t) in callees:
                    absolute.add(by_addr[t])
    print('/* cc900-module: %s */' % ' '.join(sorted(local)) if local else '/* (no module-local callee) */')
    if absolute:
        print('/* absolute calls / jumps (externs to V4.23): %s */' % ' '.join(sorted(absolute)))


if __name__ == '__main__':
    main()
