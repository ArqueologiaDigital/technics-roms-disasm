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
CALLS = {'CCALL', 'CCALP', 'ACALL', 'ACALP', 'ARICALL'}
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


def mul_steps(res, x, c, pre='LU'):
    """res = x * c (c with one or two set bits) as thc2 expands it: the bits from the top; a single doubling is an
    add of the value to itself, a run of k doublings one shift by k, and each set bit adds x; the first step is
    three-address (from x), the others compound"""
    steps, first, pend = [], True, 0

    def flush(k):
        nonlocal first
        if k == 1:
            steps.append(('+', res, x, x) if first else ('+=', res, res, None))
        elif k > 1:
            steps.append(('<<', res, x, '#%s%d' % (pre, k)) if first else ('<<=', res, '#%s%d' % (pre, k), None))
        if k:
            first = False
    for bit in bin(c)[3:]:
        pend += 1
        if bit == '1':
            flush(pend)
            pend = 0
            steps.append(('+=', res, x, None))
    flush(pend)
    if not steps:
        steps.append(('=', res, x, None))
    return steps


SWITCH_MOVE = True
INVERT = {'BEQ': 'BNE', 'BNE': 'BEQ', 'BLT': 'BGE', 'BGE': 'BLT', 'BLE': 'BGT', 'BGT': 'BLE', 'JRBC': 'JRBS',
          'JRBS': 'JRBC'}


def move_dispatch(out):
    """a switch: thc1 jumps to a dispatch block (only compare branches) written after the cases and followed by a
    label; thc2 puts the dispatch where the jump was.  When its last branch then targets the label right below it,
    that branch is inverted and sent to the label that followed the dispatch"""
    i = 0
    while i < len(out):
        r = out[i]
        if r[0] == 'JMP':
            j = next((k for k in range(i + 1, len(out)) if out[k][0] == 'LAB' and out[k][1] == r[1]), None)
            if j is not None:
                k = j + 1
                while k < len(out) and (out[k][0] in BRANCHES or out[k][0] in MARKERS):
                    k += 1
                if k < len(out) and out[k][0] == 'JMP':   # a dispatch may end with a jump to the default case
                    k += 1
                disp = [x for x in out[j + 1:k] if x[0] in BRANCHES or x[0] == 'JMP']
                while k < len(out) and out[k][0] in MARKERS:
                    k += 1
                if disp and k < len(out) and out[k][0] in ('LAB', 'END') and \
                        not any(x[0] in ('JMP', 'LAB') and x[1] == r[1] for x in out[:j] + out[k:] if x is not r):
                    after = out[k][1]
                    body = out[i + 1:j] + out[k:]
                    nxt = next((x for x in out[i + 1:j] if x[0] not in MARKERS), None)
                    last = disp[-1]
                    if last[0] in BRANCHES and out[k][0] == 'LAB' and nxt is not None and nxt[0] == 'LAB' and \
                            nxt[1] == last[1]:
                        disp[-1] = (INVERT[last[0]], after) + tuple(last[2:])
                    out = out[:i] + disp + body
                    i += len(disp)
                    continue
        i += 1
    return out


def branch_over_jump(out):
    """B<cond> La / JMP Lb / LAB La  ->  B<inverse> Lb / LAB La, and La goes when nothing else jumps to it"""
    real = [k for k, r in enumerate(out) if r[0] not in MARKERS]
    drop = set()
    for n in range(len(real) - 2):
        a, b, c = (out[real[n + m]] for m in range(3))
        if a[0] in INVERT and b[0] == 'JMP' and c[0] == 'LAB' and c[1] == a[1] and real[n + 1] not in drop:
            out[real[n]] = (INVERT[a[0]], b[1]) + tuple(a[2:])
            drop.add(real[n + 1])
    out = [r for k, r in enumerate(out) if k not in drop]
    used = {r[1] for r in out if r[0] in BRANCHES or r[0] == 'JMP'}
    return [r for r in out if not (r[0] == 'LAB' and r[1] not in used)]


TEMP_COPY_MERGE = False                             # OPEN: thc2 merges some temp-to-temp copies at read time (the
                                                    # copy's temporary takes the source's definition: Audio_CmdHandler
                                                    # _00_1F, T7 = T8 of USHORT / UINT), but every variant tried so far
                                                    # (any copy; binary sources; differing types) loses more functions
                                                    # than it gains (767 -> 743 / 746 / 758 on -Xr, 2026-11-22)


