#!/usr/bin/env python3
"""cmpx_ast.py -- the cc900 oracle's code for the functions of probe cmpx.c (corpus/probes/cmpx.c, oracle run
2026-11-13-4-micro-cmpx), at four option sets, from the model's AST of each function.

    whole(f, set) -> [listing lines after the function label] or None
    set: 'none' (cdecl), 'O3XS' (cdecl -O3 -XS), 'Xr' (register arguments), 'O3XSXr'

    python3 cmpx_ast.py --check SET [--show N] [--only REGEX]    score against the oracle listing (exact / wrong /
                                                                 declined); run with the model directory on sys.path

The function is classified from its AST alone (the operand kinds, their types, the parameters and locals); the
real symbols, member offsets and element offsets are used.  Anything outside the probe's shapes returns None.
The rules are in cmpx-FAMILIES.md beside this file.
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


# --------------------------------------------------------------------------------------------- types and operands

def tl(ty):
    """type letter: c char, b unsigned char, i int, u unsigned int, l long, n unsigned long"""
    if ty is None or ty.kind != 'int':
        return None
    return {(1, True): 'c', (1, False): 'b', (2, True): 'i', (2, False): 'u', (4, True): 'l', (4, False): 'n'}.get(
        (ty.size, ty.signed))


ES = {'c': 1, 'b': 1, 'i': 2, 'u': 2, 'l': 4, 'n': 4}
SIGNED = {'c': True, 'i': True, 'l': True, 'b': False, 'u': False, 'n': False}
LOW = {'WA': 'A', 'BC': 'C', 'DE': 'E', 'HL': 'L'}


def hx(v):
    return '0x%x' % v


def symoff(sym, off):
    return sym if not off else '%s + %s' % (sym, hx(off))


def rw(p, w):
    """register pair p at width w bytes"""
    need(p is not None)
    if w == 1:
        need(p in LOW)
        return LOW[p]
    return p if w == 2 else 'X' + p


def disp(p, off):
    return '(X%s)' % p if not off else '(X%s+%s)' % (p, hx(off))


class Op:
    """an operand: kind letter + attributes
    G sym              a global scalar                         (gc)
    R prm              a parameter                             (r)
    E sym off          a global object at a constant offset    (gca[3], gs.mc)
    D ptr off          a member through a global pointer        (gps->mc)
    X arr prm          an element of a global array at a parameter index      (hca[c])
    Y arr loc          an element of a global array at a local's index        (hca[v], v = gc)
    P ptr off          a global pointer's target at a constant offset         (*hcp, hcp[2], hps->ac[4])
    A ptr off prm      an array member through a global pointer, at a parameter index   (hps->ac[c])
    T loc off          a local pointer's target at a constant offset           (v[1], v = hcp)"""

    def __init__(self, k, t, **kw):
        self.k, self.t = k, t
        self.__dict__.update(kw)

    def __repr__(self):
        return 'Op(%s %s %s)' % (self.k, self.t, {k: v for k, v in self.__dict__.items() if k not in ('k', 't')})


def var_of(n):
    n = cg.strip(n)
    return n.decl if n.k == 'var' else None


def unc(n):
    """strip implicit integral casts (promotions)"""
    n = cg.strip(n)
    while n.k == 'cast' and n.kind == 'IntegralCast' and not n.explicit:
        n = cg.strip(n.e)
    return n


def gname(d):
    return '_' + d.name


def global_ptr(x):
    """load of a global pointer variable -> its decl"""
    x = cg.strip(x)
    if x.k == 'load':
        d = var_of(x.e)
        if d is not None and d.kind == 'global' and d.ty is not None and d.ty.kind == 'ptr':
            return d
    return None


def global_array(b):
    b = cg.strip(b)
    if b.k == 'var' and b.decl.kind == 'global' and b.decl.ty is not None and b.decl.ty.kind == 'array':
        return b.decl
    return None


def index_var(i):
    """an index expression that is a parameter or local read -> (decl, type letter)"""
    i = unc(i)
    if i.k == 'load':
        d = var_of(i.e)
        if d is not None and d.kind in ('param', 'local'):
            return d, tl(d.ty)
    return None, None


def const_of(n):
    c = cg.fold(unc(n))
    if c.k == 'const' and c.value is not None:
        return c.value
    return None


def lvalue(x, t):
    """classify an lvalue node x whose value has type letter t"""
    x = cg.strip(x)
    if x.k == 'var':
        d = x.decl
        if d.kind == 'global':
            return Op('G', t, sym=gname(d))
        if d.kind == 'param':
            return Op('R', t, prm=d)
        if d.kind == 'local':
            return Op('V', t, loc=d)
        raise Decline()
    if x.k == 'member':
        if x.arrow:
            p = global_ptr(x.base)
            need(p is not None)
            return Op('D', t, ptr=gname(p), off=cg.member_offset(x))
        d = var_of(x.base)
        need(d is not None and d.kind == 'global')
        return Op('E', t, sym=gname(d), off=cg.member_offset(x))
    if x.k == 'deref':
        p = global_ptr(x.e)
        if p is not None:
            return Op('P', t, ptr=gname(p), off=0)
        raise Decline()
    if x.k == 'index':
        es = ES[t]
        b = cg.strip(x.base)
        k = const_of(x.idx)
        a = global_array(b)
        if a is not None:
            if k is not None:
                return Op('E', t, sym=gname(a), off=k * es)
            d, it = index_var(x.idx)
            need(d is not None and it is not None)
            if d.kind == 'param':
                return Op('X', t, sym=gname(a), prm=d, it=it)
            return Op('Y', t, sym=gname(a), loc=d, it=it)
        p = global_ptr(b)
        if p is not None:
            need(k is not None)
            return Op('P', t, ptr=gname(p), off=k * es)
        if b.k == 'member' and b.arrow:                    # hps->ac[k] / hps->ac[c]
            p = global_ptr(b.base)
            need(p is not None)
            mo = cg.member_offset(b)
            if k is not None:
                return Op('P', t, ptr=gname(p), off=mo + k * es)
            d, it = index_var(x.idx)
            need(d is not None and d.kind == 'param' and it is not None)
            return Op('A', t, ptr=gname(p), off=mo, prm=d, it=it)
        if b.k == 'load':
            d = var_of(b.e)
            if d is not None and d.kind == 'local':
                need(k is not None)
                return Op('T', t, loc=d, off=k * es)
        raise Decline()
    raise Decline()


def rvalue(n):
    """an operand read: load of an lvalue (implicit promotions stripped) -> Op; an explicit integral cast of one
    -> Op('C', target type, src=Op)"""
    n = unc(n)
    if n.k == 'cast' and n.kind == 'IntegralCast' and n.explicit:
        d = tl(n.ty)
        need(d is not None)
        src = rvalue(n.e)
        need(src.k != 'C')
        return Op('C', d, src=src)
    need(n.k == 'load')
    t = tl(n.ty)
    need(t is not None)
    return lvalue(n.e, t)


# --------------------------------------------------------------------------------------------- function frame

class Frame:
    """parameters and locals of the function, as the set sees them"""

    def __init__(self, f, s):
        self.f, self.s = f, s
        self.xr = s.endswith('Xr')
        self.opt = s.startswith('O3')
        self.preg = {}                                    # param decl -> register pair (Xr)
        self.poff = {}                                    # param decl -> stack offset (cdecl)
        off = 4
        regs = ['WA', 'BC', 'DE']
        for p in f.params:
            t = tl(p.ty)
            if t is None and p.ty is not None and p.ty.kind == 'ptr':
                t = 'p'
            need(t is not None)
            w = 4 if t in 'lnp' else 2
            if self.xr:
                need(regs)
                self.preg[p] = regs.pop(0)
            else:
                self.poff[p] = off
                off += w
        self.locals = {}                                  # local decl -> init node
        self.ctx = ''                                     # '' or 'loop': the compare is a loop test
        self.override = None                              # (fitting) the roles to use instead of the tables
        self.keys = []
        self.iz = False                                   # the code keeps a value in IZ across a call
        self.frame = False                                # ... and one more in a frame slot
        self.labels = Labels()

    def roles(self, table, key, col):
        """the register roles for a generator key: EXTRA_ROLES[<set>/<ctx>/<key>] first (cz's loop tests and the
        compares outside the probe's own families), else the family table (not for loops)"""
        self.keys.append(key)
        _KEYS.append('%s#%d' % (key, col))
        globals()['_CTX'] = self.ctx
        if self.override is not None:
            return self.override
        if _FRAME_HOOK is not None:
            return _FRAME_HOOK
        x = EXTRA_ROLES.get('%s/%s/%s#%d' % (self.s, self.ctx, key, col))
        if x is not None:
            return roles(x)
        need(self.ctx == '')
        row = table.get('%s/%s' % (self.s, key))
        need(row is not None and row[col] != '-')
        return roles(row[col])

    def pmem(self, p, w=None):
        """a parameter's memory operand (cdecl)"""
        return '(XSP+%s)' % hx(self.poff[p])

    def preg_w(self, p, w):
        return rw(self.preg[p], w)


def param_at(F, prm, idx):
    """the probe's layouts only: a parameter the code reads sits where the probe has it"""
    need(prm in F.f.params and F.f.params.index(prm) == idx)


def params_used(F, ops):
    """the parameters the operands read sit where the probe has them: r (an R operand) first; the index c of an X
    or A operand second after r or the char index of a cast compare (cc), else first and alone; at most two"""
    need(len(F.f.params) <= 2)
    r = any(o.k == 'R' for o in ops)
    for o in ops:
        if o.k == 'R':
            param_at(F, o.prm, 0)
        if o.k == 'X':
            pos = 1 if r or getattr(o, 'cc', False) else 0
            param_at(F, o.prm, pos)
            need(len(F.f.params) == pos + 1)
        if o.k == 'A':
            param_at(F, o.prm, 1)


def left_disp_ok(L):
    """a member through a pointer as the probe has it: displacement 0 only for char (gps->mc)"""
    if L.k == 'D':
        need((L.off == 0) == (L.t == 'c'))


def body_parts(f):
    """(local decls [(decl, init)], the statements after them)"""
    st = cg.flat(f.body)
    decls = []
    while st and st[0].k == 'decl':
        decls.append((st[0].var, st[0].init))
        st = st[1:]
    return decls, st


# --------------------------------------------------------------------------------------------- cx: L op h[idx]

def copy(dst, src, w):
    return [] if dst == src else ['ld %s,%s' % (rw(dst, w), rw(src, w))]


def double8(h, i):
    """an 8-bit h + h into i: `ld i,h / add i,h`, or through A when i is h itself"""
    if i != h:
        return ['ld %s,%s' % (rw(i, 1), rw(h, 1)), 'add %s,%s' % (rw(i, 1), rw(h, 1))]
    return ['ld A,%s' % rw(h, 1), 'add A,%s' % rw(h, 1), 'ld %s,A' % rw(h, 1)]


def scale(r, es, w):
    if es == 2:
        return ['add %s,%s' % (rw(r, w), rw(r, w))]
    return ['%s 0x2,%s' % ('sll' if w == 4 else 'sla', rw(r, w))]


def index_path(es, x, h, i, b, base, opt, keep=False):
    """the element address from an index value of type x held in register h -> (lines, address operand)"""
    lda = 'lda X%s,%s' % (b, base)
    if es == 1:
        if x == 'c':
            return [lda], '(X%s+%s)' % (b, rw(h, 1))
        if x == 'b':
            return copy(i, h, 1) + ['extz %s' % i, lda], '(X%s+%s)' % (b, i)
        if x == 'i':
            return [lda], '(X%s+%s)' % (b, h)
        return copy(i, h, 2) + ['extz X%s' % i, 'ld X%s,%s' % (b, base), 'add X%s,X%s' % (b, i)], '(X%s)' % b
    if x == 'c':
        L = double8(h, i) if es == 2 else ['sla 0x2,%s' % rw(h, 1)] + copy(i, h, 1)
        return L + [lda], '(X%s+%s)' % (b, rw(i, 1))
    if x == 'b':
        if opt or keep:                                   # (keep: h is a parameter still live, in a loop test)
            L = copy(i, h, 1) + ['extz %s' % i] + scale(i, es, 2)
        else:
            L = ['extz %s' % h] + copy(i, h, 2) + scale(i, es, 2)
        return L + [lda], '(X%s+%s)' % (b, i)
    if x == 'i':
        return copy(i, h, 2) + scale(i, es, 2) + [lda], '(X%s+%s)' % (b, i)
    return copy(i, h, 2) + ['extz X%s' % i] + scale(i, es, 4) + ['ld X%s,%s' % (b, base), 'add X%s,X%s' % (b, i)], \
        '(X%s)' % b


