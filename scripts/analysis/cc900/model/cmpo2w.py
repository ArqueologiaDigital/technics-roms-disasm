#!/usr/bin/env python3
"""cmpordl2_ast.py -- the cc900 oracle's code for the functions of probe cmpordl2.c (corpus/probes/cmpordl2.c, oracle
run 2026-11-10-18-micro-cmpordl2), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 cmpordl2_ast.py --check SET [--show N] [--only REGEX]    score against the oracle listing (exact / wrong /
                                                                     declined); run with the model directory on sys.path

The function is classified from its AST alone: `void f(int c) { int t = g; if (L op R) g3 = K; }` with op < or ==
and L, R operand kinds of the probe (int, long and char families); the real symbols, member offsets, element
offsets and constants are used.  The code is built from a template (rules: evaluation order, compare forms, call
conventions, CSE under -O) whose registers are roles; the roles come from tables fitted against the oracle.
Anything outside the probe's shapes returns None.  The rules are in cmpordl2-FAMILIES.md beside this file.
"""
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
PROBE = 'corpus/probes/cmpordl2.c'                 # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = __import__('os').path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-10-18-micro-cmpordl2/out/v423/%s/probes/cmpordl2.asm')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


# --------------------------------------------------------------------------------------------- types and operands

def tl(ty):
    """type letter: c char, b unsigned char, i int, u unsigned int, l long, n unsigned long"""
    if ty is None or ty.kind != 'int':
        return None
    return {(1, True): 'c', (1, False): 'b', (2, True): 'i', (2, False): 'u', (4, True): 'l', (4, False): 'n'}.get(
        (ty.size, ty.signed))


ES = {'c': 1, 'b': 1, 'i': 2, 'u': 2, 'l': 4, 'n': 4}


def hx(v):
    return '0x%x' % v


class Op:
    """a compare operand.  k: kind letter of the probe
    K val                      a constant
    G sym                      a global scalar
    P ptr off                  a global pointer's target at a constant offset (*p, p[k]; the probe's P and I)
    A ptr off                  an int array member through a global struct pointer at the parameter (hps->a[c])
    X sym                      an element of a global char array at the parameter (hca[c])
    Y sym                      an element of a global array at the local (hia[t])
    C dst src                  an explicit integral cast of a G or P operand (the probe's Z U W V)
    S sym n                    an element of a global long array at the parameter, shifted right by n (hla[c] >> 16)
    F fn arg                   a call of a global function with one argument (a G, or an S-like element)
    B ptr mask                 a long pointer's target masked by a constant (*hpl & 3)
    imp: the type an implicit conversion of the whole operand gives (None: none)"""

    def __init__(self, k, t, **kw):
        self.k, self.t = k, t
        self.imp = None
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s %s %s)' % (self.k, self.t, {k: v for k, v in self.__dict__.items() if k not in ('k', 't')})


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def gname(d):
    need(d.storage in ('extern', ''))                     # (a static object's or function's symbol is not checked)
    return '_' + d.name


def global_scalar(x):
    """load of a global scalar variable -> (decl, type letter)"""
    x = cg.strip(x)
    if x.k == 'load':
        d = var_of(x.e)
        if d is not None and d.kind == 'global' and tl(d.ty) is not None and tl(x.ty) == tl(d.ty):
            return d
    return None


def global_ptr(x):
    x = cg.strip(x)
    if x.k == 'load':
        d = var_of(x.e)
        if d is not None and d.kind == 'global' and d.ty is not None and d.ty.kind == 'ptr':
            return d
    return None


def global_array(b):
    b = cg.strip(b)
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array':
        return b.decl
    return None


def const_of(n, implicit=False):
    n = cg.strip(n)
    while implicit and n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    if n.k == 'const' and n.value is not None and not isinstance(n.value, float):
        return n.value
    return None


def index_decl(i):
    i = cg.strip(i)
    if i.k == 'load':
        d = var_of(i.e)
        if d is not None and d.kind in ('param', 'local') and tl(d.ty) == 'i' and tl(i.ty) == 'i':
            return d
    return None


def load_kind(n, ctx):
    """a load node -> Op (G P A X Y)"""
    need(n.k == 'load')
    t = tl(n.ty)
    need(t is not None)
    x = cg.strip(n.e)
    if x.k == 'var':
        d = global_scalar(n)
        need(d is not None)
        return Op('G', t, sym=gname(d))
    if x.k == 'deref':
        p = global_ptr(x.e)
        need(p is not None and tl(p.ty.base) == t)
        return Op('P', t, ptr=gname(p), off=0, deref=True)
    if x.k == 'index':
        b = cg.strip(x.base)
        k = const_of(x.idx)
        p = global_ptr(b)
        if p is not None:
            need(k is not None and 0 <= k <= 8 and tl(p.ty.base) == t)
            return Op('P', t, ptr=gname(p), off=k * ES[t], deref=False)
        a = global_array(b)
        if a is not None:
            need(tl(a.ty.base) == t and k is None)
            d = index_decl(x.idx)
            need(d is not None)
            if d is ctx['param']:
                return Op('X', t, sym=gname(a))
            need(d is ctx['local'])
            return Op('Y', t, sym=gname(a))
        if b.k == 'member' and b.arrow:
            p = global_ptr(b.base)
            need(p is not None and b.ty is not None and b.ty.kind == 'array' and tl(b.ty.base) == t)
            need(k is None)
            d = index_decl(x.idx)
            need(d is not None and d is ctx['param'])
            return Op('A', t, ptr=gname(p), off=cg.member_offset(b))
    raise Decline()


