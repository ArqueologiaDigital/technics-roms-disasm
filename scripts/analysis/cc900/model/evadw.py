#!/usr/bin/env python3
"""evorder_ad_ast.py -- the cc900 V4.23 oracle's code for the functions of probe evorder_ad.c
(corpus/probes/evorder_ad.c, oracle run 2026-11-10-17-micro-evorder_ad) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 evorder_ad_ast.py --check [SET ...] [--show N] [--only REGEX] [--src FILE.c --map OLD=NEW,...]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path.  --src scores another source (a renamed copy of the probe) against the same
        listing, with the listing's global names mapped by --map.

The probe's functions are `void f(int c) { g<t>2 = L op R; }`, t char / int / long, op + - & | ^ * / %, L and R
one of seven operand kinds (letters as in the probe's names; left side shown, the right reads h*):

    K 7        G gi       P *gpi     D gps->i   X gia[c]   E gia[3]   F gfi()

The function is classified from its AST alone; the real symbols, member and element offsets and callees are
substituted.  Anything outside the probe's grammar returns None.  The code is planned by a small register
allocator in the manner of evorder_st_ast.py (research-scratch tabulation/evorder_st-ast/): registers held over
intervals of the evaluation order, placed in a fixed order, each taking the first free family.  The rules are in
evorder_ad-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402
HOME_ = __import__('os').path.expanduser('~/')
import evlhw  # noqa: E402  (the model's evorder_lh generator: the long helpers' argument order)

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
FAMS = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY')
ALU = {'+': 'add', '-': 'sub', '&': 'and', '|': 'or', '^': 'xor'}
COMM = set('+&|^*')
WIDTH = {'c': 1, 'i': 2, 'l': 4}


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


def R(f, w):
    """family f at width w"""
    if w == 4:
        return 'X' + f
    if w == 2:
        return f
    need(f in ('WA', 'BC', 'DE', 'HL', 'IZ'))
    return {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L', 'IZ': 'QIZH'}[f]


# --------------------------------------------------------------------------------------------- classification

def tletter(ty):
    if ty is None or ty.kind != 'int' or not ty.signed:
        return None
    return {1: 'c', 2: 'i', 4: 'l'}.get(ty.size)


class Op:
    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s)' % self.k


def gname(d):
    return '_' + d.name


def memtext(sym, off):
    return sym if off == 0 else '%s + %s' % (sym, hx(off))


def gptr(n, t):
    """a load of a global pointer to a T (t letter) or to a struct (t None) -> decl"""
    n = cg.strip(n)
    need(n.k == 'load')
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and v.decl.ty is not None and v.decl.ty.kind == 'ptr')
    b = v.decl.ty.base
    need(b is not None and (b.kind == 'struct' if t is None else tletter(b) == t))
    return v.decl


def operand(n, prm, t, xr):
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:   # char / int promotions
        n = cg.strip(n.e)
    if n.k == 'const':
        need(n.value == 7)
        return Op('K', val=7, syms=[])
    need(tletter(n.ty) == t)
    if n.k == 'call':
        fn = cg.strip(n.fn)
        need(fn.k == 'var' and fn.decl.kind == 'func' and not n.args)
        sp = getattr(fn.decl.ty, 'spell', '') or ''
        need(re.match(r'(char|int|long) \(void\)( |$)', sp) is not None)
        return Op('F', fn=('.' if xr else '_') + fn.decl.name, syms=[fn.decl])
    need(n.k == 'load')
    x = cg.strip(n.e)
    if x.k == 'var':
        d = x.decl
        need(d.kind == 'global' and tletter(d.ty) == t)
        return Op('G', mem='(%s)' % gname(d), syms=[d])
    if x.k == 'member':
        need(x.arrow)
        off = cg.member_offset(x)
        p = gptr(x.base, None)
        return Op('D', ptr=gname(p), off=off, syms=[p])
    if x.k == 'deref':
        p = gptr(x.e, t)
        return Op('P', ptr=gname(p), off=0, syms=[p])
    if x.k == 'index':
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array')
        need(tletter(b.decl.ty.base) == t)
        i = cg.strip(x.idx)
        if i.k == 'const':
            need(i.value is not None and i.value > 0)
            return Op('E', mem='(%s)' % memtext(gname(b.decl), WIDTH[t] * i.value), syms=[b.decl])
        need(i.k == 'load' and tletter(i.ty) == 'i')
        v = cg.strip(i.e)
        need(v.k == 'var' and v.decl is prm)
        return Op('X', arr=gname(b.decl), syms=[b.decl])
    raise Decline()


OPS = {'+': '+', '-': '-', '&': '&', '|': '|', '^': '^', '*': '*', '/': '/', '%': '%'}


def classify(f, xr):
    """-> (t, target, op, L, R)"""
    need(f.ret is not None and f.ret.kind == 'void')
    need(len(f.params) == 1 and tletter(f.params[0].ty) == 'i')
    prm = f.params[0]
    st = cg.flat(f.body)
    need(len(st) == 1 and st[0].k == 'expr')
    e = cg.strip(st[0].e)
    need(e.k == 'bin' and e.op == '=')
    tv = cg.strip(e.l)
    need(tv.k == 'var' and tv.decl.kind == 'global')
    t = tletter(tv.decl.ty)
    need(t is not None)
    x = cg.strip(e.r)
    while x.k == 'cast' and x.kind == 'IntegralCast' and not x.explicit:  # (char) of the int operation
        x = cg.strip(x.e)
    need(x.k == 'bin' and x.op in OPS)
    xt = tletter(x.ty)
    need(xt == ('i' if t == 'c' else t))
    L, Rr = operand(x.l, prm, t, xr), operand(x.r, prm, t, xr)
    ids = [id(d) for d in L.syms] + [id(d) for d in Rr.syms]
    need(len(set(ids)) == len(ids))
    need(id(tv.decl) not in ids)
    return t, gname(tv.decl), x.op, L, Rr


# --------------------------------------------------------------------------------------------- the allocator

class Alloc:
    """registers held over intervals [a, b) of the evaluation order: 0 the calls, 1 / 2 the left / right
    operand's address, 4 the accumulator's load, 5 the operator, 6 the store"""

    def __init__(self):
        self.iv = {f: [] for f in FAMS + ('IZ',)}

    def free(self, f, a, b):
        return all(not (x < b and a < y) for x, y, _ in self.iv[f])

    def take(self, f, a, b, tag):
        self.iv[f].append((a, b, tag))
        return f

    def pick(self, a, b, tag, avoid=(), fams=FAMS):
        for f in fams:
            if f not in avoid and self.free(f, a, b):
                return self.take(f, a, b, tag)
        raise Decline()


class Fn:
    def __init__(self, s, t, tgt, op, L, Rr):
        self.s, self.opt, self.xr = s, s.startswith('O3'), s.endswith('Xr')
        self.t, self.w, self.tgt, self.op, self.L, self.R = t, WIDTH[t], tgt, op, L, Rr
        self.out = []
        self.tail = []
        self.pre = []

    def e(self, *ls):
        self.out.extend(ls)

    def param(self):
        return '(XSP+0x4)'

    def imm(self, r, v):
        return '%s %s,%s' % ('lda' if self.opt and 8 <= v < 0x10000 else 'ld', r, hx(v))


def acc_src(F):
    """the accumulator and the source of the operation"""
    L, Rr, op = F.L, F.R, F.op
    if op not in COMM:
        return L, Rr
    kl, kr = L.k, Rr.k
    if kl == 'F' and kr == 'F':
        return L, Rr
    if kl == 'F':
        return (L, Rr) if kr in 'KG' else (Rr, L)
    if kr == 'F':
        return (Rr, L) if kl in 'KG' else (L, Rr)
    if kr == 'K':
        return L, Rr
    if kl == 'K':
        return Rr, L
    if kl == 'G':
        return L, Rr
    if kr == 'G':
        return L, Rr
    return Rr, L                                                        # both addressed: the right


def calls(F, A):
    """the calls first (the right one first); -> {id(op): register family holding its value}"""
    L, Rr = F.L, F.R
    fs = [o for o in (Rr, L) if o.k == 'F']
    held = {}
    if not fs:
        return held
    xs = [o for o in (L, Rr) if o.k == 'X']
    w = F.w
    iz = {1: 'QIZ', 2: 'IZ', 4: 'XIZ'}[w]
    if len(fs) == 2:
        F.pre += ['push %s' % iz]
        F.tail += ['pop %s' % iz]
        F.e('cal %s' % fs[0].fn, 'ld %s,%s' % (R('IZ', w), R('HL', w)), 'cal %s' % fs[1].fn)
        held[id(fs[0])] = 'IZ'
        held[id(fs[1])] = 'HL'
        A.take('IZ', 0, 6, 'call')
        A.take('HL', 0, 6, 'call')
        return held
    if xs and F.xr:                                                      # c kept in IZ across the call
        F.pre += ['push IZ', 'ld IZ,WA']
        F.tail += ['pop IZ']
        F.cz = True
    F.e('cal %s' % fs[0].fn)
    held[id(fs[0])] = 'HL'
    A.take('HL', 0, 6, 'call')
    return held


def xx_opt(F, acc, src, res):
    """-O, two elements at c: one index for both (the accumulator's base in the result register)"""
    L, Rr, w = F.L, F.R, F.w
    others = [f for f in FAMS if f != res]
    if F.t == 'c':
        ob, i = others[0], others[1]
        base = {id(acc): res, id(src): ob}
        F.e('lda X%s,%s' % (base[id(L)], L.arr), 'ld %s,%s' % (i, F.param()), 'lda X%s,%s' % (base[id(Rr)], Rr.arr))
    else:
        i, ob = others[0], others[1]
        base = {id(acc): res, id(src): ob}
        if F.xr:
            F.e('ld %s,WA' % i)
        else:
            F.e('ld %s,%s' % (i, F.param()))
        F.e('add %s,%s' % (i, i) if w == 2 else 'sla 0x2,%s' % i, 'lda X%s,%s' % (base[id(L)], L.arr),
            'lda X%s,%s' % (base[id(Rr)], Rr.arr))
    return {id(o): '(X%s+%s)' % (base[id(o)], i) for o in (L, Rr)}


def solve_alu(F):
    A = Alloc()
    F.cz = False
    held = calls(F, A)
    acc, src = acc_src(F)
    if F.L.k == 'X' and F.R.k == 'X' and F.opt and not (F.t == 'c' and F.xr):
        text = xx_opt(F, acc, src, 'WA')
        return alu_op(F, acc, src, text, 'WA')
    L, Rr, w = F.L, F.R, F.w
    pos = {id(L): 1, id(Rr): 2}

    def use(o):
        return 4 if o is acc else 5

    xs = [o for o in (L, Rr) if o.k == 'X']
    char = F.t == 'c'
    # 0. fixed
    if F.xr and xs and not F.cz:
        last = max((use(o) if char else pos[id(o)]) for o in xs)
        A.take('WA', 0, last, 'c')
    reg = {}
    md = F.op in '*/%'
    if md and src.k == 'D' and src.off != 0:                           # mul / div: p->m pointers first, textual
        for o in (L, Rr):
            if o.k == 'D' and o.off != 0:
                reg[(id(o), 'ptr')] = A.pick(pos[id(o)], use(o), 'dsrc')
    res = None
    if acc.k != 'F' or md:
        res = A.pick(4, 6, 'result')                                    # WA unless c still holds it
    F.res_hl = md and acc.k == 'F' and F.opt                          # -O: the call's HL is the accumulator
    if char and not F.xr:
        for o in xs:
            A.take('WA', pos[id(o)], pos[id(o)] + 0.3, 'xbase')

    def slots(o):
        p = pos[id(o)]
        if o.k in 'PD':
            return [('ptr', p, use(o))]
        if o.k == 'X':
            if char and not F.xr and not F.cz:
                return [('idx', p, use(o))]
            if char:
                return [('base', p, use(o))]
            return [('idx', p, use(o)), ('base', p, use(o))]
        return []

    def assign(o, sl, a, b, avoid=()):
        if (id(o), sl) not in reg:
            reg[(id(o), sl)] = A.pick(a, b, sl, avoid)

    # 2. the accumulator's own address in WA
    if acc.k in 'PDX':
        for sl, a, b in slots(acc):
            if sl in ('ptr', 'idx', 'base'):
                if res and A.free(res, a, b):
                    reg[(id(acc), sl)] = A.take(res, a, b, 'self')
                elif F.t == 'c' and F.xr:
                    reg[(id(acc), sl)] = A.pick(a, b, 'self')
                break
    # 2b. p->m at a nonzero offset beside an element
    if xs:
        for o in (Rr, L):
            if o.k == 'D' and o.off != 0:
                for sl, a, b in slots(o):
                    assign(o, sl, a, b)
    # 3. indexes, right first
    if not char:
        for o in (Rr, L):
            if o.k == 'X':
                for sl, a, b in slots(o):
                    assign(o, sl, a, b)
    # 4. the right operand, then the left
    for o in (Rr, L):
        for sl, a, b in slots(o):
            assign(o, sl, a, b)
    # ---- emission: addresses in textual order
    text = {}
    F.xx_shared = None
    if len(xs) == 2 and F.w == 2 and not F.xr and not F.cz:          # int, cdecl: c read once, into the right index
        ri, li = reg[(id(Rr), 'idx')], reg[(id(L), 'idx')]
        F.e('ld %s,%s' % (ri, F.param()), 'ld %s,%s' % (li, ri))
        F.xx_shared = ri
    for o in (L, Rr):
        if o.k in 'PD':
            p = reg[(id(o), 'ptr')]
            F.e('ld X%s,(%s)' % (p, o.ptr))
            text[id(o)] = '(X%s)' % p if o.off == 0 else '(X%s+%s)' % (p, hx(o.off))
        elif o.k == 'X':
            text[id(o)] = elem(F, o, reg)
        elif o.k in 'GE':
            text[id(o)] = o.mem
        elif o.k == 'K':
            text[id(o)] = hx(o.val)
        elif o.k == 'F':
            text[id(o)] = R(held[id(o)], w)
    if F.res_hl or (acc.k == 'F' and not md):
        res = held[id(acc)]
    elif acc.k == 'F':
        F.e('ld %s,%s' % (R(res, w), R('HL', w)))
        text[id(acc)] = R(res, w)
    return alu_op(F, acc, src, text, res)


def alu_op(F, acc, src, text, res):
    w = F.w
    if F.op in '*/%':
        return md_op(F, acc, src, text, res)
    r = R(res, w)
    if acc.k != 'F':
        F.e('ld %s,%s' % (r, text[id(acc)]))
    s = text[id(src)]
    if src.k == 'K' and F.op in '+-' and 1 <= src.val <= 8:
        F.e('%s %s,%s' % ('inc' if F.op == '+' else 'dec', hx(src.val), r))
    else:
        F.e('%s %s,%s' % (ALU[F.op], r, s))
    return r


HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}


