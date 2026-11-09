"""Rule LN1: the registers V4.23 without options (cdecl) gives to the variables of a leaf function that has a loop.

Ported from research-scratch sessions/2026-11-09_cc900-leaf-none (rule.py, commit 3d847d0), where the rule, its
evidence and its scoring live (README.md there).  Fitted on 275 functions of the micro corpora and the lnr/lnr2/lnr3
probes (corpus/probes/README.md); the held-out lnr4.c scored 9 / 18 functions before six fixes and 15 / 18 after.

THE RULE, in short: every candidate variable is placed in the order (a) result variables (HL), (b) each statement's
hard template registers, (c) early parameters in reverse declaration order, (d) soft temporaries of uncrowded
statements, (e) the locals in reverse declaration order, (f) the other parameters in reverse declaration order;
each takes its preference when free, else the first of SEQ16 / SEQ32 / SEQ8 that no reservation or overlapping
variable holds over its live range (first definition to last reference, widened over a loop whose first reference
reads it).

allocate(f, inreg) -> {decl: family or '-'}; codegen.plan_leaf applies it under LEAF_NONE_LN1.
"""
import collections
import codegen

def strip(e): return codegen.strip(e)

def walk(n, fn): codegen.walk(n, fn)

def variables(f):
    """the scalar variables a register could hold: parameters then locals, in declaration order"""
    out = []
    for d in list(f.params) + [d for d in f.decls if d.kind == 'local']:
        if d.ty.kind in ('int', 'ptr') and not d.addr_taken and d.ty.size in (1, 2, 4): out.append(d)
    return out

def unc(e):
    e = strip(e)
    while e.k == 'cast': e = strip(e.e)
    return e

def var_of(e):
    e = unc(e)
    return strip(e.e).decl if e.k == 'load' and strip(e.e).k == 'var' else None

INPLACE = ('+', '-', '&', '|', '^')

def result_vars(e):
    """variables an expression's value is produced in place of: the value itself, an arm of ?:, the left operand
    of + - & | ^ (one level only: ra_leafsum3's (v0 + v1) + v2 pulls nothing)"""
    e = unc(e)
    v = var_of(e)
    if v is not None: return [v]
    if e.k == 'cond': return [x for x in (var_of(e.a), var_of(e.b)) if x is not None]
    if e.k == 'bin' and e.op in INPLACE:
        v = var_of(e.l)
        return [v] if v is not None else []
    return []

SEQ16 = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'QWA', 'QBC', 'QDE', 'QHL']
SEQ32 = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
SEQ8 = ['WA', 'BC', 'DE', 'HL']

def res_of(r, size):
    """the 16-bit halves a variable of `size` in family r occupies"""
    if r.startswith('Q'): return {r}
    return {r, 'Q' + r} if size == 4 else {r}

# ---------------------------------------------------------------- units: statement-level evaluations with spans

class Lin:
    def __init__(s): s.pos = 0; s.ev = []; s.loops = []; s.stack = []; s.units = []
    def tick(s): s.pos += 1; return s.pos

