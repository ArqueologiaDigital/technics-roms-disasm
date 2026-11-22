#!/usr/bin/env python3
"""thc2's intermediate-code dumps (-zio, -zim; this directory's README) read into records and written back.

QUESTION ANSWERED: can a dump line be taken apart into (block, operation, result, operands, extra) and put back
exactly?  That lets a stage be developed from the previous stage's dump of V4.23 itself (S2 from -zio, ...), so a
stage's errors never hide behind an earlier stage's.  `--roundtrip DUMP...` checks every line and prints counts only.

The grammar, as observed: `<block>:   |<body>`, the body being one of
    BEGIN | END | LAB,L<n> | JMP,L<n> | asm,<text> | ASM,<text>
    L<n> <branch> <a>,<b>
    <x> Switch L<n> ...
    [<res>] <OP> <a>[,<b>][ <extra>]          (<extra>: a helper name, `#<n>` byte counts, `#<o>,<i>`)
    AARG <a> #<o>,<i> | CARG <a> #<n> | <a> DUMMY | <a> PIN
An operand is `[*&]` then a constant (`#` + size letter or blank + U? + value), a name with its `(type)`, `(Def)`
and `{..}` groups, or a memory operand `@(base[+index][+disp])` / `@name(type)`.
"""
import re
import sys

BRANCH = {'BLT', 'BGE', 'BLE', 'BGT', 'BEQ', 'BNE', 'JRBC', 'JRBS', 'DJNZ'}


def operand_end(s, i):
    """the end index of the operand starting at s[i]"""
    j = i
    while j < len(s) and s[j] in '*&':
        j += 1
    if j < len(s) and s[j] == '#':
        m = re.compile(r'#[ CL]?U?-?[0-9.eE+-]+').match(s, j)
        return m.end() if m else j + 1
    if s.startswith('@(', j):
        depth = 0
        while j < len(s):
            if s[j] == '(':
                depth += 1
            elif s[j] == ')':
                depth -= 1
                if depth == 0:
                    return j + 1
            j += 1
        return j
    m = re.compile(r'[@A-Za-z_.$][\w.$]*').match(s, j)
    if not m:
        return j
    j = m.end()
    while j < len(s) and s[j] in '({[':
        close = {'(': ')', '{': '}', '[': ']'}[s[j]]
        k = s.find(close, j)
        if k < 0:
            break
        j = k + 1
    return j


class Rec:
    __slots__ = ('block', 'op', 'res', 'args', 'extra', 'raw')

    def __init__(self, block, op, res, args, extra, raw):
        self.block, self.op, self.res, self.args, self.extra, self.raw = block, op, res, args, extra, raw

    def __repr__(self):
        return 'Rec(%s %r %r %r %r)' % (self.block, self.res, self.op, self.args, self.extra)


def parse_body(b):
    """(op, res, args, extra) of a dump line's body"""
    for k in ('BEGIN', 'END'):
        if b == k:
            return k, None, [], None
    m = re.match(r'^(LAB|JMP|asm|ASM),(.*)$', b)
    if m:
        return m.group(1), None, [m.group(2)], None
    m = re.match(r'^(L\d+) (\S+) (.*)$', b)
    if m and m.group(2) in BRANCH:
        rest = m.group(3)
        e = operand_end(rest, 0)
        return m.group(2), m.group(1), [rest[:e], rest[e + 1:]], None
    m = re.match(r'^(AARG &|CARG &|AARG|CARG|CFARG|AFARG) (.*)$', b)
    if m:
        rest = m.group(2)
        e = operand_end(rest, 0)
        return m.group(1), None, [rest[:e]], rest[e:].strip()
    # [res] OP args
    res = None
    i = 0
    if not b.startswith(' '):
        e = operand_end(b, 0)
        res, i = b[:e], e
    if b[i:i + 1] != ' ':
        return '?', None, [b], None
    i += 1
    m = re.compile(r'(\S+)').match(b, i)
    op = m.group(1)
    i = m.end()
    rest = b[i:]
    if op == 'Switch':
        return op, res, [rest.strip()], None
    if op in ('DUMMY', 'PIN') or rest == ' ':
        return op, res, [], rest          # (NEG / NOT on their result alone end with a blank)
    rest = rest[1:] if rest.startswith(' ') else rest
    args = []
    j = 0
    if rest:
        e = operand_end(rest, 0)
        args.append(rest[:e])
        j = e
        if rest[j:j + 1] == ',':
            e2 = operand_end(rest, j + 1)
            args.append(rest[j + 1:e2])
            j = e2
    extra = rest[j:] if j < len(rest) else None
    return op, res, args, extra


def parse_line(line):
    m = re.match(r'^(...):   \|(.*)$', line)
    if not m:
        return None
    blk = m.group(1).strip()
    op, res, args, extra = parse_body(m.group(2))
    return Rec(int(blk) if blk.isdigit() else None, op, res, args, extra, line)


def body(r):
    """the record written back as a dump body"""
    if r.op in ('BEGIN', 'END'):
        return r.op
    if r.op in ('LAB', 'JMP', 'asm', 'ASM'):
        return '%s,%s' % (r.op, r.args[0])
    if r.op in BRANCH and r.res and r.res.startswith('L'):
        return '%s %s %s,%s' % (r.res, r.op, r.args[0], r.args[1])
    if r.op in ('AARG', 'CARG', 'CFARG', 'AFARG', 'AARG &', 'CARG &'):
        return '%s %s %s' % (r.op, r.args[0], r.extra)
    if r.op == 'Switch':
        return '%s Switch %s' % (r.res, r.args[0])
    if r.op in ('DUMMY', 'PIN') or (not r.args and r.extra == ' '):
        return '%s %s%s' % (r.res, r.op, r.extra or '')
    s = '%s %s' % (r.res or '', r.op)
    if r.args:
        s += ' ' + ','.join(r.args)
    if r.extra:
        s += r.extra
    return s


def line(r):
    return '%3s:   |%s' % ('' if r.block is None else r.block, body(r))


def roundtrip(paths):
    import collections
    sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
    import s1_check
    n = collections.Counter()
    for p in paths:
        for f in s1_check.zio_functions(p):
            for l in f[1:-1]:
                r = parse_line(l)
                n['lines'] += 1
                if r is None:
                    n['unparsed'] += 1
                elif line(r) == l:
                    n['exact'] += 1
                else:
                    n['differs'] += 1
                    if n['differs'] <= 6:
                        sys.stderr.write('differs: %r\n   %r\n' % (l, line(r)))
    print(' '.join('%s %d' % kv for kv in sorted(n.items())))


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--roundtrip':
        roundtrip(sys.argv[2:])
    else:
        sys.exit(__doc__)
