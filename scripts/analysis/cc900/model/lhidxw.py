#!/usr/bin/env python3
"""lhidx_ast.py -- the cc900 oracle's code for the functions of probe lhidx.c (corpus/probes/lhidx.c, oracle run
2026-11-12-6-micro-lhidx), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'
    python3 lhidx_ast.py --check SET [--show N] [--one] [--dec] [--only REGEX]   (the model directory on sys.path)

As lhx_ast.py: the function's AST in a canonical notation is matched against the probe's grammar (probe_text), the
code is written for that probe name with the probe's symbols, then the real symbols are substituted.  The rules are
in lhidx-FAMILIES.md.  Nothing is looked up by the function's name.
"""
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
# the probe's grammar, in the notation (lhidx.c: lx_<t>_<op>_<S><shape>(int c), gen_lhidx.py)
# ==============================================================================================================
SL = 'S{0:c,2:l,6:n}'                                          # struct sl { char c; long l; unsigned long n; }
OPS = {'d': '/', 'm': '%', 'x': '*'}
SHAPES = {'GX': ('gV', 'vV', 'vA[I]'), 'XG': ('gV', 'vA[I]', 'vV'), 'XK': ('gV', 'vA[I]', '7'),
          'KX': ('gV', '100', 'vA[I]'), 'MX': ('gV', 'vs.V', 'vA[I]'), 'YX': ('gV', 'vA[@0]', 'wA[I]'),
          'SX': ('gA[3]', 'vV', 'vA[I]'), 'DX': ('gps->V', 'vV', 'vA[I]'), 'EX': ('gA[I]', 'vV', 'wA[I]')}


def probe_types(name):
    t = name.split('_')[1]
    ty = {'gi': 'i', 'vs': SL, 'gps': SL + '*'}
    for p in 'gvw':
        ty[p + t] = t
        ty['%s%sa' % (p, t)] = '%s[8]' % t
    return ty


def probe_text(name):
    _, t, op, k = name.split('_')
    S, sh = k[0], k[1:]
    off = 2 if t == 'l' else 6
    I = {'L': '%0', 'T': '%0', 'C': '@0'}[S]

    def f(x):
        if x in ('7', '100'):
            return x
        x = x.replace('vs.V', 'vs.{%d:%s}' % (off, t)).replace('gps->V', 'gps->{%d:%s}' % (off, t))
        return '$' + x.replace('A', t + 'a').replace('V', t).replace('I', I)
    L, A, B = SHAPES[sh]
    st = '(%s = (%s %s %s));' % (f(L), f(A), OPS[op], f(B))
    if S == 'L':
        return 'v(i) { i %%0; for ((%%0 = 0); (%%0 < 4) %%0++) %s }' % st
    if S == 'T':
        return 'v(i) { i %%0 = $gi; %s }' % st
    return 'v(i) { %s }' % st


def probe_names():
    return ['lx_%s_%s_%s%s' % (t, op, S, sh) for t in 'ln' for op in 'dmx' for S in 'LTC' for sh in SHAPES
            if not (op == 'x' and 'K' in sh)]


# ==============================================================================================================
# 2. the predictor (probe symbols; the slots and the parameter as placeholders until the frame is known)
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




SI, ST, SA, ST2, SM, SE = '{I}', '{TI}', '{A4}', '{T2}', '{M}', '{E}'   # slots: counter, t, 4-byte, index, ...
P_ = '{P}'


def regs_used(lines):
    used = set()
    for l in lines:
        for r in re.findall(r'\b[X]?(WA|BC|DE|HL)\b', l):
            used.add(r)
    return used


def predict(name, Z):
    _, t, op, k = name.split('_')
    S, sh = k[0], k[1:]
    N = dict(t=t, op=op, S=S, sh=sh, x=op == 'x', off=2 if t == 'l' else 6, vv='(_v%s)' % t, va='_v%sa' % t,
             wa='_w%sa' % t, ga='_g%sa' % t, gv='_g' + t, hlp='cal C9H_%sl%s' % ({'d': 'div', 'm': 'rem', 'x': 'mul'}[op],
                                                                               's' if t == 'l' else 'u'))
    if Z.opt and S == 'L':
        body = loop_opt(N)
    else:
        body = straight(N, Z)
    out = frame(body, Z)
    if Z.xr:
        out = param_in_wa(out, PARAM_RX)
        need(not any('@P' in l for l in out))
    return [frame_adjust(l) for l in out]


