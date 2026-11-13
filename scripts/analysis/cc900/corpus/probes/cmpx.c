/* Compare operands of the "complex compare operand" refusals (gen_cmpx.py); the family and name letters are in the
   generator's docstring.  Types: c char, b unsigned char, i int, u unsigned int, l long, n unsigned long. */
struct sv {
	char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn;
	char ac[8]; unsigned char ab[8]; int ai[8]; unsigned int au[8]; long al[8]; unsigned long an[8];
};
extern struct sv gs, hs, *gps, *hps;
extern int gi2, gi3;
extern char gc, hc, kc, gca[8], hca[8], *gcp, *hcp;
extern unsigned char gb, hb, kb, gba[8], hba[8], *gbp, *hbp;
extern int gi, hi, ki, gia[8], hia[8], *gip, *hip;
extern unsigned int gu, hu, ku, gua[8], hua[8], *gup, *hup;
extern long gl, hl, kl, gla[8], hla[8], *glp, *hlp;
extern unsigned long gn, hn, kn, gna[8], hna[8], *gnp, *hnp;
extern char grc(char);
extern unsigned char grb(unsigned char);
extern int gri(int);
extern unsigned int gru(unsigned int);
extern long grl(long);
extern unsigned long grn(unsigned long);

void cx_l_c_GXc(char c) { if (gc < hca[c]) gi3 = 1; }
void cx_l_c_GXb(unsigned char c) { if (gc < hca[c]) gi3 = 1; }
void cx_l_c_GXi(int c) { if (gc < hca[c]) gi3 = 1; }
void cx_l_c_GXu(unsigned int c) { if (gc < hca[c]) gi3 = 1; }
void cx_l_c_GYc(int c) { char v = gc; if (gc < hca[v]) gi3 = 1; }
void cx_l_c_GYb(int c) { unsigned char v = gb; if (gc < hca[v]) gi3 = 1; }
void cx_l_c_GYi(int c) { int v = gi; if (gc < hca[v]) gi3 = 1; }
void cx_l_c_GYu(int c) { unsigned int v = gu; if (gc < hca[v]) gi3 = 1; }
void cx_l_c_RXc(char r, char c) { if (r < hca[c]) gi3 = 1; }
void cx_l_c_RXb(char r, unsigned char c) { if (r < hca[c]) gi3 = 1; }
void cx_l_c_RXi(char r, int c) { if (r < hca[c]) gi3 = 1; }
void cx_l_c_RXu(char r, unsigned int c) { if (r < hca[c]) gi3 = 1; }
void cx_l_c_RYc(char r, int c) { char v = gc; if (r < hca[v]) gi3 = 1; }
void cx_l_c_RYb(char r, int c) { unsigned char v = gb; if (r < hca[v]) gi3 = 1; }
void cx_l_c_RYi(char r, int c) { int v = gi; if (r < hca[v]) gi3 = 1; }
void cx_l_c_RYu(char r, int c) { unsigned int v = gu; if (r < hca[v]) gi3 = 1; }
void cx_l_c_DXc(char c) { if (gps->mc < hca[c]) gi3 = 1; }
void cx_l_c_DXb(unsigned char c) { if (gps->mc < hca[c]) gi3 = 1; }
void cx_l_c_DXi(int c) { if (gps->mc < hca[c]) gi3 = 1; }
void cx_l_c_DXu(unsigned int c) { if (gps->mc < hca[c]) gi3 = 1; }
void cx_l_c_DYc(int c) { char v = gc; if (gps->mc < hca[v]) gi3 = 1; }
void cx_l_c_DYb(int c) { unsigned char v = gb; if (gps->mc < hca[v]) gi3 = 1; }
void cx_l_c_DYi(int c) { int v = gi; if (gps->mc < hca[v]) gi3 = 1; }
void cx_l_c_DYu(int c) { unsigned int v = gu; if (gps->mc < hca[v]) gi3 = 1; }
void cx_l_c_EXc(char c) { if (gca[3] < hca[c]) gi3 = 1; }
void cx_l_c_EXb(unsigned char c) { if (gca[3] < hca[c]) gi3 = 1; }
void cx_l_c_EXi(int c) { if (gca[3] < hca[c]) gi3 = 1; }
void cx_l_c_EXu(unsigned int c) { if (gca[3] < hca[c]) gi3 = 1; }
void cx_l_c_EYc(int c) { char v = gc; if (gca[3] < hca[v]) gi3 = 1; }
void cx_l_c_EYb(int c) { unsigned char v = gb; if (gca[3] < hca[v]) gi3 = 1; }
void cx_l_c_EYi(int c) { int v = gi; if (gca[3] < hca[v]) gi3 = 1; }
void cx_l_c_EYu(int c) { unsigned int v = gu; if (gca[3] < hca[v]) gi3 = 1; }
void cx_e_c_GXc(char c) { if (gc == hca[c]) gi3 = 1; }
void cx_e_c_GXb(unsigned char c) { if (gc == hca[c]) gi3 = 1; }
void cx_e_c_GXi(int c) { if (gc == hca[c]) gi3 = 1; }
void cx_e_c_GXu(unsigned int c) { if (gc == hca[c]) gi3 = 1; }
void cx_e_c_GYc(int c) { char v = gc; if (gc == hca[v]) gi3 = 1; }
void cx_e_c_GYb(int c) { unsigned char v = gb; if (gc == hca[v]) gi3 = 1; }
void cx_e_c_GYi(int c) { int v = gi; if (gc == hca[v]) gi3 = 1; }
void cx_e_c_GYu(int c) { unsigned int v = gu; if (gc == hca[v]) gi3 = 1; }
void cx_e_c_RXc(char r, char c) { if (r == hca[c]) gi3 = 1; }
void cx_e_c_RXb(char r, unsigned char c) { if (r == hca[c]) gi3 = 1; }
void cx_e_c_RXi(char r, int c) { if (r == hca[c]) gi3 = 1; }
void cx_e_c_RXu(char r, unsigned int c) { if (r == hca[c]) gi3 = 1; }
void cx_e_c_RYc(char r, int c) { char v = gc; if (r == hca[v]) gi3 = 1; }
void cx_e_c_RYb(char r, int c) { unsigned char v = gb; if (r == hca[v]) gi3 = 1; }
void cx_e_c_RYi(char r, int c) { int v = gi; if (r == hca[v]) gi3 = 1; }
void cx_e_c_RYu(char r, int c) { unsigned int v = gu; if (r == hca[v]) gi3 = 1; }
void cx_e_c_DXc(char c) { if (gps->mc == hca[c]) gi3 = 1; }
void cx_e_c_DXb(unsigned char c) { if (gps->mc == hca[c]) gi3 = 1; }
void cx_e_c_DXi(int c) { if (gps->mc == hca[c]) gi3 = 1; }
void cx_e_c_DXu(unsigned int c) { if (gps->mc == hca[c]) gi3 = 1; }
void cx_e_c_DYc(int c) { char v = gc; if (gps->mc == hca[v]) gi3 = 1; }
void cx_e_c_DYb(int c) { unsigned char v = gb; if (gps->mc == hca[v]) gi3 = 1; }
void cx_e_c_DYi(int c) { int v = gi; if (gps->mc == hca[v]) gi3 = 1; }
void cx_e_c_DYu(int c) { unsigned int v = gu; if (gps->mc == hca[v]) gi3 = 1; }
void cx_e_c_EXc(char c) { if (gca[3] == hca[c]) gi3 = 1; }
void cx_e_c_EXb(unsigned char c) { if (gca[3] == hca[c]) gi3 = 1; }
void cx_e_c_EXi(int c) { if (gca[3] == hca[c]) gi3 = 1; }
void cx_e_c_EXu(unsigned int c) { if (gca[3] == hca[c]) gi3 = 1; }
void cx_e_c_EYc(int c) { char v = gc; if (gca[3] == hca[v]) gi3 = 1; }
void cx_e_c_EYb(int c) { unsigned char v = gb; if (gca[3] == hca[v]) gi3 = 1; }
void cx_e_c_EYi(int c) { int v = gi; if (gca[3] == hca[v]) gi3 = 1; }
void cx_e_c_EYu(int c) { unsigned int v = gu; if (gca[3] == hca[v]) gi3 = 1; }

void cx_l_b_GXc(char c) { if (gb < hba[c]) gi3 = 1; }
void cx_l_b_GXb(unsigned char c) { if (gb < hba[c]) gi3 = 1; }
void cx_l_b_GXi(int c) { if (gb < hba[c]) gi3 = 1; }
void cx_l_b_GXu(unsigned int c) { if (gb < hba[c]) gi3 = 1; }
void cx_l_b_GYc(int c) { char v = gc; if (gb < hba[v]) gi3 = 1; }
void cx_l_b_GYb(int c) { unsigned char v = gb; if (gb < hba[v]) gi3 = 1; }
void cx_l_b_GYi(int c) { int v = gi; if (gb < hba[v]) gi3 = 1; }
void cx_l_b_GYu(int c) { unsigned int v = gu; if (gb < hba[v]) gi3 = 1; }
void cx_l_b_RXc(unsigned char r, char c) { if (r < hba[c]) gi3 = 1; }
void cx_l_b_RXb(unsigned char r, unsigned char c) { if (r < hba[c]) gi3 = 1; }
void cx_l_b_RXi(unsigned char r, int c) { if (r < hba[c]) gi3 = 1; }
void cx_l_b_RXu(unsigned char r, unsigned int c) { if (r < hba[c]) gi3 = 1; }
void cx_l_b_RYc(unsigned char r, int c) { char v = gc; if (r < hba[v]) gi3 = 1; }
void cx_l_b_RYb(unsigned char r, int c) { unsigned char v = gb; if (r < hba[v]) gi3 = 1; }
void cx_l_b_RYi(unsigned char r, int c) { int v = gi; if (r < hba[v]) gi3 = 1; }
void cx_l_b_RYu(unsigned char r, int c) { unsigned int v = gu; if (r < hba[v]) gi3 = 1; }
void cx_l_b_DXc(char c) { if (gps->mb < hba[c]) gi3 = 1; }
void cx_l_b_DXb(unsigned char c) { if (gps->mb < hba[c]) gi3 = 1; }
void cx_l_b_DXi(int c) { if (gps->mb < hba[c]) gi3 = 1; }
void cx_l_b_DXu(unsigned int c) { if (gps->mb < hba[c]) gi3 = 1; }
void cx_l_b_DYc(int c) { char v = gc; if (gps->mb < hba[v]) gi3 = 1; }
void cx_l_b_DYb(int c) { unsigned char v = gb; if (gps->mb < hba[v]) gi3 = 1; }
void cx_l_b_DYi(int c) { int v = gi; if (gps->mb < hba[v]) gi3 = 1; }
void cx_l_b_DYu(int c) { unsigned int v = gu; if (gps->mb < hba[v]) gi3 = 1; }
void cx_l_b_EXc(char c) { if (gba[3] < hba[c]) gi3 = 1; }
void cx_l_b_EXb(unsigned char c) { if (gba[3] < hba[c]) gi3 = 1; }
void cx_l_b_EXi(int c) { if (gba[3] < hba[c]) gi3 = 1; }
void cx_l_b_EXu(unsigned int c) { if (gba[3] < hba[c]) gi3 = 1; }
void cx_l_b_EYc(int c) { char v = gc; if (gba[3] < hba[v]) gi3 = 1; }
void cx_l_b_EYb(int c) { unsigned char v = gb; if (gba[3] < hba[v]) gi3 = 1; }
void cx_l_b_EYi(int c) { int v = gi; if (gba[3] < hba[v]) gi3 = 1; }
void cx_l_b_EYu(int c) { unsigned int v = gu; if (gba[3] < hba[v]) gi3 = 1; }
void cx_e_b_GXc(char c) { if (gb == hba[c]) gi3 = 1; }
void cx_e_b_GXb(unsigned char c) { if (gb == hba[c]) gi3 = 1; }
void cx_e_b_GXi(int c) { if (gb == hba[c]) gi3 = 1; }
void cx_e_b_GXu(unsigned int c) { if (gb == hba[c]) gi3 = 1; }
void cx_e_b_GYc(int c) { char v = gc; if (gb == hba[v]) gi3 = 1; }
void cx_e_b_GYb(int c) { unsigned char v = gb; if (gb == hba[v]) gi3 = 1; }
void cx_e_b_GYi(int c) { int v = gi; if (gb == hba[v]) gi3 = 1; }
void cx_e_b_GYu(int c) { unsigned int v = gu; if (gb == hba[v]) gi3 = 1; }
void cx_e_b_RXc(unsigned char r, char c) { if (r == hba[c]) gi3 = 1; }
void cx_e_b_RXb(unsigned char r, unsigned char c) { if (r == hba[c]) gi3 = 1; }
void cx_e_b_RXi(unsigned char r, int c) { if (r == hba[c]) gi3 = 1; }
void cx_e_b_RXu(unsigned char r, unsigned int c) { if (r == hba[c]) gi3 = 1; }
void cx_e_b_RYc(unsigned char r, int c) { char v = gc; if (r == hba[v]) gi3 = 1; }
void cx_e_b_RYb(unsigned char r, int c) { unsigned char v = gb; if (r == hba[v]) gi3 = 1; }
void cx_e_b_RYi(unsigned char r, int c) { int v = gi; if (r == hba[v]) gi3 = 1; }
void cx_e_b_RYu(unsigned char r, int c) { unsigned int v = gu; if (r == hba[v]) gi3 = 1; }
void cx_e_b_DXc(char c) { if (gps->mb == hba[c]) gi3 = 1; }
void cx_e_b_DXb(unsigned char c) { if (gps->mb == hba[c]) gi3 = 1; }
void cx_e_b_DXi(int c) { if (gps->mb == hba[c]) gi3 = 1; }
void cx_e_b_DXu(unsigned int c) { if (gps->mb == hba[c]) gi3 = 1; }
void cx_e_b_DYc(int c) { char v = gc; if (gps->mb == hba[v]) gi3 = 1; }
void cx_e_b_DYb(int c) { unsigned char v = gb; if (gps->mb == hba[v]) gi3 = 1; }
void cx_e_b_DYi(int c) { int v = gi; if (gps->mb == hba[v]) gi3 = 1; }
void cx_e_b_DYu(int c) { unsigned int v = gu; if (gps->mb == hba[v]) gi3 = 1; }
void cx_e_b_EXc(char c) { if (gba[3] == hba[c]) gi3 = 1; }
void cx_e_b_EXb(unsigned char c) { if (gba[3] == hba[c]) gi3 = 1; }
void cx_e_b_EXi(int c) { if (gba[3] == hba[c]) gi3 = 1; }
void cx_e_b_EXu(unsigned int c) { if (gba[3] == hba[c]) gi3 = 1; }
void cx_e_b_EYc(int c) { char v = gc; if (gba[3] == hba[v]) gi3 = 1; }
void cx_e_b_EYb(int c) { unsigned char v = gb; if (gba[3] == hba[v]) gi3 = 1; }
void cx_e_b_EYi(int c) { int v = gi; if (gba[3] == hba[v]) gi3 = 1; }
void cx_e_b_EYu(int c) { unsigned int v = gu; if (gba[3] == hba[v]) gi3 = 1; }

