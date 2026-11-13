"""cc900 reference model: floating point (V4.23, cdecl), from run 2026-11-09-9-micro-fp (corpus/micro/fp.c).

Every operation is a runtime call that takes addresses (abi.md, Helpers): `._f<op>_<d|f>` with XWA = the result's
address, XBC / XDE = the operands'; `._fneg_d`, `._fld_<to><from>` (copy and conversions: d double, f float, l long,
ul unsigned long; XWA = destination, XBC = source); `._fcmp_d` (XWA, XBC = operands, DE = relation) and
`._fcmp_zd` (XWA = operand, BC = relation) leave the answer in HL.

Rules (fp.c under none; -O3 -XS differs only where noted):
- the result address is loaded first when it is the caller's hidden pointer (`ld XWA,(XSP+0x4)` / `lda XBC,..` /
  `lda XDE,..`), last otherwise (`lda XBC,_gd2` / `lda XDE,_gd3` / `lda XWA,_gd`); a float result goes to a 4-byte
  frame temporary and comes back in XHL (`dec 0x4,XSP` ... `lda XWA,XSP` / `cal ._fadd_f` / `ld XHL,(XSP)`);
- constants live in f_const at the start of the function (`S5000n: fdatad ...`), one per use;
- relation codes: <= 0, < 1, >= 2, > 3, == 4, != 5; a value takes the relation's code, a branch the negated
  relation's and skips when HL is not 0 (`cp HL,0x0` / `j ne,else`);
- integer to double: through a 4-byte temporary holding the long (`ld BC,(_gi)` / `exts XBC` /
  `ld (XSP+0x4),XBC` / `lda XBC,XSP+0x4` / `cal ._fld_dl`); a char takes `exts BC` / `exts XBC`, an unsigned char
  `ld XBC,0x0` / `ld C,(_guc)`; a long or unsigned long in memory is converted in place;
- double to integer: into a 4-byte temporary (`lda XBC,_gd` / `lda XWA,XSP+0x4` / `cal ._fld_ld` /
  `ld XHL,(XSP+0x4)`), directly when the destination is a long in memory;
- -O3 -XS: an address already in a register is copied, not recomputed (`lda XWA,_gd` / `ld XBC,XWA`).
"""

FCONST = [50000]

def C():
    import codegen
    return codegen

def is_fp(t): return t is not None and getattr(t, 'kind', None) == 'float'
def sfx(t): return 'd' if t.size == 8 else 'f'
def conv_name(t):
    if is_fp(t): return sfx(t)
    return 'l' if t.signed else 'ul'

REL = {'<=': 0, '<': 1, '>=': 2, '>': 3, '==': 4, '!=': 5}
NEG = {'<=': '>', '<': '>=', '>=': '<', '>': '<=', '==': '!=', '!=': '=='}

def fdata(v):
    m, e = ('%.16e' % v).split('e')
    return '%s0000e%s%03d' % (m, '-' if int(e) < 0 else '+', abs(int(e)))

def const_label(F, v, ty):
    lab = 'S%d' % FCONST[0]; FCONST[0] += 1
    F.fconsts = getattr(F, 'fconsts', []) + [(lab, v, ty.size)]
    return lab

def string_label(F, text):
    """a string literal in a function: f_const at the start, no align (abi globals.c gl_lit: S2: db "lit",0)"""
    lab = 'S%d' % FCONST[0]; FCONST[0] += 1
    F.fconsts = getattr(F, 'fconsts', []) + [(lab, text, 'str')]
    return lab

def static_label(F, d):
    """an uninitialised static local: f_area at the start of the function (abi globals.c gl_local_static:
    f_area section data large align=2,2 / S3: / dsb 2)"""
    if getattr(d, 'slabel', None) is None:
        d.slabel = 'S%d' % FCONST[0]; FCONST[0] += 1
        F.statics = getattr(F, 'statics', []) + [d]
    return d.slabel

def area_block(F):
    if not getattr(F, 'statics', None): return []
    out = ['f_area section data large align=2,2']
    for d in F.statics: out += [d.slabel + ':', '\tdsb\t%d' % d.ty.size]
    return out + ['f_code section code large align=1,1']

def const_block(F):
    if not getattr(F, 'fconsts', None): return area_block(F)
    out = ['f_const section romdata large align=2,2']
    for lab, v, size in F.fconsts:
        if size == 'str': out += [lab + ':', '\tdb\t%s,0' % v]; continue
        if isinstance(size, str) and size.startswith('init'):   # __fint: unsigned short maru[4] = {0, ...} ->
            out += [lab + ':', '\t%s\t%s' % ({'1': 'db', '2': 'dw', '4': 'dd'}[size[4:]], ','.join(v))]   # S1: dw 0,0,0,0
            continue
        out += ['\talign\t2', lab + ':', '\t%s\t%s' % ('fdatad' if size == 8 else 'fdataf', fdata(v))]
    return out + ['f_code section code large align=1,1'] + area_block(F)

def strip(e): return C().strip(e)

def stmt_reset(F):
    """the temporaries of one statement are free again at the next (_log: many statements, one small region)"""
    if getattr(F, 'fp_temps', None) is not None: F.ftemp_used = 0

SRET_HOME_RANGE = True                             # see needs_sret_home (homes2's table)
SRET_HOME_LATE = True                              # the load after the first test (acos, cosh)
SRET_HOME_EARLY = True                             # see needs_sret_home (_floor)
CALL_INTO_LOCAL = True                             # see call_into (_floor)
WINDOW_RULE = True                                 # fpwindow.plan: the slot order of FP temporaries (E2)
CALL_OP_LEFT_FIRST = True                          # see eval_val (fpp7 w5, w7)
COMMUTE_LAST_XBC = True                            # see eval_into / eval_val (fpp7 w5)
ROOT_CELL_AFTER_CALL = False                       # the operation after a call takes the root's slot (fpp7 w4)
RANK_CONST = True
MEMBER_FIRST = True
LONG_TOP = False                                   # tried for fo_conv2: costs fp_temps t_* and fp_stmts O3XS 9 -> 5

class FrameAlloc:
    """FP temporaries as depths below the top of the temporary region (rule R5g of research-scratch
    sessions/2026-11-09_cc900-fp-frame, 7f6721d): op slots are pooled and free again at each statement (the free slot
    nearest the top, else a new one below all); call and long slots are never reused; the function's first long
    reserves room for all its longs (counted in pass 1), handed out deepest first.  pooled_longs: the shadow
    allocator whose depth is D' (the longs pooled like op slots)."""
    def __init__(s, nlong, pooled_longs=False):
        s.slots = []; s.depth = 0; s.nlong = 0; s.region = None; s.n = max(nlong, 1); s.pool_l = pooled_longs
        s.stack = []                                     # rule R6 (E3): freed op slots, the last freed on top
        s.log = []; s.nst = 0; s.remap = None            # the request log (fpwindow.plan) and the second pass's remap
        if nlong and not pooled_longs and LONG_TOP:        # fo_conv2: the long above the double built before it
            s.region = [4 * (s.n - i) for i in range(s.n)]; s.depth = 4 * s.n
    def begin_stmt(s, st=None):
        s.nst += 1; s.log.append(('stmt', s.nst, getattr(st, 'k', '?'), st))
        for sl in sorted(s.slots, key=lambda x: x[0]):   # (research-scratch sessions/2026-11-09_cc900-fp-prepass,
            if (sl[2] == 'op' or (sl[2] == 'long' and s.pool_l)) and sl[3]:   # b804104): shallow first, so the
                sl[3] = False                                                   # deepest ends on top
                if sl[0] in s.stack: s.stack.remove(sl[0])
                s.stack.append(sl[0])
    def get(s, size, kind):
        d = s.get0(size, kind); s.log.append(('get', kind, size, d, s.nst))
        return s.remap.get(d, d) if s.remap else d         # WINDOW_RULE: the first pass's depth, remapped (fpwindow)
    def get0(s, size, kind):
        if kind == 'long': s.nlong += 1
        reusable = kind == 'op' or (kind == 'long' and s.pool_l)
        free = [x for x in s.slots if reusable and not x[3] and x[1] == size and x[2] == kind]
        if free:                                         # R6: the free slot freed last (_atan's returns, __trig)
            depths = {x[0] for x in free}
            onstack = [d for d in s.stack if d in depths]
            pick = onstack[-1] if onstack else min(depths)
            sl = [x for x in free if x[0] == pick][0]; sl[3] = True
            if pick in s.stack: s.stack.remove(pick)
            return sl[0]
        if kind == 'long' and not s.pool_l:
            if s.region is None:
                base = s.depth; s.depth += 4 * s.n
                s.region = [base + 4 * (s.n - i) for i in range(s.n)]       # deepest first
            if s.region: d = s.region.pop(0)
            else: s.depth += 4; d = s.depth
            s.slots.append([d, 4, 'long', True]); return d
        s.depth += size; s.slots.append([s.depth, size, kind, True]); return s.depth

def frame_allocs(F):
    if '_fa' not in F.__dict__:
        F._fa = FrameAlloc(getattr(F, 'fp_nlong', 0)); F._fb = FrameAlloc(getattr(F, 'fp_nlong', 0), True)
        F._fa.remap = getattr(F, 'fp_remap', None) or None
    return F._fa, F._fb

FP_UNARY_HALF = False                                     # a statement without a double + - * / uses the region D alone

