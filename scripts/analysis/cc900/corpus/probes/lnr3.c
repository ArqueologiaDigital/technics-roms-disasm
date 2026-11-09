/* Third round for research-scratch sessions/2026-11-09_cc900-leaf-none (see lnr.c, lnr2.c).
   s_*: does a held lvalue address (p[i] += q[i]: ld XBC,XWA) keep BC from the counter when the counter is alone
        (opt_counted.c oc_add2: i in DE) but not when other variables are live (lnr2.c q_p_acc: i in BC)?
   e_*: which first reference makes a parameter be allocated before the locals. */
extern int g1, g2, g3, gr;
extern int gu[], gw[];

void s_add2(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) p[i] += q[i]; }
void s_add2_d1a(int *p, int *q, int n) { int i; int d1 = g1; for (i = 0; i < n; i++) p[i] += q[i]; g1 = d1; }
void s_add2_d1b(int *p, int *q, int n) { int d1 = g1; int i; for (i = 0; i < n; i++) p[i] += q[i]; g1 = d1; }
void s_add2_d2b(int *p, int *q, int n) { int d1 = g1, d2 = g2; int i; for (i = 0; i < n; i++) p[i] += q[i]; g1 = d1; g2 = d2; }
void s_add2_d3b(int *p, int *q, int n) { int d1 = g1, d2 = g2, d3 = g3; int i; for (i = 0; i < n; i++) p[i] += q[i]; g1 = d1; g2 = d2; g3 = d3; }
void s_add2_u(int *p, int *q, int n) { int i; int d1; for (i = 0; i < n; i++) p[i] += q[i]; d1 = g1; g2 = d1; }
void s_cpy2(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) p[i] = q[i]; }
void s_sub2(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) p[i] -= q[i]; }
void s_gu_acc(int n) { int i; for (i = 0; i < n; i++) gu[i] += gw[i]; }
void s_gu_cpy(int n) { int i; for (i = 0; i < n; i++) gu[i] = gw[i]; }
void s_mul(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) gr += p[i] * q[i]; }
void s_add_k(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] += 3; }
void s_add_g(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] += gr; }
void s_add_t(int *t, int n) { int i; for (i = 0; i < n; i++) t[i] += t[i + 1]; }
void s_add_gw(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] += gw[i]; }

void e_gstore(int n) { int i; gr = n; for (i = 0; i < 9; i++) gu[i] = n + n; }
void e_lstore(int n) { int i, m; m = n; for (i = 0; i < 9; i++) gu[i] = n + n; gr = m; }
void e_ifb(int n) { int i; if (n) gr = 1; for (i = 0; i < 9; i++) gu[i] = n + n; }
void e_rd_g(int *t) { int i; gr = t[0]; for (i = 0; i < 9; i++) t[i] = t[i + 1]; }
void e_rd_cmp(int *t) { int i; if (t[0]) gr = 1; for (i = 0; i < 9; i++) t[i] = t[i + 1]; }
void e_wr_first(int *t, int n) { int i; t[0] = n; for (i = 0; i < 9; i++) t[i] = t[i + 1] + n; }
void e_deref_wr(int *t) { int i; *t = 0; for (i = 0; i < 9; i++) t[i] = t[i + 1]; }
void e_body_rd(int *t) { int i; for (i = 0; i < 9; i++) { gr = t[i]; t[i] = t[i + 1]; } }
void e_body_rhs(int *t) { int i; for (i = 0; i < 9; i++) gu[i] = t[i] + t[i + 1]; }
void e_body_wr_n(int n) { int i; for (i = 0; i < 9; i++) { gu[i] = n; gw[i] = n + n; } }