def operand(n, ctx):
    """a compare side -> Op (implicit conversion recorded in .imp)"""
    n = cg.strip(n)
    imp = None
    if n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        imp = tl(n.ty)
        need(imp is not None)
        n = cg.strip(n.e)
    if n.k == 'const':
        v = const_of(n)
        need(v is not None and tl(n.ty) is not None)
        o = Op('K', tl(n.ty), val=v)
    elif n.k == 'load':
        o = load_kind(n, ctx)
    elif n.k == 'cast' and n.kind == 'IntegralCast' and n.explicit:
        d = tl(n.ty)
        need(d is not None)
        s = load_kind(cg.strip(n.e), ctx)
        need(s.k in ('G', 'P'))
        o = Op('C', d, src=s)
    elif n.k == 'bin' and n.op == '>>':
        s = load_kind(cg.strip(n.l), ctx)
        k = const_of(n.r)
        need(s.k == 'X' and s.t == 'l' and k == 16 and tl(n.ty) == 'l')
        o = Op('S', 'l', sym=s.sym, n=k)
    elif n.k == 'bin' and n.op == '&':
        s = load_kind(cg.strip(n.l), ctx)
        k = const_of(n.r, True)
        need(s.k == 'P' and s.off == 0 and s.deref and s.t == 'l' and k == 3 and tl(n.ty) == 'l')
        o = Op('B', 'l', ptr=s.ptr, mask=k)
    elif n.k == 'call':
        fn = cg.strip(n.fn)
        need(fn.k == 'var' and fn.decl.kind in ('func', 'global') and len(n.args) == 1)
        t = tl(n.ty)
        a = cg.strip(n.args[0])
        need(a.k == 'load')
        arg = load_kind(a, ctx)
        sp = re.sub(r'\s+', ' ', fn.decl.ty.spell if fn.decl.ty is not None else '')
        m = re.match(r'^(char|int|long) \((int|long)\) __attribute__\(\(tlcs900_([ac])decl\)\)$', sp)
        need(m is not None and m.group(1) == {'c': 'char', 'i': 'int', 'l': 'long'}.get(t)
             and m.group(2) == {'i': 'int', 'l': 'long'}.get(arg.t))
        o = Op('F', t, fn=gname(fn.decl)[1:], arg=arg, conv=m.group(3))
    else:
        raise Decline()
    o.imp = imp
    return o


# The probe's operand kinds per family (the compare's operand type): kind letter -> test of the Op
def _cast(o, d, s, sk):
    return o.k == 'C' and o.t == d and o.src.k == sk and o.src.t == s


KINDS = {
    'i': {
        'K': lambda o: o.k == 'K' and o.t == 'i',
        'G': lambda o: o.k == 'G' and o.t == 'i',
        'P': lambda o: o.k == 'P' and o.t == 'i' and o.off == 0 and o.deref,
        'I': lambda o: o.k == 'P' and o.t == 'i' and o.off != 0,
        'A': lambda o: o.k == 'A' and o.t == 'i',
        'Y': lambda o: o.k == 'Y' and o.t == 'i',
        'Z': lambda o: _cast(o, 'i', 'c', 'G'),
        'U': lambda o: _cast(o, 'i', 'b', 'G'),
        'F': lambda o: o.k == 'F' and o.t == 'i' and o.arg.k == 'G' and o.arg.t == 'i',
    },
    'l': {
        'K': lambda o: o.k == 'K' and o.t == 'l',
        'G': lambda o: o.k == 'G' and o.t == 'l',
        'P': lambda o: o.k == 'P' and o.t == 'l' and o.off == 0 and o.deref,
        'I': lambda o: o.k == 'P' and o.t == 'l' and o.off != 0,
        'Y': lambda o: o.k == 'Y' and o.t == 'l',
        'Z': lambda o: _cast(o, 'l', 'c', 'G'),
        'W': lambda o: _cast(o, 'l', 'i', 'G'),
        'V': lambda o: _cast(o, 'l', 'c', 'P') and o.src.off == 0 and not o.src.deref,
        'U': lambda o: _cast(o, 'n', 'b', 'G'),
        'S': lambda o: o.k == 'S',
        'F': lambda o: o.k == 'F' and o.t == 'l' and o.arg.k == 'X' and o.arg.t == 'l',
        'B': lambda o: o.k == 'B',
    },
    'c': {
        'K': lambda o: o.k == 'K' and o.t == 'i',
        'G': lambda o: o.k == 'G' and o.t == 'c',
        'P': lambda o: o.k == 'P' and o.t == 'c' and o.off == 0 and o.deref,
        'I': lambda o: o.k == 'P' and o.t == 'c' and o.off != 0,
        'X': lambda o: o.k == 'X' and o.t == 'c',
        'Y': lambda o: o.k == 'Y' and o.t == 'c',
        'W': lambda o: _cast(o, 'b', 'n', 'G'),
        'F': lambda o: o.k == 'F' and o.t == 'c' and o.arg.k == 'G' and o.arg.t == 'i',
    },
}


def kind_letter(fam, o):
    hits = [k for k, test in KINDS[fam].items() if test(o)]
    need(len(hits) == 1)
    return hits[0]


def family(L, R):
    """the probe family of a compare from its operands' types and implicit conversions"""
    if L.k == 'K' and R.k == 'K':
        raise Decline()
    core = [o for o in (L, R) if o.k != 'K']
    if all(o.imp is None for o in (L, R)) and all(o.t == 'i' for o in (L, R)):
        return 'i'
    if all(o.imp == 'i' or (o.k == 'K' and o.imp is None and o.t == 'i') for o in (L, R)):
        return 'c'
    # long: no conversions, or the unsigned long compare of a U operand (the other side converted to unsigned long)
    u = [o for o in core if o.k == 'C' and o.t == 'n']
    for o in (L, R):
        if o.k == 'C' and o.t == 'n':
            need(o.imp is None)
        elif u:
            need(o.imp == 'n' and o.t == 'l')
        else:
            need(o.imp is None and o.t == 'l')
    return 'l'


# --------------------------------------------------------------------------------------------- function shape

def shape(f):
    """the probe's statement shape -> (param, local, local's init global, cond, store global, store value)"""
    need(len(f.params) == 1 and tl(f.params[0].ty) == 'i')
    st = cg.flat(f.body)
    need(len(st) == 2 and st[0].k == 'decl' and st[1].k == 'if')
    d, init = st[0].var, st[0].init
    need(d.kind == 'local' and tl(d.ty) == 'i' and init is not None)
    need(not getattr(d, 'addr_taken', False) and not getattr(d, 'reg', None))
    g = global_scalar(init)
    need(g is not None and tl(g.ty) == 'i')
    s = st[1]
    need(s.els is None)
    th = cg.flat(s.then) if s.then.k == 'block' else [s.then]
    need(len(th) == 1 and th[0].k == 'expr')
    e = cg.strip(th[0].e)
    need(e.k == 'bin' and e.op == '=')
    tgt = var_of(e.l)
    need(tgt is not None and tgt.kind == 'global' and tl(tgt.ty) == 'i')
    v = const_of(e.r)
    need(v is not None and 1 <= v <= 0x7fff)
    cond = cg.strip(s.cond)
    need(cond.k == 'bin' and cond.op in ('<', '==') and tl(cond.ty) == 'i')
    return f.params[0], d, g, cond, tgt, v