def begin_stmt(F, st=None):
    bins = []                                              # (random r4_01_10: vd(-gda[0]) in dec 0x8,XSP, the temporary at XSP)
    if st is not None and hasattr(st, 'k'):
        C().walk(st, lambda n, d: bins.append(n) if n.k in ('bin', 'opassign') and n.op in ('+', '-', '*', '/') and
                 is_fp(getattr(n, 'ty', None)) else None)
    F.fp_stmt_bin = bool(bins) or st is None
    F.pend_at_stmt = F.pending                           # (kept only through a statement that calls: random r1_08_03's
    e_ = getattr(st, 'e', None) if getattr(st, 'k', None) == 'expr' else None   # vc(t); gd2 = gda[2] releases them first)
    if e_ is None or getattr(C().strip(e_), 'k', None) != 'call': F.pend_at_stmt = -1   # (a bare call statement, where gen_stmt
                                                         #  applied the merge limit; fpp8.c mc03's gd3 = fd(..) releases them)
    if getattr(F, 'fp_temps', None) is None: return
    A, B = frame_allocs(F); A.begin_stmt(st); B.begin_stmt(st)

def temp(F, size, kind='op'):
    """a frame temporary (FrameAlloc); the region is D + D' (s_conv2: 16 + 12 = 28; no long: twice D)"""
    A, B = frame_allocs(F)
    if getattr(F, 'fp_has_switch', None) is None:        # fpargf.c af_VNWNP, fpargg.c ag_S*: a function with a switch
        sw = []                                           # statement, before or after, has the region D alone (8 bytes,
        C().walk(F.f.body, lambda n, d_: sw.append(n) if n.k == 'switch' and getattr(C().strip(n.value), 'ty', None) is not None
                 and C().strip(n.value).ty.size <= 2 else None)   # the temporary at XSP); not a long selector (random r4_03_19)
        F.fp_has_switch = bool(sw)
    lab = (FP_SWITCH_HALF and F.fp_has_switch) or (FP_UNARY_HALF and not F.opt and not getattr(F, 'fp_stmt_bin', True))
    d = A.get(size, kind); B.get(0 if lab else size, kind)
    F.ftemp_max = max(getattr(F, 'ftemp_max', 0), A.depth + B.depth)
    return getattr(F, 'ftemp_top', 0) - d

class Cell:
    """a temporary allocated at its first write (fp_temps.c: t_ci's long temporary sits above the double that
    the conversion writes after it)"""
    def __init__(s, size): s.size = size; s.off = None

def alloc(F, cell, kind='op'):
    if cell.off is None: cell.off = temp(F, cell.size, kind)
    return cell.off

def slot_addr(F, off): return 'XSP+%s' % C().hx(off + F.push) if off + F.push else 'XSP'
def slot_mem(F, off): return '(%s)' % slot_addr(F, off)

def fp_value_cast(e):
    """a FloatingCast between equal sizes is nothing; an integer constant converted is an FP constant (d_st_0)"""
    e = strip(e)
    while e.k == 'cast' and e.kind in ('FloatingCast', 'NoOp') and is_fp(strip(e.e).ty) and strip(e.e).ty.size == e.ty.size:
        e = strip(e.e)
    if e.k == 'cast' and e.kind == 'IntegralToFloating':
        c = C().fold(e.e)
        if c.k == 'const' and c.value is not None:
            from frontend import N
            return N('fconst', value=float(c.value), ty=e.ty)
    if e.k == 'un' and e.op == '-' and fp_value_cast(e.e).k == 'fconst':      # _exp: -708.396 is a constant
        from frontend import N
        return N('fconst', value=-fp_value_cast(e.e).value, ty=e.ty)
    return e

def lvalue_addr(F, v, reg):
    """the address of an FP object v (a var / deref / member / index node) into reg, or False"""
    cg = C(); v = strip(v)
    if v.k == 'var':
        d = v.decl
        if d.kind == 'global': F.emit('lda', '%s,_%s' % (reg, d.name)); return True
        if d.kind == 'param' and getattr(d, 'home_slot', False):   # adecl float stored at entry (adfp.c ad_fi)
            F.emit('lda', '%s,%s' % (reg, slot_addr(F, d.slot))); return True
        if d.kind == 'param' and not getattr(d, 'reg', None): F.emit('lda', '%s,%s' % (reg, slot_addr(F, d.off))); return True
        if d.kind == 'local' and hasattr(d, 'slot'): F.emit('lda', '%s,%s' % (reg, slot_addr(F, d.slot))); return True
        return False
    if v.k == 'deref':
        p = strip(v.e)
        m = cg.mem_operand(F, p)
        if m is not None: F.emit('ld', '%s,%s' % (reg, m)); return True       # d_ptr: ld XBC,(XSP+0x8)
        return False
    if v.k == 'member' and not v.arrow:
        g = cg.global_offset(v)
        if g and g[0] != '__param__':
            F.emit('lda', '%s,_%s + %s' % (reg, g[0], g[1]) if g[1] != '0x0' else '%s,_%s' % (reg, g[0])); return True
        b = strip(v.base)
        if b.k == 'var' and b.decl.kind == 'local' and getattr(b.decl, 'slot', None) is not None:
            off = cg.member_offset(v)                      # _frexp: d.d = x -> lda XWA,XSP+0x2 (a local union)
            F.emit('lda', '%s,%s' % (reg, slot_addr(F, b.decl.slot + off))); return True
        gi = elem_member(v)
        if gi:                                             # _cos: PAI5 = g_dbltbl[2].val -> lda XBC,_g_dbltbl + 0x10
            F.emit('lda', '%s,_%s + %s' % (reg, gi[0], cg.hx(gi[1])) if gi[1] else '%s,_%s' % (reg, gi[0])); return True
        return False
    if v.k == 'index':
        b = strip(v.base)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            i = cg.fold(v.idx)
            if i.k == 'const':
                off_ = i.value * v.ty.size                   # (fpord.c fo_a_GGZ: element 0 is lda XDE,_kda)
                F.emit('lda', '%s,_%s + %s' % (reg, b.decl.name, cg.hx(off_)) if off_ or not FP_ORD else '%s,_%s' % (reg, b.decl.name)); return True
            im = cg.mem_operand(F, cg.narrow(v.idx, 2))
            if im is None: return False
            if not im.startswith('(') and reg == 'XDE' and cg.family_of(im) not in (None, 'XWA', 'XBC'):
                F.emit('ld', 'WA,%s' % im)                     # d_loop: ld WA,IZ / sla 0x3,WA / lda XBC,_gda /
                F.emit('sla', '%s,WA' % cg.hx({8: 3, 4: 2}[v.ty.size]))   # lda XDE,XBC+WA
                F.emit('lda', 'XBC,_%s' % b.decl.name); F.emit('lda', 'XDE,XBC+WA'); return True
            scratch = {'XWA': 'XBC', 'XBC': 'XDE', 'XDE': 'XBC'}[reg]
            r16 = cg.FAM[cg.family_of(reg)[1:]][2]
            F.emit('ld', '%s,%s' % (r16, im))                                    # d_arr: ld BC,(XSP+0x8) / sla 0x3,BC /
            F.emit('sla', '%s,%s' % (cg.hx({8: 3, 4: 2}[v.ty.size]), r16))      # lda XDE,_gda / exts XBC / add XBC,XDE
            F.emit('lda', '%s,_%s' % (scratch, b.decl.name))
            F.emit('exts', reg); F.emit('add', '%s,%s' % (reg, scratch)); return True
    return False

def addressable(F, e):
    e = fp_value_cast(e)
    if e.k == 'fconst': return True
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var': return v.decl.kind in ('global', 'param') or hasattr(v.decl, 'slot')
        return v.k in ('deref', 'member', 'index')
    return False

def addr_of(F, e, reg):
    """reg = the address of FP rvalue e; computes it into a temporary when it is not in memory"""
    e = fp_value_cast(e)
    if e.k == 'fconst':
        F.emit('lda', '%s,%s' % (reg, const_label(F, e.value, e.ty))); return
    if e.k == 'load':
        if lvalue_addr(F, e.e, reg): return
        raise C().Unsupported('fp operand ' + strip(e.e).k)
    off = temp(F, e.ty.size)
    eval_into(F, e, ('slot', off))
    F.emit('lda', '%s,%s' % (reg, slot_addr(F, off)))

def dest_first(F, dest):
    """a result address that has to be loaded or computed is formed before the operands: the hidden pointer
    (d_add_gg: ld XWA,(XSP+0x4)), a pointer (d_ptr_st), an indexed element (d_arr_st); a named or stack object's
    address is formed last (d_add_st: lda XWA,_gd)"""
    if dest[0] == 'sret': F.emit('ld', 'XWA,(XSP+%s)' % C().hx(F.sret.off + F.push)); return True
    if dest[0] == 'xizh': F.emit('ld', 'XWA,XIZ'); return True      # the homed pointer: a register copy, first
    if dest[0] == 'lv':
        v = strip(dest[1])
        named = v.k == 'var' or (v.k == 'member' and not v.arrow) or (v.k == 'index' and C().fold(v.idx).k == 'const')
        if not named:
            if not lvalue_addr(F, v, 'XWA'): raise C().Unsupported('fp destination')
            return True
    return False

def dest_last(F, dest):
    if dest[0] in ('sret', 'xizh'): return
    if dest[0] == 'xiz': F.emit('ld', 'XWA,XIZ'); return             # t_mla: lda XBC,.. / lda XDE,.. / ld XWA,XIZ
    if dest[0] == 'cell': F.emit('lda', 'XWA,%s' % slot_addr(F, alloc(F, dest[1]))); return
    if dest[0] == 'slot': F.emit('lda', 'XWA,%s' % slot_addr(F, dest[1])); return
    if dest[0] == 'lv':
        if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')
        return
    raise C().Unsupported('fp destination')

