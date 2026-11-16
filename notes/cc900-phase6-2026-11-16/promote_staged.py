#!/usr/bin/env python3
"""Move every tree's staged firmware C into the build, in one step, once `make` compiles firmware C with V4.23.

QUESTION ANSWERED / WHY: <tree>/maincpu/cc900-staged/*.c holds C that V4.23 reproduces (staged_v423.tsv) but that
the model-built `make` could not build.  After the V4.23 build lands, each staged file moves into <tree>/cc900/:
- if cc900/ has no file of that name, the staged file moves there as it is (its header says "STAGED"; the line is
  rewritten to say the C is built by V4.23);
- if it has one with the same option set, the staged declarations it lacks and the staged functions are appended;
- if it has one with another option set, the staged file goes to cc900/<name>_<label>.c instead (e.g. _o3xr).
Then scripts/tools/cc900_splice.py splices every moved function into its hand source, with --symbols (inner labels)
and --sizes staged_v423.tsv (the V4.23 sizes per tree: no reference model needed).  The staged files are removed
only by hand afterwards (one literal path per rm), once `make gate` passes.

usage: python3 notes/cc900-phase6-2026-11-16/promote_staged.py [--dry-run] [TREE ...]    (default: all five trees)
Run from the repository root; check with `make gate` and `staged_v423.py`-style V4.23 checks of cc900/ afterwards.
"""
import os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
import staged_v423 as sv                                     # noqa: E402

TREES = {'v10': 'v10', 'v9': 'v9', 'v7': 'v7', 'v6': 'v6', 'v5': 'v5'}
SYMREF = 'symbols/maincpu_%s_symbols_reference.txt'


BUILT_DEFAULT = '-O3 -Xr'      # the V4.23 build's default for a cc900/ file without `cc900-options:` (lane_vmb)


def built_flags(path):
    m = sv.OPT_RE.search(open(path, 'rb').read())
    return ' '.join(m.group(1).decode().split()) if m else BUILT_DEFAULT


def tree_functions(cdir, skip=None):
    """{function label: C file} over a tree's cc900/*.c (two files must not define the same function)"""
    out = {}
    for f in sorted(os.listdir(cdir)) if os.path.isdir(cdir) else []:
        p = os.path.join(cdir, f)
        if f.endswith('.c') and p != skip:
            t = open(p, encoding='latin-1').read()
            lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t)}
            for k, d in sp.items(t):
                if k == 'fn':
                    out[lm.get(sp.fn_name(d), sp.fn_name(d))] = f
    return out


def main():
    a = sys.argv[1:]
    dry = '--dry-run' in a
    trees = [x for x in a if not x.startswith('--')] or list(TREES)
    trees = [x for x in trees if x in TREES]
    ledger = os.path.join(HERE, 'staged_v423.tsv')
    # --checked-only: promote a staged file only when staged_v423.tsv holds V4.23 rows for its CURRENT text (same
    # SHA-256) and every one of them is a MATCH; the others wait for the next check
    ok = None
    if '--checked-only' in a:
        rows = {}
        for l in open(ledger):
            c = l.rstrip('\n').split('\t')
            if len(c) >= 8 and c[0] in TREES:
                rows.setdefault((c[0], c[1], c[2]), []).append(c[7])
        ok = {k for k, v in rows.items() if v and all(x == 'MATCH' for x in v)}
    for t in trees:
        sdir = os.path.join(REPO, t, 'maincpu', 'cc900-staged')
        cdir = os.path.join(REPO, t, 'maincpu', 'cc900')
        for fn in sorted(os.listdir(sdir)) if os.path.isdir(sdir) else []:
            if not fn.endswith('.c'):
                continue
            sp_path = os.path.join(sdir, fn)
            text = open(sp_path, encoding='latin-1').read()
            if ok is not None and (t, os.path.relpath(sp_path, REPO), sv.sha256(sp_path)) not in ok:
                print('%s: %s not checked in its current text: left staged' % (t, fn))
                continue
            flags = sv.file_flags(sp_path)
            dst = os.path.join(cdir, fn)
            if os.path.exists(dst) and built_flags(dst) != flags:
                dst = os.path.join(cdir, fn[:-2] + '_' + sv.LABEL_OF_FLAGS[flags].lower() + '.c')
            have = tree_functions(cdir)
            lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text)}
            dup = [lm.get(sp.fn_name(d), sp.fn_name(d)) for k, d in sp.items(text)
                   if k == 'fn' and lm.get(sp.fn_name(d), sp.fn_name(d)) in have]
            nfn = sum(1 for k, _ in sp.items(text) if k == 'fn')
            if dup and len(dup) == nfn and all(have[d] == os.path.basename(dst) or True for d in dup):
                print('%s: %s already promoted' % (t, fn))  # a re-run after a stop
                continue
            if dup:
                sys.exit('%s: %s already defined in cc900/ (%s)' % (sp_path, ', '.join(dup), ', '.join(sorted(set(have[d] for d in dup)))))
            if os.path.exists(dst):                       # a name the built file declares otherwise: a sibling file
                prev = {}
                for k, d in sp.items(open(dst, encoding='latin-1').read()):
                    if k in ('decl', 'pp'):
                        for n in sp.defines(d):
                            prev[n] = d
                if any(n in prev and prev[n] != d for k, d in sp.items(text) if k in ('decl', 'pp') for n in sp.defines(d)):
                    for c in 'bcdefgh':
                        alt = dst[:-2] + '_' + c + '.c'
                        if not os.path.exists(alt):
                            print('   %s declares a staged name otherwise: %s instead' % (os.path.basename(dst), os.path.basename(alt)))
                            dst = alt
                            break
            if os.path.exists(dst):
                old = open(dst, encoding='latin-1').read()
                if built_flags(dst) != flags:
                    sys.exit('%s: option sets differ from %s' % (dst, sp_path))
                items = sp.items(text)
                declared = set()
                for k, d in sp.items(old):
                    if k in ('decl', 'pp'):
                        declared |= sp.defines(d)
                # a name the built file already declares keeps the built declaration (its qualifier is the build's)
                add = [d for k, d in items if k in ('decl', 'pp') and d not in old and not (sp.defines(d) & declared)]
                for k, d in items:
                    if k in ('decl', 'pp') and d not in old and sp.defines(d) & declared:
                        print('   note: %s keeps its declaration in %s, not the staged %r: check with V4.23'
                              % (', '.join(sorted(sp.defines(d) & declared)), os.path.basename(dst), d))
                body = [d for k, d in items if k in ('fn', 'name')]
                new = old.rstrip('\n') + '\n\n' + '\n'.join(add) + ('\n\n' if add else '') + '\n'.join(body) + '\n'
                what = 'append %d functions to' % sum(1 for k, _ in items if k == 'fn')
            else:
                new = text.replace('Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions\' ROM bytes\n'
                                   '   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.',
                                   'Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function\n'
                                   '   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).')
                what = 'create'
            print('%s: %s %s' % (t, what, os.path.relpath(dst, REPO)))
            if dry:
                continue
            open(dst, 'w', encoding='latin-1').write(new)
            r = subprocess.run([sys.executable, os.path.join(REPO, 'scripts', 'tools', 'cc900_splice.py'),
                                os.path.join(t, 'maincpu'), os.path.relpath(dst, REPO), '--symbols', SYMREF % t,
                                '--sizes', ledger], capture_output=True, text=True, cwd=REPO)
            print('   ' + (r.stdout + r.stderr).strip().replace('\n', '\n   '))
            if r.returncode:
                sys.exit('stopped: the splice failed')


if __name__ == '__main__':
    main()
