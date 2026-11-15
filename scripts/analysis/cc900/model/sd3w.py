#!/usr/bin/env python3
"""sd3w.py -- probe stdiv3's shapes as a whole-function override for the cc900 model, decided from the AST.

    whole(f, set) -> the function's lines after its label ('\top\targs', '\top', labels 'Ln:'), or None
    python3 sd3w.py --check SET [--show N]     score whole() over the probe against SET's oracle listing

f is a Function from the model's front end (frontend.load(path, [], [], adecl=SET.endswith('Xr'))); SET is none,
O3XS, Xr or O3XSXr.  The shapes (corpus/probes/stdiv3.c, run 2026-11-13-5-micro-stdiv3):

    void f(int c, T d, unsigned int e) { [char t = jc; [f0();]] | [int i; for (i = 0; i < 4; i++)]  L = A op B; }

with T int, unsigned int or char (the statement's type; char computed in int), op `/` or `%`, and the index I of
every element at a variable index the same one of: c (p), e (u), t kept across the call (q), t (r), i (l).
L: G a global, D gp->m, E ga[k], X ga[I], P *gp.  A: G a global, K a constant, E ha[k], D hp->m, R the parameter d,
X ha[I].  B: X ka[I]; G a global or K a constant only when A is X.  The statement is classified into the probe's
name, sd3w_predict.py (research-scratch tabulation/stdiv3-predict.py, 1,200 / 1,200 at every set) gives the code for the probe's own globals, and the probe's
names, element offsets and constants are replaced by the real ones.

Declined (None) outside those shapes, never guessed: other parameter lists or locals, other loop bounds or
increments, a member offset other than the probe's (int +2, unsigned +4, char +0), a constant element index of 0
or past the array, a divisor constant that is a power of two or outside 3..0x7fff (char 3..0x7f), a dividend
constant outside 8..0x7fff (char 8..0x7f), a global used in two roles, an index variable used for anything but
the index, a callee spelt __cdecl in an -Xr file.
"""
import os
import re
import sys

import codegen as cg
import sd3w_predict as P

HERE = os.path.dirname(os.path.abspath(__file__))
PROBE = 'corpus/probes/stdiv3.c'                  # --check runs from scripts/analysis/cc900, as score.py does
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-5-micro-stdiv3/out/v423/%s/probes/stdiv3.asm')

STDIV3 = True
SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
MOFF = {'i': 2, 'u': 4, 'c': 0}                 # the probe's member offsets (struct sv: c +0, i +2, u +4)
ESZ = {'i': 2, 'u': 2, 'c': 1}
EIDX = {'g': 3, 'h': 2}                          # the probe's constant element indexes (L ga[3], A ha[2])


def tkind(ty):
    if ty is None or ty.kind != 'int':
        return None
    return {(2, True): 'i', (2, False): 'u', (1, True): 'c'}.get((ty.size, ty.signed))


def unc(n):
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    return n


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def loaded(n):
    """the decl of `load(var)`, else None"""
    n = cg.strip(n)
    return var_of(n.e) if n.k == 'load' else None


def gvar(d):
    return d is not None and d.kind == 'global'


def symoff(sym, off):
    return sym if not off else '%s + %s' % (sym, cg.hx(off))


def is_const(n, t=None):
    c = cg.fold(unc(n))
    return c.value if c.k == 'const' and c.value is not None else None


