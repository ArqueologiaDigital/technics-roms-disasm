#!/usr/bin/env python3
"""fn_calls.py -- per FUNCTION, which callees does the ROM reach relatively (calr / jr / jrl) and which absolutely?

QUESTION ANSWERED / WHY: scripts/analysis/cc900/module_calls.py answers this for a whole C file, as the one
`cc900-module:` line the file needs.  A staging file that holds functions of DIFFERENT original modules can need a
callee relative for one function and absolute for another (2026-11-20: SePitPit1_OnSideRow4 / 5 call
SeMenu_LoadPartParam with `call`, while the SeMenu_ApplyPartEdit_AltStore_Join* functions of the same
semenu_routines_m0.c reach it with `calr`; with the file's module line V4.23 wrote the relative call, DIFF at +5).
restage_modules.py uses calls() to keep such functions in separate files.  Same reading as module_calls.py: the
built image's ELF, a function's extent from its label to the next routine start, only callees its C text names.

usage (from the repository root, after `make`):
    python3 -B notes/cc900-phase6-2026-11-16/fn_calls.py TREE FILE.c      one line per function: local / absolute
"""
import bisect
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900'))
import module_calls as mc                                    # noqa: E402

fw = mc.fw


def calls(tree, wanted):
    """wanted: {label: set of callee labels its C names}.  Returns {label: (local set, absolute set)}; a label
    missing from the tree's symbols reference is left out."""
    elf = os.path.join(REPO, 'rebuilt_ROMs', mc.IMAGE_ELF.get(tree, 'kn5000_%s_program.llvm.elf' % tree))
    ref = fw.tree_addresses(mc.TREE_DIR.get(tree, '%s/maincpu' % tree))
    by_addr = {}
    for n, a in ref.items():
        by_addr.setdefault(a, n)
    insns = []
    out = subprocess.run([mc.OBJDUMP, '-d', elf], capture_output=True, text=True, check=True).stdout
    for line in out.splitlines():
        m = mc.LINE.match(line)
        if m:
            insns.append((int(m.group(1), 16), len(m.group(2).split()), m.group(3), m.group(4)))
    routines = {ref[f] for f in wanted if f in ref}
    for addr, nb, mnem, ops in insns:
        if mnem == 'calr':
            routines.add(mc.rel_target(addr, nb, mnem, ops))
        elif mnem == 'call' and ops.strip().isdigit():
            routines.add(int(ops.strip()))
    starts = sorted(routines)
    res = {}
    for fn, callees in wanted.items():
        if fn not in ref:
            continue
        lo = ref[fn]
        hi = next((x for x in starts if x > lo), lo + 0x10000)
        local, absolute = set(), set()
        i = bisect.bisect_left(insns, (lo,))
        while i < len(insns) and insns[i][0] < hi:
            addr, nb, mnem, ops = insns[i]
            i += 1
            if mnem in ('calr', 'jr', 'jrl'):
                t = mc.rel_target(addr, nb, mnem, ops)
                if t is not None and not lo <= t < hi and by_addr.get(t) in callees:
                    local.add(by_addr[t])
            elif mnem in ('call', 'jp') and ops.strip().isdigit():
                t = int(ops.strip())
                if by_addr.get(t) in callees:
                    absolute.add(by_addr[t])
        res[fn] = (local, absolute)
    return res


def fn_callees(text, lm):
    """the tree labels one function's C text calls (cc900-name mapped)"""
    import re
    body = text[text.index('{'):]
    body = re.sub(r'/\*.*?\*/', ' ', body, flags=re.S)
    return {lm.get(n, n) for n in re.findall(r'\b([A-Za-z_]\w*)\s*\(', body) if n not in mc.C_WORDS}


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    tree, path = sys.argv[1], sys.argv[2]
    sys.path.insert(0, HERE)
    import stage_probe as sp
    text = open(path, encoding='latin-1').read()
    lm = fw.label_map(path)
    wanted = {}
    for k, d in sp.items(text):
        if k == 'fn':
            cn = sp.fn_name(d)
            wanted[lm.get(cn, cn)] = fn_callees(d, lm)
    for fn, (loc, ab) in calls(tree, wanted).items():
        print('%s\tlocal: %s\tabsolute: %s' % (fn, ' '.join(sorted(loc)), ' '.join(sorted(ab))))


if __name__ == '__main__':
    main()
