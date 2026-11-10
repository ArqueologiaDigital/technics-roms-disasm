/* Evaluation order of the two operands of a binary operator, by operand kind (gen_evorder.py).  The random
   corpora showed the right operand computed first when it needs more registers (r2_05_13: !gla[7] - (gua[c] - gs.u);
   r2_02_18: -gs.u ^ (*gp == '9' ? c : gua[i])) and the left first otherwise (r2_06_05: (256 - gl) | !*gpl).
   Kinds: K constant, G global, M struct member, P deref of a global pointer, E element with a constant index,
   X element with a parameter index, N !g, U -g, B g - g, C 256 - g, T g ? g : g, S g << c, D member through a
   pointer.  eo_<op>_<L><R>(c) returns L op R for - (s), ^ (x) and * (m); the left side reads the g* globals, the
   right side the h* globals, so a listing shows which operand was computed first. */
struct st { int i; int a[4]; };
extern int gi, gj, gc, hi, hj, hc; extern int gia[10], hia[10]; extern int *gpi, *hpi;
extern struct st gs, *gps, hs, *hps;

int eo_s_KK(int c) { return 7 - 7; }
int eo_s_KG(int c) { return 7 - hi; }
int eo_s_KM(int c) { return 7 - hs.i; }
int eo_s_KP(int c) { return 7 - *hpi; }
int eo_s_KE(int c) { return 7 - hia[3]; }
int eo_s_KX(int c) { return 7 - hia[c]; }
int eo_s_KN(int c) { return 7 - !hi; }
int eo_s_KU(int c) { return 7 - -hi; }
int eo_s_KB(int c) { return 7 - (hi - hj); }
int eo_s_KC(int c) { return 7 - (256 - hi); }
int eo_s_KT(int c) { return 7 - (hc ? hi : hj); }
int eo_s_KS(int c) { return 7 - (hi << c); }
int eo_s_KD(int c) { return 7 - hps->i; }
int eo_s_GK(int c) { return gi - 7; }
int eo_s_GG(int c) { return gi - hi; }
int eo_s_GM(int c) { return gi - hs.i; }
int eo_s_GP(int c) { return gi - *hpi; }
int eo_s_GE(int c) { return gi - hia[3]; }
int eo_s_GX(int c) { return gi - hia[c]; }
int eo_s_GN(int c) { return gi - !hi; }
int eo_s_GU(int c) { return gi - -hi; }
int eo_s_GB(int c) { return gi - (hi - hj); }
int eo_s_GC(int c) { return gi - (256 - hi); }
int eo_s_GT(int c) { return gi - (hc ? hi : hj); }
int eo_s_GS(int c) { return gi - (hi << c); }
int eo_s_GD(int c) { return gi - hps->i; }
int eo_s_MK(int c) { return gs.i - 7; }
int eo_s_MG(int c) { return gs.i - hi; }
int eo_s_MM(int c) { return gs.i - hs.i; }
int eo_s_MP(int c) { return gs.i - *hpi; }
int eo_s_ME(int c) { return gs.i - hia[3]; }
int eo_s_MX(int c) { return gs.i - hia[c]; }
int eo_s_MN(int c) { return gs.i - !hi; }
int eo_s_MU(int c) { return gs.i - -hi; }
int eo_s_MB(int c) { return gs.i - (hi - hj); }
int eo_s_MC(int c) { return gs.i - (256 - hi); }
int eo_s_MT(int c) { return gs.i - (hc ? hi : hj); }
int eo_s_MS(int c) { return gs.i - (hi << c); }
int eo_s_MD(int c) { return gs.i - hps->i; }
int eo_s_PK(int c) { return *gpi - 7; }
int eo_s_PG(int c) { return *gpi - hi; }
int eo_s_PM(int c) { return *gpi - hs.i; }
int eo_s_PP(int c) { return *gpi - *hpi; }
int eo_s_PE(int c) { return *gpi - hia[3]; }
int eo_s_PX(int c) { return *gpi - hia[c]; }
int eo_s_PN(int c) { return *gpi - !hi; }
int eo_s_PU(int c) { return *gpi - -hi; }
int eo_s_PB(int c) { return *gpi - (hi - hj); }
int eo_s_PC(int c) { return *gpi - (256 - hi); }
int eo_s_PT(int c) { return *gpi - (hc ? hi : hj); }
int eo_s_PS(int c) { return *gpi - (hi << c); }
int eo_s_PD(int c) { return *gpi - hps->i; }
int eo_s_EK(int c) { return gia[3] - 7; }
int eo_s_EG(int c) { return gia[3] - hi; }
int eo_s_EM(int c) { return gia[3] - hs.i; }
int eo_s_EP(int c) { return gia[3] - *hpi; }
int eo_s_EE(int c) { return gia[3] - hia[3]; }
int eo_s_EX(int c) { return gia[3] - hia[c]; }
int eo_s_EN(int c) { return gia[3] - !hi; }
int eo_s_EU(int c) { return gia[3] - -hi; }
int eo_s_EB(int c) { return gia[3] - (hi - hj); }
int eo_s_EC(int c) { return gia[3] - (256 - hi); }
int eo_s_ET(int c) { return gia[3] - (hc ? hi : hj); }
int eo_s_ES(int c) { return gia[3] - (hi << c); }
int eo_s_ED(int c) { return gia[3] - hps->i; }
int eo_s_XK(int c) { return gia[c] - 7; }
int eo_s_XG(int c) { return gia[c] - hi; }
int eo_s_XM(int c) { return gia[c] - hs.i; }
int eo_s_XP(int c) { return gia[c] - *hpi; }
int eo_s_XE(int c) { return gia[c] - hia[3]; }
int eo_s_XX(int c) { return gia[c] - hia[c]; }
int eo_s_XN(int c) { return gia[c] - !hi; }
int eo_s_XU(int c) { return gia[c] - -hi; }
int eo_s_XB(int c) { return gia[c] - (hi - hj); }
int eo_s_XC(int c) { return gia[c] - (256 - hi); }
int eo_s_XT(int c) { return gia[c] - (hc ? hi : hj); }
int eo_s_XS(int c) { return gia[c] - (hi << c); }
int eo_s_XD(int c) { return gia[c] - hps->i; }
int eo_s_NK(int c) { return !gi - 7; }
int eo_s_NG(int c) { return !gi - hi; }
int eo_s_NM(int c) { return !gi - hs.i; }
int eo_s_NP(int c) { return !gi - *hpi; }
int eo_s_NE(int c) { return !gi - hia[3]; }
int eo_s_NX(int c) { return !gi - hia[c]; }
int eo_s_NN(int c) { return !gi - !hi; }
int eo_s_NU(int c) { return !gi - -hi; }
int eo_s_NB(int c) { return !gi - (hi - hj); }
int eo_s_NC(int c) { return !gi - (256 - hi); }
int eo_s_NT(int c) { return !gi - (hc ? hi : hj); }
int eo_s_NS(int c) { return !gi - (hi << c); }
int eo_s_ND(int c) { return !gi - hps->i; }
int eo_s_UK(int c) { return -gi - 7; }
int eo_s_UG(int c) { return -gi - hi; }
int eo_s_UM(int c) { return -gi - hs.i; }
int eo_s_UP(int c) { return -gi - *hpi; }
int eo_s_UE(int c) { return -gi - hia[3]; }
int eo_s_UX(int c) { return -gi - hia[c]; }
int eo_s_UN(int c) { return -gi - !hi; }
int eo_s_UU(int c) { return -gi - -hi; }
int eo_s_UB(int c) { return -gi - (hi - hj); }
int eo_s_UC(int c) { return -gi - (256 - hi); }
int eo_s_UT(int c) { return -gi - (hc ? hi : hj); }
int eo_s_US(int c) { return -gi - (hi << c); }
int eo_s_UD(int c) { return -gi - hps->i; }
int eo_s_BK(int c) { return (gi - gj) - 7; }
int eo_s_BG(int c) { return (gi - gj) - hi; }
int eo_s_BM(int c) { return (gi - gj) - hs.i; }
int eo_s_BP(int c) { return (gi - gj) - *hpi; }
int eo_s_BE(int c) { return (gi - gj) - hia[3]; }
int eo_s_BX(int c) { return (gi - gj) - hia[c]; }
int eo_s_BN(int c) { return (gi - gj) - !hi; }
int eo_s_BU(int c) { return (gi - gj) - -hi; }
int eo_s_BB(int c) { return (gi - gj) - (hi - hj); }
int eo_s_BC(int c) { return (gi - gj) - (256 - hi); }
int eo_s_BT(int c) { return (gi - gj) - (hc ? hi : hj); }
int eo_s_BS(int c) { return (gi - gj) - (hi << c); }
int eo_s_BD(int c) { return (gi - gj) - hps->i; }
int eo_s_CK(int c) { return (256 - gi) - 7; }
int eo_s_CG(int c) { return (256 - gi) - hi; }
int eo_s_CM(int c) { return (256 - gi) - hs.i; }
int eo_s_CP(int c) { return (256 - gi) - *hpi; }
int eo_s_CE(int c) { return (256 - gi) - hia[3]; }
int eo_s_CX(int c) { return (256 - gi) - hia[c]; }
int eo_s_CN(int c) { return (256 - gi) - !hi; }
int eo_s_CU(int c) { return (256 - gi) - -hi; }
int eo_s_CB(int c) { return (256 - gi) - (hi - hj); }
int eo_s_CC(int c) { return (256 - gi) - (256 - hi); }
int eo_s_CT(int c) { return (256 - gi) - (hc ? hi : hj); }
int eo_s_CS(int c) { return (256 - gi) - (hi << c); }
int eo_s_CD(int c) { return (256 - gi) - hps->i; }
int eo_s_TK(int c) { return (gc ? gi : gj) - 7; }
int eo_s_TG(int c) { return (gc ? gi : gj) - hi; }
int eo_s_TM(int c) { return (gc ? gi : gj) - hs.i; }
int eo_s_TP(int c) { return (gc ? gi : gj) - *hpi; }
int eo_s_TE(int c) { return (gc ? gi : gj) - hia[3]; }
int eo_s_TX(int c) { return (gc ? gi : gj) - hia[c]; }
int eo_s_TN(int c) { return (gc ? gi : gj) - !hi; }
int eo_s_TU(int c) { return (gc ? gi : gj) - -hi; }
int eo_s_TB(int c) { return (gc ? gi : gj) - (hi - hj); }
int eo_s_TC(int c) { return (gc ? gi : gj) - (256 - hi); }
int eo_s_TT(int c) { return (gc ? gi : gj) - (hc ? hi : hj); }
int eo_s_TS(int c) { return (gc ? gi : gj) - (hi << c); }
int eo_s_TD(int c) { return (gc ? gi : gj) - hps->i; }
int eo_s_SK(int c) { return (gi << c) - 7; }
int eo_s_SG(int c) { return (gi << c) - hi; }
int eo_s_SM(int c) { return (gi << c) - hs.i; }
int eo_s_SP(int c) { return (gi << c) - *hpi; }
int eo_s_SE(int c) { return (gi << c) - hia[3]; }
int eo_s_SX(int c) { return (gi << c) - hia[c]; }
int eo_s_SN(int c) { return (gi << c) - !hi; }
int eo_s_SU(int c) { return (gi << c) - -hi; }
int eo_s_SB(int c) { return (gi << c) - (hi - hj); }
int eo_s_SC(int c) { return (gi << c) - (256 - hi); }
int eo_s_ST(int c) { return (gi << c) - (hc ? hi : hj); }
int eo_s_SS(int c) { return (gi << c) - (hi << c); }
int eo_s_SD(int c) { return (gi << c) - hps->i; }
int eo_s_DK(int c) { return gps->i - 7; }
int eo_s_DG(int c) { return gps->i - hi; }
int eo_s_DM(int c) { return gps->i - hs.i; }
int eo_s_DP(int c) { return gps->i - *hpi; }
int eo_s_DE(int c) { return gps->i - hia[3]; }
int eo_s_DX(int c) { return gps->i - hia[c]; }
int eo_s_DN(int c) { return gps->i - !hi; }
int eo_s_DU(int c) { return gps->i - -hi; }
int eo_s_DB(int c) { return gps->i - (hi - hj); }
int eo_s_DC(int c) { return gps->i - (256 - hi); }
int eo_s_DT(int c) { return gps->i - (hc ? hi : hj); }
int eo_s_DS(int c) { return gps->i - (hi << c); }
int eo_s_DD(int c) { return gps->i - hps->i; }

