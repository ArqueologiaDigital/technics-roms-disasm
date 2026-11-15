"""elrd_ast.py -- the cc900 oracle's code for the functions of probe elrd.c, at four option sets, from the model's AST.

    whole(f, set) -> the function's listing lines after its label ('\\top\\targs' / '\\top' / 'L1:'), or None
    python3 -B model/elrdw.py --check SET [--probe elrd.c] [--oracle elrd.asm] [--show N]     (the model directory on sys.path)

SET: none, O3XS (cdecl, `_name`), Xr, O3XSXr (register arguments, `.name`).  f is a function of
frontend.load(probe, [], [], adecl=SET in (Xr, O3XSXr)).

How it works (elrd-FAMILIES.md has the rules):
  1. classify(f) reads the AST and names the function's shape with the probe's letters (er_a_iaKs, bc_b_nLMS ...):
     element type, index kind (an int / char / unsigned char / unsigned int parameter, the loop counter, a local
     `T t = gi`), left operand, operator, destination or context.  Every constant must be the probe's, every struct
     member at the probe's offset, and the real objects must stand in the probe's equality pattern (two roles that
     are one object in the probe are one object here, and only then); anything else is declined (None).
  2. The predictor of the set writes the code for that shape with the probe's symbol names: for no options the
     research-scratch templates elrd1/elrd2 (copied); for the other sets virtual instructions over named temporaries
     coloured to register pairs (fixed parameters, preferences, birth order, coalescing of copies) plus the -O
     peepholes (a load forwarded into the register it is copied to, a value computed straight into the register
     it is copied to, loop strength reduction to a walking pointer).
  3. The probe's names are replaced by the real ones (a name the substitution does not know declines).
Local labels come out numbered from L1 in order of appearance, as listing.normalise_labels numbers them; the
oracle numbers them across the file.  Nothing is looked up by function name.
"""
import os
import re
import sys
import collections

import codegen as cg


# ==============================================================================================================
# the classifier: AST -> the probe's name and the real symbols
# ==============================================================================================================
TL = {(1, True): 'c', (1, False): 'u', (2, True): 'i', (2, False): 'w', (4, True): 'l', (4, False): 'n'}
ES = {'c': 1, 'u': 1, 'i': 2, 'w': 2, 'l': 4, 'n': 4}
# struct st of the probe: c ca[8] u ua[8] i ia[8] w wa[8] l la[8] n na[8] (arrays at even offsets)
MOFF = {'c': 0, 'u': 0xa, 'i': 0x14, 'w': 0x26, 'l': 0x38, 'n': 0x5c}
AOFF = {'c': 2, 'u': 0xc, 'i': 0x16, 'w': 0x28, 'l': 0x3c, 'n': 0x60}
PARAM_I = {'c': 'b', 'u': 'c', 'i': 'a', 'w': 'd'}
LOCAL_I = {'c': 'h', 'u': 'g', 'i': 'f', 'w': 'j'}


class No(Exception):
    pass


def need(c):
    if not c:
        raise No()


def tl(ty):
    if ty is None or ty.kind != 'int':
        return None
    return TL.get((ty.size, ty.signed))


def unc(n):
    """strip noops and implicit integral casts"""
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not getattr(n, 'explicit', False):
        n = cg.strip(n.e)
    return n


def const(n):
    n = unc(n)
    if n.k == 'const' and n.value is not None:
        return n.value
    return None


def gvar(n, kind=None):
    """a plain global variable node -> decl"""
    n = cg.strip(n)
    need(n.k == 'var' and n.decl.kind == 'global')
    if kind is not None:
        need(n.decl.ty is not None and n.decl.ty.kind == kind)
    return n.decl


class Ctx:
    def __init__(self, f):
        self.f = f
        self.roles = []          # (canonical symbol, decl)
        self.loopvar = None
        self.local = None        # (decl, I letter)
        self.locsrc = None
        self.q = None            # er_d s3 pointer local
        self.u = None            # er_b / bc_c V local
        self.callee_cdecl = None  # a sink call's callee: declared __cdecl (stack arguments)?
        self.used_index = None   # the parameter kind (a b c d) when a parameter is the index

    def role(self, canon, decl):
        self.roles.append((canon, decl))

    # ---- the element h<t>a[idx] and its index
    def index_kind(self, idx):
        i = unc(idx)
        need(i.k == 'load')
        v = cg.strip(i.e)
        need(v.k == 'var')
        d = v.decl
        if self.loopvar is not None and d is self.loopvar:
            return 'L'
        if self.local is not None and d is self.local[0]:
            return self.local[1]
        need(d.kind == 'param')
        ps = self.f.params
        t = tl(d.ty)
        need(t in PARAM_I)
        if len(ps) == 2:          # er_e R: (T *p, x)
            need(d is ps[1])
        else:
            need(d is ps[0])
        self.used_index = PARAM_I[t]
        return PARAM_I[t]

    def elem(self, n, t=None, base_kinds='A'):
        """n: an rvalue/lvalue index node.  -> (t, base kind, I)"""
        n = unc(n)
        if n.k == 'load':
            n = cg.strip(n.e)
        need(n.k == 'index')
        et = tl(n.ty)
        need(et is not None and (t is None or et == t))
        b = cg.strip(n.base)
        I = self.index_kind(n.idx)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            need('A' in base_kinds)
            need(tl(b.decl.ty.base) == et)
            self.role('_h%sa' % et, b.decl)
            return et, 'A', I
        if b.k == 'member' and not b.arrow:
            need('M' in base_kinds)
            d = gvar(b.base, 'struct')
            need(cg.member_offset(b) == AOFF[et] and b.ty.kind == 'array')
            self.role('_hs', d)
            return et, 'M', I
        if b.k == 'member' and b.arrow:
            need('D' in base_kinds)
            x = cg.strip(b.base)
            need(x.k == 'load')
            d = gvar(x.e, 'ptr')
            need(cg.member_offset(b) == AOFF[et] and b.ty.kind == 'array')
            self.role('_hps', d)
            return et, 'D', I
        if b.k == 'load':
            v = cg.strip(b.e)
            need(v.k == 'var' and v.decl.ty.kind == 'ptr' and tl(v.decl.ty.base) == et)
            if v.decl.kind == 'global':
                need('Q' in base_kinds)
                self.role('_g%sp' % et, v.decl)
                return et, 'Q', I
            if v.decl.kind == 'param':
                need('R' in base_kinds and len(self.f.params) == 2 and v.decl is self.f.params[0])
                return et, 'R', I
            if v.decl is self.q:
                need('q' in base_kinds)
                return et, 'q', I
        raise No()

    def same_elem(self, a, b):
        """two reads of the same element (er_d s1): same array, same index variable"""
        a = unc(a); b = unc(b)
        a = cg.strip(a.e) if a.k == 'load' else a
        b = cg.strip(b.e) if b.k == 'load' else b
        need(a.k == 'index' and b.k == 'index')
        need(cg.strip(a.base).decl is cg.strip(b.base).decl)
        need(cg.strip(unc(a.idx).e).decl is cg.strip(unc(b.idx).e).decl)

    def gload(self, n, canon, t):
        """load of a plain global of type t -> role"""
        n = unc(n)
        need(n.k == 'load')
        d = gvar(n.e)
        need(tl(d.ty) == t)
        self.role(canon, d)

    def kelem(self, n, t, k, canon):
        """load of h<t>a[k] (a constant element of a global array)"""
        n = unc(n)
        need(n.k == 'load')
        x = cg.strip(n.e)
        need(x.k == 'index' and const(x.idx) == k)
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and tl(b.decl.ty.base) == t)
        self.role(canon, b.decl)

    def store_global(self, n, canon, t):
        d = gvar(n)
        need(tl(d.ty) == t)
        self.role(canon, d)


def strip_assign(e):
    e = cg.strip(e)
    need(e.k == 'bin' and e.op == '=')
    return e


def peel(f):
    """the function's frame: locals, a loop, the statement(s) inside.  -> (ctx, inner statements, extra)"""
    c = Ctx(f)
    st = cg.flat(f.body)
    pre, post = [], []
    loop = None
    for i, s in enumerate(st):
        if s.k == 'for':
            loop = s
            pre, post = st[:i], st[i + 1:]
            break
    if loop is None:
        pre, inner, post = [], st, []
    else:
        inner = cg.flat(loop.body)
    decls = []
    body = []
    for s in (pre if loop is not None else inner):
        if s.k == 'decl':
            decls.append(s)
        else:
            body.append(s)
    if loop is None:
        inner = body
    else:
        need(not body)
    return c, decls, loop, inner, post


def check_loop(c, loop, decls):
    need(loop.init is not None and loop.cond is not None and loop.inc is not None)
    ie = strip_assign(loop.init.e)
    lv = cg.strip(ie.l)
    need(lv.k == 'var' and lv.decl.kind == 'local' and const(ie.r) == 0)
    d = lv.decl
    need(tl(d.ty) == 'i')
    cd = cg.strip(loop.cond)
    need(cd.k == 'bin' and cd.op == '<' and const(cd.r) == 4)
    x = unc(cd.l)
    need(x.k == 'load' and cg.strip(x.e).decl is d)
    inc = cg.strip(loop.inc)
    need(inc.k == 'incdec' and inc.op == '++' and cg.strip(inc.e).decl is d)
    c.loopvar = d


# The probe's shapes, letter by letter (elrd.c's header): every family is the full product of its letter sets except
# that a loop never returns (er_b R, bc_c R have no L form).  A name outside this grammar is a shape the probe does
# not contain (another operator with a constant left, a long product, a local index in er_b ...): declined.
GRAMMAR = {
    'er_a': ('cilnuw', 'Labcdfgh', 'CGKZ', 'os'),
    'er_b': ('in', 'Lab', 'ACEGMPQRV', 'DEGN'),
    'er_c': ('cin', 'Lbf', 'CG', 'amopsx'),
    'er_d': ('s', '123', 'cin', 'Labf'),
    'er_k': ('ilnuw', 'cn', 'os', 'Lab'),
    'er_e': ('ci', 'ADMQR', 'Lab', 'GK'),
    'bc_a': ('cilnuw', 'Labcf', 'BGKNS'),
    'bc_b': ('clnu', 'Lab', 'DEMP', 'GKS'),
    'bc_c': ('cilnuw', 'Lab', 'ACKRV'),
}


def in_probe(name):
    p = name.split('_')
    fam = p[0] + '_' + p[1]
    letters = ''.join(p[2:])
    g = GRAMMAR.get(fam)
    if g is None or len(letters) != len(g) or any(ch not in g[i] for i, ch in enumerate(letters)):
        return False
    if fam == 'er_b' and letters[1] == 'L' and letters[2] == 'R':
        return False
    if fam == 'bc_c' and letters[1] == 'L' and letters[2] == 'R':
        return False
    if fam == 'er_k' and letters[0] == 'c':
        return False
    return True


def classify(f):
    try:
        return _classify(f)
    except No:
        return None
    except (AttributeError, IndexError, KeyError, TypeError, ValueError):
        return None


def _classify(f):
    c, decls, loop, inner, post = peel(f)
    ps = f.params
    need(len(ps) in (1, 2))
    if loop is not None:
        check_loop(c, loop, decls)
    # locals other than the loop counter
    others = []
    for s in decls:
        d = s.var
        if d is c.loopvar:
            need(s.init is None)
            continue
        others.append(s)
    for s in others:
        d = s.var
        need(d.kind == 'local')
        if s.init is not None and tl(d.ty) in LOCAL_I and loop is None and c.local is None and \
                unc(s.init).k == 'load' and cg.strip(unc(s.init).e).k == 'var' and \
                tl(cg.strip(unc(s.init).e).decl.ty) == 'i' and \
                any(_uses_index(st, d) for st in inner):
            c.local = (d, LOCAL_I[tl(d.ty)])
            c.role('_gi', gvar(unc(s.init).e))
        elif d.ty.kind == 'ptr' and s.init is not None:
            x = unc(s.init)
            need(x.k == 'load')
            gd = gvar(x.e)
            need(gd.ty.kind == 'ptr' and tl(gd.ty.base) == tl(d.ty.base))
            c.q = d
            c.role('_g%sp' % tl(d.ty.base), gd)
        else:
            need(c.u is None)
            c.u = s
    if len(ps) == 2:
        need(ps[0].ty.kind == 'ptr')
    base = list(c.roles)
    for fam in (fam_er_ak, fam_er_b, fam_bc_c, fam_er_d, fam_bc):
        c.roles = list(base)
        try:
            name = fam(c, f, inner, post, loop)
        except No:
            continue
        # the parameters: (T *p, x) only for a pointer-parameter base; a parameter the body does not use is an int
        # (the probe's), so that the -Xr registers are the probe's
        need(in_probe(name))
        if len(ps) == 2:
            need(name.startswith('er_e_') and name[6] == 'R')
        I = c.used_index
        if I is None or I not in 'abcd':
            need(tl(ps[-1].ty) == 'i')
        return name, c
    raise No()


def _uses_index(s, d):
    """does statement s use local d as an array index somewhere"""
    found = []

    def walk(n):
        if isinstance(n, list):
            for x in n:
                walk(x)
            return
        if not hasattr(n, 'k'):
            return
        if n.k == 'index':
            i = unc(n.idx)
            if i.k == 'load' and cg.strip(i.e).k == 'var' and cg.strip(i.e).decl is d:
                found.append(1)
        for k_, v in n.__dict__.items():
            if k_ in ('decl', 'ty', 'k'):
                continue
            if isinstance(v, list) or hasattr(v, 'k'):
                walk(v)
    walk(s)
    return bool(found)


def one_expr(inner):
    need(len(inner) == 1 and inner[0].k == 'expr')
    return cg.strip(inner[0].e)


# ------------------------------------------------------------------------------------------------- er_a / er_c / er_k
C_OPS = {'+': 'p', '-': 's', '|': 'o', '&': 'a', '^': 'x', '*': 'm'}


def fam_er_ak(c, f, inner, post, loop):
    need(not post and c.u is None and c.q is None)
    e = strip_assign(one_expr(inner))
    dt = tl(cg.strip(e.l).ty)
    need(dt is not None)
    r = unc(e.r)
    need(r.k == 'bin' and r.op in C_OPS)
    o = C_OPS[r.op]
    le, re_ = cg.strip(r.l), cg.strip(r.r)
    # er_k: an explicit cast on both sides, to the destination's type
    def xcast(n):
        n = cg.strip(n)
        while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
            n = cg.strip(n.e)
        if n.k == 'cast' and n.explicit and n.kind == 'IntegralCast':
            return n
        return None
    xl, xr = xcast(le), xcast(re_)
    if xr is not None:
        need(xl is not None or tl(unc(le).ty) == dt)
        R = dt
        need(R in 'cn' and tl(xr.ty) == R)
        need(xl is None or tl(xl.ty) == R)
        t, B, I = c.elem(unc(xr.e))
        need(t != R and B == 'A' and I in 'abL' and o in 'so')
        c.store_global(e.l, '_g%s' % R, R)
        c.gload(xl.e if xl is not None else le, '_h%s' % R, R)
        return 'er_k_%s%s%s%s' % (t, R, o, I)
    if dt == 'n' and o in 'so' and cg.strip(le).k == 'noop' or xl is not None:
        pass
    t, B, I = c.elem(re_, base_kinds='AMDQR')
    need(t == dt)
    c.store_global(e.l, '_g%s' % t, t)
    if B != 'A':
        L = left_kind(c, le, t, 'KG')
        need(o == 's')
        return 'er_e_%s%s%s%s' % (t, B, I, L)
    L = left_kind(c, le, t, 'KGZC')
    fam = 'a' if o in 'so' else 'c'
    return 'er_%s_%s%s%s%s' % (fam, t, I, L, o)


def left_kind(c, n, t, allowed):
    n0 = unc(n)
    k = const(n0)
    if k is not None:
        need('K' in allowed and k == 7)
        return 'K'
    if n0.k == 'bin' and n0.op == '-':
        need('C' in allowed and const(n0.r) == 3)
        c.gload(n0.l, '_h%s' % t, t)
        return 'C'
    x = cg.strip(n0.e) if n0.k == 'load' else None
    need(x is not None)
    if x.k == 'var':
        need('G' in allowed)
        c.gload(n0, '_h%s' % t, t)
        return 'G'
    if x.k == 'index':
        need('Z' in allowed)
        c.kelem(n0, t, 1, '_h%sa' % t)
        return 'Z'
    raise No()


# ------------------------------------------------------------------------------------------------- er_e handled in er_ak
# ------------------------------------------------------------------------------------------------- er_b
def fam_er_b(c, f, inner, post, loop):
    """D <- L - h<t>a[idx]"""
    need(c.q is None)
    st = inner
    D = None
    if c.u is not None:
        # V: a local initialised with the difference (dead), or (loop) u = 0; ... u = ...; gi3 = u
        u = c.u.var
        need(tl(u.ty) in ('i', 'n', 'c', 'u', 'w', 'l'))
        if loop is None:
            need(not st and c.u.init is not None)
            val = c.u.init
        else:
            need(const(c.u.init) == 0 and len(post) == 1 and post[0].k == 'expr')
            pe = strip_assign(post[0].e)
            c.store_global(pe.l, '_gi3', 'i')
            x = unc(pe.r)
            need(x.k == 'load' and cg.strip(x.e).decl is u)
            e = strip_assign(one_expr(st))
            need(cg.strip(e.l).k == 'var' and cg.strip(e.l).decl is u)
            val = e.r
        D = 'V'
    else:
        need(not post)
        need(len(st) == 1)
        s = st[0]
        if s.k == 'return':
            D = 'R'
            val = s.value
        elif s.k == 'if':
            need(s.els is None)
            cd = cg.strip(s.cond)
            need(cd.k == 'bin' and cd.op == '>' and const(cd.r) == 3)
            th = cg.flat(s.then)
            need(len(th) == 1 and th[0].k == 'expr')
            te = strip_assign(th[0].e)
            c.store_global(te.l, '_gi3', 'i')
            need(const(te.r) == 1)
            D = 'C'
            val = cd.l
        else:
            need(s.k == 'expr')
            e = cg.strip(s.e)
            if e.k == 'call':
                fn = cg.strip(e.fn)
                need(fn.k == 'var' and len(e.args) == 1)
                D = 'A'
                val = e.args[0]
                sk = fn.decl
            else:
                e = strip_assign(e)
                val = e.r
                D = ('lv', e.l)
    v = unc(val)
    need(v.k == 'bin' and v.op == '-')
    t, B, I = c.elem(v.r)
    need(B == 'A')
    need(t in 'in')
    if D == 'V':
        need(tl(c.u.var.ty) == t)
    if D == 'A':
        need(sk.ty is not None)
        c.callee_cdecl = bool(getattr(sk.ty, 'cdecl', False))
        need(tl(cg.strip(val).ty) == t)
        c.role('_sk%s' % t, sk)
    if D == 'R':
        need(tl(f.ret) == t)
    if isinstance(D, tuple):
        D = dest_kind(c, D[1], t, 'GEPMQ')
    # left
    l = unc(v.l)
    if l.k == 'un' and l.op == '!':
        c.gload(l.e, '_h%s' % t, t)
        L = 'N'
    elif l.k == 'load' and cg.strip(l.e).k == 'member':
        m = cg.strip(l.e)
        need(m.arrow and cg.member_offset(m) == MOFF[t] and tl(m.ty) == t)
        x = cg.strip(m.base)
        need(x.k == 'load')
        c.role('_hps', gvar(x.e, 'ptr'))
        L = 'D'
    elif l.k == 'load' and cg.strip(l.e).k == 'index':
        c.kelem(l, t, 3, '_h%sa' % t)
        L = 'E'
    else:
        c.gload(l, '_h%s' % t, t)
        L = 'G'
    if D == 'V' and loop is None:
        pass
    return 'er_b_%s%s%s%s' % (t, I, D, L)


def dest_kind(c, n, t, allowed):
    n = cg.strip(n)
    if n.k == 'var':
        need('G' in allowed)
        c.store_global(n, '_g%s' % t, t)
        return 'G'
    if n.k == 'deref':
        need('P' in allowed)
        x = unc(n.e)
        need(x.k == 'load')
        d = gvar(x.e, 'ptr')
        need(tl(d.ty.base) == t)
        c.role('_g%sp' % t, d)
        return 'P'
    if n.k == 'member':
        need(tl(n.ty) == t and cg.member_offset(n) == MOFF[t])
        if n.arrow:
            need('D' in allowed)
            x = cg.strip(n.base)
            need(x.k == 'load')
            c.role('_gps', gvar(x.e, 'ptr'))
            return 'D'
        need('M' in allowed)
        c.role('_gs', gvar(n.base, 'struct'))
        return 'M'
    if n.k == 'index':
        b = cg.strip(n.base)
        if b.k == 'var':
            need('E' in allowed and const(n.idx) == 2)
            need(b.decl.kind == 'global' and b.decl.ty.kind == 'array' and tl(b.decl.ty.base) == t)
            c.role('_g%sa' % t, b.decl)
            return 'E'
        need(b.k == 'load')
        d = gvar(b.e, 'ptr')
        need(tl(d.ty.base) == t)
        k = const(n.idx)
        c.role('_g%sp' % t, d)
        if k == 2 and 'Q' in allowed:
            return 'Q'
        need(k == 0 and 'R0' in allowed)
        return 'R0'
    raise No()


# ------------------------------------------------------------------------------------------------- er_d
def fam_er_d(c, f, inner, post, loop):
    need(not post and c.u is None)
    e = strip_assign(one_expr(inner))
    dt = tl(cg.strip(e.l).ty)
    need(dt in ('i', 'c', 'n'))
    r = unc(e.r)
    need(r.k == 'bin')
    if c.q is not None:
        need(r.op == '-')
        l = unc(r.l)
        need(l.k == 'load' and cg.strip(l.e).k == 'deref')
        p = unc(cg.strip(l.e).e)
        need(p.k == 'load' and cg.strip(p.e).decl is c.q)
        t, B, I = c.elem(r.r, base_kinds='q')
        need(t == dt)
        c.store_global(e.l, '_g%s' % t, t)
        if loop is not None:
            pass
        return 'er_d_s3_%s%s' % (t, I)
    if r.op == '*':
        a = unc(r.l)
        need(a.k == 'bin' and a.op == '+')
        t, B, I = c.elem(r.r)
        need(B == 'A' and t == dt)
        t2, B2, I2 = c.elem(a.r)
        c.same_elem(a.r, r.r)
        c.gload(a.l, '_h%s' % t, t)
        c.store_global(e.l, '_g%s' % t, t)
        return 'er_d_s1_%s%s' % (t, I)
    need(r.op == '-')
    b = unc(r.r)
    need(b.k == 'bin' and b.op == '-')
    t, B, I = c.elem(b.r)
    need(B == 'A' and t == dt)
    c.gload(r.l, '_h%s' % t, t)
    c.gload(b.l, '_v%s' % t, t)
    c.store_global(e.l, '_g%s' % t, t)
    return 'er_d_s2_%s%s' % (t, I)


# ------------------------------------------------------------------------------------------------- bc_a, bc_b
def fam_bc(c, f, inner, post, loop):
    need(not post and c.u is None and c.q is None)
    e = strip_assign(one_expr(inner))
    ie = strip_assign(unc(e.r))
    t, B, I = c.elem(ie.l)
    need(B == 'A' and I in 'abcLf')
    V = value_kind(c, ie.r, t)
    D = dest_kind(c, e.l, t, 'GMEPD')
    if D == 'G':
        return 'bc_a_%s%s%s' % (t, I, V)
    need(V in 'KGS')
    return 'bc_b_%s%s%s%s' % (t, I, D, V)


