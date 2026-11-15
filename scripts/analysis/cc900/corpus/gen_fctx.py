"""gen_fctx.py OUT.c: a wrong-code probe for multi-statement context (lane_o3), for semcheck first: functions of 3-8
statements over char / unsigned char / int / unsigned / long / unsigned long, built so that values live across calls,
long helpers and loops, register parameters are read after calls, and one base takes several stores.  No undefined
behaviour on purpose: every variable is assigned before it is read, loop bounds are constants, indices stay in 0..7,
divisors are odd and (signed) positive, signed values are only added / subtracted / combined bitwise, and every path
of a value-returning function returns.  Names: fx_<fam>_<t><variant>

  t  type: c char, b unsigned char, i int, u unsigned int, l long, n unsigned long
  lc<k>  a local live across a call: k 0 v0(), 1 v<t>(t) (the local passed), 2 a call returning <t> in between,
         3 two calls, 4 a call between two uses
  lh<k>  a local live across a long helper: k 0 gl3 = gl1 * gl2 (unsigned long), 1 / , 2 %, 3 a long helper in
         the local's own expression, 4 two helpers
  lp<k>  a local live across a loop: k 0 for summing an array, 1 while counting down, 2 do-while, 3 a call in the
         loop body, 4 the local updated in the loop
  rp<k>  register parameters read after a call (-Xr: a WA, b BC, c DE): k 0 v0(); return a + b, 1 the first parameter
         passed on, 2 three parameters across two calls, 3 a parameter updated after the call, 4 a parameter compared
         after the call
  lo<k>  loops: k 0 for with counter over an array, 1 while with a counter, 2 pointer walk, 3 do-while, 4 two arrays
         in one loop, 5 a loop storing into an array
  ie<k>  if / else chains writing one local: k 0 two arms, 1 three arms, 2 a call in one arm, 3 nested, 4 the local
         read in the test of the next if
  rl<k>  returns from inside a loop: k 0 found index, 1 found value, 2 early exit on a compare with a parameter,
         3 a while loop, 4 the loop's last value
  ss<k>  several stores through one base: k 0 array elements, 1 struct members, 2 members through a global pointer,
         3 members through a parameter pointer, 4 elements through a pointer, 5 a store read back
  cv<k>  a value computed before a call and used after: k 0 into a global, 1 returned, 2 compared, 3 passed to a
         second call, 4 combined with the call's result"""
import sys
T = {'c': 'char', 'b': 'unsigned char', 'i': 'int', 'u': 'unsigned int', 'l': 'long', 'n': 'unsigned long'}
out = ['/* lane_o3 wrong-code probe: multi-statement context; see gen_fctx.py for the name letters */']
for t, ty in T.items():
    out.append('extern %s g%s1, g%s2, g%s3, g%sa[8], g%sb[8], *g%sp;' % (ty, t, t, t, t, t, t))
    out.append('extern void v%s(%s); extern %s r%s(void); extern void w%s(%s, %s);' % (t, ty, ty, t, t, ty, ty))
out += ['struct sv { char c; unsigned char b; int i; unsigned int u; long l; unsigned long n; int a[4]; };',
        'extern struct sv gs, *gps;', 'extern void v0(void); extern int ri(void);',
        'extern long gl4; extern unsigned long gn4;']
F = []
def fn(name, rt, params, *stmts):
    F.append('%s fx_%s(%s) { %s }' % (rt, name, params, ' '.join(stmts)))
