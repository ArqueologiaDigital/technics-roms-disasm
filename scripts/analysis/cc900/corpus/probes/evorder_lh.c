/* Long helper operands (gen_evorder_lh.py): the long kinds of evorder_l.c on both sides of * / and %, which call
   C9H_mulls, C9H_divls and C9H_remls (eh_<op>_<L><R>(c): return L op R).  The left side reads g* globals, the
   right h*, so a listing shows which argument was computed first and where each landed. */
struct st { int i; int a[4]; long l; };
extern int gi, gj, gc, hi, hj, hc; extern long gl, gm, hl, hm; extern long gla[10], hla[10]; extern long *gpl, *hpl;
extern struct st gs, *gps, hs, *hps;

long eh_m_KK(int c) { return 7L * 7L; }
long eh_m_KG(int c) { return 7L * hl; }
long eh_m_KM(int c) { return 7L * hs.l; }
long eh_m_KP(int c) { return 7L * *hpl; }
long eh_m_KE(int c) { return 7L * hla[3]; }
long eh_m_KX(int c) { return 7L * hla[c]; }
long eh_m_KN(int c) { return 7L * !hl; }
long eh_m_KU(int c) { return 7L * -hl; }
long eh_m_KB(int c) { return 7L * (hl - hm); }
long eh_m_KC(int c) { return 7L * (256L - hl); }
long eh_m_KT(int c) { return 7L * (hc ? hl : hm); }
long eh_m_KS(int c) { return 7L * (hl << c); }
long eh_m_KD(int c) { return 7L * hps->l; }
long eh_m_GK(int c) { return gl * 7L; }
long eh_m_GG(int c) { return gl * hl; }
long eh_m_GM(int c) { return gl * hs.l; }
long eh_m_GP(int c) { return gl * *hpl; }
long eh_m_GE(int c) { return gl * hla[3]; }
long eh_m_GX(int c) { return gl * hla[c]; }
long eh_m_GN(int c) { return gl * !hl; }
long eh_m_GU(int c) { return gl * -hl; }
long eh_m_GB(int c) { return gl * (hl - hm); }
long eh_m_GC(int c) { return gl * (256L - hl); }
long eh_m_GT(int c) { return gl * (hc ? hl : hm); }
long eh_m_GS(int c) { return gl * (hl << c); }
long eh_m_GD(int c) { return gl * hps->l; }
long eh_m_MK(int c) { return gs.l * 7L; }
long eh_m_MG(int c) { return gs.l * hl; }
long eh_m_MM(int c) { return gs.l * hs.l; }
long eh_m_MP(int c) { return gs.l * *hpl; }
long eh_m_ME(int c) { return gs.l * hla[3]; }
long eh_m_MX(int c) { return gs.l * hla[c]; }
long eh_m_MN(int c) { return gs.l * !hl; }
long eh_m_MU(int c) { return gs.l * -hl; }
long eh_m_MB(int c) { return gs.l * (hl - hm); }
long eh_m_MC(int c) { return gs.l * (256L - hl); }
long eh_m_MT(int c) { return gs.l * (hc ? hl : hm); }
long eh_m_MS(int c) { return gs.l * (hl << c); }
long eh_m_MD(int c) { return gs.l * hps->l; }
long eh_m_PK(int c) { return *gpl * 7L; }
long eh_m_PG(int c) { return *gpl * hl; }
long eh_m_PM(int c) { return *gpl * hs.l; }
long eh_m_PP(int c) { return *gpl * *hpl; }
long eh_m_PE(int c) { return *gpl * hla[3]; }
long eh_m_PX(int c) { return *gpl * hla[c]; }
long eh_m_PN(int c) { return *gpl * !hl; }
long eh_m_PU(int c) { return *gpl * -hl; }
long eh_m_PB(int c) { return *gpl * (hl - hm); }
long eh_m_PC(int c) { return *gpl * (256L - hl); }
long eh_m_PT(int c) { return *gpl * (hc ? hl : hm); }
long eh_m_PS(int c) { return *gpl * (hl << c); }
long eh_m_PD(int c) { return *gpl * hps->l; }
long eh_m_EK(int c) { return gla[3] * 7L; }
long eh_m_EG(int c) { return gla[3] * hl; }
long eh_m_EM(int c) { return gla[3] * hs.l; }
long eh_m_EP(int c) { return gla[3] * *hpl; }
long eh_m_EE(int c) { return gla[3] * hla[3]; }
long eh_m_EX(int c) { return gla[3] * hla[c]; }
long eh_m_EN(int c) { return gla[3] * !hl; }
long eh_m_EU(int c) { return gla[3] * -hl; }
long eh_m_EB(int c) { return gla[3] * (hl - hm); }
long eh_m_EC(int c) { return gla[3] * (256L - hl); }
long eh_m_ET(int c) { return gla[3] * (hc ? hl : hm); }
long eh_m_ES(int c) { return gla[3] * (hl << c); }
long eh_m_ED(int c) { return gla[3] * hps->l; }
long eh_m_XK(int c) { return gla[c] * 7L; }
long eh_m_XG(int c) { return gla[c] * hl; }
long eh_m_XM(int c) { return gla[c] * hs.l; }
long eh_m_XP(int c) { return gla[c] * *hpl; }
long eh_m_XE(int c) { return gla[c] * hla[3]; }
long eh_m_XX(int c) { return gla[c] * hla[c]; }
long eh_m_XN(int c) { return gla[c] * !hl; }
long eh_m_XU(int c) { return gla[c] * -hl; }
long eh_m_XB(int c) { return gla[c] * (hl - hm); }
long eh_m_XC(int c) { return gla[c] * (256L - hl); }
long eh_m_XT(int c) { return gla[c] * (hc ? hl : hm); }
long eh_m_XS(int c) { return gla[c] * (hl << c); }
long eh_m_XD(int c) { return gla[c] * hps->l; }
long eh_m_NK(int c) { return !gl * 7L; }
long eh_m_NG(int c) { return !gl * hl; }
long eh_m_NM(int c) { return !gl * hs.l; }
long eh_m_NP(int c) { return !gl * *hpl; }
long eh_m_NE(int c) { return !gl * hla[3]; }
long eh_m_NX(int c) { return !gl * hla[c]; }
long eh_m_NN(int c) { return !gl * !hl; }
long eh_m_NU(int c) { return !gl * -hl; }
long eh_m_NB(int c) { return !gl * (hl - hm); }
long eh_m_NC(int c) { return !gl * (256L - hl); }
long eh_m_NT(int c) { return !gl * (hc ? hl : hm); }
long eh_m_NS(int c) { return !gl * (hl << c); }
long eh_m_ND(int c) { return !gl * hps->l; }
long eh_m_UK(int c) { return -gl * 7L; }
long eh_m_UG(int c) { return -gl * hl; }
long eh_m_UM(int c) { return -gl * hs.l; }
long eh_m_UP(int c) { return -gl * *hpl; }
long eh_m_UE(int c) { return -gl * hla[3]; }
long eh_m_UX(int c) { return -gl * hla[c]; }
long eh_m_UN(int c) { return -gl * !hl; }
long eh_m_UU(int c) { return -gl * -hl; }
long eh_m_UB(int c) { return -gl * (hl - hm); }
long eh_m_UC(int c) { return -gl * (256L - hl); }
long eh_m_UT(int c) { return -gl * (hc ? hl : hm); }
long eh_m_US(int c) { return -gl * (hl << c); }
long eh_m_UD(int c) { return -gl * hps->l; }
long eh_m_BK(int c) { return (gl - gm) * 7L; }
long eh_m_BG(int c) { return (gl - gm) * hl; }
long eh_m_BM(int c) { return (gl - gm) * hs.l; }
long eh_m_BP(int c) { return (gl - gm) * *hpl; }
long eh_m_BE(int c) { return (gl - gm) * hla[3]; }
long eh_m_BX(int c) { return (gl - gm) * hla[c]; }
long eh_m_BN(int c) { return (gl - gm) * !hl; }
long eh_m_BU(int c) { return (gl - gm) * -hl; }
long eh_m_BB(int c) { return (gl - gm) * (hl - hm); }
long eh_m_BC(int c) { return (gl - gm) * (256L - hl); }
long eh_m_BT(int c) { return (gl - gm) * (hc ? hl : hm); }
long eh_m_BS(int c) { return (gl - gm) * (hl << c); }
long eh_m_BD(int c) { return (gl - gm) * hps->l; }
long eh_m_CK(int c) { return (256L - gl) * 7L; }
long eh_m_CG(int c) { return (256L - gl) * hl; }
long eh_m_CM(int c) { return (256L - gl) * hs.l; }
long eh_m_CP(int c) { return (256L - gl) * *hpl; }
long eh_m_CE(int c) { return (256L - gl) * hla[3]; }
long eh_m_CX(int c) { return (256L - gl) * hla[c]; }
long eh_m_CN(int c) { return (256L - gl) * !hl; }
long eh_m_CU(int c) { return (256L - gl) * -hl; }
long eh_m_CB(int c) { return (256L - gl) * (hl - hm); }
long eh_m_CC(int c) { return (256L - gl) * (256L - hl); }
long eh_m_CT(int c) { return (256L - gl) * (hc ? hl : hm); }
long eh_m_CS(int c) { return (256L - gl) * (hl << c); }
long eh_m_CD(int c) { return (256L - gl) * hps->l; }
long eh_m_TK(int c) { return (gc ? gl : gm) * 7L; }
long eh_m_TG(int c) { return (gc ? gl : gm) * hl; }
long eh_m_TM(int c) { return (gc ? gl : gm) * hs.l; }
long eh_m_TP(int c) { return (gc ? gl : gm) * *hpl; }
long eh_m_TE(int c) { return (gc ? gl : gm) * hla[3]; }
long eh_m_TX(int c) { return (gc ? gl : gm) * hla[c]; }
long eh_m_TN(int c) { return (gc ? gl : gm) * !hl; }
long eh_m_TU(int c) { return (gc ? gl : gm) * -hl; }
long eh_m_TB(int c) { return (gc ? gl : gm) * (hl - hm); }
long eh_m_TC(int c) { return (gc ? gl : gm) * (256L - hl); }
long eh_m_TT(int c) { return (gc ? gl : gm) * (hc ? hl : hm); }
long eh_m_TS(int c) { return (gc ? gl : gm) * (hl << c); }
long eh_m_TD(int c) { return (gc ? gl : gm) * hps->l; }
long eh_m_SK(int c) { return (gl << c) * 7L; }
long eh_m_SG(int c) { return (gl << c) * hl; }
long eh_m_SM(int c) { return (gl << c) * hs.l; }
long eh_m_SP(int c) { return (gl << c) * *hpl; }
long eh_m_SE(int c) { return (gl << c) * hla[3]; }
long eh_m_SX(int c) { return (gl << c) * hla[c]; }
long eh_m_SN(int c) { return (gl << c) * !hl; }
long eh_m_SU(int c) { return (gl << c) * -hl; }
long eh_m_SB(int c) { return (gl << c) * (hl - hm); }
long eh_m_SC(int c) { return (gl << c) * (256L - hl); }
long eh_m_ST(int c) { return (gl << c) * (hc ? hl : hm); }
long eh_m_SS(int c) { return (gl << c) * (hl << c); }
long eh_m_SD(int c) { return (gl << c) * hps->l; }
long eh_m_DK(int c) { return gps->l * 7L; }
long eh_m_DG(int c) { return gps->l * hl; }
long eh_m_DM(int c) { return gps->l * hs.l; }
long eh_m_DP(int c) { return gps->l * *hpl; }
long eh_m_DE(int c) { return gps->l * hla[3]; }
long eh_m_DX(int c) { return gps->l * hla[c]; }
long eh_m_DN(int c) { return gps->l * !hl; }
long eh_m_DU(int c) { return gps->l * -hl; }
long eh_m_DB(int c) { return gps->l * (hl - hm); }
long eh_m_DC(int c) { return gps->l * (256L - hl); }
long eh_m_DT(int c) { return gps->l * (hc ? hl : hm); }
long eh_m_DS(int c) { return gps->l * (hl << c); }
long eh_m_DD(int c) { return gps->l * hps->l; }

