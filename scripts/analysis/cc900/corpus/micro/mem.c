/* Pointer, array and struct member access. */
struct s { char c; int i; long l; char *p; int a[4]; };
extern struct s gs, *gps; extern int ga[10]; extern char gca[10]; extern long gla[10];
int m_ga_k(void) { return ga[3]; }
int m_ga_v(int i) { return ga[i]; }
char m_gca_v(int i) { return gca[i]; }
long m_gla_v(int i) { return gla[i]; }
void m_ga_set(int i, int v) { ga[i] = v; }
int m_p_k(int *p) { return p[2]; }
int m_p_v(int *p, int i) { return p[i]; }
long m_lp_v(long *p, int i) { return p[i]; }
char m_cp_v(char *p, unsigned int i) { return p[i]; }
int m_gs_i(void) { return gs.i; }
long m_gs_l(void) { return gs.l; }
int m_gps_i(void) { return gps->i; }
int m_gps_a(int k) { return gps->a[k]; }
void m_gps_set(int v) { gps->i = v; gps->c = 0; }
int m_ps_i(struct s *p) { return p->i; }
char *m_ps_p(struct s *p) { return p->p; }
int *m_addr(int i) { return &ga[i]; }
int m_diff(int *a, int *b) { return a - b; }
int *m_padd(int *p, int i) { return p + i; }
void m_copy(struct s *d) { *d = gs; }
int m_2d(int (*a)[4], int i, int j) { return a[i][j]; }
