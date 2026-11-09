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

def const_block(F):
    if not getattr(F, 'fconsts', None): return []
    out = ['f_const section romdata large align=2,2']
    for lab, v, size in F.fconsts:
        out += ['\talign\t2', lab + ':', '\t%s\t%s' % ('fdatad' if size == 8 else 'fdataf', fdata(v))]
    return out + ['f_code section code large align=1,1']

def strip(e): return C().strip(e)

def temp(F, size):
    """a frame temporary, allocated from the top of the frame region down (fp.c: d_from_i at (XSP+0x4) of 8)"""
    F.ftemp_used = getattr(F, 'ftemp_used', 0) + size
    F.ftemp_max = max(getattr(F, 'ftemp_max', 0), F.ftemp_used)
    return getattr(F, 'ftemp_top', 0) - F.ftemp_used

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
    return e

def lvalue_addr(F, v, reg):
    """the address of an FP object v (a var / deref / member / index node) into reg, or False"""
    cg = C(); v = strip(v)
    if v.k == 'var':
        d = v.decl
        if d.kind == 'global': F.emit('lda', '%s,_%s' % (reg, d.name)); return True
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
        return False
    if v.k == 'index':
        b = strip(v.base)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            i = cg.fold(v.idx)
            if i.k == 'const':
                F.emit('lda', '%s,_%s + %s' % (reg, b.decl.name, cg.hx(i.value * v.ty.size))); return True
            im = cg.mem_operand(F, cg.narrow(v.idx, 2))
            if im is None: return False
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
    if dest[0] == 'lv':
        v = strip(dest[1])
        named = v.k == 'var' or (v.k == 'member' and not v.arrow) or (v.k == 'index' and C().fold(v.idx).k == 'const')
        if not named:
            if not lvalue_addr(F, v, 'XWA'): raise C().Unsupported('fp destination')
            return True
    return False

def dest_last(F, dest):
    if dest[0] == 'sret': return
    if dest[0] == 'slot': F.emit('lda', 'XWA,%s' % slot_addr(F, dest[1])); return
    if dest[0] == 'lv':
        if not lvalue_addr(F, dest[1], 'XWA'): raise C().Unsupported('fp destination')
        return
    raise C().Unsupported('fp destination')

def prepare(F, ops):
    """operands that are not in memory are computed into temporaries first, the right one first (d_four)"""
    out = [None] * len(ops)
    for i in reversed(range(len(ops))):
        e = fp_value_cast(ops[i])
        if not addressable(F, e):
            off = temp(F, e.ty.size); eval_into(F, e, ('slot', off)); out[i] = ('slot', off)
        else: out[i] = e
    return out

def addr_kind(F, x):
    """'lda' when the address is a name, a stack offset or a constant; 'ld' when it has to be loaded, copied from a
    register or computed"""
    if isinstance(x, tuple): return 'lda'
    e = fp_value_cast(x)
    if e.k == 'fconst': return 'lda'
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var' or (v.k == 'member' and not v.arrow): return 'lda'
        if v.k == 'index' and C().fold(v.idx).k == 'const': return 'lda'
    return 'ld'

def dest_kind(F, dest):
    if dest[0] == 'sret': return 'ld'
    if dest[0] == 'slot': return 'lda'
    from frontend import N
    return addr_kind(F, N('load', e=dest[1], ty=dest[1].ty))

def emit_operands(F, dest, ops):
    """the result address and the operand addresses: those that are loaded, copied or computed first, in XWA, XBC,
    XDE order (d_add_gg: ld XWA,(XSP+0x4); _modf: ld XDE,XIZ / lda XBC,XSP+0x24 / lda XWA,XSP+0x14), then the
    named and stack ones in XBC, XDE, XWA order (d_add_st: lda XBC,_gd2 / lda XDE,_gd3 / lda XWA,_gd)"""
    items = [('XWA', None)] + list(zip(('XBC', 'XDE'), ops))
    kinds = {'XWA': dest_kind(F, dest)}
    for r, x in items[1:]: kinds[r] = addr_kind(F, x)
    def do(r, x):
        if r == 'XWA':
            if not dest_first(F, dest): dest_last(F, dest)
        else: put_addr(F, x, r)
    for r, x in items:
        if kinds[r] == 'ld': do(r, x)
    for r, x in items[1:] + items[:1]:
        if kinds[r] == 'lda': do(r, x)

def put_addr(F, x, reg):
    if isinstance(x, tuple): F.emit('lda', '%s,%s' % (reg, slot_addr(F, x[1])))
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
        if t.size == 2: F.emit('exts' if t.signed else 'extz', cg.FAM[fam][4])
        R4 = cg.FAM[fam][4]
    off = temp(F, 4)
    F.emit('ld', '%s,%s' % (slot_mem(F, off), R4))
    return off

