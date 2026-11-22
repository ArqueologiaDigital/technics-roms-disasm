#!/usr/bin/env python3
"""Stage S2 of the rebuilt back end (README.md): from thc2's state after S1 (its -zio dump, read with dump.py) to its
state when code selection starts (its -zim dump), so that S2 is developed and checked on V4.23's own S1 output.

What it does so far (fitted with s2_check.py on the firmware C, runs 2026-11-22-51..54):
  - a DUMMY line after BEGIN for each value live on entry: the globals read as data (first appearance order), then
    the register parameters used (highest first);
  - block numbers are no longer printed (all 0).

    python3 -B scripts/analysis/cc900/stages/s2_check.py RUN_DIR ...      (the comparison)
"""
import re

import dump

NAME = re.compile(r'^[*&]?(@[\w.$]+|P\d+)\(')


HASH_AT = False
HASH_STRIP = True


def sym_hash(name):
    """thc2's symbol-table bucket: h = c + 2h over the name's (signed) characters, low 4 bits"""
    h = 0
    nm = name if HASH_AT else name.lstrip('@')
    if HASH_STRIP and nm[:1] in '_.':
        nm = nm[1:]                                 # (the C name: without the assembler's prefix)
    for ch in nm.encode('latin-1'):
        h = ((ch - 256 if ch > 127 else ch) + 2 * h) & 0xffffffff
    return h & 15


def sym_order(symbols):
    """symbol names in the order thc2 walks its table: bucket by bucket, newest declaration first"""
    pos = {n: i for i, n in enumerate(symbols)}
    bs, cs = WALK
    return lambda n: (bs * sym_hash(n), cs * pos.get(n, -1))


WALK = (-1, -1)                                      # (bucket order, chain order): +1 ascending, -1 descending


def s2_lines(zio, decl_order=None):
    """thc2's -zio lines of one function (FUNC_START .. FUNC_END) -> our -zim lines; decl_order: the symbol names
    of thc1's file in declaration order up to this function (for the table walk's order)"""
    recs = [dump.parse_line(l) for l in zio[1:-1]]
    globs, params, addr_taken = [], [], []
    for r in recs:
        reads = list(r.args)
        if r.res and (r.res.startswith('*') or r.op.endswith('=') and r.op not in ('=', '==', '!=', '<=', '>=') or
                      r.op in ('++', '--', 'BSET', 'BCLR')):
            reads.append(r.res)                    # a compound operation reads its target; a three-address one not
        if r.op == 'ADDR' and r.args and re.match(r'^[IS]\d+\(', r.args[0]):
            if r.args[0] not in [x for _, x in addr_taken]:
                addr_taken.append((r.args[0].split('(')[0], r.args[0]))   # a local / static whose address is taken
        if r.op in ('ACALL', 'CCALL', 'ACALP', 'CCALP') and r.args:
            reads = reads[1:]                      # a call's target is not data
        for x in reads:
            if not x:
                continue
            m = NAME.match(x)
            if not m:
                for y in re.findall(r'(@[\w.$]+|P\d+)\(', x):   # inside a memory operand
                    if y.startswith('P') and y not in [p for p, _ in params]:
                        params.append((y, x))
                continue
            n = m.group(1)
            full = x.lstrip('*&')
            if n.startswith('@') and n not in [g for g, _ in globs]:
                globs.append((n, full))
            elif n.startswith('P') and n not in [p for p, _ in params]:
                params.append((n, full))
    out = [zio[0]]
    for r in recs:
        if r.op == 'BEGIN':
            out.append(dump.line(dump.Rec(0, 'BEGIN', None, [], None, '')))
            if decl_order is not None:
                key = sym_order(decl_order)
                globs.sort(key=lambda g: key(g[0]))
            for n, full in globs:
                out.append('  0:   |%s DUMMY ' % re.sub(r'(\(Def\))+$', '', full))
            for n, full in addr_taken:
                out.append('  0:   |%s DUMMY ' % re.sub(r'(\(Def\))+$', '', full))
            for n, full in sorted(params, key=lambda p: -int(p[0][1:])):
                if int(n[1:]) <= 2:
                    out.append('  0:   |%s DUMMY ' % re.sub(r'(\(Def\))+$', '', full))
            continue
        r.block = 0
        out.append(dump.line(r))
    out.append(zio[-1])
    return out
