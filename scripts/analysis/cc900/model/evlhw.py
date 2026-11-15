#!/usr/bin/env python3
"""evorder_lh_ast.py -- the cc900 V4.23 oracle's code for the functions of probe evorder_lh.c
(corpus/probes/evorder_lh.c, oracle run 2026-11-10-13-micro-evorder4) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 evorder_lh_ast.py --check SET [--show N] [--only REGEX]    score against the oracle listing (exact /
                                                                       wrong / declined); run from
                                                                       scripts/analysis/cc900 with the model
                                                                       directory on sys.path

The probe's functions are `long f(int c) { return L op R; }`, op one of * / %, L and R one of thirteen long
operand kinds (letters as in the probe's names):

    K 7L               G gl              M gs.l             P *gpl            E gla[3]          X gla[c]
    D gps->l           N !gl             U -gl              B (gl - gm)       C (256L - gl)     T (gc ? gl : gm)
    S (gl << c)

The function is classified from its AST alone (operand kinds, symbols, offsets, the parameter); the real symbols,
member offsets and element offsets are substituted.  Anything outside the probe's grammar returns None.
The rules are in evorder_lh-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
VALUE = set('NUBCTS')                     # operands that need code of their own
ADDRD = set('MEPXD')                      # operands read through an address (member, element, pointer)
HELPER = {'*': 'C9H_mulls', '/': 'C9H_divls', '%': 'C9H_remls'}


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


# --------------------------------------------------------------------------------------------- classification

def is_long(ty):
    return ty is not None and ty.kind == 'int' and ty.size == 4 and ty.signed


def is_int(ty):
    return ty is not None and ty.kind == 'int' and ty.size == 2 and ty.signed


class Op:
    """k: kind letter; syms: the global decls the operand reads (for the distinctness check); plus per kind
    sym (G N U S: the long global), m (M E: memory operand text without parentheses), ptr / off (P D),
    arr (X), a / b (B: a - b; T: c ? a : b), c (T: the int global tested)"""

    def __init__(self, k, **kw):
        self.k = k
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s)' % self.k


def gname(d):
    return '_' + d.name


def gvar(n, test):
    """n is a load of a global variable whose type passes test -> decl"""
    n = cg.strip(n)
    need(n.k == 'load' and test(n.ty))
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and test(v.decl.ty))
    return v.decl


def glong(n):
    return gvar(n, is_long)


def gptr(n, struct):
    """a load of a global pointer: to long (struct False) or to a struct (True) -> decl"""
    n = cg.strip(n)
    need(n.k == 'load')
    v = cg.strip(n.e)
    need(v.k == 'var' and v.decl.kind == 'global' and v.decl.ty is not None and v.decl.ty.kind == 'ptr')
    b = v.decl.ty.base
    need(b is not None and (b.kind == 'struct' if struct else is_long(b)))
    return v.decl


def operand(n, prm):
    """classify one long operand node -> Op"""
    n0 = n
    n = cg.strip(n)
    if n.k == 'cast':                                                  # !gl: (long)(int)
        need(n.kind == 'IntegralCast' and not n.explicit and is_long(n.ty))
        u = cg.strip(n.e)
        need(u.k == 'un' and u.op == '!' and is_int(u.ty))
        d = glong(u.e)
        return Op('N', sym=gname(d), syms=[d])
    need(is_long(n.ty))
    if n.k == 'const':
        need(n.value == 7)
        return Op('K', val=7, syms=[])
    if n.k == 'un' and n.op == '-':
        d = glong(n.e)
        return Op('U', sym=gname(d), syms=[d])
    if n.k == 'bin' and n.op == '-':
        l, r = cg.strip(n.l), cg.strip(n.r)
        if l.k == 'const':
            need(l.value == 256 and is_long(l.ty))
            d = glong(r)
            return Op('C', val=256, sym=gname(d), syms=[d])
        a, b = glong(l), glong(r)
        need(a is not b)
        return Op('B', a=gname(a), b=gname(b), syms=[a, b])
    if n.k == 'bin' and n.op == '<<':
        d = glong(n.l)
        r = cg.strip(n.r)
        need(r.k == 'load' and is_int(r.ty))
        v = cg.strip(r.e)
        need(v.k == 'var' and v.decl is prm)
        return Op('S', sym=gname(d), syms=[d])
    if n.k == 'cond':
        c = gvar(n.c, is_int)
        a, b = glong(n.a), glong(n.b)
        need(len({id(c), id(a), id(b)}) == 3)
        return Op('T', c=gname(c), a=gname(a), b=gname(b), syms=[c, a, b])
    need(n.k == 'load')
    x = cg.strip(n.e)
    if x.k == 'var':
        d = x.decl
        need(d.kind == 'global' and is_long(d.ty))
        return Op('G', sym=gname(d), syms=[d])
    if x.k == 'member':
        off = cg.member_offset(x)
        need(off > 0)
        if x.arrow:
            p = gptr(x.base, True)
            return Op('D', ptr=gname(p), off=off, syms=[p])
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'struct')
        return Op('M', m='%s + %s' % (gname(b.decl), hx(off)), syms=[b.decl])
    if x.k == 'deref':
        p = gptr(x.e, False)
        return Op('P', ptr=gname(p), syms=[p])
    if x.k == 'index':
        b = cg.strip(x.base)
        if b.k == 'decay':
            b = cg.strip(b.e)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array')
        i = cg.strip(x.idx)
        if i.k == 'const':
            need(i.value is not None and i.value > 0)
            return Op('E', m='%s + %s' % (gname(b.decl), hx(4 * i.value)), syms=[b.decl])
        need(i.k == 'load' and is_int(i.ty))
        v = cg.strip(i.e)
        need(v.k == 'var' and v.decl is prm)
        return Op('X', arr=gname(b.decl), syms=[b.decl])
    raise Decline()


def classify(f):
    """-> (op, L, R)"""
    need(is_long(f.ret))
    need(len(f.params) == 1 and is_int(f.params[0].ty))
    prm = f.params[0]
    st = cg.flat(f.body)
    need(len(st) == 1 and st[0].k == 'return' and st[0].value is not None)
    e = cg.strip(st[0].value)
    if e.k == 'cast':                                                  # !gl op !hl is an int operation, widened
        need(e.kind == 'IntegralCast' and not e.explicit and is_long(e.ty))
        b = cg.strip(e.e)
        need(b.k == 'bin' and b.op in HELPER and is_int(b.ty))
        ops = []
        for x in (b.l, b.r):
            x = cg.strip(x)
            need(x.k == 'un' and x.op == '!' and is_int(x.ty))
            d = glong(x.e)
            ops.append(Op('N', sym=gname(d), syms=[d]))
        need(ops[0].syms[0] is not ops[1].syms[0])
        return b.op, ops[0], ops[1]
    need(e.k == 'bin' and e.op in HELPER and is_long(e.ty))
    L, R = operand(e.l, prm), operand(e.r, prm)
    need(not (L.k == 'N' and R.k == 'N'))
    ids = [id(d) for d in L.syms] + [id(d) for d in R.syms]
    need(len(set(ids)) == len(ids))                                    # every object distinct, as in the probe
    return e.op, L, R


# --------------------------------------------------------------------------------------------- frame

class Frame:
    def __init__(self, s):
        self.s = s
        self.xr = s.endswith('Xr')
        self.opt = s.startswith('O3')
        self.n = 0

    def label(self):
        self.n += 1
        return 'L%d' % self.n

    def param(self, fb):
        """the parameter's stack slot with fb bytes of frame below the return address (cdecl)"""
        return '(XSP+%s)' % hx(4 + fb)

    def imm(self, r, v):
        return '%s %s,%s' % ('lda' if self.opt and 8 <= v < 0x10000 else 'ld', r, hx(v))


