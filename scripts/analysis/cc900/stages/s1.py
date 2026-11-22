#!/usr/bin/env python3
"""Stage S1 of the rebuilt back end (README.md): from thc1's operations (S0) to the instruction list V4.23's thc2 holds
before code selection, printed in the form of its `-zio` dump so that the two can be compared line by line.

Written from our description of thc2 (feedback plan section 13; this directory's README).  What it does, without
optimisation (the `-Xr` and no-option files; the `-O` passes are later work):
  - locals I<n>, parameters P<n> and the temporaries that survive are renumbered from 0 (temporaries in the order
    thc1 declared them);
  - the result temporary thc1 gives every assignment and compound assignment is dropped unless something reads it;
  - a compare whose only use is the next FALSE / TRUE becomes one branch (FALSE of `<` is BGE, ...);
  - `x * 2` becomes `x + x`; a pointer plus an integer becomes ADD;
  - `T = x; x += 1` with T unread becomes `x ++ 1` (likewise `--`);
  - a temporary written once and copied once into a local, a parameter or A is replaced by that destination;
  - every operation carries a block number: a new block starts at each label and at each call, and after a call.

    python3 -B scripts/analysis/cc900/stages/s1.py FILE.inter          prints our S1 for every function
"""
import re
import sys

import s0

BASIC = ['VOID', 'SCHAR', 'UCHAR', 'SSHORT', 'USHORT', 'SINT', 'UINT', 'SLONG', 'ULONG', 'FLOAT', 'DOUBLE', 'LDOUBLE']
CMP = {'<': ('BLT', 'BGE'), '<=': ('BLE', 'BGT'), '>': ('BGT', 'BLE'), '>=': ('BGE', 'BLT'), '==': ('BEQ', 'BNE'),
       '!=': ('BNE', 'BEQ')}
COMPOUND = {'=', '+=', '-=', '*=', '/=', '%=', '<<=', '>>=', '&=', '|=', '^='}
BINARY = {'+', '-', '*', '/', '%', '<<', '>>', '&', '|', '^'}
CALLS = {'CCALL', 'CCALP', 'ACALL', 'ACALP'}
ARGS = {'CARG', 'AARG'}
SIZE = {1: 0, 2: 1, 3: 1, 4: 2, 5: 2, 6: 2, 7: 2, 8: 4, 9: 4, 10: 4, 11: 8, 12: 10}


def type_name(t):
    t = int(t) if str(t).lstrip('-').isdigit() else 0
    if 1 <= t <= 12:
        return BASIC[t - 1]
    if 17 <= t <= 28:
        return '%s F*' % BASIC[t - 17]
    if 33 <= t <= 44:
        return '%s N*' % BASIC[t - 33]
    return '%d' % t


def is_ptr(t):
    t = int(t) if str(t).lstrip('-').isdigit() else 0
    return 17 <= t <= 28 or 33 <= t <= 44


class Fn:
    """one function's S1 records: a list of [block, text] after rewriting; operands kept as thc1 spells them until
    printing"""

    def __init__(self, f, symtypes):
        self.f = f
        self.symtypes = symtypes
        self.ltype = {k: v[2] for k, v in f.locals.items()}
        self.ptype = {'P%d' % (i + 1): p[2] for i, p in enumerate(f.params)}
        self.ttype = dict(f.temps)

    def typ(self, x):
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


def uses(ops, name):
    """how many times operand `name` is read in ops (any field after the first of a line, dereferences included)"""
    n = 0
    for l in ops:
        for x in l.fields[1:]:
            if x.lstrip('*&') == name:
                n += 1
    return n


def rewrite(F):
    """the S1 list of (op, result, a, b, extra) tuples, operands in thc1's spelling"""
    ops = [l for l in F.f.ops if l.kind == 'op']
    out = []
    i = 0
    reads = {}
    for l in ops:                                   # reads of each temporary (fields that are inputs)
        op = l.op
        ins = l.fields[1:3] if op in COMPOUND or op in BINARY or op in CMP or op in CALLS or op == 'ADDR' else l.fields[1:]
        for x in ins:
            x = x.lstrip('*&')
            if x.startswith('T'):
                reads[x] = reads.get(x, 0) + 1
    while i < len(ops):
        l = ops[i]
        op, fl = l.op, l.fields
        nxt = ops[i + 1] if i + 1 < len(ops) else None
        if op in CMP and nxt is not None and nxt.op in ('FALSE', 'TRUE') and nxt.fields[1] == fl[3] and \
                reads.get(fl[3], 0) == 1:
            br = CMP[op][1] if nxt.op == 'FALSE' else CMP[op][0]
            out.append((br, nxt.fields[3], fl[1], fl[2], None))
            i += 2
            continue
        if op == '=' and len(fl) > 3 and fl[1] == fl[3] and fl[1].startswith('T') and nxt is not None and \
                nxt.op in ('+=', '-=') and nxt.fields[1] == fl[2] and nxt.fields[2].startswith('#') and \
                reads.get(fl[1], 0) == 1:
            out.append(('++' if nxt.op == '+=' else '--', fl[2], '#' + nxt.fields[2][1:], None, None))
            i += 2
            continue
        if op in COMPOUND:
            out.append((op, fl[1], fl[2], None, fl[3] if len(fl) > 3 else None))
        elif op in BINARY:
            if op == '*' and fl[2] == '#2':
                out.append(('+', fl[3], fl[1], fl[1], None))
            elif op == '+' and (is_ptr(F.typ(fl[1])) or is_ptr(F.typ(fl[2]))):
                out.append(('ADD', fl[3], fl[1], fl[2], None))
            else:
                out.append((op, fl[3], fl[1], fl[2], None))
        elif op == 'ADDR':
            out.append(('ADDR', fl[3], fl[1], None, None))
        elif op in CALLS:                            # CCALL,@f,#argbytes,T: the result first, as the others
            res_ = fl[3] if len(fl) > 3 and F.typ(fl[3]) not in ('1', None) else None
            out.append((op, res_, fl[1], fl[2], None))
        elif op in ARGS:
            out.append((op, None, fl[1], None, None))
        else:
            out.append((op,) + tuple(fl[1:]) + (None,) * (4 - len(fl[1:])))
        i += 1
    # a temporary written once by an operation and then copied by `=` into its destination: write the destination
    res = []
    for k, r in enumerate(out):
        if r[0] == '=' and r[2] and r[2].startswith('T') and res and res[-1][1] == r[2] and reads.get(r[2], 0) == 1:
            prev = res.pop()
            res.append((prev[0], r[1]) + prev[2:])
            continue
        res.append(r)
    return res


