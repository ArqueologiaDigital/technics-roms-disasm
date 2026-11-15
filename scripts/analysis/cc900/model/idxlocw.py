#!/usr/bin/env python3
"""idxloc_ast.py -- the cc900 oracle's code for the functions of probe idxloc.c (corpus/probes/idxloc.c, oracle run
2026-11-12-3-micro-idxloc), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'
    python3 idxloc_ast.py --check SET [--show N] [--one] [--dec] [--only REGEX]   (the model directory on sys.path)

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
# the probe's grammar, in the notation (idxloc.c: il_<t>_<H><S>(int c), gen_idxloc.py)
# ==============================================================================================================
TYP = {'i': ('i', 'gia', 'hia', 'gx', 'hx', 'v1', 'ri', 'gpx'), 'l': ('l', 'gla', 'hla', 'gxl', 'hxl', 'vl', 'rl', 'gpl'),
       'c': ('c', 'gca', 'hca', 'gxc', 'hxc', 'vc', 'rc', 'gpc')}
STMT = {'1': '({g} = {a}[X]);', '2': '({a}[X] = {h});', '3': '({a}[X] = 7);', '4': '({a}[X] = {r}());',
        '5': '({g} = ({h} - {a}[X]));', '6': '({g} = ({a}[X] + {h}));', '7': '{v}({a}[X]);', '8': '{v}(({h} - {a}[X]));',
        '9': 'if (({a}[X] < {h})) ($gi3 = 1);', 'A': '({a}[X] += {h});', 'B': '({p} = &{a}[X]);',
        'C': '({g} = ({a}[X] - {b}[X]));'}


def probe_types(name):
    ty = {'gi': 'i', 'gi3': 'i', 'v0': 'Fv(v)'}
    for t, (s, a, b, g, h, v, r, p) in TYP.items():
        ty.update({a: s + '[8]', b: s + '[8]', g: s, h: s, v: 'Fv(%s)' % s, r: 'F%s(v)' % s, p: s + '*'})
    return ty


def probe_text(name):
    _, t, k = name.split('_')
    H, sn = k[0], k[1]
    s, a, b, g, h, v, r, p = TYP[t]
    st = STMT[sn]
    for x, y in (('a', a), ('b', b), ('g', g), ('h', h), ('v', v), ('r', r), ('p', p)):
        st = st.replace('{%s}' % x, '$' + y)
    st = st.replace('X', '%0')
    if H == 'L':
        return 'v(i) { i %%0; for ((%%0 = 0); (%%0 < 4) %%0++) { %s $v0(); } }' % st
    if H == 'T':
        return 'v(i) { i %%0 = $gi; $v0(); %s $v0(); }' % st
    return 'v(i) { i %%0 = $gi; %s }' % st


def probe_names():
    return ['il_%s_%s%s' % (t, H, s) for t in 'ilc' for H in 'LTR' for s in '123456789ABC']


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




# which pairs the element's address takes: (scaled index i, base b) -- the second pair (BC, XDE) when the statement
# needs WA for another value first (a store of a loaded value, `h - e`, `+=`; a long constant store)
SECOND = {'i': '25A', 'l': '235A', 'c': '258ABC'}


def elem(t, src, i, b, arr):
    """the address of arr[index]: (lines, operand); src the index's home (IZ, or (_gi) for a register temporary)"""
    if t == 'c':                                          # no scaling: the index register itself
        return ['lda X%s,_%s' % (b, arr)], '(X%s+%s)' % (b, src)
    sc = ['add %s,%s' % (i, i)] if t == 'i' else ['sla 0x2,%s' % i]
    return ['ld %s,%s' % (i, src)] + sc + ['lda X%s,_%s' % (b, arr)], '(X%s+%s)' % (b, i)


