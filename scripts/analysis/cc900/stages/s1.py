#!/usr/bin/env python3
"""Stage S1 of the rebuilt back end (README.md): from thc1's operations (S0) to the instruction list V4.23's thc2 holds
before code selection, printed in the form of its `-zio` dump so that the two can be compared line by line
(s1_check.py).

Written from our description of thc2 (feedback plan section 13; this directory's README), and fitted on thc2's dumps
of the firmware C (runs 2026-11-22-51..54) with s1_check.py's worklist.  What it does, without optimisation (the
`-Xr` and no-option files; the `-O` passes are later work):
  - locals I<n>, parameters P<n> and the temporaries that survive are renumbered from 0 (temporaries in the order
    thc1 declared them);
  - the result temporary thc1 gives every assignment and compound assignment is dropped unless something reads it;
  - a compare whose only use is the next FALSE / TRUE becomes one branch (FALSE of `<` is BGE, ...); a test of one
    bit against zero (`x & 2^k` then == / != 0) becomes JRBC / JRBS x,#k;
  - `x * 2` becomes `x + x`; a pointer plus an integer becomes ADD, the pointer first; adding a constant 0 is a copy;
  - an assignment between different basic types is CONV; a structure assignment is LDIR;
  - `T = x; x += 1` with T unread becomes `x ++ 1` (likewise `--`);
  - a temporary written once and copied once into a local, a parameter or A is replaced by that destination;
  - a temporary written exactly once is printed with (Def);
  - every operation carries a block number: a block starts at each label, at each call, after a call and after a
    conditional branch; thc1's repeated END after the function's last line marker is dropped.

    python3 -B scripts/analysis/cc900/stages/s1.py FILE.inter          prints our S1 for every function
"""
import re
import sys

import s0

BASIC = ['VOID', 'SCHAR', 'UCHAR', 'SSHORT', 'USHORT', 'SINT', 'UINT', 'SLONG', 'ULONG', 'FLOAT', 'DOUBLE', 'LDOUBLE']
SIGNED = {2: True, 3: False, 4: True, 5: False, 6: True, 7: False, 8: True, 9: False}
SIZE = {1: 0, 2: 1, 3: 1, 4: 2, 5: 2, 6: 2, 7: 2, 8: 4, 9: 4, 10: 4, 11: 8, 12: 10}
CMP = {'<': ('BLT', 'BGE'), '<=': ('BLE', 'BGT'), '>': ('BGT', 'BLE'), '>=': ('BGE', 'BLT'), '==': ('BEQ', 'BNE'),
       '!=': ('BNE', 'BEQ')}
BRANCHES = {'BLT', 'BGE', 'BLE', 'BGT', 'BEQ', 'BNE', 'JRBC', 'JRBS'}
COMPOUND = {'=', '+=', '-=', '*=', '/=', '%=', '<<=', '>>=', '&=', '|=', '^='}
BINARY = {'+', '-', '*', '/', '%', '<<', '>>', '&', '|', '^'}
CALLS = {'CCALL', 'CCALP', 'ACALL', 'ACALP'}
ARGS = {'CARG', 'AARG'}
MARKERS = {'LINE', '{', '}', 'FILE'}


def num(t):
    return int(t) if t is not None and str(t).lstrip('-').isdigit() else 0


def type_name(t):
    t = num(t)
    if 1 <= t <= 12:
        return BASIC[t - 1]
    if 17 <= t <= 28:
        return '%s F*' % BASIC[t - 17]
    if 33 <= t <= 44:
        return '%s N*' % BASIC[t - 33]
    return '%d' % t


class Types:
    """thc1's type table of one file: id -> fields (`<id>,<kind>,...`; kinds a p s u x c v t b)"""

    def __init__(self, u):
        self.t = {}
        for l in u.header + u.between + [d for f in u.functions for d in f.decls]:
            if l.kind == 'decl' and l.fields[0].isdigit() and len(l.fields) > 1:
                self.t[int(l.fields[0])] = l.fields

    def kind(self, t):
        t = num(t)
        seen = 0
        while t in self.t and self.t[t][1] in ('c', 'v', 't') and seen < 8:   # qualifiers / typedefs: their base
            t, seen = num(self.t[t][2]), seen + 1
        if 1 <= t <= 12:
            return 'basic'
        if 17 <= t <= 28 or 33 <= t <= 44:
            return 'p'
        return self.t[t][1] if t in self.t else '?'

    def is_ptr(self, t):
        return self.kind(t) == 'p'

    def is_basic(self, t):
        return 1 <= num(t) <= 12

    def pointee(self, t):
        t = num(t)
        if 17 <= t <= 28:
            return t - 16
        if 33 <= t <= 44:
            return t - 32
        if t in self.t and self.t[t][1] == 'p':
            return num(self.t[t][2])
        return 0


