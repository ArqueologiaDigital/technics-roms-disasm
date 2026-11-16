#!/usr/bin/env python3
"""Which routines of the HD-AE5000 v2.06i image look like compiled C, how large are they, and what do they call?

QUESTION ANSWERED: the HD-AE5000 links Toshiba's C library (notes/toshiba-runtime-xref-2026-11-08), so at least part
of Matsushita's own code in it was compiled with cc900.  Before writing C for it (cc900 phase 6, lane_hd), list every
routine of hdae5000/*.s -- a column-0 label up to the next one -- with:

  bytes    its extent, from the symbols reference (next column-0 label of the same file, else the next symbol)
  insns    instruction lines
  calr     same-module calls (asm900 shortens V4.23's `cal` to calr only for a target in the same file, so a routine
           with calr needs the coming `cc900-module:` marking before V4.23 can reproduce it)
  call     absolute calls (another module: the library or another C file) -- fine today
  icall    `call (xRR)`: calls through a pointer, mostly the main CPU's root-function table -- fine today
  ws       loads of HDAE5000_RAM_MainWorkspacePtr (the C's `ws->table->fn(...)` idiom)
  frame    the first instruction when it makes a frame: `lda xsp,(xsp-N)`, `dec N,xsp`, `push xiz` / `pushw iz`
  fall     entered by falling through from the label before (that one does not end in ret / jp / jr t / jrl t)
  hand     signs of hand assembly: di / ei / reti / halt / swi / ldc / push sr / pop sr / ldir(w) / ldi(w) / cpir /
           djnz / data directives between instructions / mnemonics our trees use only for raw encodings
  lib      the label is a Toshiba library routine (results/xref.resolved.tsv of the runtime xref)
  kind     C?      ends in ret / retd, no hand sign, not a library routine, not entered by fall-through
           C-calr  the same, but with same-module calls (wait for cc900-module)
           hand?   a hand sign
           lib     library
           tail    entered by fall-through (part of the routine before)
           other   does not end in a return (a jump-out tail, a switch arm, data)
  ported   which of the ported trees (v2.01i, v1.15i, v1.10i) define the label

    python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py [--md OUT.md] [--tsv OUT.tsv] [--kind C?] [--max-bytes N]
    python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py --body LABEL [--comments]
        the hand source of one function as the survey delimits it (its label up to the next function), comments
        stripped unless --comments

With no option it prints a summary and the C? routines by size.  Run from the repository root.  Reads only this
repository's sources and symbols references.
"""
import collections, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
TREE = os.path.join(REPO, 'hdae5000')
REFS = {'v2.06i': 'symbols/hdae5000_symbols_reference.txt', 'v2.01i': 'symbols/hdae5000_v2_01i_symbols_reference.txt',
        'v1.15i': 'symbols/hdae5000_v1_15i_symbols_reference.txt', 'v1.10i': 'symbols/hdae5000_v1_10i_symbols_reference.txt'}
XREF = 'notes/toshiba-runtime-xref-2026-11-08/results/xref.resolved.tsv'
LAB = re.compile(r'^([A-Za-z_][\w]*):(.*)$')
LOCAL = re.compile(r'^(\.L[\w.$]*):(.*)$')
HAND = {'di', 'ei', 'reti', 'halt', 'swi', 'ldc', 'ldir', 'ldirw', 'ldi', 'ldiw', 'lddr', 'lddrw', 'cpir', 'cpirw',
        'djnz', 'djnz8', 'djnz16', 'ldir83', 'ldi85', 'cpir83', 'mirr', 'bs1f', 'bs1b', 'bs1b16', 'ldf', 'incf', 'decf',
        'scf', 'rcf', 'zcf', 'ccf', 'daa', 'paa', 'link', 'unlk', 'ex8', 'ldcf', 'stcf', 'ldcf16ri', 'stcf16ri', 'stcf8ri',
        'mdec1', 'mdec2', 'mdec4', 'minc1', 'minc2', 'minc4'}
DATA = ('.byte', '.short', '.word', '.long', '.ascii', '.asciz', '.incbin', '.space', '.fill', '.zero')
ENDS = {'ret', 'retd', 'reti'}


def code(l):
    return l.split(';')[0].strip()


def load_ref(rel):
    p = os.path.join(REPO, rel)
    ref = {}
    if not os.path.exists(p):
        return ref
    for l in open(p, encoding='latin-1'):
        f = l.split()
        if len(f) == 2 and not l.startswith('#'):
            ref[f[0]] = int(f[1], 16)
    return ref


