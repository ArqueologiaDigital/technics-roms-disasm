#!/usr/bin/env python3
"""stchain_ast.py -- the cc900 V4.23 oracle's code for the functions of probe stchain.c (corpus/probes/stchain.c,
oracle run 2026-11-12-1-micro-stchain) at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 stchain_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path.  --rename checks a copy of the probe with every global renamed instead.

The probe's functions are `void sc_<t>_<L1><L2><V>(int c) { L1 = (L2 = V); }`, t = i (int) or l (long):

    L  G gv / gl      M gs.i / gs.l     P *gpi / *gpl     D gps->i / gps->l
       E gia[3]       X gia[c]          Q gpi[c]          (L1 writes g*, L2 the same kinds of h*)
    V  K 7            G vi / vl         B (vi - vj)       C ri() / rl()

How it works (stchain-FAMILIES.md beside this file has the rules):
  1. classify(f): the function's AST is written out in a small canonical notation (implicit integral casts dropped,
     every leaf with its type, members as offset:type, the parameter by position, globals by name).  The probe's
     grammar writes every probe function in the same notation with the probe's names; the globals of both are
     numbered in order of first appearance, and the function is the probe function whose numbered text and global
     types are equal.  Nothing is looked up by the function's name.
  2. predict(): a small model of the code generator for `L1 = (L2 = V)`: the evaluation order (destination address
     first for a constant or a plain global value, the value first for a difference or a call), virtual registers
     with live ranges, and a priority order in which they take the first free register (WA BC DE HL IX IY).
  3. The probe's symbols are replaced by the real ones.
"""
import os
import re
import sys

import codegen as cg

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')


class No(Exception):
    pass


def need(c):
    if not c:
        raise No()


# ==============================================================================================================
# 1. the canonical notation (as lhxw.py)
# ==============================================================================================================
TL = {(1, True): 'c', (1, False): 'b', (2, True): 'i', (2, False): 'u', (4, True): 'l', (4, False): 'n'}


def tn(ty):
    need(ty is not None)
    if ty.kind == 'int':
        r = TL.get((ty.size, ty.signed))
        need(r is not None)
        return r
    if ty.kind == 'void':
        return 'v'
    if ty.kind == 'ptr':
        return tn(ty.base) + '*'
    if ty.kind == 'array':
        return '%s[%d]' % (tn(ty.base), ty.count)
    if ty.kind == 'struct':
        need(ty.rec)
        return 'S{%s}' % ','.join('%d:%s' % (o, tn(t)) for _, t, o in ty.rec)
    raise No()


def fn_type(ty):
    need(ty is not None and ty.kind == 'func')
    sp = re.sub(r'__attribute__\(\(tlcs900_[ac]decl\)\)', '', ty.spell or '')
    m = re.match(r'^(.*?)\s*\((.*)\)\s*$', sp.strip())
    need(m is not None)
    ps = [re.sub(r'\s+', ' ', p.strip()) for p in m.group(2).split(',')]
    PT = {'long': 'l', 'int': 'i', 'void': 'v', 'long int': 'l'}
    need(all(p in PT for p in ps))
    return 'F%s(%s)' % (tn(ty.ret), ','.join(PT[p] for p in ps))


