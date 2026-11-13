/* Probes for "element read over the left value" (er_*) and "operator = through BC" (bc_*), gen_elrd.py.
   t: c char, u unsigned char, i int, w unsigned int, l long, n unsigned long.  Index kinds I: a int param x,
   b char param x, c unsigned char param x, d unsigned int param x, L int loop counter i, f int local t,
   g unsigned char local t, h char local t, j unsigned int local t (locals start from gi).  The element is
   h<t>a[idx] unless stated.
   er_a_<t><I><L><o>: gT = L op h<t>a[idx];  L: K 7, G h<t>, Z h<t>a[1], C (h<t> - 3);  o: s - , o |.
   er_b_<t><I><D><L>: the destination kind D with  L - h<t>a[idx];  D: V local init, G global, E g<t>a[2],
     P *g<t>p, M gs.<t>, Q g<t>p[2], R return, A sink call argument, C if condition; L: G, E h<t>a[3], D hps-><t>, N !h<t>.
   er_c_<t><I><L><o>: the six operators + - | & ^ * with L: G, C (h<t> - 3).
   er_d_*: nested shapes (s1 (G + va[x]) * va[x]; s2 G - (G - va[x]); s3 *q - q[x]) and casts er_k_<t><R><o><I>:
     gR = (R)h<R> o (R)h<t>a[idx].
   er_e_<t><B><I><L>: the base kind B (A, M, D, Q, R) of the element, L: K or G.
   bc_a_<t><I><V>: g<t> = (h<t>a[idx] = V);  V: K 7, G v<t>, S h<t>a[1], N !vi, B (w<t>a[3] + v<t>) % 16.
   bc_b_<t><I><L><V>: L1 = (h<t>a[idx] = V) with L1: M gs.<t>, P *g<t>p, E g<t>a[2], D gps-><t>; V: K, G, S.
   bc_c_<t><I><X>: an assignment used as a value in a context X: C  if ((EL = 2) == gi) gi3 = 1;
     A  if (hi < 5 && (EL = 2) == gi) gi3 = 1;  R  return (g<t>p[0] = EL);  K  sink call (EL = v<t>);
     V  local init  T u = (EL = v<t>). */
struct st {
	char c; char ca[8];
	unsigned char u; unsigned char ua[8];
	int i; int ia[8];
	unsigned int w; unsigned int wa[8];
	long l; long la[8];
	unsigned long n; unsigned long na[8];
};
extern int gi3, gi; extern struct st gs, hs, vs, *gps, *hps;
extern char gc, hc, vc, gca[16], hca[16], wca[16], *gcp;
extern void skc(char); extern char rfc(void);
extern unsigned char gu, hu, vu, gua[16], hua[16], wua[16], *gup;
extern void sku(unsigned char); extern unsigned char rfu(void);
extern int gi, hi, vi, gia[16], hia[16], wia[16], *gip;
extern void ski(int); extern int rfi(void);
extern unsigned int gw, hw, vw, gwa[16], hwa[16], wwa[16], *gwp;
extern void skw(unsigned int); extern unsigned int rfw(void);
extern long gl, hl, vl, gla[16], hla[16], wla[16], *glp;
extern void skl(long); extern long rfl(void);
extern unsigned long gn, hn, vn, gna[16], hna[16], wna[16], *gnp;
extern void skn(unsigned long); extern unsigned long rfn(void);

