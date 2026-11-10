/* Compare operands of long and char kinds (gen_cmpordl.py), as the condition of an if: cl_<op>_<L><R>(c) for
   long kinds and cc_<op>_<L><R>(c) for char kinds, op < (l) and == (e).  Kinds: K constant, G global, M member,
   P deref, E constant element, X element at c, N !g, U -g, B g - g, C 256 - g, T g ? g : g, S g << c, D member
   through a pointer, F a call.  The left side reads the g* globals, the right the h* globals. */
struct st { char c; int i; long l; int a[4]; };
extern int gi, hi, gi3, gc_, hc_; extern long gl, gm, hl, hm; extern char gc, gd, hc, hd;
extern long gla[10], hla[10]; extern char gca[10], hca[10]; extern long *gpl, *hpl; extern char *gp, *hp;
extern struct st gs, *gps, hs, *hps;
extern long gfl(void), hfl(void); extern char gfc(void), hfc(void);

void cl_l_KK(int c) { if (7L < 7L) gi3 = 1; }
void cl_l_KG(int c) { if (7L < hl) gi3 = 1; }
void cl_l_KM(int c) { if (7L < hs.l) gi3 = 1; }
void cl_l_KP(int c) { if (7L < *hpl) gi3 = 1; }
void cl_l_KE(int c) { if (7L < hla[3]) gi3 = 1; }
void cl_l_KX(int c) { if (7L < hla[c]) gi3 = 1; }
void cl_l_KN(int c) { if (7L < (long)!hl) gi3 = 1; }
void cl_l_KU(int c) { if (7L < -hl) gi3 = 1; }
void cl_l_KB(int c) { if (7L < (hl - hm)) gi3 = 1; }
void cl_l_KC(int c) { if (7L < (256L - hl)) gi3 = 1; }
void cl_l_KT(int c) { if (7L < (hc ? hl : hm)) gi3 = 1; }
void cl_l_KS(int c) { if (7L < (hl << c)) gi3 = 1; }
void cl_l_KD(int c) { if (7L < hps->l) gi3 = 1; }
void cl_l_KF(int c) { if (7L < hfl()) gi3 = 1; }
void cl_l_GK(int c) { if (gl < 7L) gi3 = 1; }
void cl_l_GG(int c) { if (gl < hl) gi3 = 1; }
void cl_l_GM(int c) { if (gl < hs.l) gi3 = 1; }
void cl_l_GP(int c) { if (gl < *hpl) gi3 = 1; }
void cl_l_GE(int c) { if (gl < hla[3]) gi3 = 1; }
void cl_l_GX(int c) { if (gl < hla[c]) gi3 = 1; }
void cl_l_GN(int c) { if (gl < (long)!hl) gi3 = 1; }
void cl_l_GU(int c) { if (gl < -hl) gi3 = 1; }
void cl_l_GB(int c) { if (gl < (hl - hm)) gi3 = 1; }
void cl_l_GC(int c) { if (gl < (256L - hl)) gi3 = 1; }
void cl_l_GT(int c) { if (gl < (hc ? hl : hm)) gi3 = 1; }
void cl_l_GS(int c) { if (gl < (hl << c)) gi3 = 1; }
void cl_l_GD(int c) { if (gl < hps->l) gi3 = 1; }
void cl_l_GF(int c) { if (gl < hfl()) gi3 = 1; }
void cl_l_MK(int c) { if (gs.l < 7L) gi3 = 1; }
void cl_l_MG(int c) { if (gs.l < hl) gi3 = 1; }
void cl_l_MM(int c) { if (gs.l < hs.l) gi3 = 1; }
void cl_l_MP(int c) { if (gs.l < *hpl) gi3 = 1; }
void cl_l_ME(int c) { if (gs.l < hla[3]) gi3 = 1; }
void cl_l_MX(int c) { if (gs.l < hla[c]) gi3 = 1; }
void cl_l_MN(int c) { if (gs.l < (long)!hl) gi3 = 1; }
void cl_l_MU(int c) { if (gs.l < -hl) gi3 = 1; }
void cl_l_MB(int c) { if (gs.l < (hl - hm)) gi3 = 1; }
void cl_l_MC(int c) { if (gs.l < (256L - hl)) gi3 = 1; }
void cl_l_MT(int c) { if (gs.l < (hc ? hl : hm)) gi3 = 1; }
void cl_l_MS(int c) { if (gs.l < (hl << c)) gi3 = 1; }
void cl_l_MD(int c) { if (gs.l < hps->l) gi3 = 1; }
void cl_l_MF(int c) { if (gs.l < hfl()) gi3 = 1; }
void cl_l_PK(int c) { if (*gpl < 7L) gi3 = 1; }
void cl_l_PG(int c) { if (*gpl < hl) gi3 = 1; }
void cl_l_PM(int c) { if (*gpl < hs.l) gi3 = 1; }
void cl_l_PP(int c) { if (*gpl < *hpl) gi3 = 1; }
void cl_l_PE(int c) { if (*gpl < hla[3]) gi3 = 1; }
void cl_l_PX(int c) { if (*gpl < hla[c]) gi3 = 1; }
void cl_l_PN(int c) { if (*gpl < (long)!hl) gi3 = 1; }
void cl_l_PU(int c) { if (*gpl < -hl) gi3 = 1; }
void cl_l_PB(int c) { if (*gpl < (hl - hm)) gi3 = 1; }
void cl_l_PC(int c) { if (*gpl < (256L - hl)) gi3 = 1; }
void cl_l_PT(int c) { if (*gpl < (hc ? hl : hm)) gi3 = 1; }
void cl_l_PS(int c) { if (*gpl < (hl << c)) gi3 = 1; }
void cl_l_PD(int c) { if (*gpl < hps->l) gi3 = 1; }
void cl_l_PF(int c) { if (*gpl < hfl()) gi3 = 1; }
void cl_l_EK(int c) { if (gla[3] < 7L) gi3 = 1; }
void cl_l_EG(int c) { if (gla[3] < hl) gi3 = 1; }
void cl_l_EM(int c) { if (gla[3] < hs.l) gi3 = 1; }
void cl_l_EP(int c) { if (gla[3] < *hpl) gi3 = 1; }
void cl_l_EE(int c) { if (gla[3] < hla[3]) gi3 = 1; }
void cl_l_EX(int c) { if (gla[3] < hla[c]) gi3 = 1; }
void cl_l_EN(int c) { if (gla[3] < (long)!hl) gi3 = 1; }
void cl_l_EU(int c) { if (gla[3] < -hl) gi3 = 1; }
void cl_l_EB(int c) { if (gla[3] < (hl - hm)) gi3 = 1; }
void cl_l_EC(int c) { if (gla[3] < (256L - hl)) gi3 = 1; }
void cl_l_ET(int c) { if (gla[3] < (hc ? hl : hm)) gi3 = 1; }
void cl_l_ES(int c) { if (gla[3] < (hl << c)) gi3 = 1; }
void cl_l_ED(int c) { if (gla[3] < hps->l) gi3 = 1; }
void cl_l_EF(int c) { if (gla[3] < hfl()) gi3 = 1; }
void cl_l_XK(int c) { if (gla[c] < 7L) gi3 = 1; }
void cl_l_XG(int c) { if (gla[c] < hl) gi3 = 1; }
void cl_l_XM(int c) { if (gla[c] < hs.l) gi3 = 1; }
void cl_l_XP(int c) { if (gla[c] < *hpl) gi3 = 1; }
void cl_l_XE(int c) { if (gla[c] < hla[3]) gi3 = 1; }
void cl_l_XX(int c) { if (gla[c] < hla[c]) gi3 = 1; }
void cl_l_XN(int c) { if (gla[c] < (long)!hl) gi3 = 1; }
void cl_l_XU(int c) { if (gla[c] < -hl) gi3 = 1; }
void cl_l_XB(int c) { if (gla[c] < (hl - hm)) gi3 = 1; }
void cl_l_XC(int c) { if (gla[c] < (256L - hl)) gi3 = 1; }
void cl_l_XT(int c) { if (gla[c] < (hc ? hl : hm)) gi3 = 1; }
void cl_l_XS(int c) { if (gla[c] < (hl << c)) gi3 = 1; }
void cl_l_XD(int c) { if (gla[c] < hps->l) gi3 = 1; }
void cl_l_XF(int c) { if (gla[c] < hfl()) gi3 = 1; }
void cl_l_NK(int c) { if ((long)!gl < 7L) gi3 = 1; }
void cl_l_NG(int c) { if ((long)!gl < hl) gi3 = 1; }
void cl_l_NM(int c) { if ((long)!gl < hs.l) gi3 = 1; }
void cl_l_NP(int c) { if ((long)!gl < *hpl) gi3 = 1; }
void cl_l_NE(int c) { if ((long)!gl < hla[3]) gi3 = 1; }
void cl_l_NX(int c) { if ((long)!gl < hla[c]) gi3 = 1; }
void cl_l_NN(int c) { if ((long)!gl < (long)!hl) gi3 = 1; }
void cl_l_NU(int c) { if ((long)!gl < -hl) gi3 = 1; }
void cl_l_NB(int c) { if ((long)!gl < (hl - hm)) gi3 = 1; }
void cl_l_NC(int c) { if ((long)!gl < (256L - hl)) gi3 = 1; }
void cl_l_NT(int c) { if ((long)!gl < (hc ? hl : hm)) gi3 = 1; }
void cl_l_NS(int c) { if ((long)!gl < (hl << c)) gi3 = 1; }
void cl_l_ND(int c) { if ((long)!gl < hps->l) gi3 = 1; }
void cl_l_NF(int c) { if ((long)!gl < hfl()) gi3 = 1; }
void cl_l_UK(int c) { if (-gl < 7L) gi3 = 1; }
void cl_l_UG(int c) { if (-gl < hl) gi3 = 1; }
void cl_l_UM(int c) { if (-gl < hs.l) gi3 = 1; }
void cl_l_UP(int c) { if (-gl < *hpl) gi3 = 1; }
void cl_l_UE(int c) { if (-gl < hla[3]) gi3 = 1; }
void cl_l_UX(int c) { if (-gl < hla[c]) gi3 = 1; }
void cl_l_UN(int c) { if (-gl < (long)!hl) gi3 = 1; }
void cl_l_UU(int c) { if (-gl < -hl) gi3 = 1; }
void cl_l_UB(int c) { if (-gl < (hl - hm)) gi3 = 1; }
void cl_l_UC(int c) { if (-gl < (256L - hl)) gi3 = 1; }
void cl_l_UT(int c) { if (-gl < (hc ? hl : hm)) gi3 = 1; }
void cl_l_US(int c) { if (-gl < (hl << c)) gi3 = 1; }
void cl_l_UD(int c) { if (-gl < hps->l) gi3 = 1; }
void cl_l_UF(int c) { if (-gl < hfl()) gi3 = 1; }
void cl_l_BK(int c) { if ((gl - gm) < 7L) gi3 = 1; }
void cl_l_BG(int c) { if ((gl - gm) < hl) gi3 = 1; }
void cl_l_BM(int c) { if ((gl - gm) < hs.l) gi3 = 1; }
void cl_l_BP(int c) { if ((gl - gm) < *hpl) gi3 = 1; }
void cl_l_BE(int c) { if ((gl - gm) < hla[3]) gi3 = 1; }
void cl_l_BX(int c) { if ((gl - gm) < hla[c]) gi3 = 1; }
void cl_l_BN(int c) { if ((gl - gm) < (long)!hl) gi3 = 1; }
void cl_l_BU(int c) { if ((gl - gm) < -hl) gi3 = 1; }
void cl_l_BB(int c) { if ((gl - gm) < (hl - hm)) gi3 = 1; }
void cl_l_BC(int c) { if ((gl - gm) < (256L - hl)) gi3 = 1; }
void cl_l_BT(int c) { if ((gl - gm) < (hc ? hl : hm)) gi3 = 1; }
void cl_l_BS(int c) { if ((gl - gm) < (hl << c)) gi3 = 1; }
void cl_l_BD(int c) { if ((gl - gm) < hps->l) gi3 = 1; }
void cl_l_BF(int c) { if ((gl - gm) < hfl()) gi3 = 1; }
void cl_l_CK(int c) { if ((256L - gl) < 7L) gi3 = 1; }
void cl_l_CG(int c) { if ((256L - gl) < hl) gi3 = 1; }
void cl_l_CM(int c) { if ((256L - gl) < hs.l) gi3 = 1; }
void cl_l_CP(int c) { if ((256L - gl) < *hpl) gi3 = 1; }
void cl_l_CE(int c) { if ((256L - gl) < hla[3]) gi3 = 1; }
void cl_l_CX(int c) { if ((256L - gl) < hla[c]) gi3 = 1; }
void cl_l_CN(int c) { if ((256L - gl) < (long)!hl) gi3 = 1; }
void cl_l_CU(int c) { if ((256L - gl) < -hl) gi3 = 1; }
void cl_l_CB(int c) { if ((256L - gl) < (hl - hm)) gi3 = 1; }
void cl_l_CC(int c) { if ((256L - gl) < (256L - hl)) gi3 = 1; }
void cl_l_CT(int c) { if ((256L - gl) < (hc ? hl : hm)) gi3 = 1; }
void cl_l_CS(int c) { if ((256L - gl) < (hl << c)) gi3 = 1; }
void cl_l_CD(int c) { if ((256L - gl) < hps->l) gi3 = 1; }
void cl_l_CF(int c) { if ((256L - gl) < hfl()) gi3 = 1; }
void cl_l_TK(int c) { if ((gc ? gl : gm) < 7L) gi3 = 1; }
void cl_l_TG(int c) { if ((gc ? gl : gm) < hl) gi3 = 1; }
void cl_l_TM(int c) { if ((gc ? gl : gm) < hs.l) gi3 = 1; }
void cl_l_TP(int c) { if ((gc ? gl : gm) < *hpl) gi3 = 1; }
void cl_l_TE(int c) { if ((gc ? gl : gm) < hla[3]) gi3 = 1; }
void cl_l_TX(int c) { if ((gc ? gl : gm) < hla[c]) gi3 = 1; }
void cl_l_TN(int c) { if ((gc ? gl : gm) < (long)!hl) gi3 = 1; }
void cl_l_TU(int c) { if ((gc ? gl : gm) < -hl) gi3 = 1; }
void cl_l_TB(int c) { if ((gc ? gl : gm) < (hl - hm)) gi3 = 1; }
void cl_l_TC(int c) { if ((gc ? gl : gm) < (256L - hl)) gi3 = 1; }
void cl_l_TT(int c) { if ((gc ? gl : gm) < (hc ? hl : hm)) gi3 = 1; }
void cl_l_TS(int c) { if ((gc ? gl : gm) < (hl << c)) gi3 = 1; }
void cl_l_TD(int c) { if ((gc ? gl : gm) < hps->l) gi3 = 1; }
void cl_l_TF(int c) { if ((gc ? gl : gm) < hfl()) gi3 = 1; }
void cl_l_SK(int c) { if ((gl << c) < 7L) gi3 = 1; }
void cl_l_SG(int c) { if ((gl << c) < hl) gi3 = 1; }
void cl_l_SM(int c) { if ((gl << c) < hs.l) gi3 = 1; }
void cl_l_SP(int c) { if ((gl << c) < *hpl) gi3 = 1; }
void cl_l_SE(int c) { if ((gl << c) < hla[3]) gi3 = 1; }
void cl_l_SX(int c) { if ((gl << c) < hla[c]) gi3 = 1; }
void cl_l_SN(int c) { if ((gl << c) < (long)!hl) gi3 = 1; }
void cl_l_SU(int c) { if ((gl << c) < -hl) gi3 = 1; }
void cl_l_SB(int c) { if ((gl << c) < (hl - hm)) gi3 = 1; }
void cl_l_SC(int c) { if ((gl << c) < (256L - hl)) gi3 = 1; }
void cl_l_ST(int c) { if ((gl << c) < (hc ? hl : hm)) gi3 = 1; }
void cl_l_SS(int c) { if ((gl << c) < (hl << c)) gi3 = 1; }
void cl_l_SD(int c) { if ((gl << c) < hps->l) gi3 = 1; }
void cl_l_SF(int c) { if ((gl << c) < hfl()) gi3 = 1; }
void cl_l_DK(int c) { if (gps->l < 7L) gi3 = 1; }
void cl_l_DG(int c) { if (gps->l < hl) gi3 = 1; }
void cl_l_DM(int c) { if (gps->l < hs.l) gi3 = 1; }
void cl_l_DP(int c) { if (gps->l < *hpl) gi3 = 1; }
void cl_l_DE(int c) { if (gps->l < hla[3]) gi3 = 1; }
void cl_l_DX(int c) { if (gps->l < hla[c]) gi3 = 1; }
void cl_l_DN(int c) { if (gps->l < (long)!hl) gi3 = 1; }
void cl_l_DU(int c) { if (gps->l < -hl) gi3 = 1; }
void cl_l_DB(int c) { if (gps->l < (hl - hm)) gi3 = 1; }
void cl_l_DC(int c) { if (gps->l < (256L - hl)) gi3 = 1; }
void cl_l_DT(int c) { if (gps->l < (hc ? hl : hm)) gi3 = 1; }
void cl_l_DS(int c) { if (gps->l < (hl << c)) gi3 = 1; }
void cl_l_DD(int c) { if (gps->l < hps->l) gi3 = 1; }
void cl_l_DF(int c) { if (gps->l < hfl()) gi3 = 1; }
void cl_l_FK(int c) { if (gfl() < 7L) gi3 = 1; }
void cl_l_FG(int c) { if (gfl() < hl) gi3 = 1; }
void cl_l_FM(int c) { if (gfl() < hs.l) gi3 = 1; }
void cl_l_FP(int c) { if (gfl() < *hpl) gi3 = 1; }
void cl_l_FE(int c) { if (gfl() < hla[3]) gi3 = 1; }
void cl_l_FX(int c) { if (gfl() < hla[c]) gi3 = 1; }
void cl_l_FN(int c) { if (gfl() < (long)!hl) gi3 = 1; }
void cl_l_FU(int c) { if (gfl() < -hl) gi3 = 1; }
void cl_l_FB(int c) { if (gfl() < (hl - hm)) gi3 = 1; }
void cl_l_FC(int c) { if (gfl() < (256L - hl)) gi3 = 1; }
void cl_l_FT(int c) { if (gfl() < (hc ? hl : hm)) gi3 = 1; }
void cl_l_FS(int c) { if (gfl() < (hl << c)) gi3 = 1; }
void cl_l_FD(int c) { if (gfl() < hps->l) gi3 = 1; }
void cl_l_FF(int c) { if (gfl() < hfl()) gi3 = 1; }

