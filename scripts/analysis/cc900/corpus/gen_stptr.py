"""gen_stptr.py OUT.c: a wrong-code probe for element and pointer stores and store chains (lane_nm's area: rules
CHAIN_PTR_LAST, XREG_BASE_DIRECT, the element / pointer store paths).  Every function is one statement (two for the
value-used forms), so a semcheck DIFFERENT names its shape.  Names: sp_<t><d><x><o>

  t  type of the destination:      c char, i int, l long
  d  destination base:             A global sized array (g?a[8]), U global unsized array (g?u[]), P global pointer
                                   (g?p[x]), Q parameter pointer (q[x]), S array member through a global pointer
                                   (gps->m?[x]), D *gp (no index), E *q (no index)
  x  index:                        k constant 3, K constant 0x8001 (unsigned: past the 16-bit sign), p int parameter,
                                   u unsigned int parameter, c char parameter, l local int (from a global), g global int,
                                   n negative constant -2 (pointers only), - none (D, E)
  o  operation (value computed into a different register family each):
                                   a = constant, b = global, c = x + y, d = x * y (multiply: WA / XWA), e = r() (call:
                                   HL / XHL), f = x >> c (a shift by a variable: the value in BC), g = (c ? x : y),
                                   h = -dest' (a negated element of another array), i chain d = h? = x + y, j chain
                                   d = h? = constant, k += global, m ^= x + y, n -= constant, o <<= 1, p d++ (statement),
                                   q --d (statement), r gx = d++ (the old value used), s gx = ++d, t gx = d-- (long and
                                   char too)
The large constant index K reaches past 0x8000 elements: the element's byte offset no longer fits a signed 16-bit
index (char 0x8001, int 0x10002, long 0x20004); a 16-bit index register would wrap.  Parameters: (int b, unsigned
int ub, char cb, T *q) at every function, so -Xr puts them in WA / BC / DE and the pointer on the stack."""
import sys

out = ['/* lane_nm wrong-code probe: element and pointer stores and chains; see gen_stptr.py for the name letters */',
       'struct sv { char mc; int mi; long ml; char mca[8]; int mia[8]; long mla[8]; };',
       'extern struct sv *gps;',
       'extern char gc, gc2, gc3, gca[8], gcb[8], gcu[], *gcp;',
       'extern int gi, gi2, gi3, gia[8], gib[8], giu[], *gip;',
       'extern long gl, gl2, gl3, gla[8], glb[8], glu[], *glp;',
       'extern unsigned int gu;',
       'extern char rc(void);', 'extern int ri(void);', 'extern long rl(void);']
T = {'c': ('char', 'gc', 'gca', 'gcb', 'gcu', 'gcp', 'mca', 'rc'),
     'i': ('int', 'gi', 'gia', 'gib', 'giu', 'gip', 'mia', 'ri'),
     'l': ('long', 'gl', 'gla', 'glb', 'glu', 'glp', 'mla', 'rl')}
IDX = {'k': '3', 'K': '0x8001u', 'p': 'b', 'u': 'ub', 'c': 'cb', 'l': 't', 'g': 'gi2', 'n': '-2'}
DEST = {'A': 'kKpuclg', 'U': 'kKpc', 'P': 'kKpcln', 'Q': 'kKpcn', 'S': 'kp', 'D': '-', 'E': '-'}


def dest(t, d, x):
    ty, g, ga, gb, gu, gp, ma, rf = T[t]
    i = IDX.get(x)
    return {'A': '%s[%s]' % (ga, i), 'U': '%s[%s]' % (gu, i), 'P': '%s[%s]' % (gp, i), 'Q': 'q[%s]' % i,
            'S': 'gps->%s[%s]' % (ma, i), 'D': '*%s' % gp, 'E': '*q'}[d]


def ops(t):
    ty, g, ga, gb, gu, gp, ma, rf = T[t]
    x, y = g, g + '2'
    return [('a', '%s = 5;'), ('b', '%%s = %s;' % x), ('c', '%%s = %s + %s;' % (x, y)), ('d', '%%s = %s * %s;' % (x, y)),
            ('e', '%%s = %s();' % rf), ('f', '%%s = %s >> cb;' % x), ('g', '%%s = (gu ? %s : %s);' % (x, y)),
            ('h', '%%s = -%s[2];' % gb), ('i', '%%s = %s3 = %s + %s;' % (g, x, y)), ('j', '%%s = %s3 = 7;' % g),
            ('k', '%%s += %s;' % x), ('m', '%%s ^= %s + %s;' % (x, y)), ('n', '%s -= 9;'), ('o', '%s <<= 1;'),
            ('p', '%s++;'), ('q', '--%s;'), ('r', g + '3 = %s++;'), ('s', g + '3 = ++%s;'), ('t', g + '3 = %s--;')]


n = 0
for t, (ty, g, ga, gb, gu, gp, ma, rf) in T.items():
    for d, xs in DEST.items():
        for x in xs:
            for o, form in ops(t):
                if x in 'ucgn' and o not in 'acdeijkmpr':     # (the other indices: a subset of the operations)
                    continue
                name = 'sp_%s%s%s%s' % (t, d, '-' if x == '-' else x, o)
                name = name.replace('-', '_')
                lhs = dest(t, d, x if x != '-' else None)
                body = form % lhs
                pre = 'int t = gi3; ' if x == 'l' else ''
                out.append('void %s(int b, unsigned int ub, char cb, %s *q) { %s%s }' % (name, ty, pre, body))
                n += 1
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(n, 'functions')
