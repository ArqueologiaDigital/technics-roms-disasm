"""stvx_ast.py -- the cc900 oracle's code for the functions of probe stvx.c, at four option sets, from the model's AST.

    whole(f, set) -> the function's listing lines after its label ('\\top\\targs' / '\\top' / 'L1:'), or None
    python3 stvx_ast.py --check [SET ...] [--show N] [--rename]          (the model directory on sys.path)

SET: none, O3XS (cdecl, `_name`), Xr, O3XSXr (register arguments, `.name`); f is a function of
frontend.load(probe, [], [], adecl=SET in (Xr, O3XSXr)).  --rename checks a copy of the probe with every global
renamed (zq_*, written beside this file).

1. classify(f): the function is written in a canonical notation (implicit integral casts dropped, types spelt,
   members {offset:type}, constants value:type, parameters @0 @1, globals numbered by first appearance); it must
   equal the notation of one of the probe's functions, generated from the letters of the probe's header, with the
   same global types -- so every operand kind, constant, offset and type is the probe's and two globals are one
   object exactly where the probe's are.  Anything else is declined (None).  The function's name is never read.
2. predict(name, set): virtual instructions over named temporaries for `L = V`, coloured to register pairs, then
   the -O peepholes (stvx-FAMILIES.md).
3. The probe's globals are replaced by the real ones.  Local labels come out L1, L2 in order of appearance.
"""
HOME_ = __import__('os').path.expanduser('~/')
import os
import re
import sys

import codegen as cg

PROBE_NAME = 'stvx'
RUN = '2026-11-12-8-micro-stvx'


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
ST = 'S{0:c,2:i,4:l,8:c*,12:i[4]}'      # struct st { char c; int i; long l; char *p; int a[4]; }
OFF = {'c': 0, 'i': 2, 'l': 4}
NAMES = {'c': ('gc', 'hc', 'gca', 'vca', 'gp', 'vp'), 'i': ('gv', 'hv', 'gia', 'via', 'gpi', 'vpi'),
         'l': ('gl', 'hl', 'gla', 'vla', 'gpl', 'vpl')}


def probe_types():
    ty = {'gs': ST, 'vs': ST, 'gps': ST + '*', 'vps': ST + '*'}
    for t, ns in NAMES.items():
        g, h, ga, va, gp, vp = ns
        ty.update({g: t, h: t, ga: t + '[8]', va: t + '[8]', gp: t + '*', vp: t + '*'})
    return ty


def lval(L, t):
    g, h, ga, va, gp, vp = NAMES[t]
    mem = '{%d:%s}' % (OFF[t], t)
    return {'G': '$' + g, 'M': '$gs.' + mem, 'P': '*$' + gp, 'D': '$gps->' + mem, 'E': '$%s[3:i]' % ga,
            'X': '$%s[@1]' % ga, 'Q': '$%s[@1]' % gp}[L]


def rval(V, t, cast):
    g, h, ga, va, gp, vp = NAMES[t]
    mem = '{%d:%s}' % (OFF[t], t)
    k = 'l' if t == 'l' else 'i'
    if not cast:
        return {'D': '($%s - $vps->%s)' % (h, mem), 'P': '(*$%s + $%s)' % (vp, h), 'X': '($%s[@0] | 5:%s)' % (va, k),
                'Y': '($%s ^ $%s[@0])' % (h, va), 'E': '($%s[5:i] & $%s)' % (va, h),
                'S': '($vs.%s >> (@0 & 7:i))' % mem}[V]
    return '(c)' + {'D': '((i)$hc - (i)$vps->{0:c})', 'P': '((i)*$vp + (i)$hc)', 'X': '((i)$vca[@0] | 5:i)',
                    'Y': '((i)$hc ^ (i)$vca[@0])', 'E': '((i)$vca[5:i] & (i)$hc)',
                    'S': '((i)$vs.{0:c} >> (@0 & 7:i))'}[V]


def probe_names(probe):
    if probe == 'stvx':
        return ['sx_%s_%s%s' % (t, L, V) for t in 'ilc' for L in 'GMPDEXQ' for V in 'DPXYES'] + \
            ['sp_%s%s' % (L, V) for L in 'GMD' for V in 'ASD']
    return ['%s_%s_%s%s' % (p, t, L, V) for p in 'icu' for t in 'cil' for L in 'GMPDEXQ' for V in 'DPXYES'
            if not (p == 'i' and t != 'c')]


def probe_text(name):
    m = re.match(r'sx_([ilc])_(.)(.)$', name)
    if m:
        t, L, V = m.groups()
        return 'v(i,i) { (%s = %s); }' % (lval(L, t), rval(V, t, t == 'c'))
    m = re.match(r'sp_(.)(.)$', name)
    if m:
        L, V = m.groups()
        d = {'G': '$gp', 'M': '$gs.{8:c*}', 'D': '$gps->{8:c*}'}[L]
        v = {'A': '&$vca[@0]', 'S': '($vs.{8:c*} + @0)', 'D': '$vps->{8:c*}'}[V]
        return 'v(i,i) { (%s = %s); }' % (d, v)
    p, t, L, V = re.match(r'([icu])_([cil])_(.)(.)$', name).groups()
    sig = {'i': 'v(i,i)', 'c': 'v(c,c)', 'u': 'v(b,b)'}[p]
    return '%s { (%s = %s); }' % (sig, lval(L, t), rval(V, t, False))


_INDEX = {}


def index(probe):
    if probe not in _INDEX:
        ix = {}
        pt = probe_types()
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
# register colouring (ir.py)
# ==============================================================================================================
BYDEG = False
PAIRS = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L', 'IX': 'IXL', 'IY': 'IYL', 'IZ': 'IZL'}
HIGH = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}


class Reg:
    def __init__(self, p):
        self.p = p

    def __format__(self, spec):
        p = self.p
        return {'': p, 'x': 'X' + p, 'b': LOW.get(p, '?'), 'h': HIGH.get(p, '?'), 'q': 'Q' + p}[spec]


class Ins:
    def __init__(self, text, copy=None, when=None):
        self.text, self.copy, self.when = text, copy, when
        self.temps = re.findall(r'\{(\w+)(?::\w+)?\}', text)


def cells(r, w):
    if w == 8:
        return {(r, 'lo')}
    return {(r, 'lo'), (r, 'hi')} | ({(r, 'q')} if w == 32 else set())