def frame(body, Z):
    """the slots in the order counter / t, the 4-byte one(s), the scaled index; XIZ saved when used"""
    xiz = any('XIZ' in l for l in body)
    base = 4 if xiz else 0
    off = base
    pos = {}
    for s, w in ((SI, 2), (ST, 2), (SA, 4), (SM, 4), (ST2, 2), (SE, 4)):
        if any(s in l for l in body):
            pos[s] = off
            off += w
    n = off - base
    out = []
    for l in body:
        for s, o in pos.items():
            l = l.replace(s, 'XSP+0x%x' % o)
        l = l.replace(P_, '@P' if Z.xr else 'XSP+0x%x' % (base + n + 4))
        out.append(l)
    return (['dec 0x%x,XSP' % n] if n else []) + (['push XIZ'] if xiz else []) + out + \
        (['pop XIZ'] if xiz else []) + (['inc 0x%x,XSP' % n] if n else []) + ['ret']


def frame_adjust(l):
    m = re.match(r'^(dec|inc) (0x[0-9a-f]+),XSP$', l)
    if m and int(m.group(2), 16) > 8:
        return 'lda XSP,XSP%s%s' % ('-' if m.group(1) == 'dec' else '+', m.group(2))
    return l


def operands(N, opt):
    """the two operand loads once XIZ holds the element's array and T2 the scaled index"""
    sh, x, vv = N['sh'], N['x'], N['vv']
    if sh == 'XG':
        return ['ld WA,(%s)' % ST2, 'ld XWA,(XIZ+WA)', 'ld XBC,%s' % vv] if opt else \
            ['ld XBC,%s' % vv, 'ld WA,(%s)' % ST2, 'ld XWA,(XIZ+WA)']
    if sh == 'XK':
        return ['ld WA,(%s)' % ST2, 'ld XWA,(XIZ+WA)', 'ld XBC,0x7']
    if sh == 'KX':
        return ['ld BC,(%s)' % ST2, '%s XWA,0x64' % ('lda' if opt else 'ld'), 'ld XBC,(XIZ+BC)']
    if sh in ('MX', 'YX'):
        return ['ld WA,(%s)' % ST2, 'ld XWA,(XIZ+WA)', 'ld XBC,(XBC)'] if x else \
            ['ld BC,(%s)' % ST2, 'ld XWA,(XDE)', 'ld XBC,(XIZ+BC)']
    return ['ld BC,(%s)' % ST2, 'ld XWA,%s' % vv, 'ld XBC,(XIZ+BC)'] if opt else \
        ['ld XWA,%s' % vv, 'ld BC,(%s)' % ST2, 'ld XBC,(XIZ+BC)']


