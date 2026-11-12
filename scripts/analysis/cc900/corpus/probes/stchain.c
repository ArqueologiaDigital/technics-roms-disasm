/* A store whose value is an assignment (gen_stchain.py): sc_<t>_<L1><L2><V>(c) { L1 = (L2 = V); } for int (i) and
   long (l).  L: G global, M static member, P deref, D member through a pointer, E constant element, X element at
   c, Q pointer element at c.  V: K constant, G global, B difference, C call.  L1 writes g*, L2 h*, V reads v*. */
struct st { char c; int i; long l; int a[4]; };
extern int gv, hv, vi, vj; extern long gl, hl, vl, vm; extern int gia[8], hia[8]; extern long gla[8], hla[8];
extern int *gpi, *hpi; extern long *gpl, *hpl; extern struct st gs, hs, *gps, *hps;
extern int ri(void); extern long rl(void);

void sc_i_GGK(int c) { gv = (hv = 7); }
void sc_i_GGG(int c) { gv = (hv = vi); }
void sc_i_GGB(int c) { gv = (hv = (vi - vj)); }
void sc_i_GGC(int c) { gv = (hv = ri()); }
void sc_i_GMK(int c) { gv = (hs.i = 7); }
void sc_i_GMG(int c) { gv = (hs.i = vi); }
void sc_i_GMB(int c) { gv = (hs.i = (vi - vj)); }
void sc_i_GMC(int c) { gv = (hs.i = ri()); }
void sc_i_GPK(int c) { gv = (*hpi = 7); }
void sc_i_GPG(int c) { gv = (*hpi = vi); }
void sc_i_GPB(int c) { gv = (*hpi = (vi - vj)); }
void sc_i_GPC(int c) { gv = (*hpi = ri()); }
void sc_i_GDK(int c) { gv = (hps->i = 7); }
void sc_i_GDG(int c) { gv = (hps->i = vi); }
void sc_i_GDB(int c) { gv = (hps->i = (vi - vj)); }
void sc_i_GDC(int c) { gv = (hps->i = ri()); }
void sc_i_GEK(int c) { gv = (hia[3] = 7); }
void sc_i_GEG(int c) { gv = (hia[3] = vi); }
void sc_i_GEB(int c) { gv = (hia[3] = (vi - vj)); }
void sc_i_GEC(int c) { gv = (hia[3] = ri()); }
void sc_i_GXK(int c) { gv = (hia[c] = 7); }
void sc_i_GXG(int c) { gv = (hia[c] = vi); }
void sc_i_GXB(int c) { gv = (hia[c] = (vi - vj)); }
void sc_i_GXC(int c) { gv = (hia[c] = ri()); }
void sc_i_GQK(int c) { gv = (hpi[c] = 7); }
void sc_i_GQG(int c) { gv = (hpi[c] = vi); }
void sc_i_GQB(int c) { gv = (hpi[c] = (vi - vj)); }
void sc_i_GQC(int c) { gv = (hpi[c] = ri()); }
void sc_i_MGK(int c) { gs.i = (hv = 7); }
void sc_i_MGG(int c) { gs.i = (hv = vi); }
void sc_i_MGB(int c) { gs.i = (hv = (vi - vj)); }
void sc_i_MGC(int c) { gs.i = (hv = ri()); }
void sc_i_MMK(int c) { gs.i = (hs.i = 7); }
void sc_i_MMG(int c) { gs.i = (hs.i = vi); }
void sc_i_MMB(int c) { gs.i = (hs.i = (vi - vj)); }
void sc_i_MMC(int c) { gs.i = (hs.i = ri()); }
void sc_i_MPK(int c) { gs.i = (*hpi = 7); }
void sc_i_MPG(int c) { gs.i = (*hpi = vi); }
void sc_i_MPB(int c) { gs.i = (*hpi = (vi - vj)); }
void sc_i_MPC(int c) { gs.i = (*hpi = ri()); }
void sc_i_MDK(int c) { gs.i = (hps->i = 7); }
void sc_i_MDG(int c) { gs.i = (hps->i = vi); }
void sc_i_MDB(int c) { gs.i = (hps->i = (vi - vj)); }
void sc_i_MDC(int c) { gs.i = (hps->i = ri()); }
void sc_i_MEK(int c) { gs.i = (hia[3] = 7); }
void sc_i_MEG(int c) { gs.i = (hia[3] = vi); }
void sc_i_MEB(int c) { gs.i = (hia[3] = (vi - vj)); }
void sc_i_MEC(int c) { gs.i = (hia[3] = ri()); }
void sc_i_MXK(int c) { gs.i = (hia[c] = 7); }
void sc_i_MXG(int c) { gs.i = (hia[c] = vi); }
void sc_i_MXB(int c) { gs.i = (hia[c] = (vi - vj)); }
void sc_i_MXC(int c) { gs.i = (hia[c] = ri()); }
void sc_i_MQK(int c) { gs.i = (hpi[c] = 7); }
void sc_i_MQG(int c) { gs.i = (hpi[c] = vi); }
void sc_i_MQB(int c) { gs.i = (hpi[c] = (vi - vj)); }
void sc_i_MQC(int c) { gs.i = (hpi[c] = ri()); }
void sc_i_PGK(int c) { *gpi = (hv = 7); }
void sc_i_PGG(int c) { *gpi = (hv = vi); }
void sc_i_PGB(int c) { *gpi = (hv = (vi - vj)); }
void sc_i_PGC(int c) { *gpi = (hv = ri()); }
void sc_i_PMK(int c) { *gpi = (hs.i = 7); }
void sc_i_PMG(int c) { *gpi = (hs.i = vi); }
void sc_i_PMB(int c) { *gpi = (hs.i = (vi - vj)); }
void sc_i_PMC(int c) { *gpi = (hs.i = ri()); }
void sc_i_PPK(int c) { *gpi = (*hpi = 7); }
void sc_i_PPG(int c) { *gpi = (*hpi = vi); }
void sc_i_PPB(int c) { *gpi = (*hpi = (vi - vj)); }
void sc_i_PPC(int c) { *gpi = (*hpi = ri()); }
void sc_i_PDK(int c) { *gpi = (hps->i = 7); }
void sc_i_PDG(int c) { *gpi = (hps->i = vi); }
void sc_i_PDB(int c) { *gpi = (hps->i = (vi - vj)); }
void sc_i_PDC(int c) { *gpi = (hps->i = ri()); }
void sc_i_PEK(int c) { *gpi = (hia[3] = 7); }
void sc_i_PEG(int c) { *gpi = (hia[3] = vi); }
void sc_i_PEB(int c) { *gpi = (hia[3] = (vi - vj)); }
void sc_i_PEC(int c) { *gpi = (hia[3] = ri()); }
void sc_i_PXK(int c) { *gpi = (hia[c] = 7); }
void sc_i_PXG(int c) { *gpi = (hia[c] = vi); }
void sc_i_PXB(int c) { *gpi = (hia[c] = (vi - vj)); }
void sc_i_PXC(int c) { *gpi = (hia[c] = ri()); }
void sc_i_PQK(int c) { *gpi = (hpi[c] = 7); }
void sc_i_PQG(int c) { *gpi = (hpi[c] = vi); }
void sc_i_PQB(int c) { *gpi = (hpi[c] = (vi - vj)); }
void sc_i_PQC(int c) { *gpi = (hpi[c] = ri()); }
void sc_i_DGK(int c) { gps->i = (hv = 7); }
void sc_i_DGG(int c) { gps->i = (hv = vi); }
void sc_i_DGB(int c) { gps->i = (hv = (vi - vj)); }
void sc_i_DGC(int c) { gps->i = (hv = ri()); }
void sc_i_DMK(int c) { gps->i = (hs.i = 7); }
void sc_i_DMG(int c) { gps->i = (hs.i = vi); }
void sc_i_DMB(int c) { gps->i = (hs.i = (vi - vj)); }
void sc_i_DMC(int c) { gps->i = (hs.i = ri()); }
void sc_i_DPK(int c) { gps->i = (*hpi = 7); }
void sc_i_DPG(int c) { gps->i = (*hpi = vi); }
void sc_i_DPB(int c) { gps->i = (*hpi = (vi - vj)); }
void sc_i_DPC(int c) { gps->i = (*hpi = ri()); }
void sc_i_DDK(int c) { gps->i = (hps->i = 7); }
void sc_i_DDG(int c) { gps->i = (hps->i = vi); }
void sc_i_DDB(int c) { gps->i = (hps->i = (vi - vj)); }
void sc_i_DDC(int c) { gps->i = (hps->i = ri()); }
void sc_i_DEK(int c) { gps->i = (hia[3] = 7); }
void sc_i_DEG(int c) { gps->i = (hia[3] = vi); }
void sc_i_DEB(int c) { gps->i = (hia[3] = (vi - vj)); }
void sc_i_DEC(int c) { gps->i = (hia[3] = ri()); }
void sc_i_DXK(int c) { gps->i = (hia[c] = 7); }
void sc_i_DXG(int c) { gps->i = (hia[c] = vi); }
void sc_i_DXB(int c) { gps->i = (hia[c] = (vi - vj)); }
void sc_i_DXC(int c) { gps->i = (hia[c] = ri()); }
void sc_i_DQK(int c) { gps->i = (hpi[c] = 7); }
void sc_i_DQG(int c) { gps->i = (hpi[c] = vi); }
void sc_i_DQB(int c) { gps->i = (hpi[c] = (vi - vj)); }
void sc_i_DQC(int c) { gps->i = (hpi[c] = ri()); }
void sc_i_EGK(int c) { gia[3] = (hv = 7); }
void sc_i_EGG(int c) { gia[3] = (hv = vi); }
void sc_i_EGB(int c) { gia[3] = (hv = (vi - vj)); }
void sc_i_EGC(int c) { gia[3] = (hv = ri()); }
void sc_i_EMK(int c) { gia[3] = (hs.i = 7); }
void sc_i_EMG(int c) { gia[3] = (hs.i = vi); }
void sc_i_EMB(int c) { gia[3] = (hs.i = (vi - vj)); }
void sc_i_EMC(int c) { gia[3] = (hs.i = ri()); }
void sc_i_EPK(int c) { gia[3] = (*hpi = 7); }
void sc_i_EPG(int c) { gia[3] = (*hpi = vi); }
void sc_i_EPB(int c) { gia[3] = (*hpi = (vi - vj)); }
void sc_i_EPC(int c) { gia[3] = (*hpi = ri()); }
void sc_i_EDK(int c) { gia[3] = (hps->i = 7); }
void sc_i_EDG(int c) { gia[3] = (hps->i = vi); }
void sc_i_EDB(int c) { gia[3] = (hps->i = (vi - vj)); }
void sc_i_EDC(int c) { gia[3] = (hps->i = ri()); }
void sc_i_EEK(int c) { gia[3] = (hia[3] = 7); }
void sc_i_EEG(int c) { gia[3] = (hia[3] = vi); }
void sc_i_EEB(int c) { gia[3] = (hia[3] = (vi - vj)); }
void sc_i_EEC(int c) { gia[3] = (hia[3] = ri()); }
void sc_i_EXK(int c) { gia[3] = (hia[c] = 7); }
void sc_i_EXG(int c) { gia[3] = (hia[c] = vi); }
void sc_i_EXB(int c) { gia[3] = (hia[c] = (vi - vj)); }
void sc_i_EXC(int c) { gia[3] = (hia[c] = ri()); }
void sc_i_EQK(int c) { gia[3] = (hpi[c] = 7); }
void sc_i_EQG(int c) { gia[3] = (hpi[c] = vi); }
void sc_i_EQB(int c) { gia[3] = (hpi[c] = (vi - vj)); }
void sc_i_EQC(int c) { gia[3] = (hpi[c] = ri()); }
void sc_i_XGK(int c) { gia[c] = (hv = 7); }
void sc_i_XGG(int c) { gia[c] = (hv = vi); }
void sc_i_XGB(int c) { gia[c] = (hv = (vi - vj)); }
void sc_i_XGC(int c) { gia[c] = (hv = ri()); }
void sc_i_XMK(int c) { gia[c] = (hs.i = 7); }
void sc_i_XMG(int c) { gia[c] = (hs.i = vi); }
void sc_i_XMB(int c) { gia[c] = (hs.i = (vi - vj)); }
void sc_i_XMC(int c) { gia[c] = (hs.i = ri()); }
void sc_i_XPK(int c) { gia[c] = (*hpi = 7); }
void sc_i_XPG(int c) { gia[c] = (*hpi = vi); }
void sc_i_XPB(int c) { gia[c] = (*hpi = (vi - vj)); }
void sc_i_XPC(int c) { gia[c] = (*hpi = ri()); }
void sc_i_XDK(int c) { gia[c] = (hps->i = 7); }
void sc_i_XDG(int c) { gia[c] = (hps->i = vi); }
void sc_i_XDB(int c) { gia[c] = (hps->i = (vi - vj)); }
void sc_i_XDC(int c) { gia[c] = (hps->i = ri()); }
void sc_i_XEK(int c) { gia[c] = (hia[3] = 7); }
void sc_i_XEG(int c) { gia[c] = (hia[3] = vi); }
void sc_i_XEB(int c) { gia[c] = (hia[3] = (vi - vj)); }
void sc_i_XEC(int c) { gia[c] = (hia[3] = ri()); }
void sc_i_XXK(int c) { gia[c] = (hia[c] = 7); }
void sc_i_XXG(int c) { gia[c] = (hia[c] = vi); }
void sc_i_XXB(int c) { gia[c] = (hia[c] = (vi - vj)); }
void sc_i_XXC(int c) { gia[c] = (hia[c] = ri()); }
void sc_i_XQK(int c) { gia[c] = (hpi[c] = 7); }
void sc_i_XQG(int c) { gia[c] = (hpi[c] = vi); }
void sc_i_XQB(int c) { gia[c] = (hpi[c] = (vi - vj)); }
void sc_i_XQC(int c) { gia[c] = (hpi[c] = ri()); }
void sc_i_QGK(int c) { gpi[c] = (hv = 7); }
void sc_i_QGG(int c) { gpi[c] = (hv = vi); }
void sc_i_QGB(int c) { gpi[c] = (hv = (vi - vj)); }
void sc_i_QGC(int c) { gpi[c] = (hv = ri()); }
void sc_i_QMK(int c) { gpi[c] = (hs.i = 7); }
void sc_i_QMG(int c) { gpi[c] = (hs.i = vi); }
void sc_i_QMB(int c) { gpi[c] = (hs.i = (vi - vj)); }
void sc_i_QMC(int c) { gpi[c] = (hs.i = ri()); }
void sc_i_QPK(int c) { gpi[c] = (*hpi = 7); }
void sc_i_QPG(int c) { gpi[c] = (*hpi = vi); }
void sc_i_QPB(int c) { gpi[c] = (*hpi = (vi - vj)); }
void sc_i_QPC(int c) { gpi[c] = (*hpi = ri()); }
void sc_i_QDK(int c) { gpi[c] = (hps->i = 7); }
void sc_i_QDG(int c) { gpi[c] = (hps->i = vi); }
void sc_i_QDB(int c) { gpi[c] = (hps->i = (vi - vj)); }
void sc_i_QDC(int c) { gpi[c] = (hps->i = ri()); }
void sc_i_QEK(int c) { gpi[c] = (hia[3] = 7); }
void sc_i_QEG(int c) { gpi[c] = (hia[3] = vi); }
void sc_i_QEB(int c) { gpi[c] = (hia[3] = (vi - vj)); }
void sc_i_QEC(int c) { gpi[c] = (hia[3] = ri()); }
void sc_i_QXK(int c) { gpi[c] = (hia[c] = 7); }
void sc_i_QXG(int c) { gpi[c] = (hia[c] = vi); }
void sc_i_QXB(int c) { gpi[c] = (hia[c] = (vi - vj)); }
void sc_i_QXC(int c) { gpi[c] = (hia[c] = ri()); }
void sc_i_QQK(int c) { gpi[c] = (hpi[c] = 7); }
void sc_i_QQG(int c) { gpi[c] = (hpi[c] = vi); }
void sc_i_QQB(int c) { gpi[c] = (hpi[c] = (vi - vj)); }
void sc_i_QQC(int c) { gpi[c] = (hpi[c] = ri()); }