class Body:
    def __init__(self):
        self.seq = []
        self.width = {}
        self.early = []
        self.bydeg = BYDEG

    def e(self, text, copy=None, when=None):
        self.seq.append(Ins(text, copy, when))

    def w(self, **kw):
        self.width.update(kw)

    def colour(self, fixed=None, first=(), pref=None, avoid=None, coalesce=True, order=None, live=None,
               nocoalesce=(), params=('p', 'p2', 'p3'), last=()):
        """fixed {temp: pair}; first: temps coloured before the rest; pref {temp: pair or temp};
        avoid {temp: [temps]}; live {temp: (start, end)} overrides; order: explicit order for the rest."""
        fixed = dict(fixed or {})
        pref = dict(pref or {})
        avoid = dict(avoid or {})
        iv = {}
        for i, ins in enumerate(self.seq):
            for n in ins.temps:
                iv.setdefault(n, [i, i])[1] = i
        for n in params:
            if n in iv:
                iv[n][0] = -1
        for n, se in (live or {}).items():
            if n in iv:
                iv[n] = list(se)
        self.iv = iv
        W = lambda n: self.width.get(n, 16)
        reg = {n: r for n, r in fixed.items() if n in iv}

        def busy_for(n, skip=()):
            s, e = iv[n]
            b = set()
            for o, r in reg.items():
                if o == n or o in skip:
                    continue
                s2, e2 = iv[o]
                if s < e2 and s2 < e:
                    b |= cells(r, W(o))
            return b

        def free(n, r, skip=()):
            return not (cells(r, W(n)) & busy_for(n, skip))

        def pick(n):
            if n in reg:
                return
            w = W(n)
            pool = PAIRS[:4] if w == 8 else PAIRS
            av = set()
            for a in avoid.get(n, ()):
                if a in reg:
                    av.add(reg[a])
            want = pref.get(n)
            if want in reg:
                want = reg[want]
            if want in pool and want not in av and free(n, want):
                reg[n] = want
                return
            if coalesce == 'pref' and n not in nocoalesce:      # a copy whose source dies there: the source's pair
                for i, ins in enumerate(self.seq):
                    if ins.copy and ins.copy[0] == n and ins.copy[1] in reg and iv[ins.copy[1]][1] == i:
                        r = reg[ins.copy[1]]
                        if r in pool and r not in av and free(n, r, skip=(ins.copy[1],)):
                            reg[n] = r
                            return
            for p in pool:
                if p not in av and free(n, p):
                    reg[n] = p
                    return
            raise RuntimeError('no register for %s' % n)

        for n in first:
            if n in iv:
                pick(n)
        if coalesce is True:
            for i, ins in enumerate(self.seq):
                if ins.copy:
                    a, b = ins.copy
                    if a in iv and b in iv and a not in reg and b in reg and iv[b][1] == i and a not in nocoalesce:
                        if free(a, reg[b], skip=(b,)):
                            reg[a] = reg[b]
        def deg(n):
            s, e = iv[n]
            return sum(1 for o in iv if o != n and s < iv[o][1] and iv[o][0] < e)

        rest = order if order is not None else sorted((n for n in iv if n not in reg), key=lambda n: (-deg(n), iv[n][0]) if self.bydeg else (n not in self.early, iv[n][0]))
        for n in rest:
            if n in iv and n not in last:
                pick(n)
        for n in sorted(iv, key=lambda n: iv[n][0]):
            if n not in last:
                pick(n)
        for n in last:
            if n in iv:
                pick(n)
        for n in sorted(iv, key=lambda n: iv[n][0]):
            pick(n)
        self.reg = reg
        F = {n: Reg(r) for n, r in reg.items()}
        out = []
        for ins in self.seq:
            if ins.copy and ins.copy[1] in reg and reg.get(ins.copy[0]) == reg[ins.copy[1]]:
                continue
            if ins.when and (reg.get(ins.when[0]) == reg.get(ins.when[1])) != ins.when[2]:
                continue
            out.append(ins.text.format(**F))
        return out


def loop(b, body_fn, call=False):
    """`for (i = 0; i < 4; i++) body`: the counter {ctr} is live over the whole loop and coloured last; temps
    named in `carried` (parameters) are live over the whole loop too"""
    b.e('ld {ctr},0x0')
    b.e('cp {ctr},0x4')
    b.e('ret ge')
    b.e('L1:')
    body_fn()
    b.e('inc 0x1,{ctr}')
    b.e('cp {ctr},0x4')
    b.e('j lt,L1')
    b.e('L2:')
    b.e('ret')
    n = len(b.seq)
    return {'ctr': (-1, n)}


# ==============================================================================================================
# -O peepholes (peep.py)
# ==============================================================================================================
_REG = re.compile(r'(?<![A-Za-z_0-9])(Q?X?(?:WA|BC|DE|HL|IX|IY|IZ)|[AWCBEDLH])(?![A-Za-z_0-9])')
_PAIR = {'A': 'WA', 'W': 'WA', 'C': 'BC', 'B': 'BC', 'E': 'DE', 'D': 'DE', 'L': 'HL', 'H': 'HL'}


def _pair(r):
    return _PAIR[r] if r in _PAIR else r.lstrip('Q').lstrip('X')


def _regs(x):
    p = x.split(None, 1)
    return {_pair(m) for m in _REG.findall(p[1])} if len(p) > 1 else set()


def _dead_after(L, j, r):
    """register r (a name) is not read after line j before being written (straight-line code)"""
    for z in L[j + 1:]:
        if z.endswith(':') or z.startswith('j') or z.startswith('cal'):
            return False
        if z == 'ret':
            return True
        if z.startswith('scc ') and _pair(z.split(',')[1]) == _pair(r):
            return True
        if _pair(r) in _regs(z):
            ops = z.split(None, 1)[1]
            dst = ops.split(',')[0]
            src = ops[len(dst) + 1:]
            if z.startswith(('ld ', 'lda ')) and _pair(dst) == _pair(r) and _pair(r) not in _regs('x ' + src) and \
                    not dst.startswith('('):
                return True
            return False
    return True


def _dst(z):
    p = z.split(None, 1)
    if len(p) < 2:
        return None
    op, ops = p
    if op in ('cp', 'push', 'j', 'cal', 'ret', 'inc', 'dec') or ops.startswith('('):
        if op in ('inc', 'dec') and ',' in ops:
            return ops.split(',')[1]
        return None
    if op == 'scc':
        return ops.split(',')[1]
    if op in ('exts', 'extz', 'sla', 'sll', 'srl', 'sra'):
        return ops.split(',')[-1]
    return ops.split(',')[0]


def _rename(z, a, b):
    """rename register pair a to pair b in instruction z (all widths)"""
    names = {}
    for w in ('', 'X', 'Q'):
        names[w + a] = w + b
    if a in ('WA', 'BC', 'DE', 'HL') and b in ('WA', 'BC', 'DE', 'HL'):
        lo = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}
        hi = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}
        names[lo[a]] = lo[b]
        names[hi[a]] = hi[b]
    return _REG.sub(lambda m: names.get(m.group(1), m.group(1)), z)