void cx_l_i_GXc(char c) { if (gi < hia[c]) gi3 = 1; }
void cx_l_i_GXb(unsigned char c) { if (gi < hia[c]) gi3 = 1; }
void cx_l_i_GXi(int c) { if (gi < hia[c]) gi3 = 1; }
void cx_l_i_GXu(unsigned int c) { if (gi < hia[c]) gi3 = 1; }
void cx_l_i_GYc(int c) { char v = gc; if (gi < hia[v]) gi3 = 1; }
void cx_l_i_GYb(int c) { unsigned char v = gb; if (gi < hia[v]) gi3 = 1; }
void cx_l_i_GYi(int c) { int v = gi; if (gi < hia[v]) gi3 = 1; }
void cx_l_i_GYu(int c) { unsigned int v = gu; if (gi < hia[v]) gi3 = 1; }
void cx_l_i_RXc(int r, char c) { if (r < hia[c]) gi3 = 1; }
void cx_l_i_RXb(int r, unsigned char c) { if (r < hia[c]) gi3 = 1; }
void cx_l_i_RXi(int r, int c) { if (r < hia[c]) gi3 = 1; }
void cx_l_i_RXu(int r, unsigned int c) { if (r < hia[c]) gi3 = 1; }
void cx_l_i_RYc(int r, int c) { char v = gc; if (r < hia[v]) gi3 = 1; }
void cx_l_i_RYb(int r, int c) { unsigned char v = gb; if (r < hia[v]) gi3 = 1; }
void cx_l_i_RYi(int r, int c) { int v = gi; if (r < hia[v]) gi3 = 1; }
void cx_l_i_RYu(int r, int c) { unsigned int v = gu; if (r < hia[v]) gi3 = 1; }
void cx_l_i_DXc(char c) { if (gps->mi < hia[c]) gi3 = 1; }
void cx_l_i_DXb(unsigned char c) { if (gps->mi < hia[c]) gi3 = 1; }
void cx_l_i_DXi(int c) { if (gps->mi < hia[c]) gi3 = 1; }
void cx_l_i_DXu(unsigned int c) { if (gps->mi < hia[c]) gi3 = 1; }
void cx_l_i_DYc(int c) { char v = gc; if (gps->mi < hia[v]) gi3 = 1; }
void cx_l_i_DYb(int c) { unsigned char v = gb; if (gps->mi < hia[v]) gi3 = 1; }
void cx_l_i_DYi(int c) { int v = gi; if (gps->mi < hia[v]) gi3 = 1; }
void cx_l_i_DYu(int c) { unsigned int v = gu; if (gps->mi < hia[v]) gi3 = 1; }
void cx_l_i_EXc(char c) { if (gia[3] < hia[c]) gi3 = 1; }
void cx_l_i_EXb(unsigned char c) { if (gia[3] < hia[c]) gi3 = 1; }
void cx_l_i_EXi(int c) { if (gia[3] < hia[c]) gi3 = 1; }
void cx_l_i_EXu(unsigned int c) { if (gia[3] < hia[c]) gi3 = 1; }
void cx_l_i_EYc(int c) { char v = gc; if (gia[3] < hia[v]) gi3 = 1; }
void cx_l_i_EYb(int c) { unsigned char v = gb; if (gia[3] < hia[v]) gi3 = 1; }
void cx_l_i_EYi(int c) { int v = gi; if (gia[3] < hia[v]) gi3 = 1; }
void cx_l_i_EYu(int c) { unsigned int v = gu; if (gia[3] < hia[v]) gi3 = 1; }
void cx_e_i_GXc(char c) { if (gi == hia[c]) gi3 = 1; }
void cx_e_i_GXb(unsigned char c) { if (gi == hia[c]) gi3 = 1; }
void cx_e_i_GXi(int c) { if (gi == hia[c]) gi3 = 1; }
void cx_e_i_GXu(unsigned int c) { if (gi == hia[c]) gi3 = 1; }
void cx_e_i_GYc(int c) { char v = gc; if (gi == hia[v]) gi3 = 1; }
void cx_e_i_GYb(int c) { unsigned char v = gb; if (gi == hia[v]) gi3 = 1; }
void cx_e_i_GYi(int c) { int v = gi; if (gi == hia[v]) gi3 = 1; }
void cx_e_i_GYu(int c) { unsigned int v = gu; if (gi == hia[v]) gi3 = 1; }
void cx_e_i_RXc(int r, char c) { if (r == hia[c]) gi3 = 1; }
void cx_e_i_RXb(int r, unsigned char c) { if (r == hia[c]) gi3 = 1; }
void cx_e_i_RXi(int r, int c) { if (r == hia[c]) gi3 = 1; }
void cx_e_i_RXu(int r, unsigned int c) { if (r == hia[c]) gi3 = 1; }
void cx_e_i_RYc(int r, int c) { char v = gc; if (r == hia[v]) gi3 = 1; }
void cx_e_i_RYb(int r, int c) { unsigned char v = gb; if (r == hia[v]) gi3 = 1; }
void cx_e_i_RYi(int r, int c) { int v = gi; if (r == hia[v]) gi3 = 1; }
void cx_e_i_RYu(int r, int c) { unsigned int v = gu; if (r == hia[v]) gi3 = 1; }
void cx_e_i_DXc(char c) { if (gps->mi == hia[c]) gi3 = 1; }
void cx_e_i_DXb(unsigned char c) { if (gps->mi == hia[c]) gi3 = 1; }
void cx_e_i_DXi(int c) { if (gps->mi == hia[c]) gi3 = 1; }
void cx_e_i_DXu(unsigned int c) { if (gps->mi == hia[c]) gi3 = 1; }
void cx_e_i_DYc(int c) { char v = gc; if (gps->mi == hia[v]) gi3 = 1; }
void cx_e_i_DYb(int c) { unsigned char v = gb; if (gps->mi == hia[v]) gi3 = 1; }
void cx_e_i_DYi(int c) { int v = gi; if (gps->mi == hia[v]) gi3 = 1; }
void cx_e_i_DYu(int c) { unsigned int v = gu; if (gps->mi == hia[v]) gi3 = 1; }
void cx_e_i_EXc(char c) { if (gia[3] == hia[c]) gi3 = 1; }
void cx_e_i_EXb(unsigned char c) { if (gia[3] == hia[c]) gi3 = 1; }
void cx_e_i_EXi(int c) { if (gia[3] == hia[c]) gi3 = 1; }
void cx_e_i_EXu(unsigned int c) { if (gia[3] == hia[c]) gi3 = 1; }
void cx_e_i_EYc(int c) { char v = gc; if (gia[3] == hia[v]) gi3 = 1; }
void cx_e_i_EYb(int c) { unsigned char v = gb; if (gia[3] == hia[v]) gi3 = 1; }
void cx_e_i_EYi(int c) { int v = gi; if (gia[3] == hia[v]) gi3 = 1; }
void cx_e_i_EYu(int c) { unsigned int v = gu; if (gia[3] == hia[v]) gi3 = 1; }

void cx_l_u_GXc(char c) { if (gu < hua[c]) gi3 = 1; }
void cx_l_u_GXb(unsigned char c) { if (gu < hua[c]) gi3 = 1; }
void cx_l_u_GXi(int c) { if (gu < hua[c]) gi3 = 1; }
void cx_l_u_GXu(unsigned int c) { if (gu < hua[c]) gi3 = 1; }
void cx_l_u_GYc(int c) { char v = gc; if (gu < hua[v]) gi3 = 1; }
void cx_l_u_GYb(int c) { unsigned char v = gb; if (gu < hua[v]) gi3 = 1; }
void cx_l_u_GYi(int c) { int v = gi; if (gu < hua[v]) gi3 = 1; }
void cx_l_u_GYu(int c) { unsigned int v = gu; if (gu < hua[v]) gi3 = 1; }
void cx_l_u_RXc(unsigned int r, char c) { if (r < hua[c]) gi3 = 1; }
void cx_l_u_RXb(unsigned int r, unsigned char c) { if (r < hua[c]) gi3 = 1; }
void cx_l_u_RXi(unsigned int r, int c) { if (r < hua[c]) gi3 = 1; }
void cx_l_u_RXu(unsigned int r, unsigned int c) { if (r < hua[c]) gi3 = 1; }
void cx_l_u_RYc(unsigned int r, int c) { char v = gc; if (r < hua[v]) gi3 = 1; }
void cx_l_u_RYb(unsigned int r, int c) { unsigned char v = gb; if (r < hua[v]) gi3 = 1; }
void cx_l_u_RYi(unsigned int r, int c) { int v = gi; if (r < hua[v]) gi3 = 1; }
void cx_l_u_RYu(unsigned int r, int c) { unsigned int v = gu; if (r < hua[v]) gi3 = 1; }
void cx_l_u_DXc(char c) { if (gps->mu < hua[c]) gi3 = 1; }
void cx_l_u_DXb(unsigned char c) { if (gps->mu < hua[c]) gi3 = 1; }
void cx_l_u_DXi(int c) { if (gps->mu < hua[c]) gi3 = 1; }
void cx_l_u_DXu(unsigned int c) { if (gps->mu < hua[c]) gi3 = 1; }
void cx_l_u_DYc(int c) { char v = gc; if (gps->mu < hua[v]) gi3 = 1; }
void cx_l_u_DYb(int c) { unsigned char v = gb; if (gps->mu < hua[v]) gi3 = 1; }
void cx_l_u_DYi(int c) { int v = gi; if (gps->mu < hua[v]) gi3 = 1; }
void cx_l_u_DYu(int c) { unsigned int v = gu; if (gps->mu < hua[v]) gi3 = 1; }
void cx_l_u_EXc(char c) { if (gua[3] < hua[c]) gi3 = 1; }
void cx_l_u_EXb(unsigned char c) { if (gua[3] < hua[c]) gi3 = 1; }
void cx_l_u_EXi(int c) { if (gua[3] < hua[c]) gi3 = 1; }
void cx_l_u_EXu(unsigned int c) { if (gua[3] < hua[c]) gi3 = 1; }
void cx_l_u_EYc(int c) { char v = gc; if (gua[3] < hua[v]) gi3 = 1; }
void cx_l_u_EYb(int c) { unsigned char v = gb; if (gua[3] < hua[v]) gi3 = 1; }
void cx_l_u_EYi(int c) { int v = gi; if (gua[3] < hua[v]) gi3 = 1; }
void cx_l_u_EYu(int c) { unsigned int v = gu; if (gua[3] < hua[v]) gi3 = 1; }
void cx_e_u_GXc(char c) { if (gu == hua[c]) gi3 = 1; }
void cx_e_u_GXb(unsigned char c) { if (gu == hua[c]) gi3 = 1; }
void cx_e_u_GXi(int c) { if (gu == hua[c]) gi3 = 1; }
void cx_e_u_GXu(unsigned int c) { if (gu == hua[c]) gi3 = 1; }
void cx_e_u_GYc(int c) { char v = gc; if (gu == hua[v]) gi3 = 1; }
void cx_e_u_GYb(int c) { unsigned char v = gb; if (gu == hua[v]) gi3 = 1; }
void cx_e_u_GYi(int c) { int v = gi; if (gu == hua[v]) gi3 = 1; }
void cx_e_u_GYu(int c) { unsigned int v = gu; if (gu == hua[v]) gi3 = 1; }
void cx_e_u_RXc(unsigned int r, char c) { if (r == hua[c]) gi3 = 1; }
void cx_e_u_RXb(unsigned int r, unsigned char c) { if (r == hua[c]) gi3 = 1; }
void cx_e_u_RXi(unsigned int r, int c) { if (r == hua[c]) gi3 = 1; }
void cx_e_u_RXu(unsigned int r, unsigned int c) { if (r == hua[c]) gi3 = 1; }
void cx_e_u_RYc(unsigned int r, int c) { char v = gc; if (r == hua[v]) gi3 = 1; }
void cx_e_u_RYb(unsigned int r, int c) { unsigned char v = gb; if (r == hua[v]) gi3 = 1; }
void cx_e_u_RYi(unsigned int r, int c) { int v = gi; if (r == hua[v]) gi3 = 1; }
void cx_e_u_RYu(unsigned int r, int c) { unsigned int v = gu; if (r == hua[v]) gi3 = 1; }
void cx_e_u_DXc(char c) { if (gps->mu == hua[c]) gi3 = 1; }
void cx_e_u_DXb(unsigned char c) { if (gps->mu == hua[c]) gi3 = 1; }
void cx_e_u_DXi(int c) { if (gps->mu == hua[c]) gi3 = 1; }
void cx_e_u_DXu(unsigned int c) { if (gps->mu == hua[c]) gi3 = 1; }
void cx_e_u_DYc(int c) { char v = gc; if (gps->mu == hua[v]) gi3 = 1; }
void cx_e_u_DYb(int c) { unsigned char v = gb; if (gps->mu == hua[v]) gi3 = 1; }
void cx_e_u_DYi(int c) { int v = gi; if (gps->mu == hua[v]) gi3 = 1; }
void cx_e_u_DYu(int c) { unsigned int v = gu; if (gps->mu == hua[v]) gi3 = 1; }
void cx_e_u_EXc(char c) { if (gua[3] == hua[c]) gi3 = 1; }
void cx_e_u_EXb(unsigned char c) { if (gua[3] == hua[c]) gi3 = 1; }
void cx_e_u_EXi(int c) { if (gua[3] == hua[c]) gi3 = 1; }
void cx_e_u_EXu(unsigned int c) { if (gua[3] == hua[c]) gi3 = 1; }
void cx_e_u_EYc(int c) { char v = gc; if (gua[3] == hua[v]) gi3 = 1; }
void cx_e_u_EYb(int c) { unsigned char v = gb; if (gua[3] == hua[v]) gi3 = 1; }
void cx_e_u_EYi(int c) { int v = gi; if (gua[3] == hua[v]) gi3 = 1; }
void cx_e_u_EYu(int c) { unsigned int v = gu; if (gua[3] == hua[v]) gi3 = 1; }

void cx_l_l_GXc(char c) { if (gl < hla[c]) gi3 = 1; }
void cx_l_l_GXb(unsigned char c) { if (gl < hla[c]) gi3 = 1; }
void cx_l_l_GXi(int c) { if (gl < hla[c]) gi3 = 1; }
void cx_l_l_GXu(unsigned int c) { if (gl < hla[c]) gi3 = 1; }
void cx_l_l_GYc(int c) { char v = gc; if (gl < hla[v]) gi3 = 1; }
void cx_l_l_GYb(int c) { unsigned char v = gb; if (gl < hla[v]) gi3 = 1; }
void cx_l_l_GYi(int c) { int v = gi; if (gl < hla[v]) gi3 = 1; }
void cx_l_l_GYu(int c) { unsigned int v = gu; if (gl < hla[v]) gi3 = 1; }
void cx_l_l_RXc(long r, char c) { if (r < hla[c]) gi3 = 1; }
void cx_l_l_RXb(long r, unsigned char c) { if (r < hla[c]) gi3 = 1; }
void cx_l_l_RXi(long r, int c) { if (r < hla[c]) gi3 = 1; }
void cx_l_l_RXu(long r, unsigned int c) { if (r < hla[c]) gi3 = 1; }
void cx_l_l_RYc(long r, int c) { char v = gc; if (r < hla[v]) gi3 = 1; }
void cx_l_l_RYb(long r, int c) { unsigned char v = gb; if (r < hla[v]) gi3 = 1; }
void cx_l_l_RYi(long r, int c) { int v = gi; if (r < hla[v]) gi3 = 1; }
void cx_l_l_RYu(long r, int c) { unsigned int v = gu; if (r < hla[v]) gi3 = 1; }
void cx_l_l_DXc(char c) { if (gps->ml < hla[c]) gi3 = 1; }
void cx_l_l_DXb(unsigned char c) { if (gps->ml < hla[c]) gi3 = 1; }
void cx_l_l_DXi(int c) { if (gps->ml < hla[c]) gi3 = 1; }
void cx_l_l_DXu(unsigned int c) { if (gps->ml < hla[c]) gi3 = 1; }
void cx_l_l_DYc(int c) { char v = gc; if (gps->ml < hla[v]) gi3 = 1; }
void cx_l_l_DYb(int c) { unsigned char v = gb; if (gps->ml < hla[v]) gi3 = 1; }
void cx_l_l_DYi(int c) { int v = gi; if (gps->ml < hla[v]) gi3 = 1; }
void cx_l_l_DYu(int c) { unsigned int v = gu; if (gps->ml < hla[v]) gi3 = 1; }
void cx_l_l_EXc(char c) { if (gla[3] < hla[c]) gi3 = 1; }
void cx_l_l_EXb(unsigned char c) { if (gla[3] < hla[c]) gi3 = 1; }
void cx_l_l_EXi(int c) { if (gla[3] < hla[c]) gi3 = 1; }
void cx_l_l_EXu(unsigned int c) { if (gla[3] < hla[c]) gi3 = 1; }
void cx_l_l_EYc(int c) { char v = gc; if (gla[3] < hla[v]) gi3 = 1; }
void cx_l_l_EYb(int c) { unsigned char v = gb; if (gla[3] < hla[v]) gi3 = 1; }
void cx_l_l_EYi(int c) { int v = gi; if (gla[3] < hla[v]) gi3 = 1; }
void cx_l_l_EYu(int c) { unsigned int v = gu; if (gla[3] < hla[v]) gi3 = 1; }
void cx_e_l_GXc(char c) { if (gl == hla[c]) gi3 = 1; }
void cx_e_l_GXb(unsigned char c) { if (gl == hla[c]) gi3 = 1; }
void cx_e_l_GXi(int c) { if (gl == hla[c]) gi3 = 1; }
void cx_e_l_GXu(unsigned int c) { if (gl == hla[c]) gi3 = 1; }
void cx_e_l_GYc(int c) { char v = gc; if (gl == hla[v]) gi3 = 1; }
void cx_e_l_GYb(int c) { unsigned char v = gb; if (gl == hla[v]) gi3 = 1; }
void cx_e_l_GYi(int c) { int v = gi; if (gl == hla[v]) gi3 = 1; }
void cx_e_l_GYu(int c) { unsigned int v = gu; if (gl == hla[v]) gi3 = 1; }
void cx_e_l_RXc(long r, char c) { if (r == hla[c]) gi3 = 1; }
void cx_e_l_RXb(long r, unsigned char c) { if (r == hla[c]) gi3 = 1; }
void cx_e_l_RXi(long r, int c) { if (r == hla[c]) gi3 = 1; }
void cx_e_l_RXu(long r, unsigned int c) { if (r == hla[c]) gi3 = 1; }
void cx_e_l_RYc(long r, int c) { char v = gc; if (r == hla[v]) gi3 = 1; }
void cx_e_l_RYb(long r, int c) { unsigned char v = gb; if (r == hla[v]) gi3 = 1; }
void cx_e_l_RYi(long r, int c) { int v = gi; if (r == hla[v]) gi3 = 1; }
void cx_e_l_RYu(long r, int c) { unsigned int v = gu; if (r == hla[v]) gi3 = 1; }
void cx_e_l_DXc(char c) { if (gps->ml == hla[c]) gi3 = 1; }
void cx_e_l_DXb(unsigned char c) { if (gps->ml == hla[c]) gi3 = 1; }
void cx_e_l_DXi(int c) { if (gps->ml == hla[c]) gi3 = 1; }
void cx_e_l_DXu(unsigned int c) { if (gps->ml == hla[c]) gi3 = 1; }
void cx_e_l_DYc(int c) { char v = gc; if (gps->ml == hla[v]) gi3 = 1; }
void cx_e_l_DYb(int c) { unsigned char v = gb; if (gps->ml == hla[v]) gi3 = 1; }
void cx_e_l_DYi(int c) { int v = gi; if (gps->ml == hla[v]) gi3 = 1; }
void cx_e_l_DYu(int c) { unsigned int v = gu; if (gps->ml == hla[v]) gi3 = 1; }
void cx_e_l_EXc(char c) { if (gla[3] == hla[c]) gi3 = 1; }
void cx_e_l_EXb(unsigned char c) { if (gla[3] == hla[c]) gi3 = 1; }
void cx_e_l_EXi(int c) { if (gla[3] == hla[c]) gi3 = 1; }
void cx_e_l_EXu(unsigned int c) { if (gla[3] == hla[c]) gi3 = 1; }
void cx_e_l_EYc(int c) { char v = gc; if (gla[3] == hla[v]) gi3 = 1; }
void cx_e_l_EYb(int c) { unsigned char v = gb; if (gla[3] == hla[v]) gi3 = 1; }
void cx_e_l_EYi(int c) { int v = gi; if (gla[3] == hla[v]) gi3 = 1; }
void cx_e_l_EYu(int c) { unsigned int v = gu; if (gla[3] == hla[v]) gi3 = 1; }

