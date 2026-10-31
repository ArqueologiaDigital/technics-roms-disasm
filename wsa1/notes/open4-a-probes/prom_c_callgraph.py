#!/usr/bin/env python3
"""prom_c's static call graph, read from the converted sources (lane open4/wsa1-a, 2026-10-31).

Reads prom_c/wsa1_prom_c.s and every file it `.include`s, in order, as BYTES.
A ROUTINE is a column-0 label that is not local: a label spelled `<owner>__<hex>`
or `.L...` belongs to the routine above it.  Edges:

  call   `call` / `calr` / `jp` / `jr` / `jrl` / `djnz` to a label of ANOTHER routine
  table  a `.long` entry of a label block that code references by an immediate
         (`add xRR,T` / `ld xRR,T` / `lda xRR,T`), i.e. a computed-goto table
  ref    any other symbolic operand naming a routine (a pointer handed on)

Importable (graph(), routine_of(), ROOT) and runnable:

  python3 notes/open4-a-probes/prom_c_callgraph.py --callers NAME   transitive callers
  python3 notes/open4-a-probes/prom_c_callgraph.py --closure NAME   forward call+table closure
"""
import os, re, sys
from collections import defaultdict

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
LABEL = re.compile(rb'^([A-Za-z_.$][\w.$]*):')
IDENT = re.compile(rb'[A-Za-z_][\w.]*')
BRANCH = {b'call', b'calr', b'jp', b'jr', b'jrl', b'djnz'}
REGS = set(b'a w b c d e h l wa bc de hl ix iy iz sp xwa xbc xde xhl xix xiy xiz xsp '
           b'z nz c nc t f ugt ule ult uge gt ge lt le eq ne ov nov mi pl'.split())


def lines(path=b'prom_c/wsa1_prom_c.s', seen=None):
    seen = set() if seen is None else seen
    full = os.path.join(ROOT, path.decode())
    if full in seen:
        return
    seen.add(full)
    for raw in open(full, 'rb').read().split(b'\n'):
        code = raw.split(b';', 1)[0] if b'.ascii' not in raw else raw.split(b'"')[0]
        m = re.match(rb'\s*\.include\s+"([^"]+)"', code)
        if m:
            yield from lines(m.group(1), seen)
            continue
        yield raw, code


def is_local(name):
    return name.startswith(b'.L') or b'__' in name


def graph():
    """Return (owner, edges): owner[label] = routine; edges[kind][routine] = set(routines)."""
    owner, body = {}, []
    cur = None
    for raw, code in lines():
        m = LABEL.match(code)
        if m:
            name = m.group(1)
            if not is_local(name):
                cur = name
            owner[name] = cur
            code = code[m.end():]
        body.append((cur, code.strip()))
    edges = {k: defaultdict(set) for k in ('call', 'table', 'ref')}
    tables = defaultdict(list)
    for cur, code in body:
        if code.startswith(b'.long'):
            for t in IDENT.findall(code[5:]):
                if t in owner:
                    tables[cur].append(owner[t])
    for cur, code in body:
        if not code or code.startswith(b'.'):
            continue
        parts = code.split(None, 1)
        mn = parts[0].lower()
        ops = parts[1] if len(parts) > 1 else b''
        for t in IDENT.findall(ops):
            if t.lower() in REGS or t not in owner:
                continue
            tgt = owner[t]
            if mn in BRANCH:
                if tgt != cur:
                    edges['call'][cur].add(tgt)
            elif tgt in tables and tgt != cur:
                edges['table'][cur].update(x for x in tables[tgt] if x != cur)
                edges['ref'][cur].add(tgt)
            elif tgt != cur:
                edges['ref'][cur].add(tgt)
    return owner, edges


def closure(start, edges, kinds=('call', 'table'), stop=()):
    seen, todo = set(start), list(start)
    while todo:
        r = todo.pop()
        for k in kinds:
            for t in edges[k].get(r, ()):
                if t not in seen and t not in stop:
                    seen.add(t)
                    todo.append(t)
    return seen


def callers(name, edges, kinds=('call', 'table')):
    rev = defaultdict(set)
    for k in kinds:
        for a, bs in edges[k].items():
            for b in bs:
                rev[b].add(a)
    seen, todo = {name}, [name]
    while todo:
        r = todo.pop()
        for a in rev.get(r, ()):
            if a not in seen:
                seen.add(a)
                todo.append(a)
    return seen - {name}, rev


if __name__ == '__main__':
    owner, edges = graph()
    if len(sys.argv) == 3 and sys.argv[1] == '--callers':
        s, _ = callers(sys.argv[2].encode(), edges)
        print('\n'.join(sorted(x.decode() for x in s)))
    elif len(sys.argv) == 3 and sys.argv[1] == '--closure':
        print('\n'.join(sorted(x.decode() for x in closure({sys.argv[2].encode()}, edges))))
    else:
        print(__doc__)
        sys.exit(2)