def backprop(L):
    """-O: a value computed in R and then only copied to R2 is computed in R2:
    (def R) ... ld R2,R  ->  (def R2) ... , when nothing between touches R2 and R is dead after"""
    L = list(L)
    j = 0
    while j < len(L):
        m = re.match(r'ld (X?(?:WA|BC|DE|HL)|[ACEL]),(X?(?:WA|BC|DE|HL)|[ACEL])$', L[j])
        if m and len(m.group(1)) == len(m.group(2)) and _dead_after(L, j, m.group(2)):
            r2, r = _pair(m.group(1)), _pair(m.group(2))
            k = j - 1
            ok = False
            while k >= 0:
                z = L[k]
                inner = (z.endswith(':') and any(y.startswith('j ') and y.endswith(',' + z[:-1]) for y in L[:k])) or \
                    (z.startswith('j ') and (z.split(',')[-1] + ':') in L[k:j])
                if (not inner and (z.endswith(':') or z.startswith('j'))) or z.startswith('cal') or \
                        _pair(r2) in _regs(z):
                    break
                if inner:
                    k -= 1
                    continue
                d = _dst(z)
                rn = m.group(2)
                if z.endswith('#nb'):
                    break
                srcs = set() if z.startswith('scc') else _regs('x ' + z.split(None, 1)[1][len(d) + 1:])
                lowdef = rn in ('WA', 'BC', 'DE', 'HL') and d == {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}[rn] and \
                    any(y.startswith(('exts ' + rn, 'extz ' + rn)) for y in L[k + 1:j])
                plain_copy = re.match(r'ld \w+,(Q?X?(WA|BC|DE|HL|IX|IY|IZ)|[AWCBEDLH])$', z) is not None
                if d is not None and not plain_copy and (d == rn or (rn[0] == 'X' and d == rn[1:]) or lowdef) \
                        and r not in srcs \
                        and not z.startswith(('add', 'sub', 'or', 'and', 'xor', 'exts', 'extz', 'sla', 'sll', 'inc',
                                              'dec', 'muls')):
                    ok = True
                    break
                k -= 1
            if ok and r2 in ('WA', 'BC', 'DE', 'HL') or (ok and len(m.group(1)) > 1):
                for q in range(k, j):
                    L[q] = _rename(L[q], r, r2)
                del L[j]
                continue
        j += 1
    return L


def unmark(L):
    return [x[:-3].rstrip() if x.endswith('#nb') else x for x in L]


def forward(L):
    """-O: a register loaded from memory and only copied into another register is loaded there directly:
    ld R,(m) ... ld R2,R  ->  ... ld R2,(m), when R is untouched between and dead after (same width)"""
    L = list(L)
    i = 0
    while i < len(L):
        m = re.match(r'ld (A|C|E|L|WA|BC|DE|HL|XWA|XBC|XDE|XHL),(\([^#]*\))( #nb)?$', L[i])
        if m:
            r, mem = m.group(1), m.group(2)
            for j in range(i + 1, len(L)):
                y = L[j]
                m2 = re.match(r'ld (\w+),%s$' % r, y)
                if m2 and len(m2.group(1)) == len(r) and _dead_after(L, j, r):
                    r2 = m2.group(1)
                    if any(_pair(r2) in _regs(z) for z in L[i + 1:j]):
                        L[j] = 'ld %s,%s' % (r2, mem)
                        del L[i]
                        i -= 1
                    else:
                        L[i] = 'ld %s,%s%s' % (r2, mem, ' #nb' if m.group(3) else '')
                        del L[j]
                    break
                if _pair(r) in _regs(y) or y.endswith(':') or y.startswith('j'):
                    break
                if mem != '(XSP+0x4)' and y.startswith('ld (') :
                    break
        i += 1
    return L

SRC = '(XSP+0x4)'


# ==============================================================================================================
# element addresses (elem.py)
# ==============================================================================================================
SRC = '(XSP+0x4)'


def hx(n):
    return '0x%x' % n


def scale_ins(b, s, r, spec=''):
    sp = ':' + spec if spec else ''
    if s == 2:
        b.e('add {%s%s},{%s%s}' % (r, sp, r, sp))
    elif s == 4:
        b.e(('sll 0x2,{%s:x}' % r) if spec == 'x' else 'sla 0x2,{%s%s}' % (r, sp))


def xr_elem(b, s, I, arr, opt=False, zbase=False, kept=True):
    """-Xr: the element arr[p] with the index parameter p pre-coloured; returns the memory operand.
    opt (-O3 -XS -Xr): an unsigned char index is copied before it is extended; zbase: the base is formed early
    (after a leading copy of the parameter) and kept for a second element"""
    k0 = len(b.seq)
    mode = _xr_elem(b, s, I, arr, opt)
    if zbase:
        seq = b.seq[k0:]
        lda = [x for x in seq if x.text.startswith(('lda {B:x}', 'ld {AD:x},_'))]
        if lda:
            x = lda[0]
            if x.text.startswith('ld {AD:x},_'):     # an unsigned index: the base kept, the sum built from a copy
                k = seq.index(x)
                seq[k] = Ins('ld {AD:x},{B:x}', copy=('AD', 'B'))
                x = Ins('lda {B:x},%s' % arr)
                seq.insert(k, x)
            seq.remove(x)
            pos = 1 if kept and I in 'ac' and seq and seq[0].copy and seq[0].copy[1] == 'p' else 0
            seq.insert(pos, x)
            b.seq[k0:] = seq
    return mode


def _xr_elem(b, s, I, arr, opt=False):
    if s == 1:
        if I == 'a':
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p})'
        if I == 'b':
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p:b})'
        if I == 'c':
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.e('extz {IX}')
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{IX})'
        if I == 'd':
            b.e('ld {IX},{p}', copy=('IX', 'p'))
            b.e('extz {IX:x}')
            b.e('ld {AD:x},%s' % arr)
            b.e('add {AD:x},{IX:x}')
            return '({AD:x})'
    if I == 'a':
        b.e('ld {IX},{p}', copy=('IX', 'p'))
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'b':
        b.w(IX=8, Z=8)
        if s == 2:
            b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
            b.e('add {IX:b},{p:b}')
            b.early.append('IX')
        else:
            b.e('ld {Z:b},{p:b}', copy=('Z', 'p'))
            b.e('sla 0x2,{Z:b}')
            b.e('ld {IX:b},{Z:b}', copy=('IX', 'Z'))
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX:b})'
    if I == 'c' and opt:
        b.w(IX=16)
        b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
        b.e('extz {IX}')
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'c':
        b.e('ld {Z},{p}', copy=('Z', 'p'))
        b.e('extz {Z}')
        if s == 4:
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.e('sla 0x2,{IX}')
        else:
            b.e('ld {IX},{Z}', copy=('IX', 'Z'))
            b.e('add {IX},{IX}')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'd':
        b.e('ld {IX},{p}', copy=('IX', 'p'))
        b.e('extz {IX:x}')
        scale_ins(b, s, 'IX', 'x')
        b.e('ld {AD:x},%s' % arr)
        b.e('add {AD:x},{IX:x}')
        return '({AD:x})'
    raise KeyError(I)