void cl_e_KK(int c) { if (7L == 7L) gi3 = 1; }
void cl_e_KG(int c) { if (7L == hl) gi3 = 1; }
void cl_e_KM(int c) { if (7L == hs.l) gi3 = 1; }
void cl_e_KP(int c) { if (7L == *hpl) gi3 = 1; }
void cl_e_KE(int c) { if (7L == hla[3]) gi3 = 1; }
void cl_e_KX(int c) { if (7L == hla[c]) gi3 = 1; }
void cl_e_KN(int c) { if (7L == (long)!hl) gi3 = 1; }
void cl_e_KU(int c) { if (7L == -hl) gi3 = 1; }
void cl_e_KB(int c) { if (7L == (hl - hm)) gi3 = 1; }
void cl_e_KC(int c) { if (7L == (256L - hl)) gi3 = 1; }
void cl_e_KT(int c) { if (7L == (hc ? hl : hm)) gi3 = 1; }
void cl_e_KS(int c) { if (7L == (hl << c)) gi3 = 1; }
void cl_e_KD(int c) { if (7L == hps->l) gi3 = 1; }
void cl_e_KF(int c) { if (7L == hfl()) gi3 = 1; }
void cl_e_GK(int c) { if (gl == 7L) gi3 = 1; }
void cl_e_GG(int c) { if (gl == hl) gi3 = 1; }
void cl_e_GM(int c) { if (gl == hs.l) gi3 = 1; }
void cl_e_GP(int c) { if (gl == *hpl) gi3 = 1; }
void cl_e_GE(int c) { if (gl == hla[3]) gi3 = 1; }
void cl_e_GX(int c) { if (gl == hla[c]) gi3 = 1; }
void cl_e_GN(int c) { if (gl == (long)!hl) gi3 = 1; }
void cl_e_GU(int c) { if (gl == -hl) gi3 = 1; }
void cl_e_GB(int c) { if (gl == (hl - hm)) gi3 = 1; }
void cl_e_GC(int c) { if (gl == (256L - hl)) gi3 = 1; }
void cl_e_GT(int c) { if (gl == (hc ? hl : hm)) gi3 = 1; }
void cl_e_GS(int c) { if (gl == (hl << c)) gi3 = 1; }
void cl_e_GD(int c) { if (gl == hps->l) gi3 = 1; }
void cl_e_GF(int c) { if (gl == hfl()) gi3 = 1; }
void cl_e_MK(int c) { if (gs.l == 7L) gi3 = 1; }
void cl_e_MG(int c) { if (gs.l == hl) gi3 = 1; }
void cl_e_MM(int c) { if (gs.l == hs.l) gi3 = 1; }
void cl_e_MP(int c) { if (gs.l == *hpl) gi3 = 1; }
void cl_e_ME(int c) { if (gs.l == hla[3]) gi3 = 1; }
void cl_e_MX(int c) { if (gs.l == hla[c]) gi3 = 1; }
void cl_e_MN(int c) { if (gs.l == (long)!hl) gi3 = 1; }
void cl_e_MU(int c) { if (gs.l == -hl) gi3 = 1; }
void cl_e_MB(int c) { if (gs.l == (hl - hm)) gi3 = 1; }
void cl_e_MC(int c) { if (gs.l == (256L - hl)) gi3 = 1; }
void cl_e_MT(int c) { if (gs.l == (hc ? hl : hm)) gi3 = 1; }
void cl_e_MS(int c) { if (gs.l == (hl << c)) gi3 = 1; }
void cl_e_MD(int c) { if (gs.l == hps->l) gi3 = 1; }
void cl_e_MF(int c) { if (gs.l == hfl()) gi3 = 1; }
void cl_e_PK(int c) { if (*gpl == 7L) gi3 = 1; }
void cl_e_PG(int c) { if (*gpl == hl) gi3 = 1; }
void cl_e_PM(int c) { if (*gpl == hs.l) gi3 = 1; }
void cl_e_PP(int c) { if (*gpl == *hpl) gi3 = 1; }
void cl_e_PE(int c) { if (*gpl == hla[3]) gi3 = 1; }
void cl_e_PX(int c) { if (*gpl == hla[c]) gi3 = 1; }
void cl_e_PN(int c) { if (*gpl == (long)!hl) gi3 = 1; }
void cl_e_PU(int c) { if (*gpl == -hl) gi3 = 1; }
void cl_e_PB(int c) { if (*gpl == (hl - hm)) gi3 = 1; }
void cl_e_PC(int c) { if (*gpl == (256L - hl)) gi3 = 1; }
void cl_e_PT(int c) { if (*gpl == (hc ? hl : hm)) gi3 = 1; }
void cl_e_PS(int c) { if (*gpl == (hl << c)) gi3 = 1; }
void cl_e_PD(int c) { if (*gpl == hps->l) gi3 = 1; }
void cl_e_PF(int c) { if (*gpl == hfl()) gi3 = 1; }
void cl_e_EK(int c) { if (gla[3] == 7L) gi3 = 1; }
void cl_e_EG(int c) { if (gla[3] == hl) gi3 = 1; }
void cl_e_EM(int c) { if (gla[3] == hs.l) gi3 = 1; }
void cl_e_EP(int c) { if (gla[3] == *hpl) gi3 = 1; }
void cl_e_EE(int c) { if (gla[3] == hla[3]) gi3 = 1; }
void cl_e_EX(int c) { if (gla[3] == hla[c]) gi3 = 1; }
void cl_e_EN(int c) { if (gla[3] == (long)!hl) gi3 = 1; }
void cl_e_EU(int c) { if (gla[3] == -hl) gi3 = 1; }
void cl_e_EB(int c) { if (gla[3] == (hl - hm)) gi3 = 1; }
void cl_e_EC(int c) { if (gla[3] == (256L - hl)) gi3 = 1; }
void cl_e_ET(int c) { if (gla[3] == (hc ? hl : hm)) gi3 = 1; }
void cl_e_ES(int c) { if (gla[3] == (hl << c)) gi3 = 1; }
void cl_e_ED(int c) { if (gla[3] == hps->l) gi3 = 1; }
void cl_e_EF(int c) { if (gla[3] == hfl()) gi3 = 1; }
void cl_e_XK(int c) { if (gla[c] == 7L) gi3 = 1; }
void cl_e_XG(int c) { if (gla[c] == hl) gi3 = 1; }
void cl_e_XM(int c) { if (gla[c] == hs.l) gi3 = 1; }
void cl_e_XP(int c) { if (gla[c] == *hpl) gi3 = 1; }
void cl_e_XE(int c) { if (gla[c] == hla[3]) gi3 = 1; }
void cl_e_XX(int c) { if (gla[c] == hla[c]) gi3 = 1; }
void cl_e_XN(int c) { if (gla[c] == (long)!hl) gi3 = 1; }
void cl_e_XU(int c) { if (gla[c] == -hl) gi3 = 1; }
void cl_e_XB(int c) { if (gla[c] == (hl - hm)) gi3 = 1; }
void cl_e_XC(int c) { if (gla[c] == (256L - hl)) gi3 = 1; }
void cl_e_XT(int c) { if (gla[c] == (hc ? hl : hm)) gi3 = 1; }
void cl_e_XS(int c) { if (gla[c] == (hl << c)) gi3 = 1; }
void cl_e_XD(int c) { if (gla[c] == hps->l) gi3 = 1; }
void cl_e_XF(int c) { if (gla[c] == hfl()) gi3 = 1; }
void cl_e_NK(int c) { if ((long)!gl == 7L) gi3 = 1; }
void cl_e_NG(int c) { if ((long)!gl == hl) gi3 = 1; }
void cl_e_NM(int c) { if ((long)!gl == hs.l) gi3 = 1; }
void cl_e_NP(int c) { if ((long)!gl == *hpl) gi3 = 1; }
void cl_e_NE(int c) { if ((long)!gl == hla[3]) gi3 = 1; }
void cl_e_NX(int c) { if ((long)!gl == hla[c]) gi3 = 1; }
void cl_e_NN(int c) { if ((long)!gl == (long)!hl) gi3 = 1; }
void cl_e_NU(int c) { if ((long)!gl == -hl) gi3 = 1; }
void cl_e_NB(int c) { if ((long)!gl == (hl - hm)) gi3 = 1; }
void cl_e_NC(int c) { if ((long)!gl == (256L - hl)) gi3 = 1; }
void cl_e_NT(int c) { if ((long)!gl == (hc ? hl : hm)) gi3 = 1; }
void cl_e_NS(int c) { if ((long)!gl == (hl << c)) gi3 = 1; }
void cl_e_ND(int c) { if ((long)!gl == hps->l) gi3 = 1; }
void cl_e_NF(int c) { if ((long)!gl == hfl()) gi3 = 1; }
void cl_e_UK(int c) { if (-gl == 7L) gi3 = 1; }
void cl_e_UG(int c) { if (-gl == hl) gi3 = 1; }
void cl_e_UM(int c) { if (-gl == hs.l) gi3 = 1; }
void cl_e_UP(int c) { if (-gl == *hpl) gi3 = 1; }
void cl_e_UE(int c) { if (-gl == hla[3]) gi3 = 1; }
void cl_e_UX(int c) { if (-gl == hla[c]) gi3 = 1; }
void cl_e_UN(int c) { if (-gl == (long)!hl) gi3 = 1; }
void cl_e_UU(int c) { if (-gl == -hl) gi3 = 1; }
void cl_e_UB(int c) { if (-gl == (hl - hm)) gi3 = 1; }
void cl_e_UC(int c) { if (-gl == (256L - hl)) gi3 = 1; }
void cl_e_UT(int c) { if (-gl == (hc ? hl : hm)) gi3 = 1; }
void cl_e_US(int c) { if (-gl == (hl << c)) gi3 = 1; }
void cl_e_UD(int c) { if (-gl == hps->l) gi3 = 1; }
void cl_e_UF(int c) { if (-gl == hfl()) gi3 = 1; }
void cl_e_BK(int c) { if ((gl - gm) == 7L) gi3 = 1; }
void cl_e_BG(int c) { if ((gl - gm) == hl) gi3 = 1; }
void cl_e_BM(int c) { if ((gl - gm) == hs.l) gi3 = 1; }
void cl_e_BP(int c) { if ((gl - gm) == *hpl) gi3 = 1; }
void cl_e_BE(int c) { if ((gl - gm) == hla[3]) gi3 = 1; }
void cl_e_BX(int c) { if ((gl - gm) == hla[c]) gi3 = 1; }
void cl_e_BN(int c) { if ((gl - gm) == (long)!hl) gi3 = 1; }
void cl_e_BU(int c) { if ((gl - gm) == -hl) gi3 = 1; }
void cl_e_BB(int c) { if ((gl - gm) == (hl - hm)) gi3 = 1; }
void cl_e_BC(int c) { if ((gl - gm) == (256L - hl)) gi3 = 1; }
void cl_e_BT(int c) { if ((gl - gm) == (hc ? hl : hm)) gi3 = 1; }
void cl_e_BS(int c) { if ((gl - gm) == (hl << c)) gi3 = 1; }
void cl_e_BD(int c) { if ((gl - gm) == hps->l) gi3 = 1; }
void cl_e_BF(int c) { if ((gl - gm) == hfl()) gi3 = 1; }
void cl_e_CK(int c) { if ((256L - gl) == 7L) gi3 = 1; }
void cl_e_CG(int c) { if ((256L - gl) == hl) gi3 = 1; }
void cl_e_CM(int c) { if ((256L - gl) == hs.l) gi3 = 1; }
void cl_e_CP(int c) { if ((256L - gl) == *hpl) gi3 = 1; }
void cl_e_CE(int c) { if ((256L - gl) == hla[3]) gi3 = 1; }
void cl_e_CX(int c) { if ((256L - gl) == hla[c]) gi3 = 1; }
void cl_e_CN(int c) { if ((256L - gl) == (long)!hl) gi3 = 1; }
void cl_e_CU(int c) { if ((256L - gl) == -hl) gi3 = 1; }
void cl_e_CB(int c) { if ((256L - gl) == (hl - hm)) gi3 = 1; }
void cl_e_CC(int c) { if ((256L - gl) == (256L - hl)) gi3 = 1; }
void cl_e_CT(int c) { if ((256L - gl) == (hc ? hl : hm)) gi3 = 1; }
void cl_e_CS(int c) { if ((256L - gl) == (hl << c)) gi3 = 1; }
void cl_e_CD(int c) { if ((256L - gl) == hps->l) gi3 = 1; }
void cl_e_CF(int c) { if ((256L - gl) == hfl()) gi3 = 1; }
void cl_e_TK(int c) { if ((gc ? gl : gm) == 7L) gi3 = 1; }
void cl_e_TG(int c) { if ((gc ? gl : gm) == hl) gi3 = 1; }
void cl_e_TM(int c) { if ((gc ? gl : gm) == hs.l) gi3 = 1; }
void cl_e_TP(int c) { if ((gc ? gl : gm) == *hpl) gi3 = 1; }
void cl_e_TE(int c) { if ((gc ? gl : gm) == hla[3]) gi3 = 1; }
void cl_e_TX(int c) { if ((gc ? gl : gm) == hla[c]) gi3 = 1; }
void cl_e_TN(int c) { if ((gc ? gl : gm) == (long)!hl) gi3 = 1; }
void cl_e_TU(int c) { if ((gc ? gl : gm) == -hl) gi3 = 1; }
void cl_e_TB(int c) { if ((gc ? gl : gm) == (hl - hm)) gi3 = 1; }
void cl_e_TC(int c) { if ((gc ? gl : gm) == (256L - hl)) gi3 = 1; }
void cl_e_TT(int c) { if ((gc ? gl : gm) == (hc ? hl : hm)) gi3 = 1; }
void cl_e_TS(int c) { if ((gc ? gl : gm) == (hl << c)) gi3 = 1; }
void cl_e_TD(int c) { if ((gc ? gl : gm) == hps->l) gi3 = 1; }
void cl_e_TF(int c) { if ((gc ? gl : gm) == hfl()) gi3 = 1; }
void cl_e_SK(int c) { if ((gl << c) == 7L) gi3 = 1; }
void cl_e_SG(int c) { if ((gl << c) == hl) gi3 = 1; }
void cl_e_SM(int c) { if ((gl << c) == hs.l) gi3 = 1; }
void cl_e_SP(int c) { if ((gl << c) == *hpl) gi3 = 1; }
void cl_e_SE(int c) { if ((gl << c) == hla[3]) gi3 = 1; }
void cl_e_SX(int c) { if ((gl << c) == hla[c]) gi3 = 1; }
void cl_e_SN(int c) { if ((gl << c) == (long)!hl) gi3 = 1; }
void cl_e_SU(int c) { if ((gl << c) == -hl) gi3 = 1; }
void cl_e_SB(int c) { if ((gl << c) == (hl - hm)) gi3 = 1; }
void cl_e_SC(int c) { if ((gl << c) == (256L - hl)) gi3 = 1; }
void cl_e_ST(int c) { if ((gl << c) == (hc ? hl : hm)) gi3 = 1; }
void cl_e_SS(int c) { if ((gl << c) == (hl << c)) gi3 = 1; }
void cl_e_SD(int c) { if ((gl << c) == hps->l) gi3 = 1; }
void cl_e_SF(int c) { if ((gl << c) == hfl()) gi3 = 1; }
void cl_e_DK(int c) { if (gps->l == 7L) gi3 = 1; }
void cl_e_DG(int c) { if (gps->l == hl) gi3 = 1; }
void cl_e_DM(int c) { if (gps->l == hs.l) gi3 = 1; }
void cl_e_DP(int c) { if (gps->l == *hpl) gi3 = 1; }
void cl_e_DE(int c) { if (gps->l == hla[3]) gi3 = 1; }
void cl_e_DX(int c) { if (gps->l == hla[c]) gi3 = 1; }
void cl_e_DN(int c) { if (gps->l == (long)!hl) gi3 = 1; }
void cl_e_DU(int c) { if (gps->l == -hl) gi3 = 1; }
void cl_e_DB(int c) { if (gps->l == (hl - hm)) gi3 = 1; }
void cl_e_DC(int c) { if (gps->l == (256L - hl)) gi3 = 1; }
void cl_e_DT(int c) { if (gps->l == (hc ? hl : hm)) gi3 = 1; }
void cl_e_DS(int c) { if (gps->l == (hl << c)) gi3 = 1; }
void cl_e_DD(int c) { if (gps->l == hps->l) gi3 = 1; }
void cl_e_DF(int c) { if (gps->l == hfl()) gi3 = 1; }
void cl_e_FK(int c) { if (gfl() == 7L) gi3 = 1; }
void cl_e_FG(int c) { if (gfl() == hl) gi3 = 1; }
void cl_e_FM(int c) { if (gfl() == hs.l) gi3 = 1; }
void cl_e_FP(int c) { if (gfl() == *hpl) gi3 = 1; }
void cl_e_FE(int c) { if (gfl() == hla[3]) gi3 = 1; }
void cl_e_FX(int c) { if (gfl() == hla[c]) gi3 = 1; }
void cl_e_FN(int c) { if (gfl() == (long)!hl) gi3 = 1; }
void cl_e_FU(int c) { if (gfl() == -hl) gi3 = 1; }
void cl_e_FB(int c) { if (gfl() == (hl - hm)) gi3 = 1; }
void cl_e_FC(int c) { if (gfl() == (256L - hl)) gi3 = 1; }
void cl_e_FT(int c) { if (gfl() == (hc ? hl : hm)) gi3 = 1; }
void cl_e_FS(int c) { if (gfl() == (hl << c)) gi3 = 1; }
void cl_e_FD(int c) { if (gfl() == hps->l) gi3 = 1; }
void cl_e_FF(int c) { if (gfl() == hfl()) gi3 = 1; }

