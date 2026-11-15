#!/usr/bin/env python3
"""loc0_ast.py -- the cc900 oracle's code for probe loc0.c (corpus/probes/loc0.c, oracle run 2026-11-10-14-micro-loc0):
where V4.23 keeps a local with an initialiser, at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None      set: none O3XS Xr O3XSXr
    python3 loc0_ast.py --check [SET ...] [--show N] [--only REGEX]

The function is `T t = INIT; [MID;] USE;` with one local t.  Its home (the register that keeps t from the
initialisation to the last use) is decided by rules from the AST: what INIT is (a load, a computation, a call),
what MID does (nothing, a store of a global, a call, a store through a pointer) and how t is used (a call argument,
a store, an operand, both).  The rules are in loc0-FAMILIES.md beside this file."""
HOME_ = __import__('os').path.expanduser('~/')
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


# --------------------------------------------------------------------------------------------- types

def tl(ty):
    """c uc i u l ul p (char *) pi (int *); None otherwise"""
    if ty is None:
        return None
    if ty.kind == 'int':
        return {(1, True): 'c', (1, False): 'uc', (2, True): 'i', (2, False): 'u', (4, True): 'l',
                (4, False): 'ul'}.get((ty.size, ty.signed))
    if ty.kind == 'ptr' and ty.base is not None and ty.base.kind == 'int':
        return {1: 'p', 2: 'pi'}.get(ty.base.size) if ty.base.signed else None
    return None


W = {'c': 1, 'uc': 1, 'i': 2, 'u': 2, 'l': 4, 'ul': 4, 'p': 4, 'pi': 4}
SIGNED = {'c': True, 'uc': False}
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L', 'IZ': 'QIZH'}


def rw(p, w):
    if w == 1:
        return LOW[p]
    return p if w == 2 else 'X' + p


def hx(v):
    return '0x%x' % v


def symoff(sym, off):
    return sym if not off else '%s + %s' % (sym, hx(off))


# --------------------------------------------------------------------------------------------- classification

def unc(n):
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    return n


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def gmem(n):
    """a read of a global scalar or of a global array element at a constant index -> (memory operand, kind G/E)"""
    n = unc(n)
    need(n.k == 'load')
    x = cg.strip(n.e)
    if x.k == 'var' and x.decl.kind == 'global':
        return '(_%s)' % x.decl.name, 'G'
    if x.k == 'index':
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array')
        k = cg.fold(unc(x.idx))
        need(k.k == 'const' and k.value is not None)
        return '(%s)' % symoff('_' + b.decl.name, k.value * n.ty.size), 'E'
    raise Decline()


def const_of(n):
    c = cg.fold(unc(n))
    return c.value if c.k == 'const' else None


def global_of(n):
    """a global variable as an lvalue -> its name"""
    d = var_of(n)
    need(d is not None and d.kind == 'global')
    return '_' + d.name


class Init:
    """G / E a load (mem); B a computation (op, a, b: memory operands or a constant); R a call (fn)"""

    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)


def classify_init(n, t):
    x = cg.strip(n)
    if x.k == 'call':
        fn = cg.strip(x.fn)
        need(fn.k == 'var' and fn.decl.kind == 'func' and not x.args and tl(x.ty) == t)
        CALLEES.append(fn.decl)
        return Init('R', fn=fn.decl.name)
    if x.k == 'load' and tl(x.ty) == t:
        mem, k = gmem(x)
        return Init(k, mem=mem)
    if x.k == 'cast' and x.explicit and tl(x.ty) == t and W[t] == 1:
        x = cg.strip(x.e)
    elif t in ('c', 'uc'):
        raise Decline()
    x = cg.strip(x)
    need(x.k == 'bin' and x.op in ('+', '-', '>>'))
    a = unc(x.l)
    need(a.k == 'load' and tl(a.ty) == t)
    amem, _ = gmem(a)
    k = const_of(x.r)
    if k is not None:
        if t in ('p', 'pi'):
            need(x.op == '+')
            k *= W['c'] if t == 'p' else 2
        return Init('B', op=x.op, a=amem, kc=k, b=None)
    b = unc(x.r)
    need(b.k == 'load' and tl(b.ty) == t and x.op == '+')
    return Init('B', op='+', a=amem, b=gmem(b)[0], kc=None)


