#!/usr/bin/env python3
"""thc2 listings of job_i2.sh's `zimg` option set (-zim -g) split per function into the three things stage S4 uses:
the -zim dump (S3's input / S4's input), the -g storage records, and the code lines (S4's target).

QUESTION ANSWERED: per function, the code thc2 wrote, normalised for comparison (comments and debug records
dropped, blanks collapsed, labels kept), next to its dump.

    python3 -B scripts/analysis/cc900/stages/listing2.py --stats LISTING ...      (counts only)
"""
import re
import sys


def functions(path):
    """[(dump lines, code lines)] in file order; code = the function's instructions and labels, normalised"""
    text = open(path, 'rb').read().decode('latin-1').replace('\r', '')
    out = []
    parts = text.split(';<intermediate-code output>')
    for p in parts[1:]:
        dump, code = [], []
        for l in p.split('\n'):
            if l.startswith(';'):
                if '|' in l:
                    dump.append(l[1:])
                continue
            if not l.strip():
                continue
            s = l.split(';', 1)[0].rstrip()
            if not s:
                continue
            if s.startswith('\t'):
                body = s.strip()
                if re.match(r'^(symbol_\w+|line|file|public|extern|section|align|module|end|\$\w+)\b', body):
                    continue
                code.append(re.sub(r'\s+', ' ', body.replace('\t', ' ', 1)))
            elif re.match(r'^L\d+:', s):
                code.append(s.split()[0])
        out.append((dump, code))
    return out


def stats(paths):
    import collections
    c = collections.Counter()
    for p in paths:
        for d, code in functions(p):
            c['functions'] += 1
            c['code lines'] += len(code)
    print(' '.join('%s %d' % kv for kv in sorted(c.items())))


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--stats':
        stats(sys.argv[2:])
    else:
        sys.exit(__doc__)
