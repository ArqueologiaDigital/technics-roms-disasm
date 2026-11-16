#!/usr/bin/env python3
"""Which routines of the sub-CPU payload look compiled from C, and which are leaf candidates for cc900 V4.23?

QUESTION ANSWERED: the sub-CPU payload (v142/subcpu) holds Toshiba library code (results/pairs.tsv: the double
math library), so at least part of it was compiled with cc900.  This splits every hand source into routines and
says, per routine, how large it is, whether it calls anything (absolute `call`, or `calr`, which asm900 writes only
for a target in the same module), and which marks of compiled C or of hand assembly it carries.

A routine starts at a label that is a call / calr target, a `.long` entry or an `lda` operand, when the
instruction before it ends the flow (ret, retd, reti, an unconditional jp / jr / jrl) or it starts the file.  It
ends at the next such start; its size is the distance between the two labels in the symbols reference.

Marks (counted per routine):
  cmark   extz / exts / muls / mul / div / a stack frame `lda xsp,(xsp-N)` / retd: the code cc900 writes for
          integer promotion, array indexing and locals
  hand    ei / di / reti / ldc / swi / halt / ldf / incf / decf / `.byte`: what a C compiler does not emit
  erp     bank-register forms (`*_erp*`): V4.23 does allocate the index registers' byte parts (IXL .. QIZH), so these
          are not a hand mark by themselves
  nop     `nop`: the tone-generator writers' settling gaps
  mm      memory-to-memory moves (`ld (m),(m)`, ldmm8 / ldmm16): V4.23 never writes them (cc900 phase 6 README)
  O-mark  32-bit constants of 8..0xffff: loaded with `lda xR,(N:16)` (V4.23 does that only with -O) or with
          `ld xR,N` (without -O); counted for the file, as the phase-6 census did for the main CPU
Class: C when it has a cmark and no hand mark, hand when it has a hand mark, ? otherwise.
Kind: leaf (no call / calr / jump outside itself), abs (calls only with absolute `call`), rel (some `calr`).
calr groups: routines joined by calr edges belong to one module; the group number lets a C file hold a whole module.

usage (from the repository root):
    python3 -B notes/cc900-c-subcpu-2026-11-16/survey.py [TREE] [--tsv OUT] [--md OUT] [--top N]
        TREE defaults to v142/subcpu (its symbols reference: symbols/subcpu_symbols_reference.txt).
        --tsv writes one row per routine; --md the per-file summary and the top-N candidate table.
"""
import collections, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SYMREF = {'v142/subcpu': 'symbols/subcpu_symbols_reference.txt',
          'v141/subcpu': 'symbols/subcpu_v141_symbols_reference.txt',
          'v140/subcpu': 'symbols/subcpu_v140_symbols_reference.txt'}
LABEL = re.compile(r'^([A-Za-z_.$][\w.$]*):\s*(.*)$')
NAME = r'([A-Za-z_][\w]*)'
TERM = re.compile(r'(?i)^(ret|retd|reti|jp\s+(t\s*,\s*)?[A-Za-z_(]|jrl?\s+(t\s*,\s*)?[A-Za-z_])')
CALL = re.compile(r'(?i)^(call|calr)\s+(?:t\s*,\s*)?' + NAME + r'\s*$')
JUMP = re.compile(r'(?i)^(jp|jr|jrl|djnz\w*)\s+(?:\w+\s*,\s*)*' + NAME + r'\s*$')
LDA = re.compile(r'(?i)^lda\s+\w+\s*,\s*\(?\s*' + NAME + r'(?::24|:16)?\s*\)?\s*$')
LONG = re.compile(r'^\.long\s+(.*)$')
CMARK = re.compile(r'(?i)^(extz|exts|muls|mul|div|divs|retd)\b|^lda\s+xsp\s*,\s*\(xsp\s*-')
HAND = re.compile(r'(?i)^(ei|di|reti|ldc\w*|swi|halt|ldf|incf|decf|\.byte)\b')
MM = re.compile(r'(?i)^(ld|ldw)\b[^,]*\([^)]*\)\s*,\s*\(|^(ldmm8|ldmm16)\b')
LDA_CONST = re.compile(r'(?i)^lda\s+x\w+\s*,\s*\((0x[0-9a-f]+|\d+):16\)\s*$')
LD_CONST = re.compile(r'(?i)^ld\s+x\w+\s*,\s*(0x[0-9a-f]+|\d+)\s*$')