def left_mem(F, L, R):
    """the left operand's memory (or register) operand; D needs the pointer in R['p']"""
    if L.k == 'G':
        return '(%s)' % L.sym
    if L.k == 'E':
        return '(%s)' % symoff(L.sym, L.off)
    if L.k == 'R':
        return F.preg_w(L.prm, ES[L.t]) if F.xr else F.pmem(L.prm)
    if L.k == 'D':
        return disp(R['p'], L.off)
    raise Decline()


def index_code(F, S, R, locs, cse_with=None):
    """the address of an element at a variable index (kinds X / Y) -> (lines, address operand, cse); cse_with: the
    left operand when -O may fold the local index's load into its load.  Roles h i b (a for the folded load)."""
    t = S.t
    es = ES[t]
    x = S.it
    base = S.sym
    pre = []
    cse = False
    if S.k == 'X':
        if F.xr:
            h = F.preg[S.prm]
        elif es == 1 and x in 'ci':                       # a stack parameter as a byte-array index: 32-bit sum
            i, b = R['i'], R['b']
            P = F.pmem(S.prm)
            if x == 'c':
                if F.opt or i == 'WA':
                    body = ['lda X%s,%s' % (b, base), 'ld X%s,0x0' % i, 'ld %s,%s' % (rw(i, 1), P), 'add X%s,X%s' % (i, b)]
                else:
                    body = ['lda X%s,%s' % (b, base), 'ld A,%s' % P, 'ld X%s,0x0' % i, 'ld %s,A' % rw(i, 1),
                            'add X%s,X%s' % (i, b)]
            else:
                body = ['lda X%s,%s' % (b, base), 'ld %s,%s' % (i, P), 'extz X%s' % i, 'add X%s,X%s' % (i, b)]
            return body, '(X%s)' % i, False
        elif not F.opt and es == 2 and x == 'c':          # none: c + c straight from memory
            i, b = R['i'], R['b']
            P = F.pmem(S.prm)
            body = ['ld A,%s' % P, 'add A,%s' % P] + copy(i, 'WA', 1) + ['lda X%s,%s' % (b, base)]
            return body, '(X%s+%s)' % (b, rw(i, 1)), False
        else:
            h = 'WA' if (not F.opt and x in 'cb') else R['h']   # none: a byte parameter is read through A
            pre = ['ld %s,%s' % (rw(h, ES[x]), F.pmem(S.prm))]
    else:
        init = locs.get(S.loc)
        need(init is not None)
        src = rvalue(init)
        need(src.k == 'G' and src.t == x)
        h = R['h']
        L = cse_with
        if F.opt and L is not None and L.k == 'G' and L.sym == src.sym and L.t == x:
            cse = True                                    # -O: the local and the left operand are one load
            h = R['a']
        pre = ['ld %s,(%s)' % (rw(h, ES[x]), src.sym)]
    body, addr = index_path(es, x, h, R['i'], R['b'], base, F.opt, keep=F.ctx == 'loop' and S.k == 'X' and F.xr)
    return pre + body, addr, cse


def ptr_slot(F, local_first, seq):
    """where the left operand's pointer load goes: after the local's initialisation (an index local, a pointer
    local); -O3 -XS -Xr: after a leading copy of a parameter register; else first"""
    if local_first:
        return 1
    if F.s == 'O3XSXr' and param_copy(F, seq):
        return 1
    return 0


def param_copy(F, seq):
    """seq starts with `ld r,p`, p a parameter register that the next instruction does not read again (a copy of
    the parameter into its own register, not the first half of `ld r,p / add r,p`)"""
    if not seq:
        return False
    m = re.match(r'ld (\w+),(\w+)$', seq[0])
    regs = set()
    for p in F.preg.values():
        regs |= {p, 'X' + p, LOW.get(p)}
    if m is None or m.group(2) not in regs or m.group(1) in regs:
        return False
    return len(seq) < 2 or not re.search(r'[ ,]%s\b' % m.group(2), seq[1])


def cx_seq(F, L, S, op, R, locs):
    """the compare `L op S` with S an element at a variable index (kinds X / Y); R: the register roles
    p (pointer of D), h (the index value), i (the scaled index), b (the array base), a (the accumulator)"""
    w = ES[S.t]
    swap = op == '==' and L.k in 'DE'
    seq, addr, cse = index_code(F, S, R, locs, None if swap else L)
    a = R['a']
    if swap:
        seq += ['ld %s,%s' % (rw(a, w), addr), 'cp %s,%s' % (rw(a, w), left_mem(F, L, R))]
    elif F.xr and L.k == 'R':
        seq += ['cp %s,%s' % (F.preg_w(L.prm, w), addr)]
    elif cse:
        seq += ['cp %s,%s' % (rw(a, w), addr)]
    else:
        seq += ['ld %s,%s' % (rw(a, w), left_mem(F, L, R)), 'cp %s,%s' % (rw(a, w), addr)]
    if L.k == 'D':
        seq.insert(ptr_slot(F, S.k == 'Y', seq), 'ld X%s,(%s)' % (R['p'], L.ptr))
    return seq


# --------------------------------------------------------------------------------------------- cp: L op *(ptr + k)

def local_ptr_init(locs, d):
    """a local pointer initialised from a global pointer -> that pointer's symbol"""
    init = locs.get(d)
    need(init is not None)
    p = global_ptr(unc(init))
    need(p is not None)
    return gname(p)


def cp_seq(F, L, Q, op, R, locs):
    """the compare `L op Q` with Q read through a pointer (kinds P, D, A, T); roles: p pointer of a D left operand,
    q the right operand's pointer, h the index value, j the index sum, i its low byte, a the accumulator"""
    t = Q.t
    w = ES[t]
    swap = op == '==' and L.k in 'DE'
    q = R['q']
    if Q.k == 'A':
        es = ES[t]
        if F.xr:
            h = F.preg[Q.prm]
            pre = []
        else:
            h = R['h']
            pre = ['ld %s,%s' % (h, F.pmem(Q.prm))]
        need(Q.it == 'i')
        j, i = R['j'], R['i']
        body = pre + ([] if es == 1 else scale(h, es, 2)) + copy(j, h, 2) + ['add %s,%s' % (j, hx(Q.off))] + \
            copy(i, j, 1) + ['ld X%s,(%s)' % (q, Q.ptr)]
        addr = '(X%s+%s)' % (q, rw(i, 1))
    elif Q.k == 'T':
        body = ['ld X%s,(%s)' % (q, local_ptr_init(locs, Q.loc))]
        addr = disp(q, Q.off)
    else:
        body = ['ld X%s,(%s)' % (q, Q.ptr)]
        addr = disp(q, Q.off)
    a = R['a']
    seq = list(body)
    if swap:
        seq += ['ld %s,%s' % (rw(a, w), addr), 'cp %s,%s' % (rw(a, w), left_mem(F, L, R))]
    elif F.xr and L.k == 'R':
        seq += ['cp %s,%s' % (F.preg_w(L.prm, w), addr)]
    else:
        seq += ['ld %s,%s' % (rw(a, w), left_mem(F, L, R)), 'cp %s,%s' % (rw(a, w), addr)]
    if L.k == 'D':
        seq.insert(ptr_slot(F, Q.k == 'T', seq), 'ld X%s,(%s)' % (R['p'], L.ptr))
    return seq


# --------------------------------------------------------------------------------------------- cc: (d)K op O

def cast_load(src_mem, s, d, Q):
    """load a type-s operand into register pair Q and convert it to type d"""
    ws, wd = ES[s], ES[d]
    if wd > ws and ws == 1 and not SIGNED[s] and wd == 4:
        return ['ld X%s,0x0' % Q, 'ld %s,%s' % (rw(Q, 1), src_mem)]   # unsigned char to long: clear, then the byte
    out = ['ld %s,%s' % (rw(Q, ws), src_mem)]
    w = ws
    while w < wd:
        w = 2 if w == 1 else 4
        out.append('%s %s' % ('exts' if SIGNED[s] else 'extz', rw(Q, w)))
    return out


def cc_seq(F, C, O, side, R, locs):
    """C: the cast operand (kind C, .src the source operand, .t the target type); O the other operand (G R X);
    side 'l': the cast is the left operand.  Roles: a the cast's register, h i b the element index (as cx)"""
    d = C.t
    src = C.src
    need(src.k in 'GE')
    smem = '(%s)' % symoff(src.sym, src.off if src.k == 'E' else 0)
    if O.k == 'X':
        seq, other, _ = index_code(F, O, R, locs)
    elif O.k in 'GR':
        seq, other = [], left_mem(F, O, R)
    else:
        raise Decline()
    Q = R['a']
    seq = seq + cast_load(smem, src.t, d, Q)
    reg = rw(Q, ES[d])
    seq.append('cp %s,%s' % ((reg, other) if side == 'l' else (other, reg)))
    return seq

def cond_cc(op, t, neg):
    """the condition code of `op` on type letter t; neg: the inverted test"""
    sg = SIGNED[t]
    cc = {'<': ('lt', 'ult'), '>': ('gt', 'ugt'), '<=': ('le', 'ule'), '>=': ('ge', 'uge'), '==': ('eq', 'eq'),
          '!=': ('ne', 'ne')}
    inv = {'<': '>=', '>': '<=', '<=': '>', '>=': '<', '==': '!=', '!=': '=='}
    o = inv[op] if neg else op
    return cc[o][0 if sg else 1]


_FRAME_HOOK = None                                    # (fitting) roles for every lookup
_KEYS = []
_CTX = ''


def roles(s):
    out = {}
    for kv in s.split():
        k, v = kv.split('=')
        out[k] = int(v) if v.isdigit() else v
    return out


COL = {'c': 0, 'b': 1, 'i': 2, 'u': 2, 'l': 3, 'n': 3}


def gen_cx(F, L, S, op, locs):
    swap = op == '==' and L.k in 'DE'
    ctx = ('s' if swap else '') + L.k
    if L.k == 'G' and S.k == 'Y':
        init = locs.get(S.loc)
        need(init is not None)
        src = rvalue(init)
        if src.k == 'G' and src.sym == L.sym and src.t == L.t:
            ctx += '='
    need(L.t == S.t)
    left_disp_ok(L)
    params_used(F, [L, S])
    R = F.roles(CX_ROLES, 'cx/%s/%s/%s' % (ctx, S.k, S.it), COL[S.t])
    return cx_seq(F, L, S, op, R, locs)


def gen_cp(F, L, Q, op, locs):
    swap = op == '==' and L.k in 'DE'
    need(L.t == Q.t)
    left_disp_ok(L)
    params_used(F, [L, Q])
    if Q.k == 'A':
        need(len(F.f.params) == 2)
    R = F.roles(CP_ROLES, 'cp/%s%s/%s' % ('s' if swap else '', L.k, Q.k), COL[Q.t])
    return cp_seq(F, L, Q, op, R, locs)


COL6 = {'c': 0, 'b': 1, 'i': 2, 'u': 3, 'l': 4, 'n': 5}


def gen_cc(F, C, O, side, op, locs):
    need(O.t == C.t)
    O.cc = O.k == 'X' and O.it == 'c'                    # (the probe's cc: r first, the char index c second)
    params_used(F, [O])
    need(op == '<' or (op == '!=' and side == 'l'))
    R = F.roles(CC_ROLES, 'cc/%s%s%s%s/%s' % (O.k, side, (':' + O.it) if O.k == 'X' and O.it != 'c' else '',
                                         '' if op == '<' else op, C.src.t),
                COL6[C.t])
    return cc_seq(F, C, O, side, R, locs)


# --------------------------------------------------------------------------------------------- cq: computed operands

class Ex:
    """a computed compare operand: F f(g) a call with one global argument; A g - h; B g | h; H g >> k;
    T g ? h : k; P (int) *gp * ga[k], (unsigned long) g * h; all of one type t (int or unsigned long)"""

    def __init__(self, k, t, **kw):
        self.k, self.t = k, t
        self.__dict__.update(kw)


def gload(n, t):
    """a read of a global scalar of type t -> its symbol"""
    o = rvalue(n)
    need(o.k == 'G' and o.t == t)
    return o.sym


