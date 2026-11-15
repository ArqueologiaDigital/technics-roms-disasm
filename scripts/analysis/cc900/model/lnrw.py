#!/usr/bin/env python3
"""lnr_ast.py -- the cc900 V4.23 oracle's code for the leaf functions of probes lnr.c, lnr2.c, lnr3.c and lnr4.c
(corpus/probes/, oracle runs 2026-11-09-31..34), from the model's AST.  Stage 1: the option set none (cdecl).

    whole(f, set) -> [listing lines after the function label] or None
    python3 lnr_ast.py --check [SET ...] [--probe P] [--show N] [--only REGEX]    (from scripts/analysis/cc900,
                                                                                    model directory on sys.path)

The variables' registers are rule LN1 (model/leafnone.py, from research-scratch sessions/2026-11-09_cc900-leaf-none);
the code is emitted from statement templates whose temporaries are the registers of LN1's reservation table.  A
function outside the probes' grammar, or whose temporaries would meet a live variable in a way the templates do not
cover, returns None.  Rules: lnr-FAMILIES.md beside this file.
"""
HOME_ = __import__('os').path.expanduser('~/')
import re
import sys

import codegen as cg  # noqa: E402
import leafnone  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
FAMS16 = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % (v & 0xffffffff)


def strip(e):
    return cg.strip(e)


def unc(e):
    e = strip(e)
    while e.k == 'cast' and e.kind in ('IntegralCast', 'NoOp'):
        e = strip(e.e)
    return e


def is_int(t):
    return t is not None and t.kind == 'int' and t.size == 2


def vdecl(e):
    e = unc(e)
    if e.k == 'load' and strip(e.e).k == 'var':
        return strip(e.e).decl
    return None


# --------------------------------------------------------------------------------------------- the function

class Fn:
    def __init__(self, f, s):
        self.f, self.s = f, s
        self.out = []
        self.n = 0
        self.home = {}                         # decl -> family ('HL', 'QWA') for 16-bit, 'X..' for 32-bit
        self.push = 0

    def label(self):
        self.n += 1
        return 'L%d' % self.n

    def e(self, *ls):
        self.out.extend(ls)

    def reg(self, d):
        """the register of variable d, sized; None when it lives in memory"""
        h = self.home.get(d)
        if h is None:
            return None
        if getattr(self, 'xr', False):
            return xr_tok(h, d.ty.size)
        if d.ty.size == 4:
            need(not h.startswith('Q'))
            return 'X' + h
        if d.ty.size == 1:
            need(h in ('WA', 'BC', 'DE', 'HL'))
            return h[1]
        return h

    def slot(self, d):
        """cdecl: the parameters from (XSP+4) up, an int or char taking 2 bytes, a pointer or long 4"""
        need(d.kind == 'param')
        off = 4
        for q in self.f.params:
            if q is d:
                return '(XSP+%s)' % hx(off + self.push)
            need(q.ty.size in (1, 2, 4))
            off += 4 if q.ty.size == 4 else 2
        raise Decline()

    def where(self, d):
        """a variable as an operand: its register or its memory"""
        r = self.reg(d)
        if r is not None:
            return r
        if d.kind == 'param':
            return self.slot(d)
        need(d.kind == 'global')
        return '(_%s)' % d.name

    def live_homes(self):
        """the families a variable holds in its low word (a Q home leaves the low word free)"""
        return set(h for h in self.home.values() if not h.startswith('Q'))

    def live_x(self):
        """the families a variable holds in either word (a 32-bit temporary must avoid them)"""
        return set(h.lstrip('Q') for h in self.home.values())


def lrefs(f, d):
    """references of d, a loop condition counting twice (it is tested at the guard and at the bottom)"""
    n = [0]

    def cnt(x, w):
        def v(m, dd):
            if m.k == 'load' and strip(m.e).k == 'var' and strip(m.e).decl is d:
                n[0] += w
        cg.walk(x, v)

    def st(s):
        if s is None:
            return
        if s.k == 'block':
            for c in s.body:
                st(c)
        elif s.k == 'for':
            st_init(s.init)
            cnt(s.cond, 2)
            st_e(s.inc)
            st(s.body)
        elif s.k in ('while', 'do'):
            cnt(s.cond, 2)
            st(s.body)
        elif s.k == 'if':
            cnt(s.cond, 1)
            st(s.then)
            st(getattr(s, 'els', None))
        elif s.k == 'expr':
            cnt(s.e, 1)
        elif s.k == 'return':
            if s.value is not None:
                cnt(s.value, 1)
        elif s.k == 'decl':
            if getattr(s, 'init', None) is not None:
                cnt(s.init, 1)
        else:
            raise Decline()

    def st_init(x):
        if x is None:
            return
        if getattr(x, 'k', None) in ('expr', 'decl', 'block'):
            st(x)
        else:
            cnt(x, 1)

    def st_e(x):
        if x is not None:
            cnt(x, 1)
    st(f.body)
    return n[0]


def modified(f, d):
    m = []

    def v(n, dd):
        if n.k == 'incdec' and strip(n.e).k == 'var' and strip(n.e).decl is d:
            m.append(n)
        if n.k in ('opassign',) and strip(n.l).k == 'var' and strip(n.l).decl is d:
            m.append(n)
        if n.k == 'bin' and n.op == '=' and strip(n.l).k == 'var' and strip(n.l).decl is d:
            m.append(n)
    cg.walk(f.body, v)
    return bool(m)


def homes(F):
    f = F.f
    vs = leafnone.variables(f)
    inreg = set()
    for d in vs:
        if d.kind == 'local':
            inreg.add(d)
        else:
            k = lrefs(f, d)
            if modified(f, d):
                need(not d.ty.is_ptr())
                if k >= 2:
                    inreg.add(d)
            elif k >= 3:
                inreg.add(d)
    got = leafnone.allocate(f, inreg)
    for d in inreg:
        r = got.get(d, '-')
        need(r != '-')
        F.home[d] = r


# --------------------------------------------------------------------------------------------- statements

ARITH = {'+': 'add', '-': 'sub', '^': 'xor', '&': 'and', '|': 'or'}


class Elem:
    """an element access: kind 'sized' (global array), 'unsized' (global int x[]), 'ptr' (pointer variable or global
    pointer); base decl; idx: (decl, add) with add the constant added to the index variable; esz"""

    def __init__(self, n):
        n = strip(n)
        need(n.k == 'index')
        b = strip(n.base)
        if b.k == 'decay':
            b = strip(b.e)
        self.esz = n.ty.size
        need(self.esz in (1, 2, 4))
        if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty.kind == 'array':
            self.kind = 'sized' if (b.decl.ty.count or 0) > 0 else 'unsized'
            self.base = b.decl
        else:
            d = vdecl(b)
            need(d is not None and d.ty.kind == 'ptr')
            self.kind = 'ptr'
            self.base = d
        i = unc(n.idx)
        self.cidx = None
        if i.k == 'const':
            need(self.kind == 'ptr')
            self.cidx, self.add, self.idx = i.value, 0, None
            return
        if i.k == 'bin' and i.op == '+' and unc(i.r).k == 'const':
            self.add = unc(i.r).value
            i = unc(i.l)
        else:
            self.add = 0
        d = vdecl(i)
        need(d is not None and is_int(d.ty))
        self.idx = d


