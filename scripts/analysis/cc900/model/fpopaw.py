#!/usr/bin/env python3
"""fpopa_ast.py -- the cc900 V4.23 oracle's code for the functions of probe fpopa.c (corpus/probes/fpopa.c, oracle
run 2026-11-12-10-micro-fpopa: double compound assignments) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 fpopa_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]

The probe's functions are `void fa_<o>_<L><V><C>(int c)`: o a `+=`, m `*=`; L G gd, M gs.d, E gda[2], X gda[c];
V G hd, N -hd, K 3.0, E hda[1], C (double)gi, B hd / 3.0, S the target itself; C T at the top level, I inside
`if (gi) { .. }`.

How it works (fpp_b-FAMILIES.md beside this file has the rules): the function is classified from its AST against
the probe's grammar (canonical notation, globals numbered by first appearance; never by its name); the code is the
helper call `._fadd_d` / `._fmul_d` (XWA the destination, XBC the left operand, XDE the right one), the target's
address in XIZ unless it is a plain global, the right operand formed first in a frame temporary when it is an
operation; the probe's symbols are replaced by the real ones.
"""
HOME_ = __import__('os').path.expanduser('~/')
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
    if ty.kind == 'float':
        need(ty.size == 8)
        return 'd'
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
    PT = {'long': 'l', 'int': 'i', 'void': 'v', 'long int': 'l', 'char': 'c', 'double': 'd', 'int *': 'i*'}
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
            need(n.kind in ('IntegralCast', 'IntegralToFloating'))
            return '(%s%s)%s' % (tn(n.ty), '' if n.explicit else '~', self.e(n.e))
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
        if k == 'fconst':
            need(n.value is not None)
            return '%r:%s' % (float(n.value), tn(n.ty))
        if k == 'opassign':
            return '(%s %s= %s)' % (self.e(n.l), n.op, self.e(n.r))
        if k == 'incdec':
            return ('%s%s' % (self.e(n.e), n.op)) if n.post else ('%s%s' % (n.op, self.e(n.e)))
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
        k = st.k
        if k == 'return':
            need(st.value is not None)
            return 'return %s;' % self.e(st.value)
        if k == 'expr':
            return self.e(st.e) + ';'
        if k == 'block':
            return '{ %s }' % ' '.join(self.s(x) for x in st.body)
        if k == 'if':
            return 'if (%s) %s%s' % (self.e(st.cond), self.s(st.then),
                                     ' else %s' % self.s(st.els) if st.els is not None else '')
        if k == 'while':
            return 'while (%s) %s' % (self.e(st.cond), self.s(st.body))
        if k == 'do':
            return 'do %s while (%s);' % (self.s(st.body), self.e(st.cond))
        if k == 'for':
            return 'for (%s %s; %s) %s' % (self.s(st.init), self.e(st.cond), self.e(st.inc), self.s(st.body))
        if k == 'switch':
            return 'switch (%s) %s' % (self.e(st.value), self.s(st.body))
        if k == 'case':
            return 'case %s: %s' % (self.e(st.value), self.s(st.body))
        if k == 'break':
            return 'break;'
        raise No()

    def function(self):
        f = self.f
        sig = '%s(%s)' % (tn(f.ret), ','.join(tn(p.ty) for p in f.params))
        body = f.body.body if f.body.k == 'block' else [f.body]
        return sig + ' { ' + ' '.join(self.s(x) for x in body) + ' }'


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
ST = 'S{0:c,2:i,4:d}'                           # struct st { char c; int i; double d; }


def probe_types():
    return {'gd': 'd', 'hd': 'd', 'gda': 'd[4]', 'hda': 'd[4]', 'gi': 'i', 'gs': ST}


def lv(L):
    return {'G': '$gd', 'M': '$gs.{4:d}', 'E': '$gda[2:i]', 'X': '$gda[@0]'}[L]


def probe_text(name):
    o, L, V, C = re.match(r'fa_([am])_([GMEX])([GNKECBS])([TI])$', name).groups()
    r = {'G': '$hd', 'N': '-$hd', 'K': '3.0:d', 'E': '$hda[1:i]', 'C': '(d)$gi', 'B': '($hd / 3.0:d)',
         'S': lv(L)}[V]
    st = '(%s %s= %s);' % (lv(L), '+' if o == 'a' else '*', r)
    if C == 'I':
        st = 'if ($gi) { %s }' % st
    return 'v(i) { %s }' % st


def probe_names():
    return ['fa_%s_%s%s%s' % (o, L, V, C) for o in 'am' for L in 'GMEX' for V in 'GNKECBS' for C in 'TI']


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
def h(n):
    return '0x%x' % n


K3 = ['align 2', 'S1:', 'fdatad 3.00000000000000000000e+000']


