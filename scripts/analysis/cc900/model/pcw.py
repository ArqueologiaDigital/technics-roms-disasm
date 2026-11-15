#!/usr/bin/env python3
"""pc_ast.py -- the cc900 oracle's code for probe pc.c (corpus/probes/pc.c, oracle run 2026-11-13-15-micro-pc): one
parameter c (int, unsigned int or char) read one to four times as a value, an array index, a divisor or a tested
value, at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None      set: none O3XS Xr O3XSXr
    python3 pc_ast.py --check [SET ...] [--show N] [--only REGEX]

The statement is matched to one of the probe's sixteen shapes (from the tree, with the real symbols).  Whether c is
kept in a register (its home) or read from the stack each time, and the other structural choices, are rules (see
`home_rule`, pc in loc0-FAMILIES.md); the registers of the temporaries are the fitted table PC_ROLES, keyed by shape
and type."""
HOME_ = __import__('os').path.expanduser('~/')
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def tl(ty):
    if ty is None or ty.kind != 'int':
        return None
    return {(1, True): 'c', (2, True): 'i', (2, False): 'u'}.get((ty.size, ty.signed))


W = {'c': 1, 'i': 2, 'u': 2}
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}


def rw(p, w):
    if w == 1:
        need(p in LOW)
        return LOW[p]
    return p if w == 2 else 'X' + p


def hx(v):
    return '0x%x' % v


# --------------------------------------------------------------------------------------------- shapes from the AST

def unc(n):
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    return n


class Shape:
    pass


def classify(f):
    """the statement as one of the probe's shapes -> (shape letter, info); the letters are the probe's forms:
    a g = c; b g = A[c]; c g = c + c; d g = A[c] + c; e g = A[c] / c; f A[c] = B[c]; g A[c] = c; h g = c * c + c;
    i A[c] = B[c] + c; j g = A[c] + B[c] + c; k g = c != 0 ? A[c] : c; l if (c != 0) g = A[c] / c; m A[c] = B[c] / c;
    n g = A[c] + B[c] + A[c] + c; o if (c != 0) A[c] = B[c] % c; p g = c + c + c + c"""
    need(len(f.params) == 1 and f.ret is not None and f.ret.kind == 'void')
    c = f.params[0]
    t = tl(c.ty)
    need(t is not None)
    st = cg.flat(f.body)
    need(len(st) == 1)
    s = st[0]
    arrays = []

    def is_c(n):
        n = unc(n)
        return n.k == 'load' and cg.strip(n.e).k == 'var' and cg.strip(n.e).decl is c

    def elem(n):
        """A[c] with A a global array of t -> its symbol"""
        n = unc(n)
        if n.k != 'load':
            return None
        x = cg.strip(n.e)
        if x.k != 'index' or tl(x.ty) != t or not is_c(x.idx):
            return None
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            return '_' + b.decl.name
        return None

    def glob(n):
        n = cg.strip(n)
        if n.k == 'var' and n.decl.kind == 'global' and tl(n.ty) == t:
            return '_' + n.decl.name
        return None

    def bin_(n, op):
        n = unc(n)
        if n.k == 'cast' and n.explicit:
            return None
        if n.k == 'bin' and n.op == op:
            return unc(n.l), unc(n.r)
        return None

    def expr(n):
        """the right-hand side -> (form, arrays)"""
        if is_c(n):
            return 'a', []
        a = elem(n)
        if a:
            return 'b', [a]
        for op, form in (('+', None), ('/', 'e'), ('*', None), ('%', 'o')):
            p = bin_(n, op)
            if p is None:
                continue
            l, r = p
            if op == '+':
                if is_c(l) and is_c(r):
                    return 'c', []
                if elem(l) and is_c(r):
                    return 'd', [elem(l)]
                q = bin_(l, '+')
                if q and is_c(r):
                    if elem(q[0]) and elem(q[1]):
                        return 'j', [elem(q[0]), elem(q[1])]
                    w = bin_(q[0], '+')
                    if w and elem(w[0]) and elem(w[1]) and elem(q[1]) == elem(w[0]) and elem(w[1]) != elem(w[0]):
                        return 'n', [elem(w[0]), elem(w[1])]
                    if w and is_c(w[0]) and is_c(w[1]) and is_c(q[1]):
                        return 'p', []
                    m = bin_(q[0], '*') if False else None
                m = bin_(l, '*')
                if m and is_c(m[0]) and is_c(m[1]) and is_c(r):
                    return 'h', []
                return None, []
            if op in ('/', '%') and elem(l) and is_c(r):
                return form, [elem(l)]
        return None, []

    def assign(n):
        """`g = E` / `A[c] = E` -> (form, dest global or None, arrays)"""
        e = cg.strip(n)
        need(e.k == 'bin' and e.op == '=' and tl(e.ty) == t)
        g = glob(e.l)
        if g:
            form, arrs = expr(e.r)
            need(form in ('a', 'b', 'c', 'd', 'e', 'h', 'j', 'n', 'p'))
            return form, g, arrs
        x = cg.strip(e.l)
        need(x.k == 'index' and is_c(x.idx))
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and tl(x.ty) == t)
        dst = '_' + b.decl.name
        if is_c(e.r):
            return 'g', None, [dst]
        form, arrs = expr(e.r)
        need(form in ('b', 'd', 'e', 'o') and arrs[0] != dst)
        return {'b': 'f', 'd': 'i', 'e': 'm', 'o': 'o'}[form], None, [dst] + arrs

    def nonzero(n):
        n = unc(n)
        return n.k == 'bin' and n.op == '!=' and is_c(n.l) and cg.fold(unc(n.r)).k == 'const' and \
            cg.fold(unc(n.r)).value == 0

    if s.k == 'if' and s.els is None and nonzero(s.cond):
        th = cg.flat(s.then)
        need(len(th) == 1 and th[0].k == 'expr')
        form, g, arrs = assign(th[0].e)
        need(form in ('e', 'o'))
        return ('l' if form == 'e' else 'o'), t, g, arrs
    need(s.k == 'expr')
    e = cg.strip(s.e)
    if e.k == 'bin' and e.op == '=' and unc(e.r).k == 'cond':
        cnd = unc(e.r)
        g = glob(e.l)
        need(g is not None and nonzero(cnd.c) and elem(cnd.a) and is_c(cnd.b))
        return 'k', t, g, [elem(cnd.a)]
    form, g, arrs = assign(e)
    need(form != 'o' and form is not None)
    return form, t, g, arrs


