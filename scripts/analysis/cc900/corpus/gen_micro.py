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
- call: calls with 0-4 arguments of mixed types, nested calls, results used in expressions;
- ra_leaf, ra_call: register allocation, varying the number, types and uses of variables, loops and calls;
- opt_loops: the -O3 loop optimizations (hoisting, induction variables, address CSE, bounds, rotation);
- rules: shapes of the library routines whose code changed between V4.23 and 2003 (rule triggers);
- switch: switch statements with statement bodies (jump tables, compare chains, ranges), at int, char,
  unsigned and long, the shapes of the firmware's event handlers (dispatch on a long event code).
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

def ra_files():
    """register allocation: which variable gets which register, by count, type, use, calls and loops"""
    leaf = ['/* Register allocation in leaf functions: locals and parameters in loops, returned or not. */',
            'extern int ga[10]; extern char gca[10]; extern long gla[10];']
    for n in range(1, 6):
        vs = ['v%d' % i for i in range(n)]
        decl = 'int %s;' % ', '.join(vs)
        init = ' '.join('%s = %d;' % (v, i) for i, v in enumerate(vs))
        body = ' '.join('%s += ga[i];' % v for v in vs)
        leaf.append('int ra_leaf%d(int k) { int i; %s %s for (i = 0; i < k; i++) { %s } return v0; }' % (n, decl, init, body))
        leaf.append('int ra_leafsum%d(int k) { int i; %s %s for (i = 0; i < k; i++) { %s } return %s; }'
                    % (n, decl, init, body, ' + '.join(vs)))
    leaf += ['long ra_long(int k) { int i; long s = 0; for (i = 0; i < k; i++) s += gla[i]; return s; }',
             'char ra_char(int k) { int i; char c = 0; for (i = 0; i < k; i++) c ^= gca[i]; return c; }',
             'int ra_ptr(int *p, int k) { int s = 0; while (k--) s += *p++; return s; }',
             'int ra_ptr2(int *p, int *q, int k) { int s = 0; while (k--) s += *p++ * *q++; return s; }',
             'void ra_ptrcpy(char *d, char *s) { while (*s) *d++ = *s++; *d = 0; }',
             'int ra_param3(int a, int b, int c) { int i, s = 0; for (i = 0; i < a; i++) s += b * c; return s; }',
             'int ra_noloop(int a, int b) { int x = a + b; int y = a - b; return x * y; }',
             'int ra_noloop3(int a, int b) { int x = a + b; int y = a - b; int z = x * y; return z + x + y; }',
             'int ra_twice(int a) { int x = a * 3; ga[0] = x; ga[1] = x; return x; }',
             'void ra_dowhile(int n) { do { ga[n] = 0; } while (--n); }',
             'void ra_while(int n) { while (n--) ga[n] = 0; }',
             'void ra_for_down(int n) { int i; for (i = n; i > 0; i--) ga[i] = 0; }',
             'int ra_nested(int n) { int i, j, s = 0; for (i = 0; i < n; i++) for (j = 0; j < n; j++) s += i * j; return s; }']
    call = ['/* Register allocation across calls: what goes to IZ / QIZ, and what stays in memory. */',
            'extern void f0(void); extern void f1(int); extern int g1(int); extern long gl1(long); extern int ga[10];']
    for n in range(1, 5):
        vs = ['v%d' % i for i in range(n)]
        call.append('int rc_keep%d(int a) { int %s; %s f0(); return %s; }' % (n, ', '.join(vs),
                    ' '.join('%s = a + %d;' % (v, i) for i, v in enumerate(vs)), ' + '.join(vs)))
        call.append('void rc_loop%d(int k) { int i, %s; %s for (i = 0; i < k; i++) { f1(%s); } }' % (n, ', '.join(vs),
                    ' '.join('%s = %d;' % (v, i) for i, v in enumerate(vs)), ' + '.join(vs)))
    call += ['int rc_param(int a, int b) { f0(); return a + b; }',
             'int rc_param_twice(int a) { f1(a); f1(a); return a; }',
             'int rc_param_thrice(int a) { f1(a); f1(a); f1(a); return a; }',
             'long rc_long(long a) { long x = gl1(a); f0(); return x + a; }',
             'int rc_ptr(int *p) { f0(); return *p; }',
             'int rc_ptr_loop(int *p, int n) { int s = 0; while (n--) s += g1(*p++); return s; }',
             'int rc_two_loops(int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(i); for (i = 0; i < n; i++) s -= g1(i); return s; }',
             'void rc_dowhile(int n) { do { f0(); } while (--n); }',
             'void rc_while(int n) { while (n--) f0(); }',
             'void rc_while2(int n) { while (n-- > 0) f0(); }',
             'void rc_for(int n) { int i; for (i = 0; i < n; i++) f0(); }']
    return {'ra_leaf.c': leaf, 'ra_call.c': call}

