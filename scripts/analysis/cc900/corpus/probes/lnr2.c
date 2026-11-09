/* Second round for research-scratch sessions/2026-11-09_cc900-leaf-none (see lnr.c).
   q_*: the loop bodies of lnr.c's r_* with the counter declared LAST, so that it is allocated first: its register
        shows what the body keeps from a variable the body reads; the dummies then show what it keeps from variables
        it does not read (as in lnr.c).
   p_*: when a parameter that gets a register is allocated before the locals. */
extern int g1, g2, g3, gr;
extern int ga[10], gb[10];
extern int gu[], gw[];
extern long gla[10], glb[10];
extern char gca[10], gcb[10];
extern int *gp;

#define D_DECL int d1 = g1, d2 = g2, d3 = g3;
#define D_USE g1 = d1; g2 = d2; g3 = d3;

void q_none(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = i; D_USE }
void q_ga_rd(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = ga[i]; D_USE }
void q_ga_wr(int k) { D_DECL int i; for (i = 0; i < k; i++) ga[i] = gr; D_USE }
void q_ga_cpy(int k) { D_DECL int i; for (i = 0; i < k; i++) ga[i] = gb[i]; D_USE }
void q_ga_acc(int k) { D_DECL int i; for (i = 0; i < k; i++) ga[i] += gb[i]; D_USE }
void q_ga_mul(int k) { D_DECL int i; for (i = 0; i < k; i++) gr += ga[i] * gb[i]; D_USE }
void q_ga_add(int k) { D_DECL int i; for (i = 0; i < k; i++) gr += ga[i] + gb[i]; D_USE }
void q_gu_rd(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = gu[i]; D_USE }
void q_gu_wr(int k) { D_DECL int i; for (i = 0; i < k; i++) gu[i] = gr; D_USE }
void q_gu_cpy(int k) { D_DECL int i; for (i = 0; i < k; i++) gu[i] = gw[i]; D_USE }
void q_gu_acc(int k) { D_DECL int i; for (i = 0; i < k; i++) gu[i] += gw[i]; D_USE }
void q_p_rd(int *p, int k) { D_DECL int i; for (i = 0; i < k; i++) gr = p[i]; D_USE }
void q_p_wr(int *p, int k) { D_DECL int i; for (i = 0; i < k; i++) p[i] = gr; D_USE }
void q_p_cpy(int *p, int *q, int k) { D_DECL int i; for (i = 0; i < k; i++) p[i] = q[i]; D_USE }
void q_p_acc(int *p, int *q, int k) { D_DECL int i; for (i = 0; i < k; i++) p[i] += q[i]; D_USE }
void q_p_mul(int *p, int *q, int k) { D_DECL int i; for (i = 0; i < k; i++) gr += p[i] * q[i]; D_USE }
void q_p_add(int *p, int *q, int k) { D_DECL int i; for (i = 0; i < k; i++) gr += p[i] + q[i]; D_USE }
void q_p_wri(int *p, int k) { D_DECL int i; for (i = 0; i < k; i++) p[i] = i; D_USE }
void q_c_cpy(int k) { D_DECL int i; for (i = 0; i < k; i++) gca[i] = gcb[i]; D_USE }
void q_cp_cpy(char *p, char *q, int k) { D_DECL int i; for (i = 0; i < k; i++) p[i] = q[i]; D_USE }
void q_l_clr(int k) { D_DECL int i; for (i = 0; i < k; i++) gla[i] = 0; D_USE }
void q_l_cpy(int k) { D_DECL int i; for (i = 0; i < k; i++) gla[i] = glb[i]; D_USE }
void q_mul_i(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = gr * i; D_USE }
void q_div_i(int k) { D_DECL int i; for (i = 1; i < k; i++) gr = gr / i; D_USE }
void q_div_k(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = gr / 10; D_USE }
void q_mod_k(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = gr % 10; D_USE }
void q_shl_i(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = 1 << i; D_USE }
void q_shr_i(int k) { D_DECL int i; for (i = 0; i < k; i++) gr = gr >> i; D_USE }
void q_gp_wr(int k) { D_DECL int i; for (i = 0; i < k; i++) *gp = i; D_USE }
void q_gp_idx(int k) { D_DECL int i; for (i = 0; i < k; i++) gp[i] = 0; D_USE }

void q_free_only(int k) { D_DECL int i; for (i = 0; i < k; i++) gr += i; D_USE }

void p_if(int n) { int i; for (i = 0; i < 9; i++) if (n) ga[i] = n + n; }
void p_while(int n) { int i = 0; while (i < n) { ga[i] = n; i++; } }
void p_assign(int *t) { int i; int m; m = t[0]; for (i = 0; i < 9; i++) t[i] = t[i + 1]; gr = m; }
void p_decl(int *t) { int m = t[0]; int i; for (i = 0; i < 9; i++) t[i] = t[i + 1]; gr = m; }
void p_decl_late(int *t) { int i; int m = t[0]; for (i = 0; i < 9; i++) t[i] = t[i + 1]; gr = m; }
void p_forinit(int n) { int i; for (i = n; i > 0; i--) ga[i] = n + n; }
void p_bound_only(int n, int *t) { int i; for (i = 0; i < n; i++) t[i] = t[i + 1] + t[i + 2]; }
void p_bound_body(int n) { int i; for (i = 0; i < n; i++) gr += n; }
void p_body3(int n) { int i; for (i = 0; i < 9; i++) gr += n + n + n; }
void p_two_loops(int n) { int i; for (i = 0; i < 9; i++) ga[i] = n; for (i = 0; i < 9; i++) gb[i] = n; }
void p_dowhile(int n) { int i = 0; do { ga[i] = n; i++; } while (i < n); }
void p_cond_after(int *t, int n) { int i; for (i = 0; i < 9; i++) t[i] = t[i + 1]; if (t[0] < n) gr = n; }
