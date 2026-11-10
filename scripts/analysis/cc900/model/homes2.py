"""The homes2 rule: which int / pointer / long values live across a call cc900 V4.23 keeps in IZ / QIZ / XIZ, and
which it leaves in memory (a frame slot, or a cdecl parameter's stack arrival).

Ported from research-scratch sessions/2026-11-09_cc900-homes2 (rule.py, lin.py, params.json, README "The rule"),
a black-box fit to the oracle listings of corpus/probes/homes2a.c (run 2026-11-09-37), regkw.c (-35), the first
homes session's micro corpora and 50 functions of the 1997 library; held out on homes2b.c (run 2026-11-09-42).
codegen.plan_homes applies it behind the HOMES2 policy switch (POLICIES below); homes.py is the rule it replaces.

For one function and one option set (none / O3XS / Xr / O3XSXr):

1. Values: every int, pointer or long parameter and local, inner blocks included, that is not address-taken,
   static, floating or an aggregate.
2. Live interval, over quads (one operation each, in source order: an arithmetic or compare operator, a call with
   its arguments, a plain copy or constant assignment, an element or pointer read, a test of a plain value, a
   return): from the first write (a parameter: quad 0) to the last read; a value read in a loop before it is
   written there lives to the loop's end.  A backward goto makes a loop from its label to the goto.
3. Candidates: values whose interval strictly contains a call, real or runtime helper (floating point; long `*`
   `/` `%`, except `*` by a constant with at most three one bits).  Under -O3, `x = p` / `x = p + 0` with neither
   written again merges x into p; under cdecl -O3 a `for` counter read only by its own test and step makes the
   loop count the bound down (the bound takes the counter's references, the counter goes to a slot).
4. Score = weighted reads (call argument rA, test rT, return rR, update rU, other rX, the callee of an indirect
   call rF = 0; a loop test's reads count twice) + weighted writes (arithmetic wa = 2, call result wc, global or
   pointer load wg / wp, constant wk = 0), minus `ld` for a cdecl parameter (already in memory), plus `pa` for an
   adecl register parameter.  Priority = score / span ** ws.
5. Colouring (Chow style), highest priority first (none: candidate parameters first, pf).  A value needs score
   >= T1 for any register.  It takes IZ when no interfering value already holds IZ, else QIZ when its score >= T2
   (the cost of saving all of XIZ), else memory.  A long needs both halves free and takes XIZ.  A parameter is
   never homed in QIZ.  Interference = overlapping intervals, so a short inner-block local can share a half with
   values that are dead around it.
6. Halves: parameters take IZ.  Among the other 16-bit winners, an interfering pair is ordered by HKEYS: a call
   result goes to QIZ first; then (none, O3XS) the value that interferes with more values takes IZ (O3XSXr:
   fewer); Xr instead puts an arithmetic-defined value in QIZ; then the later-declared value takes IZ.
7. Memory: `mem` for a cdecl parameter, `slot` otherwise; `-` for a value that is no candidate.

The hidden result pointer of a function returning a double (`.sret`) is part of the fitted rule (20 of the
library's 21 double functions); in the model fpgen.needs_sret_home implements that part, and SRET_AS_VALUE
(default False) keeps it out of the colouring here so that the two cannot disagree.

Scores of the fitted rule (research-scratch README "Results"): exact home right on 657 / 752 (none), 744 / 961
(O3XS), 632 / 756 (Xr), 584 / 746 (O3XSXr) fitted values; held-out homes2b.c 181 / 236, 160 / 236, 171 / 232,
174 / 232; the 1997 library's variables 155 / 198 against homes.py's 163.

    predict(fn, setname, reg_params=None) -> {decl: 'IZ' | 'QIZ' | 'XIZ' | 'slot' | 'mem' | '-'}
    applies(policy, setname, r4_fired)     -> does the policy hand this function to homes2
"""
import functools
import homes
from homes import strip, kids

