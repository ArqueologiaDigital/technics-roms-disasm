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

PSEUDO = ('XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'A', 'L')

def hx(v):
    return '0x%x' % (v & 0xffffffff) if v >= 0 else '0x%x' % (v & 0xffffffff)

class Fn:
    def __init__(s, f, adecl):
        s.f = f; s.lines = []; s.adecl = adecl; s.label = 50000; s.push = 0; s.xiz_vars = []; s.pending = 0
        s.save_reg = 'XIZ'                         # push IZ when only IZ holds a value (call.c k_seq, adecl.c d_keep)
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
    while e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size >= size and not wide_divide(strip(e.e), size):
        e = strip(e.e)                                   # / % >> on wide operands keep their width (_ultoa: val % radix)
    if e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size < size:
        return e
    return e

def operand_width(x):
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size <= x.ty.size: x = strip(x.e)
    return 0 if fold(x).k == 'const' else x.ty.size

def wide_divide(e, size):
    """/ % >> whose operands are wider than `size`: narrowing would change the result (binop_c div_c: char operands
    narrow; _ultoa: val % radix on longs does not)"""
    return e.k == 'bin' and e.op in ('/', '%', '>>') and e.ty.size > size and \
        max(operand_width(e.l), operand_width(e.r) if e.op != '>>' else 0) > size

def fold(e):
    """constant folding of integral casts of constants"""
    e = strip(e)
    if e.k == 'bin' and e.op in ('+', '-', '*') and fold(e.l).k == 'const' and fold(e.r).k == 'const' and \
            fold(e.l).value is not None and fold(e.r).value is not None:
        from frontend import N                           # sizeof(buf) - 1
        a, b = fold(e.l).value, fold(e.r).value
        return N('const', value={'+': a + b, '-': a - b, '*': a * b}[e.op], ty=e.ty)
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
    if strip(e).k == 'cast':
        ct = cast_temp(F, strip(e))
        if ct: return ct
    e = fold(e)
    if e.k == 'load' and strip(e.e).k == 'deref' and getattr(F, 'naive_loads', False):
        pv = strip(strip(e.e).e)                          # _ultoa: ld XWA,(p) / ... (XWA)
        if pv.k == 'load' and strip(pv.e).k == 'var' and hasattr(strip(pv.e).decl, 'slot'):
            F.emit('ld', 'XWA,(XSP+%s)' % hx(strip(pv.e).decl.slot + F.push)); return '(XWA)'
    if e.k == 'const' and e.value is not None: return hx(e.value)
    if e.k == 'load':
        v = strip(e.e)
        if v.k == 'var':
            d = v.decl
            if getattr(F, 'lazy_homes', None) and d in F.lazy_homes: touch_home(F, d)
            if getattr(d, 'reg', None) and d.reg != 'XIZ':
                return FAM[d.reg].get(d.ty.size) or FAM[d.reg][2]
            if getattr(d, 'homed', False) and d.reg == 'XIZ': return 'XIZ'
            if d.kind == 'local' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + F.push)
            if d.kind == 'param' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + F.push)   # homed (d_keep)
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

def esize_of(b):
    t = strip(b.l).ty
    return t.base.size if t.kind in ('ptr', 'array') and t.base is not None else 1