def o3_elem(b, s, I, arr, zbase=False, src=SRC, first=None):
    """-O3 -XS, cdecl: the element arr[idx]; idx a parameter in memory (a b c d) or a local `t = gi` (f g h j),
    whose load {T} the caller emitted.  zbase: the base address is also used for another element (Z), so it is
    formed first ({B}) and kept.  Returns the memory operand."""
    first = first if first is not None else []
    if zbase:
        b.e('lda {B:x},%s' % arr)
    lda = (lambda: None) if zbase else (lambda: b.e('lda {B:x},%s' % arr))
    if I == 'L':
        if s == 1:
            lda()
            return '({B:x}+{ctr})'
        b.e('ld {IX},{ctr}', copy=('IX', 'ctr'))
        scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I in 'fghj':
        if I == 'f':
            if s == 1:
                lda()
                return '({B:x}+{T})'
            b.e('ld {IX},{T}', copy=('IX', 'T'))
            scale_ins(b, s, 'IX')
            lda()
            return '({B:x}+{IX})'
        if I == 'g':
            b.w(IX8=8)
            b.e('ld {IX8:b},{T:b}', copy=('IX8', 'T'))
            b.e('extz {IX8}')
            b.w(IX8=16)
            if s > 1:
                scale_ins(b, s, 'IX8')
            lda()
            return '({B:x}+{IX8})'
        if I == 'h':
            if s == 1:
                lda()
                return '({B:x}+{T:b})'
            b.w(Y=8, IX=8)
            b.e('ld {Y:b},{T:b}', copy=('Y', 'T'))
            if s == 2:
                b.e('add {Y:b},{T:b}')
                first.append('Y')
            else:
                b.e('sla 0x2,{Y:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            lda()
            return '({B:x}+{IX:b})'
        raise KeyError(I)
    if I == 'a':
        if s == 1:
            if not zbase:
                b.e('lda {B:x},%s' % arr)
            b.e('ld {IX},%s' % src)
            b.e('extz {IX:x}')
            b.e('add {IX:x},{B:x}')
            return '({IX:x})'
        b.e('ld {IX},%s' % src)
        scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I == 'b':
        if s == 1:
            if not zbase:
                b.e('lda {B:x},%s' % arr)
            b.e('ld {ZX:x},0x0')
            if b.regime == 'F':
                b.w(T8=8)
                b.e('ld {T8:b},%s' % src)
                b.e('ld {ZX:b},{T8:b}')
                first.append('T8')
            else:
                b.e('ld {ZX:b},%s' % src)
                first.append('ZX')
            b.e('add {ZX:x},{B:x}')
            return '({ZX:x})'
        b.w(T8=8, Y=8, IX=8)
        if s == 2:
            b.e('ld {T8:b},%s' % src)
            b.e('ld {Y:b},{T8:b}', copy=('Y', 'T8'))
            b.e('add {Y:b},{T8:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            first.append('Y')
        else:
            b.e('ld {Y:b},%s' % src)
            b.e('sla 0x2,{Y:b}')
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
            first.append('Y')
        lda()
        return '({B:x}+{IX:b})'
    if I == 'c':
        b.w(IX=16, T8=8)
        b.e('ld {T8:b},%s' % src)
        b.e('ld {IX:b},{T8:b}', copy=('IX', 'T8'))
        first.append('T8')
        b.e('extz {IX}')
        if s > 1:
            scale_ins(b, s, 'IX')
        lda()
        return '({B:x}+{IX})'
    if I == 'd':
        b.e('ld {IX},%s' % src)
        b.e('extz {IX:x}')
        scale_ins(b, s, 'IX', 'x')
        if zbase:
            b.e('ld {AD:x},{B:x}', copy=('AD', 'B'))
        else:
            b.e('ld {AD:x},%s' % arr)
        b.e('add {AD:x},{IX:x}')
        return '({AD:x})'
    raise KeyError(I)


def none_elem(b, s, I, arr, src=SRC, first=None):
    """no options, cdecl: arr[idx] with idx an int (a), char (b) or unsigned char (c) parameter in memory"""
    first = first if first is not None else []
    if I == 'a':
        if s == 1:
            b.e('lda {B:x},%s' % arr)
            b.e('ld {IX},%s' % src)
            b.e('extz {IX:x}')
            b.e('add {IX:x},{B:x}')
            return '({IX:x})'
        b.e('ld {IX},%s' % src)
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'b':
        if s == 1:
            b.e('lda {B:x},%s' % arr)
            if getattr(b, 'regime', 'F') == 'F':
                b.w(T8=8)
                b.e('ld {T8:b},%s' % src)
                b.e('ld {ZX:x},0x0')
                b.e('ld {ZX:b},{T8:b}')
                first.append('T8')
            else:
                b.e('ld {ZX:x},0x0')
                b.e('ld {ZX:b},%s' % src)
                first.append('ZX')
            b.e('add {ZX:x},{B:x}')
            return '({ZX:x})'
        b.w(Y=8, IX=8)
        b.e('ld {Y:b},%s' % src)
        if s == 2:
            b.e('add {Y:b},%s' % src)
        else:
            b.e('sla 0x2,{Y:b}')
        b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
        first.append('Y')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX:b})'
    if I == 'c':
        if s == 1:
            b.w(T8=8)
            b.e('ld {T8:b},%s' % src)
            b.e('ld {IX:b},{T8:b}', copy=('IX', 'T8'))
            b.e('extz {IX}')
            first.append('T8')
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{IX})'
        b.e('ld {Z:b},%s' % src)
        b.e('extz {Z}')
        b.e('ld {IX},{Z}', copy=('IX', 'Z'))
        scale_ins(b, s, 'IX')
        first.append('Z')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    raise KeyError(I)


TEMPS = ('IX', 'B', 'Z', 'Y', 'T8', 'ZX', 'AD', 'p')


