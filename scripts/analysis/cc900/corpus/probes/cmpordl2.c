/* Compare operands of the second wave (gen_cmpordl2.py): c<i|l|c>_<op>_<L><R>(c) { int t = gi; if (L op R) gi3 = 1; }
   for int, long and char kinds, op < (l) and == (e).  Kinds: K constant, G global, P deref, I pointer at a
   constant index, A member array through a pointer at c, X element at c, Y element at the local t, Z / W / V / U
   widening casts of a char / int / pointed char / unsigned char, S element shifted by a constant, F a call with
   an argument, B a masked deref; W for char: a narrowing cast of an unsigned long.  Left g*, right h*. */
struct st { char c; int i; long l; int a[4]; };
extern int gi, hi, gi3; extern long gl, hl; extern char gc, hc; extern unsigned char guc, huc; extern unsigned long gul, hul;
extern int gia[10], hia[10]; extern long gla[10], hla[10]; extern char gca[10], hca[10];
extern int *gpi, *hpi; extern long *gpl, *hpl; extern char *gp, *hp; extern struct st gs, *gps, hs, *hps;
extern int gri(int), hri(int); extern long grl(long), hrl(long); extern char grc(int), hrc(int);

void ci_l_KG(int c) { int t = gi; if (7 < hi) gi3 = 1; }
void ci_l_KP(int c) { int t = gi; if (7 < *hpi) gi3 = 1; }
void ci_l_KI(int c) { int t = gi; if (7 < hpi[2]) gi3 = 1; }
void ci_l_KA(int c) { int t = gi; if (7 < hps->a[c]) gi3 = 1; }
void ci_l_KY(int c) { int t = gi; if (7 < hia[t]) gi3 = 1; }
void ci_l_KZ(int c) { int t = gi; if (7 < (int)hc) gi3 = 1; }
void ci_l_KU(int c) { int t = gi; if (7 < (int)huc) gi3 = 1; }
void ci_l_KF(int c) { int t = gi; if (7 < hri(hi)) gi3 = 1; }
void ci_l_GK(int c) { int t = gi; if (gi < 7) gi3 = 1; }
void ci_l_GG(int c) { int t = gi; if (gi < hi) gi3 = 1; }
void ci_l_GP(int c) { int t = gi; if (gi < *hpi) gi3 = 1; }
void ci_l_GI(int c) { int t = gi; if (gi < hpi[2]) gi3 = 1; }
void ci_l_GA(int c) { int t = gi; if (gi < hps->a[c]) gi3 = 1; }
void ci_l_GY(int c) { int t = gi; if (gi < hia[t]) gi3 = 1; }
void ci_l_GZ(int c) { int t = gi; if (gi < (int)hc) gi3 = 1; }
void ci_l_GU(int c) { int t = gi; if (gi < (int)huc) gi3 = 1; }
void ci_l_GF(int c) { int t = gi; if (gi < hri(hi)) gi3 = 1; }
void ci_l_PK(int c) { int t = gi; if (*gpi < 7) gi3 = 1; }
void ci_l_PG(int c) { int t = gi; if (*gpi < hi) gi3 = 1; }
void ci_l_PP(int c) { int t = gi; if (*gpi < *hpi) gi3 = 1; }
void ci_l_PI(int c) { int t = gi; if (*gpi < hpi[2]) gi3 = 1; }
void ci_l_PA(int c) { int t = gi; if (*gpi < hps->a[c]) gi3 = 1; }
void ci_l_PY(int c) { int t = gi; if (*gpi < hia[t]) gi3 = 1; }
void ci_l_PZ(int c) { int t = gi; if (*gpi < (int)hc) gi3 = 1; }
void ci_l_PU(int c) { int t = gi; if (*gpi < (int)huc) gi3 = 1; }
void ci_l_PF(int c) { int t = gi; if (*gpi < hri(hi)) gi3 = 1; }
void ci_l_IK(int c) { int t = gi; if (gpi[2] < 7) gi3 = 1; }
void ci_l_IG(int c) { int t = gi; if (gpi[2] < hi) gi3 = 1; }
void ci_l_IP(int c) { int t = gi; if (gpi[2] < *hpi) gi3 = 1; }
void ci_l_II(int c) { int t = gi; if (gpi[2] < hpi[2]) gi3 = 1; }
void ci_l_IA(int c) { int t = gi; if (gpi[2] < hps->a[c]) gi3 = 1; }
void ci_l_IY(int c) { int t = gi; if (gpi[2] < hia[t]) gi3 = 1; }
void ci_l_IZ(int c) { int t = gi; if (gpi[2] < (int)hc) gi3 = 1; }
void ci_l_IU(int c) { int t = gi; if (gpi[2] < (int)huc) gi3 = 1; }
void ci_l_IF(int c) { int t = gi; if (gpi[2] < hri(hi)) gi3 = 1; }
void ci_l_AK(int c) { int t = gi; if (gps->a[c] < 7) gi3 = 1; }
void ci_l_AG(int c) { int t = gi; if (gps->a[c] < hi) gi3 = 1; }
void ci_l_AP(int c) { int t = gi; if (gps->a[c] < *hpi) gi3 = 1; }
void ci_l_AI(int c) { int t = gi; if (gps->a[c] < hpi[2]) gi3 = 1; }
void ci_l_AA(int c) { int t = gi; if (gps->a[c] < hps->a[c]) gi3 = 1; }
void ci_l_AY(int c) { int t = gi; if (gps->a[c] < hia[t]) gi3 = 1; }
void ci_l_AZ(int c) { int t = gi; if (gps->a[c] < (int)hc) gi3 = 1; }
void ci_l_AU(int c) { int t = gi; if (gps->a[c] < (int)huc) gi3 = 1; }
void ci_l_AF(int c) { int t = gi; if (gps->a[c] < hri(hi)) gi3 = 1; }
void ci_l_YK(int c) { int t = gi; if (gia[t] < 7) gi3 = 1; }
void ci_l_YG(int c) { int t = gi; if (gia[t] < hi) gi3 = 1; }
void ci_l_YP(int c) { int t = gi; if (gia[t] < *hpi) gi3 = 1; }
void ci_l_YI(int c) { int t = gi; if (gia[t] < hpi[2]) gi3 = 1; }
void ci_l_YA(int c) { int t = gi; if (gia[t] < hps->a[c]) gi3 = 1; }
void ci_l_YY(int c) { int t = gi; if (gia[t] < hia[t]) gi3 = 1; }
void ci_l_YZ(int c) { int t = gi; if (gia[t] < (int)hc) gi3 = 1; }
void ci_l_YU(int c) { int t = gi; if (gia[t] < (int)huc) gi3 = 1; }
void ci_l_YF(int c) { int t = gi; if (gia[t] < hri(hi)) gi3 = 1; }
void ci_l_ZK(int c) { int t = gi; if ((int)gc < 7) gi3 = 1; }
void ci_l_ZG(int c) { int t = gi; if ((int)gc < hi) gi3 = 1; }
void ci_l_ZP(int c) { int t = gi; if ((int)gc < *hpi) gi3 = 1; }
void ci_l_ZI(int c) { int t = gi; if ((int)gc < hpi[2]) gi3 = 1; }
void ci_l_ZA(int c) { int t = gi; if ((int)gc < hps->a[c]) gi3 = 1; }
void ci_l_ZY(int c) { int t = gi; if ((int)gc < hia[t]) gi3 = 1; }
void ci_l_ZZ(int c) { int t = gi; if ((int)gc < (int)hc) gi3 = 1; }
void ci_l_ZU(int c) { int t = gi; if ((int)gc < (int)huc) gi3 = 1; }
void ci_l_ZF(int c) { int t = gi; if ((int)gc < hri(hi)) gi3 = 1; }
void ci_l_UK(int c) { int t = gi; if ((int)guc < 7) gi3 = 1; }
void ci_l_UG(int c) { int t = gi; if ((int)guc < hi) gi3 = 1; }
void ci_l_UP(int c) { int t = gi; if ((int)guc < *hpi) gi3 = 1; }
void ci_l_UI(int c) { int t = gi; if ((int)guc < hpi[2]) gi3 = 1; }
void ci_l_UA(int c) { int t = gi; if ((int)guc < hps->a[c]) gi3 = 1; }
void ci_l_UY(int c) { int t = gi; if ((int)guc < hia[t]) gi3 = 1; }
void ci_l_UZ(int c) { int t = gi; if ((int)guc < (int)hc) gi3 = 1; }
void ci_l_UU(int c) { int t = gi; if ((int)guc < (int)huc) gi3 = 1; }
void ci_l_UF(int c) { int t = gi; if ((int)guc < hri(hi)) gi3 = 1; }
void ci_l_FK(int c) { int t = gi; if (gri(gi) < 7) gi3 = 1; }
void ci_l_FG(int c) { int t = gi; if (gri(gi) < hi) gi3 = 1; }
void ci_l_FP(int c) { int t = gi; if (gri(gi) < *hpi) gi3 = 1; }
void ci_l_FI(int c) { int t = gi; if (gri(gi) < hpi[2]) gi3 = 1; }
void ci_l_FA(int c) { int t = gi; if (gri(gi) < hps->a[c]) gi3 = 1; }
void ci_l_FY(int c) { int t = gi; if (gri(gi) < hia[t]) gi3 = 1; }
void ci_l_FZ(int c) { int t = gi; if (gri(gi) < (int)hc) gi3 = 1; }
void ci_l_FU(int c) { int t = gi; if (gri(gi) < (int)huc) gi3 = 1; }
void ci_l_FF(int c) { int t = gi; if (gri(gi) < hri(hi)) gi3 = 1; }

