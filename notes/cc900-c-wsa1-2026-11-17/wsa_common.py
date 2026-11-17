#!/usr/bin/env python3
"""Shared readers for the SX-WSA1R cc900 lane: the three program images, their symbols and their source lines.

Not a command.  The WSA1R has no symbols reference file: names and addresses are read from the linked ELFs
(`make wsa1` first), `t` / `T` rows being labels and `a` rows the `.equ` values.  CPU 1 is one link of prom_b
(0xF00000) and prom_a (0xF80000), so both trees read wsa1_maincpu.llvm.elf; CPU 2 is prom_c (0xF80000).
"""
import os, re, subprocess

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
# tree: (ROM image, its base address, the ELF with its names)
TREES = {'wsa1/prom_a': ('wsa1/original_ROMs/wsa1_prom_a.ic12', 0xF80000, 'wsa1/rebuilt_ROMs/wsa1_maincpu.llvm.elf'),
         'wsa1/prom_b': ('wsa1/original_ROMs/wsa1_prom_b.ic13', 0xF00000, 'wsa1/rebuilt_ROMs/wsa1_maincpu.llvm.elf'),
         'wsa1/prom_c': ('wsa1/original_ROMs/wsa1_prom_c.ic28', 0xF80000, 'wsa1/rebuilt_ROMs/wsa1_prom_c.llvm.elf')}
_SYMS = {}


def symbols(tree):
    """({label: address}, {equ name: value}) of TREE's ELF"""
    elf = os.path.join(REPO, TREES[tree][2])
    if elf not in _SYMS:
        if not os.path.exists(elf):
            raise SystemExit('%s is missing: run `make wsa1` first' % elf)
        labels, values = {}, {}
        for l in subprocess.run([NM, elf], check=True, capture_output=True, text=True).stdout.splitlines():
            p = l.split()
            if len(p) == 3 and p[1] in 'tT':
                labels[p[2]] = int(p[0], 16)
            elif len(p) == 3 and p[1] == 'a':
                values[p[2]] = int(p[0], 16)
        _SYMS[elf] = (labels, values)
    return _SYMS[elf]


def rom(tree):
    """(bytes, base address) of TREE's reference image"""
    f, base, _ = TREES[tree]
    return open(os.path.join(REPO, f), 'rb').read(), base


def own_labels(tree):
    """the labels whose address lies in TREE's own image"""
    labels, _ = symbols(tree)
    base = TREES[tree][1]
    return {n: a for n, a in labels.items() if base <= a < base + 0x80000}


def source_files(tree):
    """TREE's hand sources (.s), sorted; generated and C directories left out"""
    out = []
    for dp, dn, fn in os.walk(os.path.join(REPO, tree)):
        dn[:] = sorted(d for d in dn if d not in ('generated', 'cc900', 'cc900-staged', 'images'))
        out += [os.path.join(dp, f) for f in sorted(fn) if f.endswith('.s')]
    return out


LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):\s*(.*)$')


def items(path):
    """[(line number, [labels before this statement], statement)] of one source, comments stripped; read as bytes
    (latin-1), since the sources hold raw ROM text"""
    out, pend = [], []
    for n, raw in enumerate(open(path, 'rb').read().decode('latin-1').split('\n'), 1):
        c = raw.split(';')[0].strip()
        while True:
            m = LABEL.match(c)
            if not m:
                break
            pend.append(m.group(1)); c = m.group(2).strip()
        if c:
            out.append((n, pend, ' '.join(c.split()))); pend = []
    return out