def scale(esz, r):
    if esz == 2:
        return 'add %s,%s' % (r, r)
    if esz == 4:
        return 'sla 0x2,%s' % r
    raise Decline()


def idx_into(F, el, r):
    """the index variable (plus its constant) into 16-bit register r"""
    ri = F.reg(el.idx)
    need(ri is not None)
    out = ['ld %s,%s' % (r, ri)]
    if el.add:
        need(1 <= el.add <= 8)
        out.append('inc %s,%s' % (hx(el.add), r))
    return out


def const_elem(F, el):
    """p[k] with p a register pointer -> operand"""
    rb = F.reg(el.base)
    need(rb is not None and rb.startswith('X'))
    off = el.cidx * el.esz
    return '(%s)' % rb if off == 0 else '(%s+%s)' % (rb, hx(off))


def addr_ptr(F, el, held=None):
    """the address of a pointer / unsized element; held: the 32-bit register that keeps it (else XWA) -> operand"""
    need(el.esz == 2 or (el.esz == 1 and el.kind == 'ptr'))
    out = idx_into(F, el, 'WA')
    out.append('extz XWA' if el.esz == 1 else 'exts XWA')
    if el.esz == 2:
        out.append('add XWA,XWA')
    if el.kind == 'unsized':
        h = held or 'XBC'
        out += ['ld %s,_%s' % (h, el.base.name), 'add %s,XWA' % h]
        return out, '(%s)' % h
    base = F.where(el.base)
    if held:
        out += ['ld %s,XWA' % held, 'add %s,%s' % (held, base)]
        return out, '(%s)' % held
    out.append('add XWA,%s' % base)
    return out, '(XWA)'


def sized(F, el, ri, rb):
    """a sized global element: index in ri, base in X<rb> -> (code, operand)"""
    if el.esz == 1:
        rv = F.reg(el.idx)
        need(rv is not None and not el.add)
        return ['lda X%s,_%s' % (rb, el.base.name)], '(X%s+%s)' % (rb, rv)
    return idx_into(F, el, ri) + [scale(el.esz, ri), 'lda X%s,_%s' % (rb, el.base.name)], '(X%s+%s)' % (rb, ri)


def accreg(esz, f='WA'):
    return {1: f[1], 2: f, 4: 'X' + f}[esz]


def free_after_vars(F, n=1):
    """the first n families no variable holds (WA excluded), in SEQ order"""
    used = F.live_homes()
    out = [r for r in FAMS16[1:] if r not in used]
    need(len(out) >= n)
    return out[:n]


def simple(F, x):
    """a value that is an operand as it is: constant, register variable, memory scalar -> text, or None"""
    x = unc(x)
    if x.k == 'const':
        return hx(x.value)
    d = vdecl(x)
    if d is not None and (d.ty.kind == 'ptr' or (d.ty.kind == 'int' and d.ty.size in (2, 4))):
        return F.where(d)                                              # (a char is not an int operand as it is)
    return None


def is_mem(t):
    return t.startswith('(')


def st_expr(F, e):
    e = strip(e)
    if e.k == 'incdec':
        d = vdecl(e.e) if strip(e.e).k != 'var' else strip(e.e).decl
        need(d is not None)
        r = F.reg(d)
        need(r is not None)
        F.e('%s 0x1,%s' % ('inc' if e.op == '++' else 'dec', r))
        return
    need(e.k in ('bin', 'opassign'))
    op = e.op if e.k == 'opassign' else '='
    if e.k == 'bin':
        need(e.op == '=')
    l = strip(e.l)
    if l.k == 'var':
        return assign_scalar(F, l.decl, op, e.r)
    if l.k == 'index':
        return assign_elem(F, Elem(l), op, e.r)
    if l.k == 'deref' and vdecl(l.e) is not None and F.reg(vdecl(l.e)) is not None and op == '=':
        v = simple(F, e.r)
        need(v is not None and not is_mem(v))
        F.e(('ldw (%s),%s' if unc(e.r).k == 'const' else 'ld (%s),%s') % (F.reg(vdecl(l.e)), v))
        return
    if l.k == 'deref':
        p = vdecl(l.e)
        need(p is not None and p.kind == 'global' and op == '=')
        v = simple(F, e.r)
        need(v is not None and not is_mem(v))
        F.e('ld XWA,(_%s)' % p.name, 'ld (XWA),%s' % v)
        return
    raise Decline()


def opname(op):
    return op[:-1] if op.endswith('=') and op != '=' else op


def assign_scalar(F, d, op, r):
    tgt = F.reg(d)
    r = unc(r)
    if op in ('>>=', '<<=') and tgt is not None and unc(r).k == 'const':
        F.e('%s %s,%s' % ('sra' if op == '>>=' else 'sla', hx(unc(r).value), tgt))
        return
    if op != '=':
        o = op if op in ARITH else opname(op)
        need(o in ARITH)
        v = simple(F, r)
        if tgt is not None:                                            # a += x on a register variable
            if v is not None and getattr(F, 'xr', False) and o in ('+', '-') and unc(r).k == 'const' and                     1 <= unc(r).value <= 8 and not tgt.startswith('Q'):
                F.e('%s %s,%s' % ('inc' if o == '+' else 'dec', hx(unc(r).value), tgt))   # -Xr h17: k += 2 -> inc 0x2,HL
                return
            need(not (getattr(F, 'xr', False) and tgt.startswith('Q')))   # (-Xr ra_leaf5: no arithmetic on
            if v is not None:                                          #  a high word; cc900 spills instead)
                F.e('%s %s,%s' % (ARITH[o], tgt, v))
                return
            if strip(r).k == 'load' and strip(strip(r).e).k == 'index':
                el = Elem(strip(r).e)
                need(el.esz == d.ty.size and el.cidx is None)
                if el.kind == 'sized':
                    code, opd = sized(F, el, 'WA', 'BC')
                else:
                    need(el.esz in (1, 2))
                    code, opd = addr_ptr(F, el)
                F.e(*code)
                F.e('%s %s,%s' % (ARITH[o], tgt, opd))
                return
            rr = val(F, r, 'WA')                                       # a computed value: in WA (BC for a shift)
            F.e('%s %s,%s' % (ARITH[o], tgt, rr))
            return
        need(d.kind == 'global')                                       # gr += x
        if v is not None and not is_mem(v):
            F.e('%s (_%s),%s' % (ARITH[o], d.name, v))
            return
        val(F, r, 'WA')
        F.e('%s (_%s),WA' % (ARITH[o], d.name))
        return
    x0 = unc(r)
    if tgt is not None and x0.k == 'bin' and x0.op in ARITH and vdecl(x0.l) is d and simple(F, x0.r) is None:
        return assign_scalar(F, d, x0.op + '=', x0.r)                  # x = x + e is x += e
    if tgt is not None and x0.k == 'bin' and x0.op in ('>>', '<<') and vdecl(x0.l) is d and unc(x0.r).k == 'const':
        F.e('%s %s,%s' % ('sra' if x0.op == '>>' else 'sla', hx(unc(x0.r).value), tgt))
        return
    if tgt is not None:                                                # a = x on a register variable
        v = simple(F, r)
        if v is not None:
            if tgt.startswith('Q') and is_mem(v):                      # memory to a high word: through WA
                F.e('ld WA,%s' % v, 'ld %s,WA' % tgt)
            else:
                F.e('ld %s,%s' % (tgt, v))
            return
        x = unc(r)
        need(x.k == 'load' and strip(x.e).k == 'index')
        el = Elem(strip(x.e))
        need(el.cidx is not None and not tgt.startswith('Q'))
        F.e('ld %s,%s' % (tgt, const_elem(F, el)))
        return
    need(d.kind == 'global')                                           # gr = x
    v = simple(F, r)
    if v is not None and not is_mem(v):
        if unc(r).k == 'const':                                        # a constant: ldw (_g),k
            need(d.ty.size == 2)
            F.e('ldw (_%s),%s' % (d.name, v))
        elif v.startswith('Q'):                                        # a high word to memory: through WA
            F.e('ld WA,%s' % v, 'ld (_%s),WA' % d.name)
        else:
            F.e('ld (_%s),%s' % (d.name, v))
        return
    reg = val(F, r, 'WA')
    F.e('ld (_%s),%s' % (d.name, reg))


