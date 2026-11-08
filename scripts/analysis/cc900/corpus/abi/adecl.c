/* With -Xr (adecl), where do arguments go, who pops them, and how are register arguments kept? */
extern void t1(char), t2(int, int), t3(long, int, char *), t4(int, int, int, int), t5(long, long, long, long, int);
extern int gi; extern long gl; extern char *gp; extern char gc;
extern int x_i(int); extern void g0(void);
extern int __cdecl lib_f(int, long);
int  d_c(char c) { return c; }
int  d_i2(int a, int b) { return b; }
long d_l3(int a, long b, char *c) { return b + (long)c; }
int  d_i4(int a, int b, int c, int d) { return a + d; }
int  d_i5(int a, int b, int c, int d, int e) { return e; }
long d_l4(long a, long b, long c, long d) { return a + d; }
int  d_keep(int a, int b) { g0(); return a + b; }
int  d_ptr(char *p, int n) { int s = 0; while (n--) s += *p++; return s; }
void c_t1(void) { t1(gc); }
void c_t2(void) { t2(1, gi); }
void c_t3(void) { t3(gl, gi, gp); }
void c_t4(void) { t4(1, 2, 3, 4); }
void c_t5(void) { t5(gl, 2L, 3L, 4L, 5); }
int  c_x(void) { return x_i(gi) + 1; }
int  c_lib(void) { return lib_f(gi, gl); }