def classify(f):
    """-> (family, op, L kind letter, R kind letter, L Op, R Op, extra) or Decline"""
    prm, loc, g, cond, tgt, v = shape(f)
    ctx = {'param': prm, 'local': loc}
    L, R = operand(cond.l, ctx), operand(cond.r, ctx)
    fam = family(L, R)
    lk, rk = kind_letter(fam, L), kind_letter(fam, R)
    need(lk != 'K' or rk != 'K')
    for o in (L, R):
        if o.k == 'K':
            need(1 <= o.val <= 0x7f)
    ex = {'tsym': gname(g), 'store': gname(tgt), 'sval': v}
    return fam, cond.op, lk, rk, L, R, ex


# --------------------------------------------------------------------------------------------- templates
# A template is a list of items: a line 'op args' whose registers are roles ({r} a pair WA BC DE HL IX IY IZ, {r:X}
# its 32-bit name, {r:l} / {r:h} its low / high byte, {r:b} a byte register role), or ('alt', (x, y), A, B): the
# items A when roles (or literal registers) x and y are the same register, else B.

def opt(line, x, y):
    """a copy that is there only when x and y differ"""
    return ('alt', (x, y), [], [line])


def alt(x, y, a, b):
    return ('alt', (x, y), a, b)


class Gen:
    def __init__(self, s, fam, op, lk, rk, L, R, ex):
        self.s, self.fam, self.op, self.lk, self.rk, self.L, self.R, self.ex = s, fam, op, lk, rk, L, R, ex
        self.opt, self.xr = s.startswith('O3'), s.endswith('Xr')
        self.w = {'i': 2, 'l': 4, 'c': 1}[fam]
        self.out = []
        self.push = 0                                     # bytes pushed since entry, above the return address
        self.csrc = None                                  # Xr: where the parameter is (WA, or IZ when saved)

    def emit(self, *items):
        self.out.extend(items)

    def creg(self):
        """the parameter: its stack slot (cdecl) or register (Xr)"""
        if self.xr or self.csrc == 'IZ':
            return self.csrc
        return '(XSP+%s)' % hx(4 + self.push)

    def W(self, r, w=None):
        w = self.w if w is None else w
        return {1: '{%s:l}' % r, 2: '{%s}' % r, 4: '{%s:X}' % r}[w]


MEMK = {'i': 'GPIAY', 'l': 'GPIY', 'c': 'GPIXY'}


def swap_rule(lk, rk, md, side, calls, fam):
    """== : the cp takes first the operand whose code comes last (calls, then the addresses left then right, then the
    register operands right then left); a global on the left against a memory operand on the right stays first"""
    if md['l'] == 'mem' and lk == 'G' and md['r'] == 'mem':
        return False
    seq = list(calls)
    seq += [s for s in 'lr' if md[s] == 'mem' and side[s][0] != 'G']
    seq += [s for s in 'rl' if md[s] == 'reg' and s not in calls]
    return bool(seq) and seq[-1] == 'r'