# --------------------------------------------------------------------------------------------- code

def copy(dst, src, w):
    return [] if dst == src else ['ld %s,%s' % (rw(dst, w), rw(src, w))]


class Gen:
    """the code of one shape; R: the roles (registers of the temporaries, fitted per shape and type)"""

    def __init__(self, F, t, R):
        self.F, self.t, self.R, self.w = F, t, R, W[t]
        self.out = []

    def e(self, *lines):
        self.out.extend(lines)

    def elem(self, h, arr, n):
        """the element arr[c] with c in register h -> its address operand"""
        R, t = self.R, self.t
        i, b = R['i%d' % n], R['b%d' % n]
        if t == 'c':
            self.e('lda X%s,%s' % (b, arr))
            return '(X%s+%s)' % (b, rw(h, 1))
        self.e(*copy(i, h, 2))
        if t == 'i':
            self.e('add %s,%s' % (i, i), 'lda X%s,%s' % (b, arr))
            return '(X%s+%s)' % (b, i)
        self.e('extz X%s' % i, 'add X%s,X%s' % (i, i), 'ld X%s,%s' % (b, arr), 'add X%s,X%s' % (b, i))
        return '(X%s)' % b

    def elem_mem(self, P, arr, n):
        """the element arr[c] with c read from the stack"""
        R, t = self.R, self.t
        i, b = R['i%d' % n], R['b%d' % n]
        if t == 'c':                                      # a 32-bit sum (cmpx's byte-array rule)
            if self.F.opt or i == 'WA':
                self.e('lda X%s,%s' % (b, arr), 'ld X%s,0x0' % i, 'ld %s,%s' % (rw(i, 1), P), 'add X%s,X%s' % (i, b))
            else:
                self.e('lda X%s,%s' % (b, arr), 'ld A,%s' % P, 'ld X%s,0x0' % i, 'ld %s,A' % rw(i, 1),
                       'add X%s,X%s' % (i, b))
            return '(X%s)' % i
        self.e('ld %s,%s' % (i, P))
        return self.elem(i, arr, n)

    def elem2(self, h, a1, a2):
        """-O: two arrays at the same index, the scaled index built once"""
        R, t = self.R, self.t
        i, b1, b2 = R['i1'], R['b1'], R['b2']
        if t == 'c':
            self.e('lda X%s,%s' % (b1, a1), 'lda X%s,%s' % (b2, a2))
            return '(X%s+%s)' % (b1, rw(h, 1)), '(X%s+%s)' % (b2, rw(h, 1))
        self.e(*copy(i, h, 2))
        if t == 'i':
            self.e('add %s,%s' % (i, i), 'lda X%s,%s' % (b1, a1), 'lda X%s,%s' % (b2, a2))
            return '(X%s+%s)' % (b1, i), '(X%s+%s)' % (b2, i)
        self.e('extz X%s' % i, 'add X%s,X%s' % (i, i), 'ld X%s,%s' % (b1, a1), 'add X%s,X%s' % (b1, i),
               'ld X%s,%s' % (b2, a2), 'add X%s,X%s' % (b2, i))
        return '(X%s)' % b1, '(X%s)' % b2

    def div(self, v, d, rem):
        """v = v / d (or % d): the quotient (remainder) stays in v; -> the register holding the result"""
        t = self.t
        if t == 'c':
            self.e('exts %s' % v, 'divs %s,%s' % (v, d))
            if rem:
                r = self.R['r']
                self.e('ld %s,%s' % (rw(r, 1), HIGH[v]))
                return r
            return v
        self.e('%s X%s' % ('exts' if t == 'i' else 'extz', v), '%s X%s,%s' % ('divs' if t == 'i' else 'div', v, d))
        if rem:
            r = self.R['r']
            self.e('ld %s,Q%s' % (r, v))
            return r
        return v


