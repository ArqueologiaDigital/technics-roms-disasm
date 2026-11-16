#!/usr/bin/env python3
"""Which of our C functions does Toshiba V4.23 turn into the HD-AE5000 ROM's bytes, in which file and option set?

QUESTION ANSWERED: lane_hd writes C for the HD-AE5000 images (probe files in this directory's probes/, staged files
in hdae5000/cc900-staged/).  An oracle run compiles them in the VM; this compares every function of every listing
with the ROM, as scripts/analysis/cc900/asm_vs_rom.py does for the main CPU: the listing goes through
model/to_llvm.py (asm900's encodings, operand widths as the listing declares them), llvm-mc assembles it, and the
bytes are compared with the image at the function's label.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --corpus DIR OPTIONS FILE.c [FILE.c ...]
        copies the C files into DIR/hd/, writes DIR/sources.txt and DIR/options.txt (OPTIONS: comma-separated labels
        of LABELS below, e.g. O3Xr,Xr) and prints the oracle command (run it under the VM lock)
    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR [--image v2.06i] [--tsv OUT] [--only GLOB]
        one row per function: bytes and, per C file and option set, MATCH or the first differing offset.  --tsv
        writes (c_file, options, function, bytes, result) rows.

C names: a function's C name is the tree's label; a `cc900-name: CNAME=LABEL` comment maps a shorter one (cc900
keeps 31 characters).  Other names resolve as in the build (scripts/build/cc900_firmware_c.py): the tree's `.equ`
values, `ram_<hex>` cells, the symbols reference's labels.  No Toshiba text is printed or written: names, sizes and
verdicts only.  Run from the repository root.
"""
import fnmatch, glob, os, re, shutil, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')
sys.path.insert(0, os.path.join(CC, 'model'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
LABELS = {'O3Xr': '-O3 -Xr', 'Xr': '-Xr', 'O3XSXr': '-O3 -XS -Xr', 'O3XS': '-O3 -XS', 'none': '', 'O1Xr': '-O1 -Xr',
          'O2Xr': '-O2 -Xr', 'O3': '-O3'}
IMAGES = {'v2.06i': ('hdae5000', 'original_ROMs/hd-ae5000_v2_06i.ic4', 'symbols/hdae5000_symbols_reference.txt'),
          'v2.01i': ('hdae5000_v2_01i', 'original_ROMs/hd-ae5000_v2_01i.ic4',
                     'symbols/hdae5000_v2_01i_symbols_reference.txt'),
          'v1.15i': ('hdae5000_v1_15i', 'original_ROMs/hd-ae5000_v1_15i.ic4',
                     'symbols/hdae5000_v1_15i_symbols_reference.txt'),
          'v1.10i': ('hdae5000_v1_10i', 'original_ROMs/hd-ae5000_v1_10i.ic4',
                     'symbols/hdae5000_v1_10i_symbols_reference.txt')}
BASE = 0x280000
NAME_RE = re.compile(r'cc900-name:\s*([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)')
DEF_RE = re.compile(r'^[\w\s\*]+?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def opt(a, n, d=None):
    return a[a.index(n) + 1] if n in a else d


def corpus(a):
    d = os.path.abspath(a[0])
    labels = a[1].split(',')
    os.makedirs(os.path.join(d, 'hd'), exist_ok=True)
    names = []
    for f in a[2:]:
        shutil.copyfile(f, os.path.join(d, 'hd', os.path.basename(f)))
        names.append('hd/' + os.path.basename(f))
    open(os.path.join(d, 'sources.txt'), 'w').write('\n'.join(names) + '\n')
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (l, LABELS[l]) for l in labels))
    print('flock /home/fsanches/compartilhado/cc900-oracle/vm/.runlock bash scripts/analysis/cc900/oracle/run_oracle.sh '
          'RUN_NAME %s %s/sources.txt %s/options.txt v423' % (d, d, d))


def c_names(cfiles):
    """{C name cut to 31: tree label} from the C files' definitions and cc900-name comments"""
    out = {}
    for c in cfiles:
        t = open(c, encoding='latin-1').read()
        lm = dict(NAME_RE.findall(t))
        for n in DEF_RE.findall(t):
            out[n[:31]] = lm.get(n, n)
    return out


def tree_values(tree):
    import cc900_firmware_c as fw
    v = fw.tree_values(os.path.join(REPO, tree))
    if tree != 'hdae5000':                      # the ported trees take shared/ from hdae5000 through a second -I
        for k, x in fw.tree_values(os.path.join(REPO, 'hdae5000', 'shared')).items():
            v.setdefault(k, x)
    return v


def check(a):
    import listing, to_llvm, check_bytes
    import cc900_firmware_c as fw
    run = a[0]
    image = opt(a, '--image', 'v2.06i')
    tree, romp, symp = IMAGES[image]
    rom = open(os.path.join(REPO, romp), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, symp))
    names = fw.Names(tree_values(tree), ref, cut=True)
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    only = opt(a, '--only', '*')
    res, order = {}, []
    base = os.path.join(run, 'out', 'v423')
    for label in sorted(os.listdir(base)):
        for asm in sorted(glob.glob(os.path.join(base, label, '**', '*.asm'), recursive=True)):
            stem = os.path.basename(asm)[:-4]
            if not fnmatch.fnmatch(stem, only):
                continue
            srcs = glob.glob(os.path.join(REPO, 'notes', 'cc900-c-hdae5000-2026-11-16', 'probes', stem + '.c')) + \
                glob.glob(os.path.join(REPO, tree, 'cc900-staged', stem + '.c'))
            cn = c_names(srcs)
            to_llvm.SPELL = None
            text = open(asm, encoding='latin-1').read()
            to_llvm.WIDTHS = listing.attributes(text)
            for name, lines in listing.split(text).items():
                bare = name.lstrip('_.')
                full = cn.get(bare) if cn.get(bare) in ref else bare if bare in ref else \
                    (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
                key = full or bare
                if key not in res:
                    res[key] = {}
                    order.append(key)
                if full is None:
                    res[key][(stem, label)] = (0, 'not in the symbols reference')
                    continue
                try:
                    body = [l for l in to_llvm.translate_function(name, lines, names)
                            if l not in ('\t.globl %s' % bare, bare + ':')]
                except KeyError as e:
                    res[key][(stem, label)] = (0, 'cannot resolve %s' % e)
                    continue
                if any('untranslated' in l for l in body):
                    res[key][(stem, label)] = (0, 'to_llvm cannot translate a line')
                    continue
                try:
                    mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n%s\n' % (full, full, '\n'.join(body)))[full]
                except Exception:
                    res[key][(stem, label)] = (0, 'llvm-mc refused the translation')
                    continue
                at = ref[full] - BASE
                r = rom[at:at + len(mine)]
                if mine == r:
                    res[key][(stem, label)] = (len(mine), 'MATCH')
                else:
                    first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
                    res[key][(stem, label)] = (len(mine), 'DIFF at +%d' % first)
        for log in sorted(glob.glob(os.path.join(base, label, '**', '*.cc.log'), recursive=True)):
            stem = os.path.basename(log)[:-7]
            if fnmatch.fnmatch(stem, only) and not os.path.exists(log[:-7] + '.asm'):
                print('%s %s: V4.23 refused the file (see its .cc.log in the run)' % (label, stem))
    rows = []
    for k in order:
        v = res[k]
        ok = sorted('%s/%s' % s for s, (n, r) in v.items() if r == 'MATCH')
        n = max(x for x, _ in v.values())
        if ok:
            best = 'MATCH ' + ' '.join(ok)
        else:
            diffs = [(int(r.split('+')[1]), '%s/%s' % s) for s, (x, r) in v.items() if r.startswith('DIFF')]
            best = ('best DIFF at +%d (%s)' % max(diffs)) if diffs else '; '.join(sorted(set(r for _, r in v.values())))
        rows.append((k, n, best))
    w = max([len(r[0]) for r in rows] + [8])
    for k, n, best in rows:
        print('%-*s %5d B  %s' % (w, k, n, best))
    print('%d functions, %d match (%d B)' % (len(rows), sum(1 for r in rows if r[2].startswith('MATCH')),
                                             sum(r[1] for r in rows if r[2].startswith('MATCH'))))
    if '--tsv' in a:
        with open(opt(a, '--tsv'), 'w') as f:
            f.write('c_file\toptions\tfunction\tbytes\tresult\n')
            for k in order:
                for (stem, label), (n, r) in sorted(res[k].items()):
                    f.write('%s\t%s\t%s\t%d\t%s\n' % (stem, label, k, n, r))


def main():
    a = sys.argv[1:]
    if '--corpus' in a:
        corpus(a[a.index('--corpus') + 1:])
    elif '--check' in a:
        check(a[a.index('--check') + 1:])
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