for t, ty in T.items():
    g1, g2, g3, ga, gb, gp = 'g%s1' % t, 'g%s2' % t, 'g%s3' % t, 'g%sa' % t, 'g%sb' % t, 'g%sp' % t
    v, r, w = 'v' + t, 'r' + t, 'w' + t
    # lc
    fn('lc_%s0' % t, 'void', 'void', '%s t = %s + %s;' % (ty, g1, g2), 'v0();', '%s = t ^ %s;' % (g3, g1))
    fn('lc_%s1' % t, 'void', 'void', '%s t = %s ^ %s;' % (ty, g1, g2), '%s(t);' % v, '%s = t + %s;' % (g3, g2))
    fn('lc_%s2' % t, 'void', 'void', '%s t = %s - %s;' % (ty, g1, g2), '%s = %s();' % (g2, r), '%s = t | %s;' % (g3, g2))
    fn('lc_%s3' % t, 'void', 'void', '%s t = %s & %s;' % (ty, g1, g2), 'v0();', '%s(%s);' % (v, g1), '%s = t;' % g3)
    fn('lc_%s4' % t, 'void', 'void', '%s t = %s;' % (ty, g1), '%s = t + %s;' % (g2, g2), 'v0();', '%s = t - %s;' % (g3, g2))
    # lh
    fn('lh_%s0' % t, 'void', 'void', '%s t = %s + 1;' % (ty, g1), 'gn4 = gn1 * gn2;', '%s = t ^ %s;' % (g3, g2))
    fn('lh_%s1' % t, 'void', 'void', '%s t = %s ^ %s;' % (ty, g1, g2), 'gl4 = gl1 / (gl2 & 0x7fff | 1);', '%s = t;' % g3)
    fn('lh_%s2' % t, 'void', 'void', '%s t = %s | 3;' % (ty, g1), 'gn4 = gn1 % (gn2 | 1);', '%s = t + %s;' % (g3, g1))
    fn('lh_%s3' % t, 'void', 'void', '%s t = %s;' % (ty, g1), 'gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1);', '%s = t - %s;' % (g3, g2))
    fn('lh_%s4' % t, 'void', 'void', '%s t = %s & %s;' % (ty, g1, g2), 'gn4 = gn1 * gn2;', 'gl4 = gl1 % (gl2 & 0x7fff | 1);', '%s = t ^ %s;' % (g3, g1))
    # lp
    fn('lp_%s0' % t, 'void', 'void', '%s t = %s;' % (ty, g1), 'int i;', '%s s = 0;' % ty,
       'for (i = 0; i < 8; i++) s += %s[i];' % ga, '%s = t ^ s;' % g3)
    fn('lp_%s1' % t, 'void', 'void', '%s t = %s + %s;' % (ty, g1, g2), 'int n = 5;', 'while (n-- > 0) %s ^= %s;' % (g2, g1), '%s = t;' % g3)
    fn('lp_%s2' % t, 'void', 'void', '%s t = %s;' % (ty, g2), 'int n = 0;', 'do { %s[n] = t; n++; } while (n < 6);' % gb, '%s = t + %s;' % (g3, g1))
    fn('lp_%s3' % t, 'void', 'void', '%s t = %s | %s;' % (ty, g1, g2), 'int i;', 'for (i = 0; i < 4; i++) %s(%s[i]);' % (v, ga), '%s = t;' % g3)
    fn('lp_%s4' % t, ty, 'void', '%s t = %s;' % (ty, g1), 'int i;', 'for (i = 0; i < 8; i++) t ^= %s[i];' % ga, 'return t;')
    # rp
    P2 = '%s a, %s b' % (ty, ty); P3 = '%s a, %s b, %s c' % (ty, ty, ty)
    fn('rp_%s0' % t, ty, P2, 'v0();', 'return a + b;')
    fn('rp_%s1' % t, ty, P2, '%s(a);' % v, 'return a ^ b;')
    fn('rp_%s2' % t, ty, P3, '%s(b);' % v, 'v0();', 'return (a - c) | b;')
    fn('rp_%s3' % t, ty, P2, '%s = %s();' % (g1, r), 'a += b;', 'return a ^ %s;' % g1)
    fn('rp_%s4' % t, 'int', P2, 'v0();', 'if (a > b) return 1;', 'return 2;')
    # lo
    fn('lo_%s0' % t, ty, 'void', '%s s = 0;' % ty, 'int i;', 'for (i = 0; i < 8; i++) s += %s[i];' % ga, 'return s;')
    fn('lo_%s1' % t, ty, 'void', '%s s = %s;' % (ty, g1), 'int n = 7;', 'while (n > 0) { s ^= %s[n]; n--; }' % ga, 'return s;')
    fn('lo_%s2' % t, ty, 'void', '%s *p = %s;' % (ty, ga), '%s s = 0;' % ty, 'while (p < %s + 8) s += *p++;' % ga, 'return s;')
    fn('lo_%s3' % t, 'void', 'void', 'int i = 0;', 'do { %s[i] = %s[i] ^ %s; i++; } while (i < 8);' % (gb, ga, g1), '%s = %s[7];' % (g3, gb))
    fn('lo_%s4' % t, ty, 'void', '%s s = 0;' % ty, 'int i;', 'for (i = 0; i < 8; i++) s += %s[i] & %s[i];' % (ga, gb), 'return s;')
    fn('lo_%s5' % t, 'void', 'void', 'int i;', 'for (i = 0; i < 8; i++) %s[i] = %s + %s[i];' % (gb, g1, ga), '%s = %s[3];' % (g3, gb))
    # ie
    fn('ie_%s0' % t, 'void', 'void', '%s t;' % ty, 'if (%s > %s) t = %s; else t = %s;' % (g1, g2, g1, g2), '%s = t;' % g3)
    fn('ie_%s1' % t, 'void', 'void', '%s t;' % ty, 'if (%s > %s) t = %s; else if (%s == %s) t = 5; else t = %s;' % (g1, g2, g1, g1, g2, g2), '%s = t + %s;' % (g3, g1))
    fn('ie_%s2' % t, 'void', 'void', '%s t;' % ty, 'if (%s != 0) t = %s(); else t = %s;' % (g1, r, g2), '%s = t ^ %s;' % (g3, g1))
    fn('ie_%s3' % t, 'void', 'void', '%s t = %s;' % (ty, g2), 'if (%s > 2) { if (%s < %s) t = %s; else t = 9; }' % (g1, g1, g2, g1), '%s = t;' % g3)
    fn('ie_%s4' % t, 'int', 'void', '%s t;' % ty, 'if (%s > %s) t = %s; else t = %s;' % (g1, g2, g1, g2), 'if (t == %s) return 1;' % g3, 'return 0;')
    # rl
    fn('rl_%s0' % t, 'int', 'void', 'int i;', 'for (i = 0; i < 8; i++) if (%s[i] == %s) return i;' % (ga, g1), 'return 9;')
    fn('rl_%s1' % t, ty, 'void', 'int i;', 'for (i = 0; i < 8; i++) if (%s[i] > %s) return %s[i];' % (ga, g1, ga), 'return %s;' % g2)
    fn('rl_%s2' % t, 'int', '%s a' % ty, 'int i;', 'for (i = 0; i < 8; i++) { if (%s[i] == a) return i; %s[i] = a; }' % (ga, gb), 'return 9;')
    fn('rl_%s3' % t, 'int', 'void', 'int i = 0;', 'while (i < 8) { if (%s[i] != %s[i]) return i; i++; }' % (ga, gb), 'return 9;')
    fn('rl_%s4' % t, ty, 'void', '%s s = 0;' % ty, 'int i;', 'for (i = 0; i < 8; i++) { s = %s[i]; if (s == %s) break; }' % (ga, g1), 'return s;')
    # ss
    fn('ss_%s0' % t, 'void', 'void', '%s[1] = %s;' % (ga, g1), '%s[2] = %s;' % (ga, g2), '%s[3] = %s[1] ^ %s[2];' % (ga, ga, ga))
    fn('ss_%s1' % t, 'void', 'void', 'gs.%s = %s;' % (t, g1), 'gs.i = gi1;', 'gs.l = gl1;', '%s = gs.%s;' % (g3, t))
    fn('ss_%s2' % t, 'void', 'void', 'gps->%s = %s;' % (t, g1), 'gps->i = gi2;', 'gps->a[2] = gi1;', '%s = gps->%s;' % (g3, t))
    fn('ss_%s3' % t, 'void', 'struct sv *p', 'p->%s = %s;' % (t, g1), 'p->a[1] = gi2;', 'p->a[3] = p->a[1] + gi1;', '%s = p->%s;' % (g3, t))
    fn('ss_%s4' % t, 'void', 'void', '%s[1] = %s;' % (gp, g1), '%s[4] = %s;' % (gp, g2), '%s = %s[1] + %s[4];' % (g3, gp, gp))
    fn('ss_%s5' % t, ty, 'void', '%s[5] = %s + %s;' % (ga, g1, g2), '%s[6] = %s[5] ^ %s;' % (ga, ga, g1), 'return %s[6];' % ga)
    # cv
    fn('cv_%s0' % t, 'void', 'void', '%s t = %s ^ %s;' % (ty, g1, g2), '%s(%s);' % (v, g3), '%s = t;' % g2)
    fn('cv_%s1' % t, ty, 'void', '%s t = %s + %s;' % (ty, g1, g2), 'v0();', 'return t;')
    fn('cv_%s2' % t, 'int', 'void', '%s t = %s;' % (ty, g1), '%s = %s();' % (g2, r), 'return t == %s;' % g2)
    fn('cv_%s3' % t, 'void', 'void', '%s t = %s - %s;' % (ty, g1, g2), 'v0();', '%s(t, %s);' % (w, g1))
    fn('cv_%s4' % t, ty, 'void', '%s t = %s | %s;' % (ty, g1, g2), 'return t ^ %s();' % r)
