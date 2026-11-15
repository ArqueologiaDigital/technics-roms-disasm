#!/usr/bin/env python3
"""stord_ast.py -- the cc900 V4.23 oracle's code for the functions of probe stord.c (corpus/probes/stord.c, oracle
run 2026-11-10-15-micro-stord) at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 stord_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path.  --rename checks a copy of the probe with every global renamed instead.

The probe's functions are `void st_<t>_<L><R>(int c) { L = R; }`, t = i (int), l (long), c (char):

    L  G global     M member       D member through a pointer   P deref     E constant element
       X element at c              Y member array element through a pointer at c                Q pointer element at c
    R  K constant   G global       E / X element   P deref   D member through a pointer   B difference
       M product    V quotient     R remainder     S shift by c    C call   A call with an argument   N !
       T ?:         W / Z quotient with an indexed operand            U quotient by a constant

How it works (stores-FAMILIES.md beside this file has the rules):
  1. classify(f): the function's AST in a canonical notation, globals numbered by first appearance, matched against
     the probe's grammar written in the same notation.  Nothing is looked up by the function's name.
  2. predict(): the evaluation order (the address first, the value first for a call or a Z quotient), virtual
     registers with live ranges, a priority order in which they take the first free register; the long helper
     forms and the frame are templates per destination.
  3. The probe's symbols are replaced by the real ones.
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
ST = 'S{0:c,2:i,4:l,8:i[4],16:l[4],32:c[4]}'   # struct st { char c; int i; long l; int a[4]; long la[4]; char ca[4]; }
MOFF = {'i': 2, 'l': 4, 'c': 0}                 # the scalar member of each type
AOFF = {'i': 8, 'l': 16, 'c': 32}               # the array member of each type
SZ = {'i': 2, 'l': 4, 'c': 1}


def probe_types():
    ty = {'gi': 'i', 'hi': 'i', 'hj': 'i', 'hc': 'i', 'hd': 'i', 'gl': 'l', 'hl': 'l', 'hm': 'l', 'gc': 'c',
          'gia': 'i[8]', 'hia': 'i[8]', 'gla': 'l[8]', 'hla': 'l[8]', 'gca': 'c[8]', 'hca': 'c[8]',
          'gpi': 'i*', 'hpi': 'i*', 'gpl': 'l*', 'hpl': 'l*', 'gp': 'c*', 'hp': 'c*', 'gs': ST, 'gps': ST + '*',
          'hps': ST + '*', 'ri': 'Fi(v)', 'r1': 'Fi(i)', 'rl': 'Fl(v)', 'rl1': 'Fl(l)', 'rc': 'Fc(v)', 'rc1': 'Fc(c)'}
    return ty


NAMES = {'i': dict(g='gi', a='gia', p='gpi', h='hi', h2='hj', ha='hia', hp='hpi', f='ri', f1='r1'),
         'l': dict(g='gl', a='gla', p='gpl', h='hl', h2='hm', ha='hla', hp='hpl', f='rl', f1='rl1'),
         'c': dict(g='gc', a='gca', p='gp', h='hc', h2='hd', ha='hca', hp='hp', f='rc', f1='rc1')}


def lval(L, t):
    n = NAMES[t]
    return {'G': '$' + n['g'], 'M': '$gs.{%d:%s}' % (MOFF[t], t), 'D': '$gps->{%d:%s}' % (MOFF[t], t),
            'P': '*$' + n['p'], 'E': '$%s[3:i]' % n['a'], 'X': '$%s[@0]' % n['a'],
            'Y': '$gps->{%d:%s[4]}[@0]' % (AOFF[t], t), 'Q': '$%s[@0]' % n['p']}[L]


def rval(R, t):
    n = NAMES[t]
    h, h2 = '$' + n['h'], '$' + n['h2']
    k = '7:l' if t == 'l' else '7:i'
    r = {'K': k, 'G': h, 'E': '$%s[3:i]' % n['ha'], 'X': '$%s[@0]' % n['ha'], 'P': '*$' + n['hp'],
         'D': '$hps->{%d:%s}' % (MOFF[t], t), 'B': '(%s - %s)' % (h, h2), 'M': '(%s * %s)' % (h, h2),
         'V': '(%s / %s)' % (h, h2), 'R': '(%s %% %s)' % (h, h2), 'S': '(%s << @0)' % h, 'C': '$%s()' % n['f'],
         'A': '$%s(%s)' % (n['f1'], h), 'N': '!%s' % h, 'T': '($hc ? %s : %s)' % (h, h2),
         'W': '($%s[@0] / %s)' % (n['ha'], h2), 'Z': '(%s / $%s[@0])' % (h, n['ha']), 'U': '(%s / %s)' % (h, k)}[R]
    if t == 'l' and R == 'N':
        r = '(l)!%s' % h
    if t == 'c' and R == 'T':
        r = '($hc ? $hd : $hc)'
    return r


def probe_text(name):
    m = re.match(r'st_([ilc])_([GMDPEXYQ])([KGEXPDBMVRSCANTWZU])$', name)
    t, L, R = m.groups()
    return 'v(i) { (%s = %s); }' % (lval(L, t), rval(R, t))


def probe_names():
    return ['st_%s_%s%s' % (t, L, R) for t in 'ilc' for L in 'GMDPEXYQ' for R in 'KGEXPDBMVRSCANTWZU']


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
    for v in sorted([v for v in vrs if v.reg is None], key=lambda v: v.prio):
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


class Gen:
    def __init__(self, name, s):
        m = re.match(r'st_([ilc])_([GMDPEXYQ])([KGEXPDBMVRSCANTWZU])$', name)
        self.t, self.L, self.R = m.groups()
        self.s = s
        self.opt = s.startswith('O3')
        self.xr = s.endswith('Xr')
        self.pre = '.' if self.xr else '_'
        self.n = NAMES[self.t]

    def g(self, k):
        return '_' + self.n[k]

    def fn(self, k):
        return self.pre + self.n[k]


def predict(name, s):
    G = Gen(name, s)
    out = body(G)
    return out + ['ret']


# value classes: the order in which the value's register is chosen against the destination's
LOADV = set('GEXPDK')                 # a load: chosen before every address register
OPM = set('MVRUW')                    # a multiply / divide: after D and Y's pointer, before X and Y's offset
OPB = set('BNST')                     # after every address register but P / Q


def body(G):
    t, L, R = G.t, G.L, G.R
    if t == 'l' and R in 'MVRUWZ':
        return long_helper(G)
    if t == 'c':
        return body_c(G)
    need(t in 'il')
    vfirst = R in 'CAZ'
    pA, pV, pS = (5, 1, 10) if vfirst else (1, 3, 10)
    vrs = []
    pre, post = [], []
    # ---- c: its uses (position, kind)
    uses = []
    if L in 'XY':
        uses.append((pA, 'x'))
    elif L == 'Q':
        uses.append((pA, 'q'))
    if R in 'XWZ':
        uses.append((pV, 'x'))
    elif R == 'S':
        uses.append((pV + 0.7, 'n'))
    uses.sort()
    lastc = uses[-1][0] if uses else None
    xlike = any(k == 'x' for _, k in uses)
    cse = G.opt and len(uses) == 2 and all(k == 'x' for _, k in uses)     # -O: one scaled index
    csrc = None                                                # None: the stack slot; 'IZ'; or a VR
    pin = hold = shared = None
    if G.xr and uses:
        if R in 'CA':
            pre += ['push IZ', 'ld IZ,WA']
            post += ['pop IZ']
            csrc = 'IZ'
        else:
            pin = VR('c', 0, uses[0][0] if cse else lastc, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
    elif len(uses) == 2 and not cse and (G.opt or (xlike and t == 'i')):
        hold = VR('hold', 0, lastc, 65)
        if G.opt and uses[0][1] == 'q':                       # -O: a Q formed while the copy lives: not WA
            hold.avoid = lambda: ('WA',)
        hold.lastpos = lastc
        vrs.append(hold)
        csrc = hold
    if cse:
        shared = VR('shared', uses[0][0], pS if (L == 'X' or uses[-1][0] == pA) else pV + 0.5, 25)
        vrs.append(shared)

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        if csrc == 'IZ':
            return 'IZ'
        return csrc.reg

    def inplace_ok(pos):
        return isinstance(csrc, VR) and getattr(csrc, 'lastpos', csrc.u) == pos

    # ---- the destination's address
    A = {'L': L}
    last = pS
    if L in 'PD':
        A['r'] = VR('A' + L, pA, last, 10 if L == 'D' else 70)
        vrs.append(A['r'])
    elif L == 'X':
        if cse:
            A['i'] = shared
        else:
            A['i'] = VR('Aidx', pA, last, 30, prefer=lambda: 'WA')
            vrs.append(A['i'])
        A['b'] = VR('Abase', pA + 0.3, last, 30.1)
        vrs.append(A['b'])
    elif L == 'Q':
        A['T'] = VR('AT', pA + 0.5, last, 30 if vfirst else 70)
        vrs.append(A['T'])
        T = A['T']
        if G.opt:
            if inplace_ok(pA) and csrc is hold:
                if vfirst:
                    T.prio = 85
                A['S'] = hold
                T.prefer = lambda: hold.reg
            elif inplace_ok(pA):
                A['S'] = csrc
                T.prefer = lambda: pin.reg
            else:
                A['S'] = T
        else:
            A['S'] = VR('AS', pA, pA + 0.5, 1)
            vrs.append(A['S'])
            S = A['S']
            T.prefer = lambda: S.reg
    elif L == 'Y':
        A['r'] = VR('Aptr', pA + 0.3, last, 10)
        vrs.append(A['r'])
        if cse and uses[-1][0] == pA:                          # -O: the offset formed in place on the index
            A['S'] = A['o'] = shared
            shared.only = ('WA', 'BC', 'DE', 'HL')
        else:
            A['o'] = VR('Aoff', pA + 0.2, last, 30, only=('WA', 'BC', 'DE', 'HL'))
            vrs.append(A['o'])
            if G.opt and cse:
                A['S'] = A['o']
            else:
                A['S'] = VR('AS', pA, pA + 0.2, 1)
                vrs.append(A['S'])
    fold = R == 'T' and L != 'G'
    if fold and L in 'MEXY':                                   # ?: : the address in one register first
        for k in ('r', 'b', 'i', 'o'):
            if k in A:
                A[k].u = pA + 0.8
        A['F'] = VR('AF', pA + 0.8, last, 31)
        if L == 'X':
            A['F'].prefer = lambda: A['b'].reg
        vrs.append(A['F'])
    elif fold:
        A['F'] = A['r'] if L in 'DP' else A['T']
    # ---- the value
    V = {}
    vprio = 5 if R in LOADV or (t == 'l' and R == 'N') else (20 if R in OPM else 40)
    if R in 'CA':
        V['v'] = VR('HL', pV, pS, 0, fixed='HL')
        vrs.append(V['v'])
    elif R == 'K' and t == 'i':
        pass
    elif R in 'XW':
        V['v'] = VR('V', pV + 0.5, pS, vprio)
        v = V['v']
        if cse:
            V['i'] = shared
            V['b'] = VR('Vbase', pV + 0.3, pV + 0.5, 24 if vprio == 5 else 26, prefer=lambda: v.reg)
            shared.prefer = lambda: v.reg if v.reg != 'WA' else None
            shared.avoid = lambda: (v.reg,) if v.reg == 'WA' else ()
            if vprio == 5:
                V['b'].prio = 6
        else:
            V['i'] = VR('Vidx', pV, pV + 0.5, vprio, prefer=lambda: 'WA')
            V['b'] = VR('Vbase', pV + 0.3, pV + 0.5, 20, prefer=lambda: v.reg)
            vi = V['i']
            v.prefer = lambda: vi.reg
            vrs.append(V['i'])
        vrs += [V['b'], v]
    elif R == 'Z':
        if cse:
            V['i'] = shared
        else:
            V['i'] = VR('Vidx', pV, pV + 0.5, 20, prefer=lambda: 'WA')
            vrs.append(V['i'])
        V['b'] = VR('Vbase', pV + 0.3, pV + 0.5, 26 if cse else 20)
        V['s'] = VR('Vs', pV + 0.4, pV + 0.6, 1)
        vs = V['s']
        V['v'] = VR('V', pV + 0.6, pS, 40, prefer=lambda: vs.reg)
        if G.opt and L == 'Q':
            V['v'].avoid = lambda: ('WA',)
        vrs += [V['b'], V['s'], V['v']]
    elif R in 'PD':
        V['p'] = VR('Vptr', pV, pV + 0.5, vprio, prefer=lambda: 'WA')
        vp = V['p']
        V['v'] = VR('V', pV + 0.5, pS, vprio, prefer=lambda: vp.reg)
        vrs += [V['p'], V['v']]
    else:
        V['v'] = VR('V', pV, pS, vprio)
        vrs.append(V['v'])
        if R == 'S':
            V['n'] = VR('count', pV + 0.7, pV + 0.8, 0, fixed='WA')
            vrs.append(V['n'])
    if R == 'T' and fold:
        V['v'].prio = 5
    allocate(vrs)
    # ---- emission
    sz = SZ[t]
    done = set()                                               # the shared index is formed once

    def index(i):
        """c scaled by the element size into i"""
        if cse and i == shared.reg and 'sh' in done:
            return []
        done.add('sh')
        out = [] if src() == i else ['ld %s,%s' % (i, src())]
        return out + ['add %s,%s' % (i, i) if t == 'i' else 'sla 0x2,%s' % i]

    def yoff(S):
        return 'inc %s,%s' % (h(AOFF[t]), S) if AOFF[t] <= 8 else 'add %s,%s' % (S, h(AOFF[t]))

    def addr():
        if L == 'P':
            A['op'] = '(X%s)' % A['r'].reg
            return ['ld X%s,(%s)' % (A['r'].reg, G.g('p'))]
        if L == 'D':
            A['op'] = '(X%s+%s)' % (A['r'].reg, h(MOFF[t]))
            return ['ld X%s,(_gps)' % A['r'].reg]
        if L == 'X':
            i, b = A['i'].reg, A['b'].reg
            A['op'] = '(X%s+%s)' % (b, i)
            return index(i) + ['lda X%s,%s' % (b, G.g('a'))]
        if L == 'Q':
            S, T = A['S'].reg, A['T'].reg
            out = [] if src() == S else ['ld %s,%s' % (S, src())]
            out += ['exts X%s' % S, 'add X%s,X%s' % (S, S) if t == 'i' else 'sll 0x2,X%s' % S]
            if T != S:
                out.append('ld X%s,X%s' % (T, S))
            A['op'] = '(X%s)' % T
            return out + ['add X%s,(%s)' % (T, G.g('p'))]
        if L == 'Y':
            S, o, r = A['S'].reg, A['o'].reg, A['r'].reg
            if cse:
                sh = shared.reg
                out = index(sh) + ([] if S == sh else ['ld %s,%s' % (S, sh)])
                out += [yoff(S)]
            else:
                out = [] if src() == S else ['ld %s,%s' % (S, src())]
                out += ['add %s,%s' % (S, S) if t == 'i' else 'sla 0x2,%s' % S, yoff(S)]
            if o != S:
                out.append('ld %s,%s' % (LOW[o], LOW[S]))
            A['op'] = '(X%s+%s)' % (r, LOW[o])
            return out + ['ld X%s,(_gps)' % r]
        sym = G.g('g') if L == 'G' else ('_gs' if L == 'M' else G.g('a'))
        off = {'G': None, 'M': MOFF[t], 'E': 3 * sz}[L]
        A['mem'] = '%s + %s' % (sym, h(off)) if off is not None else sym
        A['op'] = '(%s)' % A['mem']
        return []

    def folded():
        if not fold:
            return []
        F = A['F'].reg
        if L in 'ME':
            out = ['lda X%s,%s' % (F, A['mem'])]
        elif L == 'X':
            out = ['lda X%s,X%s+%s' % (F, A['b'].reg, A['i'].reg)]
        elif L == 'Y':
            out = ['lda X%s,X%s+%s' % (F, A['r'].reg, LOW[A['o'].reg])]
        elif L == 'D':
            out = ['inc %s,X%s' % (h(MOFF[t]), F)]
        else:
            out = []
        A['op'] = '(X%s)' % F
        return out

    h1, h2 = G.g('h'), G.g('h2')

    def value():
        if t == 'l':
            return value_l()
        v = V['v'].reg if 'v' in V else None
        if R == 'K':
            return []
        if R == 'G':
            return ['ld %s,(%s)' % (v, h1)]
        if R == 'E':
            return ['ld %s,(%s + %s)' % (v, G.g('ha'), h(3 * sz))]
        if R in 'PD':
            p = V['p'].reg
            return ['ld X%s,(%s)' % (p, G.g('hp') if R == 'P' else '_hps'),
                    'ld %s,(X%s%s)' % (v, p, '' if R == 'P' else '+' + h(MOFF[t]))]
        if R in 'XW':
            i, b = V['i'].reg, V['b'].reg
            out = index(i) + ['lda X%s,%s' % (b, G.g('ha')), 'ld %s,(X%s+%s)' % (v, b, i)]
            if R == 'W':
                out += ['exts X%s' % v, 'divs X%s,(%s)' % (v, h2)]
            return out
        if R == 'Z':
            i, b, s = V['i'].reg, V['b'].reg, V['s'].reg
            out = index(i) + ['lda X%s,%s' % (b, G.g('ha')), 'ld %s,(%s)' % (s, h1), 'exts X%s' % s,
                              'divs X%s,(X%s+%s)' % (s, b, i)]
            if v != s:
                out.append('ld %s,%s' % (v, s))
            return out
        if R == 'B':
            return ['ld %s,(%s)' % (v, h1), 'sub %s,(%s)' % (v, h2)]
        if R == 'M':
            return ['ld %s,(%s)' % (v, h1), 'muls X%s,(%s)' % (v, h2)]
        if R in 'VRU':
            out = ['ld %s,(%s)' % (v, h1), 'exts X%s' % v,
                   'divs X%s,%s' % (v, '0x7' if R == 'U' else '(%s)' % h2)]
            return out + (['ld %s,Q%s' % (v, v)] if R == 'R' else [])
        if R == 'S':
            out = ['ld %s,(%s)' % (v, h1)]
            if src() != 'WA':
                out.append('ld WA,%s' % src())
            return out + ['and A,0xf', 'j z,L50000', 'sla A,%s' % v, 'L50000:']
        if R == 'C':
            return ['cal ' + G.fn('f')]
        if R == 'A':
            if G.xr:
                return ['ld WA,(%s)' % h1, 'cal ' + G.fn('f1')]
            return ['pushw (%s)' % h1, 'cal ' + G.fn('f1'), 'inc 0x2,XSP']
        if R == 'N':
            return ['cpw (%s),0x0' % h1, 'scc eq,%s' % v]
        if R == 'T':
            return ['cpw (_hc),0x0', 'j eq,L2', 'ld %s,(%s)' % (v, h1), 'j L1', 'L2:', 'ld %s,(%s)' % (v, h2), 'L1:']
        raise No()

    def value_l():
        v = V['v'].reg if 'v' in V else None
        xv = 'X%s' % v if v else None
        if R == 'K':
            return ['ld %s,0x7' % xv]
        if R == 'G':
            return ['ld %s,(%s)' % (xv, h1)]
        if R == 'E':
            return ['ld %s,(%s + %s)' % (xv, G.g('ha'), h(3 * sz))]
        if R in 'PD':
            p = V['p'].reg
            return ['ld X%s,(%s)' % (p, G.g('hp') if R == 'P' else '_hps'),
                    'ld %s,(X%s%s)' % (xv, p, '' if R == 'P' else '+' + h(MOFF[t]))]
        if R == 'X':
            i, b = V['i'].reg, V['b'].reg
            return index(i) + ['lda X%s,%s' % (b, G.g('ha')), 'ld %s,(X%s+%s)' % (xv, b, i)]
        if R == 'B':
            return ['ld %s,(%s)' % (xv, h1), 'sub %s,(%s)' % (xv, h2)]
        if R == 'N':
            return ['ld %s,(%s)' % (xv, h1), 'or %s,%s' % (xv, xv), 'scc eq,%s' % v, 'exts %s' % xv]
        if R == 'T':
            return ['cpw (_hc),0x0', 'j eq,L2', 'ld %s,(%s)' % (xv, h1), 'j L1', 'L2:', 'ld %s,(%s)' % (xv, h2), 'L1:']
        if R == 'S':
            out = ['ld %s,(%s)' % (xv, h1)]
            if src() != 'WA':
                out.append('ld WA,%s' % src())
            return out + ['bit 0x4,A', 'j z,L50001', 'sla 0x0,%s' % xv, 'L50001:', 'and A,0xf', 'j z,L50000',
                          'sla A,%s' % xv, 'L50000:']
        if R == 'C':
            return ['cal ' + G.fn('f')]
        if R == 'A':
            if G.xr:
                return ['ld XWA,(%s)' % h1, 'cal ' + G.fn('f1')]
            return ['ld XWA,(%s)' % h1, 'push XWA', 'cal ' + G.fn('f1'), 'inc 0x4,XSP']
        raise No()

    out = list(pre)
    if hold is not None:
        out.append('ld %s,(XSP+0x4)' % hold.reg)
    if vfirst:
        out += value() + addr()
    else:
        out += addr() + folded() + value()
    v = V['v'].reg if 'v' in V else None
    if R == 'K' and t == 'i':
        out.append('ldw %s,0x7' % A['op'])
    else:
        out.append('ld %s,%s' % (A['op'], v if t == 'i' else 'X' + v))
    return out + post


CHARV = set('EXPDCAK')                # values of type char; the others are int values narrowed by the store


def body_c(G):
    """char destinations: the int values (hc, hd are int) are formed in a register pair and stored by its low
    byte; char elements are addressed base + zero-extended index unless c is in a register"""
    L, R = G.L, G.R
    opt, xr = G.opt, G.xr
    if L == 'G' and R == 'Z':                                  # the 16 / 8 divide: hc / (char)hca[c]
        if xr:
            return ['lda XDE,_hca', 'ld BC,(_hc)', 'divs BC,(XDE+WA)', 'ld (_gc),C']
        return ['lda XWA,_hca', 'ld BC,(XSP+0x4)', 'extz XBC', 'add XBC,XWA', 'ld WA,(_hc)', 'divs WA,(XBC)',
                'ld (_gc),A']
    vfirst = R in 'CAZ'
    pA, pV, pS = (5, 1, 10) if vfirst else (1, 3, 10)
    vrs = []
    pre, post = [], []
    uses = []
    fold = R == 'T' and L != 'G'
    if L in 'XQ':
        uses.append((pA + 0.8 if fold else pS, 'e'))           # read by the store's operand (Xb+c) or the extz
    elif L == 'Y':
        uses.append((pA, 'y'))
    if R in 'XWZ':
        uses.append((pV + 0.4, 'e'))
    elif R == 'S':
        uses.append((pV + 0.7, 'n'))
    uses.sort()
    lastc = uses[-1][0] if uses else None
    csrc = None
    pin = hold = None
    if xr and uses:
        if R in 'CA':
            pre += ['push IZ', 'ld IZ,WA']
            post += ['pop IZ']
            csrc = 'IZ'
        elif R == 'S' and lastc > pV + 0.7:                    # the count needs WA: c moves out at the entry
            hold = VR('hold', 0, lastc, 1)
            hold.fromwa = True
            vrs.append(hold)
            csrc = hold
        else:
            pin = VR('c', 0, lastc, 0, fixed='WA')
            vrs.append(pin)
            csrc = pin
    elif opt and len(uses) == 2:
        hold = VR('hold', 0, lastc, 65)
        vrs.append(hold)
        csrc = hold
        if uses[0][1] == 'y':                                  # -O: a Y offset formed while the copy lives
            hold.avoid = lambda: ('WA',)
        if L == 'X' and R == 'W':                              # (tabulated: XW keeps the copy in BC)
            hold.prio = 8.5
    regc = csrc is not None                                    # c in a register: (base + c) operands

    def src():
        if csrc is None:
            return '(XSP+0x4)'
        if csrc == 'IZ':
            return 'IZ'
        return csrc.reg

    # ---- the destination
    A = {'L': L}
    if L in 'PD':
        A['r'] = VR('A' + L, pA, pS, (35 if vfirst else 16) if L == 'D' else 70)
        vrs.append(A['r'])
    elif L in 'XQ':
        A['b'] = VR('Abase', pA, pS if regc else pA + 0.4, 9 if regc else 30, prefer=lambda: 'WA')
        vrs.append(A['b'])
        if not regc:                                          # base + zero-extended c, in the index register
            A['i'] = VR('Aidx', pA + 0.2, pS, 30.1)
            vrs.append(A['i'])
        elif fold:
            A['F'] = VR('AF', pA + 0.8, pS, 31, prefer=lambda: A['b'].reg)
            A['b'].u = pA + 0.8
            vrs.append(A['F'])
    elif L == 'Y':
        A['r'] = VR('Aptr', pA + 0.3, pS, 10)
        vrs.append(A['r'])
        if opt and (pin is None or vfirst or pin.u > pA):     # -O: the offset formed in its own register
            A['o'] = VR('Aoff', pA, pS, 10.5, only=('WA', 'BC', 'DE', 'HL'))
            if pin is not None and pin.u == pA:              # (in place on c, kept in WA when the value is first)
                A['o'].prefer = lambda: 'WA'
                A['o'].prio = 9
            if hold is not None and lastc == pA:              # (in place on the held copy)
                hold.prio = 10.4
                A['o'].prefer = lambda: hold.reg
            A['S'] = A['o']
            vrs.append(A['o'])
        else:
            A['S'] = VR('AS', pA, pA + 0.2, 1)
            A['o'] = VR('Aoff', pA + 0.2, pS, 10.5, only=('WA', 'BC', 'DE', 'HL'))
            vrs += [A['S'], A['o']]
        if fold:
            A['r'].u = A['o'].u = pA + 0.8
            A['F'] = VR('AF', pA + 0.8, pS, 31)
            vrs.append(A['F'])
    elif L in 'ME' and fold:
        A['F'] = VR('AF', pA + 0.8, pS, 31)
        vrs.append(A['F'])
        if L == 'M' and not opt:
            A['S'] = VR('AS', pA, pA + 0.8, 1)
            vrs.append(A['S'])
    if fold and L in 'PD':
        A['F'] = A['r']
    if fold and L in 'XQ' and not regc:
        A['F'] = A['i']
    # ---- the value
    V = {}
    lt = None                                                  # -O0: a char load goes through A when it is free
    if R in 'CA':
        V['v'] = VR('HL', pV, pS, 0, fixed='HL')
        vrs.append(V['v'])
    elif R == 'K':
        pass
    elif R in 'XWZ':
        tp = 15 if R == 'X' else 5
        V['b'] = VR('Vbase', pV, pV + (0.45 if regc else 0.3), {'X': 10.3, 'W': 10.2, 'Z': 5}[R],
                    prefer=lambda: 'WA')
        vrs.append(V['b'])
        if not regc:
            V['i'] = VR('Vidx', pV + 0.2, pV + 0.45, 10.25 if R == 'W' else tp)
            vrs.append(V['i'])
        if R == 'Z':
            V['s'] = VR('Vs', pV + 0.6, pV + 0.7, 2)
            V['d'] = VR('Vd', pV + 0.5, pV + 0.7, 3)
            vs = V['s']
            V['v'] = VR('V', pV + 0.7, pS, 8 if regc and L in 'XQ' else 30.05, prefer=lambda: vs.reg)
            vrs += [V['s'], V['d'], V['v']]
            if opt:                                            # -O: the dividend formed in the final register
                vrs.remove(V['s'])
                V['v'].d = V['s'].d
                V['s'] = V['v']
                V['v'].prio = 2
                V['v'].prefer = None
                V['d'].avoid = lambda: ('WA',)
                if L == 'Y':                                   # (tabulated: YZ's registers)
                    V['v'].reg = 'HL'
                    V['d'].reg = 'BC' if pin is None else 'DE'
                    A['r'].avoid = lambda: ('WA',)
            if not opt:
                lt = VR('lt', pV + 0.45, pV + 0.5, 4, prefer=lambda: 'WA')
                vrs.append(lt)
        else:
            V['v'] = VR('V', pV + 0.45, pS, 5)
            vrs.append(V['v'])
            if not opt:
                lt = VR('lt', pV + 0.45, pV + 0.5, 4, prefer=lambda: 'WA')
                vrs.append(lt)
                vlt = lt
                V['v'].prefer = lambda: vlt.reg
                V['v'].d = pV + 0.5
    elif R in 'PD':
        V['p'] = VR('Vptr', pV, pV + 0.5, 5, prefer=lambda: 'WA')
        vp = V['p']
        V['v'] = VR('V', pV + 0.5, pS, 5, prefer=lambda: vp.reg)
        vrs += [V['p'], V['v']]
    else:
        V['v'] = VR('V', pV, pS, 11 if R == 'S' else 5)
        vrs.append(V['v'])
        if R == 'S':
            V['n'] = VR('count', pV + 0.7, pV + 0.8, 0, fixed='WA')
            vrs.append(V['n'])
    narrow = R not in CHARV and not opt                        # -O0: the narrowed store goes through A
    fixed = {id(v) for v in vrs if v.reg is not None}
    allocate(vrs)
    if narrow and 'v' in V and V['v'].reg != 'WA':
        sa = VR('storeA', pS - 0.05, pS, 0, fixed='WA')
        if all(not (u.reg == 'WA' and overlap(u, sa)) for u in vrs if id(u) in fixed):
            for u in vrs:                                      # again, with A kept free for the store
                if id(u) not in fixed:
                    u.reg = None
            vrs.append(sa)
            allocate(vrs)
            V['viaA'] = True
    # ---- emission
    lo = LOW

    loaded = []

    def elem(b, i, sym, ldb):
        """the address of a char element: (operand text, lines)"""
        out = [ldb % (b, sym)]
        if regc:
            if hold is not None and not loaded:                # the held copy is loaded at its first use
                loaded.append(1)
                hl = 'ld %s,(XSP+0x4)' % hold.reg
                out = out + [hl] if ldb.startswith('lda') else [hl] + out
            return '(X%s+%s)' % (b, src()), out
        return '(X%s)' % i, out + ['ld %s,(XSP+0x4)' % i, 'extz X%s' % i, 'add X%s,X%s' % (i, b)]

    def addr():
        if L == 'P':
            A['op'] = '(X%s)' % A['r'].reg
            return ['ld X%s,(_gp)' % A['r'].reg]
        if L == 'D':
            A['op'] = '(X%s)' % A['r'].reg
            return ['ld X%s,(_gps)' % A['r'].reg]
        if L in 'XQ':
            A['op'], out = elem(A['b'].reg, A['i'].reg if 'i' in A else None, '_gca' if L == 'X' else '_gp',
                                'lda X%s,%s' if L == 'X' else 'ld X%s,(%s)')
            return out
        if L == 'Y':
            S, o, r = A['S'].reg, A['o'].reg, A['r'].reg
            out = [] if src() == S else ['ld %s,%s' % (S, src())]
            out.append('add %s,0x20' % S)
            if o != S:
                out.append('ld %s,%s' % (lo[o], lo[S]))
            A['op'] = '(X%s+%s)' % (r, lo[o])
            return out + ['ld X%s,(_gps)' % r]
        A['mem'] = {'G': '_gc', 'M': '_gs', 'E': '_gca + 0x3'}[L]
        A['op'] = '(%s)' % A['mem']
        return []

    def folded():
        if not fold:
            return []
        F = A['F'].reg
        out = []
        if L == 'M' and not opt:
            out = ['lda X%s,_gs' % A['S'].reg, 'ld X%s,X%s' % (F, A['S'].reg)]
        elif L in 'ME':
            out = ['lda X%s,%s' % (F, A['mem'])]
        elif L == 'Y':
            out = ['lda X%s,X%s+%s' % (F, A['r'].reg, lo[A['o'].reg])]
        elif L in 'XQ' and regc:
            out = ['lda X%s,X%s+%s' % (F, A['b'].reg, src())]
        A['op'] = '(X%s)' % F
        return out

    def value():
        v = V['v'].reg if 'v' in V else None
        if R == 'K':
            return []
        if R == 'G':
            return ['ld %s,(_hc)' % v]
        if R == 'E':
            return ['ld %s,(_hca + 0x3)' % lo[v]]
        if R in 'PD':
            p = V['p'].reg
            return ['ld X%s,(%s)' % (p, '_hp' if R == 'P' else '_hps'), 'ld %s,(X%s)' % (lo[v], p)]
        if R in 'XWZ':
            op, out = elem(V['b'].reg, V['i'].reg if 'i' in V else None, '_hca', 'lda X%s,%s')
            tgt = V['d'].reg if R == 'Z' else v
            if lt is not None:
                out.append('ld %s,%s' % (lo[lt.reg], op))
                if lt.reg != tgt:
                    out.append('ld %s,%s' % (lo[tgt], lo[lt.reg]))
            else:
                out.append('ld %s,%s' % (lo[tgt], op))
            if R == 'W':
                out += ['exts %s' % v, 'exts X%s' % v, 'divs X%s,(_hd)' % v]
            elif R == 'Z':
                d, s_ = V['d'].reg, V['s'].reg
                out += ['exts %s' % d, 'ld %s,(_hc)' % s_, 'exts X%s' % s_, 'divs X%s,%s' % (s_, d)]
                if v != s_:
                    out.append('ld %s,%s' % (v, s_))
            return out
        if R == 'B':
            return ['ld %s,(_hc)' % v, 'sub %s,(_hd)' % v]
        if R == 'M':
            return ['ld %s,(_hc)' % v, 'muls X%s,(_hd)' % v]
        if R in 'VRU':
            out = ['ld %s,(_hc)' % v, 'exts X%s' % v, 'divs X%s,%s' % (v, '0x7' if R == 'U' else '(_hd)')]
            return out + (['ld %s,Q%s' % (v, v)] if R == 'R' else [])
        if R == 'S':
            out = ['ld %s,(_hc)' % v]
            if src() != 'WA':
                out.append('ld WA,%s' % src())
            return out + ['and A,0xf', 'j z,L50000', 'sla A,%s' % v, 'L50000:']
        if R == 'C':
            return ['cal ' + G.fn('f')]
        if R == 'A':
            if xr:
                return ['ld WA,(_hc)', 'cal ' + G.fn('f1')]
            return ['ld WA,(_hc)', 'exts WA', 'push WA', 'cal ' + G.fn('f1'), 'inc 0x2,XSP']
        if R == 'N':
            return ['cpw (_hc),0x0', 'scc eq,%s' % v]
        if R == 'T':
            if opt:
                return ['ld %s,(_hc)' % v, 'cp %s,0x0' % v, 'j eq,L1', 'ld %s,(_hd)' % v, 'L2:', 'L1:']
            return ['cpw (_hc),0x0', 'j eq,L2', 'ld %s,(_hd)' % v, 'j L1', 'L2:', 'ld %s,(_hc)' % v, 'L1:']
        raise No()

    out = list(pre)
    first_elem = (L in 'XQ' and not vfirst) or (R in 'XWZ' and vfirst)
    if hold is not None and (getattr(hold, 'fromwa', False) or not first_elem):
        loaded.append(1)
        out.append('ld %s,%s' % (hold.reg, 'WA' if getattr(hold, 'fromwa', False) else '(XSP+0x4)'))
    if vfirst:
        out += value() + addr()
    else:
        out += addr() + folded() + value()
    if R == 'K':
        return out + ['ldb %s,0x7' % A['op']] + post
    v = V['v'].reg
    if V.get('viaA'):
        out += ['ld A,%s' % lo[v], 'ld %s,A' % A['op']]
    else:
        out.append('ld %s,%s' % (A['op'], lo[v]))
    return out + post


HELPER = {'M': 'C9H_mulls', 'V': 'C9H_divls', 'R': 'C9H_remls', 'U': 'C9H_divls', 'W': 'C9H_divls', 'Z': 'C9H_divls'}


def long_helper(G):
    """long * / % through the C9H helpers: operands in XWA, XBC, the result in XHL; the destination's address is
    kept in XIZ, in a frame slot or rebuilt after the call (templates per destination)"""
    L, R, xr, opt = G.L, G.R, G.xr, G.opt
    hl_, hm_ = '_hl', '_hm'
    call = 'cal ' + HELPER[R]
    if R in 'MVRU':
        ops = ['ld XWA,(%s)' % hl_, 'ld XBC,%s' % ('0x7' if R == 'U' else '(%s)' % hm_), call]
        if L in 'GME':
            op = {'G': '(_gl)', 'M': '(_gs + 0x4)', 'E': '(_gla + 0xc)'}[L]
            return ops + ['ld %s,XHL' % op]
        if L in 'PD':
            return ['push XIZ', 'ld XIZ,(%s)' % ('_gpl' if L == 'P' else '_gps')] + ops + \
                ['ld (XIZ%s),XHL' % ('' if L == 'P' else '+0x4'), 'pop XIZ']
        if L == 'Q':
            return ['push XIZ'] + ([] if xr else ['ld WA,(XSP+0x8)']) + \
                ['exts XWA', 'sll 0x2,XWA', 'ld XIZ,XWA', 'add XIZ,(_gpl)'] + ops + ['ld (XIZ),XHL', 'pop XIZ']
        if L == 'Y':
            return ['dec 0x2,XSP', 'push XIZ'] + ([] if xr else ['ld WA,(XSP+0xa)']) + \
                ['sla 0x2,WA', 'add WA,0x10', 'ld (XSP+0x4),A', 'ld XIZ,(_gps)'] + ops + \
                ['ld A,(XSP+0x4)', 'ld (XIZ+A),XHL', 'pop XIZ', 'inc 0x2,XSP']
        if opt or R == 'U':                                    # X: the scaled index in a slot, the base in XIZ
            return ['dec 0x2,XSP', 'push XIZ'] + ['ld (XSP+0x4),WA' if xr else 'ld WA,(XSP+0xa)'] + \
                ([] if xr else ['ld (XSP+0x4),WA']) + \
                ['ld WA,(XSP+0x4)', 'sla 0x2,WA', 'ld (XSP+0x4),WA', 'lda XIZ,_gla'] + ops + \
                ['ld WA,(XSP+0x4)', 'ld (XIZ+WA),XHL', 'pop XIZ', 'inc 0x2,XSP']
        return ['dec 0x4,XSP', 'push IZ', 'ld IZ,WA' if xr else 'ld IZ,(XSP+0xa)', 'sla 0x2,IZ', 'lda XWA,_gla',
                'ld (XSP+0x2),XWA'] + ops + ['ld XWA,(XSP+0x2)', 'ld (XWA+IZ),XHL', 'pop IZ', 'inc 0x4,XSP']
    if R == 'W':
        n = 2 if L == 'G' else 6
        slot = '(XSP+0x4)' if L == 'G' else '(XSP+0x8)'
        par = '(XSP+%s)' % h(4 + n + 4)
        a = 'XBC' if xr else 'XWA'
        out = ['dec %s,XSP' % h(n), 'push XIZ']
        cse = False
        if L in 'MEPD':
            out += [{'M': 'lda %s,_gs + 0x4', 'E': 'lda %s,_gla + 0xc', 'P': 'ld %s,(_gpl)',
                     'D': 'ld %s,(_gps)'}[L] % a]
            if L == 'D':
                out.append('inc 0x4,%s' % a)
            out.append('ld (XSP+0x4),%s' % a)
        elif L == 'X' and opt:                                  # one scaled index for both elements
            cse = True
            out += (['ld %s,WA' % slot] if xr else ['ld WA,%s' % par, 'ld %s,WA' % slot]) + \
                ['ld WA,%s' % slot, 'sla 0x2,WA', 'ld %s,WA' % slot, 'lda XBC,_gla', 'ld DE,%s' % slot,
                 'lda XWA,XBC+DE', 'ld (XSP+0x4),XWA', 'lda XIZ,_hla', 'ld XWA,(XIZ+DE)', 'ld XBC,(_hm)']
        elif L == 'Y' and opt:
            cse = True
            out += (['ld %s,WA' % slot] if xr else ['ld WA,%s' % par, 'ld %s,WA' % slot]) + \
                ['ld WA,%s' % slot, 'sla 0x2,WA', 'ld %s,WA' % slot, 'ld BC,%s' % slot, 'add BC,0x10',
                 'ld XWA,(_gps)', 'lda XWA,XWA+C', 'ld (XSP+0x4),XWA', 'lda XIZ,_hla', 'ld WA,%s' % slot,
                 'ld XWA,(XIZ+WA)', 'ld XBC,(_hm)']
        elif L == 'X':
            out += (['ld BC,WA', 'sla 0x2,BC', 'lda XDE,_gla', 'exts XBC', 'add XBC,XDE', 'ld (XSP+0x4),XBC']
                    if xr else ['ld WA,%s' % par, 'sla 0x2,WA', 'lda XBC,_gla', 'exts XWA', 'add XWA,XBC',
                                'ld (XSP+0x4),XWA'])
        elif L == 'Y':
            out += (['ld BC,WA', 'sla 0x2,BC', 'add BC,0x10', 'ld E,C', 'ld XBC,(_gps)', 'lda XBC,XBC+E',
                     'ld (XSP+0x4),XBC'] if xr else
                    ['ld WA,%s' % par, 'sla 0x2,WA', 'add WA,0x10', 'ld C,A', 'ld XWA,(_gps)', 'lda XWA,XWA+C',
                     'ld (XSP+0x4),XWA'])
        elif L == 'Q':
            if xr:
                out += ['ld BC,WA', 'exts XBC', 'sll 0x2,XBC', 'ld (XSP+0x4),XBC', 'ld XBC,(_gpl)',
                        'add (XSP+0x4),XBC']
            elif opt:
                out += ['ld BC,%s' % par, 'ld WA,BC', 'exts XWA', 'sll 0x2,XWA', 'ld (XSP+0x4),XWA',
                        'ld XWA,(_gpl)', 'add (XSP+0x4),XWA', 'ld %s,BC' % slot]
            else:
                out += ['ld WA,%s' % par, 'exts XWA', 'sll 0x2,XWA', 'ld (XSP+0x4),XWA', 'ld XWA,(_gpl)',
                        'add (XSP+0x4),XWA']
        if not cse:
            if xr:
                out.append('ld %s,WA' % slot)
            elif not (L == 'Q' and opt):
                out += ['ld WA,%s' % par, 'ld %s,WA' % slot]
            out += ['ld WA,%s' % slot, 'sla 0x2,WA', 'ld %s,WA' % slot, 'lda XIZ,_hla']
            load = ['ld WA,%s' % slot, 'ld XWA,(XIZ+WA)']
            out += load + ['ld XBC,(_hm)'] if opt else ['ld XBC,(_hm)'] + load
        out.append(call)
        out += ['ld (_gl),XHL'] if L == 'G' else ['ld XWA,(XSP+0x4)', 'ld (XWA),XHL']
        return out + ['pop XIZ', 'inc %s,XSP' % h(n)]
    # Z: hl / hla[c]
    spill = xr and L in 'XYQ' and not (opt and L in 'XY')        # c kept in a slot across the call
    n = 4 if spill else 2
    par = '(XSP+0x6)' if spill else '(XSP+0xa)'
    out = ['dec %s,XSP' % h(n), 'push XIZ']
    if spill:
        out += ['ld (XSP+0x6),WA', 'ld WA,(XSP+0x6)', 'ld (XSP+0x4),WA']
    elif xr:
        out += ['ld (XSP+0x4),WA']
    else:
        out += ['ld WA,(XSP+0xa)', 'ld (XSP+0x4),WA']
    out += ['ld WA,(XSP+0x4)', 'sla 0x2,WA', 'ld (XSP+0x4),WA', 'lda XIZ,_hla']
    ld = ['ld XWA,(_hl)', 'ld BC,(XSP+0x4)']
    out += (ld[::-1] if opt else ld) + ['ld XBC,(XIZ+BC)', call]
    if L in 'GME':
        out.append('ld %s,XHL' % {'G': '(_gl)', 'M': '(_gs + 0x4)', 'E': '(_gla + 0xc)'}[L])
    elif L in 'PD':
        out += ['ld XWA,(%s)' % ('_gpl' if L == 'P' else '_gps'), 'ld (XWA%s),XHL' % ('' if L == 'P' else '+0x4')]
    elif L == 'X':
        out += ['lda XBC,_gla', 'ld WA,(XSP+0x4)', 'ld (XBC+WA),XHL'] if opt else \
            ['ld WA,%s' % par, 'sla 0x2,WA', 'lda XBC,_gla', 'ld (XBC+WA),XHL']
    elif L == 'Y':
        out += ['ld BC,(XSP+0x4)', 'add BC,0x10', 'ld XWA,(_gps)', 'ld (XWA+C),XHL'] if opt else \
            ['ld WA,%s' % par, 'sla 0x2,WA', 'add WA,0x10', 'ld C,A', 'ld XWA,(_gps)', 'ld (XWA+C),XHL']
    else:
        out += ['ld WA,%s' % par, 'exts XWA', 'sll 0x2,XWA', 'add XWA,(_gpl)', 'ld (XWA),XHL']
    return out + ['pop XIZ', 'inc %s,XSP' % h(n)]


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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/stord.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-15-micro-stord/out/v423/%s/probes/stord.asm'


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
