#!/usr/bin/env python3
"""Bodies of named trampolines (lane open14/sibling-names3).

Question it answers: which func_<ADDR> routines are the whole work of a NAMED routine whose own body
is nothing but a jump to them -- `[add -N, sp] / call func_X[_entry] / [ret|retf]` or a bare
`jmp func_X` -- so that the body takes the wrapper's name with `_Impl` (the repository's
`DrawBox` / `DrawBox_Impl` and uITRON `<svc>` / `<svc>_Impl` convention)?  A body qualifies only
when the trampoline is its only caller... or, when other routines call it too, every caller is a
trampoline of the same body (then the first by address gives the name and the row says so).

    python3 -I kn7000/notes/sibling-names3-probes/wrapper_bodies.py kn6000 [--rows]

--rows prints `<model>_manual.sym` rows (`; caller: ...` evidence) instead of the table.
"""
import re, sys, collections
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import routine_graph as g

TRAMP = [re.compile(r'^add\s+-?(0x[0-9a-f]+|\d+), sp$'), re.compile(r'^call\s+(\w+?)(_entry)?, .*$'),
         re.compile(r'^(ret|retf)\s')]


def trampoline_target(body):
    b = [i for i in body if i != 'nop']
    if len(b) == 1:
        m = re.match(r'^jmp\s+(\w+?)(_entry)?$', b[0])
        return m.group(1) if m else None
    if len(b) == 3 and TRAMP[0].match(b[0]) and TRAMP[2].match(b[2]):
        m = TRAMP[1].match(b[1])
        return m.group(1) if m else None
    if len(b) == 2 and TRAMP[2].match(b[1]):
        m = TRAMP[1].match(b[0])
        return m.group(1) if m else None
    return None


def find(model):
    rs = g.parse(model)
    info, callers = g.analyse(rs)
    out = []
    for body in rs:
        if not g.PLACE.match(body):
            continue
        cs = callers[body]
        if not cs:
            continue
        tramps = [c for c in cs if trampoline_target(rs[c]) == body]
        if len(tramps) != len(cs):
            continue
        named = sorted(c for c in tramps if not g.PLACE.match(c))
        if not named:
            continue
        out.append((body, named, len(cs)))
    return out


def main():
    rows = '--rows' in sys.argv
    for model in [a for a in sys.argv[1:] if not a.startswith('--')]:
        res = find(model)
        if not rows:
            print(f'{model}: {len(res)} func_ bodies whose every caller is a trampoline, one at least named')
        for body, named, n in res:
            nm = named[0] + '_Impl'
            if rows:
                more = f'; the trampolines {", ".join(named)} all reach it' if len(named) > 1 else ''
                print(f'0x{body[5:]}  {nm:<28}; caller: {named[0]} is `call` + ret of it, its only caller{more}')
            else:
                print(f'  {body}  <- {", ".join(named)}  ({n} callers)')


if __name__ == '__main__':
    main()
