#!/usr/bin/env python3
"""Does the TLCS-900 C Compiler V4.23 reproduce the firmware's runtime?  Compares the VM's objects with the ROMs.

usage: python3 -I -B compare_vm.py RESULTS_DIR > ../results/vm_compile.md
RESULTS_DIR is run_vm.sh's results.tar unpacked: one directory per option set and mode, `<label>.c/` holding the
IEEE-695 objects (`*.REL`) that `cc900 <flags> -c` wrote.  Every public piece of every object (split at its publics
like xref_runtime.py, relocated fields masked) is
- searched for exactly in every image of xref_runtime.IMAGES ("images": how many images, and one per family);
- when it has no exact hit, scored against the image family it should be in (NEAR below): the best fraction of its
  known bytes that equal the image, at any start that one of its 6-byte unmasked windows finds;
- compared with the piece of the same public name in each of the three libraries (1997 = V4.23's own C900ML.LIB,
  2003 = the kit CD's IDE, 2008 = v1.10): "=" when the lengths are equal and every byte known in both agrees, else
  the length difference or the number of differing bytes.
__doform_c's f_const (the 22 case offsets of __doprnt's switch) is also printed beside the firmware's table at
main CPU v10 0xeed878 (doform_switch.py).
"""
import os, sys, glob, struct, collections
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import ieee695, lib_match, xref_runtime as X

BUILDS = [('1997', X.V423 + '/C900ML.LIB'), ('2003', X.IDE + '/c900ml.lib'), ('2008', X.V110 + '/c900ml.lib')]
NEAR = ['maincpu v10', 'subcpu v142', 'hdae v2.06i']
FAMILY = {'maincpu': 'maincpu v10', 'subcpu': 'subcpu v142', 'hdae': 'hdae v2.06i', 'wsa1': 'wsa1 prom_a'}

def lib_pieces(path):
    out = {}
    for m in ieee695.library(open(path, 'rb').read()):
        for sname, pub, off, pat, rel in lib_match.pieces_r(m):
            out.setdefault(pub if pub != sname else '%s data' % m.name.lower(), pat)
    return out

def same(a, b):
    if len(a) != len(b): return '%+d B' % (len(a) - len(b))
    d = sum(1 for x, y in zip(a, b) if x is not None and y is not None and x >= 0 and y >= 0 and x != y)
    return '=' if d == 0 else '%d B differ' % d

def near(pat, img):
    kn = [(i, x) for i, x in enumerate(pat) if x is not None and x >= 0]
    if not kn: return 0.0, None
    starts = set()
    for i in range(0, len(pat) - 6, 3):
        w = pat[i:i + 6]
        if any(x is None or x < 0 for x in w): continue
        w = bytes(w); p = img.find(w)
        n = 0
        while p >= 0 and n < 50:
            starts.add(p - i); p = img.find(w, p + 1); n += 1
    best = (0.0, None)
    for s in starts:
        if s < 0 or s + len(pat) > len(img): continue
        sc = sum(1 for i, x in kn if img[s + i] == x) / len(kn)
        if sc > best[0]: best = (sc, s)
    return best

def main():
    root = sys.argv[1]
    libs = {y: lib_pieces(p) for y, p in BUILDS}
    imgs = []
    for name, ref, elf in X.IMAGES:
        if os.path.exists(elf): imgs.append((name, X.segments(elf)))
    rows = []
    doform = {}
    for d in sorted(p for p in glob.glob(os.path.join(root, '*')) if os.path.isdir(p)):
        label = os.path.basename(d)
        for f in sorted(glob.glob(os.path.join(d, '*.[Rr][Ee][Ll]'))):
            m = ieee695.Module(open(f, 'rb').read())
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                if pub == sname: pub = '%s data' % m.name.lower()
                kn = sum(1 for x in pat if x is not None and x >= 0)
                if kn < 8: continue
                if pub == '__doform_c data' and sname == 'f_const':
                    doform[label] = struct.unpack('<22H', bytes(x if 0 <= x < 256 else 0 for x in pat[:44]))
                hit = []
                for name, segs in imgs:
                    for va, data in segs:
                        h, _ = lib_match.search(pat, data)
                        if h: hit.append((name, va + h[0]))
                fams = sorted({n.split()[0] for n, a in hit})
                where = ', '.join('%s 0x%06x' % next((n, a) for n, a in hit if n.split()[0] == fm) for fm in fams)
                nr = ''
                if not hit:
                    best = max(((near(pat, data)[0], n) for n, segs in imgs if n in NEAR for va, data in segs),
                               default=(0, ''))
                    nr = '%.3f %s' % best if best[0] else ''
                cmp = [same(pat, libs[y][pub]) if pub in libs[y] else 'absent' for y, _ in BUILDS]
                rows.append((label, os.path.basename(f), '`%s`' % pub, len(pat), len(hit), where or '-', nr) +
                            tuple(cmp))
    head = ('options', 'object', 'piece', 'bytes', 'images', 'exact hit (one per family)', 'best near',
            'vs 1997', 'vs 2003', 'vs 2008')
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    print('| ' + ' | '.join(h.ljust(x) for h, x in zip(head, w)) + ' |')
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in rows: print('| ' + ' | '.join(str(c).ljust(v) for c, v in zip(r, w)) + ' |')
    if doform:
        fw = None
        for name, segs in imgs:
            if name != 'maincpu v10': continue
            for va, data in segs:
                if va <= 0xeed878 < va + len(data):
                    fw = struct.unpack('<22H', data[0xeed878 - va:0xeed878 - va + 44])
        print('\n__doprnt case table (22 offsets), firmware = main CPU v10 0xeed878\n')
        print('%-10s %s' % ('firmware', ' '.join('%4d' % v for v in fw)))
        for label, t in sorted(doform.items()):
            print('%-10s %s' % (label, ' '.join('%4d' % v for v in t)))
            print('%-10s %s' % ('fw-' + label, ' '.join('%+4d' % (a - b) for a, b in zip(fw, t))))

main()
