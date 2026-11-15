"""gen_fpw.py OUT.c: a wrong-code probe for floating point (lane_o3), for semcheck first: double and float arithmetic,
compares, conversions, parameters and returns, struct members and array elements, values live across calls, several
temporaries in one expression, op=, and -Xr forms.  No undefined behaviour on purpose: every variable is assigned
before it is read, indices are constants in range or masked (& 7), constants are ordinary finite values (no NaN, inf,
denormals or overflow), and every path of a value-returning function returns.  Functions returning float or double are __cdecl (the
adecl convention of -Xr cannot return them).  Conversions to integer types are of
values the inputs choose (semcheck's helper truncates modulo 2^32, semcheck.md).  Names: fp_<fam>_<t><...>

  t  d double, f float
  ar_<t><o><k>   g?3 = x o y: o a + s - m * d / ; k G global op global, P parameter op global, Q parameter op parameter,
                 K global op constant (1.5), C constant op global (2.25), A element op global, S member op global,
                 R a call's result op global
  ng_<t><k>      g?3 = -x: k G, P, A, S
  cm_<t><c><k><f> a compare: c e == n != l < g > L <= G >=; k G global/global, K global/constant, P parameter/global,
                 A element/global; f T g?3 = (x c y ? x : y), I if (x c y) g?3 = x; else g?3 = 1.0, R return (x c y ? 1
                 : 2), B return x c y
  ci_<t><i><d>   conversions: i the integer type c char, b unsigned char, i int, u unsigned, l long, n unsigned long;
                 d F from the FP type (gi3 = (int)gd1), T to it (gd3 = (double)gi1), P a parameter converted and returned,
                 Q an FP parameter returned as the integer type
  ff_<k>         float <-> double: k D gd3 = gf1, F gf3 = gd1, A gd3 = gf1 + gd2, M gf3 = gf1 * (float)gd2, P a float
                 parameter returned as double, Q a double parameter returned as float
  pr_<t><k>      FP parameters and returns: k 0 return a, 1 return a + b, 2 return a * b - c (three), 3 an int and an FP
                 parameter, 4 an FP and an int parameter, 5 the parameter stored to a global, 6 returned negated, 7 the
                 parameter passed to a call
  st_<t><k>      members and elements: k 0 gs.x = ga[2] + gs.x, 1 ga[i & 7] = g1 * 2.0, 2 gps->x = gps->x - g1, 3 two
                 members, 4 element to element, 5 an element read through a pointer parameter
  lc_<t><k>      a value live across a call: k 0 local, 1 parameter, 2 a call between two FP calls, 3 a local and a
                 parameter, 4 a call in a loop, 5 an int local beside an FP local
  tm_<t><k>      several temporaries: k 0 (a + b) * (a - b), 1 .. / (b + 2.5), 2 two calls, 3 nested parentheses,
                 4 an FP compare of two temporaries, 5 mixed int and FP operands
  oa_<t><o><v>   op=: o a += s -= m *= d /= ; v G a global, L a local, A an element, S a member, P a parameter
  ch_<t><o><p>   chains g?3 = g1 o g2 p 1.25 (o, p among + - * /)
  ce_<t><i><d>   conversions with elements and members: F gi3 = (int)ga[2], T gs.x = gi1
  oi_<t><o><i>   op= with an integer right side: g1 o= g<i>1 (o a + s - m * d /, a divisor forced odd)
  cx_<t><c><i>   an FP global compared with an integer global (c among the six relations, i c / i / l)
  xr_<t><k>      -Xr shapes: k 0 (double a, int b, double c) returning a * b + c, 1 (int a, double b) b stored then
                 a returned, 2 (double a, double b) compared, 3 a call between two parameters, 4 a parameter converted to
                 long, 5 a long parameter converted to double, 6 two FP parameters passed to a call swapped, 7 an
                 element indexed by an int parameter
  ai_<t><o>      an element at a masked int parameter index op a global;  sp_<t><o>  a member through a pointer
                 parameter op=-like (p->x = p->x o g2);  cr_<t><i>  a call's FP result converted to an integer type
  lo_<t><k>      loops: k 0 sum of an array, 1 product with a counter, 2 a running maximum"""