def build(g, sw=None):
    """the template of a classified function; sw: an == compare whose cp takes the right operand first"""
    fam, op, xr, o3 = g.fam, g.op, g.xr, g.opt
    lk, rk, L, R = g.lk, g.rk, g.L, g.R
    tsym = g.ex['tsym']
    mirror = False
    if lk == 'K':                                         # a constant on the left: the compare is mirrored
        lk, rk, L, R = rk, lk, R, L
        mirror = True
    side = {'l': (lk, L), 'r': (rk, R)}
    need(not (sw and (op != '==' or rk == 'K')))

    fs0 = [s for s in 'lr' if side[s][0] == 'F']
    for s in fs0:                                         # the callee's convention is the set's
        need(side[s][1].conv == ('a' if xr else 'c'))
    t_live = 'Y' in (lk, rk) and not fs0                 # t in a register (not IZ) when the compare is reached

    def from_t(s):
        """-O: a load of t's global while t is live in a register reads the register"""
        k, o = side[s]
        src = o.src if o.k == 'C' else o
        return o3 and t_live and k in 'GW' and src.k == 'G' and src.sym == tsym and src.t == 'i'

    def mode(s):
        k, o = side[s]
        other = side['r' if s == 'l' else 'l'][0]
        if k == 'K':
            return 'imm'
        if from_t(s):
            return 'reg'
        if k in MEMK[fam]:
            if fam == 'l' and other == 'U' or fam == 'c' and other == 'W':
                return 'reg'                              # converted: an unsigned long / unsigned char compare
            return 'mem'
        return 'reg'

    md = {s: mode(s) for s in 'lr'}
    g.md, g.kinds = md, {'l': lk, 'r': rk}
    fs = [s for s in 'lr' if side[s][0] == 'F']
    calls = ['r', 'l'] if len(fs) == 2 else fs
    ty = 'Y' in (lk, rk)
    # the parameter's uses (calls first: the F arguments; then the other sides)
    cuses = []
    for s in calls:
        if fam == 'l':
            cuses.append(('F', s))
    for s in 'lr':
        if side[s][0] in 'AXS':
            cuses.append((side[s][0], s))
    # the parameter is read after a call: by an operand that is not a call, or by the second call's argument
    c_after_call = bool(calls) and (any(u[0] != 'F' for u in cuses) or (len(calls) == 2 and fam == 'l'))
    t_iz = ty and bool(calls)                             # t lives across a call: in IZ
    c_iz = c_after_call and (xr or (o3 and len(cuses) >= 2))   # ... kept in IZ (cdecl: only -O, read twice)
    need(not (t_iz and c_iz))
    g.c_in_wa = xr and bool(cuses) and not c_iz           # the parameter stays in WA past the prologue
    g.t_live = ty
    g.t_iz = t_iz
    frame = len(calls) == 2 and fam == 'l' and (o3 or xr)  # the first result of two long calls in a frame slot
    izw = {1: 'QIZ', 2: 'IZ', 4: 'XIZ'}
    saved = None                                          # the register that IZ's push saves
    out = g.out
    # ---- prologue
    if frame:
        out.append('dec 0x4,XSP')
        g.push += 4
    if t_iz or c_iz or (len(calls) == 2 and not frame):
        saved = 'IZ' if (t_iz or c_iz or frame) else izw[g.w]
        out.append('push %s' % saved)
        g.push += 2 if saved in ('IZ', 'QIZ') else 4
    g.csrc = 'WA' if xr else None
    if c_iz:
        out.append('ld IZ,%s' % ('WA' if xr else '(XSP+%s)' % hx(4 + g.push)))
        g.csrc = 'IZ'
    treg = None                                           # where t is: a role or IZ
    if t_iz:
        out.append('ld IZ,(%s)' % tsym)
        treg = 'IZ'
    elif ty:
        out.append('ld {t},(%s)' % tsym)
        treg = 't'
    elif not o3:
        out.append('ld {t},(%s)' % tsym)                  # the dead local is still initialised
    cpre = None
    if not xr and not o3 and lk == 'A' and rk == 'A':
        cpre = 'c'
    if cpre:
        out.insert(len(out) - (0 if o3 else 1), 'ld {c},(XSP+%s)' % hx(4 + g.push))

    cse = {}

    def cload(dst):
        """the parameter into role dst (16 bits)"""
        if cpre:
            return [opt('ld {%s},{c}' % dst, dst, 'c')]
        src = g.creg()
        if src in ('WA', 'IZ'):
            return [opt('ld {%s},%s' % (dst, src), dst, src)]
        return ['ld {%s},%s' % (dst, src)]

    def tcopy(dst):
        if treg == 'IZ':
            return [opt('ld {%s},IZ' % dst, dst, 'IZ')]
        return [opt('ld {%s},{%s}' % (dst, treg), dst, treg)]

    def tname():
        return 'IZ' if treg == 'IZ' else '{%s}' % treg

    es = ES[{'i': 'i', 'l': 'l', 'c': 'c'}[fam]]

    def scale(r):
        if es == 2:
            return ['add {%s},{%s}' % (r, r)]
        if es == 4:
            return ['sla 0x2,{%s}' % r]
        return []

    # ---- operand pieces
    def addr(s):
        """address code of a memory operand -> (items, mem)"""
        k, o = side[s]
        if k == 'G':
            return [], '(%s)' % o.sym
        if k in 'PI':
            m = '({%sp:X})' % s if not o.off else '({%sp:X}+%s)' % (s, hx(o.off))
            return ['ld {%sp:X},(%s)' % (s, o.ptr)], m
        if k == 'A':
            need(1 <= o.off <= 8)
            if o3 and 'A' in cse:
                return ['ld {%sp:X},(%s)' % (s, o.ptr)], '({%sp:X}+%s)' % (s, cse['A'])
            j, i = s + 'j', s + 'i'
            code = cload(j) + ['add {%s},{%s}' % (j, j), 'inc %s,{%s}' % (hx(o.off), j), 'ld {%s:b},{%s:l}' % (i, j),
                               'ld {%sp:X},(%s)' % (s, o.ptr)]
            if o3:
                cse['A'] = '{%s:b}' % i
            return code, '({%sp:X}+{%s:b})' % (s, i)
        if k == 'Y':
            if fam == 'c':
                return ['lda {%sb:X},%s' % (s, o.sym)], '({%sb:X}+%s)' % (s, tname())
            if o3 and 'Y' in cse:
                return ['lda {%sb:X},%s' % (s, o.sym)], '({%sb:X}+%s)' % (s, cse['Y'])
            h = s + 'h'
            code = tcopy(h) + scale(h) + ['lda {%sb:X},%s' % (s, o.sym)]
            if o3:
                cse['Y'] = '{%s}' % h
            return code, '({%sb:X}+{%s})' % (s, h)
        if k == 'X':
            e = s + 'e'
            if xr:
                return ['lda {%s:X},%s' % (e, o.sym)], '({%s:X}+%s)' % (e, g.csrc)
            if o3 and lk == 'X' and rk == 'X':
                if 'X' in cse:
                    return ['lda {%s:X},%s' % (e, o.sym)], '({%s:X}+%s)' % (e, cse['X'])
                cse['X'] = '{x}'
                return ['lda {%s:X},%s' % (e, o.sym), 'ld {x},%s' % g.creg()], '({%s:X}+{x})' % e
            i = s + 'k'
            return ['lda {%s:X},%s' % (e, o.sym), 'ld {%s},%s' % (i, g.creg()), 'extz {%s:X}' % i,
                    'add {%s:X},{%s:X}' % (i, e)], '({%s:X})' % i
        raise Decline()

    def val(s):
        """code that leaves a register operand's value -> (items, register spelling)"""
        k, o = side[s]
        v = s + 'v'
        if from_t(s):
            if k == 'G':
                return [], '{t}'
            return ['exts {t:X}'], '{t:X}'
        if k in MEMK[fam]:                                # converted memory operand: loaded
            code, m = addr(s)
            return code + ['ld %s,%s' % (g.W(v), m)], g.W(v)
        if k in 'ZUWV' and fam in 'il':
            src = o.src
            ext = 'exts' if src.t in 'ci' else 'extz'
            if fam == 'l' and k == 'W':                   # (long) int
                return ['ld {%s},(%s)' % (v, src.sym), 'exts {%s:X}' % v], '{%s:X}' % v
            if fam == 'l' and k == 'U':                   # (unsigned long) unsigned char: cleared, then the byte
                if o3:
                    return ['ld {%s:X},0x0' % v, 'ld {%s:l},(%s)' % (v, src.sym)], '{%s:X}' % v
                z = s + 'z'
                return [alt(v, z, ['ld {%s:X},0x0' % v, 'ld {%s:l},(%s)' % (v, src.sym)],
                            ['ld {%s:l},(%s)' % (z, src.sym), 'ld {%s:X},0x0' % v, 'ld {%s:l},{%s:l}' % (v, z)])], \
                    '{%s:X}' % v
            pre = []
            if src.k == 'P':
                pre = ['ld {%sq:X},(%s)' % (s, src.ptr)]
                m = '({%sq:X})' % s
            else:
                m = '(%s)' % src.sym
            z = s + 'z'
            code = pre + ['ld {%s:l},%s' % (z, m), opt('ld {%s:l},{%s:l}' % (v, z), v, z), '%s {%s}' % (ext, v)]
            if fam == 'l':
                code.append('exts {%s:X}' % v)
                return code, '{%s:X}' % v
            return code, '{%s}' % v
        if k == 'W' and fam == 'c':                       # (unsigned char) unsigned long: its low byte
            return ['ld {%sq:X},(%s)' % (s, o.src.sym), opt('ld {%s:l},{%sq:l}' % (v, s), v, s + 'q')], '{%s:l}' % v
        if k == 'S':
            j, b = s + 'j', s + 'b'
            if o3 and 'S' in cse:
                return ['lda {%s:X},%s' % (b, o.sym), 'ld {%s:X},({%s:X}+%s)' % (v, b, cse['S']),
                        'sra %s,{%s:X}' % (hx(o.n & 15), v)], '{%s:X}' % v
            if o3:
                cse['S'] = '{%s}' % j
            return cload(j) + ['sla 0x2,{%s}' % j, 'lda {%s:X},%s' % (b, o.sym), 'ld {%s:X},({%s:X}+{%s})' % (v, b, j),
                               'sra %s,{%s:X}' % (hx(o.n & 15), v)], '{%s:X}' % v
        if k == 'B':
            return ['ld {%sq:X},(%s)' % (s, o.ptr), 'ld {%s:X},({%sq:X})' % (v, s), 'and {%s:X},%s' % (v, hx(o.mask))], \
                '{%s:X}' % v
        raise Decline()

    def call(s, first, second):
        """a call operand; first: the first of two calls (its result is saved), second: the second one"""
        k, o = side[s]
        a = o.arg
        code = []
        if fam == 'l':                                    # the argument: an element at the parameter
            j, b = s + 'fj', s + 'fb'
            code += cload(j) + ['sla 0x2,{%s}' % j, 'lda {%s:X},%s' % (b, a.sym)]
            if xr:
                code += ['ld XWA,({%s:X}+{%s})' % (b, j)]
            else:
                code += ['ld {%sfa:X},({%s:X}+{%s})' % (s, b, j), 'push {%sfa:X}' % s]
                g.push += 4
        else:
            if treg == 'IZ' and a.sym == tsym and (o3 or xr):
                code += ['ld WA,IZ'] if xr else ['push IZ']
            else:
                if xr and a.sym == tsym and treg is None and not o3 and not second:
                    code += [alt('t', 'WA', [], ['ld WA,(%s)' % a.sym])]
                else:
                    code += ['ld WA,(%s)' % a.sym] if xr else ['pushw (%s)' % a.sym]
            if not xr:
                g.push += 2
        code.append('cal %s%s' % ('.' if xr else '_', o.fn))
        n = 4 if fam == 'l' else 2
        if not xr and not first:
            tot = n * (2 if second else 1)
            code.append('inc %s,XSP' % hx(tot))
            g.push -= tot
        res = {1: 'L', 2: 'HL', 4: 'XHL'}[g.w]
        if first:
            if frame:
                code.append('ld (XSP+%s),XHL' % hx(g.push - 4))
                return code, None
            keep = {1: 'QIZH', 2: 'IZ', 4: 'XIZ'}[g.w]
            code.append('ld %s,%s' % (keep, res))
            return code, keep
        return code, res

    regs = {}
    mems = {}
    # ---- calls
    for n_, s in enumerate(calls):
        code, r = call(s, len(calls) == 2 and n_ == 0, len(calls) == 2 and n_ == 1)
        out.extend(code)
        regs[s] = r
    if frame:
        regs['r'] = '(XSP+%s)' % hx(g.push - 4)
    # ---- the addresses of memory operands, left then right
    for s in 'lr':
        if md[s] == 'mem':
            code, m = addr(s)
            out.extend(code)
            mems[s] = m
    # ---- register operands that are not calls: right then left
    todo = [s for s in 'rl' if md[s] == 'reg' and s not in regs]
    g.todo = todo
    for n_, s in enumerate(todo):
        code, r = val(s)
        out.extend(code)
        if n_ == 0 and len(todo) == 2 and r == g.W(s + 'v'):
            out.append(opt('ld %s,%s' % (g.W(s + 'm'), r), s + 'm', s + 'v'))
            r = g.W(s + 'm')
        regs[s] = r
    # ---- the compare
    if sw is None:
        sw = op == '==' and swap_rule(lk, rk, md, side, calls, fam)
    first, second = ('r', 'l') if sw else ('l', 'r')
    g.first = first

    def spell(s):
        if md[s] == 'imm':
            return hx(side[s][1].val)
        return regs.get(s) or mems[s]

    if md[first] == 'mem' and md[second] == 'mem':
        out.append('ld %s,%s' % (g.W('a'), mems[first]))
        out.append('cp %s,%s' % (g.W('a'), mems[second]))
    elif md[first] == 'mem' and md[second] == 'imm':
        if fam == 'l':
            out.append('ld {a:X},%s' % mems[first])
            out.append('cp {a:X},%s' % spell(second))
        else:
            out.append('%s %s,%s' % ('cpw' if fam == 'i' else 'cpb', mems[first], spell(second)))
    else:
        out.append('cp %s,%s' % (spell(first), spell(second)))
    # ---- the branch
    uns = (fam == 'l' and 'U' in (lk, rk)) or (fam == 'c' and 'W' in (lk, rk))
    if op == '==':
        cc = 'ne'
    else:
        cc = ('u' if uns else '') + ('le' if mirror else 'ge')
    store = 'ldw (%s),%s' % (g.ex['store'], hx(g.ex['sval']))
    if saved or frame:
        out.extend(['j %s,L1' % cc, store, 'L1:'])
        if saved:
            out.append('pop %s' % saved)
        if frame:
            out.append('inc 0x4,XSP')
        out.append('ret')
    else:
        out.extend(['ret %s' % cc, store, 'L1:', 'ret'])
    return out


