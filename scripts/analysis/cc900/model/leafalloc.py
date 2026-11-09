"""cc900 reference model: the -O3 -XS -Xr leaf loop's temporary family and parameter moves (rule R6).

Fitted by research-scratch sessions/2026-11-09_cc900-leaf-temps (fit.py, 62 of 62 rows of runs
2026-11-09-5-micro-optparams and 2026-11-09-11-micro-opttemps under O3XSXr).  A loop needs one register family T
for its temporaries (the `n--` copy: ld T16,n / dec 0x1,n / cp T16,0x0; the byte moved or compared).  T is chosen
by the loop body's kind; a parameter that holds the chosen family moves out at entry:
- count, word (no byte temporary): T = the first free of DE, HL, IX; nothing moves;
- move3: T = the first free of DE, WA, BC, HL;
- move, heavy: candidates DE, WA, BC; the counter n is never T's victim: when a candidate holds n, n moves to the
  first free family of reloc(candidate) and the candidate is barred; cmp: BC; arith, cmp2: WA;
- a candidate's occupant moves to the first free family of reloc(candidate); if none is free, the next candidate;
  reloc(WA) = DE, HL; reloc(BC) = HL, IX; reloc(DE) = HL;
- a returned local reserves HL; if no candidate works, a victim may take HL and the local goes to IX;
- entry moves: repeatedly the first pending move (parameter order) whose destination is no other move's source.
"""

RELOC = {'WA': ['DE', 'HL'], 'BC': ['HL', 'IX'], 'DE': ['HL']}
KINDS = {'move': (['DE', 'WA', 'BC'], 'evict', True), 'heavy': (['DE', 'WA', 'BC'], 'evict', True),
         'move3': (['DE', 'WA', 'BC', 'HL'], 'free-first', True), 'cmp': (['BC'], 'evict', False),
         'arith': (['WA'], 'evict', False), 'cmp2': (['WA'], 'evict', False),
         'count': (['DE', 'HL', 'IX'], 'free-only', False), 'word': (['DE', 'HL', 'IX'], 'free-only', False),
         'none': ([], 'none', False)}

class Fail(Exception): pass

def choose(arrival, counter, retloc, kind):
    """arrival: {var: family}; returns (T, final {var: family}, retloc family or None)"""
    pref, policy, excl_n = KINDS[kind]
    occ0 = {f: v for v, f in arrival.items()}
    def attempt(yielding):
        occ = dict(occ0); where = {v: f for f, v in occ.items()}
        reserved = {'HL': retloc} if retloc is not None else {}
        yielded = set(); excluded = set()
        def free(f, cand):
            if f == cand or occ.get(f) is not None: return False
            return yielding or f not in reserved
        def relocate(v, src, cand):
            for f in RELOC.get(src, []):
                if free(f, cand):
                    if f in reserved: yielded.add(reserved.pop(f))
                    del occ[src]; occ[f] = v; where[v] = f; return True
            return False
        if policy == 'none': return '', where, reserved, yielded
        if policy in ('free-first', 'free-only'):
            for f in pref:
                if occ.get(f) is None and f not in reserved: return f, where, reserved, yielded
            if policy == 'free-only': raise Fail
        excl_fam = arrival.get(counter) if excl_n and counter is not None else None
        for cand in pref:
            if cand in excluded or (cand == excl_fam and occ.get(cand) != counter): continue
            if cand in reserved and not yielding: continue
            v = occ.get(cand)
            if v is None:
                if cand in reserved: yielded.add(reserved.pop(cand))
                return cand, where, reserved, yielded
            if excl_fam and v == counter:
                if relocate(v, cand, cand): excluded.add(cand)
                continue
            if relocate(v, cand, cand): return cand, where, reserved, yielded
        raise Fail
    try: T, where, reserved, yielded = attempt(False)
    except Fail: T, where, reserved, yielded = attempt(True)
    rl = None
    if retloc is not None: rl = 'IX' if retloc in yielded else 'HL'
    return T, where, rl

def moves(order, arrival, final):
    """the entry moves, sequentialised: [(var, src, dst)]"""
    pend = [(v, arrival[v], final[v]) for v in order if v in arrival and final[v] != arrival[v]]
    out = []
    while pend:
        for i, (v, s, d) in enumerate(pend):
            if not any(s2 == d for w, s2, _ in pend if w is not v):
                out.append((v, s, d)); pend.pop(i); break
        else: raise Fail
    return out

def classify(f, strip, walk):
    """(kind, counter decl) of a leaf function made of while loops and simple statements, or None.  Loops with no
    temporary (`while (*a) a++;`) are skipped; the others must agree on one kind (op_cat: the second loop's move)."""
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    if not loops or any(l.k != 'while' for l in loops): return None
    def unc(e):
        e = strip(e)
        while e.k == 'cast': e = strip(e.e)
        return e
    def byte_deref(e):
        e = unc(e)
        return e.k == 'load' and strip(e.e).k == 'deref' and e.ty.size == 1
    def derefs(n, size):
        out = []
        walk(n, lambda m, d: out.append(m) if m.k == 'load' and strip(m.e).k == 'deref' and m.ty.size == size else None)
        return out
    def is_cnt(e):
        e = unc(e)
        return e.k == 'incdec' and e.post and e.op == '--' and strip(e.e).k == 'var' and strip(e.e).decl.kind == 'param'
    def byte_cmp(e):
        e = unc(e)
        return e.k == 'bin' and e.op in ('==', '!=') and byte_deref(e.l) and byte_deref(e.r)
    found = []
    for w in loops:
        c = unc(w.cond); counter = None; extra = None
        if is_cnt(c): counter = strip(unc(c).e).decl
        elif c.k == 'bin' and c.op == '&&' and (is_cnt(c.l) or is_cnt(c.r)):   # op_cat3: n-- && *b
            counter = strip(unc(c.l if is_cnt(c.l) else c.r).e).decl
        elif c.k == 'bin' and c.op == '&&':
            l = unc(c.l)
            if l.k == 'load' and strip(l.e).k == 'var' and strip(l.e).decl.kind == 'param' and byte_cmp(c.r):
                found.append(('cmp', strip(l.e).decl)); continue
            if byte_cmp(c.l) or byte_cmp(c.r): found.append(('cmp2', None)); continue   # op_two: *a == *b && *a
            return None
        elif byte_cmp(c): found.append(('cmp2', None)); continue
        elif byte_deref(c) or (c.k == 'load' and c.ty.kind in ('int', 'ptr')):
            if not derefs(w.body, 1) and not derefs(w.body, 2): continue          # while (*a) a++;: no temporary
            return None
        else: return None
        if derefs(w.body, 2): found.append(('word', counter)); continue
        stores = []
        walk(w.body, lambda m, d: stores.append(m) if m.k in ('bin', 'opassign') and (m.k == 'opassign' or m.op == '=') else None)
        kind = 'count'
        for st in stores:
            lv = strip(st.l)
            if lv.k == 'deref' and st.ty.size == 1 and derefs(st.r, 1):
                kind = 'move3' if len([p for p in f.params if p.ty.is_ptr()]) >= 3 else 'move'; break
            if lv.k == 'var' and lv.decl.kind == 'local' and derefs(st.r, 1):
                r = unc(st.r)
                kind = 'arith' if r.k == 'bin' else 'heavy'; break
        found.append((kind, counter))
    if not found: return ('none', None)
    if len({k for k, _ in found}) != 1: return None
    return found[0]
