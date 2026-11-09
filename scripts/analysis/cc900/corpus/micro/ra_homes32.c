/* A 32-bit local against a 16-bit parameter, both live across a call */
extern void g0(void); extern void g2(int); extern int g1(int); extern char *fp(int); extern long fl(int);
extern void *vp(const void *, int, unsigned int); extern void *cp2(void *, const void *, unsigned int);
char *h_p(int n) { char *p = fp(n); g2(n); return p; }
char *h_p_only(int n) { char *p = fp(n); g0(); return p; }
char *h_p_n1(int n) { char *p = fp(1); g2(n); return p; }
char *h_p_n3(int n) { char *p = fp(n); g2(n); return p + n; }
char *h_p_n4(int n) { char *p = fp(n); g2(n); g2(n); return p; }
char *h_p_if(int n) { char *p = fp(n); if (p == 0) g2(n); return p; }
char *h_p_asg(int n) { char *p; p = fp(n); g2(n); return p; }
char *h_p_p3(int n) { char *p = fp(n); g2(n); if (p == 0) return p + 1; return p; }
char *h_p_m(int n, int m) { char *p = fp(n); g2(m); return p; }
int h_p_diff(char *s, int n) { char *p = fp(n); g2(n); return p - s; }
long h_l(int n) { long x = fl(n); g2(n); return x; }
long h_l_n3(int n) { long x = fl(n); g2(n); return x + n; }
int h_i(int n) { int x = g1(n); g2(n); return x; }
char *h_p_un(unsigned int n) { char *p = fp(1); g2(n); return p; }
void *h_mc(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { unsigned int nn; nn = pos - (unsigned char *)s2 + 1; cp2(s1, s2, nn); } return (void *)pos; }
void *h_mc_int(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { cp2(s1, s2, 4); } return (void *)pos; }
void *h_mc_nouse(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, n); cp2(s1, s2, n); return (void *)pos; }
