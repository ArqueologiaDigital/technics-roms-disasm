"""stv2_ast.py -- the cc900 oracle's code for the functions of probe stv2.c, at four option sets, from the model's AST.

    whole(f, set) -> the function's listing lines after its label ('\\top\\targs' / '\\top'), or None
    python3 stv2_ast.py --check [SET ...] [--show N] [--rename]          (the model directory on sys.path)

SET: none, O3XS (cdecl, `_name`), Xr, O3XSXr (register arguments, `.name`); f is a function of
frontend.load(probe, [], [], adecl=SET in (Xr, O3XSXr)).  --rename checks a copy of the probe with every global
renamed (zq_*, written beside this file).  The module does not touch sys.path: the caller provides codegen etc.

1. classify(f): the function is written in a canonical notation (implicit integral casts dropped, types spelt,
   members {offset:type}, constants value:type, parameters @0, globals numbered by first appearance); it must
   equal the notation of one of the probe's functions, generated from the letters of the probe's header, with the
   same global types (the whole struct included) -- so every operand kind, constant, offset and type is the
   probe's and two globals are one object exactly where the probe's are.  Anything else is declined (None).  The
   function's name is never read.
2. predict(name, set): the template of the statement's shape (destination D, divisor V) for the option set,
   shared by the types where the code is the same up to the type's globals, member offset, extension and divide
   (exts/divs, extz/div) or helper (C9H_divls/divlu); `%` is derived from `/` (the remainder is the high word Q
   of the dividend pair; the long helpers C9H_reml*) except where its own template is stored (stv-FAMILIES.md).
3. The probe's globals are replaced by the real ones.
"""
HOME_ = __import__('os').path.expanduser('~/')
import os
import re
import sys

import codegen as cg

PROBE_NAME = 'stv2'
RUN = '2026-11-13-13-micro-stv2'


# ==============================================================================================================
# the canonical notation (render.py)
# ==============================================================================================================
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
        if k == 'addr':
            return '&%s' % self.e(n.e)
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


# ==============================================================================================================
# the probes' grammar (probe.py)
# ==============================================================================================================
SV = 'S{0:i,2:u,4:l,8:n}'                               # struct sv { int x; unsigned u; long l; unsigned long n; }
SV2 = 'S{0:i,2:i[8],18:u[8],34:l[8],66:n[8]}'           # struct sv2 { int x; int arr[8]; unsigned u[8]; long l[8]; unsigned long n[8]; }
SVOFF = {'i': 0, 'u': 2, 'l': 4, 'n': 8}
SV2OFF = {'i': 2, 'u': 18, 'l': 34, 'n': 66}
OPS = {'d': '/', 'm': '%'}


def probe_types(probe):
    if probe == 'stv2':
        return {'gp': SV2 + '*'}
    ty = {'gp': SV + '*'}
    for t in 'iuln':
        g = {'i': 'i', 'u': 'u', 'l': 'l', 'n': 'n'}[t]
        ty.update({'g' + g: t, 'h' + g: t, 'g%sa' % g: t + '[8]', 'h%sa' % g: t + '[8]'})
    return ty


def probe_names(probe):
    if probe == 'stv':
        return ['sv_%s_%s_%s%s' % (t, o, D, V) for t in 'iuln' for o in 'dm' for D in 'EPG' for V in 'GAKE']
    return ['sv2_%s_%s_%s%s' % (t, o, D, V) for t in 'iuln' for o in 'dm' for D in 'EP' for V in 'RS']


def probe_text(name):
    m = re.match(r'sv_([iuln])_([dm])_([EPG])([GAKE])$', name)
    if m:
        t, o, D, V = m.groups()
        mem = '$gp->{%d:%s}' % (SVOFF[t], t)
        d = {'E': '$g%sa[@0]' % t, 'P': mem, 'G': '$g' + t}[D]
        q = {'E': d, 'P': mem, 'G': '$h' + t}[D]
        v = {'G': '$h' + t, 'A': '$h%sa[@0]' % t, 'K': '7:i', 'E': '$h%sa[2:i]' % t}[V]
        return 'v(i) { (%s = (%s %s %s)); }' % (d, q, OPS[o], v)
    t, o, D, V = re.match(r'sv2_([iuln])_([dm])_([EP])([RS])$', name).groups()
    el = '$gp->{%d:%s[8]}[@0]' % (SV2OFF[t], t)
    d = {'E': el, 'P': '$gp->{0:i}'}[D]
    v = {'R': '@0', 'S': el}[V]
    return 'v(i) { (%s = (%s %s %s)); }' % (d, el, OPS[o], v)


