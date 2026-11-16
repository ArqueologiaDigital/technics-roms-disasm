#!/usr/bin/env python3
"""Move the HD-AE5000 trees' staged C (<tree>/cc900-staged/) into the build (<tree>/cc900/) and splice it.

QUESTION ANSWERED / WHY: since b40ae3a4c `make` compiles <tree>/cc900/*.c for the four HD-AE5000 trees with V4.23.
The splice (scripts/tools/cc900_splice.py) takes one C file per HAND SOURCE (its first comment says "Functions of
<file>.s"), while the staged files are one per original module.  For each tree and staged file this:
  1. groups the file's functions by the hand source that defines their label (a module can span two);
  2. writes <tree>/cc900/<staged stem>.c, or <staged stem>_<hand stem>.c when the module spans several, with the
     staged declarations, cc900-name / cc900-module / cc900-options lines (stage_from_probe.py) and a first line
     "Functions of <hand>.s";
  3. runs the splice with --symbols and --sizes staged_v423.tsv as a dry run; a function it refuses is HELD BACK
     (dropped from the C, listed with the splice's reason) and the file is rewritten, until the dry run passes;
  4. splices for real.
A function is promoted only when its row in staged_v423.tsv is MATCH for that tree.  The staged files are left in
place; remove them (git rm, explicit paths) after `make gate` passes.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/promote_hd.py [--dry-run] [--hold LABEL[,LABEL...]] [TREE ...]
        --hold: labels not to promote (e.g. a function the build cannot yet compile)
        TREE: hdae5000, hdae5000_v2_01i, hdae5000_v1_15i, hdae5000_v1_10i (default: all four)
Prints what it promoted and what it held back.  Run from the repository root.
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_from_probe as sp                                # noqa: E402

TREES = ['hdae5000', 'hdae5000_v2_01i', 'hdae5000_v1_15i', 'hdae5000_v1_10i']
LEDGER = os.path.join(HERE, 'staged_v423.tsv')
NAME_RE = re.compile(r'cc900-name:\s*(\w+)\s*=\s*(\w+)')


def matched(tree):
    out = set()
    for l in open(LEDGER):
        f = l.rstrip('\n').split('\t')
        if len(f) == 8 and f[0] == tree and f[7] == 'MATCH':
            out.add(f[5])
    return out


def hand_sources(tree):
    """{label: hand source file name} for the column-0 labels of TREE/*.s"""
    out = {}
    d = os.path.join(REPO, tree)
    for f in sorted(os.listdir(d)):
        if f.endswith('.s'):
            for l in open(os.path.join(d, f), 'rb'):
                m = re.match(rb'^([A-Za-z_]\w*):', l)
                if m:
                    out.setdefault(m.group(1).decode(), f)
    return out


def write(tree, staged, out, hand, keep):
    sys.argv = ['x', staged, out, 'Functions of %s.  (%s)' % (hand, os.path.basename(staged))] + sorted(keep)
    sp.main()
    t = open(out, encoding='latin-1').read()
    t = t.replace("   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes\n"
                  "   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from %s." % os.path.basename(staged),
                  "   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/%s (checked in\n"
                  "   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv)." % os.path.basename(staged))
    open(out, 'w', encoding='latin-1').write(t)


def splice(tree, cfile, dry):
    cmd = [sys.executable, '-B', os.path.join(REPO, 'scripts', 'tools', 'cc900_splice.py'), tree, cfile,
           '--symbols', os.path.join('symbols', '%s_symbols_reference.txt' % tree), '--sizes', LEDGER]
    if dry:
        cmd.append('--dry-run')
    return subprocess.run(cmd, cwd=REPO, capture_output=True, text=True)


def remove_generated(path, cdir):
    """remove a C file this script wrote, only inside TREE/cc900/ and never that directory itself"""
    path, cdir = os.path.realpath(path), os.path.realpath(cdir)
    assert os.path.dirname(path) == cdir and path != cdir and path.endswith('.c'), path
    os.remove(path)


def main():
    a = sys.argv[1:]
    dry = '--dry-run' in a
    hold = set(a[a.index('--hold') + 1].split(',')) if '--hold' in a else set()
    skip = {a.index('--hold') + 1} if '--hold' in a else set()
    trees = [t for i, t in enumerate(a) if not t.startswith('--') and i not in skip] or TREES
    for t in trees:
        if t not in TREES:
            sys.exit('unknown tree %s' % t)
    held = []
    for tree in trees:
        ok = matched(tree)
        hs = hand_sources(tree)
        sdir = os.path.join(REPO, tree, 'cc900-staged')
        cdir = os.path.join(REPO, tree, 'cc900')
        os.makedirs(cdir, exist_ok=True)
        for f in sorted(os.listdir(sdir)):
            if not f.endswith('.c'):
                continue
            staged = os.path.join(sdir, f)
            text = open(staged, encoding='latin-1').read()
            label = dict(NAME_RE.findall(text))
            groups = {}
            for kind, name, _ in sp.split(text):
                if kind != 'fn':
                    continue
                lab = label.get(name, name)
                if lab not in ok:
                    held.append((tree, lab, 'not MATCH in staged_v423.tsv'))
                    continue
                if lab in hold:
                    held.append((tree, lab, 'held by --hold'))
                    continue
                groups.setdefault(hs.get(lab, '?'), set()).add(name)
            for hand, keep in sorted(groups.items()):
                if hand == '?':
                    held += [(tree, label.get(n, n), 'no hand source defines the label') for n in keep]
                    continue
                stem = f[:-2] if len(groups) == 1 else '%s_%s' % (f[:-2], hand[:-2].replace('hdae5000_', ''))
                out = os.path.join(cdir, stem + '.c')
                rel = os.path.relpath(out, os.path.join(REPO, tree))
                while keep:
                    write(tree, staged, out, hand, keep)
                    r = splice(tree, os.path.relpath(out, REPO), True)
                    if r.returncode == 0:
                        break
                    msg = (r.stderr or r.stdout).strip().split('\n')[-1]
                    bad = [n for n in keep if label.get(n, n) in msg or n in msg]
                    if not bad:
                        held += [(tree, label.get(n, n), 'splice: ' + msg[:160]) for n in keep]
                        keep = set()
                        break
                    for n in bad:
                        held.append((tree, label.get(n, n), 'splice: ' + msg[:160]))
                        keep.discard(n)
                if not keep:
                    if os.path.exists(out):
                        remove_generated(out, cdir)
                    continue
                if not dry:
                    r = splice(tree, os.path.relpath(out, REPO), False)
                    if r.returncode != 0:
                        sys.exit('%s: splice failed after a clean dry run: %s' % (out, r.stderr[-300:]))
                print('%s: %s (%d functions, from %s)' % (tree, rel, len(keep), f))
                if dry:
                    remove_generated(out, cdir)
    for t, lab, why in held:
        print('HELD %s %s: %s' % (t, lab, why))


if __name__ == '__main__':
    main()
