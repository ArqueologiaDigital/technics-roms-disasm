"""The WINDOW rule (E2): the order of a function's FP frame temporaries under V4.23, ported from research-scratch
sessions/2026-11-09_cc900-fp-e2b (window.py, predict.py; README there has the evidence and the unit table's probes).

The used slots of the temporary region are laid out from the bottom up by walking the function's statements
backwards from the end and counting units (units(), end_units(): a plain statement 1, `v = a op b` 2, `return v` 1,
a nested call 2 more, an if on a double compare -1 at its end, a loop body twice).  A call or long slot is placed
when the walk passes its statement; the k-th operation slot (creation order) when the walk has counted
W_SEQ[k] = 3, 7, 17 units, above everything placed so far, or at the very bottom when the whole function counts
fewer than T_SEQ[k] = 3, 7, 15.  Slot sizes, count and sharing stay as FrameAlloc (R5g / R6) makes them: the rule
only permutes them.

Fitted on probes fpp4-fpp8 (365 of 373 layouts); held out fpp9: 26 of 48 (the model's own order: 10).  GUARDED
(unvalidated()): a function with a return before its last statement, a break / continue / goto, or a long slot
keeps the model's order; so guarded, the rule was never worse than the model on any corpus measured.

plan(log) -> {old depth: new depth} from the first pass's request log (fpgen.FrameAlloc.log); the second pass
hands out the remapped depths.
"""
import codegen, fpgen

ARITH = set('+-*/%&|^') | {'<<', '>>'}
CMP = {'<', '>', '<=', '>=', '==', '!='}
WINDOW_LONG_ONE = True                               # see unvalidated (rstmt rs_4_01_04_2)
W_SEQ = (3, 7, 17, 21, 25)                           # window of the k-th operation slot (k >= 3: unmeasured)
T_SEQ = (3, 7, 15, 21, 25)                           # below this many units in the function it wraps to the bottom

def walk(e, fn):
    """visit every expression node under e"""
    if e is None or not hasattr(e, 'k'): return
    fn(e)
    for a in ('e', 'l', 'r', 'c', 'a', 'b', 'base', 'idx', 'fn'):
        x = getattr(e, a, None)
        if x is not None and hasattr(x, 'k'): walk(x, fn)
    for x in getattr(e, 'args', None) or []: walk(x, fn)

def calls_in(e):
    out = []
    walk(e, lambda n: out.append(n) if n.k == 'call' else None)
    return out

def fp_compare(e):
    hit = []
    walk(e, lambda n: hit.append(n) if n.k == 'bin' and n.op in CMP and fpgen.is_fp(codegen.strip(n.l).ty) else None)
    return bool(hit)

def is_int16(t): return t is not None and getattr(t, 'kind', None) != 'float' and getattr(t, 'size', 0) in (1, 2)

def int_conv(e):
    """casts between FP and a 16-bit integer (they go through a long temporary) under e"""
    hit = []
    def f(n):
        if n.k == 'cast' and n.kind in ('IntegralToFloating', 'FloatingToIntegral'):
            if is_int16(codegen.strip(n.e).ty) or is_int16(n.ty): hit.append(n)
    walk(e, f)
    return hit

def is_op(r): return (r.k == 'bin' and r.op in ARITH) or (r.k == 'un' and r.op == '-')

def units(st):
    """-> (units at the statement's start, nested calls).  An if / loop entry is its condition (the model logs
    bodies as statements of their own); its closing units are end_units()."""
    if st is None: return 1, 0
    k = st.k
    if k == 'expr':
        e = codegen.strip(st.e)
        if e.k == 'call': return 1, len(calls_in(e)) - 1                     # fpp5 hd, fpp8 c05
        if e.k == 'opassign': return 1, len(calls_in(e.r))                    # fpp7 x05 / x26-x28, fpp8 c06
        if e.k == 'bin' and e.op == '=':
            r = codegen.strip(e.r); n = len(calls_in(r))
            if r.k == 'call': return 1, n - 1                                 # fpp7 x07, fpp8 c04
            if r.k == 'cond': return 0, n                                     # fpp7 x24
            conv = int_conv(r)
            if r.k == 'cast' and r.kind in ('IntegralToFloating', 'FloatingToIntegral'):
                return (0 if r.kind == 'IntegralToFloating' and conv else 1 if conv else 2), n   # x17 x18 v03-v05
            if is_op(r): return 2 - len(conv), n                              # fpp6 oe, fpp7 x08, fpp8 v01 v02
            return 1, n                                                       # copies, compares as values
        return 1, len(calls_in(e))
    if k == 'return':
        if st.value is None: return 0, 0                                      # fpp7 x21
        v = codegen.strip(st.value); n = len(calls_in(v))
        if v.k == 'call': return 1, n                                         # fpp8 r05 (sequence() adds f's 2)
        if v.k == 'cond': return 0, n                                         # fpp8 r08
        if is_op(v): return (1 if n else 2), n                                # fpp8 r02-r04, r06
        return 1, n                                                           # fpp8 r01, r07, r11, r18
    if k == 'if': return 0, len(calls_in(st.cond))                            # fpp7 x12, x19
    if k in ('while', 'do'): return 0, len(calls_in(st.cond))
    if k == 'for': return (1 if st.init is not None else 0), (len(calls_in(st.cond)) if st.cond is not None else 0)
    if k in ('break', 'continue', 'switch', 'case', 'default', 'label', 'goto'): return 0, 0
    return 1, 0

