#!/usr/bin/env python3
"""cmpord_ast.py -- the cc900 oracle's code for the functions of probes cmpord.c (int family: ci_*, cv_*) and
cmpordl.c (long and char families: cl_*, cc_*), at four option sets, from the model's AST of each function.
cmpordl_ast.py is the same engine restricted to the long and char families.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 cmpord_ast.py --check SET [--show N] [--only REGEX]   score against the oracle listing; run with the model
                                                                  directory on sys.path

The function is classified from its AST alone: `void f(int c) { if (L op R) g3 = K; }` or `int f(int c) { return L
< R; }`, op < or ==, L and R operand kinds of the probes; the real symbols, offsets and constants are used.  The code
comes from a template (rules: evaluation order, compare forms, conversions, CSE under -O, calls) whose registers are
roles, filled from defaults and from a table fitted against the oracle.  Anything outside the probes' shapes returns
None.  The rules are in cmpord-FAMILIES.md beside this file.
"""
import re
import sys

import codegen as cg  # noqa: E402
HOME_ = __import__('os').path.expanduser('~/')

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
PROBES = {
    'cmpord': (HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/cmpord.c',
               HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-12-micro-cmpord/out/v423/%s/probes/'
               'cmpord.asm'),
    'cmpordl': (HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/cmpordl.c',
                HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-16-micro-cmpordl/out/v423/%s/probes/'
                'cmpordl.asm'),
}
FAMILIES = 'i'                                            # the families this module answers for (cmpordl_ast: 'lc')


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


ES = {'c': 1, 'i': 2, 'l': 4}


def hx(v):
    return '0x%x' % v


def symoff(sym, off):
    return sym if not off else '%s + %s' % (sym, hx(off))


class Op:
    """a compare operand: k kind letter (the probes' letters), t the type letter of its value
    K val            constant                     G sym           global scalar
    M sym off        member of a global struct    E sym off       global array element at a constant index
    P ptr            *p of a global pointer       D ptr off       member through a global struct pointer
    X sym            global array element at the parameter
    N g              !g                           U g             -g
    B g h            g - h                        C val g         constant - g
    T c a b          c ? a : b                    S g             g << parameter
    F fn             call without arguments"""

    def __init__(self, k, t, **kw):
        self.k, self.t = k, t
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s %s %s)' % (self.k, self.t, {k: v for k, v in self.__dict__.items() if k not in ('k', 't')})


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def gname(d):
    need(d.storage in ('extern', ''))                     # (a static object's or function's symbol is not checked)
    return '_' + d.name


def unpromote(n):
    """strip an implicit integral promotion of a char to int"""
    n = cg.strip(n)
    if n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit and tl(n.ty) == 'i' and tl(cg.strip(n.e).ty) == 'c':
        return cg.strip(n.e), True
    return n, False


def gload(n):
    """a load of a global scalar -> Op G (type c i l)"""
    n = cg.strip(n)
    need(n.k == 'load')
    d = var_of(n.e)
    need(d is not None and d.kind == 'global' and tl(d.ty) in ('c', 'i', 'l') and tl(n.ty) == tl(d.ty))
    return Op('G', tl(d.ty), sym=gname(d))


def const_of(n):
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    if n.k == 'const' and n.value is not None and not isinstance(n.value, float):
        return n.value
    return None


def memload(n, prm):
    """a load of a memory operand -> Op G M E P D X"""
    n = cg.strip(n)
    need(n.k == 'load')
    t = tl(n.ty)
    need(t in ('c', 'i', 'l'))
    x = cg.strip(n.e)
    if x.k == 'var':
        return gload(n)
    if x.k == 'member' and not x.arrow:
        d = var_of(x.base)
        need(d is not None and d.kind == 'global' and d.ty is not None and d.ty.kind == 'struct')
        return Op('M', t, sym=gname(d), off=cg.member_offset(x))
    if x.k == 'member' and x.arrow:
        p = cg.strip(x.base)
        need(p.k == 'load')
        d = var_of(p.e)
        need(d is not None and d.kind == 'global' and d.ty is not None and d.ty.kind == 'ptr')
        return Op('D', t, ptr=gname(d), off=cg.member_offset(x))
    if x.k == 'deref':
        p = cg.strip(x.e)
        need(p.k == 'load')
        d = var_of(p.e)
        need(d is not None and d.kind == 'global' and d.ty is not None and d.ty.kind == 'ptr' and tl(d.ty.base) == t)
        return Op('P', t, ptr=gname(d))
    if x.k == 'index':
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array'
             and tl(b.decl.ty.base) == t)
        k = const_of(x.idx)
        if k is not None:
            need(0 <= k <= 9)
            return Op('E', t, sym=gname(b.decl), off=k * ES[t])
        i = cg.strip(x.idx)
        need(i.k == 'load' and var_of(i.e) is prm and tl(i.ty) == 'i')
        return Op('X', t, sym=gname(b.decl))
    raise Decline()


