#!/usr/bin/env python3
"""loopctr_ast.py -- the cc900 oracle's code for the functions of probe loopctr.c (corpus/probes/loopctr.c, oracle run
2026-11-12-7-micro-loopctr), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'
    python3 loopctr_ast.py --check SET [--show N] [--one] [--dec] [--only REGEX]   (the model directory on sys.path)

As lhx_ast.py: the function's AST in a canonical notation is matched against the probe's grammar (probe_text), the
code is written for that probe name with the probe's symbols, then the real symbols are substituted.  The rules are
in idxloc-FAMILIES.md.  Nothing is looked up by the function's name.
"""
HOME_ = __import__('os').path.expanduser('~/')
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
    """a type in the notation: c b i u l n, v void, T* pointer, T[n] array, S{off:T,...} struct, F<ret>(<params>)"""
    need(ty is not None)
    if ty.kind == 'int':
        r = TL.get((ty.size, ty.signed))
        need(r is not None)
        return r
    if ty.kind == 'void':
        return 'v'
    if ty.kind == 'float':
        return {4: 'f', 8: 'd'}.get(ty.size) or need(False)
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
    PT = {'long': 'l', 'unsigned long': 'n', 'int': 'i', 'unsigned int': 'u', 'char': 'c', 'unsigned char': 'b',
          'void': 'v', 'long int': 'l', 'unsigned long int': 'n', 'unsigned': 'u'}
    need(all(p in PT for p in ps))
    return 'F%s(%s)' % (tn(ty.ret), ','.join(PT[p] for p in ps))


class Render:
    """AST -> notation text; globals keep their names (prefixed '$'), their types collected in self.gty"""

    def __init__(self, f, adecl):
        self.f, self.adecl = f, adecl
        self.gty = {}
        self.locals = []

    def glob(self, d, ty):
        t = fn_type(ty) if ty.kind == 'func' else tn(ty)
        if ty.kind == 'func' and self.adecl:
            need(not getattr(ty, 'cdecl', False))              # a __cdecl callee in a -Xr file: other code
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
            if d.kind == 'local':
                need(d in self.locals)
                return '%%%d' % self.locals.index(d)
            need(d.kind in ('global', 'func'))
            return self.glob(d, d.ty)
        if k == 'const':
            need(n.value is not None)
            return str(n.value)
        if k == 'fconst':
            return repr(n.value)
        if k == 'addr':
            return '&%s' % self.e(n.e)
        if k == 'opassign':
            return '(%s %s= %s)' % (self.e(n.l), n.op, self.e(n.r))
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
        if k == 'incdec':
            return ('%s%s' % (self.e(n.e), n.op)) if n.post else ('%s%s' % (n.op, self.e(n.e)))
        raise No()

    def s(self, st):
        k = st.k
        if k == 'expr':
            return self.e(st.e) + ';'
        if k == 'decl':
            d = st.var
            need(d.kind == 'local' and not getattr(d, 'addr_taken', False))
            need(getattr(d, 'storage', '') in ('', None))
            self.locals.append(d)
            if st.init is None:
                return '%s %%%d;' % (tn(d.ty), len(self.locals) - 1)
            return '%s %%%d = %s;' % (tn(d.ty), len(self.locals) - 1, self.e(st.init))
        if k == 'for':
            need(st.init is not None and st.cond is not None and st.inc is not None)
            return 'for (%s %s %s) %s' % (self.s(st.init), self.e(st.cond), self.e(st.inc), self.body(st.body))
        if k == 'if':
            need(st.els is None)
            return 'if (%s) %s' % (self.e(st.cond), self.body(st.then))
        if k == 'while':
            return 'while (%s) %s' % (self.e(st.cond), self.body(st.body))
        if k == 'do':
            return 'do %s while (%s);' % (self.body(st.body), self.e(st.cond))
        if k == 'return':
            return 'return %s;' % self.e(st.value) if st.value is not None else 'return;'
        raise No()

    def body(self, st):
        b = cg.flat(st)
        need(len(b) >= 1)
        if len(b) == 1:
            return self.s(b[0])
        return '{ %s }' % ' '.join(self.s(x) for x in b)

    def function(self):
        f = self.f
        sig = '%s(%s)' % (tn(f.ret), ','.join(tn(p.ty) for p in f.params))
        return sig + ' { ' + ' '.join(self.s(x) for x in cg.flat(f.body)) + ' }'