void ci_e_KG(int c) { int t = gi; if (7 == hi) gi3 = 1; }
void ci_e_KP(int c) { int t = gi; if (7 == *hpi) gi3 = 1; }
void ci_e_KI(int c) { int t = gi; if (7 == hpi[2]) gi3 = 1; }
void ci_e_KA(int c) { int t = gi; if (7 == hps->a[c]) gi3 = 1; }
void ci_e_KY(int c) { int t = gi; if (7 == hia[t]) gi3 = 1; }
void ci_e_KZ(int c) { int t = gi; if (7 == (int)hc) gi3 = 1; }
void ci_e_KU(int c) { int t = gi; if (7 == (int)huc) gi3 = 1; }
void ci_e_KF(int c) { int t = gi; if (7 == hri(hi)) gi3 = 1; }
void ci_e_GK(int c) { int t = gi; if (gi == 7) gi3 = 1; }
void ci_e_GG(int c) { int t = gi; if (gi == hi) gi3 = 1; }
void ci_e_GP(int c) { int t = gi; if (gi == *hpi) gi3 = 1; }
void ci_e_GI(int c) { int t = gi; if (gi == hpi[2]) gi3 = 1; }
void ci_e_GA(int c) { int t = gi; if (gi == hps->a[c]) gi3 = 1; }
void ci_e_GY(int c) { int t = gi; if (gi == hia[t]) gi3 = 1; }
void ci_e_GZ(int c) { int t = gi; if (gi == (int)hc) gi3 = 1; }
void ci_e_GU(int c) { int t = gi; if (gi == (int)huc) gi3 = 1; }
void ci_e_GF(int c) { int t = gi; if (gi == hri(hi)) gi3 = 1; }
void ci_e_PK(int c) { int t = gi; if (*gpi == 7) gi3 = 1; }
void ci_e_PG(int c) { int t = gi; if (*gpi == hi) gi3 = 1; }
void ci_e_PP(int c) { int t = gi; if (*gpi == *hpi) gi3 = 1; }
void ci_e_PI(int c) { int t = gi; if (*gpi == hpi[2]) gi3 = 1; }
void ci_e_PA(int c) { int t = gi; if (*gpi == hps->a[c]) gi3 = 1; }
void ci_e_PY(int c) { int t = gi; if (*gpi == hia[t]) gi3 = 1; }
void ci_e_PZ(int c) { int t = gi; if (*gpi == (int)hc) gi3 = 1; }
void ci_e_PU(int c) { int t = gi; if (*gpi == (int)huc) gi3 = 1; }
void ci_e_PF(int c) { int t = gi; if (*gpi == hri(hi)) gi3 = 1; }
void ci_e_IK(int c) { int t = gi; if (gpi[2] == 7) gi3 = 1; }
void ci_e_IG(int c) { int t = gi; if (gpi[2] == hi) gi3 = 1; }
void ci_e_IP(int c) { int t = gi; if (gpi[2] == *hpi) gi3 = 1; }
void ci_e_II(int c) { int t = gi; if (gpi[2] == hpi[2]) gi3 = 1; }
void ci_e_IA(int c) { int t = gi; if (gpi[2] == hps->a[c]) gi3 = 1; }
void ci_e_IY(int c) { int t = gi; if (gpi[2] == hia[t]) gi3 = 1; }
void ci_e_IZ(int c) { int t = gi; if (gpi[2] == (int)hc) gi3 = 1; }
void ci_e_IU(int c) { int t = gi; if (gpi[2] == (int)huc) gi3 = 1; }
void ci_e_IF(int c) { int t = gi; if (gpi[2] == hri(hi)) gi3 = 1; }
void ci_e_AK(int c) { int t = gi; if (gps->a[c] == 7) gi3 = 1; }
void ci_e_AG(int c) { int t = gi; if (gps->a[c] == hi) gi3 = 1; }
void ci_e_AP(int c) { int t = gi; if (gps->a[c] == *hpi) gi3 = 1; }
void ci_e_AI(int c) { int t = gi; if (gps->a[c] == hpi[2]) gi3 = 1; }
void ci_e_AA(int c) { int t = gi; if (gps->a[c] == hps->a[c]) gi3 = 1; }
void ci_e_AY(int c) { int t = gi; if (gps->a[c] == hia[t]) gi3 = 1; }
void ci_e_AZ(int c) { int t = gi; if (gps->a[c] == (int)hc) gi3 = 1; }
void ci_e_AU(int c) { int t = gi; if (gps->a[c] == (int)huc) gi3 = 1; }
void ci_e_AF(int c) { int t = gi; if (gps->a[c] == hri(hi)) gi3 = 1; }
void ci_e_YK(int c) { int t = gi; if (gia[t] == 7) gi3 = 1; }
void ci_e_YG(int c) { int t = gi; if (gia[t] == hi) gi3 = 1; }
void ci_e_YP(int c) { int t = gi; if (gia[t] == *hpi) gi3 = 1; }
void ci_e_YI(int c) { int t = gi; if (gia[t] == hpi[2]) gi3 = 1; }
void ci_e_YA(int c) { int t = gi; if (gia[t] == hps->a[c]) gi3 = 1; }
void ci_e_YY(int c) { int t = gi; if (gia[t] == hia[t]) gi3 = 1; }
void ci_e_YZ(int c) { int t = gi; if (gia[t] == (int)hc) gi3 = 1; }
void ci_e_YU(int c) { int t = gi; if (gia[t] == (int)huc) gi3 = 1; }
void ci_e_YF(int c) { int t = gi; if (gia[t] == hri(hi)) gi3 = 1; }
void ci_e_ZK(int c) { int t = gi; if ((int)gc == 7) gi3 = 1; }
void ci_e_ZG(int c) { int t = gi; if ((int)gc == hi) gi3 = 1; }
void ci_e_ZP(int c) { int t = gi; if ((int)gc == *hpi) gi3 = 1; }
void ci_e_ZI(int c) { int t = gi; if ((int)gc == hpi[2]) gi3 = 1; }
void ci_e_ZA(int c) { int t = gi; if ((int)gc == hps->a[c]) gi3 = 1; }
void ci_e_ZY(int c) { int t = gi; if ((int)gc == hia[t]) gi3 = 1; }
void ci_e_ZZ(int c) { int t = gi; if ((int)gc == (int)hc) gi3 = 1; }
void ci_e_ZU(int c) { int t = gi; if ((int)gc == (int)huc) gi3 = 1; }
void ci_e_ZF(int c) { int t = gi; if ((int)gc == hri(hi)) gi3 = 1; }
void ci_e_UK(int c) { int t = gi; if ((int)guc == 7) gi3 = 1; }
void ci_e_UG(int c) { int t = gi; if ((int)guc == hi) gi3 = 1; }
void ci_e_UP(int c) { int t = gi; if ((int)guc == *hpi) gi3 = 1; }
void ci_e_UI(int c) { int t = gi; if ((int)guc == hpi[2]) gi3 = 1; }
void ci_e_UA(int c) { int t = gi; if ((int)guc == hps->a[c]) gi3 = 1; }
void ci_e_UY(int c) { int t = gi; if ((int)guc == hia[t]) gi3 = 1; }
void ci_e_UZ(int c) { int t = gi; if ((int)guc == (int)hc) gi3 = 1; }
void ci_e_UU(int c) { int t = gi; if ((int)guc == (int)huc) gi3 = 1; }
void ci_e_UF(int c) { int t = gi; if ((int)guc == hri(hi)) gi3 = 1; }
void ci_e_FK(int c) { int t = gi; if (gri(gi) == 7) gi3 = 1; }
void ci_e_FG(int c) { int t = gi; if (gri(gi) == hi) gi3 = 1; }
void ci_e_FP(int c) { int t = gi; if (gri(gi) == *hpi) gi3 = 1; }
void ci_e_FI(int c) { int t = gi; if (gri(gi) == hpi[2]) gi3 = 1; }
void ci_e_FA(int c) { int t = gi; if (gri(gi) == hps->a[c]) gi3 = 1; }
void ci_e_FY(int c) { int t = gi; if (gri(gi) == hia[t]) gi3 = 1; }
void ci_e_FZ(int c) { int t = gi; if (gri(gi) == (int)hc) gi3 = 1; }
void ci_e_FU(int c) { int t = gi; if (gri(gi) == (int)huc) gi3 = 1; }
void ci_e_FF(int c) { int t = gi; if (gri(gi) == hri(hi)) gi3 = 1; }