def reads_of(f):
    """how the statement reads the parameter: (number of reads, whether one of them is an array index)"""
    c = f.params[0]
    n, idx = [0], [False]

    def walk(x, under_index):
        if isinstance(x, list):
            for y in x:
                walk(y, under_index)
            return
        if not hasattr(x, 'k'):
            return
        if x.k == 'var' and x.decl is c:
            n[0] += 1
            idx[0] = idx[0] or under_index
            return
        for k, y in x.__dict__.items():
            if hasattr(y, 'k') or isinstance(y, list):
                walk(y, under_index or (x.k == 'index' and k == 'idx'))
    walk(f.body, False)
    return n[0], idx[0]


def home_rule(reads, t, s):
    """does c get a register of its own (its home), loaded once?  -Xr: always, it arrives in one.  -O3 -XS: when
    it is read twice or more.  Without options: when it is read three times or more, or twice for an int with
    one of the reads an array index (an unsigned index is widened to 32 bits in place, a char index of a byte array
    is a 32-bit sum from the stack: both read the stack again instead)"""
    n, idx = reads
    if s.endswith('Xr'):
        return True
    if s.startswith('O3'):
        return n >= 2
    return n >= 3 or (n == 2 and idx and t == 'i')


def home_slot(form, reads, t, s):
    """where the load of the home goes: -O3 -XS, a char used as a byte-array index with no test first: after the
    first array base (lda XDE,_gca / ld C,(XSP+0x4)); else first"""
    return 1 if s == 'O3XS' and t == 'c' and reads[1] and form not in ('k', 'l', 'o') else 0


class Frame:
    def __init__(self, s):
        self.s, self.xr, self.opt = s, s.endswith('Xr'), s.startswith('O3')


