/* Where V4.23 keeps a local with an initialiser (gen_loc0.py): the random corpora refuse such declarations most
   often (int *t = gpi; unsigned long t = gula[5]; unsigned char t = guc + 212), and the listings show XHL, XDE,
   C, IZ or a frame slot.  lo_<type>_<init><mid><use>(): the type is c uc i u l ul p pi; the initialiser G a
   plain global, E a constant-index element, B computed, R a call; between the declaration and the use nothing
   (0), a global copy (g), a call (c) or a pointer store (s); the use an argument (a), a store (s), an arithmetic
   operand (e) or a store and then an argument (d).  The local reads the g* globals, the rest the h* globals. */
extern char gc, hc, hc2; extern unsigned char guc, huc, huc2; extern int gi, hi, hj, hi2; extern unsigned int gu, hu, hu2;
extern long gl, hl, hl2; extern unsigned long gul, hul, hul2; extern char *gp, *hp, *hp2; extern int *gpi, *hpi, *hpi2;
extern char gca[8]; extern unsigned char guca[8]; extern int gia[8]; extern unsigned int gua[8]; extern long gla[8];
extern unsigned long gula[8]; extern char *gpa[4]; extern int *gpia[4];
extern char rc(void); extern unsigned char ruc(void); extern int ri(void); extern unsigned int ru(void);
extern long rl(void); extern unsigned long rul(void); extern char *rp(void); extern int *rpi(void);
extern void v0(void); extern void vc(char); extern void vuc(unsigned char); extern void vi(int); extern void vu(unsigned int);
extern void vl(long); extern void vul(unsigned long); extern void vp(char *); extern void vpi(int *);

void lo_c_G0a(void) { char t = gc; vc(t); }
void lo_c_G0s(void) { char t = gc; hc2 = t; }
void lo_c_G0e(void) { char t = gc; hc2 = (char)(t + hc); }
void lo_c_G0d(void) { char t = gc; hc2 = t; vc(t); }
void lo_c_Gga(void) { char t = gc; hi = hj; vc(t); }
void lo_c_Ggs(void) { char t = gc; hi = hj; hc2 = t; }
void lo_c_Gge(void) { char t = gc; hi = hj; hc2 = (char)(t + hc); }
void lo_c_Ggd(void) { char t = gc; hi = hj; hc2 = t; vc(t); }
void lo_c_Gca(void) { char t = gc; v0(); vc(t); }
void lo_c_Gcs(void) { char t = gc; v0(); hc2 = t; }
void lo_c_Gce(void) { char t = gc; v0(); hc2 = (char)(t + hc); }
void lo_c_Gcd(void) { char t = gc; v0(); hc2 = t; vc(t); }
void lo_c_Gsa(void) { char t = gc; *hp = 7; vc(t); }
void lo_c_Gss(void) { char t = gc; *hp = 7; hc2 = t; }
void lo_c_Gse(void) { char t = gc; *hp = 7; hc2 = (char)(t + hc); }
void lo_c_Gsd(void) { char t = gc; *hp = 7; hc2 = t; vc(t); }
void lo_c_E0a(void) { char t = gca[2]; vc(t); }
void lo_c_E0s(void) { char t = gca[2]; hc2 = t; }
void lo_c_E0e(void) { char t = gca[2]; hc2 = (char)(t + hc); }
void lo_c_E0d(void) { char t = gca[2]; hc2 = t; vc(t); }
void lo_c_Ega(void) { char t = gca[2]; hi = hj; vc(t); }
void lo_c_Egs(void) { char t = gca[2]; hi = hj; hc2 = t; }
void lo_c_Ege(void) { char t = gca[2]; hi = hj; hc2 = (char)(t + hc); }
void lo_c_Egd(void) { char t = gca[2]; hi = hj; hc2 = t; vc(t); }
void lo_c_Eca(void) { char t = gca[2]; v0(); vc(t); }
void lo_c_Ecs(void) { char t = gca[2]; v0(); hc2 = t; }
void lo_c_Ece(void) { char t = gca[2]; v0(); hc2 = (char)(t + hc); }
void lo_c_Ecd(void) { char t = gca[2]; v0(); hc2 = t; vc(t); }
void lo_c_Esa(void) { char t = gca[2]; *hp = 7; vc(t); }
void lo_c_Ess(void) { char t = gca[2]; *hp = 7; hc2 = t; }
void lo_c_Ese(void) { char t = gca[2]; *hp = 7; hc2 = (char)(t + hc); }
void lo_c_Esd(void) { char t = gca[2]; *hp = 7; hc2 = t; vc(t); }
void lo_c_B0a(void) { char t = (char)(gc + hc); vc(t); }
void lo_c_B0s(void) { char t = (char)(gc + hc); hc2 = t; }
void lo_c_B0e(void) { char t = (char)(gc + hc); hc2 = (char)(t + hc); }
void lo_c_B0d(void) { char t = (char)(gc + hc); hc2 = t; vc(t); }
void lo_c_Bga(void) { char t = (char)(gc + hc); hi = hj; vc(t); }
void lo_c_Bgs(void) { char t = (char)(gc + hc); hi = hj; hc2 = t; }
void lo_c_Bge(void) { char t = (char)(gc + hc); hi = hj; hc2 = (char)(t + hc); }
void lo_c_Bgd(void) { char t = (char)(gc + hc); hi = hj; hc2 = t; vc(t); }
void lo_c_Bca(void) { char t = (char)(gc + hc); v0(); vc(t); }
void lo_c_Bcs(void) { char t = (char)(gc + hc); v0(); hc2 = t; }
void lo_c_Bce(void) { char t = (char)(gc + hc); v0(); hc2 = (char)(t + hc); }
void lo_c_Bcd(void) { char t = (char)(gc + hc); v0(); hc2 = t; vc(t); }
void lo_c_Bsa(void) { char t = (char)(gc + hc); *hp = 7; vc(t); }
void lo_c_Bss(void) { char t = (char)(gc + hc); *hp = 7; hc2 = t; }
void lo_c_Bse(void) { char t = (char)(gc + hc); *hp = 7; hc2 = (char)(t + hc); }
void lo_c_Bsd(void) { char t = (char)(gc + hc); *hp = 7; hc2 = t; vc(t); }
void lo_c_R0a(void) { char t = rc(); vc(t); }
void lo_c_R0s(void) { char t = rc(); hc2 = t; }
void lo_c_R0e(void) { char t = rc(); hc2 = (char)(t + hc); }
void lo_c_R0d(void) { char t = rc(); hc2 = t; vc(t); }
void lo_c_Rga(void) { char t = rc(); hi = hj; vc(t); }
void lo_c_Rgs(void) { char t = rc(); hi = hj; hc2 = t; }
void lo_c_Rge(void) { char t = rc(); hi = hj; hc2 = (char)(t + hc); }
void lo_c_Rgd(void) { char t = rc(); hi = hj; hc2 = t; vc(t); }
void lo_c_Rca(void) { char t = rc(); v0(); vc(t); }
void lo_c_Rcs(void) { char t = rc(); v0(); hc2 = t; }
void lo_c_Rce(void) { char t = rc(); v0(); hc2 = (char)(t + hc); }
void lo_c_Rcd(void) { char t = rc(); v0(); hc2 = t; vc(t); }
void lo_c_Rsa(void) { char t = rc(); *hp = 7; vc(t); }
void lo_c_Rss(void) { char t = rc(); *hp = 7; hc2 = t; }
void lo_c_Rse(void) { char t = rc(); *hp = 7; hc2 = (char)(t + hc); }
void lo_c_Rsd(void) { char t = rc(); *hp = 7; hc2 = t; vc(t); }

