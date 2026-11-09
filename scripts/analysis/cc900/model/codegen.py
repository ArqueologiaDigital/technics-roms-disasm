"""cc900 reference model, code generator (thc2's instruction selection, as the oracle shows it).

compile_unit(unit, opt='none', adecl=False) -> {function name: [lines]} in the normalised form of listing.py.
Version 0 covers what the micro-tests' binary operators need at no optimisation, cdecl: returning or storing an
expression built from parameters, globals and constants.  Each rule cites the oracle listing it comes from
(oracle run 2026-11-08-7-micro, v423/none).  Unsupported constructs raise Unsupported, and score.py counts them.

Observed rules (v423, none):
- a value is computed in the register where it is needed: the result register (L / HL / XHL) when returned, the
  accumulator (A / WA / XWA) when it is stored to a global (binop_i: add_i_pp, add_i_gg);
- `+` / `-` by a constant 1..8 is `inc` / `dec n` (add_i_pk);
- `*` and `/` work in the accumulator: int `muls XWA,src` (16x16->32), char `muls WA,src`; `/` sign-extends first
  (`exts XWA`, `exts WA`) and takes the quotient from WA / A, the remainder from QWA / W (mul_i_*, div_*, mod_*);
- char arithmetic stays 8-bit when the result is char (binop_c);
- a variable shift count is loaded into A / WA / XWA, `and A,0xf`, skip when zero, `sla A,r`; long first tests bit 4
  (`bit 0x4,A` / `sla 0x0,r` = 16); the shifted value moves to BC when the accumulator holds the count
  (shl_i_gg); a skip that lands on `ret` becomes `ret z` (shl_i_pp);
- long `*` `/` `%` call C9H_mulls / C9H_divls / C9H_remls (C9H_*lu unsigned) with XWA, XBC -> XHL (mul_l_pp).
"""

class Unsupported(Exception): pass

FAM = {'WA': {1: 'A', 2: 'WA', 4: 'XWA'}, 'BC': {1: 'C', 2: 'BC', 4: 'XBC'},
       'DE': {1: 'E', 2: 'DE', 4: 'XDE'}, 'HL': {1: 'L', 2: 'HL', 4: 'XHL'},
       'IX': {2: 'IX', 4: 'XIX'}, 'IY': {2: 'IY', 4: 'XIY'}, 'IZ': {2: 'IZ', 4: 'XIZ'},
       'QWA': {2: 'QWA'}, 'QIZ': {2: 'QIZ'}, 'XIZ': {4: 'XIZ'}}
LEAF_SEQ = ['BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'QWA']        # regalloc_notes.md
HI = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}            # high byte (char remainder)
Q = {'WA': 'QWA', 'BC': 'QBC', 'DE': 'QDE', 'HL': 'QHL'}       # upper word (int remainder)
CC_S = {'==': 'eq', '!=': 'ne', '<': 'lt', '<=': 'le', '>': 'gt', '>=': 'ge'}
CC_U = {'==': 'eq', '!=': 'ne', '<': 'ult', '<=': 'ule', '>': 'ugt', '>=': 'uge'}
INV = {'eq': 'ne', 'ne': 'eq', 'lt': 'ge', 'ge': 'lt', 'le': 'gt', 'gt': 'le',
       'ult': 'uge', 'uge': 'ult', 'ule': 'ugt', 'ugt': 'ule', 'z': 'nz', 'nz': 'z'}
SIMPLE_OPS = {'+': 'add', '-': 'sub', '&': 'and', '|': 'or', '^': 'xor'}

def hx(v):
    return '0x%x' % (v & 0xffffffff) if v >= 0 else '0x%x' % (v & 0xffffffff)

class Fn:
    def __init__(s, f, adecl):
        s.f = f; s.lines = []; s.adecl = adecl; s.label = 50000; s.push = 0; s.xiz_vars = []; s.pending = 0
        off = 4
        s.sret = None
        if f.ret is not None and f.ret.kind == 'struct' and f.ret.size > 4 and not adecl:
            from frontend import Decl, Type                  # abi.md: the hidden first argument (_ldiv)
            s.sret = Decl('__sret', Type('ptr', 4, 2, base=f.ret, spell='sret'), '', 'param'); s.sret.off = 4; off = 8
        s.retd = 0
        if adecl:                                   # abi.md: XWA / XBC / XDE, then the stack left to right
            regs = ['WA', 'BC', 'DE']
            stack = []
            for i, p in enumerate(f.params):
                if i < 3: p.reg = regs[i]
                else: stack.append(p)
            for p in reversed(stack):
                p.off = off; off += 2 if p.ty.size <= 2 else (p.ty.size + 1) // 2 * 2
            s.retd = off - 4
        else:
            for p in f.params:
                p.off = off; off += 2 if p.ty.size <= 2 else (p.ty.size + 1) // 2 * 2
        if s.sret is not None: f.params = [s.sret] + [p for p in f.params if p is not s.sret]
    def emit(s, op, args=None): s.lines.append('\t' + op + ('\t' + args if args else ''))
    def newlabel(s):
        s.label += 1; return 'L%d' % s.label
    def newulabel(s):
        s.ulabel = getattr(s, 'ulabel', 0) + 1; return 'L%d' % s.ulabel

# ------------------------------------------------------------- expression helpers

def strip(e):
    while e.k in ('noop', 'decay'): e = e.e
    return e

def narrow(e, size):
    """the value of e, known to be needed only in its low `size` bytes: drop integral casts that widen"""
    e = strip(e)
    while e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size >= size:
        e = strip(e.e)
    if e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size < size:
        return e
    return e

def fold(e):
    """constant folding of integral casts of constants"""
    e = strip(e)
    if e.k == 'cast' and e.kind in ('NullToPointer', 'IntegralToPointer') and fold(e.e).k == 'const':
        from frontend import N
        return N('const', value=fold(e.e).value, ty=e.ty)
    if e.k == 'cast' and e.kind == 'IntegralCast':
        i = fold(e.e)
        if i.k == 'const' and i.value is not None:
            v = i.value & ((1 << (8 * e.ty.size)) - 1)
            if e.ty.signed and v >= 1 << (8 * e.ty.size - 1): v -= 1 << (8 * e.ty.size)
            from frontend import N
            return N('const', value=v, ty=e.ty)
    return e

def mem_operand(F, e):
    """a memory or immediate operand string for e, or None"""
    e = fold(e)
    if e.k == 'const' and e.value is not None: return hx(e.value)
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var':
            d = v.decl
            if getattr(d, 'reg', None) and d.reg != 'XIZ':
                return FAM[d.reg].get(d.ty.size) or FAM[d.reg][2]
            if d.kind == 'local' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + F.push)
            if d.kind == 'param': return '(XSP+%s)' % hx(d.off + F.push)
            if d.kind in ('global', 'func') and not d.ty.kind == 'array': return '(_%s)' % d.name
        g = global_offset(v)
        if g: return '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0]
        if v.k == 'deref':                              # _strcat at -O: (XDE), (XBC+:1)
            pv = strip(v.e)
            if pv.k == 'load' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
                return '(%s)' % FAM[regvar_of(pv.e).reg][4]
            if pv.k == 'incdec' and pv.post and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
                d = regvar_of(pv.e); step = d.ty.base.size
                return '(%s%s:%d)' % (FAM[d.reg][4], '+' if pv.op == '++' else '-', step)
    return None

def global_offset(v):
    """(name, offset) when v is a global object at a constant offset: ga[3], gs.i (mem.c: m_ga_k, m_gs_i)"""
    v = strip(v)
    if v.k == 'index':
        b = strip(v.base); i = fold(v.idx)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and i.k == 'const':
            return (b.decl.name, hx(i.value * v.ty.size))
    if v.k == 'member' and not v.arrow:
        b = strip(v.base)
        if b.k == 'var' and b.decl.kind == 'global':
            off = [o for n, t, o in b.decl.ty.rec if n == v.name][0]
            return (b.decl.name, hx(off))
    return None

def member_offset(v):
    base_ty = strip(v.base).ty
    rec = base_ty.base.rec if v.arrow else base_ty.rec
    return [o for n, t, o in rec if n == v.name][0]

def reg_or_mem(F, e, size):
    e = strip(e)
    if e.k == 'load' and strip(e.e).k == 'var' and getattr(strip(e.e).decl, 'reg', None):
        r = strip(e.e).decl.reg
        return {'XIZ': 'XIZ'}.get(r, FAM.get(r, {}).get(size))
    return mem_operand(F, e)

def is_signed(e):
    return strip(e).ty.signed

# ------------------------------------------------------------- code generation