def number(text, gty):
    """globals numbered in order of first appearance -> (numbered text, their types, the names in order)"""
    order = []

    def sub(m):
        nm = m.group(1)
        if nm not in order:
            order.append(nm)
        return '$%d' % order.index(nm)
    t = re.sub(r'\$([A-Za-z_]\w*)', sub, text)
    return t, tuple(gty[n] for n in order), order


# ==============================================================================================================
# the probe's grammar, in the notation (loopctr.c: lc_<L><B><P>(void), gen_loopctr.py)
# ==============================================================================================================
BODY = {'E': ['($gia[%0] = ($gi3 + 100));'], 'G': ['($gc2 ^= (8 & $gc));'],
        'T': ['($gia[%0] = ($gi3 + 100));', '($gc2 ^= (8 & $gc));'], 'C': ['$vi(%0);'], 'X': ['($gi2 += $gia[%0]);']}
PRE = '($gd = ((2.5 + $gda[3]) * ($gd2 * $gd2))); '


def probe_types(name):
    return {'gia': 'i[8]', 'gi2': 'i', 'gi3': 'i', 'gc': 'c', 'gc2': 'c', 'gd': 'd', 'gd2': 'd', 'gda': 'd[4]',
            'vi': 'Fv(i)'}


def probe_text(name):
    L, B, P = name.split('_')[1]
    pre = PRE if P == 'F' else ''
    b = BODY[B]

    def blk(x):
        return x[0] if len(x) == 1 else '{ %s }' % ' '.join(x)
    if L == 'D':
        loop = '(%%0 = 7); do %s while ((--%%0 > 0));' % blk(b)
    elif L == 'F':
        loop = 'for ((%%0 = 0); (%%0 < 8) %%0++) %s' % blk(b)
    else:
        loop = '(%%0 = 0); while ((%%0 < 8)) %s' % blk(b + ['%0++;'])
    return 'i() { i %%0; %s%s return $gi3; }' % (pre, loop)


def probe_names():
    return ['lc_%s%s%s' % (L, B, P) for L in 'DFW' for B in 'EGTCX' for P in 'NF']


# ==============================================================================================================
# 2. the predictor (probe symbols)
# ==============================================================================================================
def h(n):
    return '0x%x' % n


def S(n):
    return '(XSP+%s)' % h(n)


class Set:
    def __init__(self, s):
        self.s = s
        self.opt = s.startswith('O3')
        self.xr = s.endswith('Xr')






def body(B, R):
    """the loop body with the counter in register R (cdecl)"""
    e = ['ld BC,%s' % R, 'add BC,BC', 'lda XDE,_gia', 'ld WA,(_gi3)', 'add WA,0x64', 'ld (XDE+BC),WA']
    g = ['ld A,(_gc)', 'and A,0x8', 'xor (_gc2),A']
    return {'E': e, 'G': g, 'T': e + g, 'C': ['push IZ', 'cal _vi', 'inc 0x2,XSP'],
            'X': ['ld WA,%s' % R, 'add WA,WA', 'lda XBC,_gia', 'ld WA,(XBC+WA)', 'add (_gi2),WA']}[B]


# the counter's register (cdecl): the first of BC DE HL the body leaves alone; IZ across the call
COUNTER = {'E': 'HL', 'T': 'HL', 'G': 'BC', 'X': 'DE', 'C': 'IZ'}


def loop_none(L, B):
    R = COUNTER[B]
    b = body(B, R)
    if L == 'D':
        return ['ld %s,0x7' % R, 'L1:'] + b + ['dec 0x1,%s' % R, 'ld WA,%s' % R, 'cp WA,0x0', 'j gt,L1']
    return ['ld %s,0x0' % R, 'cp %s,0x8' % R, 'j ge,L1', 'L2:'] + b + ['inc 0x1,%s' % R, 'cp %s,0x8' % R,
                                                                       'j lt,L2', 'L1:']