class Render:
    """AST -> notation text; globals keep their names (prefixed '$'), their types collected in self.gty"""

    def __init__(self, f, adecl):
        self.f, self.adecl = f, adecl
        self.gty = {}

    def glob(self, d, ty):
        t = fn_type(ty) if ty.kind == 'func' else tn(ty)
        if ty.kind == 'func' and self.adecl:
            need(not getattr(ty, 'cdecl', False))              # a __cdecl callee in a -Xr file: other code
        need(getattr(d, 'storage', '') in ('', 'extern', None))
        old = self.gty.get(d.name)
        need(old is None or old == t)
        self.gty[d.name] = t
        return '$' + d.name

    def e(self, n):
        n = cg.strip(n)
        k = n.k
        if k == 'cast':
            if n.kind == 'IntegralCast' and not n.explicit:
                return self.e(n.e)
            if n.kind == 'FunctionToPointerDecay':
                return self.e(n.e)
            need(n.kind == 'IntegralCast')
            return '(%s)%s' % (tn(n.ty), self.e(n.e))
        if k == 'load':
            return self.e(n.e)
        if k == 'var':
            d = n.decl
            if d.kind == 'param':
                return '@%d' % self.f.params.index(d)
            need(d.kind in ('global', 'func'))
            return self.glob(d, d.ty)
        if k == 'const':
            need(n.value is not None)
            return '%s:%s' % (n.value, tn(n.ty))
        if k == 'bin':
            return '(%s %s %s)' % (self.e(n.l), n.op, self.e(n.r))
        if k == 'index':
            return '%s[%s]' % (self.e(n.base), self.e(n.idx))
        if k == 'member':
            return '%s%s{%d:%s}' % (self.e(n.base), '->' if n.arrow else '.', cg.member_offset(n), tn(n.ty))
        if k == 'deref':
            return '*%s' % self.e(n.e)
        if k == 'call':
            return '%s(%s)' % (self.e(n.fn), ','.join(self.e(a) for a in n.args))
        raise No()

    def s(self, st):
        need(st.k == 'expr')
        return self.e(st.e) + ';'

    def function(self):
        f = self.f
        sig = '%s(%s)' % (tn(f.ret), ','.join(tn(p.ty) for p in f.params))
        return sig + ' { ' + ' '.join(self.s(x) for x in cg.flat(f.body)) + ' }'


def number(text, gty):
    order = []

    def sub(m):
        nm = m.group(1)
        if nm not in order:
            order.append(nm)
        return '$%d' % order.index(nm)
    t = re.sub(r'\$([A-Za-z_]\w*)', sub, text)
    return t, tuple(gty[n] for n in order), order


# --------------------------------------------------------------------------------------------- the probe grammar
ST = 'S{0:c,2:i,4:l,8:i[4]}'                    # struct st { char c; int i; long l; int a[4]; }
OFF = {'i': 2, 'l': 4}                           # the member read by M and D


def probe_types():
    ty = {'ri': 'Fi(v)', 'rl': 'Fl(v)', 'gs': ST, 'hs': ST, 'gps': ST + '*', 'hps': ST + '*'}
    for p in 'gh':
        ty[p + 'v'] = 'i'
        ty[p + 'l'] = 'l'
        ty[p + 'ia'] = 'i[8]'
        ty[p + 'la'] = 'l[8]'
        ty[p + 'pi'] = 'i*'
        ty[p + 'pl'] = 'l*'
    for n in ('vi', 'vj'):
        ty[n] = 'i'
    for n in ('vl', 'vm'):
        ty[n] = 'l'
    return ty


def lval(L, p, t):
    """the destination L of type t, writing the p* (g or h) objects, in the notation"""
    var = {'i': p + 'v', 'l': p + 'l'}[t]
    arr = '$%s%sa' % (p, t)
    ptr = '$%sp%s' % (p, t)
    mem = '{%d:%s}' % (OFF[t], t)
    return {'G': '$' + var, 'M': '$%ss.%s' % (p, mem), 'P': '*' + ptr, 'D': '$%sps->%s' % (p, mem),
            'E': '%s[3:i]' % arr, 'X': '%s[@0]' % arr, 'Q': '%s[@0]' % ptr}[L]


def rval(V, t):
    a, b = ('$vi', '$vj') if t == 'i' else ('$vl', '$vm')
    return {'K': '7:%s' % t, 'G': a, 'B': '(%s - %s)' % (a, b), 'C': '$r%s()' % t}[V]