# ---- the policy switch (codegen.HOMES2 selects one; codegen reads the environment variable CC900_HOMES2) --------
POLICIES = {
    'off':      'homes.py (R3-set / R4) and codegen.plan_homes\'s first-fit fallback everywhere',
    'all':      'homes2 decides under every option set',
    'r4keep':   'homes2 everywhere except cdecl -O3 -XS with a 32-bit candidate, where homes.py\'s R4 stays',
    'noO3XS':   'homes2 under none, -Xr and -O3 -XS -Xr; cdecl -O3 -XS (the library\'s set) keeps homes.py',
    'noopt':    'homes2 under none and -Xr only',
    'fallback': 'homes2 only where homes.choose returns None (cdecl -O3 -XS without a 32-bit candidate)',
    'noloop':   'homes2 in functions without a loop (the rule\'s losses against homes.py are loop counters and '
                'accumulators: c_nested, rc_loop2-4, rh_loop*, sv_register), under every option set',
    'noloop-r4keep': 'noloop, and cdecl -O3 -XS with a 32-bit candidate keeps homes.py\'s R4',
    'fallback-noloop': 'fallback, in functions without a loop only',
}


def applies(policy, setname, r4_fired, fn=None):
    """does `policy` hand a function compiled under `setname` to homes2?  r4_fired: homes.choose answered (R4,
    cdecl -O3 -XS with a 32-bit candidate); fn: the function (the loop policies read its body)"""
    if policy == 'off': return False
    if policy == 'all': return True
    if policy == 'r4keep': return not r4_fired
    if policy == 'noO3XS': return setname != 'O3XS'
    if policy == 'noopt': return setname in ('none', 'Xr')
    if policy == 'fallback': return setname == 'O3XS' and not r4_fired
    if policy == 'noloop': return not has_loop(fn)
    if policy == 'noloop-r4keep': return not has_loop(fn) and not r4_fired
    if policy == 'fallback-noloop': return setname == 'O3XS' and not r4_fired and not has_loop(fn)
    raise ValueError('unknown HOMES2 policy %r (one of %s)' % (policy, ', '.join(POLICIES)))


CALL_FIRST = True              # an operand that calls is evaluated before its siblings are read (codegen: a call on the
                               # right is built first; probes/adfp.c ad_idi: a + b + (x > 0.0) keeps a across the helper)
SRET_AS_VALUE = False          # the hidden result pointer as a colouring value (fpgen.needs_sret_home does it instead)
CANDIDATES = 'model'           # which values plan_homes lets homes2 home: 'model' = its own across-a-call set
                               # (vals), 'rule' = also locals the rule finds live across a call that the model does not

# ---- the linearizer (lin.py): quads over the reference model's syntax tree -----------------------------------------
CMP = ('==', '!=', '<', '<=', '>', '>=')


def helper_call(n):
    """an operation cc900 does by a runtime call (floating point; long * / %, except * by a constant with <= 3 bits
    set, as codegen.long_helper): it clobbers everything but XIZ, like a call"""
    import fpgen
    try:
        if fpgen.is_fp_op(n): return True
    except Exception:
        return False
    if n.k in ('bin', 'opassign') and getattr(n, 'ty', None) is not None and n.ty.kind == 'int' and n.ty.size == 4:
        op = n.op.rstrip('=') if n.k == 'opassign' else n.op
        if op in ('/', '%'): return True
        if op == '*':
            r = strip(n.r)
            return not (r.k == 'const' and isinstance(r.value, int) and r.value > 0 and bin(r.value).count('1') <= 3)
    return False


def has_call(n):
    """does the expression call (a real call or a runtime helper) anywhere inside?"""
    if n is None or not hasattr(n, 'k'): return False
    if n.k == 'call' or helper_call(n): return True
    return any(has_call(c) for _, c in kids(n))


def has_loop(fn):
    """does the function loop (while / for / do, or a goto, which may be a backward one)?"""
    found = []
    def walk(n):
        if n is None or found: return
        if isinstance(n, list):
            for x in n: walk(x)
            return
        if not hasattr(n, 'k'): return
        if n.k in ('while', 'for', 'do', 'goto'): found.append(n); return
        for _, c in kids(n): walk(c)
    walk(fn.body)
    return bool(found)


class Lin:
    """ev [(q, decl, 'r' | 'w', info)], info = dict(loop=depth, arm=0/1, kind='A' | 'T' | 'R' | 'U' | 'X' | 'F',
    test2=0/1, dk=write kind); calls [q]; loops [(s0, e0)]; vars [decl] (parameters, then locals in text order);
    depth {decl: block depth}; addr {decl}; fors [(counter, bound, s0, e0)]; copies [(x, p)]; returns [(q, iscall, q0)]"""
    def __init__(s):
        s.ev = []; s.calls = []; s.loops = []; s.vars = []; s.depth = {}; s.addr = set(); s.q = 0
        s.labels = {}; s.gotos = []; s.callargs = {}; s.fors = []; s.copies = []; s.returns = []