def operand(n, prm):
    """a compare side -> Op; .prom: an implicit promotion of a char value to int was stripped"""
    n, prom = unpromote(n)
    if n.k == 'cast' and n.kind == 'IntegralCast' and n.explicit and tl(n.ty) == 'l':
        e = cg.strip(n.e)                                 # (long)!g
        need(e.k == 'un' and e.op == '!' and tl(e.ty) == 'i')
        g = gload(e.e)
        need(g.t == 'l')
        o = Op('N', 'l', g=g)
    elif n.k == 'const':
        v = const_of(n)
        need(v is not None and tl(n.ty) in ('i', 'l'))
        o = Op('K', tl(n.ty), val=v)
    elif n.k == 'load':
        o = memload(n, prm)
    elif n.k == 'un' and n.op == '!':
        need(tl(n.ty) == 'i')
        g, _ = unpromote(n.e)
        g = gload(g)
        need(g.t in ('c', 'i'))
        o = Op('N', g.t, g=g)
    elif n.k == 'un' and n.op == '-':
        g, p = unpromote(n.e)
        g = gload(g)
        need(tl(n.ty) == ('i' if g.t in 'ci' else 'l') and p == (g.t == 'c'))
        o = Op('U', g.t, g=g)
    elif n.k == 'bin' and n.op == '-':
        a, pa = unpromote(n.l)
        b, pb = unpromote(n.r)
        if cg.strip(a).k == 'const':
            v = const_of(a)
            g = gload(b)
            need(v is not None and g.t in ('i', 'l') and tl(n.ty) == g.t and tl(cg.strip(a).ty) == g.t)
            o = Op('C', g.t, val=v, g=g)
        else:
            ga, gb = gload(a), gload(b)
            need(ga.t == gb.t and pa == pb == (ga.t == 'c') and tl(n.ty) == ('l' if ga.t == 'l' else 'i'))
            o = Op('B', ga.t, g=ga, h=gb)
    elif n.k == 'cond':
        c, pc = unpromote(n.c)
        c = gload(c)
        need(pc == (c.t == 'c'))
        a, pa = unpromote(n.a)
        b, pb = unpromote(n.b)
        ga, gb = gload(a), gload(b)
        need(ga.t == gb.t and pa == pb == (ga.t == 'c') and c.t in ('c', 'i'))
        o = Op('T', ga.t, c=c, a=ga, b=gb)
    elif n.k == 'bin' and n.op == '<<':
        g = gload(n.l)
        i = cg.strip(n.r)
        need(i.k == 'load' and var_of(i.e) is prm and tl(i.ty) == 'i' and g.t in ('i', 'l') and tl(n.ty) == g.t)
        o = Op('S', g.t, g=g)
    elif n.k == 'call':
        fn = cg.strip(n.fn)
        need(fn.k == 'var' and fn.decl.kind in ('func', 'global') and len(n.args) == 0)
        t = tl(n.ty)
        sp = re.sub(r'\s+', ' ', fn.decl.ty.spell if fn.decl.ty is not None else '')
        m = re.match(r'^(char|long) \(void\) __attribute__\(\(tlcs900_([ac])decl\)\)$', sp)
        need(m is not None and m.group(1) == {'c': 'char', 'l': 'long'}.get(t))
        o = Op('F', t, fn=gname(fn.decl)[1:], conv=m.group(2))
    else:
        raise Decline()
    o.prom = prom
    return o


MEMK = 'GMEPDX'
KINDS = {'i': 'KGMPEXNUBCTSD', 'l': 'KGMPEXNUBCTSDF', 'c': 'KGMPEXNUBTDF'}


def family(L, R):
    """i: int operands (cmpord); l: long; c: char (promoted to int, ! and - and g - h at int type)"""
    ts = set()
    for o in (L, R):
        if o.k == 'K':
            continue
        ts.add(o.t)
    need(len(ts) == 1)
    fam = ts.pop()
    for o in (L, R):
        if o.k == 'K':
            need(o.t == ('l' if fam == 'l' else 'i') and not o.prom)
        elif fam == 'c':
            need(o.prom == (o.k not in 'NUBT'))
        else:
            need(not o.prom)
        need(o.k in KINDS[fam])
        if o.k in 'MD':                                   # the probes' members: at 0 (int, char), not at 0 (long);
            need((o.off == 0) == (fam != 'l'))            # a displacement changes the register choice (cmpx.c
        if o.k == 'E':                                    # cx_*_i_DXi: hps->i at +2 against hia[c])
            need(o.off != 0)
    return fam


# --------------------------------------------------------------------------------------------- function shape

def shape(f):
    """-> (param, cond, context, store global, store value); context 'if' (void f: if (cond) g = K;) or 'ret'"""
    need(len(f.params) == 1 and tl(f.params[0].ty) == 'i')
    st = cg.flat(f.body)
    need(len(st) == 1)
    s = st[0]
    if s.k == 'return':
        need(tl(f.ret) == 'i' and s.value is not None)
        cond = cg.strip(s.value)
        need(cond.k == 'bin' and cond.op == '<' and tl(cond.ty) == 'i')
        return f.params[0], cond, 'ret', None, None
    need(s.k == 'if' and s.els is None and f.ret is not None and f.ret.kind == 'void')
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
    return f.params[0], cond, 'if', gname(tgt), v


def classify(f):
    prm, cond, ctx, store, sval = shape(f)
    L, R = operand(cond.l, prm), operand(cond.r, prm)
    fam = family(L, R) if not (L.k == 'K' and R.k == 'K') else None
    if fam is None:
        need(L.t == R.t)
        fam = 'l' if L.t == 'l' else 'i'                  # (a constant compare: the int and char probes alike)
    for o in (L, R):
        if o.k == 'K':
            need(0 <= o.val <= 0x7f)
    return fam, cond.op, ctx, L, R, {'store': store, 'sval': sval}


def key_of(fam, op, ctx, L, R):
    head = {'i': 'ci', 'l': 'cl', 'c': 'cc'}[fam]
    if ctx == 'ret':
        head = 'cv'
    return '%s_%s/%s%s' % (head, {'<': 'l', '==': 'e'}[op], L.k, R.k)


