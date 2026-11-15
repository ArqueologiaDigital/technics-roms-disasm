#!/usr/bin/env python3
"""stval_ast.py -- the cc900 V4.23 oracle's code for the functions of probe stval.c (corpus/probes/stval.c, oracle
run 2026-11-12-4-micro-stval) at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 stval_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]

The probe's functions (assignments whose value is read through an address):
    rv_<t>_<L><V>(int c) { return L = V; }          t = i int, l long, c char
    cv_i_<L1><L2><V>(int c) { L1 = (L2 = V); }       int
    L: G global, M static member, P deref, D member through a pointer, E constant element, X element at c, Q pointer
    element at c.  V: P deref, D member through a pointer, X element at c, E constant element, M static member.
    L1 writes g*, L2 h*, V reads v*.

How it works (stores-FAMILIES.md beside this file has the rules): the function is classified from its AST against
the probe's grammar (canonical notation, globals numbered by first appearance; never by its name); `return L = V`
is a single store whose value is loaded into the return register; the chained int stores follow stchain_ast.py's
model with the read-through values evaluated before the outer destination; the probe's symbols are replaced by the
real ones.
"""
import os
import re
import sys

import codegen as cg
HOME_ = __import__('os').path.expanduser('~/')

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')


class No(Exception):
    pass


def need(c):
    if not c:
        raise No()


# ==============================================================================================================
# 1. the canonical notation
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
    PT = {'long': 'l', 'int': 'i', 'void': 'v', 'long int': 'l', 'char': 'c'}
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
        if k == 'un':
            return '%s%s' % (n.op, self.e(n.e))
        if k == 'cond':
            return '(%s ? %s : %s)' % (self.e(n.c), self.e(n.a), self.e(n.b))
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
        if st.k == 'return':
            need(st.value is not None)
            return 'return %s;' % self.e(st.value)
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
MOFF = {'i': 2, 'l': 4, 'c': 0}
SZ = {'i': 2, 'l': 4, 'c': 1}
CV = ('GGP GGD GGX GGE GMP GMD GMX GME GPP GPD GPX GPE GDP GDD GDX GDE GXP GXD GXX GXE MGP MGD MGX MGE MMP MMD MMX MME '
      'MPP MPD MPX MPE MDP MDD MDX MDE MXP MXD MXX MXE PGP PGD PGX PGE PMP PMD PMX PME PPP PPD PPX PPE PDP PDD PDX PDE '
      'PXP PXD PXX PXE DGP DGD DGX DGE DMP DMD DMX DME DPP DPD DPX DPE DDP DDD DDX DDE DXP DXD DXX DXE EGP EGD EGX EGE '
      'EMP EMD EMX EME EPP EPD EPX EPE EDP EDD EDX EDE EXP EXD EXX EXE XGP XGD XGX XGE XMP XMD XMX XME XPP XPD XPX XPE '
      'XDP XDD XDX XDE').split()


def probe_types():
    ty = {'gs': ST, 'hs': ST, 'vs': ST, 'gps': ST + '*', 'hps': ST + '*', 'vps': ST + '*'}
    for n, t in (('gv', 'i'), ('hv', 'i'), ('gl', 'l'), ('hl', 'l'), ('gc', 'c'), ('hc', 'c')):
        ty[n] = t
    for p in 'ghv':
        ty[p + 'ia'] = 'i[8]'
        ty[p + 'la'] = 'l[8]'
        ty[p + 'ca'] = 'c[8]'
        ty[p + 'pi'] = 'i*'
        ty[p + 'pl'] = 'l*'
        ty[p + 'p'] = 'c*'
    return ty


NAMES = {'i': dict(v='v', a='ia', p='pi'), 'l': dict(v='l', a='la', p='pl'), 'c': dict(v='c', a='ca', p='p')}


def lval(L, t, p):
    n = NAMES[t]
    return {'G': '$%s%s' % (p, n['v']), 'M': '$%ss.{%d:%s}' % (p, MOFF[t], t), 'D': '$%sps->{%d:%s}' % (p, MOFF[t], t),
            'P': '*$%s%s' % (p, n['p']), 'E': '$%s%s[%s:i]' % (p, n['a'], 5 if p == 'v' else 3),
            'X': '$%s%s[@0]' % (p, n['a']), 'Q': '$%s%s[@0]' % (p, n['p'])}[L]