void er_a_caKs(int x) { gc = 7 - hca[x]; }
void er_a_caKo(int x) { gc = 7 | hca[x]; }
void er_a_caGs(int x) { gc = hc - hca[x]; }
void er_a_caGo(int x) { gc = hc | hca[x]; }
void er_a_caZs(int x) { gc = hca[1] - hca[x]; }
void er_a_caZo(int x) { gc = hca[1] | hca[x]; }
void er_a_caCs(int x) { gc = (hc - 3) - hca[x]; }
void er_a_caCo(int x) { gc = (hc - 3) | hca[x]; }
void er_a_cbKs(char x) { gc = 7 - hca[x]; }
void er_a_cbKo(char x) { gc = 7 | hca[x]; }
void er_a_cbGs(char x) { gc = hc - hca[x]; }
void er_a_cbGo(char x) { gc = hc | hca[x]; }
void er_a_cbZs(char x) { gc = hca[1] - hca[x]; }
void er_a_cbZo(char x) { gc = hca[1] | hca[x]; }
void er_a_cbCs(char x) { gc = (hc - 3) - hca[x]; }
void er_a_cbCo(char x) { gc = (hc - 3) | hca[x]; }
void er_a_ccKs(unsigned char x) { gc = 7 - hca[x]; }
void er_a_ccKo(unsigned char x) { gc = 7 | hca[x]; }
void er_a_ccGs(unsigned char x) { gc = hc - hca[x]; }
void er_a_ccGo(unsigned char x) { gc = hc | hca[x]; }
void er_a_ccZs(unsigned char x) { gc = hca[1] - hca[x]; }
void er_a_ccZo(unsigned char x) { gc = hca[1] | hca[x]; }
void er_a_ccCs(unsigned char x) { gc = (hc - 3) - hca[x]; }
void er_a_ccCo(unsigned char x) { gc = (hc - 3) | hca[x]; }
void er_a_cdKs(unsigned int x) { gc = 7 - hca[x]; }
void er_a_cdKo(unsigned int x) { gc = 7 | hca[x]; }
void er_a_cdGs(unsigned int x) { gc = hc - hca[x]; }
void er_a_cdGo(unsigned int x) { gc = hc | hca[x]; }
void er_a_cdZs(unsigned int x) { gc = hca[1] - hca[x]; }
void er_a_cdZo(unsigned int x) { gc = hca[1] | hca[x]; }
void er_a_cdCs(unsigned int x) { gc = (hc - 3) - hca[x]; }
void er_a_cdCo(unsigned int x) { gc = (hc - 3) | hca[x]; }
void er_a_cLKs(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - hca[i]; } }
void er_a_cLKo(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 | hca[i]; } }
void er_a_cLGs(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - hca[i]; } }
void er_a_cLGo(int x) { int i; for (i = 0; i < 4; i++) { gc = hc | hca[i]; } }
void er_a_cLZs(int x) { int i; for (i = 0; i < 4; i++) { gc = hca[1] - hca[i]; } }
void er_a_cLZo(int x) { int i; for (i = 0; i < 4; i++) { gc = hca[1] | hca[i]; } }
void er_a_cLCs(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) - hca[i]; } }
void er_a_cLCo(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) | hca[i]; } }
void er_a_cfKs(int x) { int t = gi; gc = 7 - hca[t]; }
void er_a_cfKo(int x) { int t = gi; gc = 7 | hca[t]; }
void er_a_cfGs(int x) { int t = gi; gc = hc - hca[t]; }
void er_a_cfGo(int x) { int t = gi; gc = hc | hca[t]; }
void er_a_cfZs(int x) { int t = gi; gc = hca[1] - hca[t]; }
void er_a_cfZo(int x) { int t = gi; gc = hca[1] | hca[t]; }
void er_a_cfCs(int x) { int t = gi; gc = (hc - 3) - hca[t]; }
void er_a_cfCo(int x) { int t = gi; gc = (hc - 3) | hca[t]; }
void er_a_cgKs(int x) { unsigned char t = gi; gc = 7 - hca[t]; }
void er_a_cgKo(int x) { unsigned char t = gi; gc = 7 | hca[t]; }
void er_a_cgGs(int x) { unsigned char t = gi; gc = hc - hca[t]; }
void er_a_cgGo(int x) { unsigned char t = gi; gc = hc | hca[t]; }
void er_a_cgZs(int x) { unsigned char t = gi; gc = hca[1] - hca[t]; }
void er_a_cgZo(int x) { unsigned char t = gi; gc = hca[1] | hca[t]; }
void er_a_cgCs(int x) { unsigned char t = gi; gc = (hc - 3) - hca[t]; }
void er_a_cgCo(int x) { unsigned char t = gi; gc = (hc - 3) | hca[t]; }
void er_a_chKs(int x) { char t = gi; gc = 7 - hca[t]; }
void er_a_chKo(int x) { char t = gi; gc = 7 | hca[t]; }
void er_a_chGs(int x) { char t = gi; gc = hc - hca[t]; }
void er_a_chGo(int x) { char t = gi; gc = hc | hca[t]; }
void er_a_chZs(int x) { char t = gi; gc = hca[1] - hca[t]; }
void er_a_chZo(int x) { char t = gi; gc = hca[1] | hca[t]; }
void er_a_chCs(int x) { char t = gi; gc = (hc - 3) - hca[t]; }
void er_a_chCo(int x) { char t = gi; gc = (hc - 3) | hca[t]; }
void er_a_uaKs(int x) { gu = 7 - hua[x]; }
void er_a_uaKo(int x) { gu = 7 | hua[x]; }
void er_a_uaGs(int x) { gu = hu - hua[x]; }
void er_a_uaGo(int x) { gu = hu | hua[x]; }
void er_a_uaZs(int x) { gu = hua[1] - hua[x]; }
void er_a_uaZo(int x) { gu = hua[1] | hua[x]; }
void er_a_uaCs(int x) { gu = (hu - 3) - hua[x]; }
void er_a_uaCo(int x) { gu = (hu - 3) | hua[x]; }
void er_a_ubKs(char x) { gu = 7 - hua[x]; }
void er_a_ubKo(char x) { gu = 7 | hua[x]; }
void er_a_ubGs(char x) { gu = hu - hua[x]; }
void er_a_ubGo(char x) { gu = hu | hua[x]; }
void er_a_ubZs(char x) { gu = hua[1] - hua[x]; }
void er_a_ubZo(char x) { gu = hua[1] | hua[x]; }
void er_a_ubCs(char x) { gu = (hu - 3) - hua[x]; }
void er_a_ubCo(char x) { gu = (hu - 3) | hua[x]; }
void er_a_ucKs(unsigned char x) { gu = 7 - hua[x]; }
void er_a_ucKo(unsigned char x) { gu = 7 | hua[x]; }
void er_a_ucGs(unsigned char x) { gu = hu - hua[x]; }
void er_a_ucGo(unsigned char x) { gu = hu | hua[x]; }
void er_a_ucZs(unsigned char x) { gu = hua[1] - hua[x]; }
void er_a_ucZo(unsigned char x) { gu = hua[1] | hua[x]; }
void er_a_ucCs(unsigned char x) { gu = (hu - 3) - hua[x]; }
void er_a_ucCo(unsigned char x) { gu = (hu - 3) | hua[x]; }
void er_a_udKs(unsigned int x) { gu = 7 - hua[x]; }
void er_a_udKo(unsigned int x) { gu = 7 | hua[x]; }
void er_a_udGs(unsigned int x) { gu = hu - hua[x]; }
void er_a_udGo(unsigned int x) { gu = hu | hua[x]; }
void er_a_udZs(unsigned int x) { gu = hua[1] - hua[x]; }
void er_a_udZo(unsigned int x) { gu = hua[1] | hua[x]; }
void er_a_udCs(unsigned int x) { gu = (hu - 3) - hua[x]; }
void er_a_udCo(unsigned int x) { gu = (hu - 3) | hua[x]; }
void er_a_uLKs(int x) { int i; for (i = 0; i < 4; i++) { gu = 7 - hua[i]; } }
void er_a_uLKo(int x) { int i; for (i = 0; i < 4; i++) { gu = 7 | hua[i]; } }
void er_a_uLGs(int x) { int i; for (i = 0; i < 4; i++) { gu = hu - hua[i]; } }
void er_a_uLGo(int x) { int i; for (i = 0; i < 4; i++) { gu = hu | hua[i]; } }
void er_a_uLZs(int x) { int i; for (i = 0; i < 4; i++) { gu = hua[1] - hua[i]; } }
void er_a_uLZo(int x) { int i; for (i = 0; i < 4; i++) { gu = hua[1] | hua[i]; } }
void er_a_uLCs(int x) { int i; for (i = 0; i < 4; i++) { gu = (hu - 3) - hua[i]; } }
void er_a_uLCo(int x) { int i; for (i = 0; i < 4; i++) { gu = (hu - 3) | hua[i]; } }
void er_a_ufKs(int x) { int t = gi; gu = 7 - hua[t]; }
void er_a_ufKo(int x) { int t = gi; gu = 7 | hua[t]; }
void er_a_ufGs(int x) { int t = gi; gu = hu - hua[t]; }
void er_a_ufGo(int x) { int t = gi; gu = hu | hua[t]; }
void er_a_ufZs(int x) { int t = gi; gu = hua[1] - hua[t]; }
void er_a_ufZo(int x) { int t = gi; gu = hua[1] | hua[t]; }
void er_a_ufCs(int x) { int t = gi; gu = (hu - 3) - hua[t]; }
void er_a_ufCo(int x) { int t = gi; gu = (hu - 3) | hua[t]; }
void er_a_ugKs(int x) { unsigned char t = gi; gu = 7 - hua[t]; }
void er_a_ugKo(int x) { unsigned char t = gi; gu = 7 | hua[t]; }
void er_a_ugGs(int x) { unsigned char t = gi; gu = hu - hua[t]; }
void er_a_ugGo(int x) { unsigned char t = gi; gu = hu | hua[t]; }
void er_a_ugZs(int x) { unsigned char t = gi; gu = hua[1] - hua[t]; }
void er_a_ugZo(int x) { unsigned char t = gi; gu = hua[1] | hua[t]; }
void er_a_ugCs(int x) { unsigned char t = gi; gu = (hu - 3) - hua[t]; }
void er_a_ugCo(int x) { unsigned char t = gi; gu = (hu - 3) | hua[t]; }
void er_a_uhKs(int x) { char t = gi; gu = 7 - hua[t]; }
void er_a_uhKo(int x) { char t = gi; gu = 7 | hua[t]; }
void er_a_uhGs(int x) { char t = gi; gu = hu - hua[t]; }
void er_a_uhGo(int x) { char t = gi; gu = hu | hua[t]; }
void er_a_uhZs(int x) { char t = gi; gu = hua[1] - hua[t]; }
void er_a_uhZo(int x) { char t = gi; gu = hua[1] | hua[t]; }
void er_a_uhCs(int x) { char t = gi; gu = (hu - 3) - hua[t]; }
void er_a_uhCo(int x) { char t = gi; gu = (hu - 3) | hua[t]; }
void er_a_iaKs(int x) { gi = 7 - hia[x]; }
void er_a_iaKo(int x) { gi = 7 | hia[x]; }
void er_a_iaGs(int x) { gi = hi - hia[x]; }
void er_a_iaGo(int x) { gi = hi | hia[x]; }
void er_a_iaZs(int x) { gi = hia[1] - hia[x]; }
void er_a_iaZo(int x) { gi = hia[1] | hia[x]; }
void er_a_iaCs(int x) { gi = (hi - 3) - hia[x]; }
void er_a_iaCo(int x) { gi = (hi - 3) | hia[x]; }
void er_a_ibKs(char x) { gi = 7 - hia[x]; }
void er_a_ibKo(char x) { gi = 7 | hia[x]; }
void er_a_ibGs(char x) { gi = hi - hia[x]; }
void er_a_ibGo(char x) { gi = hi | hia[x]; }
void er_a_ibZs(char x) { gi = hia[1] - hia[x]; }
void er_a_ibZo(char x) { gi = hia[1] | hia[x]; }
void er_a_ibCs(char x) { gi = (hi - 3) - hia[x]; }
void er_a_ibCo(char x) { gi = (hi - 3) | hia[x]; }
void er_a_icKs(unsigned char x) { gi = 7 - hia[x]; }
void er_a_icKo(unsigned char x) { gi = 7 | hia[x]; }
void er_a_icGs(unsigned char x) { gi = hi - hia[x]; }
void er_a_icGo(unsigned char x) { gi = hi | hia[x]; }
void er_a_icZs(unsigned char x) { gi = hia[1] - hia[x]; }
void er_a_icZo(unsigned char x) { gi = hia[1] | hia[x]; }
void er_a_icCs(unsigned char x) { gi = (hi - 3) - hia[x]; }
void er_a_icCo(unsigned char x) { gi = (hi - 3) | hia[x]; }
void er_a_idKs(unsigned int x) { gi = 7 - hia[x]; }
void er_a_idKo(unsigned int x) { gi = 7 | hia[x]; }
void er_a_idGs(unsigned int x) { gi = hi - hia[x]; }
void er_a_idGo(unsigned int x) { gi = hi | hia[x]; }
void er_a_idZs(unsigned int x) { gi = hia[1] - hia[x]; }
void er_a_idZo(unsigned int x) { gi = hia[1] | hia[x]; }
void er_a_idCs(unsigned int x) { gi = (hi - 3) - hia[x]; }
void er_a_idCo(unsigned int x) { gi = (hi - 3) | hia[x]; }
void er_a_iLKs(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - hia[i]; } }
void er_a_iLKo(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 | hia[i]; } }
void er_a_iLGs(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hia[i]; } }
void er_a_iLGo(int x) { int i; for (i = 0; i < 4; i++) { gi = hi | hia[i]; } }
void er_a_iLZs(int x) { int i; for (i = 0; i < 4; i++) { gi = hia[1] - hia[i]; } }
void er_a_iLZo(int x) { int i; for (i = 0; i < 4; i++) { gi = hia[1] | hia[i]; } }
void er_a_iLCs(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) - hia[i]; } }
void er_a_iLCo(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) | hia[i]; } }
void er_a_ifKs(int x) { int t = gi; gi = 7 - hia[t]; }
void er_a_ifKo(int x) { int t = gi; gi = 7 | hia[t]; }
void er_a_ifGs(int x) { int t = gi; gi = hi - hia[t]; }
void er_a_ifGo(int x) { int t = gi; gi = hi | hia[t]; }
void er_a_ifZs(int x) { int t = gi; gi = hia[1] - hia[t]; }
void er_a_ifZo(int x) { int t = gi; gi = hia[1] | hia[t]; }
void er_a_ifCs(int x) { int t = gi; gi = (hi - 3) - hia[t]; }
void er_a_ifCo(int x) { int t = gi; gi = (hi - 3) | hia[t]; }
void er_a_igKs(int x) { unsigned char t = gi; gi = 7 - hia[t]; }
void er_a_igKo(int x) { unsigned char t = gi; gi = 7 | hia[t]; }
void er_a_igGs(int x) { unsigned char t = gi; gi = hi - hia[t]; }
void er_a_igGo(int x) { unsigned char t = gi; gi = hi | hia[t]; }
void er_a_igZs(int x) { unsigned char t = gi; gi = hia[1] - hia[t]; }
void er_a_igZo(int x) { unsigned char t = gi; gi = hia[1] | hia[t]; }
void er_a_igCs(int x) { unsigned char t = gi; gi = (hi - 3) - hia[t]; }
void er_a_igCo(int x) { unsigned char t = gi; gi = (hi - 3) | hia[t]; }
void er_a_ihKs(int x) { char t = gi; gi = 7 - hia[t]; }
void er_a_ihKo(int x) { char t = gi; gi = 7 | hia[t]; }
void er_a_ihGs(int x) { char t = gi; gi = hi - hia[t]; }
void er_a_ihGo(int x) { char t = gi; gi = hi | hia[t]; }
void er_a_ihZs(int x) { char t = gi; gi = hia[1] - hia[t]; }
void er_a_ihZo(int x) { char t = gi; gi = hia[1] | hia[t]; }
void er_a_ihCs(int x) { char t = gi; gi = (hi - 3) - hia[t]; }
void er_a_ihCo(int x) { char t = gi; gi = (hi - 3) | hia[t]; }
void er_a_waKs(int x) { gw = 7 - hwa[x]; }
void er_a_waKo(int x) { gw = 7 | hwa[x]; }
void er_a_waGs(int x) { gw = hw - hwa[x]; }
void er_a_waGo(int x) { gw = hw | hwa[x]; }
void er_a_waZs(int x) { gw = hwa[1] - hwa[x]; }
void er_a_waZo(int x) { gw = hwa[1] | hwa[x]; }
void er_a_waCs(int x) { gw = (hw - 3) - hwa[x]; }
void er_a_waCo(int x) { gw = (hw - 3) | hwa[x]; }
void er_a_wbKs(char x) { gw = 7 - hwa[x]; }
void er_a_wbKo(char x) { gw = 7 | hwa[x]; }
void er_a_wbGs(char x) { gw = hw - hwa[x]; }
void er_a_wbGo(char x) { gw = hw | hwa[x]; }
void er_a_wbZs(char x) { gw = hwa[1] - hwa[x]; }
void er_a_wbZo(char x) { gw = hwa[1] | hwa[x]; }
void er_a_wbCs(char x) { gw = (hw - 3) - hwa[x]; }
void er_a_wbCo(char x) { gw = (hw - 3) | hwa[x]; }
void er_a_wcKs(unsigned char x) { gw = 7 - hwa[x]; }
void er_a_wcKo(unsigned char x) { gw = 7 | hwa[x]; }
void er_a_wcGs(unsigned char x) { gw = hw - hwa[x]; }
void er_a_wcGo(unsigned char x) { gw = hw | hwa[x]; }
void er_a_wcZs(unsigned char x) { gw = hwa[1] - hwa[x]; }
void er_a_wcZo(unsigned char x) { gw = hwa[1] | hwa[x]; }
void er_a_wcCs(unsigned char x) { gw = (hw - 3) - hwa[x]; }
void er_a_wcCo(unsigned char x) { gw = (hw - 3) | hwa[x]; }
void er_a_wdKs(unsigned int x) { gw = 7 - hwa[x]; }
void er_a_wdKo(unsigned int x) { gw = 7 | hwa[x]; }
void er_a_wdGs(unsigned int x) { gw = hw - hwa[x]; }
void er_a_wdGo(unsigned int x) { gw = hw | hwa[x]; }
void er_a_wdZs(unsigned int x) { gw = hwa[1] - hwa[x]; }
void er_a_wdZo(unsigned int x) { gw = hwa[1] | hwa[x]; }
void er_a_wdCs(unsigned int x) { gw = (hw - 3) - hwa[x]; }
void er_a_wdCo(unsigned int x) { gw = (hw - 3) | hwa[x]; }
void er_a_wLKs(int x) { int i; for (i = 0; i < 4; i++) { gw = 7 - hwa[i]; } }
void er_a_wLKo(int x) { int i; for (i = 0; i < 4; i++) { gw = 7 | hwa[i]; } }
void er_a_wLGs(int x) { int i; for (i = 0; i < 4; i++) { gw = hw - hwa[i]; } }
void er_a_wLGo(int x) { int i; for (i = 0; i < 4; i++) { gw = hw | hwa[i]; } }
void er_a_wLZs(int x) { int i; for (i = 0; i < 4; i++) { gw = hwa[1] - hwa[i]; } }
void er_a_wLZo(int x) { int i; for (i = 0; i < 4; i++) { gw = hwa[1] | hwa[i]; } }
void er_a_wLCs(int x) { int i; for (i = 0; i < 4; i++) { gw = (hw - 3) - hwa[i]; } }
void er_a_wLCo(int x) { int i; for (i = 0; i < 4; i++) { gw = (hw - 3) | hwa[i]; } }
void er_a_wfKs(int x) { int t = gi; gw = 7 - hwa[t]; }
void er_a_wfKo(int x) { int t = gi; gw = 7 | hwa[t]; }
void er_a_wfGs(int x) { int t = gi; gw = hw - hwa[t]; }
void er_a_wfGo(int x) { int t = gi; gw = hw | hwa[t]; }
void er_a_wfZs(int x) { int t = gi; gw = hwa[1] - hwa[t]; }
void er_a_wfZo(int x) { int t = gi; gw = hwa[1] | hwa[t]; }
void er_a_wfCs(int x) { int t = gi; gw = (hw - 3) - hwa[t]; }
void er_a_wfCo(int x) { int t = gi; gw = (hw - 3) | hwa[t]; }
void er_a_wgKs(int x) { unsigned char t = gi; gw = 7 - hwa[t]; }
void er_a_wgKo(int x) { unsigned char t = gi; gw = 7 | hwa[t]; }
void er_a_wgGs(int x) { unsigned char t = gi; gw = hw - hwa[t]; }
void er_a_wgGo(int x) { unsigned char t = gi; gw = hw | hwa[t]; }
void er_a_wgZs(int x) { unsigned char t = gi; gw = hwa[1] - hwa[t]; }
void er_a_wgZo(int x) { unsigned char t = gi; gw = hwa[1] | hwa[t]; }
void er_a_wgCs(int x) { unsigned char t = gi; gw = (hw - 3) - hwa[t]; }
void er_a_wgCo(int x) { unsigned char t = gi; gw = (hw - 3) | hwa[t]; }
void er_a_whKs(int x) { char t = gi; gw = 7 - hwa[t]; }
void er_a_whKo(int x) { char t = gi; gw = 7 | hwa[t]; }
void er_a_whGs(int x) { char t = gi; gw = hw - hwa[t]; }
void er_a_whGo(int x) { char t = gi; gw = hw | hwa[t]; }
void er_a_whZs(int x) { char t = gi; gw = hwa[1] - hwa[t]; }
void er_a_whZo(int x) { char t = gi; gw = hwa[1] | hwa[t]; }
void er_a_whCs(int x) { char t = gi; gw = (hw - 3) - hwa[t]; }
void er_a_whCo(int x) { char t = gi; gw = (hw - 3) | hwa[t]; }
void er_a_laKs(int x) { gl = 7 - hla[x]; }
void er_a_laKo(int x) { gl = 7 | hla[x]; }
void er_a_laGs(int x) { gl = hl - hla[x]; }
void er_a_laGo(int x) { gl = hl | hla[x]; }
void er_a_laZs(int x) { gl = hla[1] - hla[x]; }
void er_a_laZo(int x) { gl = hla[1] | hla[x]; }
void er_a_laCs(int x) { gl = (hl - 3) - hla[x]; }
void er_a_laCo(int x) { gl = (hl - 3) | hla[x]; }
void er_a_lbKs(char x) { gl = 7 - hla[x]; }
void er_a_lbKo(char x) { gl = 7 | hla[x]; }
void er_a_lbGs(char x) { gl = hl - hla[x]; }
void er_a_lbGo(char x) { gl = hl | hla[x]; }
void er_a_lbZs(char x) { gl = hla[1] - hla[x]; }
void er_a_lbZo(char x) { gl = hla[1] | hla[x]; }
void er_a_lbCs(char x) { gl = (hl - 3) - hla[x]; }
void er_a_lbCo(char x) { gl = (hl - 3) | hla[x]; }
void er_a_lcKs(unsigned char x) { gl = 7 - hla[x]; }
void er_a_lcKo(unsigned char x) { gl = 7 | hla[x]; }
void er_a_lcGs(unsigned char x) { gl = hl - hla[x]; }
void er_a_lcGo(unsigned char x) { gl = hl | hla[x]; }
void er_a_lcZs(unsigned char x) { gl = hla[1] - hla[x]; }
void er_a_lcZo(unsigned char x) { gl = hla[1] | hla[x]; }
void er_a_lcCs(unsigned char x) { gl = (hl - 3) - hla[x]; }
void er_a_lcCo(unsigned char x) { gl = (hl - 3) | hla[x]; }
void er_a_ldKs(unsigned int x) { gl = 7 - hla[x]; }
void er_a_ldKo(unsigned int x) { gl = 7 | hla[x]; }
void er_a_ldGs(unsigned int x) { gl = hl - hla[x]; }
void er_a_ldGo(unsigned int x) { gl = hl | hla[x]; }
void er_a_ldZs(unsigned int x) { gl = hla[1] - hla[x]; }
void er_a_ldZo(unsigned int x) { gl = hla[1] | hla[x]; }
void er_a_ldCs(unsigned int x) { gl = (hl - 3) - hla[x]; }
void er_a_ldCo(unsigned int x) { gl = (hl - 3) | hla[x]; }
void er_a_lLKs(int x) { int i; for (i = 0; i < 4; i++) { gl = 7 - hla[i]; } }
void er_a_lLKo(int x) { int i; for (i = 0; i < 4; i++) { gl = 7 | hla[i]; } }
void er_a_lLGs(int x) { int i; for (i = 0; i < 4; i++) { gl = hl - hla[i]; } }
void er_a_lLGo(int x) { int i; for (i = 0; i < 4; i++) { gl = hl | hla[i]; } }
void er_a_lLZs(int x) { int i; for (i = 0; i < 4; i++) { gl = hla[1] - hla[i]; } }
void er_a_lLZo(int x) { int i; for (i = 0; i < 4; i++) { gl = hla[1] | hla[i]; } }
void er_a_lLCs(int x) { int i; for (i = 0; i < 4; i++) { gl = (hl - 3) - hla[i]; } }
void er_a_lLCo(int x) { int i; for (i = 0; i < 4; i++) { gl = (hl - 3) | hla[i]; } }
void er_a_lfKs(int x) { int t = gi; gl = 7 - hla[t]; }
void er_a_lfKo(int x) { int t = gi; gl = 7 | hla[t]; }
void er_a_lfGs(int x) { int t = gi; gl = hl - hla[t]; }
void er_a_lfGo(int x) { int t = gi; gl = hl | hla[t]; }
void er_a_lfZs(int x) { int t = gi; gl = hla[1] - hla[t]; }
void er_a_lfZo(int x) { int t = gi; gl = hla[1] | hla[t]; }
void er_a_lfCs(int x) { int t = gi; gl = (hl - 3) - hla[t]; }
void er_a_lfCo(int x) { int t = gi; gl = (hl - 3) | hla[t]; }
void er_a_lgKs(int x) { unsigned char t = gi; gl = 7 - hla[t]; }
void er_a_lgKo(int x) { unsigned char t = gi; gl = 7 | hla[t]; }
void er_a_lgGs(int x) { unsigned char t = gi; gl = hl - hla[t]; }
void er_a_lgGo(int x) { unsigned char t = gi; gl = hl | hla[t]; }
void er_a_lgZs(int x) { unsigned char t = gi; gl = hla[1] - hla[t]; }
void er_a_lgZo(int x) { unsigned char t = gi; gl = hla[1] | hla[t]; }
void er_a_lgCs(int x) { unsigned char t = gi; gl = (hl - 3) - hla[t]; }
void er_a_lgCo(int x) { unsigned char t = gi; gl = (hl - 3) | hla[t]; }
void er_a_lhKs(int x) { char t = gi; gl = 7 - hla[t]; }
void er_a_lhKo(int x) { char t = gi; gl = 7 | hla[t]; }
void er_a_lhGs(int x) { char t = gi; gl = hl - hla[t]; }
void er_a_lhGo(int x) { char t = gi; gl = hl | hla[t]; }
void er_a_lhZs(int x) { char t = gi; gl = hla[1] - hla[t]; }
void er_a_lhZo(int x) { char t = gi; gl = hla[1] | hla[t]; }
void er_a_lhCs(int x) { char t = gi; gl = (hl - 3) - hla[t]; }
void er_a_lhCo(int x) { char t = gi; gl = (hl - 3) | hla[t]; }
void er_a_naKs(int x) { gn = 7 - hna[x]; }
void er_a_naKo(int x) { gn = 7 | hna[x]; }
void er_a_naGs(int x) { gn = hn - hna[x]; }
void er_a_naGo(int x) { gn = hn | hna[x]; }
void er_a_naZs(int x) { gn = hna[1] - hna[x]; }
void er_a_naZo(int x) { gn = hna[1] | hna[x]; }
void er_a_naCs(int x) { gn = (hn - 3) - hna[x]; }
void er_a_naCo(int x) { gn = (hn - 3) | hna[x]; }
void er_a_nbKs(char x) { gn = 7 - hna[x]; }
void er_a_nbKo(char x) { gn = 7 | hna[x]; }
void er_a_nbGs(char x) { gn = hn - hna[x]; }
void er_a_nbGo(char x) { gn = hn | hna[x]; }
void er_a_nbZs(char x) { gn = hna[1] - hna[x]; }
void er_a_nbZo(char x) { gn = hna[1] | hna[x]; }
void er_a_nbCs(char x) { gn = (hn - 3) - hna[x]; }
void er_a_nbCo(char x) { gn = (hn - 3) | hna[x]; }
void er_a_ncKs(unsigned char x) { gn = 7 - hna[x]; }
void er_a_ncKo(unsigned char x) { gn = 7 | hna[x]; }
void er_a_ncGs(unsigned char x) { gn = hn - hna[x]; }
void er_a_ncGo(unsigned char x) { gn = hn | hna[x]; }
void er_a_ncZs(unsigned char x) { gn = hna[1] - hna[x]; }
void er_a_ncZo(unsigned char x) { gn = hna[1] | hna[x]; }
void er_a_ncCs(unsigned char x) { gn = (hn - 3) - hna[x]; }
void er_a_ncCo(unsigned char x) { gn = (hn - 3) | hna[x]; }
void er_a_ndKs(unsigned int x) { gn = 7 - hna[x]; }
void er_a_ndKo(unsigned int x) { gn = 7 | hna[x]; }
void er_a_ndGs(unsigned int x) { gn = hn - hna[x]; }
void er_a_ndGo(unsigned int x) { gn = hn | hna[x]; }
void er_a_ndZs(unsigned int x) { gn = hna[1] - hna[x]; }
void er_a_ndZo(unsigned int x) { gn = hna[1] | hna[x]; }
void er_a_ndCs(unsigned int x) { gn = (hn - 3) - hna[x]; }
void er_a_ndCo(unsigned int x) { gn = (hn - 3) | hna[x]; }
void er_a_nLKs(int x) { int i; for (i = 0; i < 4; i++) { gn = 7 - hna[i]; } }
void er_a_nLKo(int x) { int i; for (i = 0; i < 4; i++) { gn = 7 | hna[i]; } }
void er_a_nLGs(int x) { int i; for (i = 0; i < 4; i++) { gn = hn - hna[i]; } }
void er_a_nLGo(int x) { int i; for (i = 0; i < 4; i++) { gn = hn | hna[i]; } }
void er_a_nLZs(int x) { int i; for (i = 0; i < 4; i++) { gn = hna[1] - hna[i]; } }
void er_a_nLZo(int x) { int i; for (i = 0; i < 4; i++) { gn = hna[1] | hna[i]; } }
void er_a_nLCs(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) - hna[i]; } }
void er_a_nLCo(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) | hna[i]; } }
void er_a_nfKs(int x) { int t = gi; gn = 7 - hna[t]; }
void er_a_nfKo(int x) { int t = gi; gn = 7 | hna[t]; }
void er_a_nfGs(int x) { int t = gi; gn = hn - hna[t]; }
void er_a_nfGo(int x) { int t = gi; gn = hn | hna[t]; }
void er_a_nfZs(int x) { int t = gi; gn = hna[1] - hna[t]; }
void er_a_nfZo(int x) { int t = gi; gn = hna[1] | hna[t]; }
void er_a_nfCs(int x) { int t = gi; gn = (hn - 3) - hna[t]; }
void er_a_nfCo(int x) { int t = gi; gn = (hn - 3) | hna[t]; }
void er_a_ngKs(int x) { unsigned char t = gi; gn = 7 - hna[t]; }
void er_a_ngKo(int x) { unsigned char t = gi; gn = 7 | hna[t]; }
void er_a_ngGs(int x) { unsigned char t = gi; gn = hn - hna[t]; }
void er_a_ngGo(int x) { unsigned char t = gi; gn = hn | hna[t]; }
void er_a_ngZs(int x) { unsigned char t = gi; gn = hna[1] - hna[t]; }
void er_a_ngZo(int x) { unsigned char t = gi; gn = hna[1] | hna[t]; }
void er_a_ngCs(int x) { unsigned char t = gi; gn = (hn - 3) - hna[t]; }
void er_a_ngCo(int x) { unsigned char t = gi; gn = (hn - 3) | hna[t]; }
void er_a_nhKs(int x) { char t = gi; gn = 7 - hna[t]; }
void er_a_nhKo(int x) { char t = gi; gn = 7 | hna[t]; }
void er_a_nhGs(int x) { char t = gi; gn = hn - hna[t]; }
void er_a_nhGo(int x) { char t = gi; gn = hn | hna[t]; }
void er_a_nhZs(int x) { char t = gi; gn = hna[1] - hna[t]; }
void er_a_nhZo(int x) { char t = gi; gn = hna[1] | hna[t]; }
void er_a_nhCs(int x) { char t = gi; gn = (hn - 3) - hna[t]; }
void er_a_nhCo(int x) { char t = gi; gn = (hn - 3) | hna[t]; }

