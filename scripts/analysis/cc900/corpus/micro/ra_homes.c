/* Values live across a call: which register or slot does each get? */
extern void g0(void); extern int g1(int); extern int gi; extern long gl;
int rh_l1(int a) { int x = a + 1; g0(); return x; }
int rh_p1(int a) { g0(); return a; }
int rh_lp(int a) { int x = a + 1; g0(); return x + a; }
int rh_lp_x2(int a) { int x = a + 1; g0(); return x + x + a; }
int rh_lp_a2(int a) { int x = a + 1; g0(); return x + a + a; }
int rh_lp_call(int a) { int x = g1(a); g0(); return x + a; }
int rh_ll(int a, int b) { int x = a + b, y = a - b; g0(); return x * y; }
int rh_ll_y2(int a, int b) { int x = a + b, y = a - b; g0(); return x * y + y; }
int rh_ll_x2(int a, int b) { int x = a + b, y = a - b; g0(); return x * y + x; }
int rh_ll_rev(int a, int b) { int y = a - b, x = a + b; g0(); return x * y; }
int rh_lll(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z; }
int rh_lll_z2(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z + z; }
int rh_llll(int a, int b, int c) { int w = a + c, x = a + b, y = b + c, z = a - c; g0(); return w + x + y + z; }
int rh_pp(int a, int b) { g0(); return a + b; }
int rh_pp_b2(int a, int b) { g0(); return a + b + b; }
int rh_pp_a2(int a, int b) { g0(); return a + a + b; }
int rh_ppp(int a, int b, int c) { g0(); return a + b + c; }
long rh_long(long a) { long x = a + 1; g0(); return x + a; }
char *rh_ptr(char *p) { char *q = p + 1; g0(); return q; }
int rh_ptr_int(char *p, int n) { g0(); return p[n]; }
int rh_int_ptr(int n, char *p) { g0(); return p[n]; }
int rh_loop(int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(i); return s; }
int rh_loop2(int n) { int s = 0; int i; for (i = 0; i < n; i++) s += g1(i); return s; }
int rh_loop_p(int *p, int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(p[i]); return s; }
void rh_loop_call2(int n) { int i; for (i = 0; i < n; i++) { g0(); g1(i); } }