class Fn:
    def __init__(self, f, symtypes, types=None):
        self.f = f
        self.symtypes = symtypes
        self.types = types
        self.ltype = {k: v[2] for k, v in f.locals.items()}
        self.ptype = {'P%d' % (i + 1): p[2] for i, p in enumerate(f.params)}
        self.ttype = dict(f.temps)

    def typ(self, x):
        if x is None:
            return None
        x = x.lstrip('*&')
        if x.startswith('I'):
            return self.ltype.get(x)
        if x.startswith('P'):
            return self.ptype.get(x)
        if x.startswith('T'):
            return self.ttype.get(x)
        if x.startswith('@'):
            return self.symtypes.get(x)
        return None

    def vtype(self, x):
        """the type of the value an operand denotes (a dereference: the pointee)"""
        t = self.typ(x)
        if x and x.startswith('*') and self.types:
            return self.types.pointee(t)
        return num(t)


def outputs(op, fl):
    """the fields an operation line writes"""
    if op in COMPOUND:
        return [x for x in (fl[1], fl[3] if len(fl) > 3 else None) if x]
    if op in BINARY or op in CMP or op == 'ADDR' or op in CALLS or op in ('UMINUS', 'UPLUS', '~'):
        return [fl[3]] if len(fl) > 3 and fl[3] else []
    return []


def inputs(op, fl):
    if op == '=':                                   # a plain assignment reads only its source
        return [x for x in fl[2:3] if x] + ([fl[1]] if fl[1].startswith('*') else [])
    if op in COMPOUND or op in BINARY or op in CMP or op in CALLS or op == 'ADDR' or op in ('UMINUS', 'UPLUS', '~'):
        return [x for x in fl[1:3] if x]
    return [x for x in fl[1:] if x]


def pow2(c):
    m = re.match(r'^#[LC]?U?(\d+)$', c or '')
    if not m:
        return None
    v = int(m.group(1))
    return v.bit_length() - 1 if v and v & (v - 1) == 0 else None