def gen(F, e, fam, size, then_ret=False, store=False):
    """emit code leaving e's low `size` bytes in register family `fam`; returns the family actually used"""
    e0 = strip(e)
    if e0.k == 'cast' and e0.kind == 'IntegralCast' and strip(e0.e).ty.size > size and mem_operand(F, e0.e):
        # a narrowing cast of a load reads at the source width (unop_*: cast_l_c, cast_i_c)
        isz = strip(e0.e).ty.size
        F.emit('ld', '%s,%s' % (FAM[fam][isz], mem_operand(F, e0.e))); return fam
    e = narrow(e, size)
    src = mem_operand(F, e)
    if src is not None:
        if src != FAM[fam][size]: F.emit('ld', '%s,%s' % (FAM[fam][size], src))
        return fam
    if e.k == 'cast' and e.kind == 'IntegralCast':
        inner = strip(e.e); isz = inner.ty.size
        if isz == 1 and size == 4 and not inner.ty.signed and mem_operand(F, inner):
            # unsigned char to long: clear, then load the byte (cast_uc_l)
            F.emit('ld', '%s,0x0' % FAM[fam][4]); F.emit('ld', '%s,%s' % (FAM[fam][1], mem_operand(F, inner)))
            return fam
        gen(F, inner, fam, isz)
        sz = isz
        while sz < size:                       # one step at a time: exts HL, then exts XHL (cast_c_l)
            sz *= 2
            F.emit('exts' if inner.ty.signed else 'extz', FAM[fam][sz])
        return fam
    if e.k == 'un' and e.op in ('-', '~'):
        ur = regvar_of(strip(e.e).e) if strip(e.e).k == 'load' else None
        if ur is not None and F.opt and dies_here(F, e.e) and ur.reg != fam and ur.reg in ('WA', 'BC', 'DE') and size <= 2:
            F.emit('neg' if e.op == '-' else 'cpl', FAM[ur.reg][size])     # .neg_i under O3XSXr
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[ur.reg][size])); return fam
        gen(F, e.e, fam, size)
        R = FAM[fam][size]
        if size == 4:                          # neg_l: cpl HL / cpl QHL / inc 1,XHL
            F.emit('cpl', FAM[fam][2]); F.emit('cpl', Q[fam])
            if e.op == '-': F.emit('inc', '0x1,%s' % R)
        else:
            F.emit('neg' if e.op == '-' else 'cpl', R)
        return fam
    if e.k == 'bin' and e.op in CC_S:
        cc = gen_compare(F, e)
        if cc in (True, False): F.emit('ld', '%s,%s' % (FAM[fam][2], hx(int(cc))))
        else: F.emit('scc', '%s,%s' % (cc, FAM[fam][2]))
        return fam
    if e.k == 'call': return gen_call(F, e, fam, size)
    if e.k == 'bin' and e.op in ('&&', '||'):        # c_and / c_or: ld HL,0 / conditions / ld HL,1
        R = FAM[fam][2]
        F.emit('ld', '%s,0x0' % R)
        lend = F.newulabel()
        gen_cond_false(F, e, 'RET' if then_ret else lend)
        F.emit('ld', '%s,0x1' % R); F.lines.append(lend + ':'); return fam
    if e.k == 'cond':                                # c_tern
        lelse, lend = F.newulabel(), F.newulabel()
        gen_cond_false(F, e.c, lelse)
        gen(F, e.a, fam, size); F.emit('j', lend); F.lines.append(lelse + ':')
        gen(F, e.b, fam, size); F.lines.append(lend + ':'); return fam
    if e.k == 'un' and e.op == '!':
        x = strip(e.e); xs = x.ty.size; m = mem_operand(F, x)
        if m in ('A', 'WA', 'BC', 'DE', 'HL', 'C', 'E', 'L'):                 # .lnot_i: cp WA,0x0
            F.emit('cp', '%s,0x0' % m)
        elif xs == 4 or m is None:               # lnot_l: ld XWA,x / or XWA,XWA
            gen(F, x, 'WA', xs); W = FAM['WA'][xs]; F.emit('or', '%s,%s' % (W, W))
        else:
            F.emit('cp%s' % ('b' if xs == 1 else 'w'), '%s,0x0' % m)
        F.emit('scc', 'eq,%s' % FAM[fam][2]); return fam
    if e.k == 'incdec':
        return gen_incdec(F, e, fam, size, value=True)
    if e.k == 'load' and strip(e.e).k in ('index', 'member', 'deref') and not strip(e.e).k == 'deref' or \
       (e.k == 'load' and strip(e.e).k == 'deref' and strip(strip(e.e).e).k != 'incdec'):
        return gen_load_mem(F, strip(e.e), fam, size)
    if e.k == 'load' and strip(e.e).k == 'deref' and strip(strip(e.e).e).k == 'incdec' and strip(strip(e.e).e).post:
        inc = strip(strip(e.e).e); g = global_name(inc.e)
        if g is None: raise Unsupported('deref incdec')
        F.emit('ld', 'XBC,(%s)' % g); F.emit('ld', 'XWA,%s' % hx(strip(inc.e).ty.base.size))
        F.emit('add' if inc.op == '++' else 'sub', '(%s),XWA' % g)
        F.emit('ld', '%s,(XBC)' % FAM[fam][size]); return fam
    if e.k == 'load' and strip(e.e).k == 'var' and getattr(strip(e.e).decl, 'reg', None):
        r = strip(e.e).decl.reg
        if r != fam: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[r].get(size, FAM[r].get(2))))
        return fam if r != fam else r
    if e.k == 'bin':
        return gen_bin(F, e, fam, size, then_ret, store)
    raise Unsupported(e.k)

def gen_bin(F, e, fam, size, then_ret, store=False):
    op = e.op
    if op in '+-' and (strip(e.l).ty.is_ptr() or strip(e.r).ty.is_ptr()):
        return gen_ptr_arith(F, e, fam, size)
    l, r = narrow(e.l, size), narrow(e.r, size)
    signed = e.ty.signed if size >= e.ty.size else is_signed(l)
    R = FAM[fam][size]
    if op in SIMPLE_OPS:
        if fam != 'WA' and reads_reg(r, fam):        # ra_leafsum5: target read later -> compute in WA
            gen_bin(F, e, 'WA', size, then_ret, store)
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['WA'][size])); return fam
        lr = regvar_of(strip(l).e) if strip(l).k == 'load' else None
        if lr is not None and lr.reg in ('WA', 'BC', 'DE', 'HL') and F.opt and dies_here(F, l) and lr.reg != fam:
            # -O: a dying register operand is computed in place, then moved (add_i_pp under O3XSXr)
            F.dead.add(lr)
            rs = operand(F, r, size)
            if rs is None:
                other = free_reg(F, avoid={lr.reg, fam}); gen(F, r, other, size); rs = FAM[other][size]
            rc = fold(r)
            if op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
                F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc.value), FAM[lr.reg][size]))
            else:
                F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM[lr.reg][size], rs))
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[lr.reg][size])); return fam
        if lr is not None and lr.reg == fam and not dies_here(F, l):
            # the target holds a live variable: work in a free register (mul_i_loc under Xr: ld DE,WA)
            other = free_reg(F, avoid={fam})
            gen(F, l, other, size); fam_work = other
            rs = operand(F, r, size)
            if rs is None: raise Unsupported('complex right operand')
            F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM[other][size], rs))
            return other
        if fam != 'WA' and natural_wa(l):              # ra_noloop3: inner levels over a multiply stay in WA
            gen(F, l, 'WA', size)
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['WA'][size]))
        else:
            gen(F, l, fam, size)
        rs = mem_operand(F, r)
        if rs is None:
            other = 'BC' if fam != 'BC' else 'DE'
            gen(F, r, other, size); rs = FAM[other][size]
        rc = fold(r)
        if op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
            F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc.value), R))
        else:
            F.emit(SIMPLE_OPS[op], '%s,%s' % (R, rs))
        return fam
    if op == '*' and size == 4 and fold(r).k == 'const' and fold(r).value > 0:
        return gen_mul_const(F, l, fold(r).value, fam, size, signed)
    if op in ('*', '/', '%'):
        if size == 4: return gen_long_helper(F, e, l, r, fam, signed)
        rs = mem_operand(F, r)
        work = 'WA'
        if F.opt and fam in ('HL', 'BC', 'DE') and mem_operand(F, l) and rs and not regvar_of(getattr(strip(l), 'e', l)):
            work = fam                                  # -O: mul_i_pp -> ld HL,(a) / muls XHL,(b)
        lr = regvar_of(strip(l).e) if strip(l).k == 'load' else None
        if lr is not None and lr.reg == 'WA' and not dies_here(F, l):
            work = free_reg(F, avoid={'WA'})            # mul_i_loc under Xr: ld DE,WA / muls XDE,BC
        if lr is not None and lr.reg == 'WA' and dies_here(F, l): F.dead.add(lr)
        gen(F, l, work, size)
        if rs is None:                                  # ra_noloop: muls XWA,BC
            gen(F, r, 'BC', size); rs = FAM['BC'][size]
        wide = FAM[work][4] if size == 2 else FAM[work][2]
        if op == '*':
            F.emit('muls' if signed else 'mul', '%s,%s' % (wide, rs))
            res = FAM[work][size]
        else:
            F.emit('exts' if signed else 'extz', wide)
            F.emit('divs' if signed else 'div', '%s,%s' % (wide, rs))
            res = FAM[work][size] if op == '/' else (Q[work] if size == 2 else HI[work])
        if store and res == 'W': F.store_from = 'W'; return fam
        return move_to(F, res, fam, size)
    if op in ('<<', '>>'):
        mnem = ('sla' if signed else 'sll') if op == '<<' else ('sra' if signed else 'srl')
        rr = strip(r)
        if rr.k == 'const':
            gen(F, l, fam, size)
            F.emit(mnem, '%s,%s' % (hx(rr.value), R)); return fam
        vfam = 'BC' if fam == 'WA' else fam
        V = FAM[vfam][size]
        gen(F, l, vfam, size)
        cs = mem_operand(F, r)
        if cs is None: raise Unsupported('complex shift count')
        F.emit('ld', '%s,%s' % (FAM['WA'][strip(r).ty.size], cs))
        if size == 4:
            lab16 = F.newlabel()
            F.emit('bit', '0x4,A'); F.emit('j', 'z,%s' % lab16); F.emit(mnem, '0x0,%s' % V)
            F.lines.append(lab16 + ':')
        F.emit('and', 'A,0xf')
        lab = F.newlabel()
        F.emit('ret', 'z') if then_ret and vfam == fam else F.emit('j', 'z,%s' % lab)
        F.emit(mnem, 'A,%s' % V)
        F.lines.append(lab + ':')
        return vfam
    raise Unsupported('operator ' + op)

def cse_params(F, e):
    """-O: a memory parameter loaded twice in one expression is loaded once into a temporary (binop_*: *_loc
    under O3XS): WA for add/sub/and/or/xor chains, BC when the operation needs WA (*, /, %, shifts, char)"""
    counts = {}
    def v(n, d):
        if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl.kind == 'param' and not getattr(strip(n.e).decl, 'reg', None):
            counts[strip(n.e).decl] = counts.get(strip(n.e).decl, 0) + 1
    walk(e, v)
    many = [d for d, c in counts.items() if c >= 2]
    if len(many) != 1: return False
    d = many[0]; size = F.f.ret.size; top = narrow(e, size)
    needs_wa = size == 1 or (top.k == 'bin' and top.op in ('*', '/', '%', '<<', '>>'))
    if top.k == 'bin' and top.op in ('*', '/', '%') and size == 4: return False
    tmp = 'BC' if needs_wa else 'WA'
    F.emit('ld', '%s,(XSP+%s)' % (FAM[tmp][d.ty.size], hx(d.off + F.push)))
    d.reg = tmp
    try:
        fam = gen(F, e, 'HL', size, then_ret=True)
        if fam != 'HL' and FAM[fam].get(size) != FAM['HL'][size]:
            F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam][size]))
    finally:
        d.reg = None
    flush_pops(F)
    for r in reversed(F.pushes): F.emit('pop', r)
    F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret')
    return True

def free_reg(F, avoid=()):
    live = live_regs(F)
    for r in ('BC', 'DE', 'HL', 'WA'):
        if r not in live and r not in avoid: return r
    raise Unsupported('no free register')

def natural_wa(e):
    e = strip(e)
    if e.k == 'bin' and e.op in ('*', '/', '%') and e.ty.size <= 2: return True
    if e.k == 'bin' and e.op in SIMPLE_OPS: return natural_wa(e.l)
    return False

def reads_reg(e, fam):
    found = []
    def v(n, d):
        if n.k == 'var' and getattr(n.decl, 'reg', None) == fam: found.append(n)
    walk(e, v)
    return bool(found)

