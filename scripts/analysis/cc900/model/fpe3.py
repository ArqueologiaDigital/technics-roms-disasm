"""E3: how many frame temporaries a function uses and which slot each operation writes, ported from research-scratch
sessions/2026-11-10_cc900-fp-e3 (e3model.py, commit 750484d; README there has the evidence, probes fpp10 / fpp11, runs
2026-11-10-2-micro-fpe3a and -3-micro-fpe3b).  Installed over fpgen's functions by install(), each rule behind a switch:

  R_A  an operation never writes over a call-result slot; a call never takes the hint cell
  R_B  free-dead: an op slot is free as soon as its value was pushed or consumed as a helper operand (R6 stack top)
  R_C  with two op temporaries as operands the result goes to the later-created slot
  R_R  no reserved root slot (`gd = fd(gd2) * gd3` has one slot), except when the first operand holds an
       int-to-double conversion
  R_L  a returned operation's temporary is not allocated before its operands
  R_X  the commutative swap after the holds_xiz order
  R_E  the region is D + D' unless the function has a resetting statement (a plain copy between memory objects of
       an integer / pointer / float type, `m op= m2`, a long ++, `if (m & c)`), then D
  R_S  (off) the long shadow pooled with the op / call slots

Held out (fpp10, predictions committed before the run): share 73 -> 93, frame 54 -> 95, temps 37 -> 81 of 100.
"""
import re
import fpgen, codegen

SW = {'R_A': True, 'R_B': True, 'R_C': True, 'R_R': True, 'R_L': True, 'R_X': True, 'R_E': True, 'R_S': False}
# R_S (the long shadow pooled with the op / call slots) is +10 on the probes and -2 on the library (_log, __trig): off

# ------------------------------------------------------------------ slot bookkeeping on the model's allocators

def slot_of(F, off):
    """-> (index into A.slots, first-pass depth, kind) of the slot at frame offset off, or None"""
    A, B = fpgen.frame_allocs(F); top = getattr(F, 'ftemp_top', 0)
    for i, sl in enumerate(A.slots):
        d = sl[0]; act = A.remap.get(d, d) if A.remap else d
        if top - act == off: return i, d, sl[2]
    return None

def free_slot(F, off):
    """R_B: the op slot at off is free again, on top of the R6 stack (in the shadow allocator too)"""
    if getattr(F, 'fp_temps', None) is None: return
    s = slot_of(F, off)
    if s is None: return
    i, d, kind = s
    if kind != 'op': return
    A, B = fpgen.frame_allocs(F)
    for X in (A, B):
        if i < len(X.slots) and X.slots[i][2] == 'op':
            sl = X.slots[i]
            if sl[3]:
                sl[3] = False
                if sl[0] in X.stack: X.stack.remove(sl[0])
                X.stack.append(sl[0])

def busy_slot(F, off):
    """a slot written again (a cell reused as a destination) is busy"""
    if getattr(F, 'fp_temps', None) is None: return
    s = slot_of(F, off)
    if s is None: return
    i, d, kind = s
    A, B = fpgen.frame_allocs(F)
    for X in (A, B):
        if i < len(X.slots):
            sl = X.slots[i]; sl[3] = True
            if sl[0] in X.stack: X.stack.remove(sl[0])

def is_call_slot(F, off):
    s = slot_of(F, off)
    return s is not None and s[2] == 'call'

def depth_of(F, off):
    s = slot_of(F, off)
    return s[1] if s is not None else -1

def slot_off(v): return v[1] if isinstance(v, tuple) and v[0] == 'slot' else None

# ------------------------------------------------------------------ the patched eval_val (copy of fpgen.eval_val)

_orig_eval_val = fpgen.eval_val
_orig_op_into = fpgen.op_into
_orig_push = fpgen.push_fp_arg
_orig_compare = fpgen.compare

def choose_dst(F, e, vals, dst, hint):
    """R_A / R_C: the slot an operation on two computed operands writes"""
    offs = [slot_off(v) for v in vals]
    ops = [o for o in offs if o is not None and not is_call_slot(F, o)]
    if SW['R_C'] and len(ops) == 2:
        return ('slot', max(ops, key=lambda o: depth_of(F, o)))
    if SW['R_A']:
        if len(ops) == 1: return ('slot', ops[0])
        if not ops:
            cell = hint if hint is not None else fpgen.Cell(e.ty.size)
            return ('slot', fpgen.alloc(F, cell))
    return dst

