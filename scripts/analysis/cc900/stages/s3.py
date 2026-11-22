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
INTERFERENCE = True
AVOID_WA_TEMPS = True
TEMP_FAMS = 4
OP_CLOBBERS = True
BYTE_HIGH = True
TEMP_ORDER = ('XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY')
TEMPS_FIRST = False                                 # tested: temporaries coloured first lose 197-257 variables
TEMP_DIR = 1
CALL_RESULT_HL = True
BYTE_QIZH = True
LOCAL_DIR = -1
LOCAL_ORDER = ('XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY')


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
    for m in re.finditer(r'\b([IPT]\d+)(\([^()]*\))(\{..\})?' if TEMPS_FIRST else r'\b([IP]\d+)(\([^()]*\))(\{..\})?',
                         text):
        names.setdefault(m.group(1), [m.group(1) + m.group(2), False])
        if m.group(3) in ('{MO}', '{MM}'):
            names[m.group(1)][1] = True
    for m in re.finditer(r'\|([IP]\d+)\([^()]*\)(?:\{..\})? PIN', text):
        names[m.group(1)][1] = True
    out = {}
    xiz = 2                                          # IZ / QIZ halves free
    params = sorted([n for n in names if n.startswith('P')], key=lambda n: int(n[1:]))
    locs = sorted([n for n in names if n.startswith('I')], key=lambda n: LOCAL_DIR * int(n[1:]))
    temps = sorted([n for n in names if n.startswith('T')], key=lambda n: TEMP_DIR * int(n[1:]))
    if TEMPS_FIRST:
        locs = temps + locs
    across = {n for n in names if not n.startswith('T') and not names[n][1] and flow.live_across_call(recs, n)}
    for n in sorted([x for x in locs if x in across], key=lambda n: int(n[1:])) + [p for p in params if p in across]:
        size = size_of(names[n][0])
        need = 2 if size == 4 else 1
        if need <= xiz:
            if size == 1 and BYTE_QIZH:
                out[n] = 'QIZH' if xiz == 2 else 'IZL'   # a byte kept across calls: the high byte of QIZ first
            else:
                out[n] = 'XIZ' if size == 4 else ('IZ' if xiz == 2 else 'QIZ')
            xiz -= need
    used = set()
    for n in params:
        if names[n][1]:
            out[n] = 'stack'
        elif n not in out and int(n[1:]) < 3:
            out[n] = reg(ARGREG[int(n[1:])], size_of(names[n][0]))
            used.add(ARGREG[int(n[1:])])
    order = list(LOCAL_ORDER)
    inter = flow.interference(recs, list(names)) if INTERFERENCE else None
    busy = {}                                        # local -> families temporaries take while it is live: with k
    if AVOID_WA_TEMPS:                               # temporaries live at a point, XWA, XBC, ... (k of them)
        tnames = sorted(set(re.findall(r'\b(T\d+)\(', text)))
        lives = flow.live_sets(recs, list(names) + tnames)
        for i, r in enumerate(recs):
            if r.res and re.match(r'^T\d+\(', r.res):
                after = lives[i + 1] if i + 1 < len(recs) else set()
                k = len({x for x in after if x.startswith('T')} | {r.res.split('(')[0]})
                held = set()                         # families of parameters live there are not the temporaries'
                for x in (lives[i] | after):
                    if x.startswith('P') and x in out:
                        held |= {f for f, fam in FAM.items() if out[x] in fam}
                fams = [f for f in TEMP_ORDER if f not in held][:min(k, TEMP_FAMS)]
                for x in after:
                    if not x.startswith('T'):
                        busy.setdefault(x, set()).update(fams)
    if OP_CLOBBERS:                                  # instructions that clobber fixed registers (thc2's allocator):
        lives2 = flow.live_sets(recs, list(names))   # what is live across them avoids those registers
        for i, r in enumerate(recs):
            fams = ()
            if r.op == 'AARG' and r.extra and re.match(r'^#0,(\d+)$', r.extra):
                k = int(r.extra.split(',')[1])
                fams = (ARGREG[k - 1],) if 1 <= k <= 3 else ()
            elif r.op in ('LDIR', 'LDDR'):
                fams = ('XBC', 'XIX', 'XIY')
            elif r.op == 'Switch':
                fams = ('XIX',)
            if fams:
                after = lives2[i + 1] if i + 1 < len(recs) else set()
                for x in after:
                    busy.setdefault(x, set()).update(fams)
    owner = {}                                       # family -> variables holding it (for sharing when disjoint)
    for n, r_ in out.items():
        for f, fam in FAM.items():
            if r_ in fam or r_ in ('QIZ', 'QIZH', 'IZL') and f == 'XIZ':
                owner.setdefault(f, set()).add(n)
    for n in locs:
        if names[n][1]:
            out[n] = 'stack'
            continue
        if n in out:
            continue
        size = size_of(names[n][0])
        def free(f):
            if inter is None:
                return f not in used
            return not (owner.get(f, set()) & (inter.get(n, set()) | ({p for p in params if p not in out} if False else set())))
        if RETURN_HL and (re.search(r'\|A = %s\(' % n, text) or
                          (CALL_RESULT_HL and re.search(r'\|%s\([^()]*\)(?:\{..\})? (?:A|C)CAL[LP] ' % n, text))) \
                and free('XHL'):
            out[n] = reg('XHL', size)                # the returned value is pinned to the HL family
            used.add('XHL')
            owner.setdefault('XHL', set()).add(n)
            continue
        for f in order:
            if not free(f) or (size == 1 and FAM[f][0] is None) or f in busy.get(n, ()):
                continue
            out[n] = reg(f, size)
            used.add(f)
            owner.setdefault(f, set()).add(n)
            break
        if n not in out and size == 1 and BYTE_HIGH:   # a byte: the high byte of a family whose low part a
            for f, hi in (('XWA', 'W'), ('XBC', 'B'), ('XDE', 'D'), ('XHL', 'H')):   # temporary holds
                blockers = {v for v in owner.get(f, set()) & inter.get(n, set()) if size_of(names[v][0]) > 1} \
                    if inter is not None else set()
                if not blockers and (f in busy.get(n, ()) or owner.get(f)):
                    out[n] = hi
                    owner.setdefault(f, set()).add(n)
                    break
    return out