def linear(f):
    """events (pos, decl, mode, loops, cond) and units (lo, hi, expr, kind, loops) in evaluation order"""
    L = Lin()
    def ref(d, mode, cond): L.ev.append((L.tick(), d, mode, tuple(L.stack), cond))
    def ex(n, cond=False):
        if n is None: return
        k = n.k
        if k in ('noop', 'decay', 'cast', 'un', 'deref'): ex(n.e, cond); return
        if k == 'load':
            v = strip(n.e)
            if v.k == 'var': ref(v.decl, 'r', cond); return
            ex(n.e, cond); return
        if k in ('var', 'const', 'string', 'fconst'): return
        if k == 'bin' and n.op == '=':
            l = strip(n.l)
            if l.k == 'var': ex(n.r, cond); ref(l.decl, 'w', cond)
            else: ex(n.l, cond); ex(n.r, cond)            # cc900 computes a stored-to address first
            return
        if k == 'opassign':
            l = strip(n.l)
            if l.k == 'var': ex(n.r, cond); ref(l.decl, 'rw', cond)
            else: ex(n.l, cond); ex(n.r, cond)
            return
        if k == 'incdec':
            v = strip(n.e)
            if v.k == 'var': ref(v.decl, 'rw', cond)
            else: ex(n.e, cond)
            return
        if k == 'bin': ex(n.l, cond); ex(n.r, cond); return
        if k == 'index': ex(n.base, cond); ex(n.idx, cond); return
        if k == 'cond': ex(n.c, cond); ex(n.a, cond); ex(n.b, cond); return
        if k == 'member': ex(n.base, cond); return
        if k == 'call':
            for a in getattr(n, 'args', []): ex(a, cond)
            return
        for v in n.__dict__.values():
            if hasattr(v, 'k'): ex(v, cond)
    def unit(e, kind, cond=False):
        if e is None: return
        lo = L.pos + 1; ex(e, cond); L.units.append((lo, L.pos, e, kind, tuple(L.stack)))
    def st(n):
        if n is None: return
        if isinstance(n, list):
            for x in n: st(x)
            return
        k = n.k
        if k == 'block': st(n.body); return
        if k == 'decl':
            if n.init is not None:
                lo = L.pos + 1; ex(n.init); ref(n.var, 'w', False)
                L.units.append((lo, L.pos, ('declinit', n.var, n.init), 'decl', tuple(L.stack)))
            return
        if k == 'expr': unit(n.e, 'expr'); return
        if k == 'return': unit(n.value, 'return'); return
        if k == 'if': unit(n.cond, 'cond', True); st(n.then); st(n.els); return
        if k == 'switch': unit(n.cond, 'cond', True); st(n.body); return
        if k in ('while', 'do', 'for'):
            if k == 'for' and n.init is not None:
                if n.init.k == 'expr': unit(n.init.e, 'expr')
                else: st(n.init)
            lid = len(L.loops); L.loops.append([L.pos + 1, None, n]); L.stack.append(lid)
            if k == 'while': unit(n.cond, 'loopcond', True); st(n.body)
            elif k == 'do': st(n.body); unit(n.cond, 'docond', True)
            else:
                unit(n.cond, 'loopcond', True); st(n.body)
                if n.inc is not None: unit(n.inc, 'expr')
            L.stack.pop(); L.loops[lid][1] = L.pos
            return
        for v in n.__dict__.values():
            if hasattr(v, 'k') or isinstance(v, list): st(v)
    st(f.body)
    return L

# ---------------------------------------------------------------- what a statement's temporaries keep

def is_sized_global(b):
    b = strip(b)
    while b.k in ('decay', 'cast'): b = strip(b.e)
    return b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and (b.decl.ty.count or 0) > 0

def is_unsized_global(b):
    b = strip(b)
    while b.k in ('decay', 'cast'): b = strip(b.e)
    return b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and not b.decl.ty.count

def base_var(b):
    b = unc(b)
    return strip(b.e).decl if b.k == 'load' and strip(b.e).k == 'var' else None

def simple(e, inreg):
    """a value that needs no register of its own: a constant, a variable held in a register"""
    e = unc(e)
    if e.k == 'const': return True
    v = var_of(e)
    return v is not None and v in inreg

def mem_scalar(e):
    e = unc(e)
    return e.k == 'load' and strip(e.e).k == 'var'

def has_index(e):
    out = []
    walk(e, lambda n, d: out.append(n) if n.k in ('index', 'deref') else None)
    return bool(out)

