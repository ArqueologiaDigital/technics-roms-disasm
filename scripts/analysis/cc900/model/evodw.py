#!/usr/bin/env python3
"""evorder_d_ast.py -- the cc900 V4.23 oracle's code for the functions of probe evorder_d.c (corpus/probes/evorder_d.c, oracle run
2026-11-10-11-micro-evorder3) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 evorder_d_ast.py --check [SET ...] [--show N] [--only REGEX] [--src FILE.c]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the model
        directory on sys.path

The probe's functions: int f(int c) { return L op R; }, op / % (ed_<d|r>_<L><R>), divs XWA / XHL, the result in HL; L and R one of thirteen operand kinds (K 7, G g, M gs.m, P *gp, E ga[3], X ga[c],
D gps->m, N !g, U -g, B (g - h), C (256 - g), T (gc ? g : h), S (g << c)).  The function is classified from its AST
alone; the real symbols, offsets and constants are substituted; anything outside the probe's grammar returns None.
The code is planned by the register allocator of evorder_st_ast.py (fixed reservations, -O direct values, the
accumulator's own address, indexes, the right operand, the left one, an argument's result last), generalised to a
result returned in HL / XHL, the int multiply and divide through XWA and long operands.  Rules:
evorder_more-FAMILIES.md beside this file.  Assembled by dev/build.py from dev/engine.py and dev/parts/evorder_d.py.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402
HOME_ = __import__('os').path.expanduser('~/')

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
VAL = set('NUBCTS')
FAMS = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY')
MNEM = {'-': 'sub', '^': 'xor', '+': 'add'}
PARAM = '(XSP+0x4)'                       # the parameter's slot (cdecl; no frame in these probes)


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


# --------------------------------------------------------------------------------------------- classification

def is_int(ty):
    return ty is not None and ty.kind == 'int' and ty.size == 2 and ty.signed


def is_long(ty):
    return ty is not None and ty.kind == 'int' and ty.size == 4 and ty.signed


class Op:
    """k: kind letter; syms: the global decls it reads; per kind: val (K C), mem / addr / zero (G M E: the memory
    operand, the address for lda, offset 0), ptr / off (P D), arr / esz (X), sym (N U S), a / b (B; T arms),
    c (T)"""

    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s)' % self.k


def gname(d):
    return '_' + d.name


def gvar(n, test):
    n = cg.strip(n)
    need(n.k == 'load' and test(n.ty))
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and test(v.decl.ty))
    return v.decl


def is_param(n, prm):
    n = cg.strip(n)
    if n.k != 'load' or not is_int(n.ty):
        return False
    v = cg.strip(n.e)
    return v.k == 'var' and v.decl is prm


def gptr(n, struct, vt):
    n = cg.strip(n)
    need(n.k == 'load')
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and v.decl.ty is not None and v.decl.ty.kind == 'ptr')
    b = v.decl.ty.base
    need(b is not None and (b.kind == 'struct' if struct else vt(b)))
    return v.decl


def memop(sym, off):
    a = sym if off == 0 else '%s + %s' % (sym, hx(off))
    return '(%s)' % a, a


def operand(n, prm, vt, ksz):
    """one operand of value type vt (is_int / is_long); ksz: the probe's constant 7 and 256 as written"""
    n = cg.strip(n)
    need(vt(n.ty))
    if n.k == 'const':
        need(n.value == 7)
        return Op('K', val=7, syms=[])
    if n.k == 'un' and n.op == '-':
        d = gvar(n.e, vt)
        return Op('U', sym=gname(d), syms=[d])
    if n.k == 'un' and n.op == '!':
        need(vt is is_int)
        d = gvar(n.e, vt)
        return Op('N', sym=gname(d), syms=[d])
    if n.k == 'cast':                                                  # (long)!gl
        need(vt is is_long and n.kind == 'IntegralCast' and not n.explicit)
        u = cg.strip(n.e)
        need(u.k == 'un' and u.op == '!' and is_int(u.ty))
        d = gvar(u.e, is_long)
        return Op('N', sym=gname(d), syms=[d])
    if n.k == 'bin' and n.op == '-':
        l, r = cg.strip(n.l), cg.strip(n.r)
        if l.k == 'const':
            need(l.value == 256 and vt(l.ty))
            d = gvar(r, vt)
            return Op('C', val=256, sym=gname(d), syms=[d])
        a, b = gvar(l, vt), gvar(r, vt)
        need(a is not b)
        return Op('B', a=gname(a), b=gname(b), syms=[a, b])
    if n.k == 'bin' and n.op == '<<':
        d = gvar(n.l, vt)
        need(is_param(n.r, prm))
        return Op('S', sym=gname(d), syms=[d])
    if n.k == 'cond':
        c, a, b = gvar(n.c, is_int), gvar(n.a, vt), gvar(n.b, vt)
        need(len({id(c), id(a), id(b)}) == 3)
        return Op('T', c=gname(c), a=gname(a), b=gname(b), syms=[c, a, b])
    need(n.k == 'load')
    x = cg.strip(n.e)
    if x.k == 'var':
        d = x.decl
        need(d.kind == 'global' and vt(d.ty))
        m, a = memop(gname(d), 0)
        return Op('G', mem=m, addr=a, zero=True, syms=[d])
    if x.k == 'member':
        off = cg.member_offset(x)
        need(off is not None and off >= 0)
        if x.arrow:
            p = gptr(x.base, True, vt)
            return Op('D', ptr=gname(p), off=off, syms=[p])
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'struct')
        m, a = memop(gname(b.decl), off)
        return Op('M', mem=m, addr=a, zero=off == 0, syms=[b.decl])
    if x.k == 'deref':
        p = gptr(x.e, False, vt)
        return Op('P', ptr=gname(p), off=0, syms=[p])
    if x.k == 'index':
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array')
        need(vt(b.decl.ty.base))
        esz = b.decl.ty.base.size
        i = cg.strip(x.idx)
        if i.k == 'const':
            need(i.value is not None and i.value > 0)
            m, a = memop(gname(b.decl), esz * i.value)
            return Op('E', mem=m, addr=a, zero=False, syms=[b.decl])
        need(is_param(i, prm))
        return Op('X', arr=gname(b.decl), esz=esz, syms=[b.decl])
    raise Decline()