def merge_temp_copies(F, ops):
    """read time: `=,Ta,Tb,Ta` copying a temporary Tb (read only there) into Ta of a basic integer type of the same
    size: Tb's definition writes Ta instead, and the copy goes (Tb gets no number)"""
    import thc1ir
    nreads = {}
    for l in ops:
        for x in inputs(l.op, l.fields):
            x = x.lstrip('*&')
            nreads[x] = nreads.get(x, 0) + 1
    ops = list(ops)
    k = 0
    while k < len(ops):
        l = ops[k]
        fl = l.fields
        if l.op == '=' and len(fl) > 3 and fl[1] == fl[3] and fl[1].startswith('T') and fl[2].startswith('T') and \
                nreads.get(fl[2], 0) == 1 and k > 0 and ops[k - 1].kind == 'op' and \
                outputs(ops[k - 1].op, ops[k - 1].fields)[-1:] == [fl[2]] and ops[k - 1].op in BINARY:
            ta, tb = num(F.typ(fl[1])), num(F.typ(fl[2]))
            if 1 <= ta <= 12 and 1 <= tb <= 12 and SIZE[ta] == SIZE[tb] and ta != tb:
                p = ops[k - 1]
                ops[k - 1] = thc1ir.Line('op', p.fields[:3] + [fl[1]] + p.fields[4:], p.raw)
                del ops[k]
                continue
        k += 1
    return ops


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
    if TEMP_COPY_MERGE:
        ops = merge_temp_copies(F, ops)
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
            if v is not None and (bits == 8 or re.match(r'^[IP]\d+$', fl[1])) and pow2('#%d' % v) is not None and \
                    v < (1 << bits):
                out.append(('BSET' if op == '|=' else 'BCLR', fl[1], '#%s%s%d' % (m.group(1), m.group(2), pow2('#%d' % v)),
                            None))
                i += 1
                continue
        if op in ('+=', '-=') and re.match(r'^#[LC]?U?([1-8])$', fl[2]):
            out.append(('++' if op == '+=' else '--', fl[1], fl[2], None))   # INC / DEC take 1..8
            i += 1
            continue
        if op in ('*=', '/=', '%=') and 1 <= F.vtype(fl[1]) <= 12 and SIZE[F.vtype(fl[1])] == 4:
            rt = F.vtype(fl[1])
            helper = {'*=': 'mul', '/=': 'div', '%=': 'rem'}[op] + ('lu' if SIGNED.get(rt) is False else 'ls')
            out.append(('ARICALL', fl[1], fl[1], fl[2], 'C9H_' + helper))
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
                elif T and (T.is_basic(dt) and T.is_ptr(st) or T.is_ptr(dt) and T.is_basic(st)):
                    o = 'CONV'                       # between a pointer and an integer
            out.append((o, fl[1], fl[2], None))
            if MEM_RESULT_NUMBERED and op == '=' and len(fl) > 3 and fl[3].startswith('T') and \
                    fl[1][:1] in '@*' and fl[2][:1] in '@*' and not reads.get(fl[3], 0):   # memory to memory
                F.kept.add(fl[3])                    # numbered although unread (dropped after numbering)
            if len(fl) > 3 and fl[3] and fl[3] != fl[1] and fl[3].startswith('T') and reads.get(fl[3], 0):
                out.append(('=', fl[3], fl[1].lstrip('&'), None))   # a read result: a copy of the target after it
        elif op in BINARY:
            pa, pb = T and T.is_ptr(F.typ(fl[1])), T and T.is_ptr(F.typ(fl[2]))
            rt = F.vtype(fl[3])
            cm = re.match(r'^#[LC]?U?(\d+)$', fl[2]) if op == '*' else None
            if cm and 1 <= rt <= 12 and SIZE[rt] == 4 and 0 < int(cm.group(1)) and bin(int(cm.group(1))).count('1') <= 2:
                out.extend(mul_steps(fl[3], fl[1], int(cm.group(1)), 'LU' if SIGNED.get(rt) is False else 'L'))
                i += 1                                                  # two set bits: shifts and adds
                continue
            if op in ('*', '/', '%') and 1 <= rt <= 12 and SIZE[rt] == 4:
                helper = {'*': 'mul', '/': 'div', '%': 'rem'}[op] + ('lu' if SIGNED.get(rt) is False else 'ls')
                out.append(('ARICALL', fl[3], fl[1], fl[2], 'C9H_' + helper))   # a 4-byte multiply / divide:
                i += 1                                                         # the runtime helper
                continue
            pm = re.match(r'^#([LC]?U?)(\d+)$', fl[2]) if op == '*' else None
            if pm and pow2(fl[2]) and pow2(fl[2]) > 1:
                out.append(('<<', fl[3], fl[1], '#%s%d' % (pm.group(1), pow2(fl[2]))))   # x * 2^k -> x << k
                i += 1
                continue
            if op == '*' and re.match(r'^#[LC]?U?2$', fl[2]):
                out.append(('+', fl[3], fl[1], fl[1]))
            elif op == '+' and (pa or pb):
                a, b = (fl[1], fl[2]) if pa else (fl[2], fl[1])
                if re.match(r'^#[LC]?U?0$', b):
                    out.append(('=', fl[3], a, None))
                elif (b.startswith('#L') if b.startswith('#') else SIZE.get(num(F.typ(b)), 4) == 4):
                    out.append(('+', fl[3], fl[1], fl[2]))   # a 4-byte offset: `+`, in thc1's order
                else:
                    out.append(('ADD', fl[3], a, b))   # a 1- or 2-byte offset: ADD
            else:
                out.append((op, fl[3], fl[1], fl[2]))
        elif op in CMP:                              # a compare whose value is used
            out.append((op, fl[3], fl[1], fl[2]))
        elif op == 'ADDR':
            out.append(('ADDR', fl[3], fl[1], None))
        elif op in CALLS:                            # CCALL,@f,#argbytes,T: the result first, as the others
            res_ = fl[3] if len(fl) > 3 and F.typ(fl[3]) not in ('1', None) and reads.get(fl[3], 0) else None
            spare = fl[3] if len(fl) > 3 and fl[3] and res_ is None else None
            out.append((op, res_, fl[1], fl[2]) + (('res:' + spare,) if spare and CALL_RES_COPY else ()))
        elif op in ('asm', 'ASM'):                   # inline assembler: its text as thc1 wrote it
            out.append((op, ','.join(fl[1:]), None, None))
        elif op in ARGS:                             # AARG,value,call,index: the index is kept
            out.append((op, None, fl[1], fl[3] if op == 'AARG' and len(fl) > 3 else None))
        else:
            out.append((op,) + tuple(fl[1:4]) + (None,) * (3 - len(fl[1:4])))
        i += 1
    if SWITCH_MOVE:
        out = move_dispatch(out)
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
    out = branch_over_jump(out)
    ends = set()                                     # a jump to a label whose block is just END: END
    real = [r for r in out if r[0] not in MARKERS]
    for k, r in enumerate(real[:-1]):
        if r[0] == 'LAB' and real[k + 1][0] == 'END':
            ends.add(r[1])
    out = [('END', None, None, None) if r[0] == 'JMP' and r[1] in ends else r for r in out]
    used = {r[1] for r in out if r[0] in BRANCHES or r[0] == 'JMP'}
    out = [r for r in out if not (r[0] == 'LAB' and r[1] not in used)]
    out = [r for k, r in enumerate(out)               # a jump to the label that follows it goes
           if not (r[0] == 'JMP' and next((x for x in out[k + 1:] if x[0] not in MARKERS), (None, None))[:2] ==
                   ('LAB', r[1]))]
    res = []                                         # a temporary copied once into its destination: write that
    for r in out:
        if r[0] == '=' and r[2] and r[2].startswith('T') and res and res[-1][1] == r[2] and reads.get(r[2], 0) == 1 \
                and (F.typ(r[1]) == F.typ(r[2]) or r[1] == 'A') and res[-1][0] != 'ADDR' and \
                (re.match(r'^([IP]\d+|A)$', r[1]) or
                                                    r[1].startswith('@') and res[-1][0] not in ('ADDR', 'CONV')):
            prev = res.pop()
            r = (prev[0], r[1]) + prev[2:]          # (and the chain rule below may apply to the folded line)
        if CHAIN_COMPOUND and r[0] in BINARY and r[1] and re.match(r'^([IP]\d+|A)$', r[1]) and r[2] and \
                r[2].startswith('T') and res and res[-1][1] == r[2] and reads.get(r[2], 0) == 1 and \
                (r[3] or '').lstrip('*&') != r[1] and F.typ(r[1]) == F.typ(r[2]) and res[-1][0] not in ('ADDR',):
            prev = res.pop()                         # T = ...; X = T op y  ->  X = ...; X op= y
            res.append((prev[0], r[1]) + prev[2:])
            rt = num(F.typ(r[1]))
            if r[0] in ('*', '/', '%') and 1 <= rt <= 12 and SIZE[rt] == 4:
                helper = {'*': 'mul', '/': 'div', '%': 'rem'}[r[0]] + ('lu' if SIGNED.get(rt) is False else 'ls')
                res.append(('ARICALL', r[1], r[1], r[3], 'C9H_' + helper))
            else:
                res.append((r[0] + '=', r[1], r[3], None))
            continue
        res.append(r)
    return res