_INDEX = {}


def index(probe):
    if probe not in _INDEX:
        ix = {}
        pt = probe_types(probe)
        for nm in probe_names(probe):
            txt, tys, order = number(probe_text(nm), pt)
            ix[(txt, tys)] = (nm, order)
        _INDEX[probe] = ix
    return _INDEX[probe]


def classify(f, adecl, probe):
    try:
        r = Render(f, adecl)
        txt, tys, order = number(r.function(), r.gty)
    except No:
        return None
    except (AttributeError, IndexError, KeyError, TypeError, ValueError):
        return None
    hit = index(probe).get((txt, tys))
    if hit is None:
        return None
    nm, porder = hit
    return nm, dict(zip(porder, order))


# ==============================================================================================================
# template text (fill.py)
# ==============================================================================================================
TYPES = {'i': dict(G='gi', H='hi', GA='gia', HA='hia', EXT='exts', DIV='divs', HELP='C9H_divls', HELPM='C9H_remls'),
         'u': dict(G='gu', H='hu', GA='gua', HA='hua', EXT='extz', DIV='div', HELP='C9H_divlu', HELPM='C9H_remlu'),
         'l': dict(G='gl', H='hl', GA='gla', HA='hla', EXT='exts', DIV='divs', HELP='C9H_divls', HELPM='C9H_remls'),
         'n': dict(G='gn', H='hn', GA='gna', HA='hna', EXT='extz', DIV='div', HELP='C9H_divlu', HELPM='C9H_remlu')}
MOFF = {'stv': {'i': 0, 'u': 2, 'l': 4, 'n': 8},               # struct sv { int x; unsigned u; long l; unsigned long n; }
        'stv2': {'i': 2, 'u': 0x12, 'l': 0x22, 'n': 0x42}}    # struct sv2 { int x; int arr[8]; unsigned u[8]; long l[8]; ... }


def abstract(lines, probe, t):
    out = []
    L = [x.strip().replace('\t', ' ') for x in lines]
    T = TYPES[t]
    off = MOFF[probe][t]
    for k, x in enumerate(L):
        for ph in ('GA', 'HA', 'G', 'H'):
            x = re.sub(r'(?<![\w.])_%s(?!\w)' % T[ph], '{%s}' % ph, x)
        for ph in ('HELPM', 'HELP'):
            x = x.replace(T[ph], '{%s}' % ph)
        m = re.match(r'(divs|div) (.*)$', x)
        if m:
            x = '{DIV} ' + m.group(2)
        if re.match(r'(exts|extz) X\w+$', x) and k + 1 < len(L) and re.match(r'(divs|div) ', L[k + 1]):
            x = '{EXT} ' + x.split()[1]
        if off and 'XSP' not in x:
            h = '0x%x' % off
            hi = '0x%x' % (off & 7)
            if off <= 8:
                x = re.sub(r'^inc %s,' % hi, 'inc {OFFI},', x)
            x = re.sub(r'^add (\w+),%s$' % h, r'add \1,{OFF}', x)
            x = re.sub(r'^(ld|lda) (X\w+),%s$' % h, r'{LDK} \2,{OFF}', x)
            x = re.sub(r'\+%s\)' % h, '+{OFF})', x)
            x = re.sub(r'(X\w\w)\+%s$' % h, r'\1+{OFF}', x)
        out.append(x)
    return out