def opt_loop_files():
    """-O3 loop optimizations: hoisting, induction variables, CSE of addresses, bounds in registers, rotation"""
    out = ['/* -O3 loops: what is hoisted, which induction variables appear, where the bound lives. */',
           'extern int ga[10], gb[10]; extern char gca[10]; extern long gla[10]; extern int gn; extern int *gp;']
    for tk, t, arr in (('i', 'int', 'ga'), ('l', 'long', 'gla'), ('c', 'char', 'gca')):
        for n in range(1, 4):
            acc = ['s%d' % k for k in range(n)]
            out.append('%s ol_%s_acc%d(int k) { int i; %s %s; %s for (i = 0; i < k; i++) { %s } return %s; }' % (
                t, tk, n, t, ', '.join(acc), ' '.join('%s = 0;' % a for a in acc),
                ' '.join('%s += %s[i];' % (a, arr) for a in acc), ' + '.join(acc)))
        out.append('%s ol_%s_const(void) { int i; %s s = 0; for (i = 0; i < 10; i++) s += %s[i]; return s; }' % (t, tk, t, arr))
        out.append('%s ol_%s_glob(void) { int i; %s s = 0; for (i = 0; i < gn; i++) s += %s[i]; return s; }' % (t, tk, t, arr))
        out.append('void ol_%s_clear(int k) { int i; for (i = 0; i < k; i++) %s[i] = 0; }' % (tk, arr))
        out.append('void ol_%s_copy(int k) { int i; for (i = 0; i < k; i++) gb[i] = (int)%s[i]; }' % (tk, arr))
    out += ['int ol_idx_use(int k) { int i, s = 0; for (i = 0; i < k; i++) s += ga[i] * i; return s; }',
            'int ol_two_arr(int k) { int i, s = 0; for (i = 0; i < k; i++) s += ga[i] + gb[i]; return s; }',
            'int ol_ptr(int *p, int k) { int i, s = 0; for (i = 0; i < k; i++) s += p[i]; return s; }',
            'int ol_ptr_walk(int *p, int k) { int s = 0; while (k--) s += *p++; return s; }',
            'int ol_gptr(int k) { int i, s = 0; for (i = 0; i < k; i++) s += gp[i]; return s; }',
            'void ol_down(int k) { int i; for (i = k; i > 0; i--) ga[i] = 0; }',
            'void ol_while(int k) { int i = 0; while (i < k) { ga[i] = i; i++; } }',
            'void ol_do(int k) { int i = 0; do { ga[i] = 0; i++; } while (i < k); }',
            'int ol_nested(int k) { int i, j, s = 0; for (i = 0; i < k; i++) for (j = 0; j < k; j++) s += ga[j]; return s; }',
            'int ol_inv(int k, int a, int b) { int i, s = 0; for (i = 0; i < k; i++) s += a * b; return s; }',
            'void ol_strcpy(char *d, char *s) { while ((*d++ = *s++) != 0) ; }',
            'int ol_strlen(char *s) { int n = 0; while (*s++) n++; return n; }']
    return {'opt_loops.c': out}

def rule_files():
    """shapes that trigger the V4.23-to-2003 changes seen in the library (phase0.md, section 3)"""
    out = ['/* Rule triggers: shapes of the library routines whose code changed between V4.23 and 2003. */',
           'struct pr { long q, r; }; struct pi { int q, r; };',
           'extern void *mchr(const void *, int, unsigned int); extern void *mcpy(void *, const void *, unsigned int);',
           'extern int g1(int); extern void f0(void);',
           'struct pr r_divmod(long x, long y) { struct pr r; struct pr *p = &r; if (y) { p->q = x / y; p->r = x % y; } return r; }',
           'struct pi r_divmod_i(int x, int y) { struct pi r; struct pi *p = &r; p->q = x / y; p->r = x % y; return r; }',
           'void r_buf(char *out, unsigned long v) { char buf[16]; char *p = buf + 15; *p = 0; do { *--p = (char)(v % 10) + 48; v /= 10; } while (v); mcpy(out, p, (buf + 16) - p); }',
           'void r_buf2(char *out) { char buf[8]; char *p; p = buf; p[7] = 0; mcpy(out, p, 8); }',
           'void *r_ccpy(void *d, const void *s, int c, unsigned int n) { char *e = mchr(s, c, n); if (e == 0) { mcpy(d, s, n); return 0; } mcpy(d, s, e - (char *)s + 1); return (char *)d + (e - (char *)s) + 1; }',
           'char *r_rchr(char *s, int c, unsigned int n) { char *p = s + n; while (n--) if (*--p == (char)c) return p; return 0; }',
           'void r_countdown(char *p, unsigned int n) { while (n--) *p++ = 0; }',
           'int r_countdown2(int *p, unsigned int n) { int s = 0; do { s += *p++; } while (--n); return s; }',
           'char *r_rev(char *s, unsigned int n) { char *a = s, *b = s + n - 1, t; while (a < b) { t = *a; *a++ = *b; *b-- = t; } return s; }',
           'int r_keep(int a, int b) { int x = g1(a); int y = g1(b); f0(); return x + y + a; }',
           'long r_lkeep(long a) { long x = a * 3; long *p = &x; *p += a; return *p; }']
    return {'rules.c': out}

