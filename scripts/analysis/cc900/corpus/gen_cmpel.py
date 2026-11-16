"""gen_cmpel.py OUT.c: a probe for a compare whose right operand is an array element at a variable index (lane_o3).
In the training pool the model refuses "complex compare operand" mostly for this shape (rstmt12 rs_12_02_14_2:
guc != guca[t]; rs_12_09_09_3: gl2 != a[t]).  Without -O V4.23 builds the element's address first, then loads the
left and compares against the element in memory (ld WA,HL / extz XWA / ld XBC,_guca / add XBC,XWA / ld A,(_guc) /
cp A,(XBC)); under -O3 -XS the two examples differ (a byte: ld A,(XWA) / cp (_guc),A; a long: ld XBC,(_gl2) /
cp XBC,(XWA)).  This probe asks for the forms in each set.  No undefined behaviour: every index is read from a
parameter or global the caller sets, and the arrays are extern (the oracle only compiles).  Names:
  ce_<size>_<left>_<elem>_<idx>_<op>
  size   c unsigned char, i int, l long
  left   g a global, k an element at a constant index, d *gp (a deref of a global pointer), m gs.m (a global struct's member)
  elem   a a sized global array, u an incomplete global array, p a pointer parameter, q a global pointer
  idx    P an int parameter, L an int local copied from a global, U an unsigned int local
  op     eq ==, ne !=, lt <, ge >=
The statement is if (L op R) gi3 = 1; else gi3 = 2;"""
import sys
T = {'c': 'unsigned char', 'i': 'int', 'l': 'long'}
out = ['/* lane_o3 probe: a compare against an array element at a variable index; see gen_cmpel.py */',
       'extern int gi3, ji;', 'extern unsigned int ju;']
for s, t in T.items():
    out += ['extern %s g%s, k%sa[8], a%sa[8], u%sa[], *gp%s, *q%s;' % (t, s, s, s, s, s, s),
            'struct s%s { int pad; %s m; };' % (s, t), 'extern struct s%s gs%s;' % (s, s)]
OPS = {'eq': '==', 'ne': '!=', 'lt': '<', 'ge': '>='}
for s, t in T.items():
    LEFT = {'g': 'g%s' % s, 'k': 'k%sa[3]' % s, 'd': '*gp%s' % s, 'm': 'gs%s.m' % s}
    for ln, lx in LEFT.items():
        for en in 'aupq':
            for ix in 'PLU':
                for on, op in OPS.items():
                    params = []
                    if en == 'p': params.append('%s *p' % t)
                    if ix == 'P': params.append('int i')
                    decl = ''
                    if ix == 'L': decl = 'int i = ji; '
                    if ix == 'U': decl = 'unsigned int i = ju; '
                    arr = {'a': 'a%sa' % s, 'u': 'u%sa' % s, 'p': 'p', 'q': 'q%s' % s}[en]
                    nm = 'ce_%s_%s_%s_%s_%s' % (s, ln, en, ix, on)
                    out.append('void %s(%s) { %sif (%s %s %s[i]) gi3 = 1; else gi3 = 2; }' %
                               (nm, ', '.join(params) or 'void', decl, lx, op, arr))
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