def classify(f, adecl):
    """(name, substitutions) of f in probe stdiv3's terms, or None"""
    if len(f.params) != 3:
        return None
    pc, pd, pe = f.params
    if tkind(pc.ty) != 'i' or tkind(pe.ty) != 'u':
        return None
    body = cg.flat(f.body)
    locals_ = [d for d in f.decls if d.kind != 'param']
    if any(d.kind != 'local' for d in locals_):
        return None
    sub = {}
    globs = []                                   # every global the statement names, to refuse one in two roles
    # ---- the frame: p / u (one statement), r / q (char t = jc; [f0();]), l (int i; for (i = 0; i < 4; i++))
    ivar = None
    if len(body) == 1 and body[0].k == 'expr' and not locals_:
        st, kind = body[0], 'pu'
    elif len(body) in (2, 3) and body[0].k == 'decl' and len(locals_) == 1 and body[0].var is locals_[0] \
            and body[-1].k == 'expr':
        ivar = locals_[0]
        if tkind(ivar.ty) != 'c' or ivar.addr_taken or body[0].init is None:
            return None
        jc = loaded(body[0].init)
        if not gvar(jc) or tkind(jc.ty) != 'c':
            return None
        sub['_jc'] = '_' + jc.name
        globs.append(jc.name)
        if len(body) == 3:
            call = cg.strip(body[1].e) if body[1].k == 'expr' else None
            if call is None or call.k != 'call' or call.args:
                return None
            fd = var_of(call.fn)
            if fd is None or fd.kind != 'func' or fd.ty is None or fd.ty.kind != 'func' or \
                    fd.ty.ret is None or fd.ty.ret.kind != 'void' or '(void)' not in fd.ty.spell:
                return None
            if adecl and 'tlcs900_cdecl' in fd.ty.spell:
                return None
            sub['_f0'] = '_' + fd.name
            sub['.f0'] = '.' + fd.name
            kind = 'q'
        else:
            kind = 'r'
        st = body[-1]
    elif len(body) == 2 and body[0].k == 'decl' and body[0].init is None and len(locals_) == 1 and \
            body[0].var is locals_[0] and body[1].k == 'for':
        ivar = locals_[0]
        lp = body[1]
        if tkind(ivar.ty) != 'i' or ivar.addr_taken:
            return None
        ini = lp.init
        if ini is None or ini.k != 'expr':
            return None
        ini = cg.strip(ini.e)
        if ini.k != 'bin' or ini.op != '=' or var_of(ini.l) is not ivar or is_const(ini.r) != 0:
            return None
        cnd = cg.strip(lp.cond) if lp.cond is not None else None
        if cnd is None or cnd.k != 'bin' or cnd.op != '<' or loaded(cnd.l) is not ivar or is_const(cnd.r) != 4:
            return None
        inc = cg.strip(lp.inc) if lp.inc is not None else None
        if inc is None or inc.k != 'incdec' or inc.op != '++' or not inc.post or var_of(inc.e) is not ivar:
            return None
        lb = cg.flat(lp.body)
        if len(lb) != 1 or lb[0].k != 'expr':
            return None
        st, kind = lb[0], 'l'
    else:
        return None
    # ---- the statement
    e = cg.strip(st.e)
    if e.k != 'bin' or e.op != '=':
        return None
    lv = cg.strip(e.l)
    t = tkind(lv.ty)
    if t is None:
        return None
    if tkind(pd.ty) != t:
        return None
    rv = cg.strip(e.r)
    if t == 'c':
        if rv.k != 'cast' or rv.kind != 'IntegralCast' or rv.explicit:
            return None
        rv = cg.strip(rv.e)
    if rv.k != 'bin' or rv.op not in ('/', '%') or tkind(rv.ty) != ('i' if t == 'c' else t):
        return None
    idx_used = []                                # the index expression of every element at a variable index

    def arr(b, role):
        b = cg.strip(b)
        if b.k == 'decay':
            b = cg.strip(b.e)
        if b.k == 'var' and gvar(b.decl) and b.decl.ty.kind == 'array' and tkind(b.decl.ty.base) == t:
            return b.decl
        return None

    def gptr(x, pointee):
        d = loaded(x)
        if gvar(d) and d.ty.kind == 'ptr' and d.ty.base is not None and pointee(d.ty.base):
            return d
        return None

    def obj(n, role):
        """(letter, {probe symbol: real}) of the object n for role g (L), h (A), k (B)"""
        n = cg.strip(n)
        if n.k == 'var' and gvar(n.decl) and tkind(n.decl.ty) == t and role in 'gh':
            globs.append(n.decl.name)
            return 'G', {'_%s%s' % (role, t): '_' + n.decl.name}
        if n.k == 'var' and gvar(n.decl) and tkind(n.decl.ty) == t and role == 'k':
            globs.append(n.decl.name)
            return 'G', {'_k%s' % t: '_' + n.decl.name}
        if n.k == 'deref' and role == 'g':
            d = gptr(n.e, lambda b: tkind(b) == t)
            if d is None:
                return None
            globs.append(d.name)
            return 'P', {'_g%sp' % t: '_' + d.name}
        if n.k == 'member' and n.arrow and role in 'gh':
            d = gptr(n.base, lambda b: b.kind == 'struct')
            if d is None or tkind(n.ty) != t or cg.member_offset(n) != MOFF[t]:
                return None
            globs.append(d.name)
            return 'D', {'_%sps' % role: '_' + d.name}
        if n.k == 'index':
            a = arr(n.base, role)
            if a is None:
                return None
            k = is_const(n.idx)
            if k is not None:
                if role not in 'gh' or not (0 < k < a.ty.count):
                    return None
                globs.append(a.name)
                return 'E', {symoff('_%s%sa' % (role, t), EIDX[role] * ESZ[t]): symoff('_' + a.name, k * ESZ[t])}
            iv = loaded(n.idx)
            if iv is None or cg.strip(n.idx).ty is None:
                return None
            idx_used.append(iv)
            globs.append(a.name)
            return 'X', {'_%s%sa' % (role, t): '_' + a.name}
        return None

    L = obj(lv, 'g')
    if L is None:
        return None
    # dividend
    a = unc(rv.l)
    av = is_const(a)
    if av is not None and a.k == 'const':
        if not (8 <= av <= (0x7f if t == 'c' else 0x7fff)):
            return None
        A = 'K', {'0x64': cg.hx(av)}
    elif loaded(a) is pd:
        A = 'R', {}
    elif a.k == 'load':
        A = obj(a.e, 'h')
        if A is None or A[0] == 'P':
            return None
    else:
        return None
    # divisor
    b = unc(rv.r)
    bv = is_const(b)
    if bv is not None and b.k == 'const':
        if not (3 <= bv <= (0x7f if t == 'c' else 0x7fff)) or bv & (bv - 1) == 0:
            return None
        B = 'K', {'0x7': cg.hx(bv)}
    elif b.k == 'load':
        B = obj(b.e, 'k')
        if B is None or B[0] not in 'GX':
            return None
    else:
        return None
    if B[0] in 'GK' and A[0] != 'X':
        return None
    # ---- the index: one variable, the kind's own, used only as the index
    if not idx_used or any(v is not idx_used[0] for v in idx_used):
        return None
    iv = idx_used[0]
    if kind == 'pu':
        I = 'p' if iv is pc else 'u' if iv is pe else None
    else:
        I = kind if iv is ivar else None
    if I is None:
        return None
    if len(set(globs)) != len(globs):
        return None
    for s_ in (L[1], A[1], B[1]):
        sub.update(s_)
    name = 'sd3_%s_%s_%s_%s%s%s' % (t, 'd' if rv.op == '/' else 'm', I, L[0], A[0], B[0])
    return name, sub


