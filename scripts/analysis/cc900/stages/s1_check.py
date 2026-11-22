#!/usr/bin/env python3
"""Check stage S1 against V4.23: for every kept thc1 file of job_i2.sh runs that also hold thc2's `-zio` dump of it,
compare s1.py's text with thc2's, function by function.

QUESTION ANSWERED: for how many functions does our S1 equal thc2's state after its machine-independent stage, per
option set; and, for the others, which kind of line differs first (the operation of thc2's line, our line's), as a
worklist.  Prints counts only (the dumps are Toshiba's output).

    python3 -B scripts/analysis/cc900/stages/s1_check.py [--labels Xr,...] [--show N] RUN_DIR [RUN_DIR ...]

--show N prints the first N differing functions' paths and names (no dump lines), to open privately.
"""
import collections
import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import s0  # noqa: E402
import s1  # noqa: E402


def zio_functions(path):
    """thc2's -zio dump: [list of lines per function], as s1.s1_text writes them"""
    out, cur = [], None
    for raw in open(path, 'rb').read().decode('latin-1').split('\n'):
        l = raw.rstrip('\r')
        if not l.startswith(';'):
            continue
        l = l[1:]
        if l.endswith('|FUNC_START'):
            cur = [l]
        elif cur is not None:
            cur.append(l)
            if l.endswith('|FUNC_END'):
                out.append(cur)
                cur = None
    return out


def kind(line):
    if line is None:
        return '(missing)'
    t = line.split('|', 1)[-1]
    m = re.search(r'\b(CCALL|CCALP|ACALL|ACALP|CARG|AARG|ADDR|ADD|DUMMY|PIN|LDIR|CONV|SWITCH|JMP|LAB|END|BEGIN|'
                  r'B[GLEN][TEQ]|\+\+|--|[-+*/%&|^]=?|<<=?|>>=?|=)', t)
    return m.group(1) if m else t.split(' ')[0][:12]


def main():
    a = sys.argv[1:]
    labels, show = None, 0
    if '--labels' in a:
        i = a.index('--labels'); labels = set(a[i + 1].split(',')); a = a[:i] + a[i + 2:]
    if '--show' in a:
        i = a.index('--show'); show = int(a[i + 1]); a = a[:i] + a[i + 2:]
    count = collections.Counter()
    first = collections.Counter()
    shown = 0
    for r in a:
        for inter in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*.inter'), recursive=True)):
            label = os.path.relpath(inter, os.path.join(r, 'out')).split(os.sep)[1]
            if labels and label not in labels:
                continue
            z = inter[:-len('.inter')] + '_zio.asm'
            if not os.path.exists(z):
                continue
            theirs = zio_functions(z)
            u = s0.load(inter)
            st = s1.symtypes(u)
            if len(theirs) != len(u.functions):
                count[(label, 'count mismatch')] += len(u.functions)
                continue
            for f, t in zip(u.functions, theirs):
                try:
                    ours = s1.s1_text(s1.Fn(f, st))
                except Exception as ex:                      # our stage fails: counted, never hidden
                    count[(label, 'error')] += 1
                    first[('error', type(ex).__name__)] += 1
                    continue
                count[(label, 'functions')] += 1
                if ours == t:
                    count[(label, 'exact')] += 1
                    continue
                k = next(i for i in range(max(len(ours), len(t)))
                         if i >= len(ours) or i >= len(t) or ours[i] != t[i])
                first[(kind(t[k] if k < len(t) else None), kind(ours[k] if k < len(ours) else None))] += 1
                if shown < show:
                    shown += 1
                    print('differs: %s %s (line %d)' % (inter, f.name, k))
    print('| option set | functions | exact | errors | count mismatch |')
    print('|------------|-----------|-------|--------|----------------|')
    for lab in sorted({k[0] for k in count}):
        print('| %-10s | %9d | %5d | %6d | %14d |' % (lab, count[(lab, 'functions')], count[(lab, 'exact')],
                                                     count[(lab, 'error')], count[(lab, 'count mismatch')]))
    print('\nfirst difference (thc2 line kind, our line kind): count')
    for k, v in first.most_common(25):
        print('  %-40s %d' % ('%s / %s' % k, v))


if __name__ == '__main__':
    main()