int eo_x_KK(int c) { return 7 ^ 7; }
int eo_x_KG(int c) { return 7 ^ hi; }
int eo_x_KM(int c) { return 7 ^ hs.i; }
int eo_x_KP(int c) { return 7 ^ *hpi; }
int eo_x_KE(int c) { return 7 ^ hia[3]; }
int eo_x_KX(int c) { return 7 ^ hia[c]; }
int eo_x_KN(int c) { return 7 ^ !hi; }
int eo_x_KU(int c) { return 7 ^ -hi; }
int eo_x_KB(int c) { return 7 ^ (hi - hj); }
int eo_x_KC(int c) { return 7 ^ (256 - hi); }
int eo_x_KT(int c) { return 7 ^ (hc ? hi : hj); }
int eo_x_KS(int c) { return 7 ^ (hi << c); }
int eo_x_KD(int c) { return 7 ^ hps->i; }
int eo_x_GK(int c) { return gi ^ 7; }
int eo_x_GG(int c) { return gi ^ hi; }
int eo_x_GM(int c) { return gi ^ hs.i; }
int eo_x_GP(int c) { return gi ^ *hpi; }
int eo_x_GE(int c) { return gi ^ hia[3]; }
int eo_x_GX(int c) { return gi ^ hia[c]; }
int eo_x_GN(int c) { return gi ^ !hi; }
int eo_x_GU(int c) { return gi ^ -hi; }
int eo_x_GB(int c) { return gi ^ (hi - hj); }
int eo_x_GC(int c) { return gi ^ (256 - hi); }
int eo_x_GT(int c) { return gi ^ (hc ? hi : hj); }
int eo_x_GS(int c) { return gi ^ (hi << c); }
int eo_x_GD(int c) { return gi ^ hps->i; }
int eo_x_MK(int c) { return gs.i ^ 7; }
int eo_x_MG(int c) { return gs.i ^ hi; }
int eo_x_MM(int c) { return gs.i ^ hs.i; }
int eo_x_MP(int c) { return gs.i ^ *hpi; }
int eo_x_ME(int c) { return gs.i ^ hia[3]; }
int eo_x_MX(int c) { return gs.i ^ hia[c]; }
int eo_x_MN(int c) { return gs.i ^ !hi; }
int eo_x_MU(int c) { return gs.i ^ -hi; }
int eo_x_MB(int c) { return gs.i ^ (hi - hj); }
int eo_x_MC(int c) { return gs.i ^ (256 - hi); }
int eo_x_MT(int c) { return gs.i ^ (hc ? hi : hj); }
int eo_x_MS(int c) { return gs.i ^ (hi << c); }
int eo_x_MD(int c) { return gs.i ^ hps->i; }
int eo_x_PK(int c) { return *gpi ^ 7; }
int eo_x_PG(int c) { return *gpi ^ hi; }
int eo_x_PM(int c) { return *gpi ^ hs.i; }
int eo_x_PP(int c) { return *gpi ^ *hpi; }
int eo_x_PE(int c) { return *gpi ^ hia[3]; }
int eo_x_PX(int c) { return *gpi ^ hia[c]; }
int eo_x_PN(int c) { return *gpi ^ !hi; }
int eo_x_PU(int c) { return *gpi ^ -hi; }
int eo_x_PB(int c) { return *gpi ^ (hi - hj); }
int eo_x_PC(int c) { return *gpi ^ (256 - hi); }
int eo_x_PT(int c) { return *gpi ^ (hc ? hi : hj); }
int eo_x_PS(int c) { return *gpi ^ (hi << c); }
int eo_x_PD(int c) { return *gpi ^ hps->i; }
int eo_x_EK(int c) { return gia[3] ^ 7; }
int eo_x_EG(int c) { return gia[3] ^ hi; }
int eo_x_EM(int c) { return gia[3] ^ hs.i; }
int eo_x_EP(int c) { return gia[3] ^ *hpi; }
int eo_x_EE(int c) { return gia[3] ^ hia[3]; }
int eo_x_EX(int c) { return gia[3] ^ hia[c]; }
int eo_x_EN(int c) { return gia[3] ^ !hi; }
int eo_x_EU(int c) { return gia[3] ^ -hi; }
int eo_x_EB(int c) { return gia[3] ^ (hi - hj); }
int eo_x_EC(int c) { return gia[3] ^ (256 - hi); }
int eo_x_ET(int c) { return gia[3] ^ (hc ? hi : hj); }
int eo_x_ES(int c) { return gia[3] ^ (hi << c); }
int eo_x_ED(int c) { return gia[3] ^ hps->i; }
int eo_x_XK(int c) { return gia[c] ^ 7; }
int eo_x_XG(int c) { return gia[c] ^ hi; }
int eo_x_XM(int c) { return gia[c] ^ hs.i; }
int eo_x_XP(int c) { return gia[c] ^ *hpi; }
int eo_x_XE(int c) { return gia[c] ^ hia[3]; }
int eo_x_XX(int c) { return gia[c] ^ hia[c]; }
int eo_x_XN(int c) { return gia[c] ^ !hi; }
int eo_x_XU(int c) { return gia[c] ^ -hi; }
int eo_x_XB(int c) { return gia[c] ^ (hi - hj); }
int eo_x_XC(int c) { return gia[c] ^ (256 - hi); }
int eo_x_XT(int c) { return gia[c] ^ (hc ? hi : hj); }
int eo_x_XS(int c) { return gia[c] ^ (hi << c); }
int eo_x_XD(int c) { return gia[c] ^ hps->i; }
int eo_x_NK(int c) { return !gi ^ 7; }
int eo_x_NG(int c) { return !gi ^ hi; }
int eo_x_NM(int c) { return !gi ^ hs.i; }
int eo_x_NP(int c) { return !gi ^ *hpi; }
int eo_x_NE(int c) { return !gi ^ hia[3]; }
int eo_x_NX(int c) { return !gi ^ hia[c]; }
int eo_x_NN(int c) { return !gi ^ !hi; }
int eo_x_NU(int c) { return !gi ^ -hi; }
int eo_x_NB(int c) { return !gi ^ (hi - hj); }
int eo_x_NC(int c) { return !gi ^ (256 - hi); }
int eo_x_NT(int c) { return !gi ^ (hc ? hi : hj); }
int eo_x_NS(int c) { return !gi ^ (hi << c); }
int eo_x_ND(int c) { return !gi ^ hps->i; }
int eo_x_UK(int c) { return -gi ^ 7; }
int eo_x_UG(int c) { return -gi ^ hi; }
int eo_x_UM(int c) { return -gi ^ hs.i; }
int eo_x_UP(int c) { return -gi ^ *hpi; }
int eo_x_UE(int c) { return -gi ^ hia[3]; }
int eo_x_UX(int c) { return -gi ^ hia[c]; }
int eo_x_UN(int c) { return -gi ^ !hi; }
int eo_x_UU(int c) { return -gi ^ -hi; }
int eo_x_UB(int c) { return -gi ^ (hi - hj); }
int eo_x_UC(int c) { return -gi ^ (256 - hi); }
int eo_x_UT(int c) { return -gi ^ (hc ? hi : hj); }
int eo_x_US(int c) { return -gi ^ (hi << c); }
int eo_x_UD(int c) { return -gi ^ hps->i; }
int eo_x_BK(int c) { return (gi - gj) ^ 7; }
int eo_x_BG(int c) { return (gi - gj) ^ hi; }
int eo_x_BM(int c) { return (gi - gj) ^ hs.i; }
int eo_x_BP(int c) { return (gi - gj) ^ *hpi; }
int eo_x_BE(int c) { return (gi - gj) ^ hia[3]; }
int eo_x_BX(int c) { return (gi - gj) ^ hia[c]; }
int eo_x_BN(int c) { return (gi - gj) ^ !hi; }
int eo_x_BU(int c) { return (gi - gj) ^ -hi; }
int eo_x_BB(int c) { return (gi - gj) ^ (hi - hj); }
int eo_x_BC(int c) { return (gi - gj) ^ (256 - hi); }
int eo_x_BT(int c) { return (gi - gj) ^ (hc ? hi : hj); }
int eo_x_BS(int c) { return (gi - gj) ^ (hi << c); }
int eo_x_BD(int c) { return (gi - gj) ^ hps->i; }
int eo_x_CK(int c) { return (256 - gi) ^ 7; }
int eo_x_CG(int c) { return (256 - gi) ^ hi; }
int eo_x_CM(int c) { return (256 - gi) ^ hs.i; }
int eo_x_CP(int c) { return (256 - gi) ^ *hpi; }
int eo_x_CE(int c) { return (256 - gi) ^ hia[3]; }
int eo_x_CX(int c) { return (256 - gi) ^ hia[c]; }
int eo_x_CN(int c) { return (256 - gi) ^ !hi; }
int eo_x_CU(int c) { return (256 - gi) ^ -hi; }
int eo_x_CB(int c) { return (256 - gi) ^ (hi - hj); }
int eo_x_CC(int c) { return (256 - gi) ^ (256 - hi); }
int eo_x_CT(int c) { return (256 - gi) ^ (hc ? hi : hj); }
int eo_x_CS(int c) { return (256 - gi) ^ (hi << c); }
int eo_x_CD(int c) { return (256 - gi) ^ hps->i; }
int eo_x_TK(int c) { return (gc ? gi : gj) ^ 7; }
int eo_x_TG(int c) { return (gc ? gi : gj) ^ hi; }
int eo_x_TM(int c) { return (gc ? gi : gj) ^ hs.i; }
int eo_x_TP(int c) { return (gc ? gi : gj) ^ *hpi; }
int eo_x_TE(int c) { return (gc ? gi : gj) ^ hia[3]; }
int eo_x_TX(int c) { return (gc ? gi : gj) ^ hia[c]; }
int eo_x_TN(int c) { return (gc ? gi : gj) ^ !hi; }
int eo_x_TU(int c) { return (gc ? gi : gj) ^ -hi; }
int eo_x_TB(int c) { return (gc ? gi : gj) ^ (hi - hj); }
int eo_x_TC(int c) { return (gc ? gi : gj) ^ (256 - hi); }
int eo_x_TT(int c) { return (gc ? gi : gj) ^ (hc ? hi : hj); }
int eo_x_TS(int c) { return (gc ? gi : gj) ^ (hi << c); }
int eo_x_TD(int c) { return (gc ? gi : gj) ^ hps->i; }
int eo_x_SK(int c) { return (gi << c) ^ 7; }
int eo_x_SG(int c) { return (gi << c) ^ hi; }
int eo_x_SM(int c) { return (gi << c) ^ hs.i; }
int eo_x_SP(int c) { return (gi << c) ^ *hpi; }
int eo_x_SE(int c) { return (gi << c) ^ hia[3]; }
int eo_x_SX(int c) { return (gi << c) ^ hia[c]; }
int eo_x_SN(int c) { return (gi << c) ^ !hi; }
int eo_x_SU(int c) { return (gi << c) ^ -hi; }
int eo_x_SB(int c) { return (gi << c) ^ (hi - hj); }
int eo_x_SC(int c) { return (gi << c) ^ (256 - hi); }
int eo_x_ST(int c) { return (gi << c) ^ (hc ? hi : hj); }
int eo_x_SS(int c) { return (gi << c) ^ (hi << c); }
int eo_x_SD(int c) { return (gi << c) ^ hps->i; }
int eo_x_DK(int c) { return gps->i ^ 7; }
int eo_x_DG(int c) { return gps->i ^ hi; }
int eo_x_DM(int c) { return gps->i ^ hs.i; }
int eo_x_DP(int c) { return gps->i ^ *hpi; }
int eo_x_DE(int c) { return gps->i ^ hia[3]; }
int eo_x_DX(int c) { return gps->i ^ hia[c]; }
int eo_x_DN(int c) { return gps->i ^ !hi; }
int eo_x_DU(int c) { return gps->i ^ -hi; }
int eo_x_DB(int c) { return gps->i ^ (hi - hj); }
int eo_x_DC(int c) { return gps->i ^ (256 - hi); }
int eo_x_DT(int c) { return gps->i ^ (hc ? hi : hj); }
int eo_x_DS(int c) { return gps->i ^ (hi << c); }
int eo_x_DD(int c) { return gps->i ^ hps->i; }

