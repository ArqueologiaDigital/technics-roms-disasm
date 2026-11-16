/* lane_o3 wrong-code probe: struct copies, parameters and returns; see gen_stc.py for the name letters */
extern int gi1, gi3; extern long gl1; extern double gd1; extern void v0(void);
struct s1 { char a; };
struct w1 { int k; struct s1 m; long z; };
extern struct s1 g11, g12, g13, ga1[4], *gp11, *gp12;
extern struct w1 gw1, gwa1[2], *gpw1;
extern struct s1 __cdecl r1(void); extern void x1(struct s1); extern void y1(int, struct s1, int); extern void z1(long, struct s1, double);
struct s2 { int a; };
struct w2 { int k; struct s2 m; long z; };
extern struct s2 g21, g22, g23, ga2[4], *gp21, *gp22;
extern struct w2 gw2, gwa2[2], *gpw2;
extern struct s2 __cdecl r2(void); extern void x2(struct s2); extern void y2(int, struct s2, int); extern void z2(long, struct s2, double);
struct s3 { char a, b, c; };
struct w3 { int k; struct s3 m; long z; };
extern struct s3 g31, g32, g33, ga3[4], *gp31, *gp32;
extern struct w3 gw3, gwa3[2], *gpw3;
extern struct s3 __cdecl r3(void); extern void x3(struct s3); extern void y3(int, struct s3, int); extern void z3(long, struct s3, double);
struct s4 { int a, b; };
struct w4 { int k; struct s4 m; long z; };
extern struct s4 g41, g42, g43, ga4[4], *gp41, *gp42;
extern struct w4 gw4, gwa4[2], *gpw4;
extern struct s4 __cdecl r4(void); extern void x4(struct s4); extern void y4(int, struct s4, int); extern void z4(long, struct s4, double);
struct s5 { char a, b, c, d, e; };
struct w5 { int k; struct s5 m; long z; };
extern struct s5 g51, g52, g53, ga5[4], *gp51, *gp52;
extern struct w5 gw5, gwa5[2], *gpw5;
extern struct s5 __cdecl r5(void); extern void x5(struct s5); extern void y5(int, struct s5, int); extern void z5(long, struct s5, double);
struct s6 { int a, b, c; };
struct w6 { int k; struct s6 m; long z; };
extern struct s6 g61, g62, g63, ga6[4], *gp61, *gp62;
extern struct w6 gw6, gwa6[2], *gpw6;
extern struct s6 __cdecl r6(void); extern void x6(struct s6); extern void y6(int, struct s6, int); extern void z6(long, struct s6, double);
struct s8 { long a; int b, c; };
struct w8 { int k; struct s8 m; long z; };
extern struct s8 g81, g82, g83, ga8[4], *gp81, *gp82;
extern struct w8 gw8, gwa8[2], *gpw8;
extern struct s8 __cdecl r8(void); extern void x8(struct s8); extern void y8(int, struct s8, int); extern void z8(long, struct s8, double);
struct sC { long a, b; int c, d; };
struct wC { int k; struct sC m; long z; };
extern struct sC gC1, gC2, gC3, gaC[4], *gpC1, *gpC2;
extern struct wC gwC, gwaC[2], *gpwC;
extern struct sC __cdecl rC(void); extern void xC(struct sC); extern void yC(int, struct sC, int); extern void zC(long, struct sC, double);
struct sG { long a, b, c, d; };
struct wG { int k; struct sG m; long z; };
extern struct sG gG1, gG2, gG3, gaG[4], *gpG1, *gpG2;
extern struct wG gwG, gwaG[2], *gpwG;
extern struct sG __cdecl rG(void); extern void xG(struct sG); extern void yG(int, struct sG, int); extern void zG(long, struct sG, double);
struct sX { char c[33]; };
struct wX { int k; struct sX m; long z; };
extern struct sX gX1, gX2, gX3, gaX[4], *gpX1, *gpX2;
extern struct wX gwX, gwaX[2], *gpwX;
extern struct sX __cdecl rX(void); extern void xX(struct sX); extern void yX(int, struct sX, int); extern void zX(long, struct sX, double);
struct sN { struct s4 h; long x; int y; };
struct wN { int k; struct sN m; long z; };
extern struct sN gN1, gN2, gN3, gaN[4], *gpN1, *gpN2;
extern struct wN gwN, gwaN[2], *gpwN;
extern struct sN __cdecl rN(void); extern void xN(struct sN); extern void yN(int, struct sN, int); extern void zN(long, struct sN, double);
struct sA { int v[5]; };
struct wA { int k; struct sA m; long z; };
extern struct sA gA1, gA2, gA3, gaA[4], *gpA1, *gpA2;
extern struct wA gwA, gwaA[2], *gpwA;
extern struct sA __cdecl rA(void); extern void xA(struct sA); extern void yA(int, struct sA, int); extern void zA(long, struct sA, double);
void st_gg_1(void) { g11 = g12; }
void st_gl_1(void) { struct s1 t = g12; t.a = 5; g11 = t; }
void st_lg_1(void) { struct s1 t; t = g12; v0(); g11 = t; }
void st_pp_1(struct s1 *d, struct s1 *q) { *d = *q; }
void st_pi_1(struct s1 *d, struct s1 *q, int i) { d[i & 3] = *q; }
void st_gp_1(void) { *gp11 = *gp12; }
void st_ae_1(int i) { ga1[i & 3] = ga1[(i & 3) ^ 1]; }
void st_ag_1(void) { ga1[gi1 & 3] = g12; }
void st_mb_1(void) { gw1.m = g12; }
void st_bm_1(void) { g11 = gw1.m; }
void st_mw_1(int i) { gwa1[i & 1].m = gwa1[(i & 1) ^ 1].m; }
void st_ar_1(void) { gpw1->m = g12; }
void st_ch_1(void) { g11 = g12 = g13; }
void st_lo_1(int n) { int i; for (i = 0; i < (n & 3); i++) ga1[i] = g12; }
void st_if_1(int c) { if (c) g11 = g12; else g11 = g13; }
void st_tc_1(int c) { g11 = c ? g12 : g13; }
void st_tp_1(int c) { g11 = *(c ? gp11 : gp12); }
void st_la_1(void) { struct s1 l[2]; l[0] = g12; l[1] = l[0]; g11 = l[1]; }
int st_cx_1(int a, int b) { g11 = g12; return a + b; }
long st_cy_1(long a, long b, long c) { *gp11 = *gp12; return a - b + c; }
char st_cc_1(char a, int b) { ga1[b & 3] = g12; return a; }
int st_cl_1(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga1[i & 3] = g12; t += i; } return t; }
int st_cp_1(struct s1 *d, int a) { *d = g12; return a * 3; }
void st_pa_1(void) { x1(g12); }
void st_pb_1(int a) { y1(a, g12, a + 1); }
void st_pc_1(void) { z1(gl1, g12, gd1); }
void st_pd_1(struct s1 *p) { x1(*p); }
void st_pe_1(int i) { x1(ga1[i & 3]); }
void st_pr_1(struct s1 q) { g11 = q; }
void st_pq_1(int a, struct s1 q, int b) { g11 = q; gi3 = a - b; }
char st_pf_1(struct s1 q) { return q.a; }
void st_pm_1(struct s1 q) { q.a = 7; g11 = q; }
struct s1 __cdecl st_rt_1(void) { return g12; }
struct s1 __cdecl st_rp_1(struct s1 *p) { return *p; }
struct s1 __cdecl st_rl_1(void) { struct s1 t; t = g12; t.a = 9; return t; }
struct s1 __cdecl st_rq_1(struct s1 q) { return q; }
struct s1 __cdecl st_ri_1(int i) { return ga1[i & 3]; }
struct s1 __cdecl st_rc_1(int c) { if (c) return g12; return g13; }
void st_ug_1(void) { g11 = r1(); }
void st_ul_1(void) { struct s1 t; t = r1(); g11 = t; }
void st_um_1(void) { gw1.m = r1(); }
void st_up_1(void) { *gp11 = r1(); }
void st_ud_1(void) { r1(); }
void st_ux_1(void) { x1(r1()); }
void st_ua_1(int i) { ga1[i & 3] = r1(); }
void st_uv_1(int a) { g11 = r1(); gi3 = a + 1; }
void st_gg_2(void) { g21 = g22; }
void st_gl_2(void) { struct s2 t = g22; t.a = 5; g21 = t; }
void st_lg_2(void) { struct s2 t; t = g22; v0(); g21 = t; }
void st_pp_2(struct s2 *d, struct s2 *q) { *d = *q; }
void st_pi_2(struct s2 *d, struct s2 *q, int i) { d[i & 3] = *q; }
void st_gp_2(void) { *gp21 = *gp22; }
void st_ae_2(int i) { ga2[i & 3] = ga2[(i & 3) ^ 1]; }
void st_ag_2(void) { ga2[gi1 & 3] = g22; }
void st_mb_2(void) { gw2.m = g22; }
void st_bm_2(void) { g21 = gw2.m; }
void st_mw_2(int i) { gwa2[i & 1].m = gwa2[(i & 1) ^ 1].m; }
void st_ar_2(void) { gpw2->m = g22; }
void st_ch_2(void) { g21 = g22 = g23; }
void st_lo_2(int n) { int i; for (i = 0; i < (n & 3); i++) ga2[i] = g22; }
void st_if_2(int c) { if (c) g21 = g22; else g21 = g23; }
void st_tc_2(int c) { g21 = c ? g22 : g23; }
void st_tp_2(int c) { g21 = *(c ? gp21 : gp22); }
void st_la_2(void) { struct s2 l[2]; l[0] = g22; l[1] = l[0]; g21 = l[1]; }
int st_cx_2(int a, int b) { g21 = g22; return a + b; }
long st_cy_2(long a, long b, long c) { *gp21 = *gp22; return a - b + c; }
char st_cc_2(char a, int b) { ga2[b & 3] = g22; return a; }
int st_cl_2(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga2[i & 3] = g22; t += i; } return t; }
int st_cp_2(struct s2 *d, int a) { *d = g22; return a * 3; }
void st_pa_2(void) { x2(g22); }
void st_pb_2(int a) { y2(a, g22, a + 1); }
void st_pc_2(void) { z2(gl1, g22, gd1); }
void st_pd_2(struct s2 *p) { x2(*p); }
void st_pe_2(int i) { x2(ga2[i & 3]); }
void st_pr_2(struct s2 q) { g21 = q; }
void st_pq_2(int a, struct s2 q, int b) { g21 = q; gi3 = a - b; }
int st_pf_2(struct s2 q) { return q.a; }
void st_pm_2(struct s2 q) { q.a = 7; g21 = q; }
struct s2 __cdecl st_rt_2(void) { return g22; }
struct s2 __cdecl st_rp_2(struct s2 *p) { return *p; }
struct s2 __cdecl st_rl_2(void) { struct s2 t; t = g22; t.a = 9; return t; }
struct s2 __cdecl st_rq_2(struct s2 q) { return q; }
struct s2 __cdecl st_ri_2(int i) { return ga2[i & 3]; }
struct s2 __cdecl st_rc_2(int c) { if (c) return g22; return g23; }
void st_ug_2(void) { g21 = r2(); }
void st_ul_2(void) { struct s2 t; t = r2(); g21 = t; }
void st_um_2(void) { gw2.m = r2(); }
void st_up_2(void) { *gp21 = r2(); }
void st_ud_2(void) { r2(); }
void st_ux_2(void) { x2(r2()); }
void st_ua_2(int i) { ga2[i & 3] = r2(); }
void st_uv_2(int a) { g21 = r2(); gi3 = a + 1; }
void st_gg_3(void) { g31 = g32; }
void st_gl_3(void) { struct s3 t = g32; t.a = 5; g31 = t; }
void st_lg_3(void) { struct s3 t; t = g32; v0(); g31 = t; }
void st_pp_3(struct s3 *d, struct s3 *q) { *d = *q; }
void st_pi_3(struct s3 *d, struct s3 *q, int i) { d[i & 3] = *q; }
void st_gp_3(void) { *gp31 = *gp32; }
void st_ae_3(int i) { ga3[i & 3] = ga3[(i & 3) ^ 1]; }
void st_ag_3(void) { ga3[gi1 & 3] = g32; }
void st_mb_3(void) { gw3.m = g32; }
void st_bm_3(void) { g31 = gw3.m; }
void st_mw_3(int i) { gwa3[i & 1].m = gwa3[(i & 1) ^ 1].m; }
void st_ar_3(void) { gpw3->m = g32; }
void st_ch_3(void) { g31 = g32 = g33; }
void st_lo_3(int n) { int i; for (i = 0; i < (n & 3); i++) ga3[i] = g32; }
void st_if_3(int c) { if (c) g31 = g32; else g31 = g33; }
void st_tc_3(int c) { g31 = c ? g32 : g33; }
void st_tp_3(int c) { g31 = *(c ? gp31 : gp32); }
void st_la_3(void) { struct s3 l[2]; l[0] = g32; l[1] = l[0]; g31 = l[1]; }
int st_cx_3(int a, int b) { g31 = g32; return a + b; }
long st_cy_3(long a, long b, long c) { *gp31 = *gp32; return a - b + c; }
char st_cc_3(char a, int b) { ga3[b & 3] = g32; return a; }
int st_cl_3(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga3[i & 3] = g32; t += i; } return t; }
int st_cp_3(struct s3 *d, int a) { *d = g32; return a * 3; }
void st_pa_3(void) { x3(g32); }
void st_pb_3(int a) { y3(a, g32, a + 1); }
void st_pc_3(void) { z3(gl1, g32, gd1); }
void st_pd_3(struct s3 *p) { x3(*p); }
void st_pe_3(int i) { x3(ga3[i & 3]); }
void st_pr_3(struct s3 q) { g31 = q; }
void st_pq_3(int a, struct s3 q, int b) { g31 = q; gi3 = a - b; }
char st_pf_3(struct s3 q) { return q.a; }
void st_pm_3(struct s3 q) { q.a = 7; g31 = q; }
struct s3 __cdecl st_rt_3(void) { return g32; }
struct s3 __cdecl st_rp_3(struct s3 *p) { return *p; }
struct s3 __cdecl st_rl_3(void) { struct s3 t; t = g32; t.a = 9; return t; }
struct s3 __cdecl st_rq_3(struct s3 q) { return q; }
struct s3 __cdecl st_ri_3(int i) { return ga3[i & 3]; }
struct s3 __cdecl st_rc_3(int c) { if (c) return g32; return g33; }
void st_ug_3(void) { g31 = r3(); }
void st_ul_3(void) { struct s3 t; t = r3(); g31 = t; }
void st_um_3(void) { gw3.m = r3(); }
void st_up_3(void) { *gp31 = r3(); }
void st_ud_3(void) { r3(); }
void st_ux_3(void) { x3(r3()); }
void st_ua_3(int i) { ga3[i & 3] = r3(); }
void st_uv_3(int a) { g31 = r3(); gi3 = a + 1; }
void st_gg_4(void) { g41 = g42; }
void st_gl_4(void) { struct s4 t = g42; t.a = 5; g41 = t; }
void st_lg_4(void) { struct s4 t; t = g42; v0(); g41 = t; }
void st_pp_4(struct s4 *d, struct s4 *q) { *d = *q; }
void st_pi_4(struct s4 *d, struct s4 *q, int i) { d[i & 3] = *q; }
void st_gp_4(void) { *gp41 = *gp42; }
void st_ae_4(int i) { ga4[i & 3] = ga4[(i & 3) ^ 1]; }
void st_ag_4(void) { ga4[gi1 & 3] = g42; }
void st_mb_4(void) { gw4.m = g42; }
void st_bm_4(void) { g41 = gw4.m; }
void st_mw_4(int i) { gwa4[i & 1].m = gwa4[(i & 1) ^ 1].m; }
void st_ar_4(void) { gpw4->m = g42; }
void st_ch_4(void) { g41 = g42 = g43; }
void st_lo_4(int n) { int i; for (i = 0; i < (n & 3); i++) ga4[i] = g42; }
void st_if_4(int c) { if (c) g41 = g42; else g41 = g43; }
void st_tc_4(int c) { g41 = c ? g42 : g43; }
void st_tp_4(int c) { g41 = *(c ? gp41 : gp42); }
void st_la_4(void) { struct s4 l[2]; l[0] = g42; l[1] = l[0]; g41 = l[1]; }
int st_cx_4(int a, int b) { g41 = g42; return a + b; }
long st_cy_4(long a, long b, long c) { *gp41 = *gp42; return a - b + c; }
char st_cc_4(char a, int b) { ga4[b & 3] = g42; return a; }
int st_cl_4(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga4[i & 3] = g42; t += i; } return t; }
int st_cp_4(struct s4 *d, int a) { *d = g42; return a * 3; }
void st_pa_4(void) { x4(g42); }
void st_pb_4(int a) { y4(a, g42, a + 1); }
void st_pc_4(void) { z4(gl1, g42, gd1); }
void st_pd_4(struct s4 *p) { x4(*p); }
void st_pe_4(int i) { x4(ga4[i & 3]); }
void st_pr_4(struct s4 q) { g41 = q; }
void st_pq_4(int a, struct s4 q, int b) { g41 = q; gi3 = a - b; }
int st_pf_4(struct s4 q) { return q.a; }
void st_pm_4(struct s4 q) { q.a = 7; g41 = q; }
struct s4 __cdecl st_rt_4(void) { return g42; }
struct s4 __cdecl st_rp_4(struct s4 *p) { return *p; }
struct s4 __cdecl st_rl_4(void) { struct s4 t; t = g42; t.a = 9; return t; }
struct s4 __cdecl st_rq_4(struct s4 q) { return q; }
struct s4 __cdecl st_ri_4(int i) { return ga4[i & 3]; }
struct s4 __cdecl st_rc_4(int c) { if (c) return g42; return g43; }
void st_ug_4(void) { g41 = r4(); }
void st_ul_4(void) { struct s4 t; t = r4(); g41 = t; }
void st_um_4(void) { gw4.m = r4(); }
void st_up_4(void) { *gp41 = r4(); }
void st_ud_4(void) { r4(); }
void st_ux_4(void) { x4(r4()); }
void st_ua_4(int i) { ga4[i & 3] = r4(); }
void st_uv_4(int a) { g41 = r4(); gi3 = a + 1; }
void st_gg_5(void) { g51 = g52; }
void st_gl_5(void) { struct s5 t = g52; t.a = 5; g51 = t; }
void st_lg_5(void) { struct s5 t; t = g52; v0(); g51 = t; }
void st_pp_5(struct s5 *d, struct s5 *q) { *d = *q; }
void st_pi_5(struct s5 *d, struct s5 *q, int i) { d[i & 3] = *q; }
void st_gp_5(void) { *gp51 = *gp52; }
void st_ae_5(int i) { ga5[i & 3] = ga5[(i & 3) ^ 1]; }
void st_ag_5(void) { ga5[gi1 & 3] = g52; }
void st_mb_5(void) { gw5.m = g52; }
void st_bm_5(void) { g51 = gw5.m; }
void st_mw_5(int i) { gwa5[i & 1].m = gwa5[(i & 1) ^ 1].m; }
void st_ar_5(void) { gpw5->m = g52; }
void st_ch_5(void) { g51 = g52 = g53; }
void st_lo_5(int n) { int i; for (i = 0; i < (n & 3); i++) ga5[i] = g52; }
void st_if_5(int c) { if (c) g51 = g52; else g51 = g53; }
void st_tc_5(int c) { g51 = c ? g52 : g53; }
void st_tp_5(int c) { g51 = *(c ? gp51 : gp52); }
void st_la_5(void) { struct s5 l[2]; l[0] = g52; l[1] = l[0]; g51 = l[1]; }
int st_cx_5(int a, int b) { g51 = g52; return a + b; }
long st_cy_5(long a, long b, long c) { *gp51 = *gp52; return a - b + c; }
char st_cc_5(char a, int b) { ga5[b & 3] = g52; return a; }
int st_cl_5(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga5[i & 3] = g52; t += i; } return t; }
int st_cp_5(struct s5 *d, int a) { *d = g52; return a * 3; }
void st_pa_5(void) { x5(g52); }
void st_pb_5(int a) { y5(a, g52, a + 1); }
void st_pc_5(void) { z5(gl1, g52, gd1); }
void st_pd_5(struct s5 *p) { x5(*p); }
void st_pe_5(int i) { x5(ga5[i & 3]); }
void st_pr_5(struct s5 q) { g51 = q; }
void st_pq_5(int a, struct s5 q, int b) { g51 = q; gi3 = a - b; }
char st_pf_5(struct s5 q) { return q.a; }
void st_pm_5(struct s5 q) { q.a = 7; g51 = q; }
struct s5 __cdecl st_rt_5(void) { return g52; }
struct s5 __cdecl st_rp_5(struct s5 *p) { return *p; }
struct s5 __cdecl st_rl_5(void) { struct s5 t; t = g52; t.a = 9; return t; }
struct s5 __cdecl st_rq_5(struct s5 q) { return q; }
struct s5 __cdecl st_ri_5(int i) { return ga5[i & 3]; }
struct s5 __cdecl st_rc_5(int c) { if (c) return g52; return g53; }
void st_ug_5(void) { g51 = r5(); }
void st_ul_5(void) { struct s5 t; t = r5(); g51 = t; }
void st_um_5(void) { gw5.m = r5(); }
void st_up_5(void) { *gp51 = r5(); }
void st_ud_5(void) { r5(); }
void st_ux_5(void) { x5(r5()); }
void st_ua_5(int i) { ga5[i & 3] = r5(); }
void st_uv_5(int a) { g51 = r5(); gi3 = a + 1; }
void st_gg_6(void) { g61 = g62; }
void st_gl_6(void) { struct s6 t = g62; t.a = 5; g61 = t; }
void st_lg_6(void) { struct s6 t; t = g62; v0(); g61 = t; }
void st_pp_6(struct s6 *d, struct s6 *q) { *d = *q; }
void st_pi_6(struct s6 *d, struct s6 *q, int i) { d[i & 3] = *q; }
void st_gp_6(void) { *gp61 = *gp62; }
void st_ae_6(int i) { ga6[i & 3] = ga6[(i & 3) ^ 1]; }
void st_ag_6(void) { ga6[gi1 & 3] = g62; }
void st_mb_6(void) { gw6.m = g62; }
void st_bm_6(void) { g61 = gw6.m; }
void st_mw_6(int i) { gwa6[i & 1].m = gwa6[(i & 1) ^ 1].m; }
void st_ar_6(void) { gpw6->m = g62; }
void st_ch_6(void) { g61 = g62 = g63; }
void st_lo_6(int n) { int i; for (i = 0; i < (n & 3); i++) ga6[i] = g62; }
void st_if_6(int c) { if (c) g61 = g62; else g61 = g63; }
void st_tc_6(int c) { g61 = c ? g62 : g63; }
void st_tp_6(int c) { g61 = *(c ? gp61 : gp62); }
void st_la_6(void) { struct s6 l[2]; l[0] = g62; l[1] = l[0]; g61 = l[1]; }
int st_cx_6(int a, int b) { g61 = g62; return a + b; }
long st_cy_6(long a, long b, long c) { *gp61 = *gp62; return a - b + c; }
char st_cc_6(char a, int b) { ga6[b & 3] = g62; return a; }
int st_cl_6(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga6[i & 3] = g62; t += i; } return t; }
int st_cp_6(struct s6 *d, int a) { *d = g62; return a * 3; }
void st_pa_6(void) { x6(g62); }
void st_pb_6(int a) { y6(a, g62, a + 1); }
void st_pc_6(void) { z6(gl1, g62, gd1); }
void st_pd_6(struct s6 *p) { x6(*p); }
void st_pe_6(int i) { x6(ga6[i & 3]); }
void st_pr_6(struct s6 q) { g61 = q; }
void st_pq_6(int a, struct s6 q, int b) { g61 = q; gi3 = a - b; }
int st_pf_6(struct s6 q) { return q.a; }
void st_pm_6(struct s6 q) { q.a = 7; g61 = q; }
struct s6 __cdecl st_rt_6(void) { return g62; }
struct s6 __cdecl st_rp_6(struct s6 *p) { return *p; }
struct s6 __cdecl st_rl_6(void) { struct s6 t; t = g62; t.a = 9; return t; }
struct s6 __cdecl st_rq_6(struct s6 q) { return q; }
struct s6 __cdecl st_ri_6(int i) { return ga6[i & 3]; }
struct s6 __cdecl st_rc_6(int c) { if (c) return g62; return g63; }
void st_ug_6(void) { g61 = r6(); }
void st_ul_6(void) { struct s6 t; t = r6(); g61 = t; }
void st_um_6(void) { gw6.m = r6(); }
void st_up_6(void) { *gp61 = r6(); }
void st_ud_6(void) { r6(); }
void st_ux_6(void) { x6(r6()); }
void st_ua_6(int i) { ga6[i & 3] = r6(); }
void st_uv_6(int a) { g61 = r6(); gi3 = a + 1; }
void st_gg_8(void) { g81 = g82; }
void st_gl_8(void) { struct s8 t = g82; t.a = 5; g81 = t; }
void st_lg_8(void) { struct s8 t; t = g82; v0(); g81 = t; }
void st_pp_8(struct s8 *d, struct s8 *q) { *d = *q; }
void st_pi_8(struct s8 *d, struct s8 *q, int i) { d[i & 3] = *q; }
void st_gp_8(void) { *gp81 = *gp82; }
void st_ae_8(int i) { ga8[i & 3] = ga8[(i & 3) ^ 1]; }
void st_ag_8(void) { ga8[gi1 & 3] = g82; }
void st_mb_8(void) { gw8.m = g82; }
void st_bm_8(void) { g81 = gw8.m; }
void st_mw_8(int i) { gwa8[i & 1].m = gwa8[(i & 1) ^ 1].m; }
void st_ar_8(void) { gpw8->m = g82; }
void st_ch_8(void) { g81 = g82 = g83; }
void st_lo_8(int n) { int i; for (i = 0; i < (n & 3); i++) ga8[i] = g82; }
void st_if_8(int c) { if (c) g81 = g82; else g81 = g83; }
void st_tc_8(int c) { g81 = c ? g82 : g83; }
void st_tp_8(int c) { g81 = *(c ? gp81 : gp82); }
void st_la_8(void) { struct s8 l[2]; l[0] = g82; l[1] = l[0]; g81 = l[1]; }
int st_cx_8(int a, int b) { g81 = g82; return a + b; }
long st_cy_8(long a, long b, long c) { *gp81 = *gp82; return a - b + c; }
char st_cc_8(char a, int b) { ga8[b & 3] = g82; return a; }
int st_cl_8(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { ga8[i & 3] = g82; t += i; } return t; }
int st_cp_8(struct s8 *d, int a) { *d = g82; return a * 3; }
void st_pa_8(void) { x8(g82); }
void st_pb_8(int a) { y8(a, g82, a + 1); }
void st_pc_8(void) { z8(gl1, g82, gd1); }
void st_pd_8(struct s8 *p) { x8(*p); }
void st_pe_8(int i) { x8(ga8[i & 3]); }
void st_pr_8(struct s8 q) { g81 = q; }
void st_pq_8(int a, struct s8 q, int b) { g81 = q; gi3 = a - b; }
long st_pf_8(struct s8 q) { return q.a; }
void st_pm_8(struct s8 q) { q.a = 7; g81 = q; }
struct s8 __cdecl st_rt_8(void) { return g82; }
struct s8 __cdecl st_rp_8(struct s8 *p) { return *p; }
struct s8 __cdecl st_rl_8(void) { struct s8 t; t = g82; t.a = 9; return t; }
struct s8 __cdecl st_rq_8(struct s8 q) { return q; }
struct s8 __cdecl st_ri_8(int i) { return ga8[i & 3]; }
struct s8 __cdecl st_rc_8(int c) { if (c) return g82; return g83; }
void st_ug_8(void) { g81 = r8(); }
void st_ul_8(void) { struct s8 t; t = r8(); g81 = t; }
void st_um_8(void) { gw8.m = r8(); }
void st_up_8(void) { *gp81 = r8(); }
void st_ud_8(void) { r8(); }
void st_ux_8(void) { x8(r8()); }
void st_ua_8(int i) { ga8[i & 3] = r8(); }
void st_uv_8(int a) { g81 = r8(); gi3 = a + 1; }
void st_gg_C(void) { gC1 = gC2; }
void st_gl_C(void) { struct sC t = gC2; t.a = 5; gC1 = t; }
void st_lg_C(void) { struct sC t; t = gC2; v0(); gC1 = t; }
void st_pp_C(struct sC *d, struct sC *q) { *d = *q; }
void st_pi_C(struct sC *d, struct sC *q, int i) { d[i & 3] = *q; }
void st_gp_C(void) { *gpC1 = *gpC2; }
void st_ae_C(int i) { gaC[i & 3] = gaC[(i & 3) ^ 1]; }
void st_ag_C(void) { gaC[gi1 & 3] = gC2; }
void st_mb_C(void) { gwC.m = gC2; }
void st_bm_C(void) { gC1 = gwC.m; }
void st_mw_C(int i) { gwaC[i & 1].m = gwaC[(i & 1) ^ 1].m; }
void st_ar_C(void) { gpwC->m = gC2; }
void st_ch_C(void) { gC1 = gC2 = gC3; }
void st_lo_C(int n) { int i; for (i = 0; i < (n & 3); i++) gaC[i] = gC2; }
void st_if_C(int c) { if (c) gC1 = gC2; else gC1 = gC3; }
void st_tc_C(int c) { gC1 = c ? gC2 : gC3; }
void st_tp_C(int c) { gC1 = *(c ? gpC1 : gpC2); }
void st_la_C(void) { struct sC l[2]; l[0] = gC2; l[1] = l[0]; gC1 = l[1]; }
int st_cx_C(int a, int b) { gC1 = gC2; return a + b; }
long st_cy_C(long a, long b, long c) { *gpC1 = *gpC2; return a - b + c; }
char st_cc_C(char a, int b) { gaC[b & 3] = gC2; return a; }
int st_cl_C(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { gaC[i & 3] = gC2; t += i; } return t; }
int st_cp_C(struct sC *d, int a) { *d = gC2; return a * 3; }
void st_pa_C(void) { xC(gC2); }
void st_pb_C(int a) { yC(a, gC2, a + 1); }
void st_pc_C(void) { zC(gl1, gC2, gd1); }
void st_pd_C(struct sC *p) { xC(*p); }
void st_pe_C(int i) { xC(gaC[i & 3]); }
void st_pr_C(struct sC q) { gC1 = q; }
void st_pq_C(int a, struct sC q, int b) { gC1 = q; gi3 = a - b; }
long st_pf_C(struct sC q) { return q.a; }
void st_pm_C(struct sC q) { q.a = 7; gC1 = q; }
struct sC __cdecl st_rt_C(void) { return gC2; }
struct sC __cdecl st_rp_C(struct sC *p) { return *p; }
struct sC __cdecl st_rl_C(void) { struct sC t; t = gC2; t.a = 9; return t; }
struct sC __cdecl st_rq_C(struct sC q) { return q; }
struct sC __cdecl st_ri_C(int i) { return gaC[i & 3]; }
struct sC __cdecl st_rc_C(int c) { if (c) return gC2; return gC3; }
void st_ug_C(void) { gC1 = rC(); }
void st_ul_C(void) { struct sC t; t = rC(); gC1 = t; }
void st_um_C(void) { gwC.m = rC(); }
void st_up_C(void) { *gpC1 = rC(); }
void st_ud_C(void) { rC(); }
void st_ux_C(void) { xC(rC()); }
void st_ua_C(int i) { gaC[i & 3] = rC(); }
void st_uv_C(int a) { gC1 = rC(); gi3 = a + 1; }
void st_gg_G(void) { gG1 = gG2; }
void st_gl_G(void) { struct sG t = gG2; t.a = 5; gG1 = t; }
void st_lg_G(void) { struct sG t; t = gG2; v0(); gG1 = t; }
void st_pp_G(struct sG *d, struct sG *q) { *d = *q; }
void st_pi_G(struct sG *d, struct sG *q, int i) { d[i & 3] = *q; }
void st_gp_G(void) { *gpG1 = *gpG2; }
void st_ae_G(int i) { gaG[i & 3] = gaG[(i & 3) ^ 1]; }
void st_ag_G(void) { gaG[gi1 & 3] = gG2; }
void st_mb_G(void) { gwG.m = gG2; }
void st_bm_G(void) { gG1 = gwG.m; }
void st_mw_G(int i) { gwaG[i & 1].m = gwaG[(i & 1) ^ 1].m; }
void st_ar_G(void) { gpwG->m = gG2; }
void st_ch_G(void) { gG1 = gG2 = gG3; }
void st_lo_G(int n) { int i; for (i = 0; i < (n & 3); i++) gaG[i] = gG2; }
void st_if_G(int c) { if (c) gG1 = gG2; else gG1 = gG3; }
void st_tc_G(int c) { gG1 = c ? gG2 : gG3; }
void st_tp_G(int c) { gG1 = *(c ? gpG1 : gpG2); }
void st_la_G(void) { struct sG l[2]; l[0] = gG2; l[1] = l[0]; gG1 = l[1]; }
int st_cx_G(int a, int b) { gG1 = gG2; return a + b; }
long st_cy_G(long a, long b, long c) { *gpG1 = *gpG2; return a - b + c; }
char st_cc_G(char a, int b) { gaG[b & 3] = gG2; return a; }
int st_cl_G(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { gaG[i & 3] = gG2; t += i; } return t; }
int st_cp_G(struct sG *d, int a) { *d = gG2; return a * 3; }
void st_pa_G(void) { xG(gG2); }
void st_pb_G(int a) { yG(a, gG2, a + 1); }
void st_pc_G(void) { zG(gl1, gG2, gd1); }
void st_pd_G(struct sG *p) { xG(*p); }
void st_pe_G(int i) { xG(gaG[i & 3]); }
void st_pr_G(struct sG q) { gG1 = q; }
void st_pq_G(int a, struct sG q, int b) { gG1 = q; gi3 = a - b; }
long st_pf_G(struct sG q) { return q.a; }
void st_pm_G(struct sG q) { q.a = 7; gG1 = q; }
struct sG __cdecl st_rt_G(void) { return gG2; }
struct sG __cdecl st_rp_G(struct sG *p) { return *p; }
struct sG __cdecl st_rl_G(void) { struct sG t; t = gG2; t.a = 9; return t; }
struct sG __cdecl st_rq_G(struct sG q) { return q; }
struct sG __cdecl st_ri_G(int i) { return gaG[i & 3]; }
struct sG __cdecl st_rc_G(int c) { if (c) return gG2; return gG3; }
void st_ug_G(void) { gG1 = rG(); }
void st_ul_G(void) { struct sG t; t = rG(); gG1 = t; }
void st_um_G(void) { gwG.m = rG(); }
void st_up_G(void) { *gpG1 = rG(); }
void st_ud_G(void) { rG(); }
void st_ux_G(void) { xG(rG()); }
void st_ua_G(int i) { gaG[i & 3] = rG(); }
void st_uv_G(int a) { gG1 = rG(); gi3 = a + 1; }
void st_gg_X(void) { gX1 = gX2; }
void st_gl_X(void) { struct sX t = gX2; t.c[0] = 5; gX1 = t; }
void st_lg_X(void) { struct sX t; t = gX2; v0(); gX1 = t; }
void st_pp_X(struct sX *d, struct sX *q) { *d = *q; }
void st_pi_X(struct sX *d, struct sX *q, int i) { d[i & 3] = *q; }
void st_gp_X(void) { *gpX1 = *gpX2; }
void st_ae_X(int i) { gaX[i & 3] = gaX[(i & 3) ^ 1]; }
void st_ag_X(void) { gaX[gi1 & 3] = gX2; }
void st_mb_X(void) { gwX.m = gX2; }
void st_bm_X(void) { gX1 = gwX.m; }
void st_mw_X(int i) { gwaX[i & 1].m = gwaX[(i & 1) ^ 1].m; }
void st_ar_X(void) { gpwX->m = gX2; }
void st_ch_X(void) { gX1 = gX2 = gX3; }
void st_lo_X(int n) { int i; for (i = 0; i < (n & 3); i++) gaX[i] = gX2; }
void st_if_X(int c) { if (c) gX1 = gX2; else gX1 = gX3; }
void st_tc_X(int c) { gX1 = c ? gX2 : gX3; }
void st_tp_X(int c) { gX1 = *(c ? gpX1 : gpX2); }
void st_la_X(void) { struct sX l[2]; l[0] = gX2; l[1] = l[0]; gX1 = l[1]; }
int st_cx_X(int a, int b) { gX1 = gX2; return a + b; }
long st_cy_X(long a, long b, long c) { *gpX1 = *gpX2; return a - b + c; }
char st_cc_X(char a, int b) { gaX[b & 3] = gX2; return a; }
int st_cl_X(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { gaX[i & 3] = gX2; t += i; } return t; }
int st_cp_X(struct sX *d, int a) { *d = gX2; return a * 3; }
void st_pa_X(void) { xX(gX2); }
void st_pb_X(int a) { yX(a, gX2, a + 1); }
void st_pc_X(void) { zX(gl1, gX2, gd1); }
void st_pd_X(struct sX *p) { xX(*p); }
void st_pe_X(int i) { xX(gaX[i & 3]); }
void st_pr_X(struct sX q) { gX1 = q; }
void st_pq_X(int a, struct sX q, int b) { gX1 = q; gi3 = a - b; }
char st_pf_X(struct sX q) { return q.c[0]; }
void st_pm_X(struct sX q) { q.c[0] = 7; gX1 = q; }
struct sX __cdecl st_rt_X(void) { return gX2; }
struct sX __cdecl st_rp_X(struct sX *p) { return *p; }
struct sX __cdecl st_rl_X(void) { struct sX t; t = gX2; t.c[0] = 9; return t; }
struct sX __cdecl st_rq_X(struct sX q) { return q; }
struct sX __cdecl st_ri_X(int i) { return gaX[i & 3]; }
struct sX __cdecl st_rc_X(int c) { if (c) return gX2; return gX3; }
void st_ug_X(void) { gX1 = rX(); }
void st_ul_X(void) { struct sX t; t = rX(); gX1 = t; }
void st_um_X(void) { gwX.m = rX(); }
void st_up_X(void) { *gpX1 = rX(); }
void st_ud_X(void) { rX(); }
void st_ux_X(void) { xX(rX()); }
void st_ua_X(int i) { gaX[i & 3] = rX(); }
void st_uv_X(int a) { gX1 = rX(); gi3 = a + 1; }
void st_gg_N(void) { gN1 = gN2; }
void st_gl_N(void) { struct sN t = gN2; t.h.a = 5; gN1 = t; }
void st_lg_N(void) { struct sN t; t = gN2; v0(); gN1 = t; }
void st_pp_N(struct sN *d, struct sN *q) { *d = *q; }
void st_pi_N(struct sN *d, struct sN *q, int i) { d[i & 3] = *q; }
void st_gp_N(void) { *gpN1 = *gpN2; }
void st_ae_N(int i) { gaN[i & 3] = gaN[(i & 3) ^ 1]; }
void st_ag_N(void) { gaN[gi1 & 3] = gN2; }
void st_mb_N(void) { gwN.m = gN2; }
void st_bm_N(void) { gN1 = gwN.m; }
void st_mw_N(int i) { gwaN[i & 1].m = gwaN[(i & 1) ^ 1].m; }
void st_ar_N(void) { gpwN->m = gN2; }
void st_ch_N(void) { gN1 = gN2 = gN3; }
void st_lo_N(int n) { int i; for (i = 0; i < (n & 3); i++) gaN[i] = gN2; }
void st_if_N(int c) { if (c) gN1 = gN2; else gN1 = gN3; }
void st_tc_N(int c) { gN1 = c ? gN2 : gN3; }
void st_tp_N(int c) { gN1 = *(c ? gpN1 : gpN2); }
void st_la_N(void) { struct sN l[2]; l[0] = gN2; l[1] = l[0]; gN1 = l[1]; }
int st_cx_N(int a, int b) { gN1 = gN2; return a + b; }
long st_cy_N(long a, long b, long c) { *gpN1 = *gpN2; return a - b + c; }
char st_cc_N(char a, int b) { gaN[b & 3] = gN2; return a; }
int st_cl_N(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { gaN[i & 3] = gN2; t += i; } return t; }
int st_cp_N(struct sN *d, int a) { *d = gN2; return a * 3; }
void st_pa_N(void) { xN(gN2); }
void st_pb_N(int a) { yN(a, gN2, a + 1); }
void st_pc_N(void) { zN(gl1, gN2, gd1); }
void st_pd_N(struct sN *p) { xN(*p); }
void st_pe_N(int i) { xN(gaN[i & 3]); }
void st_pr_N(struct sN q) { gN1 = q; }
void st_pq_N(int a, struct sN q, int b) { gN1 = q; gi3 = a - b; }
int st_pf_N(struct sN q) { return q.h.a; }
void st_pm_N(struct sN q) { q.h.a = 7; gN1 = q; }
struct sN __cdecl st_rt_N(void) { return gN2; }
struct sN __cdecl st_rp_N(struct sN *p) { return *p; }
struct sN __cdecl st_rl_N(void) { struct sN t; t = gN2; t.h.a = 9; return t; }
struct sN __cdecl st_rq_N(struct sN q) { return q; }
struct sN __cdecl st_ri_N(int i) { return gaN[i & 3]; }
struct sN __cdecl st_rc_N(int c) { if (c) return gN2; return gN3; }
void st_ug_N(void) { gN1 = rN(); }
void st_ul_N(void) { struct sN t; t = rN(); gN1 = t; }
void st_um_N(void) { gwN.m = rN(); }
void st_up_N(void) { *gpN1 = rN(); }
void st_ud_N(void) { rN(); }
void st_ux_N(void) { xN(rN()); }
void st_ua_N(int i) { gaN[i & 3] = rN(); }
void st_uv_N(int a) { gN1 = rN(); gi3 = a + 1; }
void st_gg_A(void) { gA1 = gA2; }
void st_gl_A(void) { struct sA t = gA2; t.v[0] = 5; gA1 = t; }
void st_lg_A(void) { struct sA t; t = gA2; v0(); gA1 = t; }
void st_pp_A(struct sA *d, struct sA *q) { *d = *q; }
void st_pi_A(struct sA *d, struct sA *q, int i) { d[i & 3] = *q; }
void st_gp_A(void) { *gpA1 = *gpA2; }
void st_ae_A(int i) { gaA[i & 3] = gaA[(i & 3) ^ 1]; }
void st_ag_A(void) { gaA[gi1 & 3] = gA2; }
void st_mb_A(void) { gwA.m = gA2; }
void st_bm_A(void) { gA1 = gwA.m; }
void st_mw_A(int i) { gwaA[i & 1].m = gwaA[(i & 1) ^ 1].m; }
void st_ar_A(void) { gpwA->m = gA2; }
void st_ch_A(void) { gA1 = gA2 = gA3; }
void st_lo_A(int n) { int i; for (i = 0; i < (n & 3); i++) gaA[i] = gA2; }
void st_if_A(int c) { if (c) gA1 = gA2; else gA1 = gA3; }
void st_tc_A(int c) { gA1 = c ? gA2 : gA3; }
void st_tp_A(int c) { gA1 = *(c ? gpA1 : gpA2); }
void st_la_A(void) { struct sA l[2]; l[0] = gA2; l[1] = l[0]; gA1 = l[1]; }
int st_cx_A(int a, int b) { gA1 = gA2; return a + b; }
long st_cy_A(long a, long b, long c) { *gpA1 = *gpA2; return a - b + c; }
char st_cc_A(char a, int b) { gaA[b & 3] = gA2; return a; }
int st_cl_A(int n) { int i, t = 0; for (i = 0; i < (n & 7); i++) { gaA[i & 3] = gA2; t += i; } return t; }
int st_cp_A(struct sA *d, int a) { *d = gA2; return a * 3; }
void st_pa_A(void) { xA(gA2); }
void st_pb_A(int a) { yA(a, gA2, a + 1); }
void st_pc_A(void) { zA(gl1, gA2, gd1); }
void st_pd_A(struct sA *p) { xA(*p); }
void st_pe_A(int i) { xA(gaA[i & 3]); }
void st_pr_A(struct sA q) { gA1 = q; }
void st_pq_A(int a, struct sA q, int b) { gA1 = q; gi3 = a - b; }
int st_pf_A(struct sA q) { return q.v[0]; }
void st_pm_A(struct sA q) { q.v[0] = 7; gA1 = q; }
struct sA __cdecl st_rt_A(void) { return gA2; }
struct sA __cdecl st_rp_A(struct sA *p) { return *p; }
struct sA __cdecl st_rl_A(void) { struct sA t; t = gA2; t.v[0] = 9; return t; }
struct sA __cdecl st_rq_A(struct sA q) { return q; }
struct sA __cdecl st_ri_A(int i) { return gaA[i & 3]; }
struct sA __cdecl st_rc_A(int c) { if (c) return gA2; return gA3; }
void st_ug_A(void) { gA1 = rA(); }
void st_ul_A(void) { struct sA t; t = rA(); gA1 = t; }
void st_um_A(void) { gwA.m = rA(); }
void st_up_A(void) { *gpA1 = rA(); }
void st_ud_A(void) { rA(); }
void st_ux_A(void) { xA(rA()); }
void st_ua_A(int i) { gaA[i & 3] = rA(); }
void st_uv_A(int a) { gA1 = rA(); gi3 = a + 1; }
