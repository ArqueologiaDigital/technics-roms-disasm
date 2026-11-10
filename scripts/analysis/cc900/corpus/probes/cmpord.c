/* Compare operands, by operand kind (gen_cmpord.py): the kinds of evorder.c on both sides of < (l) and == (e) as
   the condition of an if (ci_<op>_<L><R>(c): if (L op R) gi3 = 1;) and of < as a value (cv_l_<L><R>: return
   L < R).  The left side reads g* globals, the right h*, so a listing shows which operand was computed first,
   where each landed and which compare instruction was used. */
struct st { int i; int a[4]; };
extern int gi, gj, gc, hi, hj, hc, gi3; extern int gia[10], hia[10]; extern int *gpi, *hpi;
extern struct st gs, *gps, hs, *hps;

void ci_l_KK(int c) { if (7 < 7) gi3 = 1; }
void ci_l_KG(int c) { if (7 < hi) gi3 = 1; }
void ci_l_KM(int c) { if (7 < hs.i) gi3 = 1; }
void ci_l_KP(int c) { if (7 < *hpi) gi3 = 1; }
void ci_l_KE(int c) { if (7 < hia[3]) gi3 = 1; }
void ci_l_KX(int c) { if (7 < hia[c]) gi3 = 1; }
void ci_l_KN(int c) { if (7 < !hi) gi3 = 1; }
void ci_l_KU(int c) { if (7 < -hi) gi3 = 1; }
void ci_l_KB(int c) { if (7 < (hi - hj)) gi3 = 1; }
void ci_l_KC(int c) { if (7 < (256 - hi)) gi3 = 1; }
void ci_l_KT(int c) { if (7 < (hc ? hi : hj)) gi3 = 1; }
void ci_l_KS(int c) { if (7 < (hi << c)) gi3 = 1; }
void ci_l_KD(int c) { if (7 < hps->i) gi3 = 1; }
void ci_l_GK(int c) { if (gi < 7) gi3 = 1; }
void ci_l_GG(int c) { if (gi < hi) gi3 = 1; }
void ci_l_GM(int c) { if (gi < hs.i) gi3 = 1; }
void ci_l_GP(int c) { if (gi < *hpi) gi3 = 1; }
void ci_l_GE(int c) { if (gi < hia[3]) gi3 = 1; }
void ci_l_GX(int c) { if (gi < hia[c]) gi3 = 1; }
void ci_l_GN(int c) { if (gi < !hi) gi3 = 1; }
void ci_l_GU(int c) { if (gi < -hi) gi3 = 1; }
void ci_l_GB(int c) { if (gi < (hi - hj)) gi3 = 1; }
void ci_l_GC(int c) { if (gi < (256 - hi)) gi3 = 1; }
void ci_l_GT(int c) { if (gi < (hc ? hi : hj)) gi3 = 1; }
void ci_l_GS(int c) { if (gi < (hi << c)) gi3 = 1; }
void ci_l_GD(int c) { if (gi < hps->i) gi3 = 1; }
void ci_l_MK(int c) { if (gs.i < 7) gi3 = 1; }
void ci_l_MG(int c) { if (gs.i < hi) gi3 = 1; }
void ci_l_MM(int c) { if (gs.i < hs.i) gi3 = 1; }
void ci_l_MP(int c) { if (gs.i < *hpi) gi3 = 1; }
void ci_l_ME(int c) { if (gs.i < hia[3]) gi3 = 1; }
void ci_l_MX(int c) { if (gs.i < hia[c]) gi3 = 1; }
void ci_l_MN(int c) { if (gs.i < !hi) gi3 = 1; }
void ci_l_MU(int c) { if (gs.i < -hi) gi3 = 1; }
void ci_l_MB(int c) { if (gs.i < (hi - hj)) gi3 = 1; }
void ci_l_MC(int c) { if (gs.i < (256 - hi)) gi3 = 1; }
void ci_l_MT(int c) { if (gs.i < (hc ? hi : hj)) gi3 = 1; }
void ci_l_MS(int c) { if (gs.i < (hi << c)) gi3 = 1; }
void ci_l_MD(int c) { if (gs.i < hps->i) gi3 = 1; }
void ci_l_PK(int c) { if (*gpi < 7) gi3 = 1; }
void ci_l_PG(int c) { if (*gpi < hi) gi3 = 1; }
void ci_l_PM(int c) { if (*gpi < hs.i) gi3 = 1; }
void ci_l_PP(int c) { if (*gpi < *hpi) gi3 = 1; }
void ci_l_PE(int c) { if (*gpi < hia[3]) gi3 = 1; }
void ci_l_PX(int c) { if (*gpi < hia[c]) gi3 = 1; }
void ci_l_PN(int c) { if (*gpi < !hi) gi3 = 1; }
void ci_l_PU(int c) { if (*gpi < -hi) gi3 = 1; }
void ci_l_PB(int c) { if (*gpi < (hi - hj)) gi3 = 1; }
void ci_l_PC(int c) { if (*gpi < (256 - hi)) gi3 = 1; }
void ci_l_PT(int c) { if (*gpi < (hc ? hi : hj)) gi3 = 1; }
void ci_l_PS(int c) { if (*gpi < (hi << c)) gi3 = 1; }
void ci_l_PD(int c) { if (*gpi < hps->i) gi3 = 1; }
void ci_l_EK(int c) { if (gia[3] < 7) gi3 = 1; }
void ci_l_EG(int c) { if (gia[3] < hi) gi3 = 1; }
void ci_l_EM(int c) { if (gia[3] < hs.i) gi3 = 1; }
void ci_l_EP(int c) { if (gia[3] < *hpi) gi3 = 1; }
void ci_l_EE(int c) { if (gia[3] < hia[3]) gi3 = 1; }
void ci_l_EX(int c) { if (gia[3] < hia[c]) gi3 = 1; }
void ci_l_EN(int c) { if (gia[3] < !hi) gi3 = 1; }
void ci_l_EU(int c) { if (gia[3] < -hi) gi3 = 1; }
void ci_l_EB(int c) { if (gia[3] < (hi - hj)) gi3 = 1; }
void ci_l_EC(int c) { if (gia[3] < (256 - hi)) gi3 = 1; }
void ci_l_ET(int c) { if (gia[3] < (hc ? hi : hj)) gi3 = 1; }
void ci_l_ES(int c) { if (gia[3] < (hi << c)) gi3 = 1; }
void ci_l_ED(int c) { if (gia[3] < hps->i) gi3 = 1; }
void ci_l_XK(int c) { if (gia[c] < 7) gi3 = 1; }
void ci_l_XG(int c) { if (gia[c] < hi) gi3 = 1; }
void ci_l_XM(int c) { if (gia[c] < hs.i) gi3 = 1; }
void ci_l_XP(int c) { if (gia[c] < *hpi) gi3 = 1; }
void ci_l_XE(int c) { if (gia[c] < hia[3]) gi3 = 1; }
void ci_l_XX(int c) { if (gia[c] < hia[c]) gi3 = 1; }
void ci_l_XN(int c) { if (gia[c] < !hi) gi3 = 1; }
void ci_l_XU(int c) { if (gia[c] < -hi) gi3 = 1; }
void ci_l_XB(int c) { if (gia[c] < (hi - hj)) gi3 = 1; }
void ci_l_XC(int c) { if (gia[c] < (256 - hi)) gi3 = 1; }
void ci_l_XT(int c) { if (gia[c] < (hc ? hi : hj)) gi3 = 1; }
void ci_l_XS(int c) { if (gia[c] < (hi << c)) gi3 = 1; }
void ci_l_XD(int c) { if (gia[c] < hps->i) gi3 = 1; }
void ci_l_NK(int c) { if (!gi < 7) gi3 = 1; }
void ci_l_NG(int c) { if (!gi < hi) gi3 = 1; }
void ci_l_NM(int c) { if (!gi < hs.i) gi3 = 1; }
void ci_l_NP(int c) { if (!gi < *hpi) gi3 = 1; }
void ci_l_NE(int c) { if (!gi < hia[3]) gi3 = 1; }
void ci_l_NX(int c) { if (!gi < hia[c]) gi3 = 1; }
void ci_l_NN(int c) { if (!gi < !hi) gi3 = 1; }
void ci_l_NU(int c) { if (!gi < -hi) gi3 = 1; }
void ci_l_NB(int c) { if (!gi < (hi - hj)) gi3 = 1; }
void ci_l_NC(int c) { if (!gi < (256 - hi)) gi3 = 1; }
void ci_l_NT(int c) { if (!gi < (hc ? hi : hj)) gi3 = 1; }
void ci_l_NS(int c) { if (!gi < (hi << c)) gi3 = 1; }
void ci_l_ND(int c) { if (!gi < hps->i) gi3 = 1; }
void ci_l_UK(int c) { if (-gi < 7) gi3 = 1; }
void ci_l_UG(int c) { if (-gi < hi) gi3 = 1; }
void ci_l_UM(int c) { if (-gi < hs.i) gi3 = 1; }
void ci_l_UP(int c) { if (-gi < *hpi) gi3 = 1; }
void ci_l_UE(int c) { if (-gi < hia[3]) gi3 = 1; }
void ci_l_UX(int c) { if (-gi < hia[c]) gi3 = 1; }
void ci_l_UN(int c) { if (-gi < !hi) gi3 = 1; }
void ci_l_UU(int c) { if (-gi < -hi) gi3 = 1; }
void ci_l_UB(int c) { if (-gi < (hi - hj)) gi3 = 1; }
void ci_l_UC(int c) { if (-gi < (256 - hi)) gi3 = 1; }
void ci_l_UT(int c) { if (-gi < (hc ? hi : hj)) gi3 = 1; }
void ci_l_US(int c) { if (-gi < (hi << c)) gi3 = 1; }
void ci_l_UD(int c) { if (-gi < hps->i) gi3 = 1; }
void ci_l_BK(int c) { if ((gi - gj) < 7) gi3 = 1; }
void ci_l_BG(int c) { if ((gi - gj) < hi) gi3 = 1; }
void ci_l_BM(int c) { if ((gi - gj) < hs.i) gi3 = 1; }
void ci_l_BP(int c) { if ((gi - gj) < *hpi) gi3 = 1; }
void ci_l_BE(int c) { if ((gi - gj) < hia[3]) gi3 = 1; }
void ci_l_BX(int c) { if ((gi - gj) < hia[c]) gi3 = 1; }
void ci_l_BN(int c) { if ((gi - gj) < !hi) gi3 = 1; }
void ci_l_BU(int c) { if ((gi - gj) < -hi) gi3 = 1; }
void ci_l_BB(int c) { if ((gi - gj) < (hi - hj)) gi3 = 1; }
void ci_l_BC(int c) { if ((gi - gj) < (256 - hi)) gi3 = 1; }
void ci_l_BT(int c) { if ((gi - gj) < (hc ? hi : hj)) gi3 = 1; }
void ci_l_BS(int c) { if ((gi - gj) < (hi << c)) gi3 = 1; }
void ci_l_BD(int c) { if ((gi - gj) < hps->i) gi3 = 1; }
void ci_l_CK(int c) { if ((256 - gi) < 7) gi3 = 1; }
void ci_l_CG(int c) { if ((256 - gi) < hi) gi3 = 1; }
void ci_l_CM(int c) { if ((256 - gi) < hs.i) gi3 = 1; }
void ci_l_CP(int c) { if ((256 - gi) < *hpi) gi3 = 1; }
void ci_l_CE(int c) { if ((256 - gi) < hia[3]) gi3 = 1; }
void ci_l_CX(int c) { if ((256 - gi) < hia[c]) gi3 = 1; }
void ci_l_CN(int c) { if ((256 - gi) < !hi) gi3 = 1; }
void ci_l_CU(int c) { if ((256 - gi) < -hi) gi3 = 1; }
void ci_l_CB(int c) { if ((256 - gi) < (hi - hj)) gi3 = 1; }
void ci_l_CC(int c) { if ((256 - gi) < (256 - hi)) gi3 = 1; }
void ci_l_CT(int c) { if ((256 - gi) < (hc ? hi : hj)) gi3 = 1; }
void ci_l_CS(int c) { if ((256 - gi) < (hi << c)) gi3 = 1; }
void ci_l_CD(int c) { if ((256 - gi) < hps->i) gi3 = 1; }
void ci_l_TK(int c) { if ((gc ? gi : gj) < 7) gi3 = 1; }
void ci_l_TG(int c) { if ((gc ? gi : gj) < hi) gi3 = 1; }
void ci_l_TM(int c) { if ((gc ? gi : gj) < hs.i) gi3 = 1; }
void ci_l_TP(int c) { if ((gc ? gi : gj) < *hpi) gi3 = 1; }
void ci_l_TE(int c) { if ((gc ? gi : gj) < hia[3]) gi3 = 1; }
void ci_l_TX(int c) { if ((gc ? gi : gj) < hia[c]) gi3 = 1; }
void ci_l_TN(int c) { if ((gc ? gi : gj) < !hi) gi3 = 1; }
void ci_l_TU(int c) { if ((gc ? gi : gj) < -hi) gi3 = 1; }
void ci_l_TB(int c) { if ((gc ? gi : gj) < (hi - hj)) gi3 = 1; }
void ci_l_TC(int c) { if ((gc ? gi : gj) < (256 - hi)) gi3 = 1; }
void ci_l_TT(int c) { if ((gc ? gi : gj) < (hc ? hi : hj)) gi3 = 1; }
void ci_l_TS(int c) { if ((gc ? gi : gj) < (hi << c)) gi3 = 1; }
void ci_l_TD(int c) { if ((gc ? gi : gj) < hps->i) gi3 = 1; }
void ci_l_SK(int c) { if ((gi << c) < 7) gi3 = 1; }
void ci_l_SG(int c) { if ((gi << c) < hi) gi3 = 1; }
void ci_l_SM(int c) { if ((gi << c) < hs.i) gi3 = 1; }
void ci_l_SP(int c) { if ((gi << c) < *hpi) gi3 = 1; }
void ci_l_SE(int c) { if ((gi << c) < hia[3]) gi3 = 1; }
void ci_l_SX(int c) { if ((gi << c) < hia[c]) gi3 = 1; }
void ci_l_SN(int c) { if ((gi << c) < !hi) gi3 = 1; }
void ci_l_SU(int c) { if ((gi << c) < -hi) gi3 = 1; }
void ci_l_SB(int c) { if ((gi << c) < (hi - hj)) gi3 = 1; }
void ci_l_SC(int c) { if ((gi << c) < (256 - hi)) gi3 = 1; }
void ci_l_ST(int c) { if ((gi << c) < (hc ? hi : hj)) gi3 = 1; }
void ci_l_SS(int c) { if ((gi << c) < (hi << c)) gi3 = 1; }
void ci_l_SD(int c) { if ((gi << c) < hps->i) gi3 = 1; }
void ci_l_DK(int c) { if (gps->i < 7) gi3 = 1; }
void ci_l_DG(int c) { if (gps->i < hi) gi3 = 1; }
void ci_l_DM(int c) { if (gps->i < hs.i) gi3 = 1; }
void ci_l_DP(int c) { if (gps->i < *hpi) gi3 = 1; }
void ci_l_DE(int c) { if (gps->i < hia[3]) gi3 = 1; }
void ci_l_DX(int c) { if (gps->i < hia[c]) gi3 = 1; }
void ci_l_DN(int c) { if (gps->i < !hi) gi3 = 1; }
void ci_l_DU(int c) { if (gps->i < -hi) gi3 = 1; }
void ci_l_DB(int c) { if (gps->i < (hi - hj)) gi3 = 1; }
void ci_l_DC(int c) { if (gps->i < (256 - hi)) gi3 = 1; }
void ci_l_DT(int c) { if (gps->i < (hc ? hi : hj)) gi3 = 1; }
void ci_l_DS(int c) { if (gps->i < (hi << c)) gi3 = 1; }
void ci_l_DD(int c) { if (gps->i < hps->i) gi3 = 1; }

