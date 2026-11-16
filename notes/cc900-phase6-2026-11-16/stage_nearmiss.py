#!/usr/bin/env python3
"""Stage functions that lane_nmx's re-check found matching (branch cc900/nearmiss, notes/cc900-c-nearmiss/ready.tsv).

QUESTION ANSWERED / WHY: lane_nmx re-checks earlier V4.23 listings with main's translator, without the VM, and lists
the attempts that now give the ROM's bytes, each with the exact C (a copy, c/<tree>/<function>__<hash>.c) and the
cc900-module line it needs.  For the named v10 functions this copies the C into the probe corpus as
p6_nm_<hash>.c (with the module line added), records the match in probe_matches.tsv and writes a probe_v423-style
TSV for stage_matches.py, which stages them as usual (then restage_modules.py, add_module_lines.py, port_staged.py
and a V4.23 staged recheck).

usage: python3 -B notes/cc900-phase6-2026-11-16/stage_nearmiss.py OUT.tsv FUNCTION [FUNCTION ...]
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
PROBES = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
BRANCH = 'cc900/nearmiss'
NMX = 'notes/cc900-c-nearmiss/'


def show(path):
    """the file's bytes, read as latin-1 (the C copies hold raw bytes; latin-1 keeps every byte as it is)"""
    return subprocess.run(['git', 'show', '%s:%s' % (BRANCH, path)], capture_output=True,
                          cwd=REPO, check=True).stdout.decode('latin-1')


def main():
    out, want = sys.argv[1], set(sys.argv[2:])
    rows = [l.rstrip('\n').split('\t') for l in show(NMX + 'ready.tsv').split('\n') if l.strip()]
    head = rows[0]
    col = {n: i for i, n in enumerate(head)}
    picked = []
    for r in rows[1:]:
        if len(r) < len(head) or r[col['lane']] != 'lane_p6' or r[col['tree']] != 'v10' or r[col['function']] not in want:
            continue
        c = r[col['c_copy']]
        stem = 'p6_nm_' + os.path.basename(c)[:-2]          # one copy per function (same hash, other text)
        dst = os.path.join(PROBES, stem + '.c')
        text = show(NMX + c)
        mod = r[col['cc900_module']].strip()
        if mod and 'cc900-module:' not in text:
            i = text.index('*/\n') + 3 if '*/\n' in text else 0
            text = text[:i] + '/* cc900-module: %s */   /* lane_nmx ready.tsv */\n' % mod + text[i:]
        if os.path.exists(dst):
            if open(dst, encoding='latin-1', newline='').read() != text:     # (CR LF kept as written)
                sys.exit('%s exists with other text' % dst)
        else:
            open(dst, 'w', encoding='latin-1', newline='').write(text)
        picked.append((r[col['function']], r[col['bytes']], r[col['run']], '%s@%s' % (stem, r[col['opt']])))
    with open(out, 'w') as fh:
        fh.write('function\tbytes\tmatches\tbest_diff\n')
        for f, b, run, m in picked:
            fh.write('%s\t%s\t%s\t-\n' % (f, b, m))
    with open(os.path.join(HERE, 'probe_matches.tsv'), 'a') as fh:
        for f, b, run, m in picked:
            fh.write('%s\t%s\t%s (lane_nmx re-check)\t%s\n' % (f, b, run, m))
    print('%d functions: %s' % (len(picked), ' '.join(sorted(p[0] for p in picked))))
    missing = want - {p[0] for p in picked}
    if missing:
        print('not in ready.tsv (lane_p6, v10): %s' % ' '.join(sorted(missing)))


if __name__ == '__main__':
    main()
