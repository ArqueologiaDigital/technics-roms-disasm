#!/usr/bin/env python3
"""label_fdemo_markup_tag_handlers.py -- the feature-demo markup-tag handlers, as labels (one-off edit, applied
2026-11-02 by lane open6/kn5000-c; it refuses to run twice: the anchor lines must still be unlabelled).

QUESTION ANSWERED: which code do the nine numeric words of FDemoText_MarkupTag_HandlerColumn
(naka_technichord_strings.c, 0x00F85A28 ...) point at?  Each is the first instruction after a `ret` in
demo/fdemotext_routines.s (v10 lines below, found with scripts/analysis/address_line_map.py), the entry of
a compiled-C routine that FDemoText_ProcessMarkup calls for the tag whose name precedes it in the
{name, handler} records.  The routine gets `FDemoText_Tag_<TAG>:` and a header; v9 / v7 / v6 / v5 are
labelled at the line with the same text at the same distance from the same preceding label (and after a
`ret`).  The C words become NAKA_ADDR(FDemoText_Tag_<TAG>) with the word's own value in the link script.

RUN (repository root):  python3 scripts/converters/label_fdemo_markup_tag_handlers.py v10 v9 v7 v6 v5
"""
import re, sys
V10 = {1958: ('ACT', 0xF858D5), 2071: ('EndACT', 0xF85A1C), 2079: ('BR', 0xF85A28), 2086: ('CENTER', 0xF85A36),
       2103: ('EndCENTER', 0xF85A61), 2121: ('FONT', 0xF85A96), 2222: ('EndFONT', 0xF85BCC),
       2247: ('IMG', 0xF85C22), 2337: ('SHOW', 0xF85D0F)}
TAGTXT = {'ACT': '<ACT>', 'EndACT': '</ACT>', 'BR': '<BR>', 'CENTER': '<CENTER>', 'EndCENTER': '</CENTER>',
          'FONT': '<FONT>', 'EndFONT': '</FONT>', 'IMG': '<IMG>', 'SHOW': '<SHOW>'}
norm = lambda b: re.sub(rb'\s+', b' ', b.strip())
src = 'v10/maincpu/demo/fdemotext_routines.s'
L10 = open(src, 'rb').read().split(b'\n')
def anchor(L, i):
    j = i - 1
    while j >= 0 and not re.match(rb'^[A-Za-z_]\w*:', L[j]):
        j -= 1
    return re.match(rb'^([A-Za-z_]\w*):', L[j]).group(1), i - j
anchors = {ln: anchor(L10, ln - 1) for ln in V10}
for t in sys.argv[1:]:
    p = '%s/maincpu/demo/fdemotext_routines.s' % t
    L = open(p, 'rb').read().split(b'\n')
    labs = {re.match(rb'^([A-Za-z_]\w*):', l).group(1): k for k, l in enumerate(L) if re.match(rb'^[A-Za-z_]\w*:', l)}
    ins = []
    for ln, (tag, addr) in V10.items():
        a, d = anchors[ln]
        k = labs[a] + d
        assert norm(L[k]) == norm(L10[ln - 1]) and norm(L[k - 1]) == b'ret', (t, tag, L[k], L[k - 1])
        ins.append((k, tag))
    for k, tag in sorted(ins, reverse=True):
        hdr = [b'; ' + ('FDemoText_Tag_%s -- the handler of the feature-demo markup tag %s: FDemoText_ProcessMarkup '
                        'calls it through' % (tag, TAGTXT[tag])).encode(),
               b'; FDemoText_MarkupTag_HandlerColumn (the {tag name, handler} records of FDemoText_MarkupTagTable).',
               ('FDemoText_Tag_%s:' % tag).encode()]
        L[k:k] = hdr
    open(p, 'wb').write(b'\n'.join(L))
    c = '%s/maincpu/ui_widgets/naka_technichord_strings.c' % t
    s = open(c, 'rb').read().decode('latin-1')
    names = []
    for ln, (tag, addr) in V10.items():
        lit = '        0x%08X,\n' % addr
        assert s.count(lit) == 1, (t, tag)
        s = s.replace(lit, '        NAKA_ADDR(FDemoText_Tag_%s),\n' % tag)
        names.append(('FDemoText_Tag_%s' % tag, addr))
    last = list(re.finditer(r'^extern const char \w+;\n', s, re.M))[-1]
    s = s[:last.end()] + ''.join('extern const char %s;\n' % n for n, _ in sorted(names)) + s[last.end():]
    open(c, 'wb').write(s.encode('latin-1'))
    ld = '%s/maincpu/ui_widgets/naka_technichord_strings_link.ld' % t
    lt = open(ld, 'rb').read().decode('latin-1').rstrip('\n') + '\n'
    lt += ''.join('%s = 0x%08X;\n' % (n, a) for n, a in sorted(names))
    open(ld, 'wb').write(lt.encode('latin-1'))
    print(t, 'labelled', len(ins))
