/* Control flow: if/else, loops, break/continue, early return, ?:, && and ||. */
extern int gi; extern void f0(void); extern void f1(int); extern int g(int);
int c_if(int a) { if (a) return 1; return 2; }
int c_ifelse(int a, int b) { int r; if (a > b) r = a; else r = b; return r; }
void c_ifchain(int a) { if (a == 1) f1(10); else if (a == 2) f1(20); else f1(30); }
int c_tern(int a, int b) { return a < b ? a : b; }
int c_and(int a, int b) { return a && b; }
int c_or(int a, int b) { return a || b; }
void c_andbr(int a, int b) { if (a && b) f0(); }
void c_orbr(int a, int b) { if (a || b) f0(); }
void c_for(int n) { int i; for (i = 0; i < n; i++) f1(i); }
void c_fordown(int n) { int i; for (i = n; i > 0; i--) f1(i); }
void c_while(int n) { while (n--) f0(); }
void c_do(int n) { do { f0(); } while (--n); }
int c_sum(int *p, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }
int c_find(int *p, int n, int k) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
void c_break(int n) { int i; for (i = 0; i < n; i++) { if (g(i)) break; f1(i); } }
void c_cont(int n) { int i; for (i = 0; i < n; i++) { if (g(i)) continue; f1(i); } }
void c_nested(int n) { int i, j; for (i = 0; i < n; i++) for (j = 0; j < i; j++) f1(i + j); }
void c_inf(void) { for (;;) { if (g(gi)) return; f0(); } }
int c_cnt(char *s) { int n = 0; while (*s++) n++; return n; }
void c_clear(char *p, int n) { while (n-- > 0) *p++ = 0; }
void c_copy(char *d, char *s, int n) { int i; for (i = 0; i < n; i++) d[i] = s[i]; }