void er_b_iaVG(int x) { int u = hi - hia[x]; }
void er_b_iaVE(int x) { int u = hia[3] - hia[x]; }
void er_b_iaVD(int x) { int u = hps->i - hia[x]; }
void er_b_iaVN(int x) { int u = !hi - hia[x]; }
void er_b_iaGG(int x) { gi = hi - hia[x]; }
void er_b_iaGE(int x) { gi = hia[3] - hia[x]; }
void er_b_iaGD(int x) { gi = hps->i - hia[x]; }
void er_b_iaGN(int x) { gi = !hi - hia[x]; }
void er_b_iaEG(int x) { gia[2] = hi - hia[x]; }
void er_b_iaEE(int x) { gia[2] = hia[3] - hia[x]; }
void er_b_iaED(int x) { gia[2] = hps->i - hia[x]; }
void er_b_iaEN(int x) { gia[2] = !hi - hia[x]; }
void er_b_iaPG(int x) { *gip = hi - hia[x]; }
void er_b_iaPE(int x) { *gip = hia[3] - hia[x]; }
void er_b_iaPD(int x) { *gip = hps->i - hia[x]; }
void er_b_iaPN(int x) { *gip = !hi - hia[x]; }
void er_b_iaMG(int x) { gs.i = hi - hia[x]; }
void er_b_iaME(int x) { gs.i = hia[3] - hia[x]; }
void er_b_iaMD(int x) { gs.i = hps->i - hia[x]; }
void er_b_iaMN(int x) { gs.i = !hi - hia[x]; }
void er_b_iaQG(int x) { gip[2] = hi - hia[x]; }
void er_b_iaQE(int x) { gip[2] = hia[3] - hia[x]; }
void er_b_iaQD(int x) { gip[2] = hps->i - hia[x]; }
void er_b_iaQN(int x) { gip[2] = !hi - hia[x]; }
int er_b_iaRG(int x) { return hi - hia[x]; }
int er_b_iaRE(int x) { return hia[3] - hia[x]; }
int er_b_iaRD(int x) { return hps->i - hia[x]; }
int er_b_iaRN(int x) { return !hi - hia[x]; }
void er_b_iaAG(int x) { ski(hi - hia[x]); }
void er_b_iaAE(int x) { ski(hia[3] - hia[x]); }
void er_b_iaAD(int x) { ski(hps->i - hia[x]); }
void er_b_iaAN(int x) { ski(!hi - hia[x]); }
void er_b_iaCG(int x) { if (hi - hia[x] > 3) gi3 = 1; }
void er_b_iaCE(int x) { if (hia[3] - hia[x] > 3) gi3 = 1; }
void er_b_iaCD(int x) { if (hps->i - hia[x] > 3) gi3 = 1; }
void er_b_iaCN(int x) { if (!hi - hia[x] > 3) gi3 = 1; }
void er_b_ibVG(char x) { int u = hi - hia[x]; }
void er_b_ibVE(char x) { int u = hia[3] - hia[x]; }
void er_b_ibVD(char x) { int u = hps->i - hia[x]; }
void er_b_ibVN(char x) { int u = !hi - hia[x]; }
void er_b_ibGG(char x) { gi = hi - hia[x]; }
void er_b_ibGE(char x) { gi = hia[3] - hia[x]; }
void er_b_ibGD(char x) { gi = hps->i - hia[x]; }
void er_b_ibGN(char x) { gi = !hi - hia[x]; }
void er_b_ibEG(char x) { gia[2] = hi - hia[x]; }
void er_b_ibEE(char x) { gia[2] = hia[3] - hia[x]; }
void er_b_ibED(char x) { gia[2] = hps->i - hia[x]; }
void er_b_ibEN(char x) { gia[2] = !hi - hia[x]; }
void er_b_ibPG(char x) { *gip = hi - hia[x]; }
void er_b_ibPE(char x) { *gip = hia[3] - hia[x]; }
void er_b_ibPD(char x) { *gip = hps->i - hia[x]; }
void er_b_ibPN(char x) { *gip = !hi - hia[x]; }
void er_b_ibMG(char x) { gs.i = hi - hia[x]; }
void er_b_ibME(char x) { gs.i = hia[3] - hia[x]; }
void er_b_ibMD(char x) { gs.i = hps->i - hia[x]; }
void er_b_ibMN(char x) { gs.i = !hi - hia[x]; }
void er_b_ibQG(char x) { gip[2] = hi - hia[x]; }
void er_b_ibQE(char x) { gip[2] = hia[3] - hia[x]; }
void er_b_ibQD(char x) { gip[2] = hps->i - hia[x]; }
void er_b_ibQN(char x) { gip[2] = !hi - hia[x]; }
int er_b_ibRG(char x) { return hi - hia[x]; }
int er_b_ibRE(char x) { return hia[3] - hia[x]; }
int er_b_ibRD(char x) { return hps->i - hia[x]; }
int er_b_ibRN(char x) { return !hi - hia[x]; }
void er_b_ibAG(char x) { ski(hi - hia[x]); }
void er_b_ibAE(char x) { ski(hia[3] - hia[x]); }
void er_b_ibAD(char x) { ski(hps->i - hia[x]); }
void er_b_ibAN(char x) { ski(!hi - hia[x]); }
void er_b_ibCG(char x) { if (hi - hia[x] > 3) gi3 = 1; }
void er_b_ibCE(char x) { if (hia[3] - hia[x] > 3) gi3 = 1; }
void er_b_ibCD(char x) { if (hps->i - hia[x] > 3) gi3 = 1; }
void er_b_ibCN(char x) { if (!hi - hia[x] > 3) gi3 = 1; }
void er_b_iLVG(int x) { int i; int u = 0; for (i = 0; i < 4; i++) { u = hi - hia[i]; } gi3 = u; }
void er_b_iLVE(int x) { int i; int u = 0; for (i = 0; i < 4; i++) { u = hia[3] - hia[i]; } gi3 = u; }
void er_b_iLVD(int x) { int i; int u = 0; for (i = 0; i < 4; i++) { u = hps->i - hia[i]; } gi3 = u; }
void er_b_iLVN(int x) { int i; int u = 0; for (i = 0; i < 4; i++) { u = !hi - hia[i]; } gi3 = u; }
void er_b_iLGG(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hia[i]; } }
void er_b_iLGE(int x) { int i; for (i = 0; i < 4; i++) { gi = hia[3] - hia[i]; } }
void er_b_iLGD(int x) { int i; for (i = 0; i < 4; i++) { gi = hps->i - hia[i]; } }
void er_b_iLGN(int x) { int i; for (i = 0; i < 4; i++) { gi = !hi - hia[i]; } }
void er_b_iLEG(int x) { int i; for (i = 0; i < 4; i++) { gia[2] = hi - hia[i]; } }
void er_b_iLEE(int x) { int i; for (i = 0; i < 4; i++) { gia[2] = hia[3] - hia[i]; } }
void er_b_iLED(int x) { int i; for (i = 0; i < 4; i++) { gia[2] = hps->i - hia[i]; } }
void er_b_iLEN(int x) { int i; for (i = 0; i < 4; i++) { gia[2] = !hi - hia[i]; } }
void er_b_iLPG(int x) { int i; for (i = 0; i < 4; i++) { *gip = hi - hia[i]; } }
void er_b_iLPE(int x) { int i; for (i = 0; i < 4; i++) { *gip = hia[3] - hia[i]; } }
void er_b_iLPD(int x) { int i; for (i = 0; i < 4; i++) { *gip = hps->i - hia[i]; } }
void er_b_iLPN(int x) { int i; for (i = 0; i < 4; i++) { *gip = !hi - hia[i]; } }
void er_b_iLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.i = hi - hia[i]; } }
void er_b_iLME(int x) { int i; for (i = 0; i < 4; i++) { gs.i = hia[3] - hia[i]; } }
void er_b_iLMD(int x) { int i; for (i = 0; i < 4; i++) { gs.i = hps->i - hia[i]; } }
void er_b_iLMN(int x) { int i; for (i = 0; i < 4; i++) { gs.i = !hi - hia[i]; } }
void er_b_iLQG(int x) { int i; for (i = 0; i < 4; i++) { gip[2] = hi - hia[i]; } }
void er_b_iLQE(int x) { int i; for (i = 0; i < 4; i++) { gip[2] = hia[3] - hia[i]; } }
void er_b_iLQD(int x) { int i; for (i = 0; i < 4; i++) { gip[2] = hps->i - hia[i]; } }
void er_b_iLQN(int x) { int i; for (i = 0; i < 4; i++) { gip[2] = !hi - hia[i]; } }
void er_b_iLAG(int x) { int i; for (i = 0; i < 4; i++) { ski(hi - hia[i]); } }
void er_b_iLAE(int x) { int i; for (i = 0; i < 4; i++) { ski(hia[3] - hia[i]); } }
void er_b_iLAD(int x) { int i; for (i = 0; i < 4; i++) { ski(hps->i - hia[i]); } }
void er_b_iLAN(int x) { int i; for (i = 0; i < 4; i++) { ski(!hi - hia[i]); } }
void er_b_iLCG(int x) { int i; for (i = 0; i < 4; i++) { if (hi - hia[i] > 3) gi3 = 1; } }
void er_b_iLCE(int x) { int i; for (i = 0; i < 4; i++) { if (hia[3] - hia[i] > 3) gi3 = 1; } }
void er_b_iLCD(int x) { int i; for (i = 0; i < 4; i++) { if (hps->i - hia[i] > 3) gi3 = 1; } }
void er_b_iLCN(int x) { int i; for (i = 0; i < 4; i++) { if (!hi - hia[i] > 3) gi3 = 1; } }
void er_b_naVG(int x) { unsigned long u = hn - hna[x]; }
void er_b_naVE(int x) { unsigned long u = hna[3] - hna[x]; }
void er_b_naVD(int x) { unsigned long u = hps->n - hna[x]; }
void er_b_naVN(int x) { unsigned long u = !hn - hna[x]; }
void er_b_naGG(int x) { gn = hn - hna[x]; }
void er_b_naGE(int x) { gn = hna[3] - hna[x]; }
void er_b_naGD(int x) { gn = hps->n - hna[x]; }
void er_b_naGN(int x) { gn = !hn - hna[x]; }
void er_b_naEG(int x) { gna[2] = hn - hna[x]; }
void er_b_naEE(int x) { gna[2] = hna[3] - hna[x]; }
void er_b_naED(int x) { gna[2] = hps->n - hna[x]; }
void er_b_naEN(int x) { gna[2] = !hn - hna[x]; }
void er_b_naPG(int x) { *gnp = hn - hna[x]; }
void er_b_naPE(int x) { *gnp = hna[3] - hna[x]; }
void er_b_naPD(int x) { *gnp = hps->n - hna[x]; }
void er_b_naPN(int x) { *gnp = !hn - hna[x]; }
void er_b_naMG(int x) { gs.n = hn - hna[x]; }
void er_b_naME(int x) { gs.n = hna[3] - hna[x]; }
void er_b_naMD(int x) { gs.n = hps->n - hna[x]; }
void er_b_naMN(int x) { gs.n = !hn - hna[x]; }
void er_b_naQG(int x) { gnp[2] = hn - hna[x]; }
void er_b_naQE(int x) { gnp[2] = hna[3] - hna[x]; }
void er_b_naQD(int x) { gnp[2] = hps->n - hna[x]; }
void er_b_naQN(int x) { gnp[2] = !hn - hna[x]; }
unsigned long er_b_naRG(int x) { return hn - hna[x]; }
unsigned long er_b_naRE(int x) { return hna[3] - hna[x]; }
unsigned long er_b_naRD(int x) { return hps->n - hna[x]; }
unsigned long er_b_naRN(int x) { return !hn - hna[x]; }
void er_b_naAG(int x) { skn(hn - hna[x]); }
void er_b_naAE(int x) { skn(hna[3] - hna[x]); }
void er_b_naAD(int x) { skn(hps->n - hna[x]); }
void er_b_naAN(int x) { skn(!hn - hna[x]); }
void er_b_naCG(int x) { if (hn - hna[x] > 3) gi3 = 1; }
void er_b_naCE(int x) { if (hna[3] - hna[x] > 3) gi3 = 1; }
void er_b_naCD(int x) { if (hps->n - hna[x] > 3) gi3 = 1; }
void er_b_naCN(int x) { if (!hn - hna[x] > 3) gi3 = 1; }
void er_b_nbVG(char x) { unsigned long u = hn - hna[x]; }
void er_b_nbVE(char x) { unsigned long u = hna[3] - hna[x]; }
void er_b_nbVD(char x) { unsigned long u = hps->n - hna[x]; }
void er_b_nbVN(char x) { unsigned long u = !hn - hna[x]; }
void er_b_nbGG(char x) { gn = hn - hna[x]; }
void er_b_nbGE(char x) { gn = hna[3] - hna[x]; }
void er_b_nbGD(char x) { gn = hps->n - hna[x]; }
void er_b_nbGN(char x) { gn = !hn - hna[x]; }
void er_b_nbEG(char x) { gna[2] = hn - hna[x]; }
void er_b_nbEE(char x) { gna[2] = hna[3] - hna[x]; }
void er_b_nbED(char x) { gna[2] = hps->n - hna[x]; }
void er_b_nbEN(char x) { gna[2] = !hn - hna[x]; }
void er_b_nbPG(char x) { *gnp = hn - hna[x]; }
void er_b_nbPE(char x) { *gnp = hna[3] - hna[x]; }
void er_b_nbPD(char x) { *gnp = hps->n - hna[x]; }
void er_b_nbPN(char x) { *gnp = !hn - hna[x]; }
void er_b_nbMG(char x) { gs.n = hn - hna[x]; }
void er_b_nbME(char x) { gs.n = hna[3] - hna[x]; }
void er_b_nbMD(char x) { gs.n = hps->n - hna[x]; }
void er_b_nbMN(char x) { gs.n = !hn - hna[x]; }
void er_b_nbQG(char x) { gnp[2] = hn - hna[x]; }
void er_b_nbQE(char x) { gnp[2] = hna[3] - hna[x]; }
void er_b_nbQD(char x) { gnp[2] = hps->n - hna[x]; }
void er_b_nbQN(char x) { gnp[2] = !hn - hna[x]; }
unsigned long er_b_nbRG(char x) { return hn - hna[x]; }
unsigned long er_b_nbRE(char x) { return hna[3] - hna[x]; }
unsigned long er_b_nbRD(char x) { return hps->n - hna[x]; }
unsigned long er_b_nbRN(char x) { return !hn - hna[x]; }
void er_b_nbAG(char x) { skn(hn - hna[x]); }
void er_b_nbAE(char x) { skn(hna[3] - hna[x]); }
void er_b_nbAD(char x) { skn(hps->n - hna[x]); }
void er_b_nbAN(char x) { skn(!hn - hna[x]); }
void er_b_nbCG(char x) { if (hn - hna[x] > 3) gi3 = 1; }
void er_b_nbCE(char x) { if (hna[3] - hna[x] > 3) gi3 = 1; }
void er_b_nbCD(char x) { if (hps->n - hna[x] > 3) gi3 = 1; }
void er_b_nbCN(char x) { if (!hn - hna[x] > 3) gi3 = 1; }
void er_b_nLVG(int x) { int i; unsigned long u = 0; for (i = 0; i < 4; i++) { u = hn - hna[i]; } gi3 = u; }
void er_b_nLVE(int x) { int i; unsigned long u = 0; for (i = 0; i < 4; i++) { u = hna[3] - hna[i]; } gi3 = u; }
void er_b_nLVD(int x) { int i; unsigned long u = 0; for (i = 0; i < 4; i++) { u = hps->n - hna[i]; } gi3 = u; }
void er_b_nLVN(int x) { int i; unsigned long u = 0; for (i = 0; i < 4; i++) { u = !hn - hna[i]; } gi3 = u; }
void er_b_nLGG(int x) { int i; for (i = 0; i < 4; i++) { gn = hn - hna[i]; } }
void er_b_nLGE(int x) { int i; for (i = 0; i < 4; i++) { gn = hna[3] - hna[i]; } }
void er_b_nLGD(int x) { int i; for (i = 0; i < 4; i++) { gn = hps->n - hna[i]; } }
void er_b_nLGN(int x) { int i; for (i = 0; i < 4; i++) { gn = !hn - hna[i]; } }
void er_b_nLEG(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = hn - hna[i]; } }
void er_b_nLEE(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = hna[3] - hna[i]; } }
void er_b_nLED(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = hps->n - hna[i]; } }
void er_b_nLEN(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = !hn - hna[i]; } }
void er_b_nLPG(int x) { int i; for (i = 0; i < 4; i++) { *gnp = hn - hna[i]; } }
void er_b_nLPE(int x) { int i; for (i = 0; i < 4; i++) { *gnp = hna[3] - hna[i]; } }
void er_b_nLPD(int x) { int i; for (i = 0; i < 4; i++) { *gnp = hps->n - hna[i]; } }
void er_b_nLPN(int x) { int i; for (i = 0; i < 4; i++) { *gnp = !hn - hna[i]; } }
void er_b_nLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.n = hn - hna[i]; } }
void er_b_nLME(int x) { int i; for (i = 0; i < 4; i++) { gs.n = hna[3] - hna[i]; } }
void er_b_nLMD(int x) { int i; for (i = 0; i < 4; i++) { gs.n = hps->n - hna[i]; } }
void er_b_nLMN(int x) { int i; for (i = 0; i < 4; i++) { gs.n = !hn - hna[i]; } }
void er_b_nLQG(int x) { int i; for (i = 0; i < 4; i++) { gnp[2] = hn - hna[i]; } }
void er_b_nLQE(int x) { int i; for (i = 0; i < 4; i++) { gnp[2] = hna[3] - hna[i]; } }
void er_b_nLQD(int x) { int i; for (i = 0; i < 4; i++) { gnp[2] = hps->n - hna[i]; } }
void er_b_nLQN(int x) { int i; for (i = 0; i < 4; i++) { gnp[2] = !hn - hna[i]; } }
void er_b_nLAG(int x) { int i; for (i = 0; i < 4; i++) { skn(hn - hna[i]); } }
void er_b_nLAE(int x) { int i; for (i = 0; i < 4; i++) { skn(hna[3] - hna[i]); } }
void er_b_nLAD(int x) { int i; for (i = 0; i < 4; i++) { skn(hps->n - hna[i]); } }
void er_b_nLAN(int x) { int i; for (i = 0; i < 4; i++) { skn(!hn - hna[i]); } }
void er_b_nLCG(int x) { int i; for (i = 0; i < 4; i++) { if (hn - hna[i] > 3) gi3 = 1; } }
void er_b_nLCE(int x) { int i; for (i = 0; i < 4; i++) { if (hna[3] - hna[i] > 3) gi3 = 1; } }
void er_b_nLCD(int x) { int i; for (i = 0; i < 4; i++) { if (hps->n - hna[i] > 3) gi3 = 1; } }
void er_b_nLCN(int x) { int i; for (i = 0; i < 4; i++) { if (!hn - hna[i] > 3) gi3 = 1; } }

