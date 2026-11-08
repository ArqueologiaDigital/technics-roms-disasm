/* Register allocation in leaf functions: locals and parameters in loops, returned or not. */
extern int ga[10]; extern char gca[10]; extern long gla[10];
int ra_leaf1(int k) { int i; int v0; v0 = 0; for (i = 0; i < k; i++) { v0 += ga[i]; } return v0; }
int ra_leafsum1(int k) { int i; int v0; v0 = 0; for (i = 0; i < k; i++) { v0 += ga[i]; } return v0; }
int ra_leaf2(int k) { int i; int v0, v1; v0 = 0; v1 = 1; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; } return v0; }
int ra_leafsum2(int k) { int i; int v0, v1; v0 = 0; v1 = 1; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; } return v0 + v1; }
int ra_leaf3(int k) { int i; int v0, v1, v2; v0 = 0; v1 = 1; v2 = 2; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; } return v0; }
int ra_leafsum3(int k) { int i; int v0, v1, v2; v0 = 0; v1 = 1; v2 = 2; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; } return v0 + v1 + v2; }
int ra_leaf4(int k) { int i; int v0, v1, v2, v3; v0 = 0; v1 = 1; v2 = 2; v3 = 3; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; v3 += ga[i]; } return v0; }
int ra_leafsum4(int k) { int i; int v0, v1, v2, v3; v0 = 0; v1 = 1; v2 = 2; v3 = 3; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; v3 += ga[i]; } return v0 + v1 + v2 + v3; }
int ra_leaf5(int k) { int i; int v0, v1, v2, v3, v4; v0 = 0; v1 = 1; v2 = 2; v3 = 3; v4 = 4; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; v3 += ga[i]; v4 += ga[i]; } return v0; }
int ra_leafsum5(int k) { int i; int v0, v1, v2, v3, v4; v0 = 0; v1 = 1; v2 = 2; v3 = 3; v4 = 4; for (i = 0; i < k; i++) { v0 += ga[i]; v1 += ga[i]; v2 += ga[i]; v3 += ga[i]; v4 += ga[i]; } return v0 + v1 + v2 + v3 + v4; }
long ra_long(int k) { int i; long s = 0; for (i = 0; i < k; i++) s += gla[i]; return s; }
char ra_char(int k) { int i; char c = 0; for (i = 0; i < k; i++) c ^= gca[i]; return c; }
int ra_ptr(int *p, int k) { int s = 0; while (k--) s += *p++; return s; }
int ra_ptr2(int *p, int *q, int k) { int s = 0; while (k--) s += *p++ * *q++; return s; }
void ra_ptrcpy(char *d, char *s) { while (*s) *d++ = *s++; *d = 0; }
int ra_param3(int a, int b, int c) { int i, s = 0; for (i = 0; i < a; i++) s += b * c; return s; }
int ra_noloop(int a, int b) { int x = a + b; int y = a - b; return x * y; }
int ra_noloop3(int a, int b) { int x = a + b; int y = a - b; int z = x * y; return z + x + y; }
int ra_twice(int a) { int x = a * 3; ga[0] = x; ga[1] = x; return x; }
void ra_dowhile(int n) { do { ga[n] = 0; } while (--n); }
void ra_while(int n) { while (n--) ga[n] = 0; }
void ra_for_down(int n) { int i; for (i = n; i > 0; i--) ga[i] = 0; }
int ra_nested(int n) { int i, j, s = 0; for (i = 0; i < n; i++) for (j = 0; j < n; j++) s += i * j; return s; }