void lo_uc_G0a(void) { unsigned char t = guc; vuc(t); }
void lo_uc_G0s(void) { unsigned char t = guc; huc2 = t; }
void lo_uc_G0e(void) { unsigned char t = guc; huc2 = (unsigned char)(t + huc); }
void lo_uc_G0d(void) { unsigned char t = guc; huc2 = t; vuc(t); }
void lo_uc_Gga(void) { unsigned char t = guc; hi = hj; vuc(t); }
void lo_uc_Ggs(void) { unsigned char t = guc; hi = hj; huc2 = t; }
void lo_uc_Gge(void) { unsigned char t = guc; hi = hj; huc2 = (unsigned char)(t + huc); }
void lo_uc_Ggd(void) { unsigned char t = guc; hi = hj; huc2 = t; vuc(t); }
void lo_uc_Gca(void) { unsigned char t = guc; v0(); vuc(t); }
void lo_uc_Gcs(void) { unsigned char t = guc; v0(); huc2 = t; }
void lo_uc_Gce(void) { unsigned char t = guc; v0(); huc2 = (unsigned char)(t + huc); }
void lo_uc_Gcd(void) { unsigned char t = guc; v0(); huc2 = t; vuc(t); }
void lo_uc_Gsa(void) { unsigned char t = guc; *hp = 7; vuc(t); }
void lo_uc_Gss(void) { unsigned char t = guc; *hp = 7; huc2 = t; }
void lo_uc_Gse(void) { unsigned char t = guc; *hp = 7; huc2 = (unsigned char)(t + huc); }
void lo_uc_Gsd(void) { unsigned char t = guc; *hp = 7; huc2 = t; vuc(t); }
void lo_uc_E0a(void) { unsigned char t = guca[2]; vuc(t); }
void lo_uc_E0s(void) { unsigned char t = guca[2]; huc2 = t; }
void lo_uc_E0e(void) { unsigned char t = guca[2]; huc2 = (unsigned char)(t + huc); }
void lo_uc_E0d(void) { unsigned char t = guca[2]; huc2 = t; vuc(t); }
void lo_uc_Ega(void) { unsigned char t = guca[2]; hi = hj; vuc(t); }
void lo_uc_Egs(void) { unsigned char t = guca[2]; hi = hj; huc2 = t; }
void lo_uc_Ege(void) { unsigned char t = guca[2]; hi = hj; huc2 = (unsigned char)(t + huc); }
void lo_uc_Egd(void) { unsigned char t = guca[2]; hi = hj; huc2 = t; vuc(t); }
void lo_uc_Eca(void) { unsigned char t = guca[2]; v0(); vuc(t); }
void lo_uc_Ecs(void) { unsigned char t = guca[2]; v0(); huc2 = t; }
void lo_uc_Ece(void) { unsigned char t = guca[2]; v0(); huc2 = (unsigned char)(t + huc); }
void lo_uc_Ecd(void) { unsigned char t = guca[2]; v0(); huc2 = t; vuc(t); }
void lo_uc_Esa(void) { unsigned char t = guca[2]; *hp = 7; vuc(t); }
void lo_uc_Ess(void) { unsigned char t = guca[2]; *hp = 7; huc2 = t; }
void lo_uc_Ese(void) { unsigned char t = guca[2]; *hp = 7; huc2 = (unsigned char)(t + huc); }
void lo_uc_Esd(void) { unsigned char t = guca[2]; *hp = 7; huc2 = t; vuc(t); }
void lo_uc_B0a(void) { unsigned char t = (unsigned char)(guc + 212); vuc(t); }
void lo_uc_B0s(void) { unsigned char t = (unsigned char)(guc + 212); huc2 = t; }
void lo_uc_B0e(void) { unsigned char t = (unsigned char)(guc + 212); huc2 = (unsigned char)(t + huc); }
void lo_uc_B0d(void) { unsigned char t = (unsigned char)(guc + 212); huc2 = t; vuc(t); }
void lo_uc_Bga(void) { unsigned char t = (unsigned char)(guc + 212); hi = hj; vuc(t); }
void lo_uc_Bgs(void) { unsigned char t = (unsigned char)(guc + 212); hi = hj; huc2 = t; }
void lo_uc_Bge(void) { unsigned char t = (unsigned char)(guc + 212); hi = hj; huc2 = (unsigned char)(t + huc); }
void lo_uc_Bgd(void) { unsigned char t = (unsigned char)(guc + 212); hi = hj; huc2 = t; vuc(t); }
void lo_uc_Bca(void) { unsigned char t = (unsigned char)(guc + 212); v0(); vuc(t); }
void lo_uc_Bcs(void) { unsigned char t = (unsigned char)(guc + 212); v0(); huc2 = t; }
void lo_uc_Bce(void) { unsigned char t = (unsigned char)(guc + 212); v0(); huc2 = (unsigned char)(t + huc); }
void lo_uc_Bcd(void) { unsigned char t = (unsigned char)(guc + 212); v0(); huc2 = t; vuc(t); }
void lo_uc_Bsa(void) { unsigned char t = (unsigned char)(guc + 212); *hp = 7; vuc(t); }
void lo_uc_Bss(void) { unsigned char t = (unsigned char)(guc + 212); *hp = 7; huc2 = t; }
void lo_uc_Bse(void) { unsigned char t = (unsigned char)(guc + 212); *hp = 7; huc2 = (unsigned char)(t + huc); }
void lo_uc_Bsd(void) { unsigned char t = (unsigned char)(guc + 212); *hp = 7; huc2 = t; vuc(t); }
void lo_uc_R0a(void) { unsigned char t = ruc(); vuc(t); }
void lo_uc_R0s(void) { unsigned char t = ruc(); huc2 = t; }
void lo_uc_R0e(void) { unsigned char t = ruc(); huc2 = (unsigned char)(t + huc); }
void lo_uc_R0d(void) { unsigned char t = ruc(); huc2 = t; vuc(t); }
void lo_uc_Rga(void) { unsigned char t = ruc(); hi = hj; vuc(t); }
void lo_uc_Rgs(void) { unsigned char t = ruc(); hi = hj; huc2 = t; }
void lo_uc_Rge(void) { unsigned char t = ruc(); hi = hj; huc2 = (unsigned char)(t + huc); }
void lo_uc_Rgd(void) { unsigned char t = ruc(); hi = hj; huc2 = t; vuc(t); }
void lo_uc_Rca(void) { unsigned char t = ruc(); v0(); vuc(t); }
void lo_uc_Rcs(void) { unsigned char t = ruc(); v0(); huc2 = t; }
void lo_uc_Rce(void) { unsigned char t = ruc(); v0(); huc2 = (unsigned char)(t + huc); }
void lo_uc_Rcd(void) { unsigned char t = ruc(); v0(); huc2 = t; vuc(t); }
void lo_uc_Rsa(void) { unsigned char t = ruc(); *hp = 7; vuc(t); }
void lo_uc_Rss(void) { unsigned char t = ruc(); *hp = 7; huc2 = t; }
void lo_uc_Rse(void) { unsigned char t = ruc(); *hp = 7; huc2 = (unsigned char)(t + huc); }
void lo_uc_Rsd(void) { unsigned char t = ruc(); *hp = 7; huc2 = t; vuc(t); }