def gen(F, e, fam, size, then_ret=False, store=False):
    """emit code leaving e's low `size` bytes in register family `fam`; returns the family actually used"""
    e0 = strip(e)
    if e0.k == 'cast' and e0.kind == 'IntegralCast' and strip(e0.e).ty.size > size and mem_operand(F, e0.e) and \
            family_of(mem_operand(F, e0.e)):
        # a narrowing cast of a register variable (unop_*, v423 Xr / O3XSXr): without -O it is moved at the narrow
        # width (.cast_i_c: ld L,A; .cast_l_i: ld HL,WA); with -O at the source width (ld HL,WA; ld XHL,XWA), except
        # long to char (ld L,A)
        isz = strip(e0.e).ty.size; r = family_of(mem_operand(F, e0.e))[1:]
        w = (1 if size == 1 and isz == 4 else isz) if F.opt else size
        if r != fam: F.emit('ld', '%s,%s' % (FAM[fam][w], FAM[r][w]))
        return fam
    if e0.k == 'cast' and e0.kind == 'IntegralCast' and strip(e0.e).ty.size > size and mem_operand(F, e0.e) and \
            not family_of(mem_operand(F, e0.e)):
        # a narrowing cast of a load reads at the source width (unop_*: cast_l_c, cast_i_c)
        isz = strip(e0.e).ty.size
        F.emit('ld', '%s,%s' % (FAM[fam][isz], mem_operand(F, e0.e))); return fam
    if e0.k == 'cast' and e0.kind == 'IntegralCast' and strip(e0.e).ty.size > size and strip(e0.e).k == 'bin' and \
            strip(e0.e).op in SIMPLE_OPS:
        b = strip(e0.e); lv = strip(b.l); rm = mem_operand(F, b.r)
        d = regvar_of(lv.e) if lv.k == 'load' else None
        if strip(b.l).ty.kind in ('ptr', 'array') and b.op == '-' and esize_of(b) > 1: rm = None   # m_diff: scaled
        elif rm is not None and family_of(rm) and rm.startswith('X') and b.ty.size == 4: pass   # _strlen: sub XHL,XIZ
        elif rm is not None and family_of(rm): rm = None
        if d is not None and d.reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, lv) and rm is not None:
            F.emit(SIMPLE_OPS[b.op], '%s,%s' % (FAM[d.reg][b.ty.size], rm))   # sw_ev: sub XBC,0x2000 / ld WA,BC
            if d.reg != fam: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[d.reg][size]))
            return fam
    e = narrow(e, size)
    src = mem_operand(F, e)
    if src is not None:
        if src.startswith('X') and size < 4 and src[1:] in FAM: src = FAM[src[1:]][size]   # a long register, narrowed
        if src != FAM[fam][size]: F.emit('ld', '%s,%s' % (FAM[fam][size], src))
        return fam
    if e.k == 'cast' and e.kind == 'IntegralCast':
        inner = strip(e.e); isz = inner.ty.size
        if isz == 1 and size == 4 and not inner.ty.signed and F.opt and family_of(mem_operand(F, inner) or ''):
            F.emit('ld', '%s,%s' % (FAM[fam][1], mem_operand(F, inner)))   # .cast_uc_l under O3XSXr
            F.emit('ld', '%s,0x0' % FAM[fam][1].replace('L', 'H').replace('A', 'W').replace('C', 'B').replace('E', 'D'))
            F.emit('extz', FAM[fam][4]); return fam
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
        x = strip(e.e)
        while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size <= x.ty.size: x = strip(x.e)
        ur = regvar_of(x.e) if x.k == 'load' else None           # .not_c: ~ on a promoted char
        if ur is not None and dies_here(F, x) and ur.reg != fam and ur.reg in ('WA', 'BC', 'DE') and \
                (e.op == '~' or F.opt):                        # without -O only ~ works in place (.neg_i: ld HL,WA / neg HL)
            if size == 4:                                      # .not_l under Xr: cpl WA / cpl QWA / ld XHL,XWA
                F.emit('cpl', FAM[ur.reg][2]); F.emit('cpl', Q[ur.reg])
                if e.op == '-': F.emit('inc', '0x1,%s' % FAM[ur.reg][4])
            else: F.emit('neg' if e.op == '-' else 'cpl', FAM[ur.reg][size])     # .neg_i, .not_i under Xr
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
    if e.k == 'addr' and strip(e.e).k == 'index' and local_array_of(strip(e.e).base) in getattr(F, 'array_temps', {}) \
            and fold(strip(e.e).idx).k == 'const':
        a = local_array_of(strip(e.e).base); array_base(F, a)   # _ultoa: p = &buf[31] -> lda XWA,XWA+0x1f
        off = fold(strip(e.e).idx).value * strip(e.e).ty.size
        if off: F.emit('lda', 'XWA,XWA+%s' % hx(off))
        if fam != 'WA': F.emit('ld', '%s,XWA' % FAM[fam][4])
        return fam
    if e.k == 'bin' and e.op in ('&&', '||'):        # c_and / c_or: ld HL,0 / conditions / ld HL,1
        R = FAM[fam][2]
        if not getattr(F, 'preset_hl', False): F.emit('ld', '%s,0x0' % R)
        F.preset_hl = False
        lend = F.newulabel()
        gen_cond_false(F, e, 'RET' if then_ret else lend)
        F.emit('ld', '%s,0x1' % R); F.lines.append(lend + ':'); return fam
    if e.k == 'cond' and F.opt:
        c, a, b = strip(e.c), strip(e.a), strip(e.b)
        v = strip(b.e).decl if b.k == 'load' and strip(b.e).k == 'var' else None
        if v is not None and c.k == 'bin' and c.op in CC_S and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var' \
                and strip(strip(c.l).e).decl is v and fold(c.r).k == 'const' and a.k == 'un' and a.op in ('-', '~') \
                and strip(a.e).k == 'load' and strip(strip(a.e).e).k == 'var' and strip(strip(a.e).e).decl is v \
                and mem_operand(F, b) is not None:
            R = FAM[fam][size]                       # _abs: ld HL,(XSP+0x4) / cp HL,0x0 / ret ge / neg HL
            lelse, lend = F.newulabel(), F.newulabel()
            if mem_operand(F, b) != R: F.emit('ld', '%s,%s' % (R, mem_operand(F, b)))
            F.emit('cp', '%s,%s' % (R, hx(fold(c.r).value)))
            cc = (CC_S if v.ty.signed else CC_U)[c.op]
            F.emit('ret', INV[cc]) if then_ret else F.emit('j', '%s,%s' % (INV[cc], lelse))
            if size == 4:                            # _labs: cpl HL / cpl QHL / inc 0x1,XHL
                F.emit('cpl', FAM[fam][2]); F.emit('cpl', Q[fam])
                if a.op == '-': F.emit('inc', '0x1,%s' % R)
            else: F.emit('neg' if a.op == '-' else 'cpl', R)
            F.lines.append(lelse + ':'); F.lines.append(lend + ':'); return fam
    if e.k == 'cond' and F.opt:
        c, a, b = strip(e.c), strip(e.a), strip(e.b)
        def simple(x):
            x = strip(narrow(x, size))
            return 0 if fold(x).k == 'const' else 1 if mem_operand(F, x) is not None else 2
        R = FAM[fam][size]
        if c.k == 'bin' and c.op in CC_S and min(simple(a), simple(b)) <= 1 and \
                strip(c.l).k == 'load' and (fold(c.r).k == 'const' or strip(c.r).k == 'load'):
            # -O: the simpler arm goes to the result register first, the other is computed only when needed
            # (ctrl.c c_tern: ld WA,(a) / ld HL,(b) / cp WA,HL / ret ge / ld HL,WA; _strncmp: ld L,0x0 / ... )
            pre_then = simple(a) < simple(b)
            pre, other = (a, b) if pre_then else (b, a)
            if family_of(mem_operand(F, strip(narrow(pre, size))) or '') and family_of(mem_operand(F, strip(narrow(other, size))) or ''):
                pre = None                                 # both arms in registers: the plain form (c_tern under -Xr)
        else: pre = None
        def char_valued(x):                                # an int built only from chars and small constants
            x = strip(x)
            if fold(x).k == 'const': return fold(x).value is not None and -128 <= fold(x).value <= 127
            if x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == 1: return True
            if x.k == 'bin' and x.op in ('+', '-', '&', '|', '^'): return char_valued(x.l) and char_valued(x.r)
            return False
        narrow_ok = pre is not None and size == 2 and char_valued(a) and char_valued(b) and \
            (strip(a).k == 'bin' or strip(b).k == 'bin')
        if pre is not None:
            lskip, lend = F.newulabel(), F.newulabel()
            lm = mem_operand(F, c.l); rv = strip(c.r)
            tmpv = None
            if pre.k == 'load' and strip(pre.e).k == 'var' and rv.k == 'load' and strip(rv.e).k == 'var' and \
                    strip(rv.e).decl is strip(pre.e).decl and lm is not None and lm.startswith('('):
                cs = strip(c.l).ty.size
                F.emit('ld', '%s,%s' % (FAM['WA'][cs], lm))
                F.emit('ld', '%s,%s' % (R, mem_operand(F, pre)))
                F.emit('cp', '%s,%s' % (FAM['WA'][cs], R))
                cc = (CC_S if strip(c.l).ty.signed else CC_U)[c.op]
                lv = strip(strip(c.l).e)
                if lv.k == 'var': tmpv = (lv.decl, getattr(lv.decl, 'reg', None)); lv.decl.reg = 'WA'
            else:
                gen(F, pre, fam, 1 if narrow_ok else size)
                cc = gen_compare(F, c)
                if cc in (True, False): raise Unsupported('constant ?: condition')
            jcc = INV[cc] if not pre_then else cc
            if narrow_ok:                                  # _strncmp: ... j eq,L5 / ... / ld L,A / L5: exts HL
                F.emit('j', '%s,%s' % (jcc, lend))
                o = strip(narrow(other, 1))
                try:
                    if o.k == 'bin' and fam != 'WA':
                        f2 = gen(F, o, 'WA', 1); F.emit('ld', '%s,%s' % (FAM[fam][1], FAM[f2][1]))
                    else: gen(F, o, fam, 1)
                finally:
                    if tmpv: tmpv[0].reg = tmpv[1]
                F.lines.append(lend + ':'); F.emit('exts' if e.ty.signed else 'extz', FAM[fam][2]); return fam
            F.emit('ret', jcc) if then_ret else F.emit('j', '%s,%s' % (jcc, lend))
            try: gen(F, other, fam, size)
            finally:
                if tmpv: tmpv[0].reg = tmpv[1]
            F.lines.append(lskip + ':'); F.lines.append(lend + ':'); return fam
    if e.k == 'cond':                                # c_tern
        lelse, lend = F.newulabel(), F.newulabel()
        gen_cond_false(F, e.c, lelse)
        if F.opt and strip(e.a).k == 'bin' and fam != 'WA':   # _toupper: ld WA,IZ / sub WA,0x20 / ld HL,WA / j L2
            f2 = gen(F, e.a, 'WA', size); F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[f2][size]))
        else: gen(F, e.a, fam, size)
        F.emit('j', lend); F.lines.append(lelse + ':')
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
    if e.k == 'bin' and e.op in '+-' and len(e.op) == 1 and e.ty.kind == 'int' and fold(e.r).k == 'const' and \
            fold(e.r).value is not None and fold(e.r).value < 0:
        from frontend import N                           # __toupper: c + ('A' - 'a') -> sub HL,0x20
        e = N('bin', op='-' if e.op == '+' else '+', l=e.l, r=N('const', value=-fold(e.r).value, ty=e.ty), ty=e.ty)
    if e.k == 'bin' and e.op in SIMPLE_OPS and strip(e.l).k == 'call' and strip(e.r).k == 'call' and getattr(F, 'call_temp', None):
        T = FAM[F.call_temp][2] if F.call_temp == 'IZ' else 'QIZ'     # k_expr: the right call first, kept in QIZ
        gen_call(F, strip(e.r)); F.emit('ld', '%s,%s' % (T, FAM['HL'][size]))
        gen_call(F, strip(e.l)); flush_pops(F) if F.opt else None
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (FAM['HL'][size], T))
        if fam != 'HL': F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['HL'][size]))
        return fam
    def deref_load(x):
        x = strip(x)
        while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
        return x.k == 'load' and strip(x.e).k == 'deref'
    if F.opt and e.k == 'bin' and e.op in ('+', '&', '|', '^') and deref_load(e.l) and deref_load(e.r):
        from frontend import N                           # op_sum2, op_three: *p++ + *q++ loads q first
        e = N('bin', op=e.op, l=e.r, r=e.l, ty=e.ty)
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
    wide_l = strip(strip(l).e) if strip(l).k == 'cast' else strip(l)
    if op in SIMPLE_OPS and size < wide_l.ty.size and wide_divide(wide_l, size):
        inner = wide_l; w = inner.ty.size                  # _ultoa: cal C9H_remlu / add L,0x30
        f2 = gen(F, inner, fam, w); R1 = FAM[f2][size]
        rc = fold(r); rs = mem_operand(F, r)
        if op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
            F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc.value), R1))
        else: F.emit(SIMPLE_OPS[op], '%s,%s' % (R1, rs))
        return f2
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
    if op == '*' and size == 4 and fold(r).k == 'const' and fold(r).value > 0 and bin(fold(r).value).count('1') <= 3:
        # shifts and adds for a constant with few one bits (mul_l_pk: *10); _rand's *1103515245 and *301 (5 or
        # more one bits) call C9H_mul*; the threshold between 3 and 5 is a guess
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
    if top.k == 'cond': return False                       # _abs: the ?: loads j into HL itself
    needs_wa = size == 1 or (top.k == 'bin' and top.op in ('*', '/', '%', '<<', '>>'))
    if top.k == 'bin' and top.op in ('*', '/', '%') and size == 4: return False
    tmp = 'BC' if needs_wa else 'WA'
    if top.k == 'bin' and top.op in ('&&', '||'):          # _isdigit: ld HL,0x0 before ld WA,(XSP+0x4)
        F.emit('ld', '%s,0x0' % FAM['HL'][2]); F.preset_hl = True
        tmp = 'WA'
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
        if lm is None and strip(l).k in ('addr', 'decay'):
            gen(F, l, 'WA', 4); lm = 'XWA'                     # _ultoa: &buf[33] - p
        if lm is None or rm is None: raise Unsupported('complex pointer difference')
        if lm != 'XWA': F.emit('ld', 'XWA,%s' % lm)
        F.emit('sub', 'XWA,%s' % rm)
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
    rc = fold(r)
    if F.opt and rc.k == 'const' and rc.value is not None and 0 <= rc.value < 0x10000:
        rs_ld = ('lda', 'XBC,%s' % hx(rc.value))        # -O: div_l_pk, _rand: lda XBC,0xa / lda XBC,0x7fff
    else:
        rs_ld = ('ld', 'XBC,%s' % rs)
    if F.xiz_vars and any(d is not None and d.kind == 'local' for d in F.xiz_vars):
        F.emit(*rs_ld); F.emit('ld', 'XWA,%s' % ls)
    else:
        F.emit('ld', 'XWA,%s' % ls); F.emit(*rs_ld)
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
    if e.op in ('==', '!=') and size == 1 and lm is not None and lm.startswith('(X') and rvm is not None and \
            rvm.startswith('(X') and not lm.startswith('(XSP') and not rvm.startswith('(XSP'):
        F.emit('ld', 'A,%s' % rvm); F.emit('cp', 'A,%s' % lm); return cc   # _strncmp: ld A,(XDE) / cp A,(XIX) (guess:
                                                                          # one example)
    if rvm in ('A', 'C', 'E', 'L', 'WA', 'BC', 'DE', 'HL') and lm is not None and lm.startswith('(') and e.op in ('==', '!='):
        rr = FAM[[k for k, v in FAM.items() if rvm in v.values()][0]][size]     # _strchr: cp A,(XHL)
        F.emit('cp', '%s,%s' % (rr, lm)); return cc
    if regvar_of(getattr(l, 'e', l)) and lm in ('BC', 'DE', 'HL', 'IX', 'IY', 'IZ'):   # ra_leaf: cp IX,(XSP+4)
        rs = mem_operand(F, r)
        if rs is None: raise Unsupported('complex compare operand')
        F.emit('cp', '%s,%s' % (lm, rs)); return cc
    if rc.k == 'const' and lm is not None and lm.startswith('(') and size <= 2:
        F.emit('cp' + ('b' if size == 1 else 'w'), '%s,%s' % (lm, hx(rc.value))); return cc
    if l.k == 'call' and rc.k == 'const' and size == 2:   # k_cond, c_break: cal .r1 / cp HL,0x0 (cdecl too)
        gen_call(F, l); flush_pops(F, True); F.emit('cp', 'HL,%s' % hx(rc.value)); return cc   # _toupper: inc 0x2,XSP
    if rc.k == 'const' and rc.value == 0 and size == 4 and op in ('==', '!=') and lm in ('XIZ', 'XBC', 'XDE', 'XHL', 'XWA'):
        if F.opt: flush_pops(F, True)                    # _strlen: cal _memchr / inc 0x8,XSP / or XHL,XHL
        F.emit('or', '%s,%s' % (lm, lm)); return cc     # _calloc: if (ptr) -> or XIZ,XIZ
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
    if c.k == 'bin' and c.op == '&&':                # _isalpha: (c>='a' && c<='z') || ... -> j lt,L1 / j le,L2 / L1:
        lf = F.newulabel(); gen_cond_false(F, c.l, lf); gen_cond_true(F, c.r, target)
        F.lines.append(lf + ':'); return
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
    if c.k == 'bin' and c.op in ('==', '!=') and strip(c.l).k == 'opassign' and fold(c.r).k == 'const' and fold(c.r).value == 0:
        oa = strip(c.l); lvv = strip(oa.l)
        d = lvv.decl if lvv.k == 'var' and getattr(lvv.decl, 'reg', None) == 'XIZ' else None
        if d is not None:              # _ultoa: (val /= radix) == 0 -> ld XIZ,XHL / or XIZ,XIZ
            from frontend import N
            fam = gen(F, N('bin', op=oa.op, l=N('load', e=oa.l, ty=oa.ty), r=oa.r, ty=oa.ty), 'HL', 4)
            F.emit('ld', 'XIZ,%s' % FAM[fam][4]); F.emit('or', 'XIZ,XIZ')
            cc = 'eq' if c.op == '==' else 'ne'
            F.emit('ret', INV[cc]) if target == 'RET' else F.emit('j', '%s,%s' % (INV[cc], target)); return None
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
    if size <= 2 and m is not None and family_of(m):    # a register: push IZ (call.c k_seq under O3XS)
        F.emit('push', m if size == 2 else FAM[family_of(m)[1:]][2]); F.push += 2; return 2
    if size <= 2 and m is not None:
        F.emit('pushw', m); F.push += 2; return 2
    if size == 4 and m is not None and m in ('XIZ', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY'):
        F.emit('push', m); F.push += 4; return 4          # _calloc: push XIZ
    if size == 4 and m is not None and m.startswith('('):
        F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    if size == 4 and m is not None:
        F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    fam = gen(F, a, 'WA', size)
    F.emit('push', FAM[fam][size]); F.push += size; return size

def flush_pops(F, before_test=False):
    """release the stack arguments of earlier calls; more than 8 bytes is lda XSP,XSP+n, or add XSP,n when a test
    of the call's result follows (_strcpy: add XSP,0xc / or XHL,XHL; _strstr: add XSP,0xa)"""
    n = F.pending
    if n:
        if n <= 8: F.emit('inc', '%s,XSP' % hx(n))
        elif before_test: F.emit('add', 'XSP,%s' % hx(n))
        else: F.emit('lda', 'XSP,XSP+%s' % hx(n))
        F.push -= n; F.pending = 0

def gen_call(F, e, fam=None, size=0):
    fn = strip(e.fn)
    if fn.k != 'var': raise Unsupported('indirect call')
    n = 0
    args = e.args
    if getattr(fn.decl, 'implicit', False):            # _ultoa: memcpy undeclared -> the long difference is pushed whole
        args = [strip(a.e) if strip(a).k == 'cast' and strip(a).kind == 'IntegralCast' and strip(a.e).ty.size > strip(a).ty.size
                else a for a in args]
    if F.adecl and not getattr(fn.decl.ty, 'cdecl', False):
        return gen_call_adecl(F, fn, args, fam, size)
    for a in reversed(args): n += push_arg(F, a)
    F.emit('cal', '_' + fn.decl.name)                  # cdecl, also from an adecl file (adecl.c: c_lib)
    F.pending += n
    if fam and fam != 'HL': F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['HL'][size]))
    return fam

