#!/usr/bin/env python3
"""Generate the cc900 micro-test corpus: one C construct per function, grouped into files by topic.

usage: python3 -I -B gen_micro.py OUTDIR      (writes OUTDIR/micro/*.c and OUTDIR/micro-sources.txt)
Each function exercises one construct with one combination of operand kinds, so that an oracle listing of it shows
how cc900 compiles exactly that (notes/cc900-compat-plan-2026-11-08/PLAN.md, section 4.1).  Topics:
- binop_<type>: every binary operator at every integer type, operands from parameters, globals, locals and
  constants;
- unop_<type>: unary operators, increments, casts between types;
- cmp_<type>: comparisons used as values and as branch conditions;
- assign: compound assignments to globals, locals, through pointers and array elements;
- mem: pointer, array and struct member access, with constant and variable indices;
- ctrl: if/else, loops of each form, break/continue, early return, the ternary operator, && and ||;
- call: calls with 0-4 arguments of mixed types, nested calls, results used in expressions.
The output is deterministic, ours, and C89.
"""
import os, sys

INT_TYPES = [('c', 'char'), ('uc', 'unsigned char'), ('i', 'int'), ('ui', 'unsigned int'),
             ('l', 'long'), ('ul', 'unsigned long')]
BINOPS = [('add', '+'), ('sub', '-'), ('mul', '*'), ('div', '/'), ('mod', '%'), ('and', '&'), ('or', '|'),
          ('xor', '^'), ('shl', '<<'), ('shr', '>>')]
CMPOPS = [('eq', '=='), ('ne', '!='), ('lt', '<'), ('le', '<='), ('gt', '>'), ('ge', '>=')]

def binop_file(tk, t):
    out = ['/* Binary operators at type %s: parameters, globals, a constant, a local. */' % t,
           'extern %s g%s1, g%s2, g%s3;' % (t, tk, tk, tk)]
    for on, op in BINOPS:
        k = '3' if on in ('shl', 'shr') else ('10' if on in ('mul', 'div', 'mod') else '5')
        out.append('%s %s_%s_pp(%s a, %s b) { return a %s b; }' % (t, on, tk, t, t, op))
        out.append('%s %s_%s_pk(%s a) { return a %s %s; }' % (t, on, tk, t, op, k))
        out.append('void %s_%s_gg(void) { g%s1 = g%s2 %s g%s3; }' % (on, tk, tk, tk, op, tk))
        out.append('void %s_%s_gk(void) { g%s1 = g%s2 %s %s; }' % (on, tk, tk, tk, op, k))
        out.append('%s %s_%s_loc(%s a, %s b) { %s x = a %s b; return x %s a; }' % (t, on, tk, t, t, t, op, op))
    return out

def unop_file(tk, t):
    out = ['/* Unary operators, increments and casts at type %s. */' % t, 'extern %s g%s1, *gp%s;' % (t, tk, tk)]
    out += ['%s neg_%s(%s a) { return -a; }' % (t, tk, t), '%s not_%s(%s a) { return ~a; }' % (t, tk, t),
            'int lnot_%s(%s a) { return !a; }' % (tk, t),
            'void preinc_%s(void) { ++g%s1; }' % (tk, tk), 'void postdec_%s(void) { g%s1--; }' % (tk, tk),
            '%s preinc_val_%s(void) { return ++g%s1; }' % (t, tk, tk),
            '%s postinc_val_%s(void) { return g%s1++; }' % (t, tk, tk),
            '%s deref_inc_%s(void) { return *gp%s++; }' % (t, tk, tk)]
    for tk2, t2 in INT_TYPES:
        if tk2 != tk: out.append('%s cast_%s_%s(%s a) { return (%s)a; }' % (t2, tk, tk2, t, t2))
    return out

def cmp_file(tk, t):
    out = ['/* Comparisons at type %s: as values and as branch conditions. */' % t, 'extern %s g%s1;' % (t, tk),
           'extern void hit(void);']
    for on, op in CMPOPS:
        out.append('int %s_%s_val(%s a, %s b) { return a %s b; }' % (on, tk, t, t, op))
        out.append('void %s_%s_br(%s a, %s b) { if (a %s b) hit(); }' % (on, tk, t, t, op))
        out.append('void %s_%s_brk(%s a) { if (a %s 7) hit(); }' % (on, tk, t, op))
        out.append('void %s_%s_br0(%s a) { if (a %s 0) hit(); }' % (on, tk, t, op))
        out.append('void %s_%s_brg(void) { if (g%s1 %s 3) hit(); }' % (on, tk, tk, op))
    return out

def assign_file():
    out = ['/* Compound assignments to globals, locals, through pointers and to array elements. */',
           'extern int gi, ga[10]; extern long gl; extern char gc; extern int *gp;']
    for on, op in BINOPS:
        out.append('void as_%s_gi(int v) { gi %s= v; }' % (on, op))
        out.append('void as_%s_gl(long v) { gl %s= v; }' % (on, op))
        out.append('void as_%s_gc(char v) { gc %s= v; }' % (on, op))
        out.append('void as_%s_ptr(int *p, int v) { *p %s= v; }' % (on, op))
        out.append('void as_%s_arr(int i, int v) { ga[i] %s= v; }' % (on, op))
        out.append('int as_%s_loc(int a, int v) { a %s= v; return a; }' % (on, op))
    return out