class Use:
    """a: call f(t); s: store to a global; e: store of t + operand (pointers: t + k) to a global; d: s then a"""

    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)


def is_t(n, t_decl):
    n = unc(n)
    return n.k == 'load' and var_of(n.e) is t_decl


def arg_call(st, t_decl):
    if st.k != 'expr':
        return None
    e = cg.strip(st.e)
    if e.k == 'call' and len(e.args) == 1 and is_t(e.args[0], t_decl):
        fn = cg.strip(e.fn)
        if fn.k == 'var' and fn.decl.kind == 'func':
            CALLEES.append(fn.decl)
            return fn.decl.name
    return None


def store(st, t_decl, t):
    """`g = t` -> ('s', g); `g = (T)(t + h)` / `g = t + k` -> ('e', g, operand)"""
    if st.k != 'expr':
        return None
    e = cg.strip(st.e)
    if not (e.k == 'bin' and e.op == '=' and tl(e.l.ty) == t):
        return None
    if var_of(e.l) is None or var_of(e.l).kind != 'global':
        return None
    g = global_of(e.l)
    r = cg.strip(e.r)
    if is_t(r, t_decl):
        return ('s', g, None)
    if r.k == 'cast' and r.explicit and W[t] == 1:
        r = cg.strip(r.e)
    if r.k == 'bin' and r.op == '+' and is_t(r.l, t_decl):
        k = const_of(r.r)
        if k is not None and t in ('p', 'pi'):
            return ('e', g, k * (1 if t == 'p' else 2))
        if k is None and t not in ('p', 'pi'):
            return ('e', g, gmem(r.r)[0])
    return None


# the computed initialisers the probe has: (type, operator, second operand a global G or a constant K)
B_SHAPES = {('c', '+', 'G'), ('uc', '+', 'K'), ('i', '+', 'G'), ('u', '-', 'K'), ('l', '+', 'G'), ('ul', '>>', 'K'),
            ('p', '+', 'K'), ('pi', '+', 'K')}


def cdecl_mismatch(fn_decl, xr):
    """a callee whose convention is not the set's (an explicit __cdecl under -Xr, __adecl without it)"""
    sp = getattr(fn_decl.ty, 'spell', '') or ''
    return ('tlcs900_cdecl' in sp) if xr else ('tlcs900_adecl' in sp)


CALLEES = []


def classify(f):
    del CALLEES[:]
    need(not f.params and f.ret is not None and f.ret.kind == 'void')
    st = cg.flat(f.body)
    need(len(st) >= 2 and st[0].k == 'decl' and st[0].init is not None)
    d = st[0].var
    t = tl(d.ty)
    need(t is not None)
    init = classify_init(st[0].init, t)
    rest = st[1:]
    mid = ('0',)
    if len(rest) >= 2 and store(rest[0], d, t) is None and arg_call(rest[0], d) is None:
        m = rest[0]
        need(m.k == 'expr')
        e = cg.strip(m.e)
        if e.k == 'call' and not e.args:
            fn = cg.strip(e.fn)
            need(fn.k == 'var' and fn.decl.kind == 'func')
            CALLEES.append(fn.decl)
            mid = ('c', fn.decl.name)
        elif e.k == 'bin' and e.op == '=' and cg.strip(e.l).k == 'deref':
            p = unc(cg.strip(e.l).e)
            need(p.k == 'load' and var_of(p.e) is not None and var_of(p.e).kind == 'global')
            need(tl(e.l.ty) in ('c', 'uc') and const_of(e.r) is not None)
            mid = ('s', '_' + var_of(p.e).name, const_of(e.r))
        elif e.k == 'bin' and e.op == '=' and tl(e.l.ty) == 'i':
            src = unc(e.r)
            need(src.k == 'load' and tl(src.ty) == 'i')
            mid = ('g', global_of(e.l), gmem(src)[0])
        else:
            raise Decline()
        rest = rest[1:]
    if len(rest) == 2:
        s = store(rest[0], d, t)
        a = arg_call(rest[1], d)
        need(s is not None and s[0] == 's' and a is not None)
        use = Use('d', g=s[1], fn=a)
    else:
        need(len(rest) == 1)
        a = arg_call(rest[0], d)
        if a is not None:
            use = Use('a', fn=a)
        else:
            s = store(rest[0], d, t)
            need(s is not None)
            use = Use(s[0], g=s[1], x=s[2])
    return t, init, mid, use