def prefixed(b, pre, fn, *a, **k):
    """run an element builder for a second index (the destination's): its temps renamed with a prefix, its
    parameter p renamed p2"""
    k0 = len(b.seq)
    w0 = dict(b.width)
    e0, n0 = list(b.early), list(getattr(b, 'nocoal', []))
    fst = k.get('first')
    f0 = list(fst) if fst is not None else None
    mode = fn(b, *a, **k)

    def ren(txt):
        for t in TEMPS:
            new = 'p2' if t == 'p' else pre + t
            txt = re.sub(r'\{%s([:}])' % t, '{%s\\1' % new, txt)
        return txt
    for i in range(k0, len(b.seq)):
        x = b.seq[i]
        cp = tuple(('p2' if c == 'p' else pre + c) for c in x.copy) if x.copy else None
        n = Ins(ren(x.text), copy=cp, when=x.when)
        n.hoist = getattr(x, 'hoist', False)
        b.seq[i] = n
    for lst, old in ((b.early, e0),):
        lst[:] = old + [pre + t for t in lst[len(old):]]
    if hasattr(b, 'nocoal'):
        b.nocoal[:] = n0 + [pre + t for t in b.nocoal[len(n0):]]
    if fst is not None:
        fst[:] = f0 + [pre + t for t in fst[len(f0):]]
    for t in TEMPS:
        if t != 'p' and t in b.width and b.width.get(t) != w0.get(t, None):
            b.width[pre + t] = b.width[t]
            if t in w0:
                b.width[t] = w0[t]
            else:
                del b.width[t]
    return ren(mode)


# ==============================================================================================================
# the predictor (pred.py)
# ==============================================================================================================
S_ = {'c': 1, 'i': 2, 'l': 4}
MOFF = {'c': 0, 'i': 2, 'l': 4, 'p': 8}           # struct st { char c; int i; long l; char *p; int a[4]; }
GLOB = {'c': ('gc', 'hc', 'gca', 'vca', 'gp', 'vp'), 'i': ('gv', 'hv', 'gia', 'via', 'gpi', 'vpi'),
        'l': ('gl', 'hl', 'gla', 'vla', 'gpl', 'vpl')}


def hx(n):
    return '0x%x' % n


def W(t, n):
    """register text of temp n at the width of type t"""
    return {'c': '{%s:b}', 'i': '{%s}', 'l': '{%s:x}'}[t] % n


def scale_ins(b, s, r, spec=''):
    sp = ':' + spec if spec else ''
    if s == 2:
        b.e('add {%s%s},{%s%s}' % (r, sp, r, sp))
    elif s == 4:
        b.e(('sll 0x2,{%s:x}' % r) if spec == 'x' else 'sla 0x2,{%s%s}' % (r, sp))


class Shape:
    def __init__(self, t, pb, pc, L, V, S, cast=False):
        self.t, self.pb, self.pc, self.L, self.V, self.S, self.cast = t, pb, pc, L, V, S, cast
        self.xr = S in ('Xr', 'O3XSXr')
        self.o3 = S in ('O3XS', 'O3XSXr')
        self.s = S_[t]
        g, h, ga, va, gp, vp = GLOB[t]
        self.g, self.h, self.ga, self.va, self.gp, self.vp = '_' + g, '_' + h, '_' + ga, '_' + va, '_' + gp, '_' + vp


def xr_idx(b, s, I, arr, opt, first, pref):
    """-Xr: arr[p] with the index parameter p in WA / A (b) or BC / C (c)"""
    if I == 'a':
        if s == 1:
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p})'
        b.e('ld {IX},{p}', copy=('IX', 'p'))
        scale_ins(b, s, 'IX')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if I == 'b':
        if s == 1:
            b.e('lda {B:x},%s' % arr)
            return '({B:x}+{p:b})'
        b.w(Y=8, IX=8, Z=8)
        if s == 2:
            b.e('ld {Y:b},{p:b}', copy=('Y', 'p'))
            b.e('add {Y:b},{p:b}')
            first.append('Y')
            pref['Y'] = 'WA'
            b.e('ld {IX:b},{Y:b}', copy=('IX', 'Y'))
        else:
            b.e('ld {Z:b},{p:b}', copy=('Z', 'p'))
            b.e('sla 0x2,{Z:b}')
            b.e('ld {IX:b},{Z:b}', copy=('IX', 'Z'))
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX:b})'
    if s == 1:
        b.w(IX=16)
        b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
        b.seq[-1].hoist = opt
        pref['IX'] = 'WA'
        b.e('extz {IX}')
        b.e('lda {B:x},%s' % arr)
        return '({B:x}+{IX})'
    if opt:
        b.w(IX=16)
        b.e('ld {IX:b},{p:b}', copy=('IX', 'p'))
        b.seq[-1].hoist = True
        pref['IX'] = 'WA'
        b.e('extz {IX}')
    else:
        b.w(Z=16)
        b.e('ld {Z:b},{p:b}', copy=('Z', 'p'))
        pref['Z'] = 'WA'
        b.e('extz {Z}')
        b.e('ld {IX},{Z}', copy=('IX', 'Z'))
    scale_ins(b, s, 'IX')
    b.e('lda {B:x},%s' % arr)
    return '({B:x}+{IX})'


def elem(sh, b, s, which, arr, first, regime):
    """arr[b] (which 0) or arr[c] (which 1): the element at a parameter index, by set; -> operand"""
    pt = sh.pb if which == 0 else sh.pc
    I = {'i': 'a', 'c': 'b', 'u': 'c'}[pt]
    b.regime = regime
    if sh.xr:
        pr = {}
        fn, a, k = xr_idx, (b, s, I, arr, sh.o3, first, pr), {}
        if which == 0:
            r = xr_idx(*a)
        else:
            f0 = list(first)
            r = prefixed(b, 'D', xr_idx, *a[1:5], [], pr)
            first.extend('D' + x for x in [y for y in ('Y',) if y in pr])
        for kk, v in pr.items():
            b.prefs[('D' + kk) if which else kk] = v
        return r
    elif sh.o3:
        fn, a, k = o3_elem, (b, s, I, arr), dict(src='(XSP+0x6)' if which else SRC, first=first)
    else:
        fn, a, k = none_elem, (b, s, I, arr), dict(src='(XSP+0x6)' if which else SRC, first=first)
    if which == 0:
        return fn(*a, **k)
    return prefixed(b, 'D', fn, *a[1:], **k)