def cls(o):
    if o.k == 'K':
        return 'K'
    if o.k == 'G':
        return 'G'
    return 'V' if o.k in VAL else 'A'


# --------------------------------------------------------------------------------------------- the allocator

class Alloc:
    """registers held over intervals [a, b) of the evaluation order: 1 / 2 the left / right operand's address,
    3 the source value, 4 the accumulator, 5 the operator, 6 the result after it"""

    def __init__(self):
        self.iv = {f: [] for f in FAMS}

    def free(self, f, a, b):
        return all(not (x < b and a < y) for x, y, _ in self.iv[f])

    def take(self, f, a, b, tag):
        self.iv[f].append((a, b, tag))
        return f

    def pick(self, a, b, tag, avoid=()):
        for f in FAMS:
            if f not in avoid and self.free(f, a, b):
                return self.take(f, a, b, tag)
        raise Decline()


class Fn:
    """ctx: 'ST' (stored), 'ARG' (an argument), 'RET' (returned); kind: 'alu' (- ^ +), 'mul' (*), 'div' (/ %);
    size: 2 (int) or 4 (long)"""

    def __init__(self, s, ctx, tgt, op, L, R, size=2):
        self.s, self.opt, self.xr = s, s.startswith('O3'), s.endswith('Xr')
        self.ctx, self.tgt, self.op, self.L, self.R, self.size = ctx, tgt, op, L, R, size
        self.kind = 'mul' if op == '*' else 'div' if op in ('/', '%') else 'alu'
        self.wa = ctx == 'ST' or (ctx == 'ARG' and s == 'O3XSXr') or self.kind != 'alu'   # the result planned in WA
        self.n = 0
        self.out = []

    def label(self):
        self.n += 1
        return 'L%d' % self.n

    def e(self, *ls):
        self.out.extend(ls)

    def v(self, f):
        """a family's value register"""
        return f if self.size == 2 else 'X' + f

    def imm(self, f, v):
        return '%s %s,%s' % ('lda' if self.size == 4 and self.opt and 8 <= v < 0x10000 else 'ld', self.v(f), hx(v))