CHAIN_COMPOUND = True


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
    spare = {r[4][4:] for r in recs if len(r) > 4 and str(r[4]).startswith('res:')}
    if CALL_RES_COPY:                                # an unread call result is numbered when an argument of its
        for k, r in enumerate(recs):                 # call is copied (it becomes that copy, arg_copies)
            if len(r) > 4 and str(r[4]).startswith('res:'):
                j = k - 1
                while j >= 0 and recs[j][0] == 'AARG':
                    j -= 1
                if any(x[2] and not x[2].startswith(('#', '*', '&')) for x in recs[j + 1:k]):
                    live_t.add(r[4][4:])
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
    for r in recs:                                  # a function pointer a call reads, and what it returns: no (Def)
        if r[0] in ('ACALP', 'CCALP'):
            for x in (r[1], r[2]):
                if x and x.lstrip('*&') in tmap:
                    defs.discard(tmap[x.lstrip('*&')])
    for t in list(writes):                          # ... and not when its source is written again before the read
        if t not in tmap or tmap[t] not in defs:
            continue
        di = next((i for i, r in enumerate(recs) if r[1] == t), None)
        ri = next((i for i, r in enumerate(recs) if i > (di or 0) and
                   any(x and x.lstrip('*&') == t for x in r[2:4] + ((r[1],) if r[1] and r[1].startswith('*') else ()))),
                  None)
        if di is None or ri is None:
            continue
        srcs = {x.lstrip('*&') for x in recs[di][2:4] if x and not x.startswith('#')}
        if any(r[1] and not r[1].startswith('*') and r[1] in srcs and r[0] not in BRANCHES for r in recs[di + 1:ri]):
            defs.discard(tmap[t])
    return [(r[0],) + tuple(ren(x) for x in r[1:4]) +
            tuple(('res:' + tmap[x[4:]] if x[4:] in tmap else None) if str(x).startswith('res:') else x
                  for x in r[4:]) for r in recs], tmap, defs


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
    if b in getattr(F, 'newtemps', ()):
        return '%s%s(0)%s' % (pre, b, '(Def)' if b in defs else '')
    orig = inv.get(b, b)
    if b[:1] in 'IP' and b[1:].isdigit():
        orig = '%s%d' % (b[0], int(b[1:]) + 1)
    return '%s%s(%s)%s' % (pre, b, type_name(F.typ(orig)), '(Def)' if b in defs else '')


