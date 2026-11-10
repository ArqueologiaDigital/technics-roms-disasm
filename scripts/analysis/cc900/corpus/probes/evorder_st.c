/* Evaluation order, second probe (gen_evorder2.py): the int kinds of evorder.c as a value stored into a global
   (es_<op>_<L><R>: gi3 = L op R) and as an argument (ea_<op>_<L><R>: v1(L op R)), for - and ^; the left side
   reads g* globals, the right h*. */
struct st { int i; int a[4]; long l; };
extern int gi, gj, gc, hi, hj, hc, gi3; extern int gia[10], hia[10]; extern int *gpi, *hpi;
extern long gl, gm, hl, hm; extern long gla[10], hla[10]; extern long *gpl, *hpl;
extern struct st gs, *gps, hs, *hps; extern void v1(int);

void es_s_KK(int c) { gi3 = 7 - 7; }
void es_s_KG(int c) { gi3 = 7 - hi; }
void es_s_KM(int c) { gi3 = 7 - hs.i; }
void es_s_KP(int c) { gi3 = 7 - *hpi; }
void es_s_KE(int c) { gi3 = 7 - hia[3]; }
void es_s_KX(int c) { gi3 = 7 - hia[c]; }
void es_s_KN(int c) { gi3 = 7 - !hi; }
void es_s_KU(int c) { gi3 = 7 - -hi; }
void es_s_KB(int c) { gi3 = 7 - (hi - hj); }
void es_s_KC(int c) { gi3 = 7 - (256 - hi); }
void es_s_KT(int c) { gi3 = 7 - (hc ? hi : hj); }
void es_s_KS(int c) { gi3 = 7 - (hi << c); }
void es_s_KD(int c) { gi3 = 7 - hps->i; }
void es_s_GK(int c) { gi3 = gi - 7; }
void es_s_GG(int c) { gi3 = gi - hi; }
void es_s_GM(int c) { gi3 = gi - hs.i; }
void es_s_GP(int c) { gi3 = gi - *hpi; }
void es_s_GE(int c) { gi3 = gi - hia[3]; }
void es_s_GX(int c) { gi3 = gi - hia[c]; }
void es_s_GN(int c) { gi3 = gi - !hi; }
void es_s_GU(int c) { gi3 = gi - -hi; }
void es_s_GB(int c) { gi3 = gi - (hi - hj); }
void es_s_GC(int c) { gi3 = gi - (256 - hi); }
void es_s_GT(int c) { gi3 = gi - (hc ? hi : hj); }
void es_s_GS(int c) { gi3 = gi - (hi << c); }
void es_s_GD(int c) { gi3 = gi - hps->i; }
void es_s_MK(int c) { gi3 = gs.i - 7; }
void es_s_MG(int c) { gi3 = gs.i - hi; }
void es_s_MM(int c) { gi3 = gs.i - hs.i; }
void es_s_MP(int c) { gi3 = gs.i - *hpi; }
void es_s_ME(int c) { gi3 = gs.i - hia[3]; }
void es_s_MX(int c) { gi3 = gs.i - hia[c]; }
void es_s_MN(int c) { gi3 = gs.i - !hi; }
void es_s_MU(int c) { gi3 = gs.i - -hi; }
void es_s_MB(int c) { gi3 = gs.i - (hi - hj); }
void es_s_MC(int c) { gi3 = gs.i - (256 - hi); }
void es_s_MT(int c) { gi3 = gs.i - (hc ? hi : hj); }
void es_s_MS(int c) { gi3 = gs.i - (hi << c); }
void es_s_MD(int c) { gi3 = gs.i - hps->i; }
void es_s_PK(int c) { gi3 = *gpi - 7; }
void es_s_PG(int c) { gi3 = *gpi - hi; }
void es_s_PM(int c) { gi3 = *gpi - hs.i; }
void es_s_PP(int c) { gi3 = *gpi - *hpi; }
void es_s_PE(int c) { gi3 = *gpi - hia[3]; }
void es_s_PX(int c) { gi3 = *gpi - hia[c]; }
void es_s_PN(int c) { gi3 = *gpi - !hi; }
void es_s_PU(int c) { gi3 = *gpi - -hi; }
void es_s_PB(int c) { gi3 = *gpi - (hi - hj); }
void es_s_PC(int c) { gi3 = *gpi - (256 - hi); }
void es_s_PT(int c) { gi3 = *gpi - (hc ? hi : hj); }
void es_s_PS(int c) { gi3 = *gpi - (hi << c); }
void es_s_PD(int c) { gi3 = *gpi - hps->i; }
void es_s_EK(int c) { gi3 = gia[3] - 7; }
void es_s_EG(int c) { gi3 = gia[3] - hi; }
void es_s_EM(int c) { gi3 = gia[3] - hs.i; }
void es_s_EP(int c) { gi3 = gia[3] - *hpi; }
void es_s_EE(int c) { gi3 = gia[3] - hia[3]; }
void es_s_EX(int c) { gi3 = gia[3] - hia[c]; }
void es_s_EN(int c) { gi3 = gia[3] - !hi; }
void es_s_EU(int c) { gi3 = gia[3] - -hi; }
void es_s_EB(int c) { gi3 = gia[3] - (hi - hj); }
void es_s_EC(int c) { gi3 = gia[3] - (256 - hi); }
void es_s_ET(int c) { gi3 = gia[3] - (hc ? hi : hj); }
void es_s_ES(int c) { gi3 = gia[3] - (hi << c); }
void es_s_ED(int c) { gi3 = gia[3] - hps->i; }
void es_s_XK(int c) { gi3 = gia[c] - 7; }
void es_s_XG(int c) { gi3 = gia[c] - hi; }
void es_s_XM(int c) { gi3 = gia[c] - hs.i; }
void es_s_XP(int c) { gi3 = gia[c] - *hpi; }
void es_s_XE(int c) { gi3 = gia[c] - hia[3]; }
void es_s_XX(int c) { gi3 = gia[c] - hia[c]; }
void es_s_XN(int c) { gi3 = gia[c] - !hi; }
void es_s_XU(int c) { gi3 = gia[c] - -hi; }
void es_s_XB(int c) { gi3 = gia[c] - (hi - hj); }
void es_s_XC(int c) { gi3 = gia[c] - (256 - hi); }
void es_s_XT(int c) { gi3 = gia[c] - (hc ? hi : hj); }
void es_s_XS(int c) { gi3 = gia[c] - (hi << c); }
void es_s_XD(int c) { gi3 = gia[c] - hps->i; }
void es_s_NK(int c) { gi3 = !gi - 7; }
void es_s_NG(int c) { gi3 = !gi - hi; }
void es_s_NM(int c) { gi3 = !gi - hs.i; }
void es_s_NP(int c) { gi3 = !gi - *hpi; }
void es_s_NE(int c) { gi3 = !gi - hia[3]; }
void es_s_NX(int c) { gi3 = !gi - hia[c]; }
void es_s_NN(int c) { gi3 = !gi - !hi; }
void es_s_NU(int c) { gi3 = !gi - -hi; }
void es_s_NB(int c) { gi3 = !gi - (hi - hj); }
void es_s_NC(int c) { gi3 = !gi - (256 - hi); }
void es_s_NT(int c) { gi3 = !gi - (hc ? hi : hj); }
void es_s_NS(int c) { gi3 = !gi - (hi << c); }
void es_s_ND(int c) { gi3 = !gi - hps->i; }
void es_s_UK(int c) { gi3 = -gi - 7; }
void es_s_UG(int c) { gi3 = -gi - hi; }
void es_s_UM(int c) { gi3 = -gi - hs.i; }
void es_s_UP(int c) { gi3 = -gi - *hpi; }
void es_s_UE(int c) { gi3 = -gi - hia[3]; }
void es_s_UX(int c) { gi3 = -gi - hia[c]; }
void es_s_UN(int c) { gi3 = -gi - !hi; }
void es_s_UU(int c) { gi3 = -gi - -hi; }
void es_s_UB(int c) { gi3 = -gi - (hi - hj); }
void es_s_UC(int c) { gi3 = -gi - (256 - hi); }
void es_s_UT(int c) { gi3 = -gi - (hc ? hi : hj); }
void es_s_US(int c) { gi3 = -gi - (hi << c); }
void es_s_UD(int c) { gi3 = -gi - hps->i; }
void es_s_BK(int c) { gi3 = (gi - gj) - 7; }
void es_s_BG(int c) { gi3 = (gi - gj) - hi; }
void es_s_BM(int c) { gi3 = (gi - gj) - hs.i; }
void es_s_BP(int c) { gi3 = (gi - gj) - *hpi; }
void es_s_BE(int c) { gi3 = (gi - gj) - hia[3]; }
void es_s_BX(int c) { gi3 = (gi - gj) - hia[c]; }
void es_s_BN(int c) { gi3 = (gi - gj) - !hi; }
void es_s_BU(int c) { gi3 = (gi - gj) - -hi; }
void es_s_BB(int c) { gi3 = (gi - gj) - (hi - hj); }
void es_s_BC(int c) { gi3 = (gi - gj) - (256 - hi); }
void es_s_BT(int c) { gi3 = (gi - gj) - (hc ? hi : hj); }
void es_s_BS(int c) { gi3 = (gi - gj) - (hi << c); }
void es_s_BD(int c) { gi3 = (gi - gj) - hps->i; }
void es_s_CK(int c) { gi3 = (256 - gi) - 7; }
void es_s_CG(int c) { gi3 = (256 - gi) - hi; }
void es_s_CM(int c) { gi3 = (256 - gi) - hs.i; }
void es_s_CP(int c) { gi3 = (256 - gi) - *hpi; }
void es_s_CE(int c) { gi3 = (256 - gi) - hia[3]; }
void es_s_CX(int c) { gi3 = (256 - gi) - hia[c]; }
void es_s_CN(int c) { gi3 = (256 - gi) - !hi; }
void es_s_CU(int c) { gi3 = (256 - gi) - -hi; }
void es_s_CB(int c) { gi3 = (256 - gi) - (hi - hj); }
void es_s_CC(int c) { gi3 = (256 - gi) - (256 - hi); }
void es_s_CT(int c) { gi3 = (256 - gi) - (hc ? hi : hj); }
void es_s_CS(int c) { gi3 = (256 - gi) - (hi << c); }
void es_s_CD(int c) { gi3 = (256 - gi) - hps->i; }
void es_s_TK(int c) { gi3 = (gc ? gi : gj) - 7; }
void es_s_TG(int c) { gi3 = (gc ? gi : gj) - hi; }
void es_s_TM(int c) { gi3 = (gc ? gi : gj) - hs.i; }
void es_s_TP(int c) { gi3 = (gc ? gi : gj) - *hpi; }
void es_s_TE(int c) { gi3 = (gc ? gi : gj) - hia[3]; }
void es_s_TX(int c) { gi3 = (gc ? gi : gj) - hia[c]; }
void es_s_TN(int c) { gi3 = (gc ? gi : gj) - !hi; }
void es_s_TU(int c) { gi3 = (gc ? gi : gj) - -hi; }
void es_s_TB(int c) { gi3 = (gc ? gi : gj) - (hi - hj); }
void es_s_TC(int c) { gi3 = (gc ? gi : gj) - (256 - hi); }
void es_s_TT(int c) { gi3 = (gc ? gi : gj) - (hc ? hi : hj); }
void es_s_TS(int c) { gi3 = (gc ? gi : gj) - (hi << c); }
void es_s_TD(int c) { gi3 = (gc ? gi : gj) - hps->i; }
void es_s_SK(int c) { gi3 = (gi << c) - 7; }
void es_s_SG(int c) { gi3 = (gi << c) - hi; }
void es_s_SM(int c) { gi3 = (gi << c) - hs.i; }
void es_s_SP(int c) { gi3 = (gi << c) - *hpi; }
void es_s_SE(int c) { gi3 = (gi << c) - hia[3]; }
void es_s_SX(int c) { gi3 = (gi << c) - hia[c]; }
void es_s_SN(int c) { gi3 = (gi << c) - !hi; }
void es_s_SU(int c) { gi3 = (gi << c) - -hi; }
void es_s_SB(int c) { gi3 = (gi << c) - (hi - hj); }
void es_s_SC(int c) { gi3 = (gi << c) - (256 - hi); }
void es_s_ST(int c) { gi3 = (gi << c) - (hc ? hi : hj); }
void es_s_SS(int c) { gi3 = (gi << c) - (hi << c); }
void es_s_SD(int c) { gi3 = (gi << c) - hps->i; }
void es_s_DK(int c) { gi3 = gps->i - 7; }
void es_s_DG(int c) { gi3 = gps->i - hi; }
void es_s_DM(int c) { gi3 = gps->i - hs.i; }
void es_s_DP(int c) { gi3 = gps->i - *hpi; }
void es_s_DE(int c) { gi3 = gps->i - hia[3]; }
void es_s_DX(int c) { gi3 = gps->i - hia[c]; }
void es_s_DN(int c) { gi3 = gps->i - !hi; }
void es_s_DU(int c) { gi3 = gps->i - -hi; }
void es_s_DB(int c) { gi3 = gps->i - (hi - hj); }
void es_s_DC(int c) { gi3 = gps->i - (256 - hi); }
void es_s_DT(int c) { gi3 = gps->i - (hc ? hi : hj); }
void es_s_DS(int c) { gi3 = gps->i - (hi << c); }
void es_s_DD(int c) { gi3 = gps->i - hps->i; }

