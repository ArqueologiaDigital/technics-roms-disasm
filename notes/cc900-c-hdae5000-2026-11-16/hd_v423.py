#!/usr/bin/env python3
"""Which of our C functions does Toshiba V4.23 turn into the HD-AE5000 ROM's bytes, in which file and option set?

QUESTION ANSWERED: lane_hd writes C for the HD-AE5000 images (probe files in this directory's probes/, staged files
in hdae5000/cc900-staged/).  An oracle run compiles them in the VM; this compares every function of every listing
with the ROM, as scripts/analysis/cc900/asm_vs_rom.py does for the main CPU: the listing goes through
model/to_llvm.py (asm900's encodings, operand widths as the listing declares them), llvm-mc assembles it, and the
bytes are compared with the image at the function's label.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --corpus DIR OPTIONS FILE.c [FILE.c ...]
        copies the C files into DIR/hd/ with their #include "..." headers inlined (expand()), writes DIR/sources.txt and DIR/options.txt (OPTIONS: comma-separated labels
        of LABELS below, e.g. O3Xr,Xr) and prints the oracle command (run it under the VM lock)
    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR [--image v2.06i] [--tsv OUT] [--only GLOB]
                                                                          [--calr] [--record]
        one row per function: bytes and, per C file and option set, MATCH or the first differing offset.  --calr:
        a `call` (V4.23's `cal`) whose place in the ROM holds a `calr` to the same target is written calr, as asm900
        writes a call to a function of the same source file; such a match is reported `MATCH calr:<targets>`, and
        is only real once those targets are in the same C file.  An operand naming the compiler's own data (a
        switch table S50000, an initialiser S1), which to_llvm cannot place, is masked: `MATCH sdata:<n>` means
        the code is identical and the n data operands are not checked.  --tsv
        writes (c_file, options, function, bytes, result) rows.  --compiler NAME reads another compiler's listings
        of the run (ide2003, v110; diagnostics only: a function is done only under V4.23).  --record appends the rows of the STAGED files
        (hdae5000/cc900-staged/*.c whose text the run compiled) to staged_v423.tsv beside this script (tree directory, C file,
        SHA-256 of its text, options, run, function, bytes, result), replacing that file's earlier rows.
    python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --show RUN_DIR FUNC [--file STEM] [--label O3Xr]
        for working only (never paste its output into the repository: it is derived from Toshiba's listing): our
        llvm-mc spelling of V4.23's code for FUNC, each line with its bytes and the ROM's bytes at that offset

The Toshiba library's own names in a listing's calls (`C9H_mullu`) resolve to the tree's labels through
notes/toshiba-runtime-xref-2026-11-08/results/xref.resolved.tsv (`HDAE5000_Multiply`).

C names: a function's C name is the tree's label; a `cc900-name: CNAME=LABEL` comment maps a shorter one (cc900
keeps 31 characters), or several variants of one function in one probe file (reported as FILE:CNAME).  Other names resolve as in the build (scripts/build/cc900_firmware_c.py): the tree's `.equ`
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
        if f.endswith('.c'):
            open(os.path.join(d, 'hd', os.path.basename(f)), 'w', encoding='latin-1').write(expand(f))
            names.append('hd/' + os.path.basename(f))
    open(os.path.join(d, 'sources.txt'), 'w').write('\n'.join(names) + '\n')
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (l, LABELS[l]) for l in labels))
    print('flock /home/fsanches/compartilhado/cc900-oracle/vm/.runlock bash scripts/analysis/cc900/oracle/run_oracle.sh '
          'RUN_NAME %s %s/sources.txt %s/options.txt v423' % (d, d, d))


INC_RE = re.compile(r'^[ \t]*#[ \t]*include[ \t]*"([^"]+)"[ \t]*$', re.M)
HEADER_DIRS = [os.path.join(os.path.dirname(os.path.abspath(__file__)), 'probes'),
               os.path.join(REPO, 'hdae5000', 'cc900-staged')]


def expand(path):
    """FILE.c with each #include "x.h" replaced by the header's text: V4.23 in the oracle VM did not open a header
    beside the C (run 2026-11-16-46-hd-r2: THC1-Error-310 although job.sh passes -I with the source directory).
    Of a header of #defines only (hdae_ids.h) only the macros the file uses are kept."""
    text = open(path, encoding='latin-1').read()

    def one(m):
        h = next((os.path.join(x, m.group(1)) for x in [os.path.dirname(os.path.abspath(path))] + HEADER_DIRS
                  if os.path.exists(os.path.join(x, m.group(1)))), None)
        if h is None:
            sys.exit('%s: #include "%s" not found' % (path, m.group(1)))
        ht = open(h, encoding='latin-1').read()
        lines = ht.split('\n')
        if all(l.startswith('#define ') or l.startswith('/*') or not l.strip() for l in lines):
            words = set(re.findall(r'\w+', INC_RE.sub('', text)))
            ht = '\n'.join(l for l in lines if l.startswith('/*') or (l.startswith('#define ') and l.split()[1] in words))
        return '/* ---- %s (inlined) ---- */\n%s\n/* ---- end of %s ---- */' % (m.group(1), ht.rstrip('\n'), m.group(1))
    return INC_RE.sub(one, text)


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