def add_off(reg, tmp, off):
    """X<reg> = X<tmp> + off: `lda`, or `inc off,Xr` when the register is its own source and 1 <= off <= 8
    (run 2026-11-13-2-micro-lhx lxo_l_x_RDX Xr: gps->l at offset 2, `ld XBC,(_gps) / inc 0x2,XBC`)"""
    if reg == tmp and 1 <= off <= 8:
        return 'inc %s,X%s' % (hx(off), reg)
    return 'lda X%s,X%s+%s' % (reg, tmp, hx(off))


def mem(o):
    """the memory operand of a plain G / M / E"""
    return '(%s)' % (o.sym if o.k == 'G' else o.m)


# --------------------------------------------------------------------------------------------- values

def val_N(F, o, r, test='WA', wide=True):
    out = ['ld X%s,(%s)' % (test, o.sym), 'or X%s,X%s' % (test, test), 'scc eq,%s' % r]
    return out + (['exts X%s' % r] if wide else [])


def val_U(F, o, r, via=False):
    if via:
        return ['ld XWA,(%s)' % o.sym, 'cpl WA', 'cpl QWA', 'inc 0x1,XWA', 'ld X%s,XWA' % r]
    return ['ld X%s,(%s)' % (r, o.sym), 'cpl %s' % r, 'cpl Q%s' % r, 'inc 0x1,X%s' % r]