void es_x_KK(int c) { gi3 = 7 ^ 7; }
void es_x_KG(int c) { gi3 = 7 ^ hi; }
void es_x_KM(int c) { gi3 = 7 ^ hs.i; }
void es_x_KP(int c) { gi3 = 7 ^ *hpi; }
void es_x_KE(int c) { gi3 = 7 ^ hia[3]; }
void es_x_KX(int c) { gi3 = 7 ^ hia[c]; }
void es_x_KN(int c) { gi3 = 7 ^ !hi; }
void es_x_KU(int c) { gi3 = 7 ^ -hi; }
void es_x_KB(int c) { gi3 = 7 ^ (hi - hj); }
void es_x_KC(int c) { gi3 = 7 ^ (256 - hi); }
void es_x_KT(int c) { gi3 = 7 ^ (hc ? hi : hj); }
void es_x_KS(int c) { gi3 = 7 ^ (hi << c); }
void es_x_KD(int c) { gi3 = 7 ^ hps->i; }
void es_x_GK(int c) { gi3 = gi ^ 7; }
void es_x_GG(int c) { gi3 = gi ^ hi; }
void es_x_GM(int c) { gi3 = gi ^ hs.i; }
void es_x_GP(int c) { gi3 = gi ^ *hpi; }
void es_x_GE(int c) { gi3 = gi ^ hia[3]; }
void es_x_GX(int c) { gi3 = gi ^ hia[c]; }
void es_x_GN(int c) { gi3 = gi ^ !hi; }
void es_x_GU(int c) { gi3 = gi ^ -hi; }
void es_x_GB(int c) { gi3 = gi ^ (hi - hj); }
void es_x_GC(int c) { gi3 = gi ^ (256 - hi); }
void es_x_GT(int c) { gi3 = gi ^ (hc ? hi : hj); }
void es_x_GS(int c) { gi3 = gi ^ (hi << c); }
void es_x_GD(int c) { gi3 = gi ^ hps->i; }
void es_x_MK(int c) { gi3 = gs.i ^ 7; }
void es_x_MG(int c) { gi3 = gs.i ^ hi; }
void es_x_MM(int c) { gi3 = gs.i ^ hs.i; }
void es_x_MP(int c) { gi3 = gs.i ^ *hpi; }
void es_x_ME(int c) { gi3 = gs.i ^ hia[3]; }
void es_x_MX(int c) { gi3 = gs.i ^ hia[c]; }
void es_x_MN(int c) { gi3 = gs.i ^ !hi; }
void es_x_MU(int c) { gi3 = gs.i ^ -hi; }
void es_x_MB(int c) { gi3 = gs.i ^ (hi - hj); }
void es_x_MC(int c) { gi3 = gs.i ^ (256 - hi); }
void es_x_MT(int c) { gi3 = gs.i ^ (hc ? hi : hj); }
void es_x_MS(int c) { gi3 = gs.i ^ (hi << c); }
void es_x_MD(int c) { gi3 = gs.i ^ hps->i; }
void es_x_PK(int c) { gi3 = *gpi ^ 7; }
void es_x_PG(int c) { gi3 = *gpi ^ hi; }
void es_x_PM(int c) { gi3 = *gpi ^ hs.i; }
void es_x_PP(int c) { gi3 = *gpi ^ *hpi; }
void es_x_PE(int c) { gi3 = *gpi ^ hia[3]; }
void es_x_PX(int c) { gi3 = *gpi ^ hia[c]; }
void es_x_PN(int c) { gi3 = *gpi ^ !hi; }
void es_x_PU(int c) { gi3 = *gpi ^ -hi; }
void es_x_PB(int c) { gi3 = *gpi ^ (hi - hj); }
void es_x_PC(int c) { gi3 = *gpi ^ (256 - hi); }
void es_x_PT(int c) { gi3 = *gpi ^ (hc ? hi : hj); }
void es_x_PS(int c) { gi3 = *gpi ^ (hi << c); }
void es_x_PD(int c) { gi3 = *gpi ^ hps->i; }
void es_x_EK(int c) { gi3 = gia[3] ^ 7; }
void es_x_EG(int c) { gi3 = gia[3] ^ hi; }
void es_x_EM(int c) { gi3 = gia[3] ^ hs.i; }
void es_x_EP(int c) { gi3 = gia[3] ^ *hpi; }
void es_x_EE(int c) { gi3 = gia[3] ^ hia[3]; }
void es_x_EX(int c) { gi3 = gia[3] ^ hia[c]; }
void es_x_EN(int c) { gi3 = gia[3] ^ !hi; }
void es_x_EU(int c) { gi3 = gia[3] ^ -hi; }
void es_x_EB(int c) { gi3 = gia[3] ^ (hi - hj); }
void es_x_EC(int c) { gi3 = gia[3] ^ (256 - hi); }
void es_x_ET(int c) { gi3 = gia[3] ^ (hc ? hi : hj); }
void es_x_ES(int c) { gi3 = gia[3] ^ (hi << c); }
void es_x_ED(int c) { gi3 = gia[3] ^ hps->i; }
void es_x_XK(int c) { gi3 = gia[c] ^ 7; }
void es_x_XG(int c) { gi3 = gia[c] ^ hi; }
void es_x_XM(int c) { gi3 = gia[c] ^ hs.i; }
void es_x_XP(int c) { gi3 = gia[c] ^ *hpi; }
void es_x_XE(int c) { gi3 = gia[c] ^ hia[3]; }
void es_x_XX(int c) { gi3 = gia[c] ^ hia[c]; }
void es_x_XN(int c) { gi3 = gia[c] ^ !hi; }
void es_x_XU(int c) { gi3 = gia[c] ^ -hi; }
void es_x_XB(int c) { gi3 = gia[c] ^ (hi - hj); }
void es_x_XC(int c) { gi3 = gia[c] ^ (256 - hi); }
void es_x_XT(int c) { gi3 = gia[c] ^ (hc ? hi : hj); }
void es_x_XS(int c) { gi3 = gia[c] ^ (hi << c); }
void es_x_XD(int c) { gi3 = gia[c] ^ hps->i; }
void es_x_NK(int c) { gi3 = !gi ^ 7; }
void es_x_NG(int c) { gi3 = !gi ^ hi; }
void es_x_NM(int c) { gi3 = !gi ^ hs.i; }
void es_x_NP(int c) { gi3 = !gi ^ *hpi; }
void es_x_NE(int c) { gi3 = !gi ^ hia[3]; }
void es_x_NX(int c) { gi3 = !gi ^ hia[c]; }
void es_x_NN(int c) { gi3 = !gi ^ !hi; }
void es_x_NU(int c) { gi3 = !gi ^ -hi; }
void es_x_NB(int c) { gi3 = !gi ^ (hi - hj); }
void es_x_NC(int c) { gi3 = !gi ^ (256 - hi); }
void es_x_NT(int c) { gi3 = !gi ^ (hc ? hi : hj); }
void es_x_NS(int c) { gi3 = !gi ^ (hi << c); }
void es_x_ND(int c) { gi3 = !gi ^ hps->i; }
void es_x_UK(int c) { gi3 = -gi ^ 7; }
void es_x_UG(int c) { gi3 = -gi ^ hi; }
void es_x_UM(int c) { gi3 = -gi ^ hs.i; }
void es_x_UP(int c) { gi3 = -gi ^ *hpi; }
void es_x_UE(int c) { gi3 = -gi ^ hia[3]; }
void es_x_UX(int c) { gi3 = -gi ^ hia[c]; }
void es_x_UN(int c) { gi3 = -gi ^ !hi; }
void es_x_UU(int c) { gi3 = -gi ^ -hi; }
void es_x_UB(int c) { gi3 = -gi ^ (hi - hj); }
void es_x_UC(int c) { gi3 = -gi ^ (256 - hi); }
void es_x_UT(int c) { gi3 = -gi ^ (hc ? hi : hj); }
void es_x_US(int c) { gi3 = -gi ^ (hi << c); }
void es_x_UD(int c) { gi3 = -gi ^ hps->i; }
void es_x_BK(int c) { gi3 = (gi - gj) ^ 7; }
void es_x_BG(int c) { gi3 = (gi - gj) ^ hi; }
void es_x_BM(int c) { gi3 = (gi - gj) ^ hs.i; }
void es_x_BP(int c) { gi3 = (gi - gj) ^ *hpi; }
void es_x_BE(int c) { gi3 = (gi - gj) ^ hia[3]; }
void es_x_BX(int c) { gi3 = (gi - gj) ^ hia[c]; }
void es_x_BN(int c) { gi3 = (gi - gj) ^ !hi; }
void es_x_BU(int c) { gi3 = (gi - gj) ^ -hi; }
void es_x_BB(int c) { gi3 = (gi - gj) ^ (hi - hj); }
void es_x_BC(int c) { gi3 = (gi - gj) ^ (256 - hi); }
void es_x_BT(int c) { gi3 = (gi - gj) ^ (hc ? hi : hj); }
void es_x_BS(int c) { gi3 = (gi - gj) ^ (hi << c); }
void es_x_BD(int c) { gi3 = (gi - gj) ^ hps->i; }
void es_x_CK(int c) { gi3 = (256 - gi) ^ 7; }
void es_x_CG(int c) { gi3 = (256 - gi) ^ hi; }
void es_x_CM(int c) { gi3 = (256 - gi) ^ hs.i; }
void es_x_CP(int c) { gi3 = (256 - gi) ^ *hpi; }
void es_x_CE(int c) { gi3 = (256 - gi) ^ hia[3]; }
void es_x_CX(int c) { gi3 = (256 - gi) ^ hia[c]; }
void es_x_CN(int c) { gi3 = (256 - gi) ^ !hi; }
void es_x_CU(int c) { gi3 = (256 - gi) ^ -hi; }
void es_x_CB(int c) { gi3 = (256 - gi) ^ (hi - hj); }
void es_x_CC(int c) { gi3 = (256 - gi) ^ (256 - hi); }
void es_x_CT(int c) { gi3 = (256 - gi) ^ (hc ? hi : hj); }
void es_x_CS(int c) { gi3 = (256 - gi) ^ (hi << c); }
void es_x_CD(int c) { gi3 = (256 - gi) ^ hps->i; }
void es_x_TK(int c) { gi3 = (gc ? gi : gj) ^ 7; }
void es_x_TG(int c) { gi3 = (gc ? gi : gj) ^ hi; }
void es_x_TM(int c) { gi3 = (gc ? gi : gj) ^ hs.i; }
void es_x_TP(int c) { gi3 = (gc ? gi : gj) ^ *hpi; }
void es_x_TE(int c) { gi3 = (gc ? gi : gj) ^ hia[3]; }
void es_x_TX(int c) { gi3 = (gc ? gi : gj) ^ hia[c]; }
void es_x_TN(int c) { gi3 = (gc ? gi : gj) ^ !hi; }
void es_x_TU(int c) { gi3 = (gc ? gi : gj) ^ -hi; }
void es_x_TB(int c) { gi3 = (gc ? gi : gj) ^ (hi - hj); }
void es_x_TC(int c) { gi3 = (gc ? gi : gj) ^ (256 - hi); }
void es_x_TT(int c) { gi3 = (gc ? gi : gj) ^ (hc ? hi : hj); }
void es_x_TS(int c) { gi3 = (gc ? gi : gj) ^ (hi << c); }
void es_x_TD(int c) { gi3 = (gc ? gi : gj) ^ hps->i; }
void es_x_SK(int c) { gi3 = (gi << c) ^ 7; }
void es_x_SG(int c) { gi3 = (gi << c) ^ hi; }
void es_x_SM(int c) { gi3 = (gi << c) ^ hs.i; }
void es_x_SP(int c) { gi3 = (gi << c) ^ *hpi; }
void es_x_SE(int c) { gi3 = (gi << c) ^ hia[3]; }
void es_x_SX(int c) { gi3 = (gi << c) ^ hia[c]; }
void es_x_SN(int c) { gi3 = (gi << c) ^ !hi; }
void es_x_SU(int c) { gi3 = (gi << c) ^ -hi; }
void es_x_SB(int c) { gi3 = (gi << c) ^ (hi - hj); }
void es_x_SC(int c) { gi3 = (gi << c) ^ (256 - hi); }
void es_x_ST(int c) { gi3 = (gi << c) ^ (hc ? hi : hj); }
void es_x_SS(int c) { gi3 = (gi << c) ^ (hi << c); }
void es_x_SD(int c) { gi3 = (gi << c) ^ hps->i; }
void es_x_DK(int c) { gi3 = gps->i ^ 7; }
void es_x_DG(int c) { gi3 = gps->i ^ hi; }
void es_x_DM(int c) { gi3 = gps->i ^ hs.i; }
void es_x_DP(int c) { gi3 = gps->i ^ *hpi; }
void es_x_DE(int c) { gi3 = gps->i ^ hia[3]; }
void es_x_DX(int c) { gi3 = gps->i ^ hia[c]; }
void es_x_DN(int c) { gi3 = gps->i ^ !hi; }
void es_x_DU(int c) { gi3 = gps->i ^ -hi; }
void es_x_DB(int c) { gi3 = gps->i ^ (hi - hj); }
void es_x_DC(int c) { gi3 = gps->i ^ (256 - hi); }
void es_x_DT(int c) { gi3 = gps->i ^ (hc ? hi : hj); }
void es_x_DS(int c) { gi3 = gps->i ^ (hi << c); }
void es_x_DD(int c) { gi3 = gps->i ^ hps->i; }

