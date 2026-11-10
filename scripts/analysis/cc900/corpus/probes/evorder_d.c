/* Evaluation order, fourth probe (gen_evorder3.py): the int kinds of evorder.c for / (d) and % (r), which call no
   helper at 16 bits (divs WA,src): which operand is the accumulator and the order of their code.  ed_<op>_<L><R>(c)
   returns L op R; the left side reads g* globals, the right h*.  Kinds as in evorder.c. */
struct st { int i; int a[4]; };
extern int gi, gj, gc, hi, hj, hc; extern int gia[10], hia[10]; extern int *gpi, *hpi;
extern struct st gs, *gps, hs, *hps;

int ed_d_KK(int c) { return 7 / 7; }
int ed_d_KG(int c) { return 7 / hi; }
int ed_d_KM(int c) { return 7 / hs.i; }
int ed_d_KP(int c) { return 7 / *hpi; }
int ed_d_KE(int c) { return 7 / hia[3]; }
int ed_d_KX(int c) { return 7 / hia[c]; }
int ed_d_KN(int c) { return 7 / !hi; }
int ed_d_KU(int c) { return 7 / -hi; }
int ed_d_KB(int c) { return 7 / (hi - hj); }
int ed_d_KC(int c) { return 7 / (256 - hi); }
int ed_d_KT(int c) { return 7 / (hc ? hi : hj); }
int ed_d_KS(int c) { return 7 / (hi << c); }
int ed_d_KD(int c) { return 7 / hps->i; }
int ed_d_GK(int c) { return gi / 7; }
int ed_d_GG(int c) { return gi / hi; }
int ed_d_GM(int c) { return gi / hs.i; }
int ed_d_GP(int c) { return gi / *hpi; }
int ed_d_GE(int c) { return gi / hia[3]; }
int ed_d_GX(int c) { return gi / hia[c]; }
int ed_d_GN(int c) { return gi / !hi; }
int ed_d_GU(int c) { return gi / -hi; }
int ed_d_GB(int c) { return gi / (hi - hj); }
int ed_d_GC(int c) { return gi / (256 - hi); }
int ed_d_GT(int c) { return gi / (hc ? hi : hj); }
int ed_d_GS(int c) { return gi / (hi << c); }
int ed_d_GD(int c) { return gi / hps->i; }
int ed_d_MK(int c) { return gs.i / 7; }
int ed_d_MG(int c) { return gs.i / hi; }
int ed_d_MM(int c) { return gs.i / hs.i; }
int ed_d_MP(int c) { return gs.i / *hpi; }
int ed_d_ME(int c) { return gs.i / hia[3]; }
int ed_d_MX(int c) { return gs.i / hia[c]; }
int ed_d_MN(int c) { return gs.i / !hi; }
int ed_d_MU(int c) { return gs.i / -hi; }
int ed_d_MB(int c) { return gs.i / (hi - hj); }
int ed_d_MC(int c) { return gs.i / (256 - hi); }
int ed_d_MT(int c) { return gs.i / (hc ? hi : hj); }
int ed_d_MS(int c) { return gs.i / (hi << c); }
int ed_d_MD(int c) { return gs.i / hps->i; }
int ed_d_PK(int c) { return *gpi / 7; }
int ed_d_PG(int c) { return *gpi / hi; }
int ed_d_PM(int c) { return *gpi / hs.i; }
int ed_d_PP(int c) { return *gpi / *hpi; }
int ed_d_PE(int c) { return *gpi / hia[3]; }
int ed_d_PX(int c) { return *gpi / hia[c]; }
int ed_d_PN(int c) { return *gpi / !hi; }
int ed_d_PU(int c) { return *gpi / -hi; }
int ed_d_PB(int c) { return *gpi / (hi - hj); }
int ed_d_PC(int c) { return *gpi / (256 - hi); }
int ed_d_PT(int c) { return *gpi / (hc ? hi : hj); }
int ed_d_PS(int c) { return *gpi / (hi << c); }
int ed_d_PD(int c) { return *gpi / hps->i; }
int ed_d_EK(int c) { return gia[3] / 7; }
int ed_d_EG(int c) { return gia[3] / hi; }
int ed_d_EM(int c) { return gia[3] / hs.i; }
int ed_d_EP(int c) { return gia[3] / *hpi; }
int ed_d_EE(int c) { return gia[3] / hia[3]; }
int ed_d_EX(int c) { return gia[3] / hia[c]; }
int ed_d_EN(int c) { return gia[3] / !hi; }
int ed_d_EU(int c) { return gia[3] / -hi; }
int ed_d_EB(int c) { return gia[3] / (hi - hj); }
int ed_d_EC(int c) { return gia[3] / (256 - hi); }
int ed_d_ET(int c) { return gia[3] / (hc ? hi : hj); }
int ed_d_ES(int c) { return gia[3] / (hi << c); }
int ed_d_ED(int c) { return gia[3] / hps->i; }
int ed_d_XK(int c) { return gia[c] / 7; }
int ed_d_XG(int c) { return gia[c] / hi; }
int ed_d_XM(int c) { return gia[c] / hs.i; }
int ed_d_XP(int c) { return gia[c] / *hpi; }
int ed_d_XE(int c) { return gia[c] / hia[3]; }
int ed_d_XX(int c) { return gia[c] / hia[c]; }
int ed_d_XN(int c) { return gia[c] / !hi; }
int ed_d_XU(int c) { return gia[c] / -hi; }
int ed_d_XB(int c) { return gia[c] / (hi - hj); }
int ed_d_XC(int c) { return gia[c] / (256 - hi); }
int ed_d_XT(int c) { return gia[c] / (hc ? hi : hj); }
int ed_d_XS(int c) { return gia[c] / (hi << c); }
int ed_d_XD(int c) { return gia[c] / hps->i; }
int ed_d_NK(int c) { return !gi / 7; }
int ed_d_NG(int c) { return !gi / hi; }
int ed_d_NM(int c) { return !gi / hs.i; }
int ed_d_NP(int c) { return !gi / *hpi; }
int ed_d_NE(int c) { return !gi / hia[3]; }
int ed_d_NX(int c) { return !gi / hia[c]; }
int ed_d_NN(int c) { return !gi / !hi; }
int ed_d_NU(int c) { return !gi / -hi; }
int ed_d_NB(int c) { return !gi / (hi - hj); }
int ed_d_NC(int c) { return !gi / (256 - hi); }
int ed_d_NT(int c) { return !gi / (hc ? hi : hj); }
int ed_d_NS(int c) { return !gi / (hi << c); }
int ed_d_ND(int c) { return !gi / hps->i; }
int ed_d_UK(int c) { return -gi / 7; }
int ed_d_UG(int c) { return -gi / hi; }
int ed_d_UM(int c) { return -gi / hs.i; }
int ed_d_UP(int c) { return -gi / *hpi; }
int ed_d_UE(int c) { return -gi / hia[3]; }
int ed_d_UX(int c) { return -gi / hia[c]; }
int ed_d_UN(int c) { return -gi / !hi; }
int ed_d_UU(int c) { return -gi / -hi; }
int ed_d_UB(int c) { return -gi / (hi - hj); }
int ed_d_UC(int c) { return -gi / (256 - hi); }
int ed_d_UT(int c) { return -gi / (hc ? hi : hj); }
int ed_d_US(int c) { return -gi / (hi << c); }
int ed_d_UD(int c) { return -gi / hps->i; }
int ed_d_BK(int c) { return (gi - gj) / 7; }
int ed_d_BG(int c) { return (gi - gj) / hi; }
int ed_d_BM(int c) { return (gi - gj) / hs.i; }
int ed_d_BP(int c) { return (gi - gj) / *hpi; }
int ed_d_BE(int c) { return (gi - gj) / hia[3]; }
int ed_d_BX(int c) { return (gi - gj) / hia[c]; }
int ed_d_BN(int c) { return (gi - gj) / !hi; }
int ed_d_BU(int c) { return (gi - gj) / -hi; }
int ed_d_BB(int c) { return (gi - gj) / (hi - hj); }
int ed_d_BC(int c) { return (gi - gj) / (256 - hi); }
int ed_d_BT(int c) { return (gi - gj) / (hc ? hi : hj); }
int ed_d_BS(int c) { return (gi - gj) / (hi << c); }
int ed_d_BD(int c) { return (gi - gj) / hps->i; }
int ed_d_CK(int c) { return (256 - gi) / 7; }
int ed_d_CG(int c) { return (256 - gi) / hi; }
int ed_d_CM(int c) { return (256 - gi) / hs.i; }
int ed_d_CP(int c) { return (256 - gi) / *hpi; }
int ed_d_CE(int c) { return (256 - gi) / hia[3]; }
int ed_d_CX(int c) { return (256 - gi) / hia[c]; }
int ed_d_CN(int c) { return (256 - gi) / !hi; }
int ed_d_CU(int c) { return (256 - gi) / -hi; }
int ed_d_CB(int c) { return (256 - gi) / (hi - hj); }
int ed_d_CC(int c) { return (256 - gi) / (256 - hi); }
int ed_d_CT(int c) { return (256 - gi) / (hc ? hi : hj); }
int ed_d_CS(int c) { return (256 - gi) / (hi << c); }
int ed_d_CD(int c) { return (256 - gi) / hps->i; }
int ed_d_TK(int c) { return (gc ? gi : gj) / 7; }
int ed_d_TG(int c) { return (gc ? gi : gj) / hi; }
int ed_d_TM(int c) { return (gc ? gi : gj) / hs.i; }
int ed_d_TP(int c) { return (gc ? gi : gj) / *hpi; }
int ed_d_TE(int c) { return (gc ? gi : gj) / hia[3]; }
int ed_d_TX(int c) { return (gc ? gi : gj) / hia[c]; }
int ed_d_TN(int c) { return (gc ? gi : gj) / !hi; }
int ed_d_TU(int c) { return (gc ? gi : gj) / -hi; }
int ed_d_TB(int c) { return (gc ? gi : gj) / (hi - hj); }
int ed_d_TC(int c) { return (gc ? gi : gj) / (256 - hi); }
int ed_d_TT(int c) { return (gc ? gi : gj) / (hc ? hi : hj); }
int ed_d_TS(int c) { return (gc ? gi : gj) / (hi << c); }
int ed_d_TD(int c) { return (gc ? gi : gj) / hps->i; }
int ed_d_SK(int c) { return (gi << c) / 7; }
int ed_d_SG(int c) { return (gi << c) / hi; }
int ed_d_SM(int c) { return (gi << c) / hs.i; }
int ed_d_SP(int c) { return (gi << c) / *hpi; }
int ed_d_SE(int c) { return (gi << c) / hia[3]; }
int ed_d_SX(int c) { return (gi << c) / hia[c]; }
int ed_d_SN(int c) { return (gi << c) / !hi; }
int ed_d_SU(int c) { return (gi << c) / -hi; }
int ed_d_SB(int c) { return (gi << c) / (hi - hj); }
int ed_d_SC(int c) { return (gi << c) / (256 - hi); }
int ed_d_ST(int c) { return (gi << c) / (hc ? hi : hj); }
int ed_d_SS(int c) { return (gi << c) / (hi << c); }
int ed_d_SD(int c) { return (gi << c) / hps->i; }
int ed_d_DK(int c) { return gps->i / 7; }
int ed_d_DG(int c) { return gps->i / hi; }
int ed_d_DM(int c) { return gps->i / hs.i; }
int ed_d_DP(int c) { return gps->i / *hpi; }
int ed_d_DE(int c) { return gps->i / hia[3]; }
int ed_d_DX(int c) { return gps->i / hia[c]; }
int ed_d_DN(int c) { return gps->i / !hi; }
int ed_d_DU(int c) { return gps->i / -hi; }
int ed_d_DB(int c) { return gps->i / (hi - hj); }
int ed_d_DC(int c) { return gps->i / (256 - hi); }
int ed_d_DT(int c) { return gps->i / (hc ? hi : hj); }
int ed_d_DS(int c) { return gps->i / (hi << c); }
int ed_d_DD(int c) { return gps->i / hps->i; }