def fill(tpl, probe, t):
    T = dict(TYPES[t])
    off = MOFF[probe][t]
    T['G'], T['H'], T['GA'], T['HA'] = ['_' + T[k] for k in ('G', 'H', 'GA', 'HA')]
    T['OFF'] = '0x%x' % off
    T['OFFI'] = '0x%x' % (off & 7)
    T['LDK'] = 'ld' if off < 8 else 'lda'          # a 32-bit constant 0..7 loads with ld (the short form), 8 up with lda
    out = []
    for x in tpl:
        if '{OFFI}' in x and not 0 < off <= 8:
            return None
        out.append(re.sub(r'\{(\w+)\}', lambda m: T[m.group(1)], x))
    return out


def m_from_d(d, t):
    """the remainder's code from the quotient's: the helper C9H_divl* -> C9H_reml*; after an int divide the
    remainder is the high word Q of the dividend pair -- `ld X,R` after the divide reads `ld X,QR`, and where the
    quotient is used in place (no copy), `ld R,QR` is inserted"""
    if t in 'ln':
        return [x.replace('{HELP}', '{HELPM}') for x in d]
    out = []
    k = 0
    while k < len(d):
        x = d[k]
        out.append(x)
        m = re.match(r'\{DIV\} X(\w+),', x)
        if m:
            r = m.group(1)
            nxt = d[k + 1] if k + 1 < len(d) else ''
            m2 = re.match(r'ld (\w+),%s$' % r, nxt)
            if m2:
                out.append('ld %s,Q%s' % (m2.group(1), r))
                k += 1
            else:
                out.append('ld %s,Q%s' % (r, r))
        k += 1
    return out


