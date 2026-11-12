/* An assignment as a return value and char chained stores (gen_stret.py): rs_<t>_<L><V>(c) { return L = V; }
   for int (i), long (l), char (c); sc_c_<L1><L2><V>(c) { L1 = (L2 = V); } for char.  L: G global, M static member,
   P deref, D member through a pointer, E constant element, X element at c, Q pointer element at c.  V: K constant,
   G global, B difference, C call.  L1 writes g*, L2 h*, V reads v*. */
struct st { char c; int i; long l; int a[4]; };
extern int gv, hv, vi, vj; extern long gl, hl, vl, vm; extern char gc, hc, vc, vd;
extern int gia[8], hia[8]; extern long gla[8], hla[8]; extern char gca[8], hca[8];
extern int *gpi, *hpi; extern long *gpl, *hpl; extern char *gp, *hp; extern struct st gs, hs, *gps, *hps;
extern int ri(void); extern long rl(void); extern char rc(void);

int rs_i_GK(int c) { return gv = 7; }
int rs_i_GG(int c) { return gv = vi; }
int rs_i_GB(int c) { return gv = (vi - vj); }
int rs_i_GC(int c) { return gv = ri(); }
int rs_i_MK(int c) { return gs.i = 7; }
int rs_i_MG(int c) { return gs.i = vi; }
int rs_i_MB(int c) { return gs.i = (vi - vj); }
int rs_i_MC(int c) { return gs.i = ri(); }
int rs_i_PK(int c) { return *gpi = 7; }
int rs_i_PG(int c) { return *gpi = vi; }
int rs_i_PB(int c) { return *gpi = (vi - vj); }
int rs_i_PC(int c) { return *gpi = ri(); }
int rs_i_DK(int c) { return gps->i = 7; }
int rs_i_DG(int c) { return gps->i = vi; }
int rs_i_DB(int c) { return gps->i = (vi - vj); }
int rs_i_DC(int c) { return gps->i = ri(); }
int rs_i_EK(int c) { return gia[3] = 7; }
int rs_i_EG(int c) { return gia[3] = vi; }
int rs_i_EB(int c) { return gia[3] = (vi - vj); }
int rs_i_EC(int c) { return gia[3] = ri(); }
int rs_i_XK(int c) { return gia[c] = 7; }
int rs_i_XG(int c) { return gia[c] = vi; }
int rs_i_XB(int c) { return gia[c] = (vi - vj); }
int rs_i_XC(int c) { return gia[c] = ri(); }
int rs_i_QK(int c) { return gpi[c] = 7; }
int rs_i_QG(int c) { return gpi[c] = vi; }
int rs_i_QB(int c) { return gpi[c] = (vi - vj); }
int rs_i_QC(int c) { return gpi[c] = ri(); }

long rs_l_GK(int c) { return gl = 7L; }
long rs_l_GG(int c) { return gl = vl; }
long rs_l_GB(int c) { return gl = (vl - vm); }
long rs_l_GC(int c) { return gl = rl(); }
long rs_l_MK(int c) { return gs.l = 7L; }
long rs_l_MG(int c) { return gs.l = vl; }
long rs_l_MB(int c) { return gs.l = (vl - vm); }
long rs_l_MC(int c) { return gs.l = rl(); }
long rs_l_PK(int c) { return *gpl = 7L; }
long rs_l_PG(int c) { return *gpl = vl; }
long rs_l_PB(int c) { return *gpl = (vl - vm); }
long rs_l_PC(int c) { return *gpl = rl(); }
long rs_l_DK(int c) { return gps->l = 7L; }
long rs_l_DG(int c) { return gps->l = vl; }
long rs_l_DB(int c) { return gps->l = (vl - vm); }
long rs_l_DC(int c) { return gps->l = rl(); }
long rs_l_EK(int c) { return gla[3] = 7L; }
long rs_l_EG(int c) { return gla[3] = vl; }
long rs_l_EB(int c) { return gla[3] = (vl - vm); }
long rs_l_EC(int c) { return gla[3] = rl(); }
long rs_l_XK(int c) { return gla[c] = 7L; }
long rs_l_XG(int c) { return gla[c] = vl; }
long rs_l_XB(int c) { return gla[c] = (vl - vm); }
long rs_l_XC(int c) { return gla[c] = rl(); }
long rs_l_QK(int c) { return gpl[c] = 7L; }
long rs_l_QG(int c) { return gpl[c] = vl; }
long rs_l_QB(int c) { return gpl[c] = (vl - vm); }
long rs_l_QC(int c) { return gpl[c] = rl(); }