# --------------------------------------------------------------------------------------------- templates
# A template is a list of items: a line 'op args' whose registers are roles ({r} a pair WA BC DE HL IX IY IZ, {r:X}
# / {r:Q} its 32-bit / upper-word name, {r:l} / {r:h} its low / high byte, {r:b} a byte register role), or ('alt',
# (x, y), A, B): the items A when roles (or literal registers) x and y are the same register, else B.

def opt(line, x, y):
    return ('alt', (x, y), [], [line])


def alt(x, y, a, b):
    return ('alt', (x, y), a, b)


class Gen:
    def __init__(self, s, fam, op, ctx, L, R, ex):
        self.s, self.fam, self.op, self.ctx, self.L, self.R, self.ex = s, fam, op, ctx, L, R, ex
        self.opt, self.xr = s.startswith('O3'), s.endswith('Xr')
        self.out = []
        self.nlab = 0

    def lab(self):
        self.nlab += 1
        return 'L%d' % self.nlab


def swap_rule(md, kinds, calls):
    """== : the cp takes first the operand whose code comes last (calls, then the addresses left then right, then the
    register operands right then left); a memory operand without address code on the left against a memory operand
    on the right stays first"""
    if md['l'] == 'mem' and kinds['l'] == 'G' and md['r'] in ('mem', 'memr'):
        return False
    seq = list(calls)
    seq += [s for s in 'lr' if md[s] in ('mem', 'memr') and kinds[s] != 'G']
    seq += [s for s in 'rl' if md[s] == 'reg' and s not in calls]
    return bool(seq) and seq[-1] == 'r'