def eval_val(F, e, hint):
    fp = fpgen
    e = fp.fp_value_cast(e)
    if fp.addressable(F, e): return e
    if e.k == 'call':                                 # R_A: a call result never takes the hint cell (a call slot is
        cell = hint if hint is not None and not SW['R_A'] else fp.Cell(e.ty.size)   # never an operation's; fpp1 c9)
        fp.call_into(F, e, ('cell', cell)); return ('slot', cell.off)
    if e.k in ('bin', 'un', 'cast') and not (e.k == 'cast' and e.kind == 'IntegralToFloating'):
        ops = [e.l, e.r] if e.k == 'bin' else [e.e]
        comp = [i for i, x in enumerate(ops) if not fp.addressable(F, fp.fp_value_cast(x))]
        vals = [fp.fp_value_cast(x) for x in ops]
        if len(comp) == 2 and fp.holds_xiz(ops[0]) and not fp.holds_xiz(ops[1]):
            vals[0] = fp.eval_val(F, ops[0], hint); vals[1] = fp.eval_val(F, ops[1], None); dst = ('slot', vals[1][1])
            dst = choose_dst(F, e, vals, dst, hint)
            if SW['R_X'] and e.op in ('+', '*') and fp.COMMUTE_LAST_XBC: vals = [vals[1], vals[0]]
        elif len(comp) == 2 and fp.CALL_OP_LEFT_FIRST and fp.ncalls(ops[0]) > fp.ncalls(ops[1]):
            vals[0] = fp.eval_val(F, ops[0], hint); vals[1] = fp.eval_val(F, ops[1], None); dst = ('slot', vals[0][1])
            dst = choose_dst(F, e, vals, dst, hint)
            if e.op in ('+', '*') and fp.COMMUTE_LAST_XBC: vals = [vals[1], vals[0]]
        elif len(comp) == 2:
            vals[1] = fp.eval_val(F, ops[1], hint); vals[0] = fp.eval_val(F, ops[0], None); dst = ('slot', vals[0][1])
            dst = choose_dst(F, e, vals, dst, hint)
        elif len(comp) == 1 and fp.fp_value_cast(ops[comp[0]]).k != 'call':
            vals[comp[0]] = fp.eval_val(F, ops[comp[0]], hint); dst = vals[comp[0]]
            if SW['R_A'] and slot_off(dst) is not None and is_call_slot(F, dst[1]):   # e.g. -(fd(x) + 1) chains
                cell = hint if hint is not None else fp.Cell(e.ty.size); dst = ('slot', fp.alloc(F, cell))
        else:
            cell = hint if hint is not None else fp.Cell(e.ty.size)
            if comp:
                c0 = fp.fp_value_cast(ops[comp[0]])
                if c0.k == 'call' and CALL_OPERAND_FIRST and hint is None and \
                        all(fp.addressable(F, fp.fp_value_cast(a)) for a in c0.args if fp.is_fp(fp.strip(a).ty)):
                    cc = fp.Cell(c0.ty.size); fp.call_into(F, c0, ('cell', cc)); vals[comp[0]] = ('slot', cc.off)
                    fp.alloc(F, cell)                      # the call's slot first (_cosh: fabs(x) - C1 in a compare)
                elif c0.k == 'call':
                    fp.alloc(F, cell)
                    cc = fp.Cell(c0.ty.size); fp.call_into(F, c0, ('cell', cc), arg_hint=cell); vals[comp[0]] = ('slot', cc.off)
                else: vals[comp[0]] = fp.eval_val(F, ops[comp[0]], None)
            fp.op_into(F, e, vals, ('cell', cell)); return ('slot', cell.off)
        fp.op_into(F, e, vals, dst); return dst
    if CONV_LOCAL_FIRST and e.k == 'cast' and e.kind == 'IntegralToFloating' and hint is None and \
            getattr(F, 'conv_local_dest', False) and not getattr(F, 'fp_opassign', False):   # (not an op=: _exp's
                                                           # xx *= x / i keeps the long first) a local destination: the conversion's double before its
        cell = fp.Cell(e.ty.size); fp.alloc(F, cell)       # long (rstmt rs_4_03_13_0: double t = (double)gc2 - gd2 ->
        fp.eval_into(F, e, ('cell', cell)); return ('slot', cell.off)   # the long at +0xc, the double at +0x10)
    if e.k == 'cond' or e.k == 'cast':
        return _orig_eval_val(F, e, hint)
    return _orig_eval_val(F, e, hint)

