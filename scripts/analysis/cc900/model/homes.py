"""Where a value live across a call lives: IZ / QIZ / XIZ / a frame slot / its stack arrival (rule R3-set).

Under -O3 -XS rule R4 (research-scratch sessions/2026-11-09_cc900-homes, fit_o3xs_uses.py, 1baf8a7: 203 of 213 O3XS
values, the 1997 library's _strlen, _calloc, _memccpy, _strcmp, _modf all right): with a 32-bit candidate the order is
(demoted, class, -score, span, locals before parameters), from how each value is used (uses() below); without one,
choose() returns None and codegen keeps the first fit's rule, which gets the 16-bit contests (rh_lp,
sv_keep_across) that R4's fallback misses.  The R3 order keeps two refinements (research-scratch sessions/2026-11-09_cc900-homes/fit_o3xs_counter.py, 132 -> 142 of
158 values): a parameter read only as a loop bound is no candidate when a local that is more than a loop counter is
(rh_loop, c_for: i, read in the body, IZ; n memory; rc_for: i only counts, n IZ), and an accumulator written by
arithmetic in a loop (s += g1(i)) takes no QIZ.

The rule was fitted to cc900 V4.23's listings of 75-79 functions under the four option sets (research-scratch
sessions/2026-11-09_cc900-homes, fit_homes.py BEST3_SET; exact home right for 160/168 values without options,
132/158 under -O3 -XS, 147/178 under -Xr, 147/168 under -O3 -XS -Xr).  This module measures the features that rule
reads from our syntax tree -- the same ones homes.csv counts by hand -- and applies it.

Features of a value (homes.csv's columns):
- reads / writes: references as code; x++ and x op= y count a read and a write; a for / while test is counted twice
  (the rotated loop tests at the top and at the bottom), except that under -O the entry test of
  `for (i = K; i < n; ...)` folds to `n > 0`, so i is read there once;
- u_cmp: reads that are the bound of a loop compare (`n` of `i < n`);
- u_conv: reads through an unsigned-to-int conversion of a call argument;
- span: last-use quad minus definition quad (a parameter is defined at quad 0).  A quad is one operation in source
  evaluation order: an arithmetic or compare operator, a call (its arguments are read there), a plain copy or
  constant assignment, an element or pointer read (`p[i]`, `*p`), a test of a plain value, a return of a plain
  value.  A loop's quads are numbered once in
  source order (for: init, test, body, step); a value whose first reference in the loop is a read is live around the
  back edge and lasts to the loop's last quad;
- argwa: the value itself is the first argument of some call;
- ctl: reads that are its own for-loop's test or step (counter_only: all of them);
- accum: written by arithmetic inside a loop.
"""

# rule parameters per option set (fit_homes.py BEST3_SET)
SETS = {
    'none':   dict(ld=2, cw=1, cv=0, p32=0, norm=0, pf=1, sp=1, tie='ldecl', fp=1, qt='pri', TQ=2),
    'O3XS':   dict(ld=1, cw=0, cv=0, p32=1, p32k='L', norm=0, pf=1, sp=1, tie='ldecl', fp=1, qt='pair', TQ=3, qacc=1,
                   mixx=1, r4=1),
    'Xr':     dict(ld=2, cw=1, cv=1, p32=0, norm=1, pf=0, sp=0, tie='decl', fp=2, qt='pair', TQ=2),
    'O3XSXr': dict(ld=0, cw=1, cv=1, p32=1, norm=1, pf=0, sp=0, tie='ldecl', fp=3, qt='pair', TQ=2),
}
CMP = ('==', '!=', '<', '<=', '>', '>=')


def strip(e):
    while e.k in ('noop', 'decay', 'cast'): e = e.e
    return e


def var_of(e):
    """the variable a plain read names, or None"""
    e = strip(e)
    if e.k == 'load' and strip(e.e).k == 'var': return strip(e.e).decl
    return None


def kids(n):
    for k, v in n.__dict__.items():
        if isinstance(v, list):
            for x in v:
                if hasattr(x, 'k'): yield k, x
        elif hasattr(v, 'k'): yield k, v


class Feat:
    def __init__(s): s.reads = s.writes = s.u_cmp = s.u_conv = s.ctl = 0; s.argwa = s.accum = False; s.span = 0
    def counter_only(s): return s.reads > 0 and s.ctl >= s.reads


