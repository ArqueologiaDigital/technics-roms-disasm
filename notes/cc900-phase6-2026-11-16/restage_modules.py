#!/usr/bin/env python3
"""Regroup v10's staged firmware C by the original C module of each function.

QUESTION ANSWERED / WHY: run 2026-11-16-55 (p6-r10) found 16 staged functions that matched as probes but differ in
their staging file.  They call a function that the same staging file DEFINES, and V4.23 compiles a call to a
function of its own file differently (it knows the callee).  In the ROM those callers reach the callee with an
absolute `call`: different modules (modules_v10.tsv, from modules_main.py).  So a staging file must hold one module's
functions only.  This rewrites every v10/maincpu/cc900-staged/<base>[_xr|_xs|_b...].c as one file per (option set,
module): <base>_m<module>[_xr|_xs].c, each with the declarations its functions use (stage_probe.py's rule); a
function no call reaches (no module) goes to <base>_m0.c.  Then port_staged.py rebuilds the other trees.
Within one group, a function also starts a new file (_b, _c ...) when the ROM reaches one of its callees
absolutely that another function of the file reaches relatively, or the reverse (fn_calls.py; needs the built v10
ELF, 2026-11-20): the file's cc900-module line would give it the wrong call form.

usage: python3 notes/cc900-phase6-2026-11-16/restage_modules.py [--dry-run]     (from the repository root)
"""
import collections, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
import staged_v423 as sv                                     # noqa: E402

SUFFIX = {'-O3 -Xr': '', '-Xr': '_xr', '-O3 -XS -Xr': '_xs'}


def norm(t):
    return ' '.join(t.split())


