#!/usr/bin/env python3
"""Which Toshiba C-runtime library routines are in our ROM images, and under which of our labels?

usage: python3 -I xref_runtime.py OUT.tsv
Reads three builds of Toshiba's runtime (paths below; override with TOSHIBA_V423 / TOSHIBA_IDE / TOSHIBA_V110): the
1998 V4.23 compiler's c900ml.lib (members assembled 1997-05-26), the 2003 kit-CD IDE's and the 2008 v1.10's.  It searches every
image listed in IMAGES with lib_match.py's masked search, keeps a piece only when it has >= 6 distinct known byte
values and at most 4 hits in an image (fill and tiny tables otherwise match everywhere), and names each hit from the
image's linked ELF (llvm-nm): the label at that address, else nearest-label+offset.  The bytes searched are the
ELF's own PT_LOAD segments (an executable segment of the byte-identical rebuild), so every address is the
linked address; the reference image named beside it is what `make gate` proves those bytes equal.  Writes one TSV row per
(image, address, piece) and prints a summary grouped by image and address: which library versions match.
"""
import os, subprocess, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ieee695, lib_match

H = os.path.expanduser('~/compartilhado')
def _root():
    here = os.path.dirname(os.path.abspath(__file__))
    for up in (os.path.join(here, '..', '..'), os.path.join(H, 'technics-roms-disasm')):
        if os.path.exists(os.path.join(up, 'original_ROMs')): return os.path.abspath(up)
    raise SystemExit('technics-roms-disasm not found; set TECHNICS_ROOT')
R = os.environ.get('TECHNICS_ROOT') or _root()   # the repository: two levels above notes/<topic>/, or the share's
V110 = os.environ.get('TOSHIBA_V110', H + '/upstream_repos/file_archive/archive.org/ToshibaTLCS900CompilerV1.10/unpacked/msi/install-1033/TOSHIBA/T900/lib')
IDE = os.environ.get('TOSHIBA_IDE', H + '/upstream_repos/file_archive/github.com/colinoflynn/Toshiba-TLCS-900-L-Resources/unpacked/toshiba-ide/install-1033/Toshiba/IDE/T900SK/lib')
V423 = os.environ.get('TOSHIBA_V423', H + '/upstream_repos/file_archive/devrs.com/ngpcbins/unpacked/zip/T900/LIB')
LIBS = [('V4.23 ml', V423 + '/C900ML.LIB'),
        ('v1.10 ml', V110 + '/c900ml.lib'), ('v1.10 pic', V110 + '/c900pic.lib'),
        ('IDE ml', IDE + '/c900ml.lib'), ('IDE pic', IDE + '/pic/c900pic.lib')]
O = R + '/original_ROMs/'; RB = R + '/rebuilt_ROMs/'; W = R + '/wsa1/'
IMAGES = [  # name, reference image, linked ELF of the byte-identical rebuild
    ('maincpu v10', O + 'kn5000_v10_program.rom', RB + 'kn5000_v10_program.llvm.elf'),
    ('maincpu v9', O + 'kn5000_v9_program.rom', RB + 'kn5000_v9_program.llvm.elf'),
    ('maincpu v7', O + 'kn5000_v7_program.rom', RB + 'kn5000_v7_program.llvm.elf'),
    ('maincpu v6', O + 'kn5000_v6_program.rom', RB + 'kn5000_v6_program.llvm.elf'),
    ('maincpu v5', O + 'kn5000_v5_program.rom', RB + 'kn5000_v5_program.llvm.elf'),
    ('subcpu v142', O + 'kn5000_subprogram_v142.rom', RB + 'kn5000_subprogram_v142.llvm.elf'),
    ('subcpu v141', O + 'kn5000_subprogram_v141.rom', RB + 'kn5000_subprogram_v141.llvm.elf'),
    ('subcpu v140', O + 'kn5000_subprogram_v140.rom', RB + 'kn5000_subprogram_v140.llvm.elf'),
    ('subcpu boot', O + 'kn5000_subcpu_boot.ic30', RB + 'kn5000_subcpu_boot.llvm.elf'),
    ('table data', O + 'kn5000_table_data.rom', RB + 'kn5000_table_data.llvm.elf'),
    ('custom data', O + 'kn5000_custom_data.ic19', RB + 'kn5000_custom_data.llvm.elf'),
    ('hdae v2.06i', O + 'hd-ae5000_v2_06i.ic4', RB + 'hd-ae5000_v2_06i.llvm.elf'),
    ('hdae v2.01i', O + 'hd-ae5000_v2_01i.ic4', RB + 'hd-ae5000_v2_01i.llvm.elf'),
    ('hdae v1.15i', O + 'hd-ae5000_v1_15i.ic4', RB + 'hd-ae5000_v1_15i.llvm.elf'),
    ('hdae v1.10i', O + 'hd-ae5000_v1_10i.ic4', RB + 'hd-ae5000_v1_10i.llvm.elf'),
    ('wsa1 prom_a', W + 'original_ROMs/wsa1_prom_a.ic12', W + 'rebuilt_ROMs/wsa1_prom_a.llvm.elf'),
    ('wsa1 prom_b', W + 'original_ROMs/wsa1_prom_b.ic13', W + 'rebuilt_ROMs/wsa1_prom_b.llvm.elf'),
    ('wsa1 prom_c', W + 'original_ROMs/wsa1_prom_c.ic28', W + 'rebuilt_ROMs/wsa1_prom_c.llvm.elf'),
    ('wsa1 prom_d', W + 'original_ROMs/wsa1_prom_d.bin', W + 'rebuilt_ROMs/wsa1_prom_d.llvm.elf'),
]
NM = H + '/llvm-project/build/bin/llvm-nm'
LABELERS = {}
SEGS = {}
PIECES_BY_NAME = collections.defaultdict(list)