def gen_ptr_arith(F, e, fam, size):
    """p + i (mem.c: m_padd): index sign-extended and scaled in XWA, then the pointer added;
    p - q (m_diff): 32-bit difference divided by the element size with C9H_divls"""
    l, r = strip(e.l), strip(e.r)
    if l.ty.is_ptr() and r.ty.is_ptr():
        lm, rm = mem_operand(F, l), mem_operand(F, r)
        if lm is None or rm is None: raise Unsupported('complex pointer difference')
        F.emit('ld', 'XWA,%s' % lm); F.emit('sub', 'XWA,%s' % rm)
        esz = l.ty.base.size
        if esz > 1:
            F.emit('ld', 'XBC,%s' % hx(esz)); F.emit('cal', 'C9H_divls'); return 'HL'
        return move_to(F, 'XWA', fam, 4)
    if r.ty.is_ptr(): l, r = r, l
    pm = mem_operand(F, l); ii = r
    while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
    im = mem_operand(F, ii)
    if pm is None or im is None: raise Unsupported('complex pointer arithmetic')
    esz = l.ty.base.size
    F.emit('ld', 'WA,%s' % im); F.emit('exts' if ii.ty.signed else 'extz', 'XWA')
    if esz == 2: F.emit('add', 'XWA,XWA')
    elif esz > 2: F.emit('sll', '%s,XWA' % hx({4: 2, 8: 3}[esz]))
    R = FAM[fam][4]
    if R != 'XWA': F.emit('ld', '%s,XWA' % R)
    F.emit('add' if e.op == '+' else 'sub', '%s,%s' % (R, pm)); return fam

def gen_mul_const(F, l, k, fam, size, signed=True):
    """long multiply by a constant, by shifts and adds (mul_l_pk, mul_l_gk): binary method from the top bit;
    a run of doublings before an add is `sla n`, a final single doubling `add r,r`"""
    R = FAM[fam][size]
    x = mem_operand(F, l)
    if x is None: raise Unsupported('complex multiplicand')
    if x.startswith('(_'):                       # an absolute operand is loaded once into XBC
        F.emit('ld', '%s,%s' % (FAM['BC'][size], x)); F.emit('ld', '%s,%s' % (R, FAM['BC'][size])); x = FAM['BC'][size]
    else:
        F.emit('ld', '%s,%s' % (R, x))
    bits = bin(k)[3:]; run = 0
    for i, b in enumerate(bits):
        run += 1
        if b == '1':
            F.emit('sla' if signed else 'sll', '%s,%s' % (hx(run), R))
            F.emit('add', '%s,%s' % (R, x)); run = 0
    if run == 1: F.emit('add', '%s,%s' % (R, R))
    elif run > 1: F.emit('sla' if signed else 'sll', '%s,%s' % (hx(run), R))
    return fam

def gen_long_helper(F, e, l, r, fam, signed):
    name = {'*': 'mul', '/': 'div', '%': 'rem'}[e.op] + ('ls' if signed else 'lu')
    ls, rs = reg_or_mem(F, l, 4), reg_or_mem(F, r, 4)
    if ls is None or rs is None: raise Unsupported('complex long helper operands')
    # provisional (two examples, mul_l_loc): XBC first when a register variable is involved
    if F.xiz_vars and any(d.kind == 'local' for d in F.xiz_vars):
        F.emit('ld', 'XBC,%s' % rs); F.emit('ld', 'XWA,%s' % ls)
    else:
        F.emit('ld', 'XWA,%s' % ls); F.emit('ld', 'XBC,%s' % rs)
    F.emit('cal', 'C9H_' + name)
    return 'HL' if fam == 'HL' else move_to(F, 'XHL', fam, 4, keep=True)

def move_to(F, res, fam, size, keep=False):
    tgt = FAM[fam][size]
    if keep: return 'HL'
    if res != tgt: F.emit('ld', '%s,%s' % (tgt, res))
    return fam

def gen_compare(F, e):
    """emit the compare for relational/equality node e; return its condition code, or True/False if constant
    (cmp_*: cp acc,mem; cpw/cpb mem,k; long: ld XWA / cp XWA,k / or XWA,XWA for ==0 and !=0)"""
    l, r = strip(e.l), strip(e.r)
    while l.k == 'cast' and l.kind == 'IntegralCast' and strip(l.e).ty.size <= r.ty.size and fold(r).k == 'const':
        l = strip(l.e)
    # operands promoted from the same narrower type compare at that type
    if l.k == 'cast' and r.k == 'cast' and l.kind == r.kind == 'IntegralCast' and strip(l.e).ty.size == strip(r.e).ty.size:
        l, r = strip(l.e), strip(r.e)
    if l.k == 'cast' and l.kind == 'IntegralCast' and fold(r).k == 'const':
        l = strip(l.e)
    size = l.ty.size; signed = l.ty.signed
    cc = (CC_S if signed else CC_U)[e.op]
    rc = fold(r)
    op = e.op
    if rc.k == 'const' and rc.value == 0 and not signed:
        if op in ('<', '>='): return op == '>='
        op = {'<=': '==', '>': '!='}.get(op, op)          # cmp_ui: le_ui_br0, gt_ui_br0
        cc = CC_U[op]
    lm = mem_operand(F, l)
    rv = r
    while rv.k == 'cast' and rv.kind == 'IntegralCast': rv = strip(rv.e)
    rvm = mem_operand(F, rv)
    if rvm in ('A', 'C', 'E', 'L', 'WA', 'BC', 'DE', 'HL') and lm is not None and lm.startswith('(') and e.op in ('==', '!='):
        rr = FAM[[k for k, v in FAM.items() if rvm in v.values()][0]][size]     # _strchr: cp A,(XHL)
        F.emit('cp', '%s,%s' % (rr, lm)); return cc
    if regvar_of(getattr(l, 'e', l)) and lm in ('BC', 'DE', 'HL', 'IX', 'IY', 'IZ'):   # ra_leaf: cp IX,(XSP+4)
        rs = mem_operand(F, r)
        if rs is None: raise Unsupported('complex compare operand')
        F.emit('cp', '%s,%s' % (lm, rs)); return cc
    if rc.k == 'const' and lm is not None and lm.startswith('(') and size <= 2:
        F.emit('cp' + ('b' if size == 1 else 'w'), '%s,%s' % (lm, hx(rc.value))); return cc
    W = FAM['WA'][size]
    gen(F, l, 'WA', size)
    if rc.k == 'const' and rc.value == 0 and size == 4 and op in ('==', '!='):
        F.emit('or', '%s,%s' % (W, W)); return cc
    rs = mem_operand(F, r)
    if rs is None: raise Unsupported('complex compare operand')
    F.emit('cp', '%s,%s' % (W, rs)); return cc

def jump(F, cc, target):
    F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target))

def gen_cond_true(F, c, target):
    """jump to target when c is true (ctrl.c: c_orbr's first operand)"""
    c = strip(c)
    if c.k == 'un' and c.op == '!': return gen_cond_false(F, c.e, target)
    if c.k == 'bin' and c.op == '||':
        gen_cond_true(F, c.l, target); gen_cond_true(F, c.r, target); return
    if c.k == 'bin' and c.op in CC_S:
        cc = gen_compare(F, c)
        if cc in (True, False): raise Unsupported('constant condition')
        jump(F, cc, target); return
    from frontend import N
    if c.ty.kind in ('int', 'ptr'):
        return gen_cond_true(F, N('bin', op='!=', l=c, r=N('const', value=0, ty=c.ty), ty=c.ty), target)
    raise Unsupported('condition ' + c.k)

def gen_cond_false(F, c, target):
    """jump to `target` (a label, or 'RET' for the function exit) when condition c is false; returns the
    constant value of c when it folds"""
    c = strip(c)
    if c.k == 'un' and c.op == '!':
        gen_cond_true(F, c.e, target); return None
    if c.k == 'bin' and c.op == '&&':                # c_andbr: both operands jump to the false target
        gen_cond_false(F, c.l, target); gen_cond_false(F, c.r, target); return None
    if c.k == 'bin' and c.op == '||':                # c_orbr: first true -> then label; last false -> target
        lt = F.newulabel(); gen_cond_true(F, c.l, lt); gen_cond_false(F, c.r, target)
        F.lines.append(lt + ':'); return None
    if c.k in ('load', 'cast', 'call') and c.ty.kind in ('int', 'ptr'):   # c_if: if (a)
        from frontend import N
        return gen_cond_false(F, N('bin', op='!=', l=c, r=N('const', value=0, ty=c.ty), ty=c.ty), target)
    if c.k == 'bin' and c.op in CC_S:
        cc = gen_compare(F, c)
        if cc is True: return True
        if cc is False:
            F.emit('ret') if target == 'RET' else F.emit('j', target); return
        F.emit('ret', INV[cc]) if target == 'RET' else F.emit('j', '%s,%s' % (INV[cc], target))
        return
    raise Unsupported('condition ' + c.k)

def push_arg(F, a):
    """push one cdecl argument (call.c: k1, k1k, k3, k4; abi args_caller)"""
    a0 = strip(a); size = a0.ty.size
    if size == 1:                                    # a char parameter: sign-extended to a word (call.c: k4)
        m = mem_operand(F, a0)
        if m is None: raise Unsupported('complex char argument')
        F.emit('ld', 'A,%s' % m); F.emit('exts' if a0.ty.signed else 'extz', 'WA'); F.emit('push', 'WA')
        F.push += 2; return 2
    if a0.k == 'call':                               # a call result is pushed from HL (call.c: k_nest)
        gen_call(F, a0); F.emit('push', FAM['HL'][size] if size >= 2 else 'HL'); F.push += max(size, 2)
        return max(size, 2)
    if a0.k == 'cast' and a0.kind == 'IntegralCast' and strip(a0.e).ty.size == 1 and size == 2:
        m = mem_operand(F, a0.e)
        if m is None: raise Unsupported('complex char argument')
        F.emit('ld', 'A,%s' % m); F.emit('exts' if strip(a0.e).ty.signed else 'extz', 'WA'); F.emit('push', 'WA')
        F.push += 2; return 2
    m = mem_operand(F, a)
    if size <= 2 and m is not None:
        F.emit('pushw', m); F.push += 2; return 2
    if size == 4 and m is not None and m.startswith('('):
        F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    if size == 4 and m is not None:
        F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    fam = gen(F, a, 'WA', size)
    F.emit('push', FAM[fam][size]); F.push += size; return size

def flush_pops(F):
    n = F.pending
    if n:
        F.emit('inc', '%s,XSP' % hx(n)) if n <= 8 else F.emit('lda', 'XSP,XSP+%s' % hx(n))
        F.push -= n; F.pending = 0

def gen_call(F, e, fam=None, size=0):
    fn = strip(e.fn)
    if fn.k != 'var': raise Unsupported('indirect call')
    n = 0
    for a in reversed(e.args): n += push_arg(F, a)
    F.emit('cal', ('.' if F.adecl else '_') + fn.decl.name)
    F.pending += n
    if fam and fam != 'HL': F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['HL'][size]))
    return fam

def global_name(e):
    v = strip(e)
    if v.k == 'var' and v.decl.kind == 'global': return '_' + v.decl.name
    return None