void cl_l_KG(int c) { int t = gi; if (7L < hl) gi3 = 1; }
void cl_l_KP(int c) { int t = gi; if (7L < *hpl) gi3 = 1; }
void cl_l_KI(int c) { int t = gi; if (7L < hpl[2]) gi3 = 1; }
void cl_l_KY(int c) { int t = gi; if (7L < hla[t]) gi3 = 1; }
void cl_l_KZ(int c) { int t = gi; if (7L < (long)hc) gi3 = 1; }
void cl_l_KW(int c) { int t = gi; if (7L < (long)hi) gi3 = 1; }
void cl_l_KV(int c) { int t = gi; if (7L < (long)hp[0]) gi3 = 1; }
void cl_l_KU(int c) { int t = gi; if (7L < (unsigned long)huc) gi3 = 1; }
void cl_l_KS(int c) { int t = gi; if (7L < (hla[c] >> 16)) gi3 = 1; }
void cl_l_KF(int c) { int t = gi; if (7L < hrl(hla[c])) gi3 = 1; }
void cl_l_KB(int c) { int t = gi; if (7L < (*hpl & 3)) gi3 = 1; }
void cl_l_GK(int c) { int t = gi; if (gl < 7L) gi3 = 1; }
void cl_l_GG(int c) { int t = gi; if (gl < hl) gi3 = 1; }
void cl_l_GP(int c) { int t = gi; if (gl < *hpl) gi3 = 1; }
void cl_l_GI(int c) { int t = gi; if (gl < hpl[2]) gi3 = 1; }
void cl_l_GY(int c) { int t = gi; if (gl < hla[t]) gi3 = 1; }
void cl_l_GZ(int c) { int t = gi; if (gl < (long)hc) gi3 = 1; }
void cl_l_GW(int c) { int t = gi; if (gl < (long)hi) gi3 = 1; }
void cl_l_GV(int c) { int t = gi; if (gl < (long)hp[0]) gi3 = 1; }
void cl_l_GU(int c) { int t = gi; if (gl < (unsigned long)huc) gi3 = 1; }
void cl_l_GS(int c) { int t = gi; if (gl < (hla[c] >> 16)) gi3 = 1; }
void cl_l_GF(int c) { int t = gi; if (gl < hrl(hla[c])) gi3 = 1; }
void cl_l_GB(int c) { int t = gi; if (gl < (*hpl & 3)) gi3 = 1; }
void cl_l_PK(int c) { int t = gi; if (*gpl < 7L) gi3 = 1; }
void cl_l_PG(int c) { int t = gi; if (*gpl < hl) gi3 = 1; }
void cl_l_PP(int c) { int t = gi; if (*gpl < *hpl) gi3 = 1; }
void cl_l_PI(int c) { int t = gi; if (*gpl < hpl[2]) gi3 = 1; }
void cl_l_PY(int c) { int t = gi; if (*gpl < hla[t]) gi3 = 1; }
void cl_l_PZ(int c) { int t = gi; if (*gpl < (long)hc) gi3 = 1; }
void cl_l_PW(int c) { int t = gi; if (*gpl < (long)hi) gi3 = 1; }
void cl_l_PV(int c) { int t = gi; if (*gpl < (long)hp[0]) gi3 = 1; }
void cl_l_PU(int c) { int t = gi; if (*gpl < (unsigned long)huc) gi3 = 1; }
void cl_l_PS(int c) { int t = gi; if (*gpl < (hla[c] >> 16)) gi3 = 1; }
void cl_l_PF(int c) { int t = gi; if (*gpl < hrl(hla[c])) gi3 = 1; }
void cl_l_PB(int c) { int t = gi; if (*gpl < (*hpl & 3)) gi3 = 1; }
void cl_l_IK(int c) { int t = gi; if (gpl[2] < 7L) gi3 = 1; }
void cl_l_IG(int c) { int t = gi; if (gpl[2] < hl) gi3 = 1; }
void cl_l_IP(int c) { int t = gi; if (gpl[2] < *hpl) gi3 = 1; }
void cl_l_II(int c) { int t = gi; if (gpl[2] < hpl[2]) gi3 = 1; }
void cl_l_IY(int c) { int t = gi; if (gpl[2] < hla[t]) gi3 = 1; }
void cl_l_IZ(int c) { int t = gi; if (gpl[2] < (long)hc) gi3 = 1; }
void cl_l_IW(int c) { int t = gi; if (gpl[2] < (long)hi) gi3 = 1; }
void cl_l_IV(int c) { int t = gi; if (gpl[2] < (long)hp[0]) gi3 = 1; }
void cl_l_IU(int c) { int t = gi; if (gpl[2] < (unsigned long)huc) gi3 = 1; }
void cl_l_IS(int c) { int t = gi; if (gpl[2] < (hla[c] >> 16)) gi3 = 1; }
void cl_l_IF(int c) { int t = gi; if (gpl[2] < hrl(hla[c])) gi3 = 1; }
void cl_l_IB(int c) { int t = gi; if (gpl[2] < (*hpl & 3)) gi3 = 1; }
void cl_l_YK(int c) { int t = gi; if (gla[t] < 7L) gi3 = 1; }
void cl_l_YG(int c) { int t = gi; if (gla[t] < hl) gi3 = 1; }
void cl_l_YP(int c) { int t = gi; if (gla[t] < *hpl) gi3 = 1; }
void cl_l_YI(int c) { int t = gi; if (gla[t] < hpl[2]) gi3 = 1; }
void cl_l_YY(int c) { int t = gi; if (gla[t] < hla[t]) gi3 = 1; }
void cl_l_YZ(int c) { int t = gi; if (gla[t] < (long)hc) gi3 = 1; }
void cl_l_YW(int c) { int t = gi; if (gla[t] < (long)hi) gi3 = 1; }
void cl_l_YV(int c) { int t = gi; if (gla[t] < (long)hp[0]) gi3 = 1; }
void cl_l_YU(int c) { int t = gi; if (gla[t] < (unsigned long)huc) gi3 = 1; }
void cl_l_YS(int c) { int t = gi; if (gla[t] < (hla[c] >> 16)) gi3 = 1; }
void cl_l_YF(int c) { int t = gi; if (gla[t] < hrl(hla[c])) gi3 = 1; }
void cl_l_YB(int c) { int t = gi; if (gla[t] < (*hpl & 3)) gi3 = 1; }
void cl_l_ZK(int c) { int t = gi; if ((long)gc < 7L) gi3 = 1; }
void cl_l_ZG(int c) { int t = gi; if ((long)gc < hl) gi3 = 1; }
void cl_l_ZP(int c) { int t = gi; if ((long)gc < *hpl) gi3 = 1; }
void cl_l_ZI(int c) { int t = gi; if ((long)gc < hpl[2]) gi3 = 1; }
void cl_l_ZY(int c) { int t = gi; if ((long)gc < hla[t]) gi3 = 1; }
void cl_l_ZZ(int c) { int t = gi; if ((long)gc < (long)hc) gi3 = 1; }
void cl_l_ZW(int c) { int t = gi; if ((long)gc < (long)hi) gi3 = 1; }
void cl_l_ZV(int c) { int t = gi; if ((long)gc < (long)hp[0]) gi3 = 1; }
void cl_l_ZU(int c) { int t = gi; if ((long)gc < (unsigned long)huc) gi3 = 1; }
void cl_l_ZS(int c) { int t = gi; if ((long)gc < (hla[c] >> 16)) gi3 = 1; }
void cl_l_ZF(int c) { int t = gi; if ((long)gc < hrl(hla[c])) gi3 = 1; }
void cl_l_ZB(int c) { int t = gi; if ((long)gc < (*hpl & 3)) gi3 = 1; }
void cl_l_WK(int c) { int t = gi; if ((long)gi < 7L) gi3 = 1; }
void cl_l_WG(int c) { int t = gi; if ((long)gi < hl) gi3 = 1; }
void cl_l_WP(int c) { int t = gi; if ((long)gi < *hpl) gi3 = 1; }
void cl_l_WI(int c) { int t = gi; if ((long)gi < hpl[2]) gi3 = 1; }
void cl_l_WY(int c) { int t = gi; if ((long)gi < hla[t]) gi3 = 1; }
void cl_l_WZ(int c) { int t = gi; if ((long)gi < (long)hc) gi3 = 1; }
void cl_l_WW(int c) { int t = gi; if ((long)gi < (long)hi) gi3 = 1; }
void cl_l_WV(int c) { int t = gi; if ((long)gi < (long)hp[0]) gi3 = 1; }
void cl_l_WU(int c) { int t = gi; if ((long)gi < (unsigned long)huc) gi3 = 1; }
void cl_l_WS(int c) { int t = gi; if ((long)gi < (hla[c] >> 16)) gi3 = 1; }
void cl_l_WF(int c) { int t = gi; if ((long)gi < hrl(hla[c])) gi3 = 1; }
void cl_l_WB(int c) { int t = gi; if ((long)gi < (*hpl & 3)) gi3 = 1; }
void cl_l_VK(int c) { int t = gi; if ((long)gp[0] < 7L) gi3 = 1; }
void cl_l_VG(int c) { int t = gi; if ((long)gp[0] < hl) gi3 = 1; }
void cl_l_VP(int c) { int t = gi; if ((long)gp[0] < *hpl) gi3 = 1; }
void cl_l_VI(int c) { int t = gi; if ((long)gp[0] < hpl[2]) gi3 = 1; }
void cl_l_VY(int c) { int t = gi; if ((long)gp[0] < hla[t]) gi3 = 1; }
void cl_l_VZ(int c) { int t = gi; if ((long)gp[0] < (long)hc) gi3 = 1; }
void cl_l_VW(int c) { int t = gi; if ((long)gp[0] < (long)hi) gi3 = 1; }
void cl_l_VV(int c) { int t = gi; if ((long)gp[0] < (long)hp[0]) gi3 = 1; }
void cl_l_VU(int c) { int t = gi; if ((long)gp[0] < (unsigned long)huc) gi3 = 1; }
void cl_l_VS(int c) { int t = gi; if ((long)gp[0] < (hla[c] >> 16)) gi3 = 1; }
void cl_l_VF(int c) { int t = gi; if ((long)gp[0] < hrl(hla[c])) gi3 = 1; }
void cl_l_VB(int c) { int t = gi; if ((long)gp[0] < (*hpl & 3)) gi3 = 1; }
void cl_l_UK(int c) { int t = gi; if ((unsigned long)guc < 7L) gi3 = 1; }
void cl_l_UG(int c) { int t = gi; if ((unsigned long)guc < hl) gi3 = 1; }
void cl_l_UP(int c) { int t = gi; if ((unsigned long)guc < *hpl) gi3 = 1; }
void cl_l_UI(int c) { int t = gi; if ((unsigned long)guc < hpl[2]) gi3 = 1; }
void cl_l_UY(int c) { int t = gi; if ((unsigned long)guc < hla[t]) gi3 = 1; }
void cl_l_UZ(int c) { int t = gi; if ((unsigned long)guc < (long)hc) gi3 = 1; }
void cl_l_UW(int c) { int t = gi; if ((unsigned long)guc < (long)hi) gi3 = 1; }
void cl_l_UV(int c) { int t = gi; if ((unsigned long)guc < (long)hp[0]) gi3 = 1; }
void cl_l_UU(int c) { int t = gi; if ((unsigned long)guc < (unsigned long)huc) gi3 = 1; }
void cl_l_US(int c) { int t = gi; if ((unsigned long)guc < (hla[c] >> 16)) gi3 = 1; }
void cl_l_UF(int c) { int t = gi; if ((unsigned long)guc < hrl(hla[c])) gi3 = 1; }
void cl_l_UB(int c) { int t = gi; if ((unsigned long)guc < (*hpl & 3)) gi3 = 1; }
void cl_l_SK(int c) { int t = gi; if ((gla[c] >> 16) < 7L) gi3 = 1; }
void cl_l_SG(int c) { int t = gi; if ((gla[c] >> 16) < hl) gi3 = 1; }
void cl_l_SP(int c) { int t = gi; if ((gla[c] >> 16) < *hpl) gi3 = 1; }
void cl_l_SI(int c) { int t = gi; if ((gla[c] >> 16) < hpl[2]) gi3 = 1; }
void cl_l_SY(int c) { int t = gi; if ((gla[c] >> 16) < hla[t]) gi3 = 1; }
void cl_l_SZ(int c) { int t = gi; if ((gla[c] >> 16) < (long)hc) gi3 = 1; }
void cl_l_SW(int c) { int t = gi; if ((gla[c] >> 16) < (long)hi) gi3 = 1; }
void cl_l_SV(int c) { int t = gi; if ((gla[c] >> 16) < (long)hp[0]) gi3 = 1; }
void cl_l_SU(int c) { int t = gi; if ((gla[c] >> 16) < (unsigned long)huc) gi3 = 1; }
void cl_l_SS(int c) { int t = gi; if ((gla[c] >> 16) < (hla[c] >> 16)) gi3 = 1; }
void cl_l_SF(int c) { int t = gi; if ((gla[c] >> 16) < hrl(hla[c])) gi3 = 1; }
void cl_l_SB(int c) { int t = gi; if ((gla[c] >> 16) < (*hpl & 3)) gi3 = 1; }
void cl_l_FK(int c) { int t = gi; if (grl(gla[c]) < 7L) gi3 = 1; }
void cl_l_FG(int c) { int t = gi; if (grl(gla[c]) < hl) gi3 = 1; }
void cl_l_FP(int c) { int t = gi; if (grl(gla[c]) < *hpl) gi3 = 1; }
void cl_l_FI(int c) { int t = gi; if (grl(gla[c]) < hpl[2]) gi3 = 1; }
void cl_l_FY(int c) { int t = gi; if (grl(gla[c]) < hla[t]) gi3 = 1; }
void cl_l_FZ(int c) { int t = gi; if (grl(gla[c]) < (long)hc) gi3 = 1; }
void cl_l_FW(int c) { int t = gi; if (grl(gla[c]) < (long)hi) gi3 = 1; }
void cl_l_FV(int c) { int t = gi; if (grl(gla[c]) < (long)hp[0]) gi3 = 1; }
void cl_l_FU(int c) { int t = gi; if (grl(gla[c]) < (unsigned long)huc) gi3 = 1; }
void cl_l_FS(int c) { int t = gi; if (grl(gla[c]) < (hla[c] >> 16)) gi3 = 1; }
void cl_l_FF(int c) { int t = gi; if (grl(gla[c]) < hrl(hla[c])) gi3 = 1; }
void cl_l_FB(int c) { int t = gi; if (grl(gla[c]) < (*hpl & 3)) gi3 = 1; }
void cl_l_BK(int c) { int t = gi; if ((*gpl & 3) < 7L) gi3 = 1; }
void cl_l_BG(int c) { int t = gi; if ((*gpl & 3) < hl) gi3 = 1; }
void cl_l_BP(int c) { int t = gi; if ((*gpl & 3) < *hpl) gi3 = 1; }
void cl_l_BI(int c) { int t = gi; if ((*gpl & 3) < hpl[2]) gi3 = 1; }
void cl_l_BY(int c) { int t = gi; if ((*gpl & 3) < hla[t]) gi3 = 1; }
void cl_l_BZ(int c) { int t = gi; if ((*gpl & 3) < (long)hc) gi3 = 1; }
void cl_l_BW(int c) { int t = gi; if ((*gpl & 3) < (long)hi) gi3 = 1; }
void cl_l_BV(int c) { int t = gi; if ((*gpl & 3) < (long)hp[0]) gi3 = 1; }
void cl_l_BU(int c) { int t = gi; if ((*gpl & 3) < (unsigned long)huc) gi3 = 1; }
void cl_l_BS(int c) { int t = gi; if ((*gpl & 3) < (hla[c] >> 16)) gi3 = 1; }
void cl_l_BF(int c) { int t = gi; if ((*gpl & 3) < hrl(hla[c])) gi3 = 1; }
void cl_l_BB(int c) { int t = gi; if ((*gpl & 3) < (*hpl & 3)) gi3 = 1; }