def whole(f, set='none'):
    if not STDIV3 or set not in SETS:
        return None
    try:
        r = classify(f, set.endswith('Xr'))
    except Exception:            # noqa  (an unexpected tree: not this probe's shape)
        return None
    if r is None:
        return None
    name, sub = r
    lines = P.predict(name, set)
    # one pass, longest key first, so that a real name equal to another probe name is never substituted twice
    syms = sorted((k_ for k_ in sub if not k_.startswith('0x')), key=lambda k_: -len(k_))
    nums = sorted((k_ for k_ in sub if k_.startswith('0x')), key=lambda k_: -len(k_))
    alts = []
    if syms:
        alts.append(r'(?<![\w.])(?:%s)(?!\w)' % '|'.join(map(re.escape, syms)))
    if nums:
        alts.append(r'(?<![0-9a-fx+])(?:%s)(?![0-9a-f])' % '|'.join(map(re.escape, nums)))
    pat = re.compile('|'.join(alts)) if alts else None
    out = []
    for l in lines:
        if pat is not None:
            l = pat.sub(lambda m: sub[m.group(0)], l)
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def check(set, show=0):
    import frontend
    import listing
    unit = frontend.load(PROBE, [], [], adecl=set.endswith('Xr'))
    want = listing.split(open(ORACLE % set, encoding='latin-1').read())
    exact = wrong = declined = 0
    shown = 0
    for f in unit.functions:
        got = whole(f, set)
        if got is None:
            declined += 1
            print('DECLINED', f.name)
            continue
        wl = want.get(('.' if set.endswith('Xr') else '_') + f.name, [])
        W = [l for l in wl if 'section' not in l and not re.fullmatch(r'[._]\w+:', l)]
        W, G = listing.normalise_labels(W), listing.normalise_labels(got)
        if W == G:
            exact += 1
        else:
            wrong += 1
            if shown < show:
                shown += 1
                print('WRONG', f.name)
                print('   exp: ' + ' ; '.join(x.strip().replace('\t', ' ') for x in W))
                print('   got: ' + ' ; '.join(x.strip().replace('\t', ' ') for x in G))
    print('set %-7s exact %d  wrong %d  declined %d  (of %d)' % (set, exact, wrong, declined, len(unit.functions)))
    return wrong


if __name__ == '__main__':
    a = sys.argv[1:]
    if len(a) >= 2 and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 20
        sys.exit(1 if check(a[1], show) else 0)
    print(__doc__)
