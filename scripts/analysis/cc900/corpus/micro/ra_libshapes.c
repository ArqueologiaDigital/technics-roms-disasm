/* Library-shaped homes: _calloc, _memccpy, _strlen and the steps between them */
extern void *al(unsigned int); extern void *ms(void *, int, unsigned int); extern void g0(void);
extern void g2(unsigned int); extern char *ch(const char *, int, unsigned int);
extern void *vp(const void *, int, unsigned int); extern void *cp2(void *, const void *, unsigned int);
void *ls_cl(unsigned int n, unsigned int s) { void *p; if (!n || !s) return 0; p = al(n * s); if (p) ms(p, 0, n * s); return p; }
void *ls_cl_noguard(unsigned int n, unsigned int s) { void *p; p = al(n * s); if (p) ms(p, 0, n * s); return p; }
void *ls_cl1(unsigned int n) { void *p; if (!n) return 0; p = al(n); if (p) ms(p, 0, n); return p; }
void *ls_cl1_noguard(unsigned int n) { void *p; p = al(n); if (p) ms(p, 0, n); return p; }
void *ls_cl1_always(unsigned int n) { void *p; p = al(n); ms(p, 0, n); return p; }
void *ls_cl1_notest(unsigned int n) { void *p; p = al(n); g2(n); return p; }
void *ls_cl1_ptest(unsigned int n) { void *p; p = al(n); if (p) g2(n); return p; }
void *ls_cl1_pneg(unsigned int n) { void *p; p = al(n); if (p == 0) g2(n); return p; }
void *ls_cl1_parg(unsigned int n) { void *p; p = al(n); if (p) ms(p, 0, 4); return p; }
void *ls_cl_mul1(unsigned int n, unsigned int s) { void *p; p = al(n * s); if (p) ms(p, 0, n); return p; }
void *ls_mc(void *s1, const void *s2, int c, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(s1, s2, n); } else { unsigned int nn; nn = pos - (unsigned char *)s2 + 1; cp2(s1, s2, nn); } return (void *)pos; }
void *ls_mc_nos1(const void *s2, int c, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, n); if (pos == 0) { cp2(0, s2, n); } else { cp2(0, s2, pos - (unsigned char *)s2 + 1); } return (void *)pos; }
void *ls_mc_non(void *s1, const void *s2, int c) { unsigned char *pos; pos = (unsigned char *)vp(s2, c, 8); if (pos == 0) { cp2(s1, s2, 8); } else { cp2(s1, s2, pos - (unsigned char *)s2 + 1); } return (void *)pos; }
void *ls_mc_test(const void *s2, unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(s2, 0, n); if (pos == 0) cp2(0, s2, n); return (void *)pos; }
void *ls_mc_n1(unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(0, 0, n); if (pos == 0) g2(n); return (void *)pos; }
void *ls_mc_n1p(unsigned int n) { unsigned char *pos; pos = (unsigned char *)vp(0, 0, n); if (pos) g2(n); return (void *)pos; }
unsigned int ls_sl(const char *s) { char *ss; ss = ch(s, 0, 0xffff); if (ss == 0) return 0xffff; return (unsigned int)(ss - (char *)s); }
unsigned int ls_sl_n(const char *s, unsigned int n) { char *ss; ss = ch(s, 0, n); if (ss == 0) return n; return (unsigned int)(ss - (char *)s); }
unsigned int ls_sl_g(const char *s) { g0(); return (unsigned int)(*s); }
unsigned int ls_sl_2(const char *s) { g2(*s); return (unsigned int)(*s); }
char *ls_sl_ret(const char *s) { char *ss; ss = ch(s, 0, 4); if (ss == 0) return (char *)s; return ss; }
