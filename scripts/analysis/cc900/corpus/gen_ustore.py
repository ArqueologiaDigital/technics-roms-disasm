"""gen_ustore.py OUT.c: a probe for an unsigned int index on an element store through a pointer (lane_nm, pointer
area; lane_o3's u3: HEAD's model sign-extends the index on a store, `p[u] = 5` -> ld WA,(_ju) / exts XWA / add XWA,XWA,
while the loads zero-extend).  Question: how does V4.23 widen an unsigned int index for a store, a load and an op=?
Every access is defined for an index below the pointed-to array's length (the caller's contract); u >= 32768 is
defined too when the array is that long.

Names: us_<t><p><i><o>
  t  element type:  c char, i int, l long
  p  the pointer:   q parameter (T *q), g global T *gXp, l local copy of the global (T *w = gXp, kept by a call)
  i  the index:     l local unsigned int (u = ju, kept by a call), g global unsigned int ju, p unsigned int parameter
  o  the operation: s store q[u] = 5, v store of a global value q[u] = gX, r return q[u] (load), a op= q[u] += 3
Parameters (unsigned int pu, T *q); a call to v0() between the locals' set-up and the access keeps them in frame
slots without -O."""
import sys

T = {'c': ('char', 'gc', 'gcp'), 'i': ('int', 'gi', 'gip'), 'l': ('long', 'gl', 'glp')}
out = ['/* lane_nm probe: an unsigned int index on stores through a pointer; see gen_ustore.py for the name letters */',
       'extern char gc, *gcp;', 'extern int gi, *gip;', 'extern long gl, *glp;', 'extern unsigned int ju;',
       'extern void v0(void);']
n = 0
for t, (ty, gv, gp) in T.items():
    P = {'q': ('', 'q'), 'g': ('', gp), 'l': ('%s *w = %s; ' % (ty, gp), 'w')}
    I = {'l': ('unsigned int u = ju; ', 'u'), 'g': ('', 'ju'), 'p': ('', 'pu')}
    O = {'s': ('void', '%s = 5;'), 'v': ('void', '%%s = %s;' % gv), 'r': (ty, 'return %s;'), 'a': ('void', '%s += 3;')}
    for p, (pd, pv) in P.items():
        for i, (idc, iv) in I.items():
            for o, (ret, form) in O.items():
                pre = pd + idc + ('v0(); ' if pd or idc else '')
                out.append('%s us_%s%s%s%s(unsigned int pu, %s *q) { %s%s }' % (
                    ret, t, p, i, o, ty, pre, form % ('%s[%s]' % (pv, iv))))
                n += 1
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(n, 'functions')