void er_c_cbGp(char x) { gc = hc + hca[x]; }
void er_c_cbGs(char x) { gc = hc - hca[x]; }
void er_c_cbGo(char x) { gc = hc | hca[x]; }
void er_c_cbGa(char x) { gc = hc & hca[x]; }
void er_c_cbGx(char x) { gc = hc ^ hca[x]; }
void er_c_cbGm(char x) { gc = hc * hca[x]; }
void er_c_cbCp(char x) { gc = (hc - 3) + hca[x]; }
void er_c_cbCs(char x) { gc = (hc - 3) - hca[x]; }
void er_c_cbCo(char x) { gc = (hc - 3) | hca[x]; }
void er_c_cbCa(char x) { gc = (hc - 3) & hca[x]; }
void er_c_cbCx(char x) { gc = (hc - 3) ^ hca[x]; }
void er_c_cbCm(char x) { gc = (hc - 3) * hca[x]; }
void er_c_cfGp(int x) { int t = gi; gc = hc + hca[t]; }
void er_c_cfGs(int x) { int t = gi; gc = hc - hca[t]; }
void er_c_cfGo(int x) { int t = gi; gc = hc | hca[t]; }
void er_c_cfGa(int x) { int t = gi; gc = hc & hca[t]; }
void er_c_cfGx(int x) { int t = gi; gc = hc ^ hca[t]; }
void er_c_cfGm(int x) { int t = gi; gc = hc * hca[t]; }
void er_c_cfCp(int x) { int t = gi; gc = (hc - 3) + hca[t]; }
void er_c_cfCs(int x) { int t = gi; gc = (hc - 3) - hca[t]; }
void er_c_cfCo(int x) { int t = gi; gc = (hc - 3) | hca[t]; }
void er_c_cfCa(int x) { int t = gi; gc = (hc - 3) & hca[t]; }
void er_c_cfCx(int x) { int t = gi; gc = (hc - 3) ^ hca[t]; }
void er_c_cfCm(int x) { int t = gi; gc = (hc - 3) * hca[t]; }
void er_c_cLGp(int x) { int i; for (i = 0; i < 4; i++) { gc = hc + hca[i]; } }
void er_c_cLGs(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - hca[i]; } }
void er_c_cLGo(int x) { int i; for (i = 0; i < 4; i++) { gc = hc | hca[i]; } }
void er_c_cLGa(int x) { int i; for (i = 0; i < 4; i++) { gc = hc & hca[i]; } }
void er_c_cLGx(int x) { int i; for (i = 0; i < 4; i++) { gc = hc ^ hca[i]; } }
void er_c_cLGm(int x) { int i; for (i = 0; i < 4; i++) { gc = hc * hca[i]; } }
void er_c_cLCp(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) + hca[i]; } }
void er_c_cLCs(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) - hca[i]; } }
void er_c_cLCo(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) | hca[i]; } }
void er_c_cLCa(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) & hca[i]; } }
void er_c_cLCx(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) ^ hca[i]; } }
void er_c_cLCm(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc - 3) * hca[i]; } }
void er_c_ibGp(char x) { gi = hi + hia[x]; }
void er_c_ibGs(char x) { gi = hi - hia[x]; }
void er_c_ibGo(char x) { gi = hi | hia[x]; }
void er_c_ibGa(char x) { gi = hi & hia[x]; }
void er_c_ibGx(char x) { gi = hi ^ hia[x]; }
void er_c_ibGm(char x) { gi = hi * hia[x]; }
void er_c_ibCp(char x) { gi = (hi - 3) + hia[x]; }
void er_c_ibCs(char x) { gi = (hi - 3) - hia[x]; }
void er_c_ibCo(char x) { gi = (hi - 3) | hia[x]; }
void er_c_ibCa(char x) { gi = (hi - 3) & hia[x]; }
void er_c_ibCx(char x) { gi = (hi - 3) ^ hia[x]; }
void er_c_ibCm(char x) { gi = (hi - 3) * hia[x]; }
void er_c_ifGp(int x) { int t = gi; gi = hi + hia[t]; }
void er_c_ifGs(int x) { int t = gi; gi = hi - hia[t]; }
void er_c_ifGo(int x) { int t = gi; gi = hi | hia[t]; }
void er_c_ifGa(int x) { int t = gi; gi = hi & hia[t]; }
void er_c_ifGx(int x) { int t = gi; gi = hi ^ hia[t]; }
void er_c_ifGm(int x) { int t = gi; gi = hi * hia[t]; }
void er_c_ifCp(int x) { int t = gi; gi = (hi - 3) + hia[t]; }
void er_c_ifCs(int x) { int t = gi; gi = (hi - 3) - hia[t]; }
void er_c_ifCo(int x) { int t = gi; gi = (hi - 3) | hia[t]; }
void er_c_ifCa(int x) { int t = gi; gi = (hi - 3) & hia[t]; }
void er_c_ifCx(int x) { int t = gi; gi = (hi - 3) ^ hia[t]; }
void er_c_ifCm(int x) { int t = gi; gi = (hi - 3) * hia[t]; }
void er_c_iLGp(int x) { int i; for (i = 0; i < 4; i++) { gi = hi + hia[i]; } }
void er_c_iLGs(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hia[i]; } }
void er_c_iLGo(int x) { int i; for (i = 0; i < 4; i++) { gi = hi | hia[i]; } }
void er_c_iLGa(int x) { int i; for (i = 0; i < 4; i++) { gi = hi & hia[i]; } }
void er_c_iLGx(int x) { int i; for (i = 0; i < 4; i++) { gi = hi ^ hia[i]; } }
void er_c_iLGm(int x) { int i; for (i = 0; i < 4; i++) { gi = hi * hia[i]; } }
void er_c_iLCp(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) + hia[i]; } }
void er_c_iLCs(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) - hia[i]; } }
void er_c_iLCo(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) | hia[i]; } }
void er_c_iLCa(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) & hia[i]; } }
void er_c_iLCx(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) ^ hia[i]; } }
void er_c_iLCm(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi - 3) * hia[i]; } }
void er_c_nbGp(char x) { gn = hn + hna[x]; }
void er_c_nbGs(char x) { gn = hn - hna[x]; }
void er_c_nbGo(char x) { gn = hn | hna[x]; }
void er_c_nbGa(char x) { gn = hn & hna[x]; }
void er_c_nbGx(char x) { gn = hn ^ hna[x]; }
void er_c_nbGm(char x) { gn = hn * hna[x]; }
void er_c_nbCp(char x) { gn = (hn - 3) + hna[x]; }
void er_c_nbCs(char x) { gn = (hn - 3) - hna[x]; }
void er_c_nbCo(char x) { gn = (hn - 3) | hna[x]; }
void er_c_nbCa(char x) { gn = (hn - 3) & hna[x]; }
void er_c_nbCx(char x) { gn = (hn - 3) ^ hna[x]; }
void er_c_nbCm(char x) { gn = (hn - 3) * hna[x]; }
void er_c_nfGp(int x) { int t = gi; gn = hn + hna[t]; }
void er_c_nfGs(int x) { int t = gi; gn = hn - hna[t]; }
void er_c_nfGo(int x) { int t = gi; gn = hn | hna[t]; }
void er_c_nfGa(int x) { int t = gi; gn = hn & hna[t]; }
void er_c_nfGx(int x) { int t = gi; gn = hn ^ hna[t]; }
void er_c_nfGm(int x) { int t = gi; gn = hn * hna[t]; }
void er_c_nfCp(int x) { int t = gi; gn = (hn - 3) + hna[t]; }
void er_c_nfCs(int x) { int t = gi; gn = (hn - 3) - hna[t]; }
void er_c_nfCo(int x) { int t = gi; gn = (hn - 3) | hna[t]; }
void er_c_nfCa(int x) { int t = gi; gn = (hn - 3) & hna[t]; }
void er_c_nfCx(int x) { int t = gi; gn = (hn - 3) ^ hna[t]; }
void er_c_nfCm(int x) { int t = gi; gn = (hn - 3) * hna[t]; }
void er_c_nLGp(int x) { int i; for (i = 0; i < 4; i++) { gn = hn + hna[i]; } }
void er_c_nLGs(int x) { int i; for (i = 0; i < 4; i++) { gn = hn - hna[i]; } }
void er_c_nLGo(int x) { int i; for (i = 0; i < 4; i++) { gn = hn | hna[i]; } }
void er_c_nLGa(int x) { int i; for (i = 0; i < 4; i++) { gn = hn & hna[i]; } }
void er_c_nLGx(int x) { int i; for (i = 0; i < 4; i++) { gn = hn ^ hna[i]; } }
void er_c_nLGm(int x) { int i; for (i = 0; i < 4; i++) { gn = hn * hna[i]; } }
void er_c_nLCp(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) + hna[i]; } }
void er_c_nLCs(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) - hna[i]; } }
void er_c_nLCo(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) | hna[i]; } }
void er_c_nLCa(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) & hna[i]; } }
void er_c_nLCx(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) ^ hna[i]; } }
void er_c_nLCm(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn - 3) * hna[i]; } }