def library_aliases(image):
    """{library name: the tree's label} for one HD-AE5000 image (the runtime xref's rows)"""
    tag = 'hdae ' + image
    out = {}
    for l in open(os.path.join(REPO, 'notes/toshiba-runtime-xref-2026-11-08/results/xref.resolved.tsv'),
                  encoding='latin-1'):
        f = l.rstrip('\n').split('\t')
        if len(f) > 4 and f[0] == tag:
            for n in f[2].split(' | '):
                out[n.strip().lstrip('_.')] = f[4]
    # names known by reference only (C9H_divlu = HDAE5000_UDivMod32 ...): image, address, library name, from, label
    for l in open(os.path.join(REPO, 'notes/toshiba-runtime-xref-2026-11-08/results/xref.inferred.tsv'),
                  encoding='latin-1'):
        f = l.rstrip('\n').split('\t')
        if len(f) > 4 and f[0] == tag and f[4] != '?':
            out.setdefault(f[2].strip().lstrip('_.'), f[4])
    # names V4.23 calls that the xref tables give another name: ._fld_ful (unsigned long to float) is the routine
    # the xref calls ._fld_fl_tail, our HDAE5000_ULongToFloat (0x29b815, entered after ._fld_fl's sign handling)
    out.setdefault('fld_ful', 'HDAE5000_ULongToFloat')
    return out


def setup(image):
    import check_bytes
    import cc900_firmware_c as fw
    tree, romp, symp = IMAGES[image]
    rom = open(os.path.join(REPO, romp), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, symp))
    values = tree_values(tree)
    for lib, lab in library_aliases(image).items():
        if lab in ref and lib not in values:
            values[lib] = ref[lab]
    return tree, rom, ref, fw.Names(values, ref, cut=True)


def show(a):
    import listing, to_llvm, check_bytes
    run, func = a[0], a[1]
    tree, rom, ref, names = setup(opt(a, '--image', 'v2.06i'))
    base = os.path.join(run, 'out', opt(a, '--compiler', 'v423'))
    for label in sorted(os.listdir(base)):
        if opt(a, '--label') not in (None, label):
            continue
        for asm in sorted(glob.glob(os.path.join(base, label, '**', '*.asm'), recursive=True)):
            stem = os.path.basename(asm)[:-4]
            if opt(a, '--file') not in (None, stem):
                continue
            text = open(asm, encoding='latin-1').read()
            to_llvm.SPELL = None
            to_llvm.WIDTHS = listing.attributes(text)
            for name, lines in listing.split(text).items():
                if name.lstrip('_.') != func[:31]:
                    continue
                body = [l for l in to_llvm.translate_function(name, lines, names) if not l.endswith(':') and
                        not l.startswith('\t.globl')]
                print('== %s %s' % (stem, label))
                if func not in ref:                      # a variant: its label from the probe's cc900-name comment
                    src = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'probes', stem + '.c')
                    func = c_names([src]).get(func[:31], func)
                at = ref[func] - BASE
                off = 0
                for l in body:
                    try:
                        b = check_bytes.assemble('\t.text\n\t.globl f\nf:\n%s\n' % l).get('f', b'')
                    except Exception:
                        b = b''
                    r = rom[at + off:at + off + len(b)]
                    print('%-40s %-16s %s %s' % (l.strip(), b.hex(), '=' if b == r else '!', r.hex()))
                    off += len(b)