def library_labels():
    labs = set()
    for l in open(os.path.join(REPO, XREF), encoding='latin-1'):
        f = l.rstrip('\n').split('\t')
        if len(f) > 4 and f[0].startswith('hdae'):
            labs.add(f[4])
    return labs


def unconditional_end(ins):
    if not ins:
        return False
    w = ins.split()
    op = w[0]
    if op in ENDS:
        return True
    if op in ('jp', 'jr', 'jrl'):
        rest = ins[len(op):].strip()
        return ',' not in rest or rest.startswith('t,') or rest.startswith('t ')
    return False


def label_refs(texts):
    """{label: set of reference kinds}: 'call' (call / calr), 'branch' (jr / jrl / jp / djnz), 'other' (any other
    operand or data directive: an address taken)"""
    refs = collections.defaultdict(set)
    word = re.compile(r'[A-Za-z_]\w*')
    for L in texts:
        for l in L:
            c = code(l)
            m = LAB.match(c) or LOCAL.match(c)
            if m:
                c = m.group(2).strip()
            if not c:
                continue
            op = c.split()[0]
            kind = 'call' if op in ('call', 'calr') else 'branch' if op in ('jr', 'jrl', 'jp', 'djnz', 'djnz8',
                                                                            'djnz16') else 'other'
            for w in word.findall(c[len(op):]):
                refs[w].add(kind)
    return refs


def blocks_of(L):
    blocks, cur = [], None
    for l in L:
        c = code(l)
        m = LAB.match(c)
        if m:
            cur = [m.group(1), []]
            blocks.append(cur)
            rest = m.group(2).strip()
            if rest:
                cur[1].append(rest)
            continue
        if cur is None or not c:
            continue
        m = LOCAL.match(c)
        if m:
            rest = m.group(2).strip()
            if rest:
                cur[1].append(rest)
            continue
        cur[1].append(c)
    return blocks


def routines():
    """one row per function: a column-0 label that is called, whose address is taken, or that nothing references and
    nothing falls into; the column-0 labels after it that only branches reach (or that it falls into) are its inner
    blocks"""
    ref = load_ref(REFS['v2.06i'])
    addrs = sorted(set(ref.values()))
    lib = library_labels()
    ported = {k: load_ref(v) for k, v in REFS.items() if k != 'v2.06i'}
    files = {f: open(os.path.join(TREE, f), encoding='latin-1').read().split('\n')
             for f in sorted(os.listdir(TREE)) if f.endswith('.s')}
    refs = label_refs(files.values())
    out = []
    for f, L in files.items():
        funcs, prev_last = [], None
        for name, body in blocks_of(L):
            ins = [b for b in body if not b.startswith('.')]
            data = [b for b in body if b.split()[0] in DATA]
            fall = prev_last is not None and not unconditional_end(prev_last) and bool(ins)
            rk = refs.get(name, set())
            start = (not funcs or not ins or not funcs[-1]['ins'] or bool(rk & {'call', 'other'}) or
                     (not rk and not fall) or name in lib)
            if start:
                funcs.append({'name': name, 'ins': [], 'data': [], 'fall': fall, 'inner': 0, 'blocks': [name]})
            else:
                funcs[-1]['inner'] += 1
                funcs[-1]['blocks'].append(name)
            funcs[-1]['ins'] += ins
            funcs[-1]['data'] += data
            if ins:
                prev_last = ins[-1]
            elif data:
                prev_last = 'ret'           # a data block between: the next routine is not a fall-through
        for i, fn in enumerate(funcs):
            name, ins, data = fn['name'], fn['ins'], fn['data']
            a = ref.get(name)
            nxt = None
            for g in funcs[i + 1:]:
                if ref.get(g['name'], -1) > (a or -1):
                    nxt = ref[g['name']]
                    break
            if a is not None and nxt is None:
                nxt = next((x for x in addrs if x > a), None)
            size = (nxt - a) if a is not None and nxt is not None else None
            ops = [b.split()[0] for b in ins]
            r = collections.OrderedDict()
            r['file'] = f
            r['label'] = name
            r['addr'] = '%06x' % a if a is not None else '-'
            r['bytes'] = size if size is not None else 0
            r['insns'] = len(ins)
            r['inner'] = fn['inner']
            r['calr'] = ops.count('calr')
            r['call'] = sum(1 for b in ins if b.split()[0] == 'call' and '(' not in b)
            r['icall'] = sum(1 for b in ins if b.split()[0] in ('call', 'call_cc_ri') and '(' in b)
            r['ws'] = sum(1 for b in ins if 'MainWorkspacePtr' in b)
            first = ins[0] if ins else ''
            r['frame'] = (first.split()[0] + ' ' + first.split(None, 1)[1].replace(' ', '')) if (
                first.startswith('lda xsp') or first.startswith('dec ') and 'xsp' in first or
                first in ('push xiz', 'pushw iz')) else ''
            r['fall'] = int(fn['fall'])
            hand = sorted({o for o in ops if o in HAND} | ({'push sr'} if any(b.replace(' ', '') in ('pushsr', 'popsr')
                                                                                for b in ins) else set()))
            if data and ins:
                hand.append('data-in-code')
            r['hand'] = ','.join(hand)
            r['lib'] = int(name in lib)
            ends = bool(ops) and ops[-1] in ('ret', 'retd') or any(o in ('ret', 'retd') for o in ops)
            if not ins:
                kind = 'data'
            elif r['lib']:
                kind = 'lib'
            elif r['fall']:
                kind = 'tail'
            elif hand:
                kind = 'hand?'
            elif not ends:
                kind = 'other'
            elif r['calr']:
                kind = 'C-calr'
            else:
                kind = 'C?'
            r['kind'] = kind
            r['ported'] = ','.join(k for k, p in ported.items() if name in p)
            out.append(r)
    return out


