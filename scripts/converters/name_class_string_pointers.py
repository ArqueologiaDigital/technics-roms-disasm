#!/usr/bin/env python3
r"""name_class_string_pointers.py -- the class-name / propdata string pointers of the NAKA class
descriptors, as labels.

QUESTION ANSWERED
-----------------
"Which string does `.name = 0x00EAD8C6` in a Class descriptor point at?"  Every Class record has a
`name` (+12) and a `propdata` (+16) pointer; most of them point into the string pools of OTHER C
blobs (naka_widget_names_charmap.bin, naka_sound_menu_drawbar.bin, ...).  Those pools are already
sliced, one asm `.incbin "includes/generated/<bin>.bin", off, size` line per string, each under a
`[nakarest]` comment that says whose string it is ("class-name strings ... : VwUserBitmap",
"propdata strings ... : PsTextBox "c^dB""), but the slices had no label.  For every numeric ROM
literal of a ui_widgets C file that lands exactly on such a slice, this:

  * puts a label on the slice line, `ClassName_<Class>:` or `ClassPropdata_<Class>:`;
  * spells the literal NAKA_ADDR(<label>), declares `extern const char <label>;` and defines the
    label in the file's link script with the literal's own value (so the compiled blob is the same
    in every tree; v7/v6/v5 then patch it as before).

Matching is by (bin, offset) = (the slice's .incbin, literal - the target C file's BASE), so each
tree's own asm is labelled at its own slice.

RUN (repository root)
    python3 scripts/converters/name_class_string_pointers.py --tree v10 [--apply]
"""
import argparse
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import naka_gui_model as G               # noqa: E402
import naka_gui_symbolize as S           # noqa: E402

LIT = re.compile(r'(?<![\w.])0x00([EeFf][0-9A-Fa-f]{5})\b')
SLICE = re.compile(r'^(\s*)\.incbin "includes/generated/(\w+)\.bin", (0x[0-9A-Fa-f]+|\d+), (0x[0-9A-Fa-f]+|\d+)\s*$')


def compile_with(cpath, ld, text, extra):
    import tempfile
    fd, tmp = tempfile.mkstemp(suffix='.ld', dir=os.environ.get('TMPDIR'))
    os.close(fd)
    try:
        open(tmp, 'w').write(G.read(ld) + '\n' + ''.join('%s = 0x%08X;\n' % kv for kv in sorted(extra.items())))
        return S.compile_c(cpath, tmp, text)
    finally:
        os.remove(tmp)


def bin_bases(tree):
    """bin name -> BASE of the C file that compiles it (the v10 address the C is written for)."""
    mk = G.read(os.path.join(ROOT, 'Makefile'))
    out = {}
    for p in G.tree_files(tree):
        t = G.read(p)
        mb = re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', t, re.M)
        b, ld = S.bin_rule(tree, p)
        if mb and b:
            out[os.path.basename(b)[:-4]] = (int(mb.group(1), 16), p, ld)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--apply', action='store_true')
    a = ap.parse_args()
    bases = bin_bases(a.tree)
    # every unlabelled slice: (bin, offset) -> (file, line index, label name)
    slices, labelled = {}, {}
    asm = {}
    for p in sorted(glob.glob(os.path.join(ROOT, a.tree, 'maincpu', '**', '*.s'), recursive=True)):
        L = G.read(p).split('\n')
        asm[p] = L
        for i, ln in enumerate(L):
            lab = None
            body = ln
            mm = re.match(r'^([A-Za-z_]\w*):(.*)$', ln)
            if mm:
                lab, body = mm.group(1), mm.group(2)
            sm = SLICE.match(body)
            if not sm:
                continue
            key = (sm.group(2), int(sm.group(3), 0))
            if lab:
                labelled[key] = lab
                continue
            note = ' '.join(L[k] for k in range(max(0, i - 4), i))
            cm = re.search(r'(class-name|propdata) strings .*?\): (\w+)', note.replace('\n', ' ').replace('; [nakarest] ', ''))
            if cm:
                kind = 'ClassName_' if cm.group(1) == 'class-name' else 'ClassPropdata_'
                slices[key] = (p, i, kind + cm.group(2))
    used_names = set(labelled.values())
    files_txt, ld_add, asm_lab = {}, {}, {}
    n = 0
    unresolved = 0
    for p in G.tree_files(a.tree):
        t = G.read(p)
        code_spans = []
        # replace literals outside comments only
        out, pos = [], 0
        changed = False
        for cm in re.finditer(r'/\*.*?\*/|"(?:[^"\\\n]|\\.)*"', t, re.S):
            code_spans.append((pos, cm.start()))
            pos = cm.end()
        code_spans.append((pos, len(t)))
        new = []
        last = 0
        for s0, s1 in code_spans:
            seg = t[s0:s1]

            def rep(mm):
                nonlocal changed, n, unresolved
                v = int(mm.group(1), 16)
                for bn, (base, cp, ld) in bases.items():
                    key = (bn, v - base)
                    if key in labelled:
                        lab = labelled[key]
                    elif key in slices:
                        lab = slices[key][2]
                        if lab in used_names and asm_lab.get(key) != lab:
                            lab = '%s_%X' % (lab, v)
                        asm_lab[key] = lab
                        used_names.add(lab)
                    else:
                        continue
                    ld_add.setdefault(p, {})[lab] = v
                    changed = True
                    n += 1
                    return 'NAKA_ADDR(%s)' % lab
                unresolved += 1
                return mm.group(0)
            new.append(t[last:s0])
            new.append(LIT.sub(rep, seg))
            last = s1
        new.append(t[last:])
        if changed:
            files_txt[p] = ''.join(new)
    # write
    for p, txt in files_txt.items():
        labs = sorted(ld_add[p])
        ext = ''.join('extern const char %s;\n' % l for l in labs if 'extern const char %s;' % l not in txt)
        mm = re.search(r'^(/\* ── External symbols.*?\n\n)((?:extern const char \w+;\n)*)', txt, re.M | re.S)
        if mm:
            txt = txt[:mm.end()] + ext + txt[mm.end():]
        else:
            txt = txt.replace('#include "naka_types.h"\n', '#include "naka_types.h"\n\n' + ext, 1)
        b, ld = S.bin_rule(a.tree, p)
        same = compile_with(p, ld, txt, {l: ld_add[p][l] for l in labs}) == S.compile_c(p, ld, G.read(p))
        print('%-32s %3d pointers named  %s' % (os.path.basename(p), sum(1 for _ in labs), 'IDENTICAL' if same else 'DIFFERS'))
        if not same:
            return 1
        if a.apply:
            open(p, 'wb').write(txt.encode('utf-8', 'surrogateescape'))
            ldt = G.read(ld)
            add = ''.join('%s = 0x%08X;\n' % (l, ld_add[p][l]) for l in labs if not re.search(r'^%s = ' % l, ldt, re.M))
            open(ld, 'wb').write((ldt.rstrip('\n') + '\n' + add).encode('utf-8', 'surrogateescape'))
    if a.apply:
        for key, lab in asm_lab.items():
            p, i, _ = slices[key]
            L = asm[p]
            L[i] = '%s:\t%s' % (lab, L[i].lstrip())
        for p in {slices[k][0] for k in asm_lab}:
            open(p, 'wb').write('\n'.join(asm[p]).encode('utf-8', 'surrogateescape'))
    print('%s: %d pointers named, %d new labels; %d ROM literals left' % (a.tree, n, len(asm_lab), unresolved))
    return 0


if __name__ == '__main__':
    sys.exit(main())