def mc_errors(text):
    """llvm-mc's stderr for one text (empty when it assembles)"""
    import subprocess, tempfile
    import check_bytes
    with tempfile.TemporaryDirectory() as d:
        f = os.path.join(d, 'f.s')
        open(f, 'w').write(text)
        r = subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-mc'), '-triple=tlcs900', '-filetype=obj', f, '-o',
                            os.path.join(d, 'f.o')], capture_output=True, text=True)
        return r.stderr if r.returncode else ''


SDATA_RE = re.compile(r'untranslated: (\w+)\t(\w+),S\d+\s*$')
SDATA_MARK = 0x5a5a5a00
CALL_RE = re.compile(r'^\s*call\s+(0x[0-9a-fA-F]+)\s*$')


def assemble_fn(full, body, rom, at, calr):
    """the bytes of one translated function, with asm900's jr / jrl choice (to_llvm.relax).  With calr, each absolute
    `call T` whose place in the ROM holds a `calr` to the same T is written `calr` -- asm900's shortening of a call
    to a function of the same source file.  Returns (bytes, [relaxed call targets])."""
    import check_bytes, to_llvm
    head = '\t.text\n\t.globl %s\n%s:\n.Lhd_base:\n' % (full, full)   # a local base: calr to it resolves
    text = to_llvm.relax(head + '\n'.join(body) + '\n', mc_errors)
    lines = text.split('\n')[4:]
    shortened = []
    if calr and any(CALL_RE.match(l) for l in lines):
        marked = []
        for i, l in enumerate(lines):
            marked += ['\t.globl __hdp%d' % i, '__hdp%d:' % i, l]
        got = check_bytes.assemble(head + '\n'.join(marked) + '\n')
        off = 0
        for i, l in enumerate(lines):
            n = len(got.get('__hdp%d' % i, b''))
            m = CALL_RE.match(l)
            if m:
                t = int(m.group(1), 16)
                o = at + off
                if rom[o:o + 1] == b'\x1e':
                    disp = int.from_bytes(rom[o + 1:o + 3], 'little', signed=True)
                    if BASE + o + 3 + disp == t:
                        lines[i] = '\tcalr .Lhd_base + %d' % (t - (BASE + at))
                        shortened.append('%06x' % t)
                        n = 3
            off += n
        text = to_llvm.relax(head + '\n'.join(lines) + '\n', mc_errors)
    return check_bytes.assemble(text)[full], shortened