void cx_l_n_GXc(char c) { if (gn < hna[c]) gi3 = 1; }
void cx_l_n_GXb(unsigned char c) { if (gn < hna[c]) gi3 = 1; }
void cx_l_n_GXi(int c) { if (gn < hna[c]) gi3 = 1; }
void cx_l_n_GXu(unsigned int c) { if (gn < hna[c]) gi3 = 1; }
void cx_l_n_GYc(int c) { char v = gc; if (gn < hna[v]) gi3 = 1; }
void cx_l_n_GYb(int c) { unsigned char v = gb; if (gn < hna[v]) gi3 = 1; }
void cx_l_n_GYi(int c) { int v = gi; if (gn < hna[v]) gi3 = 1; }
void cx_l_n_GYu(int c) { unsigned int v = gu; if (gn < hna[v]) gi3 = 1; }
void cx_l_n_RXc(unsigned long r, char c) { if (r < hna[c]) gi3 = 1; }
void cx_l_n_RXb(unsigned long r, unsigned char c) { if (r < hna[c]) gi3 = 1; }
void cx_l_n_RXi(unsigned long r, int c) { if (r < hna[c]) gi3 = 1; }
void cx_l_n_RXu(unsigned long r, unsigned int c) { if (r < hna[c]) gi3 = 1; }
void cx_l_n_RYc(unsigned long r, int c) { char v = gc; if (r < hna[v]) gi3 = 1; }
void cx_l_n_RYb(unsigned long r, int c) { unsigned char v = gb; if (r < hna[v]) gi3 = 1; }
void cx_l_n_RYi(unsigned long r, int c) { int v = gi; if (r < hna[v]) gi3 = 1; }
void cx_l_n_RYu(unsigned long r, int c) { unsigned int v = gu; if (r < hna[v]) gi3 = 1; }
void cx_l_n_DXc(char c) { if (gps->mn < hna[c]) gi3 = 1; }
void cx_l_n_DXb(unsigned char c) { if (gps->mn < hna[c]) gi3 = 1; }
void cx_l_n_DXi(int c) { if (gps->mn < hna[c]) gi3 = 1; }
void cx_l_n_DXu(unsigned int c) { if (gps->mn < hna[c]) gi3 = 1; }
void cx_l_n_DYc(int c) { char v = gc; if (gps->mn < hna[v]) gi3 = 1; }
void cx_l_n_DYb(int c) { unsigned char v = gb; if (gps->mn < hna[v]) gi3 = 1; }
void cx_l_n_DYi(int c) { int v = gi; if (gps->mn < hna[v]) gi3 = 1; }
void cx_l_n_DYu(int c) { unsigned int v = gu; if (gps->mn < hna[v]) gi3 = 1; }
void cx_l_n_EXc(char c) { if (gna[3] < hna[c]) gi3 = 1; }
void cx_l_n_EXb(unsigned char c) { if (gna[3] < hna[c]) gi3 = 1; }
void cx_l_n_EXi(int c) { if (gna[3] < hna[c]) gi3 = 1; }
void cx_l_n_EXu(unsigned int c) { if (gna[3] < hna[c]) gi3 = 1; }
void cx_l_n_EYc(int c) { char v = gc; if (gna[3] < hna[v]) gi3 = 1; }
void cx_l_n_EYb(int c) { unsigned char v = gb; if (gna[3] < hna[v]) gi3 = 1; }
void cx_l_n_EYi(int c) { int v = gi; if (gna[3] < hna[v]) gi3 = 1; }
void cx_l_n_EYu(int c) { unsigned int v = gu; if (gna[3] < hna[v]) gi3 = 1; }
void cx_e_n_GXc(char c) { if (gn == hna[c]) gi3 = 1; }
void cx_e_n_GXb(unsigned char c) { if (gn == hna[c]) gi3 = 1; }
void cx_e_n_GXi(int c) { if (gn == hna[c]) gi3 = 1; }
void cx_e_n_GXu(unsigned int c) { if (gn == hna[c]) gi3 = 1; }
void cx_e_n_GYc(int c) { char v = gc; if (gn == hna[v]) gi3 = 1; }
void cx_e_n_GYb(int c) { unsigned char v = gb; if (gn == hna[v]) gi3 = 1; }
void cx_e_n_GYi(int c) { int v = gi; if (gn == hna[v]) gi3 = 1; }
void cx_e_n_GYu(int c) { unsigned int v = gu; if (gn == hna[v]) gi3 = 1; }
void cx_e_n_RXc(unsigned long r, char c) { if (r == hna[c]) gi3 = 1; }
void cx_e_n_RXb(unsigned long r, unsigned char c) { if (r == hna[c]) gi3 = 1; }
void cx_e_n_RXi(unsigned long r, int c) { if (r == hna[c]) gi3 = 1; }
void cx_e_n_RXu(unsigned long r, unsigned int c) { if (r == hna[c]) gi3 = 1; }
void cx_e_n_RYc(unsigned long r, int c) { char v = gc; if (r == hna[v]) gi3 = 1; }
void cx_e_n_RYb(unsigned long r, int c) { unsigned char v = gb; if (r == hna[v]) gi3 = 1; }
void cx_e_n_RYi(unsigned long r, int c) { int v = gi; if (r == hna[v]) gi3 = 1; }
void cx_e_n_RYu(unsigned long r, int c) { unsigned int v = gu; if (r == hna[v]) gi3 = 1; }
void cx_e_n_DXc(char c) { if (gps->mn == hna[c]) gi3 = 1; }
void cx_e_n_DXb(unsigned char c) { if (gps->mn == hna[c]) gi3 = 1; }
void cx_e_n_DXi(int c) { if (gps->mn == hna[c]) gi3 = 1; }
void cx_e_n_DXu(unsigned int c) { if (gps->mn == hna[c]) gi3 = 1; }
void cx_e_n_DYc(int c) { char v = gc; if (gps->mn == hna[v]) gi3 = 1; }
void cx_e_n_DYb(int c) { unsigned char v = gb; if (gps->mn == hna[v]) gi3 = 1; }
void cx_e_n_DYi(int c) { int v = gi; if (gps->mn == hna[v]) gi3 = 1; }
void cx_e_n_DYu(int c) { unsigned int v = gu; if (gps->mn == hna[v]) gi3 = 1; }
void cx_e_n_EXc(char c) { if (gna[3] == hna[c]) gi3 = 1; }
void cx_e_n_EXb(unsigned char c) { if (gna[3] == hna[c]) gi3 = 1; }
void cx_e_n_EXi(int c) { if (gna[3] == hna[c]) gi3 = 1; }
void cx_e_n_EXu(unsigned int c) { if (gna[3] == hna[c]) gi3 = 1; }
void cx_e_n_EYc(int c) { char v = gc; if (gna[3] == hna[v]) gi3 = 1; }
void cx_e_n_EYb(int c) { unsigned char v = gb; if (gna[3] == hna[v]) gi3 = 1; }
void cx_e_n_EYi(int c) { int v = gi; if (gna[3] == hna[v]) gi3 = 1; }
void cx_e_n_EYu(int c) { unsigned int v = gu; if (gna[3] == hna[v]) gi3 = 1; }

void cp_l_c_GP(char r, int c) { if (gc < *hcp) gi3 = 1; }
void cp_l_c_GI(char r, int c) { if (gc < hcp[2]) gi3 = 1; }
void cp_l_c_GA(char r, int c) { if (gc < hps->ac[c]) gi3 = 1; }
void cp_l_c_GQ(char r, int c) { if (gc < hps->ac[4]) gi3 = 1; }
void cp_l_c_GD(char r, int c) { if (gc < hps->mc) gi3 = 1; }
void cp_l_c_GT(char r, int c) { char *v = hcp; if (gc < v[1]) gi3 = 1; }
void cp_l_c_RP(char r, int c) { if (r < *hcp) gi3 = 1; }
void cp_l_c_RI(char r, int c) { if (r < hcp[2]) gi3 = 1; }
void cp_l_c_RA(char r, int c) { if (r < hps->ac[c]) gi3 = 1; }
void cp_l_c_RQ(char r, int c) { if (r < hps->ac[4]) gi3 = 1; }
void cp_l_c_RD(char r, int c) { if (r < hps->mc) gi3 = 1; }
void cp_l_c_RT(char r, int c) { char *v = hcp; if (r < v[1]) gi3 = 1; }
void cp_l_c_DP(char r, int c) { if (gps->mc < *hcp) gi3 = 1; }
void cp_l_c_DI(char r, int c) { if (gps->mc < hcp[2]) gi3 = 1; }
void cp_l_c_DA(char r, int c) { if (gps->mc < hps->ac[c]) gi3 = 1; }
void cp_l_c_DQ(char r, int c) { if (gps->mc < hps->ac[4]) gi3 = 1; }
void cp_l_c_DD(char r, int c) { if (gps->mc < hps->mc) gi3 = 1; }
void cp_l_c_DT(char r, int c) { char *v = hcp; if (gps->mc < v[1]) gi3 = 1; }
void cp_l_c_EP(char r, int c) { if (gca[3] < *hcp) gi3 = 1; }
void cp_l_c_EI(char r, int c) { if (gca[3] < hcp[2]) gi3 = 1; }
void cp_l_c_EA(char r, int c) { if (gca[3] < hps->ac[c]) gi3 = 1; }
void cp_l_c_EQ(char r, int c) { if (gca[3] < hps->ac[4]) gi3 = 1; }
void cp_l_c_ED(char r, int c) { if (gca[3] < hps->mc) gi3 = 1; }
void cp_l_c_ET(char r, int c) { char *v = hcp; if (gca[3] < v[1]) gi3 = 1; }
void cp_e_c_GP(char r, int c) { if (gc == *hcp) gi3 = 1; }
void cp_e_c_GI(char r, int c) { if (gc == hcp[2]) gi3 = 1; }
void cp_e_c_GA(char r, int c) { if (gc == hps->ac[c]) gi3 = 1; }
void cp_e_c_GQ(char r, int c) { if (gc == hps->ac[4]) gi3 = 1; }
void cp_e_c_GD(char r, int c) { if (gc == hps->mc) gi3 = 1; }
void cp_e_c_GT(char r, int c) { char *v = hcp; if (gc == v[1]) gi3 = 1; }
void cp_e_c_RP(char r, int c) { if (r == *hcp) gi3 = 1; }
void cp_e_c_RI(char r, int c) { if (r == hcp[2]) gi3 = 1; }
void cp_e_c_RA(char r, int c) { if (r == hps->ac[c]) gi3 = 1; }
void cp_e_c_RQ(char r, int c) { if (r == hps->ac[4]) gi3 = 1; }
void cp_e_c_RD(char r, int c) { if (r == hps->mc) gi3 = 1; }
void cp_e_c_RT(char r, int c) { char *v = hcp; if (r == v[1]) gi3 = 1; }
void cp_e_c_DP(char r, int c) { if (gps->mc == *hcp) gi3 = 1; }
void cp_e_c_DI(char r, int c) { if (gps->mc == hcp[2]) gi3 = 1; }
void cp_e_c_DA(char r, int c) { if (gps->mc == hps->ac[c]) gi3 = 1; }
void cp_e_c_DQ(char r, int c) { if (gps->mc == hps->ac[4]) gi3 = 1; }
void cp_e_c_DD(char r, int c) { if (gps->mc == hps->mc) gi3 = 1; }
void cp_e_c_DT(char r, int c) { char *v = hcp; if (gps->mc == v[1]) gi3 = 1; }
void cp_e_c_EP(char r, int c) { if (gca[3] == *hcp) gi3 = 1; }
void cp_e_c_EI(char r, int c) { if (gca[3] == hcp[2]) gi3 = 1; }
void cp_e_c_EA(char r, int c) { if (gca[3] == hps->ac[c]) gi3 = 1; }
void cp_e_c_EQ(char r, int c) { if (gca[3] == hps->ac[4]) gi3 = 1; }
void cp_e_c_ED(char r, int c) { if (gca[3] == hps->mc) gi3 = 1; }
void cp_e_c_ET(char r, int c) { char *v = hcp; if (gca[3] == v[1]) gi3 = 1; }