def template(f, s, sw=None):
    fam, op, lk, rk, L, R, ex = classify(f)
    g = Gen(s, fam, op, lk, rk, L, R, ex)
    items = build(g, sw)
    return '%s/c%s_%s/%s%s' % (s, fam, {'<': 'l', '==': 'e'}[op], lk, rk), items


# --------------------------------------------------------------------------------------------- roles
# Defaults: '=r' is another role's register.  The dead initialisation of t goes to WA, or to BC while the -Xr
# parameter is still wanted in WA; a char load goes through A (scratch z) without -O and straight into its register
# with -O; an optional copy (index from t, a moved value) is absent unless the table says otherwise.
DEFAULTS = {
    'a': 'WA', 'c': 'DE', 'x': 'DE',
    'lh': '=t', 'rh': '=t', 'lm': '=lv', 'rm': '=rv', 'lv': 'WA', 'rv': 'WA',
    'lj': 'WA', 'rj': 'WA', 'lp': 'WA', 'rp': 'BC', 'lb': 'BC', 'rb': 'BC', 'lq': 'WA', 'rq': 'WA',
    'lfa': 'WA', 'lfb': 'BC', 'lfj': 'WA', 'rfa': 'WA', 'rfb': 'BC', 'rfj': 'WA',
}


A_AFFINE = {'i': 'ZU', 'l': 'ZUV'}                       # register operands whose char load goes through A
WA_AFFINE = {'i': 'ZU', 'l': 'ZUVSB', 'c': 'W'}           # register operands computed in WA