def opt(a, n, d=None):
    return a[a.index(n) + 1] if n in a else d


def md_table(rows, cols):
    w = {c: max(len(c), *(len(str(r[c])) for r in rows)) if rows else len(c) for c in cols}
    s = ['| ' + ' | '.join(c.ljust(w[c]) for c in cols) + ' |', '|' + '|'.join('-' * (w[c] + 2) for c in cols) + '|']
    for r in rows:
        s.append('| ' + ' | '.join(str(r[c]).ljust(w[c]) for c in cols) + ' |')
    return '\n'.join(s)


def body(label, comments):
    for f in sorted(os.listdir(TREE)):
        if not f.endswith('.s'):
            continue
        L = open(os.path.join(TREE, f), encoding='latin-1').read().split('\n')
        starts = {r['label'] for r in ROWS if r['file'] == f}
        on = False
        for l in L:
            m = LAB.match(code(l))
            if m and m.group(1) in starts:
                if on:
                    return
                on = m.group(1) == label
            if on:
                t = l if comments else l.split(';')[0].rstrip()
                if t.strip():
                    print(t)
        if on:
            return


ROWS = []


def main():
    a = sys.argv[1:]
    if '--body' in a:
        ROWS.extend(routines())
        body(opt(a, '--body'), '--comments' in a)
        return
    rows = routines()
    kind = opt(a, '--kind')
    mx = int(opt(a, '--max-bytes', '0'))
    code_rows = [r for r in rows if r['kind'] != 'data']
    summ = collections.OrderedDict()
    for r in code_rows:
        s = summ.setdefault(r['kind'], [0, 0])
        s[0] += 1
        s[1] += r['bytes']
    srows = [{'kind': k, 'routines': v[0], 'bytes': v[1]} for k, v in sorted(summ.items(), key=lambda kv: -kv[1][1])]
    srows.append({'kind': 'total', 'routines': sum(v[0] for v in summ.values()), 'bytes': sum(v[1] for v in summ.values())})
    sel = [r for r in code_rows if (kind is None or r['kind'] == kind) and (not mx or r['bytes'] <= mx)]
    sel.sort(key=lambda r: (-r['bytes'], r['label']))
    cols = ['label', 'file', 'addr', 'bytes', 'insns', 'inner', 'calr', 'call', 'icall', 'ws', 'frame', 'kind', 'hand', 'ported']
    if '--tsv' in a:
        with open(opt(a, '--tsv'), 'w') as f:
            f.write('\t'.join(rows[0].keys()) + '\n')
            for r in sorted(code_rows, key=lambda r: r['addr']):
                f.write('\t'.join(str(v) for v in r.values()) + '\n')
    if '--md' in a:
        with open(opt(a, '--md'), 'w') as f:
            f.write(md_table(srows, ['kind', 'routines', 'bytes']) + '\n\n')
            f.write(md_table(sel, cols) + '\n')
    if '--tsv' not in a and '--md' not in a:
        print(md_table(srows, ['kind', 'routines', 'bytes']))
        print()
        print(md_table(sel if kind else [r for r in sel if r['kind'] == 'C?'], cols))


if __name__ == '__main__':
    main()
