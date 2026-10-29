#!/usr/bin/env python3
r"""retype_prop_type_records.py -- SupportClass_PropTypeRecords as one typed array in naka_style_bitmaps.c.

QUESTION ANSWERED
-----------------
"What are the 55 x 12 bytes in naka_style_bitmaps.c that the C spelled as `xxxProc_ptr`,
`field_04d8`, `ptr_04e6` ...?"  They are SupportClass_PropTypeRecords, the property-type table
InitializeObjectTable registers at registry slot 0x260 (`ldw (xbc + 8), 0x37`, ui/ui_widget_defs.s):
one 12-byte record per propdata letter 'A'..'w' (ClassProc: `sub a, 0x41; add xwa, 0x2600000`):
    +0 proc    the property-type procedure (swordProc .. IntTimeIDProc)
    +4 count   named values (CommonIDProc walks that many {name, value} pairs)
    +6 size    the property's byte size (SupportClassProc_OnGetPropSize: `ld hl, (xhl + 6)`)
    +8 values  -> the {name, value} pairs, or the type's name when count is 0
This replaces the members of letters A..s with `naka_prop_type_t SupportClass_PropTypeRecords[51]`
(naka_types.h), one row per letter, keeping every symbolic initializer; the blob is unchanged.

RUN (repository root)
    python3 scripts/converters/retype_prop_type_records.py --tree v10 [--apply]
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import nakarest_c_model as CM            # noqa: E402
import naka_gui_model as G               # noqa: E402
import naka_gui_symbolize as S           # noqa: E402

N = 51      # letters A..s; t (WindowID) splits its value pointer at a labelled byte and u..w are
            # SupportClass_PartTrackIntTimeRecords, typed on their own


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    a = ap.parse_args()
    p = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_style_bitmaps.c')
    CM.register_local_types(G.read(os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'naka_classes.h')))
    txt = G.read(p)
    if 'SupportClass_PropTypeRecords[%d]' % N in txt:
        print('already typed')
        return
    b = CM.CBlob(p)
    start = next(i for i, mb in enumerate(b.members) if mb.name == 'swordProc_ptr')
    base = b.members[start].offset
    data = open(S.bin_rule('v10', p.replace('/%s/' % a.tree, '/v10/'))[0], 'rb').read()
    init = {}
    for m in re.finditer(r'^    \.(\w+) = (.*?),$', txt, re.M):
        init[m.group(1)] = m.group(2)
    by_off = {mb.offset: mb for mb in b.members}
    end = base + 12 * N
    covered = [mb for mb in b.members if base <= mb.offset < end]
    if sum(mb.size for mb in covered) != 12 * N or covered[-1].offset + covered[-1].size != end:
        sys.exit('member boundaries do not match 55 x 12 bytes')
    rows = []
    for i in range(N):
        o = base + 12 * i
        proc = by_off.get(o)
        val = by_off.get(o + 8)
        if not proc or proc.size != 4 or not val or val.size != 4:
            sys.exit('record %d: no 4-byte member at +0 / +8' % i)
        cnt = int.from_bytes(data[o + 4:o + 6], 'little')
        siz = int.from_bytes(data[o + 6:o + 8], 'little')
        for mb in covered:
            if o + 4 <= mb.offset < o + 8 and not re.match(r'^(0x[0-9A-Fa-f]+|\d+|\{[ 0x,]*\})$', init.get(mb.name, '0').strip()):
                sys.exit('record %d: a symbolic count/size' % i)
        rows.append('        /* %s */ { %s, %d, %d, %s },' % (chr(0x41 + i), init[proc.name], cnt, siz, init[val.name]))
    names = {mb.name for mb in covered}
    # struct: replace the members' declaration lines (and their comments) with the array
    L = txt.split('\n')
    s0, s1 = b.s0, b.s1
    out, placed = [], False
    for i, ln in enumerate(L):
        if s0 < i < s1:
            mm = re.match(r'^\s+\w+ (\w+)(\[[^\]]*\])?;', ln)
            if mm and mm.group(1) in names:
                if not placed:
                    out.append('    /* SupportClass_PropTypeRecords: the property type of each propdata letter (retype_prop_type_records.py) */')
                    out.append('    naka_prop_type_t SupportClass_PropTypeRecords[%d];' % N)
                    placed = True
                continue
        out.append(ln)
    txt2 = '\n'.join(out)
    # initializer
    for nm in names:
        txt2, k = re.subn(r'\n(\n)?    \.%s = .*?,\n' % re.escape(nm), '\n' if False else '\n', txt2, count=1, flags=re.S)
        txt2 = txt2.replace('@@', '@@')
    first = b.members[start].name
    body = '    .SupportClass_PropTypeRecords = {\n' + '\n'.join(rows) + '\n    },\n'
    # insert where the first member's initializer was: find the member before it
    prev = b.members[start - 1].name
    m = re.search(r'^    \.%s = .*?,\n' % re.escape(prev), txt2, re.M | re.S)
    txt2 = txt2[:m.end()] + '\n' + body + txt2[m.end():]
    # SELF() into the replaced members would break: refuse
    for nm in names:
        if re.search(r'SELF\(%s\b' % re.escape(nm), txt2):
            sys.exit('SELF(%s) is used' % nm)
    b2, ld = S.bin_rule(a.tree, p)
    same = S.compile_c(p, ld, txt2) == S.compile_c(p, ld, txt)
    print('%s: %s' % (a.tree, 'IDENTICAL' if same else 'DIFFERS'))
    if same and a.apply:
        open(p, 'wb').write(txt2.encode('utf-8', 'surrogateescape'))


if __name__ == '__main__':
    main()