def default_role(g, r, B):
    if r == 't' and not g.t_live:
        return 'BC' if g.c_in_wa else 'WA'
    ys = [s for s in 'lr' if g.kinds[s] == 'Y']
    if g.t_iz and r in ('lh', 'rh', 'lb', 'rb') and g.kinds[r[0]] == 'Y':
        return 'WA' if r[1] == 'h' or g.fam == 'c' else 'BC'      # t in IZ: copied to WA, the base in BC
    if len(ys) == 1 and (r == 't' or r == ys[0] + 'b'):
        # one element at t: its registers come after WA when the other operand holds WA at the compare
        o = 'r' if ys[0] == 'l' else 'l'
        busy = g.md[o] == 'reg' or (g.md[o] == 'mem' and g.first == o)
        order = ['BC', 'DE'] if busy else ['WA', 'BC']
        if g.fam == 'c':
            order = ['DE', 'BC'] if busy else ['BC', 'WA']
        return order[0] if r == 't' else order[1]
    if r == 't':
        return 'BC' if g.fam == 'c' else 'WA'
    if r in ('lz', 'rz'):
        return '=' + r[0] + 'v' if g.opt else 'WA'
    if r in ('li', 'ri'):                                 # an int member index's byte: the low byte of the first
        taken = set()                                     # pair the pointers and the other operand leave free
        for x in ('lp', 'rp', 'lb', 'rb', 'lh', 'rh', 'lv', 'rv'):
            v = B.get(x)
            if v is None or v.startswith('='):
                if x in B:
                    return None                           # not resolved yet
                continue
            taken.add(v)
        for p in ('BC', 'DE', 'HL'):
            if p not in taken:
                return {'BC': 'C', 'DE': 'E', 'HL': 'L'}[p]
        return None
    if r in ('le', 're'):                                 # a char array's base: WA, or BC beside the -Xr parameter
        return 'BC' if g.xr else 'WA'
    if r in ('lk', 'rk'):
        return 'BC'
    if r in ('lb', 'rb'):
        return 'WA' if g.fam == 'c' else 'BC'
    if r in ('lp', 'rp'):
        sd = r[0]
        o = 'r' if sd == 'l' else 'l'
        if g.md[o] == 'mem':                              # the pointer of the operand loaded for the compare: WA
            return 'WA' if sd == g.first else 'BC'
        if g.md[o] == 'reg' and g.kinds[o] != 'F':
            # beside a register operand: a char value loaded through A keeps WA; else a pointer at a displacement
            # is coloured before the value and takes WA, a plain *p after it
            if g.kinds[o] in A_AFFINE.get(g.fam, '') or not g.kinds[sd] == 'I':
                return 'BC'
        return 'WA'
    if r in ('lv', 'rv'):                                 # two register operands: the first one computed in BC
        if len(g.todo) == 2:                              # right computed first, then left
            lk_, rk_ = g.kinds['l'], g.kinds['r']
            if (g.fam == 'l' and lk_ == 'U') or (g.fam == 'c' and rk_ == 'W' and lk_ != 'G'):
                return 'WA'                               # the right one computed in WA, then moved to BC (rm)
            if g.fam == 'l' and rk_ == 'U':
                return 'BC' if r[0] == 'r' else 'WA'
            if lk_ in WA_AFFINE[g.fam]:                   # the left one wants WA: the right one goes to BC (DE
                if r[0] == 'r':                           # beside a shifted element, whose base takes BC)
                    return 'DE' if lk_ == 'S' else 'BC'
                return 'WA'
            return 'WA' if r[0] == 'r' else 'BC'
        o = 'r' if r[0] == 'l' else 'l'
        if len(g.todo) == 1 and g.md[o] == 'mem' and g.kinds[o] == 'I' and g.kinds[r[0]] not in A_AFFINE.get(g.fam, ''):
            return 'BC'
        return 'WA'
    if r == 'rm' and len(g.todo) == 2 and (
            (g.fam == 'l' and g.kinds['l'] == 'U') or (g.fam == 'c' and g.kinds['r'] == 'W' and g.kinds['l'] != 'G')):
        return 'BC'
    return DEFAULTS.get(r)