char rs_c_GK(int c) { return gc = 7; }
char rs_c_GG(int c) { return gc = vc; }
char rs_c_GB(int c) { return gc = (vc - vd); }
char rs_c_GC(int c) { return gc = rc(); }
char rs_c_MK(int c) { return gs.c = 7; }
char rs_c_MG(int c) { return gs.c = vc; }
char rs_c_MB(int c) { return gs.c = (vc - vd); }
char rs_c_MC(int c) { return gs.c = rc(); }
char rs_c_PK(int c) { return *gp = 7; }
char rs_c_PG(int c) { return *gp = vc; }
char rs_c_PB(int c) { return *gp = (vc - vd); }
char rs_c_PC(int c) { return *gp = rc(); }
char rs_c_DK(int c) { return gps->c = 7; }
char rs_c_DG(int c) { return gps->c = vc; }
char rs_c_DB(int c) { return gps->c = (vc - vd); }
char rs_c_DC(int c) { return gps->c = rc(); }
char rs_c_EK(int c) { return gca[3] = 7; }
char rs_c_EG(int c) { return gca[3] = vc; }
char rs_c_EB(int c) { return gca[3] = (vc - vd); }
char rs_c_EC(int c) { return gca[3] = rc(); }
char rs_c_XK(int c) { return gca[c] = 7; }
char rs_c_XG(int c) { return gca[c] = vc; }
char rs_c_XB(int c) { return gca[c] = (vc - vd); }
char rs_c_XC(int c) { return gca[c] = rc(); }
char rs_c_QK(int c) { return gp[c] = 7; }
char rs_c_QG(int c) { return gp[c] = vc; }
char rs_c_QB(int c) { return gp[c] = (vc - vd); }
char rs_c_QC(int c) { return gp[c] = rc(); }