void cp_l_b_GP(unsigned char r, int c) { if (gb < *hbp) gi3 = 1; }
void cp_l_b_GI(unsigned char r, int c) { if (gb < hbp[2]) gi3 = 1; }
void cp_l_b_GA(unsigned char r, int c) { if (gb < hps->ab[c]) gi3 = 1; }
void cp_l_b_GQ(unsigned char r, int c) { if (gb < hps->ab[4]) gi3 = 1; }
void cp_l_b_GD(unsigned char r, int c) { if (gb < hps->mb) gi3 = 1; }
void cp_l_b_GT(unsigned char r, int c) { unsigned char *v = hbp; if (gb < v[1]) gi3 = 1; }
void cp_l_b_RP(unsigned char r, int c) { if (r < *hbp) gi3 = 1; }
void cp_l_b_RI(unsigned char r, int c) { if (r < hbp[2]) gi3 = 1; }
void cp_l_b_RA(unsigned char r, int c) { if (r < hps->ab[c]) gi3 = 1; }
void cp_l_b_RQ(unsigned char r, int c) { if (r < hps->ab[4]) gi3 = 1; }
void cp_l_b_RD(unsigned char r, int c) { if (r < hps->mb) gi3 = 1; }
void cp_l_b_RT(unsigned char r, int c) { unsigned char *v = hbp; if (r < v[1]) gi3 = 1; }
void cp_l_b_DP(unsigned char r, int c) { if (gps->mb < *hbp) gi3 = 1; }
void cp_l_b_DI(unsigned char r, int c) { if (gps->mb < hbp[2]) gi3 = 1; }
void cp_l_b_DA(unsigned char r, int c) { if (gps->mb < hps->ab[c]) gi3 = 1; }
void cp_l_b_DQ(unsigned char r, int c) { if (gps->mb < hps->ab[4]) gi3 = 1; }
void cp_l_b_DD(unsigned char r, int c) { if (gps->mb < hps->mb) gi3 = 1; }
void cp_l_b_DT(unsigned char r, int c) { unsigned char *v = hbp; if (gps->mb < v[1]) gi3 = 1; }
void cp_l_b_EP(unsigned char r, int c) { if (gba[3] < *hbp) gi3 = 1; }
void cp_l_b_EI(unsigned char r, int c) { if (gba[3] < hbp[2]) gi3 = 1; }
void cp_l_b_EA(unsigned char r, int c) { if (gba[3] < hps->ab[c]) gi3 = 1; }
void cp_l_b_EQ(unsigned char r, int c) { if (gba[3] < hps->ab[4]) gi3 = 1; }
void cp_l_b_ED(unsigned char r, int c) { if (gba[3] < hps->mb) gi3 = 1; }
void cp_l_b_ET(unsigned char r, int c) { unsigned char *v = hbp; if (gba[3] < v[1]) gi3 = 1; }
void cp_e_b_GP(unsigned char r, int c) { if (gb == *hbp) gi3 = 1; }
void cp_e_b_GI(unsigned char r, int c) { if (gb == hbp[2]) gi3 = 1; }
void cp_e_b_GA(unsigned char r, int c) { if (gb == hps->ab[c]) gi3 = 1; }
void cp_e_b_GQ(unsigned char r, int c) { if (gb == hps->ab[4]) gi3 = 1; }
void cp_e_b_GD(unsigned char r, int c) { if (gb == hps->mb) gi3 = 1; }
void cp_e_b_GT(unsigned char r, int c) { unsigned char *v = hbp; if (gb == v[1]) gi3 = 1; }
void cp_e_b_RP(unsigned char r, int c) { if (r == *hbp) gi3 = 1; }
void cp_e_b_RI(unsigned char r, int c) { if (r == hbp[2]) gi3 = 1; }
void cp_e_b_RA(unsigned char r, int c) { if (r == hps->ab[c]) gi3 = 1; }
void cp_e_b_RQ(unsigned char r, int c) { if (r == hps->ab[4]) gi3 = 1; }
void cp_e_b_RD(unsigned char r, int c) { if (r == hps->mb) gi3 = 1; }
void cp_e_b_RT(unsigned char r, int c) { unsigned char *v = hbp; if (r == v[1]) gi3 = 1; }
void cp_e_b_DP(unsigned char r, int c) { if (gps->mb == *hbp) gi3 = 1; }
void cp_e_b_DI(unsigned char r, int c) { if (gps->mb == hbp[2]) gi3 = 1; }
void cp_e_b_DA(unsigned char r, int c) { if (gps->mb == hps->ab[c]) gi3 = 1; }
void cp_e_b_DQ(unsigned char r, int c) { if (gps->mb == hps->ab[4]) gi3 = 1; }
void cp_e_b_DD(unsigned char r, int c) { if (gps->mb == hps->mb) gi3 = 1; }
void cp_e_b_DT(unsigned char r, int c) { unsigned char *v = hbp; if (gps->mb == v[1]) gi3 = 1; }
void cp_e_b_EP(unsigned char r, int c) { if (gba[3] == *hbp) gi3 = 1; }
void cp_e_b_EI(unsigned char r, int c) { if (gba[3] == hbp[2]) gi3 = 1; }
void cp_e_b_EA(unsigned char r, int c) { if (gba[3] == hps->ab[c]) gi3 = 1; }
void cp_e_b_EQ(unsigned char r, int c) { if (gba[3] == hps->ab[4]) gi3 = 1; }
void cp_e_b_ED(unsigned char r, int c) { if (gba[3] == hps->mb) gi3 = 1; }
void cp_e_b_ET(unsigned char r, int c) { unsigned char *v = hbp; if (gba[3] == v[1]) gi3 = 1; }

void cp_l_i_GP(int r, int c) { if (gi < *hip) gi3 = 1; }
void cp_l_i_GI(int r, int c) { if (gi < hip[2]) gi3 = 1; }
void cp_l_i_GA(int r, int c) { if (gi < hps->ai[c]) gi3 = 1; }
void cp_l_i_GQ(int r, int c) { if (gi < hps->ai[4]) gi3 = 1; }
void cp_l_i_GD(int r, int c) { if (gi < hps->mi) gi3 = 1; }
void cp_l_i_GT(int r, int c) { int *v = hip; if (gi < v[1]) gi3 = 1; }
void cp_l_i_RP(int r, int c) { if (r < *hip) gi3 = 1; }
void cp_l_i_RI(int r, int c) { if (r < hip[2]) gi3 = 1; }
void cp_l_i_RA(int r, int c) { if (r < hps->ai[c]) gi3 = 1; }
void cp_l_i_RQ(int r, int c) { if (r < hps->ai[4]) gi3 = 1; }
void cp_l_i_RD(int r, int c) { if (r < hps->mi) gi3 = 1; }
void cp_l_i_RT(int r, int c) { int *v = hip; if (r < v[1]) gi3 = 1; }
void cp_l_i_DP(int r, int c) { if (gps->mi < *hip) gi3 = 1; }
void cp_l_i_DI(int r, int c) { if (gps->mi < hip[2]) gi3 = 1; }
void cp_l_i_DA(int r, int c) { if (gps->mi < hps->ai[c]) gi3 = 1; }
void cp_l_i_DQ(int r, int c) { if (gps->mi < hps->ai[4]) gi3 = 1; }
void cp_l_i_DD(int r, int c) { if (gps->mi < hps->mi) gi3 = 1; }
void cp_l_i_DT(int r, int c) { int *v = hip; if (gps->mi < v[1]) gi3 = 1; }
void cp_l_i_EP(int r, int c) { if (gia[3] < *hip) gi3 = 1; }
void cp_l_i_EI(int r, int c) { if (gia[3] < hip[2]) gi3 = 1; }
void cp_l_i_EA(int r, int c) { if (gia[3] < hps->ai[c]) gi3 = 1; }
void cp_l_i_EQ(int r, int c) { if (gia[3] < hps->ai[4]) gi3 = 1; }
void cp_l_i_ED(int r, int c) { if (gia[3] < hps->mi) gi3 = 1; }
void cp_l_i_ET(int r, int c) { int *v = hip; if (gia[3] < v[1]) gi3 = 1; }
void cp_e_i_GP(int r, int c) { if (gi == *hip) gi3 = 1; }
void cp_e_i_GI(int r, int c) { if (gi == hip[2]) gi3 = 1; }
void cp_e_i_GA(int r, int c) { if (gi == hps->ai[c]) gi3 = 1; }
void cp_e_i_GQ(int r, int c) { if (gi == hps->ai[4]) gi3 = 1; }
void cp_e_i_GD(int r, int c) { if (gi == hps->mi) gi3 = 1; }
void cp_e_i_GT(int r, int c) { int *v = hip; if (gi == v[1]) gi3 = 1; }
void cp_e_i_RP(int r, int c) { if (r == *hip) gi3 = 1; }
void cp_e_i_RI(int r, int c) { if (r == hip[2]) gi3 = 1; }
void cp_e_i_RA(int r, int c) { if (r == hps->ai[c]) gi3 = 1; }
void cp_e_i_RQ(int r, int c) { if (r == hps->ai[4]) gi3 = 1; }
void cp_e_i_RD(int r, int c) { if (r == hps->mi) gi3 = 1; }
void cp_e_i_RT(int r, int c) { int *v = hip; if (r == v[1]) gi3 = 1; }
void cp_e_i_DP(int r, int c) { if (gps->mi == *hip) gi3 = 1; }
void cp_e_i_DI(int r, int c) { if (gps->mi == hip[2]) gi3 = 1; }
void cp_e_i_DA(int r, int c) { if (gps->mi == hps->ai[c]) gi3 = 1; }
void cp_e_i_DQ(int r, int c) { if (gps->mi == hps->ai[4]) gi3 = 1; }
void cp_e_i_DD(int r, int c) { if (gps->mi == hps->mi) gi3 = 1; }
void cp_e_i_DT(int r, int c) { int *v = hip; if (gps->mi == v[1]) gi3 = 1; }
void cp_e_i_EP(int r, int c) { if (gia[3] == *hip) gi3 = 1; }
void cp_e_i_EI(int r, int c) { if (gia[3] == hip[2]) gi3 = 1; }
void cp_e_i_EA(int r, int c) { if (gia[3] == hps->ai[c]) gi3 = 1; }
void cp_e_i_EQ(int r, int c) { if (gia[3] == hps->ai[4]) gi3 = 1; }
void cp_e_i_ED(int r, int c) { if (gia[3] == hps->mi) gi3 = 1; }
void cp_e_i_ET(int r, int c) { int *v = hip; if (gia[3] == v[1]) gi3 = 1; }

void cp_l_u_GP(unsigned int r, int c) { if (gu < *hup) gi3 = 1; }
void cp_l_u_GI(unsigned int r, int c) { if (gu < hup[2]) gi3 = 1; }
void cp_l_u_GA(unsigned int r, int c) { if (gu < hps->au[c]) gi3 = 1; }
void cp_l_u_GQ(unsigned int r, int c) { if (gu < hps->au[4]) gi3 = 1; }
void cp_l_u_GD(unsigned int r, int c) { if (gu < hps->mu) gi3 = 1; }
void cp_l_u_GT(unsigned int r, int c) { unsigned int *v = hup; if (gu < v[1]) gi3 = 1; }
void cp_l_u_RP(unsigned int r, int c) { if (r < *hup) gi3 = 1; }
void cp_l_u_RI(unsigned int r, int c) { if (r < hup[2]) gi3 = 1; }
void cp_l_u_RA(unsigned int r, int c) { if (r < hps->au[c]) gi3 = 1; }
void cp_l_u_RQ(unsigned int r, int c) { if (r < hps->au[4]) gi3 = 1; }
void cp_l_u_RD(unsigned int r, int c) { if (r < hps->mu) gi3 = 1; }
void cp_l_u_RT(unsigned int r, int c) { unsigned int *v = hup; if (r < v[1]) gi3 = 1; }
void cp_l_u_DP(unsigned int r, int c) { if (gps->mu < *hup) gi3 = 1; }
void cp_l_u_DI(unsigned int r, int c) { if (gps->mu < hup[2]) gi3 = 1; }
void cp_l_u_DA(unsigned int r, int c) { if (gps->mu < hps->au[c]) gi3 = 1; }
void cp_l_u_DQ(unsigned int r, int c) { if (gps->mu < hps->au[4]) gi3 = 1; }
void cp_l_u_DD(unsigned int r, int c) { if (gps->mu < hps->mu) gi3 = 1; }
void cp_l_u_DT(unsigned int r, int c) { unsigned int *v = hup; if (gps->mu < v[1]) gi3 = 1; }
void cp_l_u_EP(unsigned int r, int c) { if (gua[3] < *hup) gi3 = 1; }
void cp_l_u_EI(unsigned int r, int c) { if (gua[3] < hup[2]) gi3 = 1; }
void cp_l_u_EA(unsigned int r, int c) { if (gua[3] < hps->au[c]) gi3 = 1; }
void cp_l_u_EQ(unsigned int r, int c) { if (gua[3] < hps->au[4]) gi3 = 1; }
void cp_l_u_ED(unsigned int r, int c) { if (gua[3] < hps->mu) gi3 = 1; }
void cp_l_u_ET(unsigned int r, int c) { unsigned int *v = hup; if (gua[3] < v[1]) gi3 = 1; }
void cp_e_u_GP(unsigned int r, int c) { if (gu == *hup) gi3 = 1; }
void cp_e_u_GI(unsigned int r, int c) { if (gu == hup[2]) gi3 = 1; }
void cp_e_u_GA(unsigned int r, int c) { if (gu == hps->au[c]) gi3 = 1; }
void cp_e_u_GQ(unsigned int r, int c) { if (gu == hps->au[4]) gi3 = 1; }
void cp_e_u_GD(unsigned int r, int c) { if (gu == hps->mu) gi3 = 1; }
void cp_e_u_GT(unsigned int r, int c) { unsigned int *v = hup; if (gu == v[1]) gi3 = 1; }
void cp_e_u_RP(unsigned int r, int c) { if (r == *hup) gi3 = 1; }
void cp_e_u_RI(unsigned int r, int c) { if (r == hup[2]) gi3 = 1; }
void cp_e_u_RA(unsigned int r, int c) { if (r == hps->au[c]) gi3 = 1; }
void cp_e_u_RQ(unsigned int r, int c) { if (r == hps->au[4]) gi3 = 1; }
void cp_e_u_RD(unsigned int r, int c) { if (r == hps->mu) gi3 = 1; }
void cp_e_u_RT(unsigned int r, int c) { unsigned int *v = hup; if (r == v[1]) gi3 = 1; }
void cp_e_u_DP(unsigned int r, int c) { if (gps->mu == *hup) gi3 = 1; }
void cp_e_u_DI(unsigned int r, int c) { if (gps->mu == hup[2]) gi3 = 1; }
void cp_e_u_DA(unsigned int r, int c) { if (gps->mu == hps->au[c]) gi3 = 1; }
void cp_e_u_DQ(unsigned int r, int c) { if (gps->mu == hps->au[4]) gi3 = 1; }
void cp_e_u_DD(unsigned int r, int c) { if (gps->mu == hps->mu) gi3 = 1; }
void cp_e_u_DT(unsigned int r, int c) { unsigned int *v = hup; if (gps->mu == v[1]) gi3 = 1; }
void cp_e_u_EP(unsigned int r, int c) { if (gua[3] == *hup) gi3 = 1; }
void cp_e_u_EI(unsigned int r, int c) { if (gua[3] == hup[2]) gi3 = 1; }
void cp_e_u_EA(unsigned int r, int c) { if (gua[3] == hps->au[c]) gi3 = 1; }
void cp_e_u_EQ(unsigned int r, int c) { if (gua[3] == hps->au[4]) gi3 = 1; }
void cp_e_u_ED(unsigned int r, int c) { if (gua[3] == hps->mu) gi3 = 1; }
void cp_e_u_ET(unsigned int r, int c) { unsigned int *v = hup; if (gua[3] == v[1]) gi3 = 1; }

