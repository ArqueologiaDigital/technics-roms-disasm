#!/usr/bin/env python3
"""Control flow over a list of dump records (dump.py): successors of each record and a liveness question.

QUESTION ANSWERED: is a variable live across a call (read on some path after the call before it is written)?  S2
marks such parameters {MO} (moved out of their argument register); see s2.py.
"""
import re

import dump

CALLS = {'ACALL', 'ACALP', 'CCALL', 'CCALP', 'ARICALL'}


def successors(recs):
    labels = {r.args[0]: i for i, r in enumerate(recs) if r.op == 'LAB'}
    succ = []
    for i, r in enumerate(recs):
        nxt = [i + 1] if i + 1 < len(recs) else []
        if r.op == 'JMP':
            succ.append([labels[r.args[0]]] if r.args[0] in labels else [])
        elif r.op == 'END':
            succ.append([])
        elif r.op in dump.BRANCH and r.res and r.res.startswith('L'):
            succ.append(nxt + ([labels[r.res]] if r.res in labels else []))
        elif r.op == 'Switch':
            succ.append([labels[x] for x in r.args[0].split() if x in labels])
        else:
            succ.append(nxt)
    return succ


def mentions(x, name):
    return bool(x) and re.search(r'(?<![\w.])%s\(' % re.escape(name), x) is not None


def reads(r, name):
    if any(mentions(x, name) for x in r.args):
        return True
    if r.res and (r.res.startswith('*') or r.res.startswith('@(')) and mentions(r.res, name):
        return True
    return bool(r.res) and mentions(r.res, name) and (
        r.op.endswith('=') and r.op not in ('=', 'CONV', '==', '!=', '<=', '>=') or
        r.op in ('++', '--', 'BSET', 'BCLR', 'Switch', 'NOT', 'NEG'))   # (a compare producing a value writes only)


def writes(r, name):
    return bool(r.res) and re.match(r'^%s\(' % re.escape(name), r.res) is not None and not reads(r, name)


def live_across_call(recs, name):
    succ = successors(recs)
    for c, r in enumerate(recs):
        if r.op not in CALLS or (r.res and re.match(r'^%s\(' % re.escape(name), r.res)):
            continue                                 # (a call that writes the variable: not live across it)
        seen, todo = set(), list(succ[c])
        while todo:
            i = todo.pop()
            if i in seen:
                continue
            seen.add(i)
            if reads(recs[i], name):
                return True
            if writes(recs[i], name):
                continue
            todo.extend(succ[i])
    return False


def live_at_entry(recs, name):
    """is the variable read (or its address taken) on some path from the start before it is written?"""
    succ = successors(recs)
    seen, todo = set(), [0] if recs else []
    while todo:
        i = todo.pop()
        if i in seen:
            continue
        seen.add(i)
        if reads(recs[i], name):
            return True
        if writes(recs[i], name):
            continue
        todo.extend(succ[i])
    return False


def live_sets(recs, names):
    """the set of `names` live into each record (backward dataflow over successors())"""
    succ = successors(recs)
    use = [{n for n in names if reads(r, n)} for r in recs]
    defs = [{n for n in names if writes(r, n)} for r in recs]
    live_in = [set() for _ in recs]
    changed = True
    while changed:
        changed = False
        for i in range(len(recs) - 1, -1, -1):
            out = set()
            for j in succ[i]:
                out |= live_in[j]
            new = use[i] | (out - defs[i])
            if new != live_in[i]:
                live_in[i] = new
                changed = True
    return live_in


def interference(recs, names):
    """{name: names live together with it somewhere}"""
    sets = live_sets(recs, names)
    inter = {n: set() for n in names}
    for i, s in enumerate(sets):
        here = set(s)
        for n in defs_at(recs[i], names):       # a definition interferes with what is live after it
            here.add(n)
        for a in here:
            inter[a] |= here - {a}
    return inter


def defs_at(r, names):
    return [n for n in names if writes(r, n)]