void lo_i_G0a(void) { int t = gi; vi(t); }
void lo_i_G0s(void) { int t = gi; hi2 = t; }
void lo_i_G0e(void) { int t = gi; hi2 = t + hi; }
void lo_i_G0d(void) { int t = gi; hi2 = t; vi(t); }
void lo_i_Gga(void) { int t = gi; hi = hj; vi(t); }
void lo_i_Ggs(void) { int t = gi; hi = hj; hi2 = t; }
void lo_i_Gge(void) { int t = gi; hi = hj; hi2 = t + hi; }
void lo_i_Ggd(void) { int t = gi; hi = hj; hi2 = t; vi(t); }
void lo_i_Gca(void) { int t = gi; v0(); vi(t); }
void lo_i_Gcs(void) { int t = gi; v0(); hi2 = t; }
void lo_i_Gce(void) { int t = gi; v0(); hi2 = t + hi; }
void lo_i_Gcd(void) { int t = gi; v0(); hi2 = t; vi(t); }
void lo_i_Gsa(void) { int t = gi; *hp = 7; vi(t); }
void lo_i_Gss(void) { int t = gi; *hp = 7; hi2 = t; }
void lo_i_Gse(void) { int t = gi; *hp = 7; hi2 = t + hi; }
void lo_i_Gsd(void) { int t = gi; *hp = 7; hi2 = t; vi(t); }
void lo_i_E0a(void) { int t = gia[2]; vi(t); }
void lo_i_E0s(void) { int t = gia[2]; hi2 = t; }
void lo_i_E0e(void) { int t = gia[2]; hi2 = t + hi; }
void lo_i_E0d(void) { int t = gia[2]; hi2 = t; vi(t); }
void lo_i_Ega(void) { int t = gia[2]; hi = hj; vi(t); }
void lo_i_Egs(void) { int t = gia[2]; hi = hj; hi2 = t; }
void lo_i_Ege(void) { int t = gia[2]; hi = hj; hi2 = t + hi; }
void lo_i_Egd(void) { int t = gia[2]; hi = hj; hi2 = t; vi(t); }
void lo_i_Eca(void) { int t = gia[2]; v0(); vi(t); }
void lo_i_Ecs(void) { int t = gia[2]; v0(); hi2 = t; }
void lo_i_Ece(void) { int t = gia[2]; v0(); hi2 = t + hi; }
void lo_i_Ecd(void) { int t = gia[2]; v0(); hi2 = t; vi(t); }
void lo_i_Esa(void) { int t = gia[2]; *hp = 7; vi(t); }
void lo_i_Ess(void) { int t = gia[2]; *hp = 7; hi2 = t; }
void lo_i_Ese(void) { int t = gia[2]; *hp = 7; hi2 = t + hi; }
void lo_i_Esd(void) { int t = gia[2]; *hp = 7; hi2 = t; vi(t); }
void lo_i_B0a(void) { int t = gi + hi; vi(t); }
void lo_i_B0s(void) { int t = gi + hi; hi2 = t; }
void lo_i_B0e(void) { int t = gi + hi; hi2 = t + hi; }
void lo_i_B0d(void) { int t = gi + hi; hi2 = t; vi(t); }
void lo_i_Bga(void) { int t = gi + hi; hi = hj; vi(t); }
void lo_i_Bgs(void) { int t = gi + hi; hi = hj; hi2 = t; }
void lo_i_Bge(void) { int t = gi + hi; hi = hj; hi2 = t + hi; }
void lo_i_Bgd(void) { int t = gi + hi; hi = hj; hi2 = t; vi(t); }
void lo_i_Bca(void) { int t = gi + hi; v0(); vi(t); }
void lo_i_Bcs(void) { int t = gi + hi; v0(); hi2 = t; }
void lo_i_Bce(void) { int t = gi + hi; v0(); hi2 = t + hi; }
void lo_i_Bcd(void) { int t = gi + hi; v0(); hi2 = t; vi(t); }
void lo_i_Bsa(void) { int t = gi + hi; *hp = 7; vi(t); }
void lo_i_Bss(void) { int t = gi + hi; *hp = 7; hi2 = t; }
void lo_i_Bse(void) { int t = gi + hi; *hp = 7; hi2 = t + hi; }
void lo_i_Bsd(void) { int t = gi + hi; *hp = 7; hi2 = t; vi(t); }
void lo_i_R0a(void) { int t = ri(); vi(t); }
void lo_i_R0s(void) { int t = ri(); hi2 = t; }
void lo_i_R0e(void) { int t = ri(); hi2 = t + hi; }
void lo_i_R0d(void) { int t = ri(); hi2 = t; vi(t); }
void lo_i_Rga(void) { int t = ri(); hi = hj; vi(t); }
void lo_i_Rgs(void) { int t = ri(); hi = hj; hi2 = t; }
void lo_i_Rge(void) { int t = ri(); hi = hj; hi2 = t + hi; }
void lo_i_Rgd(void) { int t = ri(); hi = hj; hi2 = t; vi(t); }
void lo_i_Rca(void) { int t = ri(); v0(); vi(t); }
void lo_i_Rcs(void) { int t = ri(); v0(); hi2 = t; }
void lo_i_Rce(void) { int t = ri(); v0(); hi2 = t + hi; }
void lo_i_Rcd(void) { int t = ri(); v0(); hi2 = t; vi(t); }
void lo_i_Rsa(void) { int t = ri(); *hp = 7; vi(t); }
void lo_i_Rss(void) { int t = ri(); *hp = 7; hi2 = t; }
void lo_i_Rse(void) { int t = ri(); *hp = 7; hi2 = t + hi; }
void lo_i_Rsd(void) { int t = ri(); *hp = 7; hi2 = t; vi(t); }

