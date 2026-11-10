/* Evaluation order, third probe (gen_evorder2.py): the kinds of evorder.c as longs, returned (el_<op>_<L><R>),
   for - and ^; the left side reads g* globals, the right h*. */
struct st { int i; int a[4]; long l; };
extern int gi, gj, gc, hi, hj, hc, gi3; extern int gia[10], hia[10]; extern int *gpi, *hpi;
extern long gl, gm, hl, hm; extern long gla[10], hla[10]; extern long *gpl, *hpl;
extern struct st gs, *gps, hs, *hps; extern void v1(int);

long el_s_KK(int c) { return 7L - 7L; }
long el_s_KG(int c) { return 7L - hl; }
long el_s_KM(int c) { return 7L - hs.l; }
long el_s_KP(int c) { return 7L - *hpl; }
long el_s_KE(int c) { return 7L - hla[3]; }
long el_s_KX(int c) { return 7L - hla[c]; }
long el_s_KN(int c) { return 7L - !hl; }
long el_s_KU(int c) { return 7L - -hl; }
long el_s_KB(int c) { return 7L - (hl - hm); }
long el_s_KC(int c) { return 7L - (256L - hl); }
long el_s_KT(int c) { return 7L - (hc ? hl : hm); }
long el_s_KS(int c) { return 7L - (hl << c); }
long el_s_KD(int c) { return 7L - hps->l; }
long el_s_GK(int c) { return gl - 7L; }
long el_s_GG(int c) { return gl - hl; }
long el_s_GM(int c) { return gl - hs.l; }
long el_s_GP(int c) { return gl - *hpl; }
long el_s_GE(int c) { return gl - hla[3]; }
long el_s_GX(int c) { return gl - hla[c]; }
long el_s_GN(int c) { return gl - !hl; }
long el_s_GU(int c) { return gl - -hl; }
long el_s_GB(int c) { return gl - (hl - hm); }
long el_s_GC(int c) { return gl - (256L - hl); }
long el_s_GT(int c) { return gl - (hc ? hl : hm); }
long el_s_GS(int c) { return gl - (hl << c); }
long el_s_GD(int c) { return gl - hps->l; }
long el_s_MK(int c) { return gs.l - 7L; }
long el_s_MG(int c) { return gs.l - hl; }
long el_s_MM(int c) { return gs.l - hs.l; }
long el_s_MP(int c) { return gs.l - *hpl; }
long el_s_ME(int c) { return gs.l - hla[3]; }
long el_s_MX(int c) { return gs.l - hla[c]; }
long el_s_MN(int c) { return gs.l - !hl; }
long el_s_MU(int c) { return gs.l - -hl; }
long el_s_MB(int c) { return gs.l - (hl - hm); }
long el_s_MC(int c) { return gs.l - (256L - hl); }
long el_s_MT(int c) { return gs.l - (hc ? hl : hm); }
long el_s_MS(int c) { return gs.l - (hl << c); }
long el_s_MD(int c) { return gs.l - hps->l; }
long el_s_PK(int c) { return *gpl - 7L; }
long el_s_PG(int c) { return *gpl - hl; }
long el_s_PM(int c) { return *gpl - hs.l; }
long el_s_PP(int c) { return *gpl - *hpl; }
long el_s_PE(int c) { return *gpl - hla[3]; }
long el_s_PX(int c) { return *gpl - hla[c]; }
long el_s_PN(int c) { return *gpl - !hl; }
long el_s_PU(int c) { return *gpl - -hl; }
long el_s_PB(int c) { return *gpl - (hl - hm); }
long el_s_PC(int c) { return *gpl - (256L - hl); }
long el_s_PT(int c) { return *gpl - (hc ? hl : hm); }
long el_s_PS(int c) { return *gpl - (hl << c); }
long el_s_PD(int c) { return *gpl - hps->l; }
long el_s_EK(int c) { return gla[3] - 7L; }
long el_s_EG(int c) { return gla[3] - hl; }
long el_s_EM(int c) { return gla[3] - hs.l; }
long el_s_EP(int c) { return gla[3] - *hpl; }
long el_s_EE(int c) { return gla[3] - hla[3]; }
long el_s_EX(int c) { return gla[3] - hla[c]; }
long el_s_EN(int c) { return gla[3] - !hl; }
long el_s_EU(int c) { return gla[3] - -hl; }
long el_s_EB(int c) { return gla[3] - (hl - hm); }
long el_s_EC(int c) { return gla[3] - (256L - hl); }
long el_s_ET(int c) { return gla[3] - (hc ? hl : hm); }
long el_s_ES(int c) { return gla[3] - (hl << c); }
long el_s_ED(int c) { return gla[3] - hps->l; }
long el_s_XK(int c) { return gla[c] - 7L; }
long el_s_XG(int c) { return gla[c] - hl; }
long el_s_XM(int c) { return gla[c] - hs.l; }
long el_s_XP(int c) { return gla[c] - *hpl; }
long el_s_XE(int c) { return gla[c] - hla[3]; }
long el_s_XX(int c) { return gla[c] - hla[c]; }
long el_s_XN(int c) { return gla[c] - !hl; }
long el_s_XU(int c) { return gla[c] - -hl; }
long el_s_XB(int c) { return gla[c] - (hl - hm); }
long el_s_XC(int c) { return gla[c] - (256L - hl); }
long el_s_XT(int c) { return gla[c] - (hc ? hl : hm); }
long el_s_XS(int c) { return gla[c] - (hl << c); }
long el_s_XD(int c) { return gla[c] - hps->l; }
long el_s_NK(int c) { return !gl - 7L; }
long el_s_NG(int c) { return !gl - hl; }
long el_s_NM(int c) { return !gl - hs.l; }
long el_s_NP(int c) { return !gl - *hpl; }
long el_s_NE(int c) { return !gl - hla[3]; }
long el_s_NX(int c) { return !gl - hla[c]; }
long el_s_NN(int c) { return !gl - !hl; }
long el_s_NU(int c) { return !gl - -hl; }
long el_s_NB(int c) { return !gl - (hl - hm); }
long el_s_NC(int c) { return !gl - (256L - hl); }
long el_s_NT(int c) { return !gl - (hc ? hl : hm); }
long el_s_NS(int c) { return !gl - (hl << c); }
long el_s_ND(int c) { return !gl - hps->l; }
long el_s_UK(int c) { return -gl - 7L; }
long el_s_UG(int c) { return -gl - hl; }
long el_s_UM(int c) { return -gl - hs.l; }
long el_s_UP(int c) { return -gl - *hpl; }
long el_s_UE(int c) { return -gl - hla[3]; }
long el_s_UX(int c) { return -gl - hla[c]; }
long el_s_UN(int c) { return -gl - !hl; }
long el_s_UU(int c) { return -gl - -hl; }
long el_s_UB(int c) { return -gl - (hl - hm); }
long el_s_UC(int c) { return -gl - (256L - hl); }
long el_s_UT(int c) { return -gl - (hc ? hl : hm); }
long el_s_US(int c) { return -gl - (hl << c); }
long el_s_UD(int c) { return -gl - hps->l; }
long el_s_BK(int c) { return (gl - gm) - 7L; }
long el_s_BG(int c) { return (gl - gm) - hl; }
long el_s_BM(int c) { return (gl - gm) - hs.l; }
long el_s_BP(int c) { return (gl - gm) - *hpl; }
long el_s_BE(int c) { return (gl - gm) - hla[3]; }
long el_s_BX(int c) { return (gl - gm) - hla[c]; }
long el_s_BN(int c) { return (gl - gm) - !hl; }
long el_s_BU(int c) { return (gl - gm) - -hl; }
long el_s_BB(int c) { return (gl - gm) - (hl - hm); }
long el_s_BC(int c) { return (gl - gm) - (256L - hl); }
long el_s_BT(int c) { return (gl - gm) - (hc ? hl : hm); }
long el_s_BS(int c) { return (gl - gm) - (hl << c); }
long el_s_BD(int c) { return (gl - gm) - hps->l; }
long el_s_CK(int c) { return (256L - gl) - 7L; }
long el_s_CG(int c) { return (256L - gl) - hl; }
long el_s_CM(int c) { return (256L - gl) - hs.l; }
long el_s_CP(int c) { return (256L - gl) - *hpl; }
long el_s_CE(int c) { return (256L - gl) - hla[3]; }
long el_s_CX(int c) { return (256L - gl) - hla[c]; }
long el_s_CN(int c) { return (256L - gl) - !hl; }
long el_s_CU(int c) { return (256L - gl) - -hl; }
long el_s_CB(int c) { return (256L - gl) - (hl - hm); }
long el_s_CC(int c) { return (256L - gl) - (256L - hl); }
long el_s_CT(int c) { return (256L - gl) - (hc ? hl : hm); }
long el_s_CS(int c) { return (256L - gl) - (hl << c); }
long el_s_CD(int c) { return (256L - gl) - hps->l; }
long el_s_TK(int c) { return (gc ? gl : gm) - 7L; }
long el_s_TG(int c) { return (gc ? gl : gm) - hl; }
long el_s_TM(int c) { return (gc ? gl : gm) - hs.l; }
long el_s_TP(int c) { return (gc ? gl : gm) - *hpl; }
long el_s_TE(int c) { return (gc ? gl : gm) - hla[3]; }
long el_s_TX(int c) { return (gc ? gl : gm) - hla[c]; }
long el_s_TN(int c) { return (gc ? gl : gm) - !hl; }
long el_s_TU(int c) { return (gc ? gl : gm) - -hl; }
long el_s_TB(int c) { return (gc ? gl : gm) - (hl - hm); }
long el_s_TC(int c) { return (gc ? gl : gm) - (256L - hl); }
long el_s_TT(int c) { return (gc ? gl : gm) - (hc ? hl : hm); }
long el_s_TS(int c) { return (gc ? gl : gm) - (hl << c); }
long el_s_TD(int c) { return (gc ? gl : gm) - hps->l; }
long el_s_SK(int c) { return (gl << c) - 7L; }
long el_s_SG(int c) { return (gl << c) - hl; }
long el_s_SM(int c) { return (gl << c) - hs.l; }
long el_s_SP(int c) { return (gl << c) - *hpl; }
long el_s_SE(int c) { return (gl << c) - hla[3]; }
long el_s_SX(int c) { return (gl << c) - hla[c]; }
long el_s_SN(int c) { return (gl << c) - !hl; }
long el_s_SU(int c) { return (gl << c) - -hl; }
long el_s_SB(int c) { return (gl << c) - (hl - hm); }
long el_s_SC(int c) { return (gl << c) - (256L - hl); }
long el_s_ST(int c) { return (gl << c) - (hc ? hl : hm); }
long el_s_SS(int c) { return (gl << c) - (hl << c); }
long el_s_SD(int c) { return (gl << c) - hps->l; }
long el_s_DK(int c) { return gps->l - 7L; }
long el_s_DG(int c) { return gps->l - hl; }
long el_s_DM(int c) { return gps->l - hs.l; }
long el_s_DP(int c) { return gps->l - *hpl; }
long el_s_DE(int c) { return gps->l - hla[3]; }
long el_s_DX(int c) { return gps->l - hla[c]; }
long el_s_DN(int c) { return gps->l - !hl; }
long el_s_DU(int c) { return gps->l - -hl; }
long el_s_DB(int c) { return gps->l - (hl - hm); }
long el_s_DC(int c) { return gps->l - (256L - hl); }
long el_s_DT(int c) { return gps->l - (hc ? hl : hm); }
long el_s_DS(int c) { return gps->l - (hl << c); }
long el_s_DD(int c) { return gps->l - hps->l; }