void cl_e_KG(int c) { int t = gi; if (7L == hl) gi3 = 1; }
void cl_e_KP(int c) { int t = gi; if (7L == *hpl) gi3 = 1; }
void cl_e_KI(int c) { int t = gi; if (7L == hpl[2]) gi3 = 1; }
void cl_e_KY(int c) { int t = gi; if (7L == hla[t]) gi3 = 1; }
void cl_e_KZ(int c) { int t = gi; if (7L == (long)hc) gi3 = 1; }
void cl_e_KW(int c) { int t = gi; if (7L == (long)hi) gi3 = 1; }
void cl_e_KV(int c) { int t = gi; if (7L == (long)hp[0]) gi3 = 1; }
void cl_e_KU(int c) { int t = gi; if (7L == (unsigned long)huc) gi3 = 1; }
void cl_e_KS(int c) { int t = gi; if (7L == (hla[c] >> 16)) gi3 = 1; }
void cl_e_KF(int c) { int t = gi; if (7L == hrl(hla[c])) gi3 = 1; }
void cl_e_KB(int c) { int t = gi; if (7L == (*hpl & 3)) gi3 = 1; }
void cl_e_GK(int c) { int t = gi; if (gl == 7L) gi3 = 1; }
void cl_e_GG(int c) { int t = gi; if (gl == hl) gi3 = 1; }
void cl_e_GP(int c) { int t = gi; if (gl == *hpl) gi3 = 1; }
void cl_e_GI(int c) { int t = gi; if (gl == hpl[2]) gi3 = 1; }
void cl_e_GY(int c) { int t = gi; if (gl == hla[t]) gi3 = 1; }
void cl_e_GZ(int c) { int t = gi; if (gl == (long)hc) gi3 = 1; }
void cl_e_GW(int c) { int t = gi; if (gl == (long)hi) gi3 = 1; }
void cl_e_GV(int c) { int t = gi; if (gl == (long)hp[0]) gi3 = 1; }
void cl_e_GU(int c) { int t = gi; if (gl == (unsigned long)huc) gi3 = 1; }
void cl_e_GS(int c) { int t = gi; if (gl == (hla[c] >> 16)) gi3 = 1; }
void cl_e_GF(int c) { int t = gi; if (gl == hrl(hla[c])) gi3 = 1; }
void cl_e_GB(int c) { int t = gi; if (gl == (*hpl & 3)) gi3 = 1; }
void cl_e_PK(int c) { int t = gi; if (*gpl == 7L) gi3 = 1; }
void cl_e_PG(int c) { int t = gi; if (*gpl == hl) gi3 = 1; }
void cl_e_PP(int c) { int t = gi; if (*gpl == *hpl) gi3 = 1; }
void cl_e_PI(int c) { int t = gi; if (*gpl == hpl[2]) gi3 = 1; }
void cl_e_PY(int c) { int t = gi; if (*gpl == hla[t]) gi3 = 1; }
void cl_e_PZ(int c) { int t = gi; if (*gpl == (long)hc) gi3 = 1; }
void cl_e_PW(int c) { int t = gi; if (*gpl == (long)hi) gi3 = 1; }
void cl_e_PV(int c) { int t = gi; if (*gpl == (long)hp[0]) gi3 = 1; }
void cl_e_PU(int c) { int t = gi; if (*gpl == (unsigned long)huc) gi3 = 1; }
void cl_e_PS(int c) { int t = gi; if (*gpl == (hla[c] >> 16)) gi3 = 1; }
void cl_e_PF(int c) { int t = gi; if (*gpl == hrl(hla[c])) gi3 = 1; }
void cl_e_PB(int c) { int t = gi; if (*gpl == (*hpl & 3)) gi3 = 1; }
void cl_e_IK(int c) { int t = gi; if (gpl[2] == 7L) gi3 = 1; }
void cl_e_IG(int c) { int t = gi; if (gpl[2] == hl) gi3 = 1; }
void cl_e_IP(int c) { int t = gi; if (gpl[2] == *hpl) gi3 = 1; }
void cl_e_II(int c) { int t = gi; if (gpl[2] == hpl[2]) gi3 = 1; }
void cl_e_IY(int c) { int t = gi; if (gpl[2] == hla[t]) gi3 = 1; }
void cl_e_IZ(int c) { int t = gi; if (gpl[2] == (long)hc) gi3 = 1; }
void cl_e_IW(int c) { int t = gi; if (gpl[2] == (long)hi) gi3 = 1; }
void cl_e_IV(int c) { int t = gi; if (gpl[2] == (long)hp[0]) gi3 = 1; }
void cl_e_IU(int c) { int t = gi; if (gpl[2] == (unsigned long)huc) gi3 = 1; }
void cl_e_IS(int c) { int t = gi; if (gpl[2] == (hla[c] >> 16)) gi3 = 1; }
void cl_e_IF(int c) { int t = gi; if (gpl[2] == hrl(hla[c])) gi3 = 1; }
void cl_e_IB(int c) { int t = gi; if (gpl[2] == (*hpl & 3)) gi3 = 1; }
void cl_e_YK(int c) { int t = gi; if (gla[t] == 7L) gi3 = 1; }
void cl_e_YG(int c) { int t = gi; if (gla[t] == hl) gi3 = 1; }
void cl_e_YP(int c) { int t = gi; if (gla[t] == *hpl) gi3 = 1; }
void cl_e_YI(int c) { int t = gi; if (gla[t] == hpl[2]) gi3 = 1; }
void cl_e_YY(int c) { int t = gi; if (gla[t] == hla[t]) gi3 = 1; }
void cl_e_YZ(int c) { int t = gi; if (gla[t] == (long)hc) gi3 = 1; }
void cl_e_YW(int c) { int t = gi; if (gla[t] == (long)hi) gi3 = 1; }
void cl_e_YV(int c) { int t = gi; if (gla[t] == (long)hp[0]) gi3 = 1; }
void cl_e_YU(int c) { int t = gi; if (gla[t] == (unsigned long)huc) gi3 = 1; }
void cl_e_YS(int c) { int t = gi; if (gla[t] == (hla[c] >> 16)) gi3 = 1; }
void cl_e_YF(int c) { int t = gi; if (gla[t] == hrl(hla[c])) gi3 = 1; }
void cl_e_YB(int c) { int t = gi; if (gla[t] == (*hpl & 3)) gi3 = 1; }
void cl_e_ZK(int c) { int t = gi; if ((long)gc == 7L) gi3 = 1; }
void cl_e_ZG(int c) { int t = gi; if ((long)gc == hl) gi3 = 1; }
void cl_e_ZP(int c) { int t = gi; if ((long)gc == *hpl) gi3 = 1; }
void cl_e_ZI(int c) { int t = gi; if ((long)gc == hpl[2]) gi3 = 1; }
void cl_e_ZY(int c) { int t = gi; if ((long)gc == hla[t]) gi3 = 1; }
void cl_e_ZZ(int c) { int t = gi; if ((long)gc == (long)hc) gi3 = 1; }
void cl_e_ZW(int c) { int t = gi; if ((long)gc == (long)hi) gi3 = 1; }
void cl_e_ZV(int c) { int t = gi; if ((long)gc == (long)hp[0]) gi3 = 1; }
void cl_e_ZU(int c) { int t = gi; if ((long)gc == (unsigned long)huc) gi3 = 1; }
void cl_e_ZS(int c) { int t = gi; if ((long)gc == (hla[c] >> 16)) gi3 = 1; }
void cl_e_ZF(int c) { int t = gi; if ((long)gc == hrl(hla[c])) gi3 = 1; }
void cl_e_ZB(int c) { int t = gi; if ((long)gc == (*hpl & 3)) gi3 = 1; }
void cl_e_WK(int c) { int t = gi; if ((long)gi == 7L) gi3 = 1; }
void cl_e_WG(int c) { int t = gi; if ((long)gi == hl) gi3 = 1; }
void cl_e_WP(int c) { int t = gi; if ((long)gi == *hpl) gi3 = 1; }
void cl_e_WI(int c) { int t = gi; if ((long)gi == hpl[2]) gi3 = 1; }
void cl_e_WY(int c) { int t = gi; if ((long)gi == hla[t]) gi3 = 1; }
void cl_e_WZ(int c) { int t = gi; if ((long)gi == (long)hc) gi3 = 1; }
void cl_e_WW(int c) { int t = gi; if ((long)gi == (long)hi) gi3 = 1; }
void cl_e_WV(int c) { int t = gi; if ((long)gi == (long)hp[0]) gi3 = 1; }
void cl_e_WU(int c) { int t = gi; if ((long)gi == (unsigned long)huc) gi3 = 1; }
void cl_e_WS(int c) { int t = gi; if ((long)gi == (hla[c] >> 16)) gi3 = 1; }
void cl_e_WF(int c) { int t = gi; if ((long)gi == hrl(hla[c])) gi3 = 1; }
void cl_e_WB(int c) { int t = gi; if ((long)gi == (*hpl & 3)) gi3 = 1; }
void cl_e_VK(int c) { int t = gi; if ((long)gp[0] == 7L) gi3 = 1; }
void cl_e_VG(int c) { int t = gi; if ((long)gp[0] == hl) gi3 = 1; }
void cl_e_VP(int c) { int t = gi; if ((long)gp[0] == *hpl) gi3 = 1; }
void cl_e_VI(int c) { int t = gi; if ((long)gp[0] == hpl[2]) gi3 = 1; }
void cl_e_VY(int c) { int t = gi; if ((long)gp[0] == hla[t]) gi3 = 1; }
void cl_e_VZ(int c) { int t = gi; if ((long)gp[0] == (long)hc) gi3 = 1; }
void cl_e_VW(int c) { int t = gi; if ((long)gp[0] == (long)hi) gi3 = 1; }
void cl_e_VV(int c) { int t = gi; if ((long)gp[0] == (long)hp[0]) gi3 = 1; }
void cl_e_VU(int c) { int t = gi; if ((long)gp[0] == (unsigned long)huc) gi3 = 1; }
void cl_e_VS(int c) { int t = gi; if ((long)gp[0] == (hla[c] >> 16)) gi3 = 1; }
void cl_e_VF(int c) { int t = gi; if ((long)gp[0] == hrl(hla[c])) gi3 = 1; }
void cl_e_VB(int c) { int t = gi; if ((long)gp[0] == (*hpl & 3)) gi3 = 1; }
void cl_e_UK(int c) { int t = gi; if ((unsigned long)guc == 7L) gi3 = 1; }
void cl_e_UG(int c) { int t = gi; if ((unsigned long)guc == hl) gi3 = 1; }
void cl_e_UP(int c) { int t = gi; if ((unsigned long)guc == *hpl) gi3 = 1; }
void cl_e_UI(int c) { int t = gi; if ((unsigned long)guc == hpl[2]) gi3 = 1; }
void cl_e_UY(int c) { int t = gi; if ((unsigned long)guc == hla[t]) gi3 = 1; }
void cl_e_UZ(int c) { int t = gi; if ((unsigned long)guc == (long)hc) gi3 = 1; }
void cl_e_UW(int c) { int t = gi; if ((unsigned long)guc == (long)hi) gi3 = 1; }
void cl_e_UV(int c) { int t = gi; if ((unsigned long)guc == (long)hp[0]) gi3 = 1; }
void cl_e_UU(int c) { int t = gi; if ((unsigned long)guc == (unsigned long)huc) gi3 = 1; }
void cl_e_US(int c) { int t = gi; if ((unsigned long)guc == (hla[c] >> 16)) gi3 = 1; }
void cl_e_UF(int c) { int t = gi; if ((unsigned long)guc == hrl(hla[c])) gi3 = 1; }
void cl_e_UB(int c) { int t = gi; if ((unsigned long)guc == (*hpl & 3)) gi3 = 1; }
void cl_e_SK(int c) { int t = gi; if ((gla[c] >> 16) == 7L) gi3 = 1; }
void cl_e_SG(int c) { int t = gi; if ((gla[c] >> 16) == hl) gi3 = 1; }
void cl_e_SP(int c) { int t = gi; if ((gla[c] >> 16) == *hpl) gi3 = 1; }
void cl_e_SI(int c) { int t = gi; if ((gla[c] >> 16) == hpl[2]) gi3 = 1; }
void cl_e_SY(int c) { int t = gi; if ((gla[c] >> 16) == hla[t]) gi3 = 1; }
void cl_e_SZ(int c) { int t = gi; if ((gla[c] >> 16) == (long)hc) gi3 = 1; }
void cl_e_SW(int c) { int t = gi; if ((gla[c] >> 16) == (long)hi) gi3 = 1; }
void cl_e_SV(int c) { int t = gi; if ((gla[c] >> 16) == (long)hp[0]) gi3 = 1; }
void cl_e_SU(int c) { int t = gi; if ((gla[c] >> 16) == (unsigned long)huc) gi3 = 1; }
void cl_e_SS(int c) { int t = gi; if ((gla[c] >> 16) == (hla[c] >> 16)) gi3 = 1; }
void cl_e_SF(int c) { int t = gi; if ((gla[c] >> 16) == hrl(hla[c])) gi3 = 1; }
void cl_e_SB(int c) { int t = gi; if ((gla[c] >> 16) == (*hpl & 3)) gi3 = 1; }
void cl_e_FK(int c) { int t = gi; if (grl(gla[c]) == 7L) gi3 = 1; }
void cl_e_FG(int c) { int t = gi; if (grl(gla[c]) == hl) gi3 = 1; }
void cl_e_FP(int c) { int t = gi; if (grl(gla[c]) == *hpl) gi3 = 1; }
void cl_e_FI(int c) { int t = gi; if (grl(gla[c]) == hpl[2]) gi3 = 1; }
void cl_e_FY(int c) { int t = gi; if (grl(gla[c]) == hla[t]) gi3 = 1; }
void cl_e_FZ(int c) { int t = gi; if (grl(gla[c]) == (long)hc) gi3 = 1; }
void cl_e_FW(int c) { int t = gi; if (grl(gla[c]) == (long)hi) gi3 = 1; }
void cl_e_FV(int c) { int t = gi; if (grl(gla[c]) == (long)hp[0]) gi3 = 1; }
void cl_e_FU(int c) { int t = gi; if (grl(gla[c]) == (unsigned long)huc) gi3 = 1; }
void cl_e_FS(int c) { int t = gi; if (grl(gla[c]) == (hla[c] >> 16)) gi3 = 1; }
void cl_e_FF(int c) { int t = gi; if (grl(gla[c]) == hrl(hla[c])) gi3 = 1; }
void cl_e_FB(int c) { int t = gi; if (grl(gla[c]) == (*hpl & 3)) gi3 = 1; }
void cl_e_BK(int c) { int t = gi; if ((*gpl & 3) == 7L) gi3 = 1; }
void cl_e_BG(int c) { int t = gi; if ((*gpl & 3) == hl) gi3 = 1; }
void cl_e_BP(int c) { int t = gi; if ((*gpl & 3) == *hpl) gi3 = 1; }
void cl_e_BI(int c) { int t = gi; if ((*gpl & 3) == hpl[2]) gi3 = 1; }
void cl_e_BY(int c) { int t = gi; if ((*gpl & 3) == hla[t]) gi3 = 1; }
void cl_e_BZ(int c) { int t = gi; if ((*gpl & 3) == (long)hc) gi3 = 1; }
void cl_e_BW(int c) { int t = gi; if ((*gpl & 3) == (long)hi) gi3 = 1; }
void cl_e_BV(int c) { int t = gi; if ((*gpl & 3) == (long)hp[0]) gi3 = 1; }
void cl_e_BU(int c) { int t = gi; if ((*gpl & 3) == (unsigned long)huc) gi3 = 1; }
void cl_e_BS(int c) { int t = gi; if ((*gpl & 3) == (hla[c] >> 16)) gi3 = 1; }
void cl_e_BF(int c) { int t = gi; if ((*gpl & 3) == hrl(hla[c])) gi3 = 1; }
void cl_e_BB(int c) { int t = gi; if ((*gpl & 3) == (*hpl & 3)) gi3 = 1; }

