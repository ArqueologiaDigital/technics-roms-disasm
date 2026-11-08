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
       'DE': {1: 'E', 2: 'DE', 4: 'XDE'}, 'HL': {1: 'L', 2: 'HL', 4: 'XHL'}}
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
        for p in f.params:
            p.off = off; off += 2 if p.ty.size <= 2 else (p.ty.size + 1) // 2 * 2
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
            if d.kind == 'param': return '(XSP+%s)' % hx(d.off + F.push)
            if d.kind in ('global', 'func') and not d.ty.kind == 'array': return '(_%s)' % d.name
    return None

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
        F.emit('ld', '%s,%s' % (FAM[fam][size], src)); return fam
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
    if e.k == 'un' and e.op == '!':
        x = strip(e.e); xs = x.ty.size; m = mem_operand(F, x)
        if xs == 4 or m is None:               # lnot_l: ld XWA,x / or XWA,XWA
            gen(F, x, 'WA', xs); W = FAM['WA'][xs]; F.emit('or', '%s,%s' % (W, W))
        else:
            F.emit('cp%s' % ('b' if xs == 1 else 'w'), '%s,0x0' % m)
        F.emit('scc', 'eq,%s' % FAM[fam][2]); return fam
    if e.k == 'incdec':
        return gen_incdec(F, e, fam, size, value=True)
    if e.k == 'load' and strip(e.e).k == 'deref' and strip(strip(e.e).e).k == 'incdec' and strip(strip(e.e).e).post:
        inc = strip(strip(e.e).e); g = global_name(inc.e)
        if g is None: raise Unsupported('deref incdec')
        F.emit('ld', 'XBC,(%s)' % g); F.emit('ld', 'XWA,%s' % hx(strip(inc.e).ty.base.size))
        F.emit('add' if inc.op == '++' else 'sub', '(%s),XWA' % g)
        F.emit('ld', '%s,(XBC)' % FAM[fam][size]); return fam
    if e.k == 'load' and strip(e.e).k == 'var' and getattr(strip(e.e).decl, 'reg', None):
        r = strip(e.e).decl.reg
        if r != fam: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[r][size]))
        return fam
    if e.k == 'bin':
        return gen_bin(F, e, fam, size, then_ret, store)
    raise Unsupported(e.k)

def gen_bin(F, e, fam, size, then_ret, store=False):
    op = e.op; l, r = narrow(e.l, size), narrow(e.r, size)
    signed = e.ty.signed if size >= e.ty.size else is_signed(l)
    R = FAM[fam][size]
    if op in SIMPLE_OPS:
        gen(F, l, fam, size)
        rs = mem_operand(F, r)
        if rs is None: raise Unsupported('complex right operand')
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
        if rs is None: raise Unsupported('complex right operand')
        gen(F, l, 'WA', size)
        wide = 'XWA' if size == 2 else 'WA'
        if op == '*':
            F.emit('muls' if signed else 'mul', '%s,%s' % (wide, rs))
            res = FAM['WA'][size]
        else:
            F.emit('exts' if signed else 'extz', wide)
            F.emit('divs' if signed else 'div', '%s,%s' % (wide, rs))
            res = FAM['WA'][size] if op == '/' else ('QWA' if size == 2 else 'W')
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
    if F.xiz_vars:
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
    if rc.k == 'const' and lm is not None and lm.startswith('(') and size <= 2:
        F.emit('cp' + ('b' if size == 1 else 'w'), '%s,%s' % (lm, hx(rc.value))); return cc
    W = FAM['WA'][size]
    gen(F, l, 'WA', size)
    if rc.k == 'const' and rc.value == 0 and size == 4 and op in ('==', '!='):
        F.emit('or', '%s,%s' % (W, W)); return cc
    rs = mem_operand(F, r)
    if rs is None: raise Unsupported('complex compare operand')
    F.emit('cp', '%s,%s' % (W, rs)); return cc

def gen_cond_false(F, c, target):
    """jump to `target` (a label, or 'RET' for the function exit) when condition c is false; returns the
    constant value of c when it folds"""
    c = strip(c)
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

def store_global(F, name, e, size):
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
            gen_stmt(F, c, last and i == len(body) - 1); i += 1
        return
    if s.k == 'decl': raise Unsupported('decl')
    if s.k == 'return':
        if s.value is not None:
            size = F.f.ret.size
            fam = gen(F, s.value, 'HL', size, then_ret=True)
            if fam != 'HL': F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam][size]))
        flush_pops(F)
        if F.xiz_vars: F.emit('pop', 'XIZ')
        F.emit('ret'); return
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
        gen_stmt(F, s.then, False)
        F.emit('j', lend); F.lines.append(lelse + ':')
        gen_stmt(F, s.els, last); F.lines.append(lend + ':')
        return
    if s.k == 'expr' and s.e.k == 'call':
        gen_call(F, s.e); return
    if s.k == 'expr' and s.e.k == 'incdec':
        gen_incdec(F, s.e, 'WA', 0, value=False); return
    if s.k == 'expr' and s.e.k == 'bin' and s.e.op == '=':
        lv = strip(s.e.l)
        if lv.k == 'var' and lv.decl.kind == 'global':
            store_global(F, lv.decl.name, s.e.r, lv.decl.ty.size); return
    raise Unsupported('statement ' + s.k)

def has_helper_call(e):
    if not hasattr(e, 'k'): return False
    if e.k == 'bin' and e.op in '*/%' and e.ty.size == 4 and fold(e.r).k != 'const': return True
    if e.k == 'call': return True
    return any(has_helper_call(v) for v in e.__dict__.values() if hasattr(v, 'k'))

def plan_registers(F):
    body = flat(F.f.body)
    for i, c in enumerate(body):
        if c.k == 'decl' and c.init is not None and c.var.ty.size == 4 and has_helper_call(c.init):
            later = body[i + 1:]
            if any(has_helper_call(getattr(x, 'value', None) or getattr(x, 'e', None)) for x in later):
                c.var.reg = 'XIZ'; F.xiz_vars.append(c.var)
    if F.xiz_vars:
        F.emit('push', 'XIZ'); F.push = 4

def compile_function(f, opt, adecl):
    F = Fn(f, adecl)
    F.lines.append(('.' if adecl else '_') + f.name + ':')
    plan_registers(F)
    gen_stmt(F, f.body, True)
    flush_pops(F)
    if not F.lines[-1].startswith('\tret'): F.emit('ret')
    # a call directly followed by the return becomes a jump (cmp_ui: ge_ui_br0)
    if len(F.lines) >= 2 and F.lines[-1] == '\tret' and F.lines[-2].startswith('\tcal\t') \
            and not F.lines[-2].split('\t')[2].startswith(('C9H_', '._f')):
        F.lines[-2:] = ['\tj\t' + F.lines[-2].split('\t')[2]]
    # a label that only a jump to `ret` uses: the oracle keeps it; nothing to do here yet
    return F.lines

def compile_unit(unit, opt='none', adecl=False):
    out = {}
    for f in unit.functions:
        name = ('.' if adecl else '_') + f.name
        try: out[name] = compile_function(f, opt, adecl)
        except Unsupported as ex: out[name] = ['; unsupported: %s' % ex]
    return out