def features(body, params, opt):
    """{decl: Feat} for every variable referenced in body"""
    if opt: mark_merged_tails(body)
    F = {}
    def f(d):
        if d not in F: F[d] = Feat()
        return F[d]
    for d in params: f(d)

    # --- reads / writes / u_cmp / u_conv / argwa
    def count(n, k=1, bound=None, once=None, ctl=None):
        if isinstance(n, list):
            for x in n: count(x, k, bound, once, ctl)
            return
        if not hasattr(n, 'k') or getattr(n, '_merged', False): return
        if n.k == 'load' and strip(n.e).k == 'var':
            d = strip(n.e).decl
            if n is bound: f(d).u_cmp += k
            r = 1 if (once is not None and d is once) else k
            f(d).reads += r
            if d is ctl: f(d).ctl += r
        if n.k in ('incdec', 'opassign'):
            v = strip(n.e if n.k == 'incdec' else n.l)
            if v.k == 'var':
                f(v.decl).reads += k; f(v.decl).writes += k
                if v.decl is ctl: f(v.decl).ctl += k
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': f(strip(n.l).decl).writes += k
        if n.k == 'decl' and getattr(n, 'init', None) is not None: f(n.var).writes += k
        if n.k == 'call':
            if n.args and var_of(n.args[0]) is not None: f(var_of(n.args[0])).argwa = True
            for a in n.args:
                x = a
                while x.k in ('noop', 'decay'): x = x.e
                if x.k == 'cast' and x.ty.kind == 'int' and x.ty.signed:
                    d = var_of(x.e)
                    if d is not None and d.ty.kind == 'int' and not d.ty.signed: f(d).u_conv += k
        for key, v in kids(n):
            if n.k in ('while', 'for') and key == 'cond':
                c = strip(v); b = None; o = None
                if c.k == 'bin' and c.op in CMP:
                    rb = c.r
                    while rb.k in ('noop', 'decay', 'cast'): rb = rb.e
                    b = rb if rb.k == 'load' else None
                    if opt and n.k == 'for' and n.init is not None:
                        o = init_var(n.init)
                        if o is not None and o is not var_of(c.l): o = None
                # -O: `while (n--)` tests once (rc_while, rc_ptr_loop: n has 2 references, not 4)
                kk = k if (opt and n.k == 'while' and has_incdec(v)) else 2 * k
                count(v, kk, b, o, init_var(n.init) if n.k == 'for' and n.init is not None else None)
            elif n.k == 'for' and key == 'inc':
                count(v, k, bound, once, init_var(n.init) if n.init is not None else None)
            elif key == 'l' and n.k == 'bin' and n.op == '=' and strip(v).k == 'var':
                continue
            else: count(v, k, bound, once, ctl)
    count(body)
    def acc(n, depth):                                 # an arithmetic write inside a loop: s += g1(i), s = s - x
        if isinstance(n, list):
            for x in n: acc(x, depth)
            return
        if not hasattr(n, 'k'): return
        if depth and n.k == 'opassign' and strip(n.l).k == 'var': f(strip(n.l).decl).accum = True
        if depth and n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' and strip(n.r).k == 'bin' and \
                strip(n.r).op in ('+', '-', '*', '/', '%', '&', '|', '^', '<<', '>>'):
            f(strip(n.l).decl).accum = True
        for _, c in kids(n): acc(c, depth + (1 if n.k in ('for', 'while', 'do') else 0))
    acc(body, 0)

    # --- spans
    q = [0]; first_def = {}; last = {}; refs = []      # refs: (quad, decl, 'r' | 'w')
    def use(ds, qq):
        for d in ds: last[d] = max(last.get(d, 0), qq); refs.append((qq, d, 'r'))
    def define(d, qq):
        if d not in first_def: first_def[d] = qq
        refs.append((qq, d, 'w'))
    def quad(ds):
        q[0] += 1; use(ds, q[0]); return q[0]
    def ex(n):
        """walk an expression; -> the variables it reads that no quad has consumed yet"""
        if n is None or not hasattr(n, 'k'): return []
        k = n.k
        if k == 'load' and strip(n.e).k == 'var': return [strip(n.e).decl]
        if k == 'call':
            pend = []
            for a in n.args: pend += ex(a)
            pend += ex(n.fn) if n.fn.k not in ('var', 'decay', 'noop') else []
            quad(pend); return []
        if k == 'incdec':
            v = strip(n.e)
            if v.k == 'var': qq = quad([v.decl]); define(v.decl, qq); return []
            quad(ex(n.e)); return []
        if k == 'opassign':
            pend = ex(n.r); v = strip(n.l)
            if v.k == 'var': qq = quad(pend + [v.decl]); define(v.decl, qq); return []
            quad(pend + ex(n.l)); return []
        if k == 'bin' and n.op == '=':
            v = strip(n.l)
            if v.k == 'var':
                assign(v.decl, n.r); return []
            pend = ex(n.r) + ex(n.l); quad(pend); return []
        if k in ('bin', 'un', 'cond', 'index', 'deref'):     # rh_loop_p: g1(p[i]) is two quads
            pend = []
            for _, c in kids(n): pend += ex(c)
            quad(pend); return []
        pend = []
        for _, c in kids(n): pend += ex(c)
        return pend
    def assign(d, rhs):
        before = q[0]; pend = ex(rhs)
        if pend or q[0] == before: qq = quad(pend)
        else: qq = q[0]
        define(d, qq)
    def test(c):
        before = q[0]; pend = ex(c)
        if pend or q[0] == before: quad(pend)
    loops = []
    def st(n):
        if n is None: return
        if isinstance(n, list):
            for x in n: st(x)
            return
        k = n.k
        if k == 'block': st(n.body); return
        if k == 'decl':
            if getattr(n, 'init', None) is not None: assign(n.var, n.init)
            return
        if k == 'expr': ex(n.e) if hasattr(n, 'e') else None; return
        if k == 'return':
            if n.value is not None:
                pend = ex(n.value)
                if pend: quad(pend)
            return
        if k == 'if':
            test(n.cond); st(n.then); st(n.els); return
        if k == 'while':
            s0 = q[0] + 1; test(n.cond); st(n.body); loops.append((s0, q[0])); return
        if k == 'do':
            s0 = q[0] + 1; st(n.body); test(n.cond); loops.append((s0, q[0])); return
        if k == 'for':
            st(n.init) if n.init is not None and hasattr(n.init, 'k') and n.init.k in ('block', 'decl', 'expr') \
                else (ex(n.init) if n.init is not None else None)
            s0 = q[0] + 1
            if n.cond is not None: test(n.cond)
            st(n.body)
            if n.inc is not None: ex(n.inc)
            loops.append((s0, q[0])); return
        if k == 'switch':
            test(n.value); st(n.body); return
        if hasattr(n, 'k') and k not in ('break', 'continue', 'goto', 'label', 'case', 'default'):
            ex(n)
        for _, c in kids(n):
            if c.k in ('block', 'if', 'while', 'do', 'for', 'return', 'decl', 'expr', 'switch'): st(c)
    for d in params: first_def[d] = 0
    st(body)
    for s0, e0 in loops:
        inloop = sorted((r for r in refs if s0 <= r[0] <= e0), key=lambda r: (r[0], r[2] == 'w'))
        seen = set()
        for qq, d, kind in inloop:
            if d in seen: continue
            seen.add(d)
            if kind == 'r': last[d] = max(last.get(d, 0), e0)
    for d, x in F.items():
        x.span = max(0, last.get(d, first_def.get(d, 0)) - first_def.get(d, 0))
    return F