def value(F, o, f, count=None, move=None):
    """the code of a value operand into family f; count: the instruction putting the shift count in WA; move: a
    `!` computed in f and moved to `move` before its widening (long)"""
    r = F.v(f)
    if o.k == 'N':
        if F.size == 2 and getattr(o, 'ltest', False):                # (long)!gl in an int operation
            return ['ld XWA,(%s)' % o.sym, 'or XWA,XWA', 'scc eq,%s' % f] + (['ld %s,%s' % (move, f)] if move else [])
        if F.size == 2:
            return ['cpw (%s),0x0' % o.sym, 'scc eq,%s' % f] + (['ld %s,%s' % (move, f)] if move else [])
        m = move or f
        t = f if getattr(o, 'tself', False) else 'WA'
        return ['ld X%s,(%s)' % (t, o.sym), 'or X%s,X%s' % (t, t), 'scc eq,%s' % f] + (['ld %s,%s' % (move, f)] if move else []) + \
            ['exts X%s' % m]
    if o.k == 'U':
        if F.size == 2:
            out = ['ld %s,(%s)' % (r, o.sym), 'neg %s' % r]
        else:
            out = ['ld %s,(%s)' % (r, o.sym), 'cpl %s' % f, 'cpl Q%s' % f, 'inc 0x1,%s' % r]
        return out + (['ld %s,%s' % (F.v(move), r)] if move else [])
    if o.k == 'B':
        return ['ld %s,(%s)' % (r, o.a), 'sub %s,(%s)' % (r, o.b)]
    if o.k == 'C':
        return [F.imm(f, o.val), 'sub %s,(%s)' % (r, o.sym)]
    if o.k == 'T':
        l1, l2 = F.label(), F.label()
        return ['cpw (%s),0x0' % o.c, 'j eq,%s' % l1, 'ld %s,(%s)' % (r, o.a), 'j %s' % l2, l1 + ':',
                'ld %s,(%s)' % (r, o.b), l2 + ':']
    if o.k == 'S':
        need(f != 'WA')
        out = ['ld %s,(%s)' % (r, o.sym)] + ([count] if count else [])
        if F.size == 4:
            l0 = F.label()
            out += ['bit 0x4,A', 'j z,%s' % l0, 'sla 0x0,%s' % r, l0 + ':']
        l1 = F.label()
        return out + ['and A,0xf', 'j z,%s' % l1, 'sla A,%s' % r, l1 + ':']
    raise Decline()


def scale(F, o, i):
    """the index register scaled by the element size"""
    if o.esz == 2:
        return 'add %s,%s' % (i, i)
    need(o.esz in (4, 8))
    return 'sla %s,%s' % (hx({4: 2, 8: 3}[o.esz]), i)