void cc_l_KK(int c) { if (7 < 7) gi3 = 1; }
void cc_l_KG(int c) { if (7 < hc) gi3 = 1; }
void cc_l_KM(int c) { if (7 < hs.c) gi3 = 1; }
void cc_l_KP(int c) { if (7 < *hp) gi3 = 1; }
void cc_l_KE(int c) { if (7 < hca[3]) gi3 = 1; }
void cc_l_KX(int c) { if (7 < hca[c]) gi3 = 1; }
void cc_l_KN(int c) { if (7 < !hc) gi3 = 1; }
void cc_l_KU(int c) { if (7 < -hc) gi3 = 1; }
void cc_l_KB(int c) { if (7 < (hc - hd)) gi3 = 1; }
void cc_l_KT(int c) { if (7 < (hi ? hc : hd)) gi3 = 1; }
void cc_l_KD(int c) { if (7 < hps->c) gi3 = 1; }
void cc_l_KF(int c) { if (7 < hfc()) gi3 = 1; }
void cc_l_GK(int c) { if (gc < 7) gi3 = 1; }
void cc_l_GG(int c) { if (gc < hc) gi3 = 1; }
void cc_l_GM(int c) { if (gc < hs.c) gi3 = 1; }
void cc_l_GP(int c) { if (gc < *hp) gi3 = 1; }
void cc_l_GE(int c) { if (gc < hca[3]) gi3 = 1; }
void cc_l_GX(int c) { if (gc < hca[c]) gi3 = 1; }
void cc_l_GN(int c) { if (gc < !hc) gi3 = 1; }
void cc_l_GU(int c) { if (gc < -hc) gi3 = 1; }
void cc_l_GB(int c) { if (gc < (hc - hd)) gi3 = 1; }
void cc_l_GT(int c) { if (gc < (hi ? hc : hd)) gi3 = 1; }
void cc_l_GD(int c) { if (gc < hps->c) gi3 = 1; }
void cc_l_GF(int c) { if (gc < hfc()) gi3 = 1; }
void cc_l_MK(int c) { if (gs.c < 7) gi3 = 1; }
void cc_l_MG(int c) { if (gs.c < hc) gi3 = 1; }
void cc_l_MM(int c) { if (gs.c < hs.c) gi3 = 1; }
void cc_l_MP(int c) { if (gs.c < *hp) gi3 = 1; }
void cc_l_ME(int c) { if (gs.c < hca[3]) gi3 = 1; }
void cc_l_MX(int c) { if (gs.c < hca[c]) gi3 = 1; }
void cc_l_MN(int c) { if (gs.c < !hc) gi3 = 1; }
void cc_l_MU(int c) { if (gs.c < -hc) gi3 = 1; }
void cc_l_MB(int c) { if (gs.c < (hc - hd)) gi3 = 1; }
void cc_l_MT(int c) { if (gs.c < (hi ? hc : hd)) gi3 = 1; }
void cc_l_MD(int c) { if (gs.c < hps->c) gi3 = 1; }
void cc_l_MF(int c) { if (gs.c < hfc()) gi3 = 1; }
void cc_l_PK(int c) { if (*gp < 7) gi3 = 1; }
void cc_l_PG(int c) { if (*gp < hc) gi3 = 1; }
void cc_l_PM(int c) { if (*gp < hs.c) gi3 = 1; }
void cc_l_PP(int c) { if (*gp < *hp) gi3 = 1; }
void cc_l_PE(int c) { if (*gp < hca[3]) gi3 = 1; }
void cc_l_PX(int c) { if (*gp < hca[c]) gi3 = 1; }
void cc_l_PN(int c) { if (*gp < !hc) gi3 = 1; }
void cc_l_PU(int c) { if (*gp < -hc) gi3 = 1; }
void cc_l_PB(int c) { if (*gp < (hc - hd)) gi3 = 1; }
void cc_l_PT(int c) { if (*gp < (hi ? hc : hd)) gi3 = 1; }
void cc_l_PD(int c) { if (*gp < hps->c) gi3 = 1; }
void cc_l_PF(int c) { if (*gp < hfc()) gi3 = 1; }
void cc_l_EK(int c) { if (gca[3] < 7) gi3 = 1; }
void cc_l_EG(int c) { if (gca[3] < hc) gi3 = 1; }
void cc_l_EM(int c) { if (gca[3] < hs.c) gi3 = 1; }
void cc_l_EP(int c) { if (gca[3] < *hp) gi3 = 1; }
void cc_l_EE(int c) { if (gca[3] < hca[3]) gi3 = 1; }
void cc_l_EX(int c) { if (gca[3] < hca[c]) gi3 = 1; }
void cc_l_EN(int c) { if (gca[3] < !hc) gi3 = 1; }
void cc_l_EU(int c) { if (gca[3] < -hc) gi3 = 1; }
void cc_l_EB(int c) { if (gca[3] < (hc - hd)) gi3 = 1; }
void cc_l_ET(int c) { if (gca[3] < (hi ? hc : hd)) gi3 = 1; }
void cc_l_ED(int c) { if (gca[3] < hps->c) gi3 = 1; }
void cc_l_EF(int c) { if (gca[3] < hfc()) gi3 = 1; }
void cc_l_XK(int c) { if (gca[c] < 7) gi3 = 1; }
void cc_l_XG(int c) { if (gca[c] < hc) gi3 = 1; }
void cc_l_XM(int c) { if (gca[c] < hs.c) gi3 = 1; }
void cc_l_XP(int c) { if (gca[c] < *hp) gi3 = 1; }
void cc_l_XE(int c) { if (gca[c] < hca[3]) gi3 = 1; }
void cc_l_XX(int c) { if (gca[c] < hca[c]) gi3 = 1; }
void cc_l_XN(int c) { if (gca[c] < !hc) gi3 = 1; }
void cc_l_XU(int c) { if (gca[c] < -hc) gi3 = 1; }
void cc_l_XB(int c) { if (gca[c] < (hc - hd)) gi3 = 1; }
void cc_l_XT(int c) { if (gca[c] < (hi ? hc : hd)) gi3 = 1; }
void cc_l_XD(int c) { if (gca[c] < hps->c) gi3 = 1; }
void cc_l_XF(int c) { if (gca[c] < hfc()) gi3 = 1; }
void cc_l_NK(int c) { if (!gc < 7) gi3 = 1; }
void cc_l_NG(int c) { if (!gc < hc) gi3 = 1; }
void cc_l_NM(int c) { if (!gc < hs.c) gi3 = 1; }
void cc_l_NP(int c) { if (!gc < *hp) gi3 = 1; }
void cc_l_NE(int c) { if (!gc < hca[3]) gi3 = 1; }
void cc_l_NX(int c) { if (!gc < hca[c]) gi3 = 1; }
void cc_l_NN(int c) { if (!gc < !hc) gi3 = 1; }
void cc_l_NU(int c) { if (!gc < -hc) gi3 = 1; }
void cc_l_NB(int c) { if (!gc < (hc - hd)) gi3 = 1; }
void cc_l_NT(int c) { if (!gc < (hi ? hc : hd)) gi3 = 1; }
void cc_l_ND(int c) { if (!gc < hps->c) gi3 = 1; }
void cc_l_NF(int c) { if (!gc < hfc()) gi3 = 1; }
void cc_l_UK(int c) { if (-gc < 7) gi3 = 1; }
void cc_l_UG(int c) { if (-gc < hc) gi3 = 1; }
void cc_l_UM(int c) { if (-gc < hs.c) gi3 = 1; }
void cc_l_UP(int c) { if (-gc < *hp) gi3 = 1; }
void cc_l_UE(int c) { if (-gc < hca[3]) gi3 = 1; }
void cc_l_UX(int c) { if (-gc < hca[c]) gi3 = 1; }
void cc_l_UN(int c) { if (-gc < !hc) gi3 = 1; }
void cc_l_UU(int c) { if (-gc < -hc) gi3 = 1; }
void cc_l_UB(int c) { if (-gc < (hc - hd)) gi3 = 1; }
void cc_l_UT(int c) { if (-gc < (hi ? hc : hd)) gi3 = 1; }
void cc_l_UD(int c) { if (-gc < hps->c) gi3 = 1; }
void cc_l_UF(int c) { if (-gc < hfc()) gi3 = 1; }
void cc_l_BK(int c) { if ((gc - gd) < 7) gi3 = 1; }
void cc_l_BG(int c) { if ((gc - gd) < hc) gi3 = 1; }
void cc_l_BM(int c) { if ((gc - gd) < hs.c) gi3 = 1; }
void cc_l_BP(int c) { if ((gc - gd) < *hp) gi3 = 1; }
void cc_l_BE(int c) { if ((gc - gd) < hca[3]) gi3 = 1; }
void cc_l_BX(int c) { if ((gc - gd) < hca[c]) gi3 = 1; }
void cc_l_BN(int c) { if ((gc - gd) < !hc) gi3 = 1; }
void cc_l_BU(int c) { if ((gc - gd) < -hc) gi3 = 1; }
void cc_l_BB(int c) { if ((gc - gd) < (hc - hd)) gi3 = 1; }
void cc_l_BT(int c) { if ((gc - gd) < (hi ? hc : hd)) gi3 = 1; }
void cc_l_BD(int c) { if ((gc - gd) < hps->c) gi3 = 1; }
void cc_l_BF(int c) { if ((gc - gd) < hfc()) gi3 = 1; }
void cc_l_TK(int c) { if ((gi ? gc : gd) < 7) gi3 = 1; }
void cc_l_TG(int c) { if ((gi ? gc : gd) < hc) gi3 = 1; }
void cc_l_TM(int c) { if ((gi ? gc : gd) < hs.c) gi3 = 1; }
void cc_l_TP(int c) { if ((gi ? gc : gd) < *hp) gi3 = 1; }
void cc_l_TE(int c) { if ((gi ? gc : gd) < hca[3]) gi3 = 1; }
void cc_l_TX(int c) { if ((gi ? gc : gd) < hca[c]) gi3 = 1; }
void cc_l_TN(int c) { if ((gi ? gc : gd) < !hc) gi3 = 1; }
void cc_l_TU(int c) { if ((gi ? gc : gd) < -hc) gi3 = 1; }
void cc_l_TB(int c) { if ((gi ? gc : gd) < (hc - hd)) gi3 = 1; }
void cc_l_TT(int c) { if ((gi ? gc : gd) < (hi ? hc : hd)) gi3 = 1; }
void cc_l_TD(int c) { if ((gi ? gc : gd) < hps->c) gi3 = 1; }
void cc_l_TF(int c) { if ((gi ? gc : gd) < hfc()) gi3 = 1; }
void cc_l_DK(int c) { if (gps->c < 7) gi3 = 1; }
void cc_l_DG(int c) { if (gps->c < hc) gi3 = 1; }
void cc_l_DM(int c) { if (gps->c < hs.c) gi3 = 1; }
void cc_l_DP(int c) { if (gps->c < *hp) gi3 = 1; }
void cc_l_DE(int c) { if (gps->c < hca[3]) gi3 = 1; }
void cc_l_DX(int c) { if (gps->c < hca[c]) gi3 = 1; }
void cc_l_DN(int c) { if (gps->c < !hc) gi3 = 1; }
void cc_l_DU(int c) { if (gps->c < -hc) gi3 = 1; }
void cc_l_DB(int c) { if (gps->c < (hc - hd)) gi3 = 1; }
void cc_l_DT(int c) { if (gps->c < (hi ? hc : hd)) gi3 = 1; }
void cc_l_DD(int c) { if (gps->c < hps->c) gi3 = 1; }
void cc_l_DF(int c) { if (gps->c < hfc()) gi3 = 1; }
void cc_l_FK(int c) { if (gfc() < 7) gi3 = 1; }
void cc_l_FG(int c) { if (gfc() < hc) gi3 = 1; }
void cc_l_FM(int c) { if (gfc() < hs.c) gi3 = 1; }
void cc_l_FP(int c) { if (gfc() < *hp) gi3 = 1; }
void cc_l_FE(int c) { if (gfc() < hca[3]) gi3 = 1; }
void cc_l_FX(int c) { if (gfc() < hca[c]) gi3 = 1; }
void cc_l_FN(int c) { if (gfc() < !hc) gi3 = 1; }
void cc_l_FU(int c) { if (gfc() < -hc) gi3 = 1; }
void cc_l_FB(int c) { if (gfc() < (hc - hd)) gi3 = 1; }
void cc_l_FT(int c) { if (gfc() < (hi ? hc : hd)) gi3 = 1; }
void cc_l_FD(int c) { if (gfc() < hps->c) gi3 = 1; }
void cc_l_FF(int c) { if (gfc() < hfc()) gi3 = 1; }