def md_op(F, acc, src, text, res):
    """* / % on char or int: muls / divs into the result family; -> the register stored"""
    s = text[id(src)]
    a = text[id(acc)]
    if F.t == 'c':
        r16, r8 = res, R(res, 1)
        if F.op == '*':
            if a != r8:
                F.e('ld %s,%s' % (r8, a))
            F.e('muls %s,%s' % (r16, s))
            return r8
        if acc.k == 'K':
            F.e('ld %s,%s' % (r16, a))
        else:
            if a != r8:
                F.e('ld %s,%s' % (r8, a))
            F.e('exts %s' % r16)
        F.e('divs %s,%s' % (r16, s))
        return r8 if F.op == '/' else HIGH[res]
    r16 = res
    if F.op == '*':
        if a != r16:
            F.e('ld %s,%s' % (r16, a))
        F.e('muls X%s,%s' % (r16, s))
        return r16
    if acc.k == 'K':
        F.e('ld X%s,%s' % (r16, a))
    else:
        if a != r16:
            F.e('ld %s,%s' % (r16, a))
        F.e('exts X%s' % r16)
    F.e('divs X%s,%s' % (r16, s))
    if F.op == '%':
        F.e('ld WA,Q%s' % r16)
        return 'WA'
    return r16


def elem(F, o, reg):
    """the element's address code; -> its memory operand"""
    w = F.w
    if F.t == 'c':
        if F.xr or F.cz:
            b = reg[(id(o), 'base')]
            F.e('lda X%s,%s' % (b, o.arr))
            return '(X%s+%s)' % (b, 'IZ' if F.cz else 'WA')
        i = reg[(id(o), 'idx')]
        F.e('lda XWA,%s' % o.arr, 'ld %s,%s' % (i, F.param()), 'extz X%s' % i, 'add X%s,XWA' % i)
        return '(X%s)' % i
    i, b = reg[(id(o), 'idx')], reg[(id(o), 'base')]
    if F.xx_shared:
        pass
    elif F.cz:
        F.e('ld %s,IZ' % i)
    elif F.xr:
        if i != 'WA':
            F.e('ld %s,WA' % i)
    else:
        F.e('ld %s,%s' % (i, F.param()))
    F.e('add %s,%s' % (i, i) if w == 2 else 'sla 0x2,%s' % i, 'lda X%s,%s' % (b, o.arr))
    return '(X%s+%s)' % (b, i)