def solve(F, acc, src, op):
    """plan and emit `acc op src` (src None: the accumulator alone); returns the result register's family"""
    L, R = F.L, F.R
    order = [o for o in (L, R) if o is not None]
    pre = {id(L): 1, id(R): 2}
    A = Alloc()
    xs = [o for o in order if o.k == 'X']
    ss = [o for o in order if o.k == 'S']
    tpart = any(o.k == 'T' for o in order)
    if len(xs) == 2:
        return solve_xx(F, acc, src, op, A)
    acc_v = acc.k in VAL
    src_v = src is not None and src.k in VAL
    ret = F.ctx == 'RET' and not F.wa                                  # the result planned in HL
    hl_acc = None                                                      # how a returned `!` / `-` accumulator goes to HL

    def use(o):
        return 4 if o is acc else 5

    def ev(o):
        return 4 if o is acc else 3

    # 0. fixed reservations
    shared = len(xs) == 1 and len(ss) == 1 and (F.size == 2 or F.opt or F.xr)   # c read by an index and a count
    holder = None
    if F.xr:
        uses = [pre[id(o)] for o in xs] + [ev(o) for o in ss]
        if uses:
            A.take('WA', 0, max(uses), 'c')
    elif shared:
        A.take('WA', pre[id(xs[0])], ev(ss[0]), 'c')
    for o in ss:
        A.take('WA', ev(o), ev(o) + 0.3, 'count')
    if F.wa:
        if acc.k == 'S':
            if not F.opt:
                A.take('WA', 4.6, 6, 'result')
        else:
            A.take('WA', 4, 6, 'result')
    elif ret:
        A.take('HL', 4, 6, 'result')
        if acc.k in 'NU':
            if F.size == 2 and acc.k == 'N' and F.opt:
                hl_acc = 'direct'
            elif F.opt:
                hl_acc = 'late'
                A.take('WA', 4, 5.5, 'acc')
            else:
                hl_acc = 'move'
                if not (acc.k == 'N' and F.size == 4):
                    A.take('WA', 4, 4.3, 'acc')
    elif acc.k in 'NU':
        A.take('WA', 4, 6, 'acc')
    if len(ss) == 2 and F.xr:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
    if acc.k == 'N' and (F.size == 4 or getattr(acc, 'ltest', False)) and A.free('WA', 4, 4.2):
        A.take('WA', 4, 4.2, 'test')                                   # a long `!` accumulator tests in XWA
    reg = {}
    nat = None
    if src_v and src.k in 'NU':
        if not F.wa and A.free('WA', 3, 5):
            nat = 'keep'
            reg[(id(src), 'val')] = A.take('WA', 3, 5, 'src')
        elif src.k == 'U' and F.opt and A.free('WA', 3, 3.3):          # -O -g: planned as if computed in WA
            nat = 'udirect'                                            # (ed_d_PU O3XS: ld XDE,(_gpi) / ld BC,(_hi) /
            A.take('WA', 3, 3.3, 'natural')                            #  neg BC; ed_d_XU: the index BC, -g in HL)
        elif F.opt or not A.free('WA', 3, 3.3):
            nat = 'direct'
            src.tself = not A.free('WA', 3, 3.3)                       # (a long `!` with WA busy tests in its own
            reg[(id(src), 'val')] = A.pick(3, 5, 'src')                #  register: evorder_l.c el_s_SN -Xr)
        else:
            nat = 'move'
            A.take('WA', 3, 3.3, 'natural')

    for o in order:                                                    # a long `!` tests in XWA
        if o is src and o.k == 'N' and (F.size == 4 or getattr(o, 'ltest', False)) and nat not in ('keep', 'move'):
            if A.free('WA', ev(o), ev(o) + 0.2):
                A.take('WA', ev(o), ev(o) + 0.2, 'test')

    def slots(o):
        p = pre.get(id(o))
        if o.k in 'PD' or (o.k in 'ME' and tpart):
            return [('ptr', p, use(o), ())]
        if o.k == 'X':
            if tpart:
                return [('idx', p, p + 0.3, ()), ('base', p, p + 0.3, ()), ('addr', p + 0.3, use(o), ())]
            return [('idx', p, use(o), ('WA',) if shared else ()), ('base', p, use(o), ())]
        if o.k in VAL:
            if o is src:
                if nat in ('move', 'udirect'):
                    return [('val', 3.3, 5, ())]
                if nat:
                    return []
                return [('val', 3, 5, ('WA',) if o.k == 'S' else ())]
            if F.wa and o.k != 'S':
                return []
            if ret or o.k in 'NU':
                return []
            return [('val', 4, 6, ('WA',) if o.k == 'S' else ())]
        return []

    def assign(o, slot, a, b, avoid):
        if (id(o), slot) not in reg:
            reg[(id(o), slot)] = A.pick(a, b, slot, avoid)

    # 2. the accumulator's own address in WA (result planned in WA)
    if F.wa and acc.k not in VAL:
        for slot, a, b, avoid in slots(acc):
            if slot in ('ptr', 'addr') or (slot == 'idx' and not tpart):
                if 'WA' not in avoid and A.free('WA', a, b):
                    reg[(id(acc), slot)] = A.take('WA', a, b, 'self')
                break
    # 2b. a member through a pointer at a nonzero offset (not beside a T): its pointer before the indexes and the
    #     other operand, in textual order (run 2026-11-10-17 evorder_ad.c ea_i_sub_XD: lda XDE,_gia / ld XBC,(_hps) /
    #     ld WA,(XDE+WA) / sub WA,(XBC+0x2); evorder_l.c el_s_DP: ld XWA,(_gps) / ld XBC,(_hpl))
    if not tpart:
        for o in (L, R):
            if o is not None and o.k == 'D' and o.off != 0:
                for slot, a, b, avoid in slots(o):
                    assign(o, slot, a, b, avoid)
    # 3. indexes (right first)
    for o in (R, L):
        if o is not None and o.k == 'X':
            for slot, a, b, avoid in slots(o):
                if slot in ('idx', 'base'):
                    assign(o, slot, a, b, avoid)
    # 4. the right operand, then the left
    for o in (R, L):
        if o is None:
            continue
        for slot, a, b, avoid in slots(o):
            if (id(o), slot) in reg:
                continue
            if slot == 'addr':
                fi, fb = reg[(id(o), 'idx')], reg[(id(o), 'base')]
                for f in FAMS:
                    if f in (fi, fb) and A.free(f, a, b):
                        reg[(id(o), slot)] = A.take(f, a, b, slot)
                        break
                else:
                    raise Decline()
            else:
                assign(o, slot, a, b, avoid)
    if len(ss) == 2 and not F.xr and F.opt:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
    # 5. the result register
    if F.wa:
        res = reg[(id(acc), 'val')] if acc.k == 'S' else 'WA'
    elif ret:
        res = 'HL'
    elif acc.k in 'NU':
        res = 'WA'
    elif acc_v:
        res = reg[(id(acc), 'val')]
    else:
        res = A.pick(4, 6, 'result')

    # ---- emission
    def cnt():
        if F.xr:
            return ('ld WA,%s' % holder) if holder else None
        if holder:
            return 'ld WA,%s' % holder
        if shared:
            return None
        return 'ld WA,%s' % PARAM

    if holder and not F.xr:
        F.e('ld %s,%s' % (holder, PARAM))
    if holder and F.xr:
        F.e('ld %s,WA' % holder)
    text = {}
    for o in order:
        if o.k in 'PD' or (o.k in 'ME' and tpart):
            p = reg[(id(o), 'ptr')]
            if o.k in 'PD':
                F.e('ld X%s,(%s)' % (p, o.ptr))
                if o.off != 0 and tpart:                               # beside a T: the member's address formed
                    F.e('lda X%s,X%s+%s' % (p, p, hx(o.off)))          # before the branches (el_s_TD)
                    text[id(o)] = '(X%s)' % p
                else:
                    text[id(o)] = '(X%s)' % p if o.off == 0 else '(X%s+%s)' % (p, hx(o.off))
            else:
                if o.zero and not F.opt and p != 'WA':
                    need(A.free('WA', pre[id(o)], pre[id(o)] + 0.1))
                    F.e('lda XWA,%s' % o.addr, 'ld X%s,XWA' % p)
                else:
                    F.e('lda X%s,%s' % (p, o.addr))
                text[id(o)] = '(X%s)' % p
        elif o.k == 'X':
            i, b = reg[(id(o), 'idx')], reg[(id(o), 'base')]
            if F.xr:
                if i != 'WA':
                    F.e('ld %s,WA' % i)
            elif shared:
                F.e('ld WA,%s' % PARAM)
                if i != 'WA':
                    F.e('ld %s,WA' % i)
            else:
                F.e('ld %s,%s' % (i, PARAM))
            F.e(scale(F, o, i), 'lda X%s,%s' % (b, o.arr))
            if tpart:
                a = reg[(id(o), 'addr')]
                if a == i:
                    F.e('exts X%s' % i, 'add X%s,X%s' % (i, b))
                else:
                    F.e('lda X%s,X%s+%s' % (b, b, i))
                text[id(o)] = '(X%s)' % a
            else:
                text[id(o)] = '(X%s+%s)' % (b, i)
    # the source value
    sop = None
    if src is not None:
        if src_v:
            r = reg[(id(src), 'val')]
            if nat == 'move':
                F.e(*value(F, src, 'WA', move=r))
            else:
                F.e(*value(F, src, r, cnt() if src.k == 'S' else None))
            sop = F.v(r)
        elif src.k == 'K':
            sop = hx(src.val)
        elif id(src) in text:
            sop = text[id(src)]
        else:
            sop = src.mem
    # the accumulator
    late = None
    if acc_v:
        if F.wa:
            r = 'WA' if acc.k != 'S' else reg[(id(acc), 'val')]
            F.e(*value(F, acc, r, cnt() if acc.k == 'S' else None))
            if acc.k == 'S' and not F.opt:
                F.e('ld %s,%s' % (F.v('WA'), F.v(r)))
                r = 'WA'
        elif ret:
            r = 'HL'
            if hl_acc == 'direct':
                F.e(*value(F, acc, 'HL'))
            elif hl_acc == 'late':
                F.e(*value(F, acc, 'WA'))
                r, late = 'WA', 'HL'
            elif hl_acc == 'move':
                F.e(*value(F, acc, 'WA'))
                F.e('ld %s,%s' % (F.v('HL'), F.v('WA')))
            else:
                F.e(*value(F, acc, 'HL', cnt() if acc.k == 'S' else None))
        else:
            r = res
            F.e(*value(F, acc, r, cnt() if acc.k == 'S' else None))
    else:
        r = res
        if F.opt and ((F.kind == 'div' and op == '/') or (F.kind == 'mul' and not src_v)) and A.free('HL', 4, 6):
            r = 'HL'                                                   # -O: the operation in XHL when HL is free
        if acc.k == 'K':
            F.e(F.imm(r, acc.val) if F.kind != 'div' else 'ld X%s,%s' % (r, hx(acc.val)))
        elif id(acc) in text:
            F.e('ld %s,%s' % (F.v(r), text[id(acc)]))
        else:
            F.e('ld %s,%s' % (F.v(r), acc.mem))
    if op is not None:
        if F.kind == 'mul':
            F.e('muls X%s,%s' % (r, sop))
        elif F.kind == 'div':
            if acc.k != 'K':
                F.e('exts X%s' % r)
            F.e('divs X%s,%s' % (r, sop))
        elif src.k == 'K' and op in '+-' and 1 <= src.val <= 8:
            F.e('%s %s,%s' % ('inc' if op == '+' else 'dec', hx(src.val), F.v(r)))
        else:
            F.e('%s %s,%s' % (MNEM[op], F.v(r), sop))
    if late:
        F.e('ld %s,%s' % (F.v(late), F.v(r)))
        r = late
    F.regs_used = A
    return r