import sys
FT = {'d': 'double', 'f': 'float'}
IT = {'c': 'char', 'b': 'unsigned char', 'i': 'int', 'u': 'unsigned int', 'l': 'long', 'n': 'unsigned long'}
out = ['/* lane_o3 wrong-code probe: floating point; see gen_fpw.py for the name letters */',
       'extern double gd1, gd2, gd3, gda[8], *gdp; extern float gf1, gf2, gf3, gfa[8], *gfp;',
       'struct sv { char c; double d; int i; float f; double d2; float f2; };', 'extern struct sv gs, *gps;',
       'extern double __cdecl rd(void); extern float __cdecl rf(void); extern void vd(double); extern void vf(float); extern void v0(void);']
for t, ty in IT.items(): out.append('extern %s g%s1, g%s3;' % (ty, t, t))
F = []
def fn(name, rt, params, *st):                 # (an FP result needs cdecl under -Xr: adecl cannot return one)
    F.append('%s%s fp_%s(%s) { %s }' % (rt, ' __cdecl' if rt in ('double', 'float') else '', name, params, ' '.join(st)))
for t, ty in FT.items():
    g1, g2, g3, ga, gp, r, v = 'g%s1' % t, 'g%s2' % t, 'g%s3' % t, 'g%sa' % t, 'g%sp' % t, 'r' + t, 'v' + t
    m, m2 = ('d', 'd2') if t == 'd' else ('f', 'f2')
    K1, K2 = ('1.5', '2.25') if t == 'd' else ('1.5f', '2.25f')
    P2 = '%s a, %s b' % (ty, ty)
    OPS = {'a': '+', 's': '-', 'm': '*', 'd': '/'}
    KX = {'G': (g1, g2, 'void'), 'P': ('a', g2, P2), 'Q': ('a', 'b', P2), 'K': (g1, K1, 'void'), 'C': (K2, g1, 'void'),
          'A': ('%s[2]' % ga, g1, 'void'), 'S': ('gs.%s' % m, g1, 'void'), 'R': ('%s()' % r, g1, 'void')}
    for o, op in OPS.items():
        for k, (x, y, pp) in KX.items():
            if o == 'd' and y in (g1, g2, 'b'): y = '(%s * %s + 3.0)' % (y, y)   # (a divisor never 0: x*x + 3)
            fn('ar_%s%s%s' % (t, o, k), 'void', pp, '%s = %s %s %s;' % (g3, x, op, y))
    for k, x, pp in (('G', g1, 'void'), ('P', 'a', P2), ('A', '%s[3]' % ga, 'void'), ('S', 'gs.%s' % m, 'void')):
        fn('ng_%s%s' % (t, k), 'void', pp, '%s = -%s;' % (g3, x))
    for c, cop in {'e': '==', 'n': '!=', 'l': '<', 'g': '>', 'L': '<=', 'G': '>='}.items():
        for k, (x, y, pp) in (('G', (g1, g2, 'void')), ('K', (g1, K1, 'void')), ('P', ('a', g2, P2)), ('A', ('%s[1]' % ga, g1, 'void'))):
            fn('cm_%s%s%sT' % (t, c, k), 'void', pp, '%s = (%s %s %s ? %s : %s);' % (g3, x, cop, y, x, y))
            fn('cm_%s%s%sI' % (t, c, k), 'void', pp, 'if (%s %s %s) %s = %s; else %s = 1.0;' % (x, cop, y, g3, x, g3))
            fn('cm_%s%s%sR' % (t, c, k), 'int', pp, 'return (%s %s %s ? 1 : 2);' % (x, cop, y))
            fn('cm_%s%s%sB' % (t, c, k), 'int', pp, 'return %s %s %s;' % (x, cop, y))
    for i, ity in IT.items():
        fn('ci_%s%sF' % (t, i), 'void', 'void', 'g%s3 = (%s)%s;' % (i, ity, g1))
        fn('ci_%s%sT' % (t, i), 'void', 'void', '%s = (%s)g%s1;' % (g3, ty, i))
        fn('ci_%s%sP' % (t, i), ty, '%s a' % ity, 'return a;')
        fn('ci_%s%sQ' % (t, i), ity, '%s a' % ty, 'return (%s)a;' % ity)
    PR = ['return a;', 'return a + b;', 'return a * b - c;', None, None, '%s = a; return b;' % g3, 'return -a;', '%s(a); return b;' % v]
    for k, body in enumerate(PR):
        if k == 2: fn('pr_%s%d' % (t, k), ty, '%s a, %s b, %s c' % (ty, ty, ty), body)
        elif k == 3: fn('pr_%s%d' % (t, k), ty, 'int i, %s a' % ty, 'return a + i;')
        elif k == 4: fn('pr_%s%d' % (t, k), ty, '%s a, int i' % ty, 'return a * i;')
        else: fn('pr_%s%d' % (t, k), ty, P2, body)
    fn('st_%s0' % t, 'void', 'void', 'gs.%s = %s[2] + gs.%s;' % (m, ga, m))
    fn('st_%s1' % t, 'void', 'int i', '%s[i & 7] = %s * 2.0;' % (ga, g1))
    fn('st_%s2' % t, 'void', 'void', 'gps->%s = gps->%s - %s;' % (m, m, g1))
    fn('st_%s3' % t, 'void', 'void', 'gs.%s = %s;' % (m, g1), 'gs.%s = gs.%s * %s;' % (m2, m, g2))
    fn('st_%s4' % t, 'void', 'void', '%s[4] = %s[1] + %s[2];' % (ga, ga, ga))
    fn('st_%s5' % t, ty, '%s *p' % ty, 'return p[3] - p[1];')
    fn('lc_%s0' % t, 'void', 'void', '%s t = %s * %s;' % (ty, g1, g2), 'v0();', '%s = t + %s;' % (g3, g1))
    fn('lc_%s1' % t, ty, '%s a' % ty, 'v0();', 'return a * 2.0;')
    fn('lc_%s2' % t, 'void', 'void', '%s t = %s();' % (ty, r), '%s(%s);' % (v, g1), '%s = t - %s();' % (g3, r))
    fn('lc_%s3' % t, ty, '%s a' % ty, '%s t = a + %s;' % (ty, g1), 'v0();', 'return t * a;')
    fn('lc_%s4' % t, 'void', 'void', '%s t = %s;' % (ty, g1), 'int i;', 'for (i = 0; i < 3; i++) { v0(); %s[i] = t; }' % ga, '%s = t;' % g3)
    fn('lc_%s5' % t, 'void', 'void', 'int n = gi1;', '%s t = %s + 1.0;' % (ty, g2), 'v0();', '%s = t * n;' % g3)
    fn('tm_%s0' % t, 'void', 'void', '%s = (%s + %s) * (%s - %s);' % (g3, g1, g2, g1, g2))
    fn('tm_%s1' % t, 'void', 'void', '%s = (%s + %s) * (%s - %s) / (%s * %s + 2.5);' % (g3, g1, g2, g1, g2, g2, g2))
    fn('tm_%s2' % t, 'void', 'void', '%s = %s() * (%s + %s());' % (g3, r, g1, r))
    fn('tm_%s3' % t, 'void', 'void', '%s = ((%s * 2.0 + %s) * (%s - 0.5)) + (%s * %s);' % (g3, g1, g2, g2, g1, g1))
    fn('tm_%s4' % t, 'int', 'void', 'return (%s + %s) < (%s * %s);' % (g1, g2, g1, g2))
    fn('tm_%s5' % t, 'void', 'void', '%s = (%s + gi1) * (%s - gl1);' % (g3, g1, g2))
    for o, op in (('a', '+='), ('s', '-='), ('m', '*='), ('d', '/=')):
        y = g2 if o != 'd' else '(%s * %s + 3.0)' % (g2, g2)
        fn('oa_%s%sG' % (t, o), 'void', 'void', '%s %s %s;' % (g1, op, y))
        fn('oa_%s%sL' % (t, o), 'void', 'void', '%s t = %s;' % (ty, g1), 't %s %s;' % (op, y), '%s = t;' % g3)
        fn('oa_%s%sA' % (t, o), 'void', 'void', '%s[3] %s %s;' % (ga, op, y))
        fn('oa_%s%sS' % (t, o), 'void', 'void', 'gs.%s %s %s;' % (m, op, y))
        fn('oa_%s%sP' % (t, o), ty, P2, 'a %s %s;' % (op, y.replace(g2, 'b')), 'return a;')