void cp_l_l_GP(long r, int c) { if (gl < *hlp) gi3 = 1; }
void cp_l_l_GI(long r, int c) { if (gl < hlp[2]) gi3 = 1; }
void cp_l_l_GA(long r, int c) { if (gl < hps->al[c]) gi3 = 1; }
void cp_l_l_GQ(long r, int c) { if (gl < hps->al[4]) gi3 = 1; }
void cp_l_l_GD(long r, int c) { if (gl < hps->ml) gi3 = 1; }
void cp_l_l_GT(long r, int c) { long *v = hlp; if (gl < v[1]) gi3 = 1; }
void cp_l_l_RP(long r, int c) { if (r < *hlp) gi3 = 1; }
void cp_l_l_RI(long r, int c) { if (r < hlp[2]) gi3 = 1; }
void cp_l_l_RA(long r, int c) { if (r < hps->al[c]) gi3 = 1; }
void cp_l_l_RQ(long r, int c) { if (r < hps->al[4]) gi3 = 1; }
void cp_l_l_RD(long r, int c) { if (r < hps->ml) gi3 = 1; }
void cp_l_l_RT(long r, int c) { long *v = hlp; if (r < v[1]) gi3 = 1; }
void cp_l_l_DP(long r, int c) { if (gps->ml < *hlp) gi3 = 1; }
void cp_l_l_DI(long r, int c) { if (gps->ml < hlp[2]) gi3 = 1; }
void cp_l_l_DA(long r, int c) { if (gps->ml < hps->al[c]) gi3 = 1; }
void cp_l_l_DQ(long r, int c) { if (gps->ml < hps->al[4]) gi3 = 1; }
void cp_l_l_DD(long r, int c) { if (gps->ml < hps->ml) gi3 = 1; }
void cp_l_l_DT(long r, int c) { long *v = hlp; if (gps->ml < v[1]) gi3 = 1; }
void cp_l_l_EP(long r, int c) { if (gla[3] < *hlp) gi3 = 1; }
void cp_l_l_EI(long r, int c) { if (gla[3] < hlp[2]) gi3 = 1; }
void cp_l_l_EA(long r, int c) { if (gla[3] < hps->al[c]) gi3 = 1; }
void cp_l_l_EQ(long r, int c) { if (gla[3] < hps->al[4]) gi3 = 1; }
void cp_l_l_ED(long r, int c) { if (gla[3] < hps->ml) gi3 = 1; }
void cp_l_l_ET(long r, int c) { long *v = hlp; if (gla[3] < v[1]) gi3 = 1; }
void cp_e_l_GP(long r, int c) { if (gl == *hlp) gi3 = 1; }
void cp_e_l_GI(long r, int c) { if (gl == hlp[2]) gi3 = 1; }
void cp_e_l_GA(long r, int c) { if (gl == hps->al[c]) gi3 = 1; }
void cp_e_l_GQ(long r, int c) { if (gl == hps->al[4]) gi3 = 1; }
void cp_e_l_GD(long r, int c) { if (gl == hps->ml) gi3 = 1; }
void cp_e_l_GT(long r, int c) { long *v = hlp; if (gl == v[1]) gi3 = 1; }
void cp_e_l_RP(long r, int c) { if (r == *hlp) gi3 = 1; }
void cp_e_l_RI(long r, int c) { if (r == hlp[2]) gi3 = 1; }
void cp_e_l_RA(long r, int c) { if (r == hps->al[c]) gi3 = 1; }
void cp_e_l_RQ(long r, int c) { if (r == hps->al[4]) gi3 = 1; }
void cp_e_l_RD(long r, int c) { if (r == hps->ml) gi3 = 1; }
void cp_e_l_RT(long r, int c) { long *v = hlp; if (r == v[1]) gi3 = 1; }
void cp_e_l_DP(long r, int c) { if (gps->ml == *hlp) gi3 = 1; }
void cp_e_l_DI(long r, int c) { if (gps->ml == hlp[2]) gi3 = 1; }
void cp_e_l_DA(long r, int c) { if (gps->ml == hps->al[c]) gi3 = 1; }
void cp_e_l_DQ(long r, int c) { if (gps->ml == hps->al[4]) gi3 = 1; }
void cp_e_l_DD(long r, int c) { if (gps->ml == hps->ml) gi3 = 1; }
void cp_e_l_DT(long r, int c) { long *v = hlp; if (gps->ml == v[1]) gi3 = 1; }
void cp_e_l_EP(long r, int c) { if (gla[3] == *hlp) gi3 = 1; }
void cp_e_l_EI(long r, int c) { if (gla[3] == hlp[2]) gi3 = 1; }
void cp_e_l_EA(long r, int c) { if (gla[3] == hps->al[c]) gi3 = 1; }
void cp_e_l_EQ(long r, int c) { if (gla[3] == hps->al[4]) gi3 = 1; }
void cp_e_l_ED(long r, int c) { if (gla[3] == hps->ml) gi3 = 1; }
void cp_e_l_ET(long r, int c) { long *v = hlp; if (gla[3] == v[1]) gi3 = 1; }

void cp_l_n_GP(unsigned long r, int c) { if (gn < *hnp) gi3 = 1; }
void cp_l_n_GI(unsigned long r, int c) { if (gn < hnp[2]) gi3 = 1; }
void cp_l_n_GA(unsigned long r, int c) { if (gn < hps->an[c]) gi3 = 1; }
void cp_l_n_GQ(unsigned long r, int c) { if (gn < hps->an[4]) gi3 = 1; }
void cp_l_n_GD(unsigned long r, int c) { if (gn < hps->mn) gi3 = 1; }
void cp_l_n_GT(unsigned long r, int c) { unsigned long *v = hnp; if (gn < v[1]) gi3 = 1; }
void cp_l_n_RP(unsigned long r, int c) { if (r < *hnp) gi3 = 1; }
void cp_l_n_RI(unsigned long r, int c) { if (r < hnp[2]) gi3 = 1; }
void cp_l_n_RA(unsigned long r, int c) { if (r < hps->an[c]) gi3 = 1; }
void cp_l_n_RQ(unsigned long r, int c) { if (r < hps->an[4]) gi3 = 1; }
void cp_l_n_RD(unsigned long r, int c) { if (r < hps->mn) gi3 = 1; }
void cp_l_n_RT(unsigned long r, int c) { unsigned long *v = hnp; if (r < v[1]) gi3 = 1; }
void cp_l_n_DP(unsigned long r, int c) { if (gps->mn < *hnp) gi3 = 1; }
void cp_l_n_DI(unsigned long r, int c) { if (gps->mn < hnp[2]) gi3 = 1; }
void cp_l_n_DA(unsigned long r, int c) { if (gps->mn < hps->an[c]) gi3 = 1; }
void cp_l_n_DQ(unsigned long r, int c) { if (gps->mn < hps->an[4]) gi3 = 1; }
void cp_l_n_DD(unsigned long r, int c) { if (gps->mn < hps->mn) gi3 = 1; }
void cp_l_n_DT(unsigned long r, int c) { unsigned long *v = hnp; if (gps->mn < v[1]) gi3 = 1; }
void cp_l_n_EP(unsigned long r, int c) { if (gna[3] < *hnp) gi3 = 1; }
void cp_l_n_EI(unsigned long r, int c) { if (gna[3] < hnp[2]) gi3 = 1; }
void cp_l_n_EA(unsigned long r, int c) { if (gna[3] < hps->an[c]) gi3 = 1; }
void cp_l_n_EQ(unsigned long r, int c) { if (gna[3] < hps->an[4]) gi3 = 1; }
void cp_l_n_ED(unsigned long r, int c) { if (gna[3] < hps->mn) gi3 = 1; }
void cp_l_n_ET(unsigned long r, int c) { unsigned long *v = hnp; if (gna[3] < v[1]) gi3 = 1; }
void cp_e_n_GP(unsigned long r, int c) { if (gn == *hnp) gi3 = 1; }
void cp_e_n_GI(unsigned long r, int c) { if (gn == hnp[2]) gi3 = 1; }
void cp_e_n_GA(unsigned long r, int c) { if (gn == hps->an[c]) gi3 = 1; }
void cp_e_n_GQ(unsigned long r, int c) { if (gn == hps->an[4]) gi3 = 1; }
void cp_e_n_GD(unsigned long r, int c) { if (gn == hps->mn) gi3 = 1; }
void cp_e_n_GT(unsigned long r, int c) { unsigned long *v = hnp; if (gn == v[1]) gi3 = 1; }
void cp_e_n_RP(unsigned long r, int c) { if (r == *hnp) gi3 = 1; }
void cp_e_n_RI(unsigned long r, int c) { if (r == hnp[2]) gi3 = 1; }
void cp_e_n_RA(unsigned long r, int c) { if (r == hps->an[c]) gi3 = 1; }
void cp_e_n_RQ(unsigned long r, int c) { if (r == hps->an[4]) gi3 = 1; }
void cp_e_n_RD(unsigned long r, int c) { if (r == hps->mn) gi3 = 1; }
void cp_e_n_RT(unsigned long r, int c) { unsigned long *v = hnp; if (r == v[1]) gi3 = 1; }
void cp_e_n_DP(unsigned long r, int c) { if (gps->mn == *hnp) gi3 = 1; }
void cp_e_n_DI(unsigned long r, int c) { if (gps->mn == hnp[2]) gi3 = 1; }
void cp_e_n_DA(unsigned long r, int c) { if (gps->mn == hps->an[c]) gi3 = 1; }
void cp_e_n_DQ(unsigned long r, int c) { if (gps->mn == hps->an[4]) gi3 = 1; }
void cp_e_n_DD(unsigned long r, int c) { if (gps->mn == hps->mn) gi3 = 1; }
void cp_e_n_DT(unsigned long r, int c) { unsigned long *v = hnp; if (gps->mn == v[1]) gi3 = 1; }
void cp_e_n_EP(unsigned long r, int c) { if (gna[3] == *hnp) gi3 = 1; }
void cp_e_n_EI(unsigned long r, int c) { if (gna[3] == hnp[2]) gi3 = 1; }
void cp_e_n_EA(unsigned long r, int c) { if (gna[3] == hps->an[c]) gi3 = 1; }
void cp_e_n_EQ(unsigned long r, int c) { if (gna[3] == hps->an[4]) gi3 = 1; }
void cp_e_n_ED(unsigned long r, int c) { if (gna[3] == hps->mn) gi3 = 1; }
void cp_e_n_ET(unsigned long r, int c) { unsigned long *v = hnp; if (gna[3] == v[1]) gi3 = 1; }

void cc_c_b_GGl(unsigned char r, char c) { if ((unsigned char)hc < gb) gi3 = 1; }
void cc_c_b_GGr(unsigned char r, char c) { if (gb < (unsigned char)hc) gi3 = 1; }
void cc_c_b_GEl(unsigned char r, char c) { if ((unsigned char)hca[3] < gb) gi3 = 1; }
void cc_c_b_GEr(unsigned char r, char c) { if (gb < (unsigned char)hca[3]) gi3 = 1; }
void cc_c_b_XGl(unsigned char r, char c) { if ((unsigned char)hc < gba[c]) gi3 = 1; }
void cc_c_b_XGr(unsigned char r, char c) { if (gba[c] < (unsigned char)hc) gi3 = 1; }
void cc_c_b_XEl(unsigned char r, char c) { if ((unsigned char)hca[3] < gba[c]) gi3 = 1; }
void cc_c_b_XEr(unsigned char r, char c) { if (gba[c] < (unsigned char)hca[3]) gi3 = 1; }
void cc_c_b_RGl(unsigned char r, char c) { if ((unsigned char)hc < r) gi3 = 1; }
void cc_c_b_RGr(unsigned char r, char c) { if (r < (unsigned char)hc) gi3 = 1; }
void cc_c_b_REl(unsigned char r, char c) { if ((unsigned char)hca[3] < r) gi3 = 1; }
void cc_c_b_REr(unsigned char r, char c) { if (r < (unsigned char)hca[3]) gi3 = 1; }
void cc_c_i_GGl(int r, char c) { if ((int)hc < gi) gi3 = 1; }
void cc_c_i_GGr(int r, char c) { if (gi < (int)hc) gi3 = 1; }
void cc_c_i_GEl(int r, char c) { if ((int)hca[3] < gi) gi3 = 1; }
void cc_c_i_GEr(int r, char c) { if (gi < (int)hca[3]) gi3 = 1; }
void cc_c_i_XGl(int r, char c) { if ((int)hc < gia[c]) gi3 = 1; }
void cc_c_i_XGr(int r, char c) { if (gia[c] < (int)hc) gi3 = 1; }
void cc_c_i_XEl(int r, char c) { if ((int)hca[3] < gia[c]) gi3 = 1; }
void cc_c_i_XEr(int r, char c) { if (gia[c] < (int)hca[3]) gi3 = 1; }
void cc_c_i_RGl(int r, char c) { if ((int)hc < r) gi3 = 1; }
void cc_c_i_RGr(int r, char c) { if (r < (int)hc) gi3 = 1; }
void cc_c_i_REl(int r, char c) { if ((int)hca[3] < r) gi3 = 1; }
void cc_c_i_REr(int r, char c) { if (r < (int)hca[3]) gi3 = 1; }
void cc_c_u_GGl(unsigned int r, char c) { if ((unsigned int)hc < gu) gi3 = 1; }
void cc_c_u_GGr(unsigned int r, char c) { if (gu < (unsigned int)hc) gi3 = 1; }
void cc_c_u_GEl(unsigned int r, char c) { if ((unsigned int)hca[3] < gu) gi3 = 1; }
void cc_c_u_GEr(unsigned int r, char c) { if (gu < (unsigned int)hca[3]) gi3 = 1; }
void cc_c_u_XGl(unsigned int r, char c) { if ((unsigned int)hc < gua[c]) gi3 = 1; }
void cc_c_u_XGr(unsigned int r, char c) { if (gua[c] < (unsigned int)hc) gi3 = 1; }
void cc_c_u_XEl(unsigned int r, char c) { if ((unsigned int)hca[3] < gua[c]) gi3 = 1; }
void cc_c_u_XEr(unsigned int r, char c) { if (gua[c] < (unsigned int)hca[3]) gi3 = 1; }
void cc_c_u_RGl(unsigned int r, char c) { if ((unsigned int)hc < r) gi3 = 1; }
void cc_c_u_RGr(unsigned int r, char c) { if (r < (unsigned int)hc) gi3 = 1; }
void cc_c_u_REl(unsigned int r, char c) { if ((unsigned int)hca[3] < r) gi3 = 1; }
void cc_c_u_REr(unsigned int r, char c) { if (r < (unsigned int)hca[3]) gi3 = 1; }
void cc_c_l_GGl(long r, char c) { if ((long)hc < gl) gi3 = 1; }
void cc_c_l_GGr(long r, char c) { if (gl < (long)hc) gi3 = 1; }
void cc_c_l_GEl(long r, char c) { if ((long)hca[3] < gl) gi3 = 1; }
void cc_c_l_GEr(long r, char c) { if (gl < (long)hca[3]) gi3 = 1; }
void cc_c_l_XGl(long r, char c) { if ((long)hc < gla[c]) gi3 = 1; }
void cc_c_l_XGr(long r, char c) { if (gla[c] < (long)hc) gi3 = 1; }
void cc_c_l_XEl(long r, char c) { if ((long)hca[3] < gla[c]) gi3 = 1; }
void cc_c_l_XEr(long r, char c) { if (gla[c] < (long)hca[3]) gi3 = 1; }
void cc_c_l_RGl(long r, char c) { if ((long)hc < r) gi3 = 1; }
void cc_c_l_RGr(long r, char c) { if (r < (long)hc) gi3 = 1; }
void cc_c_l_REl(long r, char c) { if ((long)hca[3] < r) gi3 = 1; }
void cc_c_l_REr(long r, char c) { if (r < (long)hca[3]) gi3 = 1; }
void cc_c_n_GGl(unsigned long r, char c) { if ((unsigned long)hc < gn) gi3 = 1; }
void cc_c_n_GGr(unsigned long r, char c) { if (gn < (unsigned long)hc) gi3 = 1; }
void cc_c_n_GEl(unsigned long r, char c) { if ((unsigned long)hca[3] < gn) gi3 = 1; }
void cc_c_n_GEr(unsigned long r, char c) { if (gn < (unsigned long)hca[3]) gi3 = 1; }
void cc_c_n_XGl(unsigned long r, char c) { if ((unsigned long)hc < gna[c]) gi3 = 1; }
void cc_c_n_XGr(unsigned long r, char c) { if (gna[c] < (unsigned long)hc) gi3 = 1; }
void cc_c_n_XEl(unsigned long r, char c) { if ((unsigned long)hca[3] < gna[c]) gi3 = 1; }
void cc_c_n_XEr(unsigned long r, char c) { if (gna[c] < (unsigned long)hca[3]) gi3 = 1; }
void cc_c_n_RGl(unsigned long r, char c) { if ((unsigned long)hc < r) gi3 = 1; }
void cc_c_n_RGr(unsigned long r, char c) { if (r < (unsigned long)hc) gi3 = 1; }
void cc_c_n_REl(unsigned long r, char c) { if ((unsigned long)hca[3] < r) gi3 = 1; }
void cc_c_n_REr(unsigned long r, char c) { if (r < (unsigned long)hca[3]) gi3 = 1; }