def reserve(u, inreg, crowded):
    """the temporaries of one unit, as two ordered lists of wanted registers (16-bit halves):
    hard -- fixed by the code template, kept from every variable live across the unit;
    soft -- an lvalue address held while an indexed right-hand side is computed (and that right-hand side's own
            address), kept only when no variable is live across the unit without being read in it (`crowded`), the
            two sides do not share a base, and allocated after the early parameters (allocate()).
    `inreg`: the variables that have registers."""
    lo, hi, e, kind, loops = u
    hard, soft = [], []
    def H(*r): hard.extend(x for x in r if x not in hard)
    if isinstance(e, tuple):                              # a declaration's initializer: as `v = init`
        e = type('B', (), {'k': 'bin', 'op': '=', 'l': type('V', (), {'k': 'var', 'decl': e[1]})(), 'r': e[2],
                           'ty': e[1].ty})()
    def regptr(p):
        v = var_of(p) if unc(p).k != 'incdec' else var_of(unc(p).e) if strip(unc(p).e).k == 'var' else None
        if unc(p).k == 'incdec' and strip(unc(p).e).k == 'var': v = strip(unc(p).e).decl
        return v is not None and v in inreg
    def idx_rv(n):
        es = n.ty.size
        if is_sized_global(n.base):
            if es == 1:
                iv = unc(n.idx)
                if var_of(n.idx) in inreg and var_of(n.idx).ty.size == 2 and iv.k == 'load':
                    H('WA')                                             # lda XWA,_g / (XWA+i)
                else: H('WA', 'BC', 'QBC')                              # the index in WA, the base in XBC
            else: H('WA', 'BC', 'QBC', *(['QWA'] if es == 4 else []))
            rv(n.idx, True); return
        if is_unsized_global(n.base): H('WA', 'BC', 'QBC', *(['QWA'] if es == 4 else [])); rv(n.idx, True); return
        H('WA', 'QWA'); rv(n.idx, True)
    def rv(n, sub=False):
        n = unc(n)
        if n.k == 'const': return
        if n.k == 'load':
            x = strip(n.e)
            if x.k == 'var': return
            if x.k == 'index': idx_rv(x); return
            if x.k == 'deref':
                p = unc(x.e)
                if regptr(p): H('WA') if sub else None; return
                if p.k == 'incdec': H('WA', 'QWA', 'BC', 'QBC'); return
                H('BC', 'QBC'); return
            return
        if n.k == 'bin' and n.op in ('=', ','): pass
        elif n.k == 'bin':
            if n.op in ('*', '/', '%') and has_index(n.l) and has_index(n.r):
                H('WA', 'QWA')                                         # the held operand goes where it can
                for x in (n.l, n.r):
                    xx = unc(x)
                    if xx.k == 'load' and strip(xx.e).k == 'index' and is_sized_global(strip(xx.e).base):
                        idx_rv(strip(xx.e))
                    if xx.k == 'load' and strip(xx.e).k == 'index' and is_sized_global(strip(xx.e).base): pass
                if all(unc(x).k == 'load' and strip(unc(x).e).k == 'index' and is_sized_global(strip(unc(x).e).base)
                       for x in (n.l, n.r)): H('DE', 'HL', 'QHL')
                return
            if n.op in ('+', '-', '&', '|', '^') and has_index(n.l) and has_index(n.r):
                if all(unc(x).k == 'load' and strip(unc(x).e).k == 'index' and is_sized_global(strip(unc(x).e).base)
                       for x in (n.l, n.r)):
                    H('WA', 'BC', 'QBC', 'DE', 'HL', 'QHL'); return
                H('WA', 'QWA')
                for x in (n.l, n.r):
                    xx = unc(x)
                    if xx.k == 'load' and strip(xx.e).k == 'index' and is_unsized_global(strip(xx.e).base): H('BC', 'QBC')
                return
            rv(n.l, True); rv(n.r, True)
            rr = unc(n.r)
            if rr.k == 'load' and strip(rr.e).k == 'index' and is_sized_global(strip(rr.e).base) and \
                    rr.ty.size >= 2 and not simple(n.l, inreg):
                H('DE', 'QDE')                                         # (post-hoc, lnr4 h18)
            if n.op in ('*', '/', '%'): H('WA', 'QWA')
            elif n.op in ('<<', '>>') and unc(n.r).k != 'const': H('WA', 'BC')
            elif n.op in ('&&', '||'): pass
            else: H('WA')                                           # (post-hoc, lnr4 h11)
            return
        if n.k == 'cond': rv(n.c, True); rv(n.a, True); rv(n.b, True); H('WA'); return
        if n.k == 'bin' and n.op == '=': assign(n.l, n.r, None); return
        if n.k == 'bin' and n.op == ',': rv(n.l); rv(n.r); return
        if n.k == 'incdec':
            v = strip(n.e).decl if strip(n.e).k == 'var' else None
            if v is None: rv(n.e, True)
            H('WA'); return
        if n.k == 'un': rv(n.e, True); H('WA'); return
        H('WA')
    def assign(l, r, op):
        l = strip(l)
        ru = unc(r)
        if l.k == 'var':
            v = l.decl
            if v in inreg:
                if op is None and ru.k == 'bin' and ru.op in INPLACE and \
                        (simple(ru.l, inreg) or mem_scalar(ru.l)) and (simple(ru.r, inreg) or mem_scalar(ru.r)):
                    return                                      # x = a + b: computed in x's register
                if op is not None and (simple(r, inreg) or mem_scalar(r)): return     # s += x
                if op is None and ru.k == 'load' and strip(ru.e).k == 'deref' and not regptr(strip(ru.e).e):
                    p = unc(strip(ru.e).e)
                    if p.k == 'incdec': H('WA', 'QWA')                 # v = *p++: the address is v's own register
                    return
                rv(r, op is not None)
                return
            if ru.k == 'bin' and ru.op == '=' and strip(ru.l).k == 'var' and strip(ru.l).decl in inreg:
                assign(ru.l, ru.r, None); return                # gi = y = x: the value is y's own register
            rv(r, True)
            if not simple(r, inreg): H('WA')
            return
        if l.k == 'index':
            es = l.ty.size
            rc = simple(r, inreg) and not (ru.k == 'const' and es == 4)
            rx = has_index(r)
            if is_sized_global(l.base):
                if es == 1:
                    if rc: H('WA'); return                              # lda XWA,_g / ldb (XWA+i),k
                    H('WA', 'BC', 'QBC'); rv(r, True); return
                if rx:
                    rr = []
                    walk(r, lambda n, d: rr.append(n) if n.k == 'index' else None)
                    if all(x.ty.size == 1 and is_sized_global(x.base) for x in rr):
                        H('WA', 'BC', 'DE', 'QDE'); return             # gb[i] = gca[i]: BC / XDE, XWA
                    rv(r, True); H('DE', 'QHL'); soft.append('HL'); return  # (post-hoc, lnr4 h7: the base moves)
                if rc and es <= 2: H('WA', 'BC', 'QBC'); return
                H('WA', 'BC', 'DE', 'QDE', *(['QWA'] if es == 4 else [])); rv(r, True); return
            if regptr(l.base) and unc(l.idx).k == 'const':
                rv(r, True)
                if not simple(r, inreg) and ru.k != 'const': H('WA')
                return
            if es == 1 and not is_unsized_global(l.base):
                if rc and op in (None, '+', '-'): H('WA', 'QWA'); return
                H('WA', 'QWA', 'BC', 'QBC'); rv(r, True); return
            if rc and op in (None, '+', '-') and not (ru.k == 'const' and es == 4):
                H('WA', 'QWA')
                if is_unsized_global(l.base) and ru.k != 'const': pass
                return
            if not rx:                                                  # held over a simple value: fixed XBC
                rv(r, True)
                if regptr(l.base) and False: pass
                H('WA', 'QWA')
                if is_unsized_global(l.base) and not simple(r, inreg) and ru.k != 'load': soft.append('BC')
                elif is_unsized_global(l.base) and var_of(r) is None and ru.k != 'const' and not mem_scalar(r):
                    soft.append('BC')
                else: H('BC', 'QBC')
                return
            # an indexed right-hand side: the held address is soft
            H('WA', 'QWA')
            if ru.k == 'bin' and has_index(ru.l) and has_index(ru.r): rv(r, True); return
            rb = []
            walk(r, lambda n, d: rb.append(n) if n.k == 'index' else None)
            def bkey(b):
                b = unc(b)
                while b.k in ('decay',): b = unc(b.e)
                v = strip(b.e).decl if b.k == 'load' and strip(b.e).k == 'var' else (b.decl if b.k == 'var' else None)
                return v
            same = bkey(l.base) is not None and any(bkey(x.base) is bkey(l.base) for x in rb)
            unsized_r = [x for x in rb if is_unsized_global(x.base)]
            sized_r = [x for x in rb if is_sized_global(x.base)]
            for x in sized_r: idx_rv(x)
            if same:
                for x in unsized_r: H('BC', 'QBC')
                return
            if crowded:
                if unsized_r and crowded < 3: H('BC', 'QBC')            # (post-hoc, lnr4 h9 h10 h17)
                return
            for x in unsized_r: soft.append('BC')
            soft.append('BC')
            return
        if l.k == 'deref':
            p = unc(l.e)
            gp = var_of(p)
            if gp is not None and gp.kind == 'global' and simple(r, inreg): H('WA', 'QWA'); return
            if regptr(l.e):
                if not simple(r, inreg) and ru.k != 'const': rv(r, True); H('WA')
                return
            rv(r, True)
            if p.k == 'incdec': H('WA', 'QWA', 'BC', 'QBC'); return
            H('BC', 'QBC')
            if ru.k != 'const': H('WA')
            return
        rv(r, True); H('WA')
    n = e if (getattr(e, 'k', None) == 'bin' and e.op == '=') else unc(e)
    if n.k == 'bin' and n.op == '=': assign(n.l, n.r, None)
    elif n.k == 'opassign': assign(n.l, n.r, n.op)
    elif n.k == 'incdec' and strip(n.e).k == 'var':
        if kind in ('loopcond', 'docond', 'cond'): H('WA')
    elif n.k == 'bin' and n.op in ('<', '<=', '>', '>=', '==', '!=') and kind in ('cond', 'loopcond', 'docond'):
        if all(unc(x).k == 'bin' and unc(x).op == '=' for x in (n.l, n.r)): H('WA', 'BC')
        for x in (n.l, n.r):
            ux = unc(x)
            if ux.k == 'bin' and ux.op == '=': assign(ux.l, ux.r, None); H('WA')
            elif ux.k == 'incdec' and strip(ux.e).k == 'var': H('WA')
            elif ux.k == 'load' and strip(ux.e).k == 'deref' and regptr(strip(ux.e).e):
                if unc(n.r if x is n.l else n.l).k != 'const': H('WA')
            else: rv(x, True)
    elif n.k == 'bin' and n.op == '&' and kind in ('cond', 'loopcond', 'docond') and unc(n.r).k == 'const':
        if not simple(n.l, inreg): rv(n.l, True); H('WA')                  # bit k,R on a register variable
    elif kind in ('cond', 'loopcond', 'docond') and n.k == 'load' and strip(n.e).k == 'deref' and regptr(strip(n.e).e):
        pass                                                            # while (*s++): cpb (XWA+:1),0x0
    else:
        rv(e)
    return hard, soft