def gen_call_adecl(F, fn, args, fam, size):
    """a call to an adecl function (abi.md; adecl.c c_t1..c_t5, call.c under -Xr).  The first three arguments go to
    WA / BC / DE (by size: A, WA, XWA ...), the rest are pushed left to right and the callee pops them (retd).
    Order (call.c k4: ld BC,WA / ld A,(_gc) / exts WA / pushw 0x3 / ld XDE,(_gl); adecl.c c_t2: ld BC,(_gi) /
    ld WA,0x1; c_t5: ld XWA,0x4 / push XWA / pushw 0x5 / ld XWA,(_gl) / ld XBC,0x2 / ld XDE,0x3):
    register variables moved into place first, then computed arguments (a char is loaded and extended to a word),
    then the stack arguments, then plain memory operands, then constants; each group left to right."""
    regs = ['WA', 'BC', 'DE']; inreg = []; stack = []
    for i, a in enumerate(args):
        if i < 3 and strip(a).ty.kind != 'struct' and strip(a).ty.size <= 4: inreg.append((regs[i], a))
        else: stack.append(a)
    def kind(a):
        a0 = strip(a)
        if a0.ty.size == 1: return 'computed'
        if fold(a0).k == 'const': return 'const'
        if a0.k != 'load': return 'computed'
        m = mem_operand(F, a0)
        if m is None: return 'computed'
        return 'reg' if family_of(m) else 'mem'
    groups = {'reg': [], 'computed': [], 'mem': [], 'const': []}
    for t, a in inreg: groups[kind(a)].append((t, a))
    for t, a in groups['reg']:
        sz = strip(a).ty.size; m = mem_operand(F, strip(a))
        if m != FAM[t][sz]: F.emit('ld', '%s,%s' % (FAM[t][sz], m))
    for t, a in groups['computed']:
        a0 = strip(a)
        if a0.ty.size == 1:
            m = mem_operand(F, a0)
            if m is not None and m != FAM[t][1]: F.emit('ld', '%s,%s' % (FAM[t][1], m))
            elif m is None: gen(F, a0, t, 1)
            F.emit('exts' if a0.ty.signed else 'extz', FAM[t][2])
        else:
            gen(F, a0, t, a0.ty.size)
    n = 0
    for a in stack: n += push_arg(F, a)
    for t, a in groups['mem'] + groups['const']:
        sz = strip(a).ty.size; F.emit('ld', '%s,%s' % (FAM[t][sz], mem_operand(F, strip(a)) if fold(strip(a)).k != 'const'
                                                     else hx(fold(strip(a)).value)))
    F.emit('cal', '.' + fn.decl.name + ('\t;stack' if n else ''))      # the callee pops: no tail jump (c_t4)
    F.push -= n
    if fam and fam != 'HL': F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['HL'][size]))
    return fam

def global_name(e):
    v = strip(e)
    if v.k == 'var' and v.decl.kind == 'global': return '_' + v.decl.name
    return None

def gen_incdec(F, e, fam, size, value):
    """++/-- on a global: incb/incw in memory, long through XWA (unop_*: preinc, postinc_val); *p++ (deref_inc)"""
    g = global_name(e.e)
    if g is None and strip(e.e).k == 'var' and hasattr(strip(e.e).decl, 'slot'):
        g = 'XSP+%s' % hx(strip(e.e).decl.slot + F.push)     # _ultoa: p-- -> ld XWA,0x1 / sub (XSP+4),XWA
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
            if esz == 1 and im in ('WA', 'BC', 'DE', 'HL'):       # globals.c gl_index: lda XBC,_ext_arr / ld L,(XBC+WA)
                base = 'XBC' if im == 'WA' else 'XWA'
                F.emit('lda', '%s,_%s' % (base, b.decl.name)); F.emit('ld', '%s,(%s+%s)' % (R, base, im)); return fam
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
    if lv.k == 'index' and local_array_of(lv.base) is not None and fold(lv.idx).k == 'const' and \
            local_array_of(lv.base) in getattr(F, 'array_temps', {}):
        array_base(F, local_array_of(lv.base))          # _ultoa: buf[32] = 0 -> (XWA+0x20)
        off = fold(lv.idx).value * lv.ty.size
        return '(XWA+%s)' % hx(off) if off else '(XWA)'
    if lv.k == 'deref' and strip(lv.e).k == 'load' and strip(strip(lv.e).e).k == 'var' and \
            hasattr(strip(strip(lv.e).e).decl, 'slot') and getattr(F, 'naive_loads', False):
        F.emit('ld', 'XWA,(XSP+%s)' % hx(strip(strip(lv.e).e).decl.slot + F.push)); return '(XWA)'
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
        pe = strip(lv.e)
        while pe.k == 'cast': pe = strip(pe.e)
        if m is None and pe.k == 'bin' and pe.op == '+' and fold(pe.r).k == 'const':
            bv = strip(pe.l)
            while bv.k == 'cast': bv = strip(bv.e)
            bm = mem_operand(F, bv) if bv.k == 'load' else None
            if bm is not None and bm.startswith('X') and not 0 <= fold(pe.r).value <= 0x7fff or bm == 'XIZ':
                F.emit('ld', 'XWA,%s' % bm)                # _strcpy: *((char *)s1 + 0xffff) = 0 ->
                F.emit('add', 'XWA,%s' % hx(fold(pe.r).value))   # ld XWA,XIZ / add XWA,0xffff / ldb (XWA),0x0
                return '(XWA)'
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
    if op in SIMPLE_OPS and fold(r).k == 'const' and size <= 2 and getattr(F, 'naive_loads', False):
        t = lvalue(F, e.l)                                # _ultoa: *p += 39 -> addb (XWA),0x27
        F.emit(SIMPLE_OPS[op] + ('b' if size == 1 else 'w'), '%s,%s' % (t, hx(fold(r).value))); return t
    if op in SIMPLE_OPS:
        t = lvalue(F, e.l)
        rv = mem_operand(F, r)
        if rv in ('A', 'C', 'E', 'WA', 'BC', 'DE', 'HL', 'XWA', 'XBC', 'XDE'):
            F.emit(SIMPLE_OPS[op], '%s,%s' % (t, rv)); return t        # .as_add_ptr: add (XWA),BC
        gen(F, r, 'WA', size)
        F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM['WA'][size])); return t
    if op in ('<<', '>>'):
        mnem = ('sla' if signed else 'sll') if op == '<<' else ('sra' if signed else 'srl')
        cnt = mem_operand(F, r) if fold(r).k != 'const' else None
        lv = strip(e.l); ia = strip(lv.idx) if lv.k == 'index' else None
        if F.adecl and size == 2 and cnt in ('BC', 'DE'):
            # the count needs WA, so a variable in WA moves out (assign.c under Xr and O3XSXr):
            # .as_shl_ptr: ld DE,BC / ld XBC,XWA / ld HL,(XBC) / ld WA,DE / ... / ld (XBC),HL
            # .as_shl_arr: ld HL,WA / add HL,HL / lda XIX,_ga / ld DE,(XIX+HL) / ld WA,BC / ... / ld (XIX+HL),DE
            t = None
            if lv.k == 'deref' and mem_operand(F, lv.e) == 'XWA':
                if cnt == 'BC': F.emit('ld', 'DE,BC'); cnt = 'DE'
                F.emit('ld', 'XBC,XWA'); t = '(XBC)'; taken = {'BC', cnt}
            elif lv.k == 'index' and strip(lv.base).k == 'var' and strip(lv.base).decl.kind == 'global' and \
                    strip(lv.base).decl.ty.kind == 'array' and mem_operand(F, lv.idx) == 'WA':
                F.emit('ld', 'HL,WA'); F.emit('add', 'HL,HL'); F.emit('lda', 'XIX,_%s' % strip(lv.base).decl.name)
                t = '(XIX+HL)'; taken = {'HL', cnt}
            if t is not None:
                V = [x for x in ('HL', 'DE', 'BC') if x not in taken][0]
                F.emit('ld', '%s,%s' % (V, t)); F.emit('ld', 'WA,%s' % cnt)
                F.emit('and', 'A,0xf'); lab = F.newlabel(); F.emit('j', 'z,%s' % lab); F.emit(mnem, 'A,%s' % V)
                F.lines.append(lab + ':'); F.emit('ld', '%s,%s' % (t, V)); return t
        t = lvalue(F, e.l, ptr='XDE', idx='DE', base='XHL')
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
            if rs == 'XWA' and not F.opt:                  # .as_mul_gl under Xr: ld XBC,XWA / ld XWA,(_gl)
                F.emit('ld', 'XBC,XWA'); F.emit('ld', 'XWA,%s' % t); F.emit('cal', 'C9H_' + name)
                F.emit('ld', '%s,XHL' % t); return t
            if rs == 'XWA':                                # .as_mul_gl under O3XSXr: push XIZ / ld XIZ,XWA
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
        if res.startswith('Q'):                            # .as_mod_gi: ld WA,QBC into the dead operand's register
            dst = 'WA' if work == 'WA' or (rs == 'WA' and dies_here(F, narrow(r, size))) else FAM[work][2]
            F.emit('ld', '%s,%s' % (dst, res)); res = dst
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

def array_base(F, d):
    """XWA = &array, through its compiler temporary (naive load; knowledge_pass thins it per personality)"""
    t = F.array_temps[d]
    if not getattr(t, 'set', False):
        F.emit('lda', 'XWA,XSP+%s' % hx(d.slot + F.push)); F.emit('ld', '(XSP+%s),XWA' % hx(t.slot + F.push)); t.set = True
    F.emit('ld', 'XWA,(XSP+%s)' % hx(t.slot + F.push))

def cast_temp(F, e):
    """the per-iteration temporary of a widened parameter (_ultoa: ld WA,(radix) / exts XWA / ld (XSP+0xc),XWA)"""
    for d, t in getattr(F, 'cast_temps', {}).items():
        if id(e) in t['nodes']:
            if not t['done']:
                F.emit('ld', 'WA,(XSP+%s)' % hx(d.off + F.push)); F.emit('exts' if d.ty.signed else 'extz', 'XWA')
                F.emit('ld', '(XSP+%s),XWA' % hx(t['decl'].slot + F.push)); t['done'] = True
            return '(XSP+%s)' % hx(t['decl'].slot + F.push)
    return None

def local_array_of(e):
    e = strip(e)
    if e.k == 'var' and e.decl.kind == 'local' and e.decl.ty.kind == 'array': return e.decl
    return None

def setup_struct_temps(F, c):
    """_ldiv: lda XWA,XSP+slot / ld (tB),XWA / [V4.23: ld XWA,(tB)] / ld (tA),XWA, before the first member store"""
    for d, t in getattr(F, 'struct_temps', {}).items():
        if t['done']: continue
        hit = []
        walk(c, lambda n, dep: hit.append(n) if id(n) in t['stores'] else None)
        if not hit: continue
        F.emit('lda', 'XWA,XSP+%s' % hx(d.slot + F.push))
        F.emit('ld', '(XSP+%s),XWA' % hx(t['tB'].slot + F.push))
        F.emit('ld', 'XWA,(XSP+%s)' % hx(t['tB'].slot + F.push))   # removed for kn5000 by store_knowledge()
        F.emit('ld', '(XSP+%s),XWA' % hx(t['tA'].slot + F.push))
        t['done'] = True; t['n'] = 0

def flat(s):
    if s.k == 'block':
        out = []
        for c in s.body: out += flat(c)
        return out
    return [s]

