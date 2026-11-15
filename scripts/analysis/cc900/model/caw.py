#!/usr/bin/env python3
"""chararith_ast.py -- the cc900 V4.23 oracle's code for the functions of probes chararith.c (oracle run
2026-11-13-8-micro-chararith) and chararith2.c (run 2026-11-13-10-micro-chararith2) at four option sets, from the
model's AST.  A superset of chararith2_ast.py: on chararith2's grammar it gives that module's code.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 chararith_ast.py --check [SET...] [--show N] [--only REGEX] [--probe chararith|chararith2]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path
    python3 chararith_ast.py --rename OUT.c [--probe P]
        a copy of the probe with every global renamed (x_<name>_q), checked against the oracle listing renamed the
        same way in memory

One statement C(E) of one char expression E (char arithmetic stays char-typed in cc900):

    E, any operand kind x:  -x   ~x   x << k   x * K   x + K (K 1..8)
    E, global operands only:  g * h   g + h   g - h   g / h (signed)   g + K (unsigned, K 128..255)
    x: a global, gca[2], gca[a], *gp, gps->c, the char parameter pc / puc  (chararith2.c's kinds)
    C, any operand kind: gi = E; return E; return E / D; return E >> R; if (E > K) v0(); gl = E;
    C, global operands only: gc2 = E; return E % D; return E + gi; v1(E); return -(E); return E ^ gi; gu = E;
                             return E * gi;

The function is classified from its AST alone; the real symbols, offsets and constants are substituted.  Anything
outside the grammar returns None.  The rules are in chararith-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')
BASE_C = ('si', 'ri', 'sd', 'sr', 'cm', 'sl')     # the contexts every operand kind takes (chararith2.c)
UNARY = ('ng', 'cp', 'sh', 'mk', 'ak')


class Decline(Exception):
    pass


def need(c):
    if not c:
        raise Decline()


def hx(v):
    return '0x%x' % v


# --------------------------------------------------------------------------------------------- types

def is_ty(ty, size, signed):
    return ty is not None and ty.kind == 'int' and ty.size == size and ty.signed == signed


def is_int(ty):
    return is_ty(ty, 2, True)


def is_char(ty):
    return ty is not None and ty.kind == 'int' and ty.size == 1


def is_void(ty):
    return ty is not None and ty.kind == 'void'


def const(n, lo, hi):
    """an int constant lo <= v <= hi -> v"""
    n = cg.strip(n)
    need(n.k == 'const' and is_int(n.ty) and n.value is not None and lo <= n.value <= hi)
    return n.value


def not_pow2(v):
    return v & (v - 1) != 0


def gname(d):
    return '_' + d.name


def gvar(n):
    """a global variable node (not loaded) -> decl"""
    n = cg.strip(n)
    need(n.k == 'var' and n.decl.kind == 'global')
    return n.decl


def gload(n, test):
    """a load of a global whose type passes test -> its symbol"""
    n = cg.strip(n)
    need(n.k == 'load' and test(n.ty))
    d = gvar(n.e)
    need(test(d.ty))
    return gname(d)


# --------------------------------------------------------------------------------------------- classification

class X:
    """the char operand.  k: g e x p m r; signed; plus per kind
    m (g e: memory operand text without parentheses), arr (x), ptr / off (p m), reg / pair / slot (r), decl (g)"""

    def __init__(self, k, signed, **kw):
        self.k, self.signed = k, signed
        self.__dict__.update(kw)


class E:
    """the char expression.  op: ng cp sh mk ak (one operand x) or mul add sub div (two globals x, y);
    v: the constant (sh mk ak); sg: its effective char type; prod: a product (signed: a 16-bit int in some contexts)"""

    def __init__(self, op, x, y=None, v=None):
        self.op, self.x, self.y, self.v = op, x, y, v
        if op == 'mul':
            self.sg = x.signed and y.signed
        else:
            self.sg = x.signed
        self.prod = op in ('mk', 'mul')

    def base(self):
        """in chararith2.c's grammar (every operand kind, the six base contexts)"""
        return self.op in UNARY and (self.op != 'ak' or self.v <= 8)

    def globals_only(self):
        return self.x.k == 'g' and (self.y is None or self.y.k == 'g')


