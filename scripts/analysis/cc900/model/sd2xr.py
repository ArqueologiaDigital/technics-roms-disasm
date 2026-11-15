"""L = A / B and L = A % B under -Xr without -O, for a function whose whole body is that one statement and whose
parameters are (int c, T d, T e) with T the statement's type, over probe stdiv2's kinds (corpus/probes/stdiv2.c, run 2026-11-13-1-micro-stdiv2, the Xr
listing): int, char and unsigned long; L is P *gp, D gps->m, X ga[c] (c the first parameter, WA), E ga[k], M gs.m;
A is S (L itself), D, M, E or R (the second parameter, BC); B is S, G, D, M, E, R (the third parameter, DE) or K.

The code is the predictor sd2xr_predict.py (research-scratch tabulation/stdiv2xr-predict.py, 1,020 / 1,020 on the
probe), which names the probe's globals (g* for L, h* for A, k* for B); the probe's names, static member offsets and
constant element offsets are replaced by the real operands'.  A member through a pointer keeps the probe's offsets
(int 2, char 0, unsigned long 4); a constant must not be a power of two.  whole(f) -> lines after the label, or None."""
import re
import codegen as cg
import sd2xr_predict as P

SD2XR = True
OFF = {'i': 2, 'c': 0, 'n': 4}
ESZ = {'i': 2, 'c': 1, 'n': 4}
EIDX = {'g': 3, 'h': 2, 'k': 5}


def tkind(ty):
    if ty is None or ty.kind != 'int': return None
    return {(2, True): 'i', (4, False): 'n', (1, True): 'c'}.get((ty.size, ty.signed))


def whole(f, opt='none', cdecl=False):
    if not SD2XR: return None
    if len(f.params) != 3 or tkind(f.params[0].ty) != 'i': return None
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
    if tkind(pd.ty) != t or tkind(pe.ty) != t: return None   # (the probe: (int c, T d, T e) for the statement's type T)
    hx = cg.hx
    def unc(n):
        n = cg.strip(n)
        while n.k == 'cast' and n.kind == 'IntegralCast': n = cg.strip(n.e)
        return n
    def var_of(n):
        n = cg.strip(n)
        return n.decl if n.k == 'var' else None
    def gptr(x):                                           # a global pointer's load -> its decl
        x = cg.strip(x)
        if x.k == 'load' and var_of(x.e) is not None and var_of(x.e).kind == 'global': return var_of(x.e)
        return None
    def arr(b):
        b = cg.strip(b)
        if b.k == 'decay': b = cg.strip(b.e)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array': return b.decl
        return None
    def symoff(sym, off): return sym if not off else '%s + %s' % (sym, hx(off))
    def obj(n, role, prm):
        """(kind, key, {canonical: real}) of an lvalue node n for role g / h / k; key identifies the object"""
        n = cg.strip(n)
        if n.k == 'deref' and gptr(n.e) is not None and role == 'g':
            d = gptr(n.e); return 'P', ('P', d.name), {'_g%sp' % t: '_' + d.name}
        if n.k == 'member' and n.arrow and gptr(n.base) is not None and cg.member_offset(n) == OFF[t]:
            d = gptr(n.base); return 'D', ('D', d.name), {'_%sps' % role: '_' + d.name}
        if n.k == 'member' and not n.arrow and var_of(n.base) is not None and var_of(n.base).kind == 'global':
            d = var_of(n.base); o = cg.member_offset(n)
            return 'M', ('M', d.name, o), {symoff('_%ss' % role, OFF[t]): symoff('_' + d.name, o)}
        if n.k == 'index' and arr(n.base) is not None:
            a = arr(n.base); i = unc(n.idx); c = cg.fold(i)
            if c.k == 'const' and c.value is not None and c.value >= 0:
                return 'E', ('E', a.name, c.value), {symoff('_%s%sa' % (role, t), EIDX[role] * ESZ[t]): symoff('_' + a.name, c.value * ESZ[t])}
            if role == 'g' and i.k == 'load' and var_of(i.e) is pc:
                return 'X', ('X', a.name), {'_g%sa' % t: '_' + a.name}
        return None
    L = obj(lv, 'g', None)
    if L is None: return None
    def operand(n, role, prm):
        x = unc(n)
        c = cg.fold(x)
        if role == 'k' and c.k == 'const' and c.value is not None:
            v = c.value
            if v <= 0 or v & (v - 1) == 0 or v > (0x7f if t == 'c' else 0x7fff): return None
            return 'K', {'0x7': hx(v)}
        if x.k == 'load' and var_of(x.e) is prm: return 'R', {}   # (the int parameter, under a cast for a long)
        if x.k != 'load' or tkind(x.ty) != t: return None
        y = cg.strip(x.e)
        so = obj(y, 'g', prm)                              # the destination itself (an element at c included)
        if so is not None and so[1] == L[1]: return 'S', {}
        if role == 'k' and y.k == 'var' and y.decl.kind == 'global': return 'G', {'_k%s' % t: '_' + y.decl.name}
        o = obj(y, role, prm) if y.k != 'deref' else (obj(y, 'g', prm) if True else None)
        if o is None: return None
        if o[1] == L[1]: return 'S', {}
        if y.k == 'deref': return None                     # (another pointer's target: not in the probe)
        if o[0] == 'X': return None
        return o[0], o[2]
    A = operand(rv.l, 'h', pd); B = operand(rv.r, 'k', pe)
    if A is None or B is None: return None
    if A[0] not in 'SDMER' or B[0] not in 'SGDMERK': return None
    sub = dict(L[2]); sub.update(A[1]); sub.update(B[1])
    name = '.sd2_%s_%s_%s%s%s' % (t, 'd' if rv.op == '/' else 'm', L[0], A[0], B[0])
    try: lines = P.predict(name, 'O3XS' if cdecl else ('O3XSXr' if opt != 'none' else 'Xr'))
    except Exception: return None
    if not lines: return None
    out = []
    keys = sorted(sub, key=lambda k_: -len(k_))
    for l in lines:
        for k_ in keys:
            v_ = sub[k_]
            if k_.startswith('0x'): l = re.sub(r'(?<![0-9a-fx+])%s(?![0-9a-f])' % re.escape(k_), v_, l)
            else: l = re.sub(r'(?<![\w])%s(?![\w])' % re.escape(k_), v_, l)
        op, _, args = l.partition(' ')
        out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out