void sc_l_GGK(int c) { gl = (hl = 7L); }
void sc_l_GGG(int c) { gl = (hl = vl); }
void sc_l_GGB(int c) { gl = (hl = (vl - vm)); }
void sc_l_GGC(int c) { gl = (hl = rl()); }
void sc_l_GMK(int c) { gl = (hs.l = 7L); }
void sc_l_GMG(int c) { gl = (hs.l = vl); }
void sc_l_GMB(int c) { gl = (hs.l = (vl - vm)); }
void sc_l_GMC(int c) { gl = (hs.l = rl()); }
void sc_l_GPK(int c) { gl = (*hpl = 7L); }
void sc_l_GPG(int c) { gl = (*hpl = vl); }
void sc_l_GPB(int c) { gl = (*hpl = (vl - vm)); }
void sc_l_GPC(int c) { gl = (*hpl = rl()); }
void sc_l_GDK(int c) { gl = (hps->l = 7L); }
void sc_l_GDG(int c) { gl = (hps->l = vl); }
void sc_l_GDB(int c) { gl = (hps->l = (vl - vm)); }
void sc_l_GDC(int c) { gl = (hps->l = rl()); }
void sc_l_GEK(int c) { gl = (hla[3] = 7L); }
void sc_l_GEG(int c) { gl = (hla[3] = vl); }
void sc_l_GEB(int c) { gl = (hla[3] = (vl - vm)); }
void sc_l_GEC(int c) { gl = (hla[3] = rl()); }
void sc_l_GXK(int c) { gl = (hla[c] = 7L); }
void sc_l_GXG(int c) { gl = (hla[c] = vl); }
void sc_l_GXB(int c) { gl = (hla[c] = (vl - vm)); }
void sc_l_GXC(int c) { gl = (hla[c] = rl()); }
void sc_l_GQK(int c) { gl = (hpl[c] = 7L); }
void sc_l_GQG(int c) { gl = (hpl[c] = vl); }
void sc_l_GQB(int c) { gl = (hpl[c] = (vl - vm)); }
void sc_l_GQC(int c) { gl = (hpl[c] = rl()); }
void sc_l_MGK(int c) { gs.l = (hl = 7L); }
void sc_l_MGG(int c) { gs.l = (hl = vl); }
void sc_l_MGB(int c) { gs.l = (hl = (vl - vm)); }
void sc_l_MGC(int c) { gs.l = (hl = rl()); }
void sc_l_MMK(int c) { gs.l = (hs.l = 7L); }
void sc_l_MMG(int c) { gs.l = (hs.l = vl); }
void sc_l_MMB(int c) { gs.l = (hs.l = (vl - vm)); }
void sc_l_MMC(int c) { gs.l = (hs.l = rl()); }
void sc_l_MPK(int c) { gs.l = (*hpl = 7L); }
void sc_l_MPG(int c) { gs.l = (*hpl = vl); }
void sc_l_MPB(int c) { gs.l = (*hpl = (vl - vm)); }
void sc_l_MPC(int c) { gs.l = (*hpl = rl()); }
void sc_l_MDK(int c) { gs.l = (hps->l = 7L); }
void sc_l_MDG(int c) { gs.l = (hps->l = vl); }
void sc_l_MDB(int c) { gs.l = (hps->l = (vl - vm)); }
void sc_l_MDC(int c) { gs.l = (hps->l = rl()); }
void sc_l_MEK(int c) { gs.l = (hla[3] = 7L); }
void sc_l_MEG(int c) { gs.l = (hla[3] = vl); }
void sc_l_MEB(int c) { gs.l = (hla[3] = (vl - vm)); }
void sc_l_MEC(int c) { gs.l = (hla[3] = rl()); }
void sc_l_MXK(int c) { gs.l = (hla[c] = 7L); }
void sc_l_MXG(int c) { gs.l = (hla[c] = vl); }
void sc_l_MXB(int c) { gs.l = (hla[c] = (vl - vm)); }
void sc_l_MXC(int c) { gs.l = (hla[c] = rl()); }
void sc_l_MQK(int c) { gs.l = (hpl[c] = 7L); }
void sc_l_MQG(int c) { gs.l = (hpl[c] = vl); }
void sc_l_MQB(int c) { gs.l = (hpl[c] = (vl - vm)); }
void sc_l_MQC(int c) { gs.l = (hpl[c] = rl()); }
void sc_l_PGK(int c) { *gpl = (hl = 7L); }
void sc_l_PGG(int c) { *gpl = (hl = vl); }
void sc_l_PGB(int c) { *gpl = (hl = (vl - vm)); }
void sc_l_PGC(int c) { *gpl = (hl = rl()); }
void sc_l_PMK(int c) { *gpl = (hs.l = 7L); }
void sc_l_PMG(int c) { *gpl = (hs.l = vl); }
void sc_l_PMB(int c) { *gpl = (hs.l = (vl - vm)); }
void sc_l_PMC(int c) { *gpl = (hs.l = rl()); }
void sc_l_PPK(int c) { *gpl = (*hpl = 7L); }
void sc_l_PPG(int c) { *gpl = (*hpl = vl); }
void sc_l_PPB(int c) { *gpl = (*hpl = (vl - vm)); }
void sc_l_PPC(int c) { *gpl = (*hpl = rl()); }
void sc_l_PDK(int c) { *gpl = (hps->l = 7L); }
void sc_l_PDG(int c) { *gpl = (hps->l = vl); }
void sc_l_PDB(int c) { *gpl = (hps->l = (vl - vm)); }
void sc_l_PDC(int c) { *gpl = (hps->l = rl()); }
void sc_l_PEK(int c) { *gpl = (hla[3] = 7L); }
void sc_l_PEG(int c) { *gpl = (hla[3] = vl); }
void sc_l_PEB(int c) { *gpl = (hla[3] = (vl - vm)); }
void sc_l_PEC(int c) { *gpl = (hla[3] = rl()); }
void sc_l_PXK(int c) { *gpl = (hla[c] = 7L); }
void sc_l_PXG(int c) { *gpl = (hla[c] = vl); }
void sc_l_PXB(int c) { *gpl = (hla[c] = (vl - vm)); }
void sc_l_PXC(int c) { *gpl = (hla[c] = rl()); }
void sc_l_PQK(int c) { *gpl = (hpl[c] = 7L); }
void sc_l_PQG(int c) { *gpl = (hpl[c] = vl); }
void sc_l_PQB(int c) { *gpl = (hpl[c] = (vl - vm)); }
void sc_l_PQC(int c) { *gpl = (hpl[c] = rl()); }
void sc_l_DGK(int c) { gps->l = (hl = 7L); }
void sc_l_DGG(int c) { gps->l = (hl = vl); }
void sc_l_DGB(int c) { gps->l = (hl = (vl - vm)); }
void sc_l_DGC(int c) { gps->l = (hl = rl()); }
void sc_l_DMK(int c) { gps->l = (hs.l = 7L); }
void sc_l_DMG(int c) { gps->l = (hs.l = vl); }
void sc_l_DMB(int c) { gps->l = (hs.l = (vl - vm)); }
void sc_l_DMC(int c) { gps->l = (hs.l = rl()); }
void sc_l_DPK(int c) { gps->l = (*hpl = 7L); }
void sc_l_DPG(int c) { gps->l = (*hpl = vl); }
void sc_l_DPB(int c) { gps->l = (*hpl = (vl - vm)); }
void sc_l_DPC(int c) { gps->l = (*hpl = rl()); }
void sc_l_DDK(int c) { gps->l = (hps->l = 7L); }
void sc_l_DDG(int c) { gps->l = (hps->l = vl); }
void sc_l_DDB(int c) { gps->l = (hps->l = (vl - vm)); }
void sc_l_DDC(int c) { gps->l = (hps->l = rl()); }
void sc_l_DEK(int c) { gps->l = (hla[3] = 7L); }
void sc_l_DEG(int c) { gps->l = (hla[3] = vl); }
void sc_l_DEB(int c) { gps->l = (hla[3] = (vl - vm)); }
void sc_l_DEC(int c) { gps->l = (hla[3] = rl()); }
void sc_l_DXK(int c) { gps->l = (hla[c] = 7L); }
void sc_l_DXG(int c) { gps->l = (hla[c] = vl); }
void sc_l_DXB(int c) { gps->l = (hla[c] = (vl - vm)); }
void sc_l_DXC(int c) { gps->l = (hla[c] = rl()); }
void sc_l_DQK(int c) { gps->l = (hpl[c] = 7L); }
void sc_l_DQG(int c) { gps->l = (hpl[c] = vl); }
void sc_l_DQB(int c) { gps->l = (hpl[c] = (vl - vm)); }
void sc_l_DQC(int c) { gps->l = (hpl[c] = rl()); }
void sc_l_EGK(int c) { gla[3] = (hl = 7L); }
void sc_l_EGG(int c) { gla[3] = (hl = vl); }
void sc_l_EGB(int c) { gla[3] = (hl = (vl - vm)); }
void sc_l_EGC(int c) { gla[3] = (hl = rl()); }
void sc_l_EMK(int c) { gla[3] = (hs.l = 7L); }
void sc_l_EMG(int c) { gla[3] = (hs.l = vl); }
void sc_l_EMB(int c) { gla[3] = (hs.l = (vl - vm)); }
void sc_l_EMC(int c) { gla[3] = (hs.l = rl()); }
void sc_l_EPK(int c) { gla[3] = (*hpl = 7L); }
void sc_l_EPG(int c) { gla[3] = (*hpl = vl); }
void sc_l_EPB(int c) { gla[3] = (*hpl = (vl - vm)); }
void sc_l_EPC(int c) { gla[3] = (*hpl = rl()); }
void sc_l_EDK(int c) { gla[3] = (hps->l = 7L); }
void sc_l_EDG(int c) { gla[3] = (hps->l = vl); }
void sc_l_EDB(int c) { gla[3] = (hps->l = (vl - vm)); }
void sc_l_EDC(int c) { gla[3] = (hps->l = rl()); }
void sc_l_EEK(int c) { gla[3] = (hla[3] = 7L); }
void sc_l_EEG(int c) { gla[3] = (hla[3] = vl); }
void sc_l_EEB(int c) { gla[3] = (hla[3] = (vl - vm)); }
void sc_l_EEC(int c) { gla[3] = (hla[3] = rl()); }
void sc_l_EXK(int c) { gla[3] = (hla[c] = 7L); }
void sc_l_EXG(int c) { gla[3] = (hla[c] = vl); }
void sc_l_EXB(int c) { gla[3] = (hla[c] = (vl - vm)); }
void sc_l_EXC(int c) { gla[3] = (hla[c] = rl()); }
void sc_l_EQK(int c) { gla[3] = (hpl[c] = 7L); }
void sc_l_EQG(int c) { gla[3] = (hpl[c] = vl); }
void sc_l_EQB(int c) { gla[3] = (hpl[c] = (vl - vm)); }
void sc_l_EQC(int c) { gla[3] = (hpl[c] = rl()); }
void sc_l_XGK(int c) { gla[c] = (hl = 7L); }
void sc_l_XGG(int c) { gla[c] = (hl = vl); }
void sc_l_XGB(int c) { gla[c] = (hl = (vl - vm)); }
void sc_l_XGC(int c) { gla[c] = (hl = rl()); }
void sc_l_XMK(int c) { gla[c] = (hs.l = 7L); }
void sc_l_XMG(int c) { gla[c] = (hs.l = vl); }
void sc_l_XMB(int c) { gla[c] = (hs.l = (vl - vm)); }
void sc_l_XMC(int c) { gla[c] = (hs.l = rl()); }
void sc_l_XPK(int c) { gla[c] = (*hpl = 7L); }
void sc_l_XPG(int c) { gla[c] = (*hpl = vl); }
void sc_l_XPB(int c) { gla[c] = (*hpl = (vl - vm)); }
void sc_l_XPC(int c) { gla[c] = (*hpl = rl()); }
void sc_l_XDK(int c) { gla[c] = (hps->l = 7L); }
void sc_l_XDG(int c) { gla[c] = (hps->l = vl); }
void sc_l_XDB(int c) { gla[c] = (hps->l = (vl - vm)); }
void sc_l_XDC(int c) { gla[c] = (hps->l = rl()); }
void sc_l_XEK(int c) { gla[c] = (hla[3] = 7L); }
void sc_l_XEG(int c) { gla[c] = (hla[3] = vl); }
void sc_l_XEB(int c) { gla[c] = (hla[3] = (vl - vm)); }
void sc_l_XEC(int c) { gla[c] = (hla[3] = rl()); }
void sc_l_XXK(int c) { gla[c] = (hla[c] = 7L); }
void sc_l_XXG(int c) { gla[c] = (hla[c] = vl); }
void sc_l_XXB(int c) { gla[c] = (hla[c] = (vl - vm)); }
void sc_l_XXC(int c) { gla[c] = (hla[c] = rl()); }
void sc_l_XQK(int c) { gla[c] = (hpl[c] = 7L); }
void sc_l_XQG(int c) { gla[c] = (hpl[c] = vl); }
void sc_l_XQB(int c) { gla[c] = (hpl[c] = (vl - vm)); }
void sc_l_XQC(int c) { gla[c] = (hpl[c] = rl()); }
void sc_l_QGK(int c) { gpl[c] = (hl = 7L); }
void sc_l_QGG(int c) { gpl[c] = (hl = vl); }
void sc_l_QGB(int c) { gpl[c] = (hl = (vl - vm)); }
void sc_l_QGC(int c) { gpl[c] = (hl = rl()); }
void sc_l_QMK(int c) { gpl[c] = (hs.l = 7L); }
void sc_l_QMG(int c) { gpl[c] = (hs.l = vl); }
void sc_l_QMB(int c) { gpl[c] = (hs.l = (vl - vm)); }
void sc_l_QMC(int c) { gpl[c] = (hs.l = rl()); }
void sc_l_QPK(int c) { gpl[c] = (*hpl = 7L); }
void sc_l_QPG(int c) { gpl[c] = (*hpl = vl); }
void sc_l_QPB(int c) { gpl[c] = (*hpl = (vl - vm)); }
void sc_l_QPC(int c) { gpl[c] = (*hpl = rl()); }
void sc_l_QDK(int c) { gpl[c] = (hps->l = 7L); }
void sc_l_QDG(int c) { gpl[c] = (hps->l = vl); }
void sc_l_QDB(int c) { gpl[c] = (hps->l = (vl - vm)); }
void sc_l_QDC(int c) { gpl[c] = (hps->l = rl()); }
void sc_l_QEK(int c) { gpl[c] = (hla[3] = 7L); }
void sc_l_QEG(int c) { gpl[c] = (hla[3] = vl); }
void sc_l_QEB(int c) { gpl[c] = (hla[3] = (vl - vm)); }
void sc_l_QEC(int c) { gpl[c] = (hla[3] = rl()); }
void sc_l_QXK(int c) { gpl[c] = (hla[c] = 7L); }
void sc_l_QXG(int c) { gpl[c] = (hla[c] = vl); }
void sc_l_QXB(int c) { gpl[c] = (hla[c] = (vl - vm)); }
void sc_l_QXC(int c) { gpl[c] = (hla[c] = rl()); }
void sc_l_QQK(int c) { gpl[c] = (hpl[c] = 7L); }
void sc_l_QQG(int c) { gpl[c] = (hpl[c] = vl); }
void sc_l_QQB(int c) { gpl[c] = (hpl[c] = (vl - vm)); }
void sc_l_QQC(int c) { gpl[c] = (hpl[c] = rl()); }