def switch_files():
    """switch statements: when a jump table, when a compare chain, how ranges and defaults are tested, and how the
    case bodies are laid out (the firmware dispatches on long event codes through 16-bit offset tables)"""
    out = ['/* Switch statements with statement bodies. */',
           'extern void f0(void); extern void f1(int); extern int g1(int); extern int gi; extern long gl;']
    body6 = 'case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; ' \
            'case 4: f1(14); break; case 5: f1(15); break;'
    out += [
        'void sw_jt6(int x) { switch (x) { %s } }' % body6,
        'void sw_jt6d(int x) { switch (x) { %s default: f0(); break; } }' % body6,
        'void sw_jt3(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 2: f1(3); break; } }',
        'void sw_jt4(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 2: f1(3); break; case 3: f1(4); break; } }',
        'void sw_jt8(int x) { switch (x) { case 0: f0(); break; case 1: f1(1); break; case 2: f1(2); break; case 3: f1(3); break; '
        'case 4: f1(4); break; case 5: f1(5); break; case 6: f1(6); break; case 7: f1(7); break; } }',
        'void sw_jtoff(int x) { switch (x) { case 10: f1(1); break; case 11: f1(2); break; case 12: f1(3); break; '
        'case 13: f1(4); break; case 14: f1(5); break; case 15: f1(6); break; } }',
        'void sw_jthole(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 3: f1(3); break; '
        'case 4: f1(4); break; case 6: f1(5); break; case 7: f1(6); break; } }',
        'void sw_jtu(unsigned int x) { switch (x) { %s } }' % body6,
        'void sw_jtc(char x) { switch (x) { %s } }' % body6,
        'void sw_jtuc(unsigned char x) { switch (x) { %s } }' % body6,
        'void sw_jtl(long x) { switch (x) { %s } }' % body6,
        'void sw_jtlu(unsigned long x) { switch (x) { %s } }' % body6,
        'void sw_jtg(void) { switch (gi) { %s } }' % body6,
        'void sw_jtgl(void) { switch (gl) { %s } }' % body6,
        'void sw_fall(int x) { switch (x) { case 0: f0(); case 1: f1(1); break; case 2: case 3: f1(2); break; '
        'case 4: f1(4); case 5: f1(5); break; } }',
        'int sw_ret(int x) { switch (x) { case 0: return g1(1); case 1: return g1(2); case 2: return g1(3); '
        'case 3: return g1(4); case 4: return g1(5); case 5: return g1(6); } return 0; }',
        'int sw_local(int x) { int r = 0; switch (x) { case 0: r = 5; break; case 1: r = gi; break; case 2: r = g1(x); break; '
        'case 3: r = x + 1; break; case 4: r = -1; break; case 5: r = 7; break; } return r; }',
        'void sw_sparse(int x) { switch (x) { case 1: f1(1); break; case 100: f1(2); break; case 1000: f1(3); break; '
        'case 30000: f1(4); break; } }',
        'void sw_mixed(int x) { switch (x) { case 0: f1(0); break; case 1: f1(1); break; case 2: f1(2); break; case 3: f1(3); break; '
        'case 4: f1(4); break; case 100: f1(100); break; case 200: f1(200); break; } }',
        'void sw_two(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; } }',
        'void sw_one(int x) { switch (x) { case 7: f0(); break; } }',
        'void sw_neg(int x) { switch (x) { case -2: f1(1); break; case -1: f1(2); break; case 0: f1(3); break; case 1: f1(4); break; '
        'case 2: f1(5); break; case 3: f1(6); break; } }',
        'void sw_loop(int n) { int i; for (i = 0; i < n; i++) { switch (i) { %s } } }' % body6,
        'int sw_ev(int obj, long ev, long par) { switch (ev) { case 0x1001: f1(obj); break; case 0x1002: f0(); break; '
        'case 0x2000: case 0x2001: case 0x2002: case 0x2003: case 0x2004: case 0x2005: f1((int)(ev - 0x2000)); break; '
        'default: return 0; } return 1; }',
        'int sw_evtab(int obj, long ev, long par) { switch (ev) { case 0x2000: f1(obj); break; case 0x2001: f0(); break; '
        'case 0x2002: f1(2); break; case 0x2003: f1(3); break; case 0x2004: gi = obj; break; case 0x2005: gl = par; break; '
        'default: return g1(obj); } return 1; }']
    return {'switch.c': out}

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
    files.update(ra_files())
    files.update(opt_loop_files())
    files.update(rule_files())
    files.update(switch_files())
    for n, lines in sorted(files.items()):
        open(os.path.join(d, n), 'w').write('\n'.join(lines) + '\n')
    open(os.path.join(out, 'micro-sources.txt'), 'w').write(''.join('micro/%s\n' % n for n in sorted(files)))
    print('%d files, %d functions' % (len(files), sum(sum(1 for l in v if '{' in l) for v in files.values())))

main()