def linearise(fn, opt=False):
    L = Lin()
    for p in fn.params:
        L.vars.append(p); L.depth[p] = 0
    st_loop = [0]; st_arm = [0]

    def ref(d, kind, rw, test2=0):
        if d is None or getattr(d, 'kind', None) not in ('param', 'local') or getattr(d, 'storage', None) == 'static':
            return
        L.ev.append((L.q, d, rw, dict(loop=st_loop[0], arm=st_arm[0], kind=kind, test2=test2)))

    def quad():
        L.q += 1
        return L.q

    def mark_addr(n):
        if not hasattr(n, 'k'): return
        if n.k == 'addr':
            v = strip(n.e)
            if v.k == 'var': L.addr.add(v.decl)
        for _, c in kids(n): mark_addr(c)

    def ex(n, ctx='X', test2=0):
        """walk an expression; returns the list of (decl, kind, test2) it reads that no quad consumed yet"""
        if n is None or not hasattr(n, 'k'): return []
        k = n.k
        if k == 'cast' and helper_call(n):
            p = ex(n.e, 'X', test2); q = quad(); flush(p, q); L.calls.append(q); return []
        if k in ('noop', 'decay', 'cast'): return ex(n.e, ctx, test2)
        if k == 'load':
            e = strip(n.e)
            if e.k == 'var': return [(e.decl, ctx, test2)]
            p = ex(n.e, 'X', test2); q = quad(); flush(p, q); return []
        if k == 'call':
            pend = []
            for a in n.args: pend += ex(a, 'A', test2)
            if n.fn.k not in ('var', 'decay', 'noop'): pend += ex(n.fn, 'F', test2)
            elif strip(n.fn).k == 'load': pend += ex(n.fn, 'F', test2)
            q = quad(); flush(pend, q); L.calls.append(q)
            L.callargs[q] = [getattr(strip(strip(a).e), 'decl', None) if strip(a).k == 'load' else None for a in n.args]
            return []
        if k == 'incdec':
            v = strip(n.e)
            if v.k == 'var':
                quad(); ref(v.decl, 'U' if ctx in ('S', 'X') else ctx, 'r', test2); ref(v.decl, ctx, 'w', test2)
                return []
            p = ex(n.e, 'X', test2); q = quad(); flush(p, q); return []
        if k == 'opassign':
            pend = ex(n.r, 'X', test2); v = strip(n.l)
            if v.k == 'var':
                q = quad(); flush(pend, q); ref(v.decl, 'U', 'r', test2); ref(v.decl, 'X', 'w', test2)
                if helper_call(n): L.calls.append(q)
                return []
            pend += ex(n.l, 'X', test2); q = quad(); flush(pend, q)
            if helper_call(n): L.calls.append(q)
            return []
        if k == 'bin' and n.op == '=':
            v = strip(n.l)
            if v.k == 'var':
                assign(v.decl, n.r); return [(v.decl, ctx, test2)] if ctx in ('T', 'A', 'R') else []
            pend = ex(n.r, 'X', test2) + ex(n.l, 'X', test2); q = quad(); flush(pend, q); return []
        if k == 'bin' and n.op in ('&&', '||'):
            p = ex(n.l, ctx if ctx == 'T' else 'X', test2)
            if p: flush(p, quad())
            st_arm[0] += 1
            p = ex(n.r, ctx if ctx == 'T' else 'X', test2)
            if p: flush(p, quad())
            st_arm[0] -= 1
            return []
        if k == 'cond':
            p = ex(n.c if hasattr(n, 'c') else n.cond, 'T', test2)
            if p: flush(p, quad())
            st_arm[0] += 1
            for side in ('t', 'f', 'then', 'els', 'a', 'b'):
                if hasattr(n, side) and hasattr(getattr(n, side), 'k'):
                    p = ex(getattr(n, side), 'X', test2)
                    if p: flush(p, quad())
            st_arm[0] -= 1
            return []
        if k in ('bin', 'un', 'index', 'deref', 'member'):
            pend = []
            sub = 'T' if (ctx == 'T' and k == 'un' and getattr(n, 'op', '') == '!') else 'X'
            ks = list(kids(n))
            if CALL_FIRST and len(ks) > 1 and sum(has_call(c) for _, c in ks) == 1:
                ks.sort(key=lambda kc: not has_call(kc[1]))     # a + b + (x > 0.0): the helper runs before a, b are read
            for _, c in ks: pend += ex(c, sub, test2)
            q = quad(); flush(pend, q)
            if helper_call(n): L.calls.append(q)
            return []
        if k == 'addr':
            mark_addr(n); pend = []
            for _, c in kids(n):
                if c.k != 'var': pend += ex(c, 'X', test2)
            return pend
        pend = []
        for _, c in kids(n): pend += ex(c, 'X', test2)
        return pend

    def flush(pend, q):
        for d, kind, t2 in pend: ref(d, kind, 'r', t2)

    def assign(d, rhs):
        r0 = strip(rhs)
        if r0.k == 'bin' and r0.op == '+' and strip(r0.r).k == 'const' and strip(r0.r).value == 0: r0 = strip(r0.l)
        if r0.k == 'load' and strip(r0.e).k == 'var': L.copies.append((d, strip(r0.e).decl))
        before = L.q; pend = ex(rhs, 'X')
        q = quad() if (pend or L.q == before) else L.q
        flush(pend, q)
        r = strip(rhs)
        dk = 'c' if r.k == 'call' else 'k' if r.k in ('const', 'fconst') else \
            ('p' if strip(r.e).k == 'var' and strip(r.e).decl.kind in ('param', 'local') else 'g') if r.k == 'load' \
            else 'r'
        if d is not None and getattr(d, 'kind', None) in ('param', 'local') and getattr(d, 'storage', None) != 'static':
            L.ev.append((q, d, 'w', dict(loop=st_loop[0], arm=st_arm[0], kind='X', test2=0, dk=dk)))

    def test(c, test2=0):
        before = L.q; pend = ex(c, 'T', test2)
        if pend or L.q == before: flush(pend, quad())

    def st(n, depth):
        if n is None: return
        if isinstance(n, list):
            for x in n: st(x, depth)
            return
        k = n.k
        if k == 'block':
            for x in n.body: st(x, depth + 1)
            return
        if k == 'decl':
            d = n.var
            if d not in L.depth and getattr(d, 'storage', None) != 'static':
                L.vars.append(d); L.depth[d] = max(0, depth - 1)
            if getattr(n, 'init', None) is not None:
                if n.init.k == 'initlist': mark_addr(n.init); return
                assign(d, n.init)
            return
        if k == 'expr':
            e = getattr(n, 'e', None)
            if e is not None:
                mark_addr(e)
                p = ex(e, 'S')
                if p: flush(p, quad())
            return
        if k == 'return':
            if n.value is not None:
                mark_addr(n.value)
                before = L.q
                p = ex(n.value, 'R')
                if p or L.q == before: flush(p, quad())
                rv = n.value
                while hasattr(rv, 'k') and rv.k in ('noop', 'decay', 'cast'): rv = rv.e
                L.returns.append((L.q, rv.k == 'call', before))
            return
        if k == 'if':
            mark_addr(n.cond); test(n.cond)
            st_arm[0] += 1; st(n.then, depth); st(n.els, depth); st_arm[0] -= 1
            return
        if k in ('while', 'for', 'do'):
            if k == 'for' and n.init is not None:
                if hasattr(n.init, 'k') and n.init.k in ('block', 'decl', 'expr'): st(n.init, depth)
                else:
                    p = ex(n.init, 'S')
                    if p: flush(p, quad())
            s0 = L.q + 1; st_loop[0] += 1
            if k != 'do' and n.cond is not None:
                mark_addr(n.cond); test(n.cond, test2=1)
            st(n.body, depth)
            if k == 'for' and n.inc is not None:
                p = ex(n.inc, 'S')
                if p: flush(p, quad())
            if k == 'do': mark_addr(n.cond); test(n.cond)
            st_loop[0] -= 1
            if k == 'for' and n.cond is not None:
                c = strip(n.cond); iv = None; bv = None
                if c.k == 'bin' and c.op in CMP:
                    l, r = strip(c.l), strip(c.r)
                    if l.k == 'load' and strip(l.e).k == 'var': iv = strip(l.e).decl
                    if r.k == 'load' and strip(r.e).k == 'var': bv = strip(r.e).decl
                L.fors.append((iv, bv, s0, L.q))
            L.loops.append((s0, L.q)); return
        if k == 'switch':
            test(n.value); st_arm[0] += 1; st(n.body, depth); st_arm[0] -= 1; return
        if k == 'label':
            L.labels[getattr(n, 'name', None)] = L.q + 1
            for _, c in kids(n): st(c, depth)
            return
        if k == 'goto':
            L.gotos.append((getattr(n, 'name', None), L.q)); return
        if k in ('break', 'continue'): return
        if k in ('case', 'default'):
            for _, c in kids(n):
                if c.k not in ('const',): st(c, depth)
            return
        mark_addr(n)
        p = ex(n, 'S')
        if p: flush(p, quad())

    st(fn.body, 0)
    for name, q in L.gotos:
        lq = L.labels.get(name)
        if lq is not None and lq <= q: L.loops.append((lq, q))
    return L


