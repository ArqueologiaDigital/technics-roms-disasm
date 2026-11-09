/* Rule triggers: shapes of the library routines whose code changed between V4.23 and 2003. */
struct pr { long q, r; }; struct pi { int q, r; };
extern void *mchr(const void *, int, unsigned int); extern void *mcpy(void *, const void *, unsigned int);
extern int g1(int); extern void f0(void);
struct pr r_divmod(long x, long y) { struct pr r; struct pr *p = &r; if (y) { p->q = x / y; p->r = x % y; } return r; }
struct pi r_divmod_i(int x, int y) { struct pi r; struct pi *p = &r; p->q = x / y; p->r = x % y; return r; }
void r_buf(char *out, unsigned long v) { char buf[16]; char *p = buf + 15; *p = 0; do { *--p = (char)(v % 10) + 48; v /= 10; } while (v); mcpy(out, p, (buf + 16) - p); }
void r_buf2(char *out) { char buf[8]; char *p; p = buf; p[7] = 0; mcpy(out, p, 8); }
void *r_ccpy(void *d, const void *s, int c, unsigned int n) { char *e = mchr(s, c, n); if (e == 0) { mcpy(d, s, n); return 0; } mcpy(d, s, e - (char *)s + 1); return (char *)d + (e - (char *)s) + 1; }
char *r_rchr(char *s, int c, unsigned int n) { char *p = s + n; while (n--) if (*--p == (char)c) return p; return 0; }
void r_countdown(char *p, unsigned int n) { while (n--) *p++ = 0; }
int r_countdown2(int *p, unsigned int n) { int s = 0; do { s += *p++; } while (--n); return s; }
char *r_rev(char *s, unsigned int n) { char *a = s, *b = s + n - 1, t; while (a < b) { t = *a; *a++ = *b; *b-- = t; } return s; }
int r_keep(int a, int b) { int x = g1(a); int y = g1(b); f0(); return x + y + a; }
long r_lkeep(long a) { long x = a * 3; long *p = &x; *p += a; return *p; }
