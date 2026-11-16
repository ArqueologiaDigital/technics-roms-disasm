#!/usr/bin/env python3
"""How much of each Technics ROM image is built from C sources, and by which toolchain?

QUESTION ANSWERED: for every TLCS-900 image of the KN5000 and the SX-WSA1R, how many ROM bytes come from C that a
compiler turns into exactly the ROM's bytes, checked byte for byte against the image, per toolchain:

  Toshiba V4.23    the C compiled by the original compiler (thc2 listing from the oracle VM), translated by
                   model/to_llvm.py and assembled by our llvm-mc at the function's address.  Each symbol's operand
                   width is the one the listing declares (`extern small|medium|large`: the C's __tiny / __near /
                   plain), as the build reads it (cc900_firmware_c.listing_widths), never a guess from the address.
                   For firmware C this is what `make` builds (CC900_COMPILER=v423, the default);
  reference model  the same C through the Python reference model (scripts/analysis/cc900/model/), then the same
                   to_llvm.py and llvm-mc, widths from the C's qualifiers.  `make CC900_COMPILER=model` builds it;
  LLVM backend     clang -mcc900-compat (phase 3b of notes/cc900-compat-plan-2026-11-08/PLAN.md).  It does not
                   exist yet, so the column is 0; see llvm_backend_results() for the hook.

Two kinds of C source count (one table row per image and kind):

  firmware C   Matsushita's functions reconstructed in cc900 phase 6, <tree>/cc900/*.c (and <tree>/cc900/unbuilt/*.c,
               C that V4.23 does not reproduce, checked but never built), built into the image by
               scripts/build/cc900_firmware_c.py (notes/cc900-phase6-2026-11-16/README.md).  A function counts for
               the model when the tree includes its generated body (`.include "includes/generated/cc900/F.s"`) and
               the model's bytes equal the ROM's at the symbols reference's address (as model/fn_diff.py checks).
               It counts for V4.23 when a V4.23 listing of exactly this C file at the file's options gives the
               ROM's bytes.  The listing comes from the build's own V4.23 cache first (build/cc900-v423, or
               CC900_V423_CACHE; the key of this text, options, headers, compiler and job.sh, as
               scripts/build/cc900_v423.py computes it): under the default build the build IS the V4.23 check.
               Otherwise from a recorded oracle run (same SHA-256, results/c_build_v423_runs.tsv).  The "V4.23
               run" column names the source: `cache <key prefix>` or the run.  A function with neither is "not yet
               checked", never guessed; `make` (or --v423-corpus and an oracle run) checks it.  A function the
               model refuses still gets its V4.23 verdict (its name from the C's own definitions).
               When V4.23 refuses the file (listing FAILED in the runs file: an error in its .cc.log, e.g. two names
               alike in their first 31 characters), its functions read "does not compile" and count as not matched.
               A longer name that V4.23 only cuts to 31 characters is compared under the cut name ("name cut to 31").
  library C    Toshiba's runtime routines linked into the images (results/pairs.tsv, compiled from the 1997
               LIB/SRC at -O3 -XS -DFLOAT, cdecl).  Model: results/pairs_model_kn5000.tsv (MATCH rows).  V4.23:
               results/pairs_v423_llvm_kn5000.tsv, pairs_model.py --listings on V4.23's listings of oracle run
               2026-11-08-5-libsrc97-O3XS (MATCH rows).  Data pieces (`<member> data`) are not compiled by either
               path and are not counted.  The other option sets (run 2026-11-15-2-libsrc97-othersets: none, -Xr,
               -O3 -XS -Xr) were checked the same way on 2026-11-16 (--library-sets) and reproduce no pair that
               -O3 -XS does not.  pairs_crosscheck.py compares the V4.23 rows with pairs_check.py's asm900-object check.
               v8 has no rows of its own (it is v9's source): v9's matched ranges count for v8 where v8's ROM bytes
               equal v9's, which this script checks.

Bytes are the union of the matched address ranges (an address under two publics counts once).  "code" bytes are
the part of them that scripts/analysis/data_range_census.py calls CODE, and an image's "code" column is its census
CODE total, so `C code / code` is the share of the image's code built from C.  Census results are cached under
$TMPDIR/cc900-c-coverage/ per image, keyed by the census's own mirror fingerprint of the image's source trees and
the census script's SHA-1: a cold census of the twenty images took 7 minutes on 2026-11-16, a warm run 8 s.

RUN (from the repository root; needs `make all` and `make wsa1`: the ELFs, the git-ignored v8 / v6 / v5 reference images,
and the generated media the census assembles):

    make cc900-c-coverage                       # refreshes both pairs_* inputs, then writes the results file
    python3 -B scripts/analysis/cc900/c_build_coverage.py            # results/c_build_coverage.md only
    python3 -B scripts/analysis/cc900/c_build_coverage.py --print    # the same, to stdout, file untouched
    python3 -B scripts/analysis/cc900/c_build_coverage.py --v423-corpus DIR
        copies every firmware C file without a V4.23 check into DIR, with sources.txt / options.txt, and prints the
        oracle run command and the --record-v423-run command to file its result
    python3 -B scripts/analysis/cc900/c_build_coverage.py --record-v423-run RUN_DIR DIR
        appends to results/c_build_v423_runs.tsv one row per C file and option set that RUN_DIR compiled
    python3 -B scripts/analysis/cc900/c_build_coverage.py --library-sets
        V4.23's library listings at the other option sets: does any reproduce a pair that -O3 -XS does not?
    python3 -B scripts/analysis/cc900/c_build_coverage.py --census-json FILE
        fills the census cache from `data_range_census.py --json FILE`, which must be a run of the current tree

OUTPUT: results/c_build_coverage.md, aligned Markdown tables, deterministic (no dates; the commit dates it).
scripts/analysis/cc900/dashboard.py reads its "Per image" table at every commit that changed it.  It holds counts and
function names only, never a line of a Toshiba listing.
"""
import collections
import glob
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
MODEL = os.path.join(HERE, 'model')
RESULTS = os.path.join(HERE, 'results')
OUT = os.path.join(RESULTS, 'c_build_coverage.md')
RUNS_TSV = os.path.join(RESULTS, 'c_build_v423_runs.tsv')
PAIRS_MODEL = os.path.join(RESULTS, 'pairs_model_kn5000.tsv')
PAIRS_V423 = os.path.join(RESULTS, 'pairs_v423_llvm_kn5000.tsv')
ORACLE = os.environ.get('CC900_ORACLE', os.path.expanduser('~/compartilhado/cc900-oracle'))
TMP = os.path.join(os.environ.get('TMPDIR') or os.path.expanduser('~/compartilhado/tmp'), 'cc900-c-coverage')
sys.path.insert(0, MODEL)
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis'))