def gen_incdec(F, e, fam, size, value):
    """++/-- on a global: incb/incw in memory, long through XWA (unop_*: preinc, postinc_val); *p++ (deref_inc)"""
    g = global_name(e.e)
    if g is None: raise Unsupported('incdec target')
    vt = strip(e.e).ty
    step = vt.base.size if vt.kind == 'ptr' else 1
    def bump():
        if vt.size == 4:
            F.emit('ld', 'XWA,%s' % hx(step)); F.emit('add' if e.op == '++' else 'sub', '(%s),XWA' % g)
        else:
            F.emit(('inc' if e.op == '++' else 'dec') + ('b' if vt.size == 1 else 'w'), '%s,(%s)' % (hx(step), g))
    if not value: bump(); return None
    if e.post: F.emit('ld', '%s,(%s)' % (FAM[fam][vt.size], g)); bump()
    else: bump(); F.emit('ld', '%s,(%s)' % (FAM[fam][vt.size], g))
    return fam

def gen_load_mem(F, v, fam, size):
    """load through an index, member or pointer (mem.c)"""
    R = FAM[fam][size]
    if v.k == 'member' and v.arrow:
        pm = mem_operand(F, v.base)
        if pm is None: raise Unsupported('complex member base')
        F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA+%s)' % (R, hx(member_offset(v)))); return fam
    if v.k == 'deref':
        pm = mem_operand(F, v.e)
        if pm is None: raise Unsupported('complex pointer')
        F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA)' % R); return fam
    if v.k == 'index':
        b = strip(v.base); i = v.idx; esz = v.ty.size
        ic = fold(i)
        if b.k == 'load' and ic.k == 'const':                      # p[k]: m_p_k
            pm = mem_operand(F, b)
            F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA+%s)' % (R, hx(ic.value * esz))); return fam
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            ii = strip(i); im = mem_operand(F, ii)
            if im is None: raise Unsupported('complex index')
            if esz == 1:                                           # m_gca_v
                F.emit('lda', 'XWA,_%s' % b.decl.name); F.emit('ld', 'BC,%s' % im); F.emit('extz', 'XBC')
                F.emit('add', 'XBC,XWA'); F.emit('ld', '%s,(XBC)' % R); return fam
            F.emit('ld', 'WA,%s' % im)                             # m_ga_v, m_gla_v
            F.emit('add', 'WA,WA') if esz == 2 else F.emit('sla', '%s,WA' % hx({4: 2, 8: 3}[esz]))
            F.emit('lda', 'XBC,_%s' % b.decl.name); F.emit('ld', '%s,(XBC+WA)' % R); return fam
        if b.k == 'load':                                          # p[i]: m_p_v, m_lp_v, m_cp_v
            pm = mem_operand(F, b); ii = strip(i)
            while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
            im = mem_operand(F, ii)
            if pm is None or im is None: raise Unsupported('complex pointer index')
            F.emit('ld', 'WA,%s' % im); F.emit('exts' if ii.ty.signed else 'extz', 'XWA')
            if esz == 2: F.emit('add', 'XWA,XWA')
            elif esz > 2: F.emit('sll', '%s,XWA' % hx({4: 2, 8: 3}[esz]))
            F.emit('add', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA)' % R); return fam
    raise Unsupported('memory load ' + v.k)

def lvalue(F, lv, ptr='XBC', idx='BC', base='XDE', combine=False):
    """set up the address of lvalue lv and return its operand string (assign.c): a global or parameter is a direct
    operand; *p loads p into `ptr`; a[i] of a global array scales i in `idx` and puts the array in `base`
    (`(base+idx)`), or with combine=True adds them into `ptr` (`(ptr)`)"""
    lv = strip(lv)
    if getattr(F, 'cl_active', None) and lv.k == 'index' and strip(lv.base).k == 'var' and \
            strip(lv.base).decl is F.cl_active['arr']:
        return F.cl_operand                                  # ol_i_clear: ldw (XBC+WA),0x0
    if lv.k == 'var':
        d = lv.decl
        if d.kind == 'global': return '(_%s)' % d.name
        if d.kind == 'param': return '(XSP+%s)' % hx(d.off + F.push)
        if d.kind == 'local' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + F.push)
    if lv.k == 'deref':
        pv = strip(lv.e)
        if pv.k == 'incdec' and pv.post and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
            d = regvar_of(pv.e)
            return '(%s%s:%d)' % (FAM[d.reg][4], '+' if pv.op == '++' else '-', d.ty.base.size)
        m = mem_operand(F, lv.e)
        if m is None: raise Unsupported('complex pointer')
        if m.startswith('X'): return '(%s)' % m        # .as_add_ptr: add (XWA),BC
        F.emit('ld', '%s,%s' % (ptr, m)); return '(%s)' % ptr
    if lv.k == 'member' and lv.arrow:                 # mem.c: m_gps_set
        m = mem_operand(F, lv.base)
        if m is None: raise Unsupported('complex member base')
        F.emit('ld', '%s,%s' % (ptr, m)); off = member_offset(lv)
        return '(%s+%s)' % (ptr, hx(off)) if off else '(%s)' % ptr
    g = global_offset(lv)
    if g: return '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0]
    if lv.k == 'index' and strip(lv.base).k == 'load' and fold(lv.idx).k == 'const':
        m = mem_operand(F, lv.base)                      # _ultoa: ld XWA,(s) / ldb (XWA),0x0
        if m is not None:
            if m.startswith('('): F.emit('ld', '%s,%s' % (ptr if ptr != 'XBC' else 'XWA', m)); m = ptr if ptr != 'XBC' else 'XWA'
            off = fold(lv.idx).value * lv.ty.size
            return '(%s+%s)' % (m, hx(off)) if off else '(%s)' % m
    if lv.k == 'index':
        b, i = strip(lv.base), lv.idx
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            esz = lv.ty.size; im = mem_operand(F, i)
            if im is None: raise Unsupported('complex index')
            I = idx if not combine else 'WA'
            if im in ('WA', 'BC', 'DE') and dies_here(F, i):   # .as_add_arr: add WA,WA / (XDE+WA)
                I = im
                idx = im
            elif im != I: F.emit('ld', '%s,%s' % (I, im))
            if esz == 2: F.emit('add', '%s,%s' % (I, I))
            elif esz == 4: F.emit('sla', '0x2,%s' % I)
            if combine:
                F.emit('lda', '%s,_%s' % (ptr, b.decl.name)); F.emit('lda', '%s,%s+%s' % (ptr, ptr, I))
                d_i = regvar_of(strip(i).e) if strip(i).k == 'load' else None
                if d_i is not None and I == FAM[d_i.reg][2]: F.dead.add(d_i)
                return '(%s)' % ptr
            F.emit('lda', '%s,_%s' % (base, b.decl.name)); return '(%s+%s)' % (base, idx)
    raise Unsupported('lvalue ' + lv.k)

def gen_opassign(F, e):
    """x op= y as a statement (assign.c)"""
    size = strip(e.l).ty.size; op = e.op
    r = narrow(e.r, size)
    signed = strip(e.l).ty.signed
    if op in SIMPLE_OPS:
        t = lvalue(F, e.l)
        rv = mem_operand(F, r)
        if rv in ('A', 'C', 'E', 'WA', 'BC', 'DE', 'HL', 'XWA', 'XBC', 'XDE'):
            F.emit(SIMPLE_OPS[op], '%s,%s' % (t, rv)); return t        # .as_add_ptr: add (XWA),BC
        gen(F, r, 'WA', size)
        F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM['WA'][size])); return t
    if op in ('<<', '>>'):
        t = lvalue(F, e.l, ptr='XDE', idx='DE', base='XHL')
        mnem = ('sla' if signed else 'sll') if op == '<<' else ('sra' if signed else 'srl')
        V = FAM['BC'][size]
        F.emit('ld', '%s,%s' % (V, t))
        rr = fold(r)
        if rr.k == 'const':
            F.emit(mnem, '%s,%s' % (hx(rr.value), V))
        else:
            cs = mem_operand(F, r)
            if cs is None: raise Unsupported('complex shift count')
            F.emit('ld', '%s,%s' % (FAM['WA'][strip(r).ty.size], cs))
            if size == 4:
                lab16 = F.newlabel(); F.emit('bit', '0x4,A'); F.emit('j', 'z,%s' % lab16)
                F.emit(mnem, '0x0,%s' % V); F.lines.append(lab16 + ':')
            F.emit('and', 'A,0xf'); lab = F.newlabel(); F.emit('j', 'z,%s' % lab); F.emit(mnem, 'A,%s' % V)
            F.lines.append(lab + ':')
        F.emit('ld', '%s,%s' % (t, V)); return t
    if op in ('*', '/', '%'):
        if size == 4:
            t = lvalue(F, e.l)
            rs = mem_operand(F, r)
            if rs is None: raise Unsupported('complex long operand')
            name = {'*': 'mul', '/': 'div', '%': 'rem'}[op] + ('ls' if signed else 'lu')
            saved = False
            if rs == 'XWA':                                # .as_mul_gl: push XIZ / ld XIZ,XWA
                F.lines.insert(1, '\tpush\tXIZ'); F.push += 4; F.emit('ld', 'XIZ,XWA'); rs = 'XIZ'; saved = True
            F.emit('ld', 'XWA,%s' % t); F.emit('ld', 'XBC,%s' % rs); F.emit('cal', 'C9H_' + name)
            F.emit('ld', '%s,XHL' % t)
            if saved: F.pushes.append('XIZ')
            return t
        lv = strip(e.l)
        if lv.k == 'deref' and mem_operand(F, lv.e) == 'XWA':        # .as_mul_ptr: ld XDE,XWA / ld WA,(XDE)
            pr = free_reg(F, avoid={'WA'}); pd = regvar_of(strip(lv.e).e)
            pr = 'DE' if pr == 'BC' and 'BC' in live_regs(F) else pr
            F.emit('ld', '%s,XWA' % FAM[pr][4]); t = '(%s)' % FAM[pr][4]; F.dead.add(pd)
        else:
            ptr = 'XBC'
            if 'BC' in live_regs(F): ptr = FAM[free_reg(F, avoid={'WA', 'BC'})][4]      # .as_mul_arr: XDE
            t = lvalue(F, e.l, ptr=ptr, combine=True)
        rs = mem_operand(F, r)
        if rs is None: raise Unsupported('complex operand')
        work = 'WA' if 'WA' not in live_regs(F) else free_reg(F, avoid={'WA'})   # .as_mul_gi: muls XBC,WA
        F.emit('ld', '%s,%s' % (FAM[work][size], t))
        wide = FAM[work][4] if size == 2 else FAM[work][2]
        if op == '*':
            F.emit('muls' if signed else 'mul', '%s,%s' % (wide, rs)); res = FAM[work][size]
        else:
            F.emit('exts' if signed else 'extz', wide); F.emit('divs' if signed else 'div', '%s,%s' % (wide, rs))
            res = FAM[work][size] if op == '/' else (Q[work] if size == 2 else HI[work])
        if res.startswith('Q'): F.emit('ld', '%s,%s' % (FAM[work][2], res)); res = FAM[work][2]
        F.emit('ld', '%s,%s' % (t, res)); return t
    raise Unsupported('opassign ' + op)