def value_kind(c, n, t):
    v = unc(n)
    k = const(v)
    if k is not None:
        need(k == 7)
        return 'K'
    if v.k == 'un' and v.op == '!':
        c.gload(v.e, '_gi', 'i')
        return 'N'
    if v.k == 'bin' and v.op == '%':
        need(const(v.r) == 16)
        a = unc(v.l)
        need(a.k == 'bin' and a.op == '+')
        c.kelem(a.l, t, 3, '_w%sa' % t)
        c.gload(a.r, '_v%s' % t, t)
        return 'B'
    need(v.k == 'load')
    x = cg.strip(v.e)
    if x.k == 'index':
        c.kelem(v, t, 1, '_h%sa' % t)
        return 'S'
    c.gload(v, '_v%s' % t, t)
    return 'G'


# ------------------------------------------------------------------------------------------------- bc_c
def fam_bc_c(c, f, inner, post, loop):
    need(c.q is None)
    if c.u is not None:                                        # V: T u = (EL = vT); gi3 = u
        u = c.u.var
        need(len(post if loop is not None else inner) == 1)
        if loop is None:
            need(c.u.init is not None)
            ie = strip_assign(unc(c.u.init))
            ps = inner[0]
        else:
            need(const(c.u.init) == 0)
            e = strip_assign(one_expr(inner))
            need(cg.strip(e.l).k == 'var' and cg.strip(e.l).decl is u)
            ie = strip_assign(unc(e.r))
            ps = post[0]
        need(ps.k == 'expr')
        pe = strip_assign(ps.e)
        x = unc(pe.r)
        need(x.k == 'load' and cg.strip(x.e).decl is u)
        t, B, I = c.elem(ie.l)
        need(B == 'A' and tl(u.ty) == t)
        c.store_global(pe.l, '_gi3', 'i')
        need(value_kind(c, ie.r, t) == 'G')
        return 'bc_c_%s%sV' % (t, I)
    need(not post and len(inner) == 1)
    s = inner[0]
    if s.k == 'return':
        e = strip_assign(unc(s.value))
        t, B, I = c.elem(e.r)
        need(B == 'A' and tl(f.ret) == t)
        need(dest_kind(c, e.l, t, 'R0') == 'R0')
        return 'bc_c_%s%sR' % (t, I)
    if s.k == 'if':
        need(s.els is None)
        cd = unc(s.cond)
        X = 'C'
        if cd.k == 'bin' and cd.op == '&&':
            g = unc(cd.l)
            need(g.k == 'bin' and g.op == '<' and const(g.r) == 5)
            c.gload(g.l, '_gi', 'i')
            cd = unc(cd.r)
            X = 'A'
        need(cd.k == 'bin' and cd.op == '==')
        ie = strip_assign(unc(cd.l))
        t, B, I = c.elem(ie.l)
        need(B == 'A' and const(ie.r) == 2)
        c.gload(cd.r, '_gi', 'i')
        th = cg.flat(s.then)
        need(len(th) == 1 and th[0].k == 'expr')
        te = strip_assign(th[0].e)
        c.store_global(te.l, '_gi3', 'i')
        need(const(te.r) == 1)
        return 'bc_c_%s%s%s' % (t, I, X)
    need(s.k == 'expr')
    e = cg.strip(s.e)
    need(e.k == 'call' and len(e.args) == 1)
    fn = cg.strip(e.fn)
    need(fn.k == 'var')
    need(tl(cg.strip(e.args[0]).ty) == tl(unc(e.args[0]).ty))
    c.callee_cdecl = bool(getattr(fn.decl.ty, 'cdecl', False))
    ie = strip_assign(unc(e.args[0]))
    t, B, I = c.elem(ie.l)
    need(B == 'A')
    need(value_kind(c, ie.r, t) == 'G')
    c.role('_sk%s' % t, fn.decl)
    return 'bc_c_%s%sK' % (t, I)


# ==============================================================================================================
# register colouring of virtual instructions
# ==============================================================================================================
BYDEG = False
PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}


class Reg:
    def __init__(self, p):
        self.p = p

    def __format__(self, spec):
        p = self.p
        return {'': p, 'x': 'X' + p, 'b': LOW.get(p, '?'), 'h': HIGH.get(p, '?'), 'q': 'Q' + p}[spec]


class Ins:
    def __init__(self, text, copy=None, when=None):
        self.text, self.copy, self.when = text, copy, when
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text)


def cells(r, w):
    if w == 8:
        return {(r, 'lo')}
    return {(r, 'lo'), (r, 'hi')} | ({(r, 'q')} if w == 32 else set())


class Body:
    def __init__(self):
        self.seq = []
        self.width = {}
        self.early = []
        self.bydeg = BYDEG

    def e(self, text, copy=None, when=None):
        self.seq.append(Ins(text, copy, when))

    def w(self, **kw):
        self.width.update(kw)

    def colour(self, fixed=None, first=(), pref=None, avoid=None, coalesce=True, order=None, live=None,
               nocoalesce=(), params=('p', 'p2', 'p3'), last=()):
        """fixed {temp: pair}; first: temps coloured before the rest; pref {temp: pair or temp};
        avoid {temp: [temps]}; live {temp: (start, end)} overrides; order: explicit order for the rest."""
        fixed = dict(fixed or {})
        pref = dict(pref or {})
        avoid = dict(avoid or {})
        iv = {}
        for i, ins in enumerate(self.seq):
            for n in ins.temps:
                iv.setdefault(n, [i, i])[1] = i
        for n in params:
            if n in iv:
                iv[n][0] = -1
        for n, se in (live or {}).items():
            if n in iv:
                iv[n] = list(se)
        self.iv = iv
        W = lambda n: self.width.get(n, 16)
        reg = {n: r for n, r in fixed.items() if n in iv}

        def busy_for(n, skip=()):
            s, e = iv[n]
            b = set()
            for o, r in reg.items():
                if o == n or o in skip:
                    continue
                s2, e2 = iv[o]
                if s < e2 and s2 < e:
                    b |= cells(r, W(o))
            return b

        def free(n, r, skip=()):
            return not (cells(r, W(n)) & busy_for(n, skip))

        def pick(n):
            if n in reg:
                return
            w = W(n)
            pool = PAIRS[:4] if w == 8 else PAIRS
            av = set()
            for a in avoid.get(n, ()):
                if a in reg:
                    av.add(reg[a])
            want = pref.get(n)
            if want in reg:
                want = reg[want]
            if want in pool and want not in av and free(n, want):
                reg[n] = want
                return
            for p in pool:
                if p not in av and free(n, p):
                    reg[n] = p
                    return
            raise RuntimeError('no register for %s' % n)

        for n in first:
            if n in iv:
                pick(n)
        if coalesce:
            for i, ins in enumerate(self.seq):
                if ins.copy:
                    a, b = ins.copy
                    if a in iv and b in iv and a not in reg and b in reg and iv[b][1] == i and a not in nocoalesce:
                        if free(a, reg[b], skip=(b,)):
                            reg[a] = reg[b]
        def deg(n):
            s, e = iv[n]
            return sum(1 for o in iv if o != n and s < iv[o][1] and iv[o][0] < e)

        rest = order if order is not None else sorted((n for n in iv if n not in reg), key=lambda n: (-deg(n), iv[n][0]) if self.bydeg else (n not in self.early, iv[n][0]))
        for n in rest:
            if n in iv and n not in last:
                pick(n)
        for n in sorted(iv, key=lambda n: iv[n][0]):
            if n not in last:
                pick(n)
        for n in last:
            if n in iv:
                pick(n)
        for n in sorted(iv, key=lambda n: iv[n][0]):
            pick(n)
        self.reg = reg
        F = {n: Reg(r) for n, r in reg.items()}
        out = []
        for ins in self.seq:
            if ins.copy and ins.copy[1] in reg and reg.get(ins.copy[0]) == reg[ins.copy[1]]:
                continue
            if ins.when and (reg.get(ins.when[0]) == reg.get(ins.when[1])) != ins.when[2]:
                continue
            out.append(ins.text.format(**F))
        return out


def loop(b, body_fn, call=False):
    """`for (i = 0; i < 4; i++) body`: the counter {ctr} is live over the whole loop and coloured last; temps
    named in `carried` (parameters) are live over the whole loop too"""
    b.e('ld {ctr},0x0')
    b.e('cp {ctr},0x4')
    b.e('ret ge')
    b.e('L1:')
    body_fn()
    b.e('inc 0x1,{ctr}')
    b.e('cp {ctr},0x4')
    b.e('j lt,L1')
    b.e('L2:')
    b.e('ret')
    n = len(b.seq)
    return {'ctr': (-1, n)}


# ==============================================================================================================
# er_*, no options (research-scratch elrd1-predict.py)
# ==============================================================================================================
#!/usr/bin/env python3
"""er0_predict.py -- templates for the er_* probes of elrd.c (see FAMILIES.md).

er0_predict(name) -> list of the oracle's instruction strings, from the letters of the name.
python3 er0_predict.py --check forms.txt [-oPREFIX] [-q]   per-family score, the first differing instruction
python3 er0_predict.py NAME                                print the prediction

Letters (gen_elrd.py): type t  c u i w l n;  index kind I  a b c d (parameters: int char uchar uint),
L (loop counter), f g h j (locals: int uchar char uint);  see FAMILIES.md for the rest.
"""

TYP = {'c': 1, 'u': 1, 'i': 2, 'w': 2, 'l': 4, 'n': 4}         # letter -> size in bytes
UNSIGNED = set('uwn')
ACC = {1: 'A', 2: 'WA', 4: 'XWA'}                               # value register of that size, in the WA family
OPS = {'p': 'add', 's': 'sub', 'o': 'or', 'a': 'and', 'x': 'xor', 'm': 'muls'}
SRC_PARAM = '(XSP+0x4)'      # the first (only) parameter
SRC_LOCAL = '(_gi)'          # a local "T t = gi;" is only ever read once, straight from gi
CTR = 'CTR'                  # placeholder for the loop counter register, chosen when the body is known


def hx(n):
    return '0x%x' % n


def sz(t):
    return TYP[t]


def scale(s, reg):
    """multiply the index in reg by the element size s"""
    if s == 1:
        return []
    if reg.startswith('X'):
        return ['add %s,%s' % (reg, reg)] if s == 2 else ['sll 0x2,%s' % reg]
    return ['add %s,%s' % (reg, reg)] if s == 2 else ['sla 0x2,%s' % reg]


# ---------------------------------------------------------------- the element address
def index_code(s, I, order, arr, src, base='A'):
    """instructions that leave arr[idx] (elements of s bytes) addressable, and the operand string.
    order 'F': the left operand is loaded AFTER this code and takes WA, so the temporaries are BC/DE.
    order 'E': the element is the first value computed and goes to WA, so the temporaries are WA/BC.
    base 'M' (member array hs.xa) differs from 'A' (global array) for byte elements only."""
    E = order == 'E'
    lda = lambda r: 'lda X%s,%s' % (r, arr)
    if I == 'L':
        if s == 1:
            r = 'WA' if E else 'BC'
            return [lda(r)], '(X%s+%s)' % (r, CTR)
        p, q = ('WA', 'BC') if E else ('BC', 'DE')
        return ['ld %s,%s' % (p, CTR)] + scale(s, p) + [lda(q)], '(X%s+%s)' % (q, p)
    if s == 1:
        if base == 'M':          # member array: plain indexed operand, no extension of the index
            if I in 'af':
                return ['ld BC,%s' % src, lda('DE')], '(XDE+BC)'
            if I == 'b':
                return ['ld C,%s' % src, lda('DE')], '(XDE+C)'
        if I == 'a':             # int parameter, byte element: zero-extend and ADD to the base
            return [lda('WA'), 'ld BC,%s' % src, 'extz XBC', 'add XBC,XWA'], '(XBC)'
        if I == 'f':             # int local: plain indexed operand
            p, q = ('BC', 'WA') if E else ('DE', 'BC')
            return ['ld %s,%s' % (p, src), lda(q)], '(X%s+%s)' % (q, p)
        if I == 'b':             # char parameter: sign handling is a byte load into a zeroed XDE/XWA
            if E:
                return [lda('BC'), 'ld XWA,0x0', 'ld A,%s' % src, 'add XWA,XBC'], '(XWA)'
            return [lda('BC'), 'ld A,%s' % src, 'ld XDE,0x0', 'ld E,A', 'add XDE,XBC'], '(XDE)'
        if I in 'cg':
            ld = 'ld A,%s' % src if I == 'c' else 'ld WA,%s' % src
            if E:
                return [ld, 'extz WA', lda('BC')], '(XBC+WA)'
            return [ld, 'ld C,A', 'extz BC', lda('DE')], '(XDE+BC)'
        if I in 'dj':
            return ['ld WA,%s' % src, 'extz XWA', 'ld XBC,%s' % arr, 'add XBC,XWA'], '(XBC)'
        if I == 'h':
            if E:
                return ['ld WA,%s' % src, 'ld C,A', lda('WA')], '(XWA+C)'
            return ['ld WA,%s' % src, 'ld E,A', lda('BC')], '(XBC+E)'
    # ---- scaled elements (s = 2 or 4)
    if I in 'af':
        p, q = ('WA', 'BC') if E else ('BC', 'DE')
        return ['ld %s,%s' % (p, src)] + scale(s, p) + [lda(q)], '(X%s+%s)' % (q, p)
    if I in 'bh':
        if s == 4:
            sc = ['sla 0x2,A']
        elif I == 'b':
            sc = ['add A,%s' % src]
        else:
            sc = ['ld C,A', 'add A,C']
        pre = ['ld A,%s' % src] if I == 'b' else ['ld WA,%s' % src]
        pre = pre + sc
        if E:
            return pre + [lda('BC')], '(XBC+A)'
        return pre + ['ld C,A', lda('DE')], '(XDE+C)'
    if I in 'cg':
        ld = 'ld A,%s' % src if I == 'c' else 'ld WA,%s' % src
        if E:
            return [ld, 'extz WA'] + scale(s, 'WA') + [lda('BC')], '(XBC+WA)'
        return [ld, 'extz WA', 'ld BC,WA'] + scale(s, 'BC') + [lda('DE')], '(XDE+BC)'
    if I in 'dj':
        return (['ld WA,%s' % src, 'extz XWA'] + scale(s, 'XWA') +
                ['ld XBC,%s' % arr, 'add XBC,XWA']), '(XBC)'
    raise KeyError(I)


# ---------------------------------------------------------------- registers and loops
_REG0 = re.compile(r'(?<![A-Za-z_0-9])X?(WA|BC|DE|HL|IX|IY|IZ|A|C|E|L)(?![A-Za-z_0-9])')
_PAIR0 = {'A': 'WA', 'C': 'BC', 'E': 'DE', 'L': 'HL'}


def regs_in(ins):
    """register pairs named in the operands of ins (byte registers count as their pair)"""
    out = set()
    for x in ins:
        parts = x.split(None, 1)
        if len(parts) > 1:
            out |= {_PAIR0.get(m, m) for m in _REG0.findall(parts[1])}
    return out


def counter_for(body, call=False):
    """a loop counter takes the first of BC DE HL IX IY that the body does not name; a body with a call
    needs a register the callee keeps: IZ"""
    if call:
        return 'IZ'
    used = regs_in(body)
    for r in ('BC', 'DE', 'HL', 'IX', 'IY'):
        if r not in used:
            return r
    raise RuntimeError('no counter')


def sub_ctr(body, c):
    return [x.replace(CTR, c) for x in body]


def wrap_ret(I, body, call=False):
    """function wrapper: a loop `for (i = 0; i < 4; i++)` or nothing"""
    if I != 'L':
        return body + ['ret']
    c = counter_for(body, call)
    return (['ld %s,0x0' % c, 'cp %s,0x4' % c, 'ret ge', 'L1:'] + sub_ctr(body, c) +
            ['inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L1', 'L2:', 'ret'])


# ---------------------------------------------------------------- er_a, er_c:  gT = L op h<t>a[idx]
def left_code(L, t, s):
    R = ACC[s]
    if L == 'K':
        return ['ld %s,0x7' % R]
    if L == 'G':
        return ['ld %s,(_h%s)' % (R, t)]
    if L == 'Z':
        return ['ld %s,(_h%sa + %s)' % (R, t, hx(s))]
    if L == 'C':
        return ['ld %s,(_h%s)' % (R, t), 'dec 0x3,%s' % R]
    raise KeyError(L)


def binop(t, I, L, o):
    s = sz(t)
    R = ACC[s]
    arr = '_h%sa' % t
    src = SRC_PARAM if I in 'abcd' else SRC_LOCAL
    mn = OPS[o]
    # a commutative operator with a constant / constant-address left operand is turned round: the
    # element is loaded first, the constant is the operand of the operation
    order = 'E' if (o == 'o' and L in 'KZ') else 'F'
    ins, opd = index_code(s, I, order, arr, src)
    st = 'ld (_g%s),%s' % (t, R)
    if order == 'E':
        left = {'K': '0x7', 'Z': '(_h%sa + %s)' % (t, hx(s))}[L]
        body = ins + ['ld %s,%s' % (R, opd), '%s %s,%s' % (mn, R, left), st]
    else:
        reg = ('WA' if s == 1 else 'XWA') if mn == 'muls' else R
        body = ins + left_code(L, t, s) + ['%s %s,%s' % (mn, reg, opd), st]
    return wrap_ret(I, body)


# ---------------------------------------------------------------- er_c, long multiply: a helper call
def mulu(t, I, L):
    """gn = L * hna[idx] for unsigned long: the compiler calls C9H_mullu (XWA * XBC -> XHL).  The element address
    is formed before the call; with a plain global as left operand the scaled index is spilled to a stack
    slot and the base lives in the call-saved XIZ, with a computed left operand the sum is built in XBC."""
    arr = '_h%sa' % t
    st = ['cal C9H_mullu', 'ld (_g%s),XHL' % t]
    if L == 'C':
        left = ['ld XWA,(_h%s)' % t, 'dec 0x3,XWA']
        if I == 'b':
            idx, r = ['ld A,%s' % SRC_PARAM, 'sla 0x2,A'], 'A'
        elif I == 'f':
            idx, r = ['ld WA,%s' % SRC_LOCAL, 'sla 0x2,WA'], 'WA'
        else:
            idx, r = ['ld WA,IZ', 'sla 0x2,WA'], 'WA'
        body = idx + ['lda XBC,%s' % arr, 'lda XBC,XBC+%s' % r] + left + ['ld XBC,(XBC)'] + st
        if I != 'L':
            return body + ['ret']
        return (['push IZ', 'ld IZ,0x0', 'cp IZ,0x4', 'j ge,L1', 'L2:'] + body +
                ['inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L2', 'L1:', 'pop IZ', 'ret'])
    left = ['lda XIZ,%s' % arr, 'ld XWA,(_h%s)' % t]
    if I == 'b':
        return (['dec 0x2,XSP', 'push XIZ', 'ld A,(XSP+0xa)', 'sla 0x2,A', 'ld (XSP+0x4),A'] + left +
                ['ld C,(XSP+0x4)', 'ld XBC,(XIZ+C)'] + st + ['pop XIZ', 'inc 0x2,XSP', 'ret'])
    if I == 'f':
        return (['dec 0x2,XSP', 'push XIZ', 'ld WA,%s' % SRC_LOCAL, 'ld (XSP+0x4),WA', 'ld WA,(XSP+0x4)',
                 'sla 0x2,WA', 'ld (XSP+0x4),WA'] + left + ['ld BC,(XSP+0x4)', 'ld XBC,(XIZ+BC)'] + st +
                ['pop XIZ', 'inc 0x2,XSP', 'ret'])
    return (['dec 0x4,XSP', 'push XIZ', 'ldw (XSP+0x4),0x0', 'cpw (XSP+0x4),0x4', 'j ge,L1', 'L2:',
             'ld WA,(XSP+0x4)', 'ld (XSP+0x6),WA', 'ld WA,(XSP+0x6)', 'sla 0x2,WA', 'ld (XSP+0x6),WA'] + left +
            ['ld BC,(XSP+0x6)', 'ld XBC,(XIZ+BC)'] + st +
            ['incw 0x1,(XSP+0x4)', 'cpw (XSP+0x4),0x4', 'j lt,L2', 'L1:',
             'pop XIZ', 'inc 0x4,XSP', 'ret'])


# ---------------------------------------------------------------- er_k: gR = (R)hR o (R)h<t>a[idx]
def fam_k(t, R, o, I):
    """a cast element is a register value, not a memory operand: the element is computed first (layout 'E'),
    converted to R in a register, and the left operand (a plain global) is then the operand of the operation.
    Without a cast (t == R == n) it is the ordinary left-first er_a form."""
    s = sz(t)
    if t == R:
        return binop(t, I, 'G', o)
    arr = '_h%sa' % t
    ins, opd = index_code(s, I, 'E', arr, SRC_PARAM)
    sub = (o == 's')
    ext = 'extz' if t in UNSIGNED else 'exts'
    if R == 'c':
        if s == 1:
            elem = ['ld %s,%s' % ('C' if sub else 'A', opd)]
        else:
            elem = ['ld %s,%s' % (ACC[s], opd)] + (['ld C,A'] if sub else [])
        tail = ['ld A,(_hc)', 'sub A,C'] if sub else ['or A,(_hc)']
        return wrap_ret(I, ins + elem + tail + ['ld (_gc),A'])
    if sub:
        if s == 1:
            elem = ['ld A,%s' % opd, 'ld XBC,0x0', 'ld C,A']
        elif s == 2:
            elem = ['ld BC,%s' % opd, '%s XBC' % ext]
        else:
            elem = ['ld XBC,%s' % opd]
        tail = ['ld XWA,(_hn)', 'sub XWA,XBC']
    else:
        if s == 1:
            elem = (['ld XWA,0x0', 'ld A,%s' % opd] if opd == '(XBC)' else ['ld A,%s' % opd, 'extz WA', 'extz XWA'])
        elif s == 2:
            elem = ['ld WA,%s' % opd, '%s XWA' % ext]
        else:
            elem = ['ld XWA,%s' % opd]
        tail = ['or XWA,(_hn)']
    return wrap_ret(I, ins + elem + tail + ['ld (_gn),XWA'])


# ---------------------------------------------------------------- er_d: nested shapes
def wrap_pre(I, pre, body, call=False, jge=False):
    """like wrap_ret, with instructions `pre` before the loop (the counter avoids their registers too)"""
    if I != 'L':
        return pre + body + ['ret']
    c = counter_for(pre + body, call)
    if jge:
        return (['push IZ'] if call else []) + pre + ['ld %s,0x0' % c, 'cp %s,0x4' % c, 'j ge,L1', 'L2:'] + \
            sub_ctr(body, c) + ['inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L2', 'L1:'] + (['pop IZ'] if call else []) + ['ret']
    return (pre + ['ld %s,0x0' % c, 'cp %s,0x4' % c, 'ret ge', 'L1:'] + sub_ctr(body, c) +
            ['inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L1', 'L2:', 'ret'])


def d_s2(t, I):
    """gT = hT - (vT - hTa[x]):  the inner difference is a register value"""
    s = sz(t)
    src = SRC_PARAM if I in 'abcd' else SRC_LOCAL
    arr = '_h%sa' % t
    if s == 1:
        ins, opd = index_code(1, I, 'F', arr, src)
        body = ins + ['ld A,(_v%s)' % t, 'sub A,%s' % opd, 'ld C,A', 'ld A,(_h%s)' % t, 'sub A,C', 'ld (_g%s),A' % t]
    else:
        ins, opd = index_code(s, I, 'E', arr, src)
        lr = 'DE' if s == 2 else 'XDE'
        body = ins + ['ld %s,(_v%s)' % (lr, t), 'sub %s,%s' % (lr, opd), 'ld %s,(_h%s)' % (ACC[s], t),
                      'sub %s,%s' % (ACC[s], lr), 'ld (_g%s),%s' % (t, ACC[s])]
    return wrap_ret(I, body)