def same_expr(a, b):
    """structural equality of two expression trees (the same variables, constants and operators)"""
    if not (hasattr(a, 'k') and hasattr(b, 'k')) or a.k != b.k: return False
    if a.k == 'var': return a.decl is b.decl
    if a.k == 'const': return a.value == b.value
    for key in ('op', 'kind'):
        if getattr(a, key, None) != getattr(b, key, None): return False
    ka, kb = list(kids(a)), list(kids(b))
    return len(ka) == len(kb) and all(x[0] == y[0] and same_expr(x[1], y[1]) for x, y in zip(ka, kb))


def last_call(arm):
    n = arm
    while hasattr(n, 'k') and n.k == 'block' and n.body: n = n.body[-1]
    if hasattr(n, 'k') and n.k == 'expr' and hasattr(n.e, 'k') and strip(n.e).k == 'call': return strip(n.e)
    return None


def mark_merged_tails(body):
    """-O cross-jumping (_memccpy: both arms end in memcpy(s1, s2, x)): the arguments the two arms' final calls share,
    from the first, are pushed once after the arms meet; mark the else arm's copies _merged (counted once)"""
    def visit(n):
        if not hasattr(n, 'k'): return
        if n.k == 'if' and n.els is not None:
            a, b = last_call(n.then), last_call(n.els)
            if a is not None and b is not None and same_expr(a.fn, b.fn) and len(a.args) == len(b.args):
                k = 0
                while k < len(a.args) and same_expr(a.args[k], b.args[k]): k += 1
                if k < len(a.args):                        # identical calls are a different merge
                    for x in b.args[:k]: x._merged = True
        for _, c in kids(n): visit(c)
    visit(body)