TOOLCHAINS = ['V4.23', 'model', 'LLVM']
TOOLCHAIN_TITLE = {'V4.23': 'Toshiba V4.23', 'model': 'reference model', 'LLVM': 'LLVM backend (-mcc900-compat)'}

# census key, name in results/pairs.tsv (None: no pairs; 'v9' for v8: see the docstring), firmware C tree, its ROM
# and symbols reference (None: the image has no firmware C)
IMAGES = [
    ('v10', 'maincpu v10', 'v10/maincpu', 'original_ROMs/kn5000_v10_program.rom', 'symbols/maincpu_v10_symbols_reference.txt'),
    ('v9', 'maincpu v9', 'v9/maincpu', 'original_ROMs/kn5000_v9_program.rom', 'symbols/maincpu_v9_symbols_reference.txt'),
    ('v8', 'maincpu v9', 'v9/maincpu', 'original_ROMs/kn5000_v8_program.rom', 'symbols/maincpu_v8_symbols_reference.txt'),
    ('v7', 'maincpu v7', 'v7/maincpu', 'original_ROMs/kn5000_v7_program.rom', 'symbols/maincpu_v7_symbols_reference.txt'),
    ('v6', 'maincpu v6', 'v6/maincpu', 'original_ROMs/kn5000_v6_program.rom', 'symbols/maincpu_v6_symbols_reference.txt'),
    ('v5', 'maincpu v5', 'v5/maincpu', 'original_ROMs/kn5000_v5_program.rom', 'symbols/maincpu_v5_symbols_reference.txt'),
    ('v142', 'subcpu v142', None, None, None),
    ('v141', 'subcpu v141', None, None, None),
    ('v140', 'subcpu v140', None, None, None),
    ('subboot', 'subcpu boot', None, None, None),
    ('tabledata', 'table data', None, None, None),
    ('customdata', 'custom data', None, None, None),
    ('hdae5000', 'hdae v2.06i', None, None, None),
    ('hdae_v201', 'hdae v2.01i', None, None, None),
    ('hdae_v115', 'hdae v1.15i', None, None, None),
    ('hdae_v110', 'hdae v1.10i', None, None, None),
    ('prom_a', 'wsa1 prom_a', None, None, None),
    ('prom_b', 'wsa1 prom_b', None, None, None),
    ('prom_c', 'wsa1 prom_c', None, None, None),
    ('prom_d', 'wsa1 prom_d', None, None, None),
]
from cc900_v423 import label_of                              # noqa: E402  (-O3 -XS -Xr -> O3XSXr; any flag string)
import cc900_v423                                            # noqa: E402
# the build's V4.23 cache (Makefile CC900_V423_CACHE): its listings are the V4.23 check of the C the build compiled
V423_CACHE = os.environ.get('CC900_V423_CACHE') or os.path.join(REPO, 'build', 'cc900-v423')
if not os.path.isabs(V423_CACHE):
    V423_CACHE = os.path.join(REPO, V423_CACHE)