def straight(N, Z):
    """the index a for-loop counter in a slot (cdecl), the local t = gi, or the parameter c"""
    S, sh, x, opt, off = N['S'], N['sh'], N['x'], Z.opt, N['off']
    held = x and sh in ('SX', 'DX', 'EX')
    arr = N['wa'] if sh in ('YX', 'EX') else N['va']
    store_t = sh == 'EX' and not held and S == 'T' and not opt  # t needed after the call: its own slot
    src = {'L': '(%s)' % SI, 'C': '(%s)' % P_, 'T': '(%s)' % ST}[S]
    # -O: two elements at c, or the held element destination with one scaled index
    if opt and S == 'C' and sh == 'YX':
        body = idx_from(['ld WA,%s' % src])
        if x:
            return body + ['lda XBC,%s' % N['va'], 'ld WA,(%s)' % ST2, 'lda XBC,XBC+WA', 'lda XIZ,%s' % arr,
                           'ld XWA,(XIZ+WA)', 'ld XBC,(XBC)', N['hlp'], 'ld (%s),XHL' % N['gv']]
        return body + ['lda XWA,%s' % N['va'], 'ld (%s),XWA' % SA, 'lda XIZ,%s' % arr, 'ld XWA,(%s)' % SA,
                       'ld HL,(%s)' % ST2, 'ld XWA,(XWA+HL)', 'ld XBC,(XIZ+HL)', N['hlp'], 'ld (%s),XHL' % N['gv']]
    if opt and held and sh == 'EX':
        first = ['ld WA,(_gi)'] if S == 'T' else ['ld WA,%s' % src]
        return idx_from(first) + ['lda XBC,%s' % N['ga'], 'ld DE,(%s)' % ST2, 'lda XWA,XBC+DE', 'ld (%s),XWA' % SA,
                                  'lda XIZ,%s' % arr, 'ld XWA,%s' % N['vv'], 'ld XBC,(XIZ+DE)', N['hlp'],
                                  'ld XWA,(%s)' % SA, 'ld (XWA),XHL']
    # the part before the index: the other operand's address, the held destination
    pre = []
    if sh == 'MX':
        pre = ['lda %s,_vs + 0x%x' % ('XBC' if x else 'XDE', off)]
    elif sh == 'YX':
        pre = ['ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % N['va'], 'lda %s,XBC+WA' % ('XBC' if x else 'XDE')]
    elif held:
        if sh == 'SX':
            pre = ['lda XWA,%s + 0xc' % N['ga'], 'ld (%s),XWA' % SA]
        elif sh == 'DX':
            pre = ['ld XWA,(_gps)', 'inc 0x%x,XWA' % off, 'ld (%s),XWA' % SA]
        else:
            pre = ['@SRC', 'sla 0x2,WA', 'lda XBC,%s' % N['ga'], 'exts XWA', 'add XWA,XBC', 'ld (%s),XWA' % SA]
    # where the index value comes from
    if S == 'T' and store_t:
        init, first, srcl = ['ld WA,(_gi)', 'ld (%s),WA' % ST], ['ld WA,(%s)' % ST], 'ld WA,(%s)' % ST
    elif S == 'T':
        R = [r for r in ('WA', 'BC', 'DE', 'HL') if r not in regs_used(p for p in pre if p != '@SRC')][0]
        init, first, srcl = ['ld %s,(_gi)' % R], ([] if R == 'WA' else ['@R' + R]), 'ld WA,%s' % R
    else:
        init, first, srcl = [], ['ld WA,%s' % src], 'ld WA,%s' % src
    pre = [srcl if p == '@SRC' else p for p in pre]
    body = init + pre + idx_from(first) + ['lda XIZ,%s' % arr] + operands(N, opt) + [N['hlp']]
    # the store
    if held:
        body += ['ld XWA,(%s)' % SA, 'ld (XWA),XHL']
    elif sh == 'SX':
        body += ['ld (%s + 0xc),XHL' % N['ga']]
    elif sh == 'DX':
        body += ['ld XWA,(_gps)', 'ld (XWA+0x%x),XHL' % off]
    elif sh == 'EX':
        body += ['lda XBC,%s' % N['ga'], 'ld WA,(%s)' % ST2, 'ld (XBC+WA),XHL'] if opt else \
            [srcl, 'sla 0x2,WA', 'lda XBC,%s' % N['ga'], 'ld (XBC+WA),XHL']
    else:
        body += ['ld (%s),XHL' % N['gv']]
    if S == 'L':                                          # cdecl: the counter lives in its slot
        body = ['ldw (%s),0x0' % SI, 'cpw (%s),0x4' % SI, 'j ge,L1', 'L2:'] + body + \
            ['incw 0x1,(%s)' % SI, 'cpw (%s),0x4' % SI, 'j lt,L2', 'L1:']
    return body


def idx_from(first):
    """the index value scaled through the 2-byte slot T2; first: its load into WA, or ['@R<pair>'] when the
    local t already sits in that pair"""
    if first and first[0].startswith('@R'):
        return ['ld (%s),%s' % (ST2, first[0][2:]), 'ld WA,(%s)' % ST2, 'sla 0x2,WA', 'ld (%s),WA' % ST2]
    return first + ['ld (%s),WA' % ST2, 'ld WA,(%s)' % ST2, 'sla 0x2,WA', 'ld (%s),WA' % ST2]


def loop_opt(N):
    """-O3 -XS, the for-loop counter: strength-reduced to a pointer walking the element's array in XIZ, the end
    address in a slot E, compared unsigned"""
    sh, x, off = N['sh'], N['x'], N['off']
    arr = N['wa'] if sh in ('YX', 'EX') else N['va']
    tail = ['inc 0x4,XIZ', 'cp XIZ,(%s)' % SE, 'j ult,L1']
    start = ['lda XWA,%s' % arr, 'ld XIZ,XWA', 'lda XWA,XWA+0x10', 'ld (%s),XWA' % SE]
    if sh == 'EX':                                        # the destination walks too (lhx_ast lxi_opt_loop)
        if not x:
            return ['lda XBC,%s' % arr, 'lda XWA,%s' % N['ga'], 'ld XIZ,XWA', 'ld (%s),XBC' % SM,
                    'lda XWA,XWA+0x10', 'ld (%s),XWA' % SA, 'L1:', 'ld XWA,(%s)' % SM, 'ld XBC,(XWA)',
                    'ld XWA,%s' % N['vv'], N['hlp'], 'ld (XIZ+:4),XHL', 'ld XWA,0x4', 'add (%s),XWA' % SM,
                    'cp XIZ,(%s)' % SA, 'j ult,L1']
        return ['lda XBC,%s' % N['ga'], 'lda XWA,%s' % arr, 'ld XIZ,XWA', 'ld (%s),XBC' % SM, 'lda XWA,XWA+0x10',
                'ld (%s),XWA' % SA, 'L1:', 'ld XBC,(XIZ)', 'ld XWA,%s' % N['vv'], N['hlp'], 'ld XWA,(%s)' % SM,
                'ld (XWA),XHL', 'ld XWA,0x4', 'add (%s),XWA' % SM, 'inc 0x4,XIZ', 'cp XIZ,(%s)' % SA, 'j ult,L1']
    ops = {'GX': ['ld XBC,(XIZ)', 'ld XWA,%s' % N['vv']], 'XG': ['ld XWA,(XIZ)', 'ld XBC,%s' % N['vv']],
           'XK': ['ld XWA,(XIZ)', 'ld XBC,0x7'], 'KX': ['ld XBC,(XIZ)', 'lda XWA,0x64']}
    if sh in ops:
        return start + ['L1:'] + ops[sh] + [N['hlp'], 'ld (%s),XHL' % N['gv']] + tail
    pre = []
    if sh in ('MX', 'YX'):                                # the other operand's address, invariant, in a slot
        pre = ['lda XWA,_vs + 0x%x' % off, 'ld (%s),XWA' % SA] if sh == 'MX' else \
            ['ld WA,(%s)' % P_, 'sla 0x2,WA', 'lda XBC,%s' % N['va'], 'exts XWA', 'add XWA,XBC', 'ld (%s),XWA' % SA]
        ld = ['ld XWA,(XIZ)', 'ld XBC,(%s)' % SA, 'ld XBC,(XBC)'] if x else \
            ['ld XBC,(XIZ)', 'ld XWA,(%s)' % SA, 'ld XWA,(XWA)']
        return pre + start + ['L1:'] + ld + [N['hlp'], 'ld (%s),XHL' % N['gv']] + tail
    # SX, DX: the destination's address in a slot; with / and % the array's base is taken first
    dest = ['lda XWA,%s + 0xc' % N['ga'], 'ld (%s),XWA' % SA] if sh == 'SX' else \
        ['ld XWA,(_gps)', 'ld (%s),XWA' % SA, 'ld XWA,0x%x' % off, 'add (%s),XWA' % SA]
    if x:
        head = dest + start
    else:
        head = ['lda XBC,%s' % arr] + dest + ['ld XIZ,XBC', 'lda XWA,XBC+0x10', 'ld (%s),XWA' % SE]
    return head + ['L1:', 'ld XBC,(XIZ)', 'ld XWA,%s' % N['vv'], N['hlp'], 'ld XWA,(%s)' % SA, 'ld (XWA),XHL'] + tail


# ---------------------------------------------------------------------------------------------- -Xr
# The -Xr code is the cdecl (or -O3 -XS) code with the parameter c arriving in WA (lhx_ast.py's param_in_wa).

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
    loops = [(out.index(m.group(1) + ':'), j) for j, l in enumerate(out)
             for m in [re.match(r'^j \w+,(L\d+)$', l)] if m and m.group(1) + ':' in out[:j]]
    post = [k for k in ks if (cal and k > cal[0]) or any(a < k < b for a, b in loops)]   # (a loop: every pass)
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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/lhidx.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-6-micro-lhidx/out/v423/%s/probes/lhidx.asm'


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
        fs = fams.setdefault(f.name[3], [0, 0, 0])
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
