/* Assignment as a value */
struct fl { struct fl *next; int size; };
extern char gc, gc2; extern int gi, gi2, gi3; extern long gl, gl2; extern char *gp, *gp2;
extern struct fl *gfl; extern int f(int); extern int g(void); extern char *h(void); extern int gr;
void ae_c_chain_gg(char x) { gc = gc2 = x; }
void ae_c_chain_lg(char x) { char y; gc = y = x; gr = (int)(y != 0); }
char ae_c_ret_g(char x) { return (gc = x); }
int ae_c_eq_g(char x) { if ((gc = x) == 0) return 2; return 3; }
int ae_c_ne_l(char x) { char y; if ((y = x) != 0) return (int)(y == x); return 3; }
int ae_c_two(char x, char z) { if ((gc = x) == (gc2 = z)) return 2; return 3; }
void ae_c_ptr(char *p, char x) { if ((*p = x) != 0) gr = 2; }
void ae_i_chain_gg(int x) { gi = gi2 = x; }
void ae_i_chain_lg(int x) { int y; gi = y = x; gr = (int)(y != 0); }
int ae_i_ret_g(int x) { return (gi = x); }
int ae_i_eq_g(int x) { if ((gi = x) == 0) return 2; return 3; }
int ae_i_ne_l(int x) { int y; if ((y = x) != 0) return (int)(y == x); return 3; }
int ae_i_two(int x, int z) { if ((gi = x) == (gi2 = z)) return 2; return 3; }
void ae_i_ptr(int *p, int x) { if ((*p = x) != 0) gr = 2; }
void ae_l_chain_gg(long x) { gl = gl2 = x; }
void ae_l_chain_lg(long x) { long y; gl = y = x; gr = (int)(y != 0); }
long ae_l_ret_g(long x) { return (gl = x); }
int ae_l_eq_g(long x) { if ((gl = x) == 0) return 2; return 3; }
int ae_l_ne_l(long x) { long y; if ((y = x) != 0) return (int)(y == x); return 3; }
int ae_l_two(long x, long z) { if ((gl = x) == (gl2 = z)) return 2; return 3; }
void ae_l_ptr(long *p, long x) { if ((*p = x) != 0) gr = 2; }
void ae_p_chain_gg(char * x) { gp = gp2 = x; }
void ae_p_chain_lg(char * x) { char * y; gp = y = x; gr = (int)(y != 0); }
char * ae_p_ret_g(char * x) { return (gp = x); }
int ae_p_eq_g(char * x) { if ((gp = x) == 0) return 2; return 3; }
int ae_p_ne_l(char * x) { char * y; if ((y = x) != 0) return (int)(y == x); return 3; }
int ae_p_two(char * x, char * z) { if ((gp = x) == (gp2 = z)) return 2; return 3; }
void ae_p_ptr(char * *p, char * x) { if ((*p = x) != 0) gr = 2; }
void ae_c_ptr_nl(char *s, unsigned char c) { if ((*s = c) != 10) s++; gp = s; }
int ae_c_loop(char *s) { char c; int n = 0; while ((c = *s++) != 0) n += c; return n; }
int ae_i_call(void) { int v; if ((v = g()) < 0) return 0; return v; }
int ae_i_call_g(void) { if ((gi = g()) < 0) return 0; return gi; }
char *ae_p_call(void) { char *q; if ((q = h()) == 0) return gp; return q; }
void ae_i_arg(int x) { f(gi = x); }
int ae_i_add(int x) { int y; y = (gi = x) + 1; return y; }
void ae_i_chain3(int x) { gi = gi2 = gi3 = x; }
void ae_i_chain_k(void) { gi = gi2 = 7; }
void ae_i_chain_ll(int x) { int a, b; a = b = x; gr = a + b; }
void ae_fl_chain(void) { struct fl *cp, *pp; for (pp = cp = gfl; cp; pp = cp, cp = cp->next) if (cp->size > 4) break; gfl = pp; }
int ae_c_tou(char *s1, char *s2) { char c1, c2; while ((c1 = *s1) == (c2 = *s2)) { if (!c1) return 0; s1++; s2++; } return c1 - c2; }
int ae_i_while(int *p) { int v, n = 0; while ((v = *p++) > 0) n += v; return n; }
void ae_i_member(struct fl *p, int x) { if ((p->size = x) == 0) gr = 1; }
void ae_i_opassign(int x) { gi += (gi2 = x); }