def sha256(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()


def rel(p):
    return os.path.relpath(p, REPO)


# ---------------------------------------------------------------- census: image size, CODE bytes, CODE intervals
def census(keys):
    """{key: {'size', 'code', 'title', 'iv': [(lo, hi) ROM offsets of CODE]}} from data_range_census.py, cached"""
    import data_range_census as D
    script = hashlib.sha1(open(D.__file__, 'rb').read()).hexdigest()
    os.makedirs(TMP, exist_ok=True)
    out, todo, paths = {}, [], {}
    for img in D.IMAGES:
        if img['key'] not in keys:
            continue
        fp = D._mirror_fingerprint([os.path.join(D.ROOT, img['mirror'])] +
                                   [os.path.join(D.ROOT, x) for x in img.get('xmirrors', [])])
        # v8's reference image is a git-ignored copy; its key alone does not change with it, so its SHA-1 joins in
        romsha = hashlib.sha1(open(os.path.join(D.ROOT, img['rom']), 'rb').read()).hexdigest()
        p = os.path.join(TMP, 'census-%s-%s.json' % (img['key'], hashlib.sha1(
            (fp + script + romsha + ' '.join(img.get('defsym', []))).encode()).hexdigest()[:20]))
        paths[img['key']] = p
        if os.path.exists(p):
            out[img['key']] = json.load(open(p))
        elif SEED and img['key'] in SEED:
            out[img['key']] = SEED[img['key']]
            json.dump(SEED[img['key']], open(p, 'w'))
        else:
            todo.append(img['key'])
    import io, contextlib
    for key in todo:                                       # one image at a time, each cached as soon as it is done
        sys.stderr.write('census of %s (not cached; under a minute) ...\n' % key)
        with contextlib.redirect_stdout(io.StringIO()):
            res, recs = D.run({key}, verbose=False)
        for k, d in census_results(res, recs).items():
            json.dump(d, open(paths[k], 'w'))
            out[k] = d
    return out


SEED = {}


def census_results(res, recs):
    """data_range_census.run()'s (or its --json file's) results -> {key: {'title', 'size', 'code', 'iv'}}"""
    out = {}
    for r in res:
        if r['covered'] != r['size'] or not r['inert']:
            sys.exit('census of %s does not reconcile (%d of %d B, inert %s): no figure is quoted'
                     % (r['key'], r['covered'], r['size'], r['inert']))
        iv = sorted((x['lo'], x['hi']) for x in recs if x['image'] == r['key'] and x['grade'] == 'CODE')
        d = dict(title=r['title'], size=r['size'], code=r['totals']['CODE'], iv=merge(iv))
        assert sum(b - a for a, b in d['iv']) == d['code'], r['key']
        out[r['key']] = d
    return out


def merge(iv):
    out = []
    for a, b in sorted(iv):
        if out and a <= out[-1][1]:
            out[-1][1] = max(out[-1][1], b)
        else:
            out.append([a, b])
    return [tuple(x) for x in out]


def overlap(iv, code):
    """bytes of the intervals iv that lie in the sorted, merged intervals code"""
    import bisect
    starts = [a for a, b in code]
    n = 0
    for a, b in merge(iv):
        i = max(0, bisect.bisect_right(starts, a) - 1)
        while i < len(code) and code[i][0] < b:
            n += max(0, min(b, code[i][1]) - max(a, code[i][0]))
            i += 1
    return n


def offsets_fn(key):
    """address -> list of ROM-offset intervals, the census's own mapping (the sub-CPU payload's split included)"""
    import data_range_census as D
    img = next(i for i in D.IMAGES if i['key'] == key)
    return lambda a, b: D.clip_to_rom(a, b, img)


# ---------------------------------------------------------------- firmware C (phase 6)
def tree_includes(tree):
    """names of the functions whose generated body the tree includes"""
    pat = re.compile(rb'\.include\s+"includes/generated/cc900/([\w.]+)\.s"')
    names = set()
    for dp, dn, fn in os.walk(os.path.join(REPO, tree)):
        dn[:] = [d for d in dn if d != 'generated']
        for f in fn:
            if f.endswith('.s'):
                names.update(m.group(1).decode() for m in pat.finditer(open(os.path.join(dp, f), 'rb').read()))
    return names


BUILT_BY = ['?']


def build_compiler():
    """which compiler made the firmware-C bodies the measured build includes (their GENERATED headers): 'Toshiba
    V4.23', 'reference model', 'mixed' or 'none built'"""
    seen = set()
    for key, pname, tree, *_ in IMAGES:
        if not tree:
            continue
        for fn in tree_includes(tree):
            p = os.path.join(REPO, tree, 'includes', 'generated', 'cc900', fn + '.s')
            head = open(p, encoding='latin-1').read(600) if os.path.exists(p) else ''
            seen.add('Toshiba V4.23' if 'by Toshiba cc900 V4.23' in head else
                     'reference model' if 'by the cc900 reference model' in head else 'not built yet')
    return 'none built' if not seen else seen.pop() if len(seen) == 1 else 'mixed (%s)' % ', '.join(sorted(seen))


def listing_functions(path):
    """a thc2 listing -> {function: [lines]}, as listing.split gives them, with the section lines before each label
    dropped and a label that is not public kept inside the function before it"""
    import listing
    text = open(path, encoding='latin-1').read()
    pubs = set(re.findall(r'(?im)^\s*public\s+([._\w]+)', text))
    fs = {}
    for k, v in listing.split(text).items():
        v = v[[i for i, l in enumerate(v) if l == k + ':'][0]:]
        if k not in pubs and fs:
            fs[list(fs)[-1]] += v
        else:
            fs[k] = v
    return fs


def translate(listing_funcs, names, widths=None):
    """{name: listing lines} -> {bare name: llvm-mc lines}, every name written as its address (fn_diff.py's way),
    as cc900_firmware_c.compile_c does for the model's listing.  widths: each symbol's operand width as the listing
    declares it (cc900_firmware_c.listing_widths); a function that reaches a symbol without one is None"""
    import to_llvm
    import cc900_firmware_c as fw
    to_llvm.SPELL = None
    to_llvm.WIDTHS = widths
    funcs = {}
    for name, lines in listing_funcs.items():
        if not lines or not lines[0].endswith(':') or lines[0][:-1] != name:
            continue
        bare = name.lstrip('_.')
        try:
            body = to_llvm.translate_function(name, lines, names)
        except KeyError:
            funcs[bare] = None
            continue
        locals_ = {l[:-1] for l in lines if l.endswith(':') and not l.startswith('\t') and l[:-1] != name}
        text = []
        for l in body:
            if l in ('\t.globl %s' % bare, bare + ':'):
                continue
            for lab in locals_:
                l = re.sub(r'(?<![\w.])%s(?![\w])' % re.escape(lab), '.Lcc900_%s_%s' % (bare, lab), l)
            text.append(l)
        if any('untranslated' in l for l in text):
            funcs[bare] = None
            continue
        funcs[bare] = to_llvm.relax('\n'.join(text), fw.assembler_errors).split('\n')
    return funcs


def compare(fn, lines, rom, ref, base=0xe00000):
    """-> (length, True when the bytes equal the ROM's at fn's address), or (0, why not)"""
    import check_bytes
    if lines is None:
        return 0, 'untranslated'
    if fn not in ref:
        return 0, 'not in the symbols reference'
    try:
        mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n%s\n' % (fn, fn, '\n'.join(lines)))[fn]
    except subprocess.CalledProcessError:
        return 0, 'does not assemble'
    at = ref[fn] - base
    return len(mine), mine == rom[at:at + len(mine)]


def v423_runs():
    """{(C file, sha256, options label): (run, listing path relative to the run's out/)}"""
    out = {}
    if os.path.exists(RUNS_TSV):
        for l in open(RUNS_TSV, encoding='utf-8'):
            c = l.rstrip('\n').split('\t')
            if l.startswith('#') or len(c) < 5 or c[0] == 'c_file':
                continue
            out[(c[0], c[1], c[2])] = (c[3], c[4])
    return out


def firmware(key, tree, rom_path, sym_path):
    """[{function, file, options, built, bytes, model, V4.23, iv}] for one image's tree"""
    import check_bytes
    import cc900_firmware_c as fw
    cfiles = sorted(glob.glob(os.path.join(REPO, tree, 'cc900', '*.c')) +
                    glob.glob(os.path.join(REPO, tree, 'cc900', 'unbuilt', '*.c')))   # unbuilt: checked, not built
    if not cfiles:
        return []
    rom = open(os.path.join(REPO, rom_path), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, sym_path))
    names = fw.Names(fw.tree_values(os.path.join(REPO, tree)), ref)
    built = tree_includes(tree)
    runs = v423_runs()
    rows = []
    for path in cfiles:
        flags = fw.file_flags(path)
        label = label_of(flags)
        lm_ = fw.label_map(path)                          # a short C name (`cc900-name: C=LABEL`) is the label's
        try:
            funcs = fw.compile_c(path, names, spell=False)
        except SystemExit as ex:                          # the model refuses the file: its functions still count
            sys.stderr.write('%s: the model does not compile it: %s\n' % (rel(path), str(ex)[:200]))
            funcs = {}                                    # for V4.23, from the C's own definitions below
        # V4.23's listing of this exact text: the build's cache first (the build is the V4.23 check), else a recorded
        # oracle run (results/c_build_v423_runs.tsv)
        lp, src, v423 = None, None, {}
        st, cache_lp, _ = cc900_v423.listing(V423_CACHE, path)
        if st == 'OK':
            lp, src = cache_lp, 'cache ' + os.path.basename(os.path.dirname(cache_lp))[:12]
        elif st == 'FAILED':
            src, v423 = 'cache ' + os.path.basename(os.path.dirname(cache_lp))[:12], None
        else:
            run = runs.get((rel(path), sha256(path), label))
            if run and run[1] == 'FAILED':
                src, v423 = run[0], None                  # V4.23 does not compile this text
            elif run and os.path.exists(os.path.join(ORACLE, 'runs', run[0], 'out', run[1])):
                lp, src = os.path.join(ORACLE, 'runs', run[0], 'out', run[1]), run[0]
        if lp:
            text = open(lp, encoding='latin-1').read()
            try:                                          # the widths the listing declares, as the build reads them
                widths = fw.listing_widths(path, text)
            except SystemExit as ex:                      # the C's qualifiers disagree with the listing
                sys.stderr.write('%s: %s\n' % (rel(path), str(ex)[:200]))
                widths = {}
            v423 = translate(listing_functions(lp), names, widths)
            v423 = {lm_.get(k, k): v for k, v in v423.items()}   # (BitMapOut_PrepRender_CheckBit1)
        fnames = set(funcs) | {lm_.get(c, c) for c in fw.c_functions(path)}
        for fn in sorted(fnames):
            n, ok = compare(fn, funcs[fn], rom, ref) if fn in funcs else (0, 'the model refuses it')
            r = dict(function=fn, file=rel(path), options=flags or 'no options', built=fn in built, bytes=n,
                     model=ok is True)
            if src is None:
                r['V4.23'] = None                                 # not yet checked
            elif v423 is None:
                r['V4.23'] = 'refused'
            elif fn not in v423 and fn[:31] not in v423:
                r['V4.23'] = False
            else:                                         # V4.23 keeps 31 characters of a name (THC1-Warning-515)
                n2, ok2 = compare(fn, v423.get(fn) or v423[fn[:31]], rom, ref)
                r['V4.23'] = ok2 is True
                r['cut'] = fn not in v423
                if ok2 is True:
                    r['bytes'] = n2                       # V4.23's length: the model's may be missing or differ
            r['iv'] = [(ref[fn], ref[fn] + r['bytes'])] if fn in ref and r['bytes'] else []
            r['run'] = src
            rows.append(r)
    return rows