def predict(name, s):
    o, L, V, C = re.match(r'fa_([am])_([GMEX])([GNKECBS])([TI])$', name).groups()
    opt, xr = s.startswith('O3'), s.endswith('Xr')
    helper = 'cal ._fadd_d' if o == 'a' else 'cal ._fmul_d'
    xiz = L != 'G'
    frame = {'N': 0x10, 'B': 0x10, 'C': 0x18}.get(V, 0)
    up = 4 if xiz else 0                                       # push XIZ above the frame
    tmp = 'XSP+%s' % h((0x8 if V in 'NB' else 0xc) + up)
    lslot = '(XSP+%s)' % h(0x14 + up)
    par = '(XSP+%s)' % h(4 + frame + up)
    addr = {'G': '_gd', 'M': '_gs + 0x4', 'E': '_gda + 0x10'}.get(L)
    out = list(K3) if V in 'KB' else []
    if frame:
        out.append('lda XSP,XSP-%s' % h(frame))
    if xiz:
        out.append('push XIZ')
    tail = []
    # the condition
    gi_reg = None
    hoist = []
    if L == 'X' and V == 'S' and opt and xr:                   # (O3XSXr: c leaves WA before the test)
        hoist = ['ld BC,WA']
    out += hoist
    if C == 'I':
        if V == 'C' and opt:                                   # -O: gi loaded once, for the test and the conversion
            gi_reg = 'BC' if (xr and L == 'X') else 'WA'
            out += ['ld %s,(_gi)' % gi_reg, 'cp %s,0x0' % gi_reg, 'j eq,L1']
        elif frame or xiz:
            out += ['cpw (_gi),0x0', 'j eq,L1']
        else:
            out += ['cpw (_gi),0x0', 'ret eq']
    body = []
    # the target's address in XIZ
    if L in 'ME':
        if V == 'S' and opt:
            body += ['lda XDE,%s' % addr, 'ld XIZ,XDE']
        else:
            body.append('lda XIZ,%s' % addr)
    elif L == 'X':
        if V == 'S' and opt:
            src = [] if xr else ['ld BC,%s' % par]
            body += src + ['sla 0x3,BC', 'lda XWA,_gda', 'lda XDE,XWA+BC', 'ld XIZ,XDE']
        elif V == 'S' and xr:
            body += ['ld BC,WA', 'sla 0x3,BC', 'lda XDE,_gda', 'lda XIZ,XDE+BC']
        elif gi_reg == 'WA':
            body += ['ld BC,%s' % par, 'sla 0x3,BC', 'lda XDE,_gda', 'lda XIZ,XDE+BC']
        elif gi_reg == 'BC':
            body += ['sla 0x3,WA', 'lda XDE,_gda', 'lda XIZ,XDE+WA']
        else:
            body += ([] if xr else ['ld WA,%s' % par]) + ['sla 0x3,WA', 'lda XBC,_gda', 'lda XIZ,XBC+WA']
    # the right operand
    if V == 'N':
        body += ['lda XBC,_hd', 'lda XWA,%s' % tmp, 'cal ._fneg_d']
        R = tmp
    elif V == 'B':
        body += ['lda XBC,_hd', 'lda XDE,S1', 'lda XWA,%s' % tmp, 'cal ._fdiv_d']
        R = tmp
    elif V == 'C':
        r = gi_reg or 'WA'
        body += ([] if gi_reg else ['ld WA,(_gi)']) + ['exts X%s' % r, 'ld %s,X%s' % (lslot, r),
                                                       'lda XBC,%s' % lslot[1:-1], 'lda XWA,%s' % tmp,
                                                       'cal ._fld_dl']
        R = tmp
    else:
        R = {'G': '_hd', 'K': 'S1', 'E': '_hda + 0x8'}.get(V)
    # the operation
    if not xiz:
        if V == 'S':
            body += ['lda XWA,_gd', 'ld XBC,XWA', 'ld XDE,XWA'] if opt else \
                ['lda XBC,_gd', 'lda XDE,_gd', 'lda XWA,_gd']
        elif V == 'E':
            body += ['lda XDE,%s' % R] + (['lda XWA,_gd', 'ld XBC,XWA'] if opt else ['lda XBC,_gd', 'lda XWA,_gd'])
        else:
            body += ['lda XWA,_gd', 'ld XBC,XWA', 'lda XDE,%s' % R] if opt else \
                ['lda XBC,_gd', 'lda XDE,%s' % R, 'lda XWA,_gd']
    else:
        if V == 'S' and not opt:
            if L == 'X':
                body += (['sla 0x3,WA'] if xr else ['ld WA,%s' % par, 'sla 0x3,WA']) + ['lda XBC,_gda',
                                                                                        'lda XDE,XBC+WA']
            else:
                body.append('lda XDE,%s' % addr)
        elif V != 'S':
            body.append('lda XDE,%s' % R)
        body += ['ld XBC,XIZ', 'ld XWA,XIZ']
    body.append(helper)
    out += body
    if C == 'I':
        out.append('L1:')
    if xiz:
        out.append('pop XIZ')
    if frame:
        out.append('lda XSP,XSP+%s' % h(frame))
    return out + ['ret']


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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/fpopa.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-10-micro-fpopa/out/v423/%s/probes/fpopa.asm'


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
