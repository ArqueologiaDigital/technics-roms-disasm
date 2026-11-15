"""gen_oexp.py OUT.c: a wrong-code probe for -O expression code (lane_o3's area), for semcheck first.  One statement
per function (two or three for the families that exercise the -O listing passes), over char / unsigned char / int /
unsigned / long / unsigned long.  No undefined behaviour on purpose: every variable is assigned before it is read,
divisors are forced odd (| 1) and, when signed, positive (& 0x7f | 1), shift counts are masked below the width, indices are constants in range or masked
(& 7), and every path of a value-returning function returns.  Names: oe_<fam>_<t><...>

  t  type: c char, b unsigned char, i int, u unsigned int, l long, n unsigned long
  ar_<t><o><k>   g? = x o y: o a + s - m * d / r % n & o | x ^ l << (by a constant) h >> (by a constant)
                 L << (by a variable, masked) H >> (by a variable, masked); k operands: G global op global, P
                 parameter op global, Q parameter op parameter, K global op constant, C constant op global
  cm_<t><c><f>   a compare: c e == n != l < g > L <= G >=; f the form: T g? = (x c y ? x : 7), I if (x c y) g? = x;
                 else g? = 3, R return (x c y ? 1 : 2), B return x c y (a truth value)
  lg_<t><o><f>   && / ||: o a &&, o ||; f T g? = (x > 3 o y != 0), I if (..) g? = 1; else g? = 2, R return (..)
  cs_<s><d>      a cast g<d> = (D)g<s>: every pair of the six types, both directions (narrow and widen)
  ca_<t><o><s>   a call in an operand: o a + s - m * x ^; s L r() o x, R x o r()
  un_<t><o><k>   unary: o n -x, c ~x, t !x; k G global, P parameter
  oa_<t><o><v>   op= on v G a global, L a local (assigned from a global, stored back), P a parameter (stored to a
                 global): o a += s -= x ^= n &= o |= l <<= 3 h >>= 3 m *= 3 i ++ (statement) j -- (statement)
  rp_<t><o>      register parameters (-Xr: a in WA, b in BC, c in DE): return (a o b) o2 c, o + - & | ^
  pa_<t><f>      -O listing passes: f S struct base CSE (gs.x = ..; gs.y = ..; gs.z = ..), C copy propagation
                 (T t = g1; g2 = t + g3;), R register reuse (g2 = g1 + 1; g3 = g1;), E element base reuse
                 (ga[1] = ..; ga[5] = ga[1] + ..), A address reuse through a pointer (gp->x = ..; gp->y = gp->x + ..),
                 W a global written then read (g1 = g2 * 3; g3 = g1 - g2)"""
import sys
T = {'c': 'char', 'b': 'unsigned char', 'i': 'int', 'u': 'unsigned int', 'l': 'long', 'n': 'unsigned long'}
BITS = {'c': 8, 'b': 8, 'i': 16, 'u': 16, 'l': 32, 'n': 32}
G = {t: ('g%s1' % t, 'g%s2' % t, 'g%s3' % t) for t in T}
out = ['/* lane_o3 wrong-code probe: -O expression code; see gen_oexp.py for the name letters */']
for t, ty in T.items():
    out.append('extern %s g%s1, g%s2, g%s3, g%sa[8];' % (ty, t, t, t, t))
out += ['struct sv { char c; int i; long l; unsigned int u; char c2; int i2; long l2; };',
        'extern struct sv gs, *gps;',
        'extern char rc(void); extern unsigned char rb(void); extern int ri(void); extern unsigned int ru(void);',
        'extern long rl(void); extern unsigned long rn(void);']
RF = {'c': 'rc', 'b': 'rb', 'i': 'ri', 'u': 'ru', 'l': 'rl', 'n': 'rn'}
F = []
def fn(name, rt, params, body):
    F.append('%s oe_%s(%s) { %s }' % (rt, name, params, body))
