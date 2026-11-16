#!/usr/bin/env python3
"""Stage the functions of a probe file that V4.23 reproduced, as one C module of hdae5000/cc900-staged/.

QUESTION ANSWERED / WHY: a probe file (probes/hd_r*.c) holds one calr group's C, several functions of which match
and some not yet.  The staged file must hold only matching functions, with every declaration, macro and
cc900-name comment they need.  This copies the probe's text outside function bodies whole (declarations, macros,
structs; the C compiles exactly as in the run), drops the bodies of the functions not named, and writes a staging
header.  A function that matched with calr ("MATCH calr", hd_v423.py --calr) may be staged only with the callees
of its calr in the same file: the caller checks that itself, from the run.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/stage_from_probe.py PROBE.c OUT.c "WHAT" FUNC [FUNC ...]
        WHAT  one line for the header: the module and where its functions are in the hand source
        FUNC  C names (as defined in PROBE.c) to keep
Run from the repository root.  OUT.c is overwritten.
"""
import re, sys

DEF = re.compile(r'^[A-Za-z_][\w \t\*]*?\b(\w+)\s*\(([^;{]*)$')
DEF1 = re.compile(r'^[A-Za-z_][\w \t\*]*?\b(\w+)\s*\([^;{]*\)\s*\{.*\}\s*$')     # a one-line definition


def split(text):
    """[(kind, name, text)]: 'fn' for a function definition (its signature line to the closing brace at column 0),
    'other' for everything else"""
    lines = text.split('\n')
    out, i, cur = [], 0, []
    while i < len(lines):
        m1 = DEF1.match(lines[i])
        if m1 and not lines[i].startswith('extern'):
            if cur:
                out.append(('other', None, '\n'.join(cur)))
                cur = []
            out.append(('fn', m1.group(1), lines[i]))
            i += 1
            continue
        m = DEF.match(lines[i])
        if m and not lines[i].startswith('extern') and not lines[i].rstrip().endswith(';'):
            j = i
            while j < len(lines) and not lines[j].startswith('}'):
                j += 1
            if cur:
                out.append(('other', None, '\n'.join(cur)))
                cur = []
            out.append(('fn', m.group(1), '\n'.join(lines[i:j + 1])))
            i = j + 1
            continue
        cur.append(lines[i])
        i += 1
    if cur:
        out.append(('other', None, '\n'.join(cur)))
    return out


def main():
    a = sys.argv[1:]
    if len(a) < 4:
        sys.exit(__doc__)
    probe, out, what, keep = a[0], a[1], a[2], set(a[3:])
    text = open(probe, encoding='latin-1').read()
    parts = split(text)
    found = {n for k, n, _ in parts if k == 'fn'}
    missing = keep - found
    if missing:
        sys.exit('not defined in %s: %s' % (probe, ' '.join(sorted(missing))))
    # the probe's leading comment is replaced by the staging header; its cc900-name lines for kept names stay
    first = parts[0][2] if parts and parts[0][0] == 'other' else ''
    m = re.match(r'\s*/\*.*?\*/', first, re.S)
    lead = m.group(0) if m else ''
    names = [l.strip() for l in lead.split('\n') if 'cc900-name:' in l and
             l.split('cc900-name:')[1].split('=')[0].strip() in keep]
    opts = re.search(r'cc900-options:[^\n*]*', lead)
    head = ['/* %s' % what,
            '   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions\' ROM bytes',
            '   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from %s.' % probe.split('/')[-1],
            '   ' + (opts.group(0).strip() if opts else 'cc900-options: -Xr')] + ['   ' + n for n in names] + ['*/']
    body = []
    for k, n, t in parts:
        if k == 'fn':
            if n in keep:
                body.append(t)
        else:
            body.append(t.replace(lead, '', 1) if t is first else t)
    text = '\n'.join(head) + '\n' + re.sub(r'\n{3,}', '\n\n', '\n'.join(body)).strip('\n') + '\n'
    open(out, 'w', encoding='latin-1').write(text)
    print('%s: %d functions' % (out, len(keep)))


if __name__ == '__main__':
    main()