def probe_text(name):
    m = re.match(r'sc_([il])_([GMPDEXQ])([GMPDEXQ])([KGBC])$', name)
    t, L1, L2, V = m.groups()
    return 'v(i) { (%s = (%s = %s)); }' % (lval(L1, 'g', t), lval(L2, 'h', t), rval(V, t))


def probe_names():
    return ['sc_%s_%s%s%s' % (t, a, b, v) for t in 'il' for a in 'GMPDEXQ' for b in 'GMPDEXQ' for v in 'KGBC']


_INDEX = None


def index():
    global _INDEX
    if _INDEX is None:
        _INDEX = {}
        pt = probe_types()
        for nm in probe_names():
            txt, tys, order = number(probe_text(nm), pt)
            _INDEX[(txt, tys)] = (nm, order)
    return _INDEX


def classify(f, adecl):
    """-> (probe name, {probe symbol: real symbol}) or None"""
    try:
        r = Render(f, adecl)
        txt, tys, order = number(r.function(), r.gty)
    except No:
        return None
    except (AttributeError, IndexError, KeyError, TypeError, ValueError):
        return None
    hit = index().get((txt, tys))
    if hit is None:
        return None
    nm, porder = hit
    return nm, dict(zip(porder, order))


# ==============================================================================================================
# 2. the predictor (probe symbols)
# ==============================================================================================================
REGS = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY')


def h(n):
    return '0x%x' % n


class VR:
    """a virtual register: live from d to u (positions in emission order); conflicts when the interiors meet"""

    def __init__(self, name, d, u, prio, prefer=None, fixed=None):
        self.name, self.d, self.u, self.prio = name, d, u, prio
        self.prefer = prefer               # a callable -> a register to try first, or None
        self.reg = fixed
        self.coal = ()                     # virtual registers it may share a register with although they meet

    def __repr__(self):
        return '%s[%s..%s]=%s' % (self.name, self.d, self.u, self.reg)


def overlap(a, b):
    return max(a.d, b.d) < min(a.u, b.u)


def allocate(vrs):
    done = [v for v in vrs if v.reg is not None]
    for v in sorted([v for v in vrs if v.reg is None], key=lambda v: v.prio):
        cands = list(REGS)
        p = v.prefer() if v.prefer else None
        if p:
            cands = [p] + [r for r in REGS if r != p]
        for r in cands:
            if all(not (u.reg == r and overlap(u, v)) or u in v.coal for u in done):
                v.reg = r
                break
        need(v.reg is not None)
        done.append(v)


class Gen:
    def __init__(self, name, s):
        m = re.match(r'sc_([il])_([GMPDEXQ])([GMPDEXQ])([KGBC])$', name)
        self.t, self.L1, self.L2, self.V = m.groups()
        self.s = s
        self.opt = s.startswith('O3')
        self.xr = s.endswith('Xr')
        self.fn = ('.' if self.xr else '_') + ('ri' if self.t == 'i' else 'rl')

    # ---------------------------------------------------------------- names
    def sym(self, L, p):
        t = self.t
        return {'G': '_%s' % ({'i': p + 'v', 'l': p + 'l'}[t]), 'M': '_%ss' % p, 'D': '_%sps' % p,
                'E': '_%s%sa' % (p, t), 'X': '_%s%sa' % (p, t), 'P': '_%sp%s' % (p, t),
                'Q': '_%sp%s' % (p, t)}[L]

    def w(self, r):
        """a value register at the type's width"""
        return r if self.t == 'i' else 'X' + r

    def scale_x(self, r):
        return 'add %s,%s' % (r, r) if self.t == 'i' else 'sla 0x2,%s' % r

    def scale_q(self, r):
        return 'add X%s,X%s' % (r, r) if self.t == 'i' else 'sll 0x2,X%s' % r


def predict(name, s):
    G = Gen(name, s)
    return frame(G, body(G))


def frame(G, out):
    return out + ['ret']


