#!/usr/bin/env python3
"""Feedback plan step I2 / I5: where does the reference model differ from V4.23 on the firmware C, at listing level?

QUESTION ANSWERED: for every function of the firmware C files of the given trees, compare the model's listing
(model/codegen.compile_unit, exactly as the build calls it in scripts/build/cc900_firmware_c.compile_c) with V4.23's
listing of the same file (the build's cache, build/cc900-v423), after normalising both (comments and blank lines
dropped, blanks collapsed, upper case, local labels renumbered in order of appearance).  Each function is graded:
  same        identical
  regs-only   identical once every register name is replaced by one placeholder: the model chose other registers
  same-count  same number of instructions and the same mnemonics, other operand differences
  other       anything else
  model-none  the model writes no listing for it (refusal or front-end failure)
and counted over all functions and over the ones the build makes from C (built, V4.23 MATCH).  Prints Markdown with
counts only (no listing lines: V4.23's are Toshiba's output); --tsv OUT writes the per-function grades (names and
grades only).

Usage, from technics-roms-disasm's root (needs the build's V4.23 cache, filled by `make`):
    python3 -B notes/cc900-feedback-plan-2026-11-22/i2/m1_model_vs_v423.py [--tsv OUT] [TREE ...]   (default: v10)
"""
import collections
import glob
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')
sys.path.insert(0, CC)
import c_build_coverage as cbc  # noqa: E402  (puts model/ and scripts/build on sys.path)
import cc900_firmware_c as fw  # noqa: E402
import cc900_v423  # noqa: E402

TREES = {'v10': 'v10/maincpu', 'v9': 'v9/maincpu', 'v7': 'v7/maincpu', 'v6': 'v6/maincpu', 'v5': 'v5/maincpu',
         'v142': 'v142/subcpu', 'v141': 'v141/subcpu', 'v140': 'v140/subcpu', 'hdae5000': 'hdae5000'}
REG = re.compile(r'\b(?:X(?:WA|BC|DE|HL|IX|IY|IZ|SP)|Q?(?:WA|BC|DE|HL|IX|IY|IZ|SP)|Q?I[XYZ][HL]|Q?SP[HL]|'
                 r'Q?[WABCDEHL])\b')
LABEL = re.compile(r'\b(L\d+|\$\$\w+|_?\.L\w+)\b')


def norm(lines):
    out, labels = [], {}
    for l in lines:
        l = l.split(';', 1)[0].strip()
        if not l:
            continue
        l = re.sub(r'\s+', ' ', l).upper()
        l = LABEL.sub(lambda m: labels.setdefault(m.group(1).upper(), 'L%d' % len(labels)), l)
        out.append(l)
    return out


def grade(m, v):
    if m == v:
        return 'same'
    mr, vr = [REG.sub('R', x) for x in m], [REG.sub('R', x) for x in v]
    if mr == vr:
        return 'regs-only'
    if len(m) == len(v) and [x.split(' ')[0] for x in m] == [x.split(' ')[0] for x in v]:
        return 'same-count'
    return 'other'


def model_listing(path):
    import frontend
    import codegen
    _, opt, adecl = fw.file_options(path)
    for flag in fw.FIRMWARE_RULES:
        if hasattr(codegen, flag):
            setattr(codegen, flag, True)
    unit = frontend.load(path, ["__near=", "__tiny="], [], adecl=adecl)
    return codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=fw.OPTIONS["personality"])


def main():
    a = sys.argv[1:]
    tsv = None
    if '--tsv' in a:
        i = a.index('--tsv')
        tsv, a = a[i + 1], a[:i] + a[i + 2:]
    trees = a or ['v10']
    cache = os.path.join(REPO, 'build', 'cc900-v423')
    count = collections.Counter()
    reasons = collections.Counter()
    rows = []
    for t in trees:
        tree = TREES[t]
        built = cbc.tree_includes(tree)
        for path in sorted(glob.glob(os.path.join(REPO, tree, 'cc900', '*.c'))):
            st, lp, _ = cc900_v423.listing(cache, path)
            if st != 'OK':
                continue
            vf = cbc.listing_functions(lp)
            why = ''
            try:
                mf = model_listing(path)
            except (Exception, SystemExit) as ex:
                mf, why = {}, 'file: %s %s' % (type(ex).__name__, str(ex).split('\n')[0][:90])
            labels = fw.label_map(path)
            for name, vl in vf.items():
                bare = labels.get(name.lstrip('_.'), name.lstrip('_.'))
                ml = mf.get(name)
                if not ml or ml[0].startswith('; unsupported'):
                    g = 'model-none'
                    reasons[why or (ml[0][2:92] if ml else 'no function in the model output')] += 1
                else:
                    g = grade(norm(ml), norm(vl))
                b = bare in built
                count[('all', g)] += 1
                if b:
                    count[('built', g)] += 1
                rows.append((t, os.path.relpath(path, REPO), bare, int(b), g))
    grades = ['same', 'regs-only', 'same-count', 'other', 'model-none']
    print('## Model against V4.23, listing level (%s)\n' % ', '.join(trees))
    head = ('functions', 'total') + tuple(grades)
    body = []
    for scope in ('all', 'built'):
        tot = sum(count[(scope, g)] for g in grades)
        body.append((scope, tot) + tuple('%d (%.1f %%)' % (count[(scope, g)], 100.0 * count[(scope, g)] / tot)
                                         if tot else '0' for g in grades))
    w = [max(len(str(x)) for x in c) for c in zip(head, *body)]
    print('| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |')
    print('|' + '|'.join('-' * (n + 2) for n in w) + '|')
    for r in body:
        print('| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |')
    print('\nmodel-none, by reason (first 90 characters of the model\'s message; file = the whole file failed):\n')
    for k, v in reasons.most_common(25):
        print('- %d: %s' % (v, k.replace('|', '/')))
    if tsv:
        with open(tsv, 'w') as f:
            f.write('tree\tfile\tfunction\tbuilt\tgrade\n')
            for r in rows:
                f.write('\t'.join(str(x) for x in r) + '\n')


if __name__ == '__main__':
    main()
