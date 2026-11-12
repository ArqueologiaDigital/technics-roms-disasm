/* Assignments whose value is read through an address (gen_stval.py): rv_<t>_<L><V>(c) { return L = V; } for char,
   int, long; cv_i_<L1><L2><V>(c) { L1 = (L2 = V); } for int.  L: G global, M static member, P deref, D member
   through a pointer, E constant element, X element at c, Q pointer element at c.  V: P deref, D member through a
   pointer, X element at c, E constant element, M static member.  L1 writes g*, L2 h*, V reads v*. */
struct st { char c; int i; long l; int a[4]; };
extern int gv, hv; extern long gl, hl; extern char gc, hc;
extern int gia[8], hia[8], via[8]; extern long gla[8], hla[8], vla[8]; extern char gca[8], hca[8], vca[8];
extern int *gpi, *hpi, *vpi; extern long *gpl, *hpl, *vpl; extern char *gp, *hp, *vp;
extern struct st gs, hs, vs, *gps, *hps, *vps;

int rv_i_GP(int c) { return gv = *vpi; }
int rv_i_GD(int c) { return gv = vps->i; }
int rv_i_GX(int c) { return gv = via[c]; }
int rv_i_GE(int c) { return gv = via[5]; }
int rv_i_GM(int c) { return gv = vs.i; }
int rv_i_MP(int c) { return gs.i = *vpi; }
int rv_i_MD(int c) { return gs.i = vps->i; }
int rv_i_MX(int c) { return gs.i = via[c]; }
int rv_i_ME(int c) { return gs.i = via[5]; }
int rv_i_MM(int c) { return gs.i = vs.i; }
int rv_i_PP(int c) { return *gpi = *vpi; }
int rv_i_PD(int c) { return *gpi = vps->i; }
int rv_i_PX(int c) { return *gpi = via[c]; }
int rv_i_PE(int c) { return *gpi = via[5]; }
int rv_i_PM(int c) { return *gpi = vs.i; }
int rv_i_DP(int c) { return gps->i = *vpi; }
int rv_i_DD(int c) { return gps->i = vps->i; }
int rv_i_DX(int c) { return gps->i = via[c]; }
int rv_i_DE(int c) { return gps->i = via[5]; }
int rv_i_DM(int c) { return gps->i = vs.i; }
int rv_i_EP(int c) { return gia[3] = *vpi; }
int rv_i_ED(int c) { return gia[3] = vps->i; }
int rv_i_EX(int c) { return gia[3] = via[c]; }
int rv_i_EE(int c) { return gia[3] = via[5]; }
int rv_i_EM(int c) { return gia[3] = vs.i; }
int rv_i_XP(int c) { return gia[c] = *vpi; }
int rv_i_XD(int c) { return gia[c] = vps->i; }
int rv_i_XX(int c) { return gia[c] = via[c]; }
int rv_i_XE(int c) { return gia[c] = via[5]; }
int rv_i_XM(int c) { return gia[c] = vs.i; }
int rv_i_QP(int c) { return gpi[c] = *vpi; }
int rv_i_QD(int c) { return gpi[c] = vps->i; }
int rv_i_QX(int c) { return gpi[c] = via[c]; }
int rv_i_QE(int c) { return gpi[c] = via[5]; }
int rv_i_QM(int c) { return gpi[c] = vs.i; }