# --------------------------------------------------------------------------------------------- whole function

def hoist(F):
    """O3XSXr: an index's copy of c goes first (evorder_st_ast.py's rule)"""
    if F.s != 'O3XSXr':
        return
    body = F.out
    for k, l in enumerate(body):
        if re.match(r'ld (BC|DE|HL),WA$', l) and k > 0 and not any(re.search(r'\bWA\b|\bA\b', x) for x in body[:k]):
            body.insert(0, body.pop(k))
            break


LHELP = {'*': 'C9H_mulls', '/': 'C9H_divls', '%': 'C9H_remls'}


def lh_op(o):
    """one of our operands as an evlhw operand"""
    if o.k == 'K':
        return evlhw.Op('K', val=o.val, syms=[])
    if o.k == 'G':
        return evlhw.Op('G', sym=o.mem[1:-1], syms=[])
    if o.k == 'E':
        return evlhw.Op('E', m=o.mem[1:-1], syms=[])
    if o.k == 'P':
        return evlhw.Op('P', ptr=o.ptr, syms=[])
    if o.k == 'D':
        need(o.off > 0)
        return evlhw.Op('D', ptr=o.ptr, off=o.off, syms=[])
    if o.k == 'X':
        return evlhw.Op('X', arr=o.arr, syms=[])
    raise Decline()


