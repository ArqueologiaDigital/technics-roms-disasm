/* Leaf functions without options: which registers the variables get (research-scratch
   sessions/2026-11-09_cc900-leaf-none).
   r_*: three "dummy" locals d1..d3, declared after the counter and live across the loop, fill the free registers
        before the counter does; the registers they skip are the ones the loop body keeps for itself.
   o_*: a promoted parameter and a local compete for one register: which is allocated first.
   l_*: two locals with different use counts: declaration order against use count.
   h_*: which variable a return expression pulls into HL. */
extern int g1, g2, g3, gr;
extern int ga[10], gb[10];
extern int gu[], gw[];
extern long gla[10], glb[10];
extern char gca[10], gcb[10];
extern int *gp;

#define D_DECL int d1 = g1, d2 = g2, d3 = g3;
#define D_USE g1 = d1; g2 = d2; g3 = d3;

void r_none(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = i; D_USE }
void r_ga_rd(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = ga[i]; D_USE }
void r_ga_wr(int k) { int i; D_DECL for (i = 0; i < k; i++) ga[i] = gr; D_USE }
void r_ga_cpy(int k) { int i; D_DECL for (i = 0; i < k; i++) ga[i] = gb[i]; D_USE }
void r_ga_acc(int k) { int i; D_DECL for (i = 0; i < k; i++) ga[i] += gb[i]; D_USE }
void r_ga_mul(int k) { int i; D_DECL for (i = 0; i < k; i++) gr += ga[i] * gb[i]; D_USE }
void r_ga_add(int k) { int i; D_DECL for (i = 0; i < k; i++) gr += ga[i] + gb[i]; D_USE }
void r_gu_rd(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = gu[i]; D_USE }
void r_gu_wr(int k) { int i; D_DECL for (i = 0; i < k; i++) gu[i] = gr; D_USE }
void r_gu_cpy(int k) { int i; D_DECL for (i = 0; i < k; i++) gu[i] = gw[i]; D_USE }
void r_gu_acc(int k) { int i; D_DECL for (i = 0; i < k; i++) gu[i] += gw[i]; D_USE }
void r_p_rd(int *p, int k) { int i; D_DECL for (i = 0; i < k; i++) gr = p[i]; D_USE }
void r_p_wr(int *p, int k) { int i; D_DECL for (i = 0; i < k; i++) p[i] = gr; D_USE }
void r_p_cpy(int *p, int *q, int k) { int i; D_DECL for (i = 0; i < k; i++) p[i] = q[i]; D_USE }
void r_p_acc(int *p, int *q, int k) { int i; D_DECL for (i = 0; i < k; i++) p[i] += q[i]; D_USE }
void r_p_mul(int *p, int *q, int k) { int i; D_DECL for (i = 0; i < k; i++) gr += p[i] * q[i]; D_USE }
void r_p_add(int *p, int *q, int k) { int i; D_DECL for (i = 0; i < k; i++) gr += p[i] + q[i]; D_USE }
void r_p_wri(int *p, int k) { int i; D_DECL for (i = 0; i < k; i++) p[i] = i; D_USE }
void r_c_cpy(int k) { int i; D_DECL for (i = 0; i < k; i++) gca[i] = gcb[i]; D_USE }
void r_cp_cpy(char *p, char *q, int k) { int i; D_DECL for (i = 0; i < k; i++) p[i] = q[i]; D_USE }
void r_l_clr(int k) { int i; D_DECL for (i = 0; i < k; i++) gla[i] = 0; D_USE }
void r_l_cpy(int k) { int i; D_DECL for (i = 0; i < k; i++) gla[i] = glb[i]; D_USE }
void r_mul_i(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = gr * i; D_USE }
void r_div_i(int k) { int i; D_DECL for (i = 1; i < k; i++) gr = gr / i; D_USE }
void r_div_k(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = gr / 10; D_USE }
void r_mod_k(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = gr % 10; D_USE }
void r_shl_i(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = 1 << i; D_USE }
void r_shr_i(int k) { int i; D_DECL for (i = 0; i < k; i++) gr = gr >> i; D_USE }
void r_gp_wr(int k) { int i; D_DECL for (i = 0; i < k; i++) *gp = i; D_USE }
void r_gp_idx(int k) { int i; D_DECL for (i = 0; i < k; i++) gp[i] = 0; D_USE }

void o_in(int *t) { int i; for (i = 0; i < 9; i++) t[i] = t[i + 1]; }
void o_before(int *t) { int i; t[9] = 0; for (i = 0; i < 9; i++) t[i] = t[i + 1]; }
void o_after(int *t) { int i; for (i = 0; i < 9; i++) t[i] = t[i + 1]; t[9] = 0; }
void o_init(int *t) { int m = t[0]; int i; for (i = 0; i < 9; i++) t[i] = t[i + 1]; gr = m; }
void o_n_bound(int n) { int i; for (i = 0; i < n; i++) ga[i] = n; }
void o_n_in(int n) { int i; for (i = 0; i < 9; i++) ga[i] = n + n; }
void o_n_after(int n) { int i; for (i = 0; i < 9; i++) ga[i] = n; gr = n; }
void o_n_before(int n) { int i; gr = n; for (i = 0; i < 9; i++) ga[i] = n; }
void o_n_deep(int n) { int i, j; for (i = 0; i < 9; i++) for (j = 0; j < 9; j++) ga[j] = n + n; }
void o_n_bounds(int n) { int i, j; for (i = 0; i < n; i++) for (j = 0; j < n; j++) ga[j] = 0; }
void o_two(int *t, int n) { int i; for (i = 0; i < n; i++) t[i] = t[i + 1] + n; }

void l_heavy_first(int k) { int a, b, i; a = 0; b = 0; for (i = 0; i < k; i++) { a += ga[i]; a += gb[i]; a ^= i; b++; } g1 = a; g2 = b; }
void l_heavy_last(int k) { int b, a, i; a = 0; b = 0; for (i = 0; i < k; i++) { a += ga[i]; a += gb[i]; a ^= i; b++; } g1 = a; g2 = b; }
void l_i_last(int k) { int a, b, i; a = 0; b = 0; for (i = 0; i < k; i++) { a += ga[i]; b++; } g1 = a; g2 = b; }
void l_i_first(int k) { int i, a, b; a = 0; b = 0; for (i = 0; i < k; i++) { a += ga[i]; b++; } g1 = a; g2 = b; }

int h_ret_a(int k) { int i, a = 0, b = 0; for (i = 0; i < k; i++) { a += ga[i]; b += gb[i]; } gr = b; return a; }
int h_add_ba(int k) { int i, a = 0, b = 0; for (i = 0; i < k; i++) { a += ga[i]; b += gb[i]; } return b + a; }
int h_add_ab(int k) { int i, a = 0, b = 0; for (i = 0; i < k; i++) { a += ga[i]; b += gb[i]; } return a + b; }
int h_sub_ab(int k) { int i, a = 0, b = 0; for (i = 0; i < k; i++) { a += ga[i]; b += gb[i]; } return a - b; }
int h_tern(int k) { int i, a = 0, b = 0; for (i = 0; i < k; i++) { a += ga[i]; b += gb[i]; } return k ? a : b; }
