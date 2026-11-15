#!/usr/bin/env python3
"""evorder_st_ast.py -- the cc900 V4.23 oracle's code for the functions of probe evorder_st.c
(corpus/probes/evorder_st.c, oracle run 2026-11-10-10-micro-evorder2) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 evorder_st_ast.py --check [SET ...] [--show N] [--only REGEX] [--src FILE.c]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path.  --src scores another source (a renamed copy of the probe) against the same
        listing, with the global names mapped back by --map OLD=NEW pairs.

The probe's functions are `void f(int c) { gi3 = L op R; }` (store, es_*) and `void f(int c) { v1(L op R); }`
(argument, ea_*), op one of - ^, L and R one of thirteen int operand kinds (letters as in the probe's names):

    K 7                G gi               M gs.i             P *gpi             E gia[3]           X gia[c]
    D gps->i           N !gi              U -gi              B (gi - gj)        C (256 - gi)       T (gc ? gi : gj)
    S (gi << c)

The function is classified from its AST alone (operand kinds, symbols, offsets, the parameter); the real symbols,
member and element offsets are substituted.  Anything outside the probe's grammar returns None.  The code is
planned by a small register allocator (fixed reservations, then -O direct values, the accumulator's own address,
indexes, the right operand, the left one, and last an argument's result register), each register held over an
interval of the evaluation order: addresses (textual order), the source value, the accumulator, the operator.
The rules are in evorder_st-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
VAL = set('NUBCTS')
FAMS = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY')
MNEM = {'-': 'sub', '^': 'xor', '+': 'add'}
PARAM = '(XSP+0x4)'                       # the parameter's slot (cdecl; no frame in this probe)


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


class Op:
    """k: kind letter; syms: the global decls it reads; per kind: val (K C), mem / addr / zero (G M E: the memory
    operand, the address for lda, offset 0), ptr / off (P D), arr (X), sym (N U S), a / b (B; T arms), c (T)"""

    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s)' % self.k


def gname(d):
    return '_' + d.name


def gint(n):
    """a load of a global int -> decl"""
    n = cg.strip(n)
    need(n.k == 'load' and is_int(n.ty))
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and is_int(v.decl.ty))
    return v.decl


def is_param(n, prm):
    n = cg.strip(n)
    if n.k != 'load' or not is_int(n.ty):
        return False
    v = cg.strip(n.e)
    return v.k == 'var' and v.decl is prm


def gptr(n, struct):
    """a load of a global pointer to int (struct False) or to a struct (True) -> decl"""
    n = cg.strip(n)
    need(n.k == 'load')
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and v.decl.ty is not None and v.decl.ty.kind == 'ptr')
    b = v.decl.ty.base
    need(b is not None and (b.kind == 'struct' if struct else is_int(b)))
    return v.decl


def memop(sym, off):
    a = sym if off == 0 else '%s + %s' % (sym, hx(off))
    return '(%s)' % a, a


def operand(n, prm):
    n = cg.strip(n)
    need(is_int(n.ty))
    if n.k == 'const':
        need(n.value == 7)
        return Op('K', val=7, syms=[])
    if n.k == 'un' and n.op in ('!', '-'):
        d = gint(n.e)
        return Op('N' if n.op == '!' else 'U', sym=gname(d), syms=[d])
    if n.k == 'bin' and n.op == '-':
        l, r = cg.strip(n.l), cg.strip(n.r)
        if l.k == 'const':
            need(l.value == 256 and is_int(l.ty))
            d = gint(r)
            return Op('C', val=256, sym=gname(d), syms=[d])
        a, b = gint(l), gint(r)
        need(a is not b)
        return Op('B', a=gname(a), b=gname(b), syms=[a, b])
    if n.k == 'bin' and n.op == '<<':
        d = gint(n.l)
        need(is_param(n.r, prm))
        return Op('S', sym=gname(d), syms=[d])
    if n.k == 'cond':
        c, a, b = gint(n.c), gint(n.a), gint(n.b)
        need(len({id(c), id(a), id(b)}) == 3)
        return Op('T', c=gname(c), a=gname(a), b=gname(b), syms=[c, a, b])
    need(n.k == 'load')
    x = cg.strip(n.e)
    if x.k == 'var':
        d = x.decl
        need(d.kind == 'global' and is_int(d.ty))
        m, a = memop(gname(d), 0)
        return Op('G', mem=m, addr=a, zero=True, syms=[d])
    if x.k == 'member':
        off = cg.member_offset(x)
        need(off is not None and off >= 0)
        if x.arrow:
            p = gptr(x.base, True)
            return Op('D', ptr=gname(p), off=off, syms=[p])
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'struct')
        m, a = memop(gname(b.decl), off)
        return Op('M', mem=m, addr=a, zero=off == 0, syms=[b.decl])
    if x.k == 'deref':
        p = gptr(x.e, False)
        return Op('P', ptr=gname(p), off=0, syms=[p])
    if x.k == 'index':
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array')
        need(is_int(b.decl.ty.base))
        i = cg.strip(x.idx)
        if i.k == 'const':
            need(i.value is not None and i.value > 0)
            m, a = memop(gname(b.decl), 2 * i.value)
            return Op('E', mem=m, addr=a, zero=False, syms=[b.decl])
        need(is_param(i, prm))
        return Op('X', arr=gname(b.decl), syms=[b.decl])
    raise Decline()


def classify(f, xr):
    """-> (ctx, target, op, L, R): ctx 'ST' (gi3 = L op R; target the stored global) or 'ARG' (v1(L op R); target
    the callee's name)"""
    need(f.ret is not None and f.ret.kind == 'void')
    need(len(f.params) == 1 and is_int(f.params[0].ty))
    prm = f.params[0]
    st = cg.flat(f.body)
    need(len(st) == 1 and st[0].k == 'expr')
    e = cg.strip(st[0].e)
    if e.k == 'bin' and e.op == '=':
        t = cg.strip(e.l)
        need(t.k == 'var' and t.decl.kind == 'global' and is_int(t.decl.ty))
        ctx, tgt, tdecl, x = 'ST', gname(t.decl), t.decl, cg.strip(e.r)
    elif e.k == 'call':
        fn = cg.strip(e.fn)
        need(fn.k == 'var' and fn.decl.kind == 'func' and len(e.args) == 1)
        ft = fn.decl.ty
        need(ft is not None and getattr(ft, 'ret', None) is not None and ft.ret.kind == 'void')
        need(re.match(r'void \(int\)( |$)', getattr(ft, 'spell', '') or '') is not None)
        need(e.ty is not None and e.ty.kind == 'void')
        ctx, tgt, tdecl, x = 'ARG', ('.' if xr else '_') + fn.decl.name, fn.decl, cg.strip(e.args[0])
    else:
        raise Decline()
    need(x.k == 'bin' and x.op in ('-', '^') and is_int(x.ty))
    L, R = operand(x.l, prm), operand(x.r, prm)
    ids = [id(d) for d in L.syms] + [id(d) for d in R.syms]
    need(len(set(ids)) == len(ids))                                   # every object distinct, as in the probe
    need(id(tdecl) not in ids)
    return ctx, tgt, x.op, L, R


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
    def __init__(self, s, ctx, tgt, op, L, R):
        self.s, self.opt, self.xr = s, s.startswith('O3'), s.endswith('Xr')
        self.ctx, self.tgt, self.op, self.L, self.R = ctx, tgt, op, L, R
        self.st = ctx == 'ST' or s == 'O3XSXr'                       # the result wanted in WA (STJ: -O3 -XS -Xr call)
        self.n = 0
        self.out = []

    def label(self):
        self.n += 1
        return 'L%d' % self.n

    def e(self, *ls):
        self.out.extend(ls)


def value(F, o, r, count=None):
    """the code of a value operand into register r (16 bits); count: the instruction putting the shift count in WA"""
    if o.k == 'N':
        return ['cpw (%s),0x0' % o.sym, 'scc eq,%s' % r]
    if o.k == 'U':
        return ['ld %s,(%s)' % (r, o.sym), 'neg %s' % r]
    if o.k == 'B':
        return ['ld %s,(%s)' % (r, o.a), 'sub %s,(%s)' % (r, o.b)]
    if o.k == 'C':
        return ['ld %s,%s' % (r, hx(o.val)), 'sub %s,(%s)' % (r, o.sym)]
    if o.k == 'T':
        l1, l2 = F.label(), F.label()
        return ['cpw (%s),0x0' % o.c, 'j eq,%s' % l1, 'ld %s,(%s)' % (r, o.a), 'j %s' % l2, l1 + ':',
                'ld %s,(%s)' % (r, o.b), l2 + ':']
    if o.k == 'S':
        need(r != 'WA')
        l1 = F.label()
        return ['ld %s,(%s)' % (r, o.sym)] + ([count] if count else []) + \
            ['and A,0xf', 'j z,%s' % l1, 'sla A,%s' % r, l1 + ':']
    raise Decline()


def solve(F, acc, src, op):
    """plan and emit `acc op src` (src None: the accumulator alone); returns the result register"""
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

    def use(o):
        return 4 if o is acc else 5

    def ev(o):
        return 4 if o is acc else 3

    # 0. fixed reservations
    shared = len(xs) == 1 and len(ss) == 1                            # c read by an index and a shift count
    holder = None                                                     # (S S) the register keeping c
    if F.xr:
        uses = [pre[id(o)] for o in xs] + [ev(o) for o in ss]
        if uses:
            A.take('WA', 0, max(uses), 'c')
    elif shared:
        A.take('WA', pre[id(xs[0])], ev(ss[0]), 'c')
    for o in ss:
        A.take('WA', ev(o), ev(o) + 0.3, 'count')
    if F.st:
        if acc.k == 'S':
            if not F.opt:
                A.take('WA', 4.6, 6, 'result')
        else:
            A.take('WA', 4, 6, 'result')
    elif acc.k in 'NU':
        A.take('WA', 4, 6, 'acc')
    if len(ss) == 2:                                                  # S S: where c waits between the two counts
        if F.xr:
            holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
    reg = {}                                                          # (id(op), slot) -> family
    nat = None                                                        # how a ! / unary - source is computed
    if src_v and src.k in 'NU':
        if not F.st and A.free('WA', 3, 5):
            nat = 'keep'
            reg[(id(src), 'val')] = A.take('WA', 3, 5, 'src')
        elif F.opt or not A.free('WA', 3, 3.3):
            nat = 'direct'
            reg[(id(src), 'val')] = A.pick(3, 5, 'src')
        else:
            nat = 'move'
            A.take('WA', 3, 3.3, 'natural')

    def slots(o):
        """the register slots of operand o: (slot, a, b, avoid)"""
        p = pre.get(id(o))
        if o.k in 'PD' or (o.k in 'ME' and tpart):
            return [('ptr', p, use(o), ())]
        if o.k == 'X':
            if tpart:
                return [('idx', p, p + 0.3, ()), ('base', p, p + 0.3, ()), ('addr', p + 0.3, use(o), ())]
            return [('idx', p, use(o), ('WA',) if shared else ()), ('base', p, use(o), ())]
        if o.k in VAL:
            if o is src:
                if nat == 'move':
                    return [('val', 3.3, 5, ())]
                if nat:
                    return []
                return [('val', 3, 5, ('WA',) if o.k == 'S' else ())]
            if F.st and o.k != 'S':
                return []
            if o.k in 'NU':
                return []
            return [('val', 4, 6, ('WA',) if o.k == 'S' else ())]
        return []

    def assign(o, slot, a, b, avoid):
        if (id(o), slot) not in reg:
            reg[(id(o), slot)] = A.pick(a, b, slot, avoid)

    # 2. the accumulator's own address in WA (store)
    if F.st and acc.k not in VAL:
        for slot, a, b, avoid in slots(acc):
            if slot in ('ptr', 'addr') or (slot == 'idx' and not tpart):
                if 'WA' not in avoid and A.free('WA', a, b):
                    reg[(id(acc), slot)] = A.take('WA', a, b, 'self')
                break
    # 2b. a member through a pointer at a nonzero offset beside an element takes its pointer before the indexes
    #     (run 2026-11-10-17 evorder_ad.c ea_i_sub_XD: lda XDE,_gia / ld XBC,(_hps) / ld WA,(XDE+WA) / sub WA,(XBC+0x2))
    if xs:
        for o in (R, L):
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
            if slot == 'addr':                                        # a collapsed element address: its index's or
                fi, fb = reg[(id(o), 'idx')], reg[(id(o), 'base')]   # its base's register
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
    # 5. the result register of an argument
    if F.st:
        res = reg[(id(acc), 'val')] if acc.k == 'S' else 'WA'
    elif acc.k in 'NU':
        res = 'WA'
    elif acc_v:
        res = reg[(id(acc), 'val')]
    else:
        res = A.pick(4, 6, 'result')

    # ---- emission
    cdone = [False]

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
            F.e('add %s,%s' % (i, i), 'lda X%s,%s' % (b, o.arr))
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
            if nat == 'move':
                r = reg[(id(src), 'val')]
                F.e(*value(F, src, 'WA'))
                F.e('ld %s,WA' % r)
            else:
                r = reg[(id(src), 'val')]
                F.e(*value(F, src, r, cnt() if src.k == 'S' else None))
            sop = r
        elif src.k == 'K':
            sop = hx(src.val)
        elif id(src) in text:
            sop = text[id(src)]
        else:
            sop = src.mem
    # the accumulator
    if acc_v:
        r = 'WA' if (acc.k in 'NU' or (F.st and acc.k != 'S')) else reg[(id(acc), 'val')]
        F.e(*value(F, acc, r, cnt() if acc.k == 'S' else None))
        if F.st and acc.k == 'S' and not F.opt:
            F.e('ld WA,%s' % r)
            r = 'WA'
    else:
        r = res
        if acc.k == 'K':
            F.e('ld %s,%s' % (r, hx(acc.val)))
        elif id(acc) in text:
            F.e('ld %s,%s' % (r, text[id(acc)]))
        else:
            F.e('ld %s,%s' % (r, acc.mem))
    if op is not None:
        if src.k == 'K' and op in '+-' and 1 <= src.val <= 8:
            F.e('%s %s,%s' % ('inc' if op == '+' else 'dec', hx(src.val), r))
        else:
            F.e('%s %s,%s' % (MNEM[op], r, sop))
    return r


def solve_xx(F, acc, src, op, A):
    """two elements at c"""
    L, R = F.L, F.R
    use = {id(acc): 4, id(src): 5}
    reg = {}
    if F.xr:
        A.take('WA', 0, 2, 'c')
    if F.st:
        A.take('WA', 4, 6, 'result')
    if F.opt:                                                         # one index, two bases
        if F.st:
            reg[(id(acc), 'base')] = A.take('WA', 1 if acc is L else 2, 4, 'self')
        i = A.pick(1, 5, 'idx')
        for o in (R, L):
            if (id(o), 'base') not in reg:
                reg[(id(o), 'base')] = A.pick(1 if o is L else 2, use[id(o)], 'base')
        F.e(*([] if (F.xr and i == 'WA') else ['ld %s,%s' % (i, 'WA' if F.xr else PARAM)]))
        F.e('add %s,%s' % (i, i), 'lda X%s,%s' % (reg[(id(L), 'base')], L.arr), 'lda X%s,%s' % (reg[(id(R), 'base')],
                                                                                            R.arr))
        txt = {id(o): '(X%s+%s)' % (reg[(id(o), 'base')], i) for o in (L, R)}
    else:
        if F.st and not (F.xr and acc is L):
            reg[(id(acc), 'idx')] = A.take('WA', 1 if (acc is L or not F.xr) else 2, 4, 'self')
        for o in (R, L):
            p = 1 if (o is L or not F.xr) else 2                      # (cdecl: c is read into the right index first)
            if (id(o), 'idx') not in reg:
                reg[(id(o), 'idx')] = A.pick(p, use[id(o)], 'idx')
            reg[(id(o), 'base')] = A.pick(1 if o is L else 2, use[id(o)], 'base')
        li, ri = reg[(id(L), 'idx')], reg[(id(R), 'idx')]
        if F.xr:
            if li != 'WA':
                F.e('ld %s,WA' % li)
        else:
            F.e('ld %s,%s' % (ri, PARAM), 'ld %s,%s' % (li, ri))
        F.e('add %s,%s' % (li, li), 'lda X%s,%s' % (reg[(id(L), 'base')], L.arr))
        if F.xr and ri != 'WA':
            F.e('ld %s,WA' % ri)
        F.e('add %s,%s' % (ri, ri), 'lda X%s,%s' % (reg[(id(R), 'base')], R.arr))
        txt = {id(o): '(X%s+%s)' % (reg[(id(o), 'base')], reg[(id(o), 'idx')]) for o in (L, R)}
    r = 'WA' if F.st else A.pick(4, 6, 'result')
    F.e('ld %s,%s' % (r, txt[id(acc)]), '%s %s,%s' % (MNEM[op], r, txt[id(src)]))
    return r


# --------------------------------------------------------------------------------------------- whole function

def whole_(f, s):
    xr = s.endswith('Xr')
    ctx, tgt, op, L, R = classify(f, xr)
    F = Fn(s, ctx, tgt, op, L, R)
    acc, src = L, R
    if L.k == 'K' and R.k == 'K':                                     # folded
        v = (L.val - R.val if op == '-' else L.val ^ R.val) & 0xffff
        if ctx == 'ST':
            return ['ldw (%s),%s' % (tgt, hx(v)), 'ret']
        if xr:
            return ['ld WA,%s' % hx(v), 'j %s' % tgt]
        return ['pushw %s' % hx(v), 'cal %s' % tgt, 'inc 0x2,XSP', 'ret']
    if op == '-' and R.k == 'U' and L.k != 'K':                       # a - -b
        g = Op('G', mem='(%s)' % R.sym, addr=R.sym, zero=True, syms=R.syms)
        if L.k == 'U':                                                # -a - -b = b - a
            F.L, F.R = Op('G', mem='(%s)' % R.sym, addr=R.sym, zero=True, syms=R.syms), \
                Op('G', mem='(%s)' % L.sym, addr=L.sym, zero=True, syms=L.syms)
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
    elif op == '^':                                                   # the accumulator of a commutative operator
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
    for o in (L, R):                                                  # p->m at a nonzero offset: seen stored beside
        if o.k == 'D' and o.off != 0:                                 # K G P D E X (evorder_ad.c), passed beside X
            q = (R if o is L else L).k                                # (elrd.c er_b_iaAD); declined elsewhere
            need(q == 'X' or (ctx == 'ST' and q in 'KGPDE'))
    if src is not None and src.k == 'K' and op == '-':
        need(1 <= src.val <= 8)
    if src is not None and src.k == 'S' and acc.k == 'S':
        r = solve_ss(F, acc, src, op)
    else:
        r = solve(F, acc, src, op)
    body = F.out
    if s == 'O3XSXr':                                                 # the index's copy of c goes first
        for k, l in enumerate(body):
            if re.match(r'ld (BC|DE|HL),WA$', l) and k > 0 and \
                    not any(re.search(r'\bWA\b|\bA\b', x) for x in body[:k]):
                body.insert(0, body.pop(k))
                break
    if F.ctx == 'ST':
        return body + ['ld (%s),%s' % (tgt, r), 'ret']
    if xr:
        return body + (['ld WA,%s' % r] if r != 'WA' else []) + ['j %s' % tgt]
    return body + ['push %s' % r, 'cal %s' % tgt, 'inc 0x2,XSP', 'ret']


def solve_ss(F, acc, src, op):
    """(gi << c) op (hi << c): the right shift first; c reloaded (none), kept in HL (-O3 -XS) or in BC (-Xr)"""
    A = Alloc()
    holder = None
    if F.xr:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
        F.e('ld %s,WA' % holder)
    rs = A.pick(3, 5, 'src', avoid=('WA',))
    ra = A.pick(4, 6, 'acc', avoid=('WA',))
    if F.opt and not F.xr:
        holder = A.pick(0, 4.3, 'holder', avoid=('WA',))
        F.e('ld %s,%s' % (holder, PARAM))
    cnt = 'ld WA,%s' % (holder or PARAM)
    F.e(*value(F, src, rs, cnt))
    F.e(*value(F, acc, ra, cnt))
    r = ra
    if F.st and not F.opt:
        F.e('ld WA,%s' % ra)
        r = 'WA'
    F.e('%s %s,%s' % (MNEM[op], r, rs))
    return r


def fmt(lines):
    out = []
    for l in lines:
        if l.endswith(':'):
            out.append(l)
        else:
            op, _, args = l.partition(' ')
            out.append('\t%s\t%s' % (op, args) if args else '\t' + op)
    return out


def whole(f, set='none'):
    if set not in SETS:
        return None
    try:
        return fmt(whole_(f, set))
    except Decline:
        return None
    except Exception:                                                  # (an AST shape the classifier did not foresee)
        return None


# --------------------------------------------------------------------------------------------- check

ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-10-10-micro-evorder2/out/v423/%s/probes/evorder_st.asm')
PROBE = 'corpus/probes/evorder_st.c'               # --check runs from scripts/analysis/cc900, as score.py does


def check(s, show=0, only=None, src=PROBE, rename=None):
    import frontend
    import listing
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
        fam = f.name[:4]
        fs = fams.setdefault(fam, [0, 0, 0])
        if got is None:
            dec += 1
            fs[2] += 1
            if shown < show:
                shown += 1
                print('---- %s declined' % f.name)
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
                    print('  %-36s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
    print('%-7s exact %4d  wrong %4d  declined %4d   %s' % (s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        src = a[a.index('--src') + 1] if '--src' in a else PROBE
        rename = None
        if '--map' in a:
            pairs = [p.split('=') for p in a[a.index('--map') + 1].split(',')]
            rx = re.compile(r'\b(%s)\b' % '|'.join(re.escape(o) for o, _ in pairs))
            mp = dict(pairs)
            rename = lambda l: rx.sub(lambda m: mp[m.group(1)], l)  # noqa: E731
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, src, rename)