void cc_l_KG(int c) { int t = gi; if (7 < hc) gi3 = 1; }
void cc_l_KP(int c) { int t = gi; if (7 < *hp) gi3 = 1; }
void cc_l_KI(int c) { int t = gi; if (7 < hp[1]) gi3 = 1; }
void cc_l_KX(int c) { int t = gi; if (7 < hca[c]) gi3 = 1; }
void cc_l_KY(int c) { int t = gi; if (7 < hca[t]) gi3 = 1; }
void cc_l_KW(int c) { int t = gi; if (7 < (unsigned char)hul) gi3 = 1; }
void cc_l_KF(int c) { int t = gi; if (7 < hrc(hi)) gi3 = 1; }
void cc_l_GK(int c) { int t = gi; if (gc < 7) gi3 = 1; }
void cc_l_GG(int c) { int t = gi; if (gc < hc) gi3 = 1; }
void cc_l_GP(int c) { int t = gi; if (gc < *hp) gi3 = 1; }
void cc_l_GI(int c) { int t = gi; if (gc < hp[1]) gi3 = 1; }
void cc_l_GX(int c) { int t = gi; if (gc < hca[c]) gi3 = 1; }
void cc_l_GY(int c) { int t = gi; if (gc < hca[t]) gi3 = 1; }
void cc_l_GW(int c) { int t = gi; if (gc < (unsigned char)hul) gi3 = 1; }
void cc_l_GF(int c) { int t = gi; if (gc < hrc(hi)) gi3 = 1; }
void cc_l_PK(int c) { int t = gi; if (*gp < 7) gi3 = 1; }
void cc_l_PG(int c) { int t = gi; if (*gp < hc) gi3 = 1; }
void cc_l_PP(int c) { int t = gi; if (*gp < *hp) gi3 = 1; }
void cc_l_PI(int c) { int t = gi; if (*gp < hp[1]) gi3 = 1; }
void cc_l_PX(int c) { int t = gi; if (*gp < hca[c]) gi3 = 1; }
void cc_l_PY(int c) { int t = gi; if (*gp < hca[t]) gi3 = 1; }
void cc_l_PW(int c) { int t = gi; if (*gp < (unsigned char)hul) gi3 = 1; }
void cc_l_PF(int c) { int t = gi; if (*gp < hrc(hi)) gi3 = 1; }
void cc_l_IK(int c) { int t = gi; if (gp[1] < 7) gi3 = 1; }
void cc_l_IG(int c) { int t = gi; if (gp[1] < hc) gi3 = 1; }
void cc_l_IP(int c) { int t = gi; if (gp[1] < *hp) gi3 = 1; }
void cc_l_II(int c) { int t = gi; if (gp[1] < hp[1]) gi3 = 1; }
void cc_l_IX(int c) { int t = gi; if (gp[1] < hca[c]) gi3 = 1; }
void cc_l_IY(int c) { int t = gi; if (gp[1] < hca[t]) gi3 = 1; }
void cc_l_IW(int c) { int t = gi; if (gp[1] < (unsigned char)hul) gi3 = 1; }
void cc_l_IF(int c) { int t = gi; if (gp[1] < hrc(hi)) gi3 = 1; }
void cc_l_XK(int c) { int t = gi; if (gca[c] < 7) gi3 = 1; }
void cc_l_XG(int c) { int t = gi; if (gca[c] < hc) gi3 = 1; }
void cc_l_XP(int c) { int t = gi; if (gca[c] < *hp) gi3 = 1; }
void cc_l_XI(int c) { int t = gi; if (gca[c] < hp[1]) gi3 = 1; }
void cc_l_XX(int c) { int t = gi; if (gca[c] < hca[c]) gi3 = 1; }
void cc_l_XY(int c) { int t = gi; if (gca[c] < hca[t]) gi3 = 1; }
void cc_l_XW(int c) { int t = gi; if (gca[c] < (unsigned char)hul) gi3 = 1; }
void cc_l_XF(int c) { int t = gi; if (gca[c] < hrc(hi)) gi3 = 1; }
void cc_l_YK(int c) { int t = gi; if (gca[t] < 7) gi3 = 1; }
void cc_l_YG(int c) { int t = gi; if (gca[t] < hc) gi3 = 1; }
void cc_l_YP(int c) { int t = gi; if (gca[t] < *hp) gi3 = 1; }
void cc_l_YI(int c) { int t = gi; if (gca[t] < hp[1]) gi3 = 1; }
void cc_l_YX(int c) { int t = gi; if (gca[t] < hca[c]) gi3 = 1; }
void cc_l_YY(int c) { int t = gi; if (gca[t] < hca[t]) gi3 = 1; }
void cc_l_YW(int c) { int t = gi; if (gca[t] < (unsigned char)hul) gi3 = 1; }
void cc_l_YF(int c) { int t = gi; if (gca[t] < hrc(hi)) gi3 = 1; }
void cc_l_WK(int c) { int t = gi; if ((unsigned char)gul < 7) gi3 = 1; }
void cc_l_WG(int c) { int t = gi; if ((unsigned char)gul < hc) gi3 = 1; }
void cc_l_WP(int c) { int t = gi; if ((unsigned char)gul < *hp) gi3 = 1; }
void cc_l_WI(int c) { int t = gi; if ((unsigned char)gul < hp[1]) gi3 = 1; }
void cc_l_WX(int c) { int t = gi; if ((unsigned char)gul < hca[c]) gi3 = 1; }
void cc_l_WY(int c) { int t = gi; if ((unsigned char)gul < hca[t]) gi3 = 1; }
void cc_l_WW(int c) { int t = gi; if ((unsigned char)gul < (unsigned char)hul) gi3 = 1; }
void cc_l_WF(int c) { int t = gi; if ((unsigned char)gul < hrc(hi)) gi3 = 1; }
void cc_l_FK(int c) { int t = gi; if (grc(gi) < 7) gi3 = 1; }
void cc_l_FG(int c) { int t = gi; if (grc(gi) < hc) gi3 = 1; }
void cc_l_FP(int c) { int t = gi; if (grc(gi) < *hp) gi3 = 1; }
void cc_l_FI(int c) { int t = gi; if (grc(gi) < hp[1]) gi3 = 1; }
void cc_l_FX(int c) { int t = gi; if (grc(gi) < hca[c]) gi3 = 1; }
void cc_l_FY(int c) { int t = gi; if (grc(gi) < hca[t]) gi3 = 1; }
void cc_l_FW(int c) { int t = gi; if (grc(gi) < (unsigned char)hul) gi3 = 1; }
void cc_l_FF(int c) { int t = gi; if (grc(gi) < hrc(hi)) gi3 = 1; }