def store_global(F, name, e, size):
    rv = regvar_of(getattr(strip(e), 'e', e)) if strip(e).k == 'load' else None
    if rv is not None and rv.ty.size == size:          # ra_twice: ld (_ga),HL
        F.emit('ld', '(_%s),%s' % (name, FAM[rv.reg][size])); return
    F.store_from = None
    fam = gen(F, e, 'WA', size, store=True)
    reg = F.store_from or FAM[fam][size]
    F.emit('ld', '(_%s),%s' % (name, reg))

# ------------------------------------------------------------- statements

def uses_of(node, d, acc):
    if isinstance(node, list):
        for x in node: uses_of(x, d, acc)
        return acc
    if not hasattr(node, 'k'): return acc
    if node.k == 'load' and strip(node.e).k == 'var' and strip(node.e).decl is d: acc.append(node)
    for v in node.__dict__.values():
        if hasattr(v, 'k') or isinstance(v, list): uses_of(v, d, acc)
    return acc

def substitute(node, d, repl):
    for key, v in list(node.__dict__.items()):
        if hasattr(v, 'k'):
            if v.k == 'load' and strip(v.e).k == 'var' and strip(v.e).decl is d: setattr(node, key, repl)
            else: substitute(v, d, repl)
        elif isinstance(v, list):
            for i, x in enumerate(v):
                if hasattr(x, 'k'):
                    if x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl is d: v[i] = repl
                    else: substitute(x, d, repl)

def uses_decl(node, d):
    found = []
    def v(n, depth):
        if n.k == 'var' and n.decl is d: found.append(n)
    walk(node, v)
    return bool(found)

def setup_struct_temps(F, c):
    """_ldiv: lda XWA,XSP+slot / ld (tB),XWA / [V4.23: ld XWA,(tB)] / ld (tA),XWA, before the first member store"""
    for d, t in getattr(F, 'struct_temps', {}).items():
        if t['done']: continue
        hit = []
        walk(c, lambda n, dep: hit.append(n) if id(n) in t['stores'] else None)
        if not hit: continue
        F.emit('lda', 'XWA,XSP+%s' % hx(d.slot + F.push))
        F.emit('ld', '(XSP+%s),XWA' % hx(t['tB'].slot + F.push))
        if F.personality == 'v4.23':                      # rules.md: reload-after-store (kn5000 = 2003: no reload)
            F.emit('ld', 'XWA,(XSP+%s)' % hx(t['tB'].slot + F.push))
        F.emit('ld', '(XSP+%s),XWA' % hx(t['tA'].slot + F.push))
        t['done'] = True; t['n'] = 0

def flat(s):
    if s.k == 'block':
        out = []
        for c in s.body: out += flat(c)
        return out
    return [s]