def symbols(elf):
    out = subprocess.run([NM, '-n', '--defined-only', elf], capture_output=True, text=True, check=True).stdout
    syms = collections.defaultdict(list)
    for l in out.splitlines():
        a, t, n = l.split(None, 2)
        if t in 'tT' and not n.startswith('.L') and not n.startswith('$'): syms[int(a, 16)].append(n)
    return syms

def segments(elf):
    """[(vaddr, bytes)] of the ELF32's PT_LOAD segments that are executable or larger than 4 KB"""
    import struct
    b = open(elf, 'rb').read()
    assert b[:4] == b'\x7fELF' and b[4] == 1
    phoff, = struct.unpack_from('<I', b, 28); phentsize, phnum = struct.unpack_from('<HH', b, 42)
    out = []
    for i in range(phnum):
        t, off, va, pa, fsz, msz, fl, al = struct.unpack_from('<8I', b, phoff + i * phentsize)
        if t == 1 and fsz and (fl & 1 or fsz > 4096): out.append((va, b[off:off + fsz]))
    return out

def label(syms, addrs, a):
    if a in syms: return ' / '.join(syms[a])
    import bisect
    i = bisect.bisect_right(addrs, a) - 1
    return '%s+%d' % (syms[addrs[i]][-1], a - addrs[i]) if i >= 0 else '?'

def main():
    out = sys.argv[1]
    pieces = []
    for ln, lf in LIBS:
        for m in ieee695.library(open(lf, 'rb').read()):
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                if pub == sname: pub = '%s data' % m.name   # a section with no public at its start: name its member
                kn = [x for x in pat if x is not None and x >= 0]
                if len(kn) >= 12 and len(set(kn)) >= 6:
                    refs = []
                    for ro, size, x in rel:   # a call/jump/pointer to an external: read its target from the image
                        if len(x) >= 1 and x[0][0] == 'X' and x[0][1] in m.externals:
                            refs.append((ro, size, m.externals[x[0][1]], len(x) == 1))
                    pieces.append((ln, m.name, sname, pub, off, pat, len(kn), refs))
                if len(kn) >= 12: PIECES_BY_NAME[pub].append(pat)
    rows = []; LABELERS.clear()
    for iname, img, elf in IMAGES:
        syms = symbols(elf); addrs = sorted(syms)
        LABELERS[iname] = (syms, addrs)
        SEGS[iname] = segs = segments(elf)
        for ln, mem, sname, pub, off, pat, nk, refs in pieces:
            hits = []
            for va, data in segs:
                hits += [(va + h, va, data) for h in lib_match.search(pat, data)[0]]
            if not hits or len(hits) > 4: continue
            for h, va, data in hits:
                tg = []
                for ro, size, name, absolute in refs:
                    p = h - va + ro
                    if absolute and size in (3, 4):
                        t = int.from_bytes(data[p:p + 3], 'little')
                    elif size == 2:   # PC-relative (calr / jrl): target = end of the field + signed displacement
                        t = h + ro + 2 + int.from_bytes(data[p:p + 2], 'little', signed=True)
                    else:
                        continue
                    tg.append((name, t))
                rows.append((iname, h, ln, mem, sname, pub, off, len(pat), nk, label(syms, addrs, h), tg))
    with open(out, 'w') as f:
        f.write('image\taddress\tlibrary\tmember\tsection\tpublic\toffset\tlength\tknown\tour_label\treferences\n')
        for r in rows:
            f.write('\t'.join(['%s' % r[0], '%06x' % r[1]] + [str(x) for x in r[2:10]]
                               + [' '.join('%s=%06x' % nt for nt in r[10])]) + '\n')
    resolved, inferred = resolve(rows)
    with open(out.replace('.tsv', '') + '.resolved.tsv', 'w') as f:
        f.write('image\taddress\tlibrary_name\tlength\tour_label\tlibraries\tcheck\n')
        for r in resolved: f.write('%s\t%06x\t%s\t%d\t%s\t%s\t%s\n' % r)
    with open(out.replace('.tsv', '') + '.inferred.tsv', 'w') as f:
        f.write('image\taddress\tlibrary_name\treferenced_from\tour_label\n')
        for r in inferred: f.write('%s\t%06x\t%s\t%s\t%s\n' % r)
    for r in resolved:
        print('%-12s %06x %-34s len %4d  %-40s %-26s %s' % (r[0], r[1], r[2], r[3], r[4][:40], r[5], r[6]))
    print('%d resolved hits, %d inferred names' % (len(resolved), len(inferred)), file=sys.stderr)