# ---------------------------------------------------------------- library C (Toshiba's runtime routines)
def pairs_results(path):
    """{pairs image name: [(address, length)] of the MATCH rows} of a pairs_model.py output"""
    out = collections.defaultdict(list)
    if not os.path.exists(path):
        return out
    for l in open(path, encoding='utf-8'):
        c = l.rstrip('\n').split('\t')
        if len(c) >= 6 and c[5] == 'MATCH':
            out[c[0]].append((int(c[1], 16), int(c[4]), c[2]))
    return out


def llvm_backend_results():
    """THE HOOK FOR PHASE 3b.  Once clang -mcc900-compat exists, return the same shape as pairs_results() for the
    library pairs and a {(image key, function): True} map for firmware C, from a results file that a script like
    pairs_model.py writes with clang in place of the model (e.g. results/pairs_llvm_kn5000.tsv).  Until then: none."""
    return collections.defaultdict(list), {}


# ---------------------------------------------------------------- the table
def measure():
    cen = census({k for k, *_ in IMAGES})
    pm, pv = pairs_results(PAIRS_MODEL), pairs_results(PAIRS_V423)
    pl, fl = llvm_backend_results()
    rows, fwrows = [], []
    v9rom = open(os.path.join(REPO, 'original_ROMs/kn5000_v9_program.rom'), 'rb').read()
    for key, pname, tree, rom_path, sym_path in IMAGES:
        c = cen[key]
        to_off = offsets_fn(key)

        def ivs(addr_ranges):
            out = []
            for a, b in addr_ranges:
                out += to_off(a, b)
            return merge(out)

        # firmware C
        fr = firmware(key, tree, rom_path, sym_path) if tree else []
        for r in fr:
            r['image'] = key
        fwrows += fr
        if fr:
            row = dict(image=key, category='firmware C', items=len(fr))
            for tc, ok in (('V4.23', lambda r: r['built'] and r['V4.23'] is True),
                           ('model', lambda r: r['built'] and r['model']),
                           ('LLVM', lambda r: r['built'] and fl.get((key, r['function'])))):
                iv = ivs([x for r in fr if ok(r) for x in r['iv']])
                row[tc] = (sum(b - a for a, b in iv), overlap(iv, c['iv']))
            row['unchecked'] = sum(1 for r in fr if r['V4.23'] is None)
            rows.append(row)
        # library C
        if pname:
            items = {p for p in (pm.get(pname, []) + pv.get(pname, []))}
            if items or pname in pm or pname in pv:
                row = dict(image=key, category='library C', items=len({p[2] for p in items}))
                for tc, src in (('V4.23', pv), ('model', pm), ('LLVM', pl)):
                    ranges = [(a, a + n) for a, n, _ in src.get(pname, [])]
                    if key == 'v8':                       # v9's ranges, where v8's bytes are v9's
                        rom8 = open(os.path.join(REPO, rom_path), 'rb').read()
                        ranges = [(a, b) for a, b in ranges if rom8[a - 0xe00000:b - 0xe00000] == v9rom[a - 0xe00000:b - 0xe00000]]
                    iv = ivs(ranges)
                    row[tc] = (sum(b - a for a, b in iv), overlap(iv, c['iv']))
                row['unchecked'] = 0
                rows.append(row)
    return cen, rows, fwrows