def gen_stmt(F, s, last):
    if s.k == 'block':
        body = flat(s)
        i = 0
        while i < len(body):
            c = body[i]
            if getattr(F, 'deferred', None):
                j = i
                while j < len(body) and body[j].k not in ('for', 'while', 'do'): j += 1
                stretch = body[i:j + 1]
                def first_use(d):
                    order = []
                    walk(stretch, lambda n, dep: order.append(n.decl) if n.k == 'var' else None)
                    return order.index(d) if d in order else 1 << 30
                need = [d for d in F.deferred if any(uses_decl(x, d) for x in stretch)
                        and (d.reg != 'XIZ' or (c.k in ('expr', 'return', 'decl') and uses_decl(c, d)))]   # _ldiv: XIZ at its statement
                own = sorted([d for d in need if uses_decl(c, d)], key=first_use)
                rest = sorted([d for d in need if d not in own], key=first_use)
                for d in rest + own:                       # _strncpy: n, s2, then s1 (its own statement); _strchr: s, c
                    setup_struct_temps(F, c)
                    F.emit('ld', '%s,(XSP+%s)' % ('XIZ' if d.reg == 'XIZ' else FAM[d.reg][d.ty.size], hx(d.off + F.push)))
                    F.deferred.remove(d)
            if c.k == 'decl' and getattr(c.var, 'reg', None) not in (None, 'XIZ', 'WA') and c.var.kind == 'local':
                if c.init is not None:
                    from frontend import N
                    regvar_stmt(F, N('bin', op='=', l=N('var', decl=c.var, ty=c.var.ty), r=c.init, ty=c.var.ty))
                i += 1; continue
            if c.k == 'decl' and getattr(c.var, 'reg', None) == 'XIZ':
                fam = gen(F, c.init, 'HL', 4); F.emit('ld', 'XIZ,%s' % FAM[fam][4]); i += 1; continue
            if c.k == 'decl' and c.init is not None and c.var.kind == 'local' and not c.var.addr_taken:
                rest = body[i + 1:]
                u = uses_of(rest, c.var, [])
                if len(u) == 1 and c.var.ty.size >= 2:
                    for x in rest: substitute(x, c.var, c.init)
                    i += 1; continue
                if len(u) >= 1 and c.var.ty.size == 1:
                    c.var.reg = gen(F, c.init, 'WA', 1); i += 1; continue
                raise Unsupported('local ' + c.var.name)
            if c.k == 'decl' and c.init is None: i += 1; continue
            nxt = body[i + 1] if i + 1 < len(body) else None
            if F.opt and c.k == 'expr' and c.e.k == 'bin' and c.e.op == '=' and strip(c.e.l).k == 'deref' and nxt is not None \
                    and nxt.k == 'expr' and strip(nxt.e).k == 'incdec' and strip(nxt.e).op == '++':
                pv = strip(strip(c.e.l).e); iv = strip(strip(nxt.e).e)
                if pv.k == 'load' and regvar_of(pv.e) and regvar_of(iv) is regvar_of(pv.e):
                    from frontend import N                   # _strncpy: ldb (XIX+:1),0x0
                    strip(c.e.l).e = N('incdec', op='++', post=True, e=iv, ty=pv.ty)
                    gen_stmt(F, c, False); i += 2; continue
            if c.k == 'expr' and c.e.k == 'opassign' and regvar_of(c.e.l) and nxt is not None and nxt.k == 'return' \
                    and nxt.value is not None and strip(nxt.value).k == 'load' and regvar_of(strip(nxt.value).e) is regvar_of(c.e.l) \
                    and (c.e.op in SIMPLE_OPS or c.e.op in ('*', '/', '%')):
                from frontend import N                           # .as_add_loc: ld HL,WA / add HL,BC
                d = regvar_of(c.e.l)
                ld = N('load', e=N('var', decl=d, ty=d.ty), ty=d.ty)
                nxt.value = N('bin', op=c.e.op, l=ld, r=c.e.r, ty=d.ty)
                F.last_use[d] = id(ld) if c.e.op in ('*', '/', '%') else None   # .as_mul_loc: muls XWA,BC in place
                i += 1; continue
            trivial = last and nxt is not None and i + 2 == len(body) and nxt.k == 'return' and (
                nxt.value is None or (strip(nxt.value).k == 'load' and regvar_of(strip(nxt.value).e)
                                      and regvar_of(strip(nxt.value).e).reg == 'HL'))
            F.trivial_ret_next = trivial
            gen_stmt(F, c, (last and i == len(body) - 1) or trivial); i += 1
            if not getattr(F, 'cl_active', None): F.cl_tmp_done = False
        return
    if s.k == 'decl': raise Unsupported('decl')
    if s.k == 'return' and s.value is not None and F.opt:
        cse = cse_params(F, s.value)
        if cse: return
    if s.k == 'return' and F.opt and getattr(F, 'shared_exit', None) and id(s) in F.shared_exit['early']:
        flush_pops(F); F.emit('j', F.shared_exit['label']); return       # _ultoa: j L50000
    if s.k == 'return' and F.opt and getattr(F, 'shared_exit', None) and id(s) == F.shared_exit['last']:
        F.lines.append(F.shared_exit['label'] + ':')
    if s.k == 'return' and s.value is not None and F.sret is not None:
        v = strip(s.value)
        if v.k == 'load' and strip(v.e).k == 'var' and hasattr(strip(v.e).decl, 'slot'):
            d = strip(v.e).decl                        # _ldiv: ld XIX,(sret) / lda XIY,XSP+slot / ld BC,n / ldirw
            F.emit('ld', 'XIX,(XSP+%s)' % hx(F.sret.off + F.push)); F.emit('lda', 'XIY,XSP+%s' % hx(d.slot + F.push))
            F.emit('ld', 'BC,%s' % hx(d.ty.size // 2)); F.emit('ldirw', '(XIX+),(XIY+)')
            if F.xiz_vars: F.emit('pop', 'XIZ')
            epilogue(F); F.emit('ret'); return
        raise Unsupported('struct return')
    if s.k == 'return':
        if s.value is not None:
            size = F.f.ret.size
            fam = gen(F, s.value, 'HL', size, then_ret=True)
            if fam != 'HL' and FAM[fam].get(size) != FAM['HL'][size]:
                F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam].get(size, FAM[fam].get(2))))
        flush_pops(F)
        if F.xiz_vars: F.emit('pop', 'XIZ')
        epilogue(F)
        F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret'); return
    if s.k == 'if' and s.els is None and F.opt and not F.pending and not F.pushes and not F.xiz_vars and \
            flat(s.then) and flat(s.then)[0].k == 'return' and len(flat(s.then)) == 1 and (
            flat(s.then)[0].value is None or (strip(flat(s.then)[0].value).k == 'load' and regvar_of(strip(flat(s.then)[0].value).e)
                                              and regvar_of(strip(flat(s.then)[0].value).e).reg == 'HL')):
        lab = F.newulabel()                                # _strchr: cp A,(XHL) / ret eq
        c = strip(s.cond)
        if c.k == 'bin' and c.op in CC_S:
            cc = gen_compare(F, c)
            if cc not in (True, False):
                F.emit('ret', cc); F.lines.append(lab + ':'); return
        raise Unsupported('conditional return')
    if s.k == 'if':
        if s.els is None:
            lab = F.newulabel()
            folded = False
            k = gen_cond_false(F, s.cond, 'RET' if last else lab)
            if F.lines[-1] == '\tret' and last:
                return                               # condition always false: the statement disappears
            gen_stmt(F, s.then, False)
            if k is not True: F.lines.append(lab + ':')   # always true: no label (cmp_ui: ge_ui_br0)
            return
        lelse, lend = F.newulabel(), F.newulabel()
        gen_cond_false(F, s.cond, lelse)
        gen_stmt(F, s.then, last)
        if last and not F.xiz_vars and not F.pushes and not F.lines[-1].startswith(('\tret', '\tj\t')):
            flush_pops(F); F.emit('ret')               # c_ifchain: the exit is duplicated, not jumped to
        elif not F.lines[-1].startswith(('\tret', '\tj\t')):
            flush_pops(F); F.emit('j', lend)
        F.push -= F.pending; F.pending = 0
        F.lines.append(lelse + ':')
        gen_stmt(F, s.els, last)
        if not (last and F.lines[-1].startswith('\tret')):
            F.lines.append(lend + ':')
        return
    if s.k == 'expr' and s.e.k == 'call':
        gen_call(F, s.e); return
    if s.k in ('for', 'while', 'do'):
        gen_loop(F, s, last); return
    if s.k == 'break': F.emit('j', F.loops[-1][0]); return
    if s.k == 'continue': F.emit('j', F.loops[-1][1]()); return
    if s.k == 'expr' and regvar_stmt(F, s.e): return
    if s.k == 'expr' and s.e.k == 'opassign':
        gen_opassign(F, s.e); return
    if s.k == 'expr' and s.e.k == 'incdec':
        gen_incdec(F, s.e, 'WA', 0, value=False); return
    if s.k == 'expr' and s.e.k == 'bin' and s.e.op == '=':
        lv = strip(s.e.l)
        if lv.k == 'var' and lv.decl.kind == 'global':
            store_global(F, lv.decl.name, s.e.r, lv.decl.ty.size); return
        size = lv.ty.size
        if lv.k == 'member' and not lv.arrow and strip(lv.base).k == 'var' and strip(lv.base).decl in getattr(F, 'struct_temps', {}):
            d = strip(lv.base).decl; t = F.struct_temps[d]
            setup_struct_temps(F, s)
            fam = gen(F, s.e.r, 'HL', size)              # _ldiv: value first (XHL from the helper), then the address
            tmp = t['tA'] if t['n'] == 0 else t['tB']; t['n'] += 1
            F.emit('ld', 'XWA,(XSP+%s)' % hx(tmp.slot + F.push))
            off = [o for n, ty, o in d.ty.rec if n == lv.name][0]
            F.emit('ld', '%s,%s' % ('(XWA+%s)' % hx(off) if off else '(XWA)', FAM[fam][size])); return
        if lv.ty.kind == 'struct':                   # m_copy: ld XIX,dst / ld XIY,src / ld BC,words / ldirw
            src = strip(s.e.r)
            if src.k == 'load': src = strip(src.e)
            if not (src.k == 'var' and src.decl.kind == 'global'): raise Unsupported('struct source')
            t = lvalue(F, lv, ptr='XIX')
            if t != '(XIX)': raise Unsupported('struct destination')
            F.emit('ld', 'XIY,_%s' % src.decl.name); F.emit('ld', 'BC,%s' % hx(size // 2))
            F.emit('ldirw', '(XIX+),(XIY+)'); return
        rc = fold(narrow(s.e.r, size))
        if rc.k == 'const' and size <= 2:            # m_gps_set: ldb (XWA),0x0
            t = lvalue(F, lv, ptr='XWA', idx='WA', base='XBC')     # ra_while: ldw (XBC+WA),0x0
            F.emit('ld' + ('b' if size == 1 else 'w'), '%s,%s' % (t, hx(rc.value))); return
        t = lvalue(F, lv)                            # m_ga_set, m_gps_set
        rv = regvar_of(strip(s.e.r).e) if strip(s.e.r).k == 'load' else None
        if rv is not None and rv.ty.size == size:
            F.emit('ld', '%s,%s' % (t, FAM[rv.reg][size])); return
        fam = gen(F, s.e.r, 'WA', size)
        F.emit('ld', '%s,%s' % (t, FAM[fam][size])); return
    raise Unsupported('statement ' + s.k)

def has_helper_call(e):
    if not hasattr(e, 'k'): return False
    if e.k == 'bin' and e.op in '*/%' and e.ty.size == 4 and fold(e.r).k != 'const': return True
    if e.k == 'call': return True
    return any(has_helper_call(v) for v in e.__dict__.values() if hasattr(v, 'k'))

def plan_registers(F):
    body = flat(F.f.body)
    helper_uses = {}
    def hv(n, d):
        if n.k == 'bin' and n.op in '*/%' and n.ty.size == 4 and fold(n.r).k != 'const':
            for side in (n.l, n.r):
                sv = strip(side)
                if sv.k == 'load' and strip(sv.e).k == 'var' and strip(sv.e).decl.kind == 'param':
                    helper_uses[strip(sv.e).decl] = helper_uses.get(strip(sv.e).decl, 0) + (1 if side is n.l else 0)
    walk(F.f.body, hv)
    for d, k in helper_uses.items():
        if k >= 2 and d.ty.size == 4 and not F.xiz_vars:  # _ldiv: numer in XIZ across the two helper calls
            d.reg = 'XIZ'; F.xiz_vars.append(d); F.deferred = getattr(F, 'deferred', []) + [d]
            F.emit('push', 'XIZ'); F.push = 4
            return
    for i, c in enumerate(body):
        if c.k == 'decl' and c.init is not None and c.var.ty.size == 4 and has_helper_call(c.init):
            later = body[i + 1:]
            if any(has_helper_call(getattr(x, 'value', None) or getattr(x, 'e', None)) for x in later):
                c.var.reg = 'XIZ'; F.xiz_vars.append(c.var)
    if F.xiz_vars:
        F.emit('push', 'XIZ'); F.push = 4

def regvar_of(e):
    v = strip(e)
    if v.k == 'var' and getattr(v.decl, 'reg', None) and v.decl.reg != 'XIZ': return v.decl
    return None

def operand(F, e, size, avoid=()):
    """an operand string for e, emitting address setup for indexed loads (ra_leaf: add HL,(XBC+WA))"""
    m = mem_operand(F, e)
    if m is not None: return m
    e0 = narrow(e, size)
    if getattr(F, 'cl_active', None) and e0.k == 'load' and strip(e0.e).k == 'index' and \
            strip(strip(e0.e).base).k == 'var' and strip(strip(e0.e).base).decl is F.cl_active['arr']:
        if getattr(F, 'cl_shared', False):                 # ol_i_acc2: lda XWA,XDE+BC / (XWA)
            if not getattr(F, 'cl_tmp_done', False):
                F.emit('lda', 'XWA,%s' % F.cl_operand.strip('()')); F.cl_tmp_done = True
            return '(XWA)'
        return F.cl_operand
    if e0.k == 'load' and strip(e0.e).k == 'deref' and strip(strip(e0.e).e).k == 'incdec' and strip(strip(e0.e).e).post:
        inc = strip(strip(e0.e).e); pm = mem_operand(F, inc.e) if False else None
        pv = strip(inc.e)
        if pv.k == 'var' and pv.decl.kind == 'param' and not getattr(pv.decl, 'reg', None):
            slot = '(XSP+%s)' % hx(pv.decl.off + F.push)            # ra_ptr: bump the pointer in place
            F.emit('ld', 'XBC,%s' % slot); F.emit('ld', 'XWA,%s' % hx(pv.ty.base.size))
            F.emit('add' if inc.op == '++' else 'sub', '%s,XWA' % slot); return '(XBC)'
    m = mem_operand(F, e0)
    if m is not None: return m
    if e0.k == 'load' and strip(e0.e).k == 'index':
        v = strip(e0.e); b = strip(v.base); esz = v.ty.size
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            im = mem_operand(F, v.idx) or mem_operand(F, strip(v.idx))
            if im is None: raise Unsupported('complex index')
            if esz == 1 and im in ('BC', 'DE', 'HL'):          # ra_char: lda XWA,_gca / (XWA+BC)
                F.emit('lda', 'XWA,_%s' % b.decl.name); return '(XWA+%s)' % im
            F.emit('ld', 'WA,%s' % im)
            F.emit('add', 'WA,WA') if esz == 2 else F.emit('sla', '%s,WA' % hx({4: 2, 8: 3}[esz]))
            F.emit('lda', 'XBC,_%s' % b.decl.name); return '(XBC+WA)'
    return None

def regvar_stmt(F, e):
    """assignments to register variables: v = x, v op= x, v++ (ra_leaf, ctrl)"""
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l):
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        rc = fold(narrow(e.r, d.ty.size))
        if rc.k == 'const': F.emit('ld', '%s,%s' % (R, hx(rc.value))); return True
        m = operand(F, e.r, d.ty.size)
        if m is not None: F.emit('ld', '%s,%s' % (R, m)); return True
        tgt = d.reg if d.reg in ('BC', 'DE', 'HL', 'WA') else 'WA'      # ra_noloop3: ld DE,(a) / add DE,(b)
        fam = gen(F, e.r, tgt, d.ty.size)
        if FAM[fam][d.ty.size] != R: F.emit('ld', '%s,%s' % (R, FAM[fam][d.ty.size]))
        return True
    if e.k == 'opassign' and regvar_of(e.l) and e.op in SIMPLE_OPS:
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        rc = fold(narrow(e.r, d.ty.size))
        if e.op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
            F.emit('inc' if e.op == '+' else 'dec', '%s,%s' % (hx(rc.value), R)); return True
        m = operand(F, e.r, d.ty.size)
        if m is None:                                  # ra_param3: s += b * c -> WA, then add HL,WA
            fam = gen(F, e.r, 'WA', d.ty.size); m = FAM[fam][d.ty.size]
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (R, m)); return True
    if e.k == 'incdec' and regvar_of(e.e):
        d = regvar_of(e.e); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        step = d.ty.base.size if d.ty.kind == 'ptr' else 1
        F.emit('inc' if e.op == '++' else 'dec', '%s,%s' % (hx(step), R)); return True
    return False

def loop_cond(F, c, target, sense):
    """jump to target when c is true (sense) or false (not sense); x-- as condition (rc_while)"""
    c = strip(c)
    if c.k == 'bin' and c.op == '&&' and sense:          # _strncpy: first false -> past the loop, last true -> body
        out = F.newulabel(); loop_cond(F, c.l, out, False); loop_cond(F, c.r, target, True)
        F.lines.append(out + ':'); return
    if c.k == 'bin' and c.op == '&&' and not sense:
        loop_cond(F, c.l, target, False); loop_cond(F, c.r, target, False); return
    if c.k == 'bin' and c.op == '||' and sense:
        loop_cond(F, c.l, target, True); loop_cond(F, c.r, target, True); return
    if c.k == 'bin' and c.op == '||' and not sense:
        inn = F.newulabel(); loop_cond(F, c.l, inn, True); loop_cond(F, c.r, target, False)
        F.lines.append(inn + ':'); return
    if c.k == 'incdec' and c.post and regvar_of(c.e):
        d = regvar_of(c.e); R = FAM[d.reg][2]
        F.emit('ld', 'WA,%s' % R); F.emit('dec' if c.op == '--' else 'inc', '0x1,%s' % R); F.emit('cp', 'WA,0x0')
        cc = 'ne' if sense else 'eq'
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k == 'incdec' and not c.post and regvar_of(c.e):          # ra_dowhile: dec DE / ld WA,DE / cp WA,0
        d = regvar_of(c.e); R = FAM[d.reg][2]
        F.emit('dec' if c.op == '--' else 'inc', '0x1,%s' % R); F.emit('ld', 'WA,%s' % R); F.emit('cp', 'WA,0x0')
        cc = 'ne' if sense else 'eq'
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k in ('load', 'cast') and c.ty.kind in ('int', 'ptr'):         # while (*s): compare with 0
        from frontend import N
        return loop_cond(F, N('bin', op='!=', l=c, r=N('const', value=0, ty=c.ty), ty=c.ty), target, sense)
    if c.k == 'bin' and c.op in CC_S:
        cc = gen_compare(F, c)
        if cc is True or cc is False: raise Unsupported('constant loop condition')
        cc = cc if sense else INV[cc]
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    raise Unsupported('loop condition ' + c.k)

