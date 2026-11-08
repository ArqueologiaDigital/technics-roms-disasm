/* Calls: argument counts and types, nested calls, results in expressions. */
extern void v0(void); extern void v1(int); extern void v2(int, int); extern void v3(int, long, char *);
extern void v4(char, int, long, int); extern int r1(int); extern long rl(long); extern char rc(void);
extern int gi; extern long gl; extern char gc, *gp;
void k0(void) { v0(); }
void k1(void) { v1(gi); }
void k1k(void) { v1(5); }
void k2(int a) { v2(a, gi); }
void k3(void) { v3(gi, gl, gp); }
void k4(int a) { v4(gc, a, gl, 3); }
int k_expr(int a) { return r1(a) + r1(a + 1); }
int k_nest(int a) { return r1(r1(a)); }
long k_l(long a) { return rl(a) * 2; }
int k_rc(void) { return rc() + 1; }
void k_seq(int a) { v1(a); v1(a + 1); v1(a + 2); }
int k_keep(int a) { int x = r1(a); v0(); return x + a; }
void k_cond(int a) { if (r1(a)) v0(); }
int k_tail(int a) { return r1(a); }
