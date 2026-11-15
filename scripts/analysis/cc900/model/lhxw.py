#!/usr/bin/env python3
"""lhx_ast.py -- the cc900 oracle's code for the functions of probe lhx.c (corpus/probes/lhx.c, oracle run
2026-11-13-2-micro-lhx), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 lhx_ast.py --check SET [--show N] [--only REGEX]     score against the oracle listing (exact / wrong /
                                                                 declined); run with the model directory on sys.path

How it works (lhx-FAMILIES.md beside this file has the rules):
  1. classify(f): the function's AST is written out in a small canonical notation (implicit integral casts dropped,
     every leaf with its type, members as offset:type, parameters and locals by position, globals by name).  The
     probe's grammar (GRAMMAR below, the letters of lhx.c's header) writes every probe function in the same
     notation with the probe's names.  The globals of both are numbered in order of first appearance; the function
     is the probe function whose numbered text and global types are the same.  So every constant, member offset,
     type, parameter list and local is the probe's, and two globals are one object exactly where the probe's are.
     Nothing is looked up by the function's name.
  2. The predictor of the group writes the code for that probe name at the option set, with the probe's symbols.
  3. The probe's symbols are replaced by the real ones (a symbol the substitution does not know declines).
Local labels come out numbered from L1 in order of appearance, as listing.normalise_labels numbers them.
"""
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
        if k == 'return':
            return 'return %s;' % self.e(st.value) if st.value is not None else 'return;'
        raise No()

    def body(self, st):
        b = cg.flat(st)
        need(len(b) == 1)
        return self.s(b[0])

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
# the probe's grammar, in the notation
# ==============================================================================================================
SL = 'S{0:c,2:l,6:n}'                                          # struct sl { char c; long l; unsigned long n; }
OPS = {'d': '/', 'm': '%', 'x': '*'}
ITY = {'c': 'c', 'u': 'b', 'w': 'u'}
INIT = {'c': 'gcc', 'u': 'guc', 'w': 'guu'}


def probe_types(t):
    ty = {'gcc': 'c', 'guc': 'b', 'guu': 'u', 'gi': 'i', 'gs': SL, 'gps': SL + '*'}
    for p in 'gvw':
        ty[p + t] = t
        ty['%s%sa' % (p, t)] = '%s[8]' % t
    ty['gp' + t] = t + '*'
    ty['vv' + t] = 'Fv(%s)' % t
    ty['rr' + t] = 'F%s(%s)' % (t, t)
    return ty


def bop(a, o, b):
    return '(%s %s %s)' % (a, o, b)


def asg(l, r):
    return '(%s = %s);' % (l, r)


def probe_text(name):
    """the probe function `name` in the notation, or None"""
    p = name.split('_')
    g, t = p[0], p[1]
    if g == 'lxi':
        op, (I, O, s) = p[2], p[3]
        o = OPS[op]
        ix = '@0' if O == 'P' else '%0'
        st = {'G': asg('$g' + t, bop('$v' + t, o, '$v%sa[%s]' % (t, ix))),
              'X': asg('$g' + t, bop('$v%sa[%s]' % (t, ix), o, '$v' + t)),
              'E': asg('$g%sa[%s]' % (t, ix), bop('$v' + t, o, '$w%sa[%s]' % (t, ix))),
              'Z': asg('$g%sa[%s]' % (t, ix), bop('$g%sa[%s]' % (t, ix), o, '$v' + t))}[s]
        if O == 'P':
            return 'v(%s) { %s }' % (ITY[I], st)
        if O == 'T':
            return 'v(i) { %s %%0 = $%s; %s }' % (ITY[I], INIT[I], st)
        return 'v(i) { %s %%0; for ((%%0 = 0); (%%0 < 4) %%0++) %s }' % (ITY[I], st)
    if g == 'lxo':
        op, (D, A, B) = p[2], p[3]
        mem = '$gps->{%d:%s}' % (2 if t == 'l' else 6, t)
        opa = {'P': '*$gp' + t, 'D': mem, 'E': '$v%sa[2]' % t, 'X': '$v%sa[@0]' % t}[A]
        opb = {'G': '$w' + t, 'P': '*$gp' + t, 'D': mem, 'K': '7', 'X': '$w%sa[@0]' % t}[B]
        e = bop(opa, OPS[op], opb)
        st = {'G': asg('$g' + t, e), 'P': asg('*$gp' + t, e), 'D': asg(mem, e), 'X': asg('$g%sa[@0]' % t, e),
              'R': 'return %s;' % e, 'A': '$vv%s(%s);' % (t, e), 'Q': 'if (%s) %s' % (e, asg('$gi', '1'))}[D]
        return '%s(i) { %s }' % (t if D == 'R' else 'v', st)
    if g == 'lxm':
        f, D = p[2], p[3]
        v, w, gv = '$v' + t, '$w' + t, '$g' + t
        va, wa = '$v%sa[@0]' % t, '$w%sa[@0]' % t
        mem = '$gps->{%d:%s}' % (2 if t == 'l' else 6, t)
        e = {'a': bop(bop(gv, '%', '3'), '%', '2'), 'b': bop(v, '*', bop(w, '+', gv)), 'c': bop(bop(v, '/', w), '%', '7'),
             'd': bop(bop(v, '*', w), '*', '5'), 'e': bop(bop(va, '%', '3'), '%', '2'), 'f': bop(v, '*', bop(wa, '+', '1')),
             'g': bop(bop(v, '+', w), '/', va), 'h': bop(bop(v, '*', w), '+', bop(v, '/', w)),
             'i': bop('$rr%s(%s)' % (t, v), '%', '3'), 'j': bop(bop(v, '/', '7'), '+', bop(wa, '%', '7')),
             'k': bop('*$gp' + t, '*', bop('$gp%s[1]' % t, '+', '65536')), 'l': bop(bop(mem, '%', '100'), '/', '100'),
             'm': bop(bop(gv, '/', '10'), '/', '10'), 'n': bop(bop(va, '*', '3'), '*', '5'),
             'o': bop(bop(va, '%', '10'), '*', w), 'p': bop('$rr%s(%s)' % (t, v), '*', '$rr%s(%s)' % (t, w))}[f]
        st = {'G': asg(gv, e), 'X': asg('$g%sa[@0]' % t, e), 'P': asg('*$gp' + t, e), 'R': 'return %s;' % e}[D]
        return '%s(i) { %s }' % (t if D == 'R' else 'v', st)
    return None


def probe_names():
    out = []
    for t in 'ln':
        for op in 'dmx':
            for I in 'cuw':
                for O in 'PTL':
                    for s in 'GXEZ':
                        out.append('lxi_%s_%s_%s%s%s' % (t, op, I, O, s))
    for t in 'ln':
        for op in 'dmx':
            for D in 'GPDXRAQ':
                for A in 'PDEX':
                    for B in 'GPDKX':
                        out.append('lxo_%s_%s_%s%s%s' % (t, op, D, A, B))
    for t in 'ln':
        for f in 'abcdefghijklmnop':
            for D in 'GXPR':
                out.append('lxm_%s_%s_%s' % (t, f, D))
    return out


_INDEX = None


def index():
    global _INDEX
    if _INDEX is None:
        _INDEX = {}
        for nm in probe_names():
            t = nm.split('_')[1]
            txt, tys, order = number(probe_text(nm), probe_types(t))
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
# 2. the predictors (probe symbols; '_x' a global, '.f' / '_f' a function)
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


def predict(name, Z):
    g = name.split('_')[0]
    out = {'lxi': predict_lxi, 'lxo': predict_lxo, 'lxm': predict_lxm}[g](name, Z)
    return [frame_adjust(l) for l in out]


def frame_adjust(l):
    """dec / inc take 1..8: a larger frame is `lda XSP,XSP-n` / `lda XSP,XSP+n`"""
    m = re.match(r'^(dec|inc) (0x[0-9a-f]+),XSP$', l)
    if m and int(m.group(2), 16) > 8:
        return 'lda XSP,XSP%s%s' % ('-' if m.group(1) == 'dec' else '+', m.group(2))
    return l


# ---------------------------------------------------------------------------------------------- group 1: lxi
def lxi_names(t, op):
    sfx = 's' if t == 'l' else 'u'
    helper = 'C9H_' + {'d': 'div', 'm': 'rem', 'x': 'mul'}[op] + 'l' + sfx
    return helper, '_v' + t, '_v%sa' % t, '_w%sa' % t, '_g%sa' % t, '_g' + t