def val_B(F, o, r):
    return ['ld X%s,(%s)' % (r, o.a), 'sub X%s,(%s)' % (r, o.b)]


def val_C(F, o, r):
    return [F.imm('X' + r, o.val), 'sub X%s,(%s)' % (r, o.sym)]


def val_T(F, o, r):
    l1, l2 = F.label(), F.label()
    return ['cpw (%s),0x0' % o.c, 'j eq,%s' % l1, 'ld X%s,(%s)' % (r, o.a), 'j %s' % l2, l1 + ':',
            'ld X%s,(%s)' % (r, o.b), l2 + ':']


def val_S(F, o, r, count):
    """count: the instruction putting the shift count into WA, or None when it is there"""
    l1, l2 = F.label(), F.label()
    return ['ld X%s,(%s)' % (r, o.sym)] + ([count] if count else []) + \
        ['bit 0x4,A', 'j z,%s' % l1, 'sla 0x0,X%s' % r, l1 + ':', 'and A,0xf', 'j z,%s' % l2, 'sla A,X%s' % r,
         l2 + ':']


# --------------------------------------------------------------------------------------------- the two arguments

def general(F, A, B, a_first):
    """no X operand: A's value to XWA, B's to XBC.  a_first: A is the textually first operand"""
    if A.k == 'D' and B.k == 'D':
        return dd(F, A, B, a_first)
    if A.k == 'T' and B.k == 'N':
        return tn(F, A, B)
    if A.k == 'S' and B.k == 'S':
        return ss(F, A, B)
    push = False                       # push XIZ
    addr = {}                          # id(op) -> (register of the address / base, lines that compute it)
    for o, t, q in ((A, 'WA', B), (B, 'BC', A)):
        if o.k in 'ME':
            reg = None
            if q.k == 'N' or q.k == 'S' and F.s == 'O3XS':
                reg = 'BC' if t == 'BC' else 'DE'
            elif q.k == 'T':
                reg = 'IZ'
            if reg:
                addr[id(o)] = (reg, ['lda X%s,%s' % (reg, o.m)], '(X%s)' % reg)
        elif o.k == 'P':
            reg = t
            if q.k == 'T':
                reg = 'IZ'
            elif t == 'WA' and q.k in 'NUS':
                reg = 'DE'
            addr[id(o)] = (reg, ['ld X%s,(%s)' % (reg, o.ptr)], '(X%s)' % reg)
        elif o.k == 'D':
            if q.k in 'NT' or q.k == 'S' and F.s == 'O3XS':
                reg = 'BC' if t == 'BC' else ('WA' if q.k == 'T' else 'DE')
                tmp = reg if q.k == 'T' else 'WA'
                addr[id(o)] = (reg, ['ld X%s,(%s)' % (tmp, o.ptr), add_off(reg, tmp, o.off)],
                               '(X%s)' % reg)
            else:
                addr[id(o)] = ('IZ', ['ld XIZ,(%s)' % o.ptr], '(XIZ+%s)' % hx(o.off))
    push = any(v[0] == 'IZ' for v in addr.values())
    fb = 4 if push else 0
    out = ['push XIZ'] if push else []
    for o in ((A, B) if a_first else (B, A)):                         # 1. addresses, in textual order
        if id(o) in addr:
            out += addr[id(o)][1]
    bc_busy = B.k in VALUE or (id(B) in addr and addr[id(B)][0] == 'BC')
    if B.k in VALUE:                                                   # 2. the right value, then the left one
        wa_busy = F.xr and A.k == 'S'
        out += value(F, B, 'BC', wa_busy, fb)
    if A.k in VALUE:
        out += value(F, A, 'WA', False, fb, bc_busy)
    loads = []                                                         # 3. the loads: plain globals first (no -O),
    for o, t in ((A, 'WA'), (B, 'BC')):                                #    then XWA's, then XBC's
        if o.k in VALUE:
            continue
        if o.k == 'K':
            loads.append((o, F.imm('X' + t, o.val)))
        elif id(o) in addr:
            loads.append((o, 'ld X%s,%s' % (t, addr[id(o)][2])))
        else:
            loads.append((o, 'ld X%s,%s' % (t, mem(o))))
    if not F.opt:
        loads.sort(key=lambda x: 0 if x[0].k == 'G' else 1)
    out += [l for _, l in loads]
    return out, (['pop XIZ'] if push else [])