def mem_file():
    return ['/* Pointer, array and struct member access. */',
            'struct s { char c; int i; long l; char *p; int a[4]; };',
            'extern struct s gs, *gps; extern int ga[10]; extern char gca[10]; extern long gla[10];',
            'int m_ga_k(void) { return ga[3]; }', 'int m_ga_v(int i) { return ga[i]; }',
            'char m_gca_v(int i) { return gca[i]; }', 'long m_gla_v(int i) { return gla[i]; }',
            'void m_ga_set(int i, int v) { ga[i] = v; }', 'int m_p_k(int *p) { return p[2]; }',
            'int m_p_v(int *p, int i) { return p[i]; }', 'long m_lp_v(long *p, int i) { return p[i]; }',
            'char m_cp_v(char *p, unsigned int i) { return p[i]; }',
            'int m_gs_i(void) { return gs.i; }', 'long m_gs_l(void) { return gs.l; }',
            'int m_gps_i(void) { return gps->i; }', 'int m_gps_a(int k) { return gps->a[k]; }',
            'void m_gps_set(int v) { gps->i = v; gps->c = 0; }',
            'int m_ps_i(struct s *p) { return p->i; }', 'char *m_ps_p(struct s *p) { return p->p; }',
            'int *m_addr(int i) { return &ga[i]; }', 'int m_diff(int *a, int *b) { return a - b; }',
            'int *m_padd(int *p, int i) { return p + i; }', 'void m_copy(struct s *d) { *d = gs; }',
            'int m_2d(int (*a)[4], int i, int j) { return a[i][j]; }']

def ctrl_file():
    return ['/* Control flow: if/else, loops, break/continue, early return, ?:, && and ||. */',
            'extern int gi; extern void f0(void); extern void f1(int); extern int g(int);',
            'int c_if(int a) { if (a) return 1; return 2; }',
            'int c_ifelse(int a, int b) { int r; if (a > b) r = a; else r = b; return r; }',
            'void c_ifchain(int a) { if (a == 1) f1(10); else if (a == 2) f1(20); else f1(30); }',
            'int c_tern(int a, int b) { return a < b ? a : b; }',
            'int c_and(int a, int b) { return a && b; }', 'int c_or(int a, int b) { return a || b; }',
            'void c_andbr(int a, int b) { if (a && b) f0(); }', 'void c_orbr(int a, int b) { if (a || b) f0(); }',
            'void c_for(int n) { int i; for (i = 0; i < n; i++) f1(i); }',
            'void c_fordown(int n) { int i; for (i = n; i > 0; i--) f1(i); }',
            'void c_while(int n) { while (n--) f0(); }', 'void c_do(int n) { do { f0(); } while (--n); }',
            'int c_sum(int *p, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }',
            'int c_find(int *p, int n, int k) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }',
            'void c_break(int n) { int i; for (i = 0; i < n; i++) { if (g(i)) break; f1(i); } }',
            'void c_cont(int n) { int i; for (i = 0; i < n; i++) { if (g(i)) continue; f1(i); } }',
            'void c_nested(int n) { int i, j; for (i = 0; i < n; i++) for (j = 0; j < i; j++) f1(i + j); }',
            'void c_inf(void) { for (;;) { if (g(gi)) return; f0(); } }',
            'int c_cnt(char *s) { int n = 0; while (*s++) n++; return n; }',
            'void c_clear(char *p, int n) { while (n-- > 0) *p++ = 0; }',
            'void c_copy(char *d, char *s, int n) { int i; for (i = 0; i < n; i++) d[i] = s[i]; }']

def call_file():
    return ['/* Calls: argument counts and types, nested calls, results in expressions. */',
            'extern void v0(void); extern void v1(int); extern void v2(int, int); extern void v3(int, long, char *);',
            'extern void v4(char, int, long, int); extern int r1(int); extern long rl(long); extern char rc(void);',
            'extern int gi; extern long gl; extern char gc, *gp;',
            'void k0(void) { v0(); }', 'void k1(void) { v1(gi); }', 'void k1k(void) { v1(5); }',
            'void k2(int a) { v2(a, gi); }', 'void k3(void) { v3(gi, gl, gp); }', 'void k4(int a) { v4(gc, a, gl, 3); }',
            'int k_expr(int a) { return r1(a) + r1(a + 1); }', 'int k_nest(int a) { return r1(r1(a)); }',
            'long k_l(long a) { return rl(a) * 2; }', 'int k_rc(void) { return rc() + 1; }',
            'void k_seq(int a) { v1(a); v1(a + 1); v1(a + 2); }', 'int k_keep(int a) { int x = r1(a); v0(); return x + a; }',
            'void k_cond(int a) { if (r1(a)) v0(); }', 'int k_tail(int a) { return r1(a); }']

def main():
    out = sys.argv[1]
    d = os.path.join(out, 'micro'); os.makedirs(d, exist_ok=True)
    files = {}
    for tk, t in INT_TYPES:
        files['binop_%s.c' % tk] = binop_file(tk, t)
        files['unop_%s.c' % tk] = unop_file(tk, t)
        files['cmp_%s.c' % tk] = cmp_file(tk, t)
    files['assign.c'] = assign_file(); files['mem.c'] = mem_file()
    files['ctrl.c'] = ctrl_file(); files['call.c'] = call_file()
    for n, lines in sorted(files.items()):
        open(os.path.join(d, n), 'w').write('\n'.join(lines) + '\n')
    open(os.path.join(out, 'micro-sources.txt'), 'w').write(''.join('micro/%s\n' % n for n in sorted(files)))
    print('%d files, %d functions' % (len(files), sum(sum(1 for l in v if '{' in l) for v in files.values())))

main()