void ea_s_KK(int c) { v1(7 - 7); }
void ea_s_KG(int c) { v1(7 - hi); }
void ea_s_KM(int c) { v1(7 - hs.i); }
void ea_s_KP(int c) { v1(7 - *hpi); }
void ea_s_KE(int c) { v1(7 - hia[3]); }
void ea_s_KX(int c) { v1(7 - hia[c]); }
void ea_s_KN(int c) { v1(7 - !hi); }
void ea_s_KU(int c) { v1(7 - -hi); }
void ea_s_KB(int c) { v1(7 - (hi - hj)); }
void ea_s_KC(int c) { v1(7 - (256 - hi)); }
void ea_s_KT(int c) { v1(7 - (hc ? hi : hj)); }
void ea_s_KS(int c) { v1(7 - (hi << c)); }
void ea_s_KD(int c) { v1(7 - hps->i); }
void ea_s_GK(int c) { v1(gi - 7); }
void ea_s_GG(int c) { v1(gi - hi); }
void ea_s_GM(int c) { v1(gi - hs.i); }
void ea_s_GP(int c) { v1(gi - *hpi); }
void ea_s_GE(int c) { v1(gi - hia[3]); }
void ea_s_GX(int c) { v1(gi - hia[c]); }
void ea_s_GN(int c) { v1(gi - !hi); }
void ea_s_GU(int c) { v1(gi - -hi); }
void ea_s_GB(int c) { v1(gi - (hi - hj)); }
void ea_s_GC(int c) { v1(gi - (256 - hi)); }
void ea_s_GT(int c) { v1(gi - (hc ? hi : hj)); }
void ea_s_GS(int c) { v1(gi - (hi << c)); }
void ea_s_GD(int c) { v1(gi - hps->i); }
void ea_s_MK(int c) { v1(gs.i - 7); }
void ea_s_MG(int c) { v1(gs.i - hi); }
void ea_s_MM(int c) { v1(gs.i - hs.i); }
void ea_s_MP(int c) { v1(gs.i - *hpi); }
void ea_s_ME(int c) { v1(gs.i - hia[3]); }
void ea_s_MX(int c) { v1(gs.i - hia[c]); }
void ea_s_MN(int c) { v1(gs.i - !hi); }
void ea_s_MU(int c) { v1(gs.i - -hi); }
void ea_s_MB(int c) { v1(gs.i - (hi - hj)); }
void ea_s_MC(int c) { v1(gs.i - (256 - hi)); }
void ea_s_MT(int c) { v1(gs.i - (hc ? hi : hj)); }
void ea_s_MS(int c) { v1(gs.i - (hi << c)); }
void ea_s_MD(int c) { v1(gs.i - hps->i); }
void ea_s_PK(int c) { v1(*gpi - 7); }
void ea_s_PG(int c) { v1(*gpi - hi); }
void ea_s_PM(int c) { v1(*gpi - hs.i); }
void ea_s_PP(int c) { v1(*gpi - *hpi); }
void ea_s_PE(int c) { v1(*gpi - hia[3]); }
void ea_s_PX(int c) { v1(*gpi - hia[c]); }
void ea_s_PN(int c) { v1(*gpi - !hi); }
void ea_s_PU(int c) { v1(*gpi - -hi); }
void ea_s_PB(int c) { v1(*gpi - (hi - hj)); }
void ea_s_PC(int c) { v1(*gpi - (256 - hi)); }
void ea_s_PT(int c) { v1(*gpi - (hc ? hi : hj)); }
void ea_s_PS(int c) { v1(*gpi - (hi << c)); }
void ea_s_PD(int c) { v1(*gpi - hps->i); }
void ea_s_EK(int c) { v1(gia[3] - 7); }
void ea_s_EG(int c) { v1(gia[3] - hi); }
void ea_s_EM(int c) { v1(gia[3] - hs.i); }
void ea_s_EP(int c) { v1(gia[3] - *hpi); }
void ea_s_EE(int c) { v1(gia[3] - hia[3]); }
void ea_s_EX(int c) { v1(gia[3] - hia[c]); }
void ea_s_EN(int c) { v1(gia[3] - !hi); }
void ea_s_EU(int c) { v1(gia[3] - -hi); }
void ea_s_EB(int c) { v1(gia[3] - (hi - hj)); }
void ea_s_EC(int c) { v1(gia[3] - (256 - hi)); }
void ea_s_ET(int c) { v1(gia[3] - (hc ? hi : hj)); }
void ea_s_ES(int c) { v1(gia[3] - (hi << c)); }
void ea_s_ED(int c) { v1(gia[3] - hps->i); }
void ea_s_XK(int c) { v1(gia[c] - 7); }
void ea_s_XG(int c) { v1(gia[c] - hi); }
void ea_s_XM(int c) { v1(gia[c] - hs.i); }
void ea_s_XP(int c) { v1(gia[c] - *hpi); }
void ea_s_XE(int c) { v1(gia[c] - hia[3]); }
void ea_s_XX(int c) { v1(gia[c] - hia[c]); }
void ea_s_XN(int c) { v1(gia[c] - !hi); }
void ea_s_XU(int c) { v1(gia[c] - -hi); }
void ea_s_XB(int c) { v1(gia[c] - (hi - hj)); }
void ea_s_XC(int c) { v1(gia[c] - (256 - hi)); }
void ea_s_XT(int c) { v1(gia[c] - (hc ? hi : hj)); }
void ea_s_XS(int c) { v1(gia[c] - (hi << c)); }
void ea_s_XD(int c) { v1(gia[c] - hps->i); }
void ea_s_NK(int c) { v1(!gi - 7); }
void ea_s_NG(int c) { v1(!gi - hi); }
void ea_s_NM(int c) { v1(!gi - hs.i); }
void ea_s_NP(int c) { v1(!gi - *hpi); }
void ea_s_NE(int c) { v1(!gi - hia[3]); }
void ea_s_NX(int c) { v1(!gi - hia[c]); }
void ea_s_NN(int c) { v1(!gi - !hi); }
void ea_s_NU(int c) { v1(!gi - -hi); }
void ea_s_NB(int c) { v1(!gi - (hi - hj)); }
void ea_s_NC(int c) { v1(!gi - (256 - hi)); }
void ea_s_NT(int c) { v1(!gi - (hc ? hi : hj)); }
void ea_s_NS(int c) { v1(!gi - (hi << c)); }
void ea_s_ND(int c) { v1(!gi - hps->i); }
void ea_s_UK(int c) { v1(-gi - 7); }
void ea_s_UG(int c) { v1(-gi - hi); }
void ea_s_UM(int c) { v1(-gi - hs.i); }
void ea_s_UP(int c) { v1(-gi - *hpi); }
void ea_s_UE(int c) { v1(-gi - hia[3]); }
void ea_s_UX(int c) { v1(-gi - hia[c]); }
void ea_s_UN(int c) { v1(-gi - !hi); }
void ea_s_UU(int c) { v1(-gi - -hi); }
void ea_s_UB(int c) { v1(-gi - (hi - hj)); }
void ea_s_UC(int c) { v1(-gi - (256 - hi)); }
void ea_s_UT(int c) { v1(-gi - (hc ? hi : hj)); }
void ea_s_US(int c) { v1(-gi - (hi << c)); }
void ea_s_UD(int c) { v1(-gi - hps->i); }
void ea_s_BK(int c) { v1((gi - gj) - 7); }
void ea_s_BG(int c) { v1((gi - gj) - hi); }
void ea_s_BM(int c) { v1((gi - gj) - hs.i); }
void ea_s_BP(int c) { v1((gi - gj) - *hpi); }
void ea_s_BE(int c) { v1((gi - gj) - hia[3]); }
void ea_s_BX(int c) { v1((gi - gj) - hia[c]); }
void ea_s_BN(int c) { v1((gi - gj) - !hi); }
void ea_s_BU(int c) { v1((gi - gj) - -hi); }
void ea_s_BB(int c) { v1((gi - gj) - (hi - hj)); }
void ea_s_BC(int c) { v1((gi - gj) - (256 - hi)); }
void ea_s_BT(int c) { v1((gi - gj) - (hc ? hi : hj)); }
void ea_s_BS(int c) { v1((gi - gj) - (hi << c)); }
void ea_s_BD(int c) { v1((gi - gj) - hps->i); }
void ea_s_CK(int c) { v1((256 - gi) - 7); }
void ea_s_CG(int c) { v1((256 - gi) - hi); }
void ea_s_CM(int c) { v1((256 - gi) - hs.i); }
void ea_s_CP(int c) { v1((256 - gi) - *hpi); }
void ea_s_CE(int c) { v1((256 - gi) - hia[3]); }
void ea_s_CX(int c) { v1((256 - gi) - hia[c]); }
void ea_s_CN(int c) { v1((256 - gi) - !hi); }
void ea_s_CU(int c) { v1((256 - gi) - -hi); }
void ea_s_CB(int c) { v1((256 - gi) - (hi - hj)); }
void ea_s_CC(int c) { v1((256 - gi) - (256 - hi)); }
void ea_s_CT(int c) { v1((256 - gi) - (hc ? hi : hj)); }
void ea_s_CS(int c) { v1((256 - gi) - (hi << c)); }
void ea_s_CD(int c) { v1((256 - gi) - hps->i); }
void ea_s_TK(int c) { v1((gc ? gi : gj) - 7); }
void ea_s_TG(int c) { v1((gc ? gi : gj) - hi); }
void ea_s_TM(int c) { v1((gc ? gi : gj) - hs.i); }
void ea_s_TP(int c) { v1((gc ? gi : gj) - *hpi); }
void ea_s_TE(int c) { v1((gc ? gi : gj) - hia[3]); }
void ea_s_TX(int c) { v1((gc ? gi : gj) - hia[c]); }
void ea_s_TN(int c) { v1((gc ? gi : gj) - !hi); }
void ea_s_TU(int c) { v1((gc ? gi : gj) - -hi); }
void ea_s_TB(int c) { v1((gc ? gi : gj) - (hi - hj)); }
void ea_s_TC(int c) { v1((gc ? gi : gj) - (256 - hi)); }
void ea_s_TT(int c) { v1((gc ? gi : gj) - (hc ? hi : hj)); }
void ea_s_TS(int c) { v1((gc ? gi : gj) - (hi << c)); }
void ea_s_TD(int c) { v1((gc ? gi : gj) - hps->i); }
void ea_s_SK(int c) { v1((gi << c) - 7); }
void ea_s_SG(int c) { v1((gi << c) - hi); }
void ea_s_SM(int c) { v1((gi << c) - hs.i); }
void ea_s_SP(int c) { v1((gi << c) - *hpi); }
void ea_s_SE(int c) { v1((gi << c) - hia[3]); }
void ea_s_SX(int c) { v1((gi << c) - hia[c]); }
void ea_s_SN(int c) { v1((gi << c) - !hi); }
void ea_s_SU(int c) { v1((gi << c) - -hi); }
void ea_s_SB(int c) { v1((gi << c) - (hi - hj)); }
void ea_s_SC(int c) { v1((gi << c) - (256 - hi)); }
void ea_s_ST(int c) { v1((gi << c) - (hc ? hi : hj)); }
void ea_s_SS(int c) { v1((gi << c) - (hi << c)); }
void ea_s_SD(int c) { v1((gi << c) - hps->i); }
void ea_s_DK(int c) { v1(gps->i - 7); }
void ea_s_DG(int c) { v1(gps->i - hi); }
void ea_s_DM(int c) { v1(gps->i - hs.i); }
void ea_s_DP(int c) { v1(gps->i - *hpi); }
void ea_s_DE(int c) { v1(gps->i - hia[3]); }
void ea_s_DX(int c) { v1(gps->i - hia[c]); }
void ea_s_DN(int c) { v1(gps->i - !hi); }
void ea_s_DU(int c) { v1(gps->i - -hi); }
void ea_s_DB(int c) { v1(gps->i - (hi - hj)); }
void ea_s_DC(int c) { v1(gps->i - (256 - hi)); }
void ea_s_DT(int c) { v1(gps->i - (hc ? hi : hj)); }
void ea_s_DS(int c) { v1(gps->i - (hi << c)); }
void ea_s_DD(int c) { v1(gps->i - hps->i); }

