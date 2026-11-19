#!/usr/bin/env python3
"""Which v2.06i functions built from C (hdae5000/cc900/*.c) does V4.23 reproduce in the older HD-AE5000 images too,
with each older tree's OWN object ids?  Stage them per tree.

QUESTION ANSWERED (2026-11-19): until then the older trees' cc900/hdae_ids.h was a copy of v2.06i's, so every
`OBJ_*` name in ported C carried a v2.06i object id; the older images number their UI objects differently (the
ui tree differs), and port_staged.py could only port functions that name no object.  With each tree's header
written by gen_ids_header.py from that tree's own ELF, run 2026-11-19-14-hd-r61-ids-ports compiled the v2.06i
C once per older tree (the C files laid out as <tree>/cc900-staged/ with the tree's header beside them) and this
checks that run, per older image, and writes <tree>/cc900-staged/<stem>.c with the functions of
hdae5000/cc900/<stem>.c that MATCH there and are not built in the tree yet -- plus, when the tree already has a
cc900/<stem>.c, every function that file builds, so that promote_hd.py (which rewrites cc900/<stem>.c from the
staged file) keeps them.  A function built in the tree from a C file of another name is left out.  It also copies
the tree's cc900/hdae_ids.h and hdae_ws.h into its cc900-staged/ (hd_v423.py --corpus reads the header beside the
C first), and lists any built function of a same-named file that does not match in the run (it must be fixed in
the staged copy by hand before the staged run).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/port_built.py --layout OUT [--remap]
        writes OUT/<tree>/cc900-staged/<stem>.c, the C laid out per older tree with its headers, for
        `hd_v423.py --corpus DIR Xr OUT/*/cc900-staged/*.c`.  --remap (2026-11-19, second round): each ram_<hex>
        name (a RAM cell, or a string whose label is longer than cc900's 31 characters) is moved to the older
        tree's address of the label at that v2.06i address (labels and .equ values from the trees' ELFs), else of
        the nearest label below it plus the same distance; prints per tree how many cells each way found.
        --extra TSV (with --remap): learn_remap.py's table of addresses read from near misses, for the cells
        neither label rule moves (keyed by the v2.06i address), and to correct a nearest-label guess (keyed by
        the guessed address the run wrote).
    python3 -B notes/cc900-c-hdae5000-2026-11-16/port_built.py RUN_DIR [--dry-run] [--remap]
        RUN_DIR: an oracle run that compiled hdae5000/cc900/*.c as <tree>/<stem>.c (corpus directory per tree) with
        each tree's own header (--layout); their text must not have changed since.  --remap: the run compiled the
        remapped layout; the staged text is read from it ($TMPDIR/cc900-tab/lane_hd/port_built/<tree>/, written by
        the --layout --remap call before the run).
Run from the repository root with $TMPDIR set.  The staged files are then rechecked and recorded by a run of their
own (hd_v423.py --check RUN --dir TREE --image IMG --record).
"""
import os, re, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_from_probe as sp                                # noqa: E402

PORTS = [('v2.01i', 'hdae5000_v2_01i'), ('v1.15i', 'hdae5000_v1_15i'), ('v1.10i', 'hdae5000_v1_10i')]
INC = re.compile(rb'^([A-Za-z_]\w*):\s*\.include\s+"includes/generated/cc900/')
NAME_RE = re.compile(r'cc900-name:\s*(\w+)\s*=\s*(\w+)')


def built(tree):
    """{label} of the functions TREE builds from C (its hand source's `.include` of generated cc900 bodies)"""
    out = set()
    for f in os.listdir(os.path.join(REPO, tree)):
        if f.endswith('.s'):
            for l in open(os.path.join(REPO, tree, f), 'rb'):
                m = INC.match(l)
                if m and b'(cc900-data' not in l:
                    out.add(m.group(1).decode())
    return out


def labels_of(path):
    """{C name: tree label} of the functions a C file defines"""
    text = open(path, encoding='latin-1').read()
    lab = dict(NAME_RE.findall(text))
    return {n: lab.get(n, n) for k, n, _ in sp.split(text) if k == 'fn'}