def fmt(F, r, inv, defs):
    op, res, a, b = r[:4]
    S = lambda x: show(F, x, inv, defs)
    if op in COMPOUND or op in ('++', '--', 'BSET', 'BCLR') or op in BRANCHES and op not in ('JRBC', 'JRBS'):
        ct = ctype(F, res if op not in BRANCHES else a, inv) if op not in BRANCHES else \
            (ctype(F, a, inv) or ctype(F, b, inv))
        S = lambda x: show(F, x, inv, defs, ct if op not in ('<<', '>>') else None)
    elif op in CMP:
        ct = ctype(F, a, inv) or ctype(F, b, inv)
        S = lambda x: show(F, x, inv, defs, ct if op not in ('<<', '>>') else None)
        return '%s %s %s,%s' % (S(res), op, S(a), S(b))
    elif op in BINARY:
        ct = ctype(F, res, inv)
        S = lambda x: show(F, x, inv, defs, ct if op not in ('<<', '>>') else None)
    if op in ('JRBC', 'JRBS'):
        t = ctype(F, a, inv)
        m = re.match(r'^#[LC]?U?(\d+)$', b)
        size = SIZE.get(t, 1) if isinstance(t, int) else 1
        return '%s %s %s,#%sU%s' % (res, op, S(a), {1: 'C', 4: 'L'}.get(size, ' '), m.group(1))
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
    if op in ('asm', 'ASM'):
        return '%s,%s' % (op, res)
    if op == 'ARICALL':
        ct = ctype(F, res, inv)
        return '%s ARICALL %s,%s %s' % (S(res), S(a), show(F, b, inv, defs, ct), r[4])
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
MEM_RESULT_NUMBERED = False                         # OPEN: some unread assignment results are numbered (Voice_WriteChPanShift T75); "target in memory" variants lose 111-319 functions
CALL_RES_COPY = True