def param_word(sh, b, which, tmp):
    """the parameter as a 16-bit value in tmp: a load (cdecl; a char one by its byte and an extension) or a copy"""
    pt = sh.pb if which == 0 else sh.pc
    p = ('p', 'p2')[which]
    src = '(XSP+0x4)' if which == 0 else '(XSP+0x6)'
    if pt == 'i':
        b.e('ld {%s},{%s}' % (tmp, p) if sh.xr else 'ld {%s},%s' % (tmp, src), copy=(tmp, p) if sh.xr else None)
    else:
        b.e('ld {%s:b},{%s:b}' % (tmp, p) if sh.xr else 'ld {%s:b},%s' % (tmp, src), copy=(tmp, p) if sh.xr else None)


# ---------------------------------------------------------------------------------------------------- int / long
def stmt_il(sh):
    t, s, L, V = sh.t, sh.s, sh.L, sh.V
    b = Body()
    b.nocoal = []
    b.prefs = {}
    pw = lambda pt: 8 if pt in 'cu' else 16
    b.w(p=pw(sh.pb), p2=pw(sh.pc), V=8 * s if s != 2 else 16)
    off = lambda r, o: '({%s:x}+%s)' % (r, hx(o)) if o else '({%s:x})' % r
    R = lambda n: W(t, n)
    first, pref, order_v, order_d, last = [], {}, [], [], []
    dest_first = V not in 'DS'

    def dest():
        if L == 'G':
            return '(%s)' % sh.g
        if L == 'M':
            return '(_gs + %s)' % hx(MOFF[t]) if MOFF[t] else '(_gs)'
        if L == 'E':
            return '(%s + %s)' % (sh.ga, hx(3 * s))
        if L == 'P':
            b.e('ld {Q:x},(%s)' % sh.gp)
            last.append('Q')
            return '({Q:x})'
        if L == 'D':
            b.e('ld {Q:x},(_gps)')
            (first if MOFF[t] else last).append('Q')     # (offset 0: as a plain pointer)
            return off('Q', MOFF[t])
        if L == 'X' and sh.pc == 'c' and s == 2 and V in 'XY' and sh.pb == 'c' and (sh.xr or sh.o3):
            b.w(DIX=8, DT8=8)               # (the value's index is computed in A: this one goes straight to its
            if sh.xr:                       #  register)
                b.e('ld {DIX:b},{p2:b}', copy=('DIX', 'p2'))
                b.e('add {DIX:b},{p2:b}')
            else:
                b.e('ld {DT8:b},(XSP+0x6)')
                b.e('ld {DIX:b},{DT8:b}', copy=('DIX', 'DT8'))
                b.e('add {DIX:b},{DT8:b}')
                b.nocoal.append('DIX')
                b.prefs['DT8'] = 'BC'       # (loaded into C, as the value's own index byte)
            b.e('lda {DB:x},%s' % sh.ga)
            order_d.extend(['DT8', 'DIX', 'DB'])
            return '({DB:x}+{DIX:b})'
        if L == 'X':
            k0 = len(b.seq)
            d = elem(sh, b, s, 1, sh.ga, first, 'E' if not dest_first else 'F')
            names = ('DY', 'DT8', 'DZ', 'DB', 'DIX', 'DZX', 'DAD') if d == '({DIX:x})' else \
                ('DY', 'DT8', 'DZ', 'DIX', 'DB', 'DZX', 'DAD')
            order_d.extend(n for n in names if any(n in x.temps for x in b.seq[k0:]))
            return d
        if L == 'Q' and s == 1:              # a char element through the pointer: as X with the pointer's value
            k0 = len(b.seq)
            d = elem(sh, b, s, 1, sh.gp, first, 'E' if not dest_first else 'F')
            for i in range(k0, len(b.seq)):
                x = b.seq[i]
                if x.text == 'lda {DB:x},%s' % sh.gp:
                    b.seq[i] = Ins('ld {DB:x},(%s)' % sh.gp)
            names = ('DY', 'DT8', 'DZ', 'DB', 'DIX', 'DZX', 'DAD') if d == '({DIX:x})' else \
                ('DY', 'DT8', 'DZ', 'DIX', 'DB', 'DZX', 'DAD')
            order_d.extend(n for n in names if any(n in x.temps for x in b.seq[k0:]))
            return d
        if L == 'Q':
            if sh.pc == 'i':
                param_word(sh, b, 1, 'DIX')
                b.e('exts {DIX:x}')
                scale_ins(b, s, 'DIX', 'x')
                b.e('ld {DA:x},{DIX:x}', copy=('DA', 'DIX'))
                b.e('add {DA:x},(%s)' % sh.gp)
                order_d.extend(['DIX', 'DA'])
                if dest_first and not sh.o3:
                    b.nocoal.append('DA')
                if sh.xr and not sh.o3:          # -Xr without -O: c's register is not reused for a 32-bit index
                    b.nocoal.append('DIX')
                return '({DA:x})'
            ext = 'exts' if sh.pc == 'c' else 'extz'
            if sh.xr and sh.o3:              # -O3 -Xr: the char copied out of C, extended where it is used
                b.w(DIX=16)
                b.e('ld {DIX:b},{p2:b}', copy=('DIX', 'p2'))
                b.e('%s {DIX}' % ext)
            else:
                b.w(DQZ=8)
                b.nocoal.append('DIX')
                param_word(sh, b, 1, 'DQZ')
                b.e('%s {DQZ}' % ext)
                b.e('ld {DIX},{DQZ}', copy=('DIX', 'DQZ'))
                b.prefs['DQZ'] = 'WA'
            scale_ins(b, s, 'DIX')
            b.e('ld {DQ:x},(%s)' % sh.gp)
            order_d.extend(['DQZ', 'DQ', 'DIX'])
            b.qchar = True
            return '({DQ:x}+{DIX})'
        raise KeyError(L)

    if dest_first:
        d = dest()
    # the value
    if V == 'D':
        b.e('ld {VP:x},(_vps)')
        b.e('ld %s,(%s)' % (R('V'), sh.h))
        b.e('sub %s,%s' % (R('V'), off('VP', MOFF[t])))
        order_v.append('VP')
    elif V == 'P':
        b.e('ld {VP:x},(%s)' % sh.vp)
        b.e('ld %s,({VP:x})' % R('V'))
        b.e('add %s,(%s)' % (R('V'), sh.h))
        order_v.append('VP')
    elif V in 'XY':
        k0 = len(b.seq)
        el = elem(sh, b, s, 0, sh.va, first, 'E' if V == 'X' else 'F')
        names = ('Y', 'T8', 'Z', 'B', 'IX', 'ZX', 'AD') if el == '({IX:x})' else ('Y', 'T8', 'Z', 'IX', 'B', 'ZX', 'AD')
        order_v.extend(n for n in names if any(n in x.temps for x in b.seq[k0:]))
        if V == 'X':
            b.e('ld %s,%s' % (R('V'), el))
            b.e('or %s,0x5' % R('V'))
            first.insert(0, 'V')
            pref['V'] = 'WA'
        else:
            b.e('ld %s,(%s)' % (R('V'), sh.h))
            b.e('xor %s,%s' % (R('V'), el))
    elif V == 'E':
        b.e('ld %s,(%s + %s)' % (R('V'), sh.va, hx(5 * s)))
        b.e('and %s,(%s)' % (R('V'), sh.h))
    elif V == 'S':
        cb = sh.pb in 'cu'
        if cb:
            b.w(CN=8)
        param_word(sh, b, 0, 'CN')
        b.e('and {CN%s},0x7' % (':b' if cb else ''))
        b.e('ld %s,%s' % (R('V'), '(_vs + %s)' % hx(MOFF[t]) if MOFF[t] else '(_vs)'))
        if s == 4:
            b.e('bit 0x4,{CN:b}')
            b.e('j z,L1')
            b.e('sra 0x0,%s' % R('V'))
            b.e('L1:')
            b.e('and {CN:b},0xf')
            b.e('j z,L2')
            b.e('sra {CN:b},%s' % R('V'))
            b.e('L2:')
        else:
            b.e('and {CN:b},0xf')
            b.e('j z,L1')
            b.e('sra {CN:b},%s' % R('V'))
            b.e('L1:')
    if (L == 'G' or t == 'c') and V not in 'S':
        if 'V' not in first:
            first.insert(0, 'V')
        pref['V'] = 'WA'
    vs = 'V'
    if not dest_first:
        if t == 'c' and L in 'XQ':                  # a char value moves out of the way of the address
            b.e('ld {VS:b},{V:b}', copy=('VS', 'V'))
            b.w(VS=8)
            vs = 'VS'
        d = dest()
    b.e('ld %s,%s' % (d, R(vs)))
    fixed = {}
    if V == 'S':
        fixed['CN'] = 'WA'
    if sh.xr:
        fixed['p'] = 'WA'
        fixed['p2'] = 'BC'
    if 'Q' in first:                       # a destination pointer with a displacement is coloured first, after the
        first.remove('Q')                  # temps of a char index computed in A
        byte = [x for x in first if x in ('Y', 'T8', 'ZX', 'Z')]
        early = [x for x in b.early if x not in first]
        first[:] = byte + early + ['Q'] + [x for x in first if x not in byte]
    for n in ('Y', 'T8', 'DY', 'DT8', 'Z', 'DZ'):
        pref.setdefault(n, 'WA')
    pref.update(b.prefs)
    if sh.xr:
        for n in ('Z', 'DZ', 'Y', 'DY'):
            if n not in b.prefs:
                pref.pop(n, None)
    if dest_first and getattr(b, 'qchar', False):
        ev = [x for x in order_v if x in b.early or (sh.xr and x == 'Y')]
        order = ['DQZ'] + ev + ['DQ'] + [x for x in order_v if x not in ev] + ['DIX', 'V']
    elif dest_first:
        late = [x for x in order_d if x == 'DA']
        order = order_v + [x for x in order_d if x != 'DA'] + ['V'] + late
    elif t == 'c' and L in 'XQ' and sh.pc in 'cu':
        order = order_v + ['V'] + order_d + ['VS']
    elif t == 'c' and L in 'XQ':
        order = order_v + ['V', 'VS'] + order_d
    else:
        order = order_d + order_v + ['V']
    if L == 'Q' and s == 1 and 'DB' in order:
        order.remove('DB')
        order.insert(0, 'DB')
    out = b.colour(fixed=fixed, first=first, pref=pref, order=order, last=last,
                   nocoalesce=b.nocoal + (['VS'] if V != 'S' else []), coalesce='pref',
                   avoid={'VS': ['V']} if V != 'S' else {})
    if sh.o3:
        out = unmark(backprop(forward(out)))
    if sh.xr and sh.o3 and dest_first:     # -O3 -Xr: the surviving copies of an unsigned char parameter go first,
        F = {n: Reg(r) for n, r in b.reg.items()}    # b's before c's unless b's would overwrite c
        hs = []
        for x in b.seq:
            if getattr(x, 'hoist', False) and b.reg.get(x.copy[0]) != b.reg.get(x.copy[1]):
                hs.append((x.copy[1], x.text.format(**F), b.reg.get(x.copy[0])))
        if hs:
            hs.sort(key=lambda h: h[0] != 'p')
            if len(hs) == 2 and hs[0][2] == b.reg.get('p2'):
                hs.reverse()
            for _, txt, _r in hs:
                out.remove(txt)
            out[0:0] = [h[1] for h in hs]
    return out + ['ret']


