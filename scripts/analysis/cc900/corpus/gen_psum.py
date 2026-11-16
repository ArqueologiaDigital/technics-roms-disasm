"""gen_psum.py OUT.c: a probe for V4.23's two forms of a char pointer plus an int (lane_nm, pointer area).  The pool's
rstmt9 rs_9_08_04_3 (none) writes vp(u + i), u and i locals in frame slots, as ld XWA,(u) / ld BC,(i) /
lda XWA,XWA+BC (the index signed), while a stack parameter index takes ld WA,(i) / extz XWA / add XWA,(u) (V4.23
bug 1, the index zero-extended).  Question: which of the operands' homes picks the form?  Every function is
defined for in-range indices; a negative one is defined when the caller points the pointer into an array's middle.

Names: ps_<p><i><c>
  p  the pointer:  q char * parameter, g global char *gp, l local copy of gp (char *u = gp, kept in a slot by a
                   call), m local copy of the parameter q
  i  the index:    b int parameter, u unsigned int parameter, g global int gi, l local int (t = gi, kept by a
                   call), k local computed from the parameter (t = b + 1), c char parameter, x long parameter
  c  the context:  a argument vp(p + i), r return p + i, s gp2 = p + i (stored to a global), i char *w = p + i;
                   vp(w) in an inner block (a local's initialiser), d *(p + i) = 5 (a store through the sum)
Parameters (int b, unsigned int ub, char cb, long lb, char *q); a call to v0() between the locals' set-up and the
sum keeps them in frame slots without -O."""
import sys

out = ['/* lane_nm probe: char pointer + int, the extz and the lda forms; see gen_psum.py for the name letters */',
       'extern char *gp, *gp2;', 'extern int gi;', 'extern void vp(char *);', 'extern void v0(void);']
P = {'q': ('', 'q'), 'g': ('', 'gp'), 'l': ('char *u = gp; ', 'u'), 'm': ('char *u = q; ', 'u')}
I = {'b': ('', 'b'), 'u': ('', 'ub'), 'g': ('', 'gi'), 'l': ('int t = gi; ', 't'), 'k': ('int t = b + 1; ', 't'),
     'c': ('', 'cb'), 'x': ('', 'lb')}
C = {'a': ('void', 'vp(%s);'), 'r': ('char *', 'return %s;'), 's': ('void', 'gp2 = %s;'),
     'i': ('void', '{ char *w = %s; vp(w); }'), 'd': ('void', '*(%s) = 5;')}
n = 0
for p, (pd, pv) in P.items():
    for i, (idc, iv) in I.items():
        for c, (ret, form) in C.items():
            pre = pd + idc + ('v0(); ' if pd or idc else '')
            out.append('%s ps_%s%s%s(int b, unsigned int ub, char cb, long lb, char *q) { %s%s }' % (
                ret, p, i, c, pre, form % ('%s + %s' % (pv, iv))))
            n += 1
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(n, 'functions')