void lo_u_G0a(void) { unsigned int t = gu; vu(t); }
void lo_u_G0s(void) { unsigned int t = gu; hu2 = t; }
void lo_u_G0e(void) { unsigned int t = gu; hu2 = t + hu; }
void lo_u_G0d(void) { unsigned int t = gu; hu2 = t; vu(t); }
void lo_u_Gga(void) { unsigned int t = gu; hi = hj; vu(t); }
void lo_u_Ggs(void) { unsigned int t = gu; hi = hj; hu2 = t; }
void lo_u_Gge(void) { unsigned int t = gu; hi = hj; hu2 = t + hu; }
void lo_u_Ggd(void) { unsigned int t = gu; hi = hj; hu2 = t; vu(t); }
void lo_u_Gca(void) { unsigned int t = gu; v0(); vu(t); }
void lo_u_Gcs(void) { unsigned int t = gu; v0(); hu2 = t; }
void lo_u_Gce(void) { unsigned int t = gu; v0(); hu2 = t + hu; }
void lo_u_Gcd(void) { unsigned int t = gu; v0(); hu2 = t; vu(t); }
void lo_u_Gsa(void) { unsigned int t = gu; *hp = 7; vu(t); }
void lo_u_Gss(void) { unsigned int t = gu; *hp = 7; hu2 = t; }
void lo_u_Gse(void) { unsigned int t = gu; *hp = 7; hu2 = t + hu; }
void lo_u_Gsd(void) { unsigned int t = gu; *hp = 7; hu2 = t; vu(t); }
void lo_u_E0a(void) { unsigned int t = gua[2]; vu(t); }
void lo_u_E0s(void) { unsigned int t = gua[2]; hu2 = t; }
void lo_u_E0e(void) { unsigned int t = gua[2]; hu2 = t + hu; }
void lo_u_E0d(void) { unsigned int t = gua[2]; hu2 = t; vu(t); }
void lo_u_Ega(void) { unsigned int t = gua[2]; hi = hj; vu(t); }
void lo_u_Egs(void) { unsigned int t = gua[2]; hi = hj; hu2 = t; }
void lo_u_Ege(void) { unsigned int t = gua[2]; hi = hj; hu2 = t + hu; }
void lo_u_Egd(void) { unsigned int t = gua[2]; hi = hj; hu2 = t; vu(t); }
void lo_u_Eca(void) { unsigned int t = gua[2]; v0(); vu(t); }
void lo_u_Ecs(void) { unsigned int t = gua[2]; v0(); hu2 = t; }
void lo_u_Ece(void) { unsigned int t = gua[2]; v0(); hu2 = t + hu; }
void lo_u_Ecd(void) { unsigned int t = gua[2]; v0(); hu2 = t; vu(t); }
void lo_u_Esa(void) { unsigned int t = gua[2]; *hp = 7; vu(t); }
void lo_u_Ess(void) { unsigned int t = gua[2]; *hp = 7; hu2 = t; }
void lo_u_Ese(void) { unsigned int t = gua[2]; *hp = 7; hu2 = t + hu; }
void lo_u_Esd(void) { unsigned int t = gua[2]; *hp = 7; hu2 = t; vu(t); }
void lo_u_B0a(void) { unsigned int t = gu - 1; vu(t); }
void lo_u_B0s(void) { unsigned int t = gu - 1; hu2 = t; }
void lo_u_B0e(void) { unsigned int t = gu - 1; hu2 = t + hu; }
void lo_u_B0d(void) { unsigned int t = gu - 1; hu2 = t; vu(t); }
void lo_u_Bga(void) { unsigned int t = gu - 1; hi = hj; vu(t); }
void lo_u_Bgs(void) { unsigned int t = gu - 1; hi = hj; hu2 = t; }
void lo_u_Bge(void) { unsigned int t = gu - 1; hi = hj; hu2 = t + hu; }
void lo_u_Bgd(void) { unsigned int t = gu - 1; hi = hj; hu2 = t; vu(t); }
void lo_u_Bca(void) { unsigned int t = gu - 1; v0(); vu(t); }
void lo_u_Bcs(void) { unsigned int t = gu - 1; v0(); hu2 = t; }
void lo_u_Bce(void) { unsigned int t = gu - 1; v0(); hu2 = t + hu; }
void lo_u_Bcd(void) { unsigned int t = gu - 1; v0(); hu2 = t; vu(t); }
void lo_u_Bsa(void) { unsigned int t = gu - 1; *hp = 7; vu(t); }
void lo_u_Bss(void) { unsigned int t = gu - 1; *hp = 7; hu2 = t; }
void lo_u_Bse(void) { unsigned int t = gu - 1; *hp = 7; hu2 = t + hu; }
void lo_u_Bsd(void) { unsigned int t = gu - 1; *hp = 7; hu2 = t; vu(t); }
void lo_u_R0a(void) { unsigned int t = ru(); vu(t); }
void lo_u_R0s(void) { unsigned int t = ru(); hu2 = t; }
void lo_u_R0e(void) { unsigned int t = ru(); hu2 = t + hu; }
void lo_u_R0d(void) { unsigned int t = ru(); hu2 = t; vu(t); }
void lo_u_Rga(void) { unsigned int t = ru(); hi = hj; vu(t); }
void lo_u_Rgs(void) { unsigned int t = ru(); hi = hj; hu2 = t; }
void lo_u_Rge(void) { unsigned int t = ru(); hi = hj; hu2 = t + hu; }
void lo_u_Rgd(void) { unsigned int t = ru(); hi = hj; hu2 = t; vu(t); }
void lo_u_Rca(void) { unsigned int t = ru(); v0(); vu(t); }
void lo_u_Rcs(void) { unsigned int t = ru(); v0(); hu2 = t; }
void lo_u_Rce(void) { unsigned int t = ru(); v0(); hu2 = t + hu; }
void lo_u_Rcd(void) { unsigned int t = ru(); v0(); hu2 = t; vu(t); }
void lo_u_Rsa(void) { unsigned int t = ru(); *hp = 7; vu(t); }
void lo_u_Rss(void) { unsigned int t = ru(); *hp = 7; hu2 = t; }
void lo_u_Rse(void) { unsigned int t = ru(); *hp = 7; hu2 = t + hu; }
void lo_u_Rsd(void) { unsigned int t = ru(); *hp = 7; hu2 = t; vu(t); }

