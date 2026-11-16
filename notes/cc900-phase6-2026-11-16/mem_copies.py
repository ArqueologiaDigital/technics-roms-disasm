#!/usr/bin/env python3
"""When does the firmware copy memory to memory directly, and when through a register?  The census for the candidate
firmware rule KN_MEM_TO_MEM.

QUESTION ANSWERED: V4.23 copies a value from one memory operand to another by loading it into a register and storing
the register (`ld WA,(src)` / `ld (dst),WA`).  The firmware often uses the TLCS-900's memory-to-memory moves instead.
The hardware has two of them, byte and word only: `ld (#16),(mem)` (the destination a 16-bit absolute address, any
source) and `ld (mem),(#16)` (any destination, the source a 16-bit absolute address).  The hand source spells them
`ld` / `ldw (m),(m)` and, when both sides are absolute 16-bit, `ldmm8` / `ldmm16 DST, SRC`.  For every copy in a tree
this tool records:
    form    mem-to-mem, or reg (an `ld R,(src)` immediately followed by `ld (dst),R`)
    size    8 / 16 / 32 bits
    src     abs8 / abs16 / abs24 (an absolute address of that width), stack (xsp+d), disp (xrr+d), index (xrr+rr),
            ind (xrr), postinc / predec, or other
    dst     the same kinds
    after   for reg copies: "reused" when the register is read again before it is written, a branch or a label
            (so the register copy cannot simply become a move), else "dead"
and prints one table row per (form, size, src, dst, after) with its count.  A copy is eligible for a move when its
size is 8 or 16 and one side is abs16; the reg copies that are eligible and dead are where the firmware's compiler and
V4.23 would differ if the rule were "always move".  The source is read as written, so hand assembly is counted too.

usage: python3 notes/cc900-phase6-2026-11-16/mem_copies.py [TREE] [--list FORM:SIZE:SRC:DST:AFTER] [--by-file]
    TREE defaults to v10/maincpu.  --list prints file:line of every copy in that row.  --by-file prints, per hand
    source, the moves and the dead register copies that have a 16-bit absolute side, beside the -O marker: the
    32-bit constants of 8..0xffff loaded with lda (what V4.23 writes with -O) and with ld (without -O).
"""
import collections, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import loop_shapes as L                                      # noqa: E402  (items(): instructions with their labels)

R8 = {'a', 'w', 'b', 'c', 'd', 'e', 'h', 'l', 'qa', 'qw', 'qb', 'qc', 'qd', 'qe', 'qh', 'ql'}
R16 = {'wa', 'bc', 'de', 'hl', 'ix', 'iy', 'iz', 'qwa', 'qbc', 'qde', 'qhl'}
R32 = {'xwa', 'xbc', 'xde', 'xhl', 'xix', 'xiy', 'xiz'}
FAMILY = {r: r[-1] if r in R8 else None for r in R8}


def fam(r):
    """the 32-bit register a register name lies in (a -> xwa, bc -> xbc, ix -> xix)"""
    r = r.lower()
    if r in R32:
        return r
    if r in R16:
        return 'x' + r.lstrip('q')
    return {'a': 'xwa', 'w': 'xwa', 'b': 'xbc', 'c': 'xbc', 'd': 'xde', 'e': 'xde', 'h': 'xhl', 'l': 'xhl'}.get(
        r.lstrip('q'))


def size_of(r):
    r = r.lower()
    return 8 if r in R8 else 16 if r in R16 else 32 if r in R32 else None


def kind(op):
    """the addressing kind of a memory operand's text (without the outer parentheses)"""
    o = op.strip().lower()
    m = re.match(r'^[\w.$+\- ]+?:(8|16|24)$', o)
    if m:
        return 'abs' + m.group(1)
    if re.match(r'^-x\w+(:\d)?$', o):
        return 'predec'
    if re.match(r'^x\w+\+(:\d)?$', o):
        return 'postinc'
    if re.match(r'^xsp\s*([+-].*)?$', o):
        return 'stack'
    if re.match(r'^x\w+\s*\+\s*(wa|bc|de|hl|ix|iy|iz|a|w|b|c|d|e|h|l)$', o):
        return 'index'
    if re.match(r'^x\w+\s*[+-]\s*[\w.]+(:\d+)?$', o):
        return 'disp'
    if re.match(r'^x\w+$', o):
        return 'ind'
    if re.match(r'^[\w.$+\- ]+$', o):
        return 'abs?'                                     # an absolute operand without a width suffix
    return 'other'


MEM2 = re.compile(r'^(ld|ldw)\s+\((.+?)\)\s*,\s*\((.+)\)$')
LDMM = re.compile(r'^ldmm(8|16|32)\s+([^,]+),\s*(.+)$')
LOAD = re.compile(r'^ld\s+(q?[a-z]{1,3})\s*,\s*\((.+)\)$')
STORE = re.compile(r'^ld\s+\((.+)\)\s*,\s*(q?[a-z]{1,3})$')


def reads(ins, f):
    """does instruction text ins read 32-bit register family f (beyond being the destination of a plain ld)?"""
    parts = ins.split(None, 1)
    if len(parts) < 2:
        return parts[0] in ('ret',) and f in ('xhl', 'xwa')    # a return passes HL / XHL out
    ops = [o.strip() for o in re.split(r',(?![^()]*\))', parts[1])]
    mn = parts[0]
    for k, o in enumerate(ops):
        regs = re.findall(r'\b(q?x?(?:wa|bc|de|hl|ix|iy|iz)|q?[awbcdehl])\b', o.lower())
        for r in regs:
            if fam(r) != f:
                continue
            if k == 0 and mn in ('ld', 'lda', 'ldw') and not o.startswith('('):
                continue                                     # the plain destination: written, not read
            return True
    return False