def gen_stmt(F, s, last):
    if s.k in ('if', 'for', 'while', 'do', 'switch') and getattr(F, 'lazy_homes', None):
        for d in [d for d in F.f.params if d in F.lazy_homes and uses_decl(s, d)]:
            touch_home(F, d)                               # c_while: ld IZ,(XSP+0x6) before the loop
    if s.k == 'block':
        body = flat(s)
        i = 0
        while i < len(body):
            c = body[i]
            if getattr(F, 'deferred', None):
                j = i
                while j < len(body) and body[j].k not in ('for', 'while', 'do'): j += 1
                stretch = body[i:j + 1]
                def eval_walk(n, acc):                     # evaluation order: *s1 == *s2 reads s2 first (_strncmp)
                    if isinstance(n, list):
                        for x in n: eval_walk(x, acc)
                        return
                    if not hasattr(n, 'k'): return
                    if n.k == 'var': acc.append(n.decl)
                    kids = [v for v in n.__dict__.values() if hasattr(v, 'k') or isinstance(v, list)]
                    def dl(x):
                        x = strip(x)
                        while x.k == 'cast': x = strip(x.e)
                        return x.k == 'load' and strip(x.e).k == 'deref'
                    if n.k == 'bin' and n.op in ('==', '!=') and dl(n.l) and dl(n.r):
                        kids = [n.r, n.l]
                    for v in kids: eval_walk(v, acc)
                def first_use(d):
                    order = []
                    eval_walk(stretch, order)
                    return order.index(d) if d in order else 1 << 30
                need = [d for d in F.deferred if any(uses_decl(x, d) for x in stretch)
                        and (d.reg != 'XIZ' or (c.k in ('expr', 'return', 'decl', 'while', 'for', 'do') and uses_decl(c, d)))]
                own = sorted([d for d in need if uses_decl(c, d)], key=first_use)
                # run 2026-11-09-5-micro-optparams: loaded at the start of the function, reverse declaration order
                # (op_cpy_ab, op_cmp_ab, op_three ...: whatever the uses); later, before a second loop, declaration
                # order (op_cat, op_cat2, op_cat_b; _strncat)
                at_start = not any(l.startswith('\t') and not l.startswith(('\tpush', '\tdec\t', '\tlda\tXSP')) for l in F.lines[1:])
                pidx = {d: k for k, d in enumerate(F.f.params)}
                order_key = lambda d: (d.reg == 'WA', -pidx[d] if at_start else pidx[d])   # WA last (_strchr: s, c)
                if any(d.kind != 'param' for d in need): rest = sorted([d for d in need if d not in own], key=first_use)
                else:
                    rest = sorted([d for d in need if d not in own], key=order_key)
                    if c.k in ('for', 'while', 'do'): own = sorted(own, key=order_key)   # the loop needs them all
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
                if c.init is not None: fam = gen(F, c.init, 'HL', 4); F.emit('ld', 'XIZ,%s' % FAM[fam][4])
                i += 1; continue
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
                    and (c.e.op in ('*', '/') or F.opt and c.e.op in tuple(SIMPLE_OPS) + ('%', '<<', '>>')):
                # without -O only * and / fold into the return; + - & | ^ % << >> work on the variable's register,
                # then the return moves it (.as_add_loc, .as_mod_loc, .as_shl_loc under Xr)
                from frontend import N                           # .as_add_loc: ld HL,WA / add HL,BC
                d = regvar_of(c.e.l)
                if c.e.op == '%' and d.ty.size == 2 and d.reg in ('WA', 'BC', 'DE') and 'HL' not in live_regs(F):
                    F.emit('ld', 'HL,%s' % FAM[d.reg][2]); d.reg = 'HL'   # .as_mod_loc under O3XSXr: the variable
                    gen_stmt(F, c, False); i += 1; continue               # moves to HL, then exts XHL / divs XHL,BC
                ld = N('load', e=N('var', decl=d, ty=d.ty), ty=d.ty)
                nxt.value = N('bin', op=c.e.op, l=ld, r=c.e.r, ty=d.ty)
                F.last_use[d] = id(ld) if c.e.op in ('*', '/') else None   # .as_mul_loc: muls XWA,BC in place;
                # .as_mod_loc under O3XSXr is not: ld HL,WA / exts XHL / divs XHL,BC / ld HL,QHL
                i += 1; continue
            if F.opt and c.k == 'if' and c.els is not None and nxt is not None and nxt.k == 'return' and \
                    nxt.value is not None and strip(nxt.value).k == 'load' and strip(strip(nxt.value).e).k == 'var':
                rv = strip(strip(nxt.value).e).decl
                th, el = flat(c.then), flat(c.els)
                def asg(st):
                    return len(st) == 1 and st[0].k == 'expr' and st[0].e.k == 'bin' and st[0].e.op == '=' and \
                        strip(st[0].e.l).k == 'var' and strip(st[0].e.l).decl is rv
                if asg(th) and asg(el) and rv.kind == 'local':
                    from frontend import N                     # c_ifelse under O3XS: as return c ? a : b (c_tern)
                    gen_stmt(F, N('return', value=N('cond', c=c.cond, a=th[0].e.r, b=el[0].e.r, ty=rv.ty)), last)
                    i += 2; continue
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
        flush_pops(F)                                      # _ultoa: lda XSP,XSP+0xc before L50000
        F.lines.append(F.shared_exit['label'] + ':')
    if s.k == 'return' and s.value is not None and F.sret is not None:
        v = strip(s.value)
        if v.k == 'load' and strip(v.e).k == 'var' and hasattr(strip(v.e).decl, 'slot'):
            d = strip(v.e).decl                        # _ldiv: ld XIX,(sret) / lda XIY,XSP+slot / ld BC,n / ldirw
            F.emit('ld', 'XIX,(XSP+%s)' % hx(F.sret.off + F.push)); F.emit('lda', 'XIY,XSP+%s' % hx(d.slot + F.push))
            F.emit('ld', 'BC,%s' % hx(d.ty.size // 2)); F.emit('ldirw', '(XIX+),(XIY+)')
            if F.xiz_vars: F.emit('pop', F.save_reg)
            epilogue(F); F.emit('ret'); return
        raise Unsupported('struct return')
    if s.k == 'expr' and s.e.k == 'call' and strip(s.e.fn).k == 'var' and strip(s.e.fn).decl.name == '__cc900_asm':
        import listing, ast as _ast                        # __ASM("..."): the text as it is (_MEMSET.C)
        lit = strip(s.e.args[0])
        while lit.k in ('cast', 'decay', 'noop'): lit = strip(lit.e)
        l = listing.clean(_ast.literal_eval(lit.value))
        if l: F.lines.append(l)
        return
    if s.k == 'return' and s.value is not None:
        v = strip(s.value)
        while v.k == 'cast': v = strip(v.e)
        if v.k == 'load' and strip(v.e).k == 'var' and strip(v.e).decl.name.lstrip('_') in PSEUDO and \
                strip(v.e).decl.name.startswith('__'):
            flush_pops(F); epilogue(F); F.emit('ret'); return    # return (void *)__XHL: the value is already there
    if s.k == 'return' and s.value is not None and F.f.ret.size == 2 and char_arith(s.value) and \
            (F.opt or strip(strip(s.value).l).k == 'cast' and strip(strip(strip(s.value).l).e).k == 'call') and \
            not (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)):
        fam = gen(F, narrow(s.value, 1), 'HL', 1)          # op_two: return *a - *b -> ld L,(XDE) / sub L,(XBC) / exts HL
        if fam != 'HL': F.emit('ld', 'L,%s' % FAM[fam][1])
        F.emit('exts' if F.f.ret.signed else 'extz', 'HL'); flush_pops(F)
        F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret'); return
    if s.k == 'return':
        epi = F.opt and (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)) and not getattr(F, 'shared_exit', None)
        if s.value is not None:
            size = F.f.ret.size
            fam = gen(F, s.value, 'HL', size, then_ret=True)
            if fam != 'HL' and FAM[fam].get(size) != FAM['HL'][size]:
                F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam].get(size, FAM[fam].get(2))))
        if epi and not last:                               # -XS: _calloc: ld XHL,0x0 / j L3 ... L3: pop XIZ / ret
            flush_pops(F)
            if not getattr(F, 'exit_label', None): F.exit_label = F.newlabel()
            F.emit('j', F.exit_label); return
        if epi and getattr(F, 'exit_label', None): F.lines.append(F.exit_label + ':')
        flush_pops(F)
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F)
        F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret'); return
    if s.k == 'if' and s.els is None and F.loops and flat(s.then) and flat(s.then)[0].k == 'break' and len(flat(s.then)) == 1:
        c = strip(s.cond)                                  # _ultoa: if ((val /= radix) == 0) break;
        if c.k == 'bin' and c.op in ('==', '!=') and strip(c.l).k == 'opassign':
            from frontend import N
            inv = N('bin', op='!=' if c.op == '==' else '==', l=c.l, r=c.r, ty=c.ty)
            gen_cond_false(F, inv, F.loops[-1][0]); F.newulabel(); return
        lab = F.newulabel(); gen_cond_true(F, c, F.loops[-1][0]); return
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
        if (c.k == 'un' and c.op == '!') or c.ty.kind in ('int', 'ptr'):
            from frontend import N                         # _strncat: if (!*s1) return (s); -> cpb (XIX),0x0 / ret eq
            x = strip(c.e) if c.k == 'un' else c           # (no label after it: the loop body goes on)
            cc = gen_compare(F, N('bin', op='==' if c.k == 'un' else '!=', l=x, r=N('const', value=0, ty=x.ty), ty=c.ty))
            if cc not in (True, False):
                F.emit('ret', cc); return
        raise Unsupported('conditional return')
    if s.k == 'if':
        if s.els is None:
            lab = F.newulabel()
            folded = False
            k = gen_cond_false(F, s.cond, 'RET' if last else lab)
            if F.lines[-1] == '\tret' and last:
                return                               # condition always false: the statement disappears
            gen_stmt(F, s.then, False)
            flush_pops(F)                                # _calloc: inc 0x8,XSP before the join label
            if k is not True: F.lines.append(lab + ':')   # always true: no label (cmp_ui: ge_ui_br0)
            return
        lelse, lend = F.newulabel(), F.newulabel()
        before_trivial_ret = getattr(F, 'trivial_ret_next', False)   # c_ifelse: r = a; else r = b; return r -> j L2
        gen_cond_false(F, s.cond, lelse)
        gen_stmt(F, s.then, last)
        if last and not before_trivial_ret and not F.xiz_vars and not F.pushes and not F.lines[-1].startswith(('\tret', '\tj\t')):
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
    if s.k == 'switch':
        gen_switch(F, s, last); return
    if s.k in ('case', 'default'):                         # a case label inside a switch body (gen_switch)
        if F.case_labels[id(s)] and id(s) not in F.case_inner: F.lines.append(F.case_labels[id(s)] + ':')
        if s.body is not None: gen_stmt(F, s.body, False)
        return
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
        if has_helper_call(s.e.r) and strip(lv).k == 'deref':
            fam = gen(F, s.e.r, 'HL', size)              # _ultoa: value first (XHL / L), then the address
            t = lvalue(F, lv, ptr='XWA')
            F.emit('ld', '%s,%s' % (t, FAM[fam][size])); return
        sv = store_through_temp(s.e) if F.opt else None
        if sv is not None and not getattr(sv, 'reg', None) and regvar_of(strip(strip(lv.e).e)) is not None:
            pd = regvar_of(strip(strip(lv.e).e))         # _strset: lda XBC,XDE+:1 / ld WA,(XSP+0x8) / ld (XBC),A
            F.emit('lda', 'XBC,%s+:%d' % (FAM[pd.reg][4], pd.ty.base.size))
            F.emit('ld', '%s,%s' % (FAM['WA'][sv.ty.size], mem_operand(F, N_load(sv))))
            F.emit('ld', '(XBC),%s' % FAM['WA'][size]); return
        t = lvalue(F, lv)                            # m_ga_set, m_gps_set
        rv = regvar_of(strip(s.e.r).e) if strip(s.e.r).k == 'load' else None
        if rv is not None and rv.ty.size == size:
            F.emit('ld', '%s,%s' % (t, FAM[rv.reg][size])); return
        fam = gen(F, s.e.r, 'WA', size)
        F.emit('ld', '%s,%s' % (t, FAM[fam][size])); return
    raise Unsupported('statement ' + s.k)

def char_arith(x):
    """an int expression of +, -, &, |, ^ over chars only (both operands promoted from char)"""
    x = strip(x)
    if x.k != 'bin' or x.op not in ('+', '-', '&', '|', '^'): return False
    def ch(y):
        y = strip(y)
        if y.k == 'cast' and y.kind == 'IntegralCast' and strip(y.e).ty.size == 1: return True
        return y.k == 'bin' and char_arith(y)
    def small(y): return fold(y).k == 'const' and fold(y).value is not None and -128 <= fold(y).value <= 127
    return (ch(x.l) and ch(x.r)) or (ch(x.l) and small(x.r) and x.op in ('+', '-'))   # call.c k_rc: rc() + 1

def N_load(d):
    from frontend import N
    return N('load', e=N('var', decl=d, ty=d.ty), ty=d.ty)

def store_through_temp(n):
    """*p++ = v with v a parameter read from memory: -O computes the address first into a temporary (_strset:
    lda XBC,XDE+:1 / ld WA,(XSP+0x8) / ld (XBC),A); returns the parameter, or None"""
    lv = strip(n.l)
    if lv.k != 'deref' or strip(lv.e).k != 'incdec' or not strip(lv.e).post: return None
    v = strip(n.r)
    if v.k != 'cast': return None                          # op_fill: a char parameter is stored directly
    while v.k == 'cast': v = strip(v.e)
    if v.k == 'load' and strip(v.e).k == 'var' and strip(v.e).decl.kind == 'param' and strip(v.e).decl.ty.size > 1:
        return strip(v.e).decl
    return None

def has_helper_call(e):
    if not hasattr(e, 'k'): return False
    if e.k == 'bin' and e.op in '*/%' and e.ty.size == 4 and fold(e.r).k != 'const': return True
    if e.k == 'call': return True
    return any(has_helper_call(v) for v in e.__dict__.values() if hasattr(v, 'k'))