def md_table(head, rows):
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    out = ['| ' + ' | '.join(str(h).ljust(x) for h, x in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (x + 2) for x in w) + '|']
    out += ['| ' + ' | '.join(str(c).ljust(x) for c, x in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)


def pct(a, b):
    return '%.3f %%' % (100.0 * a / b) if b else '-'


def render(cen, rows, fwrows):
    L = ['# C build coverage: ROM bytes built from C, per toolchain', '',
         'Generated by `scripts/analysis/cc900/c_build_coverage.py` (its docstring defines every column; regenerate with',
         '`make cc900-c-coverage`).  Do not edit by hand.  A byte counts when the C, through that toolchain, gives exactly',
         'the ROM\'s bytes there.  "code" is the census CODE part (`data_range_census.py`).  Firmware C counts only where',
         'the image is built from it (`.include` of its generated body); library C is checked, not yet built from C.', '',
         'The measured build compiled its firmware C with: **%s** (`make` uses Toshiba V4.23 in the oracle VM;' % BUILT_BY[0],
         '`make CC900_COMPILER=model` the reference model).  The V4.23 column is the progress measure: a function is',
         'built from C only where V4.23 reproduces it (C it does not is kept in `<tree>/cc900/unbuilt/`).', '']
    # totals
    tot_size = sum(cen[k]['size'] for k, *_ in IMAGES)
    tot_code = sum(cen[k]['code'] for k, *_ in IMAGES)
    L += ['## Totals', '']
    t = []
    for tc in TOOLCHAINS:
        b = sum(r[tc][0] for r in rows)
        cb = sum(r[tc][1] for r in rows)
        fwb = sum(r[tc][0] for r in rows if r['category'] == 'firmware C')
        t.append([TOOLCHAIN_TITLE[tc], b, cb, pct(cb, tot_code), fwb, b - fwb])
    L += [md_table(['toolchain', 'bytes from C', 'code bytes from C', '% of all code', 'firmware C bytes',
                    'library C bytes'], t), '',
          'All %d images: %d bytes, %d of them census CODE.  Every version of an image counts on its own.' %
          (len(IMAGES), tot_size, tot_code), '']
    # per image
    L += ['## Per image', '']
    t = []
    for k, *_ in IMAGES:
        c, mine = cen[k], [r for r in rows if r['image'] == k]
        for r in mine:
            t.append([k, c['size'], c['code'], r['category'], r['items']] +
                     ['%d / %d' % r[tc] for tc in TOOLCHAINS] + [pct(r['model'][1], c['code']), r['unchecked']])
        if not mine:
            t.append([k, c['size'], c['code'], '-', 0, '0 / 0', '0 / 0', '0 / 0', pct(0, c['code']), 0])
    L += [md_table(['image', 'size', 'code', 'category', 'items', 'V4.23 bytes / code', 'model bytes / code',
                    'LLVM bytes / code', 'model % of code', 'V4.23 not yet checked'], t), '',
          '"items": functions (firmware C) or matched library publics (library C).  Rows with category `-` have no C',
          'found yet.', '']
    # firmware functions
    if fwrows:
        L += ['## Firmware C functions', '']
        t = []
        for r in fwrows:
            v = {None: 'not yet checked', 'refused': 'does not compile', True: 'MATCH', False: 'differs'}[r['V4.23']]
            if r.get('cut'):
                v += ' (name cut to 31)'
            t.append([r['image'], r['function'], r['file'], r['options'], r['bytes'], 'yes' if r['built'] else 'no',
                      'MATCH' if r['model'] else 'differs', v, r['run'] or '-'])
        L += [md_table(['image', 'function', 'C file', 'options', 'bytes', 'built', 'model', 'V4.23', 'V4.23 run'], t), '']
        need = sorted({(r['file'], r['options']) for r in fwrows if r['V4.23'] is None})
        if need:
            L += ['### V4.23 runs needed', '',
                  'These C files have no V4.23 listing of their current text.  `c_build_coverage.py --v423-corpus DIR` copies',
                  'them into DIR and prints the oracle run (`oracle/run_oracle.sh`) and the command that files its result.', '']
            L += [md_table(['C file', 'options'], [list(x) for x in need]), '']
    return '\n'.join(L).rstrip('\n') + '\n'


# ---------------------------------------------------------------- the V4.23 runs of firmware C
def v423_corpus(d):
    import cc900_firmware_c as fw
    d = os.path.abspath(d)
    runs = v423_runs()
    picked, labels = [], {}
    for key, pname, tree, *_ in IMAGES:
        for path in sorted(glob.glob(os.path.join(REPO, tree or '-', 'cc900', '*.c')) +
                           glob.glob(os.path.join(REPO, tree or '-', 'cc900', 'unbuilt', '*.c'))):
            label = label_of(fw.file_flags(path))
            if (rel(path), sha256(path), label) in runs or rel(path) in [p for p, _ in picked]:
                continue
            picked.append((rel(path), os.path.join(tree.split('/')[0], os.path.relpath(path, os.path.join(REPO, tree, 'cc900')))))
            labels[label] = fw.file_flags(path)
    if not picked:
        print('every firmware C file has a V4.23 listing of its current text')
        return
    os.makedirs(d, exist_ok=True)
    for src, dst in picked:
        os.makedirs(os.path.join(d, os.path.dirname(dst)), exist_ok=True)
        shutil.copyfile(os.path.join(REPO, src), os.path.join(d, dst))
    open(os.path.join(d, 'sources.txt'), 'w').write(''.join(dst + '\n' for _, dst in picked))
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (l, labels[l]) for l in sorted(labels)))
    open(os.path.join(d, 'manifest.tsv'), 'w').write(''.join('%s\t%s\n' % p for p in picked))
    print('%d C files in %s, option sets %s' % (len(picked), d, ' '.join(sorted(labels))))
    print('run:    bash scripts/analysis/cc900/oracle/run_oracle.sh p6-firmware %s %s/sources.txt '
          '%s/options.txt v423' % (d, d, d))
    print('        (it takes a free slot of the shared VM pool, oracle/vm_slot.sh; the oracle repo is committed by the '
          'coordinator)')
    print('file:   python3 -B scripts/analysis/cc900/c_build_coverage.py --record-v423-run %s/runs/<the run> %s' % (ORACLE, d))