def d_s3(t, I):
    """gT = *q - q[x]  with  T *q = gTp;  the pointer is held in a register"""
    s = sz(t)
    src = SRC_PARAM if I in 'abcd' else SRC_LOCAL
    R = ACC[s]
    ptr = '(_g%sp)' % t
    if s == 1:
        if I == 'a':
            body = ['ld XWA,%s' % ptr, 'ld BC,%s' % src, 'extz XBC', 'add XBC,XWA', 'ld A,(XWA)', 'sub A,(XBC)']
            pre = []
        elif I == 'b':
            body = ['ld XDE,%s' % ptr, 'ld A,%s' % src, 'ld XBC,0x0', 'ld C,A', 'add XBC,XDE', 'ld A,(XDE)', 'sub A,(XBC)']
            pre = []
        elif I == 'L':
            pre = ['ld XBC,%s' % ptr]
            body = ['ld A,(XBC)', 'sub A,(XBC+%s)' % CTR]
        else:
            pre = []
            body = ['ld DE,%s' % src, 'ld XBC,%s' % ptr, 'ld A,(XBC)', 'sub A,(XBC+DE)']
    else:
        if I == 'b':
            pre = []
            body = ['ld XDE,%s' % ptr, 'ld A,%s' % src, 'exts WA', 'ld BC,WA'] + scale(s, 'BC') + \
                   ['ld %s,(XDE)' % R, 'sub %s,(XDE+BC)' % R]
        else:
            first = {'a': ['ld XDE,%s' % ptr, 'ld WA,%s' % src], 'f': ['ld WA,%s' % src, 'ld XDE,%s' % ptr],
                     'L': ['ld WA,%s' % CTR]}[I]
            pre = ['ld XDE,%s' % ptr] if I == 'L' else []
            body = first + ['exts XWA'] + scale(s, 'XWA') + ['ld XBC,XWA', 'add XBC,XDE', 'ld %s,(XDE)' % R, 'sub %s,(XBC)' % R]
    return wrap_pre(I, pre, body + ['ld (_g%s),%s' % (t, R)])


def d_s1(t, I):
    """gT = (hT + hTa[x]) * hTa[x]:  the element address is formed twice, once for each use"""
    s = sz(t)
    arr = '_h%sa' % t
    src = SRC_PARAM if I in 'abcd' else SRC_LOCAL
    st = 'ld (_g%s),%s' % (t, ACC[s])
    if s == 4:                                       # unsigned long: the product is a helper call
        post = ['ld XWA,XHL', 'ld XBC,(XBC)', 'cal C9H_mullu', 'ld (_gn),XHL']
        if I == 'L':
            r = 'IZ'
        pre = []
        if I == 'f':
            pre = ['ld DE,%s' % src]
            c = 'DE'
        if I in 'bL':
            first = ['ld A,%s' % src, 'sla 0x2,A'] if I == 'b' else ['ld WA,CTR', 'sla 0x2,WA']
            r = 'A' if I == 'b' else 'WA'
            ld2 = list(first)
            body = first + ['lda XBC,%s' % arr, 'lda XBC,XBC+%s' % r] + ld2 + ['lda XDE,%s' % arr, 'ld XHL,(_hn)', 'add XHL,(XDE+%s)' % r] + post
        else:
            first = ['ld WA,%s' % ('DE' if I == 'f' else src), 'sla 0x2,WA']
            body = pre + first + ['lda XBC,%s' % arr, 'lda XBC,XBC+WA'] + first + ['lda XDE,%s' % arr, 'ld XHL,(_hn)', 'add XHL,(XDE+WA)'] + post
        if I == 'L':
            return wrap_pre('L', [], body, call=True, jge=True)
        return body + ['ret']
    if s == 2:
        if I == 'b':
            return (['ld C,%s' % src, 'ld A,C', 'add A,C', 'ld E,A', 'lda XHL,%s' % arr, 'ld A,C', 'add A,C',
                     'lda XBC,%s' % arr, 'ld IX,(_h%s)' % t, 'add IX,(XBC+A)', 'ld WA,IX', 'muls XWA,(XHL+E)', st, 'ret'])
        ld = {'a': ['ld WA,%s' % src], 'f': ['ld WA,%s' % src], 'L': ['ld DE,CTR']}[I]
        if I == 'L':
            body = ['ld DE,CTR', 'add DE,DE', 'lda XHL,%s' % arr, 'ld WA,CTR', 'add WA,WA']
        else:
            body = ld + ['ld DE,WA', 'add DE,DE', 'lda XHL,%s' % arr, 'add WA,WA']
        body += ['lda XBC,%s' % arr, 'ld IX,(_h%s)' % t, 'add IX,(XBC+WA)', 'ld WA,IX', 'muls XWA,(XHL+DE)', st]
        return wrap_ret(I, body)
    # char
    if I == 'L':
        return wrap_ret('L', ['lda XDE,%s' % arr, 'lda XBC,%s' % arr, 'ld A,(_h%s)' % t, 'add A,(XBC+CTR)',
                              'muls WA,(XDE+CTR)', st])
    if I == 'f':
        return ['ld HL,%s' % src, 'lda XDE,%s' % arr, 'lda XBC,%s' % arr, 'ld A,(_hc)', 'add A,(XBC+HL)',
                'muls WA,(XDE+HL)', st, 'ret']
    if I == 'a':
        sm = lambda r, q: ['lda XWA,%s' % arr, 'ld %s,%s' % (r, src), 'extz X%s' % r, 'add X%s,XWA' % r]
        return sm('DE', 0) + sm('BC', 0) + ['ld A,(_hc)', 'add A,(XBC)', 'muls WA,(XDE)', st, 'ret']
    sm = lambda r: ['lda XBC,%s' % arr, 'ld A,%s' % src, 'ld X%s,0x0' % r, 'ld %s,A' % ('L' if r == 'HL' else 'E'), 'add X%s,XBC' % r]
    return sm('HL') + sm('DE') + ['ld A,(_hc)', 'add A,(XDE)', 'muls WA,(XHL)', st, 'ret']

# ---------------------------------------------------------------- er_e: the base kind of the element
def elem_base(t, B, I, src_idx='(XSP+0x4)'):
    """returns (instructions, operand) for  base[idx]  with order F; B: A M D Q R"""
    s = sz(t)
    arr = {'A': '_h%sa' % t, 'M': '_hs + %s' % hx(MEMOFF[t][1])}.get(B)
    ptr = {'Q': '(_g%sp)' % t, 'R': '(XSP+0x4)'}.get(B)
    if B in 'AM':
        return index_code(s, I, 'F', arr, src_idx, base=B)
    if B == 'D':                      # hps->ta[idx]: the member offset is folded into the byte index
        off = MEMOFF[t][1]
        if I == 'L':
            pre = ['ld WA,%s' % CTR]
        else:
            pre = ['ld A,%s' % src_idx] if I == 'b' else ['ld WA,%s' % src_idx]
        if s == 2:
            sc = [('add A,%s' % src_idx) if I == 'b' else 'add WA,WA', 'add %s,%s' % ('A' if I == 'b' else 'WA', hx(off))]
        else:
            sc = ['inc %s,%s' % (hx(off), 'A' if I == 'b' else 'WA')]
        if s == 2 and I == 'b':
            sc = ['add A,%s' % src_idx, 'add A,%s' % hx(off)]
        return pre + sc + ['ld E,A', 'ld XBC,(_hps)'], '(XBC+E)'
    # B in QR: the idx parameter of R is the second argument
    isrc = '(XSP+0x8)' if B == 'R' else src_idx
    p = ptr
    if B == 'Q':
        if s == 1:
            if I == 'a':
                return ['ld XWA,%s' % p, 'ld BC,%s' % isrc, 'extz XBC', 'add XBC,XWA'], '(XBC)'
            if I == 'b':
                return ['ld XBC,%s' % p, 'ld A,%s' % isrc, 'ld XDE,0x0', 'ld E,A', 'add XDE,XBC'], '(XDE)'
            return ['ld XBC,%s' % p], '(XBC+%s)' % CTR
        if I == 'a':
            return ['ld WA,%s' % isrc, 'exts XWA', 'add XWA,XWA', 'ld XBC,XWA', 'add XBC,%s' % p], '(XBC)'
        if I == 'b':
            return ['ld A,%s' % isrc, 'exts WA', 'ld DE,WA', 'add DE,DE', 'ld XBC,%s' % p], '(XBC+DE)'
        return ['ld WA,%s' % CTR, 'exts XWA', 'add XWA,XWA', 'ld XBC,XWA', 'add XBC,%s' % p], '(XBC)'
    # B == 'R': the pointer is the first parameter, added from the stack
    if s == 1:
        if I == 'a':
            return ['ld BC,%s' % isrc, 'extz XBC', 'add XBC,%s' % p], '(XBC)'
        if I == 'b':
            return ['ld A,%s' % isrc, 'ld XBC,0x0', 'ld C,A', 'add XBC,%s' % p], '(XBC)'
        return ['ld BC,%s' % CTR, 'extz XBC', 'add XBC,%s' % p], '(XBC)'
    if I == 'a':
        return ['ld WA,%s' % isrc, 'exts XWA', 'add XWA,XWA', 'ld XBC,XWA', 'add XBC,%s' % p], '(XBC)'
    if I == 'b':
        return ['ld A,%s' % isrc, 'exts WA', 'add WA,WA', 'ld BC,WA', 'extz XBC', 'add XBC,%s' % p], '(XBC)'
    return ['ld WA,%s' % CTR, 'exts XWA', 'add XWA,XWA', 'ld XBC,XWA', 'add XBC,%s' % p], '(XBC)'


# member offsets in struct st (gen_elrd.py): c ca[8] u ua[8] i ia[8] ... -> (scalar offset, array offset)
MEMOFF = {'c': (0, 2), 'u': (10, 12), 'i': (20, 22), 'w': (40, 42), 'l': (60, 64), 'n': (96, 100)}
# (the scalar of i is 0x14 = 20, its array 0x16 = 22 ... n scalar 0x5c = 92 in the oracle: see below)
MEMOFF['n'] = (92, 96)
MEMOFF['l'] = (56, 60)


def fam_e(t, B, I, L):
    s = sz(t)
    R = ACC[s]
    src = '(XSP+0x8)' if B == 'R' and I != 'L' else SRC_PARAM
    ins, opd = elem_base(t, B, I)
    left = ['ld %s,0x7' % R] if L == 'K' else ['ld %s,(_h%s)' % (R, t)]
    body = ins + left + ['sub %s,%s' % (R, opd), 'ld (_g%s),%s' % (t, R)]
    return wrap_ret(I, body)


# ---------------------------------------------------------------- er_b: destination kinds
def fam_b(t, I, D, L):
    s = sz(t)
    acc = ACC[s]                                       # WA / XWA
    x = lambda r: r if s == 2 else 'X' + r              # register pair seen at the value size
    arr = '_h%sa' % t
    src = SRC_PARAM
    unsigned = t in UNSIGNED
    # ---- the left operand and its register
    regime = 'E' if (L in 'GE' and D != 'G') else 'F'
    pre = []
    if L in 'GE':
        # regime F: the accumulator; regime E: the element took WA/BC, the left value goes to the next one
        lr = 'WA' if regime == 'F' else ('HL' if D == 'R' else 'DE')
        ins, opd = index_code(s, I, regime, arr, src)
        leaf = '(_h%s)' % t if L == 'G' else '(_h%sa + %s)' % (t, hx(3 * s))
        body = ins + ['ld %s,%s' % (x(lr), leaf)]
    elif L == 'N':
        ins, opd = index_code(s, I, 'F', arr, src)
        if s == 2:
            n = ['cpw (_h%s),0x0' % t, 'scc eq,WA']
        else:
            n = ['ld XWA,(_h%s)' % t, 'or XWA,XWA', 'scc eq,WA', 'exts XWA']
        lr = 'HL' if D in 'QR' else 'WA'
        body = ins + n + (['ld %s,%s' % (x('HL'), acc)] if lr == 'HL' else [])
    else:                                              # 'D': hps->t
        off = MEMOFF[t][0]
        if I == 'b':
            lr = 'HL' if D == 'R' else ('WA' if D == 'G' else 'BC')
            sc = ['ld A,%s' % src] + (['sla 0x2,A'] if s == 4 else ['add A,%s' % src])
            if D == 'G':
                ins = sc + ['ld E,A', 'lda XHL,%s' % arr]
                opd = '(XHL+E)'
            else:
                ins = sc + ['lda XDE,%s' % arr]
                opd = '(XDE+A)'
            body = ['ld XBC,(_hps)'] + ins + ['ld %s,(XBC+%s)' % (x(lr), hx(off))]
        else:
            lr = 'HL' if D in 'QR' else 'WA'
            ins, opd = index_code(s, I, 'F', arr, src)
            body = ['ld XWA,(_hps)'] + ins + ['ld %s,(XWA+%s)' % (x(lr), hx(off))]
    body = body + ['sub %s,%s' % (x(lr), opd)]
    # ---- the destination
    lrx = x(lr)
    st = []
    ptr = 'XBC' if lr == 'WA' else 'XWA'          # destination pointer: first register the value does not hold
    if D == 'G':
        st = ['ld (_g%s),%s' % (t, lrx)]
    elif D == 'E':
        st = ['ld (_g%sa + %s),%s' % (t, hx(2 * s), lrx)]
    elif D == 'M':
        st = ['ld (_gs + %s),%s' % (hx(MEMOFF[t][0]), lrx)]
    elif D == 'P':
        st = ['ld %s,(_g%sp)' % (ptr, t), 'ld (%s),%s' % (ptr, lrx)]
    elif D == 'Q':
        st = ['ld %s,(_g%sp)' % (ptr, t), 'ld (%s+%s),%s' % (ptr, hx(2 * s), lrx)]
    elif D == 'A':
        st = ['push %s' % lrx, 'cal _sk%s' % t, 'inc %s,XSP' % hx(s)]
    elif D == 'C':
        st = ['cp %s,0x3' % lrx]
    body = body + st
    # ---- the wrapper
    if D == 'C':
        j = 'ule' if unsigned else 'le'
        if I == 'L':
            c = counter_for(body)
            return (['ld %s,0x0' % c, 'cp %s,0x4' % c, 'ret ge', 'L1:'] + sub_ctr(body, c) +
                    ['j %s,L2' % j, 'ldw (_gi3),0x1', 'L2:', 'inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L1', 'L3:', 'ret'])
        return body + ['ret %s' % j, 'ldw (_gi3),0x1', 'L1:', 'ret']
    if I == 'L' and D in 'VA':
        c = counter_for(body, call=(D == 'A'))
        out = (['push IZ'] if D == 'A' else [])
        if D == 'V':
            out += ['ld %s,0x0' % lrx]
        out += ['ld %s,0x0' % c, 'cp %s,0x4' % c, 'j ge,L1', 'L2:'] + sub_ctr(body, c) + \
               ['inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L2', 'L1:']
        if D == 'A':
            out += ['pop IZ']
        if D == 'V':
            out += ['ld (_gi3),%s' % lr]
        return out + ['ret']
    return wrap_ret(I, body)


# ---------------------------------------------------------------- dispatch
def er0_predict(name):
    m = re.match(r'_?er_([a-ek])_(.*)$', name)
    fam, rest = m.group(1), m.group(2)
    if fam == 'c' and rest[0] == 'n' and rest[3] == 'm':
        return mulu(rest[0], rest[1], rest[2])
    if fam in 'ac':
        return binop(rest[0], rest[1], rest[2], rest[3])
    if fam == 'd':
        m2 = re.match(r's([123])_(.)(.)$', rest)
        return {'1': d_s1, '2': d_s2, '3': d_s3}[m2.group(1)](m2.group(2), m2.group(3))
    if fam == 'k':
        return fam_k(rest[0], rest[1], rest[2], rest[3])
    if fam == 'e':
        return fam_e(rest[0], rest[1], rest[2], rest[3])
    if fam == 'b':
        return fam_b(rest[0], rest[1], rest[2], rest[3])
    raise NotImplementedError(name)


# ==============================================================================================================
# bc_*, no options (research-scratch elrd2-predict.py)
# ==============================================================================================================
#!/usr/bin/env python3
"""bc0_predict.py -- bc0_predict the cc900 oracle's code (opt none) for the bc_* probes of elrd.c from the name alone.

    bc0_predict("_bc_a_caK") -> ['lda XWA,_hca', 'ld BC,(XSP+0x4)', ...]
    python3 bc0_predict.py --check forms.txt        score per family, list the wrong ones
    python3 bc0_predict.py NAME                     print one prediction

Names: bc_a_<t><I><V>, bc_b_<t><I><L1><V>, bc_c_<t><I><X>  (letters: see FAMILIES.md / elrd.c header).
The code is written as the compiler seems to work: build the address temps, give every temp the LOWEST register
that no overlapping temp already holds (an interval colouring, order = the order of `COLOUR ORDER` below), then
print the instruction templates with the registers filled in.
"""

REGS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
ES = {'c': 1, 'u': 1, 'i': 2, 'w': 2, 'l': 4, 'n': 4}
SIGNED = {'c': True, 'u': False, 'i': True, 'w': False, 'l': True, 'n': False}
GS_OFF = {'c': 0, 'u': 0xa, 'l': 0x38, 'n': 0x5c}          # member offset in struct st (gs.<t>, gps-><t>)


def hx(n):
    return '0x%x' % n


def X(r):
    return 'X' + r


def reg_of(r, es):
    """register operand text of pair r for an operand of es bytes"""
    return LOW[r] if es == 1 else (r if es == 2 else X(r))


class Colour:
    """interval colouring: temps are (start, end, fixed); two temps overlap when s1 < e2 and s2 < e1.
    Each temp, in the order the caller asks, gets its fixed register or the lowest register no overlapping
    coloured temp holds."""

    def __init__(self):
        self.t = {}
        self.r = {}

    def add(self, name, s, e, fixed=None):
        self.t[name] = (s, e, fixed)
        if fixed:
            self.r[name] = fixed

    def go(self, name):
        if name in self.r or name not in self.t:
            return
        s, e, _ = self.t[name]
        busy = {self.r[o] for o in self.r if o != name and s < self.t[o][1] and self.t[o][0] < e}
        self.r[name] = next(x for x in REGS if x not in busy)

    def order(self, *names):
        for n in names:
            self.go(n)


def sinfo(t):
    return dict(arr='_h%sa' % t, v='_v%s' % t, g='_g%s' % t, w='_w%sa' % t, p='_g%sp' % t)


def gen(t, I, V, outer, ctx=None):
    """The shared core: `outer = (EL = V)` where EL = h<t>a[idx].
    outer: 'G' global gt, 'M' gs.t, 'E' gta[2], 'P' *gtp, 'D' gps->t   (families a, b)
           'C' (EL = 2) == gi condition, 'A' the same behind  gi < 5 &&,  'R' return (gtp[0] = EL),
           'K' sink call argument, 'V' local initialiser   (family c; V is then the value kind K/G)."""
    es = ES[t]
    sy = sinfo(t)
    H = sy['arr']
    ctxc = outer in 'CARKV'
    loop = I == 'L'
    callctx = outer == 'K'
    out = []
    # ---- value kind of the inner assignment -------------------------------------------------------------------
    if outer == 'C' or outer == 'A':
        V = 'K'                       # constant 2
    if outer == 'R':
        V = 'E'                       # element copy source (loaded into the return register)
    if outer in 'KV':
        V = 'G'
    konst = 2 if outer in 'CA' else 7
    longk = V == 'K' and es == 4
    # ---- does the value take WA by force? ---------------------------------------------------------------------
    wa = (V == 'B') or longk or (V == 'N' and es == 1 and I == 'b')
    sum_form = es == 1 and I in 'ab'
    C = Colour()
    if loop:
        if callctx:
            C.add('ctr', -5, 100, 'IZ')
        else:
            C.add('ctr', -5, 100)
    # address temps
    T_END = 10
    if sum_form:
        C.add('base', 1, 4)
        if I == 'a':
            C.add('addr', 2, T_END)
        else:
            C.add('ta', 3, 4, 'WA')
            C.add('addr', 2, T_END, None if wa else 'WA')
    elif es == 1:                      # c, L, f : indexed (base+idx)
        if I == 'c':
            C.add('idx', 1, T_END, None)
        C.add('base', 2, T_END)
        if I == 'f':
            C.add('loc', 0, T_END)
    else:
        C.add('idx', 1, T_END, 'WA' if (I in 'bc' and not wa) else None)
        C.add('base', 2, T_END)
    # value temp
    ptr_kind = outer if outer in 'PD' else ('P' if outer == 'R' else None)
    off = GS_OFF.get(t, 0) if outer == 'D' else 0
    ptr_late = ptr_kind is not None and V == 'S'
    if outer == 'R':
        C.add('val', 8, 12, 'HL')
    elif V == 'K' and es == 4:
        C.add('val', 8, 12, 'WA')
    elif V == 'B' or (V == 'N' and es == 1 and I == 'b'):
        C.add('val', 6 if V == 'B' else 8, 12, 'WA')
    elif V == 'K':
        if outer in 'PDME':                    # byte constant: reloaded for the outer store
            C.add('val', 11, 12)
        elif outer in 'CA':
            C.add('val', 11, 12)
    else:
        C.add('val', 8, 12)
    if outer == 'K' or outer == 'V':
        C.t['val'] = (-5, 100, None) if (outer == 'V' and loop and es > 1) else (8, 12, None)
    if ptr_kind:
        if ptr_late:
            C.add('ptr', 11, 12)
        else:
            C.add('ptr', 0, 12)
    if outer in 'CA' and es >= 2 and t in 'wln':
        C.add('gi', 0, 12)
    if outer in 'CA' and es == 4:
        C.add('gi', 0, 12)
    # ---- COLOUR ORDER ------------------------------------------------------------------------------------------
    if ptr_kind == 'D' and off:
        C.order('ptr')
    if sum_form:
        C.order('base', 'addr')
    elif es == 1:
        if I == 'c':
            C.order('idx')
        C.order('base')
    else:
        C.order('idx', 'base')
    C.order('val')
    if ptr_kind == 'P' or (ptr_kind == 'D' and not off):
        C.order('ptr')
    C.order('ptr')
    C.order('loc')
    C.order('gi')
    C.order('ctr')
    rg = C.r
    base = rg.get('base')
    # ---- helpers for the address -----------------------------------------------------------------------------
    pre = []
    if es == 1:
        if I == 'a':
            ad = rg['addr']
            pre += ['lda %s,%s' % (X(base), H), 'ld %s,(XSP+0x4)' % ad, 'extz %s' % X(ad), 'add %s,%s' % (X(ad), X(base))]
            mode = '(%s)' % X(ad)
        elif I == 'b':
            ad = rg['addr']
            if ad == 'WA':
                pre += ['lda %s,%s' % (X(base), H), 'ld %s,0x0' % X(ad), 'ld A,(XSP+0x4)', 'add %s,%s' % (X(ad), X(base))]
            else:
                pre += ['lda %s,%s' % (X(base), H), 'ld A,(XSP+0x4)', 'ld %s,0x0' % X(ad), 'ld %s,A' % LOW[ad],
                        'add %s,%s' % (X(ad), X(base))]
            mode = '(%s)' % X(ad)
        elif I == 'c':
            ix = rg['idx']
            if ix == 'WA':
                pre += ['ld A,(XSP+0x4)', 'extz WA']
            else:
                pre += ['ld A,(XSP+0x4)', 'ld %s,A' % LOW[ix], 'extz %s' % ix]
            pre += ['lda %s,%s' % (X(base), H)]
            mode = '(%s+%s)' % (X(base), ix)
        elif I == 'L':
            pre += ['lda %s,%s' % (X(base), H)]
            mode = '(%s+%s)' % (X(base), rg['ctr'])
        else:
            lc = rg['loc']
            pre += ['ld %s,(_gi)' % lc, 'lda %s,%s' % (X(base), H)]
            mode = '(%s+%s)' % (X(base), lc)
    else:
        ix = rg['idx']
        op = (lambda r, src=None: 'add %s,%s' % (r, src or r)) if es == 2 else (lambda r, src=None: 'sla 0x2,%s' % r)
        if I == 'a':
            pre += ['ld %s,(XSP+0x4)' % ix, op(ix)]
            mi = ix
        elif I == 'b':
            pre += ['ld A,(XSP+0x4)', ('add A,(XSP+0x4)' if es == 2 else 'sla 0x2,A')]
            if ix != 'WA':
                pre += ['ld %s,A' % LOW[ix]]
                mi = LOW[ix]
            else:
                mi = 'A'
        elif I == 'c':
            pre += ['ld A,(XSP+0x4)', 'extz WA']
            if ix != 'WA':
                pre += ['ld %s,WA' % ix]
            pre += [op(ix)]
            mi = ix
        elif I == 'L':
            pre += ['ld %s,%s' % (ix, rg['ctr']), op(ix)]
            mi = ix
        else:
            pre += ['ld %s,(_gi)' % ix, op(ix)]
            mi = ix
        pre += ['lda %s,%s' % (X(base), H)]
        mode = '(%s+%s)' % (X(base), mi)
    # ---- value ------------------------------------------------------------------------------------------------
    val = rg.get('val')
    vr = reg_of(val, es) if val else None
    body = []
    glob = sy['g']
    store_in = None

    def vload(r):
        """instructions computing the value into r (a register operand of the element's width)"""
        if V == 'G':
            return ['ld %s,(%s)' % (r, sy['v'])]
        if V == 'S':
            return ['ld %s,(%s + %s)' % (r, H, hx(es))]
        if V == 'E':
            return ['ld %s,%s' % (r, mode)]
        if V == 'N':
            ins = ['cpw (_gi),0x0', 'scc eq,%s' % val]
            if es == 4:
                ins.append('exts %s' % X(val))
            return ins
        if V == 'B':
            w3 = '(%s + %s)' % (sy['w'], hx(3 * es))
            if es == 1:
                ins = ['ld A,%s' % w3, 'add A,(%s)' % sy['v']]
                ins += (['exts WA', 'divs WA,0x10', 'ld A,W'] if SIGNED[t] else ['and A,0xf'])
            elif es == 2:
                ins = ['ld WA,%s' % w3, 'add WA,(%s)' % sy['v']]
                ins += (['exts XWA', 'divs XWA,0x10', 'ld WA,QWA'] if SIGNED[t] else ['and WA,0xf'])
            else:
                ins = ['ld XWA,%s' % w3, 'add XWA,(%s)' % sy['v'], 'and XWA,0xf']
            return ins
        raise KeyError(V)

    out_pre = []
    out_tail = []
    # --- the outer destination ---
    pr = rg.get('ptr')
    ptr_load = None
    if ptr_kind:
        ptr_load = 'ld %s,(%s)' % (X(pr), sy['p'] if ptr_kind == 'P' else '_gps')
        odst = '(%s)' % X(pr) if not off else '(%s+%s)' % (X(pr), hx(off))
    elif outer == 'M':
        odst = '(_gs%s)' % (' + ' + hx(GS_OFF[t]) if GS_OFF[t] else '')
    elif outer == 'E':
        odst = '(%s + %s)' % ('_g%sa' % t, hx(2 * es))
    elif outer == 'G':
        odst = '(%s)' % glob
    else:
        odst = None
    ins = []
    if ctxc:
        return ctx_tail(t, I, V, outer, pre, mode, rg, ptr_load, vr, C, sy)
    if V == 'K':
        if es == 4:
            ins += ['ld XWA,%s' % hx(konst), 'ld %s,XWA' % mode, 'ld XWA,%s' % hx(konst)]
            tail_reg = 'XWA'
        else:
            ins += ['%s %s,%s' % ('ldb' if es == 1 else 'ldw', mode, hx(konst))]
            tail_reg = None
    else:
        ins += vload(vr)
        ins.append('ld %s,%s' % (mode, vr))
        tail_reg = vr
    # ---------------------------------------------------------------- outer stores
    if outer == 'G':
        if V == 'K' and es != 4:
            ins.append('%s %s,%s' % ('ldb' if es == 1 else 'ldw', odst, hx(konst)))
        else:
            ins.append('ld %s,%s' % (odst, tail_reg))
    elif outer in 'MEPD':
        if V == 'K' and es != 4:
            r = reg_of(val, es)
            ins += ['ld %s,%s' % (r, hx(konst))]
            tail_reg = r
        if ptr_late:
            ins.append(ptr_load)
        ins.append('ld %s,%s' % (odst, tail_reg))
    return pre, ins, rg, mode, ptr_load, ptr_late, C, vr, tail_reg