void cc_b_c_GGl(char r, char c) { if ((char)hb < gc) gi3 = 1; }
void cc_b_c_GGr(char r, char c) { if (gc < (char)hb) gi3 = 1; }
void cc_b_c_GEl(char r, char c) { if ((char)hba[3] < gc) gi3 = 1; }
void cc_b_c_GEr(char r, char c) { if (gc < (char)hba[3]) gi3 = 1; }
void cc_b_c_XGl(char r, char c) { if ((char)hb < gca[c]) gi3 = 1; }
void cc_b_c_XGr(char r, char c) { if (gca[c] < (char)hb) gi3 = 1; }
void cc_b_c_XEl(char r, char c) { if ((char)hba[3] < gca[c]) gi3 = 1; }
void cc_b_c_XEr(char r, char c) { if (gca[c] < (char)hba[3]) gi3 = 1; }
void cc_b_c_RGl(char r, char c) { if ((char)hb < r) gi3 = 1; }
void cc_b_c_RGr(char r, char c) { if (r < (char)hb) gi3 = 1; }
void cc_b_c_REl(char r, char c) { if ((char)hba[3] < r) gi3 = 1; }
void cc_b_c_REr(char r, char c) { if (r < (char)hba[3]) gi3 = 1; }
void cc_b_i_GGl(int r, char c) { if ((int)hb < gi) gi3 = 1; }
void cc_b_i_GGr(int r, char c) { if (gi < (int)hb) gi3 = 1; }
void cc_b_i_GEl(int r, char c) { if ((int)hba[3] < gi) gi3 = 1; }
void cc_b_i_GEr(int r, char c) { if (gi < (int)hba[3]) gi3 = 1; }
void cc_b_i_XGl(int r, char c) { if ((int)hb < gia[c]) gi3 = 1; }
void cc_b_i_XGr(int r, char c) { if (gia[c] < (int)hb) gi3 = 1; }
void cc_b_i_XEl(int r, char c) { if ((int)hba[3] < gia[c]) gi3 = 1; }
void cc_b_i_XEr(int r, char c) { if (gia[c] < (int)hba[3]) gi3 = 1; }
void cc_b_i_RGl(int r, char c) { if ((int)hb < r) gi3 = 1; }
void cc_b_i_RGr(int r, char c) { if (r < (int)hb) gi3 = 1; }
void cc_b_i_REl(int r, char c) { if ((int)hba[3] < r) gi3 = 1; }
void cc_b_i_REr(int r, char c) { if (r < (int)hba[3]) gi3 = 1; }
void cc_b_u_GGl(unsigned int r, char c) { if ((unsigned int)hb < gu) gi3 = 1; }
void cc_b_u_GGr(unsigned int r, char c) { if (gu < (unsigned int)hb) gi3 = 1; }
void cc_b_u_GEl(unsigned int r, char c) { if ((unsigned int)hba[3] < gu) gi3 = 1; }
void cc_b_u_GEr(unsigned int r, char c) { if (gu < (unsigned int)hba[3]) gi3 = 1; }
void cc_b_u_XGl(unsigned int r, char c) { if ((unsigned int)hb < gua[c]) gi3 = 1; }
void cc_b_u_XGr(unsigned int r, char c) { if (gua[c] < (unsigned int)hb) gi3 = 1; }
void cc_b_u_XEl(unsigned int r, char c) { if ((unsigned int)hba[3] < gua[c]) gi3 = 1; }
void cc_b_u_XEr(unsigned int r, char c) { if (gua[c] < (unsigned int)hba[3]) gi3 = 1; }
void cc_b_u_RGl(unsigned int r, char c) { if ((unsigned int)hb < r) gi3 = 1; }
void cc_b_u_RGr(unsigned int r, char c) { if (r < (unsigned int)hb) gi3 = 1; }
void cc_b_u_REl(unsigned int r, char c) { if ((unsigned int)hba[3] < r) gi3 = 1; }
void cc_b_u_REr(unsigned int r, char c) { if (r < (unsigned int)hba[3]) gi3 = 1; }
void cc_b_l_GGl(long r, char c) { if ((long)hb < gl) gi3 = 1; }
void cc_b_l_GGr(long r, char c) { if (gl < (long)hb) gi3 = 1; }
void cc_b_l_GEl(long r, char c) { if ((long)hba[3] < gl) gi3 = 1; }
void cc_b_l_GEr(long r, char c) { if (gl < (long)hba[3]) gi3 = 1; }
void cc_b_l_XGl(long r, char c) { if ((long)hb < gla[c]) gi3 = 1; }
void cc_b_l_XGr(long r, char c) { if (gla[c] < (long)hb) gi3 = 1; }
void cc_b_l_XEl(long r, char c) { if ((long)hba[3] < gla[c]) gi3 = 1; }
void cc_b_l_XEr(long r, char c) { if (gla[c] < (long)hba[3]) gi3 = 1; }
void cc_b_l_RGl(long r, char c) { if ((long)hb < r) gi3 = 1; }
void cc_b_l_RGr(long r, char c) { if (r < (long)hb) gi3 = 1; }
void cc_b_l_REl(long r, char c) { if ((long)hba[3] < r) gi3 = 1; }
void cc_b_l_REr(long r, char c) { if (r < (long)hba[3]) gi3 = 1; }
void cc_b_n_GGl(unsigned long r, char c) { if ((unsigned long)hb < gn) gi3 = 1; }
void cc_b_n_GGr(unsigned long r, char c) { if (gn < (unsigned long)hb) gi3 = 1; }
void cc_b_n_GEl(unsigned long r, char c) { if ((unsigned long)hba[3] < gn) gi3 = 1; }
void cc_b_n_GEr(unsigned long r, char c) { if (gn < (unsigned long)hba[3]) gi3 = 1; }
void cc_b_n_XGl(unsigned long r, char c) { if ((unsigned long)hb < gna[c]) gi3 = 1; }
void cc_b_n_XGr(unsigned long r, char c) { if (gna[c] < (unsigned long)hb) gi3 = 1; }
void cc_b_n_XEl(unsigned long r, char c) { if ((unsigned long)hba[3] < gna[c]) gi3 = 1; }
void cc_b_n_XEr(unsigned long r, char c) { if (gna[c] < (unsigned long)hba[3]) gi3 = 1; }
void cc_b_n_RGl(unsigned long r, char c) { if ((unsigned long)hb < r) gi3 = 1; }
void cc_b_n_RGr(unsigned long r, char c) { if (r < (unsigned long)hb) gi3 = 1; }
void cc_b_n_REl(unsigned long r, char c) { if ((unsigned long)hba[3] < r) gi3 = 1; }
void cc_b_n_REr(unsigned long r, char c) { if (r < (unsigned long)hba[3]) gi3 = 1; }

void cc_i_c_GGl(char r, char c) { if ((char)hi < gc) gi3 = 1; }
void cc_i_c_GGr(char r, char c) { if (gc < (char)hi) gi3 = 1; }
void cc_i_c_GEl(char r, char c) { if ((char)hia[3] < gc) gi3 = 1; }
void cc_i_c_GEr(char r, char c) { if (gc < (char)hia[3]) gi3 = 1; }
void cc_i_c_XGl(char r, char c) { if ((char)hi < gca[c]) gi3 = 1; }
void cc_i_c_XGr(char r, char c) { if (gca[c] < (char)hi) gi3 = 1; }
void cc_i_c_XEl(char r, char c) { if ((char)hia[3] < gca[c]) gi3 = 1; }
void cc_i_c_XEr(char r, char c) { if (gca[c] < (char)hia[3]) gi3 = 1; }
void cc_i_c_RGl(char r, char c) { if ((char)hi < r) gi3 = 1; }
void cc_i_c_RGr(char r, char c) { if (r < (char)hi) gi3 = 1; }
void cc_i_c_REl(char r, char c) { if ((char)hia[3] < r) gi3 = 1; }
void cc_i_c_REr(char r, char c) { if (r < (char)hia[3]) gi3 = 1; }
void cc_i_b_GGl(unsigned char r, char c) { if ((unsigned char)hi < gb) gi3 = 1; }
void cc_i_b_GGr(unsigned char r, char c) { if (gb < (unsigned char)hi) gi3 = 1; }
void cc_i_b_GEl(unsigned char r, char c) { if ((unsigned char)hia[3] < gb) gi3 = 1; }
void cc_i_b_GEr(unsigned char r, char c) { if (gb < (unsigned char)hia[3]) gi3 = 1; }
void cc_i_b_XGl(unsigned char r, char c) { if ((unsigned char)hi < gba[c]) gi3 = 1; }
void cc_i_b_XGr(unsigned char r, char c) { if (gba[c] < (unsigned char)hi) gi3 = 1; }
void cc_i_b_XEl(unsigned char r, char c) { if ((unsigned char)hia[3] < gba[c]) gi3 = 1; }
void cc_i_b_XEr(unsigned char r, char c) { if (gba[c] < (unsigned char)hia[3]) gi3 = 1; }
void cc_i_b_RGl(unsigned char r, char c) { if ((unsigned char)hi < r) gi3 = 1; }
void cc_i_b_RGr(unsigned char r, char c) { if (r < (unsigned char)hi) gi3 = 1; }
void cc_i_b_REl(unsigned char r, char c) { if ((unsigned char)hia[3] < r) gi3 = 1; }
void cc_i_b_REr(unsigned char r, char c) { if (r < (unsigned char)hia[3]) gi3 = 1; }
void cc_i_u_GGl(unsigned int r, char c) { if ((unsigned int)hi < gu) gi3 = 1; }
void cc_i_u_GGr(unsigned int r, char c) { if (gu < (unsigned int)hi) gi3 = 1; }
void cc_i_u_GEl(unsigned int r, char c) { if ((unsigned int)hia[3] < gu) gi3 = 1; }
void cc_i_u_GEr(unsigned int r, char c) { if (gu < (unsigned int)hia[3]) gi3 = 1; }
void cc_i_u_XGl(unsigned int r, char c) { if ((unsigned int)hi < gua[c]) gi3 = 1; }
void cc_i_u_XGr(unsigned int r, char c) { if (gua[c] < (unsigned int)hi) gi3 = 1; }
void cc_i_u_XEl(unsigned int r, char c) { if ((unsigned int)hia[3] < gua[c]) gi3 = 1; }
void cc_i_u_XEr(unsigned int r, char c) { if (gua[c] < (unsigned int)hia[3]) gi3 = 1; }
void cc_i_u_RGl(unsigned int r, char c) { if ((unsigned int)hi < r) gi3 = 1; }
void cc_i_u_RGr(unsigned int r, char c) { if (r < (unsigned int)hi) gi3 = 1; }
void cc_i_u_REl(unsigned int r, char c) { if ((unsigned int)hia[3] < r) gi3 = 1; }
void cc_i_u_REr(unsigned int r, char c) { if (r < (unsigned int)hia[3]) gi3 = 1; }
void cc_i_l_GGl(long r, char c) { if ((long)hi < gl) gi3 = 1; }
void cc_i_l_GGr(long r, char c) { if (gl < (long)hi) gi3 = 1; }
void cc_i_l_GEl(long r, char c) { if ((long)hia[3] < gl) gi3 = 1; }
void cc_i_l_GEr(long r, char c) { if (gl < (long)hia[3]) gi3 = 1; }
void cc_i_l_XGl(long r, char c) { if ((long)hi < gla[c]) gi3 = 1; }
void cc_i_l_XGr(long r, char c) { if (gla[c] < (long)hi) gi3 = 1; }
void cc_i_l_XEl(long r, char c) { if ((long)hia[3] < gla[c]) gi3 = 1; }
void cc_i_l_XEr(long r, char c) { if (gla[c] < (long)hia[3]) gi3 = 1; }
void cc_i_l_RGl(long r, char c) { if ((long)hi < r) gi3 = 1; }
void cc_i_l_RGr(long r, char c) { if (r < (long)hi) gi3 = 1; }
void cc_i_l_REl(long r, char c) { if ((long)hia[3] < r) gi3 = 1; }
void cc_i_l_REr(long r, char c) { if (r < (long)hia[3]) gi3 = 1; }
void cc_i_n_GGl(unsigned long r, char c) { if ((unsigned long)hi < gn) gi3 = 1; }
void cc_i_n_GGr(unsigned long r, char c) { if (gn < (unsigned long)hi) gi3 = 1; }
void cc_i_n_GEl(unsigned long r, char c) { if ((unsigned long)hia[3] < gn) gi3 = 1; }
void cc_i_n_GEr(unsigned long r, char c) { if (gn < (unsigned long)hia[3]) gi3 = 1; }
void cc_i_n_XGl(unsigned long r, char c) { if ((unsigned long)hi < gna[c]) gi3 = 1; }
void cc_i_n_XGr(unsigned long r, char c) { if (gna[c] < (unsigned long)hi) gi3 = 1; }
void cc_i_n_XEl(unsigned long r, char c) { if ((unsigned long)hia[3] < gna[c]) gi3 = 1; }
void cc_i_n_XEr(unsigned long r, char c) { if (gna[c] < (unsigned long)hia[3]) gi3 = 1; }
void cc_i_n_RGl(unsigned long r, char c) { if ((unsigned long)hi < r) gi3 = 1; }
void cc_i_n_RGr(unsigned long r, char c) { if (r < (unsigned long)hi) gi3 = 1; }
void cc_i_n_REl(unsigned long r, char c) { if ((unsigned long)hia[3] < r) gi3 = 1; }
void cc_i_n_REr(unsigned long r, char c) { if (r < (unsigned long)hia[3]) gi3 = 1; }

void cc_u_c_GGl(char r, char c) { if ((char)hu < gc) gi3 = 1; }
void cc_u_c_GGr(char r, char c) { if (gc < (char)hu) gi3 = 1; }
void cc_u_c_GEl(char r, char c) { if ((char)hua[3] < gc) gi3 = 1; }
void cc_u_c_GEr(char r, char c) { if (gc < (char)hua[3]) gi3 = 1; }
void cc_u_c_XGl(char r, char c) { if ((char)hu < gca[c]) gi3 = 1; }
void cc_u_c_XGr(char r, char c) { if (gca[c] < (char)hu) gi3 = 1; }
void cc_u_c_XEl(char r, char c) { if ((char)hua[3] < gca[c]) gi3 = 1; }
void cc_u_c_XEr(char r, char c) { if (gca[c] < (char)hua[3]) gi3 = 1; }
void cc_u_c_RGl(char r, char c) { if ((char)hu < r) gi3 = 1; }
void cc_u_c_RGr(char r, char c) { if (r < (char)hu) gi3 = 1; }
void cc_u_c_REl(char r, char c) { if ((char)hua[3] < r) gi3 = 1; }
void cc_u_c_REr(char r, char c) { if (r < (char)hua[3]) gi3 = 1; }
void cc_u_b_GGl(unsigned char r, char c) { if ((unsigned char)hu < gb) gi3 = 1; }
void cc_u_b_GGr(unsigned char r, char c) { if (gb < (unsigned char)hu) gi3 = 1; }
void cc_u_b_GEl(unsigned char r, char c) { if ((unsigned char)hua[3] < gb) gi3 = 1; }
void cc_u_b_GEr(unsigned char r, char c) { if (gb < (unsigned char)hua[3]) gi3 = 1; }
void cc_u_b_XGl(unsigned char r, char c) { if ((unsigned char)hu < gba[c]) gi3 = 1; }
void cc_u_b_XGr(unsigned char r, char c) { if (gba[c] < (unsigned char)hu) gi3 = 1; }
void cc_u_b_XEl(unsigned char r, char c) { if ((unsigned char)hua[3] < gba[c]) gi3 = 1; }
void cc_u_b_XEr(unsigned char r, char c) { if (gba[c] < (unsigned char)hua[3]) gi3 = 1; }
void cc_u_b_RGl(unsigned char r, char c) { if ((unsigned char)hu < r) gi3 = 1; }
void cc_u_b_RGr(unsigned char r, char c) { if (r < (unsigned char)hu) gi3 = 1; }
void cc_u_b_REl(unsigned char r, char c) { if ((unsigned char)hua[3] < r) gi3 = 1; }
void cc_u_b_REr(unsigned char r, char c) { if (r < (unsigned char)hua[3]) gi3 = 1; }
void cc_u_i_GGl(int r, char c) { if ((int)hu < gi) gi3 = 1; }
void cc_u_i_GGr(int r, char c) { if (gi < (int)hu) gi3 = 1; }
void cc_u_i_GEl(int r, char c) { if ((int)hua[3] < gi) gi3 = 1; }
void cc_u_i_GEr(int r, char c) { if (gi < (int)hua[3]) gi3 = 1; }
void cc_u_i_XGl(int r, char c) { if ((int)hu < gia[c]) gi3 = 1; }
void cc_u_i_XGr(int r, char c) { if (gia[c] < (int)hu) gi3 = 1; }
void cc_u_i_XEl(int r, char c) { if ((int)hua[3] < gia[c]) gi3 = 1; }
void cc_u_i_XEr(int r, char c) { if (gia[c] < (int)hua[3]) gi3 = 1; }
void cc_u_i_RGl(int r, char c) { if ((int)hu < r) gi3 = 1; }
void cc_u_i_RGr(int r, char c) { if (r < (int)hu) gi3 = 1; }
void cc_u_i_REl(int r, char c) { if ((int)hua[3] < r) gi3 = 1; }
void cc_u_i_REr(int r, char c) { if (r < (int)hua[3]) gi3 = 1; }
void cc_u_l_GGl(long r, char c) { if ((long)hu < gl) gi3 = 1; }
void cc_u_l_GGr(long r, char c) { if (gl < (long)hu) gi3 = 1; }
void cc_u_l_GEl(long r, char c) { if ((long)hua[3] < gl) gi3 = 1; }
void cc_u_l_GEr(long r, char c) { if (gl < (long)hua[3]) gi3 = 1; }
void cc_u_l_XGl(long r, char c) { if ((long)hu < gla[c]) gi3 = 1; }
void cc_u_l_XGr(long r, char c) { if (gla[c] < (long)hu) gi3 = 1; }
void cc_u_l_XEl(long r, char c) { if ((long)hua[3] < gla[c]) gi3 = 1; }
void cc_u_l_XEr(long r, char c) { if (gla[c] < (long)hua[3]) gi3 = 1; }
void cc_u_l_RGl(long r, char c) { if ((long)hu < r) gi3 = 1; }
void cc_u_l_RGr(long r, char c) { if (r < (long)hu) gi3 = 1; }
void cc_u_l_REl(long r, char c) { if ((long)hua[3] < r) gi3 = 1; }
void cc_u_l_REr(long r, char c) { if (r < (long)hua[3]) gi3 = 1; }
void cc_u_n_GGl(unsigned long r, char c) { if ((unsigned long)hu < gn) gi3 = 1; }
void cc_u_n_GGr(unsigned long r, char c) { if (gn < (unsigned long)hu) gi3 = 1; }
void cc_u_n_GEl(unsigned long r, char c) { if ((unsigned long)hua[3] < gn) gi3 = 1; }
void cc_u_n_GEr(unsigned long r, char c) { if (gn < (unsigned long)hua[3]) gi3 = 1; }
void cc_u_n_XGl(unsigned long r, char c) { if ((unsigned long)hu < gna[c]) gi3 = 1; }
void cc_u_n_XGr(unsigned long r, char c) { if (gna[c] < (unsigned long)hu) gi3 = 1; }
void cc_u_n_XEl(unsigned long r, char c) { if ((unsigned long)hua[3] < gna[c]) gi3 = 1; }
void cc_u_n_XEr(unsigned long r, char c) { if (gna[c] < (unsigned long)hua[3]) gi3 = 1; }
void cc_u_n_RGl(unsigned long r, char c) { if ((unsigned long)hu < r) gi3 = 1; }
void cc_u_n_RGr(unsigned long r, char c) { if (r < (unsigned long)hu) gi3 = 1; }
void cc_u_n_REl(unsigned long r, char c) { if ((unsigned long)hua[3] < r) gi3 = 1; }
void cc_u_n_REr(unsigned long r, char c) { if (r < (unsigned long)hua[3]) gi3 = 1; }