def end_units(st):
    """units after the bodies of an if / loop"""
    if st.k == 'if': return -1 if fp_compare(st.cond) else 0                  # fpp7 x10 x11 x32, fpp8 k01-k11
    if st.k == 'while': return -3 if fp_compare(st.cond) else 0               # fpp8 k03
    if st.k == 'do': return -1 if fp_compare(st.cond) else 0                  # fpp8 k04
    if st.k == 'for': return (1 if st.inc is not None else 0) - (1 if st.cond is not None and fp_compare(st.cond) else 0)
    return 0

def body_ids(st):
    """ids of the statement nodes inside an if / loop (the ones the model logs)"""
    out = set()
    def f(n):
        if n is None: return
        if n.k == 'block':
            for c in n.body: f(c)
            return
        out.add(id(n))
        for a in ('then', 'els', 'body'):
            x = getattr(n, a, None)
            if x is not None: f(x)
    for a in ('then', 'els', 'body'):
        x = getattr(st, a, None)
        if x is not None: f(x)
    return out

def sequence(stmts, created):
    """forward list of (units, [attached slot ids]).  stmts: [(node, [slot ids made in it, request order])];
    created: slot id -> (kind c/o/l, creation index)."""
    out = []; stack = []                              # open compound statements: (node, body ids, start index)
    def close(upto):
        while len(stack) > upto:
            node, ids, start = stack.pop()
            if node.k in ('while', 'do', 'for'):      # a loop body counts twice (fpp7 x14 x15 x16, fpp8 k07)
                out.extend([(w, []) for w, _ in out[start:]])
            e = end_units(node)
            if e: out.append((e, []))
    for node, offs in stmts:
        while stack and (node is None or id(node) not in stack[-1][1]): close(len(stack) - 1)
        own, nested = units(node)
        att = [o for o in offs if created[o][0] != 'o']
        calls = [o for o in att if created[o][0] == 'c']; other = [o for o in att if created[o][0] != 'c']
        top = node is not None and node.k == 'expr' and codegen.strip(node.e).k == 'call'
        ret = node is not None and node.k == 'return' and node.value is not None and codegen.strip(node.value).k == 'call'
        head, rest = (calls[:1], calls[1:]) if (top or ret) else ([], calls)
        if ret:                                       # return f(..): 3 units, f's slot on the first (lib _cos, fpp8 r05)
            nested -= 1
            out.append((1, head)); out.append((own + 1, other + rest[nested:]))
        else: out.append((own, head + other + rest[nested:]))
        for j in range(min(nested, len(rest))):       # fpp8 c01 c02 c05, fpp7 w1 w8
            out.append((1, [])); out.append((1, [rest[j]]))
        if node is not None and node.k in ('if', 'while', 'do', 'for'):
            stack.append((node, body_ids(node), len(out) - (1 + 2 * min(nested, len(rest))) if node.k != 'if' else len(out)))
    close(0)
    return out

def layout(stmts, created):
    """top-down list of slot ids"""
    seq = sequence(stmts, created)
    ops = sorted((o for o in created if created[o][0] == 'o'), key=lambda o: created[o][1])
    kof = {o: (created[o][2] if len(created[o]) > 2 and created[o][2] is not None else n) for n, o in enumerate(ops)}
    want = {o: W_SEQ[min(kof[o], len(W_SEQ) - 1)] for o in ops}
    thr = {o: T_SEQ[min(kof[o], len(T_SEQ) - 1)] for o in ops}
    total = sum(w for w, _ in seq)
    B = []; count = 0; placed = set()
    for w, att in reversed(seq):
        B.extend(sorted(att, key=lambda o: -created[o][1]))   # call and long slots: the later made lower
        count += w
        for o in ops:
            if o not in placed and total >= thr[o] and count >= want[o]: B.append(o); placed.add(o)
    rest = [o for o in ops if o not in placed]
    B = sorted((o for o in rest if total < thr[o]), key=lambda o: -want[o]) + B + [o for o in rest if total >= thr[o]]
    return list(reversed(B))