# more shapes per type
for t, ty in T.items():
    g1, g2, g3, ga, gb, gp = 'g%s1' % t, 'g%s2' % t, 'g%s3' % t, 'g%sa' % t, 'g%sb' % t, 'g%sp' % t
    v, r, w = 'v' + t, 'r' + t, 'w' + t
    fn('lp_%s5' % t, 'void', 'void', '%s t = %s ^ %s;' % (ty, g1, g2), 'int i;', 'for (i = 0; i < 4; i++) %s[i] = t;' % gb,
       'for (i = 4; i < 8; i++) %s[i] = %s;' % (gb, g1), '%s = t + %s[2];' % (g3, gb))
    fn('lo_%s6' % t, ty, '%s *p' % ty, '%s s = 0;' % ty, 'int i;', 'for (i = 0; i < 8; i++) s += p[i];', 'return s;')
    fn('lo_%s7' % t, ty, '%s *p' % ty, '%s s = %s;' % (ty, g1), 'int n = 8;', 'while (n--) s ^= *p++;', 'return s;')
    fn('rp_%s5' % t, ty, '%s a, %s b' % (ty, ty), '%s t = a + b;' % ty, 'v0();', 'return t ^ a;')
    fn('rp_%s6' % t, 'void', '%s a, %s b, %s c' % (ty, ty, ty), '%s = a;' % g1, '%s(b);' % v, '%s = c ^ a;' % g3)
    fn('ie_%s5' % t, 'void', 'void', '%s t;' % ty, 'if (%s > %s) t = %s(); else t = %s() ^ %s;' % (g1, g2, r, r, g1), '%s = t;' % g3)
    fn('cv_%s5' % t, 'void', 'void', '%s t = %s + %s;' % (ty, g1, g2), 'v0();', '%s[3] = t;' % ga, '%s[4] = t ^ %s;' % (ga, g1))
    fn('lc_%s5' % t, 'void', 'void', '%s t = %s;' % (ty, g1), 'int i;', 'for (i = 0; i < 3; i++) { v0(); %s[i] = t; }' % gb, '%s = t;' % g3)