void er_d_s1_ia(int x) { gi = (hi + hia[x]) * hia[x]; }
void er_d_s2_ia(int x) { gi = hi - (vi - hia[x]); }
void er_d_s3_ia(int x) { int *q = gip; gi = *q - q[x]; }
void er_d_s1_ib(char x) { gi = (hi + hia[x]) * hia[x]; }
void er_d_s2_ib(char x) { gi = hi - (vi - hia[x]); }
void er_d_s3_ib(char x) { int *q = gip; gi = *q - q[x]; }
void er_d_s1_iL(int x) { int i; for (i = 0; i < 4; i++) { gi = (hi + hia[i]) * hia[i]; } }
void er_d_s2_iL(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - (vi - hia[i]); } }
void er_d_s3_iL(int x) { int i; int *q = gip; for (i = 0; i < 4; i++) { gi = *q - q[i]; } }
void er_d_s1_if(int x) { int t = gi; gi = (hi + hia[t]) * hia[t]; }
void er_d_s2_if(int x) { int t = gi; gi = hi - (vi - hia[t]); }
void er_d_s3_if(int x) { int t = gi; int *q = gip; gi = *q - q[t]; }
void er_d_s1_ca(int x) { gc = (hc + hca[x]) * hca[x]; }
void er_d_s2_ca(int x) { gc = hc - (vc - hca[x]); }
void er_d_s3_ca(int x) { char *q = gcp; gc = *q - q[x]; }
void er_d_s1_cb(char x) { gc = (hc + hca[x]) * hca[x]; }
void er_d_s2_cb(char x) { gc = hc - (vc - hca[x]); }
void er_d_s3_cb(char x) { char *q = gcp; gc = *q - q[x]; }
void er_d_s1_cL(int x) { int i; for (i = 0; i < 4; i++) { gc = (hc + hca[i]) * hca[i]; } }
void er_d_s2_cL(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - (vc - hca[i]); } }
void er_d_s3_cL(int x) { int i; char *q = gcp; for (i = 0; i < 4; i++) { gc = *q - q[i]; } }
void er_d_s1_cf(int x) { int t = gi; gc = (hc + hca[t]) * hca[t]; }
void er_d_s2_cf(int x) { int t = gi; gc = hc - (vc - hca[t]); }
void er_d_s3_cf(int x) { int t = gi; char *q = gcp; gc = *q - q[t]; }
void er_d_s1_na(int x) { gn = (hn + hna[x]) * hna[x]; }
void er_d_s2_na(int x) { gn = hn - (vn - hna[x]); }
void er_d_s3_na(int x) { unsigned long *q = gnp; gn = *q - q[x]; }
void er_d_s1_nb(char x) { gn = (hn + hna[x]) * hna[x]; }
void er_d_s2_nb(char x) { gn = hn - (vn - hna[x]); }
void er_d_s3_nb(char x) { unsigned long *q = gnp; gn = *q - q[x]; }
void er_d_s1_nL(int x) { int i; for (i = 0; i < 4; i++) { gn = (hn + hna[i]) * hna[i]; } }
void er_d_s2_nL(int x) { int i; for (i = 0; i < 4; i++) { gn = hn - (vn - hna[i]); } }
void er_d_s3_nL(int x) { int i; unsigned long *q = gnp; for (i = 0; i < 4; i++) { gn = *q - q[i]; } }
void er_d_s1_nf(int x) { int t = gi; gn = (hn + hna[t]) * hna[t]; }
void er_d_s2_nf(int x) { int t = gi; gn = hn - (vn - hna[t]); }
void er_d_s3_nf(int x) { int t = gi; unsigned long *q = gnp; gn = *q - q[t]; }
void er_k_ucsa(int x) { gc = (char)hc - (char)hua[x]; }
void er_k_ucsb(char x) { gc = (char)hc - (char)hua[x]; }
void er_k_ucsL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc - (char)hua[i]; } }
void er_k_ucoa(int x) { gc = (char)hc | (char)hua[x]; }
void er_k_ucob(char x) { gc = (char)hc | (char)hua[x]; }
void er_k_ucoL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc | (char)hua[i]; } }
void er_k_unsa(int x) { gn = (unsigned long)hn - (unsigned long)hua[x]; }
void er_k_unsb(char x) { gn = (unsigned long)hn - (unsigned long)hua[x]; }
void er_k_unsL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn - (unsigned long)hua[i]; } }
void er_k_unoa(int x) { gn = (unsigned long)hn | (unsigned long)hua[x]; }
void er_k_unob(char x) { gn = (unsigned long)hn | (unsigned long)hua[x]; }
void er_k_unoL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn | (unsigned long)hua[i]; } }
void er_k_icsa(int x) { gc = (char)hc - (char)hia[x]; }
void er_k_icsb(char x) { gc = (char)hc - (char)hia[x]; }
void er_k_icsL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc - (char)hia[i]; } }
void er_k_icoa(int x) { gc = (char)hc | (char)hia[x]; }
void er_k_icob(char x) { gc = (char)hc | (char)hia[x]; }
void er_k_icoL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc | (char)hia[i]; } }
void er_k_insa(int x) { gn = (unsigned long)hn - (unsigned long)hia[x]; }
void er_k_insb(char x) { gn = (unsigned long)hn - (unsigned long)hia[x]; }
void er_k_insL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn - (unsigned long)hia[i]; } }
void er_k_inoa(int x) { gn = (unsigned long)hn | (unsigned long)hia[x]; }
void er_k_inob(char x) { gn = (unsigned long)hn | (unsigned long)hia[x]; }
void er_k_inoL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn | (unsigned long)hia[i]; } }
void er_k_wcsa(int x) { gc = (char)hc - (char)hwa[x]; }
void er_k_wcsb(char x) { gc = (char)hc - (char)hwa[x]; }
void er_k_wcsL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc - (char)hwa[i]; } }
void er_k_wcoa(int x) { gc = (char)hc | (char)hwa[x]; }
void er_k_wcob(char x) { gc = (char)hc | (char)hwa[x]; }
void er_k_wcoL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc | (char)hwa[i]; } }
void er_k_wnsa(int x) { gn = (unsigned long)hn - (unsigned long)hwa[x]; }
void er_k_wnsb(char x) { gn = (unsigned long)hn - (unsigned long)hwa[x]; }
void er_k_wnsL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn - (unsigned long)hwa[i]; } }
void er_k_wnoa(int x) { gn = (unsigned long)hn | (unsigned long)hwa[x]; }
void er_k_wnob(char x) { gn = (unsigned long)hn | (unsigned long)hwa[x]; }
void er_k_wnoL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn | (unsigned long)hwa[i]; } }
void er_k_lcsa(int x) { gc = (char)hc - (char)hla[x]; }
void er_k_lcsb(char x) { gc = (char)hc - (char)hla[x]; }
void er_k_lcsL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc - (char)hla[i]; } }
void er_k_lcoa(int x) { gc = (char)hc | (char)hla[x]; }
void er_k_lcob(char x) { gc = (char)hc | (char)hla[x]; }
void er_k_lcoL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc | (char)hla[i]; } }
void er_k_lnsa(int x) { gn = (unsigned long)hn - (unsigned long)hla[x]; }
void er_k_lnsb(char x) { gn = (unsigned long)hn - (unsigned long)hla[x]; }
void er_k_lnsL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn - (unsigned long)hla[i]; } }
void er_k_lnoa(int x) { gn = (unsigned long)hn | (unsigned long)hla[x]; }
void er_k_lnob(char x) { gn = (unsigned long)hn | (unsigned long)hla[x]; }
void er_k_lnoL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn | (unsigned long)hla[i]; } }
void er_k_ncsa(int x) { gc = (char)hc - (char)hna[x]; }
void er_k_ncsb(char x) { gc = (char)hc - (char)hna[x]; }
void er_k_ncsL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc - (char)hna[i]; } }
void er_k_ncoa(int x) { gc = (char)hc | (char)hna[x]; }
void er_k_ncob(char x) { gc = (char)hc | (char)hna[x]; }
void er_k_ncoL(int x) { int i; for (i = 0; i < 4; i++) { gc = (char)hc | (char)hna[i]; } }
void er_k_nnsa(int x) { gn = (unsigned long)hn - (unsigned long)hna[x]; }
void er_k_nnsb(char x) { gn = (unsigned long)hn - (unsigned long)hna[x]; }
void er_k_nnsL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn - (unsigned long)hna[i]; } }
void er_k_nnoa(int x) { gn = (unsigned long)hn | (unsigned long)hna[x]; }
void er_k_nnob(char x) { gn = (unsigned long)hn | (unsigned long)hna[x]; }
void er_k_nnoL(int x) { int i; for (i = 0; i < 4; i++) { gn = (unsigned long)hn | (unsigned long)hna[i]; } }