long eh_d_KK(int c) { return 7L / 7L; }
long eh_d_KG(int c) { return 7L / hl; }
long eh_d_KM(int c) { return 7L / hs.l; }
long eh_d_KP(int c) { return 7L / *hpl; }
long eh_d_KE(int c) { return 7L / hla[3]; }
long eh_d_KX(int c) { return 7L / hla[c]; }
long eh_d_KN(int c) { return 7L / !hl; }
long eh_d_KU(int c) { return 7L / -hl; }
long eh_d_KB(int c) { return 7L / (hl - hm); }
long eh_d_KC(int c) { return 7L / (256L - hl); }
long eh_d_KT(int c) { return 7L / (hc ? hl : hm); }
long eh_d_KS(int c) { return 7L / (hl << c); }
long eh_d_KD(int c) { return 7L / hps->l; }
long eh_d_GK(int c) { return gl / 7L; }
long eh_d_GG(int c) { return gl / hl; }
long eh_d_GM(int c) { return gl / hs.l; }
long eh_d_GP(int c) { return gl / *hpl; }
long eh_d_GE(int c) { return gl / hla[3]; }
long eh_d_GX(int c) { return gl / hla[c]; }
long eh_d_GN(int c) { return gl / !hl; }
long eh_d_GU(int c) { return gl / -hl; }
long eh_d_GB(int c) { return gl / (hl - hm); }
long eh_d_GC(int c) { return gl / (256L - hl); }
long eh_d_GT(int c) { return gl / (hc ? hl : hm); }
long eh_d_GS(int c) { return gl / (hl << c); }
long eh_d_GD(int c) { return gl / hps->l; }
long eh_d_MK(int c) { return gs.l / 7L; }
long eh_d_MG(int c) { return gs.l / hl; }
long eh_d_MM(int c) { return gs.l / hs.l; }
long eh_d_MP(int c) { return gs.l / *hpl; }
long eh_d_ME(int c) { return gs.l / hla[3]; }
long eh_d_MX(int c) { return gs.l / hla[c]; }
long eh_d_MN(int c) { return gs.l / !hl; }
long eh_d_MU(int c) { return gs.l / -hl; }
long eh_d_MB(int c) { return gs.l / (hl - hm); }
long eh_d_MC(int c) { return gs.l / (256L - hl); }
long eh_d_MT(int c) { return gs.l / (hc ? hl : hm); }
long eh_d_MS(int c) { return gs.l / (hl << c); }
long eh_d_MD(int c) { return gs.l / hps->l; }
long eh_d_PK(int c) { return *gpl / 7L; }
long eh_d_PG(int c) { return *gpl / hl; }
long eh_d_PM(int c) { return *gpl / hs.l; }
long eh_d_PP(int c) { return *gpl / *hpl; }
long eh_d_PE(int c) { return *gpl / hla[3]; }
long eh_d_PX(int c) { return *gpl / hla[c]; }
long eh_d_PN(int c) { return *gpl / !hl; }
long eh_d_PU(int c) { return *gpl / -hl; }
long eh_d_PB(int c) { return *gpl / (hl - hm); }
long eh_d_PC(int c) { return *gpl / (256L - hl); }
long eh_d_PT(int c) { return *gpl / (hc ? hl : hm); }
long eh_d_PS(int c) { return *gpl / (hl << c); }
long eh_d_PD(int c) { return *gpl / hps->l; }
long eh_d_EK(int c) { return gla[3] / 7L; }
long eh_d_EG(int c) { return gla[3] / hl; }
long eh_d_EM(int c) { return gla[3] / hs.l; }
long eh_d_EP(int c) { return gla[3] / *hpl; }
long eh_d_EE(int c) { return gla[3] / hla[3]; }
long eh_d_EX(int c) { return gla[3] / hla[c]; }
long eh_d_EN(int c) { return gla[3] / !hl; }
long eh_d_EU(int c) { return gla[3] / -hl; }
long eh_d_EB(int c) { return gla[3] / (hl - hm); }
long eh_d_EC(int c) { return gla[3] / (256L - hl); }
long eh_d_ET(int c) { return gla[3] / (hc ? hl : hm); }
long eh_d_ES(int c) { return gla[3] / (hl << c); }
long eh_d_ED(int c) { return gla[3] / hps->l; }
long eh_d_XK(int c) { return gla[c] / 7L; }
long eh_d_XG(int c) { return gla[c] / hl; }
long eh_d_XM(int c) { return gla[c] / hs.l; }
long eh_d_XP(int c) { return gla[c] / *hpl; }
long eh_d_XE(int c) { return gla[c] / hla[3]; }
long eh_d_XX(int c) { return gla[c] / hla[c]; }
long eh_d_XN(int c) { return gla[c] / !hl; }
long eh_d_XU(int c) { return gla[c] / -hl; }
long eh_d_XB(int c) { return gla[c] / (hl - hm); }
long eh_d_XC(int c) { return gla[c] / (256L - hl); }
long eh_d_XT(int c) { return gla[c] / (hc ? hl : hm); }
long eh_d_XS(int c) { return gla[c] / (hl << c); }
long eh_d_XD(int c) { return gla[c] / hps->l; }
long eh_d_NK(int c) { return !gl / 7L; }
long eh_d_NG(int c) { return !gl / hl; }
long eh_d_NM(int c) { return !gl / hs.l; }
long eh_d_NP(int c) { return !gl / *hpl; }
long eh_d_NE(int c) { return !gl / hla[3]; }
long eh_d_NX(int c) { return !gl / hla[c]; }
long eh_d_NN(int c) { return !gl / !hl; }
long eh_d_NU(int c) { return !gl / -hl; }
long eh_d_NB(int c) { return !gl / (hl - hm); }
long eh_d_NC(int c) { return !gl / (256L - hl); }
long eh_d_NT(int c) { return !gl / (hc ? hl : hm); }
long eh_d_NS(int c) { return !gl / (hl << c); }
long eh_d_ND(int c) { return !gl / hps->l; }
long eh_d_UK(int c) { return -gl / 7L; }
long eh_d_UG(int c) { return -gl / hl; }
long eh_d_UM(int c) { return -gl / hs.l; }
long eh_d_UP(int c) { return -gl / *hpl; }
long eh_d_UE(int c) { return -gl / hla[3]; }
long eh_d_UX(int c) { return -gl / hla[c]; }
long eh_d_UN(int c) { return -gl / !hl; }
long eh_d_UU(int c) { return -gl / -hl; }
long eh_d_UB(int c) { return -gl / (hl - hm); }
long eh_d_UC(int c) { return -gl / (256L - hl); }
long eh_d_UT(int c) { return -gl / (hc ? hl : hm); }
long eh_d_US(int c) { return -gl / (hl << c); }
long eh_d_UD(int c) { return -gl / hps->l; }
long eh_d_BK(int c) { return (gl - gm) / 7L; }
long eh_d_BG(int c) { return (gl - gm) / hl; }
long eh_d_BM(int c) { return (gl - gm) / hs.l; }
long eh_d_BP(int c) { return (gl - gm) / *hpl; }
long eh_d_BE(int c) { return (gl - gm) / hla[3]; }
long eh_d_BX(int c) { return (gl - gm) / hla[c]; }
long eh_d_BN(int c) { return (gl - gm) / !hl; }
long eh_d_BU(int c) { return (gl - gm) / -hl; }
long eh_d_BB(int c) { return (gl - gm) / (hl - hm); }
long eh_d_BC(int c) { return (gl - gm) / (256L - hl); }
long eh_d_BT(int c) { return (gl - gm) / (hc ? hl : hm); }
long eh_d_BS(int c) { return (gl - gm) / (hl << c); }
long eh_d_BD(int c) { return (gl - gm) / hps->l; }
long eh_d_CK(int c) { return (256L - gl) / 7L; }
long eh_d_CG(int c) { return (256L - gl) / hl; }
long eh_d_CM(int c) { return (256L - gl) / hs.l; }
long eh_d_CP(int c) { return (256L - gl) / *hpl; }
long eh_d_CE(int c) { return (256L - gl) / hla[3]; }
long eh_d_CX(int c) { return (256L - gl) / hla[c]; }
long eh_d_CN(int c) { return (256L - gl) / !hl; }
long eh_d_CU(int c) { return (256L - gl) / -hl; }
long eh_d_CB(int c) { return (256L - gl) / (hl - hm); }
long eh_d_CC(int c) { return (256L - gl) / (256L - hl); }
long eh_d_CT(int c) { return (256L - gl) / (hc ? hl : hm); }
long eh_d_CS(int c) { return (256L - gl) / (hl << c); }
long eh_d_CD(int c) { return (256L - gl) / hps->l; }
long eh_d_TK(int c) { return (gc ? gl : gm) / 7L; }
long eh_d_TG(int c) { return (gc ? gl : gm) / hl; }
long eh_d_TM(int c) { return (gc ? gl : gm) / hs.l; }
long eh_d_TP(int c) { return (gc ? gl : gm) / *hpl; }
long eh_d_TE(int c) { return (gc ? gl : gm) / hla[3]; }
long eh_d_TX(int c) { return (gc ? gl : gm) / hla[c]; }
long eh_d_TN(int c) { return (gc ? gl : gm) / !hl; }
long eh_d_TU(int c) { return (gc ? gl : gm) / -hl; }
long eh_d_TB(int c) { return (gc ? gl : gm) / (hl - hm); }
long eh_d_TC(int c) { return (gc ? gl : gm) / (256L - hl); }
long eh_d_TT(int c) { return (gc ? gl : gm) / (hc ? hl : hm); }
long eh_d_TS(int c) { return (gc ? gl : gm) / (hl << c); }
long eh_d_TD(int c) { return (gc ? gl : gm) / hps->l; }
long eh_d_SK(int c) { return (gl << c) / 7L; }
long eh_d_SG(int c) { return (gl << c) / hl; }
long eh_d_SM(int c) { return (gl << c) / hs.l; }
long eh_d_SP(int c) { return (gl << c) / *hpl; }
long eh_d_SE(int c) { return (gl << c) / hla[3]; }
long eh_d_SX(int c) { return (gl << c) / hla[c]; }
long eh_d_SN(int c) { return (gl << c) / !hl; }
long eh_d_SU(int c) { return (gl << c) / -hl; }
long eh_d_SB(int c) { return (gl << c) / (hl - hm); }
long eh_d_SC(int c) { return (gl << c) / (256L - hl); }
long eh_d_ST(int c) { return (gl << c) / (hc ? hl : hm); }
long eh_d_SS(int c) { return (gl << c) / (hl << c); }
long eh_d_SD(int c) { return (gl << c) / hps->l; }
long eh_d_DK(int c) { return gps->l / 7L; }
long eh_d_DG(int c) { return gps->l / hl; }
long eh_d_DM(int c) { return gps->l / hs.l; }
long eh_d_DP(int c) { return gps->l / *hpl; }
long eh_d_DE(int c) { return gps->l / hla[3]; }
long eh_d_DX(int c) { return gps->l / hla[c]; }
long eh_d_DN(int c) { return gps->l / !hl; }
long eh_d_DU(int c) { return gps->l / -hl; }
long eh_d_DB(int c) { return gps->l / (hl - hm); }
long eh_d_DC(int c) { return gps->l / (256L - hl); }
long eh_d_DT(int c) { return gps->l / (hc ? hl : hm); }
long eh_d_DS(int c) { return gps->l / (hl << c); }
long eh_d_DD(int c) { return gps->l / hps->l; }