void cc_l_c_GGl(char r, char c) { if ((char)hl < gc) gi3 = 1; }
void cc_l_c_GGr(char r, char c) { if (gc < (char)hl) gi3 = 1; }
void cc_l_c_GEl(char r, char c) { if ((char)hla[3] < gc) gi3 = 1; }
void cc_l_c_GEr(char r, char c) { if (gc < (char)hla[3]) gi3 = 1; }
void cc_l_c_XGl(char r, char c) { if ((char)hl < gca[c]) gi3 = 1; }
void cc_l_c_XGr(char r, char c) { if (gca[c] < (char)hl) gi3 = 1; }
void cc_l_c_XEl(char r, char c) { if ((char)hla[3] < gca[c]) gi3 = 1; }
void cc_l_c_XEr(char r, char c) { if (gca[c] < (char)hla[3]) gi3 = 1; }
void cc_l_c_RGl(char r, char c) { if ((char)hl < r) gi3 = 1; }
void cc_l_c_RGr(char r, char c) { if (r < (char)hl) gi3 = 1; }
void cc_l_c_REl(char r, char c) { if ((char)hla[3] < r) gi3 = 1; }
void cc_l_c_REr(char r, char c) { if (r < (char)hla[3]) gi3 = 1; }
void cc_l_b_GGl(unsigned char r, char c) { if ((unsigned char)hl < gb) gi3 = 1; }
void cc_l_b_GGr(unsigned char r, char c) { if (gb < (unsigned char)hl) gi3 = 1; }
void cc_l_b_GEl(unsigned char r, char c) { if ((unsigned char)hla[3] < gb) gi3 = 1; }
void cc_l_b_GEr(unsigned char r, char c) { if (gb < (unsigned char)hla[3]) gi3 = 1; }
void cc_l_b_XGl(unsigned char r, char c) { if ((unsigned char)hl < gba[c]) gi3 = 1; }
void cc_l_b_XGr(unsigned char r, char c) { if (gba[c] < (unsigned char)hl) gi3 = 1; }
void cc_l_b_XEl(unsigned char r, char c) { if ((unsigned char)hla[3] < gba[c]) gi3 = 1; }
void cc_l_b_XEr(unsigned char r, char c) { if (gba[c] < (unsigned char)hla[3]) gi3 = 1; }
void cc_l_b_RGl(unsigned char r, char c) { if ((unsigned char)hl < r) gi3 = 1; }
void cc_l_b_RGr(unsigned char r, char c) { if (r < (unsigned char)hl) gi3 = 1; }
void cc_l_b_REl(unsigned char r, char c) { if ((unsigned char)hla[3] < r) gi3 = 1; }
void cc_l_b_REr(unsigned char r, char c) { if (r < (unsigned char)hla[3]) gi3 = 1; }
void cc_l_i_GGl(int r, char c) { if ((int)hl < gi) gi3 = 1; }
void cc_l_i_GGr(int r, char c) { if (gi < (int)hl) gi3 = 1; }
void cc_l_i_GEl(int r, char c) { if ((int)hla[3] < gi) gi3 = 1; }
void cc_l_i_GEr(int r, char c) { if (gi < (int)hla[3]) gi3 = 1; }
void cc_l_i_XGl(int r, char c) { if ((int)hl < gia[c]) gi3 = 1; }
void cc_l_i_XGr(int r, char c) { if (gia[c] < (int)hl) gi3 = 1; }
void cc_l_i_XEl(int r, char c) { if ((int)hla[3] < gia[c]) gi3 = 1; }
void cc_l_i_XEr(int r, char c) { if (gia[c] < (int)hla[3]) gi3 = 1; }
void cc_l_i_RGl(int r, char c) { if ((int)hl < r) gi3 = 1; }
void cc_l_i_RGr(int r, char c) { if (r < (int)hl) gi3 = 1; }
void cc_l_i_REl(int r, char c) { if ((int)hla[3] < r) gi3 = 1; }
void cc_l_i_REr(int r, char c) { if (r < (int)hla[3]) gi3 = 1; }
void cc_l_u_GGl(unsigned int r, char c) { if ((unsigned int)hl < gu) gi3 = 1; }
void cc_l_u_GGr(unsigned int r, char c) { if (gu < (unsigned int)hl) gi3 = 1; }
void cc_l_u_GEl(unsigned int r, char c) { if ((unsigned int)hla[3] < gu) gi3 = 1; }
void cc_l_u_GEr(unsigned int r, char c) { if (gu < (unsigned int)hla[3]) gi3 = 1; }
void cc_l_u_XGl(unsigned int r, char c) { if ((unsigned int)hl < gua[c]) gi3 = 1; }
void cc_l_u_XGr(unsigned int r, char c) { if (gua[c] < (unsigned int)hl) gi3 = 1; }
void cc_l_u_XEl(unsigned int r, char c) { if ((unsigned int)hla[3] < gua[c]) gi3 = 1; }
void cc_l_u_XEr(unsigned int r, char c) { if (gua[c] < (unsigned int)hla[3]) gi3 = 1; }
void cc_l_u_RGl(unsigned int r, char c) { if ((unsigned int)hl < r) gi3 = 1; }
void cc_l_u_RGr(unsigned int r, char c) { if (r < (unsigned int)hl) gi3 = 1; }
void cc_l_u_REl(unsigned int r, char c) { if ((unsigned int)hla[3] < r) gi3 = 1; }
void cc_l_u_REr(unsigned int r, char c) { if (r < (unsigned int)hla[3]) gi3 = 1; }
void cc_l_n_GGl(unsigned long r, char c) { if ((unsigned long)hl < gn) gi3 = 1; }
void cc_l_n_GGr(unsigned long r, char c) { if (gn < (unsigned long)hl) gi3 = 1; }
void cc_l_n_GEl(unsigned long r, char c) { if ((unsigned long)hla[3] < gn) gi3 = 1; }
void cc_l_n_GEr(unsigned long r, char c) { if (gn < (unsigned long)hla[3]) gi3 = 1; }
void cc_l_n_XGl(unsigned long r, char c) { if ((unsigned long)hl < gna[c]) gi3 = 1; }
void cc_l_n_XGr(unsigned long r, char c) { if (gna[c] < (unsigned long)hl) gi3 = 1; }
void cc_l_n_XEl(unsigned long r, char c) { if ((unsigned long)hla[3] < gna[c]) gi3 = 1; }
void cc_l_n_XEr(unsigned long r, char c) { if (gna[c] < (unsigned long)hla[3]) gi3 = 1; }
void cc_l_n_RGl(unsigned long r, char c) { if ((unsigned long)hl < r) gi3 = 1; }
void cc_l_n_RGr(unsigned long r, char c) { if (r < (unsigned long)hl) gi3 = 1; }
void cc_l_n_REl(unsigned long r, char c) { if ((unsigned long)hla[3] < r) gi3 = 1; }
void cc_l_n_REr(unsigned long r, char c) { if (r < (unsigned long)hla[3]) gi3 = 1; }

void cc_n_c_GGl(char r, char c) { if ((char)hn < gc) gi3 = 1; }
void cc_n_c_GGr(char r, char c) { if (gc < (char)hn) gi3 = 1; }
void cc_n_c_GEl(char r, char c) { if ((char)hna[3] < gc) gi3 = 1; }
void cc_n_c_GEr(char r, char c) { if (gc < (char)hna[3]) gi3 = 1; }
void cc_n_c_XGl(char r, char c) { if ((char)hn < gca[c]) gi3 = 1; }
void cc_n_c_XGr(char r, char c) { if (gca[c] < (char)hn) gi3 = 1; }
void cc_n_c_XEl(char r, char c) { if ((char)hna[3] < gca[c]) gi3 = 1; }
void cc_n_c_XEr(char r, char c) { if (gca[c] < (char)hna[3]) gi3 = 1; }
void cc_n_c_RGl(char r, char c) { if ((char)hn < r) gi3 = 1; }
void cc_n_c_RGr(char r, char c) { if (r < (char)hn) gi3 = 1; }
void cc_n_c_REl(char r, char c) { if ((char)hna[3] < r) gi3 = 1; }
void cc_n_c_REr(char r, char c) { if (r < (char)hna[3]) gi3 = 1; }
void cc_n_b_GGl(unsigned char r, char c) { if ((unsigned char)hn < gb) gi3 = 1; }
void cc_n_b_GGr(unsigned char r, char c) { if (gb < (unsigned char)hn) gi3 = 1; }
void cc_n_b_GEl(unsigned char r, char c) { if ((unsigned char)hna[3] < gb) gi3 = 1; }
void cc_n_b_GEr(unsigned char r, char c) { if (gb < (unsigned char)hna[3]) gi3 = 1; }
void cc_n_b_XGl(unsigned char r, char c) { if ((unsigned char)hn < gba[c]) gi3 = 1; }
void cc_n_b_XGr(unsigned char r, char c) { if (gba[c] < (unsigned char)hn) gi3 = 1; }
void cc_n_b_XEl(unsigned char r, char c) { if ((unsigned char)hna[3] < gba[c]) gi3 = 1; }
void cc_n_b_XEr(unsigned char r, char c) { if (gba[c] < (unsigned char)hna[3]) gi3 = 1; }
void cc_n_b_RGl(unsigned char r, char c) { if ((unsigned char)hn < r) gi3 = 1; }
void cc_n_b_RGr(unsigned char r, char c) { if (r < (unsigned char)hn) gi3 = 1; }
void cc_n_b_REl(unsigned char r, char c) { if ((unsigned char)hna[3] < r) gi3 = 1; }
void cc_n_b_REr(unsigned char r, char c) { if (r < (unsigned char)hna[3]) gi3 = 1; }
void cc_n_i_GGl(int r, char c) { if ((int)hn < gi) gi3 = 1; }
void cc_n_i_GGr(int r, char c) { if (gi < (int)hn) gi3 = 1; }
void cc_n_i_GEl(int r, char c) { if ((int)hna[3] < gi) gi3 = 1; }
void cc_n_i_GEr(int r, char c) { if (gi < (int)hna[3]) gi3 = 1; }
void cc_n_i_XGl(int r, char c) { if ((int)hn < gia[c]) gi3 = 1; }
void cc_n_i_XGr(int r, char c) { if (gia[c] < (int)hn) gi3 = 1; }
void cc_n_i_XEl(int r, char c) { if ((int)hna[3] < gia[c]) gi3 = 1; }
void cc_n_i_XEr(int r, char c) { if (gia[c] < (int)hna[3]) gi3 = 1; }
void cc_n_i_RGl(int r, char c) { if ((int)hn < r) gi3 = 1; }
void cc_n_i_RGr(int r, char c) { if (r < (int)hn) gi3 = 1; }
void cc_n_i_REl(int r, char c) { if ((int)hna[3] < r) gi3 = 1; }
void cc_n_i_REr(int r, char c) { if (r < (int)hna[3]) gi3 = 1; }
void cc_n_u_GGl(unsigned int r, char c) { if ((unsigned int)hn < gu) gi3 = 1; }
void cc_n_u_GGr(unsigned int r, char c) { if (gu < (unsigned int)hn) gi3 = 1; }
void cc_n_u_GEl(unsigned int r, char c) { if ((unsigned int)hna[3] < gu) gi3 = 1; }
void cc_n_u_GEr(unsigned int r, char c) { if (gu < (unsigned int)hna[3]) gi3 = 1; }
void cc_n_u_XGl(unsigned int r, char c) { if ((unsigned int)hn < gua[c]) gi3 = 1; }
void cc_n_u_XGr(unsigned int r, char c) { if (gua[c] < (unsigned int)hn) gi3 = 1; }
void cc_n_u_XEl(unsigned int r, char c) { if ((unsigned int)hna[3] < gua[c]) gi3 = 1; }
void cc_n_u_XEr(unsigned int r, char c) { if (gua[c] < (unsigned int)hna[3]) gi3 = 1; }
void cc_n_u_RGl(unsigned int r, char c) { if ((unsigned int)hn < r) gi3 = 1; }
void cc_n_u_RGr(unsigned int r, char c) { if (r < (unsigned int)hn) gi3 = 1; }
void cc_n_u_REl(unsigned int r, char c) { if ((unsigned int)hna[3] < r) gi3 = 1; }
void cc_n_u_REr(unsigned int r, char c) { if (r < (unsigned int)hna[3]) gi3 = 1; }
void cc_n_l_GGl(long r, char c) { if ((long)hn < gl) gi3 = 1; }
void cc_n_l_GGr(long r, char c) { if (gl < (long)hn) gi3 = 1; }
void cc_n_l_GEl(long r, char c) { if ((long)hna[3] < gl) gi3 = 1; }
void cc_n_l_GEr(long r, char c) { if (gl < (long)hna[3]) gi3 = 1; }
void cc_n_l_XGl(long r, char c) { if ((long)hn < gla[c]) gi3 = 1; }
void cc_n_l_XGr(long r, char c) { if (gla[c] < (long)hn) gi3 = 1; }
void cc_n_l_XEl(long r, char c) { if ((long)hna[3] < gla[c]) gi3 = 1; }
void cc_n_l_XEr(long r, char c) { if (gla[c] < (long)hna[3]) gi3 = 1; }
void cc_n_l_RGl(long r, char c) { if ((long)hn < r) gi3 = 1; }
void cc_n_l_RGr(long r, char c) { if (r < (long)hn) gi3 = 1; }
void cc_n_l_REl(long r, char c) { if ((long)hna[3] < r) gi3 = 1; }
void cc_n_l_REr(long r, char c) { if (r < (long)hna[3]) gi3 = 1; }