def body(G):
    t, L1, L2, V = G.t, G.L1, G.L2, G.V
    REGK = {'P', 'D', 'X', 'Q'}
    cuses = [L for L in (L1, L2) if L in 'XQ']
    simple = V in 'KG'
    # ---- positions
    if simple:
        pO, pI, pV, sI, pR, sO = 1, 2, 3, 4, 5, 6
    else:
        pV = 2 if V == 'B' else 1
        pI, sI, pO, sO = (1 if V == 'B' else 2), 3, 4, 5
        pR = None
    pos = {'O': pO, 'I': pI}
    # ---- the parameter c: where its uses read it
    both = len(cuses) == 2
    cse = G.opt and both and L1 == L2                          # -O: one scaled index for both (XX, QQ)
    csrc = None                                                # None: the stack slot
    vrs = []
    pre, post = [], []
    lastc = max(pos[k] for k, L in (('O', L1), ('I', L2)) if L in 'XQ') if cuses else None
    if cse:
        lastc = min(pos[k] for k, L in (('O', L1), ('I', L2)) if L in 'XQ')
    pin = None
    if G.xr and cuses:
        if V == 'C':
            pre += ['push IZ', 'ld IZ,WA']
            post += ['pop IZ']
            csrc = 'IZ'
        else:
            pin = VR('c', 0, lastc, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
    hold = None
    if not G.xr and both and not cse:
        if G.opt or (t == 'i' and 'X' in cuses):
            if V == 'C' and not G.opt:
                pre += ['push IZ', 'ld IZ,(XSP+0x6)']
                post += ['pop IZ']
                csrc = 'IZ'
            else:
                hold = VR('hold', 0.0 if V != 'C' else 1.5, lastc + (0.01 if G.opt else 0), 80)
                hold.lastpos = lastc
                vrs.append(hold)
                csrc = hold
    # ---- the address registers
    A = {}
    shared = {}                                                # -O, XX / QQ: the one scaled index

    def mk_addr(key, L, p):
        pp = pos[key]
        last = sO if key == 'O' else sI
        if key == 'O':
            prio = 10 if L == 'D' else (30 if (not simple and L in 'XQ') else (50 if L == 'X' else 70))
        else:
            prio = 40
        d = {'L': L, 'p': p, 'key': key, 'pos': pp}
        if cse and L in 'XQ' and 'v' not in shared:
            first = min(pos.values())
            shared['v'] = VR('shared', first, max(pos.values()) if L == 'Q' else max(sO, sI), 1, prefer=lambda: 'WA')
            shared['first'] = first
            vrs.append(shared['v'])
        if L in 'PD':
            d['r'] = VR(key + L, pp, last, prio)
            vrs.append(d['r'])
        elif L == 'X':
            if cse:
                d['i'] = shared['v']
            else:
                d['i'] = VR(key + 'idx', pp, last, prio, prefer=lambda: 'WA')
                vrs.append(d['i'])
                if G.opt and hold is not None and hold.lastpos == pp:
                    ix = d['i']

                    def share(ix=ix):
                        hold.coal = (ix,) if ix.reg != 'WA' else ()
                        return ix.reg if ix.reg != 'WA' else None
                    hold.prefer = share
            d['b'] = VR(key + 'base', pp + 0.5, last, prio + 0.1)
            vrs.append(d['b'])
        elif L == 'Q':
            d['T'] = VR(key + 'T', pp + 0.5, last, prio)
            vrs.append(d['T'])
            src = csrc
            inplace = isinstance(src, VR) and getattr(src, 'lastpos', src.u) == pp
            if cse:
                S = d['S'] = shared['v']
                if pp == max(pos.values()) and pin is None:   # the last use: in place, one live range
                    vrs.remove(d['T'])
                    S.u = last
                    d['T'] = S
                else:
                    d['T'].prefer = lambda: S.reg
            elif G.opt:
                if inplace and src is hold:                    # in place on the held copy
                    if key == 'I':
                        hold.prio = prio
                    else:
                        d['T'].prio = 85
                    d['S'] = hold
                    d['T'].prefer = lambda: hold.reg
                elif inplace:
                    d['S'] = src
                    d['T'].prefer = lambda: src.reg
                else:
                    d['S'] = d['T']
            else:
                d['S'] = VR(key + 'S', pp, pp + 0.5, 20)
                vrs.append(d['S'])
                S = d['S']
                d['T'].prefer = lambda: S.reg
        A[key] = d
        return d

    if L1 in REGK:
        mk_addr('O', L1, 'g')
    if L2 in REGK:
        mk_addr('I', L2, 'h')
    # ---- the value
    val = None
    rel = None
    if V == 'C':
        val = VR('HL', pV, sO, 0, fixed='HL')
        vrs.append(val)
    elif V in 'GB' or (V == 'K' and t == 'l'):
        hi = V == 'K'
        if V == 'K' and not G.opt:                             # -O0: the constant is loaded again for L1
            val = VR('V', pV, sI, 0.5)
            rel = VR('R', pR, sO, 0.5)
            vrs += [val, rel]
        else:
            val = VR('V', pV, sO, 0.5 if hi else 60)
            vrs.append(val)
    elif V == 'K' and not G.opt and L1 != 'G':
        rel = VR('R', pR, sO, 60)
        vrs.append(rel)
    allocate(vrs)
    # ---- emission
    def src_text(d=None):
        if d is not None and d.get('moved'):
            return d['moved']
        if csrc is None:
            return '(XSP+0x4)'
        if csrc == 'IZ':
            return 'IZ'
        return csrc.reg

    def emit_addr(key):
        d = A.get(key)
        if d is None:
            return []
        L = d['L']
        sym = G.sym(L, d['p'])
        if L == 'P':
            d['op'] = '(X%s)' % d['r'].reg
            return ['ld X%s,(%s)' % (d['r'].reg, sym)]
        if L == 'D':
            d['op'] = '(X%s+%s)' % (d['r'].reg, h(OFF[t]))
            return ['ld X%s,(%s)' % (d['r'].reg, sym)]
        again = cse and d['pos'] != shared['first']           # the shared index is already there
        if L == 'X':
            i, b = d['i'].reg, d['b'].reg
            out = [] if src_text(d) == i or again else ['ld %s,%s' % (i, src_text(d))]
            d['op'] = '(X%s+%s)' % (b, i)
            return out + ([] if again else [G.scale_x(i)]) + ['lda X%s,%s' % (b, sym)]
        S, T = d['S'].reg, d['T'].reg
        out = [] if src_text(d) == S or again else ['ld %s,%s' % (S, src_text(d))]
        if not again:
            out += ['exts X%s' % S, G.scale_q(S)]
        if T != S:
            out.append('ld X%s,X%s' % (T, S))
        d['op'] = '(X%s)' % T
        return out + ['add X%s,(%s)' % (T, sym)]

    def operand(key, L, p):
        if L in REGK:
            return A[key]['op']
        sym = G.sym(L, p)
        if L == 'G':
            return '(%s)' % sym
        if L == 'M':
            return '(%s + %s)' % (sym, h(OFF[t]))
        return '(%s + %s)' % (sym, h(3 * (2 if t == 'i' else 4)))

    out = list(pre)
    if G.opt and pin is not None:                              # -O: c leaves WA at the entry when it moves
        for key in (('O', 'I') if simple else ('I', 'O')):
            d = A.get(key)
            if d is None or d['L'] not in 'XQ':
                continue
            r = d['i'].reg if d['L'] == 'X' else d['S'].reg
            if r != 'WA':
                out.append('ld %s,WA' % r)
                d['moved'] = r
            break
    if hold is not None and V != 'C':
        out.append('ld %s,(XSP+0x4)' % hold.reg)
    va, vb = ('_vi', '_vj') if t == 'i' else ('_vl', '_vm')

    def load_value():
        if V == 'G':
            return ['ld %s,(%s)' % (G.w(val.reg), va)]
        if V == 'B':
            return ['ld %s,(%s)' % (G.w(val.reg), va), 'sub %s,(%s)' % (G.w(val.reg), vb)]
        if V == 'K' and val is not None:
            return ['ld %s,0x7' % G.w(val.reg)]
        return []

    if V == 'C':
        out.append('cal ' + G.fn)
        if hold is not None:
            out.append('ld %s,(XSP+0x4)' % hold.reg)
    if simple:
        out += emit_addr('O')
        out += emit_addr('I')
        out += load_value()
    else:
        out += emit_addr('I')
        out += load_value()
    a2 = operand('I', L2, 'h')
    vreg = 'HL' if V == 'C' else (val.reg if val is not None else None)
    if V == 'K' and t == 'i':
        out.append('ldw %s,0x7' % a2)
    else:
        out.append('ld %s,%s' % (a2, G.w(vreg)))
    if not simple:
        out += emit_addr('O')
    a1 = operand('O', L1, 'g')
    if V == 'K' and t == 'i':
        if rel is not None:
            out += ['ld %s,0x7' % rel.reg, 'ld %s,%s' % (a1, rel.reg)]
        else:
            out.append('ldw %s,0x7' % a1)
    elif V == 'K' and rel is not None:
        out += ['ld %s,0x7' % G.w(rel.reg), 'ld %s,%s' % (a1, G.w(rel.reg))]
    else:
        out.append('ld %s,%s' % (a1, G.w(vreg)))
    return out + post


# ==============================================================================================================
# 3. substitution, formatting, entry points
# ==============================================================================================================
def substitute(lines, roles):
    def sub(m):
        nm = m.group(2)
        need(nm in roles)
        return m.group(1) + roles[nm]
    return [re.sub(r'(?<![\w.])([_.])([A-Za-z]\w*)', sub, l) for l in lines]


def fmt(lines):
    out = []
    for l in lines:
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def whole_(f, s):
    xr = s.endswith('Xr')
    if not xr:
        need(not getattr(f, 'adecl_attr', False))
    c = classify(f, xr)
    need(c is not None)
    name, roles = c
    return fmt(substitute(predict(name, s), roles))


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return whole_(f, set)
    except No:
        return None
    except Exception:                                      # (an AST shape the classifier did not foresee)
        return None


PROBE = 'corpus/probes/stchain.c'                  # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-12-1-micro-stchain/out/v423/%s/probes/stchain.asm')


def renamed_probe():
    """a copy of the probe with every global renamed (in this file's directory, scratch)"""
    src = open(PROBE, encoding='latin-1').read()
    names = sorted(probe_types(), key=len, reverse=True)
    for n in names:
        src = re.sub(r'\b%s\b' % n, 'zq_' + n, src)
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'stchain_renamed.c')
    open(p, 'w', encoding='latin-1').write(src)
    return p


def check(s, show=0, only=None, rename=False):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(renamed_probe() if rename else PROBE, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = listing.normalise_labels([l for l in want.get(name, []) if 'section' not in l][1:])
        if rename:
            W = [re.sub(r'(?<![\w.])([_.])([a-z]\w*)', lambda m: m.group(1) + 'zq_' + m.group(2), l) for l in W]
        try:
            got = whole_(f, s)
        except No:
            got = None
        if got is None:
            dec += 1
            if shown < show:
                shown += 1
                print('---- %s declined' % f.name)
            continue
        if listing.normalise_labels(got) == W:
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    print('  %-34s | %s' % (W[k].strip().replace('\t', ' ') if k < len(W) else '',
                                            got[k].strip().replace('\t', ' ') if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d' % (s, ok, wrong, dec))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, '--rename' in a)
