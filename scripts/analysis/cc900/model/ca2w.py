#!/usr/bin/env python3
"""chararith2_ast.py -- the cc900 V4.23 oracle's code for the functions of probe chararith2.c
(corpus/probes/chararith2.c, oracle run 2026-11-13-10-micro-chararith2) at four option sets, from the model's AST.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 chararith2_ast.py --check SET [--show N] [--only REGEX] [--probe PATH]
        score against the oracle listing (exact / wrong / declined); run from scripts/analysis/cc900 with the
        model directory on sys.path.  --probe compiles another copy of the probe (a renamed one: --rename)
    python3 chararith2_ast.py --rename OUT.c
        write a copy of the probe with every global renamed (x_<name>_q) and check it against the oracle listing
        renamed the same way in memory

The probe's functions are `f(int a, char pc, unsigned char puc)` with one statement, C(E):

    E  -x   x << k (k 1..7)   x * K   ~x   x + K       (x a char or unsigned char, promoted to int)
    x  gc / guc (a global), gca[2] (an element at a constant), gca[a] (an element at the int parameter),
       *gp (through a char pointer), gps->c (a member through a struct pointer), pc / puc (the char parameter)
    C  gi = E;   return E;   return E / D;   return E >> R;   if (E > K) v0();   gl = E;

The function is classified from its AST alone (operator, operand kind, symbols, offsets, constants and the
parameter it reads); the real symbols, offsets and constants are substituted.  Anything outside the probe's grammar
returns None.  The rules are in chararith2-FAMILIES.md beside this file.
"""
import os
import re
import sys

import codegen as cg  # noqa: E402

SETS = ('none', 'O3XS', 'Xr', 'O3XSXr')


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


# --------------------------------------------------------------------------------------------- classification

class X:
    """the char operand.  k: g e x p m r; signed; plus per kind
    m (g e: memory operand text without parentheses), arr (x), ptr / off (p m), reg / pair / slot (r)"""

    def __init__(self, k, signed, **kw):
        self.k, self.signed = k, signed
        self.__dict__.update(kw)


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
            return X('g', sg, m=gname(d))
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


def expression(n, f):
    """E -> (op, x, constant): op ng cp sh mk ak"""
    n = cg.strip(n)
    need(is_int(n.ty))
    if n.k == 'un' and n.op in ('-', '~'):
        return ('ng' if n.op == '-' else 'cp'), operand(n.e, f), None
    need(n.k == 'bin')
    if n.op == '<<':
        return 'sh', operand(n.l, f), const(n.r, 1, 7)
    if n.op == '*':
        v = const(n.r, 3, 127)
        need(not_pow2(v))
        return 'mk', operand(n.l, f), v
    if n.op == '+':
        return 'ak', operand(n.l, f), const(n.r, 1, 8)
    raise Decline()


def probe_signature(f):
    """(int a, char pc, unsigned char puc): an element at a or a char parameter is read only with these (its stack
    slot and argument register come from it); a global operand takes any parameters, which it does not read"""
    need(len(f.params) == 3 and is_int(f.params[0].ty) and is_ty(f.params[1].ty, 1, True) and
         is_ty(f.params[2].ty, 1, False))