def eval_into(F, e, dest):
    """compute FP expression e and store it at dest: ('sret',), ('slot', off), ('lv', lvalue node)"""
    cg = C(); e = fp_value_cast(e)
    if e.k == 'bin' and e.op in '+-*/' and len(e.op) == 1:
        a = prepare(F, [e.l, e.r])
        name = '._f%s_%s' % ({'+': 'add', '-': 'sub', '*': 'mul', '/': 'div'}[e.op], sfx(e.ty))
        if F.opt and dest[0] != 'sret':
            sa, sb, sd = simple_addr(F, a[0]), simple_addr(F, a[1]), dest_simple(F, dest)
            if sa is not None and sa == sd and sb is not None:   # d_add_asg: lda XWA,_gd / ld XBC,XWA / lda XDE,_gd2
                F.emit('lda', 'XWA,%s' % sd); F.emit('ld', 'XBC,XWA'); put_addr(F, a[1], 'XDE'); F.emit('cal', name); return
            if sa is not None and sa == sb and sd is not None:   # d_loc: lda XDE,XSP+0x10 / ld XBC,XDE / lda XWA,XSP
                put_addr(F, a[1], 'XDE'); F.emit('ld', 'XBC,XDE'); F.emit('lda', 'XWA,%s' % sd); F.emit('cal', name); return
        if F.opt and dest[0] == 'sret':
            sa, sb = simple_addr(F, a[0]), simple_addr(F, a[1])
            if sa is not None and sa == sb:
                dest_first(F, dest); put_addr(F, a[1], 'XDE'); F.emit('ld', 'XBC,XDE'); F.emit('cal', name); return
        emit_operands(F, dest, a)
        F.emit('cal', name)
        return
    if e.k == 'un' and e.op == '-':
        a = prepare(F, [e.e])
        emit_operands(F, dest, a)
        F.emit('cal', '._fneg_%s' % sfx(e.ty)); return
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
        a = prepare(F, [e.e])
        emit_operands(F, dest, a)
        F.emit('cal', '._fld_%s%s' % (sfx(e.ty), sfx(strip(e.e).ty))); return
    if e.k == 'call':
        call_into(F, e, dest); return
    if e.k not in ('load', 'fconst'): raise C().Unsupported('fp ' + e.k + ' ' + str(getattr(e, 'op', getattr(e, 'kind', ''))))
    # a copy (load, constant)
    emit_operands(F, dest, [e])
    F.emit('cal', '._fld_%s%s' % (sfx(e.ty), sfx(e.ty)))

def push_fp_arg(F, a):
    """a double argument: high half first, through XIY / XIX (d_call1: lda XIY,XSP+0x18 / ld XIX,(XIY+0x4) /
    push XIX / ld XIX,(XIY) / push XIX)"""
    a = fp_value_cast(a)
    if not addressable(F, a):
        off = temp(F, a.ty.size); eval_into(F, a, ('slot', off)); F.emit('lda', 'XIY,%s' % slot_addr(F, off))
    else: addr_of(F, a, 'XIY')
    if a.ty.size == 8:
        F.emit('ld', 'XIX,(XIY+0x4)'); F.emit('push', 'XIX'); F.push += 4
    F.emit('ld', 'XIX,(XIY)'); F.emit('push', 'XIX'); F.push += 4
    return a.ty.size

def call_into(F, e, dest):
    """a call returning double: the caller's temporary's address is the hidden first argument"""
    cg = C()
    fn = strip(e.fn)
    off = temp(F, 8) if dest[0] != 'slot' else dest[1]
    n = 0
    for a in reversed(e.args):
        if is_fp(strip(a).ty): n += push_fp_arg(F, a)
        else: n += cg.push_arg(F, a)
    F.emit('lda', 'XWA,%s' % slot_addr(F, off)); F.emit('push', 'XWA'); F.push += 4; n += 4
    F.emit('cal', '_' + fn.decl.name)
    F.emit('lda' if n > 8 else 'inc', 'XSP,XSP+%s' % cg.hx(n) if n > 8 else '%s,XSP' % cg.hx(n)); F.push -= n
    if dest[0] != 'slot' or dest[1] != off:
        first = dest_first(F, dest); F.emit('lda', 'XBC,%s' % slot_addr(F, off))
        if not first: dest_last(F, dest)
        F.emit('cal', '._fld_dd')

def gen_return(F, v):
    """return of a double (hidden pointer) or a float (XHL, through a frame temporary)"""
    if F.f.ret.size == 8:
        eval_into(F, v, ('sret',)); return
    off = F.fret_slot if getattr(F, 'fret_slot', None) is not None else temp(F, 4)
    eval_into(F, v, ('slot', off))
    F.emit('ld', 'XHL,%s' % slot_mem(F, off))

def gen_assign(F, e):
    """an FP assignment or compound assignment statement"""
    cg = C()
    if e.k == 'opassign':
        from frontend import N
        lv = strip(e.l)
        b = N('bin', op=e.op, l=N('load', e=lv, ty=lv.ty), r=e.r, ty=lv.ty)
        eval_into(F, b, ('lv', lv)); return
    eval_into(F, e.r, ('lv', strip(e.l)))

def compare(F, c, value):
    """`._fcmp_d` / `._fcmp_zd`: HL = 1 when the relation holds; value: the relation, else the negated one"""
    cg = C()
    op = c.op if value else NEG[c.op]
    l, r = fp_value_cast(c.l), fp_value_cast(c.r)
    if r.k == 'fconst' and r.value == 0.0 or (strip(r).k == 'cast' and strip(strip(r).e).k == 'const' and strip(strip(r).e).value == 0):
        a = prepare(F, [l]); put_addr(F, a[0], 'XWA')
        F.emit('ld', 'BC,%s' % cg.hx(REL[op])); F.emit('cal', '._fcmp_z%s' % sfx(l.ty)); return
    a = prepare(F, [l, r])
    put_addr(F, a[0], 'XWA'); put_addr(F, a[1], 'XBC')
    F.emit('ld', 'DE,%s' % cg.hx(REL[op])); F.emit('cal', '._fcmp_%s' % sfx(l.ty))

def truth(F, c, value):
    """if (d), !d"""
    from frontend import N
    z = N('fconst', value=0.0, ty=c.ty)
    compare(F, N('bin', op='!=', l=c, r=z, ty=c.ty), value)

def to_int(F, e, size):
    """FloatingToIntegral: through a 4-byte temporary (d_to_i), result in XHL; returns the temp's offset"""
    src = strip(e.e)
    signed = e.ty.signed
    a = prepare(F, [src])
    put_addr(F, a[0], 'XBC')
    off = temp(F, 4)
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