def value(F, o, t, wa_busy, fb, bc_busy=False):
    """the code of a value operand into X<t>"""
    cnt = None if F.xr else 'ld WA,%s' % F.param(fb)
    if o.k == 'N':
        return val_N(F, o, t, test='BC' if wa_busy and t == 'BC' else 'WA')
    if o.k == 'U':
        return val_U(F, o, t, via=(t != 'WA' and not F.opt and not wa_busy))
    if o.k == 'B':
        return val_B(F, o, t)
    if o.k == 'C':
        return val_C(F, o, t)
    if o.k == 'T':
        return val_T(F, o, t)
    if o.k == 'S':
        if t == 'BC':
            return val_S(F, o, 'BC', cnt)
        r = 'DE' if bc_busy else 'BC'
        return val_S(F, o, r, cnt) + ['ld XWA,X%s' % r]
    raise Decline()


def dd(F, A, B, a_first):
    """two members through pointers: the first pointer in a frame slot, the second in XIZ"""
    f, s = (A, B) if a_first else (B, A)
    tf = 'WA' if f is A else 'BC'
    out = ['dec 0x4,XSP', 'push XIZ', 'ld XWA,(%s)' % f.ptr, 'ld (XSP+0x4),XWA', 'ld XIZ,(%s)' % s.ptr,
           'ld X%s,(XSP+0x4)' % tf]
    out += ['ld XWA,(%s+%s)' % ('XWA' if f is A else 'XIZ', hx(A.off)),
            'ld XBC,(%s+%s)' % ('XBC' if f is B else 'XIZ', hx(B.off))]
    return out, ['pop XIZ', 'inc 0x4,XSP']


def tn(F, A, B):
    """(gc ? gl : gm) op !hl: the ! value waits in XIZ across the conditional"""
    out = ['push XIZ'] + val_N(F, B, 'WA', wide=False) + ['ld IZ,WA', 'exts XIZ'] + val_T(F, A, 'WA') + \
        ['ld XBC,XIZ']
    return out, ['pop XIZ']