def val(F, x, want='WA'):
    """compute int value x into a register (WA unless the template says otherwise) -> the register"""
    x = unc(x)
    need(is_int(x.ty))
    v = simple(F, x)
    if v is not None:
        F.e('ld %s,%s' % (want, v))
        return want
    if x.k == 'load' and strip(x.e).k == 'index':
        el = Elem(strip(x.e))
        if el.cidx is not None:
            F.e('ld %s,%s' % (want, const_elem(F, el)))
            return want
        if el.kind == 'sized':
            code, opd = sized(F, el, 'WA', 'BC')
            F.e(*code)
            F.e('ld WA,%s' % opd)
            return 'WA'
        code, opd = addr_ptr(F, el)
        F.e(*code)
        F.e('ld WA,%s' % opd)
        return 'WA'
    if x.k == 'bin' and x.op in ('<<', '>>'):
        l, r = unc(x.l), unc(x.r)
        need(vdecl(r) is not None and F.reg(vdecl(r)) is not None)
        lv = simple(F, l)
        need(lv is not None)
        F.e('ld BC,%s' % lv, 'ld WA,%s' % F.reg(vdecl(r)), 'and A,0xf')
        lb = F.label()
        F.e('j z,%s' % lb, '%s A,BC' % ('sla' if x.op == '<<' else 'sra'), lb + ':')
        return 'BC'
    if x.k == 'bin' and x.op == '*' and strip(unc(x.l)).k == 'load' and strip(strip(unc(x.l)).e).k == 'index' and \
            strip(unc(x.r)).k == 'load' and strip(strip(unc(x.r)).e).k == 'index':
        return two_elems(F, x)
    if x.k == 'bin' and x.op in ARITH and strip(unc(x.l)).k == 'load' and strip(strip(unc(x.l)).e).k == 'index' and \
            simple(F, x.r) is not None:                                # t[i + 1] + n: the element, then the operand
        val(F, x.l, 'WA')
        F.e('%s WA,%s' % (ARITH[x.op], simple(F, x.r)))
        return 'WA'
    if x.k == 'bin' and x.op in ('*', '/', '%'):
        lv, rv = simple(F, x.l), simple(F, x.r)
        if x.op == '*' and lv is not None and lv == rv and not is_mem(lv):   # i * i: ld WA,i / muls XWA,i
            F.e('ld WA,%s' % lv, 'muls XWA,%s' % lv)
            return 'WA'
        need(lv is not None and rv is not None)
        F.e('ld WA,%s' % lv)
        if x.op == '*':
            F.e('muls XWA,%s' % rv)
        else:
            F.e('exts XWA', 'divs XWA,%s' % rv)
            if x.op == '%':
                F.e('ld WA,QWA')
        return 'WA'
    if x.k == 'bin' and x.op in ARITH:
        if strip(unc(x.l)).k == 'load' and strip(strip(unc(x.l)).e).k == 'index' and \
                strip(unc(x.r)).k == 'load' and strip(strip(unc(x.r)).e).k == 'index':
            return two_elems(F, x)
        chain = []                                                     # n + n (+ n): ld WA,n / add WA,WA / add WA,n
        y = x
        while y.k == 'bin' and y.op in ARITH:
            chain.append((y.op, unc(y.r)))
            y = unc(y.l)
        first = simple(F, y)
        need(first is not None and all(simple(F, c[1]) is not None for c in chain))
        F.e('ld %s,%s' % (want, first))
        for k, (o, v) in enumerate(reversed(chain)):
            same = k == 0 and vdecl(v) is not None and vdecl(v) is vdecl(y)
            F.e('%s %s,%s' % (ARITH[o], want, want if same else simple(F, v)))
        return want
    raise Decline()


def two_elems(F, x):
    """ga[i] op gb[i] / p[i] op q[i]: the left's address first and held, the right read into WA"""
    L, R = Elem(strip(unc(x.l)).e), Elem(strip(unc(x.r)).e)
    need(L.esz == 2 and R.esz == 2)
    if L.kind == 'sized' and R.kind == 'sized':
        cl, ol = sized(F, L, 'DE', 'HL')
        cr, orr = sized(F, R, 'WA', 'BC')
    elif L.kind == 'ptr' and R.kind == 'ptr':
        h = 'X' + free_after_vars(F)[0]
        cl, ol = addr_ptr(F, L, held=h)
        cr, orr = addr_ptr(F, R)
    else:
        raise Decline()
    if L.kind == 'sized':
        need('DE' not in F.live_homes() and 'HL' not in F.live_x())
    F.e(*cl)
    F.e(*cr)
    F.e('ld WA,%s' % orr)
    F.e('%s XWA,%s' % ('muls', ol) if x.op == '*' else '%s WA,%s' % (ARITH[x.op], ol))
    return 'WA'