void lo_l_G0a(void) { long t = gl; vl(t); }
void lo_l_G0s(void) { long t = gl; hl2 = t; }
void lo_l_G0e(void) { long t = gl; hl2 = t + hl; }
void lo_l_G0d(void) { long t = gl; hl2 = t; vl(t); }
void lo_l_Gga(void) { long t = gl; hi = hj; vl(t); }
void lo_l_Ggs(void) { long t = gl; hi = hj; hl2 = t; }
void lo_l_Gge(void) { long t = gl; hi = hj; hl2 = t + hl; }
void lo_l_Ggd(void) { long t = gl; hi = hj; hl2 = t; vl(t); }
void lo_l_Gca(void) { long t = gl; v0(); vl(t); }
void lo_l_Gcs(void) { long t = gl; v0(); hl2 = t; }
void lo_l_Gce(void) { long t = gl; v0(); hl2 = t + hl; }
void lo_l_Gcd(void) { long t = gl; v0(); hl2 = t; vl(t); }
void lo_l_Gsa(void) { long t = gl; *hp = 7; vl(t); }
void lo_l_Gss(void) { long t = gl; *hp = 7; hl2 = t; }
void lo_l_Gse(void) { long t = gl; *hp = 7; hl2 = t + hl; }
void lo_l_Gsd(void) { long t = gl; *hp = 7; hl2 = t; vl(t); }
void lo_l_E0a(void) { long t = gla[2]; vl(t); }
void lo_l_E0s(void) { long t = gla[2]; hl2 = t; }
void lo_l_E0e(void) { long t = gla[2]; hl2 = t + hl; }
void lo_l_E0d(void) { long t = gla[2]; hl2 = t; vl(t); }
void lo_l_Ega(void) { long t = gla[2]; hi = hj; vl(t); }
void lo_l_Egs(void) { long t = gla[2]; hi = hj; hl2 = t; }
void lo_l_Ege(void) { long t = gla[2]; hi = hj; hl2 = t + hl; }
void lo_l_Egd(void) { long t = gla[2]; hi = hj; hl2 = t; vl(t); }
void lo_l_Eca(void) { long t = gla[2]; v0(); vl(t); }
void lo_l_Ecs(void) { long t = gla[2]; v0(); hl2 = t; }
void lo_l_Ece(void) { long t = gla[2]; v0(); hl2 = t + hl; }
void lo_l_Ecd(void) { long t = gla[2]; v0(); hl2 = t; vl(t); }
void lo_l_Esa(void) { long t = gla[2]; *hp = 7; vl(t); }
void lo_l_Ess(void) { long t = gla[2]; *hp = 7; hl2 = t; }
void lo_l_Ese(void) { long t = gla[2]; *hp = 7; hl2 = t + hl; }
void lo_l_Esd(void) { long t = gla[2]; *hp = 7; hl2 = t; vl(t); }
void lo_l_B0a(void) { long t = gl + hl; vl(t); }
void lo_l_B0s(void) { long t = gl + hl; hl2 = t; }
void lo_l_B0e(void) { long t = gl + hl; hl2 = t + hl; }
void lo_l_B0d(void) { long t = gl + hl; hl2 = t; vl(t); }
void lo_l_Bga(void) { long t = gl + hl; hi = hj; vl(t); }
void lo_l_Bgs(void) { long t = gl + hl; hi = hj; hl2 = t; }
void lo_l_Bge(void) { long t = gl + hl; hi = hj; hl2 = t + hl; }
void lo_l_Bgd(void) { long t = gl + hl; hi = hj; hl2 = t; vl(t); }
void lo_l_Bca(void) { long t = gl + hl; v0(); vl(t); }
void lo_l_Bcs(void) { long t = gl + hl; v0(); hl2 = t; }
void lo_l_Bce(void) { long t = gl + hl; v0(); hl2 = t + hl; }
void lo_l_Bcd(void) { long t = gl + hl; v0(); hl2 = t; vl(t); }
void lo_l_Bsa(void) { long t = gl + hl; *hp = 7; vl(t); }
void lo_l_Bss(void) { long t = gl + hl; *hp = 7; hl2 = t; }
void lo_l_Bse(void) { long t = gl + hl; *hp = 7; hl2 = t + hl; }
void lo_l_Bsd(void) { long t = gl + hl; *hp = 7; hl2 = t; vl(t); }
void lo_l_R0a(void) { long t = rl(); vl(t); }
void lo_l_R0s(void) { long t = rl(); hl2 = t; }
void lo_l_R0e(void) { long t = rl(); hl2 = t + hl; }
void lo_l_R0d(void) { long t = rl(); hl2 = t; vl(t); }
void lo_l_Rga(void) { long t = rl(); hi = hj; vl(t); }
void lo_l_Rgs(void) { long t = rl(); hi = hj; hl2 = t; }
void lo_l_Rge(void) { long t = rl(); hi = hj; hl2 = t + hl; }
void lo_l_Rgd(void) { long t = rl(); hi = hj; hl2 = t; vl(t); }
void lo_l_Rca(void) { long t = rl(); v0(); vl(t); }
void lo_l_Rcs(void) { long t = rl(); v0(); hl2 = t; }
void lo_l_Rce(void) { long t = rl(); v0(); hl2 = t + hl; }
void lo_l_Rcd(void) { long t = rl(); v0(); hl2 = t; vl(t); }
void lo_l_Rsa(void) { long t = rl(); *hp = 7; vl(t); }
void lo_l_Rss(void) { long t = rl(); *hp = 7; hl2 = t; }
void lo_l_Rse(void) { long t = rl(); *hp = 7; hl2 = t + hl; }
void lo_l_Rsd(void) { long t = rl(); *hp = 7; hl2 = t; vl(t); }