def long_value(F, o, v):
    """one long operand alone into X<v> (the multiply by 7)"""
    if o.k in 'GE':
        return ['ld X%s,%s' % (v, o.mem)]
    if o.k == 'P':
        return ['ld XWA,(%s)' % o.ptr, 'ld X%s,(XWA)' % v]
    if o.k == 'D':
        return ['ld XWA,(%s)' % o.ptr, 'ld X%s,(XWA+%s)' % (v, hx(o.off))]
    if o.k == 'X':
        return ([] if F.xr else ['ld WA,%s' % F.param()]) + ['sla 0x2,WA', 'lda X%s,%s' % (v, o.arr),
                                                              'ld X%s,(X%s+WA)' % (v, v)]
    raise Decline()


def solve_long(F):
    """long * / %: -> lines up to the end (store, epilogue, ret)"""
    L, Rr, op, tgt = F.L, F.R, F.op, F.tgt
    store = 'ld (%s),XHL' % tgt
    if 'F' in (L.k, Rr.k):
        return long_calls(F)
    if op == '*' and 'K' in (L.k, Rr.k):                               # x * 7 = (x << 3) - x, into XWA
        o = Rr if L.k == 'K' else L
        return long_value(F, o, 'BC') + ['ld XWA,XBC', 'sla 0x3,XWA', 'sub XWA,XBC', 'ld (%s),XWA' % tgt, 'ret']
    G = evlhw.Frame(F.s)
    A, B = lh_op(L), lh_op(Rr)
    a_first = True
    if op == '*' and A.k in evlhw.ADDRD and B.k in evlhw.ADDRD:
        A, B, a_first = B, A, False
    if 'X' in (A.k, B.k):
        body, tail = evlhw.with_x(G, A, B, a_first)
    else:
        body, tail = evlhw.general(G, A, B, a_first)
    return body + ['cal %s' % LHELP[op], store] + tail + ['ret']