def assign_elem(F, L, op, r):
    o = None if op == '=' else (op if op in ARITH else opname(op))
    if o is not None:
        need(o in ARITH)
    x = unc(r)
    rv = simple(F, x)
    xl = x.k == 'load' and strip(x.e).k == 'index'
    if o is not None and not xl and L.kind == 'ptr' and L.esz == 2 and L.cidx is None:
        need(rv is not None)
        if x.k == 'const' and o in ('+', '-'):                         # p[i] += 3: incw 0x3,(XWA)
            c, opd = addr_ptr(F, L)
            F.e(*c)
            F.e('%s %s,%s' % ('incw' if o == '+' else 'decw', hx(x.value), opd))
            return
        c, opd = addr_ptr(F, L, held='XBC')                            # p[i] += gr: the address held in XBC
        F.e(*c)
        F.e('ld WA,%s' % rv, '%s %s,WA' % (ARITH[o], opd))
        return
    if xl:                                                             # elem = / op= elem
        R = Elem(strip(x.e))
        need(R.esz == L.esz)
        if L.kind == 'sized' and R.kind == 'sized':
            if L.esz == 1:
                need(o is None)
                cl, ol = sized(F, L, None, 'BC')
                cr, orr = sized(F, R, None, 'WA')
                F.e(*cl)
                F.e(*cr)
                F.e('ld A,%s' % orr, 'ld %s,A' % ol)
                return
            need('DE' not in F.live_homes() and 'HL' not in F.live_x())
            cl, ol = sized(F, L, 'DE', 'HL')
            cr, orr = sized(F, R, 'WA', 'BC')
            a = accreg(L.esz)
            F.e(*cl)
            F.e(*cr)
            F.e('ld %s,%s' % (a, orr))
            F.e('ld %s,%s' % (ol, a) if o is None else '%s %s,%s' % (ARITH[o], ol, a))
            return
        if o is None and xr_char_store(F, L, R):
            return
        if L.kind == 'ptr' and R.kind == 'ptr':
            if L.esz == 1:
                need(o is None)
                cl = idx_into(F, L, 'BC') + ['extz XBC', 'add XBC,%s' % F.where(L.base)]
                cr = idx_into(F, R, 'WA') + ['extz XWA', 'add XWA,%s' % F.where(R.base)]
                F.e(*cl)
                F.e(*cr)
                F.e('ld A,(XWA)', 'ld (XBC),A')
                return
            h = 'X' + free_after_vars(F)[0]
            need(h != 'XIZ')
            cl, ol = addr_ptr(F, L, held=h)
            cr, orr = addr_ptr(F, R)
            F.e(*cl)
            F.e(*cr)
            F.e('ld WA,%s' % orr)
            F.e('ld %s,WA' % ol if o is None else '%s %s,WA' % (ARITH[o], ol))
            return
        if L.kind == 'ptr' and R.kind == 'unsized' and L.esz == 2:     # p[i] += gw[i]
            h = 'X' + free_after_vars(F)[0]
            need(h not in ('XIZ', 'XBC'))
            cl, ol = addr_ptr(F, L, held=h)
            cr, orr = addr_ptr(F, R, held='XBC')
            F.e(*cl)
            F.e(*cr)
            F.e('ld WA,%s' % orr)
            F.e('ld %s,WA' % ol if o is None else '%s %s,WA' % (ARITH[o], ol))
            return
        if L.kind == 'ptr' and R.kind == 'sized' and L.esz == 1 == R.esz and o is None:   # d[i] = gca[i]
            cl = idx_into(F, L, 'BC') + ['extz XBC', 'add XBC,%s' % F.where(L.base)]
            cr, orr = sized(F, R, None, 'WA')
            F.e(*cl)
            F.e(*cr)
            F.e('ld A,%s' % orr, 'ld (XBC),A')
            return
        if L.kind == 'unsized' and R.kind == 'unsized':
            hr, hl = free_after_vars(F, 2)
            cl, ol = addr_ptr(F, L, held='X' + hl)
            cr, orr = addr_ptr(F, R, held='X' + hr)
            F.e(*cl)
            F.e(*cr)
            F.e('ld WA,%s' % orr)
            F.e('ld %s,WA' % ol if o is None else '%s %s,WA' % (ARITH[o], ol))
            if 'IZ' in (hr, hl):
                F.xiz = True
            return
        raise Decline()
    need(o is None)
    if L.cidx is not None:                                             # p[k] = v, p in a register
        opd = const_elem(F, L)
        if rv is not None and not is_mem(rv):
            F.e(('ldw %s,%s' if unc(x).k == 'const' else 'ld %s,%s') % (opd, rv))
            return
        r = val(F, x, 'WA')
        F.e('ld %s,%s' % (opd, r))
        return
    if L.kind == 'sized':
        if rv is not None and not is_mem(rv):
            if L.esz == 4:                                             # a long constant: index BC, base XDE
                need(unc(x).k == 'const')
                c, opd = sized(F, L, 'BC', 'DE')
                F.e(*c)
                F.e('ld XWA,%s' % rv, 'ld %s,XWA' % opd)
                return
            if L.esz == 1:                                             # gca[i] = k: lda XWA,_gca / ldb (XWA+i),k
                need(unc(x).k == 'const')
                c, opd = sized(F, L, None, 'WA')
                F.e(*c)
                F.e('ldb %s,%s' % (opd, hx(unc(x).value & 0xff)))
                return
            c, opd = sized(F, L, 'WA', 'BC')
            F.e(*c)
            F.e(('ldw %s,%s' if unc(x).k == 'const' else 'ld %s,%s') % (opd, rv))
            return
        if rv is not None:                                             # a memory scalar: index BC, base XDE, WA
            need(L.esz == 2)
            c, opd = sized(F, L, 'BC', 'DE')
            F.e(*c)
            F.e('ld WA,%s' % rv, 'ld %s,WA' % opd)
            return
        if x.k == 'bin' and x.op in ('*',) + tuple(ARITH) and strip(unc(x.l)).k == 'load' and \
                strip(strip(unc(x.l)).e).k == 'index' and simple(F, x.r) is not None and not is_mem(simple(F, x.r)):
            R = Elem(strip(unc(x.l)).e)                                # ga[i] = gb[i] * a: the left's address in
            need(R.kind == 'sized' and R.esz == 2 == L.esz)            # DE / XHL, the right read into WA
            need('DE' not in F.live_homes() and 'HL' not in F.live_x())
            cl, ol = sized(F, L, 'DE', 'HL')
            cr, orr = sized(F, R, 'WA', 'BC')
            F.e(*cl)
            F.e(*cr)
            F.e('ld WA,%s' % orr)
            F.e(('muls XWA,%s' if x.op == '*' else ARITH[x.op] + ' WA,%s') % simple(F, x.r))
            F.e('ld %s,WA' % ol)
            return
        need(L.esz == 2 and x.k == 'bin' and x.op in ARITH)
        if not (x.op == '+' and vdecl(x.l) is not None and vdecl(x.l) is vdecl(x.r)):
            c, opd = sized(F, L, 'BC', 'DE')                           # another computed value: index BC, base
            need('BC' not in F.live_homes() and 'DE' not in F.live_x())   # XDE, the value in WA (lc_FEN)
            F.e(*c)
            r = val(F, x, 'WA')
            need(r == 'WA')
            F.e('ld %s,WA' % opd)
            return
        c, opd = sized(F, L, 'WA', 'BC')                               # n + n: in DE after WA / XBC (o_n_in)
        F.e(*c)
        need('DE' not in F.live_homes())
        val(F, x, 'DE')
        F.e('ld %s,DE' % opd)
        return
    if L.kind in ('ptr', 'unsized'):
        need(L.esz == 2)
        if L.kind == 'ptr' and L.base.kind == 'global':
            need(unc(x).k == 'const')
            c, opd = addr_ptr(F, L)
            F.e(*c)
            F.e('ldw %s,%s' % (opd, rv))
            return
        if rv is not None and not is_mem(rv) and L.kind == 'ptr':
            c, opd = addr_ptr(F, L)
            F.e(*c)
            F.e(('ldw %s,%s' if unc(x).k == 'const' else 'ld %s,%s') % (opd, rv))
            return
        if rv is not None and L.kind == 'unsized' and not is_mem(rv):  # gu[i] = n, n in a register
            h = 'X' + free_after_vars(F)[0]
            need(h != 'XIZ')
            c, opd = addr_ptr(F, L, held=h)
            F.e(*c)
            F.e('ld %s,%s' % (opd, rv))
            return
        if rv is not None:
            need(not (getattr(F, 'xr', False) and L.base.kind == 'param'))   # (-Xr r_p_wr: p goes to the frame)
            c, opd = addr_ptr(F, L, held='XBC')
            F.e(*c)
            F.e('ld WA,%s' % rv, 'ld %s,WA' % opd)
            return
        els = []                                                       # (two elements in the value, or an element
        cg.walk(x, lambda m, dd: els.append(m) if m.k == 'index' else None)   # of another base: not fitted -- p_bound_only,
        need(len(els) <= 1)                                            # e_body_rhs, lnr4 h4)
        if els:
            need(Elem(els[0]).base is L.base)
        h = 'X' + free_after_vars(F)[0]                                # a computed value: the address held in
        need(h != 'XIZ')                                               # the first free register, the value in WA
        c, opd = addr_ptr(F, L, held=h)
        F.e(*c)
        r = val(F, x, 'WA')
        need(r == 'WA')
        F.e('ld %s,WA' % opd)
        return
    raise Decline()


