"""gen_stc.py OUT.c: a wrong-code probe for struct copies, struct parameters and struct returns (lane_o3), for semcheck
first.  V4.23 copies a struct with ldiw (XIX+),(XIY+) runs or ld BC,n / ldirw (XIX+),(XIY+) (abi structs.c,
returns.c), which take BC, XIX and XIY: the cx_ family keeps values live in those registers' neighbourhood.
No undefined behaviour on purpose: every object is assigned before it is read, no copy overlaps (two elements are
i & 3 and (i & 3) ^ 1, pointer parameters point into separate buffers), indices are masked, every path of a
value-returning function returns.  A member read from a struct rvalue ((g1 = g2).a, r().a) is left out: the
model's front end stops on its ExprWithCleanups node, which would fail the whole file.  Functions returning a struct are __cdecl (under -Xr an adecl function cannot
return one in memory, and semcheck's stub refuses an adecl callee with a memory result).
Types (struct s<k>; the field f0 is the one read or written alone):
  1 {char a}  2 {int a}  3 {char a, b, c}  4 {int a, b}  5 {char a, b, c, d, e}  6 {int a, b, c}
  8 {long a; int b, c}  C {long a, b; int c, d}  G {long a, b, c, d}  X {char c[33]}  N {struct s4 h; long x; int y}
  A {int v[5]}
Each type k has globals g<k>1..3, ga<k>[4], pointers gp<k>1 / gp<k>2, a wrapper struct w<k> {int k; struct s<k> m;
long z} gw<k>, gwa<k>[2], *gpw<k>, and externs r<k>() returning one, x<k>(s), y<k>(int, s, int), z<k>(long, s, double).
Names st_<fam>_<k>:
  copies   gg g1 = g2; gl a local initialised, a field set, copied out; lg a local live across a call;
           pp *d = *s (parameters); pi d[i & 3] = *s; gp *gp1 = *gp2; ae ga[i & 3] = ga[(i & 3) ^ 1];
           ag ga[gi1 & 3] = g2; mb gw.m = g2; bm g1 = gw.m; mw gwa[i & 1].m = gwa[(i & 1) ^ 1].m;
           ar gpw->m = g2; ch g1 = g2 = g3; lo a copy in a loop; if if / else arms; tc g1 = c ? g2 : g3;
           tp g1 = *(c ? gp1 : gp2); la a local array of two
  context  cx (int a, int b) a + b after a copy; cy (long a, long b, long c) after *gp1 = *gp2; cc (char a, int b);
           cl a loop counter and a sum live across a copy in the loop; cp (struct *d, int a) a * 3 after *d = g2
  passing  pa x(g2); pb y(a, g2, a + 1); pc z(gl1, g2, gd1); pd x(*p); pe x(ga[i & 3])
  params   pr g1 = s; pq (int a, s, int b) g1 = s and gi3 = a - b; pf return s.f0; pm s.f0 = 7 then g1 = s
  returns  rt return g2; rp return *p; rl a local with f0 = 9; rq return s; ri return ga[i & 3]; rc two returns
  results  ug g1 = r(); ul a local; um gw.m = r(); up *gp1 = r(); ud r() discarded; ux x(r()); ua ga[i & 3] = r(); uv (int a) g1 = r() then gi3 = a + 1"""
import sys
T = {'1': ('char a;', 'a', 'char'), '2': ('int a;', 'a', 'int'), '3': ('char a, b, c;', 'a', 'char'),
     '4': ('int a, b;', 'a', 'int'), '5': ('char a, b, c, d, e;', 'a', 'char'), '6': ('int a, b, c;', 'a', 'int'),
     '8': ('long a; int b, c;', 'a', 'long'), 'C': ('long a, b; int c, d;', 'a', 'long'),
     'G': ('long a, b, c, d;', 'a', 'long'), 'X': ('char c[33];', 'c[0]', 'char'),
     'N': ('struct s4 h; long x; int y;', 'h.a', 'int'), 'A': ('int v[5];', 'v[0]', 'int')}
out = ['/* lane_o3 wrong-code probe: struct copies, parameters and returns; see gen_stc.py for the name letters */',
       'extern int gi1, gi3; extern long gl1; extern double gd1; extern void v0(void);']
F = []
def fn(name, k, rt, params, *st):
    cd = ' __cdecl' if rt.startswith('struct') else ''
    F.append('%s%s st_%s_%s(%s) { %s }' % (rt, cd, name, k, params, ' '.join(st)))