def solve_xx(F, acc, src, op, A):
    """two elements at c"""
    L, R = F.L, F.R
    use = {id(acc): 4, id(src): 5}
    reg = {}
    ret = F.ctx == 'RET' and not F.wa
    if F.xr:
        A.take('WA', 0, 1 if F.opt else 2, 'c')                        # (-O: one index, c's only reader)
    if F.wa:
        A.take('WA', 4, 6, 'result')
    elif ret:
        A.take('HL', 4, 6, 'result')
    copy = F.size == 2                                                 # cdecl int: c read once into the right index
    if F.opt:                                                          # one index, two bases
        if F.wa:
            reg[(id(acc), 'base')] = A.take('WA', 1 if acc is L else 2, 4, 'self')
        i = A.pick(1, 5, 'idx')
        for o in (R, L):
            if (id(o), 'base') not in reg:
                reg[(id(o), 'base')] = A.pick(1 if o is L else 2, use[id(o)], 'base')
        F.e(*([] if (F.xr and i == 'WA') else ['ld %s,%s' % (i, 'WA' if F.xr else PARAM)]))
        F.e(scale(F, L, i), 'lda X%s,%s' % (reg[(id(L), 'base')], L.arr), 'lda X%s,%s' % (reg[(id(R), 'base')],
                                                                                          R.arr))
        txt = {id(o): '(X%s+%s)' % (reg[(id(o), 'base')], i) for o in (L, R)}
    else:
        if F.wa and not (F.xr and acc is L):
            reg[(id(acc), 'idx')] = A.take('WA', 1 if (acc is L or not (F.xr or not copy)) else 2, 4, 'self')
        for o in (R, L):
            p = 1 if (o is L or not (F.xr or not copy)) else 2
            if (id(o), 'idx') not in reg:
                reg[(id(o), 'idx')] = A.pick(p, use[id(o)], 'idx')
            reg[(id(o), 'base')] = A.pick(1 if o is L else 2, use[id(o)], 'base')
        li, ri = reg[(id(L), 'idx')], reg[(id(R), 'idx')]
        if F.xr:
            if li != 'WA':
                F.e('ld %s,WA' % li)
        elif copy:
            F.e('ld %s,%s' % (ri, PARAM), 'ld %s,%s' % (li, ri))
        else:
            F.e('ld %s,%s' % (li, PARAM))
        F.e(scale(F, L, li), 'lda X%s,%s' % (reg[(id(L), 'base')], L.arr))
        if F.xr and ri != 'WA':
            F.e('ld %s,WA' % ri)
        if not F.xr and not copy:
            F.e('ld %s,%s' % (ri, PARAM))
        F.e(scale(F, R, ri), 'lda X%s,%s' % (reg[(id(R), 'base')], R.arr))
        txt = {id(o): '(X%s+%s)' % (reg[(id(o), 'base')], reg[(id(o), 'idx')]) for o in (L, R)}
    r = 'WA' if F.wa else 'HL' if ret else A.pick(4, 6, 'result')
    if F.wa and F.opt and (F.kind == 'mul' or op == '/') and A.free('HL', 4, 6):   # -O: the operation in XHL
        r = 'HL'
    F.e('ld %s,%s' % (F.v(r), txt[id(acc)]))
    if F.kind == 'mul':
        F.e('muls X%s,%s' % (r, txt[id(src)]))
    elif F.kind == 'div':
        F.e('exts X%s' % r, 'divs X%s,%s' % (r, txt[id(src)]))
    else:
        F.e('%s %s,%s' % (MNEM[op], F.v(r), txt[id(src)]))
    return r