def bindings(g, items, table_row):
    """the role -> register map: the table's entries, then the defaults"""
    B = dict(table_row)
    names = set()

    def walk(its):
        for it in its:
            if isinstance(it, tuple):
                names.update(x for x in it[1] if not x[0].isupper())
                walk(it[2])
                walk(it[3])
            else:
                for m in re.finditer(r'\{([a-z0-9]+)(?::[Xlhb])?\}', it):
                    names.add(m.group(1))
    walk(items)
    for _ in range(4):
        for r in sorted(names, key=lambda x: x in ('li', 'ri')):
            if r in B and not B[r].startswith('='):
                continue
            d = B.get(r) or default_role(g, r, B)
            if d is None:
                continue
            if d.startswith('='):
                v = B.get(d[1:])
                if v is None or v.startswith('='):
                    B[r] = d
                    continue
                d = v
            B[r] = d
    need(all(not v.startswith('=') for v in B.values()) and names <= set(B))
    return B


LOWB = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
HIGHB = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}


def substitute(items, B):
    out = []
    for it in items:
        if isinstance(it, tuple):
            _, (x, y), a, b = it
            vx = x if x[0].isupper() else B[x]
            vy = y if y[0].isupper() else B[y]
            out += substitute(a if vx == vy else b, B)
            continue

        def rep(m):
            v = B[m.group(1)]
            f = m.group(2)
            if f is None:
                return v
            if f == 'X':
                return 'X' + v
            if f == 'l':
                need(v in LOWB)
                return LOWB[v]
            if f == 'h':
                need(v in HIGHB)
                return HIGHB[v]
            return v
        out.append(re.sub(r'\{([a-z0-9]+)(?::([Xlhb]))?\}', rep, it))
    return out


def fmt(lines):
    return [l if l.endswith(':') else '\t' + l.replace(' ', '\t', 1) for l in lines]


def table_row(key, s):
    row = ROLES.get(key)
    if row is None:
        return {}
    if isinstance(row, str):
        row = (row,) * 4
    txt = row[SETS.index(s)]
    return dict(x.split('=') for x in txt.split())


def whole(f, set='none'):
    """the oracle's lines for f at option set `set`, or None outside the probe's shapes"""
    if set not in SETS:
        return None
    try:
        fam, op, lk, rk, L, R, ex = classify(f)
        g = Gen(set, fam, op, lk, rk, L, R, ex)
        items = build(g)
        key = 'c%s_%s/%s%s' % (fam, {'<': 'l', '==': 'e'}[op], lk, rk)
        B = bindings(g, items, table_row(key, set))
        return fmt(substitute(items, B))
    except Decline:
        return None
    except Exception:                                     # (an AST shape the classifier did not foresee)
        return None