def ss(F, A, B):
    """(gl << c) op (hl << c): both shifts, the count kept where the set keeps it"""
    if F.xr:
        out = ['ld BC,WA'] + val_S(F, B, 'DE', 'ld WA,BC') + val_S(F, A, 'HL', 'ld WA,BC') + \
            ['ld XWA,XHL', 'ld XBC,XDE']
    elif F.opt:
        out = ['ld HL,%s' % F.param(0)] + val_S(F, B, 'BC', 'ld WA,HL') + val_S(F, A, 'DE', 'ld WA,HL') + \
            ['ld XWA,XDE']
    else:
        out = val_S(F, B, 'BC', 'ld WA,%s' % F.param(0)) + val_S(F, A, 'DE', 'ld WA,%s' % F.param(0)) + \
            ['ld XWA,XDE']
    return out, []


# --------------------------------------------------------------------------------------------- element operands

def slot_prologue(F, arr, fb, slot='(XSP+0x4)', base_xiz=True):
    out = [] if F.xr else ['ld WA,%s' % F.param(fb)]
    out += ['ld %s,WA' % slot, 'ld WA,%s' % slot, 'sla 0x2,WA', 'ld %s,WA' % slot]
    if base_xiz:
        out += ['lda XIZ,%s' % arr]
    return out


def elem_addr(F, arr, reg, fb):
    return ([] if F.xr else ['ld WA,%s' % F.param(fb)]) + ['sla 0x2,WA', 'lda XBC,%s' % arr,
                                                           'lda X%s,XBC+WA' % reg]


def with_x(F, A, B, a_first):
    """one or two element-at-c operands"""
    if A.k == 'X' and B.k == 'X':
        return xx(F, A, B, a_first)
    X, Q = (A, B) if A.k == 'X' else (B, A)
    tx, tq = ('WA', 'BC') if X is A else ('BC', 'WA')
    x_first = (X is A) == a_first
    if Q.k == 'N':                                                     # the element's address, then the value
        reg = 'BC' if tx == 'BC' else 'DE'
        out = elem_addr(F, X.arr, reg, 0) + value(F, Q, tq, False, 0) + ['ld X%s,(X%s)' % (tx, reg)]
        return out, []
    if Q.k == 'T':
        out = ['push XIZ'] + elem_addr(F, X.arr, 'IZ', 4) + value(F, Q, tq, False, 4) + ['ld X%s,(XIZ)' % tx]
        return out, ['pop XIZ']
    if Q.k in 'UBCS':                                                  # the scaled index in IZ, the base in a slot
        q = 'BC' if F.xr and Q.k == 'S' else 'WA'
        out = ['dec 0x4,XSP', 'push IZ']
        cnt = None
        if F.xr:
            out += ['ld IZ,WA']
        elif F.opt and Q.k == 'S':
            out += ['ld DE,%s' % F.param(6), 'ld IZ,DE']
            cnt = 'ld WA,DE'
        else:
            out += ['ld IZ,%s' % F.param(6)]
            cnt = 'ld WA,%s' % F.param(6)
        out += ['sla 0x2,IZ', 'lda X%s,%s' % (q, X.arr), 'ld (XSP+0x2),X%s' % q]
        if Q.k == 'S':
            out += val_S(F, Q, 'BC', cnt) + (['ld XWA,XBC'] if tq == 'WA' else [])
        else:
            out += value(F, Q, tq, False, 6)
        out += ['ld X%s,(XSP+0x2)' % tx, 'ld X%s,(X%s+IZ)' % (tx, tx)]
        return out, ['pop IZ', 'inc 0x4,XSP']
    if Q.k == 'D' and x_first:
        return xd(F, X, Q, tx)
    need(Q.k in 'KGMEPD')
    out = ['dec 0x2,XSP', 'push XIZ']
    qload = None
    if not x_first:                                                    # an address before the element's index
        reg = 'BC' if tq == 'BC' else 'DE'
        if Q.k in 'ME':
            out += ['lda X%s,%s' % (reg, Q.m)]
            qload = 'ld X%s,(X%s)' % (tq, reg)
        elif Q.k == 'P':
            out += ['ld X%s,(%s)' % (reg, Q.ptr)]
            qload = 'ld X%s,(X%s)' % (tq, reg)
        elif Q.k == 'D':
            tmp = 'BC' if F.xr else 'WA'
            out += ['ld X%s,(%s)' % (tmp, Q.ptr), add_off(reg, tmp, Q.off)]
            qload = 'ld X%s,(X%s)' % (tq, reg)
    out += slot_prologue(F, X.arr, 6)
    if qload is None:
        if Q.k == 'P':                                                 # an address after it
            out += ['ld X%s,(%s)' % (tq, Q.ptr)]
            qload = 'ld X%s,(X%s)' % (tq, tq)
        elif Q.k == 'K':
            qload = F.imm('X' + tq, Q.val)
        else:
            qload = 'ld X%s,%s' % (tq, mem(Q))
    xi = tx                                                            # the index register: the target's own
    xpre, xload = 'ld %s,(XSP+0x4)' % xi, 'ld X%s,(XIZ+%s)' % (tx, xi)
    if X is A:
        seq = [xpre, xload, qload]
        if Q.k == 'G' and not F.opt:
            seq = [qload, xpre, xload]
    else:
        seq = [xpre, qload, xload]
        if Q.k == 'G' and not F.opt:
            seq = [qload, xpre, xload]
    return out + seq, ['pop XIZ', 'inc 0x2,XSP']