# ---- values and their intervals (rule.py) ----------------------------------------------------------------------------
def eligible(d, L):
    t = d.ty
    if d in L.addr or getattr(d, 'storage', None) == 'static': return False
    if t.kind not in ('int', 'ptr'): return False
    return t.size in (1, 2, 4)


class Val:
    def __init__(s, d):
        s.d = d; s.start = 0 if d.kind == 'param' else None; s.end = None; s.reads = 0; s.writes = 0
        s.first_read = None; s.ev = []; s.dk = []; s.rk = []
    @property
    def name(s): return s.d.name
    @property
    def big(s): return s.d.ty.size == 4
    def span(s): return max(1, (s.end or 0) - (s.start or 0))


class SretDecl:
    """the hidden result pointer of a function returning a double (a 32-bit stack parameter read at each return;
    passed on, as an argument, when the returned value is a call)"""
    name = '.sret'; kind = 'param'; storage = None
    def __init__(s, frontend_type): s.ty = frontend_type


def values(fn, opt=False, count=True, sret=SRET_AS_VALUE):
    """-> (L, {decl: Val}, candidates): the function's values, intervals and references, and those live across a call"""
    L = linearise(fn, opt)
    V = {}
    for d in L.vars:
        if eligible(d, L): V[d] = Val(d)
    rt = getattr(fn, 'ret', None)
    if sret and rt is not None and rt.kind == 'float' and rt.size >= 8 and L.returns:
        import frontend
        sd = SretDecl(frontend.Type('ptr', 4, 2, spell='sret'))
        L.vars.insert(0, sd); L.depth[sd] = 0
        v = V[sd] = Val(sd)
        for q, iscall, q0 in L.returns:
            info = dict(loop=0, arm=0, kind='A' if iscall else 'R', test2=0)
            L.ev.append((q, sd, 'r', info))
        v.start = min(q0 for _, _, q0 in L.returns) + 0.5   # loaded where it is first needed: the first return
    for q, d, rw, info in L.ev:
        v = V.get(d)
        if v is None: continue
        v.ev.append((q, rw, info))
        if rw == 'r' and isinstance(d, SretDecl) and v.start is not None and v.start > q: v.start = q - 0.5
        if rw == 'w':
            v.writes += 1; v.dk.append(info.get('dk', 'r'))
            if v.start is None: v.start = q
        else:
            v.reads += 2 if info.get('test2') else 1
            v.rk += [info.get('kind', 'X')] * (2 if info.get('test2') else 1)
            v.end = q if v.end is None else max(v.end, q)
            if v.first_read is None: v.first_read = q
    for s0, e0 in L.loops:
        for v in V.values():
            inl = sorted([(q, rw) for q, rw, _ in v.ev if s0 <= q <= e0], key=lambda x: (x[0], x[1] == 'w'))
            if inl and inl[0][1] == 'r':
                v.end = max(v.end or 0, e0 + 0.5)
                if v.start is not None and v.start > s0: v.start = s0
    for v in V.values():
        if v.start is None: v.start = v.first_read or 0
        if v.end is None: v.end = v.start
    if opt:
        o3_rewrites(L, V, count)
    cand = [v for v in V.values() if any(v.start < c < v.end for c in L.calls) and not getattr(v, 'gone', False)]
    for v in V.values():
        if getattr(v, 'force_slot', False) and v not in cand: cand.append(v)
    return L, V, cand