def loop_opt(L, B):
    """-O3 -XS: the invariant `gi3 + 100` and `8 & gc` hoisted; an element walked by a pointer (down from gia + 0xe for
    the do loop, compared `j ugt`; up with post-increment for for / while, `j ult`); the counter kept only for G and C
    (`sub R,0x1 / j gt` for the do loop, no test before a for / while loop)"""
    if B == 'C':
        return ['ld IZ,0x7', 'L1:', 'push IZ', 'cal _vi', 'inc 0x2,XSP', 'sub IZ,0x1', 'j gt,L1'] if L == 'D' else \
            ['ld IZ,0x0', 'L1:', 'push IZ', 'cal _vi', 'inc 0x2,XSP', 'inc 0x1,IZ', 'cp IZ,0x8', 'j lt,L1']
    if B == 'G':
        head = ['ld BC,0x%x' % (7 if L == 'D' else 0), 'ld A,(_gc)', 'and A,0x8', 'L1:', 'xor (_gc2),A']
        return head + (['sub BC,0x1', 'j gt,L1'] if L == 'D' else ['inc 0x1,BC', 'cp BC,0x8', 'j lt,L1'])
    if B == 'X':
        if L == 'D':
            return ['lda XWA,_gia + 0xe', 'ld XBC,XWA', 'lda XDE,XWA-0xe', 'L1:', 'ld WA,(XBC)', 'add (_gi2),WA',
                    'dec 0x2,XBC', 'cp XBC,XDE', 'j ugt,L1']
        return ['lda XWA,_gia', 'ld XBC,XWA', 'lda XDE,XWA+0x10', 'L1:', 'ld WA,(XBC+:2)', 'add (_gi2),WA',
                'cp XBC,XDE', 'j ult,L1']
    v = 'DE' if B == 'E' else 'HL'                        # gi3 + 100 (and 8 & gc in E)
    inv = ['ld %s,(_gi3)' % v, 'add %s,0x64' % v] + (['ld E,(_gc)', 'and E,0x8'] if B == 'T' else [])
    g = ['xor (_gc2),E'] if B == 'T' else []
    if L == 'D':
        return inv + ['lda XBC,_gia + 0xe', 'ld XWA,XBC', 'lda XBC,XBC-0xe', 'L1:', 'ld (XWA),%s' % v] + g + \
            ['dec 0x2,XWA', 'cp XWA,XBC', 'j ugt,L1']
    return ['lda XBC,_gia'] + inv + ['ld XWA,XBC', 'lda XBC,XBC+0x10', 'L1:', 'ld (XWA+:2),%s' % v] + g + \
        ['cp XWA,XBC', 'j ult,L1']


# the double statement's two temporaries: the do loop with E, G, C or X puts the product first in the higher slot
HIGH_FIRST = {'DE', 'DG', 'DC', 'DX'}


def prefix(L, B, Z):
    """gd = (2.5 + gda[3]) * (gd2 * gd2) through ._fmul_d / ._fadd_d with two 8-byte frame slots"""
    size = 0x10 if B == 'X' else 0x20
    lo = (0 if B == 'X' else 0x10) + (2 if B == 'C' else 0)      # (push IZ shifts the slots by 2)
    hi = lo + 8
    s1, s2 = (hi, lo) if L + B in HIGH_FIRST else (lo, hi)
    sp = lambda o: 'XSP+0x%x' % o if o else 'XSP'
    args = ['lda XDE,_gd2', 'ld XBC,XDE'] if Z.opt else ['lda XBC,_gd2', 'lda XDE,_gd2']
    return size, ['align 2', 'S1:', 'fdatad 2.50000000000000000000e+000', 'lda XSP,XSP-0x%x' % size] + \
        (['push IZ'] if B == 'C' else []) + args + \
        ['lda XWA,%s' % sp(s1), 'cal ._fmul_d', 'lda XBC,_gda + 0x18', 'lda XDE,S1', 'lda XWA,%s' % sp(s2),
         'cal ._fadd_d', 'lda XBC,%s' % sp(s2), 'lda XDE,%s' % sp(s1), 'lda XWA,_gd', 'cal ._fmul_d']


