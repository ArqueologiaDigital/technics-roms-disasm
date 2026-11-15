#!/usr/bin/env python3
"""fpargg_ast.py -- the cc900 V4.23 oracle's code for the functions of probe fpargg.c (corpus/probes/fpargg.c, oracle
run 2026-11-12-12-micro-fpargg: the construct around one double temporary) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 fpargg_ast.py --check [SET...] [--show N] [--only REGEX] [--rename]

The probe's functions are `void ag_<C><P><V>(void)`: an integer construct C (I if, E if / else, Q ?:, A &&, H a
shift by a variable, W while, F for, D do-while, S switch, G a block, N a nested if) before (P = B) or after (A)
one double statement V (C `vd(gd * gd2)`, O `gd += gd2 / 3.0`).

How it works (fpp_b-FAMILIES.md beside this file has the rules): the function is classified from its AST against
the probe's grammar (canonical notation, globals numbered by first appearance; never by its name); the double
statement takes one 8-byte frame temporary (a frame of 0x10 with the temporary at +8, or of 8 with it at +0 when the
function has a resetting statement, the switch's long stores); the construct's integer code is the probe's own
(tabulated per construct and option level); the probe's symbols are replaced by the real ones.
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
CONSTRUCT = {
    'I': 'if ($gi) ($gu = 1:i);',
    'E': 'if ($gi) ($gu = 1:i); else ($gu = 2:i);',
    'Q': '($gu = ($gi ? 5:i : 7:i));',
    'A': '($gu = ($gi && $gi2));',
    'H': '($gu = ($gu << $gi));',
    'W': 'while (($gi > 0:i)) $gi--;',
    'F': 'for (($gi = 0:i); ($gi < 4:i); $gi++) ($gu += 9:i);',
    'D': 'do $gi--; while (($gi > 0:i));',
    'S': 'switch ($gu) { case 1:i: ($gl = 5:i); break; case 5:i: ($gl = 6:i); break; }',
    'G': '{ ($gu = 1:i); }',
    'N': 'if ($gi) { if ($gi2) ($gu = 1:i); }',
}
DOUBLE = {'C': '$vd(($gd * $gd2));', 'O': '($gd += ($gd2 / 3.0:d));'}


def probe_types():
    return {'gd': 'd', 'gd2': 'd', 'gi': 'i', 'gi2': 'i', 'gu': 'u', 'gl': 'l', 'vd': 'Fv(d)'}


def probe_text(name):
    C, P, V = re.match(r'ag_([IEQAHWFDSGN])([BA])([CO])$', name).groups()
    a, b = CONSTRUCT[C], DOUBLE[V]
    return 'v() { %s }' % (' '.join((a, b) if P == 'B' else (b, a)))


def probe_names():
    return ['ag_%s%s%s' % (C, P, V) for C in 'IEQAHWFDSGN' for P in 'BA' for V in 'CO']


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


def construct(C, opt):
    """the integer construct's code (tabulated per construct; -O3 rotates the while and for loops)"""
    if C == 'I':
        return ['cpw (_gi),0x0', 'j eq,L91', 'ldw (_gu),0x1', 'L91:']
    if C == 'E':
        return ['cpw (_gi),0x0', 'j eq,L91', 'ldw (_gu),0x1', 'j L92', 'L91:', 'ldw (_gu),0x2', 'L92:']
    if C == 'Q':
        return ['ld WA,0x7', 'cpw (_gi),0x0', 'j eq,L91', 'ld WA,0x5', 'L91:', 'ld (_gu),WA']
    if C == 'A':
        return ['ld WA,0x0', 'cpw (_gi),0x0', 'j eq,L91', 'cpw (_gi2),0x0', 'j eq,L91', 'ld WA,0x1', 'L91:',
                'ld (_gu),WA']
    if C == 'H':
        return ['ld BC,(_gu)', 'ld WA,(_gi)', 'and A,0xf', 'j z,L91', 'sll A,BC', 'L91:', 'ld (_gu),BC']
    if C == 'W':
        if opt:
            return ['j L91', 'L92:', 'decw 0x1,(_gi)', 'L91:', 'cpw (_gi),0x0', 'j gt,L92']
        return ['cpw (_gi),0x0', 'j le,L91', 'L92:', 'decw 0x1,(_gi)', 'cpw (_gi),0x0', 'j gt,L92', 'L91:']
    if C == 'F':
        loop = ['L92:', 'addw (_gu),0x9', 'incw 0x1,(_gi)', 'cpw (_gi),0x4', 'j lt,L92']
        if opt:
            return ['ldw (_gi),0x0'] + loop
        return ['ldw (_gi),0x0', 'cpw (_gi),0x4', 'j ge,L91'] + loop + ['L91:']
    if C == 'D':
        return ['L91:', 'decw 0x1,(_gi)', 'cpw (_gi),0x0', 'j gt,L91']
    if C == 'S':
        return ['ld WA,(_gu)', 'cp WA,0x5', 'j eq,L91', 'cp WA,0x1', 'j ne,L92', 'ld XWA,0x5', 'ld (_gl),XWA',
                'j L92', 'L91:', 'ld XWA,0x6', 'ld (_gl),XWA', 'L92:']
    if C == 'G':
        return ['ldw (_gu),0x1']
    return ['cpw (_gi),0x0', 'j eq,L91', 'cpw (_gi2),0x0', 'j eq,L91', 'ldw (_gu),0x1', 'L91:']


def predict(name, s):
    C, P, V = re.match(r'ag_([IEQAHWFDSGN])([BA])([CO])$', name).groups()
    opt, xr = s.startswith('O3'), s.endswith('Xr')
    frame = 8 if C == 'S' else 0x10                            # a resetting statement: the region is D, else D + D'
    tmp = 'XSP' if frame == 8 else 'XSP+%s' % h(frame - 8)
    out = list(K3) if V == 'O' else []
    out.append('dec 0x8,XSP' if frame == 8 else 'lda XSP,XSP-%s' % h(frame))
    if V == 'C':
        dbl = ['lda XBC,_gd', 'lda XDE,_gd2', 'lda XWA,%s' % tmp, 'cal ._fmul_d', 'lda XIY,%s' % tmp,
               'ld XIX,(XIY+0x4)', 'push XIX', 'ld XIX,(XIY)', 'push XIX', 'cal %svd' % ('.' if xr else '_')]
    else:
        dbl = ['lda XBC,_gd2', 'lda XDE,S1', 'lda XWA,%s' % tmp, 'cal ._fdiv_d']
        dbl += ['lda XWA,_gd', 'ld XBC,XWA', 'lda XDE,%s' % tmp] if opt else \
            ['lda XBC,_gd', 'lda XDE,%s' % tmp, 'lda XWA,_gd']
        dbl.append('cal ._fadd_d')
    pending = 8 if (V == 'C' and not xr) else 0                # cdecl: vd's argument still on the stack
    if P == 'B':
        out += construct(C, opt) + dbl
    else:
        out += dbl
        if pending:
            out.append('inc 0x8,XSP')
            pending = 0
        out += construct(C, opt)
    n = frame + pending
    out.append('inc %s,XSP' % h(n) if n <= 8 else 'lda XSP,XSP+%s' % h(n))
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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/fpargg.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-12-micro-fpargg/out/v423/%s/probes/fpargg.asm'


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