def solve_ss(F, acc, src, op):
    """(g << c) op (h << c): the right shift first; c reloaded (none), kept (-O3 -XS: placed after the shifts;
    -Xr: before them)"""
    A = Alloc()
    holder = None
    if F.ctx == 'RET' and not F.wa:
        A.take('HL', 4, 6, 'result')
    if F.xr:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
        F.e('ld %s,WA' % holder)
    rs = A.pick(3, 5, 'src', avoid=('WA',))
    ra = 'HL' if (F.ctx == 'RET' and not F.wa) else A.pick(4, 6, 'acc', avoid=('WA',))
    if F.opt and not F.xr:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
        F.e('ld %s,%s' % (holder, PARAM))
    cnt = 'ld WA,%s' % (holder or PARAM)
    F.e(*value(F, src, rs, cnt))
    F.e(*value(F, acc, ra, cnt))
    r = ra
    if F.wa and not F.opt:
        F.e('ld %s,%s' % (F.v('WA'), F.v(ra)))
        r = 'WA'
    if F.kind == 'mul':
        F.e('muls X%s,%s' % (r, F.v(rs)))
    elif F.kind == 'div':
        F.e('exts X%s' % r, 'divs X%s,%s' % (r, F.v(rs)))
    else:
        F.e('%s %s,%s' % (MNEM[op], F.v(r), F.v(rs)))
    return r