def plan_registers(F):
    body = flat(F.f.body)
    helper_uses = {}
    def hv(n, d):
        if n.k == 'opassign' and n.op in '*/%' and strip(n.l).ty.size == 4 and fold(n.r).k != 'const' and \
                strip(n.l).k == 'var' and strip(n.l).decl.kind == 'param':        # _ultoa: val /= radix
            helper_uses[strip(n.l).decl] = helper_uses.get(strip(n.l).decl, 0) + 1
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

def eval_sequence(node, out):
    """('use', decl) / ('def', decl) / ('call',) / ('loop', [...]) in evaluation order, operands before operators"""
    if isinstance(node, list):
        for x in node: eval_sequence(x, out)
        return out
    if not hasattr(node, 'k'): return out
    if node.k in ('for', 'while', 'do'):
        if node.k == 'for' and getattr(node, 'init', None) is not None: eval_sequence(node.init, out)   # c_fordown
        inner = []
        for key, v in node.__dict__.items():
            if key != 'init' and (hasattr(v, 'k') or isinstance(v, list)): eval_sequence(v, inner)
        out.append(('loop', inner)); out.extend(inner); return out
    if node.k == 'return':                                 # a call in a return clobbers nothing that is used later
        inner = eval_sequence(getattr(node, 'value', None), []) if getattr(node, 'value', None) is not None else []
        rid = id(node)                                     # but within the return itself it does (k_expr)
        out.extend(('rcall', rid) if x == ('call',) else (x + (rid,) if x[0] == 'use' else x) for x in inner)
        return out
    if node.k == 'switch':                                 # case bodies are alternatives (switch.c sw_local, sw_ev)
        eval_sequence(node.value, out)
        items = node.body.body if node.body.k == 'block' else [node.body]
        side = 0
        for it in items:
            if it.k in ('case', 'default'): side += 1
            out.extend(('branch', id(node), side, x) for x in eval_sequence(it, []))
        return out
    if node.k == 'if':                                     # c_ifchain: the else branch is not after the then's call
        eval_sequence(node.cond, out)
        a = eval_sequence(node.then, []); b = eval_sequence(getattr(node, 'els', None), []) if getattr(node, 'els', None) else []
        out.extend(('branch', id(node), 'then', x) for x in a); out.extend(('branch', id(node), 'else', x) for x in b)
        return out
    if node.k == 'decl' and getattr(node, 'init', None) is not None:
        eval_sequence(node.init, out); out.append(('def', node.var)); return out
    if node.k == 'bin' and node.op == '=' and strip(node.l).k == 'var':
        eval_sequence(node.r, out); out.append(('def', strip(node.l).decl)); return out
    for v in node.__dict__.values():
        if hasattr(v, 'k') or isinstance(v, list): eval_sequence(v, out)
    if node.k == 'load' and strip(node.e).k == 'var': out.append(('use', strip(node.e).decl))
    if node.k == 'incdec' and strip(node.e).k == 'var': out.append(('use', strip(node.e).decl))   # c_while: n--
    if node.k == 'opassign' and strip(node.l).k == 'var': out.append(('use', strip(node.l).decl))
    if node.k == 'call' or (node.k == 'bin' and node.op in '*/%' and node.ty.size == 4 and fold(node.r).k != 'const'):
        out.append(('call',))
    return out

def plan_homes(F):
    """adecl: where register parameters and register locals live when a call would clobber them (call.c, adecl.c,
    binop_l.c under -Xr and -O3 -XS -Xr).  A parameter used after a call (or in a loop that calls) goes to IZ / XIZ
    by size, the next ones to stack slots stored at entry (d_keep: dec 0x2,XSP / push IZ / ld (XSP+0x2),BC /
    ld IZ,WA); then an int local defined before a call and used after it goes to IZ, else QIZ (k_keep: ld QIZ,HL).
    With -O every parameter that is an operand of a long helper is homed too (mul_l_pp: push XIZ /
    ld (XSP+0x4),XBC / ld XIZ,XWA); the long locals plan_registers put in XIZ come first (mul_l_loc under -Xr)."""
    # cdecl -O: call.c k_seq: push IZ / ld IZ,(XSP+0x6); without -O as well, but a parameter (already in memory)
    # only when it is read three or more times (k_seq), while k_keep's a (twice) stays on the stack
    raw = eval_sequence(F.f.body, [])
    def unwrap(x, path=()):                                # ('branch', if, side, item) -> (item, path)
        while x[0] == 'branch': path = path + ((x[1], x[2]),); x = x[3]
        return x, dict(path)
    def lift(lst):
        out = []
        for x in lst:
            it, path = unwrap(x)
            if it[0] == 'loop': it = ('loop', [unwrap(y)[0] for y in it[1]])
            out.append((it, path))
        return out
    seq0 = lift(raw); seq = [it for it, _ in seq0]
    if not any(x[0] in ('call', 'rcall') for x in seq): return
    def compatible(p, q): return all(q.get(k, v) == v for k, v in p.items())
    across = []
    def mark(d):
        if d not in across: across.append(d)
    for i, (x, px) in enumerate(seq0):
        if x[0] in ('call', 'rcall'):
            before = {y[1] for y, py in seq0[:i] if y[0] in ('use', 'def')}
            for y, py in seq0[i + 1:]:
                if x[0] == 'rcall' and (y[0] != 'use' or len(y) < 3 or y[2] != x[1]): continue
                if y[0] == 'use' and compatible(px, py) and (y[1].kind == 'param' or y[1] in before): mark(y[1])
        if x[0] == 'loop' and any(y[0] == 'call' for y in x[1]):
            for y in x[1]:
                if y[0] == 'use': mark(y[1])
    helper_ops = []
    if F.opt:
        def hv(n, dep):
            if n.k == 'bin' and n.op in '*/%' and n.ty.size == 4 and fold(n.r).k != 'const' or \
                    n.k == 'bin' and n.op in '/%' and n.ty.size == 4:
                for side in (n.l, n.r):
                    sv = strip(side)
                    if sv.k == 'load' and strip(sv.e).k == 'var' and strip(sv.e).decl.kind == 'param': helper_ops.append(strip(sv.e).decl)
        walk(F.f.body, hv)
    nrefs = {}                                             # references as code: x-- reads and writes (2), and a
    def cnt(n, k=1):                                       # while / for condition appears twice (top and bottom)
        if isinstance(n, list):
            for x in n: cnt(x, k)
            return
        if not hasattr(n, 'k'): return
        if n.k == 'load' and strip(n.e).k == 'var': nrefs[strip(n.e).decl] = nrefs.get(strip(n.e).decl, 0) + k
        if n.k in ('incdec', 'opassign'):
            v = strip(n.e if n.k == 'incdec' else n.l)
            if v.k == 'var': nrefs[v.decl] = nrefs.get(v.decl, 0) + 2 * k
        for key, v in n.__dict__.items():
            if hasattr(v, 'k') or isinstance(v, list):
                cnt(v, 2 * k if n.k in ('while', 'for') and key == 'cond' and not F.opt else k)
    cnt(F.f.body)                                          # (c_while: n homed; c_do's single --n is not)
    if F.adecl:
        params = [d for d in F.f.params if getattr(d, 'reg', None) in ('WA', 'BC', 'DE') and (d in across or d in helper_ops)]
    else:
        params = [d for d in F.f.params if not getattr(d, 'reg', None) and d in across and d.ty.kind in ('int', 'ptr')
                  and d.ty.size in (2, 4) and d is not F.sret and (F.opt or nrefs.get(d, 0) >= 3)]
    locs = [d for d in across if d.kind == 'local' and not getattr(d, 'reg', None) and d.ty.size in (1, 2, 4)
            and d.ty.kind in ('int', 'ptr') and not d.addr_taken]
    weight = {}                  # references, not weighted by loops: c_for i (4) before n (1), c_nested i (5) before j (4)
    for y in seq:
        if y[0] in ('use', 'def'): weight[y[1]] = weight.get(y[1], 0) + 1
    order = sorted(params + locs, key=lambda d: -weight.get(d, 0))     # stable: parameters first on a tie (k_keep)
    used = {'IZ': False, 'QIZ': False}
    for d in F.xiz_vars: used['IZ'] = used['QIZ'] = True
    moves = []; stores = []
    for d in order:                                        # k_keep: a -> IZ, then x -> QIZ
        if d.kind == 'param':
            src = FAM[d.reg][d.ty.size] if getattr(d, 'reg', None) else d    # cdecl: loaded from its slot
            if d.ty.size == 4 and not used['IZ'] and not used['QIZ']:
                moves.append(('XIZ', src)); d.reg = 'XIZ'; d.homed = True; used['IZ'] = used['QIZ'] = True
                F.xiz_vars.append(d)
            elif d.ty.size <= 2 and not used['IZ']:
                moves.append(('IZ', src)); d.reg = 'IZ'; used['IZ'] = True; F.xiz_vars.append(d)
            elif not F.adecl: continue
            else:
                stores.append((d, FAM[d.reg][d.ty.size])); d.home_slot = True; d.reg = None
        elif d.ty.size == 4:                               # _calloc: p = malloc(...) in XIZ, n stays on the stack
            if not used['IZ'] and not used['QIZ']:
                d.reg = 'XIZ'; d.homed = True; used['IZ'] = used['QIZ'] = True; F.xiz_vars.append(d)
        else:
            r = 'IZ' if not used['IZ'] else 'QIZ' if not used['QIZ'] else None
            if r: d.reg = r; used[r] = True; F.xiz_vars.append(d)
            if r == 'IZ' and getattr(F, 'opt', False) is not None: pass
    if F.opt:                                              # _strlen: ss = memchr(...) stays in XHL (no call after it)
        rets = []
        walk(F.f.body, lambda n, dep: rets.append(n) if n.k == 'return' and n.value is not None else None)
        from_call = set()                                  # _strcpy: endPtr = memccpy(...) is only tested: XHL too
        walk(F.f.body, lambda n, dep: from_call.add(strip(n.l).decl) if n.k == 'bin' and n.op == '=' and
             strip(n.l).k == 'var' and strip(n.r).k in ('call', 'cast') and has_helper_call(n.r) else None)
        hl = [d for d in F.f.decls if d.kind == 'local' and not getattr(d, 'reg', None) and d not in across and
              not d.addr_taken and d.ty.kind in ('int', 'ptr') and d.ty.size in (2, 4) and
              (any(uses_decl(r, d) for r in rets) or d in from_call)]
        if len(hl) == 1 and not any(getattr(x, 'reg', None) == 'HL' for x in list(F.f.params) + list(F.f.decls)):
            hl[0].reg = 'HL'
    pairs = []                                             # k_expr: r1(a) + r1(a + 1) keeps the right result in QIZ
    walk(F.f.body, lambda n, dep: pairs.append(n) if n.k == 'bin' and n.op in SIMPLE_OPS and strip(n.l).k == 'call'
         and strip(n.r).k == 'call' else None)
    if pairs:
        r = 'IZ' if not used['IZ'] else 'QIZ' if not used['QIZ'] else None
        if r:
            used[r] = True; F.call_temp = r
            if not F.xiz_vars: F.xiz_vars.append(None)
    if not (moves or stores or locs or pairs): return
    if F.xiz_vars and not any(l == '\tpush\tXIZ' for l in F.lines):
        F.save_reg = 'XIZ' if used['QIZ'] else 'IZ'
        F.emit('push', F.save_reg); F.push = 4 if F.save_reg == 'XIZ' else 2
    F.home_moves = moves; F.home_stores = stores

def emit_homes(F):
    """after the frame is known: slot stores first, then the moves into IZ / XIZ (adecl.c d_keep).  A cdecl
    parameter is loaded at its first use instead (_strlen: pushw 0xffff / pushw 0x0 / ld XIZ,(XSP+0xc) / push XIZ;
    call.c k_seq, where the first use is the first instruction)"""
    for d, r in getattr(F, 'home_stores', []): F.emit('ld', '(XSP+%s),%s' % (hx(d.slot + F.push), r))
    F.lazy_homes = {}
    for dst, src in getattr(F, 'home_moves', []):
        if not isinstance(src, str): F.lazy_homes[src] = dst; continue
        F.emit('ld', '%s,%s' % (dst, src))

