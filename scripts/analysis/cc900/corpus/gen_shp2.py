"""gen_shp2.py OUT.c: a probe for three shapes from the all-four-set DIFF statements (P11 evidence; the one-fix lists
only chose them).  Names:
  eo_<t><i><o><v>   element op=: g[i] op= v.  t: i int, l long, c char; i: P parameter, L local; o: a + s - x ^ n & o |;
                    v: K x ^ 3, M x * 3, B x + y, U ~x, G x (a plain global), Q (x ^ 3) then a second statement
  tv_<m><o><c><s>   a truth value with another operand: m: M member through a pointer, A constant element, G global,
                    D *p; o: n & o | x ^ a +; c: N x != 4, L x < y, B !x; s: R (m op c) returned, r (c op m) returned,
                    S stored to a global
  uc_<p><o><s>      a char complement with an element through a pointer: p: P parameter pointer, G global pointer;
                    o: o | n & x ^; s: l (p[6] op ~gc2), r (~gc2 op p[6]); stored to gc2"""
import sys
out = ['/* lane_o3 shapes probe 2: see gen_shp2.py for the name letters */',
       'struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; int ma[8]; };',
       'extern struct sv gs, *gps;',
       'extern char gc, gc2, gca[8], *gcp;', 'extern int gi, gi2, gia[8], *gip;', 'extern unsigned int gu, gu2, gua[8];',
       'extern long gl, gl2, gla[8];', 'extern unsigned char guc;']
T = {'i': ('int', 'gia', 'gu', 'gu2'), 'l': ('long', 'gla', 'gl', 'gl2'), 'c': ('char', 'gca', 'gc', 'gc2')}
OPS = {'a': '+=', 's': '-=', 'x': '^=', 'n': '&=', 'o': '|='}
for t, (ty, arr, x, y) in T.items():
    for ip in 'PL':
        for o, op in OPS.items():
            for vn, v in (('K', '%s ^ 3' % x), ('M', '%s * 3' % x), ('B', '%s + %s' % (x, y)), ('U', '~%s' % x), ('G', x)):
                n = 'eo_%s%s%s%s' % (t, ip, o, vn)
                if ip == 'P': out.append('void %s(int b) { %s[b] %s %s; }' % (n, arr, op, v))
                else: out.append('void %s(void) { int b = gi2; %s[b] %s %s; }' % (n, arr, op, v))
M = {'M': 'gps->ma[2]', 'A': 'gia[2]', 'G': 'gi', 'D': '*gip'}
TO = {'n': '&', 'o': '|', 'x': '^', 'a': '+'}
C = {'N': '(guc != 4)', 'L': '(gi < gi2)', 'B': '!gu'}
for mn, m in M.items():
    for o, op in TO.items():
        for cn, cv in C.items():
            out.append('int tv_%s%s%sR(void) { return %s %s %s; }' % (mn, o, cn, m, op, cv))
            out.append('int tv_%s%s%sr(void) { return %s %s %s; }' % (mn, o, cn, cv, op, m))
            out.append('void tv_%s%s%sS(void) { gi2 = %s %s %s; }' % (mn, o, cn, m, op, cv))
for p, pe in (('P', 'a'), ('G', 'gcp')):
    for o, op in (('o', '|'), ('n', '&'), ('x', '^')):
        for sd in 'lr':
            e = '%s[6] %s ~gc2' % (pe, op) if sd == 'l' else '~gc2 %s %s[6]' % (op, pe)
            out.append('void uc_%s%s%s(char *a) { gc2 = %s; }' % (p, o, sd, e))
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(sum(1 for l in out if l.startswith(('void', 'int'))), 'functions')