def check(a):
    import listing, to_llvm, check_bytes
    run = a[0]
    image = opt(a, '--image', 'v2.06i')
    tree, rom, ref, names = setup(image)
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    only = opt(a, '--only', '*')
    res, order = {}, []
    base = os.path.join(run, 'out', opt(a, '--compiler', 'v423'))
    for label in sorted(os.listdir(base)):
        for asm in sorted(glob.glob(os.path.join(base, label, '**', '*.asm'), recursive=True)):
            stem = os.path.basename(asm)[:-4]
            if not fnmatch.fnmatch(stem, only):
                continue
            srcs = glob.glob(os.path.join(REPO, 'notes', 'cc900-c-hdae5000-2026-11-16', 'probes', stem + '.c')) + \
                glob.glob(os.path.join(REPO, tree, 'cc900-staged', stem + '.c'))
            cn = c_names(srcs)
            for cname, lab in cn.items():                # a call to a function by its short C name
                if lab in ref:
                    for pre in ('', '.', '_'):
                        names.values.setdefault(pre + cname, ref[lab])
            to_llvm.SPELL = None
            text = open(asm, encoding='latin-1').read()
            to_llvm.WIDTHS = listing.attributes(text)
            for name, lines in listing.split(text).items():
                bare = name.lstrip('_.')
                full = cn.get(bare) if cn.get(bare) in ref else bare if bare in ref else \
                    (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
                key = full or bare
                if full and bare != full and cn.get(bare) == full:
                    stem_k = '%s:%s' % (stem, bare)      # one of several C variants of one label (cc900-name)
                else:
                    stem_k = stem
                if key not in res:
                    res[key] = {}
                    order.append(key)
                if full is None:
                    res[key][(stem_k, label)] = (0, 'not in the symbols reference')
                    continue
                try:
                    body = [l for l in to_llvm.translate_function(name, lines, names)
                            if l not in ('\t.globl %s' % bare, bare + ':')]
                except KeyError as e:
                    res[key][(stem_k, label)] = (0, 'cannot resolve %s' % e)
                    continue
                marks = []
                for i, l in enumerate(body):
                    m = SDATA_RE.search(l)
                    if m:                            # an operand naming the compiler's own data (S50000: a switch
                        marks.append(len(marks))     # table, S1: an initialiser); masked, reported `sdata:<n>`
                        body[i] = '\t%s %s, 0x%x' % (m.group(1), m.group(2).lower(), SDATA_MARK + len(marks) - 1)
                if any('untranslated' in l for l in body):
                    res[key][(stem_k, label)] = (0, 'to_llvm cannot translate a line')
                    continue
                at = ref[full] - BASE
                try:
                    mine, relaxed = assemble_fn(full, body, rom, at, '--calr' in a)
                except Exception:
                    res[key][(stem_k, label)] = (0, 'llvm-mc refused the translation')
                    continue
                r = rom[at:at + len(mine)]
                if marks:
                    mine = bytearray(mine)
                    for k in marks:
                        mk = (SDATA_MARK + k).to_bytes(4, 'little')
                        j = mine.find(mk)
                        if j >= 0 and len(r) >= j + 4:
                            mine[j:j + 4] = r[j:j + 4]
                    mine = bytes(mine)
                if mine == r and marks:
                    res[key][(stem_k, label)] = (len(mine), 'MATCH sdata:%d' % len(marks) +
                                                 (' calr:' + ','.join(relaxed) if relaxed else ''))
                elif mine == r:
                    res[key][(stem_k, label)] = (len(mine), 'MATCH' + (' calr:' + ','.join(relaxed) if relaxed else ''))
                else:
                    first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
                    res[key][(stem_k, label)] = (len(mine), 'DIFF at +%d' % first)
        for log in sorted(glob.glob(os.path.join(base, label, '**', '*.cc.log'), recursive=True)):
            stem = os.path.basename(log)[:-7]
            if fnmatch.fnmatch(stem, only) and not os.path.exists(log[:-7] + '.asm'):
                print('%s %s: V4.23 refused the file (see its .cc.log in the run)' % (label, stem))
    rows = []
    for k in order:
        v = res[k]
        ok = sorted('%s/%s%s' % (s + (r[5:],)) for s, (n, r) in v.items() if r.startswith('MATCH'))
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
    if '--record' in a:
        record(run, image, tree, res)
    if '--tsv' in a:
        with open(opt(a, '--tsv'), 'w') as f:
            f.write('c_file\toptions\tfunction\tbytes\tresult\n')
            for k in order:
                for (stem, label), (n, r) in sorted(res[k].items()):
                    f.write('%s\t%s\t%s\t%d\t%s\n' % (stem, label, k, n, r))


LEDGER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'staged_v423.tsv')
HEAD = ('# Staged HD-AE5000 C (hdae5000/cc900-staged/) checked against the ROM with Toshiba V4.23, by\n'
        '# notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR --record.  The listings stay in the private '
        'oracle repo.\n'
        'tree\tc_file\tsha256\toptions\trun\tfunction\tbytes\tresult\n')


def record(run, image, tree, res):
    import hashlib
    rows = []
    if os.path.exists(LEDGER):
        rows = [l for l in open(LEDGER).read().split('\n') if l and not l.startswith('#') and not l.startswith('tree\t')]
    new, files = [], set()
    for k, v in res.items():
        for (stem, label), (n, r) in v.items():
            c = os.path.join(tree, 'cc900-staged', stem.split(':')[0] + '.c')   # FILE:CNAME for a short C name
            p = os.path.join(REPO, c)
            if not os.path.exists(p):
                continue
            # the run files only the corpus tarball's hash, so the SHA-256 is of the text now: record right after
            # the run, before the staged file changes
            h = hashlib.sha256(open(p, 'rb').read()).hexdigest()
            files.add(c)
            new.append('\t'.join([tree, c, h, label, os.path.basename(run.rstrip('/')), k, str(n), r]))
    rows = [r for r in rows if r.split('\t')[1] not in files] + sorted(new)
    open(LEDGER, 'w').write(HEAD + '\n'.join(rows) + '\n')


def main():
    a = sys.argv[1:]
    if '--show' in a:
        show(a[a.index('--show') + 1:])
    elif '--corpus' in a:
        corpus(a[a.index('--corpus') + 1:])
    elif '--check' in a:
        check(a[a.index('--check') + 1:])
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