def expr_kind(n):
    n = unc(n)
    t = tl(n.ty)
    need(t in ('i', 'n'))
    if n.k == 'call':
        fn = cg.strip(n.fn)
        need(fn.k == 'var' and fn.decl.kind == 'func' and len(n.args) == 1)
        return Ex('F', t, fn=fn.decl.name, arg=gload(n.args[0], t))
    if n.k == 'bin' and n.op in ('-', '|'):
        return Ex('A' if n.op == '-' else 'B', t, x=gload(n.l, t), y=gload(n.r, t))
    if n.k == 'bin' and n.op == '>>':
        k = const_of(n.r)
        need(k is not None and 0 < k < 16)
        return Ex('H', t, x=gload(n.l, t), sh=k)
    if n.k == 'cond':
        return Ex('T', t, c=gload(n.c, t), a=gload(n.a, t), b=gload(n.b, t))
    if n.k == 'bin' and n.op == '*':
        if t == 'n':
            return Ex('P', t, x=gload(n.l, t), y=gload(n.r, t))
        a, b = rvalue(n.l), rvalue(n.r)
        need(a.k == 'P' and a.off == 0 and b.k == 'E' and a.t == b.t == 'i')
        return Ex('P', t, ptr=a.ptr, sym=b.sym, off=b.off)
    raise Decline()


class Labels:
    def __init__(self):
        self.n = 0

    def new(self):
        self.n += 1
        return 'L%d' % self.n


def load_sites(e):
    """the global loads of an operand in evaluation order -> [(sym, unconditional)]; a call ends the list with None"""
    if e.k == 'F':
        return [(e.arg, True), (None, True)]
    if e.k in 'AB' or (e.k == 'P' and e.t == 'n'):
        return [(e.x, True), (e.y, True)]
    if e.k == 'H':
        return [(e.x, True)]
    if e.k == 'T':
        return [(e.c, True), (e.a, False), (e.b, False)]
    return [(e.ptr, True), (symoff(e.sym, e.off), True)]


def sharing(L, R):
    """which global reads of the two operands (left, then right; a call's argument too) are the same object: each
    read numbered by its object's first appearance, e.g. hi - gi vs ki - hi -> '01.20'"""
    seen = []
    out = []
    for e in (L, R):
        s = ''
        for sym, _ in load_sites(e):
            if sym is None:
                continue
            if sym not in seen:
                seen.append(sym)
            s += str(seen.index(sym))
        out.append(s)
    return '.'.join(out)


def cse_temps(first, second):
    """-O: the global values read again after an unconditional read (no real call between) -> [sym] in the order
    of their first read"""
    avail, temps = [], []
    for e in (first, second):
        for sym, unc_ in load_sites(e):
            if sym is None:                               # a call may change any global
                avail = []
                continue
            if sym in avail and sym not in temps:
                temps.append(sym)
            if unc_ and sym not in avail:
                avail.append(sym)
    return temps


def eval_order(L, R):
    """which operand of a compare of computed operands is evaluated first: 0 the left, 1 the right.  A call first
    (the right one when both are calls); an int product before anything else but a call (the right one when both
    are products); otherwise the right operand"""
    if L.k == 'F' and R.k != 'F':
        return 0
    if R.k == 'F':
        return 1
    if L.t == 'i' and L.k == 'P' and R.k != 'P':
        return 0
    return 1


def cq_seq(F, L, Rt, op, R, LB):
    """the compare of two computed operands, evaluated in eval_order.  Roles: t1 t2 where the first and the
    second evaluated values end (a pair, IZ, or FR a frame slot); -O only: k1 k2 the registers of the shared loads
    (cse_temps) and ko their load order; m1 m2 where an int product is formed and q1 q2 its pointer; lo1 lo2 the
    order of a long product's operand loads; z1 z2 the register of a long ?: test.  -> (lines, IZ used, frame)"""
    t = L.t
    W = 4 if t == 'n' else 2
    o = eval_order(L, Rt)
    first, second = (Rt, L) if o else (L, Rt)
    temps = cse_temps(first, second) if F.opt else []
    tloc = {sym: R['k%d' % (n + 1)] for n, sym in enumerate(temps)}
    FR = '(XSP+0x4)'

    def loc(p):
        return FR if p == 'FR' else rw(p, W)

    def opnd(sym):
        return loc(tloc[sym]) if sym in tloc else '(%s)' % sym

    out = []
    pend = [0]                                           # a pending stack adjustment (cdecl argument pushes)

    def flush():
        if pend[0]:
            out.append('inc %s,XSP' % hx(pend[0]))
            pend[0] = 0

    def move(dst, src):
        """dst <- src, locations (pair names, 'FR') or operand text"""
        d = loc(dst) if dst in PAIRS6 else dst
        s_ = loc(src) if src in PAIRS6 else src
        if d == s_:
            return
        if d == FR and s_.startswith('('):
            out.extend(['ld %s,%s' % (rw('WA', W), s_), 'ld %s,%s' % (FR, rw('WA', W))])
            return
        out.append('ld %s,%s' % (d, s_))

    order = list(range(len(temps)))
    if R.get('ko', 0) if temps[1:] else 0:
        order.reverse()
    for n in order:
        move(tloc[temps[n]], '(%s)' % temps[n])

    def side(e, n):
        tg = R['t%d' % n]
        nxt_push = n == 1 and second.k == 'F' and not F.xr
        if e.k == 'F':
            if F.xr:
                out.append('ld %s,%s' % (rw('WA', W), opnd(e.arg)))
                out.append('cal .%s' % e.fn)
            else:
                if W == 2:
                    out.append('pushw %s' % opnd(e.arg))
                else:
                    out.extend(['ld XWA,%s' % opnd(e.arg), 'push XWA'])
                out.append('cal _%s' % e.fn)
                pend[0] += W
                if not nxt_push:
                    flush()
            move(tg, 'HL')
            return
        need(tg != 'FR' or e.k == 'P')
        if e.k in 'AB':
            move(tg, opnd(e.x))
            out.append('%s %s,%s' % ('sub' if e.k == 'A' else 'or', loc(tg), opnd(e.y)))
            return
        if e.k == 'H':
            move(tg, opnd(e.x))
            out.append('%s %s,%s' % ('sra' if SIGNED[t] else 'srl', hx(e.sh), loc(tg)))
            return
        if e.k == 'T':
            la, lb = LB.new(), LB.new()
            if e.c in tloc:
                c = loc(tloc[e.c])
                out.append('cp %s,0x0' % c if W == 2 else 'or %s,%s' % (c, c))
            elif W == 2:
                out.append('cpw (%s),0x0' % e.c)
            else:
                z = R['z%d' % n]
                out.extend(['ld %s,(%s)' % (rw(z, W), e.c), 'or %s,%s' % (rw(z, W), rw(z, W))])
            mark = len(out)
            move(tg, opnd(e.a))
            then = out[mark:]
            del out[mark:]
            move(tg, opnd(e.b))
            els = out[mark:]
            del out[mark:]
            if then and els:
                out.extend(['j eq,%s' % la] + then + ['j %s' % lb, la + ':'] + els + [lb + ':'])
            elif then:
                out.extend(['j eq,%s' % la] + then + [lb + ':', la + ':'])
            elif els:
                out.extend(['j ne,%s' % lb, la + ':'] + els + [lb + ':'])
            else:
                raise Decline()
            return
        if e.k == 'P' and t == 'i':
            m, q = R['m%d' % n], R['q%d' % n]
            out.extend(['ld X%s,(%s)' % (q, e.ptr), 'ld %s,(%s)' % (m, symoff(e.sym, e.off)), 'muls X%s,(X%s)' % (m, q)])
            out.extend(copy(tg, m, 2))
            return
        if e.k == 'P':
            ld = [('XWA', e.x), ('XBC', e.y)]
            for r, sym in (ld[::-1] if R['lo%d' % n] else ld):
                move(r, opnd(sym))
            out.append('cal C9H_mullu')
            move(tg, 'HL')
            return
        raise Decline()

    side(first, 1)
    side(second, 2)
    flush()
    if op == '==':                                       # == : the value formed last is the register operand
        a, b = R['t2'], R['t1']
    else:
        a, b = (R['t2'], R['t1']) if o else (R['t1'], R['t2'])
    out.append('cp %s,%s' % (loc(a), loc(b)))
    used = set(tloc.values()) | {R['t1'], R['t2']}
    fr = 'FR' in used
    if fr:
        need('IZ' in used)
    return out, 'IZ' in used, fr


PAIRS6 = ('WA', 'BC', 'DE', 'HL', 'IZ', 'FR')


# --------------------------------------------------------------------------------------------- contexts

def compare(F, cond, locs):
    """a compare -> (lines, op, type letter of the compare); op as written, the operands in the order of the code"""
    c = cg.strip(cond)
    need(c.k == 'bin' and c.op in ('<', '==', '!='))
    if unc(c.l).k != 'load' and unc(c.r).k != 'load' and not (unc(c.l).k == 'cast' or unc(c.r).k == 'cast'):
        need(c.op in ('<', '=='))
        El, Er = expr_kind(c.l), expr_kind(c.r)
        need(El.t == Er.t)
        R = F.roles({}, 'cq/%s%s/%s/%s' % (El.k, Er.k, El.t, sharing(El, Er)), 0)
        lines, F.iz, F.frame = cq_seq(F, El, Er, c.op, R, F.labels)
        return lines, c.op, El.t
    L = rvalue(c.l)
    R = rvalue(c.r)
    if L.k == 'P':                                        # a pointer's target at an offset reads as a member
        L.k = 'D'
    if R.k in 'XY' and L.k in 'GRDE' and c.op in ('<', '=='):
        return gen_cx(F, L, R, c.op, locs), c.op, R.t
    if L.k == 'C' and R.k in 'GRX':
        return gen_cc(F, L, R, 'l', c.op, locs), c.op, L.t
    if R.k == 'C' and L.k in 'GRX':
        return gen_cc(F, R, L, 'r', c.op, locs), c.op, R.t
    if R.k in 'PDAT' and L.k in 'GRDE' and c.op in ('<', '=='):
        return gen_cp(F, L, R, c.op, locs), c.op, R.t
    raise Decline()


def global_int(n):
    """a read of a global int -> its symbol"""
    n = unc(n)
    if n.k == 'load' and var_of(n.e) is not None and var_of(n.e).kind == 'global' and tl(n.ty) == 'i':
        return gname(var_of(n.e))
    return None


def store_of(e, value):
    """`gX = value` (a global int) -> its symbol"""
    e = cg.strip(e)
    if e.k == 'bin' and e.op == '=' and var_of(e.l) is not None and var_of(e.l).kind == 'global' \
            and tl(e.l.ty) == 'i' and const_of(e.r) == value:
        return gname(var_of(e.l))
    return None


def incr_of(e):
    """`gX++` (a global int) -> its symbol"""
    e = cg.strip(e)
    if e.k == 'incdec' and e.op == '++' and var_of(e.e) is not None and var_of(e.e).kind == 'global' \
            and tl(e.e.ty) == 'i':
        return gname(var_of(e.e))
    return None


def is_compare(n):
    n = unc(n)
    return n.k == 'bin' and n.op in ('<', '==', '!=')


def hoist_param_copy(F, cmp):
    """O3XSXr: a leading copy of a parameter register into another register goes to the top of the function"""
    if F.s == 'O3XSXr' and param_copy(F, cmp):
        return [cmp[0]], cmp[1:]
    return [], cmp


def free_pair(lines):
    """the first of WA BC DE HL that the lines do not touch"""
    text = ' '.join(lines)
    for p in ('WA', 'BC', 'DE', 'HL'):
        if not re.search(r'\b(X?%s|%s|%s)\b' % (p, p[0], p[1]), text):
            return p
    raise Decline()


def loop(F, cond, locs, init, body):
    """while / for: the test at the bottom; -O hoists the test's invariant part above the loop"""
    F.ctx = 'loop'
    if F.opt:
        pre, inl, op, t = hoisted(F, cond, locs)
        return init + pre + ['j L1', 'L2:'] + body + ['L1:'] + inl + ['j %s,L2' % cond_cc(op, t, False), 'ret']
    cmp, op, t = compare(F, cond, locs)
    if len(cmp) <= 3:                                     # a short test is duplicated: once before the loop
        return init + cmp + ['ret %s' % cond_cc(op, t, True), 'L1:'] + body + cmp + \
            ['j %s,L1' % cond_cc(op, t, False), 'L2:', 'ret']
    return init + ['j L1', 'L2:'] + body + ['L1:'] + cmp + ['j %s,L2' % cond_cc(op, t, False), 'ret']


