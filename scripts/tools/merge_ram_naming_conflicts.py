#!/usr/bin/env python3
"""merge_ram_naming_conflicts.py -- resolve git conflict hunks where one side renamed labels / added headers and the
other side replaced numeric RAM operands with symbols.

QUESTION THIS ANSWERS / JOB IT DOES
  Merging wave2/ram-naming (numeric RAM operands -> .equ names, on the old v7/v9 label names) after wave2/v7-harmonize
  (v7 labels renamed to v10's, v10 headers propagated) conflicted in 22 .s files (306 hunks).  Neither side is right
  alone.  For each hunk this keeps OURS (HEAD) for every label line, comment line and identifier, and takes THEIRS'
  spelling only where THEIRS turned a number into a symbol: the code lines of both sides are paired in order by their
  shape (mnemonic, with every number and identifier blanked); in a paired line a token span where ours is numeric and
  theirs names something is taken from theirs.  A hunk whose code lines do not pair one to one is left unresolved and
  listed.  The byte gate is the proof: a wrong symbol cannot assemble to the same bytes.

USAGE
  python3 scripts/tools/merge_ram_naming_conflicts.py FILE...      # rewrites the files in place, prints a summary
"""
import difflib
import re
import sys

TOK = re.compile(r'\.?[A-Za-z_][\w$.]*|0x[0-9a-fA-F]+|\d+|\s+|.')
NUM = re.compile(r'^(0x[0-9a-fA-F]+|\d+)$')
IDENT = re.compile(r'^\.?[A-Za-z_][\w$.]*$')
HUNK = re.compile(r'<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n', re.S)


def is_code(line):
    s = line.strip()
    return bool(s) and not s.startswith(';') and line[:1] in ' \t' and not s.endswith(':')


def code_part(line):
    return line.split(';', 1)[0]


def shape(line):
    toks = TOK.findall(code_part(line).strip())
    out = []
    for t in toks:
        if t.isspace():
            continue
        out.append('N' if NUM.match(t) or IDENT.match(t) and out else t)
    # `NAME+2` (theirs) and `0x95aa` (ours) are the same operand: collapse N+N / N-N to N
    while True:
        for k in range(len(out) - 2):
            if out[k] == 'N' and out[k + 1] in '+-' and out[k + 2] == 'N':
                out[k:k + 3] = ['N']
                break
        else:
            return ' '.join(out)


def merge_line(ours, theirs):
    """ours' line with theirs' symbol wherever ours had a number there."""
    oc, ocomment = (ours.split(';', 1) + [None])[:2]
    to = TOK.findall(oc)
    tt = TOK.findall(code_part(theirs))
    sm = difflib.SequenceMatcher(a=to, b=tt, autojunk=False)
    out = []
    for op, a0, a1, b0, b1 in sm.get_opcodes():
        a, b = to[a0:a1], tt[b0:b1]
        if op == 'equal':
            out += a
        elif op == 'replace' and any(NUM.match(x) for x in a) and any(IDENT.match(x) for x in b) \
                and not any(IDENT.match(x) for x in a):
            out += b
        else:
            out += a
    line = ''.join(out)
    return line + (';' + ocomment if ocomment is not None else '')


def resolve(ours, theirs):
    o = ours.split('\n')[:-1]
    t = theirs.split('\n')[:-1]
    oc = [i for i, l in enumerate(o) if is_code(l)]
    tc = [i for i, l in enumerate(t) if is_code(l)]
    if len(oc) != len(tc) or any(shape(o[i]) != shape(t[j]) for i, j in zip(oc, tc)):
        return None
    for i, j in zip(oc, tc):
        o[i] = merge_line(o[i], t[j])
    return '\n'.join(o) + '\n'


def main():
    total = left = 0
    for path in sys.argv[1:]:
        text = open(path, 'rb').read().decode('latin-1')
        unresolved = []

        def f(m):
            nonlocal total
            total += 1
            r = resolve(m.group(1), m.group(2))
            if r is None:
                unresolved.append(text.count('\n', 0, m.start()) + 1)
                return m.group(0)
            return r
        new = HUNK.sub(f, text)
        open(path, 'wb').write(new.encode('latin-1'))
        left += len(unresolved)
        if unresolved:
            print('%s: %d unresolved hunk(s) at lines %s' % (path, len(unresolved), unresolved[:12]))
    print('hunks %d, resolved %d, left %d' % (total, total - left, left))


if __name__ == '__main__':
    main()
