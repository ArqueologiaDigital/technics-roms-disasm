/* Statement stores of a computed value that reads through an address (gen_stvx.py): sx_<t>_<L><V>(b, c) for
   char / int / long.  L: G global, M static member, P deref, D member through a pointer, E constant element,
   X element at c, Q pointer element at c.  V: D h - vps->m, P *vp + h, X va[b] | 5, Y h ^ va[b], E va[5] & h,
   S vs.m >> (b & 7).  sp_<L><V>: char pointer stores, L: G gp, M gs.p, D gps->p; V: A &vca[b], S vs.p + b,
   D vps->p. */
struct st { char c; int i; long l; char *p; int a[4]; };
extern int gv, hv; extern long gl, hl; extern char gc, hc;
extern int gia[8], via[8]; extern long gla[8], vla[8]; extern char gca[8], vca[8];
extern int *gpi, *vpi; extern long *gpl, *vpl; extern char *gp, *vp;
extern struct st gs, vs, *gps, *vps;

void sx_i_GD(int b, int c) { gv = hv - vps->i; }
void sx_i_GP(int b, int c) { gv = *vpi + hv; }
void sx_i_GX(int b, int c) { gv = via[b] | 5; }
void sx_i_GY(int b, int c) { gv = hv ^ via[b]; }
void sx_i_GE(int b, int c) { gv = via[5] & hv; }
void sx_i_GS(int b, int c) { gv = vs.i >> (b & 7); }
void sx_i_MD(int b, int c) { gs.i = hv - vps->i; }
void sx_i_MP(int b, int c) { gs.i = *vpi + hv; }
void sx_i_MX(int b, int c) { gs.i = via[b] | 5; }
void sx_i_MY(int b, int c) { gs.i = hv ^ via[b]; }
void sx_i_ME(int b, int c) { gs.i = via[5] & hv; }
void sx_i_MS(int b, int c) { gs.i = vs.i >> (b & 7); }
void sx_i_PD(int b, int c) { *gpi = hv - vps->i; }
void sx_i_PP(int b, int c) { *gpi = *vpi + hv; }
void sx_i_PX(int b, int c) { *gpi = via[b] | 5; }
void sx_i_PY(int b, int c) { *gpi = hv ^ via[b]; }
void sx_i_PE(int b, int c) { *gpi = via[5] & hv; }
void sx_i_PS(int b, int c) { *gpi = vs.i >> (b & 7); }
void sx_i_DD(int b, int c) { gps->i = hv - vps->i; }
void sx_i_DP(int b, int c) { gps->i = *vpi + hv; }
void sx_i_DX(int b, int c) { gps->i = via[b] | 5; }
void sx_i_DY(int b, int c) { gps->i = hv ^ via[b]; }
void sx_i_DE(int b, int c) { gps->i = via[5] & hv; }
void sx_i_DS(int b, int c) { gps->i = vs.i >> (b & 7); }
void sx_i_ED(int b, int c) { gia[3] = hv - vps->i; }
void sx_i_EP(int b, int c) { gia[3] = *vpi + hv; }
void sx_i_EX(int b, int c) { gia[3] = via[b] | 5; }
void sx_i_EY(int b, int c) { gia[3] = hv ^ via[b]; }
void sx_i_EE(int b, int c) { gia[3] = via[5] & hv; }
void sx_i_ES(int b, int c) { gia[3] = vs.i >> (b & 7); }
void sx_i_XD(int b, int c) { gia[c] = hv - vps->i; }
void sx_i_XP(int b, int c) { gia[c] = *vpi + hv; }
void sx_i_XX(int b, int c) { gia[c] = via[b] | 5; }
void sx_i_XY(int b, int c) { gia[c] = hv ^ via[b]; }
void sx_i_XE(int b, int c) { gia[c] = via[5] & hv; }
void sx_i_XS(int b, int c) { gia[c] = vs.i >> (b & 7); }
void sx_i_QD(int b, int c) { gpi[c] = hv - vps->i; }
void sx_i_QP(int b, int c) { gpi[c] = *vpi + hv; }
void sx_i_QX(int b, int c) { gpi[c] = via[b] | 5; }
void sx_i_QY(int b, int c) { gpi[c] = hv ^ via[b]; }
void sx_i_QE(int b, int c) { gpi[c] = via[5] & hv; }
void sx_i_QS(int b, int c) { gpi[c] = vs.i >> (b & 7); }