void sc_c_GGK(int c) { gc = (hc = 7); }
void sc_c_GGG(int c) { gc = (hc = vc); }
void sc_c_GGB(int c) { gc = (hc = (vc - vd)); }
void sc_c_GGC(int c) { gc = (hc = rc()); }
void sc_c_GMK(int c) { gc = (hs.c = 7); }
void sc_c_GMG(int c) { gc = (hs.c = vc); }
void sc_c_GMB(int c) { gc = (hs.c = (vc - vd)); }
void sc_c_GMC(int c) { gc = (hs.c = rc()); }
void sc_c_GPK(int c) { gc = (*hp = 7); }
void sc_c_GPG(int c) { gc = (*hp = vc); }
void sc_c_GPB(int c) { gc = (*hp = (vc - vd)); }
void sc_c_GPC(int c) { gc = (*hp = rc()); }
void sc_c_GDK(int c) { gc = (hps->c = 7); }
void sc_c_GDG(int c) { gc = (hps->c = vc); }
void sc_c_GDB(int c) { gc = (hps->c = (vc - vd)); }
void sc_c_GDC(int c) { gc = (hps->c = rc()); }
void sc_c_GEK(int c) { gc = (hca[3] = 7); }
void sc_c_GEG(int c) { gc = (hca[3] = vc); }
void sc_c_GEB(int c) { gc = (hca[3] = (vc - vd)); }
void sc_c_GEC(int c) { gc = (hca[3] = rc()); }
void sc_c_GXK(int c) { gc = (hca[c] = 7); }
void sc_c_GXG(int c) { gc = (hca[c] = vc); }
void sc_c_GXB(int c) { gc = (hca[c] = (vc - vd)); }
void sc_c_GXC(int c) { gc = (hca[c] = rc()); }
void sc_c_GQK(int c) { gc = (hp[c] = 7); }
void sc_c_GQG(int c) { gc = (hp[c] = vc); }
void sc_c_GQB(int c) { gc = (hp[c] = (vc - vd)); }
void sc_c_GQC(int c) { gc = (hp[c] = rc()); }
void sc_c_MGK(int c) { gs.c = (hc = 7); }
void sc_c_MGG(int c) { gs.c = (hc = vc); }
void sc_c_MGB(int c) { gs.c = (hc = (vc - vd)); }
void sc_c_MGC(int c) { gs.c = (hc = rc()); }
void sc_c_MMK(int c) { gs.c = (hs.c = 7); }
void sc_c_MMG(int c) { gs.c = (hs.c = vc); }
void sc_c_MMB(int c) { gs.c = (hs.c = (vc - vd)); }
void sc_c_MMC(int c) { gs.c = (hs.c = rc()); }
void sc_c_MPK(int c) { gs.c = (*hp = 7); }
void sc_c_MPG(int c) { gs.c = (*hp = vc); }
void sc_c_MPB(int c) { gs.c = (*hp = (vc - vd)); }
void sc_c_MPC(int c) { gs.c = (*hp = rc()); }
void sc_c_MDK(int c) { gs.c = (hps->c = 7); }
void sc_c_MDG(int c) { gs.c = (hps->c = vc); }
void sc_c_MDB(int c) { gs.c = (hps->c = (vc - vd)); }
void sc_c_MDC(int c) { gs.c = (hps->c = rc()); }
void sc_c_MEK(int c) { gs.c = (hca[3] = 7); }
void sc_c_MEG(int c) { gs.c = (hca[3] = vc); }
void sc_c_MEB(int c) { gs.c = (hca[3] = (vc - vd)); }
void sc_c_MEC(int c) { gs.c = (hca[3] = rc()); }
void sc_c_MXK(int c) { gs.c = (hca[c] = 7); }
void sc_c_MXG(int c) { gs.c = (hca[c] = vc); }
void sc_c_MXB(int c) { gs.c = (hca[c] = (vc - vd)); }
void sc_c_MXC(int c) { gs.c = (hca[c] = rc()); }
void sc_c_MQK(int c) { gs.c = (hp[c] = 7); }
void sc_c_MQG(int c) { gs.c = (hp[c] = vc); }
void sc_c_MQB(int c) { gs.c = (hp[c] = (vc - vd)); }
void sc_c_MQC(int c) { gs.c = (hp[c] = rc()); }
void sc_c_PGK(int c) { *gp = (hc = 7); }
void sc_c_PGG(int c) { *gp = (hc = vc); }
void sc_c_PGB(int c) { *gp = (hc = (vc - vd)); }
void sc_c_PGC(int c) { *gp = (hc = rc()); }
void sc_c_PMK(int c) { *gp = (hs.c = 7); }
void sc_c_PMG(int c) { *gp = (hs.c = vc); }
void sc_c_PMB(int c) { *gp = (hs.c = (vc - vd)); }
void sc_c_PMC(int c) { *gp = (hs.c = rc()); }
void sc_c_PPK(int c) { *gp = (*hp = 7); }
void sc_c_PPG(int c) { *gp = (*hp = vc); }
void sc_c_PPB(int c) { *gp = (*hp = (vc - vd)); }
void sc_c_PPC(int c) { *gp = (*hp = rc()); }
void sc_c_PDK(int c) { *gp = (hps->c = 7); }
void sc_c_PDG(int c) { *gp = (hps->c = vc); }
void sc_c_PDB(int c) { *gp = (hps->c = (vc - vd)); }
void sc_c_PDC(int c) { *gp = (hps->c = rc()); }
void sc_c_PEK(int c) { *gp = (hca[3] = 7); }
void sc_c_PEG(int c) { *gp = (hca[3] = vc); }
void sc_c_PEB(int c) { *gp = (hca[3] = (vc - vd)); }
void sc_c_PEC(int c) { *gp = (hca[3] = rc()); }
void sc_c_PXK(int c) { *gp = (hca[c] = 7); }
void sc_c_PXG(int c) { *gp = (hca[c] = vc); }
void sc_c_PXB(int c) { *gp = (hca[c] = (vc - vd)); }
void sc_c_PXC(int c) { *gp = (hca[c] = rc()); }
void sc_c_PQK(int c) { *gp = (hp[c] = 7); }
void sc_c_PQG(int c) { *gp = (hp[c] = vc); }
void sc_c_PQB(int c) { *gp = (hp[c] = (vc - vd)); }
void sc_c_PQC(int c) { *gp = (hp[c] = rc()); }
void sc_c_DGK(int c) { gps->c = (hc = 7); }
void sc_c_DGG(int c) { gps->c = (hc = vc); }
void sc_c_DGB(int c) { gps->c = (hc = (vc - vd)); }
void sc_c_DGC(int c) { gps->c = (hc = rc()); }
void sc_c_DMK(int c) { gps->c = (hs.c = 7); }
void sc_c_DMG(int c) { gps->c = (hs.c = vc); }
void sc_c_DMB(int c) { gps->c = (hs.c = (vc - vd)); }
void sc_c_DMC(int c) { gps->c = (hs.c = rc()); }
void sc_c_DPK(int c) { gps->c = (*hp = 7); }
void sc_c_DPG(int c) { gps->c = (*hp = vc); }
void sc_c_DPB(int c) { gps->c = (*hp = (vc - vd)); }
void sc_c_DPC(int c) { gps->c = (*hp = rc()); }
void sc_c_DDK(int c) { gps->c = (hps->c = 7); }
void sc_c_DDG(int c) { gps->c = (hps->c = vc); }
void sc_c_DDB(int c) { gps->c = (hps->c = (vc - vd)); }
void sc_c_DDC(int c) { gps->c = (hps->c = rc()); }
void sc_c_DEK(int c) { gps->c = (hca[3] = 7); }
void sc_c_DEG(int c) { gps->c = (hca[3] = vc); }
void sc_c_DEB(int c) { gps->c = (hca[3] = (vc - vd)); }
void sc_c_DEC(int c) { gps->c = (hca[3] = rc()); }
void sc_c_DXK(int c) { gps->c = (hca[c] = 7); }
void sc_c_DXG(int c) { gps->c = (hca[c] = vc); }
void sc_c_DXB(int c) { gps->c = (hca[c] = (vc - vd)); }
void sc_c_DXC(int c) { gps->c = (hca[c] = rc()); }
void sc_c_DQK(int c) { gps->c = (hp[c] = 7); }
void sc_c_DQG(int c) { gps->c = (hp[c] = vc); }
void sc_c_DQB(int c) { gps->c = (hp[c] = (vc - vd)); }
void sc_c_DQC(int c) { gps->c = (hp[c] = rc()); }
void sc_c_EGK(int c) { gca[3] = (hc = 7); }
void sc_c_EGG(int c) { gca[3] = (hc = vc); }
void sc_c_EGB(int c) { gca[3] = (hc = (vc - vd)); }
void sc_c_EGC(int c) { gca[3] = (hc = rc()); }
void sc_c_EMK(int c) { gca[3] = (hs.c = 7); }
void sc_c_EMG(int c) { gca[3] = (hs.c = vc); }
void sc_c_EMB(int c) { gca[3] = (hs.c = (vc - vd)); }
void sc_c_EMC(int c) { gca[3] = (hs.c = rc()); }
void sc_c_EPK(int c) { gca[3] = (*hp = 7); }
void sc_c_EPG(int c) { gca[3] = (*hp = vc); }
void sc_c_EPB(int c) { gca[3] = (*hp = (vc - vd)); }
void sc_c_EPC(int c) { gca[3] = (*hp = rc()); }
void sc_c_EDK(int c) { gca[3] = (hps->c = 7); }
void sc_c_EDG(int c) { gca[3] = (hps->c = vc); }
void sc_c_EDB(int c) { gca[3] = (hps->c = (vc - vd)); }
void sc_c_EDC(int c) { gca[3] = (hps->c = rc()); }
void sc_c_EEK(int c) { gca[3] = (hca[3] = 7); }
void sc_c_EEG(int c) { gca[3] = (hca[3] = vc); }
void sc_c_EEB(int c) { gca[3] = (hca[3] = (vc - vd)); }
void sc_c_EEC(int c) { gca[3] = (hca[3] = rc()); }
void sc_c_EXK(int c) { gca[3] = (hca[c] = 7); }
void sc_c_EXG(int c) { gca[3] = (hca[c] = vc); }
void sc_c_EXB(int c) { gca[3] = (hca[c] = (vc - vd)); }
void sc_c_EXC(int c) { gca[3] = (hca[c] = rc()); }
void sc_c_EQK(int c) { gca[3] = (hp[c] = 7); }
void sc_c_EQG(int c) { gca[3] = (hp[c] = vc); }
void sc_c_EQB(int c) { gca[3] = (hp[c] = (vc - vd)); }
void sc_c_EQC(int c) { gca[3] = (hp[c] = rc()); }
void sc_c_XGK(int c) { gca[c] = (hc = 7); }
void sc_c_XGG(int c) { gca[c] = (hc = vc); }
void sc_c_XGB(int c) { gca[c] = (hc = (vc - vd)); }
void sc_c_XGC(int c) { gca[c] = (hc = rc()); }
void sc_c_XMK(int c) { gca[c] = (hs.c = 7); }
void sc_c_XMG(int c) { gca[c] = (hs.c = vc); }
void sc_c_XMB(int c) { gca[c] = (hs.c = (vc - vd)); }
void sc_c_XMC(int c) { gca[c] = (hs.c = rc()); }
void sc_c_XPK(int c) { gca[c] = (*hp = 7); }
void sc_c_XPG(int c) { gca[c] = (*hp = vc); }
void sc_c_XPB(int c) { gca[c] = (*hp = (vc - vd)); }
void sc_c_XPC(int c) { gca[c] = (*hp = rc()); }
void sc_c_XDK(int c) { gca[c] = (hps->c = 7); }
void sc_c_XDG(int c) { gca[c] = (hps->c = vc); }
void sc_c_XDB(int c) { gca[c] = (hps->c = (vc - vd)); }
void sc_c_XDC(int c) { gca[c] = (hps->c = rc()); }
void sc_c_XEK(int c) { gca[c] = (hca[3] = 7); }
void sc_c_XEG(int c) { gca[c] = (hca[3] = vc); }
void sc_c_XEB(int c) { gca[c] = (hca[3] = (vc - vd)); }
void sc_c_XEC(int c) { gca[c] = (hca[3] = rc()); }
void sc_c_XXK(int c) { gca[c] = (hca[c] = 7); }
void sc_c_XXG(int c) { gca[c] = (hca[c] = vc); }
void sc_c_XXB(int c) { gca[c] = (hca[c] = (vc - vd)); }
void sc_c_XXC(int c) { gca[c] = (hca[c] = rc()); }
void sc_c_XQK(int c) { gca[c] = (hp[c] = 7); }
void sc_c_XQG(int c) { gca[c] = (hp[c] = vc); }
void sc_c_XQB(int c) { gca[c] = (hp[c] = (vc - vd)); }
void sc_c_XQC(int c) { gca[c] = (hp[c] = rc()); }
void sc_c_QGK(int c) { gp[c] = (hc = 7); }
void sc_c_QGG(int c) { gp[c] = (hc = vc); }
void sc_c_QGB(int c) { gp[c] = (hc = (vc - vd)); }
void sc_c_QGC(int c) { gp[c] = (hc = rc()); }
void sc_c_QMK(int c) { gp[c] = (hs.c = 7); }
void sc_c_QMG(int c) { gp[c] = (hs.c = vc); }
void sc_c_QMB(int c) { gp[c] = (hs.c = (vc - vd)); }
void sc_c_QMC(int c) { gp[c] = (hs.c = rc()); }
void sc_c_QPK(int c) { gp[c] = (*hp = 7); }
void sc_c_QPG(int c) { gp[c] = (*hp = vc); }
void sc_c_QPB(int c) { gp[c] = (*hp = (vc - vd)); }
void sc_c_QPC(int c) { gp[c] = (*hp = rc()); }
void sc_c_QDK(int c) { gp[c] = (hps->c = 7); }
void sc_c_QDG(int c) { gp[c] = (hps->c = vc); }
void sc_c_QDB(int c) { gp[c] = (hps->c = (vc - vd)); }
void sc_c_QDC(int c) { gp[c] = (hps->c = rc()); }
void sc_c_QEK(int c) { gp[c] = (hca[3] = 7); }
void sc_c_QEG(int c) { gp[c] = (hca[3] = vc); }
void sc_c_QEB(int c) { gp[c] = (hca[3] = (vc - vd)); }
void sc_c_QEC(int c) { gp[c] = (hca[3] = rc()); }
void sc_c_QXK(int c) { gp[c] = (hca[c] = 7); }
void sc_c_QXG(int c) { gp[c] = (hca[c] = vc); }
void sc_c_QXB(int c) { gp[c] = (hca[c] = (vc - vd)); }
void sc_c_QXC(int c) { gp[c] = (hca[c] = rc()); }
void sc_c_QQK(int c) { gp[c] = (hp[c] = 7); }
void sc_c_QQG(int c) { gp[c] = (hp[c] = vc); }
void sc_c_QQB(int c) { gp[c] = (hp[c] = (vc - vd)); }
void sc_c_QQC(int c) { gp[c] = (hp[c] = rc()); }