# ==============================================================================================================
# the shape templates (tables.py)
# ==============================================================================================================
TPL = {
    ('stv2', 'ER'): [
        ('d', 'i', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; inc {OFFI},WA; ld H,A; ld XBC,(_gp); ld WA,DE; add WA,WA; inc {OFFI},WA; ld L,A; ld XWA,(_gp); ld WA,(XWA+L); {EXT} XWA; {DIV} XWA,DE; ld (XBC+H),WA; ret'),
        ('d', 'u', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld HL,DE; ld WA,(XWA+C); {EXT} XWA; {DIV} XWA,HL; ld HL,WA; ld WA,DE; add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),HL; ret'),
        ('d', 'ln', 'none',
         'dec 0x2,XSP; push XIZ; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld BC,(XSP+0xa); exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),XHL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XS',
         'ld BC,(XSP+0x4); ld WA,BC; add WA,WA; inc {OFFI},WA; ld E,A; ld XWA,(_gp); lda XDE,XWA+E; ld WA,(XDE); {EXT} XWA; {DIV} XWA,BC; ld (XDE),WA; ret'),
        ('d', 'u', 'O3XS',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XBC,XWA+C; ld WA,(XBC); {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('d', 'ln', 'O3XS',
         'push XIZ; ld DE,(XSP+0x8); ld WA,DE; sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XIZ,XWA+C; exts XDE; ld XWA,(XIZ); ld XBC,XDE; cal {HELP}; ld (XIZ),XHL; pop XIZ; ret'),
        ('d', 'i', 'Xr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld H,C; ld XDE,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld L,C; ld XBC,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,WA; ld (XDE+H),BC; ret'),
        ('m', 'i', 'Xr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld H,C; ld XDE,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld L,C; ld XBC,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,WA; ld WA,QBC; ld (XDE+H),WA; ret'),
        ('d', 'u', 'Xr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); ld HL,WA; ld BC,(XBC+E); {EXT} XBC; {DIV} XBC,HL; ld DE,BC; add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),DE; ret'),
        ('d', 'ln', 'Xr',
         'dec 0x4,XSP; push XIZ; ld (XSP+0x6),WA; ld WA,(XSP+0x6); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld BC,(XSP+0x6); exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld WA,(XSP+0x6); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),XHL; pop XIZ; inc 0x4,XSP; ret'),
        ('d', 'i', 'O3XSXr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld E,C; ld XBC,(_gp); lda XDE,XBC+E; ld BC,(XDE); {EXT} XBC; {DIV} XBC,WA; ld (XDE),BC; ret'),
        ('m', 'i', 'O3XSXr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld E,C; ld XBC,(_gp); lda XDE,XBC+E; ld BC,(XDE); {EXT} XBC; {DIV} XBC,WA; ld WA,QBC; ld (XDE),WA; ret'),
        ('d', 'u', 'O3XSXr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); lda XBC,XBC+E; ld DE,WA; ld WA,(XBC); {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('d', 'ln', 'O3XSXr',
         'push XIZ; ld BC,WA; sla 0x2,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); lda XIZ,XBC+E; ld BC,WA; exts XBC; ld XWA,(XIZ); cal {HELP}; ld (XIZ),XHL; pop XIZ; ret'),
    ],
    ('stv2', 'ES'): [
        ('d', 'i', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; inc {OFFI},WA; ld H,A; ld XBC,(_gp); ld WA,DE; add WA,WA; inc {OFFI},WA; ld L,A; ld XWA,(_gp); ld BC,(XBC+H); {EXT} XBC; {DIV} XBC,(XWA+L); ld HL,BC; add DE,DE; ld WA,DE; inc {OFFI},WA; ld C,A; ld XWA,(_gp); ld (XWA+C),HL; ret'),
        ('d', 'u', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld H,A; ld XBC,(_gp); ld WA,DE; add WA,WA; add WA,{OFF}; ld L,A; ld XWA,(_gp); ld BC,(XBC+H); {EXT} XBC; {DIV} XBC,(XWA+L); ld HL,BC; add DE,DE; ld WA,DE; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),HL; ret'),
        ('d', 'ln', 'none',
         'dec 0x2,XSP; push XIZ; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld C,(XSP+0x4); ld XWA,(XDE); ld XBC,(XIZ+C); cal {HELP}; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),XHL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld BC,(XDE); ld WA,BC; {EXT} XWA; {DIV} XWA,BC; ld (XDE),WA; ret'),
        ('m', 'i', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'u', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld BC,(XDE); ld WA,BC; {EXT} XWA; {DIV} XWA,BC; ld (XDE),WA; ret'),
        ('m', 'u', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'ln', 'O3XS',
         'push XIZ; ld WA,(XSP+0x8); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XIZ,XWA+C; ld XBC,(XIZ); ld XWA,XBC; cal {HELP}; ld (XIZ),XHL; pop XIZ; ret'),
        ('m', 'ln', 'O3XS',
         'ld WA,(XSP+0x4); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld XBC,0x0; ld (XWA),XBC; ret'),
        ('d', 'i', 'Xr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld H,C; ld XDE,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld L,C; ld XBC,(_gp); ld DE,(XDE+H); {EXT} XDE; {DIV} XDE,(XBC+L); add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); ld (XWA+C),DE; ret'),
        ('d', 'u', 'Xr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld H,C; ld XDE,(_gp); ld BC,WA; add BC,BC; add BC,{OFF}; ld L,C; ld XBC,(_gp); ld DE,(XDE+H); {EXT} XDE; {DIV} XDE,(XBC+L); add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),DE; ret'),
        ('d', 'ln', 'Xr',
         'dec 0x4,XSP; push XIZ; ld (XSP+0x6),WA; ld WA,(XSP+0x6); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld WA,(XSP+0x6); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld C,(XSP+0x4); ld XWA,(XDE); ld XBC,(XIZ+C); cal {HELP}; ld WA,(XSP+0x6); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld (XWA+C),XHL; pop XIZ; inc 0x4,XSP; ret'),
        ('d', 'i', 'O3XSXr',
         'add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld BC,(XDE); ld WA,BC; {EXT} XWA; {DIV} XWA,BC; ld (XDE),WA; ret'),
        ('m', 'i', 'O3XSXr',
         'add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'u', 'O3XSXr',
         'add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld BC,(XDE); ld WA,BC; {EXT} XWA; {DIV} XWA,BC; ld (XDE),WA; ret'),
        ('m', 'u', 'O3XSXr',
         'add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'ln', 'O3XSXr',
         'push XIZ; sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XIZ,XWA+C; ld XBC,(XIZ); ld XWA,XBC; cal {HELP}; ld (XIZ),XHL; pop XIZ; ret'),
        ('m', 'ln', 'O3XSXr',
         'sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XWA,XWA+C; ld XBC,0x0; ld (XWA),XBC; ret'),
    ],
    ('stv2', 'PR'): [
        ('d', 'i', 'none',
         'ld DE,(XSP+0x4); ld XHL,(_gp); ld WA,DE; add WA,WA; inc {OFFI},WA; ld C,A; ld XWA,(_gp); ld WA,(XWA+C); {EXT} XWA; {DIV} XWA,DE; ld (XHL),WA; ret'),
        ('d', 'u', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); ld WA,(XWA+C); {EXT} XWA; {DIV} XWA,DE; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'ln', 'none',
         'dec 0x2,XSP; push XIZ; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld BC,(XSP+0xa); exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld XWA,(_gp); ld (XWA),HL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XS',
         'ld XBC,(_gp); ld DE,(XSP+0x4); ld WA,DE; add WA,WA; inc {OFFI},WA; ld WA,(XBC+A); {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('d', 'u', 'O3XS',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld XBC,(_gp); ld WA,(XBC+A); {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('d', 'ln', 'O3XS',
         'dec 0x2,XSP; push XIZ; ld BC,(XSP+0xa); ld WA,BC; sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld (XIZ),HL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'Xr',
         'ld XHL,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld E,C; ld XBC,(_gp); ld BC,(XBC+E); {EXT} XBC; {DIV} XBC,WA; ld (XHL),BC; ret'),
        ('m', 'i', 'Xr',
         'ld XHL,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld E,C; ld XBC,(_gp); ld BC,(XBC+E); {EXT} XBC; {DIV} XBC,WA; ld WA,QBC; ld (XHL),WA; ret'),
        ('d', 'u', 'Xr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); ld HL,WA; ld WA,(XBC+E); {EXT} XWA; {DIV} XWA,HL; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'ln', 'Xr',
         'dec 0x2,XSP; push XIZ; ld BC,WA; sla 0x2,BC; add BC,{OFF}; ld (XSP+0x4),C; ld XIZ,(_gp); ld BC,WA; exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld XWA,(_gp); ld (XWA),HL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XSXr',
         'ld XDE,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld BC,(XDE+C); {EXT} XBC; {DIV} XBC,WA; ld (XDE),BC; ret'),
        ('m', 'i', 'O3XSXr',
         'ld XDE,(_gp); ld BC,WA; add BC,BC; inc {OFFI},BC; ld BC,(XDE+C); {EXT} XBC; {DIV} XBC,WA; ld WA,QBC; ld (XDE),WA; ret'),
        ('d', 'u', 'O3XSXr',
         'ld HL,WA; ld BC,HL; add BC,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); ld WA,(XBC+E); {EXT} XWA; {DIV} XWA,HL; ld (XBC),WA; ret'),
        ('d', 'ln', 'O3XSXr',
         'dec 0x2,XSP; push XIZ; ld BC,WA; sla 0x2,BC; add BC,{OFF}; ld (XSP+0x4),C; ld XIZ,(_gp); ld BC,WA; exts XBC; ld A,(XSP+0x4); ld XWA,(XIZ+A); cal {HELP}; ld (XIZ),HL; pop XIZ; inc 0x2,XSP; ret'),
    ],
    ('stv2', 'PS'): [
        ('d', 'i', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; inc {OFFI},WA; ld L,A; ld XBC,(_gp); ld WA,DE; add WA,WA; inc {OFFI},WA; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld XWA,(_gp); ld (XWA),BC; ret'),
        ('m', 'i', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; inc {OFFI},WA; ld L,A; ld XBC,(_gp); ld WA,DE; add WA,WA; inc {OFFI},WA; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld WA,QBC; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'u', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld L,A; ld XBC,(_gp); ld WA,DE; add WA,WA; add WA,{OFF}; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld XWA,(_gp); ld (XWA),BC; ret'),
        ('m', 'u', 'none',
         'ld DE,(XSP+0x4); ld WA,DE; add WA,WA; add WA,{OFF}; ld L,A; ld XBC,(_gp); ld WA,DE; add WA,WA; add WA,{OFF}; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld WA,QBC; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'ln', 'none',
         'dec 0x2,XSP; push XIZ; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld C,A; ld XWA,(_gp); lda XDE,XWA+C; ld WA,(XSP+0xa); sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld C,(XSP+0x4); ld XWA,(XDE); ld XBC,(XIZ+C); cal {HELP}; ld XWA,(_gp); ld (XWA),HL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; inc {OFFI},WA; ld XBC,(_gp); ld DE,(XBC+A); ld WA,DE; {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('m', 'i', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; inc {OFFI},WA; ld XWA,(_gp); ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'u', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; add WA,{OFF}; ld XBC,(_gp); ld DE,(XBC+A); ld WA,DE; {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('m', 'u', 'O3XS',
         'ld WA,(XSP+0x4); add WA,WA; add WA,{OFF}; ld XWA,(_gp); ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'ln', 'O3XS',
         'push XIZ; ld WA,(XSP+0x8); sla 0x2,WA; add WA,{OFF}; ld XIZ,(_gp); ld XBC,(XIZ+A); ld XWA,XBC; cal {HELP}; ld (XIZ),HL; pop XIZ; ret'),
        ('m', 'ln', 'O3XS',
         'ld WA,(XSP+0x4); sla 0x2,WA; add WA,{OFF}; ld XWA,(_gp); ld XBC,0x0; ld (XWA),BC; ret'),
        ('d', 'i', 'Xr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld L,C; ld XBC,(_gp); add WA,WA; inc {OFFI},WA; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld XWA,(_gp); ld (XWA),BC; ret'),
        ('m', 'i', 'Xr',
         'ld BC,WA; add BC,BC; inc {OFFI},BC; ld L,C; ld XBC,(_gp); add WA,WA; inc {OFFI},WA; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld WA,QBC; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'u', 'Xr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld L,C; ld XBC,(_gp); add WA,WA; add WA,{OFF}; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld XWA,(_gp); ld (XWA),BC; ret'),
        ('m', 'u', 'Xr',
         'ld BC,WA; add BC,BC; add BC,{OFF}; ld L,C; ld XBC,(_gp); add WA,WA; add WA,{OFF}; ld E,A; ld XWA,(_gp); ld BC,(XBC+L); {EXT} XBC; {DIV} XBC,(XWA+E); ld WA,QBC; ld XBC,(_gp); ld (XBC),WA; ret'),
        ('d', 'ln', 'Xr',
         'dec 0x2,XSP; push XIZ; ld BC,WA; sla 0x2,BC; add BC,{OFF}; ld E,C; ld XBC,(_gp); lda XDE,XBC+E; sla 0x2,WA; add WA,{OFF}; ld (XSP+0x4),A; ld XIZ,(_gp); ld C,(XSP+0x4); ld XWA,(XDE); ld XBC,(XIZ+C); cal {HELP}; ld XWA,(_gp); ld (XWA),HL; pop XIZ; inc 0x2,XSP; ret'),
        ('d', 'i', 'O3XSXr',
         'add WA,WA; inc {OFFI},WA; ld XBC,(_gp); ld DE,(XBC+A); ld WA,DE; {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('m', 'i', 'O3XSXr',
         'add WA,WA; inc {OFFI},WA; ld XWA,(_gp); ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'u', 'O3XSXr',
         'add WA,WA; add WA,{OFF}; ld XBC,(_gp); ld DE,(XBC+A); ld WA,DE; {EXT} XWA; {DIV} XWA,DE; ld (XBC),WA; ret'),
        ('m', 'u', 'O3XSXr',
         'add WA,WA; add WA,{OFF}; ld XWA,(_gp); ld BC,0x0; ld (XWA),BC; ret'),
        ('d', 'ln', 'O3XSXr',
         'push XIZ; sla 0x2,WA; add WA,{OFF}; ld XIZ,(_gp); ld XBC,(XIZ+A); ld XWA,XBC; cal {HELP}; ld (XIZ),HL; pop XIZ; ret'),
        ('m', 'ln', 'O3XSXr',
         'sla 0x2,WA; add WA,{OFF}; ld XWA,(_gp); ld XBC,0x0; ld (XWA),BC; ret'),
    ],
}


# ==============================================================================================================
# the predictor (pred.py)
# ==============================================================================================================
def predict(name, S):
    m = re.match(r'(sv2?)_([iuln])_([dm])_(..)$', name)
    if m is None:
        return None
    pre, t, op, sh = m.groups()
    probe = 'stv' if pre == 'sv' else 'stv2'
    rows = TPL.get((probe, sh), [])

    def find(o):
        for o2, ts, ss, tpl in rows:
            if o2 == o and t in ts and S in ss.split():
                return tpl.split('; ')
        return None
    tpl = find(op) if op == 'm' else None
    if tpl is None:
        tpl = find('d')
        if tpl is None:
            return None
        if op == 'm':
            tpl = m_from_d(tpl, t)
    return fill(tpl, probe, t)


# ==============================================================================================================
# the driver
# ==============================================================================================================
SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
CORPUS = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/'
PROBE = CORPUS + PROBE_NAME + '.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/' + RUN + '/out/v423/%s/probes/' + PROBE_NAME + '.asm'
_SYM = re.compile(r'(?<![\w.])([_.])([A-Za-z]\w*)')


def _fmt(x):
    x = x.strip()
    if x.endswith(':'):
        return x
    op, _, a = x.partition(' ')
    a = re.sub(r',\s+', ',', a) if re.search(r'\w \+ ', a) else a.replace(' ', '')
    return '\t' + op + ('\t' + a if a else '')


def whole(f, set='none'):
    """the oracle's lines after the label of function f, or None outside the probe's shapes"""
    if set not in SETS:
        return None
    try:
        xr = set.endswith('Xr')
        if not xr and getattr(f, 'adecl_attr', False):
            return None
        c = classify(f, xr, PROBE_NAME)
        if c is None:
            return None
        name, roles = c
        lines = predict(name, set)
        if not lines:
            return None
        out = []
        for x in lines:
            bad = []

            def rep(m):
                r = roles.get(m.group(2))
                if r is None:
                    bad.append(m.group(0))
                    return m.group(0)
                return m.group(1) + r
            y = _SYM.sub(rep, x)
            if bad:
                return None
            out.append(_fmt(y))
        return out
    except Exception:                                  # (an AST shape the classifier did not foresee)
        return None


def renamed_probe(dirpath):
    """a copy of the probe with every global prefixed zq_ (written into dirpath)"""
    import os
    src = open(PROBE, encoding='latin-1').read()
    for n in sorted(probe_types(PROBE_NAME), key=len, reverse=True):
        src = re.sub(r'\b%s\b' % n, 'zq_' + n, src)
    p = os.path.join(dirpath, PROBE_NAME + '_renamed.c')
    open(p, 'w', encoding='latin-1').write(src)
    return p


def check(set_, show=0, rename=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE % set_, encoding='latin-1').read())
    unit = frontend.load(renamed_probe(rename) if rename else PROBE, [], [], adecl=set_.endswith('Xr'))
    ok = wrong = dec = shown = 0
    for f in unit.functions:
        nm = ('.' if set_.endswith('Xr') else '_') + f.name
        wl = want.get(nm, [])
        W = listing.normalise_labels([l for l in wl[wl.index(nm + ':') + 1:] if 'section' not in l]) if wl else []
        if rename:
            W = [re.sub(r'(?<![\w.])([_.])([a-z]\w*)', lambda m: m.group(1) + 'zq_' + m.group(2), l)
                 if not l.startswith('\tcal\tC9H') else l for l in W]
        got = whole(f, set_)
        if got is None:
            dec += 1
            continue
        if listing.normalise_labels(got) == W:
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                for k in range(max(len(W), len(got))):
                    print('  %-34s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d%s' % (set_, ok, wrong, dec, '  (renamed globals)' if rename else ''))
    return ok, wrong, dec


if __name__ == '__main__':
    import os
    a = sys.argv[1:]
    if not a or a[0] != '--check':
        print(__doc__)
        sys.exit(2)
    show = int(a[a.index('--show') + 1]) if '--show' in a else 0
    sets = [x for x in a[1:] if x in SETS] or list(SETS)
    rn = os.path.dirname(os.path.abspath(__file__)) if '--rename' in a else None
    for s in sets:
        check(s, show, rn)