def long_calls(F):
    """long * / % with a call operand"""
    L, Rr, op, tgt = F.L, F.R, F.op, F.tgt
    store = 'ld (%s),XHL' % tgt
    hcall = ['cal %s' % LHELP[op], store]
    if L.k == 'F' and Rr.k == 'F':
        return ['push XIZ', 'cal %s' % Rr.fn, 'ld XIZ,XHL', 'cal %s' % L.fn, 'ld XWA,XHL', 'ld XBC,XIZ'] + hcall + \
            ['pop XIZ', 'ret']
    Fo, Q = (L, Rr) if L.k == 'F' else (Rr, L)
    if op == '*' and Q.k == 'K':
        return ['cal %s' % Fo.fn, 'ld XWA,XHL', 'sla 0x3,XWA', 'sub XWA,XHL', 'ld (%s),XWA' % tgt, 'ret']
    if op == '*':                                                      # the call is the accumulator beside K G only
        A, B = (Fo, Q) if Q.k in 'KG' else (Q, Fo)
    else:
        A, B = L, Rr
    tf = 'WA' if A is Fo else 'BC'
    tq = 'BC' if tf == 'WA' else 'WA'
    call = ['cal %s' % Fo.fn]
    if Q.k in 'KE' or (Q.k == 'G' and F.opt):                          # the result moved straight into its argument
        ql = F.imm('X' + tq, Q.val) if Q.k == 'K' else 'ld X%s,%s' % (tq, Q.mem)
        return call + ['ld X%s,XHL' % tf, ql] + hcall + ['ret']
    if Q.k in 'GP':                                                    # kept in XIZ
        fl = 'ld X%s,XIZ' % tf
        if Q.k == 'G':
            body = ['ld X%s,%s' % (tq, Q.mem), fl]
        elif tq == 'WA':
            body = ['ld XWA,(%s)' % Q.ptr, 'ld XWA,(XWA)', fl]
        else:
            body = ['ld XBC,(%s)' % Q.ptr, fl, 'ld XBC,(XBC)']
        return ['push XIZ'] + call + ['ld XIZ,XHL'] + body + hcall + ['pop XIZ', 'ret']
    fl = 'ld X%s,(XSP+0x4)' % tf                                       # kept in a frame slot (XIZ is the base)
    if Q.k == 'D':
        ql = 'ld X%s,(XIZ+%s)' % (tq, hx(Q.off))
        body = ['ld XIZ,(%s)' % Q.ptr] + ([ql, fl] if tq == 'WA' else [fl, ql])
        return ['dec 0x4,XSP', 'push XIZ'] + call + ['ld (XSP+0x4),XHL'] + body + hcall + \
            ['pop XIZ', 'inc 0x4,XSP', 'ret']
    need(Q.k == 'X')
    n = 8 if F.xr else 6
    pre = ['dec %s,XSP' % hx(n), 'push XIZ'] + (['ld (XSP+0xa),WA'] if F.xr else [])
    src = '(XSP+0xa)' if F.xr else '(XSP+0xe)'
    body = ['ld WA,%s' % src, 'ld (XSP+0x8),WA', 'ld WA,(XSP+0x8)', 'sla 0x2,WA', 'ld (XSP+0x8),WA',
            'lda XIZ,%s' % Q.arr]
    if tq == 'WA':
        body += ['ld WA,(XSP+0x8)', 'ld XWA,(XIZ+WA)', fl]
    else:
        body += ['ld BC,(XSP+0x8)', fl, 'ld XBC,(XIZ+BC)']
    return pre + call + ['ld (XSP+0x4),XHL'] + body + hcall + ['pop XIZ', 'inc %s,XSP' % hx(n), 'ret']