def parse(name):
    m = re.match(r'sx_([icl])_([GMPDEXQ])([DPXYES])$', name)
    if m:
        t, L, V = m.groups()
        return dict(t=t, pb='i', pc='i', L=L, V=V, cast=(t == 'c'), probe='stvx')
    m = re.match(r'sp_([GMD])([ASD])$', name)
    if m:
        return dict(t='p', pb='i', pc='i', L=m.group(1), V=m.group(2), cast=False, probe='stvx')
    m = re.match(r'([icu])_([cil])_([GMPDEXQ])([DPXYES])$', name)
    if m:
        p, t, L, V = m.groups()
        return dict(t=t, pb=p, pc=p, L=L, V=V, cast=False, probe='stvxc')
    return None


def predict(name, S):
    d = parse(name)
    if d is None:
        return None
    sh = Shape(d['t'] if d['t'] != 'p' else 'i', d['pb'], d['pc'], d['L'], d['V'], S, d['cast'])
    if d['t'] in 'il' or (d['t'] == 'c' and not d['cast']):
        return stmt_il(sh)
    if d['cast']:
        return stmt_cast(sh)
    if d['t'] == 'p':
        return stmt_sp(sh)
    return None


def store_fwd(L):
    """-O: ld A,R / ld (m),A -> ld (m),R when A is dead after"""
    out = list(L)
    i = 0
    while i < len(out) - 1:
        m = re.match(r'ld A,([CELBDH])$', out[i])
        m2 = re.match(r'ld (\(.*\)),A$', out[i + 1])
        if m and m2 and _dead_after(out, i + 1, 'A'):
            out[i:i + 2] = ['ld %s,%s' % (m2.group(1), m.group(1))]
        i += 1
    return out