def predict(name, Z):
    _, t, k = name.split('_')
    H, sn = k[0], k[1]
    s, a, b2, g, h, v, r, p = TYP[t]
    V = {'i': 'WA', 'l': 'XWA', 'c': 'A'}[t]
    RET = {'i': 'HL', 'l': 'XHL', 'c': 'L'}[t]
    second = sn in SECOND[t]
    if Z.opt and Z.xr and sn == '8' and t != 'c':      # -O3 -XS -Xr: `h - e` formed in the argument register WA
        second = True
    i_, b_ = ('BC', 'DE') if second else ('WA', 'BC')
    # the index's home: IZ (loop counter, local across a call, or across the call of S4), else a register
    iz = H in 'LT' or sn == '4'
    if iz:
        src, pre = 'IZ', []
    elif t == 'c':
        src = 'DE' if second else 'BC'
        pre = ['ld %s,(_gi)' % src]
        if sn == 'B':
            src, pre = None, ['ld WA,(_gi)']
    else:
        src, pre = '(_gi)', []
    out = []
    if sn == 'C':                                         # two elements at the same index
        if t == 'c':
            idx = 'IZ' if iz else 'DE'
            out = (pre if not iz else []) + ['lda XWA,_%s' % a, 'lda XBC,_%s' % b2, 'ld A,(XWA+%s)' % idx,
                                             'sub A,(XBC+%s)' % idx, 'ld (_%s),A' % g]
        else:
            sc = (lambda x: ['add %s,%s' % (x, x)]) if t == 'i' else (lambda x: ['sla 0x2,%s' % x])
            if Z.opt:                                     # -O: one scaled index for both
                first = ['ld BC,%s' % src] + sc('BC')
                out = first + ['lda XWA,_%s' % a, 'lda XDE,_%s' % b2, 'ld %s,(XWA+BC)' % V, 'sub %s,(XDE+BC)' % V]
            elif iz:
                out = ['ld WA,IZ'] + sc('WA') + ['lda XHL,_%s' % a, 'ld BC,IZ'] + sc('BC') + \
                    ['lda XDE,_%s' % b2, 'ld %s,(XHL+WA)' % V, 'sub %s,(XDE+BC)' % V]
            else:
                out = ['ld BC,(_gi)', 'ld WA,BC'] + sc('WA') + ['lda XHL,_%s' % a] + sc('BC') + \
                    ['lda XDE,_%s' % b2, 'ld %s,(XHL+WA)' % V, 'sub %s,(XDE+BC)' % V]
            out += ['ld (_%s),%s' % (g, V)]
    elif sn == 'B':                                       # the element's address
        if t == 'c':
            out = (['lda XBC,_%s' % a, 'ld WA,IZ'] if iz else pre + ['lda XBC,_%s' % a]) + ['exts XWA', 'add XWA,XBC']
        else:
            out = elem(t, src, 'WA', 'BC', a)[0] + ['exts XWA', 'add XWA,XBC']
        out += ['ld (_%s),XWA' % p]
    else:
        if t == 'c':
            bb = 'BC' if second else 'WA'
            al, e = elem(t, src, None, bb, a)
            al = pre + al
        else:
            al, e = elem(t, src, i_, b_, a)
        hm = '(_%s)' % h
        if sn == '1':
            out = al + ['ld %s,%s' % (V, e), 'ld (_%s),%s' % (g, V)]
        elif sn == '2':
            out = al + ['ld %s,%s' % (V, hm), 'ld %s,%s' % (e, V)]
        elif sn == '3':
            out = al + (['ld XWA,0x7', 'ld %s,XWA' % e] if t == 'l' else ['ld%s %s,0x7' % ('w' if t == 'i' else 'b', e)])
        elif sn == '4':
            out = ['cal _%s' % r] + al + ['ld %s,%s' % (e, RET)]
        elif sn == '5':
            out = al + ['ld %s,%s' % (V, hm), 'sub %s,%s' % (V, e), 'ld (_%s),%s' % (g, V)]
        elif sn == '6':
            out = al + ['ld %s,%s' % (V, e), 'add %s,%s' % (V, hm), 'ld (_%s),%s' % (g, V)]
        elif sn == '7':
            if t == 'i':
                out = al + ['pushw %s' % e, 'cal _%s' % v, 'inc 0x2,XSP']
            elif t == 'l':
                out = al + ['ld XWA,%s' % e, 'push XWA', 'cal _%s' % v, 'inc 0x4,XSP']
            else:
                out = al + ['ld A,%s' % e, 'exts WA', 'push WA', 'cal _%s' % v, 'inc 0x2,XSP']
        elif sn == '8':
            if t == 'c':
                out = al + ['ld A,%s' % hm, 'sub A,%s' % e, 'exts WA', 'push WA', 'cal _%s' % v, 'inc 0x2,XSP']
            else:
                d = V if second else ('DE' if t == 'i' else 'XDE')
                out = al + ['ld %s,%s' % (d, hm), 'sub %s,%s' % (d, e), 'push %s' % d, 'cal _%s' % v,
                            'inc 0x%x,XSP' % (2 if t == 'i' else 4)]
        elif sn == '9':
            out = al + ['ld %s,%s' % (V, e), 'cp %s,%s' % (V, hm), 'JGE', 'ldw (_gi3),0x1', 'LX:']
        else:                                             # 'A'
            out = al + ['ld %s,%s' % (V, hm), 'add %s,%s' % (e, V)]
    # the home of the index
    if H == 'L':
        if Z.opt:                                         # -O: 0 < 4 is known, no test before the loop
            out = ['push IZ', 'ld IZ,0x0', 'L1:'] + out + ['cal _v0', 'inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L1', 'pop IZ', 'ret']
        else:
            out = ['push IZ', 'ld IZ,0x0', 'cp IZ,0x4', 'j ge,L1', 'L2:'] + out + \
                ['cal _v0', 'inc 0x1,IZ', 'cp IZ,0x4', 'j lt,L2', 'L1:', 'pop IZ', 'ret']
        jge = 'j ge,L3'
    elif H == 'T':
        out = ['push IZ', 'ld IZ,(_gi)', 'cal _v0'] + out + ['cal _v0', 'pop IZ', 'ret']
        jge = 'j ge,L3'
    elif iz:
        out = ['push IZ', 'ld IZ,(_gi)'] + out + ['pop IZ', 'ret']
        jge = 'j ge,L3'
    else:
        out = out + ['ret']
        jge = 'ret ge'
    out = [jge if l == 'JGE' else ('L3:' if l == 'LX:' else l) for l in out]
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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/idxloc.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-12-3-micro-idxloc/out/v423/%s/probes/idxloc.asm'


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
        fs = fams.setdefault(f.name[:5], [0, 0, 0])
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
