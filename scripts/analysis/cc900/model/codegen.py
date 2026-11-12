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

import os
import chidx                                              # char indexes (probes/chidx.c)
import re
import fpgen
import homes
import homes2

class Unsupported(Exception): pass

class LiveClobber(Unsupported):
    """the live-register guard fired on a register temporary (plan_regtemps): compile_function retries with the
    next candidate home"""
    def __init__(s, msg, decl): Unsupported.__init__(s, msg); s.decl = decl

FAM = {'WA': {1: 'A', 2: 'WA', 4: 'XWA'}, 'BC': {1: 'C', 2: 'BC', 4: 'XBC'},
       'DE': {1: 'E', 2: 'DE', 4: 'XDE'}, 'HL': {1: 'L', 2: 'HL', 4: 'XHL'},
       'IX': {2: 'IX', 4: 'XIX'}, 'IY': {2: 'IY', 4: 'XIY'}, 'IZ': {2: 'IZ', 4: 'XIZ'},
       'QWA': {2: 'QWA'}, 'QIZ': {2: 'QIZ'}, 'XIZ': {4: 'XIZ'},
       'QBC': {2: 'QBC'}, 'QDE': {2: 'QDE'}, 'QHL': {2: 'QHL'}, 'QIX': {2: 'QIX'}, 'QIY': {2: 'QIY'},   # _itoa: u in QBC
       'W': {1: 'W'}, 'B': {1: 'B'}, 'D': {1: 'D'}, 'H': {1: 'H'},   # a char in a high half (U1: ol_c_acc2's s1 in B)
       'QIZH': {1: 'QIZH'}}                                         # a char live across a call (r1_05_05)
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
        if f.ret is not None and (f.ret.kind == 'struct' and f.ret.size > 4 or f.ret.kind == 'float' and f.ret.size == 8) \
                and not adecl:
            from frontend import Decl, Type                  # abi.md: the hidden first argument (_ldiv)
            s.sret = Decl('__sret', Type('ptr', 4, 2, base=f.ret, spell='sret'), '', 'param'); s.sret.off = 4; off = 8
        s.retd = 0
        if adecl:                                   # abi.md: XWA / XBC / XDE, then the stack left to right
            regs = ['WA', 'BC', 'DE']
            stack = []
            for i, p in enumerate(f.params):
                if i < 3 and p.ty.kind != 'struct' and not (p.ty.kind == 'float' and p.ty.size == 8): p.reg = regs[i]
                else: stack.append(p)                  # abi structs.c s_pair: a struct is on the stack (its register
                                                       # position is used up: a guess, abi.md); a double too, and its
                                                       # position is used up (probes/adfp.c ad_idi: b in DE); a float
                                                       # is in its register like a long (ad_fi: x in XWA)
            for p in reversed(stack):
                p.off = off; off += 2 if p.ty.size <= 2 else (p.ty.size + 1) // 2 * 2
            s.retd = off - 4
        else:
            for p in f.params:
                p.off = off; off += 2 if p.ty.size <= 2 else (p.ty.size + 1) // 2 * 2
        if s.sret is not None: f.params = [s.sret] + [p for p in f.params if p is not s.sret]
    def emit(s, op, args=None):
        if args is not None and 'None' in args: raise Unsupported('operand None in %s %s' % (op, args))   # (r4_07_06)
        if op == 'ld' and args is not None and re.match(r'^(WA|BC|DE|HL|IX|IY|IZ),[WABCDEHL]$', args):
            raise Unsupported('a byte into a word: ld %s' % args)   # (r2_02_05 -Xr: ld WA,A for a char index)
        if op == 'cp' and args is not None:
            m_ = re.match(r'^([WABCDEHL]),0x([0-9a-f]{3,})$', args)   # (r3_01_02: cp A,0xffc2 -> cp A,0xc2)
            if m_: args = '%s,%s' % (m_.group(1), hx(int(m_.group(2), 16) & 0xff))
        if op in ('ldw', 'ldb') and args is not None:
            m_ = re.match(r'^(.*),0x([0-9a-f]+)$', args)   # an immediate store is masked to its width (r1_08_15 wrote
            if m_ and len(m_.group(2)) > (4 if op == 'ldw' else 2):   # ldw ..,0xffffff00)
                args = '%s,%s' % (m_.group(1), hx(int(m_.group(2), 16) & (0xffff if op == 'ldw' else 0xff)))
        if LIVE_PARAM_GUARD and (s.adecl or LIVE_LOCAL_GUARD) and getattr(s, 'guard_on', False) and args is not None and \
                getattr(s, 'u1_i', None) is None and not getattr(s, 'u1x', None) and not getattr(s, 'cl_active', None) \
                and not getattr(s, 'l2', None) and not getattr(s, 'u1_inv', None):   # (the loop allocators keep their
                                                         # registers in their own objects; ol_inv hoists a * b into a's)
            for fam_ in written_fams(op, args):
                cur_k = getattr(getattr(s, 'cur_stmt', None), 'k', None)
                for d in list(s.f.params) + (list(s.f.decls) if LIVE_LOCAL_GUARD else []):
                    rt_ = getattr(d, 'regtemp', False)
                    if cur_k == 'return' or getattr(s, 'in_return', False) or d in getattr(s, 'deferred', ()) or \
                            (d.kind != 'param' and ((op == 'cal' and not rt_) or cur_k is None or getattr(s, 'counted', None) or
                                                    not local_defined_before(s, d))):
                        continue                         # (nothing is live after a return: _strlen's ld HL,0xffff; a
                                                         # deferred copy is not loaded yet; a call's clobber of a local's
                                                         # home is its planner's business: homes2a R55; a counted-loop
                                                         # planner's init: ol_c_acc3's ld H,0x0; a local not assigned
                                                         # yet: lnr3 s_add2_u's d1)
                    if rt_ and not param_live_after(s, d) and uses_decl(getattr(s, 'cur_stmt', None), d) and \
                            (op == 'cal' or self_update(op, args, d) or
                             op in ('exts', 'extz') and args in (d.reg, 'X' + d.reg) or   # (lo_c_G0a: exts WA / push WA)
                             re.search(r'\b(X?%s|%s)\b' % (d.reg, {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}[d.reg]),
                                       args.split(',', 1)[1] if ',' in args else '')):
                        continue                         # (the read that consumes it: lo_i_G0e add WA,(_hi))
                    if getattr(d, 'reg', None) in ('WA', 'BC', 'DE', 'HL') and 'X' + d.reg == fam_ and d not in s.dead and \
                            (param_live_after(s, d) or rt_ and uses_decl(getattr(s, 'cur_stmt', None), d)) and \
                            not assigns_decl(getattr(s, 'cur_stmt', None), d) and \
                            not (assigns_decl(getattr(s, 'top_cur', None), d) and
                                 (getattr(getattr(s, 'top_cur', None), 'k', None) not in ('while', 'do', 'for') or
                                  self_update(op, args, d))) and \
                            not (op == 'ld' and own_slot(s, d, args)) and \
                            not re.search(r',(X?IZ|QIZ|QIZH|IZL|X?IX|X?IY)$', args):   # (a read of a home: the
                        if rt_: raise LiveClobber('%s %s over the register temporary %s in %s' % (op, args, d.name, d.reg), d)
                        raise Unsupported('%s %s over the live parameter %s in %s' % (op, args, d.name, d.reg))   # parameter moved there, c_fordown)
        s.lines.append('\t' + op + ('\t' + args if args else ''))
    def newlabel(s):
        s.label += 1; return 'L%d' % s.label
    def newulabel(s):
        s.ulabel = getattr(s, 'ulabel', 0) + 1; return 'L%d' % s.ulabel

# ------------------------------------------------------------- expression helpers

def strip(e):
    while e.k in ('noop', 'decay'): e = e.e
    return e

CUR_OPT = [True]                                           # the current function's -O (narrow() has no F)

def long_arith_kept(x, size):
    """without -O a long + - & | ^ narrowed to an int keeps its 32 bits (switch.c sw_ev: f1((int)(ev - 0x2000)) ->
    ld XWA,(XSP+0x6) / sub XWA,0x2000 / push WA; -O3 -XS narrows it: ld WA,(XSP+0x6) / sub WA,0x2000)"""
    return not CUR_OPT[0] and x.k == 'bin' and x.op in ('+', '-', '&', '|', '^') and x.ty.size == 4 and size < 4

def narrow(e, size):
    """the value of e, known to be needed only in its low `size` bytes: drop integral casts that widen"""
    e = strip(e)
    while e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size >= size and not wide_divide(strip(e.e), size) \
            and not ptrdiff_arith(strip(e.e)) and not long_arith_kept(strip(e.e), size):
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

def ptrdiff_arith(e):
    """an + / - on a pointer difference: cc900 does it at the difference's 32 bits even when the result is narrowed
    (_memccpy: (unsigned)(pos - s2 + 1) -> sub XWA,(XSP+0xe) / inc 0x1,XWA / push WA)"""
    if e.k != 'bin' or e.op not in ('+', '-'): return False
    for x in (e.l, e.r):
        x = strip(x)
        while x.k == 'cast' and x.kind in ('IntegralCast', 'NoOp'): x = strip(x.e)
        if x.k == 'bin' and x.op == '-' and strip(x.l).ty is not None and strip(x.l).ty.is_ptr() and \
                strip(x.r).ty is not None and strip(x.r).ty.is_ptr(): return True
    return False

def same_size_ptr_cast(e):
    """an integer <-> pointer cast between equal sizes changes nothing (__SBRK.C: (void *)SBRK_size)"""
    while e.k == 'cast' and e.kind in ('IntegralToPointer', 'PointerToIntegral') and strip(e.e).ty is not None \
            and strip(e.e).ty.size == e.ty.size:
        e = strip(e.e)
    return e

def fold(e):
    """constant folding of integral casts of constants"""
    e = same_size_ptr_cast(strip(e))
    if e.k == 'un' and e.op == '-' and fold(e.e).k == 'const' and fold(e.e).value is not None:
        from frontend import N                           # c_find: return -1 -> ld HL,0xffff
        v = -fold(e.e).value; sz = e.ty.size if e.ty is not None else 2
        return N('const', value=v, ty=e.ty)
    if e.k == 'un' and e.op == '!' and FOLD_NOT and fold(e.e).k == 'const' and fold(e.e).value is not None:
        from frontend import N                           # r3_01_13: !7UL -> 0 (the model had tested it at run time)
        return N('const', value=int(not fold(e.e).value), ty=e.ty)
    if e.k == 'un' and e.op == '~' and FOLD_NOT and fold(e.e).k == 'const' and fold(e.e).value is not None:
        from frontend import N                           # _fgetc: stream->flag &= ~__UNGETC -> andw (XBC),0xfffb
        v = fold(e.e).value
        n = N('const', value=~v, ty=e.ty)
        if 128 <= v <= 255: n.byte_unsigned = True       # V4.23 types a constant 128..255 as an unsigned char: ~255
        return n                                         # keeps 0xff00 for further folding (-8 ^ ~255 is 0xf8) but
                                                         # materializes as its low byte (gpi[1] = ~255 -> ldw ..,0x0,
                                                         # pushw 0x0, ld IZ,0x0; ~139 * x -> mul WA,0x74); ~4 stays
                                                         # 0xfffb (_fgetc) and 16 - 255 is 0xff11.  Imitated.
    if e.k == 'bin' and e.op in ('+', '-', '*', '|', '&', '^', '<<', '>>') and fold(e.l).k == 'const' and \
            fold(e.r).k == 'const' and fold(e.l).value is not None and fold(e.r).value is not None and \
            (e.op not in ('<<', '>>') or 0 <= fold(e.r).value < 32):
        from frontend import N                           # sizeof(buf) - 1; cond_bits.c: x & (0x2 | 0x4);
        a, b = fold(e.l).value, fold(e.r).value           # r4_03_11: guca[i] -= 236 >> 6 -> decb 0x3 (the model shifted
        if e.op == '>>' and e.ty is not None and e.ty.size in (1, 2, 4):   # 0xec in a byte)
            sz = 8 * e.ty.size; a &= (1 << sz) - 1         # (r1_02_00: ~0x10000UL >> 3 is a logical shift of the
            if e.ty.signed and a & (1 << (sz - 1)): a -= 1 << sz   # 32-bit value, 0x1fffdfff; Python's >> of the
        if e.op == '<<': v = a << b                      # (computed per operator: a dict evaluated every entry, and
        elif e.op == '>>': v = a >> b                    # -8 ^ ~255 raised "negative shift count")
        else: v = {'+': a + b, '-': a - b, '*': a * b, '|': a | b, '&': a & b, '^': a ^ b}[e.op]
        return N('const', value=v, ty=e.ty)
    if e.k == 'bin' and e.op in ('<', '<=', '>', '>=', '==', '!=') and FOLD_CONST_CMP and fold(e.l).k == 'const' and \
            fold(e.r).k == 'const' and fold(e.l).value is not None and fold(e.r).value is not None:
        from frontend import N                           # r2_06_17: gca[a] & 0x7 || 39 < 3 -> the second test is gone
        a_, b_ = fold(e.l).value, fold(e.r).value         # (ld WA,0x27 / cp WA,0x3 destroyed a in WA under -Xr)
        v = {'<': a_ < b_, '<=': a_ <= b_, '>': a_ > b_, '>=': a_ >= b_, '==': a_ == b_, '!=': a_ != b_}[e.op]
        return N('const', value=int(v), ty=e.ty)
    if e.k == 'bin' and e.op in ('<', '<=', '>', '>=', '==', '!=') and FOLD_UCHAR_CMP:
        lx, rc = strip(e.l), fold(e.r)
        if lx.k == 'cast' and lx.kind == 'IntegralCast' and strip(lx.e).ty is not None and strip(lx.e).ty.size == 1 \
                and not strip(lx.e).ty.signed and rc.k == 'const' and rc.value is not None and not (0 <= rc.value <= 255):
            from frontend import N                       # random r1_05_01: (a > 255 ? gi3 : b) with an unsigned char a
            big = rc.value > 255
            v = {'<': big, '<=': big, '>': not big, '>=': not big, '==': False, '!=': True}[e.op]
            return N('const', value=int(v), ty=e.ty)
    if e.k == 'bin' and e.op in ('/', '%') and FOLD_SELF_DIV and same_leaf(e.l, e.r) and e.ty is not None and e.ty.size <= 2:
        from frontend import N                           # random r2_05_00: gu % gu -> 0 (V4.23 folds it; UB at 0)
        return N('const', value=0 if e.op == '%' else 1, ty=e.ty)
    if e.k == 'bin' and e.op in ('/', '%') and FOLD_DIV and fold(e.l).k == 'const' and fold(e.r).k == 'const' \
            and fold(e.l).value is not None and fold(e.r).value:
        from frontend import N                           # random r1_02_06: vl(3L / 3L) -> ld XWA,0x1
        a, b = fold(e.l).value, fold(e.r).value
        q = abs(a) // abs(b) * (1 if (a < 0) == (b < 0) else -1)
        return N('const', value=q if e.op == '/' else a - q * b, ty=e.ty)
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

def imm_of(c, size):
    """the immediate for a folded constant at a store or op-assign of `size` bytes: masked to the width, or to a
    byte when V4.23 typed it as an unsigned char (fold's ~K rule: gpi[1] = ~255 -> ldw (XWA+0x2),0x0)"""
    if getattr(c, 'byte_unsigned', False): return hx(c.value & 0xff)
    return hx(c.value & ((1 << (8 * size)) - 1))

def mem_operand(F, e):
    """a memory or immediate operand string for e, or None"""
    e = same_size_ptr_cast(strip(e))
    eo = getattr(F, 'elem_ops', None)
    if eo and e.k == 'load' and id(strip(e.e)) in eo: return eo[id(strip(e.e))]   # (shared_base_opassign)
    lh = getattr(F, 'lazy_homes', None)
    if lh and e.k == 'load' and strip(e.e).k == 'deref':  # ra_libshapes.c ls_sl_2 (-O3 -XS): *s with s a lazy cdecl
        pv = strip(strip(e.e).e)                           # home: its load comes first (ld A,(XIZ) read an unloaded
        if pv.k == 'load' and strip(pv.e).k == 'var' and strip(pv.e).decl in lh:   # XIZ: wrong code)
            touch_home(F, strip(pv.e).decl)
    if strip(e).k == 'cast':
        ct = cast_temp(F, strip(e))
        if ct: return ct
    e = fold(e)
    if e.k == 'load' and strip(e.e).k == 'deref' and getattr(F, 'naive_loads', False):
        pv = strip(strip(e.e).e)                          # _ultoa: ld XWA,(p) / ... (XWA)
        if pv.k == 'load' and strip(pv.e).k == 'var' and hasattr(strip(pv.e).decl, 'slot'):
            F.emit('ld', 'XWA,(XSP+%s)' % hx(strip(pv.e).decl.slot + F.push)); return '(XWA)'
    if e.k == 'const' and e.value is not None:            # c_find: -1 in a 16-bit context is 0xffff
        sz = e.ty.size if getattr(e, 'ty', None) is not None and e.ty.size in (1, 2, 4) else 4
        if getattr(e, 'byte_unsigned', False): return hx(e.value & 0xff)   # (~255 materializes as 0: see fold)
        return hx(e.value & ((1 << (8 * sz)) - 1))        # (r4_09_15: return 32767 * 5 -> ld HL,0x7ffb)
    if e.k == 'load' and strip(e.e).k == 'index' and getattr(F, 'u1_i', None) is not None:
        u1 = u1_operand(F, strip(e.e))                   # oc_sum_pn: add HL,(XDE) after the chain
        if u1 is not None: return u1
    if e.k == 'load' and strip(e.e).k == 'index' and fold(strip(e.e).idx).k == 'const':
        bb = strip(strip(e.e).base)                      # Toshiba's va_arg as an operand: s += va_arg(ap, int) ->
        while bb.k == 'cast': bb = strip(bb.e)           # inc 0x2,XBC / add HL,(XBC-0x2)
        if bb.k == 'opassign' and bb.op in '+-' and regvar_of(bb.l) and fold(bb.r).k == 'const':
            d = regvar_of(bb.l); X = FAM[d.reg][4]
            F.emit('inc' if bb.op == '+' else 'dec', '%s,%s' % (hx(fold(bb.r).value), X))
            off = fold(strip(e.e).idx).value * e.ty.size
            return '(%s%s%s)' % (X, '+' if off >= 0 else '-', hx(abs(off))) if off else '(%s)' % X
        if bb.k == 'member' and not bb.arrow and strip(bb.base).k == 'var' and strip(bb.base).decl.kind == 'local' \
                and getattr(strip(bb.base).decl, 'slot', None) is not None and fold(strip(e.e).idx).value is not None:
            t = strip(bb.base).decl.slot + F.push + member_offset(bb) + fold(strip(e.e).idx).value * e.ty.size
            return '(XSP+%s)' % hx(t) if t else '(XSP+0x0~)'   # cb_union_c7 / _n0: d.c[7] -> (XSP+0x7), d.n[0] ->
                                                            # (XSP+0x0): an element keeps its zero (see ZERO_DISP)
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
            if d.kind == 'static' and not d.ty.kind == 'array' and getattr(d, 'init', None) is None:
                return '(%s)' % fpgen.static_label(F, d)   # gl_local_static: incw 0x1,(S3) / ld HL,(S3)
        if v.k == 'index' and fold(v.idx).k == 'const':     # _tan: ((unsigned short *)&x)[3] -> (XSP+off+6)
            b = strip(v.base)
            while b.k == 'cast': b = strip(b.e)
            if b.k == 'addr' and strip(b.e).k == 'var':
                d = strip(b.e).decl; k = fold(v.idx).value * v.ty.size
                if d.kind == 'param' and not getattr(d, 'reg', None) and hasattr(d, 'off'):
                    return '(XSP+%s)' % hx(d.off + k + F.push)
                if d.kind == 'local' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + k + F.push)
        pc_ = getattr(F, 'ptr_cache', None) or {}
        if pc_ and v.k == 'member' and v.arrow and strip(v.base).k == 'load' and strip(strip(v.base).e).k == 'var' and \
                strip(strip(v.base).e).decl in pc_:        # _fgetc: ld WA,(XBC) / ld HL,(XDE+0x8) / ld XWA,(XDE+0x4)
            pd_ = strip(strip(v.base).e).decl; off_ = member_offset(v)
            mc_ = getattr(F, 'member_cache', None) or {}
            if (pd_, off_) in mc_: return mc_[(pd_, off_)]
            P_ = pc_[pd_]
            return '(%s+%s)' % (P_, hx(off_)) if off_ else '(%s)' % P_
        if REG_MEMBER and not F.opt and not F.adecl and v.k == 'member' and v.arrow:
            pv = strip(v.base)                           # assign_expr.c ae_fl_chain (none): cp in XBC ->
            if pv.k == 'load' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:   # cpw (XBC+0x4),0x4 /
                X = FAM[regvar_of(pv.e).reg][4]; off = member_offset(v)            # ld XBC,(XBC)
                return '(%s+%s)' % (X, hx(off)) if off else '(%s)' % X
        g = global_offset(v)
        if g and g[0] == '__param__': return '(XSP+%s)' % hx(g[1].off + g[2] + F.push)   # s_pair: ld HL,(XSP+0x6)
        if g: return '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0]
        if v.k == 'deref' and getattr(F, 'l2', None) and F.l2.get('ivmap'):
            pv = strip(v.e)                              # _strrev: tmp = *p -> ld A,(XBC)
            if pv.k == 'load' and strip(pv.e).k == 'var' and strip(pv.e).decl in F.l2['ivmap']:
                return '(X%s)' % F.l2['ivmap'][strip(pv.e).decl]
        if v.k == 'deref':                              # _strcat at -O: (XDE), (XBC+:1)
            pv = strip(v.e)
            if pv.k == 'load' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
                return '(%s)' % FAM[regvar_of(pv.e).reg][4]
            hv = strip(pv.e) if pv.k == 'load' else None     # ls_sl_g, ls_sl_2 (-Xr): s homed in XIZ -> ld L,(XIZ)
            if hv is not None and hv.k == 'var' and getattr(hv.decl, 'homed', False) and hv.decl.reg == 'XIZ' and \
                    hv.decl.ty.size == 4 and DEREF_XIZ:
                return '(XIZ)'
            if pv.k == 'incdec' and pv.post and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
                d = regvar_of(pv.e); step = d.ty.base.size
                return '(%s%s:%d)' % (FAM[d.reg][4], '+' if pv.op == '++' else '-', step)
            if pv.k == 'incdec' and not pv.post and pv.op == '--' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
                d = regvar_of(pv.e)                      # _strrchr: *(--s0) -> (-XHL:1)
                return '(-%s:%d)' % (FAM[d.reg][4], d.ty.base.size)
    return None

GLOBAL_MEMBER_ELEM = True                                 # gs.a[3] is a static operand (random r1_02_07, r1_05_12)
ADDR_GLOBAL_CONST = True                                  # &gia[5], &gs.a[2]: lda R,_gia + 0xa (random r1_01_12)

def global_offset(v):
    """(name, offset) when v is a global object at a constant offset: ga[3], gs.i, gs.a[3] (mem.c: m_ga_k, m_gs_i)"""
    v = strip(v)
    if v.k == 'index':
        b = strip(v.base); i = fold(v.idx)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and i.k == 'const':
            return (b.decl.name, hx(i.value * v.ty.size))
        if GLOBAL_MEMBER_ELEM and b.k == 'member' and not b.arrow and i.k == 'const' and i.value is not None and \
                strip(b.base).k == 'var' and strip(b.base).decl.kind == 'global':   # gs.a[3] -> (_gs + 0x14)
            return (strip(b.base).decl.name, hx(member_offset(b) + i.value * v.ty.size))   # (random r1_02_07)
    if v.k == 'member' and not v.arrow:
        b = strip(v.base)
        if b.k == 'var' and b.decl.kind == 'param' and hasattr(b.decl, 'off') and not getattr(b.decl, 'reg', None):
            return ('__param__', b.decl, member_offset(v))
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
    x = strip(e)                                         # binop-loc 1.1: an operation narrowed to its operands'
    if UNPROMOTED_SIGN:                                  # width keeps their own signedness (mul_uc_loc under O3XS:
        while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty is not None and \
                strip(x.e).ty.size < x.ty.size:          # mul WA,C, not muls)
            x = strip(x.e)
    return x.ty.signed

# ------------------------------------------------------------- code generation

def esize_of(b):
    t = strip(b.l).ty
    return t.base.size if t.kind in ('ptr', 'array') and t.base is not None else 1

def l2_array_base(F, ar):
    """L2: a local array's address in its register, set at the first use (_itoa: lda XIZ,XSP+0x4)"""
    done = F.l2.setdefault('arr_done', set())
    if ar not in done:
        F.emit('lda', 'X%s,XSP+%s' % (F.l2['arr'][ar], hx(ar.slot + F.push))); done.add(ar)

def l2_elem_addr(F, e):
    """`&buf[k]` with buf an L2 array held in a register: 'XIZ+0x10' (after setting the base), else None"""
    x = strip(e.e)
    if x.k != 'index' or fold(x.idx).k != 'const': return None
    ar = local_array_of(x.base)
    if ar is None or ar not in F.l2.get('arr', {}): return None
    l2_array_base(F, ar); off = fold(x.idx).value * x.ty.size; R = 'X' + F.l2['arr'][ar]
    return '%s+%s' % (R, hx(off)) if off else R

def l2_divide(F, e):
    """L2 (_itoa): an unsigned 16-bit u / x or u % x whose divisor is a per-iteration conversion copy: the copy
    (ld DE,BC, once per iteration), the dividend widened in t1 (ld WA,QBC / extz XWA), div XWA,DE; returns the
    family of the result (WA: the quotient, or ld WA,QWA for the remainder)"""
    l, r = strip(e.l), strip(e.r)
    while l.k == 'cast' and l.kind == 'IntegralCast' and strip(l.e).ty.size == l.ty.size: l = strip(l.e)
    cv = getattr(F, 'l2_convs', {}).get(id(r)) if r.k == 'cast' else None
    if cv is None or e.ty.size != 2 or e.ty.signed: return None
    creg = F.l2['conv'][cv]; done = F.l2.setdefault('conv_done', set())
    if cv not in done:
        F.emit('ld', '%s,%s' % (FAM[creg][2], FAM[cv.reg][2])); done.add(cv)
    m = mem_operand(F, l)
    if m is None: return None
    if m != 'WA': F.emit('ld', 'WA,%s' % m)
    F.emit('extz', 'XWA'); F.emit('div', 'XWA,%s' % FAM[creg][2])
    if e.op == '%': F.emit('ld', 'WA,QWA')
    return 'WA'

def gen(F, e, fam, size, then_ret=False, store=False):
    """emit code leaving e's low `size` bytes in register family `fam`; returns the family actually used"""
    e0 = strip(e)
    if RET_ASSIGN and then_ret and fam == 'HL' and e0.k == 'bin' and e0.op == '=' and not getattr(F, 'l2', None) and \
            not getattr(F, 'cl_active', None) and getattr(F, 'u1_i', None) is None and ret_assign(F, e0, size):
        return 'HL'                                    # (stret.c: return L = V)
    if getattr(F, 'l2', None) and e0.k == 'addr' and l2_elem_addr(F, e0) is not None:
        F.emit('lda', '%s,%s' % (FAM[fam][4], l2_elem_addr(F, e0))); return fam   # _itoa: lda XWA,XIZ+0x12
    if getattr(F, 'l2', None) and e0.k == 'bin' and e0.op in ('/', '%'):
        r = l2_divide(F, e0)
        if r is not None:
            if fam != r and size >= 2: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[r][size])); return fam
            return r
    if e0.k == 'cast' and same_size_ptr_cast(e0) is not e0:
        return gen(F, same_size_ptr_cast(e0), fam, size, then_ret, store)
    sx = e0
    while sx.k in ('decay', 'cast') and getattr(sx, 'kind', 'ArrayToPointerDecay') in ('ArrayToPointerDecay', 'NoOp', 'BitCast'):
        sx = strip(sx.e)
    if sx.k == 'string' and size == 4:                               # abi globals.c gl_lit: return "lit" ->
        F.emit('lda', '%s,%s' % (FAM[fam][4], fpgen.string_label(F, sx.value))); return fam   # lda XHL,S2
    if ADDR_GLOBAL_CONST and e0.k == 'addr' and strip(e0.e).k in ('index', 'member') and size == 4 and \
            global_offset(strip(e0.e)) is not None and global_offset(strip(e0.e))[0] != '__param__':
        g = global_offset(strip(e0.e))                       # vp(&gca[4]) -> lda XWA,_gca + 0x4 / push XWA;
        F.emit('lda', '%s,%s' % (FAM[fam][4], '_%s + %s' % g if g[1] != '0x0' else '_%s' % g[0]))   # gpi = &gia[5]
        return fam
    if e0.k == 'addr' and strip(e0.e).k == 'var' and size == 4:      # _log: frexp(x / SQRT2, &nptr) ->
        d = strip(e0.e).decl; R = FAM[fam][4]                          # lda XWA,XSP+0x68 / push XWA
        if d.kind == 'global': F.emit('lda', '%s,_%s' % (R, d.name)); return fam
        off = getattr(d, 'slot', None) if d.kind == 'local' else (getattr(d, 'slot', None) or getattr(d, 'off', None))
        if off is not None:
            F.emit('lda', '%s,%s' % (R, 'XSP+%s' % hx(off + F.push) if off + F.push else 'XSP')); return fam
    if e0.k == 'bin' and e0.op in CC_S and fpgen.is_fp(strip(e0.l).ty):
        fpgen.compare(F, e0, True); return move_to(F, FAM['HL'][size] if size in FAM['HL'] else 'HL', fam, size)
    if e0.k == 'un' and e0.op == '!' and fpgen.is_fp(strip(e0.e).ty):
        fpgen.truth(F, e0.e, False); return move_to(F, FAM['HL'][size], fam, size)      # d_not: ld BC,0x4
    if e0.k == 'cast' and e0.kind == 'FloatingToIntegral':
        off = fpgen.to_int(F, e0, size)                     # d_to_i: ... cal ._fld_ld / ld XHL,(XSP+0x4)
        F.emit('ld', '%s,%s' % (FAM[fam][4], fpgen.slot_mem(F, off))); return fam
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
        if d is not None and d.reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, lv) and rm is not None and \
                d not in getattr(F, 'no_inplace', ()):
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
        if size == 4 and inner.k == 'un' and inner.op == '-' and isz == 2 and strip(inner.e).k == 'cast' and \
                strip(strip(inner.e).e).ty is not None and strip(strip(inner.e).e).ty.size == 1 and \
                not strip(strip(inner.e).e).ty.signed and strip(strip(inner.e).e).k == 'load' and \
                (mem_operand(F, strip(strip(inner.e).e)) or '').startswith('(') and fam in FAM and 1 in FAM[fam]:
            B1 = FAM[fam][1]                               # r4_00_12: gl = (long)-guca[2] -> ld A,(_guca+0x2) / neg A /
            F.emit('ld', '%s,%s' % (B1, mem_operand(F, strip(strip(inner.e).e))))   # ld W,0x0 / extz XWA: V4.23
            F.emit('neg', B1)                              # negates the byte and zero-extends it (not C; imitated)
            F.emit('ld', '%s,0x0' % B1.replace('L', 'H').replace('A', 'W').replace('C', 'B').replace('E', 'D'))
            F.emit('extz', FAM[fam][4]); return fam
        if isz == 1 and size == 4 and not inner.ty.signed and F.opt and family_of(mem_operand(F, inner) or ''):
            F.emit('ld', '%s,%s' % (FAM[fam][1], mem_operand(F, inner)))   # .cast_uc_l under O3XSXr
            F.emit('ld', '%s,0x0' % FAM[fam][1].replace('L', 'H').replace('A', 'W').replace('C', 'B').replace('E', 'D'))
            F.emit('extz', FAM[fam][4]); return fam
        if isz == 1 and size == 4 and not inner.ty.signed and mem_operand(F, inner):
            # unsigned char to long: clear, then load the byte (cast_uc_l)
            F.emit('ld', '%s,0x0' % FAM[fam][4]); F.emit('ld', '%s,%s' % (FAM[fam][1], mem_operand(F, inner)))
            return fam
        il = strip(inner.l) if getattr(inner, 'narrowed', False) else None
        ilr = regvar_of(il.e) if il is not None and il.k == 'load' else None
        onebit = il is not None and inner.op == '|' and fold(inner.r).k == 'const' and fold(inner.r).value and \
            fold(inner.r).value & (fold(inner.r).value - 1) == 0
        if CHAR_NARROW and isz == 1 and size == 2 and not F.opt and ilr is not None and \
                ilr.reg in ('WA', 'BC', 'DE', 'HL') and ilr.reg != fam and dies_here(F, il) and not onebit:
            f2 = gen(F, inner, ilr.reg, 1)     # chnarrow.c under -Xr, c in A: sub A,0x30 / ld L,A / exts HL (a char
            F.emit('ld', '%s,%s' % (FAM[fam][1], FAM[f2][1]))   # result, binop_c.c add_c_pp, stays ld L,A / add L,C;
            F.emit('exts' if inner.ty.signed else 'extz', FAM[fam][2]); return fam   # c | 0x20: ld L,A / set 0x5,L)
        if CHAR_NARROW and isz == 1 and size == 2 and not F.opt and fam != 'WA' and getattr(inner, 'narrowed', False) \
                and inner.op in ('+', '-') and fold(inner.r).k == 'const' and strip(inner.l).k == 'load' and \
                (mem_operand(F, inner.l) or '').startswith('('):
            f2 = gen(F, inner, 'WA', 1)        # chnarrow.c cn_sub_k (no -O): ld A,(XSP+0x4) / sub A,0x30 / ld L,A /
            F.emit('ld', '%s,%s' % (FAM[fam][1], FAM[f2][1]))   # exts HL (& | and a char operand work in L; a char
        else:
            f2 = gen(F, inner, fam, isz)       # result, binop_c.c add_c_pk, too)
            if isz >= size and f2 in FAM and f2 != fam: return f2   # (the value stayed where the chain built it)
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
        if F.adecl and NEG_FREE_FAM and fam not in ('WA', 'BC', 'DE', 'HL') and 'WA' in live_regs(F) and size <= 2:
            W_ = free_reg(F, avoid={'WA'})                 # r2_01_01: int t = -gi2 with a in WA -> ld BC,(_gi2) /
            gen(F, e.e, W_, size); F.emit('neg' if e.op == '-' else 'cpl', FAM[W_][size])   # neg BC / ld IZ,BC
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[W_][size])); return fam
        f_ = gen(F, e.e, fam, size)
        if f_ in FAM and size in FAM[f_] and f_ != fam and FAM[f_][size] != FAM[fam][size]: fam = f_   # (r3_09_14)
        R = FAM[fam][size]
        if size == 4:                          # neg_l: cpl HL / cpl QHL / inc 1,XHL
            F.emit('cpl', FAM[fam][2]); F.emit('cpl', Q[fam])
            if e.op == '-': F.emit('inc', '0x1,%s' % R)
        else:
            F.emit('neg' if e.op == '-' else 'cpl', R)
        return fam
    if e.k == 'bin' and e.op in ('==', '!=') and and_truth(F, e, fam) is not None: return fam
    if e.k == 'bin' and e.op == '=' and not fpgen.is_fp(e.ty):
        return gen_assign_value(F, e, fam, size)
    if e.k == 'bin' and e.op in CC_S:
        F.cmp_as_value = True                            # (cmpord.c cv_l_NK: !gi < 7 keeps the 7 as a value)
        try: cc = gen_compare(F, e)
        finally: F.cmp_as_value = False
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
    if e.k == 'bin' and e.op in ('&&', '||') and has_helper_call(e) and not getattr(F, 'preset_hl', False):
        R = FAM[fam][2]                              # _ispunct: return isascii(c) && !isalnum(c) && ...: a call
        lfalse, lend = F.newulabel(), F.newulabel()  # replaces HL, so no preset: ... j ne,L1 / ld HL,0x1 / j L2 /
        gen_cond_false(F, e, lfalse)                 # L1: ld HL,0x0 / L2:
        F.emit('ld', '%s,0x1' % R); F.emit('j', lend)
        F.lines.append(lfalse + ':'); F.emit('ld', '%s,0x0' % R); F.lines.append(lend + ':'); return fam
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
            F.emit('ret', INV[cc]) if then_ret and not (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)) else \
                F.emit('j', '%s,%s' % (INV[cc], lelse))
            if size == 4:                            # _labs: cpl HL / cpl QHL / inc 0x1,XHL
                F.emit('cpl', FAM[fam][2]); F.emit('cpl', Q[fam])
                if a.op == '-': F.emit('inc', '0x1,%s' % R)
            else: F.emit('neg' if a.op == '-' else 'cpl', R)
            F.lines.append(lelse + ':'); F.lines.append(lend + ':'); return fam
    if e.k == 'cond' and F.opt and not getattr(F, 'cw_plain_cond', False):   # (a compare operand keeps the plain form)
        c, a, b = strip(e.c), strip(e.a), strip(e.b)
        truth = False
        if TERN_TRUTH_PRE and c.k == 'load' and strip(c.e).k == 'var' and c.ty.kind == 'int' and c.ty.size == 2:
            from frontend import N                   # chnarrow.c cn_tern under -O3 -XS: k ? c - 32 : c as k != 0
            c = N('bin', op='!=', l=c, r=N('const', value=0, ty=c.ty), ty=e.ty)   # (ld L,(c) / cpw (k),0x0 / ...)
            truth = True
        def _opd(x):
            x = strip(x)
            return x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).k == 'bin'
        bsz = 1 if size == 2 and byte_arms(e) is not None and (_opd(a) or _opd(b)) else size   # (char arms with a
                                                     # char operation: measured as bytes, cn_tern; cn_tern_cc's two
                                                     # loads keep the plain form)
        def simple(x):
            x = strip(narrow(x, bsz))
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
            elif truth and not (mem_operand(F, strip(narrow(pre, bsz))) or '').startswith('('):
                pre = None                                 # (_atoi: neg ? -n : n with n in IY keeps the plain form)
        else: pre = None
        def char_valued(x):                                # an int built only from chars and small constants
            x = strip(x)
            if fold(x).k == 'const': return fold(x).value is not None and -128 <= fold(x).value <= 127
            if x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == 1: return True
            if x.k == 'bin' and x.op in ('+', '-', '&', '|', '^'): return char_valued(x.l) and char_valued(x.r)
            return False
        def binish(x):                                     # (char_narrow writes (int)(*s1 - *s2) as a cast)
            x = strip(x)
            return x.k == 'bin' or x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).k == 'bin'
        narrow_ok = pre is not None and size == 2 and char_valued(a) and char_valued(b) and (binish(a) or binish(b))
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
                n_pre = len(F.lines)
                gen(F, pre, fam, 1 if narrow_ok else size)
                n_cmp = len(F.lines)
                cc = gen_compare(F, c)
                if cc in (True, False): raise Unsupported('constant ?: condition')
                if TERN_PRE_GUARD and clobbers(F.lines[n_cmp:], '(%s)' % FAM[fam][4]):
                    del F.lines[n_pre:]                    # (-O3 -XS -Xr r1_05_05: the condition reads gla[t] through
                    raise Unsupported('?: arm loaded over its condition')   # XWA: the preloaded arm was wrong code)
            jcc = INV[cc] if not pre_then else cc
            if narrow_ok:                                  # _strncmp: ... j eq,L5 / ... / ld L,A / L5: exts HL
                F.emit('j', '%s,%s' % (jcc, lend))
                o = strip(narrow(other, 1))
                pv = strip(narrow(pre, 1))
                same = o.k == 'bin' and o.op in SIMPLE_OPS and pv.k == 'load' and strip(pv.e).k == 'var' and \
                    strip(o.l).k == 'load' and strip(strip(o.l).e).k == 'var' and strip(strip(o.l).e).decl is strip(pv.e).decl
                try:
                    if same and operand(F, o.r, 1) is not None:   # cn_tern: the pre arm loaded c -> sub L,0x20 in place
                        rc_ = fold(o.r)
                        if o.op in '+-' and rc_.k == 'const' and 1 <= rc_.value <= 8:
                            F.emit('inc' if o.op == '+' else 'dec', '%s,%s' % (hx(rc_.value), FAM[fam][1]))
                        else: F.emit(SIMPLE_OPS[o.op], '%s,%s' % (FAM[fam][1], operand(F, o.r, 1)))
                    elif o.k == 'bin' and fam != 'WA':
                        f2 = gen(F, o, 'WA', 1); F.emit('ld', '%s,%s' % (FAM[fam][1], FAM[f2][1]))
                    else: gen(F, o, fam, 1)
                finally:
                    if tmpv: tmpv[0].reg = tmpv[1]
                if not pre_then: F.lines.append(lskip + ':')   # (cn_tern, the else arm first: L2: / L1: as in the
                F.lines.append(lend + ':')                     # plain pre form; _strncmp's then arm: one label)
                sg = byte_arms(e)
                F.emit('exts' if (sg if sg is not None else e.ty.signed) else 'extz', FAM[fam][2]); return fam
            F.emit('ret', jcc) if then_ret and not (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)) else \
                F.emit('j', '%s,%s' % (jcc, lend))         # (r2_00_13: ret ne before pop XIZ was wrong code)
            try: gen(F, other, fam, size)
            finally:
                if tmpv: tmpv[0].reg = tmpv[1]
            F.lines.append(lskip + ':'); F.lines.append(lend + ':'); return fam
    bs = byte_arms(e) if e.k == 'cond' and size == 2 else None
    if bs is not None:                               # chnarrow.c cn_tern: k ? c - 32 : c -> ... / ld L,A / j L1 /
        lelse, lend = F.newulabel(), F.newulabel()   # L2: ld L,(XSP+0x4) / L1: exts HL (cn_tern_cc too)
        gen_cond_false(F, e.c, lelse)
        def arm(x):
            x = strip(narrow(x, 1))
            xl = strip(x.l) if getattr(x, 'narrowed', False) else None
            xreg = regvar_of(xl.e) if xl is not None and xl.k == 'load' else None
            if not F.opt and fam != 'WA' and getattr(x, 'narrowed', False) and x.op in ('+', '-') and \
                    fold(x.r).k == 'const' and ((mem_operand(F, x.l) or '').startswith('(') or
                                                xreg is not None and xreg.reg == 'WA'):   # (-Xr: c in A, sub A,0x20)
                f2 = gen(F, x, 'WA', 1); F.emit('ld', '%s,%s' % (FAM[fam][1], FAM[f2][1]))   # (ld A,.. / sub A,0x20 /
            else: gen(F, x, fam, 1)                                                          # ld L,A, as a return)
        F.cond_joins = getattr(F, 'cond_joins', set()) | {lend}
        dead0 = set(F.dead); arm(e.a); F.dead = dead0; F.emit('j', lend); F.lines.append(lelse + ':')
        arm(e.b); F.lines.append(lend + ':')
        F.emit('exts' if bs else 'extz', FAM[fam][2]); return fam
    if e.k == 'cond':                                # c_tern
        lelse, lend = F.newulabel(), F.newulabel()
        gen_cond_false(F, e.c, lelse)
        if (F.opt or TERN_ARM_WA) and (strip(e.a).k == 'bin' or strip(e.a).k == 'un' and strip(e.a).op in ('-', '~')) \
                and fam != 'WA':                     # (chnarrow.c cn_tern_i without -O too: ld WA,(c) / sub WA,0x20)
            # _toupper: ld WA,IZ / sub WA,0x20 / ld HL,WA / j L2; _atoi: ld WA,IY / neg WA / ld HL,WA
            f2 = gen(F, e.a, 'WA', size); F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[f2][size]))
        else:
            pend0 = F.pending
            dead0 = set(F.dead); fa_ = gen(F, e.a, fam, size); F.dead = dead0   # (the arms are exclusive: cn_tern_i)
            if fa_ != fam and fa_ in FAM and size in FAM[fa_]: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[fa_][size]))
            if F.pending != pend0: flush_pops(F)         # (r3_08_13: an arm's own call pops inside the arm)
        F.cond_joins = getattr(F, 'cond_joins', set()) | {lend}
        F.emit('j', lend); F.lines.append(lelse + ':')
        pend0 = F.pending
        fb_ = gen(F, e.b, fam, size)
        if fb_ != fam and fb_ in FAM and size in FAM[fb_]: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[fb_][size]))   # r2_09_13
        if F.pending != pend0: flush_pops(F)
        F.lines.append(lend + ':'); return fam
    if e.k == 'un' and e.op == '!':
        x = strip(e.e); xs = x.ty.size; m = mem_operand(F, x)
        if m in ('A', 'WA', 'BC', 'DE', 'HL', 'C', 'E', 'L'):                 # .lnot_i: cp WA,0x0
            F.emit('cp', '%s,0x0' % m)
        elif NOT_MEMBER_CP and x.k == 'load' and strip(x.e).k == 'member' and strip(x.e).arrow and xs <= 2 and \
                strip(strip(x.e).base).k == 'load' and strip(strip(strip(x.e).base).e).k == 'var' and \
                strip(strip(strip(x.e).base).e).decl.kind == 'global' and not member_offset(strip(x.e)):
            F.emit('ld', 'XWA,(_%s)' % strip(strip(strip(x.e).base).e).decl.name)   # random r1_06_01: !gps->c ->
            F.emit('cp%s' % ('b' if xs == 1 else 'w'), '(XWA),0x0')                  # ld XWA,(_gps) / cpb (XWA),0x0
        elif xs == 4 or m is None:               # lnot_l: ld XWA,x / or XWA,XWA
            f_ = gen(F, x, 'WA', xs); W = FAM[f_ if f_ in FAM and xs in FAM[f_] else 'WA'][xs]
            if xs == 4: F.emit('or', '%s,%s' % (W, W))   # (random r1_00_05: !(k * gl2) tests the helper's XHL; r1_09_14:
            else: F.emit('cp', '%s,0x0' % W)     # !(gs.l << n) the shifted XBC: XWA was wrong code; r1_01_18: a loaded
                                                 # word is compared, ld WA,(XWA+0x12) / cp WA,0x0)
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
        pv = strip(inc.e)
        if g is None and pv.k == 'var' and not getattr(pv.decl, 'reg', None) and pv.decl.ty.size == 4 and \
                fam != 'WA' and size in FAM.get(fam, {}):
            sm = lvalue(F, pv)                             # __doprnt: c = *fmt++ with fmt in a slot ->
            if sm.startswith('(XSP'):                      # ld XWA,(XSP+0x52) / ld C,(XWA+:1) / ld (XSP+0x52),XWA
                F.emit('ld', 'XWA,%s' % sm)
                F.emit('ld', '%s,(XWA%s:%d)' % (FAM[fam][size], '+' if inc.op == '++' else '-', pv.decl.ty.base.size))
                F.emit('ld', '%s,XWA' % sm); return fam
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
        T = 'XIZ' if F.call_temp == 'XIZ' else FAM[F.call_temp][2] if F.call_temp == 'IZ' else 'QIZ'   # k_expr: QIZ
        if (T == 'XIZ') != (size == 4): raise Unsupported('a call pair of another size than its temporary')
        gen_call(F, strip(e.r)); F.emit('ld', '%s,%s' % (T, FAM['HL'][size]))
        gen_call(F, strip(e.l)); flush_pops(F)              # k_expr: inc 0x4,XSP before add HL,IZ (none too)
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
    if e.k == 'addr' and strip(e.e).k == 'index':
        r_ = chidx.ptr_sum(F, e, fam)                      # &gia[c] with a char c (probes/chidx.c ec1 / ec2 / eu2)
        if r_ is not None: return r_
    if e.k == 'addr' and strip(e.e).k == 'index' and ADDR_ELEM_REG:
        x = strip(e.e); b = strip(x.base); ii = unpromote(x.idx)
        iv = regvar_of(ii.e) if ii.k == 'load' else None
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and x.ty.size == 1 and \
                iv is not None and iv.ty.size == 2 and iv.reg in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ') and fam == 'WA' \
                and iv.ty.signed:                          # (r3_07_07: an unsigned index is zero-extended whole)
            touch_home(F, iv)                              # (r3_07_07: the home is loaded first; r3_04_06: a return
            X = FAM[fam][4]                                # random r1_00_00: char *u = &gca[t], t in IZ ->   zero-extends)
            F.emit('lda', '%s,_%s' % (X, b.decl.name))     # lda XWA,_gca / lda XWA,XWA+IZ
            F.emit('lda', '%s,%s+%s' % (X, X, FAM[iv.reg][2])); return fam
    if ADDR_ELEM_WA and e.k == 'addr' and strip(e.e).k == 'index' and fam == 'WA' and not F.opt and size == 4:
        x = strip(e.e); b = strip(x.base); ib = strip(x.idx)  # random r1_09_00: gpi = &gia[t] -> ld WA,IZ / add WA,WA /
        while ib.k == 'cast' and ib.kind == 'IntegralCast': ib = strip(ib.e)   # lda XBC,_gia / exts XWA / add XWA,XBC;
        im = mem_operand(F, ib) if ib.k == 'load' else None   # r1_03_02: &gca[u], u a char in E -> ld A,E / extz WA
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and im is not None and \
                x.ty.size in (1, 2, 4) and 'BC' not in live_regs(F) and \
                (ib.ty.size == 2 and ib.ty.signed or ib.ty.size == 1) and family_of(im) != 'XBC':
            if ib.ty.size == 1:                           # a char index (r4_00_04: &gia[t], t a char in QIZH ->
                if x.ty.size == 4: raise Unsupported('the address of a long element at a char index')   # ld A,QIZH /
                if im != 'A': F.emit('ld', 'A,%s' % im)   # add A,QIZH / lda XBC,_gia / exts WA / exts XWA / add XWA,XBC:
                if x.ty.size == 1 or not ib.ty.signed:   # doubled in the byte; r1_03_02: &gca[u] -> ld A,E / extz WA;
                    F.emit('exts' if ib.ty.signed else 'extz', 'WA')   # an unsigned char is extended first and doubled
                    if x.ty.size == 2: F.emit('add', 'WA,WA')          # in the word (r3_02_09: ld A,(b) / extz WA /
                else: F.emit('add', 'A,%s' % ('A' if im == 'A' else im))   # add WA,WA / lda XBC,_gia / exts XWA)
                F.emit('lda', 'XBC,_%s' % b.decl.name)
                if x.ty.size == 2 and ib.ty.signed: F.emit('exts', 'WA')
                F.emit('exts', 'XWA'); F.emit('add', 'XWA,XBC'); return fam
            if im != 'WA': F.emit('ld', 'WA,%s' % im)
            if x.ty.size == 2: F.emit('add', 'WA,WA')
            elif x.ty.size == 4: F.emit('sla', '0x2,WA')
            F.emit('lda', 'XBC,_%s' % b.decl.name); F.emit('exts', 'XWA'); F.emit('add', 'XWA,XBC'); return fam
    if e.k == 'addr' and strip(e.e).k == 'index' and fam != 'WA':
        x = strip(e.e); b = strip(x.base); ii = strip(x.idx)
        while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
        im = mem_operand(F, ii)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and im is not None and ii.ty.size == 2:
            R2 = FAM[fam][2]; X = FAM[fam][4]                 # m_addr: &ga[i] -> ld HL,(i) / add HL,HL / lda XWA,_ga /
            if not ii.ty.signed and not F.adecl:             # extz XHL / add XHL,XWA (-Xr: ld HL,WA)
                if im != 'WA': F.emit('ld', 'WA,%s' % im)    # r4_01_02: &gia[b], unsigned b -> ld WA,(b) / extz XWA /
                F.emit('extz', 'XWA'); scale32(F, 'XWA', x.ty.size)   # add XWA,XWA / lda XHL,_gia / add XHL,XWA
                F.emit('lda', '%s,_%s' % (X, b.decl.name)); F.emit('add', '%s,XWA' % X); return fam
            if im != R2: F.emit('ld', '%s,%s' % (R2, im))
            scale_reg(F, R2, x.ty.size, 'sla')
            B_ = 'XWA'; ext_ = 'extz'
            if F.adecl and 'WA' in live_regs(F) and fam != 'WA' and not dies_here(F, ii):   # (m_addr: i dies -> XWA / extz)
                B_ = FAM[free_reg(F, avoid={'WA', fam})][4]; ext_ = 'exts' if ii.ty.signed else 'extz'   # r2_06_17: a stays
            F.emit('lda', '%s,_%s' % (B_, b.decl.name)); F.emit(ext_, X); F.emit('add', '%s,%s' % (X, B_)); return fam
    if e.k == 'bin':
        return gen_bin(F, e, fam, size, then_ret, store)
    raise Unsupported(e.k)

CALL_RIGHT_FIRST = True                                   # see gen_bin
EVORDER = True                                            # see evorder_bin

def ev_uncast(x):
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty is not None and strip(x.e).ty.size == x.ty.size:
        x = strip(x.e)
    return x

def ev_addr_kind(F, x):
    """'P' for *p and p->m with p a pointer variable in memory, 'X' for g[i] with g a global array and i an int in
    memory (the operands whose address needs registers), else None"""
    x = ev_uncast(x)
    if x.k != 'load': return None
    v = strip(x.e)
    if v.k == 'deref' or (v.k == 'member' and v.arrow):
        pv = strip(v.e if v.k == 'deref' else v.base)
        if pv.k == 'load' and strip(pv.e).k == 'var' and not getattr(strip(pv.e).decl, 'reg', None) and \
                mem_operand(F, pv) is not None and (mem_operand(F, pv) or '').startswith('('): return 'P'
        return None
    if v.k == 'index':
        b = strip(v.base); ii = ev_uncast(v.idx)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and fold(ii).k != 'const' and \
                ii.ty is not None and ii.ty.size == 2 and ii.k == 'load' and strip(ii.e).k == 'var' and \
                not getattr(strip(ii.e).decl, 'reg', None) and v.ty.size in (2, 4) and \
                (mem_operand(F, ii) or '').startswith('('): return 'X'
    return None

def ev_left_kind(F, x):
    """'wa' when the left's own code needs WA (! and unary - go through WA, a shift's count is in A), 'idx' for an
    indexed element (index in WA, base in XBC), else 'plain'"""
    x = ev_uncast(x)
    if x.k == 'un' and x.op in ('!', '-'): return 'wa'
    if x.k == 'bin' and x.op in ('<<', '>>') and fold(x.r).k != 'const': return 'wa'
    return 'idx' if ev_addr_kind(F, x) == 'X' else 'plain'

def ev_address(F, x, P, I, B):
    """emit the address setup of an addressed operand (ev_addr_kind) with the pointer in P, or the index in I and
    the array in B; return the operand string"""
    x = ev_uncast(x); v = strip(x.e)
    if v.k in ('deref', 'member'):
        pv = strip(v.e if v.k == 'deref' else v.base)
        F.emit('ld', '%s,%s' % (P, mem_operand(F, pv)))
        off = member_offset(v) if v.k == 'member' else 0
        return '(%s+%s)' % (P, hx(off)) if off else '(%s)' % P
    b = strip(v.base); ii = ev_uncast(v.idx)
    F.emit('ld', '%s,%s' % (I, mem_operand(F, ii)))
    if not ii.ty.signed:                                   # an unsigned index is extended whole (UIDX32; r2_01_11:
        XI = 'X' + I                                       # gua[a] -> ld WA,(a) / extz XWA / add XWA,XWA / ld XBC,_gua /
        F.emit('extz', XI)                                 # add XBC,XWA / (XBC))
        if v.ty.size == 2: F.emit('add', '%s,%s' % (XI, XI))
        else: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[v.ty.size]), XI))
        F.emit('ld', '%s,_%s' % (B, b.decl.name)); F.emit('add', '%s,%s' % (B, XI))
        return '(%s)' % B
    if v.ty.size == 2: F.emit('add', '%s,%s' % (I, I))
    else: F.emit('sla', '%s,%s' % (hx({4: 2, 8: 3}[v.ty.size]), I))
    F.emit('lda', '%s,_%s' % (B, b.decl.name))
    return '(%s+%s)' % (B, I)

def ev_core(x):
    """the operand under every integral cast (a widened !x is still a ! for the WA rule)"""
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
    return x

def ev_class(F, x):
    """the operand classes of V4.23's binary operators (probes/evorder.c): 'K' a constant; 'G' a plain variable (a
    symbol or slot operand, or a register variable); 'A' an addressed operand (a struct member or constant-index
    element, whose symbol carries an offset, or *p, p->m, g[i], whose address needs registers); 'V' a value that
    needs computing (! - a shift, a + - & | ^ of operands, a ?:)"""
    x = ev_uncast(x)
    if fold(x).k == 'const': return 'K'
    if x.k == 'cast' and x.kind == 'IntegralCast': return 'V' if ev_class(F, x.e) is not None else None   # (el_s_GN: !hl widened)
    if x.k == 'load':
        v = strip(x.e)
        if v.k == 'var': return 'G'
        if ev_addr_kind(F, x) is not None: return 'A'
        m = mem_operand(F, x)
        if m is not None and m.startswith('(') and (v.k == 'member' and not v.arrow or v.k == 'index'): return 'A'
        return None
    if x.k == 'un' and x.op in ('!', '-'): return 'V'
    if x.k == 'bin' and (x.op in SIMPLE_OPS or x.op in ('<<', '>>')): return 'V'
    if x.k == 'cond': return 'V'
    return None

def ev_natural_wa(F, x):
    """the operand's own code needs WA: ! and unary - compute there, a shift's count is in A, an element's index"""
    x = ev_core(x)
    if x.k == 'un' and x.op == '!': return not F.opt       # -O: scc eq,HL directly (s_NB O3XS)
    if x.k == 'un' and x.op == '-': return True
    if x.k == 'bin' and x.op in ('<<', '>>') and fold(x.r).k != 'const': return True
    return False

def ev_unfitted_pair(F, l, r):
    """two operands V4.23 pairs in a way the rule has not fitted: two indexed elements, a shift by a variable
    beside an indexed or addressed operand, or (under -Xr) an indexed element whose index is a register parameter
    beside an addressed operand (semcheck found the older paths wrong there: evorder.c at -O3 -XS and -Xr)"""
    def kind(x):
        x = ev_uncast(x)
        if x.k == 'bin' and x.op in ('<<', '>>') and fold(x.r).k != 'const': return 'S'
        if x.k != 'load': return None
        v = strip(x.e)
        if v.k == 'index' and fold(v.idx).k != 'const': return 'X'
        if v.k == 'deref' or (v.k == 'member' and v.arrow): return 'P'
        return None
    kl, kr = kind(l), kind(r)
    if F.adecl and ((kl in ('S', 'X') and (kr is not None or ev_class(F, r) == 'V')) or
                    (kr in ('S', 'X') and (kl is not None or ev_class(F, l) == 'V'))): return True   # (el_s_NS -Xr)
    if kl is None or kr is None: return False
    return 'S' in (kl, kr) or 'X' in (kl, kr)

CMP_ORDER = True                                          # see cmp_order
CMP_WIDE = True                                           # see cmp_wide
CMP_WIDE_OPT = True                                       # cmp_wide under -O too (553 of cmpordl.c's 680 forms are the same)
BIN_WIDE = True                                           # see bin_wide
CHAR_ARG_ANY = True                                       # any computed char argument: into A, exts WA / push WA (push_arg)
CALL_FOLD_GUARD = True                                    # call_before_use: a read after a call in the same statement
CHAR_REG_INDEX = True                                     # a char element at a register index: (XWA+IZ) (elem_addr)
IZ_HOMES = ('IZ', 'QIZ', 'XIZ', 'QIZH')                   # homes the WA..HL rules never write (cmp_wide, bin_wide hooks)
SP_INDEX_IZ = True                                        # sp_plain_index accepts an IZ home
ADDR_ELEM_WA = True                                       # &garr[i] into XWA: ld WA,(i) / add WA,WA / lda XBC,_garr / exts XWA / add XWA,XBC
UNUSED_LOCAL_INIT = True                                  # a local with an initialiser and no use: cc900 still computes it into WA

def cw_explicit_widening(x):
    """an explicit cast that widens: cc900 keeps it as a conversion ((long)gc < 7L: exts WA / exts XWA / cp XWA,0x7),
    where an implicit promotion compares at the narrower width"""
    x = strip(x)
    return x.k == 'cast' and x.kind == 'IntegralCast' and getattr(x, 'explicit', False) and x.ty is not None and \
        strip(x.e).ty is not None and strip(x.e).ty.size < x.ty.size

def cw_char_derived(x):
    """x computes from signed chars and small constants only (!c, -c, c - d, i ? c : d, a call returning char), so that
    cc900 compares it at the byte although C promotes it to int (cmpordl.c cc_l_UG: ld A,(_gc) / neg A / cp A,(_hc));
    an explicit widening cast is a conversion, not a promotion"""
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast':
        if cw_explicit_widening(x): return False
        if getattr(x, 'explicit', False) and x.ty is not None and x.ty.size == 1 and strip(x.e).ty is not None and \
                strip(x.e).ty.size > 1: return True        # ((unsigned char)hul: cc900 compares the byte)
        x = strip(x.e)
    if x.k == 'const': return x.value is not None and -128 <= x.value <= 127
    if x.k == 'load': return x.ty is not None and x.ty.size == 1 and x.ty.signed
    if x.k == 'call': return x.ty is not None and x.ty.size == 1 and x.ty.signed
    if x.k == 'un' and x.op in ('-', '!'): return cw_char_derived(x.e)
    if x.k == 'bin' and x.op in ('+', '-', '&', '|', '^'): return cw_char_derived(x.l) and cw_char_derived(x.r)
    if x.k == 'cond': return cw_char_derived(x.a) and cw_char_derived(x.b)
    return False

def _cw_load_raw(F, k, size, base='XBC', idx='WA'):
    """load an operand of kind G / M / P / D / X into XWA / A and return the register (the == rule's right side:
    ld XWA,(_hpl) / ld XWA,(XWA); ld WA,(c) / sla 0x2,WA / lda XBC,_hla / ld XWA,(XBC+WA); size 1: lda XWA,_hca /
    ld BC,(c) / extz XBC / add XBC,XWA / ld A,(XBC))"""
    R = {4: 'XWA', 2: 'WA', 1: 'A'}[size]
    if k[0] in ('G', 'M'): F.emit('ld', '%s,%s' % (R, k[1])); return R
    if k[0] in ('P', 'D'):
        F.emit('ld', 'XWA,%s' % k[1]); F.emit('ld', '%s,%s' % (R, '(XWA+%s)' % hx(k[2]) if k[2] else '(XWA)')); return R
    if k[0] == 'X':
        if size == 1:
            if len(k) == 5 or k[2] == 'IZ':
                if len(k) == 5: cw_regidx_ok(F, k)
                if base[1:] == k[2]: raise cw_base_clash(k)
                F.emit('lda', '%s,%s' % (base, k[1])); F.emit('ld', 'A,(%s+%s)' % (base, k[2])); return 'A'
            I = base[1:]
            F.emit('lda', 'XWA,%s' % k[1]); F.emit('ld', '%s,%s' % (I, k[2])); F.emit('extz', base); F.emit('add', '%s,XWA' % base)
            F.emit('ld', 'A,(%s)' % base); return 'A'
        if len(k) == 5 and base[1:] == idx: raise cw_base_clash(k)
        ldidx(F, k, idx); scale_reg(F, idx, size, 'sla' if size == 4 else 'add'); F.emit('lda', '%s,%s' % (base, k[1]))
        F.emit('ld', '%s,(%s+%s)' % (R, base, idx)); return R
    raise Unsupported('cw_load %s' % k[0])

def bin_wide(F, e, op, l, r, fam, size):
    """a binary operation with an addressed operand (a deref, a member through a pointer, an element) or a call, after
    corpus/probes/evorder_ad.c (run 2026-11-10-17-micro-evorder_ad).  The right's address is taken first and the left
    loads (ld XBC,(_hpi) / ld WA,(_gi) / sub WA,(XBC); an element: ld BC,(c) / add BC,BC / lda XDE,_hia / (XDE+BC)), a
    left pointer's own load before it (ld XWA,(_gpi) / ld XBC,(_hpi) / ld WA,(XWA) / sub WA,(XBC)), a left element with
    its index in WA and the right pointer in XDE.  A commutative operation whose both sides are addressed (a static
    member counts, a plain global does not) loads the RIGHT and keeps the left as the memory operand, its address first
    (ld XBC,(_gpi) / ld XWA,(_hpi) / ld WA,(XWA) / add WA,(XBC); ld XBC,(_gps) / ld WA,(c) / add WA,WA / lda XDE,_hia /
    ld WA,(XDE+WA) / add WA,(XBC+0x2)).  A call comes first and is the accumulator (cal _gfi / sub HL,(_hi); cal _hfi /
    add HL,(_gi)); a deref against it loads into WA (ld WA,(XWA) / add WA,HL); a multiply or divide moves it to WA
    (ld WA,HL / muls XWA,(_hi)).  Multiply: muls XWA,(mem); with a member through a pointer the pointer in XWA and the
    accumulator BC (ld XWA,(_hps) / ld BC,(_gi) / muls XBC,(XWA+0x2)).  Divide: exts XWA / divs XWA,(mem), a constant
    dividend as ld XWA,0x7 without the extension, a remainder's ld WA,QWA (ld WA,QBC from the BC accumulator).  Chars
    the same at the byte (ld A,(_gc) / sub A,(XBC); exts WA / divs WA,(_hc)); a constant left loads the right (ld A,(_hc)
    / inc 0x7,A).  Returns the register family of the result, or None where the pair is not in the table."""
    lk, rk = cw_kind(F, l, size), cw_kind(F, r, size)
    if lk is None or rk is None: return None
    L, R = lk[0], rk[0]
    if getattr(F, 'bw_any', False):                        # a pushed argument (random corpora: ld A,(b) / extz WA /
        F.bw_any = False                                   # add WA,WA / lda XBC,_gia / ld DE,(_gi) / sub DE,(XBC+WA) /
        if not (L in ('G', 'M', 'K') and R == 'X' and op == '-' and len(rk) == 4): return None   # push DE)
        if any(r_ in ('WA', 'BC', 'DE') for r_ in live_regs(F)): return None
        a = cw_addr(F, rk, size, P='XBC', I='WA', B='XBC')
        V = FAM['DE'][size]
        F.emit('ld', '%s,%s' % (V, hx(fold(l).value & ((1 << 8 * size) - 1)) if L == 'K' else lk[1]))
        F.cw_opline = len(F.lines); F.emit('sub', '%s,%s' % (V, a)); return 'DE'
    if L not in ('K', 'G', 'M', 'P', 'D', 'X', 'F') or R not in ('K', 'G', 'M', 'P', 'D', 'X', 'F'): return None
    if L == 'K' and R == 'K': return None
    if L == 'F' and R == 'F':                              # (the right's result saved in XIZ: unmodelled; the older
        if size == 4: raise Unsupported('bin_wide: two calls in a long operation')   # path saved a long in IZ: wrong code)
        return None
    addressed = ('P', 'D', 'X', 'F')
    wrem = op == '%' and size == 1                           # (a char remainder is stored from W: ld (_gc2),W)
    if wrem and getattr(F, 'keep_q', False): return None   # (a char local's remainder stays in W: the older path, mod_c_loc)
    if not (L in addressed or R in addressed or size == 1 and (op in ('*', '/') or L == 'K' and op in ('+', '&', '|', '^', '*', '/', '%')
            or L == 'M' and R == 'M' and op in ('+', '&', '|', '^', '*')) or size == 2 and op in ('/', '%') and L == 'K'
            or size == 4 and L == 'K' and op in ('+', '&', '|', '^')):
        return None                                        # (the older paths keep the plain pairs)
    if size == 4 and op in ('*', '/', '%'):                 # the long helpers with a deref operand (evorder_ad.c l_div_GP:
        if not (L == 'P' or R == 'P' or L == 'K' and op != '*') or 'F' in (L, R) or 'D' in (L, R) or 'X' in (L, R) or 'A' in (L, R): return None
        if R == 'K': return None                              # ld XBC,(_hpl) / ld XWA,(_gl) / ld XBC,(XBC) / cal C9H_divls);
        if L == 'K' and op == '*': return None                # (a constant multiplier is strength-reduced)
        if L == 'K' and R in ('G', 'M'):                      # ea_l_div_KG: ld XBC,(_hl) / ld XWA,0x7 / cal C9H_divls
            F.emit('ld', 'XBC,%s' % rk[1]); F.emit('ld', 'XWA,%s' % hx(fold(l).value & 0xffffffff)); F.emit('cal', 'C9H_' + name); return 'HL'
        name = {'*': 'mul', '/': 'div', '%': 'rem'}[op] + ('ls' if (e.ty is None or e.ty.signed) else 'lu')
        def ldk(reg, k, x):
            if k[0] == 'K': F.emit('ld', '%s,%s' % (reg, hx(fold(x).value & 0xffffffff)))
            else: F.emit('ld', '%s,%s' % (reg, k[1]))
        if op == '*' and L == 'P' and R == 'P':               # ea_l_mul_PP: ld XBC,(_gpl) / ld XWA,(_hpl) / ld XWA,(XWA) / ld XBC,(XBC)
            F.emit('ld', 'XBC,%s' % lk[1]); F.emit('ld', 'XWA,%s' % rk[1]); F.emit('ld', 'XWA,(XWA)'); F.emit('ld', 'XBC,(XBC)')
        elif op == '*' and L == 'P' and R == 'M':             # ea_l_mul_PE: ld XBC,(_gpl) / ld XWA,(_hla + 0xc) / ld XBC,(XBC)
            F.emit('ld', 'XBC,%s' % lk[1]); ldk('XWA', rk, r); F.emit('ld', 'XBC,(XBC)')
        elif op == '*' and L == 'M' and R == 'P':             # ea_l_mul_EP: ld XWA,(_hpl) / ld XWA,(XWA) / ld XBC,(_gla + 0xc)
            F.emit('ld', 'XWA,%s' % rk[1]); F.emit('ld', 'XWA,(XWA)'); ldk('XBC', lk, l)
        elif L == 'P' and R == 'P':                           # ea_l_div_PP: ld XWA,(_gpl) / ld XBC,(_hpl) / ld XWA,(XWA) / ld XBC,(XBC)
            F.emit('ld', 'XWA,%s' % lk[1]); F.emit('ld', 'XBC,%s' % rk[1]); F.emit('ld', 'XWA,(XWA)'); F.emit('ld', 'XBC,(XBC)')
        elif R == 'P':                                        # ea_l_div_GP: ld XBC,(_hpl) / ld XWA,(_gl) / ld XBC,(XBC)
            F.emit('ld', 'XBC,%s' % rk[1]); ldk('XWA', lk, l); F.emit('ld', 'XBC,(XBC)')
        elif R == 'M':                                        # ea_l_div_PE: ld XWA,(_gpl) / ld XWA,(XWA) / ld XBC,(_hla + 0xc)
            F.emit('ld', 'XWA,%s' % lk[1]); F.emit('ld', 'XWA,(XWA)'); ldk('XBC', rk, r)
        else:                                                 # ea_l_div_PG: ld XWA,(_gpl) / ld XBC,(_hl) / ld XWA,(XWA)
            F.emit('ld', 'XWA,%s' % lk[1]); ldk('XBC', rk, r); F.emit('ld', 'XWA,(XWA)')
        F.emit('cal', 'C9H_' + name); return 'HL'
    if op in ('/', '%') and R == 'K': return None
    def ret(fam_): return 'W' if wrem and fam_ == 'WA' else fam_
    live = {r_ for r_ in live_regs(F) & {'WA', 'BC', 'DE', 'HL'} if any(
        uses_decl(F.f.body, d_) for d_ in list(F.f.params) + list(F.f.decls) if getattr(d_, 'reg', None) == r_ and d_ not in F.dead)}
    for k_ in (lk, rk):
        if k_[0] == 'X' and len(k_) == 5: live.discard(k_[2])
    if live: return None
    comm = op in ('+', '&', '|', '^', '*')
    sgn = (e.ty is None or e.ty.signed) if size != 1 else all(   # (mul_uc.c: mul WA,(_guc3); div_uc: extz / div)
        unpromote(x).ty is None or unpromote(x).ty.signed for x in (l, r) if fold(x).k != 'const')
    W, H = FAM['WA'][size], FAM['HL'][size]
    XW = FAM['WA'][4]
    mn = {'+': 'add', '-': 'sub', '&': 'and', '|': 'or', '^': 'xor'}.get(op)
    def kimm(x): return hx(fold(x).value & ((1 << 8 * size) - 1))
    def emit_op(acc, src, kv=None):                          # the operation on the accumulator
        F.cw_opline = len(F.lines)
        if op in SIMPLE_OPS:
            if op in ('+', '-') and kv is not None and 1 <= kv <= 8:
                F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(kv), acc)); return
            F.emit(mn, '%s,%s' % (acc, src)); return
        if op == '*':
            F.emit('muls' if sgn else 'mul', '%s,%s' % ({'WA': 'XWA', 'A': 'WA', 'BC': 'XBC', 'C': 'BC', 'HL': 'XHL', 'L': 'HL'}[acc], src)); return
        F.emit('divs' if sgn else 'div', '%s,%s' % ({'WA': 'XWA', 'A': 'WA', 'BC': 'XBC'}[acc], src))
        if op == '%' and size == 2:
            if acc == 'BC': F.emit('ld', 'WA,QBC')
            else: F.emit('ld', 'WA,QWA')
    def ext(acc):                                            # the dividend's extension
        if op in ('/', '%'): F.emit('exts' if sgn else 'extz', {'WA': 'XWA', 'A': 'WA', 'BC': 'XBC'}[acc])
    def ldv(reg, k, x):                                      # a K / G / M operand into reg
        if k[0] == 'K': F.emit('ld', '%s,%s' % (reg, kimm(x)))
        else: F.emit('ld', '%s,%s' % (reg, k[1]))
    def addr(k, P='XBC', I='BC', Bs='XDE'):                  # the address of a P / D / X operand; G / M as they are
        if k[0] in ('P', 'D', 'X'): return cw_addr(F, k, size, P=P, I=I, B=Bs)
        return k[1]
    def kval(k, x): return fold(x).value if k[0] == 'K' else None
    # ---- a call on one side
    if R == 'F' or L == 'F':
        ok_, okind = (l, lk) if R == 'F' else (r, rk)
        f_fam = gen(F, r if R == 'F' else l, 'HL', size)
        if f_fam != 'HL': raise Unsupported('bin_wide: a call result not in HL')
        O = okind[0]
        xi = 'WA' if size != 1 else 'BC'
        if op in SIMPLE_OPS and (comm or L == 'F'):          # the call result is the accumulator (add HL,(_gi); sub HL,(XWA))
            if O == 'M' and comm: F.emit('ld', '%s,%s' % (W, okind[1])); emit_op(W, H); return ret('WA')
            if O in ('K', 'G', 'M'): emit_op(H, kimm(ok_) if O == 'K' else okind[1], kval(okind, ok_)); return 'HL'
            a = addr(okind, P='XWA', I=xi, Bs='XBC')
            if comm: F.emit('ld', '%s,%s' % (W, a)); emit_op(W, H); return ret('WA')   # ea_i_add_PF: ld WA,(XWA) / add WA,HL
            emit_op(H, a); return 'HL'
        if op in SIMPLE_OPS:                                 # a call on the right of a -: the left into WA, sub WA,HL
            if O in ('K', 'G', 'M'): ldv(W, okind, ok_)
            else: F.emit('ld', '%s,%s' % (W, addr(okind, P='XWA', I=xi, Bs='XBC')))
            emit_op(W, H); return ret('WA')
        if op == '*':                                        # ea_i_mul_GF: cal / ld WA,HL / muls XWA,(_gi)
            if O in ('P', 'D', 'X', 'M'):                    # ea_c_mul_PF: cal / ld XWA,(_gp) / ld A,(XWA) / muls WA,L; ea_i_mul_EF
                F.emit('ld', '%s,%s' % (W, addr(okind, P='XWA', I=xi, Bs='XBC'))); emit_op(W, H); return ret('WA')
            F.emit('ld', '%s,%s' % (W, H)); emit_op(W, kimm(ok_) if O == 'K' else okind[1]); return ret('WA')
        if L == 'F' and O == 'D' and size == 2:              # ea_i_div_FD: cal / ld XWA,(_hps) / ld BC,HL / exts XBC / divs XBC,(XWA+0x2)
            F.emit('ld', 'XWA,%s' % okind[1]); F.emit('ld', 'BC,HL'); ext('BC'); emit_op('BC', '(XWA+%s)' % hx(okind[2]) if okind[2] else '(XWA)')
            return ret('WA') if op == '%' else 'BC'
        if L == 'F':                                         # ea_i_div_FG: cal / ld WA,HL / exts XWA / divs XWA,(_hi)
            a = addr(okind); F.emit('ld', '%s,%s' % (W, H)); ext(W); emit_op(W, a); return ret('WA')
        if O in ('P', 'D', 'X'):                             # ea_c_div_PF: cal / ld XWA,(_gp) / ld A,(XWA) / exts WA / divs WA,L
            F.emit('ld', '%s,%s' % (W, addr(okind, P='XWA', I=xi, Bs='XBC')))
        else: ldv(W, okind, ok_)
        if O == 'K': F.emit('ld', '%s,%s' % ('XWA' if size == 2 else 'WA', kimm(ok_))); F.lines.pop(-2)
        else: ext(W)
        emit_op(W, H); return ret('WA')
    # ---- multiply / divide with a member through a pointer as the memory operand: its pointer in XWA, the accumulator BC
    if op in ('*', '/', '%') and size == 2 and (R == 'D' and L != 'F' and (op != '*' and L != 'D' or op == '*' and L in ('G', 'D'))
                                                or op == '*' and L == 'D' and R in ('M', 'P', 'X')):
        dk, ok_, okind = (rk, l, lk) if R == 'D' else (lk, r, rk)
        if okind[0] == 'X' and R == 'D':                     # ea_i_div_XD: the element's address, the pointer, ld BC,(XDE+BC)
            a = cw_addr(F, okind, size, I='BC', B='XDE'); F.emit('ld', 'XWA,%s' % dk[1]); F.emit('ld', 'BC,%s' % a)
        elif okind[0] == 'X':                                # ea_i_mul_DX: the pointer, the element's address, ld BC,(XDE+BC)
            F.emit('ld', 'XWA,%s' % dk[1]); a = cw_addr(F, okind, size, I='BC', B='XDE'); F.emit('ld', 'BC,%s' % a)
        elif okind[0] == 'P' and R == 'D': F.emit('ld', 'XBC,%s' % okind[1]); F.emit('ld', 'XWA,%s' % dk[1]); F.emit('ld', 'BC,(XBC)')
        elif okind[0] == 'P': F.emit('ld', 'XWA,%s' % dk[1]); F.emit('ld', 'XBC,%s' % okind[1]); F.emit('ld', 'BC,(XBC)')
        elif okind[0] == 'D':                                # ea_i_mul_DD: ld XWA,(_gps) / ld XBC,(_hps) / ld BC,(XBC+0x2) / muls XBC,(XWA+0x2)
            if R != 'D': return None
            if op == '*':
                F.emit('ld', 'XWA,%s' % lk[1]); F.emit('ld', 'XBC,%s' % rk[1]); F.emit('ld', 'BC,(XBC+%s)' % hx(rk[2]) if rk[2] else 'BC,(XBC)')
                emit_op('BC', '(XWA+%s)' % hx(lk[2]) if lk[2] else '(XWA)'); return 'BC'
            return None
        elif okind[0] == 'K': F.emit('ld', 'XWA,%s' % dk[1]); F.emit('ld', 'XBC,%s' % kimm(ok_))   # ea_i_div_KD: ld XBC,0x7
        else: F.emit('ld', 'XWA,%s' % dk[1]); ldv('BC', okind, ok_)
        if okind[0] != 'K': ext('BC')
        emit_op('BC', '(XWA+%s)' % hx(dk[2]) if dk[2] else '(XWA)')
        return ret('WA') if op == '%' else 'BC'
    if op in ('/', '%') and size == 2 and L == 'D' and R == 'D':
        F.emit('ld', 'XWA,%s' % lk[1]); F.emit('ld', 'XBC,%s' % rk[1]); F.emit('ld', 'WA,(XWA+%s)' % hx(lk[2]) if lk[2] else 'WA,(XWA)')
        ext('WA'); emit_op('WA', '(XBC+%s)' % hx(rk[2]) if rk[2] else '(XBC)'); return ret('WA')
    # ---- a constant on the left: the right loads (ea_c_add_KG: ld A,(_hc) / inc 0x7,A; ea_i_div_KP: ld XBC,(_hpi) / ld XWA,0x7 / divs XWA,(XBC))
    if L == 'K':
        n0 = len(F.lines); a = addr(rk)
        if op in ('/', '%'):
            F.emit('ld', '%s,%s' % ('XWA' if size == 2 else 'WA', kimm(l))); emit_op(W, a); return ret('WA')
        if comm:
            if R in ('G', 'M'): F.emit('ld', '%s,%s' % (W, a))
            else: F.lines[len(F.lines) - (len(F.lines) - n0):] = []; cw_load(F, rk, size)
            emit_op(W, kimm(l), kval(lk, l)); return ret('WA')
        F.emit('ld', '%s,%s' % (W, kimm(l))); emit_op(W, a); return ret('WA')
    # ---- a commutative operation of two addressed sides: the right loads, the left is the memory operand
    swap = comm and R in ('M', 'P', 'D', 'X') and L in ('M', 'P', 'D', 'X') and (L, R) != ('M', 'M')
    if swap:
        if L == 'X' and R == 'X':
            if size == 1 and F.opt and lk[2] == rk[2] and len(lk) == 4:   # -O: lda XBC,_gca / ld DE,(c) / lda XWA,_hca / ld A,(XWA+DE) / add A,(XBC+DE)
                F.emit('lda', 'XBC,%s' % lk[1]); F.emit('ld', 'DE,%s' % lk[2]); F.emit('lda', 'XWA,%s' % rk[1])
                F.emit('ld', '%s,(XWA+DE)' % W); emit_op(W, '(XBC+DE)'); return ret('WA')
            if size == 1:                                    # ea_c_add_XX: left (XDE), right (XBC), ld A,(XBC) / add A,(XDE)
                al = cw_addr(F, lk, size, P='XWA', I='DE'); ar = cw_addr(F, rk, size, I='BC')
                F.emit('ld', '%s,%s' % (W, ar)); emit_op(W, al); return ret('WA')
            if size == 2 and lk[2] == rk[2]:                 # ea_i_add_XX: ld WA,(c) / ld DE,WA / add DE,DE / lda XHL,_gia / add WA,WA / lda XBC,_hia
                ldidx(F, lk, 'WA'); F.emit('ld', 'DE,WA'); F.emit('add', 'DE,DE'); F.emit('lda', 'XHL,%s' % lk[1])
                F.emit('add', 'WA,WA'); F.emit('lda', 'XBC,%s' % rk[1]); F.emit('ld', 'WA,(XBC+WA)'); emit_op(W, '(XHL+DE)'); return ret('WA')
            if size == 4:                                    # (as cl_e_XX: ld DE,(c) / sla 0x2,DE / lda XHL,_gla / the right through XBC+WA)
                ldidx(F, lk, 'DE'); scale_reg(F, 'DE', size, 'sla'); F.emit('lda', 'XHL,%s' % lk[1])
                v = cw_load(F, rk, size, base='XBC'); emit_op(v, '(XHL+DE)'); return ret('WA')
            return None
        if R == 'X' and L in ('P', 'D'):
            if size == 1 or L == 'P':                        # ea_i_mul_PX: ld XDE,(_gpi) / the element into WA / muls XWA,(XDE)
                F.emit('ld', 'XDE,%s' % lk[1]); v = cw_load(F, rk, size, base='XBC'); emit_op(v, '(XDE+%s)' % hx(lk[2]) if lk[2] else '(XDE)'); return ret('WA')
            a = cw_addr(F, lk, size, P='XBC'); v = cw_load(F, rk, size, base='XDE'); emit_op(v, a); return ret('WA')   # ea_i_add_DX
        a = addr(lk, P='XBC', I='BC', Bs='XDE')
        v = cw_load(F, rk, size, base='XDE' if L == 'X' else 'XBC'); emit_op(v, a); return ret('WA')
    # ---- the general order: a left pointer's load, the right's address, the left's value, the operation
    if L in ('P', 'D') and R == 'X' and len(rk) == 5 and rk[4][0] == 'regp' and size != 1:
        if L == 'P': F.emit('ld', 'XHL,%s' % lk[1]); a = addr(rk, P='XBC', I='BC', Bs='XDE'); PL = 'XHL'
        else: F.emit('ld', 'XBC,%s' % lk[1]); a = addr(rk, P='XDE', I='DE', Bs='XHL'); PL = 'XBC'
        F.emit('ld', '%s,%s' % (W, '(%s+%s)' % (PL, hx(lk[2])) if lk[2] else '(%s)' % PL)); ext(W); emit_op(W, a); return ret('WA')
    if L in ('P', 'D'):
        if R == 'X' and size == 1: F.emit('ld', 'XDE,%s' % lk[1]); PL = 'XDE'   # (the char element's address uses XWA)
        else: F.emit('ld', 'XWA,%s' % lk[1]); PL = 'XWA'
        a = addr(rk) if R != 'K' else kimm(r)
        F.emit('ld', '%s,%s' % (W, '(%s+%s)' % (PL, hx(lk[2])) if lk[2] else '(%s)' % PL))
        ext(W); emit_op(W, a, kval(rk, r)); return ret('WA')
    if L == 'X':
        if R == 'X':
            if size == 1 and F.opt and lk[2] == rk[2] and len(lk) == 4:   # -O: lda XWA,_gca / ld DE,(c) / lda XBC,_hca / ld A,(XWA+DE) / sub A,(XBC+DE)
                F.emit('lda', 'XWA,%s' % lk[1]); F.emit('ld', 'DE,%s' % lk[2]); F.emit('lda', 'XBC,%s' % rk[1])
                F.emit('ld', '%s,(XWA+DE)' % W); ext(W); emit_op(W, '(XBC+DE)'); return ret('WA')
            if size == 1:                                    # ea_c_sub_XX: left (XDE), right (XBC)
                al = cw_addr(F, lk, size, P='XWA', I='DE'); ar = cw_addr(F, rk, size, I='BC')
                F.emit('ld', '%s,%s' % (W, al)); ext(W); emit_op(W, ar); return ret('WA')
            if size == 2 and lk[2] == rk[2]:                 # ea_i_sub_XX: ld BC,(c) / ld WA,BC / add WA,WA / lda XHL,_gia / add BC,BC / lda XDE,_hia
                ldidx(F, lk, 'BC'); F.emit('ld', 'WA,BC'); F.emit('add', 'WA,WA'); F.emit('lda', 'XHL,%s' % lk[1])
                F.emit('add', 'BC,BC'); F.emit('lda', 'XDE,%s' % rk[1]); F.emit('ld', 'WA,(XHL+WA)'); ext(W); emit_op(W, '(XDE+BC)'); return ret('WA')
            if size == 4:                                    # ea_l_sub_XX: ld WA,(c) / sla 0x2,WA / lda XHL,_gla / ld BC,(c) / sla 0x2,BC / lda XDE,_hla
                ldidx(F, lk, 'WA'); scale_reg(F, 'WA', size, 'sla'); F.emit('lda', 'XHL,%s' % lk[1])
                ar = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); F.emit('ld', 'XWA,(XHL+WA)'); emit_op(XW, ar); return ret('WA')
            return None
        if size == 1:                                        # ea_c_sub_XG: the element's address in XBC, ld A,(XBC) / sub A,(_hc)
            if R in ('P', 'D'): al = cw_addr(F, lk, size, P='XWA', I='DE'); a = addr(rk, P='XBC')
            else: al = cw_addr(F, lk, size, I='BC'); a = addr(rk) if R != 'K' else kimm(r)
            F.emit('ld', '%s,%s' % (W, al)); ext(W); emit_op(W, a, kval(rk, r)); return ret('WA')
        if R == 'D':                                         # ea_i_sub_XD: the element's base in XDE, the pointer in XBC
            ldidx(F, lk, 'WA'); scale_reg(F, 'WA', size, 'sla' if size == 4 else 'add'); F.emit('lda', 'XDE,%s' % lk[1])
            a = addr(rk, P='XBC'); F.emit('ld', '%s,(XDE+WA)' % W); ext(W); emit_op(W, a); return ret('WA')
        ldidx(F, lk, 'WA'); scale_reg(F, 'WA', size, 'sla' if size == 4 else 'add'); F.emit('lda', 'XBC,%s' % lk[1])
        a = addr(rk, P='XDE', I='DE', Bs='XDE') if R != 'K' else kimm(r)
        F.emit('ld', '%s,(XBC+WA)' % W); ext(W); emit_op(W, a, kval(rk, r)); return ret('WA')
    if L == 'M' and R == 'M' and comm:                       # ea_c_add_EE: ld A,(_hca + 0x3) / add A,(_gca + 0x3)
        F.emit('ld', '%s,%s' % (W, rk[1])); emit_op(W, lk[1]); return ret('WA')
    # ---- a global or static member on the left against an addressed right or a constant
    a = kimm(r) if R == 'K' else addr(rk)
    ldv(W, lk, l); ext(W); emit_op(W, a, kval(rk, r)); return ret('WA')

def cw_addr(F, *a, **k): return cw_pin(F, _cw_addr_raw(F, *a, **k))
def cw_load(F, *a, **k): return cw_pin(F, _cw_load_raw(F, *a, **k))
def cw_value(F, *a, **k): return cw_pin(F, _cw_value_raw(F, *a, **k))
def cw_ext(F, *a, **k): return cw_pin(F, _cw_ext_raw(F, *a, **k))

LH_MEMBER = True                                          # see lh_member

def lh_member_kinds(F, op, l, r):
    """(D kind, other kind, D on the right) for a long helper with one member-through-a-pointer operand and a constant,
    global, static member or plain-pointer one; None otherwise (a constant multiplier is strength-reduced, a constant
    divisor and the element / call kinds are unprobed here)"""
    try: lk, rk = cw_kind(F, l, 4), cw_kind(F, r, 4)
    except Unsupported: return None
    if lk is None or rk is None: return None
    if (lk[0] == 'D') == (rk[0] == 'D'): return None
    dk, ok_, right = (rk, lk, True) if rk[0] == 'D' else (lk, rk, False)
    if ok_[0] not in ('K', 'G', 'M', 'P'): return None
    if ok_[0] == 'K' and (op == '*' or not right): return None
    return dk, ok_, right

def lh_member(F, op, l, r):
    """emit the operands of a long helper with a member-through-a-pointer operand (corpus/probes/evorder_ad.c, run
    2026-11-10-17): the pointer in XIZ, saved at entry (plan_store_xiz), the member read through it.  Divide and
    remainder: the left in XWA and the right in XBC; a left pointer's own load comes before XIZ's (ld XWA,(_gpl) /
    ld XIZ,(_hps) / ld XWA,(XWA) / ld XBC,(XIZ+0x4)); with the member on the left, a global right loads before the
    member (ld XIZ,(_gps) / ld XBC,(_hl) / ld XWA,(XIZ+0x4); -O: the member first), a static member or element after
    it, a pointer's load before and its deref after.  Multiply: a global keeps its side, a static member or pointer
    swaps sides with the member (ea_l_mul_ED: ld XIZ,(_hps) / ld XWA,(XIZ+0x4) / ld XBC,(_gla + 0xc); DE:
    ld XIZ,(_gps) / ld XWA,(_hla + 0xc) / ld XBC,(XIZ+0x4); PD: ld XBC,(_gpl) / ld XIZ,(_hps) / ld XWA,(XIZ+0x4) /
    ld XBC,(XBC)).  True when it emitted them."""
    ks = lh_member_kinds(F, op, l, r)
    if ks is None: return False
    dk, ok_, right = ks; O = ok_[0]; ox = l if right else r
    mem = '(XIZ+%s)' % hx(dk[2]) if dk[2] else '(XIZ)'
    def ld(a, b): F.emit('ld', '%s,%s' % (a, b))
    oval = hx(fold(ox).value & 0xffffffff) if O == 'K' else ok_[1]
    if right:
        if op == '*':
            if O == 'G': ld('XIZ', dk[1]); ld('XWA', oval); ld('XBC', mem)
            elif O == 'M': ld('XIZ', dk[1]); ld('XWA', mem); ld('XBC', oval)
            else: ld('XBC', ok_[1]); ld('XIZ', dk[1]); ld('XWA', mem); ld('XBC', '(XBC)')
        else:
            if O == 'P': ld('XWA', ok_[1]); ld('XIZ', dk[1]); ld('XWA', '(XWA)'); ld('XBC', mem)
            else: ld('XIZ', dk[1]); ld('XWA', oval); ld('XBC', mem)
        return True
    ld('XIZ', dk[1])
    if op == '*':
        if O == 'G':
            if F.opt: ld('XWA', mem); ld('XBC', oval)
            else: ld('XBC', oval); ld('XWA', mem)
        elif O == 'M': ld('XWA', oval); ld('XBC', mem)
        else: ld('XWA', ok_[1]); ld('XWA', '(XWA)'); ld('XBC', mem)
    else:
        if O == 'G':
            if F.opt: ld('XWA', mem); ld('XBC', oval)
            else: ld('XBC', oval); ld('XWA', mem)
        elif O == 'M': ld('XWA', mem); ld('XBC', oval)
        else: ld('XBC', ok_[1]); ld('XWA', mem); ld('XBC', '(XBC)')
    return True

STORE_CHAIN = True                                        # see store_chain
RET_ASSIGN_OPT = True                                     # ret_assign under -O (stret.c, stval.c at O3XS)
STORE_CHAIN_OPT = True                                    # store_chain under -O: an int constant takes ldw on both sides,
                                                          # an outer pointer element is built in its own register

def sc_lkind(F, lv):
    """the lvalue kinds of store_chain: ('G', mem) a global variable, ('M', mem) a static member or constant element,
    ('P', ptr, off) / ('D', ptr, off) through a plain pointer, ('X', sym, idxmem) a global array at a plain signed int
    index in memory, ('Q', ptr, idxmem) a pointer at such an index; None otherwise"""
    x = strip(lv)
    if x.k == 'var':
        if x.decl.kind != 'global' or getattr(x.decl, 'reg', None): return None
        return ('G', '(_%s)' % x.decl.name)
    k = sp_lvalue_kind(F, x)
    if k is None: return None
    if k[0] == 'S': return ('M', k[1])
    if k[0] in ('P', 'D'): return ('D' if k[2] else 'P', k[1], k[2])
    if k[0] in ('X', 'Q'):
        im, signed = k[2]
        if not signed or not isinstance(im, str) or not im.startswith('('): return None
        return (k[0], k[1], im)
    return None

STORE_CHAIN_CHAR = True                                   # store_chain for chars (sc_char)
STORE_CHAIN_CHAR_OPT = True                               # sc_char under -O (stret.c at O3XS)

def sc_char(F, ok_, ik, v, V, vc):
    """L1 = (L2 = V) for chars (corpus/probes/stret.c, run 2026-11-12-2, sc_c_*).  A char element is built through XWA
    into XBC or XDE (lda XWA,_gca / ld BC,(c) / extz XBC / add XBC,XWA).  A loaded value goes to A, or to C when the
    inner address takes XWA (sc_c_GPG: ld XWA,(_hp) / ld C,(_vc)); the outer address comes first, in XBC, or in XDE
    when XBC is taken by the inner element or the value C (sc_c_PPG: ld XDE,(_gp) / ld XWA,(_hp) / ld C,(_vc)).  A
    constant: ldb into the inner, then ldb into a global outer or ld A,0x7 for any other (sc_c_PGK).  A computed value
    is computed in A after the inner address (a pointer in XBC), stored into the inner, and the outer address is built
    after it; an outer element needs XWA, so the value moves to C (outer in XDE) or, when the inner holds XBC, to E
    (outer in XBC) (sc_c_XGB: ld C,A / ld (_hc),C / lda XWA,_gca / ld DE,(c) / extz XDE / add XDE,XWA / ld (XDE),C).
    A call comes first; both addresses are built from XWA after it.  True when it emitted the statement."""
    O, I = ok_[0], ik[0]
    if O == 'D' or I == 'D': return False                  # (a char member at a displacement: unprobed)
    if O in ('X', 'Q') and I in ('X', 'Q'): return False
    def elem(k, reg):                                       # a char element / pointer element into reg (XBC / XDE)
        F.emit('lda' if k[0] == 'X' else 'ld', 'XWA,%s' % k[1]); F.emit('ld', '%s,%s' % (reg[1:], k[2]))
        F.emit('extz', reg); F.emit('add', '%s,XWA' % reg); return '(%s)' % reg
    def ptr(k, reg): F.emit('ld', '%s,%s' % (reg, k[1])); return '(%s)' % reg
    def addr(k, reg):
        if k[0] in ('G', 'M'): return k[1]
        if k[0] == 'P': return ptr(k, reg)
        return elem(k, reg)
    if V == 'C':
        fam = gen(F, v, 'HL', 1)
        if fam != 'HL': raise Unsupported('sc_char: the call result not in L')
        flush_pops(F)
        m = addr(ik, 'XWA' if I == 'P' else 'XBC'); F.emit('ld', '%s,L' % m)
        m = addr(ok_, 'XWA' if O == 'P' else 'XBC'); F.emit('ld', '%s,L' % m); return True
    if V in ('K', 'G'):
        val = 'C' if (V == 'G' and I == 'P') else 'A'
        inner_bc = I in ('X', 'Q')
        oreg = 'XDE' if (inner_bc or val == 'C') else 'XBC'
        if F.opt and V == 'K' and O == 'P' and I in ('G', 'M'): oreg = 'XWA'           # (sc_c_PGK -O)
        om = None
        if O == 'P': om = ptr(ok_, oreg)
        elif O in ('X', 'Q'): om = elem(ok_, oreg)
        im = addr(ik, 'XWA' if I == 'P' else 'XBC')
        if V == 'G':
            F.emit('ld', '%s,%s' % (val, mem_operand(F, v))); F.emit('ld', '%s,%s' % (im, val))
            F.emit('ld', '%s,%s' % (om or ok_[1], val)); return True
        Kv = hx(vc.value & 0xff)
        F.emit('ldb', '%s,%s' % (im, Kv))
        if O == 'G' or F.opt: F.emit('ldb', '%s,%s' % (om or ok_[1], Kv)); return True
        F.emit('ld', 'A,%s' % Kv); F.emit('ld', '%s,A' % (om or ok_[1])); return True
    # V == 'B'
    im = ptr(ik, 'XBC') if I == 'P' else (elem(ik, 'XBC') if I in ('X', 'Q') else ik[1])
    n0 = len(F.lines)
    R = 'A'
    if O in ('X', 'Q'): R = 'E' if I != 'G' and I != 'M' else 'C'
    want = {'A': 'WA', 'C': 'BC', 'E': 'DE'}[R] if F.opt else 'WA'   # (-O: computed in place, sc_c_XGB)
    fam = gen(F, v, want, 1)
    if fam != want or (im.startswith('(X') and clobbers(F.lines[n0:], im)): raise Unsupported('sc_char: the value over the inner address')
    if R != 'A' and not F.opt: F.emit('ld', '%s,A' % R)
    F.emit('ld', '%s,%s' % (im, R))
    if O in ('G', 'M'): F.emit('ld', '%s,%s' % (ok_[1], R)); return True
    if O == 'P': m = ptr(ok_, 'XBC')
    else: m = elem(ok_, 'XDE' if R == 'C' else 'XBC')
    F.emit('ld', '%s,%s' % (m, R)); return True

STORE_VALUE_ADDR = True                                   # see sv_regs

SV_RANK = {('D', 'i'): 0, ('D', 'v'): 1, ('X', 'v'): 1.5, ('X', 'i'): 2, ('P', 'v'): 3, ('P', 'i'): 4, ('Q', 'i'): 4,
           ('G', 'i'): 5, ('M', 'i'): 5}

def sv_value_kind(F, v, size):
    """the kinds of a value read through an address (stval.c): ('P', ptr, 0) / ('D', ptr, off) through a plain pointer,
    ('X', sym, idxmem) a global array at a plain signed index in memory; None otherwise (nothing emitted)"""
    x = strip(v)
    if x.k != 'load' or x.ty is None or x.ty.size != size: return None
    lv = strip(x.e)
    if lv.k not in ('deref', 'member', 'index'): return None
    if lv.k == 'index':
        ie = strip(lv.idx)
        while ie.k == 'cast' and ie.kind == 'IntegralCast': ie = strip(ie.e)
        if ie.k == 'load' and strip(ie.e).k == 'var' and getattr(strip(ie.e).decl, 'reg', None): return None
    keep = getattr(F, 'sp_index_param', None)
    k = sc_lkind(F, lv)
    F.sp_index_param = keep
    if k is None or k[0] not in ('P', 'D', 'X'): return None
    if size == 1 and k[0] == 'D': return None              # (a char member at a displacement: unprobed)
    return k

def sv_regs(ik, vk, size, pool):
    """the registers of a store address (kind ik) and a value read through an address (kind vk), after stval.c: the two
    take registers in the order of SV_RANK, a member with a displacement first, a plain pointer store last (rv_i_PP:
    ld XBC,(_gpi) / ld XWA,(_vpi); rv_i_DP: ld XWA,(_gps) / ld XBC,(_vpi); rv_i_XD: ld BC,(c) / add BC,BC /
    lda XDE,_gia / ld XWA,(_vps)).  The store address is emitted first and lives to the end, so when the value ranks
    first the store avoids every register of the value; when the store ranks first the value avoids only the store's
    final registers (a char element is built through XWA into another register, rv_c_XP: lda XWA,_gca / ld BC,(c) /
    extz XBC / add XBC,XWA / ld XWA,(_vp)).  {'i': regs, 'v': regs}, or None when the registers run out."""
    order = sorted([('i', ik), ('v', vk)], key=lambda t: SV_RANK[(t[1][0], t[0])])
    free = list(pool); out = {}
    for role, k in order:
        if k[0] in ('G', 'M'): out[role] = []; continue
        if size == 1 and k[0] in ('X', 'Q'):
            rest = [r for r in free if r != 'WA']
            if not rest or (role == 'v' and 'WA' not in free): return None
            out[role] = ['WA', rest[0]] if role == 'v' else [rest[0]]
        else:
            n = 2 if k[0] == 'X' else 1
            if len(free) < n: return None
            out[role] = free[:n]
        free = [r for r in free if r not in out[role]]
    return out

def sv_store_addr(F, k, regs, size):
    """emit a store address of kind k into regs (sv_regs); returns its operand"""
    K = k[0]
    if K in ('G', 'M'): return k[1]
    if K in ('P', 'D'):
        F.emit('ld', 'X%s,%s' % (regs[0], k[1]))
        return '(X%s+%s)' % (regs[0], hx(k[2])) if k[2] else '(X%s)' % regs[0]
    if size == 1:                                            # char X / Q: built through XWA into regs[0]
        r = regs[0]
        F.emit('lda' if K == 'X' else 'ld', 'XWA,%s' % k[1]); F.emit('ld', '%s,%s' % (r, k[2]))
        F.emit('extz', 'X' + r); F.emit('add', 'X%s,XWA' % r); return '(X%s)' % r
    if K == 'X':
        ix, bs = regs
        F.emit('ld', '%s,%s' % (ix, k[2]))
        if size == 2: F.emit('add', '%s,%s' % (ix, ix))
        else: F.emit('sla', '0x2,%s' % ix)
        F.emit('lda', 'X%s,%s' % (bs, k[1])); return '(X%s+%s)' % (bs, ix)
    r = regs[0]                                              # Q: built in XWA, moved to another register (rv_i_QP);
    q = r if F.opt else 'WA'                                 # under -O built in its own register (rv_i_QP -O)
    F.emit('ld', '%s,%s' % (q, k[2])); F.emit('exts', 'X' + q)
    if size == 2: F.emit('add', 'X%s,X%s' % (q, q))
    else: F.emit('sll', '0x2,X%s' % q)
    if r != q: F.emit('ld', 'X%s,XWA' % r); F.emit('add', 'X%s,%s' % (r, k[1])); return '(X%s)' % r
    F.emit('add', 'X%s,%s' % (q, k[1])); return '(X%s)' % q

def sv_load(F, k, regs, dst, size):
    """emit the value of kind k (sv_value_kind) into dst through regs (sv_regs)"""
    if k[0] in ('P', 'D'):
        F.emit('ld', 'X%s,%s' % (regs[0], k[1]))
        F.emit('ld', '%s,%s' % (dst, '(X%s+%s)' % (regs[0], hx(k[2])) if k[2] else '(X%s)' % regs[0])); return
    if size == 1:                                            # rv_c_GX: lda XWA,_vca / ld BC,(c) / extz XBC / add XBC,XWA / ld L,(XBC)
        r = regs[1]
        F.emit('lda', 'XWA,%s' % k[1]); F.emit('ld', '%s,%s' % (r, k[2])); F.emit('extz', 'X' + r)
        F.emit('add', 'X%s,XWA' % r); F.emit('ld', '%s,(X%s)' % (dst, r)); return
    ix, bs = regs
    F.emit('ld', '%s,%s' % (ix, k[2]))
    if size == 2: F.emit('add', '%s,%s' % (ix, ix))
    else: F.emit('sla', '0x2,%s' % ix)
    F.emit('lda', 'X%s,%s' % (bs, k[1])); F.emit('ld', '%s,(X%s+%s)' % (dst, bs, ix))

def ra_addr_value(F, k, v, size):
    """return L = V with V read through an address (stval.c rv_*): the store address, the value straight into HL / L /
    XHL, the store; registers from sv_regs.  Two elements at one index (rv_i_XX: the store's base in XIX, rv_i_QX: the
    index cached in BC) are left to the older paths, except for chars, which reload the index (rv_c_XX)."""
    vk = sv_value_kind(F, v, size)
    if vk is None: return False
    if size != 1 and k[0] in ('X', 'Q') and vk[0] == 'X': return False
    al = sv_regs(k, vk, size, ['WA', 'BC', 'DE'])
    if al is None: return False
    m = sv_store_addr(F, k, al['i'], size) if al['i'] else k[1]
    R = FAM['HL'][size]
    sv_load(F, vk, al['v'], R, size)
    F.emit('ld', '%s,%s' % (m, R)); return True

def sc_addr_value(F, ok_, ik, v, size):
    """L1 = (L2 = V) for an int, V read through an address (stval.c cv_i_*): the inner address and the value's take
    registers as sv_regs says; the value lands in the first register that neither the inner address nor the outer one
    will need (cv_i_DXD: ld BC,(c) / add BC,BC / lda XDE,_hia / ld XWA,(_vps) / ld HL,(XWA+0x2) / ld (XDE+BC),HL /
    ld XWA,(_gps) / ld (XWA+0x2),HL); then the outer address is built as for a computed value.  An element at the
    shared index (an index cache in HL or IX in the oracle) is left to the older paths."""
    O, I = ok_[0], ik[0]
    vk = sv_value_kind(F, v, size)
    if vk is None or size != 2: return False
    if vk[0] == 'X' and (O in ('X', 'Q') or I in ('X', 'Q')): return False
    pool = ['WA', 'BC', 'DE', 'HL']
    al = sv_regs(ik, vk, size, pool)
    if al is None: return False
    rout = {'D': ['WA'], 'X': ['WA', 'BC'], 'Q': ['WA']}.get(O, [])
    vf = next((r for r in pool if r not in rout and r not in al['i']), None)
    if vf is None: return False
    im = sv_store_addr(F, ik, al['i'], size) if al['i'] else ik[1]
    R = FAM[vf][size]
    sv_load(F, vk, al['v'], R, size); F.emit('ld', '%s,%s' % (im, R))
    if O in ('G', 'M'): F.emit('ld', '%s,%s' % (ok_[1], R)); return True
    if O == 'P': orr = [next(r for r in pool if r != vf)]
    elif O == 'X': orr = ['WA', 'BC']
    else: orr = ['WA']
    om = sv_store_addr(F, ok_, orr, size); F.emit('ld', '%s,%s' % (om, R)); return True

def store_chain(F, lv, rv, size):
    """L1 = (L2 = V) for an int or long, after corpus/probes/stchain.c (run 2026-11-12-1-micro-stchain).  A loaded or
    constant V: the outer address is emitted first, the inner one next, the value last; the registers are taken in
    the order WA, BC, DE, HL by the outer pointer when it is a member through a pointer (sc_i_DPG: ld XWA,(_gps) /
    ld XBC,(_hpi) / ld DE,(_vi)), then the inner address (an element: its index, then its base), then the outer
    element, then the value, then the outer plain pointer or pointer element (sc_i_PPG: ld XDE,(_gpi) / ld XWA,(_hpi) /
    ld BC,(_vi) / ld (XWA),BC / ld (XDE),BC).  An int constant is stored into the inner with ldw and reloaded into
    the inner address's first register (or the value's) for the outer, a global outer takes ldw too (sc_i_GPK:
    ldw (XWA),0x7 / ldw (_gv),0x7); a long constant holds XWA throughout and is reloaded before each store
    (sc_l_PPK: ld XDE,(_gpl) / ld XBC,(_hpl) / ld XWA,0x7 / ld (XBC),XWA / ld XWA,0x7 / ld (XDE),XWA).  A computed V
    stores the inner first (its address from WA, the value in the first register the outer will not need) and builds
    the outer address after it (sc_i_DPB: ld XWA,(_hpi) / ld BC,(_vi) / sub BC,(_vj) / ld (XWA),BC / ld XWA,(_gps) /
    ld (XWA+0x2),BC); a call comes first and both addresses are built from WA after it.  Two elements at the same index
    (an index cache in HL or IZ in the oracle), a long pointer element and -Xr's register index are left to the older
    paths.  True when it emitted the statement."""
    if size not in (1, 2, 4): return False
    if size == 1 and (not STORE_CHAIN_CHAR or (F.opt and not STORE_CHAIN_CHAR_OPT)): return False
    x = strip(rv)
    if x.k != 'bin' or x.op != '=' or x.ty is None or x.ty.size != size or lv.ty is None or lv.ty.size != size: return False
    if strip(lv).ty is not None and strip(lv).ty.kind not in ('int', 'ptr') or strip(x.l).ty.kind not in ('int', 'ptr'): return False
    if fpgen.is_fp(x.ty): return False
    ok_, ik = sc_lkind(F, lv), sc_lkind(F, x.l)
    if ok_ is None or ik is None: return False
    if size == 4 and 'Q' in (ok_[0], ik[0]): return False
    if ok_[0] in ('X', 'Q') and ik[0] in ('X', 'Q'): return False   # (the shared index: unmodelled)
    v = strip(x.r)
    vk = sp_value_kind(F, v, size)
    vc = fold(v)
    if vc.k == 'const' and vc.value is not None: V = 'K'
    elif v.k == 'load' and mem_operand(F, v) is not None and mem_operand(F, v).startswith('(_'):
        V = 'B' if (STORE_VALUE_ADDR and size == 2 and strip(v.e).k != 'var') else 'G'   # (cv_i_PPE)
    elif STORE_VALUE_ADDR and size == 2 and sv_value_kind(F, v, size) is not None: V = 'A'
    elif vk == 'B': V = 'B'
    elif vk == 'C' and v.k == 'call': V = 'C'
    else: return False
    if any(r_ in ('WA', 'BC', 'DE', 'HL') for r_ in live_regs(F)): return False
    if size == 1: return sc_char(F, ok_, ik, v, V, vc)
    X_ = lambda r: 'X' + r
    W_ = lambda r: FAM[r][size]
    O, I = ok_[0], ik[0]
    def addr(k, regs, via_wa=False):                         # emit k's address in regs; return its operand
        K = k[0]
        if K in ('G', 'M'): return k[1]
        if K in ('P', 'D'):
            F.emit('ld', '%s,%s' % (X_(regs[0]), k[1]))
            return '(%s+%s)' % (X_(regs[0]), hx(k[2])) if k[2] else '(%s)' % X_(regs[0])
        if K == 'X':
            ix, bs = regs
            F.emit('ld', '%s,%s' % (ix, k[2]))
            if size == 2: F.emit('add', '%s,%s' % (ix, ix))
            else: F.emit('sla', '0x2,%s' % ix)
            F.emit('lda', '%s,%s' % (X_(bs), k[1])); return '(%s+%s)' % (X_(bs), ix)
        R = regs[0]                                          # Q (int): built in R, or through XWA then moved
        if via_wa and R != 'WA':
            F.emit('ld', 'WA,%s' % k[2]); F.emit('exts', 'XWA'); F.emit('add', 'XWA,XWA')
            F.emit('ld', '%s,XWA' % X_(R)); F.emit('add', '%s,%s' % (X_(R), k[1])); return '(%s)' % X_(R)
        F.emit('ld', '%s,%s' % (R, k[2])); F.emit('exts', X_(R)); F.emit('add', '%s,%s' % (X_(R), X_(R)))
        F.emit('add', '%s,%s' % (X_(R), k[1])); return '(%s)' % X_(R)
    def nregs(K): return 2 if K == 'X' else (1 if K in ('P', 'D', 'Q') else 0)
    def st(m, r): F.emit('ld', '%s,%s' % (m, r))
    pool = ['WA', 'BC', 'DE', 'HL']
    if V in ('K', 'G'):
        take = list(pool); al = {}
        def get(n):
            if len(take) < n: raise Unsupported('store_chain: out of registers')
            r_ = take[:n]; del take[:n]; return r_
        try:
            if V == 'K' and size == 4: al['v'] = get(1)
            if O == 'D': al['o'] = get(1)
            al['i'] = get(nregs(I))
            if O == 'X': al['o'] = get(2)
            if V == 'G' or (V == 'K' and size == 2 and nregs(I) == 0 and not F.opt): al['v'] = get(1)
            if O in ('P', 'Q'): al['o'] = get(1)
        except Unsupported: return False
        om = addr(ok_, al.get('o', []), via_wa=not F.opt) if nregs(O) else ok_[1]
        im = addr(ik, al['i']) if nregs(I) else ik[1]
        if V == 'G':
            R = W_(al['v'][0]); st(R, mem_operand(F, v)); st(im, R); st(om, R); return True
        K = hx(vc.value & ((1 << 8 * size) - 1))
        if size == 4:
            st('XWA', K); st(im, 'XWA')
            if not F.opt: st('XWA', K)                       # (-O sc_l_PPK: the constant is not reloaded)
            st(om, 'XWA'); return True
        F.emit('ldw', '%s,%s' % (im, K))
        if O == 'G' or F.opt: F.emit('ldw', '%s,%s' % (om, K)); return True   # (-O sc_i_PGK: ldw (XWA),0x7)
        R = W_(al['v'][0] if 'v' in al else al['i'][0])
        st(R, K); st(om, R); return True
    if V == 'A': return sc_addr_value(F, ok_, ik, v, size)
    if V == 'B':
        rout = {'D': ['WA'], 'X': ['WA', 'BC'], 'Q': ['WA']}.get(O, [])
        ir = pool[:nregs(I)]
        if I == 'X' and O in ('X', 'Q'): return False
        vf = next((r for r in pool if r not in rout and r not in ir), None)
        if vf is None: return False
        im = addr(ik, ir) if nregs(I) else ik[1]
        n0 = len(F.lines)
        fam = gen(F, v, vf, size)
        if fam != vf or (nregs(I) and clobbers(F.lines[n0:], im)): raise Unsupported('store_chain: the value over the inner address')
        R = W_(vf); st(im, R)
        if O in ('G', 'M'): st(ok_[1], R); return True
        if O == 'P': orr = [next(r for r in pool if r != vf)]
        elif O == 'X': orr = ['WA', 'BC']
        else: orr = ['WA']
        om = addr(ok_, orr); st(om, R); return True
    # V == 'C'
    if O in ('X', 'Q') and I in ('X', 'Q'): return False
    fam = gen(F, v, 'HL', size)
    if fam != 'HL': raise Unsupported('store_chain: the call result not in HL')
    flush_pops(F)
    R = W_('HL')
    im = addr(ik, pool[:nregs(I)]) if nregs(I) else ik[1]; st(im, R)
    om = addr(ok_, pool[:nregs(O)]) if nregs(O) else ok_[1]; st(om, R)
    return True

RET_ASSIGN = True                                         # see ret_assign

def ret_assign(F, x, size):
    """return L = V for a char, int or long, after corpus/probes/stret.c (run 2026-11-12-2-micro-stret): the address
    first (a pointer in XWA; an element's index in WA and its base in XBC; a pointer element built in XWA; a char
    element: lda XWA,_gca / ld BC,(c) / extz XBC / add XBC,XWA), the value straight into HL / L / XHL and stored from
    there (rs_i_PB: ld XWA,(_gpi) / ld HL,(_vi) / sub HL,(_vj) / ld (XWA),HL); a constant is stored with ldw / ldb and
    then loaded (rs_i_PK: ldw (XWA),0x7 / ld HL,0x7); a long constant goes through XWA, the address moving up one
    register (rs_l_PK: ld XBC,(_gpl) / ld XWA,0x7 / ld (XBC),XWA / ld XHL,0x7); a call comes first.  True when it
    emitted the value and the store."""
    if size not in (1, 2, 4) or x.ty is None or x.ty.size != size or fpgen.is_fp(x.ty): return False
    lv = strip(x.l)
    if lv.ty is None or lv.ty.size != size or lv.ty.kind not in ('int', 'ptr'): return False
    if F.opt and not RET_ASSIGN_OPT: return False
    k = sc_lkind(F, lv)
    if k is None: return False
    if size == 1 and k[0] == 'D': return False             # (a char member at a displacement: unprobed)
    v = strip(x.r)
    while v.k == 'cast' and v.kind == 'IntegralCast' and strip(v.e).ty is not None and strip(v.e).ty.size == size: v = strip(v.e)
    vc = fold(v)
    if vc.k == 'const' and vc.value is not None: V = 'K'
    elif v.k == 'load' and mem_operand(F, v) is not None and mem_operand(F, v).startswith('(_'): V = 'G'
    elif STORE_VALUE_ADDR and sv_value_kind(F, v, size) is not None: V = 'A'
    elif sp_value_kind(F, v, size) == 'B': V = 'B'
    elif v.k == 'call' and v.ty is not None and v.ty.size == size: V = 'C'
    else: return False
    if any(r_ in ('WA', 'BC', 'DE', 'HL') for r_ in live_regs(F)): return False
    K = k[0]; R = FAM['HL'][size]
    def addr(base):                                          # base: the first register ('WA', or 'BC' for a long K)
        nxt = {'WA': 'BC', 'BC': 'DE'}[base]
        if K in ('G', 'M'): return k[1]
        if K in ('P', 'D'):
            F.emit('ld', 'X%s,%s' % (base, k[1]))
            return '(X%s+%s)' % (base, hx(k[2])) if k[2] else '(X%s)' % base
        if size == 1:                                        # char X / Q: lda XWA,_gca (ld XWA,(_gp)) / ld BC,(c) / extz XBC / add XBC,XWA
            F.emit('lda' if K == 'X' else 'ld', 'XWA,%s' % k[1]); F.emit('ld', 'BC,%s' % k[2])
            F.emit('extz', 'XBC'); F.emit('add', 'XBC,XWA'); return '(XBC)'
        if K == 'X':
            F.emit('ld', '%s,%s' % (base, k[2]))
            if size == 2: F.emit('add', '%s,%s' % (base, base))
            else: F.emit('sla', '0x2,%s' % base)
            F.emit('lda', 'X%s,%s' % (nxt, k[1])); return '(X%s+%s)' % (nxt, base)
        q = base if F.opt else 'WA'                          # Q: built in XWA (a long K: moved to XBC); under -O
        F.emit('ld', '%s,%s' % (q, k[2])); F.emit('exts', 'X' + q)   # in its own register (rs_l_QK -O)
        if size == 2: F.emit('add', 'X%s,X%s' % (q, q))
        else: F.emit('sll', '0x2,X%s' % q)
        if base != q: F.emit('ld', 'X%s,XWA' % base); F.emit('add', 'X%s,%s' % (base, k[1])); return '(X%s)' % base
        F.emit('add', 'X%s,%s' % (q, k[1])); return '(X%s)' % q
    if V == 'C':
        fam = gen(F, v, 'HL', size)
        if fam != 'HL': raise Unsupported('ret_assign: the call result not in HL')
        flush_pops(F)
        m = addr('WA'); F.emit('ld', '%s,%s' % (m, R)); return True
    if V == 'K':
        Kv = hx(vc.value & ((1 << 8 * size) - 1))
        if size == 4:
            m = addr('BC'); F.emit('ld', 'XWA,%s' % Kv); F.emit('ld', '%s,XWA' % m); F.emit('ld', 'XHL,%s' % Kv); return True
        m = addr('WA'); F.emit('ldb' if size == 1 else 'ldw', '%s,%s' % (m, Kv)); F.emit('ld', '%s,%s' % (R, Kv)); return True
    if V == 'A': return ra_addr_value(F, k, v, size)
    m = addr('WA')
    n0 = len(F.lines)
    fam = gen(F, v, 'HL', size)
    if fam != 'HL' or (m.startswith('(X') and clobbers(F.lines[n0:], m)): raise Unsupported('ret_assign: the value over the address')
    F.emit('ld', '%s,%s' % (m, R)); return True

BIN_WIDE_ARG = True                                       # bin_wide for a pushed global minus element
PUSH_ELEM = True                                          # see push_elem

def push_elem(F, x):
    """the address of an int element pushed as an argument (the random corpora's oracle listings): the index into WA
    and doubled, lda XBC,_arr, pushw (XBC+WA); an unsigned char index is extended first (ld A,(b) / extz WA /
    add WA,WA); a signed char index is doubled in the byte and used as it is (ld A,C / add A,C / lda XBC,_gia /
    pushw (XBC+A)).  Returns the operand, or None for another shape (nothing emitted)."""
    if x.ty is None or x.ty.size != 2: return None
    b = strip(x.base)
    while b.k in ('decay', 'cast', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array': sym = '_' + b.decl.name
    elif b.k == 'member' and not b.arrow and b.ty.kind == 'array' and strip(b.base).k == 'var' and strip(b.base).decl.kind == 'global':
        off = member_offset(b); sym = '_%s + %s' % (strip(b.base).decl.name, hx(off)) if off else '_' + strip(b.base).decl.name
    else: return None
    ib = strip(x.idx)
    while ib.k == 'cast' and ib.kind == 'IntegralCast': ib = strip(ib.e)
    if ib.k != 'load' or ib.ty is None: return None
    m = mem_operand(F, ib)
    if m is None or ('BC' in live_regs(F)) or (family_of(m) in ('XWA', 'XBC') and not (ib.ty.size == 2 and m == 'WA')): return None
    if ib.ty.size == 2 and ib.ty.signed:
        if m != 'WA': F.emit('ld', 'WA,%s' % m)
        F.emit('add', 'WA,WA'); F.emit('lda', 'XBC,%s' % sym); return '(XBC+WA)'
    if ib.ty.size == 1 and not ib.ty.signed:
        F.emit('ld', 'A,%s' % m); F.emit('extz', 'WA'); F.emit('add', 'WA,WA'); F.emit('lda', 'XBC,%s' % sym); return '(XBC+WA)'
    if ib.ty.size == 1:
        F.emit('ld', 'A,%s' % m); F.emit('add', 'A,%s' % m); F.emit('lda', 'XBC,%s' % sym); return '(XBC+A)'
    return None

def cw_kind(F, x, size):
    """the operand kinds of cmp_wide: ('K',), ('G', mem), ('M', mem) for a static member or constant element,
    ('P', ptrmem, 0) / ('D', ptrmem, off) through a plain pointer, ('X', sym, idxmem, signed) a global or static
    member array at a plain int index, ('N',) ('U',) ('B',) ('T',) ('S',) computed, ('F',) a call; None otherwise"""
    x0 = strip(x)
    while x0.k == 'cast' and x0.kind in ('IntegralCast', 'NoOp', 'BitCast') and x0.ty is not None and \
            strip(x0.e).ty is not None and (strip(x0.e).ty.size == size or x0.k == 'cast' and strip(x0.e).k == 'un'):
        x0 = strip(x0.e)
    if x0.k == 'const' or fold(x0).k == 'const' and fold(x0).value is not None: return ('K',)
    if x0.k == 'call':
        return ('F',) if not has_helper_call(x0.fn) and x0.ty is not None and x0.ty.size == size and \
            not any(nodes_in(a_, 'call') or has_helper_call(a_) for a_ in x0.args) else None
    if x0.k == 'cast' and x0.kind == 'IntegralCast' and size == 1 and x0.ty is not None and x0.ty.size == 1 and \
            getattr(x0, 'explicit', False):
        xi = strip(x0.e)                                   # (unsigned char)hul: a narrowing cast of a wider load
        while xi.k == 'cast' and xi.kind == 'IntegralCast': xi = strip(xi.e)
        if xi.k == 'load' and xi.ty is not None and xi.ty.size in (2, 4):
            ik = cw_kind(F, xi, xi.ty.size)
            if ik is not None and ik[0] in ('G', 'M', 'P', 'D'): return ('NW', ik, xi.ty.size, x0.ty.signed)
        return None
    if x0.k == 'cast' and x0.kind == 'IntegralCast' and x0.ty is not None and x0.ty.size == size:
        xi = strip(x0.e)                                   # (long)gc, (int)huc, (long)gp[0]: the extension of a smaller load
        while xi.k == 'cast' and xi.kind == 'IntegralCast' and strip(xi.e).ty is not None and strip(xi.e).ty.size <= xi.ty.size:
            xi = strip(xi.e)
        if xi.k == 'load' and xi.ty is not None and xi.ty.size < size and xi.ty.size in (1, 2):
            ik = cw_kind(F, xi, xi.ty.size)
            if ik is not None and ik[0] in ('G', 'M', 'P', 'D'):
                return ('ZU' if not xi.ty.signed and size == 4 else 'Z', ik, xi.ty.size, xi.ty.signed)
        return cw_generic(F, x0)
    if x0.k == 'un' and x0.op in ('!', '-'):
        xi = strip(x0.e)
        while xi.k == 'cast' and xi.kind == 'IntegralCast': xi = strip(xi.e)
        if xi.k == 'load' and mem_operand(F, xi) is not None and not family_of(mem_operand(F, xi)) and \
                strip(xi.e).k in ('var', 'member') and not (strip(xi.e).k == 'member' and strip(xi.e).arrow) and \
                xi.ty is not None and xi.ty.size == size:
            return ('N',) if x0.op == '!' else ('U',)
        return cw_generic(F, x0)
    if x0.k == 'bin' and x0.op in ('+', '-', '&', '|', '^') and x0.ty is not None and (x0.ty.size == size or size == 1):
        def simple(y):
            y = strip(y)
            while y.k == 'cast' and y.kind == 'IntegralCast': y = strip(y.e)
            return y.k == 'const' or (y.k == 'load' and mem_operand(F, y) is not None and not family_of(mem_operand(F, y))
                                      and strip(y.e).k in ('var', 'member') and not (strip(y.e).k == 'member' and strip(y.e).arrow))
        return ('B',) if simple(x0.l) and simple(x0.r) and not (fold(x0.l).k == 'const' and fold(x0.r).k == 'const') else cw_generic(F, x0)
    if x0.k == 'bin' and x0.op in ('<<', '>>') and x0.ty is not None and x0.ty.size == size and fold(x0.r).k != 'const':
        xl, xr = strip(x0.l), strip(x0.r)
        while xr.k == 'cast' and xr.kind == 'IntegralCast': xr = strip(xr.e)
        if xl.k == 'load' and mem_operand(F, xl) is not None and not family_of(mem_operand(F, xl)) and \
                xr.k == 'load' and mem_operand(F, xr) is not None and not family_of(mem_operand(F, xr)): return ('S',)
        return cw_generic(F, x0)
    if x0.k == 'cond':
        ok = lambda y: unpromote(y).k == 'load' and mem_operand(F, unpromote(y)) is not None and \
            not family_of(mem_operand(F, unpromote(y))) and strip(unpromote(y).e).k == 'var'
        return ('T',) if ok(x0.c) and ok(x0.a) and ok(x0.b) and unpromote(x0.a).ty.size == size and \
            unpromote(x0.b).ty.size == size else None
    if x0.k != 'load' or x0.ty is None or x0.ty.size != size: return cw_generic(F, x0)
    v = strip(x0.e)
    if v.k == 'var':
        m = mem_operand(F, x0)
        return ('G', m) if m is not None and not family_of(m) else None
    if v.k == 'deref':
        pm = sp_plain_ptr(F, v.e)
        return ('P', pm, 0) if pm is not None else None
    if v.k == 'member' and v.arrow:
        pm = sp_plain_ptr(F, v.base)
        if pm is None: return None
        off = member_offset(v)
        return ('D', pm, off) if off else ('P', pm, 0)
    if v.k == 'index' and fold(v.idx).k == 'const' and fold(v.idx).value is not None:
        b = strip(v.base)
        while b.k in ('cast', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
        pm = sp_plain_ptr(F, b) if b.k != 'decay' else None   # gpl[2]: a pointer at a constant index
        if pm is not None: return ('D', pm, fold(v.idx).value * size, 'I')
    if v.k == 'member' or (v.k == 'index' and fold(v.idx).k == 'const'):
        g = global_offset(v)
        if g is None or g[0] == '__param__': return None
        return ('M', '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0])
    if v.k == 'index' and strip(v.base).k == 'member' and strip(v.base).arrow and strip(v.base).ty.kind == 'array':
        mb = strip(v.base); pm = sp_plain_ptr(F, mb.base); ii = sp_plain_index(F, v.idx)
        if pm is not None and ii is not None and ii[0] != 'WA' and mb.ty.kind == 'array':
            return ('A', pm, member_offset(mb), ii[0], ii[1])    # gps->a[c]
        return None
    if v.k == 'index':
        ii = sp_plain_index(F, v.idx); reg = None
        xi_ = strip(v.idx)
        while xi_.k == 'cast' and xi_.kind == 'IntegralCast': xi_ = strip(xi_.e)
        if ii is None and xi_.k == 'load' and strip(xi_.e).k == 'var' and xi_.ty is not None and xi_.ty.size == 2:
            d_ = strip(xi_.e).decl; r_ = getattr(d_, 'reg', None)   # gia[t], t a register temporary dying here
            if r_ in ('WA', 'BC', 'DE', 'HL') and getattr(d_, 'regtemp', False) and (dies_here(F, xi_) or not uses_after_stmt(F, d_)):
                ii = (r_, xi_.ty.signed); reg = ('reg', d_)
        elif ii is not None and ii[0] == 'WA': reg = ('regp', None)   # (-Xr: the index parameter in WA, dying here)
        if ii is None: return None
        if not ii[1] and (size in (2, 4) or ii[0] == 'IZ'): return None   # (an unsigned index is extended whole:
                                                           #  r1_04_10, UIDX32; a char element: r4_07_10)
        b = strip(v.base)
        while b.k in ('decay', 'cast', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
        tag = (reg,) if reg else ()
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array': return ('X', '_' + b.decl.name, ii[0], ii[1]) + tag
        if b.k == 'member' and not b.arrow and b.ty.kind == 'array' and strip(b.base).k == 'var' and strip(b.base).decl.kind == 'global':
            off = member_offset(b)
            return ('X', '_%s + %s' % (strip(b.base).decl.name, hx(off)) if off else '_' + strip(b.base).decl.name, ii[0], ii[1]) + tag
    return None

def cw_pin(F, s_):
    """record an operand (an address or a value register) with the line count at which it became ready; an address
    whose base and index are one register is refused (cmpordl2.c ci_l_FY once gave cp HL,(XBC+BC))"""
    if isinstance(s_, str):
        m_ = re.match(r'^\((X[A-Z]{2})\+([A-Z]{1,3})\)$', s_)
        if m_ and family_of(m_.group(2)) == m_.group(1): raise Unsupported('cmp_wide: an address with its base as its index')
    if isinstance(s_, str) and getattr(F, 'cw_pins', None) is not None: F.cw_pins.append((s_, len(F.lines)))
    return s_

def cw_guard(F, final_idx, what):
    """the operands of the final instruction F.lines[final_idx] must not have been overwritten after they were formed:
    for each pinned operand that the instruction names, no line between its pin and the instruction may write a
    register it is built from (a call counts).  The safety net of cmp_wide and bin_wide: their tables are fitted
    to the probes, and an unprobed pair could otherwise compute an operand over another (wrong code)"""
    pins = sorted(getattr(F, 'cw_pins', None) or [], key=lambda p_: p_[1])
    if not pins: return
    for idx in range(pins[0][1], final_idx + 1):
        if idx >= len(F.lines): break
        parts = F.lines[idx].split('	')
        ops = [o.strip() for o in parts[2].split(',')] if len(parts) > 2 else []
        latest = {}
        for s_, n_ in pins:
            if n_ <= idx: latest[s_] = n_
        for s_, n_ in latest.items():
            if s_ not in ops: continue
            fam_ = family_of(s_) if not s_.startswith('(') else None
            if any(n2 > idx and (s2 == s_ or fam_ is not None and family_of(s2) == fam_) for s2, n2 in pins if not s2.startswith('(')):
                continue                                   # (this line recomputes the register: a later pin is ready after it)
            probe = s_ if s_.startswith('(') else ('(%s)' % fam_ if fam_ else None)
            if probe and clobbers(F.lines[n_:idx], probe):
                raise Unsupported('%s: the operand %s is overwritten before it is read' % (what, s_))

def cw_base_clash(k):
    """the index register of k is the base register it needs: a register temporary moves to the next home (the planner
    retries on LiveClobber), -Xr's parameter in WA cannot"""
    if k[4][0] == 'reg': return LiveClobber('cmp_wide: the index register %s is the base' % k[2], k[4][1])
    return Unsupported('cmp_wide: the index register %s is the base' % k[2])

def cw_regidx_ok(F, k):
    """a register index (a register temporary, -Xr's parameter in WA) must not have been written since the rule began"""
    st = getattr(F, 'cw_start', None)
    if st is not None and clobbers(F.lines[st:], '(X%s)' % k[2]):
        raise Unsupported('cmp_wide: the index register %s was overwritten' % k[2])

def ldidx(F, k, I):
    """the index of the element operand k into register I: a memory index loads (ld BC,(c)); an index already in a
    register stays when it is I and is copied otherwise (ld BC,WA; ld WA,BC)"""
    if len(k) == 5: cw_regidx_ok(F, k)
    if len(k) == 5:
        if k[2] != I: F.emit('ld', '%s,%s' % (I, k[2]))
    else: F.emit('ld', '%s,%s' % (I, k[2]))

def _cw_addr_raw(F, k, size, P='XBC', I='BC', B='XDE', combine=False):
    """emit the address of an operand of kind P / D / X / M and return it: the pointer in P, the index in I with the
    base in B (size 4: ld I,(c) / sla 0x2,I / lda B,sym -> (B+I); size 1: lda XWA,sym / ld I,(c) / extz XI /
    add XI,XWA -> (XI)); combine=True adds the index into the base (lda B,B+I -> (B))"""
    if k[0] in ('P', 'D'):
        F.emit('ld', '%s,%s' % (P, k[1]))
        if combine and k[2]: F.emit('inc' if k[2] <= 8 else 'add', '%s,%s' % (hx(k[2]), P) if k[2] <= 8 else '%s,%s' % (P, hx(k[2]))); return '(%s)' % P
        return '(%s+%s)' % (P, hx(k[2])) if k[2] else '(%s)' % P
    if k[0] == 'X':
        sym, im, signed = k[1], k[2], k[3]
        if size == 1:
            if len(k) == 5 or im == 'IZ':                    # the 16-bit index register as it is: (XBC+DE), (XWA+BC),
                if len(k) == 5: cw_regidx_ok(F, k)           # (XWA+IZ) (evorder_ad.c -Xr ea_c_add_FX)
                base = P
                if base[1:] == im: raise cw_base_clash(k)
                F.emit('lda', '%s,%s' % (base, sym)); return '(%s+%s)' % (base, im)
            X = 'X' + I
            F.emit('lda', 'XWA,%s' % sym); F.emit('ld', '%s,%s' % (I, im)); F.emit('extz', X); F.emit('add', '%s,XWA' % X)
            return '(%s)' % X
        if len(k) == 5 and B[1:] == I: raise cw_base_clash(k)
        ldidx(F, k, I); scale_reg(F, I, size, 'sla' if size == 4 else 'add'); F.emit('lda', '%s,%s' % (B, sym))
        if combine: F.emit('lda', '%s,%s+%s' % (B, B, I)); return '(%s)' % B
        return '(%s+%s)' % (B, I)
    if k[0] == 'A':                                          # ld WA,(c) / add WA,WA / inc 0x8,WA / ld E,A / ld XBC,(_hps) -> (XBC+E)
        pm, off, im = k[1], k[2], k[3]
        I8 = {'XWA': 'C', 'XBC': 'E', 'XDE': 'L', 'XHL': 'H'}[P]
        F.emit('ld', 'WA,%s' % im)
        if size == 2: F.emit('add', 'WA,WA')
        elif size == 4: F.emit('sla', '0x2,WA')
        if off: F.emit('inc' if off <= 8 else 'add', '%s,WA' % hx(off) if off <= 8 else 'WA,%s' % hx(off))
        F.emit('ld', '%s,A' % I8); F.emit('ld', '%s,%s' % (P, pm)); return '(%s+%s)' % (P, I8)
    if k[0] == 'M':
        if combine: F.emit('lda', '%s,%s' % (P, k[1][1:-1])); return '(%s)' % P
        return k[1]
    if k[0] == 'G': return k[1]
    return None

def cw_truth(F, x, R):
    """!v as a word into R: cpb / cpw (v),0x0 / scc eq,R; a long: ld XWA,(v) / or XWA,XWA / scc eq,R (no extension)"""
    x0 = strip(x)
    while x0.k == 'cast': x0 = strip(x0.e)
    assert x0.k == 'un' and x0.op == '!'
    xi = strip(x0.e)
    while xi.k == 'cast' and xi.kind == 'IntegralCast': xi = strip(xi.e)
    m = mem_operand(F, xi)
    if xi.ty.size == 4: F.emit('ld', 'XWA,%s' % m); F.emit('or', 'XWA,XWA')
    else: F.emit('cpb' if xi.ty.size == 1 else 'cpw', '%s,0x0' % m)
    F.emit('scc', 'eq,%s' % R)

def cw_index_use(node, d):
    """is d read as the index of an element in node? (cmpordl2.c ci_l_GY: int t = gi; if (gi < hia[t]): t is the index
    register, ld BC,(_gi) / add BC,BC / lda XDE,_hia, not folded into its use)"""
    hits = []
    def v(n, depth):
        if n.k == 'index':
            x = strip(n.idx)
            while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
            if x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl is d: hits.append(n)
    walk(node, v)
    return bool(hits)

def cw_generic(F, x0):
    """('V',): any other expression without a call, an assignment or a floating-point operation; cmp_wide computes it
    like a difference (kind B) and refuses when its code touched an address register the other side holds"""
    if x0.k not in ('bin', 'un', 'cast', 'load', 'cond'): return None
    bad = []
    walk(x0, lambda n, d: bad.append(n) if n.k in ('call', 'assign', 'incdec', 'comma') or n.k == 'bin' and n.op in ('=', ',') or
         fpgen.is_fp_op(n) else None)
    return None if bad or has_helper_call(x0) else ('V',)

def _cw_ext_raw(F, zk, size, R):
    """the Z / ZU operand (the extension of a smaller memory operand) into R: ld A,(_hc) / exts WA / exts XWA; into BC
    through A: ld A,(_hc) / ld C,A / exts BC / exts XBC; an int source: ld BC,(_hi) / exts XBC; the zero extension of
    a byte to a long: ld XWA,0x0 / ld A,(_guc), or ld A,(_guc) / ld XBC,0x0 / ld C,A (cmpordl2.c cl_l_UK, cl_l_PU)"""
    kind, ik, isz, sg = zk
    if ik[0] in ('P', 'D'):
        if kind == 'ZU': raise Unsupported('cmp_wide: a zero extension of a pointed operand')
        F.emit('ld', 'XWA,%s' % ik[1]); m = '(XWA+%s)' % hx(ik[2]) if ik[2] else '(XWA)'
    else: m = ik[1]
    X = {'WA': 'XWA', 'BC': 'XBC', 'DE': 'XDE'}[R]; lo = {'WA': 'A', 'BC': 'C', 'DE': 'E'}[R]
    if kind == 'ZU':
        if R == 'WA': F.emit('ld', 'XWA,0x0'); F.emit('ld', 'A,%s' % m)
        else: F.emit('ld', 'A,%s' % m); F.emit('ld', '%s,0x0' % X); F.emit('ld', '%s,A' % lo)
        return X
    ex = 'exts' if sg else 'extz'
    if isz == 1:
        F.emit('ld', 'A,%s' % m)
        if R != 'WA': F.emit('ld', '%s,A' % lo)
        F.emit(ex, R)
        if size == 4: F.emit(ex, X)
    else:
        F.emit('ld', '%s,%s' % (R, m)); F.emit(ex, X)
    return FAM[R][size]

def _cw_value_raw(F, x, k, size, R):
    """emit the value of x (kind k) into register family R and return its spelling"""
    x0 = strip(x)
    while x0.k == 'cast' and x0.kind == 'IntegralCast': x0 = strip(x0.e)
    if k[0] == 'B' and size == 4 and x0.op == '-' and fold(x0.l).k == 'const' and fold(x0.l).value is not None:
        m = mem_operand(F, strip(x0.r))                    # 256L - hl: ld XWA,0x100 / sub XWA,(_hl); -O: lda XWA,0x100
        if m is not None:
            F.emit('lda' if F.opt else 'ld', '%s,%s' % (FAM[R][4], hx(fold(x0.l).value & 0xffffffff)))
            F.emit('sub', '%s,%s' % (FAM[R][4], m)); return FAM[R][4]
    if k[0] in ('U', 'B') and F.opt and R != 'WA':         # -O: computed in its own register (ld XBC,(_hl) / cpl BC /
        xi = strip(x0.e) if k[0] == 'U' else None          #  cpl QBC / inc 0x1,XBC; ld C,(_hc) / sub C,(_hd))
        while xi is not None and xi.k == 'cast' and xi.kind == 'IntegralCast': xi = strip(xi.e)
        Rr = FAM[R][size]
        if k[0] == 'U' and mem_operand(F, xi) is not None:
            F.emit('ld', '%s,%s' % (Rr, mem_operand(F, xi)))
            if size == 4: F.emit('cpl', FAM[R][2]); F.emit('cpl', Q[R]); F.emit('inc', '0x1,%s' % Rr)
            else: F.emit('neg', Rr)
            return Rr
        if k[0] == 'B':
            xl, xr = strip(x0.l), strip(x0.r)
            while xl.k == 'cast' and xl.kind == 'IntegralCast': xl = strip(xl.e)
            while xr.k == 'cast' and xr.kind == 'IntegralCast': xr = strip(xr.e)
            ml, mr = mem_operand(F, xl), (hx(fold(xr).value & ((1 << 8 * size) - 1)) if fold(xr).k == 'const' else mem_operand(F, xr))
            if ml is not None and mr is not None and fold(xl).k != 'const':
                F.emit('ld', '%s,%s' % (Rr, ml)); F.emit({'+': 'add', '-': 'sub', '&': 'and', '|': 'or', '^': 'xor'}[x0.op], '%s,%s' % (Rr, mr))
                return Rr
    if k[0] == 'T':
        F.cw_plain_cond = True
        try: fam = gen(F, x, R, size)
        finally: F.cw_plain_cond = False
        if fam != R: raise Unsupported('cmp_wide: the ?: landed in %s' % fam)
        return FAM[R][size]
    if k[0] == 'F':
        fam = gen(F, x, 'HL', size)
        if fam != 'HL': raise Unsupported('cmp_wide: a call result not in HL')
        flush_pops(F)                                        # (cmpordl2.c cl_l_GF: cal _hrl / inc 0x4,XSP / cp (_gl),XHL)
        return FAM['HL'][size]
    fam = gen(F, x, R, size)
    if fam not in FAM or size not in FAM[fam]: raise Unsupported('cmp_wide: value in %s' % fam)
    if fam != R: raise Unsupported('cmp_wide: the value landed in %s, not %s [%s]' % (fam, R, k[0]))
    return FAM[R][size]

def cmp_wide(F, e, l, r, size, op, cc):
    """the operands of a long (size 4) or char (size 1) compare, after corpus/probes/cmpordl.c (run
    2026-11-10-16-micro-cmpordl, the same at the four option sets up to -O's in-place forms, so applied without -O):
    a memory or addressed left is loaded into XWA / A against a constant or memory right (ld XWA,(_gl) / cp XWA,0x7;
    chars: cpb (_gc),0x7 against a constant); a right pointer or element's address comes first (ld XBC,(_hpl) /
    ld XWA,(_gl) / cp XWA,(XBC); ld BC,(c) / sla 0x2,BC / lda XDE,_hla), the left pointer's own load before it
    (ld XWA,(_gpl) / ld XBC,(_hpl) / ld XWA,(XWA)); a computed right goes first into XWA and the left stays in memory
    (ld XWA,(_hl) / sub XWA,(_hm) / cp (_gl),XWA; == : cp XWA,(_gl)), a left pointer in XBC before it, a member with
    a displacement in XWA with the right in XBC for a difference (ld XWA,(_gps) / ld XBC,(_hl) / sub XBC,(_hm) /
    cp (XWA+0x4),XBC) and in XBC with the right in XWA for a ! or - ; two computed operands: the one that needs WA (!,
    -) takes XWA and the other XBC, else the right XWA and the left XBC (cp XBC,XWA), both needing WA: the right moves
    to XBC; a shift's value takes XBC with the count in WA (a right shift first; a left shift takes XDE before a right
    pointer or computed value); a call comes first and its result stays in XHL / L (cal _hfl / cp (_gl),XHL); a ?:
    on the left takes a static member's, element's or pointer's address in XWA first and its arms into XBC
    (lda XWA,_hs + 0x4 / ... / cp XBC,(XWA)); == of an addressed left against a static member, element, pointer or
    element right loads the right into XWA (ld XBC,(_gpl) / ld XWA,(_hs + 0x4) / cp XWA,(XBC)).  Chars compare at the
    byte except against a ! (the truth value): the other side is sign-extended to a word (cpb (_hc),0x0 / scc eq,WA /
    ld BC,WA / ld A,(_gc) / exts WA / cp WA,BC).  None where the pair is not in the table."""
    lk, rk = cw_kind(F, l, size), cw_kind(F, r, size)
    if lk is None or rk is None or lk[0] == 'K': return None
    if size == 1 and ('S' in (lk[0], rk[0])): return None   # (char shifts: not probed)
    if 'NW' in (lk[0], rk[0]):                              # (unsigned char)hul against a char: the long loads, cp C,A
        if not rk[3] if rk[0] == 'NW' else not lk[3]: cc = CC_U[op]
        def nw(zk):                                        # the wide operand into XWA / WA: its low byte is A
            if zk[1][0] in ('P', 'D'): F.emit('ld', 'XWA,%s' % zk[1][1]); F.emit('ld', '%s,%s' % (FAM['WA'][zk[2]], '(XWA+%s)' % hx(zk[1][2]) if zk[1][2] else '(XWA)'))
            else: F.emit('ld', '%s,%s' % (FAM['WA'][zk[2]], zk[1][1]))
        if rk[0] == 'NW' and lk[0] in ('G', 'M'): nw(rk); F.emit('ld', 'C,%s' % lk[1]); F.emit('cp', 'C,A'); return cc   # cc_l_GW
        if rk[0] == 'NW' and lk[0] == 'NW': nw(rk); F.emit('ld', 'C,A'); nw(lk); F.emit('cp', 'A,C'); return cc        # cc_l_WW
        if rk[0] == 'NW' and lk[0] in ('P', 'D'):                                                                    # cc_l_PW
            nw(rk); F.emit('ld', 'C,A'); F.emit('ld', 'XWA,%s' % lk[1]); F.emit('ld', 'A,%s' % ('(XWA+%s)' % hx(lk[2]) if lk[2] else '(XWA)')); F.emit('cp', 'A,C'); return cc
        if lk[0] == 'NW' and rk[0] in ('G', 'M'): F.emit('ld', 'C,%s' % rk[1]); nw(lk); F.emit('cp', 'A,C'); return cc   # cc_l_WG
        if lk[0] == 'NW' and rk[0] in ('P', 'D'):                                                                    # cc_l_WP
            F.emit('ld', 'XWA,%s' % rk[1]); F.emit('ld', 'C,%s' % ('(XWA+%s)' % hx(rk[2]) if rk[2] else '(XWA)')); nw(lk); F.emit('cp', 'A,C'); return cc
        if lk[0] == 'NW' and rk[0] == 'K': nw(lk); F.emit('cp', 'A,%s' % hx(fold(r).value & 0xff)); return cc
        if rk[0] == 'NW' and lk[0] == 'F': cw_value(F, l, lk, size, 'HL'); nw(rk); F.emit('cp', 'L,A'); return cc   # cc_l_FW
        return None
    vgen = {'V'}
    if lk[0] == 'V': lk = ('B',) + lk[1:]; vgen.add('L')
    if rk[0] == 'V': rk = ('B',) + rk[1:]; vgen.add('R')
    live = {r_ for r_ in live_regs(F) & {'WA', 'BC', 'DE', 'HL'} if any(      # (a register parameter the body never
        uses_decl(F.f.body, d_) for d_ in list(F.f.params) + list(F.f.decls)    #  reads is free: -Xr's c in WA)
        if getattr(d_, 'reg', None) == r_ and d_ not in F.dead)}
    for k_ in (lk, rk):
        if k_[0] == 'X' and len(k_) == 5: live.discard(k_[2])   # (the index register is consumed here)
    if live: return None
    ordered = op in ('<', '<=', '>', '>=')
    L, R = lk[0], rk[0]
    W = {4: ('XWA', 'XBC', 'XDE', 'XHL'), 2: ('WA', 'BC', 'DE', 'HL'), 1: ('A', 'C', 'E', 'L')}[size]
    XW, XB, XD, XH = W
    famof = lambda rg: {'XWA': 'WA', 'WA': 'WA', 'A': 'WA', 'XBC': 'BC', 'BC': 'BC', 'C': 'BC', 'XDE': 'DE', 'DE': 'DE', 'E': 'DE',
                        'XHL': 'HL', 'HL': 'HL', 'L': 'HL'}[rg]
    def value(x, k, Rfam):
        n0 = len(F.lines); v_ = cw_value(F, x, k, size, Rfam)
        side = 'L' if x is l else 'R'
        if side in vgen:                                   # a generic computed operand writes only its own family
            own = '(X%s)' % Rfam
            if any(clobbers(F.lines[n0:], '(%s)' % X_) for X_ in ('XWA', 'XBC', 'XDE', 'XHL') if '(%s)' % X_ != own):
                raise Unsupported('cmp_wide: a computed operand over another register')
        return v_
    def ld(dst, src): F.emit('ld', '%s,%s' % (dst, src)); cw_pin(F, dst)
    def cp(a, b): F.emit('cp', '%s,%s' % (a, b)); return cc
    def cpmem(mem, reg):                                  # a memory left against a register right
        return cp(mem, reg) if ordered else cp(reg, mem)
    memk = ('G', 'M'); addrk = ('P', 'D', 'X', 'A'); compk = ('N', 'U', 'B', 'T'); wak = ('N', 'U')
    if L == 'A':                                            # the member array through a pointer on the left: (XWA+C)
        if R == 'K':                                        # ci_l_AK: ... / ld XWA,(_gps) / cpw (XWA+C),0x7
            a = cw_addr(F, lk, size, P='XWA'); F.emit({1: 'cpb', 2: 'cpw', 4: 'cp'}[size], '%s,%s' % (a, hx(fold(r).value & ((1 << 8 * size) - 1)))); return cc
        if R in memk: a = cw_addr(F, lk, size, P='XWA'); ld(XW, a); return cp(XW, rk[1])   # ci_l_AG
        return None                                         # (AP, AI, AA, AY: unfitted)
    if R == 'A' and L in memk + ('K',):                     # ci_l_GA: ... / ld E,A / ld XBC,(_hps) / ld WA,(_gi) / cp WA,(XBC+E)
        a = cw_addr(F, rk, size, P='XBC'); ld(XW, lk[1]) if L != 'K' else ld(XW, hx(fold(l).value)); return cp(XW, a)
    if R == 'A' and L in ('P', 'D'):                        # ci_l_PA: ld XHL,(_gpi) / the member's address / ld WA,(XHL) / cp WA,(XBC+E)
        ld('XHL', lk[1]); a = cw_addr(F, rk, size, P='XBC'); ld(XW, '(XHL+%s)' % hx(lk[2]) if lk[2] else '(XHL)'); return cp(XW, a)
    if R == 'A' and L == 'X' and size != 1:                 # ci_l_YA: ld HL,WA / add HL,HL / lda XIX,_gia / ... / ld WA,(XIX+HL)
        ldidx(F, lk, 'HL'); scale_reg(F, 'HL', size, 'sla' if size == 4 else 'add'); F.emit('lda', 'XIX,%s' % lk[1])
        a = cw_addr(F, rk, size, P='XBC'); ld(XW, '(XIX+HL)'); return cp(XW, a)
    if R == 'A': return None
    # ---- an extension on either side (cmpordl2.c Z / W / V / U kinds)
    if L in ('Z', 'ZU') or R in ('Z', 'ZU'):
        if R == 'Z':
            if L in memk: cw_ext(F, rk, size, 'WA'); return cpmem(lk[1], XW)          # cl_l_GZ: cp (_gl),XWA
            if L in addrk:                                                            # cl_l_PZ: ld XBC,(_gpl) / ... / cp (XBC),XWA
                a = cw_addr(F, lk, size, P='XBC', I='BC', B='XDE'); cw_ext(F, rk, size, 'WA'); return cpmem(a, XW)
            if L == 'Z' and lk[2] == 2: cw_ext(F, rk, size, 'WA'); cw_ext(F, lk, size, 'BC'); return cp(XB, XW)   # cl_l_WZ, WW
            if L == 'Z': cw_ext(F, rk, size, 'BC'); cw_ext(F, lk, size, 'WA'); return cp(XW, XB)   # cl_l_ZZ, ZW
            if L == 'ZU':                                                             # cl_l_UZ: ld XBC,XWA in between
                cw_ext(F, rk, size, 'WA'); ld(XB, XW); cw_ext(F, lk, size, 'WA'); return cp(XW, XB)
            return None
        if R == 'ZU':
            if L in memk: cw_ext(F, rk, size, 'WA'); ld(XB, lk[1]); return cp(XB, XW)  # cl_l_GU: ld XBC,(_gl) / cp XBC,XWA
            if L == 'X': cw_ext(F, rk, size, 'DE'); v = cw_load(F, lk, size, base='XBC'); return cp(v, XD)   # cl_l_YU
            if L in addrk: cw_ext(F, rk, size, 'BC'); v = cw_load(F, lk, size); return cp(v, XB)   # cl_l_PU, IU
            if L in ('Z', 'ZU'): cw_ext(F, rk, size, 'BC'); cw_ext(F, lk, size, 'WA'); return cp(XW, XB)   # cl_l_UU
            return None
        if L == 'Z':
            if R == 'K': cw_ext(F, lk, size, 'WA'); return cp(XW, hx(fold(r).value & ((1 << 8 * size) - 1)))
            if R in memk: cw_ext(F, lk, size, 'WA'); return cp(XW, rk[1])              # cl_l_ZG
            if R in addrk:                                                            # cl_l_ZP: ld XBC,(_hpl) / ... / cp XWA,(XBC)
                a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); cw_ext(F, lk, size, 'WA'); return cp(XW, a)
            return None
        if R == 'K': cw_ext(F, lk, size, 'WA'); return cp(XW, hx(fold(r).value & 0xffffffff))   # cl_l_UK
        if R in memk: ld(XB, rk[1]); cw_ext(F, lk, size, 'WA'); return cp(XW, XB)      # cl_l_UG: ld XBC,(_hl) first
        if R in ('P', 'D'):                                                           # cl_l_UP: ld XWA,(_hpl) / ld XBC,(XWA)
            ld('XWA', rk[1]); ld(XB, '(XWA+%s)' % hx(rk[2]) if rk[2] else '(XWA)'); cw_ext(F, lk, size, 'WA'); return cp(XW, XB)
        return None
    # ---- the right is a constant or memory
    if R == 'K':
        kv = fold(r).value
        if kv is None: return None
        if kv == 0: return None                            # (the older path: or XWA,XWA for a long's == 0 / != 0, r4_09_15;
                                                           #  cmp_uc.c ge_uc_br0 folds an unsigned >= 0 to j _hit)
        K = hx(kv & (0xffffffff if size == 4 else 0xff))
        if size in (1, 2) and L in memk + addrk:         # cc_l_GK: cpb (_gc),0x7; cc_l_PK: ld XWA,(_gp) / cpb (XWA),0x7; ci_l_YK: cpw (XBC+WA),0x7
            cpk = 'cpb' if size == 1 else 'cpw'
            if L in memk: F.emit(cpk, '%s,%s' % (lk[1], K)); return cc
            a = cw_addr(F, lk, size, P='XWA', I='BC' if size == 1 else 'WA', B='XBC')
            F.emit(cpk, '%s,%s' % (a, K)); return cc
        if L == 'N' and size == 1 and kv not in (0, 1): K = '0x1'   # (the truth value, as cmpord.c ci_l_NK)
        if L == 'N' and size == 1:
            v = value(l, lk, 'WA'); return cp('WA', K)     # cc_l_NK: cpb (_gc),0x0 / scc eq,WA / cp WA,0x1
        Rl = XB if L == 'S' else (XH if L == 'F' else XW)
        v = value(l, lk, famof(Rl))
        return cp(v, K)
    if R in memk:
        if not ordered and L == 'M' and R == 'M': ld(XW, rk[1]); return cp(XW, lk[1])
        if not ordered and L == 'F' and R == 'M': v = value(l, lk, 'HL'); return cp(rk[1], v)   # cl_e_FM: cp (_hs + 0x4),XHL
        if L == 'T' and R == 'M':                         # cl_l_TM: lda XWA,_hs + 0x4 / arms into XBC / cp XBC,(XWA)
            if size == 1: F.emit('lda', 'XWA,%s' % rk[1][1:-1]); v = value(l, lk, 'BC'); return cp(v, '(XWA)')
            F.emit('lda', 'XWA,%s' % rk[1][1:-1]); v = value(l, lk, 'BC'); return cp(v, '(XWA)')
        if not ordered and L in addrk and R == 'M':       # cl_e_PM: ld XBC,(_gpl) / ld XWA,(_hs + 0x4) / cp XWA,(XBC)
            a = cw_addr(F, lk, size, P='XBC', I='BC', B='XDE'); ld(XW, rk[1]); return cp(XW, a)
        if L == 'N' and size == 1:                        # cc_l_NG: ld A,(_hc) / ld C,A / exts BC / cpb .. / scc eq,WA / cp WA,BC
            if F.opt: ld('C', rk[1])                       # -O: ld C,(_hc)
            else: ld('A', rk[1]); ld('C', 'A')
            F.emit('exts', 'BC'); cw_truth(F, l, 'WA'); return cp('WA', 'BC')
        if L == 'X' and size == 1 and len(lk) == 5:       # -Xr cc_l_XG: lda XBC,_gca / ld A,(XBC+WA); a register temporary:
            a = cw_addr(F, lk, size, P='XBC' if lk[4][0] == 'regp' else 'XWA', I='DE')   # cc_l_YG: lda XWA,_gca / ld A,(XWA+BC)
            ld('A', a); return cp('A', rk[1])
        Rl = XB if L == 'S' else (XH if L == 'F' else XW)
        v = value(l, lk, famof(Rl))
        return cp(v, rk[1])
    # ---- the right is a pointer, a member through a pointer or an element
    if R in addrk:
        if R == 'X' and size == 1 and len(rk) == 5 and rk[4][0] == 'regp' and L in memk:   # cc_l_GX -Xr: lda XDE,_hca / ld C,(_gc) / cp C,(XDE+WA)
            F.emit('lda', 'XDE,%s' % rk[1]); v = value(l, lk, 'BC'); return cp(v, '(XDE+WA)')
        if L == 'X' and size == 1 and len(lk) == 5 and lk[4][0] == 'regp' and R in ('P', 'D'):   # cc_l_XP -Xr: lda XBC,_gca / ld XDE,(_hp) / ld A,(XBC+WA) / cp A,(XDE)
            F.emit('lda', 'XBC,%s' % lk[1]); a = cw_addr(F, rk, size, P='XDE'); ld('A', '(XBC+WA)'); return cp('A', a)
        if L == 'F':                                       # cl_l_FP: cal _gfl / ld XWA,(_hpl) / cp XHL,(XWA); cl_e_FP: cp (XWA),XHL
            v = value(l, lk, 'HL'); a = cw_addr(F, rk, size, P='XWA', I='WA' if size != 1 else 'BC', B='XBC')
            return cp(v, a) if ordered else cp(a, v)
        if not ordered and L == 'M':                       # cl_e_MP: ld XWA,(_hpl) / ld XWA,(XWA) / cp XWA,(_gs + 0x4)
            v = cw_load(F, rk, size); return cp(v, lk[1])
        if L == 'T':                                       # cl_l_TP: ld XWA,(_hpl) / arms into XBC / cp XBC,(XWA)
            if R == 'X' and size == 4:                     # cl_l_TX: the element's address combined in XWA
                ldidx(F, rk, 'WA'); scale_reg(F, 'WA', size, 'sla'); F.emit('lda', 'XBC,%s' % rk[1])
                F.emit('exts' if rk[3] else 'extz', 'XWA'); F.emit('add', 'XWA,XBC'); a = '(XWA)'
            else: a = cw_addr(F, rk, size, P='XWA', I='BC', B='XWA', combine=True)
            v = value(l, lk, 'WA' if size == 1 and R == 'X' else 'BC'); return cp(v, a)
        if L in ('B',) or (L == 'S' and R != 'X'):        # cl_l_BP: ld XWA,(_hpl) / ld XBC,(_gl) / sub XBC,(_gm) / cp XBC,(XWA)
            if size == 1:                                  # cc_l_BP: ld XBC,(_hp) / ld A,(_gc) / sub A,(_gd) / cp A,(XBC)
                a = cw_addr(F, rk, size, P='XBC', I='BC'); v = value(l, lk, 'WA'); return cp(v, a)
            if R == 'X':                                   # cl_l_BX: index WA / XBC, the left in XDE
                a = cw_addr(F, rk, size, P='XWA', I='WA', B='XBC'); v = value(l, lk, 'DE'); return cp(v, a)
            if L == 'S':                                   # cl_l_SP: ld XBC,(_hpl) / ld XDE,(_gl) ... / cp XDE,(XBC)
                a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); v = value(l, lk, 'DE'); return cp(v, a)
            a = cw_addr(F, rk, size, P='XWA', I='WA', B='XBC'); v = value(l, lk, 'BC'); return cp(v, a)
        if L == 'S':                                       # cl_l_SX: index BC / XDE, the shift in XHL
            a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); v = value(l, lk, 'HL'); return cp(v, a)
        if L in addrk:
            if L == 'X' and R == 'X' and F.opt and lk[2] == rk[2]:   # -O: one index for both elements
                if size == 4:
                    ldidx(F, lk, 'BC'); scale_reg(F, 'BC', size, 'sla')
                    if ordered: F.emit('lda', 'XWA,%s' % lk[1]); F.emit('lda', 'XDE,%s' % rk[1]); ld('XWA', '(XWA+BC)'); return cp('XWA', '(XDE+BC)')
                    F.emit('lda', 'XDE,%s' % lk[1]); F.emit('lda', 'XWA,%s' % rk[1]); ld('XWA', '(XWA+BC)'); return cp('XWA', '(XDE+BC)')
                if ordered:                                # cc_l_XX: lda XWA,_gca / ld DE,(c) / lda XBC,_hca / ld A,(XWA+DE) / cp A,(XBC+DE)
                    F.emit('lda', 'XWA,%s' % lk[1]); ldidx(F, lk, 'DE'); F.emit('lda', 'XBC,%s' % rk[1]); ld('A', '(XWA+DE)'); return cp('A', '(XBC+DE)')
                F.emit('lda', 'XBC,%s' % lk[1]); ldidx(F, lk, 'DE'); F.emit('lda', 'XWA,%s' % rk[1]); ld('A', '(XWA+DE)'); return cp('A', '(XBC+DE)')   # cc_e_XX
            if not ordered and L in addrk:                 # == : the right loads (cl_e_PP: ld XBC,(_gpl) / ld XWA,(_hpl) / ld XWA,(XWA))
                if R == 'X' and size == 4:
                    if L == 'P': ld('XDE', lk[1]); v = cw_load(F, rk, size, base='XBC'); return cp(v, '(XDE)')   # cl_e_PX
                    if L == 'D': a = cw_addr(F, lk, size, P='XBC'); v = cw_load(F, rk, size, base='XDE'); return cp(v, a)   # cl_e_DX
                    ldidx(F, lk, 'DE'); scale_reg(F, 'DE', size, 'sla'); F.emit('lda', 'XHL,%s' % lk[1])   # cl_e_XX
                    v = cw_load(F, rk, size, base='XBC'); return cp(v, '(XHL+DE)')
                if R == 'X' and size == 1 and L in ('P', 'D'):   # cc_e_PX: ld XDE,(_gp) / the element through XBC / cp A,(XDE)
                    ld('XDE', lk[1]); v = cw_load(F, rk, size, base='XBC'); return cp(v, '(XDE+%s)' % hx(lk[2]) if lk[2] else '(XDE)')
                if R == 'X' and L == 'X':                  # cc_e_XX: the left at (XDE), the right through XBC
                    a = cw_addr(F, lk, size, P='XWA', I='DE'); v = cw_load(F, rk, size, base='XBC'); return cp(v, a)
                a = cw_addr(F, lk, size, P='XBC', I='BC', B='XDE')
                v = cw_load(F, rk, size, base='XDE' if L == 'X' or rk[0] == 'X' else 'XBC'); return cp(v, a)
            if L == 'X':                                   # cl_l_XP: index WA / XBC, the right pointer in XDE, the left in XWA
                if size == 1:                              # cc_l_XP: lda XWA,_gca / ld DE,(c) / extz XDE / add XDE,XWA / ld XBC,(_hp) / ld A,(XDE) / cp A,(XBC)
                    al = cw_addr(F, lk, size, P='XWA', I='DE'); a = cw_addr(F, rk, size, P='XBC', I='BC'); ld('A', al); return cp('A', a)
                if R == 'X' and len(rk) == 5 and rk[4][0] == 'regp' and len(lk) == 5:   # cl_l_XX -Xr: ld HL,WA / sla / lda XIX / ld BC,WA / sla / lda XDE
                    ld('HL', 'WA'); scale_reg(F, 'HL', size, 'sla' if size == 4 else 'add'); F.emit('lda', 'XIX,%s' % lk[1])
                    a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); ld(XW, '(XIX+HL)'); return cp(XW, a)
                if R == 'D':                               # cl_l_XD: the element's base in XDE, the pointer in XBC
                    ldidx(F, lk, 'WA'); scale_reg(F, 'WA', size, 'sla'); F.emit('lda', 'XDE,%s' % lk[1])
                    a = cw_addr(F, rk, size, P='XBC'); ld(XW, '(XDE+WA)'); return cp(XW, a)
                ldidx(F, lk, 'WA'); scale_reg(F, 'WA', size, 'sla'); F.emit('lda', 'XBC,%s' % lk[1])
                a = cw_addr(F, rk, size, P='XDE', I='BC', B='XDE') if R != 'X' else None
                if R == 'X':                               # cl_l_XX: left XHL+WA, right XDE+BC
                    F.lines.pop(); F.emit('lda', 'XHL,%s' % lk[1]); a = cw_addr(F, rk, size, P='XDE', I='BC', B='XDE')
                    ld(XW, '(XHL+WA)'); return cp(XW, a)
                ld(XW, '(XBC+WA)'); return cp(XW, a)
            # a left pointer: its own load, the right's address, the left's deref (cl_l_PP, cl_l_DP, cl_l_PX, cl_l_DX)
            if R == 'X' and len(rk) == 5 and rk[4][0] == 'regp' and size != 1:   # -Xr: the pointer avoids XWA (cl_l_PX: XHL; cl_l_DX: XBC, the base XHL)
                if L == 'P': ld('XHL', lk[1]); a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE'); ld(XW, '(XHL)'); return cp(XW, a)
                ld('XBC', lk[1]); a = cw_addr(F, rk, size, P='XDE', I='DE', B='XHL'); ld(XW, '(XBC+%s)' % hx(lk[2]) if lk[2] else '(XBC)'); return cp(XW, a)
            PL = 'XDE' if (R == 'X' and size == 1) else 'XWA'
            ld(PL, lk[1])
            a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE')
            ld(XW, '(%s+%s)' % (PL, hx(lk[2])) if lk[2] else '(%s)' % PL); return cp(XW, a)
        # a memory, ! or - left: the right's address first, the left into XWA
        if size == 1 and L == 'N':                        # cc_l_NP: ld XWA,(_hp) / ld A,(XWA) / ld C,A / exts BC / ...
            a = cw_addr(F, rk, size, P='XWA', I='BC')
            if F.opt: ld('C', a)
            else: ld('A', a); ld('C', 'A')
            F.emit('exts', 'BC'); cw_truth(F, l, 'WA'); return cp('WA', 'BC')
        a = cw_addr(F, rk, size, P='XBC', I='BC', B='XDE')
        v = value(l, lk, 'WA'); return cp(v, a)
    # ---- the right is a call
    if R == 'F':
        if L == 'F': return None                           # (cl_l_FF: the right result saved in XIZ: unmodelled)
        vr = value(r, rk, 'HL')
        if L in memk: return cpmem(lk[1], vr) if L == 'G' else cp(lk[1], vr)   # cl_l_GF: cp (_gl),XHL; cl_e_GF: cp XHL,(_gl); cl_e_MF: cp (_gs + 0x4),XHL
        if L in addrk:                                     # cl_l_PF: ld XWA,(_gpl) / cp (XWA),XHL; cc_l_XF: cp (XBC),L
            a = cw_addr(F, lk, size, P='XWA', I='WA' if size != 1 else 'BC', B='XBC'); return cp(a, vr)
        if L == 'N' and size == 1:                        # cc_l_NF: ld C,L / exts BC / cpb .. / scc eq,WA / cp WA,BC
            if F.opt: F.emit('exts', 'HL'); cw_truth(F, l, 'WA'); return cp('WA', 'HL')   # -O: exts HL / cp WA,HL
            ld('C', 'L'); F.emit('exts', 'BC'); cw_truth(F, l, 'WA'); return cp('WA', 'BC')
        v = value(l, lk, 'BC' if L == 'S' else 'WA'); return cp(v, vr)
    # ---- the right is a shift
    if R == 'S':
        if L in memk:                                      # cl_l_GS: shift into XBC / cp (_gl),XBC
            vr = value(r, rk, 'BC'); return cpmem(lk[1], vr)
        if L == 'P':                                       # cl_l_PS: ld XDE,(_gpl) / shift into XBC / cp (XDE),XBC
            a = cw_addr(F, lk, size, P='XDE'); vr = value(r, rk, 'BC'); return cpmem(a, vr)
        if L in ('D', 'X'):                                # cl_l_DS: ld XBC,(_gps) / shift XDE / cp (XBC+0x4),XDE;
            a = cw_addr(F, lk, size, P='XBC', I='BC', B='XDE')   # cl_l_XS: index BC / XDE, shift XHL
            vr = value(r, rk, 'DE' if L == 'D' else 'HL'); return cpmem(a, vr)
        if L == 'F':                                       # cl_l_FS: cal _gfl / the shift into XBC / cp XHL,XBC; == cp XBC,XHL
            v = value(l, lk, 'HL'); vr = value(r, rk, 'BC'); return cp(v, vr) if ordered else cp(vr, v)
        vr = value(r, rk, 'BC')
        v = value(l, lk, 'DE' if L == 'S' else 'WA'); return cp(v, vr)   # cl_l_BS: cp XWA,XBC; cl_l_SS: cp XDE,XBC
    # ---- the right is computed (N, U, B, T)
    if R in compk:
        if size == 1 and R == 'N':                        # cc_l_GN: cpb (_hc),0x0 / scc eq,WA / ld BC,WA / ld A,(_gc) / exts WA / cp WA,BC
            if L == 'N':                                   # cc_l_NN: cpb (_hc),0 / scc eq,WA / cpb (_gc),0 / scc eq,BC / cp BC,WA
                cw_truth(F, r, 'WA'); cw_truth(F, l, 'BC'); return cp('BC', 'WA')
            if L == 'F':                                   # cc_l_FN: cal _gfc / ld C,L / exts BC / cpb (_hc),0x0 / scc eq,WA / cp BC,WA
                value(l, lk, 'HL')
                if F.opt: F.emit('exts', 'HL'); cw_truth(F, r, 'WA'); return cp('HL', 'WA') if ordered else cp('WA', 'HL')
                ld('C', 'L'); F.emit('exts', 'BC'); cw_truth(F, r, 'WA'); return cp('BC', 'WA') if ordered else cp('WA', 'BC')
            if L == 'X':                                   # cc_l_XN: scc eq,WA / ld DE,WA (-O: scc eq,DE) / the element / exts WA / cp WA,DE
                if F.opt: cw_truth(F, r, 'DE')
                else: cw_truth(F, r, 'WA'); ld('DE', 'WA')
                a = cw_addr(F, lk, size, P='XWA', I='BC'); ld('A', a); F.emit('exts', 'WA'); return cp('WA', 'DE')
            if F.opt: cw_truth(F, r, 'BC')
            else: cw_truth(F, r, 'WA'); ld('BC', 'WA')
            if L in memk: ld('A', lk[1])
            elif L in ('P', 'D'): a = cw_addr(F, lk, size, P='XWA'); ld('A', a)
            else: v = value(l, lk, 'WA')
            F.emit('exts', 'WA'); return cp('WA', 'BC')
        if size == 1 and L == 'N':                        # cc_l_NB: right into A / ld C,A / exts BC / cpb (_gc),0 / scc eq,WA / cp WA,BC
            if F.opt: value(r, rk, 'BC')                   # -O: the right computed in C (ld C,(_hc) / neg C; the ?: arms into C)
            else: value(r, rk, 'WA'); ld('C', 'A')
            F.emit('exts', 'BC'); cw_truth(F, l, 'WA'); return cp('WA', 'BC')
        if L in memk:                                      # cl_l_GB: ld XWA,(_hl) / sub XWA,(_hm) / cp (_gl),XWA
            if L == 'M' and R == 'T':                      # cl_l_MT: lda XBC,_gs + 0x4 / the arms into XWA / cp (XBC),XWA
                if size == 1 and ' + ' not in lk[1] and not F.opt: F.emit('lda', 'XWA,%s' % lk[1][1:-1]); ld('XBC', 'XWA')   # cc_l_MT: through XWA
                else: F.emit('lda', 'XBC,%s' % lk[1][1:-1])
                vr = value(r, rk, 'WA'); return cpmem('(XBC)', vr)
            vr = value(r, rk, 'WA'); return cpmem(lk[1], vr)
        if L == 'P':                                       # cl_l_PB: ld XBC,(_gpl) / right into XWA / cp (XBC),XWA
            a = cw_addr(F, lk, size, P='XBC'); vr = value(r, rk, 'WA'); return cpmem(a, vr)
        if L == 'D':
            if R in wak or R == 'T':                       # cl_l_DN: ld XBC,(_gps) / right XWA / cp (XBC+0x4),XWA; cl_l_DT: inc 0x4,XBC
                a = cw_addr(F, lk, size, P='XBC', combine=(R == 'T')); vr = value(r, rk, 'WA'); return cpmem(a, vr)
            a = cw_addr(F, lk, size, P='XWA'); vr = value(r, rk, 'BC'); return cpmem(a, vr)   # cl_l_DB: cp (XWA+0x4),XBC
        if L == 'X':
            if size == 1:                                  # cc_l_XB: the element's address in XBC, the right into A
                a = cw_addr(F, lk, size, P='XWA', I='BC'); vr = value(r, rk, 'WA'); return cpmem(a, vr)
            if R in wak:                                   # cl_l_XN: index BC / XDE, right XWA, cp (XDE+BC),XWA
                a = cw_addr(F, lk, size, P='XBC', I='BC', B='XDE'); vr = value(r, rk, 'WA'); return cpmem(a, vr)
            if R == 'T':                                   # cl_l_XT: index WA / XBC, lda XBC,XBC+WA, arms XWA, cp (XBC),XWA
                a = cw_addr(F, lk, size, P='XBC', I='WA', B='XBC', combine=True); vr = value(r, rk, 'WA'); return cpmem(a, vr)
            a = cw_addr(F, lk, size, P='XBC', I='WA', B='XBC'); vr = value(r, rk, 'DE'); return cpmem(a, vr)   # cl_l_XB
        if L == 'F':                                       # cl_l_FB: cal / right into XWA / cp XHL,XWA; == cp XWA,XHL
            v = value(l, lk, 'HL'); vr = value(r, rk, 'WA'); return cp(v, vr) if ordered else cp(vr, v)
        if L == 'S':                                       # cl_l_SB: right first into XBC, the shift into XDE, cp XDE,XBC
            if R == 'N':
                if F.opt: cw_truth(F, r, 'BC')
                else: cw_truth(F, r, 'WA'); ld('BC', 'WA')
                F.emit('exts', 'XBC')
            elif R == 'U' and F.opt: value(r, rk, 'BC')
            elif R == 'U': value(r, rk, 'WA'); ld(XB, XW)
            else: value(r, rk, 'BC')
            v = value(l, lk, 'DE'); return cp(v, XB)
        # both computed
        if size == 1:
            if L == 'T' and R in ('U', 'B'):               # cc_l_TU: right into A / arms into C / cp C,A
                value(r, rk, 'WA'); value(l, lk, 'BC'); return cp('C', 'A')
            if L in ('U', 'B') and R in ('U', 'B'):        # cc_l_UU: right into A / ld C,A / left into A / cp A,C (-O: right in C)
                if F.opt: value(r, rk, 'BC')
                else: value(r, rk, 'WA'); ld('C', 'A')
                v = value(l, lk, 'WA'); return cp(v, 'C')
            if L == 'T' and R == 'T':                      # cc_l_TT: right arms A, left arms C, cp C,A
                value(r, rk, 'WA'); value(l, lk, 'BC'); return cp('C', 'A')
            if R == 'T':                                   # cc_l_BT: right arms into C, left into A, cp A,C
                value(r, rk, 'BC'); v = value(l, lk, 'WA'); return cp(v, 'C')
            return None
        if L in wak and R in wak:                          # cl_l_NN: right in WA -> XBC, left XWA, cp XWA,XBC
            if R == 'N':                                   # (-O: scc eq,BC / exts XBC)
                if F.opt: cw_truth(F, r, 'BC')
                else: cw_truth(F, r, 'WA'); ld('BC', 'WA')
                F.emit('exts', 'XBC')
            elif F.opt: value(r, rk, 'BC')                 # (-O: ld XBC,(_hl) / cpl BC / cpl QBC / inc 0x1,XBC)
            else: value(r, rk, 'WA'); ld('XBC', 'XWA')
            v = value(l, lk, 'WA'); return cp(v, 'XBC')
        if L in wak:                                       # cl_l_NB: right into XBC, left XWA, cp XWA,XBC
            value(r, rk, 'BC'); v = value(l, lk, 'WA'); return cp(v, 'XBC')
        vr = value(r, rk, 'WA'); v = value(l, lk, 'BC'); return cp(v, vr)   # cl_l_BB, cl_l_BN: cp XBC,XWA
    return None

def cmp_order(F, e, l, r, size, op, cc, swapped=False):
    """the operands of a 16-bit compare (corpus/probes/cmpord.c, run 2026-11-10-12-micro-cmpord; the order of the
    operand-order rule): a computed right goes to WA and a memory left stays in memory (cp (_gi),WA for an ordered
    compare, cp WA,(_gi) for == / !=); a computed left goes to WA against a memory right (cp WA,(_hi)); two computed
    operands: the right first into WA, the left into BC (cp BC,WA), unless the left is a unary minus, which owns WA
    (the right then in BC); a shift's value is in BC with the count in WA (cp (_gi),BC; cp BC,(_hi)); a left *p stays
    (XBC) against a computed right (cp (XBC),WA) and loads into WA against a memory right; a right *p takes XBC
    (cp WA,(XBC)); a left g[i] stays (XBC+WA) against a computed right (cp (XBC+WA),DE); a right g[i] takes BC / XDE
    against a left loaded into WA (cp WA,(XDE+BC)); a constant right is cpw mem,K or cp reg,K.  None where the shape
    is not one of these (two memory operands, a ?: beside a member or element, two indexed elements, ...)."""
    cl, cr = ev_class(F, l), ev_class(F, r)
    if cl is None or cr is None or cl == 'K': return None
    lk, rk = ev_addr_kind(F, l), ev_addr_kind(F, r)
    lx, rx = ev_core(l), ev_core(r)
    if any(getattr(x, 'ty', None) is None or x.ty.size != 2 for x in (lx, rx) if x.k != 'const'): return None
    lv, rv = cl == 'V', cr == 'V'                          # (r1_05_18: two char-narrowed operations compare as bytes)
    if not (lv or rv or lk is not None or rk is not None): return None   # two memory operands: the older paths
    if (lx.k == 'cond' and cr == 'A' and rk is None) or (rx.k == 'cond' and cl == 'A' and lk is None): return None
    if lk == 'X' and rk == 'X': return None                # (ci_l_MT: lda XWA,_gs first; a cond beside *p is plain)
    ordered = op in ('<', '<=', '>', '>=')
    def shift(x): return x.k == 'bin' and x.op in ('<<', '>>') and fold(x.r).k != 'const'
    lS, rS = lv and shift(lx), rv and shift(rx)
    lU = lv and lx.k == 'un' and lx.op == '-'
    if (lS or rS) and 'X' in (lk, rk): return None         # (ci_l_XS, ci_l_SX: the index goes through WA)
    rconst = fold(r).k == 'const' and fold(r).value is not None
    if not ordered and not swapped and not lv and not rv and cl != 'G' and cr != 'G' and (lk or rk):
        return cmp_order(F, e, r, l, size, op, cc, True)   # == of two offset or addressed operands: the right loads
    if lx.k == 'cond' and rk == 'X': return None           # (ci_e_MP: ld XWA,(_hpi) / ld WA,(XWA) / cp WA,(_gs);
    live = {r_ for r_ in live_regs(F) if any(uses_decl(F.f.body, d_) for d_ in list(F.f.params) + list(F.f.decls)
                                            if getattr(d_, 'reg', None) == r_ and d_ not in F.dead)}
    taken = set(live)
    def pick(avoid=()):
        for f_ in ('WA', 'BC', 'DE', 'HL'):
            if f_ not in taken and f_ not in avoid: taken.add(f_); return f_
        raise Unsupported('cmp_order: no free register')
    if lS or rS: taken.add('WA')                           # the count
    plan = {}
    if lU: plan['L'] = 'WA'; taken.add('WA')                # ci_l_UB: neg WA, the right in BC
    if lk == 'X':                                          # an indexed element claims its registers first, on either
        i_ = pick(); b_ = pick(); plan['LA'] = (None, FAM[i_][2], 'X' + b_)   # side (ci_l_XB: (XBC+WA) stays, the
    if rk == 'X': i_ = pick(); b_ = pick(); plan['RA'] = (None, FAM[i_][2], 'X' + b_)   # right value in DE; ci_l_NX:
    if rk == 'P' and (rv or lv): plan['RA'] = ('X' + pick(), None, None)   # cp DE,(XBC+WA)); a right *p before a left
    if not rv and not rconst:                              # (ci_l_NP: cp BC,(XWA); ci_l_UP: cp WA,(XBC)); against a
        if lk == 'P': plan['LA'] = ('X' + pick(), None, None); plan['L'] = plan['LA'][0][1:]   # memory or addressed
        elif lk == 'X': plan['L'] = next(k for k, v in FAM.items() if v.get(2) == plan['LA'][1])   # right the left
        elif not lv: plan['L'] = pick()                    # loads into a register: ci_l_PG: ld XWA,(_gpi) / ld WA,(XWA) /
    elif rconst and lk == 'P': plan['LA'] = ('X' + pick(), None, None)   # cp WA,(_hi); ci_l_XG: ld WA,(XBC+WA); ci_l_GX:
    if rk == 'P' and 'RA' not in plan: plan['RA'] = ('X' + pick(), None, None)   # ld WA,(_gi).  A constant right keeps the left in
    if rv: plan['R'] = pick()                              # memory (ci_l_PK: cpw (XWA),0x7); two pointers: the left first
    if lv and 'L' not in plan: plan['L'] = pick()          # ci_l_NB: the left value in BC
    if lk == 'P' and 'LA' not in plan: plan['LA'] = ('X' + pick(), None, None)   # ci_l_PB: XBC behind the right's WA
    # emission: addresses in textual order, the right value, the left value or load, the compare
    lm = rm = None
    if 'LA' in plan: lm = ev_address(F, l, *plan['LA'])
    if 'RA' in plan: rm = ev_address(F, r, *plan['RA'])
    n0 = len(F.lines)
    if rv:
        f_ = gen(F, r, plan['R'], size)
        if f_ not in FAM or size not in FAM[f_]: raise Unsupported('cmp_order right value')
        R = FAM[f_][size]
        if lm and clobbers(F.lines[n0:], lm): raise Unsupported('cmp_order right over the left address')
    elif rm is not None: R = rm
    else: R = mem_operand(F, r)
    if R is None: return None
    n1 = len(F.lines)
    if lv:
        f_ = gen(F, l, plan['L'], size)
        if f_ not in FAM or size not in FAM[f_]: raise Unsupported('cmp_order left value')
        L = FAM[f_][size]
    elif 'L' in plan:                                      # a memory or addressed left loaded into a register
        src = lm if lm else mem_operand(F, l)
        if src is None: return None
        F.emit('ld', '%s,%s' % (FAM[plan['L']][size], src)); L = FAM[plan['L']][size]
        if rm is not None and clobbers(F.lines[n1:], rm): raise Unsupported('cmp_order left load over the right address')
    elif lm is not None: L = lm
    else: L = mem_operand(F, l)
    if L is None: return None
    if rv and clobbers(F.lines[n1:], '(%s)' % FAM[f_ if False else plan['R']][4]) and not lv:
        raise Unsupported('cmp_order left over the right value')
    if (rv or rm is not None) and clobbers(F.lines[n1:], rm or '(%s)' % FAM[plan['R']][4]):
        raise Unsupported('cmp_order left over the right')
    Lreg = L in ('WA', 'BC', 'DE', 'HL'); Rreg = R in ('WA', 'BC', 'DE', 'HL')
    rc = fold(r)
    if rc.k == 'const' and rc.value is not None and not rv:
        K = hx(rc.value & 0xffff)
        if Lreg: F.emit('cp', '%s,%s' % (L, K))
        else: F.emit('cpw', '%s,%s' % (L, K))
        return cc
    if Lreg: F.emit('cp', '%s,%s' % (L, R)); return cc
    if Rreg:
        if ordered: F.emit('cp', '%s,%s' % (L, R))         # cp (_gi),WA
        else: F.emit('cp', '%s,%s' % (R, L))               # cp WA,(_gi)
        return cc
    return None

def ev_mul_div(F, e, op, ACC, fam, size, src_op):
    """the multiply or divide of evorder_bin's accumulator (evorder_d.c: ld WA,(_gi) / exts XWA / divs XWA,BC /
    ld HL,WA; the remainder ld HL,QWA; -O with a plain left: divs XHL,src)"""
    X = FAM[ACC][4]
    if op == '*':
        F.emit('muls' if e.ty.signed else 'mul', '%s,%s' % (X, src_op))
        if fam != ACC: F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[ACC][size]))
        return fam
    F.emit('exts' if e.ty.signed else 'extz', X)
    F.emit('divs' if e.ty.signed else 'div', '%s,%s' % (X, src_op))
    res = FAM[ACC][size] if op == '/' else Q[ACC]
    if res != FAM[fam][size]: F.emit('ld', '%s,%s' % (FAM[fam][size], res))
    return fam

def evorder_bin(F, e, op, l, r, fam, size, ctx='HL'):
    """the order of evaluation of V4.23's binary operators at 16 bits (corpus/probes/evorder.c, run
    2026-11-10-9-micro-evorder, the same at the four option sets).  One operand is the accumulator (HL; XWA for *),
    the other the instruction's source.  For - the left is the accumulator.  For + & | ^ * (commutative) a value
    (class V) is the accumulator when the other side is not one, a constant never is, two addressed operands make
    the right one the accumulator, otherwise the left (x_GB: ld HL,(_hi) / sub HL,(_hj) / xor HL,(_gi); x_MM:
    ld HL,(_hs) / xor HL,(_gs); x_PG: ld XWA,(_gpi) / ld HL,(XWA) / xor HL,(_hi)).  Code order: the addresses of
    *p / p->m / g[i] operands in textual order, then the source's value if it needs computing, then the
    accumulator's value or load, then the operator.  Registers: the source value takes WA (BC when the accumulator's
    code needs WA: ! - or a shift; DE after an indexed accumulator: s_XB); a ! or - on the source side computes in
    WA regardless (s_XN: the index moves to BC / XDE); a ! or - that is the accumulator computes in WA and moves to
    HL (s_NG: scc eq,WA / ld HL,WA).  Addresses take the first free family in WA, BC, DE order after what the other
    operand needs: the right *p takes XWA and the left XBC (s_PP, x_PP), a left *p takes XDE before a right g[i]
    (s_PX), a left g[i] keeps WA / XBC and a right *p takes XDE (s_XP).  Returns None where the shape is not one
    of these (a ?: beside a member or element, two indexed elements, a shift beside an indexed element, ...)."""
    cl, cr = ev_class(F, l), ev_class(F, r)
    if cl is None or cr is None: return None
    lx, rx = ev_core(l), ev_core(r)
    if op == '-' and rx.k == 'un' and rx.op == '-' and rx.ty is not None and rx.ty.size == size and cl != 'K':
        from frontend import N                           # s_GU: gi - -hi -> ld HL,(_gi) / add HL,(_hi) (s_KU keeps
        if lx.k == 'un' and lx.op == '-': return evorder_bin(F, e, '-', rx.e, lx.e, fam, size)   # the neg; s_UU: hi - gi)
        if lx.k == 'cond' or (lx.k == 'bin' and lx.op == '-' and fold(lx.l).k == 'const'): return None   # (s_CU)
        return evorder_bin(F, e, '+', l, rx.e, fam, size)
    if op in '+-' and cr == 'K' and lx.k == 'bin' and lx.op == '-' and fold(lx.l).k == 'const' and \
            fold(lx.l).value is not None and fold(rx).value is not None:
        from frontend import N                           # s_CK: (256 - gi) - 7 -> ld HL,0xf9 / sub HL,(_gi)
        k = fold(lx.l).value + (fold(rx).value if op == '+' else -fold(rx).value)
        return evorder_bin(F, e, '-', N('bin', op='-', l=N('const', value=k, ty=lx.l.ty), r=lx.r, ty=lx.ty), lx.r, fam, size) \
            if False else gen_bin(F, N('bin', op='-', l=N('const', value=k, ty=lx.l.ty), r=lx.r, ty=e.ty), fam, size, False)
    if (lx.k == 'cond' and cr == 'A') or (rx.k == 'cond' and cl == 'A'): return None   # (s_MT: lda XWA,_gs first)
    comm = op in ('+', '&', '|', '^', '*')
    mulop = op in ('*', '/', '%')                          # the accumulator is XWA (divs XWA,src; the remainder in QWA)
    if comm:
        if cr == 'V' and cl != 'V': acc, src = r, l
        elif cl == 'V': acc, src = l, r
        elif cr == 'K': acc, src = l, r
        elif cl == 'K': acc, src = r, l
        elif cl == 'A' and cr == 'A': acc, src = r, l
        else: acc, src = l, r
    else: acc, src = l, r
    if acc is r and ev_class(F, r) == 'K': return None
    ak, sk = ev_addr_kind(F, acc), ev_addr_kind(F, src)
    acc_v = ev_class(F, acc) == 'V'; src_v = ev_class(F, src) == 'V'
    if ak == 'X' and sk == 'X': return None                # (s_XX, x_XX: the index is shared)
    src_shift = src_v and ev_natural_wa(F, src) and ev_core(src).k == 'bin'
    acc_shift = acc_v and ev_natural_wa(F, acc) and ev_core(acc).k == 'bin'
    if src_shift and (ak is not None or ev_natural_wa(F, acc)): return None   # (s_XS: IX; s_SS)
    if acc_shift and sk == 'X': return None                # (s_SX: the index goes through WA)
    live = {r_ for r_ in live_regs(F) if any(uses_decl(F.f.body, d_) for d_ in list(F.f.params) + list(F.f.decls)
                                            if getattr(d_, 'reg', None) == r_ and d_ not in F.dead)}
                                                           # (a parameter the function never reads holds nothing:
                                                           # -Xr s_DG keeps ld XWA,(_gps) with c unused)
    ACC = 'WA' if mulop else fam                           # ctx HL: the result register; ctx WA (a stored value):
    if mulop and getattr(F, 'mul_acc_fam', None) == fam and fam in ('BC', 'DE'): ACC = fam   # (store_plan: divs XBC)
    if op == '*' and F.opt and not acc_v and not src_v: ACC = fam   # WA reserved (evorder_st.c es_s_GB: the source in
    if op == '/' and F.opt and not acc_v and ctx == 'HL': ACC = fam   # (d_GG, d_GB -O: divs XHL,src; d_BG: XWA)
    if mulop and (ak == 'X' or 'WA' in live): return None           # BC); ctx ANY (a pushed argument): decided after
    if mulop and ctx != 'HL' and ctx != 'WA' and ctx != 'ANY': return None
    if ctx == 'ANY' and not mulop: ACC = None              # the plan, the first free family (ea_s_GB: BC after the
    def decl_order(x):                                     # a folded single-use local: the order it was declared in
        d_ = getattr(strip(x), 'from_local', None) or getattr(ev_uncast(x), 'from_local', None)
        return F.f.decls.index(d_) if d_ is not None and d_ in F.f.decls else None
    acc_first = acc_v and src_v and decl_order(acc) is not None and decl_order(src) is not None and \
        decl_order(acc) < decl_order(src)                  # ra_noloop: x * y with x = a + b, y = a - b -> x in WA first
    # register plan: an index claims WA and XBC first, then the source value WA (BC when the accumulator's code
    # needs WA), then pointers take the next free family; a right pointer prefers XWA; for * the accumulator's
    # pointer may use XWA (m_PG: ld XWA,(_gpi) / ld WA,(XWA) / muls XWA,(_hi))
    acc_wa = ev_natural_wa(F, acc) or (mulop and ACC == 'WA') or ACC == 'WA'   # the accumulator's code needs WA
    src_nat_wa = src_v and ev_core(src).k == 'un' and ev_core(src).op in ('!', '-') and not (F.opt and acc_wa)
                                                           # ! - on the source side: WA (under -O too: s_XN O3XS
                                                           # scc eq,WA), unless -O and the accumulator needs WA: then
                                                           # straight to its register (m_BN O3XS: scc eq,BC)
    taken = set(live)
    def pick(avoid=()):
        for f_ in ('WA', 'BC', 'DE'):
            if f_ not in taken and f_ not in avoid: taken.add(f_); return f_
        raise Unsupported('evorder: no free register')
    plan = {}                                               # id(node) -> (P, I, B) or value family
    order = [l, r]
    hard_wa = acc_wa or src_nat_wa or src_shift or mulop   # WA is spoken for before the indexes (m_GX -O:
    if hard_wa: taken.add('WA')
    acc_self = (ACC == 'WA' or mulop) and ak is not None and not src_nat_wa and not src_shift   # the WA (or multiply)
                                                            # accumulator is loaded from
    if acc_self and 'WA' in taken: taken.discard('WA')      # its own pointer or index (es_s_PP: ld XWA,(_gpi) ... ld WA,(XWA))
    if acc_self and ak == 'P': plan[id(acc)] = ('XWA', None, None); taken.add('WA')
    for x in order:                                        # indexes first (s_XB: WA / XBC, the value in DE; s_XN: BC / XDE)
        if ev_addr_kind(F, x) == 'X' and id(x) not in plan:
            i_ = pick(); b_ = pick(); plan[id(x)] = (None, FAM[i_][2], 'X' + b_)
    if acc_self and 'WA' not in taken: taken.add('WA')
    if src_v and not src_nat_wa:                           # then the source value
        if src_shift: taken.discard('WA'); plan['V'] = pick(('WA',)); taken.add('WA')   # (s_PS: BC, the count in WA)
        else: plan['V'] = pick()
    elif src_v:
        plan['V'] = 'WA'
        if acc_wa: plan['Vmove'] = pick(('WA',))            # (es_s_PN: scc eq,WA / ld BC,WA, the pointer then in XDE)
    if ev_addr_kind(F, r) == 'P' and id(r) not in plan and 'WA' not in taken:
        plan[id(r)] = ('XWA', None, None); taken.add('WA') # a right pointer takes XWA (s_PP, x_PP)
    for x in order:
        if id(x) in plan or ev_addr_kind(F, x) != 'P': continue
        plan[id(x)] = ('X' + pick(), None, None)
    if mulop or ACC == 'WA': taken.add('WA')
    if ACC is None:                                        # ctx ANY: the accumulator takes its index register (ea_s_XB:
        if ev_natural_wa(F, acc): ACC = 'WA'               # (ea_s_NG, ea_s_NB: the ! owns WA, computed there)
        elif ak == 'X': ACC = next(k for k, v in FAM.items() if v.get(2) == plan[id(acc)][1])
        elif ak == 'P': ACC = plan[id(acc)][0][1:]          # ld WA,(XBC+WA)), its own pointer's family (ea_s_PG: ld WA,(XWA)),
        else:                                              # else the first free family (ea_s_GB: BC after the source's WA)
            ACC = next((f_ for f_ in ('WA', 'BC', 'DE', 'HL') if f_ not in taken), None)
            if ACC is None: return None
        fam = ACC
    if ctx == 'ANY' and mulop: fam = 'WA'                  # (_calloc: mul XWA,(XSP+0xa) / push WA)
    # emission
    n_addr = len(F.lines); operands = {}
    for x in order:
        k = ev_addr_kind(F, x)
        if k is None: continue
        P, I, B = plan[id(x)]
        operands[id(x)] = ev_address(F, x, P, I, B)
    if acc_first:
        R = FAM[ACC][size]; n1 = len(F.lines)
        f_ = gen(F, acc, ACC, size)
        if f_ != ACC:
            if f_ not in FAM or size not in FAM[f_]: raise Unsupported('evorder accumulator')
            F.emit('ld', '%s,%s' % (R, FAM[f_][size]))
        V = plan['V']; n0 = len(F.lines)
        f_ = gen(F, src, V, size)
        if f_ not in FAM or size not in FAM[f_] or f_ == ACC: raise Unsupported('evorder source after the accumulator')
        if clobbers(F.lines[n0:], '(%s)' % FAM[ACC][4]): raise Unsupported('evorder source overwrote the accumulator')
        src_op = FAM[f_][size]
        if mulop: return ev_mul_div(F, e, op, ACC, fam, size, src_op)
        F.emit(SIMPLE_OPS[op], '%s,%s' % (R, src_op)); return fam
    if src_v:
        V = plan['V']; n0 = len(F.lines)
        f_ = gen(F, src, V, size)
        if f_ not in FAM or size not in FAM[f_]: raise Unsupported('evorder source value')
        if f_ == 'WA' and acc_wa:
            if not src_nat_wa: raise Unsupported('evorder source value in WA before a WA accumulator')
            m_ = plan.get('Vmove') or pick(('WA',)); F.emit('ld', '%s,%s' % (FAM[m_][size], FAM['WA'][size])); f_ = m_   # (s_NN, es_s_GN: ld BC,WA)
        src_op = FAM[f_][size]
        if id(acc) in operands and clobbers(F.lines[n0:], operands[id(acc)]):
            raise Unsupported('evorder source overwrote the accumulator address')
        guard = ['(%s)' % FAM[f_][4]]
    elif id(src) in operands: src_op = operands[id(src)]; guard = [src_op]
    else:
        src_op = mem_operand(F, src); guard = []
        if src_op is None: return None
        if op == '*' and size == 1 and src_op.startswith('0x'): src_op = hx(int(src_op, 16) & 0xff)
    R = FAM[ACC][size]; n1 = len(F.lines); late_move = None
    if id(acc) in operands:
        F.emit('ld', '%s,%s' % (R, operands[id(acc)]))
    elif acc_v and ev_natural_wa(F, acc) and ev_uncast(acc).k == 'un' and ACC != 'WA':
        f_ = gen(F, acc, 'WA', size)                         # s_NG: cpw (_gi),0x0 / scc eq,WA / ld HL,WA
        if f_ != 'WA': raise Unsupported('evorder accumulator in WA')
        if F.opt and ev_uncast(acc).op == '-' and op != '*': late_move = R; R = FAM['WA'][size]   # -O: the operator in WA
        else: F.emit('ld', '%s,%s' % (R, FAM['WA'][size]))
    elif acc is l and ACC == 'HL' and (natural_wa(acc) or chain_wa(acc) or char_widen(F, acc)) and \
            not (src_v and src_op.startswith('WA')):
        f_ = gen(F, acc, 'WA', size)                         # ra_chains ch_g4: ld WA,(_gi) / add WA,(_gj) / add WA,(_gk) /
        if f_ not in FAM or size not in FAM[f_]: raise Unsupported('evorder chain accumulator')   # ld HL,WA / add HL,(_gm)
        F.emit('ld', '%s,%s' % (R, FAM[f_][size]))
    else:
        f_ = gen(F, acc, ACC, size)
        if f_ != ACC:
            if f_ not in FAM or size not in FAM[f_]: raise Unsupported('evorder accumulator')
            rt_ = regvar_of(strip(acc).e) if strip(acc).k == 'load' else None
            if F.opt and op == '*' and f_ in ('BC', 'DE') and f_ not in taken: ACC = f_; R = FAM[ACC][size]   # (m_SG -O:
            elif REGTEMP_INPLACE and not mulop and rt_ is not None and getattr(rt_, 'regtemp', False) and \
                    dies_here(F, strip(acc)) and (rt_.reg == 'HL' or F.opt) and f_ == rt_.reg:
                ACC = fam = f_; R = FAM[ACC][size]       # a dying register temporary in HL is the accumulator in place
                                                         # (lo_i_R0e: cal _ri / add HL,(_hi) / ld (_hi2),HL; from BC it
                                                         # moves, lo_i_Gge: ld WA,BC / add WA,(_hi), except under -O)
            else: F.emit('ld', '%s,%s' % (R, FAM[f_][size]))                                # muls XBC,(_hi) / ld HL,BC)
    if any(clobbers(F.lines[n1:], g) for g in guard if g): raise Unsupported('evorder accumulator overwrote the source')
    if mulop: return ev_mul_div(F, e, op, ACC, fam, size, src_op)
    rc = fold(src) if src is r else None
    if op in '+-' and acc is l and rc is not None and rc.k == 'const' and rc.value is not None and 1 <= rc.value <= 8:
        F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc.value), R))
    else: F.emit(SIMPLE_OPS[op], '%s,%s' % (R, src_op))
    if late_move: F.emit('ld', '%s,%s' % (late_move, R))   # (s_UG -O: ld HL,WA after sub WA,(_hi))
    return fam

def plain_hl_tree(F, x):
    """x is built in HL from memory operands alone (no other register): a variable in memory, a constant, or a
    + - & | ^ of them whose right side is such an operand"""
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == x.ty.size: x = strip(x.e)
    if x.k in ('load', 'const'):
        if x.k == 'load' and (strip(x.e).k != 'var' or getattr(strip(x.e).decl, 'reg', None) not in
                              (None, 'IZ', 'QIZ', 'XIZ')): return False
        m = mem_operand(F, x)                          # (a home in IZ survives the call: ad_di -Xr, add HL,IZ)
        return m is not None and (not family_of(m) or family_of(m) in ('IZ', 'QIZ', 'XIZ'))
    if x.k == 'bin' and x.op in ('+', '-', '&', '|', '^') and x.ty.size == 2:
        return plain_hl_tree(F, x.l) and strip(x.r).k in ('load', 'const') and plain_hl_tree(F, x.r)
    return False

def emit_shift(F, mnem, count, R):
    """a constant shift: the count field holds 1..15, 16 is written 0x0, more is two shifts (random r1_08_03:
    gpl[3] >> 26 -> sra 0xa,XWA / sra 0x0,XWA)"""
    if count > 16 and SHIFT_SPLIT: F.emit(mnem, '%s,%s' % (hx(count - 16), R)); count = 16
    F.emit(mnem, '%s,%s' % ('0x0' if count == 16 and SHIFT_SPLIT else hx(count), R))

def gen_bin(F, e, fam, size, then_ret, store=False):
    any_fam = getattr(F, 'any_fam', False); F.any_fam = False   # (push_arg's hint, for this level only)
    op = e.op
    if op == '*' and size == 2 and e.ty.kind == 'int' and fold(e.r).k == 'const' and fold(e.r).value is not None and \
            fold(e.r).value >= 8 and fold(e.r).value & (fold(e.r).value - 1) == 0:
        from frontend import N                           # arr_index.c ai_i_p_carry: x % 10 * 256 -> sla 0x8,WA
        e = N('bin', op='<<', l=e.l, r=N('const', value=fold(e.r).value.bit_length() - 1, ty=e.r.ty), ty=e.ty)
        op = '<<'
    rk_ = fold(e.r)
    F.bw_any = any_fam and size in (2, 4) and op == '-' and BIN_WIDE_ARG and not F.opt
    if BIN_WIDE and size in (1, 2, 4) and fam == 'WA' and (not any_fam or size == 1 or F.bw_any) and (op in SIMPLE_OPS or op in ('*', '/', '%')) and \
            not getattr(F, 'cl_active', None) and not getattr(F, 'l2', None) and getattr(F, 'u1_i', None) is None and \
            not getattr(F, 'elem_ops', None) and not getattr(F, 'tfam', None) and \
            not any(any(regvar_of(strip(y.e)) is not None and getattr(regvar_of(strip(y.e)), 'reg', None) not in IZ_HOMES and not (dies_here(F, y) or strip(y.e).k == 'var' and
                                                                  not uses_after_stmt(F, strip(y.e).decl)) for y in loads_in(x)) for x in (strip(e.l), strip(e.r))):
        saved_ = (getattr(F, 'cw_pins', None), getattr(F, 'cw_start', None), getattr(F, 'cw_opline', None))
        F.cw_pins = []; F.cw_opline = None; F.cw_start = len(F.lines); bw = None
        try:
            bw = bin_wide(F, e, op, strip(e.l), strip(e.r), fam, size)
            if bw is not None and F.cw_opline is not None: cw_guard(F, F.cw_opline, 'bin_wide')
        finally:
            F.cw_pins, F.cw_start, F.cw_opline = saved_
        if bw is not None: return bw
    if op in ('%', '/') and F.opt and CHAR_PRODUCT_DIV_GUARD and strip(e.l).k == 'bin' and strip(e.l).op == '*' and \
            fold(strip(e.l).r).k == 'const' and strip(strip(e.l).l).k == 'cast' and strip(strip(strip(e.l).l).e).ty is not None \
            and strip(strip(strip(e.l).l).e).ty.size == 1:
        raise Unsupported('char product remainder')     # (r3_07_12 -O3 -XS: (gca[0] * 61) % 2 -> muls WA,0x3d / exts WA /
    if op == '%' and size in (1, 2) and UCHAR_MOD_AND and rk_.k == 'const' and rk_.value is not None and rk_.value >= 2 and \
            rk_.value & (rk_.value - 1) == 0 and narrow(e.l, 1) is not strip(e.l) and not narrow(e.l, 1).ty.signed and \
            narrow(e.l, 1).ty.size == 1:
        f_ = gen(F, narrow(e.l, 1), 'WA', 1)             # random r1_04_05: (guca[a] | 128) % 2 -> set 0x7,A / and A,0x1
        B_ = FAM[f_][1]; F.emit('and', '%s,%s' % (B_, hx(rk_.value - 1)))
        if fam != f_: F.emit('ld', '%s,%s' % (FAM[fam][1], B_)); f_ = fam
        if size == 2: F.emit('extz', FAM[f_][2])
        return f_
    if F.opt and POW2_UNSIGNED and op in ('%', '/') and e.ty.kind == 'int' and not e.ty.signed and rk_.k == 'const' and \
            rk_.value is not None and rk_.value >= 2 and rk_.value & (rk_.value - 1) == 0:
        from frontend import N                           # __doform.c _doodigit: unsigned long val % 8 -> and XWA,0x7,
        if op == '%':                                    # val / 8 -> srl 0x3,XDE (no helper call)
            e = N('bin', op='&', l=e.l, r=N('const', value=rk_.value - 1, ty=e.r.ty), ty=e.ty); op = '&'
        else:
            e = N('bin', op='>>', l=e.l, r=N('const', value=rk_.value.bit_length() - 1, ty=e.r.ty), ty=e.ty); op = '>>'
    if op in '+-' and (strip(e.l).ty.is_ptr() or strip(e.r).ty.is_ptr()):
        F.ptr_arg_ctx = any_fam                          # (gen_ptr_arith: a pushed pointer sum zero-extends its char)
        try: return gen_ptr_arith(F, e, fam, size)
        finally: F.ptr_arg_ctx = False
    l, r = narrow(e.l, size), narrow(e.r, size)
    if CHAR_NARROW and op == '*' and size == 2 and fold(e.r).k == 'const' and fold(e.r).value is not None:
        cx = strip(e.l)                                  # chnarrow.c cn_mul_k: c * 3 -> ld L,(c) / muls HL,0x3 (the
        if cx.k == 'cast' and cx.kind == 'IntegralCast' and strip(cx.e).ty is not None and strip(cx.e).ty.size == 1 \
                and strip(cx.e).k == 'load':             # byte form); -O3 -XS -Xr with c in A: muls WA,0x3 / ld HL,WA
            x = strip(cx.e); k = fold(e.r).value; sg = x.ty.signed
            if (sg and -128 <= k <= 127) or (not sg and 0 <= k <= 255):
                xr = regvar_of(x.e)
                if F.opt and xr is not None and xr.reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, x) and xr.reg != fam:
                    F.dead.add(xr); W = xr.reg
                else:
                    gen(F, x, fam, 1); W = fam
                F.emit('muls' if sg else 'mul', '%s,%s' % (FAM[W][2], hx(k & 0xff)))
                if W != fam: F.emit('ld', '%s,%s' % (FAM[fam][2], FAM[W][2]))
                return fam
    cx = strip(e.l)
    cr = regvar_of(strip(cx.e).e) if CHAR_NARROW and cx.k == 'cast' and cx.kind == 'IntegralCast' and \
        strip(cx.e).k == 'load' and strip(cx.e).ty.size == 1 else None
    if cr is not None and op in SIMPLE_OPS and size == 2 and cr.reg in ('WA', 'BC', 'DE', 'HL') and cr.reg != fam and \
            dies_here(F, strip(cx.e)) and not reads_reg(r, cr.reg) and operand(F, r, 2) is not None:
        W = FAM[cr.reg][2]; F.dead.add(cr)               # chnarrow.c cn_sub_big, cn_sub_iv under adecl: the char in A
        F.emit('exts' if strip(cx.e).ty.signed else 'extz', W)   # widened in place: exts WA / ld HL,WA / sub HL,..
        if F.opt: F.emit(SIMPLE_OPS[op], '%s,%s' % (W, operand(F, r, 2))); F.emit('ld', '%s,%s' % (FAM[fam][2], W))
        else: F.emit('ld', '%s,%s' % (FAM[fam][2], W)); F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM[fam][2], operand(F, r, 2)))
        return fam                                       # (-O3 -XS -Xr: exts WA / sub WA,.. / ld HL,WA)
    if CONST_LEFT_SWAP and op in ('+', '*', '&', '|', '^') and fold(l).k == 'const' and fold(r).k != 'const' and \
            (mem_operand(F, r) is None or EVORDER and size == 2) and not has_helper_call(r):   # (evorder x_KG: ld HL,(_hi) / xor HL,0x7)
        l, r = r, l; e.l, e.r = e.r, e.l                   # random r1_04_16: 255 ^ gpi[2] -> ld XWA,(_gpi) /
                                                           # ld WA,(XWA+0x4) / xor WA,0xff (the constant last)
    has_helper_call.const_div = True                     # (r2_04_15: gs.l % 3L beside rl() clobbers the call's XHL)
    try: l_helper = has_helper_call(l)
    finally: has_helper_call.const_div = False
    if CALL_RIGHT_FIRST and op in SIMPLE_OPS and size in (2, 4) and has_helper_call(r) and not l_helper \
            and not plain_hl_tree(F, l) and (not F.adecl or CALL_RIGHT_XR and not any(
                regvar_of(strip(x.e)) for x in loads_in(l))) and not reads_reg(l, 'HL') and CALL_RIGHT_GENERAL:
        hf = gen(F, r, 'HL', size)                       # random r1_04_01: gula[a] + rul(gul) -> cal _rul /
        if hf != 'HL': F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[hf][size]))   # inc 0x6,XSP / ... /
        flush_pops(F)                                    # ld XWA,(XBC+A) / add XWA,XHL / ld XHL,XWA
        lf = gen(F, l, 'WA', size)
        if lf != 'WA': F.emit('ld', '%s,%s' % (FAM['WA'][size], FAM[lf][size]))
        F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM['WA'][size], FAM['HL'][size]))
        return move_to(F, FAM['WA'][size], fam, size)
    if CALL_RIGHT_FIRST and op in SIMPLE_OPS and size == 2 and has_helper_call(r) and \
            not has_helper_call(l) and plain_hl_tree(F, l):
        hf = gen(F, r, 'HL', size)                       # probes/adfp.c ad_di: a + (x > 0.0) -> cal ._fcmp_zd /
        if hf != 'HL': F.emit('ld', 'HL,%s' % FAM[hf][2])   # add HL,(XSP+0xc) (-Xr: add HL,IZ)
        flush_pops(F)
        lm = mem_operand(F, l)
        if op in ('+', '&', '|', '^') and lm is not None:
            F.emit(SIMPLE_OPS[op], 'HL,%s' % lm)
        elif not F.adecl:                                # ad_idi: a + b + (x > 0.0) -> cal / ld WA,HL / ld HL,(a) /
            T = 'BC' if F.opt else 'WA'                  # add HL,(b) / add HL,WA (-O3 -XS: BC)
            F.emit('ld', '%s,HL' % T); lf = gen(F, l, 'HL', size)
            if lf != 'HL': raise Unsupported('call-first left operand')
            F.emit(SIMPLE_OPS[op], 'HL,%s' % T)
        else:                                            # -Xr: ld WA,HL / ld BC,IZ / add BC,(XSP+0x2) / ld HL,BC /
            T, B = ('BC', 'WA') if F.opt else ('WA', 'BC')   # add HL,WA; -O3 -XS -Xr: ld BC,HL / ld WA,IZ /
            F.emit('ld', '%s,HL' % T); lf = gen(F, l, B, size)   # add WA,(XSP+0x2) / add WA,BC / ld HL,WA
            if lf != B: raise Unsupported('call-first left operand')
            if F.opt: F.emit(SIMPLE_OPS[op], '%s,%s' % (B, T)); F.emit('ld', 'HL,%s' % B)
            else: F.emit('ld', 'HL,%s' % B); F.emit(SIMPLE_OPS[op], 'HL,%s' % T)
        if fam != 'HL': F.emit('ld', '%s,HL' % FAM[fam][size])
        return fam
    signed = e.ty.signed if size >= e.ty.size else is_signed(e.l if UNPROMOTED_SIGN else l)   # (before narrowing
                                                     # drops the cast to unsigned char: mul_uc_loc)
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
    if op == '+' and strip(r).k != 'const':          # ch_g3_k1: gi + 100 + gj -> ld HL,(_gi) / add HL,(_gj) / add HL,0x64
        sl = strip(l)
        if sl.k == 'bin' and sl.op == '+' and fold(sl.r).k == 'const' and not sl.ty.is_ptr() and not e.ty.is_ptr():
            from frontend import N
            e = N('bin', op='+', l=N('bin', op='+', l=sl.l, r=e.r, ty=sl.ty), r=sl.r, ty=e.ty)
            return gen_bin(F, e, fam, size, then_ret, store)
    if op == '+' and same_leaf(l, r):
        lv = regvar_of(strip(l).e)
        if lv is None and mem_operand(F, l) is not None:   # ch_g3_rep: gi + gi -> ld HL,(_gi) / sla 0x1,HL
            gen(F, l, fam, size); F.emit('sla', '0x1,%s' % R); return fam
    if op in SIMPLE_OPS and F.opt and not e.ty.is_ptr() and (strip(l).k == 'bin' or char_widen(F, l)):
        T = 'WA' if (chain_wa(l) or natural_wa(l) or char_widen(F, l)) else None
        lf = strip(l)
        while lf.k == 'bin' and lf.op in SIMPLE_OPS: lf = strip(narrow(lf.l, size))
        lv = regvar_of(lf.e) if lf.k == 'load' else None
        if T is None and lv is not None and lv.reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, lf): T = lv.reg
        if T is not None and T != fam and not reads_reg(r, T):
            # -O keeps the whole chain in its working register (ch_g4: add WA,(_gm) / ld HL,WA; ch_p3: add WA,BC /
            # add WA,DE / ld HL,WA; ra_noloop3: muls XWA,DE / add WA,HL / add WA,DE / ld HL,WA)
            f2 = gen_bin(F, e, T, size, then_ret, store)
            if any_fam and f2 in FAM: return f2             # (a pushed argument: ___fmemccpy push XHL, no copy)
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM[f2][size])); return fam
    il = strip(l)
    if XR_CHAIN_INPLACE and F.adecl and not F.opt and op in SIMPLE_OPS and size == 2 and il.k == 'bin' and \
            il.op in SIMPLE_OPS and strip(il.l).k == 'load' and regvar_of(strip(il.l).e) is not None and \
            regvar_of(strip(il.l).e).reg in ('WA', 'BC', 'DE') and regvar_of(strip(il.l).e).reg != fam and \
            dies_here(F, strip(il.l)) and not il.ty.is_ptr() and not e.ty.is_ptr() and operand(F, il.r, size) is not None:
        lv0 = regvar_of(strip(il.l).e); W0 = FAM[lv0.reg][size]   # ra_chains.c ch_p3 (-Xr): a + b + c ->
        F.emit(SIMPLE_OPS[il.op], '%s,%s' % (W0, operand(F, il.r, size))); F.dead.add(lv0)   # add WA,BC / ld HL,WA /
        F.emit('ld', '%s,%s' % (R, W0))                                                         # add HL,DE
        rs0 = operand(F, r, size)
        if rs0 is None: raise Unsupported('chain operand')
        rc0 = fold(r)
        if op in '+-' and rc0.k == 'const' and rc0.value is not None and 1 <= rc0.value <= 8:
            F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc0.value), R))
        else: F.emit(SIMPLE_OPS[op], '%s,%s' % (R, rs0))
        return fam
    ev_ctx = 'ANY' if any_fam and fam == 'WA' else fam     # evorder.c: HL (a returned value); evorder_st.c: WA (a
    if EVORDER and size in (2, 4) and ev_ctx in ('HL', 'WA', 'ANY') and \
            (op in SIMPLE_OPS or op in ('*', '/', '%') and size == 2 and (fold(r).k != 'const' or ev_class(F, l) == 'V')) \
            and not any(nodes_in(x, 'call') or has_helper_call(x) or fpgen.is_fp_op(x) or
                        any(regvar_of(strip(y.e)) is not None for y in loads_in(x)) for x in (l, r)) and \
            not getattr(F, 'cl_active', None) and not getattr(F, 'l2', None) and \
            getattr(F, 'u1_i', None) is None and not getattr(F, 'elem_ops', None) and not getattr(F, 'tfam', None):
        ev = evorder_bin(F, e, op, l, r, fam, size, ev_ctx)   # stored value), ANY (a pushed argument); evorder_l.c: longs
        if ev is not None: return ev                       # which operand is the accumulator, the order of their code
    if EVORDER and size in (2, 4) and ev_ctx in ('HL', 'WA', 'ANY') and (op in SIMPLE_OPS or op in ('*', '/', '%')) and \
            (F.opt or F.adecl) and ev_unfitted_pair(F, l, r):   # (evorder.c s_XX, x_XS, s_PX -Xr ...: the older paths
        raise Unsupported('unfitted operand pair (evorder)')   # were wrong code there; refused until the pair is probed)
    if op in ('+', '&', '|', '^') and fam != 'WA' and getattr(F, 'tfam', None) and reads_reg(r, fam) and not reads_reg(l, fam):
        rr = strip(r)                                # ot_cnt_abn: gc = *a + *b with b in XBC dying -> ld C,(XBC) /
        while rr.k == 'cast': rr = strip(rr.e)       # add C,(XWA)
        if rr.k == 'load' and strip(rr.e).k == 'deref':
            from frontend import N
            return gen_bin(F, N('bin', op=op, l=e.r, r=e.l, ty=e.ty), fam, size, then_ret, store)
    if op in SIMPLE_OPS:
        if fam != 'WA' and reads_reg(r, fam):        # ra_leafsum5: target read later -> compute in WA
            gen_bin(F, e, 'WA', size, then_ret, store)
            F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['WA'][size])); return fam
        rcv = strip(r)
        if F.opt and F.adecl and op in ('+', '&', '|', '^') and size == 4 and rcv.k == 'cast' and \
                rcv.kind == 'IntegralCast' and strip(rcv.e).ty.size == 2 and strip(rcv.e).k == 'load' and \
                regvar_of(strip(rcv.e).e) is not None and regvar_of(strip(rcv.e).e).reg in ('IZ', 'QIZ') and \
                (mem_operand(F, l) or '').startswith('('):
            l, r = r, l                                    # ra_homes32.c h_l_n3: x + n, x a slot long, n in IZ ->
            rcv = strip(r)                                 # ld HL,IZ / exts XHL / add XHL,(XSP+0x2)
        if F.opt and op in ('+', '&', '|', '^') and rcv.k == 'cast' and rcv.kind == 'PointerToIntegral' and \
                strip(rcv.e).k == 'load' and regvar_of(strip(rcv.e).e) is not None and dies_here(F, strip(rcv.e)) and \
                strip(l).k == 'load' and regvar_of(strip(l).e) is not None and dies_here(F, l):
            l, r = r, l                                    # abi adecl.c d_l3: b + (long)c -> add XDE,XBC / ld XHL,XDE
            l = strip(l.e)
        la_ = strip(l)
        if F.opt and ASSIGN_OPERAND_INPLACE and la_.k == 'bin' and la_.op == '=' and strip(la_.l).k == 'var' and \
                strip(la_.l).decl.kind == 'global' and strip(la_.r).k == 'load' and regvar_of(strip(la_.r).e) and \
                regvar_of(strip(la_.r).e).reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, strip(la_.r)) and \
                regvar_of(strip(la_.r).e).reg != fam and strip(la_.l).decl.ty.size == size and operand(F, r, size):
            xv = regvar_of(strip(la_.r).e); X = FAM[xv.reg][size]   # assign_expr.c ae_i_add (-O3 -XS -Xr):
            F.emit('ld', '(_%s),%s' % (strip(la_.l).decl.name, X)); F.dead.add(xv)   # (gi = x) + 1 ->
            rc = fold(r)                                            # ld (_gi),WA / inc 0x1,WA / ld HL,WA
            if op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
                F.emit('inc' if op == '+' else 'dec', '%s,%s' % (hx(rc.value), X))
            else: F.emit(SIMPLE_OPS[op], '%s,%s' % (X, operand(F, r, size)))
            F.emit('ld', '%s,%s' % (FAM[fam][size], X)); return fam
        lr = regvar_of(strip(l).e) if strip(l).k == 'load' else None
        if lr is not None and lr.reg in ('WA', 'BC', 'DE', 'HL') and F.opt and dies_here(F, l) and lr.reg != fam and \
                lr not in getattr(F, 'no_inplace', ()):
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
        if ADDR_CLOBBER_SWAP and fam in ('WA', 'BC', 'DE', 'HL'):   # opt_temps.c ot_cnt_ban (-Xr): *a + *b with b
            rm_ = mem_operand(F, r) if strip(r).k == 'load' else None   # in XWA: ld A,(XBC) would destroy b before
            lm_ = mem_operand(F, l) if strip(l).k == 'load' else None   # add A,(XWA); read through XWA first
            X_ = FAM[fam][4]
            if rm_ and rm_.startswith('(') and X_ in rm_:
                if op in ('+', '&', '|', '^') and not (lm_ and X_ in lm_):
                    from frontend import N
                    return gen_bin(F, N('bin', op=op, l=e.r, r=e.l, ty=e.ty), fam, size, then_ret, store)
                raise Unsupported('operand address in the target register')
        pa = ptr_access(F, r) if PTR_RIGHT_BC and fam == 'WA' and op in SIMPLE_OPS and size in (1, 2, 4) and \
            strip(l).k == 'load' and mem_operand(F, l) is not None and not family_of(mem_operand(F, l)) and \
            not has_helper_call(l) and 'BC' not in live_regs(F) else None
        pl_ = ptr_access(F, l) if PTR_RIGHT_BC and fam == 'WA' and op in SIMPLE_OPS and size in (1, 2, 4) \
            and 'BC' not in live_regs(F) else None
        if pl_ is not None and ptr_access(F, r) is not None and not held_after(F, 'BC', e):
            pr_ = ptr_access(F, r); R_ = FAM['WA'][size]  # random r1_05_19: *gpl + gpl[1] -> ld XBC,(_gpl) /
            F.emit('ld', 'XBC,%s' % pl_[0]); F.emit('ld', 'XWA,%s' % pr_[0])   # ld XWA,(_gpl) / ld XWA,(XWA+0x4) /
            ol_ = '(XBC+%s)' % hx(pl_[1]) if pl_[1] else '(XBC)'               # add XWA,(XBC)
            or_ = '(XWA+%s)' % hx(pr_[1]) if pr_[1] else '(XWA)'
            if op == '-':                                # r2_09_00: *gpi - gps->i -> ld BC,(XBC) / sub BC,(XWA+0x2)
                F.emit('ld', '%s,%s' % (FAM['BC'][size], ol_)); F.emit('sub', '%s,%s' % (FAM['BC'][size], or_))
                return 'BC'
            F.emit('ld', '%s,%s' % (R_, or_)); F.emit(SIMPLE_OPS[op], '%s,%s' % (R_, ol_))
            return fam
        if pa is not None and not held_after(F, 'BC', e):
            pm_, off_ = pa; lm_ = mem_operand(F, l)      # random r1_06_08 / r1_08_07 / r1_04_16: the pointer load into
            F.emit('ld', 'XWA,%s' % pm_)                 # XWA would destroy a left operand already in WA
            F.emit('ld', '%s,%s' % (FAM['BC'][size], lm_))
            F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM['BC'][size], '(XWA+%s)' % hx(off_) if off_ else '(XWA)'))
            return 'BC'
        if ELEM_LEFT_COMMUTE and F.adecl and op in ('+', '&', '|', '^') and size in (1, 2) and strip(l).k == 'load' and \
                chidx.is_elem(F, strip(l).e) and strip(r).k != 'load' and not has_helper_call(r) and \
                not any(n.k == 'load' and strip(n.e).k != 'var' for n in nodes_in(r, 'load')):
            el = chidx.element(F, strip(l).e, 'load')    # -Xr r1_06_01: guca[a] ^ (a + 8) -> ld E,A / extz DE /
            if el is None: raise Unsupported('element operand')   # lda XHL,_guca / inc 0x8,A / xor A,(XHL+DE)
            n0_ = len(F.lines); f_ = gen(F, r, fam, size)
            if clobbers(F.lines[n0_:], el): raise Unsupported('element address over the right operand')
            F.emit(SIMPLE_OPS[op], '%s,%s' % (FAM[f_][size], el)); return f_
        if ELEM_LEFT_COMMUTE and not F.opt and not F.adecl and op in ('+', '&', '|', '^') and size == 2 and \
                strip(l).k == 'load' and chidx.is_elem(F, strip(l).e) and strip(r).k == 'load' and \
                mem_operand(F, r) is not None and mem_operand(F, r).startswith('('):
            rs = mem_operand(F, r)                       # random r1_02_19: gua[a] + gua[6] -> ld A,(c) / add A,(c) /
            el = chidx.element(F, strip(l).e, 'load')    # lda XBC,_gua / ld DE,(_gua + 0xc) / add DE,(XBC+A): the
            if el is None: raise Unsupported('element operand')   # element's address, then the plain operand loaded
            F.emit('ld', '%s,%s' % (R, rs))              # and the element added to it
            F.emit(SIMPLE_OPS[op], '%s,%s' % (R, el)); return fam
        wa_var = [d for d in list(F.f.params) + list(F.f.decls) + [getattr(F, 'cse_tmp', None)]
                  if d is not None and getattr(d, 'reg', None) == 'WA' and d not in F.dead
                  and uses_decl(e.r, d)]                   # sv_leaf: a * b + a keeps a in WA -> ld HL,DE / add HL,WA
        if fam != 'WA' and (natural_wa(l) or chain_wa(l) or char_widen(F, l)) and not wa_var:   # ra_noloop3: inner levels over a multiply stay in WA
            f0 = gen(F, l, 'WA', size)
            src_ = FAM[f0][size] if f0 in FAM and size in FAM[f0] else FAM['WA'][size]   # (where gen left it)
            if src_ != FAM[fam][size]: F.emit('ld', '%s,%s' % (FAM[fam][size], src_))
        else:
            rtl = regvar_of(strip(l).e) if strip(l).k == 'load' else None
            if REGTEMP_INPLACE and rtl is not None and getattr(rtl, 'regtemp', False) and dies_here(F, strip(l)) and \
                    (rtl.reg == 'HL' or F.opt) and rtl.reg in FAM and size in FAM[rtl.reg]:
                fam = f0 = rtl.reg; R = FAM[fam][size]; F.dead.add(rtl)   # lo_i_R0e: cal _ri / add HL,(_hi) in place
            else: f0 = gen(F, l, fam, size)
            if f0 != fam and f0 in FAM and size in FAM[f0]:   # _rand: Seed * k + 12345 -> the helper's XHL:
                fam = f0; R = FAM[fam][size]                  # cal C9H_mullu / add XHL,0x3039 (not XWA: wrong code)
        rs = mem_operand(F, r)
        if rs is None:
            other = 'BC' if fam != 'BC' else 'DE'
            if IDX_GUARD and held_after(F, other, r):       # (ol_two_arr: DE held i)
                other = next((x for x in ('BC', 'DE', 'HL') if x != fam and not held_after(F, x, r) and
                              x not in live_regs(F)), None)
                if other is None: raise Unsupported('right operand register')
            rx = strip(r)
            while rx.k == 'cast' and rx.kind == 'IntegralCast': rx = strip(rx.e)
            if IDX_GUARD and fam in ('WA', 'BC') and rx.k == 'load' and strip(rx.e).k == 'index' and \
                    fold(strip(rx.e).idx).k != 'const' and not getattr(F, 'cl_active', None) and \
                    not getattr(F, 'l2', None) and not getattr(F, 'u1_i', None) and not getattr(F, 'elem_ops', None):
                raise Unsupported('element read over the left value')   # (ol_two_arr: ga[i] in WA, then gb[i]'s
                                                                       # index built in WA: wrong code)
            n_r_ = len(F.lines); gen(F, r, other, size); rs = FAM[other][size]
            if RIGHT_CLOBBER_GUARD and clobbers(F.lines[n_r_:], '(%s)' % (FAM[fam][4] if size < 4 else FAM[fam][4])):
                raise Unsupported('the right operand overwrites the left [%s %s %s size %d in %s]' % (
                    op, strip(l).k, strip(r).k, size, fam))      # (r2_02_18, r2_05_13, r2_06_05: wrong code)
        elif op == '+' and same_leaf(l, r) and regvar_of(strip(r).e) is not None:
            rs = R                                     # rh_lp_x2: x + x with x in QIZ -> ld WA,QIZ / add WA,WA
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
    rc0 = fold(r)
    if op == '*' and size == 2 and signed and rc0.k == 'const' and rc0.value in (2, 4, 8, 16, 32, 64, 128, 256):
        gen(F, l, fam, size)                              # fp_temps.c t_i_e: gi * 2 -> ld WA,(_gi) / sla 0x1,WA
        F.emit('sla', '%s,%s' % (hx(rc0.value.bit_length() - 1), R)); return fam
    if op == '/' and size == 4 and not signed and ULONG_DIV_SHIFT and fold(r).k == 'const' and \
            fold(r).value and fold(r).value > 0 and fold(r).value & (fold(r).value - 1) == 0:
        f1 = gen(F, l, fam, 4)                            # random r1_01_15: u / 2UL -> srl 0x1,XWA (no C9H_divlu)
        emit_shift(F, 'srl', fold(r).value.bit_length() - 1, FAM[f1][4]); return f1
    if op in ('*', '/', '%'):
        if size == 4: return gen_long_helper(F, e, l, r, fam, signed)
        rs = mem_operand(F, r); n_rs = len(F.lines)
        if size == 1 and rs is not None and rs.startswith('0x'): rs = hx(int(rs, 16) & 0xff)   # r2_01_17: muls WA,0xa6
        work = 'WA'
        if getattr(F, 'mul_acc_fam', None) == fam and fam in ('BC', 'DE') and size == 2: work = fam   # (store_plan)
        if F.opt and fam in ('HL', 'BC', 'DE') and mem_operand(F, l) and rs and not regvar_of(getattr(strip(l), 'e', l)) \
                and (size == 2 and op != '%' or op == '*'):       # (mod_i_pp under O3XS: divs XWA / ld HL,QWA)
            work = fam                                  # -O: mul_i_pp -> ld HL,(a) / muls XHL,(b); a char / or %
                                                        # stays in WA (div_c_pp: ld A,(a) / exts WA / divs WA,(b) / ld L,A)
        if getattr(F, 'u1_value', None) == fam and size == 2 and op == '*' and rs: work = fam   # U1's value temporary
        lr = regvar_of(strip(l).e) if strip(l).k == 'load' else None
        if F.opt and lr is not None and lr.reg in ('BC', 'DE', 'HL') and dies_here(F, l) and size == 2 and op in '*/':
            work = lr.reg; F.dead.add(lr)               # mul_i_loc under O3XSXr: x in DE dying -> muls XDE,WA / ld HL,DE
        lc = strip(l)
        while lc.k == 'cast' and lc.kind == 'IntegralCast': lc = strip(lc.e)
        lrc = regvar_of(lc.e) if lc.k == 'load' else None
        if F.opt and F.adecl and BINLOC_XR and lrc is not None and lrc.reg in ('BC', 'DE', 'HL') and size == 1 and \
                op in '*/' and dies_here(F, lc) and not getattr(lrc, 'rem_hi', False):
            work = lrc.reg; F.dead.add(lrc)             # mul_c_loc under O3XSXr: muls DE,A / ld L,E (in place)
        if lr is not None and lr.reg == 'WA' and not dies_here(F, l):
            work = free_reg(F, avoid={'WA'})            # mul_i_loc under Xr: ld DE,WA / muls XDE,BC
        if lr is not None and lr.reg == 'WA' and dies_here(F, l): F.dead.add(lr)
        def uncast(x):
            x = strip(x)
            while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
            return x
        rr = regvar_of(uncast(r).e) if uncast(r).k == 'load' else None
        sl = strip(l)
        lu = uncast(l); lvd = regvar_of(lu.e) if lu.k == 'load' else None
        dying_var = lvd is not None and lvd.reg not in ('WA',) and dies_here(F, lu) and size == 1
        rem_left = (lu.k == 'bin' and lu.op == '%') or (lvd is not None and getattr(lvd, 'rem_hi', False))
        if F.adecl and (not F.opt or rem_left) and work == 'WA' and rr is not None and rr.reg == 'WA' and size in (1, 2) \
                and BINLOC_XR and (lr is None and lu.k == 'bin' and lu.op in ('*', '/', '%') or dying_var):
            # (a remainder is never reused in place, -O3 too: mod_c_loc / mod_i_loc under O3XSXr)
            sl = lu if lu.k == 'bin' else None
            # binop-loc rule 3.3 (research-scratch sessions/2026-11-09_cc900-binop-loc): mul_i_loc under -Xr,
            # (a * b) * a -> ld DE,WA / muls XDE,BC (a live) / ld BC,DE / muls XBC,WA: the first free pair once the
            # left operand is built (b dead), never the right operand's WA
            if then_ret:                                    # in the returned expression, a variable it does not
                for d in list(F.f.params) + list(F.f.decls):   # read is dead (mul_c_loc: b, after x = a * b)
                    if getattr(d, 'reg', None) and not uses_decl(e, d): F.dead.add(d)
            if sl is None:                                  # mul_c_loc under -Xr: x (the first product, a char
                f1 = lvd.reg; F.dead.add(lvd)               # register variable in DE) dies here
                if getattr(lvd, 'rem_hi', False): f1 = HI[lvd.reg]
            else:
                F.keep_once = True; F.keep_q = sl.op == '%'           # (a byte operation keeps its family too)
                f1 = gen(F, l, 'WA', size); F.keep_once = False; F.keep_q = False
            for ld_ in loads_in(l):
                v = regvar_of(strip(ld_.e))
                if v is not None and dies_here(F, ld_): F.dead.add(v)
            rem = getattr(F, 'last_remainder', None)
            w2 = free_reg(F, avoid={'WA', rr.reg})
            if size == 2: src = f1 if f1.startswith('Q') else FAM[f1][2]
            else: src = f1 if f1 in ('W', 'B', 'D', 'H') else FAM[f1][1]          # mod_c_loc: the remainder in D
            if src != FAM[w2][size]: F.emit('ld', '%s,%s' % (FAM[w2][size], src))  # -> ld C,D
            work = w2; wide = FAM[work][4] if size == 2 else FAM[work][2]
            ro = FAM[rr.reg][size]
            if op == '*': F.emit('muls' if signed else 'mul', '%s,%s' % (wide, ro)); res = FAM[work][size]
            else:
                F.emit('exts' if signed else 'extz', wide); F.emit('divs' if signed else 'div', '%s,%s' % (wide, ro))
                res = FAM[work][size] if op == '/' else (Q[work] if size == 2 else HI[work])
            return move_to(F, res, fam, size)
        if F.opt and size == 2 and op in '*/' and sl.k == 'bin' and sl.op in '*/' and work == 'WA':
            F.keep_once = True                          # mul_i_loc under O3XSXr: (a * b) * a keeps the product in DE:
            f1 = gen(F, l, work, size); F.keep_once = False   # muls XDE,BC / muls XDE,WA / ld HL,DE
            work = f1
        else:
            lh = regvar_of(strip(l).e) if strip(l).k == 'load' else None
            if F.opt and F.adecl and op == '*' and size == 2 and fam == 'HL' and work == 'WA' and lh is not None and \
                    lh.reg in ('IZ', 'QIZ') and 'HL' not in live_regs(F):
                work = 'HL'                                 # ra_homes.c rh_ll: return a * b with a, b in IZ / QIZ ->
            if held_after(F, work, e):                      # ra_ptr2 (-O3 -XS -Xr): *p++ * *q++ with p in XWA ->
                work = free_reg(F, avoid={work})            # not WA (ld WA,(XWA+:2) was wrong code)
            f1 = gen(F, l, work, size)                      # ld HL,IZ / muls XHL,QIZ
            if f1 != work and f1 in FAM and f1 in ('WA', 'BC', 'DE', 'HL'):
                work = f1                                   # (where gen left it: ra_noloop's a + b in DE, before
        if STORE_ADDR_GUARD and rs is not None and clobbers(F.lines[n_rs:], rs):
            raise Unsupported('the left operand overwrites the right operand\'s address')   # (lnr3.c s_mul -Xr)
        if rs is None:                                  # ra_noloop: muls XWA,BC   (a - b took WA: wrong code)
            ro = 'BC' if work != 'BC' else 'DE'
            occ = [d for d in list(F.f.params) + list(F.f.decls) if getattr(d, 'reg', None) == ro and d not in F.dead]
            for d in occ:                                   # the variable in ro must die within r
                lds = [x for x in loads_in(r) if regvar_of(strip(x.e)) is d]
                if not lds or not any(dies_here(F, x) for x in lds): raise Unsupported('multiply operands')
            if reads_reg(r, work): raise Unsupported('multiply operands')
            n0 = len(F.lines)
            gen(F, r, ro, size); rs = FAM[ro][size]
            if STORE_ADDR_GUARD and clobbers(F.lines[n0:], '(%s)' % (FAM[work].get(4) or work)):   # lnr.c r_ga_mul (none):
                raise Unsupported('the right operand overwrites the left [%s %s %s size %d in %s]' % (
                    op, strip(l).k, strip(r).k, size, work))                        # ga[i] * gb[i] reloaded WA
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
        lr0 = regvar_of(strip(l).e) if strip(l).k == 'load' else None
        if rr.k == 'const' and F.opt and lr0 is not None and lr0.reg in ('WA', 'BC', 'DE', 'HL') and lr0.reg != fam \
                and dies_here(F, l) and lr0.ty.size == size:
            F.dead.add(lr0)                                # binop_i.c shl_i_pk under O3XSXr: sla 0x3,WA / ld HL,WA
            emit_shift(F, mnem, rr.value, FAM[lr0.reg][size]); F.emit('ld', '%s,%s' % (R, FAM[lr0.reg][size]))
            return fam
        if rr.k == 'const':
            gen(F, l, fam, size)
            emit_shift(F, mnem, rr.value, R); return fam
        vfam = 'BC' if fam == 'WA' else fam
        if F.adecl and BINLOC_XR and fam == 'WA' and getattr(F, 'xr_reloc', False):
            vfam = free_reg(F, avoid={'WA'})               # binop-loc 3.1: shl_c_loc under -Xr, the inner shift in L
        V = FAM[vfam][size]
        cs = mem_operand(F, r)
        if cs is None and SHIFT_COUNT_EXPR and vfam != 'WA':   # random r1_03_06: gps->i >> (a & 15): the count into A
            if vfam in live_regs(F):                       # (-O3 -XS r1_09_14: t in BC inside the loop -> the value
                vfam = free_reg(F, avoid={'WA', vfam}); V = FAM[vfam][size]   # elsewhere; ld XBC,(_gs+4) was wrong code)
            n0 = len(F.lines); cf = gen_shift_count(F, r)   # first (ld A,(XSP+0xc) / and A,0xf), the value next
            if cf != 'WA': raise Unsupported('complex shift count')
            n1 = len(F.lines); f1 = gen(F, l, vfam, size)
            if f1 != vfam: raise Unsupported('complex shift count')
            if clobbers(F.lines[n1:], '(XWA)'):             # the value's load needs WA: the count waits in E
                if held_after(F, 'DE', e) or clobbers(F.lines[n1:], '(XDE)'): raise Unsupported('complex shift count')
                F.lines.insert(n1, '\tld\tE,A'); F.emit('ld', 'A,E')   # (r1_03_06: ld E,A / ld WA,(XBC+0x2) / ld A,E)
            if size == 4:
                lab16 = F.newlabel(); F.emit('bit', '0x4,A'); F.emit('j', 'z,%s' % lab16); F.emit(mnem, '0x0,%s' % V)
                F.lines.append(lab16 + ':')
            F.emit('and', 'A,0xf'); lab = F.newlabel(); F.emit('j', 'z,%s' % lab); F.emit(mnem, 'A,%s' % V)
            F.lines.append(lab + ':'); return vfam
        if cs is None: raise Unsupported('complex shift count')
        cv_ = regvar_of(strip(unpromote(r)).e) if strip(unpromote(r)).k == 'load' else None
        wv = [d for d in list(F.f.params) + list(F.f.decls) if getattr(d, 'reg', None) == 'WA' and d not in F.dead
              and d is not cv_]
        def wa_ok(d):                                     # read by e itself (copied out first: as_shl_loc), and not
            lds = [x for x in loads_in(e) if regvar_of(strip(x.e)) is d]   # inside a loop without dying there
            return bool(lds) and (not F.loops or any(dies_here(F, x) for x in lds))
        if IDX_GUARD and family_of(cs) != 'XWA' and wv and not all(wa_ok(d) for d in wv):
            raise Unsupported('shift count over a live WA')   # (cond_bits.c cb_shift -O3 -XS -Xr: x in WA, read by the
                                                               # enclosing & after the shift)
        if family_of(cs) == FAM[vfam][4] and cv_ is not None and (held_after(F, vfam, e) or
                                                                 cv_ in getattr(F, 'in_loop', ())):
            vfam = free_reg(F, avoid={vfam, 'WA'}); V = FAM[vfam][size]   # cond_bits.c cb_for: 1 << i with i in BC,
                                                                           # needed again: the value elsewhere
        if SHIFT_VALUE_FREE and vfam != fam and held_after(F, vfam, e) and family_of(cs) != FAM[vfam][4]:
            alt = next((x for x in ('BC', 'DE', 'HL', 'IX', 'IY') if x != vfam and not held_after(F, x, e) and
                        family_of(cs) != FAM[x][4]), None)  # lnr.c r_shl_i (-O3 -XS): d3 in BC, gr = 1 << i
            if alt is None: raise Unsupported('no free register for the shifted value')
            vfam = alt; V = FAM[vfam][size]
        if family_of(cs) == FAM[vfam][4]:                 # the count lives where the value is built (cb_shift: s in BC,
            if fold(l).k != 'const': raise Unsupported('shift count register')   # 0x8000 >> s): the count first
            F.emit('ld', '%s,%s' % (FAM['WA'][strip(r).ty.size], cs)); gen(F, l, vfam, size)
        else:
            gen(F, l, vfam, size)
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
        if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl.kind == 'param' and not getattr(strip(n.e).decl, 'reg', None) \
                and hasattr(strip(n.e).decl, 'off'):       # (an adecl parameter homed in a slot is read twice from
            counts[strip(n.e).decl] = counts.get(strip(n.e).decl, 0) + 1   # there: ra_homes.c rh_pp_b2)
        if CSE_GLOBALS and n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl.kind == 'global' and \
                strip(n.e).decl.ty.kind == 'int' and strip(n.e).decl.ty.size == 2:   # ra_chains.c ch_g3_rep2 (-O3 -XS):
            counts[strip(n.e).decl] = counts.get(strip(n.e).decl, 0) + 1         # gi + gj + gj -> ld WA,(_gj) first
    walk(e, v)
    pairs_ = []                                            # (gi + gi itself stays ld HL,(_gi) / sla 0x1,HL: ch_g3_rep)
    walk(e, lambda n, dd: pairs_.append(n) if n.k == 'bin' and same_leaf(n.l, n.r) else None)
    many = [d for d, c in counts.items() if c >= 2 and not (d.kind == 'global' and pairs_)]
    if len(many) != 1: return False
    if has_helper_call(e): return False                   # (r2_04_05: r2(gi2, a[7]) & -gi2 destroyed the temporary)
    d = many[0]; size = F.f.ret.size; top = narrow(e, size)
    if top.k == 'cond': return False                       # _abs: the ?: loads j into HL itself
    t0 = strip(top)
    while t0.k == 'cast': t0 = strip(t0.e)
    if t0.k == 'bin' and t0.op in ('==', '!=', '<=', '>=', '<', '>') and same_leaf(t0.l, t0.r):
        return False                                       # assign_expr.c ae_i_ne_l: y == x with y = x folds
    needs_wa = size == 1 or (top.k == 'bin' and top.op in ('*', '/', '%', '<<', '>>'))
    if top.k == 'bin' and top.op in ('*', '/', '%') and size == 4: return False
    tmp = 'BC' if needs_wa else 'WA'
    chain = 'HL'
    if size == 1 and BINLOC_XR and top.k == 'bin' and top.op in tuple(SIMPLE_OPS) + ('<<', '>>'):
        # binop-loc rule 5 (cdecl O3XS): a byte chain is never L -- C under a shift, A without -- and moves to L at the
        # end; the parameter read twice takes the first byte the count (A) and the chain have not claimed
        # (add_c_loc: ld C,(a) / ld A,C / add A,(b) / add A,C / ld L,A; shl_c_loc: a in E, the chain in C)
        shifts = []
        walk(e, lambda n, dd: shifts.append(n) if n.k == 'bin' and n.op in ('<<', '>>') else None)
        chain = 'BC' if shifts else 'WA'
        tmp = next(f_ for f_ in ('WA', 'BC', 'DE', 'HL') if f_ != chain and not (shifts and f_ == 'WA'))
    if top.k == 'bin' and top.op in ('&&', '||'):          # _isdigit: ld HL,0x0 before ld WA,(XSP+0x4)
        F.emit('ld', '%s,0x0' % FAM['HL'][2]); F.preset_hl = True
        tmp = 'WA'
    if d.kind == 'global': F.emit('ld', '%s,(_%s)' % (FAM[tmp][d.ty.size], d.name))
    else: F.emit('ld', '%s,(XSP+%s)' % (FAM[tmp][d.ty.size], hx(d.off + F.push)))
    d.reg = tmp; F.cse_tmp = d
    try:
        fam = gen(F, e, chain, size, then_ret=chain == 'HL')
        if fam != 'HL' and FAM[fam].get(size) != FAM['HL'][size]:
            F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam][size]))
    finally:
        d.reg = None; F.cse_tmp = None
    flush_pops(F)
    if F.xiz_vars: F.emit('pop', F.save_reg)              # ra_homes.c rh_lp_a2 (-O3 -XS): IZ was pushed and never
    epilogue(F)                                            # popped (wrong code)
    F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret')
    return True

def xr_shift_reloc(F):
    """binop-loc rule 4 (research-scratch sessions/2026-11-09_cc900-binop-loc): under -Xr a parameter in WA that is
    read again after a shift's count load leaves WA at entry.  Policy T: an int / long function takes P (a to BC,
    b from BC to DE: ld DE,BC / ld BC,WA), a char one Q (b keeps BC, a to DE: ld E,A).  Only the corpus shape is
    taken: one returned expression of variable-count shifts over the two register parameters."""
    f = F.f
    body = [x for x in flat(f.body) if not (x.k == 'decl' and x.init is None)]
    import copy as _copy
    if len(body) == 2 and body[0].k == 'decl' and body[0].init is not None and body[1].k == 'return':
        memo = {id(d): d for d in list(f.params) + list(f.decls)}       # (the declarations stay shared)
        e2 = _copy.deepcopy(body[1].value, memo)
        holder = type('H', (), {})(); holder.v = e2
        def subst(n):
            for key, v in list(n.__dict__.items()):
                if hasattr(v, 'k'):
                    if v.k == 'load' and strip(v.e).k == 'var' and strip(v.e).decl is body[0].var: setattr(n, key, body[0].init)
                    else: subst(v)
        if strip(e2).k == 'load' and strip(strip(e2).e).k == 'var' and strip(strip(e2).e).decl is body[0].var: e2 = body[0].init
        else: subst(e2)
        from frontend import N
        body = [N('return', value=e2)]
    if len(body) != 1 or body[0].k != 'return' or body[0].value is None: return
    ps = [d for d in f.params if getattr(d, 'reg', None) in ('WA', 'BC')]
    if len(ps) != 2 or ps[0].reg != 'WA' or ps[1].reg != 'BC' or ps[0].ty.size != ps[1].ty.size: return
    a, b = ps
    e = strip(body[0].value)
    while e.k == 'cast': e = strip(e.e)
    shifts = []
    def sh(n, d):
        if n.k == 'bin' and n.op in ('<<', '>>') and fold(n.r).k != 'const': shifts.append(n)
    walk(e, sh)
    if len(shifts) < 2 or not (e.k == 'bin' and e.op in ('<<', '>>')): return
    reads = [strip(n.e).decl for n in loads_in(e)]
    if reads.count(a) < 2: return
    size = a.ty.size
    if f.ret.size >= 2 and size >= 2:                    # P
        F.emit('ld', '%s,%s' % (FAM['DE'][size], FAM['BC'][size])); F.emit('ld', '%s,%s' % (FAM['BC'][size], FAM['WA'][size]))
        a.reg, b.reg = 'BC', 'DE'
    elif size == 1:                                      # Q
        F.emit('ld', 'E,A'); a.reg = 'DE'
    F.xr_reloc = True

def ptr_access(F, x):
    """(pointer operand, byte offset) when x reads p->m, p[k] or *p through a pointer variable in memory, else None"""
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty is not None and strip(x.e).ty.size == x.ty.size:
        x = strip(x.e)
    if x.k != 'load': return None
    v = strip(x.e)
    if v.k == 'member' and v.arrow: base, off = strip(v.base), member_offset(v)
    elif v.k == 'index' and fold(v.idx).k == 'const' and fold(v.idx).value is not None and strip(v.base).k == 'member' \
            and strip(v.base).arrow:                       # r2_01_04: gps->a[1] -> (XWA+0x10)
        base, off = strip(strip(v.base).base), member_offset(strip(v.base)) + fold(v.idx).value * v.ty.size
    elif v.k == 'index' and fold(v.idx).k == 'const' and fold(v.idx).value is not None:
        base, off = strip(v.base), fold(v.idx).value * v.ty.size
    elif v.k == 'deref': base, off = strip(v.e), 0
    else: return None
    if base.k != 'load' or not (base.ty is not None and base.ty.is_ptr()) or strip(base.e).k != 'var': return None
    d = strip(base.e).decl
    if getattr(d, 'reg', None) or d.kind not in ('global', 'param'): return None
    pm = mem_operand(F, base)
    if pm is None or not pm.startswith('('): return None
    return pm, off

def long_helper_node(n):
    """a long / % or * that calls C9H_* (r3_02_00: the loop counter must not live in BC across it)"""
    if getattr(n, 'k', None) != 'bin' or n.ty is None or n.ty.size != 4 or n.op not in '*/%': return False
    r = fold(n.r)
    if n.op == '*': return not (r.k == 'const' and r.value is not None and r.value > 0 and bin(r.value).count('1') <= 3)
    return not (not n.ty.signed and r.k == 'const' and r.value and r.value & (r.value - 1) == 0)

def nodes_in(e, kind):
    out = []
    walk(e, lambda n, d: out.append(n) if n.k == kind else None)
    return out

def loads_in(e):
    out = []
    walk(e, lambda n, d: out.append(n) if n.k == 'load' and strip(n.e).k == 'var' else None)
    return out

def held_after(F, R, e):
    """the family R holds a register variable that is still needed after expression e is evaluated, so writing R
    while building e would be wrong code.  Without real liveness this is an approximation: a variable incremented
    in e; inside a loop, one read in e by no last read, or a loop variable or parameter e does not read (ra_leaf3's
    k).  Outside a loop a read in e is taken as the last one (opt_params.c op_two_loops' *d = *s reuses C), and a
    variable read only by later statements is not seen."""
    inloop = bool(F.loops) or bool(getattr(F, 'cl_active', None))   # (gen_counted pushes no F.loops entry)
    for d in list(F.f.params) + list(F.f.decls):
        if getattr(d, 'reg', None) != R or d in F.dead: continue
        if R == 'WA' and getattr(d, 'regtemp', False) and not getattr(d, 'regtemp_keep_wa', False): continue
        lds = [x for x in loads_in(e) if regvar_of(strip(x.e)) is d]
        incs = []
        walk(e, lambda n, dd: incs.append(n) if n.k == 'incdec' and regvar_of(n.e) is d else None)
        if lds or incs:
            if incs or (inloop and not any(dies_here(F, x) for x in lds)): return True
        elif inloop and (d in getattr(F, 'in_loop', ()) or d.kind == 'param'):
            return True
        elif HELD_LATER and d in read_after_top(F):         # lnr.c r_p_wri (none): d3 in BC is read after the loop,
            return True                                    # so p[i] = i must not build its address in XBC
    return False

class LazyLabel:
    """a loop's break label that exists only once something jumps to it (str() makes it)"""
    def __init__(s, make): s.make = make
    def __str__(s): return s.make()
    def __add__(s, o): return str(s) + o
    def __radd__(s, o): return o + str(s)
    def __mod__(s, o): return str(s) % o
    def __eq__(s, o): return False
    def __hash__(s): return id(s)

def free_reg(F, avoid=()):
    live = live_regs(F)
    for r in ('BC', 'DE', 'HL', 'WA'):
        if r not in live and r not in avoid: return r
    raise Unsupported('no free register')

def byte_arms(e):
    """a ?: whose two arms are chars (or char operations, char_narrow) of one signedness, or one of them a constant
    that fits: the signedness (True / False), else None"""
    if not CHAR_NARROW: return None
    sg = []
    for x in (e.a, e.b):
        x = strip(x)
        if fold(x).k == 'const':
            if fold(x).value is None or not 0 <= fold(x).value <= 127: return None
            continue
        if not (x.k == 'cast' and x.kind == 'IntegralCast' and x.ty.size == 2 and strip(x.e).ty is not None and
                strip(x.e).ty.kind == 'int' and strip(x.e).ty.size == 1): return None
        sg.append(strip(x.e).ty.signed)
    if not sg or len(set(sg)) != 1: return None
    return sg[0]

def char_widen(F, x):
    """a char in memory widened to int as the left operand of + - & | ^: cc900 widens it in WA (chnarrow.c
    cn_sub_big: ld A,(XSP+0x4) / exts WA / ld HL,WA / sub HL,0x12c; -O3 -XS: ... / sub WA,0x12c / ld HL,WA)"""
    if not CHAR_WIDEN_WA: return False
    x = strip(x)
    if not (x.k == 'cast' and x.kind == 'IntegralCast' and x.ty.size == 2 and strip(x.e).ty is not None and
            strip(x.e).ty.size == 1 and strip(x.e).k == 'load'): return False
    m = mem_operand(F, strip(x.e))
    return m is not None and m.startswith('(')

CHAR_WIDEN_WA = True

def natural_wa(e):
    e = strip(e)
    if e.k == 'bin' and e.op in ('*', '/', '%') and e.ty.size <= 2: return True
    if e.k == 'bin' and e.op in SIMPLE_OPS: return natural_wa(e.l)
    return False

def same_leaf(a, b):
    """two reads of the same variable (a + a)"""
    a, b = strip(a), strip(b)
    if a.k != 'load' or b.k != 'load': return False
    x, y = strip(a.e), strip(b.e)
    return x.k == 'var' and y.k == 'var' and x.decl is y.decl and a.ty.size == b.ty.size

def chain_wa(l):
    """the left side of a + - & | ^ chain that cc900 builds in WA and moves (ld HL,WA) before the last operand: one
    of three or more operands (ch_g4: ld WA,(_gi) / add WA,(_gj) / add WA,(_gk) / ld HL,WA / add HL,(_gm)), or a pair
    led by an IZ / QIZ home (ch_c_pg2: ld WA,IZ / add WA,(_gi) / ld HL,WA); a pair led by memory is built in the
    target (ch_g3, ch_c_xyz: ld HL,(XSP+0x4) / add HL,QIZ / add HL,IZ).  Run 2026-11-09-7-micro-chains."""
    l = strip(l)
    if l.k != 'bin' or l.op not in SIMPLE_OPS or l.ty.is_ptr(): return False
    ll = strip(l.l)
    if ll.k == 'bin' and ll.op in SIMPLE_OPS and not ll.ty.is_ptr(): return True
    lv = regvar_of(ll.e) if ll.k == 'load' else None
    return lv is not None and lv.reg in ('IZ', 'QIZ', 'XIZ')

def reads_reg(e, fam):
    found = []
    def v(n, d):
        if n.k == 'var' and getattr(n.decl, 'reg', None) == fam: found.append(n)
    walk(e, v)
    return bool(found)

def load_index16(F, ii, im):
    """WA = the index ii whose memory operand is im: a char is loaded as a byte and extended by its sign"""
    if ii.ty is not None and ii.ty.size == 1 and im != 'WA':
        F.emit('ld', 'A,%s' % im); F.emit('exts' if ii.ty.signed else 'extz', 'WA')
    elif im != 'WA': F.emit('ld', 'WA,%s' % im)

def gen_ptr_arith(F, e, fam, size):
    """p + i (mem.c: m_padd): index sign-extended and scaled in XWA, then the pointer added;
    p - q (m_diff): 32-bit difference divided by the element size with C9H_divls"""
    r_ = chidx.ptr_sum(F, e, fam)                          # a char index (probes/chidx.c ac2: ... extz XHL / add XHL,XWA)
    if r_ is not None: return r_
    l, r = strip(e.l), strip(e.r)
    if l.ty.is_ptr() and r.ty.is_ptr():
        lm, rm = mem_operand(F, l), mem_operand(F, r)
        if lm is None and strip(l).k in ('addr', 'decay'):
            gen(F, l, 'WA', 4); lm = 'XWA'                     # _ultoa: &buf[33] - p
        if lm is None or rm is None: raise Unsupported('complex pointer difference')
        esz = l.ty.base.size
        if PTRDIFF_INPLACE and F.opt and lm in ('XBC', 'XDE', 'XHL') and esz == 1 and l.k == 'load' and \
                dies_here(F, l) and family_of(rm) != family_of(lm):
            F.emit('sub', '%s,%s' % (lm, rm))               # ___fmemccpy (-O3 -XS): pos - s2 with pos dying in XHL ->
            dl = regvar_of(l.e)                             # sub XHL,(XSP+0xc) (then inc 0x1,XHL / push XHL)
            if dl is not None: F.dead.add(dl)
            if size == 2 and fam != lm[1:]: F.emit('ld', '%s,%s' % (FAM[fam][2], lm[1:])); return fam
            return lm[1:]
        if lm != 'XWA': F.emit('ld', 'XWA,%s' % lm)
        F.emit('sub', 'XWA,%s' % rm)
        if esz > 1:
            F.emit('ld', 'XBC,%s' % hx(esz)); F.emit('cal', 'C9H_divls'); return 'HL'
        if size == 2 and fam != 'WA':                      # ra_homes32.c h_p_diff: return p - s (int) -> sub XWA,(s) /
            F.emit('ld', '%s,WA' % FAM[fam][2]); return fam   # ld HL,WA
        return move_to(F, 'XWA', fam, 4)
    if r.ty.is_ptr(): l, r = r, l
    rc = fold(r)
    if rc.k == 'const' and rc.value is not None:
        bsz = e.ty.base.size if e.ty is not None and e.ty.is_ptr() and e.ty.base is not None else l.ty.base.size
        k = rc.value * bsz * (1 if e.op == '+' else -1)   # va_start: (va_list)&n + 2 counts chars, not ints
        R = FAM[fam][4]
        la = strip(l)
        while la.k in ('cast', 'noop'): la = strip(la.e)
        if F.opt and la.k == 'addr' and strip(la.e).k == 'var':   # _sprintf's va_start at -O3: (char *)&format + 4 ->
            # lda XWA,XSP+0x10 (without -O the constant is added after: varargs.c v_sum lda XWA,XSP+0x4 / inc 0x2,XWA)
            d = strip(la.e).decl
            off = getattr(d, 'slot', None) if d.kind == 'local' else getattr(d, 'off', None)
            if off is not None and not getattr(d, 'reg', None):
                t = off + F.push + k
                F.emit('lda', '%s,%s' % (R, 'XSP+%s' % hx(t) if t else 'XSP')); return fam
        lr = operand(F, l, 4)
        if lr is not None and not lr.startswith('(') and lr != R:
            F.emit('lda', '%s,%s%s%s' % (R, lr, '+' if k >= 0 else '-', hx(abs(k))))   # _ltoa: lda XWA,XBC+0x1
            return fam
        f2 = gen(F, l, fam, 4); R = FAM[f2][4]                          # _ltoa: cal _ultoa / lda XSP,XSP+0xa /
        if strip(l).k == 'call' and F.opt: flush_pops(F)                 # dec 0x1,XHL
        if 1 <= abs(k) <= 8: F.emit('inc' if k > 0 else 'dec', '%s,%s' % (hx(abs(k)), R))
        elif k: F.emit('add', '%s,%s' % (R, hx(k & 0xffffffff)))
        return f2
    pm = mem_operand(F, l); ii = r
    while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
    im = mem_operand(F, ii)
    if pm is None or im is None: raise Unsupported('complex pointer arithmetic')
    esz = l.ty.base.size
    iv = regvar_of(ii.e) if ii.k == 'load' else None
    opn = 'add' if e.op == '+' else 'sub'
    if iv is not None and iv.reg in ('BC', 'DE', 'HL') and dies_here(F, ii) and ii.ty.size == 2:
        X = FAM[iv.reg][4]; F.dead.add(iv)          # mem.c m_padd under -Xr: exts XBC / add XBC,XBC, then
        F.emit('exts' if ii.ty.signed else 'extz', X)   # -O: add XBC,XWA / ld XHL,XBC; none: ld XHL,XBC / add XHL,XWA
        if esz == 2: F.emit('add', '%s,%s' % (X, X))
        elif esz > 2: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[esz]), X))
        if fam != iv.reg and not getattr(F, 'ptr_keep', False):
            R = FAM[fam][4]
            if F.opt: F.emit(opn, '%s,%s' % (X, pm)); F.emit('ld', '%s,%s' % (R, X))
            else: F.emit('ld', '%s,%s' % (R, X)); F.emit(opn, '%s,%s' % (R, pm))
            return fam
        F.emit(opn, '%s,%s' % (X, pm)); return iv.reg
    ext = 'extz' if esz == 1 and PTR_CHAR_EXTZ and (getattr(F, 'ptr_arg_ctx', False) or not ii.ty.signed or
                                                   ii.ty.size != 1) else ('exts' if ii.ty.signed else 'extz')
    R = FAM[fam][4]                                      # (a char pointer's index is zero-extended: h_p_n3's int n,
                                                         # extz XHL; a char index too when the sum is pushed, r1_04_02;
                                                         # a stored char index is sign-extended, r1_00_13)
    if F.adecl and PTRSUM_FREE_X and 'WA' in live_regs(F) and ii.ty is not None and ii.ty.size == 2 and im is not None \
            and not im.startswith('(XWA') and (im != 'WA' or not dies_here(F, ii)) and pm.startswith('(') and \
            'XWA' not in pm and esz in (1, 2, 4):
        T = free_reg(F, avoid={'WA'}); X = FAM[T][4]     # -Xr r1_06_01: gpi + b with a live in A -> ld DE,BC /
        if im != FAM[T][2]: F.emit('ld', '%s,%s' % (FAM[T][2], im))   # exts XDE / add XDE,XDE / add XDE,(_gpi)
        F.emit(ext, X)
        if esz == 2: F.emit('add', '%s,%s' % (X, X))
        elif esz > 2: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[esz]), X))
        F.emit(opn, '%s,%s' % (X, pm)); return T
    if F.opt and F.adecl and im in ('IZ', 'QIZ') and R != 'XWA' and pm.startswith('('):
        F.emit('ld', '%s,%s' % (FAM[fam][2], im)); F.emit(ext, R)   # h_p_n3: return p + n with n in IZ ->
        if esz == 2: F.emit('add', '%s,%s' % (R, R))                # ld HL,IZ / extz XHL / add XHL,(XSP+0x2)
        elif esz > 2: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[esz]), R))
        F.emit('add' if e.op == '+' else 'sub', '%s,%s' % (R, pm)); return fam
    if ii.ty is not None and ii.ty.size == 1 and esz == 1 and PTR_CHAR_EXTZ and im != 'WA' and e.op == '+' and \
            R != 'XWA' and not F.adecl and pm.startswith('(_') and ' ' in pm and im.startswith('(XSP') and MEMBER_PTR_CHAR_LDA:
        F.emit('ld', 'C,%s' % im); F.emit('ld', 'XWA,%s' % pm)   # r2_02_05: char *t = gs.p + a -> ld C,(XSP+0x8) /
        F.emit('lda', '%s,XWA+C' % R); return fam                # ld XWA,(_gs + 0xa) / lda XIZ,XWA+C
    if ii.ty is not None and ii.ty.size == 1 and esz == 1 and PTR_CHAR_EXTZ and im != 'WA' and e.op == '+' and \
            (F.adecl or F.opt and pm.startswith('(_') and ' ' not in pm) and pm != 'XBC' and not im.startswith('(XBC'):
        F.emit('ld', 'XBC,%s' % pm); F.emit('ld', 'A,%s' % im)   # -O / -Xr (r1_04_19, r1_04_02): gp + b ->
        F.emit('lda', '%s,XBC+A' % R); return fam               # ld XBC,(_gp) / ld A,(b) / lda XWA,XBC+A
    if ii.ty is not None and ii.ty.size == 1 and esz == 1 and PTR_CHAR_EXTZ and im != 'WA' and \
            (getattr(F, 'ptr_arg_ctx', False) or not ii.ty.signed):
        F.emit('ld', 'XWA,0x0'); F.emit('ld', 'A,%s' % im)   # random r1_04_02: vp(gs.p + a), a char a on a char pointer,
    else:                                                  # pushed: the byte zero-extended whole (ld XWA,0x0 / ld A,(XSP+0x8));
        load_index16(F, ii, im); F.emit(ext, 'XWA')       # stored it is sign-extended (r1_00_13: gp = gs.p + a -> ld A,.. /
    if esz == 2: F.emit('add', 'XWA,XWA')
    elif esz > 2: F.emit('sll', '%s,XWA' % hx({4: 2, 8: 3}[esz]))
    if F.opt and R != 'XWA' and pm != 'XWA':          # m_padd under -O3 -XS: add XWA,(XSP+0x4) / ld XHL,XWA
        F.emit(opn, 'XWA,%s' % pm); F.emit('ld', '%s,XWA' % R); return fam
    if R != 'XWA': F.emit('ld', '%s,XWA' % R)
    F.emit(opn, '%s,%s' % (R, pm)); return fam

def gen_mul_const(F, l, k, fam, size, signed=True):
    """long multiply by a constant, by shifts and adds (mul_l_pk, mul_l_gk): binary method from the top bit;
    a run of doublings before an add is `sla n`, a final single doubling `add r,r`"""
    R = FAM[fam][size]
    x = mem_operand(F, l)
    if x is None and strip(l).k == 'call' and k == 2:   # k_l: rl(a) * 2 -> cal _rl / inc 0x4,XSP / ld XWA,XHL /
        gen_call(F, strip(l)); flush_pops(F); X = FAM['HL'][size]; W = FAM['WA'][size]   # add XWA,XHL / ld XHL,XWA
        F.emit('ld', '%s,%s' % (W, X))
        if F.adecl and fam == 'HL': F.emit('add', '%s,%s' % (X, W)); return fam   # -Xr: ld XWA,XHL / add XHL,XWA
        F.emit('add', '%s,%s' % (W, X))
        if fam != 'WA': F.emit('ld', '%s,%s' % (R, W))
        return fam
    ldm = []
    walk(l, lambda n, d: ldm.append(n) if n.k == 'bin' and n.op in ('/', '%') and n.ty is not None and n.ty.size == 4 else None)
    if x is None and k & (k - 1) == 0 and (has_helper_call(l) or ldm):   # arr_index.c ai_l_p_carry: p[i] % 10 * 256 ->
        f = gen(F, l, fam, size); X = FAM[f][size]                   # cal C9H_remls / sla 0x8,XHL
        F.emit('sla' if signed else 'sll', '%s,%s' % (hx(k.bit_length() - 1), X)); return f
    if x is None: raise Unsupported('complex multiplicand')
    if x.startswith('(_'):                       # an absolute operand is loaded once into XBC
        F.emit('ld', '%s,%s' % (FAM['BC'][size], x)); F.emit('ld', '%s,%s' % (R, FAM['BC'][size])); x = FAM['BC'][size]
    elif F.opt and x.startswith('(XSP') and fam != 'WA' and MUL_K_XWA:   # mul_l_pk under O3XS: ld XWA,(a) /
        W = FAM['WA'][size]; F.emit('ld', '%s,%s' % (W, x)); F.emit('ld', '%s,%s' % (R, W)); x = W   # ld XHL,XWA
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

def gen_shift_count(F, r):
    """a computed shift count into A (SHIFT_COUNT_EXPR): a byte expression of memory operands (r1_03_06: ld A,(XSP+0xc) /
    and A,0xf), but at the variable's width when it reads a register variable (-Xr r1_06_19: gc << (a & 7) with a in
    IZ -> ld WA,IZ / and WA,0x7)"""
    rv = [regvar_of(strip(x.e)) for x in loads_in(r)]
    if rv and all(v is not None and v.ty.size == 2 for v in rv): return gen(F, r, 'WA', 2)   # (-O3 -XS r1_09_14: t in BC -> ld WA,BC)
    return gen(F, narrow(r, 1), 'WA', 1)

LONG_HELPER_ORDER = True                                  # see long_helper_order

def long_helper_order(F, e, l, r):
    """the arguments of a long * / % helper when one operand needs code (corpus/probes/evorder_lh.c, run
    2026-11-10-13-micro-evorder4): the left goes to XWA and the right to XBC, except that * (commutative) puts the
    operand the operator rule makes the accumulator in XWA (m_GB: ld XWA,(_hl) / sub XWA,(_hm) / ld XBC,(_gl); m_PP:
    the right pointer in XWA).  Code order: the pointers' addresses in textual order, each into its own argument
    register; the source value (XBC: a ! tests in XWA and lands in BC, scc eq,BC / exts XBC; a unary minus computes
    in XWA and moves, ld XBC,XWA; a shift's value in XBC with the count in WA); the accumulator value (XWA; a shift
    moves ld XWA,XBC); the plain loads, a plain variable before a member or element (d_MG: ld XBC,(_hl) /
    ld XWA,(_gs+0xa)); constants last (d_KB: ld XWA,0x7 after the right value); the pointers' loads last, in
    place (m_GP: ld XBC,(XBC)).  Emits up to the arguments; returns False where the shape is not one of these
    (an indexed element goes through a slot and XIZ, a member through a pointer through XIZ, two values and a
    pointer, ...)."""
    cl, cr = ev_class(F, l), ev_class(F, r)
    if cl is None or cr is None or (cl == 'K' and cr == 'K'): return False
    if cl != 'V' and cr != 'V' and ev_addr_kind(F, l) is None and ev_addr_kind(F, r) is None: return False
    def kind(x):
        k = ev_addr_kind(F, x)
        if k == 'P' and strip(ev_uncast(x).e).k == 'member': return 'D'   # (through XIZ: unprobed)
        return k
    lk, rk = kind(l), kind(r)
    if 'X' in (lk, rk) or 'D' in (lk, rk): return False
    if e.op == '*':
        if cr == 'V' and cl != 'V': acc, src = r, l
        elif cl == 'V': acc, src = l, r
        elif cr == 'K': acc, src = l, r
        elif cl == 'K': acc, src = r, l
        elif cl == 'A' and cr == 'A': acc, src = r, l
        else: acc, src = l, r
    else: acc, src = l, r
    if ev_class(F, acc) == 'K': return False
    def vshift(x): return ev_core(x).k == 'bin' and ev_core(x).op in ('<<', '>>') and fold(ev_core(x).r).k != 'const'
    if vshift(l) and vshift(r): return False               # (eh_r_SS: the two counts share WA; unprobed)
    if vshift(acc) and ev_class(F, src) == 'V': return False   # (eh_r_ST: the shift's XBC over the source value)
    reg = {id(acc): 'XWA', id(src): 'XBC'}
    def is_v(x): return ev_class(F, x) == 'V'
    if any(regvar_of(strip(y.e)) is not None for x in (l, r) for y in loads_in(x)): return False
    if nodes_in(l, 'call') or nodes_in(r, 'call') or fpgen.is_fp_op(l) or fpgen.is_fp_op(r): return False
    # 1. pointer addresses, textual
    for x in (l, r):
        if kind(x) == 'P':
            pv = strip(strip(ev_uncast(x).e).e)
            F.emit('ld', '%s,%s' % (reg[id(x)], mem_operand(F, pv)))
    n0 = len(F.lines)
    # 2. the source value
    if is_v(src):
        sx = ev_core(src)
        if sx.k == 'un' and sx.op == '!':
            f_ = gen(F, sx.e, 'WA', 4)
            if f_ != 'WA': raise Unsupported('long helper: ! operand')
            F.emit('or', 'XWA,XWA'); F.emit('scc', 'eq,BC'); F.emit('exts', 'XBC')
        elif sx.k == 'un' and sx.op == '-':
            f_ = gen(F, src, 'WA', 4)
            if f_ != 'WA': raise Unsupported('long helper: - operand')
            F.emit('ld', 'XBC,XWA')
        else:
            f_ = gen(F, src, 'BC', 4)
            if f_ != 'BC': raise Unsupported('long helper: source value')
        if kind(acc) == 'P' and clobbers(F.lines[n0:], '(XWA)'): raise Unsupported('long helper: source over the pointer')
    n1 = len(F.lines)
    # 3. the accumulator value
    if is_v(acc):
        f_ = gen(F, acc, 'WA', 4)
        if f_ == 'BC': F.emit('ld', 'XWA,XBC')           # (m_SG: the shifted value moves)
        elif f_ != 'WA': raise Unsupported('long helper: accumulator value')
        if is_v(src) and clobbers(F.lines[n1:], '(XBC)') and f_ != 'BC': raise Unsupported('long helper: accumulator over the source')
        if kind(src) == 'P' and clobbers(F.lines[n1:], '(XBC)'): raise Unsupported('long helper: accumulator over the pointer')
    # 4. plain loads: a plain variable before a member or element, ties textual
    plain = [x for x in (l, r) if not is_v(x) and kind(x) is None and ev_class(F, x) != 'K']
    plain.sort(key=lambda x: 0 if ev_class(F, x) == 'G' else 1)
    for x in plain:
        m = mem_operand(F, x)
        if m is None: raise Unsupported('long helper: plain operand')
        F.emit('ld', '%s,%s' % (reg[id(x)], m))
    # 5. constants
    for x in (l, r):
        if ev_class(F, x) == 'K':
            v = fold(x).value
            if F.opt and reg[id(x)] == 'XBC' and 0 <= v < 0x10000: F.emit('lda', 'XBC,%s' % hx(v))   # (div_l_pk -O)
            else: F.emit('ld', '%s,%s' % (reg[id(x)], hx(v & 0xffffffff)))
    # 6. the pointers' loads, in place
    for x in (l, r):
        if kind(x) == 'P': F.emit('ld', '%s,(%s)' % (reg[id(x)], reg[id(x)]))
    return True

def gen_long_helper(F, e, l, r, fam, signed):
    name = {'*': 'mul', '/': 'div', '%': 'rem'}[e.op] + ('ls' if signed else 'lu')
    if e.op == '*' and CONST_LEFT_SWAP and fold(l).k == 'const' and fold(r).k != 'const':
        l, r = r, l                                      # random r1_00_05: 61613L * gl2 -> ld XWA,(_gl2) / ld XBC,0xf0ad
    ls, rs = reg_or_mem(F, l, 4), reg_or_mem(F, r, 4)
    if (ls is None or rs is None) and LONG_HELPER_ORDER and not getattr(F, 'l2', None) and \
            not getattr(F, 'cl_active', None) and getattr(F, 'u1_i', None) is None and long_helper_order(F, e, l, r):
        F.emit('cal', 'C9H_' + name)
        return 'HL' if fam == 'HL' else move_to(F, 'XHL', fam, 4, keep=True)
    if (ls is None or rs is None) and LH_MEMBER and getattr(F, 'store_xiz', False) and F.xiz_vars == ['stores'] and \
            not getattr(F, 'sp_xiz_busy', False) and not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None) and \
            getattr(F, 'u1_i', None) is None and lh_member(F, e.op, l, r):
        F.emit('cal', 'C9H_' + name)                   # (evorder_ad.c l_div_GD: push XIZ / ld XIZ,(_hps) / ld XWA,(_gl) /
        return 'HL' if fam == 'HL' else move_to(F, 'XHL', fam, 4, keep=True)   # ld XBC,(XIZ+0x4) / cal C9H_divls)
    if ls is None or rs is None: raise Unsupported('complex long helper operands')
    # provisional (two examples, mul_l_loc): XBC first when a register variable is involved
    rc = fold(r)
    if F.opt and rc.k == 'const' and rc.value is not None and 0 <= rc.value < 0x10000:
        rs_ld = ('lda', 'XBC,%s' % hx(rc.value))        # -O: div_l_pk, _rand: lda XBC,0xa / lda XBC,0x7fff
    else:
        rs_ld = ('ld', 'XBC,%s' % rs)
    if F.opt and F.adecl and BINLOC_XR and bool(family_of(ls)) != bool(family_of(rs)):
        # binop-loc section 6, -O3 -XS -Xr: the register copy first (mul_l_loc: ld XBC,XIZ / ld XWA,(XSP+0x4))
        if family_of(ls): F.emit('ld', 'XWA,%s' % ls); F.emit(*rs_ld)
        else: F.emit(*rs_ld); F.emit('ld', 'XWA,%s' % ls)
    elif F.opt and not F.adecl and BINLOC_XR:
        # cdecl -O3 -XS: XWA first, except a memory right operand beside a local held in XIZ, which is loaded
        # first (mul_l_loc: ld XBC,(a) / ld XWA,XIZ); a parameter in XIZ keeps XWA first (_ldiv, _ultoa:
        # ld XWA,XIZ / ld XBC,(XSP+0x20))
        if not ls.startswith('(') and rs.startswith('(') and \
                any(d is not None and d.kind == 'local' for d in F.xiz_vars):
            F.emit(*rs_ld); F.emit('ld', 'XWA,%s' % ls)
        else: F.emit('ld', 'XWA,%s' % ls); F.emit(*rs_ld)
    elif F.xiz_vars and any(d is not None and getattr(d, 'kind', None) == 'local' for d in F.xiz_vars):
        F.emit(*rs_ld); F.emit('ld', 'XWA,%s' % ls)
    else:
        F.emit('ld', 'XWA,%s' % ls); F.emit(*rs_ld)
    F.emit('cal', 'C9H_' + name)
    return 'HL' if fam == 'HL' else move_to(F, 'XHL', fam, 4, keep=True)

def move_to(F, res, fam, size, keep=False):
    tgt = FAM[fam][size]
    if keep: return 'HL'
    if getattr(F, 'keep_q', False) and (res.startswith('Q') or res in ('W', 'B', 'D', 'H')):   # mod_i_loc / mod_c_loc
        F.keep_q = False; F.keep_once = False; return res
    if getattr(F, 'keep_once', False) and family_of(res) and res in FAM[family_of(res)[1:]].values() \
            and res == FAM[family_of(res)[1:]].get(size):
        F.keep_once = False; return family_of(res)[1:]  # the caller works where the value already is
    if res != tgt: F.emit('ld', '%s,%s' % (tgt, res))
    return fam

def l2_opassign_value(F, oa):
    """(u /= radix) as a value in L2: the division into t1, stored back to u's register; returns u's register"""
    v = strip(oa.l)
    if not (v.k == 'var' and getattr(v.decl, 'reg', None) and oa.op in ('/', '%')): return None
    from frontend import N
    r = l2_divide(F, N('bin', op=oa.op, l=N('load', e=oa.l, ty=v.ty), r=oa.r, ty=v.ty))
    if r is None: return None
    R = FAM[v.decl.reg][2]; F.emit('ld', '%s,%s' % (R, FAM[r][2])); return R

def gen_compare(F, e):
    """emit the compare for relational/equality node e; return its condition code, or True/False if constant
    (cmp_*: cp acc,mem; cpw/cpb mem,k; long: ld XWA / cp XWA,k / or XWA,XWA for ==0 and !=0)"""
    l, r = strip(e.l), strip(e.r)
    if F.opt and unpromote(l).k == 'load' and unpromote(r).k == 'load' and strip(unpromote(l).e).k == 'var' and \
            strip(unpromote(r).e).k == 'var' and strip(unpromote(l).e).decl is strip(unpromote(r).e).decl:
        return e.op in ('==', '<=', '>=')                # ae_i_ne_l after copy propagation: y == x -> 1
    if fold(l).k == 'const' and fold(r).k != 'const':      # _tan: LMTPOW <= (p[3] & 0x7ff0) -> cp WA,0x41e0 / j ult
        from frontend import N
        e = N('bin', op={'<': '>', '>': '<', '<=': '>=', '>=': '<=', '==': '==', '!=': '!='}[e.op], l=e.r, r=e.l, ty=e.ty)
        l, r = strip(e.l), strip(e.r)
    def fits_(k_, t_):
        if k_ is None: return True
        lo = -(1 << (8 * t_.size - 1)) if t_.signed else 0
        return lo <= k_ <= (1 << (8 * t_.size - (1 if t_.signed else 0))) - 1
    while l.k == 'cast' and l.kind == 'IntegralCast' and strip(l.e).ty.size <= r.ty.size and fold(r).k == 'const' and \
            not (CMP_WIDE and l.ty.size == 4 and ev_core(strip(l.e)).k == 'un' and ev_core(strip(l.e)).op == '!') and \
            not (CMP_WIDE and cw_explicit_widening(l)) and \
            not (strip(l.e).ty.size == l.ty.size and strip(l.e).ty.signed != l.ty.signed) and \
            (not CMP_CONST_FITS or fits_(fold(r).value, strip(l.e).ty)):   # _itoa: (int)u < 0
        l = strip(l.e)
    # operands promoted from the same narrower type compare at that type
    if l.k == 'cast' and r.k == 'cast' and l.kind == r.kind == 'IntegralCast' and strip(l.e).ty.size == strip(r.e).ty.size and \
            not (CMP_WIDE and l.ty.size == 4 and any(ev_core(strip(x.e)).k == 'un' and ev_core(strip(x.e)).op == '!' for x in (l, r))) and \
            not (CMP_WIDE and (cw_explicit_widening(l) or cw_explicit_widening(r))):
        l, r = strip(l.e), strip(r.e)                      # ((long)!gl < (long)!hl compares the longs: cmpordl.c cl_l_NN)
    if l.k == 'cast' and l.kind == 'IntegralCast' and fold(r).k == 'const' and strip(l.e).ty.size <= l.ty.size and \
            not (strip(l.e).ty.size == l.ty.size and strip(l.e).ty.signed != l.ty.signed) and \
            not (CMP_WIDE and l.ty.size == 4 and ev_core(strip(l.e)).k == 'un' and ev_core(strip(l.e)).op == '!') and \
            not (CMP_WIDE and cw_explicit_widening(l)) and \
            (not CMP_CONST_FITS or fits_(fold(r).value, strip(l.e).ty)):   # _itoa: (int)u < 0 (a widening cast only:
        l = strip(l.e)                                     # r4_04_11's (unsigned char)gul != 255 keeps its byte)
    size = l.ty.size; signed = l.ty.signed
    cc = (CC_S if signed else CC_U)[e.op]
    rc = fold(r)
    op = e.op
    if CMP_ORDER and size != 4 and ev_core(l).k == 'un' and ev_core(l).op == '!' and rc.k == 'const' and rc.value not in (None, 0, 1) \
            and not getattr(F, 'cmp_as_value', False):     # (in a condition only: ci_l_NK cp WA,0x1, cv_l_NK cp WA,0x7)
        from frontend import N                           # V4.23 compares !x with the truth value of the constant:
        r = N('const', value=1, ty=rc.ty); rc = r        # !gi == 7 -> cp WA,0x1 (cmpord.c ci_e_NK, ci_l_NK; imitated)
    if CMP_WIDE and (size in (1, 4) or size == 2 and (cw_char_derived(l) and cw_char_derived(r) or
                                                       any(k_ is not None and (k_[0] in ('Z', 'A') or k_[0] == 'D' and len(k_) == 4 or k_[0] == 'X' and len(k_) == 5 or
                                                                               k_[0] == 'F' and strip(unpromote(x_)).k == 'call' and strip(unpromote(x_)).args)
                                                           for x_, k_ in ((l, cw_kind(F, l, 2)), (r, cw_kind(F, r, 2)))))) and \
            not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None) and \
            getattr(F, 'u1_i', None) is None and not getattr(F, 'elem_ops', None) and (not F.opt or CMP_WIDE_OPT) and \
            not any(any(regvar_of(strip(y.e)) is not None and getattr(regvar_of(strip(y.e)), 'reg', None) not in IZ_HOMES and not (dies_here(F, y) or strip(y.e).k == 'var' and
                                                                  not uses_after_stmt(F, strip(y.e).decl)) for y in loads_in(x)) for x in (l, r)):
        nrw = size == 2 and cw_char_derived(l) and cw_char_derived(r)   # (cc900 compares two char-derived values at the
        csz = 1 if nrw else size                                        #  byte: cmpordl.c cc_l_UG ld A / neg A / cp A,(_hc))
        saved_ = (getattr(F, 'cw_pins', None), getattr(F, 'cw_start', None), getattr(F, 'cw_opline', None))
        F.cw_pins = []; F.cw_start = len(F.lines)
        try:
            co = cmp_wide(F, e, l, r, csz, op, CC_S[e.op] if nrw else cc)
            if co is not None: cw_guard(F, len(F.lines) - 1, 'cmp_wide')
        finally:                                           # (a nested rule keeps its own pins: the outer ones return)
            inner_ = F.cw_pins or []
            F.cw_pins, F.cw_start, F.cw_opline = saved_
            if F.cw_pins is not None and co is not None: F.cw_pins.extend(inner_)
        if co is not None: return co
    if CMP_ORDER and size == 2 and not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None) and \
            getattr(F, 'u1_i', None) is None and not getattr(F, 'elem_ops', None) and not any(
                nodes_in(x, 'call') or has_helper_call(x) or fpgen.is_fp_op(x) or
                any(regvar_of(strip(y.e)) is not None for y in loads_in(x)) for x in (l, r)):
        co = cmp_order(F, e, l, r, size, op, cc)
        if co is not None: return co
    if l.k == 'cast' and l.kind == 'IntegralCast' and size == 1 and strip(l.e).ty.size > 1 and rc.k == 'const' and \
            rc.value is not None and strip(l.e).k == 'load' and mem_operand(F, strip(l.e)) is not None and \
            mem_operand(F, strip(l.e)).startswith('('):   # r4_04_11: (unsigned char)gul != 255 -> ld XWA,(_gul) /
        wsz = strip(l.e).ty.size                           # cp A,0xff (the model compared all 32 bits)
        F.emit('ld', '%s,%s' % (FAM['WA'][wsz], mem_operand(F, strip(l.e))))
        F.emit('cp', 'A,%s' % hx(rc.value & 0xff)); return cc
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
        T1 = FAM[getattr(F, 'tfam', 'WA')][1]                              # ot_cmp_abn: ld C,(XHL) / cp C,(XWA)
        F.emit('ld', '%s,%s' % (T1, rvm)); F.emit('cp', '%s,%s' % (T1, lm)); return cc   # _strncmp: ld A,(XDE) / cp A,(XIX) (guess:
                                                                          # one example)
    if getattr(F, 'u1_i', None) is not None and lm is not None and lm.startswith('(') and rvm in \
            ('A', 'C', 'E', 'L', 'WA', 'BC', 'DE', 'HL', 'IX', 'IY') and rv.k == 'load' and regvar_of(rv.e):
        F.emit('cp', '%s,%s' % (lm, rvm)); return cc     # oc_cnt_c: cp (XWA+IX),E; oc_find: cp (XIX),DE
    if rvm in ('A', 'C', 'E', 'L', 'WA', 'BC', 'DE', 'HL') and lm is not None and lm.startswith('(') and e.op in ('==', '!='):
        rr = FAM[[k for k, v in FAM.items() if rvm in v.values()][0]][size]     # _strchr: cp A,(XHL)
        F.emit('cp', '%s,%s' % (rr, lm)); return cc
    if lm is not None and lm.startswith('(_') and rvm is not None and family_of(rvm) and size >= 2 and \
            rv.k == 'load' and regvar_of(rv.e):              # .sbrk: SBRK_size < size -> cp (_SBRK_size),XWA
        F.emit('cp', '%s,%s' % (lm, rvm)); return cc
    if (regvar_of(getattr(l, 'e', l)) or lm == 'XIZ' and getattr(F, 'l2', None)) and \
            lm in ('BC', 'DE', 'HL', 'IX', 'IY', 'IZ', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ') and \
            not (lm.startswith('X') and rc.k == 'const' and rc.value == 0 and op in ('==', '!=')):   # _ltoa: cp XDE,0x0
        rs = mem_operand(F, r)
        if rs is None: raise Unsupported('complex compare operand')
        F.emit('cp', '%s,%s' % (lm, rs)); return cc
    rvr = regvar_of(strip(r).e) if strip(r).k == 'load' else None
    if F.adecl and lm is None and rvr is not None and l.k == 'load' and strip(l.e).k == 'index' and size == 2 and \
            rvr.reg in FAM and not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None) and \
            not getattr(F, 'u1_i', None):
        ea = elem_addr(F, strip(l.e), 'cmp')               # .c_find: cp (XIX),DE
        if ea is not None: F.emit('cp', '%s,%s' % (ea, FAM[rvr.reg][size])); return cc
    if rc.k == 'const' and lm is None and l.k == 'load' and strip(l.e).k == 'index' and size == 2 and \
            not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None):
        lm = elem_addr(F, strip(l.e), 'cmp')               # ai_mul10: if (gsa[i] == 0) -> cpw (XBC+WA),0x0
    if rc.k == 'const' and lm is not None and lm.startswith('(') and size <= 2:
        F.emit('cp' + ('b' if size == 1 else 'w'), '%s,%s' % (lm, hx(rc.value & (0xff if size == 1 else 0xffff)))); return cc
        # (the immediate at the operand's width: _ldexp's `nn < -2047` in memory is cpw (XSP+..),0xf801)
    if l.k == 'call' and rc.k == 'const' and size == 2:   # k_cond, c_break: cal .r1 / cp HL,0x0 (cdecl too)
        gen_call(F, l); flush_pops(F, True); F.emit('cp', 'HL,%s' % hx(rc.value)); return cc   # _toupper: inc 0x2,XSP
    if rc.k == 'const' and rc.value == 0 and size == 4 and op in ('==', '!=') and lm in ('XIZ', 'XBC', 'XDE', 'XHL', 'XWA'):
        if F.opt: flush_pops(F, True)                    # _strlen: cal _memchr / inc 0x8,XSP / or XHL,XHL
        F.emit('or', '%s,%s' % (lm, lm)); return cc     # _calloc: if (ptr) -> or XIZ,XIZ
    if getattr(F, 'l2', None) and l.k == 'opassign' and rc.k == 'const':   # _itoa: if ((u /= radix) == 0) ->
        R = l2_opassign_value(F, l)                                         # ... / ld QBC,WA / cp QBC,0x0
        if R is not None: F.emit('cp', '%s,%s' % (R, hx(rc.value))); return cc
    la = l
    if la.k == 'bin' and la.op == '=' and strip(la.l).k == 'var' and getattr(strip(la.l).decl, 'reg', None) in \
            ('BC', 'DE', 'HL', 'IX', 'IY') and rc.k == 'const' and rc.value == 0 and op in ('==', '!='):
        fv = gen_assign_value(F, la, 'WA', size)           # ae_i_ne_l: ld BC,(XSP+0x4) / ld WA,BC / cp WA,0x0
        if (F.opt and ASSIGN_CMP_INPLACE) or held_after(F, 'WA', la) or any(
                getattr(d, 'reg', None) == 'WA' and d not in F.dead and d in getattr(F, 'in_loop', ())
                for d in list(F.f.params) + list(F.f.decls)):   # (-Xr ae_c_loop: s in XWA, ld A,E was wrong code)
            W = FAM[fv][size]                              # -O: the variable's own register (assign_expr.c
        else:                                              # ae_c_loop -O3 -XS -Xr: ld C,(XWA+:1) / cp C,0x0)
            F.emit('ld', '%s,%s' % (FAM['WA'][size], FAM[fv][size])); W = FAM['WA'][size]
        F.emit('or', '%s,%s' % (W, W)) if size == 4 else F.emit('cp', '%s,0x0' % W); return cc
    ra = strip(r)
    while ra.k == 'cast' and ra.kind == 'IntegralCast': ra = strip(ra.e)
    if ra.k == 'bin' and ra.op == '=' and mem_operand(F, r) is None:
        fr = gen_assign_value(F, ra, 'WA', size, in_place=True)   # assign_expr.c ae_i_two: (gi = x) == (gi2 = z)
        la2 = strip(l)                                     # -> ld WA,(z) / ld (_gi2),WA / ld BC,(x) / ld (_gi),BC /
        while la2.k == 'cast' and la2.kind == 'IntegralCast': la2 = strip(la2.e)
        fl = gen_assign_value(F, la2, 'BC' if fr == 'WA' else 'WA', size, in_place=True) if \
            la2.k == 'bin' and la2.op == '=' else gen(F, l, 'BC' if fr == 'WA' else 'WA', size)
        if fl == fr: raise Unsupported('compare of two assignments in one register')
        F.emit('cp', '%s,%s' % (FAM[fl][size], FAM[fr][size])); return cc   # cp BC,WA
    if getattr(F, 'u1_i', None) is not None and lm is not None and lm.startswith('(X') and l.k == 'load' and \
            strip(l.e).k == 'index':                       # cdecl oc_find: the chain is built once (by mem_operand)
        f0 = 'WA'; F.emit('ld', '%s,%s' % (FAM['WA'][size], lm))   # -> ld WA,(XWA) / cp WA,(XSP+0xa)
    else:
        if IDX_GUARD and any(getattr(d, 'reg', None) == 'WA' and d not in F.dead and uses_decl(r, d) and
                             not uses_decl(l, d) for d in list(F.f.params) + list(F.f.decls)):
            raise Unsupported('compare operand over a variable in WA')   # (c1 != c2 with c2 in A: ld A,C / cp A,A)
        f0 = gen(F, l, 'WA', size)
    W = FAM[f0][size]                                      # (the value's own register: ae_i_ptr cp BC,0x0)
    if rc.k == 'const' and rc.value == 0 and size == 4 and op in ('==', '!='):
        F.emit('or', '%s,%s' % (W, W)); return cc
    rs = mem_operand(F, r)
    if rs is None: raise Unsupported('complex compare operand')
    F.emit('cp', '%s,%s' % (W, rs)); return cc

def ret_target(F, target):
    """'RET' stands for the function exit; a function that returns with retd has no `ret cc`, its early exits jump
    to the exit label (r1_07_03 -Xr: j lt,L8 ... L8: retd 0x8)"""
    if target == 'RET' and getattr(F, 'retd', 0):
        if not getattr(F, 'exit_label', None): F.exit_label = F.newlabel()
        return F.exit_label
    return target

def jump(F, cc, target):
    target = ret_target(F, target)
    F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target))

def table_test(c):
    """(table global, index expression, bit) when c is `tab[(unsigned char)(x)] & (1 << bit)` (ctype.h's isdigit(),
    islower() ...), else None"""
    c = strip(c)
    while c.k == 'cast' and c.kind == 'IntegralCast': c = strip(c.e)
    if c.k != 'bin' or c.op != '&': return None
    m = fold(c.r)
    if m.k != 'const' or m.value is None or m.value <= 0 or m.value & (m.value - 1): return None
    x = strip(c.l)
    while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
    if x.k != 'load' or strip(x.e).k != 'index': return None
    ix = strip(x.e); base = strip(ix.base)
    while base.k in ('decay', 'cast'): base = strip(base.e)
    if base.k != 'var' or base.decl.kind != 'global' or x.ty.size != 1: return None
    idx = strip(ix.idx)
    while idx.k == 'cast' and idx.kind == 'IntegralCast' and idx.ty.size >= 2: idx = strip(idx.e)
    if not (idx.k == 'cast' and idx.ty.size == 1 and not idx.ty.signed): return None
    return base.decl, strip(idx.e), m.value.bit_length() - 1

def gen_table_test(F, tt):
    """ld A,<x> / extz WA / [lda XBC,_tab] / bit k,(XBC+WA); returns 'ne' (the condition is true on ne)
    (_strupr, _atoi: the index in t1 = WA, the base in its L2 register, hoisted or per use)"""
    tab, x, bit = tt
    m = mem_operand(F, x)
    if m is None: raise Unsupported('table index')
    fm = family_of(m); fm = fm[1:] if fm and fm.startswith('X') else fm
    if fm and 1 not in FAM.get(fm, {}): raise Unsupported('table index in a register without a byte')
    if m not in ('A',):
        F.emit('ld', 'A,%s' % (FAM[fm][1] if fm else m))
    F.emit('extz', 'WA')
    l2 = getattr(F, 'l2', {})
    breg = l2.get('tab_inv', {}).get(tab)
    if breg is None:
        breg = l2.get('tab_once', {}).get(tab)
        if breg is None: raise Unsupported('table base')
        F.emit('lda', 'X%s,_%s' % (breg, tab.name))
    F.emit('bit', '%s,(X%s+WA)' % (hx(bit), breg))
    return 'ne'

def unpromote(x):
    x = strip(x)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size <= x.ty.size: x = strip(x.e)
    return x

TABLE_BIT_MEM = True                                      # see byte_addr

def byte_addr(F, x):
    """a memory operand for the byte x that `bit n,(...)` can test in place (cond_bits.c: (XSP+0x4), (_guc),
    (XWA), (XWA+0x3), (XWA+0xb), (XSP+0x7)), emitting the pointer load; None when x is not such a byte"""
    x = strip(x)
    if x.k != 'load': return None
    m = mem_operand(F, x)
    if m is not None and m.startswith('('): return m
    v = strip(x.e); off = 0
    if TABLE_BIT_MEM and v.k == 'index' and strip(v.base).k == 'var' and strip(v.base).decl.kind == 'global' and \
            strip(v.base).decl.ty.kind == 'array' and v.ty.size == 1:
        uc = strip(v.idx)                                # ctype tests: gtab[(unsigned char)ch] & 0x4 tested in place
        while uc.k == 'cast' and uc.kind == 'IntegralCast' and uc.ty.size >= 2: uc = strip(uc.e)
        if uc.k == 'cast' and uc.ty.size == 1 and not uc.ty.signed:
            ix = strip(uc.e); xm = mem_operand(F, ix)
            if xm is not None and ix.ty.size in (1, 2) and ix.k == 'load':
                rv = regvar_of(ix.e)
                tab = strip(v.base).decl.name
                if rv is not None and not dies_here(F, ix):   # arr_index.c ai_dig_val (-Xr): ch in A is needed
                    F.emit('ld', '%s,%s' % ('C' if ix.ty.size == 1 else 'BC', xm))   # after: ld C,A / extz BC /
                    F.emit('extz', 'BC'); F.emit('lda', 'XDE,_%s' % tab); return '(XDE+BC)'   # bit 0x2,(XDE+BC)
                W = FAM['WA'][ix.ty.size]                 # cond_bits.c cb_tern: ld WA,c / extz WA / lda XBC,_gtab /
                if xm != W: F.emit('ld', '%s,%s' % (W, xm))   # bit 0x1,(XBC+WA)
                F.emit('extz', 'WA'); F.emit('lda', 'XBC,_%s' % tab); return '(XBC+WA)'
    if v.k == 'index' and fold(v.idx).k == 'const' and fold(v.idx).value is not None:
        off = fold(v.idx).value * v.ty.size; v = strip(v.base)
        if v.k == 'load': p = v
        elif v.k == 'member' and v.arrow: off += member_offset(v); p = v.base
        elif v.k == 'member' and not v.arrow and strip(v.base).k == 'var' and strip(v.base).decl.kind == 'local' and \
                getattr(strip(v.base).decl, 'slot', None) is not None:
            t = strip(v.base).decl.slot + F.push + member_offset(v) + off    # cb_union_c7: bit 0x7,(XSP+0x7)
            return '(XSP+%s)' % hx(t) if t else '(XSP+0x0~)'
        else: return None
    elif v.k == 'deref': p = v.e
    elif v.k == 'member' and v.arrow: off = member_offset(v); p = v.base
    else: return None
    pm = mem_operand(F, p)
    if pm is None: return None
    if pm != 'XWA':
        if pm.startswith('X') or pm.startswith('('): F.emit('ld', 'XWA,%s' % pm)
        else: return None
    return '(XWA+%s)' % hx(off) if off else '(XWA)'

def bit_cond(F, c):
    """x & mask as a branch condition (cond_bits.c, no -O form): a one-bit mask is `bit n`, in memory for a byte
    (except bit 7 of a signed char, which is loaded first), on WA / QWA for an int or a long; another mask is
    `and`.  Emits the test and returns the condition code that means `c is true`, or None (nothing emitted) when
    c is not of that shape"""
    c = strip(c); sense = 'ne'
    if c.k == 'bin' and c.op in ('==', '!=') and fold(c.r).k == 'const' and fold(c.r).value == 0:
        sense = 'eq' if c.op == '==' else 'ne'; c = strip(c.l)
        while c.k == 'cast' and c.kind == 'IntegralCast': c = strip(c.e)
    if not (c.k == 'bin' and c.op == '&' and c.ty.kind == 'int'): return None
    l, r = c.l, c.r
    if fold(l).k == 'const': l, r = r, l
    x = unpromote(l); xs = x.ty.size; rc = fold(r)
    if xs not in (1, 2, 4) or x.ty.kind not in ('int', 'ptr'): return None
    if rc.k != 'const' or rc.value is None:
        y = unpromote(r)
        if y.ty.size != xs: return None
        xr = reg_or_mem(F, x, xs); yr = reg_or_mem(F, y, xs)
        if yr is None and reg_or_mem(F, x, xs) is not None and xs == 2 and not F.adecl:
            fam = gen(F, y, 'BC', xs); yr = FAM[fam][xs]      # cb_shift: ld BC,0x8000 / ... / srl A,BC / and WA,BC
        if yr is None: return None
        if xr is None or xr.startswith('('):
            fam = gen(F, x, 'WA', xs); xr = FAM[fam][xs]
        F.emit('and', '%s,%s' % (xr, yr)); return sense
    m = rc.value & {1: 0xff, 2: 0xffff, 4: 0xffffffff}[c.ty.size]
    if xs == 1 and m > 0xff or m == 0: return None
    single = m & (m - 1) == 0; n = m.bit_length() - 1
    if xs == 1 and single and not (x.ty.signed and n == 7):
        a = byte_addr(F, x)
        if a is not None: F.emit('bit', '%s,%s' % (hx(n), a)); return sense
    xr = reg_or_mem(F, x, xs)
    if x.k == 'call':                                  # cb_call: cal _f / inc 0x2,XSP / bit 0x3,HL
        fam = gen(F, x, 'HL', xs); flush_pops(F); xr = FAM[fam][xs]
    elif xr is None or xr.startswith('(') or xr == 'XIZ':
        fam = gen(F, x, 'WA', xs); xr = FAM[fam][xs]
    if single:
        if xs == 4: F.emit('bit', '%s,%s' % (hx(n - 16), 'Q' + xr[1:]) if n >= 16 else '%s,%s' % (hx(n), xr[1:]))
        else: F.emit('bit', '%s,%s' % (hx(n), xr))
    else: F.emit('and', '%s,%s' % (xr, hx(m)))
    return sense

CHAR_NARROW = True                                        # see char_narrow
OR_BIT_SET = True                                         # see compile_function
LN1_NOLOOP = True                                         # LN1 for loop-free leaf functions too (assign_expr chain family)
LEAF_NONE_LN1 = True                                      # see plan_leaf (model/leafnone.py)
COPY_ELEM_DE = True                                       # see gen_stmt's store (ol_i_copy)
STORE_ADDR_GUARD = True                                   # see clobbers
REG_MEMBER = True                                         # see mem_operand (ae_fl_chain)
HELD_LATER = True                                         # see held_after (lnr.c's dummies)
PTR_ELEM_REGVAL = True                                    # see gen_stmt's store (r_p_wri)
PTR_ELEM_XDE = True                                       # see gen_opassign (s_add_gw)
STORE_GLOBAL_FREE = True                                  # see store_global (r_p_rd)
KLOOP_VALUE_WA = True                                     # see plan_leaf (r_ga_rd)
SHIFT_VALUE_FREE = True                                   # see gen_bin's variable shift (r_shl_i)
HOMED_WRITES = True                                       # see regvar_stmt (_strtok)
LOCAL_ARRAY_INIT = True                                   # see gen_stmt's decl (__fint's maru)
ARRAY_TAIL_DFB = True                                     # see the data emitter (_CTYPE.C)
STORE_FORWARD = True                                      # see store_forward (_strtok)
POP_LDA_LIVE = True                                       # see gen_stmt's if (___fmemccpy)
PTRDIFF_INPLACE = True                                    # see gen_ptr_arith (___fmemccpy)
PUSH_ANY_FAM = True                                       # see push_arg / gen_bin (___fmemccpy)
LOOP_FLUSH_POPS = True                                    # see gen_stmt's loops (fpp7 m14)
POP_MERGE_MAX = 32                                        # see gen_stmt's call statement (fpp7 m14, regkw, _log)
FP_ARRAY_DATA = True                                      # see the data emitter (_s_coshtbl)
OPASSIGN_CALL_HL = True                                   # see gen_opassign (homes2b HL05)
MEMBER_CSE = True                                         # see member_cse (_fgetc)
FOLD_NOT = True                                           # see fold (~K)
SHIFT_SPLIT = True                                        # see emit_shift (r1_08_03)
ULONG_DIV_SHIFT = True                                    # see gen_bin (r1_01_15)
CONST_LEFT_SWAP = True                                    # see gen_bin (r1_04_16), gen_long_helper (r1_00_05)
UIDX32 = True                                             # see elem_addr (r1_08_00)
ELEM_LEFT_COMMUTE = True                                  # see gen_bin (r1_02_19)
ARGS_LIVE_NO_FLUSH = True                                 # see flush_pops (fpp11 q15)
NOT_MEMBER_CP = True                                      # see gen's ! (r1_06_01)
CALL_RIGHT_XR = True                                      # see gen_bin (r1_01_18)
FOLD_DIV = True                                           # see fold (r1_02_06)
OPB_GLOBAL = True                                         # see gen_opassign (r1_03_19)
CHAR_HOMES = True                                         # see plan_homes (r1_05_05, r1_04_01)
PTR_RIGHT_BC = True                                       # see gen_bin, ptr_access (r1_06_08, r1_08_07, r1_04_16)
UCHAR_MOD_AND = True                                      # see gen_bin (r1_04_05)
XR_FIRST_LIVE = True                                      # see plan_homes (r1_05_01)
FOLD_UCHAR_CMP = True                                     # see fold (r1_05_01)
PTRSUM_FREE_X = True                                      # see gen_ptr_arith (r1_06_01)
TERN_PRE_GUARD = True                                     # see gen's -O ?: (r1_05_05)
RIGHT_CLOBBER_GUARD = True                                # see gen_bin (r2_02_18, r2_05_13, r2_06_05)
HELPER_CONST_DIV = True                                   # see has_helper_call (r2_04_15)
FOLD_SELF_DIV = True                                      # see fold (r2_05_00)
CMP_CONST_FITS = True                                     # see gen_compare (r2_05_02)
NO_FOLD_OVER_STORE = True                                 # see ptr_store_before_use (r2_08_05)
MEMBER_PTR_CHAR_LDA = True                                # see gen_ptr_arith (r2_02_05)
CHAR_NARROW_NOT = True                                    # see char_narrow (r2_09_00)
NEG_FREE_FAM = True                                       # see gen's unary - (r2_01_01)
PTR_STORE_FREE = True                                     # see lvalue (r2_06_02)
FOLD_CONST_CMP = True                                     # see fold (r2_06_17)
LIVE_PARAM_GUARD = True                                   # see F.emit, written_fams (r2_07_15, r2_09_01)
LIVE_LOCAL_GUARD = True                                   # the same for register locals (r3_04_08, r3_01_13)
COND_FLUSH_POPS = True                                    # see gen_cond_false / true (r3_00_13, r3_06_08)
UIDX32_EXPR = True                                        # see elem_addr (r3_04_11)
CHAR_PRODUCT_DIV_GUARD = True                             # see gen_bin (r3_07_12)
VALUE_FIRST_CHIDX = True                                  # see gen_stmt's assignment (r1_02_19)
POP_FLUSH_NOCALL = True                                   # see gen_stmt's expression statements (r1_02_19)
CALL_RIGHT_GENERAL = True                                 # see gen_bin (r1_04_01)
SHIFT_COUNT_EXPR = True                                   # see the shift paths (r1_03_04, r1_03_06)
ADDR_ELEM_REG = True                                      # see gen's addr (r1_00_00)
PK_STORE_XBC = True                                       # see lvalue's p[k] (r1_03_04)
INC_ELEM = True                                           # see gen_opassign (chidx kc2)
DEC_CMP_SUB = True                                        # dec 0x1,R / cp R,0x0 -> sub R,0x1 (opt_counted.c oc_down)
TERN_TRUTH_PRE = True                                     # see gen's -O ?: path
RET_CC_KEEPS = True                                       # see knowledge_pass
TERN_ARM_LAST = True                                      # see compute_last_uses
TERN_NO_MERGE = True                                      # see cross_jump
TERN_ARM_WA = True                                        # see gen's plain ?: path
LONG_RMW_XIZ = True                                       # see gen_opassign
KCONST_MULTI = True                                       # see gen_counted
PTR_KLOOP = True                                          # see ptr_kloop
STORE_FROM_WORK = True                                    # see store_global
ASSIGN_CMP_INPLACE = True                                 # see gen_compare
LOOP_COND_DEF = True                                      # see compute_last_uses
CHAR_LOCAL_WA = True                                      # see plan_leaf
ASSIGN_OPERAND_INPLACE = True                             # see gen_bin
POSTDEC_FREE = True                                       # see loop_cond
PTR_INDEX_REG = True                                      # see gen_load_mem
EMPTY_WHILE_ONE_LABEL = True                              # see gen_loop
IDX_GUARD = True                                          # see elem_addr
LEAF_KEEP_TAKEN = True                                    # see plan_leaf
IF_FLUSH_POPS = True                                      # see gen_stmt's if
ADDR_CLOBBER_SWAP = True                                  # see gen_bin
CHAR_NARROW_TERN = True                                   # see char_narrow
LOOP_FLUSH_POPS = True                                    # see gen_loop
SWITCH_LOOP_LABEL = True                                  # see gen_switch
CHAR_CONST_PUSHW = True                                   # see push_arg
CSE_GLOBALS = True                                        # see cse_params
XR_CHAIN_INPLACE = True                                   # see gen_bin

def char_narrow(body):
    """cc900 does int + - & | ^ of a char and a constant that fits a byte, or of two chars, on the byte and
    extends the result (probes/chnarrow.c, run 2026-11-09-30-micro-chnarrow: c - 48 -> sub A,0x30 / ld L,A /
    exts HL).  The byte is unsigned when either side is: an unsigned char, or a constant 128..255 (c + 200 ->
    add A,0xc8 / ... / extz HL).  A constant that needs a word (c - 300), an int operand or * widen first.
    Rewritten in place: (int)x op k becomes (int)(x op k) with a char-typed operation."""
    from frontend import N, Type
    def chr_of(x):
        x = strip(x)
        if x.k == 'cast' and x.kind == 'IntegralCast' and x.ty.size == 2 and strip(x.e).ty is not None and \
                strip(x.e).ty.kind == 'int' and strip(x.e).ty.size == 1:
            return strip(x.e)
        if CHAR_NARROW_TERN and x.k == 'cond' and x.ty is not None and x.ty.size == 2:   # arr_index.c ai_up_sub:
            sg = byte_arms(x)                                                    # (c ? ch - 32 : ch) - 55 is done in
            if sg is not None:                                                   # the byte too
                def arm(a):
                    a = strip(a)
                    if fold(a).k == 'const': return N('const', value=fold(a).value, ty=ct0(sg))
                    return strip(a.e)
                return N('cond', c=x.c, a=arm(x.a), b=arm(x.b), ty=ct0(sg))
        return None
    def ct0(sg): return Type('int', 1, 1, signed=sg, spell='char' if sg else 'unsigned char')
    def visit(n, d):
        if CHAR_NARROW_NOT and n.k == 'un' and n.op == '~' and n.ty is not None and n.ty.kind == 'int' and n.ty.size == 2:
            x = chr_of(n.e)
            if x is not None and x.k != 'cond':            # r2_09_00: ~guca[3] / 3 -> cpl A / extz WA / div WA,0x3
                ct = ct0(x.ty.signed); inner = N('un', op='~', e=x, ty=ct, narrowed=True); it = n.ty
                n.__dict__.clear(); n.k = 'cast'; n.kind = 'IntegralCast'; n.e = inner; n.ty = it
            return
        if not (n.k == 'bin' and n.op in ('+', '-', '&', '|', '^') and n.ty is not None and n.ty.kind == 'int' and
                n.ty.size == 2 and n.ty.signed):           # (r4_09_15: (unsigned int)gc - 255 is exts WA / sub WA,0xff:
            return                                         # an unsigned int operation is not narrowed)
        x = chr_of(n.l)
        if x is None: return
        rk = fold(n.r); y = chr_of(n.r); op = n.op
        if rk.k == 'const' and rk.value is not None and op in ('+', '-') and -255 <= rk.value < 0:
            op = '-' if op == '+' else '+'               # cond_bits.c cb_tern_char: c + ('A' - 'a') -> sub 0x20
            rk = N('const', value=-rk.value, ty=rk.ty)
        if rk.k == 'const' and rk.value is not None and 0 <= rk.value <= 255:
            signed = x.ty.signed and rk.value <= 127
            ct = Type('int', 1, 1, signed=signed, spell='char' if signed else 'unsigned char')
            r = N('const', value=rk.value, ty=ct)
        elif y is not None:
            signed = x.ty.signed and y.ty.signed
            ct = Type('int', 1, 1, signed=signed, spell='char' if signed else 'unsigned char'); r = y
        else: return
        inner = N('bin', op=op, l=x, r=r, ty=ct, narrowed=True)
        it = n.ty
        n.__dict__.clear(); n.k = 'cast'; n.kind = 'IntegralCast'; n.e = inner; n.ty = it
    walk(body, visit)
    if CHAR_NARROW_TERN: walk(body, visit)                 # (a second pass sees the arms the first one narrowed)

def copy_propagate(f):
    """-O: a local assigned exactly once, from a parameter that the function never writes, is that parameter
    (assign_expr.c under -O3 -XS: ae_i_ne_l `if ((y = x) != 0) return (int)(y == x);` -> cpw (XSP+0x4),0x0 /
    ld HL,0x1; ae_i_chain_lg `gi = y = x; gr = (int)(y != 0);` -> the value held in WA serves both).  The
    assignment keeps its value where one is used; a statement that is only `y = x` disappears."""
    import copy as _copy
    from frontend import N
    def simplify(node):                                    # x + 0, x - 0 -> x (ra_call.c rc_keep1: v0 = a + 0)
        for key, val in list(node.__dict__.items()):
            items = val if isinstance(val, list) else [val]
            for i, x in enumerate(items):
                if not hasattr(x, 'k'): continue
                simplify(x)
                if x.k == 'bin' and x.op in ('+', '-') and fold(x.r).k == 'const' and fold(x.r).value == 0 and \
                        not x.ty.is_ptr() and strip(x.l).ty is not None and strip(x.l).ty.size == x.ty.size:
                    if isinstance(val, list): val[i] = x.l
                    else: setattr(node, key, x.l)
    simplify(f.body)
    def pow2_opassign(n, dep):                             # _doodigit: val /= 8 (unsigned long) -> srl 0x3,XDE
        if POW2_UNSIGNED and n.k == 'opassign' and n.op in ('/', '%') and strip(n.l).ty is not None and \
                strip(n.l).ty.kind == 'int' and not strip(n.l).ty.signed:
            k = fold(n.r)
            if k.k == 'const' and k.value is not None and k.value >= 2 and k.value & (k.value - 1) == 0:
                if n.op == '/': n.op = '>>'; n.r = N('const', value=k.value.bit_length() - 1, ty=n.r.ty)
                else: n.op = '&'; n.r = N('const', value=k.value - 1, ty=n.r.ty)
    walk(f.body, pow2_opassign)
    assigns = {}; writes = set(); addr = set()
    def v(n, dep):
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': assigns.setdefault(strip(n.l).decl, []).append(n)
        if n.k in ('opassign',) and strip(n.l).k == 'var': writes.add(strip(n.l).decl)
        if n.k == 'incdec' and strip(n.e).k == 'var': writes.add(strip(n.e).decl)
        if n.k == 'addr' and strip(n.e).k == 'var': addr.add(strip(n.e).decl)
    walk(f.body, v)
    decl_init = []
    walk(f.body, lambda n, dep: decl_init.append(n) if n.k == 'decl' and n.init is not None else None)
    inited = {c.var for c in decl_init}
    for d, al in assigns.items():
        if d.kind != 'local' or len(al) != 1 or d in writes or d in addr or d in inited or d.ty.kind not in ('int', 'ptr'):
            continue
        a = al[0]; src = strip(a.r)
        while src.k == 'cast' and src.kind == 'NoOp': src = strip(src.e)
        sc = fold(narrow(a.r, d.ty.size)) if d.ty.kind == 'int' else None
        if sc is not None and sc.k == 'const' and sc.value is not None and CONST_PROP:
            repl = N('const', value=sc.value, ty=d.ty)       # ra_call.c rc_loop1: v0 = 0 ... f1(v0) -> ld WA,0x0
        elif not (src.k == 'load' and strip(src.e).k == 'var'): continue
        else:
            p = strip(src.e).decl
            if p.kind != 'param' or p in writes or p in addr or p in assigns or p.ty.size != d.ty.size or \
                    p.ty.kind != d.ty.kind:
                continue
            repl = N('load', e=N('var', decl=p, ty=p.ty), ty=p.ty)
        def rewrite(node):                                 # y = x as a value -> x; uses of y -> x
            for key, val in list(node.__dict__.items()):
                items = val if isinstance(val, list) else [val]
                for i, x in enumerate(items):
                    if not hasattr(x, 'k'): continue
                    if x is a:
                        new = _copy.copy(repl)
                        if isinstance(val, list): val[i] = new
                        else: setattr(node, key, new)
                        continue
                    if x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl is d:
                        new = _copy.copy(repl)
                        if isinstance(val, list): val[i] = new
                        else: setattr(node, key, new)
                        continue
                    rewrite(x)
        rewrite(f.body)
        def prune(node):                                   # a statement that was only `y = x` is now `x;`: drop it
            if getattr(node, 'k', None) == 'block':
                node.body = [c for c in node.body if not (c.k == 'expr' and (strip(c.e).k == 'load' and
                             strip(strip(c.e).e).k == 'var' or strip(c.e).k == 'const'))]
            for key, val in list(node.__dict__.items()):
                for x in (val if isinstance(val, list) else [val]):
                    if hasattr(x, 'k'): prune(x)
        prune(f.body)
    cnt = {}                                               # the front end's use counts are stale now (plan_frame
    walk(f.body, lambda n, dep: cnt.__setitem__(n.decl, cnt.get(n.decl, 0) + 1) if n.k == 'var' else None)   # slots:
    for d in list(f.params) + list(f.decls):                # rc_loop1's v0 has none left)
        if hasattr(d, 'uses') and isinstance(d.uses, int): d.uses = cnt.get(d, 0)

def bool_returns(s):
    """-O: `if (c) return 1; return 0;` is `return c` as a truth value (cond_bits.c under -O3 -XS: and A,0x80 /
    cp A,0x0 / scc ne,HL; cb_lt_mask: scc uge,HL), and with 0 / 1 its negation; c is a comparison, x & m or !"""
    from frontend import N
    if getattr(s, 'k', None) != 'block': return
    for c in s.body:
        for f in ('then', 'els', 'body'):
            x = getattr(c, f, None)
            if hasattr(x, 'k'): bool_returns(x)
    def ret_const(x):
        while getattr(x, 'k', None) == 'block' and len(x.body) == 1: x = x.body[0]
        if getattr(x, 'k', None) != 'return' or x.value is None: return None
        v = fold(x.value)
        return v.value if v.k == 'const' and v.value in (0, 1) and not fpgen.is_fp(v.ty) else None
    i = 0
    while i + 1 < len(s.body):
        c, nx = s.body[i], s.body[i + 1]
        if c.k == 'if' and c.els is None and ret_const(c.then) is not None and ret_const(nx) is not None and \
                ret_const(c.then) != ret_const(nx):
            cond = strip(c.cond); neg = ret_const(c.then) == 0
            while cond.k == 'un' and cond.op == '!': cond = strip(cond.e); neg = not neg
            ok = cond.k == 'bin' and (cond.op in CC_S or cond.op == '&') and not fpgen.is_fp(strip(cond.l).ty) and \
                cond.ty.kind == 'int'
            if ok:
                rt = nx.value.ty
                if cond.op == '&':
                    v = N('bin', op='==' if neg else '!=', l=cond, r=N('const', value=0, ty=cond.ty), ty=rt)
                elif neg:
                    v = N('bin', op={'==': '!=', '!=': '==', '<': '>=', '>=': '<', '>': '<=', '<=': '>'}[cond.op],
                          l=cond.l, r=cond.r, ty=rt)
                else: v = cond
                s.body[i:i + 2] = [N('return', value=v)]
                continue
        i += 1

def and_truth(F, e, fam):
    """(x & m) != 0 as a value (cond_bits.c cb_ret_bool; the -O form of the if-return): the and at the operand's
    width, cp R,0x0 (or XWA,XWA for a long), scc; -O writes & 0xff of an int as ld W,0x0 and & 0xffff0000 of a long
    as ld WA,0x0.  Returns None (nothing emitted) when e is not of that shape"""
    if not (e.k == 'bin' and e.op in ('==', '!=') and fold(e.r).k == 'const' and fold(e.r).value == 0): return None
    a = strip(e.l)
    while a.k == 'cast' and a.kind == 'IntegralCast': a = strip(a.e)
    if not (a.k == 'bin' and a.op == '&' and a.ty.kind == 'int'): return None
    l, r = a.l, a.r
    if fold(l).k == 'const': l, r = r, l
    x = unpromote(l); xs = x.ty.size; rc = fold(r)
    if xs not in (1, 2, 4): return None
    if rc.k == 'const' and rc.value is not None:
        m = rc.value & {1: 0xff, 2: 0xffff, 4: 0xffffffff}[a.ty.size]
        if xs == 1 and m > 0xff: return None
        ro = hx(m)
    else:
        y = unpromote(r)
        if y.ty.size != xs: return None
        ro = reg_or_mem(F, y, xs); m = None
        if ro is None:
            if reg_or_mem(F, x, xs) is None or xs != 2 or F.adecl: return None
            f2 = gen(F, y, 'BC', xs); ro = FAM[f2][xs]
    if x.k == 'call':
        xf = gen(F, x, 'HL', xs); flush_pops(F)
    else:
        xr = reg_or_mem(F, x, xs)
        xf = family_of(xr) if xr is not None and not xr.startswith('(') and xr != 'XIZ' else None
        if xf is None or xf not in FAM: xf = gen(F, x, 'WA', xs)
    R = FAM[xf][xs]
    if F.opt and m == 0xff and xs == 2 and xf in ('WA', 'BC', 'DE', 'HL'): F.emit('ld', '%s,0x0' % HIGHB8[xf])
    elif F.opt and m == 0xffff0000 and xs == 4: F.emit('ld', '%s,0x0' % FAM[xf][2])
    else: F.emit('and', '%s,%s' % (R, ro))
    F.emit('or', '%s,%s' % (R, R)) if xs == 4 else F.emit('cp', '%s,0x0' % R)
    F.emit('scc', '%s,%s' % ('eq' if e.op == '==' else 'ne', FAM[fam][2])); return fam

HIGHB8 = {'WA': 'W', 'BC': 'B', 'DE': 'D', 'HL': 'H'}

def gen_assign_value(F, e, fam, size, in_place=False):
    """an assignment used as a value (assign_expr.c): the value is built once in a register and stored, and the
    register is the expression's value.  A global, parameter or slot is stored directly (ld WA,(XSP+0x4) /
    ld (_gi2),WA / ld (_gi),WA for gi = gi2 = x); through a pointer the address goes to XWA first and the value to
    BC's family (ld XWA,(XSP+0x4) / ld C,(XSP+0x8) / ld (XWA),C)"""
    lv = strip(e.l); vs = lv.ty.size
    if fpgen.is_fp(lv.ty) or lv.ty.kind == 'struct': raise Unsupported('operator =')
    rv = narrow(e.r, vs)
    if lv.k == 'var' and getattr(lv.decl, 'reg', None) in ('IX', 'IY', 'IZ') and vs == 2:
        x = strip(rv)
        if x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == 1:
            d = lv.decl; inner = strip(x.e)                # __doprnt: c = *fmt++ with c in IZ -> ... ld C,(XWA+:1) /
            fb = gen(F, inner, 'BC', 1)                    # ... / ld IZL,C / exts IZ
            F.emit('ld', '%sL,%s' % (d.reg, FAM[fb][1]))
            F.emit('exts' if inner.ty.signed else 'extz', d.reg); return d.reg
    if lv.k == 'var' and getattr(lv.decl, 'reg', None) in FAM and lv.decl.reg != 'XIZ':
        d = lv.decl                                        # ae_c_ne_l: (y = x) with y in C -> ld C,(XSP+0x4)
        f2 = gen(F, rv, d.reg, vs)
        if f2 != d.reg: F.emit('ld', '%s,%s' % (FAM[d.reg][vs], FAM[f2][vs]))
        return d.reg
    if lv.k == 'var' and getattr(lv.decl, 'reg', None):
        raise Unsupported('operator = to a register variable')
    if lv.k == 'var':
        t = lvalue(F, lv)
        if strip(rv).k == 'call' and not has_helper_call(strip(rv).fn):   # ae_i_call_g: cal _g / ld (_gi),HL /
            gen_call(F, strip(rv)); flush_pops(F)                        # cp HL,0x0
            F.emit('ld', '%s,%s' % (t, FAM['HL'][vs])); return 'HL'
        sv = unpromote(rv)
        src = regvar_of(sv.e) if sv.k == 'load' and sv.ty.size == vs else None
        if src is not None and src.reg in FAM and (in_place or src.reg == fam):   # .ae_i_two under -Xr:
            F.emit('ld', '%s,%s' % (t, FAM[src.reg][vs])); return src.reg   # ld (_gi2),BC / ld (_gi),WA / cp WA,BC
        if src is not None and src.reg in FAM:             # .ae_i_ret_g: ld HL,WA / ld (_gi),HL
            F.emit('ld', '%s,%s' % (FAM[fam][vs], FAM[src.reg][vs])); F.emit('ld', '%s,%s' % (t, FAM[fam][vs]))
            return fam
        f2 = gen(F, rv, fam, vs)
        F.emit('ld', '%s,%s' % (t, FAM[f2][vs])); return f2
    if lv.k in ('deref', 'member', 'index'):
        if fam in ('WA',):
            t = lvalue(F, lv, ptr='XWA')
            if 'XBC' in t or 'BC' in t.replace('XBC', ''): raise Unsupported('operator = through BC')
            V = 'BC'
            if held_after(F, 'BC', e):                     # opt_loops.c ol_strcpy (-Xr): *d++ = *s++ with s in
                V = next((r for r in ('DE', 'HL') if r not in t and not held_after(F, r, e)), None)   # XBC: the byte
                if V is None: raise Unsupported('operator = value register')   # in E (ld C,(XBC+:1) was wrong code)
            n0_ = len(F.lines); f2 = gen(F, rv, V, vs)
            if STORE_ADDR_GUARD and clobbers(F.lines[n0_:], t):   # (-Xr r1_04_07: gpi[2] = *c = (a != gi3) >> (a & 15)
                raise Unsupported('operator = value over its address')   # built the count in WA over c in XWA)
            F.emit('ld', '%s,%s' % (t, FAM[f2][vs])); return f2
    raise Unsupported('operator =')

def gen_cond_true(F, c, target):
    """jump to target when c is true (ctrl.c: c_orbr's first operand)"""
    c = strip(c); target = ret_target(F, target)
    if F.pending and COND_FLUSH_POPS and not nodes_in(c, 'call') and not getattr(F, 'arg_bases', None):
        flush_pops(F)
    if FOLD_CONST_CMP and c.k == 'bin' and c.op in ('&&', '||'):
        fl, fr = fold(c.l), fold(c.r)
        if fr.k == 'const' and fr.value is not None:
            if c.op == '||': return (F.emit('j', target) if fr.value else gen_cond_true(F, c.l, target))
            return gen_cond_true(F, c.l, target) if fr.value else None
        if fl.k == 'const' and fl.value is not None:
            if c.op == '||': return (F.emit('j', target) if fl.value else gen_cond_true(F, c.r, target))
            return gen_cond_true(F, c.r, target) if fl.value else None
    if FOLD_CONST_CMP and c.k == 'bin' and c.op in ('<', '<=', '>', '>=', '==', '!=') and fold(c).k == 'const':
        if fold(c).value: F.emit('ret') if target == 'RET' else F.emit('j', target)
        return None
    if table_test(c) and getattr(F, 'l2', None):
        jump(F, gen_table_test(F, table_test(c)), target); return
    if c.k == 'un' and c.op == '!': return gen_cond_false(F, c.e, target)
    if c.k == 'bin' and c.op == '||':
        gen_cond_true(F, c.l, target); gen_cond_true(F, c.r, target); return
    if c.k == 'bin' and c.op == '&&':                # _isalpha: (c>='a' && c<='z') || ... -> j lt,L1 / j le,L2 / L1:
        lf = F.newulabel(); gen_cond_false(F, c.l, lf); gen_cond_true(F, c.r, target)
        F.lines.append(lf + ':'); return
    if not fpgen.is_fp(c.ty):
        bt = bit_cond(F, c)
        if bt is not None: jump(F, bt, target); return
    if c.k == 'bin' and c.op in CC_S and fpgen.is_fp(strip(c.l).ty):   # _exp: if (ret == old) break; -> ld DE,0x5 /
        fpgen.compare(F, c, False); F.emit('cp', 'HL,0x0'); jump(F, 'eq', target); return   # ... / j eq (the negation)
    if fpgen.is_fp(c.ty):
        fpgen.truth(F, c, False); F.emit('cp', 'HL,0x0'); jump(F, 'eq', target); return
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
    c = strip(c); target = ret_target(F, target)
    if F.pending and COND_FLUSH_POPS and not nodes_in(c, 'call') and not getattr(F, 'arg_bases', None):
        flush_pops(F)                                   # (r3_00_13: a ?: with pops pending from an earlier statement
    if FOLD_CONST_CMP and c.k == 'bin' and c.op in ('&&', '||'):   # released them in one arm only: wrong code)
        fl, fr = fold(c.l), fold(c.r)                   # r2_06_17: gca[a] & 0x7 || 39 < 3 -> the test of gca[a] alone
        if fr.k == 'const' and fr.value is not None:
            if c.op == '||': return None if fr.value else gen_cond_false(F, c.l, target)
            if not fr.value: gen_cond_false(F, c.l, target); F.emit('j', target); return None
            return gen_cond_false(F, c.l, target)
        if fl.k == 'const' and fl.value is not None:
            if c.op == '||': return None if fl.value else gen_cond_false(F, c.r, target)
            if not fl.value: F.emit('j', target); return None
            return gen_cond_false(F, c.r, target)
    if FOLD_CONST_CMP and c.k == 'bin' and c.op in ('<', '<=', '>', '>=', '==', '!=') and fold(c).k == 'const':
        if not fold(c).value: F.emit('ret') if target == 'RET' else F.emit('j', target)
        return None
    if table_test(c) and getattr(F, 'l2', None):
        cc = gen_table_test(F, table_test(c))
        F.emit('ret', INV[cc]) if target == 'RET' else F.emit('j', '%s,%s' % (INV[cc], target)); return None
    if c.k == 'un' and c.op == '!':
        gen_cond_true(F, c.e, target); return None
    if c.k == 'bin' and c.op == '&&':                # c_andbr: both operands jump to the false target
        gen_cond_false(F, c.l, target); gen_cond_false(F, c.r, target); return None
    if c.k == 'bin' and c.op == '||':                # c_orbr: first true -> then label; last false -> target
        lt = F.newulabel(); gen_cond_true(F, c.l, lt); gen_cond_false(F, c.r, target)
        F.lines.append(lt + ':'); return None
    if not fpgen.is_fp(c.ty):
        bt = bit_cond(F, c)                            # cond_bits.c: bit 0x7,(XSP+0x4) / j eq
        if bt is not None: jump(F, INV[bt], target); return None
    if c.k == 'bin' and c.op in CC_S and fpgen.is_fp(strip(c.l).ty):   # d_blt_gg: ld DE,0x2 (>=) / cal ._fcmp_d /
        fpgen.compare(F, c, False); F.emit('cp', 'HL,0x0'); jump(F, 'ne', target); return None   # cp HL,0x0 / j ne
    if fpgen.is_fp(c.ty):                              # d_if: ld BC,0x4 (==) / cal ._fcmp_zd
        fpgen.truth(F, c, False); F.emit('cp', 'HL,0x0'); jump(F, 'ne', target); return None
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
    raise Unsupported('condition ' + c.k + (' ' + c.op if c.k in ('bin', 'un') else ''))

def push_arg(F, a):
    """push one cdecl argument (call.c: k1, k1k, k3, k4; abi args_caller)"""
    a0 = strip(a); size = a0.ty.size
    if a0.ty.kind == 'struct':                       # abi structs.c s_pass_pair / s_pass_big: room on the stack, then
        src = strip(a0.e) if a0.k == 'load' else a0      # a block copy into it (two words: ldiw twice; more: ldirw)
        if not (src.k == 'var' and src.decl.kind == 'global'): raise Unsupported('struct argument')
        n = (size + 1) // 2 * 2
        F.emit('dec', '%s,XSP' % hx(n)) if n <= 8 else F.emit('lda', 'XSP,XSP-%s' % hx(n))
        F.emit('ld', 'XIY,_%s' % src.decl.name); F.emit('ld', 'XIX,XSP')
        if n // 2 <= 2:
            for _ in range(n // 2): F.emit('ldiw', '(XIX+),(XIY+)')
        else: F.emit('ld', 'BC,%s' % hx(n // 2)); F.emit('ldirw', '(XIX+),(XIY+)')
        F.push += n; return n
    if size == 1 and fold(a0).k == 'const' and fold(a0).value is not None and CHAR_CONST_PUSHW:
        F.emit('pushw', hx(fold(a0).value & 0xffff)); F.push += 2; return 2   # abi args_caller.c c_ci: t_c(5) ->
                                                                             # pushw 0x5
    if size == 1:                                    # a char parameter: sign-extended to a word (call.c: k4)
        m = mem_operand(F, a0)
        b0 = a0
        while b0.k == 'cast' and b0.kind == 'IntegralCast' and strip(b0.e).ty.size == 1: b0 = strip(b0.e)
        if m is None and b0.k == 'load' and strip(b0.e).k == 'deref':   # _fputs: *s++ with s in XIZ ->
            pv = strip(strip(b0.e).e)                                     # ld A,(XIZ+:1)
            if pv.k == 'incdec' and pv.post and strip(pv.e).k == 'var' and \
                    getattr(strip(pv.e).decl, 'reg', None) in ('XIZ', 'BC', 'DE', 'HL', 'IX', 'IY') and \
                    strip(pv.e).decl.ty.size == 4:
                d = strip(pv.e).decl; X = 'XIZ' if d.reg == 'XIZ' else FAM[d.reg][4]
                m = '(%s%s:%d)' % (X, '+' if pv.op == '++' else '-', d.ty.base.size)
            elif pv.k == 'incdec' and pv.post and strip(pv.e).k == 'var' and not getattr(strip(pv.e).decl, 'reg', None) \
                    and strip(pv.e).decl.ty.size == 4:
                sm = lvalue(F, strip(pv.e))                # _fwrite: *p++ with p in a slot -> ld XWA,(XSP+0x4) /
                if sm.startswith('(XSP'):                  # ld C,(XWA+:1) / ld (XSP+0x4),XWA / extz BC / push BC
                    F.emit('ld', 'XWA,%s' % sm)
                    F.emit('ld', 'C,(XWA%s:%d)' % ('+' if pv.op == '++' else '-', strip(pv.e).decl.ty.base.size))
                    F.emit('ld', '%s,XWA' % sm)
                    F.emit('exts' if a0.ty.signed else 'extz', 'BC'); F.emit('push', 'BC'); F.push += 2; return 2
        if m is None:                                # _fputc: (char)c of an int in IZ -> ld A,IZL / extz WA
            x = a0
            while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
            if x.k == 'load' and x.ty.size in (2, 4):
                if strip(x.e).k == 'var': touch_home(F, strip(x.e).decl)   # ld IZ,(XSP+0x6) first
                xm = reg_or_mem(F, x, x.ty.size)
                if xm is not None and xm.startswith('('): m = xm          # the low byte is at the same address
                elif xm in ('IX', 'IY', 'IZ', 'XIX', 'XIY', 'XIZ'): m = xm.lstrip('X') + 'L'
                elif xm is not None and family_of(xm): m = FAM[family_of(xm)[1:]][1]
        if m is None and CHAR_ARG_ANY and not F.opt and not F.adecl:   # random corpora: vc(gp[0]), vc((char)(gc - gca[2])),
            f_ = gen(F, a0, 'WA', 1)                                    # vc(rc(..)): the value into A (a call's result
            if f_ not in FAM or 1 not in FAM[f_]: raise Unsupported('complex char argument')   # from L), then exts WA /
            m = FAM[f_][1]                                              # push WA (r2_06_07: ld XWA,(_gp) / ld A,(XWA))
        if m is None: raise Unsupported('complex char argument')
        if m != 'A': F.emit('ld', 'A,%s' % m)
        F.emit('exts' if a0.ty.signed else 'extz', 'WA'); F.emit('push', 'WA')
        F.push += 2; return 2
    if a0.k == 'call':                               # a call result is pushed from HL (call.c: k_nest)
        gen_call(F, a0); F.emit('push', FAM['HL'][size] if size >= 2 else 'HL'); F.push += max(size, 2)
        return max(size, 2)
    if a0.k == 'cast' and a0.kind == 'IntegralCast' and strip(a0.e).ty.size == 1 and size == 2:
        m = mem_operand(F, a0.e)
        if m is None and CHAR_ARG_GEN and not F.opt:
            f_ = gen(F, a0.e, 'WA', 1)                      # r2_06_16: vc(gps->c); r2_06_07: vc(gp[0])
            if f_ != 'WA': raise Unsupported('complex char argument')
            m = 'A'
        if m is None: raise Unsupported('complex char argument')
        if m != 'A': F.emit('ld', 'A,%s' % m)
        F.emit('exts' if strip(a0.e).ty.signed else 'extz', 'WA'); F.emit('push', 'WA')
        F.push += 2; return 2
    if PUSH_ELEM and size == 2 and not F.opt and not F.adecl and a0.k == 'load' and strip(a0.e).k == 'index':
        pe = push_elem(F, strip(a0.e))                     # random corpora: v2(gi, gia[t]) -> ld WA,IZ / add WA,WA /
        if pe is not None:                                 # lda XBC,_gia / pushw (XBC+WA)
            F.emit('pushw', pe); F.push += 2; return 2
    sx = a0
    while sx.k in ('decay', 'cast') and getattr(sx, 'kind', 'ArrayToPointerDecay') in ('ArrayToPointerDecay', 'NoOp', 'BitCast',
                                                                                    'FunctionToPointerDecay'):
        sx = strip(sx.e)
    if sx.k == 'var' and sx.decl.kind == 'func' and a.ty is not None and a.ty.is_ptr():
        F.emit('pushw', '_%s >> 16' % sx.decl.name); F.emit('pushw', '_%s & 0xffff' % sx.decl.name)   # _sprintf:
        F.push += 4; return 4                                                     # pushw __strOut >> 16 / ...
    if sx.k == 'string' and a.ty is not None and a.ty.is_ptr():   # abi varargs.c v_call: pushw S1 >> 16 / pushw S1 & 0xffff
        lab = fpgen.string_label(F, sx.value)
        F.emit('pushw', '%s >> 16' % lab); F.emit('pushw', '%s & 0xffff' % lab); F.push += 4; return 4
    a1 = a0
    while a1.k == 'cast' and a1.kind == 'IntegralCast' and strip(a1.e).ty.size == size: a1 = strip(a1.e)
    if a1.k == 'un' and a1.op in ('-', '~') and size >= 2:
        x = strip(a1.e)
        ur = regvar_of(x.e) if x.k == 'load' else None
        if ur is not None and ur.reg in ('BC', 'DE') and dies_here(F, x) and F.opt:
            fam = gen(F, a1, ur.reg, size)              # _ltoa: cpl DE / cpl QDE / inc 0x1,XDE / push XDE
            F.emit('push', FAM[fam][size]); F.push += size; return size
    m = mem_operand(F, a1)
    if size <= 2 and m is not None and family_of(m):    # a register: push IZ (call.c k_seq under O3XS)
        F.emit('push', m if size == 2 else FAM[family_of(m)[1:]][2]); F.push += 2; return 2
    if size <= 2 and m is not None:
        F.emit('pushw', m); F.push += 2; return 2
    if size == 4 and m is not None and m in ('XIZ', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY'):
        F.emit('push', m); F.push += 4; return 4          # _calloc: push XIZ
    if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and size == 4 and a1.k == 'load' and strip(a1.e).k == 'var' and \
            getattr(strip(a1.e).decl, 'reg', None) == 'XIZ':
        F.emit('push', 'XIZ'); F.push += 4; return 4      # lo_p_Rca: push XIZ (not through XWA)
    if size == 4 and m is not None and m.startswith('('):
        X = 'X' + (getattr(F, 'arg_tmp', None) or 'WA')     # (adecl c_mix: XBC while A holds an argument)
        F.emit('ld', '%s,%s' % (X, m)); F.emit('push', X); F.push += 4; return 4
    if size == 4 and m is not None:
        F.emit('ld', 'XWA,%s' % m); F.emit('push', 'XWA'); F.push += 4; return 4
    if fpgen.is_fp(strip(a).ty): return fpgen.push_fp_arg(F, a, None)   # _atan2: _sign(y) with a double y, called
    F.any_fam = PUSH_ANY_FAM                                             # from an int-to-double conversion
    try: fam = gen(F, a, 'WA', size)
    finally: F.any_fam = False
    F.emit('push', FAM[fam][size]); F.push += size; return size

def call_arg_bytes(F, e):
    """the stack bytes a call statement's arguments take (a double 8, a pointer 4, else 2; a hidden result 4)"""
    e = strip(e)
    if e.k != 'call': return 0
    n = 0
    for a in e.args:
        t = strip(a).ty; n += 8 if fpgen.is_fp(t) and t.size == 8 else 4 if t is not None and t.size == 4 else 2
    rt = getattr(strip(e.fn).ty, 'ret', None) if strip(e.fn).ty is not None else None
    if rt is not None and fpgen.is_fp(rt) and rt.size == 8: n += 4
    return n

def args_begin(F):
    """a call's argument pushes start here: pending pops of earlier calls stay below them until the call is made"""
    F.arg_bases = getattr(F, 'arg_bases', []) + [(F.push, F.pending)]

def args_end(F):
    if getattr(F, 'arg_bases', None): F.arg_bases.pop()

def flush_pops(F, before_test=False):
    """release the stack arguments of earlier calls; more than 8 bytes is lda XSP,XSP+n, or add XSP,n when a test
    of the call's result follows (_strcpy: add XSP,0xc / or XHL,XHL; _strstr: add XSP,0xa)"""
    n = F.pending
    if ARGS_LIVE_NO_FLUSH and getattr(F, 'arg_bases', None) and F.push > F.arg_bases[-1][0]:
        bp, bq = F.arg_bases[-1]                       # fpp11.c q15: ldexp(f * 2.0, n / 2) after frexp(): push WA /
        if F.push - F.pending > bp - bq:               # ... cal ._fmul_d / ... cal _ldexp / lda XSP,XSP+0x1e: pops
            n = F.pending - bq                         # older than the pushed arguments wait under them (a release
            if n <= 0: return                          # between the pushes dropped the argument: wrong code); a call
    F.pending_calls = 0                                # made inside the argument list releases its own (_cos: cal
    if n:                                              # _fabs / lda XSP,XSP+0xc / ... cal ._fadd_d / push ...)
        if n <= 8: F.emit('inc', '%s,XSP' % hx(n))
        elif before_test: F.emit('add', 'XSP,%s' % hx(n))
        else: F.emit('lda', 'XSP,XSP+%s' % hx(n))
        F.push -= n; F.pending -= n

def gen_call(F, e, fam=None, size=0):
    fn = strip(e.fn)
    if fn.k == 'deref' and strip(fn.e).ty is not None and strip(fn.e).ty.is_ptr():
        fn = strip(fn.e)                               # _fputc: (*stream->out)(c) calls through the pointer itself
    if fn.k != 'var' and not F.adecl and fn.ty is not None and fn.ty.is_ptr():
        n = 0                                          # abi fptr.c fp_call: pushw (XSP+0x4) / ld XWA,(_gfp) /
        if not e.args and F.pending: flush_pops(F)     # call XWA / inc 0x2,XSP
        args_begin(F)
        for a in reversed(e.args): n += push_arg(F, a)
        pm = mem_operand(F, fn)
        if pm is None:                                 # _fputc: ld XWA,(XSP+0xa) / ld XWA,(XWA) / call XWA
            fr = gen(F, fn, 'WA', 4)
            if fr != 'WA': F.emit('ld', 'XWA,%s' % FAM[fr][4])
            pm = 'XWA'
        if pm != 'XWA': F.emit('ld', 'XWA,%s' % pm)
        F.emit('call', 'XWA'); args_end(F); F.pending += n
        if fam and fam != 'HL': F.emit('ld', '%s,%s' % (FAM[fam][size], FAM['HL'][size]))
        return fam
    if fn.k != 'var': raise Unsupported('indirect call')
    n = 0
    args = e.args
    if getattr(fn.decl, 'implicit', False):            # _ultoa: memcpy undeclared -> the long difference is pushed whole
        args = [strip(a.e) if strip(a).k == 'cast' and strip(a).kind == 'IntegralCast' and strip(a.e).ty.size > strip(a).ty.size
                else a for a in args]
    if F.adecl and not getattr(fn.decl.ty, 'cdecl', False):
        return gen_call_adecl(F, fn, args, fam, size)
    if not args and F.pending: flush_pops(F)           # h_p_only: cal _fp / inc 0x2,XSP / ld XIZ,XHL / cal _g0
    args_begin(F)
    for a in reversed(args): n += push_arg(F, a)
    F.emit('cal', '_' + fn.decl.name)                  # cdecl, also from an adecl file (adecl.c: c_lib)
    args_end(F); F.pending += n
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
        if fold(a0).k == 'const' and fold(a0).value is not None: return 'const'   # abi args_caller.c c_ci: t_c(5) ->
        if a0.ty.size == 1: return 'computed'                                        # ld WA,0x5
        if a0.k != 'load': return 'computed'
        m = mem_operand(F, a0)
        if m is None: return 'computed'
        return 'reg' if family_of(m) else 'mem'
    groups = {'reg': [], 'computed': [], 'mem': [], 'const': []}
    for t, a in inreg: groups[kind(a)].append((t, a))
    parked = []
    def in_wa(a):                                      # a * / % is computed in XWA whatever its target
        a0 = strip(a)
        while a0.k == 'cast' and a0.kind == 'IntegralCast': a0 = strip(a0.e)
        return a0.k == 'bin' and a0.op in ('*', '/', '%')
    if not F.opt and any(t == 'WA' for t, _ in groups['reg']):   # ls_cl, ls_cl_noguard under -Xr: ms(p, 0, n * s), p in
        busy = {t for t, _ in groups['reg']}             # XIZ -> ld WA,(n) / mul XWA,(s) / ld BC,WA / ld XWA,XIZ /
        for t, a in list(groups['computed']):            # ld DE,BC / ld BC,0x0: the product first, parked in the
            if t != 'WA' and in_wa(a) and strip(a).ty.size == 2:   # first free of BC, DE
                tmp = next((r for r in ('BC', 'DE') if r not in busy and r != t), None)
                if tmp is None: continue
                gen(F, strip(a), 'WA', 2); F.emit('ld', '%s,WA' % tmp)
                parked.append((t, tmp)); groups['computed'].remove((t, a)); busy.add(tmp)
    for t, a in groups['reg']:
        sz = strip(a).ty.size; m = mem_operand(F, strip(a))
        if m != FAM[t][sz]: F.emit('ld', '%s,%s' % (FAM[t][sz], m))
    for t, a in groups['computed']:
        a0 = strip(a)
        if a0.ty.size == 1:
            m = mem_operand(F, a0)
            if m is not None and m != FAM[t][1]: F.emit('ld', '%s,%s' % (FAM[t][1], m))
            elif m is None:
                f_ = gen(F, a0, t, 1)                    # (r1_06_19: the shifted value in C -> ld A,C / exts WA)
                if f_ != t: F.emit('ld', '%s,%s' % (FAM[t][1], FAM[f_][1]))
            F.emit('exts' if a0.ty.signed else 'extz', FAM[t][2])
        else:
            f_ = gen(F, a0, t, a0.ty.size)
            if f_ != t and f_ in FAM and a0.ty.size in FAM[f_] and f_ != 'HL' or (f_ == 'HL' and strip(a0).k != 'call' and f_ != t):
                F.emit('ld', '%s,%s' % (FAM[t][a0.ty.size], FAM[f_][a0.ty.size]))   # (r2_09_00: the difference in BC)
    for t, tmp in parked: F.emit('ld', '%s,%s' % (t, tmp))
    n = 0
    held = {t for t, _ in groups['reg']} | {t for t, _ in groups['computed']} | {t for t, _ in parked}
    if 'WA' in held and stack:                         # c_mix: c already in A -> the pointer goes through XBC
        F.arg_tmp = next((r for r in ('BC', 'DE', 'HL') if r not in held), None)
    args_begin(F)
    for a in stack: n += fpgen.push_fp_arg(F, a) if fpgen.is_fp(strip(a).ty) else push_arg(F, a)   # ac_di: a double
    F.arg_tmp = None                                   # through XIY / XIX; ac_iiif: a fourth float ld XWA,(_gf) / push
    def on_stack(a): return (mem_operand(F, strip(a)) or '').startswith('(XSP')
    if F.opt:                                          # -O: memory, then constants, then frame slots (adecl.c c_t2:
        order = [x for x in groups['mem'] if not on_stack(x[1])] + groups['const'] + \
                [x for x in groups['mem'] if on_stack(x[1])]   # ld BC,(_gi) / ld WA,0x1; ls_mc_n1: ld XWA,0x0 /
    else: order = groups['mem'] + groups['const']               # ld BC,0x0 / ld DE,(XSP+0x4))
    fslot = getattr(F, 'farg_slot', None); fwa = False   # probes/adfp.c ac_fi: a float in a register goes through a
    for k_, (t, a) in enumerate(order):                       # frame temporary: ld XWA,(_gf) / ld (XSP),XWA / ld BC,(_gi)
        sz = strip(a).ty.size                                # / ld XWA,(XSP) (XWA reloaded after later loads; ac_if,
        if fold(strip(a)).k == 'const':                      # ac_ifi: XBC is not)
            sz = max(2, sz); v = fold(strip(a)).value & ((1 << (8 * sz)) - 1)
            F.emit('ld', '%s,%s' % (FAM[t][sz], hx(v))); continue
        F.emit('ld', '%s,%s' % (FAM[t][sz], mem_operand(F, strip(a))))
        if fpgen.is_fp(strip(a).ty):
            if fslot is None: raise Unsupported('float argument temporary')
            F.emit('ld', '(XSP+%s),%s' % (hx(fslot + F.push), FAM[t][4]) if fslot + F.push else '(XSP),%s' % FAM[t][4])
            fwa = t == 'WA' and k_ < len(order) - 1
    if fwa: F.emit('ld', 'XWA,(XSP+%s)' % hx(fslot + F.push) if fslot + F.push else 'XWA,(XSP)')
    args_end(F)
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
    xv = strip(e.e)
    if regvar_of(xv): touch_home(F, regvar_of(xv))      # (r2_08_15: a-- on a parameter homed in IZ, loaded lazily)
    if not value and regvar_of(xv) and getattr(F, 'l2', None):
        d = regvar_of(xv); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        step = d.ty.base.size if d.ty.kind == 'ptr' else 1
        k = F.l2.setdefault('const', {})
        if d in k:                                       # _itoa: sign = 0 ... sign++ -> ld IX,0x1 (the value is known)
            v = k.pop(d) + (step if e.op == '++' else -step); F.emit('ld', '%s,%s' % (R, hx(v & 0xffff))); return None
        F.emit('inc' if e.op == '++' else 'dec', '%s,%s' % (hx(step), R)); return None
    if not value and xv.k == 'var' and getattr(xv.decl, 'reg', None) == 'XIZ' and xv.decl.ty.size == 4:
        step = xv.decl.ty.base.size if xv.decl.ty.kind == 'ptr' else 1    # _strstr: ++s1 with s1 in XIZ
        F.emit('inc' if e.op == '++' else 'dec', '%s,XIZ' % hx(step)); return None
    if g is None and strip(e.e).k == 'var' and hasattr(strip(e.e).decl, 'slot'):
        g = 'XSP+%s' % hx(strip(e.e).decl.slot + F.push)     # _ultoa: p-- -> ld XWA,0x1 / sub (XSP+4),XWA
    if g is None and strip(e.e).k == 'var' and strip(e.e).decl.kind == 'param' and hasattr(strip(e.e).decl, 'off') and \
            not getattr(strip(e.e).decl, 'reg', None):
        g = 'XSP+%s' % hx(strip(e.e).decl.off + F.push)      # r1_03_00: b++ on a stack parameter -> incb 0x1,(XSP+0x16)
    if g is None and strip(e.e).k == 'var' and strip(e.e).decl.kind == 'static' and getattr(strip(e.e).decl, 'init', None) is None:
        g = fpgen.static_label(F, strip(e.e).decl)            # gl_local_static: return ++n -> incw 0x1,(S3)
    if g is None and xv.k == 'index' and not value:
        op = chidx.element(F, xv, 'rmw')                 # chidx.c lc1: gca[c]++ -> lda XBC,_gca / ld XWA,0x0 / ld A,(c) /
        if op is not None: g = op[1:-1]                  # add XWA,XBC / incb 0x1,(XWA)
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

def u1_operand(F, v):
    """p[i] with p and i in registers after leaf_u1: (Xp+i) for chars, else the index chain in its register
    (ld DE,IX / exts XDE / add XDE,XDE / add XDE,XWA -> (XDE))"""
    if getattr(F, 'u1_i', None) is None or v.k != 'index': return None
    b = strip(v.base); ix = strip(v.idx)
    while ix.k == 'cast': ix = strip(ix.e)
    rl = getattr(F, 'u1_reload', {})
    pd = strip(b.e).decl if b.k == 'load' and strip(b.e).k == 'var' else None
    gp = pd is not None and v.ty.size > 1 and (pd.kind == 'global' or pd in getattr(F, 'u1_mem', ()))
    if not (b.k == 'load' and (regvar_of(b.e) or pd in rl or gp) and ix.k == 'load' and strip(ix.e).k == 'var'
            and strip(ix.e).decl is F.u1_i):
        return None
    I = FAM[F.u1_i.reg][2]
    if gp and getattr(F, 'u1_chain', None):              # ol_gptr: ld BC,DE / exts XBC / add XBC,XBC / add XBC,(_gp)
        T = F.u1_chain; XT = FAM[T][4]                   # O3XS oc_nested: ... / add XWA,(XSP+0x4)
        F.emit('ld', '%s,%s' % (FAM[T][2], I)); F.emit('exts', XT)
        if v.ty.size == 2: F.emit('add', '%s,%s' % (XT, XT))
        else: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[v.ty.size]), XT))
        F.emit('add', '%s,%s' % (XT, '(_%s)' % pd.name if pd.kind == 'global' else '(XSP+%s)' % hx(pd.off + F.push)))
        return '(%s)' % XT
    if gp: return None
    if pd in rl:                                         # cdecl: the pointer reloaded at its use
        P = FAM[rl[pd]][4]
        if v.ty.size == 1:
            F.emit('ld', '%s,(XSP+%s)' % (P, hx(pd.off + F.push))); return '(%s+%s)' % (P, I)
        T = getattr(F, 'u1_chain', None); XT = FAM[T][4]
        F.emit('ld', '%s,%s' % (FAM[T][2], I)); F.emit('exts', XT)
        if v.ty.size == 2: F.emit('add', '%s,%s' % (XT, XT))
        else: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[v.ty.size]), XT))
        F.emit('ld', '%s,(XSP+%s)' % (P, hx(pd.off + F.push))); F.emit('add', '%s,%s' % (XT, P)); return '(%s)' % XT
    P = FAM[regvar_of(b.e).reg][4]
    if v.ty.size == 1: return '(%s+%s)' % (P, I)
    T = getattr(F, 'u1_chain', None)
    if T is None: return None
    XT = FAM[T][4]
    F.emit('ld', '%s,%s' % (FAM[T][2], I)); F.emit('exts', XT)
    if v.ty.size == 2: F.emit('add', '%s,%s' % (XT, XT))
    else: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[v.ty.size]), XT))
    F.emit('add', '%s,%s' % (XT, P)); return '(%s)' % XT

def scale_reg(F, X, sz, shift):
    """multiply register X by the element size sz: add X,X for 2, `shift` n,X for 4 / 8 (mem.c)"""
    if sz == 2: F.emit('add', '%s,%s' % (X, X))
    elif sz in (4, 8, 16, 32, 64): F.emit(shift, '%s,%s' % (hx(sz.bit_length() - 1), X))
    elif sz != 1: raise Unsupported('element size %d' % sz)

def split_index(i):
    """an index i as (base, k): i = base + k with k a constant (k = 0 when there is none)"""
    x = strip(i)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == x.ty.size: x = strip(x.e)
    if x.k == 'bin' and x.op in ('+', '-') and fold(x.r).k == 'const' and fold(x.r).value is not None:
        return x.l, fold(x.r).value * (1 if x.op == '+' else -1)
    return i, 0

def is_plain_index(i):
    x = strip(i)
    while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
    return x.k == 'load' and strip(x.e).k == 'var'

def scale32(F, X, esz):
    if esz == 2: F.emit('add', '%s,%s' % (X, X))
    elif esz in (4, 8): F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[esz]), X))

def scale16(F, R, esz):
    if esz == 2: F.emit('add', '%s,%s' % (R, R))
    elif esz in (4, 8): F.emit('sla', '%s,%s' % (hx({4: 2, 8: 3}[esz]), R))

def elem_addr_regs(F, lv, b, esz, kind):
    """-Xr: an element whose index is a register parameter that dies here (arr_index_sz.c under -Xr): the index is
    adjusted and scaled in place (inc 0x1,WA / add WA,WA); a global's base is XBC for a load, a constant op or a
    compare, XDE for a store or + - & | ^ with a variable, lda XBC,XBC+WA for * / %; through a pointer in a
    register a char element is (XWA+BC), any other is exts XBC / add XBC,XBC / add XBC,XWA / (XBC)"""
    ib, k = split_index(lv.idx)
    x = strip(ib)
    while x.k == 'cast' and x.kind == 'IntegralCast' and strip(x.e).ty.size == 2 and x.ty.size >= 2: x = strip(x.e)
    pair = None                                            # ((unsigned char)ch narrows: ai_xdig_i needs its extz WA)
    if x.k == 'bin' and x.op == '+' and fold(x.r).k != 'const':
        a, c = unpromote(x.l), unpromote(x.r)
        av = regvar_of(a.e) if a.k == 'load' else None; cv = regvar_of(c.e) if c.k == 'load' else None
        if av is None or cv is None or not dies_here(F, a): return None
        pair = (av, cv); iv = av
    else:
        x = unpromote(x)
        iv = regvar_of(x.e) if x.k == 'load' else None
        if iv is None or iv.ty.size != 2 or iv.reg not in ('WA', 'BC', 'DE', 'HL') or not dies_here(F, x): return None
    if iv.kind != 'param' or F.loops: return None          # (a loop counter's last use is not its death: c_sum)
    R = FAM[iv.reg][2]
    def adjust(kk):
        if pair: F.emit('add', '%s,%s' % (R, FAM[pair[1].reg][2]))
        if kk: F.emit('inc' if kk > 0 else 'dec', '%s,%s' % (hx(abs(kk)), R)) if abs(kk) <= 8 else \
            F.emit('add', '%s,%s' % (R, hx(kk & 0xffff)))
        F.dead.add(iv)
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and not getattr(b.decl.ty, 'count', 0) \
            and esz > 1:
        if esz == 4 and kind in ('rmw', 'andk'): return None
        g = '_' + b.decl.name; X = FAM[iv.reg][4]          # arr_index.c under -Xr: exts XWA / add XWA,XWA /
        adjust(k); F.emit('exts', X); scale32(F, X, esz)   # ld XDE,_gsa / add XDE,XWA / (XDE)
        base = getattr(F, 'force_base', None) or ('XDE' if kind in ('store', 'add') else 'XBC')
        if base == X: return None
        F.emit('ld', '%s,%s' % (base, g)); F.emit('add', '%s,%s' % (base, X)); return '(%s)' % base
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and (getattr(b.decl.ty, 'count', 0) or esz == 1):
        g = '_' + b.decl.name
        if kind != 'rmw' and ('XDE' if kind in ('store', 'add') else 'XBC')[1:] == iv.reg and \
                not (esz == 4 and kind == 'andk' and iv.reg == 'WA' and not pair): return None   # (r2_03_03)
        if esz == 4 and kind == 'andk' and iv.reg == 'WA' and not pair:   # ai_l_g_and: the constant needs XWA ->
            F.emit('ld', 'BC,WA'); F.dead.add(iv)                         # ld BC,WA / sla 0x2,BC / lda XDE,_gla /
            if k: F.emit('inc' if k > 0 else 'dec', '%s,BC' % hx(abs(k)))  # (XDE+BC)
            scale16(F, 'BC', esz); F.emit('lda', 'XDE,%s' % g); return '(XDE+BC)'
        if esz == 4 and kind in ('rmw', 'andk'): return None
        if esz > 1 and not iv.ty.signed and kind == 'load' and not pair and UIDX32:
            X = FAM[iv.reg][4]; adjust(k); F.emit('extz', X); scale32(F, X, esz)   # r3_08_11 -Xr: an unsigned index
            base = 'XBC' if iv.reg != 'BC' else 'XDE'                             # extended whole: extz XWA /
            F.emit('ld', '%s,%s' % (base, g)); F.emit('add', '%s,%s' % (base, X))  # add XWA,XWA / ld XBC,_gia /
            return '(%s)' % base                                                  # add XBC,XWA / (XBC)
        if esz == 1:
            adjust(0)
            sym = g if not k else '%s + %s' % (g, hx(k & 0xffffffff))
        else:
            adjust(k); scale16(F, R, esz); sym = g
        if kind == 'rmw':                                  # .as_mul_arr: the operand in BC -> XDE
            P = 'XDE' if 'BC' in live_regs(F, except_decl=iv) else 'XBC'
            F.emit('lda', '%s,%s' % (P, sym)); F.emit('lda', '%s,%s+%s' % (P, P, R)); return '(%s)' % P
        base = 'XDE' if kind in ('store', 'add') else 'XBC'
        if base[1:] == iv.reg: return None
        F.emit('lda', '%s,%s' % (base, sym)); return '(%s+%s)' % (base, R)
    if b.k == 'load' and b.ty.is_ptr() and regvar_of(b.e) is not None and regvar_of(b.e).ty.size == 4:
        P = FAM[regvar_of(b.e).reg][4]
        if esz == 4 and kind == 'rmw': return None
        adjust(k)
        if dies_here(F, b): F.dead.add(regvar_of(b.e))    # ai_i_p_div: the value then takes WA
        if esz == 1 and kind in ('load', 'store', 'storek', 'add') and iv.ty.signed:
            return '(%s+%s)' % (P, R)                       # (an unsigned index: .m_cp_v extz XBC / (XBC))
        X = FAM[iv.reg][4]
        F.emit('exts' if iv.ty.signed else 'extz', X); scale32(F, X, esz)
        if getattr(F, 'force_base', None):                 # ai_l_p_div: ld XIZ,XBC / add XIZ,XWA
            B = F.force_base; F.emit('ld', '%s,%s' % (B, X)); F.emit('add', '%s,%s' % (B, P)); return '(%s)' % B
        F.emit('add', '%s,%s' % (X, P))
        return '(%s)' % X
    return None

def elem_addr(F, lv, kind):
    """the operand of array element lv for the forms of arr_index.c / arr_index_sz.c (runs 2026-11-09-24 / -25),
    or None (nothing emitted) for the plain forms the older paths write.  kind: 'load', 'store', 'add' (a + - & | ^
    compound with a variable), 'andk' (with a constant) or 'rmw' (* / % and the rest).
    - a global char array: an index i + k folds k into the symbol (lda XBC,_gca + 0x1 / (XBC+WA); a store
      ld BC,(i) / lda XDE,_gca + 0x1 / (XDE+BC)); a compound target lda XWA,_gca / ld BC,(i) / extz XBC /
      add XBC,XWA / (XBC);
    - a sized global array: a computed index stays 16-bit (inc 0x1,WA / add WA,WA / lda XBC,_gia / (XBC+WA); a
      store copies it to BC: ld BC,WA / add BC,BC / lda XDE,_gia / (XDE+BC)); a constant-mask compound
      (XBC+WA);
    - an incomplete global array: the index is sign-extended and scaled in XWA, the base an immediate
      (exts XWA / add XWA,XWA / ld XBC,_gia / add XBC,XWA / (XBC));
    - through a pointer: exts (extz for a char element) and scaled in XWA, added to the pointer: a load
      add XWA,(p) / (XWA); a store or compound ld XBC,XWA / add XBC,(p) / (XBC) (a char: ld BC,(i) / extz XBC)"""
    lv = strip(lv)
    if lv.k != 'index': return None
    b = strip(lv.base); esz = lv.ty.size
    while b.k in ('decay', 'cast', 'noop') and b.ty is not None and b.ty.is_ptr() and strip(getattr(b, 'e', b)) is not b \
            and strip(b.e).k == 'var' and strip(b.e).decl.ty.kind == 'array':
        b = strip(b.e)
    ic = fold(lv.idx)
    if ic.k == 'const': return None
    plain = is_plain_index(lv.idx)
    if F.adecl:
        r = elem_addr_regs(F, lv, b, esz, kind)
        if r is not None: return r
        if kind in ('load', 'cmp') and plain and b.k == 'load' and b.ty.is_ptr() and regvar_of(b.e) is not None and \
                regvar_of(b.e).ty.size == 4 and not (esz == 1 and kind == 'load'):
            iv = regvar_of(unpromote(lv.idx).e)              # ctrl.c c_sum / c_find under -Xr: the pointer in XWA,
            if iv is not None and iv.reg in FAM and iv.ty.size == 2:   # the counter live -> a free register:
                P = FAM[regvar_of(b.e).reg][4]               # ld DE,IX / exts XDE / add XDE,XDE / add XDE,XWA / (XDE)
                live = live_regs(F) | {regvar_of(b.e).reg, iv.reg}
                T = next((r for r in LEAF_SEQ if r in ('BC', 'DE', 'HL', 'IX', 'IY') and r not in live), None)
                if T is not None:
                    X = FAM[T][4]
                    F.emit('ld', '%s,%s' % (FAM[T][2], FAM[iv.reg][2]))
                    F.emit('exts' if iv.ty.signed else 'extz', X); scale32(F, X, esz); F.emit('add', '%s,%s' % (X, P))
                    return '(%s)' % X
    def idx_into(R):                                   # the index (16-bit) into register family R
        if IDX_GUARD and held_after(F, R, lv):           # (ol_two_arr -O3 -XS -Xr: the index over k in WA)
            raise Unsupported('index register holds a live variable')
        f = gen(F, narrow(lv.idx, 2), R, 2)
        if f != R: F.emit('ld', '%s,%s' % (FAM[R][2], FAM[f][2]))
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
        g = '_' + b.decl.name; sized = getattr(b.decl.ty, 'count', 0)
        ui = unpromote(lv.idx)
        if UIDX32 and ui.ty is not None and ui.ty.size == 2 and not ui.ty.signed and (plain and ui.k == 'load' or
                UIDX32_EXPR and ui.k == 'bin' and not has_helper_call(ui)) and \
                kind in ('load', 'store', 'storek', 'add', 'andk', 'cmp'):
            # random r1_08_00: an unsigned int index is zero-extended whole, as for an incomplete array:
            # ld WA,(i) / extz XWA / sll 0x2,XWA / ld XDE,_gula / add XDE,XWA / and (XDE),XWA; guca[a] ->
            # ld WA,(i) / extz XWA / ld XBC,_guca / add XBC,XWA / ld A,(XBC)
            uv_ = regvar_of(ui.e) if ui.k == 'load' else None
            if (F.opt or F.adecl) and not (ui.k == 'load' and (uv_ is None or uv_.reg in ('IZ', 'QIZ'))):
                raise Unsupported('unsigned index')        # (-O / -Xr: a register-parameter index's home lives on;
                                                           # an IZ home is copied out first: r1_01_15 O3XS ld WA,IZ /
                                                           # extz XWA / add XWA,XWA / ld XBC,_gua)
            idx_into('WA'); F.emit('extz', 'XWA'); scale32(F, 'XWA', esz)
            B = getattr(F, 'force_base', None) or ('XDE' if kind == 'add' else 'XBC')
            F.emit('ld', '%s,%s' % (B, g)); F.emit('add', '%s,XWA' % B); return '(%s)' % B
        if esz == 1:
            if kind == 'cmp': return None
            if kind in ('load', 'store', 'storek'):
                if kind == 'storek': kind = 'store'
                if plain: return None
                base_e, k = split_index(lv.idx)
                sym = g if not k else '%s + %s' % (g, hx(k & 0xffffffff))
                if kind == 'load':
                    ub_ = unpromote(base_e)
                    if ub_.ty is not None and ub_.ty.size == 1 and ub_.k == 'load' and strip(ub_.e).k == 'deref':
                        f = gen(F, ub_, 'WA', 1)           # _atof: _ctype[*str] -> ld A,(XDE) / extz WA (a char index
                        if f != 'WA': F.emit('ld', 'A,%s' % FAM[f][1])   # into a char array is zero-extended)
                        F.emit('extz', 'WA')
                    else:
                        f = gen(F, narrow(base_e, 2), 'WA', 2)
                        if f != 'WA': F.emit('ld', 'WA,%s' % FAM[f][2])
                    F.emit('lda', 'XBC,%s' % sym); return '(XBC+WA)'
                ub_ = unpromote(base_e)
                if ub_.ty is not None and ub_.ty.size == 1:
                    if not ub_.ty.signed or ub_.k != 'load' or mem_operand(F, ub_) is None: return None
                    F.emit('lda', 'XBC,%s' % sym); F.emit('ld', 'A,%s' % mem_operand(F, ub_))   # (r2_05_07 none)
                    F.emit('ld', 'XDE,0x0'); F.emit('ld', 'E,A'); F.emit('add', 'XDE,XBC'); return '(XDE)'
                f = gen(F, narrow(base_e, 2), 'BC', 2)
                if f != 'BC': F.emit('ld', 'BC,%s' % FAM[f][2])
                F.emit('lda', 'XDE,%s' % sym); return '(XDE+BC)'
            if not plain: return None
            if CHAR_REG_INDEX and not F.opt:                  # a register index is used as it is (idxloc.c il_c_L1:
                ix_ = strip(lv.idx)                            # lda XWA,_gca / ld A,(XWA+IZ); il_c_L2: lda XBC,_gca /
                while ix_.k == 'cast' and ix_.kind == 'IntegralCast': ix_ = strip(ix_.e)   # ld (XBC+IZ),A)
                iv_ = regvar_of(strip(ix_.e)) if ix_.k == 'load' else None
                if iv_ is not None and iv_.ty.size == 2 and iv_.ty.signed and iv_.reg in ('IZ', 'BC', 'DE', 'HL'):
                    B_ = 'XWA' if kind == 'load' else 'XBC'
                    if FAM.get(iv_.reg, {}).get(4) != B_ and B_[1:] not in live_regs(F):
                        touch_home(F, iv_); F.emit('lda', '%s,%s' % (B_, g)); return '(%s+%s)' % (B_, iv_.reg)
            F.emit('lda', 'XWA,%s' % g); idx_into('BC'); F.emit('extz', 'XBC'); F.emit('add', 'XBC,XWA'); return '(XBC)'
        if not sized:
            if kind == 'rmw' and esz == 4: return None
            if kind == 'cmp': return None
            wa_live = any(getattr(d, 'reg', None) == 'WA' and d not in F.dead for d in list(F.f.params) + list(F.f.decls))
            I = 'BC' if getattr(F, 'idx_avoid_wa', False) and wa_live else 'WA'   # (-Xr ai_us_g_sh: i stays in WA)
            idx_into(I); F.emit('exts', 'X' + I); scale32(F, 'X' + I, esz)
            B = getattr(F, 'force_base', None) or 'XBC'     # (ai_l_g_div: XIZ across the helper; ai_l_g_mul: XDE)
            if IDX_GUARD and B != 'XIZ' and (held_after(F, B[1:], lv) or any(
                    getattr(d, 'reg', None) == B[1:] and d not in F.dead and d in getattr(F, 'in_loop', ())
                    for d in list(F.f.params) + list(F.f.decls))):   # (arr_index.c ai_carry none: ld XDE,_gsa
                raise Unsupported('array base over a live register')   # over i in DE)
            F.emit('ld', '%s,%s' % (B, g)); F.emit('add', '%s,X%s' % (B, I)); return '(%s)' % B
        if (kind == 'load' and not plain) or kind == 'cmp':   # ai_mul10: cpw (XBC+WA),0x0
            idx_into('WA'); scale16(F, 'WA', esz); F.emit('lda', 'XBC,%s' % g); return '(XBC+WA)'
        if kind in ('store', 'storek') and not plain:
            if F.opt: idx_into('BC')                       # -O3 -XS: ld BC,(i) / inc 0x1,BC (no copy through WA)
            else: idx_into('WA'); F.emit('ld', 'BC,WA')
            scale16(F, 'BC', esz); F.emit('lda', 'XDE,%s' % g); return '(XDE+BC)'
        if kind == 'andk' and plain and esz == 2:
            idx_into('WA'); scale16(F, 'WA', esz); F.emit('lda', 'XBC,%s' % g); return '(XBC+WA)'
        return None
    if b.k == 'load' and b.ty.is_ptr():
        pm = mem_operand(F, b)
        if pm is None or not pm.startswith('(') or (kind == 'load' and plain and esz > 1) or kind == 'cmp': return None
        if kind == 'rmw' and esz == 4: return None
        ii = unpromote(lv.idx); im0 = mem_operand(F, ii) if ii.k == 'load' else None
        if PTR_INDEX_REG and esz == 1 and kind == 'load' and im0 in ('IZ', 'QIZ', 'IX', 'IY') and ii.ty.size == 2:
            F.emit('ld', 'XWA,%s' % pm); return '(XWA+%s)' % im0   # ra_homes.c rh_int_ptr: n in IZ -> ld XWA,(p) /
        if kind in ('load', 'storek'):                    # ai_clear: p[i] = 0 -> add XWA,(XSP+0x4) / ldw (XWA),0x0
            ii_ = unpromote(lv.idx)                         # (adecl: by the index's own sign; no -Xr listing zero-
            ext_ = 'exts' if ii_.ty is not None and ii_.ty.signed else 'extz'   # extends a signed one: ra_homes.c
            idx_into('WA'); F.emit(ext_ if F.adecl and esz == 1 else 'extz' if esz == 1 else 'exts', 'XWA')   # rh_ptr_int)
            scale32(F, 'XWA', esz)
            F.emit('add', 'XWA,%s' % pm); return '(XWA)'
        if IDX_GUARD and (held_after(F, 'BC', lv) or any(
                getattr(d, 'reg', None) == 'BC' and d not in F.dead and d in getattr(F, 'in_loop', ())
                for d in list(F.f.params) + list(F.f.decls))) and not getattr(F, 'force_base', None):
            raise Unsupported('pointer element address over a live BC')   # (oc_add2, ai_div10 none: i in BC)
        if esz == 1:
            if plain or F.opt: idx_into('BC')
            else: idx_into('WA'); F.emit('ld', 'BC,WA')
            F.emit('extz', 'XBC')
        elif getattr(F, 'force_base', None) and esz == 4:  # ai_l_p_div: ld WA,(i) / exts XWA / sll 0x2,XWA /
            B = F.force_base                               # ld XIZ,XWA / add XIZ,(p) (-O3 -XS too)
            idx_into('WA'); F.emit('exts', 'XWA'); scale32(F, 'XWA', esz); F.emit('ld', '%s,XWA' % B)
            F.emit('add', '%s,%s' % (B, pm)); return '(%s)' % B
        elif F.opt and plain:                              # ai_i_p_add under -O3 -XS: ld BC,(i) / exts XBC /
            idx_into('BC'); F.emit('exts', 'XBC'); scale32(F, 'XBC', esz)   # add XBC,XBC / add XBC,(p)
        else:
            B = getattr(F, 'force_base', None) or 'XBC'    # (lnr3.c s_add_gw: XDE, the value needs XBC)
            idx_into('WA'); F.emit('exts', 'XWA'); scale32(F, 'XWA', esz); F.emit('ld', '%s,XWA' % B)
            F.emit('add', '%s,%s' % (B, pm)); return '(%s)' % B
        F.emit('add', 'XBC,%s' % pm); return '(XBC)'
    return None

def gen_load_mem(F, v, fam, size):
    """load through an index, member or pointer (mem.c)"""
    R = FAM[fam][size]
    eo = getattr(F, 'elem_ops', None)
    if eo and id(v) in eo: F.emit('ld', '%s,%s' % (R, eo[id(v)])); return fam   # (shared_base_opassign)
    if v.k == 'member' and v.arrow:
        pm = mem_operand(F, v.base)
        if pm is None or pm == 'None': raise Unsupported('complex member base')
        off = member_offset(v)                     # cond_bits.c cb_mem_flag: offset 0 is ld WA,(XWA)
        F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,%s' % (R, '(XWA+%s)' % hx(off) if off else '(XWA)')); return fam
    if v.k == 'deref':
        pm = mem_operand(F, v.e)
        if pm is None: raise Unsupported('complex pointer')
        F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA)' % R); return fam
    if v.k == 'index' and getattr(F, 'u1x', None) and id(v) in F.u1x['acc']:
        if F.u1x.get('wide') and v.ty.size == 4 and size == 2: R = FAM[fam][4]   # plain -Xr ol_l_copy: ld XBC,(XDE+BC)
        F.emit('ld', '%s,%s' % (R, u1x_op(F, v))); return fam
    if v.k == 'index' and getattr(F, 'cl_active', None) and F.cl_active.get('u1') and cl_op(F, v.base):
        if F.cl_active.get('copy_wide') and v.ty.size == 4 and size == 2: R = FAM[fam][4]   # ol_l_copy: ld XBC,(XIX+DE)
        F.emit('ld', '%s,%s' % (R, cl_op(F, v.base))); return fam  # ol_idx_use: ld BC,(XIX+DE) / muls XBC,IY
    if v.k == 'index':
        ci = chidx.element(F, v, 'load', fam)              # a char index (probes/chidx.c): rc2 ld A,(c) / add A,(c) /
        if ci is not None: F.emit('ld', '%s,%s' % (R, ci)); return fam   # lda XBC,_gia / ld HL,(XBC+A)
        ea = elem_addr(F, v, 'load')
        if ea is not None: F.emit('ld', '%s,%s' % (R, ea)); return fam
        b = strip(v.base); i = v.idx; esz = v.ty.size
        ic = fold(i)
        if b.k == 'load' and ic.k == 'const':                      # p[k]: m_p_k
            pm = mem_operand(F, b)
            if getattr(F, 'u1_i', None) is not None and pm in ('XBC', 'XDE', 'XHL', 'XIX', 'XIY'):
                F.emit('ld', '%s,%s' % (R, '(%s+%s)' % (pm, hx(ic.value * esz)) if ic.value else '(%s)' % pm))
                return fam                                 # cdecl oc_max: ld XDE,(XSP+0x4) / ld HL,(XDE)
            F.emit('ld', 'XWA,%s' % pm)                    # oc_max: m = p[0] -> ld HL,(XWA)
            F.emit('ld', '%s,%s' % (R, '(XWA+%s)' % hx(ic.value * esz) if ic.value else '(XWA)')); return fam
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            ii = strip(i); im = mem_operand(F, ii)
            uc = ii
            while uc.k == 'cast' and uc.kind == 'IntegralCast' and uc.ty.size >= 2: uc = strip(uc.e)
            if im is None and esz == 1 and uc.k == 'cast' and uc.ty.size == 1 and not uc.ty.signed:
                x = strip(uc.e); xm = mem_operand(F, x)    # ai_xdig: gtab[(unsigned char)ch] -> ld A,(XSP+0x4) /
                if xm is not None and x.ty.size in (1, 2):  # extz WA / lda XBC,_gtab / ld A,(XBC+WA)
                    W = FAM['WA'][x.ty.size]
                    if xm != W: F.emit('ld', '%s,%s' % (W, xm))
                    F.emit('extz', 'WA'); F.emit('lda', 'XBC,_%s' % b.decl.name)
                    F.emit('ld', '%s,(XBC+WA)' % R); return fam
            if im is None: raise Unsupported('complex index')
            if esz == 1 and (im in ('WA', 'BC', 'DE', 'HL') or CHAR_REG_INDEX and im == 'IZ' and not F.opt and
                             unpromote(i).ty is not None and unpromote(i).ty.signed):   # globals.c (an unsigned index
                                                           #  in IZ is extended whole: r2_00_12 -Xr, r4_07_10)
                                                                   # (idxloc.c il_c_L1: lda XWA,_gca / ld A,(XWA+IZ))
                base = 'XBC' if im == 'WA' else 'XWA'
                F.emit('lda', '%s,_%s' % (base, b.decl.name)); F.emit('ld', '%s,(%s+%s)' % (R, base, im)); return fam
            if esz == 1:                                           # m_gca_v
                F.emit('lda', 'XWA,_%s' % b.decl.name); F.emit('ld', 'BC,%s' % im); F.emit('extz', 'XBC')
                F.emit('add', 'XBC,XWA'); F.emit('ld', '%s,(XBC)' % R); return fam
            if STORE_GLOBAL_FREE and fam in ('BC', 'DE', 'HL') and held_after(F, 'WA', v) and \
                    not reads_reg(i, fam):                 # lnr.c r_ga_rd (-Xr): k in WA -> ld BC,IZ / add BC,BC /
                B = next((x for x in ('DE', 'HL', 'IX', 'IY') if x != fam and not held_after(F, x, v)), None)
                if B is None: raise Unsupported('index register holds a live variable')   # lda XDE,_ga /
                F.emit('ld', '%s,%s' % (fam, im))                                         # ld BC,(XDE+BC)
                F.emit('add', '%s,%s' % (fam, fam)) if esz == 2 else F.emit('sla', '%s,%s' % (hx({4: 2, 8: 3}[esz]), fam))
                F.emit('lda', 'X%s,_%s' % (B, b.decl.name)); F.emit('ld', '%s,(X%s+%s)' % (R, B, fam)); return fam
            if IDX_GUARD and (held_after(F, 'WA', v) or held_after(F, 'BC', v)) and fam not in ('WA', 'BC'):
                raise Unsupported('index register holds a live variable')   # (ol_two_arr -O3 -XS -Xr: k in WA)
            if STORE_ADDR_GUARD and held_after(F, 'WA', v):
                raise Unsupported('index register holds a live variable')   # (r_ga_rd -Xr: wrong code)
            F.emit('ld', 'WA,%s' % im)                             # m_ga_v, m_gla_v
            F.emit('add', 'WA,WA') if esz == 2 else F.emit('sla', '%s,WA' % hx({4: 2, 8: 3}[esz]))
            B_ = 'XDE' if 'XBC' in getattr(F, 'sp_busy', ()) else 'XBC'   # (store_plan st_i_DX: the pointer in XBC)
            F.emit('lda', '%s,_%s' % (B_, b.decl.name)); F.emit('ld', '%s,(%s+WA)' % (R, B_)); return fam
        if b.k == 'member' and b.arrow and b.ty.kind == 'array' and ic.k == 'const' and ic.value is not None:
            pm = mem_operand(F, b.base)                    # cond_bits.c cb_mem_b: p->b[3] -> ld A,(XWA+0xb)
            if pm is not None:
                off = member_offset(b) + ic.value * esz
                if pm != 'XWA': F.emit('ld', 'XWA,%s' % pm)
                F.emit('ld', '%s,%s' % (R, '(XWA+%s)' % hx(off) if off else '(XWA)')); return fam
        if b.k == 'member' and b.arrow and b.ty.kind == 'array':
            # m_gps_a: gps->a[k] -> ld WA,(k) / add WA,WA / add WA,0xc / ld C,A / ld XWA,(_gps) / ld HL,(XWA+C):
            # cc900 indexes the member array with the low byte of the scaled offset (every option set)
            pm = mem_operand(F, b.base); ii = strip(i)
            while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
            im = mem_operand(F, ii)
            if pm is not None and im is not None and pm.startswith('(') and esz in (1, 2, 4, 8):
                load_index16(F, ii, im)                    # (random r1_03_19: a->a[b] with an unsigned char b ->
                scale_reg(F, 'WA', esz, 'sla')             # ld A,(XSP+0x8) / extz WA, not a word load)
                off = member_offset(b)
                if off: F.emit('add', 'WA,%s' % hx(off))
                F.emit('ld', 'C,A'); F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,(XWA+C)' % R); return fam
        if b.k == 'index' and b.ty.kind == 'array' and strip(b.base).k == 'load' and \
                strip(strip(b.base).e).k == 'var' and strip(strip(b.base).e).decl.kind == 'param':
            # m_2d: a[i][j] through int (*a)[4]: the column term first, then the row term, the sum, the pointer
            d = strip(strip(b.base).e).decl
            pm = FAM[d.reg][4] if getattr(d, 'reg', None) else '(XSP+%s)' % hx(d.off + F.push)
            row = b.ty.size
            def term(x, sz, dflt):
                x = strip(x)
                while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
                xv = regvar_of(x.e) if x.k == 'load' else None
                if xv is not None and xv.reg in ('BC', 'DE', 'HL') and dies_here(F, x) and x.ty.size == 2:
                    X = FAM[xv.reg][4]; F.dead.add(xv)               # -Xr: exts XDE / add XDE,XDE
                    F.emit('exts' if x.ty.signed else 'extz', X)
                else:
                    xm = mem_operand(F, x)
                    if xm is None: raise Unsupported('complex 2-d index')
                    if F.opt or dflt == 'WA':                         # -O3 -XS: ld BC,(j) / exts XBC
                        X = FAM[dflt][4]; F.emit('ld', '%s,%s' % (FAM[dflt][2], xm))
                        F.emit('exts' if x.ty.signed else 'extz', X)
                    else:                                             # none: ld WA,(j) / exts XWA / ld XBC,XWA
                        F.emit('ld', 'WA,%s' % xm); F.emit('exts' if x.ty.signed else 'extz', 'XWA')
                        X = FAM[dflt][4]; F.emit('ld', '%s,XWA' % X)
                scale_reg(F, X, sz, 'sll')
                return X
            J = term(i, esz, 'BC'); I = term(b.idx, row, 'WA' if J != 'XWA' else 'BC')
            F.emit('add', '%s,%s' % (I, J)); F.emit('add', '%s,%s' % (I, pm)); F.emit('ld', '%s,(%s)' % (R, I))
            return fam
        u1 = u1_operand(F, v)
        if u1 is not None: F.emit('ld', '%s,%s' % (R, u1)); return fam
        bb = strip(b)
        while bb.k == 'cast': bb = strip(bb.e)
        if bb.k == 'opassign' and bb.op in '+-' and regvar_of(bb.l) and fold(bb.r).k == 'const' and fold(i).k == 'const':
            d = regvar_of(bb.l); X = FAM[d.reg][4]                 # Toshiba's va_arg: ((int *)(ap += 2))[-1] ->
            step = fold(bb.r).value                                # inc 0x2,XBC / ld WA,(XBC-0x2)
            F.emit('inc' if bb.op == '+' else 'dec', '%s,%s' % (hx(step), X))
            off = fold(i).value * esz
            F.emit('ld', '%s,(%s%s%s)' % (R, X, '+' if off >= 0 else '-', hx(abs(off))) if off else '%s,(%s)' % (R, X))
            return fam
        if b.k == 'load':                                          # p[i]: m_p_v, m_lp_v, m_cp_v
            pm = mem_operand(F, b); ii = strip(i)
            while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
            im = mem_operand(F, ii)
            if pm is None or im is None: raise Unsupported('complex pointer index')
            iv = regvar_of(ii.e) if ii.k == 'load' else None
            W = 'XWA'
            if iv is not None and iv.reg in ('BC', 'DE', 'HL') and dies_here(F, ii) and ii.ty.size == 2:
                W = FAM[iv.reg][4]; F.dead.add(iv)          # m_p_v under -Xr, O3XSXr: exts XBC / add XBC,XBC / add XBC,XWA /
            else: F.emit('ld', 'WA,%s' % im)                # ld HL,(XBC)
            F.emit('exts' if ii.ty.signed else 'extz', W)
            if esz == 2: F.emit('add', '%s,%s' % (W, W))
            elif esz > 2: F.emit('sll', '%s,%s' % (hx({4: 2, 8: 3}[esz]), W))
            F.emit('add', '%s,%s' % (W, pm)); F.emit('ld', '%s,(%s)' % (R, W)); return fam
    raise Unsupported('memory load ' + v.k)

def member_cse(F):
    """cdecl -O: a function whose pointer parameter p is used only through its members, one member m of which is
    read and written again: (p, m's offset) -- V4.23 keeps p in XDE and &p->m in XBC for the whole function
    (_fgetc: if (stream->flag & __UNGETC) { stream->flag &= ~__UNGETC; return stream->unget; } else return
    (*stream->in)(); -> ld XDE,(XSP+0x4) / lda XBC,XDE+0xa / ld WA,(XBC) / bit 0x2,WA / ... / andw (XBC),0xfffb /
    ld HL,(XDE+0x8) / ... / ld XWA,(XDE+0x4) / call XWA)"""
    f = F.f
    ps = [d for d in f.params if d.ty.is_ptr() and d.ty.base is not None and d.ty.base.kind == 'struct' and
          not getattr(d, 'reg', None) and hasattr(d, 'off')]
    if len(ps) != 1: return None
    p = ps[0]
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do', 'switch') else None)
    if loops: return None
    uses = []; members = {}
    def v(n, d):
        if n.k == 'member' and n.arrow and strip(n.base).k == 'load' and strip(strip(n.base).e).k == 'var' and \
                strip(strip(n.base).e).decl is p:
            members.setdefault(member_offset(n), []).append(n)
        elif n.k == 'var' and n.decl is p: uses.append(n)
    walk(f.body, v)
    if len(uses) != sum(len(x) for x in members.values()) or not members: return None
    twice = [(off, ns) for off, ns in members.items() if len(ns) >= 2]
    if len(twice) != 1: return None
    off, ns = twice[0]
    stores = []
    walk(f.body, lambda n, d: stores.append(n) if (n.k == 'opassign' or n.k == 'bin' and n.op == '=') and
         strip(n.l) in ns else None)
    if not stores or len(stores) == len(ns): return None    # a read and a write of it (not stores only: member_run)
    return p, off

def member_run(body, i):
    """cdecl -O: two or more statements from body[i] storing through members of one memory parameter p
    (`p->f = v;`, `p->f op= k;`) with no call: (p, length, any non-constant value, the next statement returns a
    stored parameter) or None.  The pointer is loaded once (_fassign: ld XBC,(XSP+0x4) / ldw (XBC+0xa),0x0 /
    ld XWA,(XSP+0x8) / ld (XBC+0x4),XWA ...; _ungetc: ld XWA,(XSP+0x6) / ld HL,(XSP+0x4) / ld (XWA+0x8),HL /
    orw (XWA+0xa),0x4 / ret)"""
    p = None; n = 0; nonconst = False; vals = []
    for c in body[i:]:
        if c.k != 'expr': break
        e = c.e
        if not ((e.k == 'bin' and e.op == '=') or (e.k == 'opassign' and e.op in SIMPLE_OPS and fold(e.r).k == 'const')):
            break
        lv = strip(e.l)
        if not (lv.k == 'member' and lv.arrow and strip(lv.base).k == 'load' and strip(strip(lv.base).e).k == 'var'):
            break
        d = strip(strip(lv.base).e).decl
        if d.kind != 'param' or getattr(d, 'reg', None) or not hasattr(d, 'off') or (p is not None and d is not p): break
        calls = []
        walk(e.r, lambda m, dep: calls.append(m) if m.k in ('call', 'incdec', 'opassign') or (m.k == 'bin' and m.op == '=') else None)
        if calls or fpgen.is_fp(lv.ty) or lv.ty.kind == 'struct' or uses_decl(e.r, d): break
        p = d; n += 1
        if e.k == 'bin' and fold(e.r).k != 'const': nonconst = True; vals.append(strip(e.r))
    if n < 2: return None
    nxt = body[i + n] if i + n < len(body) else None
    rv = None
    if nxt is not None and nxt.k == 'return' and nxt.value is not None:
        x = strip(nxt.value)
        if x.k == 'load' and strip(x.e).k == 'var' and any(v.k == 'load' and strip(v.e).k == 'var' and
                                                          strip(v.e).decl is strip(x.e).decl for v in vals):
            rv = strip(x.e).decl
    return p, n, nonconst, rv is not None

def lvalue(F, lv, ptr='XBC', idx='BC', base='XDE', combine=False, kind='store'):
    """set up the address of lvalue lv and return its operand string (assign.c): a global or parameter is a direct
    operand; *p loads p into `ptr`; a[i] of a global array scales i in `idx` and puts the array in `base`
    (`(base+idx)`), or with combine=True adds them into `ptr` (`(ptr)`)"""
    lv = strip(lv)
    if PTR_STORE_FREE and F.adecl and ptr == 'XBC' and kind == 'storev' and 'BC' in live_regs(F) and \
            lv.k == 'member' and lv.arrow and strip(lv.base).k == 'load' and strip(strip(lv.base).e).k == 'var' and \
            strip(strip(lv.base).e).decl.kind == 'global':
        try: ptr = FAM[free_reg(F, avoid={'WA', 'BC'})][4]   # r2_06_02 (-O3 -XS -Xr): gps->c = .. with b in BC -> XHL
        except Unsupported: pass                           # (ot_cpy_*: every family taken: the old XBC)
    eo = getattr(F, 'elem_ops', None)
    if eo and id(lv) in eo: return eo[id(lv)]           # (gen_counted's pointer loop, shared_base_opassign)
    u1 = u1_operand(F, lv) if getattr(F, 'u1_i', None) is not None else None
    if u1 is not None: return u1                         # oc_cpy_abn: ld (XWA+IX),C; oc_clr_i: ldw (XDE),0x0
    if lv.k == 'index' and getattr(F, 'u1x', None) and id(lv) in F.u1x['acc']: return u1x_op(F, lv)
    if lv.k == 'index' and not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None):
        ck = {'storek': 'storek', 'storev': 'store', 'add': 'store', 'andk': 'rmwk', 'rmw': 'rmw', 'store': 'rmw'}.get(kind, 'store')
        ci = chidx.element(F, lv, 'rmw' if combine else ck)   # a char index (probes/chidx.c): sc2 ldw (XBC+A),0x1
        if ci is not None: return ci
    if lv.k == 'index' and not getattr(F, 'l2', None) and not getattr(F, 'cl_active', None) and \
            not (ptr == 'XBC' and idx == 'BC' and base == 'XDE' and not combine and kind == 'store' and False):
        ea = elem_addr(F, lv, 'rmw' if combine else ('store' if kind == 'storev' else kind))   # arr_index.c
        if ea is not None: return ea
    if lv.k == 'deref' and getattr(F, 'l2', None) and F.l2.get('ivmap'):
        pv = strip(lv.e)                                 # _strrev: *p = ... through the copy p' (XBC), the last
        if pv.k == 'load' and strip(pv.e).k == 'var' and strip(pv.e).decl in F.l2['ivmap']:   # one post-incremented
            X = 'X' + F.l2['ivmap'][strip(pv.e).decl]
            return '(%s+:%d)' % (X, strip(pv.e).decl.ty.base.size) if id(lv) in F.l2.get('ivpost', ()) else '(%s)' % X
    if lv.k == 'deref':
        pv = strip(lv.e)                                 # _itoa: *--p = '-' -> ldb (-XIY:1),0x2d
        if pv.k == 'incdec' and not pv.post and pv.op == '--' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4:
            d = regvar_of(pv.e); return '(-%s:%d)' % (FAM[d.reg][4], d.ty.base.size)
        if pv.k == 'load' and strip(pv.e).k == 'var' and regvar_of(pv.e) and regvar_of(pv.e).ty.size == 4 and \
                getattr(F, 'l2', None):                  # _itoa: *p = ... -> (XIY)
            return '(%s)' % FAM[regvar_of(pv.e).reg][4]
    if lv.k == 'index' and getattr(F, 'l2', None) and local_array_of(lv.base) in F.l2.get('arr', {}) and \
            fold(lv.idx).k == 'const':                   # _itoa: buf[17] = 0 with buf in XIZ -> (XIZ+0x11)
        ar = local_array_of(lv.base); l2_array_base(F, ar)
        off = fold(lv.idx).value * lv.ty.size; R = 'X' + F.l2['arr'][ar]
        return '(%s+%s)' % (R, hx(off)) if off else '(%s)' % R
    if lv.k == 'index' and local_array_of(lv.base) is not None and fold(lv.idx).k == 'const' and \
            local_array_of(lv.base) in getattr(F, 'array_temps', {}):
        array_base(F, local_array_of(lv.base))          # _ultoa: buf[32] = 0 -> (XWA+0x20)
        off = fold(lv.idx).value * lv.ty.size
        return '(XWA+%s)' % hx(off) if off else '(XWA)'
    if lv.k == 'deref' and strip(lv.e).k == 'load' and strip(strip(lv.e).e).k == 'var' and \
            hasattr(strip(strip(lv.e).e).decl, 'slot') and getattr(F, 'naive_loads', False):
        F.emit('ld', 'XWA,(XSP+%s)' % hx(strip(strip(lv.e).e).decl.slot + F.push)); return '(XWA)'
    if getattr(F, 'cl_active', None) and lv.k == 'index' and cl_op(F, lv.base):
        return cl_op(F, lv.base)                             # ol_i_clear: ldw (XBC+WA),0x0
    if lv.k == 'var':
        d = lv.decl
        if d.kind == 'global': return '(_%s)' % d.name
        if d.kind == 'static' and getattr(d, 'init', None) is None: return '(%s)' % fpgen.static_label(F, d)
        if d.kind == 'param':
            if not hasattr(d, 'off'): raise Unsupported('register parameter as an lvalue')   # (r4_01_09 -Xr: *c++ = ..)
            return '(XSP+%s)' % hx(d.off + F.push)
        if d.kind == 'local' and hasattr(d, 'slot'): return '(XSP+%s)' % hx(d.slot + F.push)
    if lv.k == 'deref' and strip(lv.e).k == 'incdec' and strip(lv.e).post and strip(strip(lv.e).e).k == 'var' and \
            strip(strip(lv.e).e).decl.kind in ('param', 'local') and strip(strip(lv.e).e).decl.ty.is_ptr() and \
            not getattr(strip(strip(lv.e).e).decl, 'reg', None):
        pv = strip(lv.e); g = strip(pv.e).decl; P = ptr if ptr != 'XWA' else 'XBC'   # ctrl.c c_clear: *p++ = 0 ->
        sl = lvalue(F, strip(pv.e))                        # ld XBC,(XSP+0x4) / ld XWA,0x1 / add (XSP+0x4),XWA /
        F.emit('ld', '%s,%s' % (P, sl)); F.emit('ld', 'XWA,%s' % hx(g.ty.base.size))   # ldb (XBC),0x0
        F.emit('add' if pv.op == '++' else 'sub', '%s,XWA' % sl)
        return '(%s)' % P
    if lv.k == 'deref' and strip(lv.e).k == 'incdec' and strip(lv.e).post and strip(strip(lv.e).e).k == 'var' and \
            strip(strip(lv.e).e).decl.kind == 'global' and strip(strip(lv.e).e).decl.ty.is_ptr():
        pv = strip(lv.e); g = strip(pv.e).decl          # __strOut: *_str++ = c -> ld XBC,(__str) / ld XWA,0x1 /
        P = 'XBC' if ptr == 'XWA' else ptr                 # add (__str),XWA / ... / ld (XBC),A  (the step takes XWA:
        F.emit('ld', '%s,(_%s)' % (P, g.name))             # random r1_07_13 *gpi++ = 100 -> ld XBC,(_gpi) / ldw (XBC),0x64)
        F.emit('ld', 'XWA,%s' % hx(g.ty.base.size)); F.emit('add' if pv.op == '++' else 'sub', '(_%s),XWA' % g.name)
        return '(%s)' % P
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
        bv = strip(lv.base); pc = getattr(F, 'ptr_cache', None) or {}
        if bv.k == 'load' and strip(bv.e).k == 'var' and strip(bv.e).decl in pc:
            P = pc[strip(bv.e).decl]; off = member_offset(lv)   # _fassign: stream once in XBC for three stores
            mc_ = getattr(F, 'member_cache', None) or {}
            if (strip(bv.e).decl, off) in mc_: return mc_[(strip(bv.e).decl, off)]   # _fgetc: andw (XBC),0xfffb
            return '(%s+%s)' % (P, hx(off)) if off else '(%s)' % P
        m = mem_operand(F, lv.base)
        if m is None: raise Unsupported('complex member base')
        F.emit('ld', '%s,%s' % (ptr, m)); off = member_offset(lv)
        return '(%s+%s)' % (ptr, hx(off)) if off else '(%s)' % ptr
    g = global_offset(lv)
    if g and g[0] == '__param__': return '(XSP+%s)' % hx(g[1].off + g[2] + F.push)   # a member of a struct parameter
    if g: return '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0]
    if lv.k == 'index' and fold(lv.idx).k == 'const' and fold(lv.idx).value is not None:
        bb = strip(lv.base)                              # _frexp: d.n[3] = ... -> (XSP+0x6), as mem_operand reads it
        if bb.k == 'member' and not bb.arrow and strip(bb.base).k == 'var' and strip(bb.base).decl.kind == 'local' \
                and getattr(strip(bb.base).decl, 'slot', None) is not None:
            t = strip(bb.base).decl.slot + F.push + member_offset(bb) + fold(lv.idx).value * lv.ty.size
            return '(XSP+%s)' % hx(t) if t else '(XSP+0x0~)'
    if lv.k == 'index' and strip(lv.base).k == 'load' and fold(lv.idx).k == 'const':
        m = mem_operand(F, lv.base)                      # _ultoa: ld XWA,(s) / ldb (XWA),0x0 (a constant stored: ptr
                                                         # XWA); a computed value: XBC (random r1_03_04: gpi[1] = ~gi ->
                                                         # ld XBC,(_gpi) / ld WA,(_gi) / cpl WA / ld (XBC+0x2),WA)
        if m is not None:
            P_ = ptr if ptr != 'XBC' else ('XBC' if kind == 'storev' and PK_STORE_XBC else 'XWA')
            if m.startswith('('): F.emit('ld', '%s,%s' % (P_, m)); m = P_
            off = fold(lv.idx).value * lv.ty.size
            return '(%s+%s)' % (m, hx(off)) if off else '(%s)' % m
    if lv.k == 'index':
        b, i = strip(lv.base), lv.idx
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            esz = lv.ty.size; im = mem_operand(F, i)
            if im is None: raise Unsupported('complex index')
            ui_ = unpromote(i)
            if ui_.ty is not None and ui_.ty.size == 1 and ui_.k == 'load' and not family_of(im):
                # a char index in memory: the word load of it read its neighbour (r2_05_07 none: guca[a] with a char
                # parameter a -> lda XBC,_guca / ld A,(XSP+0xa) / ld XDE,0x0 / ld E,A / add XDE,XBC / ld (XDE),A)
                if esz == 1 and ui_.ty.signed and not combine and mem_operand(F, ui_) is not None:
                    F.emit('lda', 'XBC,_%s' % b.decl.name); F.emit('ld', 'A,%s' % mem_operand(F, ui_))
                    F.emit('ld', 'XDE,0x0'); F.emit('ld', 'E,A'); F.emit('add', 'XDE,XBC'); return '(XDE)'
                raise Unsupported('a char index in memory')
            I = idx if not combine else 'WA'
            if im in ('WA', 'BC', 'DE') and dies_here(F, i):   # .as_add_arr: add WA,WA / (XDE+WA)
                I = im
                idx = im
            elif im == I and family_of(im):                # the index variable's own register, still needed:
                busy = live_regs(F) | {ptr[1:]}            # scale a copy (ra_while under -O3 -XS -Xr: n in WA ->
                I2 = next((x for x in ('BC', 'DE', 'HL') if x not in busy), None)   # ld BC,WA / add BC,BC /
                if I2 is None:                             # lda XDE,_ga / ldw (XDE+BC),0x0; the scaling in place
                    raise Unsupported('index register')    # was wrong code)
                F.emit('ld', '%s,%s' % (I2, im)); I = idx = I2
                if base[1:] == I2 or base == 'XBC' and I2 == 'BC': base = 'XDE' if I2 != 'DE' else 'XHL'
            elif im != I: F.emit('ld', '%s,%s' % (I, im))
            if IDX_GUARD and not combine and (held_after(F, base[1:], lv) or any(
                    getattr(d, 'reg', None) == base[1:] and d not in F.dead and d in getattr(F, 'in_loop', ())
                    for d in list(F.f.params) + list(F.f.decls))):   # opt_loops.c ol_i_copy (none): lda XDE,_gb
                raise Unsupported('array base over a live register')   # over i in DE (wrong code)
            if esz == 2: F.emit('add', '%s,%s' % (I, I))
            elif esz == 4: F.emit('sla', '0x2,%s' % I)
            if combine:
                F.emit('lda', '%s,_%s' % (ptr, b.decl.name)); F.emit('lda', '%s,%s+%s' % (ptr, ptr, I))
                d_i = regvar_of(strip(i).e) if strip(i).k == 'load' else None
                if d_i is not None and I == FAM[d_i.reg][2]: F.dead.add(d_i)
                return '(%s)' % ptr
            F.emit('lda', '%s,_%s' % (base, b.decl.name)); return '(%s+%s)' % (base, idx)
    raise Unsupported('lvalue ' + lv.k)

def combine_indexed(F, t, D):
    """a sized array's (XR+WA) operand made one address in D (arr_index_sz.c ai_l_g_mul / _div, every set):
    the lda XR,_g just emitted becomes lda XBC,_g / lda D,XBC+WA"""
    m = re.match(r'^\((X\w+)\+(WA|DE|HL)\)$', t)
    if not m or not F.lines or not F.lines[-1].startswith('\tlda\t%s,' % m.group(1)): return t
    sym = F.lines[-1].split(',', 1)[1]
    F.lines[-1] = '\tlda\tXBC,%s' % sym; F.emit('lda', '%s,XBC+%s' % (D, m.group(2)))
    return '(%s)' % D

def sized_pair_noopt(F, lv, r, heavy, size, op):
    """no -O, g a sized global array: g[i + k] op= f(g[i]) (arr_index_sz.c ai_*_g_sh): the target's index in DE
    and its base in XHL, the source as any element read.  none: ld WA,(i) / dec 0x1,WA / ld DE,WA / sla 0x2,DE /
    lda XHL,_gla / ld WA,(i) / sla 0x2,WA / lda XBC,_gla / ld XWA,(XBC+WA) / sra 0x8,XWA / add (XHL+DE),XWA;
    -Xr with i in WA: ld BC,WA / dec 0x1,BC / ld DE,BC / ...  True when written."""
    g = strip(lv.base).decl; esz = lv.ty.size
    if len(heavy) != 1 or not getattr(g.ty, 'count', 0) or esz == 1 or not SHARED_BASE: return False
    src = strip(heavy[0].e)
    if src.k != 'index' or strip(src.base).k != 'var' or strip(src.base).decl is not g: return False
    bd, k = split_index(lv.idx); bs, k2 = split_index(src.idx)
    bd, bs = unpromote(bd), unpromote(bs)
    if k2 != 0 or k == 0 or bd.k != 'load' or bs.k != 'load' or strip(bd.e).k != 'var' or strip(bs.e).k != 'var' or \
            strip(bd.e).decl is not strip(bs.e).decl or strip(bd.e).decl.ty.size != 2: return False
    iv = strip(bd.e).decl; ir = getattr(iv, 'reg', None)
    if ir is not None and ir != 'WA': return False
    T = 'BC' if ir else 'WA'
    keep = ir is None and esz == 2                       # none, 16-bit elements: i loaded once into BC and reused
    if ir: F.emit('ld', 'BC,WA')                         # (ld BC,(i) / ld WA,BC / dec 0x1,WA / ... / ld WA,BC /
    elif keep: F.emit('ld', 'BC,%s' % mem_operand(F, bd)); F.emit('ld', 'WA,BC')   # add WA,WA); a long element
    else: F.emit('ld', 'WA,%s' % mem_operand(F, bd))     # reloads it (ai_l_g_sh: two ld WA,(i)) -- as observed
    F.emit('inc' if k > 0 else 'dec', '%s,%s' % (hx(abs(k)), T)) if abs(k) <= 8 else F.emit('add', '%s,%s' % (T, hx(k & 0xffff)))
    F.emit('ld', 'DE,%s' % T); scale16(F, 'DE', esz); F.emit('lda', 'XHL,_%s' % g.name)
    if keep:
        F.emit('ld', 'WA,BC'); scale16(F, 'WA', esz)
        eo0 = getattr(F, 'elem_ops', None) or {}; F.elem_ops = dict(eo0); F.elem_ops[id(src)] = '(XBC+WA)'
        F.lines.append('\tlda\tXBC,_%s' % g.name)
        try: f2 = gen(F, r, 'WA', size)
        finally: F.elem_ops = eo0
        F.emit(SIMPLE_OPS[op], '(XHL+DE),%s' % FAM[f2][size]); return True
    f2 = gen(F, r, 'WA', size)
    F.emit(SIMPLE_OPS[op], '(XHL+DE),%s' % FAM[f2][size]); return True

def shared_base_opassign(F, e, lv, r, heavy, size, op):
    """-O: g[i + k] op= f(g[i]) with g a global array of unknown size (arr_index.c ai_*_g_sh): the index copied
    and adjusted in DE, the base loaded once and copied for the target, the source added to it.
    -O3 -XS (i in memory): ld BC,(i) / ld DE,BC / dec 0x1,DE / exts XDE / add XDE,XDE / lda XWA,_gia /
    ld XHL,XWA / add XHL,XDE / exts XBC / add XBC,XBC / add XWA,XBC / ld WA,(XWA) / sra 0x8,WA / add (XHL),WA;
    -O3 -XS -Xr (i in WA) the same with I = WA, base XBC.  A char array keeps 16-bit indexes and one base:
    ld DE,WA / dec 0x1,DE / lda XBC,_gca / ld A,(XBC+WA) / sra 0x8,A / add (XBC+DE),A.  True when written."""
    if len(heavy) != 1 or not SHARED_BASE: return False
    if strip(lv.base).k == 'load': return pointer_pair_opassign(F, e, lv, r, heavy, size, op)
    g = strip(lv.base).decl
    if g.ty.kind != 'array': return False
    sized = bool(getattr(g.ty, 'count', 0))
    src = strip(heavy[0].e)
    if src.k != 'index' or strip(src.base).k != 'var' or strip(src.base).decl is not g: return False
    bd, k = split_index(lv.idx); bs, k2 = split_index(src.idx)
    bd, bs = unpromote(bd), unpromote(bs)
    if k2 != 0 or k == 0 or bd.k != 'load' or bs.k != 'load' or strip(bd.e).k != 'var' or strip(bs.e).k != 'var' or \
            strip(bd.e).decl is not strip(bs.e).decl: return False
    iv = strip(bd.e).decl
    if iv.ty.size != 2: return False
    esz = lv.ty.size
    ir = getattr(iv, 'reg', None)
    if ir is not None and ir != 'WA': return False
    if ir is None:
        I = 'WA' if esz == 1 else 'BC'
        F.emit('ld', '%s,%s' % (I, mem_operand(F, bd)))
    else: I = 'WA'
    B = 'XBC' if I == 'WA' else 'XWA'
    F.emit('ld', 'DE,%s' % I)
    F.emit('inc' if k > 0 else 'dec', '%s,DE' % hx(abs(k))) if abs(k) <= 8 else F.emit('add', 'DE,%s' % hx(k & 0xffff))
    V = 'WA'
    if sized and esz > 1:                              # arr_index_sz.c: 16-bit indexes and one base: ld DE,WA /
        scale16(F, 'DE', esz); F.emit('lda', '%s,_%s' % (B, g.name))   # dec 0x1,DE / add DE,DE / lda XBC,_gia /
        scale16(F, I, esz); t = '(%s+DE)' % B; so = '(%s+%s)' % (B, I)   # add WA,WA / ld WA,(XBC+WA) / ... /
        V = 'BC' if B == 'XWA' else 'WA'                 # add (XBC+DE),WA (-O3 -XS, base XWA: the value in BC)
    elif esz == 1:
        F.emit('lda', '%s,_%s' % (B, g.name)); t = '(%s+DE)' % B; so = '(%s+%s)' % (B, I)
    else:
        F.emit('exts', 'XDE'); scale32(F, 'XDE', esz)
        F.emit('lda', '%s,_%s' % (B, g.name)); F.emit('ld', 'XHL,%s' % B); F.emit('add', 'XHL,XDE')
        F.emit('exts', 'X' + I); scale32(F, 'X' + I, esz); F.emit('add', '%s,X%s' % (B, I))
        t = '(XHL)'; so = '(%s)' % B
    if ir is not None: F.dead.add(iv)
    eo0 = getattr(F, 'elem_ops', None) or {}; F.elem_ops = dict(eo0); F.elem_ops[id(src)] = so
    try: f2 = gen(F, r, V, size)
    finally: F.elem_ops = eo0
    F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM[f2][size]))
    return True

SHARED_BASE = True

def pointer_pair_opassign(F, e, lv, r, heavy, size, op):
    """-O: p[i + k] op= f(p[i]) (arr_index.c ai_*_p_carry).  -O3 -XS -Xr, p in XWA and i in BC: ld DE,BC /
    inc 0x1,DE / exts XDE / add XDE,XDE / add XDE,XWA / exts XBC / add XBC,XBC / add XBC,XWA / ld WA,(XBC) / ... /
    add (XDE),WA.  -O3 -XS: ld BC,(i) / ld WA,BC / inc 0x1,WA / exts XWA / add XWA,XWA / ld XHL,(p) / ld XDE,XWA /
    add XDE,XHL / exts XBC / add XBC,XBC / add XBC,XHL / ld WA,(XBC) / ... / add (XDE),WA.  When the right side
    calls a helper (a long %), the target goes to XIZ (push XIZ; -O3 -XS: p in XDE) and the value comes in XHL:
    cal C9H_remls / sla 0x8,XHL / add (XIZ),XHL.  True when written."""
    pb = strip(strip(lv.base).e); src = strip(heavy[0].e)
    if pb.k != 'var' or pb.decl.kind != 'param' or not pb.decl.ty.is_ptr(): return False
    if src.k != 'index' or strip(src.base).k != 'load' or strip(strip(src.base).e).k != 'var' or \
            strip(strip(src.base).e).decl is not pb.decl: return False
    bd, k = split_index(lv.idx); bs, k2 = split_index(src.idx)
    bd, bs = unpromote(bd), unpromote(bs)
    if k2 != 0 or k == 0 or bd.k != 'load' or bs.k != 'load' or strip(bd.e).k != 'var' or strip(bs.e).k != 'var' or \
            strip(bd.e).decl is not strip(bs.e).decl: return False
    iv = strip(bd.e).decl; pv = pb.decl; esz = lv.ty.size
    if iv.ty.size != 2 or esz == 1: return False
    ldm = []
    walk(r, lambda n, d: ldm.append(n) if n.k == 'bin' and n.op in ('/', '%') and n.ty is not None and n.ty.size == 4 else None)
    helper = has_helper_call(r) or bool(ldm)              # (a long % 10 is C9H_remls)
    if helper and (F.xiz_vars or len(F.lines) != 1): return False
    regs = getattr(pv, 'reg', None), getattr(iv, 'reg', None)
    if regs != ('WA', 'BC') and regs != (None, None): return False
    def adj(R):
        F.emit('inc' if k > 0 else 'dec', '%s,%s' % (hx(abs(k)), R)) if abs(k) <= 8 else F.emit('add', '%s,%s' % (R, hx(k & 0xffff)))
    if helper:
        F.lines.insert(1, '\tpush\tXIZ'); F.push += 4; F.pushes.append('XIZ')
    if regs == ('WA', 'BC'):
        F.emit('ld', 'DE,BC'); adj('DE'); F.emit('exts', 'XDE'); scale32(F, 'XDE', esz)
        if helper: F.emit('ld', 'XIZ,XDE'); F.emit('add', 'XIZ,XWA'); t = '(XIZ)'
        else: F.emit('add', 'XDE,XWA'); t = '(XDE)'
        F.emit('exts', 'XBC'); scale32(F, 'XBC', esz); F.emit('add', 'XBC,XWA')
        F.dead.add(iv); F.dead.add(pv)
    else:
        F.emit('ld', 'BC,%s' % mem_operand(F, bd)); F.emit('ld', 'WA,BC'); adj('WA')
        F.emit('exts', 'XWA'); scale32(F, 'XWA', esz)
        PB = 'XDE' if helper else 'XHL'; D = 'XIZ' if helper else 'XDE'
        F.emit('ld', '%s,%s' % (PB, mem_operand(F, strip(lv.base)))); F.emit('ld', '%s,XWA' % D)
        F.emit('add', '%s,%s' % (D, PB)); t = '(%s)' % D
        F.emit('exts', 'XBC'); scale32(F, 'XBC', esz); F.emit('add', 'XBC,%s' % PB)
    eo0 = getattr(F, 'elem_ops', None) or {}; F.elem_ops = dict(eo0); F.elem_ops[id(src)] = '(XBC)'
    try: f2 = gen(F, r, 'HL' if helper and size == 4 else 'WA', size)
    finally: F.elem_ops = eo0
    F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM[f2][size]))
    return True

def gen_opassign(F, e):
    """x op= y as a statement (assign.c)"""
    size = strip(e.l).ty.size; op = e.op
    r = narrow(e.r, size)
    signed = strip(e.l).ty.signed
    if op in SIMPLE_OPS and fold(r).k == 'const' and size <= 2 and (getattr(F, 'naive_loads', False) or
                                                                    getattr(F, 'l2', None) or
                                                                    getattr(F, 'ptr_cache', None)):   # _itoa: addb (XIY),0x27
                                                                    # (_ungetc: orw (XWA+0xa),0x4)
        t = lvalue(F, e.l)                                # _ultoa: *p += 39 -> addb (XWA),0x27
        F.emit(SIMPLE_OPS[op] + ('b' if size == 1 else 'w'), '%s,%s' % (t, imm_of(fold(r), size))); return t
    if op in SIMPLE_OPS and OPB_GLOBAL and fold(r).k == 'const' and fold(r).value is not None and size == 1 and \
            strip(e.l).k == 'var' and strip(e.l).decl.kind == 'global' and not getattr(strip(e.l).decl, 'reg', None):
        t = lvalue(F, e.l)                                 # random r1_03_19: gc |= ~'A' -> orb (_gc),0xbe
        F.emit(SIMPLE_OPS[op] + 'b', '%s,%s' % (t, hx(fold(r).value & 0xff))); return t
    if op in SIMPLE_OPS and OPASSIGN_CALL_HL and strip(r).k == 'call' and not has_helper_call(strip(r).fn) and \
            size in (2, 4) and not fpgen.is_fp(strip(e.l).ty) and regvar_of(getattr(strip(e.l), 'e', strip(e.l))) is None \
            and strip(e.l).k == 'var':
        gen_call(F, strip(r)); flush_pops(F)               # homes2b.c HL05: b ^= g1(a) -> cal _g1 / inc 0x4,XSP /
        t = lvalue(F, e.l)                                 # xor (XSP+0x4),HL (the slot after the pops, the result as
        F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM['HL'][size])); return t   # it is)
    if op in SIMPLE_OPS:
        rk = fold(r).k == 'const' and fold(r).value is not None
        heavy = []                                         # the right side reads memory through an address
        walk(r, lambda n, d: heavy.append(n) if n.k == 'load' and (strip(n.e).k == 'deref' or strip(n.e).k == 'index'
             and not (fold(strip(n.e).idx).k == 'const' and strip(strip(n.e).base).k == 'var')) else None)
        lvg = strip(e.l)
        if id(lvg) in (getattr(F, 'elem_ops', None) or {}): heavy = []   # (a loop operand already: gen_counted)
        gdst = lvg.k == 'index' and strip(lvg.base).k == 'var' and strip(lvg.base).decl.kind == 'global'
        if heavy and F.opt and lvg.k == 'index' and not gdst and not getattr(F, 'l2', None) and \
                not getattr(F, 'u1_i', None) and not getattr(F, 'cl_active', None) and \
                shared_base_opassign(F, e, lvg, r, heavy, size, op): return None      # p[i + 1] += f(p[i])
        if heavy and gdst and not getattr(F, 'l2', None) and \
                not getattr(F, 'u1_i', None) and not getattr(F, 'cl_active', None):
            if F.opt:
                if shared_base_opassign(F, e, lvg, r, heavy, size, op): return None
                raise Unsupported('element op= element (-O shares the base)')   # (other shapes)
            if sized_pair_noopt(F, lvg, r, heavy, size, op): return None
            F.force_base = 'XDE'                           # ai_i_g_sh, no -O: the target's address in XDE first
            F.idx_avoid_wa = True                          # (-Xr: ld BC,WA / dec 0x1,BC / ... / ld XDE,_gsa /
            try: t = lvalue(F, e.l, kind='add')            # add XDE,XBC), then the right side through XBC /
            finally: F.force_base = None; F.idx_avoid_wa = False   # ld WA,(XBC) / sra 0x8,WA / add (XDE),WA
            used = set(re.findall(r'X?(WA|BC|DE|HL|IX|IY)', t))
            if used - {'DE'} or not t.startswith('(X'): raise Unsupported('element op= element: target operand')
            gen(F, r, 'WA', size); F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM['WA'][size])); return t
        pde = PTR_ELEM_XDE and heavy and not F.opt and not F.adecl and lvg.k == 'index' and not gdst and \
            strip(lvg.base).k == 'load' and strip(lvg.base).ty.is_ptr() and fold(lvg.idx).k != 'const' and \
            lvg.ty.size == 2
        if pde:                                            # (only when the right side reads a global array's element
            ga_ = []                                       # through XBC: ai_i_p_carry keeps XBC)
            walk(r, lambda n, d: ga_.append(n) if n.k == 'index' and fold(n.idx).k != 'const' and
                 strip(n.base).k in ('var', 'decay') and getattr(strip(strip(n.base).e) if strip(n.base).k == 'decay'
                                                             else strip(n.base), 'decl', None) is not None and
                 (strip(strip(n.base).e) if strip(n.base).k == 'decay' else strip(n.base)).decl.kind == 'global'
                 else None)
            cands = ('DE', 'HL', 'IX', 'IY') if ga_ else ('BC', 'DE', 'HL', 'IX', 'IY')
            pde = next(('X' + x for x in cands if not held_after(F, x, e)), None)   # (the first free one: lnr4.c
            if pde == 'XBC': pde = None                    # h17 XIX; lnr.c r_p_acc, d3 in BC: XDE)
        if pde: F.force_base = pde                         # lnr3.c s_add_gw (none): p[i] += gw[i] -> ld XDE,XWA /
        try: t = lvalue(F, e.l, kind='andk' if rk else 'add')   # add XDE,(p) / ... ld XBC,_gw / ... / add (XDE),WA
        finally:
            if pde: F.force_base = None
        if rk and size <= 2 and strip(e.l).k == 'index':  # arr_index_sz.c ai_i_g_and: andw (XBC+WA),0xff
            kv = fold(r).value
            if op in '+-' and 1 <= abs(kv) <= 8 and INC_ELEM:   # chidx.c kc2: gia[c] += 3 -> incw 0x3,(XBC+A)
                F.emit(('inc' if (op == '+') == (kv > 0) else 'dec') + ('b' if size == 1 else 'w'), '%s,%s' % (hx(abs(kv)), t))
                return t
            F.emit(SIMPLE_OPS[op] + ('b' if size == 1 else 'w'), '%s,%s' % (t, imm_of(fold(r), size) if fold(r).k == 'const' else hx(kv & 0xffff))); return t
        rv = mem_operand(F, r)
        if rv in ('A', 'C', 'E', 'WA', 'BC', 'DE', 'HL', 'XWA', 'XBC', 'XDE'):
            F.emit(SIMPLE_OPS[op], '%s,%s' % (t, rv)); return t        # .as_add_ptr: add (XWA),BC
        rw = strip(r)
        if F.opt and size == 2 and rw.k == 'cast' and rw.kind == 'IntegralCast' and strip(rw.e).k == 'load' and \
                strip(rw.e).ty.size == 1 and regvar_of(strip(rw.e).e) is not None and dies_here(F, strip(rw.e)) and \
                regvar_of(strip(rw.e).e).reg in ('WA', 'BC', 'DE', 'HL') and FAM[regvar_of(strip(rw.e).e).reg][2] not in t:
            cv = regvar_of(strip(rw.e).e); W = FAM[cv.reg][2]   # ae_c_loop (-O3 -XS -Xr): n += c, c dying in C ->
            F.emit('exts' if strip(rw.e).ty.signed else 'extz', W); F.dead.add(cv)   # exts BC / add HL,BC
            F.emit(SIMPLE_OPS[op], '%s,%s' % (t, W)); return t
        T = getattr(F, 'tfam', 'WA')                        # ot_add_anb: ld E,(XHL+:1) / add (XWA+:1),E
        if STORE_GLOBAL_FREE and T in FAM and held_after(F, T, e):   # lnr3.c s_add_g (-Xr): p in XWA -> not WA
            used_ = set(re.findall(r'X?(WA|BC|DE|HL|IX|IY)', t))
            T = next((x for x in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY') if x not in used_ and not held_after(F, x, e)), None)
            if T is None: raise Unsupported('no free register for the op= value')
        rc = fold(r)
        if F.opt and size == 4 and rc.k == 'const' and rc.value is not None and 0 <= rc.value < 0x10000:
            F.emit('lda', '%s,%s' % (FAM[T][4], hx(rc.value)))   # ai_l_g_and under -O3 -XS: lda XWA,0xff
        else:
            n0 = len(F.lines); T_ = gen(F, r, T, size)
            if STORE_ADDR_GUARD and clobbers(F.lines[n0:], t):
                raise Unsupported('the right side overwrites the op= address')   # (wrong code otherwise)
            if T_ in FAM and T_ != T: T = T_               # lnr2.c p_body3 (-Xr): n + n + n ends in DE, n in WA
        F.emit(SIMPLE_OPS[op], '%s,%s' % (t, FAM[T][size])); return t
    if op in ('<<', '>>'):
        mnem = ('sla' if signed else 'sll') if op == '<<' else ('sra' if signed else 'srl')
        lvg = strip(e.l)
        if fold(r).k == 'const' and fold(r).value == 1 and size <= 2 and lvg.k == 'var' and lvg.decl.kind == 'global':
            F.emit(mnem + ('b' if size == 1 else 'w'), '(_%s)' % lvg.decl.name)   # cb_while_g: gi <<= 1 -> slaw (_gi)
            return '(_%s)' % lvg.decl.name
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
        t = lvalue(F, e.l, ptr='XDE', idx='DE', base='XHL', kind='rmw')
        V = FAM[next((x for x in ('BC', 'WA', 'DE', 'HL') if not re.search(r'\b(X?%s|%s)\b' % (x, FAM[x][1]), t)), 'BC')][size]
        rr = fold(r); cs = mem_operand(F, r) if rr.k != 'const' else None
        pre = rr.k != 'const' and cs is None and SHIFT_COUNT_EXPR
        if pre:                                            # random r1_03_04: gul >>= (t & 15): the count computed
            n0 = len(F.lines); cf = gen_shift_count(F, r)   # into A before the value is loaded
            if cf != 'WA' or clobbers(F.lines[n0:], t): raise Unsupported('complex shift count')
        F.emit('ld', '%s,%s' % (V, t))
        if rr.k == 'const':
            emit_shift(F, mnem, rr.value, V)
        else:
            if cs is None and not pre: raise Unsupported('complex shift count')
            if not pre: F.emit('ld', '%s,%s' % (FAM['WA'][strip(r).ty.size], cs))
            if size == 4:
                lab16 = F.newlabel(); F.emit('bit', '0x4,A'); F.emit('j', 'z,%s' % lab16)
                F.emit(mnem, '0x0,%s' % V); F.lines.append(lab16 + ':')
            F.emit('and', 'A,0xf'); lab = F.newlabel(); F.emit('j', 'z,%s' % lab); F.emit(mnem, 'A,%s' % V)
            F.lines.append(lab + ':')
        F.emit('ld', '%s,%s' % (t, V)); return t
    if op in ('*', '/', '%'):
        rk = fold(r)
        if size == 4 and op == '*' and rk.k == 'const' and rk.value is not None and rk.value > 0 and \
                bin(rk.value).count('1') <= 3 and strip(e.l).k in ('index', 'deref') and LONG_RMW_XIZ:
            F.force_base = 'XDE'
            try: t = lvalue(F, e.l, idx='WA')              # arr_index.c ai_l_g_mul: gla[i] *= 10 inline, no helper:
            finally: F.force_base = None
            t = combine_indexed(F, t, 'XDE')
            if re.search(r'X?(WA|BC|HL|IX|IY)\b', t) or 'XDE' not in t:   # ld XWA,(XDE) /
                raise Unsupported('long element multiply address')
            F.emit('ld', 'XWA,%s' % t); F.emit('ld', 'XBC,XWA')                    # ld XBC,XWA / sla 0x2,XWA /
            bits = bin(rk.value)[3:]; run = 0                                      # add XWA,XBC / add XWA,XWA /
            for b_ in bits:                                                        # ld (XDE),XWA
                run += 1
                if b_ == '1': F.emit('sla' if signed else 'sll', '%s,XWA' % hx(run)); F.emit('add', 'XWA,XBC'); run = 0
            if run == 1: F.emit('add', 'XWA,XWA')
            elif run > 1: F.emit('sla' if signed else 'sll', '%s,XWA' % hx(run))
            F.emit('ld', '%s,XWA' % t); return t
        if size == 4:
            lvx = strip(e.l); held = False
            if LONG_RMW_XIZ and lvx.k in ('index', 'deref') and not F.xiz_vars and len(F.lines) == 1:
                F.lines.insert(1, '\tpush\tXIZ'); F.push += 4; F.pushes.append('XIZ'); held = True
                F.force_base = 'XIZ'                       # arr_index.c ai_l_g_div (-O3 -XS -Xr): the element's
            try: t = lvalue(F, e.l, idx='WA')              # address lives across the helper in XIZ: push XIZ /
            finally: F.force_base = None                   # ... / ld XIZ,_gla / add XIZ,XWA / ld XWA,(XIZ) /
            if held: t = combine_indexed(F, t, 'XIZ')
            if re.search(r'\(X(WA|BC|DE|HL|IX|IY)', t) or (held and 'XIZ' not in t):   # lda XBC,0xa / cal C9H_divls /
                raise Unsupported('long element address across a helper')        # ld (XIZ),XHL / pop XIZ
            rs = mem_operand(F, r)
            if rs is None: raise Unsupported('complex long operand')
            if F.opt and fold(r).k == 'const' and fold(r).value is not None and 0 <= fold(r).value < 0x10000:
                rs = None                                  # (lda XBC,0xa under -O, as gen_long_helper)
            name = {'*': 'mul', '/': 'div', '%': 'rem'}[op] + ('ls' if signed else 'lu')
            saved = False
            if rs is None:
                F.emit('ld', 'XWA,%s' % t); F.emit('lda', 'XBC,%s' % hx(fold(r).value)); F.emit('cal', 'C9H_' + name)
                F.emit('ld', '%s,XHL' % t); return t
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
        in_t = {f_[1:] for f_ in ('XWA', 'XBC', 'XDE', 'XHL') if f_ in t} | \
               {{'A': 'WA', 'C': 'BC', 'E': 'DE', 'L': 'HL'}[m_] for m_ in re.findall(r'\+([ACEL])\)', t)} | \
               {m_ for m_ in re.findall(r'\+(WA|BC|DE|HL)\)', t)}      # the registers the address is built from
        work = 'WA' if 'WA' not in live_regs(F) and 'WA' not in in_t else free_reg(F, avoid={'WA'} | in_t)   # .as_mul_gi: muls XBC,WA
        n_t = len(F.lines)                                 # (r2_06_15: gia[u] /= 10 through (XBC+WA) divided in XWA and
        F.emit('ld', '%s,%s' % (FAM[work][size], t))      # stored through the quotient; r4_02_10: guca[t] /= 7 in (XWA))
        wide = FAM[work][4] if size == 2 else FAM[work][2]
        if op == '*':
            F.emit('muls' if signed else 'mul', '%s,%s' % (wide, rs)); res = FAM[work][size]
        else:
            F.emit('exts' if signed else 'extz', wide); F.emit('divs' if signed else 'div', '%s,%s' % (wide, rs))
            res = FAM[work][size] if op == '/' else (Q[work] if size == 2 else HI[work])
        if res.startswith('Q'):                            # .as_mod_gi: ld WA,QBC into the dead operand's register
            dst = 'WA' if work == 'WA' or (rs == 'WA' and dies_here(F, narrow(r, size))) else FAM[work][2]
            F.emit('ld', '%s,%s' % (dst, res)); res = dst
        if STORE_ADDR_GUARD and clobbers(F.lines[n_t:], t): raise Unsupported('the op= operation overwrites its address')
        F.emit('ld', '%s,%s' % (t, res)); return t
    raise Unsupported('opassign ' + op)

def uses_after_stmt(F, d):
    """is d read in a statement after the current one (F.next_stmt onwards)?"""
    nx = getattr(F, 'next_stmt', None)
    if nx is None: return False
    body = flat(F.f.body)
    try: i = body.index(nx)
    except ValueError: return True
    return any(uses_decl(x, d) for x in body[i:])

def store_global(F, name, e, size):
    ia = strip(e)
    while ia.k == 'cast' and ia.kind == 'IntegralCast': ia = strip(ia.e)
    if ia.k == 'bin' and ia.op == '=' and strip(ia.l).k == 'var' and strip(ia.l).decl.kind == 'global' and size <= 2 \
            and strip(ia.l).decl.ty.size == size and fold(narrow(ia.r, size)).k == 'const':
        store_global(F, strip(ia.l).decl.name, ia.r, size)   # ae_i_chain_k: gi = gi2 = 7 -> ldw (_gi2),0x7 /
        store_global(F, name, ia.r, size); return            # ldw (_gi),0x7
    rc = fold(narrow(e, size)) if size <= 2 else None
    if rc is not None and rc.k == 'const' and rc.value is not None:   # _exp, _tan: errno = ERANGE -> ldw (_errno),0x22
        F.emit('ld' + ('b' if size == 1 else 'w'), '(_%s),%s' % (name, imm_of(rc, size))); return
    if strip(e).k == 'call' and not has_helper_call(strip(e).fn):   # abi returns.c use_i: cal _x_i / ld (_gi),HL
        gen_call(F, strip(e)); flush_pops(F); F.emit('ld', '(_%s),%s' % (name, FAM['HL'][size])); return
    rv = regvar_of(getattr(strip(e), 'e', e)) if strip(e).k == 'load' else None
    if rv is not None and rv.ty.size == size:          # ra_twice: ld (_ga),HL
        if FAM[rv.reg][size] == 'QIZH':                # lo_c_Gcs: ld A,QIZH / ld (_hc2),A (no ld (mem),QIZH)
            F.emit('ld', 'A,QIZH'); F.emit('ld', '(_%s),A' % name); return
        F.emit('ld', '(_%s),%s' % (name, FAM[rv.reg][size])); return
    xv = strip(strip(e).e) if strip(e).k == 'load' else None
    if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and size == 4 and xv is not None and xv.k == 'var' and \
            getattr(xv.decl, 'reg', None) == 'XIZ':
        F.emit('ld', '(_%s),XIZ' % name); return         # lo_l_Gcs: ld (_hl2),XIZ (not through XWA)
    F.store_from = None
    work = 'WA'
    if getattr(F, 'tfam', None) and size == 1 and strip(e).k in ('bin', 'cast'):
        # after an R6 loop (opt_temps.c ot_cnt_abn: gc = *a + *b -> ld C,(XBC) / add C,(XWA)): the first of WA, BC,
        # DE, HL whose variable is not needed again (b dies at its load, n after the loop)
        x = strip(e)
        while x.k == 'cast': x = strip(x.e)
        need = set()
        if x.k == 'bin':
            walk(x.l, lambda m, d: need.add(strip(m.e).decl) if m.k == 'load' and strip(m.e).k == 'var' else None)
        for d in list(F.f.params) + list(F.f.decls):
            if getattr(d, 'reg', None) and d not in need and not uses_after_stmt(F, d): continue
            if getattr(d, 'reg', None): need.add(d)
        held = {getattr(d, 'reg', None) for d in need}
        work = next((r for r in ('WA', 'BC', 'DE', 'HL') if r not in held), 'WA')
    elif STORE_GLOBAL_FREE and held_after(F, 'WA', e):  # lnr.c r_p_rd (-Xr): gr = p[i] with p in XWA -> ld DE,IZ /
        work = next((r for r in ('BC', 'DE', 'HL') if not held_after(F, r, e)), 'WA')   # ... / ld DE,(XDE) /
    fam = gen(F, e, work, size, store=True)                                           # ld (_gr),DE
    reg = F.store_from or FAM[fam][size]
    if STORE_FROM_WORK and F.opt and F.lines and size >= 1:   # -O: the value is stored from where it was computed
        m = re.match(r'^\tld\t%s,(BC|DE|HL|IX|IY|XBC|XDE|XHL|XIX|XIY|C|E|L)$' % reg, F.lines[-1])   # (assign_expr.c
        if m and len(m.group(1)) == len(reg): F.lines.pop(); reg = m.group(1)   # ae_i_chain_ll -O3 -XS -Xr:
    F.emit('ld', '(_%s),%s' % (name, reg))                                      # add BC,WA / ld (_gr),BC)

# ------------------------------------------------------------- statements

def ptr_store_before_use(rest, d, init=None):
    """does a statement before d's first use write what d's initializer read: a store through a pointer or into an
    array element when the initializer reads memory through one (r2_08_05: gpl[2] = 8L after long t = gpl[2] ^ k),
    or a write of a global the initializer reads (r2_05_10: gpi = &gia[u] after int t = *gpi + a)?"""
    reads = set(); through = []; vreads = set(); calls = []
    if init is not None:
        def rv(n, depth):
            if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl.kind == 'global': reads.add(strip(n.e).decl)
            if n.k == 'load' and strip(n.e).k == 'var': vreads.add(strip(n.e).decl)
            if n.k == 'load' and (strip(n.e).k in ('deref', 'index') or strip(n.e).k == 'member' and strip(n.e).arrow):
                through.append(n)
            if n.k == 'call': calls.append(n)
        walk(init, rv)
    for st in rest:
        if uses_decl(st, d): return False
        hit = []
        def target(t):
            t = strip(t)
            if t.k in ('deref', 'index') or (t.k == 'member' and t.arrow):
                return init is None or bool(through) or bool(reads) or bool(calls)   # (r2_09_01: *gp may alias gs.u; _ultoa: q = s folds)
            if t.k == 'var' and t.decl in vreads: return True   # (r3_01_07: a = gu2 before gpi = t with t = gpi + a)
            if t.k == 'var' and t.decl.kind == 'global' and (through or calls): return True   # (r3_04_11, r3_07_01)
            if t.k == 'member' and not t.arrow and strip(t.base).k == 'var' and strip(t.base).decl in reads: return True
            return False
        def v(n, depth):
            if n.k in ('bin', 'opassign') and (n.k == 'opassign' or n.op == '=') and target(n.l): hit.append(n)
            if n.k == 'incdec' and target(n.e): hit.append(n)
        walk(st, v)
        if hit: return True
    return False

def uses_of(node, d, acc):
    if isinstance(node, list):
        for x in node: uses_of(x, d, acc)
        return acc
    if not hasattr(node, 'k'): return acc
    if node.k == 'load' and strip(node.e).k == 'var' and strip(node.e).decl is d: acc.append(node)
    for v in node.__dict__.values():
        if hasattr(v, 'k') or isinstance(v, list): uses_of(v, d, acc)
    return acc

def ptr_elem_in_loops(f):
    """does a loop read p[i] (computed index) through a pointer variable kept in memory (its address is built in
    XWA)?  (lnr4.c h5: c ^= s[i] -> c is not A)"""
    hit = []
    def v(n, dep):
        if dep and n.k == 'index' and fold(n.idx).k != 'const' and strip(n.base).k == 'load' and \
                strip(n.base).ty.is_ptr() and strip(strip(n.base).e).k == 'var' and \
                strip(strip(n.base).e).decl.kind == 'param': hit.append(n)
    walk(f.body, v)
    return bool(hit)

def written_in(nodes, d):
    """is d assigned, op-assigned or incremented anywhere in nodes?"""
    hit = []
    def v(n, dep):
        if n.k == 'incdec' and strip(n.e).k == 'var' and strip(n.e).decl is d: hit.append(n)
        if n.k in ('opassign', 'bin') and (n.k == 'opassign' or n.op == '=') and strip(n.l).k == 'var' and \
                strip(n.l).decl is d: hit.append(n)
    for x in nodes if isinstance(nodes, list) else [nodes]: walk(x, v)
    return bool(hit)

def substitute(node, d, repl):
    if hasattr(repl, 'k'): repl.from_local = d          # (evorder_bin: folded locals keep their declaration order)
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

def read_after_top(F):
    """the variables whose first reference after the current top-level statement is a read (live there); a
    statement that is not `d = e` with e free of d counts as a read"""
    tops = getattr(F, 'top_stmts', None)
    k = getattr(F, 'cur_top', None)
    if tops is None or k is None: return set()
    memo = F.__dict__.setdefault('_read_after', {})
    if k in memo: return memo[k]
    out = set(); seen = set()
    for st in tops[k + 1:]:
        for d in list(F.f.params) + list(F.f.decls):
            if d in seen or not getattr(d, 'reg', None) or not uses_decl(st, d): continue
            seen.add(d)
            e = strip(st.e) if st.k == 'expr' else None
            if not (e is not None and e.k == 'bin' and e.op == '=' and strip(e.l).k == 'var' and strip(e.l).decl is d
                    and not uses_decl(e.r, d)):
                out.add(d)
    memo[k] = out
    return out

def gen_stmt(F, s, last):
    tix = getattr(F, 'top_ix', None)
    if tix is not None and id(s) in tix: F.cur_top = tix[id(s)]
    if getattr(F, 'sret_home_pending', None) and tix is not None and id(s) in tix:
        r_ = []; walk(s, lambda n, d: r_.append(n) if n.k == 'return' and n.value is not None else None)
        if r_: F.lines.append(F.sret_home_pending + '\t;sret-late'); F.sret_home_pending = None
    if s.k != 'block' and getattr(F, 'fp_temps', None) is not None:
        fpgen.begin_stmt(F, s); F._root_done = False; fpgen.hoist_elems(F, s)         # R5g: a statement's op temporaries are free at the next
        e = getattr(s, 'e', None) if s.k == 'expr' else None
        e = strip(e) if e is not None else None
        F.stmt_global = e is not None and ((e.k == 'bin' and e.op == '=') or e.k == 'opassign') and \
            strip(e.l).k == 'var' and strip(e.l).decl.kind == 'global'
    if s.k in ('if', 'for', 'while', 'do', 'switch') and getattr(F, 'lazy_homes', None):
        for d in [d for d in F.f.params if d in F.lazy_homes and uses_decl(s, d)]:
            touch_home(F, d)                               # c_while: ld IZ,(XSP+0x6) before the loop
    if s.k == 'block':
        body = flat(s)
        i = 0
        if s is F.f.body and getattr(F, 'guard_armed', False): F.guard_on = True   # (after the prologue, real pass only)
        while i < len(body):
            c = body[i]; F.cur_stmt = c; F.cur_rest = body[i + 1:]   # (cur_rest: the innermost block's remainder)
            if s is F.f.body:
                F.top_cur = c; F.top_rest = body[i + 1:]
                for d_ in F.f.decls:                       # a register temporary is free once nothing after it reads it
                    if getattr(d_, 'regtemp', False) and d_ not in F.dead and not uses_decl(c, d_) and \
                            not any(uses_decl(y_, d_) for y_ in F.top_rest):
                        F.dead.add(d_)
            F.next_stmt = body[i + 1] if i + 1 < len(body) else None
            F.prev_stmt = body[i - 1] if i else None
            if F.opt and not F.adecl and MEMBER_RUNS and getattr(F, 'ptr_run_end', -1) == i:
                F.ptr_cache = {}; F.store_val_reg = None
            if F.opt and not F.adecl and MEMBER_CSE and i == 0 and getattr(F, 'top_stmts', None) is not None and \
                    s is F.f.body and not getattr(F, 'ptr_cache', None):
                mc = member_cse(F)
                if mc is not None:                         # _fgetc: ld XDE,(XSP+0x4) / lda XBC,XDE+0xa: the stream in
                    p_, moff = mc                          # XDE for every member, the twice-used member's address in XBC
                    F.emit('ld', 'XDE,(XSP+%s)' % hx(p_.off + F.push)); F.emit('lda', 'XBC,XDE+%s' % hx(moff))
                    F.ptr_cache = {p_: 'XDE'}; F.member_cache = {(p_, moff): '(XBC)'}; F.ptr_run_end = 10 ** 6
            if F.opt and not F.adecl and MEMBER_RUNS and not getattr(F, 'ptr_cache', None):
                run = member_run(body, i)
                if run is not None:
                    p_, n_, nonconst, rets_val = run
                    R_ = 'XWA' if rets_val or not nonconst else 'XBC'
                    F.emit('ld', '%s,(XSP+%s)' % (R_, hx(p_.off + F.push)))
                    F.ptr_cache = {p_: R_}; F.ptr_run_end = i + n_
                    F.store_val_reg = 'HL' if rets_val else None
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
                        and (d.reg != 'XIZ' or (c.k in ('expr', 'return', 'decl', 'while', 'for', 'do') and uses_decl(c, d)))
                        and not (getattr(F, 'l2', None) and c.k == 'decl' and d in F.l2.get('ro', ()))]   # _itoa: radix
                                                                    # after sign = 0, at its first use
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
                    if c.k in ('for', 'while', 'do') or (c.k == 'if' and at_start and getattr(F, 'nonleaf_regs', False)):
                        own = sorted(own, key=order_key)   # the loop needs them all; _ltoa's if: s, val, then radix
                for d in rest + own:                       # _strncpy: n, s2, then s1 (its own statement); _strchr: s, c
                    setup_struct_temps(F, c)
                    F.emit('ld', '%s,(XSP+%s)' % ('XIZ' if d.reg == 'XIZ' else FAM[d.reg][d.ty.size], hx(d.off + F.push)))
                    F.deferred.remove(d)
            if c.k == 'decl' and c.var.kind == 'local' and (getattr(c.var, 'reg', None) not in (None, 'XIZ', 'WA') or
                                                          getattr(c.var, 'reg', None) == 'WA' and getattr(c.var, 'regtemp', False)):
                if c.init is not None:
                    from frontend import N
                    regvar_stmt(F, N('bin', op='=', l=N('var', decl=c.var, ty=c.var.ty), r=c.init, ty=c.var.ty))
                i += 1; continue
            if c.k == 'decl' and getattr(c.var, 'reg', None) == 'XIZ':
                ci = strip(c.init) if c.init is not None else None
                if ci is not None and F.opt and F.adecl and ci.k == 'bin' and ci.op in ('+', '-') and \
                        fold(ci.r).k == 'const' and fold(ci.r).value is not None and 1 <= abs(fold(ci.r).value) <= 8 and \
                        unpromote(ci.l).k == 'load':
                    fam = gen(F, c.init, 'IZ', 4)          # ra_homes.c rh_ptr / rh_long under O3XSXr: built in XIZ
                    if fam != 'IZ': F.emit('ld', 'XIZ,%s' % FAM[fam][4])   # (lda XIZ,XWA+0x1; ld XIZ,(XSP+0x4) /
                    i += 1; continue                       # inc 0x1,XIZ)
                ci_ = strip(c.init) if c.init is not None else None
                while ci_ is not None and ci_.k == 'cast' and ci_.kind in ('IntegralCast', 'NoOp', 'BitCast') and \
                        strip(ci_.e).ty is not None and strip(ci_.e).ty.size == 4: ci_ = strip(ci_.e)
                if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and ci_ is not None and mem_operand(F, ci_) is not None and \
                        not getattr(F, 'l2', None):     # lo_l_Gcs: ld XIZ,(_gl) (not through XHL)
                    F.emit('ld', 'XIZ,%s' % mem_operand(F, ci_)); i += 1; continue
                if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and ci_ is not None and ci_.k == 'bin' and ci_.op in ('+', '&', '|', '^') and \
                        fold(ci_.l).k == 'const' and fold(ci_.r).k != 'const' and mem_operand(F, ci_.r) is not None:
                    from frontend import N                 # r3_08_11: 54549UL + gul -> ld XIZ,(_gul) / add XIZ,0xd515
                    ci_ = N('bin', op=ci_.op, l=ci_.r, r=ci_.l, ty=ci_.ty)
                if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and ci_ is not None and ci_.k == 'bin' and \
                        (ci_.op in SIMPLE_OPS or ci_.op in ('<<', '>>') and fold(ci_.r).k == 'const') and \
                        not ci_.ty.is_ptr() and mem_operand(F, ci_.l) is not None and fold(ci_.l).k != 'const' and \
                        (mem_operand(F, ci_.r) is not None or fold(ci_.r).k == 'const') and not getattr(F, 'l2', None):
                    F.emit('ld', 'XIZ,%s' % mem_operand(F, ci_.l))   # lo_l_Bcs: ld XIZ,(_gl) / add XIZ,(_hl);
                    rc_ = fold(ci_.r)                                 # lo_ul_Bcs: srl 0x3,XIZ
                    if ci_.op in ('<<', '>>') and rc_.k == 'const':
                        emit_shift(F, ('sla' if ci_.ty.signed else 'sll') if ci_.op == '<<' else ('sra' if ci_.ty.signed else 'srl'), rc_.value, 'XIZ')
                    elif rc_.k == 'const' and ci_.op in '+-' and 1 <= (rc_.value or 0) <= 8:
                        F.emit('inc' if ci_.op == '+' else 'dec', '%s,XIZ' % hx(rc_.value))
                    else: F.emit(SIMPLE_OPS[ci_.op], 'XIZ,%s' % (mem_operand(F, ci_.r) if rc_.k != 'const' else hx(rc_.value & 0xffffffff)))
                    i += 1; continue
                if c.init is not None:
                    if ci_ is not None and ci_.k == 'bin' and ci_.ty.is_ptr() and \
                            any(unpromote(y).ty is not None and unpromote(y).ty.size == 1 for y in (ci_.l, ci_.r)):
                        raise Unsupported('a char index into an XIZ pointer home')   # (r1_04_19: ld XIZ,0x0 / ld IZL,A /
                    fam = gen(F, c.init, 'WA' if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and ci_ is not None and ci_.k == 'bin'
                              and ci_.ty.is_ptr() else 'HL', 4)   # (lo_p_Bcs: ld XWA,(_gp) / inc 0x1,XWA / ld XIZ,XWA)
                    nxc = strip(F.next_stmt.e) if F.next_stmt is not None and F.next_stmt.k == 'expr' else None
                    if strip(c.init).k == 'call' and (nxc is None or nxc.k != 'call' or not nxc.args):
                        flush_pops(F)                      # h_p_only: cal _fp / inc 0x2,XSP / ld XIZ,XHL / cal _g0
                    F.emit('ld', 'XIZ,%s' % FAM[fam][4])
                i += 1; continue
            if c.k == 'decl' and c.init is not None and fpgen.is_fp(c.var.ty):
                fpgen.eval_into(F, c.init, ('lv', N_var(c.var))); i += 1; continue
            if c.k == 'decl' and c.init is not None and c.var.kind == 'local' and not c.var.addr_taken:
                rest = body[i + 1:]
                u = uses_of(rest, c.var, [])
                if UNUSED_LOCAL_INIT and not u and not any(uses_decl(x, c.var) for x in rest) and c.var.ty.size in (1, 2, 4) and \
                        getattr(c.var, 'reg', None) is None and not nodes_in(c.init, 'call') and not has_helper_call(c.init) and \
                        not fpgen.is_fp_op(c.init) and not fpgen.is_fp(c.var.ty):
                    gen(F, c.init, 'WA', c.var.ty.size); F.dead.add(c.var); i += 1; continue   # (cmpordl2.c: an unused
                helper_res = getattr(c.var, 'no_fold', False)                                #  int t = gi; -> ld WA,(_gi))
                upto = rest[:next((k for k, x in enumerate(rest) if uses_decl(x, c.var)), len(rest)) + 1]
                if len(u) == 1 and (c.var.ty.size >= 2 or (F.opt and not F.adecl)) and not call_before_use(rest, c.var) \
                        and not helper_res and not written_in(upto, c.var) and \
                        not (NO_FOLD_OVER_STORE and ptr_store_before_use(rest, c.var, c.init)):   # (lnr4.c h5: c ^= s[i] then gc = c)
                                                     # (mul_l_loc under O3XSXr: x = a * b stays in a slot)
                    for x in rest: substitute(x, c.var, c.init)   # cdecl -O folds a char local too (add_c_loc)
                    i += 1; continue
                if getattr(c.var, 'slot', None) is not None and c.var.ty.size >= 2 and strip(c.init).k != 'initlist':
                    slot_init(F, c.var, c.init); i += 1; continue
                calls_after = []
                for x in rest: walk(x, lambda n, d: calls_after.append(n) if n.k == 'call' else None)
                if len(u) >= 1 and c.var.ty.size == 1 and getattr(c.var, 'slot', None) is not None and calls_after:
                    fam = gen(F, c.init, 'WA', 1)            # _strstr: char c = *s2; -> ld A,(XWA) / ld (XSP+0x8),A
                    F.emit('ld', '(XSP+%s),%s' % (hx(c.var.slot + F.push), FAM[fam][1])); i += 1; continue
                if len(u) >= 1 and c.var.ty.size == 1:
                    wa_live = F.adecl and BINLOC_XR and any(getattr(d, 'reg', None) == 'WA' and d not in F.dead and
                                                            any(uses_decl(x, d) for x in rest) for d in F.f.params)
                    if wa_live: F.keep_once = True; F.keep_q = True   # mul_c_loc under -Xr: x stays in E (a in A);
                    r_ = gen(F, c.init, 'WA', 1); F.keep_once = False; F.keep_q = False   # mod_c_loc: in D
                    if r_ in ('W', 'B', 'D', 'H'):
                        r_ = {'W': 'WA', 'B': 'BC', 'D': 'DE', 'H': 'HL'}[r_]; c.var.rem_hi = True
                    c.var.reg = r_; i += 1; continue
                if LOCAL_ARRAY_INIT and c.var.ty.kind == 'array' and strip(c.init).k == 'initlist' and \
                        getattr(c.var, 'slot', None) is not None and c.var.ty.base.size in (1, 2, 4) and \
                        c.var.ty.size % 2 == 0:
                    es = c.var.ty.base.size; n_ = c.var.ty.size // es; vals = []
                    for it in strip(c.init).items:
                        v_ = fold(it)
                        if v_.k != 'const' or v_.value is None: raise Unsupported('local array initialiser')
                        vals.append(str(v_.value & ((1 << (8 * es)) - 1)))
                    vals += ['0'] * (n_ - len(vals))
                    lab = 'S%d' % fpgen.FCONST[0]; fpgen.FCONST[0] += 1   # __fint: ld XIY,S1 / lda XIX,XSP+0x18 /
                    F.fconsts = getattr(F, 'fconsts', []) + [(lab, vals, 'init%d' % es)]   # ld BC,0x4 /
                    F.emit('ld', 'XIY,%s' % lab)                                          # ldirw (XIX+),(XIY+)
                    F.emit('lda', 'XIX,XSP+%s' % hx(c.var.slot + F.push))
                    F.emit('ld', 'BC,%s' % hx(c.var.ty.size // 2)); F.emit('ldirw', '(XIX+),(XIY+)')
                    i += 1; continue
                raise Unsupported('local ' + c.var.name)
            if c.k == 'decl' and c.init is None: i += 1; continue
            nxt = body[i + 1] if i + 1 < len(body) else None
            if F.opt and c.k == 'expr' and c.e.k == 'bin' and c.e.op == '=' and strip(c.e.l).k == 'deref' and nxt is not None \
                    and nxt.k == 'expr' and strip(nxt.e).k == 'incdec' and strip(nxt.e).op == '++' and \
                    id(c.e) not in getattr(F, 'l2', {}).get('held', {}):     # _strupr: a held store is not folded
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
            if c.k == 'switch' and nxt is not None and nxt.k == 'return' and i + 2 == len(body) and \
                    not switch_breaks(c.body):             # (r3_05_00: an arm that breaks must reach the return)
                F.switch_after = nxt                       # abi switch.c sw_char: the return after the switch goes
                gen_stmt(F, c, False)                      # right after the compare chain
                if getattr(F, 'switch_after', None) is None: i += 2; continue
                F.switch_after = None; i += 1; continue
            if F.opt and not F.adecl and c.k == 'expr' and c.e.k == 'opassign' and strip(c.e.l).k == 'var' and \
                    not fpgen.is_fp(strip(c.e.l).ty) and \
                    not getattr(strip(c.e.l).decl, 'reg', None) and strip(c.e.l).decl.kind in ('param', 'local') and \
                    nxt is not None and nxt.k == 'return' and nxt.value is not None and strip(nxt.value).k == 'load' and \
                    strip(strip(nxt.value).e).k == 'var' and strip(strip(nxt.value).e).decl is strip(c.e.l).decl:
                from frontend import N                     # assign.c *_loc under O3XS: the store to a is dead
                d = strip(c.e.l).decl
                b = N('bin', op=c.e.op, l=N('load', e=N('var', decl=d, ty=d.ty), ty=d.ty), r=c.e.r, ty=d.ty)
                rm_ = mem_operand(F, narrow(c.e.r, d.ty.size))
                if c.e.op == '%' and d.ty.size == 2 and rm_ is not None and rm_.startswith('('):
                    F.emit('ld', 'HL,%s' % mem_operand(F, b.l))   # as_mod_loc: ld HL,(a) / exts XHL / divs XHL,(v) /
                    F.emit('exts' if d.ty.signed else 'extz', 'XHL')   # ld HL,QHL (return a % b: WA, assign.c too)
                    F.emit('divs' if d.ty.signed else 'div', 'XHL,%s' % rm_); F.emit('ld', 'HL,QHL')
                    flush_pops(F); epilogue(F); F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret')
                elif c.e.op in ('*', '/'):                 # as_mul_loc: ld WA,(a) / muls XWA,(v) / ld HL,WA
                    f2 = gen(F, b, 'WA', d.ty.size); F.emit('ld', '%s,%s' % (FAM['HL'][d.ty.size], FAM[f2][d.ty.size]))
                    flush_pops(F); epilogue(F); F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret')
                else:
                    gen_stmt(F, N('return', value=b), last)   # as_add_loc: ld HL,(a) / add HL,(v)
                i += 2; continue
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
    if s.k == 'return' and s.value is not None and getattr(F, 'u1_bcse', False) and F.f.ret.size == 1 and \
            not (F.xiz_vars or F.pushes or getattr(F, 'frame', 0) or F.retd) and u1_byte_sum(F, s.value): return
    if s.k == 'return' and s.value is not None and F.opt and not fpgen.is_fp(F.f.ret):
        cse = cse_params(F, s.value)
        if cse: return
    if s.k == 'return' and F.opt and getattr(F, 'shared_exit', None) and id(s) in F.shared_exit['early']:
        flush_pops(F); F.emit('j', F.shared_exit['label']); return       # _ultoa: j L50000
    if s.k == 'return' and F.opt and getattr(F, 'shared_exit', None) and id(s) == F.shared_exit['last']:
        flush_pops(F)                                      # _ultoa: lda XSP,XSP+0xc before L50000
        if s.value is not None and nodes_in(s.value, 'call'): F.shared_exit_pending = F.shared_exit['label']
        else: F.lines.append(F.shared_exit['label'] + ':')   # (r3_03_06: the label after cal _rl / inc 0x4,XSP, so
    if s.k == 'return' and s.value is not None and fpgen.is_fp(F.f.ret):
        fpgen.gen_return(F, s.value); flush_pops(F)                   # run 2026-11-09-9-micro-fp (fpgen.py)
        rets = []
        walk(F.f.body, lambda n, d: rets.append(n) if n.k == 'return' else None)
        if (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)) and rets and s is not rets[-1]:
            if not getattr(F, 'exit_label', None): F.exit_label = F.newlabel()
            F.emit('j', F.exit_label); return                         # _sin: ... cal ._fld_dd / j L2
        if getattr(F, 'exit_label', None): F.lines.append(F.exit_label + ':')
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F); F.emit('ret'); return
    if s.k == 'expr' and s.e.k in ('bin', 'opassign') and (s.e.k == 'opassign' or s.e.op == '=') and \
            fpgen.is_fp(strip(s.e.l).ty):
        fpgen.gen_assign(F, s.e); return
    if s.k == 'expr' and s.e.k == 'bin' and s.e.op == '=' and strip(s.e.r).k == 'cast' and \
            strip(s.e.r).kind == 'FloatingToIntegral' and strip(s.e.l).ty.size == 4 and fpgen.lvalue_direct(F, s.e):
        return                                             # d_to_l_st: lda XBC,_gd / lda XWA,_gl / cal ._fld_ld
    if s.k == 'return' and s.value is not None and F.sret is not None:
        v = strip(s.value)
        if v.k == 'load' and strip(v.e).k == 'var' and hasattr(strip(v.e).decl, 'slot'):
            d = strip(v.e).decl                        # _ldiv: ld XIX,(sret) / lda XIY,XSP+slot / ld BC,n / ldirw
            F.emit('ld', 'XIX,(XSP+%s)' % hx(F.sret.off + F.push)); F.emit('lda', 'XIY,XSP+%s' % hx(d.slot + F.push))
            F.emit('ld', 'BC,%s' % hx(d.ty.size // 2)); F.emit('ldirw', '(XIX+),(XIY+)')
            if F.xiz_vars: F.emit('pop', F.save_reg)
            epilogue(F); F.emit('ret'); return
        if v.k == 'load' and strip(v.e).k == 'var' and strip(v.e).decl.kind == 'global':
            d = strip(v.e).decl                        # abi returns.c r_big: ld XIX,(XSP+0x4) / ld XIY,_gbig /
            F.emit('ld', 'XIX,(XSP+%s)' % hx(F.sret.off + F.push)); F.emit('ld', 'XIY,_%s' % d.name)   # ld BC,0x8 /
            F.emit('ld', 'BC,%s' % hx(d.ty.size // 2)); F.emit('ldirw', '(XIX+),(XIY+)')               # ldirw
            if F.xiz_vars: F.emit('pop', F.save_reg)
            epilogue(F); F.emit('ret'); return
        raise Unsupported('struct return')
    if s.k == 'expr' and s.e.k == 'call' and (any(fpgen.is_fp(strip(a).ty) for a in s.e.args) or
                                             fpgen.is_fp(s.e.ty) and s.e.ty.size == 8):
        fpgen.call_stmt(F, s.e); return
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
        epi = (F.opt or getattr(F, 'fp_temps', None) is not None) and (F.xiz_vars or F.pushes or getattr(F, 'frame', 0)) \
            and not getattr(F, 'shared_exit', None)       # fp_temps.c t_cmp_e (none too): ld HL,0x1 / j L50000
        if s.value is not None:
            size = F.f.ret.size
            if not has_helper_call(s.value) and F.pending:
                flush_pops(F)                              # h_p, h_p_diff: inc 0x4,XSP / ld XHL,XIZ (none too)
            fam = gen(F, s.value, 'HL', size, then_ret=True)
            if fam != 'HL' and FAM[fam].get(size) != FAM['HL'][size]:
                F.emit('ld', '%s,%s' % (FAM['HL'][size], FAM[fam].get(size, FAM[fam].get(2))))
        if epi and not last:                               # -XS: _calloc: ld XHL,0x0 / j L3 ... L3: pop XIZ / ret
            flush_pops(F)
            if not getattr(F, 'exit_label', None): F.exit_label = F.newlabel()
            F.emit('j', F.exit_label); return
        if getattr(F, 'l2', None): flush_pops(F)          # _itoa: cal _memcpy / lda XSP,XSP+0xa / L3: pop XIZ
        flush_pops(F)                                      # (r3_03_06: the last return's call pops before the exit
        if epi and getattr(F, 'exit_label', None): F.lines.append(F.exit_label + ':')   # label an early return jumps to)
        if getattr(F, 'shared_exit_pending', None): F.lines.append(F.shared_exit_pending + ':'); F.shared_exit_pending = None
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F)
        F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret'); return
    if s.k == 'if' and s.els is None and F.loops and flat(s.then) and flat(s.then)[0].k == 'continue' and len(flat(s.then)) == 1:
        flush_pops(F); gen_cond_true(F, s.cond, F.loops[-1][1]()); return   # c_cont: j ne,L3 (the continue label)
    if s.k == 'if' and s.els is None and F.loops and flat(s.then) and flat(s.then)[0].k == 'break' and len(flat(s.then)) == 1:
        c = strip(s.cond)                                  # _ultoa: if ((val /= radix) == 0) break;
        if c.k == 'bin' and c.op in ('==', '!=') and strip(c.l).k == 'opassign':
            from frontend import N
            inv = N('bin', op='!=' if c.op == '==' else '==', l=c.l, r=c.r, ty=c.ty)
            gen_cond_false(F, inv, F.loops[-1][0]); F.newulabel(); return
        lab = F.newulabel(); gen_cond_true(F, c, F.loops[-1][0]); return
    if s.k == 'if' and s.els is None and not F.pending and not F.pushes and not F.xiz_vars and \
            flat(s.then) and flat(s.then)[0].k == 'return' and len(flat(s.then)) == 1 and (
            flat(s.then)[0].value is None or (strip(flat(s.then)[0].value).k == 'load' and regvar_of(strip(flat(s.then)[0].value).e)
                                              and regvar_of(strip(flat(s.then)[0].value).e).reg == 'HL')):
        lab = F.newulabel()                                # _strchr: cp A,(XHL) / ret eq
        c = strip(s.cond)
        if c.k == 'bin' and c.op in CC_S:
            cc = gen_compare(F, c)
            if cc not in (True, False):
                F.emit('ret', cc); F.lines.append(lab + ':'); return
        bt = bit_cond(F, c) if not fpgen.is_fp(c.ty) else None
        if bt is not None:                                 # cond_bits.c cb_loc: if (n & 1) return n; -> bit 0x0,HL /
            F.emit('ret', bt); F.lines.append(lab + ':'); return   # ret ne
        if (c.k == 'un' and c.op == '!') or c.ty.kind in ('int', 'ptr'):
            from frontend import N                         # _strncat: if (!*s1) return (s); -> cpb (XIX),0x0 / ret eq
            x = strip(c.e) if c.k == 'un' else c           # (no label after it: the loop body goes on)
            cc = gen_compare(F, N('bin', op='==' if c.k == 'un' else '!=', l=x, r=N('const', value=0, ty=x.ty), ty=c.ty))
            if cc not in (True, False):
                F.emit('ret', cc)
                if not F.opt or flat(s.then)[0].value is None:   # c_inf keeps the label (a plain return); at -O
                    F.lines.append(lab + ':')                   # _strncat's return (s) does not
                return
        raise Unsupported('conditional return')
    if s.k == 'if' and s.els is None and F.opt and getattr(F, 'u1_chain', None) and u1_cse_if(F, s): return
    if s.k == 'if':
        fpc = []
        walk(s.cond, lambda n, d: fpc.append(n) if fpgen.is_fp_op(n) else None)
        if F.pending and IF_FLUSH_POPS and not fpc:       # ra_homes32.c h_p_p3: g2(n); if (p == 0)
            live_res = False                                # the previous statement's `v = call()`: v read after the
            pv = getattr(F, 'prev_stmt', None)              # test -> lda XSP,XSP+n (___fmemccpy: pos - s2 in the else
            pe = strip(pv.e) if pv is not None and pv.k == 'expr' else None   # arm); only tested -> add XSP,n
            if POP_LDA_LIVE and pe is not None and pe.k == 'bin' and pe.op == '=' and strip(pe.l).k == 'var' and \
                    strip(pe.r).k == 'call':                # (_strcpy: endPtr == NULL; _strstr: memcmp() == 0)
                v_ = strip(pe.l).decl
                live_res = any(uses_decl(x, v_) for x in (s.then, s.els) if x is not None) or uses_after_stmt(F, v_)
            flush_pops(F, not live_res)
                                                          # ...: the call's pops before the test (an FP test places them
                                                          # itself, before the helper's addresses)
        if s.els is None:                                 # (only one arm popped them before: wrong code)
            lab = F.newulabel()
            F.if_joins = getattr(F, 'if_joins', set()) | {lab}
            folded = False
            bare = not F.xiz_vars and not F.pushes and not getattr(F, 'frame', 0)   # ra_libshapes.c ls_sl_ret: a
            k = gen_cond_false(F, s.cond, 'RET' if last and bare else lab)          # pushed XIZ is popped first
                                                                                   # (ret ne was wrong code)
            if F.lines[-1] == '\tret' and last:
                return                               # condition always false: the statement disappears
            dead0 = set(F.dead)
            gen_stmt(F, s.then, False)
            if stmt_returns(s.then): F.dead = dead0     # (r4_08_02: c died in the returning arm, then was read)
            flush_pops(F)                                # _calloc: inc 0x8,XSP before the join label
            if k is not True: F.lines.append(lab + ':')   # always true: no label (cmp_ui: ge_ui_br0)
            return
        lelse, lend = F.newulabel(), F.newulabel()
        F.if_joins = getattr(F, 'if_joins', set()) | {lend}
        before_trivial_ret = getattr(F, 'trivial_ret_next', False)   # c_ifelse: r = a; else r = b; return r -> j L2
        gen_cond_false(F, s.cond, lelse)
        dead0 = set(F.dead)
        gen_stmt(F, s.then, last)
        if stmt_returns(s.then): F.dead = dead0         # (the else arm and what follows still read them)
        arm_call = F.pending or F.lines[-1].startswith('\tcal\t')
        if last and not before_trivial_ret and not F.xiz_vars and not F.pushes and not F.lines[-1].startswith(('\tret', '\tj\t')) \
                and not getattr(F, 'frame', 0) \
                and not (F.opt and IFCHAIN_JOIN and arm_call):   # (an arm without a call returns
                                                                                  # itself: cb_c_else_80 under O3XS)
            flush_pops(F); F.emit('ret')               # c_ifchain: the exit is duplicated, not jumped to (cdecl -O
                                                       # jumps to the join and the tails merge: pushw 0xa / j L2)
        elif not F.lines[-1].startswith(('\tret', '\tj\t')):
            flush_pops(F); F.emit('j', lend)
        F.push -= F.pending; F.pending = 0
        F.lines.append(lelse + ':')
        gen_stmt(F, s.els, last)
        if last and not before_trivial_ret and not F.xiz_vars and not F.pushes and not getattr(F, 'frame', 0) and \
                not F.lines[-1].startswith(('\tret', '\tj\t')) and not F.opt:   # (a frame is released once, at the join: s_if)
            flush_pops(F); F.emit('ret'); return            # c_ifchain under none: the last arm returns too
        import re as _re
        jumped = any(_re.search(r'[\t,]%s$' % lend, l) for l in F.lines)
        if not (last and F.lines[-1].startswith('\tret')):
            flush_pops(F)                                  # c_ifchain: inc 0x2,XSP before the join labels
            if not (F.opt and last and not jumped):        # a join no arm jumps to is not written (cb_c_else_80
                F.lines.append(lend + ':')                 # under O3XSXr)
        elif jumped:                                       # arr_index.c ai_dig_val: the else arm returns, the then
            js = [i for i, l in enumerate(F.lines) if l == '\tj\t' + lend]   # arm jumps to the join (a missing label
            if last and js and len(js) == sum(1 for l in F.lines if _re.search(r'[\t,]%s$' % lend, l)) and \
                    not F.xiz_vars and not F.pushes:     # before); the join is only the return: each jump returns
                for i in js: F.lines[i] = '\tret'         # (exts HL / ret, as the oracle at every set)
            else: F.lines.append(lend + ':')
        return
    if s.k == 'expr' and F.pending and POP_MERGE_MAX and POP_FLUSH_NOCALL and not nodes_in(s.e, 'call') and \
            not (strip(s.e).k == 'bin' and strip(s.e).op == '=' and strip(strip(s.e).l).k == 'var' and
                 getattr(strip(strip(s.e).l).decl, 'reg', None)):
        flush_pops(F)                                      # random r1_02_19: vd(gd2); gua[a] = ... -> cal _vd /
                                                           # inc 0x8,XSP / ld A,(XSP+0x4): the pops merge across
                                                           # statements that call, and across an assignment to a
                                                           # register variable (homes2a B09: sb(b); a = gi; sa(a) ->
                                                           # cal _sb / ld IZ,(_gi) / push IZ / cal _sa / inc 0x8,XSP)
    if s.k == 'expr' and s.e.k == 'call':
        if F.pending and POP_MERGE_MAX and F.pending + call_arg_bytes(F, s.e) > POP_MERGE_MAX:
            flush_pops(F)                                  # fpp7.c m14: fd(e1); fd(e2); lda XSP,XSP+0x18; fd(e3); ...
        gen_call(F, s.e)                                   # (V4.23 merges call statements' pops up to 32 bytes:
        return                                             # 1,045 pairs of 12-byte fd() calls and never three in
                                                           # fpp5-fpp9; regkw.c k_plain six 2-byte calls, 0xc; _log
                                                           # frexp + ldexp, 0x1e)
    if s.k in ('for', 'while', 'do'):
        if F.pending and LOOP_FLUSH_POPS: flush_pops(F)   # fpp7.c m14: eight fd() calls then a while: the pops come
                                                          # before the loop's test (inside the body was wrong code)
        gen_loop(F, s, last); return
    if s.k == 'switch':
        if F.pending and LOOP_FLUSH_POPS: flush_pops(F)   # fpp7.c m25: the pops before the switch, not in a case arm
        gen_switch(F, s, last); return
    if s.k in ('case', 'default'):                         # a case label inside a switch body (gen_switch)
        if F.case_labels[id(s)] and id(s) not in F.case_inner:
            if F.pending: flush_pops(F)                    # sw_fall: a case falls into the next one: its pops first
            F.lines.append(F.case_labels[id(s)] + ':')
        if s.body is not None: gen_stmt(F, s.body, False)
        return
    if s.k == 'ulabel':                                    # a user label left by goto_returns (_strcspn's bye: stays)
        lab = F.newulabel(); F.lines.append(lab + ':'); F.user_labels = getattr(F, 'user_labels', set()) | {lab}; return
    if s.k == 'break':
        if F.loops[-1][0] in getattr(F, 'switch_rets', set()):   # sw_jt6 under none: each case returns itself
            flush_pops(F); F.emit('ret'); return
        flush_pops(F)                                      # switch.c under O3XS: each arm's pops before its jump (cross-
        F.emit('j', F.loops[-1][0]); return                # jumping then merges cal _f1 / inc 0x2,XSP)
    if s.k == 'continue': F.emit('j', F.loops[-1][1]()); return
    if s.k == 'expr' and s.e.k == 'noop' and s.e.ty is not None and s.e.ty.kind == 'void':
        from frontend import N                                                     # (void)(ap = ...) as a statement
        return gen_stmt(F, N('expr', e=s.e.e), last)
    if s.k == 'expr' and strip(s.e).k == 'cast' and strip(s.e).kind == 'ToVoid':   # (void)(ap = ...): Toshiba's
        from frontend import N                                                     # va_start
        return gen_stmt(F, N('expr', e=strip(strip(s.e).e)), last)
    if s.k == 'expr' and s.e.k == 'bin' and s.e.op == ',':      # a, b as a statement: a then b (_strrchr's for)
        from frontend import N
        gen_stmt(F, N('expr', e=s.e.l), False); gen_stmt(F, N('expr', e=s.e.r), False); return
    if s.k == 'expr' and getattr(F, 'u1x', None) and F.u1x.get('sum2') and s.e.k == 'opassign' and \
            strip(s.e.r).k == 'bin' and id(strip(strip(s.e.r).l).e) in F.u1x['acc']:
        T = FAM[F.u1x['sum2']][2]; r = strip(s.e.r)     # plain -Xr ol_two_arr: ga's address first, gb loaded into its
        a = u1x_op(F, strip(strip(r.l).e)); b = u1x_op(F, strip(strip(r.r).e))   # chain, then add BC,(XIY+IX)
        F.emit('ld', '%s,%s' % (T, b)); F.emit('add', '%s,%s' % (T, a))
        F.emit(SIMPLE_OPS[s.e.op], '%s,%s' % (FAM[regvar_of(s.e.l).reg][2], T)); return
    if s.k == 'expr' and getattr(F, 'u1_held', None) and u1_held_stmt(F, s.e): return
    if s.k == 'expr' and getattr(F, 'u1_inv', None) and s.e.k == 'opassign' and strip(s.e.r) is F.u1_inv[1]:
        R = F.u1_inv[4] or F.u1_inv[2].reg
        F.emit(SIMPLE_OPS[s.e.op], '%s,%s' % (FAM[regvar_of(s.e.l).reg][2], FAM[R][2])); return
    if s.k == 'expr' and regvar_stmt(F, s.e): return
    if s.k == 'expr' and s.e.k == 'opassign':
        gen_opassign(F, s.e); return
    if s.k == 'expr' and s.e.k == 'incdec':
        gen_incdec(F, s.e, 'WA', 0, value=False); return
    if s.k == 'expr' and s.e.k == 'bin' and s.e.op == '=':
        lv = strip(s.e.l)
        if STORE_CHAIN and (not F.opt or STORE_CHAIN_OPT) and lv.ty is not None and lv.ty.size in (1, 2, 4) and not getattr(F, 'l2', None) and \
                not getattr(F, 'u1_i', None) and not getattr(F, 'cl_active', None) and store_chain(F, lv, s.e.r, lv.ty.size):
            return                                         # (stchain.c: L1 = (L2 = V))
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
        if lv.ty.kind == 'struct' and lv.k == 'deref' and strip(strip(s.e.r).e if strip(s.e.r).k == 'load' else s.e.r).k == 'deref':
            sp = strip(strip(strip(s.e.r).e).e) if strip(s.e.r).k == 'load' else strip(strip(s.e.r).e)
            sm = mem_operand(F, sp); dm = mem_operand(F, lv.e)   # abi structs.c s_copy: ld XIY,XBC / ld XIX,XWA /
            if sm is not None and dm is not None:              # ld BC,0x8 / ldirw
                F.emit('ld', 'XIY,%s' % sm); F.emit('ld', 'XIX,%s' % dm)
                F.emit('ld', 'BC,%s' % hx(size // 2)); F.emit('ldirw', '(XIX+),(XIY+)'); return
        if lv.ty.kind == 'struct':                   # m_copy: ld XIX,dst / ld XIY,src / ld BC,words / ldirw
            src = strip(s.e.r)
            if src.k == 'load': src = strip(src.e)
            if not (src.k == 'var' and src.decl.kind == 'global'): raise Unsupported('struct source')
            pv = regvar_of(strip(lv.e).e) if lv.k == 'deref' and strip(lv.e).k == 'load' else None
            if pv is not None and getattr(pv, 'reg', None):         # m_copy under -Xr: the source first,
                F.emit('ld', 'XIY,_%s' % src.decl.name); F.emit('ld', 'XIX,%s' % FAM[pv.reg][4])   # ld XIX,XWA
                F.emit('ld', 'BC,%s' % hx(size // 2)); F.emit('ldirw', '(XIX+),(XIY+)'); return
            t = lvalue(F, lv, ptr='XIX')
            if t != '(XIX)': raise Unsupported('struct destination')
            F.emit('ld', 'XIY,_%s' % src.decl.name); F.emit('ld', 'BC,%s' % hx(size // 2))
            F.emit('ldirw', '(XIX+),(XIY+)'); return
        if STORE_PLAN and not getattr(F, 'l2', None) and not getattr(F, 'u1_i', None) and \
                not getattr(F, 'cl_active', None) and store_plan(F, lv, s.e.r, size): return
        rc = fold(narrow(s.e.r, size))
        if rc.k == 'const' and size <= 2:            # m_gps_set: ldb (XWA),0x0
            t = lvalue(F, lv, ptr='XWA', idx='WA', base='XBC', kind='storek')   # ra_while: ldw (XBC+WA),0x0
            F.emit('ld' + ('b' if size == 1 else 'w'), '%s,%s' % (t, imm_of(rc, size))); return
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
        hr = getattr(F, 'l2', {}).get('held', {}).get(id(s.e))
        if hr is not None and lv.k == 'deref':           # _strupr: ld XDE,XIX / (the value) / ld (XDE),A
            pv = strip(lv.e); pd = regvar_of(pv.e) if pv.k == 'load' else None
            if pd is None: raise Unsupported('held store address')
            F.emit('ld', 'X%s,%s' % (hr, FAM[pd.reg][4]))
            fam = gen(F, s.e.r, getattr(F, 'tfam', 'WA'), size)
            F.emit('ld', '(X%s),%s' % (hr, FAM[fam][size])); return
        def gidx(x):                                 # a global array's element at a computed index
            x = strip(x)
            while x.k == 'cast': x = strip(x.e)
            if x.k == 'load': x = strip(x.e)
            if x.k != 'index' or fold(x.idx).k == 'const': return False
            bb = strip(x.base)
            while bb.k in ('decay', 'cast', 'noop') and getattr(bb, 'e', None) is not None: bb = strip(bb.e)
            return bb.k == 'var' and bb.decl.kind == 'global' and bb.decl.ty.kind == 'array'
        rv0 = regvar_of(strip(s.e.r).e) if strip(s.e.r).k == 'load' else None
        if PTR_ELEM_REGVAL and not F.opt and not F.adecl and rv0 is not None and rv0.ty.size == size and \
                lv.k == 'index' and strip(lv.base).k == 'load' and strip(lv.base).ty.is_ptr() and \
                fold(lv.idx).k != 'const' and rv0.reg not in ('WA',) and 'WA' not in live_regs(F):
            t = lvalue(F, lv, kind='storek')         # lnr.c r_p_wri (none): p[i] = i with i in IX -> ld WA,IX /
            F.emit('ld', '%s,%s' % (t, FAM[rv0.reg][size])); return   # exts XWA / add XWA,XWA / add XWA,(p) / ld (XWA),IX
        if PTR_ELEM_REGVAL and rv0 is not None and rv0.ty.size == size and rv0.reg != 'WA' and \
                'WA' not in live_regs(F) and lv.k == 'deref' and strip(lv.e).k == 'load' and strip(strip(lv.e).e).k == 'var' and \
                not getattr(strip(strip(lv.e).e).decl, 'reg', None):
            t = lvalue(F, lv, ptr='XWA')             # lnr.c r_gp_wr (none, -Xr): *gp = i with i in IX ->
            F.emit('ld', '%s,%s' % (t, FAM[rv0.reg][size])); return   # ld XWA,(_gp) / ld (XWA),IX
        if COPY_ELEM_DE and not F.opt and gidx(lv) and gidx(s.e.r) and not ({'DE', 'HL'} & live_regs(F)):
            t = lvalue(F, lv, idx='DE', base='XHL')   # opt_loops.c ol_i_copy (none): gb[i] = ga[i] -> ld DE,IX /
        elif VALUE_FIRST_CHIDX and lv.k == 'index' and strip(s.e.r).k == 'bin' and strip(s.e.r).op == '=' and \
                not fpgen.is_fp(lv.ty) and size in (1, 2, 4) and strip(strip(s.e.r).l).k == 'var' and \
                uses_decl(lv.idx, strip(strip(s.e.r).l).decl):   # (only when the index reads the assigned variable:
                                                                  # r1_00_05's gula[3] = gul = gula[2] keeps its form)
            fam = gen(F, s.e.r, 'DE', size)              # r3_05_02: guca[a] = a = (a - guca[4]) / 100: the inner
            if fam != 'DE': F.emit('ld', '%s,%s' % (FAM['DE'][size], FAM[fam][size]))   # assignment first, the index
            n2_ = len(F.lines); t = lvalue(F, lv, kind='storev')                        # reads the new a
            if clobbers(F.lines[n2_:], '(XDE)'): raise Unsupported('element store over its value')
            F.emit('ld', '%s,%s' % (t, FAM['DE'][size])); return
        elif VALUE_FIRST_CHIDX and F.adecl and chidx.is_elem(F, lv) and size == 1 and chidx.store_byte_shape(F, lv) and \
                strip(s.e.r).k != 'load' and fold(s.e.r).k != 'const' and not has_helper_call(s.e.r):
            F.emit('lda', 'XBC,%s' % chidx.store_byte_shape(F, lv))   # r2_05_07 (-Xr): guca[a] = (uchar)(gc2 + 2)
            n1_ = len(F.lines); fam = gen(F, s.e.r, 'DE', 1)
            if fam != 'DE': F.emit('ld', 'E,%s' % FAM[fam][1])
            if clobbers(F.lines[n1_:], '(XBC)'): raise Unsupported('element store over its base')
            t = chidx.element(F, lv, 'storeb')
            if t is None: raise Unsupported('element store')
            F.emit('ld', '%s,E' % t); return
        elif VALUE_FIRST_CHIDX and not F.opt and not F.adecl and chidx.is_elem(F, lv) and size == 2 and \
                any(gidx(x) for x in nodes_in(s.e.r, 'load')):
            fam = gen(F, s.e.r, 'DE', size)              # random r1_02_19: gua[a] = gua[a] + gua[6]: the value first,
            if fam != 'DE': F.emit('ld', '%s,%s' % (FAM['DE'][size], FAM[fam][size]))   # in DE (A and XBC build the
            t = chidx.element(F, lv, 'load')             # element reads), then the store's own (XBC+A)
            if t is None: raise Unsupported('element store')
            F.emit('ld', '%s,%s' % (t, FAM['DE'][size])); return
        else:                                        # add DE,DE / lda XHL,_gb / ... lda XBC,_ga / ld (XHL+DE),WA
            nl = len(F.lines)
            t = lvalue(F, lv, kind='storev')         # m_ga_set, m_gps_set (a computed value: p[k] through XBC)
            if STORE_ADDR_GUARD:                     # lnr.c r_gp_wr (-Xr): ld XBC,(_gp) over d3 in BC
                for d in list(F.f.params) + list(F.f.decls):
                    r_ = getattr(d, 'reg', None)
                    if r_ in FAM and d not in F.dead and clobbers(F.lines[nl:], '(%s)' % (FAM[r_].get(4) or r_)) and \
                            held_after(F, r_, s.e):
                        raise Unsupported('store address over a live register')
        rv = regvar_of(strip(s.e.r).e) if strip(s.e.r).k == 'load' else None
        if rv is not None and rv.ty.size == size:
            F.emit('ld', '%s,%s' % (t, FAM[rv.reg][size])); return
        work = getattr(F, 'tfam', 'WA')
        if getattr(F, 'tfam', None) and not F.loops and size == 1:   # op_two_loops: *a = *b after the loops ->
            need = set()                                             # ld C,(XBC) / ld (XWA),C
            walk(lv, lambda m, d: need.add(strip(m.e).decl) if m.k == 'load' and strip(m.e).k == 'var' else None)
            need |= {d for d in list(F.f.params) + list(F.f.decls) if getattr(d, 'reg', None) and uses_after_stmt(F, d)}
            held = {getattr(d, 'reg', None) for d in need}
            work = next((r for r in ('WA', 'BC', 'DE', 'HL') if r not in held), 'WA')
        rcall = strip(s.e.r)
        while rcall.k == 'cast' and rcall.kind in ('BitCast', 'NoOp') or (rcall.k == 'cast' and rcall.ty.is_ptr()): rcall = strip(rcall.e)
        if (F.opt or F.adecl or STORE_XHL_NONE) and rcall.k == 'call' and lv.k == 'var' and size in (2, 4) and not getattr(lv.decl, 'reg', None):
            gen(F, rcall, 'HL', size)                       # ls_mc / _memccpy: cal _vp / inc 0x8,XSP /
            nx = getattr(F, 'next_stmt', None); nxe = strip(nx.e) if nx is not None and nx.k == 'expr' else None
            nxc = strip(nxe.r) if nxe is not None and nxe.k == 'bin' and nxe.op == '=' else nxe
            while nxc is not None and nxc.k == 'cast': nxc = strip(nxc.e)
            if not (nxc is not None and nxc.k == 'call' and nxc.args):   # _strstr: len1 = strlen(s1); len2 = strlen(s2)
                flush_pops(F)                                            # -> the pops merge (inc 0x8,XSP)
            t = lvalue(F, lv)                                   # (the slot's offset after the pending pushes)
            F.emit('ld', '%s,%s' % (t, FAM['HL'][size])); return   # ld (XSP+0x2),XHL
        if getattr(F, 'store_val_reg', None) and getattr(F, 'ptr_cache', None):
            work = F.store_val_reg                         # _ungetc: c is returned next -> ld HL,(XSP+0x4) / ld (XWA+0x8),HL
        if work in FAM and held_after(F, work, s.e):       # ra_ptrcpy (-O3 -XS -Xr): *d++ = *s++ with d in XWA ->
            work = free_reg(F, avoid={work} | {x for x in ('WA', 'BC', 'DE', 'HL') if x in t})   # not A
        n0 = len(F.lines); push0 = F.push
        rv_ = strip(s.e.r)
        if XIZ_DIRECT_INIT and (not F.opt or XIZ_DIRECT_OPT) and size == 4 and rv_.k == 'load' and strip(rv_.e).k == 'var' and \
                getattr(strip(rv_.e).decl, 'reg', None) == 'XIZ':
            F.emit('ld', '%s,XIZ' % t); return             # lo_l_Gcs: ld (_hl2),XIZ (not through XWA)
        fam = gen(F, s.e.r, work, size)                    # opt_temps.c ot_cpy_anb: ld E,(XHL+:1) / ld (XWA+:1),E
        if STORE_ADDR_GUARD and clobbers(F.lines[n0:], t):
            raise Unsupported('the value overwrites the store address')    # (wrong code otherwise)
        if F.push != push0 and t.startswith('(XSP'):        # r2_08_13: a = r2(..) << 11: the pops are still pending
            if lv.k != 'var': raise Unsupported('store address moved by the value')
            t = lvalue(F, lv, kind='storev')
        if FAM[fam][size] == 'QIZH': F.emit('ld', 'A,QIZH'); fam = 'WA'   # (lo_c_Gcs: ld A,QIZH / ld (_hc2),A)
        F.emit('ld', '%s,%s' % (t, FAM[fam][size])); return
    raise Unsupported('statement ' + s.k)

_gen_stmt_body = gen_stmt
def gen_stmt(F, s, last):
    """gen_stmt with F.in_return raised while a return statement (at any depth) is generated: the live-local guard
    then knows nothing is read after it (_strlen: if (ss == NULL) return 0xffff; writes ss's HL)"""
    prev = getattr(F, 'in_return', False); F.in_return = prev or s.k == 'return'
    try: return _gen_stmt_body(F, s, last)
    finally: F.in_return = prev

def param_live_after(F, d):
    """is d read by a top-level statement after the current one, or by the current one when it is a loop?
    (the live-parameter guard; inside a loop every read of the next iteration counts)"""
    top = getattr(F, 'top_cur', None)
    if top is None: return True
    if any(uses_decl(x, d) for x in getattr(F, 'top_rest', [])): return True
    if any(uses_decl(x, d) for x in getattr(F, 'cur_rest', [])): return True   # (r4_09_15 -Xr: gua[a] later in the
    if top.k == 'for':                                     # (c_fordown: n read by the init only is not live in the body)
        return any(uses_decl(x, d) for x in (getattr(top, 'cond', None), getattr(top, 'inc', None), top.body) if x is not None)
    return top.k in ('while', 'do') and uses_decl(top, d)

def self_update(op, args, d):
    """is the instruction an arithmetic update of d's own register (dec 0x1,BC for n-- in a loop that owns n)?  A
    load into it from elsewhere is not (r4_00_03: ld XWA,(_gp) in a loop over a; r4_04_14: ld XWA,(_gps) over t)"""
    if op in ('ld', 'lda', 'cal', 'pop', 'push', 'pushw', 'ldw', 'ldb', 'scc', 'ex') or ',' not in args: return False
    parts = args.split(',')
    dest = parts[1] if op in ('inc', 'dec', 'incw', 'decw') else parts[0]
    return dest in REG_ALIASES.get('X' + d.reg, ())

def own_slot(F, d, args):
    """is this `ld R,(XSP+k)` the reload of d's own slot into its register?  (c_cnt -O3 -XS: ld XWA,(XSP+0x4))"""
    off = getattr(d, 'off', None) if d.kind == 'param' else getattr(d, 'slot', None)
    if off is None: return False
    return args.endswith(',(XSP+%s)' % hx(off + F.push)) or (off + F.push == 0 and args.endswith(',(XSP)'))

def assigns_decl(node, d):
    """does the statement assign, op-assign or ++/-- the variable d (then writing its register is the point)"""
    if node is None or d is None: return False
    hit = []
    def v(n, depth):
        if n.k in ('bin', 'opassign') and (n.k == 'opassign' or n.op == '=') and strip(n.l).k == 'var' and strip(n.l).decl is d: hit.append(n)
        if n.k == 'incdec' and strip(n.e).k == 'var' and strip(n.e).decl is d: hit.append(n)
        if n.k == 'decl' and getattr(n, 'var', None) is d: hit.append(n)   # (c_sum: int s = 0 -> ld HL,0x0)
    if getattr(node, 'k', None) == 'decl' and getattr(node, 'var', None) is d: return True
    walk(node, v)
    return bool(hit)

def written_fams(op, args):
    """the register families an instruction writes (for the live-parameter guard); a call writes WA, BC, DE, HL"""
    if op in ('cal', 'call'): return ['XWA', 'XBC', 'XDE', 'XHL']
    parts = [x.strip() for x in args.split(',')]
    if op in ('or', 'and', 'ld') and len(parts) == 2 and parts[0] == parts[1]: return []   # a test or a no-op (.sbrk:
                                                                                       # or XWA,XWA; lnr4 h8: ld XWA,XWA)
    regs = []
    if op in ('inc', 'dec', 'sla', 'sll', 'sra', 'srl', 'rl', 'rr', 'rlc', 'rrc', 'scc') and len(parts) == 2: regs = [parts[1]]
    elif op in ('ld', 'lda', 'add', 'sub', 'and', 'or', 'xor', 'adc', 'sbc', 'neg', 'cpl', 'exts', 'extz', 'mul', 'muls',
                'div', 'divs', 'pop', 'set', 'res', 'chg', 'ldi', 'ldiw', 'ldir', 'ldirw', 'minc1', 'minc2', 'minc4',
                'mdec1', 'mdec2', 'mdec4', 'paa', 'daa', 'mirr', 'bs1f', 'bs1b', 'ex'):
        regs = parts[:2] if op == 'ex' else parts[:1]
    out = []
    for r in regs:
        if r.startswith('('): continue
        f = family_of(r)
        if f: out.append(f)
    return out

def clobbers(lines, operand):
    """does any of lines write a register that the memory operand (XDE+BC) / (XBC) is built from?"""
    import re
    if not operand.startswith('('): return False
    fams = {family_of(r) for r in re.findall(r'\b(X?(?:WA|BC|DE|HL|IX|IY|IZ))\b', operand)} - {None}
    fams |= {{'A': 'XWA', 'C': 'XBC', 'E': 'XDE', 'L': 'XHL'}[r] for r in re.findall(r'\+([ACEL])\)', operand)}
    if not fams: return False                           # (r1_02_19: (XDE+C) is built from XBC too)
    for l in lines:
        m = re.match(r'^\t(ld|lda|add|adc|sub|sbc|and|or|xor|sla|sll|sra|srl|rl|rr|rlc|rrc|exts|extz|mul|muls|div|divs|'
                     r'neg|cpl|pop|inc|dec|ex|ldw|ldb|scc)\t(?:(?:0x[0-9a-f]+|[a-z]+),)?([A-Z]+)\b', l)   # (scc eq,BC
        if m and not m.group(2).startswith(('XSP', 'SP')) and family_of(m.group(2)) in fams: return True
        if l.startswith('\tcal'): return True
    return False

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

F_OPT_HINT = [False]                                      # (set by compile_function: -O folds u % 8 to an and)

def has_helper_call(e):
    if not hasattr(e, 'k'): return False
    if e.k == 'bin' and e.op in '*/%' and e.ty.size == 4 and fold(e.r).k != 'const': return True
    if e.k == 'bin' and e.op in '/%' and e.ty.size == 4 and HELPER_CONST_DIV and getattr(has_helper_call, 'const_div', False) \
            and not (not e.ty.signed and fold(e.r).k == 'const' and fold(e.r).value and
                     fold(e.r).value & (fold(e.r).value - 1) == 0 and (e.op == '/' or F_OPT_HINT[0])):
        return True                                      # (u / 2UL is a shift; u % 8 an and under -O)
    if e.k == 'call' or fpgen.is_fp_op(e): return True
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
        if F.adecl and F.opt and BINLOC_XR: break        # -O3 -XS -Xr: the helper result takes a slot (mul_l_loc)
        if c.k == 'decl' and c.init is not None and c.var.ty.size == 4 and has_helper_call(c.init) and \
                not getattr(c.var, 'regtemp_pre', False):   # (lo_l_R0a: a long call result read next stays in XHL)
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
    if CALL_RIGHT_FIRST and node.k == 'bin' and node.op in SIMPLE_OPS and has_helper_call(node.r) and \
            not has_helper_call(node.l) and node.ty is not None and node.ty.size == 2:
        eval_sequence(node.r, out); eval_sequence(node.l, out); return out   # probes/adfp.c ad_di: a + (x > 0.0)
    for v in node.__dict__.values():
        if hasattr(v, 'k') or isinstance(v, list): eval_sequence(v, out)
    if node.k == 'load' and strip(node.e).k == 'var': out.append(('use', strip(node.e).decl))
    if node.k == 'incdec' and strip(node.e).k == 'var': out.append(('use', strip(node.e).decl))   # c_while: n--
    if node.k == 'opassign' and strip(node.l).k == 'var': out.append(('use', strip(node.l).decl))
    if node.k == 'call' or (node.k == 'bin' and node.op in '*/%' and node.ty.size == 4 and fold(node.r).k != 'const') \
            or fpgen.is_fp_op(node):
        out.append(('call',))
    return out

# where homes.choose replaces the first fit's rule: R3-set under none, -Xr, -O3 -XS -Xr; under -O3 -XS rule R4 when a
# 32-bit value is a candidate (research-scratch sessions/2026-11-09_cc900-homes 1baf8a7: _strlen, _calloc, _memccpy,
# _strcmp, _modf), else the first fit's rule (homes.choose returns None).
R3_SETS = ('none', 'Xr', 'O3XSXr', 'O3XS')
# Which functions the homes2 rule (homes2.py, research-scratch sessions/2026-11-09_cc900-homes2) decides instead of
# homes.py's R3-set / R4 and the first-fit fallback below: one of homes2.POLICIES.  The environment variable
# CC900_HOMES2 overrides it, so ledger.sh, pairs_model.py and semcheck.py can measure each policy unchanged.
# 'fallback-noloop' (2026-11-10) is the one policy that moved no ledger row down (regalloc_notes.md, "The homes2
# rule, ported"); 'r4keep' gains the most but loses ra_homes Xr / O3XSXr and one micro function per set.
HOMES2 = os.environ.get('CC900_HOMES2', 'fallback-noloop')
FP_AGGR = True
MUL_K_XWA = True
IFCHAIN_JOIN = True
BINLOC_XR = True
ONCE_READ_MEM = True                               # cdecl -O: a parameter read once per iteration stays in memory
POW2_UNSIGNED = True                               # -O: unsigned % / by 2^k are and / srl (_doodigit)
ARG_LOCAL_WA = True                                # -O: a local read only as an argument of the returned call: XWA
MEMBER_RUNS = True                                 # cdecl -O: p->f stores load p once (_fassign, _ungetc)
GLOBAL_FORWARD = True                              # -O: a global just stored is not reloaded (_rand)
HOMES_PARAM_ORDER = True                           # adecl entry homes in reverse parameter order (h_p_diff)
PTR_CHAR_EXTZ = True                               # p + i on a char pointer zero-extends i (h_p_n3, ai_c_p_*)
SLOT_FROM_HL = True                                # a call result stored to a slot from HL / XHL (h_p)
WALKED_OPT_WA = True                               # -O3 -XS: c_cnt's lone walked pointer takes XWA too
WALKED_PTRS = True                                 # no -O: pointers a pointer-test loop walks get registers (c_cnt)
KILL_AFTER_CALL = True                             # homes: a def after a call on its path kills (sw_local)
CDECL_TAILCALL = True                              # -O: cal _f / ret (nothing between) is j _f (sw_jt6d)
EXIT_PLACEMENT = True                              # -O: an exit block nothing falls into moves (switch.c sw_evtab)
CJ_TRAMPOLINES = True                              # -O: arms the tail merge empties go (switch.c sw_ev)
RET_TAILS = True                                   # -O cross jumping of `cal X / ret` tails (switch.c sw_ret)
CONST_PROP = True                                  # -O: a local assigned one constant is that constant (rc_loop1)
COPY_PROP = True                                   # -O copy propagation (assign_expr.c, copy_propagate)
UNPROMOTED_SIGN = True
STORE_XHL_NONE = True
DEREF_XIZ = True

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
    def long_helper(n):
        return n.k == 'bin' and n.ty is not None and n.ty.size == 4 and (n.op in '/%' or n.op == '*' and
               not (fold(n.r).k == 'const' and fold(n.r).value is not None and fold(n.r).value > 0 and
                    bin(fold(n.r).value).count('1') <= 3))
    helpers = []
    walk(F.f.body, lambda n, d: helpers.append(n) if long_helper(n) else None)
    real_calls = []                                        # eval_sequence counts the helpers as calls too
    walk(F.f.body, lambda n, d: real_calls.append(n) if n.k == 'call' or fpgen.is_fp_op(n) else None)
    helper_only = F.adecl and F.opt and BINLOC_XR and helpers and not real_calls
    if helper_only:
        # binop-loc section 6: -O3 -XS -Xr treats a long helper's arguments as live across it (div_l_pk:
        # push XIZ / ld XIZ,XWA / ld XWA,XIZ / lda XBC,0xa / cal C9H_divls); the first parameter that is an
        # operand gets XIZ, the other parameters and the helper results slots (mul_l_loc)
        ops = []
        for h in helpers:
            for side in (h.l, h.r):
                sv = strip(side)
                while sv.k == 'cast': sv = strip(sv.e)
                if sv.k == 'load' and strip(sv.e).k == 'var' and strip(sv.e).decl.kind == 'param' and \
                        strip(sv.e).decl not in ops: ops.append(strip(sv.e).decl)
        ops.sort(key=lambda d: F.f.params.index(d))
        if ops and getattr(ops[0], 'reg', None) in ('WA', 'BC', 'DE') and ops[0].ty.size == 4:
            w = ops[0]; src = FAM[w.reg][4]
            F.home_moves = [('XIZ', src)]; F.home_stores = []
            for d in ops[1:]:
                if getattr(d, 'reg', None) in ('WA', 'BC', 'DE'):
                    F.home_stores.append((d, FAM[d.reg][d.ty.size])); d.home_slot = True; d.reg = None
            w.reg = 'XIZ'; w.homed = True; F.xiz_vars.append(w)
            F.save_reg = 'XIZ'; F.emit('push', 'XIZ'); F.push = 4
            for c in flat(F.f.body):                      # a helper's result used by a later helper: a slot
                if c.k == 'decl' and c.init is not None and c.var.ty.size == 4 and has_helper_call(c.init):
                    c.var.no_fold = True
            return
    if not any(x[0] in ('call', 'rcall') for x in seq): return
    def compatible(p, q): return all(q.get(k, v) == v for k, v in p.items())
    across = []
    def mark(d):
        if getattr(d, 'regtemp_pre', False): return      # (plan_regtemps: no call in its live range; lo_l_R0a)
        if d not in across: across.append(d)
    for i, (x, px) in enumerate(seq0):
        if x[0] in ('call', 'rcall'):
            before = {y[1] for y, py in seq0[:i] if y[0] in ('use', 'def')}
            killed = set()                                 # switch.c sw_local: r = g1(x) redefines r on the call's
            for y, py in seq0[i + 1:]:                     # own path, so the later `return r` does not keep r live
                if KILL_AFTER_CALL and y[0] == 'def' and compatible(px, py) and px: killed.add(y[1])   # across it
                if x[0] == 'rcall' and (y[0] != 'use' or len(y) < 3 or y[2] != x[1]): continue
                if y[0] == 'use' and y[1] in killed: continue
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
    # The home rule R3-set (homes.py; research-scratch sessions/2026-11-09_cc900-homes, fit_homes.py BEST3_SET):
    # reads + writes less fitted costs, candidates by option set, order by score (cdecl) or score / live-range
    # length (adecl), IZ (XIZ if 32-bit), the next 16-bit candidate QIZ by a fitted pair test; IZ to the one declared first.
    def stack_born(d): return d.kind == 'param' and not getattr(d, 'reg', None) and d not in getattr(F, 'homed_regs', {})
    call_res = set()
    walk(F.f.body, lambda n, dep: call_res.add(n.var) if n.k == 'decl' and getattr(n, 'init', None) is not None
         and has_helper_call(n.init) else None)
    walk(F.f.body, lambda n, dep: call_res.add(strip(n.l).decl) if n.k == 'bin' and n.op == '=' and
         strip(n.l).k == 'var' and has_helper_call(n.r) else None)
    ldecl = [d for d in F.f.decls if d.kind == 'local']
    if F.adecl:
        pvals = [d for d in params] + [d for d in F.f.params if not getattr(d, 'reg', None) and d in across and
                                       d.ty.kind in ('int', 'ptr') and d.ty.size in (2, 4) and d is not F.sret]
    else:
        pvals = [d for d in F.f.params if not getattr(d, 'reg', None) and d in across and d.ty.kind in ('int', 'ptr')
                 and d.ty.size in (2, 4) and d is not F.sret]
    vals = pvals + locs
    winners = []
    setname = ('O3XSXr' if F.opt else 'Xr') if F.adecl else ('O3XS' if F.opt else 'none')
    if setname in R3_SETS:
        if vals and not F.xiz_vars:
            feats = homes.features(F.f.body, F.f.params, F.opt)
            for d in vals: feats.setdefault(d, homes.Feat())
            rp = [d for d in F.f.params if not (F.adecl and d.ty.kind == 'float')]   # (adecl: a double is on the
            winners = homes.choose(vals, feats, setname, F.adecl, stack_born, call_res,  # stack, a float goes to a
                                   lambda d: rp.index(d) if d in rp else F.f.params.index(d),   # slot: ad_di, ad_fi)
                                   lambda d: ldecl.index(d) if d in ldecl else 0, helper_ops,
                                   homes.uses(F.f.body, F.f.params) if setname == 'O3XS' else None)
        winners_sorted = winners
    h2home = None                                          # homes2: {decl: IZ | QIZ | XIZ} when the policy applies
    if HOMES2 != 'off' and vals and not F.xiz_vars and \
            homes2.applies(HOMES2, setname, setname == 'O3XS' and winners is not None, F.f):
        h2home = homes2_choose(F, vals, setname)
        winners = winners_sorted = sorted(h2home, key=lambda d: (0, F.f.params.index(d)) if d.kind == 'param'
                                          else (1, ldecl.index(d) if d in ldecl else 0))
    elif winners is None or setname not in R3_SETS:
        # the first fit's rule (fit_homes.py BEST): -O3 -XS without a 32-bit candidate (homes.choose returns None)
        sc = {}
        def bump(d, k): sc[d] = sc.get(d, 0) + k
        def count(n, k=1, bound=None):
            if isinstance(n, list):
                for x in n: count(x, k, bound)
                return
            if not hasattr(n, 'k'): return
            if n.k == 'load' and strip(n.e).k == 'var' and n is not bound: bump(strip(n.e).decl, k)
            if n.k in ('incdec', 'opassign'):
                v = strip(n.e if n.k == 'incdec' else n.l)
                if v.k == 'var': bump(v.decl, 2 * k)
            if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': bump(strip(n.l).decl, k)
            if n.k == 'decl' and getattr(n, 'init', None) is not None: bump(n.var, k)
            for key, v in n.__dict__.items():
                if not (hasattr(v, 'k') or isinstance(v, list)): continue
                if n.k in ('while', 'for') and key == 'cond':
                    c = strip(v); b = None
                    if c.k == 'bin' and c.op in CC_S:
                        rb = strip(c.r)
                        while rb.k == 'cast': rb = strip(rb.e)
                        b = rb if rb.k == 'load' else None
                    count(v, 2 * k, b)
                else: count(v, k, bound)
        count(F.f.body)
        def stack_born(d): return d.kind == 'param' and not getattr(d, 'reg', None) and d not in getattr(F, 'homed_regs', {})
        born = {d: stack_born(d) for d in F.f.params}
        penal = 1 if (F.opt and not F.adecl) else 2            # cdecl -O homes a parameter read twice too (k_keep, rh_lp_x2)
        def score(d): return sc.get(d, 0) - (penal if born.get(d) else 0)
        call_res = set()
        walk(F.f.body, lambda n, dep: call_res.add(n.var) if n.k == 'decl' and getattr(n, 'init', None) is not None
             and has_helper_call(n.init) else None)
        walk(F.f.body, lambda n, dep: call_res.add(strip(n.l).decl) if n.k == 'bin' and n.op == '=' and
             strip(n.l).k == 'var' and has_helper_call(n.r) else None)
        if F.adecl:
            first = (params[0] if params else None) if XR_FIRST_LIVE else (F.f.params[0] if F.f.params else None)
            cands = [d for d in params if d is first and score(d) >= 1]   # (r1_05_01: a dies before the call, b is homed)
        else:
            cands = [d for d in F.f.params if not getattr(d, 'reg', None) and d in across and d.ty.kind in ('int', 'ptr')
                     and d.ty.size in (2, 4) and d is not F.sret and score(d) >= 1]
        cands += [d for d in locs if score(d) >= 1]
        ldecl = [d for d in F.f.decls if d.kind == 'local']
        mid = (len(ldecl) - 1) / 2.0
        def okey(d):
            if d.kind == 'param': return (-score(d), 1, 0, 0)
            i = ldecl.index(d) if d in ldecl else 0
            return (-score(d), 0, abs(i - mid), -i)
        order = sorted(cands, key=okey)
        winners = []
        if order and not F.xiz_vars:
            w1 = order[0]; winners = [w1]
            if w1.ty.size <= 2:
                rest = [d for d in order[1:] if d.ty.size <= 2]
                if rest:
                    w2 = rest[0]
                    if (w1.kind == 'local' and w2.kind == 'local') or w1 in call_res or w2 in call_res or \
                            score(w1) + score(w2) >= 5:
                        winners.append(w2)
        def dkey(d): return (0, F.f.params.index(d)) if d.kind == 'param' else (1, ldecl.index(d) if d in ldecl else 0)
        winners_sorted = sorted(winners, key=dkey)
    used = {'IZ': False, 'QIZ': False}; qizh = False
    for d in F.xiz_vars: used['IZ'] = used['QIZ'] = True
    moves = []; stores = []
    for d in winners_sorted:
        if d.ty.size == 4:
            if d.kind == 'param':
                src = FAM[d.reg][4] if getattr(d, 'reg', None) else d
                moves.append(('XIZ', src))
            d.reg = 'XIZ'; d.homed = True; used['IZ'] = used['QIZ'] = True; F.xiz_vars.append(d)
            continue
        r = h2home[d] if h2home is not None else ('IZ' if not used['IZ'] else 'QIZ')   # (homes2 names the half)
        if d.ty.size == 1 and CHAR_HOMES:
            if F.adecl and d.kind == 'param' and getattr(d, 'reg', None) in ('WA', 'BC', 'DE'):
                stores.append((d, FAM[d.reg][1])); d.home_slot = True; d.reg = None; continue   # r1_04_01: ld (XSP),A
            if used['QIZ'] or d.kind == 'param': raise Unsupported('char home')
            r = 'QIZH'; used['QIZ'] = True; qizh = True   # r1_05_05: char t = gp[2] -> ld QIZH,A ... ld A,QIZH
            d.reg = r; F.xiz_vars.append(d); continue
        if d.kind == 'param':
            src = FAM[d.reg][d.ty.size] if getattr(d, 'reg', None) else d
            moves.append((r, src))
        d.reg = r; used[r] = True; F.xiz_vars.append(d)
    for d in params:                                       # adecl register parameters that lost: a slot at entry
        if d not in winners and F.adecl and getattr(d, 'reg', None) in ('WA', 'BC', 'DE'):
            stores.append((d, FAM[d.reg][d.ty.size])); d.home_slot = True; d.reg = None
    if F.adecl:                                            # a float parameter is used through its address: a slot at
        for d in F.f.params:                               # entry (probes/adfp.c ad_fi: ld (XSP+0x2),XWA)
            if d.ty.kind == 'float' and d.ty.size == 4 and getattr(d, 'reg', None) in ('WA', 'BC', 'DE'):
                stores.append((d, FAM[d.reg][4])); d.home_slot = True; d.reg = None
    if F.opt:                                              # _strlen: ss = memchr(...) stays in XHL (no call after it)
        rets = []
        walk(F.f.body, lambda n, dep: rets.append(n) if n.k == 'return' and n.value is not None else None)
        from_call = set()                                  # _strcpy: endPtr = memccpy(...) is only tested: XHL too
        walk(F.f.body, lambda n, dep: from_call.add(strip(n.l).decl) if n.k == 'bin' and n.op == '=' and
             strip(n.l).k == 'var' and strip(n.r).k in ('call', 'cast') and has_helper_call(n.r) else None)
        hl = [d for d in F.f.decls if d.kind == 'local' and not getattr(d, 'reg', None) and d not in across and
              not d.addr_taken and d.ty.kind in ('int', 'ptr') and d.ty.size in (2, 4) and
              (any(uses_decl(r, d) for r in rets) or d in from_call)]
        def only_call_arg(d):                              # _fscanf: return _doscan(format, args, ...) reads args only
            for r in rets:                                 # as an argument, which the call's result replaces: XWA
                rv = strip(r.value)                        # (lda XWA,XSP+0xc / pushw ... / push XWA), not HL
                if not (rv.k == 'call' and any(uses_decl(a, d) for a in rv.args) and not uses_decl(rv.fn, d)): return False
            return d not in from_call and any(uses_decl(r, d) for r in rets)
        if len(hl) == 1 and ARG_LOCAL_WA and only_call_arg(hl[0]) and hl[0].ty.size == 4 and \
                not any(getattr(x, 'reg', None) == 'WA' for x in list(F.f.params) + list(F.f.decls)):
            hl[0].reg = 'WA'
        elif len(hl) == 1 and not any(getattr(x, 'reg', None) == 'HL' for x in list(F.f.params) + list(F.f.decls)):
            hl[0].reg = 'HL'
    pairs = []                                             # k_expr: r1(a) + r1(a + 1) keeps the right result in QIZ
    walk(F.f.body, lambda n, dep: pairs.append(n) if n.k == 'bin' and n.op in SIMPLE_OPS and strip(n.l).k == 'call'
         and strip(n.r).k == 'call' and not fpgen.is_fp(n.ty) else None)   # (cosh: exp(x) + exp(-x) are doubles
                                                                           # in frame slots, not a QIZ temporary)
    if pairs and any(n_.ty is not None and n_.ty.size == 4 for n_ in pairs):
        if not used['IZ'] and not used['QIZ']:         # evorder_ad.c ea_l_add_FF: two long calls keep the right result
            used['IZ'] = used['QIZ'] = True; F.call_temp = 'XIZ'   # in XIZ (push XIZ / cal _hfl / ld XIZ,XHL / cal _gfl /
            if not F.xiz_vars: F.xiz_vars.append(None)           # add XHL,XIZ); the 16-bit IZ was wrong code
    elif pairs:
        r = 'IZ' if not used['IZ'] else 'QIZ' if not used['QIZ'] else None
        if r:
            used[r] = True; F.call_temp = r
            if not F.xiz_vars: F.xiz_vars.append(None)
    if not (moves or stores or locs or pairs): return
    if F.xiz_vars and not any(l == '\tpush\tXIZ' for l in F.lines):
        F.save_reg = 'XIZ' if used['QIZ'] or (fpgen.uses_fp(F.f) and fpgen.has_elem_hoist(F)) else 'IZ'   # _log
        if qizh and not used['IZ'] and not (fpgen.uses_fp(F.f) and fpgen.has_elem_hoist(F)) and \
                all(getattr(d, 'reg', None) == 'QIZH' for d in F.xiz_vars if d is not None):
            F.save_reg = 'QIZ'                             # r1_05_19: only a char in QIZH -> push QIZ / pop QIZ
        F.emit('push', F.save_reg); F.push = 4 if F.save_reg == 'XIZ' else 2
    F.home_moves = moves; F.home_stores = stores

def homes2_choose(F, vals, setname):
    """the homes2 rule's register homes among plan_homes's candidates: {decl: 'IZ' | 'QIZ' | 'XIZ'}.  The rule
    sees the whole function (homes2.predict); what it may home is plan_homes's own across-a-call set `vals`
    (homes2.CANDIDATES 'model'), or also the locals the rule finds live across a call ('rule').  Everything else
    keeps plan_homes's bookkeeping: a losing adecl register parameter gets a slot store at entry, a losing cdecl
    parameter stays in its stack arrival, a losing local gets a frame slot."""
    regp = {d for d in F.f.params if getattr(d, 'reg', None) in ('WA', 'BC', 'DE')}
    H = homes2.predict(F.f, setname, regp)
    pool = [d for d in vals if not getattr(d, 'regtemp_pre', False)]
    if homes2.CANDIDATES == 'rule':
        pool += [d for d in F.f.decls if d.kind == 'local' and d not in vals and not getattr(d, 'reg', None)
                 and d.ty.size in (1, 2, 4) and d.ty.kind in ('int', 'ptr') and not d.addr_taken and
                 not getattr(d, 'regtemp_pre', False)]
    return {d: H[d] for d in pool if H.get(d) in ('IZ', 'QIZ', 'XIZ')}

def emit_homes(F):
    """after the frame is known: slot stores first, then the moves into IZ / XIZ (adecl.c d_keep).  A cdecl
    parameter is loaded at its first use instead (_strlen: pushw 0xffff / pushw 0x0 / ld XIZ,(XSP+0xc) / push XIZ;
    call.c k_seq, where the first use is the first instruction)"""
    F.lazy_homes = {}
    if HOMES_PARAM_ORDER and F.adecl:                      # adecl: stores and moves together in reverse parameter
        arr = {}                                           # order (d_keep: ld (XSP+0x2),BC / ld IZ,WA; ra_homes32.c
        for k_, p_ in enumerate(F.f.params):               # h_p_diff: ld IZ,BC / ld (XSP+0x6),XWA)
            if k_ < 3: arr[('WA', 'BC', 'DE')[k_]] = k_
        ops = []
        for d, r in getattr(F, 'home_stores', []):
            ops.append((F.f.params.index(d) if d in F.f.params else -1, -d.slot, ('ld', '(XSP+%s),%s' % (hx(d.slot + F.push), r))))
        for dst, src in getattr(F, 'home_moves', []):
            if not isinstance(src, str): F.lazy_homes[src] = dst; continue
            fam_ = family_of(src); fam_ = fam_[1:] if fam_ and fam_.startswith('X') else fam_
            ops.append((arr.get(fam_, -1), 0, ('ld', '%s,%s' % (dst, src))))
        for _, _, (op_, a_) in sorted(ops, key=lambda x: (-x[0], x[1])): F.emit(op_, a_)
        return
    for d, r in sorted(getattr(F, 'home_stores', []), key=lambda x: x[0].slot):   # ls_cl_noguard: ld (XSP+0x4),BC /
        F.emit('ld', '(XSP+%s),%s' % (hx(d.slot + F.push), r))                     # ld (XSP+0x6),WA
    for dst, src in getattr(F, 'home_moves', []):
        if not isinstance(src, str): F.lazy_homes[src] = dst; continue
        F.emit('ld', '%s,%s' % (dst, src))

def touch_home(F, d):
    """emit the deferred load of a homed cdecl parameter at its first use"""
    lh = getattr(F, 'lazy_homes', None)
    if lh and d in lh:
        dst = lh.pop(d); F.emit('ld', '%s,(XSP+%s)' % (dst, hx(d.off + F.push)))

def u1x_op(F, v):
    """plain -Xr (U1, u1_plain_global): a global array element indexed by the counter, its address built at each
    access in its own temporaries: ld BC,IX / add BC,BC / lda XDE,_ga -> (XDE+BC); a char lda XBC,_gca -> (XBC+IX)"""
    C, B = F.u1x['acc'][id(v)]; I = FAM[F.u1x['i'].reg][2]; esz = v.ty.size
    if isinstance(B, tuple): return '(%s+%s)' % (FAM[B[1].reg][4], I)   # oc_cpy_g under -Xr: ld (XWA+DE),C
    if C is not None:
        F.emit('ld', '%s,%s' % (FAM[C][2], I)); scale16(F, FAM[C][2], esz)
    F.emit('lda', '%s,_%s' % (FAM[B][4], strip(v.base).decl.name))
    return '(%s+%s)' % (FAM[B][4], FAM[C][2] if C is not None else I)

def cl_op(F, base):
    """the operand of a global array of the active -O counted loop ((XB+O), (XB+i)), or None"""
    cl = getattr(F, 'cl_active', None); b = strip(base)
    if not cl or b.k != 'var': return None
    if 'ops' in cl: return cl['ops'].get(b.decl)
    return F.cl_operand if b.decl is cl['arr'] else None

def regvar_of(e):
    v = strip(e)
    if v.k == 'var' and getattr(v.decl, 'reg', None) and v.decl.reg != 'XIZ': return v.decl
    return None

def operand(F, e, size, avoid=()):
    """an operand string for e, emitting address setup for indexed loads (ra_leaf: add HL,(XBC+WA))"""
    m = mem_operand(F, e)
    if m is not None: return m
    e0 = narrow(e, size)
    if getattr(F, 'u1x', None) and e0.k == 'load' and strip(e0.e).k == 'index' and id(strip(e0.e)) in F.u1x['acc']:
        return u1x_op(F, strip(e0.e))                    # plain -Xr ol_i_acc1: ld BC,IX / add BC,BC / lda XDE,_ga
    if getattr(F, 'cl_active', None) and e0.k == 'load' and strip(e0.e).k == 'index' and cl_op(F, strip(e0.e).base):
        if F.cl_active.get('bcse'):                        # ol_c_acc2: ld C,(XDE+IX) once, then add L,C / add B,C
            if not getattr(F, 'cl_tmp_done', False):
                F.emit('ld', '%s,%s' % (F.cl_active['bcse'], cl_op(F, strip(e0.e).base))); F.cl_tmp_done = True
            return F.cl_active['bcse']
        if getattr(F, 'cl_shared', False):                 # ol_i_acc2: lda XBC,XHL+DE / (XBC) (U1's first temporary)
            T = FAM[F.cl_active.get('tmp') if F.cl_active.get('tmp') in FAM else 'WA'][4]
            opnd = F.cl_operand.strip('()')
            clash = T[1:] in opnd.replace('X', ' ').split('+') or T in opnd.split('+')   # (ol_l_acc3: the offset in BC)
            if not getattr(F, 'cl_tmp_done', False) and (held_after(F, T[1:], e0) or clash):   # (ra_leaf3 -O3 -XS -Xr:
                busy_ = {x.lstrip('X') for x in opnd.split('+')}                        # k in WA, lda XWA,.. was
                T = FAM[free_reg(F, avoid={T[1:]} | busy_)][4]; F.cl_active['tmp'] = T[1:]   # wrong code)
            if not getattr(F, 'cl_tmp_done', False):
                F.emit('lda', '%s,%s' % (T, F.cl_operand.strip('()'))); F.cl_tmp_done = True
            return '(%s)' % T
        return cl_op(F, strip(e0.e).base)
    if e0.k == 'load' and strip(e0.e).k == 'deref' and strip(strip(e0.e).e).k == 'incdec' and strip(strip(e0.e).e).post:
        inc = strip(strip(e0.e).e); pm = mem_operand(F, inc.e) if False else None
        pv = strip(inc.e)
        if pv.k == 'var' and pv.decl.kind == 'param' and not getattr(pv.decl, 'reg', None):
            slot = '(XSP+%s)' % hx(pv.decl.off + F.push)            # ra_ptr: bump the pointer in place
            F.emit('ld', 'XBC,%s' % slot); F.emit('ld', 'XWA,%s' % hx(pv.ty.base.size))
            F.emit('add' if inc.op == '++' else 'sub', '%s,XWA' % slot); return '(XBC)'
    m = mem_operand(F, e0)
    if m is not None: return m
    if F.adecl and e0.k == 'load' and strip(e0.e).k == 'index' and not getattr(F, 'l2', None) and \
            not getattr(F, 'cl_active', None) and not getattr(F, 'u1_i', None):
        ea = elem_addr(F, strip(e0.e), 'load')             # .c_sum: add HL,(XDE)
        if ea is not None: return ea
    if e0.k == 'load' and strip(e0.e).k == 'index':
        v = strip(e0.e); b = strip(v.base); esz = v.ty.size
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            im = mem_operand(F, v.idx) or mem_operand(F, strip(v.idx))
            if im is None: raise Unsupported('complex index')
            if esz == 1 and im in ('BC', 'DE', 'HL'):          # ra_char: lda XWA,_gca / (XWA+BC)
                F.emit('lda', 'XWA,_%s' % b.decl.name); return '(XWA+%s)' % im
            if IDX_GUARD and (held_after(F, 'WA', e0) or held_after(F, 'BC', e0)):   # ra_leaf4 under -Xr: the bound
                raise Unsupported('index register holds a live variable')        # k in WA (wrong code before)
            if im in ('A', 'C', 'E', 'L', 'W', 'B', 'D', 'H'): raise Unsupported('byte index register')   # (r2_02_05 -Xr:
            F.emit('ld', 'WA,%s' % im)                                                                   # ld WA,A is no load)
            F.emit('add', 'WA,WA') if esz == 2 else F.emit('sla', '%s,WA' % hx({4: 2, 8: 3}[esz]))
            F.emit('lda', 'XBC,_%s' % b.decl.name); return '(XBC+WA)'
        if b.k == 'load' and fold(v.idx).k != 'const':      # c_sum: s += p[i] -> ... add XWA,(p) / add HL,(XWA)
            pm = mem_operand(F, b); ii = strip(v.idx)
            while ii.k == 'cast' and ii.kind == 'IntegralCast': ii = strip(ii.e)
            im = mem_operand(F, ii)
            if pm in ('XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ') and esz == 1 and ii.ty.signed and \
                    im in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ'):
                return '(%s+%s)' % (pm, im)                # lnr4.c h5 (-Xr): c ^= s[i] -> xor E,(XWA+HL)
            if pm is not None and pm.startswith('X') and family_of(pm) == 'WA':
                raise Unsupported('element through a pointer in XWA')   # (h5: add XWA,XWA was wrong code)
            if pm is not None and im is not None and 'WA' not in avoid:
                F.emit('ld', 'WA,%s' % im); F.emit('exts' if ii.ty.signed else 'extz', 'XWA')
                if esz == 2: F.emit('add', 'XWA,XWA')
                elif esz > 2: F.emit('sll', '%s,XWA' % hx({4: 2, 8: 3}[esz]))
                F.emit('add', 'XWA,%s' % pm); return '(XWA)'
    return None

def u1_held_stmt(F, e):
    """two int arrays through pointer parameters indexed by the counter (U1's held copy): the index is scaled
    once in the chain register, copied into the held register for the first array's address, the second element
    loaded through the chain (oc_add2: ld HL,IX / exts XHL / add XHL,XHL / ld XIY,XHL / add XIY,XWA / add XHL,XBC /
    ld HL,(XHL) / add (XIY),HL; oc_sum2: ... / ld IX,(XIX) / muls XIX,(XIZ) / add HL,IX)"""
    def elem(x):
        x = strip(x)
        if x.k != 'load' or strip(x.e).k != 'index': return None
        v = strip(x.e); b = strip(v.base); ix = strip(v.idx)
        while ix.k == 'cast': ix = strip(ix.e)
        if v.ty.size != 2 or b.k != 'load' or not regvar_of(b.e) or ix.k != 'load' or strip(ix.e).k != 'var' or \
                strip(ix.e).decl is not F.u1_i: return None
        return regvar_of(b.e)
    T = F.u1_chain; H = F.u1_held; XT = FAM[T][4]; XH = FAM[H][4]; I = FAM[F.u1_i.reg][2]
    def addrs(p, q):
        F.emit('ld', '%s,%s' % (FAM[T][2], I)); F.emit('exts', XT); F.emit('add', '%s,%s' % (XT, XT))
        F.emit('ld', '%s,%s' % (XH, XT)); F.emit('add', '%s,%s' % (XH, FAM[p.reg][4]))
        if not F.opt:                                    # plain -Xr recomputes the scaled index (oc_add2)
            F.emit('ld', '%s,%s' % (FAM[T][2], I)); F.emit('exts', XT); F.emit('add', '%s,%s' % (XT, XT))
        F.emit('add', '%s,%s' % (XT, FAM[q.reg][4])); F.emit('ld', '%s,(%s)' % (FAM[T][2], XT))
    if e.k == 'opassign' and e.op in SIMPLE_OPS and strip(e.l).k == 'index':
        p = elem(u1_load_node(e.l)); q = elem(e.r)
        if p is None or q is None or p is q: return False
        addrs(p, q); F.emit(SIMPLE_OPS[e.op], '(%s),%s' % (XH, FAM[T][2])); return True
    if e.k == 'opassign' and e.op in '+-' and regvar_of(e.l) and regvar_of(e.l).ty.size == 2:
        r = strip(e.r)
        if r.k != 'bin' or r.op not in ('*', '+'): return False
        p = elem(r.l); q = elem(r.r)
        if p is None or q is None or p is q: return False
        addrs(p, q)
        if r.op == '*': F.emit('muls', '%s,(%s)' % (XT, XH))
        else: F.emit('add', '%s,(%s)' % (FAM[T][2], XH))
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (FAM[regvar_of(e.l).reg][2], FAM[T][2])); return True
    return False

def u1_cse_if(F, s):
    """if (p[i] > m) m = p[i]; under U1: the element is loaded once, into the chain register itself (oc_max:
    ld DE,(XDE) / cp DE,HL / j le,L2 / ld HL,DE / L2:)"""
    c = strip(s.cond); th = flat(s.then)
    if c.k != 'bin' or c.op not in CC_S or len(th) != 1 or th[0].k != 'expr': return False
    a = th[0].e
    if a.k != 'bin' or a.op != '=' or not regvar_of(a.l) or regvar_of(a.l).ty.size != 2: return False
    def key(x):
        x = strip(x)
        if x.k != 'load' or strip(x.e).k != 'index' or x.ty.size != 2: return None
        v = strip(x.e); b = strip(v.base); ix = strip(v.idx)
        while ix.k == 'cast': ix = strip(ix.e)
        if b.k != 'load' or not regvar_of(b.e) or ix.k != 'load' or strip(ix.e).k != 'var' or \
                strip(ix.e).decl is not F.u1_i: return None
        return regvar_of(b.e)
    m = regvar_of(a.l)
    if key(c.l) is None or key(c.l) is not key(a.r) or not (strip(c.r).k == 'load' and regvar_of(strip(c.r).e) is m):
        return False
    op = u1_operand(F, strip(strip(c.l).e))
    if op is None: return False
    T = FAM[F.u1_chain][2]; M = FAM[m.reg][2]
    F.emit('ld', '%s,%s' % (T, op)); F.emit('cp', '%s,%s' % (T, M))
    lab = F.newulabel()
    F.emit('j', '%s,%s' % (INV[(CC_S if c.l.ty.signed else CC_U)[c.op]], lab))
    F.emit('ld', '%s,%s' % (M, T)); F.lines.append(lab + ':')
    return True

def u1_load_node(lv):
    from frontend import N
    return N('load', e=lv, ty=strip(lv).ty)

def regvar_stmt(F, e):
    """assignments to register variables: v = x, v op= x, v++ (ra_leaf, ctrl)"""
    if e.k in ('opassign', 'incdec') and regvar_of(e.l if e.k == 'opassign' else e.e):
        touch_home(F, regvar_of(e.l if e.k == 'opassign' else e.e))   # (r2_08_15)
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l) and regvar_of(e.l).reg == 'QIZH':
        if strip(e.r).k == 'call':                          # lo_c_Rca: cal _rc / ld QIZH,L
            gen_call(F, strip(e.r)); flush_pops(F); F.emit('ld', 'QIZH,L'); return True
        f_ = gen(F, narrow(e.r, 1), 'WA', 1)                # r2_00_13: char t = gc2 -> ld A,(_gc2) / ld QIZH,A
        F.emit('ld', 'QIZH,%s' % FAM[f_][1]); return True   # (ld QIZH,(_gc2) is not an instruction)
    if F.opt and e.k == 'opassign' and e.op in '+-' and regvar_of(e.l) and regvar_of(e.l).ty.size == 2 and \
            getattr(F, 'tkind', None) == 'word' and strip(e.r).k == 'bin':
        d = regvar_of(e.l); T = F.tfam                     # op_sum2: s += *p++ + *q++ -> ld IX,(XBC+:2) /
        gen(F, e.r, T, 2)                                  # add IX,(XWA+:2) / add HL,IX
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (FAM[d.reg][2], FAM[T][2])); return True
    if e.k == 'opassign' and e.op in '+-' and regvar_of(e.l) and regvar_of(e.l).ty.size == 2 and \
            getattr(F, 'u1_i', None) is not None and getattr(F, 'tfam', None) and strip(e.r).k == 'cast' and \
            strip(strip(e.r).e).k == 'load' and strip(strip(e.r).e).ty.size == 1:
        d = regvar_of(e.l); T = F.tfam                     # oc_sum_c: s += p[i] -> ld C,(XWA+IX) / exts BC / add HL,BC
        gen(F, strip(strip(e.r).e), T, 1); F.emit('exts' if strip(strip(e.r).e).ty.signed else 'extz', FAM[T][2])
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (FAM[d.reg][2], FAM[T][2])); return True
    if e.k == 'opassign' and e.op in '+-' and regvar_of(e.l) and regvar_of(e.l).ty.size == 2 and \
            char_arith(e.r) and getattr(F, 'tfam', None):
        d = regvar_of(e.l); T = F.tfam                     # opt_temps.c ot_sum: s += *a++ - *b++ ->
        gen(F, narrow(e.r, 1), T, 1); F.emit('exts', FAM[T][2])   # ld A,(XHL+:1) / sub A,(XBC+:1) / exts WA /
        F.emit(SIMPLE_OPS[e.op], '%s,%s' % (FAM[d.reg][2], FAM[T][2])); return True   # add IX,WA
    if e.k == 'bin' and e.op == '=' and strip(e.l).k == 'var' and getattr(strip(e.l).decl, 'reg', None) == 'XIZ' \
            and getattr(F, 'l2', None) and mem_operand(F, e.r) is not None and strip(e.r).k != 'call':
        F.emit('ld', 'XIZ,%s' % mem_operand(F, e.r)); return True     # _strrev: p = s -> ld XIZ,(XSP+0x8)
    if e.k == 'bin' and e.op == '=' and strip(e.l).k == 'var' and getattr(strip(e.l).decl, 'reg', None) == 'XIZ' \
            and getattr(strip(e.l).decl, 'homed', False) and strip(e.r).k == 'call':
        gen_call(F, strip(e.r)); flush_pops(F); F.emit('ld', 'XIZ,XHL'); return True   # _calloc: ptr = malloc(...)
    hz = strip(e.l).decl if e.k in ('bin', 'opassign') and strip(e.l).k == 'var' and \
        getattr(strip(e.l).decl, 'reg', None) == 'XIZ' and getattr(strip(e.l).decl, 'homed', False) and \
        strip(e.l).decl.ty.size == 4 else None
    if HOMED_WRITES and hz is not None and e.k == 'bin' and e.op == '=' and \
            (mem_operand(F, e.r) or '').startswith(('(_', '(S')):
        F.emit('ld', 'XIZ,%s' % mem_operand(F, e.r)); return True   # _strtok: s1 = save -> ld XIZ,(S1)
    if HOMED_WRITES and hz is not None and e.k == 'opassign' and e.op in '+-' and hz.ty.is_ptr() and \
            hz.ty.base.size == 1:
        r0 = strip(e.r)
        while r0.k == 'cast' and r0.kind == 'IntegralCast': r0 = strip(r0.e)
        if r0.k == 'call' and not has_helper_call(r0.fn) and r0.ty.size == 2:
            gen_call(F, r0); flush_pops(F)               # _strtok: s1 += strspn(s1, s2) -> cal _strspn /
            F.emit('extz' if not r0.ty.signed else 'exts', 'XHL')   # inc 0x8,XSP / extz XHL / add XIZ,XHL
            F.emit(SIMPLE_OPS[e.op], 'XIZ,XHL'); return True
    if HOMED_WRITES and hz is not None and e.k in ('bin', 'opassign'):
        raise Unsupported('write to a variable homed in XIZ')   # (its slot is not its home: wrong code)
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l) and not F.opt and regvar_of(e.l).ty.is_ptr() and \
            (strip(e.r).k == 'bin' and strip(e.r).op in '+-' or
             strip(e.r).k == 'addr' and getattr(regvar_of(e.l), 'regtemp', False)) and regvar_of(e.l).reg != 'WA':
        d = regvar_of(e.l)                             # va_start without -O: lda XWA,XSP+0x4 / inc 0x2,XWA /
        f2 = gen(F, e.r, 'WA', 4)                       # ld XBC,XWA
        m_ = re.match(r'^\tinc\t(0x[0-9a-f]+),XWA$', F.lines[-1]) if F.lines else None
        if F.opt and f2 == 'WA' and m_ and getattr(d, 'regtemp', False):   # -O: lda XBC,XWA+0x1 (lo_p_Bgs O3XS)
            F.lines.pop(); F.emit('lda', '%s,XWA+%s' % (FAM[d.reg][4], m_.group(1))); return True
        F.emit('ld', '%s,%s' % (FAM[d.reg][4], FAM[f2][4])); return True
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l) and getattr(F, 'l2', None):
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2)); r0 = strip(e.r)
        if r0.k == 'addr' and d.ty.size == 4 and l2_elem_addr(F, r0) is not None:   # p = &buf[16] -> lda XIY,XIZ+0x10
            F.emit('lda', '%s,%s' % (R, l2_elem_addr(F, r0))); return True
        if d.reg.startswith('Q'):                          # u = val with u in QBC -> ld WA,(val) / ld QBC,WA
            m = operand(F, e.r, 2)
            if m is not None and m.startswith('('):
                F.emit('ld', 'WA,%s' % m); F.emit('ld', '%s,WA' % R); return True
        while r0.k == 'cast' and r0.kind == 'IntegralCast' and strip(r0.e).ty.size == r0.ty.size: r0 = strip(r0.e)
        if r0.k == 'bin' and r0.op in ('+', '-') and strip(r0.l).k == 'call' and fold(r0.r).k == 'const' and \
                d.ty.size == 2:                            # _strrchr: i = strlen(s) + 1 -> cal _strlen / inc 0x4,XSP /
            gen_call(F, strip(r0.l)); flush_pops(F)         # inc 0x1,HL / ld BC,HL
            k = fold(r0.r).value
            if 1 <= k <= 8: F.emit('inc' if r0.op == '+' else 'dec', '%s,HL' % hx(k))
            else: F.emit(SIMPLE_OPS[r0.op], 'HL,%s' % hx(k))
            if R != 'HL': F.emit('ld', '%s,HL' % R)
            return True
        if r0.k == 'bin' and r0.op == '-' and d.ty.size == 4 and r0.ty.is_ptr() and fold(r0.r).k == 'const' and \
                strip(r0.l).k == 'bin' and strip(r0.l).op == '+':
            pl, il = strip(strip(r0.l).l), strip(strip(r0.l).r)   # _strrev: q = p + strlen(p) - 1 -> cal _strlen /
            while il.k == 'cast' and il.kind == 'IntegralCast': il = strip(il.e)   # inc 0x4,XSP / extz XHL /
            pv = strip(pl.e) if pl.k == 'load' else None            # ld XIX,XHL / add XIX,XIZ / dec 0x1,XIX
            if il.k == 'call' and pv is not None and pv.k == 'var' and getattr(pv.decl, 'reg', None):
                gen_call(F, il); flush_pops(F)
                F.emit('exts' if il.ty.signed else 'extz', 'XHL'); F.emit('ld', '%s,XHL' % R)
                F.emit('add', '%s,%s' % (R, 'XIZ' if pv.decl.reg == 'XIZ' else FAM[pv.decl.reg][4]))
                k = fold(r0.r).value * r0.ty.base.size
                F.emit('dec' if 1 <= k <= 8 else 'sub', '%s,%s' % (hx(k), R) if 1 <= k <= 8 else '%s,%s' % (R, hx(k)))
                return True
        if r0.k == 'bin' and r0.op == '+' and d.ty.size == 4 and r0.ty.is_ptr() and r0.ty.base.size == 1:
            pl, il = strip(r0.l), strip(r0.r)              # _strrchr: s0 = s + i -> lda XHL,XIZ+BC
            while il.k == 'cast' and il.kind == 'IntegralCast': il = strip(il.e)
            pv = strip(pl.e) if pl.k == 'load' else None; iv = strip(il.e) if il.k == 'load' else None
            pd = pv.decl if pv is not None and pv.k == 'var' and getattr(pv.decl, 'reg', None) else None
            idd = iv.decl if iv is not None and iv.k == 'var' and getattr(iv.decl, 'reg', None) else None
            if pd is not None and idd is not None and idd.ty.size == 2:
                F.emit('lda', '%s,%s+%s' % (R, 'XIZ' if pd.reg == 'XIZ' else FAM[pd.reg][4], FAM[idd.reg][2])); return True
    if e.k == 'bin' and e.op == '=' and regvar_of(e.l):
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        rc = fold(narrow(e.r, d.ty.size))
        if getattr(F, 'l2', None): F.l2.setdefault('const', {}).pop(d, None)
        if rc.k == 'const':
            if getattr(F, 'l2', None) and not F.loops: F.l2['const'][d] = rc.value
            F.emit('ld', '%s,%s' % (R, imm_of(rc, d.ty.size))); return True   # .sw_local: -1 is 0xffff; r3_02_11: ~255 is 0
        m = operand(F, e.r, d.ty.size)
        if m is not None: F.emit('ld', '%s,%s' % (R, m)); return True
        if strip(e.r).k == 'call':                     # k_keep: cal .r1 / ld QIZ,HL (cdecl: inc 0x2,XSP first)
            gen_call(F, strip(e.r))
            nx = getattr(F, 'next_stmt', None)
            nxc = strip(nx.e) if nx is not None and nx.k == 'expr' else None
            if R != FAM['HL'][d.ty.size] and (F.opt or nxc is None or nxc.k != 'call' or not nxc.args):
                flush_pops(F)       # (_strcpy: a local in XHL needs no move, the pops wait); h_p: cdecl merges the
                                    # pops with the next call's when that call has arguments (inc 0x4,XSP after _g2)
            F.emit('ld', '%s,%s' % (R, FAM['HL'][d.ty.size])); return True
        r0 = strip(e.r)
        ops = []; x = r0
        while x.k == 'bin' and x.op in SIMPLE_OPS and not x.ty.is_ptr():
            ops.append((x.op, narrow(x.r, 2))); x = strip(narrow(x.l, 2))
        if d.reg == 'IZ' and d.ty.size == 2 and len(ops) >= 2 and x.k == 'load' and regvar_of(x.e) is None \
                and mem_operand(F, x) is not None and all(mem_operand(F, o) is not None or fold(o).k == 'const' for _, o in ops):
            F.emit('ld', 'IZ,%s' % mem_operand(F, x))      # ch_loc3: ld IZ,(_gj) / add IZ,(_gk) / add IZ,(_gm)
            for op, o in reversed(ops):
                F.emit(SIMPLE_OPS[op], 'IZ,%s' % (mem_operand(F, o) if fold(o).k != 'const' else hx(fold(o).value)))
            return True
        if d.reg in ('IZ', 'QIZ') and d.ty.size == 2 and r0.k == 'bin' and r0.op in SIMPLE_OPS:
            lm = mem_operand(F, narrow(r0.l, 2)); rc = fold(narrow(r0.r, 2)); rm = mem_operand(F, narrow(r0.r, 2))
            if lm is not None and (rm is not None or rc.k == 'const'):
                if rc.k == 'const' and r0.op in '+-' and 1 <= (rc.value or 0) <= 8:
                    F.emit('ld', '%s,%s' % (R, lm))        # rh_l1 / rh_lp_x2: ld IZ,WA / inc 0x1,IZ; ld QIZ,IZ / inc 0x1,QIZ
                    F.emit('inc' if r0.op == '+' else 'dec', '%s,%s' % (hx(rc.value), R)); return True
                if d.reg == 'IZ':                          # rh_ll: ld IZ,WA / add IZ,BC
                    F.emit('ld', 'IZ,%s' % lm); F.emit(SIMPLE_OPS[r0.op], 'IZ,%s' % (rm if rm is not None else hx(rc.value)))
                    return True
                lv = regvar_of(strip(narrow(r0.l, 2)).e) if strip(narrow(r0.l, 2)).k == 'load' else None
                if lv is not None and lv.reg in ('WA', 'BC', 'DE', 'HL') and dies_here(F, strip(narrow(r0.l, 2))):
                    L = FAM[lv.reg][2]                     # rh_ll: ld QIZ,WA / sub WA,BC / ld QIZ,WA (QIZ takes no arithmetic)
                    F.emit('ld', 'QIZ,%s' % L)
                    F.emit(SIMPLE_OPS[r0.op], '%s,%s' % (L, rm if rm is not None else hx(rc.value)))
                    F.emit('ld', 'QIZ,%s' % L); return True
        if getattr(F, 'l2', None) and r0.k == 'bin' and r0.op in ('+', '-') and d.ty.size == 2:
            a0, b0 = strip(narrow(r0.l, 2)), strip(narrow(r0.r, 2))   # _atoi: num = num * 10 + (c - '0') ->
            if a0.k == 'bin' and a0.op == '*' and strip(a0.l).k == 'load' and regvar_of(strip(a0.l).e) is d and \
                    fold(a0.r).k == 'const' and b0.k == 'bin' and b0.op in ('+', '-') and fold(b0.r).k == 'const' and \
                    strip(b0.l).k == 'load' and regvar_of(strip(b0.l).e) and (dies_here(F, strip(b0.l)) or
                                                                     regvar_of(strip(b0.l).e) in F.l2.get('body', ())):
                w = regvar_of(strip(b0.l).e); Wr = FAM[w.reg][2]           # sub DE,0x30 / muls XIY,0xa / add IY,DE
                F.emit(SIMPLE_OPS[b0.op], '%s,%s' % (Wr, hx(fold(b0.r).value)))
                F.emit('muls' if d.ty.signed else 'mul', 'X%s,%s' % (d.reg, hx(fold(a0.r).value)))
                F.emit(SIMPLE_OPS[r0.op], '%s,%s' % (R, Wr)); return True
        if getattr(F, 'l2', None) and r0.k == 'bin' and r0.op in ('+', '-') and d.ty.size == 4:
            a0, b0 = strip(r0.l), strip(r0.r)              # _atol: num = num * 10 + (c - '0') with num long ->
            bw = b0                                         # sub DE,0x30 / ld WA,DE / exts XWA / ld XDE,XIY /
            while bw.k == 'cast' and bw.kind == 'IntegralCast': bw = strip(bw.e)   # sla 0x2,XDE / add XDE,XIY /
            if a0.k == 'bin' and a0.op == '*' and strip(a0.l).k == 'load' and regvar_of(strip(a0.l).e) is d and \
                    fold(a0.r).k == 'const' and bw.k == 'bin' and bw.op in ('+', '-') and fold(bw.r).k == 'const' and \
                    strip(bw.l).k == 'load' and regvar_of(strip(bw.l).e) and strip(bw.l).ty.size == 2 and \
                    regvar_of(strip(bw.l).e) in F.l2.get('body', ()) and F.l2.get('t1') == 'WA':   # add XDE,XDE /
                w = regvar_of(strip(bw.l).e); Wr = FAM[w.reg][2]                                   # ld XIY,XDE /
                F.emit(SIMPLE_OPS[bw.op], '%s,%s' % (Wr, hx(fold(bw.r).value)))                    # add XIY,XWA
                F.emit('ld', 'WA,%s' % Wr); F.emit('exts' if bw.ty.signed else 'extz', 'XWA')
                fam = gen(F, a0, w.reg, 4)
                F.emit('ld', '%s,%s' % (R, FAM[fam][4])); F.emit(SIMPLE_OPS[r0.op], '%s,XWA' % R); return True
        tgt = d.reg if d.reg in ('BC', 'DE', 'HL', 'WA') else 'WA'      # ra_noloop3: ld DE,(a) / add DE,(b)
        if getattr(d, 'regtemp', False) and d.ty.size == 1 and strip(e.r).k not in ('load', 'const'):
            tgt = 'WA'                                     # (lo_c_Bgs: ld A,(_gc) / add A,(_hc) / ld C,A)
        rb_ = strip(e.r)
        if REGTEMP_OPT_SCRATCH and getattr(d, 'regtemp', False) and F.opt and d.ty.size in (2, 4) and tgt in ('WA', 'BC', 'DE', 'HL') and \
                rb_.k == 'bin' and rb_.op in ('+', '-', '&', '|', '^') and not rb_.ty.is_ptr() and \
                mem_operand(F, rb_.r) is not None and fold(rb_.r).k != 'const' and mem_operand(F, rb_.l) is not None and \
                fold(rb_.l).k != 'const' and not family_of(mem_operand(F, rb_.r)) and not family_of(mem_operand(F, rb_.l)):
            sc_ = 'WA' if tgt != 'WA' else 'BC'            # -O: the source into a scratch register first (lo_i_Bgd:
            F.emit('ld', '%s,%s' % (FAM[sc_][d.ty.size], mem_operand(F, rb_.r)))   # ld WA,(_hi) / ld BC,(_gi) / add BC,WA)
            F.emit('ld', '%s,%s' % (R, mem_operand(F, rb_.l)))
            F.emit(SIMPLE_OPS[rb_.op], '%s,%s' % (R, FAM[sc_][d.ty.size])); return True
        fam = gen(F, e.r, tgt, d.ty.size)
        if FAM[fam][d.ty.size] != R: F.emit('ld', '%s,%s' % (R, FAM[fam][d.ty.size]))
        return True
    if e.k == 'opassign' and regvar_of(e.l) and e.op in ('<<', '>>') and fold(e.r).k == 'const' and \
            fold(e.r).value is not None and 1 <= fold(e.r).value <= 16 and regvar_of(e.l).reg in FAM:
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))   # cond_bits.c cb_while: x >>= 1 with x
        mn = ('sla' if d.ty.signed else 'sll') if e.op == '<<' else ('sra' if d.ty.signed else 'srl')   # in WA ->
        F.emit(mn, '%s,%s' % (hx(fold(e.r).value), R)); return True                                     # srl 0x1,WA
    if e.k == 'opassign' and regvar_of(e.l) and e.op in SIMPLE_OPS:
        d = regvar_of(e.l); R = FAM[d.reg].get(d.ty.size, FAM[d.reg].get(2))
        rc = fold(narrow(e.r, d.ty.size))
        if e.op in '+-' and rc.k == 'const' and 1 <= rc.value <= 8:
            F.emit('inc' if e.op == '+' else 'dec', '%s,%s' % (hx(rc.value), R)); return True
        rw = strip(e.r); cx = strip(rw.e) if rw.k == 'cast' and rw.kind == 'IntegralCast' else None
        cv = regvar_of(cx.e) if cx is not None and cx.k == 'load' and cx.ty.size == 1 else None
        if F.opt and d.ty.size == 2 and cv is not None and cv is not d and cv.reg in ('WA', 'BC', 'DE', 'HL') and \
                dies_here(F, cx):                      # assign_expr.c ae_c_loop (-O): n += c, c dying in C ->
            W = FAM[cv.reg][2]; F.dead.add(cv)         # exts BC / add HL,BC
            F.emit('exts' if cx.ty.signed else 'extz', W); F.emit(SIMPLE_OPS[e.op], '%s,%s' % (R, W)); return True
        n_op = len(F.lines)
        m = operand(F, e.r, d.ty.size)
        if STORE_ADDR_GUARD and m is not None and d.reg in FAM and clobbers(F.lines[n_op:], '(%s)' % (FAM[d.reg].get(4) or d.reg)):
            raise Unsupported('the operand overwrites the op= variable')   # (lnr4.c h5 -O3 -XS: c in A, s[i] in XWA)
        if m is None:                                  # ra_param3: s += b * c -> WA, then add HL,WA
            T = getattr(F, 'u1_value', None) or getattr(F, 'tfam', None) or 'WA'   # U1's value temporary (ol_idx_use:
            if T == 'WA' and 'WA' in live_regs(F, except_decl=d):   # ld BC,(XIX+DE) / muls XBC,IY); else the loop's T
                T = free_reg(F, avoid={'WA', d.reg})                 # (abi adecl.c d_ptr: ld E,(XWA+:1); A would
                                                                     # overwrite p)
            if strip(e.r).k == 'call' and R.startswith('Q'):
                gen_call(F, strip(e.r)); flush_pops(F); m = FAM['HL'][d.ty.size]   # (the result stays in HL)
            elif strip(e.r).k == 'call' and not has_helper_call(strip(e.r).fn) and d.ty.size in (2, 4) and \
                    OPASSIGN_CALL_HL and R != FAM['HL'][d.ty.size]:
                gen_call(F, strip(e.r)); m = FAM['HL'][d.ty.size]   # homes2b.c HL05: a += g1(c) -> cal _g1 / add IZ,HL
                                                                     # (the pops wait for the next call's)
            else:
                fam = gen(F, e.r, T, d.ty.size); m = FAM[fam][d.ty.size]
        if R.startswith('Q') and d.ty.size == 2:           # ra_homes.c rh_loop: s += g1(i) with s in QIZ ->
            W = 'WA' if m not in ('WA', 'A') else 'BC'     # ld WA,QIZ / add WA,HL / ld QIZ,WA (QIZ is never the
            F.emit('ld', '%s,%s' % (W, R)); F.emit(SIMPLE_OPS[e.op], '%s,%s' % (W, m)); F.emit('ld', '%s,%s' % (R, W))
            return True                                    # destination of arithmetic)
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
        k = getattr(F, 'l2', None) and F.l2.setdefault('const', {})
        if k and d in k:                                 # _itoa: sign = 0 ... sign++ -> ld IX,0x1
            v = k.pop(d) + (step if e.op == '++' else -step); F.emit('ld', '%s,%s' % (R, hx(v & 0xffff))); return True
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

def return_table(F, s, vals, lo, hi):
    """-O: a dense switch from 0 whose every case and default is `return constant` (bytes) becomes a byte table with
    the default's value as one more entry (abi switch.c sw_dense, either ABI: cp WA,0x0 / j m,L1 / cp WA,0x5 /
    j le,L2 / L1: ld WA,0x6 / L2: lda XIX,S / ld L,(XIX+WA) / exts HL / ret).  Returns (byval, default) or None"""
    if not F.opt or lo != 0: return None
    if sorted(v for v, _, _ in vals) != list(range(lo, hi + 1)): return None
    items = flat(s.body) if s.body.k == 'block' else [s.body]
    byval = {}; dflt = None
    for c in items:
        if c.k not in ('case', 'default'): return None
        b = c.body
        if b is None or b.k != 'return' or b.value is None: return None
        v = fold(b.value)
        if v.k != 'const' or v.value is None or not -128 <= v.value <= 127: return None
        if c.k == 'default': dflt = v.value
        else: byval[data_value(c.value)] = v.value
    if dflt is None or F.f.ret is None or F.f.ret.size != 2: return None
    return byval, dflt

def value_table(F, s, cases, vals, default, lo, hi):
    """cdecl -O3 -XS: a dense switch whose every case is `f(constant); break;` with one f and no default, and no
    hole, becomes a byte table of the constants (not under -Xr: switch.c O3XSXr keeps the jump table)"""
    if not F.opt or F.adecl: return None
    if sorted(v for v, _, _ in vals) != list(range(lo, hi + 1)): return None
    items = flat(s.body) if s.body.k == 'block' else [s.body]
    fn = None; byval = {}
    i = 0
    while i < len(items):
        c = items[i]
        if c.k == 'default':                             # sw_jt6d: default: f0(); break; after the table call
            F.vt_default = c; i += 2 if i + 1 < len(items) and items[i + 1].k == 'break' else 1; continue
        if c.k != 'case': return None
        body = c.body
        isret = body is not None and body.k == 'return' and body.value is not None and strip(body.value).k == 'call'
        if body is None or not (isret or (body.k == 'expr' and strip(body.e).k == 'call')): return None
        call = strip(body.value if isret else body.e); f = strip(call.fn)
        if f.k != 'var' or len(call.args) != 1 or fold(call.args[0]).k != 'const': return None
        k = fold(call.args[0]).value
        if not -128 <= k <= 127: return None
        if fn is None: fn = f; F.vt_ret = isret
        elif f.decl is not fn.decl or F.vt_ret != isret: return None
        if isret: byval[data_value(c.value)] = k; i += 1; continue   # sw_ret: case k: return g1(k + 1);
        if i + 1 >= len(items) or items[i + 1].k != 'break': return None
        byval[data_value(c.value)] = k; i += 2
    return (fn, byval) if fn is not None else None

def gen_switch(F, s, last):
    """switch (oracle run 2026-11-09-4-micro-switch, v423, -Xr and -O3 -XS -Xr).
    Six or more case values spanning at most twice their number: a jump table of 16-bit offsets from a base label
    (dw Lcase-Lbase, holes to the default), placed in f_const right after the function label; the selector is
    range-checked (sub lo, then cp R,0 / j lt; without sub cp R,0 / j m; unsigned only cp R,hi / j ugt) and
    dispatched with add R,R / lda XIX,S / ld R,(XIX+R) / lda XIX,Lbase / j XIX+R (long: add XR,XR / add XR,S /
    ld R,(XR)).  Otherwise a compare chain: single values from the highest down (cp R,v / j eq,Lv), runs of three
    or more values with one body as ranges (cp R,hi / j gt / cp R,lo / j ge,Lbody); the last single value is
    tested inverted and falls into its body; a char selector is extended to a word first (exts / extz WA).
    A selector variable that a case body also reads is copied to a free register without -O (sw_local: ld BC,WA)."""
    cases = switch_cases(s.body, [])
    in_loop_last = bool(F.loops) and getattr(F, 'next_stmt', 'x') is None   # (the last statement of a loop body)
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
    nv = len([c for c in cases if c.k != 'default'])
    vv = [data_value(c.value) for c in cases if c.k != 'default']
    will_table = nv >= 6 and None not in vv and max(vv) - min(vv) + 1 <= 2 * nv
    if e.k == 'cast' and e.kind == 'IntegralCast' and strip(e.e).ty.size == 1:
        ext = 'exts' if strip(e.e).ty.signed else 'extz'; e = strip(e.e)
        if not will_table and mem_operand(F, e) is not None:
            ext = None; chain_char = True                  # sw_char: a chain compares A itself (cp A,0x65; from memory
                                                           # too, every set: ld A,(XSP+0x4) / cp A,0x65)
    size = max(2, e.ty.size) if ext or will_table or e.ty.size != 1 else 1
    signed = strip(s.value).ty.signed
    m = mem_operand(F, e)
    sel = strip(e.e).decl if e.k == 'load' and strip(e.e).k == 'var' else None
    in_body = sel is not None and uses_decl(s.body, sel)
    if F.opt and not F.adecl and nv == 1 and default is None and m is not None and m.startswith('(') and \
            e.ty.size == 2 and not ext and not in_body:   # sw_one under O3XS: cpw (XSP+0x4),0x7 / ret ne
        exit_is_ret = last and not F.pushes and not F.xiz_vars and not getattr(F, 'frame', 0) and not F.pending
        F.emit('cpw', '%s,%s' % (m, hx(vv[0] & 0xffff)))
        if exit_is_ret: F.emit('ret', 'ne'); F.ret_refs = getattr(F, 'ret_refs', set()) | {end}
        else: F.emit('j', 'ne,%s' % end)
        F.case_labels[id(vals[0][2])] = None
        F.loops.append((end, F.loops[-1][1] if F.loops else (lambda: end)))
        for it in (flat(s.body) if s.body.k == 'block' else [s.body]): gen_stmt(F, it, False)
        F.loops.pop(); F.lines.append(end + ':'); return
    if m is not None and family_of(m) and not ext:
        R = FAM[family_of(m)[1:] if family_of(m) != 'XIZ' else 'IZ'][size]
        keep = in_body or (sel is not None and sel.reg in ('IZ', 'QIZ', 'XIZ'))   # sw_loop: ld WA,IZ
        n_ = len(vals); lo_ = min(v for v, _, _ in vals) if vals else 0; hi_ = max(v for v, _, _ in vals) if vals else 0
        is_tab = n_ >= 6 and hi_ - lo_ + 1 <= 2 * n_       # (a jump table; a compare chain keeps the register: sw_ev)
        if keep and (not F.opt or (F.adecl and in_body and is_tab and sel is not None and sel.reg in ('WA', 'BC', 'DE'))):
            used = {getattr(d, 'reg', None) for d in list(F.f.params) + list(F.f.decls)   # (.sw_local under O3XSXr:
                    if getattr(d, 'reg', None) and (d.kind != 'param' or uses_decl(F.f.body, d))}   # ld BC,WA)
            nr = [r for r in ('WA', 'BC', 'DE', 'HL') if r not in used][0]
            F.emit('ld', '%s,%s' % (FAM[nr][size], R)); R = FAM[nr][size]
            if F.opt and sel is not None: F.no_inplace = getattr(F, 'no_inplace', set()) | {sel}   # .sw_local: x + 1
                                                     # in an arm is ld HL,WA / inc 0x1,HL, not done in place
        elif keep and F.opt and sel is not None and sel.reg in ('IZ', 'QIZ') and (not F.adecl or is_tab):
            F.emit('ld', '%s,%s' % (FAM['WA'][size], R)); R = FAM['WA'][size]   # sw_loop under O3XS: ld WA,IZ
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
    table = n >= 6 and hi - lo + 1 <= 2 * n               # 5 cases are a chain (abi switch.c sw_char, sw_long)
    order = list(cases)
    rt = return_table(F, s, vals, lo, hi) if table else None
    if rt is not None:
        byval, dflt = rt
        S = 'S%d' % (90000 + len(getattr(F, 'tables', [])))
        rows = ['\talign\t2', S + ':']
        for v in range(lo, hi + 1): rows += ['\talign\t1', '\tdb\t%d' % byval[v]]
        rows += ['\talign\t1', '\tdb\t%d' % dflt]
        F.tables = getattr(F, 'tables', []) + [rows]
        La, Lb = F.newulabel(), F.newulabel()
        F.emit('cp', '%s,0x0' % R); F.emit('j', 'm,%s' % La)
        F.emit('cp', '%s,%s' % (R, hx(hi))); F.emit('j', 'le,%s' % Lb)
        F.lines.append(La + ':'); F.emit('ld', '%s,%s' % (R, hx(hi + 1)))
        F.lines.append(Lb + ':'); F.emit('lda', 'XIX,%s' % S); F.emit('ld', 'L,(XIX+%s)' % R); F.emit('exts', 'HL')
        flush_pops(F)
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F); F.emit('retd', hx(F.retd)) if getattr(F, 'retd', 0) else F.emit('ret')
        return
    vt = value_table(F, s, cases, vals, default, lo, hi) if table else None
    if vt is not None:                                   # switch.c under O3XS: every case calls one function with a
        fn, byval = vt                                   # constant: a table of the constants (sw_jt6, sw_jtoff, sw_jtl)
        S = 'S%d' % (90000 + len(getattr(F, 'tables', [])))
        rows = ['\talign\t2', S + ':']
        for v in range(lo, hi + 1): rows += ['\talign\t1', '\tdb\t%d' % byval[v]]
        F.tables = getattr(F, 'tables', []) + [rows]
        if lo != 0:
            F.emit('sub', '%s,%s' % (R, hx(lo & ((1 << (8 * size)) - 1)))); F.emit('cp', '%s,0x0' % R); to_default('lt')
        elif signed:
            F.emit('cp', '%s,0x0' % R); to_default('m')
        F.emit('cp', '%s,%s' % (R, hx(hi - lo))); to_default('gt' if signed or lo != 0 else 'ugt')
        if size == 4: F.emit('add', '%s,%s' % (R, S)); F.emit('ld', 'A,(%s)' % R)
        else: F.emit('lda', 'XIX,%s' % S); F.emit('ld', 'A,(XIX+%s)' % R)
        F.emit('exts', 'WA'); F.emit('push', 'WA'); F.emit('cal', '_' + fn.decl.name); F.emit('inc', '0x2,XSP')
        if getattr(F, 'vt_ret', False): F.emit('ret')    # sw_ret: ... cal _g1 / inc 0x2,XSP / ret / L: ld HL,0x0
        dc = getattr(F, 'vt_default', None); F.vt_default = None
        if dc is not None:                               # sw_jt6d: ... inc 0x2,XSP / ret / L1: j _f0
            F.emit('ret') if exit_is_ret else F.emit('j', end)
            F.lines.append(F.case_labels[id(dc)] + ':')
            if dc.body is not None: gen_stmt(F, dc.body, exit_is_ret)
            F.lines.append(end + ':')                    # (unreferenced: dropped, so cal _f0 / ret becomes j _f0)
        else:
            F.lines.append(end + ':'); F.ret_refs = getattr(F, 'ret_refs', set()) | {end}
        F.switch_table = True
        return
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
        after = getattr(F, 'switch_after', None) if not default else None
        def cpz(v):                                        # sw_long: a long compared with 0 is or XWA,XWA
            if v == 0 and size == 4: F.emit('or', '%s,%s' % (R, R))
            else: F.emit('cp', '%s,%s' % (R, hx(v)))
        for i, g in enumerate(entries):
            lastone = i == len(entries) - 1 and after is None
            if g[0] == g[1]:
                cpz(g[0])
                lc = [c for c in cases if F.case_labels[id(c)] == g[2]]
                aft = getattr(F, 'switch_after', None)
                if F.opt and i == len(entries) - 1 and aft is not None and not default and lc and \
                        lc[0].body is not None and lc[0].body.k == 'return' and fold(lc[0].body.value).k == 'const' and \
                        fold(lc[0].body.value).value == 1 and aft.k == 'return' and aft.value is not None and \
                        fold(aft.value).k == 'const' and fold(aft.value).value == 0 and not F.pushes and \
                        not F.xiz_vars and not getattr(F, 'frame', 0):
                    F.emit('scc', 'eq,HL'); F.emit('ret')       # abi switch.c sw_char: the last value returns 1, the
                    F.switch_after = None; after = None         # return after the switch 0 -> cp A,0x61 / scc eq,HL
                    F.skip_cases = getattr(F, 'skip_cases', set()) | {id(lc[0])}
                    continue
                if lastone:
                    to_default('ne')
                    first = [c for c in cases if F.case_labels[id(c)] == g[2]]
                    if first and cases and cases[0] is not first[0]: F.emit('j', g[2])
                    elif first and not any(x[2] == g[2] for x in entries if x is not g):   # (random r1_02_18:
                        F.case_labels[id(first[0])] = None     # sw_jt4: the body it falls into has no label; unless
                                                                # another case value jumps to it -- undefined label)
                else: F.emit('j', 'eq,%s' % g[2])
            else:
                skip = deflab if lastone else F.newulabel()
                F.emit('cp', '%s,%s' % (R, hx(g[1]))); F.emit('j', 'gt,%s' % skip)
                F.emit('cp', '%s,%s' % (R, hx(g[0]))); F.emit('j', 'ge,%s' % g[2])
                if not lastone: F.lines.append(skip + ':')
                elif default:                                  # sw_ev: the default body follows the range test
                    order = [c for c in cases if c.k == 'default'] + [c for c in cases if c.k != 'default']
        if not entries: F.emit('j', deflab)
        if after is not None:                              # the return after the switch, then the case bodies
            gen_stmt(F, after, True); F.switch_after = None
    if exit_is_ret and not F.opt: F.switch_rets = getattr(F, 'switch_rets', set()) | {end}
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
    for i_, it in enumerate(items):
        if id(it) in getattr(F, 'skip_cases', ()): continue
        rest_ = items[i_ + 1:]                             # the live guard's remainder: the fall-through path only, up to
        stop_ = next((k for k, x in enumerate(rest_) if x.k in ('break', 'return')), len(rest_))   # the next break
        F.cur_rest = rest_[:stop_]                         # (r1_00_13 -Xr: case 0: ... falls into default: gp = gs.p + a,
        gen_stmt(F, it, False)                             # a in A across the first arm's ._fsub_d was wrong code; arms
    if F.pending and not F.lines[-1].startswith(('\tret', '\tj\t', '\tretd')): flush_pops(F)   # (r2_06_14)
    F.loops.pop()
    import re as _re                                       # an end nothing reaches is not written (sw_dense, sw_sparse:
    reached = end in getattr(F, 'ret_refs', set()) or any(_re.search(r'[\t,]%s$' % end, l) for l in F.lines) or \
        not F.lines[-1].startswith(('\tret', '\tj\t', '\tretd'))          # every arm returns)
    if reached and SWITCH_LOOP_LABEL and in_loop_last and not F.opt:
        F.lines.append(F.newulabel() + ':')               # switch.c sw_loop (no -O): the switch's own end label stays
    if reached: F.lines.append(end + ':')                  # unreferenced before the loop's continue label
    F.switch_table = getattr(F, 'switch_table', False) or table

def loop_cond(F, c, target, sense):
    """jump to target when c is true (sense) or false (not sense); x-- as condition (rc_while)"""
    c = strip(c)
    if table_test(c) and getattr(F, 'l2', None):         # _atoi: while (isspace(*nptr)) -> ... / bit 0x3,(XBC+WA)
        cc = gen_table_test(F, table_test(c)); cc = cc if sense else INV[cc]
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
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
        d = regvar_of(c.e); R = FAM[d.reg][2]; T = FAM[getattr(F, 'tfam', 'WA')][2]   # opt_temps.c: ld DE,BC / dec 0x1,BC
        if POSTDEC_FREE and F.adecl and F.opt and d.reg == 'WA' and T == 'DE' and 'BC' not in live_regs(F):
            T = 'BC'                                       # ra_while (-O3 -XS -Xr): n in WA -> ld BC,WA / dec 0x1,WA
        F.emit('ld', '%s,%s' % (T, R)); F.emit('dec' if c.op == '--' else 'inc', '0x1,%s' % R); F.emit('cp', '%s,0x0' % T)
        cc = 'ne' if sense else 'eq'
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k == 'bin' and c.op in CC_S and strip(c.l).k == 'incdec' and strip(c.l).post and regvar_of(strip(c.l).e) and \
            fold(c.r).k == 'const' and fold(c.r).value is not None and regvar_of(strip(c.l).e).ty.size == 2:
        d = regvar_of(strip(c.l).e); R = FAM[d.reg][2]   # c_clear: while (n-- > 0) with n in BC, p in XWA ->
        T = getattr(F, 'tfam', None)                        # ld DE,BC / dec 0x1,BC / cp DE,0x0 / j gt
        if T is None:
            live = live_regs(F)
            T = next((r for r in ('WA', 'BC', 'DE', 'HL') if r not in live and r != d.reg), None)
        if T is not None:
            F.emit('ld', '%s,%s' % (FAM[T][2], R)); F.emit('dec' if strip(c.l).op == '--' else 'inc', '0x1,%s' % R)
            F.emit('cp', '%s,%s' % (FAM[T][2], hx(fold(c.r).value & 0xffff)))
            cc = (CC_S if d.ty.signed else CC_U)[c.op]; cc = cc if sense else INV[cc]
            F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k == 'incdec' and not c.post and c.op == '--' and regvar_of(c.e) and F.opt and sense and target != 'RET' \
            and regvar_of(c.e).ty.size == 2:
        F.emit('djnz', '%s,%s' % (FAM[regvar_of(c.e).reg][2], target)); return   # c_do under O3XS: djnz IZ,L1
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
    if not fpgen.is_fp(c.ty):
        bt = bit_cond(F, c)                                # cond_bits.c cb_while: bit 0x0,WA / j ne,L1
        if bt is not None:
            cc = bt if sense else INV[bt]
            F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k == 'bin' and c.op in CC_S and fpgen.is_fp(strip(c.l).ty):   # _log: do ... while (last != s) -> ld DE,0x5 /
        fpgen.compare(F, c, sense); F.emit('cp', 'HL,0x0')                # ... / j ne (the relation itself)
        cc = 'ne'
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    if c.k == 'bin' and c.op in CC_S:
        cc = gen_compare(F, c)
        if cc is True or cc is False: raise Unsupported('constant loop condition')
        cc = cc if sense else INV[cc]
        F.emit('ret', cc) if target == 'RET' else F.emit('j', '%s,%s' % (cc, target)); return
    raise Unsupported('loop condition ' + c.k)

def ptr_kloop(F, s):
    """-O: for (i = 0; i < K; i++) { straight-line statements } whose every array access is p[i + k], k >= 0, on
    one pointer parameter p, i used nowhere else, and the last access p[i] (arr_index.c ai_div10): a description
    for gen_counted, else None"""
    if s.k != 'for' or s.init is None or s.cond is None or s.inc is None: return None
    ini = flat(s.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return None
    iv = strip(strip(ini[0].e).l); v0 = fold(strip(ini[0].e).r)
    if iv.k != 'var' or iv.decl.kind != 'local' or iv.decl.ty.size != 2 or v0.k != 'const' or v0.value != 0: return None
    c = strip(s.cond); kc = fold(c.r) if c.k == 'bin' else None
    if not (c.k == 'bin' and c.op == '<' and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var' and
            strip(strip(c.l).e).decl is iv.decl and kc is not None and kc.k == 'const' and kc.value and kc.value > 0):
        return None
    inc = strip(s.inc)
    if not (inc.k == 'incdec' and inc.op == '++' and strip(inc.e).k == 'var' and strip(inc.e).decl is iv.decl): return None
    stmts = flat(s.body)
    if not stmts or any(x.k != 'expr' for x in stmts): return None
    accs = []; bad = []; pvs = set()
    def v(n, d):
        if n.k == 'index':
            b = strip(n.base); bi, k = split_index(n.idx); bi = unpromote(bi)
            if b.k == 'load' and strip(b.e).k == 'var' and strip(b.e).decl.kind == 'param' and \
                    strip(b.e).decl.ty.is_ptr() and bi.k == 'load' and strip(bi.e).k == 'var' and \
                    strip(bi.e).decl is iv.decl and k >= 0:
                accs.append((n, k)); pvs.add(strip(b.e).decl)
            else: bad.append(n)
        if n.k in ('call', 'deref') or fpgen.is_fp_op(n): bad.append(n)
        if n.k in ('incdec', 'opassign') and strip(n.e if n.k == 'incdec' else n.l).k == 'var': bad.append(n)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': bad.append(n)
    for x in stmts: walk(x, v)
    if bad or len(pvs) != 1 or not accs: return None
    uses = []
    walk(s.body, lambda n, d: uses.append(n) if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl is iv.decl else None)
    if len(uses) != len(accs) or accs[-1][1] != 0: return None
    esz = accs[0][0].ty.size
    if any(n.ty.size != esz for n, _ in accs): return None
    return {'pk': True, 'p': pvs.pop(), 'K': kc.value, 'esz': esz, 'accs': accs}

def gen_counted(F, s, last, cl):
    """the -O counted loop (ol_i_acc1 .. ol_c_glob)"""
    if cl.get('pk'):                                       # arr_index.c ai_div10: ld XWA,(t) / ld XBC,XWA /
        p = cl['p']; esz = cl['esz']                       # lda XDE,XWA+0x12 / L2: ... (XBC) ... (XBC+0x2) ... /
        if getattr(p, 'reg', None) not in (None, 'WA'): raise Unsupported('pointer loop base')   # (XBC+:2) /
        if not getattr(p, 'reg', None): F.emit('ld', 'XWA,(XSP+%s)' % hx(p.off + F.push))   # cp XBC,XDE / j ult,L2
        F.emit('ld', 'XBC,XWA'); F.emit('lda', 'XDE,XWA+%s' % hx(cl['K'] * esz))
        F.dead.add(p)                                      # (-Xr: XWA is free for the values: ld WA,(XBC))
        body = F.newulabel(); F.newulabel()
        F.lines.append(body + ':'); n0 = len(F.lines)
        F.elem_ops = {id(n): '(XBC+%s)' % hx(k * esz) if k else '(XBC)' for n, k in cl['accs']}
        try: gen_stmt(F, s.body, False)
        finally: F.elem_ops = {}
        for j in range(len(F.lines) - 1, n0 - 1, -1):     # the last access steps the pointer
            if '(XBC)' in F.lines[j]:
                F.lines[j] = F.lines[j].replace('(XBC)', '(XBC+:%d)' % esz); break
        else: raise Unsupported('pointer loop step')
        F.emit('cp', 'XBC,XDE'); F.emit('j', 'ult,%s' % body)
        return
    if 'kconst' in cl and KCONST_MULTI:
        idx = []; cont = []
        walk(s.body, lambda n, d: idx.append(n) if n.k == 'index' and strip(n.base).k == 'var' and
             strip(n.base).decl is cl['arr'] else None)
        walk(s.body, lambda n, d: cont.append(n) if n.k == 'continue' else None)
        if len(idx) > 1 or cont:                           # arr_index.c ai_mul10 (-O): the element read three times
            esz = cl['esz']                                # and a continue -> lda XWA,_gsa / ld XBC,XWA /
            F.emit('lda', 'XWA,_%s' % cl['arr'].name); F.emit('ld', 'XBC,XWA')   # lda XDE,XWA+0x14 / L4: cpw (XBC),..
            F.emit('lda', 'XDE,XWA+%s' % hx(cl['kconst'] * esz))                 # / ... / L6: inc 0x2,XBC /
            body = F.newulabel(); contl = F.newulabel(); end = F.newulabel()     # cp XBC,XDE / j ult,L4
            F.lines.append(body + ':')
            F.cl_operand = '(XBC)'; F.cl_active = cl; F.cl_shared = False
            F.elem_ops = {id(n): '(XBC)' for n in idx}
            F.loops.append((end, lambda: contl))
            try: gen_stmt(F, s.body, False)
            finally:
                F.loops.pop(); F.cl_active = None; F.cl_operand = None; F.elem_ops = {}
            F.lines.append(contl + ':'); F.emit('inc', '%s,XBC' % hx(esz)); F.emit('cp', 'XBC,XDE')
            F.emit('j', 'ult,%s' % body)
            return
    if 'kconst' in cl:                                     # ol_i_const: walk a pointer to an end pointer
        for d in list(F.f.params) + list(F.f.decls):       # (lnr.c o_n_in -O3 -XS -Xr: n in WA is read in the
            if d is not cl['i'] and getattr(d, 'reg', None) in ('WA', 'BC') and d not in F.dead and \
                    (uses_decl(s.body, d) or d in read_after_top(F)):   # body; V4.23 hoists n + n into DE first)
                raise Unsupported('pointer loop over a live WA / BC')
        n0 = len(F.lines)
        F.emit('lda', 'XBC,_%s' % cl['arr'].name); F.emit('ld', 'XWA,XBC')
        F.emit('lda', 'XBC,XBC+%s' % hx(cl['kconst'] * cl['esz']))
        body = F.newulabel(); F.newulabel()
        F.lines.append(body + ':')
        F.cl_operand = '(XWA+:%d)' % cl['esz']; F.cl_active = cl; F.cl_shared = False
        nb = len(F.lines)
        gen_stmt(F, s.body, False)
        F.cl_active = None; F.cl_operand = None
        if STORE_ADDR_GUARD and clobbers(F.lines[nb:], '(XWA+XBC)'):
            raise Unsupported('the loop body overwrites the walking pointers')   # (o_n_in: ld BC,WA: wrong code)
        F.emit('cp', 'XWA,XBC'); F.emit('j', 'ult,%s' % body)
        return
    i = cl['i']; I = FAM[i.reg][2]
    form = cl.get('form', 'for')
    if form == 'down':                                   # ol_down: ld DE,WA / cp DE,0x0 / ret le / lda XBC,_ga /
        kd = cl['k']                                     # ld WA,DE / add WA,WA / L1: ... / dec 0x1,DE / dec 0x2,WA /
        km = FAM[kd.reg][2] if getattr(kd, 'reg', None) else '(XSP+%s)' % hx(kd.off + F.push)   # cp DE,0x0 / j gt,L1
        F.emit('ld', '%s,%s' % (I, km)); F.emit('cp', '%s,0x0' % I)
        exitl = F.newulabel(); body = F.newulabel()
        F.emit('ret', 'le') if last and not F.pushes else F.emit('j', 'le,%s' % exitl)
        B = FAM[cl['base'].reg][4]; F.emit('lda', '%s,_%s' % (B, cl['arr'].name))
        X = I
        if cl['esz'] > 1:
            X = FAM[cl['off'].reg][2]; F.emit('ld', '%s,%s' % (X, I)); scale16(F, X, cl['esz'])
        F.lines.append(body + ':')
        F.cl_operand = '(%s+%s)' % (B, X); F.cl_active = cl; F.cl_shared = False; F.cl_tmp_done = False
        cl['ops'] = {cl['arr']: F.cl_operand}
        gen_stmt(F, s.body, False)
        F.cl_active = None; F.cl_operand = None
        F.emit('dec', '0x1,%s' % I)
        if cl['esz'] > 1: F.emit('dec', '%s,%s' % (hx(cl['esz']), X))
        F.emit('cp', '%s,0x0' % I); F.emit('j', 'gt,%s' % body); F.lines.append(exitl + ':')
        return
    K = '(XSP+%s)' % hx(cl['k'].off + F.push) if cl.get('k_mem') else FAM[cl['kp'].reg][2]   # ol_while: i = 0 is
                                                         # its declaration's; ol_do: no guard
    if form == 'for': F.emit('ld', '%s,0x0' % I)
    kd = cl['k']
    if not cl.get('k_in_reg') and not cl.get('k_mem'):
        km = '(XSP+%s)' % hx(kd.off + F.push) if kd.kind == 'param' else '(_%s)' % kd.name
        F.emit('ld', '%s,%s' % (K, km))
    exitl = F.newulabel(); body = F.newulabel()
    if form != 'do':
        F.emit('cp', '%s,0x0' % K)
        trivial = last and not F.pushes
        F.emit('ret', 'le') if trivial else F.emit('j', 'le,%s' % exitl)
    B = FAM[cl['base'].reg][4]
    if cl.get('u1'):                                     # ol_l_copy: lda XIY,_gb / lda XIX,_gla / ld DE,0x0 / ld HL,0x0
        for a_, _ in reversed(cl['order']): F.emit('lda', '%s,_%s' % (FAM[cl['bases'][a_].reg][4], a_.name))
        for o_ in cl['offs'].values(): F.emit('ld', '%s,0x0' % FAM[o_.reg][2])
        cl['ops'] = {a_: '(%s+%s)' % (FAM[cl['bases'][a_].reg][4], FAM[cl['offs'][es].reg][2] if es > 1 else I)
                     for a_, es in cl['order']}
        X = FAM[cl['off'].reg][2] if 'off' in cl else I
    else:
        F.emit('lda', '%s,_%s' % (B, cl['arr'].name))
        if 'off' in cl: O = FAM[cl['off'].reg][2]; F.emit('ld', '%s,0x0' % O); X = O
        else: X = I
    F.lines.append(body + ':')
    F.cl_operand = '(%s+%s)' % (B, X); F.cl_tmp_done = False
    if cl.get('tmp'):
        F.cl_shared = True
    F.cl_active = cl
    gen_stmt(F, cl.get('body', s.body), False)
    F.cl_active = None; F.cl_operand = None; F.cl_tmp_done = False
    F.emit('inc', '0x1,%s' % I)
    if cl.get('u1'):                                     # ol_l_copy: inc 0x1,IZ / inc 0x2,HL / inc 0x4,DE
        for es, o_ in reversed(list(cl['offs'].items())): F.emit('inc', '%s,%s' % (hx(es), FAM[o_.reg][2]))
    elif 'off' in cl: F.emit('inc', '%s,%s' % (hx(cl['esz']), FAM[cl['off'].reg][2]))
    F.emit('cp', '%s,%s' % (I, K)); F.emit('j', 'lt,%s' % body)
    if form != 'do': F.lines.append(exitl + ':')

def byte_compare_in(c):
    found = []
    def v(n, d):
        if n.k == 'bin' and n.op in ('==', '!='):
            ok = True
            for x in (n.l, n.r):
                x = strip(x)
                while x.k == 'cast': x = strip(x.e)
                ok = ok and x.k == 'load' and strip(x.e).k == 'deref' and x.ty.size == 1
            if ok: found.append(n)
    walk(c, v)
    return bool(found)

def gen_loop(F, s, last):
    """for / while / do (regalloc_notes.md, loop shapes); labels: exit first, then body"""
    cl = getattr(F, 'counted', {}).get(id(s))
    if cl: return gen_counted(F, s, last, cl)
    bk = getattr(F, 'u1_block', None)
    if bk is not None and bk[0] is s:                    # oc_cpy_g (u1_block_copy)
        d = bk[1]
        src = ('ld', 'XIY,_%s' % bk[2].name)
        if F.adecl: F.emit(*src); F.emit('ld', 'XIX,%s' % FAM[d.reg][4])
        else: F.emit('ld', 'XIX,(XSP+%s)' % hx(d.off + F.push)); F.emit(*src)
        F.emit('ld', 'BC,%s' % hx(bk[3])); F.emit('ldirw', '(XIX+),(XIY+)'); return
    d2 = getattr(F, 'u1_down2', None)
    if d2 is not None and d2['lp'] is s:                 # oc_down2 (u1_down2)
        N_ = FAM[d2['n'].reg][2]; T = FAM[d2['chain']][2]; XT = FAM[d2['chain']][4]
        exitl = F.newulabel(); body = F.newulabel()
        F.emit('cp', '%s,0x0' % N_)
        after_ret = last and not F.xiz_vars and not F.pushes and not F.pending and not getattr(F, 'frame', 0)
        F.emit('ret', 'le') if after_ret and not F.loops else F.emit('j', 'le,%s' % exitl)
        K = FAM[d2['iv']][2] if d2['iv'] else None
        if K: F.emit('ld', '%s,%s' % (K, N_)); F.emit('dec', '0x1,%s' % K)
        F.lines.append(body + ':')
        if K: F.emit('ld', '%s,%s' % (T, K))
        else: F.emit('ld', '%s,%s' % (T, N_)); F.emit('dec', '0x1,%s' % T)
        F.emit('exts', XT); F.emit('add', '%s,%s' % (XT, XT)); F.emit('add', '%s,%s' % (XT, FAM[d2['p'].reg][4]))
        F.emit(SIMPLE_OPS[d2['op']], 'HL,(%s)' % XT)
        if K: F.emit('dec', '0x1,%s' % N_); F.emit('dec', '0x1,%s' % K); F.emit('cp', '%s,0x0' % N_)
        else: F.emit('sub', '%s,0x1' % N_)
        F.emit('j', 'gt,%s' % body); F.lines.append(exitl + ':'); return
    dx = getattr(F, 'u1_down_xr', None)
    if dx is not None and dx[0] is s:                    # plain -Xr oc_down: ld DE,BC / sub DE,0x1 / ret lt / L1: ... /
        I = FAM[cl_i(s).reg][2]                          # sub DE,0x1 / j ge,L1 / L2:
        exitl = F.newulabel(); body = F.newulabel()
        F.emit('ld', '%s,%s' % (I, FAM[dx[1].reg][2])); F.emit('sub', '%s,0x1' % I)
        after_ret = last and not F.xiz_vars and not F.pushes and not F.pending and not getattr(F, 'frame', 0)
        F.emit('ret', 'lt') if after_ret and not F.loops else F.emit('j', 'lt,%s' % exitl)
        F.lines.append(body + ':')
        F.loops.append((exitl, lambda: body)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
        F.emit('sub', '%s,0x1' % I); F.emit('j', 'ge,%s' % body); F.lines.append(exitl + ':'); return
    if s.k == 'for' and s.init is not None:
        gen_stmt(F, s.init, False)
        if getattr(F, 'u1_down', None) is s: F.lines[-1] += '\t;u1'   # oc_down: dec 0x1,DE / j L1 is not merged
    l2 = getattr(F, 'l2', None)
    if l2 and getattr(F, 'l2_ivloop', None) is s and l2.get('iv'):
        exitl, bodyl = F.newulabel(), F.newulabel()    # _strrev: cp XIZ,XIX / j uge,L1 / ld XBC,XIZ / ld XDE,XIX / L2:
        gen_cond_false(F, s.cond, exitl)               # ... / inc 0x1,XIZ / dec 0x1,XDE / dec 0x1,XIX /
        R = lambda d: 'XIZ' if d.reg == 'XIZ' else FAM[d.reg][4]          # cp XIZ,XIX / j ult,L2 / L1:
        steps = []
        inc = strip(s.inc)
        parts = [inc] if inc.k != 'bin' or inc.op != ',' else [strip(inc.l), strip(inc.r)]
        for x in parts:
            if x.k == 'incdec' and strip(x.e).k == 'var': steps.append((strip(x.e).decl, x.op))
        last_store = {}
        def ls(n, d):
            if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'deref' and strip(strip(n.l).e).k == 'load' and \
                    strip(strip(strip(n.l).e).e).k == 'var':
                last_store[strip(strip(strip(n.l).e).e).decl] = id(strip(n.l))
        walk(s.body, ls)
        post = {last_store[v] for v, op in steps if op == '++' and v in l2['iv'] and v in last_store}
        for v in l2['iv']: F.emit('ld', 'X%s,%s' % (l2['iv'][v], R(v)))
        F.lines.append(bodyl + ':')
        l2['ivmap'] = dict(l2['iv']); l2['ivpost'] = post
        F.loops.append((exitl, lambda: bodyl)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
        l2['ivmap'] = {}; l2['ivpost'] = set()
        for v, op in steps:
            if op == '++' and v in l2['iv'] and any(last_store.get(v) == x for x in post):
                F.emit('inc', '%s,%s' % (hx(v.ty.base.size), R(v)))
            else:
                if v in l2['iv']: F.emit('dec' if op == '--' else 'inc', '%s,X%s' % (hx(v.ty.base.size), l2['iv'][v]))
                F.emit('dec' if op == '--' else 'inc', '%s,%s' % (hx(v.ty.base.size), R(v)))
        loop_cond(F, s.cond, bodyl, True)
        F.lines.append(exitl + ':')
        return
    if l2: l2['conv_done'] = set(); l2['const'] = {}        # _itoa: the radix copy once per iteration; a known
                                                           # constant is not known inside a loop (_strcspn: ++len)
    if l2 and s.k == 'for' and s.cond is not None and s.inc is not None:
        cv = strip(s.cond); iv = strip(s.inc)            # _strrchr: for (...; i; --i) -> cp BC,0x0 / j eq,L1 /
        cvar = strip(cv.e).decl if cv.k == 'load' and strip(cv.e).k == 'var' else None   # ld WA,(c) / L2: ... /
        if cvar is not None and getattr(cvar, 'reg', None) in ('BC', 'DE', 'HL', 'WA') and cvar.ty.size == 2 and \
                iv.k == 'incdec' and iv.op == '--' and strip(iv.e).k == 'var' and strip(iv.e).decl is cvar:   # L4: djnz
            R = FAM[cvar.reg][2]; exitl, bodyl, contl = F.newulabel(), F.newulabel(), F.newulabel()
            F.emit('cp', '%s,0x0' % R); F.emit('j', 'eq,%s' % exitl)
            for d in l2.get('pre', []):
                F.emit('ld', '%s,(XSP+%s)' % (FAM[d.reg][d.ty.size], hx(d.off + F.push)))
            l2['pre'] = []
            F.lines.append(bodyl + ':')
            F.loops.append((exitl, lambda: contl)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
            F.lines.append(contl + ':'); F.emit('djnz', '%s,%s' % (R, bodyl)); F.lines.append(exitl + ':')
            return
    if l2:                                                # _atoi: lda XBC,__ctype before the first loop that tests it
        for tab, reg in list(l2.get('tab_inv', {}).items()):
            if tab not in l2.setdefault('inv_done', set()) and uses_table(s, tab):
                F.emit('lda', 'X%s,_%s' % (reg, tab.name)); l2['inv_done'].add(tab)
    after_ret = last and not F.xiz_vars and not F.pushes and not F.pending and not getattr(F, 'frame', 0)
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
    if s.k == 'while' and s.cond is not None and (F.opt or (F.adecl and byte_compare_in(s.cond))):
        # -XS rotation: j test / body / test (_strcat); plain -Xr rotates a test that compares two bytes too
        # (opt_temps.c ot_cmp_abn, ot_len2), and repeats the others in front (ctrl.c c_cnt, c_clear)
        if EMPTY_WHILE_ONE_LABEL and not flat(s.body):     # opt_loops.c ol_strcpy: while ((*d++ = *s++) != 0) ;
            body = F.newulabel(); F.newulabel()            # -> L1: ... / j ne,L1 (one label, no jump in)
            F.lines.append(body + ':'); loop_cond(F, s.cond, body, True); return
        if F.pending and LOOP_FLUSH_POPS: flush_pops(F)    # the 1997 library's _fread: fgetc(stream)'s pop went into
        test = F.newulabel(); body = F.newulabel()          # the loop body and ran every iteration (wrong code)
        F.emit('j', test); F.lines.append(body + ':')
        cont = [None]; brk = [None]
        def getc2():
            if cont[0] is None: cont[0] = F.newulabel()
            return cont[0]
        def getb():                                        # the break label, made on first use (_strnicmp: a break
                                                           # jumped to None: wrong code)
            if brk[0] is None: brk[0] = F.newulabel()
            return brk[0]
        F.loops.append((LazyLabel(getb), getc2)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
        F.lines.append(test + ':')
        loop_cond(F, s.cond, body, True)
        if brk[0] is not None: F.lines.append(brk[0] + ':')
        return
    exitl = F.newulabel(); body = F.newulabel()
    cont = [None]
    def getc():
        if cont[0] is None: cont[0] = F.newulabel()
        return cont[0]
    rotated = None
    if F.opt and s.k == 'for' and s.cond is not None:
        ini = flat(s.init) if s.init is not None else []
        cnd = strip(s.cond)
        iv = strip(strip(ini[0].e).l) if len(ini) == 1 and ini[0].k == 'expr' and strip(ini[0].e).k == 'bin' and \
            strip(ini[0].e).op == '=' else None
        k0 = fold(strip(ini[0].e).r) if iv is not None else None
        lv = strip(cnd.l) if cnd.k == 'bin' else None
        while lv is not None and lv.k == 'cast': lv = strip(lv.e)
        if iv is not None and iv.k == 'var' and k0.k == 'const' and cnd.k == 'bin' and cnd.op in CC_S and \
                lv is not None and lv.k == 'load' and strip(lv.e).k == 'var' and strip(lv.e).decl is iv.decl:
            # -O: the first test knows i's start (c_for: for (i = 0; i < n; ...) -> cpw (XSP+0x6),0x0 / j le,L1)
            x = strip(cnd.r)
            while x.k == 'cast' and x.kind == 'IntegralCast': x = strip(x.e)
            xm = mem_operand(F, x); sz = x.ty.size
            swap = {'<': '>', '>': '<', '<=': '>=', '>=': '<=', '==': '==', '!=': '!='}[cnd.op]
            cc = (CC_S if x.ty.signed else CC_U)[swap]
            if fold(x).k == 'const' and fold(x).value is not None:     # _exp: for (i = 1; i <= LOP; ...): both known,
                import operator                                        # the first test is decided now
                holds = {'<': operator.lt, '<=': operator.le, '>': operator.gt, '>=': operator.ge,
                         '==': operator.eq, '!=': operator.ne}[cnd.op](k0.value, fold(x).value)
                if not holds: F.emit('j', exitl) if not (after_ret and not F.loops) else F.emit('ret')
                rotated = 'tested'; xm = None
            xd = strip(x.e).decl if x.k == 'load' and strip(x.e).k == 'var' else None
            if xm is not None and getattr(F, 'u1_bounds', None) and xd in F.u1_bounds:
                F.u1_bounds.remove(xd)                     # O3XS oc_nested: ld DE,(XSP+0x8) before the outer test,
                F.emit('ld', '%s,(XSP+%s)' % (FAM[xd.reg][xd.ty.size], hx(xd.off + F.push)))   # ld BC,(XSP+0xa)
            elif xm is not None and getattr(F, 'u1_bound', None) is not None and not F.adecl and \
                    getattr(F.u1_bound, 'reg', None) and not getattr(F, 'u1_bound_loaded', False) and \
                    not getattr(F, 'u1_bounds', None):     # before the inner one
                d = F.u1_bound; F.u1_bound_loaded = True          # opt_counted.c O3XS: ld BC,(XSP+0x8) / cp BC,0x0
                F.emit('ld', '%s,(XSP+%s)' % (FAM[d.reg][d.ty.size], hx(d.off + F.push)))
            if xm is not None:
                kv = k0.value if family_of(xm) or sz not in (1, 2) else k0.value & (0xff if sz == 1 else 0xffff)
                F.emit('cp' + ('' if family_of(xm) else ('w' if sz == 2 else 'b' if sz == 1 else '')), '%s,%s' % (xm, hx(kv)))
                tgt = 'RET' if after_ret and not F.loops else exitl
                F.emit('ret', INV[cc]) if tgt == 'RET' else F.emit('j', '%s,%s' % (INV[cc], tgt))
                rotated = 'tested'
        if rotated is None:                                # c_fordown: ld IZ,(n) / j L1 / body / L1: cp IZ,0x0 / j gt
            rotated = F.newulabel(); F.emit('j', rotated)
    if rotated is not None: pass
    elif s.cond is not None: loop_cond(F, s.cond, 'RET' if after_ret and not F.loops else exitl, False)
    ui = getattr(F, 'u1_inv', None)
    if ui is not None and ui[0] is s and ui[4]:          # O3XS ol_inv: ld WA,(XSP+0x6) / muls XWA,(XSP+0x8)
        F.emit('ld', '%s,(XSP+%s)' % (FAM[ui[4]][2], hx(ui[2].off + F.push)))
        F.emit('muls', '%s,(XSP+%s)' % (FAM[ui[4]][4], hx(ui[3].off + F.push)))
    elif ui is not None and ui[0] is s:                  # ra_param3: the invariant b * c after the guard: muls XBC,DE
        F.emit('muls', '%s,%s' % (FAM[ui[2].reg][4], FAM[ui[3].reg][2]))
    F.lines.append(body + ':')
    F.loops.append((exitl, getc)); gen_stmt(F, s.body, False); flush_pops(F); F.loops.pop()
    if cont[0]: F.lines.append(cont[0] + ':')
    inc = strip(s.inc) if s.k == 'for' and s.inc is not None else None
    cnd = strip(s.cond) if s.cond is not None else None
    if rotated not in (None, 'tested'):
        if s.inc is not None: gen_stmt(F, N_expr(s.inc), False)
        F.lines.append(rotated + ':'); loop_cond(F, s.cond, body, True)
        import re as _re                                   # c_fordown at -O: no exit label when nothing breaks out
        if any(_re.search(r'[\t,]%s$' % exitl, l) for l in F.lines): F.lines.append(exitl + ':')
        return
    if inc is not None and inc.k == 'incdec' and inc.op == '--' and regvar_of(inc.e) and cnd is not None and not rotated \
            and cnd.k == 'bin' and cnd.op in ('>', '!=') and fold(cnd.r).k == 'const' and fold(cnd.r).value == 0 \
            and regvar_of(getattr(strip(cnd.l), 'e', cnd.l)) is regvar_of(inc.e):
        d = regvar_of(inc.e)                                       # ra_for_down: sub DE,0x1 / j gt
        F.emit('sub', '%s,0x1' % FAM[d.reg][2]); F.emit('j', '%s,%s' % ('gt' if cnd.op == '>' else 'ne', body))
        F.lines.append(exitl + ':'); return
    if s.k == 'for' and s.inc is not None: gen_stmt(F, N_expr(s.inc), False)
    if s.cond is not None: loop_cond(F, s.cond, body, True)
    else: F.emit('j', body)
    if s.cond is None and F.opt and not any(re.search(r'[\t,]%s$' % exitl, l) for l in F.lines if l.startswith('\t')):
        F.no_exit = True; return                       # c_inf at -O: for (;;) with no break -> nothing after j L1
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

def counted_loop(F, s, multi=False):
    """for (i = 0; i < k; i++) over global arrays indexed by i (regalloc_notes.md, Loops at -O3 -XS):
    returns a description or None; `multi`: several arrays and the while / do forms (U1, u1_global)"""
    if multi and s.k in ('while', 'do'):                 # ol_while: int i = 0; while (i < k) { ...; i++; }
        w = u1_while_parts(F, s)
        if w is None: return None
        from frontend import N
        cl = counted_loop(F, N('for', init=N('expr', e=N('bin', op='=', l=N('var', decl=w[0], ty=w[0].ty),
                                                              r=N('const', value=0, ty=w[0].ty), ty=w[0].ty)),
                                 cond=s.cond, inc=w[1], body=N('block', body=w[2])), multi=True)
        if cl is not None: cl['form'] = s.k; cl['body'] = N('block', body=w[2])
        return cl
    if s.k != 'for' or s.init is None or s.cond is None or s.inc is None: return None
    ini = flat(s.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return None
    iv = strip(strip(ini[0].e).l); v0 = fold(strip(ini[0].e).r)
    r0 = strip(strip(ini[0].e).r)
    if iv.k == 'var' and iv.decl.kind == 'local' and iv.decl.ty.size == 2 and r0.k == 'load' and \
            strip(r0.e).k == 'var' and strip(r0.e).decl.kind == 'param' and strip(r0.e).decl.ty.size == 2:
        return u1_down_loop(F, s, iv.decl, strip(r0.e).decl)       # ol_down: for (i = k; i > 0; i--) ga[i] = 0
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
        if n.k == 'call' or fpgen.is_fp_op(n) or long_helper_node(n): bad.append(n)
    walk(s.body, v)
    if bad or not arrays or (len(arrays) != 1 and (not multi or kconst is not None)): return None
    if kconst is not None:
        other = []                                       # ol_i_const: only if i has no other use
        walk(s.body, lambda n, d: other.append(n) if n.k == 'load' and strip(n.e).k == 'var' and strip(n.e).decl is iv.decl else None)
        nidx = []
        walk(s.body, lambda n, d: nidx.append(n) if n.k == 'index' else None)
        if len(other) != len(nidx) or kconst.value <= 0: return None
        return {'i': iv.decl, 'kconst': kconst.value, 'arr': arrays[0][0], 'esz': arrays[0][1]}
    return {'i': iv.decl, 'k': strip(kv.e).decl, 'arr': arrays[0][0], 'esz': arrays[0][1], 'arrs': arrays}

def u1_down_loop(F, s, i, k):
    """for (i = k; i > 0; i--) over one global array indexed by i, k a parameter used nowhere else (ol_down,
    ra_for_down): a description with form 'down', or None"""
    c = strip(s.cond); inc = strip(s.inc)
    if not (c.k == 'bin' and c.op == '>' and fold(c.r).k == 'const' and fold(c.r).value == 0 and
            strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var' and strip(strip(c.l).e).decl is i): return None
    if not (inc.k == 'incdec' and inc.op == '--' and strip(inc.e).k == 'var' and strip(inc.e).decl is i): return None
    arrays = []; bad = []; ks = []
    def v(n, d):
        if n.k == 'var' and n.decl is k: ks.append(n)
        if n.k == 'index':
            b = strip(n.base); ix = strip(n.idx)
            while ix.k == 'cast': ix = strip(ix.e)
            if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and ix.k == 'load' \
                    and strip(ix.e).k == 'var' and strip(ix.e).decl is i:
                if b.decl not in [a for a, _ in arrays]: arrays.append((b.decl, n.ty.size))
            else: bad.append(n)
        if n.k == 'call' or fpgen.is_fp_op(n) or long_helper_node(n): bad.append(n)
    walk(s.body, v)
    walk([x for x in flat(F.f.body) if x is not s] + [s.cond, s.inc], lambda n, d: ks.append(n) if n.k == 'var' and n.decl is k else None)
    if bad or ks or len(arrays) != 1: return None
    return {'i': i, 'k': k, 'arr': arrays[0][0], 'esz': arrays[0][1], 'arrs': arrays, 'form': 'down'}

def u1_byte_sum(F, v):
    """return s0 + s1 + s2 over char register variables (ol_c_acc3): added in place into the first one's register,
    then moved to L (add H,L / add H,B / ld L,H); emits and returns True, or returns False"""
    terms = []
    def t(x):
        x = strip(x)
        while x.k == 'cast': x = strip(x.e)
        if x.k == 'bin' and x.op == '+': t(x.l); t(x.r)
        else: terms.append(x)
    t(v)
    ds = [regvar_of(x.e) if x.k == 'load' else None for x in terms]
    if len(ds) < 2 or None in ds or any(d.ty.size != 1 for d in ds): return False
    R = [FAM[d.reg][1] for d in ds]
    for r_ in R[1:]: F.emit('add', '%s,%s' % (R[0], r_))
    if R[0] != 'L': F.emit('ld', 'L,%s' % R[0])
    flush_pops(F); epilogue(F); F.emit('ret')
    return True

def u1_while_parts(F, s):
    """`int i = 0; while (i < k) { body; i++; }` (and the do form): (i, the i++ expression, the other body
    statements), when i is set only by its declaration and the final i++"""
    st = flat(s.body)
    if not st or st[-1].k != 'expr' or strip(st[-1].e).k != 'incdec' or strip(st[-1].e).op != '++' or \
            strip(strip(st[-1].e).e).k != 'var': return None
    i = strip(strip(st[-1].e).e).decl
    if i.kind != 'local' or i.ty.size != 2: return None
    top = flat(F.f.body)
    if s not in top: return None
    inits = [x for x in top[:top.index(s)] if x.k == 'decl' and x.var is i]
    if len(inits) != 1 or inits[0].init is None or fold(inits[0].init).k != 'const' or fold(inits[0].init).value != 0:
        return None
    sets = []
    def v(n, d):
        if n.k == 'incdec' and strip(n.e).k == 'var' and strip(n.e).decl is i: sets.append(n)
        if n.k in ('bin', 'opassign') and (n.k == 'opassign' or n.op == '=') and strip(n.l).k == 'var' and \
                strip(n.l).decl is i: sets.append(n)
        if n.k == 'addr': sets.append(n)
    walk(F.f.body, v)
    if len(sets) != 1: return None
    return i, strip(st[-1].e), st[:-1]

U1_CDECL_GLOBAL = True
U1_PLAIN_XR = True
U1_BYTE_CSE = True                                      # -O: one char element read by several statements                                      # U1 for plain -Xr counted loops over pointer parameters                                  # U1 for -O3 -XS (cdecl) counted loops over global arrays

def u1_plain_global(F):
    """rule U1 under plain -Xr for one counted for loop over global arrays (opt_loops.c under Xr): nothing is
    hoisted; each access builds its address in a chain register and a base register (ld BC,IX / add BC,BC / lda
    XDE,_ga / (XDE+BC); a char element only the base, lda XBC,_gca / (XBC+IX)).  The temporaries of the access
    computed last are allocated first (ol_i_copy: gb's address in HL / XIX first in the code, ga's in BC / XDE); the
    first of them is the first temporary, unless a long constant (ol_l_clear: ld XBC,0x0) or the byte loaded in place
    through its base (ol_c_copy: lda XBC,_gca / ld C,(XBC+IX)) comes first; then the locals and the counter."""
    import u1alloc
    f = F.f; W = {1: 8, 2: 16, 4: 32}
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    loops0 = list(loops)
    oi = None
    if len(loops) == 2 and all(x.k == 'for' for x in loops):   # ol_nested under -Xr: j IX, i IY
        ob = loops[0].body
        while ob is not None and ob.k == 'block' and len(ob.body) == 1: ob = ob.body[0]
        oh = u1_for_head(loops[0]) if ob is loops[1] else None
        if oh is None: return False
        oi = oh[0]; loops = [loops[1]]
    if len(loops) != 1: return False
    lp = loops[0]
    if lp.k == 'for':
        h = u1_for_head(lp) or u1_for_head(lp, const=True)   # (oc_cpy_g under -Xr: cp DE,0xa)
        if h is None or h[0] is oi: return False
        i, kv = h; st = flat(lp.body)
    else:                                                # ol_while, ol_do: int i = 0; while (i < k) { ...; i++; }
        w = u1_while_parts(F, lp)
        c = strip(lp.cond)
        if w is None or not (c.k == 'bin' and c.op == '<' and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var'
                             and strip(strip(c.l).e).decl is w[0]): return False
        i = w[0]; st = w[2]
    if any(getattr(p_, 'reg', None) not in ('WA', 'BC', 'DE') for p_ in f.params): return False
    if not st or any(x.k != 'expr' for x in st): return False
    def gacc(x):
        x = strip(x)
        while x.k == 'cast': x = strip(x.e)
        if x.k != 'load' or strip(x.e).k != 'index': return None
        v = strip(x.e); b = strip(v.base); ix = strip(v.idx)
        while ix.k == 'cast': ix = strip(ix.e)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array' and getattr(b.decl.ty, 'count', 0) \
                and ix.k == 'load' and strip(ix.e).k == 'var' and strip(ix.e).decl is i and v.ty.size in (1, 2, 4):
            return v
        if b.k == 'load' and strip(b.e).k == 'var' and strip(b.e).decl.kind == 'param' and v.ty.size == 1 and \
                ix.k == 'load' and strip(ix.e).k == 'var' and strip(ix.e).decl is i:
            direct.add(id(v)); return v                  # a char through a pointer parameter: (XWA+DE), no temporary
        return None
    direct = set()
    shapes = []; accs = []; lconst = False; byte_src = False; wide = False
    for x in st:
        e = x.e
        r0 = strip(e.r) if e.k == 'opassign' else None
        if e.k == 'opassign' and e.op in SIMPLE_OPS and regvar_like(e.l, f) and gacc(e.r) is not None:
            g = [gacc(e.r)]; shape = ('acc', g[0].ty.size)
        elif e.k == 'opassign' and e.op in '+-' and regvar_like(e.l, f) and r0.k == 'bin' and r0.op == '*' and \
                r0.ty.size == 2 and gacc(r0.l) is not None and gacc(r0.l).ty.size == 2 and strip(r0.r).k == 'load' \
                and strip(strip(r0.r).e).k == 'var':     # ol_idx_use: ld BC,(XDE+BC) / muls XBC,IX / add HL,BC
            g = [gacc(r0.l)]; shape = ('mul', 2)
        elif e.k == 'opassign' and e.op in '+-' and regvar_like(e.l, f) and r0.k == 'bin' and r0.op == '+' and \
                r0.ty.size == 2 and gacc(r0.l) is not None and gacc(r0.r) is not None and \
                gacc(r0.l).ty.size == 2 and gacc(r0.r).ty.size == 2:   # ol_two_arr: s += ga[i] + gb[i]
            g = [gacc(r0.l), gacc(r0.r)]; shape = ('sum2', 2); F.u1x_sum2 = id(e)
        elif e.k == 'bin' and e.op == '=' and strip(e.l).k == 'index' and gacc(u1_load_node(e.l)) is not None:
            lv = strip(e.l); r = strip(e.r)
            if fold(r).k == 'const' and fold(r).value is not None:
                g = [lv]; shape = ('k', lv.ty.size)
                if lv.ty.size == 4: lconst = True
            elif r.k == 'load' and strip(r.e).k == 'var' and strip(r.e).decl is i:
                g = [lv]; shape = ('i', lv.ty.size)
            elif gacc(e.r) is not None and strip(e.l).ty.size <= 2:
                rv = gacc(e.r); g = [lv, rv]; shape = ('copy', lv.ty.size, rv.ty.size)
                if rv.ty.size == 1: byte_src = True
                if rv.ty.size == 4: wide = True
            else: return False
        else: return False
        shapes.append(shape); accs.append(g)
    if len(set(shapes)) != 1: return False
    rf = u1alloc.RegFile()
    mentioned = set()
    walk([lp.cond, lp.body, getattr(lp, 'inc', None)] + ([loops0[0].cond] if oi is not None else []),
         lambda n, d: mentioned.add(n.decl) if n.k == 'var' else None)
    for p_ in f.params:
        if p_ in mentioned: rf.take(u1alloc.regname(p_.reg, W.get(p_.ty.size, 32)))
    locs = [d for d in f.decls if d.kind == 'local']
    if any(d.addr_taken or d.ty.kind not in ('int', 'ptr') or d.ty.size not in W for d in locs if d.uses): return False
    rets = []
    walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None
         and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    retv = [d for d in locs if d in rets]
    if len(retv) > 1 or i in retv: return False
    if retv: rf.take(u1alloc.RESULT[W[retv[0].ty.size]])
    # the template: the first statement's accesses in code order (an assignment's target first), each group
    # [chain (wide elements), base]; the groups are taken in reverse
    tmpl = accs[0]
    groups = []
    for k_, v in enumerate(tmpl):
        g = []
        if id(v) in direct: groups.append(g); continue
        if v.ty.size > 1: g.append(u1alloc.Obj(('chain', k_), 'chain', 16))
        g.append(u1alloc.Obj(('base', k_), 'chain', 32))
        groups.append(g)
    objs = []; key = 0
    for g in reversed(groups):
        for o in g: o.key = key; key += 1; objs.append(o)
    if lconst: objs.append(u1alloc.Obj('const', 'temp1', 32))
    elif byte_src: groups[-1][-1].cls = 'temp1'          # ol_c_copy: the byte loaded in place through its base
    else: min(objs, key=lambda o: o.key).cls = 'temp1'
    pref = u1_sum_pref(f, locs)
    pos = {d: k for k, d in enumerate(locs)}
    for d in locs:
        if d is i or d is oi or d in retv or not d.uses: continue
        objs.append(u1alloc.Obj(d, 'acc', W[d.ty.size], pos[d], pref=d is pref))
    objs.append(u1alloc.Obj(i, 'ctr', 16, pos[i]))
    if oi is not None:
        if oi in retv: return False
        objs.append(u1alloc.Obj(oi, 'ctr', 16, pos[oi]))
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    if any(o.reg.startswith('Q') or (o.reg in u1alloc.BYTEFAM and u1alloc.HALVES[u1alloc.family(o.reg)][0] != o.reg)
           for o in objs): return False
    if retv: retv[0].reg = 'HL'
    regs = {}
    for o in objs:
        if isinstance(o.what, tuple): regs[o.what] = u1alloc.family(o.reg)
        elif o.what == 'const': F.tfam = u1alloc.family(o.reg)
        else: o.what.reg = u1alloc.family(o.reg)
    acc = {}
    for g in accs:
        for k_, v in enumerate(g):
            if id(v) in direct: acc[id(v)] = (None, ('param', strip(strip(v.base).e).decl))
            else: acc[id(v)] = (regs.get(('chain', k_)), regs[('base', k_)])
    F.u1x = {'i': i, 'acc': acc, 'wide': wide}
    if shapes[0][0] == 'mul': F.u1_value = regs[('chain', 0)]
    if shapes[0][0] == 'sum2': F.u1x['sum2'] = regs[('chain', 1)]
    elif len(tmpl) == 2:                                   # the copy's value: in the source's chain (ld BC,(XDE+BC)),
        F.tfam = regs.get(('chain', 1)) or regs[('base', 1)]   # a char in its base's low byte (ld C,(XBC+IX))
    if any(u1alloc.family(o.reg) == 'IZ' for o in objs): F.emit('push', 'IZ'); F.push = 2; F.pushes = ['IZ']
    return True

def regvar_like(x, f):
    x = strip(x)
    return x.k == 'var' and x.decl.kind == 'local' and x.decl.ty.kind == 'int'

def u1_sum_pref(f, locs):
    """`return s0 + s1` prefers s0 for HL, `return s0 + s1 + s2` s1 (rule U1 step 7)"""
    out = []
    def v(n, d):
        if n.k != 'return' or n.value is None: return
        terms = []
        def t(x):
            x = strip(x)
            while x.k == 'cast': x = strip(x.e)
            if x.k == 'bin' and x.op == '+': t(x.l); t(x.r)
            else: terms.append(x)
        t(n.value)
        if len(terms) in (2, 3) and all(x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl in locs for x in terms):
            out.append(strip(terms[0 if len(terms) == 2 else 1].e).decl)
    walk(f.body, v)
    return out[0] if len(out) == 1 else None

def u1_global(F, lp, cl, rets0, outer=None):
    """rule U1 (u1alloc.py) for a counted loop over global arrays under -O3 -XS -Xr: the register parameters the
    loop mentions keep their registers, the returned local takes HL; then the first temporary (the shared element
    address of ra_leaf2: lda XBC,XIX+DE; a long store's constant, ol_l_clear: ld XBC,0x0; a loaded value,
    ol_i_copy: ld BC,(XHL+DE)), the offset IVs (one per element size), the hoisted bases (in order of first use),
    the other locals in reverse declaration order and the counter, each the first free of WA, BC, DE, HL, IX, IY,
    IZ.  A char element loaded into a register (ol_c_copy) is the byte temporary C."""
    import u1alloc
    f = F.f
    if 'kconst' in cl: return False
    rf = u1alloc.RegFile(); objs = []
    W = {1: 8, 2: 16, 4: 32}
    mentioned = set()
    for part in (lp.cond, lp.body, getattr(lp, 'inc', None)) + ((outer.cond, outer.inc) if outer is not None else ()):
        walk(part, lambda n, d: mentioned.add(n.decl) if n.k == 'var' else None)
    for p_ in f.params:
        if getattr(p_, 'reg', None) in u1alloc.WORDS and p_ in mentioned:
            rf.take(u1alloc.regname(p_.reg, W.get(p_.ty.size, 32)))
    locs = [d for d in f.decls if d.kind == 'local']
    oi = u1_for_head(outer)[0] if outer is not None else None
    if any(d.addr_taken or d.ty.kind not in ('int', 'ptr') or d.ty.size not in W for d in locs if d.uses): return False
    retv = [d for d in locs if d in rets0]
    if len(retv) > 1 or cl['i'] in retv: return False
    if retv: rf.take(u1alloc.RESULT[W[retv[0].ty.size]])
    kd = cl['k']; kp = Pseudo('bound', 2)
    kmem = False
    if cl.get('form') == 'down': pass                    # ol_down: k only initialises i (its register is free)
    elif getattr(kd, 'reg', None) in u1alloc.WORDS: kp.reg = kd.reg
    elif kd.kind == 'global': objs.append(u1alloc.Obj(kp, 'iv', 16))
    elif kd.kind == 'param' and not F.adecl and U1_CDECL_GLOBAL:
        if cl.get('form') == 'do': kmem = True           # O3XS ol_do: tested once, at the back-edge: cp DE,(XSP+0x4)
        else: objs.append(u1alloc.Obj(kp, 'cparam', 16, list(f.params).index(kd)))   # ol_i_copy: ld IX,(XSP+0x4)
    else: return False
    order = []                                           # arrays in evaluation order: an assignment's right side
    def ev(n):                                           # first (ol_i_copy: ga before gb)
        if isinstance(n, list):
            for x in n: ev(x)
            return
        if not hasattr(n, 'k'): return
        if n.k == 'bin' and n.op == '=': ev(n.r); ev(n.l); return
        if n.k == 'index' and strip(n.base).k == 'var' and strip(n.base).decl not in [a for a, _ in order]:
            order.append((strip(n.base).decl, n.ty.size))
        for k_, v_ in n.__dict__.items():
            if hasattr(v_, 'k') or isinstance(v_, list): ev(v_)
    ev(lp.body)
    if sorted(id(a) for a, _ in order) != sorted(id(a) for a, _ in cl['arrs']): return False
    reads = []; stores = []
    walk(lp.body, lambda n, d: reads.append(n) if n.k == 'load' and strip(n.e).k == 'index' else None)
    walk(lp.body, lambda n, d: stores.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index' else None)
    inop = []                                            # ol_idx_use: s += ga[i] * i -> ld BC,(XIX+DE) / muls XBC,IY
    walk(lp.body, lambda n, d: inop.append(n) if n.k == 'bin' and n.op in ('*', '+', '-', '&', '|', '^') and
         any(x is r for x in (strip(n.l), strip(n.r)) for r in reads) else None)
    def unc(x):
        x = strip(x)
        while x.k == 'cast': x = strip(x.e)
        return x
    copy = len(order) == 2 and len(stores) == 1 and len(reads) == 1 and unc(stores[0].r) is reads[0] and \
        strip(stores[0].l).ty.size <= 2
    tmp = None; byte = False; bcse = None
    if len(order) > 1 and not copy: return False         # (ol_two_arr: exception 2 of the README)
    if copy and reads[0].ty.size == 1:
        if not F.adecl: rf.take('A'); byte = 'WA'        # cdecl: the byte temporary is A
        elif 'C' in rf.busy or 'B' in rf.busy: return False   # (a parameter in BC to evict: not modelled here)
        else: rf.take('C'); byte = 'BC'                  # ol_c_copy: ld C,(XHL+IY) / exts BC / ld (XIX+DE),BC
    elif copy:
        tmp = u1alloc.Obj('copy', 'temp1', W[reads[0].ty.size]); objs.append(tmp)   # ol_l_copy: ld XBC,(XIX+DE)
    elif len(reads) == 2 and cl['esz'] > 1 and not stores:
        tmp = u1alloc.Obj('tmp', 'temp1', 32); objs.append(tmp)       # ra_leaf2: lda XBC,XIX+DE / (XBC) twice
    elif len(reads) >= 2 and cl['esz'] == 1 and not stores and len(order) == 1 and U1_BYTE_CSE and all(
            x.k == 'expr' and x.e.k == 'opassign' and x.e.op in SIMPLE_OPS and strip(x.e.l).k == 'var' and
            strip(x.e.l).decl.ty.size == 1 and any(unc(x.e.r) is r_ for r_ in reads)
            for x in flat(cl.get('body', lp.body))):
        if F.adecl:                                      # ol_c_acc2: ld C,(XDE+IX) / add L,C / add B,C (the element
            if 'C' in rf.busy or 'B' in rf.busy: return False   # loaded once into the byte temporary)
            rf.take('C'); bcse = 'C'
        else: rf.take('A'); bcse = 'A'                   # cdecl: A (s1 in W)
        tmp = None
    elif len(reads) >= 2: return False                   # three reads of a wide element: the base copies of
                                                         # exception 1 (not modelled)
    elif stores and cl['esz'] == 4 and fold(stores[0].r).k == 'const' and not reads:
        tmp = u1alloc.Obj('const', 'temp1', 32); objs.append(tmp)     # ol_l_clear: ld XBC,0x0 / ld (XHL+DE),XBC
    elif reads and inop and not stores and cl['esz'] == 2:
        tmp = u1alloc.Obj('value', 'temp1', 16); objs.append(tmp)
    elif KLOOP_VALUE_WA and reads and not stores and not inop and any(
            x.k == 'expr' and strip(x.e).k == 'bin' and strip(x.e).op == '=' and strip(strip(x.e).l).k == 'var' and
            strip(strip(x.e).l).decl.kind == 'global' and unc(strip(x.e).r) in reads
            for x in flat(cl.get('body', lp.body))):
        tmp = u1alloc.Obj('gvalue', 'temp1', 16); objs.append(tmp)   # lnr.c r_ga_rd (-O3 -XS): gr = ga[i] ->
                                                                     # ld WA,(XDE+BC) / ld (_gr),WA
    elif reads and stores or len(stores) > 1 or inop: return False   # other value temporaries
    offs = {}; bases = {}
    for a_, esz in order:
        if esz > 1 and esz not in offs:
            offs[esz] = Pseudo('offset', 2); objs.append(u1alloc.Obj(offs[esz], 'off', 16, len(offs)))
    for a_, esz in order:
        bases[a_] = Pseudo('base', 4); objs.append(u1alloc.Obj(bases[a_], 'base', 32, len(bases)))
    pref = u1_sum_pref(f, locs)
    pos = {d: k for k, d in enumerate(locs)}
    for d in locs:
        if d is cl['i'] or d is oi or d in retv or not d.uses: continue
        objs.append(u1alloc.Obj(d, 'acc', W[d.ty.size], pos[d], pref=d is pref))
    objs.append(u1alloc.Obj(cl['i'], 'ctr', 16, pos[cl['i']]))
    if oi is not None:
        if oi in retv: return False
        objs.append(u1alloc.Obj(oi, 'ctr', 16, pos[oi]))   # ol_nested: j IX, i IY (reverse declaration)
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    for o in objs:
        r = o.reg
        if r.startswith('Q') or (r in u1alloc.BYTEFAM and u1alloc.HALVES[u1alloc.family(r)][0] != r and
                                 not (bcse and o.cls == 'acc')): return False
    # commit
    if retv: retv[0].reg = 'HL'
    cl['kp'] = kp
    if kp.reg is not None and kd.kind == 'param': cl['k_in_reg'] = True
    if kmem: cl['k_mem'] = True
    for o in objs:
        fam = u1alloc.family(o.reg)
        if bcse and o.cls == 'acc' and o.reg in u1alloc.BYTEFAM and u1alloc.HALVES[fam][0] != o.reg:
            o.what.reg = o.reg; continue                 # a char accumulator in a high half (ol_c_acc2: s1 in B)
        if o.what is kp and not F.adecl: kp.reg = fam; continue
        if o is tmp:
            if o.what == 'gvalue':                         # (store_global loads the value into WA)
                if fam != 'WA': raise Unsupported('global store value not in WA')
                continue
            if o.what == 'tmp': cl['tmp'] = fam
            elif o.what == 'value': F.u1_value = fam
            else: F.tfam = fam
        else: o.what.reg = fam
    if byte: F.tfam = byte
    cl['copy_wide'] = copy and reads[0].ty.size == 4
    if bcse: cl['bcse'] = bcse; F.u1_bcse = True
    if outer is not None and not F.adecl and kp.reg is not None and kd.kind == 'param':
        kd.reg = kp.reg; F.u1_bound = kd; cl['k_in_reg'] = True   # O3XS ol_nested: ld DE,(XSP+0x4) before the
                                                                  # outer test, both loops compare with DE
    cl['u1'] = True; cl['order'] = order; cl['bases'] = bases; cl['offs'] = offs
    cl['base'] = bases[cl['arr']]
    if cl['esz'] > 1: cl['off'] = offs[cl['esz']]
    allregs = [o.reg for o in objs] + [u1alloc.regname('HL', W[d.ty.size]) for d in retv]
    if any(u1alloc.family(r) == 'IZ' for r in allregs):
        x = 'XIZ' if 'XIZ' in allregs else 'IZ'
        F.emit('push', x); F.push = 4 if x == 'XIZ' else 2; F.pushes = [x]
    else: F.pushes = []
    return True

def live_across_call(body):
    """is a variable read after a call on some path?  A branch that ends in a return does not carry its call on
    (_ltoa: the then-branch returns ultoa(...) - 1, the else-branch reads the parameters again); inside one
    expression only reads in the call's own arguments count as before it."""
    def reads(n):
        out = []
        walk(n, lambda m, d: out.append(m) if m.k == 'load' and strip(m.e).k == 'var' else None)
        return out
    def calls(n):
        out = []
        walk(n, lambda m, d: out.append(m) if m.k == 'call' or fpgen.is_fp_op(m) or fpgen.is_fp_copy(m) else None)
        return out
    def expr_bad(e, seen):
        cs = calls(e)
        if seen and reads(e): return True
        if not cs: return False
        inside = [set(id(x) for a in getattr(c, 'args', [c]) for x in reads(a)) for c in cs]
        return any(not all(id(x) in s for s in inside) for x in reads(e))   # k_expr: r1(a) + r1(a + 1) keeps a
    def ends_return(st):
        if st is None: return False
        if st.k == 'return': return True
        if st.k == 'block' and st.body: return ends_return(st.body[-1])
        return False
    def stmts(lst, seen):
        for st in lst:
            r = stmt(st, seen)
            if r is None: return None
            seen = r
        return seen
    def stmt(st, seen):                                # -> new 'call seen' state, or None if a read follows a call
        if st is None: return seen
        k = st.k
        if k == 'block': return stmts(st.body, seen)
        if k == 'decl': return seen if st.init is None else (None if expr_bad(st.init, seen) else seen or bool(calls(st.init)))
        if k in ('expr', 'return'):
            e = st.e if k == 'expr' else st.value
            if e is None: return seen
            if expr_bad(e, seen): return None
            return seen or bool(calls(e))
        if k == 'if':
            if expr_bad(st.cond, seen): return None
            seen = seen or bool(calls(st.cond))
            a = stmt(st.then, seen); b = stmt(st.els, seen)
            if a is None or b is None: return None
            return (a and not ends_return(st.then)) or (b and not ends_return(st.els))
        if k in ('for', 'while', 'do'):
            if calls(st) and reads(st): return None
            return seen
        if calls(st): return None
        return seen
    return stmt(body, False) is None

def u1_for_head(lp, const=False):
    """for (i = c; i < k; i++) with i an int local and k a parameter (or, with `const`, a constant): (i, k's
    load), else None"""
    if lp.init is None or lp.cond is None or lp.inc is None: return None
    ini = flat(lp.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return None
    iv = strip(strip(ini[0].e).l)
    if iv.k != 'var' or iv.decl.kind != 'local' or iv.decl.ty.size != 2 or fold(strip(ini[0].e).r).k != 'const': return None
    i = iv.decl
    c = strip(lp.cond)
    if not (c.k == 'bin' and c.op == '<' and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var'
            and strip(strip(c.l).e).decl is i): return None
    kv = strip(c.r)
    while kv.k == 'cast': kv = strip(kv.e)
    if const and fold(c.r).k == 'const': pass
    elif not (kv.k == 'load' and strip(kv.e).k == 'var' and strip(kv.e).decl.kind == 'param'): return None
    inc = strip(lp.inc)
    if not (inc.k == 'incdec' and inc.op == '++' and strip(inc.e).k == 'var' and strip(inc.e).decl is i): return None
    return i, kv

def cl_i(s):
    """the counter of for (i = ...; ...; i--)"""
    return strip(strip(s.inc).e).decl

def u1_down_head(lp):
    """for (i = n - 1; i >= 0; i--) with i an int local and n a parameter (oc_down): (i, None)"""
    if lp.init is None or lp.cond is None or lp.inc is None: return None
    ini = flat(lp.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return None
    iv = strip(strip(ini[0].e).l); r = strip(strip(ini[0].e).r)
    if iv.k != 'var' or iv.decl.kind != 'local' or iv.decl.ty.size != 2: return None
    if not (r.k == 'bin' and r.op == '-' and fold(r.r).k == 'const' and fold(r.r).value == 1 and
            strip(r.l).k == 'load' and strip(strip(r.l).e).k == 'var' and strip(strip(r.l).e).decl.kind == 'param'
            and strip(strip(r.l).e).decl.ty.size == 2): return None
    i = iv.decl; c = strip(lp.cond)
    if not (c.k == 'bin' and c.op == '>=' and fold(c.r).k == 'const' and fold(c.r).value == 0 and
            strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var' and strip(strip(c.l).e).decl is i): return None
    inc = strip(lp.inc)
    if not (inc.k == 'incdec' and inc.op == '--' and strip(inc.e).k == 'var' and strip(inc.e).decl is i): return None
    return i, None

def u1_down2(F):
    """for (; n > 0; n--) s += p[n - 1]; under -Xr (oc_down2): -O keeps the derived IV n - 1 in its own register
    (class iv: ld DE,BC / dec 0x1,DE after the guard, dec 0x1,BC / dec 0x1,DE at the back-edge) and builds the chain
    from it (IX); plain -Xr builds the chain from n each time (ld DE,BC / dec 0x1,DE / exts XDE / ... / sub BC,0x1 /
    j gt,L1)"""
    import u1alloc
    f = F.f
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    if len(loops) != 1 or loops[0].k != 'for' or loops[0].init is not None: return False
    lp = loops[0]; c = strip(lp.cond); inc = strip(lp.inc) if lp.inc is not None else None
    if not (c.k == 'bin' and c.op == '>' and fold(c.r).k == 'const' and fold(c.r).value == 0 and
            strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var'): return False
    n = strip(strip(c.l).e).decl
    if n.kind != 'param' or n.ty.size != 2 or getattr(n, 'reg', None) not in ('WA', 'BC', 'DE'): return False
    if not (inc is not None and inc.k == 'incdec' and inc.op == '--' and strip(inc.e).k == 'var' and strip(inc.e).decl is n):
        return False
    st = flat(lp.body)
    if len(st) != 1 or st[0].k != 'expr' or st[0].e.k != 'opassign' or st[0].e.op not in '+-': return False
    e = st[0].e; sv = strip(e.l); r = strip(e.r)
    if sv.k != 'var' or r.k != 'load' or strip(r.e).k != 'index' or r.ty.size != 2: return False
    v = strip(r.e); b = strip(v.base); ix, k = split_index(v.idx); ix = strip(ix)
    while ix.k == 'cast': ix = strip(ix.e)
    if k != -1 or not (b.k == 'load' and strip(b.e).k == 'var' and getattr(strip(b.e).decl, 'reg', None) and
                       strip(b.e).decl.kind == 'param') or not (ix.k == 'load' and strip(ix.e).decl is n): return False
    locs = [d for d in f.decls if d.kind == 'local']
    if locs != [sv.decl] or sv.decl.ty.size != 2: return False
    rets = []
    walk(f.body, lambda m, d: rets.append(strip(strip(m.value).e).decl) if m.k == 'return' and m.value is not None
         and strip(m.value).k == 'load' and strip(strip(m.value).e).k == 'var' else None)
    if rets != [sv.decl]: return False
    if any(getattr(p_, 'reg', None) not in ('WA', 'BC', 'DE') for p_ in f.params): return False
    rf = u1alloc.RegFile()
    for p_ in f.params: rf.take(u1alloc.regname(p_.reg, 32 if p_.ty.size == 4 else 16))
    rf.take('HL')
    objs = ([u1alloc.Obj('iv', 'iv', 16)] if F.opt else []) + [u1alloc.Obj('chain', 'temp1', 32)]
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    sv.decl.reg = 'HL'
    F.u1_down2 = {'lp': lp, 'n': n, 'p': strip(b.e).decl, 'op': e.op,
                  'iv': u1alloc.family(objs[0].reg) if F.opt else None, 'chain': u1alloc.family(objs[-1].reg)}
    return True

def u1_block_copy(F):
    """-O: for (i = 0; i < K; i++) a[i] = g[i]; with a a char pointer parameter, g a global char array and K even:
    a word block copy (oc_cpy_g, O3XSXr: ld XIY,_gca / ld XIX,XWA / ld BC,0x5 / ldirw (XIX+),(XIY+); O3XS: ld
    XIX,(XSP+0x4) / ld XIY,_gca / ...)"""
    f = F.f
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    if len(loops) != 1 or loops[0].k != 'for' or flat(f.body)[-1] is not loops[0]: return False
    lp = loops[0]
    if lp.init is None or lp.cond is None or lp.inc is None: return False
    ini = flat(lp.init)
    if len(ini) != 1 or ini[0].k != 'expr' or strip(ini[0].e).k != 'bin' or strip(ini[0].e).op != '=': return False
    iv = strip(strip(ini[0].e).l)
    if iv.k != 'var' or fold(strip(ini[0].e).r).k != 'const' or fold(strip(ini[0].e).r).value != 0: return False
    i = iv.decl; c = strip(lp.cond); inc = strip(lp.inc)
    if not (c.k == 'bin' and c.op == '<' and strip(c.l).k == 'load' and strip(strip(c.l).e).k == 'var' and
            strip(strip(c.l).e).decl is i and fold(c.r).k == 'const'): return False
    K = fold(c.r).value
    if not (inc.k == 'incdec' and inc.op == '++' and strip(inc.e).k == 'var' and strip(inc.e).decl is i): return False
    if not isinstance(K, int) or K <= 0 or K % 2: return False
    st = flat(lp.body)
    if len(st) != 1 or st[0].k != 'expr' or st[0].e.k != 'bin' or st[0].e.op != '=': return False
    lv = strip(st[0].e.l); r = strip(st[0].e.r)
    while r.k == 'cast': r = strip(r.e)
    if lv.k != 'index' or r.k != 'load' or strip(r.e).k != 'index' or lv.ty.size != 1 or r.ty.size != 1: return False
    def idx_ok(v):
        x = strip(v.idx)
        while x.k == 'cast': x = strip(x.e)
        return x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl is i
    rv = strip(r.e); db = strip(lv.base); sb = strip(rv.base)
    if not (idx_ok(lv) and idx_ok(rv)): return False
    if not (db.k == 'load' and strip(db.e).k == 'var' and strip(db.e).decl.kind == 'param' and
            sb.k == 'var' and sb.decl.kind == 'global' and sb.decl.ty.kind == 'array'): return False
    if any(d.uses for d in f.decls if d.kind == 'local' and d is not i): return False
    F.u1_block = (lp, strip(db.e).decl, sb.decl, K // 2)
    return True

def leaf_u1(F):
    """-O3 -XS -Xr leaf with one counted for loop over pointer parameters (rule U1, research-scratch
    sessions/2026-11-09_cc900-counted-loops 6357bd2): the parameters keep their registers, a returned local takes
    HL, then the byte temporary (C; BC's parameter moves to the first free of DE, HL) or the index chain, then the
    other locals in reverse declaration order, then the counter, each the first free of WA, BC, DE, HL, IX, IY, IZ"""
    f = F.f
    loops = []
    walk(f.body, lambda n, d: loops.append(n) if n.k in ('for', 'while', 'do') else None)
    if len(loops) == 2 and all(x.k == 'for' for x in loops):   # oc_nested: for i { for j { ... } }
        ob = loops[0].body
        while ob is not None and ob.k == 'block' and len(ob.body) == 1: ob = ob.body[0]
        if ob is not loops[1]: return False
        heads = [u1_for_head(x) for x in loops]
        if None in heads or heads[0][0] is heads[1][0]: return False
        lp = loops[1]; i = heads[1][0]; kv = heads[1][1]; outer = heads[0][0]; okv = heads[0][1]
    elif len(loops) != 1 or loops[0].k != 'for': return False
    else:
        lp = loops[0]; h = u1_for_head(lp)
        if h is None: h = u1_down_head(lp)               # oc_down: for (i = n - 1; i >= 0; i--)
        if h is None: return False
        i, kv = h; outer = None
    params = list(f.params)
    cdecl = not F.adecl
    if not cdecl and any(getattr(p, 'reg', None) not in ('WA', 'BC', 'DE') for p in params): return False
    acc = []; bad = []
    def v(n, d):
        if n.k == 'index':
            b = strip(n.base); ix = strip(n.idx)
            while ix.k == 'cast': ix = strip(ix.e)
            if b.k == 'load' and strip(b.e).k == 'var' and (strip(b.e).decl in params or (
                    strip(b.e).decl.kind == 'global' and n.ty.size > 1)) and ix.k == 'load' and \
                    strip(ix.e).k == 'var' and strip(ix.e).decl is i:
                acc.append((strip(b.e).decl, n.ty.size))   # (ol_gptr: gp[i] through a global pointer, -Xr)
            else: bad.append(n)
        if n.k == 'call' or fpgen.is_fp_op(n) or long_helper_node(n): bad.append(n)
    walk(lp.body, v)
    if not bad and not acc and (F.adecl or (F.opt and outer is None)):   # ra_param3, ol_inv, ra_nested: no array
        locs = [d for d in f.decls if d.kind == 'local']
        rets = []
        walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None
             and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
        retv = [d for d in locs if d in rets]
        if len(retv) > 1: return False
        return leaf_u1_noarr(F, lp, [outer, i] if outer is not None else [i], params, locs, retv, kv)
    if bad or not acc or len({p for p, _ in acc}) > 2: return False
    if len({p for p, _ in acc if _ > 1}) > 1 and (cdecl or any(sz != 2 for _, sz in acc)): return False
                                                         # two wide arrays: the held copy (oc_add2), -Xr ints only
    locs = [d for d in f.decls if d.kind == 'local']
    rets = []
    walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None
         and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    retv = [d for d in locs if d in rets]
    if len(retv) > 1: return False
    if cdecl: return leaf_u1_cdecl(F, lp, i, kv, params, acc, locs, retv, outer, okv if outer is not None else None)
    return leaf_u1_adecl(F, lp, [outer, i] if outer is not None else [i], params, acc, locs, retv)

def leaf_u1_noarr(F, lp, ctrs, params, locs, retv, kv=None):
    """U1 for a counted loop whose body is `s += x * y` (-O3 -XS -Xr): with x and y parameters the product is a
    hoisted invariant computed in place in x's register after the guard (ra_param3, ol_inv: muls XBC,DE / L1: add
    HL,BC); else it is the value temporary, the first free register (ra_nested: ld BC,IX / muls XBC,DE / add HL,BC);
    then the counters in reverse declaration order"""
    import u1alloc
    st = flat(lp.body)
    if len(st) != 1 or st[0].k != 'expr': return False
    e = st[0].e
    if e.k != 'opassign' or e.op not in '+-' or strip(e.l).k != 'var' or strip(e.l).decl not in retv: return False
    r = strip(e.r)
    if r.k != 'bin' or r.op != '*' or r.ty.size != 2 or not r.ty.signed: return False
    ops = [strip(x) for x in (r.l, r.r)]
    if not all(x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl.ty.size == 2 for x in ops): return False
    xs = [strip(x.e).decl for x in ops]
    modified = []
    walk(F.f.body, lambda n, d: modified.append(strip(n.e).decl) if n.k == 'incdec' and strip(n.e).k == 'var' else None)
    walk(F.f.body, lambda n, d: modified.append(strip(n.l).decl) if n.k in ('bin', 'opassign') and
         (n.k == 'opassign' or n.op == '=') and strip(n.l).k == 'var' else None)
    inv = all(x in params and x not in modified for x in xs) and xs[0] is not xs[1]
    if not inv and not all(x in ctrs for x in xs): return False
    if not F.opt: inv = False                            # plain -Xr: nothing hoisted (ra_param3: ld IX,BC / muls XIX,DE)
    if inv and len(ctrs) != 1: return False
    if not F.adecl and (not inv or kv is None): return False
    rf = u1alloc.RegFile()
    if F.adecl:
        for p_ in params: rf.take(p_.reg)
    if retv[0].ty.size != 2: return False
    rf.take('HL')
    objs = [] if inv else [u1alloc.Obj('value', 'temp1', 16)]
    bound = strip(kv.e).decl if kv is not None and not F.adecl else None
    if not F.adecl:                                      # O3XS ol_inv: ld WA,(XSP+0x6) / muls XWA,(XSP+0x8) after the
        if bound in xs: return False                     # guard, the bound in BC, i in DE
        objs.append(u1alloc.Obj('inv', 'inv', 16))
        objs.append(u1alloc.Obj(bound, 'cparam', 16, list(params).index(bound)))
    pos = {d: k for k, d in enumerate(locs)}
    if any(d not in ctrs and d not in retv and d.uses for d in locs): return False
    for c_ in ctrs: objs.append(u1alloc.Obj(c_, 'ctr', 16, pos[c_]))
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    if any(o.reg.startswith('Q') for o in objs): return False
    retv[0].reg = 'HL'
    T = None
    for o in objs:
        if o.what == 'value': F.u1_value = o.reg
        elif o.what == 'inv': T = o.reg
        else: o.what.reg = o.reg
    if inv: F.u1_inv = (lp, r, xs[0], xs[1], T)
    if bound is not None: F.u1_bound = bound
    if any(o.reg == 'IZ' for o in objs): F.emit('push', 'IZ'); F.push = 2; F.pushes = ['IZ']
    return True

def leaf_u1_adecl(F, lp, ctrs, params, acc, locs, retv):
    """U1 under -O3 -XS -Xr for counted loops over pointer parameters (u1alloc.py): the parameters keep their
    registers, a returned local takes HL / XHL / L; the byte temporary is C (BC's parameter moves to the first
    free of DE, HL: oc_cpy_abn ld XHL,XBC); then the first temporary (a long store's constant, oc_clr_l: ld
    XDE,0x0; else the index chain, oc_sum_pn: DE), the other locals and the counters in reverse declaration order
    (oc_nested: j IY, i IZ), each the first free of WA, BC, DE, HL, IX, IY, IZ"""
    import u1alloc
    W = {1: 8, 2: 16, 4: 32}
    rf = u1alloc.RegFile(); live = {}
    down = u1_down_head(lp)                              # oc_down: n only initialises i -> its register is free
    dn = strip(strip(strip(strip(flat(lp.init)[0].e).r).l).e).decl if down else None
    if down:
        seen = []
        walk([lp.cond, lp.body, lp.inc] + [x for x in flat(F.f.body) if x is not lp],
             lambda n_, d_: seen.append(n_) if n_.k == 'var' and n_.decl is dn else None)
        if seen: return False
    for p_ in params:
        if p_ is dn: continue
        live[p_] = u1alloc.regname(p_.reg, W.get(p_.ty.size, 32)); rf.take(live[p_])
    if any(d.ty.size not in W for d in locs if d.uses): return False
    if retv: rf.take(u1alloc.RESULT[W[retv[0].ty.size]])
    byte = []                                            # a char loaded into a register: stored or widened, not
    def bv(n, d):                                        # compared (oc_cnt_c: cp (XWA+IX),E) nor a constant store
        if n.k in ('bin', 'opassign') and (n.k == 'opassign' or n.op == '=') and fold(n.r).k != 'const':
            walk(n.r, lambda m, dd: byte.append(m) if m.k == 'load' and strip(m.e).k == 'index' and m.ty.size == 1 else None)
    walk(lp.body, bv)
    wide = [sz for _, sz in acc if sz > 1]
    lconst = []                                          # oc_clr_l: p[i] = 0 on longs -> ld XDE,0x0 / ld (XHL),XDE
    walk(lp.body, lambda n, d: lconst.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index' and
         strip(n.l).ty.size == 4 and fold(n.r).k == 'const' else None)
    moves = []
    if byte:
        try: _, moves = u1alloc.byte_temp(rf, live, reloc=('DE', 'HL'))
        except u1alloc.Fail: return False
        rf.take('B')                                     # (the byte is widened in BC: oc_sum_c exts BC)
    objs = []
    if not F.opt and lconst: return False                # plain -Xr oc_clr_l: exception 3 of the README
    if len({p_ for p_, sz in acc if sz > 1}) > 1: objs.append(u1alloc.Obj('held', 'held', 32))   # oc_add2: XIY
    if lconst: objs.append(u1alloc.Obj('const', 'temp1', 32))
    if wide: objs.append(u1alloc.Obj('chain', 'temp1' if not lconst else 'chain', 32))
    pos = {d: k for k, d in enumerate(locs)}
    for d in locs:
        if d in ctrs or d in retv or not d.uses: continue
        objs.append(u1alloc.Obj(d, 'acc', W[d.ty.size], pos[d]))
    for c_ in ctrs:
        if c_ not in retv: objs.append(u1alloc.Obj(c_, 'ctr', 16, pos[c_]))
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    if any(o.reg.startswith('Q') or (o.reg in u1alloc.BYTEFAM and u1alloc.HALVES[u1alloc.family(o.reg)][0] != o.reg)
           for o in objs): return False
    if retv: retv[0].reg = 'HL'
    for o in objs:
        fam = u1alloc.family(o.reg)
        if o.what == 'const': F.tfam = fam
        elif o.what == 'chain': F.u1_chain = fam
        elif o.what == 'held': F.u1_held = fam
        else: o.what.reg = fam
    if byte: F.tfam = 'BC'
    for h, old, new in moves: h.reg = u1alloc.family(new)
    F.u1_i = ctrs[-1]
    for v_, src, dst in moves:
        F.emit('ld', '%s,%s' % (dst, src))
    if down and not F.opt: F.u1_down_xr = (lp, dn)      # plain -Xr oc_down: ld DE,BC / sub DE,0x1 / ret lt
    elif down:                                           # oc_down: ld DE,BC at entry, dec 0x1,DE as the loop's init
        from frontend import N
        i = ctrs[-1]
        F.emit('ld', '%s,%s' % (FAM[i.reg][2], FAM[dn.reg][2]))
        lp.init = N('expr', e=N('incdec', op='--', post=False, e=N('var', decl=i, ty=i.ty), ty=i.ty)); F.u1_down = lp
    iz = [o.reg for o in objs if u1alloc.family(o.reg) == 'IZ']
    if iz:                                               # oc_sum2: the held copy in XIZ -> push XIZ
        x = 'XIZ' if 'XIZ' in iz else 'IZ'
        F.emit('push', x); F.push = 4 if x == 'XIZ' else 2; F.pushes = [x]
    return True

def leaf_u1_cdecl(F, lp, i, kv, params, acc, locs, retv, outer=None, okv=None):
    """U1 under cdecl -O3 -XS (opt_counted.c O3XS; u1alloc.py): the loop bound gets a register, loaded just before
    the first test; a parameter used more than once is kept in a register, loaded at its first use (oc_max: ld
    XDE,(XSP+0x4) / ld HL,(XDE)); one used once per iteration stays on the stack (oc_find: cp WA,(XSP+0xa)); a
    pointer read once per iteration is reloaded at each use.  The first temporary takes WA (the byte, through the
    pointer it is loaded through; else a long store's constant; else the index chain); then the kept parameters and
    the directly used pointers in reverse declaration order, the chain (when not first), the chain operands' reloads
    (into WA, BC, DE or HL, else read as a memory operand: oc_nested add XWA,(XSP+0x4)), the other locals, the
    counter (oc_sum_pn: chain WA, n BC, p's reload XDE, s HL, i IX; oc_cpy_abn: b's reload WA, n BC, a's DE, i HL;
    oc_clr_l: ld XWA,0x0 the constant, n BC, chain DE, p's reload XHL, i IX)"""
    import u1alloc
    W = {1: 8, 2: 16, 4: 32}
    rf = u1alloc.RegFile(); objs = []
    if any(d.ty.size not in W for d in locs if d.uses): return False
    if retv: rf.take(u1alloc.RESULT[W[retv[0].ty.size]])
    down = kv is None                                    # O3XS oc_down: for (i = n - 1; i >= 0; i--)
    dn = strip(strip(strip(strip(flat(lp.init)[0].e).r).l).e).decl if down else None
    if down and outer is not None: return False
    bound = strip(kv.e).decl if not down else None
    obound = strip(okv.e).decl if okv is not None else None
    if obound is not None and obound is not bound and obound.ty.size != 2: return False
    ptrs = []
    for p_, sz in acc:
        if p_ not in ptrs: ptrs.append(p_)
    nuse = {}
    walk(F.f.body, lambda n, d: nuse.__setitem__(n.decl, nuse.get(n.decl, 0) + 1) if n.k == 'var' else None)
    inloop = {}
    walk(lp.body, lambda n, d: inloop.__setitem__(n.decl, inloop.get(n.decl, 0) + 1) if n.k == 'var' else None)
    kept = [p_ for p_ in params if p_ is not bound and p_ is not obound and p_ is not dn and nuse.get(p_, 0) > 1]
    others = [p_ for p_ in params if p_ is not bound and p_ is not obound and p_ is not dn and p_ not in ptrs]
    if down and nuse.get(dn, 0) != 1: return False      # (oc_max: p[0] and p[i] keep p)
    if any(p_ in kept or inloop.get(p_, 0) != 1 for p_ in others): return False  # (k: once per iteration, stacked)
    if any(p_.ty.size not in W for p_ in kept): return False
    loads = []
    walk(lp.body, lambda m, dd: loads.append(m) if m.k == 'load' and strip(m.e).k == 'index' and m.ty.size == 1 else None)
    byte_src = None
    if loads:
        b = strip(strip(loads[0].e).base); byte_src = strip(b.e).decl if b.k == 'load' and strip(b.e).k == 'var' else None
        if byte_src in kept: return False
    wide = [p_ for p_, sz in acc if sz > 1]
    lconst = []
    walk(lp.body, lambda n, d: lconst.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index' and
         strip(n.l).ty.size == 4 and fold(n.r).k == 'const' else None)
    pidx = {p_: k for k, p_ in enumerate(params)}
    reload = {}
    if byte_src is not None:
        o = u1alloc.Obj(('reload', byte_src), 'temp1', 32); objs.append(o)
    elif lconst: objs.append(u1alloc.Obj('const', 'temp1', 32))
    if wide and (byte_src is not None or lconst): objs.append(u1alloc.Obj('chain', 'chain', 32))
    elif wide: objs.append(u1alloc.Obj('chain', 'temp1', 32))
    direct = [p_ for p_ in ptrs if p_ is not byte_src and p_ not in kept and all(sz == 1 for q, sz in acc if q is p_)]
    for p_ in params:
        if p_ is bound or p_ is obound or p_ in kept:
            objs.append(u1alloc.Obj(p_, 'cparam', W.get(p_.ty.size, 32), pidx[p_]))
        elif p_ in direct: objs.append(u1alloc.Obj(('reload', p_), 'cparam', 32, pidx[p_]))
    pos = {d: k for k, d in enumerate(locs)}
    for d in locs:
        if d is i or d is outer or d in retv or not d.uses: continue
        objs.append(u1alloc.Obj(d, 'acc', W[d.ty.size], pos[d]))
    if i not in retv: objs.append(u1alloc.Obj(i, 'ctr', 16, pos[i]))
    if outer is not None:
        if outer in retv: return False
        objs.append(u1alloc.Obj(outer, 'ctr', 16, pos[outer]))   # oc_nested: j IX, i IY
    try: u1alloc.allocate(objs, rf)
    except u1alloc.Fail: return False
    # the chain operands' reloads: after the parameters (oc_sum_np: chain WA, n BC, p's reload DE), before the
    # locals (they are temporaries of the iteration, so only WA, BC, DE, HL are tried here)
    order = sorted(objs, key=lambda o: (u1alloc.ORDER.index(o.cls), -o.key if o.cls in u1alloc.REVERSE else o.key))
    rf2 = u1alloc.RegFile(); late = []
    if retv: rf2.take(u1alloc.RESULT[W[retv[0].ty.size]])
    for o in order:
        if o.cls in ('acc', 'ctr', 'held'): late.append(o); continue
        rf2.take(o.reg)
    mem = []
    for p_ in ptrs:
        if p_ is byte_src or p_ in kept or p_ in direct or p_.kind == 'global': continue
        r = next((f_ for f_ in ('WA', 'BC', 'DE', 'HL') if rf2.fits('X' + f_)), None)
        if r is None: mem.append(p_); continue
        rf2.take('X' + r); reload[p_] = r
    for o in late:                                       # the locals and the counter again, after the reloads
        o.reg = rf2.first(o.w)
        if o.reg is None: return False
        rf2.take(o.reg)
    if any(o.reg.startswith('Q') or (o.reg in u1alloc.BYTEFAM and u1alloc.HALVES[u1alloc.family(o.reg)][0] != o.reg)
           for o in objs): return False
    # commit
    if retv: retv[0].reg = 'HL'
    F.u1_reload = {}
    for o in objs:
        fam = u1alloc.family(o.reg)
        if isinstance(o.what, tuple): F.u1_reload[o.what[1]] = fam
        elif o.what == 'const': F.tfam = fam
        elif o.what == 'chain': F.u1_chain = fam
        else: o.what.reg = fam
    for p_, r in reload.items(): F.u1_reload[p_] = r
    F.u1_mem = set(mem)
    sv = []                                              # oc_fill_i: p[i] = v with v on the stack -> v is loaded
    walk(lp.body, lambda n, d: sv.append(n) if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index' and   # into the
         strip(n.r).k == 'load' and strip(strip(n.r).e).k == 'var' and strip(strip(n.r).e).decl in others else None)
    if sv and len(reload) == 1 and not lconst and byte_src is None:      # reload's register, free after the add:
        F.tfam = list(reload.values())[0]                # ld XDE,(XSP+0x4) / add XWA,XDE / ld DE,(XSP+0xa) / ld (XWA),DE
    if byte_src is not None: F.tfam = 'WA'
    for p_ in kept:
        F.param_copies.append(p_)
    F.deferred = list(kept)
    F.u1_i = i; F.u1_bound = bound
    if down:                                             # ld DE,(XSP+0x8) / dec 0x1,DE / j L1 (the dec not merged)
        from frontend import N
        lp.init = N('block', body=[
            N('expr', e=N('bin', op='=', l=N('var', decl=i, ty=i.ty), r=N_load(dn), ty=i.ty)),
            N('expr', e=N('incdec', op='--', post=False, e=N('var', decl=i, ty=i.ty), ty=i.ty))])
        F.u1_down = lp
    if obound is not None: F.u1_bounds = [obound] + ([bound] if bound is not obound else [])
    if any(u1alloc.family(o.reg) == 'IZ' for o in objs): F.emit('push', 'IZ'); F.push = 2; F.pushes = ['IZ']
    return True

def leaf_r6(F):
    """-O3 -XS -Xr leaf with one while loop: the temporary family T and the parameter moves (leafalloc.py)"""
    import leafalloc
    f = F.f
    ck = leafalloc.classify(f, strip, walk)
    if ck is None: return False
    kind, counter = ck
    params = [p for p in f.params if getattr(p, 'reg', None) in ('WA', 'BC', 'DE')]
    stackp = [p for p in f.params if p not in params]
    if any(p.ty.size > 2 for p in stackp): return False
    locs = [d for d in f.decls if d.kind == 'local']
    rets = []
    walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None
         and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    retloc = [d for d in locs if d in rets]
    if len(locs) > len(retloc) or len(retloc) > 1: return False
    arrival = {p: p.reg for p in params}
    try: T, final, rl = leafalloc.choose(arrival, counter, retloc[0] if retloc else None, kind, opt=F.opt)
    except leafalloc.Fail: return False
    mv = leafalloc.moves(params, arrival, final)
    for p in params: p.reg = final[p]
    if retloc: retloc[0].reg = rl
    F.tfam = T or 'WA'; F.tkind = kind
    for v, src, dst in mv:                                # ot_cpy_abn: ld HL,DE / ld XDE,XWA
        sz = v.ty.size if v.ty.size in (1, 2, 4) else 4
        F.emit('ld', '%s,%s' % (FAM[dst][sz], FAM[src][sz]))
    used = set(final.values()) | {T} | ({rl} if rl else set())
    for p in stackp:                                      # op_three: n from the stack into the first free of DE, HL,
        r = next((g for g in ('DE', 'HL', 'IX', 'IY') if g not in used), None)   # IX, IY -> ld IX,(XSP+0x4)
        if r is None: return False
        used.add(r); p.reg = r; F.emit('ld', '%s,(XSP+%s)' % (FAM[r][2], hx(p.off + F.push)))
    return True

L2_NOLOOP = True                                   # see leaf_l2 (__todigit)
L2_ONCE_MEM = True                                 # see leaf_l2 (__todigit)
L2_WIDE = False
THREAD_ALL = True

def leaf_l2(F):
    """cdecl -O3 -XS leaf functions with a table lookup (ctype.h): rule L2 (l2alloc.py; research-scratch
    sessions/2026-11-09_cc900-leaf-o3xs).  Classifies the parameters, locals and temporaries, allocates them, and
    leaves the temporaries' registers in F.l2: t1 (the index / byte scratch), tab_inv / tab_once (table bases,
    hoisted or per use), held (store addresses copied before the value is built)."""
    import l2alloc
    f = F.f
    tabs = []; loops = []
    def find(n, dep):
        if table_test(n): tabs.append((table_test(n), dep, n))
        if n.k in ('for', 'while', 'do'): loops.append(n)
    walk(f.body, find)
    early = one_early_call(F)
    if not tabs and not (early and loops) and not ((L2_WIDE and len(loops) >= 2 or getattr(F, 'had_goto', False)) and loops):
        return False                                     # (L2_WIDE: nested loops only -- _strspn; every loop cost
                                                         # pairs 223 -> 199, _strncmp / _strncpy among them)
    across = set()
    if early:                                            # _strrchr: s is read after strlen(s) -> XIZ
        seq = eval_sequence(f.body, [])
        ci = next((i for i, x in enumerate(seq) if x[0] in ('call', 'rcall')), None)
        li = next((i for i, x in enumerate(seq) if x[0] == 'loop'), None)
        late = ci is not None and li is not None and ci > li and last_is_call_return(f)
        if ci is None or (li is not None and ci > li and not late): return False   # _ultoa: memcpy last -- not yet
        if late: ci = len(seq)                            # _itoa: return memcpy(...) -- nothing lives across it
        before = {x[1] for x in seq[:ci] if x[0] in ('use', 'def')}    # _strrchr: c, first read after the call,
                                                                        # stays where it arrived
        for x in seq[ci + 1:]:
            if x[0] == 'use' and x[1] in before: across.add(x[1])
            if x[0] == 'loop':
                for y in x[1]:
                    if y[0] == 'use' and y[1] in before: across.add(y[1])
    pos = {}; k = [0]
    def order(n, dep):
        k[0] += 1
        if n.k == 'var' and n.decl not in pos: pos[n.decl] = k[0]
        if n.k == 'deref' and dep and strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' and \
                ('deref', strip(strip(n.e).e).decl) not in pos:
            pos[('deref', strip(strip(n.e).e).decl)] = k[0]  # a strength-reduced copy starts at its first dereference
        if table_test(n) and ('tab', table_test(n)[0]) not in pos: pos[('tab', table_test(n)[0])] = k[0]
    walk(f.body, order)
    rets = set()
    walk(f.body, lambda n, d: rets.add(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None and
         strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    inloop = {}; modified = set(); loopmod = set(); derefidx = set(); held_ptr = set(); held_nodes = []
    def info(n, dep):
        if n.k == 'var' and dep: inloop[n.decl] = inloop.get(n.decl, 0) + 1
        if n.k == 'incdec' and strip(n.e).k == 'var':
            modified.add(strip(n.e).decl)
            if dep: loopmod.add(strip(n.e).decl)
        if n.k in ('opassign',) and strip(n.l).k == 'var':
            modified.add(strip(n.l).decl)
            if dep: loopmod.add(strip(n.l).decl)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var':
            modified.add(strip(n.l).decl)
            if dep: loopmod.add(strip(n.l).decl)
        if table_test(n):
            x = table_test(n)[1]
            while x.k == 'cast': x = strip(x.e)
            if x.k == 'load' and strip(x.e).k == 'deref':
                pv = strip(strip(x.e).e)
                if pv.k == 'load' and strip(pv.e).k == 'var': derefidx.add(strip(pv.e).decl)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'deref':
            r = []
            walk(n.r, lambda m, dd: r.append(m) if m.k == 'cond' or table_test(m) else None)
            pv = strip(strip(n.l).e)
            if r and pv.k == 'load' and strip(pv.e).k == 'var':
                held_ptr.add(strip(pv.e).decl); held_nodes.append(n)
    walk(f.body, info)
    first_write = {}; bumped = set()                     # body: first assigned by a plain = inside a loop body,
    def fw(n, dep):                                      # never incremented or compound-assigned
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': first_write.setdefault(strip(n.l).decl, dep)
        if n.k == 'decl' and getattr(n, 'init', None) is not None: first_write.setdefault(n.var, dep)
        if n.k == 'incdec' and strip(n.e).k == 'var': bumped.add(strip(n.e).decl)
        if n.k == 'opassign' and strip(n.l).k == 'var': bumped.add(strip(n.l).decl)
    walk(f.body, fw)
    body_locals = {d for d, dep in first_write.items() if dep and d not in bumped and d.kind == 'local'}
    counters = set()                                     # a for's counter: set in its init, stepped, tested
    for lp in loops:
        if lp.k == 'for' and lp.inc is not None:
            iv = strip(lp.inc)
            v = strip(iv.e) if iv.k == 'incdec' else strip(iv.l) if iv.k == 'opassign' else None
            if v is not None and v.k == 'var' and v.decl.kind == 'local': counters.add(v.decl)
    reads = {}; copies = {}                              # a parameter read only as the source of `local = p`
    def rc(n, dep):
        if n.k == 'load' and strip(n.e).k == 'var': reads[strip(n.e).decl] = reads.get(strip(n.e).decl, 0) + 1
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' and strip(n.l).decl.kind == 'local':
            r = strip(n.r)
            while r.k == 'cast' and r.kind == 'IntegralCast' and strip(r.e).ty.size == r.ty.size: r = strip(r.e)
            if r.k == 'load' and strip(r.e).k == 'var': copies[strip(r.e).decl] = copies.get(strip(r.e).decl, 0) + 1
    walk(f.body, rc)
    copy_only = {d for d in f.params if reads.get(d, 0) and reads.get(d, 0) == copies.get(d, 0) and d not in modified}
    narrowed_params = set()                              # a parameter used as (char)p in a loop: hoisted (_strrchr)
    def nar(n, dep):
        if dep and n.k == 'cast' and n.kind == 'IntegralCast' and n.ty.size == 1 and strip(n.e).k == 'load' and \
                strip(strip(n.e).e).k == 'var' and strip(strip(n.e).e).decl.kind == 'param':
            narrowed_params.add(strip(strip(n.e).e).decl)
    walk(f.body, nar)
    objs = []
    W = lambda d: 32 if d.ty.size == 4 else 16 if d.ty.size == 2 else 8
    used = [d for d in dict.fromkeys(list(f.params) + list(f.decls)) if d in pos and d.ty.kind in ('int', 'ptr')
            and not d.addr_taken]
    for d in used:
        if d.kind not in ('param', 'local'): continue
        idx = (f.params if d.kind == 'param' else [x for x in f.decls if x.kind == 'local']).index(d)
        if d in across and d in rets and d.kind == 'param' and \
                any(x is not d and x.ty.size == 4 for x in across): cls = 'memret'   # _strrev: s (p = s gets XIZ)
        elif d in across: cls = 'call'
        elif d in rets: cls = 'ret'
        elif d.kind == 'param' and d in copy_only and d not in loopmod: continue   # _itoa: u = val; val no object
        elif d.kind == 'param':
            if d.ty.kind == 'ptr' and d in loopmod: cls = 'walkh' if (d in derefidx or d in held_ptr) else 'walk'
            elif d not in inloop and L2_ONCE_MEM and len(uses_of(f.body, d, [])) == 1 and d not in modified and \
                    not loops: continue                      # __todigit: base, compared once -> cp BC,(XSP+0x6)
            elif d not in inloop: cls = 'out'
            elif d in loopmod and d.ty.kind == 'int': cls = 'cnt'
            elif d not in modified and (d in narrowed_params or inloop.get(d, 0) >= 2): cls = 'ro'   # _strrchr: (char)c
            elif d in copy_only: continue                   # _strcspn: s = s2 -> ld XDE,(XSP+0x8), s2 no object
            else: return False                              # rld parameters: not yet
        elif d in counters: cls = 'ctr'                     # _strrchr: for (i = ...; i; --i)
        else:
            cls = 'body' if d in body_locals else 'loc'      # _atoi: c = *nptr++ inside the loop -> the early group
        objs.append(dict(name=d, cls=cls, w=W(d), decl=idx, pos=pos.get(d, 0)))
    divides = []
    for lp in loops: walk(lp, lambda n, d: divides.append(n) if (n.k == 'bin' and n.op in ('/', '%') or
                                                                n.k == 'opassign' and n.op in ('/', '%')) else None)
    ivs = []                                             # _strrev: for (...; p < q; ++p, --q) { *p ... *q ... }
    for lp in loops:
        if lp.k == 'for' and lp.cond is not None and strip(lp.cond).k == 'bin' and strip(lp.cond).op in ('<', '<=', '!='):
            c = strip(lp.cond); vs = [strip(strip(x).e).decl if strip(x).k == 'load' and strip(strip(x).e).k == 'var'
                                      else None for x in (c.l, c.r)]
            if all(v is not None and v.ty.kind == 'ptr' for v in vs):
                der = []
                walk(lp.body, lambda n, d: der.append(strip(strip(n.e).e).decl) if n.k == 'deref' and
                     strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' else None)
                for v in vs:
                    if v in der and v not in ivs: ivs.append(v)
                if ivs: F.l2_ivloop = lp
    for v in ivs:
        firstd = [None]
        def fd(n, d, v=v):
            if firstd[0] is None and n.k == 'deref' and strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' and \
                    strip(strip(n.e).e).decl is v: firstd[0] = id(n)
        walk(F.l2_ivloop.body, fd)
        objs.append(dict(name=('iv', v), cls='iv', w=32, pos=pos.get(('deref', v), 0)))
    if tabs or needs_scratch(F, loops) or divides:
        objs.append(dict(name='t1', cls='t1', w=32 if divides else 16 if tabs else 8))   # _itoa: the dividend;
                                                                    # _strrev: the swapped byte (L)
    convs = {}                                           # _itoa: (unsigned)radix in both divisions -> a copy (multi)
    for lp in loops:
        def cv(n, d):
            if n.k == 'cast' and n.kind == 'IntegralCast' and strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' \
                    and strip(strip(n.e).e).decl.kind == 'param' and n.ty.signed != strip(n.e).ty.signed:
                convs.setdefault(strip(strip(n.e).e).decl, []).append(n)
        walk(lp, cv)
    for d, ns in convs.items():
        if len(ns) >= 2: objs.append(dict(name=('conv', d), cls='multi', w=16)); F.l2_convs = {id(n): d for n in ns}
    for d in dict.fromkeys(f.decls):
        if d.kind == 'local' and d.ty.kind == 'array' and d in pos:
            idx = [x for x in f.decls if x.kind == 'local'].index(d)
            objs.append(dict(name=d, cls='arr', w=32, decl=idx, pos=pos.get(d, 0)))
    tab_cls = {}
    for (tab, x, bit), dep, n in tabs:
        if tab in tab_cls: continue
        if not dep and not L2_NOLOOP: return False       # (__todigit: table tests in straight-line code)
        cond_use = any(table_test(strip(lp.cond)) or any(table_test(m) for m in [lp.cond]) for lp in loops
                       if getattr(lp, 'cond', None) is not None and uses_table(lp.cond, tab))
        per_iter = sum(1 for t in tabs if t[0][0] is tab)
        tab_cls[tab] = 'inv' if cond_use else ('once' if per_iter == 1 else 'multi')
        objs.append(dict(name=('tab', tab), cls=tab_cls[tab], w=32, pos=pos.get(('tab', tab), 0)))
    for i, hn in enumerate(held_nodes): objs.append(dict(name=('held', i), cls='held', w=32))
    got = l2alloc.allocate(objs)
    if any(v is None for v in got.values()): return False
    BYTE = {'A': 'WA', 'C': 'BC', 'E': 'DE', 'L': 'HL'}
    def fam(r):
        if r.startswith('X'): return r[1:]
        if r in ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ'): return r
        if r in ('QWA', 'QBC', 'QDE', 'QHL', 'QIX', 'QIY', 'QIZ'): return r     # a 16-bit upper half (_itoa: u)
        return BYTE.get(r)                             # W / B / D / H and the Q halves: not yet
    if any(v != 'mem' and fam(v) is None for v in got.values()): return False
    F.l2 = {'t1': fam(got['t1']) if 't1' in got else None, 'tab_inv': {}, 'tab_once': {}, 'held': {}, 'body': body_locals}
    for o in objs:
        r = got[o['name']]
        if isinstance(o['name'], tuple) and o['name'][0] == 'tab':
            F.l2['tab_inv' if o['cls'] == 'inv' else 'tab_once'][o['name'][1]] = fam(r)
        elif isinstance(o['name'], tuple) and o['name'][0] == 'held':
            F.l2['held'][id(held_nodes[o['name'][1]])] = fam(r)
        elif isinstance(o['name'], tuple) and o['name'][0] == 'conv':
            F.l2.setdefault('conv', {})[o['name'][1]] = fam(r)
        elif o['cls'] == 'arr':
            F.l2.setdefault('arr', {})[o['name']] = fam(r)
        elif isinstance(o['name'], tuple) and o['name'][0] == 'iv':
            F.l2.setdefault('iv', {})[o['name'][1]] = fam(r)
        elif o['cls'] == 'memret':
            pass                                         # stays where it arrived; reloaded for the return
        elif o['cls'] == 'memret': pass
        elif o['name'] != 't1':
            d = o['name']; d.reg = fam(r)
            if d.kind == 'param': F.param_copies.append(d)
    F.deferred = list(F.param_copies)
    if any(r in ('IZ', 'XIZ') for o, r in ((o, got[o['name']]) for o in objs) if o['cls'] == 'arr'):
        F.xiz_vars = ['arr']; F.save_reg = 'XIZ'; F.emit('push', 'XIZ'); F.push = 4   # _itoa: buf in XIZ
    ro_params = {o['name'] for o in objs if o['cls'] == 'ro' and not isinstance(o['name'], tuple)}
    F.l2['ro'] = ro_params
    if objs and any(o['cls'] == 'arr' for o in objs):   # _itoa: s (ret) at entry, radix (ro) at its first use
        F.l2['entry'] = list(reversed([d for d in F.param_copies if d not in ro_params and getattr(d, 'reg', None) != 'XIZ']))
        for d in F.l2['entry']: F.deferred.remove(d)
    F.l2['pre'] = [d for d in F.param_copies if d in narrowed_params and d not in modified]   # _strrchr: c after
    F.deferred = [d for d in F.deferred if d not in F.l2['pre']]                               # the loop's guard
    if F.l2['t1']: F.tfam = F.l2['t1']
    if any(getattr(d, 'reg', None) == 'IZ' for d in across):    # a 32-bit value across the call: XIZ
        for d in across:
            if getattr(d, 'reg', None) == 'IZ' and d.ty.size == 4: d.reg = 'XIZ'; d.homed = True
        F.xiz_vars = [d for d in across if getattr(d, 'reg', None)]; F.save_reg = 'XIZ'
        F.emit('push', 'XIZ'); F.push = 4
    return True

def needs_scratch(F, loops):
    """does a loop need L2's t1: a byte moved from memory to memory, or two memory bytes compared, an `n--`
    test copy (_strrchr's loop compares *(--s0) with c's register: no)"""
    found = []
    def regish(x):
        x = strip(x)
        while x.k == 'cast': x = strip(x.e)
        return x.k == 'load' and strip(x.e).k == 'var' or fold(x).k == 'const'
    def v(n, d):
        if not d: return
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'deref' and not regish(n.r): found.append(n)
        if n.k == 'bin' and n.op in CC_S and not regish(n.l) and not regish(n.r): found.append(n)
        if n.k == 'incdec' and n.post: found.append(n)
    for lp in loops: walk(lp, v)
    return bool(found)

def last_is_call_return(f):
    """the function's last statement is `return f(...)`, its only call (_itoa: return memcpy(s, p, ...))"""
    b = f.body
    while hasattr(b, 'k') and b.k == 'block' and b.body: b = b.body[-1]
    if not (hasattr(b, 'k') and b.k == 'return' and b.value is not None): return False
    v = strip(b.value)
    while v.k == 'cast': v = strip(v.e)
    return v.k == 'call'

def one_early_call(F):
    """the function makes one call, outside every loop, and no FP operation (_strrchr, _strrev: strlen first)"""
    calls = []
    def visit(n, depth):                                 # a for's init runs once: not inside the loop
        if isinstance(n, list):
            for x in n: visit(x, depth)
            return
        if not hasattr(n, 'k'): return
        if n.k == 'call' or fpgen.is_fp_op(n) or (depth and long_helper_node(n)): calls.append((n, depth))
        for key, v in n.__dict__.items():            # (r3_02_00: gul % gula[7] in the loop calls C9H_remlu)
            if hasattr(v, 'k') or isinstance(v, list):
                visit(v, depth + (1 if n.k in ('for', 'while', 'do') and key != 'init' else 0))
    visit(F.f.body, 0)
    return len(calls) == 1 and calls[0][0].k == 'call' and not calls[0][1] and strip(calls[0][0].fn).k == 'var'

def uses_table(n, tab):
    found = []
    walk(n, lambda m, d: found.append(m) if table_test(m) and table_test(m)[0] is tab else None)
    if table_test(n) and table_test(n)[0] is tab: return True
    return bool(found)

def read_in_for_init(f, d):
    """d's reads are all in the init of a for loop (which runs once per iteration of the loop around it:
    _strpbrk's `for (s = s2; ...)` inside `for ( ; *s1; ++s1)`)"""
    inits = []
    walk(f.body, lambda n, dep: inits.append(n.init) if n.k == 'for' and getattr(n, 'init', None) is not None else None)
    return bool(inits) and sum(1 for x in inits if uses_decl(x, d)) == 1

def narrowed_to_char(f, d):
    """d is read through a conversion to a char somewhere in f (_strchr's (char)c)"""
    hit = []
    walk(f.body, lambda n, dep: hit.append(n) if n.k == 'cast' and n.kind == 'IntegralCast' and n.ty.size == 1 and
         strip(n.e).k == 'load' and strip(strip(n.e).e).k == 'var' and strip(strip(n.e).e).decl is d else None)
    return bool(hit)

def plan_leaf(F):
    """the leaf-function allocator of regalloc_notes.md"""
    f = F.f
    has_call = []; loopvars = {}; modified = set(); deep = set(); temps_bc = []; temps_ptr = []
    def visit(n, depth):
        if n.k == 'call' or fpgen.is_fp_op(n) or (depth and long_helper_node(n)): has_call.append(n)   # (r3_02_00 -O3 -XS: gul %
        if n.k == 'load' and strip(n.e).k == 'var':                                     # gula[7] calls C9H_remlu,
            d = strip(n.e).decl                                                         # which clobbers a BC counter)
            if depth: loopvars[d] = loopvars.get(d, 0) + 1
            if depth >= 2: deep.add(d)
        if n.k in ('incdec',) and strip(n.e).k == 'var': modified.add(strip(n.e).decl); loopvars[strip(n.e).decl] = loopvars.get(strip(n.e).decl, 0) + (1 if depth else 0)
        if n.k in ('opassign',) and strip(n.l).k == 'var': modified.add(strip(n.l).decl)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var': modified.add(strip(n.l).decl)
        if n.k == 'index' and strip(n.base).k == 'var' and strip(n.base).decl.ty.kind == 'array' and n.ty.size >= 2 and fold(n.idx).k != 'const':
            temps_bc.append(n)
        if n.k == 'load' and strip(n.e).k == 'deref' and not F.opt: temps_bc.append(n)
        if not F.opt and n.k == 'bin' and n.op == '=' and strip(n.l).k == 'index' and \
                strip(strip(n.l).base).k == 'load' and fold(strip(n.l).idx).k != 'const' and fold(n.r).k != 'const':
            temps_bc.append(n)                             # ctrl.c c_copy: d[i] = s[i] -> ld BC,DE / extz XBC: i in DE
        if not F.opt and n.k == 'bin' and n.op == '=' and strip(n.l).k == 'deref' and strip(strip(n.l).e).k == 'incdec':
            temps_bc.append(n)                             # c_clear: *p++ = 0 -> ld XBC,(p) / ...: n in DE
        if F.adecl and n.k == 'index' and strip(n.base).k == 'load' and fold(n.idx).k != 'const' and depth:
            temps_ptr.append(n)                            # .c_sum: p[i] in a loop needs a free address register
        if F.opt and n.k == 'bin' and n.op == '=' and store_through_temp(n): temps_bc.append(n)   # _strset
    walk(f.body, visit)
    if F.opt and PTR_KLOOP and not has_call:
        lps = []
        walk(f.body, lambda n, d: lps.append(n) if n.k in ('for', 'while', 'do') else None)
        pk = ptr_kloop(F, lps[0]) if len(lps) == 1 else None
        if pk is not None:
            F.counted = {id(lps[0]): pk}; return True        # arr_index.c ai_div10 (gen_counted)
    if F.opt and not F.adecl and (not has_call or one_early_call(F)) and leaf_l2(F): return True
    if F.adecl and not has_call and leaf_r6(F): return True
    if (F.opt or (F.adecl and U1_PLAIN_XR)) and not has_call and leaf_u1(F): return True   # plain -Xr: U1 too
    if F.adecl and (F.opt or U1_PLAIN_XR) and not has_call and u1_down2(F): return True
    if F.opt and not has_call and u1_block_copy(F): return True
    if F.adecl and not F.opt and U1_PLAIN_XR and not has_call and u1_plain_global(F): return True
    if has_call and not (F.opt and not F.adecl and not any(d.kind == 'local' for d in f.decls) and f.params
                         and not live_across_call(f.body)):
        return False                                   # _ltoa at -O3 -XS: nothing read after its calls
    if has_call:
        uses = {}
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.e).decl, uses.get(strip(n.e).decl, 0) + 1)
             if n.k == 'load' and strip(n.e).k == 'var' else None)
        free = ['WA', 'BC', 'DE', 'HL']
        for d in reversed(f.params):                   # _ltoa: radix WA, s XBC, val XDE
            if uses.get(d, 0) >= 2 and d.ty.kind in ('int', 'ptr') and free:
                d.reg = free.pop(0); F.param_copies.append(d)
        if not F.param_copies: return False
        F.deferred = list(F.param_copies); F.nonleaf_regs = True
        return True
    hasloop = []
    walk(f.body, lambda n, d: hasloop.append(1) if n.k in ('for', 'while', 'do') else None)
    if not hasloop:
        uses = {}
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.e).decl, uses.get(strip(n.e).decl, 0) + 1)
             if n.k == 'load' and strip(n.e).k == 'var' else None)
        walk(f.body, lambda n, d: uses.__setitem__(strip(n.l).decl, uses.get(strip(n.l).decl, 0) + 1)
             if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' else None)   # c_ifelse: r = a; else r = b
        multi = [d for d in f.decls if d.kind == 'local' and uses.get(d, 0) >= 2 and
                 (d.ty.kind == 'int' or d.ty.kind == 'ptr')]          # .sbrk: addr in XHL; v_long: ap
        if not multi: return False
    rets = []
    walk(f.body, lambda n, d: rets.append(strip(strip(n.value).e).decl) if n.k == 'return' and n.value is not None and strip(n.value).k == 'load' and strip(strip(n.value).e).k == 'var' else None)
    F.counted = {}
    if F.opt:
        loops = []
        walk(f.body, lambda n, d: loops.append(n) if n.k == 'for' else None)
        u1g = F.adecl or U1_CDECL_GLOBAL
        if not loops and u1g:                            # ol_while, ol_do (U1)
            walk(f.body, lambda n, d: loops.append(n) if n.k in ('while', 'do') else None)
            if len(loops) != 1: loops = []
        cl = counted_loop(F, loops[0], multi=u1g) if len(loops) == 1 and not has_call else None
        if cl is not None and (len(cl.get('arrs', ())) > 1 or cl.get('form') == 'down'):   # U1 only (ol_i_copy)
            if u1_global(F, loops[0], cl, [d for d in rets if d.kind == 'local']):
                F.counted[id(loops[0])] = cl; return True
            cl = None
        if len(loops) == 2 and u1g and not has_call:                # ol_nested: for i { for j { s += ga[j]; } }
            ob = loops[0].body
            while ob is not None and ob.k == 'block' and len(ob.body) == 1: ob = ob.body[0]
            h = u1_for_head(loops[0]) if ob is loops[1] else None
            cl2 = counted_loop(F, loops[1], multi=True) if h is not None else None
            if cl2 is not None and h[0] is not cl2['i'] and \
                    u1_global(F, loops[1], cl2, [d for d in rets if d.kind == 'local'], outer=loops[0]):
                F.counted[id(loops[1])] = cl2; return True
        if cl is not None:
            F.counted[id(loops[0])] = cl
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
            if u1g and u1_global(F, loops[0], cl, rets0): return True
            if 'kconst' in cl:
                locs = [d for d in f.decls if d.kind == 'local' and d.ty.kind == 'int' and not d.addr_taken and d is not cl['i']]
                for d in locs:
                    if d in rets0: d.reg = 'HL'
                cl['i'].reg = None
                return True
            if shared or stores_long: reserved.add('WA')
            if KLOOP_VALUE_WA:                             # lnr.c r_ga_rd (-O3 -XS): gr = ga[i] loads the element
                gst = []                                   # into WA, so the offset is BC (ld WA,(XDE+BC) /
                walk(loops[0].body, lambda n, d: gst.append(n) if n.k == 'bin' and n.op == '=' and   # ld (_gr),WA)
                     strip(n.l).k == 'var' and strip(n.l).decl.kind == 'global' and
                     strip(n.r).k == 'load' and strip(strip(n.r).e).k == 'index' else None)
                if gst: reserved.add('WA')
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
                if not free: raise Unsupported('out of registers')   # (lnr.c r_ga_rd -O3 -XS: V4.23 takes QWA)
                x.reg = free.pop(0)
            if shared: cl['tmp'] = 'WA'
            F.pushes = ['IZ'] if any(getattr(x, 'reg', None) == 'IZ' for x in order + locs) else []
            if F.pushes: F.emit('push', 'IZ'); F.push = 2
            return True
    okind = ('int', 'ptr') if F.opt else ('int',)
    locals_ = [d for d in f.decls if d.kind == 'local' and not d.addr_taken and d.ty.kind in ('int', 'ptr')]
    # (pointer locals get registers without -O too: varargs.c v_sum's ap in XBC; pointer parameters do not, ra_ptr)
    if not hasloop:
        locals_ = multi
    stored = set()                                         # _strset: c, only ever stored, stays on the stack
    walk(f.body, lambda n, dep: stored.add(store_through_temp(n)) if n.k == 'bin' and n.op == '=' and store_through_temp(n) else None)
    params = [d for d in f.params if d.ty.kind in okind and not d.addr_taken and (d in modified or d in deep or (F.opt and d in loopvars))
              and not (F.opt and d in stored and loopvars.get(d, 0) <= 1)
              and not (F.opt and not F.adecl and ONCE_READ_MEM and d not in modified and
                       (d not in deep or read_in_for_init(f, d)) and
                       loopvars.get(d, 0) == 1 and d.uses == 1 and not narrowed_to_char(f, d))]   # _strpbrk: s = s2 once per
                                                                    # outer iteration (not _strchr's (char)c, in WA) ->
                                                                    # ld XBC,(XSP+0x8) each time
    walked = []                                            # without -O: a loop driven by a pointer test keeps the
    if (not F.opt or WALKED_OPT_WA) and not F.adecl and WALKED_PTRS:   # pointers it walks in registers (c_cnt: while (*s++)
        def unc(x):                                        # -> s in XWA; ra_ptrcpy: while (*s) *d++ = *s++ -> s XBC,
            x = strip(x)                                   # d XDE); a counted `while (n--)` does not (c_clear, ra_ptr)
            while x.k == 'cast': x = strip(x.e)
            return x
        loops_ = []
        walk(f.body, lambda n, dep: loops_.append(n) if n.k == 'while' else None)
        needs_a = False
        for w in loops_:
            c = unc(w.cond)
            if not (c.k == 'load' and strip(c.e).k == 'deref'): continue
            for n_ in [w.cond, w.body]:
                walk(n_, lambda m, dep: walked.append(strip(m.e).decl) if m.k == 'incdec' and m.post and
                     strip(m.e).k == 'var' and strip(m.e).decl.kind == 'param' and strip(m.e).decl.ty.is_ptr() and
                     strip(m.e).decl not in walked else None)
            st = []
            walk(w.body, lambda m, dep: st.append(m) if m.k == 'bin' and m.op == '=' and unc(m.r).k == 'load' and
                 strip(unc(m.r).e).k == 'deref' else None)
            if st: needs_a = True
        walked = [d for d in f.params if d in walked]
        if F.opt:                                          # -O3 -XS: only a loop with no byte temporary at all, and
            nbody = []                                     # then WA (c_cnt: cpb (XWA+:1),0x0 / inc 0x1,HL)
            cmpk = set()                                   # (__doform.c _zerochk: a byte compared with a constant,
            for w in loops_:                               # cpb (XWA+:1),0x30, needs no register)
                walk(w.body, lambda m, dep: [cmpk.add(id(x)) for x in (unc(m.l), unc(m.r))] if m.k == 'bin' and
                     m.op in CC_S and (fold(m.l).k == 'const' or fold(m.r).k == 'const') else None)
            for w in loops_: walk(w.body, lambda m, dep: nbody.append(m) if (m.k == 'load' and strip(m.e).k == 'deref'
                                  and id(m) not in cmpk) or (m.k == 'bin' and m.op == '=') else None)   # (_strset's
                                                                                                    # store needs WA)
            if needs_a or nbody or len(walked) != 1 or len(loops_) != 1: walked = []
        cands = (['WA'] if not needs_a else []) + [r for r in ('BC', 'DE', 'HL') if not (r == 'BC' and temps_bc)]
        for d in reversed(walked):
            if cands: d.reg = cands.pop(0); F.param_copies.append(d)
    params = [d for d in params if d not in walked]
    order = params + list(reversed(locals_))
    if F.opt: order = list(reversed(locals_)) + list(reversed(params))      # _strcat at -O: s, s2, s1
    free = [r for r in LEAF_SEQ if not (r == 'BC' and temps_bc) and not any(getattr(w_, 'reg', None) == r for w_ in walked)]
    if F.adecl:                                            # .c_sum: the parameters' own registers are taken
        free = [r for r in free if not any(getattr(p_, 'reg', None) == r and p_ not in order for p_ in f.params)]
    for d in order:
        if d in rets and 'HL' in free:
            d.reg = 'HL'; free.remove('HL')
            if d.kind == 'param': F.param_copies.append(d)        # _strchr: ld XHL,(XSP+4)
    if F.adecl and temps_ptr:                              # .c_sum: i IX (DE is p[i]'s address); .c_find: i HL, IX
        t_ = next((r for r in free if r in ('BC', 'DE', 'HL', 'IX', 'IY')), None)
        if t_ is not None: free.remove(t_)
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
    if LEAF_KEEP_TAKEN:                                    # a variable that keeps its register takes it out of the
        for d in order:                                    # pool (assign_expr.c ae_c_tou -O3 -XS -Xr: s2 stays in
            r_ = getattr(d, 'reg', None)                   # XBC, so c2 must not get C: wrong code)
            if r_ in free: free.remove(r_)
    for d in order:
        if getattr(d, 'reg', None): continue
        if F.opt and d in narrowed and d.ty.size == 2 and 'WA' in free:     # guess (_strchr: c in WA)
            d.reg = 'WA'; free.remove('WA')
            if d.kind == 'param': F.param_copies.append(d)
            continue
        if F.opt and CHAR_LOCAL_WA and d.kind == 'local' and d.ty.size == 1 and 'WA' in free and \
                not ptr_elem_in_loops(f) and \
                not any(getattr(p_, 'reg', None) == 'WA' for p_ in f.params) and \
                sum(1 for x in order if x.kind == 'local' and x.ty.size == 1) == 1:   # (one char local only: the
                                                                     # 1997 library's _strnicmp compares c1 through A
                                                                     # while c2 sat there: wrong code)
            d.reg = 'WA'; free.remove('WA'); continue      # assign_expr.c ae_c_loop (-O3 -XS): c in A
        if d.ty.size == 4: cand = [r for r in free if r in ('BC', 'DE', 'HL', 'IX', 'IY')]
        elif d.ty.size == 1: cand = [r for r in free if r in ('BC', 'DE', 'HL')]
        else: cand = free
        cand = [r for r in cand if r != 'WA' and not (r == 'HL' and d in hl_busy)]
        if not cand: raise Unsupported('out of registers')
        d.reg = cand[0]; free.remove(cand[0])
        if d.kind == 'param': F.param_copies.append(d)
    if LEAF_NONE_LN1 and not F.opt and not F.adecl and (hasloop or LN1_NOLOOP) and not has_call:
        import leafnone                                    # rule LN1 (model/leafnone.py) replaces the registers of
        inreg = [d for d in leafnone.variables(f) if getattr(d, 'reg', None)]     # the variables kept in one
        try: got = leafnone.allocate(f, set(inreg))
        except Exception: got = {}
        if inreg and all(got.get(d, '-') in FAM and not got[d].startswith('Q') for d in inreg):
            for d in inreg: d.reg = got[d]
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
        if n.k == 'incdec' and strip(n.e).k == 'var' or n.k == 'opassign' and strip(n.l).k == 'var':
            d = strip(n.e if n.k == 'incdec' else n.l).decl   # (r4_00_03: while (a-- > 0) reads a after gua[a],
            F.last_use[d] = None                             # which had been its last load; not in_loop: v0 += ga[i]
                                                             # then return v0 + v1 still dies there, ra_leafsum2)
    F.in_loop = set()
    walk(F.f.body, v)
    for d in F.in_loop: F.last_use[d] = None
    F.branch_last = set()                              # _ltoa: -val dies in the branch that returns
    def ends_return(st):
        if st is None: return False
        if st.k == 'return': return True
        return st.k == 'block' and bool(st.body) and ends_return(st.body[-1])
    def b(n, depth):
        if n.k == 'if' and not depth:
            for br in (n.then, n.els):
                if ends_return(br):
                    last = {}
                    walk(br, lambda m, dd: last.__setitem__(strip(m.e).decl, None if dd else id(m))
                         if m.k == 'load' and strip(m.e).k == 'var' else None)
                    F.branch_last.update(x for d, x in last.items() if x is not None and d not in F.in_loop)
        if n.k == 'while' and LOOP_COND_DEF:              # assign_expr.c ae_c_loop: while ((c = *s++) != 0) n += c ->
            defs = []                                      # c is set by the test before every read, so its last read
            walk(n.cond, lambda m, dd: defs.append(strip(m.l).decl) if m.k == 'bin' and m.op == '=' and
                 strip(m.l).k == 'var' and strip(m.l).decl.kind == 'local' else None)   # in the body is its death
            for d in defs:                                 # (-O3 -XS -Xr: exts BC / add HL,BC)
                inside = []; total = []
                walk(n, lambda m, dd: inside.append(m) if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d else None)
                walk(F.f.body, lambda m, dd: total.append(m) if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d else None)
                inb = []
                walk(n.body, lambda m, dd: inb.append(m) if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d else None)
                incond = []
                walk(n.cond, lambda m, dd: incond.append(m) if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d else None)
                if len(inside) == len(total) and inb and not incond: F.branch_last.add(id(inb[-1]))
        if n.k == 'cond' and not depth and TERN_ARM_LAST:  # chnarrow.c cn_tern (adecl): k ? c - 32 : c -> c dies in
            last = {}                                      # each arm: sub A,0x20 / ld L,A ... ld L,A
            walk(n.a, lambda m, dd: last.__setitem__(strip(m.e).decl, None if dd else id(m))
                 if m.k == 'load' and strip(m.e).k == 'var' else None)
            inb = set()
            walk(n.b, lambda m, dd: inb.add(id(m)) if m.k == 'load' and strip(m.e).k == 'var' else None)
            F.branch_last.update(x for d, x in last.items() if x is not None and d not in F.in_loop and
                                 F.last_use.get(d) in inb)
    walk(F.f.body, b)

def dies_here(F, e):
    e = strip(e)
    return e.k == 'load' and strip(e.e).k == 'var' and (F.last_use.get(strip(e.e).decl, 'x') == id(e)
                                                         or id(e) in getattr(F, 'branch_last', ()))

def live_regs(F, except_decl=None):
    out = set()
    for d in list(F.f.params) + list(F.f.decls):
        r = getattr(d, 'reg', None)
        if r == 'WA' and getattr(d, 'regtemp', False) and not getattr(d, 'regtemp_keep_wa', False): continue
        if r and d is not except_decl and d not in F.dead: out.add(r)
    return out

def merge_address_inits(f):
    """`T *p; ... p = (T *)&x;` with no use of p before: the assignment becomes p's initial value, so that a single
    use folds (_tan: p = (unsigned short *)&x; ... p[3] -> ld WA,(XSP+0x3a))"""
    def is_addr(e):
        e = strip(e)
        while e.k == 'cast': e = strip(e.e)
        return e.k == 'addr' and strip(e.e).k == 'var' and strip(e.e).decl.kind in ('param', 'local')
    def visit(n, d):
        if n.k != 'block': return
        body = n.body
        for i, c in enumerate(body):
            if c.k == 'block' and all(x.k == 'decl' for x in c.body):
                for dc in c.body:
                    if dc.init is not None or not dc.var.ty.is_ptr(): continue
                    for j in range(i + 1, len(body)):
                        st = body[j]
                        if st.k == 'expr' and st.e.k == 'bin' and st.e.op == '=' and strip(st.e.l).k == 'var' and \
                                strip(st.e.l).decl is dc.var and is_addr(st.e.r):
                            dc.init = st.e.r; body[j] = N_block(); break
                        if uses_decl(st, dc.var): break
    walk(f.body, visit)

def propagate_global_copies(f):
    """cdecl -O: after `G = p;` (G a global, p a parameter) the next statement reads p for G when it has no call
    and writes neither (_sprintf: _str = s; _str[0] = '\\0'; -> ld (__str),XWA / ldb (XWA),0x0)"""
    def writes(n, d):
        w = []
        walk(n, lambda m, dd: w.append(m) if (m.k in ('bin', 'opassign') and (m.k == 'opassign' or m.op == '=')
             and strip(m.l).k == 'var' and strip(m.l).decl is d) or (m.k == 'incdec' and strip(m.e).k == 'var'
             and strip(m.e).decl is d) else None)
        return bool(w)
    def visit(n, d):
        if n.k != 'block': return
        b = n.body
        for k in range(len(b) - 1):
            c, nx = b[k], b[k + 1]
            if c.k != 'expr' or strip(c.e).k != 'bin' or strip(c.e).op != '=': continue
            g = strip(strip(c.e).l); src = strip(strip(c.e).r)
            if g.k != 'var' or g.decl.kind != 'global' or src.k != 'load' or strip(src.e).k != 'var': continue
            p = strip(src.e).decl
            if p.kind != 'param' or nx.k not in ('expr',) or has_helper_call(nx) or writes(nx, g.decl) or writes(nx, p):
                continue
            substitute(nx, g.decl, src)
    walk(f.body, visit)

def N_ublock(body):
    from frontend import N
    return N('block', body=[N('ulabel'), body])

def goto_returns(f):
    """`goto L` where L labels a `return` becomes that return (_strcspn: goto bye; ... bye: return (len); ->
    ret eq inside the loop), and the label gives way to its statement"""
    import copy as _copy
    labels = {}
    walk(f.body, lambda n, d: labels.__setitem__(n.decl, n) if n.k == 'label' and getattr(n, 'decl', None) else None)
    def ret_of(lab):
        b = lab.body
        while hasattr(b, 'k') and b.k == 'block' and len(b.body) == 1: b = b.body[0]
        return b if hasattr(b, 'k') and b.k == 'return' else None
    def fix(n):
        for key, v in list(n.__dict__.items()):
            if hasattr(v, 'k'):
                if v.k == 'goto' and v.target in labels and ret_of(labels[v.target]) is not None:
                    setattr(n, key, _copy.deepcopy(ret_of(labels[v.target])))
                elif v.k == 'label' and v in labels.values():
                    setattr(n, key, N_ublock(v.body)); fix(v.body)
                else: fix(v)
            elif isinstance(v, list):
                for i, x in enumerate(v):
                    if not hasattr(x, 'k'): continue
                    if x.k == 'goto' and x.target in labels and ret_of(labels[x.target]) is not None:
                        v[i] = _copy.deepcopy(ret_of(labels[x.target]))
                    elif x.k == 'label' and x in labels.values(): v[i] = N_ublock(x.body); fix(x.body)
                    else: fix(x)
    fix(f)

def forward_single_use(f):
    """-O: a local written once by a call-free expression and read once, as the last argument of the call that makes
    the next statement, is not stored: the expression is pushed in its place (_memccpy, ls_mc: nn = pos - s2 + 1;
    cp2(s1, s2, nn) -> sub XWA,(XSP+0xe) / inc 0x1,XWA / push WA)"""
    refs = {}
    def count(n, dep):
        if n.k == 'var': refs[n.decl] = refs.get(n.decl, 0) + 1
    walk(f.body, count)
    gone = []
    def pure(e):
        bad = []
        walk(e, lambda n, dd: bad.append(n) if n.k in ('call', 'incdec', 'opassign') or
             (n.k == 'bin' and n.op == '=') else None)
        return not bad
    def visit(n, d):
        if n.k != 'block': return
        b = n.body
        for k in range(len(b) - 1):
            c, nx = b[k], b[k + 1]
            if not (c.k == 'expr' and strip(c.e).k == 'bin' and strip(c.e).op == '=' and strip(strip(c.e).l).k == 'var'):
                continue
            v = strip(strip(c.e).l).decl; rhs = strip(c.e).r
            if v.kind != 'local' or v.addr_taken or v.ty.kind not in ('int', 'ptr') or refs.get(v, 0) != 2 or not pure(rhs):
                continue
            if not (nx.k == 'expr' and strip(nx.e).k == 'call' and strip(nx.e).args): continue
            last = strip(nx.e).args[-1]; x = last
            while x.k in ('cast', 'noop', 'decay') and x.k != 'load': x = x.e
            if not (x.k == 'load' and strip(x.e).k == 'var' and strip(x.e).decl is v): continue
            strip(nx.e).args[-1] = rhs; b[k] = N_block(); gone.append(v)
    walk(f.body, visit)
    for v in gone:
        if v in f.decls: f.decls.remove(v)
    def drop_decl(n, dep):
        if n.k == 'block':
            n.body = [x for x in n.body if not (x.k == 'decl' and x.var in gone)]
    walk(f.body, drop_decl)

def N_block():
    from frontend import N
    return N('block', body=[])

def N_var(d):
    from frontend import N
    return N('var', decl=d, ty=d.ty)

def stmt_returns(st):
    """does the statement end in a return (its deaths do not reach the code after it)?"""
    if st is None or not hasattr(st, 'k'): return False
    if st.k == 'return': return True
    return st.k == 'block' and bool(st.body) and stmt_returns(st.body[-1])

def local_defined_before(F, d):
    """has a statement up to the current top-level one assigned local d?  A write to its register before that is harmless."""
    if d.kind == 'param': return True
    for x in flat(F.f.body):
        if x.k == 'decl' and getattr(x, 'var', None) is d:
            if x.init is not None: return True           # (int d1; without an initializer defines nothing: s_add2_u)
        elif assigns_decl(x, d): return True
        if x is getattr(F, 'top_cur', None): return False
    return True

def switch_breaks(body):
    """does a switch body break out of the switch itself (a break not inside a nested loop or switch)?"""
    hit = []
    def v(n, dep):
        if not hasattr(n, 'k'): return
        if n.k == 'break': hit.append(n); return
        if n.k in ('while', 'do', 'for', 'switch'): return
        for x in n.__dict__.values():
            if isinstance(x, list):
                for y in x: v(y, dep + 1)
            elif hasattr(x, 'k'): v(x, dep + 1)
    v(body, 0)
    return bool(hit)

def call_before_use(rest, d):
    """a call in the statements before the one that reads d: cc900 then keeps d (ch_c_xyz: x in a slot)"""
    for c in rest:
        found = []
        walk(c, lambda n, dep: found.append(n) if getattr(n, 'k', None) == 'call' else None)
        if uses_decl(c, d):                                # a loop, switch or if that calls and reads d: the read
            if found and CALL_FOLD_GUARD and c.k not in ('while', 'do', 'for', 'switch', 'if', 'block'):
                total = uses_of([c], d, [])                    # (idxloc.c il_i_R4: gia[t] = ri() reads t after the
                in_args = []                                   #  call: cc900 keeps t in IZ; folded, the model read gi
                for cl_ in found:                              #  after ri(): wrong code) -- unless every read is an
                    for a_ in getattr(cl_, 'args', []) or []: in_args += uses_of([a_], d, [])   # argument
                return len(in_args) < len(total)
            return bool(found) and c.k in ('while', 'do', 'for', 'switch', 'if', 'block')   # may follow the call
        if found: return True                              # (r3_05_00: gps->p = t in a switch arm after vd();
    return False                                           # r3_00_06: t <= gl2 in a loop body after v2())

def foldable(f, d):
    """a local that gen_stmt folds into its single use (no slot needed)"""
    body = flat(f.body)
    for i, c in enumerate(body):
        if c.k == 'decl' and c.var is d:
            if c.init is None or d.addr_taken or d.ty.size < 2 or getattr(d, 'no_fold', False): return False
            return len(uses_of(body[i + 1:], d, [])) == 1 and not call_before_use(body[i + 1:], d) and \
                not written_in(body[i + 1:], d)
    return False

def slot_init(F, d, init):
    """a slot local's initial value: built in the slot when it is an operand pair (ch_c_xyz under -Xr:
    ld (XSP+0x4),WA / add (XSP+0x4),BC; cdecl: ld WA,(a) / ld (XSP+0x4),WA / ld WA,(b) / add (XSP+0x4),WA)"""
    from frontend import N
    S = mem_operand(F, N('load', e=N('var', decl=d, ty=d.ty), ty=d.ty))
    r0 = strip(init); size = d.ty.size
    if size == 2 and r0.k == 'bin' and r0.op in SIMPLE_OPS and not r0.ty.is_ptr():
        lo = operand(F, narrow(r0.l, 2), 2); ro = operand(F, narrow(r0.r, 2), 2)
        if lo is not None and ro is not None:
            for src, opn in ((lo, 'ld'), (ro, SIMPLE_OPS[r0.op])):
                if src.startswith('('): F.emit('ld', 'WA,%s' % src); src = 'WA'
                F.emit(opn, '%s,%s' % (S, src))
            return True
    if r0.k == 'call' and not has_helper_call(r0.fn) and size in (2, 4) and SLOT_FROM_HL:
        gen_call(F, r0); flush_pops(F)                     # ra_homes32.c h_p under O3XSXr: cal .fp /
        F.emit('ld', '%s,%s' % (S, FAM['HL'][size])); return True   # ld (XSP+0x2),XHL
    W = 'WA'
    if STORE_ADDR_GUARD and any(getattr(x, 'reg', None) == 'WA' and x not in F.dead and x is not d
                                for x in list(F.f.params) + list(F.f.decls)):
        W = free_reg(F, avoid={'WA'})                      # switch.c sw_local (-Xr): x in WA, r = 0 (wrong code)
    fam = gen(F, init, W, size)
    F.emit('ld', '%s,%s' % (S, FAM[fam][size])); return True

STORE_PLAN = True                                         # see store_plan
CHAR_ARG_GEN = True                                       # a char argument computed into A (r2_06_16)

def sp_plain_ptr(F, e):
    """the memory operand of a pointer that is a plain variable (global, slot local, stack parameter), else None"""
    e = strip(e)
    while e.k == 'cast' and e.ty is not None and e.ty.size == 4: e = strip(e.e)
    if e.k != 'load' or strip(e.e).k != 'var': return None
    d = strip(e.e).decl
    if getattr(d, 'reg', None) or not d.ty.is_ptr(): return None
    return mem_operand(F, e)

def sp_plain_index(F, e):
    """(memory operand, signed) of an int-sized index that is a plain variable, or (under -Xr) the parameter in WA
    that dies here (st_i_XB -Xr: add WA,WA / lda XBC,_gia, the index in place), else None"""
    e = strip(e)
    while e.k == 'cast' and e.kind == 'IntegralCast': e = strip(e.e)
    if e.k != 'load' or strip(e.e).k != 'var' or e.ty is None or e.ty.size != 2: return None
    d = strip(e.e).decl
    if getattr(d, 'reg', None):
        if d.reg == 'WA' and d.kind == 'param' and dies_here(F, e) and not getattr(d, 'regtemp', False):
            F.sp_index_param = d; return ('WA', e.ty.signed)
        if SP_INDEX_IZ and d.reg == 'IZ' and not F.opt:     # a local kept across a call in IZ (random r2_08_09:
            touch_home(F, d); return ('IZ', e.ty.signed)   # gs.a[u] = r1(gi) -> ld WA,IZ / add WA,WA / lda XBC,_gs + 0xe)
        return None
    m = mem_operand(F, e)
    return (m, e.ty.signed) if m is not None else None

def sp_lvalue_kind(F, lv):
    """'P' *p / p->m at offset 0, 'D' p->m with a displacement, 'X' garr[i], 'Y' p->arr[i], 'Q' p[i], 'S' a static
    member or constant element, with what each needs; None where the shape is not one of these"""
    lv = strip(lv)
    if lv.k == 'deref':
        pm = sp_plain_ptr(F, lv.e)
        return ('P', pm, 0) if pm is not None else None
    if lv.k == 'member' and lv.arrow:
        pm = sp_plain_ptr(F, lv.base)
        if pm is None: return None
        off = member_offset(lv)
        return ('D' if off else 'P', pm, off)
    if lv.k == 'index' and fold(lv.idx).k == 'const' and fold(lv.idx).value is not None:
        b = strip(lv.base)
        if b.k == 'member' and b.arrow and b.ty.kind == 'array':   # r1_08_11: gps->a[3] = 100 -> ld XWA,(_gps) /
            pm = sp_plain_ptr(F, b.base)                           # ldw (XWA+0x14),0x64 (a member with a displacement)
            if pm is None: return None
            off = member_offset(b) + fold(lv.idx).value * lv.ty.size
            return ('D' if off else 'P', pm, off) if 0 <= off < 0x8000 else None
        if b.k == 'load' and b.ty.is_ptr():                        # r1_07_03: gpi[3] = r1(..) -> cal / ld XWA,(_gpi) /
            pm = sp_plain_ptr(F, b)                                # ld (XWA+0x6),HL
            if pm is None: return None
            off = fold(lv.idx).value * lv.ty.size
            return ('D' if off else 'P', pm, off) if 0 <= off < 0x8000 else None
    if lv.k == 'index' and fold(lv.idx).k != 'const':
        b = strip(lv.base); ii = sp_plain_index(F, lv.idx)
        if ii is None: return None
        while b.k in ('decay', 'cast', 'noop') and getattr(b, 'e', None) is not None: b = strip(b.e)
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array': return ('X', '_' + b.decl.name, ii)
        if b.k == 'member' and not b.arrow and b.ty.kind == 'array' and strip(b.base).k == 'var' and \
                strip(b.base).decl.kind == 'global':               # r2_08_09: gs.a[u] = r1(gi) -> lda XBC,_gs + 0xe
            off = member_offset(b)
            return ('X', '_%s + %s' % (strip(b.base).decl.name, hx(off)) if off else '_' + strip(b.base).decl.name, ii)
        if b.k == 'member' and b.arrow and b.ty.kind == 'array':
            pm = sp_plain_ptr(F, b.base)
            return ('Y', pm, member_offset(b), ii) if pm is not None else None
        if b.k == 'load':
            pm = sp_plain_ptr(F, b)
            return ('Q', pm, ii) if pm is not None else None
        return None
    g = global_offset(lv)
    if g is not None and g[0] != '__param__' and lv.k in ('member', 'index'):
        return ('S', '(_%s + %s)' % g if g[1] != '0x0' else '(_%s)' % g[0], '_%s + %s' % g if g[1] != '0x0' else '_%s' % g[0])
    return None

def sp_value_kind(F, rv, size):
    """'L' a load or (for a long) a constant or !x, 'B' + - & | ^ or an int !x, 'M' int * / %, 'H' a long helper,
    'S' a shift by a variable, 'C' a call, 'T' ?:, None otherwise"""
    x = strip(rv)
    while x.k == 'cast' and x.kind in ('IntegralCast', 'NoOp', 'BitCast'): x = strip(x.e)
    if x.k == 'call': return 'C' if not has_helper_call(x.fn) else None
    if x.k == 'cond': return 'T' if all(mem_operand(F, strip(y)) is not None or fold(strip(y)).k == 'const'
                                        for y in (x.b, x.c)) and mem_operand(F, x.a) is not None else None
    if x.k == 'un' and x.op == '!':
        xi = strip(x.e)
        while xi.k == 'cast' and xi.kind == 'IntegralCast': xi = strip(xi.e)
        if not (xi.k == 'load' and mem_operand(F, xi) is not None and strip(xi.e).k in ('var', 'member') and
                not (strip(xi.e).k == 'member' and strip(xi.e).arrow)): return None   # (r1_03_03: !gps->l loads
        return 'L' if size == 4 else 'B'                                               # through XWA, the address)
    if x.k == 'const': return 'L' if size == 4 else 'K'
    if x.k == 'load':
        if mem_operand(F, x) is not None: return 'L'
        k = sp_lvalue_kind(F, x.e)
        if k is None: return None
        return 'X' if k[0] == 'X' else ('L' if k[0] in ('P', 'D') else None)   # (hps->a[c], hpi[c] as values: unprobed)
    if x.k == 'bin':
        lk = strip(x.l); rk = strip(x.r)
        while lk.k == 'cast' and lk.kind == 'IntegralCast': lk = strip(lk.e)
        while rk.k == 'cast' and rk.kind == 'IntegralCast': rk = strip(rk.e)
        simple = lambda y: y.k == 'const' or (y.k == 'load' and mem_operand(F, y) is not None and
                                              strip(y.e).k in ('var', 'member') and not (strip(y.e).k == 'member' and strip(y.e).arrow))
        through = lambda y: y.k == 'load' and (strip(y.e).k == 'member' and strip(y.e).arrow and sp_plain_ptr(F, strip(y.e).base) is not None
                                               or strip(y.e).k == 'deref' and sp_plain_ptr(F, strip(y.e).e) is not None)
        if x.op in ('+', '-', '&', '|', '^') and size in (2, 4) and (through(lk) and simple(rk) or simple(lk) and through(rk)):
            return 'BP'
        if not (simple(lk) and simple(rk)): return None
        if x.op in ('<<', '>>'): return 'S' if rk.k != 'const' else 'B'
        if x.op in ('+', '-', '&', '|', '^'): return 'B'
        if x.op in ('*', '/', '%'):
            if size == 4 or x.ty.size == 4:                # (st_l_DU: hl / 7L is C9H_divls too)
                return 'H' if has_helper_call(x) or x.op in ('/', '%') or rk.k != 'const' else 'B'
            return 'M'
    return None

def store_plan(F, lv, rv, size):
    """the order and the registers of a store's address and value (corpus/probes/stord.c, run
    2026-11-10-15-micro-stord, the same at the four option sets).  The address comes first and the value second,
    except after a call (st_i_DC: cal _ri / ld XWA,(_gps) / ld (XWA+0x2),HL).  A plain *p takes XBC with the value
    in WA whatever the value (st_i_PB: ld XBC,(_gpi) / ld WA,(_hi) / sub WA,(_hj) / ld (XBC),WA); a member with a
    displacement takes XBC before a loaded value in WA and XWA before a computed value in BC (st_i_DB: ld XWA,(_gps) /
    ld BC,(_hi) / sub BC,(_hj) / ld (XWA+0x2),BC; st_i_DV: divs XBC,(_hj)); a global element takes BC / XDE with the
    value in WA, or WA / XBC with the value in DE for a difference or a ! (st_i_XB: ld WA,(c) / add WA,WA /
    lda XBC,_gia / ld DE,(_hi) / sub DE,(_hj) / ld (XBC+WA),DE); a member array element through a pointer the same
    with E / XBC and C / XWA (st_i_YG, st_i_YB; st_i_YM: ld E,A / ld XWA,(_gps) / ld BC,(_hi) / muls XBC,(_hj)); p[i]
    builds its address in XWA and moves it to XBC (st_i_QG: ld WA,(c) / exts XWA / add XWA,XWA / ld XBC,XWA /
    add XBC,(_gpi) / ld WA,(_hi) / ld (XBC),WA), straight in XWA after a call.  A shift's value goes to the next free
    register with the count in WA (st_i_DS: XBC / DE; st_i_PS: XDE / BC; st_i_XS: BC / XDE / HL).  A ?: value takes
    its address first in XBC, a displacement added (st_i_DT: ld XBC,(_gps) / inc 0x2,XBC), a static member too
    (st_i_MT: lda XBC,_gs + 0x2).  A long helper's store through a pointer keeps the address in XIZ across the call
    (st_l_DV: push XIZ / ld XIZ,(_gps) / ... / cal C9H_divls / ld (XIZ+0x4),XHL / pop XIZ).  A char value computes
    in WA and stores A; a char element at an int index adds the zero-extended index to the array's address
    (st_c_XG: lda XWA,_gca / ld BC,(c) / extz XBC / add XBC,XWA / ld WA,(_hc) / ld (XBC),A).  Returns False where
    the shape is not one of these, so that the older paths decide."""
    if F.opt and (getattr(F, 'ptr_cache', None) or getattr(F, 'store_val_reg', None) or getattr(F, 'member_cache', None)):
        return False                                       # (-O: a pointer run keeps its register: _fassign, _ungetc)
    lk = sp_lvalue_kind(F, lv)
    if lk is None: return False
    vk = sp_value_kind(F, rv, size)
    if vk is None: return False
    L = lk[0]
    if size not in (1, 2, 4): return False
    F.sp_index_param = None
    lk = sp_lvalue_kind(F, lv)                             # (again: sp_index_param is set by the index)
    ip = getattr(F, 'sp_index_param', None)
    live = {r for r in live_regs(F) if r not in ('WA', 'BC', 'DE', 'HL') or any(
        d is not ip and getattr(d, 'reg', None) == r and d not in F.dead and
        (param_live_after(F, d) or uses_decl(rv, d)) for d in list(F.f.params) + list(F.f.decls))}
    if live & {'WA', 'BC', 'DE', 'HL'}: return False      # (register variables still read: the older paths)
    if ip is not None and vk == 'C': return False          # (-Xr st_i_XC: c is saved in IZ around the call: unmodelled)
    if ip is not None and size == 1 and L in ('X', 'Q'):   # -Xr st_c_QG: ld XDE,(_gp) / ld BC,(_hc) / ld (XDE+WA),C;
        if vk not in ('L', 'B', 'M'): return False         # st_c_XG: lda XDE,_gca / ...: the index stays in WA
        if L == 'Q': F.emit('ld', 'XDE,%s' % lk[1])
        else: F.emit('lda', 'XDE,%s' % lk[1])
        F.dead.add(ip); n1 = len(F.lines)
        fam = gen(F, rv, 'BC', 1)
        if fam != 'BC' or clobbers(F.lines[n1:], '(XDE+WA)'): raise Unsupported('store_plan: the -Xr char element value')
        F.emit('ld', '(XDE+WA),C'); return True
    x = strip(rv)
    while x.k == 'cast' and x.kind in ('IntegralCast', 'NoOp', 'BitCast'): x = strip(x.e)
    if L == 'S' and vk not in ('T', 'C'): return False     # (a static lvalue with a plain value: the older paths)
    if vk == 'K':                                          # the address in the WA family, then ldw / ldb mem,K
        rc = fold(narrow(rv, size))
        if rc.k != 'const' or rc.value is None: return False
        t = sp_address(F, lk, size, 'XWA', 'WA', 'XBC', 'K')
        if t is None: return False
        F.emit('ld' + ('b' if size == 1 else 'w'), '%s,%s' % (t, imm_of(rc, size))); return True
    if vk == 'H' and L not in ('P', 'D', 'Q'): return False   # (an element: through a slot and IZ, unmodelled)
    if vk == 'H' and (any(not isinstance(z, str) for z in F.xiz_vars) or not getattr(F, 'store_xiz', False)): return False
    if vk == 'S' and L == 'Y': return False                # (st_i_YS: the index copied to IX, unmodelled)
    if vk == 'X' and L in ('Y', 'S'): return False         # (the value's base moves to XDE there: unmodelled)
    byte = size == 1
    if byte and L == 'Y' and vk == 'S': return False       # (st_c_YS: the value in HL, the count copied: unmodelled)
    # --- the plan: (address register(s), value register)
    if vk == 'C':                                          # the call first, then the address in the WA family
        fam = gen(F, x, 'HL', size); flush_pops(F)
        if fam != 'HL': return False
        if L == 'S': F.emit('ld', '%s,%s' % (lk[1], FAM['HL'][size])); return True   # st_i_MC: ld (_gs + 0x2),HL
        t = sp_address(F, lk, size, 'XWA', 'WA', 'XBC', 'C')
        if t is None: return False
        F.emit('ld', '%s,%s' % (t, FAM['HL'][size])); return True
    if vk == 'H':
        t = sp_address(F, lk, size, 'XIZ', None, None, 'E')   # the pointer in XIZ across the helper
        if t is None: return False
        F.sp_xiz_busy = True                               # (lh_member must not take XIZ for an operand here)
        try: fam = gen(F, x, 'HL', 4)
        finally: F.sp_xiz_busy = False
        if fam != 'HL': return False
        F.emit('ld', '%s,XHL' % t); return True
    if vk == 'BP':
        if L != 'D': return False
        fam = gen(F, rv, 'BC', size)
        if fam != 'BC': raise Unsupported('store_plan: the pointer difference landed in %s' % fam)
        t = sp_address(F, lk, size, 'XWA', None, None, 'BP')
        F.emit('ld', '%s,%s' % (t, FAM['BC'][size])); return True
    if vk == 'T':
        t = sp_address(F, lk, size, 'XWA' if L == 'Y' else 'XBC', 'C' if L == 'Y' else 'WA', 'XBC', 'T')
        if t is None: return False
        fam = gen(F, rv, 'WA', size)
        F.emit('ld', '%s,%s' % (t, FAM[fam][size])); return True
    if vk == 'X':                                          # an element value keeps WA / XBC; the address moves over
        P, I, B, V = {'P': ('XDE', None, None, 'WA'), 'X': (None, 'DE', 'XHL', 'WA'), 'Q': ('XDE', None, None, 'WA'),
                      'D': ('XBC', None, None, 'WA')}[L]   # (st_i_DX: the pointer keeps XBC, the value's base XDE)
        # (st_i_PX: ld XDE,(_gpi) / ld WA,(c) / add WA,WA / lda XBC,_hia / ld WA,(XBC+WA) / ld (XDE),WA; st_i_XX:
        # ld DE,(c) / add DE,DE / lda XHL,_gia / ...; st_i_QX: ld XDE,XWA / add XDE,(_gpi))
    elif byte:                                             # a char value computes in WA and stores A
        if vk == 'S': P, I, B, V = 'XDE', 'DE', 'XDE', 'BC'
        elif L == 'Y': P, I, B, V = 'XBC', 'E', None, 'WA'    # st_c_YG: ld E,A / ld XBC,(_gps) / ... / ld (XBC+E),A
        else: P, I, B, V = 'XBC', 'BC', 'XBC', 'WA'
    elif vk == 'S':
        P, I, B, V = {'P': ('XDE', None, None, 'BC'), 'D': ('XBC', None, None, 'DE'), 'X': (None, 'BC', 'XDE', 'HL'),
                      'Q': ('XDE', None, None, 'BC')}[L]
    elif vk in ('B',) or (vk == 'L' and False):
        P, I, B, V = {'P': ('XBC', None, None, 'WA'), 'D': ('XWA', None, None, 'BC'), 'X': (None, 'WA', 'XBC', 'DE'),
                      'Y': ('XWA', 'C', None, 'DE'), 'Q': ('XBC', None, None, 'WA')}[L]
    elif vk == 'M':
        P, I, B, V = {'P': ('XBC', None, None, 'WA'), 'D': ('XWA', None, None, 'BC'), 'X': (None, 'BC', 'XDE', 'WA'),
                      'Y': ('XWA', 'E', None, 'BC'), 'Q': ('XBC', None, None, 'WA')}[L]
    else:                                                  # 'L'
        P, I, B, V = {'P': ('XBC', None, None, 'WA'), 'D': ('XBC', None, None, 'WA'), 'X': (None, 'BC', 'XDE', 'WA'),
                      'Y': ('XBC', 'E', None, 'WA'), 'Q': ('XBC', None, None, 'WA')}[L]
    if size == 4 and vk == 'B' and L == 'D': P, V = 'XWA', 'BC'   # (st_l_DB: ld XWA,(_gps) / ld XBC,(_hl) / sub XBC,(_hm))
    n0 = len(F.lines)
    t = sp_address(F, lk, size, P, I, B, vk)
    if t is None: del F.lines[n0:]; return False
    if ip is not None: F.dead.add(ip)
    n1 = len(F.lines)                                      # (the value's code, after the address's)
    if vk == 'M': F.mul_acc_fam = V
    if vk == 'X' and L == 'D': F.sp_busy = {'XBC'}
    try: fam = gen(F, rv, V, size)
    finally: F.mul_acc_fam = None; F.sp_busy = set()
    if fam != V:
        if vk == 'S' and fam in FAM and size in FAM[fam]: V = fam   # (the shift's own register choice)
        elif byte and fam in FAM: V = fam
        else: raise Unsupported('store_plan: the value landed in %s, not %s [%s %s]' % (fam, V, L, vk))
    if clobbers(F.lines[n1:], t): raise Unsupported('store_plan: the value overwrote the address [%s %s]' % (L, vk))
    F.emit('ld', '%s,%s' % (t, FAM[V][size])); return True

def sp_address(F, lk, size, P, I, B, vk):
    """emit the address of the lvalue lk (sp_lvalue_kind) and return its operand: P the pointer register, I the index
    register, B the base register (None = not used by this shape)"""
    L = lk[0]
    if L == 'S':
        F.emit('lda', 'XBC,%s' % lk[2]); return '(XBC)'
    if L in ('P', 'D'):
        pm, off = lk[1], lk[2]
        if vk == 'T' and off:                              # st_i_DT: ld XBC,(_gps) / inc 0x2,XBC
            F.emit('ld', '%s,%s' % (P, pm)); F.emit('inc' if off <= 8 else 'add', '%s,%s' % (hx(off), P) if off <= 8 else '%s,%s' % (P, hx(off)))
            return '(%s)' % P
        F.emit('ld', '%s,%s' % (P, pm))
        return '(%s+%s)' % (P, hx(off)) if off else '(%s)' % P
    if L == 'X':
        sym, (im, signed) = lk[1], lk[2]
        if size == 1:                                      # st_c_XG: lda XWA,_gca / ld BC,(c) / extz XBC / add XBC,XWA
            X = 'XDE' if vk in ('S', 'X') else 'XBC'
            F.emit('lda', 'XWA,%s' % sym); F.emit('ld', '%s,%s' % (X[1:], im))
            F.emit('extz', X); F.emit('add', '%s,XWA' % X); return '(%s)' % X
        if not signed and UIDX32:                          # an unsigned index is extended whole (r2_03_08, r1_08_00)
            if vk == 'T': return None
            F.emit('ld', 'WA,%s' % im); F.emit('extz', 'XWA'); scale32(F, 'XWA', size)
            if ' + ' in sym:                               # a member array: the low byte plus the member offset
                base_, off_ = sym.split(' + ')              # (r2_03_08: add A,0xe / lda XBC,_gs / ld (XBC+A),HL)
                F.emit('add', 'A,%s' % off_); F.emit('lda', '%s,%s' % (B, base_)); return '(%s+A)' % B
            F.emit('ld', '%s,%s' % (B, sym)); F.emit('add', '%s,XWA' % B); return '(%s)' % B
        F.emit('ld', '%s,%s' % (I, im)); scale_reg(F, I, size, 'sla')
        if vk == 'T':                                      # st_i_XT: lda XBC,_gia / lda XBC,XBC+WA
            F.emit('lda', '%s,%s' % (B, sym)); F.emit('lda', '%s,%s+%s' % (B, B, I)); return '(%s)' % B
        F.emit('lda', '%s,%s' % (B, sym)); return '(%s+%s)' % (B, I)
    if L == 'Y':
        pm, off, (im, signed) = lk[1], lk[2], lk[3]
        if F.opt and size == 1 and vk not in ('K', 'C', 'T') and im != 'WA':   # -O st_c_YG: ld DE,(c) / add DE,0x20 /
            W_ = {'E': 'DE', 'C': 'BC', 'L': 'HL'}[I]
            F.emit('ld', '%s,%s' % (W_, im))
            if off: F.emit('inc' if off <= 8 else 'add', '%s,%s' % (hx(off), W_) if off <= 8 else '%s,%s' % (W_, hx(off)))
            F.emit('ld', '%s,%s' % (P, pm)); return '(%s+%s)' % (P, I)
        F.emit('ld', 'WA,%s' % im)
        if size > 1: scale_reg(F, 'WA', size, 'sla')
        if off: F.emit('inc' if off <= 8 else 'add', '%s,WA' % hx(off) if off <= 8 else 'WA,%s' % hx(off))
        if vk in ('K', 'C'): I, P = 'C', 'XWA'                  # st_i_YK: ld C,A / ld XWA,(_gps) / ldw (XWA+C),0x7
        F.emit('ld', '%s,A' % I); F.emit('ld', '%s,%s' % (P, pm))
        if vk == 'T': F.emit('lda', 'XBC,%s+%s' % (P, I)); return '(XBC)'
        return '(%s+%s)' % (P, I)
    if L == 'Q':
        pm, (im, signed) = lk[1], lk[2]
        if size == 1:                                      # st_c_QG: ld XWA,(_gp) / ld BC,(c) / extz XBC / add XBC,XWA
            X = 'XDE' if vk in ('S', 'X') else 'XBC'
            F.emit('ld', 'XWA,%s' % pm); F.emit('ld', '%s,%s' % (X[1:], im))
            F.emit('extz', X); F.emit('add', '%s,XWA' % X); return '(%s)' % X
        if F.opt and P != 'XWA' and im != 'WA':            # -O: built in its own register (st_i_QG O3XS: ld BC,(c) /
            I_ = P[1:]                                     # exts XBC / add XBC,XBC / add XBC,(_gpi))
            F.emit('ld', '%s,%s' % (I_, im)); F.emit('exts' if signed else 'extz', P)
            if size == 2: F.emit('add', '%s,%s' % (P, P))
            else: F.emit('sll', '0x2,%s' % P)
            F.emit('add', '%s,%s' % (P, pm)); return '(%s)' % P
        F.emit('ld', 'WA,%s' % im); F.emit('exts' if signed else 'extz', 'XWA')
        if size == 2: F.emit('add', 'XWA,XWA')
        else: F.emit('sll', '0x2,XWA')
        if P == 'XWA': F.emit('add', 'XWA,%s' % pm); return '(XWA)'
        F.emit('ld', '%s,XWA' % P); F.emit('add', '%s,%s' % (P, pm)); return '(%s)' % P
    return None

def plan_store_xiz(F):
    """before the frame: a long helper stored through a pointer keeps the address in XIZ across the call
    (st_l_DV); when nothing else uses XIZ the prologue saves it for those stores"""
    if not STORE_PLAN or F.xiz_vars: return
    hit = []
    def v(n, d):
        if n.k == 'bin' and n.op == '=' and n.ty is not None and n.ty.size == 4 and strip(n.r).k != 'call':
            k = sp_lvalue_kind(F, n.l)
            if k is not None and k[0] in ('P', 'D', 'Q') and sp_value_kind(F, n.r, 4) == 'H': hit.append(n)
    walk(F.f.body, v)
    if LH_MEMBER and not hit:                              # a long helper with a member-through-a-pointer operand: XIZ
        def w(n, d):                                       # holds its pointer (lh_member)
            if n.k == 'bin' and n.op in ('*', '/', '%') and n.ty is not None and n.ty.size == 4 and n.ty.kind == 'int' \
                    and lh_member_kinds(F, n.op, strip(n.l), strip(n.r)) is not None: hit.append(n)
        walk(F.f.body, w)
    if hit:
        F.store_xiz = True; F.xiz_vars.append('stores'); F.save_reg = 'XIZ'; F.emit('push', 'XIZ'); F.push = 4

REGTEMP = True                                            # see plan_regtemps
REGTEMP_OPT = True                                        # register temporaries under -O as well (loc0 O3XS)
REGTEMP_OPT_SCRATCH = False                               # -O: the source of a computed initialiser into a scratch register
                                                          # first (lo_i_Bgd: ld WA,(_hi) / ld BC,(_gi) / add BC,WA): off, it
                                                          # costs more loc0 O3XS rows than it wins (lo_i_Bgs keeps add BC,(_hi))
REGTEMP_INPLACE = True                                    # a dying HL temporary takes the operator in place (evorder_bin)
XIZ_DIRECT_INIT = True                                    # an XIZ home's initialiser is loaded or computed in XIZ
XIZ_DIRECT_OPT = True                                     # under -O as well (loc0 O3XS lo_l_Gcs: ld XIZ,(_gl))
REGTEMP_PICK = [{}]                                       # decl name -> index of the candidate home being tried

def plan_regtemps(F):
    """without -O a local with an initialiser whose value never lives across a call is a register temporary
    (corpus/probes/loc0.c, run 2026-11-10-14-micro-loc0): WA when nothing intervenes between its declaration and
    its uses (lo_i_G0d: ld WA,(_gi) / ld (_hi2),WA / push WA), else the lowest of BC, DE, HL that the code in
    between does not write (lo_i_Ggs: ld BC,(_gi) / ld WA,(_hj) / ld (_hi),WA / ld (_hi2),BC; random r1_00_07:
    XHL behind an element update that uses BC and DE; r1_04_12: XDE behind a pointer store through XBC); a call
    result stays in HL (lo_i_Rgs: cal _ri / ... / ld (_hi2),HL).  A byte takes the low half (lo_c_Ggs: ld C,(_gc)),
    a long or pointer the whole register (lo_l_Ggs: ld XBC,(_gl)).  The candidates are tried in that order: the
    live-register guard raises LiveClobber when the code in between writes the home, and compile_function retries
    with the next one; when all fail the local keeps its slot.  The values that live across a call are homes2's
    (IZ / QIZ / XIZ)."""
    for d, cands in regtemp_candidates(F):
        if getattr(d, 'reg', None) or getattr(d, 'home_slot', False): continue
        k = REGTEMP_PICK[0].get(d.name, 0)
        if k >= len(cands): continue                       # every candidate was clobbered: the slot
        d.reg = cands[k]; d.regtemp = True

def regtemp_premark(F):
    """before the home planners: the locals plan_regtemps will home are no candidates for IZ / XIZ (lo_l_R0a: a long
    call result read once by the next call stays in XHL, where homes2 would put it in XIZ)"""
    for d, cands in regtemp_candidates(F):
        if cands: d.regtemp_pre = True

def regtemp_candidates(F):
    """[(decl, [candidate homes])] for plan_regtemps, from the body alone (its docstring says which locals)"""
    if not REGTEMP or (F.opt and not REGTEMP_OPT) or getattr(F, 'l2', None) or getattr(F, 'leaf', None): return []
    out = []
    body = flat(F.f.body)
    live_params = set()
    def calls_in(n):
        out = []
        walk(n, lambda m, dep: out.append(m) if m.k == 'call' or fpgen.is_fp_op(m) else None)
        return out
    for i, c in enumerate(body):
        if c.k != 'decl' or c.init is None: continue
        d = c.var
        if d.kind != 'local' or d.addr_taken or \
                getattr(d, 'no_fold', False) or d.ty.kind in ('array', 'struct') or fpgen.is_fp(d.ty) or \
                d.ty.size not in (1, 2, 4) or not d.uses: continue
        rest = body[i + 1:]
        used = [k for k, x in enumerate(rest) if uses_decl(x, d)]
        if not used: continue
        last = used[-1]
        if any(calls_in(x) for x in rest[:last]): continue      # a call in between: homes2's case
        lx = rest[last]
        cl = calls_in(lx)
        if cl:                                             # the last statement may call once, with the local among the
            if len(cl) != 1 or cl[0].k != 'call' or (lx.k == 'expr' and strip(lx.e) is not cl[0]) or lx.k != 'expr' or \
                    not any(uses_decl(a_, d) for a_ in cl[0].args) or any(calls_in(a_) for a_ in cl[0].args):
                continue                                   # arguments it dies in (lo_i_Gga: push BC / cal _vi)
        if has_helper_call(c.init) and strip(c.init).k != 'call': continue
        nx_ = rest[0]
        nxcall_ = nx_.k == 'expr' and strip(nx_.e).k == 'call'
        ci = strip(c.init)
        while ci.k == 'cast': ci = strip(ci.e)
        if ci.k == 'addr' and strip(ci.e).k == 'var' and strip(ci.e).decl.kind in ('local', 'param') and F.opt: continue
        if ci.k == 'bin' and ci.ty is not None and ci.ty.is_ptr() and \
                any(unpromote(y).ty is not None and unpromote(y).ty.size == 1 for y in (ci.l, ci.r)): continue
        # (a pointer plus a char index: zero-extended through XDE by the oracle, r3_03_11; unmodelled)
        # (a stack address: folded into its uses, _tan's p = (unsigned short *)&x -> ld WA,(XSP+0x3a))
        if last == 0 and foldable(F.f, d) and not nxcall_ and ci.k != 'call' and not cw_index_use(rest[0], d): continue   # read once by the next
        # statement: folded there; a call result instead stays in HL and takes the operator there (lo_i_R0e: cal _ri /
        # add HL,(_hi) / ld (_hi2),HL)
        ci = strip(c.init)                                 # (binop_i.c add_i_loc: int x = a + b; return x; -> ld HL,(a) /
                                                           # add HL,(b)); an argument is materialized (lo_i_G0a:
                                                           # ld WA,(_gi) / push WA, not pushw (_gi))
        while ci.k == 'cast': ci = strip(ci.e)
        if last == 0 and d.ty.size == 1 and len(used) == 1 and rest[0].k == 'return': continue   # (a byte returned
                                                           # next: the older rule below, binop_c.c shl_c_loc: x in C)
        cands = ['HL', 'BC', 'DE'] if ci.k == 'call' else ['WA', 'BC', 'DE', 'HL']
        # (WA is tried with the code in between written as if WA were free -- live_regs hides a WA temporary -- so
        # that a statement that computes anything moves the temporary to BC: lo_i_Ggs ld BC,(_gi) / ld WA,(_hj),
        # while lo_i_G0d's store and push keep it in WA)
        for p in F.f.params:                               # -Xr: a register parameter still read keeps its register
            if getattr(p, 'reg', None) in ('WA', 'BC', 'DE') and any(uses_decl(x, p) for x in body[i:]):
                cands = [r for r in cands if r != p.reg]
        d.regtemp_keep_wa = False
        if F.adecl and F.opt and cl and lx is rest[-1] and 'WA' in cands and d.ty.size in (2, 4):
            cands = ['WA'] + [r for r in cands if r != 'WA']; d.regtemp_keep_wa = True   # (the tail call's argument)
        out.append((d, cands))
    return out

def plan_frame(F):
    """stack slots for locals without a register (rc_loop2-4: dec N,XSP / push XIZ / slots from (XSP+4) in
    declaration order); parameters move up by the frame size"""
    f = F.f; pos = 0; slots = []
    if getattr(F, 'fp_temps', None) is not None: return fp_plan_frame(F)
    calls = []
    walk(f.body, lambda n, d: calls.append(n) if n.k == 'call' or fpgen.is_fp_op(n) or (n.k == 'bin' and n.op in '*/%' and n.ty.size == 4
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
        if d.kind == 'local' and d.ty.kind == 'array' and d.uses and d not in getattr(F, 'l2', {}).get('arr', {}):
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
    homed = [d for d in reversed(f.params) if getattr(d, 'home_slot', False)]   # mul_l_loc under O3XSXr: x, then b;
                                                     # ls_cl_noguard (-Xr): s at +0x4, n at +0x6 (the last first)
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

def fp_plan_frame(F):
    """a function that does floating point (fp.c): FP locals from the top of the frame down in declaration order
    (d_loc2: t at +0x8, u at +0x0), then the temporaries below them, in a region twice their size (d_from_i: a
    4-byte temporary at (XSP+0x4) of 8; d_four: two doubles at +0x18 and +0x10 of 0x20); a float result has its
    own 4 bytes (f_add_gg: dec 0x4,XSP / ... / ld XHL,(XSP))"""
    f = F.f
    locs = [d for d in f.decls if d.kind == 'local' and fpgen.is_fp(d.ty) and (d.uses or True)]
    ints = [d for d in f.decls if d.kind == 'local' and not getattr(d, 'reg', None) and not fpgen.is_fp(d.ty)
            and not foldable(f, d) and (d.ty.kind not in ('array', 'struct') or FP_AGGR and d.ty.kind == 'struct' or
                                        LOCAL_ARRAY_INIT and d.ty.kind == 'array')   # (__fint: maru, work)
            and d.uses]                                    # _frexp: the union d (8 bytes) in the frame
    ints += [d for d in f.params if getattr(d, 'home_slot', False)]   # adecl homes, below the locals, the last
                    # parameter lowest (probes/adfp.c ad_ifi: dec 0x6,XSP / push IZ / ld (XSP+0x2),DE / ld (XSP+0x4),XBC)
    I = sum((d.ty.size + 1) // 2 * 2 for d in ints)          # _log: nptr (address taken) at the very top
    L = sum((d.ty.size + 1) // 2 * 2 for d in locs)
    rets = []
    walk(f.body, lambda n, d: rets.append(n) if n.k == 'return' and n.value is not None else None)
    simple = all(fpgen.fp_value_cast(r.value).k == 'load' and strip(fpgen.fp_value_cast(r.value).e).k == 'var' for r in rets)
    fret = 4 if fpgen.is_fp(f.ret) and f.ret.size == 4 and not simple else 0   # (r_f: ld XHL,(_gf), no frame)
    fargs = 0                                              # adecl: a float argument in a register position has a
    if F.adecl:                                            # 4-byte temporary of its own (probes/adfp.c ac_fi: dec 0x4,
        def fa(n, d):                                      # XSP; where it sits among other slots is not probed yet:
            nonlocal fargs                                 # here at the top, below a float result)
            if n.k == 'call' and strip(n.fn).k == 'var' and not getattr(strip(n.fn).decl.ty, 'cdecl', False) and \
                    any(i < 3 and fpgen.is_fp(strip(a).ty) and strip(a).ty.size == 4 for i, a in enumerate(n.args)):
                fargs = 4
        walk(f.body, fa)
    fret += fargs
    T = F.fp_temps                                         # the region, D + D' (fpgen.FrameAlloc)
    size = I + L + T + fret
    size = (size + 1) // 2 * 2
    top = size - fret
    for d in ints + locs:
        top -= (d.ty.size + 1) // 2 * 2; d.slot = top
    F.ftemp_top = top; F.ftemp_used = 0; F.fret_slot = size - (fret - fargs) if fret - fargs else None
    F.farg_slot = size - fret if fargs else None
    F.frame = size
    if (fpgen.needs_xiz(F) or fpgen.has_elem_hoist(F)) and not F.xiz_vars:   # fp_temps.c t_mla: push XIZ
        F.lines.insert(1, '\tpush\tXIZ'); F.push += 4; F.xiz_vars.append('sret'); F.save_reg = 'XIZ'
        if fpgen.needs_sret_home(F):                       # _sin: ld XIZ,(XSP+0x38) right after the push
            F.sret_home = True
            if getattr(F, 'sret_home_late', False): F.sret_home_pending = '\tld\tXIZ,(XSP+%s)' % hx(F.sret.off + size + F.push)
            else: F.lines.insert(2, '\tld\tXIZ,(XSP+%s)' % hx(F.sret.off + size + F.push))
    if not size: return
    for p in f.params:
        if hasattr(p, 'off'): p.off += size
    F.lines.insert(1, '\tdec\t%s,XSP' % hx(size) if size <= 8 else '\tlda\tXSP,XSP-%s' % hx(size))

def epilogue(F):
    for r in reversed(F.pushes): F.emit('pop', r)
    if getattr(F, 'frame', 0):
        n = F.frame
        if F.lines and F.lines[-1].startswith(('\tinc\t', '\tlda\tXSP,XSP+')) and F.lines[-1].endswith(('XSP',)) or \
                (F.lines and F.lines[-1].startswith('\tlda\tXSP,XSP+')) and not F.pushes and not F.xiz_vars:
            # fp.c d_call_v: cal _vd / lda XSP,XSP+0x18 (8 + 0x10); _sprintf: cal __doprnt / lda XSP,XSP+0x10
            m = re.match(r'^\t(?:inc\t(0x[0-9a-f]+),XSP|lda\tXSP,XSP\+(0x[0-9a-f]+))$', F.lines[-1])
            if m: n += int(m.group(1) or m.group(2), 16); F.lines.pop()
        F.emit('inc', '%s,XSP' % hx(n)) if n <= 8 else F.emit('lda', 'XSP,XSP+%s' % hx(n))

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
        if RET_CC_KEEPS and t.startswith('ret\t') and t != 'ret\t' and not t.startswith('retd'):
            out.append(l); prev = None; continue           # ret eq: the fall-through keeps it (cn_tern_i under -O3 -XS:
                                                           # ld HL,(c) / cpw (k),0x0 / ret eq / sub HL,0x20)
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
        mem_ = args[1] if op in ('inc', 'dec', 'incw', 'decw', 'incb', 'decb') and len(args) == 2 else (args[0] if args else '')
        if mem_.startswith('(XSP') and op not in ('cp', 'cpb', 'cpw', 'bit', 'push', 'pushw', 'ld'):
            for k in list(known):                          # (r2_04_19: decw 0x1,(XSP) ended BC's copy of i)
                if known[k][1] == mem_: del known[k]
        if op in ('cpb', 'cpw') and len(args) == 2 and args[0].startswith('(XSP'):
            w = 1 if op == 'cpb' else 2                    # ae_c_chain_lg: ld A,(XSP+0x4) / ld (_gc),A / cp A,0x0
            hit = [r for r, m in known.values() if m == args[0] and len(r) == w and not r.startswith('Q')]
            if hit:
                out.append('\tcp\t%s,%s' % (hit[0], args[1])); prev = None; continue
        if args and family_of(args[0].rstrip(':')):
            known.pop(family_of(args[0]), None)
        elif op in ('inc', 'dec', 'sla', 'sll', 'sra', 'srl', 'rl', 'rr', 'rlc', 'rrc') and len(args) == 2 and family_of(args[1]):
            known.pop(family_of(args[1]), None)        # (r1_04_01 -O3 -XS: sla 0x2,C ends C's copy of a)
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

def _spell(fam):
    """the spellings of a register family by width: {4: 'XHL', 2: 'HL', 1: 'L', 'hi': 'H', 'q': 'QHL'}
    (fam as family_of names it, 'XHL', or as FAM does, 'HL')"""
    if fam and fam.startswith('X'): fam = fam[1:]
    out = dict(FAM.get(fam, {}))
    if fam in HIGHB8: out['hi'] = HIGHB8[fam]
    if fam in ('WA', 'BC', 'DE', 'HL'): out['q'] = 'Q' + fam
    return out

def store_forward(lines):
    """-O: after `ld (M),R` with M a global or static, a later `ld R2,(M)` in the same straight-line region is
    dropped and R2's uses read R instead, until R2 or R is written again (_strtok: save = strpbrk(s1, s2);
    if (save) { *save = 0; ... } -> ld (S1),XHL / or XHL,XHL / j eq,L4 / ldb (XHL),0x0).  The region ends at a
    label, a call, a jump without a condition or a ret; `or R,R` keeps R's value and does not end it."""
    import re
    def writes(t, fam):
        """does instruction t (stripped) write a register of family fam?  (its first operand, unless a compare,
        test, push or a store to memory; `or R,R` of the same register keeps its value)"""
        parts = t.split(None, 1); op = parts[0]; args = [x.strip() for x in parts[1].split(',')] if len(parts) > 1 else []
        if not args: return op in ('pop',) and False
        if op in ('cp', 'cpb', 'cpw', 'bit', 'push', 'pushw', 'cal', 'call', 'ldir', 'ldirw'): return op in ('ldir', 'ldirw')
        if op == 'or' and len(args) == 2 and args[0] == args[1]: return False
        if op in ('ex',): return any(family_of(x) == fam for x in args)
        if op in ('inc', 'dec', 'sla', 'sll', 'sra', 'srl', 'rl', 'rr', 'rlc', 'rrc', 'scc') and len(args) == 2:
            return family_of(args[1]) == fam             # (r1_04_01 -O3 -XS: sla 0x2,C ended C's copy of a; r1_04_12:
        if op == 'pop': return family_of(args[0]) == fam   # scc ne,WA ended XWA's copy of gp)
        if args[0].startswith('('): return False
        return family_of(args[0]) == fam
    def mentions(t, fam):
        sp = _spell(fam)
        return any(re.search(r'(?<![A-Z])%s(?![A-Z])' % re.escape(v), t) for v in sp.values())
    def rename(t, f_from, f_to):
        a, b = _spell(f_from), _spell(f_to)
        for k, v in a.items():
            if k in b: t = re.sub(r'(?<![A-Z])%s(?![A-Z])' % re.escape(v), b[k], t)
        return t
    out = list(lines); i = 0
    while i < len(out):
        t = out[i].strip()
        m = re.match(r'^ld\t(\((?:_\w+|S\d+)\)),(X?(?:WA|BC|DE|HL|IX|IY))$', t)
        if not m: i += 1; continue
        M, R = m.group(1), m.group(2); fR = family_of(R)
        j = i + 1
        while j < len(out):
            u = out[j].strip()
            if u.endswith(':') or u.startswith(('cal', 'call', 'ret', 'djnz')) or (u.startswith('j') and ',' not in u): break
            if u.startswith('j'): j += 1; continue
            mm = re.match(r'^ld\t(X?(?:WA|BC|DE|HL|IX|IY)),%s$' % re.escape(M), u)
            if mm and len(mm.group(1)) == len(R) and family_of(mm.group(1)) != fR:
                R2 = mm.group(1); f2 = family_of(R2)        # the reload: rename R2's uses to R until R2 is written
                k = j + 1; ok = True; ren = []
                while k < len(out):
                    v = out[k].strip()
                    if v.endswith(':') or v.startswith(('cal', 'call', 'ret', 'djnz')) or (v.startswith('j') and ',' not in v): break
                    if v.startswith('j'): k += 1; continue
                    parts = v.split(None, 1); vargs = [x.strip() for x in parts[1].split(',')] if len(parts) > 1 else []
                    if parts[0] in ('ld', 'lda', 'pop') and vargs and family_of(vargs[0]) == f2 and \
                            not any(mentions(x, f2) for x in vargs[1:]): break   # R2 defined again: the range ends
                    if parts[0] == 'or' and len(vargs) == 2 and vargs[0] == vargs[1] and family_of(vargs[0]) == f2:
                        ren.append(k); k += 1; continue    # or XWA,XWA: a test, renamed (or XHL,XHL keeps R)
                    if writes(v, f2): ok = False; break     # a read-modify-write of R2: not renamed (it would
                                                            # change R)
                    if mentions(v, f2): ren.append(k)
                    if writes(v, fR): ok = False; break     # R changes while R2 would still read it
                    k += 1
                if not ok: j += 1; continue
                for k_ in ren: out[k_] = rename(out[k_], f2, fR)
                del out[j]; continue
            if writes(u, fR) or (u.startswith('ld\t') and u.split('\t')[1].split(',')[0] == M): break
            if mm: j += 1; continue
            j += 1
        i += 1
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

def place_exit_blocks(lines):
    """-O: a block ending in ret that nothing falls into (the code before it ends in ret / j) moves to replace the
    first unconditional jump to it (switch.c sw_evtab under O3XSXr: the default arm returns, so `L10: ld HL,0x1 /
    ret` goes after case 0x2000's `cal .f1`, which then falls into it)"""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    def uncond(l): return l.startswith(('\tret', '\tj\t', '\tretd')) and ',' not in l
    i = 0
    while i < len(lines):
        if is_label(lines[i]) and re.match(r'^L\d+$', lines[i][:-1]):
            k = i - 1
            while k >= 0 and is_label(lines[k]): k -= 1
            if k >= 0 and uncond(lines[k]) and i == k + 1:
                e = i + 1                                  # (__doform.c _zerochk: a rotated loop's test block
                while e < len(lines) and is_label(lines[e]): e += 1   # with its j ne,L2 moves too; L3: L1: both)
                labs = {l_[:-1] for l_ in lines[i:e]}
                while e < len(lines) and not uncond(lines[e]) and not is_label(lines[e]) and \
                        not (lines[e].startswith('\tj') and ',' not in lines[e]): e += 1
                if e < len(lines) and lines[e] == '\tret' and e - i <= 7:
                    first = next((j for j in range(k) if lines[j].startswith('\tj\t') and ',' not in lines[j] and
                                  lines[j].split('\t')[2] in labs), None)
                    if first is not None:
                        block = lines[i:e + 1]
                        del lines[i:e + 1]
                        lines[first:first + 1] = block
                        i = 0; continue
        i += 1
    return lines

def cross_jump(F, lines):
    """-O tail merging (switch.c and ctrl.c under -O3 -XS -Xr).  Jumps to the next label go first.  Then, for each
    label L, the instruction before each `j L` is compared with the one that falls into L: if they are equal the
    jumps move up to a new label before the falling instruction (sw_jt6: ld WA,0xa / j L50000 ... ld WA,0xf /
    L50000: cal .f1 / L3: ret); with no matching fall-through, two or more equal ones merge into the last
    (sw_jt6d: ld WA,0xf / L50002: cal .f1 / j L9).  Repeats while tails match."""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    def uncond(l): return l.startswith(('\tret', '\tj\t', '\tretd')) and ',' not in l
    lines = drop_jump_to_next(lines)
    if EXIT_PLACEMENT: lines = place_exit_blocks(lines)
    made = set(); made_new = set(); F.cj_labels = made_new
    while True:
        done = False
        for li, lab in enumerate(lines):
            if not is_label(lab): continue
            L = lab[:-1]
            if TERN_NO_MERGE and L in getattr(F, 'cond_joins', ()): continue   # a ?: keeps both arms' moves
            k = li - 1                                     # (chnarrow.c cn_tern -O3 -XS -Xr: ld L,A twice)
            while k >= 0 and is_label(lines[k]): k -= 1
            X = lines[k] if k >= 0 and not uncond(lines[k]) and not lines[k].startswith('\tj') \
                and not lines[k].startswith('\tcal\t._f') else None        # fp.c d_cond: each arm keeps its ._fld_dd
            jumps = [i for i, l in enumerate(lines) if l == '\tj\t' + L and i > 0 and not is_label(lines[i - 1])
                     and not lines[i - 1].startswith(('\tj', '\tret'))]
            js = [i for i in jumps if X is not None and lines[i - 1] == X]
            N = None
            if js:                                         # merge into the fall-through
                N = F.newlabel(); made_new.add(N)
                if L in getattr(F, 'if_joins', ()): made.add(L)   # ls_mc: the arms' join label goes (a switch's end
                                                                 # label stays, sw_jt6: L9: ret)
                for i in sorted(js, reverse=True): lines[i - 1:i + 1] = ['\tj\t' + N]
                k = [i for i in range(len(lines)) if lines[i] == lab][0] - 1
                while is_label(lines[k]): k -= 1
                lines.insert(k, N + ':')
            else:
                byx = {}
                for i in jumps:
                    if not lines[i - 1].startswith('\tcal\t._f'): byx.setdefault(lines[i - 1], []).append(i)
                grp = [g for g in byx.values() if len(g) >= 2]
                if grp:
                    g = grp[0]; X2 = lines[g[0] - 1]; N = F.newlabel(); made_new.add(N)
                    for i in sorted(g[:-1], reverse=True): lines[i - 1:i + 1] = ['\tj\t' + N]
                    last = max(i for i, l in enumerate(lines) if l == '\tj\t' + L and lines[i - 1] == X2)
                    lines.insert(last - 1, N + ':')        # the last `X / j L` of the group keeps the code
            if N: done = True; made.add(N); break
        if not done and RET_TAILS:                         # switch.c sw_ret under O3XSXr: arms ending in the same
            byx = {}                                       # `cal .g1 / ret` keep the last copy, the others jump to it
            for i, l in enumerate(lines):                  # (ld WA,0x1 / j L9 ... ld WA,0x6 / L9: j .g1)
                if l == '\tret' and i > 0 and not is_label(lines[i - 1]) and lines[i - 1].startswith('\tcal\t') and \
                        not lines[i - 1].startswith('\tcal\t._f') and not lines[i - 1].startswith('\tcal\tC9H_'):
                    byx.setdefault(lines[i - 1], []).append(i)
            grp = [(x, g) for x, g in byx.items() if len(g) >= 2]
            if grp:
                X, g = grp[0]; N = F.newlabel(); made_new.add(N); made.add(N)
                for i in sorted(g[:-1], reverse=True): lines[i - 1:i + 1] = ['\tj\t' + N]
                pos = max(i for i, l in enumerate(lines) if l == '\tret' and i > 0 and lines[i - 1] == X)
                lines.insert(pos - 1, N + ':'); continue
        if not done: break
    if CJ_TRAMPOLINES:                                     # switch.c sw_ev under O3XSXr: an arm the merge reduced to
        while True:                                        # `L1: j N` (after a ret / j) goes, and its jumps go to N
            hit = None                                     # (j eq,L50039)
            for i in range(1, len(lines) - 1):
                if is_label(lines[i]) and re.match(r'^\tj\t(L\d+)$', lines[i + 1]) and uncond(lines[i - 1]) and \
                        lines[i + 1].split('\t')[2] in made_new and re.match(r'^L\d+$', lines[i][:-1]):
                    hit = i; break
            if hit is None: break
            L = lines[hit][:-1]; T = lines[hit + 1].split('\t')[2]
            del lines[hit:hit + 2]
            lines = [re.sub(r'([\t,])%s$' % re.escape(L), r'\g<1>%s' % T, l) if l.startswith('\t') else l for l in lines]
            lines = [re.sub(r'\b%s-' % re.escape(L), '%s-' % T, l) if l.startswith('\tdw') else l for l in lines]
    def refs(L): return sum(1 for l in lines if l.startswith('\t') and re.search(r'[\t,]%s$' % re.escape(L), l))
    def named(L): return any(re.search(r'\b%s\b' % re.escape(L), l) for l in lines if not (is_label(l) and l[:-1] == L))
    return [l for l in lines if not (is_label(l) and l[:-1] in made and not refs(l[:-1]) and   # _memccpy: one L50000
                                     (l[:-1] in made_new or not named(l[:-1])))]

def thread_jumps(lines, keep=(), full=True, joins=()):
    """-O jump threading (_atoi: if (isdigit(c)) ... else break; inside for (;;) -> j eq,L6 to the exit, the arm's
    end j L5 to the loop top): a jump to a label whose next instruction is `j X` goes to X; adjacent labels merge
    into the first; a `label: j X` block that nothing reaches after an unconditional jump goes."""
    def is_label(l): return l.endswith(':') and not l.startswith('\t')
    alias = {}
    for i in range(1, len(lines)):
        if is_label(lines[i]) and is_label(lines[i - 1]) and lines[i][:-1] not in keep and lines[i - 1][:-1] not in keep \
                and (full or lines[i][:-1] in joins or lines[i - 1][:-1] in joins):   # _strstr: L6: L5: -> one
            a = lines[i - 1][:-1]
            alias[lines[i][:-1]] = alias.get(a, a)
    lines = [l for i, l in enumerate(lines) if not (is_label(l) and l[:-1] in alias)]
    def tgt(l):
        m = re.match(r'^\t(j)\t(?:([a-z]+),)?(L\d+)$', l)
        return m
    def retarget(l, new):
        return re.sub(r'(L\d+)$', new, l)
    lines = [retarget(l, alias[tgt(l).group(3)]) if tgt(l) and tgt(l).group(3) in alias else l for l in lines]
    for _ in range(8 if full else 0):                  # (not outside L2: _strncpy keeps its L3: j L4 trampoline)
        where = {l[:-1]: i for i, l in enumerate(lines) if is_label(l)}
        changed = False
        for i, l in enumerate(lines):
            m = tgt(l)
            if not m: continue
            j = where.get(m.group(3))
            if j is None or j + 1 >= len(lines): continue
            nx = tgt(lines[j + 1])
            if nx and nx.group(2) is None and nx.group(3) != m.group(3):
                lines[i] = retarget(l, nx.group(3)); changed = True
        if not changed: break
    for i in range(len(lines) - 2):                     # _strrchr: j ne,L3 / j L4 / L3: -> j eq,L4 / L3:
        m1, m2 = tgt(lines[i]), tgt(lines[i + 1])
        if m1 and m2 and m1.group(2) and m2.group(2) is None and lines[i + 2] == m1.group(3) + ':' and m1.group(2) in INV:
            lines[i] = '\tj\t%s,%s' % (INV[m1.group(2)], m2.group(3)); lines[i + 1] = '\t;dead'
            L = m1.group(3)
            if not any(re.search(r'[\t,]%s$' % L, l) for l in lines if l.startswith('\t') and l != '\t;dead') and \
                    not (i + 3 < len(lines) and lines[i + 3].startswith('\tdjnz')) and L not in keep:
                lines[i + 2] = '\t;dead'                  # _strstr: the label the inversion emptied goes (not
                                                         # _strrchr's L4: djnz)
    lines = [l for l in lines if l != '\t;dead']
    where = {l[:-1]: i for i, l in enumerate(lines) if is_label(l)}
    for i, l in enumerate(lines):                      # _strcspn: j eq,L6 ... L6: ret -> ret eq
        m = tgt(l)
        if m and m.group(2):
            j = where.get(m.group(3)); k = j + 1 if j is not None else None
            while k is not None and k < len(lines) and is_label(lines[k]): k += 1
            if k is not None and k < len(lines) and lines[k] == '\tret': lines[i] = '\tret\t%s' % m.group(2)
    def refs(L): return any(re.search(r'[\t,]%s$' % L, l) for l in lines if l.startswith('\t'))
    drop = set()
    for i, l in enumerate(lines):
        if i in drop or not is_label(l) or refs(l[:-1]) or i + 1 >= len(lines): continue
        nx = tgt(lines[i + 1])
        prev = next((lines[k] for k in range(i - 1, -1, -1) if k not in drop), '')
        if nx and nx.group(2) is None and prev.startswith(('\tj\t', '\tret')) and ',' not in prev:
            drop.update((i, i + 1))
    lines = [l for i, l in enumerate(lines) if i not in drop]
    if not full: return lines
    return [l for i, l in enumerate(lines) if not (is_label(l) and re.match(r'^L\d+$', l[:-1]) and not refs(l[:-1]) and
                                                   l[:-1] not in keep and
            not (i + 1 < len(lines) and lines[i + 1].startswith('\tdjnz')))]   # _strrchr: L4: djnz BC,L2 stays

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
    if CDECL_TAILCALL:                                     # switch.c sw_jt6d under O3XS: `cal _f0 / L2: ret` with
        rr = getattr(F, 'ret_refs', set())                 # L2 unreferenced -> j _f0 (cmp_i eq_i_br keeps
        drop = set()                                       # `cal _hit / L1: ret`: L1 was jumped to)
        for i in range(1, len(out) - 1):
            if is_label(out[i]) and out[i - 1].startswith('\tcal\t_') and out[i + 1] == '\tret' and \
                    not refs(out[i][:-1]) and out[i][:-1] not in rr and re.match(r'^L\d+$', out[i][:-1]) and \
                    out[i][:-1] not in getattr(F, 'gen_refs', set()) and out[i][:-1] not in getattr(F, 'if_joins', set()):
                drop.add(i)
        out = [l for i, l in enumerate(out) if i not in drop]
    res = []
    for i, l in enumerate(out):
        if l == '\tret' and res and res[-1].startswith('\tcal\t_') and CDECL_TAILCALL and \
                not res[-1].endswith(';stack') and not res[-1].split('\t')[2].startswith('C9H_'):
            res[-1] = '\tj\t' + res[-1].split('\t')[2]; continue
        if l == '\tret' and res and res[-1].startswith('\tcal\t') and res[-1].split('\t')[2].startswith('.') \
                and not res[-1].split('\t')[2].startswith('._f') and not res[-1].endswith(';stack'):   # fp.c: cal ._fadd_d / ret
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
        elif nxt == '\tret' and (l.split('\t')[2].startswith('.') or CDECL_TAILCALL and l.split('\t')[2].startswith('_')) \
                and not l.endswith(';stack'):                # sw_ret: return g1(1) -> j .g1; switch.c sw_jt8 without
            out[i] = '\tj\t' + l.split('\t')[2]; out[i + 1] = None        # -O: f0(); break; -> j _f0
    out = [l for l in out if l is not None]
    res = []                                               # a jump to the next label goes (sw_local: ld HL,0x7 / L128:)
    for i, l in enumerate(out):
        if l.startswith('\tj\t') and ',' not in l:
            k = i + 1; labs = set()
            while k < len(out) and is_label(out[k]): labs.add(out[k][:-1]); k += 1
            if l.split('\t')[2] in labs: continue
        res.append(l)
    out = res
    if not keep_end and len(out) >= 3 and out[-1] == '\tret' and is_label(out[-2]) and \
            (out[-3].startswith('\tj\t') or out[-3] == '\tret') and ',' not in out[-3]:   # (sw_jt4: ... ret / L4: ret)
        lab = out[-2][:-1]
        if not any(lab in x for x in out[:-2]): out = out[:-2]
    return out

PERSONALITIES = {
    # name: the rule set (rules.md).  v4.23 is Toshiba's 1998 compiler; kn5000 is the Technics compiler as inferred
    # from the firmware (V4.23 plus the reload rule's 2003 side); ide2003 and v1.10 are the dev-kit compilers of 2003
    # and 2009 (phase 7 by-products, decision D6).  On the corpus so far the 2003 and 2009 compilers differ from the
    # kn5000 rule set in no rule the model has: their own ledger lines show where they still differ.
    'v4.23': 'v4.23', 'kn5000': 'kn5000', 'ide2003': 'kn5000', 'v1.10': 'kn5000'}

def compile_function(f, opt, adecl, personality='v4.23', fp_temps=None, fp_nlong=0, fp_remap=None):
    F_OPT_HINT[0] = opt != 'none'
    if fp_temps is None and fpgen.uses_fp(f):
        import copy, sys                                    # pass 1 measures the floating-point temporaries
        sys.setrecursionlimit(max(sys.getrecursionlimit(), 200000))
        save = fpgen.FCONST[0]
        try:
            F1 = compile_function(copy.deepcopy(f), opt, adecl, personality, fp_temps=0)
            need = F1.ftemp_used_total; nlong = F1._fa.nlong if '_fa' in F1.__dict__ else 0
            remap = None
            if fpgen.WINDOW_RULE and '_fa' in F1.__dict__:
                import fpwindow                             # the slot order of the temporaries (E2), guarded
                try: remap = fpwindow.plan(F1._fa.log) or None
                except Exception: remap = None
        finally: fpgen.FCONST[0] = save
        return compile_function(f, opt, adecl, personality, fp_temps=need, fp_nlong=nlong, fp_remap=remap).lines
    if not REGTEMP or (opt != 'none' and not REGTEMP_OPT):
        return compile_function_once(f, opt, adecl, personality, fp_temps, fp_nlong, fp_remap)
    import copy
    picks = {}; base = copy.deepcopy(f); save = fpgen.FCONST[0]
    while True:
        REGTEMP_PICK[0] = picks
        try: return compile_function_once(f, opt, adecl, personality, fp_temps, fp_nlong, fp_remap)
        except LiveClobber as ex:                          # the register temporary's home was written: next candidate
            if os.environ.get('CC900_RT_DEBUG'): print('  regtemp retry %s: %s' % (f.name, ex))
            picks[ex.decl.name] = picks.get(ex.decl.name, 0) + 1
            f = copy.deepcopy(base); fpgen.FCONST[0] = save
        finally: REGTEMP_PICK[0] = {}

def compile_function_once(f, opt, adecl, personality, fp_temps, fp_nlong, fp_remap):
    if personality not in PERSONALITIES: raise ValueError('unknown personality %s' % personality)
    personality = PERSONALITIES[personality]
    merge_address_inits(f)
    if opt != 'none' and not adecl: propagate_global_copies(f); forward_single_use(f)
    gotos = []
    walk(f.body, lambda n, d: gotos.append(n) if n.k == 'goto' else None)
    goto_returns(f)
    F = Fn(f, adecl)
    F.fp_temps = fp_temps; F.fp_nlong = fp_nlong; F.fp_remap = fp_remap
    F.personality = personality
    F.opt = opt != 'none'; F.dead = set(); F.had_goto = bool(gotos); CUR_OPT[0] = F.opt
    if F.opt: bool_returns(f.body)
    if CHAR_NARROW: char_narrow(f.body)
    if F.opt and COPY_PROP: copy_propagate(f)
    compute_last_uses(F)
    F.lines.append(('.' if adecl else '_') + f.name + ':')
    F.loops = []; F.param_copies = []; F.pushes = []
    if adecl and BINLOC_XR: xr_shift_reloc(F)
    if not plan_leaf(F): regtemp_premark(F); plan_registers(F); plan_homes(F); plan_regtemps(F); plan_store_xiz(F)
    plan_frame(F)
    for d in getattr(F, 'l2', {}).get('entry', []) if getattr(F, 'l2', None) else []:
        F.emit('ld', '%s,(XSP+%s)' % (FAM[d.reg][d.ty.size], hx(d.off + F.push)))   # (after the frame: offsets)
    emit_homes(F)
    if F.opt: plan_shared_exit(F)
    F.top_stmts = flat(f.body); F.top_ix = {id(x): k for k, x in enumerate(F.top_stmts)}
    F.guard_armed = True                                   # the live-parameter guard, from the real body on (the
    gen_stmt(F, f.body, True)                              # planners' trial code runs with the registers undecided)
    flush_pops(F)
    if not F.lines[-1].startswith('\tret') and not (getattr(F, 'no_exit', False) and F.lines[-1].startswith('\tj\t')
                                                   and ',' not in F.lines[-1]):
        xl = getattr(F, 'exit_label', None)                # a void function's early return jumps here (the 1997
        if xl and (xl + ':') not in F.lines: F.lines.append(xl + ':')   # library's _sgl_set: j L50001 to nothing)
        if F.xiz_vars: F.emit('pop', F.save_reg)
        epilogue(F)
        F.emit('retd', hx(F.retd)) if F.retd else F.emit('ret')   # op_three: an adecl stack parameter -> retd 0x2
    import re as _rg
    F.gen_refs = {m for l in F.lines if l.startswith('\t') for m in _rg.findall(r'\b(L\d+)\b', l)}   # labels jumped to
    for t in reversed(getattr(F, 'tables', [])): F.lines[1:1] = t     # switch tables right after the label
    if F.opt and getattr(F, 'fp_temps', None) is not None: F.lines = fpgen.hoist_common(F.lines)
    if F.opt and getattr(F, 'l2', None): F.lines = thread_jumps(F.lines, getattr(F, 'user_labels', set()))
    if F.opt: F.lines = tail_calls_opt(F, cross_jump(F, F.lines))
    if F.opt and not getattr(F, 'l2', None) and THREAD_ALL:      # after the tails merge (_strstr: return s1 twice)
        import re as _rt                                   # (a jump table's case labels keep their own name:
        tab = {m for l in F.lines if l.startswith('\tdw') for m in _rt.findall(r'\b(L\d+)-', l)}   # sw_evtab L1, L9)
        F.lines = thread_jumps(F.lines, getattr(F, 'user_labels', set()) | tab, full=False,
                               joins=getattr(F, 'if_joins', set()) | getattr(F, 'cj_labels', set()))
    else: F.lines = tail_calls(F.lines, getattr(F, 'switch_table', False))
    if not F.opt and getattr(F, 'tfam', None):           # ot_cmp_anb under -Xr: j eq,L3 ... L3: ret -> ret eq
        import re as _rx
        for i, l in enumerate(F.lines):
            m = _rx.match(r'^\tj\t(\w+),(L\d+)$', l)
            if m and m.group(2) + ':' in F.lines:
                k = F.lines.index(m.group(2) + ':')
                if k + 1 < len(F.lines) and F.lines[k + 1] == '\tret': F.lines[i] = '\tret\t' + m.group(1)
    import re                                            # no self-moves: the oracle never writes ld XWA,XWA
    F.lines = [l for l in F.lines if not re.match(r'^\tld\t(\w+),\1$', l)]
    F.lines = [l for i, l in enumerate(F.lines) if not (l == '\tret' and i and F.lines[i - 1] == '\tret')]
    # (a ret right after a ret is unreachable: arr_index.c ai_dig_val's trivial return after an if)
    if OR_BIT_SET:                                       # a one-bit or is set: chnarrow.c cn_or_k c | 0x20 -> set
        for i, l in enumerate(F.lines):                  # 0x5,L (no or R,<bit> in any oracle listing so far); kept
            m = re.match(r'^\tor\t(A|W|B|C|D|E|H|L|WA|BC|DE|HL|IX|IY|IZ),0x([0-9a-f]+)$', l)   # when the flags
            if not m: continue                                                               # are read next
            v = int(m.group(2), 16); w = 8 if len(m.group(1)) == 1 else 16
            nxt = F.lines[i + 1] if i + 1 < len(F.lines) else ''
            if v and v & (v - 1) == 0 and v < (1 << w) and not re.match(r'^\t(j|scc|ret|jr)\t\w+,|^\tret\t\w+$|^\tscc', nxt):
                F.lines[i] = '\tset\t%s,%s' % (hx(v.bit_length() - 1), m.group(1))
    if DEC_CMP_SUB:                                      # i-- then i >= 0: sub BC,0x1 / j ge (dec on a register sets no
        for i in range(len(F.lines) - 1):                # flags; no oracle listing has dec 0x1,R / cp R,0x0; the
            m = F.lines[i] and re.match(r'^\tdec\t0x1,(\w+)$', F.lines[i])   # overflow flag of sub ends opt_counted.c oc_down
            if m and F.lines[i + 1] == '\tcp\t%s,0x0' % m.group(1):    # at n = -32768)
                F.lines[i] = '\tsub\t%s,0x1' % m.group(1); F.lines[i + 1] = None
        F.lines = [l for l in F.lines if l is not None]
    if F.opt and RET_KNOWN_GLOBAL: F.lines = ret_known_global(F.lines)
    if F.opt: F.lines = drop_unreachable(F.lines)        # (without -O a switch keeps its end: sw_jt6 L3: ret)
    if F.opt and GLOBAL_FORWARD:                          # _rand: ld (_Seed),XHL / ld XWA,(_Seed) -> ld XWA,XHL (the
        for i in range(len(F.lines) - 1):                 # value just stored, in the next instruction)
            a = re.match(r'^\tld\t\((_\w+)\),(\w+)$', F.lines[i]); b = re.match(r'^\tld\t(\w+),\((_\w+)\)$', F.lines[i + 1])
            if a and b and a.group(1) == b.group(2) and family_of(a.group(2)) and family_of(b.group(1)) and \
                    len(a.group(2)) == len(b.group(1)):
                F.lines[i + 1] = '\tld\t%s,%s' % (b.group(1), a.group(2))
    if F.opt and STORE_FORWARD: F.lines = store_forward(F.lines)   # _strtok: ld (S1),XHL / or XHL,XHL / ldb (XHL),0x0
    F.lines = [l.replace('(XSP+0x0)', '(XSP)').replace('(XSP+0x0~)', '(XSP+0x0)') for l in F.lines]   # the oracle
    # writes (XSP) for a variable at the stack pointer, but (XSP+0x0) for an element of a local aggregate (ZERO_DISP:
    # cond_bits.c cb_union_n0, ld WA,(XSP+0x0) for d.n[0])
    # a call directly followed by the return becomes a jump (cmp_ui: ge_ui_br0)
    if getattr(F, 'naive_loads', False) or (F.opt and not F.adecl): F.lines = knowledge_pass(F.lines, F.personality)
    elif F.personality != 'v4.23': F.lines = store_knowledge(F.lines)
    if len(F.lines) >= 2 and F.lines[-1] == '\tret' and F.lines[-2].startswith('\tcal\t') \
            and not F.lines[-2].split('\t')[2].startswith(('C9H_', '._f')) and not F.lines[-2].endswith(';stack'):
        F.lines[-2:] = ['\tj\t' + F.lines[-2].split('\t')[2]]
    if any(l.endswith('\t;sret-late') for l in F.lines):    # acos, cosh: the home load sits right before the first
        k = next(i for i, l in enumerate(F.lines) if l.endswith('\t;sret-late'))   # test's cp HL,0x0
        ln = F.lines.pop(k)[:-len('\t;sret-late')]
        j = next((i for i in range(k, len(F.lines)) if F.lines[i] == '\tcp\tHL,0x0' or F.lines[i].endswith(':') or
                  F.lines[i].startswith('\tj\t')), k)
        F.lines.insert(j, ln)
    F.lines = [l[:-len('\t;stack')] if l.endswith('\t;stack') else l for l in F.lines]
    F.lines = [l[:-len('\t;u1')] if l.endswith('\t;u1') else l for l in F.lines]
    F.lines[1:1] = fpgen.const_block(F)                  # fp.c: d_add_pk: f_const ... S50000: fdatad ... f_code
    # a label that only a jump to `ret` uses: the oracle keeps it; nothing to do here yet
    if fp_temps is not None:
        F.ftemp_used_total = getattr(F, 'ftemp_max', 0); return F
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
        elif FP_ARRAY_DATA and d.ty.kind == 'array' and e.k == 'initlist' and d.ty.base.kind == 'float':
            import struct                                  # _COSH.C _s_coshtbl: a double table as db rows of its
            rows = []; ok = True                           # eight bytes (db 0,0,0,0,96,46,230,63)
            for it in e.items:
                x = strip(it)
                while x.k == 'cast': x = strip(x.e)
                v = x.value if x.k == 'fconst' else (data_value(x) if x.k == 'const' else None)
                if v is None: ok = False; break
                rows.append(list(struct.pack('<d' if d.ty.base.size == 8 else '<f', float(v))))
            if not ok: continue
            for i, row in enumerate(rows):
                if i: lines.append('\talign\t1')
                lines.append('\tdb\t%s' % ','.join(str(v) for v in row))
        elif e.k == 'initlist' and (d.ty.kind == 'array' and d.ty.base.kind == 'struct' or d.ty.kind == 'struct'):
            rows = []                                      # __FLOAT.C g_dbltbl: one db row per element (its bytes);
            elems = e.items if d.ty.kind == 'array' else [e]   # _COSH.C s_coshtbl: one DBLBIT union (db row)
            ety = d.ty.base if d.ty.kind == 'array' else d.ty
            def flat_fields(x, ty):                        # __AFCNV.C normtab: each field at its own width, eight a
                x = strip(x)                               # line (dl -3529,41638,... / align 1 / dl 63128)
                if ty.kind == 'struct':
                    if x.k != 'initlist': return None
                    out = []; fields = list(ty.rec)
                    if len(fields) > 1 and all(off_ == 0 for _, _, off_ in fields):   # a union: its first member
                        fields = fields[:1]                                           # (__FLOAT.C g_dbltbl: dat[8])
                    for k_, (fname, fty, foff) in enumerate(fields):
                        it = x.items[k_] if k_ < len(x.items) else None
                        r_ = flat_fields(it, fty) if it is not None else [(0, fty.base.size if fty.kind == 'array'
                                                                               else fty.size)] * (fty.size // (fty.base.size
                                                                               if fty.kind == 'array' else fty.size))
                        if r_ is None: return None
                        out += r_
                    return out
                if ty.kind == 'array':
                    if x.k != 'initlist': return None
                    out = []; n_ = ty.size // ty.base.size
                    for k_ in range(n_):
                        it = x.items[k_] if k_ < len(x.items) else None
                        r_ = flat_fields(it, ty.base) if it is not None else [(0, ty.base.size)]
                        if r_ is None: return None
                        out += r_
                    return out
                v = data_value(x)
                return None if v is None else [(v, ty.size)]
            ok = True
            for it in elems:
                vals_ = flat_fields(it, ety)
                if vals_ is None or any(w_ not in (1, 2, 4) for _, w_ in vals_): ok = False; break
                run = []
                for v_, w_ in vals_:                       # rows of up to eight values of one width per element
                    if run and (run[-1][1] != w_ or len(run) == 8): rows.append(run); run = []
                    run.append((v_, w_))
                if run: rows.append(run)
            if not ok: continue
            for i, row in enumerate(rows):
                if i: lines.append('\talign\t1')
                w_ = {1: 'db', 2: 'dw', 4: 'dl'}[row[0][1]]
                lines.append('\t%s\t%s' % (w_, ','.join(str(v & 0xff if w_ == 'db' else v) for v, _ in row)))
        elif d.ty.kind == 'array' and e.k == 'initlist' and d.ty.base.kind == 'int':
            vals = [data_value(x) for x in e.items]        # _CTYPE.C: db 32,32,... eight a line, align 1 between
            if None in vals: continue
            pad = max(0, d.ty.count - len(vals)) if d.ty.count else 0
            if not ARRAY_TAIL_DFB: vals += [0] * pad; pad = 0
            w = {1: 'db', 2: 'dw', 4: 'dl'}[d.ty.base.size]
            rows = [vals[i:i + 8] for i in range(0, len(vals), 8)]
            for i, row in enumerate(rows):
                if i: lines.append('\talign\t1')
                lines.append('\t%s\t%s' % (w, ','.join(str(v) for v in row)))
            if pad:                                        # _CTYPE.C: the 128 elements past the initialiser are
                if rows: lines.append('\talign\t1')      # one dfb 128,0
                lines.append('\tdfb\t%d,0' % (pad * d.ty.base.size))
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

RET_KNOWN_GLOBAL = True

def ret_known_global(lines):
    """-O: j cc,L where L is `ld HL,(_g)` / `ret` and HL was just stored to _g in the same block becomes ret cc
    (assign_expr.c ae_i_call_g: cal .g / ld (_gi),HL / cp HL,0x0 / ret ge / ld HL,0x0 / ret)"""
    import re as _r
    out = list(lines)
    for i, l in enumerate(out):
        m = _r.match(r'^\tj\t(\w+),(L\d+)$', l)
        if not m: continue
        if (m.group(2) + ':') not in out: continue
        k = out.index(m.group(2) + ':')
        if k + 2 >= len(out) or out[k + 2] != '\tret': continue
        lm = _r.match(r'^\tld\t(X?HL),\((_\w+)\)$', out[k + 1])
        if not lm: continue
        R, g = lm.group(1), lm.group(2)
        ok = False
        for j in range(i - 1, -1, -1):                   # back to the store, in the same block
            t = out[j]
            if t == '\tld\t(%s),%s' % (g, R): ok = True; break
            if t.endswith(':') or t.startswith(('\tcal', '\tcall', '\tj', '\tret')): break
            if t.startswith(('\tcp', '\tbit')): continue   # (compares write no register)
            ops = t.split('\t')[2] if t.count('\t') >= 2 else ''
            dst = ops.split(',')[0] if ops else ''
            if dst in ('L', 'H', 'HL', 'XHL', 'QHL') or ('(%s' % g) in ops and not t.startswith('\tcp'): break
        if ok: out[i] = '\tret\t' + m.group(1)
    return out

def drop_unreachable(lines):
    """code after an unconditional ret / retd / j behind a label nothing jumps to is never reached, and the oracle
    does not write it (assign_expr.c ae_i_call: j ge,L1 became ret ge, so `L1: ret` after `ld HL,0x0 / ret` goes;
    cmp_i.c eq_i_br keeps its `L1: ret`, which the call falls into)"""
    import re
    def refs(L):
        return any(re.search(r'[\t,]%s(?:-\w+)?$' % re.escape(L), l) or re.search(r'\b%s-' % re.escape(L), l)
                   for l in lines if not l.endswith(':'))
    out = []; dead = False; changed = False
    for l in lines:
        is_lab = l.endswith(':') and not l.startswith('\t')
        if is_lab and (refs(l[:-1]) or not l[:-1].startswith('L')): dead = False
        elif is_lab and dead: changed = True; continue
        if dead and not is_lab and not l.startswith(('\tdw', '\tdb', '\talign', 'f_', 'S', '\tfdata')):
            changed = True; continue
        out.append(l)
        t = l.strip()
        if not is_lab and (t == 'ret' or t.startswith('retd') or (t.startswith('j\t') and ',' not in t) or t.startswith('jp\t')):
            dead = True
    return out

def compile_unit(unit, opt='none', adecl=False, personality='v4.23'):
    out = {}
    emit_data(unit, out)
    for f in unit.functions:
        fa = adecl or getattr(f, 'adecl_attr', False)        # an __adecl function in a cdecl file (__SBRK.C: .sbrk)
        name = ('.' if fa else '_') + f.name
        try:
            import copy as _copy
            spare = _copy.deepcopy(f) if opt != 'none' and not fa else None
            try:
                full = compile_function(f, opt, fa, personality)
            except Unsupported:                            # cdecl -O: what the old leaf path cannot write, L2 may
                if spare is None: raise                    # (_strcspn); never instead of a function it can write
                global L2_WIDE
                L2_WIDE = True
                try: full = compile_function(spare, opt, fa, personality)
                finally: L2_WIDE = False
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