def matches(run, image, tree, stems):
    """{(file stem, C name)} that MATCH exactly in IMAGE (calr matches are left out)"""
    tsv = os.path.join(os.environ['TMPDIR'], 'port_built_%s.tsv' % image)
    cmd = [sys.executable, '-B', os.path.join(HERE, 'hd_v423.py'), '--check', run, '--image', image, '--dir', tree,
           '--tsv', tsv]
    for s in stems:
        cmd += ['--csrc', '%s=%s' % (s, os.path.join(REPO, 'hdae5000', 'cc900', s + '.c'))]
    subprocess.run(cmd, cwd=REPO, capture_output=True, check=True)
    ok = set()
    for l in open(tsv).read().split('\n')[1:]:
        f = l.split('\t')
        if len(f) == 5 and f[4] == 'MATCH':
            stem, _, cname = f[0].partition(':')
            ok.add((stem, cname or f[2]))
    os.remove(tsv)
    return ok


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    if not os.environ.get('TMPDIR'):             # house rule: scratch goes under $TMPDIR, never /tmp
        sys.exit('port_built.py: TMPDIR is not set (scratch goes to $TMPDIR, never /tmp)')
    remap = '--remap' in sys.argv
    if sys.argv[1] == '--layout':
        layout(sys.argv[2], remap, sys.argv[sys.argv.index('--extra') + 1] if '--extra' in sys.argv else None)
        return
    run, dry = sys.argv[1], '--dry-run' in sys.argv
    src_dir = os.path.join(REPO, 'hdae5000', 'cc900')
    stems = sorted(f[:-2] for f in os.listdir(src_dir) if f.endswith('.c'))
    for image, tree in PORTS:
        ok = matches(run, image, tree, stems)
        have = built(tree)
        out_dir = os.path.join(REPO, tree, 'cc900-staged')
        n_new = 0
        src = remapped_dir(tree) if remap else src_dir
        for stem in stems:
            fns = labels_of(os.path.join(src, stem + '.c'))
            # a file named after v2.06i's own hand source (hd-ae5000_v2_06i.s) is the older tree's file named
            # after ITS hand source (hd-ae5000_v2_01i.s ...)
            ostem = stem.replace('hd-ae5000_v2_06i', 'hd-ae5000_' + tree.split('_', 1)[1])
            same = os.path.join(REPO, tree, 'cc900', ostem + '.c')
            kept_old = set(labels_of(same).values()) if os.path.exists(same) else set()
            keep, broken = set(), []
            for cname, lab in fns.items():
                if lab in kept_old:
                    keep.add(cname)
                    if (stem, cname) not in ok:
                        broken.append(lab)
                elif (stem, cname) in ok and lab not in have:
                    keep.add(cname)
            new = sorted(fns[c] for c in keep if fns[c] not in kept_old)
            if not new:
                continue
            n_new += len(new)
            print('%s %s.c: %d new %s%s' % (tree, ostem, len(new), ' '.join(new),
                                           ('; BUILT, NOT MATCHING: ' + ' '.join(broken)) if broken else ''))
            if dry:
                continue
            os.makedirs(out_dir, exist_ok=True)
            for h in ('hdae_ids.h', 'hdae_ws.h'):
                shutil.copyfile(os.path.join(REPO, tree, 'cc900', h), os.path.join(out_dir, h))
            what = ('%s: the functions of hdae5000/cc900/%s.c that V4.23 reproduces in HD-AE5000 %s with the tree\'s '
                    'own object ids%s (port_built.py).' % (tree, stem, image,
                                                            ' and ram_ addresses' if remap else ''))
            sys.argv = ['x', os.path.join(src, stem + '.c'), os.path.join(out_dir, ostem + '.c'), what] + sorted(keep)
            sp.main()
        print('%s: %d new functions' % (tree, n_new))


RAM_RE = re.compile(r'\bram_([0-9a-fA-F]{6})\b')
APFUNC_RE = re.compile(r'^#define (APFUNC_\w+) (0x[0-9a-fA-F]+)L', re.M)
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')


def symbols(tree):
    """({name: address}, {address: [names]}) of a tree's built ELF, code labels and absolute values both"""
    elf = os.path.join(REPO, 'rebuilt_ROMs', 'hd-ae5000_%s.llvm.elf' % ('v2_06i' if tree == 'hdae5000' else
                                                                          tree.split('_', 1)[1]))
    out = subprocess.run([NM, '--defined-only', elf], capture_output=True, text=True, check=True).stdout
    by_name, by_addr = {}, {}
    for l in out.splitlines():
        f = l.split()
        if len(f) == 3 and f[1] in 'tTaA' and not f[2].startswith('.'):
            by_name[f[2]] = int(f[0], 16)
            by_addr.setdefault(int(f[0], 16), []).append(f[2])
    return by_name, by_addr