def arg_copies(F, blocked, tmap, inv, defs):
    """a register argument (AARG) that is not a constant or a dereference goes through a new temporary of type 0: the
    copy takes the AARG's place, and the call's AARGs all move to just before the call; the new temporaries are
    numbered after thc1's, from the last call backwards"""
    base = len(tmap)
    for k in range(len(F.f.temps) + 1):
        if 'T%d' % k in inv:
            base = max(base, k + 1)
    sites = [i for i, (b, r) in enumerate(blocked) if r[0] == 'AARG' and r[2] and not r[2].startswith('#')
             and not r[2].startswith('*') and not r[2].startswith('&') and (not r[3] or int(r[3]) <= 3)]
    given = {}
    for k, (b, r) in enumerate(blocked):             # the call's unread result temporary: its last copied argument
        if r[0] in ('ACALL', 'ACALP') and len(r) > 4 and r[4] and str(r[4]).startswith('res:'):
            mine = [i for i in sites if i < k and all(blocked[j][1][0] in ('AARG',) or j == i or
                                                      blocked[j][1][0] not in CALLS for j in range(i, k))]
            prevcall = max([j for j in range(k) if blocked[j][1][0] in CALLS] or [-1])
            mine = [i for i in mine if i > prevcall]
            if mine:
                given[mine[-1]] = r[4][4:]
    rest = [i for i in sites if i not in given]
    names = {i: 'T%d' % (base + n) for n, i in enumerate(reversed(rest))}
    names.update(given)
    out, pending = [], []
    for i, (b, r) in enumerate(blocked):
        if r[0] == 'AARG':
            if i in names:
                new = names[i]
                F.newtemps = getattr(F, 'newtemps', set()) | {new}   # (their own names: never thc1's table)
                defs.add(new)
                out.append([b, ('=', new, r[2], None)])
                r = (r[0], r[1], new, r[3]) + tuple(r[4:])
            pending.append((b, r))
            continue
        if r[0] in ('ACALL', 'ACALP') and pending:
            out.extend([pb, x] for pb, x in pending)
            pending = []
        out.append([b, r])
    out.extend([pb, x] for pb, x in pending)
    return out


def s1_text(F):
    recs = rewrite(F)
    recs, tmap, defs = number(F, recs)
    inv = {v: k for k, v in tmap.items()}
    blocked = []
    block, start, first = 0, False, True
    for r in recs:
        if r[0] in MARKERS:
            continue
        if r[0] in ('asm', 'ASM') and blocked and blocked[-1][1][0] in ('asm', 'ASM'):
            blocked.append([block, r])                 # a run of inline assembler is one block
            continue
        if (r[0] == 'LAB' or r[0] in CALLS or r[0] in ('asm', 'ASM') or start) and not first:
            block += 1                             # a block starts at a label, at a call or inline assembler, and
        first, start = False, r[0] in CALLS or r[0] in BRANCHES or r[0] in ('asm', 'ASM')   # after one or a branch
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