def classify(f, xr):
    """-> (context, (op, x, constant), context data)"""
    # -Xr spells every register-argument function type with tlcs900_adecl (clang -mcc900-adecl); without -Xr an
    # explicit __adecl, and with it a missing one (an explicit __cdecl), is another calling convention
    need(bool(getattr(f, 'adecl_attr', False)) == xr)
    st = cg.flat(f.body)
    need(len(st) == 1)
    s = st[0]
    if s.k == 'return':
        need(is_int(f.ret) and s.value is not None)
        e = cg.strip(s.value)
        if e.k == 'bin' and e.op == '/':
            v = const(e.r, 3, 127)
            need(not_pow2(v))
            return 'sd', expression(e.l, f), v
        if e.k == 'bin' and e.op == '>>':
            return 'sr', expression(e.l, f), const(e.r, 1, 7)
        return 'ri', expression(e, f), None
    need(is_void(f.ret))
    if s.k == 'expr':
        e = cg.strip(s.e)
        need(e.k == 'bin' and e.op == '=')
        d = gvar(e.l)
        if is_int(d.ty):
            need(is_int(e.ty))
            return 'si', expression(e.r, f), gname(d)
        need(is_ty(d.ty, 4, True) and is_ty(e.ty, 4, True))
        r = cg.strip(e.r)
        need(r.k == 'cast' and r.kind == 'IntegralCast' and not r.explicit and is_ty(r.ty, 4, True))
        return 'sl', expression(r.e, f), gname(d)
    need(s.k == 'if' and getattr(s, 'els', None) is None)
    c = cg.strip(s.cond)
    need(c.k == 'bin' and c.op == '>' and is_int(c.ty))
    k = const(c.r, 1, 126)
    t = cg.flat(s.then)
    need(len(t) == 1 and t[0].k == 'expr')
    call = cg.strip(t[0].e)
    need(call.k == 'call' and not call.args)
    fn = cg.strip(call.fn)
    if fn.k == 'cast':
        need(fn.kind == 'FunctionToPointerDecay')
        fn = cg.strip(fn.e)
    need(fn.k == 'var' and fn.decl.kind == 'func')
    fty = fn.decl.ty
    need(fty is not None and fty.kind == 'func' and is_void(fty.ret))
    need(re.search(r'\(\s*void\s*\)', fty.spell or '') is not None)
    if xr:
        need(not getattr(fty, 'cdecl', False))                         # a __cdecl callee in a -Xr file
    return 'cm', expression(c.l, f), (k, ('.' if xr else '_') + fn.decl.name)


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


def unary(op, v, sg, r):
    """the byte operation on register r"""
    if op == 'ng':
        return 'neg %s' % r
    if op == 'cp':
        return 'cpl %s' % r
    if op == 'sh':
        return '%s %s,%s' % ('sla' if sg else 'sll', hx(v), r)
    if op == 'ak':
        return 'inc %s,%s' % (hx(v), r)
    raise Decline()


def tail_a(C, sg, cd, wide=False):
    """the context on a char value in A (wide: a signed product, an int in WA)"""
    ext = 'exts' if sg else 'extz'
    if C == 'si':
        return ([] if wide else ['%s WA' % ext]) + ['ld (%s),WA' % cd, 'ret']
    if C == 'sd':
        return ['%s WA' % ext, '%s WA,%s' % ('divs' if sg else 'div', hx(cd)), 'ld L,A', '%s HL' % ext, 'ret']
    if C == 'sr':
        return ['%s %s,A' % ('sra' if sg else 'srl', hx(cd)), 'ld L,A', '%s HL' % ext, 'ret']
    if C == 'cm':
        return ['cp A,%s' % hx(cd[0]), 'ret %s' % ('le' if sg else 'ule'), 'cal %s' % cd[1], 'L1:', 'ret']
    if C == 'sl':
        w = ['exts WA', 'exts XWA'] if sg else ['ld W,0x0', 'extz XWA']
        return w + ['ld (%s),XWA' % cd, 'ret']
    raise Decline()


def tail_r(C, sg, cd, R, P, wide=False):
    """-O3 -XS -Xr: the context on a char value in the parameter register R of pair P"""
    ext = 'exts' if sg else 'extz'
    if C == 'ri':
        return ['ld HL,%s' % P, 'ret'] if wide else ['ld L,%s' % R, '%s HL' % ext, 'ret']
    if C == 'si':
        return ([] if wide else ['%s %s' % (ext, P)]) + ['ld (%s),%s' % (cd, P), 'ret']
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


def mem_body(C, op, x, v, cd, F):
    """an operand in memory (globals, elements, pointers, members, a cdecl parameter)"""
    sg = x.signed
    ext = 'exts' if sg else 'extz'
    pre, M = source(x, F.xr)
    if op == 'sh' and v == 1 and x.k == 'r':                           # a parameter's << 1 is x + x
        if C == 'ri':
            if F.opt:
                return ['ld A,%s' % M, 'ld L,A', 'add L,A', '%s HL' % ext, 'ret']
            return ['ld L,%s' % M, 'add L,%s' % M, '%s HL' % ext, 'ret']
        if F.opt:
            return ['ld C,%s' % M, 'ld A,C', 'add A,C'] + tail_a(C, sg, cd)
        return ['ld A,%s' % M, 'add A,%s' % M] + tail_a(C, sg, cd)
    return pre + body_from(C, op, sg, v, cd, F, 'ld %%s,%s' % M)