void ci_e_KK(int c) { if (7 == 7) gi3 = 1; }
void ci_e_KG(int c) { if (7 == hi) gi3 = 1; }
void ci_e_KM(int c) { if (7 == hs.i) gi3 = 1; }
void ci_e_KP(int c) { if (7 == *hpi) gi3 = 1; }
void ci_e_KE(int c) { if (7 == hia[3]) gi3 = 1; }
void ci_e_KX(int c) { if (7 == hia[c]) gi3 = 1; }
void ci_e_KN(int c) { if (7 == !hi) gi3 = 1; }
void ci_e_KU(int c) { if (7 == -hi) gi3 = 1; }
void ci_e_KB(int c) { if (7 == (hi - hj)) gi3 = 1; }
void ci_e_KC(int c) { if (7 == (256 - hi)) gi3 = 1; }
void ci_e_KT(int c) { if (7 == (hc ? hi : hj)) gi3 = 1; }
void ci_e_KS(int c) { if (7 == (hi << c)) gi3 = 1; }
void ci_e_KD(int c) { if (7 == hps->i) gi3 = 1; }
void ci_e_GK(int c) { if (gi == 7) gi3 = 1; }
void ci_e_GG(int c) { if (gi == hi) gi3 = 1; }
void ci_e_GM(int c) { if (gi == hs.i) gi3 = 1; }
void ci_e_GP(int c) { if (gi == *hpi) gi3 = 1; }
void ci_e_GE(int c) { if (gi == hia[3]) gi3 = 1; }
void ci_e_GX(int c) { if (gi == hia[c]) gi3 = 1; }
void ci_e_GN(int c) { if (gi == !hi) gi3 = 1; }
void ci_e_GU(int c) { if (gi == -hi) gi3 = 1; }
void ci_e_GB(int c) { if (gi == (hi - hj)) gi3 = 1; }
void ci_e_GC(int c) { if (gi == (256 - hi)) gi3 = 1; }
void ci_e_GT(int c) { if (gi == (hc ? hi : hj)) gi3 = 1; }
void ci_e_GS(int c) { if (gi == (hi << c)) gi3 = 1; }
void ci_e_GD(int c) { if (gi == hps->i) gi3 = 1; }
void ci_e_MK(int c) { if (gs.i == 7) gi3 = 1; }
void ci_e_MG(int c) { if (gs.i == hi) gi3 = 1; }
void ci_e_MM(int c) { if (gs.i == hs.i) gi3 = 1; }
void ci_e_MP(int c) { if (gs.i == *hpi) gi3 = 1; }
void ci_e_ME(int c) { if (gs.i == hia[3]) gi3 = 1; }
void ci_e_MX(int c) { if (gs.i == hia[c]) gi3 = 1; }
void ci_e_MN(int c) { if (gs.i == !hi) gi3 = 1; }
void ci_e_MU(int c) { if (gs.i == -hi) gi3 = 1; }
void ci_e_MB(int c) { if (gs.i == (hi - hj)) gi3 = 1; }
void ci_e_MC(int c) { if (gs.i == (256 - hi)) gi3 = 1; }
void ci_e_MT(int c) { if (gs.i == (hc ? hi : hj)) gi3 = 1; }
void ci_e_MS(int c) { if (gs.i == (hi << c)) gi3 = 1; }
void ci_e_MD(int c) { if (gs.i == hps->i) gi3 = 1; }
void ci_e_PK(int c) { if (*gpi == 7) gi3 = 1; }
void ci_e_PG(int c) { if (*gpi == hi) gi3 = 1; }
void ci_e_PM(int c) { if (*gpi == hs.i) gi3 = 1; }
void ci_e_PP(int c) { if (*gpi == *hpi) gi3 = 1; }
void ci_e_PE(int c) { if (*gpi == hia[3]) gi3 = 1; }
void ci_e_PX(int c) { if (*gpi == hia[c]) gi3 = 1; }
void ci_e_PN(int c) { if (*gpi == !hi) gi3 = 1; }
void ci_e_PU(int c) { if (*gpi == -hi) gi3 = 1; }
void ci_e_PB(int c) { if (*gpi == (hi - hj)) gi3 = 1; }
void ci_e_PC(int c) { if (*gpi == (256 - hi)) gi3 = 1; }
void ci_e_PT(int c) { if (*gpi == (hc ? hi : hj)) gi3 = 1; }
void ci_e_PS(int c) { if (*gpi == (hi << c)) gi3 = 1; }
void ci_e_PD(int c) { if (*gpi == hps->i) gi3 = 1; }
void ci_e_EK(int c) { if (gia[3] == 7) gi3 = 1; }
void ci_e_EG(int c) { if (gia[3] == hi) gi3 = 1; }
void ci_e_EM(int c) { if (gia[3] == hs.i) gi3 = 1; }
void ci_e_EP(int c) { if (gia[3] == *hpi) gi3 = 1; }
void ci_e_EE(int c) { if (gia[3] == hia[3]) gi3 = 1; }
void ci_e_EX(int c) { if (gia[3] == hia[c]) gi3 = 1; }
void ci_e_EN(int c) { if (gia[3] == !hi) gi3 = 1; }
void ci_e_EU(int c) { if (gia[3] == -hi) gi3 = 1; }
void ci_e_EB(int c) { if (gia[3] == (hi - hj)) gi3 = 1; }
void ci_e_EC(int c) { if (gia[3] == (256 - hi)) gi3 = 1; }
void ci_e_ET(int c) { if (gia[3] == (hc ? hi : hj)) gi3 = 1; }
void ci_e_ES(int c) { if (gia[3] == (hi << c)) gi3 = 1; }
void ci_e_ED(int c) { if (gia[3] == hps->i) gi3 = 1; }
void ci_e_XK(int c) { if (gia[c] == 7) gi3 = 1; }
void ci_e_XG(int c) { if (gia[c] == hi) gi3 = 1; }
void ci_e_XM(int c) { if (gia[c] == hs.i) gi3 = 1; }
void ci_e_XP(int c) { if (gia[c] == *hpi) gi3 = 1; }
void ci_e_XE(int c) { if (gia[c] == hia[3]) gi3 = 1; }
void ci_e_XX(int c) { if (gia[c] == hia[c]) gi3 = 1; }
void ci_e_XN(int c) { if (gia[c] == !hi) gi3 = 1; }
void ci_e_XU(int c) { if (gia[c] == -hi) gi3 = 1; }
void ci_e_XB(int c) { if (gia[c] == (hi - hj)) gi3 = 1; }
void ci_e_XC(int c) { if (gia[c] == (256 - hi)) gi3 = 1; }
void ci_e_XT(int c) { if (gia[c] == (hc ? hi : hj)) gi3 = 1; }
void ci_e_XS(int c) { if (gia[c] == (hi << c)) gi3 = 1; }
void ci_e_XD(int c) { if (gia[c] == hps->i) gi3 = 1; }
void ci_e_NK(int c) { if (!gi == 7) gi3 = 1; }
void ci_e_NG(int c) { if (!gi == hi) gi3 = 1; }
void ci_e_NM(int c) { if (!gi == hs.i) gi3 = 1; }
void ci_e_NP(int c) { if (!gi == *hpi) gi3 = 1; }
void ci_e_NE(int c) { if (!gi == hia[3]) gi3 = 1; }
void ci_e_NX(int c) { if (!gi == hia[c]) gi3 = 1; }
void ci_e_NN(int c) { if (!gi == !hi) gi3 = 1; }
void ci_e_NU(int c) { if (!gi == -hi) gi3 = 1; }
void ci_e_NB(int c) { if (!gi == (hi - hj)) gi3 = 1; }
void ci_e_NC(int c) { if (!gi == (256 - hi)) gi3 = 1; }
void ci_e_NT(int c) { if (!gi == (hc ? hi : hj)) gi3 = 1; }
void ci_e_NS(int c) { if (!gi == (hi << c)) gi3 = 1; }
void ci_e_ND(int c) { if (!gi == hps->i) gi3 = 1; }
void ci_e_UK(int c) { if (-gi == 7) gi3 = 1; }
void ci_e_UG(int c) { if (-gi == hi) gi3 = 1; }
void ci_e_UM(int c) { if (-gi == hs.i) gi3 = 1; }
void ci_e_UP(int c) { if (-gi == *hpi) gi3 = 1; }
void ci_e_UE(int c) { if (-gi == hia[3]) gi3 = 1; }
void ci_e_UX(int c) { if (-gi == hia[c]) gi3 = 1; }
void ci_e_UN(int c) { if (-gi == !hi) gi3 = 1; }
void ci_e_UU(int c) { if (-gi == -hi) gi3 = 1; }
void ci_e_UB(int c) { if (-gi == (hi - hj)) gi3 = 1; }
void ci_e_UC(int c) { if (-gi == (256 - hi)) gi3 = 1; }
void ci_e_UT(int c) { if (-gi == (hc ? hi : hj)) gi3 = 1; }
void ci_e_US(int c) { if (-gi == (hi << c)) gi3 = 1; }
void ci_e_UD(int c) { if (-gi == hps->i) gi3 = 1; }
void ci_e_BK(int c) { if ((gi - gj) == 7) gi3 = 1; }
void ci_e_BG(int c) { if ((gi - gj) == hi) gi3 = 1; }
void ci_e_BM(int c) { if ((gi - gj) == hs.i) gi3 = 1; }
void ci_e_BP(int c) { if ((gi - gj) == *hpi) gi3 = 1; }
void ci_e_BE(int c) { if ((gi - gj) == hia[3]) gi3 = 1; }
void ci_e_BX(int c) { if ((gi - gj) == hia[c]) gi3 = 1; }
void ci_e_BN(int c) { if ((gi - gj) == !hi) gi3 = 1; }
void ci_e_BU(int c) { if ((gi - gj) == -hi) gi3 = 1; }
void ci_e_BB(int c) { if ((gi - gj) == (hi - hj)) gi3 = 1; }
void ci_e_BC(int c) { if ((gi - gj) == (256 - hi)) gi3 = 1; }
void ci_e_BT(int c) { if ((gi - gj) == (hc ? hi : hj)) gi3 = 1; }
void ci_e_BS(int c) { if ((gi - gj) == (hi << c)) gi3 = 1; }
void ci_e_BD(int c) { if ((gi - gj) == hps->i) gi3 = 1; }
void ci_e_CK(int c) { if ((256 - gi) == 7) gi3 = 1; }
void ci_e_CG(int c) { if ((256 - gi) == hi) gi3 = 1; }
void ci_e_CM(int c) { if ((256 - gi) == hs.i) gi3 = 1; }
void ci_e_CP(int c) { if ((256 - gi) == *hpi) gi3 = 1; }
void ci_e_CE(int c) { if ((256 - gi) == hia[3]) gi3 = 1; }
void ci_e_CX(int c) { if ((256 - gi) == hia[c]) gi3 = 1; }
void ci_e_CN(int c) { if ((256 - gi) == !hi) gi3 = 1; }
void ci_e_CU(int c) { if ((256 - gi) == -hi) gi3 = 1; }
void ci_e_CB(int c) { if ((256 - gi) == (hi - hj)) gi3 = 1; }
void ci_e_CC(int c) { if ((256 - gi) == (256 - hi)) gi3 = 1; }
void ci_e_CT(int c) { if ((256 - gi) == (hc ? hi : hj)) gi3 = 1; }
void ci_e_CS(int c) { if ((256 - gi) == (hi << c)) gi3 = 1; }
void ci_e_CD(int c) { if ((256 - gi) == hps->i) gi3 = 1; }
void ci_e_TK(int c) { if ((gc ? gi : gj) == 7) gi3 = 1; }
void ci_e_TG(int c) { if ((gc ? gi : gj) == hi) gi3 = 1; }
void ci_e_TM(int c) { if ((gc ? gi : gj) == hs.i) gi3 = 1; }
void ci_e_TP(int c) { if ((gc ? gi : gj) == *hpi) gi3 = 1; }
void ci_e_TE(int c) { if ((gc ? gi : gj) == hia[3]) gi3 = 1; }
void ci_e_TX(int c) { if ((gc ? gi : gj) == hia[c]) gi3 = 1; }
void ci_e_TN(int c) { if ((gc ? gi : gj) == !hi) gi3 = 1; }
void ci_e_TU(int c) { if ((gc ? gi : gj) == -hi) gi3 = 1; }
void ci_e_TB(int c) { if ((gc ? gi : gj) == (hi - hj)) gi3 = 1; }
void ci_e_TC(int c) { if ((gc ? gi : gj) == (256 - hi)) gi3 = 1; }
void ci_e_TT(int c) { if ((gc ? gi : gj) == (hc ? hi : hj)) gi3 = 1; }
void ci_e_TS(int c) { if ((gc ? gi : gj) == (hi << c)) gi3 = 1; }
void ci_e_TD(int c) { if ((gc ? gi : gj) == hps->i) gi3 = 1; }
void ci_e_SK(int c) { if ((gi << c) == 7) gi3 = 1; }
void ci_e_SG(int c) { if ((gi << c) == hi) gi3 = 1; }
void ci_e_SM(int c) { if ((gi << c) == hs.i) gi3 = 1; }
void ci_e_SP(int c) { if ((gi << c) == *hpi) gi3 = 1; }
void ci_e_SE(int c) { if ((gi << c) == hia[3]) gi3 = 1; }
void ci_e_SX(int c) { if ((gi << c) == hia[c]) gi3 = 1; }
void ci_e_SN(int c) { if ((gi << c) == !hi) gi3 = 1; }
void ci_e_SU(int c) { if ((gi << c) == -hi) gi3 = 1; }
void ci_e_SB(int c) { if ((gi << c) == (hi - hj)) gi3 = 1; }
void ci_e_SC(int c) { if ((gi << c) == (256 - hi)) gi3 = 1; }
void ci_e_ST(int c) { if ((gi << c) == (hc ? hi : hj)) gi3 = 1; }
void ci_e_SS(int c) { if ((gi << c) == (hi << c)) gi3 = 1; }
void ci_e_SD(int c) { if ((gi << c) == hps->i) gi3 = 1; }
void ci_e_DK(int c) { if (gps->i == 7) gi3 = 1; }
void ci_e_DG(int c) { if (gps->i == hi) gi3 = 1; }
void ci_e_DM(int c) { if (gps->i == hs.i) gi3 = 1; }
void ci_e_DP(int c) { if (gps->i == *hpi) gi3 = 1; }
void ci_e_DE(int c) { if (gps->i == hia[3]) gi3 = 1; }
void ci_e_DX(int c) { if (gps->i == hia[c]) gi3 = 1; }
void ci_e_DN(int c) { if (gps->i == !hi) gi3 = 1; }
void ci_e_DU(int c) { if (gps->i == -hi) gi3 = 1; }
void ci_e_DB(int c) { if (gps->i == (hi - hj)) gi3 = 1; }
void ci_e_DC(int c) { if (gps->i == (256 - hi)) gi3 = 1; }
void ci_e_DT(int c) { if (gps->i == (hc ? hi : hj)) gi3 = 1; }
void ci_e_DS(int c) { if (gps->i == (hi << c)) gi3 = 1; }
void ci_e_DD(int c) { if (gps->i == hps->i) gi3 = 1; }