def predict_lxi(name, Z):
    """group 1: lxi_<t>_<op>_<I><O><shape>; the cdecl templates of research-scratch lhx1-predict.py with the -Xr
    parameter in A / WA (xrp), lxi_w for the 16-bit index, lxi_opt / lxi_opt_loop under -O3 -XS"""
    m = re.match(r'lxi_([ln])_([dmx])_([cuw])([PTL])([GXEZ])$', name)
    t, op, I, O, shape = m.groups()
    helper, vv, va, wa, ga, gv = lxi_names(t, op)
    gidx = {'c': '_gcc', 'u': '_guc', 'w': '_guu'}[I]
    held = shape == 'Z' or (shape == 'E' and op == 'x')       # the destination address is formed first, kept
    elem_left = shape in 'XZ'
    arr = wa if shape == 'E' else (va if shape in 'GX' else ga)
    if Z.opt:
        if O == 'L':
            return lxi_opt_loop(shape, op, arr, va, wa, ga, vv, gv, helper)
        return lxi_opt(I, O, shape, op, held, elem_left, arr, ga, vv, gv, helper, gidx, Z)
    if I == 'w':
        return lxi_w(O, shape, held, elem_left, arr, ga, vv, gv, helper, Z)
    # 8-bit index (c, u): the scaled index goes to a 2-byte stack temp T, the array base to XIZ
    xrp = Z.xr and O == 'P'                                  # the index arrives in A
    stored_i = O == 'L' or (O == 'T' and shape == 'E' and not held) or (xrp and shape == 'E' and not held)
    reg_i = O == 'T' and held
    slots = {}
    off = 4
    if xrp and stored_i:                                     # -Xr: T first, then the parameter's slot
        slots['T'] = off
        off += 2
        slots['i'] = off
        off += 2
    else:
        if stored_i:
            slots['i'] = off
            off += 2
        if held:
            slots['addr'] = off
            off += 4
        slots['T'] = off
        off += 2
    N = off - 4
    if xrp and stored_i:
        src = S(slots['i'])
    elif xrp:
        src = None                                           # (A itself)
    elif O == 'P':
        src = S(4 + N + 4)
    elif stored_i:
        src = S(slots['i'])
    elif reg_i:
        src = 'E'
    else:
        src = '(%s)' % gidx
    tm = S(slots['T'])

    def lda(s):
        return [] if s is None else ['ld A,%s' % s]

    def scale_to_T(s):
        if I == 'c':
            return lda(s) + ['sla 0x2,A', 'ld %s,A' % tm]
        return lda(s) + ['extz WA', 'ld %s,WA' % tm, 'ld WA,%s' % tm, 'sla 0x2,WA', 'ld %s,WA' % tm]

    def addr_calc():
        a = S(slots['addr'])
        if xrp:                                              # the parameter stays in A: the address goes through C
            if I == 'c':
                return ['ld C,A', 'sla 0x2,C', 'lda XDE,%s' % ga, 'lda XBC,XDE+C', 'ld %s,XBC' % a]
            return ['ld C,A', 'extz BC', 'sla 0x2,BC', 'lda XDE,%s' % ga, 'exts XBC', 'add XBC,XDE', 'ld %s,XBC' % a]
        if I == 'c':
            return lda(src) + ['sla 0x2,A', 'lda XBC,%s' % ga, 'lda XWA,XBC+A', 'ld %s,XWA' % a]
        return lda(src) + ['extz WA', 'sla 0x2,WA', 'lda XBC,%s' % ga, 'exts XWA', 'add XWA,XBC', 'ld %s,XWA' % a]

    def store_e():
        if I == 'c':
            return lda(src) + ['sla 0x2,A', 'lda XBC,%s' % ga, 'ld (XBC+A),XHL']
        return lda(src) + ['extz WA', 'sla 0x2,WA', 'lda XBC,%s' % ga, 'ld (XBC+WA),XHL']
    out = []
    if N:
        out.append('dec %s,XSP' % h(N))
    out.append('push XIZ')
    if O == 'L':
        out += ['ldb %s,0x0' % S(slots['i']), 'cpb %s,0x4' % S(slots['i']), 'j %s,L1' % ('ge' if I == 'c' else 'uge'),
                'L2:']
    if stored_i and O == 'T':
        out += ['ld A,(%s)' % gidx, 'ld %s,A' % S(slots['i'])]
    if xrp and stored_i:
        out += ['ld %s,A' % S(slots['i'])]
    if reg_i:
        out += ['ld E,(%s)' % gidx]
    if held:
        out += addr_calc()
    out += scale_to_T(src)
    r = 'BC' if I == 'u' else 'C'
    ra = 'WA' if I == 'u' else 'A'
    out.append('lda XIZ,%s' % arr)
    if elem_left:
        out += ['ld XBC,(%s)' % vv, 'ld %s,%s' % (ra, tm), 'ld XWA,(XIZ+%s)' % ra]
    else:
        out += ['ld XWA,(%s)' % vv, 'ld %s,%s' % (r, tm), 'ld XBC,(XIZ+%s)' % r]
    out.append('cal ' + helper)
    if held:
        out += ['ld XWA,%s' % S(slots['addr']), 'ld (XWA),XHL']
    elif shape == 'E':
        out += store_e()
    else:
        out.append('ld (%s),XHL' % gv)
    if O == 'L':
        out += ['incb 0x1,%s' % S(slots['i']), 'cpb %s,0x4' % S(slots['i']), 'j %s,L2' % ('lt' if I == 'c' else 'ult'),
                'L1:']
    out.append('pop XIZ')
    if N:
        out.append('inc %s,XSP' % h(N))
    out.append('ret')
    return out


def lxi_w(O, shape, held, elem_left, arr, ga, vv, gv, helper, Z):
    """16-bit index, no options (-Xr: the parameter in WA)"""
    out = []
    xrp = Z.xr and O == 'P'
    first = None                                              # the first use of the index (-Xr P)
    if O == 'P':
        pro = ['push XIZ'] if held else []
        post = ['pop XIZ'] if held else []
        src = S(4 + (4 if held else 0))
        if xrp:
            if held:
                src, first = None, 'BC'
            elif shape == 'E':
                src = 'IZ'
                pro, post = ['push IZ', 'ld IZ,WA'], ['pop IZ']
            else:
                src = None
    elif O == 'T':
        if held:
            src = 'BC'
            pro, post = ['push XIZ', 'ld BC,(_guu)'], ['pop XIZ']
        elif shape == 'E':
            src = 'IZ'
            pro, post = ['push IZ', 'ld IZ,(_guu)'], ['pop IZ']
        else:
            src, pro, post = '(_guu)', [], []
    else:
        src = 'IZ'
        N = 4 if held else 0
        pro = (['dec %s,XSP' % h(N)] if N else []) + ['push IZ', 'ld IZ,0x0', 'cp IZ,0x4', 'j uge,L1', 'L2:']
        post = ['inc 0x1,IZ', 'cp IZ,0x4', 'j ult,L2', 'L1:', 'pop IZ'] + (['inc %s,XSP' % h(N)] if N else [])
    out += pro

    def ldw(s):
        return [] if s is None else ['ld WA,%s' % s]
    if held:
        if O == 'L':
            out += ['ld WA,IZ', 'extz XWA', 'ld XBC,XWA', 'sll 0x2,XBC', 'ld XWA,%s' % ga, 'add XWA,XBC',
                    'ld %s,XWA' % S(2)]
        elif first == 'BC':
            out += ['ld BC,WA', 'extz XBC', 'sll 0x2,XBC', 'ld XIZ,%s' % ga, 'add XIZ,XBC']
        else:
            out += ldw(src) + ['extz XWA', 'sll 0x2,XWA', 'ld XIZ,%s' % ga, 'add XIZ,XWA']
    out += ldw(src) + ['extz XWA', 'sll 0x2,XWA', 'ld XBC,%s' % arr, 'add XBC,XWA']
    if elem_left:
        out += ['ld XWA,(XBC)', 'ld XBC,(%s)' % vv]
    else:
        out += ['ld XWA,(%s)' % vv, 'ld XBC,(XBC)']
    out.append('cal ' + helper)
    if held:
        out += ['ld XWA,%s' % S(2), 'ld (XWA),XHL'] if O == 'L' else ['ld (XIZ),XHL']
    elif shape == 'E':
        out += ldw(src) + ['extz XWA', 'sll 0x2,XWA', 'ld XBC,%s' % ga, 'add XBC,XWA', 'ld (XBC),XHL']
    else:
        out.append('ld (%s),XHL' % gv)
    out += post
    out.append('ret')
    return out