void cc_e_KG(int c) { int t = gi; if (7 == hc) gi3 = 1; }
void cc_e_KP(int c) { int t = gi; if (7 == *hp) gi3 = 1; }
void cc_e_KI(int c) { int t = gi; if (7 == hp[1]) gi3 = 1; }
void cc_e_KX(int c) { int t = gi; if (7 == hca[c]) gi3 = 1; }
void cc_e_KY(int c) { int t = gi; if (7 == hca[t]) gi3 = 1; }
void cc_e_KW(int c) { int t = gi; if (7 == (unsigned char)hul) gi3 = 1; }
void cc_e_KF(int c) { int t = gi; if (7 == hrc(hi)) gi3 = 1; }
void cc_e_GK(int c) { int t = gi; if (gc == 7) gi3 = 1; }
void cc_e_GG(int c) { int t = gi; if (gc == hc) gi3 = 1; }
void cc_e_GP(int c) { int t = gi; if (gc == *hp) gi3 = 1; }
void cc_e_GI(int c) { int t = gi; if (gc == hp[1]) gi3 = 1; }
void cc_e_GX(int c) { int t = gi; if (gc == hca[c]) gi3 = 1; }
void cc_e_GY(int c) { int t = gi; if (gc == hca[t]) gi3 = 1; }
void cc_e_GW(int c) { int t = gi; if (gc == (unsigned char)hul) gi3 = 1; }
void cc_e_GF(int c) { int t = gi; if (gc == hrc(hi)) gi3 = 1; }
void cc_e_PK(int c) { int t = gi; if (*gp == 7) gi3 = 1; }
void cc_e_PG(int c) { int t = gi; if (*gp == hc) gi3 = 1; }
void cc_e_PP(int c) { int t = gi; if (*gp == *hp) gi3 = 1; }
void cc_e_PI(int c) { int t = gi; if (*gp == hp[1]) gi3 = 1; }
void cc_e_PX(int c) { int t = gi; if (*gp == hca[c]) gi3 = 1; }
void cc_e_PY(int c) { int t = gi; if (*gp == hca[t]) gi3 = 1; }
void cc_e_PW(int c) { int t = gi; if (*gp == (unsigned char)hul) gi3 = 1; }
void cc_e_PF(int c) { int t = gi; if (*gp == hrc(hi)) gi3 = 1; }
void cc_e_IK(int c) { int t = gi; if (gp[1] == 7) gi3 = 1; }
void cc_e_IG(int c) { int t = gi; if (gp[1] == hc) gi3 = 1; }
void cc_e_IP(int c) { int t = gi; if (gp[1] == *hp) gi3 = 1; }
void cc_e_II(int c) { int t = gi; if (gp[1] == hp[1]) gi3 = 1; }
void cc_e_IX(int c) { int t = gi; if (gp[1] == hca[c]) gi3 = 1; }
void cc_e_IY(int c) { int t = gi; if (gp[1] == hca[t]) gi3 = 1; }
void cc_e_IW(int c) { int t = gi; if (gp[1] == (unsigned char)hul) gi3 = 1; }
void cc_e_IF(int c) { int t = gi; if (gp[1] == hrc(hi)) gi3 = 1; }
void cc_e_XK(int c) { int t = gi; if (gca[c] == 7) gi3 = 1; }
void cc_e_XG(int c) { int t = gi; if (gca[c] == hc) gi3 = 1; }
void cc_e_XP(int c) { int t = gi; if (gca[c] == *hp) gi3 = 1; }
void cc_e_XI(int c) { int t = gi; if (gca[c] == hp[1]) gi3 = 1; }
void cc_e_XX(int c) { int t = gi; if (gca[c] == hca[c]) gi3 = 1; }
void cc_e_XY(int c) { int t = gi; if (gca[c] == hca[t]) gi3 = 1; }
void cc_e_XW(int c) { int t = gi; if (gca[c] == (unsigned char)hul) gi3 = 1; }
void cc_e_XF(int c) { int t = gi; if (gca[c] == hrc(hi)) gi3 = 1; }
void cc_e_YK(int c) { int t = gi; if (gca[t] == 7) gi3 = 1; }
void cc_e_YG(int c) { int t = gi; if (gca[t] == hc) gi3 = 1; }
void cc_e_YP(int c) { int t = gi; if (gca[t] == *hp) gi3 = 1; }
void cc_e_YI(int c) { int t = gi; if (gca[t] == hp[1]) gi3 = 1; }
void cc_e_YX(int c) { int t = gi; if (gca[t] == hca[c]) gi3 = 1; }
void cc_e_YY(int c) { int t = gi; if (gca[t] == hca[t]) gi3 = 1; }
void cc_e_YW(int c) { int t = gi; if (gca[t] == (unsigned char)hul) gi3 = 1; }
void cc_e_YF(int c) { int t = gi; if (gca[t] == hrc(hi)) gi3 = 1; }
void cc_e_WK(int c) { int t = gi; if ((unsigned char)gul == 7) gi3 = 1; }
void cc_e_WG(int c) { int t = gi; if ((unsigned char)gul == hc) gi3 = 1; }
void cc_e_WP(int c) { int t = gi; if ((unsigned char)gul == *hp) gi3 = 1; }
void cc_e_WI(int c) { int t = gi; if ((unsigned char)gul == hp[1]) gi3 = 1; }
void cc_e_WX(int c) { int t = gi; if ((unsigned char)gul == hca[c]) gi3 = 1; }
void cc_e_WY(int c) { int t = gi; if ((unsigned char)gul == hca[t]) gi3 = 1; }
void cc_e_WW(int c) { int t = gi; if ((unsigned char)gul == (unsigned char)hul) gi3 = 1; }
void cc_e_WF(int c) { int t = gi; if ((unsigned char)gul == hrc(hi)) gi3 = 1; }
void cc_e_FK(int c) { int t = gi; if (grc(gi) == 7) gi3 = 1; }
void cc_e_FG(int c) { int t = gi; if (grc(gi) == hc) gi3 = 1; }
void cc_e_FP(int c) { int t = gi; if (grc(gi) == *hp) gi3 = 1; }
void cc_e_FI(int c) { int t = gi; if (grc(gi) == hp[1]) gi3 = 1; }
void cc_e_FX(int c) { int t = gi; if (grc(gi) == hca[c]) gi3 = 1; }
void cc_e_FY(int c) { int t = gi; if (grc(gi) == hca[t]) gi3 = 1; }
void cc_e_FW(int c) { int t = gi; if (grc(gi) == (unsigned char)hul) gi3 = 1; }
void cc_e_FF(int c) { int t = gi; if (grc(gi) == hrc(hi)) gi3 = 1; }