int cv_l_KK(int c) { return 7 < 7; }
int cv_l_KG(int c) { return 7 < hi; }
int cv_l_KM(int c) { return 7 < hs.i; }
int cv_l_KP(int c) { return 7 < *hpi; }
int cv_l_KE(int c) { return 7 < hia[3]; }
int cv_l_KX(int c) { return 7 < hia[c]; }
int cv_l_KN(int c) { return 7 < !hi; }
int cv_l_KU(int c) { return 7 < -hi; }
int cv_l_KB(int c) { return 7 < (hi - hj); }
int cv_l_KC(int c) { return 7 < (256 - hi); }
int cv_l_KT(int c) { return 7 < (hc ? hi : hj); }
int cv_l_KS(int c) { return 7 < (hi << c); }
int cv_l_KD(int c) { return 7 < hps->i; }
int cv_l_GK(int c) { return gi < 7; }
int cv_l_GG(int c) { return gi < hi; }
int cv_l_GM(int c) { return gi < hs.i; }
int cv_l_GP(int c) { return gi < *hpi; }
int cv_l_GE(int c) { return gi < hia[3]; }
int cv_l_GX(int c) { return gi < hia[c]; }
int cv_l_GN(int c) { return gi < !hi; }
int cv_l_GU(int c) { return gi < -hi; }
int cv_l_GB(int c) { return gi < (hi - hj); }
int cv_l_GC(int c) { return gi < (256 - hi); }
int cv_l_GT(int c) { return gi < (hc ? hi : hj); }
int cv_l_GS(int c) { return gi < (hi << c); }
int cv_l_GD(int c) { return gi < hps->i; }
int cv_l_MK(int c) { return gs.i < 7; }
int cv_l_MG(int c) { return gs.i < hi; }
int cv_l_MM(int c) { return gs.i < hs.i; }
int cv_l_MP(int c) { return gs.i < *hpi; }
int cv_l_ME(int c) { return gs.i < hia[3]; }
int cv_l_MX(int c) { return gs.i < hia[c]; }
int cv_l_MN(int c) { return gs.i < !hi; }
int cv_l_MU(int c) { return gs.i < -hi; }
int cv_l_MB(int c) { return gs.i < (hi - hj); }
int cv_l_MC(int c) { return gs.i < (256 - hi); }
int cv_l_MT(int c) { return gs.i < (hc ? hi : hj); }
int cv_l_MS(int c) { return gs.i < (hi << c); }
int cv_l_MD(int c) { return gs.i < hps->i; }
int cv_l_PK(int c) { return *gpi < 7; }
int cv_l_PG(int c) { return *gpi < hi; }
int cv_l_PM(int c) { return *gpi < hs.i; }
int cv_l_PP(int c) { return *gpi < *hpi; }
int cv_l_PE(int c) { return *gpi < hia[3]; }
int cv_l_PX(int c) { return *gpi < hia[c]; }
int cv_l_PN(int c) { return *gpi < !hi; }
int cv_l_PU(int c) { return *gpi < -hi; }
int cv_l_PB(int c) { return *gpi < (hi - hj); }
int cv_l_PC(int c) { return *gpi < (256 - hi); }
int cv_l_PT(int c) { return *gpi < (hc ? hi : hj); }
int cv_l_PS(int c) { return *gpi < (hi << c); }
int cv_l_PD(int c) { return *gpi < hps->i; }
int cv_l_EK(int c) { return gia[3] < 7; }
int cv_l_EG(int c) { return gia[3] < hi; }
int cv_l_EM(int c) { return gia[3] < hs.i; }
int cv_l_EP(int c) { return gia[3] < *hpi; }
int cv_l_EE(int c) { return gia[3] < hia[3]; }
int cv_l_EX(int c) { return gia[3] < hia[c]; }
int cv_l_EN(int c) { return gia[3] < !hi; }
int cv_l_EU(int c) { return gia[3] < -hi; }
int cv_l_EB(int c) { return gia[3] < (hi - hj); }
int cv_l_EC(int c) { return gia[3] < (256 - hi); }
int cv_l_ET(int c) { return gia[3] < (hc ? hi : hj); }
int cv_l_ES(int c) { return gia[3] < (hi << c); }
int cv_l_ED(int c) { return gia[3] < hps->i; }
int cv_l_XK(int c) { return gia[c] < 7; }
int cv_l_XG(int c) { return gia[c] < hi; }
int cv_l_XM(int c) { return gia[c] < hs.i; }
int cv_l_XP(int c) { return gia[c] < *hpi; }
int cv_l_XE(int c) { return gia[c] < hia[3]; }
int cv_l_XX(int c) { return gia[c] < hia[c]; }
int cv_l_XN(int c) { return gia[c] < !hi; }
int cv_l_XU(int c) { return gia[c] < -hi; }
int cv_l_XB(int c) { return gia[c] < (hi - hj); }
int cv_l_XC(int c) { return gia[c] < (256 - hi); }
int cv_l_XT(int c) { return gia[c] < (hc ? hi : hj); }
int cv_l_XS(int c) { return gia[c] < (hi << c); }
int cv_l_XD(int c) { return gia[c] < hps->i; }
int cv_l_NK(int c) { return !gi < 7; }
int cv_l_NG(int c) { return !gi < hi; }
int cv_l_NM(int c) { return !gi < hs.i; }
int cv_l_NP(int c) { return !gi < *hpi; }
int cv_l_NE(int c) { return !gi < hia[3]; }
int cv_l_NX(int c) { return !gi < hia[c]; }
int cv_l_NN(int c) { return !gi < !hi; }
int cv_l_NU(int c) { return !gi < -hi; }
int cv_l_NB(int c) { return !gi < (hi - hj); }
int cv_l_NC(int c) { return !gi < (256 - hi); }
int cv_l_NT(int c) { return !gi < (hc ? hi : hj); }
int cv_l_NS(int c) { return !gi < (hi << c); }
int cv_l_ND(int c) { return !gi < hps->i; }
int cv_l_UK(int c) { return -gi < 7; }
int cv_l_UG(int c) { return -gi < hi; }
int cv_l_UM(int c) { return -gi < hs.i; }
int cv_l_UP(int c) { return -gi < *hpi; }
int cv_l_UE(int c) { return -gi < hia[3]; }
int cv_l_UX(int c) { return -gi < hia[c]; }
int cv_l_UN(int c) { return -gi < !hi; }
int cv_l_UU(int c) { return -gi < -hi; }
int cv_l_UB(int c) { return -gi < (hi - hj); }
int cv_l_UC(int c) { return -gi < (256 - hi); }
int cv_l_UT(int c) { return -gi < (hc ? hi : hj); }
int cv_l_US(int c) { return -gi < (hi << c); }
int cv_l_UD(int c) { return -gi < hps->i; }
int cv_l_BK(int c) { return (gi - gj) < 7; }
int cv_l_BG(int c) { return (gi - gj) < hi; }
int cv_l_BM(int c) { return (gi - gj) < hs.i; }
int cv_l_BP(int c) { return (gi - gj) < *hpi; }
int cv_l_BE(int c) { return (gi - gj) < hia[3]; }
int cv_l_BX(int c) { return (gi - gj) < hia[c]; }
int cv_l_BN(int c) { return (gi - gj) < !hi; }
int cv_l_BU(int c) { return (gi - gj) < -hi; }
int cv_l_BB(int c) { return (gi - gj) < (hi - hj); }
int cv_l_BC(int c) { return (gi - gj) < (256 - hi); }
int cv_l_BT(int c) { return (gi - gj) < (hc ? hi : hj); }
int cv_l_BS(int c) { return (gi - gj) < (hi << c); }
int cv_l_BD(int c) { return (gi - gj) < hps->i; }
int cv_l_CK(int c) { return (256 - gi) < 7; }
int cv_l_CG(int c) { return (256 - gi) < hi; }
int cv_l_CM(int c) { return (256 - gi) < hs.i; }
int cv_l_CP(int c) { return (256 - gi) < *hpi; }
int cv_l_CE(int c) { return (256 - gi) < hia[3]; }
int cv_l_CX(int c) { return (256 - gi) < hia[c]; }
int cv_l_CN(int c) { return (256 - gi) < !hi; }
int cv_l_CU(int c) { return (256 - gi) < -hi; }
int cv_l_CB(int c) { return (256 - gi) < (hi - hj); }
int cv_l_CC(int c) { return (256 - gi) < (256 - hi); }
int cv_l_CT(int c) { return (256 - gi) < (hc ? hi : hj); }
int cv_l_CS(int c) { return (256 - gi) < (hi << c); }
int cv_l_CD(int c) { return (256 - gi) < hps->i; }
int cv_l_TK(int c) { return (gc ? gi : gj) < 7; }
int cv_l_TG(int c) { return (gc ? gi : gj) < hi; }
int cv_l_TM(int c) { return (gc ? gi : gj) < hs.i; }
int cv_l_TP(int c) { return (gc ? gi : gj) < *hpi; }
int cv_l_TE(int c) { return (gc ? gi : gj) < hia[3]; }
int cv_l_TX(int c) { return (gc ? gi : gj) < hia[c]; }
int cv_l_TN(int c) { return (gc ? gi : gj) < !hi; }
int cv_l_TU(int c) { return (gc ? gi : gj) < -hi; }
int cv_l_TB(int c) { return (gc ? gi : gj) < (hi - hj); }
int cv_l_TC(int c) { return (gc ? gi : gj) < (256 - hi); }
int cv_l_TT(int c) { return (gc ? gi : gj) < (hc ? hi : hj); }
int cv_l_TS(int c) { return (gc ? gi : gj) < (hi << c); }
int cv_l_TD(int c) { return (gc ? gi : gj) < hps->i; }
int cv_l_SK(int c) { return (gi << c) < 7; }
int cv_l_SG(int c) { return (gi << c) < hi; }
int cv_l_SM(int c) { return (gi << c) < hs.i; }
int cv_l_SP(int c) { return (gi << c) < *hpi; }
int cv_l_SE(int c) { return (gi << c) < hia[3]; }
int cv_l_SX(int c) { return (gi << c) < hia[c]; }
int cv_l_SN(int c) { return (gi << c) < !hi; }
int cv_l_SU(int c) { return (gi << c) < -hi; }
int cv_l_SB(int c) { return (gi << c) < (hi - hj); }
int cv_l_SC(int c) { return (gi << c) < (256 - hi); }
int cv_l_ST(int c) { return (gi << c) < (hc ? hi : hj); }
int cv_l_SS(int c) { return (gi << c) < (hi << c); }
int cv_l_SD(int c) { return (gi << c) < hps->i; }
int cv_l_DK(int c) { return gps->i < 7; }
int cv_l_DG(int c) { return gps->i < hi; }
int cv_l_DM(int c) { return gps->i < hs.i; }
int cv_l_DP(int c) { return gps->i < *hpi; }
int cv_l_DE(int c) { return gps->i < hia[3]; }
int cv_l_DX(int c) { return gps->i < hia[c]; }
int cv_l_DN(int c) { return gps->i < !hi; }
int cv_l_DU(int c) { return gps->i < -hi; }
int cv_l_DB(int c) { return gps->i < (hi - hj); }
int cv_l_DC(int c) { return gps->i < (256 - hi); }
int cv_l_DT(int c) { return gps->i < (hc ? hi : hj); }
int cv_l_DS(int c) { return gps->i < (hi << c); }
int cv_l_DD(int c) { return gps->i < hps->i; }