def build(g):
    fam, op, xr, o3 = g.fam, g.op, g.xr, g.opt
    L, R = g.L, g.R
    out = g.out
    # ---- constant compares fold
    if L.k == 'K' and R.k == 'K':
        v = (L.val < R.val) if op == '<' else (L.val == R.val)
        if g.ctx == 'ret':
            return ['ld HL,%s' % hx(int(v)), 'ret']
        return (['ldw (%s),%s' % (g.ex['store'], hx(g.ex['sval']))] if v else []) + ['ret']
    mirror = False
    if L.k == 'K':
        L, R = R, L
        mirror = True
    side = {'l': L, 'r': R}
    kinds = {'l': L.k, 'r': R.k}
    for s in 'lr':
        if side[s].k == 'F':
            need(side[s].conv == ('a' if xr else 'c'))
    nwide = fam == 'c' and 'N' in kinds.values()          # a char compare against !g: at int width
    w = {'i': 2, 'l': 4, 'c': 1}[fam] if not nwide else 2
    g.w = w

    def Wr(r, width=None):
        width = w if width is None else width
        return {1: '{%s:l}' % r, 2: '{%s}' % r, 4: '{%s:X}' % r}[width]

    def mode(s):
        o = side[s]
        other = side['r' if s == 'l' else 'l']
        if o.k == 'K':
            return 'imm'
        if o.k in MEMK:
            if nwide:
                return 'reg'                              # a char widened to int
            if other.k == 'T' and o.k != 'G':
                return 'memr'                             # its address in one register, kept over the branch
            return 'mem'
        return 'reg'

    md = {s: mode(s) for s in 'lr'}
    g.md, g.kinds = md, kinds
    fs = [s for s in 'lr' if kinds[s] == 'F']
    calls = ['r', 'l'] if len(fs) == 2 else fs
    cusers = [s for s in 'lr' if kinds[s] in 'XS']
    c_after_call = bool(calls) and bool(cusers)
    c_iz = c_after_call and xr
    # the parameter read twice is loaded once: -O3 and -Xr always, without options only in the int family and not
    # for two shifts
    shared_c = len(cusers) == 2 and fam != 'c' and (o3 or xr or (fam == 'i' and not kinds['l'] == kinds['r'] == 'S'))
    g.c_iz, g.calls, g.cusers = c_iz, calls, cusers
    saved = None
    # ---- prologue
    if len(calls) == 2:
        saved = {1: 'QIZ', 2: 'IZ', 4: 'XIZ'}[w if fam != 'c' else 1]
        out.append('push %s' % saved)
    elif c_iz:
        saved = 'IZ'
        out.append('push IZ')
        out.append('ld IZ,WA')
    st = {'cload': False}
    csrc = 'IZ' if c_iz else ('WA' if xr else '(XSP+0x4)')
    if shared_c and not c_iz:                             # the parameter read twice: one register, from the entry
        st['cload'] = True
        out.append(opt('ld {c},WA', 'c', 'WA') if xr else 'ld {c},(XSP+0x4)')
    early = {}
    if xr and o3 and not c_iz and not shared_c:           # -O3 -Xr: the parameter's copy moves to the entry
        for s_ in cusers:
            if kinds[s_] == 'X' and fam != 'c':
                out.append(opt('ld {%sj},WA' % s_, s_ + 'j', 'WA'))
                early[s_ + 'j'] = True

    def cto(dst):
        """the parameter into role dst"""
        if dst in early:
            return []
        code = []
        if shared_c and not c_iz:
            if not st['cload']:
                st['cload'] = True
                code.append(opt('ld {c},WA', 'c', 'WA') if xr else 'ld {c},(XSP+0x4)')
            return code + [opt('ld {%s},{c}' % dst, dst, 'c')]
        if csrc in ('WA', 'IZ'):
            return [opt('ld {%s},%s' % (dst, csrc), dst, csrc)]
        return ['ld {%s},%s' % (dst, csrc)]

    def cto_wa():
        """the parameter into WA (a shift count)"""
        if shared_c and not c_iz:
            code = []
            if not st['cload']:
                st['cload'] = True
                code.append(opt('ld {c},WA', 'c', 'WA') if xr else 'ld {c},(XSP+0x4)')
            return code + [opt('ld WA,{c}', 'c', 'WA')]
        if csrc == 'IZ':
            return ['ld WA,IZ']
        if csrc == 'WA':
            return []
        return ['ld WA,%s' % csrc]

    cse = {}

    def scale(r):
        es = ES[fam]
        if es == 2:
            return ['add {%s},{%s}' % (r, r)]
        if es == 4:
            return ['sla 0x2,{%s}' % r]
        return []

    def addr(s):
        """address code -> (items, memory operand)"""
        o = side[s]
        k = o.k
        T = md[s] == 'memr'
        if k == 'G':
            return [], '(%s)' % o.sym
        if k in 'ME':
            if T:
                return ['lda {%sq:X},%s' % (s, symoff(o.sym, o.off)), opt('ld {%sp:X},{%sq:X}' % (s, s), s + 'p', s + 'q')], \
                    '({%sp:X})' % s
            return [], '(%s)' % symoff(o.sym, o.off)
        if k == 'P':
            return ['ld {%sp:X},(%s)' % (s, o.ptr)], '({%sp:X})' % s
        if k == 'D':
            if T and o.off:                               # kept over the branch: the member's address
                return ['ld {%sp:X},(%s)' % (s, o.ptr), 'inc %s,{%sp:X}' % (hx(o.off), s)], '({%sp:X})' % s
            return ['ld {%sp:X},(%s)' % (s, o.ptr)], '({%sp:X}+%s)' % (s, hx(o.off)) if o.off else '({%sp:X})' % s
        if k == 'X':
            b = s + 'b'
            if fam == 'c':
                if xr:
                    code = ['lda {%s:X},%s' % (b, o.sym)]
                    if T and s == 'l':
                        return code + ['lda {%s:X},{%s:X}+%s' % (b, b, csrc)], '({%s:X})' % b
                    if T:
                        need(csrc == 'WA')
                        return code + ['exts XWA', 'add XWA,{%s:X}' % b], '(XWA)'
                    return code, '({%s:X}+%s)' % (b, csrc)
                if o3 and kinds['l'] == kinds['r'] == 'X':
                    if 'X' in cse:
                        return ['lda {%s:X},%s' % (b, o.sym)], '({%s:X}+%s)' % (b, cse['X'])
                    cse['X'] = '{x}'
                    return ['lda {%s:X},%s' % (b, o.sym), 'ld {x},%s' % csrc], '({%s:X}+{x})' % b
                j = s + 'j'
                return ['lda {%s:X},%s' % (b, o.sym), 'ld {%s},%s' % (j, csrc), 'extz {%s:X}' % j,
                        'add {%s:X},{%s:X}' % (j, b)], '({%s:X})' % j
            if o3 and 'X' in cse:
                code = ['lda {%s:X},%s' % (b, o.sym)]
                m = '({%s:X}+%s)' % (b, cse['X'])
            else:
                j = s + 'j'
                code = cto(j) + scale(j) + ['lda {%s:X},%s' % (b, o.sym)]
                if o3:
                    cse['X'] = '{%s}' % j
                m = '({%s:X}+{%s})' % (b, j)
                if T:
                    if s == 'l':
                        code.append('lda {%s:X},{%s:X}+{%s}' % (b, b, j))
                        m = '({%s:X})' % b
                    else:
                        code += ['exts {%s:X}' % j, 'add {%s:X},{%s:X}' % (j, b)]
                        m = '({%s:X})' % j
            return code, m
        raise Decline()

    def widen(code, byte, s):
        """a char value in byte register `byte` -> int in role {sv}"""
        v = s + 'v'
        return code + [opt('ld {%s:l},%s' % (v, byte), v, byte_pair(byte)), 'exts {%s}' % v], '{%s}' % v

    def val(s):
        """code leaving a register operand's value -> (items, register)"""
        o = side[s]
        k = o.k
        v = s + 'v'
        z = s + 'z'
        if k in MEMK:                                     # a char widened to int (cc against !g)
            code, m = addr(s)
            code = code + ['ld {%s:l},%s' % (z, m)]
            return widen(code, '{%s:l}' % z, s)
        if k == 'N':
            gg = o.g
            if fam == 'l':
                n = s + 'n'
                sc = s + 'e'
                return ['ld {%s:X},(%s)' % (n, gg.sym), 'or {%s:X},{%s:X}' % (n, n), 'scc eq,{%s}' % sc,
                        opt('ld {%s},{%s}' % (v, sc), v, sc), 'exts {%s:X}' % v], '{%s:X}' % v
            return ['%s (%s),0x0' % ('cpb' if gg.t == 'c' else 'cpw', gg.sym), 'scc eq,{%s}' % v], '{%s}' % v
        if k == 'U':
            gg = o.g
            if fam == 'l':
                return ['ld {%s:X},(%s)' % (v, gg.sym), 'cpl {%s}' % v, 'cpl {%s:Q}' % v, 'inc 0x1,{%s:X}' % v], \
                    '{%s:X}' % v
            if fam == 'c':
                code = ['ld {%s:l},(%s)' % (z, gg.sym), 'neg {%s:l}' % z]
                return byteval(code, '{%s:l}' % z, s)
            return ['ld {%s},(%s)' % (v, gg.sym), 'neg {%s}' % v], '{%s}' % v
        if k == 'B':
            if fam == 'c':
                code = ['ld {%s:l},(%s)' % (z, o.g.sym), 'sub {%s:l},(%s)' % (z, o.h.sym)]
                return byteval(code, '{%s:l}' % z, s)
            return ['ld %s,(%s)' % (Wr(v), o.g.sym), 'sub %s,(%s)' % (Wr(v), o.h.sym)], Wr(v)
        if k == 'C':
            ld = 'lda' if fam == 'l' and o3 else 'ld'     # (-O: a long constant through lda)
            return ['%s %s,%s' % (ld, Wr(v), hx(o.val)), 'sub %s,(%s)' % (Wr(v), o.g.sym)], Wr(v)
        if k == 'T':
            la, lb = g.lab(), g.lab()
            tst = '%s (%s),0x0' % ('cpb' if o.c.t == 'c' else 'cpw', o.c.sym)
            dst = '{%s:l}' % z if fam == 'c' else Wr(v)
            code = [tst, 'j eq,%s' % la, 'ld %s,(%s)' % (dst, o.a.sym), 'j %s' % lb, la + ':',
                    'ld %s,(%s)' % (dst, o.b.sym), lb + ':']
            if fam == 'c':
                return byteval(code, dst, s)
            return code, dst
        if k == 'S':
            la = g.lab()
            if fam == 'l':
                lb = g.lab()
                code = ['ld {%s:X},(%s)' % (v, o.g.sym)] + cto_wa() + [
                    'bit 0x4,A', 'j z,%s' % la, 'sla 0x0,{%s:X}' % v, la + ':', 'and A,0xf', 'j z,%s' % lb,
                    'sla A,{%s:X}' % v, lb + ':']
                return code, '{%s:X}' % v
            code = ['ld {%s},(%s)' % (v, o.g.sym)] + cto_wa() + ['and A,0xf', 'j z,%s' % la, 'sla A,{%s}' % v, la + ':']
            return code, '{%s}' % v
        raise Decline()

    def byteval(code, byte, s):
        if w == 2:
            return widen(code, byte, s)
        return code, byte

    def call(s, first):
        o = side[s]
        code = ['cal %s%s' % ('.' if xr else '_', o.fn)]
        res = {'c': 'L', 'l': 'XHL'}[fam]
        if first:
            keep = {'c': 'QIZH', 'l': 'XIZ'}[fam]
            code.append('ld %s,%s' % (keep, res))
            return code, keep
        if fam == 'c' and w == 2:
            return widen(code, 'L', s)
        return code, res

    regs, mems = {}, {}
    for n_, s in enumerate(calls):
        code, r = call(s, len(calls) == 2 and n_ == 0)
        out.extend(code)
        regs[s] = r
    for s in 'lr':
        if md[s] in ('mem', 'memr'):
            code, m = addr(s)
            out.extend(code)
            mems[s] = m
    todo = [s for s in 'rl' if md[s] == 'reg' and s not in regs]
    g.todo = todo
    for n_, s in enumerate(todo):
        code, r = val(s)
        out.extend(code)
        mv = re.match(r'^\{(%s[a-z])(:[Xl])?\}$' % s, r) if n_ == 0 and len(todo) == 2 else None
        if mv:                                            # the first of two register operands may move away
            r2 = '{%sm%s}' % (s, mv.group(2) or '')
            out.append(opt('ld %s,%s' % (r2, r), s + 'm', mv.group(1)))
            r = r2
        regs[s] = r
    # ---- the compare
    sw = op == '==' and R.k != 'K' and swap_rule(md, kinds, calls)
    first, second = ('r', 'l') if sw else ('l', 'r')
    g.first = first
    kval = None
    if R.k == 'K':
        kval = R.val
        if g.ctx == 'if' and L.k == 'N' and fam != 'l':  # !g against a constant in a condition: compared with 1
            need(kval == 7)
            kval = 1

    def spell(s):
        if md[s] == 'imm':
            return hx(kval)
        return regs.get(s) or mems[s]

    ismem = {s: md[s] in ('mem', 'memr') for s in 'lr'}
    if ismem[first] and ismem[second]:
        out.append('ld %s,%s' % (Wr('a'), mems[first]))
        out.append('cp %s,%s' % (Wr('a'), mems[second]))
    elif ismem[first] and md[second] == 'imm':
        if w == 4:
            out.append('ld {a:X},%s' % mems[first])
            out.append('cp {a:X},%s' % spell(second))
        else:
            out.append('%s %s,%s' % ('cpw' if w == 2 else 'cpb', mems[first], spell(second)))
    else:
        out.append('cp %s,%s' % (spell(first), spell(second)))
    # ---- the result
    if g.ctx == 'ret':
        true = {'<': 'gt' if mirror else 'lt', '==': 'eq'}[op]
        out.extend(['scc %s,HL' % true, 'ret'])
        need(not saved)
        return out
    cc = 'ne' if op == '==' else ('le' if mirror else 'ge')
    store = 'ldw (%s),%s' % (g.ex['store'], hx(g.ex['sval']))
    if saved:
        lab = g.lab()
        out.extend(['j %s,%s' % (cc, lab), store, lab + ':', 'pop %s' % saved, 'ret'])
    else:
        lab = g.lab()
        out.extend(['ret %s' % cc, store, lab + ':', 'ret'])
    return out