void lo_ul_G0a(void) { unsigned long t = gul; vul(t); }
void lo_ul_G0s(void) { unsigned long t = gul; hul2 = t; }
void lo_ul_G0e(void) { unsigned long t = gul; hul2 = t + hul; }
void lo_ul_G0d(void) { unsigned long t = gul; hul2 = t; vul(t); }
void lo_ul_Gga(void) { unsigned long t = gul; hi = hj; vul(t); }
void lo_ul_Ggs(void) { unsigned long t = gul; hi = hj; hul2 = t; }
void lo_ul_Gge(void) { unsigned long t = gul; hi = hj; hul2 = t + hul; }
void lo_ul_Ggd(void) { unsigned long t = gul; hi = hj; hul2 = t; vul(t); }
void lo_ul_Gca(void) { unsigned long t = gul; v0(); vul(t); }
void lo_ul_Gcs(void) { unsigned long t = gul; v0(); hul2 = t; }
void lo_ul_Gce(void) { unsigned long t = gul; v0(); hul2 = t + hul; }
void lo_ul_Gcd(void) { unsigned long t = gul; v0(); hul2 = t; vul(t); }
void lo_ul_Gsa(void) { unsigned long t = gul; *hp = 7; vul(t); }
void lo_ul_Gss(void) { unsigned long t = gul; *hp = 7; hul2 = t; }
void lo_ul_Gse(void) { unsigned long t = gul; *hp = 7; hul2 = t + hul; }
void lo_ul_Gsd(void) { unsigned long t = gul; *hp = 7; hul2 = t; vul(t); }
void lo_ul_E0a(void) { unsigned long t = gula[2]; vul(t); }
void lo_ul_E0s(void) { unsigned long t = gula[2]; hul2 = t; }
void lo_ul_E0e(void) { unsigned long t = gula[2]; hul2 = t + hul; }
void lo_ul_E0d(void) { unsigned long t = gula[2]; hul2 = t; vul(t); }
void lo_ul_Ega(void) { unsigned long t = gula[2]; hi = hj; vul(t); }
void lo_ul_Egs(void) { unsigned long t = gula[2]; hi = hj; hul2 = t; }
void lo_ul_Ege(void) { unsigned long t = gula[2]; hi = hj; hul2 = t + hul; }
void lo_ul_Egd(void) { unsigned long t = gula[2]; hi = hj; hul2 = t; vul(t); }
void lo_ul_Eca(void) { unsigned long t = gula[2]; v0(); vul(t); }
void lo_ul_Ecs(void) { unsigned long t = gula[2]; v0(); hul2 = t; }
void lo_ul_Ece(void) { unsigned long t = gula[2]; v0(); hul2 = t + hul; }
void lo_ul_Ecd(void) { unsigned long t = gula[2]; v0(); hul2 = t; vul(t); }
void lo_ul_Esa(void) { unsigned long t = gula[2]; *hp = 7; vul(t); }
void lo_ul_Ess(void) { unsigned long t = gula[2]; *hp = 7; hul2 = t; }
void lo_ul_Ese(void) { unsigned long t = gula[2]; *hp = 7; hul2 = t + hul; }
void lo_ul_Esd(void) { unsigned long t = gula[2]; *hp = 7; hul2 = t; vul(t); }
void lo_ul_B0a(void) { unsigned long t = gul >> 3; vul(t); }
void lo_ul_B0s(void) { unsigned long t = gul >> 3; hul2 = t; }
void lo_ul_B0e(void) { unsigned long t = gul >> 3; hul2 = t + hul; }
void lo_ul_B0d(void) { unsigned long t = gul >> 3; hul2 = t; vul(t); }
void lo_ul_Bga(void) { unsigned long t = gul >> 3; hi = hj; vul(t); }
void lo_ul_Bgs(void) { unsigned long t = gul >> 3; hi = hj; hul2 = t; }
void lo_ul_Bge(void) { unsigned long t = gul >> 3; hi = hj; hul2 = t + hul; }
void lo_ul_Bgd(void) { unsigned long t = gul >> 3; hi = hj; hul2 = t; vul(t); }
void lo_ul_Bca(void) { unsigned long t = gul >> 3; v0(); vul(t); }
void lo_ul_Bcs(void) { unsigned long t = gul >> 3; v0(); hul2 = t; }
void lo_ul_Bce(void) { unsigned long t = gul >> 3; v0(); hul2 = t + hul; }
void lo_ul_Bcd(void) { unsigned long t = gul >> 3; v0(); hul2 = t; vul(t); }
void lo_ul_Bsa(void) { unsigned long t = gul >> 3; *hp = 7; vul(t); }
void lo_ul_Bss(void) { unsigned long t = gul >> 3; *hp = 7; hul2 = t; }
void lo_ul_Bse(void) { unsigned long t = gul >> 3; *hp = 7; hul2 = t + hul; }
void lo_ul_Bsd(void) { unsigned long t = gul >> 3; *hp = 7; hul2 = t; vul(t); }
void lo_ul_R0a(void) { unsigned long t = rul(); vul(t); }
void lo_ul_R0s(void) { unsigned long t = rul(); hul2 = t; }
void lo_ul_R0e(void) { unsigned long t = rul(); hul2 = t + hul; }
void lo_ul_R0d(void) { unsigned long t = rul(); hul2 = t; vul(t); }
void lo_ul_Rga(void) { unsigned long t = rul(); hi = hj; vul(t); }
void lo_ul_Rgs(void) { unsigned long t = rul(); hi = hj; hul2 = t; }
void lo_ul_Rge(void) { unsigned long t = rul(); hi = hj; hul2 = t + hul; }
void lo_ul_Rgd(void) { unsigned long t = rul(); hi = hj; hul2 = t; vul(t); }
void lo_ul_Rca(void) { unsigned long t = rul(); v0(); vul(t); }
void lo_ul_Rcs(void) { unsigned long t = rul(); v0(); hul2 = t; }
void lo_ul_Rce(void) { unsigned long t = rul(); v0(); hul2 = t + hul; }
void lo_ul_Rcd(void) { unsigned long t = rul(); v0(); hul2 = t; vul(t); }
void lo_ul_Rsa(void) { unsigned long t = rul(); *hp = 7; vul(t); }
void lo_ul_Rss(void) { unsigned long t = rul(); *hp = 7; hul2 = t; }
void lo_ul_Rse(void) { unsigned long t = rul(); *hp = 7; hul2 = t + hul; }
void lo_ul_Rsd(void) { unsigned long t = rul(); *hp = 7; hul2 = t; vul(t); }