def probe_signature(f):
    """(int a, char pc, unsigned char puc): an element at a or a char parameter is read only with these (its stack
    slot and argument register come from it); a global operand takes any parameters, which it does not read"""
    need(len(f.params) == 3 and is_int(f.params[0].ty) and is_ty(f.params[1].ty, 1, True) and
         is_ty(f.params[2].ty, 1, False))


def operand(n, f):
    """the promoted char operand: cast(int) of a char load"""
    n = cg.strip(n)
    need(n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit and is_int(n.ty))
    ld = cg.strip(n.e)
    need(ld.k == 'load' and is_char(ld.ty))
    sg = ld.ty.signed
    x = cg.strip(ld.e)
    need(is_char(x.ty) and x.ty.signed == sg)
    if x.k == 'var':
        d = x.decl
        need(is_char(d.ty) and d.ty.signed == sg)
        if d.kind == 'global':
            return X('g', sg, m=gname(d), decl=d)
        need(d.kind == 'param')
        probe_signature(f)
        i = f.params.index(d)
        need(i == (1 if sg else 2))                                    # pc / puc, as in the probe's signature
        return X('r', sg, reg='C' if i == 1 else 'E', pair='BC' if i == 1 else 'DE', slot=4 + 2 * i)
    if x.k == 'index':
        b = cg.strip(x.base)
        need(b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array')
        need(is_char(b.decl.ty.base) and b.decl.ty.base.signed == sg)
        i = cg.strip(x.idx)
        if i.k == 'const':
            v = const(i, 1, b.decl.ty.count - 1 if b.decl.ty.count else 0x7fff)
            return X('e', sg, m='%s + %s' % (gname(b.decl), hx(v)))
        need(i.k == 'load' and is_int(i.ty))
        v = cg.strip(i.e)
        probe_signature(f)
        need(v.k == 'var' and v.decl is f.params[0])
        return X('x', sg, arr=gname(b.decl))
    if x.k == 'deref':
        p = cg.strip(x.e)
        need(p.k == 'load' and p.ty is not None and p.ty.kind == 'ptr')
        d = gvar(p.e)
        need(d.ty is not None and d.ty.kind == 'ptr' and is_char(d.ty.base) and d.ty.base.signed == sg)
        return X('p', sg, ptr=gname(d), off=0)
    if x.k == 'member':
        need(x.arrow)
        p = cg.strip(x.base)
        need(p.k == 'load' and p.ty is not None and p.ty.kind == 'ptr')
        d = gvar(p.e)
        need(d.ty is not None and d.ty.kind == 'ptr' and d.ty.base is not None and d.ty.base.kind == 'struct')
        off = cg.member_offset(x)
        need(0 <= off < 0x80)
        return X('m', sg, ptr=gname(d), off=off)
    raise Decline()


def is_operand(n, f):
    try:
        operand(n, f)
        return True
    except Decline:
        return False


def pair(n, f):
    """two distinct global char operands"""
    x, y = operand(n.l, f), operand(n.r, f)
    need(x.k == 'g' and y.k == 'g' and x.decl is not y.decl)
    return x, y


def expression(n, f):
    """E -> E()"""
    n = cg.strip(n)
    need(is_int(n.ty))
    if n.k == 'un' and n.op in ('-', '~'):
        return E('ng' if n.op == '-' else 'cp', operand(n.e, f))
    need(n.k == 'bin')
    rc = cg.strip(n.r).k == 'const'
    if n.op == '<<':
        return E('sh', operand(n.l, f), v=const(n.r, 1, 7))
    if n.op == '*' and rc:
        v = const(n.r, 3, 127)
        need(not_pow2(v))
        return E('mk', operand(n.l, f), v=v)
    if n.op == '+' and rc:
        x = operand(n.l, f)
        v = const(n.r, 1, 255)
        need(v <= 8 or (v >= 128 and not x.signed and x.k == 'g'))   # inc 1..8; guc + 200: add A,0xc8
        return E('ak', x, v=v)
    if n.op == '*':                                                    # gc * hc, guc * huc, gc * guc (not guc * gc)
        x, y = pair(n, f)
        need(x.signed or not y.signed)
        return E('mul', x, y)
    if n.op in ('+', '-'):                                             # the same char type on both sides
        x, y = pair(n, f)
        need(x.signed == y.signed)
        return E('add' if n.op == '+' else 'sub', x, y)
    if n.op == '/':
        x, y = pair(n, f)
        need(x.signed and y.signed)
        return E('div', x, y)
    raise Decline()


def callee(fnode, xr, arg):
    """the called function: `void (void)` (arg False) or `void (int)` (arg True) -> its symbol"""
    fn = cg.strip(fnode)
    if fn.k == 'cast':
        need(fn.kind == 'FunctionToPointerDecay')
        fn = cg.strip(fn.e)
    need(fn.k == 'var' and fn.decl.kind == 'func')
    fty = fn.decl.ty
    need(fty is not None and fty.kind == 'func' and is_void(fty.ret))
    need(re.search(r'\(\s*%s\s*\)' % ('int' if arg else 'void'), fty.spell or '') is not None)
    if xr:
        need(not getattr(fty, 'cdecl', False))                         # a __cdecl callee in a -Xr file
    return ('.' if xr else '_') + fn.decl.name


def classify_(f, xr):
    """-> (context, E, context data)"""
    # -Xr spells every register-argument function type with tlcs900_adecl (clang -mcc900-adecl); without -Xr an
    # explicit __adecl, and with it a missing one (an explicit __cdecl), is another calling convention
    need(bool(getattr(f, 'adecl_attr', False)) == xr)
    st = cg.flat(f.body)
    need(len(st) == 1)
    s = st[0]
    if s.k == 'return':
        need(is_int(f.ret) and s.value is not None)
        e = cg.strip(s.value)
        if e.k == 'bin' and e.op in ('/', '%') and cg.strip(e.r).k == 'const':
            v = const(e.r, 3, 127)
            need(not_pow2(v))
            return ('sd' if e.op == '/' else 'sm'), expression(e.l, f), v
        if e.k == 'bin' and e.op == '>>':
            return 'sr', expression(e.l, f), const(e.r, 1, 7)
        if e.k == 'bin' and e.op in ('+', '^', '*') and cg.strip(e.r).k == 'load' and is_int(cg.strip(e.r).ty):
            return {'+': 'pa', '^': 'xi', '*': 'ml'}[e.op], expression(e.l, f), gload(e.r, is_int)
        if e.k == 'un' and e.op == '-' and not is_operand(e.e, f):
            return 'ng', expression(e.e, f), None
        return 'ri', expression(e, f), None
    need(is_void(f.ret))
    if s.k == 'expr':
        e = cg.strip(s.e)
        if e.k == 'call':
            need(len(e.args) == 1)
            fn = callee(e.fn, xr, True)
            return 'ar', expression(e.args[0], f), fn
        need(e.k == 'bin' and e.op == '=')
        d = gvar(e.l)
        if is_int(d.ty):
            need(is_int(e.ty))
            return 'si', expression(e.r, f), gname(d)
        r = cg.strip(e.r)
        need(r.k == 'cast' and r.kind == 'IntegralCast' and not r.explicit)
        for C, size, sg in (('sl', 4, True), ('sc', 1, True), ('su', 2, False)):
            if is_ty(d.ty, size, sg):
                need(is_ty(e.ty, size, sg) and is_ty(r.ty, size, sg))
                return C, expression(r.e, f), gname(d)
        raise Decline()
    need(s.k == 'if' and getattr(s, 'els', None) is None)
    c = cg.strip(s.cond)
    need(c.k == 'bin' and c.op == '>' and is_int(c.ty))
    k = const(c.r, 1, 126)
    t = cg.flat(s.then)
    need(len(t) == 1 and t[0].k == 'expr')
    call = cg.strip(t[0].e)
    need(call.k == 'call' and not call.args)
    return 'cm', expression(c.l, f), (k, callee(call.fn, xr, False))


def classify(f, xr):
    C, e, cd = classify_(f, xr)
    if not (C in BASE_C and e.base()):                                 # chararith.c's grammar: globals only
        need(e.globals_only())
    return C, e, cd


# --------------------------------------------------------------------------------------------- code

def source(x, xr):
    """the char operand in memory -> (lines that compute its address, memory operand)"""
    if x.k in 'ge':
        return [], '(%s)' % x.m
    if x.k in 'pm':
        return ['ld XWA,(%s)' % x.ptr], '(XWA+%s)' % hx(x.off) if x.off else '(XWA)'
    if x.k == 'x':
        if xr:
            return ['lda XBC,%s' % x.arr], '(XBC+WA)'
        return ['lda XWA,%s' % x.arr, 'ld BC,(XSP+0x4)', 'extz XBC', 'add XBC,XWA'], '(XBC)'
    if x.k == 'r':
        return [], '(XSP+%s)' % hx(x.slot)
    raise Decline()


def unary(e, r):
    """the byte operation of a one-operand E on register r"""
    op, v, sg = e.op, e.v, e.x.signed
    if op == 'ng':
        return 'neg %s' % r
    if op == 'cp':
        return 'cpl %s' % r
    if op == 'sh':
        return '%s %s,%s' % ('sla' if sg else 'sll', hx(v), r)
    if op == 'ak':
        return ('inc %s,%s' if v <= 8 else 'add %s,%s') % ((hx(v), r) if v <= 8 else (r, hx(v)))
    raise Decline()


def wide(e, C):
    """the 16-bit product in WA is the value (no extension): a signed product in the int contexts, an unsigned one
    stored to an unsigned int"""
    if not e.prod:
        return False
    if e.sg:
        return C in ('si', 'pa', 'ar', 'xi', 'ml')
    return C == 'su'


def tail_a(C, e, cd, F):
    """the context on the char value in A (in WA, when wide)"""
    sg = e.sg
    ext = 'exts' if sg else 'extz'
    w = [] if wide(e, C) else ['%s WA' % ext]
    if C == 'ri':
        return ['ld L,A', '%s HL' % ext, 'ret']
    if C == 'si':
        return w + ['ld (%s),WA' % cd, 'ret']
    if C == 'sc':
        return ['ld (%s),A' % cd, 'ret']
    if C == 'su':
        return w + ['ld (%s),WA' % cd, 'ret']
    if C in ('sd', 'sm'):
        return ['%s WA' % ext, '%s WA,%s' % ('divs' if sg else 'div', hx(cd)), 'ld L,%s' % ('A' if C == 'sd' else 'W'),
                '%s HL' % ext, 'ret']
    if C == 'sr':
        return ['%s %s,A' % ('sra' if sg else 'srl', hx(cd)), 'ld L,A', '%s HL' % ext, 'ret']
    if C == 'cm':
        return ['cp A,%s' % hx(cd[0]), 'ret %s' % ('le' if sg else 'ule'), 'cal %s' % cd[1], 'L1:', 'ret']
    if C == 'sl':
        x = ['exts WA', 'exts XWA'] if sg else ['ld W,0x0', 'extz XWA']
        return x + ['ld (%s),XWA' % cd, 'ret']
    if C in ('pa', 'xi'):
        op = 'add' if C == 'pa' else 'xor'
        if F.opt:
            return w + ['%s WA,(%s)' % (op, cd), 'ld HL,WA', 'ret']
        return w + ['ld HL,WA', '%s HL,(%s)' % (op, cd), 'ret']
    if C == 'ml':
        return w + ['muls XWA,(%s)' % cd, 'ld HL,WA', 'ret']
    if C == 'ar':
        if F.xr:
            return w + ['j %s' % cd]
        return w + ['push WA', 'cal %s' % cd, 'inc 0x2,XSP', 'ret']
    if C == 'ng':
        return ['neg A', 'ld L,A', '%s HL' % ext, 'ret']
    raise Decline()


def tail_r(C, e, cd, R, P):
    """-O3 -XS -Xr: the context on a char value in the parameter register R of pair P"""
    sg = e.sg
    ext = 'exts' if sg else 'extz'
    wd = e.prod and sg and C in ('si', 'ri')
    if C == 'ri':
        return ['ld HL,%s' % P, 'ret'] if wd else ['ld L,%s' % R, '%s HL' % ext, 'ret']
    if C == 'si':
        return ([] if wd else ['%s %s' % (ext, P)]) + ['ld (%s),%s' % (cd, P), 'ret']
    if C == 'sd':
        return ['%s %s' % (ext, P), '%s %s,%s' % ('divs' if sg else 'div', P, hx(cd)), 'ld L,%s' % R,
                '%s HL' % ext, 'ret']
    if C == 'sr':
        return ['%s %s,%s' % ('sra' if sg else 'srl', hx(cd), R), 'ld L,%s' % R, '%s HL' % ext, 'ret']
    if C == 'cm':
        return ['cp %s,%s' % (R, hx(cd[0])), 'ret %s' % ('le' if sg else 'ule'), 'cal %s' % cd[1], 'L1:', 'ret']
    if C == 'sl':
        w = ['exts %s' % P, 'exts X%s' % P] if sg else ['ld %s,0x0' % P[0], 'extz X%s' % P]
        return w + ['ld (%s),X%s' % (cd, P), 'ret']
    raise Decline()


def compute(e, F, load, reg):
    """the E's code from `load % reg` (reg A, or L for the L form)"""
    sg = e.sg
    pair16 = 'HL' if reg == 'L' else 'WA'
    if e.op == 'mk':
        return [load % reg, '%s %s,%s' % ('muls' if sg else 'mul', pair16, hx(e.v))]
    if e.op in UNARY:
        return [load % reg, unary(e, reg)]
    y = '(%s)' % e.y.m
    if e.op == 'mul':
        return [load % reg, '%s %s,%s' % ('muls' if sg else 'mul', pair16, y)]
    if e.op in ('add', 'sub'):
        return [load % reg, '%s %s,%s' % (e.op, reg, y)]
    if e.op == 'div':
        return [load % reg, 'exts WA', 'divs WA,%s' % y]
    raise Decline()


def l_form(e, F):
    """returned as an int, the value is computed in L: not for an operation that needs WA (an unsigned or mixed
    product, the division), nor for x + K without -O"""
    if e.op in ('mk', 'mul'):
        return e.sg
    if e.op == 'div':
        return False
    if e.op == 'ak':
        return F.opt
    return True


def body_from(C, e, cd, F, load):
    """the A / L forms from a byte that `load % reg` puts into reg"""
    ext = 'exts' if e.sg else 'extz'
    if C == 'ri' and l_form(e, F):
        out = compute(e, F, load, 'L')
        return out + (['ret'] if e.prod else ['%s HL' % ext, 'ret'])
    if C == 'ng' and e.op == 'ng':                                     # -(-x) cancels
        return [load % 'L', '%s HL' % ext, 'ret']
    return compute(e, F, load, 'A') + tail_a(C, e, cd, F)


def mem_body(C, e, cd, F):
    """an operand in memory (globals, elements, pointers, members, a cdecl parameter)"""
    x = e.x
    ext = 'exts' if x.signed else 'extz'
    pre, M = source(x, F.xr)
    if e.op == 'sh' and e.v == 1 and x.k == 'r':                       # a parameter's << 1 is x + x
        if C == 'ri':
            if F.opt:
                return ['ld A,%s' % M, 'ld L,A', 'add L,A', '%s HL' % ext, 'ret']
            return ['ld L,%s' % M, 'add L,%s' % M, '%s HL' % ext, 'ret']
        if F.opt:
            return ['ld C,%s' % M, 'ld A,C', 'add A,C'] + tail_a(C, e, cd, F)
        return ['ld A,%s' % M, 'add A,%s' % M] + tail_a(C, e, cd, F)
    return pre + body_from(C, e, cd, F, 'ld %%s,%s' % M)


def reg_body(C, e, cd, F):
    """-Xr: the char parameter in its register (chararith2.c's grammar only)"""
    sg = e.sg
    ext = 'exts' if sg else 'extz'
    R, P = e.x.reg, e.x.pair
    if e.op == 'sh' and e.v == 1:                                      # x + x, in A (L when returned)
        if C == 'ri':
            return ['ld L,%s' % R, 'add L,%s' % R, '%s HL' % ext, 'ret']
        return ['ld A,%s' % R, 'add A,%s' % R] + tail_a(C, e, cd, F)
    if F.opt:                                                          # -O3: computed in place, the context too
        if e.op == 'mk':
            return ['%s %s,%s' % ('muls' if sg else 'mul', P, hx(e.v))] + tail_r(C, e, cd, R, P)
        return [unary(e, R)] + tail_r(C, e, cd, R, P)
    if e.op == 'mk':                                                   # without -O: copied to A (L), as from memory
        return body_from(C, e, cd, F, 'ld %%s,%s' % R)
    out = [unary(e, R)]
    if C == 'ri':
        return out + ['ld L,%s' % R, '%s HL' % ext, 'ret']
    if C == 'cm':
        return out + ['cp %s,%s' % (R, hx(cd[0])), 'ret %s' % ('le' if sg else 'ule'), 'cal %s' % cd[1], 'L1:', 'ret']
    if C == 'sl' and not sg:
        return out + ['ld XWA,0x0', 'ld A,%s' % R, 'ld (%s),XWA' % cd, 'ret']
    return out + ['ld A,%s' % R] + tail_a(C, e, cd, F)


class Frame:
    def __init__(self, s):
        self.s = s
        self.xr = s.endswith('Xr')
        self.opt = s.startswith('O3')


def whole_(f, s):
    F = Frame(s)
    C, e, cd = classify(f, F.xr)
    if e.x.k == 'r' and F.xr:
        return reg_body(C, e, cd, F)
    return mem_body(C, e, cd, F)


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

RUNS = os.path.expanduser('~/compartilhado/cc900-oracle/runs/')
PROBES = {   # probe -> (source, from scripts/analysis/cc900 as score.py runs; oracle listing; its global names)
    'chararith': ('corpus/probes/chararith.c', RUNS + '2026-11-13-8-micro-chararith/out/v423/%s/probes/chararith.asm',
                  'gc hc gc2 guc huc gi gu gl v0 v1'.split()),
    'chararith2': ('corpus/probes/chararith2.c',
                   RUNS + '2026-11-13-10-micro-chararith2/out/v423/%s/probes/chararith2.asm',
                   'gc gca gp guc guca gup gps gi gl v0'.split()),
}


def check(s, show=0, only=None, probe='chararith', src=None, rename=False):
    import frontend
    import listing
    psrc, oracle, names = PROBES[probe]
    want = listing.split(open(oracle % s, encoding='latin-1').read())
    unit = frontend.load(src or psrc, [], [], adecl=s.endswith('Xr'))
    srx = re.compile(r'(?<!\w)([_.])(%s)\b' % '|'.join(names))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        if rename:
            W = [srx.sub(lambda m: '%sx_%s_q' % (m.group(1), m.group(2)), l) for l in W]
        got = whole(f, s)
        fam = f.name[:5] if probe == 'chararith2' else f.name[-2:]
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
    print('%-10s %-7s exact %4d  wrong %4d  declined %4d   %s' % (probe, s, ok, wrong, dec,
          ' '.join('%s %d/%d/%d' % (k, *v) for k, v in sorted(fams.items()))))
    return ok, wrong, dec


def write_renamed(probe, out):
    psrc, _, names = PROBES[probe]
    src = open(psrc).read()
    rx = re.compile(r'\b(%s)\b' % '|'.join(names))
    open(out, 'w').write(rx.sub(lambda m: 'x_%s_q' % m.group(1), src))


if __name__ == '__main__':
    a = sys.argv[1:]
    probe = a[a.index('--probe') + 1] if '--probe' in a else 'chararith'
    if a and a[0] == '--rename':
        write_renamed(probe, a[1])
        for s in SETS:
            check(s, probe=probe, src=a[1], rename=True)
    elif a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, probe)
