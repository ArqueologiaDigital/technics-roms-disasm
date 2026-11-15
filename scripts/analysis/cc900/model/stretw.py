#!/usr/bin/env python3
"""stret_ast.py -- the cc900 V4.23 oracle's code for the functions of probe stret.c (corpus/probes/stret.c, oracle
run 2026-11-12-2-micro-stret) at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 stret_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]

The probe's functions:
    rs_<t>_<L><V>(int c) { return L = V; }          t = i int, l long, c char
    sc_c_<L1><L2><V>(int c) { L1 = (L2 = V); }       char
    L: G global, M static member, P deref, D member through a pointer, E constant element, X element at c, Q pointer
    element at c.  V: K constant, G global, B difference, C call.  L1 writes g*, L2 h*, V reads v*.

How it works (stores-FAMILIES.md beside this file has the rules): the function is classified from its AST against
the probe's grammar (canonical notation, globals numbered by first appearance; never by its name); `return L = V`
is a single store whose value is formed in the return register; the chained char stores follow stchain_ast.py's
model (evaluation order, virtual registers in a priority order) with the char forms; the probe's symbols are
replaced by the real ones.
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


def probe_types():
    ty = {'gs': ST, 'hs': ST, 'gps': ST + '*', 'hps': ST + '*', 'ri': 'Fi(v)', 'rl': 'Fl(v)', 'rc': 'Fc(v)'}
    for n, t in (('gv', 'i'), ('hv', 'i'), ('vi', 'i'), ('vj', 'i'), ('gl', 'l'), ('hl', 'l'), ('vl', 'l'),
                 ('vm', 'l'), ('gc', 'c'), ('hc', 'c'), ('vc', 'c'), ('vd', 'c')):
        ty[n] = t
    for p in 'gh':
        ty[p + 'ia'] = 'i[8]'
        ty[p + 'la'] = 'l[8]'
        ty[p + 'ca'] = 'c[8]'
        ty[p + 'pi'] = 'i*'
        ty[p + 'pl'] = 'l*'
        ty[p + 'p'] = 'c*'
    return ty


NAMES = {'i': dict(v='v', a='ia', p='pi', x='vi', y='vj', f='ri'),
         'l': dict(v='l', a='la', p='pl', x='vl', y='vm', f='rl'),
         'c': dict(v='c', a='ca', p='p', x='vc', y='vd', f='rc')}


def lval(L, t, p):
    n = NAMES[t]
    return {'G': '$%s%s' % (p, n['v']), 'M': '$%ss.{%d:%s}' % (p, MOFF[t], t), 'D': '$%sps->{%d:%s}' % (p, MOFF[t], t),
            'P': '*$%s%s' % (p, n['p']), 'E': '$%s%s[3:i]' % (p, n['a']), 'X': '$%s%s[@0]' % (p, n['a']),
            'Q': '$%s%s[@0]' % (p, n['p'])}[L]


def rval(V, t):
    n = NAMES[t]
    return {'K': '7:l' if t == 'l' else '7:i', 'G': '$' + n['x'], 'B': '($%s - $%s)' % (n['x'], n['y']),
            'C': '$%s()' % n['f']}[V]


def probe_text(name):
    m = re.match(r'rs_([ilc])_([GMPDEXQ])([KGBC])$', name)
    if m:
        t, L, V = m.groups()
        return '%s(i) { return (%s = %s); }' % (t, lval(L, t, 'g'), rval(V, t))
    m = re.match(r'sc_c_([GMPDEXQ])([GMPDEXQ])([KGBC])$', name)
    L1, L2, V = m.groups()
    return 'v(i) { (%s = (%s = %s)); }' % (lval(L1, 'c', 'g'), lval(L2, 'c', 'h'), rval(V, 'c'))


def probe_names():
    return ['rs_%s_%s%s' % (t, L, V) for t in 'ilc' for L in 'GMPDEXQ' for V in 'KGBC'] + \
        ['sc_c_%s%s%s' % (a, b, v) for a in 'GMPDEXQ' for b in 'GMPDEXQ' for v in 'KGBC']


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
            cands = [p] + [r for r in cands if r != p]
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
    if name.startswith('rs_'):
        return rs(name, Z) + ['ret']
    return chain_c(name, Z) + ['ret']


def rs(name, Z):
    """return L = V: a single store, the value formed in the return register (HL, XHL, L)"""
    t, L, V = re.match(r'rs_([ilc])_(.)(.)$', name).groups()
    n = NAMES[t]
    opt, xr = Z.opt, Z.xr
    vfirst = V == 'C'
    pA, pV, pS = (5, 1, 10) if vfirst else (1, 3, 10)
    vrs, pre, post = [], [], []
    csrc = None
    if L in 'XQ':
        if xr and vfirst:
            pre, post, csrc = ['push IZ', 'ld IZ,WA'], ['pop IZ'], 'IZ'
        elif xr:
            csrc = VR('c', 0, pS if t == 'c' else pA, 0, fixed='WA')
            vrs.append(csrc)
    regc = csrc is not None
    A = {}
    if L in 'PD':
        A['r'] = VR('A', pA, pS, 10)
        vrs.append(A['r'])
    elif L in 'XQ' and t == 'c':
        A['b'] = VR('Abase', pA, pS if regc else pA + 0.4, 30, prefer=lambda: 'WA')
        vrs.append(A['b'])
        if not regc:
            A['i'] = VR('Aidx', pA + 0.2, pS, 30.1)
            vrs.append(A['i'])
    elif L == 'X':
        A['i'] = VR('Aidx', pA, pS, 30, prefer=lambda: 'WA')
        A['b'] = VR('Abase', pA + 0.3, pS, 30.1)
        vrs += [A['i'], A['b']]
    elif L == 'Q':
        A['T'] = VR('AT', pA + 0.5, pS, 70)
        vrs.append(A['T'])
        T = A['T']
        if isinstance(csrc, VR):
            A['S'] = csrc
            T.prefer = lambda: 'WA'
        elif opt:
            A['S'] = T
        else:
            A['S'] = VR('AS', pA, pA + 0.5, 1)
            vrs.append(A['S'])
            S = A['S']
            T.prefer = lambda: S.reg
    if V in 'GBC':
        vrs.append(VR('HL', pV, pS, 0, fixed='HL'))
    elif t == 'l':
        A['k'] = VR('K', pV, pS, 0.5)
        vrs.append(A['k'])
    allocate(vrs)

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        return 'IZ' if csrc == 'IZ' else csrc.reg

    out = list(pre)
    if vfirst:
        out.append('cal %s%s' % (Z.pre, n['f']))
    sc = 'add %s,%s' if t == 'i' else 'sla 0x2,%s'
    if L == 'P':
        out.append('ld X%s,(_g%s)' % (A['r'].reg, n['p']))
        op = '(X%s)' % A['r'].reg
    elif L == 'D':
        out.append('ld X%s,(_gps)' % A['r'].reg)
        op = '(X%s%s)' % (A['r'].reg, '+%s' % h(MOFF[t]) if MOFF[t] else '')
    elif L in 'XQ' and t == 'c':
        b = A['b'].reg
        out.append(('lda X%s,_g%s' if L == 'X' else 'ld X%s,(_g%s)') % (b, n['a'] if L == 'X' else n['p']))
        if regc:
            op = '(X%s+%s)' % (b, src())
        else:
            i = A['i'].reg
            out += ['ld %s,(XSP+0x4)' % i, 'extz X%s' % i, 'add X%s,X%s' % (i, b)]
            op = '(X%s)' % i
    elif L == 'X':
        i, b = A['i'].reg, A['b'].reg
        if src() != i:
            out.append('ld %s,%s' % (i, src()))
        out += [(sc % (i, i)) if t == 'i' else sc % i, 'lda X%s,_g%s' % (b, n['a'])]
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
    if V == 'G':
        out.append('ld %s,(_%s)' % (w, n['x']))
    elif V == 'B':
        out += ['ld %s,(_%s)' % (w, n['x']), 'sub %s,(_%s)' % (w, n['y'])]
    if V == 'K':
        if t == 'l':
            k = 'X' + A['k'].reg
            out += ['ld %s,0x7' % k, 'ld %s,%s' % (op, k)]
        else:
            out.append('%s %s,0x7' % ('ldw' if t == 'i' else 'ldb', op))
        out.append('ld %s,0x7' % w)
    else:
        out.append('ld %s,%s' % (op, w))
    return out + post


def chain_c(name, Z):
    """gc-side = (hc-side = V) for char: stchain_ast.py's order and priorities with byte values and char elements
    (base + zero-extended c in the index register, or (base + c) when c is in a register)"""
    L1, L2, V = re.match(r'sc_c_(.)(.)(.)$', name).groups()
    opt, xr = Z.opt, Z.xr
    simple = V in 'KG'
    if simple:
        pO, pI, pV, sI, pR, sO = 1, 2, 3, 4, 5, 6
    else:
        pV = 2 if V == 'B' else 1
        pI, sI, pO, sO = (1 if V == 'B' else 2), 3, 4, 5
        pR = None
    pos = {'O': pO, 'I': pI}
    vrs, pre, post = [], [], []
    cuse = [k for k, L in (('O', L1), ('I', L2)) if L in 'XQ']
    csrc = None
    pin = hold = None
    if cuse:
        last = max(sO if k == 'O' else sI for k in cuse)
        if xr and V == 'C':
            pre, post, csrc = ['push IZ', 'ld IZ,WA'], ['pop IZ'], 'IZ'
        elif xr:
            pin = VR('c', 0, last, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
        elif opt and len(cuse) == 2:
            hold = VR('hold', 0, last, 65)
            vrs.append(hold)
            csrc = hold
    regc = csrc is not None
    A = {}

    def mk(key, L, p):
        pp, st = pos[key], (sO if key == 'O' else sI)
        d = {'L': L, 'p': p}
        if L in 'PD':
            d['r'] = VR(key + L, pp, st, 40 if key == 'I' else 70)
            vrs.append(d['r'])
        elif L in 'XQ':
            if key == 'I':
                bp = 40
            else:
                bp = (50 if L == 'X' else 35) if simple else 30
            d['b'] = VR(key + 'base', pp, st if regc else pp + 0.4, bp, prefer=lambda: 'WA')
            vrs.append(d['b'])
            if not regc:
                d['i'] = VR(key + 'idx', pp + 0.2, st, 40.1 if key == 'I' else 65)
                vrs.append(d['i'])
        A[key] = d

    if L1 in 'PDXQ':
        mk('O', L1, 'g')
    if L2 in 'PDXQ':
        mk('I', L2, 'h')
    val = rel = scr = None
    if V == 'C':
        val = VR('HL', pV, sO, 0, fixed='HL')
        vrs.append(val)
    elif V == 'G':
        val = VR('V', pV, sO, 60)
        vrs.append(val)
    elif V == 'B':
        val = VR('V', pV + 0.5, sO, 60)
        if opt:                                                # -O: formed in place, wanting A
            val.d = pV
            val.prio = 31
            val.claim = ('BC' if pin is not None and pin.u > pV else 'WA', 60)
            val.claim_u = sI
        else:
            scr = VR('S', pV, pV + 0.5, 20, prefer=lambda: 'WA')
            vrs.append(scr)
            val.prefer = lambda: scr.reg
        vrs.append(val)
    elif not opt and L1 != 'G':                                # K, -O0: the constant reloaded for L1
        rel = VR('R', pR, sO, 60, prefer=lambda: 'WA')
        vrs.append(rel)
    allocate(vrs)

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        return 'IZ' if csrc == 'IZ' else csrc.reg

    def emit(key):
        d = A.get(key)
        if d is None:
            return []
        L, p = d['L'], d['p']
        if L == 'P':
            d['op'] = '(X%s)' % d['r'].reg
            return ['ld X%s,(_%sp)' % (d['r'].reg, p)]
        if L == 'D':
            d['op'] = '(X%s)' % d['r'].reg
            return ['ld X%s,(_%sps)' % (d['r'].reg, p)]
        b = d['b'].reg
        out = [('lda X%s,_%sca' if L == 'X' else 'ld X%s,(_%sp)') % (b, p)]
        if regc:
            d['op'] = '(X%s+%s)' % (b, src())
            if hold is not None and not loaded:                # the held copy is loaded at its first use
                loaded.append(1)
                hl = 'ld %s,(XSP+0x4)' % hold.reg
                out = out + [hl] if L == 'X' else [hl] + out
            return out
        i = d['i'].reg
        d['op'] = '(X%s)' % i
        return out + ['ld %s,(XSP+0x4)' % i, 'extz X%s' % i, 'add X%s,X%s' % (i, b)]

    def operand(key, L, p):
        if L in 'PDXQ':
            return A[key]['op']
        return {'G': '(_%sc)' % p, 'M': '(_%ss)' % p, 'E': '(_%sca + 0x3)' % p}[L]

    out = list(pre)
    loaded = []

    def value():
        if V == 'G':
            return ['ld %s,(_vc)' % LOW[val.reg]]
        if V == 'B':
            s_ = scr.reg if scr else val.reg
            o = ['ld %s,(_vc)' % LOW[s_], 'sub %s,(_vd)' % LOW[s_]]
            if s_ != val.reg:
                o.append('ld %s,%s' % (LOW[val.reg], LOW[s_]))
            return o
        return []

    if V == 'C':
        out.append('cal %src' % Z.pre)
    if simple:
        out += emit('O') + emit('I') + value()
    else:
        out += emit('I') + value()
    a2 = operand('I', L2, 'h')
    vb = 'L' if V == 'C' else (LOW[val.reg] if val is not None else None)
    out.append('ldb %s,0x7' % a2 if V == 'K' else 'ld %s,%s' % (a2, vb))
    if not simple:
        out += emit('O')
    a1 = operand('O', L1, 'g')
    if V == 'K':
        if rel is not None:
            out += ['ld %s,0x7' % LOW[rel.reg], 'ld %s,%s' % (a1, LOW[rel.reg])]
        else:
            out.append('ldb %s,0x7' % a1)
    else:
        out.append('ld %s,%s' % (a1, vb))
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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/stret.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-2-micro-stret/out/v423/%s/probes/stret.asm'


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
