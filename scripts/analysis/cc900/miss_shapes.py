#!/usr/bin/env python3
"""Classify the cc900 model's misses on an oracle directory by the shape of the first differing line.

usage: python3 -I -B miss_shapes.py ORACLE_DIR FILE.c [FILE.c ...] [--opt none|O3XS] [--adecl] [--examples N]
                                    [--personality P] [-DNAME[=V] ...] [-IDIR ...]
The arguments are score.py's.  Every function that score.py would count as not exact is put in one class, read
from the model's output and from the first line where the two listings differ (local labels normalised as score.py
does):
- unsupported: <reason>      the model raised Unsupported (its first line is `; unsupported: ...`);
- front end                  clang or the front end rejected the file (the whole file counts);
- register choice            same mnemonic, operands equal once register names are replaced by one token;
- operand order              same mnemonic, the same operands in another order;
- frame                      the first difference is in the frame: link / unlk / push / pop / retd, an XSP+ offset,
                             or a save of IZ / XIZ;
- control flow               the first difference is a branch, call, return, label or compare feeding a branch;
- helper call                one side calls a C9H_* / ._f* runtime helper where the other does not;
- instruction choice         different mnemonics (inc vs add, exts vs ld, ldirw ...);
- operand form               same mnemonic, operands differ beyond register names (addressing mode, constant);
- length                     the listings agree to the end of the shorter one.
Prints a count per class, then --examples N function names per class with the differing line index (the oracle's
text stays in the terminal: it is Toshiba's output and is never copied into the repository).
"""
import collections, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'model'))
import frontend, listing, codegen, score

REG = re.compile(r'\b(?:Q?X?(?:WA|BC|DE|HL|IX|IY|IZ|SP)|Q?[WABCDEHL])\b')
FRAME = re.compile(r'\b(link|unlk|retd|push|pop)\b|XSP\+|XSP-|\bXIZ\b|\bIZ\b')
FLOW = re.compile(r'^\t(j|jr|cal|calr|ret|cp|cpw|cpb|djnz)\b|^[LS]\d+:')
HELPER = re.compile(r'\b(C9H_\w+|\._f\w+)\b')


def split(line):
    p = line.lstrip('\t').split('\t', 1)
    return p[0], (p[1] if len(p) > 1 else '')


def classify(W, G):
    if G and G[0].startswith('; unsupported'): return 'unsupported: ' + G[0][15:].split(' (')[0].strip()
    i = listing.diff_first(W, G)
    if i is None: return None
    if i >= len(W) or i >= len(G): return 'length', i
    w, g = W[i], G[i]
    wm, wo = split(w); gm, go = split(g)
    if bool(HELPER.search(w)) != bool(HELPER.search(g)): return 'helper call', i
    if FRAME.search(w) or FRAME.search(g):
        if wm != gm or FRAME.search(w) and FRAME.search(g) or 'XSP' in w + g: return 'frame', i
    if wm == gm:
        if REG.sub('R', wo) == REG.sub('R', go): return 'register choice', i
        if sorted(wo.split(',')) == sorted(go.split(',')): return 'operand order', i
        if FLOW.match(w): return 'control flow', i
        return 'operand form', i
    if FLOW.match(w) or FLOW.match(g): return 'control flow', i
    return 'instruction choice', i


def main():
    a = sys.argv[1:]
    def arg(k, d=None): return a[a.index(k) + 1] if k in a else d
    opt = arg('--opt'); adecl = '--adecl' in a; nex = int(arg('--examples', '3'))
    personality = arg('--personality', 'v4.23')
    defines = [x[2:] for x in a if x.startswith('-D')]; incs = [x[2:] for x in a if x.startswith('-I')]
    a = [x for x in a if not x.startswith(('-D', '-I'))]
    pos = [x for i, x in enumerate(a) if not x.startswith('--') and (i == 0 or a[i - 1] not in ('--opt', '--examples', '--personality'))]
    odir, files = pos[0], pos[1:]
    base = os.path.basename(os.path.normpath(odir))
    if opt is None: opt = 'O3XS' if base.startswith('O3XS') else 'none'
    if base.endswith('Xr'): adecl = True
    classes = collections.defaultdict(list); tot = ok = 0
    for f in files:
        op = score.oracle_path(odir, f)
        if not os.path.exists(op): print('%s: no oracle listing' % os.path.basename(f)); continue
        want = listing.split(open(op, encoding='latin-1').read())
        try: unit = frontend.load(f, defines, incs, adecl=adecl)
        except Exception as ex:
            tot += len(want); classes['front end'] += [(os.path.basename(f), n, 0) for n in want]; continue
        got = codegen.compile_unit(unit, opt=opt, adecl=adecl, personality=personality)
        for name, wl in want.items():
            tot += 1
            W = listing.normalise_labels([l for l in wl if 'section' not in l])
            G = listing.normalise_labels([l for l in got.get(name, []) if 'section' not in l])
            c = classify(W, G)
            if c is None: ok += 1; continue
            if isinstance(c, str): classes[c].append((os.path.basename(f), name, 0))
            else: classes[c[0]].append((os.path.basename(f), name, c[1]))
    print('%s: %d / %d exact; %d misses' % (odir, ok, tot, tot - ok))
    width = max([len(k) for k in classes] + [5])
    for k, v in sorted(classes.items(), key=lambda kv: -len(kv[1])):
        print('  %-*s %4d   %s' % (width, k, len(v), ' '.join('%s:%s@%d' % e for e in v[:nex])))


if __name__ == '__main__':
    main()