void sx_l_GD(int b, int c) { gl = hl - vps->l; }
void sx_l_GP(int b, int c) { gl = *vpl + hl; }
void sx_l_GX(int b, int c) { gl = vla[b] | 5L; }
void sx_l_GY(int b, int c) { gl = hl ^ vla[b]; }
void sx_l_GE(int b, int c) { gl = vla[5] & hl; }
void sx_l_GS(int b, int c) { gl = vs.l >> (b & 7); }
void sx_l_MD(int b, int c) { gs.l = hl - vps->l; }
void sx_l_MP(int b, int c) { gs.l = *vpl + hl; }
void sx_l_MX(int b, int c) { gs.l = vla[b] | 5L; }
void sx_l_MY(int b, int c) { gs.l = hl ^ vla[b]; }
void sx_l_ME(int b, int c) { gs.l = vla[5] & hl; }
void sx_l_MS(int b, int c) { gs.l = vs.l >> (b & 7); }
void sx_l_PD(int b, int c) { *gpl = hl - vps->l; }
void sx_l_PP(int b, int c) { *gpl = *vpl + hl; }
void sx_l_PX(int b, int c) { *gpl = vla[b] | 5L; }
void sx_l_PY(int b, int c) { *gpl = hl ^ vla[b]; }
void sx_l_PE(int b, int c) { *gpl = vla[5] & hl; }
void sx_l_PS(int b, int c) { *gpl = vs.l >> (b & 7); }
void sx_l_DD(int b, int c) { gps->l = hl - vps->l; }
void sx_l_DP(int b, int c) { gps->l = *vpl + hl; }
void sx_l_DX(int b, int c) { gps->l = vla[b] | 5L; }
void sx_l_DY(int b, int c) { gps->l = hl ^ vla[b]; }
void sx_l_DE(int b, int c) { gps->l = vla[5] & hl; }
void sx_l_DS(int b, int c) { gps->l = vs.l >> (b & 7); }
void sx_l_ED(int b, int c) { gla[3] = hl - vps->l; }
void sx_l_EP(int b, int c) { gla[3] = *vpl + hl; }
void sx_l_EX(int b, int c) { gla[3] = vla[b] | 5L; }
void sx_l_EY(int b, int c) { gla[3] = hl ^ vla[b]; }
void sx_l_EE(int b, int c) { gla[3] = vla[5] & hl; }
void sx_l_ES(int b, int c) { gla[3] = vs.l >> (b & 7); }
void sx_l_XD(int b, int c) { gla[c] = hl - vps->l; }
void sx_l_XP(int b, int c) { gla[c] = *vpl + hl; }
void sx_l_XX(int b, int c) { gla[c] = vla[b] | 5L; }
void sx_l_XY(int b, int c) { gla[c] = hl ^ vla[b]; }
void sx_l_XE(int b, int c) { gla[c] = vla[5] & hl; }
void sx_l_XS(int b, int c) { gla[c] = vs.l >> (b & 7); }
void sx_l_QD(int b, int c) { gpl[c] = hl - vps->l; }
void sx_l_QP(int b, int c) { gpl[c] = *vpl + hl; }
void sx_l_QX(int b, int c) { gpl[c] = vla[b] | 5L; }
void sx_l_QY(int b, int c) { gpl[c] = hl ^ vla[b]; }
void sx_l_QE(int b, int c) { gpl[c] = vla[5] & hl; }
void sx_l_QS(int b, int c) { gpl[c] = vs.l >> (b & 7); }