_orig_eval_into = fpgen.eval_into

def eval_into(F, e, dest):
    """fpgen.eval_into with the root reservation's alloc removed (R_R): the cell is still the hint, allocated only
    when something is built in it"""
    fp = fpgen
    e = fp.fp_value_cast(e)
    gdest = dest[0] == 'lv' and fp.strip(dest[1]).k == 'var' and fp.strip(dest[1]).decl.kind == 'global'
    if gdest and getattr(F, 'stmt_global', False) and e.k in ('bin', 'un') and (e.k == 'un' or len(e.op) == 1) and \
            (e.k == 'un' or e.op in '+-*/') and not getattr(F, '_root_done', False):
        ops = [e.l, e.r] if e.k == 'bin' else [e.e]
        comp = [i for i, x in enumerate(ops) if not fp.addressable(F, fp.fp_value_cast(x))]
        if comp:
            F._root_done = True
            cell = fp.Cell(e.ty.size)
            vals = [fp.fp_value_cast(x) for x in ops]
            first = comp[-1] if len(comp) == 2 else comp[0]
            if len(comp) == 2 and fp.CALL_OP_LEFT_FIRST and fp.ncalls(ops[0]) > fp.ncalls(ops[1]): first = 0
            c0 = fp.fp_value_cast(ops[first])
            # R_R: no reservation, except when the operand built first is an int-to-double conversion: there the
            # double is above its long (fp_stmts s_conv2, fpp1 g7 / g20, fpp10 d03), an order the model keeps by
            # allocating the root's cell before the long (longs are outside the window rule: E2 open)
            def has_conv(x):
                found = []
                fp.C().walk(x, lambda n, d: found.append(n) if n.k == 'cast' and n.kind == 'IntegralToFloating' else None)
                return bool(found) or (x.k == 'cast' and x.kind == 'IntegralToFloating')
            if not SW['R_R'] or has_conv(c0) and (not CONV_ROOT_BIN_ONLY or c0.k in ('bin', 'cast') and
                                                   not (getattr(F, 'fp_opassign', False) and
                                                        (c0.k == 'cast' or CONV_OPA_NONE and not F.opt))):
                fp.alloc(F, cell)                            # s_conv2, s_conv_first: gd = gi * gd2 + gd3; a negated
                                                             # conversion, or one an op= takes, has its long first (rstmt
                                                             # rs_3_06_19_2: gd2 -= (double)gpi[1], the long at +0x14 above
                                                             # the double; rs_4_00_15_1: gd = -(double)gc / 100.0)
            if c0.k == 'call':
                cc = fp.Cell(c0.ty.size); fp.call_into(F, c0, ('cell', cc), arg_hint=cell); vals[first] = ('slot', cc.off)
            elif c0.k == 'cast' and c0.kind == 'IntegralToFloating':
                fp.eval_into(F, c0, ('cell', cell)); vals[first] = ('slot', cell.off)
            else: vals[first] = fp.eval_val(F, ops[first], cell)
            for i in comp:
                if i != first: vals[i] = fp.eval_val(F, ops[i], cell if c0.k == 'call' and fp.ROOT_CELL_AFTER_CALL else None)
            if len(comp) == 2 and first == 0 and e.op in ('+', '*') and fp.COMMUTE_LAST_XBC: vals = [vals[1], vals[0]]
            fp.op_into(F, e, vals, dest); return
    ldest = dest[0] == 'lv' and fp.strip(dest[1]).k == 'var' and fp.strip(dest[1]).decl.kind == 'local'
    prev = getattr(F, 'conv_local_dest', False); F.conv_local_dest = ldest
    try: return _orig_eval_into(F, e, dest)
    finally: F.conv_local_dest = prev