for k, (body, f0, ft) in T.items():
    s = 'struct s%s' % k
    g1, g2, g3, ga, p1, p2 = 'g%s1' % k, 'g%s2' % k, 'g%s3' % k, 'ga%s' % k, 'gp%s1' % k, 'gp%s2' % k
    gw, gwa, gpw, r, x, y, z = 'gw%s' % k, 'gwa%s' % k, 'gpw%s' % k, 'r%s' % k, 'x%s' % k, 'y%s' % k, 'z%s' % k
    out += ['%s { %s };' % (s, body), 'struct w%s { int k; %s m; long z; };' % (k, s),
            'extern %s %s, %s, %s, %s[4], *%s, *%s;' % (s, g1, g2, g3, ga, p1, p2),
            'extern struct w%s %s, %s[2], *%s;' % (k, gw, gwa, gpw),
            'extern %s __cdecl %s(void); extern void %s(%s); extern void %s(int, %s, int); extern void %s(long, %s, double);'
            % (s, r, x, s, y, s, z, s)]
    fn('gg', k, 'void', 'void', '%s = %s;' % (g1, g2))
    fn('gl', k, 'void', 'void', '%s t = %s;' % (s, g2), 't.%s = 5;' % f0, '%s = t;' % g1)
    fn('lg', k, 'void', 'void', '%s t;' % s, 't = %s;' % g2, 'v0();', '%s = t;' % g1)
    fn('pp', k, 'void', '%s *d, %s *q' % (s, s), '*d = *q;')
    fn('pi', k, 'void', '%s *d, %s *q, int i' % (s, s), 'd[i & 3] = *q;')
    fn('gp', k, 'void', 'void', '*%s = *%s;' % (p1, p2))
    fn('ae', k, 'void', 'int i', '%s[i & 3] = %s[(i & 3) ^ 1];' % (ga, ga))
    fn('ag', k, 'void', 'void', '%s[gi1 & 3] = %s;' % (ga, g2))
    fn('mb', k, 'void', 'void', '%s.m = %s;' % (gw, g2))
    fn('bm', k, 'void', 'void', '%s = %s.m;' % (g1, gw))
    fn('mw', k, 'void', 'int i', '%s[i & 1].m = %s[(i & 1) ^ 1].m;' % (gwa, gwa))
    fn('ar', k, 'void', 'void', '%s->m = %s;' % (gpw, g2))
    fn('ch', k, 'void', 'void', '%s = %s = %s;' % (g1, g2, g3))
    fn('lo', k, 'void', 'int n', 'int i;', 'for (i = 0; i < (n & 3); i++) %s[i] = %s;' % (ga, g2))
    fn('if', k, 'void', 'int c', 'if (c) %s = %s; else %s = %s;' % (g1, g2, g1, g3))
    fn('tc', k, 'void', 'int c', '%s = c ? %s : %s;' % (g1, g2, g3))
    fn('tp', k, 'void', 'int c', '%s = *(c ? %s : %s);' % (g1, p1, p2))
    fn('la', k, 'void', 'void', '%s l[2];' % s, 'l[0] = %s;' % g2, 'l[1] = l[0];', '%s = l[1];' % g1)
    fn('cx', k, 'int', 'int a, int b', '%s = %s;' % (g1, g2), 'return a + b;')
    fn('cy', k, 'long', 'long a, long b, long c', '*%s = *%s;' % (p1, p2), 'return a - b + c;')
    fn('cc', k, 'char', 'char a, int b', '%s[b & 3] = %s;' % (ga, g2), 'return a;')
    fn('cl', k, 'int', 'int n', 'int i, t = 0;', 'for (i = 0; i < (n & 7); i++) { %s[i & 3] = %s; t += i; }' % (ga, g2),
       'return t;')
    fn('cp', k, 'int', '%s *d, int a' % s, '*d = %s;' % g2, 'return a * 3;')
    fn('pa', k, 'void', 'void', '%s(%s);' % (x, g2))
    fn('pb', k, 'void', 'int a', '%s(a, %s, a + 1);' % (y, g2))
    fn('pc', k, 'void', 'void', '%s(gl1, %s, gd1);' % (z, g2))
    fn('pd', k, 'void', '%s *p' % s, '%s(*p);' % x)
    fn('pe', k, 'void', 'int i', '%s(%s[i & 3]);' % (x, ga))
    fn('pr', k, 'void', '%s q' % s, '%s = q;' % g1)
    fn('pq', k, 'void', 'int a, %s q, int b' % s, '%s = q;' % g1, 'gi3 = a - b;')
    fn('pf', k, ft, '%s q' % s, 'return q.%s;' % f0)
    fn('pm', k, 'void', '%s q' % s, 'q.%s = 7;' % f0, '%s = q;' % g1)
    fn('rt', k, s, 'void', 'return %s;' % g2)
    fn('rp', k, s, '%s *p' % s, 'return *p;')
    fn('rl', k, s, 'void', '%s t;' % s, 't = %s;' % g2, 't.%s = 9;' % f0, 'return t;')
    fn('rq', k, s, '%s q' % s, 'return q;')
    fn('ri', k, s, 'int i', 'return %s[i & 3];' % ga)
    fn('rc', k, s, 'int c', 'if (c) return %s;' % g2, 'return %s;' % g3)
    fn('ug', k, 'void', 'void', '%s = %s();' % (g1, r))
    fn('ul', k, 'void', 'void', '%s t;' % s, 't = %s();' % r, '%s = t;' % g1)
    fn('um', k, 'void', 'void', '%s.m = %s();' % (gw, r))
    fn('up', k, 'void', 'void', '*%s = %s();' % (p1, r))
    fn('ud', k, 'void', 'void', '%s();' % r)
    fn('ux', k, 'void', 'void', '%s(%s());' % (x, r))
    fn('ua', k, 'void', 'int i', '%s[i & 3] = %s();' % (ga, r))
    fn('uv', k, 'void', 'int a', '%s = %s();' % (g1, r), 'gi3 = a + 1;')
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(F), 'functions')