OPS = {'a': '+', 's': '-', 'm': '*', 'd': '/', 'r': '%', 'n': '&', 'o': '|', 'x': '^', 'l': '<<', 'h': '>>', 'L': '<<', 'H': '>>'}
for t, ty in T.items():
    g1, g2, g3 = G[t]; w = BITS[t]; unsigned = t in 'bun'
    P2 = '%s a, %s b' % (ty, ty)
    # ar
    for o, op in OPS.items():
        if o in 'ml' and not unsigned: continue            # (signed overflow / negative left shifts: UB)
        if o in 'lL' and t == 'n': pass
        for k in 'GPQKC':
            if o in 'lh':
                if k not in 'GP': continue
                x = g1 if k == 'G' else 'a'; e = '%s %s %d' % (x, op, min(3, w - 1))
            elif o in 'LH':
                if k not in 'GP': continue
                x = g1 if k == 'G' else 'a'; e = '%s %s (%s & %d)' % (x, op, g2, w - 1)
            else:
                x, y = {'G': (g1, g2), 'P': ('a', g2), 'Q': ('a', 'b'), 'K': (g1, '5'), 'C': ('9', g1)}[k]
                if o in 'dr':                              # (a divisor never 0: forced odd)
                    if k == 'C': y = '(%s | 1)' % g1; x = '9'
                    elif k == 'K': y = '5'
                    else: y = '(%s | 1)' % y
                    if not unsigned and k != 'K': y = '(%s & 0x7f | 1)' % y.strip('()').replace(' | 1', '')   # (no INT_MIN / -1)
                e = '%s %s %s' % (x, op, y)
            fn('ar_%s%s%s' % (t, o, k), 'void', P2 if k in 'PQ' else 'void', '%s = %s;' % (g3, e))
    # cm
    for c, cop in {'e': '==', 'n': '!=', 'l': '<', 'g': '>', 'L': '<=', 'G': '>='}.items():
        fn('cm_%s%sT' % (t, c), 'void', 'void', '%s = (%s %s %s ? %s : 7);' % (g3, g1, cop, g2, g1))
        fn('cm_%s%sI' % (t, c), 'void', 'void', 'if (%s %s %s) %s = %s; else %s = 3;' % (g1, cop, g2, g3, g1, g3))
        fn('cm_%s%sR' % (t, c), 'int', P2, 'return (a %s %s ? 1 : 2);' % (cop, g2))
        fn('cm_%s%sB' % (t, c), 'int', P2, 'return a %s b;' % cop)
    # lg
    for o, lop in (('a', '&&'), ('o', '||')):
        e = '(%s > 3 %s %s != 0)' % (g1, lop, g2)
        fn('lg_%s%sT' % (t, o), 'void', 'void', '%s = %s;' % (g3, e))
        fn('lg_%s%sI' % (t, o), 'void', 'void', 'if %s %s = 1; else %s = 2;' % (e, g3, g3))
        fn('lg_%s%sR' % (t, o), 'int', P2, 'return (a > 3 %s b != 0);' % lop)
    # cs
    for d, dty in T.items():
        if d != t: fn('cs_%s%s' % (t, d), 'void', 'void', '%s = (%s)%s;' % (G[d][2], dty, g1))
    # ca
    for o, op in (('a', '+'), ('s', '-'), ('m', '*'), ('x', '^')):
        if o == 'm' and not unsigned: continue
        fn('ca_%s%sL' % (t, o), 'void', 'void', '%s = %s() %s %s;' % (g3, RF[t], op, g1))
        fn('ca_%s%sR' % (t, o), 'void', 'void', '%s = %s %s %s();' % (g3, g1, op, RF[t]))
    # un
    for o, op in (('n', '-'), ('c', '~'), ('t', '!')):
        fn('un_%s%sG' % (t, o), 'void', 'void', '%s = %s%s;' % (g3, op, g1))
        fn('un_%s%sP' % (t, o), 'void', P2, '%s = %s%s;' % (g3, op, 'a'))
    # oa
    OA = {'a': '+= %s' % g2, 's': '-= %s' % g2, 'x': '^= %s' % g2, 'n': '&= %s' % g2, 'o': '|= %s' % g2,
          'l': '<<= 3', 'h': '>>= 3', 'm': '*= 3', 'i': '++', 'j': '--'}
    for o, rhs in OA.items():
        if o in 'lm' and not unsigned: continue
        st = (lambda v: '%s%s;' % (v, rhs) if o in 'ij' else '%s %s;' % (v, rhs))
        fn('oa_%s%sG' % (t, o), 'void', 'void', st(g1))
        fn('oa_%s%sL' % (t, o), 'void', 'void', '%s t = %s; %s %s = t;' % (ty, g1, st('t'), g3))
        fn('oa_%s%sP' % (t, o), 'void', P2, '%s %s = a;' % (st('a'), g3))
    # rp
    for o, op in (('a', '+'), ('s', '-'), ('n', '&'), ('o', '|'), ('x', '^')):
        fn('rp_%s%s' % (t, o), ty, '%s a, %s b, %s c' % (ty, ty, ty), 'return (a %s b) %s c;' % (op, '^' if op != '^' else '+'))
    # ck: a compare with a constant
    for c, cop in {'e': '==', 'n': '!=', 'l': '<', 'g': '>', 'L': '<=', 'G': '>='}.items():
        fn('ck_%s%sT' % (t, c), 'void', 'void', '%s = (%s %s 5 ? %s : %s);' % (g3, g1, cop, g2, g1))
        fn('ck_%s%sI' % (t, c), 'int', P2, 'if (a %s 0) return 4; return 9;' % cop)
    # el: an element at a masked index
    for o, op in (('a', '+'), ('s', '-'), ('n', '&'), ('o', '|'), ('x', '^')):
        fn('el_%s%sP' % (t, o), 'void', P2, '%s = g%sa[a & 7] %s %s;' % (g3, t, op, g2))
        fn('el_%s%sS' % (t, o), 'void', P2, 'g%sa[b & 7] = %s %s a;' % (t, g1, op))
    # mx: mixed types (the usual conversions)
    for d, dty in T.items():
        if d == t: continue
        fn('mx_%s%sA' % (t, d), 'void', 'void', '%s = %s + %s;' % (G[d][2], g1, G[d][1]))
        fn('mx_%s%sX' % (t, d), 'void', 'void', '%s = %s ^ %s;' % (G[t][2], g1, G[d][1]))
        fn('mx_%s%sC' % (t, d), 'int', 'void', 'return %s < %s;' % (g1, G[d][1]))
    # pa
    fn('pa_%sS' % t, 'void', 'void', 'gs.c = (char)%s; gs.i = (int)%s; gs.l = (long)%s;' % (g1, g2, g3))
    fn('pa_%sC' % t, 'void', 'void', '%s t = %s; %s = t + %s;' % (ty, g1, g2, g3))
    fn('pa_%sR' % t, 'void', 'void', '%s = %s + 1; %s = %s;' % (g2, g1, g3, g1))
    fn('pa_%sE' % t, 'void', 'void', 'g%sa[1] = %s; g%sa[5] = g%sa[1] + %s;' % (t, g1, t, t, g2))
    fn('pa_%sA' % t, 'void', 'void', 'gps->i = (int)%s; gps->i2 = gps->i + (int)%s;' % (g1, g2))
    fn('pa_%sW' % t, 'void', 'void', '%s = %s %s 3; %s = %s - %s;' % (g1, g2, '*' if unsigned else '+', g3, g1, g2))
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(F), 'functions')
