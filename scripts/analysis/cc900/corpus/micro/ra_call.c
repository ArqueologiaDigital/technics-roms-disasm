/* Register allocation across calls: what goes to IZ / QIZ, and what stays in memory. */
extern void f0(void); extern void f1(int); extern int g1(int); extern long gl1(long); extern int ga[10];
int rc_keep1(int a) { int v0; v0 = a + 0; f0(); return v0; }
void rc_loop1(int k) { int i, v0; v0 = 0; for (i = 0; i < k; i++) { f1(v0); } }
int rc_keep2(int a) { int v0, v1; v0 = a + 0; v1 = a + 1; f0(); return v0 + v1; }
void rc_loop2(int k) { int i, v0, v1; v0 = 0; v1 = 1; for (i = 0; i < k; i++) { f1(v0 + v1); } }
int rc_keep3(int a) { int v0, v1, v2; v0 = a + 0; v1 = a + 1; v2 = a + 2; f0(); return v0 + v1 + v2; }
void rc_loop3(int k) { int i, v0, v1, v2; v0 = 0; v1 = 1; v2 = 2; for (i = 0; i < k; i++) { f1(v0 + v1 + v2); } }
int rc_keep4(int a) { int v0, v1, v2, v3; v0 = a + 0; v1 = a + 1; v2 = a + 2; v3 = a + 3; f0(); return v0 + v1 + v2 + v3; }
void rc_loop4(int k) { int i, v0, v1, v2, v3; v0 = 0; v1 = 1; v2 = 2; v3 = 3; for (i = 0; i < k; i++) { f1(v0 + v1 + v2 + v3); } }
int rc_param(int a, int b) { f0(); return a + b; }
int rc_param_twice(int a) { f1(a); f1(a); return a; }
int rc_param_thrice(int a) { f1(a); f1(a); f1(a); return a; }
long rc_long(long a) { long x = gl1(a); f0(); return x + a; }
int rc_ptr(int *p) { f0(); return *p; }
int rc_ptr_loop(int *p, int n) { int s = 0; while (n--) s += g1(*p++); return s; }
int rc_two_loops(int n) { int i, s = 0; for (i = 0; i < n; i++) s += g1(i); for (i = 0; i < n; i++) s -= g1(i); return s; }
void rc_dowhile(int n) { do { f0(); } while (--n); }
void rc_while(int n) { while (n--) f0(); }
void rc_while2(int n) { while (n-- > 0) f0(); }
void rc_for(int n) { int i; for (i = 0; i < n; i++) f0(); }
