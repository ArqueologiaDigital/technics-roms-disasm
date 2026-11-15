"""gen_ternk.py OUT.c: a probe for ?: with one constant arm (rule 31 TERN_CONST_PRE's shape, P11 evidence).  Names
tk_<type>_<cond><arm side><value kind><consumer>:
  type   c char, i int, l long
  cond   B bit test of a global, L long compare, M member through a pointer, P parameter compare, E element at a
         variable index, Q two char globals, C a call (control: the oracle's plain form expected)
  side   e the constant in the else arm (x ? v : K), t in the then arm (x ? K : v)
  value  G a global, A a constant element, M a member through a pointer, P the parameter
  use    S store to a global, T a local then a store, R return, O op= into a global"""
import sys
T = {'c': ('char', 'gc', 'gca[4]', 'gps->mc', '7'), 'i': ('int', 'gi', 'gia[4]', 'gps->mi', '127'),
     'l': ('long', 'gl', 'gla[4]', 'gps->ml', '70000L')}
COND = {'B': 'gu & 0x80', 'L': 'gl2 > -40543L', 'M': 'gps->mu < 9', 'P': 'a > 3', 'E': 'gia[a] != 0',
        'Q': 'gc < hc', 'C': 'gri(gi) != 0'}
head = '''/* ?: with one constant arm (lane_o3 rule 31); see gen_ternk.py for the name letters */
struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; };
extern struct sv gs, *gps;
extern char gc, hc, gca[8], jc;
extern int gi, gi2, gia[8], ji;
extern unsigned int gu;
extern long gl, gl2, gla[8], jl;
extern int gri(int);
'''
out = [head]
for t, (ty, g, el, mem, k) in T.items():
    j = {'c': 'jc', 'i': 'ji', 'l': 'jl'}[t]
    for cn, cond in COND.items():
        for side in 'et':
            for vn, v in (('G', g), ('A', el), ('M', mem), ('P', 'a')):
                ex = '(%s ? %s : %s)' % (cond, v, k) if side == 'e' else '(%s ? %s : %s)' % (cond, k, v)
                for use in 'STRO':
                    n = 'tk_%s_%s%s%s%s' % (t, cn, side, vn, use)
                    if use == 'S': body = '%s = %s;' % (j, ex); rt = 'void'
                    elif use == 'T': body = '%s t = %s; %s = t;' % (ty, ex, j); rt = 'void'
                    elif use == 'R': body = 'return %s;' % ex; rt = ty
                    else: body = '%s ^= %s;' % (j, ex); rt = 'void'
                    out.append('%s %s(%s a) { %s }' % (rt, n, ty, body))
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(out) - 1, 'functions')