def has_incdec(n):
    if not hasattr(n, 'k'): return False
    if n.k == 'incdec': return True
    return any(has_incdec(c) for _, c in kids(n))


def init_var(init):
    """the variable a for-init `i = K` sets, or None"""
    n = init
    if hasattr(n, 'k') and n.k == 'expr': n = n.e
    if hasattr(n, 'k') and n.k == 'block' and len(n.body) == 1: n = n.body[0]
    if not hasattr(n, 'k'): return None
    if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' and strip(n.r).k == 'const': return strip(n.l).decl
    if n.k == 'decl' and getattr(n, 'init', None) is not None and strip(n.init).k == 'const': return n.var
    return None


def choose(vals, feats, setname, adecl, stack_born, call_res, pidx, lidx, helper_ops=(), uses=None):
    """-> the winners [first, second?] in IZ-then-QIZ order (decl order), the rule's (1)-(5)."""
    p = SETS[setname]
    def score(d):
        x = feats[d]
        w = x.reads + x.writes - p['cw'] * x.u_cmp + p['cv'] * x.u_conv
        if stack_born(d): w -= p['ld']
        if d.ty.size == 4 and d not in helper_ops and (p.get('p32k') != 'L' or d.kind != 'param'):
            w -= p['p32']                                                # mul_l_pp: an operand of a long helper is homed
        return w
    def allowed(d):
        if not adecl or d.kind != 'param' or p['fp'] == 0 or pidx(d) == 0: return True
        if p['fp'] == 1: return False
        return feats[d].argwa or (p['fp'] == 3 and stack_born(d))
    sc = {d: (score(d) if allowed(d) else -99) for d in vals}
    if p.get('mixx'):
        rival = any(d.kind != 'param' and not feats[d].counter_only() and sc[d] >= 1 for d in vals)
        for d in vals:                                                   # c_for: n stays where it arrived
            x = feats[d]
            if rival and d.kind == 'param' and x.u_cmp > 0 and x.u_cmp >= x.reads: sc[d] = -99
    pri = {d: (sc[d] / max(feats[d].span, 1) if p['norm'] else sc[d]) for d in vals}
    def tie(d):
        if p['tie'] == 'decl': return (0, pidx(d)) if d.kind == 'param' else (1, lidx(d))
        return (1, pidx(d)) if d.kind == 'param' else (0, lidx(d))       # ldecl
    def key(d):
        cls = 0 if (p['pf'] and d.kind == 'param' and sc[d] >= 1) else 1
        return (cls, -pri[d], feats[d].span if p['sp'] else 0, tie(d))
    if p.get('r4') and not any(d.ty.size == 4 and sc[d] >= 1 for d in vals):
        return None                          # no 32-bit candidate: the caller's first-fit rule (rh_lp: x IZ, a memory)
    if p.get('r4') and uses is not None:
        def key(d):                          # R4 (-O3 -XS with a 32-bit candidate): how the value is used
            u = uses.get(d) or Uses(); f = u.feats(); big = d.ty.size == 4
            if big and d.kind != 'param': dem = f['A_any'] or f['arm']
            elif big: dem = f['X_arm']
            elif d.kind == 'param': dem = not f['A_pre']
            else: dem = False
            if d.kind != 'param': cls = 1
            elif big: cls = 0 if f['A_post'] else 1
            else: cls = 0 if f['A_post_u'] else 1
            return (int(bool(dem)), cls, -sc[d], feats[d].span, tie(d))
    cand = [d for d in sorted(vals, key=key) if sc[d] >= 1]
    if not cand: return []
    first = cand[0]
    if first.ty.size == 4: return [first]
    winners = [first]
    for d in cand[1:]:
        if d.ty.size == 4: continue
        if p.get('qacc') and feats[d].accum: break                       # rh_loop, rc_two_loops: s += g1(i) a slot
        if p['qt'] == 'pri': ok = sc[d] >= p['TQ']
        else:
            ok = (first.kind != 'param' and d.kind != 'param') or first in call_res or d in call_res or \
                 sc[first] + sc[d] >= p['TQ'] + 3
        if ok: winners.append(d)
        break
    gdecl = lambda d: (0, pidx(d)) if d.kind == 'param' else (1, lidx(d))
    return sorted(winners, key=gdecl)


