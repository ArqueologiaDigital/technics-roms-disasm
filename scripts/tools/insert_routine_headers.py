#!/usr/bin/env python3
"""insert_routine_headers.py -- put hand-written routine header comments above their labels, safely.

QUESTION IT ANSWERS / JOB IT DOES
  WP16 (KN5000 routine headers) writes headers for hundreds of routines at a time.  Inserting them by hand
  in files of 30,000 lines is slow and error-prone (and the Edit tool is discouraged on these files); this
  inserts a batch from a plain-text file and refuses anything that would break a project rule:

    * the label must be defined exactly once (column 0, `Name:`) among the files under --path;
    * the routine must not already have a header (an informative comment block directly above it, the
      definition of doc_quality_census.py) -- an existing header is never overwritten or extended;
    * every line must be a `;` comment; no ROM address (0xe00000-0xffffff, it moves between builds and
      propagate_v10_headers.py refuses it), no upper-case hex digit in a 0x number (CLAUDE.md lowercase-hex
      rule), no `; e0018e`-style bare address, ASCII only, and the first line must not merely restate the label.

  The header goes directly above the label (after a blank line or an uninformative separator that is
  already there).  Files are read and written as bytes (CLAUDE.md: `.ascii` lines hold non-UTF-8 bytes).

INPUT FORMAT (one file, any number of blocks)
  @@ RoutineName
  ; Purpose line.
  ;   In:  ...
  ;   Out: ...

USAGE
  python3 scripts/tools/insert_routine_headers.py HEADERS.txt --path v10/maincpu/sequencer/ [--dry-run]
  Exit status 1 when any block was refused (the others are still written unless --dry-run).
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import doc_quality_census as dqc  # noqa: E402

ROM_ADDR = re.compile(r'0x0*([ef][0-9a-f]{5})\b', re.I)
UPPER_HEX = re.compile(r'0x[0-9a-fA-F]*[A-F][0-9a-fA-F]*\b')
BARE_ADDR = re.compile(r'^;\s*[0-9a-fA-F]{6}\s*$')


def parse(path):
    blocks, cur = [], None
    for ln in open(path, encoding='utf-8').read().split('\n'):
        if ln.startswith('@@'):
            cur = [ln[2:].strip(), []]
            blocks.append(cur)
        elif cur is not None and ln.strip():
            cur[1].append(ln.rstrip())
    return blocks


def problems(name, lines):
    out = []
    if not lines:
        out.append('empty header')
    for ln in lines:
        if not ln.startswith(';'):
            out.append('not a comment: %r' % ln)
        m = ROM_ADDR.search(ln)
        if m and int(m.group(1), 16) >= 0xe00000:
            out.append('quotes a ROM address: %s' % m.group(0))
        if UPPER_HEX.search(ln):
            out.append('upper-case hex: %s' % UPPER_HEX.search(ln).group(0))
        if BARE_ADDR.match(ln):
            out.append('bare address line')
        if any(ord(ch) > 126 for ch in ln):
            out.append('non-ASCII character')
    if lines and not dqc.informative(lines[0], {name.lower()}):
        out.append('first line is not informative')
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('headers')
    ap.add_argument('--path', required=True)
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()

    files = subprocess.run(['git', 'ls-files', '--', a.path], capture_output=True, text=True, cwd=ROOT,
                           check=True).stdout.split()
    files = [f for f in files if f.endswith('.s')]
    text = {f: open(os.path.join(ROOT, f), 'rb').read().decode('latin-1').split('\n') for f in files}
    where = {}
    for f, L in text.items():
        for i, ln in enumerate(L):
            m = re.match(r'^([A-Za-z_.$][\w.$]*):', ln)
            if m:
                where.setdefault(m.group(1), []).append((f, i))

    refused, inserts = 0, {}
    for name, lines in parse(a.headers):
        why = problems(name, lines)
        locs = where.get(name, [])
        if len(locs) != 1:
            why.append('label defined %d times under %s' % (len(locs), a.path))
        else:
            f, i = locs[0]
            if any(dqc.informative(h, {name.lower()}) for h in dqc.header_lines_above(text[f], i)):
                why.append('already has a header')
            if (f, i) in inserts:
                why.append('two blocks for one label')
        if why:
            refused += 1
            print('REFUSED %s: %s' % (name, '; '.join(why)))
            continue
        inserts[locs[0]] = lines

    by_file = {}
    for (f, i), lines in inserts.items():
        by_file.setdefault(f, []).append((i, lines))
    for f, items in sorted(by_file.items()):
        L = text[f]
        for i, lines in sorted(items, reverse=True):
            L[i:i] = lines
        if not a.dry_run:
            with open(os.path.join(ROOT, f), 'wb') as fh:
                fh.write('\n'.join(L).encode('latin-1'))
        print('%s: %d header(s)%s' % (f, len(items), ' (dry run)' if a.dry_run else ''))
    print('inserted %d, refused %d' % (len(inserts), refused))
    return 1 if refused else 0


if __name__ == '__main__':
    sys.exit(main())