for t, ty in FT.items():
    g1, g2, g3, ga, r, v = 'g%s1' % t, 'g%s2' % t, 'g%s3' % t, 'g%sa' % t, 'r' + t, 'v' + t
    m = 'd' if t == 'd' else 'f'
    OP = {'a': '+', 's': '-', 'm': '*', 'd': '/'}
    for o, op in OP.items():
        for p, pp in OP.items():
            fn('ch_%s%s%s' % (t, o, p), 'void', 'void', '%s = %s %s %s %s 1.25;' % (g3, g1, op, '(%s * %s + 3.0)' % (g2, g2) if o == 'd' else g2, pp))
    for i, ity in IT.items():
        fn('ce_%s%sF' % (t, i), 'void', 'void', 'g%s3 = (%s)%s[2];' % (i, ity, ga))
        fn('ce_%s%sT' % (t, i), 'void', 'void', 'gs.%s = g%s1;' % (m, i))
        for o, op in OP.items():
            y = '(g%s1 | 1)' % i if o == 'd' else 'g%s1' % i
            fn('oi_%s%s%s' % (t, o, i), 'void', 'void', '%s %s= %s;' % (g1, op, y))
    for c, cop in {'e': '==', 'n': '!=', 'l': '<', 'g': '>', 'L': '<=', 'G': '>='}.items():
        for i in 'cil':
            fn('cx_%s%s%s' % (t, c, i), 'void', 'void', '%s = (%s %s g%s1 ? %s : %s);' % (g3, g1, cop, i, g1, g2))
    fn('xr_%s0' % t, ty, '%s a, int b, %s c' % (ty, ty), 'return a * b + c;')
    fn('xr_%s1' % t, 'int', 'int a, %s b' % ty, '%s = b;' % g3, 'return a;')
    fn('xr_%s2' % t, 'int', '%s a, %s b' % (ty, ty), 'if (a < b) return 1;', 'return 0;')
    fn('xr_%s3' % t, ty, '%s a, %s b' % (ty, ty), 'v0();', 'return b - a;')
    fn('xr_%s4' % t, 'long', '%s a' % ty, 'return (long)a;')
    fn('xr_%s5' % t, ty, 'long a', 'return (%s)a;' % ty)
    fn('xr_%s6' % t, 'void', '%s a, %s b' % (ty, ty), '%s(b);' % v, '%s(a);' % v)
    fn('xr_%s7' % t, ty, 'int i, %s a' % ty, 'return %s[i & 7] + a;' % ga)
    fn('lo_%s0' % t, ty, 'void', '%s s = 0.0;' % ty, 'int i;', 'for (i = 0; i < 8; i++) s += %s[i];' % ga, 'return s;')
    fn('lo_%s1' % t, ty, 'void', '%s s = 1.0;' % ty, 'int i;', 'for (i = 1; i < 5; i++) s *= i;', 'return s * %s;' % g1)
    fn('lo_%s2' % t, ty, 'void', '%s s = %s[0];' % (ty, ga), 'int i;', 'for (i = 1; i < 8; i++) if (%s[i] > s) s = %s[i];' % (ga, ga), 'return s;')