long rv_l_GP(int c) { return gl = *vpl; }
long rv_l_GD(int c) { return gl = vps->l; }
long rv_l_GX(int c) { return gl = vla[c]; }
long rv_l_GE(int c) { return gl = vla[5]; }
long rv_l_GM(int c) { return gl = vs.l; }
long rv_l_MP(int c) { return gs.l = *vpl; }
long rv_l_MD(int c) { return gs.l = vps->l; }
long rv_l_MX(int c) { return gs.l = vla[c]; }
long rv_l_ME(int c) { return gs.l = vla[5]; }
long rv_l_MM(int c) { return gs.l = vs.l; }
long rv_l_PP(int c) { return *gpl = *vpl; }
long rv_l_PD(int c) { return *gpl = vps->l; }
long rv_l_PX(int c) { return *gpl = vla[c]; }
long rv_l_PE(int c) { return *gpl = vla[5]; }
long rv_l_PM(int c) { return *gpl = vs.l; }
long rv_l_DP(int c) { return gps->l = *vpl; }
long rv_l_DD(int c) { return gps->l = vps->l; }
long rv_l_DX(int c) { return gps->l = vla[c]; }
long rv_l_DE(int c) { return gps->l = vla[5]; }
long rv_l_DM(int c) { return gps->l = vs.l; }
long rv_l_EP(int c) { return gla[3] = *vpl; }
long rv_l_ED(int c) { return gla[3] = vps->l; }
long rv_l_EX(int c) { return gla[3] = vla[c]; }
long rv_l_EE(int c) { return gla[3] = vla[5]; }
long rv_l_EM(int c) { return gla[3] = vs.l; }
long rv_l_XP(int c) { return gla[c] = *vpl; }
long rv_l_XD(int c) { return gla[c] = vps->l; }
long rv_l_XX(int c) { return gla[c] = vla[c]; }
long rv_l_XE(int c) { return gla[c] = vla[5]; }
long rv_l_XM(int c) { return gla[c] = vs.l; }
long rv_l_QP(int c) { return gpl[c] = *vpl; }
long rv_l_QD(int c) { return gpl[c] = vps->l; }
long rv_l_QX(int c) { return gpl[c] = vla[c]; }
long rv_l_QE(int c) { return gpl[c] = vla[5]; }
long rv_l_QM(int c) { return gpl[c] = vs.l; }

char rv_c_GP(int c) { return gc = *vp; }
char rv_c_GD(int c) { return gc = vps->c; }
char rv_c_GX(int c) { return gc = vca[c]; }
char rv_c_GE(int c) { return gc = vca[5]; }
char rv_c_GM(int c) { return gc = vs.c; }
char rv_c_MP(int c) { return gs.c = *vp; }
char rv_c_MD(int c) { return gs.c = vps->c; }
char rv_c_MX(int c) { return gs.c = vca[c]; }
char rv_c_ME(int c) { return gs.c = vca[5]; }
char rv_c_MM(int c) { return gs.c = vs.c; }
char rv_c_PP(int c) { return *gp = *vp; }
char rv_c_PD(int c) { return *gp = vps->c; }
char rv_c_PX(int c) { return *gp = vca[c]; }
char rv_c_PE(int c) { return *gp = vca[5]; }
char rv_c_PM(int c) { return *gp = vs.c; }
char rv_c_DP(int c) { return gps->c = *vp; }
char rv_c_DD(int c) { return gps->c = vps->c; }
char rv_c_DX(int c) { return gps->c = vca[c]; }
char rv_c_DE(int c) { return gps->c = vca[5]; }
char rv_c_DM(int c) { return gps->c = vs.c; }
char rv_c_EP(int c) { return gca[3] = *vp; }
char rv_c_ED(int c) { return gca[3] = vps->c; }
char rv_c_EX(int c) { return gca[3] = vca[c]; }
char rv_c_EE(int c) { return gca[3] = vca[5]; }
char rv_c_EM(int c) { return gca[3] = vs.c; }
char rv_c_XP(int c) { return gca[c] = *vp; }
char rv_c_XD(int c) { return gca[c] = vps->c; }
char rv_c_XX(int c) { return gca[c] = vca[c]; }
char rv_c_XE(int c) { return gca[c] = vca[5]; }
char rv_c_XM(int c) { return gca[c] = vs.c; }
char rv_c_QP(int c) { return gp[c] = *vp; }
char rv_c_QD(int c) { return gp[c] = vps->c; }
char rv_c_QX(int c) { return gp[c] = vca[c]; }
char rv_c_QE(int c) { return gp[c] = vca[5]; }
char rv_c_QM(int c) { return gp[c] = vs.c; }