def gen_counted(F, s, last, cl):
    """the -O counted loop (ol_i_acc1 .. ol_c_glob)"""
    if 'kconst' in cl:                                     # ol_i_const: walk a pointer to an end pointer
        F.emit('lda', 'XBC,_%s' % cl['arr'].name); F.emit('ld', 'XWA,XBC')
        F.emit('lda', 'XBC,XBC+%s' % hx(cl['kconst'] * cl['esz']))
        body = F.newulabel(); F.newulabel()
        F.lines.append(body + ':')
        F.cl_operand = '(XWA+:%d)' % cl['esz']; F.cl_active = cl; F.cl_shared = False
        gen_stmt(F, s.body, False)
        F.cl_active = None; F.cl_operand = None
        F.emit('cp', 'XWA,XBC'); F.emit('j', 'ult,%s' % body)
        return
    i = cl['i']; I = FAM[i.reg][2]; K = FAM[cl['kp'].reg][2]
    F.emit('ld', '%s,0x0' % I)
    kd = cl['k']
    km = '(XSP+%s)' % hx(kd.off + F.push) if kd.kind == 'param' else '(_%s)' % kd.name
    F.emit('ld', '%s,%s' % (K, km))
    F.emit('cp', '%s,0x0' % K)
    exitl = F.newulabel(); body = F.newulabel()
    trivial = last and not F.pushes
    F.emit('ret', 'le') if trivial else F.emit('j', 'le,%s' % exitl)
    B = FAM[cl['base'].reg][4]
    F.emit('lda', '%s,_%s' % (B, cl['arr'].name))
    if 'off' in cl: O = FAM[cl['off'].reg][2]; F.emit('ld', '%s,0x0' % O); X = O
    else: X = I
    F.lines.append(body + ':')
    F.cl_operand = '(%s+%s)' % (B, X); F.cl_tmp_done = False
    if cl.get('tmp'):
        F.cl_shared = True
    F.cl_active = cl
    gen_stmt(F, s.body, False)
    F.cl_active = None; F.cl_operand = None; F.cl_tmp_done = False
    F.emit('inc', '0x1,%s' % I)
    if 'off' in cl: F.emit('inc', '%s,%s' % (hx(cl['esz']), FAM[cl['off'].reg][2]))
    F.emit('cp', '%s,%s' % (I, K)); F.emit('j', 'lt,%s' % body)
    F.lines.append(exitl + ':')

def gen_loop(F, s, last):
    """for / while / do (regalloc_notes.md, loop shapes); labels: exit first, then body"""
    cl = getattr(F, 'counted', {}).get(id(s))
    if cl: return gen_counted(F, s, last, cl)
    if s.k == 'for' and s.init is not None: gen_stmt(F, s.init, False)
    after_ret = last and not F.xiz_vars and not F.pushes and not F.pending
    if s.k == 'do':
        body = F.newulabel(); F.lines.append(body + ':')
        cont = [None]
        def getc():
            if cont[0] is None: cont[0] = F.newulabel()
            return cont[0]
        exitl = None
        F.loops.append((None, getc)); gen_stmt(F, s.body, False); F.loops.pop()
        if cont[0]: F.lines.append(cont[0] + ':')
        loop_cond(F, s.cond, body, True)
        return
    if s.k == 'while' and F.opt and s.cond is not None:  # -XS rotation: j test / body / test (_strcat)
        test = F.newulabel(); body = F.newulabel()
        F.emit('j', test); F.lines.append(body + ':')
        cont = [None]
        def getc2():
            if cont[0] is None: cont[0] = F.newulabel()
            return cont[0]
        F.loops.append((None, getc2)); gen_stmt(F, s.body, False); F.loops.pop()
        F.lines.append(test + ':')
        loop_cond(F, s.cond, body, True)
        return
    exitl = F.newulabel(); body = F.newulabel()
    cont = [None]
    def getc():
        if cont[0] is None: cont[0] = F.newulabel()
        return cont[0]
    if s.cond is not None: loop_cond(F, s.cond, 'RET' if after_ret and not F.loops else exitl, False)
    F.lines.append(body + ':')
    F.loops.append((exitl, getc)); gen_stmt(F, s.body, False); F.loops.pop()
    if cont[0]: F.lines.append(cont[0] + ':')
    inc = strip(s.inc) if s.k == 'for' and s.inc is not None else None
    cnd = strip(s.cond) if s.cond is not None else None
    if inc is not None and inc.k == 'incdec' and inc.op == '--' and regvar_of(inc.e) and cnd is not None \
            and cnd.k == 'bin' and cnd.op in ('>', '!=') and fold(cnd.r).k == 'const' and fold(cnd.r).value == 0 \
            and regvar_of(getattr(strip(cnd.l), 'e', cnd.l)) is regvar_of(inc.e):
        d = regvar_of(inc.e)                                       # ra_for_down: sub DE,0x1 / j gt
        F.emit('sub', '%s,0x1' % FAM[d.reg][2]); F.emit('j', '%s,%s' % ('gt' if cnd.op == '>' else 'ne', body))
        F.lines.append(exitl + ':'); return
    if s.k == 'for' and s.inc is not None: gen_stmt(F, N_expr(s.inc), False)
    if s.cond is not None: loop_cond(F, s.cond, body, True)
    else: F.emit('j', body)
    F.lines.append(exitl + ':')

def N_expr(e):
    from frontend import N
    return N('expr', e=e)

def walk(node, fn, depth=0):
    if isinstance(node, list):
        for x in node: walk(x, fn, depth)
        return
    if not hasattr(node, 'k'): return
    fn(node, depth)
    d = depth + (1 if node.k in ('for', 'while', 'do') else 0)
    for k, v in node.__dict__.items():
        if hasattr(v, 'k') or isinstance(v, list): walk(v, fn, d)

class Pseudo:
    """a value the -O loop transformation creates: the hoisted base, the byte offset, the bound copy"""
    def __init__(s, name, size): s.name = name; s.reg = None; s.ty = type('T', (), {'size': size, 'kind': 'int'})()