def wrap_loop(rg, body, call=False):
    c = rg['ctr']
    return ['ld %s,0x0' % c, 'cp %s,0x4' % c, 'ret ge', 'L1:'] + body + ['inc 0x1,%s' % c, 'cp %s,0x4' % c, 'j lt,L1', 'L2:', 'ret']


def long_b_special(t, I):
    """long (signed) B: the remainder is a library call; the destination address is kept in XIZ"""
    sy = sinfo(t)
    H = sy['arr']
    if I == 'a':
        idx = ['ld WA,(XSP+0x8)', 'sla 0x2,WA']; m = 'WA'
    elif I == 'b':
        idx = ['ld A,(XSP+0x8)', 'sla 0x2,A']; m = 'A'
    elif I == 'c':
        idx = ['ld A,(XSP+0x8)', 'extz WA', 'sla 0x2,WA']; m = 'WA'
    else:
        idx = ['ld WA,(_gi)', 'sla 0x2,WA']; m = 'WA'
    return (['push XIZ'] + idx + ['lda XBC,%s' % H, 'lda XIZ,XBC+%s' % m,
            'ld XWA,(%s + 0xc)' % sy['w'], 'add XWA,(%s)' % sy['v'], 'ld XBC,0x10', 'cal C9H_remls',
            'ld (XIZ),XHL', 'ld (%s),XHL' % sy['g'], 'pop XIZ', 'ret'])


def long_b_loop(t):
    sy = sinfo(t)
    return ['dec 0x4,XSP', 'push IZ', 'ld IZ,0x0', 'cp IZ,0x4', 'j ge,L1', 'L2:', 'ld WA,IZ', 'sla 0x2,WA',
            'lda XBC,%s' % sy['arr'], 'exts XWA', 'add XWA,XBC', 'ld (XSP+0x2),XWA',
            'ld XWA,(%s + 0xc)' % sy['w'], 'add XWA,(%s)' % sy['v'], 'ld XBC,0x10', 'cal C9H_remls',
            'ld XWA,(XSP+0x2)', 'ld (XWA),XHL', 'ld (%s),XHL' % sy['g'], 'inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L2',
            'L1:', 'pop IZ', 'inc 0x4,XSP', 'ret']


def split_name(name):
    n = name.lstrip('_')
    m = re.match(r'bc_([abc])_(.*)$', n)
    return m.group(1), m.group(2)


def bc0_predict(name):
    fam, rest = split_name(name)
    t, I = rest[0], rest[1]
    tail = rest[2:]
    if fam == 'a':
        V = tail
        if V == 'B' and t == 'l':
            if I == 'L':
                return long_b_loop(t)
            return long_b_special(t, I)
        pre, ins, rg, mode, pl, late, C, vr, tr = gen(t, I, V, 'G')
        body = pre + ins
        if I == 'L':
            return wrap_loop(rg, body)
        return body + ['ret']
    if fam == 'b':
        L1, V = tail[0], tail[1]
        pre, ins, rg, mode, pl, late, C, vr, tr = gen(t, I, V, L1)
        if pl and not late:
            pre = [pl] + pre
        body = pre + ins
        if I == 'L':
            return wrap_loop(rg, body)
        return body + ['ret']
    return predict_c(t, I, tail)


def ctx_tail(t, I, V, outer, pre, mode, rg, ptr_load, vr, C, sy):
    """family c: the assignment is used as a value.  Returns the whole function body (with loop wrapper)."""
    es = ES[t]
    loop = I == 'L'
    val = rg.get('val')
    ctr = rg.get('ctr')
    head = []                      # inside the loop body / function start, before the address
    if outer in 'CA' and t in 'wln':
        gi = rg['gi']
        head.append('ld %s,(_gi)' % (gi if es == 2 else gi))
        if es == 4:
            head.append('exts %s' % X(gi))
    if outer == 'R':
        head.append(ptr_load)
    body = []
    if outer in 'CA':
        if es == 4:
            body += ['ld XWA,0x2', 'ld %s,XWA' % mode, 'ld XWA,0x2', 'cp XWA,%s' % X(rg['gi'])]
        else:
            body += ['%s %s,0x2' % ('ldb' if es == 1 else 'ldw', mode), 'ld %s,0x2' % val,
                     'cp %s,%s' % (val, rg['gi'] if t == 'w' else '(_gi)')]
        tail = 'cond'
    elif outer == 'R':
        r = reg_of('HL', es)
        body += ['ld %s,%s' % (r, mode), 'ld (%s),%s' % (X(rg['ptr']), r)]
        tail = 'plain'
    elif outer == 'K':
        body += ['ld %s,(%s)' % (vr, sy['v']), 'ld %s,%s' % (mode, vr)]
        if es == 1:
            if vr != 'A':
                body.append('ld A,%s' % vr)
            body += ['%s WA' % ('exts' if SIGNED[t] else 'extz'), 'push WA']
        else:
            body.append('push %s' % reg_of(val, es))
        body += ['cal _sk%s' % t, 'inc 0x%x,XSP' % (2 if es <= 2 else 4)]
        tail = 'call'
    else:                          # V
        body += ['ld %s,(%s)' % (vr, sy['v']), 'ld %s,%s' % (mode, vr)]
        tail = 'init'
    if not loop:
        out = []
        if outer == 'A':
            out += ['cpw (_gi),0x5', 'ret ge']
        out += head + pre + body
        if tail == 'cond':
            out += ['ret ne', 'ldw (_gi3),0x1', 'L1:', 'ret']
        elif tail == 'init':
            if es == 1:
                if vr != 'A':
                    out.append('ld A,%s' % vr)
                out += ['%s WA' % ('exts' if SIGNED[t] else 'extz'), 'ld (_gi3),WA', 'ret']
            else:
                out += ['ld (_gi3),%s' % reg_of(val, 2), 'ret']
        else:
            out += ['ret']
        return out
    # loops
    if tail == 'call':
        return (['push IZ', 'ld IZ,0x0', 'cp IZ,0x4', 'j ge,L1', 'L2:'] + head + pre + body +
                ['inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L2', 'L1:', 'pop IZ', 'ret'])
    if tail == 'init':
        if es == 1:
            return (['ld A,0x0', 'ld %s,0x0' % ctr, 'cp %s,0x4' % ctr, 'j ge,L1', 'L2:'] + head + pre + body +
                    ['ld A,%s' % vr, 'inc 0x1,%s' % ctr, 'cp %s,0x4' % ctr, 'j lt,L2', 'L1:',
                     '%s WA' % ('exts' if SIGNED[t] else 'extz'), 'ld (_gi3),WA', 'ret'])
        return (['ld %s,0x0' % reg_of(val, es), 'ld %s,0x0' % ctr, 'cp %s,0x4' % ctr, 'j ge,L1', 'L2:'] + head + pre + body +
                ['inc 0x1,%s' % ctr, 'cp %s,0x4' % ctr, 'j lt,L2', 'L1:', 'ld (_gi3),%s' % reg_of(val, 2), 'ret'])
    pr = ['ld %s,0x0' % ctr, 'cp %s,0x4' % ctr, 'ret ge', 'L1:']
    if outer == 'A':
        pr += ['cpw (_gi),0x5', 'j ge,L2']
    if tail == 'cond':
        return (pr + head + pre + body + ['j ne,L2', 'ldw (_gi3),0x1', 'L2:', 'inc 0x1,%s' % ctr, 'cp %s,0x4' % ctr,
                                           'j lt,L1', 'L3:', 'ret'])
    return []


def predict_c(t, I, X_):
    return gen(t, I, 'G', X_)


# ==============================================================================================================
# er_*, the other sets
# ==============================================================================================================
ES = {'c': 1, 'u': 1, 'i': 2, 'w': 2, 'l': 4, 'n': 4}
UNS = set('uwn')
OPS = {'p': 'add', 's': 'sub', 'o': 'or', 'a': 'and', 'x': 'xor', 'm': 'muls'}
W = {1: 'b', 2: '', 4: 'x'}          # register spec of a value of s bytes


def hx(n):
    return '0x%x' % n


def scale_ins(b, s, r, spec=''):
    """scale the index temp r (spec '' 16-bit, 'b' byte, 'x' 32-bit) by s"""
    if s == 2:
        b.e('add {%s%s},{%s%s}' % (r, ':' + spec if spec else '', r, ':' + spec if spec else ''))
    elif s == 4:
        b.e(('sll 0x2,{%s:x}' % r) if spec == 'x' else ('sla 0x2,{%s%s}' % (r, ':' + spec if spec else '')))


def xr_elem(b, s, I, arr, opt=False, zbase=False, kept=True):
    """-Xr: the element arr[p] with the index parameter p pre-coloured; returns the memory operand.
    opt (-O3 -XS -Xr): an unsigned char index is copied before it is extended; zbase: the base is formed early
    (after a leading copy of the parameter) and kept for a second element"""
    k0 = len(b.seq)
    mode = _xr_elem(b, s, I, arr, opt)
    if zbase:
        seq = b.seq[k0:]
        lda = [x for x in seq if x.text.startswith(('lda {B:x}', 'ld {AD:x},_'))]
        if lda:
            x = lda[0]
            if x.text.startswith('ld {AD:x},_'):     # an unsigned index: the base kept, the sum built from a copy
                k = seq.index(x)
                seq[k] = Ins('ld {AD:x},{B:x}', copy=('AD', 'B'))
                x = Ins('lda {B:x},%s' % arr)
                seq.insert(k, x)
            seq.remove(x)
            pos = 1 if kept and I in 'ac' and seq and seq[0].copy and seq[0].copy[1] == 'p' else 0
            seq.insert(pos, x)
            b.seq[k0:] = seq
    return mode


def _xr_elem(b, s, I, arr, opt=False):
    if s == 1:
        if I == 'a':
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p})'
        if I == 'b':
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p:b})'
        if I == 'c':
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.e('extz {IX}')
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{IX})'
        if I == 'd':
            b.e('ld {IX},{p}', copy=('IX', 'p'))
            b.e('extz {IX:x}')
            b.e('ld {AD:x},%s' % arr)
            b.e('add {AD:x},{IX:x}')
            return '({AD:x})'
    if I == 'a':
        b.e('ld {IX},{p}', copy=('IX', 'p'))
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'b':
        b.w(IX=8, Z=8)
        if s == 2:
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.e('add {IX:b},{p:b}')
            b.early.append('IX')
        else:
            b.e('ld {Z:b},{p:b}', copy=('Z', 'p'))
            b.e('sla 0x2,{Z:b}')
            b.e('ld {IX:b},{Z:b}', copy=('IX', 'Z'))
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX:b})'
    if I == 'c' and opt:
        b.w(IX=16)
        b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
        b.e('extz {IX}')
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'c':
        b.e('ld {Z},{p}', copy=('Z', 'p'))
        b.e('extz {Z}')
        if s == 4:
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.e('sla 0x2,{IX}')
        else:
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.e('add {IX},{IX}')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'd':
        b.e('ld {IX},{p}', copy=('IX', 'p'))
        b.e('extz {IX:x}')
        scale_ins(b, s, 'IX', 'x')
        b.e('ld {AD:x},%s' % arr)
        b.e('add {AD:x},{IX:x}')
        return '({AD:x})'
    raise KeyError(I)


def pwidth(I):
    return 8 if I in 'bc' else 16


def left_src(t, L):
    s = ES[t]
    return {'K': '0x7', 'G': '(_h%s)' % t, 'Z': '(_h%sa + %s)' % (t, hx(s)), 'C': '(_h%s)' % t}[L]


def binop_xr(t, I, L, o, opt=False):
    s = ES[t]
    sp = W[s]
    V = '{V:%s}' % sp if sp else '{V}'
    b = Body()
    b.w(p=pwidth(I), V=8 * s if s != 2 else 16)
    arr = '_h%sa' % t
    mn = OPS[o]
    E = (o == 'o' and L in 'KZ')
    zb = opt and L == 'Z'
    opd = xr_elem(b, s, I, arr, opt=opt, zbase=zb, kept=not E)
    left = '({B:x}+%s)' % hx(s) if zb else left_src(t, L)
    if E:
        b.e('ld %s,%s' % (V, opd))
        b.e('%s %s,%s' % (mn, V, left))
    else:
        b.e('ld %s,%s' % (V, left))
        if L == 'C':
            b.e('dec 0x3,%s' % V)
        if mn == 'muls':
            b.e('muls %s,%s' % ('{V}' if s == 1 else '{V:x}', opd))
        else:
            b.e('%s %s,%s' % (mn, V, opd))
    b.e('ld (_g%s),%s' % (t, V))
    out = b.colour(fixed={'p': 'WA'}, first=['V'] + (b.early + ['B'] if zb else []), pref={'V': 'WA'})
    return out + ['ret']


def kind(n):
    p = n.split('_')
    if p[1] == 'd':
        return p[3][1]
    if p[1] == 'k':
        return p[2][3]
    if p[1] == 'e':
        return p[2][2] if p[2][1] != 'R' else 'R' + p[2][2]
    return p[2][1]


def er_predict(n, S):
    m = re.match(r'er_([a-ek])_(.*)$', n)
    fam, rest = m.group(1), m.group(2)
    I = kind(n)
    xr = S in ('Xr', 'O3XSXr')
    if S == 'none':
        return er0_predict(n)
    if S == 'Xr' and I not in 'abcd' and I not in ('Ra', 'Rb', 'Aa', 'Ab', 'Ma', 'Mb', 'Da', 'Db', 'Qa', 'Qb'):
        if fam == 'b' and rest[2] == 'A':
            return xr_loop_calls(er0_predict(n))
        if I in ('Ra', 'Rb', 'RL'):
            return fam_e_xr(rest[0], rest[1], rest[2], rest[3]) if I != 'RL' else fam_e_xr_loop(rest[0], rest[3])
        return er0_predict(n)
    if S == 'Xr':
        if fam == 'c' and rest[0] == 'n' and rest[3] == 'm':
            return mulu_xr(rest[1], rest[2])
        if fam == 'd':
            m2 = re.match(r's([123])_(.)(.)$', rest)
            return fam_d_xr(m2.group(1), m2.group(2), m2.group(3))
        if fam in 'ac' and not (rest[0] == 'n' and rest[3] == 'm'):
            return binop_xr(rest[0], rest[1], rest[2], rest[3])
        if fam == 'b':
            return fam_b_xr(rest[0], rest[1], rest[2], rest[3])
        if fam == 'e':
            return fam_e_xr(rest[0], rest[1], rest[2], rest[3])
        if fam == 'k':
            if rest[0] == rest[1]:
                return binop_xr(rest[0], rest[3], 'G', rest[2])
            return fam_k_xr(rest[0], rest[1], rest[2], rest[3])
    if S == 'O3XSXr' and (I in 'abcd' or I in ('Ra', 'Rb', 'RL', 'Aa', 'Ab', 'Ma', 'Mb', 'Da', 'Db', 'Qa', 'Qb')):
        if fam == 'c' and rest[0] == 'n' and rest[3] == 'm':
            out = mulu_o3(rest[1], rest[2])
            return [x for x in out if x not in ('ld A,(XSP+0xa)', 'ld A,(XSP+0x4)')] if rest[1] == 'b' else None
        if fam in 'ac':
            return binop_xr(rest[0], rest[1], rest[2], rest[3], opt=True)
        if fam == 'b':
            return fam_b_xr(rest[0], rest[1], rest[2], rest[3], xo=True)
        if fam == 'd':
            m2 = re.match(r's([123])_(.)(.)$', rest)
            return fam_d_xo(m2.group(1), m2.group(2), m2.group(3))
        if fam == 'e':
            if I == 'RL':
                return fam_e_xo_loop(rest[0], rest[3])
            if rest[1] == 'A':
                return binop_xr(rest[0], rest[2], rest[3], 's', opt=True)
            return fam_e_xr(rest[0], rest[1], rest[2], rest[3], xo=True)
        if fam == 'k':
            if rest[0] == rest[1]:
                return binop_xr(rest[0], rest[3], 'G', rest[2], opt=True)
            return fam_k_o3(rest[0], rest[1], rest[2], rest[3], xo=True)
        return None
    if S == 'O3XSXr' and fam == 'b' and rest[2] == 'A':
        return fam_b_xr(rest[0], rest[1], rest[2], rest[3], loop=True, o3=True, xcall=True)
    if S == 'O3XSXr' and fam == 'k' and I == 'L' and rest[0] == rest[1]:
        return er_predict(n, 'O3XS')
    if S == 'O3XSXr':
        S = 'O3XS'
    if S == 'O3XS':
        if fam == 'b' and I != 'L':
            return fam_b_xr(rest[0], rest[1], rest[2], rest[3], o3=True)
        if fam == 'b' and rest[2] == 'A':
            return fam_b_xr(rest[0], rest[1], rest[2], rest[3], loop=True, o3=True)
        if fam == 'b':
            return fam_b_o3_loop(rest[0], rest[2], rest[3])
        if fam == 'd':
            m2 = re.match(r's([123])_(.)(.)$', rest)
            return fam_d_o3(m2.group(1), m2.group(2), m2.group(3))
        if fam == 'e':
            return fam_e_o3(rest[0], rest[1], rest[2], rest[3])
        if fam == 'k':
            if rest[0] == rest[1]:
                if rest[3] == 'L':
                    return binop_o3_loop(rest[0], 'G', rest[2])
                return binop_o3(rest[0], rest[3], 'G', rest[2])
            return fam_k_o3(rest[0], rest[1], rest[2], rest[3])
        if fam == 'c' and rest[0] == 'n' and rest[3] == 'm':
            return mulu_o3(rest[1], rest[2])
        if fam in 'ac' and not (rest[0] == 'n' and rest[3] == 'm'):
            if I == 'L':
                return binop_o3_loop(rest[0], rest[2], rest[3])
            return binop_o3(rest[0], rest[1], rest[2], rest[3])
    return None


MOFF = {'c': 0, 'u': 0xa, 'i': 0x14, 'w': 0x26, 'l': 0x38, 'n': 0x5c}