void er_e_iAaK(int x) { gi = 7 - hia[x]; }
void er_e_iAaG(int x) { gi = hi - hia[x]; }
void er_e_iAbK(char x) { gi = 7 - hia[x]; }
void er_e_iAbG(char x) { gi = hi - hia[x]; }
void er_e_iALK(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - hia[i]; } }
void er_e_iALG(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hia[i]; } }
void er_e_iMaK(int x) { gi = 7 - hs.ia[x]; }
void er_e_iMaG(int x) { gi = hi - hs.ia[x]; }
void er_e_iMbK(char x) { gi = 7 - hs.ia[x]; }
void er_e_iMbG(char x) { gi = hi - hs.ia[x]; }
void er_e_iMLK(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - hs.ia[i]; } }
void er_e_iMLG(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hs.ia[i]; } }
void er_e_iDaK(int x) { gi = 7 - hps->ia[x]; }
void er_e_iDaG(int x) { gi = hi - hps->ia[x]; }
void er_e_iDbK(char x) { gi = 7 - hps->ia[x]; }
void er_e_iDbG(char x) { gi = hi - hps->ia[x]; }
void er_e_iDLK(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - hps->ia[i]; } }
void er_e_iDLG(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - hps->ia[i]; } }
void er_e_iQaK(int x) { gi = 7 - gip[x]; }
void er_e_iQaG(int x) { gi = hi - gip[x]; }
void er_e_iQbK(char x) { gi = 7 - gip[x]; }
void er_e_iQbG(char x) { gi = hi - gip[x]; }
void er_e_iQLK(int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - gip[i]; } }
void er_e_iQLG(int x) { int i; for (i = 0; i < 4; i++) { gi = hi - gip[i]; } }
void er_e_iRaK(int *p, int x) { gi = 7 - p[x]; }
void er_e_iRaG(int *p, int x) { gi = hi - p[x]; }
void er_e_iRbK(int *p, char x) { gi = 7 - p[x]; }
void er_e_iRbG(int *p, char x) { gi = hi - p[x]; }
void er_e_iRLK(int *p, int x) { int i; for (i = 0; i < 4; i++) { gi = 7 - p[i]; } }
void er_e_iRLG(int *p, int x) { int i; for (i = 0; i < 4; i++) { gi = hi - p[i]; } }
void er_e_cAaK(int x) { gc = 7 - hca[x]; }
void er_e_cAaG(int x) { gc = hc - hca[x]; }
void er_e_cAbK(char x) { gc = 7 - hca[x]; }
void er_e_cAbG(char x) { gc = hc - hca[x]; }
void er_e_cALK(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - hca[i]; } }
void er_e_cALG(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - hca[i]; } }
void er_e_cMaK(int x) { gc = 7 - hs.ca[x]; }
void er_e_cMaG(int x) { gc = hc - hs.ca[x]; }
void er_e_cMbK(char x) { gc = 7 - hs.ca[x]; }
void er_e_cMbG(char x) { gc = hc - hs.ca[x]; }
void er_e_cMLK(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - hs.ca[i]; } }
void er_e_cMLG(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - hs.ca[i]; } }
void er_e_cDaK(int x) { gc = 7 - hps->ca[x]; }
void er_e_cDaG(int x) { gc = hc - hps->ca[x]; }
void er_e_cDbK(char x) { gc = 7 - hps->ca[x]; }
void er_e_cDbG(char x) { gc = hc - hps->ca[x]; }
void er_e_cDLK(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - hps->ca[i]; } }
void er_e_cDLG(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - hps->ca[i]; } }
void er_e_cQaK(int x) { gc = 7 - gcp[x]; }
void er_e_cQaG(int x) { gc = hc - gcp[x]; }
void er_e_cQbK(char x) { gc = 7 - gcp[x]; }
void er_e_cQbG(char x) { gc = hc - gcp[x]; }
void er_e_cQLK(int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - gcp[i]; } }
void er_e_cQLG(int x) { int i; for (i = 0; i < 4; i++) { gc = hc - gcp[i]; } }
void er_e_cRaK(char *p, int x) { gc = 7 - p[x]; }
void er_e_cRaG(char *p, int x) { gc = hc - p[x]; }
void er_e_cRbK(char *p, char x) { gc = 7 - p[x]; }
void er_e_cRbG(char *p, char x) { gc = hc - p[x]; }
void er_e_cRLK(char *p, int x) { int i; for (i = 0; i < 4; i++) { gc = 7 - p[i]; } }
void er_e_cRLG(char *p, int x) { int i; for (i = 0; i < 4; i++) { gc = hc - p[i]; } }

void bc_a_caK(int x) { gc = (hca[x] = 7); }
void bc_a_caG(int x) { gc = (hca[x] = vc); }
void bc_a_caS(int x) { gc = (hca[x] = hca[1]); }
void bc_a_caN(int x) { gc = (hca[x] = !gi); }
void bc_a_caB(int x) { gc = (hca[x] = (wca[3] + vc) % 16); }
void bc_a_cbK(char x) { gc = (hca[x] = 7); }
void bc_a_cbG(char x) { gc = (hca[x] = vc); }
void bc_a_cbS(char x) { gc = (hca[x] = hca[1]); }
void bc_a_cbN(char x) { gc = (hca[x] = !gi); }
void bc_a_cbB(char x) { gc = (hca[x] = (wca[3] + vc) % 16); }
void bc_a_ccK(unsigned char x) { gc = (hca[x] = 7); }
void bc_a_ccG(unsigned char x) { gc = (hca[x] = vc); }
void bc_a_ccS(unsigned char x) { gc = (hca[x] = hca[1]); }
void bc_a_ccN(unsigned char x) { gc = (hca[x] = !gi); }
void bc_a_ccB(unsigned char x) { gc = (hca[x] = (wca[3] + vc) % 16); }
void bc_a_cLK(int x) { int i; for (i = 0; i < 4; i++) { gc = (hca[i] = 7); } }
void bc_a_cLG(int x) { int i; for (i = 0; i < 4; i++) { gc = (hca[i] = vc); } }
void bc_a_cLS(int x) { int i; for (i = 0; i < 4; i++) { gc = (hca[i] = hca[1]); } }
void bc_a_cLN(int x) { int i; for (i = 0; i < 4; i++) { gc = (hca[i] = !gi); } }
void bc_a_cLB(int x) { int i; for (i = 0; i < 4; i++) { gc = (hca[i] = (wca[3] + vc) % 16); } }
void bc_a_cfK(int x) { int t = gi; gc = (hca[t] = 7); }
void bc_a_cfG(int x) { int t = gi; gc = (hca[t] = vc); }
void bc_a_cfS(int x) { int t = gi; gc = (hca[t] = hca[1]); }
void bc_a_cfN(int x) { int t = gi; gc = (hca[t] = !gi); }
void bc_a_cfB(int x) { int t = gi; gc = (hca[t] = (wca[3] + vc) % 16); }
void bc_a_uaK(int x) { gu = (hua[x] = 7); }
void bc_a_uaG(int x) { gu = (hua[x] = vu); }
void bc_a_uaS(int x) { gu = (hua[x] = hua[1]); }
void bc_a_uaN(int x) { gu = (hua[x] = !gi); }
void bc_a_uaB(int x) { gu = (hua[x] = (wua[3] + vu) % 16); }
void bc_a_ubK(char x) { gu = (hua[x] = 7); }
void bc_a_ubG(char x) { gu = (hua[x] = vu); }
void bc_a_ubS(char x) { gu = (hua[x] = hua[1]); }
void bc_a_ubN(char x) { gu = (hua[x] = !gi); }
void bc_a_ubB(char x) { gu = (hua[x] = (wua[3] + vu) % 16); }
void bc_a_ucK(unsigned char x) { gu = (hua[x] = 7); }
void bc_a_ucG(unsigned char x) { gu = (hua[x] = vu); }
void bc_a_ucS(unsigned char x) { gu = (hua[x] = hua[1]); }
void bc_a_ucN(unsigned char x) { gu = (hua[x] = !gi); }
void bc_a_ucB(unsigned char x) { gu = (hua[x] = (wua[3] + vu) % 16); }
void bc_a_uLK(int x) { int i; for (i = 0; i < 4; i++) { gu = (hua[i] = 7); } }
void bc_a_uLG(int x) { int i; for (i = 0; i < 4; i++) { gu = (hua[i] = vu); } }
void bc_a_uLS(int x) { int i; for (i = 0; i < 4; i++) { gu = (hua[i] = hua[1]); } }
void bc_a_uLN(int x) { int i; for (i = 0; i < 4; i++) { gu = (hua[i] = !gi); } }
void bc_a_uLB(int x) { int i; for (i = 0; i < 4; i++) { gu = (hua[i] = (wua[3] + vu) % 16); } }
void bc_a_ufK(int x) { int t = gi; gu = (hua[t] = 7); }
void bc_a_ufG(int x) { int t = gi; gu = (hua[t] = vu); }
void bc_a_ufS(int x) { int t = gi; gu = (hua[t] = hua[1]); }
void bc_a_ufN(int x) { int t = gi; gu = (hua[t] = !gi); }
void bc_a_ufB(int x) { int t = gi; gu = (hua[t] = (wua[3] + vu) % 16); }
void bc_a_iaK(int x) { gi = (hia[x] = 7); }
void bc_a_iaG(int x) { gi = (hia[x] = vi); }
void bc_a_iaS(int x) { gi = (hia[x] = hia[1]); }
void bc_a_iaN(int x) { gi = (hia[x] = !gi); }
void bc_a_iaB(int x) { gi = (hia[x] = (wia[3] + vi) % 16); }
void bc_a_ibK(char x) { gi = (hia[x] = 7); }
void bc_a_ibG(char x) { gi = (hia[x] = vi); }
void bc_a_ibS(char x) { gi = (hia[x] = hia[1]); }
void bc_a_ibN(char x) { gi = (hia[x] = !gi); }
void bc_a_ibB(char x) { gi = (hia[x] = (wia[3] + vi) % 16); }
void bc_a_icK(unsigned char x) { gi = (hia[x] = 7); }
void bc_a_icG(unsigned char x) { gi = (hia[x] = vi); }
void bc_a_icS(unsigned char x) { gi = (hia[x] = hia[1]); }
void bc_a_icN(unsigned char x) { gi = (hia[x] = !gi); }
void bc_a_icB(unsigned char x) { gi = (hia[x] = (wia[3] + vi) % 16); }
void bc_a_iLK(int x) { int i; for (i = 0; i < 4; i++) { gi = (hia[i] = 7); } }
void bc_a_iLG(int x) { int i; for (i = 0; i < 4; i++) { gi = (hia[i] = vi); } }
void bc_a_iLS(int x) { int i; for (i = 0; i < 4; i++) { gi = (hia[i] = hia[1]); } }
void bc_a_iLN(int x) { int i; for (i = 0; i < 4; i++) { gi = (hia[i] = !gi); } }
void bc_a_iLB(int x) { int i; for (i = 0; i < 4; i++) { gi = (hia[i] = (wia[3] + vi) % 16); } }
void bc_a_ifK(int x) { int t = gi; gi = (hia[t] = 7); }
void bc_a_ifG(int x) { int t = gi; gi = (hia[t] = vi); }
void bc_a_ifS(int x) { int t = gi; gi = (hia[t] = hia[1]); }
void bc_a_ifN(int x) { int t = gi; gi = (hia[t] = !gi); }
void bc_a_ifB(int x) { int t = gi; gi = (hia[t] = (wia[3] + vi) % 16); }
void bc_a_waK(int x) { gw = (hwa[x] = 7); }
void bc_a_waG(int x) { gw = (hwa[x] = vw); }
void bc_a_waS(int x) { gw = (hwa[x] = hwa[1]); }
void bc_a_waN(int x) { gw = (hwa[x] = !gi); }
void bc_a_waB(int x) { gw = (hwa[x] = (wwa[3] + vw) % 16); }
void bc_a_wbK(char x) { gw = (hwa[x] = 7); }
void bc_a_wbG(char x) { gw = (hwa[x] = vw); }
void bc_a_wbS(char x) { gw = (hwa[x] = hwa[1]); }
void bc_a_wbN(char x) { gw = (hwa[x] = !gi); }
void bc_a_wbB(char x) { gw = (hwa[x] = (wwa[3] + vw) % 16); }
void bc_a_wcK(unsigned char x) { gw = (hwa[x] = 7); }
void bc_a_wcG(unsigned char x) { gw = (hwa[x] = vw); }
void bc_a_wcS(unsigned char x) { gw = (hwa[x] = hwa[1]); }
void bc_a_wcN(unsigned char x) { gw = (hwa[x] = !gi); }
void bc_a_wcB(unsigned char x) { gw = (hwa[x] = (wwa[3] + vw) % 16); }
void bc_a_wLK(int x) { int i; for (i = 0; i < 4; i++) { gw = (hwa[i] = 7); } }
void bc_a_wLG(int x) { int i; for (i = 0; i < 4; i++) { gw = (hwa[i] = vw); } }
void bc_a_wLS(int x) { int i; for (i = 0; i < 4; i++) { gw = (hwa[i] = hwa[1]); } }
void bc_a_wLN(int x) { int i; for (i = 0; i < 4; i++) { gw = (hwa[i] = !gi); } }
void bc_a_wLB(int x) { int i; for (i = 0; i < 4; i++) { gw = (hwa[i] = (wwa[3] + vw) % 16); } }
void bc_a_wfK(int x) { int t = gi; gw = (hwa[t] = 7); }
void bc_a_wfG(int x) { int t = gi; gw = (hwa[t] = vw); }
void bc_a_wfS(int x) { int t = gi; gw = (hwa[t] = hwa[1]); }
void bc_a_wfN(int x) { int t = gi; gw = (hwa[t] = !gi); }
void bc_a_wfB(int x) { int t = gi; gw = (hwa[t] = (wwa[3] + vw) % 16); }
void bc_a_laK(int x) { gl = (hla[x] = 7); }
void bc_a_laG(int x) { gl = (hla[x] = vl); }
void bc_a_laS(int x) { gl = (hla[x] = hla[1]); }
void bc_a_laN(int x) { gl = (hla[x] = !gi); }
void bc_a_laB(int x) { gl = (hla[x] = (wla[3] + vl) % 16); }
void bc_a_lbK(char x) { gl = (hla[x] = 7); }
void bc_a_lbG(char x) { gl = (hla[x] = vl); }
void bc_a_lbS(char x) { gl = (hla[x] = hla[1]); }
void bc_a_lbN(char x) { gl = (hla[x] = !gi); }
void bc_a_lbB(char x) { gl = (hla[x] = (wla[3] + vl) % 16); }
void bc_a_lcK(unsigned char x) { gl = (hla[x] = 7); }
void bc_a_lcG(unsigned char x) { gl = (hla[x] = vl); }
void bc_a_lcS(unsigned char x) { gl = (hla[x] = hla[1]); }
void bc_a_lcN(unsigned char x) { gl = (hla[x] = !gi); }
void bc_a_lcB(unsigned char x) { gl = (hla[x] = (wla[3] + vl) % 16); }
void bc_a_lLK(int x) { int i; for (i = 0; i < 4; i++) { gl = (hla[i] = 7); } }
void bc_a_lLG(int x) { int i; for (i = 0; i < 4; i++) { gl = (hla[i] = vl); } }
void bc_a_lLS(int x) { int i; for (i = 0; i < 4; i++) { gl = (hla[i] = hla[1]); } }
void bc_a_lLN(int x) { int i; for (i = 0; i < 4; i++) { gl = (hla[i] = !gi); } }
void bc_a_lLB(int x) { int i; for (i = 0; i < 4; i++) { gl = (hla[i] = (wla[3] + vl) % 16); } }
void bc_a_lfK(int x) { int t = gi; gl = (hla[t] = 7); }
void bc_a_lfG(int x) { int t = gi; gl = (hla[t] = vl); }
void bc_a_lfS(int x) { int t = gi; gl = (hla[t] = hla[1]); }
void bc_a_lfN(int x) { int t = gi; gl = (hla[t] = !gi); }
void bc_a_lfB(int x) { int t = gi; gl = (hla[t] = (wla[3] + vl) % 16); }
void bc_a_naK(int x) { gn = (hna[x] = 7); }
void bc_a_naG(int x) { gn = (hna[x] = vn); }
void bc_a_naS(int x) { gn = (hna[x] = hna[1]); }
void bc_a_naN(int x) { gn = (hna[x] = !gi); }
void bc_a_naB(int x) { gn = (hna[x] = (wna[3] + vn) % 16); }
void bc_a_nbK(char x) { gn = (hna[x] = 7); }
void bc_a_nbG(char x) { gn = (hna[x] = vn); }
void bc_a_nbS(char x) { gn = (hna[x] = hna[1]); }
void bc_a_nbN(char x) { gn = (hna[x] = !gi); }
void bc_a_nbB(char x) { gn = (hna[x] = (wna[3] + vn) % 16); }
void bc_a_ncK(unsigned char x) { gn = (hna[x] = 7); }
void bc_a_ncG(unsigned char x) { gn = (hna[x] = vn); }
void bc_a_ncS(unsigned char x) { gn = (hna[x] = hna[1]); }
void bc_a_ncN(unsigned char x) { gn = (hna[x] = !gi); }
void bc_a_ncB(unsigned char x) { gn = (hna[x] = (wna[3] + vn) % 16); }
void bc_a_nLK(int x) { int i; for (i = 0; i < 4; i++) { gn = (hna[i] = 7); } }
void bc_a_nLG(int x) { int i; for (i = 0; i < 4; i++) { gn = (hna[i] = vn); } }
void bc_a_nLS(int x) { int i; for (i = 0; i < 4; i++) { gn = (hna[i] = hna[1]); } }
void bc_a_nLN(int x) { int i; for (i = 0; i < 4; i++) { gn = (hna[i] = !gi); } }
void bc_a_nLB(int x) { int i; for (i = 0; i < 4; i++) { gn = (hna[i] = (wna[3] + vn) % 16); } }
void bc_a_nfK(int x) { int t = gi; gn = (hna[t] = 7); }
void bc_a_nfG(int x) { int t = gi; gn = (hna[t] = vn); }
void bc_a_nfS(int x) { int t = gi; gn = (hna[t] = hna[1]); }
void bc_a_nfN(int x) { int t = gi; gn = (hna[t] = !gi); }
void bc_a_nfB(int x) { int t = gi; gn = (hna[t] = (wna[3] + vn) % 16); }