_orig_gen_return = fpgen.gen_return

def gen_return(F, v):
    """fpgen.gen_return with the 'copy' mode's eager alloc of the result temporary removed (R_L)"""
    fp = fpgen
    if F.f.ret.size == 8 and not getattr(F, 'sret_home', False):
        mode = fp.root_mode(F, v)
        if mode == 'xiz' and fp.holds_xiz(v): mode = 'copy'
        if mode == 'copy':
            t1 = fp.Cell(8)
            e0 = fp.fp_value_cast(v)
            ops = [e0.l, e0.r] if e0.k == 'bin' else [e0.e] if e0.k in ('un', 'cast') else []
            if any(fp.fp_value_cast(x).k == 'call' for x in ops) and not SW['R_L']: fp.alloc(F, t1)
            loc = fp.eval_val(F, v, t1) if e0.k != 'call' else fp.call_val(F, e0, t1)
            fp.C().flush_pops(F)
            F.emit('ld', 'XWA,(XSP+%s)' % fp.C().hx(F.sret.off + F.push)); fp.put_addr(F, loc, 'XBC'); F.emit('cal', '._fld_dd')
            return
    return _orig_gen_return(F, v)

# ------------------------------------------------------------------ R_E: the region counter

def is_memory(F, x):
    """an lvalue that lives in memory (not a register local)"""
    x = fpgen.strip(x)
    if x.k == 'var':
        d = x.decl
        if d.kind == 'global': return True
        if d.kind == 'param': return not getattr(d, 'reg', None)
        return getattr(d, 'slot', None) is not None
    if x.k in ('deref', 'index'): return True
    if x.k == 'member': return True
    return False

def mem_leaf(x):
    """x is a memory object: a var, deref, index or member (through NoOp casts and loads)"""
    x = fpgen.strip(x)
    while x.k == 'cast' and (x.kind == 'NoOp' or (x.kind == 'IntegralCast' and fpgen.strip(x.e).ty.size == x.ty.size)):
        x = fpgen.strip(x.e)                          # gi = (int)gu2, gu = gi2 (fpp11 w09 / w10) are copies
    if x.k == 'load': x = fpgen.strip(x.e)
    return x if x.k in ('var', 'deref', 'index', 'member') else None

def same_obj(a, b):
    a = mem_leaf(a); b = mem_leaf(b)
    return a is not None and b is not None and a.k == 'var' and b.k == 'var' and a.decl is b.decl

def bit_const(t):
    """the constant of a bit test m & K: plain, or (RESET_BIT_CAST) behind an integral cast in a test of 1 or 2 bytes"""
    r = fpgen.strip(t.r)
    if r.k == 'const': return True
    return RESET_BIT_CAST and r.k == 'cast' and r.kind == 'IntegralCast' and fpgen.strip(r.e).k == 'const' and t.ty.size <= 2

