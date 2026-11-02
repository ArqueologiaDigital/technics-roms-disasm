#!/usr/bin/env python3
r"""split_c_string_runs.py -- one C member per string where the assembly already names each string.

QUESTION ANSWERED
-----------------
"Which `char X[N]` members of the NAKA C hold several strings that the assembly labels one by one?"
split_blobs_at_far_pointers.py (2026-10-02) split the .incbin of runs such as East_ResNames_3EC_Strings at
every string a far pointer reaches and labelled each piece (`InitializeEast_Str_TT_REVEQMENU: .incbin
"...naka_widget_tables_2.bin", 0x8FA, 0xE`), but the C kept the whole run as one member,
`char East_ResNames_3EC_Strings[252]` (notes/far-pointers-2026-10-02/README.md, "Still open").

For every `char NAME[N]` struct member of v10's NAKA C whose bytes v10's assembly places as two or more
labelled slices that tile it exactly (the first at the member's offset), each ending in NUL (or NUL and
one 0xFF pad: a label inside a string is not a string of its own), this replaces the member by one
`char <slice label>[len]` per slice, initialized from the compiled blob's bytes (a slice that ends in NUL
leaves that NUL to the array size), and rewrites every `SELF(NAME[k])` of the file to the piece that holds
byte k (`SELF(Label)` or `SELF(Label[j])`).  The member's comment block is kept above the first piece.
The layout does not change, so neither does one compiled byte; every edited file is compiled before and
after and must be identical (v10, v9, v7, v6, v5: the same member names, from v10's labels, in each tree's
copy of the C).

RUN (repository root, built tree)
    python3 scripts/converters/split_c_string_runs.py            # report
    python3 scripts/converters/split_c_string_runs.py --apply
"""
import argparse
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import ported_c_rebase as R              # noqa: E402  (compile_bin, dwarf_members, rule)
import naka_c_model as M                 # noqa: E402  (c_string)

TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
SLICE = re.compile(rb'^([A-Za-z_]\w*):\s*\.incbin\s+"includes/generated/([\w.]+\.bin)"\s*,\s*(0x[0-9a-fA-F]+|\d+)'
                   rb'\s*,\s*(0x[0-9a-fA-F]+|\d+)')


def slices(tree):
    out = {}
    for f in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
        for ln in open(f, 'rb'):
            m = SLICE.match(ln)
            if m:
                out.setdefault(m.group(2).decode(), []).append(
                    (int(m.group(3), 0), int(m.group(4), 0), m.group(1).decode()))
    return {k: sorted(v) for k, v in out.items()}


def plan(tree='v10'):
    """bin -> [(member, offset, size, [(label, off, len)])]"""
    sl = slices(tree)
    out = {}
    for c in sorted(glob.glob(os.path.join(ROOT, tree, 'maincpu', 'ui_widgets', 'naka_*.c'))):
        name = os.path.basename(c)[:-2] + '.bin'
        if name not in sl:
            continue
        t = open(c, 'rb').read().decode('latin-1')
        chars = dict(re.findall(r'^    char (\w+)\[(\d+)\];', t, re.M))
        if not chars:
            continue
        mem = R.dwarf_members(tree, name)
        for k, (off, mname, ty) in enumerate(mem):
            if mname not in chars:
                continue
            n = int(chars[mname])
            inside = [s for s in sl[name] if off <= s[0] < off + n]
            if len(inside) < 2 or inside[0][0] != off:
                continue
            pos, ok = off, True
            for so, sn, lab in inside:
                ok &= so == pos
                pos = so + sn
            if not ok or pos != off + n:
                continue
            out.setdefault(name, []).append((mname, off, n, [(lab, so, sn) for so, sn, lab in inside]))
    return out


def edit(text, blob, items):
    for mname, off, n, pieces in items:
        # struct member
        m = re.search(r'^    char %s\[%d\];\n' % (re.escape(mname), n), text, re.M)
        text = text[:m.start()] + ''.join('    char %s[%d];\n' % (lab, sn) for lab, so, sn in pieces) + text[m.end():]
        # initializer: `.NAME = "..." "..." ...,` up to the comma that ends it
        m = re.search(r'\n    \.%s = ' % re.escape(mname), text)
        i, instr = m.end(), False
        while True:
            ch = text[i]
            if instr:
                if ch == '\\':
                    i += 2
                    continue
                if ch == '"':
                    instr = False
            elif ch == '"':
                instr = True
            elif ch == ',':
                break
            i += 1
        inits = []
        for lab, so, sn in pieces:
            b = blob[so:so + sn]
            lit = b[:-1] if b.endswith(b'\x00') else b
            inits.append('    .%s = %s,' % (lab, M.c_string(lit)))
        text = text[:m.start() + 1] + '\n\n'.join(inits) + text[i + 1:]

        def rep(mm):
            k = int(mm.group(1), 0) if mm.group(1) else 0
            for lab, so, sn in pieces:
                if so - off <= k < so - off + sn:
                    j = k - (so - off)
                    return 'SELF(%s)' % lab if j == 0 else 'SELF(%s[%d])' % (lab, j)
            raise SystemExit('SELF(%s[%d]) outside the member' % (mname, k))
        text = re.sub(r'SELF\(\s*%s(?:\[\s*(0x[0-9A-Fa-f]+|\d+)\s*\])?\s*\)' % re.escape(mname), rep, text)
    return text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--apply', action='store_true')
    a = ap.parse_args()
    p = plan('v10')
    total = sum(len(v) for v in p.values())
    print('v10: %d char members tile %d labelled slices' % (total, sum(len(x[3]) for v in p.values() for x in v)))
    for name, items in sorted(p.items()):
        for mname, off, n, pieces in items:
            print('  %-32s %-40s %4d B -> %d strings' % (name, mname, n, len(pieces)))
    bad = 0
    for tree in TREES:
        done = 0
        for name, items in sorted(p.items()):
            src = R.rule(tree, name)[0]
            text = open(src, 'rb').read().decode('latin-1')
            todo = [x for x in items if re.search(r'^    char %s\[%d\];' % (re.escape(x[0]), x[2]), text, re.M)]
            if not todo:
                continue
            before = R.compile_bin(tree, name)
            # every piece must be whole strings: it ends in NUL, or NUL + one 0xFF pad
            todo = [x for x in todo if all(before[so:so + sn].endswith((b'\x00', b'\x00\xff')) for _, so, sn in x[3])]
            if not todo:
                continue
            new = edit(text, before, todo)
            open(src, 'wb').write(new.encode('latin-1'))
            after = R.compile_bin(tree, name)
            if after != before or not a.apply:
                open(src, 'wb').write(text.encode('latin-1'))
            if after != before:
                print('  %s %s: DIFFERS, not applied' % (tree, name))
                bad += 1
                continue
            done += len(todo)
        print('%s: %d members split%s' % (tree, done, '' if a.apply else ' (dry run: compiled identical, not written)'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