# --------------------------------------------------------------------------------------------- loops

def cond_parts(F, c):
    """i < B / i > 0 -> (var register, relation, bound text)"""
    c = unc(c)
    need(c.k == 'bin' and c.op in ('<', '>'))
    d = vdecl(c.l)
    need(d is not None and is_int(d.ty))
    r = F.reg(d)
    need(r is not None)
    b = simple(F, c.r)
    need(b is not None)
    return d, r, c.op, b


CC = {'<': 'lt', '>': 'gt', '<=': 'le', '>=': 'ge', '==': 'eq', '!=': 'ne'}
NEG = {'<': 'ge', '>': 'le', '<=': 'gt', '>=': 'lt', '==': 'ne', '!=': 'eq'}


def cond_parts2(F, c):
    c = unc(c)
    need(c.k == 'bin' and c.op in CC)
    d = vdecl(c.l)
    need(d is not None and is_int(d.ty))
    r = F.reg(d)
    need(r is not None)
    b = simple(F, c.r)
    need(b is not None)
    return d, r, c.op, b


def if_stmt(F, s):
    """if (v) / if (t[0]) / if (t[0] < n): the test, a jump over the statement"""
    c = unc(s.cond)
    lskip = F.label()
    if c.k == 'bin' and c.op in CC:
        l, r = unc(c.l), unc(c.r)
        rv = simple(F, r)
        need(rv is not None)
        if strip(l).k == 'load' and strip(strip(l).e).k == 'index':
            el = Elem(strip(l).e)
            need(el.cidx is not None)
            if getattr(F, 'xr', False) and not is_mem(rv) and unc(r).k != 'const':
                F.e('cp %s,%s' % (const_elem(F, el), rv))   # -Xr p_cond_after: cp (XWA),BC
            else:
                F.e('ld WA,%s' % const_elem(F, el), 'cp WA,%s' % rv)
        else:
            lv = simple(F, l)
            need(lv is not None and not is_mem(lv))
            F.e('cp %s,%s' % (lv, rv))
        F.e('j %s,%s' % (NEG[c.op], lskip))
    else:
        if strip(c).k == 'load' and strip(strip(c).e).k == 'index':
            el = Elem(strip(c).e)
            need(el.cidx is not None)
            F.e('cpw %s,0x0' % const_elem(F, el))
        else:
            v = simple(F, c)
            need(v is not None)
            F.e(('cpw %s,0x0' if is_mem(v) else 'cp %s,0x0') % v)
        F.e('j eq,%s' % lskip)
    st_block(F, s.then, False)
    F.e(lskip + ':')


def compare(F, r, b):
    if r.startswith('Q'):
        F.e('ld WA,%s' % r, 'cp WA,%s' % b)
    else:
        F.e('cp %s,%s' % (r, b))


def st_for(F, s, last):
    init = s.init
    if init is not None:
        st_block(F, init if getattr(init, 'k', None) in ('expr', 'decl', 'block') else
                 type('S', (), {'k': 'expr', 'e': init})(), False)
    d, r, rel, b = cond_parts(F, s.cond)
    step = strip(s.inc)
    need(step.k == 'incdec' and strip(step.e).k == 'var' and strip(step.e).decl is d)
    up = step.op == '++'
    need((rel == '<') == up)
    if not up:
        need(b == '0x0')
    lend, ltop = F.label(), F.label()
    if getattr(F, 'xr', False):
        xr_seg(F, s.cond)
    compare(F, r, b)
    exit_cc = 'ge' if up else 'le'
    F.e('j %s,%s' % (exit_cc, lend))
    F.e(ltop + ':')
    st_block(F, s.body, False)
    if getattr(F, 'xr', False):
        xr_seg(F, s.cond)
    if up:
        F.e('inc 0x1,%s' % r)
        compare(F, r, b)
        F.e('j lt,%s' % ltop)
    else:
        F.e('sub %s,0x1' % r, 'j gt,%s' % ltop)
    F.e(lend + ':')


def st_block(F, s, last):
    if s is None:
        return
    if s.k == 'block':
        for k, c in enumerate(s.body):
            st_block(F, c, last and k == len(s.body) - 1)
        return
    if getattr(F, 'xr', False) and s.k in ('decl', 'expr', 'return', 'if'):
        xr_seg(F, getattr(s, 'init', None) if s.k == 'decl' else s.e if s.k == 'expr' else
               None if s.k == 'return' else s.cond)   # (the result's HL is no template register)
    if s.k == 'decl':
        if getattr(s, 'init', None) is not None:
            assign_scalar(F, s.var, '=', s.init)
        return
    if s.k == 'expr':
        st_expr(F, s.e)
        return
    if s.k == 'for':
        st_for(F, s, last)
        return
    if s.k == 'while':                                                 # while (v rel b): the test, the body, the test
        d, r, rel, b = cond_parts2(F, s.cond)
        lend, ltop = F.label(), F.label()
        if getattr(F, 'xr', False):
            xr_seg(F, s.cond)
        compare(F, r, b)
        F.e('j %s,%s' % (NEG[rel], lend), ltop + ':')
        st_block(F, s.body, False)
        if getattr(F, 'xr', False):
            xr_seg(F, s.cond)
        compare(F, r, b)
        F.e('j %s,%s' % (CC[rel], ltop), lend + ':')
        return
    if s.k == 'do':
        d, r, rel, b = cond_parts2(F, s.cond)
        ltop = F.label()
        F.e(ltop + ':')
        st_block(F, s.body, False)
        if getattr(F, 'xr', False):
            xr_seg(F, s.cond)
        compare(F, r, b)
        F.e('j %s,%s' % (CC[rel], ltop))
        return
    if s.k == 'if' and getattr(s, 'els', None) is None and getattr(s, 'else_', None) is None:
        if_stmt(F, s)
        return
    if s.k == 'return' and s.value is not None:                        # the result in HL
        x = unc(s.value)
        v = simple(F, x)
        if v is not None:
            if v.upper() != 'HL':
                F.e('ld HL,%s' % v)
            return
        need(x.k == 'bin' and x.op in ARITH)
        a, b = simple(F, x.l), simple(F, x.r)
        need(a is not None and a.upper() == 'HL' and b is not None)
        F.e('%s HL,%s' % (ARITH[x.op], b))
        return
    raise Decline()