def lxi_opt(I, O, shape, op, held, elem_left, arr, ga, vv, gv, helper, gidx, Z):
    """-O3 -XS, index a parameter (P) or a local copy of a global (T)"""
    xrp = Z.xr and O == 'P'
    out = []
    if I == 'w':
        frame = held or shape == 'E'
        src = None if xrp else ('(_guu)' if O == 'T' else S(4 + (4 if frame else 0)))
        ld = [] if src is None else ['ld WA,%s' % src]
        if frame:
            out.append('push XIZ')
        if shape == 'E' and not held:
            out += ld + ['extz XWA', 'ld XIZ,XWA', 'sll 0x2,XIZ', 'ld XWA,%s' % arr, 'add XWA,XIZ', 'ld XBC,(XWA)',
                         'ld XWA,(%s)' % vv, 'cal ' + helper, 'ld XWA,%s' % ga, 'add XWA,XIZ', 'ld (XWA),XHL']
        elif held:
            out += ld + ['extz XWA', 'sll 0x2,XWA', 'ld XIZ,%s' % ga, 'add XIZ,XWA']
            if shape == 'E':
                out += ['ld XBC,%s' % arr, 'add XBC,XWA', 'ld XBC,(XBC)', 'ld XWA,(%s)' % vv]
            else:
                out += ['ld XWA,(XIZ)', 'ld XBC,(%s)' % vv]
            out += ['cal ' + helper, 'ld (XIZ),XHL']
        else:
            out += ld + ['extz XWA', 'sll 0x2,XWA', 'ld XBC,%s' % arr, 'add XBC,XWA']
            out += ['ld XWA,(XBC)', 'ld XBC,(%s)' % vv] if elem_left else ['ld XBC,(XBC)', 'ld XWA,(%s)' % vv]
            out += ['cal ' + helper, 'ld (%s),XHL' % gv]
        if frame:
            out.append('pop XIZ')
        out.append('ret')
        return out
    # 8-bit index
    if shape == 'Z':                                          # one address for the read and the store, in XIZ
        out.append('push XIZ')
        if I == 'c':
            if xrp:
                out += ['sla 0x2,A', 'ld C,A']
            elif O == 'P':
                out += ['ld C,%s' % S(8), 'sla 0x2,C']
            else:
                out += ['ld A,(%s)' % gidx, 'sla 0x2,A', 'ld C,A']
            out += ['lda XWA,%s' % ga, 'lda XIZ,XWA+C']
        else:
            out += ([] if xrp else ['ld A,%s' % (S(8) if O == 'P' else '(%s)' % gidx)])
            out += ['extz WA', 'sla 0x2,WA', 'lda XBC,%s' % ga, 'lda XIZ,XBC+WA']
        out += ['ld XWA,(XIZ)', 'ld XBC,(%s)' % vv, 'cal ' + helper, 'ld (XIZ),XHL', 'pop XIZ', 'ret']
        return out
    N = 6 if held else 2
    tm = S(8 if held else 4)
    src = [] if xrp else ['ld A,%s' % (S(4 + N + 4) if O == 'P' else '(%s)' % gidx)]
    out += ['dec %s,XSP' % h(N), 'push XIZ'] + src
    if I == 'c':
        out += ['sla 0x2,A', 'ld %s,A' % tm]
    else:
        out += ['extz WA', 'ld %s,WA' % tm, 'ld WA,%s' % tm, 'sla 0x2,WA', 'ld %s,WA' % tm]
    r, ra = ('BC', 'WA') if I == 'u' else ('C', 'A')
    if held:                                                  # E with *: the destination address first, kept
        e = 'DE' if I == 'u' else 'E'
        out += ['lda XBC,%s' % ga, 'ld %s,%s' % (e, tm), 'lda XWA,XBC+%s' % e, 'ld %s,XWA' % S(4),
                'lda XIZ,%s' % arr, 'ld XWA,(%s)' % vv, 'ld XBC,(XIZ+%s)' % e, 'cal ' + helper,
                'ld XWA,%s' % S(4), 'ld (XWA),XHL']
    else:
        out.append('lda XIZ,%s' % arr)
        if elem_left:
            out += ['ld %s,%s' % (ra, tm), 'ld XWA,(XIZ+%s)' % ra, 'ld XBC,(%s)' % vv]
        else:
            out += ['ld %s,%s' % (r, tm), 'ld XWA,(%s)' % vv, 'ld XBC,(XIZ+%s)' % r]
        out.append('cal ' + helper)
        if shape == 'E':
            out += ['lda XBC,%s' % ga, 'ld %s,%s' % (ra, tm), 'ld (XBC+%s),XHL' % ra]
        else:
            out.append('ld (%s),XHL' % gv)
    out += ['pop XIZ', 'inc %s,XSP' % h(N), 'ret']
    return out


def lxi_opt_loop(shape, op, arr, va, wa, ga, vv, gv, helper):
    """-O3 -XS, a for-loop counter 0..3 (any index type): strength-reduced to a walking pointer in XIZ, the end
    address in a frame slot, compared unsigned"""
    end = ['lda XWA,XWA+0x10', 'ld %s,XWA' % S(4)]
    tail = ['cp XIZ,%s' % S(4), 'j ult,L1', 'pop XIZ']
    bump = ['ld XWA,0x4', 'add %s,XWA' % S(8)]
    if shape in 'GX':
        out = ['dec 0x4,XSP', 'push XIZ', 'lda XWA,%s' % va, 'ld XIZ,XWA'] + end + ['L1:']
        out += ['ld XWA,(XIZ)', 'ld XBC,(%s)' % vv] if shape == 'X' else ['ld XBC,(XIZ)', 'ld XWA,(%s)' % vv]
        out += ['cal ' + helper, 'ld (%s),XHL' % gv, 'inc 0x4,XIZ'] + tail + ['inc 0x4,XSP', 'ret']
        return out
    if shape == 'E' and op != 'x':                            # XIZ walks the destination, stored with (XIZ+:4)
        out = ['dec 0x8,XSP', 'push XIZ', 'lda XBC,%s' % wa, 'lda XWA,%s' % ga, 'ld XIZ,XWA', 'ld %s,XBC' % S(8)]
        out += end + ['L1:', 'ld XWA,%s' % S(8), 'ld XBC,(XWA)', 'ld XWA,(%s)' % vv, 'cal ' + helper,
                      'ld (XIZ+:4),XHL'] + bump + tail + ['inc 0x8,XSP', 'ret']
        return out
    if shape == 'E':                                          # *: XIZ walks the operand, the destination in a slot
        out = ['dec 0x8,XSP', 'push XIZ', 'lda XBC,%s' % ga, 'lda XWA,%s' % wa, 'ld XIZ,XWA', 'ld %s,XBC' % S(8)]
        out += end + ['L1:', 'ld XBC,(XIZ)', 'ld XWA,(%s)' % vv]
    else:
        out = ['dec 0x8,XSP', 'push XIZ', 'lda XWA,%s' % ga, 'ld XIZ,XWA', 'ld %s,XWA' % S(8)]
        out += end + ['L1:', 'ld XWA,(XIZ)', 'ld XBC,(%s)' % vv]
    out += ['cal ' + helper, 'ld XWA,%s' % S(8), 'ld (XWA),XHL'] + bump + ['inc 0x4,XIZ'] + tail + ['inc 0x8,XSP', 'ret']
    return out


# ---------------------------------------------------------------------------------------------- group 2: lxo
P_, T4, T2, TS = '{PARAM}', '{T4}', '{T2}', '{TS}'      # placeholders resolved once the frame is known

def low(r):                                   # XWA -> WA
    return r[1:]

def lxo_idx():                                    # scaled index of the parameter, via the 2-byte temp
    return ['ld WA,(%s)' % P_, 'ld (%s),WA' % T2, 'ld WA,(%s)' % T2, 'sla 0x2,WA', 'ld (%s),WA' % T2]