void ea_x_KK(int c) { v1(7 ^ 7); }
void ea_x_KG(int c) { v1(7 ^ hi); }
void ea_x_KM(int c) { v1(7 ^ hs.i); }
void ea_x_KP(int c) { v1(7 ^ *hpi); }
void ea_x_KE(int c) { v1(7 ^ hia[3]); }
void ea_x_KX(int c) { v1(7 ^ hia[c]); }
void ea_x_KN(int c) { v1(7 ^ !hi); }
void ea_x_KU(int c) { v1(7 ^ -hi); }
void ea_x_KB(int c) { v1(7 ^ (hi - hj)); }
void ea_x_KC(int c) { v1(7 ^ (256 - hi)); }
void ea_x_KT(int c) { v1(7 ^ (hc ? hi : hj)); }
void ea_x_KS(int c) { v1(7 ^ (hi << c)); }
void ea_x_KD(int c) { v1(7 ^ hps->i); }
void ea_x_GK(int c) { v1(gi ^ 7); }
void ea_x_GG(int c) { v1(gi ^ hi); }
void ea_x_GM(int c) { v1(gi ^ hs.i); }
void ea_x_GP(int c) { v1(gi ^ *hpi); }
void ea_x_GE(int c) { v1(gi ^ hia[3]); }
void ea_x_GX(int c) { v1(gi ^ hia[c]); }
void ea_x_GN(int c) { v1(gi ^ !hi); }
void ea_x_GU(int c) { v1(gi ^ -hi); }
void ea_x_GB(int c) { v1(gi ^ (hi - hj)); }
void ea_x_GC(int c) { v1(gi ^ (256 - hi)); }
void ea_x_GT(int c) { v1(gi ^ (hc ? hi : hj)); }
void ea_x_GS(int c) { v1(gi ^ (hi << c)); }
void ea_x_GD(int c) { v1(gi ^ hps->i); }
void ea_x_MK(int c) { v1(gs.i ^ 7); }
void ea_x_MG(int c) { v1(gs.i ^ hi); }
void ea_x_MM(int c) { v1(gs.i ^ hs.i); }
void ea_x_MP(int c) { v1(gs.i ^ *hpi); }
void ea_x_ME(int c) { v1(gs.i ^ hia[3]); }
void ea_x_MX(int c) { v1(gs.i ^ hia[c]); }
void ea_x_MN(int c) { v1(gs.i ^ !hi); }
void ea_x_MU(int c) { v1(gs.i ^ -hi); }
void ea_x_MB(int c) { v1(gs.i ^ (hi - hj)); }
void ea_x_MC(int c) { v1(gs.i ^ (256 - hi)); }
void ea_x_MT(int c) { v1(gs.i ^ (hc ? hi : hj)); }
void ea_x_MS(int c) { v1(gs.i ^ (hi << c)); }
void ea_x_MD(int c) { v1(gs.i ^ hps->i); }
void ea_x_PK(int c) { v1(*gpi ^ 7); }
void ea_x_PG(int c) { v1(*gpi ^ hi); }
void ea_x_PM(int c) { v1(*gpi ^ hs.i); }
void ea_x_PP(int c) { v1(*gpi ^ *hpi); }
void ea_x_PE(int c) { v1(*gpi ^ hia[3]); }
void ea_x_PX(int c) { v1(*gpi ^ hia[c]); }
void ea_x_PN(int c) { v1(*gpi ^ !hi); }
void ea_x_PU(int c) { v1(*gpi ^ -hi); }
void ea_x_PB(int c) { v1(*gpi ^ (hi - hj)); }
void ea_x_PC(int c) { v1(*gpi ^ (256 - hi)); }
void ea_x_PT(int c) { v1(*gpi ^ (hc ? hi : hj)); }
void ea_x_PS(int c) { v1(*gpi ^ (hi << c)); }
void ea_x_PD(int c) { v1(*gpi ^ hps->i); }
void ea_x_EK(int c) { v1(gia[3] ^ 7); }
void ea_x_EG(int c) { v1(gia[3] ^ hi); }
void ea_x_EM(int c) { v1(gia[3] ^ hs.i); }
void ea_x_EP(int c) { v1(gia[3] ^ *hpi); }
void ea_x_EE(int c) { v1(gia[3] ^ hia[3]); }
void ea_x_EX(int c) { v1(gia[3] ^ hia[c]); }
void ea_x_EN(int c) { v1(gia[3] ^ !hi); }
void ea_x_EU(int c) { v1(gia[3] ^ -hi); }
void ea_x_EB(int c) { v1(gia[3] ^ (hi - hj)); }
void ea_x_EC(int c) { v1(gia[3] ^ (256 - hi)); }
void ea_x_ET(int c) { v1(gia[3] ^ (hc ? hi : hj)); }
void ea_x_ES(int c) { v1(gia[3] ^ (hi << c)); }
void ea_x_ED(int c) { v1(gia[3] ^ hps->i); }
void ea_x_XK(int c) { v1(gia[c] ^ 7); }
void ea_x_XG(int c) { v1(gia[c] ^ hi); }
void ea_x_XM(int c) { v1(gia[c] ^ hs.i); }
void ea_x_XP(int c) { v1(gia[c] ^ *hpi); }
void ea_x_XE(int c) { v1(gia[c] ^ hia[3]); }
void ea_x_XX(int c) { v1(gia[c] ^ hia[c]); }
void ea_x_XN(int c) { v1(gia[c] ^ !hi); }
void ea_x_XU(int c) { v1(gia[c] ^ -hi); }
void ea_x_XB(int c) { v1(gia[c] ^ (hi - hj)); }
void ea_x_XC(int c) { v1(gia[c] ^ (256 - hi)); }
void ea_x_XT(int c) { v1(gia[c] ^ (hc ? hi : hj)); }
void ea_x_XS(int c) { v1(gia[c] ^ (hi << c)); }
void ea_x_XD(int c) { v1(gia[c] ^ hps->i); }
void ea_x_NK(int c) { v1(!gi ^ 7); }
void ea_x_NG(int c) { v1(!gi ^ hi); }
void ea_x_NM(int c) { v1(!gi ^ hs.i); }
void ea_x_NP(int c) { v1(!gi ^ *hpi); }
void ea_x_NE(int c) { v1(!gi ^ hia[3]); }
void ea_x_NX(int c) { v1(!gi ^ hia[c]); }
void ea_x_NN(int c) { v1(!gi ^ !hi); }
void ea_x_NU(int c) { v1(!gi ^ -hi); }
void ea_x_NB(int c) { v1(!gi ^ (hi - hj)); }
void ea_x_NC(int c) { v1(!gi ^ (256 - hi)); }
void ea_x_NT(int c) { v1(!gi ^ (hc ? hi : hj)); }
void ea_x_NS(int c) { v1(!gi ^ (hi << c)); }
void ea_x_ND(int c) { v1(!gi ^ hps->i); }
void ea_x_UK(int c) { v1(-gi ^ 7); }
void ea_x_UG(int c) { v1(-gi ^ hi); }
void ea_x_UM(int c) { v1(-gi ^ hs.i); }
void ea_x_UP(int c) { v1(-gi ^ *hpi); }
void ea_x_UE(int c) { v1(-gi ^ hia[3]); }
void ea_x_UX(int c) { v1(-gi ^ hia[c]); }
void ea_x_UN(int c) { v1(-gi ^ !hi); }
void ea_x_UU(int c) { v1(-gi ^ -hi); }
void ea_x_UB(int c) { v1(-gi ^ (hi - hj)); }
void ea_x_UC(int c) { v1(-gi ^ (256 - hi)); }
void ea_x_UT(int c) { v1(-gi ^ (hc ? hi : hj)); }
void ea_x_US(int c) { v1(-gi ^ (hi << c)); }
void ea_x_UD(int c) { v1(-gi ^ hps->i); }
void ea_x_BK(int c) { v1((gi - gj) ^ 7); }
void ea_x_BG(int c) { v1((gi - gj) ^ hi); }
void ea_x_BM(int c) { v1((gi - gj) ^ hs.i); }
void ea_x_BP(int c) { v1((gi - gj) ^ *hpi); }
void ea_x_BE(int c) { v1((gi - gj) ^ hia[3]); }
void ea_x_BX(int c) { v1((gi - gj) ^ hia[c]); }
void ea_x_BN(int c) { v1((gi - gj) ^ !hi); }
void ea_x_BU(int c) { v1((gi - gj) ^ -hi); }
void ea_x_BB(int c) { v1((gi - gj) ^ (hi - hj)); }
void ea_x_BC(int c) { v1((gi - gj) ^ (256 - hi)); }
void ea_x_BT(int c) { v1((gi - gj) ^ (hc ? hi : hj)); }
void ea_x_BS(int c) { v1((gi - gj) ^ (hi << c)); }
void ea_x_BD(int c) { v1((gi - gj) ^ hps->i); }
void ea_x_CK(int c) { v1((256 - gi) ^ 7); }
void ea_x_CG(int c) { v1((256 - gi) ^ hi); }
void ea_x_CM(int c) { v1((256 - gi) ^ hs.i); }
void ea_x_CP(int c) { v1((256 - gi) ^ *hpi); }
void ea_x_CE(int c) { v1((256 - gi) ^ hia[3]); }
void ea_x_CX(int c) { v1((256 - gi) ^ hia[c]); }
void ea_x_CN(int c) { v1((256 - gi) ^ !hi); }
void ea_x_CU(int c) { v1((256 - gi) ^ -hi); }
void ea_x_CB(int c) { v1((256 - gi) ^ (hi - hj)); }
void ea_x_CC(int c) { v1((256 - gi) ^ (256 - hi)); }
void ea_x_CT(int c) { v1((256 - gi) ^ (hc ? hi : hj)); }
void ea_x_CS(int c) { v1((256 - gi) ^ (hi << c)); }
void ea_x_CD(int c) { v1((256 - gi) ^ hps->i); }
void ea_x_TK(int c) { v1((gc ? gi : gj) ^ 7); }
void ea_x_TG(int c) { v1((gc ? gi : gj) ^ hi); }
void ea_x_TM(int c) { v1((gc ? gi : gj) ^ hs.i); }
void ea_x_TP(int c) { v1((gc ? gi : gj) ^ *hpi); }
void ea_x_TE(int c) { v1((gc ? gi : gj) ^ hia[3]); }
void ea_x_TX(int c) { v1((gc ? gi : gj) ^ hia[c]); }
void ea_x_TN(int c) { v1((gc ? gi : gj) ^ !hi); }
void ea_x_TU(int c) { v1((gc ? gi : gj) ^ -hi); }
void ea_x_TB(int c) { v1((gc ? gi : gj) ^ (hi - hj)); }
void ea_x_TC(int c) { v1((gc ? gi : gj) ^ (256 - hi)); }
void ea_x_TT(int c) { v1((gc ? gi : gj) ^ (hc ? hi : hj)); }
void ea_x_TS(int c) { v1((gc ? gi : gj) ^ (hi << c)); }
void ea_x_TD(int c) { v1((gc ? gi : gj) ^ hps->i); }
void ea_x_SK(int c) { v1((gi << c) ^ 7); }
void ea_x_SG(int c) { v1((gi << c) ^ hi); }
void ea_x_SM(int c) { v1((gi << c) ^ hs.i); }
void ea_x_SP(int c) { v1((gi << c) ^ *hpi); }
void ea_x_SE(int c) { v1((gi << c) ^ hia[3]); }
void ea_x_SX(int c) { v1((gi << c) ^ hia[c]); }
void ea_x_SN(int c) { v1((gi << c) ^ !hi); }
void ea_x_SU(int c) { v1((gi << c) ^ -hi); }
void ea_x_SB(int c) { v1((gi << c) ^ (hi - hj)); }
void ea_x_SC(int c) { v1((gi << c) ^ (256 - hi)); }
void ea_x_ST(int c) { v1((gi << c) ^ (hc ? hi : hj)); }
void ea_x_SS(int c) { v1((gi << c) ^ (hi << c)); }
void ea_x_SD(int c) { v1((gi << c) ^ hps->i); }
void ea_x_DK(int c) { v1(gps->i ^ 7); }
void ea_x_DG(int c) { v1(gps->i ^ hi); }
void ea_x_DM(int c) { v1(gps->i ^ hs.i); }
void ea_x_DP(int c) { v1(gps->i ^ *hpi); }
void ea_x_DE(int c) { v1(gps->i ^ hia[3]); }
void ea_x_DX(int c) { v1(gps->i ^ hia[c]); }
void ea_x_DN(int c) { v1(gps->i ^ !hi); }
void ea_x_DU(int c) { v1(gps->i ^ -hi); }
void ea_x_DB(int c) { v1(gps->i ^ (hi - hj)); }
void ea_x_DC(int c) { v1(gps->i ^ (256 - hi)); }
void ea_x_DT(int c) { v1(gps->i ^ (hc ? hi : hj)); }
void ea_x_DS(int c) { v1(gps->i ^ (hi << c)); }
void ea_x_DD(int c) { v1(gps->i ^ hps->i); }