def rewrite(F):
    """the S1 list of (op, result, a, b) tuples, operands in thc1's spelling"""
    T = F.types
    F.kept = set()
    ops = []
    for l in F.f.ops:                               # the repeated END after the last line marker goes
        if l.kind != 'op':
            continue
        if l.op == 'END' and [o for o in ops if o.op not in MARKERS][-1:] and \
                [o for o in ops if o.op not in MARKERS][-1].op == 'END':
            continue
        ops.append(l)
    F.writes = {}
    for l in ops:
        for x in outputs(l.op, l.fields):
            if x.startswith('T'):
                F.writes[x] = F.writes.get(x, 0) + 1
    reads = {}
    for l in ops:
        for x in inputs(l.op, l.fields):
            x = x.lstrip('*&')
            if x.startswith('T'):
                reads[x] = reads.get(x, 0) + 1
    out = []
    i = 0
    while i < len(ops):
        l = ops[i]
        op, fl = l.op, l.fields
        nxt = ops[i + 1] if i + 1 < len(ops) else None
        if op in CMP and nxt is not None and nxt.op in ('FALSE', 'TRUE') and nxt.fields[1] == fl[3] and \
                reads.get(fl[3], 0) == 1:
            br = CMP[op][1] if nxt.op == 'FALSE' else CMP[op][0]
            if br in ('BEQ', 'BNE') and re.match(r'^#[LC]?U?0$', fl[2]) and out and out[-1][0] == '&' and \
                    out[-1][1] == fl[1] and reads.get(fl[1], 0) == 1 and pow2(out[-1][3]) is not None:
                prev = out.pop()                    # (x & 2^k) == 0 -> JRBC x,#k
                F.kept.add(prev[1])                 # (a later stage: the temporary keeps its number)
                k = pow2(prev[3])
                pre = re.match(r'^#([LC]?U?)', prev[3]).group(1)
                out.append(('JRBC' if br == 'BEQ' else 'JRBS', nxt.fields[3], prev[2], '#%s%d' % (pre, k)))
            else:
                out.append((br, nxt.fields[3], fl[1], fl[2]))
            i += 2
            continue
        if op == '=' and len(fl) > 3 and fl[1] == fl[3] and fl[1].startswith('T') and nxt is not None and \
                nxt.op in ('+=', '-=') and nxt.fields[1] == fl[2] and nxt.fields[2].startswith('#'):
            if reads.get(fl[1], 0):                 # post-increment: the old value, when read, then x ++ c
                out.append(('=', fl[1], fl[2], None))
            out.append(('++' if nxt.op == '+=' else '--', fl[2], '#' + nxt.fields[2][1:], None))
            i += 2
            continue
        if op in ('|=', '&=') and fl[2].startswith('#'):
            m = re.match(r'^#([LC]?)(U?)(\d+)$', fl[2])
            t = F.vtype(fl[1])
            bits = SIZE.get(t, 2) * 8 if 1 <= t <= 12 else 16
            v = int(m.group(3)) if m else None
            if v is not None and op == '&=':
                v = ~v & ((1 << bits) - 1)
            if v is not None and pow2('#%d' % v) is not None and v < (1 << bits):
                out.append(('BSET' if op == '|=' else 'BCLR', fl[1], '#%s%s%d' % (m.group(1), m.group(2), pow2('#%d' % v)),
                            None))
                i += 1
                continue
        if op in COMPOUND:
            o = op
            if op == '=':
                dt, st = F.vtype(fl[1]), F.vtype(fl[2])
                if T and T.kind(dt) in ('s', 'u'):
                    o = 'LDIR'
                elif T and T.is_basic(dt) and T.is_basic(st) and (SIZE[dt] != SIZE[st] or SIGNED.get(dt) != SIGNED.get(st)):
                    o = 'CONV'
            out.append((o, fl[1], fl[2], None))
        elif op in BINARY:
            pa, pb = T and T.is_ptr(F.typ(fl[1])), T and T.is_ptr(F.typ(fl[2]))
            if op == '*' and re.match(r'^#[LC]?U?2$', fl[2]):
                out.append(('+', fl[3], fl[1], fl[1]))
            elif op == '+' and (pa or pb):
                a, b = (fl[1], fl[2]) if pa else (fl[2], fl[1])
                if re.match(r'^#[LC]?U?0$', b):
                    out.append(('=', fl[3], a, None))
                elif (b.startswith('#L') if b.startswith('#') else SIZE.get(num(F.typ(b)), 4) == 4):
                    out.append(('+', fl[3], a, b))     # a 4-byte offset: `+`, the pointer first
                else:
                    out.append(('ADD', fl[3], a, b))   # a 1- or 2-byte offset: ADD
            else:
                out.append((op, fl[3], fl[1], fl[2]))
        elif op == 'ADDR':
            out.append(('ADDR', fl[3], fl[1], None))
        elif op in CALLS:                            # CCALL,@f,#argbytes,T: the result first, as the others
            res_ = fl[3] if len(fl) > 3 and F.typ(fl[3]) not in ('1', None) and reads.get(fl[3], 0) else None
            out.append((op, res_, fl[1], fl[2]))
        elif op in ARGS:                             # AARG,value,call,index: the index is kept
            out.append((op, None, fl[1], fl[3] if op == 'AARG' and len(fl) > 3 else None))
        else:
            out.append((op,) + tuple(fl[1:4]) + (None,) * (3 - len(fl[1:4])))
        i += 1
    alias = {}                                       # consecutive labels: the last one stands for all of them
    run = []
    for r in out:
        if r[0] in MARKERS:
            continue
        if r[0] == 'LAB':
            run.append(r[1])
            continue
        for x in run[:-1]:
            alias[x] = run[-1]
        run = []
    for x in run[:-1]:
        alias[x] = run[-1]
    out = [r for r in out if not (r[0] == 'LAB' and r[1] in alias)]
    out = [(r[0], alias.get(r[1], r[1])) + r[2:] if r[0] in BRANCHES or r[0] == 'JMP' else r for r in out]
    out = [r for k, r in enumerate(out)               # a jump to the label that follows it goes
           if not (r[0] == 'JMP' and next((x for x in out[k + 1:] if x[0] not in MARKERS), (None, None))[:2] ==
                   ('LAB', r[1]))]
    res = []                                         # a temporary copied once into its destination: write that
    for r in out:
        if r[0] == '=' and r[2] and r[2].startswith('T') and res and res[-1][1] == r[2] and reads.get(r[2], 0) == 1 \
                and F.typ(r[1]) == F.typ(r[2]):
            prev = res.pop()
            res.append((prev[0], r[1]) + prev[2:])
            continue
        res.append(r)
    return res