def xd(F, X, D, tx):
    """an element at c, then a member through a pointer: index and base in frame slots, the pointer in XIZ"""
    out = ['dec 0x6,XSP', 'push XIZ'] + slot_prologue(F, X.arr, 10, '(XSP+0x8)', base_xiz=False)
    out += ['lda XWA,%s' % X.arr, 'ld (XSP+0x4),XWA', 'ld XIZ,(%s)' % D.ptr, 'ld X%s,(XSP+0x4)' % tx,
            'ld DE,(XSP+0x8)']
    xl = 'ld X%s,(X%s+DE)' % (tx, tx)
    dl = 'ld X%s,(XIZ+%s)' % ('BC' if tx == 'WA' else 'WA', hx(D.off))
    out += [xl, dl] if tx == 'WA' else [dl, xl]
    return out, ['pop XIZ', 'inc 0x6,XSP']


def xx(F, A, B, a_first):
    """two elements at c"""
    f, s = (A, B) if a_first else (B, A)
    tf, ts = ('WA', 'BC') if f is A else ('BC', 'WA')
    if F.opt and a_first:                                              # -O, one shared index slot
        out = ['dec 0x6,XSP', 'push XIZ'] + slot_prologue(F, f.arr, 10, '(XSP+0x8)', base_xiz=False)
        out += ['lda XWA,%s' % f.arr, 'ld (XSP+0x4),XWA', 'lda XIZ,%s' % s.arr, 'ld XWA,(XSP+0x4)',
                'ld HL,(XSP+0x8)', 'ld XWA,(XWA+HL)', 'ld XBC,(XIZ+HL)']
        return out, ['pop XIZ', 'inc 0x6,XSP']
    out = ['dec 0x2,XSP', 'push XIZ']
    if F.opt:                                                          # -O, the multiply's swap (m_XX)
        out += slot_prologue(F, None, 6, base_xiz=False)
        out += ['lda XBC,%s' % f.arr, 'ld WA,(XSP+0x4)', 'lda XBC,XBC+WA', 'lda XIZ,%s' % s.arr,
                'ld XWA,(XIZ+WA)', 'ld XBC,(XBC)']
        return out, ['pop XIZ', 'inc 0x2,XSP']
    reg = 'DE' if tf == 'WA' else 'BC'                                 # the first element's address first
    if F.xr:
        if tf == 'WA':
            out += ['ld BC,WA', 'sla 0x2,BC', 'lda XDE,%s' % f.arr, 'lda XDE,XDE+BC']
        else:
            out += ['ld BC,WA', 'sla 0x2,BC', 'lda XDE,%s' % f.arr, 'exts XBC', 'add XBC,XDE']
    else:
        out += ['ld WA,%s' % F.param(6), 'sla 0x2,WA', 'lda XBC,%s' % f.arr, 'lda X%s,XBC+WA' % reg]
    out += slot_prologue(F, s.arr, 6)
    if tf == 'WA':
        out += ['ld BC,(XSP+0x4)', 'ld XWA,(XDE)', 'ld XBC,(XIZ+BC)']
    else:
        out += ['ld WA,(XSP+0x4)', 'ld XWA,(XIZ+WA)', 'ld XBC,(XBC)']
    return out, ['pop XIZ', 'inc 0x2,XSP']


