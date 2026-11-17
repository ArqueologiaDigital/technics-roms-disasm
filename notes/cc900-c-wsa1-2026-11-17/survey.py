#!/usr/bin/env python3
"""Which routines of the SX-WSA1R program images look compiled from C, and which are small leaf candidates?

QUESTION ANSWERED: per image (prom_a, prom_b, prom_c), the routines and their shape.  A routine starts at a
label whose first instruction follows a flow end (ret / retd / reti / an unconditional jp / a data directive;
not jr / jrl, which the compiled code uses inside a function) or is `link`; it ends before the next routine start.  Its size is the distance between the two start
labels in the linked ELF (so it includes any padding before the next routine).

Columns (--tsv): addr, bytes, insns, name, file, frame (link = `link xiz,N` .. `unlk xiz`; plain = neither),
locals (the link's N, as a positive byte count), kind (leaf = no call / calr and no jump out; abs = absolute
`call`s only; rel = some `calr`), call, calr, outj, hand (ei / di / reti / ldc / swi / halt / ldf / incf / decf /
`.byte` lines: what a C compiler does not write), args (the largest (xiz+N) read).

usage (repository root, after `make wsa1`):
    python3 -B notes/cc900-c-wsa1-2026-11-17/survey.py [--tsv OUT] [--md OUT] [--top N]
"""
import collections, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wsa_common as W

NAME = r'([A-Za-z_][\w]*)'
TERM = re.compile(r'(?i)^(ret|retd|reti)\b|^jp\s+(t\s*,\s*)?[A-Za-z_(][\w()+]*$')
DATA = re.compile(r'(?i)^\.(byte|short|word|long|ascii|asciz|string|fill|zero|space|incbin|org|p2align|align)\b')
CALL = re.compile(r'(?i)^(call|calr)\s+(?:t\s*,\s*)?' + NAME + r'\s*$')
JUMP = re.compile(r'(?i)^(jp|jr|jrl|djnz\w*)\s+(?:\w+\s*,\s*)*' + NAME + r'\s*$')
HAND = re.compile(r'(?i)^(ei|di|reti|ldc\w*|swi|halt|ldf|incf|decf|\.byte)\b')
LINK = re.compile(r'(?i)^link\s+xiz\s*,\s*(\S+)$')
ARG = re.compile(r'(?i)\(xiz\+(\d+|0x[0-9a-f]+)\)')
SKIP = ('.equ', '.set', '.include', '.globl', '.global', '.section', '.text', '.if', '.else', '.endif', '.ifndef',
        '.ifdef', '.macro', '.endm')


def survey(tree):
    labels = W.own_labels(tree)
    out = []
    for path in W.source_files(tree):
        it = [x for x in W.items(path) if not x[2].lower().startswith(SKIP)]
        starts = []
        for k, (_, labs, ins) in enumerate(it):
            if not labs or DATA.match(ins) and not ins.startswith('.byte'):
                continue
            prev = it[k - 1][2] if k else 'ret'
            if LINK.match(ins) or TERM.match(prev) or DATA.match(prev):
                starts.append(k)
        for a, b in zip(starts, starts[1:] + [None]):
            body = it[a:b]
            for j, x in enumerate(body):                     # the code stops at the first data directive
                if DATA.match(x[2]) and not x[2].startswith('.byte'):
                    body = body[:j]; break
            name = next((l for l in body[0][1] if l in labels), None) if body else None
            if name is None:
                continue
            end = next((labels[l] for l in it[b][1] if l in labels), None) if b is not None else None
            ops = [x[2] for x in body]
            own = {l for x in body for l in x[1]}
            calls = [CALL.match(o) for o in ops]
            ncall = sum(1 for m in calls if m and m.group(1).lower() == 'call')
            ncalr = sum(1 for m in calls if m and m.group(1).lower() == 'calr')
            outj = sum(1 for o in ops if JUMP.match(o) and JUMP.match(o).groups()[-1] not in own) + \
                sum(1 for o in ops if o.lower().startswith(('jp', 'call')) and '(' in o)
            lk = LINK.match(ops[0])
            frame = 'link' if lk else 'plain'
            loc = (0x10000 - int(lk.group(1), 0)) & 0xffff if lk else 0
            args = max([int(m, 0) for o in ops for m in ARG.findall(o)] + [0])
            out.append(dict(addr=labels[name], bytes=end - labels[name] if end and end > labels[name] else 0,
                            insns=len(ops), name=name, file=os.path.relpath(path, os.path.join(W.REPO, tree)),
                            frame=frame, locals=loc, call=ncall, calr=ncalr, outj=outj,
                            kind='leaf' if not (ncall or ncalr or outj) else 'rel' if ncalr else 'abs',
                            hand=sum(1 for o in ops if HAND.match(o)), args=args, tree=tree))
    return sorted(out, key=lambda r: r['addr'])


def table(rows, head):
    w = [max(len(str(x)) for x in col) for col in zip(head, *rows)]
    line = lambda r: '| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |'
    return '\n'.join([line(head), '|' + '|'.join('-' * (n + 2) for n in w) + '|'] + [line(r) for r in rows])


KEYS = ['tree', 'addr', 'bytes', 'insns', 'name', 'file', 'frame', 'locals', 'kind', 'call', 'calr', 'outj', 'hand',
        'args']


def main():
    a = sys.argv[1:]
    top = int(a[a.index('--top') + 1]) if '--top' in a else 40
    rows, md = [], ['# SX-WSA1R routine survey (survey.py)', '']
    summ = []
    for tree in sorted(W.TREES):
        r = survey(tree)
        rows += r
        c = collections.Counter()
        for x in r:
            c['routines'] += 1; c['bytes'] += x['bytes']
            c[x['frame']] += 1; c[x['frame'] + ' B'] += x['bytes']
            c['hand'] += x['hand'] > 0; c['hand B'] += x['bytes'] if x['hand'] else 0
            leaf = x['kind'] == 'leaf' and not x['hand']
            c['leaf'] += leaf; c['leaf B'] += x['bytes'] if leaf else 0
        summ.append((tree, c['routines'], c['bytes'], c['link'], c['link B'], c['plain'], c['plain B'], c['hand'],
                     c['hand B'], c['leaf'], c['leaf B']))
    md += [table(summ, ('tree', 'routines', 'bytes', 'link', 'link B', 'plain', 'plain B', 'hand marks',
                        'hand B', 'leaf, no hand mark', 'leaf B')), '']
    cand = sorted([x for x in rows if x['kind'] == 'leaf' and not x['hand'] and x['frame'] == 'link' and x['bytes']],
                  key=lambda x: x['bytes'])
    md += ['## Smallest %d leaf routines with a link frame (of %d)' % (min(top, len(cand)), len(cand)), '',
           table([(x['tree'], x['name'], x['file'], x['bytes'], x['insns'], x['locals'], x['args'])
                  for x in cand[:top]], ('tree', 'routine', 'file', 'bytes', 'insns', 'locals', 'max arg offset')), '']
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as fh:
            fh.write('\t'.join(KEYS) + '\n')
            for x in rows:
                fh.write('\t'.join('%06x' % x[k] if k == 'addr' else str(x[k]) for k in KEYS) + '\n')
    text = '\n'.join(md) + '\n'
    if '--md' in a:
        open(a[a.index('--md') + 1], 'w').write(text)
    else:
        print(text)
    print('%d routines' % len(rows), file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