long el_x_KK(int c) { return 7L ^ 7L; }
long el_x_KG(int c) { return 7L ^ hl; }
long el_x_KM(int c) { return 7L ^ hs.l; }
long el_x_KP(int c) { return 7L ^ *hpl; }
long el_x_KE(int c) { return 7L ^ hla[3]; }
long el_x_KX(int c) { return 7L ^ hla[c]; }
long el_x_KN(int c) { return 7L ^ !hl; }
long el_x_KU(int c) { return 7L ^ -hl; }
long el_x_KB(int c) { return 7L ^ (hl - hm); }
long el_x_KC(int c) { return 7L ^ (256L - hl); }
long el_x_KT(int c) { return 7L ^ (hc ? hl : hm); }
long el_x_KS(int c) { return 7L ^ (hl << c); }
long el_x_KD(int c) { return 7L ^ hps->l; }
long el_x_GK(int c) { return gl ^ 7L; }
long el_x_GG(int c) { return gl ^ hl; }
long el_x_GM(int c) { return gl ^ hs.l; }
long el_x_GP(int c) { return gl ^ *hpl; }
long el_x_GE(int c) { return gl ^ hla[3]; }
long el_x_GX(int c) { return gl ^ hla[c]; }
long el_x_GN(int c) { return gl ^ !hl; }
long el_x_GU(int c) { return gl ^ -hl; }
long el_x_GB(int c) { return gl ^ (hl - hm); }
long el_x_GC(int c) { return gl ^ (256L - hl); }
long el_x_GT(int c) { return gl ^ (hc ? hl : hm); }
long el_x_GS(int c) { return gl ^ (hl << c); }
long el_x_GD(int c) { return gl ^ hps->l; }
long el_x_MK(int c) { return gs.l ^ 7L; }
long el_x_MG(int c) { return gs.l ^ hl; }
long el_x_MM(int c) { return gs.l ^ hs.l; }
long el_x_MP(int c) { return gs.l ^ *hpl; }
long el_x_ME(int c) { return gs.l ^ hla[3]; }
long el_x_MX(int c) { return gs.l ^ hla[c]; }
long el_x_MN(int c) { return gs.l ^ !hl; }
long el_x_MU(int c) { return gs.l ^ -hl; }
long el_x_MB(int c) { return gs.l ^ (hl - hm); }
long el_x_MC(int c) { return gs.l ^ (256L - hl); }
long el_x_MT(int c) { return gs.l ^ (hc ? hl : hm); }
long el_x_MS(int c) { return gs.l ^ (hl << c); }
long el_x_MD(int c) { return gs.l ^ hps->l; }
long el_x_PK(int c) { return *gpl ^ 7L; }
long el_x_PG(int c) { return *gpl ^ hl; }
long el_x_PM(int c) { return *gpl ^ hs.l; }
long el_x_PP(int c) { return *gpl ^ *hpl; }
long el_x_PE(int c) { return *gpl ^ hla[3]; }
long el_x_PX(int c) { return *gpl ^ hla[c]; }
long el_x_PN(int c) { return *gpl ^ !hl; }
long el_x_PU(int c) { return *gpl ^ -hl; }
long el_x_PB(int c) { return *gpl ^ (hl - hm); }
long el_x_PC(int c) { return *gpl ^ (256L - hl); }
long el_x_PT(int c) { return *gpl ^ (hc ? hl : hm); }
long el_x_PS(int c) { return *gpl ^ (hl << c); }
long el_x_PD(int c) { return *gpl ^ hps->l; }
long el_x_EK(int c) { return gla[3] ^ 7L; }
long el_x_EG(int c) { return gla[3] ^ hl; }
long el_x_EM(int c) { return gla[3] ^ hs.l; }
long el_x_EP(int c) { return gla[3] ^ *hpl; }
long el_x_EE(int c) { return gla[3] ^ hla[3]; }
long el_x_EX(int c) { return gla[3] ^ hla[c]; }
long el_x_EN(int c) { return gla[3] ^ !hl; }
long el_x_EU(int c) { return gla[3] ^ -hl; }
long el_x_EB(int c) { return gla[3] ^ (hl - hm); }
long el_x_EC(int c) { return gla[3] ^ (256L - hl); }
long el_x_ET(int c) { return gla[3] ^ (hc ? hl : hm); }
long el_x_ES(int c) { return gla[3] ^ (hl << c); }
long el_x_ED(int c) { return gla[3] ^ hps->l; }
long el_x_XK(int c) { return gla[c] ^ 7L; }
long el_x_XG(int c) { return gla[c] ^ hl; }
long el_x_XM(int c) { return gla[c] ^ hs.l; }
long el_x_XP(int c) { return gla[c] ^ *hpl; }
long el_x_XE(int c) { return gla[c] ^ hla[3]; }
long el_x_XX(int c) { return gla[c] ^ hla[c]; }
long el_x_XN(int c) { return gla[c] ^ !hl; }
long el_x_XU(int c) { return gla[c] ^ -hl; }
long el_x_XB(int c) { return gla[c] ^ (hl - hm); }
long el_x_XC(int c) { return gla[c] ^ (256L - hl); }
long el_x_XT(int c) { return gla[c] ^ (hc ? hl : hm); }
long el_x_XS(int c) { return gla[c] ^ (hl << c); }
long el_x_XD(int c) { return gla[c] ^ hps->l; }
long el_x_NK(int c) { return !gl ^ 7L; }
long el_x_NG(int c) { return !gl ^ hl; }
long el_x_NM(int c) { return !gl ^ hs.l; }
long el_x_NP(int c) { return !gl ^ *hpl; }
long el_x_NE(int c) { return !gl ^ hla[3]; }
long el_x_NX(int c) { return !gl ^ hla[c]; }
long el_x_NN(int c) { return !gl ^ !hl; }
long el_x_NU(int c) { return !gl ^ -hl; }
long el_x_NB(int c) { return !gl ^ (hl - hm); }
long el_x_NC(int c) { return !gl ^ (256L - hl); }
long el_x_NT(int c) { return !gl ^ (hc ? hl : hm); }
long el_x_NS(int c) { return !gl ^ (hl << c); }
long el_x_ND(int c) { return !gl ^ hps->l; }
long el_x_UK(int c) { return -gl ^ 7L; }
long el_x_UG(int c) { return -gl ^ hl; }
long el_x_UM(int c) { return -gl ^ hs.l; }
long el_x_UP(int c) { return -gl ^ *hpl; }
long el_x_UE(int c) { return -gl ^ hla[3]; }
long el_x_UX(int c) { return -gl ^ hla[c]; }
long el_x_UN(int c) { return -gl ^ !hl; }
long el_x_UU(int c) { return -gl ^ -hl; }
long el_x_UB(int c) { return -gl ^ (hl - hm); }
long el_x_UC(int c) { return -gl ^ (256L - hl); }
long el_x_UT(int c) { return -gl ^ (hc ? hl : hm); }
long el_x_US(int c) { return -gl ^ (hl << c); }
long el_x_UD(int c) { return -gl ^ hps->l; }
long el_x_BK(int c) { return (gl - gm) ^ 7L; }
long el_x_BG(int c) { return (gl - gm) ^ hl; }
long el_x_BM(int c) { return (gl - gm) ^ hs.l; }
long el_x_BP(int c) { return (gl - gm) ^ *hpl; }
long el_x_BE(int c) { return (gl - gm) ^ hla[3]; }
long el_x_BX(int c) { return (gl - gm) ^ hla[c]; }
long el_x_BN(int c) { return (gl - gm) ^ !hl; }
long el_x_BU(int c) { return (gl - gm) ^ -hl; }
long el_x_BB(int c) { return (gl - gm) ^ (hl - hm); }
long el_x_BC(int c) { return (gl - gm) ^ (256L - hl); }
long el_x_BT(int c) { return (gl - gm) ^ (hc ? hl : hm); }
long el_x_BS(int c) { return (gl - gm) ^ (hl << c); }
long el_x_BD(int c) { return (gl - gm) ^ hps->l; }
long el_x_CK(int c) { return (256L - gl) ^ 7L; }
long el_x_CG(int c) { return (256L - gl) ^ hl; }
long el_x_CM(int c) { return (256L - gl) ^ hs.l; }
long el_x_CP(int c) { return (256L - gl) ^ *hpl; }
long el_x_CE(int c) { return (256L - gl) ^ hla[3]; }
long el_x_CX(int c) { return (256L - gl) ^ hla[c]; }
long el_x_CN(int c) { return (256L - gl) ^ !hl; }
long el_x_CU(int c) { return (256L - gl) ^ -hl; }
long el_x_CB(int c) { return (256L - gl) ^ (hl - hm); }
long el_x_CC(int c) { return (256L - gl) ^ (256L - hl); }
long el_x_CT(int c) { return (256L - gl) ^ (hc ? hl : hm); }
long el_x_CS(int c) { return (256L - gl) ^ (hl << c); }
long el_x_CD(int c) { return (256L - gl) ^ hps->l; }
long el_x_TK(int c) { return (gc ? gl : gm) ^ 7L; }
long el_x_TG(int c) { return (gc ? gl : gm) ^ hl; }
long el_x_TM(int c) { return (gc ? gl : gm) ^ hs.l; }
long el_x_TP(int c) { return (gc ? gl : gm) ^ *hpl; }
long el_x_TE(int c) { return (gc ? gl : gm) ^ hla[3]; }
long el_x_TX(int c) { return (gc ? gl : gm) ^ hla[c]; }
long el_x_TN(int c) { return (gc ? gl : gm) ^ !hl; }
long el_x_TU(int c) { return (gc ? gl : gm) ^ -hl; }
long el_x_TB(int c) { return (gc ? gl : gm) ^ (hl - hm); }
long el_x_TC(int c) { return (gc ? gl : gm) ^ (256L - hl); }
long el_x_TT(int c) { return (gc ? gl : gm) ^ (hc ? hl : hm); }
long el_x_TS(int c) { return (gc ? gl : gm) ^ (hl << c); }
long el_x_TD(int c) { return (gc ? gl : gm) ^ hps->l; }
long el_x_SK(int c) { return (gl << c) ^ 7L; }
long el_x_SG(int c) { return (gl << c) ^ hl; }
long el_x_SM(int c) { return (gl << c) ^ hs.l; }
long el_x_SP(int c) { return (gl << c) ^ *hpl; }
long el_x_SE(int c) { return (gl << c) ^ hla[3]; }
long el_x_SX(int c) { return (gl << c) ^ hla[c]; }
long el_x_SN(int c) { return (gl << c) ^ !hl; }
long el_x_SU(int c) { return (gl << c) ^ -hl; }
long el_x_SB(int c) { return (gl << c) ^ (hl - hm); }
long el_x_SC(int c) { return (gl << c) ^ (256L - hl); }
long el_x_ST(int c) { return (gl << c) ^ (hc ? hl : hm); }
long el_x_SS(int c) { return (gl << c) ^ (hl << c); }
long el_x_SD(int c) { return (gl << c) ^ hps->l; }
long el_x_DK(int c) { return gps->l ^ 7L; }
long el_x_DG(int c) { return gps->l ^ hl; }
long el_x_DM(int c) { return gps->l ^ hs.l; }
long el_x_DP(int c) { return gps->l ^ *hpl; }
long el_x_DE(int c) { return gps->l ^ hla[3]; }
long el_x_DX(int c) { return gps->l ^ hla[c]; }
long el_x_DN(int c) { return gps->l ^ !hl; }
long el_x_DU(int c) { return gps->l ^ -hl; }
long el_x_DB(int c) { return gps->l ^ (hl - hm); }
long el_x_DC(int c) { return gps->l ^ (256L - hl); }
long el_x_DT(int c) { return gps->l ^ (hc ? hl : hm); }
long el_x_DS(int c) { return gps->l ^ (hl << c); }
long el_x_DD(int c) { return gps->l ^ hps->l; }