# --------------------------------------------------------------------------------------------- whole function

def alone(F, o):
    """one operand into XWA (XBC for a shift) for the inline multiply by 7 -> (lines, register)"""
    if o.k in 'GME':
        return ['ld XWA,%s' % mem(o)], 'WA'
    if o.k == 'P':
        return ['ld XWA,(%s)' % o.ptr, 'ld XWA,(XWA)'], 'WA'
    if o.k == 'D':
        return ['ld XWA,(%s)' % o.ptr, 'ld XWA,(XWA+%s)' % hx(o.off)], 'WA'
    if o.k == 'X':
        return ([] if F.xr else ['ld WA,%s' % F.param(0)]) + ['sla 0x2,WA', 'lda XBC,%s' % o.arr,
                                                               'ld XWA,(XBC+WA)'], 'WA'
    if o.k == 'S':
        return val_S(F, o, 'BC', None if F.xr else 'ld WA,%s' % F.param(0)), 'BC'
    return value(F, o, 'WA', False, 0), 'WA'


def nn(F, op, A, B):
    """!gl op !hl: an int operation, widened"""
    out = val_N(F, B, 'WA' if not F.opt else 'BC', wide=False) + ([] if F.opt else ['ld BC,WA'])
    if op == '*':
        out += val_N(F, A, 'HL' if F.opt else 'WA', wide=False) + ([] if F.opt else ['ld HL,WA']) + \
            ['muls XHL,BC']
        return out
    out += val_N(F, A, 'WA') + ['divs XWA,BC', 'ld HL,%s' % ('WA' if op == '/' else 'QWA'), 'exts XHL']
    return out


def whole_(f, s):
    F = Frame(s)
    op, L, R = classify(f)
    if L.k == 'K' and R.k == 'K':
        v = {'*': 49, '/': 1, '%': 0}[op]
        return [F.imm('XHL', v), 'ret']
    if op == '*' and 'K' in (L.k, R.k):                                # x * 7 = (x << 3) - x
        lines, r = alone(F, R if L.k == 'K' else L)
        return lines + ['ld XHL,X%s' % r, 'sla 0x3,XHL', 'sub XHL,X%s' % r, 'ret']
    if L.k == 'N' and R.k == 'N':
        return nn(F, op, L, R) + ['ret']
    A, B, a_first = L, R, True
    if op == '*' and ((R.k in VALUE and L.k not in VALUE) or (L.k in ADDRD and R.k in ADDRD)):
        A, B, a_first = R, L, False                                   # the multiply's swap
    if 'X' in (A.k, B.k):
        body, tail = with_x(F, A, B, a_first)
    else:
        body, tail = general(F, A, B, a_first)
    return body + ['cal %s' % HELPER[op]] + tail + ['ret']


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

ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-10-13-micro-evorder4/out/v423/%s/probes/evorder_lh.asm')
PROBE = 'corpus/probes/evorder_lh.c'               # --check runs from scripts/analysis/cc900, as score.py does


def check(s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(PROBE, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
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
                print('---- %s' % f.name)
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
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only)
