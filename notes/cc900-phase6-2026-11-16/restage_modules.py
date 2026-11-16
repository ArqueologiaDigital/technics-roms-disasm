#!/usr/bin/env python3
"""Regroup v10's staged firmware C by the original C module of each function.

QUESTION ANSWERED / WHY: run 2026-11-16-55 (p6-r10) found 16 staged functions that matched as probes but differ in
their staging file.  They call a function that the same staging file DEFINES, and V4.23 compiles a call to a
function of its own file differently (it knows the callee).  In the ROM those callers reach the callee with an
absolute `call`: different modules (modules_v10.tsv, from modules_main.py).  So a staging file must hold one module's
functions only.  This rewrites every v10/maincpu/cc900-staged/<base>[_xr|_xs|_b...].c as one file per (option set,
module): <base>_m<module>[_xr|_xs].c, each with the declarations its functions use (stage_probe.py's rule); a
function no call reaches (no module) goes to <base>_m0.c.  Then port_staged.py rebuilds the other trees.

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
    probe_decls = {}
    pdir = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
    for f in sorted(os.listdir(pdir)):
        if f.startswith('p6_') and f.endswith('.c'):
            its = sp.items(open(os.path.join(pdir, f), encoding='latin-1').read())
            ds = [d for k, d in its if k in ('decl', 'pp')]
            for k, d in its:
                if k == 'fn':
                    probe_decls.setdefault(norm(d), ds)
    sdir = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
    groups = collections.OrderedDict()
    src_of, old_files, missing = {}, [], []
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
            key = (base, flags, mod.get(label, 0))
            nm = [c for c in names if re.search(r'cc900-name:\s*%s\s*=' % re.escape(cn), c)]
            ds = probe_decls.get(norm(d))
            if ds is None:
                missing.append(cn); ds = own
            need, picked, changed = sp.idents(d), [], True
            while changed:
                changed = False
                for x in ds:
                    if x not in picked and sp.defines(x) & need:
                        picked.append(x); need |= sp.idents(x); changed = True
            groups.setdefault(key, []).append((d, nm, [x for x in ds if x in picked]))
            src_of[key] = src
        old_files.append(p)
    new = {}
    for key, fns in groups.items():
        base, flags, m = key
        files = []                                           # [(name -> decl, [decls], [functions])]
        for d, nm, ds in fns:
            for fmap, fdecls, ffns in files:
                if not any(n in fmap and fmap[n] != norm(x) for x in ds for n in sp.defines(x)):
                    break
            else:
                fmap, fdecls, ffns = {}, [], []
                files.append((fmap, fdecls, ffns))
            for x in ds:
                if norm(x) not in [norm(y) for y in fdecls]:
                    fdecls.append(x)
                    for n in sp.defines(x):
                        fmap[n] = norm(x)
            ffns.append((d, nm))
        for i, (fmap, fdecls, ffns) in enumerate(files):
            name = '%s_m%d%s%s.c' % (base, m, SUFFIX[flags], '' if i == 0 else '_' + 'bcdefghij'[i - 1])
            body = sp.HEADER % (src_of[key], '\n   cc900-options: %s' % flags) + '\n' + '\n'.join(fdecls) + '\n\n' + \
                '\n'.join('\n'.join(nm + [d]) + '\n' for d, nm in ffns)
            new[name] = body
    print('%d staged files -> %d module files; %d functions without a probe source: %s'
          % (len(old_files), len(new), len(missing), ' '.join(missing)))
    if dry:
        return
    for p in old_files:                                      # this script's own outputs replace them
        assert os.path.realpath(p).startswith(os.path.realpath(sdir) + os.sep) and p.endswith('.c')
        os.remove(p)
    for n, body in new.items():
        open(os.path.join(sdir, n), 'w', encoding='latin-1').write(body)


if __name__ == '__main__':
    main()