def rewrite(F):
    """the operator rules: folds, a - -b, the accumulator of a commutative operator -> (acc, src, op) or a folded
    value ('K', v)"""
    L, R, op = F.L, F.R, F.op
    acc, src = L, R
    if L.k == 'K' and R.k == 'K':
        v = {'-': L.val - R.val, '^': L.val ^ R.val, '*': L.val * R.val, '/': L.val // R.val,
             '%': L.val % R.val}[op]
        return 'K', v & (0xffff if F.size == 2 else 0xffffffff)
    if op == '-' and R.k == 'U' and L.k != 'K':                       # a - -b
        g = Op('G', mem='(%s)' % R.sym, addr=R.sym, zero=True, syms=R.syms)
        if L.k == 'U':                                                # -a - -b = b - a
            F.L, F.R = g, Op('G', mem='(%s)' % L.sym, addr=L.sym, zero=True, syms=L.syms)
            acc, src = F.L, F.R
        elif L.k == 'C':                                              # (k - a) - -b = (b - a) + k
            acc = Op('B', a=R.sym, b=L.sym, syms=L.syms + R.syms)
            src = Op('K', val=L.val, syms=[])
            F.L, F.R = acc, None
            op = '+'
        else:
            F.R = src = g
            op = '+'
    elif op == '-' and L.k == 'C' and R.k == 'K':                     # (k - a) - 7 = (k - 7) - a
        acc = Op('C', val=L.val - R.val, sym=L.sym, syms=L.syms)
        F.L, F.R, src, op = acc, None, None, None
    elif op in ('^', '*'):                                            # the accumulator of a commutative operator
        cl, cr = cls(L), cls(R)
        if cr == 'V' and cl != 'V':
            acc, src = R, L
        elif cl == 'V':
            acc, src = L, R
        elif cr == 'K':
            acc, src = L, R
        elif cl == 'K':
            acc, src = R, L
        elif cl == 'A' and cr == 'A':
            acc, src = R, L
    if src is not None and src.k == 'K' and op == '-':
        need(1 <= src.val <= 8)
    return acc, src, op


