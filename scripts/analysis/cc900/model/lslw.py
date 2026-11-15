#!/usr/bin/env python3
"""lsl_ast.py -- the cc900 oracle's code for the functions of probe lsl.c (corpus/probes/lsl.c, oracle run
2026-11-13-16-micro-lsl), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'
    python3 lsl_ast.py --check SET [--show N] [--one] [--dec] [--only REGEX]   (the model directory on sys.path)

As lhx_ast.py: the function's AST in a canonical notation is matched against the probe's grammar (probe_text), the
code is written for that probe name with the probe's symbols, then the real symbols are substituted.  The rules are
in lhidx-FAMILIES.md (section lsl).  Nothing is looked up by the function's name.
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
# the probe's grammar, in the notation (lsl.c: ls_<t>_<i>_<m>_<u>(void), gen_lsl.py)
# ==============================================================================================================
LSL_T = {'i': ('i', 'gi', 'gia'), 'l': ('l', 'gl2', 'gla'), 'c': ('c', 'gc', 'gca'), 'p': ('i*', 'gpi', None)}


def probe_types(name):
    return {'gi': 'i', 'gia': 'i[8]', 'gpi': 'i*', 'hpi': 'i*', 'gl': 'l', 'gl2': 'l', 'gla': 'l[8]', 'gpl': 'l*',
            'gc': 'c', 'gca': 'c[8]', 'gu2': 'u', 'v0': 'Fv(v)'}


def probe_text(name):
    _, t, i, m, u = name.split('_')
    ty, g, ga = LSL_T[t]
    if t == 'p':
        init = {'g': '$gpi', 'e': '$hpi', 'a': '($gpi + 5)'}[i]
    elif t == 'c':                                         # (char)gca[3] is gca[3] once the no-op cast is gone
        init = {'g': '$gc', 'e': '$gca[3]', 'c': '$gca[3]', 's': '($gca[3] >> 3)', 'a': '($gc + 5)', 'k': '9'}[i]
    else:
        init = {'g': '$' + g, 'e': '$%s[3]' % ga, 'c': '(%s)$gca[3]' % ty, 's': '((%s)$gca[3] >> 3)' % ty,
                'a': '($%s + 5)' % g, 'k': '9'}[i]
    mid = {'h': ' if (($gl != 0)) (*$gpl = ($gla[7] % $gl));', 'v': ' $v0();', 'n': ''}[m]
    if u == 'r':
        use = ' return %0;'
    elif t == 'p':
        use = ' ($gpi = %0);'
    else:
        use = ' ($%s = ($%s + %%0));' % (g, g)
    return '%s() { %s %%0 = %s; $gu2--;%s%s }' % (ty if u == 'r' else 'v', ty, init, mid, use)


def probe_names():
    out = []
    for t in 'ilcp':
        for i in ('gea' if t == 'p' else 'gecsak'):
            for m in 'hvn':
                for u in 'ar':
                    out.append('ls_%s_%s_%s_%s' % (t, i, m, u))
    return out


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




# the local's registers by type: the accumulator, the return register, the callee-saved home (and its push)
REGS = {'i': ('WA', 'HL', 'IZ', 'IZ'), 'l': ('XWA', 'XHL', 'XIZ', 'XIZ'), 'c': ('A', 'L', 'QIZH', 'QIZ'),
        'p': ('XWA', 'XHL', 'XIZ', 'XIZ')}
GLOB = {'i': '_gi', 'l': '_gl2', 'c': '_gc', 'p': '_gpi'}
ELEM = {'i': '(_gia + 0x6)', 'l': '(_gla + 0xc)', 'c': '(_gca + 0x3)', 'p': '(_hpi)'}


def value(t, i, R, Z):
    """the initialiser computed into register R"""
    g = '(%s)' % GLOB[t]
    if t == 'p':
        if i == 'a':
            if R == 'XIZ' and not Z.opt:                  # (cdecl: formed in XWA, then moved)
                return ['ld XWA,%s' % g, 'lda XWA,XWA+0xa', 'ld XIZ,XWA']
            return ['ld XWA,%s' % g, 'lda %s,XWA+0xa' % R]
        return ['ld %s,%s' % (R, g if i == 'g' else ELEM[t])]
    if t == 'c':
        if R == 'QIZH':
            return ['ld QIZH,0x9'] if i == 'k' else value(t, i, 'A', Z) + ['ld QIZH,A']
        src = {'g': g, 'e': ELEM[t], 'c': ELEM[t], 's': ELEM[t], 'a': g, 'k': '0x9'}[i]
        return ['ld %s,%s' % (R, src)] + (['sra 0x3,%s' % R] if i == 's' else ['inc 0x5,%s' % R] if i == 'a' else [])
    if i in 'cs':                                         # a char element widened to t
        ext = ['exts %s' % R[-2:]] + (['exts %s' % R] if t == 'l' else [])
        if R in ('WA', 'XWA'):
            body = ['ld A,(_gca + 0x3)'] + ext
        elif R in ('IZ', 'XIZ'):
            body = ['ld A,(_gca + 0x3)', 'ld IZL,A'] + ext
        elif t == 'i':                                    # HL
            body = ['ld L,(_gca + 0x3)'] + ext
        else:                                             # XHL
            body = ['ld A,(_gca + 0x3)', 'ld L,A'] + ext
        return body + (['sra 0x3,%s' % R] if i == 's' else [])
    src = {'g': g, 'e': ELEM[t], 'a': g, 'k': '0x9'}[i]
    return ['ld %s,%s' % (R, src)] + (['inc 0x5,%s' % R] if i == 'a' else [])


def helper(Z, base_de=False):
    """if (gl != 0) *gpl = gla[7] % gl;"""
    e7 = '(XDE+0x1c)' if base_de else '(_gla + 0x1c)'
    if Z.opt:
        return ['ld XBC,(_gl)', 'or XBC,XBC', 'j eq,L1', 'ld XIZ,(_gpl)', 'ld XWA,%s' % e7, 'cal C9H_remls',
                'ld (XIZ),XHL', 'L1:']
    return ['ld XWA,(_gl)', 'or XWA,XWA', 'j eq,L1', 'ld XIZ,(_gpl)', 'ld XBC,(_gl)', 'ld XWA,%s' % e7,
            'cal C9H_remls', 'ld (XIZ),XHL', 'L1:']


def use(t, u, R):
    """the use of t held in register R: a `g = g + t` (`gpi = t`), r `return t`"""
    if u == 'r':
        return [] if R == REGS[t][1] else ['ld %s,%s' % (REGS[t][1], R)]
    g = GLOB[t]
    if t == 'p':
        return ['ld (%s),%s' % (g, R)]
    if t == 'c' and R != 'A':
        return ['ld A,%s' % R, 'add (%s),A' % g]
    return ['add (%s),%s' % (g, R)]


def predict(name, Z):
    _, t, i, m, u = name.split('_')
    acc, ret, home, push = REGS[t]
    dec = ['decw 0x1,(_gu2)']
    call = ['cal %sv0' % ('.' if Z.xr else '_')]
    if Z.opt and i == 'k':                                # -O: the constant 9 is propagated, t never exists
        imm = {'i': ['addw (_gi),0x9'], 'c': ['addb (_gc),0x9'], 'l': ['lda XWA,0x9', 'add (_gl2),XWA']}[t] \
            if u == 'a' else [{'i': 'ld HL,0x9', 'c': 'ld L,0x9', 'l': 'lda XHL,0x9'}[t]]
        if m == 'h':
            return ['push XIZ'] + dec + helper(Z) + imm + ['pop XIZ', 'ret']
        return dec + (call if m == 'v' else []) + imm + ['ret']
    if m == 'h':                                          # t in a frame slot across the helper
        sz = 4 if t in 'lp' else 2
        slot = S(4)
        if Z.opt and t == 'l' and i == 'e':               # -O: gla[3] and gla[7] share the array's address
            return ['dec 0x8,XSP', 'push XIZ', 'lda XWA,_gla', 'ld (XSP+0x8),XWA', 'ld XDE,(XSP+0x8)',
                    'ld XWA,(XDE+0xc)', 'ld %s,XWA' % slot] + dec + helper(Z, True) + \
                (['ld XWA,%s' % slot] + use(t, u, 'XWA') if u == 'a' else ['ld XHL,%s' % slot]) + \
                ['pop XIZ', 'inc 0x8,XSP', 'ret']
        if i == 'k':
            init = ['ld XWA,0x9', 'ld %s,XWA' % slot] if t == 'l' else ['ld%s %s,0x9' % ('w' if t == 'i' else 'b', slot)]
        elif i == 's' and t in 'il':                      # the shift is done through the slot
            init = value(t, 'c', acc, Z) + ['ld %s,%s' % (slot, acc), 'ld %s,%s' % (acc, slot), 'sra 0x3,%s' % acc,
                                            'ld %s,%s' % (slot, acc)]
        elif i == 'a' and t == 'l':                       # so is the long sum
            init = ['ld XWA,(_gl2)', 'ld %s,XWA' % slot, 'ld XWA,0x5', 'add %s,XWA' % slot]
        else:
            r = 'W' if (t == 'c' and u == 'r' and i in 'sa') else acc
            init = value(t, i, r, Z) + ['ld %s,%s' % (slot, r)]
        tail = ['ld %s,%s' % (acc, slot)] + use(t, u, acc) if u == 'a' else ['ld %s,%s' % (ret, slot)]
        return ['dec %s,XSP' % h(sz), 'push XIZ'] + init + dec + helper(Z) + tail + ['pop XIZ', 'inc %s,XSP' % h(sz), 'ret']
    if m == 'v':                                          # t in a callee-saved register across the call
        return ['push ' + push] + value(t, i, home, Z) + dec + call + use(t, u, home) + ['pop ' + push, 'ret']
    if u == 'r':
        if Z.opt and t == 'l' and i in 'cs':              # -O: formed in XWA, moved to XHL at the end
            return value(t, i, 'XWA', Z) + dec + ['ld XHL,XWA', 'ret']
        return value(t, i, ret, Z) + dec + ['ret']
    return value(t, i, acc, Z) + dec + use(t, u, acc) + ['ret']


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


PROBE = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/lsl.c'
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-13-16-micro-lsl/out/v423/%s/probes/lsl.asm'


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
