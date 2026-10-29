#!/usr/bin/env python3
"""sha1_gate.py -- the floppy byte-identity gate: does each rebuilt image have its recorded SHA-1?

    python3 floppy/tools/sha1_gate.py MODEL BUILD_DIR REF_DIR DISK=SHA1 [DISK=SHA1 ...]

Prints one OK/FAIL line per disk and exits 1 if any disk fails, if a SHA-1 is missing, or if no
disk is named (a gate that checks nothing must not pass).  On a failure it names the first
differing offset against the reference copy.
"""
import hashlib
import pathlib
import sys


def main():
    model, build, ref = sys.argv[1], pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
    pairs = [a.split('=', 1) for a in sys.argv[4:]]
    if not pairs:
        sys.exit('sha1_gate: no disks named for %s' % model)
    bad = 0
    for disk, want in pairs:
        p = build / (disk + '.img')
        if len(want) != 40:
            print('FAIL  %s/%s: no recorded SHA-1' % (model, disk))
            bad += 1
            continue
        if not p.is_file():
            print('FAIL  %s/%s: %s not built' % (model, disk, p))
            bad += 1
            continue
        got = hashlib.sha1(p.read_bytes()).hexdigest()
        if got == want:
            print('OK    %s/%s rebuilds %s.img (SHA-1 %s)' % (model, disk, disk, got))
            continue
        bad += 1
        a, r = p.read_bytes(), (ref / (disk + '.img'))
        where = ''
        if r.is_file():
            b = r.read_bytes()
            i = next((k for k in range(min(len(a), len(b))) if a[k] != b[k]), min(len(a), len(b)))
            where = ', first difference at 0x%x (sizes %d / %d)' % (i, len(a), len(b))
        print('FAIL  %s/%s: SHA-1 %s, want %s%s' % (model, disk, got, want, where))
    if bad:
        sys.exit('%s floppy byte-match FAILED (%d of %d)' % (model, bad, len(pairs)))
    print('All %d %s floppies reproduced byte-for-byte.' % (len(pairs), model))


if __name__ == '__main__':
    main()
