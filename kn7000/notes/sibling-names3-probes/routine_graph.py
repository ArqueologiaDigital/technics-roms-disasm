#!/usr/bin/env python3
"""Routine graph of a sibling's generated program source (lane open14/sibling-names3).

Question it answers: for each routine of <model>/src/program.s, what does its body name (callees,
strings, GUI ids, event codes, data labels, numeric I/O / RAM addresses) and who calls it.  The
hand-naming of sibling-only code reads this to find func_<ADDR> routines whose body carries its own
evidence (a string, a GUI id, an I/O latch, named callers / callees), and to list them by region.

A routine is a column-0 label that is not a local one: not `<x>_entry`, not `<x>_L<hex>`,
not `loc_<ADDR>`, not `.L*`, and whose next non-blank line is an instruction (data labels such as
`func_X_Table` are skipped).  A placeholder routine is exactly `^func_[0-9A-F]{8}$`.

    python3 -I kn7000/notes/sibling-names3-probes/routine_graph.py kn6000 [--clusters] [--evidence] [--dump NAME]

--clusters  func_ routines per 64 KB region, with how many have own evidence (string / GUI id)
--evidence  every func_ routine with a string or GUI-id reference, one line each
--dump N..  the routines' bodies and their callers (--brief: only the lines that name something)
"""
import re, sys, collections, argparse

PLACE = re.compile(r'^func_[0-9A-F]{8}$')
LOCAL = re.compile(r'(_entry$|_entry_L[0-9a-f]+$|_L[0-9a-f]+$|^loc_[0-9A-Fa-f]+$|^\.L)')
LABEL = re.compile(rb'^([A-Za-z_.$][\w.$]*):')
IDENT = re.compile(r'[A-Za-z_][\w]*')
HEX = re.compile(r'0x[0-9a-fA-F]{8}\b')
REG = {'d0','d1','d2','d3','a0','a1','a2','a3','sp','psw','mdr','lir','lar','pc'}


def base_of(name):
    """the routine a reference names (func_X_entry_L12 -> func_X)"""
    n = re.sub(r'_entry(_L[0-9a-f]+)?$', '', name)
    n = re.sub(r'_L[0-9a-f]+$', '', n)
    return n


def parse(model):
    lines = open(f'{model}/src/program.s', 'rb').read().split(b'\n')
    routines = collections.OrderedDict()
    cur = None
    pending = None
    for raw in lines:
        m = LABEL.match(raw)
        if m:
            name = m.group(1).decode('latin-1')
            if not LOCAL.search(name):
                pending = name
            rest = raw[m.end():].strip()
            if not rest:
                continue
            raw = b'\t' + rest
        s = raw.strip()
        if not s or s.startswith(b';'):
            continue
        if pending is not None:
            if s.startswith(b'.'):
                pending = None  # a data label
                cur = None
                continue
            cur = pending
            pending = None
            routines[cur] = []
        if cur is not None:
            if s.startswith(b'.'):
                if s.startswith((b'.include', b'.section', b'.org')):
                    cur = None
                continue
            routines[cur].append(s.split(b';')[0].decode('latin-1').strip())
    return routines


def analyse(routines):
    info = {}
    callers = collections.defaultdict(set)
    names = set(routines)
    for r, body in routines.items():
        d = collections.defaultdict(set)
        for ins in body:
            parts = ins.split(None, 1)
            op = parts[0]
            args = parts[1] if len(parts) > 1 else ''
            for tok in IDENT.findall(args):
                if tok in REG or re.fullmatch(r'0x[0-9a-fA-F]+', tok):
                    continue
                b = base_of(tok)
                if op in ('call', 'calls', 'jmp') and b in names and b != r:
                    d['callee'].add(b)
                    callers[b].add(r)
                elif tok.startswith('Str_'):
                    d['str'].add(tok)
                elif tok.endswith('_id'):
                    d['id'].add(tok)
                elif re.match(r'(EV|MT|EVT)_', tok):
                    d['ev'].add(tok)
                elif b in names and b != r:
                    d['ptr'].add(b)
                    callers[b].add(r)
                elif b != r:
                    d['sym'].add(tok)
            for h in HEX.findall(args):
                v = int(h, 16)
                top = v >> 24
                d['ram' if top in (0x50, 0x90, 0x84) else 'abs'].add(v)
        info[r] = d
    return info, callers


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('model')
    ap.add_argument('--clusters', action='store_true')
    ap.add_argument('--evidence', action='store_true')
    ap.add_argument('--dump', nargs='+')
    ap.add_argument('--brief', action='store_true', help='with --dump: only the lines that name something')
    a = ap.parse_args()
    routines = parse(a.model)
    info, callers = analyse(routines)
    def addr(n):
        m = re.search(r'([0-9A-F]{8})', n)
        return int(m.group(1), 16) if m else None
    if a.clusters:
        c = collections.Counter(); e = collections.Counter(); named = collections.Counter()
        for r in routines:
            ad = addr(r)
            if PLACE.match(r):
                c[ad >> 16] += 1
                if info[r]['str'] or info[r]['id']:
                    e[ad >> 16] += 1
        print(f'{a.model}: {sum(c.values())} func_ routines; region (64 KB), func_, of them with a string or GUI id')
        for k, v in c.most_common(25):
            print(f'  0x{k:04X}xxxx  {v:5}  {e[k]:4}')
    if a.evidence:
        for r in routines:
            if PLACE.match(r) and (info[r]['str'] or info[r]['id']):
                d = info[r]
                print(r, 'str=' + ','.join(sorted(d['str'])), 'id=' + ','.join(sorted(d['id'])),
                      'callee=' + ','.join(sorted(x for x in d['callee'] if not PLACE.match(x))),
                      'callers=' + ','.join(sorted(x for x in callers[r] if not PLACE.match(x))), sep='\t')
    for r in a.dump or ():
        cs = sorted(callers[r])
        print(f'; {r}  n={len(routines[r])}  callers ({len(cs)}): {" ".join(cs[:12])}{" ..." if len(cs) > 12 else ""}')
        for ins in routines[r]:
            if a.brief and not re.search(r'(call|jmp|Str_|_id\b|EV_|MT_|\(0x[0-9a-f]{8}\)|0x[0-9a-f]{8}|[A-Z][a-z]+[A-Z]\w*|\bcmp\b)', ins):
                continue
            print('\t' + ins)


if __name__ == '__main__':
    main()
