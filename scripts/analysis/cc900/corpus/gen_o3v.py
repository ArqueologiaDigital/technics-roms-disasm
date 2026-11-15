"""gen_o3v.py OUT.c: a probe for lane_o3's rules without evidence outside training (19 GUARD_DIV_DE, 21
XR_UNARY_ARG_BC, 22 SHIFT_RMW_XBC, 26 PTR_TEST_KEEP), each shape varied, with controls where the rule must not fire.
Names (t: c char, i int, u unsigned int, l long):
  gd_<t><d><x><s>  if (D != 0) S = X / D (19).  d: G global, M member through a pointer; x: G global, K constant, P
                   parameter; s: D member through a pointer with a displacement (fires), Z member at offset 0 (*p-like,
                   control), S a global (control), R a remainder % into a displaced member (control: the rule is /)
  ua_<t><o><x><c>  a negated / complemented argument (21, -Xr).  o: n -x, c ~x; x: G global, P parameter, I a local
                   kept across a call (IZ), M member through a pointer; c: 1 f(-x) as a statement, T return f(-x),
                   2 f(-x, gi) (control: BC holds the second argument), 3 f(gi, -x) (control)
  sr_<t><p><k><o>  a shift assigned through a pointer (22).  p: G global pointer, S stack parameter pointer, R the first
                   (-Xr register) parameter pointer (control); k: D *p, M p->m, A p[2]; o: l <<= 3, r >>= 3,
                   v >>= n (variable count, control)
  pt_<t><p><u>     if (*p != 0) .. (26).  p: S stack parameter pointer, G global pointer; u: D gi3 = gs.mi / *p,
                   A gi3 = gi + *p, W *p = gi (a store through it), N gi3 = gi (control: no use of p),
                   I p++ before the use (control)"""
import sys
TY = {'c': 'char', 'i': 'int', 'u': 'unsigned int', 'l': 'long'}
MEM = {'c': 'mc', 'i': 'mi', 'u': 'mu', 'l': 'ml'}
GV = {'c': ('gc', 'hc'), 'i': ('gi', 'hi'), 'u': ('gu', 'hu'), 'l': ('gl', 'hl')}
out = ['/* lane_o3 verification probe (rules 19, 21, 22, 26): see gen_o3v.py for the name letters */',
       'struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; int ma[4];',
       '            char mc2; int mi2; unsigned int mu2; long ml2; };',
       'extern struct sv gs, *gps, *hps;',
       'extern char gc, hc, jc, *gcp; extern int gi, hi, ji, gi3, *gip; extern unsigned int gu, hu, ju, *gup;',
       'extern long gl, hl, jl, *glp;',
       'extern void fc(char); extern void fi(int); extern void fu(unsigned int); extern void fl(long);',
       'extern char rc(char); extern int ri(int); extern unsigned int ru(unsigned int); extern long rl(long);',
       'extern void fc2(char, int); extern void fi2(int, int); extern void fu2(unsigned int, int); extern void fl2(long, int);',
       'extern void gc2(int, char); extern void gi2f(int, int); extern void gu2f(int, unsigned int); extern void gl2f(int, long);',
       'extern void v0(void);']
# 19
for t in 'ciu':
    ty = TY[t]; g, h = GV[t]; m = MEM[t]
    for dn, D in (('G', h), ('M', 'hps->' + m)):
        for xn, X in (('G', g), ('K', '100'), ('P', 'a')):
            for sn in 'DZSR':
                if sn == 'D': st = 'gps->%s2 = %s / %s;' % (m, X, D)
                elif sn == 'Z': st = 'gps->mc = %s / %s;' % (X, D) if t == 'c' else '*%s = %s / %s;' % ({'i': 'gip', 'u': 'gup'}[t], X, D)
                elif sn == 'S': st = 'j%s = %s / %s;' % (t, X, D)
                else: st = 'gps->%s2 = %s %% %s;' % (m, X, D)
                out.append('void gd_%s%s%s%s(%s a) { if (%s != 0) %s }' % (t, dn, xn, sn, ty, D, st))
# 21
for t in 'iul':
    ty = TY[t]; g = GV[t][0]; m = MEM[t]
    f1 = {'i': 'fi', 'u': 'fu', 'l': 'fl'}[t]; r1 = {'i': 'ri', 'u': 'ru', 'l': 'rl'}[t]
    f2 = {'i': 'fi2', 'u': 'fu2', 'l': 'fl2'}[t]; f3 = {'i': 'gi2f', 'u': 'gu2f', 'l': 'gl2f'}[t]
    for on, o in (('n', '-'), ('c', '~')):
        for xn in 'GPIM':
            for cn in '1T23':
                if xn == 'G': pre, x = '', g
                elif xn == 'P': pre, x = '', 'a'
                elif xn == 'I': pre, x = '%s t = %s; v0(); ' % (ty, g), 't'
                else: pre, x = '', 'gps->' + m
                e = '%s%s' % (o, x)
                if cn == '1': body, rt = '%s(%s);' % (f1, e), 'void'
                elif cn == 'T': body, rt = 'return %s(%s);' % (r1, e), ty
                elif cn == '2': body, rt = '%s(%s, gi);' % (f2, e), 'void'
                else: body, rt = '%s(gi, %s);' % (f3, e), 'void'
                out.append('%s ua_%s%s%s%s(%s a) { %s%s }' % (rt, t, on, xn, cn, ty, pre, body))
# 22
for t in 'ciul':
    ty = TY[t]; m = MEM[t]
    gp = {'c': 'gcp', 'i': 'gip', 'u': 'gup', 'l': 'glp'}[t]
    for pn in 'GSR':
        for kn in 'DMA':
            if kn == 'M' and t != 'i' and t != 'l' and t != 'c' and t != 'u': continue
            for on, op in (('l', '<<= 3'), ('r', '>>= 3'), ('v', '>>= n')):
                if pn == 'G': P = 'gps' if kn == 'M' else gp; params = 'int n'
                elif pn == 'S': P = 'p'; params = 'int n, long z, %s p' % ('struct sv *' if kn == 'M' else ty + ' *')
                else: P = 'p'; params = '%s p, int n' % ('struct sv *' if kn == 'M' else ty + ' *')
                lv = {'D': '*%s' % P, 'M': '%s->%s2' % (P, m), 'A': '%s[2]' % P}[kn]
                out.append('void sr_%s%s%s%s(%s) { %s %s; }' % (t, pn, kn, on, params.replace('* ', '*'), lv, op))
# 26
for t in 'ci':
    ty = TY[t]
    gp = {'c': 'gcp', 'i': 'gip'}[t]
    for pn in 'SG':
        P = 'p' if pn == 'S' else gp
        params = 'long z, %s *p' % ty if pn == 'S' else 'void'
        for un in 'DAWNI':
            if un == 'D': st = 'gi3 = gs.mi / *%s;' % P
            elif un == 'A': st = 'gi3 = gi + *%s;' % P
            elif un == 'W': st = '*%s = %s;' % (P, GV[t][0])
            elif un == 'N': st = 'gi3 = gi;'
            else: st = '%s++; gi3 = gi + *%s;' % (P, P)
            out.append('void pt_%s%s%s(%s) { if (*%s != 0) { %s } }' % (t, pn, un, params, P, st))
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
print(sum(1 for l in out if l.startswith(('void', 'int', 'char', 'unsigned', 'long'))), 'functions')