# --------------------------------------------------------------------------------------------- whole function

def is_leaf(f):
    bad = []
    cg.walk(f.body, lambda n, d: bad.append(n) if n.k == 'call' else None)
    return not bad


def whole_(f, s):
    if s == 'Xr' and LNRW_XR:
        return whole_xr(f)
    need(s == 'none')
    need(is_leaf(f))
    need(f.ret is not None and (f.ret.kind == 'void' or is_int(f.ret)))
    F = Fn(f, s)
    homes(F)
    body = cg.flat(f.body)
    need(any(x.k == 'for' for x in body))
    if any(h.lstrip('Q') == 'IZ' for h in F.home.values()):
        F.push = 2
    for d in f.params:                                                 # promoted parameters, at entry
        if d in F.home:
            F.e('ld %s,%s' % (F.reg(d), F.slot(d)))
    for k, st in enumerate(body):
        st_block(F, st, k == len(body) - 1)
    pre = ['push IZ'] if F.push == 2 else []
    if getattr(F, 'xiz', False):
        need(F.push == 0)
        F.push = 4
        F.out = []
        F.n = 0
        for d in f.params:
            if d in F.home:
                F.e('ld %s,%s' % (F.reg(d), F.slot(d)))
        for k, st in enumerate(body):
            st_block(F, st, k == len(body) - 1)
        pre = ['push XIZ']
    post = ['pop IZ'] if pre == ['push IZ'] else ['pop XIZ'] if pre else []
    out = pre + F.out + post + ['ret']
    for k, l in enumerate(out):                                        # a jump to a label followed by ret is a
        m = re.match(r'j (\w+),(L\d+)$', l)                            # conditional ret (the label stays)
        if m:
            t = out.index(m.group(2) + ':')
            nxt = next(x for x in out[t + 1:] if not x.endswith(':'))
            if nxt == 'ret':
                out[k] = 'ret %s' % m.group(1)
    return out


LNRW_XR = True                                            # see whole_xr

# --------------------------------------------------------------------------------------------- stage 2: -Xr
# (executed in lnrw's namespace; see lane_lnrxr/RULES.md)
#
# The parameters arrive in WA, BC, DE (A C E for a char, XWA XBC XDE for a long or pointer).  A parameter that
# leafnone.early_param calls early stays in its register (precoloured); the statements' template registers are then
# resolved around it as LN1 resolves them around any earlier variable (resolve(): the next free family), so the
# templates of section 2 come out shifted (index WA, base XBC -> index BC, base XDE while k sits in WA), and the
# locals fill what is left, which pushes the counter to IX / IY / IZ.  A parameter whose register is the fixed A of a
# shift count, or that is not early, is allocated like a late parameter and moved there at entry (ld BC,WA).  The
# code is the none code with the variables written in lower case; each statement's upper-case (template) families
# are moved up past the families that a variable holds across it, then the variables are written in upper case.

XR_ARGS = ('WA', 'BC', 'DE')
XR_SOFT = True
XR_T16 = ('WA', 'BC', 'DE', 'HL', 'IX', 'IY', 'IZ')


def xr_tok(h, size):
    """a variable's register written in lower case (the template registers stay upper case)"""
    if h.startswith('Q'):
        need(size == 2)
        return 'Q' + h[1:].lower()
    if size == 4:
        return 'X' + h.lower()
    if size == 1:
        need(h in ('WA', 'BC', 'DE', 'HL'))
        return h[1].lower()
    return h.lower()


def xr_fixed_wa(u, inreg):
    """does the unit need A itself: a shift by a variable count (and A,0xf / sla A,BC), a char copied between two
    elements of register pointers (ld A,(XBC+QWA) / ld (XHL+QWA),A)?"""
    e = u[2][2] if isinstance(u[2], tuple) else u[2]
    hit = []
    if xr_shape(u, inreg) == 'cptr':
        return True
    cg.walk(e, lambda n, d: hit.append(n) if n.k == 'bin' and n.op in ('<<', '>>') and unc(n.r).k != 'const' else None)
    cg.walk(e, lambda n, d: hit.append(n) if n.k == 'opassign' and n.op in ('<<=', '>>=') and unc(n.r).k != 'const' else None)
    return bool(hit)


def xr_shape(u, inreg):
    """units whose -Xr template is not the none template with its registers moved: 'cptr' a char copied between
    elements of two register pointers (ld A,(XBC+QWA) / ld (XHL+QWA),A), 'cps' a char element of a sized global
    stored through a register pointer (lda XDE,_gca / ld E,(XDE+HL) / ld (XWA+HL),E), 'pgw' p[i] op= gw[i] with p a
    register pointer and gw unsized (the right base and the held address come after the locals: s_add_gw, h17)"""
    if isinstance(u[2], tuple):
        return None
    x = unc(u[2])
    if x.k not in ('bin', 'opassign') or (x.k == 'bin' and x.op != '=') or strip(x.l).k != 'index':
        return None
    lb = strip(strip(x.l).base)
    lb = strip(lb.e) if lb.k == 'decay' else lb
    pl = vdecl(lb)
    if pl is None or pl not in inreg or pl.ty.kind != 'ptr':
        return None
    r = unc(x.r)
    if strip(r).k == 'load' and strip(strip(r).e).k == 'index' and x.l.ty.size == 1 and x.k == 'bin':
        rb = strip(strip(strip(r).e).base)
        rb = strip(rb.e) if rb.k == 'decay' else rb
        if vdecl(rb) is not None and vdecl(rb) in inreg and vdecl(rb).ty.kind == 'ptr' and r.ty.size == 1:
            return 'cptr'
        if rb.k == 'var' and rb.decl.kind == 'global' and rb.decl.ty.kind == 'array' and (rb.decl.ty.count or 0) > 0 \
                and r.ty.size == 1:
            return 'cps'
    els = []
    cg.walk(r, lambda n, d: els.append(n) if n.k == 'index' else None)
    if x.l.ty.size == 2 and any(leafnone.is_unsized_global(n.base) for n in els):
        return 'pgw'
    return None


