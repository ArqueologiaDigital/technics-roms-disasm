#!/usr/bin/env python3
"""Write v141's and v140's staged C from v142's.

QUESTION ANSWERED: v141/subcpu and v140/subcpu are v142's source with edits (CLAUDE.md, ROM components).  Their
uninitialised RAM starts at their own Payload_Bss_Start (v142 0x3ee76, v141 0x3ee5e, v140 0x3ee2a: the program
image above it is shorter), and the source spells those cells Payload_Bss_Start+offset.  So a v142 cell
`ram_<hex>` at or above v142's Payload_Bss_Start is the same offset from the tree's own; every other address (the
low RAM below 0x10000, the tables at 0xf000.., the tone generator's ports) is the same in all three.  Labels named
in the C are each tree's own.  A function is copied only when the tree has its label; one that sub_v423.py's
`record` shows differing in a tree is listed in DROP below and left out of that tree.

    python3 -B notes/cc900-c-subcpu-2026-11-16/port_staged.py        (from the repository root)
        rewrites v141/subcpu/cc900-staged/*.c and v140/subcpu/cc900-staged/*.c from v142/subcpu/cc900-staged/*.c
"""
import glob, os, re

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SYMS = {'v142': 'symbols/subcpu_symbols_reference.txt', 'v141': 'symbols/subcpu_v141_symbols_reference.txt',
        'v140': 'symbols/subcpu_v140_symbols_reference.txt'}
DROP = {}                                   # {tree: {function label, ...}} that V4.23 showed differ there
FUNC = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def ref(t):
    return {p[0]: int(p[1], 16) for p in (l.split() for l in open(os.path.join(REPO, SYMS[t])))
            if len(p) == 2 and not p[0].startswith('#')}


def split_functions(text):
    """(head, [(name, text)]) -- a function runs from its definition line to its closing brace at column 0, or to
    the end of its one-line body"""
    ms = list(FUNC.finditer(text))
    if not ms:
        return text, []
    head = text[:ms[0].start()]
    out = []
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(text)
        out.append((m.group(1), text[m.start():end]))
    return head, out


def main():
    src = ref('v142')
    base = src['Payload_Bss_Start']
    for t in ('v141', 'v140'):
        tr = ref(t)
        delta = tr['Payload_Bss_Start'] - base
        d = os.path.join(REPO, t, 'subcpu', 'cc900-staged')
        os.makedirs(d, exist_ok=True)
        for c in sorted(glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'cc900-staged', '*.c'))):
            text = open(c).read()
            names = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text))
            head, funcs = split_functions(text)
            keep = [(n, b) for n, b in funcs if names.get(n, n) in tr and names.get(n, n) not in DROP.get(t, ())]
            body = head + ''.join(b for _, b in keep)

            def cell(m):
                a = int(m.group(1), 16)
                return 'ram_%x' % (a + delta) if a >= base else m.group(0)
            body = re.sub(r'\bram_([0-9a-f]+)\b', cell, body)
            open(os.path.join(d, os.path.basename(c)), 'w').write(body)
            print('%s %-36s %d of %d functions' % (t, os.path.basename(c), len(keep), len(funcs)))


if __name__ == '__main__':
    main()