def lxo_operands(s, A, B, x):
    """Evaluation of `A op B`: A in ra, B in rb.  x = multiply: the operands are exchanged
    (ra=XBC, rb=XWA) when B is complex (P D X), and then the two final loads go B first."""
    sw = x and B in 'PDX'
    ra, rb = ('XBC', 'XWA') if sw else ('XWA', 'XBC')
    gp, wv, off, a8 = s['gp'], s['wv'], s['off'], '(%s + 0x8)' % s['vea']
    fin = lambda fa, fb: [fb, fa] if sw else [fa, fb]       # order of the two final loads
    o = []
    if B == 'X':                                            # A's ADDRESS goes in a pointer register
        ptr = ra if sw else 'XDE'
        if A == 'P':   o += ['ld %s,(%s)' % (ptr, gp)]
        elif A == 'D': o += ['ld XWA,(_gps)', 'lda %s,XWA+0x%x' % (ptr, off)]
        elif A == 'E': o += ['lda %s,%s' % (ptr, s['vea'] + ' + 0x8')]
        else:          o += ['ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % s['vea'], 'lda %s,XBC+WA' % ptr]
        o += lxo_idx() + ['lda XIZ,%s' % s['wea'], 'ld %s,(%s)' % (low(rb), T2)]
        o += fin('ld %s,(%s)' % (ra, ptr), 'ld %s,(XIZ+%s)' % (rb, low(rb)))
        return o
    # B in G K P D: A's setup, B's setup, then the finals
    if A == 'P':
        o += ['ld %s,(%s)' % (ra, gp)]
        if B == 'P':   return o + ['ld %s,%s' % (rb, ra), 'ld %s,(%s)' % (ra, ra), 'ld %s,(%s)' % (rb, rb)]
        if B == 'D':   o += ['ld XIZ,(_gps)']
        if B == 'G':   o += ['ld %s,%s' % (rb, wv)]
        fa = 'ld %s,(%s)' % (ra, ra)
    elif A == 'D':
        if B == 'D':   # A's pointer cannot have XIZ: it waits in the 4-byte temp
            o += ['ld XWA,(_gps)', 'ld (%s),XWA' % T4, 'ld XIZ,(_gps)', 'ld %s,(%s)' % (ra, T4)]
            return o + fin('ld %s,(%s+0x%x)' % (ra, ra, off), 'ld %s,(XIZ+0x%x)' % (rb, off))
        o += ['ld XIZ,(_gps)']
        if B == 'G':   o += ['ld %s,%s' % (rb, wv)]
        if B == 'P':   o += ['ld %s,(%s)' % (rb, gp)]
        fa = 'ld %s,(XIZ+0x%x)' % (ra, off)
    elif A == 'E':
        if B == 'G':   o += ['ld %s,%s' % (rb, wv)]
        if B == 'P':   o += ['ld %s,(%s)' % (rb, gp)]
        if B == 'D':   o += ['ld XIZ,(_gps)']
        fa = 'ld %s,%s' % (ra, a8)
    else:              # A = X
        o += lxo_idx()
        if B == 'D':
            o += ['lda XWA,%s' % s['vea'], 'ld (%s),XWA' % T4, 'ld XIZ,(_gps)', 'ld %s,(%s)' % (ra, T4),
                  'ld DE,(%s)' % T2]
            return o + fin('ld %s,(%s+DE)' % (ra, ra), 'ld %s,(XIZ+0x%x)' % (rb, off))
        o += ['lda XIZ,%s' % s['vea']]
        if B == 'G':   o += ['ld %s,%s' % (rb, wv)]
        if B == 'P':   o += ['ld %s,(%s)' % (rb, gp)]
        o += ['ld %s,(%s)' % (low(ra), T2)]
        fa = 'ld %s,(XIZ+%s)' % (ra, low(ra))
    if B == 'K':
        return o + [fa, 'ld %s,0x7' % rb]
    if B == 'G':
        return o + [fa]
    fb = 'ld %s,(%s)' % (rb, rb) if B == 'P' else 'ld %s,(XIZ+0x%x)' % (rb, off)
    return o + fin(fa, fb)

def lxo_dest(s, D, A, B):
    """(pre, post): destination address set up before the operands when B is simple (G K),
    otherwise rebuilt after the call.  XIZ keeps it unless A needs XIZ (then a 4-byte temp)."""
    gp, off, gea = s['gp'], s['off'], s['gea']
    if D == 'G': return [], ['ld (%s),XHL' % s['gv']]
    if D == 'R': return [], []
    if D == 'A': return [], ['push XHL', 'cal %s' % s['vv'], 'inc 0x4,XSP']
    if D == 'Q': return [], ['or XHL,XHL', 'JEQ', 'ldw (_gi),0x1', 'L1:']
    scal = ['ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % gea]
    if B in 'PDX':
        return [], {'P': ['ld XWA,(%s)' % gp, 'ld (XWA),XHL'],
                    'D': ['ld XWA,(_gps)', 'ld (XWA+0x%x),XHL' % off],
                    'X': scal + ['ld (XBC+WA),XHL']}[D]
    kept = A in 'PE'                      # XIZ is free for the destination
    if D == 'P':
        if A == 'P': return ['CSE'], ['ld (XIZ),XHL']
        if A == 'E': return ['ld XIZ,(%s)' % gp], ['ld (XIZ),XHL']
        return ['ld XWA,(%s)' % gp, 'ld (%s),XWA' % T4], ['ld XWA,(%s)' % T4, 'ld (XWA),XHL']
    if D == 'D':
        if A == 'P': return ['ld XWA,(_gps)', 'lda XIZ,XWA+0x%x' % off], ['ld (XIZ),XHL']
        if A == 'E': return ['ld XIZ,(_gps)'], ['ld (XIZ+0x%x),XHL' % off]
        return ['ld XWA,(_gps)', 'inc 0x%x,XWA' % off, 'ld (%s),XWA' % T4], ['ld XWA,(%s)' % T4, 'ld (XWA),XHL']
    # D == 'X'
    if A == 'P': return scal + ['lda XIZ,XBC+WA'], ['ld (XIZ),XHL']
    if A == 'E': return lxo_idx() + ['lda XIZ,%s' % gea], ['ld WA,(%s)' % T2, 'ld (XIZ+WA),XHL']
    return scal + ['exts XWA', 'add XWA,XBC', 'ld (%s),XWA' % T4], ['ld XWA,(%s)' % T4, 'ld (XWA),XHL']

def lxo_xk(s, D, A):
    """Multiplication by the constant 7 is inline (x*8-x): no helper call, no XIZ, no frame.
    Registers: V holds the operand, O the product; the destination address uses others."""
    gp, off, gea = s['gp'], s['off'], s['gea']
    sh = 'sla' if s['t'] == 'l' else 'sll'
    def load(v, ptr):                     # A into v; ptr = scratch pointer register
        if A == 'P': return ['ld %s,(%s)' % (ptr, gp), 'ld %s,(%s)' % (v, ptr)]
        if A == 'D': return ['ld %s,(_gps)' % ptr, 'ld %s,(%s+0x%x)' % (v, ptr, off)]
        if A == 'E': return ['ld %s,(%s + 0x8)' % (v, s['vea'])]
    def loadx(v, i, b):                   # A = vea[c], index reg i (16 bit), base reg b
        return ['ld %s,(%s)' % (i, P_), 'sla 0x2,%s' % i, 'lda %s,%s' % (b, s['vea']),
                'ld %s,(%s+%s)' % (v, b, i)]
    def a(v, ptr, i, b):
        return loadx(v, i, b) if A == 'X' else load(v, ptr)
    def mul(v, o):
        return ['ld %s,%s' % (o, v), '%s 0x3,%s' % (sh, o), 'sub %s,%s' % (o, v)]
    if D in 'RAQ':
        o = 'XHL' if D == 'R' else 'XBC'
        body = a('XWA', 'XWA', 'WA', 'XBC') + mul('XWA', o)
        if D == 'A': body += ['push XBC', 'cal %s' % s['vv'], 'inc 0x4,XSP']
        if D == 'Q': body += ['JEQ', 'ldw (_gi),0x1', 'L1:']
        return body
    if D == 'G':
        l = loadx('XBC', 'WA', 'XBC') if A == 'X' else (
            ['ld XWA,(%s)' % gp, 'ld XBC,(XWA)'] if A == 'P' else
            ['ld XWA,(_gps)', 'ld XBC,(XWA+0x%x)' % off] if A == 'D' else ['ld XBC,(%s + 0x8)' % s['vea']])
        return l + mul('XBC', 'XWA') + ['ld (%s),XWA' % s['gv']]
    if D == 'P':
        if A == 'P':                      # same pointer as the destination: reuse XDE
            return ['ld XDE,(%s)' % gp, 'ld XWA,(XDE)'] + mul('XWA', 'XBC') + ['ld (XDE),XBC']
        return ['ld XDE,(%s)' % gp] + a('XWA', 'XWA', 'WA', 'XBC') + mul('XWA', 'XBC') + ['ld (XDE),XBC']
    if D == 'D':
        return (['ld XWA,(_gps)'] + a('XBC', 'XBC', 'BC', 'XDE') + mul('XBC', 'XDE')
                + ['ld (XWA+0x%x),XDE' % off])
    # D == 'X'
    if A == 'X':
        return (['ld DE,(%s)' % P_, 'sla 0x2,DE', 'lda XHL,%s' % gea] + loadx('XWA', 'WA', 'XBC')
                + mul('XWA', 'XBC') + ['ld (XHL+DE),XBC'])
    return (['ld BC,(%s)' % P_, 'sla 0x2,BC', 'lda XDE,%s' % gea] + a('XWA', 'XWA', 'WA', 'XBC')
            + mul('XWA', 'XHL') + ['ld (XDE+BC),XHL'])

HELPER = {('l', 'd'): 'divls', ('l', 'm'): 'remls', ('l', 'x'): 'mulls',
          ('n', 'd'): 'divlu', ('n', 'm'): 'remlu', ('n', 'x'): 'mullu'}

def lxo_opt(s, D, A, B, x):
    """-O3 -XS: `D = A op B` with the operand values, the call ('CALL') and the store.  Differences from the cdecl
    templates: a plain global B is loaded after A; A and B the same object are loaded once (into XBC, copied to
    XWA); a destination P or D that is also an operand keeps its address (XIZ, or the slot TS when XIZ is taken)
    across the call; when both operands want XIZ, B has it and A's pointer or base waits in T4; the scaled index
    of c is computed once (T2) and reused by the store or the other element."""
    sw = x and B in 'PDX'
    ra, rb = ('XBC', 'XWA') if sw else ('XWA', 'XBC')
    gp, off, vea, wea, gea = s['gp'], s['off'], s['vea'], s['wea'], s['gea']
    a8 = '(%s + 0x8)' % vea
    o = []
    # ---- the destination as kept
    def addr_xiz(K):
        return ['ld XIZ,(%s)' % gp] if K == 'P' else ['ld XIZ,(_gps)', 'inc 0x%x,XIZ' % off]

    def addr_slot(K):
        if K == 'P':
            return ['ld XWA,(%s)' % gp, 'ld (%s),XWA' % TS]
        return ['ld XWA,(_gps)', 'ld (%s),XWA' % TS, 'ld XWA,0x%x' % off, 'add (%s),XWA' % TS]

    def rebuilt():
        if D == 'G':
            return ['ld (%s),XHL' % s['gv']]
        if D == 'R':
            return []
        if D == 'A':
            return ['push XHL', 'cal %s' % s['vv'], 'inc 0x4,XSP']
        if D == 'Q':
            return ['or XHL,XHL', 'JEQ', 'ldw (_gi),0x1', 'L1:']
        if D == 'P':
            return ['ld XWA,(%s)' % gp, 'ld (XWA),XHL']
        if D == 'D':
            return ['ld XWA,(_gps)', 'ld (XWA+0x%x),XHL' % off]
        if 'X' in (A, B):                                 # the scaled index is reused
            return ['lda XBC,%s' % gea, 'ld WA,(%s)' % T2, 'ld (XBC+WA),XHL']
        return ['ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % gea, 'ld (XBC+WA),XHL']
    # ---- one object on both sides: loaded once
    if A == B and A in 'PD':
        if D == A:
            return addr_xiz(A) + ['ld XBC,(XIZ)', 'ld XWA,XBC', 'CALL', 'ld (XIZ),XHL']
        mem = '(XWA)' if A == 'P' else '(XWA+0x%x)' % off
        return ['ld XWA,(%s)' % (gp if A == 'P' else '_gps'), 'ld XBC,%s' % mem, 'ld XWA,XBC', 'CALL'] + rebuilt()
    # ---- the destination is one of the operands (P or D)
    if D in 'PD' and D in (A, B):
        if D == A:
            if B in 'GK':
                fb = 'ld %s,%s' % (rb, s['wv'] if B == 'G' else '0x7')
                return addr_xiz(A) + ['ld %s,(XIZ)' % ra, fb, 'CALL', 'ld (XIZ),XHL']
            if B == 'P':                                  # (A = D)
                return addr_xiz(A) + ['ld %s,(%s)' % (rb, gp), 'ld %s,(XIZ)' % ra, 'ld %s,(%s)' % (rb, rb), 'CALL',
                                      'ld (XIZ),XHL']
            st = ['ld XWA,(%s)' % TS, 'ld (XWA),XHL']
            if B == 'D':                                  # (A = P) XIZ is B's: A's pointer in TS
                return addr_slot(A) + ['ld XIZ,(_gps)', 'ld XWA,(%s)' % TS, 'ld %s,(XWA)' % ra,
                                       'ld %s,(XIZ+0x%x)' % (rb, off), 'CALL'] + st
            lb = rb[1:]                                   # B = X
            return addr_slot(A) + lxo_idx() + ['lda XIZ,%s' % wea, 'ld XWA,(%s)' % TS, 'ld %s,(XWA)' % ra,
                                               'ld %s,(%s)' % (lb, T2), 'ld %s,(XIZ+%s)' % (rb, lb), 'CALL'] + st
        # D == B: B keeps XIZ, its value first
        st = ['ld (XIZ),XHL']
        if A == 'E':
            return addr_xiz(B) + ['ld %s,(XIZ)' % rb, 'ld %s,%s' % (ra, a8), 'CALL'] + st
        if A == 'P':                                      # (B = D)
            return ['ld %s,(%s)' % (ra, gp)] + addr_xiz(B) + ['ld %s,(XIZ)' % rb, 'ld %s,(%s)' % (ra, ra), 'CALL'] + st
        if A == 'D':                                      # (B = P)
            return ['ld XWA,(_gps)', 'ld (%s),XWA' % T4] + addr_xiz(B) + \
                ['ld %s,(XIZ)' % rb, 'ld %s,(%s)' % (ra, T4), 'ld %s,(%s+0x%x)' % (ra, ra, off), 'CALL'] + st
        return lxo_idx() + ['lda XWA,%s' % vea, 'ld (%s),XWA' % T4] + addr_xiz(B) + \
            ['ld %s,(XIZ)' % rb, 'ld %s,(%s)' % (ra, T4), 'ld DE,(%s)' % T2, 'ld %s,(%s+DE)' % (ra, ra), 'CALL'] + st
    # ---- two elements at c: the scaled index once
    if A == 'X' and B == 'X':
        if x:
            body = lxo_idx() + ['lda XBC,%s' % vea, 'ld WA,(%s)' % T2, 'lda XBC,XBC+WA', 'lda XIZ,%s' % wea,
                                'ld XWA,(XIZ+WA)', 'ld XBC,(XBC)']
        else:
            body = lxo_idx() + ['lda XWA,%s' % vea, 'ld (%s),XWA' % T4, 'lda XIZ,%s' % wea, 'ld XWA,(%s)' % T4,
                                'ld HL,(%s)' % T2, 'ld XWA,(XWA+HL)', 'ld XBC,(XIZ+HL)']
        return body + ['CALL'] + rebuilt()
    if D == 'X' and A == 'X' and B in 'GK':               # held destination: one scaled index, in DE
        fb = 'ld XBC,%s' % (s['wv'] if B == 'G' else '0x7')
        return lxo_idx() + ['lda XBC,%s' % gea, 'ld DE,(%s)' % T2, 'lda XWA,XBC+DE', 'ld (%s),XWA' % T4,
                            'lda XIZ,%s' % vea, 'ld XWA,(XIZ+DE)', fb, 'CALL', 'ld XWA,(%s)' % T4, 'ld (XWA),XHL']
    # ---- otherwise the cdecl templates, a plain global B loaded last
    pre, post = lxo_dest(s, D, A, B)
    core = lxo_operands(s, A, B, x)
    if pre == ['CSE']:
        pre = []
        core = ['ld XIZ,(%s)' % gp, 'ld XWA,XIZ'] + core[1:]
    if B == 'G':
        g = 'ld %s,%s' % (rb, s['wv'])
        core = [l for l in core if l != g] + [g]
    if D == 'X' and B in 'PDX':
        post = rebuilt()
    return pre + core + ['CALL'] + post


def lxo_rem_self(s, D, A):
    """-O3 -XS folds `x % x` to 0 (A and B one object): no load of the value, no call.  The store of the 0 differs
    by the operand (tabulated): `*p % *p` keeps the destination pointer's load before the 0, `p->m % p->m` after
    it; as a condition `*p % *p` vanishes, `p->m % p->m` tests the 0."""
    gp, off, gea = s['gp'], s['off'], s['gea']
    if D == 'G':
        return ['ld XWA,0x0', 'ld (%s),XWA' % s['gv']]
    if D == 'R':
        return ['ld XHL,0x0']
    if D == 'A':
        return ['ld XWA,0x0', 'push XWA', 'cal %s' % s['vv'], 'inc 0x4,XSP']
    if D == 'Q':
        return [] if A == 'P' else ['ld XWA,0x0', 'or XWA,XWA', 'JEQ', 'ldw (_gi),0x1', 'L1:']
    if D == 'P':
        return (['ld XBC,(%s)' % gp, 'ld XWA,0x0'] if A == 'P' else ['ld XWA,0x0', 'ld XBC,(%s)' % gp]) + \
            ['ld (XBC),XWA']
    if D == 'D':
        if A == 'P':
            return ['ld XBC,(_gps)', 'ld XWA,0x0', 'ld (XBC+0x%x),XWA' % off]
        return ['ld XWA,(_gps)', 'inc 0x%x,XWA' % off, 'ld XBC,0x0', 'ld (XWA),XBC']
    if A == 'P':
        return ['ld BC,(%s)' % P_, 'sla 0x2,BC', 'lda XDE,%s' % gea, 'ld XWA,0x0', 'ld (XDE+BC),XWA']
    return ['ld XDE,0x0', 'ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % gea, 'ld (XBC+WA),XDE']


def lxo_xk_opt(s, D, A):
    """-O3 -XS, `* 7` inline, the destination one of the operands' addresses"""
    sh = 'sla' if s['t'] == 'l' else 'sll'
    if D == 'D':
        return ['ld XBC,(_gps)', 'inc 0x%x,XBC' % s['off'], 'ld XWA,(XBC)', 'ld XDE,XWA', '%s 0x3,XDE' % sh,
                'sub XDE,XWA', 'ld (XBC),XDE']
    return ['ld BC,(%s)' % P_, 'sla 0x2,BC', 'lda XDE,%s' % s['gea'], 'lda XWA,%s' % s['vea'], 'ld XWA,(XWA+BC)',
            'ld XHL,XWA', '%s 0x3,XHL' % sh, 'sub XHL,XWA', 'ld (XDE+BC),XHL']


def predict_lxo_base(name, Z):
    """group 2 at every set: the cdecl templates of research-scratch lhx2-predict.py (rules 1-14, lxo_operands /
    lxo_dest / lxo_xk), the -O3 -XS ones (lxo_opt, lxo_rem_self, lxo_xk_opt), the frame from the slots used.
    Under -Xr the parameter's loads stay as `(@P)` for xr_from_cdecl."""
    name = name.lstrip('_')
    _, t, op, k = name.split('_')
    D, A, B = k
    n = 'l' if t == 'l' else 'n'
    s = dict(t=t, gv='_g' + n, wv='(_w%s)' % n, gp='_gp' + n, vea='_v%sa' % n, wea='_w%sa' % n,
             gea='_g%sa' % n, vv='_vv' + n, off=2 if t == 'l' else 6)
    if Z.opt and op == 'm' and A == B and A in 'PD':
        body = lxo_rem_self(s, D, A)
    elif Z.opt and op == 'x' and B == 'K' and (D, A) in (('D', 'D'), ('X', 'X')):
        body = lxo_xk_opt(s, D, A)
    elif op == 'x' and B == 'K' and D == 'A' and Z.opt and Z.xr:
        # -O3 -XS -Xr: the product of `* 7` passed in XWA is formed there (the G form without its store)
        body = lxo_xk(s, 'G', A)[:-1] + ['push XWA', 'cal %s' % s['vv'], 'inc 0x4,XSP']
    elif op == 'x' and B == 'K':
        body = lxo_xk(s, D, A)
    elif Z.opt:
        body = lxo_opt(s, D, A, B, op == 'x') + ['cal C9H_' + HELPER[(t, op)]]
        body = [('cal C9H_' + HELPER[(t, op)] if l == 'CALL' else l) for l in body[:-1]] \
            if 'CALL' in body else body
    else:
        pre, post = lxo_dest(s, D, A, B)
        core = lxo_operands(s, A, B, op == 'x')
        if pre == ['CSE']:
            pre = []
            core = ['ld XIZ,(%s)' % s['gp'], 'ld XWA,XIZ'] + core[1:]
        body = pre + core + ['cal C9H_' + HELPER[(t, op)]] + post
    # frame
    slots = set(c for c in (T4, T2, TS) if any(c in i for i in body))
    N = (4 if T4 in slots else 0) + (2 if T2 in slots else 0) + (4 if TS in slots else 0)
    xiz = any('XIZ' in i for i in body)
    base = 4 if xiz else 0
    def fix(i):
        i = i.replace(T4, 'XSP+0x%x' % base)
        i = i.replace(T2, 'XSP+0x%x' % (base + (4 if T4 in slots else 0)))
        i = i.replace(TS, 'XSP+0x%x' % (base + (4 if T4 in slots else 0) + (2 if T2 in slots else 0)))
        i = i.replace(P_, '@P' if Z.xr else 'XSP+0x%x' % (base + N + 4))
        return i
    body = [fix(i) for i in body]
    pro = (['dec 0x%x,XSP' % N] if N else []) + (['push XIZ'] if xiz else [])
    epi = (['pop XIZ'] if xiz else []) + (['inc 0x%x,XSP' % N] if N else []) + ['ret']
    out = []
    for i in body:
        if i == 'JEQ':
            out.append('ret eq' if not (xiz or N) else 'j eq,L1')
        else:
            out.append(i)
    # JEQ with ret eq: the epilogue ret follows L1:
    return pro + out + epi


# ---------------------------------------------------------------------------------------------- group 3: lxm
# destination strategies (RULE): how the destination of  D = <expr>  is reached, per body letter
LXM_EARLY = set('abcdfm')   # X/P: the destination address goes into XIZ first (push XIZ), the store is (XIZ)
LXM_HELD = set('elo')      # X/P: the address is computed first and kept in a stack slot (the body uses XIZ itself)
# the others (g h i j k p) compute the address after the body; n has its own register assignment

def predict_lxm_base(name, Z):
    """group 3, the cdecl templates of research-scratch lhx1-predict_lxm.py (also the -O3 -XS code of the forms
    LXM_OPT leaves out, with lda for the constants); -Xr: the parameter's loads stay as `(@P)`"""
    m = re.match(r'_?lxm_([ln])_([a-p])_([GXPR])$', name)
    t, f, D = m.groups()
    u = t == 'n'
    sfx = 'u' if u else 's'
    div, rem, mul = ['C9H_%sl%s' % (k, sfx) for k in ('div', 'rem', 'mul')]
    vv, wv, gv, gp, ga, va, wa = (('_vn', '_wn', '_gn', '_gpn', '_gna', '_vna', '_wna') if u else
                                  ('_vl', '_wl', '_gl', '_gpl', '_gla', '_vla', '_wla'))
    rr = '_rrn' if u else '_rrl'
    sl = 'sll' if u else 'sla'
    if f == 'n': return lxm_body_n(D, t, sl, va, ga, gv, gp, '(@P)' if Z.xr else S(4))
    # ---- frame: saved register, slots (offset from XSP after the push), N
    held = f in LXM_HELD and D in 'XP'
    early = f in LXM_EARLY and D in 'XP'
    slots = {}
    if f in 'abcdfm': saved = 'XIZ' if early else None
    elif f in 'ik': saved = None
    elif f == 'g': saved = 'IZ'
    else: saved = 'XIZ'
    ssz = {'XIZ': 4, 'IZ': 2, None: 0}[saved]
    off = ssz
    if held: slots['addr'] = off; off += 4
    if f == 'e': slots['T'] = off; off += 2
    if f in 'jo': slots['spill'] = off; off += 4; slots['T'] = slots['spill'] + 2   # T overlays the spill's high half
    if f == 'g': slots['tmp'] = off; off += 4
    N = off - ssz
    param = ssz + N + 4
    PP = '(@P)' if Z.xr else S(param)
    out = []
    if N: out.append('dec %s,XSP' % h(N))
    if saved: out.append('push ' + saved)
    # destination set-up
    if early:
        if D == 'X': out += ['ld WA,%s' % PP, 'sla 0x2,WA', 'lda XBC,%s' % ga, 'lda XIZ,XBC+WA']
        else: out.append('ld XIZ,(%s)' % gp)
    if held:
        if D == 'X': out += ['ld WA,%s' % PP, 'sla 0x2,WA', 'lda XBC,%s' % ga, 'exts XWA', 'add XWA,XBC', 'ld %s,XWA' % S(slots['addr'])]
        else: out += ['ld XWA,(%s)' % gp, 'ld %s,XWA' % S(slots['addr'])]
    # body
    def arr_index(base):          # int parameter c scaled in the slot T, array base in XIZ
        T = S(slots['T'])
        return ['ld WA,%s' % PP, 'ld %s,WA' % T, 'ld WA,%s' % T, 'sla 0x2,WA', 'ld %s,WA' % T,
                'lda XIZ,%s' % base, 'ld WA,%s' % T, 'ld XWA,(XIZ+WA)']
    res = 'XHL'
    if f == 'a':
        out += ['ld XWA,(%s)' % gv, 'ld XBC,0x3', 'cal ' + rem]
        out += ['and XHL,0x1'] if u else ['ld XWA,XHL', 'ld XBC,0x2', 'cal ' + rem]
    elif f == 'b':
        out += ['ld XWA,(%s)' % wv, 'add XWA,(%s)' % gv, 'ld XBC,(%s)' % vv, 'cal ' + mul]
    elif f == 'c':
        out += ['ld XWA,(%s)' % vv, 'ld XBC,(%s)' % wv, 'cal ' + div, 'ld XWA,XHL', 'ld XBC,0x7', 'cal ' + rem]
    elif f == 'd':
        # x*5 = (x<<2)+x ; the sum lands in XWA unless it is the return value, which must be in XHL
        out += ['ld XWA,(%s)' % vv, 'ld XBC,(%s)' % wv, 'cal ' + mul, 'ld XWA,XHL']
        if D == 'R': out += ['%s 0x2,XHL' % sl, 'add XHL,XWA']
        else: out += ['%s 0x2,XWA' % sl, 'add XWA,XHL']; res = 'XWA'
    elif f == 'e':
        out += arr_index(va) + ['ld XBC,0x3', 'cal ' + rem]
        out += ['and XHL,0x1'] if u else ['ld XWA,XHL', 'ld XBC,0x2', 'cal ' + rem]
    elif f == 'f':
        out += ['ld WA,%s' % PP, 'sla 0x2,WA', 'lda XBC,%s' % wa, 'ld XWA,(XBC+WA)', 'inc 0x1,XWA', 'ld XBC,(%s)' % vv, 'cal ' + mul]
    elif f == 'g':
        out += ['ld IZ,%s' % PP, 'sla 0x2,IZ', 'lda XWA,%s' % va, 'ld %s,XWA' % S(slots['tmp']),
                'ld XWA,(%s)' % vv, 'add XWA,(%s)' % wv, 'ld XBC,%s' % S(slots['tmp']), 'ld XBC,(XBC+IZ)', 'cal ' + div]
    elif f == 'h':
        out += ['ld XWA,(%s)' % vv, 'ld XBC,(%s)' % wv, 'cal ' + div, 'ld XIZ,XHL',
                'ld XWA,(%s)' % vv, 'ld XBC,(%s)' % wv, 'cal ' + mul, 'add XHL,XIZ']
    elif f == 'i':
        out += ['ld XWA,(%s)' % vv, 'push XWA', 'cal ' + rr, 'inc 0x4,XSP', 'ld XWA,XHL', 'ld XBC,0x3', 'cal ' + rem]
    elif f == 'j':
        out += arr_index(wa) + ['ld XBC,0x7', 'cal ' + rem, 'ld %s,XHL' % S(slots['spill']),
                                'ld XWA,(%s)' % vv, 'ld XBC,0x7', 'cal ' + div, 'add XHL,%s' % S(slots['spill'])]
    elif f == 'k':
        out += ['ld XBC,(%s)' % gp, 'ld XWA,(%s)' % gp, 'ld XWA,(XWA+0x4)', 'add XWA,0x10000', 'ld XBC,(XBC)', 'cal ' + mul]
    elif f == 'l':
        out += ['ld XIZ,(_gps)', 'ld XWA,(XIZ+%s)' % h(6 if u else 2), 'ld XBC,0x64', 'cal ' + rem, 'ld XWA,XHL', 'ld XBC,0x64', 'cal ' + div]
    elif f == 'm':
        out += ['ld XWA,(%s)' % gv, 'ld XBC,0xa', 'cal ' + div, 'ld XWA,XHL', 'ld XBC,0xa', 'cal ' + div]
    elif f == 'o':
        out += arr_index(va) + ['ld XBC,0xa', 'cal ' + rem, 'ld %s,XHL' % S(slots['spill']),
                                'ld XBC,(%s)' % wv, 'ld XWA,%s' % S(slots['spill']), 'cal ' + mul]
    elif f == 'p':
        out += ['ld XWA,(%s)' % wv, 'push XWA', 'cal ' + rr, 'ld XIZ,XHL', 'ld XWA,(%s)' % vv, 'push XWA', 'cal ' + rr,
                'inc 0x8,XSP', 'ld XWA,XHL', 'ld XBC,XIZ', 'cal ' + mul]
    # store
    if D == 'G': out.append('ld (%s),%s' % (gv, res))
    elif D == 'R': pass
    elif early: out.append('ld (XIZ),%s' % res)
    elif held: out += ['ld XWA,%s' % S(slots['addr']), 'ld (XWA),XHL']
    elif D == 'X': out += ['ld WA,%s' % PP, 'sla 0x2,WA', 'lda XBC,%s' % ga, 'ld (XBC+WA),XHL']
    else: out += ['ld XWA,(%s)' % gp, 'ld (XWA),XHL']
    if saved: out.append('pop ' + saved)
    if N: out.append('inc %s,XSP' % h(N))
    out.append('ret')
    return out

def lxm_body_n(D, t, sl, va, ga, gv, gp, P):
    # vla[c]*15: the multiply by 15 is (x<<4)-x; the register holding x and the result vary with the destination
    ld = ['sla 0x2,WA', 'lda XBC,%s' % va]
    if D == 'G':  return ['ld WA,%s' % P] + ld + ['ld XBC,(XBC+WA)', 'ld XWA,XBC', '%s 0x4,XWA' % sl, 'sub XWA,XBC', 'ld (%s),XWA' % gv, 'ret']
    if D == 'R':  return ['ld WA,%s' % P] + ld + ['ld XWA,(XBC+WA)', 'ld XHL,XWA', '%s 0x4,XHL' % sl, 'sub XHL,XWA', 'ret']
    if D == 'P':  return ['ld XDE,(%s)' % gp, 'ld WA,%s' % P] + ld + ['ld XWA,(XBC+WA)', 'ld XBC,XWA', '%s 0x4,XBC' % sl, 'sub XBC,XWA', 'ld (XDE),XBC', 'ret']
    return ['ld DE,%s' % P, 'sla 0x2,DE', 'lda XHL,%s' % ga, 'ld WA,%s' % P] + ld + ['ld XWA,(XBC+WA)', 'ld XBC,XWA', '%s 0x4,XBC' % sl, 'sub XBC,XWA', 'ld (XHL+DE),XBC', 'ret']


# ---------------------------------------------------------------------------------------------- groups 2 and 3 under -Xr
# The -Xr code of groups 2 and 3 is the cdecl (or -O3 -XS) code with the parameter arriving in WA and the calls
# taking their argument in XWA: xr_from_cdecl rewrites the base code (param_in_wa has the rules).

def predict_lxo(name, Z):
    """group 2: lxo_<t>_<op>_<D><A><B>"""
    out = predict_lxo_base(name, Z)
    if Z.xr:
        out = xr_from_cdecl(out)
    return out


PARAM_RX = r'^ld (WA|BC|DE|IZ),\(@P\)$'


def rename(lines, a, b, lo=0, hi=None, oneway=False):
    """swap register pair a and b (all widths) in lines[lo:hi]; oneway: a becomes b, b stays"""
    W = {'WA': ('XWA', 'WA', 'A', 'W'), 'BC': ('XBC', 'BC', 'C', 'B'), 'DE': ('XDE', 'DE', 'E', 'D'),
         'HL': ('XHL', 'HL', 'L', 'H')}
    m = {}
    for x, y in zip(W[a], W[b]):
        m[x] = y
        if not oneway:
            m[y] = x

    def sub(mm):
        return m.get(mm.group(0), mm.group(0))
    hi = len(lines) if hi is None else hi
    return lines[:lo] + [re.sub(r'\b(XWA|XBC|XDE|XHL|WA|BC|DE|HL|A|W|B|C|D|E|H|L)\b', sub, l) if not l.endswith(':')
                         else l for l in lines[lo:hi]] + lines[hi:]


def param_in_wa(out, rx):
    """-Xr: the 16-bit parameter that the cdecl code loads from the stack (`ld R,(XSP+n)`) arrives in WA.
    One load: dropped; a load into another pair swaps that pair with WA everywhere; a temporary held in XWA
    before the load moves to XBC (`lda XBC,XBC+k` -> `inc k,XBC`).  Two loads: the first use, an element address
    `ld WA,P / sla 0x2,WA / lda XBC,base / lda T,XBC+WA`, works on a copy in BC with the base in XDE
    (`lda T,XDE+BC`, or `exts XBC / add XBC,XDE` when T is XBC); the second load is dropped."""
    ks = [i for i, l in enumerate(out) if re.match(rx, l)]
    if not ks:
        return out
    cal = [i for i, l in enumerate(out) if l.startswith('cal ')]
    post = [k for k in ks if cal and k > cal[0]]
    if post:                                              # needed after a call: saved first, reloaded there
        need(all(out[k].startswith('ld WA,') for k in post))
        frame = out[0].startswith(('dec', 'push XIZ', 'push IZ'))
        if frame:
            n = int(out[0].split()[1].split(',')[0], 16) if out[0].startswith('dec') else 0
            body = out[1:] if out[0].startswith('dec') else out
            need(body[0] in ('push XIZ', 'push IZ'))
            save = S((4 if body[0] == 'push XIZ' else 2) + n)
            out = ['dec %s,XSP' % h(n + 2), body[0], 'ld %s,WA' % save] + body[1:]
            out = [('inc %s,XSP' % h(n + 2) if l == 'inc %s,XSP' % h(n) and n else l) for l in out]
            if not n:
                out.insert(len(out) - 1, 'inc 0x2,XSP')
        else:
            save = 'IZ'
            out = ['push IZ', 'ld IZ,WA'] + out[:-1] + ['pop IZ', 'ret']
        return [('ld %s,%s' % (re.match(rx, l).group(1), save) if re.match(rx, l) else l) for l in out]
    if len(ks) == 1:
        k = ks[0]
        r = re.match(rx, out[k]).group(1)
        if r != 'WA':
            if any(re.search(r'\b(XWA|WA|A)\b', l) for l in out[:k]):
                out = rename(out, 'WA', r)
            else:                                         # a copy, WA is the operand register later
                out[k] = 'ld %s,WA' % r
                return out
        elif any(re.search(r'\b(XWA|WA|A)\b', l) for l in out[:k]):
            out = rename(out, 'WA', 'BC', 0, k, oneway=True)
            out = [('inc %s,%s' % (m.group(2), m.group(1)) if m else l)
                   for l, m in ((l, re.match(r'^lda (X\w+),\1\+(0x[0-9a-f]+)$', l)) for l in out)]
        return out[:k] + out[k + 1:]
    need(len(ks) == 2)
    k1, k2 = ks
    need(out[k2].startswith('ld WA,'))
    r1 = re.match(rx, out[k1]).group(1)
    if r1 != 'WA':                                        # the first use in another pair: a copy
        return out[:k1] + ['ld %s,WA' % r1] + out[k1 + 1:k2] + out[k2 + 1:]
    need(out[k1 + 1] == 'sla 0x2,WA')
    m = re.match(r'^lda (XBC),(_\w+)$', out[k1 + 2])
    need(m is not None)
    first = ['ld BC,WA', 'sla 0x2,BC', 'lda XDE,%s' % m.group(2)]
    m2 = re.match(r'^lda (X\w+),XBC\+WA$', out[k1 + 3])
    if m2 is not None:
        tgt = m2.group(1)
        first += ['exts XBC', 'add XBC,XDE'] if tgt == 'XBC' else ['lda %s,XDE+BC' % tgt]
        rest = out[k1 + 4:k2]
    else:                                                 # exts XWA / add XWA,XBC: the address lands in XBC
        need(out[k1 + 3:k1 + 5] == ['exts XWA', 'add XWA,XBC'])
        first += ['exts XBC', 'add XBC,XDE']
        rest = rename(out[k1 + 5:k2], 'WA', 'BC', oneway=True)
    return out[:k1] + first + rest + out[k2 + 1:]


def xr_from_cdecl(out):
    """-Xr from the cdecl code: the parameter arrives in WA; a call argument goes in XWA, a tail call is a jump"""
    o2 = []
    for i, l in enumerate(out):                           # push XWA / cal _rr -> cal .rr (argument in XWA)
        if l is None or (l == 'push XWA' and i + 1 < len(out) and out[i + 1].startswith('cal _rr')):
            continue
        if l.startswith('cal _rr'):
            l = 'cal .' + l[5:]
            if i + 1 < len(out) and out[i + 1] in ('inc 0x4,XSP', 'inc 0x8,XSP'):
                out[i + 1] = None
        if l is not None:
            o2.append(l)
    out = [l for l in o2 if l is not None]
    out = param_in_wa(list(out), PARAM_RX)
    need(not any('@P' in l for l in out))
    for i, l in enumerate(out):
        if l in ('push XHL', 'push XBC', 'push XWA') and out[i + 1].startswith('cal _vv'):
            r = l.split()[1]
            fr = out[0].startswith(('dec', 'push'))
            out[i:i + 3] = ([] if r == 'XWA' else ['ld XWA,%s' % r]) + [('cal ' if fr else 'j ') + '.' + out[i + 1][5:]]
            if not fr:
                out.pop()
            break
    return out


LXM_OPT = {'e': 'X', 'f': 'X', 'g': 'X', 'h': 'GXPR', 'j': 'X', 'k': 'GXPR', 'n': 'X', 'o': 'GXPR'}


def predict_lxm_opt(name, Z):
    """-O3 -XS, the forms whose code differs from the cdecl one beyond the constants (LXM_OPT): v and w loaded
    once for both helpers (h), gpl loaded once (k), the remainder's result kept in a register instead of a spill
    (j, o), the scaled index of c computed once (e, f, g, j, n, o with the element destination)"""
    m = re.match(r'lxm_([ln])_([a-p])_([GXPR])$', name)
    t, f, D = m.groups()
    u = t == 'n'
    sfx = 'u' if u else 's'
    div, rem, mul = ['cal C9H_%sl%s' % (k, sfx) for k in ('div', 'rem', 'mul')]
    vv, wv, gv, gp, ga, va, wa = ['_%s%s%s' % (p, t, q) for p, q in (('v', ''), ('w', ''), ('g', ''), ('gp', ''),
                                                                      ('g', 'a'), ('v', 'a'), ('w', 'a'))]
    sl = 'sll' if u else 'sla'

    def frame(N, saved, body):
        P = '(@P)' if Z.xr else S((4 if saved == 'XIZ' else 2 if saved else 0) + N + 4)
        body = [l.replace('{P}', P) for l in body]
        return ((['dec %s,XSP' % h(N)] if N else []) + (['push ' + saved] if saved else []) + body +
                (['pop ' + saved] if saved else []) + (['inc %s,XSP' % h(N)] if N else []) + ['ret'])

    def idx(T):
        return ['ld WA,{P}', 'ld %s,WA' % T, 'ld WA,%s' % T, 'sla 0x2,WA', 'ld %s,WA' % T]

    def store(res='XHL'):
        return {'G': ['ld (%s),%s' % (gv, res)], 'R': [],
                'X': ['ld WA,{P}', 'sla 0x2,WA', 'lda XBC,%s' % ga, 'ld (XBC+WA),XHL'],
                'P': ['ld XWA,(%s)' % gp, 'ld (XWA),XHL']}[D]
    held = ['lda XBC,%s' % ga, 'ld DE,(XSP+0x8)', 'lda XWA,XBC+DE', 'ld (XSP+0x4),XWA', 'lda XIZ,%s' % va,
            'ld XWA,(XIZ+DE)']
    if f == 'h':
        return frame(8, 'XIZ', ['ld XWA,(%s)' % vv, 'ld (XSP+0x8),XWA', 'ld XIZ,(%s)' % wv, 'ld XWA,(XSP+0x8)',
                                'ld XBC,XIZ', div, 'ld (XSP+0x4),XHL', 'ld XWA,(XSP+0x8)', 'ld XBC,XIZ', mul,
                                'add XHL,(XSP+0x4)'] + store())
    if f == 'k':
        if D == 'P':
            return frame(0, 'XIZ', ['ld XIZ,(%s)' % gp, 'ld XWA,(XIZ+0x4)', 'add XWA,0x10000', 'ld XBC,(XIZ)', mul,
                                    'ld (XIZ),XHL'])
        return frame(0, None, ['ld XBC,(%s)' % gp, 'ld XWA,(XBC+0x4)', 'add XWA,0x10000', 'ld XBC,(XBC)', mul] +
                     store())
    if f == 'o':
        tail = ['lda XBC,0xa', rem, 'ld XWA,XHL', 'ld XBC,(%s)' % wv, mul]
        if D in 'GR':
            return frame(2, 'XIZ', idx('(XSP+0x4)') + ['lda XIZ,%s' % va, 'ld WA,(XSP+0x4)', 'ld XWA,(XIZ+WA)'] +
                         tail + store())
        if D == 'X':
            return frame(6, 'XIZ', idx('(XSP+0x8)') + held + tail + ['ld XWA,(XSP+0x4)', 'ld (XWA),XHL'])
        return frame(6, 'XIZ', ['ld XWA,(%s)' % gp, 'ld (XSP+0x4),XWA'] + idx('(XSP+0x8)') +
                     ['lda XIZ,%s' % va, 'ld WA,(XSP+0x8)', 'ld XWA,(XIZ+WA)'] + tail +
                     ['ld XWA,(XSP+0x4)', 'ld (XWA),XHL'])
    # the element destination gla[c]
    if f == 'e':
        r2 = ['and XHL,0x1'] if u else ['ld XWA,XHL', 'ld XBC,0x2', rem]
        return frame(6, 'XIZ', idx('(XSP+0x8)') + held + ['ld XBC,0x3', rem] + r2 + ['ld XWA,(XSP+0x4)',
                                                                                     'ld (XWA),XHL'])
    if f == 'f':
        return frame(0, 'XIZ', ['ld WA,{P}', 'sla 0x2,WA', 'lda XBC,%s' % ga, 'lda XIZ,XBC+WA', 'lda XBC,%s' % wa,
                                'ld XWA,(XBC+WA)', 'inc 0x1,XWA', 'ld XBC,(%s)' % vv, mul, 'ld (XIZ),XHL'])
    if f == 'g':
        return frame(4, 'IZ', ['ld IZ,{P}', 'sla 0x2,IZ', 'lda XWA,%s' % va, 'ld (XSP+0x2),XWA', 'ld XWA,(%s)' % vv,
                               'add XWA,(%s)' % wv, 'ld XBC,(XSP+0x2)', 'ld XBC,(XBC+IZ)', div, 'lda XWA,%s' % ga,
                               'ld (XWA+IZ),XHL'])
    if f == 'j':
        return frame(2, 'XIZ', idx('(XSP+0x4)') + ['lda XIZ,%s' % wa, 'ld WA,(XSP+0x4)', 'ld XWA,(XIZ+WA)',
                                                   'ld XBC,0x7', rem, 'ld XIZ,XHL', 'ld XWA,(%s)' % vv, 'ld XBC,0x7',
                                                   div, 'add XHL,XIZ', 'lda XBC,%s' % ga, 'ld WA,(XSP+0x4)',
                                                   'ld (XBC+WA),XHL'])
    return frame(0, None, ['ld BC,{P}', 'sla 0x2,BC', 'lda XDE,%s' % ga, 'lda XWA,%s' % va, 'ld XWA,(XWA+BC)',
                           'ld XHL,XWA', '%s 0x4,XHL' % sl, 'sub XHL,XWA', 'ld (XDE+BC),XHL'])


def predict_lxm(name, Z):
    f, D = name.split('_')[2:4]
    if Z.opt and D in LXM_OPT.get(f, ''):
        out = predict_lxm_opt(name, Z)
    else:
        out = predict_lxm_base(name, Z)
    if Z.opt:                                             # -O: a constant above 7 is loaded with lda
        out = [re.sub(r'^ld (X\w\w),(0x[0-9a-f]+)$', lambda m: ('lda ' if int(m.group(2), 16) > 7 else 'ld ') +
                      m.group(1) + ',' + m.group(2), l) for l in out]
    if Z.xr:
        out = xr_from_cdecl(out)
    return out


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


PROBE = 'corpus/probes/lhx.c'                      # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = __import__('os').path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-2-micro-lhx/out/v423/%s/probes/lhx.asm')


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
        fs = fams.setdefault(f.name[:3], [0, 0, 0])
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