def gen(f, s, R=None):
    form, t, g, arrs = classify(f)
    F = Frame(s)
    if R is None:
        R = roles_for(form, t, s)
    G = Gen(F, t, R)
    globals()['_LAST'] = G
    w = G.w
    P = '(XSP+0x4)'
    reads = reads_of(f)
    reg = home_rule(reads, t, s)                          # c in a register (its home)
    H = 'WA' if F.xr else (R['H'] if reg else None)
    Hw = rw(H, w) if H else None
    cv = Hw if reg else P
    v = R['v'] if form not in ('a', 'g') or not F.xr else None
    vw = rw(v, w) if v else None

    def elemX(arr, n):
        return G.elem(H, arr, n) if reg else G.elem_mem(P, arr, n)

    def store_g(x):
        G.e('ld (%s),%s' % (g, x))

    if form == 'a':
        if F.xr:
            store_g(Hw)
        else:
            G.e('ld %s,%s' % (vw, P))
            store_g(vw)
    elif form in ('b', 'd', 'e', 'l'):
        if form == 'l':
            need(reg)
            G.e('cp %s,0x0' % Hw, 'ret eq')
        addr = elemX(arrs[0], 1)
        G.e('ld %s,%s' % (vw, addr))
        res = v
        if form == 'd':
            G.e('add %s,%s' % (vw, cv))
        elif form in ('e', 'l'):
            res = G.div(v, cv, False)
        store_g(rw(res, w))
        if form == 'l':
            G.e('L1:')
    elif form == 'c':
        if reg:
            G.e(*copy(v, H, w))
            G.e('add %s,%s' % (vw, Hw))
        else:
            G.e('ld %s,%s' % (vw, P), 'add %s,%s' % (vw, P))
        store_g(vw)
    elif form in ('f', 'i', 'm', 'o'):
        if form == 'o':
            need(reg)
            G.e('cp %s,0x0' % Hw, 'ret eq')
        if F.opt:
            need(reg)
            a1, a2 = G.elem2(H, arrs[0], arrs[1])
        else:
            a1 = elemX(arrs[0], 1)
            a2 = elemX(arrs[1], 2)
        G.e('ld %s,%s' % (vw, a2))
        res = v
        if form == 'i':
            G.e('add %s,%s' % (vw, cv))
        elif form in ('m', 'o'):
            res = G.div(v, cv, form == 'o')
        G.e('ld %s,%s' % (a1, rw(res, w)))
        if form == 'o':
            G.e('L1:')
    elif form == 'g':
        a1 = elemX(arrs[0], 1)
        if reg:
            G.e('ld %s,%s' % (a1, Hw))
        else:
            G.e('ld %s,%s' % (vw, P), 'ld %s,%s' % (a1, vw))
    elif form == 'h':
        need(reg)
        G.e(*copy(v, H, w))
        if t == 'c':
            G.e('muls %s,%s' % (v, Hw))
        else:
            G.e('%s X%s,%s' % ('muls' if t == 'i' else 'mul', v, Hw))
        G.e('add %s,%s' % (vw, Hw))
        store_g(vw)
    elif form == 'j':
        if F.opt:
            need(reg)
            a1, a2 = G.elem2(H, arrs[0], arrs[1])
        else:
            a1 = elemX(arrs[0], 1)
            a2 = elemX(arrs[1], 2)
        G.e('ld %s,%s' % (vw, a2), 'add %s,%s' % (vw, a1), 'add %s,%s' % (vw, cv))
        store_g(vw)
    elif form == 'k':
        need(reg)
        G.e('cp %s,0x0' % Hw, 'j eq,L1')
        addr = G.elem(H, arrs[0], 1)
        G.e('ld %s,%s' % (vw, addr))
        if v == H:
            G.e('L2:', 'L1:')
        else:
            G.e('j L2', 'L1:', *copy(v, H, w))
            G.e('L2:')
        store_g(vw)
    elif form == 'n':
        T = R['T']
        Tw = rw(T, w)
        if F.opt:
            need(reg)
            a1, a2 = G.elem2(H, arrs[0], arrs[1])
            G.e('ld %s,%s' % (vw, a1), 'ld %s,%s' % (Tw, a2), 'add %s,%s' % (Tw, vw), 'add %s,%s' % (vw, Tw))
        else:
            a1 = elemX(arrs[0], 1)
            a2 = elemX(arrs[1], 2)
            if w == 1:
                G.e('ld %s,%s' % (vw, a2), 'add %s,%s' % (vw, a1), 'ld %s,%s' % (Tw, vw))
            else:
                G.e('ld %s,%s' % (Tw, a2), 'add %s,%s' % (Tw, a1))
            a3 = elemX(arrs[0], 3)
            G.e('ld %s,%s' % (vw, a3), 'add %s,%s' % (vw, Tw))
        G.e('add %s,%s' % (vw, cv))
        store_g(vw)
    elif form == 'p':
        need(reg)
        G.e(*copy(v, H, w))
        G.e('add %s,%s' % (vw, vw) if w == 2 else 'add %s,%s' % (vw, Hw), 'add %s,%s' % (vw, Hw),
            'add %s,%s' % (vw, Hw))
        store_g(vw)
    else:
        raise Decline()
    out = G.out
    if reg and not F.xr:                                  # c's home is loaded once from the stack
        out.insert(home_slot(form, reads, t, s), 'ld %s,%s' % (Hw, P))
    return out + ['ret']