def o3_rewrites(L, V, count=True):
    """-O3 changes that move references between values:
    copy  x = p (or p + 0) with x and p never written again: x is p (rc_keep2..4: a takes IZ, the v's go)
    count for (i = K; i < n; i++) whose counter is read only by its own test and step: the loop counts n down
          (rc_for, rc_loop1..4: n IZ, i in a slot)"""
    for x, src in L.copies:
        vx, vs = V.get(x), V.get(src)
        if vx is None or vs is None or vx.writes != 1 or vs.writes != 0: continue
        vs.reads += vx.reads - 1; vs.rk += vx.rk; vs.end = max(vs.end, vx.end); vx.gone = True
    for iv, bv, s0, e0 in (L.fors if count else ()):
        vi, vb = V.get(iv), V.get(bv)
        if vi is None or vb is None: continue
        inside = [(q, rw, i) for q, rw, i in vi.ev if s0 <= q <= e0]
        if any(rw == 'r' and not i.get('test2') and i.get('kind') != 'U' for q, rw, i in inside): continue
        vb.reads += 1; vb.rk.append('U'); vb.writes += 1; vb.dk.append('r'); vi.force_slot = True


def interferes(a, b):
    return max(a.start, b.start) < min(a.end, b.end)


# ---- the fitted parameters (params.json of the session, fit_rule.py; HKEYS from halves_fit.py) --------------------
BASE = dict(wr=1.0, wc=1.0, wg=1.0, wk=1.0, wp=1.0, wa=2.0, ld=2.0, pa=1.0, p32=0.0, T1=1.0, T2=2.0, ws=1.0, pf=0,
            rA=1.0, rT=1.0, rR=1.0, rU=1.0, rX=1.0, rF=0.0)