def prepare(F, ops):
    """operands that are not in memory are computed into temporaries first, the right one first (d_four,
    t_st_mm: gd4 * gd2 into +0x18, then gd2 * gd3 into +0x10, then the sum into _gd)"""
    out = [None] * len(ops)
    order = list(reversed(range(len(ops))))
    if len(ops) == 2 and holds_xiz(ops[0]) and not holds_xiz(ops[1]): order = [0, 1]   # fo_log: LN2 * n before 2 * s
    for i in order:
        out[i] = eval_val(F, ops[i], None)
    return out

def ncalls(e):
    found = []
    C().walk(e, lambda n, d: found.append(n) if n.k == 'call' else None)
    return len(found)

def has_call(e):
    found = []
    C().walk(e, lambda n, d: found.append(n) if n.k == 'call' else None)
    return bool(found) or getattr(e, 'k', None) == 'call'

def eval_val(F, e, hint):
    """make FP value e an operand: e itself when it is in memory, else a temporary ('slot', off).  hint: a Cell the
    caller would like the value in.  An operation writes over its computed left operand's temporary (t_chain4:
    three products in +0xc; t_mm: (gd*gd2 into +0x10) + (gd3*gd4 into +0x18) -> +0x10); a call gets its own
    temporary unless it is handed one (t_call_a: fd(a) into +0x10, the sum into the hint +0x18)."""
    e = fp_value_cast(e)
    if addressable(F, e): return e
    if e.k == 'call':
        cell = hint if hint is not None else Cell(e.ty.size)
        call_into(F, e, ('cell', cell)); return ('slot', cell.off)
    if e.k in ('bin', 'un', 'cast') and not (e.k == 'cast' and e.kind == 'IntegralToFloating'):
        ops = [e.l, e.r] if e.k == 'bin' else [e.e]
        comp = [i for i, x in enumerate(ops) if not addressable(F, fp_value_cast(x))]
        vals = [fp_value_cast(x) for x in ops]
        if len(comp) == 2 and holds_xiz(ops[0]) and not holds_xiz(ops[1]):
            vals[0] = eval_val(F, ops[0], hint); vals[1] = eval_val(F, ops[1], None); dst = ('slot', vals[1][1])
        elif len(comp) == 2 and CALL_OP_LEFT_FIRST and ncalls(ops[0]) > ncalls(ops[1]):
            vals[0] = eval_val(F, ops[0], hint); vals[1] = eval_val(F, ops[1], None); dst = ('slot', vals[0][1])
            if e.op in ('+', '*') and COMMUTE_LAST_XBC: vals = [vals[1], vals[0]]   # (the last computed in XBC)
            # the operand with more calls is evaluated first, the right one on a tie: fpp7 w4 gd2 * gd3 + fd(gd4)
            # calls first; w5 fd(gd4) + gd2 * gd3 calls first; w7 (fd(gd2) + fd(gd3)) + fd(gd4) adds first (two
            # calls against one), its inner sum calling fd(gd3) before fd(gd2) (a tie)
        elif len(comp) == 2:
            vals[1] = eval_val(F, ops[1], hint); vals[0] = eval_val(F, ops[0], None); dst = ('slot', vals[0][1])
        elif len(comp) == 1 and fp_value_cast(ops[comp[0]]).k != 'call':
            vals[comp[0]] = eval_val(F, ops[comp[0]], hint); dst = vals[comp[0]]
        else:
            cell = hint if hint is not None else Cell(e.ty.size)
            if comp:                                         # d_call_e: fd(a * 2.0) + a: the argument's product takes
                c0 = fp_value_cast(ops[comp[0]])             # the hint (+0x18), fd's result a fresh one (+0x10), the
                if c0.k == 'call':                           # sum the hint again; the sum's slot is taken before the
                    alloc(F, cell)                           # call (_cos: fabs(x) + PAI5 at +0x20, fabs at +0x18)
                    cc = Cell(c0.ty.size); call_into(F, c0, ('cell', cc), arg_hint=cell); vals[comp[0]] = ('slot', cc.off)
                else: vals[comp[0]] = eval_val(F, ops[comp[0]], None)
            op_into(F, e, vals, ('cell', cell)); return ('slot', cell.off)
        op_into(F, e, vals, dst); return dst
    cell = hint if hint is not None else Cell(e.ty.size)
    eval_into(F, e, ('cell', cell)); return ('slot', cell.off)

def op_into(F, e, vals, dest):
    """the helper call of a +-*/, unary - or float/double conversion node whose operands are ready"""
    if e.k == 'bin':
        if not (FP_PEND_KEEP and not F.opt and F.pending and F.pending == getattr(F, 'pend_at_stmt', -1)):
            C().flush_pops(F)                              # _log: x /= ldexp(1, nptr) -> cal _ldexp / lda XSP,XSP+0x1e first
        name = '._f%s_%s' % ({'+': 'add', '-': 'sub', '*': 'mul', '/': 'div'}[e.op], sfx(e.ty))
        if fo_plain(F, e, vals, dest, name): return
        if e.op in '+*' and rank(F, vals[1]) > rank(F, vals[0]) and not (
                simple_addr(F, vals[0]) is not None and simple_addr(F, vals[0]) == dest_simple(F, dest)):   # _exp: t = t * w
            vals = [vals[1], vals[0]]                      # t_amla: gd3 + gd*gd2 -> XBC = the product, XDE = _gd3;
                                                           # _cos: fabs(x) + PAI5 -> XBC = _g_dbltbl + 0x10
        if F.opt and dest[0] not in ('sret', 'xiz'):
            sa, sb, sd = simple_addr(F, vals[0]), simple_addr(F, vals[1]), dest_simple(F, dest)
            if sa is not None and sa == sd:                  # d_add_asg: lda XWA,_gd / ld XBC,XWA / lda XDE,_gd2; a
                k = addr_kind(F, vals[1])                    # computed XDE first (d_loop: lda XDE,XBC+WA / lda XWA,..)
                if k == 'ld': put_addr(F, vals[1], 'XDE')
                F.emit('lda', 'XWA,%s' % sd); F.emit('ld', 'XBC,XWA')
                if k != 'ld': put_addr(F, vals[1], 'XDE')
                F.emit('cal', name); return
            if sb is not None and sb == sd and sa is not None and sa != sb:   # _exp: w = x / w -> lda XBC,x /
                put_addr(F, vals[0], 'XBC'); F.emit('lda', 'XWA,%s' % sd); F.emit('ld', 'XDE,XWA')   # lda XWA,w / ld XDE,XWA
                F.emit('cal', name); return
            if sa is not None and sa == sb and sd is not None:   # d_loc: lda XDE,XSP+0x10 / ld XBC,XDE / lda XWA,XSP
                put_addr(F, vals[1], 'XDE'); F.emit('ld', 'XBC,XDE'); F.emit('lda', 'XWA,%s' % sd); F.emit('cal', name); return
        if F.opt and dest[0] == 'sret':
            sa, sb = simple_addr(F, vals[0]), simple_addr(F, vals[1])
            if sa is not None and sa == sb:
                dest_first(F, dest); put_addr(F, vals[1], 'XDE'); F.emit('ld', 'XBC,XDE'); F.emit('cal', name); return
        emit_operands(F, dest, vals); F.emit('cal', name); return
    if e.k == 'un':
        if COPY_DEST_FIRST and FP_ORD and not F.opt and dest[0] == 'lv' and fo_lv_kind(dest[1]) == 'A' and \
                len(vals) == 1 and fo_kind(F, vals[0]) in ('G', 'A') and e.ty.size == 8:
            C().flush_pops(F)                              # (random r4_06_09: gda[2] = -gda[2] -> lda XWA,_gda + 0x10 /
            if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')   # lda XBC,_gda + 0x10 / cal ._fneg_d)
            put_addr(F, vals[0], 'XBC'); F.emit('cal', '._fneg_d'); return
        emit_operands(F, dest, vals); F.emit('cal', '._fneg_%s' % sfx(e.ty)); return
    emit_operands(F, dest, vals); F.emit('cal', '._fld_%s%s' % (sfx(e.ty), sfx(strip(e.e).ty)))

COPY_DEST_FIRST = True                                    # see eval_into: gda[1] = gda[2]
FO_SELF = True                                            # see fo_plain: gd2 *= gs.d
CMP_K_SWAP = True                                         # see compare: 100.0 == gd
FP_ORD = True                                             # see fo_plain

def fo_kind(F, x):
    """'G' a plain global double, 'A' a static member or constant element of a global (an address with an offset
    computation: gs.d, gda[3], gda[0]), 'K' a constant; None for anything else (a temporary, a local, a pointer)"""
    if isinstance(x, tuple): return None
    e = fp_value_cast(x)
    if getattr(e, '_xiz', False): return None
    if e.k == 'fconst': return 'K'
    if e.k != 'load' or getattr(e, 'ty', None) is None or e.ty.size != 8: return None
    return fo_lv_kind(e.e)