int eo_m_KK(int c) { return 7 * 7; }
int eo_m_KG(int c) { return 7 * hi; }
int eo_m_KM(int c) { return 7 * hs.i; }
int eo_m_KP(int c) { return 7 * *hpi; }
int eo_m_KE(int c) { return 7 * hia[3]; }
int eo_m_KX(int c) { return 7 * hia[c]; }
int eo_m_KN(int c) { return 7 * !hi; }
int eo_m_KU(int c) { return 7 * -hi; }
int eo_m_KB(int c) { return 7 * (hi - hj); }
int eo_m_KC(int c) { return 7 * (256 - hi); }
int eo_m_KT(int c) { return 7 * (hc ? hi : hj); }
int eo_m_KS(int c) { return 7 * (hi << c); }
int eo_m_KD(int c) { return 7 * hps->i; }
int eo_m_GK(int c) { return gi * 7; }
int eo_m_GG(int c) { return gi * hi; }
int eo_m_GM(int c) { return gi * hs.i; }
int eo_m_GP(int c) { return gi * *hpi; }
int eo_m_GE(int c) { return gi * hia[3]; }
int eo_m_GX(int c) { return gi * hia[c]; }
int eo_m_GN(int c) { return gi * !hi; }
int eo_m_GU(int c) { return gi * -hi; }
int eo_m_GB(int c) { return gi * (hi - hj); }
int eo_m_GC(int c) { return gi * (256 - hi); }
int eo_m_GT(int c) { return gi * (hc ? hi : hj); }
int eo_m_GS(int c) { return gi * (hi << c); }
int eo_m_GD(int c) { return gi * hps->i; }
int eo_m_MK(int c) { return gs.i * 7; }
int eo_m_MG(int c) { return gs.i * hi; }
int eo_m_MM(int c) { return gs.i * hs.i; }
int eo_m_MP(int c) { return gs.i * *hpi; }
int eo_m_ME(int c) { return gs.i * hia[3]; }
int eo_m_MX(int c) { return gs.i * hia[c]; }
int eo_m_MN(int c) { return gs.i * !hi; }
int eo_m_MU(int c) { return gs.i * -hi; }
int eo_m_MB(int c) { return gs.i * (hi - hj); }
int eo_m_MC(int c) { return gs.i * (256 - hi); }
int eo_m_MT(int c) { return gs.i * (hc ? hi : hj); }
int eo_m_MS(int c) { return gs.i * (hi << c); }
int eo_m_MD(int c) { return gs.i * hps->i; }
int eo_m_PK(int c) { return *gpi * 7; }
int eo_m_PG(int c) { return *gpi * hi; }
int eo_m_PM(int c) { return *gpi * hs.i; }
int eo_m_PP(int c) { return *gpi * *hpi; }
int eo_m_PE(int c) { return *gpi * hia[3]; }
int eo_m_PX(int c) { return *gpi * hia[c]; }
int eo_m_PN(int c) { return *gpi * !hi; }
int eo_m_PU(int c) { return *gpi * -hi; }
int eo_m_PB(int c) { return *gpi * (hi - hj); }
int eo_m_PC(int c) { return *gpi * (256 - hi); }
int eo_m_PT(int c) { return *gpi * (hc ? hi : hj); }
int eo_m_PS(int c) { return *gpi * (hi << c); }
int eo_m_PD(int c) { return *gpi * hps->i; }
int eo_m_EK(int c) { return gia[3] * 7; }
int eo_m_EG(int c) { return gia[3] * hi; }
int eo_m_EM(int c) { return gia[3] * hs.i; }
int eo_m_EP(int c) { return gia[3] * *hpi; }
int eo_m_EE(int c) { return gia[3] * hia[3]; }
int eo_m_EX(int c) { return gia[3] * hia[c]; }
int eo_m_EN(int c) { return gia[3] * !hi; }
int eo_m_EU(int c) { return gia[3] * -hi; }
int eo_m_EB(int c) { return gia[3] * (hi - hj); }
int eo_m_EC(int c) { return gia[3] * (256 - hi); }
int eo_m_ET(int c) { return gia[3] * (hc ? hi : hj); }
int eo_m_ES(int c) { return gia[3] * (hi << c); }
int eo_m_ED(int c) { return gia[3] * hps->i; }
int eo_m_XK(int c) { return gia[c] * 7; }
int eo_m_XG(int c) { return gia[c] * hi; }
int eo_m_XM(int c) { return gia[c] * hs.i; }
int eo_m_XP(int c) { return gia[c] * *hpi; }
int eo_m_XE(int c) { return gia[c] * hia[3]; }
int eo_m_XX(int c) { return gia[c] * hia[c]; }
int eo_m_XN(int c) { return gia[c] * !hi; }
int eo_m_XU(int c) { return gia[c] * -hi; }
int eo_m_XB(int c) { return gia[c] * (hi - hj); }
int eo_m_XC(int c) { return gia[c] * (256 - hi); }
int eo_m_XT(int c) { return gia[c] * (hc ? hi : hj); }
int eo_m_XS(int c) { return gia[c] * (hi << c); }
int eo_m_XD(int c) { return gia[c] * hps->i; }
int eo_m_NK(int c) { return !gi * 7; }
int eo_m_NG(int c) { return !gi * hi; }
int eo_m_NM(int c) { return !gi * hs.i; }
int eo_m_NP(int c) { return !gi * *hpi; }
int eo_m_NE(int c) { return !gi * hia[3]; }
int eo_m_NX(int c) { return !gi * hia[c]; }
int eo_m_NN(int c) { return !gi * !hi; }
int eo_m_NU(int c) { return !gi * -hi; }
int eo_m_NB(int c) { return !gi * (hi - hj); }
int eo_m_NC(int c) { return !gi * (256 - hi); }
int eo_m_NT(int c) { return !gi * (hc ? hi : hj); }
int eo_m_NS(int c) { return !gi * (hi << c); }
int eo_m_ND(int c) { return !gi * hps->i; }
int eo_m_UK(int c) { return -gi * 7; }
int eo_m_UG(int c) { return -gi * hi; }
int eo_m_UM(int c) { return -gi * hs.i; }
int eo_m_UP(int c) { return -gi * *hpi; }
int eo_m_UE(int c) { return -gi * hia[3]; }
int eo_m_UX(int c) { return -gi * hia[c]; }
int eo_m_UN(int c) { return -gi * !hi; }
int eo_m_UU(int c) { return -gi * -hi; }
int eo_m_UB(int c) { return -gi * (hi - hj); }
int eo_m_UC(int c) { return -gi * (256 - hi); }
int eo_m_UT(int c) { return -gi * (hc ? hi : hj); }
int eo_m_US(int c) { return -gi * (hi << c); }
int eo_m_UD(int c) { return -gi * hps->i; }
int eo_m_BK(int c) { return (gi - gj) * 7; }
int eo_m_BG(int c) { return (gi - gj) * hi; }
int eo_m_BM(int c) { return (gi - gj) * hs.i; }
int eo_m_BP(int c) { return (gi - gj) * *hpi; }
int eo_m_BE(int c) { return (gi - gj) * hia[3]; }
int eo_m_BX(int c) { return (gi - gj) * hia[c]; }
int eo_m_BN(int c) { return (gi - gj) * !hi; }
int eo_m_BU(int c) { return (gi - gj) * -hi; }
int eo_m_BB(int c) { return (gi - gj) * (hi - hj); }
int eo_m_BC(int c) { return (gi - gj) * (256 - hi); }
int eo_m_BT(int c) { return (gi - gj) * (hc ? hi : hj); }
int eo_m_BS(int c) { return (gi - gj) * (hi << c); }
int eo_m_BD(int c) { return (gi - gj) * hps->i; }
int eo_m_CK(int c) { return (256 - gi) * 7; }
int eo_m_CG(int c) { return (256 - gi) * hi; }
int eo_m_CM(int c) { return (256 - gi) * hs.i; }
int eo_m_CP(int c) { return (256 - gi) * *hpi; }
int eo_m_CE(int c) { return (256 - gi) * hia[3]; }
int eo_m_CX(int c) { return (256 - gi) * hia[c]; }
int eo_m_CN(int c) { return (256 - gi) * !hi; }
int eo_m_CU(int c) { return (256 - gi) * -hi; }
int eo_m_CB(int c) { return (256 - gi) * (hi - hj); }
int eo_m_CC(int c) { return (256 - gi) * (256 - hi); }
int eo_m_CT(int c) { return (256 - gi) * (hc ? hi : hj); }
int eo_m_CS(int c) { return (256 - gi) * (hi << c); }
int eo_m_CD(int c) { return (256 - gi) * hps->i; }
int eo_m_TK(int c) { return (gc ? gi : gj) * 7; }
int eo_m_TG(int c) { return (gc ? gi : gj) * hi; }
int eo_m_TM(int c) { return (gc ? gi : gj) * hs.i; }
int eo_m_TP(int c) { return (gc ? gi : gj) * *hpi; }
int eo_m_TE(int c) { return (gc ? gi : gj) * hia[3]; }
int eo_m_TX(int c) { return (gc ? gi : gj) * hia[c]; }
int eo_m_TN(int c) { return (gc ? gi : gj) * !hi; }
int eo_m_TU(int c) { return (gc ? gi : gj) * -hi; }
int eo_m_TB(int c) { return (gc ? gi : gj) * (hi - hj); }
int eo_m_TC(int c) { return (gc ? gi : gj) * (256 - hi); }
int eo_m_TT(int c) { return (gc ? gi : gj) * (hc ? hi : hj); }
int eo_m_TS(int c) { return (gc ? gi : gj) * (hi << c); }
int eo_m_TD(int c) { return (gc ? gi : gj) * hps->i; }
int eo_m_SK(int c) { return (gi << c) * 7; }
int eo_m_SG(int c) { return (gi << c) * hi; }
int eo_m_SM(int c) { return (gi << c) * hs.i; }
int eo_m_SP(int c) { return (gi << c) * *hpi; }
int eo_m_SE(int c) { return (gi << c) * hia[3]; }
int eo_m_SX(int c) { return (gi << c) * hia[c]; }
int eo_m_SN(int c) { return (gi << c) * !hi; }
int eo_m_SU(int c) { return (gi << c) * -hi; }
int eo_m_SB(int c) { return (gi << c) * (hi - hj); }
int eo_m_SC(int c) { return (gi << c) * (256 - hi); }
int eo_m_ST(int c) { return (gi << c) * (hc ? hi : hj); }
int eo_m_SS(int c) { return (gi << c) * (hi << c); }
int eo_m_SD(int c) { return (gi << c) * hps->i; }
int eo_m_DK(int c) { return gps->i * 7; }
int eo_m_DG(int c) { return gps->i * hi; }
int eo_m_DM(int c) { return gps->i * hs.i; }
int eo_m_DP(int c) { return gps->i * *hpi; }
int eo_m_DE(int c) { return gps->i * hia[3]; }
int eo_m_DX(int c) { return gps->i * hia[c]; }
int eo_m_DN(int c) { return gps->i * !hi; }
int eo_m_DU(int c) { return gps->i * -hi; }
int eo_m_DB(int c) { return gps->i * (hi - hj); }
int eo_m_DC(int c) { return gps->i * (256 - hi); }
int eo_m_DT(int c) { return gps->i * (hc ? hi : hj); }
int eo_m_DS(int c) { return gps->i * (hi << c); }
int eo_m_DD(int c) { return gps->i * hps->i; }