FITTED = {
    'none':   dict(T1=2, T2=2.5, ld=2, p32=0.0, pa=1.0, pf=1, rA=1.0, rF=0.0, rR=1.0, rT=1.0, rU=1.0, rX=1.0,
                   wa=2, wc=1, wg=1.0, wk=0, wp=1.0, wr=1.5, ws=1.0),
    'O3XS':   dict(T1=2.5, T2=2.5, ld=0, p32=0, pa=1.0, pf=0, rA=1.5, rF=0.0, rR=1.5, rT=1.5, rU=1.5, rX=1.0,
                   wa=2, wc=1, wg=1, wk=0, wp=1, wr=1.5, ws=1),
    'Xr':     dict(T1=2.5, T2=1, ld=2.0, p32=0, pa=1, pf=0, rA=1.0, rF=0.0, rR=1.0, rT=1.5, rU=1.0, rX=1.5,
                   wa=2, wc=1, wg=1, wk=0, wp=0.5, wr=1.5, ws=1),
    'O3XSXr': dict(T1=2, T2=1, ld=0, p32=0, pa=1, pf=0, rA=1, rF=0.0, rR=1.5, rT=1, rU=1.5, rX=1,
                   wa=2, wc=0.5, wg=0.5, wk=0, wp=1.0, wr=1.5, ws=1.25),
}
HKEYS = {'none': [('call', -1), ('deg', 1), ('decl', 1)], 'O3XS': [('call', -1), ('deg', 1), ('decl', 1)],
         'Xr': [('call', -1), ('arith', -1), ('decl', 1)], 'O3XSXr': [('call', -1), ('deg', -1), ('decl', 1)]}
PARAMS = {k: dict(BASE, hkeys=HKEYS[k], **FITTED[k]) for k in FITTED}

RK = {'A': 'rA', 'T': 'rT', 'R': 'rR', 'U': 'rU', 'X': 'rX', 'S': 'rX', 'F': 'rF'}
WDEF = {'c': 'wc', 'g': 'wg', 'k': 'wk', 'p': 'wp', 'r': 'wa'}


def score(v, p, adecl):
    s = p['wr'] * sum(p.get(RK.get(k, 'rX'), 1.0) for k in v.rk) + sum(p[WDEF.get(k, 'wa')] for k in v.dk)
    if v.d.kind == 'param':
        s += p['pa'] if (adecl and getattr(v, 'reg_param', True)) else -p['ld']
    if v.big: s -= p['p32']
    return s


def priority(v, p, adecl):
    return score(v, p, adecl) / (v.span() ** p['ws'])