# ---- R4's use kinds (research-scratch sessions/2026-11-09_cc900-homes/use_kinds.py, 1baf8a7) ----------------------
class Uses:
    """the reads of one value: (kind, arm, pos).  kind A = the value itself is a call argument, T = a test (if /
    while / for / ?: condition, !v, v == 0, v != 0, an && / || operand there), R = returned, X = anything else; arm =
    inside an if / else arm (not its condition, not code after an if that returns); pos = calls evaluated before it
    (a call's arguments are read before the call).  A value lives across call c when defined before c and read at
    pos >= c; the first such c splits its reads into pre and post."""
    def __init__(s): s.reads = []; s.defpos = None
    def cross(s):
        d = s.defpos or 0
        return d + 1 if any(p > d for _, _, p in s.reads) else None
    def feats(s):
        c = s.cross()
        pre = [r for r in s.reads if c is None or r[2] < c]
        post = [r for r in s.reads if c is not None and r[2] >= c]
        has = lambda rs, k, arm=None: any(r[0] == k and (arm is None or r[1] == arm) for r in rs)
        return dict(A_pre=has(pre, 'A'), A_post=has(post, 'A'), A_post_u=has(post, 'A', 0),
                    X_arm=any(r[0] == 'X' and r[1] for r in s.reads), arm=any(r[1] for r in s.reads),
                    A_any=has(s.reads, 'A'))


def uses(body, params):
    """{decl: Uses} for every variable of the function (-O: merged call tails read once, mark_merged_tails)"""
    mark_merged_tails(body)
    U = {}; ncall = [0]
    def u(d):
        if d not in U: U[d] = Uses()
        return U[d]
    for d in params: u(d).defpos = 0
    def read(d, kind, arm): u(d).reads.append((kind, arm, ncall[0]))
    def write(d):
        if u(d).defpos is None: u(d).defpos = ncall[0]
    def zero(e): e = strip(e); return e.k == 'const' and e.value == 0
    def ex(n, ctx, arm):
        if n is None or not hasattr(n, 'k') or getattr(n, '_merged', False): return
        k = n.k
        if k in ('noop', 'decay', 'cast'): return ex(n.e, ctx, arm)
        if k == 'load':
            e = strip(n.e)
            if e.k == 'var': return read(e.decl, ctx, arm)
            return ex(n.e, 'X', arm)
        if k == 'call':
            for a in n.args: ex(a, 'A', arm)
            if n.fn.k not in ('var', 'decay', 'noop'): ex(n.fn, 'X', arm)
            ncall[0] += 1; return
        if k == 'bin' and n.op == '=':
            v = strip(n.l); ex(n.r, 'X', arm)
            if v.k == 'var': return write(v.decl)
            return ex(n.l, 'X', arm)
        if k in ('incdec', 'opassign'):
            v = strip(n.e if k == 'incdec' else n.l)
            if k == 'opassign': ex(n.r, 'X', arm)
            if v.k == 'var': read(v.decl, 'X', arm); return write(v.decl)
            return ex(n.e if k == 'incdec' else n.l, 'X', arm)
        if ctx == 'T' and k == 'bin' and n.op in ('==', '!=') and (zero(n.l) or zero(n.r)):
            return ex(n.r if zero(n.l) else n.l, 'T', arm)
        if ctx == 'T' and k == 'bin' and n.op in ('&&', '||'): ex(n.l, 'T', arm); return ex(n.r, 'T', arm)
        if ctx == 'T' and k == 'un' and n.op == '!': return ex(n.e, 'T', arm)
        for _, c in kids(n): ex(c, 'X', arm)
    def st(n, arm):
        if n is None: return
        if isinstance(n, list):
            for x in n: st(x, arm)
            return
        k = n.k
        if k == 'block': return st(n.body, arm)
        if k == 'decl':
            if getattr(n, 'init', None) is not None: ex(n.init, 'X', arm); write(n.var)
            return
        if k == 'expr': return ex(getattr(n, 'e', None), 'S', arm)
        if k == 'return': return ex(n.value, 'R', arm) if n.value is not None else None
        if k == 'if': ex(n.cond, 'T', arm); st(n.then, 1); st(n.els, 1); return
        if k in ('while', 'do', 'for'):
            if k == 'for' and n.init is not None:
                st(n.init, arm) if n.init.k in ('block', 'decl', 'expr') else ex(n.init, 'S', arm)
            if k != 'do' and n.cond is not None: ex(n.cond, 'T', arm)
            st(n.body, arm)
            if k == 'for' and n.inc is not None: ex(n.inc, 'S', arm)
            if k == 'do': ex(n.cond, 'T', arm)
            return
        if k == 'switch': ex(n.value, 'T', arm); return st(n.body, 1)
        if k in ('break', 'continue', 'goto', 'label', 'case', 'default'):
            for _, c in kids(n): st(c, arm)
            return
        ex(n, 'S', arm)
    st(body, 0)
    return U