def whole_(f, s):
    xr = s.endswith('Xr')
    t, tgt, op, L, Rr = classify(f, xr)
    F = Fn(s, t, tgt, op, L, Rr)
    need(not (L.k == 'K' and Rr.k == 'K'))
    if t == 'l' and op in '*/%':
        return solve_long(F)
    r = solve_alu(F)
    hoist(F)
    return F.pre + F.out + ['ld (%s),%s' % (tgt, r)] + F.tail + ['ret']


def fmt(lines):
    out = []
    for l in lines:
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return fmt(whole_(f, set))
    except Decline:
        return None
    except Exception:                                                  # (an AST shape the classifier did not foresee)
        if os.environ.get('EVAD_DEBUG'):
            raise
        return None


# --------------------------------------------------------------------------------------------- check

ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-17-micro-evorder_ad/out/v423/%s/probes/evorder_ad.asm'
PROBE = 'corpus/probes/evorder_ad.c'               # --check runs from scripts/analysis/cc900, as score.py does


def check(s, show=0, only=None, src=PROBE, rename=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(src, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        if rename:
            W = [rename(l) for l in W]
        got = whole(f, s)
        fam = f.name[:8]
        fs = fams.setdefault(fam, [0, 0, 0])
        if got is None:
            dec += 1
            fs[2] += 1
            continue
        if listing.normalise_labels(got) == listing.normalise_labels(W):
            ok += 1
            fs[0] += 1
        else:
            wrong += 1
            fs[1] += 1
            if shown < show:
                shown += 1
                print('---- %s %s' % (s, f.name))
                for k in range(max(len(W), len(got))):
                    print('  %-36s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d   %s' % (s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        src = a[a.index('--src') + 1] if '--src' in a else PROBE
        rename = None
        if '--map' in a:
            pairs = [p.split('=') for p in a[a.index('--map') + 1].split(',')]
            rx = re.compile(r'\b(%s)\b' % '|'.join(re.escape(o) for o, _ in pairs))
            mp = dict(pairs)
            rename = lambda l: rx.sub(lambda m: mp[m.group(1)], l)  # noqa: E731
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, src, rename)