def select(cand, L, p, adecl):
    """Chow-style colouring with two abstract colours: highest priority first; the first colour costs T1, the
    second (the other half of XIZ) needs a score of T2; a long needs both colours free"""
    didx = {d: i for i, d in enumerate(L.vars)}
    sc = {v: score(v, p, adecl) for v in cand}
    pf = p.get('pf', 0)
    order = sorted(cand, key=lambda v: (-(pf and v.d.kind == 'param' and sc[v] >= p['T1']),
                                        -priority(v, p, adecl), didx[v.d]))
    col = {}
    for v in order:                                     # colours: 0 = IZ, 1 = QIZ; a long takes both
        if sc[v] < p['T1']: continue
        used = set()
        for w in cand:
            if w is not v and w in col and interferes(v, w): used |= col[w]
        if v.big:
            if not used: col[v] = {0, 1}
            continue
        for c in ((0,) if v.d.kind == 'param' else (0, 1)):   # a parameter is never homed in QIZ
            if c in used: continue
            if c == 1 and sc[v] < p['T2']: break
            col[v] = {c}; break
    return col


def hfeat(v, didx, deg):
    """the per-value features the halves decision list reads"""
    return dict(decl=didx[v.d], call=int('c' in v.dk), deg=deg.get(v, 0), arith=int('r' in v.dk),
                konst=int('k' in v.dk), upd=int('U' in v.rk), glob=int('g' in v.dk),
                loop=int(any(i.get('loop') for _, _, i in v.ev)), start=v.start, end=v.end,
                refs=v.reads + v.writes, span=v.end - v.start)


def halves(sel, L, p, allv=()):
    """which 16-bit winner gets IZ.  A parameter always does (it is never homed in QIZ).  Among the others, a pair
    that interferes is ordered by the decision list p['hkeys'] = [(feature, +1 | -1), ...]: the first feature that
    differs decides, +1 meaning the larger value takes IZ; each value then takes the first half its neighbours
    leave free"""
    didx = {d: i for i, d in enumerate(L.vars)}
    deg = {v: sum(1 for w in allv if w is not v and interferes(v, w)) for v in sel}
    F = {v: hfeat(v, didx, deg) for v in sel}
    keys = p.get('hkeys') or [('call', -1), ('deg', 1), ('decl', 1)]
    def cmp(a, b):
        if (a.d.kind == 'param') != (b.d.kind == 'param'): return -1 if a.d.kind == 'param' else 1
        for k, d in keys:
            if F[a][k] != F[b][k]: return -1 if (F[a][k] > F[b][k]) == (d == 1) else 1
        return 0
    home = {}
    for v in sorted(sel, key=functools.cmp_to_key(cmp)):
        used = set()
        for w in sel:
            if w is not v and w.d in home and interferes(v, w): used.add(home[w.d])
        home[v.d] = 'IZ' if 'IZ' not in used else 'QIZ'
    return home


def predict(fn, setname, reg_params=None, p=None):
    """{decl: home} for every eligible value of fn under setname: 'IZ' / 'QIZ' / 'XIZ', 'slot' or 'mem' for a
    candidate left in memory, '-' for a value that is no candidate.  reg_params: the parameters that arrive in a
    register under adecl (the model knows: a double on the stack uses up a position); None = the first three."""
    p = p or PARAMS[setname]
    adecl = setname in ('Xr', 'O3XSXr'); opt = setname.startswith('O3')
    L, V, cand = values(fn, opt, count=not adecl)
    if adecl:
        for i, d in enumerate(fn.params):
            if d in V: V[d].reg_param = (d in reg_params) if reg_params is not None else i < 3
    col = select([v for v in cand if not getattr(v, 'force_slot', False)], L, p, adecl)
    home = {v.d: 'XIZ' for v, c in col.items() if v.big}
    home.update(halves([v for v, c in col.items() if not v.big], L, p, list(V.values())))
    out = {}
    for d, v in V.items():
        h = home.get(d)
        if h is None:
            if v not in cand or getattr(v, 'gone', False): h = 'mem' if isinstance(d, SretDecl) else '-'
            else: h = 'mem' if (d.kind == 'param' and not (adecl and getattr(v, 'reg_param', True))) else 'slot'
        out[d] = h
    return out


def predict_names(fn, setname, reg_params=None):
    """predict() keyed by name, a second declaration of a name as name#2 (the research-scratch interface)"""
    out = {}; seen = {}
    for d, h in predict(fn, setname, reg_params).items():
        seen[d.name] = seen.get(d.name, 0) + 1
        out[d.name if seen[d.name] == 1 else '%s#%d' % (d.name, seen[d.name])] = h
    return out