void cc_e_KK(int c) { if (7 == 7) gi3 = 1; }
void cc_e_KG(int c) { if (7 == hc) gi3 = 1; }
void cc_e_KM(int c) { if (7 == hs.c) gi3 = 1; }
void cc_e_KP(int c) { if (7 == *hp) gi3 = 1; }
void cc_e_KE(int c) { if (7 == hca[3]) gi3 = 1; }
void cc_e_KX(int c) { if (7 == hca[c]) gi3 = 1; }
void cc_e_KN(int c) { if (7 == !hc) gi3 = 1; }
void cc_e_KU(int c) { if (7 == -hc) gi3 = 1; }
void cc_e_KB(int c) { if (7 == (hc - hd)) gi3 = 1; }
void cc_e_KT(int c) { if (7 == (hi ? hc : hd)) gi3 = 1; }
void cc_e_KD(int c) { if (7 == hps->c) gi3 = 1; }
void cc_e_KF(int c) { if (7 == hfc()) gi3 = 1; }
void cc_e_GK(int c) { if (gc == 7) gi3 = 1; }
void cc_e_GG(int c) { if (gc == hc) gi3 = 1; }
void cc_e_GM(int c) { if (gc == hs.c) gi3 = 1; }
void cc_e_GP(int c) { if (gc == *hp) gi3 = 1; }
void cc_e_GE(int c) { if (gc == hca[3]) gi3 = 1; }
void cc_e_GX(int c) { if (gc == hca[c]) gi3 = 1; }
void cc_e_GN(int c) { if (gc == !hc) gi3 = 1; }
void cc_e_GU(int c) { if (gc == -hc) gi3 = 1; }
void cc_e_GB(int c) { if (gc == (hc - hd)) gi3 = 1; }
void cc_e_GT(int c) { if (gc == (hi ? hc : hd)) gi3 = 1; }
void cc_e_GD(int c) { if (gc == hps->c) gi3 = 1; }
void cc_e_GF(int c) { if (gc == hfc()) gi3 = 1; }
void cc_e_MK(int c) { if (gs.c == 7) gi3 = 1; }
void cc_e_MG(int c) { if (gs.c == hc) gi3 = 1; }
void cc_e_MM(int c) { if (gs.c == hs.c) gi3 = 1; }
void cc_e_MP(int c) { if (gs.c == *hp) gi3 = 1; }
void cc_e_ME(int c) { if (gs.c == hca[3]) gi3 = 1; }
void cc_e_MX(int c) { if (gs.c == hca[c]) gi3 = 1; }
void cc_e_MN(int c) { if (gs.c == !hc) gi3 = 1; }
void cc_e_MU(int c) { if (gs.c == -hc) gi3 = 1; }
void cc_e_MB(int c) { if (gs.c == (hc - hd)) gi3 = 1; }
void cc_e_MT(int c) { if (gs.c == (hi ? hc : hd)) gi3 = 1; }
void cc_e_MD(int c) { if (gs.c == hps->c) gi3 = 1; }
void cc_e_MF(int c) { if (gs.c == hfc()) gi3 = 1; }
void cc_e_PK(int c) { if (*gp == 7) gi3 = 1; }
void cc_e_PG(int c) { if (*gp == hc) gi3 = 1; }
void cc_e_PM(int c) { if (*gp == hs.c) gi3 = 1; }
void cc_e_PP(int c) { if (*gp == *hp) gi3 = 1; }
void cc_e_PE(int c) { if (*gp == hca[3]) gi3 = 1; }
void cc_e_PX(int c) { if (*gp == hca[c]) gi3 = 1; }
void cc_e_PN(int c) { if (*gp == !hc) gi3 = 1; }
void cc_e_PU(int c) { if (*gp == -hc) gi3 = 1; }
void cc_e_PB(int c) { if (*gp == (hc - hd)) gi3 = 1; }
void cc_e_PT(int c) { if (*gp == (hi ? hc : hd)) gi3 = 1; }
void cc_e_PD(int c) { if (*gp == hps->c) gi3 = 1; }
void cc_e_PF(int c) { if (*gp == hfc()) gi3 = 1; }
void cc_e_EK(int c) { if (gca[3] == 7) gi3 = 1; }
void cc_e_EG(int c) { if (gca[3] == hc) gi3 = 1; }
void cc_e_EM(int c) { if (gca[3] == hs.c) gi3 = 1; }
void cc_e_EP(int c) { if (gca[3] == *hp) gi3 = 1; }
void cc_e_EE(int c) { if (gca[3] == hca[3]) gi3 = 1; }
void cc_e_EX(int c) { if (gca[3] == hca[c]) gi3 = 1; }
void cc_e_EN(int c) { if (gca[3] == !hc) gi3 = 1; }
void cc_e_EU(int c) { if (gca[3] == -hc) gi3 = 1; }
void cc_e_EB(int c) { if (gca[3] == (hc - hd)) gi3 = 1; }
void cc_e_ET(int c) { if (gca[3] == (hi ? hc : hd)) gi3 = 1; }
void cc_e_ED(int c) { if (gca[3] == hps->c) gi3 = 1; }
void cc_e_EF(int c) { if (gca[3] == hfc()) gi3 = 1; }
void cc_e_XK(int c) { if (gca[c] == 7) gi3 = 1; }
void cc_e_XG(int c) { if (gca[c] == hc) gi3 = 1; }
void cc_e_XM(int c) { if (gca[c] == hs.c) gi3 = 1; }
void cc_e_XP(int c) { if (gca[c] == *hp) gi3 = 1; }
void cc_e_XE(int c) { if (gca[c] == hca[3]) gi3 = 1; }
void cc_e_XX(int c) { if (gca[c] == hca[c]) gi3 = 1; }
void cc_e_XN(int c) { if (gca[c] == !hc) gi3 = 1; }
void cc_e_XU(int c) { if (gca[c] == -hc) gi3 = 1; }
void cc_e_XB(int c) { if (gca[c] == (hc - hd)) gi3 = 1; }
void cc_e_XT(int c) { if (gca[c] == (hi ? hc : hd)) gi3 = 1; }
void cc_e_XD(int c) { if (gca[c] == hps->c) gi3 = 1; }
void cc_e_XF(int c) { if (gca[c] == hfc()) gi3 = 1; }
void cc_e_NK(int c) { if (!gc == 7) gi3 = 1; }
void cc_e_NG(int c) { if (!gc == hc) gi3 = 1; }
void cc_e_NM(int c) { if (!gc == hs.c) gi3 = 1; }
void cc_e_NP(int c) { if (!gc == *hp) gi3 = 1; }
void cc_e_NE(int c) { if (!gc == hca[3]) gi3 = 1; }
void cc_e_NX(int c) { if (!gc == hca[c]) gi3 = 1; }
void cc_e_NN(int c) { if (!gc == !hc) gi3 = 1; }
void cc_e_NU(int c) { if (!gc == -hc) gi3 = 1; }
void cc_e_NB(int c) { if (!gc == (hc - hd)) gi3 = 1; }
void cc_e_NT(int c) { if (!gc == (hi ? hc : hd)) gi3 = 1; }
void cc_e_ND(int c) { if (!gc == hps->c) gi3 = 1; }
void cc_e_NF(int c) { if (!gc == hfc()) gi3 = 1; }
void cc_e_UK(int c) { if (-gc == 7) gi3 = 1; }
void cc_e_UG(int c) { if (-gc == hc) gi3 = 1; }
void cc_e_UM(int c) { if (-gc == hs.c) gi3 = 1; }
void cc_e_UP(int c) { if (-gc == *hp) gi3 = 1; }
void cc_e_UE(int c) { if (-gc == hca[3]) gi3 = 1; }
void cc_e_UX(int c) { if (-gc == hca[c]) gi3 = 1; }
void cc_e_UN(int c) { if (-gc == !hc) gi3 = 1; }
void cc_e_UU(int c) { if (-gc == -hc) gi3 = 1; }
void cc_e_UB(int c) { if (-gc == (hc - hd)) gi3 = 1; }
void cc_e_UT(int c) { if (-gc == (hi ? hc : hd)) gi3 = 1; }
void cc_e_UD(int c) { if (-gc == hps->c) gi3 = 1; }
void cc_e_UF(int c) { if (-gc == hfc()) gi3 = 1; }
void cc_e_BK(int c) { if ((gc - gd) == 7) gi3 = 1; }
void cc_e_BG(int c) { if ((gc - gd) == hc) gi3 = 1; }
void cc_e_BM(int c) { if ((gc - gd) == hs.c) gi3 = 1; }
void cc_e_BP(int c) { if ((gc - gd) == *hp) gi3 = 1; }
void cc_e_BE(int c) { if ((gc - gd) == hca[3]) gi3 = 1; }
void cc_e_BX(int c) { if ((gc - gd) == hca[c]) gi3 = 1; }
void cc_e_BN(int c) { if ((gc - gd) == !hc) gi3 = 1; }
void cc_e_BU(int c) { if ((gc - gd) == -hc) gi3 = 1; }
void cc_e_BB(int c) { if ((gc - gd) == (hc - hd)) gi3 = 1; }
void cc_e_BT(int c) { if ((gc - gd) == (hi ? hc : hd)) gi3 = 1; }
void cc_e_BD(int c) { if ((gc - gd) == hps->c) gi3 = 1; }
void cc_e_BF(int c) { if ((gc - gd) == hfc()) gi3 = 1; }
void cc_e_TK(int c) { if ((gi ? gc : gd) == 7) gi3 = 1; }
void cc_e_TG(int c) { if ((gi ? gc : gd) == hc) gi3 = 1; }
void cc_e_TM(int c) { if ((gi ? gc : gd) == hs.c) gi3 = 1; }
void cc_e_TP(int c) { if ((gi ? gc : gd) == *hp) gi3 = 1; }
void cc_e_TE(int c) { if ((gi ? gc : gd) == hca[3]) gi3 = 1; }
void cc_e_TX(int c) { if ((gi ? gc : gd) == hca[c]) gi3 = 1; }
void cc_e_TN(int c) { if ((gi ? gc : gd) == !hc) gi3 = 1; }
void cc_e_TU(int c) { if ((gi ? gc : gd) == -hc) gi3 = 1; }
void cc_e_TB(int c) { if ((gi ? gc : gd) == (hc - hd)) gi3 = 1; }
void cc_e_TT(int c) { if ((gi ? gc : gd) == (hi ? hc : hd)) gi3 = 1; }
void cc_e_TD(int c) { if ((gi ? gc : gd) == hps->c) gi3 = 1; }
void cc_e_TF(int c) { if ((gi ? gc : gd) == hfc()) gi3 = 1; }
void cc_e_DK(int c) { if (gps->c == 7) gi3 = 1; }
void cc_e_DG(int c) { if (gps->c == hc) gi3 = 1; }
void cc_e_DM(int c) { if (gps->c == hs.c) gi3 = 1; }
void cc_e_DP(int c) { if (gps->c == *hp) gi3 = 1; }
void cc_e_DE(int c) { if (gps->c == hca[3]) gi3 = 1; }
void cc_e_DX(int c) { if (gps->c == hca[c]) gi3 = 1; }
void cc_e_DN(int c) { if (gps->c == !hc) gi3 = 1; }
void cc_e_DU(int c) { if (gps->c == -hc) gi3 = 1; }
void cc_e_DB(int c) { if (gps->c == (hc - hd)) gi3 = 1; }
void cc_e_DT(int c) { if (gps->c == (hi ? hc : hd)) gi3 = 1; }
void cc_e_DD(int c) { if (gps->c == hps->c) gi3 = 1; }
void cc_e_DF(int c) { if (gps->c == hfc()) gi3 = 1; }
void cc_e_FK(int c) { if (gfc() == 7) gi3 = 1; }
void cc_e_FG(int c) { if (gfc() == hc) gi3 = 1; }
void cc_e_FM(int c) { if (gfc() == hs.c) gi3 = 1; }
void cc_e_FP(int c) { if (gfc() == *hp) gi3 = 1; }
void cc_e_FE(int c) { if (gfc() == hca[3]) gi3 = 1; }
void cc_e_FX(int c) { if (gfc() == hca[c]) gi3 = 1; }
void cc_e_FN(int c) { if (gfc() == !hc) gi3 = 1; }
void cc_e_FU(int c) { if (gfc() == -hc) gi3 = 1; }
void cc_e_FB(int c) { if (gfc() == (hc - hd)) gi3 = 1; }
void cc_e_FT(int c) { if (gfc() == (hi ? hc : hd)) gi3 = 1; }
void cc_e_FD(int c) { if (gfc() == hps->c) gi3 = 1; }
void cc_e_FF(int c) { if (gfc() == hfc()) gi3 = 1; }

