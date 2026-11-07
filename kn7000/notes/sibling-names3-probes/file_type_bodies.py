#!/usr/bin/env python3
"""Load / save bodies of a sibling's disk files, by the file type they build the name for (lane open14/sibling-names3).

Question it answers: which routines open a disk file "rb" or "wb" whose name they first build with
the extension table's builder (KN6000 FileNameWithExt, the KN2400's twin at 0x486D0F12: copy the
name, append ".", append FileTypeExtTable[d0]) -- and for which type?  The type index is the
`mov N, d0` right before the builder call; the extension is the table's N-th string (read from the
data source).  A routine that builds exactly one type and opens exactly one mode is a candidate for
`Load<EXT>File` / `Save<EXT>File`; two routines with the same type and mode are listed, not named.

    python3 -I kn7000/notes/sibling-names3-probes/file_type_bodies.py kn2400 0x486D0F12 [--rows]
"""
import re, sys, collections
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import routine_graph as g

EXT = ['LSW', 'PMT', 'SQT', 'CMP', 'TM', 'MSP', 'EFC', 'MD', 'FAV', 'HMP', 'AST', 'SQF', 'SEQ', 'ACT']


def main():
    model, builder = sys.argv[1], int(sys.argv[2], 16)
    rows = '--rows' in sys.argv
    rs = g.parse(model)
    bname = next((r for r in rs if r == f'func_{builder:08X}'), None)
    if bname is None:  # already named
        for ln in open(f'{model}/src/labels.inc', encoding='latin-1'):
            pass
        bname = sys.argv[3] if len(sys.argv) > 3 and not sys.argv[3].startswith('--') else None
    found = collections.defaultdict(list)
    for r, body in rs.items():
        types, modes, opener = set(), set(), False
        for k, ins in enumerate(body):
            if re.match(rf'call\s+{bname}(_entry)?\b', ins):
                for j in range(k - 1, max(-1, k - 4), -1):
                    m = re.match(r'mov\s+(\d+|0x[0-9a-f]+), d0$', body[j])
                    if m:
                        types.add(int(m.group(1), 0)); break
            m = re.search(r'\bStr_(rb|wb)(_\d+)?\b', ins)
            if m:
                modes.add(m.group(1))
            if re.search(r'call\s+(fmmopen|FileOpen)(_entry)?\b', ins):
                opener = True
        if opener and len(types) == 1 and len(modes) == 1:
            t, md = types.pop(), modes.pop()
            found[(t, md)].append(r)
    for (t, md), rr in sorted(found.items()):
        nm = ('Load' if md == 'rb' else 'Save') + EXT[t].capitalize() + 'File'
        if rows:
            if len(rr) == 1 and g.PLACE.match(rr[0]):
                print(f'0x{rr[0][5:]}  {nm:<24}; string: builds the name of a .{EXT[t]} file ({bname} with type {t}, FileTypeExtTable) and opens it "{md}"')
        else:
            print(f'type {t:2} {EXT[t]:3} {md}: {" ".join(rr)}')


if __name__ == '__main__':
    main()