# ---------------------------------------------------------------- the allocation

def early_param(d, L):
    """allocated before the locals: every non-pointer parameter; a pointer parameter whose first reference loads
    through it (m = p[0], gr = t[i]) or stores a non-constant at a constant index (t[0] = n) -- not one first used to
    store a constant (*t = 0), to compare with a constant (if (t[0])) or as the base of a store at a variable index
    (t[i] = t[i + 1])"""
    if not d.ty.is_ptr(): return True
    for (lo, hi, e, kind, loops) in L.units:
        if isinstance(e, tuple): e = e[2]
        refs = []
        walk(e, lambda n, dd: refs.append(n) if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl is d else None)
        if not refs: continue
        n = unc(e)
        if kind in ('cond', 'loopcond', 'docond'):
            if n.k == 'bin' and n.op in ('==', '!=', '<', '>', '<=', '>=') and \
                    (unc(n.r).k == 'const' or unc(n.l).k == 'const'): return False
            if n.k == 'load' and strip(n.e).k in ('index', 'deref'): return False
            return True
        if n.k in ('bin', 'opassign') and (n.k == 'opassign' or n.op == '='):
            l = strip(n.l)
            if l.k in ('index', 'deref'):
                lrefs = []
                walk(l, lambda m, dd: lrefs.append(m) if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d else None)
                if lrefs:
                    if unc(n.r).k == 'const': return False
                    if l.k == 'index' and unc(l.idx).k != 'const': return False
                    return True
        return True
    return True