def fo_lv_kind(v):
    v = strip(v)
    if v.k == 'var': return 'G' if v.decl.kind == 'global' and not getattr(v.decl, 'reg', None) else None
    if v.k == 'member' and not v.arrow:
        b = strip(v.base)
        return 'A' if b.k == 'var' and b.decl.kind == 'global' else None
    if v.k == 'index' and C().fold(v.idx).k == 'const':
        b = strip(v.base)
        while b.k in ('decay', 'cast', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
        return 'A' if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' else None
    return None

def fo_plain(F, e, vals, dest, name):
    """a double + - * / of two plain operands -- a global (G), a static member or constant element (A), a constant
    (K) -- without -O, cdecl (corpus/probes/fpord.c, run 2026-11-12-13-micro-fpord):
    - + and * swap their operands when the left is a constant or both are A (fo_a_GMM: gd = hs.d + ks.d ->
      lda XDE,_hs + 0x2 / lda XBC,_ks + 0x2 / lda XWA,_gd); - and / never do;
    - the A operands are addressed first, in source order, then the others, XBC before XDE (fo_a_GGM:
      lda XDE,_ks + 0x2 / lda XBC,_hd; fo_s_GKE: lda XDE,_kda + 0x18 / lda XBC,S);
    - a plain destination is addressed last, an A destination first (fo_a_EGM: lda XWA,_gda + 0x10 / lda XDE,_ks + 0x2 /
      lda XBC,_hd);
    - an A destination beside two A operands, or beside an A right operand of - or /, gets the result through a
      temporary (fo_s_EGM: .. / lda XWA,XSP+0x8 / cal ._fsub_d / lda XWA,_gda + 0x10 / lda XBC,XSP+0x8 / cal ._fld_dd).
    True when it wrote the call."""
    if not FP_ORD or F.opt or F.adecl or len(vals) != 2: return False
    ka, kb = fo_kind(F, vals[0]), fo_kind(F, vals[1])
    if ka is None or kb is None or (ka == 'K' and kb == 'K'): return False
    if dest[0] == 'lv':
        dv = strip(dest[1])                                # (a local double is a plain destination: fo_a_TGM)
        dk = 'G' if dv.k == 'var' and dv.decl.kind == 'local' and not getattr(dv.decl, 'reg', None) else fo_lv_kind(dest[1])
    elif dest[0] in ('slot', 'cell'): dk = 'G'
    else: dk = None
    if dk is None: return False
    sd = dest_simple(F, dest)
    if sd is not None and sd in (simple_addr(F, vals[0]), simple_addr(F, vals[1])) and \
            not (FO_SELF and dk == 'G' and sd == simple_addr(F, vals[0]) and kb == 'A'):
        return False                                       # (gd = gd + x: the older paths; gd2 *= gs.d follows the
                                                           #  rule, random r2_09_00: lda XDE,_gs + 0x1e / lda XBC,_gd2 / lda XWA,_gd2)
    comm = e.op in '+*'
    order = ['XBC', 'XDE']                                 # the registers of the left and the right operand
    if comm and (ka == 'K' or (ka == 'A' and kb == 'A')): vals = [vals[1], vals[0]]; ka, kb = kb, ka; order = ['XDE', 'XBC']
    kind = {'XBC': ka, 'XDE': kb}; val = {'XBC': vals[0], 'XDE': vals[1]}
    seq = [r for r in order if kind[r] == 'A'] + [r for r in ('XBC', 'XDE') if kind[r] != 'A']
    via = dk == 'A' and ((ka == 'A' and kb == 'A') or (not comm and kb == 'A'))
    if dk == 'A' and not via:
        if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')
    for r in seq: put_addr(F, val[r], r)
    if via:
        t = temp(F, 8)
        F.emit('lda', 'XWA,%s' % slot_addr(F, t)); F.emit('cal', name)
        if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')
        F.emit('lda', 'XBC,%s' % slot_addr(F, t)); F.emit('cal', '._fld_dd'); return True
    if dk != 'A': dest_last(F, dest)
    F.emit('cal', name); return True

LOCAL_MEMBER_FIRST = True                                 # see addr_kind
SAME_OPERAND_COPY = True                                  # see emit_operands

def addr_kind(F, x):
    """'lda' when the address is a name, a stack offset or a constant; 'ld' when it has to be loaded, copied from a
    register or computed"""
    if isinstance(x, tuple): return 'lda'
    e = fp_value_cast(x)
    if e.k == 'fconst': return 'lda'
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var': return 'lda'
        if v.k == 'member' and not v.arrow:            # _log: x / SQRT2 (s_logtbl.val, a static union) -> lda XDE,
            b = strip(v.base)                            # _s_logtbl before lda XBC,x
            if LOCAL_MEMBER_FIRST and b.k == 'var' and b.decl.kind == 'local' and getattr(b.decl, 'storage', None) != 'static':
                return 'ld'                              # cond_bits.c cb_union_c7: d.d = x -> lda XWA,XSP / lda XBC,..
            return 'ld' if MEMBER_FIRST and b.k == 'var' and (b.decl.kind == 'static' or b.decl.storage == 'static') else 'lda'
        if v.k == 'index' and C().fold(v.idx).k == 'const': return 'lda'
    return 'ld'

def dest_kind(F, dest):
    if dest[0] in ('sret', 'xizh'): return 'ld'
    if dest[0] in ('slot', 'cell', 'xiz'): return 'lda'
    from frontend import N
    return addr_kind(F, N('load', e=dest[1], ty=dest[1].ty))

def emit_operands(F, dest, ops):
    """the result address and the operand addresses: those that are loaded, copied or computed first, in XWA, XBC,
    XDE order (d_add_gg: ld XWA,(XSP+0x4); _modf: ld XDE,XIZ / lda XBC,XSP+0x24 / lda XWA,XSP+0x14), then the
    named and stack ones in XBC, XDE, XWA order (d_add_st: lda XBC,_gd2 / lda XDE,_gd3 / lda XWA,_gd)"""
    if not (FP_PEND_KEEP and not F.opt and F.pending and F.pending == getattr(F, 'pend_at_stmt', -1)):
        C().flush_pops(F)                                  # the pending call pops go before a helper's addresses; those
                                                           # of an earlier call statement wait (fpargf.c af_VNCNP: cal _vs /
                                                           # lda XBC,_gd / .. / lda XWA,XSP+0xc / cal ._fmul_d)
    items = [('XWA', None)] + list(zip(('XBC', 'XDE'), ops))
    kinds = {'XWA': dest_kind(F, dest)}
    for r, x in items[1:]: kinds[r] = addr_kind(F, x)
    def do(r, x):
        if r == 'XWA':
            if not dest_first(F, dest): dest_last(F, dest)
        else: put_addr(F, x, r)
    held = [(r, x) for r, x in items[1:] if in_xiz(x)]     # fo_mem_n: lda XBC,.. / lda XWA,.. / ld XDE,XIZ
    if F.opt and SAME_OPERAND_COPY and len(ops) == 2 and not held and kinds['XBC'] == kinds['XDE'] == 'lda' and \
            not isinstance(ops[0], tuple) and not isinstance(ops[1], tuple) and C().same_leaf(ops[0], ops[1]):
        if kinds['XWA'] == 'ld': do('XWA', None)           # (a result address that is loaded goes first)
        put_addr(F, ops[1], 'XDE'); F.emit('ld', 'XBC,XDE')   # fp_stmts.c s_loc (-O3 -XS): a * a -> lda XDE,XSP+0x20 /
        if kinds['XWA'] != 'ld': do('XWA', None)           # ld XBC,XDE / lda XWA,.. (one address, copied)
        return
    if held and any(getattr(fp_value_cast(x), '_xiz_opa', False) for r, x in held):
        for r, x in items[1:]:                             # a compound assignment's target in XIZ (fpopa.c fa_m_MGT):
            if (r, x) not in held: do(r, x)                # lda XDE,_hd / ld XBC,XIZ / ld XWA,XIZ
        for r, x in held: do(r, x)
        do('XWA', None); return
    for r, x in items:
        if kinds[r] == 'ld' and (r, x) not in held: do(r, x)
    late = items[1:] + items[:1]
    if XDE_ELEM_FIRST and len(ops) == 2 and not held and kinds['XBC'] == kinds['XDE'] == 'lda' and \
            not isinstance(ops[0], tuple) and not isinstance(ops[1], tuple):
        a_, b_ = fp_value_cast(ops[0]), fp_value_cast(ops[1])   # fpopa.c fa_m_GET, fpargf.c af_VNNNE: gd * gda[3] ->
        if b_.k == 'load' and const_elem(b_.e) and C().strip(b_.e).k == 'index' and a_.k == 'load' and \
                C().strip(a_.e).k == 'var':                     # lda XDE,_gda + 0x18 / lda XBC,_gd / lda XWA,..
            late = [items[2], items[1], items[0]]
    for r, x in late:
        if kinds[r] == 'lda' and (r, x) not in held: do(r, x)
    for r, x in held: do(r, x)

def put_addr(F, x, reg):
    if isinstance(x, tuple): F.emit('lda', '%s,%s' % (reg, slot_addr(F, x[1])))
    elif in_xiz(x): F.emit('ld', '%s,XIZ' % reg)            # a hoisted element (elem_hoists)
    else: addr_of(F, x, reg)

def int_to_long_temp(F, e, reg_family):
    """an integer value widened to a long in a 4-byte temporary; returns its frame offset"""
    cg = C(); e = strip(e); t = e.ty
    R4 = cg.FAM[reg_family][4]; R2 = cg.FAM[reg_family][2]; R1 = cg.FAM[reg_family][1]
    m = cg.mem_operand(F, e)
    if t.size == 1 and not t.signed and m is not None:
        F.emit('ld', '%s,0x0' % R4); F.emit('ld', '%s,%s' % (R1, m))         # d_from_uc: ld XBC,0x0 / ld C,(_guc)
    elif t.size == 1 and m is not None:
        F.emit('ld', '%s,%s' % (R1, m)); F.emit('exts', R2); F.emit('exts', R4)
    elif t.size == 2 and m is not None:
        F.emit('ld', '%s,%s' % (R2, m)); F.emit('exts' if t.signed else 'extz', R4)
    elif t.size == 2 and e.k == 'call':
        cg.gen_call(F, e); cg.flush_pops(F)
        if F.opt: F.emit('exts' if t.signed else 'extz', 'XHL'); R4 = 'XHL'           # d_call_i under O3XS
        else: F.emit('ld', '%s,HL' % R2); F.emit('exts' if t.signed else 'extz', R4)   # d_call_i: ld WA,HL / exts XWA
    else:
        fam = cg.gen(F, e, reg_family, t.size)
        if t.size == 1:                                    # random r1_07_13: (double)*gp with a char *gp ->
            F.emit('exts' if t.signed else 'extz', cg.FAM[fam][2])   # ld A,(XWA) / exts WA / exts XWA
        if t.size <= 2: F.emit('exts' if t.signed else 'extz', cg.FAM[fam][4])
        R4 = cg.FAM[fam][4]
    off = temp(F, 4, 'long')
    F.emit('ld', '%s,%s' % (slot_mem(F, off), R4))
    return off

def eval_into(F, e, dest):
    """compute FP expression e and store it at dest: ('sret',), ('slot', off), ('lv', lvalue node)"""
    cg = C(); e = fp_value_cast(e)
    gdest = dest[0] == 'lv' and strip(dest[1]).k == 'var' and strip(dest[1]).decl.kind == 'global'
    if gdest and e.k == 'cast' and e.kind == 'IntegralToFloating':
        pass
    if gdest and getattr(F, 'stmt_global', False) and e.k in ('bin', 'un') and (e.k == 'un' or len(e.op) == 1) and \
            (e.k == 'un' or e.op in '+-*/') and not getattr(F, '_root_done', False):
        # fp_stmts.c (R5g): a statement that stores an operation to a global takes the root's slot first and builds
        # its computed operand there (s_conv2: the double above the long; s_call2: +0x28 unused)
        ops = [e.l, e.r] if e.k == 'bin' else [e.e]
        comp = [i for i, x in enumerate(ops) if not addressable(F, fp_value_cast(x))]
        if comp:
            F._root_done = True
            cell = Cell(e.ty.size); alloc(F, cell)
            vals = [fp_value_cast(x) for x in ops]
            first = comp[-1] if len(comp) == 2 else comp[0]
            if len(comp) == 2 and CALL_OP_LEFT_FIRST and ncalls(ops[0]) > ncalls(ops[1]):
                first = 0                                    # fpp7 w4 / w5 / w7: the operand with more calls first
            c0 = fp_value_cast(ops[first])
            if c0.k == 'call':
                cc = Cell(c0.ty.size); call_into(F, c0, ('cell', cc), arg_hint=cell); vals[first] = ('slot', cc.off)
            elif c0.k == 'cast' and c0.kind == 'IntegralToFloating':
                eval_into(F, c0, ('cell', cell)); vals[first] = ('slot', cell.off)
            else: vals[first] = eval_val(F, ops[first], cell)
            for i in comp:
                if i != first: vals[i] = eval_val(F, ops[i], cell if c0.k == 'call' and ROOT_CELL_AFTER_CALL else None)
            if len(comp) == 2 and first == 0 and e.op in ('+', '*') and COMMUTE_LAST_XBC:
                vals = [vals[1], vals[0]]                    # the operand computed last goes to XBC (fpp7 w5:
            op_into(F, e, vals, dest); return                # lda XBC,<product> / lda XDE,<fd's result>)
    if e.k == 'bin' and e.op in '+-*/' and len(e.op) == 1:
        op_into(F, e, prepare(F, [e.l, e.r]), dest); return
    if e.k == 'un' and e.op == '-':
        op_into(F, e, prepare(F, [e.e]), dest); return
    if e.k == 'cond':
        cond_into(F, e, dest); return
    if e.k == 'cast' and e.kind == 'IntegralToFloating':
        src = strip(e.e)
        while src.k == 'cast' and src.kind == 'IntegralCast' and strip(src.e).ty.size <= src.ty.size and src.ty.size <= 2:
            src = strip(src.e)
        m = cg.mem_operand(F, src) if src.ty.size == 4 else None
        name = '._fld_%s%s' % (sfx(e.ty), conv_name(src.ty) if src.ty.size == 4 else ('l' if src.ty.signed else 'ul'))
        if src.ty.size == 4 and m is not None and m.startswith('('):
            first = dest_first(F, dest)
            F.emit('lda', 'XBC,%s' % m[1:-1])                                    # d_from_l: lda XBC,_gl
            if not first: dest_last(F, dest)
            F.emit('cal', name); return
        if dest[0] == 'sret':
            first = dest_first(F, dest); off = int_to_long_temp(F, src, 'BC')
        else:
            off = int_to_long_temp(F, src, 'WA'); first = False
        F.emit('lda', 'XBC,%s' % slot_addr(F, off))
        if not first: dest_last(F, dest)
        F.emit('cal', name); return
    if e.k == 'cast' and e.kind == 'FloatingCast':
        op_into(F, e, prepare(F, [e.e]), dest); return
    if e.k == 'call':
        call_into(F, e, dest); return
    if e.k not in ('load', 'fconst'): raise C().Unsupported('fp ' + e.k + ' ' + str(getattr(e, 'op', getattr(e, 'kind', ''))))
    # a copy (load, constant)
    if COPY_DEST_FIRST and FP_ORD and not F.opt and dest[0] == 'lv' and fo_lv_kind(dest[1]) == 'A' and \
            fo_kind(F, e) in ('G', 'A') and e.ty.size == 8:
        if not (C().POP_LAZY2 and not F.adecl and C().later_call_absorbs(F)): C().flush_pops(F)   # (r2_09_11: the pops wait)
                                                           # a member / element destination is addressed first in a copy
        if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')   # too (random r4_07_03:
        put_addr(F, e, 'XBC'); F.emit('cal', '._fld_dd'); return                         # gda[1] = gda[2] ->
                                                           # lda XWA,_gda + 0x8 / lda XBC,_gda + 0x10 / cal ._fld_dd)
    emit_operands(F, dest, [e])
    F.emit('cal', '._fld_%s%s' % (sfx(e.ty), sfx(e.ty)))

def push_fp_arg(F, a, hint=None):
    """a double argument: high half first, through XIY / XIX (d_call1: lda XIY,XSP+0x18 / ld XIX,(XIY+0x4) /
    push XIX / ld XIX,(XIY) / push XIX)"""
    a = fp_value_cast(a)
    if a.ty.size == 4 and a.k == 'load' and strip(a.e).k == 'var':
        m = C().mem_operand(F, a)                          # probes/adfp.c ac_fi: a float variable -> ld XWA,(_gf) /
        if m is not None and m.startswith('('):            # push XWA
            F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    put_addr(F, eval_val(F, a, hint), 'XIY')
    if a.ty.size == 8:
        F.emit('ld', 'XIX,(XIY+0x4)'); F.emit('push', 'XIX'); F.push += 4
    F.emit('ld', 'XIX,(XIY)'); F.emit('push', 'XIX'); F.push += 4
    return a.ty.size

def call_into(F, e, dest, arg_hint=None):
    """a call returning double: the caller's temporary's address is the hidden first argument"""
    cg = C()
    fn = strip(e.fn)
    n = 0
    hints = [arg_hint]
    def push_args():
        k = 0
        cg.args_begin(F)                                 # (fpp11 q15: no pop release between the pushes)
        for a in reversed(e.args):
            if is_fp(strip(a).ty): k += push_fp_arg(F, a, hints.pop() if hints else None)
            else: k += cg.push_arg(F, a)
        return k
    if dest[0] == 'lv' and strip(dest[1]).k == 'var' and strip(dest[1]).decl.kind == 'global' and arg_hint is None:
        g = strip(dest[1]).decl.name                     # abi returns.c use_d: gd = x_d() -> pushw _gd >> 16 /
        n += push_args()                                 # pushw _gd & 0xffff / cal _x_d / inc 0x4,XSP
        F.emit('pushw', '_%s >> 16' % g); F.emit('pushw', '_%s & 0xffff' % g); F.push += 4; n += 4
        F.emit('cal', '_' + fn.decl.name); cg.args_end(F); F.pending += n; return
    if arg_hint is not None:
        n += push_args()
    if CALL_INTO_LOCAL and dest[0] == 'lv' and strip(dest[1]).k == 'var' and strip(dest[1]).decl.kind == 'local' and \
            getattr(strip(dest[1]).decl, 'slot', None) is not None and strip(dest[1]).decl.ty.size == 8 and not F.adecl:
        dest = ('slot', strip(dest[1]).decl.slot)          # _floor: k = _fint(xx) -> the hidden pointer is k's own slot
    if dest[0] == 'lazyres':                               # the hint if the arguments left it free (call_val)
        off = alloc(F, dest[1], 'call') if dest[1].off is None else temp(F, 8, 'call')
        dest = ('slot', off)
    elif dest[0] == 'cell': off = alloc(F, dest[1], 'call')
    elif dest[0] == 'slot': off = dest[1]
    else: off = temp(F, 8, 'call')
    F.last_call_off = off
    if arg_hint is None: n += push_args()
    F.emit('lda', 'XWA,%s' % slot_addr(F, off)); F.emit('push', 'XWA'); F.push += 4; n += 4
    F.emit('cal', '_' + fn.decl.name); cg.args_end(F)
    F.pending += n                                         # _tan: cos's pops wait for sin's (lda XSP,XSP+0x18)
    if dest[0] == 'discard': return
    if dest[0] not in ('slot', 'cell') or (dest[0] == 'slot' and dest[1] != off):
        cg.flush_pops(F)
        first = dest_first(F, dest); F.emit('lda', 'XBC,%s' % slot_addr(F, off))
        if not first: dest_last(F, dest)
        F.emit('cal', '._fld_dd')

def gen_return(F, v):
    """return of a double (hidden pointer) or a float (XHL, through a frame temporary)"""
    if F.f.ret.size == 8:
        mode = root_mode(F, v)
        if mode == 'xiz' and holds_xiz(v): mode = 'copy'    # fo_mem_n: the product in a temporary, then copied
        if getattr(F, 'sret_home', False):                 # _sin: two returns -> the pointer homed in XIZ at entry
            if mode == 'copy':
                t1 = Cell(8)
                loc = eval_val(F, v, t1) if fp_value_cast(v).k != 'call' else call_val(F, fp_value_cast(v), t1)
                C().flush_pops(F); F.emit('ld', 'XWA,XIZ'); put_addr(F, loc, 'XBC'); F.emit('cal', '._fld_dd'); return
            eval_into(F, v, ('xizh',)); return
        if mode == 'xiz':                                    # t_mla: ld XIZ,(XSP+0x18) ... ld XWA,XIZ / cal ._fadd_d
            F.emit('ld', 'XIZ,(XSP+%s)' % C().hx(F.sret.off + F.push)); eval_into(F, v, ('xiz',)); return
        if mode == 'copy':                                   # t_mm: ... ld XWA,(XSP+0x24) / lda XBC,XSP+0x10 / cal ._fld_dd
            t1 = Cell(8)
            e0 = fp_value_cast(v)
            ops = [e0.l, e0.r] if e0.k == 'bin' else [e0.e] if e0.k in ('un', 'cast') else []
            if any(fp_value_cast(x).k == 'call' for x in ops):
                alloc(F, t1)                                 # t_call_a: the sum's +0x18 above fd(a)'s +0x10; d_call_i
                                                             # (a conversion of fi()) takes it at its first write
            loc = eval_val(F, v, t1) if e0.k != 'call' else call_val(F, e0, t1)
            C().flush_pops(F)
            F.emit('ld', 'XWA,(XSP+%s)' % C().hx(F.sret.off + F.push)); put_addr(F, loc, 'XBC'); F.emit('cal', '._fld_dd')
            return
        eval_into(F, v, ('sret',)); return
    e = fp_value_cast(v)
    if e.k == 'load' and strip(e.e).k == 'var':          # abi returns.c r_f: return gf -> ld XHL,(_gf)
        m = C().mem_operand(F, e)
        if m is not None: F.emit('ld', 'XHL,%s' % m); return
    off = F.fret_slot if getattr(F, 'fret_slot', None) is not None else temp(F, 4)
    eval_into(F, v, ('slot', off))
    F.emit('ld', 'XHL,%s' % slot_mem(F, off))

def gen_assign(F, e):
    """an FP assignment or compound assignment statement"""
    cg = C()
    if e.k == 'opassign':
        from frontend import N
        lv = strip(e.l)
        ld_ = N('load', e=lv, ty=lv.ty)
        b = N('bin', op=e.op, l=ld_, r=e.r, ty=lv.ty)
        hk = opa_target(F, lv)
        if hk is not None:                                 # probes/fpopa.c fa_m_MGT: gs.d *= hd -> lda XIZ,_gs + 0x4 /
            for d in list(F.f.params) + list(F.f.decls):   # lda XDE,_hd / ld XBC,XIZ / ld XWA,XIZ / cal ._fmul_d
                if getattr(d, 'reg', None) in ('IZ', 'QIZ', 'XIZ', 'QIZH') and d not in F.dead:
                    raise cg.Unsupported('a double compound assignment over the XIZ home of %s' % d.name)
            if F.xiz_vars != ['sret'] or needs_xiz(F) or getattr(F, 'sret_home', False) or \
                    getattr(F, 'call_temp', None):
                raise cg.Unsupported('a double compound assignment beside another XIZ use')
            if hk[0] == 'S' and lv.k == 'index' and ' + ' not in hk[1] and not F.opt:
                F.emit('lda', 'XWA,%s' % hk[1]); F.emit('ld', 'XIZ,XWA')   # element 0 is the array itself, taken
            elif hk[0] == 'S': F.emit('lda', 'XIZ,%s' % hk[1])             # through XWA (rstmt rs_3_00_17_0: gda[0] *= ..
                                                           # -> lda XWA,_gda / ld XIZ,XWA; gda[1]: lda XIZ,_gda + 0x8)
            else:                                          # fa_m_XGT: ld WA,(c) / sla 0x3,WA / lda XBC,_gda / lda XIZ,XBC+WA
                if hk[2] != 'WA': F.emit('ld', 'WA,%s' % hk[2])
                F.emit('sla', '0x3,WA'); F.emit('lda', 'XBC,%s' % hk[1])
                F.emit('lda', 'XIZ,XBC+WA')
            ld_._xiz = True; ld_._xiz_opa = True           # (the target stays the left operand: ld XBC,XIZ)
            eval_into(F, b, ('xiz',)); return
        if OPA_XIZ and lv.k == 'index' and cg.fold(lv.idx).k != 'const':   # (fpopa.c -Xr / -O3 -XS X rows: the element's
            raise cg.Unsupported('a double compound assignment at a computed element')   # address was built twice
        eval_into(F, b, ('lv', lv)); return                                              # over its index: wrong code)
    eval_into(F, e.r, ('lv', strip(e.l)))

def compare(F, c, value):
    """`._fcmp_d` / `._fcmp_zd`: HL = 1 when the relation holds; value: the relation, else the negated one"""
    cg = C()
    op = c.op if value else NEG[c.op]
    l, r = fp_value_cast(c.l), fp_value_cast(c.r)
    cg.flush_pops(F)
    if r.k == 'fconst' and r.value == 0.0 or (strip(r).k == 'cast' and strip(strip(r).e).k == 'const' and strip(strip(r).e).value == 0):
        a = prepare(F, [l]); cg.flush_pops(F); put_addr(F, a[0], 'XWA')
        F.emit('ld', 'BC,%s' % cg.hx(REL[op])); F.emit('cal', '._fcmp_z%s' % sfx(l.ty)); return
    if CMP_K_SWAP and not F.opt and not F.adecl and op in ('==', '!=') and l.k == 'fconst' and r.k != 'fconst':
        l, r = r, l                                        # a constant on the left of == / != is the right operand
                                                           # (random r1_03_18: 100.0 == gd -> lda XWA,_gd / lda XBC,S1)
    a = prepare(F, [l, r]); cg.flush_pops(F)              # fpp1.c b1: fd(..) >= 0.5 -> cal _fd / lda XSP,XSP+0xc
    put_addr(F, a[0], 'XWA'); put_addr(F, a[1], 'XBC')     # before the compare (inside the then arm was wrong code)
    F.emit('ld', 'DE,%s' % cg.hx(REL[op])); F.emit('cal', '._fcmp_%s' % sfx(l.ty))

def truth(F, c, value):
    """if (d), !d"""
    from frontend import N
    z = N('fconst', value=0.0, ty=c.ty)
    compare(F, N('bin', op='!=', l=c, r=z, ty=c.ty), value)

def to_int(F, e, size):
    """FloatingToIntegral: through a 4-byte temporary (d_to_i), result in XHL; returns the temp's offset.  For an
    int result the temporary is taken before the operand is built (t_to_i_e: +0x14 above the double at +0xc), for
    a long after it (t_to_l: the double at +0x10, the long at +0xc)"""
    src = strip(e.e)
    signed = e.ty.signed
    early = temp(F, 4, 'long') if e.ty.size <= 2 else None
    a = prepare(F, [src])
    put_addr(F, a[0], 'XBC')
    off = early if early is not None else temp(F, 4, 'long')
    F.emit('lda', 'XWA,%s' % slot_addr(F, off))
    F.emit('cal', '._fld_%s%s' % ('l' if signed else 'ul', sfx(src.ty)))
    return off

def uses_fp(f):
    """does the function do floating point (so that helper calls count as calls)?"""
    found = []
    C().walk(f.body, lambda n, d: found.append(n) if is_fp(getattr(n, 'ty', None)) else None)
    return bool(found) or is_fp(f.ret)

def is_fp_op(n):
    """a node that becomes a runtime call (so it clobbers everything but XIZ, like a call)"""
    k = getattr(n, 'k', None)
    if k in ('bin', 'opassign', 'un', 'cast') and is_fp(getattr(n, 'ty', None)):
        return not (k == 'cast' and n.kind in ('NoOp', 'LValueToRValue'))
    if k == 'bin' and n.op in REL and is_fp(getattr(strip(n.l), 'ty', None)): return True
    if k == 'cast' and n.kind == 'FloatingToIntegral': return True
    if k == 'un' and n.op == '!' and is_fp(getattr(strip(n.e), 'ty', None)): return True
    return False

def is_fp_copy(n):
    """an FP assignment or ?: (a ._fld_dd / ._fld_dl helper call, which clobbers the registers like a call;
    random r1_05_01: b in BC across double t = a ? gda[3] : gd2)"""
    k = getattr(n, 'k', None)
    return (k == 'bin' and n.op == '=' or k == 'cond') and is_fp(getattr(n, 'ty', None))

def lvalue_direct(F, e):
    """a long destination in memory takes the conversion directly (d_to_l_st)"""
    lv = strip(e.l); src = strip(strip(e.r).e)
    if not (lv.k == 'var' and lv.decl.kind == 'global'): return False
    a = prepare(F, [src]); put_addr(F, a[0], 'XBC')
    F.emit('lda', 'XWA,_%s' % lv.decl.name)
    F.emit('cal', '._fld_%s%s' % ('l' if lv.ty.signed else 'ul', sfx(src.ty))); return True

def simple_addr(F, x):
    """the lda operand of an operand whose address is a name or a stack offset, else None"""
    if isinstance(x, tuple): return slot_addr(F, x[1])
    e = fp_value_cast(x)
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var':
            d = v.decl
            if d.kind == 'global': return '_' + d.name
            if d.kind == 'param' and not getattr(d, 'reg', None): return slot_addr(F, d.off)
            if d.kind == 'local' and hasattr(d, 'slot'): return slot_addr(F, d.slot)
    return None

def dest_simple(F, dest):
    if dest[0] == 'slot': return slot_addr(F, dest[1])
    if dest[0] == 'lv':
        from frontend import N
        return simple_addr(F, N('load', e=dest[1], ty=dest[1].ty))
    return None

def root_mode(F, v):
    """how a returned double reaches the hidden pointer (fp_temps.c): 'direct' when the last operation has no
    computed operand (ld XWA,(XSP+0x4) first); 'xiz' when it has one that involves no call (t_mla, t_ci, t_neg) or
    is a ?: (t_cond); 'copy' when it has two, or a call result (t_mm, t_call_a, t_call_only, d_call_i): built in a
    temporary, then ._fld_dd"""
    e = fp_value_cast(v)
    if addressable(F, e): return 'direct'
    if e.k == 'call': return 'copy'
    if e.k == 'cond': return 'xiz'
    if e.k == 'cast' and e.kind == 'IntegralToFloating': return 'direct'
    ops = [e.l, e.r] if e.k == 'bin' else [e.e] if e.k in ('un', 'cast') else []
    comp = [x for x in ops if not addressable(F, fp_value_cast(x))]
    if not comp: return 'direct'
    if len(comp) == 2 or any(has_call(x) for x in comp): return 'copy'
    return 'xiz'

def needs_xiz(F):
    """does a return keep the hidden pointer in XIZ (push XIZ in the prologue)?"""
    if not (is_fp(F.f.ret) and F.f.ret.size == 8): return False
    if needs_sret_home(F): return True
    rets = []
    C().walk(F.f.body, lambda n, d: rets.append(n) if n.k == 'return' and n.value is not None else None)
    return any(root_mode(F, r.value) == 'xiz' for r in rets)

def cond_into(F, e, dest):
    """a ?: of doubles: the result in a temporary, then copied (t_cond: ... L1: lda XBC,XSP+0xc / ld XWA,XIZ /
    cal ._fld_dd); the first arm is built in its own temporary and copied, the second built in place (t_cond_e)"""
    cg = C()
    r = Cell(8); alloc(F, r)
    lelse = F.newulabel(); lend = F.newulabel()
    cg.gen_cond_false(F, e.c, lelse)
    a = eval_val(F, e.a, None)
    emit_operands(F, ('cell', r), [a]); F.emit('cal', '._fld_dd')
    F.emit('j', lend); F.lines.append(lelse + ':')
    eval_into(F, e.b, ('cell', r))
    F.lines.append(lend + ':')
    emit_operands(F, dest, [('slot', r.off)]); F.emit('cal', '._fld_dd')

def hoist_common(lines):
    """-O3 -XS: after `cal ._fcmp_*` / `cp HL,0x0` / `j cc,L`, an ld / lda that both branches set before their
    first call moves above the test, each one right after the compare's call (_fabs: lda XBC,XSP+0x8 /
    ld XWA,(XSP+0x4) / cp HL,0x0; d_cond: lda XWA,XSP+0xc), unless an earlier instruction of either branch uses its
    register"""
    import re
    def regs(t):
        return set(re.findall(r'\bX?(WA|BC|DE|HL|IX|IY|IZ)\b|\b([ABCDEHLW])\b', t))
    def fam(t):
        out = set()
        for m in re.findall(r'\b(?:X|Q)?(WA|BC|DE|HL|IX|IY|IZ)\b', t): out.add(m)
        for m in re.findall(r'\b([AW])\b', t): out.add('WA')
        for m in re.findall(r'\b([BC])\b', t): out.add('BC')
        for m in re.findall(r'\b([DE])\b', t): out.add('DE')
        for m in re.findall(r'\b([HL])\b', t): out.add('HL')
        return out
    def prefix(i):
        out = []
        while i < len(lines) and lines[i].startswith('\t') and not lines[i].startswith(('\tcal', '\tj', '\tret', '\tpush',
                                                                                    '\tpop', '\tinc\t', '\tdec\t')) \
                and 'XSP,XSP' not in lines[i]:             # _sin: after pushw 0x1, XSP+0x2e is another slot
            out.append(i); i += 1
        return out
    i = 0
    while i < len(lines):
        if lines[i].startswith('\tcal\t._fcmp') and i + 2 < len(lines) and lines[i + 1] == '\tcp\tHL,0x0' \
                and lines[i + 2].startswith('\tj\t') and ',' in lines[i + 2]:
            target = lines[i + 2].split(',')[1]
            try: li = lines.index(target + ':')
            except ValueError: i += 1; continue
            pv = lines[li - 1] if li else ''
            if not (pv.startswith(('\tj\t', '\tjp\t')) and ',' not in pv or pv.startswith('\tret')):
                i += 1; continue                           # (the target is also reached by falling in, after a call
                                                           # that may change the register: _fmod's ._fneg_d / L10)
            if sum(1 for l in lines if l.startswith('\tj') and l.endswith((',' + target, '\t' + target))) != 1:
                i += 1; continue                           # (another jump reaches it after a call: _tanh's L2, where
                                                           # the hoisted ld DE,0x0 held only on the first path)
            a, b = prefix(i + 3), prefix(li + 1)
            gone_a, gone_b, hoisted = set(), set(), []
            for k, ia in enumerate(a):
                t = lines[ia]
                if not re.match(r'^\t(ld|lda)\t', t): continue
                dst, src = t.split('\t')[2].split(',', 1)
                if 'HL' in fam(dst): continue
                hits = [x for x in b if lines[x] == t and x not in gone_b]
                if not hits: continue
                kb = b.index(hits[0])
                before = [lines[x] for x in a[:k] if x not in gone_a] + [lines[x] for x in b[:kb] if x not in gone_b]
                if any(fam(dst) & fam(u) for u in before): continue
                if any(fam(u.split('\t')[2].split(',')[0]) & fam(src) for u in before if u.count('\t') >= 2): continue
                gone_a.add(ia); gone_b.add(hits[0]); hoisted.append(t)
            if hoisted:
                keep = [l for x, l in enumerate(lines) if x not in gone_a and x not in gone_b]
                order = {'XBC': 0, 'XDE': 1, 'XWA': 2}            # _fabs: lda XBC / ld XWA; t_cond_e: lda XBC / lda XDE
                hoisted.sort(key=lambda t: order.get(t.split('\t')[2].split(',')[0], 3))
                pos = i + 1
                for t in reversed(hoisted): keep.insert(pos, t)
                lines[:] = keep; i += len(hoisted)
        i += 1
    return lines

def call_stmt(F, e):
    """a call whose arguments include a double (d_call_v: vd(gd + gd2)): the double pushed through XIY / XIX, the
    pops released at once.  A double result that is thrown away still gets a frame temporary whose address is the
    hidden first argument (_log: frexp(x / SQRT2, &nptr) -> lda XWA,XSP+0x4c / push XWA / cal _frexp)."""
    cg = C()
    if F.pending and cg.POP_MERGE_MAX and F.pending + cg.call_arg_bytes(F, e) > cg.POP_MERGE_MAX:
        cg.flush_pops(F)                                   # fpp8 mk03: fd(e1); fd(e2); lda XSP,XSP+0x18; fd(e3) ...
    if is_fp(e.ty) and e.ty.size == 8:
        call_into(F, e, ('discard',)); return
    fn = strip(e.fn); n = 0
    if F.adecl and fn.k == 'var' and not getattr(fn.decl.ty, 'cdecl', False):
        cg.gen_call(F, e); return                          # probes/adfp.c ac_*: the adecl sequence (gen_call_adecl)
    for a in reversed(e.args):
        if is_fp(strip(a).ty): n += push_fp_arg(F, a)
        else: n += cg.push_arg(F, a)
    F.emit('cal', '_' + fn.decl.name); F.pending += n

def call_val(F, e, hint):
    """a returned call (_sin: _trig(x, -x, 1)): its computed argument takes the reserved temporary, its result the
    temporary if that is still free, else a fresh one (-x at +0x28, the result at +0x20; the other arm's result at
    +0x18)"""
    if any(has_call(fp_value_cast(a)) for a in e.args if is_fp(strip(a).ty)):
        alloc(F, hint, 'call')                           # _cos: _trig(x, fabs(x) + PAI5, 0): the result's slot first
        call_into(F, e, ('cell', hint)); return ('slot', hint.off)   # (+0x28), then the sum (+0x20), then fabs (+0x18)
    call_into(F, e, ('lazyres', hint), arg_hint=hint)
    return ('slot', F.last_call_off)

def needs_sret_home(F):
    """two or more returns of a double keep the hidden pointer in XIZ from the start (_sin)"""
    if not (is_fp(F.f.ret) and F.f.ret.size == 8): return False
    rets = []
    C().walk(F.f.body, lambda n, d: rets.append(n) if n.k == 'return' and n.value is not None else None)
    calls = []
    C().walk(F.f.body, lambda n, d: calls.append(n) if n.k == 'call' else None)
    if SRET_HOME_RANGE:
        # research-scratch sessions/2026-11-09_cc900-homes2 (sret_table.py, 20 of the library's 21 double functions):
        # the pointer is homed when a call (real or helper) falls inside its range, from the start of the first
        # statement that returns to the last return, and nothing else holds a half of XIZ (caller: F.xiz_vars).
        body = C().flat(F.f.body)
        def has_ret(st):
            r = []; C().walk(st, lambda n, d: r.append(n) if n.k == 'return' and n.value is not None else None); return r
        first = next((i for i, st in enumerate(body) if has_ret(st)), None)
        if first is None or not rets: return False
        # the range runs from the first return statement itself to the last one: a return's own top-level operation
        # does not count (_fabs: return -x), the helpers of a returned call's other arguments do (_sin: _trig(x, -x, 1))
        order = []
        def lin(n, d):
            if n.k == 'return' and n.value is not None: order.append(('ret', n))
            elif n.k == 'call' or is_fp_op(n) or (n.k == 'bin' and n.op in '*/%' and n.ty is not None and n.ty.size == 4):
                order.append(('call', n))
        for st in body[first:]: C().walk(st, lin)
        ri = [i for i, (k, n) in enumerate(order) if k == 'ret']
        if not ri: return False
        own = set()                                        # each return's own value node (and a returned call)
        for k, n in order:
            if k == 'ret':
                v = fp_value_cast(n.value); own.add(id(v))
        inrange = [n for i, (k, n) in enumerate(order) if k == 'call' and ri[0] < i <= ri[-1] + 0 and id(n) not in own]
        # (walk order puts a return before its value's nodes, so a returned call's argument helpers lie in range)
        if not inrange: return False
        # where the load goes (SRET_HOME_LATE): at entry (sin, tan, atan2), or after the first if's test when a real
        # call or an initialised double local precedes the first return (acos: fabs(x) > 1.0; cosh: ret = 1.0)
        # late when a real call precedes the first return (tanh: xx = fabs(x); acos: fabs(x) > 1.0 in the test) or
        # the first return hands back a double local initialised before (cosh, sinh: ret = K; ... return ret);
        # otherwise at entry (sin, tan; atan2: ret = 0.0 precedes but the first return is the parameter y)
        pre = []
        for st in body[:first]: C().walk(st, lambda n, d: pre.append(n) if n.k == 'call' else None)
        head = body[first]
        if head.k == 'if': C().walk(head.cond, lambda n, d: pre.append(n) if n.k == 'call' else None)
        inits = set()
        for st in body[:first]:
            C().walk(st, lambda n, d: inits.add(n.var) if n.k == 'decl' and n.init is not None and is_fp(n.var.ty) else None)
        r0 = fp_value_cast(has_ret(head)[0].value)
        ret_init = r0.k == 'load' and strip(r0.e).k == 'var' and strip(r0.e).decl in inits
        F.sret_home_late = SRET_HOME_LATE and head.k == 'if' and (bool(pre) or ret_init)
        return True
    if len(rets) >= 2 and SRET_HOME_EARLY:
        # _floor, _ceil: the two returns are the arms of the function's last if / else, so they share one exit and one
        # load of the pointer (hoisted above the test): no home.  A return before later code (_sin, _tan) needs it twice.
        body = C().flat(F.f.body); last = body[-1] if body else None
        inlast = []
        if last is not None and last.k == 'if':
            C().walk(last, lambda n, d: inlast.append(n) if n.k == 'return' and n.value is not None else None)
        if len(inlast) == len(rets) and all(root_mode(F, r.value) == 'direct' for r in rets): return False
        # (_sin: both arms return a call's result, _trig(...), and the pointer is homed)
    return len(rets) >= 2 and (bool(calls) or any(root_mode(F, r.value) != 'direct' for r in rets))
    # (_fabs: both direct and only helper calls, no home; _tan: both direct, but sin / cos before the second)

def elem_member(v):
    """(global name, offset) of g[k].m with a constant k"""
    v = strip(v)
    if v.k != 'member' or v.arrow: return None
    b = strip(v.base)
    if b.k != 'index': return None
    a = strip(b.base); i = C().fold(b.idx)
    if a.k != 'var' or a.decl.kind != 'global' or a.decl.ty.kind != 'array' or i.k != 'const': return None
    return (a.decl.name, i.value * b.ty.size + C().member_offset(v))

def const_elem(v):
    """(global name, offset) of g[k].m or g[k] with a constant k, else None"""
    r = elem_member(v)
    if r: return r
    v = strip(v)
    if v.k != 'index': return None
    a = strip(v.base); i = C().fold(v.idx)
    if a.k != 'var' or a.decl.kind != 'global' or a.decl.ty.kind != 'array' or i.k != 'const': return None
    return (a.decl.name, i.value * v.ty.size)

def elem_hoists(e):
    """the constant-index global elements that are an operand of a double + - * / whose other operand is an integer
    converted to double: V4.23 loads such an element's address into XIZ before the statement and keeps it across the
    conversion's helper call (run 2026-11-09-15-micro-fporder: fo_log, fo_mem_n, fo_arr_n ...; _log's LN2 * nptr,
    LN2 = g_dbltbl[3].val: lda XIZ,_g_dbltbl + 0x18 / ... / ld XDE,XIZ / cal ._fmul_d).  Not when the other operand
    is a call (fo_mem_call) or another element (fo_mem_mem)."""
    out = []
    def visit(n, d):
        if n.k == 'bin' and n.op in ('+', '-', '*', '/') and is_fp(getattr(n, 'ty', None)):
            for a, b in ((n.l, n.r), (n.r, n.l)):
                a, b = fp_value_cast(a), fp_value_cast(b)
                if a.k == 'load' and const_elem(a.e) and b.k == 'cast' and b.kind == 'IntegralToFloating':
                    out.append(a)
    if hasattr(e, 'k'): visit(e, 0); C().walk(e, visit)
    return out

FP_PEND_KEEP = True                                       # see the address order: an earlier statement's pops wait
FP_SWITCH_HALF = True                                      # see temp()
XDE_ELEM_FIRST = True                                     # see the address order above
OPA_XIZ = True                                            # see opa_target

def opa_target(F, lv):
    """the target of a double compound assignment whose address cc900 V4.23 keeps in XIZ (corpus/probes/fpopa.c, run
    2026-11-12-10-micro-fpopa): ('S', '_gs + 0x4') a static member or constant element, ('X', '_gda', mem) a global
    array's element at a signed int variable in memory; None for a plain variable (addressed directly) and for what
    is not modelled.  cdecl."""
    cg = C()
    if not OPA_XIZ or not is_fp(getattr(lv, 'ty', None)) or lv.ty.size != 8: return None
    lv = strip(lv)
    if lv.k not in ('member', 'index'): return None
    sip = getattr(F, 'sp_index_param', None)
    try: k = cg.sp_lvalue_kind(F, lv)                      # (-Xr: the index parameter in WA, dying here: sla 0x3,WA)
    finally: F.sp_index_param = sip
    if k is None: return None
    if k[0] == 'S': return ('S', k[2])
    if k[0] == 'X' and ' + ' not in k[1] and k[2][1] and (k[2][0].startswith('(XSP') or (F.adecl and k[2][0] == 'WA')):
        return ('X', k[1], k[2][0])
    return None

def has_opa_hoist(F):
    found = []
    C().walk(F.f.body, lambda n, d: found.append(n) if n.k == 'opassign' and is_fp(getattr(strip(n.l), 'ty', None))
             and opa_target(F, strip(n.l)) is not None else None)
    return bool(found)

def has_elem_hoist(F):
    found = []
    C().walk(F.f.body, lambda n, d: found.extend(elem_hoists(n)) if n.k in ('expr', 'return', 'decl') else None)
    return bool(found)

def hoist_elems(F, s):
    """at the start of statement s: lda XIZ,<element> for its first hoisted element (elem_hoists)"""
    if getattr(F, 'sret_home', False): return          # _atan2: XIZ holds the result pointer; PAI5 is addressed
                                                       # directly (lda XBC,_g_dbltbl + 0x10)
    e = getattr(s, 'e', None) if s.k == 'expr' else getattr(s, 'value', None) if s.k == 'return' else \
        getattr(s, 'init', None) if s.k == 'decl' else None
    if e is None or not hasattr(e, 'k'): return
    hs = elem_hoists(e)
    if not hs: return
    name, off = const_elem(hs[0].e)
    text = '_%s + %s' % (name, C().hx(off)) if off else '_%s' % name
    cg = C()                                           # (r3_08_05: i in IZ and t in QIZ are live here; the lda
    for d in list(F.f.params) + list(F.f.decls):        #  overwrote them: refused, a slot home is unmodelled)
        if getattr(d, 'reg', None) in ('IZ', 'QIZ', 'XIZ', 'QIZH') and d not in F.dead and \
                (cg.uses_decl(s, d) or cg.uses_after_stmt(F, d) or F.loops):
            raise cg.Unsupported('a floating-point element hoist over the XIZ home of %s' % d.name)
    F.emit('lda', 'XIZ,%s' % text)
    for h in hs:
        if const_elem(h.e) == (name, off): h._xiz = True

def in_xiz(x):
    return not isinstance(x, tuple) and getattr(fp_value_cast(x), '_xiz', False)

def holds_xiz(e):
    found = []
    if hasattr(e, 'k'):
        if in_xiz(e): return True
        C().walk(e, lambda n, d: found.append(n) if getattr(n, '_xiz', False) else None)
    return bool(found)

def rank(F, x):
    """the order of commutative operands: an element or member of a global first, then a temporary, then the rest"""
    if isinstance(x, tuple): return 1
    e = fp_value_cast(x)
    if getattr(e, '_xiz_opa', False): return 3              # (a compound assignment's target stays on the left)
    if getattr(e, '_xiz', False): return -1                 # fo_mem_n: XBC = the conversion, XDE = XIZ
    if e.k == 'fconst' and RANK_CONST: return -0.5          # fo_log, _log: 2 * s -> XBC = s, XDE = the constant
    if e.k == 'load' and (elem_member(e.e) or strip(e.e).k == 'member'): return 2   # (not d_loop's gda[i])
    return 0


FPE3 = True                                                 # the E3 slot rules of fpe3.py, installed over this module
if FPE3:
    import fpe3
    fpe3.install()