# --------------------------------------------------------------------------------------------- code

def shared(init):
    """the global a computed initialiser reads as its second operand (memory operand), or None"""
    return init.b if init.k == 'B' and init.b is not None else None


def forwarded(init, mid, use, s):
    """-O: MID stores the global the initialiser read and the use reads it again: the use takes the stored
    register (int: t = gi + hi; hi = hj; hi2 = t + hi)"""
    g2 = shared(init)
    return s.startswith('O3') and g2 is not None and mid[0] == 'g' and '(%s)' % mid[1] == g2 and use.k == 'e' \
        and use.x == g2


def preloaded(init, mid, use, s):
    """-O: the initialiser's second global is read into a register of its own first: when the use reads it again
    with nothing between (t = gi + hi; hi2 = t + hi), or when MID overwrites it and t then goes to a call"""
    g2 = shared(init)
    if not s.startswith('O3') or g2 is None:
        return False
    if mid[0] == '0' and use.k == 'e' and use.x == g2:
        return True
    return mid[0] == 'g' and '(%s)' % mid[1] == g2 and use.k in 'ad'


def home(t, init, mid, use, s):
    """the register pair that keeps t"""
    if mid[0] == 'c':
        return 'IZ'                                       # across a call: the callee-saved IZ (QIZH, XIZ)
    if s == 'O3XSXr' and use.k in 'ad' and W[t] >= 2:
        return 'WA'                                       # -O -Xr: t lives in the argument register it goes to
    if init.k == 'R':
        return 'HL'                                       # a call's result stays where it arrives
    if mid[0] == '0' or forwarded(init, mid, use, s):
        return 'WA'
    return 'BC'