void cq_i_l_FF(int r, int c) { if ((gri(hi)) < (gri(ki))) gi3 = 1; }
void cq_i_l_FA(int r, int c) { if ((gri(hi)) < (ki - hi)) gi3 = 1; }
void cq_i_l_FB(int r, int c) { if ((gri(hi)) < (ki | hi)) gi3 = 1; }
void cq_i_l_FH(int r, int c) { if ((gri(hi)) < (hi >> 5)) gi3 = 1; }
void cq_i_l_FT(int r, int c) { if ((gri(hi)) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_FP(int r, int c) { if ((gri(hi)) < (*hip * gia[2])) gi3 = 1; }
void cq_i_l_AF(int r, int c) { if ((hi - gi) < (gri(ki))) gi3 = 1; }
void cq_i_l_AA(int r, int c) { if ((hi - gi) < (ki - hi)) gi3 = 1; }
void cq_i_l_AB(int r, int c) { if ((hi - gi) < (ki | hi)) gi3 = 1; }
void cq_i_l_AH(int r, int c) { if ((hi - gi) < (hi >> 5)) gi3 = 1; }
void cq_i_l_AT(int r, int c) { if ((hi - gi) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_AP(int r, int c) { if ((hi - gi) < (*hip * gia[2])) gi3 = 1; }
void cq_i_l_BF(int r, int c) { if ((hi | gi) < (gri(ki))) gi3 = 1; }
void cq_i_l_BA(int r, int c) { if ((hi | gi) < (ki - hi)) gi3 = 1; }
void cq_i_l_BB(int r, int c) { if ((hi | gi) < (ki | hi)) gi3 = 1; }
void cq_i_l_BH(int r, int c) { if ((hi | gi) < (hi >> 5)) gi3 = 1; }
void cq_i_l_BT(int r, int c) { if ((hi | gi) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_BP(int r, int c) { if ((hi | gi) < (*hip * gia[2])) gi3 = 1; }
void cq_i_l_HF(int r, int c) { if ((gi >> 5) < (gri(ki))) gi3 = 1; }
void cq_i_l_HA(int r, int c) { if ((gi >> 5) < (ki - hi)) gi3 = 1; }
void cq_i_l_HB(int r, int c) { if ((gi >> 5) < (ki | hi)) gi3 = 1; }
void cq_i_l_HH(int r, int c) { if ((gi >> 5) < (hi >> 5)) gi3 = 1; }
void cq_i_l_HT(int r, int c) { if ((gi >> 5) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_HP(int r, int c) { if ((gi >> 5) < (*hip * gia[2])) gi3 = 1; }
void cq_i_l_TF(int r, int c) { if ((gi ? hi : ki) < (gri(ki))) gi3 = 1; }
void cq_i_l_TA(int r, int c) { if ((gi ? hi : ki) < (ki - hi)) gi3 = 1; }
void cq_i_l_TB(int r, int c) { if ((gi ? hi : ki) < (ki | hi)) gi3 = 1; }
void cq_i_l_TH(int r, int c) { if ((gi ? hi : ki) < (hi >> 5)) gi3 = 1; }
void cq_i_l_TT(int r, int c) { if ((gi ? hi : ki) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_TP(int r, int c) { if ((gi ? hi : ki) < (*hip * gia[2])) gi3 = 1; }
void cq_i_l_PF(int r, int c) { if ((*gip * hia[2]) < (gri(ki))) gi3 = 1; }
void cq_i_l_PA(int r, int c) { if ((*gip * hia[2]) < (ki - hi)) gi3 = 1; }
void cq_i_l_PB(int r, int c) { if ((*gip * hia[2]) < (ki | hi)) gi3 = 1; }
void cq_i_l_PH(int r, int c) { if ((*gip * hia[2]) < (hi >> 5)) gi3 = 1; }
void cq_i_l_PT(int r, int c) { if ((*gip * hia[2]) < (hi ? ki : gi)) gi3 = 1; }
void cq_i_l_PP(int r, int c) { if ((*gip * hia[2]) < (*hip * gia[2])) gi3 = 1; }
void cq_i_e_FF(int r, int c) { if ((gri(hi)) == (gri(ki))) gi3 = 1; }
void cq_i_e_FA(int r, int c) { if ((gri(hi)) == (ki - hi)) gi3 = 1; }
void cq_i_e_FB(int r, int c) { if ((gri(hi)) == (ki | hi)) gi3 = 1; }
void cq_i_e_FH(int r, int c) { if ((gri(hi)) == (hi >> 5)) gi3 = 1; }
void cq_i_e_FT(int r, int c) { if ((gri(hi)) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_FP(int r, int c) { if ((gri(hi)) == (*hip * gia[2])) gi3 = 1; }
void cq_i_e_AF(int r, int c) { if ((hi - gi) == (gri(ki))) gi3 = 1; }
void cq_i_e_AA(int r, int c) { if ((hi - gi) == (ki - hi)) gi3 = 1; }
void cq_i_e_AB(int r, int c) { if ((hi - gi) == (ki | hi)) gi3 = 1; }
void cq_i_e_AH(int r, int c) { if ((hi - gi) == (hi >> 5)) gi3 = 1; }
void cq_i_e_AT(int r, int c) { if ((hi - gi) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_AP(int r, int c) { if ((hi - gi) == (*hip * gia[2])) gi3 = 1; }
void cq_i_e_BF(int r, int c) { if ((hi | gi) == (gri(ki))) gi3 = 1; }
void cq_i_e_BA(int r, int c) { if ((hi | gi) == (ki - hi)) gi3 = 1; }
void cq_i_e_BB(int r, int c) { if ((hi | gi) == (ki | hi)) gi3 = 1; }
void cq_i_e_BH(int r, int c) { if ((hi | gi) == (hi >> 5)) gi3 = 1; }
void cq_i_e_BT(int r, int c) { if ((hi | gi) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_BP(int r, int c) { if ((hi | gi) == (*hip * gia[2])) gi3 = 1; }
void cq_i_e_HF(int r, int c) { if ((gi >> 5) == (gri(ki))) gi3 = 1; }
void cq_i_e_HA(int r, int c) { if ((gi >> 5) == (ki - hi)) gi3 = 1; }
void cq_i_e_HB(int r, int c) { if ((gi >> 5) == (ki | hi)) gi3 = 1; }
void cq_i_e_HH(int r, int c) { if ((gi >> 5) == (hi >> 5)) gi3 = 1; }
void cq_i_e_HT(int r, int c) { if ((gi >> 5) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_HP(int r, int c) { if ((gi >> 5) == (*hip * gia[2])) gi3 = 1; }
void cq_i_e_TF(int r, int c) { if ((gi ? hi : ki) == (gri(ki))) gi3 = 1; }
void cq_i_e_TA(int r, int c) { if ((gi ? hi : ki) == (ki - hi)) gi3 = 1; }
void cq_i_e_TB(int r, int c) { if ((gi ? hi : ki) == (ki | hi)) gi3 = 1; }
void cq_i_e_TH(int r, int c) { if ((gi ? hi : ki) == (hi >> 5)) gi3 = 1; }
void cq_i_e_TT(int r, int c) { if ((gi ? hi : ki) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_TP(int r, int c) { if ((gi ? hi : ki) == (*hip * gia[2])) gi3 = 1; }
void cq_i_e_PF(int r, int c) { if ((*gip * hia[2]) == (gri(ki))) gi3 = 1; }
void cq_i_e_PA(int r, int c) { if ((*gip * hia[2]) == (ki - hi)) gi3 = 1; }
void cq_i_e_PB(int r, int c) { if ((*gip * hia[2]) == (ki | hi)) gi3 = 1; }
void cq_i_e_PH(int r, int c) { if ((*gip * hia[2]) == (hi >> 5)) gi3 = 1; }
void cq_i_e_PT(int r, int c) { if ((*gip * hia[2]) == (hi ? ki : gi)) gi3 = 1; }
void cq_i_e_PP(int r, int c) { if ((*gip * hia[2]) == (*hip * gia[2])) gi3 = 1; }
void cq_n_l_FF(unsigned long r, int c) { if ((grn(hn)) < (grn(kn))) gi3 = 1; }
void cq_n_l_FA(unsigned long r, int c) { if ((grn(hn)) < (kn - hn)) gi3 = 1; }
void cq_n_l_FB(unsigned long r, int c) { if ((grn(hn)) < (kn | hn)) gi3 = 1; }
void cq_n_l_FH(unsigned long r, int c) { if ((grn(hn)) < (hn >> 5)) gi3 = 1; }
void cq_n_l_FT(unsigned long r, int c) { if ((grn(hn)) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_FP(unsigned long r, int c) { if ((grn(hn)) < (hn * kn)) gi3 = 1; }
void cq_n_l_AF(unsigned long r, int c) { if ((hn - gn) < (grn(kn))) gi3 = 1; }
void cq_n_l_AA(unsigned long r, int c) { if ((hn - gn) < (kn - hn)) gi3 = 1; }
void cq_n_l_AB(unsigned long r, int c) { if ((hn - gn) < (kn | hn)) gi3 = 1; }
void cq_n_l_AH(unsigned long r, int c) { if ((hn - gn) < (hn >> 5)) gi3 = 1; }
void cq_n_l_AT(unsigned long r, int c) { if ((hn - gn) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_AP(unsigned long r, int c) { if ((hn - gn) < (hn * kn)) gi3 = 1; }
void cq_n_l_BF(unsigned long r, int c) { if ((hn | gn) < (grn(kn))) gi3 = 1; }
void cq_n_l_BA(unsigned long r, int c) { if ((hn | gn) < (kn - hn)) gi3 = 1; }
void cq_n_l_BB(unsigned long r, int c) { if ((hn | gn) < (kn | hn)) gi3 = 1; }
void cq_n_l_BH(unsigned long r, int c) { if ((hn | gn) < (hn >> 5)) gi3 = 1; }
void cq_n_l_BT(unsigned long r, int c) { if ((hn | gn) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_BP(unsigned long r, int c) { if ((hn | gn) < (hn * kn)) gi3 = 1; }
void cq_n_l_HF(unsigned long r, int c) { if ((gn >> 5) < (grn(kn))) gi3 = 1; }
void cq_n_l_HA(unsigned long r, int c) { if ((gn >> 5) < (kn - hn)) gi3 = 1; }
void cq_n_l_HB(unsigned long r, int c) { if ((gn >> 5) < (kn | hn)) gi3 = 1; }
void cq_n_l_HH(unsigned long r, int c) { if ((gn >> 5) < (hn >> 5)) gi3 = 1; }
void cq_n_l_HT(unsigned long r, int c) { if ((gn >> 5) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_HP(unsigned long r, int c) { if ((gn >> 5) < (hn * kn)) gi3 = 1; }
void cq_n_l_TF(unsigned long r, int c) { if ((gn ? hn : kn) < (grn(kn))) gi3 = 1; }
void cq_n_l_TA(unsigned long r, int c) { if ((gn ? hn : kn) < (kn - hn)) gi3 = 1; }
void cq_n_l_TB(unsigned long r, int c) { if ((gn ? hn : kn) < (kn | hn)) gi3 = 1; }
void cq_n_l_TH(unsigned long r, int c) { if ((gn ? hn : kn) < (hn >> 5)) gi3 = 1; }
void cq_n_l_TT(unsigned long r, int c) { if ((gn ? hn : kn) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_TP(unsigned long r, int c) { if ((gn ? hn : kn) < (hn * kn)) gi3 = 1; }
void cq_n_l_PF(unsigned long r, int c) { if ((gn * hn) < (grn(kn))) gi3 = 1; }
void cq_n_l_PA(unsigned long r, int c) { if ((gn * hn) < (kn - hn)) gi3 = 1; }
void cq_n_l_PB(unsigned long r, int c) { if ((gn * hn) < (kn | hn)) gi3 = 1; }
void cq_n_l_PH(unsigned long r, int c) { if ((gn * hn) < (hn >> 5)) gi3 = 1; }
void cq_n_l_PT(unsigned long r, int c) { if ((gn * hn) < (hn ? kn : gn)) gi3 = 1; }
void cq_n_l_PP(unsigned long r, int c) { if ((gn * hn) < (hn * kn)) gi3 = 1; }

void cr_a(long *a, unsigned long b) { int t = gip[0]; char *u = &gca[t]; if (gua[7] < gua[t]) gi3 = 1; }
void cr_b(long *a, unsigned long b) { int t = gip[0]; if (gua[7] < gua[t]) gi3 = 1; }
void cr_c(long *a, unsigned long b) { int t = gip[0]; char *u = gcp; if (gua[7] < gua[t]) gi3 = 1; }
void cr_d(long *a, unsigned long b) { int t = gip[0]; char *u = &gca[t]; if (gia[7] < gia[t]) gi3 = 1; }

void cz_if_a(int c) { if (gi < hia[c]) gi3 = 1; }
void cz_if_b(int c) { if (gps->ai[4] == hip[1]) gi3 = 1; }
void cz_if_w(unsigned int r, unsigned char c) { if (r < hua[c]) gi3 = 1; }
void cz_if_d(int c) { if (gn < (unsigned long)hl) gi3 = 1; }
void cz_if_e(int c) { if ((long)gi != hla[c]) gi3 = 1; }
void cz_if_f(int c) { if (gc < *hcp) gi3 = 1; }
void cz_wh_a(int c) { while (gi < hia[c]) gi3++; }
void cz_wh_b(int c) { while (gps->ai[4] == hip[1]) gi3++; }
void cz_wh_w(unsigned int r, unsigned char c) { while (r < hua[c]) gi3++; }
void cz_wh_d(int c) { while (gn < (unsigned long)hl) gi3++; }
void cz_wh_e(int c) { while ((long)gi != hla[c]) gi3++; }
void cz_wh_f(int c) { while (gc < *hcp) gi3++; }
void cz_fo_a(int c) { for (gi3 = 0; gi < hia[c]; gi3++) gi2 = 1; }
void cz_fo_b(int c) { for (gi3 = 0; gps->ai[4] == hip[1]; gi3++) gi2 = 1; }
void cz_fo_w(unsigned int r, unsigned char c) { for (gi3 = 0; r < hua[c]; gi3++) gi2 = 1; }
void cz_fo_d(int c) { for (gi3 = 0; gn < (unsigned long)hl; gi3++) gi2 = 1; }
void cz_fo_e(int c) { for (gi3 = 0; (long)gi != hla[c]; gi3++) gi2 = 1; }
void cz_fo_f(int c) { for (gi3 = 0; gc < *hcp; gi3++) gi2 = 1; }
void cz_vs_a(int c) { gi3 = (gi < hia[c]); }
void cz_vs_b(int c) { gi3 = (gps->ai[4] == hip[1]); }
void cz_vs_w(unsigned int r, unsigned char c) { gi3 = (r < hua[c]); }
void cz_vs_d(int c) { gi3 = (gn < (unsigned long)hl); }
void cz_vs_e(int c) { gi3 = ((long)gi != hla[c]); }
void cz_vs_f(int c) { gi3 = (gc < *hcp); }
int cz_rt_a(int c) { return gi < hia[c]; }
int cz_rt_b(int c) { return gps->ai[4] == hip[1]; }
int cz_rt_w(unsigned int r, unsigned char c) { return r < hua[c]; }
int cz_rt_d(int c) { return gn < (unsigned long)hl; }
int cz_rt_e(int c) { return (long)gi != hla[c]; }
int cz_rt_f(int c) { return gc < *hcp; }
void cz_tn_a(int c) { gi3 = (gi < hia[c]) ? 1 : 2; }
void cz_tn_b(int c) { gi3 = (gps->ai[4] == hip[1]) ? 1 : 2; }
void cz_tn_w(unsigned int r, unsigned char c) { gi3 = (r < hua[c]) ? 1 : 2; }
void cz_tn_d(int c) { gi3 = (gn < (unsigned long)hl) ? 1 : 2; }
void cz_tn_e(int c) { gi3 = ((long)gi != hla[c]) ? 1 : 2; }
void cz_tn_f(int c) { gi3 = (gc < *hcp) ? 1 : 2; }
void cz_an_a(int c) { if (gi < hia[c] && gi2) gi3 = 1; }
void cz_an_b(int c) { if (gps->ai[4] == hip[1] && gi2) gi3 = 1; }
void cz_an_w(unsigned int r, unsigned char c) { if (r < hua[c] && gi2) gi3 = 1; }
void cz_an_d(int c) { if (gn < (unsigned long)hl && gi2) gi3 = 1; }
void cz_an_e(int c) { if ((long)gi != hla[c] && gi2) gi3 = 1; }
void cz_an_f(int c) { if (gc < *hcp && gi2) gi3 = 1; }
void cz_or_a(int c) { if (gi2 || gi < hia[c]) gi3 = 1; }
void cz_or_b(int c) { if (gi2 || gps->ai[4] == hip[1]) gi3 = 1; }
void cz_or_w(unsigned int r, unsigned char c) { if (gi2 || r < hua[c]) gi3 = 1; }
void cz_or_d(int c) { if (gi2 || gn < (unsigned long)hl) gi3 = 1; }
void cz_or_e(int c) { if (gi2 || (long)gi != hla[c]) gi3 = 1; }
void cz_or_f(int c) { if (gi2 || gc < *hcp) gi3 = 1; }