def number(F, recs):
    """renumber I / P / T from 0 (T in declaration order, surviving ones only)"""
    live_t = set()
    for r in recs:
        for x in r[1:4]:
            if x and x.lstrip('*&').startswith('T'):
                live_t.add(x.lstrip('*&'))
    tmap = {}
    for t in F.f.temps:
        if t in live_t:
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
    return [(r[0],) + tuple(ren(x) for x in r[1:4]) + (r[4],) for r in recs], tmap


def show(F, x, tmap_inv, defs):
    """an operand as the dump prints it"""
    if x is None:
        return ''
    pre = x[:len(x) - len(x.lstrip('*&'))]
    b = x[len(pre):]
    if b.startswith('#'):
        return '# %s' % b[1:]
    if b == 'A':
        return 'A'
    if b.startswith('@'):
        return '%s@%s(%s)' % (pre, b[1:], F.symtypes.get(b, '?'))
    orig = tmap_inv.get(b, b)
    if b.startswith('I') or b.startswith('P'):
        orig = '%s%d' % (b[0], int(b[1:]) + 1)
    t = type_name(F.typ(orig))
    return '%s%s(%s)%s' % (pre, b, t, '(Def)' if b in defs else '')


def fmt(F, r, tmap_inv, defs):
    op, res, a, b, _ = r
    S = lambda x: show(F, x, tmap_inv, defs)
    if op in ('BLT', 'BGE', 'BLE', 'BGT', 'BEQ', 'BNE'):
        return '%s %s %s,%s' % (res, op, S(a), S(b))
    if op in ('+', '-', '*', '/', '%', '<<', '>>', '&', '|', '^', 'ADD'):
        return '%s %s %s,%s' % (S(res), op, S(a), S(b))
    if op in COMPOUND or op in ('++', '--'):
        return '%s %s %s' % (S(res), op, S(a))
    if op == 'ADDR':
        return '%s ADDR %s' % (S(res), S(a))
    if op == 'LAB':
        return 'LAB,%s' % res
    if op == 'JMP':
        return 'JMP,%s' % res
    if op in ('BEGIN', 'END'):
        return op
    if op in CALLS:
        return '%s %s %s #%s' % (S(res), op, S(a), b.lstrip('#'))
    if op in ARGS:
        t = F.typ(tmap_inv.get(a, a) if not a[:1] in 'IP' else '%s%d' % (a[0], int(a[1:]) + 1))
        n = SIZE.get(int(t), 4) if t and t.isdigit() and 1 <= int(t) <= 12 else 4
        return '%s %s #%d' % (op, S(a), n)
    return '%s %s' % (op, ' '.join(S(x) for x in (res, a, b) if x))


def s1_text(F):
    recs = rewrite(F)
    recs, tmap = number(F, recs)
    inv = {v: k for k, v in tmap.items()}
    defs = set(tmap.values())                      # (Def): every surviving temporary, as a first approximation
    out = ['FUNC_START']
    block, start, first = 0, False, True
    for r in recs:
        if r[0] in ('LINE', '{', '}', 'FILE'):
            continue
        if (r[0] == 'LAB' or r[0] in CALLS or start) and not first:
            block += 1                             # a block starts at a label, at a call and after a call
        first, start = False, r[0] in CALLS
        out.append('%3u:   |%s' % (block, fmt(F, r, inv, defs)))
        if r[0] == 'END':
            break
    out.append('   :   |FUNC_END')
    out[0] = '   :   |FUNC_START'
    return out


def symtypes(u):
    t = {}
    for l in u.header + [d for f in u.functions for d in f.decls]:
        if l.kind == 'decl' and l.fields[0].startswith('@') and len(l.fields) > 2:
            t[l.fields[0]] = l.fields[2]
    return t


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    for p in sys.argv[1:]:
        u = s0.load(p)
        st = symtypes(u)
        for f in u.functions:
            print('\n'.join(s1_text(Fn(f, st))))