def touch_home(F, d):
    """emit the deferred load of a homed cdecl parameter at its first use"""
    lh = getattr(F, 'lazy_homes', None)
    if lh and d in lh:
        dst = lh.pop(d); F.emit('ld', '%s,(XSP+%s)' % (dst, hx(d.off + F.push)))

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
    if e.k == 'bin' and e.op == '=' and strip(e.l).k == 'var' and getattr(strip(e.l).decl, 'reg', None) == 'XIZ' \
            and getattr(strip(e.l).decl, 'homed', False) and strip(e.r).k == 'call':
        gen_call(F, strip(e.r)); flush_pops(F); F.emit('ld', 'XIZ,XHL'); return True   # _calloc: ptr = malloc(...)
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l):
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        rc = fold(narrow(e.r, d.ty.size))
        if rc.k == 'const': F.emit('ld', '%s,%s' % (R, hx(rc.value))); return True
        m = operand(F, e.r, d.ty.size)
        if m is not None: F.emit('ld', '%s,%s' % (R, m)); return True
        if strip(e.r).k == 'call':                     # k_keep: cal .r1 / ld QIZ,HL (cdecl: inc 0x2,XSP first)
            gen_call(F, strip(e.r))
            if R != FAM['HL'][d.ty.size]: flush_pops(F)   # (_strcpy: a local in XHL needs no move, the pops wait)
            F.emit('ld', '%s,%s' % (R, FAM['HL'][d.ty.size])); return True
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
    if e.k == 'opassign' and regvar_of(e.l) and e.op == '%' and regvar_of(e.l).reg in ('WA', 'BC', 'DE', 'HL') \
            and regvar_of(e.l).ty.size == 2 and mem_operand(F, narrow(e.r, 2)):
        d = regvar_of(e.l); signed = d.ty.signed       # .as_mod_loc under Xr: exts XWA / divs XWA,BC / ld WA,QWA
        F.emit('exts' if signed else 'extz', FAM[d.reg][4])
        F.emit('divs' if signed else 'div', '%s,%s' % (FAM[d.reg][4], mem_operand(F, narrow(e.r, 2))))
        F.emit('ld', '%s,%s' % (FAM[d.reg][2], Q[d.reg])); return True
    if e.k == 'opassign' and regvar_of(e.l) and e.op in ('<<', '>>') and regvar_of(e.l).ty.size == 2 \
            and fold(e.r).k != 'const' and mem_operand(F, narrow(e.r, 2)) in ('BC', 'DE'):
        d = regvar_of(e.l); signed = d.ty.signed       # .as_shl_loc under Xr: ld DE,WA / ld WA,BC / and A,0xf / sla A,DE
        mnem = ('sla' if signed else 'sll') if e.op == '<<' else ('sra' if signed else 'srl')
        cnt = mem_operand(F, narrow(e.r, 2))
        if d.reg == 'WA':
            nr = [r for r in ('BC', 'DE', 'HL') if r not in live_regs(F) | {family_of(cnt)[1:]}][0]
            F.emit('ld', '%s,WA' % nr); d.reg = nr
        F.emit('ld', 'WA,%s' % cnt)
        F.emit('and', 'A,0xf'); lab = F.newlabel(); F.emit('j', 'z,%s' % lab); F.emit(mnem, 'A,%s' % d.reg)
        F.lines.append(lab + ':'); return True
    if e.k == 'incdec' and regvar_of(e.e):
        d = regvar_of(e.e); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        step = d.ty.base.size if d.ty.kind == 'ptr' else 1
        F.emit('inc' if e.op == '++' else 'dec', '%s,%s' % (hx(step), R)); return True
    return False

def switch_cases(body, acc):
    """the case and default nodes of a switch body, nested ones (case 2: case 3:) included, in source order"""
    if isinstance(body, list):
        for x in body: switch_cases(x, acc)
        return acc
    if not hasattr(body, 'k') or body.k == 'switch': return acc
    if body.k in ('case', 'default'): acc.append(body)
    for key, v in body.__dict__.items():
        if hasattr(v, 'k') or isinstance(v, list): switch_cases(v, acc)
    return acc