def xr_allocate(f, inreg, args):
    """leafnone.allocate with the early parameters precoloured in their argument registers -> (got, rng, L)"""
    lf = leafnone
    vs = [d for d in lf.variables(f) if d in inreg]
    L = lf.linear(f)
    rng = {}
    for d in vs:
        evs = [e for e in L.ev if e[1] is d]
        pos = [e[0] for e in evs]
        lo = 0 if d.kind == 'param' else (min(pos) if pos else 0)
        hi = max(pos) if pos else 0
        for (a, b, n) in L.loops:
            inl = [e for e in evs if a <= e[0] <= b]
            if inl and inl[0][2] != 'w':
                lo, hi = min(lo, a), max(hi, b)
        rng[d] = (lo, hi, evs)

    def overlaps(d, u):
        return rng[d][0] <= u[1] and rng[d][1] >= u[0]

    def reads_in(d, u):
        return [e[0] for e in rng[d][2] if u[0] <= e[0] <= u[1] and 'r' in e[2]]

    def crowded(u):
        return sum(rng[w][0] < u[0] and rng[w][1] > u[1] and not any(u[0] <= e[0] <= u[1] for e in rng[w][2]) for w in vs)
    P = lf.prefs(f, vs, inreg)
    early = {d for d in vs if d.kind == 'param' and lf.early_param(d, L)}
    got = {}
    R = {id(u): lf.reserve(u, inreg, crowded(u)) for u in L.units}
    for u in L.units:
        sh_ = xr_shape(u, inreg)
        if sh_ in ('cptr', 'cps'):
            R[id(u)] = (['WA'], [])
        elif sh_ == 'pgw':
            R[id(u)] = ([x for x in R[id(u)][0] if x not in ('BC', 'QBC')], [])

    def held_by(u, done):
        h = set()
        for w, r in done.items():
            if overlaps(w, u):
                h |= lf.res_of(r, w.ty.size)
        return h

    def resolve(want, u, avoid):
        """LN1's resolve, and a high word follows its low word's move (QBC with BC -> DE: QDE)"""
        out = []
        mv = {}
        for r in [x for x in want if not x.startswith('Q')] + [x for x in want if x.startswith('Q')]:
            if r.startswith('Q') and r[1:] in mv:
                r = 'Q' + mv[r[1:]]
                if r in avoid or r in out or r not in lf.SEQ16:
                    continue
                out.append(r)
                continue
            if r in avoid or r in out:
                if r.startswith('Q'):
                    continue
                r0 = r
                r = next((x for x in lf.SEQ16[lf.SEQ16.index(r):] if x not in avoid and x not in out), None)
                if r is None:
                    continue
                mv[r0] = r
            out.append(r)
        return set(out)

    def busy_for(d, sets):
        lo, hi, evs = rng[d]
        busy = set()
        for u in L.units:
            if not overlaps(d, u):
                continue
            rd = reads_in(d, u)
            e = u[2]
            defines = (isinstance(e, tuple) and e[1] is d) or (getattr(e, 'k', None) == 'bin' and e.op == '=' and
                                                               strip(e.l).k == 'var' and strip(e.l).decl is d)
            if defines and not rd and d.kind != 'param':
                continue
            rs = set(sets[id(u)])
            last = rd and max(rd) == hi and u[0] <= hi <= u[1]
            if last:
                top = e[2] if isinstance(e, tuple) else e
                top = unc(top)
                if top.k in ('bin', 'opassign') and (top.k == 'opassign' or top.op == '=') and \
                        strip(top.l).k in ('index', 'deref'):
                    top = type('X', (), {'k': 'none'})()
                elif top.k == 'bin' and top.op == '=':
                    top = unc(top.r)
                if lf.var_of(top) is d or (top.k == 'bin' and lf.var_of(top.l) is d) or P.get(d) == 'WA':
                    rs -= {'WA', 'QWA'}
                if P.get(d) and top.k == 'bin' and lf.var_of(top.l) is d:
                    rs -= lf.res_of(P[d], 4)
            busy |= rs
        return busy

    def take(d, avoid_sets):
        busy = busy_for(d, avoid_sets)
        lo, hi, _ = rng[d]
        held = set()
        for w, r in got.items():
            if rng[w][0] <= hi and rng[w][1] >= lo:
                held |= lf.res_of(r, w.ty.size)
        blocked = busy | held
        seq = lf.SEQ8 if d.ty.size == 1 else lf.SEQ32 if d.ty.size == 4 else lf.SEQ16
        pr = P.get(d)
        if pr and not (lf.res_of(pr, d.ty.size) & blocked):
            return pr
        return next((r for r in seq if not (lf.res_of(r, d.ty.size) & blocked)), '-')
    # 0. the result variables (HL), then the early parameters in their argument registers
    for d in reversed(vs):
        if d.kind == 'local' and P.get(d) == 'HL':
            got[d] = take(d, {id(u): set() for u in L.units})
            if got[d] != 'HL':
                del got[d]
    fixed = {d for d in vs if d.kind == 'param' and args[d] == 'WA' and any(overlaps(d, u) and xr_fixed_wa(u, inreg)
                                                                          for u in L.units)}
    for d in vs:                                       # every parameter stays in its register
        if d.kind == 'param' and d not in fixed:
            got[d] = args[d]
    for d in vs:                                       # unless a template needs A there: an early one moves to the
        if d in fixed and d in early:                  # next free family at once (r_shl_i: ld BC,WA), a late one is
            held = set()                               # allocated last (r_cp_cpy: ld XHL,XWA)
            for w, r in got.items():
                held |= lf.res_of(r, w.ty.size)
            got[d] = next((r for r in (lf.SEQ32 if d.ty.size == 4 else lf.SEQ16)[1:]
                           if not (lf.res_of(r, d.ty.size) & held)), None)
            need(got[d] is not None)
    # 1. the template registers, around them
    HARD = {id(u): resolve(R[id(u)][0], u, held_by(u, got)) for u in L.units}
    # 2. the early parameters that could not stay
    for d in reversed(vs):
        if d in early and d not in got:
            got[d] = take(d, HARD)
    SOFT = {}
    for u in L.units:
        hs = HARD[id(u)]
        SOFT[id(u)] = resolve(R[id(u)][1], u, held_by(u, got) | hs) if R[id(u)][1] else set()
    ALL = {k: HARD[k] | (SOFT[k] if XR_SOFT else set()) for k in HARD}
    for d in [d for d in reversed(vs) if d.kind == 'local' and d not in got] + \
             [d for d in reversed(vs) if d.kind == 'param' and d not in got]:
        got[d] = take(d, ALL)
    return got, rng, L


def xr_homes(F):
    f = F.f
    need(len(f.params) <= 3)
    args = {}
    for k, d in enumerate(f.params):
        need(d.ty.kind in ('int', 'ptr') and d.ty.size in (1, 2, 4))
        args[d] = XR_ARGS[k]
    vs = leafnone.variables(f)
    need(all(d in vs for d in f.params))
    inreg = set(vs)
    got, rng, L = xr_allocate(f, inreg, args)
    for d in inreg:
        r = got.get(d, '-')
        need(r != '-')
        F.home[d] = r
    F.xr_args, F.xr_rng, F.xr_L = args, rng, L
    F.xr_units = {}
    for u in L.units:
        e = u[2][2] if isinstance(u[2], tuple) else u[2]
        F.xr_units[id(e)] = u


FAMRX = r'\b(X|Q)?(WA|BC|DE|HL|IX|IY|IZ)\b|\b([AWBCDEHL])\b'


def xr_fam(m):
    if m.group(2):
        return m.group(2)
    return {'A': 'WA', 'W': 'WA', 'B': 'BC', 'C': 'BC', 'D': 'DE', 'E': 'DE', 'H': 'HL', 'L': 'HL'}[m.group(3)]


def xr_seg(F, key):
    """mark the start of a statement's code (key: the unit's expression, None for code outside any unit)"""
    F.out.append('#U %s' % (key if key is None else id(key)))