int ed_r_KK(int c) { return 7 % 7; }
int ed_r_KG(int c) { return 7 % hi; }
int ed_r_KM(int c) { return 7 % hs.i; }
int ed_r_KP(int c) { return 7 % *hpi; }
int ed_r_KE(int c) { return 7 % hia[3]; }
int ed_r_KX(int c) { return 7 % hia[c]; }
int ed_r_KN(int c) { return 7 % !hi; }
int ed_r_KU(int c) { return 7 % -hi; }
int ed_r_KB(int c) { return 7 % (hi - hj); }
int ed_r_KC(int c) { return 7 % (256 - hi); }
int ed_r_KT(int c) { return 7 % (hc ? hi : hj); }
int ed_r_KS(int c) { return 7 % (hi << c); }
int ed_r_KD(int c) { return 7 % hps->i; }
int ed_r_GK(int c) { return gi % 7; }
int ed_r_GG(int c) { return gi % hi; }
int ed_r_GM(int c) { return gi % hs.i; }
int ed_r_GP(int c) { return gi % *hpi; }
int ed_r_GE(int c) { return gi % hia[3]; }
int ed_r_GX(int c) { return gi % hia[c]; }
int ed_r_GN(int c) { return gi % !hi; }
int ed_r_GU(int c) { return gi % -hi; }
int ed_r_GB(int c) { return gi % (hi - hj); }
int ed_r_GC(int c) { return gi % (256 - hi); }
int ed_r_GT(int c) { return gi % (hc ? hi : hj); }
int ed_r_GS(int c) { return gi % (hi << c); }
int ed_r_GD(int c) { return gi % hps->i; }
int ed_r_MK(int c) { return gs.i % 7; }
int ed_r_MG(int c) { return gs.i % hi; }
int ed_r_MM(int c) { return gs.i % hs.i; }
int ed_r_MP(int c) { return gs.i % *hpi; }
int ed_r_ME(int c) { return gs.i % hia[3]; }
int ed_r_MX(int c) { return gs.i % hia[c]; }
int ed_r_MN(int c) { return gs.i % !hi; }
int ed_r_MU(int c) { return gs.i % -hi; }
int ed_r_MB(int c) { return gs.i % (hi - hj); }
int ed_r_MC(int c) { return gs.i % (256 - hi); }
int ed_r_MT(int c) { return gs.i % (hc ? hi : hj); }
int ed_r_MS(int c) { return gs.i % (hi << c); }
int ed_r_MD(int c) { return gs.i % hps->i; }
int ed_r_PK(int c) { return *gpi % 7; }
int ed_r_PG(int c) { return *gpi % hi; }
int ed_r_PM(int c) { return *gpi % hs.i; }
int ed_r_PP(int c) { return *gpi % *hpi; }
int ed_r_PE(int c) { return *gpi % hia[3]; }
int ed_r_PX(int c) { return *gpi % hia[c]; }
int ed_r_PN(int c) { return *gpi % !hi; }
int ed_r_PU(int c) { return *gpi % -hi; }
int ed_r_PB(int c) { return *gpi % (hi - hj); }
int ed_r_PC(int c) { return *gpi % (256 - hi); }
int ed_r_PT(int c) { return *gpi % (hc ? hi : hj); }
int ed_r_PS(int c) { return *gpi % (hi << c); }
int ed_r_PD(int c) { return *gpi % hps->i; }
int ed_r_EK(int c) { return gia[3] % 7; }
int ed_r_EG(int c) { return gia[3] % hi; }
int ed_r_EM(int c) { return gia[3] % hs.i; }
int ed_r_EP(int c) { return gia[3] % *hpi; }
int ed_r_EE(int c) { return gia[3] % hia[3]; }
int ed_r_EX(int c) { return gia[3] % hia[c]; }
int ed_r_EN(int c) { return gia[3] % !hi; }
int ed_r_EU(int c) { return gia[3] % -hi; }
int ed_r_EB(int c) { return gia[3] % (hi - hj); }
int ed_r_EC(int c) { return gia[3] % (256 - hi); }
int ed_r_ET(int c) { return gia[3] % (hc ? hi : hj); }
int ed_r_ES(int c) { return gia[3] % (hi << c); }
int ed_r_ED(int c) { return gia[3] % hps->i; }
int ed_r_XK(int c) { return gia[c] % 7; }
int ed_r_XG(int c) { return gia[c] % hi; }
int ed_r_XM(int c) { return gia[c] % hs.i; }
int ed_r_XP(int c) { return gia[c] % *hpi; }
int ed_r_XE(int c) { return gia[c] % hia[3]; }
int ed_r_XX(int c) { return gia[c] % hia[c]; }
int ed_r_XN(int c) { return gia[c] % !hi; }
int ed_r_XU(int c) { return gia[c] % -hi; }
int ed_r_XB(int c) { return gia[c] % (hi - hj); }
int ed_r_XC(int c) { return gia[c] % (256 - hi); }
int ed_r_XT(int c) { return gia[c] % (hc ? hi : hj); }
int ed_r_XS(int c) { return gia[c] % (hi << c); }
int ed_r_XD(int c) { return gia[c] % hps->i; }
int ed_r_NK(int c) { return !gi % 7; }
int ed_r_NG(int c) { return !gi % hi; }
int ed_r_NM(int c) { return !gi % hs.i; }
int ed_r_NP(int c) { return !gi % *hpi; }
int ed_r_NE(int c) { return !gi % hia[3]; }
int ed_r_NX(int c) { return !gi % hia[c]; }
int ed_r_NN(int c) { return !gi % !hi; }
int ed_r_NU(int c) { return !gi % -hi; }
int ed_r_NB(int c) { return !gi % (hi - hj); }
int ed_r_NC(int c) { return !gi % (256 - hi); }
int ed_r_NT(int c) { return !gi % (hc ? hi : hj); }
int ed_r_NS(int c) { return !gi % (hi << c); }
int ed_r_ND(int c) { return !gi % hps->i; }
int ed_r_UK(int c) { return -gi % 7; }
int ed_r_UG(int c) { return -gi % hi; }
int ed_r_UM(int c) { return -gi % hs.i; }
int ed_r_UP(int c) { return -gi % *hpi; }
int ed_r_UE(int c) { return -gi % hia[3]; }
int ed_r_UX(int c) { return -gi % hia[c]; }
int ed_r_UN(int c) { return -gi % !hi; }
int ed_r_UU(int c) { return -gi % -hi; }
int ed_r_UB(int c) { return -gi % (hi - hj); }
int ed_r_UC(int c) { return -gi % (256 - hi); }
int ed_r_UT(int c) { return -gi % (hc ? hi : hj); }
int ed_r_US(int c) { return -gi % (hi << c); }
int ed_r_UD(int c) { return -gi % hps->i; }
int ed_r_BK(int c) { return (gi - gj) % 7; }
int ed_r_BG(int c) { return (gi - gj) % hi; }
int ed_r_BM(int c) { return (gi - gj) % hs.i; }
int ed_r_BP(int c) { return (gi - gj) % *hpi; }
int ed_r_BE(int c) { return (gi - gj) % hia[3]; }
int ed_r_BX(int c) { return (gi - gj) % hia[c]; }
int ed_r_BN(int c) { return (gi - gj) % !hi; }
int ed_r_BU(int c) { return (gi - gj) % -hi; }
int ed_r_BB(int c) { return (gi - gj) % (hi - hj); }
int ed_r_BC(int c) { return (gi - gj) % (256 - hi); }
int ed_r_BT(int c) { return (gi - gj) % (hc ? hi : hj); }
int ed_r_BS(int c) { return (gi - gj) % (hi << c); }
int ed_r_BD(int c) { return (gi - gj) % hps->i; }
int ed_r_CK(int c) { return (256 - gi) % 7; }
int ed_r_CG(int c) { return (256 - gi) % hi; }
int ed_r_CM(int c) { return (256 - gi) % hs.i; }
int ed_r_CP(int c) { return (256 - gi) % *hpi; }
int ed_r_CE(int c) { return (256 - gi) % hia[3]; }
int ed_r_CX(int c) { return (256 - gi) % hia[c]; }
int ed_r_CN(int c) { return (256 - gi) % !hi; }
int ed_r_CU(int c) { return (256 - gi) % -hi; }
int ed_r_CB(int c) { return (256 - gi) % (hi - hj); }
int ed_r_CC(int c) { return (256 - gi) % (256 - hi); }
int ed_r_CT(int c) { return (256 - gi) % (hc ? hi : hj); }
int ed_r_CS(int c) { return (256 - gi) % (hi << c); }
int ed_r_CD(int c) { return (256 - gi) % hps->i; }
int ed_r_TK(int c) { return (gc ? gi : gj) % 7; }
int ed_r_TG(int c) { return (gc ? gi : gj) % hi; }
int ed_r_TM(int c) { return (gc ? gi : gj) % hs.i; }
int ed_r_TP(int c) { return (gc ? gi : gj) % *hpi; }
int ed_r_TE(int c) { return (gc ? gi : gj) % hia[3]; }
int ed_r_TX(int c) { return (gc ? gi : gj) % hia[c]; }
int ed_r_TN(int c) { return (gc ? gi : gj) % !hi; }
int ed_r_TU(int c) { return (gc ? gi : gj) % -hi; }
int ed_r_TB(int c) { return (gc ? gi : gj) % (hi - hj); }
int ed_r_TC(int c) { return (gc ? gi : gj) % (256 - hi); }
int ed_r_TT(int c) { return (gc ? gi : gj) % (hc ? hi : hj); }
int ed_r_TS(int c) { return (gc ? gi : gj) % (hi << c); }
int ed_r_TD(int c) { return (gc ? gi : gj) % hps->i; }
int ed_r_SK(int c) { return (gi << c) % 7; }
int ed_r_SG(int c) { return (gi << c) % hi; }
int ed_r_SM(int c) { return (gi << c) % hs.i; }
int ed_r_SP(int c) { return (gi << c) % *hpi; }
int ed_r_SE(int c) { return (gi << c) % hia[3]; }
int ed_r_SX(int c) { return (gi << c) % hia[c]; }
int ed_r_SN(int c) { return (gi << c) % !hi; }
int ed_r_SU(int c) { return (gi << c) % -hi; }
int ed_r_SB(int c) { return (gi << c) % (hi - hj); }
int ed_r_SC(int c) { return (gi << c) % (256 - hi); }
int ed_r_ST(int c) { return (gi << c) % (hc ? hi : hj); }
int ed_r_SS(int c) { return (gi << c) % (hi << c); }
int ed_r_SD(int c) { return (gi << c) % hps->i; }
int ed_r_DK(int c) { return gps->i % 7; }
int ed_r_DG(int c) { return gps->i % hi; }
int ed_r_DM(int c) { return gps->i % hs.i; }
int ed_r_DP(int c) { return gps->i % *hpi; }
int ed_r_DE(int c) { return gps->i % hia[3]; }
int ed_r_DX(int c) { return gps->i % hia[c]; }
int ed_r_DN(int c) { return gps->i % !hi; }
int ed_r_DU(int c) { return gps->i % -hi; }
int ed_r_DB(int c) { return gps->i % (hi - hj); }
int ed_r_DC(int c) { return gps->i % (256 - hi); }
int ed_r_DT(int c) { return gps->i % (hc ? hi : hj); }
int ed_r_DS(int c) { return gps->i % (hi << c); }
int ed_r_DD(int c) { return gps->i % hps->i; }
