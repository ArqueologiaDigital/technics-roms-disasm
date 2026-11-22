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
HASH_STRIP = False


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


WALK = (-1, 1)                                      # (bucket order, chain order): +1 ascending, -1 descending


SIZES = {'SCHAR': 1, 'UCHAR': 1, 'SSHORT': 2, 'USHORT': 2, 'SINT': 2, 'UINT': 2, 'SLONG': 4, 'ULONG': 4}
BIN3 = {'+', '-', '*', '/', '%', '<<', '>>', '&', '|', '^'}
TNAME = re.compile(r'^[*&]?(T\d+)\(')


def tname(x):
    m = TNAME.match(x or '')
    return m.group(1) if m else None


def tsize(x):
    m = re.search(r'\(([A-Z]+)( [FN]\*)?\)', x or '')
    if not m:
        return None
    return 4 if m.group(2) else SIZES.get(m.group(1))


def bare(x):
    """an operand without its (Def) mark"""
    return re.sub(r'\(Def\)', '', x) if x else x


def rewrite2(recs):
    """S2's rewrites on parsed -zio records"""
    def reads_of(t):
        n = 0
        for r in recs:
            for x in r.args + ([r.res] if r.res and r.res.startswith('*') else []):
                if x and (tname(x) == t or ('@(' in x and re.search(r'\b%s\(' % t, x))):
                    n += 1
        return n
    out = []
    for r in recs:
        if r.op == 'CONV' and r.res and r.args and tsize(r.res) and tsize(r.res) == tsize(r.args[0]):
            r.op = '='                               # same size: a copy
        out.append(r)
    recs = out
    # addressing modes: a pointer + constant / index, read once through a dereference
    changed = True
    while changed:
        changed = False
        for k, r in enumerate(recs):
            if r.op in ('+', 'ADD') and r.res and len(r.args) == 2 and tname(r.res) and reads_of(tname(r.res)) == 1:
                t = tname(r.res)
                use = next((u for u in recs[k + 1:] if any(x and x.startswith('*') and tname(x) == t
                                                           for x in u.args + [u.res])), None)
                if use is None:
                    continue
                b, i = r.args
                if r.op == '+':
                    m = re.match(r'^#[ CL]?U?(-?\d+)$', i)
                    if not m:
                        continue
                    mem = '@(%s%+d)' % (b, int(m.group(1)))
                else:
                    mem = '@(%s+%s)' % (b, i)
                for j, x in enumerate(use.args):
                    if x and x.startswith('*') and tname(x) == t:
                        use.args[j] = mem
                if use.res and use.res.startswith('*') and tname(use.res) == t:
                    use.res = mem
                del recs[k]
                changed = True
                break
    out = []
    for r in recs:
        if r.op == 'ADD' and len(r.args) == 2:     # an index still needed as an address
            r.op, r.args = 'ADDR', ['@(%s+%s)' % (r.args[0], r.args[1])]
        if r.op in BIN3 and r.res and len(r.args) == 2 and not r.res.startswith('L'):
            a, b = r.args
            res = bare(r.res)
            out.append(dump.Rec(r.block, '=', res, [a], None, ''))
            out.append(dump.Rec(r.block, r.op + '=', res, [res if b == a else b], None, ''))
            continue
        out.append(r)
    return out


def def_marks(lines):
    """(Def) recomputed on the S2 text: a temporary written once and read at most once"""
    w, rd = {}, {}
    for l in lines:
        r = dump.parse_line(l)
        if r is None:
            continue
        t = tname(r.res) if r.res and not r.res.startswith('*') else None
        if t and r.op not in dump.BRANCH:
            w[t] = w.get(t, 0) + 1
        for x in r.args + ([r.res] if r.res and r.res.startswith('*') else []):
            for y in re.findall(r'\b(T\d+)\(', x or ''):
                rd[y] = rd.get(y, 0) + 1
        if r.op.endswith('=') and r.op not in ('=',) and t:
            rd[t] = rd.get(t, 0) + 1
    ok = {t for t, n in w.items() if n == 1 and rd.get(t, 0) <= 1}

    def mark(l):
        if ' DUMMY' in l:
            return l
        l = re.sub(r'\(Def\)', '', l)
        return re.sub(r'\b(T\d+)(\([^()]*\))', lambda m: m.group(0) + ('(Def)' if m.group(1) in ok else ''), l)
    return [mark(l) for l in lines]


def s2_lines(zio, decl_order=None):
    """thc2's -zio lines of one function (FUNC_START .. FUNC_END) -> our -zim lines; decl_order: the symbol names
    of thc1's file in declaration order up to this function (for the table walk's order)"""
    recs = [dump.parse_line(l) for l in zio[1:-1]]
    if REWRITE2:
        recs = rewrite2(recs)
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
                for y, yt in re.findall(r'((?:@[\w.$]+|P\d+))(\([^()]*\))', x):   # inside a memory operand
                    if y.startswith('P') and y not in [p for p, _ in params]:
                        params.append((y, y + yt))
                    elif y.startswith('@') and y not in [g for g, _ in globs]:
                        globs.append((y, y + yt))
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
            import flow
            for n, full in sorted(params, key=lambda p: -int(p[0][1:])):
                if int(n[1:]) <= 2:                  # {MO}: live across a call (moved out of its argument register)
                    mo = '{MO}' if PARAM_MO and flow.live_across_call(recs, n) else ''
                    out.append('  0:   |%s%s DUMMY ' % (re.sub(r'(\(Def\))+$', '', full), mo))
            for n, full in sorted(addr_taken, key=lambda p: -int(p[0][1:])):
                out.append('  0:   |%s{MM} DUMMY ' % re.sub(r'(\(Def\))+$', '', full))   # in memory
            continue
        r.block = 0
        out.append(dump.line(r))
    out.append(zio[-1])
    if addr_taken:                                   # an address-taken local is in memory everywhere: {MM}
        names = {n for n, _ in addr_taken}
        out = [re.sub(r'\b(%s)(\([^()]*\))(?!\{)' % '|'.join(names), r'\1\2{MM}', l) if ' DUMMY' not in l else l
               for l in out]
    return def_marks(out) if REWRITE2 else out


REWRITE2 = True
PARAM_MO = False                                    # OPEN: {MO} on parameters is not "live across a call" (1,150 right, 382 false positives, 45 missed; exact 416 -> 406)