def number(F, recs):
    """renumber I / P / T from 0 (T in declaration order, surviving ones only); the temporaries written once"""
    live_t = set()
    writes = {}
    for r in recs:
        for x in r[1:4]:
            if x and x.lstrip('*&').startswith('T'):
                live_t.add(x.lstrip('*&'))
        w = r[1]
        if w and not w.startswith('*') and w.startswith('T') and r[0] not in BRANCHES:
            writes[w] = writes.get(w, 0) + 1
    tmap = {}
    for t in F.f.temps:
        if t in live_t or t in getattr(F, 'kept', ()):
            tmap[t] = 'T%d' % len(tmap)

    def ren(x):
        if not x:
            return x
        pre = x[:len(x) - len(x.lstrip('*&'))]
        b = x[len(pre):]
        if b in tmap:
            return pre + tmap[b]
        m = re.match(r'^([IP])(\d+)$', b)
        if m:
            return pre + '%s%d' % (m.group(1), int(m.group(2)) - 1)
        return x
    reads = {}
    for r in recs:
        for x in (r[2:4] if r[0] not in BRANCHES else r[2:4]) + ((r[1],) if r[1] and r[1].startswith('*') else ()):
            if x and x.lstrip('*&').startswith('T'):
                reads[x.lstrip('*&')] = reads.get(x.lstrip('*&'), 0) + 1
    defs = {tmap[t] for t, n in writes.items() if n == 1 and t in tmap and reads.get(t, 0) <= 1}
    return [(r[0],) + tuple(ren(x) for x in r[1:4]) for r in recs], tmap, defs


def const(b):
    """thc1's #<n>, #U<n>, #L<n>, #LU<n>, #C<n>, #CU<n> as thc2 prints them: a size letter or a blank, then U, then
    the value"""
    m = re.match(r'^#([LC]?)(.*)$', b)
    return '#%s%s' % (m.group(1) or ' ', m.group(2))


def ctype(F, x, inv):
    """the basic type (1..12) or pointer-ness of the value operand x denotes, for typing a constant beside it"""
    if x is None or x.startswith('#'):
        return None
    b = x.lstrip('*&')
    orig = inv.get(b, b)
    if b[:1] in 'IP' and b[1:].isdigit():
        orig = '%s%d' % (b[0], int(b[1:]) + 1)
    t = num(F.typ(orig))
    if x.startswith('*') and F.types:
        t = F.types.pointee(t)
    if F.types and F.types.is_ptr(t):
        return 'ptr'
    return t if 1 <= t <= 12 else None


def typed_const(b, t):
    """a constant spelled as thc2 prints it beside a value of type t: C for 1 byte, L for 4, U unsigned"""
    m = re.match(r'^#([LC]?)(U?)(-?\d+)$', b)
    if not m or t is None:
        return const(b)
    if t == 'ptr':
        return '#LU%s' % m.group(3)
    size, uns = SIZE.get(t, 2), SIGNED.get(t) is False
    return '#%s%s%s' % ({1: 'C', 4: 'L'}.get(size, ' '), 'U' if uns else '', m.group(3))


def show(F, x, inv, defs, ctx=None):
    if x is None:
        return ''
    pre = x[:len(x) - len(x.lstrip('*&'))]
    b = x[len(pre):]
    if b.startswith('#'):
        return typed_const(b, ctx) if ctx is not None else const(b)
    if b == 'A':
        return 'A'
    if b.startswith('@'):
        return '%s@%s(%s)' % (pre, b[1:], type_name(F.symtypes.get(b, '?')) if b in F.symtypes else '?')
    orig = inv.get(b, b)
    if b[:1] in 'IP' and b[1:].isdigit():
        orig = '%s%d' % (b[0], int(b[1:]) + 1)
    return '%s%s(%s)%s' % (pre, b, type_name(F.typ(orig)), '(Def)' if b in defs else '')