def xr_finish(F, out):
    """shift each segment's template families past the variables live across it, then upper-case the variables"""
    res = []
    unit = None
    seg = []

    def flush():
        if not seg:
            return
        avoid = set()
        if unit is not None:
            for d, (lo, hi, _) in F.xr_rng.items():
                if lo <= unit[1] and hi >= unit[0]:
                    h = F.home[d]
                    avoid |= {h} if h.startswith('Q') else ({h, 'Q' + h} if d.ty.size == 4 else {h})
        for l in seg:
            for m in re.finditer(r'\b(X|Q)?(wa|bc|de|hl|ix|iy|iz)\b', l):
                avoid.add(('Q' if m.group(1) == 'Q' else '') + m.group(2).upper())
            for m in re.finditer(r'\b([awbcdehl])\b', l):
                avoid.add({'a': 'WA', 'w': 'WA', 'b': 'BC', 'c': 'BC', 'd': 'DE', 'e': 'DE', 'h': 'HL', 'l': 'HL'}[m.group(1)])
        temps = set()
        for l in seg:
            if l.endswith(':'):
                continue
            for m in re.finditer(FAMRX, l.split(' ', 1)[1] if ' ' in l else ''):
                temps.add(xr_fam(m))
        mp = {}
        taken = set()
        for t in [x for x in XR_T16 if x in temps]:
            if t not in avoid and t not in taken:
                mp[t] = t
            else:
                n = next((x for x in XR_T16[XR_T16.index(t):] if x not in avoid and x not in taken), None)
                need(n is not None)
                mp[t] = n
            taken.add(mp[t])
        for l in seg:
            if l.endswith(':') or ' ' not in l or not any(a != b for a, b in mp.items()):
                res.append(l)
                continue
            op, args = l.split(' ', 1)

            def sub(m):
                fam = xr_fam(m)
                t = mp.get(fam, fam)
                if t == fam:
                    return m.group(0)
                if m.group(2):
                    return (m.group(1) or '') + t
                need(t in ('WA', 'BC', 'DE', 'HL'))
                return t[1] if m.group(3) in 'ACEL' else t[0]
            res.append(op + ' ' + re.sub(FAMRX, sub, args))
    for l in out:
        if l.startswith('#U '):
            flush()
            seg = []
            k = l[3:]
            unit = None if k == 'None' else next((u for kk, u in F.xr_units.items() if str(kk) == k), None)
            continue
        seg.append(l)
    flush()

    def up(l):
        if ' ' not in l:
            return l
        op, args = l.split(' ', 1)
        args = re.sub(r'\b(X|Q)?(wa|bc|de|hl|ix|iy|iz)\b', lambda m: (m.group(1) or '') + m.group(2).upper(), args)
        args = re.sub(r'\b([awbcdehl])\b', lambda m: m.group(1).upper(), args)
        return op + ' ' + args
    return [up(l) for l in res]


def whole_xr(f):
    need(is_leaf(f))
    need(f.ret is not None and (f.ret.kind == 'void' or is_int(f.ret)))
    F = Fn(f, 'Xr')
    F.xr = True
    xr_homes(F)
    body = cg.flat(f.body)
    need(any(x.k == 'for' for x in body))
    if any(h.lstrip('Q') == 'IZ' for h in F.home.values()):
        F.push = 2
    xr_seg(F, None)
    for d in f.params:                                                 # a parameter moved at entry
        if F.home[d] != F.xr_args[d]:
            need(not F.home[d].startswith('Q'))
            F.e('ld %s,%s' % (F.reg(d), xr_tok(F.xr_args[d], d.ty.size).upper()))
    for k, st in enumerate(body):
        st_block(F, st, k == len(body) - 1)
    body_ = xr_finish(F, F.out)
    xiz = any(re.search(r'\bXIZ\b', l) for l in body_)
    need(not (xiz and F.push == 2))
    pre = ['push IZ'] if F.push == 2 else ['push XIZ'] if xiz else []
    post = ['pop IZ'] if F.push == 2 else ['pop XIZ'] if xiz else []
    out = pre + body_ + post + ['ret']
    for k, l in enumerate(out):
        m = re.match(r'j (\w+),(L\d+)$', l)
        if m:
            t = out.index(m.group(2) + ':')
            nxt = next(x for x in out[t + 1:] if not x.endswith(':'))
            if nxt == 'ret':
                out[k] = 'ret %s' % m.group(1)
    return out


def xr_char_store(F, L, R):
    """-Xr, a char element stored through a register pointer at a register index: (Xp+i) with no address code; the
    right a register pointer's element (ld A,(XBC+QWA)) or a sized global's (lda XWA,_gca / ld A,(XWA+i)) -> True"""
    if not getattr(F, 'xr', False) or L.esz != 1 or R.esz != 1 or L.kind != 'ptr' or L.add or L.cidx is not None:
        return False
    rp, ri = F.reg(L.base), F.reg(L.idx)
    if rp is None or ri is None or not rp.startswith('X'):
        return False
    if R.kind == 'ptr':
        need(False)                                    # (two register pointers: which one moves, and where the char
                                                       # goes, is not settled -- r_cp_cpy moves the destination to XHL
                                                       # and uses A, micro c_copy the source and uses C)
    if R.kind == 'sized' and R.cidx is None and not R.add and R.idx is L.idx:
        F.e('lda XWA,_%s' % R.base.name, 'ld A,(XWA+%s)' % ri, 'ld (%s+%s),A' % (rp, ri))
        return True
    return False


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
    except Exception:
        return None


RUNS = {'lnr': '2026-11-09-31-micro-lnr', 'lnr2': '2026-11-09-32-micro-lnr2', 'lnr3': '2026-11-09-33-micro-lnr3',
        'lnr4': '2026-11-09-34-micro-lnr4'}
ORACLE = HOME_ + 'compartilhado/cc900-oracle/runs/%s/out/v423/%s/probes/%s.asm'
PROBE = 'corpus/probes/%s.c'


def check(s, probes, show=0, only=None):
    import frontend
    import listing
    tot = [0, 0, 0]
    shown = 0
    for p in probes:
        want = listing.split(open(ORACLE % (RUNS[p], s, p), encoding='latin-1').read())
        unit = frontend.load(PROBE % p, [], [], adecl=s.endswith('Xr'))
        ok = wrong = dec = 0
        for f in unit.functions:
            if only and not re.search(only, f.name):
                continue
            W = [l for l in want.get(('.' if s.endswith('Xr') else '_') + f.name, []) if 'section' not in l][1:]
            got = whole(f, s)
            if got is None:
                dec += 1
                continue
            if listing.normalise_labels(got) == listing.normalise_labels(W):
                ok += 1
            else:
                wrong += 1
                if shown < show:
                    shown += 1
                    print('---- %s %s' % (s, f.name))
                    for k in range(max(len(W), len(got))):
                        print('  %-34s | %s' % (W[k].strip() if k < len(W) else '', got[k].strip() if k < len(got) else ''))
        print('%-7s %-5s exact %3d  wrong %3d  declined %3d' % (s, p, ok, wrong, dec))
        tot = [tot[0] + ok, tot[1] + wrong, tot[2] + dec]
    print('%-7s all   exact %3d  wrong %3d  declined %3d' % (s, *tot))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        probes = [a[a.index('--probe') + 1]] if '--probe' in a else list(RUNS)
        for s in [x for x in a[1:] if x in SETS] or ['none']:
            check(s, probes, show, only)