def fam_b_xr(t, I, D, L, loop=False, o3=False, xo=False, xcall=False):
    """-Xr, index parameter p: D <- L - h<t>a[idx] (t = i or n)"""
    s = ES[t]
    sp = 'x' if s == 4 else ''
    R = lambda n: '{%s:x}' % n if s == 4 else '{%s}' % n
    b = Body()
    b.w(p=pwidth(I))
    for n in ('V', 'NV', 'A0'):
        b.w(**{n: 32 if s == 4 else 16})
    arr = '_h%sa' % t
    first, pref, fixed = [], {}, {'p': 'WA'}
    nocoal = []
    if (o3 or xo) and D == 'V' and not loop:
        return ['ret']
    if L == 'D':
        b.e('ld {P:x},(_hps)')
    k_el = len(b.seq)
    if o3:
        fixed = {'ctr': 'IZ'} if loop else {}
        b.regime = 'F' if (D == 'G' or L in 'DN') else 'E'
        opd = o3_elem(b, s, I, arr, zbase=(L == 'E'), first=first)
    else:
        opd = xr_elem(b, s, I, arr, opt=xo, zbase=xo and L == 'E', kept=D in 'GA')
        if xo and L == 'D' and I == 'a' and D in 'GA':    # -O: a kept copy of the index parameter goes first
            x = b.seq[k_el]
            if x.copy and x.copy[1] == 'p':
                del b.seq[k_el]
                b.seq.insert(0, x)
    V = 'V'
    if L == 'G':
        b.e('ld %s,(_h%s)' % (R('V'), t))
    elif L == 'E':
        b.e('ld %s,%s' % (R('V'), ('({B:x}+%s)' if (o3 or xo) else '(_h%sa + %%s)' % t) % hx(3 * s)))
    elif L == 'D':
        b.e('ld %s,({P:x}+%s)' % (R('V'), hx(MOFF[t])))
    else:
        if s == 2:
            b.e('cpw (_h%s),0x0' % t)
            b.e('scc eq,{NV}')
        else:
            b.e('ld {NV:x},(_h%s)' % t)
            b.e('or {NV:x},{NV:x}')
            b.e('scc eq,{NV}')
            b.e('exts {NV:x}')
        first.append('NV')
        pref['NV'] = 'WA'
        if D == 'R' and (o3 or xo):
            V = 'NV'
            if s == 2:
                fixed['NV'] = 'HL'
        elif D in 'QR':
            b.e('ld %s,%s' % (R('V'), R('NV')), copy=('V', 'NV'))
            nocoal.append('V')
        else:
            V = 'NV'
    b.e('sub %s,%s' % (R(V), opd))
    if D == 'G' and L in 'GE':
        first.insert(0, V)
        pref[V] = 'WA'
    if D == 'G' and L == 'D':
        first.insert(0, V)
        pref[V] = 'WA'
    if D == 'R' and not ((o3 or xo) and L == 'N' and s == 4):
        fixed[V] = 'HL'
    if xo and D == 'A':
        first.insert(0, V)
        pref[V] = 'WA'
    if o3 and D == 'Q' and (L == 'N' or (L == 'D' and I == 'a')):
        pref['V'] = 'HL'
    if D == 'G':
        b.e('ld (_g%s),%s' % (t, R(V)))
    elif D == 'E':
        b.e('ld (_g%sa + %s),%s' % (t, hx(2 * s), R(V)))
    elif D == 'M':
        b.e('ld (_gs + %s),%s' % (hx(MOFF[t]), R(V)))
    elif D in 'PQ':
        b.e('ld {Q:x},(_g%sp)' % t)
        if xo and D == 'Q':
            first.append('Q')
        b.e('ld ({Q:x}%s),%s' % ('' if D == 'P' else '+' + hx(2 * s), R(V)))
    elif D == 'A' and o3 and xcall:          # -Xr: the argument in WA / XWA
        b.e('cal .sk%s' % t)
        first.insert(0, V)
        pref[V] = 'WA'
    elif D == 'A' and o3:
        b.e('push %s' % R(V))
        b.e('cal _sk%s' % t)
        b.e('inc %s,XSP' % hx(s))
    elif D == 'A':
        b.e('ld %s,%s' % (R('A0'), R(V)), copy=('A0', V))
        fixed['A0'] = 'WA'
    elif D == 'C':
        b.e('cp %s,0x3' % R(V))
    if o3:
        pref.setdefault('Y', 'WA')
        pref.setdefault('T8', 'WA')
    if xo and L == 'E':
        first = first + b.early + ['B']
    av = {'V': ['NV']}
    if xo and L == 'D' and D in 'GA':
        first = first + b.early + ['P']
        av['P'] = [V]
    out = b.colour(fixed=fixed, first=first, pref=pref, nocoalesce=nocoal, avoid=av,
                   params=('p', 'p2', 'p3', 'ctr'), live={'ctr': (-1, len(b.seq) + 1)} if loop else None)
    if o3 and loop:
        out = backprop(forward(out))
        return ['push IZ', 'ld IZ,0x0', 'L1:'] + out + ['inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L1', 'pop IZ', 'ret']
    if o3 or xo:
        out = backprop(forward(out))
        if D == 'R' and L == 'N' and s == 4:
            out.append('ld XHL,%s' % ('X' + b.reg['NV']))
    if D == 'A' and o3:
        return out + ['ret']
    if D == 'A':
        return out + ['j .sk%s' % t]
    if D == 'C':
        return out + ['ret %s' % ('ule' if t in UNS else 'le'), 'ldw (_gi3),0x1', 'L1:', 'ret']
    return out + ['ret']


def xr_loop_calls(lines):
    """-Xr: a sink call inside a loop takes its argument in WA / XWA, no stack argument"""
    out = []
    i = 0
    while i < len(lines):
        x = lines[i]
        m = re.match(r'push (X?)(\w+)$', x)
        if m and i + 2 < len(lines) and lines[i + 1].startswith('cal _sk') and lines[i + 2].startswith('inc '):
            r = m.group(1) + m.group(2)
            acc = m.group(1) + 'WA'
            if r != acc:
                out.append('ld %s,%s' % (acc, r))
            out.append('cal .' + lines[i + 1][5:])
            i += 3
            continue
        out.append(x)
        i += 1
    return out


def xr_elem_base(b, s, I, B, t, xo=False):
    """-Xr: the element of base kind B (A M D Q R) at the index parameter; returns (operand, first-order hints)"""
    if B in 'AM':
        arr = '_h%sa' % t if B == 'A' else '_hs + %s' % hx(AOFF[t])
        return xr_elem(b, s, I, arr), []
    if B == 'D':
        off = AOFF[t]
        if s == 1:
            b.w(Y=pwidth(I))
            b.e('ld {Y},{p}' if I == 'a' else 'ld {Y:b},{p:b}', copy=('Y', 'p'))
            b.e('inc %s,{Y%s}' % (hx(off), '' if I == 'a' else ':b'))
        elif I == 'a':
            b.e('ld {Y},{p}', copy=('Y', 'p'))
            b.e('add {Y},{Y}')
            b.e('add {Y},%s' % hx(off))
        else:
            b.w(IX=8, Y=8)
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.e('add {IX:b},{p:b}')
            b.early.append('IX')
            if xo:                   # -O: the offset is added in the index register itself
                b.e('add {IX:b},%s' % hx(off))
                b.w(IE=8)
                b.e('ld {IE:b},{IX:b}', copy=('IE', 'IX'))
                b.nocoal.append('IE')
                b.e('ld {B:x},(_hps)')
                return '({B:x}+{IE:b})', ['B']
            b.e('ld {Y:b},{IX:b}', copy=('Y', 'IX'))
            b.e('add {Y:b},%s' % hx(off))
            b.nocoal.append('Y')
        b.w(IE=8)
        b.e('ld {IE:b},{Y:b}', copy=('IE', 'Y'))
        b.nocoal.append('IE')
        b.e('ld {B:x},(_hps)')
        return '({B:x}+{IE:b})', ['B']
    if B == 'Q':
        if s == 1:
            b.e('ld {B:x},(_g%sp)' % t)
            return '({B:x}+{p%s})' % ('' if I == 'a' else ':b'), []
        if I == 'a':
            b.e('ld {IX},{p}', copy=('IX', 'p'))
            b.e('exts {IX:x}')
            scale_ins(b, s, 'IX', 'x')
            b.e('ld {AD:x},{IX:x}', copy=('AD', 'IX'))
            b.nocoal.append('AD')
            b.e('add {AD:x},(_g%sp)' % t)
            return '({AD:x})', []
        if xo:                       # -O: the char index is copied out of A first, then extended
            b.w(IX=16)
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.nocoal.append('IX')
            b.e('exts {IX}')
        else:
            b.e('ld {Z},{p}', copy=('Z', 'p'))
            b.e('exts {Z}')
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.nocoal.append('IX')
        scale_ins(b, s, 'IX')
        b.e('ld {B:x},(_g%sp)' % t)
        return '({B:x}+{IX})', ['B']
    # R: the pointer parameter p (XWA) and the index parameter p2 (BC / C)
    if s == 1:
        return '({p:x}+{p2%s})' % ('' if I == 'a' else ':b'), []
    if I == 'a':
        b.e('ld {IX},{p2}', copy=('IX', 'p2'))
        b.e('exts {IX:x}')
        scale_ins(b, s, 'IX', 'x')
        b.e('add {IX:x},{p:x}')
        return '({IX:x})', []
    if xo:
        b.w(IX=16)
        b.e('ld {IX:b},{p2:b}', copy=('IX', 'p2'))
        b.nocoal.append('IX')
        b.e('exts {IX}')
    else:
        b.e('ld {Z},{p2}', copy=('Z', 'p2'))
        b.e('exts {Z}')
        b.e('ld {IX},{Z}', copy=('IX', 'Z'))
        b.nocoal.append('IX')
    scale_ins(b, s, 'IX')
    return '({p:x}+{IX})', []


AOFF = {'c': 2, 'u': 0xc, 'i': 0x16, 'w': 0x28, 'l': 0x3c, 'n': 0x60}


def fam_e_xr(t, B, I, L, xo=False):
    s = ES[t]
    sp = W[s]
    V = '{V:%s}' % sp if sp else '{V}'
    b = Body()
    b.nocoal = []
    b.w(V=8 * s if s != 2 else 16)
    fixed = {}
    if B == 'R':
        b.w(p=32, p2=pwidth(I))
        fixed = {'p': 'WA', 'p2': 'BC'}
    else:
        b.w(p=pwidth(I))
        fixed = {'p': 'WA'}
    opd, hint = xr_elem_base(b, s, I, B, t, xo=xo)
    b.e('ld %s,%s' % (V, '0x7' if L == 'K' else '(_h%s)' % t))
    b.e('sub %s,%s' % (V, opd))
    b.e('ld (_g%s),%s' % (t, V))
    out = b.colour(fixed=fixed, first=['V'] + hint, pref={'V': 'WA'}, nocoalesce=b.nocoal)
    return out + ['ret']


def fam_k_xr(t, R, o, I):
    """gR = (R)hR o (R)h<t>a[p], t != R"""
    s = ES[t]
    b = Body()
    b.w(p=pwidth(I), EV=8 * s if s != 2 else 16, C8=8, A8=8, ZN=16 if s == 2 else 32, V=32)
    if s == 1:
        b.w(ZN=32)
    EV = {1: '{EV:b}', 2: '{EV}', 4: '{EV:x}'}[s]
    opd = xr_elem(b, s, I, '_h%sa' % t)
    ext = 'extz' if t in UNS else 'exts'
    first, pref = [], {}
    if R == 'c':
        if o == 's':
            if s == 1:
                b.e('ld {C8:b},%s' % opd)
            else:
                b.e('ld %s,%s' % (EV, opd))
                b.e('ld {C8:b},{EV:b}', copy=('C8', 'EV'))
                pref['EV'] = 'WA'
            b.e('ld {A8:b},(_hc)')
            b.e('sub {A8:b},{C8:b}')
            b.e('ld (_gc),{A8:b}')
            first = ['A8']
            pref['A8'] = 'WA'
        else:
            b.e('ld %s,%s' % (EV, opd))
            b.e('or {EV:b},(_hc)')
            b.e('ld (_gc),{EV:b}')
            first = ['EV']
            pref['EV'] = 'WA'
    else:
        if o == 's':
            if s == 1:
                b.e('ld {EV:b},%s' % opd)
                b.e('ld {ZN:x},0x0')
                b.e('ld {ZN:b},{EV:b}')
            elif s == 2:
                b.e('ld {ZN},%s' % opd)
                b.e('%s {ZN:x}' % ext)
            else:
                b.e('ld {ZN:x},%s' % opd)
            b.e('ld {V:x},(_hn)')
            b.e('sub {V:x},{ZN:x}')
            b.e('ld (_gn),{V:x}')
            first = ['V']
            pref = {'V': 'WA', 'EV': 'WA'}
        else:
            b.w(EV=32)
            if s == 1:
                b.e('ld {EV:b},%s' % opd)
                b.e('extz {EV}')
                b.e('extz {EV:x}')
            elif s == 2:
                b.e('ld {EV},%s' % opd)
                b.e('%s {EV:x}' % ext)
            else:
                b.e('ld {EV:x},%s' % opd)
            b.e('or {EV:x},(_hn)')
            b.e('ld (_gn),{EV:x}')
            first = ['EV']
            pref = {'EV': 'WA'}
    out = b.colour(fixed={'p': 'WA'}, first=first, pref=pref, avoid={'C8': ['EV']})
    return out + ['ret']


def fam_e_xr_loop(t, L):
    """-Xr, er_e R base with the loop counter: gT = L - p[i]"""
    s = ES[t]
    b = Body()
    b.w(p=32, V=8 * s if s != 2 else 16)
    V = '{V:b}' if s == 1 else '{V}'

    def body():
        if s == 1:
            opd = '({p:x}+{ctr})'
        else:
            b.e('ld {IX},{ctr}', copy=('IX', 'ctr'))
            b.e('exts {IX:x}')
            scale_ins(b, s, 'IX', 'x')
            b.e('ld {AD:x},{IX:x}', copy=('AD', 'IX'))
            b.e('add {AD:x},{p:x}')
            opd = '({AD:x})'
        b.e('ld %s,%s' % (V, '0x7' if L == 'K' else '(_h%s)' % t))
        b.e('sub %s,%s' % (V, opd))
        b.e('ld (_g%s),%s' % (t, V))
    live = loop(b, body)
    live['p'] = (-1, len(b.seq))
    return b.colour(fixed={'p': 'WA'}, first=['V'], pref={'V': 'WA'}, live=live, last=['ctr'],
                    nocoalesce=['IX', 'AD'], avoid={'AD': ['IX']})


def fam_d_xr(shape, t, I):
    s = ES[t]
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    b.nocoal = []
    b.w(p=pwidth(I))
    for n in ('V', 'S', 'D'):
        b.w(**{n: {1: 8, 2: 16, 4: 32}[s]})
    arr = '_h%sa' % t
    first = ['V']
    if shape == '2':
        opd = xr_elem(b, s, I, arr)
        b.e('ld %s,(_v%s)' % (R('D'), t))
        b.e('sub %s,%s' % (R('D'), opd))
        b.e('ld %s,(_h%s)' % (R('V'), t))
        b.e('sub %s,%s' % (R('V'), R('D')))
        b.e('ld (_g%s),%s' % (t, R('V')))
        if s == 1:
            first = ['V', 'D']
        return b.colour(fixed={'p': 'WA'}, first=first, pref={'V': 'WA'}) + ['ret']
    if shape == '3':
        b.e('ld {Q:x},(_g%sp)' % t)
        if s == 1:
            opd = '({Q:x}+{p%s})' % ('' if I == 'a' else ':b')
        elif I == 'a':
            b.e('ld {IX},{p}', copy=('IX', 'p'))
            b.e('exts {IX:x}')
            scale_ins(b, s, 'IX', 'x')
            b.e('ld {AD:x},{IX:x}', copy=('AD', 'IX'))
            b.nocoal.append('AD')
            b.e('add {AD:x},{Q:x}')
            opd = '({AD:x})'
            first = ['V', 'AD']
        else:
            b.e('ld {Z},{p}', copy=('Z', 'p'))
            b.e('exts {Z}')
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.nocoal.append('IX')
            scale_ins(b, s, 'IX')
            opd = '({Q:x}+{IX})'
            first = ['V', 'IX']
        b.e('ld %s,({Q:x})' % R('V'))
        b.e('sub %s,%s' % (R('V'), opd))
        b.e('ld (_g%s),%s' % (t, R('V')))
        return b.colour(fixed={'p': 'WA'}, first=first, pref={'V': 'WA'}, nocoalesce=b.nocoal) + ['ret']
    # shape 1: gT = (hT + E) * E; the multiplier's address is formed first
    if s == 1:
        b.e('lda {B2:x},%s' % arr)
        b.e('lda {B1:x},%s' % arr)
        ix = '{p}' if I == 'a' else '{p:b}'
        b.e('ld {V:b},(_h%s)' % t)
        b.e('add {V:b},({B1:x}+%s)' % ix)
        b.e('muls {V},({B2:x}+%s)' % ix)
        b.e('ld (_g%s),{V:b}' % t)
        return b.colour(fixed={'p': 'WA'}, first=['V', 'B1', 'B2'], pref={'V': 'WA'}) + ['ret']
    if s == 2:
        if I == 'a':
            b.e('ld {IX2},{p}', copy=('IX2', 'p'))
            b.e('add {IX2},{IX2}')
            b.e('lda {B2:x},%s' % arr)
            b.e('ld {IX1},{p}', copy=('IX1', 'p'))
            b.e('add {IX1},{IX1}')
            m1, m2 = '({B1:x}+{IX1})', '({B2:x}+{IX2})'
        else:
            b.w(T2=8, IX2=8, IX1=8)
            b.e('ld {T2:b},{p:b}', copy=('T2', 'p'))
            b.e('add {T2:b},{p:b}')
            b.e('ld {IX2:b},{T2:b}', copy=('IX2', 'T2'))
            b.nocoal.append('IX2')
            b.e('lda {B2:x},%s' % arr)
            b.e('ld {IX1:b},{p:b}', copy=('IX1', 'p'))
            b.e('add {IX1:b},{p:b}')
            m1, m2 = '({B1:x}+{IX1:b})', '({B2:x}+{IX2:b})'
        b.e('lda {B1:x},%s' % arr)
        b.e('ld {S},(_h%s)' % t)
        b.e('add {S},%s' % m1)
        b.e('ld {V},{S}', copy=('V', 'S'))
        b.e('muls {V:x},%s' % m2)
        b.e('ld (_g%s),{V}' % t)
        order = ['IX1', 'B1', 'IX2', 'B2', 'S'] if I == 'a' else ['T2', 'IX2', 'IX1', 'B1', 'B2', 'S']
        return b.colour(fixed={'p': 'WA'}, first=['V'], pref={'V': 'WA'}, order=order, nocoalesce=b.nocoal,
                        avoid={'IX2': ['T2']}) + ['ret']
    # unsigned long: C9H_mullu (XWA * XBC -> XHL)
    if I == 'a':
        b.e('ld {IX2},{p}', copy=('IX2', 'p'))
        b.e('sla 0x2,{IX2}')
        b.e('lda {B2:x},%s' % arr)
        b.e('exts {IX2:x}')
        b.e('add {IX2:x},{B2:x}')
        a2 = '({IX2:x})'
        b.e('ld {IX1},{p}', copy=('IX1', 'p'))
        b.e('sla 0x2,{IX1}')
        m1 = '({B1:x}+{IX1})'
        last2 = 'IX2'
    else:
        b.w(IX2=8, IX1=8)
        b.e('ld {IX2:b},{p:b}', copy=('IX2', 'p'))
        b.e('sla 0x2,{IX2:b}')
        b.e('lda {B2:x},%s' % arr)
        b.e('lda {AD2:x},{B2:x}+{IX2:b}')
        a2 = '({AD2:x})'
        b.e('ld {IX1:b},{p:b}', copy=('IX1', 'p'))
        b.e('sla 0x2,{IX1:b}')
        m1 = '({B1:x}+{IX1:b})'
    b.e('lda {B1:x},%s' % arr)
    b.e('ld {S:x},(_hn)')
    b.e('add {S:x},%s' % m1)
    b.e('ld {XA:x},{S:x}', copy=('XA', 'S'))
    b.e('ld {M:x},%s' % a2)
    b.e('cal C9H_mullu')
    b.e('ld (_gn),XHL')
    return b.colour(fixed={'p': 'WA', 'XA': 'WA', 'M': 'BC'}) + ['ret']


def mulu_xr(I, L):
    """-Xr unsigned long product with the char parameter (A): the none form without the reload of the parameter"""
    out = mulu('n', I, L)
    if I == 'b':
        drop = 'ld A,(XSP+0xa)' if L == 'G' else 'ld A,(XSP+0x4)'
        out = [x for x in out if x != drop]
        return out
    return None


# ================================================================================================ -O3 -XS (cdecl)
_REG = re.compile(r'(?<![A-Za-z_0-9])(Q?X?(?:WA|BC|DE|HL|IX|IY|IZ)|[AWCBEDLH])(?![A-Za-z_0-9])')
_PAIR = {'A': 'WA', 'W': 'WA', 'C': 'BC', 'B': 'BC', 'E': 'DE', 'D': 'DE', 'L': 'HL', 'H': 'HL'}


def _pair(r):
    return _PAIR[r] if r in _PAIR else r.lstrip('Q').lstrip('X')


def _regs(x):
    p = x.split(None, 1)
    return {_pair(m) for m in _REG.findall(p[1])} if len(p) > 1 else set()


def _dead_after(L, j, r):
    """register r (a name) is not read after line j before being written (straight-line code)"""
    for z in L[j + 1:]:
        if z.endswith(':') or z.startswith('j') or z.startswith('cal'):
            return False
        if z == 'ret':
            return True
        if z.startswith('scc ') and _pair(z.split(',')[1]) == _pair(r):
            return True
        if _pair(r) in _regs(z):
            ops = z.split(None, 1)[1]
            dst = ops.split(',')[0]
            src = ops[len(dst) + 1:]
            if z.startswith(('ld ', 'lda ')) and _pair(dst) == _pair(r) and _pair(r) not in _regs('x ' + src) and \
                    not dst.startswith('('):
                return True
            return False
    return True


def _dst(z):
    p = z.split(None, 1)
    if len(p) < 2:
        return None
    op, ops = p
    if op in ('cp', 'push', 'j', 'cal', 'ret', 'inc', 'dec') or ops.startswith('('):
        if op in ('inc', 'dec') and ',' in ops:
            return ops.split(',')[1]
        return None
    if op == 'scc':
        return ops.split(',')[1]
    if op in ('exts', 'extz', 'sla', 'sll', 'srl', 'sra'):
        return ops.split(',')[-1]
    return ops.split(',')[0]


def _rename(z, a, b):
    """rename register pair a to pair b in instruction z (all widths)"""
    names = {}
    for w in ('', 'X', 'Q'):
        names[w + a] = w + b
    if a in ('WA', 'BC', 'DE', 'HL') and b in ('WA', 'BC', 'DE', 'HL'):
        lo = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
        hi = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
        names[lo[a]] = lo[b]
        names[hi[a]] = hi[b]
    return _REG.sub(lambda m: names.get(m.group(1), m.group(1)), z)


def backprop(L):
    """-O: a value computed in R and then only copied to R2 is computed in R2:
    (def R) ... ld R2,R  ->  (def R2) ... , when nothing between touches R2 and R is dead after"""
    L = list(L)
    j = 0
    while j < len(L):
        m = re.match(r'ld (X?(?:WA|BC|DE|HL)|[ACEL]),(X?(?:WA|BC|DE|HL)|[ACEL])$', L[j])
        if m and len(m.group(1)) == len(m.group(2)) and _dead_after(L, j, m.group(2)):
            r2, r = _pair(m.group(1)), _pair(m.group(2))
            k = j - 1
            ok = False
            while k >= 0:
                z = L[k]
                if z.endswith(':') or z.startswith('j') or z.startswith('cal') or _pair(r2) in _regs(z):
                    break
                d = _dst(z)
                rn = m.group(2)
                if z.endswith('#nb'):
                    break
                srcs = set() if z.startswith('scc') else _regs('x ' + z.split(None, 1)[1][len(d) + 1:])
                lowdef = rn in ('WA', 'BC', 'DE', 'HL') and d == {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}[rn] and \
                    any(y.startswith(('exts ' + rn, 'extz ' + rn)) for y in L[k + 1:j])
                plain_copy = re.match(r'ld \w+,(Q?X?(WA|BC|DE|HL|IX|IY|IZ)|[AWCBEDLH])$', z) is not None
                if d is not None and not plain_copy and (d == rn or (rn[0] == 'X' and d == rn[1:]) or lowdef) \
                        and r not in srcs \
                        and not z.startswith(('add', 'sub', 'or', 'and', 'xor', 'exts', 'extz', 'sla', 'sll', 'inc',
                                              'dec', 'muls')):
                    ok = True
                    break
                k -= 1
            if ok and r2 in ('WA', 'BC', 'DE', 'HL') or (ok and len(m.group(1)) > 1):
                for q in range(k, j):
                    L[q] = _rename(L[q], r, r2)
                del L[j]
                continue
        j += 1
    return L


def unmark(L):
    return [x[:-3].rstrip() if x.endswith('#nb') else x for x in L]