def gen(f, s):
    t, init, mid, use = classify(f)
    xr = s.endswith('Xr')
    if init.k == 'B':
        need((t, init.op, 'K' if init.b is None else 'G') in B_SHAPES)
        need(init.op != '-' or init.kc == 1)
    for d in CALLEES:
        need(not cdecl_mismatch(d, xr))
    opt = s.startswith('O3')
    w = W[t]
    fname = lambda n: ('.' if xr else '_') + n
    H = home(t, init, mid, use, s)
    S = 'BC' if H == 'WA' and mid[0] in 'gs' else 'WA'      # the scratch pair of MID
    Hw = rw(H, w)
    out = []
    T = 'BC' if H == 'WA' else 'WA'                       # -O: the register of a preloaded global
    pre = preloaded(init, mid, use, s)
    ux = getattr(use, 'x', None)
    g2 = shared(init)
    if pre:
        out.append('ld %s,%s' % (rw(T, w), g2))
        init.b = rw(T, w)
        if ux == g2:
            use.x = rw(T, w)
    elif forwarded(init, mid, use, s):
        use.x = rw(S, w)
    # the initialisation
    if init.k in 'GE':
        if w == 1 and H == 'IZ':
            out += ['ld A,%s' % init.mem, 'ld QIZH,A']
        else:
            out += ['ld %s,%s' % (Hw, init.mem)]
    elif init.k == 'B':
        opnd = init.b if init.b is not None else hx(init.kc)
        if w == 1:
            if opt and H != 'IZ':
                out += ['ld %s,%s' % (Hw, init.a), 'add %s,%s' % (Hw, opnd)]
            else:
                out += ['ld A,%s' % init.a, 'add A,%s' % opnd] + ([] if H == 'WA' else ['ld %s,A' % Hw])
        elif t in ('p', 'pi'):
            if H == 'WA':
                out += ['ld XWA,%s' % init.a, 'inc %s,XWA' % hx(init.kc)]
            elif opt:
                out += ['ld XWA,%s' % init.a, 'lda %s,XWA+%s' % (Hw, hx(init.kc))]
            else:
                out += ['ld XWA,%s' % init.a, 'inc %s,XWA' % hx(init.kc), 'ld %s,XWA' % Hw]
        else:
            out += ['ld %s,%s' % (Hw, init.a)]
            if init.op == '+':
                out += ['add %s,%s' % (Hw, opnd)]
            elif init.op == '-':
                need(init.kc == 1)
                out += ['dec 0x1,%s' % Hw]
            else:
                out += ['%s %s,%s' % ('srl' if t in ('u', 'ul') else 'sra', hx(init.kc), Hw)]
    else:
        out += ['cal %s' % fname(init.fn)]
        if H != 'HL':
            out += ['ld %s,%s' % (Hw, rw('HL', w))]
    # between
    if mid[0] == 'g':
        out += ['ld %s,%s' % (S, mid[2]), 'ld (%s),%s' % (mid[1], S)]
    elif mid[0] == 'c':
        out += ['cal %s' % fname(mid[1])]
    elif mid[0] == 's':
        out += ['ld X%s,(%s)' % (S, mid[1]), 'ldb (X%s),%s' % (S, hx(mid[2]))]
    # the use
    tail = []

    def val8():
        """t's byte where an instruction can read it (QIZH only through A)"""
        if H == 'IZ':
            out.append('ld A,QIZH')
            return 'A'
        return Hw

    def st(g):
        out.append('ld (%s),%s' % (g, val8() if w == 1 else Hw))

    def arg(fn):
        if w == 1:
            ext = 'exts' if SIGNED[t] else 'extz'
            if opt and H in ('BC', 'HL'):                 # -O: extended where it is
                out.extend(['%s %s' % (ext, H)] + (['ld WA,%s' % H] if xr else ['push %s' % H]))
            else:
                v = val8()
                if v != 'A':
                    out.append('ld A,%s' % v)
                out.append('%s WA' % ext)
                if not xr:
                    out.append('push WA')
        elif xr:
            if H != 'WA':
                out.append('ld %s,%s' % (rw('WA', w), Hw))
        else:
            out.append('push %s' % Hw)
        if xr:
            if H == 'IZ':
                out.append('cal %s' % fname(fn))
            else:
                out.append('j %s' % fname(fn))
                return
        else:
            out.extend(['cal %s' % fname(fn), 'inc %s,XSP' % hx(2 if w <= 2 else 4)])
        tail.append('ret')

    if use.k == 'a':
        arg(use.fn)
    elif use.k == 's':
        st(use.g)
        tail.append('ret')
    elif use.k == 'd':
        st(use.g)
        arg(use.fn)
    else:
        if t in ('p', 'pi'):
            if H == 'WA':
                out += ['inc %s,XWA' % hx(use.x)]
            else:
                out += ['lda XWA,%s+%s' % (Hw, hx(use.x))]
            out += ['ld (%s),XWA' % use.g]
        elif H in ('WA', 'HL') or (opt and H == 'BC'):
            out += ['add %s,%s' % (Hw, use.x), 'ld (%s),%s' % (use.g, Hw)]
        else:
            acc = rw('WA', w)
            if w == 1 and H == 'IZ':
                val8()                                    # ld A,QIZH
            else:
                out.append('ld %s,%s' % (acc, Hw))
            out += ['add %s,%s' % (acc, use.x), 'ld (%s),%s' % (use.g, acc)]
        tail.append('ret')
    if H == 'IZ':
        q = {1: 'QIZ', 2: 'IZ', 4: 'XIZ'}[w]
        out = ['push %s' % q] + out + ['pop %s' % q]
    return out + tail


def fmt(lines):
    out = []
    for l in lines:
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return fmt(gen(f, set))
    except Exception:
        return None


# --------------------------------------------------------------------------------------------- check

RUN = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-14-micro-loc0/out/v423/%s/probes/loc0.asm'
SRC = HOME_ + 'compartilhado/technics-roms-disasm/scripts/analysis/cc900/corpus/probes/loc0.c'


def check(s, show=0, only=None, src=SRC, run=RUN):
    import frontend
    import listing
    want = listing.split(open(run % s, encoding='latin-1').read())
    unit = frontend.load(src, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        W_ = [l for l in want.get(('.' if s.endswith('Xr') else '_') + f.name, []) if 'section' not in l][1:]
        got = whole(f, s)
        if got is None:
            dec += 1
            continue
        if listing.normalise_labels(got) == listing.normalise_labels(W_):
            ok += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('---- %s' % f.name)
                print('   want: ' + '; '.join(x.strip().replace('\t', ' ') for x in W_))
                print('   got:  ' + '; '.join(x.strip().replace('\t', ' ') for x in got))
    print('%-7s exact %4d  wrong %4d  declined %4d' % (s, ok, wrong, dec))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        for s in [x for x in a[1:] if x in SETS] or list(SETS):
            check(s, show, only)
