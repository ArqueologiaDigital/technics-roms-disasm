#!/usr/bin/env python3
"""Stage S0 of the rebuilt back end (README.md): thc1's intermediate file, split into its file-level declarations and
one unit per function, with each function's declarations (parameters, locals, temporaries) and operations.

This is our structure, not thc2's: it is what later stages (S1, the -zio form) start from.  Built from the file format
as observed (thc1ir.py) and from our description of thc2's reader (feedback plan section 13, i2/README.md):
  - a function runs from `BEGIN,<name>` to the `}` that matches the `{` thc1 writes just before the BEGIN (inner
    blocks have their own `{` / `}` pairs; thc1 writes an `END,<name>` before the final `LINE` and another after);
  - its declarations are the TAB lines inside it: the function's own type and symbol, `,"name",...` parameter lines,
    `I<n>` locals, `T<n>,<type>` temporaries (declared just before the operation that first writes them).

    python3 -B scripts/analysis/cc900/stages/s0.py --stats FILE.inter ...     (counts only)
"""
import collections
import re
import sys

import thc1ir

TEMP = re.compile(r'^T(\d+)$')
LOCAL = re.compile(r'^I(\d+)$')


class Function:
    def __init__(self, name):
        self.name = name
        self.decls = []          # Line objects (TAB lines) in order
        self.ops = []            # Line objects (operation lines) in order, markers included
        self.params = []         # the `,"name",type,...` lines' fields
        self.locals = {}         # 'I<n>' -> fields
        self.temps = {}          # 'T<n>' -> type field

    def __repr__(self):
        return 'Function(%s: %d ops, %d params, %d locals, %d temps)' % (
            self.name, len(self.ops), len(self.params), len(self.locals), len(self.temps))


class Unit:
    def __init__(self):
        self.header = []         # lines before the first function (file-level types and symbols)
        self.functions = []
        self.between = []        # lines outside any function after the first


def split(lines):
    u = Unit()
    cur, depth = None, 0
    for l in lines:
        if cur is None:
            if l.kind == 'op' and l.op == 'BEGIN':
                cur, depth = Function(l.fields[1]), 0
                u.functions.append(cur)
                cur.ops.append(l)
            else:
                (u.header if not u.functions else u.between).append(l)
            continue
        if l.kind == 'decl':
            cur.decls.append(l)
            f0 = l.fields[0]
            if f0 == '' and len(l.fields) > 1:
                cur.params.append(l.fields)
            elif LOCAL.match(f0):
                cur.locals[f0] = l.fields
            elif TEMP.match(f0):
                cur.temps[f0] = l.fields[1] if len(l.fields) > 1 else ''
            continue
        cur.ops.append(l)
        if l.op == '{':
            depth += 1
        elif l.op == '}':
            depth -= 1
            if depth < 0:                    # the `}` matching the `{` written before BEGIN
                cur = None
    return u


def load(path):
    return split(thc1ir.parse(open(path, 'rb').read().decode('latin-1')))


def stats(paths):
    n = collections.Counter()
    for p in paths:
        u = load(p)
        n['files'] += 1
        n['functions'] += len(u.functions)
        for f in u.functions:
            n['ops'] += len(f.ops)
            n['params'] += len(f.params)
            n['locals'] += len(f.locals)
            n['temps'] += len(f.temps)
    print(' '.join('%s %d' % kv for kv in sorted(n.items())))


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--stats':
        stats(sys.argv[2:])
    else:
        sys.exit(__doc__)
