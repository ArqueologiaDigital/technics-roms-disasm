"""gen_bigoff.py OUT.c: a probe for constant element offsets past 16 bits (lane_nm's area: element addressing).
Question: does V4.23 compute a constant index's byte offset in 16 bits and sign-extend it (random11 r11_01_05 at -O:
gula[t] with t = (int)41411UL -> _gula + 0xffff870c), also when the C offset is in range and above 0x7fff (a defined
access into a large array)?  Every access is defined: the arrays are big enough for every index, and the negative
indices go through a pointer the caller points at the array's middle (the m form: q = &big[0x10000 / size]).

Names: bo_<t><k><f>
  t  element type: c char (1 byte), i int (2), l long (4), s struct s10 (10 bytes)
  k  the constant index, chosen by the byte offset it gives: a 0x7ffe, b 0x8000, c 0x8002 + (the next element), d
     0xa000, e 0xfffe (or the nearest element), f 0x10000, g 0x12340, h 0x1fffc (K = offset / size, rounded down)
  f  form: r return big[K]; w big[K] = 5 (a char's or member's store); a return &big[K]; p q[K] (q a parameter
     pointing at big[0]); l int t = K; return big[t] (a local folded under -O, as r11_01_05); u K written unsigned
     (Ku); m return q[-K] (q at the array's middle)
Arrays: extern char gcb[0x20010]; extern int gib[0x10008]; extern long glb[0x8004]; extern struct s10 gsb[0x3340]."""
import sys

T = {'c': ('char', 'gcb', 1, 0x20010), 'i': ('int', 'gib', 2, 0x10008), 'l': ('long', 'glb', 4, 0x8004),
     's': ('struct s10', 'gsb', 10, 0x3340)}
OFFS = {'a': 0x7ffe, 'b': 0x8000, 'c': 0x8002, 'd': 0xa000, 'e': 0xfffe, 'f': 0x10000, 'g': 0x12340, 'h': 0x1fffc}
out = ['/* lane_nm probe: constant element offsets past 16 bits; see gen_bigoff.py for the name letters */',
       'struct s10 { int a[5]; };',
       'extern char gcb[0x20010];', 'extern int gib[0x10008];', 'extern long glb[0x8004];', 'extern struct s10 gsb[0x3340];']
n = 0


def fn(ret, name, params, body):
    global n
    out.append('%s %s(%s) { %s }' % (ret, name, params, body)); n += 1


for t, (ty, arr, size, count) in T.items():
    sc = 'int' if t == 's' else ty
    el = (lambda e: '%s.a[1]' % e) if t == 's' else (lambda e: e)
    for k, off in OFFS.items():
        K = off // size                               # the element at or below the offset
        if K >= count: continue
        P = '%s *q' % ty
        fn(sc, 'bo_%s%sr' % (t, k), P, 'return %s;' % el('%s[%d]' % (arr, K)))
        fn('void', 'bo_%s%sw' % (t, k), P, '%s = 5;' % el('%s[%d]' % (arr, K)))
        fn(ty + ' *', 'bo_%s%sa' % (t, k), P, 'return &%s[%d];' % (arr, K))
        fn(sc, 'bo_%s%sp' % (t, k), P, 'return %s;' % el('q[%d]' % K))
        if K <= 0x7fff:
            fn(sc, 'bo_%s%sl' % (t, k), P, 'int t = %d; return %s;' % (K, el('%s[t]' % arr)))
        fn(sc, 'bo_%s%su' % (t, k), P, 'return %s;' % el('%s[%du]' % (arr, K)))
        if off <= 0x10000:
            fn(sc, 'bo_%s%sm' % (t, k), P, 'return %s;' % el('q[-%d]' % K))
# r11_01_05's shape, defined: a negative int from a cast of an unsigned long constant ((int)36768UL = -28768) indexing
# a long pointer the caller points at glb[0x8000]
fn('long', 'bo_lx_cast', 'long *q', 'int t = (int)36768UL; return q[t];')
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(n, 'functions')