void cv_i_GGP(int c) { gv = (hv = *vpi); }
void cv_i_GGD(int c) { gv = (hv = vps->i); }
void cv_i_GGX(int c) { gv = (hv = via[c]); }
void cv_i_GGE(int c) { gv = (hv = via[5]); }
void cv_i_GMP(int c) { gv = (hs.i = *vpi); }
void cv_i_GMD(int c) { gv = (hs.i = vps->i); }
void cv_i_GMX(int c) { gv = (hs.i = via[c]); }
void cv_i_GME(int c) { gv = (hs.i = via[5]); }
void cv_i_GPP(int c) { gv = (*hpi = *vpi); }
void cv_i_GPD(int c) { gv = (*hpi = vps->i); }
void cv_i_GPX(int c) { gv = (*hpi = via[c]); }
void cv_i_GPE(int c) { gv = (*hpi = via[5]); }
void cv_i_GDP(int c) { gv = (hps->i = *vpi); }
void cv_i_GDD(int c) { gv = (hps->i = vps->i); }
void cv_i_GDX(int c) { gv = (hps->i = via[c]); }
void cv_i_GDE(int c) { gv = (hps->i = via[5]); }
void cv_i_GXP(int c) { gv = (hia[c] = *vpi); }
void cv_i_GXD(int c) { gv = (hia[c] = vps->i); }
void cv_i_GXX(int c) { gv = (hia[c] = via[c]); }
void cv_i_GXE(int c) { gv = (hia[c] = via[5]); }
void cv_i_MGP(int c) { gs.i = (hv = *vpi); }
void cv_i_MGD(int c) { gs.i = (hv = vps->i); }
void cv_i_MGX(int c) { gs.i = (hv = via[c]); }
void cv_i_MGE(int c) { gs.i = (hv = via[5]); }
void cv_i_MMP(int c) { gs.i = (hs.i = *vpi); }
void cv_i_MMD(int c) { gs.i = (hs.i = vps->i); }
void cv_i_MMX(int c) { gs.i = (hs.i = via[c]); }
void cv_i_MME(int c) { gs.i = (hs.i = via[5]); }
void cv_i_MPP(int c) { gs.i = (*hpi = *vpi); }
void cv_i_MPD(int c) { gs.i = (*hpi = vps->i); }
void cv_i_MPX(int c) { gs.i = (*hpi = via[c]); }
void cv_i_MPE(int c) { gs.i = (*hpi = via[5]); }
void cv_i_MDP(int c) { gs.i = (hps->i = *vpi); }
void cv_i_MDD(int c) { gs.i = (hps->i = vps->i); }
void cv_i_MDX(int c) { gs.i = (hps->i = via[c]); }
void cv_i_MDE(int c) { gs.i = (hps->i = via[5]); }
void cv_i_MXP(int c) { gs.i = (hia[c] = *vpi); }
void cv_i_MXD(int c) { gs.i = (hia[c] = vps->i); }
void cv_i_MXX(int c) { gs.i = (hia[c] = via[c]); }
void cv_i_MXE(int c) { gs.i = (hia[c] = via[5]); }
void cv_i_PGP(int c) { *gpi = (hv = *vpi); }
void cv_i_PGD(int c) { *gpi = (hv = vps->i); }
void cv_i_PGX(int c) { *gpi = (hv = via[c]); }
void cv_i_PGE(int c) { *gpi = (hv = via[5]); }
void cv_i_PMP(int c) { *gpi = (hs.i = *vpi); }
void cv_i_PMD(int c) { *gpi = (hs.i = vps->i); }
void cv_i_PMX(int c) { *gpi = (hs.i = via[c]); }
void cv_i_PME(int c) { *gpi = (hs.i = via[5]); }
void cv_i_PPP(int c) { *gpi = (*hpi = *vpi); }
void cv_i_PPD(int c) { *gpi = (*hpi = vps->i); }
void cv_i_PPX(int c) { *gpi = (*hpi = via[c]); }
void cv_i_PPE(int c) { *gpi = (*hpi = via[5]); }
void cv_i_PDP(int c) { *gpi = (hps->i = *vpi); }
void cv_i_PDD(int c) { *gpi = (hps->i = vps->i); }
void cv_i_PDX(int c) { *gpi = (hps->i = via[c]); }
void cv_i_PDE(int c) { *gpi = (hps->i = via[5]); }
void cv_i_PXP(int c) { *gpi = (hia[c] = *vpi); }
void cv_i_PXD(int c) { *gpi = (hia[c] = vps->i); }
void cv_i_PXX(int c) { *gpi = (hia[c] = via[c]); }
void cv_i_PXE(int c) { *gpi = (hia[c] = via[5]); }
void cv_i_DGP(int c) { gps->i = (hv = *vpi); }
void cv_i_DGD(int c) { gps->i = (hv = vps->i); }
void cv_i_DGX(int c) { gps->i = (hv = via[c]); }
void cv_i_DGE(int c) { gps->i = (hv = via[5]); }
void cv_i_DMP(int c) { gps->i = (hs.i = *vpi); }
void cv_i_DMD(int c) { gps->i = (hs.i = vps->i); }
void cv_i_DMX(int c) { gps->i = (hs.i = via[c]); }
void cv_i_DME(int c) { gps->i = (hs.i = via[5]); }
void cv_i_DPP(int c) { gps->i = (*hpi = *vpi); }
void cv_i_DPD(int c) { gps->i = (*hpi = vps->i); }
void cv_i_DPX(int c) { gps->i = (*hpi = via[c]); }
void cv_i_DPE(int c) { gps->i = (*hpi = via[5]); }
void cv_i_DDP(int c) { gps->i = (hps->i = *vpi); }
void cv_i_DDD(int c) { gps->i = (hps->i = vps->i); }
void cv_i_DDX(int c) { gps->i = (hps->i = via[c]); }
void cv_i_DDE(int c) { gps->i = (hps->i = via[5]); }
void cv_i_DXP(int c) { gps->i = (hia[c] = *vpi); }
void cv_i_DXD(int c) { gps->i = (hia[c] = vps->i); }
void cv_i_DXX(int c) { gps->i = (hia[c] = via[c]); }
void cv_i_DXE(int c) { gps->i = (hia[c] = via[5]); }
void cv_i_EGP(int c) { gia[3] = (hv = *vpi); }
void cv_i_EGD(int c) { gia[3] = (hv = vps->i); }
void cv_i_EGX(int c) { gia[3] = (hv = via[c]); }
void cv_i_EGE(int c) { gia[3] = (hv = via[5]); }
void cv_i_EMP(int c) { gia[3] = (hs.i = *vpi); }
void cv_i_EMD(int c) { gia[3] = (hs.i = vps->i); }
void cv_i_EMX(int c) { gia[3] = (hs.i = via[c]); }
void cv_i_EME(int c) { gia[3] = (hs.i = via[5]); }
void cv_i_EPP(int c) { gia[3] = (*hpi = *vpi); }
void cv_i_EPD(int c) { gia[3] = (*hpi = vps->i); }
void cv_i_EPX(int c) { gia[3] = (*hpi = via[c]); }
void cv_i_EPE(int c) { gia[3] = (*hpi = via[5]); }
void cv_i_EDP(int c) { gia[3] = (hps->i = *vpi); }
void cv_i_EDD(int c) { gia[3] = (hps->i = vps->i); }
void cv_i_EDX(int c) { gia[3] = (hps->i = via[c]); }
void cv_i_EDE(int c) { gia[3] = (hps->i = via[5]); }
void cv_i_EXP(int c) { gia[3] = (hia[c] = *vpi); }
void cv_i_EXD(int c) { gia[3] = (hia[c] = vps->i); }
void cv_i_EXX(int c) { gia[3] = (hia[c] = via[c]); }
void cv_i_EXE(int c) { gia[3] = (hia[c] = via[5]); }
void cv_i_XGP(int c) { gia[c] = (hv = *vpi); }
void cv_i_XGD(int c) { gia[c] = (hv = vps->i); }
void cv_i_XGX(int c) { gia[c] = (hv = via[c]); }
void cv_i_XGE(int c) { gia[c] = (hv = via[5]); }
void cv_i_XMP(int c) { gia[c] = (hs.i = *vpi); }
void cv_i_XMD(int c) { gia[c] = (hs.i = vps->i); }
void cv_i_XMX(int c) { gia[c] = (hs.i = via[c]); }
void cv_i_XME(int c) { gia[c] = (hs.i = via[5]); }
void cv_i_XPP(int c) { gia[c] = (*hpi = *vpi); }
void cv_i_XPD(int c) { gia[c] = (*hpi = vps->i); }
void cv_i_XPX(int c) { gia[c] = (*hpi = via[c]); }
void cv_i_XPE(int c) { gia[c] = (*hpi = via[5]); }
void cv_i_XDP(int c) { gia[c] = (hps->i = *vpi); }
void cv_i_XDD(int c) { gia[c] = (hps->i = vps->i); }
void cv_i_XDX(int c) { gia[c] = (hps->i = via[c]); }
void cv_i_XDE(int c) { gia[c] = (hps->i = via[5]); }