def items(path):
    """[(line number, [labels before this instruction], instruction)], comments stripped, directives kept"""
    out, pend = [], []
    for n, raw in enumerate(open(path, encoding='latin-1').read().split('\n'), 1):
        c = raw.split(';')[0].strip()
        while True:
            m = LABEL.match(c)
            if not m:
                break
            pend.append(m.group(1)); c = m.group(2).strip()
        if c:
            ins = ' '.join(c.split())
            if ins.lower().startswith(('.equ', '.set', '.include', '.globl', '.section', '.text', '.align', '.p2align', '.if',
                               '.else', '.endif', '.ifndef', '.ifdef', '.macro', '.endm')):
                continue
            out.append((n, pend, ins)); pend = []
    return out


def files_of(tree):
    for dp, dn, fn in os.walk(tree):
        dn[:] = sorted(d for d in dn if d not in ('generated', 'tools', 'cc900', 'cc900-staged'))
        for f in sorted(fn):
            if f.endswith('.s'):
                yield os.path.join(dp, f)


def num(v):
    return int(v, 0)


def survey(tree):
    ref = {}
    for l in open(os.path.join(REPO, SYMREF[tree])):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            ref[p[0]] = int(p[1], 16)
    files = {os.path.relpath(p, os.path.join(REPO, tree)): items(p) for p in files_of(os.path.join(REPO, tree))}
    target = set()
    for it in files.values():
        for _, _, ins in it:
            for rx in (CALL, LDA):
                m = rx.match(ins)
                if m:
                    target.add(m.groups()[-1])
            m = LONG.match(ins)
            if m:
                target |= set(re.findall(r'[A-Za-z_]\w*', m.group(1)))
    routines, ocount = [], collections.defaultdict(lambda: [0, 0])
    for f, it in files.items():
        for _, _, ins in it:
            if LDA_CONST.match(ins) and 8 <= num(LDA_CONST.match(ins).group(1)) <= 0xffff:
                ocount[f][0] += 1
            if LD_CONST.match(ins) and 8 <= num(LD_CONST.match(ins).group(1)) <= 0xffff:
                ocount[f][1] += 1
        code = [k for k, x in enumerate(it) if not x[2].startswith('.') or x[2].startswith('.byte')]
        starts = []
        for k, (_, labs, ins) in enumerate(it):
            if not any(l in target for l in labs) or ins.startswith(('.long', '.ascii', '.short', '.word', '.zero',
                                                                     '.fill', '.space', '.incbin', '.string')):
                continue
            prev = it[k - 1][2] if k else 'ret'
            if TERM.match(prev) and not re.match(r'(?i)^(jp|jr|jrl)\s+(?!t\s*,)\w+\s*,', prev):
                starts.append(k)
        for a, b in zip(starts, starts[1:] + [None]):
            body = it[a:b] if b is not None else it[a:]
            # stop at the first data directive after the code
            for j, x in enumerate(body):
                if x[2].startswith('.') and not x[2].startswith('.byte'):
                    body = body[:j]; break
            if not body:
                continue
            name = next((l for l in body[0][1] if l in ref), None)
            end = None
            if b is not None:
                end = next((ref[l] for l in it[b][1] if l in ref), None)
            if name is None:
                continue
            own = {l for x in body for l in x[1]}
            ops = [x[2] for x in body]
            low = [o.lower() for o in ops]
            calls = [CALL.match(o) for o in ops]
            ncall = sum(1 for m in calls if m and m.group(1) == 'call')
            ncalr = sum(1 for m in calls if m and m.group(1) == 'calr')
            calr_t = sorted({m.group(2) for m in calls if m and m.group(1) == 'calr'})
            outj = sum(1 for o in ops if JUMP.match(o) and JUMP.match(o).groups()[-1] not in own) + \
                sum(1 for o in low if o.startswith('jp') and '(' in o)
            cm = sum(1 for o in ops if CMARK.match(o))
            hd = sum(1 for o in ops if HAND.match(o))
            erp = sum(1 for o in low if 'erp' in o.split()[0])
            nop = sum(1 for o in low if o == 'nop')
            mm = sum(1 for o in ops if MM.match(o))
            cls = 'hand' if hd else 'C' if cm else '?'
            kind = 'leaf' if not (ncall or ncalr or outj) else 'rel' if ncalr else 'abs'
            size = end - ref[name] if end is not None and end > ref[name] else None
            routines.append(dict(name=name, file=f, line=body[0][0], addr=ref[name], bytes=size, insns=len(body),
                                 call=ncall, calr=ncalr, outj=outj, cmark=cm, hand=hd, erp=erp, nop=nop, mm=mm,
                                 cls=cls, kind=kind, calr_t=calr_t))
    # calr groups: union-find over calr edges
    parent = {r['name']: r['name'] for r in routines}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x
    owner = {}
    for r in routines:
        owner[r['name']] = r['name']
    # a calr target may be an inner label: map it to its routine
    inner = {}
    for f, it in files.items():
        cur = None
        names = {r['line']: r['name'] for r in routines if r['file'] == f}
        for n, labs, _ in it:
            if n in names:
                cur = names[n]
            for l in labs:
                if cur:
                    inner[l] = cur
    for r in routines:
        for t in r['calr_t']:
            if t in inner:
                a, b = find(r['name']), find(inner[t])
                if a != b:
                    parent[a] = b
    groups, gid = {}, {}
    for r in sorted(routines, key=lambda r: r['addr']):
        g = find(r['name'])
        if g not in gid:
            gid[g] = len(gid) + 1
        r['group'] = gid[g]
    return routines, ocount


