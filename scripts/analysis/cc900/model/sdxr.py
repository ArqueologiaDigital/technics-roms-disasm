"""L = A / B and L = A % B under -Xr without -O, for a function whose whole body is that one statement and whose
parameters are three ints (corpus/probes/stdiv.c, run 2026-11-12-5-micro-stdiv, the Xr and O3XSXr listings).

The code is the predictor sdxr_predict.py (research-scratch tabulation/stdivxr-predict.py, 750 / 750 on the probe),
which names the probe's own globals; here the statement is classified into the probe's kinds and the probe's names
are replaced by the real operands'.  The kinds (stdiv.c header): L is G a global, P *gp, D gps->m, X ga[c] with c the
first parameter (WA), Q gp[c]; A and B are G, P (*vp), X (va[d] with d the second parameter, BC; wa[e] with e the
third, DE) or K a constant.  Declined (None) outside those shapes: a member offset other than the probe's (int 2, long
4, char 0), a constant that is a power of two or out of range, parameters other than three ints.

whole(f) -> the function's lines after its label, or None."""
import re
import codegen as cg
import sdxr_predict as P

SDXR = True
MEMBER_OFF = {'i': 2, 'u': 2, 'l': 4, 'n': 4, 'c': 0}


def tkind(ty):
    if ty is None or ty.kind != 'int': return None
    return {(2, True): 'i', (2, False): 'u', (4, True): 'l', (4, False): 'n', (1, True): 'c'}.get((ty.size, ty.signed))


def whole(f, opt='none'):
    if not SDXR: return None
    if len(f.params) != 3 or any(tkind(p.ty) != 'i' for p in f.params): return None
    body = cg.flat(f.body)
    if len(body) != 1 or body[0].k != 'expr': return None
    e = cg.strip(body[0].e)
    if e.k != 'bin' or e.op != '=': return None
    lv = cg.strip(e.l); t = tkind(lv.ty)
    if t is None: return None
    rv = cg.strip(e.r)
    while rv.k == 'cast' and rv.kind == 'IntegralCast': rv = cg.strip(rv.e)
    if rv.k != 'bin' or rv.op not in ('/', '%'): return None
    pc, pd, pe = f.params
    sub = {}
    def var_of(n):
        n = cg.strip(n)
        return n.decl if n.k == 'var' else None
    def gname(d): return '_' + d.name
    def arr_of(b):                                         # a global array as an index base (var, or its decay)
        if b.k == 'decay': b = cg.strip(b.e)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array': return b.decl
        return None
    def lkind(n):
        n = cg.strip(n)
        if n.k == 'var' and n.decl.kind == 'global' and tkind(n.ty) == t:
            return 'G', {'_g%s' % t: gname(n.decl)}
        if n.k == 'deref':
            x = cg.strip(n.e)
            if x.k == 'load' and var_of(x.e) is not None and var_of(x.e).kind == 'global':
                return 'P', {'_g%sp' % t: gname(var_of(x.e))}
        if n.k == 'member' and n.arrow:
            x = cg.strip(n.base)
            if x.k == 'load' and var_of(x.e) is not None and var_of(x.e).kind == 'global' and \
                    cg.member_offset(n) == MEMBER_OFF[t]:
                return 'D', {'_gs%s' % ('u' if t in 'un' else 'i'): gname(var_of(x.e))}
        if n.k == 'index':
            i = cg.strip(n.idx)
            while i.k == 'cast' and i.kind == 'IntegralCast': i = cg.strip(i.e)
            if not (i.k == 'load' and var_of(i.e) is pc): return None
            b = cg.strip(n.base)
            ad = arr_of(b)
            if ad is not None: return 'X', {'_g%sa' % t: gname(ad)}
            if b.k == 'load' and var_of(b.e) is not None and var_of(b.e).kind == 'global':
                return 'Q', {'_g%sp' % t: gname(var_of(b.e))}
        return None
    def okind(n, pfx, prm, kval):
        n0 = cg.strip(n)
        while n0.k == 'cast' and n0.kind == 'IntegralCast': n0 = cg.strip(n0.e)
        c = cg.fold(n0)
        if c.k == 'const' and c.value is not None:
            v = c.value
            if v <= 0 or v & (v - 1) == 0 or v > (0x7f if t == 'c' else 0x7fff): return None
            return 'K', {kval: cg.hx(v)}
        if n0.k != 'load' or tkind(n0.ty) != t: return None
        x = cg.strip(n0.e)
        if x.k == 'var' and x.decl.kind == 'global':
            return 'G', {'_%s%s' % (pfx, t): gname(x.decl)}
        if x.k == 'deref':
            y = cg.strip(x.e)
            if y.k == 'load' and var_of(y.e) is not None and var_of(y.e).kind == 'global':
                return 'P', {'_%s%sp' % (pfx, t): gname(var_of(y.e))}
        if x.k == 'index':
            i = cg.strip(x.idx)
            while i.k == 'cast' and i.kind == 'IntegralCast': i = cg.strip(i.e)
            b = cg.strip(x.base); ad = arr_of(b)
            if i.k == 'load' and var_of(i.e) is prm and ad is not None:
                return 'X', {'_%s%sa' % (pfx, t): gname(ad)}
        return None
    lk = lkind(lv)
    ak = okind(rv.l, 'v', pd, '0x64'); bk = okind(rv.r, 'w', pe, '0x7')
    if lk is None or ak is None or bk is None: return None
    if ak[0] == 'K' and bk[0] == 'K': return None
    lnames = set(lk[1].values())                           # (the destination read again, L = L / B: not the probe's
    if lnames & set(ak[1].values()) or lnames & set(bk[1].values()): return None   #  shape, probe stdiv2's PS rows)
    if ak[0] == 'K' and bk[0] != 'K' and ak[1]['0x64'] == '0x7': return None
    for k_ in (lk, ak, bk): sub.update(k_[1])
    name = 'sd_%s_%s_%s%s%s' % (t, 'd' if rv.op == '/' else 'm', lk[0], ak[0], bk[0])
    try: lines = P.predict(name, 'O3XSXr' if opt != 'none' else 'Xr')
    except Exception: return None
    if lines is None: return None
    out = []
    for l in lines:
        for k_, v_ in sorted(sub.items(), key=lambda kv: -len(kv[0])):
            if k_.startswith('0x'): l = re.sub(r'(?<![0-9a-fx])%s(?![0-9a-f])' % re.escape(k_), v_, l)
            else: l = re.sub(r'(?<![\w])%s(?![\w])' % re.escape(k_), v_, l)
        op, _, args = l.partition(' ')
        out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out