def fmt(F, r, inv, defs):
    op, res, a, b = r
    S = lambda x: show(F, x, inv, defs)
    if op in COMPOUND or op in ('++', '--', 'BSET', 'BCLR') or op in BRANCHES and op not in ('JRBC', 'JRBS'):
        ct = ctype(F, res if op not in BRANCHES else a, inv) if op not in BRANCHES else \
            (ctype(F, a, inv) or ctype(F, b, inv))
        S = lambda x: show(F, x, inv, defs, ct)
    elif op in BINARY:
        ct = ctype(F, res, inv)
        S = lambda x: show(F, x, inv, defs, ct if op not in ('<<', '>>') else None)
    if op in BRANCHES:
        return '%s %s %s,%s' % (res, op, S(a), S(b))
    if op in BINARY or op == 'ADD':
        return '%s %s %s,%s' % (S(res), op, S(a), S(b))
    if op in COMPOUND or op in ('++', '--', 'CONV', 'LDIR', 'BSET', 'BCLR'):
        return '%s %s %s' % (S(res), op, S(a))
    if op == 'ADDR':
        return '%s ADDR %s' % (S(res), S(a))
    if op == 'LAB':
        return 'LAB,%s' % res
    if op == 'JMP':
        return 'JMP,%s' % res
    if op in ('BEGIN', 'END'):
        return op
    if op in ('ACALL', 'ACALP'):
        return '%s %s %s' % (S(res), op, S(a))
    if op in CALLS:
        return '%s %s %s #%s' % (S(res), op, S(a), b.lstrip('#'))
    if op in ARGS:
        if a.startswith('#'):
            n = 4 if a.startswith('#L') else 2
        else:
            orig = inv.get(a.lstrip('*&'), a) if a[:1] not in 'IP' else '%s%d' % (a[0], int(a[1:]) + 1)
            t = num(F.typ(orig))
            n = SIZE.get(t, 4) if 1 <= t <= 12 else 4
        if op == 'AARG' and b:
            k = int(b)
            if k <= 3:
                F.aarg_off = 0
                return '%s %s #0,%d' % (op, S(a), k)
            F.aarg_off = getattr(F, 'aarg_off', 0) + max(n, 2)
            return '%s %s #%d,%d' % (op, S(a), F.aarg_off, k)
        return '%s %s #%d' % (op, S(a), n)
    return '%s %s' % (op, ' '.join(S(x) for x in (res, a, b) if x))


ARG_COPIES = True


def arg_copies(F, blocked, tmap, inv, defs):
    """a register argument (AARG) that is not a constant or a dereference goes through a new temporary of type 0,
    written right after the value's last definition in the call's block (else at the block's start); the new
    temporaries are numbered after thc1's, from the last call backwards"""
    base = len(tmap)
    for k in range(len(F.f.temps) + 1):
        if 'T%d' % k in inv:
            base = max(base, k + 1)
    sites = [i for i, (b, r) in enumerate(blocked) if r[0] == 'AARG' and r[2] and not r[2].startswith('#')
             and not r[2].startswith('*') and not r[2].startswith('&')]
    names = {}
    for n, i in enumerate(reversed(sites)):
        names[i] = 'T%d' % (base + n)
    inserts = []
    for i in sites:
        b, r = blocked[i]
        new = names[i]
        F.ttype_new = getattr(F, 'ttype_new', {})
        inv[new] = new
        F.ttype[new] = '0'
        defs.add(new)
        j = i - 1
        while j >= 0 and blocked[j][0] == b and blocked[j][1][1] != r[2]:
            j -= 1
        at = j + 1 if j >= 0 and blocked[j][0] == b else next(k for k in range(i + 1) if blocked[k][0] == b) + \
            (1 if blocked[next(k for k in range(i + 1) if blocked[k][0] == b)][1][0] == 'LAB' else 0)
        inserts.append((at, [b, ('=', new, r[2], None)]))
        blocked[i] = [b, (r[0], r[1], new, r[3])]
    for at, item in sorted(inserts, key=lambda x: -x[0]):
        blocked.insert(at, item)
    return blocked


def s1_text(F):
    recs = rewrite(F)
    recs, tmap, defs = number(F, recs)
    inv = {v: k for k, v in tmap.items()}
    blocked = []
    block, start, first = 0, False, True
    for r in recs:
        if r[0] in MARKERS:
            continue
        if (r[0] == 'LAB' or r[0] in CALLS or start) and not first:
            block += 1                             # a block starts at a label, at a call, after a call or a branch
        first, start = False, r[0] in CALLS or r[0] in BRANCHES
        blocked.append([block, r])
    if ARG_COPIES:
        blocked = arg_copies(F, blocked, tmap, inv, defs)
    out = ['   :   |FUNC_START']
    for block, r in blocked:
        out.append('%3u:   |%s' % (block, fmt(F, r, inv, defs)))
    out.append('   :   |FUNC_END')
    return out


def symtypes(u):
    t = {}
    for l in u.header + u.between + [d for f in u.functions for d in f.decls]:
        if l.kind == 'decl' and l.fields[0].startswith('@') and len(l.fields) > 2:
            t[l.fields[0]] = l.fields[2]
    return t


def functions(path):
    """[(S0 function, Fn)] of one thc1 file"""
    u = s0.load(path)
    st, ty = symtypes(u), Types(u)
    return [(f, Fn(f, st, ty)) for f in u.functions]


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    for p in sys.argv[1:]:
        for f, F in functions(p):
            print('\n'.join(s1_text(F)))