long eh_r_KK(int c) { return 7L % 7L; }
long eh_r_KG(int c) { return 7L % hl; }
long eh_r_KM(int c) { return 7L % hs.l; }
long eh_r_KP(int c) { return 7L % *hpl; }
long eh_r_KE(int c) { return 7L % hla[3]; }
long eh_r_KX(int c) { return 7L % hla[c]; }
long eh_r_KN(int c) { return 7L % !hl; }
long eh_r_KU(int c) { return 7L % -hl; }
long eh_r_KB(int c) { return 7L % (hl - hm); }
long eh_r_KC(int c) { return 7L % (256L - hl); }
long eh_r_KT(int c) { return 7L % (hc ? hl : hm); }
long eh_r_KS(int c) { return 7L % (hl << c); }
long eh_r_KD(int c) { return 7L % hps->l; }
long eh_r_GK(int c) { return gl % 7L; }
long eh_r_GG(int c) { return gl % hl; }
long eh_r_GM(int c) { return gl % hs.l; }
long eh_r_GP(int c) { return gl % *hpl; }
long eh_r_GE(int c) { return gl % hla[3]; }
long eh_r_GX(int c) { return gl % hla[c]; }
long eh_r_GN(int c) { return gl % !hl; }
long eh_r_GU(int c) { return gl % -hl; }
long eh_r_GB(int c) { return gl % (hl - hm); }
long eh_r_GC(int c) { return gl % (256L - hl); }
long eh_r_GT(int c) { return gl % (hc ? hl : hm); }
long eh_r_GS(int c) { return gl % (hl << c); }
long eh_r_GD(int c) { return gl % hps->l; }
long eh_r_MK(int c) { return gs.l % 7L; }
long eh_r_MG(int c) { return gs.l % hl; }
long eh_r_MM(int c) { return gs.l % hs.l; }
long eh_r_MP(int c) { return gs.l % *hpl; }
long eh_r_ME(int c) { return gs.l % hla[3]; }
long eh_r_MX(int c) { return gs.l % hla[c]; }
long eh_r_MN(int c) { return gs.l % !hl; }
long eh_r_MU(int c) { return gs.l % -hl; }
long eh_r_MB(int c) { return gs.l % (hl - hm); }
long eh_r_MC(int c) { return gs.l % (256L - hl); }
long eh_r_MT(int c) { return gs.l % (hc ? hl : hm); }
long eh_r_MS(int c) { return gs.l % (hl << c); }
long eh_r_MD(int c) { return gs.l % hps->l; }
long eh_r_PK(int c) { return *gpl % 7L; }
long eh_r_PG(int c) { return *gpl % hl; }
long eh_r_PM(int c) { return *gpl % hs.l; }
long eh_r_PP(int c) { return *gpl % *hpl; }
long eh_r_PE(int c) { return *gpl % hla[3]; }
long eh_r_PX(int c) { return *gpl % hla[c]; }
long eh_r_PN(int c) { return *gpl % !hl; }
long eh_r_PU(int c) { return *gpl % -hl; }
long eh_r_PB(int c) { return *gpl % (hl - hm); }
long eh_r_PC(int c) { return *gpl % (256L - hl); }
long eh_r_PT(int c) { return *gpl % (hc ? hl : hm); }
long eh_r_PS(int c) { return *gpl % (hl << c); }
long eh_r_PD(int c) { return *gpl % hps->l; }
long eh_r_EK(int c) { return gla[3] % 7L; }
long eh_r_EG(int c) { return gla[3] % hl; }
long eh_r_EM(int c) { return gla[3] % hs.l; }
long eh_r_EP(int c) { return gla[3] % *hpl; }
long eh_r_EE(int c) { return gla[3] % hla[3]; }
long eh_r_EX(int c) { return gla[3] % hla[c]; }
long eh_r_EN(int c) { return gla[3] % !hl; }
long eh_r_EU(int c) { return gla[3] % -hl; }
long eh_r_EB(int c) { return gla[3] % (hl - hm); }
long eh_r_EC(int c) { return gla[3] % (256L - hl); }
long eh_r_ET(int c) { return gla[3] % (hc ? hl : hm); }
long eh_r_ES(int c) { return gla[3] % (hl << c); }
long eh_r_ED(int c) { return gla[3] % hps->l; }
long eh_r_XK(int c) { return gla[c] % 7L; }
long eh_r_XG(int c) { return gla[c] % hl; }
long eh_r_XM(int c) { return gla[c] % hs.l; }
long eh_r_XP(int c) { return gla[c] % *hpl; }
long eh_r_XE(int c) { return gla[c] % hla[3]; }
long eh_r_XX(int c) { return gla[c] % hla[c]; }
long eh_r_XN(int c) { return gla[c] % !hl; }
long eh_r_XU(int c) { return gla[c] % -hl; }
long eh_r_XB(int c) { return gla[c] % (hl - hm); }
long eh_r_XC(int c) { return gla[c] % (256L - hl); }
long eh_r_XT(int c) { return gla[c] % (hc ? hl : hm); }
long eh_r_XS(int c) { return gla[c] % (hl << c); }
long eh_r_XD(int c) { return gla[c] % hps->l; }
long eh_r_NK(int c) { return !gl % 7L; }
long eh_r_NG(int c) { return !gl % hl; }
long eh_r_NM(int c) { return !gl % hs.l; }
long eh_r_NP(int c) { return !gl % *hpl; }
long eh_r_NE(int c) { return !gl % hla[3]; }
long eh_r_NX(int c) { return !gl % hla[c]; }
long eh_r_NN(int c) { return !gl % !hl; }
long eh_r_NU(int c) { return !gl % -hl; }
long eh_r_NB(int c) { return !gl % (hl - hm); }
long eh_r_NC(int c) { return !gl % (256L - hl); }
long eh_r_NT(int c) { return !gl % (hc ? hl : hm); }
long eh_r_NS(int c) { return !gl % (hl << c); }
long eh_r_ND(int c) { return !gl % hps->l; }
long eh_r_UK(int c) { return -gl % 7L; }
long eh_r_UG(int c) { return -gl % hl; }
long eh_r_UM(int c) { return -gl % hs.l; }
long eh_r_UP(int c) { return -gl % *hpl; }
long eh_r_UE(int c) { return -gl % hla[3]; }
long eh_r_UX(int c) { return -gl % hla[c]; }
long eh_r_UN(int c) { return -gl % !hl; }
long eh_r_UU(int c) { return -gl % -hl; }
long eh_r_UB(int c) { return -gl % (hl - hm); }
long eh_r_UC(int c) { return -gl % (256L - hl); }
long eh_r_UT(int c) { return -gl % (hc ? hl : hm); }
long eh_r_US(int c) { return -gl % (hl << c); }
long eh_r_UD(int c) { return -gl % hps->l; }
long eh_r_BK(int c) { return (gl - gm) % 7L; }
long eh_r_BG(int c) { return (gl - gm) % hl; }
long eh_r_BM(int c) { return (gl - gm) % hs.l; }
long eh_r_BP(int c) { return (gl - gm) % *hpl; }
long eh_r_BE(int c) { return (gl - gm) % hla[3]; }
long eh_r_BX(int c) { return (gl - gm) % hla[c]; }
long eh_r_BN(int c) { return (gl - gm) % !hl; }
long eh_r_BU(int c) { return (gl - gm) % -hl; }
long eh_r_BB(int c) { return (gl - gm) % (hl - hm); }
long eh_r_BC(int c) { return (gl - gm) % (256L - hl); }
long eh_r_BT(int c) { return (gl - gm) % (hc ? hl : hm); }
long eh_r_BS(int c) { return (gl - gm) % (hl << c); }
long eh_r_BD(int c) { return (gl - gm) % hps->l; }
long eh_r_CK(int c) { return (256L - gl) % 7L; }
long eh_r_CG(int c) { return (256L - gl) % hl; }
long eh_r_CM(int c) { return (256L - gl) % hs.l; }
long eh_r_CP(int c) { return (256L - gl) % *hpl; }
long eh_r_CE(int c) { return (256L - gl) % hla[3]; }
long eh_r_CX(int c) { return (256L - gl) % hla[c]; }
long eh_r_CN(int c) { return (256L - gl) % !hl; }
long eh_r_CU(int c) { return (256L - gl) % -hl; }
long eh_r_CB(int c) { return (256L - gl) % (hl - hm); }
long eh_r_CC(int c) { return (256L - gl) % (256L - hl); }
long eh_r_CT(int c) { return (256L - gl) % (hc ? hl : hm); }
long eh_r_CS(int c) { return (256L - gl) % (hl << c); }
long eh_r_CD(int c) { return (256L - gl) % hps->l; }
long eh_r_TK(int c) { return (gc ? gl : gm) % 7L; }
long eh_r_TG(int c) { return (gc ? gl : gm) % hl; }
long eh_r_TM(int c) { return (gc ? gl : gm) % hs.l; }
long eh_r_TP(int c) { return (gc ? gl : gm) % *hpl; }
long eh_r_TE(int c) { return (gc ? gl : gm) % hla[3]; }
long eh_r_TX(int c) { return (gc ? gl : gm) % hla[c]; }
long eh_r_TN(int c) { return (gc ? gl : gm) % !hl; }
long eh_r_TU(int c) { return (gc ? gl : gm) % -hl; }
long eh_r_TB(int c) { return (gc ? gl : gm) % (hl - hm); }
long eh_r_TC(int c) { return (gc ? gl : gm) % (256L - hl); }
long eh_r_TT(int c) { return (gc ? gl : gm) % (hc ? hl : hm); }
long eh_r_TS(int c) { return (gc ? gl : gm) % (hl << c); }
long eh_r_TD(int c) { return (gc ? gl : gm) % hps->l; }
long eh_r_SK(int c) { return (gl << c) % 7L; }
long eh_r_SG(int c) { return (gl << c) % hl; }
long eh_r_SM(int c) { return (gl << c) % hs.l; }
long eh_r_SP(int c) { return (gl << c) % *hpl; }
long eh_r_SE(int c) { return (gl << c) % hla[3]; }
long eh_r_SX(int c) { return (gl << c) % hla[c]; }
long eh_r_SN(int c) { return (gl << c) % !hl; }
long eh_r_SU(int c) { return (gl << c) % -hl; }
long eh_r_SB(int c) { return (gl << c) % (hl - hm); }
long eh_r_SC(int c) { return (gl << c) % (256L - hl); }
long eh_r_ST(int c) { return (gl << c) % (hc ? hl : hm); }
long eh_r_SS(int c) { return (gl << c) % (hl << c); }
long eh_r_SD(int c) { return (gl << c) % hps->l; }
long eh_r_DK(int c) { return gps->l % 7L; }
long eh_r_DG(int c) { return gps->l % hl; }
long eh_r_DM(int c) { return gps->l % hs.l; }
long eh_r_DP(int c) { return gps->l % *hpl; }
long eh_r_DE(int c) { return gps->l % hla[3]; }
long eh_r_DX(int c) { return gps->l % hla[c]; }
long eh_r_DN(int c) { return gps->l % !hl; }
long eh_r_DU(int c) { return gps->l % -hl; }
long eh_r_DB(int c) { return gps->l % (hl - hm); }
long eh_r_DC(int c) { return gps->l % (256L - hl); }
long eh_r_DT(int c) { return gps->l % (hc ? hl : hm); }
long eh_r_DS(int c) { return gps->l % (hl << c); }
long eh_r_DD(int c) { return gps->l % hps->l; }
