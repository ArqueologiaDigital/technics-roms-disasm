/* lane_o3 wrong-code probe: floating point; see gen_fpw.py for the name letters */
extern double gd1, gd2, gd3, gda[8], *gdp; extern float gf1, gf2, gf3, gfa[8], *gfp;
struct sv { char c; double d; int i; float f; double d2; float f2; };
extern struct sv gs, *gps;
extern double __cdecl rd(void); extern float __cdecl rf(void); extern void vd(double); extern void vf(float); extern void v0(void);
extern char gc1, gc3;
extern unsigned char gb1, gb3;
extern int gi1, gi3;
extern unsigned int gu1, gu3;
extern long gl1, gl3;
extern unsigned long gn1, gn3;
void fp_ar_daG(void) { gd3 = gd1 + gd2; }
void fp_ar_daP(double a, double b) { gd3 = a + gd2; }
void fp_ar_daQ(double a, double b) { gd3 = a + b; }
void fp_ar_daK(void) { gd3 = gd1 + 1.5; }
void fp_ar_daC(void) { gd3 = 2.25 + gd1; }
void fp_ar_daA(void) { gd3 = gda[2] + gd1; }
void fp_ar_daS(void) { gd3 = gs.d + gd1; }
void fp_ar_daR(void) { gd3 = rd() + gd1; }
void fp_ar_dsG(void) { gd3 = gd1 - gd2; }
void fp_ar_dsP(double a, double b) { gd3 = a - gd2; }
void fp_ar_dsQ(double a, double b) { gd3 = a - b; }
void fp_ar_dsK(void) { gd3 = gd1 - 1.5; }
void fp_ar_dsC(void) { gd3 = 2.25 - gd1; }
void fp_ar_dsA(void) { gd3 = gda[2] - gd1; }
void fp_ar_dsS(void) { gd3 = gs.d - gd1; }
void fp_ar_dsR(void) { gd3 = rd() - gd1; }
void fp_ar_dmG(void) { gd3 = gd1 * gd2; }
void fp_ar_dmP(double a, double b) { gd3 = a * gd2; }
void fp_ar_dmQ(double a, double b) { gd3 = a * b; }
void fp_ar_dmK(void) { gd3 = gd1 * 1.5; }
void fp_ar_dmC(void) { gd3 = 2.25 * gd1; }
void fp_ar_dmA(void) { gd3 = gda[2] * gd1; }
void fp_ar_dmS(void) { gd3 = gs.d * gd1; }
void fp_ar_dmR(void) { gd3 = rd() * gd1; }
void fp_ar_ddG(void) { gd3 = gd1 / (gd2 * gd2 + 3.0); }
void fp_ar_ddP(double a, double b) { gd3 = a / (gd2 * gd2 + 3.0); }
void fp_ar_ddQ(double a, double b) { gd3 = a / (b * b + 3.0); }
void fp_ar_ddK(void) { gd3 = gd1 / 1.5; }
void fp_ar_ddC(void) { gd3 = 2.25 / (gd1 * gd1 + 3.0); }
void fp_ar_ddA(void) { gd3 = gda[2] / (gd1 * gd1 + 3.0); }
void fp_ar_ddS(void) { gd3 = gs.d / (gd1 * gd1 + 3.0); }
void fp_ar_ddR(void) { gd3 = rd() / (gd1 * gd1 + 3.0); }
void fp_ng_dG(void) { gd3 = -gd1; }
void fp_ng_dP(double a, double b) { gd3 = -a; }
void fp_ng_dA(void) { gd3 = -gda[3]; }
void fp_ng_dS(void) { gd3 = -gs.d; }
void fp_cm_deGT(void) { gd3 = (gd1 == gd2 ? gd1 : gd2); }
void fp_cm_deGI(void) { if (gd1 == gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_deGR(void) { return (gd1 == gd2 ? 1 : 2); }
int fp_cm_deGB(void) { return gd1 == gd2; }
void fp_cm_deKT(void) { gd3 = (gd1 == 1.5 ? gd1 : 1.5); }
void fp_cm_deKI(void) { if (gd1 == 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_deKR(void) { return (gd1 == 1.5 ? 1 : 2); }
int fp_cm_deKB(void) { return gd1 == 1.5; }
void fp_cm_dePT(double a, double b) { gd3 = (a == gd2 ? a : gd2); }
void fp_cm_dePI(double a, double b) { if (a == gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dePR(double a, double b) { return (a == gd2 ? 1 : 2); }
int fp_cm_dePB(double a, double b) { return a == gd2; }
void fp_cm_deAT(void) { gd3 = (gda[1] == gd1 ? gda[1] : gd1); }
void fp_cm_deAI(void) { if (gda[1] == gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_deAR(void) { return (gda[1] == gd1 ? 1 : 2); }
int fp_cm_deAB(void) { return gda[1] == gd1; }
void fp_cm_dnGT(void) { gd3 = (gd1 != gd2 ? gd1 : gd2); }
void fp_cm_dnGI(void) { if (gd1 != gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dnGR(void) { return (gd1 != gd2 ? 1 : 2); }
int fp_cm_dnGB(void) { return gd1 != gd2; }
void fp_cm_dnKT(void) { gd3 = (gd1 != 1.5 ? gd1 : 1.5); }
void fp_cm_dnKI(void) { if (gd1 != 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dnKR(void) { return (gd1 != 1.5 ? 1 : 2); }
int fp_cm_dnKB(void) { return gd1 != 1.5; }
void fp_cm_dnPT(double a, double b) { gd3 = (a != gd2 ? a : gd2); }
void fp_cm_dnPI(double a, double b) { if (a != gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dnPR(double a, double b) { return (a != gd2 ? 1 : 2); }
int fp_cm_dnPB(double a, double b) { return a != gd2; }
void fp_cm_dnAT(void) { gd3 = (gda[1] != gd1 ? gda[1] : gd1); }
void fp_cm_dnAI(void) { if (gda[1] != gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_dnAR(void) { return (gda[1] != gd1 ? 1 : 2); }
int fp_cm_dnAB(void) { return gda[1] != gd1; }
void fp_cm_dlGT(void) { gd3 = (gd1 < gd2 ? gd1 : gd2); }
void fp_cm_dlGI(void) { if (gd1 < gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dlGR(void) { return (gd1 < gd2 ? 1 : 2); }
int fp_cm_dlGB(void) { return gd1 < gd2; }
void fp_cm_dlKT(void) { gd3 = (gd1 < 1.5 ? gd1 : 1.5); }
void fp_cm_dlKI(void) { if (gd1 < 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dlKR(void) { return (gd1 < 1.5 ? 1 : 2); }
int fp_cm_dlKB(void) { return gd1 < 1.5; }
void fp_cm_dlPT(double a, double b) { gd3 = (a < gd2 ? a : gd2); }
void fp_cm_dlPI(double a, double b) { if (a < gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dlPR(double a, double b) { return (a < gd2 ? 1 : 2); }
int fp_cm_dlPB(double a, double b) { return a < gd2; }
void fp_cm_dlAT(void) { gd3 = (gda[1] < gd1 ? gda[1] : gd1); }
void fp_cm_dlAI(void) { if (gda[1] < gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_dlAR(void) { return (gda[1] < gd1 ? 1 : 2); }
int fp_cm_dlAB(void) { return gda[1] < gd1; }
void fp_cm_dgGT(void) { gd3 = (gd1 > gd2 ? gd1 : gd2); }
void fp_cm_dgGI(void) { if (gd1 > gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dgGR(void) { return (gd1 > gd2 ? 1 : 2); }
int fp_cm_dgGB(void) { return gd1 > gd2; }
void fp_cm_dgKT(void) { gd3 = (gd1 > 1.5 ? gd1 : 1.5); }
void fp_cm_dgKI(void) { if (gd1 > 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dgKR(void) { return (gd1 > 1.5 ? 1 : 2); }
int fp_cm_dgKB(void) { return gd1 > 1.5; }
void fp_cm_dgPT(double a, double b) { gd3 = (a > gd2 ? a : gd2); }
void fp_cm_dgPI(double a, double b) { if (a > gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dgPR(double a, double b) { return (a > gd2 ? 1 : 2); }
int fp_cm_dgPB(double a, double b) { return a > gd2; }
void fp_cm_dgAT(void) { gd3 = (gda[1] > gd1 ? gda[1] : gd1); }
void fp_cm_dgAI(void) { if (gda[1] > gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_dgAR(void) { return (gda[1] > gd1 ? 1 : 2); }
int fp_cm_dgAB(void) { return gda[1] > gd1; }
void fp_cm_dLGT(void) { gd3 = (gd1 <= gd2 ? gd1 : gd2); }
void fp_cm_dLGI(void) { if (gd1 <= gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dLGR(void) { return (gd1 <= gd2 ? 1 : 2); }
int fp_cm_dLGB(void) { return gd1 <= gd2; }
void fp_cm_dLKT(void) { gd3 = (gd1 <= 1.5 ? gd1 : 1.5); }
void fp_cm_dLKI(void) { if (gd1 <= 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dLKR(void) { return (gd1 <= 1.5 ? 1 : 2); }
int fp_cm_dLKB(void) { return gd1 <= 1.5; }
void fp_cm_dLPT(double a, double b) { gd3 = (a <= gd2 ? a : gd2); }
void fp_cm_dLPI(double a, double b) { if (a <= gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dLPR(double a, double b) { return (a <= gd2 ? 1 : 2); }
int fp_cm_dLPB(double a, double b) { return a <= gd2; }
void fp_cm_dLAT(void) { gd3 = (gda[1] <= gd1 ? gda[1] : gd1); }
void fp_cm_dLAI(void) { if (gda[1] <= gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_dLAR(void) { return (gda[1] <= gd1 ? 1 : 2); }
int fp_cm_dLAB(void) { return gda[1] <= gd1; }
void fp_cm_dGGT(void) { gd3 = (gd1 >= gd2 ? gd1 : gd2); }
void fp_cm_dGGI(void) { if (gd1 >= gd2) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dGGR(void) { return (gd1 >= gd2 ? 1 : 2); }
int fp_cm_dGGB(void) { return gd1 >= gd2; }
void fp_cm_dGKT(void) { gd3 = (gd1 >= 1.5 ? gd1 : 1.5); }
void fp_cm_dGKI(void) { if (gd1 >= 1.5) gd3 = gd1; else gd3 = 1.0; }
int fp_cm_dGKR(void) { return (gd1 >= 1.5 ? 1 : 2); }
int fp_cm_dGKB(void) { return gd1 >= 1.5; }
void fp_cm_dGPT(double a, double b) { gd3 = (a >= gd2 ? a : gd2); }
void fp_cm_dGPI(double a, double b) { if (a >= gd2) gd3 = a; else gd3 = 1.0; }
int fp_cm_dGPR(double a, double b) { return (a >= gd2 ? 1 : 2); }
int fp_cm_dGPB(double a, double b) { return a >= gd2; }
void fp_cm_dGAT(void) { gd3 = (gda[1] >= gd1 ? gda[1] : gd1); }
void fp_cm_dGAI(void) { if (gda[1] >= gd1) gd3 = gda[1]; else gd3 = 1.0; }
int fp_cm_dGAR(void) { return (gda[1] >= gd1 ? 1 : 2); }
int fp_cm_dGAB(void) { return gda[1] >= gd1; }
void fp_ci_dcF(void) { gc3 = (char)gd1; }
void fp_ci_dcT(void) { gd3 = (double)gc1; }
double __cdecl fp_ci_dcP(char a) { return a; }
char fp_ci_dcQ(double a) { return (char)a; }
void fp_ci_dbF(void) { gb3 = (unsigned char)gd1; }
void fp_ci_dbT(void) { gd3 = (double)gb1; }
double __cdecl fp_ci_dbP(unsigned char a) { return a; }
unsigned char fp_ci_dbQ(double a) { return (unsigned char)a; }
void fp_ci_diF(void) { gi3 = (int)gd1; }
void fp_ci_diT(void) { gd3 = (double)gi1; }
double __cdecl fp_ci_diP(int a) { return a; }
int fp_ci_diQ(double a) { return (int)a; }
void fp_ci_duF(void) { gu3 = (unsigned int)gd1; }
void fp_ci_duT(void) { gd3 = (double)gu1; }
double __cdecl fp_ci_duP(unsigned int a) { return a; }
unsigned int fp_ci_duQ(double a) { return (unsigned int)a; }
void fp_ci_dlF(void) { gl3 = (long)gd1; }
void fp_ci_dlT(void) { gd3 = (double)gl1; }
double __cdecl fp_ci_dlP(long a) { return a; }
long fp_ci_dlQ(double a) { return (long)a; }
void fp_ci_dnF(void) { gn3 = (unsigned long)gd1; }
void fp_ci_dnT(void) { gd3 = (double)gn1; }
double __cdecl fp_ci_dnP(unsigned long a) { return a; }
unsigned long fp_ci_dnQ(double a) { return (unsigned long)a; }
double __cdecl fp_pr_d0(double a, double b) { return a; }
double __cdecl fp_pr_d1(double a, double b) { return a + b; }
double __cdecl fp_pr_d2(double a, double b, double c) { return a * b - c; }
double __cdecl fp_pr_d3(int i, double a) { return a + i; }
double __cdecl fp_pr_d4(double a, int i) { return a * i; }
double __cdecl fp_pr_d5(double a, double b) { gd3 = a; return b; }
double __cdecl fp_pr_d6(double a, double b) { return -a; }
double __cdecl fp_pr_d7(double a, double b) { vd(a); return b; }
void fp_st_d0(void) { gs.d = gda[2] + gs.d; }
void fp_st_d1(int i) { gda[i & 7] = gd1 * 2.0; }
void fp_st_d2(void) { gps->d = gps->d - gd1; }
void fp_st_d3(void) { gs.d = gd1; gs.d2 = gs.d * gd2; }
void fp_st_d4(void) { gda[4] = gda[1] + gda[2]; }
double __cdecl fp_st_d5(double *p) { return p[3] - p[1]; }
void fp_lc_d0(void) { double t = gd1 * gd2; v0(); gd3 = t + gd1; }
double __cdecl fp_lc_d1(double a) { v0(); return a * 2.0; }
void fp_lc_d2(void) { double t = rd(); vd(gd1); gd3 = t - rd(); }
double __cdecl fp_lc_d3(double a) { double t = a + gd1; v0(); return t * a; }
void fp_lc_d4(void) { double t = gd1; int i; for (i = 0; i < 3; i++) { v0(); gda[i] = t; } gd3 = t; }
void fp_lc_d5(void) { int n = gi1; double t = gd2 + 1.0; v0(); gd3 = t * n; }
void fp_tm_d0(void) { gd3 = (gd1 + gd2) * (gd1 - gd2); }
void fp_tm_d1(void) { gd3 = (gd1 + gd2) * (gd1 - gd2) / (gd2 * gd2 + 2.5); }
void fp_tm_d2(void) { gd3 = rd() * (gd1 + rd()); }
void fp_tm_d3(void) { gd3 = ((gd1 * 2.0 + gd2) * (gd2 - 0.5)) + (gd1 * gd1); }
int fp_tm_d4(void) { return (gd1 + gd2) < (gd1 * gd2); }
void fp_tm_d5(void) { gd3 = (gd1 + gi1) * (gd2 - gl1); }
void fp_oa_daG(void) { gd1 += gd2; }
void fp_oa_daL(void) { double t = gd1; t += gd2; gd3 = t; }
void fp_oa_daA(void) { gda[3] += gd2; }
void fp_oa_daS(void) { gs.d += gd2; }
double __cdecl fp_oa_daP(double a, double b) { a += b; return a; }
void fp_oa_dsG(void) { gd1 -= gd2; }
void fp_oa_dsL(void) { double t = gd1; t -= gd2; gd3 = t; }
void fp_oa_dsA(void) { gda[3] -= gd2; }
void fp_oa_dsS(void) { gs.d -= gd2; }
double __cdecl fp_oa_dsP(double a, double b) { a -= b; return a; }
void fp_oa_dmG(void) { gd1 *= gd2; }
void fp_oa_dmL(void) { double t = gd1; t *= gd2; gd3 = t; }
void fp_oa_dmA(void) { gda[3] *= gd2; }
void fp_oa_dmS(void) { gs.d *= gd2; }
double __cdecl fp_oa_dmP(double a, double b) { a *= b; return a; }
void fp_oa_ddG(void) { gd1 /= (gd2 * gd2 + 3.0); }
void fp_oa_ddL(void) { double t = gd1; t /= (gd2 * gd2 + 3.0); gd3 = t; }
void fp_oa_ddA(void) { gda[3] /= (gd2 * gd2 + 3.0); }
void fp_oa_ddS(void) { gs.d /= (gd2 * gd2 + 3.0); }
double __cdecl fp_oa_ddP(double a, double b) { a /= (b * b + 3.0); return a; }
void fp_ar_faG(void) { gf3 = gf1 + gf2; }
void fp_ar_faP(float a, float b) { gf3 = a + gf2; }
void fp_ar_faQ(float a, float b) { gf3 = a + b; }
void fp_ar_faK(void) { gf3 = gf1 + 1.5f; }
void fp_ar_faC(void) { gf3 = 2.25f + gf1; }
void fp_ar_faA(void) { gf3 = gfa[2] + gf1; }
void fp_ar_faS(void) { gf3 = gs.f + gf1; }
void fp_ar_faR(void) { gf3 = rf() + gf1; }
void fp_ar_fsG(void) { gf3 = gf1 - gf2; }
void fp_ar_fsP(float a, float b) { gf3 = a - gf2; }
void fp_ar_fsQ(float a, float b) { gf3 = a - b; }
void fp_ar_fsK(void) { gf3 = gf1 - 1.5f; }
void fp_ar_fsC(void) { gf3 = 2.25f - gf1; }
void fp_ar_fsA(void) { gf3 = gfa[2] - gf1; }
void fp_ar_fsS(void) { gf3 = gs.f - gf1; }
void fp_ar_fsR(void) { gf3 = rf() - gf1; }
void fp_ar_fmG(void) { gf3 = gf1 * gf2; }
void fp_ar_fmP(float a, float b) { gf3 = a * gf2; }
void fp_ar_fmQ(float a, float b) { gf3 = a * b; }
void fp_ar_fmK(void) { gf3 = gf1 * 1.5f; }
void fp_ar_fmC(void) { gf3 = 2.25f * gf1; }
void fp_ar_fmA(void) { gf3 = gfa[2] * gf1; }
void fp_ar_fmS(void) { gf3 = gs.f * gf1; }
void fp_ar_fmR(void) { gf3 = rf() * gf1; }
void fp_ar_fdG(void) { gf3 = gf1 / (gf2 * gf2 + 3.0); }
void fp_ar_fdP(float a, float b) { gf3 = a / (gf2 * gf2 + 3.0); }
void fp_ar_fdQ(float a, float b) { gf3 = a / (b * b + 3.0); }
void fp_ar_fdK(void) { gf3 = gf1 / 1.5f; }
void fp_ar_fdC(void) { gf3 = 2.25f / (gf1 * gf1 + 3.0); }
void fp_ar_fdA(void) { gf3 = gfa[2] / (gf1 * gf1 + 3.0); }
void fp_ar_fdS(void) { gf3 = gs.f / (gf1 * gf1 + 3.0); }
void fp_ar_fdR(void) { gf3 = rf() / (gf1 * gf1 + 3.0); }
void fp_ng_fG(void) { gf3 = -gf1; }
void fp_ng_fP(float a, float b) { gf3 = -a; }
void fp_ng_fA(void) { gf3 = -gfa[3]; }
void fp_ng_fS(void) { gf3 = -gs.f; }
void fp_cm_feGT(void) { gf3 = (gf1 == gf2 ? gf1 : gf2); }
void fp_cm_feGI(void) { if (gf1 == gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_feGR(void) { return (gf1 == gf2 ? 1 : 2); }
int fp_cm_feGB(void) { return gf1 == gf2; }
void fp_cm_feKT(void) { gf3 = (gf1 == 1.5f ? gf1 : 1.5f); }
void fp_cm_feKI(void) { if (gf1 == 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_feKR(void) { return (gf1 == 1.5f ? 1 : 2); }
int fp_cm_feKB(void) { return gf1 == 1.5f; }
void fp_cm_fePT(float a, float b) { gf3 = (a == gf2 ? a : gf2); }
void fp_cm_fePI(float a, float b) { if (a == gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_fePR(float a, float b) { return (a == gf2 ? 1 : 2); }
int fp_cm_fePB(float a, float b) { return a == gf2; }
void fp_cm_feAT(void) { gf3 = (gfa[1] == gf1 ? gfa[1] : gf1); }
void fp_cm_feAI(void) { if (gfa[1] == gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_feAR(void) { return (gfa[1] == gf1 ? 1 : 2); }
int fp_cm_feAB(void) { return gfa[1] == gf1; }
void fp_cm_fnGT(void) { gf3 = (gf1 != gf2 ? gf1 : gf2); }
void fp_cm_fnGI(void) { if (gf1 != gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fnGR(void) { return (gf1 != gf2 ? 1 : 2); }
int fp_cm_fnGB(void) { return gf1 != gf2; }
void fp_cm_fnKT(void) { gf3 = (gf1 != 1.5f ? gf1 : 1.5f); }
void fp_cm_fnKI(void) { if (gf1 != 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fnKR(void) { return (gf1 != 1.5f ? 1 : 2); }
int fp_cm_fnKB(void) { return gf1 != 1.5f; }
void fp_cm_fnPT(float a, float b) { gf3 = (a != gf2 ? a : gf2); }
void fp_cm_fnPI(float a, float b) { if (a != gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_fnPR(float a, float b) { return (a != gf2 ? 1 : 2); }
int fp_cm_fnPB(float a, float b) { return a != gf2; }
void fp_cm_fnAT(void) { gf3 = (gfa[1] != gf1 ? gfa[1] : gf1); }
void fp_cm_fnAI(void) { if (gfa[1] != gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_fnAR(void) { return (gfa[1] != gf1 ? 1 : 2); }
int fp_cm_fnAB(void) { return gfa[1] != gf1; }
void fp_cm_flGT(void) { gf3 = (gf1 < gf2 ? gf1 : gf2); }
void fp_cm_flGI(void) { if (gf1 < gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_flGR(void) { return (gf1 < gf2 ? 1 : 2); }
int fp_cm_flGB(void) { return gf1 < gf2; }
void fp_cm_flKT(void) { gf3 = (gf1 < 1.5f ? gf1 : 1.5f); }
void fp_cm_flKI(void) { if (gf1 < 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_flKR(void) { return (gf1 < 1.5f ? 1 : 2); }
int fp_cm_flKB(void) { return gf1 < 1.5f; }
void fp_cm_flPT(float a, float b) { gf3 = (a < gf2 ? a : gf2); }
void fp_cm_flPI(float a, float b) { if (a < gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_flPR(float a, float b) { return (a < gf2 ? 1 : 2); }
int fp_cm_flPB(float a, float b) { return a < gf2; }
void fp_cm_flAT(void) { gf3 = (gfa[1] < gf1 ? gfa[1] : gf1); }
void fp_cm_flAI(void) { if (gfa[1] < gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_flAR(void) { return (gfa[1] < gf1 ? 1 : 2); }
int fp_cm_flAB(void) { return gfa[1] < gf1; }
void fp_cm_fgGT(void) { gf3 = (gf1 > gf2 ? gf1 : gf2); }
void fp_cm_fgGI(void) { if (gf1 > gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fgGR(void) { return (gf1 > gf2 ? 1 : 2); }
int fp_cm_fgGB(void) { return gf1 > gf2; }
void fp_cm_fgKT(void) { gf3 = (gf1 > 1.5f ? gf1 : 1.5f); }
void fp_cm_fgKI(void) { if (gf1 > 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fgKR(void) { return (gf1 > 1.5f ? 1 : 2); }
int fp_cm_fgKB(void) { return gf1 > 1.5f; }
void fp_cm_fgPT(float a, float b) { gf3 = (a > gf2 ? a : gf2); }
void fp_cm_fgPI(float a, float b) { if (a > gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_fgPR(float a, float b) { return (a > gf2 ? 1 : 2); }
int fp_cm_fgPB(float a, float b) { return a > gf2; }
void fp_cm_fgAT(void) { gf3 = (gfa[1] > gf1 ? gfa[1] : gf1); }
void fp_cm_fgAI(void) { if (gfa[1] > gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_fgAR(void) { return (gfa[1] > gf1 ? 1 : 2); }
int fp_cm_fgAB(void) { return gfa[1] > gf1; }
void fp_cm_fLGT(void) { gf3 = (gf1 <= gf2 ? gf1 : gf2); }
void fp_cm_fLGI(void) { if (gf1 <= gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fLGR(void) { return (gf1 <= gf2 ? 1 : 2); }
int fp_cm_fLGB(void) { return gf1 <= gf2; }
void fp_cm_fLKT(void) { gf3 = (gf1 <= 1.5f ? gf1 : 1.5f); }
void fp_cm_fLKI(void) { if (gf1 <= 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fLKR(void) { return (gf1 <= 1.5f ? 1 : 2); }
int fp_cm_fLKB(void) { return gf1 <= 1.5f; }
void fp_cm_fLPT(float a, float b) { gf3 = (a <= gf2 ? a : gf2); }
void fp_cm_fLPI(float a, float b) { if (a <= gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_fLPR(float a, float b) { return (a <= gf2 ? 1 : 2); }
int fp_cm_fLPB(float a, float b) { return a <= gf2; }
void fp_cm_fLAT(void) { gf3 = (gfa[1] <= gf1 ? gfa[1] : gf1); }
void fp_cm_fLAI(void) { if (gfa[1] <= gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_fLAR(void) { return (gfa[1] <= gf1 ? 1 : 2); }
int fp_cm_fLAB(void) { return gfa[1] <= gf1; }
void fp_cm_fGGT(void) { gf3 = (gf1 >= gf2 ? gf1 : gf2); }
void fp_cm_fGGI(void) { if (gf1 >= gf2) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fGGR(void) { return (gf1 >= gf2 ? 1 : 2); }
int fp_cm_fGGB(void) { return gf1 >= gf2; }
void fp_cm_fGKT(void) { gf3 = (gf1 >= 1.5f ? gf1 : 1.5f); }
void fp_cm_fGKI(void) { if (gf1 >= 1.5f) gf3 = gf1; else gf3 = 1.0; }
int fp_cm_fGKR(void) { return (gf1 >= 1.5f ? 1 : 2); }
int fp_cm_fGKB(void) { return gf1 >= 1.5f; }
void fp_cm_fGPT(float a, float b) { gf3 = (a >= gf2 ? a : gf2); }
void fp_cm_fGPI(float a, float b) { if (a >= gf2) gf3 = a; else gf3 = 1.0; }
int fp_cm_fGPR(float a, float b) { return (a >= gf2 ? 1 : 2); }
int fp_cm_fGPB(float a, float b) { return a >= gf2; }
void fp_cm_fGAT(void) { gf3 = (gfa[1] >= gf1 ? gfa[1] : gf1); }
void fp_cm_fGAI(void) { if (gfa[1] >= gf1) gf3 = gfa[1]; else gf3 = 1.0; }
int fp_cm_fGAR(void) { return (gfa[1] >= gf1 ? 1 : 2); }
int fp_cm_fGAB(void) { return gfa[1] >= gf1; }
void fp_ci_fcF(void) { gc3 = (char)gf1; }
void fp_ci_fcT(void) { gf3 = (float)gc1; }
float __cdecl fp_ci_fcP(char a) { return a; }
char fp_ci_fcQ(float a) { return (char)a; }
void fp_ci_fbF(void) { gb3 = (unsigned char)gf1; }
void fp_ci_fbT(void) { gf3 = (float)gb1; }
float __cdecl fp_ci_fbP(unsigned char a) { return a; }
unsigned char fp_ci_fbQ(float a) { return (unsigned char)a; }
void fp_ci_fiF(void) { gi3 = (int)gf1; }
void fp_ci_fiT(void) { gf3 = (float)gi1; }
float __cdecl fp_ci_fiP(int a) { return a; }
int fp_ci_fiQ(float a) { return (int)a; }
void fp_ci_fuF(void) { gu3 = (unsigned int)gf1; }
void fp_ci_fuT(void) { gf3 = (float)gu1; }
float __cdecl fp_ci_fuP(unsigned int a) { return a; }
unsigned int fp_ci_fuQ(float a) { return (unsigned int)a; }
void fp_ci_flF(void) { gl3 = (long)gf1; }
void fp_ci_flT(void) { gf3 = (float)gl1; }
float __cdecl fp_ci_flP(long a) { return a; }
long fp_ci_flQ(float a) { return (long)a; }
void fp_ci_fnF(void) { gn3 = (unsigned long)gf1; }
void fp_ci_fnT(void) { gf3 = (float)gn1; }
float __cdecl fp_ci_fnP(unsigned long a) { return a; }
unsigned long fp_ci_fnQ(float a) { return (unsigned long)a; }
float __cdecl fp_pr_f0(float a, float b) { return a; }
float __cdecl fp_pr_f1(float a, float b) { return a + b; }
float __cdecl fp_pr_f2(float a, float b, float c) { return a * b - c; }
float __cdecl fp_pr_f3(int i, float a) { return a + i; }
float __cdecl fp_pr_f4(float a, int i) { return a * i; }
float __cdecl fp_pr_f5(float a, float b) { gf3 = a; return b; }
float __cdecl fp_pr_f6(float a, float b) { return -a; }
float __cdecl fp_pr_f7(float a, float b) { vf(a); return b; }
void fp_st_f0(void) { gs.f = gfa[2] + gs.f; }
void fp_st_f1(int i) { gfa[i & 7] = gf1 * 2.0; }
void fp_st_f2(void) { gps->f = gps->f - gf1; }
void fp_st_f3(void) { gs.f = gf1; gs.f2 = gs.f * gf2; }
void fp_st_f4(void) { gfa[4] = gfa[1] + gfa[2]; }
float __cdecl fp_st_f5(float *p) { return p[3] - p[1]; }
void fp_lc_f0(void) { float t = gf1 * gf2; v0(); gf3 = t + gf1; }
float __cdecl fp_lc_f1(float a) { v0(); return a * 2.0; }
void fp_lc_f2(void) { float t = rf(); vf(gf1); gf3 = t - rf(); }
float __cdecl fp_lc_f3(float a) { float t = a + gf1; v0(); return t * a; }
void fp_lc_f4(void) { float t = gf1; int i; for (i = 0; i < 3; i++) { v0(); gfa[i] = t; } gf3 = t; }
void fp_lc_f5(void) { int n = gi1; float t = gf2 + 1.0; v0(); gf3 = t * n; }
void fp_tm_f0(void) { gf3 = (gf1 + gf2) * (gf1 - gf2); }
void fp_tm_f1(void) { gf3 = (gf1 + gf2) * (gf1 - gf2) / (gf2 * gf2 + 2.5); }
void fp_tm_f2(void) { gf3 = rf() * (gf1 + rf()); }
void fp_tm_f3(void) { gf3 = ((gf1 * 2.0 + gf2) * (gf2 - 0.5)) + (gf1 * gf1); }
int fp_tm_f4(void) { return (gf1 + gf2) < (gf1 * gf2); }
void fp_tm_f5(void) { gf3 = (gf1 + gi1) * (gf2 - gl1); }
void fp_oa_faG(void) { gf1 += gf2; }
void fp_oa_faL(void) { float t = gf1; t += gf2; gf3 = t; }
void fp_oa_faA(void) { gfa[3] += gf2; }
void fp_oa_faS(void) { gs.f += gf2; }
float __cdecl fp_oa_faP(float a, float b) { a += b; return a; }
void fp_oa_fsG(void) { gf1 -= gf2; }
void fp_oa_fsL(void) { float t = gf1; t -= gf2; gf3 = t; }
void fp_oa_fsA(void) { gfa[3] -= gf2; }
void fp_oa_fsS(void) { gs.f -= gf2; }
float __cdecl fp_oa_fsP(float a, float b) { a -= b; return a; }
void fp_oa_fmG(void) { gf1 *= gf2; }
void fp_oa_fmL(void) { float t = gf1; t *= gf2; gf3 = t; }
void fp_oa_fmA(void) { gfa[3] *= gf2; }
void fp_oa_fmS(void) { gs.f *= gf2; }
float __cdecl fp_oa_fmP(float a, float b) { a *= b; return a; }
void fp_oa_fdG(void) { gf1 /= (gf2 * gf2 + 3.0); }
void fp_oa_fdL(void) { float t = gf1; t /= (gf2 * gf2 + 3.0); gf3 = t; }
void fp_oa_fdA(void) { gfa[3] /= (gf2 * gf2 + 3.0); }
void fp_oa_fdS(void) { gs.f /= (gf2 * gf2 + 3.0); }
float __cdecl fp_oa_fdP(float a, float b) { a /= (b * b + 3.0); return a; }
void fp_ch_daa(void) { gd3 = gd1 + gd2 + 1.25; }
void fp_ch_das(void) { gd3 = gd1 + gd2 - 1.25; }
void fp_ch_dam(void) { gd3 = gd1 + gd2 * 1.25; }
void fp_ch_dad(void) { gd3 = gd1 + gd2 / 1.25; }
void fp_ch_dsa(void) { gd3 = gd1 - gd2 + 1.25; }
void fp_ch_dss(void) { gd3 = gd1 - gd2 - 1.25; }
void fp_ch_dsm(void) { gd3 = gd1 - gd2 * 1.25; }
void fp_ch_dsd(void) { gd3 = gd1 - gd2 / 1.25; }
void fp_ch_dma(void) { gd3 = gd1 * gd2 + 1.25; }
void fp_ch_dms(void) { gd3 = gd1 * gd2 - 1.25; }
void fp_ch_dmm(void) { gd3 = gd1 * gd2 * 1.25; }
void fp_ch_dmd(void) { gd3 = gd1 * gd2 / 1.25; }
void fp_ch_dda(void) { gd3 = gd1 / (gd2 * gd2 + 3.0) + 1.25; }
void fp_ch_dds(void) { gd3 = gd1 / (gd2 * gd2 + 3.0) - 1.25; }
void fp_ch_ddm(void) { gd3 = gd1 / (gd2 * gd2 + 3.0) * 1.25; }
void fp_ch_ddd(void) { gd3 = gd1 / (gd2 * gd2 + 3.0) / 1.25; }
void fp_ce_dcF(void) { gc3 = (char)gda[2]; }
void fp_ce_dcT(void) { gs.d = gc1; }
void fp_oi_dac(void) { gd1 += gc1; }
void fp_oi_dsc(void) { gd1 -= gc1; }
void fp_oi_dmc(void) { gd1 *= gc1; }
void fp_oi_ddc(void) { gd1 /= (gc1 | 1); }
void fp_ce_dbF(void) { gb3 = (unsigned char)gda[2]; }
void fp_ce_dbT(void) { gs.d = gb1; }
void fp_oi_dab(void) { gd1 += gb1; }
void fp_oi_dsb(void) { gd1 -= gb1; }
void fp_oi_dmb(void) { gd1 *= gb1; }
void fp_oi_ddb(void) { gd1 /= (gb1 | 1); }
void fp_ce_diF(void) { gi3 = (int)gda[2]; }
void fp_ce_diT(void) { gs.d = gi1; }
void fp_oi_dai(void) { gd1 += gi1; }
void fp_oi_dsi(void) { gd1 -= gi1; }
void fp_oi_dmi(void) { gd1 *= gi1; }
void fp_oi_ddi(void) { gd1 /= (gi1 | 1); }
void fp_ce_duF(void) { gu3 = (unsigned int)gda[2]; }
void fp_ce_duT(void) { gs.d = gu1; }
void fp_oi_dau(void) { gd1 += gu1; }
void fp_oi_dsu(void) { gd1 -= gu1; }
void fp_oi_dmu(void) { gd1 *= gu1; }
void fp_oi_ddu(void) { gd1 /= (gu1 | 1); }
void fp_ce_dlF(void) { gl3 = (long)gda[2]; }
void fp_ce_dlT(void) { gs.d = gl1; }
void fp_oi_dal(void) { gd1 += gl1; }
void fp_oi_dsl(void) { gd1 -= gl1; }
void fp_oi_dml(void) { gd1 *= gl1; }
void fp_oi_ddl(void) { gd1 /= (gl1 | 1); }
void fp_ce_dnF(void) { gn3 = (unsigned long)gda[2]; }
void fp_ce_dnT(void) { gs.d = gn1; }
void fp_oi_dan(void) { gd1 += gn1; }
void fp_oi_dsn(void) { gd1 -= gn1; }
void fp_oi_dmn(void) { gd1 *= gn1; }
void fp_oi_ddn(void) { gd1 /= (gn1 | 1); }
void fp_cx_dec(void) { gd3 = (gd1 == gc1 ? gd1 : gd2); }
void fp_cx_dei(void) { gd3 = (gd1 == gi1 ? gd1 : gd2); }
void fp_cx_del(void) { gd3 = (gd1 == gl1 ? gd1 : gd2); }
void fp_cx_dnc(void) { gd3 = (gd1 != gc1 ? gd1 : gd2); }
void fp_cx_dni(void) { gd3 = (gd1 != gi1 ? gd1 : gd2); }
void fp_cx_dnl(void) { gd3 = (gd1 != gl1 ? gd1 : gd2); }
void fp_cx_dlc(void) { gd3 = (gd1 < gc1 ? gd1 : gd2); }
void fp_cx_dli(void) { gd3 = (gd1 < gi1 ? gd1 : gd2); }
void fp_cx_dll(void) { gd3 = (gd1 < gl1 ? gd1 : gd2); }
void fp_cx_dgc(void) { gd3 = (gd1 > gc1 ? gd1 : gd2); }
void fp_cx_dgi(void) { gd3 = (gd1 > gi1 ? gd1 : gd2); }
void fp_cx_dgl(void) { gd3 = (gd1 > gl1 ? gd1 : gd2); }
void fp_cx_dLc(void) { gd3 = (gd1 <= gc1 ? gd1 : gd2); }
void fp_cx_dLi(void) { gd3 = (gd1 <= gi1 ? gd1 : gd2); }
void fp_cx_dLl(void) { gd3 = (gd1 <= gl1 ? gd1 : gd2); }
void fp_cx_dGc(void) { gd3 = (gd1 >= gc1 ? gd1 : gd2); }
void fp_cx_dGi(void) { gd3 = (gd1 >= gi1 ? gd1 : gd2); }
void fp_cx_dGl(void) { gd3 = (gd1 >= gl1 ? gd1 : gd2); }
double __cdecl fp_xr_d0(double a, int b, double c) { return a * b + c; }
int fp_xr_d1(int a, double b) { gd3 = b; return a; }
int fp_xr_d2(double a, double b) { if (a < b) return 1; return 0; }
double __cdecl fp_xr_d3(double a, double b) { v0(); return b - a; }
long fp_xr_d4(double a) { return (long)a; }
double __cdecl fp_xr_d5(long a) { return (double)a; }
void fp_xr_d6(double a, double b) { vd(b); vd(a); }
double __cdecl fp_xr_d7(int i, double a) { return gda[i & 7] + a; }
double __cdecl fp_lo_d0(void) { double s = 0.0; int i; for (i = 0; i < 8; i++) s += gda[i]; return s; }
double __cdecl fp_lo_d1(void) { double s = 1.0; int i; for (i = 1; i < 5; i++) s *= i; return s * gd1; }
double __cdecl fp_lo_d2(void) { double s = gda[0]; int i; for (i = 1; i < 8; i++) if (gda[i] > s) s = gda[i]; return s; }
void fp_ch_faa(void) { gf3 = gf1 + gf2 + 1.25; }
void fp_ch_fas(void) { gf3 = gf1 + gf2 - 1.25; }
void fp_ch_fam(void) { gf3 = gf1 + gf2 * 1.25; }
void fp_ch_fad(void) { gf3 = gf1 + gf2 / 1.25; }
void fp_ch_fsa(void) { gf3 = gf1 - gf2 + 1.25; }
void fp_ch_fss(void) { gf3 = gf1 - gf2 - 1.25; }
void fp_ch_fsm(void) { gf3 = gf1 - gf2 * 1.25; }
void fp_ch_fsd(void) { gf3 = gf1 - gf2 / 1.25; }
void fp_ch_fma(void) { gf3 = gf1 * gf2 + 1.25; }
void fp_ch_fms(void) { gf3 = gf1 * gf2 - 1.25; }
void fp_ch_fmm(void) { gf3 = gf1 * gf2 * 1.25; }
void fp_ch_fmd(void) { gf3 = gf1 * gf2 / 1.25; }
void fp_ch_fda(void) { gf3 = gf1 / (gf2 * gf2 + 3.0) + 1.25; }
void fp_ch_fds(void) { gf3 = gf1 / (gf2 * gf2 + 3.0) - 1.25; }
void fp_ch_fdm(void) { gf3 = gf1 / (gf2 * gf2 + 3.0) * 1.25; }
void fp_ch_fdd(void) { gf3 = gf1 / (gf2 * gf2 + 3.0) / 1.25; }
void fp_ce_fcF(void) { gc3 = (char)gfa[2]; }
void fp_ce_fcT(void) { gs.f = gc1; }
void fp_oi_fac(void) { gf1 += gc1; }
void fp_oi_fsc(void) { gf1 -= gc1; }
void fp_oi_fmc(void) { gf1 *= gc1; }
void fp_oi_fdc(void) { gf1 /= (gc1 | 1); }
void fp_ce_fbF(void) { gb3 = (unsigned char)gfa[2]; }
void fp_ce_fbT(void) { gs.f = gb1; }
void fp_oi_fab(void) { gf1 += gb1; }
void fp_oi_fsb(void) { gf1 -= gb1; }
void fp_oi_fmb(void) { gf1 *= gb1; }
void fp_oi_fdb(void) { gf1 /= (gb1 | 1); }
void fp_ce_fiF(void) { gi3 = (int)gfa[2]; }
void fp_ce_fiT(void) { gs.f = gi1; }
void fp_oi_fai(void) { gf1 += gi1; }
void fp_oi_fsi(void) { gf1 -= gi1; }
void fp_oi_fmi(void) { gf1 *= gi1; }
void fp_oi_fdi(void) { gf1 /= (gi1 | 1); }
void fp_ce_fuF(void) { gu3 = (unsigned int)gfa[2]; }
void fp_ce_fuT(void) { gs.f = gu1; }
void fp_oi_fau(void) { gf1 += gu1; }
void fp_oi_fsu(void) { gf1 -= gu1; }
void fp_oi_fmu(void) { gf1 *= gu1; }
void fp_oi_fdu(void) { gf1 /= (gu1 | 1); }
void fp_ce_flF(void) { gl3 = (long)gfa[2]; }
void fp_ce_flT(void) { gs.f = gl1; }
void fp_oi_fal(void) { gf1 += gl1; }
void fp_oi_fsl(void) { gf1 -= gl1; }
void fp_oi_fml(void) { gf1 *= gl1; }
void fp_oi_fdl(void) { gf1 /= (gl1 | 1); }
void fp_ce_fnF(void) { gn3 = (unsigned long)gfa[2]; }
void fp_ce_fnT(void) { gs.f = gn1; }
void fp_oi_fan(void) { gf1 += gn1; }
void fp_oi_fsn(void) { gf1 -= gn1; }
void fp_oi_fmn(void) { gf1 *= gn1; }
void fp_oi_fdn(void) { gf1 /= (gn1 | 1); }
void fp_cx_fec(void) { gf3 = (gf1 == gc1 ? gf1 : gf2); }
void fp_cx_fei(void) { gf3 = (gf1 == gi1 ? gf1 : gf2); }
void fp_cx_fel(void) { gf3 = (gf1 == gl1 ? gf1 : gf2); }
void fp_cx_fnc(void) { gf3 = (gf1 != gc1 ? gf1 : gf2); }
void fp_cx_fni(void) { gf3 = (gf1 != gi1 ? gf1 : gf2); }
void fp_cx_fnl(void) { gf3 = (gf1 != gl1 ? gf1 : gf2); }
void fp_cx_flc(void) { gf3 = (gf1 < gc1 ? gf1 : gf2); }
void fp_cx_fli(void) { gf3 = (gf1 < gi1 ? gf1 : gf2); }
void fp_cx_fll(void) { gf3 = (gf1 < gl1 ? gf1 : gf2); }
void fp_cx_fgc(void) { gf3 = (gf1 > gc1 ? gf1 : gf2); }
void fp_cx_fgi(void) { gf3 = (gf1 > gi1 ? gf1 : gf2); }
void fp_cx_fgl(void) { gf3 = (gf1 > gl1 ? gf1 : gf2); }
void fp_cx_fLc(void) { gf3 = (gf1 <= gc1 ? gf1 : gf2); }
void fp_cx_fLi(void) { gf3 = (gf1 <= gi1 ? gf1 : gf2); }
void fp_cx_fLl(void) { gf3 = (gf1 <= gl1 ? gf1 : gf2); }
void fp_cx_fGc(void) { gf3 = (gf1 >= gc1 ? gf1 : gf2); }
void fp_cx_fGi(void) { gf3 = (gf1 >= gi1 ? gf1 : gf2); }
void fp_cx_fGl(void) { gf3 = (gf1 >= gl1 ? gf1 : gf2); }
float __cdecl fp_xr_f0(float a, int b, float c) { return a * b + c; }
int fp_xr_f1(int a, float b) { gf3 = b; return a; }
int fp_xr_f2(float a, float b) { if (a < b) return 1; return 0; }
float __cdecl fp_xr_f3(float a, float b) { v0(); return b - a; }
long fp_xr_f4(float a) { return (long)a; }
float __cdecl fp_xr_f5(long a) { return (float)a; }
void fp_xr_f6(float a, float b) { vf(b); vf(a); }
float __cdecl fp_xr_f7(int i, float a) { return gfa[i & 7] + a; }
float __cdecl fp_lo_f0(void) { float s = 0.0; int i; for (i = 0; i < 8; i++) s += gfa[i]; return s; }
float __cdecl fp_lo_f1(void) { float s = 1.0; int i; for (i = 1; i < 5; i++) s *= i; return s * gf1; }
float __cdecl fp_lo_f2(void) { float s = gfa[0]; int i; for (i = 1; i < 8; i++) if (gfa[i] > s) s = gfa[i]; return s; }
void fp_ai_da(int i) { gd3 = gda[i & 7] + gd2; }
void fp_sp_da(struct sv *p) { p->d = p->d + gd2; }
void fp_ai_ds(int i) { gd3 = gda[i & 7] - gd2; }
void fp_sp_ds(struct sv *p) { p->d = p->d - gd2; }
void fp_ai_dm(int i) { gd3 = gda[i & 7] * gd2; }
void fp_sp_dm(struct sv *p) { p->d = p->d * gd2; }
void fp_ai_dd(int i) { gd3 = gda[i & 7] / (gd2 * gd2 + 3.0); }
void fp_sp_dd(struct sv *p) { p->d = p->d / (gd2 * gd2 + 3.0); }
void fp_cr_dc(void) { gc3 = (char)rd(); }
void fp_cr_db(void) { gb3 = (unsigned char)rd(); }
void fp_cr_di(void) { gi3 = (int)rd(); }
void fp_cr_du(void) { gu3 = (unsigned int)rd(); }
void fp_cr_dl(void) { gl3 = (long)rd(); }
void fp_cr_dn(void) { gn3 = (unsigned long)rd(); }
void fp_ai_fa(int i) { gf3 = gfa[i & 7] + gf2; }
void fp_sp_fa(struct sv *p) { p->f = p->f + gf2; }
void fp_ai_fs(int i) { gf3 = gfa[i & 7] - gf2; }
void fp_sp_fs(struct sv *p) { p->f = p->f - gf2; }
void fp_ai_fm(int i) { gf3 = gfa[i & 7] * gf2; }
void fp_sp_fm(struct sv *p) { p->f = p->f * gf2; }
void fp_ai_fd(int i) { gf3 = gfa[i & 7] / (gf2 * gf2 + 3.0); }
void fp_sp_fd(struct sv *p) { p->f = p->f / (gf2 * gf2 + 3.0); }
void fp_cr_fc(void) { gc3 = (char)rf(); }
void fp_cr_fb(void) { gb3 = (unsigned char)rf(); }
void fp_cr_fi(void) { gi3 = (int)rf(); }
void fp_cr_fu(void) { gu3 = (unsigned int)rf(); }
void fp_cr_fl(void) { gl3 = (long)rf(); }
void fp_cr_fn(void) { gn3 = (unsigned long)rf(); }
void fp_ff_D(void) { gd3 = gf1; }
void fp_ff_F(void) { gf3 = gd1; }
void fp_ff_A(void) { gd3 = gf1 + gd2; }
void fp_ff_M(void) { gf3 = gf1 * (float)gd2; }
double __cdecl fp_ff_P(float a) { return a; }
float __cdecl fp_ff_Q(double a) { return a; }