def cr_compare(F, decls, cond):
    """`int t = *ptr; [char *u = &ca[t] | = gp;] ... A[k] < A[t]` (probe family cr): t lives in a register; without
    -O the dead u is still computed; -O drops it and builds A's address once for both elements"""
    need(len(decls) in (1, 2))
    t, tinit = decls[0]
    need(tl(t.ty) == 'i' and tinit is not None)
    P = rvalue(tinit)
    need(P.k == 'P' and P.t == 'i')
    c = cg.strip(cond)
    need(c.k == 'bin' and c.op == '<')
    L, S = rvalue(c.l), rvalue(c.r)
    need(L.k == 'E' and S.k == 'Y' and S.loc is t and L.sym == S.sym and L.t == S.t and ES[S.t] == 2)
    tload = ['ld XWA,(%s)' % P.ptr, 'ld %s,%s' % ('DE' if F.opt else 'BC', disp('WA', P.off))]
    if F.opt:
        return tload + ['lda XBC,%s' % S.sym, 'add DE,DE', 'ld WA,%s' % disp('BC', L.off), 'cp WA,(XBC+DE)'], S.t
    u = []
    if len(decls) == 2:
        ud, uinit = decls[1]
        need(ud.ty is not None and ud.ty.kind == 'ptr' and uinit is not None)
        x = unc(uinit)
        if x.k == 'addr':
            e = cg.strip(x.e)
            need(e.k == 'index' and global_array(e.base) is not None and index_var(e.idx)[0] is t
                 and ES.get(tl(e.ty)) == 1)
            u = ['lda XWA,%s' % gname(global_array(e.base)), 'lda XWA,XWA+BC']
        else:
            p = global_ptr(x)
            need(p is not None)
            u = ['ld XWA,(%s)' % gname(p)]
    return tload + u + ['add BC,BC', 'lda XDE,%s' % S.sym, 'ld WA,(%s)' % symoff(L.sym, L.off), 'cp WA,(XDE+BC)'], S.t


def locals_read(n, out):
    """the locals an expression reads"""
    if isinstance(n, list):
        for x in n:
            locals_read(x, out)
        return out
    if not hasattr(n, 'k'):
        return out
    if n.k == 'var' and n.decl.kind == 'local':
        out.add(n.decl)
    for v in n.__dict__.values():
        if hasattr(v, 'k') or isinstance(v, list):
            locals_read(v, out)
    return out


def whole_(f, s):
    F = Frame(f, s)
    decls, st = body_parts(f)
    locs = {d: i for d, i in decls}
    need(len(st) == 1)
    s0 = st[0]
    if s0.k == 'if' and s0.els is None and decls:       # the probe's cr shape: an int local read through a
        then = cg.flat(s0.then)                           # pointer, maybe a dead pointer local beside it
        if len(then) == 1 and then[0].k == 'expr' and store_of(then[0].e, 1):
            try:
                cmp, t = cr_compare(F, decls, s0.cond)
                lab = F.labels.new()
                return cmp + ['ret %s' % cond_cc('<', t, True), 'ldw (%s),0x1' % store_of(then[0].e, 1), lab + ':',
                              'ret']
            except Decline:
                pass
    # otherwise every local is one the compare reads (an index local, a local pointer): a dead local's
    # initialisation would still be code
    need(len(set(d for d, _ in decls)) == len(decls) and set(d for d, _ in decls) == locals_read([s0], set()))
    if s0.k == 'if' and s0.els is None:
        then = cg.flat(s0.then)
        need(len(then) == 1 and then[0].k == 'expr')
        g = store_of(then[0].e, 1)
        need(g is not None)
        c = unc(s0.cond)
        if c.k == 'bin' and c.op == '&&' and is_compare(c.l) and global_int(c.r):
            cmp, op, t = compare(F, c.l, locs)
            return cmp + ['ret %s' % cond_cc(op, t, True), 'cpw (%s),0x0' % global_int(c.r), 'ret eq',
                          'ldw (%s),0x1' % g, 'L1:', 'ret']
        if c.k == 'bin' and c.op == '||' and global_int(c.l) and is_compare(c.r):
            cmp, op, t = compare(F, c.r, locs)
            top, cmp = hoist_param_copy(F, cmp)
            return top + ['cpw (%s),0x0' % global_int(c.l), 'j ne,L1'] + cmp + \
                ['ret %s' % cond_cc(op, t, True), 'L1:', 'ldw (%s),0x1' % g, 'L2:', 'ret']
        cmp, op, t = compare(F, s0.cond, locs)
        if F.iz:                                          # IZ saved: one exit through its pop
            iz = 'XIZ' if t == 'n' else 'IZ'
            lab = F.labels.new()
            fr = F.frame
            return (['dec 0x4,XSP'] if fr else []) + ['push %s' % iz] + cmp + \
                ['j %s,%s' % (cond_cc(op, t, True), lab), 'ldw (%s),0x1' % g, lab + ':', 'pop %s' % iz] + \
                (['inc 0x4,XSP'] if fr else []) + ['ret']
        lab = F.labels.new()
        return cmp + ['ret %s' % cond_cc(op, t, True), 'ldw (%s),0x1' % g, lab + ':', 'ret']
    if s0.k == 'while' and is_compare(s0.cond):
        body = cg.flat(s0.body)
        need(len(body) == 1 and body[0].k == 'expr' and incr_of(body[0].e))
        return loop(F, s0.cond, locs, [], ['incw 0x1,(%s)' % incr_of(body[0].e)])
    if s0.k == 'for' and s0.cond is not None and is_compare(s0.cond):
        init = cg.flat(s0.init) if s0.init is not None else []
        need(len(init) == 1 and init[0].k == 'expr' and store_of(init[0].e, 0))
        need(s0.inc is not None and incr_of(s0.inc))
        body = cg.flat(s0.body)
        need(len(body) == 1 and body[0].k == 'expr' and store_of(body[0].e, 1))
        return loop(F, s0.cond, locs, ['ldw (%s),0x0' % store_of(init[0].e, 0)],
                    ['ldw (%s),0x1' % store_of(body[0].e, 1), 'incw 0x1,(%s)' % incr_of(s0.inc)])
    if s0.k == 'return' and s0.value is not None and is_compare(s0.value) and tl(f.ret) == 'i':
        cmp, op, t = compare(F, s0.value, locs)
        return cmp + ['scc %s,HL' % cond_cc(op, t, False), 'ret']
    if s0.k == 'expr':
        e = cg.strip(s0.e)
        need(e.k == 'bin' and e.op == '=' and var_of(e.l) is not None and var_of(e.l).kind == 'global'
             and tl(e.l.ty) == 'i')
        g = gname(var_of(e.l))
        r = unc(e.r)
        if is_compare(r):
            cmp, op, t = compare(F, r, locs)
            return cmp + ['scc %s,WA' % cond_cc(op, t, False), 'ld (%s),WA' % g, 'ret']
        if r.k == 'cond' and is_compare(r.c):
            a, b = const_of(r.a), const_of(r.b)
            need(a is not None and b is not None)
            cmp, op, t = compare(F, r.c, locs)
            top, cmp = hoist_param_copy(F, cmp)
            q = free_pair(top + cmp)
            return top + ['ld %s,%s' % (q, hx(b))] + cmp + ['j %s,L1' % cond_cc(op, t, True),
                                                            'ld %s,%s' % (q, hx(a)), 'L1:', 'ld (%s),%s' % (g, q), 'ret']
    raise Decline()


def combine(addr, c):
    """-O loop: an element address (Xb+r) made one pointer register c, b or r -> (lines, operand)"""
    m = re.match(r'\(X(\w\w)\+(\w\w)\)$', addr)
    if m is None:
        need(re.match(r'\(X\w\w\)$', addr) is not None)
        return [], addr
    b, r = m.groups()
    if c == b:
        return ['lda X%s,X%s+%s' % (b, b, r)], '(X%s)' % b
    need(c == r)
    return ['exts X%s' % r, 'add X%s,X%s' % (r, b)], '(X%s)' % r


def ptr_reg(R, role, ptr, off):
    """-O loop: a pointer plus a constant offset in one register"""
    if not off:
        return ['ld X%s,(%s)' % (R[role], ptr)]
    return ['ld X%s,(%s)' % (R['t'], ptr), 'lda X%s,X%s+%s' % (R[role], R['t'], hx(off))]


def hoisted(F, cond, locs):
    """-O: a loop test split into the invariant part (above the loop) and the test -> (pre, test, op, type)"""
    c = cg.strip(cond)
    need(c.k == 'bin' and c.op in ('<', '==', '!='))
    L = rvalue(c.l)
    Q = rvalue(c.r)
    if L.k == 'P':
        L.k = 'D'
    left_disp_ok(L)
    if L.k != 'C' and Q.k != 'C':
        params_used(F, [L, Q])
    if Q.k in 'XY' and L.k in 'GR' and L.t == Q.t:
        R = F.roles({}, 'hx/%s/%s/%s/%s/%s' % (L.k, Q.k, Q.it, Q.t, c.op), 0)
        pre, addr, _ = index_code(F, Q, R, locs)
        comb, ptr = combine(addr, R['c'])
        w = ES[Q.t]
        if F.xr and L.k == 'R':
            test = ['cp %s,%s' % (F.preg_w(L.prm, w), ptr)]
        else:
            test = ['ld %s,%s' % (rw(R['a'], w), left_mem(F, L, R)), 'cp %s,%s' % (rw(R['a'], w), ptr)]
        return pre + comb, test, c.op, Q.t
    if Q.k in 'PD' and L.k in 'GD' and L.t == Q.t:
        R = F.roles({}, 'hp/%s/%s/%s/%s' % (L.k, Q.k, Q.t, c.op), 0)
        w = ES[Q.t]
        pre = (ptr_reg(R, 'p', L.ptr, L.off) if L.k == 'D' else []) + ptr_reg(R, 'q', Q.ptr, Q.off)
        a = rw(R['a'], w)
        if L.k == 'D':
            test = ['ld %s,(X%s)' % (a, R['q']), 'cp %s,(X%s)' % (a, R['p'])]
        else:
            test = ['ld %s,%s' % (a, left_mem(F, L, R)), 'cp %s,(X%s)' % (a, R['q'])]
        return pre, test, c.op, Q.t
    for C, O, side in ((L, Q, 'l'), (Q, L, 'r')):
        if C.k == 'C' and O.k in 'GRX' and O.t == C.t and C.src.k in 'GE':
            O.cc = O.k == 'X' and O.it == 'c'
            params_used(F, [O])
            R = F.roles({}, 'hc/%s%s/%s/%s/%s' % (O.k, side, C.src.t, C.t, c.op), 0)
            if O.k == 'X':
                pre, addr, _ = index_code(F, O, R, locs)
                comb, other = combine(addr, R['c'])
                pre += comb
            else:
                pre, other = [], left_mem(F, O, R)
            src = C.src
            pre += cast_load('(%s)' % symoff(src.sym, src.off if src.k == 'E' else 0), src.t, C.t, R['a'])
            reg = rw(R['a'], ES[C.t])
            return pre, ['cp %s,%s' % ((reg, other) if side == 'l' else (other, reg))], c.op, C.t
    raise Decline()


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
    except Exception:                                     # (an AST shape the classifier did not foresee)
        return None


# --------------------------------------------------------------------------------------------- check

RUN = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-13-4-micro-cmpx/out/v423/%s/probes/cmpx.asm')
SRC = 'corpus/probes/cmpx.c'                       # --check runs from scripts/analysis/cc900, as score.py does


def check(s, show=0, only=None):
    import frontend
    import listing
    want = listing.split(open(RUN % s, encoding='latin-1').read())
    unit = frontend.load(SRC, [], [], adecl=s.endswith('Xr'))
    ok = wrong = dec = 0
    shown = 0
    fams = {}
    for f in unit.functions:
        if only and not re.search(only, f.name):
            continue
        name = ('.' if s.endswith('Xr') else '_') + f.name
        W = [l for l in want.get(name, []) if 'section' not in l][1:]
        got = whole(f, s)
        fam = f.name[:2]
        fs = fams.setdefault(fam, [0, 0, 0])
        if got is None:
            dec += 1
            fs[2] += 1
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


