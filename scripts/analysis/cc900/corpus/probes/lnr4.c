/* Held-out check for research-scratch sessions/2026-11-09_cc900-leaf-none: written after the rule was fitted on
   lnr.c, lnr2.c, lnr3.c and the micro corpora, to test its predictions.  Every local starts from a distinct
   constant (11 and up), so that its register can be read from the instruction that loads that constant. */
extern int g1, g2, gr;
extern char gc;
extern int ga[10], gb[10];
extern int gu[], gw[];
extern long gla[10];
extern char gca[10];

int h1(int *p, int n) { int i = 11, s = 12, t = 13; for (; i < n; i++) { s += p[i]; t ^= gu[i]; } gr = t; return s; }
void h2(int n) { int a = 14, i = 15; for (; i < n; i++) { ga[i] = gb[i] * a; a++; } gr = a; }
int h3(int k) { int i = 16, x = 17; for (; i < k; i++) x = x + (gr << i); return x; }
void h4(int *p, int *q, int n) { int i = 18, d = 19; for (; i < n; i++) p[i] = q[i] + d; gr = d; }
void h5(char *s, int n) { int i = 20; char c = 21; for (; i < n; i++) c ^= s[i]; gc = c; }
long h6(int n) { int i = 22; long s = 23; for (; i < n; i++) s += gla[i]; return s; }
void h7(int n) { int i = 24, j = 25; for (; i < n; i++) for (j = 26; j < n; j++) ga[j] = gb[i]; }
int h8(int *t, int n) { int i = 27, m = t[0]; for (; i < n; i++) if (t[i] > m) m = t[i]; return m; }
void h9(int k) { int a = 28, b = 29, i = 30; for (; i < k; i++) { gu[i] = gw[i]; a += i; } g1 = a; g2 = b; }
void h10(int k) { int a = 31, i = 32; for (; i < k; i++) { gu[i] = gw[i]; a += i; } g1 = a; }
int h11(int x) { int n = 33; while (x > 0) { n += x & 3; x >>= 2; } return n; }
void h12(int *p, int n) { int i = 34; for (; i < n; i++) p[i] = p[i] << 1; }
int h13(int n) { int i = 35, a = 36, b = 37; for (; i < n; i++) { a += gca[i]; b -= gca[i]; } return a - b; }
void h14(char *d, int n) { int i = 38; for (; i < n; i++) d[i] = gca[i]; }
int h15(int n) { int i = 39, s = 40; for (; i < n; i++) s += i * i; return s; }
void h16(int n) { int i = 41, j = 42; for (; i < n; i++) { j = gu[i]; gw[i] = j + j; } }
void h17(int *p, int n) { int i = 43, k = 44; for (; i < n; i++) { p[i] += gw[i]; k += 2; } g1 = k; }
int h18(int n, int m) { int i = 45, s = 46; for (; i < n; i++) s += m * gb[i] + m; return s; }