def promote(d, FI, has_loop_):
    """does parameter d get a register (none, cdecl)?  A pointer walked with ++ is decided by the model's WALKED_PTRS
    rule and is not scored here (None)."""
    fi = FI[d]
    if not has_loop_: return None
    if fi['modified'] and d.ty.is_ptr(): return None
    if fi['modified']: return fi['lrefs'] >= 2
    return fi['lrefs'] >= 3

def prefs(f, vs, inreg):
    """variable -> preferred register.  HL: the value becomes the result (returned as it is, an arm of a returned
    ?:, the left operand of a returned + - & | ^).  WA: a local defined once by an operation done in the accumulator
    (a char operand or result, * / %), or last read as the left operand of + - & | ^ whose result is stored to
    memory.  BC: a local defined once by a shift by a variable count (the shifted value's register)."""
    p = {}
    def direct(n, dep):                                   # returned as it is, or an arm of a returned ?:
        if n.k == 'return' and n.value is not None:
            x = unc(n.value)
            for v in ([var_of(x)] if x.k != 'cond' else [var_of(x.a), var_of(x.b)]):
                if v is not None and v in inreg: p.setdefault(v, 'HL')
    walk(f.body, direct)
    defs = collections.defaultdict(list)
    def dfn(n, dep):
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': defs[strip(n.l).decl].append(n.r)
        if n.k == 'opassign' and strip(n.l).k == 'var': defs[strip(n.l).decl].append(n)
        if n.k == 'incdec' and strip(n.e).k == 'var': defs[strip(n.e).decl].append(n)
        if n.k == 'decl' and n.init is not None: defs[n.var].append(n.init)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' and strip(n.l).decl.kind == 'global':
            # gr = a + b: a flows into WA (a scalar target only: post-hoc, lnr4 h16 gw[i] = j + j)
            x = unc(n.r)
            if x.k == 'bin' and x.op in INPLACE:
                v = var_of(x.l)
                if v is not None and v.kind == 'local' and v in inreg: p.setdefault(v, 'WA')
    walk(f.body, dfn)
    for v, ds in defs.items():
        if v not in inreg or len(ds) != 1 or v.kind != 'local' or v in p: continue
        x = unc(ds[0])
        if x.k != 'bin': continue
        chars = v.ty.size == 1 or any(unc(y).ty.size == 1 for y in (x.l, x.r) if hasattr(unc(y), 'ty'))
        if x.op in ('<<', '>>') and unc(x.r).k != 'const': p[v] = 'BC'
        elif x.op in ('*', '/', '%'): p[v] = 'WA'
        elif x.op in INPLACE and chars: p[v] = 'WA'
    def r(n, dep):
        if n.k == 'return' and n.value is not None:
            for v in result_vars(n.value):
                if v in inreg: p.setdefault(v, 'HL')
    walk(f.body, r)
    return p

