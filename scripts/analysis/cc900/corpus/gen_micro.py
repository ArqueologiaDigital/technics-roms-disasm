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
  unsigned and long, the shapes of the firmware's event handlers (dispatch on a long event code);
- opt_params: leaf loops at -O whose parameters live in registers, varying declaration order, first use,
  use counts and where the loop starts, to find the order in which -O loads them;
- ra_homes: values live across a call (locals and parameters, one to four of them, with different use counts
  and declaration orders), to find which go to IZ, QIZ, XIZ or a stack slot;
- ra_chains: chains of two to five + - & | ^ operands (globals, parameters, IZ / QIZ homes, stack slots), in
  leaf functions and after a call, as a return value, a store and an argument: when is the chain built in WA
  and moved (ld HL,WA), and when directly in its target?
- fp: float and double: arithmetic, compares as values and branches (with zero and with operands), conversions to
  and from every integer type, calls with double arguments and results, temporaries, locals, arrays and members
  (the library is built -DFLOAT; its math routines are most of the sub CPU's firmware pairs);
- fp_temps: nested double expressions: where the temporaries go, and when the hidden result pointer is kept in XIZ
  rather than the result built in a temporary and copied (fp.c: d_three vs d_four);
- opt_temps: -O3 -XS -Xr leaf loops: two pointers and a count in every argument order, with copy, compare, fill,
  sum and count-only bodies, to find which register family the loop's temporaries take and which parameter moves;
- opt_counted: counted for loops over arrays and pointers (sum, copy, find, clear, two arrays, down-counting),
  parameters in every order, int / char / long elements, to find the -O counter, bound, base and offset registers;
- fp_stmts: FP temporaries over several statements, branches and loops (where _log's slots come from);
- ra_homes32: a 32-bit local (pointer, long) against a 16-bit parameter for XIZ / IZ across calls (_memccpy gives
  IZ to n and a slot to pos);
- ra_libshapes: the shapes between _calloc (a pointer from a call wins XIZ over two 16-bit parameters), _memccpy (a
  16-bit parameter wins IZ over the pointer) and _strlen (a lone pointer parameter read twice takes XIZ) at -O3 -XS;
- fp_order: which operand of a double + or * is built first, and when a table element's address is kept in XIZ
  across a conversion helper (_log: LN2 * nptr + 2 * s, LN2 = g_dbltbl[3].val);
- cond_bits: x & mask as a branch condition at each type, operand kind and mask shape, negated, in loops, under
  && / || and in ?: (the library's `if (d.c[7] & 0x80)`, `if (n & 1)`, `if (stream->flag & __UNGETC)`);
- assign_expr: assignment as a value (chains, compared, tested, returned, passed) at char, int, long and pointer
  (the library's `pp = cp = _allocb`, `(c1 = toupper(*s1)) == (c2 = toupper(*s2))`, `(*s = c) != '\\n'`).
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

def opt_param_files():
    """the order of -O's parameter loads (phase3a-status.md, open allocator question)"""
    out = ['/* Parameters kept in registers by -O: in which order are they loaded? */', 'extern int gi;']
    fs = [
        # all needed by the first loop, loaded at the start
        'void op_cpy_ab(char *a, char *b, int n) { while (n--) *a++ = *b++; }',
        'void op_cpy_ba(char *a, char *b, int n) { while (n--) *b++ = *a++; }',
        'void op_cpy_nab(int n, char *a, char *b) { while (n--) *a++ = *b++; }',
        'void op_cpy_anb(char *a, int n, char *b) { while (n--) *a++ = *b++; }',
        'int op_cmp_ab(char *a, char *b, int n) { while (n && *a == *b) { a++; b++; n--; } return n; }',
        'int op_cmp_ba(char *a, char *b, int n) { while (n && *b == *a) { b++; a++; n--; } return n; }',
        'int op_sum2(int *p, int *q, int n) { int s = 0; while (n--) s += *p++ + *q++; return s; }',
        'int op_sum2q(int *p, int *q, int n) { int s = 0; while (n--) s += *q++ + *p++; return s; }',
        'void op_fill(char *a, int n, char c) { while (n--) *a++ = c; }',
        'void op_fill2(char c, int n, char *a) { while (n--) *a++ = c; }',
        'int op_two(char *a, char *b) { while (*a == *b && *a) { a++; b++; } return *a - *b; }',
        'int op_two_ba(char *a, char *b) { while (*b == *a && *b) { b++; a++; } return *b - *a; }',
        # first loop needs one, a second loop the others
        'void op_cat(char *a, char *b, int n) { while (*a) a++; while (n--) *a++ = *b++; }',
        'void op_cat2(char *a, int n, char *b) { while (*a) a++; while (n--) *a++ = *b++; }',
        'void op_cat3(char *a, char *b, int n) { while (*a) a++; while (n-- && *b) *a++ = *b++; }',
        'void op_cat4(char *a, char *b, int n) { while (*a) a++; while (*b && n--) *a++ = *b++; }',
        'void op_cat_b(char *a, char *b, int n) { while (*b) b++; while (n--) *b++ = *a++; }',
        'void op_two_loops(char *a, char *b) { while (*a) a++; while (*b) b++; *a = *b; }',
        # three pointers
        'void op_three(char *d, char *s, char *t, int n) { while (n--) *d++ = *s++ + *t++; }',
        'void op_three2(char *s, char *t, char *d, int n) { while (n--) *d++ = *s++ + *t++; }',
        # uses counted differently
        'int op_heavy_a(char *a, char *b, int n) { int s = 0; while (n--) { s += *a; s += a[1]; a++; b++; } return s; }',
        'int op_heavy_b(char *a, char *b, int n) { int s = 0; while (n--) { s += *b; s += b[1]; a++; b++; } return s; }',
        'char *op_ret_a(char *a, char *b, int n) { char *r = a; while (n--) *a++ = *b++; return r; }',
        'char *op_ret_b(char *a, char *b, int n) { char *r = b; while (n--) *a++ = *b++; return r; }']
    return {'opt_params.c': out + fs}

def ra_home_files():
    """the IZ / QIZ / XIZ / slot choice for values that live across a call (phase3a-status.md, open allocator)"""
    out = ['/* Values live across a call: which register or slot does each get? */',
           'extern void g0(void); extern int g1(int); extern int gi; extern long gl;']
    fs = [
        # one local, one parameter
        'int rh_l1(int a) { int x = a + 1; g0(); return x; }',
        'int rh_p1(int a) { g0(); return a; }',
        'int rh_lp(int a) { int x = a + 1; g0(); return x + a; }',
        'int rh_lp_x2(int a) { int x = a + 1; g0(); return x + x + a; }',
        'int rh_lp_a2(int a) { int x = a + 1; g0(); return x + a + a; }',
        'int rh_lp_call(int a) { int x = g1(a); g0(); return x + a; }',
        # two locals
        'int rh_ll(int a, int b) { int x = a + b, y = a - b; g0(); return x * y; }',
        'int rh_ll_y2(int a, int b) { int x = a + b, y = a - b; g0(); return x * y + y; }',
        'int rh_ll_x2(int a, int b) { int x = a + b, y = a - b; g0(); return x * y + x; }',
        'int rh_ll_rev(int a, int b) { int y = a - b, x = a + b; g0(); return x * y; }',
        # three and four locals
        'int rh_lll(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z; }',
        'int rh_lll_z2(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z + z; }',
        'int rh_llll(int a, int b, int c) { int w = a + c, x = a + b, y = b + c, z = a - c; g0(); return w + x + y + z; }',
        # two parameters
        'int rh_pp(int a, int b) { g0(); return a + b; }',
        'int rh_pp_b2(int a, int b) { g0(); return a + b + b; }',
        'int rh_pp_a2(int a, int b) { g0(); return a + a + b; }',
        'int rh_ppp(int a, int b, int c) { g0(); return a + b + c; }',
        # longs and pointers
        'long rh_long(long a) { long x = a + 1; g0(); return x + a; }',
        'char *rh_ptr(char *p) { char *q = p + 1; g0(); return q; }',
        'int rh_ptr_int(char *p, int n) { g0(); return p[n]; }',
        'int rh_int_ptr(int n, char *p) { g0(); return p[n]; }',
        # in loops
        'int rh_loop(int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(i); return s; }',
        'int rh_loop2(int n) { int s = 0; int i; for (i = 0; i < n; i++) s += g1(i); return s; }',
        'int rh_loop_p(int *p, int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(p[i]); return s; }',
        'void rh_loop_call2(int n) { int i; for (i = 0; i < n; i++) { g0(); g1(i); } }']
    return {'ra_homes.c': out + fs}

def ra_chain_files():
    """WA then ld HL,WA, or directly in HL? (rh_ppp vs rh_lll in ra_homes.c)"""
    out = ['/* Operand chains: built in WA and moved, or built in the target? */',
           'extern void g0(void); extern int g1(int); extern int gi, gj, gk, gm, gn;']
    fs = [
        # leaf, globals only
        'int ch_g2(void) { return gi + gj; }',
        'int ch_g3(void) { return gi + gj + gk; }',
        'int ch_g4(void) { return gi + gj + gk + gm; }',
        'int ch_g5(void) { return gi + gj + gk + gm + gn; }',
        'int ch_g3_sub(void) { return gi - gj - gk; }',
        'int ch_g3_mix(void) { return gi + gj - gk; }',
        'int ch_g3_and(void) { return gi & gj & gk; }',
        'int ch_g3_xor(void) { return gi ^ gj | gk; }',
        'int ch_g3_rep(void) { return gi + gi + gj; }',
        'int ch_g3_rep2(void) { return gi + gj + gj; }',
        'int ch_g3_k(void) { return gi + gj + 100; }',
        'int ch_g3_k1(void) { return gi + 100 + gj; }',
        # leaf, parameters (registers under -Xr, stack under cdecl)
        'int ch_p3(int a, int b, int c) { return a + b + c; }',
        'int ch_p4(int a, int b, int c) { return a + b + c + a; }',
        'int ch_pg2(int a) { return a + gi + gj; }',
        'int ch_gp2(int a) { return gi + a + gj; }',
        'int ch_ggp(int a) { return gi + gj + a; }',
        'int ch_p2g(int a, int b) { return a + b + gi; }',
        # after a call: a parameter homed in IZ, the rest globals
        'int ch_c_pg2(int a) { g0(); return a + gi + gj; }',
        'int ch_c_gp2(int a) { g0(); return gi + a + gj; }',
        'int ch_c_ggp(int a) { g0(); return gi + gj + a; }',
        'int ch_c_g3(void) { g0(); return gi + gj + gk; }',
        'int ch_c_g4p(int a) { g0(); return gi + gj + gk + a; }',
        'int ch_c_pg3(int a) { g0(); return a + gi + gj + gk; }',
        # after a call: three locals (IZ, QIZ, a slot) in each order
        'int ch_c_xyz(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z; }',
        'int ch_c_zyx(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return z + y + x; }',
        'int ch_c_yxz(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return y + x + z; }',
        'int ch_c_xzy(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + z + y; }',
        'int ch_c_xyg(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + gi + z; }',
        # not a return value
        'void ch_st3(void) { gi = gj + gk + gm; }',
        'void ch_st4(void) { gi = gj + gk + gm + gn; }',
        'void ch_arg3(void) { g1(gj + gk + gm); }',
        'int ch_loc3(void) { int x = gj + gk + gm; g0(); return x; }']
    return {'ra_chains.c': out + fs}

def ra_home32_files():
    """_memccpy: n (16-bit parameter, two reads) gets IZ, pos (pointer local, four references) a slot"""
    out = ['/* A 32-bit local against a 16-bit parameter, both live across a call */',
           'extern void g0(void); extern void g2(int); extern int g1(int); extern char *fp(int); extern long fl(int);',
           'extern void *vp(const void *, int, unsigned int); extern void *cp2(void *, const void *, unsigned int);']
    fs = [
        'char *h_p(int n) { char *p = fp(n); g2(n); return p; }',
        'char *h_p_only(int n) { char *p = fp(n); g0(); return p; }',
        'char *h_p_n1(int n) { char *p = fp(1); g2(n); return p; }',
        'char *h_p_n3(int n) { char *p = fp(n); g2(n); return p + n; }',
        'char *h_p_n4(int n) { char *p = fp(n); g2(n); g2(n); return p; }',
        'char *h_p_if(int n) { char *p = fp(n); if (p == 0) g2(n); return p; }',
        'char *h_p_asg(int n) { char *p; p = fp(n); g2(n); return p; }',
        'char *h_p_p3(int n) { char *p = fp(n); g2(n); if (p == 0) return p + 1; return p; }',
        'char *h_p_m(int n, int m) { char *p = fp(n); g2(m); return p; }',
        'int h_p_diff(char *s, int n) { char *p = fp(n); g2(n); return p - s; }',
        'long h_l(int n) { long x = fl(n); g2(n); return x; }',
        'long h_l_n3(int n) { long x = fl(n); g2(n); return x + n; }',
        'int h_i(int n) { int x = g1(n); g2(n); return x; }',
        'char *h_p_un(unsigned int n) { char *p = fp(1); g2(n); return p; }',
        'void *h_mc(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { unsigned int nn; '
        'nn = pos - (unsigned char *)s2 + 1; cp2(s1, s2, nn); } return (void *)pos; }',
        'void *h_mc_int(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { cp2(s1, s2, 4); } '
        'return (void *)pos; }',
        'void *h_mc_nouse(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, n); cp2(s1, s2, n); return (void *)pos; }']
    return {'ra_homes32.c': out + fs}

def ra_libshape_files():
    """which of a call-result pointer, a pointer parameter and 16-bit parameters gets XIZ / IZ (cdecl -O3 -XS first)"""
    out = ['/* Library-shaped homes: _calloc, _memccpy, _strlen and the steps between them */',
           'extern void *al(unsigned int); extern void *ms(void *, int, unsigned int); extern void g0(void);',
           'extern void g2(unsigned int); extern char *ch(const char *, int, unsigned int);',
           'extern void *vp(const void *, int, unsigned int); extern void *cp2(void *, const void *, unsigned int);']
    fs = [
        # _calloc and its reductions
        'void *ls_cl(unsigned int n, unsigned int s) { void *p; if (!n || !s) return 0; p = al(n * s); '
        'if (p) ms(p, 0, n * s); return p; }',
        'void *ls_cl_noguard(unsigned int n, unsigned int s) { void *p; p = al(n * s); if (p) ms(p, 0, n * s); return p; }',
        'void *ls_cl1(unsigned int n) { void *p; if (!n) return 0; p = al(n); if (p) ms(p, 0, n); return p; }',
        'void *ls_cl1_noguard(unsigned int n) { void *p; p = al(n); if (p) ms(p, 0, n); return p; }',
        'void *ls_cl1_always(unsigned int n) { void *p; p = al(n); ms(p, 0, n); return p; }',
        'void *ls_cl1_notest(unsigned int n) { void *p; p = al(n); g2(n); return p; }',
        'void *ls_cl1_ptest(unsigned int n) { void *p; p = al(n); if (p) g2(n); return p; }',
        'void *ls_cl1_pneg(unsigned int n) { void *p; p = al(n); if (p == 0) g2(n); return p; }',
        'void *ls_cl1_parg(unsigned int n) { void *p; p = al(n); if (p) ms(p, 0, 4); return p; }',
        'void *ls_cl_mul1(unsigned int n, unsigned int s) { void *p; p = al(n * s); if (p) ms(p, 0, n); return p; }',
        # _memccpy and its reductions
        'void *ls_mc(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { unsigned int nn; '
        'nn = pos - (unsigned char *)s2 + 1; cp2(s1, s2, nn); } return (void *)pos; }',
        'void *ls_mc_nos1(const void *s2, int c, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(0, s2, n); } else { '
        'cp2(0, s2, pos - (unsigned char *)s2 + 1); } return (void *)pos; }',
        'void *ls_mc_non(void *s1, const void *s2, int c) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, c, 8); if (pos == 0) { cp2(s1, s2, 8); } else { '
        'cp2(s1, s2, pos - (unsigned char *)s2 + 1); } return (void *)pos; }',
        'void *ls_mc_test(const void *s2, unsigned int n) { unsigned char *pos; '
        'pos = (unsigned char *)vp(s2, 0, n); if (pos == 0) cp2(0, s2, n); return (void *)pos; }',
        'void *ls_mc_n1(unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(0, 0, n); '
        'if (pos == 0) g2(n); return (void *)pos; }',
        'void *ls_mc_n1p(unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(0, 0, n); '
        'if (pos) g2(n); return (void *)pos; }',
        # _strlen and its neighbours
        'unsigned int ls_sl(const char *s) { char *ss; ss = ch(s, 0, 0xffff); if (ss == 0) return 0xffff; '
        'return (unsigned int)(ss - (char *)s); }',
        'unsigned int ls_sl_n(const char *s, unsigned int n) { char *ss; ss = ch(s, 0, n); if (ss == 0) return n; '
        'return (unsigned int)(ss - (char *)s); }',
        'unsigned int ls_sl_g(const char *s) { g0(); return (unsigned int)(*s); }',
        'unsigned int ls_sl_2(const char *s) { g2(*s); return (unsigned int)(*s); }',
        'char *ls_sl_ret(const char *s) { char *ss; ss = ch(s, 0, 4); if (ss == 0) return (char *)s; return ss; }']
    return {'ra_libshapes.c': out + fs}

def fp_order_files():
    """_log's return expression and its neighbours: left or right operand first, element address kept in XIZ"""
    out = ['/* Operand order of double expressions with conversions and table elements */',
           'typedef union { unsigned char c[8]; double val; } DB;',
           'extern DB gtab[]; extern double gd, gd2, gda[]; extern double fd(double); extern int gi;']
    fs = [
        'double fo_log(int n, double s) { return gtab[3].val * n + 2 * s; }',
        'double fo_log_rev(int n, double s) { return 2 * s + gtab[3].val * n; }',
        'double fo_conv2(int n, double s) { return n * 2.0 + s * 3.0; }',
        'double fo_conv2_rev(int n, double s) { return s * 3.0 + n * 2.0; }',
        'double fo_mem_n(int n) { return gtab[3].val * n; }',
        'double fo_n_mem(int n) { return n * gtab[3].val; }',
        'double fo_glob_n(int n, double s) { return gd * n + 2 * s; }',
        'double fo_arr_n(int n, double s) { return gda[3] * n + 2 * s; }',
        'double fo_mem_call(double x) { return gtab[3].val * fd(x); }',
        'double fo_mem_add(int n) { return gtab[3].val + n; }',
        'double fo_mem_sub(int n) { return gtab[3].val - n; }',
        'double fo_mem_div(int n) { return gtab[3].val / n; }',
        'double fo_n_div(int n) { return n / gtab[3].val; }',
        'double fo_gi(double s) { return gtab[3].val * gi + s; }',
        'double fo_two_conv(int n, int m) { return (double)n * m; }',
        'double fo_mem_mem(int n) { return gtab[3].val * gtab[2].val + n; }',
        'void fo_store(int n, double s) { gd = gtab[3].val * n + 2 * s; }',
        'double fo_loc(int n, double s) { double t; t = gtab[3].val * n; return t + 2 * s; }']
    return {'fp_order.c': out + fs}

def fp_files():
    """floating point: helper calls through operand addresses, temporaries, conversions (abi.md: helpers)"""
    out = ['/* Floating point: helpers, temporaries, conversions */',
           'extern double gd, gd2, gd3; extern float gf, gf2; extern int gi; extern long gl; extern unsigned int gu;',
           'extern unsigned long gul; extern char gc; extern unsigned char guc; extern double gda[4];',
           'struct sd { int k; double v; }; extern struct sd gs; extern double fd(double); extern double fd2(double, double);',
           'extern void vd(double); extern int fi(void); extern double *gpd;']
    fs = []
    for op, n in (('+', 'add'), ('-', 'sub'), ('*', 'mul'), ('/', 'div')):
        fs += ['double d_%s_gg(void) { return gd %s gd2; }' % (n, op),
               'double d_%s_pp(double a, double b) { return a %s b; }' % (n, op),
               'double d_%s_pk(double a) { return a %s 2.5; }' % (n, op),
               'void d_%s_st(void) { gd = gd2 %s gd3; }' % (n, op),
               'float f_%s_gg(void) { return gf %s gf2; }' % (n, op),
               'void d_%s_asg(void) { gd %s= gd2; }' % (n, op)]
    fs += ['double d_three(void) { return gd * gd2 + gd3; }',
           'double d_three2(void) { return gd + gd2 * gd3; }',
           'double d_four(double a, double b) { return (a + b) * (a - b); }',
           'double d_neg(double a) { return -a; }',
           'double d_ret_p(double a) { return a; }',
           'double d_ret_g(void) { return gd; }',
           'double d_ret_k(void) { return 1.0; }',
           'double d_ret_0(void) { return 0.0; }',
           'void d_st_k(void) { gd = 3.0; }',
           'void d_st_0(void) { gd = 0; }',
           'void d_copy(void) { gd = gd2; }',
           'double d_loc(double a) { double t = a * a; return t + t; }',
           'double d_loc2(double a, double b) { double t = a * b; double u = a + b; return t / u; }']
    for op, n in (('==', 'eq'), ('!=', 'ne'), ('<', 'lt'), ('<=', 'le'), ('>', 'gt'), ('>=', 'ge')):
        fs += ['int d_c%s_gg(void) { return gd %s gd2; }' % (n, op),
               'int d_c%s_z(double a) { return a %s 0.0; }' % (n, op),
               'int d_b%s_gg(void) { if (gd %s gd2) return 1; return 2; }' % (n, op),
               'int d_b%s_z(double a) { if (a %s 0.0) return 1; return 2; }' % (n, op)]
    fs += ['int d_bk(double a) { if (a < 1.5) return 1; return 2; }',
           'int d_not(double a) { return !a; }',
           'int d_if(double a) { if (a) return 1; return 2; }',
           'int f_clt(void) { return gf < gf2; }']
    for t, n in (('int', 'i'), ('long', 'l'), ('unsigned int', 'u'), ('unsigned long', 'ul'), ('char', 'c'),
                 ('unsigned char', 'uc')):
        g = {'i': 'gi', 'l': 'gl', 'u': 'gu', 'ul': 'gul', 'c': 'gc', 'uc': 'guc'}[n]
        fs += ['double d_from_%s(void) { return %s; }' % (n, g),
               '%s d_to_%s(void) { return gd; }' % (t, n),
               'void d_st_%s(void) { gd = %s; }' % (n, g),
               'void d_to_%s_st(void) { %s = gd; }' % (n, g)]
    fs += ['double d_from_f(void) { return gf; }',
           'float f_from_d(void) { return gd; }',
           'double d_from_ip(int i) { return i; }',
           'int d_to_ip(double a) { return a; }',
           'double d_mix(int i) { return gd * i; }',
           'double d_call1(double a) { return fd(a); }',
           'double d_call2(void) { return fd2(gd, gd2); }',
           'double d_call_e(double a) { return fd(a * 2.0) + a; }',
           'void d_call_v(void) { vd(gd + gd2); }',
           'double d_call_i(void) { return fi() * gd; }',
           'double d_arr(int i) { return gda[i]; }',
           'void d_arr_st(int i, double v) { gda[i] = v; }',
           'double d_mem(void) { return gs.v; }',
           'double d_ptr(double *p) { return *p; }',
           'void d_ptr_st(double *p, double v) { *p = v; }',
           'double d_gptr(void) { return *gpd * 2.0; }',
           'double d_cond(double a, double b) { return a > b ? a : b; }',
           'double d_loop(int n) { double s = 0.0; int i; for (i = 0; i < n; i++) s += gda[i]; return s; }',
           'double d_inc(double a) { a += 1.0; return a; }']
    return {'fp.c': out + fs}

def fp_temp_files():
    """d_three (gd * gd2 + gd3) keeps the hidden pointer in XIZ; d_four ((a + b) * (a - b)) builds its result in a
    temporary and copies it"""
    out = ['/* Nested double expressions: temporaries and the result pointer */',
           'extern double gd, gd2, gd3, gd4; extern double fd(double); extern void g0(void); extern int gi;']
    fs = [
        'double t_mla(void) { return gd * gd2 + gd3; }',
        'double t_amla(void) { return gd3 + gd * gd2; }',
        'double t_mm(void) { return gd * gd2 + gd3 * gd4; }',
        'double t_am(void) { return (gd + gd2) * gd3; }',
        'double t_ma(void) { return gd3 * (gd + gd2); }',
        'double t_chain3(void) { return gd * gd2 * gd3; }',
        'double t_chain4(void) { return gd * gd2 * gd3 * gd4; }',
        'double t_neg(void) { return -(gd * gd2); }',
        'double t_negl(void) { return -gd * gd2; }',
        'double t_mla_p(double a, double b, double c) { return a * b + c; }',
        'double t_mm_p(double a, double b) { return (a + b) * (a - b); }',
        'double t_mm_p2(double a, double b, double c, double d) { return a * b + c * d; }',
        'double t_ci(int i) { return gd * i; }',
        'double t_ic(int i) { return i * gd; }',
        'double t_ci2(int i) { return gd * i + gd2; }',
        'double t_call_a(double a) { return fd(a) + gd; }',
        'double t_a_call(double a) { return gd + fd(a); }',
        'double t_call_only(double a) { return fd(a); }',
        'double t_g0_mla(void) { g0(); return gd * gd2 + gd3; }',
        'double t_mla_g0(void) { double t = gd * gd2 + gd3; g0(); return t; }',
        'void t_st_mla(void) { gd = gd2 * gd3 + gd4; }',
        'void t_st_mm(void) { gd = gd2 * gd3 + gd4 * gd2; }',
        'void t_st_am(void) { gd = (gd2 + gd3) * gd4; }',
        'double t_loc_mla(void) { double t = gd * gd2 + gd3; return t; }',
        'double t_loc_mla2(void) { double t = gd * gd2 + gd3; return t * t; }',
        'double t_two_loc(void) { double t = gd * gd2; double u = t + gd3; return u * gd4; }',
        'double t_cond(double a, double b) { return a > b ? a : b; }',
        'double t_cond_e(double a, double b) { return a > b ? a * b : a + b; }',
        'int t_cmp_mla(void) { return gd * gd2 + gd3 < gd4; }',
        'int t_cmp_e(void) { if (gd * gd2 < gd3) return 1; return 2; }',
        'long t_to_l(void) { return (long)(gd * gd2); }',
        'int t_to_i_e(void) { return (int)(gd * gd2 + gd3); }',
        'double t_i_e(void) { return (double)(gi * 2) + gd; }']
    return {'fp_temps.c': out + fs}

def opt_temp_files():
    """which family is the loop's temporary (the n-- copy, the byte), and who moves out of it (opt_params.c)"""
    import itertools
    out = ['/* -O3 -XS -Xr leaf loops: the register family of the temporaries */', 'extern int gi; extern char gc;']
    bodies = [('cpy', 'void', 'while (n--) *a++ = *b++;'),
              ('cmp', 'int', 'while (n && *a == *b) { a++; b++; n--; } return n;'),
              ('add', 'void', 'while (n--) *a++ += *b++;'),
              ('sum', 'int', 'int s = 0; while (n--) s += *a++ - *b++; return s;'),
              ('cnt', 'void', 'while (n--) { a++; b++; } gc = *a + *b;')]
    fs = []
    for bn, rt, body in bodies:
        for perm in itertools.permutations(['char *a', 'char *b', 'int n']):
            tag = ''.join(x[-1] for x in perm)
            fs.append('%s ot_%s_%s(%s) { %s }' % (rt, bn, tag, ', '.join(perm), body))
    fs += ['void ot_fill_acn(char *a, char c, int n) { while (n--) *a++ = c; }',
           'void ot_fill_anc(char *a, int n, char c) { while (n--) *a++ = c; }',
           'void ot_fill_can(char c, char *a, int n) { while (n--) *a++ = c; }',
           'void ot_fill_nac(int n, char *a, char c) { while (n--) *a++ = c; }',
           'void ot_one_an(char *a, int n) { while (n--) *a++ = 0; }',
           'void ot_one_na(int n, char *a) { while (n--) *a++ = 0; }',
           'int ot_len(char *a) { int n = 0; while (*a++) n++; return n; }',
           'int ot_len2(char *a, char *b) { int n = 0; while (*a++ == *b++) n++; return n; }']
    return {'opt_temps.c': out + fs}

def opt_counted_files():
    """counted loops: which registers the counter, the bound, the base and the offset take (ctrl.c c_sum, c_find,
    c_copy; opt_loops.c)"""
    import itertools
    out = ['/* Counted loops: counter, bound, base and offset registers */',
           'extern int gia[10]; extern char gca[10]; extern long gla[10]; extern int gi;']
    fs = []
    for perm in itertools.permutations(['int *p', 'int n']):
        tag = ''.join(x[-1] for x in perm)
        fs.append('int oc_sum_%s(%s) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }' % (tag, ', '.join(perm)))
    for perm in itertools.permutations(['char *a', 'char *b', 'int n']):
        tag = ''.join(x[-1] for x in perm)
        fs.append('void oc_cpy_%s(%s) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }' % (tag, ', '.join(perm)))
    for perm in itertools.permutations(['int *p', 'int n', 'int k']):
        tag = ''.join(x[-1] for x in perm)
        fs.append('int oc_find_%s(%s) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }'
                  % (tag, ', '.join(perm)))
    fs += ['void oc_clr_i(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }',
           'void oc_clr_c(char *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }',
           'void oc_clr_l(long *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }',
           'long oc_sum_l(long *p, int n) { long s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }',
           'int oc_sum_c(char *p, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }',
           'int oc_sum2(int *p, int *q, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i] * q[i]; return s; }',
           'void oc_add2(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) p[i] += q[i]; }',
           'int oc_sum_i_first(int *p, int n) { int i; int s = 0; for (i = 0; i < n; i++) s += p[i]; return s; }',
           'int oc_sum_g(int n) { int s = 0; int i; for (i = 0; i < n; i++) s += gia[i]; return s; }',
           'int oc_sum_gk(void) { int s = 0; int i; for (i = 0; i < 10; i++) s += gia[i]; return s; }',
           'void oc_cpy_g(char *a) { int i; for (i = 0; i < 10; i++) a[i] = gca[i]; }',
           'int oc_down(int *p, int n) { int s = 0; int i; for (i = n - 1; i >= 0; i--) s += p[i]; return s; }',
           'int oc_down2(int *p, int n) { int s = 0; for (; n > 0; n--) s += p[n - 1]; return s; }',
           'int oc_cnt_c(char *p, int n, char c) { int k = 0; int i; for (i = 0; i < n; i++) if (p[i] == c) k++; return k; }',
           'int oc_max(int *p, int n) { int m = p[0]; int i; for (i = 1; i < n; i++) if (p[i] > m) m = p[i]; return m; }',
           'void oc_fill_i(int *p, int n, int v) { int i; for (i = 0; i < n; i++) p[i] = v; }',
           'void oc_idx(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] = i; }',
           'int oc_nested(int *p, int n, int m) { int s = 0; int i, j; for (i = 0; i < n; i++) for (j = 0; j < m; j++) s += p[j]; return s; }']
    return {'opt_counted.c': out + fs}

def fp_stmt_files():
    """how temporary slots are shared between statements (_log: 0x44, 0x3c, 0x34, 0x2c, 0x24)"""
    out = ['/* FP temporaries over several statements */',
           'extern double gd, gd2, gd3, gd4; extern double fd(double); extern int gi; extern long gl;']
    fs = [
        'void s_two(void) { gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; }',
        'void s_two_b(void) { gd = gd2 * gd3 + gd4; gd2 = (gd3 + gd4) * (gd + gd2); }',
        'void s_three(void) { gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; gd3 = gd * gd2 + gd4; }',
        'void s_conv2(void) { gd = gd2 * gi; gd2 = gd3 * gi + gd; }',
        'void s_conv_first(void) { gd = gi * gd2 + gd3; gd2 = gd3 * gd4 + gd; }',
        'void s_call2(void) { gd = fd(gd2) + gd3; gd2 = fd(gd3 * gd4) + gd; }',
        'double s_loc(double a) { double t; t = a * a + gd; t = t * a + gd2; return t; }',
        'double s_loc2(double a) { double t, u; t = a * a + gd; u = t * a + gd2; return t + u; }',
        'void s_if(int c) { if (c) gd = gd2 * gd3 + gd4; else gd = gd3 * gd4 + gd2; }',
        'void s_if2(int c) { if (c) gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; }',
        'void s_loop(int n) { int i; for (i = 0; i < n; i++) gd = gd * gd2 + gd3; }',
        'void s_loop2(int n) { int i; gd4 = gd * gd2 + gd3; for (i = 0; i < n; i++) gd = gd * gd2 + i; }',
        'void s_loop3(int n) { int i; for (i = 0; i < n; i++) { gd = gd * gd2 + gd3; gd2 = gd2 * gd3 + i; } }',
        'double s_ret2(double a) { gd = a * a + gd2; return a * gd + gd3; }',
        'long s_mix(double a) { gd = a * a + gd2; return (long)(a * gd); }',
        'void s_conv_l(void) { gd = gd2 * gl; gl = gd * gd3; }']
    return {'fp_stmts.c': out + fs}

def cond_bits_files():
    """x & mask as a branch condition (the library's `if (d.c[7] & 0x80)`, `if (stream->flag & __UNGETC)`,
    `if (n & 1)`): each integer type, operand kind and mask shape, the negated forms, and the condition in a loop,
    under && / ||, in ?: and beside an else"""
    out = ['/* x & mask as a condition */',
           'struct st { int flag; char c; long l; unsigned char b[4]; };',
           'typedef union { double d; unsigned char c[8]; unsigned int n[4]; } DU;',
           'extern char gc; extern unsigned char guc; extern int gi; extern unsigned int gui; extern long gl;',
           'extern unsigned long gul; extern int gr; extern unsigned char gtab[]; extern struct st *gps;',
           'extern int f(int);']
    fs = []
    masks = {'c': ['0x1', '0x80', '0x10', '0xf'], 'uc': ['0x1', '0x80', '0x10', '0xf0'],
             'i': ['0x1', '0x8000', '0x100', '0x10', '0xff', '0x7ff0'], 'ui': ['0x1', '0x8000', '0x100', '0xf00'],
             'l': ['0x1', '0x80000000', '0x10000', '0xff00'], 'ul': ['0x1', '0x80000000', '0x100', '0xffff0000']}
    for tk, t in INT_TYPES:
        g = 'g' + tk
        for m in masks[tk]:
            mm = m[2:]
            fs.append('int cb_%s_p_%s(%s x) { if (x & %s) return 1; return 0; }' % (tk, mm, t, m))
            fs.append('int cb_%s_g_%s(void) { if (%s & %s) return 1; return 0; }' % (tk, mm, g, m))
        m = masks[tk][1]; mm = m[2:]
        fs += ['int cb_%s_not_%s(%s x) { if (!(x & %s)) return 1; return 0; }' % (tk, mm, t, m),
               'int cb_%s_eq0_%s(%s x) { if ((x & %s) == 0) return 1; return 0; }' % (tk, mm, t, m),
               'int cb_%s_ne0_%s(%s x) { if ((x & %s) != 0) return 1; return 0; }' % (tk, mm, t, m),
               'int cb_%s_ptr_%s(%s *p) { if (*p & %s) return 1; return 0; }' % (tk, mm, t, m),
               'int cb_%s_idx_%s(%s *p) { if (p[3] & %s) return 1; return 0; }' % (tk, mm, t, m),
               'void cb_%s_else_%s(%s x) { if (x & %s) gr = 1; else gr = 2; }' % (tk, mm, t, m),
               'int cb_%s_var(%s x, %s y) { if (x & y) return 1; return 0; }' % (tk, t, t)]
    fs += [
        'int cb_mem_flag(struct st *p) { if (p->flag & 0x4) return 1; return 0; }',
        'int cb_mem_flag_g(void) { if (gps->flag & 0x4) return 1; return 0; }',
        'int cb_mem_c(struct st *p) { if (p->c & 0x80) return 1; return 0; }',
        'int cb_mem_l(struct st *p) { if (p->l & 0x100) return 1; return 0; }',
        'int cb_mem_b(struct st *p) { if (p->b[3] & 0x80) return 1; return 0; }',
        'int cb_union_c7(double x) { DU d; d.d = x; if (d.c[7] & 0x80) return 1; return 0; }',
        'int cb_union_n0(double x) { DU d; d.d = x; if (!(d.n[0] & 0xf000)) return 1; return 0; }',
        'int cb_loc(int a, int b) { int n; n = a + b; if (n & 1) return n; return 0; }',
        'int cb_cast(long x) { if ((int)x & 1) return 1; return 0; }',
        'int cb_call(int x) { if (f(x) & 0x8) return 1; return 0; }',
        'int cb_shift(int x, int s) { if (x & (0x8000 >> s)) return 1; return 0; }',
        'int cb_or_mask(int x) { if (x & (0x2 | 0x4)) return 1; return 0; }',
        'int cb_and_and(int x, int y) { if ((x & 1) && y) return 1; return 0; }',
        'int cb_and_and2(int x, int y) { if (y && (x & 0x80)) return 1; return 0; }',
        'int cb_or_or(int x, int y) { if (y || (x & 0x6)) return 1; return 0; }',
        'int cb_tern(int c) { return (gtab[(unsigned char)c] & 0x2) ? c - 32 : c; }',
        'int cb_tern_char(char c) { return (gtab[(unsigned char)c] & 0x2) ? c + (\'A\' - \'a\') : c; }',
        'int cb_while(unsigned int x) { int n = 0; while (x & 1) { x >>= 1; n++; } return n; }',
        'int cb_while_g(void) { int n = 0; while (gi & 0x80) { gi <<= 1; n++; } return n; }',
        'int cb_for(int x) { int i, n = 0; for (i = 0; i < 8; i++) if (x & (1 << i)) n++; return n; }',
        'int cb_lt_mask(unsigned int *p) { if (0x7ff0 <= (p[3] & 0x7ff0)) return 1; return 0; }',
        'int cb_ret_val(int x) { return x & 0x80; }',
        'int cb_ret_bool(int x) { return (x & 0x80) != 0; }']
    return {'cond_bits.c': out + fs}

def assign_expr_files():
    """assignment used as a value (the library's `pp = cp = _allocb` (_free), `(c1 = toupper(*s1)) ==
    (c2 = toupper(*s2))` (_stricmp), `if ((*s = c) != '\\n')` (_fgets)): chains, assignments compared, tested,
    returned, passed and added, at char, int, long and pointer, to globals, locals, parameters and through
    pointers"""
    out = ['/* Assignment as a value */',
           'struct fl { struct fl *next; int size; };',
           'extern char gc, gc2; extern int gi, gi2, gi3; extern long gl, gl2; extern char *gp, *gp2;',
           'extern struct fl *gfl; extern int f(int); extern int g(void); extern char *h(void); extern int gr;']
    fs = []
    for tk, t, g, g2 in (('c', 'char', 'gc', 'gc2'), ('i', 'int', 'gi', 'gi2'), ('l', 'long', 'gl', 'gl2'),
                         ('p', 'char *', 'gp', 'gp2')):
        fs += ['void ae_%s_chain_gg(%s x) { %s = %s = x; }' % (tk, t, g, g2),
               'void ae_%s_chain_lg(%s x) { %s y; %s = y = x; gr = (int)(y != 0); }' % (tk, t, t, g),
               '%s ae_%s_ret_g(%s x) { return (%s = x); }' % (t, tk, t, g),
               'int ae_%s_eq_g(%s x) { if ((%s = x) == 0) return 2; return 3; }' % (tk, t, g),
               'int ae_%s_ne_l(%s x) { %s y; if ((y = x) != 0) return (int)(y == x); return 3; }' % (tk, t, t),
               'int ae_%s_two(%s x, %s z) { if ((%s = x) == (%s = z)) return 2; return 3; }' % (tk, t, t, g, g2),
               'void ae_%s_ptr(%s *p, %s x) { if ((*p = x) != 0) gr = 2; }' % (tk, t, t)]
    fs += ['void ae_c_ptr_nl(char *s, unsigned char c) { if ((*s = c) != 10) s++; gp = s; }',
           'int ae_c_loop(char *s) { char c; int n = 0; while ((c = *s++) != 0) n += c; return n; }',
           'int ae_i_call(void) { int v; if ((v = g()) < 0) return 0; return v; }',
           'int ae_i_call_g(void) { if ((gi = g()) < 0) return 0; return gi; }',
           'char *ae_p_call(void) { char *q; if ((q = h()) == 0) return gp; return q; }',
           'void ae_i_arg(int x) { f(gi = x); }',
           'int ae_i_add(int x) { int y; y = (gi = x) + 1; return y; }',
           'void ae_i_chain3(int x) { gi = gi2 = gi3 = x; }',
           'void ae_i_chain_k(void) { gi = gi2 = 7; }',
           'void ae_i_chain_ll(int x) { int a, b; a = b = x; gr = a + b; }',
           'void ae_fl_chain(void) { struct fl *cp, *pp; for (pp = cp = gfl; cp; pp = cp, cp = cp->next) if (cp->size > 4) break; gfl = pp; }',
           'int ae_c_tou(char *s1, char *s2) { char c1, c2; while ((c1 = *s1) == (c2 = *s2)) { if (!c1) return 0; s1++; s2++; } return c1 - c2; }',
           'int ae_i_while(int *p) { int v, n = 0; while ((v = *p++) > 0) n += v; return n; }',
           'void ae_i_member(struct fl *p, int x) { if ((p->size = x) == 0) gr = 1; }',
           'void ae_i_opassign(int x) { gi += (gi2 = x); }']
    return {'assign_expr.c': out + fs}

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
    files.update(opt_param_files())
    files.update(ra_home_files())
    files.update(ra_chain_files())
    files.update(ra_home32_files())
    files.update(ra_libshape_files())
    files.update(fp_order_files())
    files.update(fp_files())
    files.update(fp_temp_files())
    files.update(opt_temp_files())
    files.update(opt_counted_files())
    files.update(fp_stmt_files())
    files.update(cond_bits_files())
    files.update(assign_expr_files())
    for n, lines in sorted(files.items()):
        open(os.path.join(d, n), 'w').write('\n'.join(lines) + '\n')
    open(os.path.join(out, 'micro-sources.txt'), 'w').write(''.join('micro/%s\n' % n for n in sorted(files)))
    print('%d files, %d functions' % (len(files), sum(sum(1 for l in v if '{' in l) for v in files.values())))

main()