def byte_pair(b):
    return {'A': 'WA', 'C': 'BC', 'E': 'DE', 'L': 'HL'}.get(b, b.strip('{}').split(':')[0])


def template(f, s):
    fam, op, ctx, L, R, ex = classify(f)
    g = Gen(s, fam, op, ctx, L, R, ex)
    return key_of(fam, op, ctx, L, R), build(g), g


# --------------------------------------------------------------------------------------------- roles
# Defaults ('=r': another role's register); the table ROLES holds what they do not give.
DEFAULTS = {'a': 'WA', 'c': 'WA', 'x': 'DE', 'ln': 'WA', 'rn': 'WA', 'lz': 'WA', 'rz': 'WA', 'lj': 'WA', 'rj': 'WA',
            'lb': 'BC', 'rb': 'BC', 'lq': '=lp', 'rq': '=rp', 'le': '=lv', 're': '=rv'}


AFF = {'i': 'U', 'l': 'UN', 'c': 'GMEPDXNUB'}          # register operands that take WA when two are computed


def reg_gets_wa(g, s):
    """a register operand computed alone: WA, unless it is a non-affine left operand beside a right address"""
    o = 'r' if s == 'l' else 'l'
    if g.md[o] == 'memr' or (g.md[o] == 'mem' and g.kinds[o] not in 'GME'):
        return g.kinds[s] in AFF[g.fam] or s == 'r'
    return True