# --------------------------------------------------------------------------------------------- role tables
# cx register roles, fitted per operand kinds: '<set>/<ctx>/<S>/<x>' -> roles for the element type columns
# (char, unsigned char, int / unsigned int, long / unsigned long); ctx: L's kind (G R D E), 's' prefixed when the
# compare is swapped (== with D or E), '=' suffixed when -O folds the local index's load into the left operand's.
# Roles: p pointer (D), h index value, i scaled index, b array base, a accumulator; pp: where `ld Xp,(ptr)` goes.
CX_ROLES = {
    'O3XS/cx/D/X/b': ('a=WA b=DE h=BC i=BC p=HL', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=DE i=DE p=BC'),
    'O3XS/cx/D/X/c': ('a=WA b=BC i=DE p=HL', 'a=WA b=DE i=HL p=BC', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=DE i=DE p=BC'),
    'O3XS/cx/D/X/i': ('a=WA b=WA i=BC p=DE', 'a=WA b=BC i=DE p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XS/cx/D/X/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XS/cx/D/Y/b': ('a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XS/cx/D/Y/c': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=WA i=DE p=BC'),
    'O3XS/cx/D/Y/i': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XS/cx/D/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XS/cx/E/X/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/E/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/E/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/E/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/E/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/E/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'O3XS/cx/E/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/E/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/G/X/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/G/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/G/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/G/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/G/Y/b': ('a=WA b=DE h=BC i=BC', '-', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/G/Y/c': ('-', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'O3XS/cx/G/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/G/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/G=/Y/b': ('-', 'a=WA b=DE h=WA i=BC', '-', '-'),
    'O3XS/cx/G=/Y/c': ('a=WA b=BC h=WA i=WA', '-', '-', '-'),
    'O3XS/cx/G=/Y/i': ('-', '-', 'a=WA b=DE h=WA i=BC', '-'),
    'O3XS/cx/G=/Y/u': ('-', '-', 'a=WA b=DE h=WA i=BC', '-'),
    'O3XS/cx/R/X/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/R/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/R/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/R/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/R/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/R/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'O3XS/cx/R/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cx/R/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sD/X/b': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/X/c': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/X/i': ('a=WA b=WA i=BC p=DE', 'a=WA b=WA i=DE p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/X/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/Y/b': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/Y/c': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/Y/i': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sD/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XS/cx/sE/X/b': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/X/c': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC h=BC i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/Y/b': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/Y/c': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=BC i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/Y/i': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XS/cx/sE/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/D/X/b': ('a=WA b=DE i=BC p=HL', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'O3XSXr/cx/D/X/c': ('a=BC b=DE i=WA p=BC', 'a=BC b=DE i=WA p=BC', 'a=WA b=HL i=BC p=DE', 'a=WA b=HL i=DE p=BC'),
    'O3XSXr/cx/D/X/i': ('a=BC b=DE i=WA p=BC', 'a=BC b=DE i=WA p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'O3XSXr/cx/D/X/u': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'O3XSXr/cx/D/Y/b': ('a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XSXr/cx/D/Y/c': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=WA i=DE p=BC'),
    'O3XSXr/cx/D/Y/i': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XSXr/cx/D/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'O3XSXr/cx/E/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/E/X/c': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/E/X/i': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/E/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/E/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/E/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'O3XSXr/cx/E/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/E/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/G/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/G/X/c': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/G/X/i': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/G/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/G/Y/b': ('a=WA b=DE h=BC i=BC', '-', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/G/Y/c': ('-', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'O3XSXr/cx/G/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/G/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/G=/Y/b': ('-', 'a=WA b=DE h=WA i=BC', '-', '-'),
    'O3XSXr/cx/G=/Y/c': ('a=WA b=BC h=WA i=WA', '-', '-', '-'),
    'O3XSXr/cx/G=/Y/i': ('-', '-', 'a=WA b=DE h=WA i=BC', '-'),
    'O3XSXr/cx/G=/Y/u': ('-', '-', 'a=WA b=DE h=WA i=BC', '-'),
    'O3XSXr/cx/R/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/R/X/c': ('a=WA b=DE i=WA', 'a=WA b=DE i=WA', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/R/X/i': ('a=WA b=DE i=WA', 'a=WA b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/R/X/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cx/R/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/R/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=DE i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/R/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/R/Y/u': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XSXr/cx/sD/X/b': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'O3XSXr/cx/sD/X/c': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=WA i=BC p=DE', 'a=WA b=DE i=WA p=BC'),
    'O3XSXr/cx/sD/X/i': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'O3XSXr/cx/sD/X/u': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'O3XSXr/cx/sD/Y/b': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XSXr/cx/sD/Y/c': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XSXr/cx/sD/Y/i': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XSXr/cx/sD/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'O3XSXr/cx/sE/X/b': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/sE/X/c': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=WA i=BC', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/sE/X/i': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/sE/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'O3XSXr/cx/sE/Y/b': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/sE/Y/c': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=BC i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/sE/Y/i': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'O3XSXr/cx/sE/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/D/X/b': ('a=WA b=DE i=BC p=HL', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'Xr/cx/D/X/c': ('a=BC b=DE i=WA p=BC', 'a=BC b=DE i=WA p=BC', 'a=WA b=HL i=BC p=DE', 'a=WA b=HL i=DE p=BC'),
    'Xr/cx/D/X/i': ('a=BC b=DE i=WA p=BC', 'a=BC b=DE i=WA p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'Xr/cx/D/X/u': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'Xr/cx/D/Y/b': ('a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'Xr/cx/D/Y/c': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=WA i=DE p=BC'),
    'Xr/cx/D/Y/i': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'Xr/cx/D/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'Xr/cx/E/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/E/X/c': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/E/X/i': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/E/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'Xr/cx/E/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC', 'a=WA b=DE h=WA i=BC'),
    'Xr/cx/E/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'Xr/cx/E/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/E/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/G/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/G/X/c': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/G/X/i': ('a=BC b=DE i=WA', 'a=BC b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/G/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'Xr/cx/G/Y/b': ('a=WA b=DE h=BC i=BC', '-', 'a=WA b=DE h=WA i=BC', 'a=WA b=DE h=WA i=BC'),
    'Xr/cx/G/Y/c': ('-', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'Xr/cx/G/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/G/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/G=/Y/b': ('-', 'a=WA b=DE h=BC i=BC', '-', '-'),
    'Xr/cx/G=/Y/c': ('a=WA b=BC h=DE i=WA', '-', '-', '-'),
    'Xr/cx/G=/Y/i': ('-', '-', 'a=WA b=DE h=BC i=BC', '-'),
    'Xr/cx/G=/Y/u': ('-', '-', 'a=WA b=BC h=WA i=WA', '-'),
    'Xr/cx/R/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/R/X/c': ('a=WA b=DE i=WA', 'a=WA b=DE i=WA', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC'),
    'Xr/cx/R/X/i': ('a=WA b=DE i=WA', 'a=WA b=DE i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/R/X/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cx/R/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/R/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=DE i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/R/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/R/Y/u': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'Xr/cx/sD/X/b': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'Xr/cx/sD/X/c': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=WA i=BC p=DE', 'a=WA b=DE i=WA p=BC'),
    'Xr/cx/sD/X/i': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'Xr/cx/sD/X/u': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'Xr/cx/sD/Y/b': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'Xr/cx/sD/Y/c': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'Xr/cx/sD/Y/i': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'Xr/cx/sD/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'Xr/cx/sE/X/b': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'Xr/cx/sE/X/c': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=WA i=BC', 'a=WA b=BC i=WA'),
    'Xr/cx/sE/X/i': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'Xr/cx/sE/X/u': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'Xr/cx/sE/Y/b': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/sE/Y/c': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=BC i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/sE/Y/i': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'Xr/cx/sE/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/D/X/b': ('a=WA b=DE i=BC p=HL', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'none/cx/D/X/c': ('a=WA b=BC i=DE p=HL', 'a=WA b=DE i=HL p=BC', 'a=WA b=HL i=DE p=BC', 'a=WA b=HL i=DE p=BC'),
    'none/cx/D/X/i': ('a=WA b=WA i=BC p=DE', 'a=WA b=BC i=DE p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'none/cx/D/X/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'none/cx/D/Y/b': ('a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'none/cx/D/Y/c': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=HL h=DE i=DE p=BC', 'a=WA b=HL h=WA i=DE p=BC'),
    'none/cx/D/Y/i': ('a=WA b=BC h=DE i=WA p=WA', 'a=WA b=BC h=DE i=WA p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'none/cx/D/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA', 'a=WA b=DE h=BC i=BC p=WA'),
    'none/cx/E/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/E/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/E/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/E/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/E/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/E/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/E/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/E/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/G/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/G/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/G/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/G/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/G/Y/b': ('a=WA b=DE h=BC i=BC', '-', 'a=WA b=DE h=WA i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/G/Y/c': ('-', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/G/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/G/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/G=/Y/b': ('-', 'a=WA b=DE h=BC i=BC', '-', '-'),
    'none/cx/G=/Y/c': ('a=WA b=BC h=DE i=WA', '-', '-', '-'),
    'none/cx/G=/Y/i': ('-', '-', 'a=WA b=DE h=BC i=BC', '-'),
    'none/cx/G=/Y/u': ('-', '-', 'a=WA b=BC h=WA i=WA', '-'),
    'none/cx/R/X/b': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/R/X/c': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cx/R/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/R/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/R/Y/b': ('a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/R/Y/c': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=WA i=BC'),
    'none/cx/R/Y/i': ('a=WA b=BC h=DE i=WA', 'a=WA b=BC h=DE i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'none/cx/R/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sD/X/b': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'none/cx/sD/X/c': ('a=WA b=BC i=WA p=DE', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC', 'a=WA b=DE i=WA p=BC'),
    'none/cx/sD/X/i': ('a=WA b=WA i=BC p=DE', 'a=WA b=WA i=DE p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sD/X/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sD/Y/b': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sD/Y/c': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sD/Y/i': ('a=WA b=WA h=DE i=WA p=BC', 'a=WA b=WA h=DE i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sD/Y/u': ('a=WA b=BC h=WA i=WA p=DE', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC', 'a=WA b=DE h=WA i=WA p=BC'),
    'none/cx/sE/X/b': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'none/cx/sE/X/c': ('a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA', 'a=WA b=BC i=WA'),
    'none/cx/sE/X/i': ('a=WA b=WA i=BC', 'a=WA b=WA i=BC', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sE/X/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sE/Y/b': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sE/Y/c': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=BC i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sE/Y/i': ('a=WA b=WA h=BC i=WA', 'a=WA b=WA h=BC i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
    'none/cx/sE/Y/u': ('a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA', 'a=WA b=BC h=WA i=WA'),
}

EXTRA_ROLES = {
    'O3XS//cc/Xl:i!=/i#4': 'a=DE b=BC h=WA i=WA',
    'O3XS//cq/AA/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AA/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AB/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AB/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AF/i/01.2#0': 't1=HL t2=WA',
    'O3XS//cq/AF/n/01.2#0': 't1=HL t2=WA',
    'O3XS//cq/AH/i/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AH/n/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/AP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XS//cq/AP/n/01.02#0': 'k1=IZ lo1=0 lo2=0 t1=HL t2=WA',
    'O3XS//cq/AT/i/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XS//cq/AT/n/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XS//cq/BA/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BA/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BB/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BB/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BF/i/01.2#0': 't1=HL t2=WA',
    'O3XS//cq/BF/n/01.2#0': 't1=HL t2=WA',
    'O3XS//cq/BH/i/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BH/n/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/BP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XS//cq/BP/n/01.02#0': 'k1=IZ lo1=0 lo2=0 t1=HL t2=WA',
    'O3XS//cq/BT/i/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XS//cq/BT/n/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XS//cq/FA/i/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FA/n/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FB/i/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FB/n/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FF/i/0.1#0': 't1=IZ t2=HL',
    'O3XS//cq/FF/n/0.1#0': 't1=IZ t2=HL',
    'O3XS//cq/FH/i/0.0#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FH/n/0.0#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FP/i/0.12#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'O3XS//cq/FP/n/0.01#0': 'k1=WA lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/FT/i/0.012#0': 'k1=WA t1=HL t2=WA',
    'O3XS//cq/FT/n/0.012#0': 'k1=WA t1=HL t2=WA z2=WA',
    'O3XS//cq/HA/i/0.12#0': 't1=WA t2=BC',
    'O3XS//cq/HA/n/0.12#0': 't1=WA t2=BC',
    'O3XS//cq/HB/i/0.12#0': 't1=WA t2=BC',
    'O3XS//cq/HB/n/0.12#0': 't1=WA t2=BC',
    'O3XS//cq/HF/i/0.1#0': 't1=HL t2=WA',
    'O3XS//cq/HF/n/0.1#0': 't1=HL t2=WA',
    'O3XS//cq/HH/i/0.1#0': 't1=WA t2=BC',
    'O3XS//cq/HH/n/0.1#0': 't1=WA t2=BC',
    'O3XS//cq/HP/i/0.12#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XS//cq/HP/n/0.12#0': 'lo1=0 lo2=0 t1=HL t2=WA',
    'O3XS//cq/HT/i/0.120#0': 'k1=WA t1=WA t2=BC',
    'O3XS//cq/HT/n/0.120#0': 'k1=WA t1=WA t2=BC z1=WA z2=WA',
    'O3XS//cq/PA/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XS//cq/PA/n/01.21#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/PB/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XS//cq/PB/n/01.21#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/PF/i/01.2#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'O3XS//cq/PF/n/01.2#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/PH/i/01.2#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XS//cq/PH/n/01.1#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/PP/i/01.23#0': 'm1=DE m2=WA q1=BC q2=BC t1=DE t2=WA',
    'O3XS//cq/PP/n/01.12#0': 'k1=IZ lo1=0 lo2=1 t1=FR t2=HL',
    'O3XS//cq/PT/i/01.234#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XS//cq/PT/n/01.120#0': 'k1=BC k2=WA ko=0 lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XS//cq/TA/i/012.21#0': 'k1=WA k2=BC ko=0 t1=DE t2=BC',
    'O3XS//cq/TA/n/012.21#0': 'k1=DE k2=BC ko=1 t1=HL t2=BC z1=WA z2=WA',
    'O3XS//cq/TB/i/012.21#0': 'k1=WA k2=BC ko=0 t1=DE t2=BC',
    'O3XS//cq/TB/n/012.21#0': 'k1=DE k2=BC ko=1 t1=HL t2=BC z1=WA z2=WA',
    'O3XS//cq/TF/i/012.2#0': 't1=HL t2=WA',
    'O3XS//cq/TF/n/012.2#0': 't1=HL t2=WA z1=WA z2=WA',
    'O3XS//cq/TH/i/012.1#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/TH/n/012.1#0': 'k1=BC t1=DE t2=BC z1=WA z2=WA',
    'O3XS//cq/TP/i/012.34#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XS//cq/TP/n/012.12#0': 'k1=IZ k2=FR ko=1 lo1=0 lo2=0 t1=HL t2=WA z1=WA z2=WA',
    'O3XS//cq/TT/i/012.120#0': 'k1=WA t1=BC t2=WA',
    'O3XS//cq/TT/n/012.120#0': 'k1=BC t1=DE t2=BC z2=WA',
    'O3XS/loop/hc/Gr/l/n/<#0': 'a=WA',
    'O3XS/loop/hc/Xl/i/l/!=#0': 'a=BC b=BC c=WA h=WA i=WA',
    'O3XS/loop/hp/D/P/i/==#0': 'a=WA p=DE q=BC t=WA',
    'O3XS/loop/hp/G/P/c/<#0': 'a=WA q=BC',
    'O3XS/loop/hx/G/X/i/i/<#0': 'a=WA b=BC c=BC h=WA i=WA',
    'O3XS/loop/hx/R/X/b/u/<#0': 'a=WA b=BC c=BC h=WA i=WA',
    'O3XSXr//cc/Xl:i!=/i#4': 'a=DE b=BC i=WA',
    'O3XSXr//cq/AA/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AA/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AB/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AB/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AF/i/01.2#0': 't1=HL t2=WA',
    'O3XSXr//cq/AF/n/01.2#0': 't1=HL t2=WA',
    'O3XSXr//cq/AH/i/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AH/n/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/AP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XSXr//cq/AP/n/01.02#0': 'k1=IZ lo1=0 lo2=0 t1=HL t2=WA',
    'O3XSXr//cq/AT/i/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XSXr//cq/AT/n/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XSXr//cq/BA/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BA/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BB/i/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BB/n/01.20#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BF/i/01.2#0': 't1=HL t2=WA',
    'O3XSXr//cq/BF/n/01.2#0': 't1=HL t2=WA',
    'O3XSXr//cq/BH/i/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BH/n/01.0#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/BP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XSXr//cq/BP/n/01.02#0': 'k1=IZ lo1=0 lo2=0 t1=HL t2=WA',
    'O3XSXr//cq/BT/i/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XSXr//cq/BT/n/01.021#0': 'k1=WA k2=WA ko=0 t1=BC t2=WA',
    'O3XSXr//cq/FA/i/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FA/n/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FB/i/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FB/n/0.10#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FF/i/0.1#0': 't1=IZ t2=HL',
    'O3XSXr//cq/FF/n/0.1#0': 't1=IZ t2=HL',
    'O3XSXr//cq/FH/i/0.0#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FH/n/0.0#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FP/i/0.12#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'O3XSXr//cq/FP/n/0.01#0': 'k1=WA lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/FT/i/0.012#0': 'k1=WA t1=HL t2=WA',
    'O3XSXr//cq/FT/n/0.012#0': 'k1=WA t1=HL t2=WA z2=WA',
    'O3XSXr//cq/HA/i/0.12#0': 't1=WA t2=BC',
    'O3XSXr//cq/HA/n/0.12#0': 't1=WA t2=BC',
    'O3XSXr//cq/HB/i/0.12#0': 't1=WA t2=BC',
    'O3XSXr//cq/HB/n/0.12#0': 't1=WA t2=BC',
    'O3XSXr//cq/HF/i/0.1#0': 't1=HL t2=WA',
    'O3XSXr//cq/HF/n/0.1#0': 't1=HL t2=WA',
    'O3XSXr//cq/HH/i/0.1#0': 't1=WA t2=BC',
    'O3XSXr//cq/HH/n/0.1#0': 't1=WA t2=BC',
    'O3XSXr//cq/HP/i/0.12#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XSXr//cq/HP/n/0.12#0': 'lo1=0 lo2=0 t1=HL t2=WA',
    'O3XSXr//cq/HT/i/0.120#0': 'k1=WA t1=WA t2=BC',
    'O3XSXr//cq/HT/n/0.120#0': 'k1=WA t1=WA t2=BC z1=WA z2=WA',
    'O3XSXr//cq/PA/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XSXr//cq/PA/n/01.21#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/PB/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XSXr//cq/PB/n/01.21#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/PF/i/01.2#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'O3XSXr//cq/PF/n/01.2#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/PH/i/01.2#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XSXr//cq/PH/n/01.1#0': 'k1=BC lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/PP/i/01.23#0': 'm1=DE m2=WA q1=BC q2=BC t1=DE t2=WA',
    'O3XSXr//cq/PP/n/01.12#0': 'k1=IZ lo1=0 lo2=1 t1=FR t2=HL',
    'O3XSXr//cq/PT/i/01.234#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'O3XSXr//cq/PT/n/01.120#0': 'k1=BC k2=WA ko=0 lo1=0 lo2=0 t1=IZ t2=HL',
    'O3XSXr//cq/TA/i/012.21#0': 'k1=WA k2=BC ko=0 t1=DE t2=BC',
    'O3XSXr//cq/TA/n/012.21#0': 'k1=DE k2=BC ko=1 t1=HL t2=BC z1=WA z2=WA',
    'O3XSXr//cq/TB/i/012.21#0': 'k1=WA k2=BC ko=0 t1=DE t2=BC',
    'O3XSXr//cq/TB/n/012.21#0': 'k1=DE k2=BC ko=1 t1=HL t2=BC z1=WA z2=WA',
    'O3XSXr//cq/TF/i/012.2#0': 't1=HL t2=WA',
    'O3XSXr//cq/TF/n/012.2#0': 't1=HL t2=WA z1=WA z2=WA',
    'O3XSXr//cq/TH/i/012.1#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/TH/n/012.1#0': 'k1=BC t1=DE t2=BC z1=WA z2=WA',
    'O3XSXr//cq/TP/i/012.34#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'O3XSXr//cq/TP/n/012.12#0': 'k1=IZ k2=FR ko=1 lo1=0 lo2=0 t1=HL t2=WA z1=WA z2=WA',
    'O3XSXr//cq/TT/i/012.120#0': 'k1=WA t1=BC t2=WA',
    'O3XSXr//cq/TT/n/012.120#0': 'k1=BC t1=DE t2=BC z2=WA',
    'O3XSXr/loop/hc/Gr/l/n/<#0': 'a=WA',
    'O3XSXr/loop/hc/Xl/i/l/!=#0': 'a=BC b=BC c=WA i=WA',
    'O3XSXr/loop/hp/D/P/i/==#0': 'a=WA p=DE q=BC t=WA',
    'O3XSXr/loop/hp/G/P/c/<#0': 'a=WA q=BC',
    'O3XSXr/loop/hx/G/X/i/i/<#0': 'a=WA b=BC c=BC i=WA',
    'O3XSXr/loop/hx/R/X/b/u/<#0': 'b=DE c=BC i=BC',
    'Xr//cc/Xl:i!=/i#4': 'a=DE b=BC i=WA',
    'Xr//cq/AA/i/01.20#0': 't1=WA t2=BC',
    'Xr//cq/AA/n/01.20#0': 't1=WA t2=BC',
    'Xr//cq/AB/i/01.20#0': 't1=WA t2=BC',
    'Xr//cq/AB/n/01.20#0': 't1=WA t2=BC',
    'Xr//cq/AF/i/01.2#0': 't1=HL t2=WA',
    'Xr//cq/AF/n/01.2#0': 't1=HL t2=WA',
    'Xr//cq/AH/i/01.0#0': 't1=WA t2=BC',
    'Xr//cq/AH/n/01.0#0': 't1=WA t2=BC',
    'Xr//cq/AP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'Xr//cq/AP/n/01.02#0': 'lo1=1 lo2=0 t1=HL t2=WA',
    'Xr//cq/AT/i/01.021#0': 't1=WA t2=BC',
    'Xr//cq/AT/n/01.021#0': 't1=WA t2=BC z1=WA z2=WA',
    'Xr//cq/BA/i/01.20#0': 't1=WA t2=BC',
    'Xr//cq/BA/n/01.20#0': 't1=WA t2=BC',
    'Xr//cq/BB/i/01.20#0': 't1=WA t2=BC',
    'Xr//cq/BB/n/01.20#0': 't1=WA t2=BC',
    'Xr//cq/BF/i/01.2#0': 't1=HL t2=WA',
    'Xr//cq/BF/n/01.2#0': 't1=HL t2=WA',
    'Xr//cq/BH/i/01.0#0': 't1=WA t2=BC',
    'Xr//cq/BH/n/01.0#0': 't1=WA t2=BC',
    'Xr//cq/BP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'Xr//cq/BP/n/01.02#0': 'lo1=1 lo2=0 t1=HL t2=WA',
    'Xr//cq/BT/i/01.021#0': 't1=WA t2=BC',
    'Xr//cq/BT/n/01.021#0': 't1=WA t2=BC z1=WA z2=WA',
    'Xr//cq/FA/i/0.10#0': 't1=HL t2=WA',
    'Xr//cq/FA/n/0.10#0': 't1=HL t2=WA',
    'Xr//cq/FB/i/0.10#0': 't1=HL t2=WA',
    'Xr//cq/FB/n/0.10#0': 't1=HL t2=WA',
    'Xr//cq/FF/i/0.1#0': 't1=IZ t2=HL',
    'Xr//cq/FF/n/0.1#0': 't1=IZ t2=HL',
    'Xr//cq/FH/i/0.0#0': 't1=HL t2=WA',
    'Xr//cq/FH/n/0.0#0': 't1=HL t2=WA',
    'Xr//cq/FP/i/0.12#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'Xr//cq/FP/n/0.01#0': 'lo1=0 lo2=1 t1=IZ t2=HL',
    'Xr//cq/FT/i/0.012#0': 't1=HL t2=WA',
    'Xr//cq/FT/n/0.012#0': 't1=HL t2=WA z1=WA z2=WA',
    'Xr//cq/HA/i/0.12#0': 't1=WA t2=BC',
    'Xr//cq/HA/n/0.12#0': 't1=WA t2=BC',
    'Xr//cq/HB/i/0.12#0': 't1=WA t2=BC',
    'Xr//cq/HB/n/0.12#0': 't1=WA t2=BC',
    'Xr//cq/HF/i/0.1#0': 't1=HL t2=WA',
    'Xr//cq/HF/n/0.1#0': 't1=HL t2=WA',
    'Xr//cq/HH/i/0.1#0': 't1=WA t2=BC',
    'Xr//cq/HH/n/0.1#0': 't1=WA t2=BC',
    'Xr//cq/HP/i/0.12#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'Xr//cq/HP/n/0.12#0': 'lo1=0 lo2=0 t1=HL t2=WA',
    'Xr//cq/HT/i/0.120#0': 't1=WA t2=BC',
    'Xr//cq/HT/n/0.120#0': 't1=WA t2=BC z1=WA z2=WA',
    'Xr//cq/PA/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'Xr//cq/PA/n/01.21#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'Xr//cq/PB/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'Xr//cq/PB/n/01.21#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'Xr//cq/PF/i/01.2#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'Xr//cq/PF/n/01.2#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'Xr//cq/PH/i/01.2#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'Xr//cq/PH/n/01.1#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'Xr//cq/PP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=BC t1=DE t2=WA',
    'Xr//cq/PP/n/01.12#0': 'lo1=1 lo2=0 t1=IZ t2=HL',
    'Xr//cq/PT/i/01.234#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'Xr//cq/PT/n/01.120#0': 'lo1=0 lo2=1 t1=IZ t2=HL z1=WA z2=WA',
    'Xr//cq/TA/i/012.21#0': 't1=WA t2=BC',
    'Xr//cq/TA/n/012.21#0': 't1=BC t2=WA z1=WA z2=WA',
    'Xr//cq/TB/i/012.21#0': 't1=WA t2=BC',
    'Xr//cq/TB/n/012.21#0': 't1=BC t2=WA z1=WA z2=WA',
    'Xr//cq/TF/i/012.2#0': 't1=HL t2=WA',
    'Xr//cq/TF/n/012.2#0': 't1=HL t2=WA z1=WA z2=WA',
    'Xr//cq/TH/i/012.1#0': 't1=WA t2=BC',
    'Xr//cq/TH/n/012.1#0': 't1=BC t2=WA z1=WA z2=WA',
    'Xr//cq/TP/i/012.34#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'Xr//cq/TP/n/012.12#0': 'lo1=0 lo2=0 t1=HL t2=WA z1=WA z2=WA',
    'Xr//cq/TT/i/012.120#0': 't1=WA t2=BC',
    'Xr//cq/TT/n/012.120#0': 't1=BC t2=WA z1=WA z2=WA',
    'Xr/loop/cc/Gr/l#5': 'a=WA',
    'Xr/loop/cc/Xl:i!=/i#4': 'a=HL b=DE i=BC',
    'Xr/loop/cp/G/P#0': 'a=WA q=BC',
    'Xr/loop/cp/sD/P#2': 'a=WA p=BC q=WA',
    'Xr/loop/cx/G/X/i#2': 'a=BC b=HL i=DE',
    'Xr/loop/cx/R/X/b#2': 'a=WA b=HL i=DE',
    'none//cc/Xl:i!=/i#4': 'a=DE b=BC h=WA i=WA',
    'none//cq/AA/i/01.20#0': 't1=WA t2=BC',
    'none//cq/AA/n/01.20#0': 't1=WA t2=BC',
    'none//cq/AB/i/01.20#0': 't1=WA t2=BC',
    'none//cq/AB/n/01.20#0': 't1=WA t2=BC',
    'none//cq/AF/i/01.2#0': 't1=HL t2=WA',
    'none//cq/AF/n/01.2#0': 't1=HL t2=WA',
    'none//cq/AH/i/01.0#0': 't1=WA t2=BC',
    'none//cq/AH/n/01.0#0': 't1=WA t2=BC',
    'none//cq/AP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'none//cq/AP/n/01.02#0': 'lo1=1 lo2=0 t1=HL t2=WA',
    'none//cq/AT/i/01.021#0': 't1=WA t2=BC',
    'none//cq/AT/n/01.021#0': 't1=WA t2=BC z1=WA z2=WA',
    'none//cq/BA/i/01.20#0': 't1=WA t2=BC',
    'none//cq/BA/n/01.20#0': 't1=WA t2=BC',
    'none//cq/BB/i/01.20#0': 't1=WA t2=BC',
    'none//cq/BB/n/01.20#0': 't1=WA t2=BC',
    'none//cq/BF/i/01.2#0': 't1=HL t2=WA',
    'none//cq/BF/n/01.2#0': 't1=HL t2=WA',
    'none//cq/BH/i/01.0#0': 't1=WA t2=BC',
    'none//cq/BH/n/01.0#0': 't1=WA t2=BC',
    'none//cq/BP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'none//cq/BP/n/01.02#0': 'lo1=1 lo2=0 t1=HL t2=WA',
    'none//cq/BT/i/01.021#0': 't1=WA t2=BC',
    'none//cq/BT/n/01.021#0': 't1=WA t2=BC z1=WA z2=WA',
    'none//cq/FA/i/0.10#0': 't1=HL t2=WA',
    'none//cq/FA/n/0.10#0': 't1=HL t2=WA',
    'none//cq/FB/i/0.10#0': 't1=HL t2=WA',
    'none//cq/FB/n/0.10#0': 't1=HL t2=WA',
    'none//cq/FF/i/0.1#0': 't1=IZ t2=HL',
    'none//cq/FF/n/0.1#0': 't1=IZ t2=HL',
    'none//cq/FH/i/0.0#0': 't1=HL t2=WA',
    'none//cq/FH/n/0.0#0': 't1=HL t2=WA',
    'none//cq/FP/i/0.12#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'none//cq/FP/n/0.01#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'none//cq/FT/i/0.012#0': 't1=HL t2=WA',
    'none//cq/FT/n/0.012#0': 't1=HL t2=WA z1=WA z2=WA',
    'none//cq/HA/i/0.12#0': 't1=WA t2=BC',
    'none//cq/HA/n/0.12#0': 't1=WA t2=BC',
    'none//cq/HB/i/0.12#0': 't1=WA t2=BC',
    'none//cq/HB/n/0.12#0': 't1=WA t2=BC',
    'none//cq/HF/i/0.1#0': 't1=HL t2=WA',
    'none//cq/HF/n/0.1#0': 't1=HL t2=WA',
    'none//cq/HH/i/0.1#0': 't1=WA t2=BC',
    'none//cq/HH/n/0.1#0': 't1=WA t2=BC',
    'none//cq/HP/i/0.12#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'none//cq/HP/n/0.12#0': 'lo1=0 lo2=0 t1=HL t2=WA',
    'none//cq/HT/i/0.120#0': 't1=WA t2=BC',
    'none//cq/HT/n/0.120#0': 't1=WA t2=BC z1=WA z2=WA',
    'none//cq/PA/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'none//cq/PA/n/01.21#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'none//cq/PB/i/01.23#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'none//cq/PB/n/01.21#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'none//cq/PF/i/01.2#0': 'm1=WA m2=WA q1=WA q2=BC t1=HL t2=WA',
    'none//cq/PF/n/01.2#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'none//cq/PH/i/01.2#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'none//cq/PH/n/01.1#0': 'lo1=0 lo2=0 t1=IZ t2=HL',
    'none//cq/PP/i/01.23#0': 'm1=WA m2=WA q1=BC q2=BC t1=DE t2=WA',
    'none//cq/PP/n/01.12#0': 'lo1=1 lo2=0 t1=IZ t2=HL',
    'none//cq/PT/i/01.234#0': 'm1=WA m2=WA q1=BC q2=WA t1=BC t2=WA',
    'none//cq/PT/n/01.120#0': 'lo1=0 lo2=1 t1=IZ t2=HL z1=WA z2=WA',
    'none//cq/TA/i/012.21#0': 't1=WA t2=BC',
    'none//cq/TA/n/012.21#0': 't1=BC t2=WA z1=WA z2=WA',
    'none//cq/TB/i/012.21#0': 't1=WA t2=BC',
    'none//cq/TB/n/012.21#0': 't1=BC t2=WA z1=WA z2=WA',
    'none//cq/TF/i/012.2#0': 't1=HL t2=WA',
    'none//cq/TF/n/012.2#0': 't1=HL t2=WA z1=WA z2=WA',
    'none//cq/TH/i/012.1#0': 't1=WA t2=BC',
    'none//cq/TH/n/012.1#0': 't1=BC t2=WA z1=WA z2=WA',
    'none//cq/TP/i/012.34#0': 'm1=WA m2=WA q1=BC q2=WA t1=WA t2=BC',
    'none//cq/TP/n/012.12#0': 'lo1=0 lo2=0 t1=HL t2=WA z1=WA z2=WA',
    'none//cq/TT/i/012.120#0': 't1=WA t2=BC',
    'none//cq/TT/n/012.120#0': 't1=BC t2=WA z1=WA z2=WA',
    'none/loop/cc/Gr/l#5': 'a=WA',
    'none/loop/cc/Xl:i!=/i#4': 'a=DE b=BC h=WA i=WA',
    'none/loop/cp/G/P#0': 'a=WA q=BC',
    'none/loop/cp/sD/P#2': 'a=WA p=BC q=WA',
    'none/loop/cx/G/X/i#2': 'a=WA b=DE h=BC i=BC',
    'none/loop/cx/R/X/b#2': 'a=WA b=DE i=BC',
}

# cp register roles: '<set>/<ctx>/<right kind>' -> roles per element type column (as CX_ROLES); right kinds: P a
# pointer's target at a constant offset (*hcp, hcp[2], hps->ac[4]), D a member through a pointer, A an array member
# through a pointer at a parameter index, T a local pointer's target.  Roles: q the right operand's pointer, h j i
# the index (value, sum with the member offset, its low byte), p a and pp as in CX_ROLES.
CP_ROLES = {
    'O3XS/cp/D/A': ('a=WA h=DE i=DE j=DE p=HL q=BC', 'a=WA h=HL i=HL j=HL p=BC q=DE', 'a=WA h=WA i=HL j=WA p=BC q=DE', 'a=WA h=WA i=HL j=WA p=BC q=DE'),
    'O3XS/cp/D/D': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XS/cp/D/P': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XS/cp/D/T': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XS/cp/E/A': ('a=WA h=DE i=DE j=DE q=BC', 'a=WA h=DE i=DE j=DE q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'O3XS/cp/E/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/E/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/E/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/G/A': ('a=WA h=DE i=DE j=DE q=BC', 'a=WA h=DE i=DE j=DE q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'O3XS/cp/G/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/G/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/G/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/R/A': ('a=WA h=DE i=DE j=DE q=BC', 'a=WA h=DE i=DE j=DE q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'O3XS/cp/R/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/R/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/R/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XS/cp/sD/A': ('a=WA h=BC i=BC j=BC p=DE q=WA', 'a=WA h=DE i=DE j=DE p=BC q=WA', 'a=WA h=WA i=DE j=WA p=BC q=WA', 'a=WA h=WA i=DE j=WA p=BC q=WA'),
    'O3XS/cp/sD/D': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XS/cp/sD/P': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XS/cp/sD/T': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XS/cp/sE/A': ('a=WA h=BC i=BC j=BC q=WA', 'a=WA h=BC i=BC j=BC q=WA', 'a=WA h=WA i=BC j=WA q=WA', 'a=WA h=WA i=BC j=WA q=WA'),
    'O3XS/cp/sE/D': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'O3XS/cp/sE/P': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'O3XS/cp/sE/T': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'O3XSXr/cp/D/A': ('a=WA i=DE j=BC p=WA q=BC', 'a=WA i=DE j=BC p=WA q=BC', 'a=WA i=HL j=BC p=DE q=BC', 'a=WA i=HL j=BC p=DE q=BC'),
    'O3XSXr/cp/D/D': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XSXr/cp/D/P': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XSXr/cp/D/T': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'O3XSXr/cp/E/A': ('a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC'),
    'O3XSXr/cp/E/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/E/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/E/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/G/A': ('a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC'),
    'O3XSXr/cp/G/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/G/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/G/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'O3XSXr/cp/R/A': ('a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC'),
    'O3XSXr/cp/R/D': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'O3XSXr/cp/R/P': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'O3XSXr/cp/R/T': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'O3XSXr/cp/sD/A': ('a=WA i=BC j=BC p=DE q=WA', 'a=WA i=BC j=BC p=DE q=WA', 'a=WA i=BC j=BC p=DE q=WA', 'a=WA i=BC j=BC p=DE q=WA'),
    'O3XSXr/cp/sD/D': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XSXr/cp/sD/P': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XSXr/cp/sD/T': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'O3XSXr/cp/sE/A': ('a=WA i=BC j=BC q=WA', 'a=WA i=BC j=BC q=WA', 'a=WA i=BC j=BC q=WA', 'a=WA i=BC j=BC q=WA'),
    'O3XSXr/cp/sE/D': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'O3XSXr/cp/sE/P': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'O3XSXr/cp/sE/T': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'Xr/cp/D/A': ('a=WA i=DE j=BC p=WA q=BC', 'a=WA i=DE j=BC p=WA q=BC', 'a=WA i=HL j=WA p=DE q=BC', 'a=WA i=HL j=WA p=DE q=BC'),
    'Xr/cp/D/D': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'Xr/cp/D/P': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'Xr/cp/D/T': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'Xr/cp/E/A': ('a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=WA q=BC', 'a=WA i=DE j=WA q=BC'),
    'Xr/cp/E/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/E/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/E/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/G/A': ('a=WA i=DE j=BC q=BC', 'a=WA i=DE j=BC q=BC', 'a=WA i=DE j=WA q=BC', 'a=WA i=DE j=WA q=BC'),
    'Xr/cp/G/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/G/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/G/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'Xr/cp/R/A': ('a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC', 'a=BC i=DE j=BC q=BC'),
    'Xr/cp/R/D': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'Xr/cp/R/P': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'Xr/cp/R/T': ('a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC', 'a=BC q=BC'),
    'Xr/cp/sD/A': ('a=WA i=BC j=BC p=DE q=WA', 'a=WA i=BC j=BC p=DE q=WA', 'a=WA i=BC j=WA p=DE q=WA', 'a=WA i=BC j=WA p=DE q=WA'),
    'Xr/cp/sD/D': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'Xr/cp/sD/P': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'Xr/cp/sD/T': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'Xr/cp/sE/A': ('a=WA i=BC j=BC q=WA', 'a=WA i=BC j=BC q=WA', 'a=WA i=BC j=WA q=WA', 'a=WA i=BC j=WA q=WA'),
    'Xr/cp/sE/D': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'Xr/cp/sE/P': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'Xr/cp/sE/T': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'none/cp/D/A': ('a=WA h=WA i=DE j=WA p=HL q=BC', 'a=WA h=WA i=HL j=WA p=BC q=DE', 'a=WA h=WA i=HL j=WA p=BC q=DE', 'a=WA h=WA i=HL j=WA p=BC q=DE'),
    'none/cp/D/D': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'none/cp/D/P': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'none/cp/D/T': ('a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC', 'a=WA p=WA q=BC'),
    'none/cp/E/A': ('a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'none/cp/E/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/E/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/E/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/G/A': ('a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'none/cp/G/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/G/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/G/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/R/A': ('a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC', 'a=WA h=WA i=DE j=WA q=BC'),
    'none/cp/R/D': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/R/P': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/R/T': ('a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC', 'a=WA q=BC'),
    'none/cp/sD/A': ('a=WA h=WA i=BC j=WA p=DE q=WA', 'a=WA h=WA i=DE j=WA p=BC q=WA', 'a=WA h=WA i=DE j=WA p=BC q=WA', 'a=WA h=WA i=DE j=WA p=BC q=WA'),
    'none/cp/sD/D': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'none/cp/sD/P': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'none/cp/sD/T': ('a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA', 'a=WA p=BC q=WA'),
    'none/cp/sE/A': ('a=WA h=WA i=BC j=WA q=WA', 'a=WA h=WA i=BC j=WA q=WA', 'a=WA h=WA i=BC j=WA q=WA', 'a=WA h=WA i=BC j=WA q=WA'),
    'none/cp/sE/D': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'none/cp/sE/P': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
    'none/cp/sE/T': ('a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA', 'a=WA q=WA'),
}

# cc register roles: '<set>/<other kind><side>/<source type>' -> roles per target type (c b i u l n); other kind G
# (a global), R (the parameter), X (an element at the char parameter); side l: the cast is the left operand.  Roles:
# a the cast's register, h i b the element index as in CX_ROLES.
CC_ROLES = {
    'O3XS/cc/Gl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XS/cc/Gl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XS/cc/Gl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XS/cc/Gr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Gr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XS/cc/Gr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XS/cc/Gr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XS/cc/Rl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XS/cc/Rl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XS/cc/Rl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XS/cc/Rr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XS/cc/Rr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XS/cc/Rr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XS/cc/Rr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XS/cc/Xl/b': ('a=BC b=BC i=WA', '-', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cc/Xl/c': ('-', 'a=BC b=BC i=WA', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cc/Xl/i': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', '-', 'a=DE b=BC h=BC i=WA', 'a=DE b=BC h=WA i=WA', 'a=DE b=BC h=WA i=WA'),
    'O3XS/cc/Xl/l': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', '-', 'a=DE b=BC h=WA i=WA'),
    'O3XS/cc/Xl/n': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=DE b=BC h=WA i=WA', '-'),
    'O3XS/cc/Xl/u': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=DE b=BC h=BC i=WA', '-', 'a=DE b=BC h=WA i=WA', 'a=DE b=BC h=WA i=WA'),
    'O3XS/cc/Xr/b': ('a=WA b=BC i=DE', '-', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cc/Xr/c': ('-', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC'),
    'O3XS/cc/Xr/i': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', '-', 'a=DE b=BC h=BC i=WA', 'a=DE b=BC h=WA i=WA', 'a=DE b=BC h=WA i=WA'),
    'O3XS/cc/Xr/l': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', '-', 'a=DE b=BC h=WA i=WA'),
    'O3XS/cc/Xr/n': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE h=BC i=BC', 'a=WA b=DE h=BC i=BC', 'a=DE b=BC h=WA i=WA', '-'),
    'O3XS/cc/Xr/u': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=DE b=BC h=BC i=WA', '-', 'a=DE b=BC h=WA i=WA', 'a=DE b=BC h=WA i=WA'),
    'O3XSXr/cc/Gl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XSXr/cc/Gl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XSXr/cc/Gl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Gr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'O3XSXr/cc/Gr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'O3XSXr/cc/Gr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'O3XSXr/cc/Rl/b': ('a=BC', '-', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rl/c': ('-', 'a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rl/i': ('a=BC', 'a=BC', '-', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rl/l': ('a=BC', 'a=BC', 'a=BC', 'a=BC', '-', 'a=BC'),
    'O3XSXr/cc/Rl/n': ('a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC', '-'),
    'O3XSXr/cc/Rl/u': ('a=BC', 'a=BC', 'a=BC', '-', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rr/b': ('a=BC', '-', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rr/c': ('-', 'a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rr/i': ('a=BC', 'a=BC', '-', 'a=BC', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Rr/l': ('a=BC', 'a=BC', 'a=BC', 'a=BC', '-', 'a=BC'),
    'O3XSXr/cc/Rr/n': ('a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC', '-'),
    'O3XSXr/cc/Rr/u': ('a=BC', 'a=BC', 'a=BC', '-', 'a=BC', 'a=BC'),
    'O3XSXr/cc/Xl/b': ('a=DE b=WA i=BC', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cc/Xl/c': ('-', 'a=DE b=WA i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cc/Xl/i': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'O3XSXr/cc/Xl/l': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=WA i=BC'),
    'O3XSXr/cc/Xl/n': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=WA i=BC', '-'),
    'O3XSXr/cc/Xl/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'O3XSXr/cc/Xr/b': ('a=DE b=WA i=BC', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cc/Xr/c': ('-', 'a=DE b=WA i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'O3XSXr/cc/Xr/i': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'O3XSXr/cc/Xr/l': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=WA i=BC'),
    'O3XSXr/cc/Xr/n': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=WA i=BC', '-'),
    'O3XSXr/cc/Xr/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'Xr/cc/Gl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'Xr/cc/Gl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'Xr/cc/Gl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'Xr/cc/Gr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'Xr/cc/Gr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'Xr/cc/Gr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'Xr/cc/Gr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'Xr/cc/Rl/b': ('a=BC', '-', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rl/c': ('-', 'a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rl/i': ('a=BC', 'a=BC', '-', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rl/l': ('a=BC', 'a=BC', 'a=BC', 'a=BC', '-', 'a=BC'),
    'Xr/cc/Rl/n': ('a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC', '-'),
    'Xr/cc/Rl/u': ('a=BC', 'a=BC', 'a=BC', '-', 'a=BC', 'a=BC'),
    'Xr/cc/Rr/b': ('a=BC', '-', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rr/c': ('-', 'a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rr/i': ('a=BC', 'a=BC', '-', 'a=BC', 'a=BC', 'a=BC'),
    'Xr/cc/Rr/l': ('a=BC', 'a=BC', 'a=BC', 'a=BC', '-', 'a=BC'),
    'Xr/cc/Rr/n': ('a=BC', 'a=BC', 'a=BC', 'a=BC', 'a=BC', '-'),
    'Xr/cc/Rr/u': ('a=BC', 'a=BC', 'a=BC', '-', 'a=BC', 'a=BC'),
    'Xr/cc/Xl/b': ('a=DE b=WA i=BC', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cc/Xl/c': ('-', 'a=DE b=WA i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cc/Xl/i': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'Xr/cc/Xl/l': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=WA i=BC'),
    'Xr/cc/Xl/n': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=WA i=BC', '-'),
    'Xr/cc/Xl/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'Xr/cc/Xr/b': ('a=DE b=WA i=BC', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cc/Xr/c': ('-', 'a=DE b=WA i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'Xr/cc/Xr/i': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'Xr/cc/Xr/l': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=WA i=BC'),
    'Xr/cc/Xr/n': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=WA i=BC', '-'),
    'Xr/cc/Xr/u': ('a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-', 'a=DE b=WA i=BC', 'a=DE b=WA i=BC'),
    'none/cc/Gl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'none/cc/Gl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'none/cc/Gl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'none/cc/Gr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Gr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'none/cc/Gr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'none/cc/Gr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'none/cc/Rl/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rl/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rl/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rl/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'none/cc/Rl/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'none/cc/Rl/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'none/cc/Rr/b': ('a=WA', '-', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rr/c': ('-', 'a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rr/i': ('a=WA', 'a=WA', '-', 'a=WA', 'a=WA', 'a=WA'),
    'none/cc/Rr/l': ('a=WA', 'a=WA', 'a=WA', 'a=WA', '-', 'a=WA'),
    'none/cc/Rr/n': ('a=WA', 'a=WA', 'a=WA', 'a=WA', 'a=WA', '-'),
    'none/cc/Rr/u': ('a=WA', 'a=WA', 'a=WA', '-', 'a=WA', 'a=WA'),
    'none/cc/Xl/b': ('a=BC b=BC i=WA', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cc/Xl/c': ('-', 'a=BC b=BC i=WA', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cc/Xl/i': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', '-', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA'),
    'none/cc/Xl/l': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA'),
    'none/cc/Xl/n': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-'),
    'none/cc/Xl/u': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=DE b=BC i=WA', '-', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA'),
    'none/cc/Xr/b': ('a=WA b=BC i=DE', '-', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cc/Xr/c': ('-', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC'),
    'none/cc/Xr/i': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', '-', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA'),
    'none/cc/Xr/l': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', '-', 'a=DE b=BC i=WA'),
    'none/cc/Xr/n': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=WA b=DE i=BC', 'a=WA b=DE i=BC', 'a=DE b=BC i=WA', '-'),
    'none/cc/Xr/u': ('a=WA b=BC i=DE', 'a=WA b=BC i=DE', 'a=DE b=BC i=WA', '-', 'a=DE b=BC i=WA', 'a=DE b=BC i=WA'),
}


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--check':
        show = int(a[a.index('--show') + 1]) if '--show' in a else 0
        only = a[a.index('--only') + 1] if '--only' in a else None
        sets = [x for x in a[1:] if x in SETS] or list(SETS)
        for s in sets:
            check(s, show, only)