def probe_text(name):
    m = re.match(r'rv_([ilc])_([GMPDEXQ])([PDXEM])$', name)
    if m:
        t, L, V = m.groups()
        return '%s(i) { return (%s = %s); }' % (t, lval(L, t, 'g'), lval(V, t, 'v'))
    m = re.match(r'cv_i_([GMPDEX])([GMPDX])([PDXE])$', name)
    L1, L2, V = m.groups()
    return 'v(i) { (%s = (%s = %s)); }' % (lval(L1, 'i', 'g'), lval(L2, 'i', 'h'), lval(V, 'i', 'v'))


def probe_names():
    return ['rv_%s_%s%s' % (t, L, V) for t in 'ilc' for L in 'GMPDEXQ' for V in 'PDXEM'] + ['cv_i_' + x for x in CV]


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
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}


def h(n):
    return '0x%x' % n


class VR:
    """a virtual register: live from d to u (positions in emission order); conflicts when the interiors meet"""

    def __init__(self, name, d, u, prio, prefer=None, fixed=None, only=None):
        self.name, self.d, self.u, self.prio = name, d, u, prio
        self.prefer = prefer               # a callable -> a register to try first, or None
        self.reg = fixed
        self.only = only                   # the registers it may take (byte registers: WA BC DE HL)
        self.coal = ()
        self.avoid = None                  # a callable -> registers not to take

    def __repr__(self):
        return '%s[%s..%s]=%s' % (self.name, self.d, self.u, self.reg)


def overlap(a, b):
    return max(a.d, b.d) < min(a.u, b.u)


def allocate(vrs):
    done = [v for v in vrs if v.reg is not None]
    queue = sorted([v for v in vrs if v.reg is None], key=lambda v: v.prio)
    while queue:
        v = queue.pop(0)
        claim = getattr(v, 'claim', None)
        if claim:                                              # it wants this register: takes it, or keeps others
            ok = all(not (u.reg == claim[0] and overlap(u, v)) for u in done)   # off it and waits
            if ok:
                v.reg = claim[0]
                done.append(v)
                continue
            ph = VR('claim', v.d, getattr(v, 'claim_u', v.u), 0, fixed=claim[0])
            done.append(ph)
            v.claim = None
            v.prio = claim[1]
            v.coal = (ph,)
            queue.append(v)
            queue.sort(key=lambda x: x.prio)
            continue
        cands = [r for r in REGS if v.only is None or r in v.only]
        p = v.prefer() if v.prefer else None
        if p:
            ps = [x for x in (p if isinstance(p, list) else [p]) if x]
            cands = ps + [r for r in cands if r not in ps]
        if v.avoid:
            cands = [r for r in cands if r not in v.avoid()]
        for r in cands:
            if all(not (u.reg == r and overlap(u, v)) or u in v.coal for u in done):
                v.reg = r
                break
        need(v.reg is not None)
        done.append(v)


class Set:
    def __init__(self, s):
        self.s = s
        self.opt = s.startswith('O3')
        self.xr = s.endswith('Xr')
        self.pre = '.' if self.xr else '_'


def predict(name, s):
    Z = Set(s)
    if name.startswith('rv_'):
        return rv(name, Z) + ['ret']
    G = Gen(name, s)
    return body(G) + ['ret']