def record_run(run_dir, d):
    import cc900_firmware_c as fw
    run = os.path.basename(os.path.normpath(run_dir))
    labels = [l.split('|')[0] for l in open(os.path.join(run_dir, 'options.txt')) if l.strip()]
    have = v423_runs()
    new = []
    for line in open(os.path.join(d, 'manifest.tsv')):
        src, dst = line.rstrip('\n').split('\t')
        h = sha256(os.path.join(d, dst))
        for label in labels:
            lp = 'v423/%s/%s.asm' % (label, dst[:-2])
            if (src, h, label) in have:
                continue
            if os.path.exists(os.path.join(run_dir, 'out', lp)):
                new.append([src, h, label, run, lp])
            elif os.path.exists(os.path.join(run_dir, 'out', lp[:-4] + '.cc.log')):
                new.append([src, h, label, run, 'FAILED'])    # V4.23 compiled it and refused (see its .cc.log)
    exists = os.path.exists(RUNS_TSV)
    with open(RUNS_TSV, 'a', encoding='utf-8') as fh:
        if not exists:
            fh.write('# V4.23 listings of firmware C (cc900 phase 6), one row per C file text and option set; read by\n'
                     '# c_build_coverage.py, written by its --record-v423-run.  The listings stay in the private oracle repo.\n'
                     'c_file\tsha256\toptions\trun\tlisting\n')
        for r in new:
            fh.write('\t'.join(r) + '\n')
    print('%d rows added to %s' % (len(new), rel(RUNS_TSV)))
    for line in open(os.path.join(d, 'manifest.tsv')):
        src, dst = line.rstrip('\n').split('\t')
        if sha256(os.path.join(REPO, src)) != sha256(os.path.join(d, dst)):
            print('note: %s changed since the corpus was made; its rows do not apply to its current text' % src)