def forward(L):
    """-O: a register loaded from memory and only copied into another register is loaded there directly:
    ld R,(m) ... ld R2,R  ->  ... ld R2,(m), when R is untouched between and dead after (same width)"""
    L = list(L)
    i = 0
    while i < len(L):
        m = re.match(r'ld (A|C|E|L|WA|BC|DE|HL|XWA|XBC|XDE|XHL),(\([^#]*\))( #nb)?$', L[i])
        if m:
            r, mem = m.group(1), m.group(2)
            for j in range(i + 1, len(L)):
                y = L[j]
                m2 = re.match(r'ld (\w+),%s$' % r, y)
                if m2 and len(m2.group(1)) == len(r) and _dead_after(L, j, r):
                    r2 = m2.group(1)
                    if any(_pair(r2) in _regs(z) for z in L[i + 1:j]):
                        L[j] = 'ld %s,%s' % (r2, mem)
                        del L[i]
                        i -= 1
                    else:
                        L[i] = 'ld %s,%s%s' % (r2, mem, ' #nb' if m.group(3) else '')
                        del L[j]
                    break
                if _pair(r) in _regs(y) or y.endswith(':') or y.startswith('j'):
                    break
                if mem != '(XSP+0x4)' and y.startswith('ld (') :
                    break
        i += 1
    return L

SRC = '(XSP+0x4)'


