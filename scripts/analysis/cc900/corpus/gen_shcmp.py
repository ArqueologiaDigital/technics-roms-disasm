"""gen_shcmp.py OUT.c: a probe for a char shifted or divided and then compared (lane_o3).  Phase 6 (oracle run
2026-11-16-5-p6-m2a, p6_m2a.c vari_int / vari_div) found that V4.23 compares (a >> 1) >= c and a / 2 >= c, a and c
unsigned chars, at the byte: ld A,(XSP+0x4) / srl 0x1,A / cp A,(XSP+0x6) / scc uge,HL (-Xr: srl 0x1,A / cp A,C), while
the model refuses ("complex compare operand").  No corpus row has the form, so this probe asks when the byte compare
is used: which shifts and divisors, a signed char divided, which right operands (a char, a constant, an int, a signed
char), which operators, in a value and in a branch, with parameters and with globals.  No undefined or
implementation-defined behaviour: a signed char is only divided (C99 truncation), never shifted.  Names:
  sc_<src>_<left>_<op>_<right>_<ctx>
  src    p parameters, g globals
  left   s1 a >> 1, s3 a >> 3, d2 a / 2, d4 a / 4, d3 a / 3 (unsigned char a);  D2 sa / 2 (signed char sa)
  op     ge >=, lt <, eq ==
  right  c an unsigned char, k the constant 5, i an int, S a signed char
  ctx    v return the truth value (int), b if (...) gi3 = 1; else gi3 = 2"""
import sys
LEFT = {'s1': ('a', '>>', 1), 's3': ('a', '>>', 3), 'd2': ('a', '/', 2), 'd4': ('a', '/', 4), 'd3': ('a', '/', 3),
        'D2': ('sa', '/', 2)}
OPS = {'ge': '>=', 'lt': '<', 'eq': '=='}
RIGHT = {'c': ('unsigned char', 'c'), 'k': (None, '5'), 'i': ('int', 'i'), 'S': ('signed char', 'sc')}
out = ['/* lane_o3 probe: a char shifted or divided, then compared; see gen_shcmp.py for the name letters */',
       'extern int gi3;', 'extern unsigned char ga, gc;', 'extern signed char gsa, gsc;', 'extern int gi;']
for src in ('p', 'g'):
    for ln, (lv, lop, lk) in LEFT.items():
        lt = 'signed char' if lv == 'sa' else 'unsigned char'
        for on, op in OPS.items():
            for rn, (rt, rv) in RIGHT.items():
                if rn == 'S' and ln not in ('s1', 'd2', 'D2'): continue
                if src == 'p':
                    params = ['%s %s' % (lt, lv)] + (['%s %s' % (rt, rv)] if rt else [])
                    L, R = lv, rv
                else:
                    params = ['void']
                    L = 'g' + lv
                    R = rv if rt is None else 'g' + rv
                cond = '(%s %s %d) %s %s' % (L, lop, lk, op, R)
                for ctx in ('v', 'b'):
                    nm = 'sc_%s_%s_%s_%s_%s' % (src, ln, on, rn, ctx)
                    if ctx == 'v':
                        out.append('int %s(%s) { return %s; }' % (nm, ', '.join(params), cond))
                    else:
                        out.append('void %s(%s) { if (%s) gi3 = 1; else gi3 = 2; }' % (nm, ', '.join(params), cond))
open(sys.argv[1], 'w').write('\n'.join(out) + '\n')