def writes(ins, f):
    parts = ins.split(None, 1)
    if len(parts) < 2:
        return False
    first = re.split(r',(?![^()]*\))', parts[1])[0].strip().lower()
    return not first.startswith('(') and fam(first) == f


def census(tree):
    rows = collections.Counter(); where = collections.defaultdict(list)
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != 'generated')
        for f in sorted(fn):
            if not f.endswith('.s'):
                continue
            p = os.path.join(dp, f)
            it = L.items(p)
            for k, (n, labs, ins) in enumerate(it):
                rel = '%s:%d' % (os.path.relpath(p, tree), n)
                m = MEM2.match(ins)
                if m:
                    key = ('mem-to-mem', 16 if m.group(1) == 'ldw' else 8, kind(m.group(3)), kind(m.group(2)), '-')
                    rows[key] += 1; where[key].append(rel); continue
                m = LDMM.match(ins)
                if m:
                    key = ('mem-to-mem', int(m.group(1)), 'abs16', 'abs16', '-')
                    rows[key] += 1; where[key].append(rel); continue
                m = LOAD.match(ins)
                if not m or size_of(m.group(1)) is None or k + 1 >= len(it) or it[k + 1][1]:
                    continue
                s = STORE.match(it[k + 1][2])
                if not s or s.group(2).lower() != m.group(1).lower():
                    continue
                f_ = fam(m.group(1)); after = 'dead'
                for _, labs2, ins2 in it[k + 2:k + 40]:
                    if labs2:
                        after = 'dead?'; break               # a label: control can arrive from elsewhere
                    if reads(ins2, f_):
                        after = 'reused'; break
                    if writes(ins2, f_):
                        break
                    if ins2.split()[0] in ('jr', 'jrl', 'jp', 'djnz', 'call', 'calr', 'reti', 'retd', 'ret'):
                        after = 'dead?' if ins2.split()[0] not in ('ret',) else after
                        if ins2.split()[0] == 'ret' and f_ in ('xhl',):
                            after = 'reused'
                        break
                key = ('reg', size_of(m.group(1)), kind(m.group(2)), kind(s.group(1)), after)
                rows[key] += 1; where[key].append(rel)
    return rows, where


LDA_K = re.compile(r'^lda x(wa|bc|de|hl|ix|iy|iz)\s*,\s*\((0x[0-9a-f]+|\d+):(8|16)\)$')
LD_K = re.compile(r'^ld x(wa|bc|de|hl|ix|iy|iz)\s*,\s*(0x[0-9a-f]+|\d+)$')


def by_file(tree, where):
    """per file: moves and dead register copies with a 16-bit absolute side (8 / 16 bits), and the -O marker of
    the 32-bit constants 8..0xffff: lda (V4.23 at -O) against ld (V4.23 without -O)"""
    per = collections.defaultdict(lambda: [0, 0, 0, 0])
    a16 = lambda k: k in ('abs16', 'abs?')
    for (f, s, src, dst, aft), ws in where.items():
        if s not in (8, 16):
            continue
        for w in ws:
            fn = w.rsplit(':', 1)[0]
            if f == 'mem-to-mem' and (a16(src) or a16(dst)):
                per[fn][0] += 1
            if f == 'reg' and aft == 'dead' and a16(src) and a16(dst):
                per[fn][1] += 1
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d != 'generated')
        for f in sorted(fn):
            if f.endswith('.s'):
                p = os.path.join(dp, f)
                for _, _, ins in L.items(p):
                    for rx, col in ((LDA_K, 2), (LD_K, 3)):
                        m = rx.match(ins)
                        if m and 8 <= int(m.group(2), 0) <= 0xffff:
                            per[os.path.relpath(p, tree)][col] += 1
    return per


def main():
    a = sys.argv[1:]
    tree = next((x for i, x in enumerate(a) if not x.startswith('--') and (i == 0 or a[i - 1] != '--list')),
                'v10/maincpu')
    rows, where = census(tree)
    if '--by-file' in a:
        per = by_file(tree, where)
        head = ['file', 'moves', 'reg copies', 'lda 8..0xffff', 'ld 8..0xffff']
        out = [[k] + [str(x) for x in v] for k, v in sorted(per.items(), key=lambda kv: -(kv[1][0] + kv[1][1]))
               if v[0] + v[1] >= 3]
        w = [max(len(r[i]) for r in out + [head]) for i in range(len(head))]
        fmt = lambda r: '| ' + ' | '.join(r[i].ljust(w[i]) for i in range(len(r))) + ' |'
        print(fmt(head)); print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
        for r in out:
            print(fmt(r))
        return
    if '--list' in a:
        f, s, src, dst, aft = a[a.index('--list') + 1].split(':')
        for w in where[(f, int(s), src, dst, aft)]:
            print(w)
        return
    head = ['form', 'size', 'src', 'dst', 'after', 'copies', 'move possible']
    out = []
    for (f, s, src, dst, aft), n in sorted(rows.items(), key=lambda kv: (kv[0][0], -kv[1])):
        ok = s in (8, 16) and ('abs16' in (src, dst))
        out.append([f, str(s), src, dst, aft, str(n), 'yes' if ok else 'no'])
    w = [max(len(r[i]) for r in out + [head]) for i in range(len(head))]
    fmt = lambda r: '| ' + ' | '.join(r[i].ljust(w[i]) for i in range(len(r))) + ' |'
    print(fmt(head)); print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in out:
        print(fmt(r))


if __name__ == '__main__':
    main()
