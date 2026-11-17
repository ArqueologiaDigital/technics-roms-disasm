#!/usr/bin/env python3
"""Which SX-WSA1R functions does a Toshiba cc900 turn into the ROM's bytes, from which C, compiler and option set?

QUESTION ANSWERED: an oracle run compiles C for functions of the WSA1R program images (probe files
scripts/analysis/cc900/corpus/firmware/ws_<a|b|c>_*.c: the letter names the image, prom_a / prom_b / prom_c;
and the staged C wsa1/<prom>/cc900-staged/*.c) with one or more compilers at several option sets.  For each
listing, every function is rewritten by model/to_llvm.py with the operand widths the listing declares, assembled
by llvm-mc and compared with the ROM at the function's own label.  The method is
notes/cc900-c-subcpu-2026-11-16/sub_v423.py's, with the WSA1R's address maps (wsa_common.py: prom_b at 0xF00000,
prom_a and prom_c at 0xF80000) and its names read from the linked ELFs (`make wsa1` first), since the WSA1R has
no symbols reference file.

    python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py corpus DIR FILE.c ... [--sets none,Xr,O3Xr,O3XSXr]
        copies the C files into DIR/ws/ (staged files into DIR/ws/<prom>/) and writes sources.txt / options.txt
        (every file at every set), then prints the oracle run command (one VM run for all of them)
    python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py check RUN_DIR [PATTERN] [--tsv OUT]
        one row per function: its size, the files@compiler/sets that MATCH, else the furthest first difference
    python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py record RUN_DIR
        for every wsa1/<prom>/cc900-staged/*.c that the run compiled with V4.23 at its own option set, writes its
        rows into notes/cc900-c-wsa1-2026-11-17/staged_v423.tsv (tree, C file, sha256, options, run, function,
        bytes, result)
    python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py one LISTING.asm --tree wsa1/prom_a [--cfile C]
        the comparison for one listing

No Toshiba text is printed or written: names, sizes and verdicts only.  Run from the repository root.
"""
import fnmatch, glob, hashlib, os, re, shutil, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import wsa_common as W                                       # noqa: E402
REPO = W.REPO
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')
sys.path.insert(0, os.path.join(CC, 'model'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import listing                                               # noqa: E402
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402
import cc900_firmware_c as fw                                # noqa: E402

SETS = {'none': '', 'g': '-g', 'O0': '-O0', 'O3': '-O3', 'O3XS': '-O3 -XS', 'Xr': '-Xr', 'O3Xr': '-O3 -Xr',
        'O3XSXr': '-O3 -XS -Xr', 'O1Xr': '-O1 -Xr', 'O2Xr': '-O2 -Xr', 'gXr': '-g -Xr', 'O1': '-O1', 'O2': '-O2'}
LABEL_OF = {v: k for k, v in SETS.items()}
OPT_RE = re.compile(rb'cc900-options:([^*\n]*)')
LEDGER = os.path.join(HERE, 'staged_v423.tsv')
FUNC_RE = re.compile(r'^[\w\s\*]+?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)
PROM = {'a': 'wsa1/prom_a', 'b': 'wsa1/prom_b', 'c': 'wsa1/prom_c'}
FRAME_RE = re.compile(r'^\t; untranslated:\s*(link|unlk)\s+(\w+)\s*(?:,\s*(\S+))?\s*$', re.I)


def tree_of(stem, sub=None):
    """a probe ws_<a|b|c>_*.c names its image by the letter; a staged file by its directory (ws/prom_a/...)"""
    if sub in ('prom_a', 'prom_b', 'prom_c'):
        return 'wsa1/' + sub
    m = re.match(r'^ws_([abc])', stem)
    return PROM[m.group(1)] if m else None


def file_flags(path):
    m = OPT_RE.search(open(path, 'rb').read())
    return ' '.join(m.group(1).decode().split()) if m else ''


def frame(line):
    """`link` / `unlk`, which to_llvm does not know (V4.23 never writes them)"""
    m = FRAME_RE.match(line)
    if not m:
        return line
    if m.group(1).lower() == 'link':
        return '\tlink\t%s, 0x%04x' % (m.group(2).lower(), int(m.group(3), 0) & 0xffff)
    return '\tunlk\t%s' % m.group(2).lower()


def compare(lst, tree, cfiles=()):
    """[(function, bytes, verdict)] for one listing"""
    rom, base = W.rom(tree)
    ref, values = W.symbols(tree)
    alias, cnames = {}, {}
    for c in list(cfiles) + glob.glob(os.path.join(REPO, tree, 'cc900', '*.c')):
        lm = fw.label_map(c)
        alias.update(lm)
        for n in FUNC_RE.findall(open(c, encoding='latin-1').read()):
            cnames[n[:31]] = lm.get(n, n)

    class CutNames(fw.Names):
        def resolve(self, n):
            if n in alias:
                n = alias[n]
            r = super().resolve(n)
            b = n.lstrip('._')
            if r[0] is None and b != n:
                r = super().resolve(alias.get(b, b))
            if r[0] is None and len(b) == 31:
                full = [k for k in list(self.values) + list(self.labels) if len(k) > 31 and k[:31] == b]
                if len(set(full)) == 1:
                    return super().resolve(full[0])
            return r
    names = CutNames(dict(values), ref)
    to_llvm.SPELL = None
    module, places = set(), {}
    for c in cfiles:
        module |= fw.module_names(c)
        places.update(fw.data_map(c))
    to_llvm.MODULE = (module | {c for c, l in alias.items() if l in module}) if module else None
    text = open(lst, encoding='latin-1').read()
    to_llvm.WIDTHS = listing.attributes(text)
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    out = []
    for name, lines in listing.split(text).items():
        bare = name.lstrip('_.')
        full = cnames.get(bare) if cnames.get(bare) in ref else bare if bare in ref else \
            '_' + bare if '_' + bare in ref else \
            (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
        if full is None:
            out.append((bare, 0, 'not a label of the image')); continue
        consts, _ = to_llvm.split_consts(lines)
        pl = places.get(bare, places.get(full, {}))
        to_llvm.DATA = {c: '0x%x' % ref[pl[k]] for k, c in enumerate(consts, 1) if k in pl and pl[k] in ref}
        to_llvm.DATA_REQUIRED = bool(consts)
        try:
            body = [l for l in to_llvm.translate_function(name, lines, names)
                    if l not in ('\t.globl %s' % bare, bare + ':')]
        except KeyError as e:
            out.append((full, 0, 'cannot resolve %s' % e)); continue
        body = [frame(l.replace('$+', '.+').replace('$-', '.-')) for l in body]
        body = [re.sub(r'^(\t(?:sla|sll|sra|srl|rlc|rrc|rl|rr) \w+), 0$', r'\1, 16', l) for l in body]
        own = {m.group(1) for l in body for m in [re.match(r'^([.\w$]+):', l)] if m}

        def own_address(l):
            m = re.match(r'^(\tlda \w+, )\(([.\w$]+):24\)$', l)
            if m and m.group(2) in own:
                return '%s(0x%x + %s - %s:24)' % (m.group(1), ref[full], m.group(2), full)
            return l
        body = [own_address(l) for l in body]
        if any('untranslated' in l for l in body):
            if os.environ.get('WSA_V423_SHAPES'):          # the offending lines' shapes (numbers masked), no text
                for l in body:
                    if 'untranslated' in l:
                        print('  untranslated shape:', re.sub(r'\b\d+\b', 'N', re.sub(r'0x[0-9a-fA-F]+', 'H',
                                                                                        l.strip())))
            out.append((full, 0, 'to_llvm cannot translate a line')); continue
        plain = '\n'.join(body)
        targets = sorted({int(m.group(1), 16) for m in re.finditer(r'__cc900_at_([0-9a-f]+)', plain)})
        at = ref[full]
        if targets and any(abs(t - at) > 0x10000 for t in targets):
            out.append((full, 0, 'a module-local target is out of calr / jrl reach')); continue

        def source(text_):
            if not targets:
                return '\t.text\n\t.globl %s\n%s:\n%s\n' % (full, full, text_)
            b0 = min(targets + [at])
            self_ = '__cc900_at_%x:\n' % at if at in targets else ''
            items = sorted([(t, '__cc900_at_%x:' % t) for t in targets if t != at] +
                           [(at, '%s\t.globl %s\n%s:\n%s\n\t.globl __cc900_end\n__cc900_end:' % (self_, full, full, text_))])
            return '\t.text\n' + '\n'.join('\t.org 0x%x\n%s' % (a - b0, txt) for a, txt in items) + '\n'
        mine = None
        for text_ in ([plain] if targets else []) + [to_llvm.relax(plain, fw.assembler_errors)]:
            try:
                mine = check_bytes.assemble(source(text_))[full]
                break
            except Exception:
                continue
        if mine is None:
            out.append((full, 0, 'llvm-mc cannot assemble the translation')); continue
        o = ref[full] - base
        r = rom[o:o + len(mine)]
        if mine == r:
            out.append((full, len(mine), 'MATCH'))
        else:
            first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
            out.append((full, len(mine), 'DIFF at +%d' % first))
    return out


def corpus(d, files, sets):
    d = os.path.abspath(d)
    srcs = []
    for f in files:
        rel = os.path.relpath(os.path.abspath(f), REPO).split(os.sep)
        sub = 'ws/%s/' % rel[1] if len(rel) == 4 and rel[0] == 'wsa1' and rel[2] == 'cc900-staged' else 'ws/'
        os.makedirs(os.path.join(d, sub), exist_ok=True)
        shutil.copyfile(f, os.path.join(d, sub, os.path.basename(f)))
        for h in re.findall(r'#include\s+"([^"]+)"', open(f, encoding='latin-1').read()):
            shutil.copyfile(os.path.join(os.path.dirname(f), h), os.path.join(d, sub, h))
        srcs.append(sub + os.path.basename(f))
    open(os.path.join(d, 'sources.txt'), 'w').write(''.join(s + '\n' for s in srcs))
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (s, SETS[s]) for s in sets))
    print('%d C files in %s, option sets %s' % (len(srcs), d, ' '.join(sets)))
    print('run (from scripts/analysis/cc900; it takes a free slot of the VM pool, no flock): '
          'bash oracle/run_oracle.sh <name> %s %s/sources.txt %s/options.txt v423' % (d, d, d))


def find_c(stem, sub=None):
    cands = [os.path.join(REPO, 'wsa1', sub, 'cc900-staged', stem + '.c')] if sub else \
        [os.path.join(CC, 'corpus', 'firmware', stem + '.c')]
    return next((p for p in cands if os.path.exists(p)), None)


def listings(run):
    """(compiler, option label, sub directory or None, stem, path) of every listing of the run"""
    for comp in sorted(os.listdir(os.path.join(run, 'out'))):
        cd = os.path.join(run, 'out', comp)
        if not os.path.isdir(cd):
            continue
        for label in sorted(os.listdir(cd)):
            d = os.path.join(cd, label, 'ws')
            if not os.path.isdir(d):
                continue
            for dp, dn, fn in os.walk(d):
                dn.sort()
                sub = os.path.relpath(dp, d)
                for f in sorted(fn):
                    yield comp, label, None if sub == '.' else sub, f, os.path.join(dp, f)


def check(run, pat, tsv):
    res = {}
    seen = set(x[4] for x in listings(run))
    for comp, label, sub, f, path in listings(run):
        if f.endswith('.cc.log') and fnmatch.fnmatch(f[:-7], pat) and path[:-7] + '.asm' not in seen:
            print('%s %s %s: the compiler refused the file (see its .cc.log)' % (comp, label, f[:-7]))
        if not f.endswith('.asm') or not fnmatch.fnmatch(f[:-4], pat):
            continue
        stem = f[:-4]
        tree = tree_of(stem, sub)
        if tree is None:
            continue
        src = find_c(stem, sub)
        for fn, n, v in compare(path, tree, [src] if src else []):
            res.setdefault((tree, fn), {})[(stem, comp, label)] = (n, v)
    rows = []
    for tree, fn in sorted(res):
        v = res[(tree, fn)]
        ok = sorted('%s@%s/%s' % k for k, x in v.items() if x[1] == 'MATCH')
        size = max(x[0] for x in v.values() if x[1] == 'MATCH') if ok else max(x[0] for x in v.values())
        diffs = [(int(x[1].split('+')[1]), '%s@%s/%s' % k) for k, x in v.items() if x[1].startswith('DIFF')]
        other = sorted(set(x[1] for x in v.values() if not x[1].startswith(('MATCH', 'DIFF'))))
        best = '+%d %s' % max(diffs) if diffs else '; '.join(other)
        rows.append((tree, fn, size, ' '.join(ok) or '-', '' if ok else best))
    w = max([len(r[1]) for r in rows] + [8])
    for r in rows:
        print('%-11s %-*s %4d B  %-5s %s' % (r[0], w, r[1], r[2], 'MATCH' if r[3] != '-' else 'diff',
                                             r[3] if r[3] != '-' else r[4]))
    n = [r for r in rows if r[3] != '-']
    print('%d of %d functions match; %d B' % (len(n), len(rows), sum(r[2] for r in n)))
    if tsv:
        with open(tsv, 'w') as fh:
            fh.write('tree\tfunction\tbytes\tmatches\tbest_diff\n')
            for r in rows:
                fh.write('%s\t%s\t%d\t%s\t%s\n' % r)


def sha256(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def record(run):
    runname = os.path.basename(os.path.normpath(run))
    out = []
    for tree in sorted(W.TREES):
        t = tree.split('/')[1]
        for c in sorted(glob.glob(os.path.join(REPO, tree, 'cc900-staged', '*.c'))):
            stem = os.path.basename(c)[:-2]
            label = LABEL_OF[file_flags(c)]
            lst = os.path.join(run, 'out', 'v423', label, 'ws', t, stem + '.asm')
            if not os.path.exists(lst):
                print('%s %s: the run has no listing at %s' % (t, stem, label)); continue
            for fn, n, v in compare(lst, tree, [c]):
                out.append([t, os.path.relpath(c, REPO), sha256(c), label, runname, fn, str(n), v])
                print('%-6s %-36s %-6s %-36s %4d  %s' % (t, os.path.basename(c), label, fn, n, v))
    keep = []
    if os.path.exists(LEDGER):
        done = {r[1] for r in out}
        keep = [l.rstrip('\n').split('\t') for l in open(LEDGER) if not l.startswith(('#', 'tree\t'))]
        keep = [k for k in keep if k[1] not in done]
    rows = sorted(keep + out, key=lambda r: (r[1], r[5]))
    with open(LEDGER, 'w') as fh:
        fh.write('# Staged SX-WSA1R firmware C (wsa1/<prom>/cc900-staged/) checked against the ROM with Toshiba V4.23, by\n'
                 '# notes/cc900-c-wsa1-2026-11-17/wsa_v423.py record.  The listings stay in the private oracle repo.\n'
                 '# Caveat: the sha256 is of the C file as it is now; the run must have compiled that same text.\n'
                 'tree\tc_file\tsha256\toptions\trun\tfunction\tbytes\tresult\n')
        for r in rows:
            fh.write('\t'.join(r) + '\n')
    print('%d rows in %s' % (len(rows), os.path.relpath(LEDGER, REPO)))


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    if a[0] == 'corpus':
        files = [x for x in a[2:] if x.endswith('.c')]
        return corpus(a[1], files, opt(a, '--sets', 'none,Xr,O3Xr,O3XSXr').split(','))
    if a[0] == 'check':
        pat = a[2] if len(a) > 2 and not a[2].startswith('--') else '*'
        return check(a[1], pat, opt(a, '--tsv', None))
    if a[0] == 'record':
        return record(a[1])
    if a[0] == 'one':
        cf = [a[i + 1] for i, x in enumerate(a) if x == '--cfile']
        for fn, n, v in compare(a[1], opt(a, '--tree', 'wsa1/prom_a'), cf):
            print('%-36s %4d B  %s' % (fn, n, v))
        return 0
    sys.exit(__doc__)


if __name__ == '__main__':
    sys.exit(main())