def o3_elem(b, s, I, arr, zbase=False, src=SRC, first=None):
    """-O3 -XS, cdecl: the element arr[idx]; idx a parameter in memory (a b c d) or a local `t = gi` (f g h j),
    whose load {T} the caller emitted.  zbase: the base address is also used for another element (Z), so it is
    formed first ({B}) and kept.  Returns the memory operand."""
    first = first if first is not None else []
    if zbase:
        b.e('lda {B:x},%s' % arr)
    lda = (lambda: None) if zbase else (lambda: b.e('lda {B:x},%s' % arr))
    if I == 'L':
        if s == 1:
            lda()
            return '({B:x}+{ctr})'
        b.e('ld {IX},{ctr}', copy=('IX', 'ctr'))
        scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I in 'fghj':
        if I == 'f':
            if s == 1:
                lda()
                return '({B:x}+{T})'
            b.e('ld {IX},{T}', copy=('IX', 'T'))
            scale_ins(b, s, 'IX')
            lda()
            return '({B:x}+{IX})'
        if I == 'g':
            b.w(IX8=8)
            b.e('ld {IX8:b},{T:b}', copy=('IX8', 'T'))
            b.e('extz {IX8}')
            b.w(IX8=16)
            if s > 1:
                scale_ins(b, s, 'IX8')
            lda()
            return '({B:x}+{IX8})'
        if I == 'h':
            if s == 1:
                lda()
                return '({B:x}+{T:b})'
            b.w(Y=8, IX=8)
            b.e('ld {Y:b},{T:b}', copy=('Y', 'T'))
            if s == 2:
                b.e('add {Y:b},{T:b}')
                first.append('Y')
            else:
                b.e('sla 0x2,{Y:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            lda()
            return '({B:x}+{IX:b})'
        raise KeyError(I)
    if I == 'a':
        if s == 1:
            if not zbase:
                b.e('lda {B:x},%s' % arr)
            b.e('ld {IX},%s' % src)
            b.e('extz {IX:x}')
            b.e('add {IX:x},{B:x}')
            return '({IX:x})'
        b.e('ld {IX},%s' % src)
        scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I == 'b':
        if s == 1:
            if not zbase:
                b.e('lda {B:x},%s' % arr)
            b.e('ld {ZX:x},0x0')
            if b.regime == 'F':
                b.w(T8=8)
                b.e('ld {T8:b},%s' % src)
                b.e('ld {ZX:b},{T8:b}')
                first.append('T8')
            else:
                b.e('ld {ZX:b},%s' % src)
                first.append('ZX')
            b.e('add {ZX:x},{B:x}')
            return '({ZX:x})'
        b.w(T8=8, Y=8, IX=8)
        if s == 2:
            b.e('ld {T8:b},%s' % src)
            b.e('ld {Y:b},{T8:b}', copy=('Y', 'T8'))
            b.e('add {Y:b},{T8:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            first.append('Y')
        else:
            b.e('ld {Y:b},%s' % src)
            b.e('sla 0x2,{Y:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            first.append('Y')
        lda()
        return '({B:x}+{IX:b})'
    if I == 'c':
        b.w(IX=16, T8=8)
        b.e('ld {T8:b},%s' % src)
        b.e('ld {IX:b},{T8:b}', copy=('IX', 'T8'))
        first.append('T8')
        b.e('extz {IX}')
        if s > 1:
            scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I == 'd':
        b.e('ld {IX},%s' % src)
        b.e('extz {IX:x}')
        scale_ins(b, s, 'IX', 'x')
        if zbase:
            b.e('ld {AD:x},{B:x}', copy=('AD', 'B'))
        else:
            b.e('ld {AD:x},%s' % arr)
        b.e('add {AD:x},{IX:x}')
        return '({AD:x})'
    raise KeyError(I)


def binop_o3(t, I, L, o):
    s = ES[t]
    sp = W[s]
    V = '{V:%s}' % sp if sp else '{V}'
    b = Body()
    b.w(V=8 * s if s != 2 else 16)
    arr = '_h%sa' % t
    mn = OPS[o]
    E = (o == 'o' and L in 'KZ')
    if I in 'fghj':
        b.e('ld {T},(_gi)')
    first = ['V']
    b.regime = 'E' if E else 'F'
    opd = o3_elem(b, s, I, arr, zbase=(L == 'Z'), first=first)
    left = left_src(t, L) if L != 'Z' else '({B:x}+%s)' % hx(s)
    if E:
        b.e('ld %s,%s' % (V, opd))
        b.e('%s %s,%s' % (mn, V, left))
    else:
        b.e('ld %s,%s' % (V, left))
        if L == 'C':
            b.e('dec 0x3,%s' % V)
        if mn == 'muls':
            b.e('muls %s,%s' % ('{V}' if s == 1 else '{V:x}', opd))
        else:
            b.e('%s %s,%s' % (mn, V, opd))
    b.e('ld (_g%s),%s' % (t, V))
    out = b.colour(first=first, pref={'V': 'WA', 'Y': 'WA', 'T8': 'WA'}, last=['T'])
    return backprop(forward(out)) + ['ret']


def o3_loop_tail(b):
    b.e('cp {PTR:x},{END:x}')
    b.e('j ult,L1')


def binop_o3_loop(t, L, o):
    """-O3: for (i = 0; i < 4; i++) gT = L op hTa[i]: a pointer walks the array ((PTR+:s)) up to an end pointer;
    the left operand is hoisted when it is loop-invariant (Z as a pointer, C as a value)"""
    s = ES[t]
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    for n in ('V', 'CV'):
        b.w(**{n: {1: 8, 2: 16, 4: 32}[s]})
    mn = OPS[o]
    E = (o == 'o' and L in 'KZ')
    b.e('lda {B:x},_h%sa' % t)
    if L == 'Z':
        b.e('lda {ZP:x},{B:x}+%s' % hx(s))
    if L == 'C':
        b.e('ld %s,(_h%s)' % (R('CV'), t))
        b.e('dec 0x3,%s' % R('CV'))
    b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
    end = 'END'
    if L == 'C' and s == 1:
        b.e('inc %s,{B:x}' % hx(4 * s))
        end = 'B'
    else:
        b.e('lda {END:x},{B:x}+%s' % hx(4 * s))
    b.e('L1:')
    top = len(b.seq)
    opd = '({PTR:x}+:%d)' % s
    left = {'K': '0x7', 'G': '(_h%s)' % t, 'Z': '({ZP:x})', 'C': R('CV')}[L]
    V = R('V')
    if E:
        b.e('ld %s,%s' % (V, opd))
        b.e('%s %s,%s' % (mn, V, left))
    else:
        b.e('ld %s,%s' % (V, left), copy=('V', 'CV') if L == 'C' else None)
        if mn == 'muls':
            b.e('muls %s,%s' % ('{V}' if s == 1 else '{V:x}', opd))
        else:
            b.e('%s %s,%s' % (mn, V, opd))
    b.e('ld (_g%s),%s' % (t, V))
    b.e('cp {PTR:x},{%s:x}' % end)
    b.e('j ult,L1')
    n = len(b.seq)
    live = {}
    for x in ('PTR', 'END', 'CV', 'ZP') + (('B',) if end == 'B' else ()):
        for i, ins in enumerate(b.seq):
            if x in ins.temps:
                live[x] = (i, n)
                break
    out = b.colour(first=['V', 'PTR', 'END' if end == 'END' else 'B', 'CV', 'ZP'], pref={'V': 'WA'}, live=live,
                   last=['B'] if end == 'END' else [], coalesce=False)
    if end == 'B':
        pass
    out = [x.replace('lda X', 'lda X') for x in out]
    return out + ['ret']


def mulu_o3(I, L):
    """-O3: gn = L * hna[idx] through C9H_mullu"""
    if I == 'L':
        if L == 'G':
            return ['dec 0x4,XSP', 'push XIZ', 'lda XWA,_hna', 'ld XIZ,XWA', 'lda XWA,XWA+0x10', 'ld (XSP+0x4),XWA',
                    'L1:', 'ld XBC,(XIZ)', 'ld XWA,(_hn)', 'cal C9H_mullu', 'ld (_gn),XHL', 'inc 0x4,XIZ',
                    'cp XIZ,(XSP+0x4)', 'j ult,L1', 'pop XIZ', 'inc 0x4,XSP', 'ret']
        return ['dec 0x8,XSP', 'push XIZ', 'lda XBC,_hna', 'ld XWA,(_hn)', 'ld (XSP+0x4),XWA', 'ld XWA,0x3',
                'sub (XSP+0x4),XWA', 'ld XIZ,XBC', 'lda XWA,XBC+0x10', 'ld (XSP+0x8),XWA', 'L1:', 'ld XWA,(XSP+0x4)',
                'ld XBC,(XIZ)', 'cal C9H_mullu', 'ld (_gn),XHL', 'inc 0x4,XIZ', 'cp XIZ,(XSP+0x8)', 'j ult,L1',
                'pop XIZ', 'inc 0x8,XSP', 'ret']
    out = mulu('n', I, L)
    if L == 'G':                     # the stacked index is reloaded before the left operand
        k = out.index('ld XWA,(_hn)')
        out[k], out[k + 1] = out[k + 1], out[k]
    return out


def inc_or_lda(r, n):
    """END = B + n in B's own register: inc 1..8 (8 written 0x0), else lda"""
    if n <= 8:
        return 'inc %s,%s' % (hx(n & 7), r)
    return 'lda %s,%s+%s' % (r, r, hx(n))


def fam_b_o3_loop(t, D, L):
    """-O3: for (i = 0; i < 4; i++) D <- L - hTa[i] (D not A): a pointer walk; loop-invariant parts hoisted"""
    s = ES[t]
    R = lambda n: '{%s:x}' % n if s == 4 else '{%s}' % n
    b = Body()
    for n in ('V', 'NV', 'LV', 'U'):
        b.w(**{n: 32 if s == 4 else 16})
    first, pref = [], {}
    if L == 'D':
        if D == 'V':
            b.e('ld {P:x},(_hps)')
        else:
            b.e('ld {LP:x},(_hps)')
            b.e('lda {LP:x},{LP:x}+%s' % hx(MOFF[t]))
    b.e('lda {B:x},_h%sa' % t)
    if D == 'V' and L in 'GED':
        b.e('ld %s,%s' % (R('LV'), {'G': '(_h%s)' % t, 'E': '({B:x}+%s)' % hx(3 * s),
                                    'D': '({P:x}+%s)' % hx(MOFF[t])}[L]))
        first.append('LV')
        pref['LV'] = 'WA'
    elif L == 'E':
        b.e('lda {LP:x},{B:x}+%s' % hx(3 * s))
    if L == 'N':
        if s == 2:
            b.e('cpw (_h%s),0x0' % t)
        else:
            b.e('ld {NT:x},(_h%s)' % t)
            b.e('or {NT:x},{NT:x}')
            b.w(NT=32)
        b.e('scc eq,{NV}')
        if s == 4:
            b.e('exts {NV:x}')
    if D == 'E':
        b.e('lda {SP:x},_g%sa + %s' % (t, hx(2 * s)))
    elif D == 'M':
        b.e('lda {SP:x},_gs + %s' % hx(MOFF[t]))
    elif D == 'P':
        b.e('ld {SP:x},(_g%sp)' % t)
    elif D == 'Q':
        b.e('ld {Q0:x},(_g%sp)' % t)
        b.e('lda {SP:x},{Q0:x}+%s' % hx(2 * s))
    b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
    b.e('ENDDEF')
    k_end = len(b.seq) - 1
    b.e('L1:')
    opd = '({PTR:x})' if D == 'C' else '({PTR:x}+:%d)' % s
    v = 'U' if D == 'V' else 'V'
    if D == 'V':
        src = R('LV') if L != 'N' else R('NV')
        b.e('ld %s,%s' % (R('U'), src))
    elif L == 'G':
        b.e('ld %s,(_h%s)' % (R('V'), t))
    elif L in 'ED':
        b.e('ld %s,({LP:x})' % R('V'))
    else:
        b.e('ld %s,%s' % (R('V'), R('NV')))
    b.e('sub %s,%s' % (R(v), opd))
    if D == 'G':
        b.e('ld (_g%s),%s' % (t, R('V')))
        first.insert(0, 'V')
        pref['V'] = 'WA'
    elif D in 'EMPQ':
        b.e('ld ({SP:x}),%s' % R('V'))
    elif D == 'C':
        b.e('cp %s,0x3' % R('V'))
        b.e('j %s,L2' % ('ule' if t in UNS else 'le'))
        b.e('ldw (_gi3),0x1')
        b.e('L2:')
        b.e('inc %s,{PTR:x}' % hx(s))
    b.e('cp {PTR:x},{END:x}')
    b.e('j ult,L1')
    n = len(b.seq)
    if D == 'V':
        b.e('ld (_gi3),{U}')
    top = k_end + 1
    live = {}
    for x in ('PTR', 'END', 'LP', 'NV', 'SP', 'LV', 'U'):
        for i, ins in enumerate(b.seq):
            if x in ins.temps or (x == 'END' and i == k_end):
                end_ = n if x != 'U' else len(b.seq) - 1
                live[x] = (i, max(end_, i))
                break
    b.seq[k_end].temps = ['END', 'B']
    order = ['PTR', 'END', 'LP', 'NV', 'V', 'U', 'SP', 'Q0', 'NT', 'P']
    if D != 'G':
        pref['B'] = 'END'
    b.w(B=32, END=32, PTR=32, LP=32, SP=32, Q0=32, P=32)
    out_regs = b.colour(first=first, pref=pref, live=live, order=order, last=['B'], coalesce=False)
    rb, re_ = b.reg['B'], b.reg['END']
    end_line = inc_or_lda('X' + re_, 4 * s) if rb == re_ else 'lda X%s,X%s+%s' % (re_, rb, hx(4 * s))
    out = [end_line if x == 'ENDDEF' else x for x in out_regs]
    return backprop(out) + ['ret']


def fam_k_o3(t, R, o, I, xo=False):
    """-O3 -XS: gR = (R)hR o (R)h<t>a[idx], t != R (the element is the first value)"""
    s = ES[t]
    b = Body()
    b.w(EV={1: 8, 2: 16, 4: 32}[s], C8=8, A8=8, ZN=32, V=32)
    EV = {1: '{EV:b}', 2: '{EV}', 4: '{EV:x}'}[s]
    first, pref = [], {}
    loop = I == 'L'
    if loop:
        b.e('lda {B:x},_h%sa' % t)
        b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
        b.e('lda {END:x},{B:x}+%s' % hx(4 * s))
        b.e('L1:')
        opd = '({PTR:x}+:%d)' % s
        areg = None
    elif xo:
        b.w(p=pwidth(I))
        opd = xr_elem(b, s, I, '_h%sa' % t, opt=True)
        areg = re.findall(r'\{(\w+)', opd)
    else:
        b.regime = 'E'
        opd = o3_elem(b, s, I, '_h%sa' % t, first=first)
        areg = re.findall(r'\{(\w+)', opd)
    ext = 'extz' if t in UNS else 'exts'
    if R == 'c':
        if o == 's':
            if s == 1:
                b.e('ld {C8:b},%s' % opd)
            elif s == 2:
                b.w(C8=16)
                b.e('ld {C8},%s' % opd)
            else:
                b.e('ld %s,%s' % (EV, opd))
                b.e('ld {C8:b},{EV:b}', copy=('C8', 'EV'))
                pref['EV'] = 'WA'
            b.e('ld {A8:b},(_hc)')
            b.e('sub {A8:b},{C8:b}')
            b.e('ld (_gc),{A8:b}')
            first.insert(0, 'A8')
            pref['A8'] = 'WA'
        else:
            b.e('ld %s,%s' % (EV, opd))
            b.e('or {EV:b},(_hc)')
            b.e('ld (_gc),{EV:b}')
            first.insert(0, 'EV')
            pref['EV'] = 'WA'
    else:
        tgt = 'ZN' if o == 's' else 'EV'
        if o == 'o':
            b.w(EV=32)
        if s == 1:
            if areg:                 # the address register itself is reused: extend in place, else clear first
                b.e('KLOAD {%s:x} {%s:b} %s %s' % (tgt, tgt, '|'.join('{%s:x}' % x for x in areg), opd))
            else:
                b.e('ld {%s:x},0x0' % tgt)
                b.e('ld {%s:b},%s' % (tgt, opd))
        elif s == 2:
            b.e('ld {%s},%s' % (tgt, opd))
            b.e('%s {%s:x}' % (ext, tgt))
        else:
            b.e('ld {%s:x},%s' % (tgt, opd))
        if o == 's':
            b.e('ld {V:x},(_hn)')
            b.e('sub {V:x},{ZN:x}')
            b.e('ld (_gn),{V:x}')
            first.insert(0, 'V')
            pref['V'] = 'WA'
        else:
            b.e('or {EV:x},(_hn)')
            b.e('ld (_gn),{EV:x}')
            first.insert(0, 'EV')
            pref['EV'] = 'WA'
    if loop:
        b.e('cp {PTR:x},{END:x}')
        b.e('j ult,L1')
        n = len(b.seq)
        live = {'PTR': (1, n), 'END': (2, n)}
        out = b.colour(first=first + ['PTR', 'END'], pref=pref, live=live, last=['B'], coalesce=False)
    else:
        out = b.colour(first=first, pref=pref, avoid={'C8': ['EV']}, last=['T'], fixed={'p': 'WA'} if xo else None)
    exp = []
    for x in out:
        m = re.match(r'KLOAD (\w+) (\w+) (\S+) (.*)$', x)
        if m:
            xr_, br, ar, op_ = m.groups()
            if xr_ in ar.split('|'):
                exp += ['ld %s,%s' % (br, op_), 'extz %s' % xr_[1:], 'extz %s' % xr_]
            else:
                exp += ['ld %s,0x0' % xr_, 'ld %s,%s' % (br, op_)]
        else:
            exp.append(x)
    return backprop(forward(exp)) + ['ret']


def fam_d_o3(shape, t, I):
    s = ES[t]
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    for n in ('V', 'D', 'DC', 'EL'):
        b.w(**{n: {1: 8, 2: 16, 4: 32}[s]})
    arr = '_h%sa' % t
    first, pref = ['V'], {'V': 'WA', 'Y': 'WA', 'T8': 'WA'}
    order = None
    if I == 'f':
        b.e('ld {T},(_gi) #nb')
    loop = I == 'L'
    live = {}

    def loop_head(ptrs, base_ins):
        for x in base_ins:
            b.e(x)
        for pn in ptrs:
            b.e('ld {%s:x},{B:x}' % pn, copy=(pn, 'B'))
        b.e('lda {END:x},{B:x}+%s' % hx(4 * s))
        b.e('L1:')

    def loop_tail(ptr, carried):
        b.e('cp {%s:x},{END:x}' % ptr)
        b.e('j ult,L1')
        n = len(b.seq)
        for x in carried:
            for i, ins in enumerate(b.seq):
                if x in ins.temps:
                    live[x] = (i, n)
                    break
    if shape == '2':
        if loop:
            loop_head(['PTR'], ['lda {B:x},%s' % arr])
            opd = '({PTR:x}+:%d)' % s
        else:
            b.regime = 'F'
            opd = o3_elem(b, s, I, arr, first=first)
        b.e('ld %s,(_v%s)' % (R('D'), t))
        b.e('sub %s,%s' % (R('D'), opd))
        if s == 1:
            b.e('ld %s,%s' % (R('DC'), R('D')), copy=('DC', 'D'))
        b.e('ld %s,(_h%s)' % (R('V'), t))
        b.e('sub %s,%s' % (R('V'), R('DC' if s == 1 else 'D')))
        b.e('ld (_g%s),%s' % (t, R('V')))
        if loop:
            loop_tail('PTR', ['PTR', 'END'])
            first += ['PTR', 'END']
        if s == 1:
            first.append('D')
            pref['D'] = 'WA'
        out = b.colour(first=first, pref=pref, live=live, last=['T', 'B'] if loop else ['T'],
                       coalesce=not loop, avoid={'DC': ['D']}, nocoalesce=['DC'])
        return unmark(backprop(forward(out))) + ['ret']
    if shape == '3':
        if loop:
            loop_head(['QH', 'PTR'], ['ld {B:x},(_g%sp)' % t])
            b.e('ld %s,({QH:x})' % R('V'))
            b.e('sub %s,({PTR:x}+:%d)' % (R('V'), s))
            b.e('ld (_g%s),%s' % (t, R('V')))
            loop_tail('PTR', ['QH', 'PTR', 'END'])
            out = b.colour(first=['V', 'PTR', 'END', 'QH'], pref=pref, live=live, last=['B'], coalesce=False)
            return out + ['ret']
        b.e('ld {Q:x},(_g%sp)' % t)
        if s == 1:
            if I == 'a':
                b.e('ld {IX},%s' % SRC)
                b.e('extz {IX:x}')
                b.e('add {IX:x},{Q:x}')
                opd = '({IX:x})'
            elif I == 'b':
                b.w(T8=8)
                b.e('ld {T8:b},%s' % SRC)
                b.e('ld {ZX:x},0x0')
                b.e('ld {ZX:b},{T8:b}')
                b.e('add {ZX:x},{Q:x}')
                opd = '({ZX:x})'
                first.append('T8')
            else:
                opd = '({Q:x}+{T})'
        elif I == 'b':
            b.w(Y=8)
            b.e('ld {Y:b},%s' % SRC)
            b.e('exts {Y}')
            b.e('ld {IX},{Y}', copy=('IX', 'Y'))
            scale_ins(b, s, 'IX')
            opd = '({Q:x}+{IX})'
            first.append('Y')
        else:
            if I == 'a':
                b.e('ld {Y},%s' % SRC)
            else:
                b.e('ld {Y},{T}', copy=('Y', 'T'))
            b.e('exts {Y:x}')
            scale_ins(b, s, 'Y', 'x')
            b.e('ld {AD:x},{Y:x}', copy=('AD', 'Y'))
            b.e('add {AD:x},{Q:x}')
            opd = '({AD:x})'
            first.append('Y')
        b.e('ld %s,({Q:x})' % R('V'))
        b.e('sub %s,%s' % (R('V'), opd))
        b.e('ld (_g%s),%s' % (t, R('V')))
        out = b.colour(first=first, pref=pref, last=['T'], nocoalesce=['AD', 'IX'], avoid={'AD': ['Y'], 'IX': ['Y']},
                       order=['Y', 'AD', 'IX', 'ZX', 'Q'])
        return unmark(backprop(forward(out))) + ['ret']
    # shape 1: (hT + E) * E, the element read once
    if s == 4:
        if loop:
            return ['dec 0x8,XSP', 'push XIZ', 'lda XWA,_hna', 'ld XIZ,XWA', 'ld (XSP+0x8),XWA', 'lda XWA,XWA+0x10',
                    'ld (XSP+0x4),XWA', 'L1:', 'ld XWA,(_hn)', 'add XWA,(XIZ)', 'ld XBC,(XSP+0x8)', 'ld XBC,(XBC)',
                    'cal C9H_mullu', 'ld (_gn),XHL', 'ld XWA,0x4', 'add (XSP+0x8),XWA', 'inc 0x4,XIZ',
                    'cp XIZ,(XSP+0x4)', 'j ult,L1', 'pop XIZ', 'inc 0x8,XSP', 'ret']
        b.regime = 'F'
        opd = o3_elem(b, s, I, arr, first=first)
        b.e('ld {EL:x},%s' % opd)
        b.e('ld {V:x},(_hn)')
        b.e('add {V:x},{EL:x}')
        b.e('cal C9H_mullu')
        b.e('ld (_gn),XHL')
        out = b.colour(fixed={'V': 'WA', 'EL': 'BC'}, first=first, pref=pref, last=['T'],
                       order=['EL', 'B', 'IX', 'Y'], nocoalesce=['IX'])
        return unmark(backprop(forward(out))) + ['ret']
    if loop:
        if s == 1:
            loop_head(['PTR'], ['lda {B:x},%s' % arr])
            b.e('ld {EL:b},({PTR:x}+:1)')
            b.e('ld {V:b},(_h%s)' % t)
            b.e('add {V:b},{EL:b}')
            b.e('muls {V},{EL:b}')
            b.e('ld (_g%s),{V:b}' % t)
            loop_tail('PTR', ['PTR', 'END'])
            out = b.colour(first=['V', 'EL', 'PTR', 'END'], pref=pref, live=live, last=['B'], coalesce=False)
            return out + ['ret']
        loop_head(['PTR', 'PTR2'], ['lda {B:x},%s' % arr])
        b.e('ld {V},(_h%s)' % t)
        b.e('add {V},({PTR:x}+:2)')
        b.e('muls {V:x},({PTR2:x}+:2)')
        b.e('ld (_g%s),{V}' % t)
        loop_tail('PTR', ['PTR', 'PTR2', 'END'])
        out = b.colour(first=['V', 'PTR', 'PTR2', 'END'], pref=pref, live=live, last=['B'], coalesce=False)
        return out + ['ret']
    b.regime = 'E' if s == 1 else 'F'
    opd = o3_elem(b, s, I, arr, first=first)
    b.e('ld %s,%s' % (R('EL'), opd))
    b.e('ld %s,(_h%s)' % (R('V'), t))
    b.e('add %s,%s' % (R('V'), R('EL')))
    b.e('muls %s,%s' % ('{V}' if s == 1 else '{V:x}', R('EL')))
    b.e('ld (_g%s),%s' % (t, R('V')))
    order = ['EL', 'IX', 'ZX', 'B'] if s == 1 else ['EL', 'B', 'IX']
    out = b.colour(first=first, pref=pref, last=['T'], order=order, nocoalesce=['IX'])
    return unmark(backprop(forward(out))) + ['ret']


def fam_e_o3(t, B, I, L):
    """-O3 -XS: gT = L - base[idx], base kind B (A M D Q R)"""
    s = ES[t]
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    b.w(V={1: 8, 2: 16, 4: 32}[s])
    first, pref = ['V'], {'V': 'WA', 'Y': 'WA', 'T8': 'WA'}
    left = '0x7' if L == 'K' else '(_h%s)' % t
    off = AOFF[t]
    src = '(XSP+0x8)' if B == 'R' else SRC
    order, nocoal, avoid = None, [], {}
    if I == 'L':
        if B in 'AM':
            b.e('lda {B:x},%s' % ('_h%sa' % t if B == 'A' else '_hs + %s' % hx(off)))
        elif B == 'D':
            b.e('ld {B:x},(_hps)')
            b.e('%s {K:x},%s' % ('lda' if off > 8 else 'ld', hx(off)))
            b.e('add {B:x},{K:x}')
        elif B == 'Q':
            b.e('ld {B:x},(_g%sp)' % t)
        else:
            b.e('ld {B:x},(XSP+0x4)')
        b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
        b.e('ENDDEF')
        k_end = len(b.seq) - 1
        b.e('L1:')
        b.e('ld %s,%s' % (R('V'), left))
        b.e('sub %s,({PTR:x}+:%d)' % (R('V'), s))
        b.e('ld (_g%s),%s' % (t, R('V')))
        b.e('cp {PTR:x},{END:x}')
        b.e('j ult,L1')
        n = len(b.seq)
        b.seq[k_end].temps = ['END', 'B']
        live = {'PTR': (k_end - 1, n), 'END': (k_end, n)}
        pr = dict(pref)
        if B == 'D':
            pr['B'] = 'END'
        out = b.colour(first=['V', 'PTR', 'END'], pref=pr, live=live, last=['B'], coalesce=False)
        rb, re_ = b.reg['B'], b.reg['END']
        end_line = inc_or_lda('X' + re_, 4 * s) if rb == re_ else 'lda X%s,X%s+%s' % (re_, rb, hx(4 * s))
        return [end_line if x == 'ENDDEF' else x for x in out] + ['ret']
    b.regime = 'F'
    if B == 'A':
        opd = o3_elem(b, s, I, '_h%sa' % t, first=first)
    elif B == 'M':
        arr = '_hs + %s' % hx(off)
        if s == 1:
            if I == 'a':
                b.e('ld {IX},%s' % src)
            else:
                b.w(IX=8)
                b.e('ld {IX:b},%s' % src)
            b.e('lda {B:x},%s' % arr)
            opd = '({B:x}+{IX%s})' % ('' if I == 'a' else ':b')
        else:
            opd = o3_elem(b, s, I, arr, first=first)
    elif B == 'D':
        b.w(IE=8)
        if s == 1:
            if I == 'a':
                b.e('ld {Y},%s' % src)
                b.e('inc %s,{Y}' % hx(off))
            else:
                b.w(Y=8)
                b.e('ld {Y:b},%s' % src)
                b.e('inc %s,{Y:b}' % hx(off))
            opd = '({B:x}+{Y:b})'
            b.e('ld {B:x},(_hps)')
            order = ['B', 'Y']
            pref.pop('Y')
        else:
            if I == 'a':
                b.e('ld {Y},%s' % src)
                b.e('add {Y},{Y}')
                b.e('add {Y},%s' % hx(off))
            else:
                b.w(T8=8, Y=8)
                b.e('ld {T8:b},%s' % src)
                b.e('ld {Y:b},{T8:b}', copy=('Y', 'T8'))
                b.e('add {Y:b},{T8:b}')
                b.e('add {Y:b},%s' % hx(off))
                first.append('Y')
            b.e('ld {IE:b},{Y:b}', copy=('IE', 'Y'))
            nocoal.append('IE')
            b.e('ld {B:x},(_hps)')
            opd = '({B:x}+{IE:b})'
            order = ['B']
    elif B == 'Q':
        if s == 1:
            b.e('ld {B:x},(_g%sp)' % t)
            if I == 'a':
                b.e('ld {IX},%s' % src)
                b.e('extz {IX:x}')
                b.e('add {IX:x},{B:x}')
                opd = '({IX:x})'
            else:
                b.w(T8=8)
                b.e('ld {T8:b},%s' % src)
                b.e('ld {ZX:x},0x0')
                b.e('ld {ZX:b},{T8:b}')
                b.e('add {ZX:x},{B:x}')
                opd = '({ZX:x})'
                first.append('T8')
                order = ['B', 'ZX']
        elif I == 'a':
            b.e('ld {IX},%s' % src)
            b.e('exts {IX:x}')
            scale_ins(b, s, 'IX', 'x')
            b.e('add {IX:x},(_g%sp)' % t)
            opd = '({IX:x})'
        else:
            b.w(Y=8)
            b.e('ld {Y:b},%s' % src)
            b.e('exts {Y}')
            b.e('ld {IX},{Y}', copy=('IX', 'Y'))
            scale_ins(b, s, 'IX')
            b.e('ld {B:x},(_g%sp)' % t)
            opd = '({B:x}+{IX})'
            first.append('Y')
            order = ['B', 'IX']
            nocoal.append('IX')
            avoid['IX'] = ['Y']
    else:   # R: the pointer parameter at (XSP+0x4), the index at (XSP+0x8)
        if s == 1:
            if I == 'a':
                b.e('ld {IX},%s' % src)
                b.e('extz {IX:x}')
            else:
                b.e('ld {IX:x},0x0')
                b.e('ld {IX:b},%s' % src)
            b.e('add {IX:x},(XSP+0x4)')
        elif I == 'a':
            b.e('ld {IX},%s' % src)
            b.e('exts {IX:x}')
            scale_ins(b, s, 'IX', 'x')
            b.e('add {IX:x},(XSP+0x4)')
        else:
            b.w(Y=8)
            b.e('ld {Y:b},%s #nb' % src)
            b.e('exts {Y}')
            scale_ins(b, s, 'Y')
            b.e('ld {IX},{Y}', copy=('IX', 'Y'))
            b.e('extz {IX:x}')
            b.e('add {IX:x},(XSP+0x4)')
            first.append('Y')
            nocoal.append('IX')
            avoid['IX'] = ['Y']
        opd = '({IX:x})'
    b.e('ld %s,%s' % (R('V'), left))
    b.e('sub %s,%s' % (R('V'), opd))
    b.e('ld (_g%s),%s' % (t, R('V')))
    out = b.colour(first=first, pref=pref, order=order, nocoalesce=nocoal, avoid=avoid)
    return unmark(backprop(forward(out))) + ['ret']


def fam_d_xo(shape, t, I):
    """-O3 -XS -Xr, er_d with the index parameter in WA / A"""
    s = ES[t]
    if shape == '2' or (shape == '3' and (I != 'b' or s == 1)):
        return fam_d_xr(shape, t, I)
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    b.w(p=pwidth(I))
    for n in ('V', 'EL'):
        b.w(**{n: {1: 8, 2: 16, 4: 32}[s]})
    arr = '_h%sa' % t
    if shape == '3':                 # the char index is copied out of A before q is loaded, then extended
        b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
        b.e('ld {Q:x},(_g%sp)' % t)
        b.e('exts {IX}')
        scale_ins(b, s, 'IX')
        b.e('ld %s,({Q:x})' % R('V'))
        b.e('sub %s,({Q:x}+{IX})' % R('V'))
        b.e('ld (_g%s),%s' % (t, R('V')))
        b.w(IX=16)
        return b.colour(fixed={'p': 'WA'}, first=['V'], pref={'V': 'WA'}, order=['IX', 'Q']) + ['ret']
    opd = xr_elem(b, s, I, arr, opt=True)
    if s == 4:
        b.e('ld {EL:x},%s' % opd)
        b.e('ld {V:x},(_hn)')
        b.e('add {V:x},{EL:x}')
        b.e('cal C9H_mullu')
        b.e('ld (_gn),XHL')
        return b.colour(fixed={'p': 'WA', 'V': 'WA', 'EL': 'BC'}, order=['EL', 'B', 'IX'], nocoalesce=['IX']) + ['ret']
    b.e('ld %s,%s' % (R('EL'), opd))
    b.e('ld %s,(_h%s)' % (R('V'), t))
    b.e('add %s,%s' % (R('V'), R('EL')))
    b.e('muls %s,%s' % ('{V}' if s == 1 else '{V:x}', R('EL')))
    b.e('ld (_g%s),%s' % (t, R('V')))
    return b.colour(fixed={'p': 'WA'}, first=['V'], pref={'V': 'WA'}, order=['EL', 'B', 'IX'],
                    nocoalesce=['IX']) + ['ret']


def fam_e_xo_loop(t, L):
    """-O3 -XS -Xr, er_e R base with the loop counter: a pointer walk from the pointer parameter (XWA)"""
    s = ES[t]
    sp = W[s]
    R = lambda n: '{%s:%s}' % (n, sp) if sp else '{%s}' % n
    b = Body()
    b.w(p=32, V={1: 8, 2: 16, 4: 32}[s])
    b.e('ld {PTR:x},{p:x}', copy=('PTR', 'p'))
    b.e('lda {END:x},{p:x}+%s' % hx(4 * s))
    b.e('L1:')
    b.e('ld %s,%s' % (R('V'), '0x7' if L == 'K' else '(_h%s)' % t))
    b.e('sub %s,({PTR:x}+:%d)' % (R('V'), s))
    b.e('ld (_g%s),%s' % (t, R('V')))
    b.e('cp {PTR:x},{END:x}')
    b.e('j ult,L1')
    n = len(b.seq)
    return b.colour(fixed={'p': 'WA'}, first=['V', 'PTR', 'END'], pref={'V': 'WA'},
                    live={'PTR': (0, n), 'END': (1, n)}, coalesce=False) + ['ret']


# ==============================================================================================================
# bc_*, the other sets
# ==============================================================================================================
ES = {'c': 1, 'u': 1, 'i': 2, 'w': 2, 'l': 4, 'n': 4}
SIGNED = {'c': True, 'u': False, 'i': True, 'w': False, 'l': True, 'n': False}
GS_OFF = {'c': 0, 'u': 0xa, 'i': 0x14, 'w': 0x26, 'l': 0x38, 'n': 0x5c}


def R(n, es):
    return {1: '{%s:b}', 2: '{%s}', 4: '{%s:x}'}[es] % n


def bc_xr(t, I, V, outer):
    """-Xr, the index a parameter (a b c): outer = (h<t>a[p] = V) with outer in G M E P D (families a, b) or a
    context C A R K V (family c)"""
    es = ES[t]
    b = Body()
    b.w(p=pwidth(I))
    for n in ('V', 'K', 'K2', 'C2', 'RV', 'AR', 'R8'):
        b.w(**{n: 32 if es == 4 else 16})
    b.w(R8=8)
    fixed, first, pref, order_last = {'p': 'WA'}, [], {}, []
    avoid = {}
    off = GS_OFF[t] if outer == 'D' else 0
    ptr_late = outer in 'PD' and V == 'S'
    ptr_sym = '_g%sp' % t if outer in 'PR' else '_gps'
    if outer == 'A':
        b.e('cpw (_gi),0x5')
        b.e('ret ge')
    if outer in 'CA' and t in 'wln':
        b.e('ld {G},(_gi)')
        if es == 4:
            b.e('exts {G:x}')
        order_last.append('G')
    if outer in 'PDR' and not ptr_late:
        b.e('ld {P:x},(%s)' % ptr_sym)
        if off:
            first.append('P')
        else:
            order_last.insert(0, 'P')
    mode = xr_elem(b, es, I, '_h%sa' % t)
    if outer in 'CA':
        V = 'K'
    konst = 2 if outer in 'CA' else 7
    if outer == 'R':
        b.e('ld %s,%s' % (R('RV', es), mode))
        b.e('ld ({P:x}),%s' % R('RV', es))
        fixed['RV'] = 'HL'
        return b.colour(fixed=fixed, first=first, pref=pref, last=order_last) + ['ret']
    tail = None
    if V == 'K':
        if es == 4:
            b.e('ld {K:x},%s' % hx(konst))
            b.e('ld %s,{K:x}' % mode)
            fixed['K'] = 'WA'
            if outer != 'G' or True:
                b.e('ld {K2:x},%s' % hx(konst))
                fixed['K2'] = 'WA'
                tail = '{K2:x}'
        else:
            b.e('%s %s,%s' % ('ldb' if es == 1 else 'ldw', mode, hx(konst)))
            if outer in 'MEPD':
                b.e('ld %s,%s' % (R('K2', es), hx(konst)))
                tail = R('K2', es)
            elif outer in 'CA':
                b.e('ld {K2},%s' % hx(konst))
                fixed['K2'] = 'WA'
                tail = '{K2}'
    else:
        vr = R('V', es)
        if V == 'G':
            b.e('ld %s,(_v%s)' % (vr, t))
        elif V == 'S':
            b.e('ld %s,(_h%sa + %s)' % (vr, t, hx(es)))
        elif V == 'N':
            b.e('cpw (_gi),0x0')
            b.e('scc eq,{V}')
            if es == 4:
                b.e('exts {V:x}')
        elif V == 'B':
            first.insert(0, 'V')
            pref['V'] = 'WA'
            w3 = '(_w%sa + %s)' % (t, hx(3 * es))
            if es == 1:
                b.e('ld {V:b},%s' % w3)
                b.e('add {V:b},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V}')
                    b.e('divs {V},0x10')
                    b.e('ld {R8:b},{V:h}')
                    pref['R8'] = 'V'
                    vr = '{R8:b}'
                else:
                    b.e('and {V:b},0xf')
            elif es == 2:
                b.e('ld {V},%s' % w3)
                b.e('add {V},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V:x}')
                    b.e('divs {V:x},0x10')
                    b.e('ld {R8},{V:q}')
                    b.w(R8=16)
                    pref['R8'] = 'V'
                    vr = '{R8}'
                else:
                    b.e('and {V},0xf')
            else:
                if SIGNED[t]:
                    return None
                b.e('ld {V:x},%s' % w3)
                b.e('add {V:x},(_v%s)' % t)
                b.e('and {V:x},0xf')
        b.e('ld %s,%s' % (mode, vr))
        tail = vr
    # the outer destination / context
    if outer == 'G':
        if V == 'K' and es != 4:
            b.e('%s (_g%s),%s' % ('ldb' if es == 1 else 'ldw', t, hx(konst)))
        else:
            b.e('ld (_g%s),%s' % (t, tail))
    elif outer == 'M':
        b.e('ld (_gs%s),%s' % (' + ' + hx(GS_OFF[t]) if GS_OFF[t] else '', tail))
    elif outer == 'E':
        b.e('ld (_g%sa + %s),%s' % (t, hx(2 * es), tail))
    elif outer in 'PD':
        if ptr_late:
            b.e('ld {P:x},(%s)' % ptr_sym)
        b.e('ld ({P:x}%s),%s' % ('+' + hx(off) if off else '', tail))
    elif outer in 'CA':
        if es == 4:
            b.e('cp {K2:x},{G:x}')
        elif t == 'w':
            b.e('cp {K2},{G}')
        else:
            b.e('cp {K2},(_gi)')
    elif outer in 'KV':
        if es == 1:
            b.e('ld {AR:b},{V:b}', copy=('AR', 'V'))
            fixed['AR'] = 'WA'
            b.e('%s {AR}' % ('exts' if SIGNED[t] else 'extz'))
            if outer == 'V':
                b.e('ld (_gi3),{AR}')
        elif outer == 'K':
            b.e('ld %s,%s' % (R('AR', es), R('V', es)), copy=('AR', 'V'))
            fixed['AR'] = 'WA'
        else:
            b.e('ld (_gi3),{V}')
    out = b.colour(fixed=fixed, first=first, pref=pref, last=order_last, avoid=avoid)
    if outer in 'CA':
        return out + ['ret ne', 'ldw (_gi3),0x1', 'L1:', 'ret']
    if outer == 'K':
        return out + ['j .sk%s' % t]
    return out + ['ret']


def xr_long_b(I):
    """-Xr: signed long % 16 through C9H_remls (the none form without the parameter's reload)"""
    out = long_b_special('l', I)
    drop = {'a': ['ld WA,(XSP+0x8)'], 'b': ['ld A,(XSP+0x8)'], 'c': ['ld A,(XSP+0x8)']}[I]
    return [x for x in out if x not in drop]


def xr_loop_calls(lines):
    out = []
    i = 0
    while i < len(lines):
        x = lines[i]
        m = re.match(r'push (X?)(\w+)$', x)
        if m and i + 2 < len(lines) and lines[i + 1].startswith('cal _sk') and lines[i + 2].startswith('inc '):
            r = m.group(1) + m.group(2)
            acc = m.group(1) + 'WA'
            if r != acc:
                out.append('ld %s,%s' % (acc, r))
            out.append('cal .' + lines[i + 1][5:])
            i += 3
            continue
        out.append(x)
        i += 1
    return out


def bc_predict(n, S):
    fam, rest = split_name(n)
    t, I = rest[0], rest[1]
    tail = rest[2:]
    if S == 'none':
        return bc0_predict(n)
    if S == 'Xr':
        if I not in 'abc':
            return xr_loop_calls(bc0_predict(n))
        if fam == 'a':
            if tail == 'B' and t == 'l':
                return xr_long_b(I)
            return bc_xr(t, I, tail, 'G')
        if fam == 'b':
            return bc_xr(t, I, tail[1], tail[0])
        return bc_xr(t, I, 'G', tail)
    if S == 'O3XSXr' and I in 'abc':
        if fam == 'a':
            if tail == 'B' and t == 'l':
                return [('lda XBC,0x10' if x == 'ld XBC,0x10' else x) for x in xr_long_b(I)]
            return bc_xo(t, I, tail, 'G')
        if fam == 'b':
            return bc_xo(t, I, tail[1], tail[0])
        return bc_xo(t, I, 'G', tail)
    if S == 'O3XSXr' and I == 'L' and fam == 'c' and tail == 'K':
        return bc_o3(t, I, 'G', 'K', xcall=True)
    if S == 'O3XSXr':
        S = 'O3XS'
    if S == 'O3XS':
        if I == 'L' and fam in 'ab':
            if fam == 'a' and tail == 'B' and t == 'l':
                return o3_long_b_loop()
            return bc_o3_loop(t, tail if fam == 'a' else tail[1], 'G' if fam == 'a' else tail[0])
        if I == 'L':
            if tail in 'CV':
                return bc_o3_loop_c(t, tail)
            return bc_o3(t, I, 'G', tail)
        if fam == 'a':
            if tail == 'B' and t == 'l':
                return o3_long_b(I)
            return bc_o3(t, I, tail, 'G')
        if fam == 'b':
            return bc_o3(t, I, tail[1], tail[0])
        return bc_o3(t, I, 'G', tail)
    return None


def bc_o3(t, I, V, outer, xcall=False):
    """-O3 -XS (cdecl): outer = (h<t>a[idx] = V), idx a parameter in memory or the local t = gi; with I = L (contexts
    A and K) the loop keeps a counter: rotated, no test before the first pass"""
    es = ES[t]
    b = Body()
    loop = I == 'L'
    if loop and outer == 'A':
        b.e('ld {ctr},0x0')
        b.e('L1:')
    for n in ('V', 'K', 'RV', 'NV'):
        b.w(**{n: 32 if es == 4 else 16})
    b.w(R8=8)
    fixed, first, pref, last = {}, [], {'Y': 'WA', 'T8': 'WA'}, []
    off = GS_OFF[t] if outer == 'D' else 0
    ptr_late = outer in 'PD' and V == 'S'
    ptr_sym = '_g%sp' % t if outer in 'PR' else '_gps'
    if outer in 'CA':
        V = 'K'
    konst = 2 if outer in 'CA' else 7
    T_used = I == 'f' and V == 'N'
    if outer in 'CA':
        if t == 'w':
            b.e('ld {G},(_gi)')
        elif es == 4:
            b.e('ld {G},(_gi)')
            fixed['G'] = 'HL'
        if outer == 'A':
            if t == 'w' or es == 4:
                b.e('cp {G},0x5')
            else:
                b.e('ld {G5},(_gi)')
                b.e('cp {G5},0x5')
                fixed['G5'] = 'WA'
            b.e('j ge,L2' if loop else 'ret ge')
        if es == 4:
            b.e('exts {G:x}')
        last.append('G')
    if I == 'f':
        b.e('ld {T},(_gi)')
        if not T_used:
            last.append('T')
    pfirst = []
    if outer in 'PDR' and not ptr_late:
        b.e('ld {P:x},(%s)' % ptr_sym)
        if off:
            pfirst.append('P')
        else:
            last.insert(0, 'P')
    elif outer == 'D' and off:
        pfirst.append('P')
    pinned = (V == 'B') or (V == 'N' and es == 1 and I == 'b')
    b.regime = 'F' if pinned else 'E'
    efirst = []
    mode = o3_elem(b, es, I, '_h%sa' % t, first=efirst)
    if V == 'S':
        efirst.append('B')
    if outer == 'R':
        b.e('ld %s,%s' % (R('RV', es), mode))
        b.e('ld ({P:x}),%s' % R('RV', es))
        fixed['RV'] = 'HL'
        out = b.colour(fixed=fixed, first=first + [x for x in efirst if x in ('T8', 'Y', 'ZX')] + pfirst + [x for x in efirst if x not in ('T8', 'Y', 'ZX')], pref=pref, last=last)
        return unmark(backprop(forward(out))) + ['ret']
    tail = None
    if V == 'K':
        if es == 4:
            b.e('ld {K:x},%s' % hx(konst))
            b.e('ld %s,{K:x}' % mode)
            fixed['K'] = 'WA'
            tail = '{K:x}'
        else:
            b.e('%s %s,%s' % ('ldb' if es == 1 else 'ldw', mode, hx(konst)))
            tail = None
    else:
        vr = R('V', es)
        if V == 'G':
            b.e('ld %s,(_v%s)' % (vr, t))
        elif V == 'S':
            b.e('ld %s,({B:x}+%s)' % (vr, hx(es)))
        elif V == 'N':
            if T_used:
                b.e('cp {T},0x0')
            else:
                b.e('cpw (_gi),0x0')
            b.e('scc eq,{V}')
            if es == 4:
                b.e('exts {V:x}')
            if pinned:
                first.insert(0, 'V')
                pref['V'] = 'WA'
        elif V == 'B':
            first.insert(0, 'V')
            pref['V'] = 'WA'
            w3 = '(_w%sa + %s)' % (t, hx(3 * es))
            if es == 1:
                b.e('ld {V:b},%s' % w3)
                b.e('add {V:b},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V}')
                    b.e('divs {V},0x10')
                    b.e('ld {R8:b},{V:h}')
                    pref['R8'] = 'V'
                    vr = '{R8:b}'
                else:
                    b.e('and {V:b},0xf')
            elif es == 2:
                b.e('ld {V},%s' % w3)
                b.e('add {V},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V:x}')
                    b.e('divs {V:x},0x10')
                    b.e('ld {R8},{V:q}')
                    b.w(R8=16)
                    pref['R8'] = 'V'
                    vr = '{R8}'
                else:
                    b.e('and {V},0xf')
            else:
                if SIGNED[t]:
                    return None
                b.e('ld {V:x},%s' % w3)
                b.e('add {V:x},(_v%s)' % t)
                b.e('and {V:x},0xf')
        b.e('ld %s,%s' % (mode, vr))
        tail = vr
    kb = '%s %%s,%s' % ('ldb' if es == 1 else 'ldw', hx(konst))
    if outer == 'G':
        b.e(kb % '(_g%s)' % t if tail is None else 'ld (_g%s),%s' % (t, tail))
    elif outer == 'M':
        d = '(_gs%s)' % (' + ' + hx(GS_OFF[t]) if GS_OFF[t] else '')
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer == 'E':
        d = '(_g%sa + %s)' % (t, hx(2 * es))
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer in 'PD':
        if ptr_late:
            b.e('ld {P:x},(%s)' % ptr_sym)
        d = '({P:x}%s)' % ('+' + hx(off) if off else '')
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer in 'CA':
        if es == 4:
            b.e('cp {G:x},0x2')
        elif t == 'w':
            b.e('cp {G},0x2')
        elif outer == 'A':
            b.e('ld {G2},(_gi)')
            b.e('cp {G2},0x2')
            fixed['G2'] = 'WA'
        else:
            b.e('cpw (_gi),0x2')
    elif outer == 'K' and xcall:             # -Xr call: the argument in WA / XWA
        if es == 1:
            b.e('%s {V}' % ('exts' if SIGNED[t] else 'extz'))
            b.e('ld {AR},{V}', copy=('AR', 'V'))
            fixed['AR'] = 'WA'
        else:
            first.insert(0, 'V')
            pref['V'] = 'WA'
        b.e('cal .sk%s' % t)
    elif outer in 'KV':
        if es == 1:
            b.e('%s {V}' % ('exts' if SIGNED[t] else 'extz'))
            if outer == 'K':
                b.e('push {V}')
            else:
                b.e('ld (_gi3),{V}')
        elif outer == 'K':
            b.e('push %s' % R('V', es))
        else:
            b.e('ld (_gi3),{V}')
        if outer == 'K':
            b.e('cal _sk%s' % t)
            b.e('inc %s,XSP' % ('0x2' if es <= 2 else '0x4'))
    live = None
    if loop:
        if outer == 'A':
            b.e('j ne,L2')
            b.e('ldw (_gi3),0x1')
            b.e('L2:')
            b.e('inc 0x1,{ctr}')
            b.e('cp {ctr},0x4')
            b.e('j lt,L1')
            last.append('ctr')
        else:
            fixed['ctr'] = 'IZ'
        live = {'ctr': (-1, len(b.seq) + 1)}
    out = b.colour(fixed=fixed, first=first + [x for x in efirst if x in ('T8', 'Y', 'ZX')] + pfirst + [x for x in efirst if x not in ('T8', 'Y', 'ZX')], pref=pref, last=last, params=('G', 'ctr'), live=live)
    out = unmark(backprop(forward(out)))
    if loop:
        if outer == 'A':
            return out + ['ret']
        return ['push IZ', 'ld IZ,0x0', 'L1:'] + out + ['inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L1', 'pop IZ', 'ret']
    if outer in 'CA':
        return out + ['ret ne', 'ldw (_gi3),0x1', 'L1:', 'ret']
    return out + ['ret']


def o3_long_b(I):
    out = long_b_special('l', I)
    return ['lda XBC,0x10' if x == 'ld XBC,0x10' else x for x in out]


def _endline(b, s):
    rb, re_ = b.reg['B'], b.reg['END']
    n = 4 * s
    if rb == re_:
        return 'inc %s,X%s' % (hx(n & 7), re_) if n <= 8 else 'lda X%s,X%s+%s' % (re_, re_, hx(n))
    return 'lda X%s,X%s+%s' % (re_, rb, hx(n))


def bc_o3_loop(t, V, outer):
    """-O3: for (i = 0; i < 4; i++) outer = (h<t>a[i] = V): a pointer walk; a loop-invariant value is computed (and
    a plain global destination stored) before the loop; destination addresses are hoisted"""
    es = ES[t]
    b = Body()
    for n in ('V', 'K', 'GL'):
        b.w(**{n: 32 if es == 4 else 16})
    first, pref = [], {}
    off = GS_OFF[t] if outer == 'D' else 0
    gs = '_gs%s' % (' + ' + hx(GS_OFF[t]) if GS_OFF[t] else '')
    k = '%s %%s,0x7' % ('ldb' if es == 1 else 'ldw')
    n_alias = V == 'N' and '_gi' == '_g%s' % t           # !gi read while gi is the destination: not hoisted
    hoist = V in 'KGN' and not n_alias and not (V == 'K' and es == 4 and outer != 'G')
    pinned = (V == 'B' and (SIGNED[t] or es == 1)) or n_alias or (V == 'K' and es == 4 and outer != 'G')
    # destination address (families b): before the array for K / G, after the S pointer for S
    def dest_addr():
        if outer == 'M':
            b.e('lda {SP:x},%s' % gs)
        elif outer == 'E':
            b.e('lda {SP:x},_g%sa + %s' % (t, hx(2 * es)))
        elif outer == 'P':
            b.e('ld {SP:x},(_g%sp)' % t)
        elif outer == 'D':
            b.e('ld {SP:x},(_gps)')
            if off:
                b.e('lda {SP:x},{SP:x}+%s' % hx(off))
    if outer in 'MEPD' and V != 'S':
        dest_addr()
    b.e('lda {B:x},_h%sa' % t)
    if V == 'S':
        b.e('lda {SV:x},{B:x}+%s' % hx(es))
        if outer in 'MEPD':
            dest_addr()
    if V == 'B':
        b.e('lda {WP:x},_w%sa + %s' % (t, hx(3 * es)))
    vr = R('V', es)
    if hoist:
        if V == 'K':
            if es == 4:
                b.e('ld {V:x},0x7')
                b.e('ld (_g%s),{V:x}' % t)
            elif outer == 'G':
                b.e(k % '(_g%s)' % t)
        elif V == 'G':
            b.e('ld %s,(_v%s)' % (vr, t))
            if outer == 'G':
                b.e('ld (_g%s),%s' % (t, vr))
        else:
            b.e('cpw (_gi),0x0')
            b.e('scc eq,{V}')
            if es == 4:
                b.e('exts {V:x}')
            b.e('ld (_g%s),%s' % (t, vr))
    b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
    b.e('ENDDEF')
    k_end = len(b.seq) - 1
    b.seq[k_end].temps = ['END', 'B']
    b.e('L1:')
    mode = '({PTR:x}+:%d)' % es
    if V == 'K' and not hoist or (V == 'K' and es == 4):
        b.e('ld {K2:x},0x7')
        b.e('ld %s,{K2:x}' % mode)
        b.w(K2=32)
        tail = '{K2:x}'
        pinned_t = 'K2'
    elif V == 'K':
        b.e(k % mode)
        tail = None
    else:
        if V == 'S':
            b.e('ld %s,({SV:x})' % vr)
        elif V == 'N' and n_alias:
            b.e('ld {GL},(_gi)')
            b.e('cp {GL},0x0')
            b.e('scc eq,{V}')
            if es == 4:
                b.e('exts {V:x}')
        elif V == 'B':
            if es == 1:
                b.e('ld {V:b},({WP:x})')
                b.e('add {V:b},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V}')
                    b.e('divs {V},0x10')
                    b.e('ld {V:b},{V:h}')
                else:
                    b.e('and {V:b},0xf')
            elif es == 2:
                b.e('ld {V},({WP:x})')
                b.e('add {V},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V:x}')
                    b.e('divs {V:x},0x10')
                    b.e('ld {V},{V:q}')
                else:
                    b.e('and {V},0xf')
            else:
                b.e('ld {V:x},({WP:x})')
                b.e('add {V:x},(_v%s)' % t)
                b.e('and {V:x},0xf')
        b.e('ld %s,%s' % (mode, vr))
        tail = vr
    if outer == 'G' and not hoist:
        b.e('ld (_g%s),%s' % (t, tail))
    elif outer in 'MEPD':
        b.e((k % '({SP:x})') if tail is None else 'ld ({SP:x}),%s' % tail)
    b.e('cp {PTR:x},{END:x}')
    b.e('j ult,L1')
    n = len(b.seq)
    live = {}
    for x in ('PTR', 'END', 'SP', 'SV', 'WP') + (('V',) if hoist else ()):
        for i, ins in enumerate(b.seq):
            if x in ins.temps or (x == 'END' and i == k_end):
                live[x] = (i, n)
                break
    fixed = {}
    if pinned:
        first.append('V' if V != 'K' else 'K2')
        pref['V'] = 'WA'
        pref['K2'] = 'WA'
    if V == 'K' and es == 4:
        fixed['K2'] = 'WA'
        if hoist:
            fixed['V'] = 'WA'
    order = ['PTR', 'END', 'SV', 'WP', 'V', 'SP']
    if not pinned:
        pref['B'] = 'END'
    out = b.colour(fixed=fixed, first=first, pref=pref, live=live, order=order, last=['B'], coalesce=False)
    out = [_endline(b, es) if x == 'ENDDEF' else x for x in out]
    return out + ['ret']


def bc_o3_loop_c(t, X):
    """-O3 contexts C (compare) and V (local) in a loop: a pointer walk"""
    es = ES[t]
    b = Body()
    b.w(V=32 if es == 4 else 16, K2=32)
    first, pref, fixed = [], {}, {}
    if X == 'C' and t == 'w':
        b.e('ld {G},(_gi)')
    elif X == 'C' and es == 4:
        b.e('ld {G},(_gi)')
        b.e('exts {G:x}')
        fixed['G'] = 'HL'
    b.e('lda {B:x},_h%sa' % t)
    if X == 'V':
        b.e('ld %s,(_v%s)' % (R('V', es), t))
    b.e('ld {PTR:x},{B:x}', copy=('PTR', 'B'))
    b.e('ENDDEF')
    k_end = len(b.seq) - 1
    b.seq[k_end].temps = ['END', 'B']
    b.e('L1:')
    if X == 'V':
        b.e('ld ({PTR:x}+:%d),%s' % (es, R('V', es)))
    else:
        if es == 4:
            b.e('ld {K2:x},0x2')
            b.e('ld ({PTR:x}),{K2:x}')
            fixed['K2'] = 'WA'
            b.e('cp {G:x},0x2')
        else:
            b.e('%s ({PTR:x}),0x2' % ('ldb' if es == 1 else 'ldw'))
            b.e('cp {G},0x2' if t == 'w' else 'cpw (_gi),0x2')
        b.e('j ne,L2')
        b.e('ldw (_gi3),0x1')
        b.e('L2:')
        b.e('inc %s,{PTR:x}' % hx(es))
    b.e('cp {PTR:x},{END:x}')
    b.e('j ult,L1')
    n = len(b.seq)
    live = {}
    for x in ('PTR', 'END', 'V', 'G'):
        for i, ins in enumerate(b.seq):
            if x in ins.temps or (x == 'END' and i == k_end):
                live[x] = (i if x != 'G' else -1, n)
                break
    if X == 'V':
        if es == 1:
            b.e('%s {V}' % ('exts' if SIGNED[t] else 'extz'))
        b.e('ld (_gi3),{V}')
    if es != 4:
        pref['B'] = 'END'
    out = b.colour(fixed=fixed, first=first, pref=pref, live=live, order=['PTR', 'END', 'G', 'V'], last=['B'],
                   coalesce=False)
    out = [_endline(b, es) if x == 'ENDDEF' else x for x in out]
    return out + ['ret']


def o3_long_b_loop():
    return ['dec 0x8,XSP', 'push XIZ', 'lda XBC,_hla', 'lda XWA,_wla + 0xc', 'ld (XSP+0x4),XWA', 'ld XIZ,XBC',
            'lda XWA,XBC+0x10', 'ld (XSP+0x8),XWA', 'L1:', 'ld XWA,(XSP+0x4)', 'ld XWA,(XWA)', 'add XWA,(_vl)',
            'lda XBC,0x10', 'cal C9H_remls', 'ld (XIZ+:4),XHL', 'ld (_gl),XHL', 'cp XIZ,(XSP+0x8)', 'j ult,L1',
            'pop XIZ', 'inc 0x8,XSP', 'ret']


def bc_xo(t, I, V, outer):
    """-O3 -XS -Xr, the index a parameter (a b c): the -Xr form with -O's constant reuse, base CSE (S), the
    compare against gi folded, the char argument extended in its own register; a copy of the parameter that
    survives goes first"""
    es = ES[t]
    b = Body()
    b.w(p=pwidth(I))
    for n in ('V', 'K', 'RV', 'AR', 'G2', 'G5'):
        b.w(**{n: 32 if es == 4 else 16})
    b.w(R8=8, G2=16, G5=16)
    fixed, first, pref, last = {'p': 'WA'}, [], {}, []
    off = GS_OFF[t] if outer == 'D' else 0
    ptr_late = outer in 'PD' and V == 'S'
    ptr_sym = '_g%sp' % t if outer in 'PR' else '_gps'
    if outer in 'CA':
        V = 'K'
    konst = 2 if outer in 'CA' else 7
    if outer in 'CA':
        if t == 'w' or es == 4:
            b.e('ld {G},(_gi)')
            if es == 4:
                fixed['G'] = 'HL'
            if outer == 'A':
                b.e('cp {G},0x5')
                b.e('ret ge')
            if es == 4:
                b.e('exts {G:x}')
            last.append('G')
        elif outer == 'A':
            b.e('ld {G5},(_gi)')
            b.e('cp {G5},0x5')
            b.e('ret ge')
    if outer in 'PDR' and not ptr_late:
        b.e('ld {P:x},(%s)' % ptr_sym)
        if off:
            first.append('P')
        else:
            last.insert(0, 'P')
    k_el = len(b.seq)
    mode = xr_elem(b, es, I, '_h%sa' % t, opt=True)
    first_el = b.seq[k_el]
    if V == 'S':
        first += b.early + ['B']
    if outer == 'R':
        b.e('ld %s,%s' % (R('RV', es), mode))
        b.e('ld ({P:x}),%s' % R('RV', es))
        fixed['RV'] = 'HL'
        out = b.colour(fixed=fixed, first=first, pref=pref, last=last)
        return out + ['ret']
    tail = None
    kb = '%s %%s,%s' % ('ldb' if es == 1 else 'ldw', hx(konst))
    if V == 'K':
        if es == 4:
            b.e('ld {K:x},%s' % hx(konst))
            b.e('ld %s,{K:x}' % mode)
            fixed['K'] = 'WA'
            tail = '{K:x}'
        else:
            b.e(kb % mode)
    else:
        vr = R('V', es)
        if V == 'G':
            b.e('ld %s,(_v%s)' % (vr, t))
            if outer == 'K' and es > 1:
                first.insert(0, 'V')
                pref['V'] = 'WA'
        elif V == 'S':
            b.e('ld %s,({B:x}+%s)' % (vr, hx(es)))
        elif V == 'N':
            b.e('cpw (_gi),0x0')
            b.e('scc eq,{V}')
            if es == 4:
                b.e('exts {V:x}')
        elif V == 'B':
            first.insert(0, 'V')
            pref['V'] = 'WA'
            w3 = '(_w%sa + %s)' % (t, hx(3 * es))
            if es == 1:
                b.e('ld {V:b},%s' % w3)
                b.e('add {V:b},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V}')
                    b.e('divs {V},0x10')
                    b.e('ld {R8:b},{V:h}')
                    pref['R8'] = 'V'
                    vr = '{R8:b}'
                else:
                    b.e('and {V:b},0xf')
            elif es == 2:
                b.e('ld {V},%s' % w3)
                b.e('add {V},(_v%s)' % t)
                if SIGNED[t]:
                    b.e('exts {V:x}')
                    b.e('divs {V:x},0x10')
                    b.e('ld {R8},{V:q}')
                    b.w(R8=16)
                    pref['R8'] = 'V'
                    vr = '{R8}'
                else:
                    b.e('and {V},0xf')
            else:
                if SIGNED[t]:
                    return None
                b.e('ld {V:x},%s' % w3)
                b.e('add {V:x},(_v%s)' % t)
                b.e('and {V:x},0xf')
        b.e('ld %s,%s' % (mode, vr))
        tail = vr
    if outer == 'G':
        b.e(kb % '(_g%s)' % t if tail is None else 'ld (_g%s),%s' % (t, tail))
    elif outer == 'M':
        d = '(_gs%s)' % (' + ' + hx(GS_OFF[t]) if GS_OFF[t] else '')
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer == 'E':
        d = '(_g%sa + %s)' % (t, hx(2 * es))
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer in 'PD':
        if ptr_late:
            b.e('ld {P:x},(%s)' % ptr_sym)
        d = '({P:x}%s)' % ('+' + hx(off) if off else '')
        b.e(kb % d if tail is None else 'ld %s,%s' % (d, tail))
    elif outer in 'CA':
        if es == 4:
            b.e('cp {G:x},0x2')
        elif t == 'w':
            b.e('cp {G},0x2')
        elif outer == 'A':
            b.e('ld {G2},(_gi)')
            b.e('cp {G2},0x2')
        else:
            b.e('cpw (_gi),0x2')
    elif outer in 'KV':
        if es == 1:
            b.e('%s {V}' % ('exts' if SIGNED[t] else 'extz'))
            if outer == 'K':
                b.e('ld {AR},{V}', copy=('AR', 'V'))
                fixed['AR'] = 'WA'
            else:
                b.e('ld (_gi3),{V}')
        elif outer == 'K':
            b.e('ld %s,%s' % (R('AR', es), R('V', es)), copy=('AR', 'V'))
            fixed['AR'] = 'WA'
        else:
            b.e('ld (_gi3),{V}')
    out = b.colour(fixed=fixed, first=first, pref=pref, last=last, params=('p', 'G'))
    # a surviving copy of the index parameter goes first
    if first_el.copy and first_el.copy[1] == 'p' and b.reg.get(first_el.copy[0]) != b.reg['p'] and I in 'ac':
        txt = first_el.text.format(**{n: Reg(r) for n, r in b.reg.items()})
        if txt in out:
            out.remove(txt)
            out.insert(0, txt)
    if outer in 'CA':
        return out + ['ret ne', 'ldw (_gi3),0x1', 'L1:', 'ret']
    if outer == 'K':
        return out + ['j .sk%s' % t]
    return out + ['ret']


# ==============================================================================================================
# the driver
# ==============================================================================================================
SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
PROBE = 'corpus/probes/elrd.c'                     # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-3-micro-elrd/out/v423/%s/probes/elrd.asm')
_SYM = re.compile(r'(?<![\w.])([_.])([A-Za-z]\w*)')


def predict(name, set_):
    """the code of the probe's function `name` (the probe's symbols), lines 'op args'"""
    return (bc_predict if name.startswith('bc_') else er_predict)(name, set_)


def _fmt(x):
    x = x.strip()
    if x.endswith(':'):
        return x
    op, _, a = x.partition(' ')
    a = re.sub(r',\s+', ',', a) if re.search(r'\w \+ ', a) else a.replace(' ', '')
    return '\t' + op + ('\t' + a if a else '')


def whole(f, set_='none'):
    """the oracle's lines after the label of function f, or None outside the probe's shapes"""
    if set_ not in SETS:
        return None
    r = classify(f)
    if r is None:
        return None
    name, c = r
    xr = set_ in ('Xr', 'O3XSXr')
    if c.callee_cdecl is not None and c.callee_cdecl == xr:     # a sink call must follow the set's convention
        return None
    sub, owner = {}, {}
    for canon, decl in c.roles:                                  # the probe's equality pattern, both ways
        if canon in sub and sub[canon] is not decl:
            return None
        sub[canon] = decl
    for canon, decl in sub.items():
        if owner.setdefault(id(decl), canon) != canon:
            return None
    try:
        lines = predict(name, set_)
    except Exception:
        return None
    if not lines:
        return None
    out = []
    for x in lines:
        bad = []

        def rep(m):
            d = sub.get('_' + m.group(2))
            if d is None:
                bad.append(m.group(0))
                return m.group(0)
            return m.group(1) + d.name
        y = _SYM.sub(rep, x)
        if bad:
            return None
        out.append(_fmt(y))
    return out


def _oracle(path):
    import listing
    d = listing.split(open(path, encoding='latin-1').read())
    res = {}
    for k, v in d.items():
        body = v[v.index(k + ':') + 1:]
        res[k[1:]] = listing.normalise_labels([l for l in body if 'section' not in l])
    return res


def check(set_, probe=PROBE, oracle=None, show=0):
    import frontend
    import listing
    unit = frontend.load(probe, [], [], adecl=set_ in ('Xr', 'O3XSXr'))
    want = _oracle(oracle or ORACLE % set_)
    fam = collections.OrderedDict()
    shown = 0
    for f in unit.functions:
        k = f.name[:4]
        st = fam.setdefault(k, [0, 0, 0])
        got = whole(f, set_)
        w = want.get(f.name)
        if got is None:
            st[2] += 1
            continue
        got = listing.normalise_labels(got)
        if got == w:
            st[0] += 1
        else:
            st[1] += 1
            if shown < show:
                shown += 1
                i = listing.diff_first(w or [], got) or 0
                print('---- %s (first difference at line %d)' % (f.name, i))
                for j in range(max(0, i - 2), max(len(w or []), len(got))):
                    print('  %-34s | %s' % ((w or [])[j] if j < len(w or []) else '', got[j] if j < len(got) else ''))
    tot = [sum(v[i] for v in fam.values()) for i in range(3)]
    for k, (a, b, d) in fam.items():
        print('%-6s exact %4d  wrong %4d  declined %4d' % (k, a, b, d))
    print('%s: exact %d, wrong %d, declined %d of %d' % (set_, tot[0], tot[1], tot[2], sum(tot)))
    return tot


if __name__ == '__main__':
    a = sys.argv[1:]
    if not a or a[0] != '--check' or len(a) < 2:
        print(__doc__)
        sys.exit(2)
    opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d
    for s in (SETS if a[1] == 'all' else [a[1]]):
        check(s, probe=opt('--probe', PROBE), oracle=opt('--oracle'), show=int(opt('--show', 0)))