def default_role(g, r, B):
    fam, md, kinds, todo = g.fam, g.md, g.kinds, g.todo
    if r[1:] in ('v', 'm', 'z') and r[0] in 'lr':
        s = r[0]
        if r[1] == 'z' and g.w == 2 and fam == 'c':       # a char load before its widening: A, or its own register
            return '=%sv' % s if g.opt else 'WA'
        if kinds[s] == 'S' and len(todo) == 1:            # a shift's value beside its count in A
            o = 'r' if s == 'l' else 'l'
            if kinds[o] == 'X':
                return 'HL'
            return 'DE' if s == 'l' and kinds[o] in 'PD' else 'BC'
        if len(todo) == 2:
            lk, rk = kinds['l'], kinds['r']
            if rk == 'S' and lk != 'S':
                return 'BC' if s == 'r' else 'WA'
            if lk == 'S' and fam != 'c':
                return 'DE' if s == 'l' else 'BC'
            if lk in AFF[fam]:
                if s == 'l':
                    return 'WA'
                moved = rk == 'U' and fam != 'c'          # computed in WA, then moved to BC
                return 'WA' if (r[1] == 'v' and moved) else 'BC'
            return 'BC' if s == 'l' else 'WA'
        if len(todo) == 1 and todo[0] == s:
            o = 'r' if s == 'l' else 'l'
            if kinds[o] == 'X' and fam != 'c':            # beside an element at the parameter: WA when affine, else
                return 'WA' if kinds[s] in AFF[fam] else 'DE'      # after the element's WA and BC
            return 'WA' if reg_gets_wa(g, s) else 'BC'
        return 'WA'
    if r in ('lp', 'rp'):
        s = r[0]
        o = 'r' if s == 'l' else 'l'
        if md[o] in ('mem', 'memr'):
            if s != g.first and kinds[o] == 'X' and fam != 'c':
                return 'DE'                               # after the loaded element's WA and BC
            return 'WA' if s == g.first else 'BC'
        if kinds[o] == 'S':                               # beside a shift (its count in WA): DE on the left, BC on
            return 'DE' if s == 'l' else 'BC'             # the right
        if md[o] == 'reg' and kinds[o] != 'F' and len(todo) == 1:
            return 'BC' if reg_gets_wa(g, o) else 'WA'
        return 'WA'
    if r in ('lj', 'rj', 'lb', 'rb'):
        s = r[0]
        o = 'r' if s == 'l' else 'l'
        busy = md[o] == 'reg' or (md[o] in ('mem', 'memr') and g.first == o)
        if md[o] == 'reg' and fam != 'c' and kinds[o] not in AFF[fam] and kinds[o] not in 'FS':
            busy = False                                  # a non-affine register operand comes after the element
        if fam == 'c':
            if r[1] == 'j':
                return 'BC'
            return ('DE' if busy else 'BC') if g.xr else 'WA'
        order = ['BC', 'DE'] if busy else ['WA', 'BC']
        return order[0] if r[1] == 'j' else order[1]
    if r == 'a' and fam == 'c' and g.xr and 'X' in kinds.values():
        return 'BC'                                       # beside the -Xr parameter in WA
    return DEFAULTS.get(r)


def role_names(items):
    names = set()

    def walk(its):
        for it in its:
            if isinstance(it, tuple):
                names.update(x for x in it[1] if not x[0].isupper())
                walk(it[2])
                walk(it[3])
            else:
                for m in re.finditer(r'\{([a-z0-9]+)(?::[XQlhb])?\}', it):
                    names.add(m.group(1))
    walk(items)
    return names


def bindings(g, items, row):
    B = dict(row)
    names = role_names(items)
    for _ in range(4):
        for r in sorted(names):
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
            if f is None or f == 'b':
                return v
            if f in ('X', 'Q'):
                return f + v
            table = LOWB if f == 'l' else HIGHB
            need(v in table)
            return table[v]
        out.append(re.sub(r'\{([a-z0-9]+)(?::([XQlhb]))?\}', rep, it))
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


def whole(f, set='none', families=None):
    """the oracle's lines for f at option set `set`, or None outside the probes' shapes"""
    families = FAMILIES if families is None else families
    if set not in SETS:
        return None
    try:
        fam, op, ctx, L, R, ex = classify(f)
        if fam not in families and not (L.k == 'K' and R.k == 'K'):
            return None
        g = Gen(set, fam, op, ctx, L, R, ex)
        items = build(g)
        B = bindings(g, items, table_row(key_of(fam, op, ctx, L, R), set))
        return fmt(substitute(items, B))
    except Decline:
        return None
    except Exception:                                     # (an AST shape the classifier did not foresee)
        return None