void bc_b_caMK(int x) { gs.c = (hca[x] = 7); }
void bc_b_caMG(int x) { gs.c = (hca[x] = vc); }
void bc_b_caMS(int x) { gs.c = (hca[x] = hca[1]); }
void bc_b_caPK(int x) { *gcp = (hca[x] = 7); }
void bc_b_caPG(int x) { *gcp = (hca[x] = vc); }
void bc_b_caPS(int x) { *gcp = (hca[x] = hca[1]); }
void bc_b_caEK(int x) { gca[2] = (hca[x] = 7); }
void bc_b_caEG(int x) { gca[2] = (hca[x] = vc); }
void bc_b_caES(int x) { gca[2] = (hca[x] = hca[1]); }
void bc_b_caDK(int x) { gps->c = (hca[x] = 7); }
void bc_b_caDG(int x) { gps->c = (hca[x] = vc); }
void bc_b_caDS(int x) { gps->c = (hca[x] = hca[1]); }
void bc_b_cbMK(char x) { gs.c = (hca[x] = 7); }
void bc_b_cbMG(char x) { gs.c = (hca[x] = vc); }
void bc_b_cbMS(char x) { gs.c = (hca[x] = hca[1]); }
void bc_b_cbPK(char x) { *gcp = (hca[x] = 7); }
void bc_b_cbPG(char x) { *gcp = (hca[x] = vc); }
void bc_b_cbPS(char x) { *gcp = (hca[x] = hca[1]); }
void bc_b_cbEK(char x) { gca[2] = (hca[x] = 7); }
void bc_b_cbEG(char x) { gca[2] = (hca[x] = vc); }
void bc_b_cbES(char x) { gca[2] = (hca[x] = hca[1]); }
void bc_b_cbDK(char x) { gps->c = (hca[x] = 7); }
void bc_b_cbDG(char x) { gps->c = (hca[x] = vc); }
void bc_b_cbDS(char x) { gps->c = (hca[x] = hca[1]); }
void bc_b_cLMK(int x) { int i; for (i = 0; i < 4; i++) { gs.c = (hca[i] = 7); } }
void bc_b_cLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.c = (hca[i] = vc); } }
void bc_b_cLMS(int x) { int i; for (i = 0; i < 4; i++) { gs.c = (hca[i] = hca[1]); } }
void bc_b_cLPK(int x) { int i; for (i = 0; i < 4; i++) { *gcp = (hca[i] = 7); } }
void bc_b_cLPG(int x) { int i; for (i = 0; i < 4; i++) { *gcp = (hca[i] = vc); } }
void bc_b_cLPS(int x) { int i; for (i = 0; i < 4; i++) { *gcp = (hca[i] = hca[1]); } }
void bc_b_cLEK(int x) { int i; for (i = 0; i < 4; i++) { gca[2] = (hca[i] = 7); } }
void bc_b_cLEG(int x) { int i; for (i = 0; i < 4; i++) { gca[2] = (hca[i] = vc); } }
void bc_b_cLES(int x) { int i; for (i = 0; i < 4; i++) { gca[2] = (hca[i] = hca[1]); } }
void bc_b_cLDK(int x) { int i; for (i = 0; i < 4; i++) { gps->c = (hca[i] = 7); } }
void bc_b_cLDG(int x) { int i; for (i = 0; i < 4; i++) { gps->c = (hca[i] = vc); } }
void bc_b_cLDS(int x) { int i; for (i = 0; i < 4; i++) { gps->c = (hca[i] = hca[1]); } }
void bc_b_uaMK(int x) { gs.u = (hua[x] = 7); }
void bc_b_uaMG(int x) { gs.u = (hua[x] = vu); }
void bc_b_uaMS(int x) { gs.u = (hua[x] = hua[1]); }
void bc_b_uaPK(int x) { *gup = (hua[x] = 7); }
void bc_b_uaPG(int x) { *gup = (hua[x] = vu); }
void bc_b_uaPS(int x) { *gup = (hua[x] = hua[1]); }
void bc_b_uaEK(int x) { gua[2] = (hua[x] = 7); }
void bc_b_uaEG(int x) { gua[2] = (hua[x] = vu); }
void bc_b_uaES(int x) { gua[2] = (hua[x] = hua[1]); }
void bc_b_uaDK(int x) { gps->u = (hua[x] = 7); }
void bc_b_uaDG(int x) { gps->u = (hua[x] = vu); }
void bc_b_uaDS(int x) { gps->u = (hua[x] = hua[1]); }
void bc_b_ubMK(char x) { gs.u = (hua[x] = 7); }
void bc_b_ubMG(char x) { gs.u = (hua[x] = vu); }
void bc_b_ubMS(char x) { gs.u = (hua[x] = hua[1]); }
void bc_b_ubPK(char x) { *gup = (hua[x] = 7); }
void bc_b_ubPG(char x) { *gup = (hua[x] = vu); }
void bc_b_ubPS(char x) { *gup = (hua[x] = hua[1]); }
void bc_b_ubEK(char x) { gua[2] = (hua[x] = 7); }
void bc_b_ubEG(char x) { gua[2] = (hua[x] = vu); }
void bc_b_ubES(char x) { gua[2] = (hua[x] = hua[1]); }
void bc_b_ubDK(char x) { gps->u = (hua[x] = 7); }
void bc_b_ubDG(char x) { gps->u = (hua[x] = vu); }
void bc_b_ubDS(char x) { gps->u = (hua[x] = hua[1]); }
void bc_b_uLMK(int x) { int i; for (i = 0; i < 4; i++) { gs.u = (hua[i] = 7); } }
void bc_b_uLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.u = (hua[i] = vu); } }
void bc_b_uLMS(int x) { int i; for (i = 0; i < 4; i++) { gs.u = (hua[i] = hua[1]); } }
void bc_b_uLPK(int x) { int i; for (i = 0; i < 4; i++) { *gup = (hua[i] = 7); } }
void bc_b_uLPG(int x) { int i; for (i = 0; i < 4; i++) { *gup = (hua[i] = vu); } }
void bc_b_uLPS(int x) { int i; for (i = 0; i < 4; i++) { *gup = (hua[i] = hua[1]); } }
void bc_b_uLEK(int x) { int i; for (i = 0; i < 4; i++) { gua[2] = (hua[i] = 7); } }
void bc_b_uLEG(int x) { int i; for (i = 0; i < 4; i++) { gua[2] = (hua[i] = vu); } }
void bc_b_uLES(int x) { int i; for (i = 0; i < 4; i++) { gua[2] = (hua[i] = hua[1]); } }
void bc_b_uLDK(int x) { int i; for (i = 0; i < 4; i++) { gps->u = (hua[i] = 7); } }
void bc_b_uLDG(int x) { int i; for (i = 0; i < 4; i++) { gps->u = (hua[i] = vu); } }
void bc_b_uLDS(int x) { int i; for (i = 0; i < 4; i++) { gps->u = (hua[i] = hua[1]); } }
void bc_b_laMK(int x) { gs.l = (hla[x] = 7); }
void bc_b_laMG(int x) { gs.l = (hla[x] = vl); }
void bc_b_laMS(int x) { gs.l = (hla[x] = hla[1]); }
void bc_b_laPK(int x) { *glp = (hla[x] = 7); }
void bc_b_laPG(int x) { *glp = (hla[x] = vl); }
void bc_b_laPS(int x) { *glp = (hla[x] = hla[1]); }
void bc_b_laEK(int x) { gla[2] = (hla[x] = 7); }
void bc_b_laEG(int x) { gla[2] = (hla[x] = vl); }
void bc_b_laES(int x) { gla[2] = (hla[x] = hla[1]); }
void bc_b_laDK(int x) { gps->l = (hla[x] = 7); }
void bc_b_laDG(int x) { gps->l = (hla[x] = vl); }
void bc_b_laDS(int x) { gps->l = (hla[x] = hla[1]); }
void bc_b_lbMK(char x) { gs.l = (hla[x] = 7); }
void bc_b_lbMG(char x) { gs.l = (hla[x] = vl); }
void bc_b_lbMS(char x) { gs.l = (hla[x] = hla[1]); }
void bc_b_lbPK(char x) { *glp = (hla[x] = 7); }
void bc_b_lbPG(char x) { *glp = (hla[x] = vl); }
void bc_b_lbPS(char x) { *glp = (hla[x] = hla[1]); }
void bc_b_lbEK(char x) { gla[2] = (hla[x] = 7); }
void bc_b_lbEG(char x) { gla[2] = (hla[x] = vl); }
void bc_b_lbES(char x) { gla[2] = (hla[x] = hla[1]); }
void bc_b_lbDK(char x) { gps->l = (hla[x] = 7); }
void bc_b_lbDG(char x) { gps->l = (hla[x] = vl); }
void bc_b_lbDS(char x) { gps->l = (hla[x] = hla[1]); }
void bc_b_lLMK(int x) { int i; for (i = 0; i < 4; i++) { gs.l = (hla[i] = 7); } }
void bc_b_lLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.l = (hla[i] = vl); } }
void bc_b_lLMS(int x) { int i; for (i = 0; i < 4; i++) { gs.l = (hla[i] = hla[1]); } }
void bc_b_lLPK(int x) { int i; for (i = 0; i < 4; i++) { *glp = (hla[i] = 7); } }
void bc_b_lLPG(int x) { int i; for (i = 0; i < 4; i++) { *glp = (hla[i] = vl); } }
void bc_b_lLPS(int x) { int i; for (i = 0; i < 4; i++) { *glp = (hla[i] = hla[1]); } }
void bc_b_lLEK(int x) { int i; for (i = 0; i < 4; i++) { gla[2] = (hla[i] = 7); } }
void bc_b_lLEG(int x) { int i; for (i = 0; i < 4; i++) { gla[2] = (hla[i] = vl); } }
void bc_b_lLES(int x) { int i; for (i = 0; i < 4; i++) { gla[2] = (hla[i] = hla[1]); } }
void bc_b_lLDK(int x) { int i; for (i = 0; i < 4; i++) { gps->l = (hla[i] = 7); } }
void bc_b_lLDG(int x) { int i; for (i = 0; i < 4; i++) { gps->l = (hla[i] = vl); } }
void bc_b_lLDS(int x) { int i; for (i = 0; i < 4; i++) { gps->l = (hla[i] = hla[1]); } }
void bc_b_naMK(int x) { gs.n = (hna[x] = 7); }
void bc_b_naMG(int x) { gs.n = (hna[x] = vn); }
void bc_b_naMS(int x) { gs.n = (hna[x] = hna[1]); }
void bc_b_naPK(int x) { *gnp = (hna[x] = 7); }
void bc_b_naPG(int x) { *gnp = (hna[x] = vn); }
void bc_b_naPS(int x) { *gnp = (hna[x] = hna[1]); }
void bc_b_naEK(int x) { gna[2] = (hna[x] = 7); }
void bc_b_naEG(int x) { gna[2] = (hna[x] = vn); }
void bc_b_naES(int x) { gna[2] = (hna[x] = hna[1]); }
void bc_b_naDK(int x) { gps->n = (hna[x] = 7); }
void bc_b_naDG(int x) { gps->n = (hna[x] = vn); }
void bc_b_naDS(int x) { gps->n = (hna[x] = hna[1]); }
void bc_b_nbMK(char x) { gs.n = (hna[x] = 7); }
void bc_b_nbMG(char x) { gs.n = (hna[x] = vn); }
void bc_b_nbMS(char x) { gs.n = (hna[x] = hna[1]); }
void bc_b_nbPK(char x) { *gnp = (hna[x] = 7); }
void bc_b_nbPG(char x) { *gnp = (hna[x] = vn); }
void bc_b_nbPS(char x) { *gnp = (hna[x] = hna[1]); }
void bc_b_nbEK(char x) { gna[2] = (hna[x] = 7); }
void bc_b_nbEG(char x) { gna[2] = (hna[x] = vn); }
void bc_b_nbES(char x) { gna[2] = (hna[x] = hna[1]); }
void bc_b_nbDK(char x) { gps->n = (hna[x] = 7); }
void bc_b_nbDG(char x) { gps->n = (hna[x] = vn); }
void bc_b_nbDS(char x) { gps->n = (hna[x] = hna[1]); }
void bc_b_nLMK(int x) { int i; for (i = 0; i < 4; i++) { gs.n = (hna[i] = 7); } }
void bc_b_nLMG(int x) { int i; for (i = 0; i < 4; i++) { gs.n = (hna[i] = vn); } }
void bc_b_nLMS(int x) { int i; for (i = 0; i < 4; i++) { gs.n = (hna[i] = hna[1]); } }
void bc_b_nLPK(int x) { int i; for (i = 0; i < 4; i++) { *gnp = (hna[i] = 7); } }
void bc_b_nLPG(int x) { int i; for (i = 0; i < 4; i++) { *gnp = (hna[i] = vn); } }
void bc_b_nLPS(int x) { int i; for (i = 0; i < 4; i++) { *gnp = (hna[i] = hna[1]); } }
void bc_b_nLEK(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = (hna[i] = 7); } }
void bc_b_nLEG(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = (hna[i] = vn); } }
void bc_b_nLES(int x) { int i; for (i = 0; i < 4; i++) { gna[2] = (hna[i] = hna[1]); } }
void bc_b_nLDK(int x) { int i; for (i = 0; i < 4; i++) { gps->n = (hna[i] = 7); } }
void bc_b_nLDG(int x) { int i; for (i = 0; i < 4; i++) { gps->n = (hna[i] = vn); } }
void bc_b_nLDS(int x) { int i; for (i = 0; i < 4; i++) { gps->n = (hna[i] = hna[1]); } }