def allocate(f, inreg):
    vs = [d for d in variables(f) if d in inreg]
    L = linear(f)
    rng = {}
    for d in vs:
        evs = [e for e in L.ev if e[1] is d]
        pos = [e[0] for e in evs]
        lo = 0 if d.kind == 'param' else (min(pos) if pos else 0)
        hi = max(pos) if pos else 0
        for (a, b, n) in L.loops:
            inl = [e for e in evs if a <= e[0] <= b]
            if inl and inl[0][2] != 'w': lo, hi = min(lo, a), max(hi, b)
        rng[d] = (lo, hi, evs)
    def overlaps(d, u): return rng[d][0] <= u[1] and rng[d][1] >= u[0]
    def reads_in(d, u): return [e[0] for e in rng[d][2] if u[0] <= e[0] <= u[1] and 'r' in e[2]]
    def crowded(u):
        return sum(rng[w][0] < u[0] and rng[w][1] > u[1] and not any(u[0] <= e[0] <= u[1] for e in rng[w][2]) for w in vs)
    P = prefs(f, vs, inreg)
    early = {d for d in vs if d.kind == 'param' and early_param(d, L)}
    got = {}
    R = {id(u): reserve(u, inreg, crowded(u)) for u in L.units}
    def held_by(u, done):
        h = set()
        for w, r in done.items():
            if overlaps(w, u): h |= res_of(r, w.ty.size)
        return h
    def resolve(want, u, avoid):
        """each wanted register, or the next free one of SEQ16 when a variable allocated earlier holds it"""
        out = []
        for r in want:
            if r in avoid or r in out:
                if r.startswith('Q'): continue
                r = next((x for x in SEQ16[SEQ16.index(r):] if x not in avoid and x not in out), None)
                if r is None: continue
            out.append(r)
        return set(out)
    def busy_for(d, sets):
        lo, hi, evs = rng[d]
        busy = set()
        for u in L.units:
            if not overlaps(d, u): continue
            rd = reads_in(d, u)
            e = u[2]
            defines = (isinstance(e, tuple) and e[1] is d) or (getattr(e, 'k', None) == 'bin' and e.op == '=' and
                                                               strip(e.l).k == 'var' and strip(e.l).decl is d)
            if defines and not rd and d.kind != 'param': continue
            rs = set(sets[id(u)])
            last = rd and max(rd) == hi and u[0] <= hi <= u[1]
            if last:
                top = e[2] if isinstance(e, tuple) else e
                top = unc(top)
                if top.k in ('bin', 'opassign') and (top.k == 'opassign' or top.op == '=') and \
                        strip(top.l).k in ('index', 'deref'): top = type('X', (), {'k': 'none'})()   # (post-hoc, h16)
                elif top.k == 'bin' and top.op == '=': top = unc(top.r)
                if var_of(top) is d or (top.k == 'bin' and var_of(top.l) is d) or P.get(d) == 'WA':
                    rs -= {'WA', 'QWA'}
                if P.get(d) and top.k == 'bin' and var_of(top.l) is d: rs -= res_of(P[d], 4)
            busy |= rs
        return busy
    def take(d, avoid_sets):
        busy = busy_for(d, avoid_sets)
        lo, hi, _ = rng[d]
        held = set()
        for w, r in got.items():
            if rng[w][0] <= hi and rng[w][1] >= lo: held |= res_of(r, w.ty.size)
        blocked = busy | held
        seq = SEQ8 if d.ty.size == 1 else SEQ32 if d.ty.size == 4 else SEQ16
        pr = P.get(d)
        if pr and not (res_of(pr, d.ty.size) & blocked): return pr
        return next((r for r in seq if not (res_of(r, d.ty.size) & blocked)), '-')
    # 0. the result variables (HL) are precoloured
    for d in reversed(vs):
        if d.kind == 'local' and P.get(d) == 'HL' or d.kind == 'param' and P.get(d) == 'HL' and d in early:
            got[d] = take(d, {id(u): set() for u in L.units}) if True else None
            if got[d] != 'HL': del got[d]
    # 1. the template registers, around the precoloured ones
    HARD = {id(u): resolve(R[id(u)][0], u, held_by(u, got)) for u in L.units}
    # 2. early parameters
    for d in reversed(vs):
        if d in early and d not in got: got[d] = take(d, HARD)
    # 3. held addresses of uncrowded statements
    SOFT = {}
    for u in L.units:
        hs = HARD[id(u)]
        SOFT[id(u)] = resolve(R[id(u)][1], u, held_by(u, got) | hs) if R[id(u)][1] else set()
    ALL = {k: HARD[k] | SOFT[k] for k in HARD}
    # 4. the other locals (reverse declaration order), then the late parameters
    for d in [d for d in reversed(vs) if d.kind == 'local' and d not in got] + \
             [d for d in reversed(vs) if d.kind == 'param' and d not in got]:
        got[d] = take(d, ALL)
    return got