def main():
    dry = '--dry-run' in sys.argv
    mod = {}
    for l in open(os.path.join(HERE, 'modules_v10.tsv')):
        c = l.rstrip('\n').split('\t')
        if len(c) == 4 and c[2].isdigit():
            mod[c[1]] = int(c[2])
    # every probe function's text -> that probe's declarations (a staged function takes its own probe's, since a
    # staging file assembled from several probes can lack a prototype: run 55's 16 differences)
    # the probe that matched (probe_matches.tsv, the latest run first) is preferred over any other probe with the
    # same function text: another probe's declarations of the same names can differ (GetDiskSizeInfo, run 68)
    matched = {}
    for l in open(os.path.join(HERE, 'probe_matches.tsv')):
        c = l.rstrip('\n').split('\t')
        if len(c) == 4 and c[0] != 'function':
            matched[c[0]] = [x.split('@')[0] for x in c[3].split()]
    probe = {}                                               # stem -> (decls, {short name: comment}, {fn text})
    pdir = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
    for f in sorted(os.listdir(pdir)):
        if f.startswith('p6_') and f.endswith('.c'):
            its = sp.items(open(os.path.join(pdir, f), encoding='latin-1').read())
            names = {}
            for k, d in its:
                if k == 'name':
                    for m in re.finditer(r'cc900-name:\s*(\w+)\s*=', d):
                        names[m.group(1)] = d
                    for m in re.finditer(r'cc900-data:\s*(\w+)\s+\d', d):    # a function's switch-table place
                        names[m.group(1)] = d                                 # (stage_probe.names_fn)
            # a callee the probe DEFINES (a module neighbour that did not match) still needs a prototype in the
            # staging file, or V4.23 assumes `int f()` (run 87: GetViewInstance's struct pointer, `->box` refused)
            protos = []
            for k, d in its:
                if k == 'fn':
                    head = d[:d.index('{')].strip()
                    if re.search(r'\)\s*$', head):                      # an ANSI head
                        protos.append('extern %s;' % ' '.join(head.split()))
                    else:                                              # an old-style head: no parameter types
                        m = re.match(r'([\s\S]*?\b\w+)\s*\([\w\s,]*\)', head)
                        protos.append('extern %s();' % ' '.join(m.group(1).split()))
            probe[f[:-2]] = ([d for k, d in its if k in ('decl', 'pp')] + protos, names,
                             {norm(d) for k, d in its if k == 'fn'})
    def probe_for(label, text):
        for stem in matched.get(label, []) + sorted(probe):
            if stem in probe and norm(text) in probe[stem][2]:
                return probe[stem]
        return None
    sdir = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
    groups = collections.OrderedDict()
    src_of, old_files, missing, seen = {}, [], [], set()
    for fn in sorted(os.listdir(sdir)):
        if not fn.endswith('.c'):
            continue
        p = os.path.join(sdir, fn)
        text = open(p, encoding='latin-1').read()
        flags = sv.file_flags(p)
        src = re.search(r'Functions of (\S+\.s)', text).group(1)
        base = os.path.basename(src)[:-2]
        its = sp.items(text)
        own = [d for k, d in its if k in ('decl', 'pp')]
        lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text)}
        names = [d for k, d in its if k == 'name']
        for k, d in its:
            if k != 'fn':
                continue
            cn = sp.fn_name(d)
            label = lm.get(cn, cn)
            if label in seen:                                    # staged twice (an old-style head the skip missed)
                continue
            seen.add(label)
            key = (base, flags, mod.get(label, 0))
            nm = [c for c in names if sp.names_fn(c, cn) or sp.names_fn(c, label)]
            pr = probe_for(label, d)
            if pr is None:
                missing.append(cn); ds, pnames = own, {}
            else:
                ds, pnames = pr[0], pr[1]
            need, picked, changed = sp.idents(d), [], True
            while changed:
                changed = False
                for x in ds:
                    if x not in picked and sp.defines(x) & need:
                        picked.append(x); need |= sp.idents(x); changed = True
            # cc900-name comments of the callees and objects it uses (its own comes with it in nm)
            nm = nm + [c for n, c in pnames.items() if n in need and c not in nm]
            groups.setdefault(key, []).append((d, nm, [x for x in ds if x in picked]))
            src_of[key] = src
        old_files.append(p)
    # 2026-11-20: per function, the callees the ROM reaches relatively / absolutely (fn_calls.py, from the built
    # v10 ELF).  A file's cc900-module line is the union of its functions' relative callees, so a function that
    # calls one of them absolutely must go to another file (SePitPit1_OnSideRow4 / 5 in semenu_routines_m0.c, +5).
    rel = {}
    if os.path.exists(os.path.join(REPO, 'rebuilt_ROMs', 'kn5000_v10_program.llvm.elf')):
        import fn_calls                                      # noqa: E402
        lmap = {}
        for key, fns in groups.items():
            for d, nm, ds in fns:
                for c in nm:
                    for mm in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', c):
                        lmap[mm.group(1)] = mm.group(2)
        wanted = {}
        for key, fns in groups.items():
            for d, nm, ds in fns:
                cn = sp.fn_name(d)
                wanted[lmap.get(cn, cn)] = fn_calls.fn_callees(d, lmap)
        got = fn_calls.calls('v10', wanted)
        for key, fns in groups.items():
            for d, nm, ds in fns:
                cn = sp.fn_name(d)
                rel[d] = got.get(lmap.get(cn, cn), (set(), set()))
    else:
        print('no v10 ELF: files are not split by relative / absolute callees (run make first)')
    new = {}
    for key, fns in groups.items():
        base, flags, m = key
        files = []                                           # [(name -> decl, [decls], [functions], calls)]
        for d, nm, ds in fns:
            loc, ab = rel.get(d, (set(), set()))
            for fmap, fdecls, ffns, fc in files:
                if not any(n in fmap and fmap[n] != norm(x) for x in ds for n in sp.defines(x)) \
                        and not (ab & fc['local']) and not (loc & fc['absolute']):
                    break
            else:
                fmap, fdecls, ffns, fc = {}, [], [], {'local': set(), 'absolute': set()}
                files.append((fmap, fdecls, ffns, fc))
            fc['local'] |= loc
            fc['absolute'] |= ab
            for x in ds:
                if norm(x) not in [norm(y) for y in fdecls]:
                    fdecls.append(x)
                    for n in sp.defines(x):
                        fmap[n] = norm(x)
            ffns.append((d, nm))
        for i, (fmap, fdecls, ffns, fc) in enumerate(files):
            name = '%s_m%d%s%s.c' % (base, m, SUFFIX[flags], '' if i == 0 else '_' + 'bcdefghij'[i - 1])
            body = sp.HEADER % (src_of[key], '\n   cc900-options: %s' % flags) + '\n' + '\n'.join(fdecls) + '\n\n' + \
                '\n'.join('\n'.join(nm + [d]) + '\n' for d, nm in ffns)
            new[name] = body
    print('%d staged files -> %d module files; %d functions without a probe source: %s'
          % (len(old_files), len(new), len(missing), ' '.join(missing)))
    if dry:
        return
    # Nothing is deleted here (owner's rule, 2026-11-16: removals only as standalone commands with literal paths):
    # files whose names the new grouping no longer produces are listed, for `git rm -- <path>` by hand.
    for n, body in new.items():
        open(os.path.join(sdir, n), 'w', encoding='latin-1').write(body)
    for p in old_files:
        if os.path.basename(p) not in new:
            print('obsolete, remove by hand: %s' % os.path.relpath(p, REPO))


if __name__ == '__main__':
    main()