void bc_c_caC(int x) { if ((hca[x] = 2) == gi) gi3 = 1; }
void bc_c_caA(int x) { if (gi < 5 && (hca[x] = 2) == gi) gi3 = 1; }
char bc_c_caR(int x) { return (gcp[0] = hca[x]); }
void bc_c_caK(int x) { skc((hca[x] = vc)); }
void bc_c_caV(int x) { char u = (hca[x] = vc); gi3 = u; }
void bc_c_cbC(char x) { if ((hca[x] = 2) == gi) gi3 = 1; }
void bc_c_cbA(char x) { if (gi < 5 && (hca[x] = 2) == gi) gi3 = 1; }
char bc_c_cbR(char x) { return (gcp[0] = hca[x]); }
void bc_c_cbK(char x) { skc((hca[x] = vc)); }
void bc_c_cbV(char x) { char u = (hca[x] = vc); gi3 = u; }
void bc_c_cLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hca[i] = 2) == gi) gi3 = 1; } }
void bc_c_cLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hca[i] = 2) == gi) gi3 = 1; } }
void bc_c_cLK(int x) { int i; for (i = 0; i < 4; i++) { skc((hca[i] = vc)); } }
void bc_c_cLV(int x) { int i; char u = 0; for (i = 0; i < 4; i++) { u = (hca[i] = vc); } gi3 = u; }
void bc_c_uaC(int x) { if ((hua[x] = 2) == gi) gi3 = 1; }
void bc_c_uaA(int x) { if (gi < 5 && (hua[x] = 2) == gi) gi3 = 1; }
unsigned char bc_c_uaR(int x) { return (gup[0] = hua[x]); }
void bc_c_uaK(int x) { sku((hua[x] = vu)); }
void bc_c_uaV(int x) { unsigned char u = (hua[x] = vu); gi3 = u; }
void bc_c_ubC(char x) { if ((hua[x] = 2) == gi) gi3 = 1; }
void bc_c_ubA(char x) { if (gi < 5 && (hua[x] = 2) == gi) gi3 = 1; }
unsigned char bc_c_ubR(char x) { return (gup[0] = hua[x]); }
void bc_c_ubK(char x) { sku((hua[x] = vu)); }
void bc_c_ubV(char x) { unsigned char u = (hua[x] = vu); gi3 = u; }
void bc_c_uLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hua[i] = 2) == gi) gi3 = 1; } }
void bc_c_uLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hua[i] = 2) == gi) gi3 = 1; } }
void bc_c_uLK(int x) { int i; for (i = 0; i < 4; i++) { sku((hua[i] = vu)); } }
void bc_c_uLV(int x) { int i; unsigned char u = 0; for (i = 0; i < 4; i++) { u = (hua[i] = vu); } gi3 = u; }
void bc_c_iaC(int x) { if ((hia[x] = 2) == gi) gi3 = 1; }
void bc_c_iaA(int x) { if (gi < 5 && (hia[x] = 2) == gi) gi3 = 1; }
int bc_c_iaR(int x) { return (gip[0] = hia[x]); }
void bc_c_iaK(int x) { ski((hia[x] = vi)); }
void bc_c_iaV(int x) { int u = (hia[x] = vi); gi3 = u; }
void bc_c_ibC(char x) { if ((hia[x] = 2) == gi) gi3 = 1; }
void bc_c_ibA(char x) { if (gi < 5 && (hia[x] = 2) == gi) gi3 = 1; }
int bc_c_ibR(char x) { return (gip[0] = hia[x]); }
void bc_c_ibK(char x) { ski((hia[x] = vi)); }
void bc_c_ibV(char x) { int u = (hia[x] = vi); gi3 = u; }
void bc_c_iLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hia[i] = 2) == gi) gi3 = 1; } }
void bc_c_iLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hia[i] = 2) == gi) gi3 = 1; } }
void bc_c_iLK(int x) { int i; for (i = 0; i < 4; i++) { ski((hia[i] = vi)); } }
void bc_c_iLV(int x) { int i; int u = 0; for (i = 0; i < 4; i++) { u = (hia[i] = vi); } gi3 = u; }
void bc_c_waC(int x) { if ((hwa[x] = 2) == gi) gi3 = 1; }
void bc_c_waA(int x) { if (gi < 5 && (hwa[x] = 2) == gi) gi3 = 1; }
unsigned int bc_c_waR(int x) { return (gwp[0] = hwa[x]); }
void bc_c_waK(int x) { skw((hwa[x] = vw)); }
void bc_c_waV(int x) { unsigned int u = (hwa[x] = vw); gi3 = u; }
void bc_c_wbC(char x) { if ((hwa[x] = 2) == gi) gi3 = 1; }
void bc_c_wbA(char x) { if (gi < 5 && (hwa[x] = 2) == gi) gi3 = 1; }
unsigned int bc_c_wbR(char x) { return (gwp[0] = hwa[x]); }
void bc_c_wbK(char x) { skw((hwa[x] = vw)); }
void bc_c_wbV(char x) { unsigned int u = (hwa[x] = vw); gi3 = u; }
void bc_c_wLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hwa[i] = 2) == gi) gi3 = 1; } }
void bc_c_wLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hwa[i] = 2) == gi) gi3 = 1; } }
void bc_c_wLK(int x) { int i; for (i = 0; i < 4; i++) { skw((hwa[i] = vw)); } }
void bc_c_wLV(int x) { int i; unsigned int u = 0; for (i = 0; i < 4; i++) { u = (hwa[i] = vw); } gi3 = u; }
void bc_c_laC(int x) { if ((hla[x] = 2) == gi) gi3 = 1; }
void bc_c_laA(int x) { if (gi < 5 && (hla[x] = 2) == gi) gi3 = 1; }
long bc_c_laR(int x) { return (glp[0] = hla[x]); }
void bc_c_laK(int x) { skl((hla[x] = vl)); }
void bc_c_laV(int x) { long u = (hla[x] = vl); gi3 = u; }
void bc_c_lbC(char x) { if ((hla[x] = 2) == gi) gi3 = 1; }
void bc_c_lbA(char x) { if (gi < 5 && (hla[x] = 2) == gi) gi3 = 1; }
long bc_c_lbR(char x) { return (glp[0] = hla[x]); }
void bc_c_lbK(char x) { skl((hla[x] = vl)); }
void bc_c_lbV(char x) { long u = (hla[x] = vl); gi3 = u; }
void bc_c_lLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hla[i] = 2) == gi) gi3 = 1; } }
void bc_c_lLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hla[i] = 2) == gi) gi3 = 1; } }
void bc_c_lLK(int x) { int i; for (i = 0; i < 4; i++) { skl((hla[i] = vl)); } }
void bc_c_lLV(int x) { int i; long u = 0; for (i = 0; i < 4; i++) { u = (hla[i] = vl); } gi3 = u; }
void bc_c_naC(int x) { if ((hna[x] = 2) == gi) gi3 = 1; }
void bc_c_naA(int x) { if (gi < 5 && (hna[x] = 2) == gi) gi3 = 1; }
unsigned long bc_c_naR(int x) { return (gnp[0] = hna[x]); }
void bc_c_naK(int x) { skn((hna[x] = vn)); }
void bc_c_naV(int x) { unsigned long u = (hna[x] = vn); gi3 = u; }
void bc_c_nbC(char x) { if ((hna[x] = 2) == gi) gi3 = 1; }
void bc_c_nbA(char x) { if (gi < 5 && (hna[x] = 2) == gi) gi3 = 1; }
unsigned long bc_c_nbR(char x) { return (gnp[0] = hna[x]); }
void bc_c_nbK(char x) { skn((hna[x] = vn)); }
void bc_c_nbV(char x) { unsigned long u = (hna[x] = vn); gi3 = u; }
void bc_c_nLC(int x) { int i; for (i = 0; i < 4; i++) { if ((hna[i] = 2) == gi) gi3 = 1; } }
void bc_c_nLA(int x) { int i; for (i = 0; i < 4; i++) { if (gi < 5 && (hna[i] = 2) == gi) gi3 = 1; } }
void bc_c_nLK(int x) { int i; for (i = 0; i < 4; i++) { skn((hna[i] = vn)); } }
void bc_c_nLV(int x) { int i; unsigned long u = 0; for (i = 0; i < 4; i++) { u = (hna[i] = vn); } gi3 = u; }