def body(F):
    r = rewrite(F)
    if r[0] == 'K':
        return 'K', r[1]
    acc, src, op = r
    for o in (F.L, F.R):                                              # p->m at a nonzero offset: seen stored beside
        if o is not None and o.k == 'D' and o.off != 0:               # K G P D E X (evorder_ad.c), passed beside X
            q = (F.R if o is F.L else F.L)                            # (elrd.c er_b_iaAD), returned in long evorder_l
            need(q is None or q.k in F.doff_ok)
    if src is not None and src.k == 'S' and acc.k == 'S':
        res = solve_ss(F, acc, src, op)
    else:
        res = solve(F, acc, src, op)
    b = F.out
    if F.s == 'O3XSXr':                                               # the index's copy of c goes first
        for k, l in enumerate(b):
            if re.match(r'ld (BC|DE|HL),WA$', l) and k > 0 and \
                    not any(re.search(r'\bWA\b|\bA\b', x) for x in b[:k]):
                b.insert(0, b.pop(k))
                break
    return b, res


def fmt(lines):
    out = []
    for l in lines:
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def check_main(whole, ORACLE, PROBE, fam_len=4):
    import frontend
    import listing

    def check(s, show=0, only=None, src=PROBE, rename=None):
        want = listing.split(open(ORACLE % s, encoding='latin-1').read())
        unit = frontend.load(src, [], [], adecl=s.endswith('Xr'))
        ok = wrong = dec = 0
        shown = 0
        fams = {}
        for f in unit.functions:
            if only and not re.search(only, f.name):
                continue
            name = ('.' if s.endswith('Xr') else '_') + f.name
            W = [l for l in want.get(name, []) if 'section' not in l][1:]
            if rename:
                W = [rename(l) for l in W]
            got = whole(f, s)
            fs = fams.setdefault(f.name[:fam_len], [0, 0, 0])
            if got is None:
                dec += 1
                fs[2] += 1
                if shown < show:
                    shown += 1
                    print('---- %s %s declined' % (s, f.name))
                continue
            if listing.normalise_labels(got) == listing.normalise_labels(W):
                ok += 1
                fs[0] += 1
            else:
                wrong += 1
                fs[1] += 1
                if shown < show:
                    shown += 1
                    print('---- %s %s' % (s, f.name))
                    for k in range(max(len(W), len(got))):
                        print('  %-36s | %s' % (W[k].strip() if k < len(W) else '',
                                                got[k].strip() if k < len(got) else ''))
        print('%-7s exact %4d  wrong %4d  declined %4d   %s' % (s, ok, wrong, dec,
              ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
        return ok, wrong, dec

    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        src = a[a.index('--src') + 1] if '--src' in a else PROBE
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, src)


# --------------------------------------------------------------------------------------------- evorder_d.c

DOFF_OK = 'KGPDEX'


def classify(f, xr):
    """int f(int c) { return L op R; }, op / % -> (op, L, R)"""
    need(is_int(f.ret))
    need(len(f.params) == 1 and is_int(f.params[0].ty))
    prm = f.params[0]
    st = cg.flat(f.body)
    need(len(st) == 1 and st[0].k == 'return' and st[0].value is not None)
    x = cg.strip(st[0].value)
    need(x.k == 'bin' and x.op in ("/", "%") and is_int(x.ty))
    L, R = operand(x.l, prm, is_int, 2), operand(x.r, prm, is_int, 2)
    ids = [id(d) for d in L.syms] + [id(d) for d in R.syms]
    need(len(set(ids)) == len(ids))
    return x.op, L, R, 2


def whole_(f, s):
    op, L, R, size = classify(f, s.endswith('Xr'))
    F = Fn(s, 'RET', None, op, L, R, size)
    F.doff_ok = DOFF_OK
    b = body(F)
    if b[0] == 'K':
        return ['ld HL,%s' % hx(b[1]), 'ret']
    lines, r = b
    if op == '%':
        lines.append('ld HL,Q%s' % r)
    elif r != 'HL':
        lines.append('ld HL,%s' % r)
    return lines + ['ret']


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return fmt(whole_(f, set))
    except Decline:
        return None
    except Exception:                                                  # (an AST shape the classifier did not foresee)
        return None


ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/2026-11-10-11-micro-evorder3/out/v423/%s/probes/evorder_d.asm'
PROBE = 'corpus/probes/evorder_d.c'               # --check runs from scripts/analysis/cc900, as score.py does

if __name__ == '__main__':
    check_main(whole, ORACLE, PROBE, 4)