SCORED = {}

def score_at(iname, pat, t):
    for va, data in SEGS[iname]:
        if va <= t and t + len(pat) <= va + len(data):
            kn = [(i, x) for i, x in enumerate(pat) if x is not None and x >= 0]
            return sum(1 for i, x in kn if data[t - va + i] == x) / len(kn) if kn else None
    return None

def callee_score(iname, refs, assigned):
    """mean, over a candidate's references to routines that matched nowhere, of how well the best library piece of
    that name matches at the referenced address (None when it has no such reference)"""
    v = []
    for rn, t in refs:
        if t in assigned or rn not in PIECES_BY_NAME: continue
        ss = [x for x in (score_at(iname, pat, t) for pat in PIECES_BY_NAME[rn]) if x is not None]
        if ss: v.append(max(ss))
    return sum(v) / len(v) if v else None

def resolve(rows):
    """Per image and address, pick the library name.  The longest pieces win; identical-looking pieces (twins whose
    only differences are relocated fields) are told apart by their references: a candidate is dropped when one of
    its calls lands on an address assigned to another name, or when the name it calls is assigned elsewhere.
    Returns (resolved rows, names inferred from the references of uniquely assigned hits)."""
    resolved = []; inferred = []
    for iname in dict.fromkeys(r[0] for r in rows):
        rs = [r for r in rows if r[0] == iname]
        by = collections.defaultdict(list)
        for r in rs: by[r[1]].append(r)
        cand = {}
        for a, g in by.items():
            mx = max(r[7] for r in g)
            cand[a] = {r[5] for r in g if r[7] == mx}
        def refs_of(a, name): return [t for r in by[a] if r[5] == name for t in r[10]]
        changed = True
        while changed:
            changed = False
            assigned = {a: next(iter(c)) for a, c in cand.items() if len(c) == 1}
            where = collections.defaultdict(set)
            for a, n in assigned.items(): where[n].add(a)
            for a, c in cand.items():
                if len(c) < 2: continue
                keep = set()
                for n in c:
                    bad = any((t in assigned and assigned[t] != rn) or (where.get(rn) and t not in where[rn])
                              for rn, t in refs_of(a, n))
                    if not bad: keep.add(n)
                if len(keep) > 1:   # still twins: score each one's unmatched callees against its library code
                    sc = {n: callee_score(iname, refs_of(a, n), assigned) for n in keep}
                    vals = [v for v in sc.values() if v is not None]
                    best = max(vals) if vals else None
                    if best is not None and sum(1 for v in sc.values() if v is not None and v > best - 0.15) == 1:
                        keep = {n for n, v in sc.items() if v == best}; SCORED[(iname, a)] = sc
                if keep and keep != c: cand[a] = keep; changed = True
        assigned = {a: next(iter(c)) for a, c in cand.items() if len(c) == 1}
        where = collections.defaultdict(set)
        for a, n in assigned.items(): where[n].add(a)
        seen = set()
        for a in sorted(cand):
            c = cand[a]; g = by[a]
            names = ' | '.join(sorted(c))
            gr = [r for r in g if r[5] in c]
            ln = max(r[7] for r in gr)
            libs = ','.join(sorted({r[2] for r in gr}))
            refs = [t for r in gr for t in r[10]]
            ok = [t for t in refs if t[1] in assigned and assigned[t[1]] == t[0]]
            chk = ('ambiguous' if len(c) > 1 else
                   'callee score ' + ', '.join('%s %.2f' % (k, v) for k, v in sorted(SCORED[(iname, a)].items()) if v is not None)
                   if (iname, a) in SCORED else
                   'refs confirmed %d' % len({t for t in ok}) if ok else 'no matched refs')
            resolved.append((iname, a, names, ln, gr[0][9], libs, chk))
            if len(c) == 1:
                for rn, t in refs:
                    if t not in assigned and not where.get(rn) and (rn, t) not in seen:
                        seen.add((rn, t))
                        inferred.append((iname, t, rn, names, label(*LABELERS[iname], t)))
        # label the inferred addresses
    return resolved, inferred

if __name__ == '__main__':
    main()