def is_reset(F, st):
    """a resetting statement (R_E): a plain copy between memory objects, a compound assignment / `m = m op m2` of a
    memory object with a memory operand, a long ++ / --, a bit test `if (m & c)`"""
    if st is None: return False
    k = getattr(st, 'k', None)
    if RESET_OPA_LOST and any(not getattr(d, 'reg', None) for d in getattr(F, 'opa_lost', None) or ()):
        return True                                       # (random r4_06_12: u below an 8-byte region)
    if RESET_COND_BIT and k in ('expr', 'decl', 'return'):   # a ?: tested on a bit, m & c (rstmt rs_4_06_15_1: double t =
        for c_ in fpgen.C().nodes_in(st, 'cond'):          # (gi3 & 0x80 ? gs.d : gd) -> region D alone)
            t_ = fpgen.strip(c_.c)
            if t_.k == 'bin' and t_.op == '&' and mem_leaf(t_.l) is not None and bit_const(t_) and \
                    not fpgen.is_fp(t_.ty):
                return True
    if k == 'if':
        c = fpgen.strip(st.cond)
        return c.k == 'bin' and c.op == '&' and mem_leaf(c.l) is not None and bit_const(c) and not fpgen.is_fp(c.ty)
    if k != 'expr': return False
    e = fpgen.strip(st.e)
    if RESET_INC4_INNER and any(n is not e and not fpgen.is_fp(n.ty) and n.ty.size == 4 and is_memory(F, n.e)
                                for n in fpgen.C().nodes_in(e, 'incdec')):
        return True                                       # *gp++ = 8 (random r4_03_02, r4_09_13, r1_07_13)
    if e.k == 'opassign' and not fpgen.is_fp(e.ty):
        if e.op in ('+', '-', '*', '/', '&', '|', '^'):
            return is_memory(F, e.l) and mem_leaf(e.r) is not None and (mem_leaf(e.r).k != 'var' or mem_leaf(e.r).decl.kind != 'local' or getattr(mem_leaf(e.r).decl, 'slot', None) is not None)
        return False
    if e.k == 'incdec' and not fpgen.is_fp(e.ty) and e.ty.size == 4: return is_memory(F, e.e)
    if e.k != 'bin' or e.op != '=' or (fpgen.is_fp(e.ty) and e.ty.size == 8): return False
    r = fpgen.strip(e.r)
    while r.k == 'cast' and (r.kind == 'NoOp' or (r.kind == 'IntegralCast' and fpgen.strip(r.e).ty.size == r.ty.size)): r = fpgen.strip(r.e)
    if r.k == 'bin' and r.op in ('+', '-', '*', '/', '&', '|', '^') and not fpgen.is_fp(e.ty) and \
            not (RESET_NO_MUL and r.op == '*'):          # (fpctx1 x02f: gi = gi * gi2 keeps D + D')   # gi = gi + gi2 (w45)
        if same_obj(e.l, r.l) and mem_leaf(r.r) is not None and fpgen.strip(r.r).k != 'const' and \
                not (RESET_NO_DIV and r.op == '/'): return is_memory(F, e.l)   # (gul = gul / gul: rs_2_04_10_1)
        if r.op in ('+', '*', '&', '|', '^') and same_obj(e.l, r.r) and mem_leaf(r.l) is not None and fpgen.strip(r.l).k != 'const': return is_memory(F, e.l)
        if r.op == '+' and fpgen.strip(r.r).k == 'const' and fpgen.strip(r.r).value == 0: r = fpgen.strip(r.l)   # gi2 + 0 (w32)
        else: return False
    while r.k == 'cast' and r.kind == 'NoOp': r = fpgen.strip(r.e)
    if r.k == 'load': r = fpgen.strip(r.e)
    if r.k not in ('var', 'deref', 'index', 'member'): return False
    if r.k == 'var' and r.decl.kind == 'local' and getattr(r.decl, 'slot', None) is None: return False
    if r.k == 'var' and e.l is not None and fpgen.strip(e.l).k == 'var' and fpgen.strip(e.l).decl is r.decl: return False   # gi = gi
    return is_memory(F, e.l) and is_memory(F, r)

CONV_ROOT_BIN_ONLY = True
CALL_OPERAND_FIRST = True                                  # see eval_val (_cosh)
RESET_COND_BIT = True                                      # see is_reset
CONV_OPA_NONE = True                                       # without -O an op= reserves no root cell (rstmt rs_4_01_04_2;
                                                           # -O3 -XS keeps it for a product: random r4_01_19)
RESET_INC4_INNER = True                                    # see is_reset (random r4_03_02)
RESET_BIT_CAST = True                                      # see bit_const (random r3_04_04)
RESET_NO_DIV = True                                        # see is_reset (rstmt rs_2_04_10_1)
RESET_OPA_LOST = True                                      # see is_reset (random r4_06_12)
RESET_NO_MUL = True                                        # see is_reset (fpctx1 x02f)
CONV_LOCAL_FIRST = True                                    # see eval_val

_orig_get0 = fpgen.FrameAlloc.get0
_orig_a_begin = fpgen.FrameAlloc.begin_stmt

def shadow_begin_stmt(s, st=None):
    _orig_a_begin(s, st)
    if SW['R_S'] and s.pool_l:
        for sl in s.slots:
            if sl[2] == 'call': sl[3] = False          # in the shadow a call slot is free once its statement ended

