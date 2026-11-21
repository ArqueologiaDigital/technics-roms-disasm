#!/usr/bin/env python3
"""Write v141's and v140's staged C from v142's.

QUESTION ANSWERED: v141/subcpu and v140/subcpu are v142's source with edits (CLAUDE.md, ROM components).  Their
uninitialised RAM starts at their own Payload_Bss_Start (v142 0x3ee76, v141 0x3ee5e, v140 0x3ee2a: the program
image above it is shorter), and the source spells those cells Payload_Bss_Start+offset.  So a v142 cell
`ram_<hex>` in v142's zero-initialised window (Payload_Bss_Start .. + Payload_Bss_Size) is the same offset from
the tree's own; every other address (the
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
BSS_SIZE = 0x66f2                           # Payload_Bss_Size: the tone generator's ports (0x100000..) do not move
# {tree: {function label, ...}} that V4.23 showed differ there.  Audio_Process_DSP: v1.40's body differs
# (create_v140_subcpu_source.py's EDITS 4-7); v140 keeps its hand assembly (that script's UNSPLICE).
DROP = {'v140': {'Audio_Process_DSP'}}
FUNC = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def ref(t):
    return {p[0]: int(p[1], 16) for p in (l.split() for l in open(os.path.join(REPO, SYMS[t])))
            if len(p) == 2 and not p[0].startswith('#')}


def split_functions(text):
    """(head, [(name, function text, the declarations after it)]) -- a function runs from its definition line to
    its matching closing brace; what follows it up to the next definition (declarations) is kept apart, so that
    leaving a function out never drops a declaration a later function needs"""
    ms = list(FUNC.finditer(text))
    if not ms:
        return text, []
    head = text[:ms[0].start()]
    out = []
    for i, m in enumerate(ms):
        end = ms[i + 1].start() if i + 1 < len(ms) else len(text)
        j, depth = text.index('{', m.start()), 0
        while True:
            depth += {'{': 1, '}': -1}.get(text[j], 0)
            j += 1
            if depth == 0:
                break
        out.append((m.group(1), text[m.start():j], text[j:end]))
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
            keep = [n for n, _, _ in funcs if names.get(n, n) in tr and names.get(n, n) not in DROP.get(t, ())]
            if not keep:                    # nothing of this file in that tree: write no file
                print('%s %-36s 0 of %d functions: no file' % (t, os.path.basename(c), len(funcs)))
                continue
            body = head + ''.join((f if n in keep else '') + rest for n, f, rest in funcs)

            def cell(m):
                a = int(m.group(1), 16)
                return 'ram_%x' % (a + delta) if base <= a < base + BSS_SIZE else m.group(0)
            body = re.sub(r'\bram_([0-9a-f]+)\b', cell, body)
            open(os.path.join(d, os.path.basename(c)), 'w').write(body)
            print('%s %-36s %d of %d functions' % (t, os.path.basename(c), len(keep), len(funcs)))


if __name__ == '__main__':
    main()