def table(rows, head):
    w = [max(len(str(x)) for x in col) for col in zip(head, *rows)]
    line = lambda r: '| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |'
    return '\n'.join([line(head), '|' + '|'.join('-' * (n + 2) for n in w) + '|'] + [line(r) for r in rows])


def main():
    a = sys.argv[1:]
    tree = a[0] if a and not a[0].startswith('--') else 'v142/subcpu'
    top = int(a[a.index('--top') + 1]) if '--top' in a else 60
    routines, ocount = survey(tree)
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as fh:
            keys = ['addr', 'bytes', 'insns', 'name', 'file', 'cls', 'kind', 'call', 'calr', 'outj', 'cmark', 'hand',
                    'erp', 'nop', 'mm', 'group']
            fh.write('\t'.join(keys) + '\n')
            for r in sorted(routines, key=lambda r: r['addr']):
                fh.write('\t'.join('%06x' % r[k] if k == 'addr' else str(r[k]) for k in keys) + '\n')
    per = collections.OrderedDict()
    for r in sorted(routines, key=lambda r: r['addr']):
        p = per.setdefault(r['file'], collections.Counter())
        b = r['bytes'] or 0
        p['routines'] += 1; p['bytes'] += b
        p['C bytes'] += b if r['cls'] == 'C' else 0
        p['hand bytes'] += b if r['cls'] == 'hand' else 0
        p['leaf'] += r['kind'] == 'leaf'
        p['leaf C bytes'] += b if r['kind'] == 'leaf' and r['cls'] != 'hand' else 0
    rows = [(f, p['routines'], p['bytes'], p['C bytes'], p['hand bytes'], p['leaf'], p['leaf C bytes'],
             ocount[f][0], ocount[f][1]) for f, p in per.items()]
    tot = [sum(r[i] for r in rows) for i in range(1, 9)]
    rows.append(('total', *tot))
    head = ('file', 'routines', 'bytes', 'class C', 'class hand', 'leaf', 'leaf not hand', 'lda N:16', 'ld xR,N')
    md = ['## Per hand source (%s)' % tree, '', table(rows, head), '']
    cand = [r for r in routines if r['kind'] in ('leaf', 'abs') and r['cls'] != 'hand' and r['bytes'] and r['mm'] == 0]
    cand.sort(key=lambda r: -r['bytes'])
    crow = [(r['name'], r['file'], r['bytes'], r['insns'], r['kind'], r['cls'], r['call'], r['erp'], r['nop'],
             r['group']) for r in cand[:top]]
    md += ['## Candidates: leaf or absolute-call-only, not hand, no memory-to-memory move (largest %d of %d, %d B)'
           % (len(crow), len(cand), sum(r['bytes'] for r in cand)), '',
           table(crow, ('routine', 'file', 'bytes', 'insns', 'kind', 'class', 'calls', 'erp', 'nop', 'calr group')), '']
    text = '\n'.join(md)
    if '--md' in a:
        open(a[a.index('--md') + 1], 'w').write(text + '\n')
    else:
        print(text)
    print('%d routines, %d candidates' % (len(routines), len(cand)), file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