def gen_switch(F, s, last):
    """switch (oracle run 2026-11-09-4-micro-switch, v423, -Xr and -O3 -XS -Xr).
    Five or more case values spanning at most twice their number: a jump table of 16-bit offsets from a base label
    (dw Lcase-Lbase, holes to the default), placed in f_const right after the function label; the selector is
    range-checked (sub lo, then cp R,0 / j lt; without sub cp R,0 / j m; unsigned only cp R,hi / j ugt) and
    dispatched with add R,R / lda XIX,S / ld R,(XIX+R) / lda XIX,Lbase / j XIX+R (long: add XR,XR / add XR,S /
    ld R,(XR)).  Otherwise a compare chain: single values from the highest down (cp R,v / j eq,Lv), runs of three
    or more values with one body as ranges (cp R,hi / j gt / cp R,lo / j ge,Lbody); the last single value is
    tested inverted and falls into its body; a char selector is extended to a word first (exts / extz WA).
    A selector variable that a case body also reads is copied to a free register without -O (sw_local: ld BC,WA)."""
    cases = switch_cases(s.body, [])
    F.case_labels = getattr(F, 'case_labels', {})
    F.case_inner = getattr(F, 'case_inner', set())       # case 2: case 3: share one label (sw_fall, sw_ev)
    for c in cases:                                        # (a side table: a back pointer would make the tree cyclic)
        if id(c) not in F.case_labels: F.case_labels[id(c)] = F.newulabel()
        if c.body is not None and c.body.k in ('case', 'default'):
            F.case_labels[id(c.body)] = F.case_labels[id(c)]; F.case_inner.add(id(c.body))
    end = F.newulabel()
    vals = []; default = None
    for c in cases:
        if c.k == 'default': default = F.case_labels[id(c)]
        else:
            v = data_value(c.value)
            if v is None: raise Unsupported('case value')
            vals.append((v, F.case_labels[id(c)], c))
    deflab = default or end
    e = strip(s.value); ext = None
    if e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size == 1:
        ext = 'exts' if strip(e.e).ty.signed else 'extz'; e = strip(e.e)
    size = max(2, e.ty.size); signed = strip(s.value).ty.signed
    m = mem_operand(F, e)
    sel = strip(e.e).decl if e.k == 'load' and strip(e.e).k == 'var' else None
    in_body = sel is not None and uses_decl(s.body, sel)
    if m is not None and family_of(m) and not ext:
        R = FAM[family_of(m)[1:] if family_of(m) != 'XIZ' else 'IZ'][size]
        keep = in_body or (sel is not None and sel.reg in ('IZ', 'QIZ', 'XIZ'))   # sw_loop: ld WA,IZ
        if keep and not F.opt:
            used = {getattr(d, 'reg', None) for d in list(F.f.params) + list(F.f.decls)
                    if getattr(d, 'reg', None) and (d.kind != 'param' or uses_decl(F.f.body, d))}
            nr = [r for r in ('WA', 'BC', 'DE', 'HL') if r not in used][0]
            F.emit('ld', '%s,%s' % (FAM[nr][size], R)); R = FAM[nr][size]
    else:
        fam = gen(F, e, 'WA', e.ty.size) if not (m and family_of(m) == 'XWA') else 'WA'
        R = FAM['WA'][size]
        if ext: F.emit(ext, 'WA')
    exit_is_ret = last and not F.pushes and not F.xiz_vars and not getattr(F, 'frame', 0) and not F.pending
    def to_default(cc):
        if deflab == end and exit_is_ret:
            F.emit('ret', cc); F.ret_refs = getattr(F, 'ret_refs', set()) | {end}   # still a reference to end
        else: F.emit('j', '%s,%s' % (cc, deflab))
    n = len(vals); lo = min(v for v, _, _ in vals) if vals else 0; hi = max(v for v, _, _ in vals) if vals else 0
    table = n >= 5 and hi - lo + 1 <= 2 * n
    order = list(cases)
    if table:
        base = F.newulabel(); S = 'S%d' % (90000 + len(getattr(F, 'tables', [])))
        bylab = {v: l for v, l, _ in vals}
        F.tables = getattr(F, 'tables', []) + [['\talign\t2', S + ':'] +
                   ['\tdw\t%s-%s' % (bylab.get(v, deflab), base) for v in range(lo, hi + 1)]]
        if lo != 0:
            F.emit('sub', '%s,%s' % (R, hx(lo & ((1 << (8 * size)) - 1)))); F.emit('cp', '%s,0x0' % R); to_default('lt')
        elif signed:
            F.emit('cp', '%s,0x0' % R); to_default('m')
        F.emit('cp', '%s,%s' % (R, hx(hi - lo))); to_default('gt' if signed or lo != 0 else 'ugt')
        if size == 4:
            r16 = FAM[family_of(R)[1:]][2]
            F.emit('add', '%s,%s' % (R, R)); F.emit('add', '%s,%s' % (R, S)); F.emit('ld', '%s,(%s)' % (r16, R))
        else:
            r16 = R
            F.emit('add', '%s,%s' % (R, R)); F.emit('lda', 'XIX,%s' % S); F.emit('ld', '%s,(XIX+%s)' % (R, R))
        F.emit('lda', 'XIX,%s' % base); F.emit('j', 'XIX+%s' % r16)
        F.lines.append(base + ':')
    else:
        groups = []                                        # (lo, hi, label) runs with one body
        for v, l, c in sorted(vals, key=lambda x: x[0]):
            body = c
            while body.body is not None and body.body.k == 'case': body = body.body
            key = id(body)
            if groups and groups[-1][3] == key and groups[-1][1] == v - 1: groups[-1][1] = v
            else: groups.append([v, v, l, key])
        singles = [g for g in groups if g[1] - g[0] < 2]
        singles = [[v, v, F.case_labels[id(c)], None] for g in singles for v in range(g[0], g[1] + 1)
                   for vv, l, c in vals if vv == v]
        ranges = [g for g in groups if g[1] - g[0] >= 2]
        entries = sorted(singles, key=lambda g: -g[0]) + sorted(ranges, key=lambda g: -g[0])
        for i, g in enumerate(entries):
            lastone = i == len(entries) - 1
            if g[0] == g[1]:
                F.emit('cp', '%s,%s' % (R, hx(g[0])))
                if lastone:
                    to_default('ne')
                    first = [c for c in cases if F.case_labels[id(c)] == g[2]]
                    if first and cases and cases[0] is not first[0]: F.emit('j', g[2])
                    elif first: F.case_labels[id(first[0])] = None     # sw_jt4: the body it falls into has no label
                else: F.emit('j', 'eq,%s' % g[2])
            else:
                skip = deflab if lastone else F.newulabel()
                F.emit('cp', '%s,%s' % (R, hx(g[1]))); F.emit('j', 'gt,%s' % skip)
                F.emit('cp', '%s,%s' % (R, hx(g[0]))); F.emit('j', 'ge,%s' % g[2])
                if not lastone: F.lines.append(skip + ':')
                elif default:                                  # sw_ev: the default body follows the range test
                    order = [c for c in cases if c.k == 'default'] + [c for c in cases if c.k != 'default']
        if not entries: to_default('t') if False else F.emit('j', deflab)
    F.loops.append((end, F.loops[-1][1] if F.loops else (lambda: end)))
    items = flat(s.body) if s.body.k == 'block' else [s.body]
    if order is not cases and order[0].k == 'default':     # move the default's statements to the front
        di = [i for i, x in enumerate(items) if x is order[0] or (x.k == 'case' and any(y is order[0] for y in switch_cases(x, [])))][0]
        nj = [i for i in range(di + 1, len(items)) if items[i].k in ('case', 'default')]
        stop = nj[0] if nj else len(items)
        items = items[di:stop] + items[:di] + items[stop:]
    if len(items) >= 2 and items[-1].k == 'break' and any(x.k == 'default' for x in items[-2:-1]) or \
            (len(items) >= 2 and items[-1].k == 'break' and items[-2].k == 'default'):
        items = items[:-1]                                 # sw_jt6d: default: f0(); break; -> cal .f0 / L9: ret
    for it in items: gen_stmt(F, it, False)
    F.loops.pop()
    F.lines.append(end + ':')
    F.switch_table = getattr(F, 'switch_table', False) or table

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
    if c.k == 'incdec' and strip(c.e).k == 'var' and not regvar_of(c.e) and mem_operand(F, N_load(strip(c.e).decl)):
        d = strip(c.e).decl; m = mem_operand(F, N_load(d)); W = FAM['WA'][d.ty.size]
        op = ('dec' if c.op == '--' else 'inc') + ('w' if d.ty.size == 2 else 'b' if d.ty.size == 1 else '')
        if c.post: F.emit('ld', '%s,%s' % (W, m)); F.emit(op, '0x1,%s' % m)
        else: F.emit(op, '0x1,%s' % m); F.emit('ld', '%s,%s' % (W, m))   # c_do: decw 0x1,(XSP+0x4) / ld WA,(XSP+0x4)
        F.emit('cp', '%s,0x0' % W)
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
    if not cl.get('k_in_reg'):
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
        F.loops.append((None, getc)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
        if cont[0]: F.lines.append(cont[0] + ':')
        loop_cond(F, s.cond, body, True)
        return
    if s.k == 'while' and s.cond is not None and fold(s.cond).k == 'const' and fold(s.cond).value:
        body = F.newulabel(); exitl = F.newulabel()        # _ultoa: while (1) { ... break; ... }
        F.lines.append(body + ':')
        for t in getattr(F, 'cast_temps', {}).values():
            if t['loop'] == id(s): t['done'] = False
        F.loops.append((exitl, lambda: body)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
        F.emit('j', body); F.lines.append(exitl + ':'); return
    if s.k == 'while' and F.opt and s.cond is not None:  # -XS rotation: j test / body / test (_strcat)
        test = F.newulabel(); body = F.newulabel()
        F.emit('j', test); F.lines.append(body + ':')
        cont = [None]
        def getc2():
            if cont[0] is None: cont[0] = F.newulabel()
            return cont[0]
        F.loops.append((None, getc2)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
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
    F.loops.append((exitl, getc)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
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
        if F.opt and n.k == 'bin' and n.op == '=' and store_through_temp(n): temps_bc.append(n)   # _strset
    walk(f.body, visit)
    if has_call: return False
    hasloop = []
    walk(f.body, lambda n, d: hasloop.append(1) if n.k in ('for', 'while', 'do') else None)
    if not hasloop:
        uses = {}
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.e).decl, uses.get(strip(n.e).decl, 0) + 1)
             if n.k == 'load' and strip(n.e).k == 'var' else None)
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.l).decl, uses.get(strip(n.l).decl, 0) + 1)
             if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' else None)   # c_ifelse: r = a; else r = b
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
            kd = cl['k']; kp = Pseudo('bound', 2); cl['kp'] = kp
            for p_ in f.params:                            # adecl: register parameters keep their registers
                if getattr(p_, 'reg', None) in seq: reserved.add(p_.reg)
            if getattr(kd, 'reg', None) in seq:            # ra_leaf1 under O3XSXr: the bound stays in WA (cp IX,WA)
                kp.reg = kd.reg; cl['k_in_reg'] = True
            free = [r for r in seq if r not in reserved]
            order = []
            if kd.kind == 'global': order.append(kp)
            if cl['esz'] > 1: cl['off'] = Pseudo('offset', 2); order.append(cl['off'])
            cl['base'] = Pseudo('base', 4); order.append(cl['base'])
            if kd.kind != 'global' and not cl.get('k_in_reg'): order.append(kp)
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
    stored = set()                                         # _strset: c, only ever stored, stays on the stack
    walk(f.body, lambda n, dep: stored.add(store_through_temp(n)) if n.k == 'bin' and n.op == '=' and store_through_temp(n) else None)
    params = [d for d in f.params if d.ty.kind in okind and (d in modified or d in deep or (F.opt and d in loopvars))
              and not (F.opt and d in stored and loopvars.get(d, 0) <= 1)]
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
    hl_busy = set()                                       # _strncmp: the ?: result is set in L while s1 is live
    def hb(n, dep):
        if n.k == 'return' and n.value is not None and strip(n.value).k in ('cond',) or \
                (n.k == 'return' and n.value is not None and strip(n.value).k == 'bin' and strip(n.value).op in ('&&', '||')):
            walk(n.value, lambda m, dd: hl_busy.add(strip(m.e).decl) if m.k == 'load' and strip(m.e).k == 'var' else None)
    walk(f.body, hb)
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
        cand = [r for r in cand if r != 'WA' and not (r == 'HL' and d in hl_busy)]
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
    from frontend import Decl, Type
    F.array_temps = {}; F.cast_temps = {}
    for d in f.decls:                                    # _ultoa: a local array's address in a compiler temporary
        if d.kind == 'local' and d.ty.kind == 'array' and d.uses:
            F.array_temps[d] = Decl('__a_' + d.name, Type('ptr', 4, 2, spell='t'), '', 'local')
    loops = []
    walk(f.body, lambda n, dep: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    for lp in loops:                                     # _ultoa: (unsigned long)radix once per iteration
        casts = {}
        def cv(n, dep):
            if n.k == 'cast' and n.kind == 'IntegralCast' and n.ty.size == 4 and strip(n.e).k == 'load' and \
                    strip(strip(n.e).e).k == 'var' and strip(strip(n.e).e).decl.kind == 'param' and strip(n.e).ty.size == 2:
                key = strip(strip(n.e).e).decl; casts.setdefault(key, []).append(n)
        walk(lp.body, cv)
        for d, ns in casts.items():
            if len(ns) >= 2:
                F.cast_temps[d] = {'decl': Decl('__c_' + d.name, Type('int', 4, 2, spell='t'), '', 'local'),
                                   'nodes': {id(n) for n in ns}, 'loop': id(lp), 'done': False}
    scal = [d for d in f.decls if d.kind == 'local' and not getattr(d, 'reg', None) and not foldable(f, d)
            and d.ty.kind not in ('array', 'struct') and (d.uses or d.name.startswith('__'))]
    temps = list(F.array_temps.values()) + [t['decl'] for t in F.cast_temps.values()]
    aggr = [d for d in f.decls if d.kind == 'local' and d.ty.kind in ('array', 'struct') and not getattr(d, 'reg', None)]
    homed = [d for d in f.params if getattr(d, 'home_slot', False)]          # mul_l_loc under O3XSXr: x, then b
    for d in scal + temps + aggr + homed:
        a = 2 if d.ty.size >= 2 else 1
        pos = (pos + a - 1) // a * a; d.slot = pos; pos += d.ty.size; slots.append(d)
    if F.array_temps or F.cast_temps: F.naive_loads = True
    if not slots: F.frame = 0; return
    size = (pos + 1) // 2 * 2; F.frame = size
    for p in f.params:
        if hasattr(p, 'off'): p.off += size
    F.lines.insert(1, '\tdec\t%s,XSP' % hx(size) if size <= 8 else '\tlda\tXSP,XSP-%s' % hx(size))
    TEMP_SLOTS.clear()
    for t in list(F.array_temps.values()) + [x['decl'] for x in F.cast_temps.values()] + \
             [x for v in getattr(F, 'struct_temps', {}).values() for x in (v['tA'], v['tB'])]:
        TEMP_SLOTS.add('(XSP+%s)' % hx(t.slot + F.push))

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

REG_ALIASES = {'XWA': ('XWA', 'WA', 'A', 'W', 'QWA'), 'XBC': ('XBC', 'BC', 'B', 'C', 'QBC'),
               'XDE': ('XDE', 'DE', 'D', 'E', 'QDE'), 'XHL': ('XHL', 'HL', 'H', 'L', 'QHL'),
               'XIX': ('XIX', 'IX', 'QIX'), 'XIY': ('XIY', 'IY', 'QIY'), 'XIZ': ('XIZ', 'IZ', 'QIZ')}

def family_of(r):
    for k, v in REG_ALIASES.items():
        if r in v: return k
    return None

def knowledge_pass(lines, personality):
    """drop loads ld R,(XSP+d) whose value R is known to hold (rules.md, the reload rule).  Both compilers learn
    'R holds slot M' from a load and keep it until a label, a call, an unconditional jump, a write to R or a write
    to M.  The 2003 / Technics compiler also drops a load that immediately follows a store of the same register to
    the same slot (_ldiv, _ldexp, _ultoa); it does not learn anything else from stores (__doprnt keeps a reload two
    instructions after its store)."""
    out = []; known = {}; prev = None
    for l in lines:
        t = l.strip()
        if t.endswith(':') or t.startswith(('cal', 'call', 'ret', 'djnz')) or (t.startswith('j') and ',' not in t):
            known = {}; out.append(l); prev = None; continue
        if t.startswith('j'):                              # a conditional jump: the fall-through keeps what it knows
            out.append(l); prev = None; continue
        parts = t.split(None, 1); op = parts[0]; args = parts[1].split(',') if len(parts) > 1 else []
        args = [a.strip() for a in args]
        if op == 'ld' and len(args) == 2 and args[0].startswith('(XSP') and family_of(args[1]):
            for k in list(known):
                if known[k][1] == args[0]: del known[k]
            out.append(l); prev = (args[1], args[0]); continue
        if op == 'ld' and len(args) == 2 and family_of(args[0]) and args[1].startswith('(XSP'):
            f = family_of(args[0])
            if f in known and known[f] == (args[0], args[1]): continue
            if personality != 'v4.23' and prev == (args[0], args[1]):
                prev = None; continue                      # the 2003 peephole: store, then reload of it
            known[f] = (args[0], args[1]); out.append(l); prev = None; continue
        if args and family_of(args[0].rstrip(':')):
            known.pop(family_of(args[0]), None)
        elif op in ('pop', 'ldir', 'ldirw', 'ldi', 'ldiw'):
            known = {}
        out.append(l); prev = None
    return out

TEMP_SLOTS = set()                                         # operand strings of compiler-temporary slots (per function)

def store_knowledge(lines):
    """rules.md, the reload rule: the 2003 / Technics compiler also knows R holds M after a store ld (M),R, until a
    label, a call, a write to R, a write to M, or a store through a pointer; a load ld R,(M) it knows is dropped"""
    import re
    out = []; known = {}                                   # family -> (register spelling, memory operand)
    for l in lines:
        t = l.strip()
        if t.endswith(':') or t.startswith(('cal', 'call', 'j', 'ret', 'djnz')):
            known = {}; out.append(l); continue
        parts = t.split(None, 1); op = parts[0]; args = parts[1].split(',') if len(parts) > 1 else []
        args = [a.strip() for a in args]
        if op == 'ld' and len(args) == 2 and args[0].startswith('(XSP') and family_of(args[1]):
            for k in list(known):
                if known[k][1] == args[0]: del known[k]
            known[family_of(args[1])] = (args[1], args[0]); out.append(l); continue
        if op == 'ld' and len(args) == 2 and family_of(args[0]) and args[1].startswith('(XSP'):
            f = family_of(args[0])
            if f in known and known[f] == (args[0], args[1]): continue      # the reload the 2003 compiler drops
            known[f] = (args[0], args[1]); out.append(l); continue
        if args and args[0].startswith('(X') and not args[0].startswith('(XSP'):
            known = {}                                     # a store through a pointer may alias any slot
        elif args and family_of(args[0].rstrip(':')):
            known.pop(family_of(args[0]), None)
        elif op in ('push', 'pop', 'ldir', 'ldirw', 'ldi', 'ldiw'):
            known = {} if op != 'push' else known
        out.append(l)
    return out

def drop_jump_to_next(lines):
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    out = []
    for i, l in enumerate(lines):
        if l.startswith('\tj\t') and ',' not in l:
            k = i + 1; labs = set()
            while k < len(lines) and is_label(lines[k]): labs.add(lines[k][:-1]); k += 1
            if l.split('\t')[2] in labs: continue
        out.append(l)
    return out

def cross_jump(F, lines):
    """-O tail merging (switch.c and ctrl.c under -O3 -XS -Xr).  Jumps to the next label go first.  Then, for each
    label L, the instruction before each `j L` is compared with the one that falls into L: if they are equal the
    jumps move up to a new label before the falling instruction (sw_jt6: ld WA,0xa / j L50000 ... ld WA,0xf /
    L50000: cal .f1 / L3: ret); with no matching fall-through, two or more equal ones merge into the last
    (sw_jt6d: ld WA,0xf / L50002: cal .f1 / j L9).  Repeats while tails match."""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    def uncond(l): return l.startswith(('\tret', '\tj\t', '\tretd')) and ',' not in l
    lines = drop_jump_to_next(lines)
    while True:
        done = False
        for li, lab in enumerate(lines):
            if not is_label(lab): continue
            L = lab[:-1]
            k = li - 1
            while k >= 0 and is_label(lines[k]): k -= 1
            X = lines[k] if k >= 0 and not uncond(lines[k]) and not lines[k].startswith('\tj') else None
            jumps = [i for i, l in enumerate(lines) if l == '\tj\t' + L and i > 0 and not is_label(lines[i - 1])
                     and not lines[i - 1].startswith(('\tj', '\tret'))]
            js = [i for i in jumps if X is not None and lines[i - 1] == X]
            N = None
            if js:                                         # merge into the fall-through
                N = F.newlabel()
                for i in sorted(js, reverse=True): lines[i - 1:i + 1] = ['\tj\t' + N]
                k = [i for i in range(len(lines)) if lines[i] == lab][0] - 1
                while is_label(lines[k]): k -= 1
                lines.insert(k, N + ':')
            else:
                byx = {}
                for i in jumps: byx.setdefault(lines[i - 1], []).append(i)
                grp = [g for g in byx.values() if len(g) >= 2]
                if grp:
                    g = grp[0]; X2 = lines[g[0] - 1]; N = F.newlabel()
                    for i in sorted(g[:-1], reverse=True): lines[i - 1:i + 1] = ['\tj\t' + N]
                    last = max(i for i, l in enumerate(lines) if l == '\tj\t' + L and lines[i - 1] == X2)
                    lines.insert(last - 1, N + ':')        # the last `X / j L` of the group keeps the code
            if N: done = True; break
        if not done: break
    return lines

def tail_calls_opt(F, lines):
    """-O: cal X / j L (L: ret) becomes j X; a label that lost all its references (and is not a ret cc target)
    goes, after which cal X / ret becomes j X and a ret after an unconditional jump goes (sw_jt6d: L17: j .f0)"""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    def leads_to_ret(i):
        while i < len(lines) and is_label(lines[i]): i += 1
        return i < len(lines) and lines[i] == '\tret'
    pos = {l[:-1]: i for i, l in enumerate(lines) if is_label(l)}
    out = list(lines); touched = set()
    for i, l in enumerate(lines):
        if not l.startswith('\tcal\t') or l.split('\t')[2].startswith(('C9H_', '._f')) or l.endswith(';stack'): continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ''
        if nxt.startswith('\tj\t') and ',' not in nxt and nxt.split('\t')[2] in pos and leads_to_ret(pos[nxt.split('\t')[2]]):
            out[i] = '\tj\t' + l.split('\t')[2]; out[i + 1] = None; touched.add(nxt.split('\t')[2])
    out = [l for l in out if l is not None]
    refs = lambda L: any(L in x.split('\t')[-1].split(',') or x.endswith(',' + L) or x.endswith('\t' + L)
                         for x in out if not is_label(x))
    out = [l for l in out if not (is_label(l) and l[:-1] in touched and not refs(l[:-1])
                                  and l[:-1] not in getattr(F, 'ret_refs', set()))]
    pos2 = {l[:-1]: i for i, l in enumerate(out) if is_label(l)}
    for i, l in enumerate(out):                            # _strnset: j eq,L3 (L3: ret) -> ret eq
        if l.startswith('\tj\t') and ',' in l:
            cc, L = l.split('\t')[2].split(',')
            k = pos2.get(L)
            if k is not None:
                while k < len(out) and is_label(out[k]): k += 1
                if k < len(out) and out[k] == '\tret': out[i] = '\tret\t' + cc
    res = []
    for i, l in enumerate(out):
        if l == '\tret' and res and res[-1].startswith('\tcal\t') and res[-1].split('\t')[2].startswith('.') \
                and not res[-1].endswith(';stack'):
            res[-1] = '\tj\t' + res[-1].split('\t')[2]; continue
        if l == '\tret' and res and res[-1].startswith('\tj\t') and ',' not in res[-1]: continue
        res.append(l)
    return res

def tail_calls(lines, keep_end):
    """cal X directly followed by j L, where L leads to ret, becomes j X (switch.c sw_jt6, ctrl.c c_ifchain under
    -Xr; a cal that falls into L: ret stays, cmp_i eq_i_br).  A ret left unreferenced after an unconditional jump is dropped, except a switch
    table's end (sw_jt6 keeps L3: ret, the chain sw_jt4 does not)."""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    def leads_to_ret(i):
        while i < len(lines) and is_label(lines[i]): i += 1
        return i < len(lines) and lines[i] == '\tret'
    pos = {l[:-1]: i for i, l in enumerate(lines) if is_label(l)}
    out = list(lines)
    for i, l in enumerate(lines):
        if not l.startswith('\tcal\t') or l.split('\t')[2].startswith(('C9H_', '._f')): continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ''
        if nxt.startswith('\tj\t') and ',' not in nxt and nxt.split('\t')[2] in pos and leads_to_ret(pos[nxt.split('\t')[2]]):
            out[i] = '\tj\t' + l.split('\t')[2]; out[i + 1] = None
        elif nxt == '\tret' and l.split('\t')[2].startswith('.') and not l.endswith(';stack'):
            out[i] = '\tj\t' + l.split('\t')[2]; out[i + 1] = None        # sw_ret: return g1(1) -> j .g1
    out = [l for l in out if l is not None]
    res = []                                               # a jump to the next label goes (sw_local: ld HL,0x7 / L128:)
    for i, l in enumerate(out):
        if l.startswith('\tj\t') and ',' not in l:
            k = i + 1; labs = set()
            while k < len(out) and is_label(out[k]): labs.add(out[k][:-1]); k += 1
            if l.split('\t')[2] in labs: continue
        res.append(l)
    out = res
    if not keep_end and len(out) >= 3 and out[-1] == '\tret' and is_label(out[-2]) and out[-3].startswith('\tj\t') \
            and ',' not in out[-3]:
        lab = out[-2][:-1]
        if not any(lab in x for x in out[:-2]): out = out[:-2]
    return out

def compile_function(f, opt, adecl, personality='v4.23'):
    F = Fn(f, adecl)
    F.personality = personality
    F.opt = opt != 'none'; F.dead = set()
    compute_last_uses(F)
    F.lines.append(('.' if adecl else '_') + f.name + ':')
    F.loops = []; F.param_copies = []; F.pushes = []
    if not plan_leaf(F): plan_registers(F); plan_homes(F)
    plan_frame(F)
    emit_homes(F)
    if F.opt: plan_shared_exit(F)
    gen_stmt(F, f.body, True)
    flush_pops(F)
    if not F.lines[-1].startswith('\tret'):
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F)
        F.emit('ret')
    for t in reversed(getattr(F, 'tables', [])): F.lines[1:1] = t     # switch tables right after the label
    if F.opt: F.lines = tail_calls_opt(F, cross_jump(F, F.lines))
    else: F.lines = tail_calls(F.lines, getattr(F, 'switch_table', False))
    import re                                            # no self-moves: the oracle never writes ld XWA,XWA
    F.lines = [l for l in F.lines if not re.match(r'^\tld\t(\w+),\1$', l)]
    # a call directly followed by the return becomes a jump (cmp_ui: ge_ui_br0)
    if getattr(F, 'naive_loads', False): F.lines = knowledge_pass(F.lines, F.personality)
    elif F.personality != 'v4.23': F.lines = store_knowledge(F.lines)
    if len(F.lines) >= 2 and F.lines[-1] == '\tret' and F.lines[-2].startswith('\tcal\t') \
            and not F.lines[-2].split('\t')[2].startswith(('C9H_', '._f')) and not F.lines[-2].endswith(';stack'):
        F.lines[-2:] = ['\tj\t' + F.lines[-2].split('\t')[2]]
    F.lines = [l[:-len('\t;stack')] if l.endswith('\t;stack') else l for l in F.lines]
    # a label that only a jump to `ret` uses: the oracle keeps it; nothing to do here yet
    return F.lines