def stmt_cast(sh):
    """stvx's char form: gc = (char)((int)x op (int)y) -- both operands sign-extended to int, the right one first
    (into its own register), the result's low byte stored"""
    L, V = sh.L, sh.V
    b = Body()
    b.nocoal = []
    b.prefs = {}
    b.w(p=16, p2=16, V=16, R2=16, T8=8, VS=8, SA=8)
    first, pref, order_v, order_d, last = ['V'], {'V': 'WA', 'T8': 'WA'}, [], [], []
    dest_first = V == 'X'

    def dest():
        if L == 'G':
            return '(_gc)'
        if L == 'M':
            return '(_gs)'
        if L == 'E':
            return '(_gca + 0x3)'
        if L in 'PD':
            b.e('ld {Q:x},(%s)' % ('_gp' if L == 'P' else '_gps'))
            last.append('Q')
            return '({Q:x})'
        k0 = len(b.seq)
        d = elem(sh, b, 1, 1, '_gca' if L == 'X' else '_gp', first, 'E' if not dest_first else 'F')
        if L == 'Q':
            for i in range(k0, len(b.seq)):
                if b.seq[i].text == 'lda {DB:x},_gp':
                    b.seq[i] = Ins('ld {DB:x},(_gp)')
        names = ('DB', 'DIX') if d == '({DIX:x})' else ('DIX', 'DB')
        order_d.extend(n for n in names if any(n in x.temps for x in b.seq[k0:]))
        return d

    def right(src):
        b.e('ld {T8:b},%s' % src)
        b.e('ld {R2:b},{T8:b}', copy=('R2', 'T8'))
        b.e('exts {R2}')
        b.nocoal.append('R2')

    if dest_first:
        d = dest()
    res = 'V'
    if V == 'D':
        b.e('ld {VP:x},(_vps)')
        right('({VP:x})')
        b.e('ld {V:b},(_hc)')
        b.e('exts {V}')
        b.e('sub {V},{R2}')
        order_v.append('VP')
    elif V == 'P':
        right('(_hc)')
        b.e('ld {VP:x},(_vp)')
        b.e('ld {V:b},({VP:x})')
        b.e('exts {V}')
        b.e('add {V},{R2}')
        order_v.append('VP')
    elif V in 'XY':
        k0 = len(b.seq)
        el = elem(sh, b, 1, 0, '_vca', first, 'E')
        names = ('B', 'IX') if el == '({IX:x})' else ('IX', 'B')
        order_v.extend(n for n in names if any(n in x.temps for x in b.seq[k0:]))
        if V == 'X':
            b.e('ld {V:b},%s' % el)
            b.e('exts {V}')
            b.e('or {V},0x5')
        else:
            right(el)
            b.e('ld {V:b},(_hc)')
            b.e('exts {V}')
            b.e('xor {V},{R2}')
    elif V == 'E':
        right('(_hc)')
        b.e('ld {V:b},(_vca + 0x5)')
        b.e('exts {V}')
        b.e('and {V},{R2}')
    else:                                          # S: vs.c >> (b & 7)
        param_word(sh, b, 0, 'CN')
        b.e('and {CN},0x7')
        b.e('ld {V:b},(_vs)')
        b.e('exts {V}')
        b.e('ld {VV},{V}', copy=('VV', 'V'))
        b.e('ld {CA},{CN}', copy=('CA', 'CN'))
        b.e('and {CA:b},0xf')
        b.e('j z,L1')
        b.e('sra {CA:b},{VV}')
        b.e('L1:')
        res = 'VV'
        pref.pop('V')
        first.remove('V')
        pref['V'] = 'WA'
        first.append('V')
        b.nocoal += ['VV']
        b.prefs['CA'] = 'WA'
    vs = res
    if L == 'G' and V == 'S':
        b.e('ld {SA:b},{VV:b}', copy=('SA', 'VV'))
        b.prefs['SA'] = 'WA'
        vs = 'SA'
    if not dest_first:
        if L in 'XQ':
            b.e('ld {VS:b},{%s:b}' % res, copy=('VS', res))
            vs = 'VS'
        d = dest()
    b.e('ld %s,{%s:b}' % (d, vs))
    fixed = {}
    if sh.xr:
        fixed['p'] = 'WA'
        fixed['p2'] = 'BC'
    pref.update(b.prefs)
    if V == 'S':
        order_v.insert(0, 'CN')
    if dest_first:
        order = order_v + order_d + ['R2', 'V']
        if L == 'Q':
            order = ['DB'] + [x for x in order if x != 'DB']
    elif L in 'XQ':
        order = order_v + ['R2', 'V', 'VV', 'VS'] + order_d
    else:
        order = order_d + order_v + ['R2', 'V']
    out = b.colour(fixed=fixed, first=first, pref=pref, order=order, last=last,
                   nocoalesce=b.nocoal + (['VS'] if V != 'S' else []), coalesce='pref',
                   avoid={'VS': [res] if V != 'S' else [], 'VV': ['V'], 'R2': ['T8']})
    if sh.o3:
        out = store_fwd(unmark(backprop(forward(out))))
    return out + ['ret']


def stmt_sp(sh):
    """stvx's char pointer stores sp_<L><V>: L gp / gs.p / gps->p, V &vca[b] / vs.p + b / vps->p"""
    L, V = sh.L, sh.V
    b = Body()
    b.w(p=16, IX=32, V=32)
    first, pref, last = [], {}, []
    d = {'G': '(_gp)', 'M': '(_gs + 0x8)', 'D': '({Q:x}+0x8)'}[L]
    if L == 'D':
        b.e('ld {Q:x},(_gps)')
        if V != 'D':
            first.append('Q')
    if V == 'D':
        b.e('ld {VP:x},(_vps)')
        b.e('ld {V:x},({VP:x}+0x8)')
        res = 'V'
    else:
        b.e('lda {B:x},_vca' if V == 'A' else 'ld {B:x},(_vs + 0x8)')
        ext = 'exts' if (sh.xr or L == 'G') else 'extz'     # (no options: zero-extended for a member store)
        if sh.xr:
            b.e('ld {IX},{p}', copy=('IX', 'p'))
        else:
            b.e('ld {IX},(XSP+0x4)')
        b.e('%s {IX:x}' % ext)
        b.e('add {IX:x},{B:x}')
        res = 'IX'
        if L == 'G' or sh.xr:
            first.append('IX')
            pref['IX'] = 'WA'
    b.e('ld %s,{%s:x}' % (d, res))
    fixed = {'p': 'WA'} if sh.xr else {}
    out = b.colour(fixed=fixed, first=first, pref=pref, order=['B', 'VP', 'V', 'IX'], coalesce='pref')
    return out + ['ret']


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
    for n in sorted(probe_types(), key=len, reverse=True):
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
