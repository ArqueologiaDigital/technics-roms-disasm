#!/usr/bin/env python3
"""lhy_ast.py -- the cc900 V4.23 oracle's code for the functions of probe lhy.c (corpus/probes/lhy.c, oracle run
2026-11-13-11-micro-lhy), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 lhy_ast.py --check SET [--show N] [--only REGEX]     score against the oracle listing (exact / wrong /
                                                                  declined); run with the model directory on sys.path

The function is classified from its AST alone into the probe's shapes (a long helper statement `/ % *` of long or
unsigned long with an array element at a variable index; the index an int or char parameter, or a local copied from
a global; optionally under `if (divisor != 0)`); the real symbols, element offsets and constant are substituted.
Anything outside the probe's grammar returns None.  The rules are in lhy-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
PROBE = 'corpus/probes/lhy.c'                      # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-11-micro-lhy/out/v423/%s/probes/lhy.asm')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


def symoff(sym, off):
    return sym if not off else '%s + %s' % (sym, hx(off))


# --------------------------------------------------------------------------------------------- AST matching

def is_int(ty, size, signed=None):
    return ty is not None and ty.kind == 'int' and ty.size == size and (signed is None or ty.signed == signed)


def unc(n):
    """strip implicit integral casts"""
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    return n


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def global_long(n, lt):
    """a load of a global long / unsigned long scalar -> its decl"""
    n = cg.strip(n)
    if n.k != 'load' or not is_int(n.ty, 4, lt == 'l'):
        return None
    d = var_of(n.e)
    if d is None or d.kind != 'global' or d.ty is None or not is_int(d.ty, 4, lt == 'l'):
        return None
    return d


def element(n, lt):
    """arr[idx] (an lvalue index node) of a global long array -> (array decl, idx node)"""
    n = cg.strip(n)
    if n.k != 'index' or not is_int(n.ty, 4, lt == 'l'):
        return None
    b = cg.strip(n.base)
    if b.k != 'var' or b.decl.kind != 'global' or b.decl.ty is None or b.decl.ty.kind != 'array':
        return None
    need(b.decl.ty.base is not None and is_int(b.decl.ty.base, 4, lt == 'l'))
    return b.decl, n.idx


def operand(n, lt, ix):
    """('s', decl) a global scalar; ('e', arr) arr[ix]; ('k', value) a constant; else Decline"""
    m = cg.strip(n)
    if m.k == 'load':
        d = global_long(m, lt)
        if d is not None:
            return ('s', d)
        el = element(m.e, lt)
        need(el is not None)
        need(index_of(el[1]) is ix)
        return ('e', el[0])
    c = cg.fold(m)
    need(c.k == 'const' and c.value is not None)
    return ('k', c.value)


def index_of(i):
    """the index variable read by an index expression (a parameter or local, int or char) -> decl"""
    i = unc(i)
    need(i.k == 'load')
    d = var_of(i.e)
    need(d is not None and d.kind in ('param', 'local'))
    need(d.ty is not None and d.ty.kind == 'int' and d.ty.signed and d.ty.size in (1, 2))
    return d


def classify(f):
    """-> dict of features, or Decline"""
    st = cg.flat(f.body)
    need(len(f.params) == 1)
    prm = f.params[0]
    need(prm.ty is not None and prm.ty.kind == 'int' and prm.ty.signed and prm.ty.size in (1, 2))
    need(not prm.addr_taken)
    loc = None
    if st and st[0].k == 'decl':
        loc = st[0].var
        need(st[0].init is not None and not loc.addr_taken)
        need(loc.ty is not None and loc.ty.kind == 'int' and loc.ty.signed and loc.ty.size in (1, 2))
        init = cg.strip(st[0].init)
        need(init.k == 'load' and is_int(init.ty, loc.ty.size, True))
        gidx = var_of(init.e)
        need(gidx is not None and gidx.kind == 'global' and is_int(gidx.ty, loc.ty.size, True))
        st = st[1:]
        # T: the parameter is an unused int
        need(prm.ty.size == 2)
    need(len(st) == 1)
    s = st[0]
    guard = None
    if s.k == 'if':
        need(s.els is None)
        guard = cg.strip(s.cond)
        need(guard.k == 'bin' and guard.op == '!=')
        z = cg.fold(unc(guard.r))
        need(z.k == 'const' and z.value == 0)
        s = s.then
        if s.k == 'block':
            b = cg.flat(s)
            need(len(b) == 1)
            s = b[0]
    ret = False
    if s.k == 'return':
        need(s.value is not None)
        e = cg.strip(s.value)
        ret = True
        dst = None
    else:
        need(s.k == 'expr')
        a = cg.strip(s.e)
        need(a.k == 'bin' and a.op == '=')
        dst = cg.strip(a.l)
        e = cg.strip(a.r)
    need(e.k == 'bin' and e.op in ('/', '%', '*'))
    need(e.ty is not None and e.ty.kind == 'int' and e.ty.size == 4)
    lt = 'l' if e.ty.signed else 'n'
    if ret:
        need(f.ret is not None and is_int(f.ret, 4, lt == 'l'))
    else:
        need(f.ret is None or f.ret.kind == 'void')
    # the index variable: the one any element uses
    idxs = []

    def find_idx(n):
        m = cg.strip(n)
        if m.k == 'load':
            m = cg.strip(m.e)
        if m.k == 'index':
            idxs.append(index_of(m.idx))
    find_idx(e.l)
    find_idx(e.r)
    need(idxs)
    ix = idxs[0]
    if loc is None:
        need(ix is prm)
        O = 'P'
    else:
        need(ix is loc)
        O = 'T'
    I = 'i' if ix.ty.size == 2 else 'c'
    L = operand(e.l, lt, ix)
    R = operand(e.r, lt, ix)
    # destination
    if ret:
        D = ('r', None)
    else:
        need(is_int(dst.ty, 4, lt == 'l'))
        if dst.k == 'var':
            d = dst.decl
            need(d.kind == 'global' and is_int(d.ty, 4, lt == 'l'))
            D = ('s', d)
        else:
            el = element(dst, lt)
            need(el is not None)
            ci = cg.fold(unc(el[1]))
            if ci.k == 'const' and ci.value is not None:
                need(1 <= ci.value <= 7)
                D = ('c', el[0], ci.value)
            else:
                need(index_of(el[1]) is ix)
                D = ('e', el[0])
    op = {'/': 'd', '%': 'm', '*': 'x'}[e.op]
    # shapes
    kinds = (D[0], L[0], R[0])
    SH = {('s', 's', 'e'): 'G', ('s', 'e', 's'): 'X', ('e', 's', 'e'): 'EY', ('e', 'e', 's'): 'Z',
          ('s', 'e', 'k'): 'K', ('s', 'k', 'e'): 'J', ('e', 'e', 'k'): 'S', ('c', 'e', 's'): 'C',
          ('c', 's', 'e'): 'D', ('r', 'e', 's'): 'R'}
    need(kinds in SH)
    sh = SH[kinds]
    elem = L[1] if L[0] == 'e' else R[1]
    scal = L[1] if L[0] == 's' else R[1] if R[0] == 's' else None
    k = L[1] if L[0] == 'k' else R[1] if R[0] == 'k' else None
    if sh == 'EY':
        sh = 'Y' if elem is D[1] else 'E'
    if sh in 'ZS':
        need(elem is D[1])
    if sh in 'GXKJCDR' and D[0] != 'r':
        need(elem is not D[1])
    if sh in 'GX':
        need(scal is not D[1])
    if k is not None:
        need(k == 7)
    # guard: the right operand (the divisor) != 0
    g = 'n'
    if guard is not None:
        need(op != 'x' and sh not in 'KS')
        gl = cg.strip(guard.l)
        if R[0] == 's':
            need(global_long(gl, lt) is R[1])
        else:
            need(gl.k == 'load')
            el = element(gl.e, lt)
            need(el is not None and el[0] is R[1] and index_of(el[1]) is ix)
        g = 'g'
    F = dict(t=lt, op=op, I=I, O=O, g=g, sh=sh)
    F['vv'] = '_' + scal.name if scal is not None else None
    F['gv'] = '_' + D[1].name if D[0] == 's' else None
    F['arr'] = '_' + elem.name
    F['ga'] = '_' + D[1].name if D[0] in 'ec' else None
    F['coff'] = D[2] * 4 if D[0] == 'c' else None
    F['gidx'] = '_' + gidx.name if O == 'T' else None
    F['k'] = k
    return F


# --------------------------------------------------------------------------------------------- code

def S_(n):
    return '(XSP+%s)' % hx(n)


def ins(s):
    """'op args' -> '\\top\\targs'"""
    if s.endswith(':'):
        return s
    p = s.split(' ', 1)
    return '\t' + p[0] + ('\t' + p[1] if len(p) > 1 else '')


LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E'}


def gen(F, s):
    """none and Xr: the -O0 code generator (rules: lhy-FAMILIES.md, 'none / Xr')"""
    t, op, I, O, g, sh = F['t'], F['op'], F['I'], F['O'], F['g'], F['sh']
    helper = 'C9H_' + {'d': 'div', 'm': 'rem', 'x': 'mul'}[op] + 'l' + ('s' if t == 'l' else 'u')
    shl = 'sla' if t == 'l' else 'sll'
    vv, gv, arr, ga, gidx = F['vv'], F['gv'], F['arr'], F['ga'], F['gidx']
    cst = symoff(ga, F['coff']) if F['coff'] is not None else None
    K = hx(F['k']) if F['k'] is not None else None
    wi = I == 'i'
    xr = s == 'Xr'

    def r8(p):
        return p if wi else LOW[p]
    WA, BC = r8('WA'), r8('BC')
    mul = op == 'x'
    guarded = g == 'g'
    if mul and sh in 'KJS':
        return inline_mul(F, s, shl)
    held = sh in 'ZSC' or (mul and sh in 'EYD')
    need_after = sh in 'EY' and not held
    GUARD_ELEM = 'GEYJD'
    uses_elem = held and sh in 'ZSEY' or (guarded and sh in GUARD_ELEM)
    clobber = (guarded and sh not in GUARD_ELEM) or (held and sh in 'CD')
    # where the index lives
    if O == 'P':
        kind = 'param' if not xr else 'pslot' if need_after else 'reg'
        reg = 'WA' if kind == 'reg' else None
    else:
        kind = 'slot' if need_after else 'reg' if (uses_elem or clobber) else 'direct'
        reg = 'DE' if uses_elem else 'BC' if clobber else None
    off = 4
    slots = {}
    if kind == 'slot':
        slots['i'] = off
        off += 2
    if held:
        slots['addr'] = off
        off += 4
    slots['T'] = off
    off += 2
    if kind == 'pslot':
        slots['i'] = off
        off += 2
    N = off - 4
    if kind == 'param':
        src = S_(N + 8)
    elif kind in ('slot', 'pslot'):
        src = S_(slots['i'])
    elif kind == 'reg':
        src = r8(reg)
    else:
        src = '(%s)' % gidx
    T = S_(slots['T'])
    # scratch pairs: the first two of WA BC DE not holding the index
    sa, sb = [p for p in ('WA', 'BC', 'DE') if p != reg][:2]
    a = r8(sa)

    def ld(r, x):
        return [] if r == x else ['ld %s,%s' % (r, x)]
    out = ['dec %s,XSP' % hx(N), 'push XIZ']
    if kind == 'reg' and O == 'T':
        out.append('ld %s,(%s)' % (src, gidx))
    if kind == 'slot':
        out += ['ld %s,(%s)' % (WA, gidx), 'ld %s,%s' % (src, WA)]
    if kind == 'pslot':
        out.append('ld %s,%s' % (src, WA))
    if guarded:
        if sh in GUARD_ELEM:
            out += ld(a, src) + ['sla 0x2,%s' % a, 'lda X%s,%s' % (sb, arr), 'ld X%s,(X%s+%s)' % (sa, sb, a)]
        else:
            out.append('ld X%s,(%s)' % (sa, vv))
        out += ['or X%s,X%s' % (sa, sa), 'j eq,L1']
    if held:
        if sh in 'CD':
            out.append('lda X%s,%s' % (sa, cst))
        elif wi:
            out += ld(a, src) + ['sla 0x2,%s' % a, 'lda X%s,%s' % (sb, ga), 'exts X%s' % sa,
                                 'add X%s,X%s' % (sa, sb)]
        else:
            out += ld(a, src) + ['sla 0x2,%s' % a, 'lda X%s,%s' % (sb, ga), 'lda X%s,X%s+%s' % (sa, sb, a)]
        out.append('ld %s,X%s' % (S_(slots['addr']), sa))
    if wi:
        if src in ('WA', 'BC', 'DE'):
            out.append('ld %s,%s' % (T, src))
        else:
            out += [ 'ld WA,%s' % src, 'ld %s,WA' % T]
        out += ['ld WA,%s' % T, 'sla 0x2,WA', 'ld %s,WA' % T]
    else:
        out += ld('A', src) + ['sla 0x2,A', 'ld %s,A' % T]
    out.append('lda XIZ,%s' % arr)
    if sh in 'KS':
        out += ['ld %s,%s' % (WA, T), 'ld XWA,(XIZ+%s)' % WA, 'ld XBC,%s' % K]
    elif sh == 'J':
        out += ['ld %s,%s' % (BC, T), 'ld XWA,%s' % K, 'ld XBC,(XIZ+%s)' % BC]
    elif sh in GUARD_ELEM:
        out += ['ld XWA,(%s)' % vv, 'ld %s,%s' % (BC, T), 'ld XBC,(XIZ+%s)' % BC]
    else:
        out += ['ld XBC,(%s)' % vv, 'ld %s,%s' % (WA, T), 'ld XWA,(XIZ+%s)' % WA]
    out.append('cal ' + helper)
    if held:
        out += ['ld XWA,%s' % S_(slots['addr']), 'ld (XWA),XHL']
    elif sh in 'EY':
        out += ['ld %s,%s' % (WA, src), 'sla 0x2,%s' % WA, 'lda XBC,%s' % ga, 'ld (XBC+%s),XHL' % WA]
    elif sh == 'D':
        out.append('ld (%s),XHL' % cst)
    elif sh == 'R':
        pass
    else:
        out.append('ld (%s),XHL' % gv)
    if guarded:
        out.append('L1:')
    out += ['pop XIZ', 'inc %s,XSP' % hx(N), 'ret']
    return out


def inline_mul(F, s, shl):
    """x * 7 with no helper: (x << 3) - x, a leaf"""
    wi = F['I'] == 'i'
    arr, gv, ga = F['arr'], F['gv'], F['ga']
    WA, DE = ('WA', 'DE') if wi else ('A', 'E')
    reg = F['O'] == 'P' and s == 'Xr'
    src = WA if reg else '(XSP+0x4)' if F['O'] == 'P' else '(%s)' % F['gidx']
    head = [] if src == WA else ['ld %s,%s' % (WA, src)]
    if F['sh'] in 'KJ':
        return head + ['sla 0x2,%s' % WA, 'lda XBC,%s' % arr, 'ld XBC,(XBC+%s)' % WA,
                       'ld XWA,XBC', '%s 0x3,XWA' % shl, 'sub XWA,XBC', 'ld (%s),XWA' % gv, 'ret']
    # S: the destination address first, in XHL + DE (TABULATED: how the scaled copy reaches DE / E)
    if wi:
        if F['O'] == 'P':
            head = ['ld DE,%s' % src, 'sla 0x2,DE', 'lda XHL,%s' % ga] + ([] if reg else ['ld WA,%s' % src])
        else:
            head = ['ld WA,%s' % src, 'ld DE,WA', 'sla 0x2,DE', 'lda XHL,%s' % ga]
    elif reg:
        head = ['ld C,A', 'sla 0x2,C', 'ld E,C', 'lda XHL,%s' % ga]
    elif F['O'] == 'P':
        head = ['ld A,%s' % src, 'sla 0x2,A', 'ld E,A', 'lda XHL,%s' % ga, 'ld A,%s' % src]
    else:
        head = ['ld C,%s' % src, 'ld A,C', 'sla 0x2,A', 'ld E,A', 'lda XHL,%s' % ga, 'ld A,C']
    return head + ['sla 0x2,%s' % WA, 'lda XBC,%s' % ga, 'ld XWA,(XBC+%s)' % WA, 'ld XBC,XWA',
                   '%s 0x3,XBC' % shl, 'sub XBC,XWA', 'ld (XHL+%s),XBC' % DE, 'ret']


def scaled(r, src, wi):
    """the scaled index (index * 4) into register r (O3 sets).  src: '(mem)' a parameter slot, '(_g)' a global, or
    the register the index lives in ('WA' / 'A')"""
    if wi:
        if src == 'WA':
            return ['ld %s,WA' % r, 'sla 0x2,%s' % r]
        if r == 'IZ' and not src.startswith('(XSP'):
            return ['ld WA,%s' % src, 'ld IZ,WA', 'sla 0x2,IZ']
        return ['ld %s,%s' % (r, src), 'sla 0x2,%s' % r]
    if src.startswith('(XSP') and r != 'QIZH':
        return ['ld %s,%s' % (r, src), 'sla 0x2,%s' % r]
    return ([] if src == 'A' else ['ld A,%s' % src]) + ['sla 0x2,A', 'ld %s,A' % r]


def gen_o3(F, s):
    """O3XS and O3XSXr: the -O3 -XS code generator (rules: lhy-FAMILIES.md, 'O3XS / O3XSXr')"""
    t, op, I, O, g, sh = F['t'], F['op'], F['I'], F['O'], F['g'], F['sh']
    helper = 'C9H_' + {'d': 'div', 'm': 'rem', 'x': 'mul'}[op] + 'l' + ('s' if t == 'l' else 'u')
    shl = 'sla' if t == 'l' else 'sll'
    vv, gv, arr, ga, gidx = F['vv'], F['gv'], F['arr'], F['ga'], F['gidx']
    cst = symoff(ga, F['coff']) if F['coff'] is not None else None
    K = hx(F['k']) if F['k'] is not None else None
    wi = I == 'i'
    xr = s == 'O3XSXr'

    def r8(p):
        return p if wi else LOW[p]
    WA, BC = r8('WA'), r8('BC')
    mul = op == 'x'
    guarded = g == 'g'
    preg = O == 'P' and xr                       # the index arrives in WA / A
    vreg = r8('WA') if preg else None

    def src_at(push):
        """the index's source when it is read where it is used; push: bytes pushed below the return address"""
        if preg:
            return vreg
        if O == 'P':
            return S_(4 + push)
        return '(%s)' % gidx
    store_scalar = ['ld (%s),XHL' % gv] if sh in 'GXKJ' else ['ld (%s),XHL' % cst] if sh == 'D' else []
    # F5: x * 7, open coded
    if mul and sh in 'KJ':
        src = src_at(0)
        return ([] if src == WA else ['ld %s,%s' % (WA, src)]) + [
            'sla 0x2,%s' % WA, 'lda XBC,%s' % arr, 'ld XBC,(XBC+%s)' % WA, 'ld XWA,XBC', '%s 0x3,XWA' % shl,
            'sub XWA,XBC', 'ld (%s),XWA' % gv, 'ret']
    if mul and sh == 'S':
        out = scaled(BC, src_at(0), wi) + ['lda XWA,%s' % ga]
        out += ['exts XBC', 'add XBC,XWA'] if wi else ['lda XBC,XWA+C']
        return out + ['ld XWA,(XBC)', 'ld XDE,XWA', '%s 0x3,XDE' % shl, 'sub XDE,XWA', 'ld (XBC),XDE', 'ret']
    # F2: the destination element is an operand: its address in XIZ
    if sh in 'ZYS':
        r = 'DE' if guarded and sh == 'Z' else 'BC'
        out = ['push XIZ']
        sc = scaled(r8(r), src_at(4), wi)
        if (O == 'T' or preg) and guarded and sh == 'Z':
            # the index variable is in a register from the start: int in r, char in A
            if wi:
                out.append(sc[0])
                sc = sc[1:]
            elif O == 'T':
                out.append(sc[0])
                sc = sc[1:]
        if guarded and sh == 'Z':
            out += ['ld XBC,(%s)' % vv, 'or XBC,XBC', 'j eq,L1']
        out += sc + ['lda XWA,%s' % ga, 'lda XIZ,XWA+%s' % r8(r)]
        if sh in 'ZS':
            out.append('ld XWA,(XIZ)')
            if not guarded:
                out.append('ld XBC,%s' % (K if sh == 'S' else '(%s)' % vv))
        else:
            out.append('ld XBC,(XIZ)')
            if guarded:
                out += ['or XBC,XBC', 'j eq,L1']
            out.append('ld XWA,(%s)' % vv)
        out += ['cal ' + helper, 'ld (XIZ),XHL'] + (['L1:'] if guarded else []) + ['pop XIZ', 'ret']
        return out
    # F3: guard on the element, which is then the divisor: no frame
    if guarded and sh in 'GJD':
        out = scaled(BC, src_at(0), wi) + ['lda XWA,%s' % arr, 'ld XBC,(XWA+%s)' % BC, 'or XBC,XBC', 'ret eq',
                                           'ld XWA,%s' % (K if sh == 'J' else '(%s)' % vv), 'cal ' + helper]
        return out + store_scalar + ['L1:', 'ret']
    # F4: guard on the element of E: the scaled index kept in IZ (int) / QIZH (char)
    if guarded and sh == 'E':
        pr, r = ('IZ', 'IZ') if wi else ('QIZ', 'QIZH')
        out = ['push %s' % pr] + scaled(r, src_at(2), wi)
        return out + ['lda XWA,%s' % arr, 'ld XBC,(XWA+%s)' % r, 'or XBC,XBC', 'j eq,L1', 'ld XWA,(%s)' % vv,
                      'cal ' + helper, 'lda XWA,%s' % ga, 'ld (XWA+%s),XHL' % r, 'L1:', 'pop %s' % pr, 'ret']
    # F1 / F6: the frame, the scaled index in a slot T
    need(sh in 'GXEKJCDR')
    need(not guarded or sh in 'XCR')
    held = sh in 'CD' and (sh == 'C' or mul) or (sh == 'E' and mul)
    N = 6 if held else 2
    Ts = S_(8 if held else 4)
    addr = S_(4)
    regs = ['WA', 'BC', 'DE']
    used = [vreg and 'WA']
    hreg = greg = None
    if held and sh in 'CD':
        hreg = [p for p in regs if p not in used][0]
        used.append(hreg)
    if guarded:
        greg = 'BC' if 'BC' not in used else [p for p in regs if p not in used][0]
        used.append(greg)
    out = ['dec %s,XSP' % hx(N), 'push XIZ']
    if O == 'T':
        v = [p for p in regs if p not in used][0]
        src = r8(v)
        out.append('ld %s,(%s)' % (src, gidx))
    else:
        src = src_at(4 + N) if not preg else vreg
    if guarded:
        out += ['ld X%s,(%s)' % (greg, vv), 'or X%s,X%s' % (greg, greg), 'j eq,L1']
    if hreg:
        out += ['lda X%s,%s' % (hreg, cst), 'ld %s,X%s' % (addr, hreg)]
    if wi:
        if src in regs:
            out.append('ld %s,%s' % (Ts, src))
        else:
            out += ['ld WA,%s' % src, 'ld %s,WA' % Ts]
        out += ['ld WA,%s' % Ts, 'sla 0x2,WA', 'ld %s,WA' % Ts]
    else:
        if src in ('A', 'C', 'E'):
            out += ['sla 0x2,%s' % src, 'ld %s,%s' % (Ts, src)]
        else:
            out += ['ld A,%s' % src, 'sla 0x2,A', 'ld %s,A' % Ts]
    if held and sh == 'E':
        need(wi)
        out += ['lda XBC,%s' % ga, 'ld DE,%s' % Ts, 'lda XWA,XBC+DE', 'ld %s,XWA' % addr, 'lda XIZ,%s' % arr,
                'ld XWA,(%s)' % vv, 'ld XBC,(XIZ+DE)']
    else:
        out.append('lda XIZ,%s' % arr)
        if sh in 'GED':
            out += ['ld %s,%s' % (BC, Ts), 'ld XWA,(%s)' % vv, 'ld XBC,(XIZ+%s)' % BC]
        elif sh == 'J':
            out += ['ld %s,%s' % (BC, Ts), 'ld XWA,%s' % K, 'ld XBC,(XIZ+%s)' % BC]
        else:
            out += ['ld %s,%s' % (WA, Ts), 'ld XWA,(XIZ+%s)' % WA]
            if sh == 'K':
                out.append('ld XBC,%s' % K)
            elif not guarded:
                out.append('ld XBC,(%s)' % vv)
            elif greg != 'BC':
                out.append('ld XBC,X%s' % greg)
    out.append('cal ' + helper)
    if held:
        out += ['ld XWA,%s' % addr, 'ld (XWA),XHL']
    elif sh == 'E':
        out += ['lda XBC,%s' % ga, 'ld %s,%s' % (WA, Ts), 'ld (XBC+%s),XHL' % WA]
    else:
        out += store_scalar
    if guarded:
        out.append('L1:')
    return out + ['pop XIZ', 'inc %s,XSP' % hx(N), 'ret']


# --------------------------------------------------------------------------------------------- entry

def whole(f, s):
    if s not in SETS:
        return None
    try:
        F = classify(f)
        if s in ('none', 'Xr'):
            return [ins(x) for x in gen(F, s)]
        return [ins(x) for x in gen_o3(F, s)]
    except Decline:
        return None


def check(s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(PROBE, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        got = whole(f, s)
        if got is None:
            dec += 1
            continue
        if listing.normalise_labels(got) == listing.normalise_labels(W):
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    print('  %-36s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d' % (s, ok, wrong, dec))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        for s in (a[1:2] if len(a) > 1 and a[1] in SETS else SETS):
            check(s, show, only)
    else:
        print(__doc__)