def rv(name, Z):
    """return L = V: a single store, the value read through its address into the return register"""
    t, L, V = re.match(r'rv_([ilc])_(.)(.)$', name).groups()
    n = NAMES[t]
    opt, xr = Z.opt, Z.xr
    pA, pV, pS = 1, 3, 10
    vrs = []
    uses = [k for k, x in (('A', L), ('V', V)) if x in 'XQ']
    kind = {k: (L if k == 'A' else V) for k in uses}
    pos = {'A': pA, 'V': pV}
    xlike = t == 'i' and any(kind[k] == 'X' for k in uses)
    cse = opt and t != 'c' and len(uses) == 2 and all(kind[k] == 'X' for k in uses)
    csrc = pin = hold = shared = None
    if uses:
        lastc = max(pS if (t == 'c' and k == 'A') else pos[k] + (0.4 if t == 'c' else 0) for k in uses)
        if xr:
            pin = VR('c', 0, pos[uses[0]] if cse else lastc, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
        elif len(uses) == 2 and not cse and (opt or xlike):
            hold = VR('hold', 0, lastc, 80)
            vrs.append(hold)
            csrc = hold
            if opt and kind[uses[0]] == 'Q':                   # -O: a Q formed while the copy lives: not WA
                hold.avoid = lambda: ('WA',)
        if cse:
            shared = VR('shared', pA, pS, 14, prefer=lambda: 'WA')
            vrs.append(shared)
    regc = csrc is not None
    vrs.append(VR('HL', pV, pS, 0, fixed='HL'))
    A = {}
    if L in 'PD':
        A['r'] = VR('A', pA, pS, (16 if t == 'c' else 10) if L == 'D' else 70)
        vrs.append(A['r'])
    elif L in 'XQ' and t == 'c':
        A['b'] = VR('Abase', pA, pS if regc else pA + 0.4, (8 if L == 'X' else 6) if regc else 30,
                    prefer=lambda: 'WA')
        vrs.append(A['b'])
        if not regc:
            A['i'] = VR('Aidx', pA + 0.2, pS, 30.1)
            vrs.append(A['i'])
    elif L == 'X':
        A['i'] = shared if cse else VR('Aidx', pA, pS, 30, prefer=lambda: 'WA')
        A['b'] = VR('Abase', pA + 0.3, pS, 30.1)
        vrs.extend([A['b']] + ([] if cse else [A['i']]))
    elif L == 'Q':
        A['T'] = VR('AT', pA + 0.5, pS, 70)
        vrs.append(A['T'])
        T = A['T']
        if isinstance(csrc, VR) and getattr(csrc, 'u', None) == pA and csrc is pin:
            A['S'] = csrc
            T.prefer = lambda: 'WA'
        elif opt:
            A['S'] = T
        else:
            A['S'] = VR('AS', pA, pA + 0.5, 1)
            vrs.append(A['S'])
            S = A['S']
            T.prefer = lambda: S.reg
    Vd = {}
    if V in 'PD':
        pr = (9 if regc else 5) if t == 'c' else (35 if V == 'P' else 12)
        Vd['t'] = VR('Vtmp', pV, pV + 0.5, pr, prefer=lambda: 'WA')
        vrs.append(Vd['t'])
    elif V == 'X' and t == 'c':
        Vd['b'] = VR('Vbase', pV, pV + (0.45 if regc else 0.3), 7 if regc else 10.3, prefer=lambda: 'WA')
        vrs.append(Vd['b'])
        if not regc:
            Vd['i'] = VR('Vidx', pV + 0.2, pV + 0.45, 15)
            vrs.append(Vd['i'])
    elif V == 'X':
        Vd['i'] = shared if cse else VR('Vidx', pV, pV + 0.5, 20, prefer=lambda: 'WA')
        Vd['b'] = VR('Vbase', pV + 0.3, pV + 0.5, 20.1)
        vrs.extend([Vd['b']] + ([] if cse else [Vd['i']]))
    allocate(vrs)

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        return csrc.reg

    done = []

    def index(i):
        if cse and done:
            return []
        done.append(1)
        return ([] if src() == i else ['ld %s,%s' % (i, src())]) + \
            ['add %s,%s' % (i, i) if t == 'i' else 'sla 0x2,%s' % i]

    def elem(b, i, ldb):
        out = [ldb]
        if regc:
            if hold is not None and not loaded:                # the held copy is loaded at its first use
                loaded.append(1)
                hl = 'ld %s,(XSP+0x4)' % hold.reg
                out = out + [hl] if ldb.startswith('lda') else [hl] + out
            return '(X%s+%s)' % (b, src()), out
        return '(X%s)' % i, out + ['ld %s,(XSP+0x4)' % i, 'extz X%s' % i, 'add X%s,X%s' % (i, b)]

    out = []
    loaded = []
    if hold is not None and t != 'c':
        loaded.append(1)
        out.append('ld %s,(XSP+0x4)' % hold.reg)
    if L == 'P':
        out.append('ld X%s,(_g%s)' % (A['r'].reg, n['p']))
        op = '(X%s)' % A['r'].reg
    elif L == 'D':
        out.append('ld X%s,(_gps)' % A['r'].reg)
        op = '(X%s%s)' % (A['r'].reg, '+%s' % h(MOFF[t]) if MOFF[t] else '')
    elif L in 'XQ' and t == 'c':
        b = A['b'].reg
        op, o = elem(b, A['i'].reg if 'i' in A else None,
                     'lda X%s,_gca' % b if L == 'X' else 'ld X%s,(_gp)' % b)
        out += o
    elif L == 'X':
        i, b = A['i'].reg, A['b'].reg
        out += index(i) + ['lda X%s,_g%s' % (b, n['a'])]
        op = '(X%s+%s)' % (b, i)
    elif L == 'Q':
        S, T = A['S'].reg, A['T'].reg
        if src() != S:
            out.append('ld %s,%s' % (S, src()))
        out += ['exts X%s' % S, 'add X%s,X%s' % (S, S) if t == 'i' else 'sll 0x2,X%s' % S]
        if T != S:
            out.append('ld X%s,X%s' % (T, S))
        out.append('add X%s,(_g%s)' % (T, n['p']))
        op = '(X%s)' % T
    else:
        mem = {'G': '_g' + n['v'], 'M': '_gs', 'E': '_g%s + %s' % (n['a'], h(3 * SZ[t]))}[L]
        if L == 'M' and MOFF[t]:
            mem += ' + %s' % h(MOFF[t])
        op = '(%s)' % mem
    w = {'i': 'HL', 'l': 'XHL', 'c': 'L'}[t]
    if V == 'P':
        out += ['ld X%s,(_v%s)' % (Vd['t'].reg, n['p']), 'ld %s,(X%s)' % (w, Vd['t'].reg)]
    elif V == 'D':
        off = '+%s' % h(MOFF[t]) if MOFF[t] else ''
        out += ['ld X%s,(_vps)' % Vd['t'].reg, 'ld %s,(X%s%s)' % (w, Vd['t'].reg, off)]
    elif V == 'E':
        out.append('ld %s,(_v%s + %s)' % (w, n['a'], h(5 * SZ[t])))
    elif V == 'M':
        out.append('ld %s,(_vs%s)' % (w, ' + %s' % h(MOFF[t]) if MOFF[t] else ''))
    elif t == 'c':
        b = Vd['b'].reg
        o_, o = elem(b, Vd['i'].reg if 'i' in Vd else None, 'lda X%s,_vca' % b)
        out += o + ['ld %s,%s' % (w, o_)]
    else:
        i, b = Vd['i'].reg, Vd['b'].reg
        out += index(i) + ['lda X%s,_v%s' % (b, n['a']), 'ld %s,(X%s+%s)' % (w, b, i)]
    out.append('ld %s,%s' % (op, w))
    return out


class Gen:
    def __init__(self, name, s):
        m = re.match(r'cv_i_([GMPDEX])([GMPDX])([PDXE])$', name)
        self.t = 'i'
        self.L1, self.L2, self.V = m.groups()
        self.s = s
        self.opt = s.startswith('O3')
        self.xr = s.endswith('Xr')

    def sym(self, L, p):
        return {'G': '_%sv' % p, 'M': '_%ss' % p, 'D': '_%sps' % p, 'E': '_%sia' % p, 'X': '_%sia' % p,
                'P': '_%spi' % p, 'Q': '_%spi' % p}[L]

    def w(self, r):
        return r

    def scale_x(self, r):
        return 'add %s,%s' % (r, r)

    def scale_q(self, r):
        return 'add X%s,X%s' % (r, r)


OFF = {'i': 2, 'l': 4}


def body(G):
    """L1 = (L2 = V), V read through an address: L2's address, the value, L2's store, L1's address, L1's store"""
    L1, L2, V = G.L1, G.L2, G.V
    opt, xr = G.opt, G.xr
    pI, pV, sI, pO, sO = 1, 2, 3, 4, 5
    pos = {'O': pO, 'I': pI, 'V': pV}
    vrs, pre, post = [], [], []
    uses = [k for k, L in (('I', L2), ('V', V), ('O', L1)) if L == 'X']
    cse = opt and len(uses) == 2
    csrc = None
    pin = hold = shared = None
    if uses:
        lastc = max(pos[k] for k in uses)
        if xr:
            pin = VR('c', 0, pos[uses[0]] if cse else lastc, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
        elif len(uses) == 2 and not cse:
            hold = VR('hold', 0, lastc, 80)
            vrs.append(hold)
            csrc = hold
        if cse:
            last = max(sO if k == 'O' else (sI if k == 'I' else pV + 0.5) for k in uses)
            shared = VR('shared', pos[uses[0]], last, 14, prefer=lambda: 'WA')
            vrs.append(shared)
    A = {}

    def mk(key, L, p):
        pp, st = pos[key], (sO if key == 'O' else sI)
        d = {'L': L, 'p': p}
        if L in 'PD':
            if key == 'O':
                pr = 10 if L == 'D' else 70
            else:
                pr = 13 if L == 'D' else 17
            d['r'] = VR(key + L, pp, st, pr)
            vrs.append(d['r'])
        elif L == 'X':
            pr = 30 if key == 'O' else 15
            d['i'] = shared if cse else VR(key + 'idx', pp, st, pr, prefer=lambda: 'WA')
            d['b'] = VR(key + 'base', pp + 0.3, st, pr + 0.1)
            vrs.extend([d['b']] + ([] if cse else [d['i']]))
        A[key] = d

    if L1 in 'PDX':
        mk('O', L1, 'g')
    if L2 in 'PDX':
        mk('I', L2, 'h')
    Vd = {}
    val = VR('V', pV + 0.5, sO, 60)
    if V in 'PD':
        Vd['t'] = VR('Vtmp', pV, pV + 0.5, 16 if V == 'P' else 13.5, prefer=lambda: 'WA')
        tmp = Vd['t']
        val.prefer = lambda: tmp.reg
        vrs.append(Vd['t'])
    elif V == 'X':
        Vd['i'] = shared if cse else VR('Vidx', pV, pV + 0.5, 14, prefer=lambda: 'WA')
        Vd['b'] = VR('Vbase', pV + 0.3, pV + 0.5, 14.1)
        vrs += [Vd['b']] + ([] if cse else [Vd['i']])
        vb, vi = Vd['b'], Vd['i']

        def vpref():
            return ['WA', vi.reg, vb.reg]
        val.prefer = vpref
    elif V == 'E':
        val.d = pV
    vrs.append(val)
    allocate(vrs)

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        return csrc.reg

    done = []

    def index(i):
        if cse and done:
            return []
        done.append(1)
        return ([] if src() == i else ['ld %s,%s' % (i, src())]) + ['add %s,%s' % (i, i)]

    def emit(key):
        d = A.get(key)
        if d is None:
            return []
        L, p = d['L'], d['p']
        if L == 'P':
            d['op'] = '(X%s)' % d['r'].reg
            return ['ld X%s,(_%spi)' % (d['r'].reg, p)]
        if L == 'D':
            d['op'] = '(X%s+0x2)' % d['r'].reg
            return ['ld X%s,(_%sps)' % (d['r'].reg, p)]
        i, b = d['i'].reg, d['b'].reg
        d['op'] = '(X%s+%s)' % (b, i)
        return index(i) + ['lda X%s,_%sia' % (b, p)]

    def operand(key, L, p):
        if L in 'PDX':
            return A[key]['op']
        return {'G': '(_%sv)' % p, 'M': '(_%ss + 0x2)' % p, 'E': '(_%sia + 0x6)' % p}[L]

    v = val.reg
    out = list(pre)
    if hold is not None:
        out.append('ld %s,(XSP+0x4)' % hold.reg)
    out += emit('I')
    if V == 'P':
        out += ['ld X%s,(_vpi)' % Vd['t'].reg, 'ld %s,(X%s)' % (v, Vd['t'].reg)]
    elif V == 'D':
        out += ['ld X%s,(_vps)' % Vd['t'].reg, 'ld %s,(X%s+0x2)' % (v, Vd['t'].reg)]
    elif V == 'E':
        out.append('ld %s,(_via + 0xa)' % v)
    else:
        i, b = Vd['i'].reg, Vd['b'].reg
        out += index(i) + ['lda X%s,_via' % b, 'ld %s,(X%s+%s)' % (v, b, i)]
    out.append('ld %s,%s' % (operand('I', L2, 'h'), v))
    out += emit('O')
    out.append('ld %s,%s' % (operand('O', L1, 'g'), v))
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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/stval.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-4-micro-stval/out/v423/%s/probes/stval.asm'


def renamed_probe():
    """a copy of the probe with every global renamed (in this file's directory, scratch)"""
    src = open(PROBE, encoding='latin-1').read()
    for n in sorted(probe_types(), key=len, reverse=True):
        src = re.sub(r'\b%s\b' % n, 'zq_' + n, src)
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'renamed_' + os.path.basename(PROBE))
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
            if shown < show and '--dec' in sys.argv:
                shown += 1
                print('---- %s declined' % f.name)
            continue
        got = listing.normalise_labels(got)
        if got == W:
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    a = W[k].strip().replace('\t', ' ') if k < len(W) else ''
                    b = got[k].strip().replace('\t', ' ') if k < len(got) else ''
                    print('  %-34s %s %s' % (a, ' ' if a == b else '|', b))
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