void sx_c_GD(int b, int c) { gc = (char)((int)hc - (int)vps->c); }
void sx_c_GP(int b, int c) { gc = (char)((int)*vp + (int)hc); }
void sx_c_GX(int b, int c) { gc = (char)((int)vca[b] | (int)5); }
void sx_c_GY(int b, int c) { gc = (char)((int)hc ^ (int)vca[b]); }
void sx_c_GE(int b, int c) { gc = (char)((int)vca[5] & (int)hc); }
void sx_c_GS(int b, int c) { gc = (char)((int)vs.c >> (b & 7)); }
void sx_c_MD(int b, int c) { gs.c = (char)((int)hc - (int)vps->c); }
void sx_c_MP(int b, int c) { gs.c = (char)((int)*vp + (int)hc); }
void sx_c_MX(int b, int c) { gs.c = (char)((int)vca[b] | (int)5); }
void sx_c_MY(int b, int c) { gs.c = (char)((int)hc ^ (int)vca[b]); }
void sx_c_ME(int b, int c) { gs.c = (char)((int)vca[5] & (int)hc); }
void sx_c_MS(int b, int c) { gs.c = (char)((int)vs.c >> (b & 7)); }
void sx_c_PD(int b, int c) { *gp = (char)((int)hc - (int)vps->c); }
void sx_c_PP(int b, int c) { *gp = (char)((int)*vp + (int)hc); }
void sx_c_PX(int b, int c) { *gp = (char)((int)vca[b] | (int)5); }
void sx_c_PY(int b, int c) { *gp = (char)((int)hc ^ (int)vca[b]); }
void sx_c_PE(int b, int c) { *gp = (char)((int)vca[5] & (int)hc); }
void sx_c_PS(int b, int c) { *gp = (char)((int)vs.c >> (b & 7)); }
void sx_c_DD(int b, int c) { gps->c = (char)((int)hc - (int)vps->c); }
void sx_c_DP(int b, int c) { gps->c = (char)((int)*vp + (int)hc); }
void sx_c_DX(int b, int c) { gps->c = (char)((int)vca[b] | (int)5); }
void sx_c_DY(int b, int c) { gps->c = (char)((int)hc ^ (int)vca[b]); }
void sx_c_DE(int b, int c) { gps->c = (char)((int)vca[5] & (int)hc); }
void sx_c_DS(int b, int c) { gps->c = (char)((int)vs.c >> (b & 7)); }
void sx_c_ED(int b, int c) { gca[3] = (char)((int)hc - (int)vps->c); }
void sx_c_EP(int b, int c) { gca[3] = (char)((int)*vp + (int)hc); }
void sx_c_EX(int b, int c) { gca[3] = (char)((int)vca[b] | (int)5); }
void sx_c_EY(int b, int c) { gca[3] = (char)((int)hc ^ (int)vca[b]); }
void sx_c_EE(int b, int c) { gca[3] = (char)((int)vca[5] & (int)hc); }
void sx_c_ES(int b, int c) { gca[3] = (char)((int)vs.c >> (b & 7)); }
void sx_c_XD(int b, int c) { gca[c] = (char)((int)hc - (int)vps->c); }
void sx_c_XP(int b, int c) { gca[c] = (char)((int)*vp + (int)hc); }
void sx_c_XX(int b, int c) { gca[c] = (char)((int)vca[b] | (int)5); }
void sx_c_XY(int b, int c) { gca[c] = (char)((int)hc ^ (int)vca[b]); }
void sx_c_XE(int b, int c) { gca[c] = (char)((int)vca[5] & (int)hc); }
void sx_c_XS(int b, int c) { gca[c] = (char)((int)vs.c >> (b & 7)); }
void sx_c_QD(int b, int c) { gp[c] = (char)((int)hc - (int)vps->c); }
void sx_c_QP(int b, int c) { gp[c] = (char)((int)*vp + (int)hc); }
void sx_c_QX(int b, int c) { gp[c] = (char)((int)vca[b] | (int)5); }
void sx_c_QY(int b, int c) { gp[c] = (char)((int)hc ^ (int)vca[b]); }
void sx_c_QE(int b, int c) { gp[c] = (char)((int)vca[5] & (int)hc); }
void sx_c_QS(int b, int c) { gp[c] = (char)((int)vs.c >> (b & 7)); }

void sp_GA(int b, int c) { gp = &vca[b]; }
void sp_GS(int b, int c) { gp = vs.p + b; }
void sp_GD(int b, int c) { gp = vps->p; }
void sp_MA(int b, int c) { gs.p = &vca[b]; }
void sp_MS(int b, int c) { gs.p = vs.p + b; }
void sp_MD(int b, int c) { gs.p = vps->p; }
void sp_DA(int b, int c) { gps->p = &vca[b]; }
void sp_DS(int b, int c) { gps->p = vs.p + b; }
void sp_DD(int b, int c) { gps->p = vps->p; }