def predict(name, Z):
    L, B, P = name.split('_')[1]
    loop = loop_opt(L, B) if Z.opt else loop_none(L, B)
    tail = ['ld HL,(_gi3)'] + (['pop IZ'] if B == 'C' else [])
    if P == 'F':
        size, pre = prefix(L, B, Z)
        out = pre + loop + tail + ['lda XSP,XSP+0x%x' % size, 'ret']
    else:
        out = (['push IZ'] if B == 'C' else []) + loop + tail + ['ret']
    if Z.xr:
        out = xr_calls(out)
    return out


def xr_calls(out):
    """-Xr from the cdecl code: an argument goes in WA / XWA instead of on the stack (`pushw m / cal _f / inc 0x2,XSP`
    -> `ld WA,m / cal .f`, `push R` -> `ld WA,R`, nothing when it is already there), every call is `.f`, and a call
    just before the `ret` of a function with no frame is a jump"""
    o = []
    i = 0
    while i < len(out):
        l = out[i]
        if i + 2 < len(out) and out[i + 1].startswith('cal _') and out[i + 2] in ('inc 0x2,XSP', 'inc 0x4,XSP') and \
                (l.startswith('push ') or l.startswith('pushw ')):
            src = l.split(' ', 1)[1]
            dst = 'XWA' if out[i + 2] == 'inc 0x4,XSP' else 'WA'
            need(not src.startswith('X') or dst == 'XWA')
            if src != dst:
                o.append('ld %s,%s' % (dst, src))
            o.append('cal .' + out[i + 1][5:])
            i += 3
            continue
        o.append('cal .' + l[5:] if l.startswith('cal _') else l)
        i += 1
    if len(o) >= 2 and o[-1] == 'ret' and o[-2].startswith('cal .') and \
            not any(l.startswith(('push', 'dec', 'lda XSP')) for l in o):
        o = o[:-2] + ['j ' + o[-2][4:]]
    return o


_INDEX = None


def index():
    global _INDEX
    if _INDEX is None:
        _INDEX = {}
        for nm in probe_names():
            txt, tys, order = number(probe_text(nm), probe_types(nm))
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
# 3. substitution, whole(), --check
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
    Z = Set(s)
    if not Z.xr:
        need(not getattr(f, 'adecl_attr', False))
    c = classify(f, Z.xr)
    need(c is not None)
    name, roles = c
    return fmt(substitute(predict(name, Z), roles))


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return whole_(f, set)
    except No:
        return None
    except Exception:                                     # (an AST shape the classifier did not foresee)
        return None


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/loopctr.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-7-micro-loopctr/out/v423/%s/probes/loopctr.asm'


ONE = False
DEC = False


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
        W = listing.normalise_labels([l for l in want.get(name, []) if 'section' not in l][1:])
        try:
            got = whole_(f, s)
        except No:
            got = None
        fs = fams.setdefault(f.name[:4], [0, 0, 0])
        if got is None:
            dec += 1
            fs[2] += 1
            if DEC and shown < show:
                shown += 1
                print('%-14s W %s' % (f.name, '; '.join(x.replace('\t', ' ').strip() for x in W)))
            continue
        if listing.normalise_labels(got) == W:
            ok += 1
            fs[0] += 1
        else:
            wrong += 1
            fs[1] += 1
            if shown < show and ONE:
                shown += 1
                G = listing.normalise_labels(got)
                j = 0
                while j < min(len(W), len(G)) and W[j] == G[j]:
                    j += 1
                print('%-14s W %s' % (f.name, '; '.join(x.replace('\t', ' ').strip() for x in W)))
                print('%-14s G %s   [@%d]' % ('', '; '.join(x.replace('\t', ' ').strip() for x in G), j))
            elif shown < show:
                shown += 1
                G = listing.normalise_labels(got)
                print('---- %s %s' % (s, f.name))
                for k in range(max(len(W), len(G))):
                    a = W[k].strip() if k < len(W) else ''
                    b = G[k].strip() if k < len(G) else ''
                    print('  %s %-34s | %s' % (' ' if a == b else '*', a.replace('\t', ' '), b.replace('\t', ' ')))
    print('%-7s exact %4d  wrong %4d  declined %4d   %s' % (s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        ONE = '--one' in a
        DEC = '--dec' in a
        for s_ in sets:
            check(s_, show, only)
