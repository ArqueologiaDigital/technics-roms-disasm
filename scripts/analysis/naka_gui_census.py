#!/usr/bin/env python3
r"""naka_gui_census.py -- how readable is the KN5000 GUI data in the C sources?  (GUI-readability census)

QUESTION ANSWERED
-----------------
"Per main-CPU tree, how many places in the NAKA C sources (<tree>/maincpu/ui_widgets/*.c) still
spell GUI data as numbers where a name exists or is wanted?"  Counted outside comments and string
literals, over every widget record (scripts/analysis/naka_gui_model.py) and the rest of the code:

  class ids     a raw class id: `.class_ = 0x0160xxxx` in a record, or any other 0x016S_KKKK literal
                (class descriptors, tables) -- the name is NAKA_CLASS(<Class>)
  links         a super/sub/next/prev field spelled as a number (NAKA_NONE is a name)
  view ids      a view-object id field (letters t WindowID, N ScreenID) spelled as a number
  prop values   an enumerated property (colour, border, view flag, alignment, edit switch, style,
                line mode, frame, part, track, time, user, font, bitmap, icon) or a title / mode /
                function-object id field spelled as a number although a firmware name exists
  unnamed prop  the same fields whose number has no name at all (no firmware name to use)
  rom addrs     a 32-bit literal 0x00E00000..0x00FFFFFF (a ROM address spelled as a number)
  ram cells     a RAM-pointer field (letters m n o p q r s: pBool .. pUlong, the widget's live
                value cell) spelled as a number
  field_XX      a struct member still named only by its offset (field_XXXX, bytes_XXXX, ptr_XXXX)
  records       widget records typed by class (the population the per-field counts range over)

Before/after: `--rev <commit>` reads the files as they were at that commit (the field letters
always come from the current naka_classes.h: a letter is a property of the class, not of the
spelling).

RUN (repository root)
    python3 scripts/analysis/naka_gui_census.py                  # all five trees, working tree
    python3 scripts/analysis/naka_gui_census.py --rev 9dbc03088  # the same, at a commit
    python3 scripts/analysis/naka_gui_census.py --files v10      # per file
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import naka_gui_model as G              # noqa: E402

TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
NUM = re.compile(r'^-?(0x[0-9A-Fa-f]+|\d+)$')
NAMED_LETTERS = set('^_]defghluvwZcib') | set('a`jk')
RAM_LETTERS = set('mnopqrs')
VIEW_LETTERS = set('tN')
COLS = ['class ids', 'links', 'view ids', 'prop values', 'unnamed prop', 'rom addrs', 'ram cells',
        'field_XX', 'records']


def strip_comments_strings(t):
    t = re.sub(r'/\*.*?\*/', ' ', t, flags=re.S)
    t = re.sub(r'//[^\n]*', ' ', t)
    return re.sub(r'"(?:[^"\\\n]|\\.)*"', '""', t)


def name_tables():
    """letter -> set of values that have a firmware name (from the generated headers)."""
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
    txt = G.read(os.path.join(ROOT, 'v10', 'maincpu', 'ui_widgets', 'naka_classes.h'))
    out, cur = {}, None
    for ln in txt.split('\n'):
        m = re.match(r'^/\* letter (\S), ', ln)
        if m:
            cur = m.group(1)
            out[cur] = set()
            continue
        m = re.match(r'^#define \w+\s+(0x[0-9A-F]+)u', ln)
        if m and cur:
            out[cur].add(int(m.group(1), 16))
        if ln.startswith('/* One packed struct'):
            break
    ids = G.ids_values('v10')
    pre = {'a': ('TITLE_',), '`': ('NAKA_MODE_',), 'j': ('NAKA_APFUNC_', 'NAKA_FUNC_', 'NAKA_MAINFUNC_'),
           'k': ('NAKA_MAINFUNC_', 'NAKA_FUNC_', 'NAKA_APFUNC_')}
    for ch, ps in pre.items():
        out[ch] = {v for n, v in ids.items() if n.startswith(ps)}
    return out


def census_text(name, text, letters, named):
    c = dict.fromkeys(COLS, 0)
    f = G.CFile.__new__(G.CFile)
    f.path, f.name, f.text = name, name, text
    G.CFile.__init__(f, None) if False else None
    # parse records the same way CFile does, from text
    f.records, f.by_member = [], {}
    for m in G.ELEM.finditer(text):
        r = dict(member=m.group(6), cls=m.group(5), slot=int(m.group(2), 16), elem=int(m.group(1)),
                 resname=m.group(3) or '', fields={})
        f.records.append(r)
        f.by_member[r['member']] = r
    for m in G.BLOCK.finditer(text):
        r = f.by_member.get(m.group(1))
        if r is not None:
            r['fields'] = dict(G.FIELD.findall(m.group(0)))
    c['records'] = len(f.records)
    rec_class_lines = 0
    for r in f.records:
        lt = dict(letters.get(r['cls'], []))
        for fld, v in r['fields'].items():
            v = v.strip()
            letter = lt.get(fld)
            isnum = bool(NUM.match(v))
            if letter == 'M':
                if isnum:
                    c['class ids'] += 1
                    rec_class_lines += 1
            elif letter == '[':
                if isnum and int(v, 0) != 0xFFFF:
                    c['links'] += 1
            elif letter in VIEW_LETTERS:
                if isnum and int(v, 0) not in (0, 0xFFFFFFFF):
                    c['view ids'] += 1
            elif letter in NAMED_LETTERS:
                if isnum:
                    x = int(v, 0)
                    if letter == ']' or x in named.get(letter, ()) or (letter == 'l' and x == 0xFFFFFFFF):
                        c['prop values'] += 1
                    else:
                        c['unnamed prop'] += 1
            elif letter in RAM_LETTERS:
                if isnum and int(v, 0) not in (0, 0xFFFFFFFF):
                    c['ram cells'] += 1
    code = strip_comments_strings(text)
    allcls = len(re.findall(r'\b0x0?16[0-9A-Fa-f]{5}\b', code))
    c['class ids'] += max(0, allcls - rec_class_lines)
    c['rom addrs'] = len(re.findall(r'(?<![\w.])0x00[EeFf][0-9A-Fa-f]{5}\b', code))
    c['field_XX'] = len(re.findall(r'^\s+(?:u?int(?:8|16|32)_t|char|naka_\w+_t)\s+(?:field|bytes|ptr)_[0-9a-fA-F]{4}\b',
                                   code, re.M))
    return c


def files_of(tree, rev):
    d = '%s/maincpu/ui_widgets' % tree
    if rev:
        out = subprocess.run(['git', 'ls-tree', '--name-only', rev, d + '/'], cwd=ROOT,
                             capture_output=True, text=True).stdout.split()
        for p in sorted(out):
            if p.endswith('.c'):
                yield p, subprocess.run(['git', 'show', '%s:%s' % (rev, p)], cwd=ROOT,
                                        capture_output=True).stdout.decode('utf-8', 'surrogateescape')
    else:
        for p in G.tree_files(tree):
            yield os.path.relpath(p, ROOT), G.read(p)


def table(rows, head):
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    fmt = lambda r: '| ' + ' | '.join(str(x).ljust(w[i]) for i, x in enumerate(r)) + ' |'
    return '\n'.join([fmt(head), '|' + '|'.join('-' * (x + 2) for x in w) + '|'] + [fmt(r) for r in rows])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rev')
    ap.add_argument('--files', metavar='TREE')
    ap.add_argument('trees', nargs='*')
    a = ap.parse_args()
    letters = G.class_letters('v10')
    named = name_tables()
    rows = []
    for tree in ([a.files] if a.files else (a.trees or TREES)):
        tot = dict.fromkeys(COLS, 0)
        for p, text in files_of(tree, a.rev):
            c = census_text(p, text, letters, named)
            if a.files and (c['records'] or any(c[k] for k in COLS)):
                rows.append([os.path.basename(p)] + ['{:,}'.format(c[k]) for k in COLS])
            for k in COLS:
                tot[k] += c[k]
        rows.append([('total ' if a.files else '') + tree] + ['{:,}'.format(tot[k]) for k in COLS])
    print(table(rows, ['file' if a.files else 'tree'] + COLS))


if __name__ == '__main__':
    main()
