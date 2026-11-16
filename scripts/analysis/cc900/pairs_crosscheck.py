#!/usr/bin/env python3
"""Do two checks of the same compiler output on the library pairs agree?

usage: python3 -I -B pairs_crosscheck.py CHECK.tsv MODEL.tsv
CHECK.tsv is pairs_check.py's output (a compiler's asm900 objects against the images: `=` when every byte that is not a
relocated field agrees), MODEL.tsv is model/pairs_model.py's (with --listings: the same compiler's listing through
to_llvm.py and llvm-mc at the pair's address: `MATCH` when every byte agrees).  For the same oracle run they should
agree; a pair where they do not is printed (data pieces, which pairs_model.py does not compile, are left out), then
the counts of (object "=", listing MATCH).  A pair that the listing path matches and the object check does not would
be a fault of one of the two tools.

Answers, e.g. (2026-11-16): results/pairs_libsrc97_v423.tsv against results/pairs_v423_llvm_kn5000.tsv gives
(True, True) 212, (False, False) 56, (True, False) 23 and no (False, True).
"""
import collections
import sys


def rows(path, col):
    out = {}
    for line in open(path).read().splitlines()[1:]:
        c = line.split('\t')
        if len(c) > col and not line.startswith('#'):
            out[(c[0], int(c[1], 16), c[2])] = c[col]
    return out


def main():
    a, b = rows(sys.argv[1], 6), rows(sys.argv[2], 5)
    cnt = collections.Counter()
    for k in a:
        x, y = a[k] == '=', b.get(k) == 'MATCH'
        cnt[(x, y)] += 1
        if x != y and ' data' not in k[2]:
            print('%s\t%s\tobject: %s\tlisting: %s' % (k[0], k[2], a[k], b.get(k, '(absent)')[:70]))
    print('(object "=", listing MATCH): ' + ', '.join('%s %d' % kv for kv in sorted(cnt.items())))


if __name__ == '__main__':
    main()