def library_sets():
    """--library-sets: do V4.23's listings at the other option sets (run 2026-11-15-2-libsrc97-othersets) reproduce a
    library pair that results/pairs_v423_llvm_kn5000.tsv (-O3 -XS) does not?  Runs model/pairs_model.py --listings per
    set (about 1.5 min each) and prints each set's MATCH count and the pairs only it matches."""
    base = {(c[0], c[1], c[2]) for c in (l.rstrip('\n').split('\t') for l in open(PAIRS_V423)) if len(c) > 5 and c[5] == 'MATCH'}
    libcopy = os.environ.get('CC900_LIBCOPY', os.path.expanduser('~/compartilhado/tmp/cc900-corpus-libsrc97'))
    os.makedirs(TMP, exist_ok=True)
    for label in ('none', 'Xr', 'O3XSXr'):
        d = os.path.join(ORACLE, 'runs', '2026-11-15-2-libsrc97-othersets', 'out', 'v423', label, 'libsrc')
        r = subprocess.run([sys.executable, '-I', '-B', os.path.join(MODEL, 'pairs_model.py'), os.path.join(RESULTS, 'pairs.tsv'),
                            libcopy, '--listings', d], capture_output=True, text=True, check=True).stdout
        got = {(c[0], c[1], c[2]) for c in (l.split('\t') for l in r.splitlines()) if len(c) > 5 and c[5] == 'MATCH'}
        print('%-7s MATCH %d; not matched at -O3 -XS: %s' % (label, len(got), ', '.join(sorted('%s %s' % (k[0], k[2]) for k in got - base)) or 'none'))


def main():
    a = sys.argv[1:]
    if '--library-sets' in a:
        return library_sets()
    if '--v423-corpus' in a:
        return v423_corpus(a[a.index('--v423-corpus') + 1])
    if '--record-v423-run' in a:
        i = a.index('--record-v423-run')
        return record_run(a[i + 1], a[i + 2])
    if '--census-json' in a:                              # seed the cache from a --json run of THIS tree state
        j = json.load(open(a[a.index('--census-json') + 1]))
        SEED.update(census_results(j['results'], j['regions']))
    for k in [k for k in os.environ if k.startswith('CC900_') and k not in ('CC900_MODEL_CLANG', 'CC900_ORACLE')]:
        del os.environ[k]                                  # the model's defaults, as the build runs it
    BUILT_BY[0] = build_compiler()
    cen, rows, fwrows = measure()
    text = render(cen, rows, fwrows)
    if '--print' in a:
        sys.stdout.write(text)
        return
    open(OUT, 'w', encoding='utf-8').write(text)
    for line in text.split('## Per image')[0].splitlines():
        if line.startswith('| ') and 'toolchain' not in line:
            print(line)
    print('wrote %s' % rel(OUT))


if __name__ == '__main__':
    main()
