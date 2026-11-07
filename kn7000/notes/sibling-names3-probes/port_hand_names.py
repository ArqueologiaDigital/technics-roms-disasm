#!/usr/bin/env python3
"""Carry this lane's hand names from one sibling to another (lane open14/sibling-names3).

Question it answers: which routine (and RAM address) of sibling B is the one a hand row of sibling A
names, when A and B link the same module in the same order?

Method.  Both generated sources are cut into routines (routine_graph.parse).  Each body is masked:
every symbol (a label named or func_<ADDR>, a RAM or data name, a MILK id) and every hex number of 5
or more digits becomes one placeholder, so relinked and differently named code compares equal.  The
two lists of masked bodies, in address order, are aligned with difflib.SequenceMatcher (no junk
heuristic); a pair is kept inside an `equal` block of at least --min-run routines (default 3), so a
short routine is carried only with its neighbours, or, in a shorter block, when its body has at least
--min-long instructions (default 12).  A body that occurs again among the --window (default 8)
routines on either side of it in A is refused.  Then, outside the runs, a body of at least --min-long
instructions that occurs once in A and once in B pairs wherever it is (relinked modules move).
In a run of identical procedures the alignment can be
off by one (the audit found FtLangText01 / FtLangText03 that way before this rule).  A hand row of A carries to B when its routine
pairs and B's routine is still func_<ADDR>.  A var row (a RAM address) carries when, over every
paired routine, the instruction operands at the same place give A's address one B address and that
B address no other A address.

    python3 -I kn7000/notes/sibling-names3-probes/port_hand_names.py kn6000 kn6500 [--min-run N] [--report]

Writes B rows to stdout (`; same-body: = <A> 0x... ...`); --report prints counts instead, with the
audit: of the paired routines that both images name already, how many have the same name.
"""
import re, sys, difflib, collections, argparse
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import routine_graph as g

TOK = re.compile(r'[A-Za-z_][\w.]*|0x[0-9a-fA-F]+|-?\d+|\S')
REG = {'d0', 'd1', 'd2', 'd3', 'a0', 'a1', 'a2', 'a3', 'sp', 'psw', 'mdr', 'lir', 'lar', 'pc'}


def mask_ins(ins, labels):
    parts = ins.split(None, 1)
    op, args = parts[0], (parts[1] if len(parts) > 1 else '')
    out = [op]
    for t in TOK.findall(args):
        if (t.startswith('0x') and len(t) >= 7) or (re.match(r'[A-Za-z_]', t) and t not in REG):
            out.append('#')
        else:
            out.append(t)
    return ' '.join(out)


def operands(ins):
    parts = ins.split(None, 1)
    args = parts[1] if len(parts) > 1 else ''
    return [t for t in TOK.findall(args) if not (t in REG or t in ',()[]+-' or re.fullmatch(r'-?\d+|0x[0-9a-fA-F]{1,4}', t))]


def hand_rows(model):
    txt = open(f'{model}/{model}_manual.sym', encoding='latin-1').read()
    _, _, block = txt.partition('; ---- lane open14/sibling-names3')
    rows = []
    for ln in block.splitlines():
        m = re.match(r'\s*(0x[0-9A-Fa-f]+)\s+(\S+)\s*;\s*([a-z-]+):(.*)$', ln)
        if m:
            rows.append((int(m.group(1), 16), m.group(2), m.group(3), m.group(4).strip()))
    return rows