void lo_p_G0a(void) { char * t = gp; vp(t); }
void lo_p_G0s(void) { char * t = gp; hp2 = t; }
void lo_p_G0e(void) { char * t = gp; hp2 = t + 1; }
void lo_p_G0d(void) { char * t = gp; hp2 = t; vp(t); }
void lo_p_Gga(void) { char * t = gp; hi = hj; vp(t); }
void lo_p_Ggs(void) { char * t = gp; hi = hj; hp2 = t; }
void lo_p_Gge(void) { char * t = gp; hi = hj; hp2 = t + 1; }
void lo_p_Ggd(void) { char * t = gp; hi = hj; hp2 = t; vp(t); }
void lo_p_Gca(void) { char * t = gp; v0(); vp(t); }
void lo_p_Gcs(void) { char * t = gp; v0(); hp2 = t; }
void lo_p_Gce(void) { char * t = gp; v0(); hp2 = t + 1; }
void lo_p_Gcd(void) { char * t = gp; v0(); hp2 = t; vp(t); }
void lo_p_Gsa(void) { char * t = gp; *hp = 7; vp(t); }
void lo_p_Gss(void) { char * t = gp; *hp = 7; hp2 = t; }
void lo_p_Gse(void) { char * t = gp; *hp = 7; hp2 = t + 1; }
void lo_p_Gsd(void) { char * t = gp; *hp = 7; hp2 = t; vp(t); }
void lo_p_E0a(void) { char * t = gpa[2]; vp(t); }
void lo_p_E0s(void) { char * t = gpa[2]; hp2 = t; }
void lo_p_E0e(void) { char * t = gpa[2]; hp2 = t + 1; }
void lo_p_E0d(void) { char * t = gpa[2]; hp2 = t; vp(t); }
void lo_p_Ega(void) { char * t = gpa[2]; hi = hj; vp(t); }
void lo_p_Egs(void) { char * t = gpa[2]; hi = hj; hp2 = t; }
void lo_p_Ege(void) { char * t = gpa[2]; hi = hj; hp2 = t + 1; }
void lo_p_Egd(void) { char * t = gpa[2]; hi = hj; hp2 = t; vp(t); }
void lo_p_Eca(void) { char * t = gpa[2]; v0(); vp(t); }
void lo_p_Ecs(void) { char * t = gpa[2]; v0(); hp2 = t; }
void lo_p_Ece(void) { char * t = gpa[2]; v0(); hp2 = t + 1; }
void lo_p_Ecd(void) { char * t = gpa[2]; v0(); hp2 = t; vp(t); }
void lo_p_Esa(void) { char * t = gpa[2]; *hp = 7; vp(t); }
void lo_p_Ess(void) { char * t = gpa[2]; *hp = 7; hp2 = t; }
void lo_p_Ese(void) { char * t = gpa[2]; *hp = 7; hp2 = t + 1; }
void lo_p_Esd(void) { char * t = gpa[2]; *hp = 7; hp2 = t; vp(t); }
void lo_p_B0a(void) { char * t = gp + 1; vp(t); }
void lo_p_B0s(void) { char * t = gp + 1; hp2 = t; }
void lo_p_B0e(void) { char * t = gp + 1; hp2 = t + 1; }
void lo_p_B0d(void) { char * t = gp + 1; hp2 = t; vp(t); }
void lo_p_Bga(void) { char * t = gp + 1; hi = hj; vp(t); }
void lo_p_Bgs(void) { char * t = gp + 1; hi = hj; hp2 = t; }
void lo_p_Bge(void) { char * t = gp + 1; hi = hj; hp2 = t + 1; }
void lo_p_Bgd(void) { char * t = gp + 1; hi = hj; hp2 = t; vp(t); }
void lo_p_Bca(void) { char * t = gp + 1; v0(); vp(t); }
void lo_p_Bcs(void) { char * t = gp + 1; v0(); hp2 = t; }
void lo_p_Bce(void) { char * t = gp + 1; v0(); hp2 = t + 1; }
void lo_p_Bcd(void) { char * t = gp + 1; v0(); hp2 = t; vp(t); }
void lo_p_Bsa(void) { char * t = gp + 1; *hp = 7; vp(t); }
void lo_p_Bss(void) { char * t = gp + 1; *hp = 7; hp2 = t; }
void lo_p_Bse(void) { char * t = gp + 1; *hp = 7; hp2 = t + 1; }
void lo_p_Bsd(void) { char * t = gp + 1; *hp = 7; hp2 = t; vp(t); }
void lo_p_R0a(void) { char * t = rp(); vp(t); }
void lo_p_R0s(void) { char * t = rp(); hp2 = t; }
void lo_p_R0e(void) { char * t = rp(); hp2 = t + 1; }
void lo_p_R0d(void) { char * t = rp(); hp2 = t; vp(t); }
void lo_p_Rga(void) { char * t = rp(); hi = hj; vp(t); }
void lo_p_Rgs(void) { char * t = rp(); hi = hj; hp2 = t; }
void lo_p_Rge(void) { char * t = rp(); hi = hj; hp2 = t + 1; }
void lo_p_Rgd(void) { char * t = rp(); hi = hj; hp2 = t; vp(t); }
void lo_p_Rca(void) { char * t = rp(); v0(); vp(t); }
void lo_p_Rcs(void) { char * t = rp(); v0(); hp2 = t; }
void lo_p_Rce(void) { char * t = rp(); v0(); hp2 = t + 1; }
void lo_p_Rcd(void) { char * t = rp(); v0(); hp2 = t; vp(t); }
void lo_p_Rsa(void) { char * t = rp(); *hp = 7; vp(t); }
void lo_p_Rss(void) { char * t = rp(); *hp = 7; hp2 = t; }
void lo_p_Rse(void) { char * t = rp(); *hp = 7; hp2 = t + 1; }
void lo_p_Rsd(void) { char * t = rp(); *hp = 7; hp2 = t; vp(t); }