def roles_for(form, t, s):
    row = PC_ROLES.get('%s/%s/%s' % (s, form, t))
    need(row is not None)
    out = {}
    for kv in row.split():
        k, x = kv.split('=')
        out[k] = int(x) if x.isdigit() else x
    return out


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
        return fmt(gen(f, set))
    except Exception:
        return None


PC_ROLES = {
    'O3XS/a/c': 'v=WA',
    'O3XS/a/i': 'v=WA',
    'O3XS/a/u': 'v=WA',
    'O3XS/b/c': 'b1=BC i1=WA v=WA',
    'O3XS/b/i': 'b1=BC i1=WA v=WA',
    'O3XS/b/u': 'b1=BC i1=WA v=WA',
    'O3XS/c/c': 'H=BC v=WA',
    'O3XS/c/i': 'H=BC v=WA',
    'O3XS/c/u': 'H=BC v=WA',
    'O3XS/d/c': 'H=BC b1=WA i1=WA v=WA',
    'O3XS/d/i': 'H=DE b1=BC i1=WA v=WA',
    'O3XS/d/u': 'H=BC b1=DE i1=WA v=WA',
    'O3XS/e/c': 'H=BC b1=WA i1=WA v=WA',
    'O3XS/e/i': 'H=DE b1=BC i1=WA v=WA',
    'O3XS/e/u': 'H=BC b1=DE i1=WA v=WA',
    'O3XS/f/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'O3XS/f/i': 'H=BC b1=DE b2=WA i1=BC v=WA',
    'O3XS/f/u': 'H=WA b1=DE b2=BC i1=WA v=WA',
    'O3XS/g/c': 'H=BC b1=WA i1=WA v=WA',
    'O3XS/g/i': 'H=DE b1=BC i1=WA v=WA',
    'O3XS/g/u': 'H=DE b1=BC i1=WA v=WA',
    'O3XS/h/c': 'H=BC v=WA',
    'O3XS/h/i': 'H=BC v=WA',
    'O3XS/h/u': 'H=BC v=WA',
    'O3XS/i/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'O3XS/i/i': 'H=HL b1=DE b2=BC i1=WA v=BC',
    'O3XS/i/u': 'H=DE b1=HL b2=BC i1=WA v=WA',
    'O3XS/j/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'O3XS/j/i': 'H=HL b1=DE b2=BC i1=WA v=BC',
    'O3XS/j/u': 'H=BC b1=HL b2=DE i1=WA v=WA',
    'O3XS/k/c': 'H=BC b1=WA i1=WA v=BC',
    'O3XS/k/i': 'H=WA b1=BC i1=WA v=WA',
    'O3XS/k/u': 'H=WA b1=BC i1=WA v=WA',
    'O3XS/l/c': 'H=BC b1=WA i1=WA v=WA',
    'O3XS/l/i': 'H=DE b1=BC i1=WA v=WA',
    'O3XS/l/u': 'H=BC b1=DE i1=WA v=WA',
    'O3XS/m/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'O3XS/m/i': 'H=DE b1=HL b2=WA i1=BC v=WA',
    'O3XS/m/u': 'H=BC b1=HL b2=DE i1=WA v=WA',
    'O3XS/n/c': 'H=DE T=HL b1=WA b2=HL i1=WA v=BC',
    'O3XS/n/i': 'H=DE T=BC b1=WA b2=HL i1=BC v=WA',
    'O3XS/n/u': 'H=DE T=BC b1=WA b2=HL i1=BC v=WA',
    'O3XS/o/c': 'H=BC b1=DE b2=WA i1=WA i2=WA r=WA v=WA',
    'O3XS/o/i': 'H=DE b1=HL b2=WA i1=BC r=WA v=WA',
    'O3XS/o/u': 'H=BC b1=HL b2=DE i1=WA r=WA v=WA',
    'O3XS/p/c': 'H=BC v=WA',
    'O3XS/p/i': 'H=BC v=WA',
    'O3XS/p/u': 'H=BC v=WA',
    'O3XSXr/a/c': '',
    'O3XSXr/a/i': '',
    'O3XSXr/a/u': '',
    'O3XSXr/b/c': 'b1=BC i1=WA v=WA',
    'O3XSXr/b/i': 'b1=BC i1=WA v=WA',
    'O3XSXr/b/u': 'b1=BC i1=WA v=WA',
    'O3XSXr/c/c': 'v=BC',
    'O3XSXr/c/i': 'v=BC',
    'O3XSXr/c/u': 'v=BC',
    'O3XSXr/d/c': 'b1=BC i1=WA v=BC',
    'O3XSXr/d/i': 'b1=DE i1=BC v=BC',
    'O3XSXr/d/u': 'b1=DE i1=BC v=BC',
    'O3XSXr/e/c': 'b1=BC i1=WA v=BC',
    'O3XSXr/e/i': 'b1=DE i1=BC v=BC',
    'O3XSXr/e/u': 'b1=DE i1=BC v=BC',
    'O3XSXr/f/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'O3XSXr/f/i': 'b1=DE b2=WA i1=BC v=WA',
    'O3XSXr/f/u': 'b1=DE b2=BC i1=WA v=WA',
    'O3XSXr/g/c': 'b1=BC i1=WA',
    'O3XSXr/g/i': 'b1=DE i1=BC',
    'O3XSXr/g/u': 'b1=DE i1=BC',
    'O3XSXr/h/c': 'v=BC',
    'O3XSXr/h/i': 'v=BC',
    'O3XSXr/h/u': 'v=BC',
    'O3XSXr/i/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'O3XSXr/i/i': 'b1=HL b2=DE i1=BC v=DE',
    'O3XSXr/i/u': 'b1=HL b2=DE i1=BC v=BC',
    'O3XSXr/j/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'O3XSXr/j/i': 'b1=HL b2=DE i1=BC v=DE',
    'O3XSXr/j/u': 'b1=HL b2=DE i1=BC v=BC',
    'O3XSXr/k/c': 'b1=BC i1=WA v=WA',
    'O3XSXr/k/i': 'b1=BC i1=WA v=WA',
    'O3XSXr/k/u': 'b1=BC i1=WA v=WA',
    'O3XSXr/l/c': 'b1=BC i1=WA v=BC',
    'O3XSXr/l/i': 'b1=DE i1=BC v=BC',
    'O3XSXr/l/u': 'b1=DE i1=BC v=BC',
    'O3XSXr/m/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'O3XSXr/m/i': 'b1=HL b2=BC i1=DE v=BC',
    'O3XSXr/m/u': 'b1=HL b2=DE i1=BC v=BC',
    'O3XSXr/n/c': 'T=HL b1=BC b2=HL i1=WA v=DE',
    'O3XSXr/n/i': 'T=DE b1=BC b2=HL i1=DE v=BC',
    'O3XSXr/n/u': 'T=DE b1=BC b2=HL i1=DE v=BC',
    'O3XSXr/o/c': 'b1=DE b2=BC i1=WA i2=WA r=BC v=BC',
    'O3XSXr/o/i': 'b1=HL b2=BC i1=DE r=WA v=BC',
    'O3XSXr/o/u': 'b1=HL b2=DE i1=BC r=WA v=BC',
    'O3XSXr/p/c': 'v=BC',
    'O3XSXr/p/i': 'v=BC',
    'O3XSXr/p/u': 'v=BC',
    'Xr/a/c': '',
    'Xr/a/i': '',
    'Xr/a/u': '',
    'Xr/b/c': 'b1=BC i1=WA v=WA',
    'Xr/b/i': 'b1=BC i1=WA v=WA',
    'Xr/b/u': 'b1=BC i1=WA v=WA',
    'Xr/c/c': 'v=BC',
    'Xr/c/i': 'v=BC',
    'Xr/c/u': 'v=BC',
    'Xr/d/c': 'b1=BC i1=WA v=BC',
    'Xr/d/i': 'b1=DE i1=BC v=BC',
    'Xr/d/u': 'b1=DE i1=BC v=BC',
    'Xr/e/c': 'b1=BC i1=WA v=BC',
    'Xr/e/i': 'b1=DE i1=BC v=BC',
    'Xr/e/u': 'b1=DE i1=BC v=BC',
    'Xr/f/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'Xr/f/i': 'b1=HL b2=BC i1=DE i2=WA v=WA',
    'Xr/f/u': 'b1=DE b2=BC i1=BC i2=WA v=WA',
    'Xr/g/c': 'b1=BC i1=WA',
    'Xr/g/i': 'b1=DE i1=BC',
    'Xr/g/u': 'b1=DE i1=BC',
    'Xr/h/c': 'v=BC',
    'Xr/h/i': 'v=BC',
    'Xr/h/u': 'v=BC',
    'Xr/i/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'Xr/i/i': 'b1=IX b2=DE i1=HL i2=BC v=BC',
    'Xr/i/u': 'b1=HL b2=DE i1=BC i2=BC v=BC',
    'Xr/j/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'Xr/j/i': 'b1=IX b2=DE i1=HL i2=BC v=BC',
    'Xr/j/u': 'b1=HL b2=DE i1=BC i2=BC v=BC',
    'Xr/k/c': 'b1=BC i1=WA v=WA',
    'Xr/k/i': 'b1=BC i1=WA v=WA',
    'Xr/k/u': 'b1=BC i1=WA v=WA',
    'Xr/l/c': 'b1=BC i1=WA v=BC',
    'Xr/l/i': 'b1=DE i1=BC v=BC',
    'Xr/l/u': 'b1=DE i1=BC v=BC',
    'Xr/m/c': 'b1=DE b2=BC i1=WA i2=WA v=BC',
    'Xr/m/i': 'b1=IX b2=DE i1=HL i2=BC v=BC',
    'Xr/m/u': 'b1=HL b2=DE i1=BC i2=BC v=BC',
    'Xr/n/c': 'T=DE b1=DE b2=BC b3=BC i1=WA i2=WA i3=WA v=BC',
    'Xr/n/i': 'T=IY b1=IX b2=DE b3=DE i1=HL i2=BC i3=BC v=BC',
    'Xr/n/u': 'T=IX b1=HL b2=DE b3=DE i1=BC i2=BC i3=BC v=BC',
    'Xr/o/c': 'b1=DE b2=BC i1=WA i2=WA r=BC v=BC',
    'Xr/o/i': 'b1=IX b2=DE i1=HL i2=BC r=WA v=BC',
    'Xr/o/u': 'b1=HL b2=DE i1=BC i2=BC r=WA v=BC',
    'Xr/p/c': 'v=BC',
    'Xr/p/i': 'v=BC',
    'Xr/p/u': 'v=BC',
    'none/a/c': 'v=WA',
    'none/a/i': 'v=WA',
    'none/a/u': 'v=WA',
    'none/b/c': 'b1=BC i1=WA v=WA',
    'none/b/i': 'b1=BC i1=WA v=WA',
    'none/b/u': 'b1=BC i1=WA v=WA',
    'none/c/c': 'v=WA',
    'none/c/i': 'v=WA',
    'none/c/u': 'v=WA',
    'none/d/c': 'b1=BC i1=WA v=WA',
    'none/d/i': 'H=DE b1=BC i1=WA v=WA',
    'none/d/u': 'b1=BC i1=WA v=WA',
    'none/e/c': 'b1=BC i1=WA v=WA',
    'none/e/i': 'H=DE b1=BC i1=WA v=WA',
    'none/e/u': 'b1=BC i1=WA v=WA',
    'none/f/c': 'b1=BC b2=BC i1=DE i2=WA v=WA',
    'none/f/i': 'H=WA b1=HL b2=BC i1=DE i2=WA v=WA',
    'none/f/u': 'b1=DE b2=BC i1=WA i2=WA v=WA',
    'none/g/c': 'b1=BC i1=DE v=WA',
    'none/g/i': 'H=DE b1=BC i1=WA v=WA',
    'none/g/u': 'b1=BC i1=WA v=WA',
    'none/h/c': 'H=BC v=WA',
    'none/h/i': 'H=BC v=WA',
    'none/h/u': 'H=BC v=WA',
    'none/i/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'none/i/i': 'H=IX b1=HL b2=BC i1=DE i2=WA v=WA',
    'none/i/u': 'H=DE b1=HL b2=BC i1=WA i2=WA v=WA',
    'none/j/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'none/j/i': 'H=HL b1=IX b2=BC i1=DE i2=WA v=WA',
    'none/j/u': 'H=BC b1=HL b2=DE i1=WA i2=WA v=WA',
    'none/k/c': 'H=BC b1=WA i1=WA v=WA',
    'none/k/i': 'H=WA b1=BC i1=WA v=WA',
    'none/k/u': 'H=WA b1=BC i1=WA v=WA',
    'none/l/c': 'H=BC b1=WA i1=WA v=WA',
    'none/l/i': 'H=DE b1=BC i1=WA v=WA',
    'none/l/u': 'H=BC b1=DE i1=WA v=WA',
    'none/m/c': 'H=BC b1=DE b2=WA i1=WA i2=WA v=WA',
    'none/m/i': 'H=HL b1=IX b2=BC i1=DE i2=WA v=WA',
    'none/m/u': 'H=BC b1=HL b2=DE i1=WA i2=WA v=WA',
    'none/n/c': 'H=BC T=DE b1=DE b2=WA b3=WA i1=WA i2=WA i3=WA v=WA',
    'none/n/i': 'H=DE T=IY b1=IX b2=BC b3=BC i1=HL i2=WA i3=WA v=WA',
    'none/n/u': 'H=BC T=IX b1=HL b2=DE b3=DE i1=WA i2=WA i3=WA v=WA',
    'none/o/c': 'H=BC b1=DE b2=WA i1=WA i2=WA r=WA v=WA',
    'none/o/i': 'H=HL b1=IX b2=BC i1=DE i2=WA r=WA v=WA',
    'none/o/u': 'H=BC b1=HL b2=DE i1=WA i2=WA r=WA v=WA',
    'none/p/c': 'H=BC v=WA',
    'none/p/i': 'H=BC v=WA',
    'none/p/u': 'H=BC v=WA',
}

RUN = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-13-15-micro-pc/out/v423/%s/probes/pc.asm'
SRC = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/pc.c'


def check(s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(RUN % s, encoding='latin-1').read())
    unit = frontend.load(SRC, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        W_ = [l for l in want.get(('.' if s.endswith('Xr') else '_') + f.name, []) if 'section' not in l][1:]
        got = whole(f, s)
        if got is None:
            dec += 1
            continue
        if listing.normalise_labels(got) == listing.normalise_labels(W_):
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                print('   want: ' + '; '.join(x.strip().replace('\t', ' ') for x in W_))
                print('   got:  ' + '; '.join(x.strip().replace('\t', ' ') for x in got))
    print('%-7s exact %4d  wrong %4d  declined %4d' % (s, ok, wrong, dec))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        for s_ in [x for x in a[1:] if x in SETS] or list(SETS):
            check(s_, show, only)