def check(s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(PROBE, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        got = whole(f, s)
        fs = fams.setdefault(f.name[:2], [0, 0, 0])
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
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    print('  %-36s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d   %s' % (s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


# --------------------------------------------------------------------------------------------- role table
# '<family>_<op>/<L><R>' -> the roles that differ from the defaults, one string for all four sets or a tuple
# (none, O3XS, Xr, O3XSXr).  Fitted against the oracle (fit.py / mktab.py beside this file).
ROLES = {
    'cc_e/FX': ('', '', 're=WA', 're=WA'),
    'cc_e/GX': ('', '', 'a=BC re=DE', 'a=BC re=DE'),
    'cc_e/IX': ('rk=DE', 'rk=DE', 're=DE', 're=DE'),
    'cc_e/IY': 't=DE',
    'cc_e/PW': 'lp=WA',
    'cc_e/PX': 'lp=DE',
    'cc_e/PY': 't=DE',
    'cc_e/WP': 'rp=WA',
    'cc_e/WY': 'rb=WA t=BC',
    'cc_e/XF': ('', '', 'le=WA', 'le=WA'),
    'cc_e/XI': ('', '', 'a=BC le=DE rp=BC', 'a=BC le=DE rp=BC'),
    'cc_e/XP': ('', '', 'a=BC le=DE rp=BC', 'a=BC le=DE rp=BC'),
    'cc_e/XW': ('rm=DE', 'rm=DE', 'rm=DE rq=BC rv=BC', 'rm=DE rq=BC rv=BC'),
    'cc_e/XX': ('lk=DE', 'le=BC', 'a=BC le=DE', 'a=BC le=DE'),
    'cc_e/XY': ('t=DE', 't=DE', 'a=BC le=DE rb=BC t=HL', 'a=BC le=DE rb=BC t=HL'),
    'cc_e/YW': 'lb=WA',
    'cc_e/YX': ('rk=DE t=HL', 'rk=DE t=HL', 'lb=DE t=HL', 'lb=DE t=HL'),
    'cc_e/YY': 'lb=BC t=DE',
    'cc_l/FX': ('', '', 're=WA', 're=WA'),
    'cc_l/GX': ('', '', 'a=BC re=DE', 'a=BC re=DE'),
    'cc_l/IX': ('re=BC rk=DE', 're=BC rk=DE', 'a=BC lp=BC re=DE', 'a=BC lp=BC re=DE'),
    'cc_l/PW': 'lp=WA',
    'cc_l/PX': ('lp=DE', 'lp=DE', 'a=BC lp=BC re=DE', 'a=BC lp=BC re=DE'),
    'cc_l/WP': 'rp=WA',
    'cc_l/WY': 'rb=WA t=BC',
    'cc_l/XF': ('', '', 'le=WA', 'le=WA'),
    'cc_l/XI': ('lk=DE', 'lk=DE', 'le=DE', 'le=DE'),
    'cc_l/XP': ('lk=DE', 'lk=DE', 'rp=DE', 'rp=DE'),
    'cc_l/XW': ('rm=DE', 'rm=DE', 'rm=DE rq=BC rv=BC', 'rm=DE rq=BC rv=BC'),
    'cc_l/XX': ('lk=DE', 're=BC', 'a=BC re=DE', 'a=BC re=DE'),
    'cc_l/XY': ('lk=DE t=HL', 'lk=DE t=HL', 'le=DE t=HL', 'le=DE t=HL'),
    'cc_l/YI': 't=DE',
    'cc_l/YP': 't=DE',
    'cc_l/YW': 'lb=WA',
    'cc_l/YX': ('lb=BC rk=DE t=HL', 'lb=BC rk=DE t=HL', 'a=BC lb=BC re=DE t=HL', 'a=BC lb=BC re=DE t=HL'),
    'cc_l/YY': 'rb=BC t=DE',
    'ci_e/AA': ('li=L', '', 'li=L lj=BC', ''),
    'ci_e/AY': 'rb=DE rh=WA t=DE',
    'ci_e/GY': ('', 'rh=BC t=WA', '', 'rh=BC t=WA'),
    'ci_e/IY': 'rb=DE',
    'ci_e/PA': 'lp=DE',
    'ci_e/PY': 'lp=DE',
    'ci_e/YA': 'lb=HL t=DE',
    'ci_e/YY': ('lb=HL lh=DE', 'lb=DE rb=WA t=BC', 'lb=HL lh=DE', 'lb=DE rb=WA t=BC'),
    'ci_l/AA': ('li=H lp=BC rp=DE', '', 'li=H lj=BC lp=BC rp=DE', ''),
    'ci_l/AP': 'rp=DE',
    'ci_l/GY': ('', 'rh=BC t=WA', '', 'rh=BC t=WA'),
    'ci_l/IA': 'lp=BC rp=DE',
    'ci_l/PA': 'lp=HL',
    'ci_l/YA': 'lb=IX t=HL',
    'ci_l/YI': 'lb=DE',
    'ci_l/YP': 'rp=DE',
    'ci_l/YY': ('lb=HL lh=WA rb=DE t=BC', 'lb=WA rb=DE t=BC', 'lb=HL lh=WA rb=DE t=BC', 'lb=WA rb=DE t=BC'),
    'cl_e/BI': 'lq=BC',
    'cl_e/GU': 'lv=BC rv=WA',
    'cl_e/IB': 'rq=BC',
    'cl_e/IS': ('rb=DE rj=BC', 'rb=DE rj=BC', 'lp=BC rb=DE rv=WA', 'lp=BC rb=DE rv=WA'),
    'cl_e/IU': 'lp=WA',
    'cl_e/IY': 'rb=DE',
    'cl_e/PS': 'lp=DE',
    'cl_e/PU': 'lp=WA',
    'cl_e/PY': 'lp=DE',
    'cl_e/SB': ('', '', 'rq=BC', 'rq=BC'),
    'cl_e/SI': ('lb=DE lj=BC', 'lb=DE lj=BC', 'lb=DE lv=WA rp=BC', 'lb=DE lv=WA rp=BC'),
    'cl_e/SP': 'rp=DE',
    'cl_e/SS': ('', '', 'rb=DE rj=BC', ''),
    'cl_e/SU': ('rv=DE', 'rv=DE', 'rv=DE rz=BC', 'rv=DE'),
    'cl_e/SV': ('', '', 'rq=BC rz=BC', 'rq=BC'),
    'cl_e/SY': 'rb=HL t=DE',
    'cl_e/SZ': ('', '', 'rz=BC', ''),
    'cl_e/UB': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/UG': 'rv=BC',
    'cl_e/UI': 'rp=WA rv=BC',
    'cl_e/UP': 'rp=WA rv=BC',
    'cl_e/US': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/UU': 'rv=BC',
    'cl_e/UV': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/UW': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/UY': 'rb=BC rv=BC t=WA',
    'cl_e/UZ': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/WP': 'lv=BC rp=WA',
    'cl_e/WY': ('lv=DE rb=BC t=WA', 'rh=BC t=WA', 'lv=DE rb=BC t=WA', 'rh=BC t=WA'),
    'cl_e/YS': 'lb=HL t=DE',
    'cl_e/YU': ('lb=BC lh=WA rv=DE', 'lb=BC rv=DE t=WA', 'lb=BC lh=WA rv=DE', 'lb=BC rv=DE t=WA'),
    'cl_e/YW': 'lb=BC rv=DE t=WA',
    'cl_e/YY': ('lb=HL lh=DE', 'lb=DE rb=WA t=BC', 'lb=HL lh=DE', 'lb=DE rb=WA t=BC'),
    'cl_l/BI': 'lq=BC',
    'cl_l/GU': 'lv=BC rv=WA',
    'cl_l/IB': 'rq=BC',
    'cl_l/IS': ('rb=DE rj=BC', 'rb=DE rj=BC', 'lp=BC rb=DE rv=WA', 'lp=BC rb=DE rv=WA'),
    'cl_l/IU': 'lp=WA',
    'cl_l/PS': 'lp=DE',
    'cl_l/PU': 'lp=WA',
    'cl_l/SB': ('', '', 'rq=BC', 'rq=BC'),
    'cl_l/SI': ('lb=DE lj=BC', 'lb=DE lj=BC', 'lb=DE lv=WA rp=BC', 'lb=DE lv=WA rp=BC'),
    'cl_l/SP': 'rp=DE',
    'cl_l/SS': ('', '', 'rb=DE rj=BC', ''),
    'cl_l/SU': ('rv=DE', 'rv=DE', 'rv=DE rz=BC', 'rv=DE'),
    'cl_l/SV': ('', '', 'rq=BC rz=BC', 'rq=BC'),
    'cl_l/SY': 'rb=HL t=DE',
    'cl_l/SZ': ('', '', 'rz=BC', ''),
    'cl_l/UB': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/UG': 'rv=BC',
    'cl_l/UI': 'rp=WA rv=BC',
    'cl_l/UP': 'rp=WA rv=BC',
    'cl_l/US': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/UU': 'rv=BC',
    'cl_l/UV': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/UW': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/UY': 'rb=BC rv=BC t=WA',
    'cl_l/UZ': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/WP': 'lv=BC rp=WA',
    'cl_l/WY': ('lv=DE rb=BC t=WA', 'rh=BC t=WA', 'lv=DE rb=BC t=WA', 'rh=BC t=WA'),
    'cl_l/YI': 'lb=DE',
    'cl_l/YP': 'rp=DE',
    'cl_l/YS': 'lb=HL t=DE',
    'cl_l/YU': ('lb=BC lh=WA rv=DE', 'lb=BC rv=DE t=WA', 'lb=BC lh=WA rv=DE', 'lb=BC rv=DE t=WA'),
    'cl_l/YW': 'lb=BC rv=DE t=WA',
    'cl_l/YY': ('lb=HL lh=WA rb=DE t=BC', 'lb=WA rb=DE t=BC', 'lb=HL lh=WA rb=DE t=BC', 'lb=WA rb=DE t=BC'),
}
# ROLES-END


if __name__ == '__main__':
    sys.setrecursionlimit(100000)
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only)