def data_value(e):
    """the constant value of a global's initializer (sizes.c: sizeof, offsetof spelt with a null pointer, (char)0x80 < 0)"""
    e = strip(e)
    if e.k == 'cast' and e.kind == 'PointerToIntegral':
        a = strip(e.e)
        if a.k == 'addr' and strip(a.e).k == 'member' and strip(a.e).arrow:
            b = strip(strip(a.e).base)
            if b.k == 'cast' and fold(b.e).k == 'const' and fold(b.e).value == 0: return member_offset(strip(a.e))
    if e.k == 'cast' and e.kind == 'IntegralCast':
        v = data_value(e.e)
        if v is None: return None
        v &= (1 << (8 * e.ty.size)) - 1
        if e.ty.signed and v >= 1 << (8 * e.ty.size - 1): v -= 1 << (8 * e.ty.size)
        return v
    if e.k == 'un' and e.op == '-':
        v = data_value(e.e); return None if v is None else -v
    if e.k == 'bin':
        a, b = data_value(e.l), data_value(e.r)
        if a is None or b is None: return None
        ops = {'+': a + b, '-': a - b, '*': a * b, '<': int(a < b), '>': int(a > b), '<=': int(a <= b),
               '>=': int(a >= b), '==': int(a == b), '!=': int(a != b), '&': a & b, '|': a | b, '^': a ^ b}
        return ops.get(e.op)
    f = fold(e)
    return f.value if f.k == 'const' else None

def emit_data(unit, out):
    """global data as thc2 lists it (globals.c, sizes.c): initialized objects in declaration order (const ones in
    f_const, the rest in f_data), each followed by the string literals it points to (_g_strp: dl S1 / S1: db
    "hello",0); uninitialized objects last (f_area, dsb N).  Labels keep `_` in -Xr files too."""
    sn = [0]
    bss = []
    for d in unit.globals:
        if d.ty.kind == 'func': continue
        name = '_' + d.name
        if d.init_expr is None:
            if not d.init: bss.append(d)
            continue
        e = strip(d.init_expr); lines = [name + ':']; tail = []
        if d.ty.kind == 'int':
            v = data_value(e)
            if v is None: continue
            lines.append('\t%s\t%d' % ({1: 'db', 2: 'dw', 4: 'dl'}[d.ty.size], v))
        elif d.ty.kind == 'float' and d.ty.size == 8 and e.k in ('fconst', 'cast'):
            v = e.value if e.k == 'fconst' else getattr(strip(e.e), 'value', None)
            if v is None: continue
            m, x = ('%.20e' % v).split('e')
            lines.append('\tfdatad\t%se%s%03d' % (m, x[0], abs(int(x))))
        elif d.ty.kind == 'array' and e.k == 'string':
            lines.append('\tdb\t%s,0' % e.value)
        elif d.ty.kind == 'array' and e.k == 'initlist' and d.ty.base.kind == 'int':
            vals = [data_value(x) for x in e.items]        # _CTYPE.C: db 32,32,... eight a line, align 1 between
            if None in vals: continue
            vals += [0] * (d.ty.count - len(vals)) if d.ty.count else []
            w = {1: 'db', 2: 'dw', 4: 'dl'}[d.ty.base.size]
            rows = [vals[i:i + 8] for i in range(0, len(vals), 8)]
            for i, row in enumerate(rows):
                if i: lines.append('\talign\t1')
                lines.append('\t%s\t%s' % (w, ','.join(str(v) for v in row)))
        elif d.ty.kind == 'ptr' and strip(e).k in ('decay', 'string', 'noop') and strip(getattr(strip(e), 'e', e)).k == 'string':
            sn[0] += 1; lab = 'S%d' % sn[0]
            lines.append('\tdl\t' + lab); tail = [lab + ':', '\tdb\t%s,0' % strip(getattr(strip(e), 'e', e)).value]
        elif d.ty.kind == 'ptr' and data_value(e) is not None:
            lines.append('\tdl\t%d' % data_value(e))
        else:
            continue
        out[name] = lines + tail
    for d in bss:
        out['_' + d.name] = ['_' + d.name + ':', '\tdsb\t%d' % d.ty.size]

FULL = {}

def compile_unit(unit, opt='none', adecl=False, personality='v4.23'):
    out = {}
    emit_data(unit, out)
    for f in unit.functions:
        name = ('.' if adecl else '_') + f.name
        try:
            full = compile_function(f, opt, adecl, personality)
            FULL[name] = full                              # the whole function, for pairs_model.py
            import re as _re                               # an inline-assembly label named _x / .x starts a new piece in
            cur = name; out[cur] = []                      # a listing (listing.split), so the model's output does too
            for i, l in enumerate(full):
                if i and _re.match(r'^[._][A-Za-z0-9_]+:$', l) and l[:-1] not in out: cur = l[:-1]; out[cur] = []
                out[cur].append(l)
        except Unsupported as ex: out[name] = ['; unsupported: %s' % ex]
        except (AttributeError, KeyError, ValueError, TypeError, IndexError) as ex:
            out[name] = ['; model error: %s: %s' % (type(ex).__name__, ex)]     # counted as a mismatch
    return out
