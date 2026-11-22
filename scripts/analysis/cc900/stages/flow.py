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
        r.op.endswith('=') and r.op not in ('=', 'CONV') or r.op in ('++', '--', 'BSET', 'BCLR', 'Switch'))


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