def root_stmt(st):
    """`v = a op b` / `v = -a` of doubles: the statement reserves its root's slot (R5g), written or not"""
    if st is None or st.k != 'expr': return False
    e = codegen.strip(st.e)
    return e.k == 'bin' and e.op == '=' and fpgen.is_fp(e.ty) and is_op(codegen.strip(e.r))

def from_log(log, ident):
    """(stmts, created) from a trace log; ident(i, entry) -> slot id of request i.  created[id] = (kind, creation
    index, k) with k the operation-slot index that picks the window.  A root reservation that writes nothing (an
    O statement, `gd3 = gd4 * gd`) still takes an index when none is reserved yet; a later root reservation takes
    that index, a call argument does not (fpp2 w4, fpp7 w10 w11 w13 against fpp3 n2 n4 t4 u3)."""
    stmts = []; created = {}; k = [0]; root = [None, False]          # reserved index, bound to a visible slot?
    for i, e in enumerate(log):
        if e[0] == 'stmt':
            stmts.append((e[3], []))
            st = e[3]
            if root_stmt(st):
                j = i + 1; first_op = None
                while j < len(log) and log[j][0] == 'get':
                    if log[j][1] == 'op': first_op = j; break
                    j += 1
                stmts[-1] = (st, [], first_op)
                if first_op is None and root[0] is None: root[0] = k[0]; root[1] = False; k[0] += 1
            continue
        o = ident(i, e)
        if o not in created:
            kk = None
            if e[1] == 'op':
                is_root = len(stmts[-1]) > 2 and stmts[-1][2] == i if stmts else False
                if is_root and root[0] is not None and not root[1]: kk = root[0]; root[1] = True
                else:
                    kk = k[0]; k[0] += 1
                    if is_root and root[0] is None: root[0] = kk; root[1] = True
            created[o] = (e[1][0], len(created), kk)
            if not stmts: stmts.append((None, []))
            stmts[-1][1].append(o)
    return [(x[0], x[1]) for x in stmts], created


def long_one_stmt(log):
    """WINDOW_LONG_ONE: every temporary made by one expression statement / return, no loop, no double-to-integer
    conversion in it (rstmt rs_4_01_04_2)"""
    nst = {e[4] for e in log if e[0] == 'get'}
    if len(nst) != 1: return False
    if len({e[3] for e in log if e[0] == 'get' and e[1] == 'long'}) != 1: return False   # (fp_order fo_two_conv: two
                                                                                          #  longs remapped onto one)
    sts = [e for e in log if e[0] == 'stmt']
    if any(e[2] in ('while', 'do', 'for') for e in sts): return False
    st = [e[3] for e in sts if e[1] in nst]
    if len(st) != 1 or st[0] is None or st[0].k not in ('expr', 'return'): return False
    root = st[0].e if st[0].k == 'expr' else st[0].value
    hit = []
    walk(root, lambda n: hit.append(n) if n.k == 'cast' and n.kind == 'FloatingToIntegral' else None)
    return not hit

def unvalidated(log, reset=False):
    """a function the window rule is not validated for: a return that is not the last statement, a break /
    continue / goto, or a long slot (README, what is unexplained)"""
    st = [e for e in log if e[0] == 'stmt']
    if any(e[0] == 'get' and e[1] == 'long' for e in log) and not (WINDOW_LONG_ONE and not reset and long_one_stmt(log)): return True
    if any(e[2] in ('break', 'continue', 'goto') for e in st): return True
    return any(e[2] == 'return' for e in st[:-1])

def plan(log, guard=True, reset=False):
    """{old depth: new depth} for one function's log (the model's second pass remaps with it)"""
    if guard and unvalidated(log, reset): return {}
    size = {}
    for e in log:
        if e[0] == 'get': size.setdefault(e[3], e[2])
    stmts, created = from_log(log, lambda i, e: e[3])
    if len(created) < 2: return {}
    td = layout(stmts, created)
    out = {}; d = 0
    for o in td:
        d += size[o]; out[o] = d
    return out