for t, ty in FT.items():
    g1, g2, g3, ga, r = 'g%s1' % t, 'g%s2' % t, 'g%s3' % t, 'g%sa' % t, 'r' + t
    m = 'd' if t == 'd' else 'f'
    for o, op in (('a', '+'), ('s', '-'), ('m', '*'), ('d', '/')):
        y = '(%s * %s + 3.0)' % (g2, g2) if o == 'd' else g2
        fn('ai_%s%s' % (t, o), 'void', 'int i', '%s = %s[i & 7] %s %s;' % (g3, ga, op, y))
        fn('sp_%s%s' % (t, o), 'void', 'struct sv *p', 'p->%s = p->%s %s %s;' % (m, m, op, y))
    for i, ity in IT.items():
        fn('cr_%s%s' % (t, i), 'void', 'void', 'g%s3 = (%s)%s();' % (i, ity, r))
fn('ff_D', 'void', 'void', 'gd3 = gf1;'); fn('ff_F', 'void', 'void', 'gf3 = gd1;')
fn('ff_A', 'void', 'void', 'gd3 = gf1 + gd2;'); fn('ff_M', 'void', 'void', 'gf3 = gf1 * (float)gd2;')
fn('ff_P', 'double', 'float a', 'return a;'); fn('ff_Q', 'float', 'double a', 'return a;')
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(F), 'functions')