# parameter variants: the families whose source is g<t>1 take it from a parameter instead (name suffix p)
import re
extra = []
for f_ in F:
    m = re.match(r'^(\S+(?: \S+)?) fx_(lc|lh|lp|ie|cv|ss)_(\w)(\d)\(void\) \{ (.*) \}$', f_)
    if not m: continue
    rt, fam, t, k, body = m.groups()
    if 'g%s1' % t not in body: continue
    extra.append('%s fx_%s_%s%sp(%s a) { %s }' % (rt, fam, t, k, T[t], re.sub(r'\bg%s1\b' % t, 'a', body)))
F += extra
# mixed types: a local of type t computed from globals of type d, live across a call / a loop (mx<k>), and register
# parameters of two types read after a call (mr)
for t, ty in T.items():
    for d, dty in T.items():
        if d == t: continue
        fn('mx_%s%s0' % (t, d), 'void', 'void', '%s t = (%s)(g%s1 + g%s2);' % (ty, ty, d, d), 'v0();', 'g%s3 = t;' % t)
        fn('mx_%s%s1' % (t, d), ty, 'void', '%s t = (%s)g%s1;' % (ty, ty, d), 'int i;', 'for (i = 0; i < 4; i++) t ^= (%s)g%sa[i];' % (ty, d), 'return t;')
        fn('mr_%s%s' % (t, d), ty, '%s a, %s b' % (ty, dty), 'v0();', 'return a ^ (%s)b;' % ty)
out += F
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(len(F), 'functions')
