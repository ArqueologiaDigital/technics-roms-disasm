#!/usr/bin/env python3
"""Stage S3 of the rebuilt back end (README.md): the register each parameter and local gets, from thc2's -zim dump
(its state after the allocate / spill loop: memory-marked variables are on the stack).  Checked by s3_check.py
against the storage records thc2's -g option writes.

Rules so far (fitted on the firmware C, runs 2026-11-22-51..54):
  - a variable marked {MO} / {MM} / PIN is on the stack;
  - a parameter live across a call (and not spilled) is in IZ / XIZ (QIZ when IZ is taken, by size);
  - another parameter stays in its argument register: P0 A / WA / XWA, P1 C / BC / XBC, P2 E / DE / XDE;
  - a local live across a call takes IZ / XIZ like a parameter, locals first;
  - another local takes the first free register of BC, DE, HL, IX, IY (by size: C / E / L / ... for a byte),
    locals in reverse declaration order (regalloc_notes.md's leaf rule), skipping the parameters' registers.
"""
import re

import dump
import flow

FAM = {'XWA': ('A', 'WA', 'XWA'), 'XBC': ('C', 'BC', 'XBC'), 'XDE': ('E', 'DE', 'XDE'), 'XHL': ('L', 'HL', 'XHL'),
       'XIX': (None, 'IX', 'XIX'), 'XIY': (None, 'IY', 'XIY'), 'XIZ': (None, 'IZ', 'XIZ')}
SIZES = {'SCHAR': 1, 'UCHAR': 1, 'SSHORT': 2, 'USHORT': 2, 'SINT': 2, 'UINT': 2, 'SLONG': 4, 'ULONG': 4}
ARGREG = ['XWA', 'XBC', 'XDE']
RETURN_HL = True


def size_of(full):
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', full)
    if not m:
        return 4                                    # a user type: a pointer or a structure address
    return 4 if m.group(2) else SIZES.get(m.group(1), 2)


def reg(fam, size):
    r = FAM[fam][{1: 0, 2: 1, 4: 2}[size]]
    return r or FAM[fam][1]


def allocate(zim):
    """thc2's -zim lines of one function -> {'P0': register or 'stack', 'I1': ...}"""
    recs = [dump.parse_line(l) for l in zim[1:-1]]
    text = '\n'.join(zim)
    names = {}
    for m in re.finditer(r'\b([IP]\d+)(\([^()]*\))(\{..\})?', text):
        names.setdefault(m.group(1), [m.group(1) + m.group(2), False])
        if m.group(3) in ('{MO}', '{MM}'):
            names[m.group(1)][1] = True
    for m in re.finditer(r'\|([IP]\d+)\([^()]*\)(?:\{..\})? PIN', text):
        names[m.group(1)][1] = True
    out = {}
    xiz = 2                                          # IZ / QIZ halves free
    params = sorted([n for n in names if n.startswith('P')], key=lambda n: int(n[1:]))
    locs = sorted([n for n in names if n.startswith('I')], key=lambda n: -int(n[1:]))
    across = {n for n in names if not names[n][1] and flow.live_across_call(recs, n)}
    for n in sorted([x for x in locs if x in across], key=lambda n: int(n[1:])) + [p for p in params if p in across]:
        size = size_of(names[n][0])
        need = 2 if size == 4 else 1
        if need <= xiz:
            out[n] = 'XIZ' if size == 4 else ('IZ' if xiz == 2 else 'QIZ')
            xiz -= need
    used = set()
    for n in params:
        if names[n][1]:
            out[n] = 'stack'
        elif n not in out and int(n[1:]) < 3:
            out[n] = reg(ARGREG[int(n[1:])], size_of(names[n][0]))
            used.add(ARGREG[int(n[1:])])
    order = ['XBC', 'XDE', 'XHL', 'XIX', 'XIY']
    for n in locs:
        if names[n][1]:
            out[n] = 'stack'
            continue
        if n in out:
            continue
        size = size_of(names[n][0])
        if RETURN_HL and re.search(r'\|A = %s\(' % n, text) and 'XHL' not in used:
            out[n] = reg('XHL', size)                # the returned value is pinned to the HL family
            used.add('XHL')
            continue
        for f in order:
            if f in used or (size == 1 and FAM[f][0] is None):
                continue
            out[n] = reg(f, size)
            used.add(f)
            break
    return out