def body_from(C, op, sg, v, cd, F, load):
    """the A / L forms from a byte that `load % reg` puts into reg"""
    ext = 'exts' if sg else 'extz'
    if op == 'mk':
        if C == 'ri' and sg:
            return [load % 'L', 'muls HL,%s' % hx(v), 'ret']
        if C == 'ri':
            return [load % 'A', 'mul WA,%s' % hx(v), 'ld L,A', 'extz HL', 'ret']
        return [load % 'A', '%s WA,%s' % ('muls' if sg else 'mul', hx(v))] + tail_a(C, sg, cd, wide=sg)
    if C == 'ri':
        if op == 'ak' and not F.opt:                                   # x + K returned: the A form without -O
            return [load % 'A', unary(op, v, sg, 'A'), 'ld L,A', '%s HL' % ext, 'ret']
        return [load % 'L', unary(op, v, sg, 'L'), '%s HL' % ext, 'ret']
    return [load % 'A', unary(op, v, sg, 'A')] + tail_a(C, sg, cd)


def reg_body(C, op, x, v, cd, F):
    """-Xr: the char parameter in its register"""
    sg = x.signed
    ext = 'exts' if sg else 'extz'
    R, P = x.reg, x.pair
    if op == 'sh' and v == 1:                                          # x + x, in A (L when returned)
        if C == 'ri':
            return ['ld L,%s' % R, 'add L,%s' % R, '%s HL' % ext, 'ret']
        return ['ld A,%s' % R, 'add A,%s' % R] + tail_a(C, sg, cd)
    if F.opt:                                                          # -O3: computed in place, the context too
        if op == 'mk':
            return ['%s %s,%s' % ('muls' if sg else 'mul', P, hx(v))] + tail_r(C, sg, cd, R, P, wide=sg and C in ('si', 'ri'))
        return [unary(op, v, sg, R)] + tail_r(C, sg, cd, R, P)
    if op == 'mk':                                                     # without -O: copied to A (L), as from memory
        return body_from(C, op, sg, v, cd, F, 'ld %%s,%s' % R)
    out = [unary(op, v, sg, R)]
    if C == 'ri':
        return out + ['ld L,%s' % R, '%s HL' % ext, 'ret']
    if C == 'cm':
        return out + ['cp %s,%s' % (R, hx(cd[0])), 'ret %s' % ('le' if sg else 'ule'), 'cal %s' % cd[1], 'L1:', 'ret']
    if C == 'sl' and not sg:
        return out + ['ld XWA,0x0', 'ld A,%s' % R, 'ld (%s),XWA' % cd, 'ret']
    return out + ['ld A,%s' % R] + tail_a(C, sg, cd)


class Frame:
    def __init__(self, s):
        self.s = s
        self.xr = s.endswith('Xr')
        self.opt = s.startswith('O3')


def whole_(f, s):
    F = Frame(s)
    C, (op, x, v), cd = classify(f, F.xr)
    if x.k == 'r' and F.xr:
        return reg_body(C, op, x, v, cd, F)
    return mem_body(C, op, x, v, cd, F)


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

ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-10-micro-chararith2/out/v423/%s/probes/chararith2.asm')
PROBE = 'corpus/probes/chararith2.c'               # --check runs from scripts/analysis/cc900, as score.py does
NAMES = 'gc gca gp guc guca gup gps gi gl v0'.split()


def check(s, show=0, only=None, probe=PROBE, rename=False):
    import frontend
    import listing
    want = listing.split(open(ORACLE % s, encoding='latin-1').read())
    unit = frontend.load(probe, [], [], adecl=s.endswith('Xr'))
    srx = re.compile(r'(?<!\w)([_.])(%s)\b' % '|'.join(NAMES))
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
        fam = f.name[:5]
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


def write_renamed(out):
    src = open(PROBE).read()
    rx = re.compile(r'\b(%s)\b' % '|'.join(NAMES))
    open(out, 'w').write(rx.sub(lambda m: 'x_%s_q' % m.group(1), src))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--rename':
        write_renamed(a[1])
        for s in SETS:
            check(s, probe=a[1], rename=True)
    elif a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        probe = a[a.index('--probe') + 1] if '--probe' in a else PROBE
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only, probe)