void lo_pi_G0a(void) { int * t = gpi; vpi(t); }
void lo_pi_G0s(void) { int * t = gpi; hpi2 = t; }
void lo_pi_G0e(void) { int * t = gpi; hpi2 = t + 1; }
void lo_pi_G0d(void) { int * t = gpi; hpi2 = t; vpi(t); }
void lo_pi_Gga(void) { int * t = gpi; hi = hj; vpi(t); }
void lo_pi_Ggs(void) { int * t = gpi; hi = hj; hpi2 = t; }
void lo_pi_Gge(void) { int * t = gpi; hi = hj; hpi2 = t + 1; }
void lo_pi_Ggd(void) { int * t = gpi; hi = hj; hpi2 = t; vpi(t); }
void lo_pi_Gca(void) { int * t = gpi; v0(); vpi(t); }
void lo_pi_Gcs(void) { int * t = gpi; v0(); hpi2 = t; }
void lo_pi_Gce(void) { int * t = gpi; v0(); hpi2 = t + 1; }
void lo_pi_Gcd(void) { int * t = gpi; v0(); hpi2 = t; vpi(t); }
void lo_pi_Gsa(void) { int * t = gpi; *hp = 7; vpi(t); }
void lo_pi_Gss(void) { int * t = gpi; *hp = 7; hpi2 = t; }
void lo_pi_Gse(void) { int * t = gpi; *hp = 7; hpi2 = t + 1; }
void lo_pi_Gsd(void) { int * t = gpi; *hp = 7; hpi2 = t; vpi(t); }
void lo_pi_E0a(void) { int * t = gpia[2]; vpi(t); }
void lo_pi_E0s(void) { int * t = gpia[2]; hpi2 = t; }
void lo_pi_E0e(void) { int * t = gpia[2]; hpi2 = t + 1; }
void lo_pi_E0d(void) { int * t = gpia[2]; hpi2 = t; vpi(t); }
void lo_pi_Ega(void) { int * t = gpia[2]; hi = hj; vpi(t); }
void lo_pi_Egs(void) { int * t = gpia[2]; hi = hj; hpi2 = t; }
void lo_pi_Ege(void) { int * t = gpia[2]; hi = hj; hpi2 = t + 1; }
void lo_pi_Egd(void) { int * t = gpia[2]; hi = hj; hpi2 = t; vpi(t); }
void lo_pi_Eca(void) { int * t = gpia[2]; v0(); vpi(t); }
void lo_pi_Ecs(void) { int * t = gpia[2]; v0(); hpi2 = t; }
void lo_pi_Ece(void) { int * t = gpia[2]; v0(); hpi2 = t + 1; }
void lo_pi_Ecd(void) { int * t = gpia[2]; v0(); hpi2 = t; vpi(t); }
void lo_pi_Esa(void) { int * t = gpia[2]; *hp = 7; vpi(t); }
void lo_pi_Ess(void) { int * t = gpia[2]; *hp = 7; hpi2 = t; }
void lo_pi_Ese(void) { int * t = gpia[2]; *hp = 7; hpi2 = t + 1; }
void lo_pi_Esd(void) { int * t = gpia[2]; *hp = 7; hpi2 = t; vpi(t); }
void lo_pi_B0a(void) { int * t = gpi + 1; vpi(t); }
void lo_pi_B0s(void) { int * t = gpi + 1; hpi2 = t; }
void lo_pi_B0e(void) { int * t = gpi + 1; hpi2 = t + 1; }
void lo_pi_B0d(void) { int * t = gpi + 1; hpi2 = t; vpi(t); }
void lo_pi_Bga(void) { int * t = gpi + 1; hi = hj; vpi(t); }
void lo_pi_Bgs(void) { int * t = gpi + 1; hi = hj; hpi2 = t; }
void lo_pi_Bge(void) { int * t = gpi + 1; hi = hj; hpi2 = t + 1; }
void lo_pi_Bgd(void) { int * t = gpi + 1; hi = hj; hpi2 = t; vpi(t); }
void lo_pi_Bca(void) { int * t = gpi + 1; v0(); vpi(t); }
void lo_pi_Bcs(void) { int * t = gpi + 1; v0(); hpi2 = t; }
void lo_pi_Bce(void) { int * t = gpi + 1; v0(); hpi2 = t + 1; }
void lo_pi_Bcd(void) { int * t = gpi + 1; v0(); hpi2 = t; vpi(t); }
void lo_pi_Bsa(void) { int * t = gpi + 1; *hp = 7; vpi(t); }
void lo_pi_Bss(void) { int * t = gpi + 1; *hp = 7; hpi2 = t; }
void lo_pi_Bse(void) { int * t = gpi + 1; *hp = 7; hpi2 = t + 1; }
void lo_pi_Bsd(void) { int * t = gpi + 1; *hp = 7; hpi2 = t; vpi(t); }
void lo_pi_R0a(void) { int * t = rpi(); vpi(t); }
void lo_pi_R0s(void) { int * t = rpi(); hpi2 = t; }
void lo_pi_R0e(void) { int * t = rpi(); hpi2 = t + 1; }
void lo_pi_R0d(void) { int * t = rpi(); hpi2 = t; vpi(t); }
void lo_pi_Rga(void) { int * t = rpi(); hi = hj; vpi(t); }
void lo_pi_Rgs(void) { int * t = rpi(); hi = hj; hpi2 = t; }
void lo_pi_Rge(void) { int * t = rpi(); hi = hj; hpi2 = t + 1; }
void lo_pi_Rgd(void) { int * t = rpi(); hi = hj; hpi2 = t; vpi(t); }
void lo_pi_Rca(void) { int * t = rpi(); v0(); vpi(t); }
void lo_pi_Rcs(void) { int * t = rpi(); v0(); hpi2 = t; }
void lo_pi_Rce(void) { int * t = rpi(); v0(); hpi2 = t + 1; }
void lo_pi_Rcd(void) { int * t = rpi(); v0(); hpi2 = t; vpi(t); }
void lo_pi_Rsa(void) { int * t = rpi(); *hp = 7; vpi(t); }
void lo_pi_Rss(void) { int * t = rpi(); *hp = 7; hpi2 = t; }
void lo_pi_Rse(void) { int * t = rpi(); *hp = 7; hpi2 = t + 1; }
void lo_pi_Rsd(void) { int * t = rpi(); *hp = 7; hpi2 = t; vpi(t); }