def shadow_get0(s, size, kind):
    if SW['R_S'] and s.pool_l and kind == 'long':
        if not any(not x[3] and x[1] == 4 and x[2] == 'long' for x in s.slots):
            free = [x for x in s.slots if not x[3] and x[1] == 8 and x[2] in ('op', 'call')]
            if free:
                ons = [d for d in s.stack if d in {x[0] for x in free}]
                pick = ons[-1] if ons else max(x[0] for x in free)
                sl = [x for x in free if x[0] == pick][0]; sl[3] = True; s.nlong += 1
                if pick in s.stack: s.stack.remove(pick)
                return sl[0]
    return _orig_get0(s, size, kind)

_orig_temp = fpgen.temp
_orig_begin = fpgen.begin_stmt

def region_now(F):
    A, B = fpgen.frame_allocs(F)
    return A.depth if getattr(F, '_e3reset', False) else A.depth + B.depth

def begin_stmt(F, st=None):
    _orig_begin(F, st)
    if SW['R_E'] and getattr(F, 'fp_temps', None) is not None and is_reset(F, st):
        F._e3reset = True
        if '_fa' in F.__dict__: F.ftemp_max = region_now(F)

def temp(F, size, kind='op'):
    if not SW['R_E'] or getattr(F, 'fp_temps', None) is None: return _orig_temp(F, size, kind)
    off = _orig_temp(F, size, kind)
    F.ftemp_max = region_now(F)
    return off

def op_into(F, e, vals, dest):
    doff = dest[1] if dest[0] == 'slot' else (dest[1].off if dest[0] == 'cell' else None)
    if doff is not None: busy_slot(F, doff)
    _orig_op_into(F, e, vals, dest)
    if SW['R_B']:                                     # freed shallow first, so the later-created ends on top (R6)
        offs = [slot_off(v) for v in vals]
        for o in sorted((o for o in offs if o is not None and o != doff), key=lambda o: depth_of(F, o)):
            free_slot(F, o)

def signed32(v):
    """pass 1 (fp_temps = 0) hands out negative offsets, printed as XSP+0xffffffe8"""
    return v - (1 << 32) if v >= 1 << 31 else v

def push_fp_arg(F, a, hint=None):
    import re
    before = len(F.lines)
    n = _orig_push(F, a, hint)
    if SW['R_B']:
        last = None
        for l in F.lines[before:]:                      # the last lda XIY,XSP+off before this argument's pushes
            m = re.match(r'^\tlda\tXIY,XSP(?:\+(0x[0-9a-f]+))?$', l) if isinstance(l, str) else None
            if m: last = signed32(int(m.group(1), 16) if m.group(1) else 0)
        if last is not None: free_slot(F, last - (F.push - n))   # F.push at the lda was n bytes lower
    return n

def compare(F, c, value):
    before = len(F.lines)
    _orig_compare(F, c, value)
    if SW['R_B']:
        import re
        for l in F.lines[before:]:
            m = re.match(r'^\tlda\tX(?:WA|BC),XSP(?:\+(0x[0-9a-f]+))?$', l) if isinstance(l, str) else None
            if m: free_slot(F, signed32(int(m.group(1), 16) if m.group(1) else 0) - F.push)

def install(on=True):
    if on:
        fpgen.eval_val = eval_val; fpgen.op_into = op_into; fpgen.push_fp_arg = push_fp_arg; fpgen.compare = compare
        fpgen.eval_into = eval_into; fpgen.gen_return = gen_return; fpgen.temp = temp; fpgen.begin_stmt = begin_stmt
        fpgen.FrameAlloc.get0 = shadow_get0; fpgen.FrameAlloc.begin_stmt = shadow_begin_stmt
    else:
        fpgen.eval_val = _orig_eval_val; fpgen.op_into = _orig_op_into; fpgen.push_fp_arg = _orig_push; fpgen.compare = _orig_compare
        fpgen.eval_into = _orig_eval_into; fpgen.gen_return = _orig_gen_return; fpgen.temp = _orig_temp; fpgen.begin_stmt = _orig_begin
        fpgen.FrameAlloc.get0 = _orig_get0; fpgen.FrameAlloc.begin_stmt = _orig_a_begin