def remap_text(text, old_names, old_addrs, new_names, log, extra=None):
    """TEXT with each ram_<hex> of a v2.06i address moved to the older tree's: by a label at that address that the
    tree also defines (all such labels agreeing), else by the nearest label below it (within 256 bytes) plus the
    same distance.  A cell neither finds is left as it is; LOG collects (old, new, how)."""
    below = sorted(a for a in old_addrs if 0x200000 <= a < 0x300000)

    def one(m):
        a = int(m.group(1), 16)
        cand = {new_names[n] for n in old_addrs.get(a, []) if n in new_names}
        how = 'label'
        if len(cand) != 1:
            import bisect
            i = bisect.bisect_right(below, a) - 1
            cand, how = set(), 'label+'
            while i >= 0 and a - below[i] < 256 and not cand:
                cand = {new_names[n] + a - below[i] for n in old_addrs[below[i]] if n in new_names}
                i -= 1
            if len(cand) != 1:
                # learn_remap.py's table, read from the near misses of a run of this remapped layout: only for a
                # cell no label moves, which that run therefore spelled with its v2.06i address
                if extra and a in extra:
                    log.append((a, extra[a], 'learned'))
                    return 'ram_%06x' % extra[a]
                log.append((a, None, 'unmapped'))
                return m.group(0)
        b = cand.pop()
        if how == 'label+' and extra and b in extra:
            # the nearest-label guess put the cell at B, and a near miss of a run of this layout showed the ROM
            # at extra[B] there (learn_remap.py keys such a pair by the address the run wrote)
            log.append((a, extra[b], 'learned+'))
            return 'ram_%06x' % extra[b]
        log.append((a, b, how))
        return 'ram_%06x' % b

    def apfunc(m):
        """a C file's own `#define APFUNC_<X> 0x...L`: the tree's NAKA_APFUNC_<X> (each version numbers its
        application functions, hdae5000_ui_tree.s; 2026-11-19)"""
        b = new_names.get('NAKA_' + m.group(1))
        if b is None:
            log.append((int(m.group(2), 16), None, 'apfunc-unmapped'))
            return m.group(0)
        log.append((int(m.group(2), 16), b, 'apfunc'))
        return '#define %s 0x%08xL' % (m.group(1), b)
    return APFUNC_RE.sub(apfunc, RAM_RE.sub(one, text))


def remapped_dir(tree):
    return os.path.join(os.environ['TMPDIR'], 'cc900-tab', 'lane_hd', 'port_built', tree)


def learned(path, tree):
    """{v2.06i address: tree address} of learn_remap.py's table for TREE"""
    out = {}
    for l in open(path) if path else []:
        f = l.rstrip('\n').split('\t')
        if len(f) >= 3 and f[0] == tree:
            out[int(f[1], 16)] = int(f[2], 16)
    return out


def layout(out, remap, extra_path=None):
    """OUT/<tree>/cc900-staged/<stem>.c for each older tree: hdae5000/cc900/*.c (ram_ addresses remapped with
    --remap) with the tree's own headers beside them, the layout an oracle corpus is made from
    (hd_v423.py --corpus DIR Xr OUT/*/cc900-staged/*.c); with --remap the same text goes to remapped_dir(tree),
    where the staging step reads it"""
    src_dir = os.path.join(REPO, 'hdae5000', 'cc900')
    old_names, old_addrs = symbols('hdae5000')
    for image, tree in PORTS:
        new_names, _ = symbols(tree)
        extra = learned(extra_path, tree)
        dirs =[os.path.join(out, tree, 'cc900-staged')] + ([remapped_dir(tree)] if remap else [])
        for d in dirs:
            os.makedirs(d, exist_ok=True)
            for h in ('hdae_ids.h', 'hdae_ws.h'):
                shutil.copyfile(os.path.join(REPO, tree, 'cc900', h), os.path.join(d, h))
        log = []
        for f in sorted(os.listdir(src_dir)):
            if f.endswith('.c'):
                text = open(os.path.join(src_dir, f), encoding='latin-1').read()
                if remap:
                    text = remap_text(text, old_names, old_addrs, new_names, log, extra)
                for d in dirs:
                    open(os.path.join(d, f), 'w', encoding='latin-1').write(text)
        cells = {}
        for a, b, how in log:
            cells[(a, b, how)] = 1
        kinds = {}
        for a, b, how in cells:
            kinds[how] = kinds.get(how, 0) + 1
        moved = sum(1 for a, b, how in cells if b is not None and a != b)
        print('%s: ram_ cells %s, %d of them at another address' % (
            tree, ', '.join('%s %d' % kv for kv in sorted(kinds.items())), moved))


if __name__ == '__main__':
    main()