def addr_of(model):
    out = {}
    for f in (f'{model}/src/labels.inc', f'{model}/src/symbols.inc'):
        for ln in open(f, encoding='latin-1'):
            m = re.match(r'\s*\.equ\s+(\S+),\s*(0x[0-9a-fA-F]+)', ln)
            if m:
                out[m.group(1)] = int(m.group(2), 16)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('a'); ap.add_argument('b')
    ap.add_argument('--min-run', type=int, default=3)
    ap.add_argument('--window', type=int, default=8, help='refuse a body that repeats within this many routines')
    ap.add_argument('--min-long', type=int, default=12, help='a shorter equal run counts for bodies of this many instructions')
    ap.add_argument('--report', action='store_true')
    o = ap.parse_args()
    ra, rb = g.parse(o.a), g.parse(o.b)
    la, lb = set(ra), set(rb)
    na, nb = list(ra), list(rb)
    ma = [tuple(mask_ins(i, la) for i in ra[r]) for r in na]
    mb = [tuple(mask_ins(i, lb) for i in rb[r]) for r in nb]
    sm = difflib.SequenceMatcher(None, ma, mb, autojunk=False)
    pair = {}
    for blk in sm.get_matching_blocks():
        for k in range(blk.size):
            i = blk.a + k
            # a body repeated among its neighbours (a run of identical procedures) pairs ambiguously
            if any(ma[j] == ma[i] for j in range(max(0, i - o.window), min(len(ma), i + o.window + 1)) if j != i):
                continue
            if blk.size >= o.min_run or len(ma[i]) >= o.min_long:
                pair[na[i]] = nb[blk.b + k]
    # second pass: a body of at least --min-long instructions that is unique in A and in B pairs anywhere
    ca, cb = collections.Counter(ma), collections.Counter(mb)
    whereb = {m: nb[k] for k, m in enumerate(mb) if cb[m] == 1}
    paired_b = set(pair.values())
    unique_pass = 0
    for k, m in enumerate(ma):
        if na[k] not in pair and len(m) >= o.min_long and ca[m] == 1 and m in whereb and whereb[m] not in paired_b:
            pair[na[k]] = whereb[m]; paired_b.add(whereb[m]); unique_pass += 1
    adda, addb = addr_of(o.a), addr_of(o.b)
    # RAM address pairs over the paired routines
    seen = collections.defaultdict(set); back = collections.defaultdict(set)
    for x, y in pair.items():
        for ia, ib in zip(ra[x], rb[y]):
            for ta, tb in zip(operands(ia), operands(ib)):
                va = adda.get(ta, int(ta, 16) if ta.startswith('0x') else None)
                vb = int(tb, 16) if tb.startswith('0x') else addb.get(tb)
                if va is not None and vb is not None and (va >> 24) in (0x50, 0x90, 0x84) and (vb >> 24) in (0x50, 0x90, 0x84):
                    seen[va].add(vb); back[vb].add(va)
    rows = hand_rows(o.a)
    out, missed = [], collections.Counter()
    for a, name, cls, ev in rows:
        if cls in ('var',):
            bs = seen.get(a, set())
            if len(bs) == 1 and len(back[next(iter(bs))]) == 1:
                b = next(iter(bs))
                out.append(f'0x{b:08X}  {name:<24}; same-body: = {o.a.upper()} 0x{a:08X} ({o.a}_manual.sym, var): the paired routines spell the two addresses at the same operands')
            else:
                missed['var: no single pair'] += 1
            continue
        if cls == 'data':
            missed['data rows are not carried'] += 1
            continue
        ra_name = f'func_{a:08X}' if f'func_{a:08X}' in ra else name
        if ra_name not in pair:
            missed['routine not in an equal run'] += 1
            continue
        y = pair[ra_name]
        if not g.PLACE.match(y):
            missed['B routine already named' if y != name else 'B already has the name'] += 1
            continue
        out.append(f'0x{y[5:]}  {name:<24}; same-body: = {o.a.upper()} 0x{a:08X} ({o.a}_manual.sym, {cls}): the same masked body in the same place of the routine order')
    if o.report:
        both = [(x, y) for x, y in pair.items() if not g.PLACE.match(x) and not g.PLACE.match(y)]
        same = sum(1 for x, y in both if x == y)
        print(f'audit: {len(both)} paired routines named on both sides, {same} alike, {len(both) - same} unlike'
              + (': ' + ', '.join(f'{x}/{y}' for x, y in both if x != y) if len(both) != same else ''))
        print(f'{o.a} -> {o.b}: {len(pair)} routines paired ({unique_pass} of them by a unique long body); {len(rows)} hand rows, {len(out)} carried; ' + ', '.join(f'{k} {v}' for k, v in missed.items()))
    else:
        print('\n'.join(out))


if __name__ == '__main__':
    main()