def check(probe, s, show=0, only=None, families=None):
    import frontend
    import listing
    src, orc = PROBES[probe]
    want = listing.split(open(orc % s, encoding='latin-1').read())
    unit = frontend.load(src, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        got = whole(f, s, families)
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
    print('%-8s %-7s exact %4d  wrong %4d  declined %4d   %s' % (probe, s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


# --------------------------------------------------------------------------------------------- role table
# '<head>_<op>/<L><R>' -> the roles that differ from the defaults: one string for all four sets or a tuple (none,
# O3XS, Xr, O3XSXr).  Fitted against the oracle (fit.py / mktab.py beside this file).
ROLES = {
    'cc_e/BB': ('rz=WA', '', 'rz=WA', ''),
    'cc_e/BN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/BU': ('rz=WA', '', 'rz=WA', ''),
    'cc_e/BX': ('', '', 'lz=BC', 'lz=BC'),
    'cc_e/DN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/DX': ('lp=DE', 'lp=DE', 'a=WA lp=DE', 'a=WA lp=DE'),
    'cc_e/EN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/EX': ('', '', 'a=WA', 'a=WA'),
    'cc_e/FN': ('lv=BC', 'lv=HL', 'lv=BC', 'lv=HL'),
    'cc_e/FX': ('', '', 'rb=WA', 'rb=WA'),
    'cc_e/GN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/MN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/MT': ('lq=WA', '', 'lq=WA', ''),
    'cc_e/MX': ('', '', 'a=WA', 'a=WA'),
    'cc_e/NF': ('rv=BC', 'rv=HL', 'rv=BC', 'rv=HL'),
    'cc_e/NN': 'lv=BC rm=WA rv=WA',
    'cc_e/NX': ('', '', 'rb=BC', 'rb=BC'),
    'cc_e/PN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/PX': ('lp=DE', 'lp=DE', 'a=WA lp=DE', 'a=WA lp=DE'),
    'cc_e/TN': ('lv=WA rm=BC', 'lv=WA rm=BC rv=BC', 'lv=WA rm=BC', 'lv=WA rm=BC rv=BC'),
    'cc_e/TX': ('lz=WA', 'lz=WA', 'rb=BC', 'rb=BC'),
    'cc_e/UB': ('rz=WA', '', 'rz=WA', ''),
    'cc_e/UN': ('rv=WA', '', 'rv=WA', ''),
    'cc_e/UU': ('rz=WA', '', 'rz=WA', ''),
    'cc_e/UX': ('', '', 'lz=BC', 'lz=BC'),
    'cc_e/XB': ('', '', 'rz=BC', 'rz=BC'),
    'cc_e/XD': ('', '', 'rp=BC', 'rp=BC'),
    'cc_e/XF': ('', '', 'lb=WA', 'lb=WA'),
    'cc_e/XG': ('', '', 'a=WA', 'a=WA'),
    'cc_e/XN': ('rm=DE rv=WA', 'rm=DE rv=DE', 'lb=BC rm=DE', 'lb=BC rm=DE rv=DE'),
    'cc_e/XP': ('', '', 'rp=BC', 'rp=BC'),
    'cc_e/XT': ('', '', 'lb=BC', 'lb=BC'),
    'cc_e/XU': ('', '', 'rz=BC', 'rz=BC'),
    'cc_e/XX': ('lj=DE', 'lb=BC', '', ''),
    'cc_l/BB': ('rz=WA', '', 'rz=WA', ''),
    'cc_l/BN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/BU': ('rz=WA', '', 'rz=WA', ''),
    'cc_l/BX': ('', '', 'lz=BC', 'lz=BC'),
    'cc_l/DN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/DX': ('lp=DE', 'lp=DE', 'lp=BC', 'lp=BC'),
    'cc_l/EN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/FN': ('lv=BC', 'lv=HL', 'lv=BC', 'lv=HL'),
    'cc_l/FX': ('', '', 'rb=WA', 'rb=WA'),
    'cc_l/GN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/MN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/MT': ('lq=WA', '', 'lq=WA', ''),
    'cc_l/NF': ('rv=BC', 'rv=HL', 'rv=BC', 'rv=HL'),
    'cc_l/NN': 'lv=BC rm=WA rv=WA',
    'cc_l/NX': ('', '', 'rb=BC', 'rb=BC'),
    'cc_l/PN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/PX': ('lp=DE', 'lp=DE', 'lp=BC', 'lp=BC'),
    'cc_l/TN': ('lv=WA rm=BC', 'lv=WA rm=BC rv=BC', 'lv=WA rm=BC', 'lv=WA rm=BC rv=BC'),
    'cc_l/TX': ('lz=WA', 'lz=WA', 'rb=BC', 'rb=BC'),
    'cc_l/UB': ('rz=WA', '', 'rz=WA', ''),
    'cc_l/UN': ('rv=WA', '', 'rv=WA', ''),
    'cc_l/UU': ('rz=WA', '', 'rz=WA', ''),
    'cc_l/UX': ('', '', 'lz=BC', 'lz=BC'),
    'cc_l/XB': ('', '', 'rz=BC', 'rz=BC'),
    'cc_l/XD': ('lj=DE', 'lj=DE', 'a=WA rp=DE', 'a=WA rp=DE'),
    'cc_l/XE': ('', '', 'a=WA', 'a=WA'),
    'cc_l/XF': ('', '', 'lb=WA', 'lb=WA'),
    'cc_l/XG': ('', '', 'a=WA', 'a=WA'),
    'cc_l/XM': ('', '', 'a=WA', 'a=WA'),
    'cc_l/XN': ('rm=DE rv=WA', 'rm=DE rv=DE', 'lb=BC rm=DE', 'lb=BC rm=DE rv=DE'),
    'cc_l/XP': ('lj=DE', 'lj=DE', 'a=WA rp=DE', 'a=WA rp=DE'),
    'cc_l/XT': ('', '', 'lb=BC', 'lb=BC'),
    'cc_l/XU': ('', '', 'rz=BC', 'rz=BC'),
    'cc_l/XX': ('lj=DE', 'rb=BC', '', ''),
    'ci_e/MT': ('lq=WA', '', 'lq=WA', ''),
    'ci_e/SS': ('', 'c=HL', 'c=BC lv=HL rm=DE rv=DE', 'c=BC lv=HL rm=DE rv=DE'),
    'ci_e/SU': ('rv=WA', '', '', ''),
    'ci_e/TX': 'lv=BC',
    'ci_e/UU': ('', 'rv=BC', '', 'rv=BC'),
    'ci_e/XT': 'rv=WA',
    'ci_e/XX': ('lb=HL lj=DE', 'c=BC rb=WA', 'lb=HL lj=DE', 'rb=WA'),
    'ci_l/DX': ('', '', 'lp=HL', 'lp=HL'),
    'ci_l/MT': ('lq=WA', '', 'lq=WA', ''),
    'ci_l/PX': ('', '', 'lp=HL', 'lp=HL'),
    'ci_l/SS': ('', 'c=HL', 'c=BC lv=HL rm=DE rv=DE', 'c=BC lv=HL rm=DE rv=DE'),
    'ci_l/SU': ('rv=WA', '', '', ''),
    'ci_l/TX': 'lv=BC',
    'ci_l/UU': ('', 'rv=BC', '', 'rv=BC'),
    'ci_l/XT': 'rv=WA',
    'ci_l/XX': ('c=BC lb=HL', 'c=BC lb=WA lj=BC', 'lb=IX lj=HL', 'lb=WA lj=BC'),
    'cl_e/DB': 'lp=WA rv=BC',
    'cl_e/DC': 'lp=WA rv=BC',
    'cl_e/DS': 'lp=BC rv=DE',
    'cl_e/DX': 'lp=BC rb=DE',
    'cl_e/FX': 'rb=BC rj=WA',
    'cl_e/NN': ('re=WA', '', 're=WA', ''),
    'cl_e/NU': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/SN': ('re=WA', '', 'rn=BC', 'rn=BC'),
    'cl_e/SS': ('', 'c=HL', 'c=BC lv=HL rm=DE rv=DE', 'c=BC lv=HL rm=DE rv=DE'),
    'cl_e/SU': ('rv=WA', '', '', ''),
    'cl_e/TX': 'lv=BC',
    'cl_e/UN': ('re=WA', '', 're=WA', ''),
    'cl_e/UU': ('', 'rv=BC', '', 'rv=BC'),
    'cl_e/XF': 'lb=BC lj=WA',
    'cl_e/XT': 'rv=WA',
    'cl_e/XX': ('lb=HL lj=DE', 'c=BC rb=WA', 'lb=HL lj=DE', 'rb=WA'),
    'cl_l/DB': 'lp=WA rv=BC',
    'cl_l/DC': 'lp=WA rv=BC',
    'cl_l/DS': 'lp=BC rv=DE',
    'cl_l/DX': ('', '', 'lp=BC rb=HL rj=DE', 'lp=BC rb=HL rj=DE'),
    'cl_l/FX': 'rb=BC rj=WA',
    'cl_l/NN': ('re=WA', '', 're=WA', ''),
    'cl_l/NU': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/PX': ('', '', 'lp=HL', 'lp=HL'),
    'cl_l/SN': ('re=WA', '', 'rn=BC', 'rn=BC'),
    'cl_l/SS': ('', 'c=HL', 'c=BC lv=HL rm=DE rv=DE', 'c=BC lv=HL rm=DE rv=DE'),
    'cl_l/SU': ('rv=WA', '', '', ''),
    'cl_l/TX': 'lv=BC',
    'cl_l/UN': ('re=WA', '', 're=WA', ''),
    'cl_l/UU': ('', 'rv=BC', '', 'rv=BC'),
    'cl_l/XD': 'lb=DE rp=BC',
    'cl_l/XF': 'lb=BC lj=WA',
    'cl_l/XT': 'rv=WA',
    'cl_l/XX': ('lb=HL', 'c=BC lb=WA lj=BC', 'lb=IX lj=HL', 'lb=WA lj=BC'),
    'cv_l/DX': ('', '', 'lp=HL', 'lp=HL'),
    'cv_l/MT': ('lq=WA', '', 'lq=WA', ''),
    'cv_l/PX': ('', '', 'lp=HL', 'lp=HL'),
    'cv_l/SS': ('', 'c=HL', 'c=BC lv=HL rm=DE rv=DE', 'c=BC lv=HL rm=DE rv=DE'),
    'cv_l/SU': ('rv=WA', '', '', ''),
    'cv_l/TX': 'lv=BC',
    'cv_l/UU': ('', 'rv=BC', '', 'rv=BC'),
    'cv_l/XT': 'rv=WA',
    'cv_l/XX': ('c=BC lb=HL', 'c=BC lb=WA lj=BC', 'lb=IX lj=HL', 'lb=WA lj=BC'),
}
# ROLES-END


def main(probe, families=None):
    sys.setrecursionlimit(100000)
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(probe, s, show, only, families)


if __name__ == '__main__':
    main('cmpord')
