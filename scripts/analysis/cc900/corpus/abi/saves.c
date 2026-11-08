/* Which registers does a function save, and which does it expect a call to destroy? */
extern int f1(int); extern void g0(void);
int sv_leaf(int a, int b) { return a * b + a; }
int sv_keep_across(int a) { int x = a + 1; g0(); return x + a; }
int sv_many(int a, int b, int c, int d) { int x = a + b, y = c + d, z = a - d; g0(); return x * y + z; }
int sv_register(int n) { register int i; register int s = 0; for (i = 0; i < n; i++) s += f1(i); return s; }
int sv_loop_ptr(char *p) { int n = 0; while (*p++) n++; return n; }