def counted_loop(F, s):
    """for (i = 0; i < k; i++) over global arrays indexed by i (regalloc_notes.md, Loops at -O3 -XS):
    returns a description or None"""
    if s.k != 'for' or s.init is None or s.cond is None or s.inc is None: return None
    ini = flat(s.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return None
    iv = strip(strip(ini[0].e).l); v0 = fold(strip(ini[0].e).r)
    if iv.k != 'var' or iv.decl.kind != 'local' or iv.decl.ty.size != 2 or v0.k != 'const' or v0.value != 0: return None
    c = strip(s.cond)
    if not (c.k == 'bin' and c.op == '<' and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var'
            and strip(strip(c.l).e).decl is iv.decl): return None
    kv = strip(c.r)
    while kv.k == 'cast': kv = strip(kv.e)
    kconst = fold(c.r) if fold(c.r).k == 'const' else None
    if kconst is None and not (kv.k == 'load' and strip(kv.e).k == 'var' and strip(kv.e).decl.kind in ('param', 'global')):
        return None
    inc = strip(s.inc)
    if not (inc.k == 'incdec' and inc.op == '++' and strip(inc.e).k == 'var' and strip(inc.e).decl is iv.decl): return None
    arrays = []; bad = []
    def v(n, d):
        if n.k == 'index':
            b = strip(n.base); ix = strip(n.idx)
            while ix.k == 'cast': ix = strip(ix.e)
            if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and ix.k == 'load' \
                    and strip(ix.e).k == 'var' and strip(ix.e).decl is iv.decl:
                if b.decl not in [a for a, _ in arrays]: arrays.append((b.decl, n.ty.size))
            else: bad.append(n)
        if n.k == 'call': bad.append(n)
    walk(s.body, v)
    if bad or len(arrays) != 1: return None
    if kconst is not None:
        other = []                                       # ol_i_const: only if i has no other use
        walk(s.body, lambda n, d: other.append(n) if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl is iv.decl else None)
        nidx = []
        walk(s.body, lambda n, d: nidx.append(n) if n.k == 'index' else None)
        if len(other) != len(nidx) or kconst.value <= 0: return None
        return {'i': iv.decl, 'kconst': kconst.value, 'arr': arrays[0][0], 'esz': arrays[0][1]}
    return {'i': iv.decl, 'k': strip(kv.e).decl, 'arr': arrays[0][0], 'esz': arrays[0][1]}

def plan_leaf(F):
    """the leaf-function allocator of regalloc_notes.md"""
    f = F.f
    has_call = []; loopvars = {}; modified = set(); deep = set(); temps_bc = []
    def visit(n, depth):
        if n.k == 'call': has_call.append(n)
        if n.k == 'load' and strip(n.e).k == 'var':
            d = strip(n.e).decl
            if depth: loopvars[d] = loopvars.get(d, 0) + 1
            if depth >= 2: deep.add(d)
        if n.k in ('incdec',) and strip(n.e).k == 'var': modified.add(strip(n.e).decl); loopvars[strip(n.e).decl] = loopvars.get(strip(n.e).decl, 0) + (1 if depth else 0)
        if n.k in ('opassign',) and strip(n.l).k == 'var': modified.add(strip(n.l).decl)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': modified.add(strip(n.l).decl)
        if n.k == 'index' and strip(n.base).k == 'var' and strip(n.base).decl.ty.kind == 'array' and n.ty.size >= 2 and fold(n.idx).k != 'const':
            temps_bc.append(n)
        if n.k == 'load' and strip(n.e).k == 'deref' and not F.opt: temps_bc.append(n)
    walk(f.body, visit)
    if has_call: return False
    hasloop = []
    walk(f.body, lambda n, d: hasloop.append(1) if n.k in ('for', 'while', 'do') else None)
    if not hasloop:
        uses = {}
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.e).decl, uses.get(strip(n.e).decl, 0) + 1)
             if n.k == 'load' and strip(n.e).k == 'var' else None)
        multi = [d for d in f.decls if d.kind == 'local' and uses.get(d, 0) >= 2 and d.ty.kind == 'int']
        if not multi: return False
    rets = []
    walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    F.counted = {}
    if F.opt:
        loops = []
        walk(f.body, lambda n, d: loops.append(n) if n.k == 'for' else None)
        if len(loops) == 1 and counted_loop(F, loops[0]) and not has_call:
            cl = counted_loop(F, loops[0]); F.counted[id(loops[0])] = cl
            uses_in_body = {}
            walk(loops[0].body, lambda n, d: uses_in_body.__setitem__(strip(n.base).decl, uses_in_body.get(strip(n.base).decl, 0) + 1)
                 if n.k == 'index' else None)
            shared = uses_in_body.get(cl['arr'], 0) >= 2 and cl['esz'] > 1
            stores_long = []
            walk(loops[0].body, lambda n, d: stores_long.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index'
                 and strip(n.l).ty.size == 4 else None)
            seq = ['WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ']
            rets0 = []
            walk(f.body, lambda n, d: rets0.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None
                 and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
            reserved = set()
            if 'kconst' in cl:
                locs = [d for d in f.decls if d.kind == 'local' and d.ty.kind == 'int' and not d.addr_taken and d is not cl['i']]
                for d in locs:
                    if d in rets0: d.reg = 'HL'
                cl['i'].reg = None
                return True
            if shared or stores_long: reserved.add('WA')
            locs = [d for d in f.decls if d.kind == 'local' and d.ty.kind == 'int' and not d.addr_taken]
            for d in locs:
                if d in rets0: d.reg = 'HL'; reserved.add('HL')
            free = [r for r in seq if r not in reserved]
            kd = cl['k']; kp = Pseudo('bound', 2); cl['kp'] = kp
            order = []
            if kd.kind == 'global': order.append(kp)
            if cl['esz'] > 1: cl['off'] = Pseudo('offset', 2); order.append(cl['off'])
            cl['base'] = Pseudo('base', 4); order.append(cl['base'])
            if kd.kind != 'global': order.append(kp)
            order += [d for d in reversed(locs) if not getattr(d, 'reg', None)]
            for x in order:
                x.reg = free.pop(0)
            if shared: cl['tmp'] = 'WA'
            F.pushes = ['IZ'] if any(getattr(x, 'reg', None) == 'IZ' for x in order + locs) else []
            if F.pushes: F.emit('push', 'IZ'); F.push = 2
            return True
    okind = ('int', 'ptr') if F.opt else ('int',)
    locals_ = [d for d in f.decls if d.kind == 'local' and not d.addr_taken and d.ty.kind in okind]
    if not hasloop:
        locals_ = multi
    params = [d for d in f.params if d.ty.kind in okind and (d in modified or d in deep or (F.opt and d in loopvars))]
    order = params + list(reversed(locals_))
    if F.opt: order = list(reversed(locals_)) + list(reversed(params))      # _strcat at -O: s, s2, s1
    free = [r for r in LEAF_SEQ if not (r == 'BC' and temps_bc)]
    for d in order:
        if d in rets and 'HL' in free:
            d.reg = 'HL'; free.remove('HL')
            if d.kind == 'param': F.param_copies.append(d)        # _strchr: ld XHL,(XSP+4)
    narrowed = set()
    walk(f.body, lambda n, dep: narrowed.add(strip(strip(n.e).e).decl) if n.k == 'cast' and n.kind == 'IntegralCast'
         and n.ty.size == 1 and strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' else None)
    if F.opt:
        free = ['WA'] + [r for r in free if r != 'WA'] if 'WA' not in free else free
    for d in order:
        if getattr(d, 'reg', None): continue
        if F.opt and d in narrowed and d.ty.size == 2 and 'WA' in free:     # guess (_strchr: c in WA)
            d.reg = 'WA'; free.remove('WA')
            if d.kind == 'param': F.param_copies.append(d)
            continue
        if d.ty.size == 4: cand = [r for r in free if r in ('BC', 'DE', 'HL', 'IX', 'IY')]
        elif d.ty.size == 1: cand = [r for r in free if r in ('BC', 'DE', 'HL')]
        else: cand = free
        cand = [r for r in cand if r != 'WA']
        if not cand: raise Unsupported('out of registers')
        d.reg = cand[0]; free.remove(cand[0])
        if d.kind == 'param': F.param_copies.append(d)
    if any(getattr(d, 'reg', None) == 'IZ' for d in order): F.emit('push', 'IZ'); F.push = 2; F.pushes = ['IZ']
    if F.opt:
        F.deferred = list(F.param_copies)              # loaded at first use (_strcat: ld XBC,(XSP+8) late)
    else:
        for d in F.param_copies:
            R = FAM[d.reg][d.ty.size]
            F.emit('ld', '%s,(XSP+%s)' % (R, hx(d.off + F.push)))
    return True

def compute_last_uses(F):
    """id of the last load of each variable in evaluation order; loads inside loops are never last"""
    F.last_use = {}
    def v(n, depth):
        if n.k == 'load' and strip(n.e).k == 'var':
            d = strip(n.e).decl
            F.last_use[d] = None if depth else id(n)
            if depth: F.in_loop.add(d)
    F.in_loop = set()
    walk(F.f.body, v)
    for d in F.in_loop: F.last_use[d] = None

def dies_here(F, e):
    e = strip(e)
    return e.k == 'load' and strip(e.e).k == 'var' and F.last_use.get(strip(e.e).decl, 'x') == id(e)

def live_regs(F, except_decl=None):
    out = set()
    for d in list(F.f.params) + list(F.f.decls):
        r = getattr(d, 'reg', None)
        if r and d is not except_decl and d not in F.dead: out.add(r)
    return out

def foldable(f, d):
    """a local that gen_stmt folds into its single use (no slot needed)"""
    body = flat(f.body)
    for i, c in enumerate(body):
        if c.k == 'decl' and c.var is d:
            if c.init is None or d.addr_taken or d.ty.size < 2: return False
            return len(uses_of(body[i + 1:], d, [])) == 1
    return False

def plan_frame(F):
    """stack slots for locals without a register (rc_loop2-4: dec N,XSP / push XIZ / slots from (XSP+4) in
    declaration order); parameters move up by the frame size"""
    f = F.f; pos = 0; slots = []
    calls = []
    walk(f.body, lambda n, d: calls.append(n) if n.k == 'call' or (n.k == 'bin' and n.op in '*/%' and n.ty.size == 4
         and fold(n.r).k != 'const') else None)
    if not calls: F.frame = 0; return                   # leaf functions: every local is in a register or folded
    # D: a struct local written member by member gets two address temporaries below it (_ldiv: (XSP+4), (XSP+8))
    F.struct_temps = {}
    for d in f.decls:
        if d.kind == 'local' and d.ty.kind == 'struct':
            stores = []
            walk(f.body, lambda n, dep: stores.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'member'
                 and not strip(n.l).arrow and strip(strip(n.l).base).k == 'var' and strip(strip(n.l).base).decl is d else None)
            if len(stores) == 2:
                from frontend import Decl, Type
                ta = Decl('__tA', Type('ptr', 4, 2, spell='t'), '', 'local'); tb = Decl('__tB', Type('ptr', 4, 2, spell='t'), '', 'local')
                F.struct_temps[d] = {'stores': [id(x) for x in stores], 'tA': ta, 'tB': tb, 'done': False}
                f.decls = [x for x in f.decls if x is not d] + [ta, tb, d]
    for d in f.decls:
        if d.kind != 'local' or getattr(d, 'reg', None) or foldable(f, d): continue
        a = 2 if d.ty.size >= 2 else 1
        pos = (pos + a - 1) // a * a; d.slot = pos; pos += d.ty.size; slots.append(d)
    if not slots: F.frame = 0; return
    size = (pos + 1) // 2 * 2; F.frame = size
    for p in f.params:
        if hasattr(p, 'off'): p.off += size
    F.lines.insert(1, '\tdec\t%s,XSP' % hx(size) if size <= 8 else '\tlda\tXSP,XSP-%s' % hx(size))

def epilogue(F):
    for r in reversed(F.pushes): F.emit('pop', r)
    if getattr(F, 'frame', 0):
        F.emit('inc', '%s,XSP' % hx(F.frame)) if F.frame <= 8 else F.emit('lda', 'XSP,XSP+%s' % hx(F.frame))

def plan_shared_exit(F):
    """-XS: returns of the same simple value share the last one's code (_ultoa: two return (s) -> j L50000)"""
    rets = []
    walk(F.f.body, lambda n, d: rets.append(n) if n.k == 'return' else None)
    def key(r):
        v = strip(r.value) if r.value is not None else None
        if v is None: return 'void'
        if v.k == 'load' and strip(v.e).k == 'var': return 'var:%s' % strip(v.e).decl.name
        return None
    if len(rets) >= 2 and key(rets[-1]) is not None and key(rets[-1]) != 'void' and all(key(r) == key(rets[-1]) for r in rets):
        F.shared_exit = {'label': F.newlabel(), 'early': {id(r) for r in rets[:-1]}, 'last': id(rets[-1])}

def compile_function(f, opt, adecl, personality='v4.23'):
    F = Fn(f, adecl)
    F.personality = personality
    F.opt = opt != 'none'; F.dead = set()
    compute_last_uses(F)
    F.lines.append(('.' if adecl else '_') + f.name + ':')
    F.loops = []; F.param_copies = []; F.pushes = []
    if not plan_leaf(F): plan_registers(F)
    plan_frame(F)
    if F.opt: plan_shared_exit(F)
    gen_stmt(F, f.body, True)
    flush_pops(F)
    if not F.lines[-1].startswith('\tret'):
        if F.xiz_vars: F.emit('pop', 'XIZ')
        epilogue(F)
        F.emit('ret')
    # a call directly followed by the return becomes a jump (cmp_ui: ge_ui_br0)
    if len(F.lines) >= 2 and F.lines[-1] == '\tret' and F.lines[-2].startswith('\tcal\t') \
            and not F.lines[-2].split('\t')[2].startswith(('C9H_', '._f')):
        F.lines[-2:] = ['\tj\t' + F.lines[-2].split('\t')[2]]
    # a label that only a jump to `ret` uses: the oracle keeps it; nothing to do here yet
    return F.lines

def compile_unit(unit, opt='none', adecl=False, personality='v4.23'):
    out = {}
    for f in unit.functions:
        name = ('.' if adecl else '_') + f.name
        try: out[name] = compile_function(f, opt, adecl, personality)
        except Unsupported as ex: out[name] = ['; unsupported: %s' % ex]
        except (AttributeError, KeyError, ValueError, TypeError, IndexError) as ex:
            out[name] = ['; model error: %s: %s' % (type(ex).__name__, ex)]     # counted as a mismatch
    return out
