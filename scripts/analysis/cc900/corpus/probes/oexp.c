/* lane_o3 wrong-code probe: -O expression code; see gen_oexp.py for the name letters */
extern char gc1, gc2, gc3, gca[8];
extern unsigned char gb1, gb2, gb3, gba[8];
extern int gi1, gi2, gi3, gia[8];
extern unsigned int gu1, gu2, gu3, gua[8];
extern long gl1, gl2, gl3, gla[8];
extern unsigned long gn1, gn2, gn3, gna[8];
struct sv { char c; int i; long l; unsigned int u; char c2; int i2; long l2; };
extern struct sv gs, *gps;
extern char rc(void); extern unsigned char rb(void); extern int ri(void); extern unsigned int ru(void);
extern long rl(void); extern unsigned long rn(void);
void oe_ar_caG(void) { gc3 = gc1 + gc2; }
void oe_ar_caP(char a, char b) { gc3 = a + gc2; }
void oe_ar_caQ(char a, char b) { gc3 = a + b; }
void oe_ar_caK(void) { gc3 = gc1 + 5; }
void oe_ar_caC(void) { gc3 = 9 + gc1; }
void oe_ar_csG(void) { gc3 = gc1 - gc2; }
void oe_ar_csP(char a, char b) { gc3 = a - gc2; }
void oe_ar_csQ(char a, char b) { gc3 = a - b; }
void oe_ar_csK(void) { gc3 = gc1 - 5; }
void oe_ar_csC(void) { gc3 = 9 - gc1; }
void oe_ar_cdG(void) { gc3 = gc1 / (gc2 & 0x7f | 1); }
void oe_ar_cdP(char a, char b) { gc3 = a / (gc2 & 0x7f | 1); }
void oe_ar_cdQ(char a, char b) { gc3 = a / (b & 0x7f | 1); }
void oe_ar_cdK(void) { gc3 = gc1 / 5; }
void oe_ar_cdC(void) { gc3 = 9 / (gc1 & 0x7f | 1); }
void oe_ar_crG(void) { gc3 = gc1 % (gc2 & 0x7f | 1); }
void oe_ar_crP(char a, char b) { gc3 = a % (gc2 & 0x7f | 1); }
void oe_ar_crQ(char a, char b) { gc3 = a % (b & 0x7f | 1); }
void oe_ar_crK(void) { gc3 = gc1 % 5; }
void oe_ar_crC(void) { gc3 = 9 % (gc1 & 0x7f | 1); }
void oe_ar_cnG(void) { gc3 = gc1 & gc2; }
void oe_ar_cnP(char a, char b) { gc3 = a & gc2; }
void oe_ar_cnQ(char a, char b) { gc3 = a & b; }
void oe_ar_cnK(void) { gc3 = gc1 & 5; }
void oe_ar_cnC(void) { gc3 = 9 & gc1; }
void oe_ar_coG(void) { gc3 = gc1 | gc2; }
void oe_ar_coP(char a, char b) { gc3 = a | gc2; }
void oe_ar_coQ(char a, char b) { gc3 = a | b; }
void oe_ar_coK(void) { gc3 = gc1 | 5; }
void oe_ar_coC(void) { gc3 = 9 | gc1; }
void oe_ar_cxG(void) { gc3 = gc1 ^ gc2; }
void oe_ar_cxP(char a, char b) { gc3 = a ^ gc2; }
void oe_ar_cxQ(char a, char b) { gc3 = a ^ b; }
void oe_ar_cxK(void) { gc3 = gc1 ^ 5; }
void oe_ar_cxC(void) { gc3 = 9 ^ gc1; }
void oe_ar_chG(void) { gc3 = gc1 >> 3; }
void oe_ar_chP(char a, char b) { gc3 = a >> 3; }
void oe_ar_cLG(void) { gc3 = gc1 << (gc2 & 7); }
void oe_ar_cLP(char a, char b) { gc3 = a << (gc2 & 7); }
void oe_ar_cHG(void) { gc3 = gc1 >> (gc2 & 7); }
void oe_ar_cHP(char a, char b) { gc3 = a >> (gc2 & 7); }
void oe_cm_ceT(void) { gc3 = (gc1 == gc2 ? gc1 : 7); }
void oe_cm_ceI(void) { if (gc1 == gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_ceR(char a, char b) { return (a == gc2 ? 1 : 2); }
int oe_cm_ceB(char a, char b) { return a == b; }
void oe_cm_cnT(void) { gc3 = (gc1 != gc2 ? gc1 : 7); }
void oe_cm_cnI(void) { if (gc1 != gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_cnR(char a, char b) { return (a != gc2 ? 1 : 2); }
int oe_cm_cnB(char a, char b) { return a != b; }
void oe_cm_clT(void) { gc3 = (gc1 < gc2 ? gc1 : 7); }
void oe_cm_clI(void) { if (gc1 < gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_clR(char a, char b) { return (a < gc2 ? 1 : 2); }
int oe_cm_clB(char a, char b) { return a < b; }
void oe_cm_cgT(void) { gc3 = (gc1 > gc2 ? gc1 : 7); }
void oe_cm_cgI(void) { if (gc1 > gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_cgR(char a, char b) { return (a > gc2 ? 1 : 2); }
int oe_cm_cgB(char a, char b) { return a > b; }
void oe_cm_cLT(void) { gc3 = (gc1 <= gc2 ? gc1 : 7); }
void oe_cm_cLI(void) { if (gc1 <= gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_cLR(char a, char b) { return (a <= gc2 ? 1 : 2); }
int oe_cm_cLB(char a, char b) { return a <= b; }
void oe_cm_cGT(void) { gc3 = (gc1 >= gc2 ? gc1 : 7); }
void oe_cm_cGI(void) { if (gc1 >= gc2) gc3 = gc1; else gc3 = 3; }
int oe_cm_cGR(char a, char b) { return (a >= gc2 ? 1 : 2); }
int oe_cm_cGB(char a, char b) { return a >= b; }
void oe_lg_caT(void) { gc3 = (gc1 > 3 && gc2 != 0); }
void oe_lg_caI(void) { if (gc1 > 3 && gc2 != 0) gc3 = 1; else gc3 = 2; }
int oe_lg_caR(char a, char b) { return (a > 3 && b != 0); }
void oe_lg_coT(void) { gc3 = (gc1 > 3 || gc2 != 0); }
void oe_lg_coI(void) { if (gc1 > 3 || gc2 != 0) gc3 = 1; else gc3 = 2; }
int oe_lg_coR(char a, char b) { return (a > 3 || b != 0); }
void oe_cs_cb(void) { gb3 = (unsigned char)gc1; }
void oe_cs_ci(void) { gi3 = (int)gc1; }
void oe_cs_cu(void) { gu3 = (unsigned int)gc1; }
void oe_cs_cl(void) { gl3 = (long)gc1; }
void oe_cs_cn(void) { gn3 = (unsigned long)gc1; }
void oe_ca_caL(void) { gc3 = rc() + gc1; }
void oe_ca_caR(void) { gc3 = gc1 + rc(); }
void oe_ca_csL(void) { gc3 = rc() - gc1; }
void oe_ca_csR(void) { gc3 = gc1 - rc(); }
void oe_ca_cxL(void) { gc3 = rc() ^ gc1; }
void oe_ca_cxR(void) { gc3 = gc1 ^ rc(); }
void oe_un_cnG(void) { gc3 = -gc1; }
void oe_un_cnP(char a, char b) { gc3 = -a; }
void oe_un_ccG(void) { gc3 = ~gc1; }
void oe_un_ccP(char a, char b) { gc3 = ~a; }
void oe_un_ctG(void) { gc3 = !gc1; }
void oe_un_ctP(char a, char b) { gc3 = !a; }
void oe_oa_caG(void) { gc1 += gc2; }
void oe_oa_caL(void) { char t = gc1; t += gc2; gc3 = t; }
void oe_oa_caP(char a, char b) { a += gc2; gc3 = a; }
void oe_oa_csG(void) { gc1 -= gc2; }
void oe_oa_csL(void) { char t = gc1; t -= gc2; gc3 = t; }
void oe_oa_csP(char a, char b) { a -= gc2; gc3 = a; }
void oe_oa_cxG(void) { gc1 ^= gc2; }
void oe_oa_cxL(void) { char t = gc1; t ^= gc2; gc3 = t; }
void oe_oa_cxP(char a, char b) { a ^= gc2; gc3 = a; }
void oe_oa_cnG(void) { gc1 &= gc2; }
void oe_oa_cnL(void) { char t = gc1; t &= gc2; gc3 = t; }
void oe_oa_cnP(char a, char b) { a &= gc2; gc3 = a; }
void oe_oa_coG(void) { gc1 |= gc2; }
void oe_oa_coL(void) { char t = gc1; t |= gc2; gc3 = t; }
void oe_oa_coP(char a, char b) { a |= gc2; gc3 = a; }
void oe_oa_chG(void) { gc1 >>= 3; }
void oe_oa_chL(void) { char t = gc1; t >>= 3; gc3 = t; }
void oe_oa_chP(char a, char b) { a >>= 3; gc3 = a; }
void oe_oa_ciG(void) { gc1++; }
void oe_oa_ciL(void) { char t = gc1; t++; gc3 = t; }
void oe_oa_ciP(char a, char b) { a++; gc3 = a; }
void oe_oa_cjG(void) { gc1--; }
void oe_oa_cjL(void) { char t = gc1; t--; gc3 = t; }
void oe_oa_cjP(char a, char b) { a--; gc3 = a; }
char oe_rp_ca(char a, char b, char c) { return (a + b) ^ c; }
char oe_rp_cs(char a, char b, char c) { return (a - b) ^ c; }
char oe_rp_cn(char a, char b, char c) { return (a & b) ^ c; }
char oe_rp_co(char a, char b, char c) { return (a | b) ^ c; }
char oe_rp_cx(char a, char b, char c) { return (a ^ b) + c; }
void oe_ck_ceT(void) { gc3 = (gc1 == 5 ? gc2 : gc1); }
int oe_ck_ceI(char a, char b) { if (a == 0) return 4; return 9; }
void oe_ck_cnT(void) { gc3 = (gc1 != 5 ? gc2 : gc1); }
int oe_ck_cnI(char a, char b) { if (a != 0) return 4; return 9; }
void oe_ck_clT(void) { gc3 = (gc1 < 5 ? gc2 : gc1); }
int oe_ck_clI(char a, char b) { if (a < 0) return 4; return 9; }
void oe_ck_cgT(void) { gc3 = (gc1 > 5 ? gc2 : gc1); }
int oe_ck_cgI(char a, char b) { if (a > 0) return 4; return 9; }
void oe_ck_cLT(void) { gc3 = (gc1 <= 5 ? gc2 : gc1); }
int oe_ck_cLI(char a, char b) { if (a <= 0) return 4; return 9; }
void oe_ck_cGT(void) { gc3 = (gc1 >= 5 ? gc2 : gc1); }
int oe_ck_cGI(char a, char b) { if (a >= 0) return 4; return 9; }
void oe_el_caP(char a, char b) { gc3 = gca[a & 7] + gc2; }
void oe_el_caS(char a, char b) { gca[b & 7] = gc1 + a; }
void oe_el_csP(char a, char b) { gc3 = gca[a & 7] - gc2; }
void oe_el_csS(char a, char b) { gca[b & 7] = gc1 - a; }
void oe_el_cnP(char a, char b) { gc3 = gca[a & 7] & gc2; }
void oe_el_cnS(char a, char b) { gca[b & 7] = gc1 & a; }
void oe_el_coP(char a, char b) { gc3 = gca[a & 7] | gc2; }
void oe_el_coS(char a, char b) { gca[b & 7] = gc1 | a; }
void oe_el_cxP(char a, char b) { gc3 = gca[a & 7] ^ gc2; }
void oe_el_cxS(char a, char b) { gca[b & 7] = gc1 ^ a; }
void oe_mx_cbA(void) { gb3 = gc1 + gb2; }
void oe_mx_cbX(void) { gc3 = gc1 ^ gb2; }
int oe_mx_cbC(void) { return gc1 < gb2; }
void oe_mx_ciA(void) { gi3 = gc1 + gi2; }
void oe_mx_ciX(void) { gc3 = gc1 ^ gi2; }
int oe_mx_ciC(void) { return gc1 < gi2; }
void oe_mx_cuA(void) { gu3 = gc1 + gu2; }
void oe_mx_cuX(void) { gc3 = gc1 ^ gu2; }
int oe_mx_cuC(void) { return gc1 < gu2; }
void oe_mx_clA(void) { gl3 = gc1 + gl2; }
void oe_mx_clX(void) { gc3 = gc1 ^ gl2; }
int oe_mx_clC(void) { return gc1 < gl2; }
void oe_mx_cnA(void) { gn3 = gc1 + gn2; }
void oe_mx_cnX(void) { gc3 = gc1 ^ gn2; }
int oe_mx_cnC(void) { return gc1 < gn2; }
void oe_pa_cS(void) { gs.c = (char)gc1; gs.i = (int)gc2; gs.l = (long)gc3; }
void oe_pa_cC(void) { char t = gc1; gc2 = t + gc3; }
void oe_pa_cR(void) { gc2 = gc1 + 1; gc3 = gc1; }
void oe_pa_cE(void) { gca[1] = gc1; gca[5] = gca[1] + gc2; }
void oe_pa_cA(void) { gps->i = (int)gc1; gps->i2 = gps->i + (int)gc2; }
void oe_pa_cW(void) { gc1 = gc2 + 3; gc3 = gc1 - gc2; }
void oe_ar_baG(void) { gb3 = gb1 + gb2; }
void oe_ar_baP(unsigned char a, unsigned char b) { gb3 = a + gb2; }
void oe_ar_baQ(unsigned char a, unsigned char b) { gb3 = a + b; }
void oe_ar_baK(void) { gb3 = gb1 + 5; }
void oe_ar_baC(void) { gb3 = 9 + gb1; }
void oe_ar_bsG(void) { gb3 = gb1 - gb2; }
void oe_ar_bsP(unsigned char a, unsigned char b) { gb3 = a - gb2; }
void oe_ar_bsQ(unsigned char a, unsigned char b) { gb3 = a - b; }
void oe_ar_bsK(void) { gb3 = gb1 - 5; }
void oe_ar_bsC(void) { gb3 = 9 - gb1; }
void oe_ar_bmG(void) { gb3 = gb1 * gb2; }
void oe_ar_bmP(unsigned char a, unsigned char b) { gb3 = a * gb2; }
void oe_ar_bmQ(unsigned char a, unsigned char b) { gb3 = a * b; }
void oe_ar_bmK(void) { gb3 = gb1 * 5; }
void oe_ar_bmC(void) { gb3 = 9 * gb1; }
void oe_ar_bdG(void) { gb3 = gb1 / (gb2 | 1); }
void oe_ar_bdP(unsigned char a, unsigned char b) { gb3 = a / (gb2 | 1); }
void oe_ar_bdQ(unsigned char a, unsigned char b) { gb3 = a / (b | 1); }
void oe_ar_bdK(void) { gb3 = gb1 / 5; }
void oe_ar_bdC(void) { gb3 = 9 / (gb1 | 1); }
void oe_ar_brG(void) { gb3 = gb1 % (gb2 | 1); }
void oe_ar_brP(unsigned char a, unsigned char b) { gb3 = a % (gb2 | 1); }
void oe_ar_brQ(unsigned char a, unsigned char b) { gb3 = a % (b | 1); }
void oe_ar_brK(void) { gb3 = gb1 % 5; }
void oe_ar_brC(void) { gb3 = 9 % (gb1 | 1); }
void oe_ar_bnG(void) { gb3 = gb1 & gb2; }
void oe_ar_bnP(unsigned char a, unsigned char b) { gb3 = a & gb2; }
void oe_ar_bnQ(unsigned char a, unsigned char b) { gb3 = a & b; }
void oe_ar_bnK(void) { gb3 = gb1 & 5; }
void oe_ar_bnC(void) { gb3 = 9 & gb1; }
void oe_ar_boG(void) { gb3 = gb1 | gb2; }
void oe_ar_boP(unsigned char a, unsigned char b) { gb3 = a | gb2; }
void oe_ar_boQ(unsigned char a, unsigned char b) { gb3 = a | b; }
void oe_ar_boK(void) { gb3 = gb1 | 5; }
void oe_ar_boC(void) { gb3 = 9 | gb1; }
void oe_ar_bxG(void) { gb3 = gb1 ^ gb2; }
void oe_ar_bxP(unsigned char a, unsigned char b) { gb3 = a ^ gb2; }
void oe_ar_bxQ(unsigned char a, unsigned char b) { gb3 = a ^ b; }
void oe_ar_bxK(void) { gb3 = gb1 ^ 5; }
void oe_ar_bxC(void) { gb3 = 9 ^ gb1; }
void oe_ar_blG(void) { gb3 = gb1 << 3; }
void oe_ar_blP(unsigned char a, unsigned char b) { gb3 = a << 3; }
void oe_ar_bhG(void) { gb3 = gb1 >> 3; }
void oe_ar_bhP(unsigned char a, unsigned char b) { gb3 = a >> 3; }
void oe_ar_bLG(void) { gb3 = gb1 << (gb2 & 7); }
void oe_ar_bLP(unsigned char a, unsigned char b) { gb3 = a << (gb2 & 7); }
void oe_ar_bHG(void) { gb3 = gb1 >> (gb2 & 7); }
void oe_ar_bHP(unsigned char a, unsigned char b) { gb3 = a >> (gb2 & 7); }
void oe_cm_beT(void) { gb3 = (gb1 == gb2 ? gb1 : 7); }
void oe_cm_beI(void) { if (gb1 == gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_beR(unsigned char a, unsigned char b) { return (a == gb2 ? 1 : 2); }
int oe_cm_beB(unsigned char a, unsigned char b) { return a == b; }
void oe_cm_bnT(void) { gb3 = (gb1 != gb2 ? gb1 : 7); }
void oe_cm_bnI(void) { if (gb1 != gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_bnR(unsigned char a, unsigned char b) { return (a != gb2 ? 1 : 2); }
int oe_cm_bnB(unsigned char a, unsigned char b) { return a != b; }
void oe_cm_blT(void) { gb3 = (gb1 < gb2 ? gb1 : 7); }
void oe_cm_blI(void) { if (gb1 < gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_blR(unsigned char a, unsigned char b) { return (a < gb2 ? 1 : 2); }
int oe_cm_blB(unsigned char a, unsigned char b) { return a < b; }
void oe_cm_bgT(void) { gb3 = (gb1 > gb2 ? gb1 : 7); }
void oe_cm_bgI(void) { if (gb1 > gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_bgR(unsigned char a, unsigned char b) { return (a > gb2 ? 1 : 2); }
int oe_cm_bgB(unsigned char a, unsigned char b) { return a > b; }
void oe_cm_bLT(void) { gb3 = (gb1 <= gb2 ? gb1 : 7); }
void oe_cm_bLI(void) { if (gb1 <= gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_bLR(unsigned char a, unsigned char b) { return (a <= gb2 ? 1 : 2); }
int oe_cm_bLB(unsigned char a, unsigned char b) { return a <= b; }
void oe_cm_bGT(void) { gb3 = (gb1 >= gb2 ? gb1 : 7); }
void oe_cm_bGI(void) { if (gb1 >= gb2) gb3 = gb1; else gb3 = 3; }
int oe_cm_bGR(unsigned char a, unsigned char b) { return (a >= gb2 ? 1 : 2); }
int oe_cm_bGB(unsigned char a, unsigned char b) { return a >= b; }
void oe_lg_baT(void) { gb3 = (gb1 > 3 && gb2 != 0); }
void oe_lg_baI(void) { if (gb1 > 3 && gb2 != 0) gb3 = 1; else gb3 = 2; }
int oe_lg_baR(unsigned char a, unsigned char b) { return (a > 3 && b != 0); }
void oe_lg_boT(void) { gb3 = (gb1 > 3 || gb2 != 0); }
void oe_lg_boI(void) { if (gb1 > 3 || gb2 != 0) gb3 = 1; else gb3 = 2; }
int oe_lg_boR(unsigned char a, unsigned char b) { return (a > 3 || b != 0); }
void oe_cs_bc(void) { gc3 = (char)gb1; }
void oe_cs_bi(void) { gi3 = (int)gb1; }
void oe_cs_bu(void) { gu3 = (unsigned int)gb1; }
void oe_cs_bl(void) { gl3 = (long)gb1; }
void oe_cs_bn(void) { gn3 = (unsigned long)gb1; }
void oe_ca_baL(void) { gb3 = rb() + gb1; }
void oe_ca_baR(void) { gb3 = gb1 + rb(); }
void oe_ca_bsL(void) { gb3 = rb() - gb1; }
void oe_ca_bsR(void) { gb3 = gb1 - rb(); }
void oe_ca_bmL(void) { gb3 = rb() * gb1; }
void oe_ca_bmR(void) { gb3 = gb1 * rb(); }
void oe_ca_bxL(void) { gb3 = rb() ^ gb1; }
void oe_ca_bxR(void) { gb3 = gb1 ^ rb(); }
void oe_un_bnG(void) { gb3 = -gb1; }
void oe_un_bnP(unsigned char a, unsigned char b) { gb3 = -a; }
void oe_un_bcG(void) { gb3 = ~gb1; }
void oe_un_bcP(unsigned char a, unsigned char b) { gb3 = ~a; }
void oe_un_btG(void) { gb3 = !gb1; }
void oe_un_btP(unsigned char a, unsigned char b) { gb3 = !a; }
void oe_oa_baG(void) { gb1 += gb2; }
void oe_oa_baL(void) { unsigned char t = gb1; t += gb2; gb3 = t; }
void oe_oa_baP(unsigned char a, unsigned char b) { a += gb2; gb3 = a; }
void oe_oa_bsG(void) { gb1 -= gb2; }
void oe_oa_bsL(void) { unsigned char t = gb1; t -= gb2; gb3 = t; }
void oe_oa_bsP(unsigned char a, unsigned char b) { a -= gb2; gb3 = a; }
void oe_oa_bxG(void) { gb1 ^= gb2; }
void oe_oa_bxL(void) { unsigned char t = gb1; t ^= gb2; gb3 = t; }
void oe_oa_bxP(unsigned char a, unsigned char b) { a ^= gb2; gb3 = a; }
void oe_oa_bnG(void) { gb1 &= gb2; }
void oe_oa_bnL(void) { unsigned char t = gb1; t &= gb2; gb3 = t; }
void oe_oa_bnP(unsigned char a, unsigned char b) { a &= gb2; gb3 = a; }
void oe_oa_boG(void) { gb1 |= gb2; }
void oe_oa_boL(void) { unsigned char t = gb1; t |= gb2; gb3 = t; }
void oe_oa_boP(unsigned char a, unsigned char b) { a |= gb2; gb3 = a; }
void oe_oa_blG(void) { gb1 <<= 3; }
void oe_oa_blL(void) { unsigned char t = gb1; t <<= 3; gb3 = t; }
void oe_oa_blP(unsigned char a, unsigned char b) { a <<= 3; gb3 = a; }
void oe_oa_bhG(void) { gb1 >>= 3; }
void oe_oa_bhL(void) { unsigned char t = gb1; t >>= 3; gb3 = t; }
void oe_oa_bhP(unsigned char a, unsigned char b) { a >>= 3; gb3 = a; }
void oe_oa_bmG(void) { gb1 *= 3; }
void oe_oa_bmL(void) { unsigned char t = gb1; t *= 3; gb3 = t; }
void oe_oa_bmP(unsigned char a, unsigned char b) { a *= 3; gb3 = a; }
void oe_oa_biG(void) { gb1++; }
void oe_oa_biL(void) { unsigned char t = gb1; t++; gb3 = t; }
void oe_oa_biP(unsigned char a, unsigned char b) { a++; gb3 = a; }
void oe_oa_bjG(void) { gb1--; }
void oe_oa_bjL(void) { unsigned char t = gb1; t--; gb3 = t; }
void oe_oa_bjP(unsigned char a, unsigned char b) { a--; gb3 = a; }
unsigned char oe_rp_ba(unsigned char a, unsigned char b, unsigned char c) { return (a + b) ^ c; }
unsigned char oe_rp_bs(unsigned char a, unsigned char b, unsigned char c) { return (a - b) ^ c; }
unsigned char oe_rp_bn(unsigned char a, unsigned char b, unsigned char c) { return (a & b) ^ c; }
unsigned char oe_rp_bo(unsigned char a, unsigned char b, unsigned char c) { return (a | b) ^ c; }
unsigned char oe_rp_bx(unsigned char a, unsigned char b, unsigned char c) { return (a ^ b) + c; }
void oe_ck_beT(void) { gb3 = (gb1 == 5 ? gb2 : gb1); }
int oe_ck_beI(unsigned char a, unsigned char b) { if (a == 0) return 4; return 9; }
void oe_ck_bnT(void) { gb3 = (gb1 != 5 ? gb2 : gb1); }
int oe_ck_bnI(unsigned char a, unsigned char b) { if (a != 0) return 4; return 9; }
void oe_ck_blT(void) { gb3 = (gb1 < 5 ? gb2 : gb1); }
int oe_ck_blI(unsigned char a, unsigned char b) { if (a < 0) return 4; return 9; }
void oe_ck_bgT(void) { gb3 = (gb1 > 5 ? gb2 : gb1); }
int oe_ck_bgI(unsigned char a, unsigned char b) { if (a > 0) return 4; return 9; }
void oe_ck_bLT(void) { gb3 = (gb1 <= 5 ? gb2 : gb1); }
int oe_ck_bLI(unsigned char a, unsigned char b) { if (a <= 0) return 4; return 9; }
void oe_ck_bGT(void) { gb3 = (gb1 >= 5 ? gb2 : gb1); }
int oe_ck_bGI(unsigned char a, unsigned char b) { if (a >= 0) return 4; return 9; }
void oe_el_baP(unsigned char a, unsigned char b) { gb3 = gba[a & 7] + gb2; }
void oe_el_baS(unsigned char a, unsigned char b) { gba[b & 7] = gb1 + a; }
void oe_el_bsP(unsigned char a, unsigned char b) { gb3 = gba[a & 7] - gb2; }
void oe_el_bsS(unsigned char a, unsigned char b) { gba[b & 7] = gb1 - a; }
void oe_el_bnP(unsigned char a, unsigned char b) { gb3 = gba[a & 7] & gb2; }
void oe_el_bnS(unsigned char a, unsigned char b) { gba[b & 7] = gb1 & a; }
void oe_el_boP(unsigned char a, unsigned char b) { gb3 = gba[a & 7] | gb2; }
void oe_el_boS(unsigned char a, unsigned char b) { gba[b & 7] = gb1 | a; }
void oe_el_bxP(unsigned char a, unsigned char b) { gb3 = gba[a & 7] ^ gb2; }
void oe_el_bxS(unsigned char a, unsigned char b) { gba[b & 7] = gb1 ^ a; }
void oe_mx_bcA(void) { gc3 = gb1 + gc2; }
void oe_mx_bcX(void) { gb3 = gb1 ^ gc2; }
int oe_mx_bcC(void) { return gb1 < gc2; }
void oe_mx_biA(void) { gi3 = gb1 + gi2; }
void oe_mx_biX(void) { gb3 = gb1 ^ gi2; }
int oe_mx_biC(void) { return gb1 < gi2; }
void oe_mx_buA(void) { gu3 = gb1 + gu2; }
void oe_mx_buX(void) { gb3 = gb1 ^ gu2; }
int oe_mx_buC(void) { return gb1 < gu2; }
void oe_mx_blA(void) { gl3 = gb1 + gl2; }
void oe_mx_blX(void) { gb3 = gb1 ^ gl2; }
int oe_mx_blC(void) { return gb1 < gl2; }
void oe_mx_bnA(void) { gn3 = gb1 + gn2; }
void oe_mx_bnX(void) { gb3 = gb1 ^ gn2; }
int oe_mx_bnC(void) { return gb1 < gn2; }
void oe_pa_bS(void) { gs.c = (char)gb1; gs.i = (int)gb2; gs.l = (long)gb3; }
void oe_pa_bC(void) { unsigned char t = gb1; gb2 = t + gb3; }
void oe_pa_bR(void) { gb2 = gb1 + 1; gb3 = gb1; }
void oe_pa_bE(void) { gba[1] = gb1; gba[5] = gba[1] + gb2; }
void oe_pa_bA(void) { gps->i = (int)gb1; gps->i2 = gps->i + (int)gb2; }
void oe_pa_bW(void) { gb1 = gb2 * 3; gb3 = gb1 - gb2; }
void oe_ar_iaG(void) { gi3 = gi1 + gi2; }
void oe_ar_iaP(int a, int b) { gi3 = a + gi2; }
void oe_ar_iaQ(int a, int b) { gi3 = a + b; }
void oe_ar_iaK(void) { gi3 = gi1 + 5; }
void oe_ar_iaC(void) { gi3 = 9 + gi1; }
void oe_ar_isG(void) { gi3 = gi1 - gi2; }
void oe_ar_isP(int a, int b) { gi3 = a - gi2; }
void oe_ar_isQ(int a, int b) { gi3 = a - b; }
void oe_ar_isK(void) { gi3 = gi1 - 5; }
void oe_ar_isC(void) { gi3 = 9 - gi1; }
void oe_ar_idG(void) { gi3 = gi1 / (gi2 & 0x7f | 1); }
void oe_ar_idP(int a, int b) { gi3 = a / (gi2 & 0x7f | 1); }
void oe_ar_idQ(int a, int b) { gi3 = a / (b & 0x7f | 1); }
void oe_ar_idK(void) { gi3 = gi1 / 5; }
void oe_ar_idC(void) { gi3 = 9 / (gi1 & 0x7f | 1); }
void oe_ar_irG(void) { gi3 = gi1 % (gi2 & 0x7f | 1); }
void oe_ar_irP(int a, int b) { gi3 = a % (gi2 & 0x7f | 1); }
void oe_ar_irQ(int a, int b) { gi3 = a % (b & 0x7f | 1); }
void oe_ar_irK(void) { gi3 = gi1 % 5; }
void oe_ar_irC(void) { gi3 = 9 % (gi1 & 0x7f | 1); }
void oe_ar_inG(void) { gi3 = gi1 & gi2; }
void oe_ar_inP(int a, int b) { gi3 = a & gi2; }
void oe_ar_inQ(int a, int b) { gi3 = a & b; }
void oe_ar_inK(void) { gi3 = gi1 & 5; }
void oe_ar_inC(void) { gi3 = 9 & gi1; }
void oe_ar_ioG(void) { gi3 = gi1 | gi2; }
void oe_ar_ioP(int a, int b) { gi3 = a | gi2; }
void oe_ar_ioQ(int a, int b) { gi3 = a | b; }
void oe_ar_ioK(void) { gi3 = gi1 | 5; }
void oe_ar_ioC(void) { gi3 = 9 | gi1; }
void oe_ar_ixG(void) { gi3 = gi1 ^ gi2; }
void oe_ar_ixP(int a, int b) { gi3 = a ^ gi2; }
void oe_ar_ixQ(int a, int b) { gi3 = a ^ b; }
void oe_ar_ixK(void) { gi3 = gi1 ^ 5; }
void oe_ar_ixC(void) { gi3 = 9 ^ gi1; }
void oe_ar_ihG(void) { gi3 = gi1 >> 3; }
void oe_ar_ihP(int a, int b) { gi3 = a >> 3; }
void oe_ar_iLG(void) { gi3 = gi1 << (gi2 & 15); }
void oe_ar_iLP(int a, int b) { gi3 = a << (gi2 & 15); }
void oe_ar_iHG(void) { gi3 = gi1 >> (gi2 & 15); }
void oe_ar_iHP(int a, int b) { gi3 = a >> (gi2 & 15); }
void oe_cm_ieT(void) { gi3 = (gi1 == gi2 ? gi1 : 7); }
void oe_cm_ieI(void) { if (gi1 == gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_ieR(int a, int b) { return (a == gi2 ? 1 : 2); }
int oe_cm_ieB(int a, int b) { return a == b; }
void oe_cm_inT(void) { gi3 = (gi1 != gi2 ? gi1 : 7); }
void oe_cm_inI(void) { if (gi1 != gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_inR(int a, int b) { return (a != gi2 ? 1 : 2); }
int oe_cm_inB(int a, int b) { return a != b; }
void oe_cm_ilT(void) { gi3 = (gi1 < gi2 ? gi1 : 7); }
void oe_cm_ilI(void) { if (gi1 < gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_ilR(int a, int b) { return (a < gi2 ? 1 : 2); }
int oe_cm_ilB(int a, int b) { return a < b; }
void oe_cm_igT(void) { gi3 = (gi1 > gi2 ? gi1 : 7); }
void oe_cm_igI(void) { if (gi1 > gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_igR(int a, int b) { return (a > gi2 ? 1 : 2); }
int oe_cm_igB(int a, int b) { return a > b; }
void oe_cm_iLT(void) { gi3 = (gi1 <= gi2 ? gi1 : 7); }
void oe_cm_iLI(void) { if (gi1 <= gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_iLR(int a, int b) { return (a <= gi2 ? 1 : 2); }
int oe_cm_iLB(int a, int b) { return a <= b; }
void oe_cm_iGT(void) { gi3 = (gi1 >= gi2 ? gi1 : 7); }
void oe_cm_iGI(void) { if (gi1 >= gi2) gi3 = gi1; else gi3 = 3; }
int oe_cm_iGR(int a, int b) { return (a >= gi2 ? 1 : 2); }
int oe_cm_iGB(int a, int b) { return a >= b; }
void oe_lg_iaT(void) { gi3 = (gi1 > 3 && gi2 != 0); }
void oe_lg_iaI(void) { if (gi1 > 3 && gi2 != 0) gi3 = 1; else gi3 = 2; }
int oe_lg_iaR(int a, int b) { return (a > 3 && b != 0); }
void oe_lg_ioT(void) { gi3 = (gi1 > 3 || gi2 != 0); }
void oe_lg_ioI(void) { if (gi1 > 3 || gi2 != 0) gi3 = 1; else gi3 = 2; }
int oe_lg_ioR(int a, int b) { return (a > 3 || b != 0); }
void oe_cs_ic(void) { gc3 = (char)gi1; }
void oe_cs_ib(void) { gb3 = (unsigned char)gi1; }
void oe_cs_iu(void) { gu3 = (unsigned int)gi1; }
void oe_cs_il(void) { gl3 = (long)gi1; }
void oe_cs_in(void) { gn3 = (unsigned long)gi1; }
void oe_ca_iaL(void) { gi3 = ri() + gi1; }
void oe_ca_iaR(void) { gi3 = gi1 + ri(); }
void oe_ca_isL(void) { gi3 = ri() - gi1; }
void oe_ca_isR(void) { gi3 = gi1 - ri(); }
void oe_ca_ixL(void) { gi3 = ri() ^ gi1; }
void oe_ca_ixR(void) { gi3 = gi1 ^ ri(); }
void oe_un_inG(void) { gi3 = -gi1; }
void oe_un_inP(int a, int b) { gi3 = -a; }
void oe_un_icG(void) { gi3 = ~gi1; }
void oe_un_icP(int a, int b) { gi3 = ~a; }
void oe_un_itG(void) { gi3 = !gi1; }
void oe_un_itP(int a, int b) { gi3 = !a; }
void oe_oa_iaG(void) { gi1 += gi2; }
void oe_oa_iaL(void) { int t = gi1; t += gi2; gi3 = t; }
void oe_oa_iaP(int a, int b) { a += gi2; gi3 = a; }
void oe_oa_isG(void) { gi1 -= gi2; }
void oe_oa_isL(void) { int t = gi1; t -= gi2; gi3 = t; }
void oe_oa_isP(int a, int b) { a -= gi2; gi3 = a; }
void oe_oa_ixG(void) { gi1 ^= gi2; }
void oe_oa_ixL(void) { int t = gi1; t ^= gi2; gi3 = t; }
void oe_oa_ixP(int a, int b) { a ^= gi2; gi3 = a; }
void oe_oa_inG(void) { gi1 &= gi2; }
void oe_oa_inL(void) { int t = gi1; t &= gi2; gi3 = t; }
void oe_oa_inP(int a, int b) { a &= gi2; gi3 = a; }
void oe_oa_ioG(void) { gi1 |= gi2; }
void oe_oa_ioL(void) { int t = gi1; t |= gi2; gi3 = t; }
void oe_oa_ioP(int a, int b) { a |= gi2; gi3 = a; }
void oe_oa_ihG(void) { gi1 >>= 3; }
void oe_oa_ihL(void) { int t = gi1; t >>= 3; gi3 = t; }
void oe_oa_ihP(int a, int b) { a >>= 3; gi3 = a; }
void oe_oa_iiG(void) { gi1++; }
void oe_oa_iiL(void) { int t = gi1; t++; gi3 = t; }
void oe_oa_iiP(int a, int b) { a++; gi3 = a; }
void oe_oa_ijG(void) { gi1--; }
void oe_oa_ijL(void) { int t = gi1; t--; gi3 = t; }
void oe_oa_ijP(int a, int b) { a--; gi3 = a; }
int oe_rp_ia(int a, int b, int c) { return (a + b) ^ c; }
int oe_rp_is(int a, int b, int c) { return (a - b) ^ c; }
int oe_rp_in(int a, int b, int c) { return (a & b) ^ c; }
int oe_rp_io(int a, int b, int c) { return (a | b) ^ c; }
int oe_rp_ix(int a, int b, int c) { return (a ^ b) + c; }
void oe_ck_ieT(void) { gi3 = (gi1 == 5 ? gi2 : gi1); }
int oe_ck_ieI(int a, int b) { if (a == 0) return 4; return 9; }
void oe_ck_inT(void) { gi3 = (gi1 != 5 ? gi2 : gi1); }
int oe_ck_inI(int a, int b) { if (a != 0) return 4; return 9; }
void oe_ck_ilT(void) { gi3 = (gi1 < 5 ? gi2 : gi1); }
int oe_ck_ilI(int a, int b) { if (a < 0) return 4; return 9; }
void oe_ck_igT(void) { gi3 = (gi1 > 5 ? gi2 : gi1); }
int oe_ck_igI(int a, int b) { if (a > 0) return 4; return 9; }
void oe_ck_iLT(void) { gi3 = (gi1 <= 5 ? gi2 : gi1); }
int oe_ck_iLI(int a, int b) { if (a <= 0) return 4; return 9; }
void oe_ck_iGT(void) { gi3 = (gi1 >= 5 ? gi2 : gi1); }
int oe_ck_iGI(int a, int b) { if (a >= 0) return 4; return 9; }
void oe_el_iaP(int a, int b) { gi3 = gia[a & 7] + gi2; }
void oe_el_iaS(int a, int b) { gia[b & 7] = gi1 + a; }
void oe_el_isP(int a, int b) { gi3 = gia[a & 7] - gi2; }
void oe_el_isS(int a, int b) { gia[b & 7] = gi1 - a; }
void oe_el_inP(int a, int b) { gi3 = gia[a & 7] & gi2; }
void oe_el_inS(int a, int b) { gia[b & 7] = gi1 & a; }
void oe_el_ioP(int a, int b) { gi3 = gia[a & 7] | gi2; }
void oe_el_ioS(int a, int b) { gia[b & 7] = gi1 | a; }
void oe_el_ixP(int a, int b) { gi3 = gia[a & 7] ^ gi2; }
void oe_el_ixS(int a, int b) { gia[b & 7] = gi1 ^ a; }
void oe_mx_icA(void) { gc3 = gi1 + gc2; }
void oe_mx_icX(void) { gi3 = gi1 ^ gc2; }
int oe_mx_icC(void) { return gi1 < gc2; }
void oe_mx_ibA(void) { gb3 = gi1 + gb2; }
void oe_mx_ibX(void) { gi3 = gi1 ^ gb2; }
int oe_mx_ibC(void) { return gi1 < gb2; }
void oe_mx_iuA(void) { gu3 = gi1 + gu2; }
void oe_mx_iuX(void) { gi3 = gi1 ^ gu2; }
int oe_mx_iuC(void) { return gi1 < gu2; }
void oe_mx_ilA(void) { gl3 = gi1 + gl2; }
void oe_mx_ilX(void) { gi3 = gi1 ^ gl2; }
int oe_mx_ilC(void) { return gi1 < gl2; }
void oe_mx_inA(void) { gn3 = gi1 + gn2; }
void oe_mx_inX(void) { gi3 = gi1 ^ gn2; }
int oe_mx_inC(void) { return gi1 < gn2; }
void oe_pa_iS(void) { gs.c = (char)gi1; gs.i = (int)gi2; gs.l = (long)gi3; }
void oe_pa_iC(void) { int t = gi1; gi2 = t + gi3; }
void oe_pa_iR(void) { gi2 = gi1 + 1; gi3 = gi1; }
void oe_pa_iE(void) { gia[1] = gi1; gia[5] = gia[1] + gi2; }
void oe_pa_iA(void) { gps->i = (int)gi1; gps->i2 = gps->i + (int)gi2; }
void oe_pa_iW(void) { gi1 = gi2 + 3; gi3 = gi1 - gi2; }
void oe_ar_uaG(void) { gu3 = gu1 + gu2; }
void oe_ar_uaP(unsigned int a, unsigned int b) { gu3 = a + gu2; }
void oe_ar_uaQ(unsigned int a, unsigned int b) { gu3 = a + b; }
void oe_ar_uaK(void) { gu3 = gu1 + 5; }
void oe_ar_uaC(void) { gu3 = 9 + gu1; }
void oe_ar_usG(void) { gu3 = gu1 - gu2; }
void oe_ar_usP(unsigned int a, unsigned int b) { gu3 = a - gu2; }
void oe_ar_usQ(unsigned int a, unsigned int b) { gu3 = a - b; }
void oe_ar_usK(void) { gu3 = gu1 - 5; }
void oe_ar_usC(void) { gu3 = 9 - gu1; }
void oe_ar_umG(void) { gu3 = gu1 * gu2; }
void oe_ar_umP(unsigned int a, unsigned int b) { gu3 = a * gu2; }
void oe_ar_umQ(unsigned int a, unsigned int b) { gu3 = a * b; }
void oe_ar_umK(void) { gu3 = gu1 * 5; }
void oe_ar_umC(void) { gu3 = 9 * gu1; }
void oe_ar_udG(void) { gu3 = gu1 / (gu2 | 1); }
void oe_ar_udP(unsigned int a, unsigned int b) { gu3 = a / (gu2 | 1); }
void oe_ar_udQ(unsigned int a, unsigned int b) { gu3 = a / (b | 1); }
void oe_ar_udK(void) { gu3 = gu1 / 5; }
void oe_ar_udC(void) { gu3 = 9 / (gu1 | 1); }
void oe_ar_urG(void) { gu3 = gu1 % (gu2 | 1); }
void oe_ar_urP(unsigned int a, unsigned int b) { gu3 = a % (gu2 | 1); }
void oe_ar_urQ(unsigned int a, unsigned int b) { gu3 = a % (b | 1); }
void oe_ar_urK(void) { gu3 = gu1 % 5; }
void oe_ar_urC(void) { gu3 = 9 % (gu1 | 1); }
void oe_ar_unG(void) { gu3 = gu1 & gu2; }
void oe_ar_unP(unsigned int a, unsigned int b) { gu3 = a & gu2; }
void oe_ar_unQ(unsigned int a, unsigned int b) { gu3 = a & b; }
void oe_ar_unK(void) { gu3 = gu1 & 5; }
void oe_ar_unC(void) { gu3 = 9 & gu1; }
void oe_ar_uoG(void) { gu3 = gu1 | gu2; }
void oe_ar_uoP(unsigned int a, unsigned int b) { gu3 = a | gu2; }
void oe_ar_uoQ(unsigned int a, unsigned int b) { gu3 = a | b; }
void oe_ar_uoK(void) { gu3 = gu1 | 5; }
void oe_ar_uoC(void) { gu3 = 9 | gu1; }
void oe_ar_uxG(void) { gu3 = gu1 ^ gu2; }
void oe_ar_uxP(unsigned int a, unsigned int b) { gu3 = a ^ gu2; }
void oe_ar_uxQ(unsigned int a, unsigned int b) { gu3 = a ^ b; }
void oe_ar_uxK(void) { gu3 = gu1 ^ 5; }
void oe_ar_uxC(void) { gu3 = 9 ^ gu1; }
void oe_ar_ulG(void) { gu3 = gu1 << 3; }
void oe_ar_ulP(unsigned int a, unsigned int b) { gu3 = a << 3; }
void oe_ar_uhG(void) { gu3 = gu1 >> 3; }
void oe_ar_uhP(unsigned int a, unsigned int b) { gu3 = a >> 3; }
void oe_ar_uLG(void) { gu3 = gu1 << (gu2 & 15); }
void oe_ar_uLP(unsigned int a, unsigned int b) { gu3 = a << (gu2 & 15); }
void oe_ar_uHG(void) { gu3 = gu1 >> (gu2 & 15); }
void oe_ar_uHP(unsigned int a, unsigned int b) { gu3 = a >> (gu2 & 15); }
void oe_cm_ueT(void) { gu3 = (gu1 == gu2 ? gu1 : 7); }
void oe_cm_ueI(void) { if (gu1 == gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_ueR(unsigned int a, unsigned int b) { return (a == gu2 ? 1 : 2); }
int oe_cm_ueB(unsigned int a, unsigned int b) { return a == b; }
void oe_cm_unT(void) { gu3 = (gu1 != gu2 ? gu1 : 7); }
void oe_cm_unI(void) { if (gu1 != gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_unR(unsigned int a, unsigned int b) { return (a != gu2 ? 1 : 2); }
int oe_cm_unB(unsigned int a, unsigned int b) { return a != b; }
void oe_cm_ulT(void) { gu3 = (gu1 < gu2 ? gu1 : 7); }
void oe_cm_ulI(void) { if (gu1 < gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_ulR(unsigned int a, unsigned int b) { return (a < gu2 ? 1 : 2); }
int oe_cm_ulB(unsigned int a, unsigned int b) { return a < b; }
void oe_cm_ugT(void) { gu3 = (gu1 > gu2 ? gu1 : 7); }
void oe_cm_ugI(void) { if (gu1 > gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_ugR(unsigned int a, unsigned int b) { return (a > gu2 ? 1 : 2); }
int oe_cm_ugB(unsigned int a, unsigned int b) { return a > b; }
void oe_cm_uLT(void) { gu3 = (gu1 <= gu2 ? gu1 : 7); }
void oe_cm_uLI(void) { if (gu1 <= gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_uLR(unsigned int a, unsigned int b) { return (a <= gu2 ? 1 : 2); }
int oe_cm_uLB(unsigned int a, unsigned int b) { return a <= b; }
void oe_cm_uGT(void) { gu3 = (gu1 >= gu2 ? gu1 : 7); }
void oe_cm_uGI(void) { if (gu1 >= gu2) gu3 = gu1; else gu3 = 3; }
int oe_cm_uGR(unsigned int a, unsigned int b) { return (a >= gu2 ? 1 : 2); }
int oe_cm_uGB(unsigned int a, unsigned int b) { return a >= b; }
void oe_lg_uaT(void) { gu3 = (gu1 > 3 && gu2 != 0); }
void oe_lg_uaI(void) { if (gu1 > 3 && gu2 != 0) gu3 = 1; else gu3 = 2; }
int oe_lg_uaR(unsigned int a, unsigned int b) { return (a > 3 && b != 0); }
void oe_lg_uoT(void) { gu3 = (gu1 > 3 || gu2 != 0); }
void oe_lg_uoI(void) { if (gu1 > 3 || gu2 != 0) gu3 = 1; else gu3 = 2; }
int oe_lg_uoR(unsigned int a, unsigned int b) { return (a > 3 || b != 0); }
void oe_cs_uc(void) { gc3 = (char)gu1; }
void oe_cs_ub(void) { gb3 = (unsigned char)gu1; }
void oe_cs_ui(void) { gi3 = (int)gu1; }
void oe_cs_ul(void) { gl3 = (long)gu1; }
void oe_cs_un(void) { gn3 = (unsigned long)gu1; }
void oe_ca_uaL(void) { gu3 = ru() + gu1; }
void oe_ca_uaR(void) { gu3 = gu1 + ru(); }
void oe_ca_usL(void) { gu3 = ru() - gu1; }
void oe_ca_usR(void) { gu3 = gu1 - ru(); }
void oe_ca_umL(void) { gu3 = ru() * gu1; }
void oe_ca_umR(void) { gu3 = gu1 * ru(); }
void oe_ca_uxL(void) { gu3 = ru() ^ gu1; }
void oe_ca_uxR(void) { gu3 = gu1 ^ ru(); }
void oe_un_unG(void) { gu3 = -gu1; }
void oe_un_unP(unsigned int a, unsigned int b) { gu3 = -a; }
void oe_un_ucG(void) { gu3 = ~gu1; }
void oe_un_ucP(unsigned int a, unsigned int b) { gu3 = ~a; }
void oe_un_utG(void) { gu3 = !gu1; }
void oe_un_utP(unsigned int a, unsigned int b) { gu3 = !a; }
void oe_oa_uaG(void) { gu1 += gu2; }
void oe_oa_uaL(void) { unsigned int t = gu1; t += gu2; gu3 = t; }
void oe_oa_uaP(unsigned int a, unsigned int b) { a += gu2; gu3 = a; }
void oe_oa_usG(void) { gu1 -= gu2; }
void oe_oa_usL(void) { unsigned int t = gu1; t -= gu2; gu3 = t; }
void oe_oa_usP(unsigned int a, unsigned int b) { a -= gu2; gu3 = a; }
void oe_oa_uxG(void) { gu1 ^= gu2; }
void oe_oa_uxL(void) { unsigned int t = gu1; t ^= gu2; gu3 = t; }
void oe_oa_uxP(unsigned int a, unsigned int b) { a ^= gu2; gu3 = a; }
void oe_oa_unG(void) { gu1 &= gu2; }
void oe_oa_unL(void) { unsigned int t = gu1; t &= gu2; gu3 = t; }
void oe_oa_unP(unsigned int a, unsigned int b) { a &= gu2; gu3 = a; }
void oe_oa_uoG(void) { gu1 |= gu2; }
void oe_oa_uoL(void) { unsigned int t = gu1; t |= gu2; gu3 = t; }
void oe_oa_uoP(unsigned int a, unsigned int b) { a |= gu2; gu3 = a; }
void oe_oa_ulG(void) { gu1 <<= 3; }
void oe_oa_ulL(void) { unsigned int t = gu1; t <<= 3; gu3 = t; }
void oe_oa_ulP(unsigned int a, unsigned int b) { a <<= 3; gu3 = a; }
void oe_oa_uhG(void) { gu1 >>= 3; }
void oe_oa_uhL(void) { unsigned int t = gu1; t >>= 3; gu3 = t; }
void oe_oa_uhP(unsigned int a, unsigned int b) { a >>= 3; gu3 = a; }
void oe_oa_umG(void) { gu1 *= 3; }
void oe_oa_umL(void) { unsigned int t = gu1; t *= 3; gu3 = t; }
void oe_oa_umP(unsigned int a, unsigned int b) { a *= 3; gu3 = a; }
void oe_oa_uiG(void) { gu1++; }
void oe_oa_uiL(void) { unsigned int t = gu1; t++; gu3 = t; }
void oe_oa_uiP(unsigned int a, unsigned int b) { a++; gu3 = a; }
void oe_oa_ujG(void) { gu1--; }
void oe_oa_ujL(void) { unsigned int t = gu1; t--; gu3 = t; }
void oe_oa_ujP(unsigned int a, unsigned int b) { a--; gu3 = a; }
unsigned int oe_rp_ua(unsigned int a, unsigned int b, unsigned int c) { return (a + b) ^ c; }
unsigned int oe_rp_us(unsigned int a, unsigned int b, unsigned int c) { return (a - b) ^ c; }
unsigned int oe_rp_un(unsigned int a, unsigned int b, unsigned int c) { return (a & b) ^ c; }
unsigned int oe_rp_uo(unsigned int a, unsigned int b, unsigned int c) { return (a | b) ^ c; }
unsigned int oe_rp_ux(unsigned int a, unsigned int b, unsigned int c) { return (a ^ b) + c; }
void oe_ck_ueT(void) { gu3 = (gu1 == 5 ? gu2 : gu1); }
int oe_ck_ueI(unsigned int a, unsigned int b) { if (a == 0) return 4; return 9; }
void oe_ck_unT(void) { gu3 = (gu1 != 5 ? gu2 : gu1); }
int oe_ck_unI(unsigned int a, unsigned int b) { if (a != 0) return 4; return 9; }
void oe_ck_ulT(void) { gu3 = (gu1 < 5 ? gu2 : gu1); }
int oe_ck_ulI(unsigned int a, unsigned int b) { if (a < 0) return 4; return 9; }
void oe_ck_ugT(void) { gu3 = (gu1 > 5 ? gu2 : gu1); }
int oe_ck_ugI(unsigned int a, unsigned int b) { if (a > 0) return 4; return 9; }
void oe_ck_uLT(void) { gu3 = (gu1 <= 5 ? gu2 : gu1); }
int oe_ck_uLI(unsigned int a, unsigned int b) { if (a <= 0) return 4; return 9; }
void oe_ck_uGT(void) { gu3 = (gu1 >= 5 ? gu2 : gu1); }
int oe_ck_uGI(unsigned int a, unsigned int b) { if (a >= 0) return 4; return 9; }
void oe_el_uaP(unsigned int a, unsigned int b) { gu3 = gua[a & 7] + gu2; }
void oe_el_uaS(unsigned int a, unsigned int b) { gua[b & 7] = gu1 + a; }
void oe_el_usP(unsigned int a, unsigned int b) { gu3 = gua[a & 7] - gu2; }
void oe_el_usS(unsigned int a, unsigned int b) { gua[b & 7] = gu1 - a; }
void oe_el_unP(unsigned int a, unsigned int b) { gu3 = gua[a & 7] & gu2; }
void oe_el_unS(unsigned int a, unsigned int b) { gua[b & 7] = gu1 & a; }
void oe_el_uoP(unsigned int a, unsigned int b) { gu3 = gua[a & 7] | gu2; }
void oe_el_uoS(unsigned int a, unsigned int b) { gua[b & 7] = gu1 | a; }
void oe_el_uxP(unsigned int a, unsigned int b) { gu3 = gua[a & 7] ^ gu2; }
void oe_el_uxS(unsigned int a, unsigned int b) { gua[b & 7] = gu1 ^ a; }
void oe_mx_ucA(void) { gc3 = gu1 + gc2; }
void oe_mx_ucX(void) { gu3 = gu1 ^ gc2; }
int oe_mx_ucC(void) { return gu1 < gc2; }
void oe_mx_ubA(void) { gb3 = gu1 + gb2; }
void oe_mx_ubX(void) { gu3 = gu1 ^ gb2; }
int oe_mx_ubC(void) { return gu1 < gb2; }
void oe_mx_uiA(void) { gi3 = gu1 + gi2; }
void oe_mx_uiX(void) { gu3 = gu1 ^ gi2; }
int oe_mx_uiC(void) { return gu1 < gi2; }
void oe_mx_ulA(void) { gl3 = gu1 + gl2; }
void oe_mx_ulX(void) { gu3 = gu1 ^ gl2; }
int oe_mx_ulC(void) { return gu1 < gl2; }
void oe_mx_unA(void) { gn3 = gu1 + gn2; }
void oe_mx_unX(void) { gu3 = gu1 ^ gn2; }
int oe_mx_unC(void) { return gu1 < gn2; }
void oe_pa_uS(void) { gs.c = (char)gu1; gs.i = (int)gu2; gs.l = (long)gu3; }
void oe_pa_uC(void) { unsigned int t = gu1; gu2 = t + gu3; }
void oe_pa_uR(void) { gu2 = gu1 + 1; gu3 = gu1; }
void oe_pa_uE(void) { gua[1] = gu1; gua[5] = gua[1] + gu2; }
void oe_pa_uA(void) { gps->i = (int)gu1; gps->i2 = gps->i + (int)gu2; }
void oe_pa_uW(void) { gu1 = gu2 * 3; gu3 = gu1 - gu2; }
void oe_ar_laG(void) { gl3 = gl1 + gl2; }
void oe_ar_laP(long a, long b) { gl3 = a + gl2; }
void oe_ar_laQ(long a, long b) { gl3 = a + b; }
void oe_ar_laK(void) { gl3 = gl1 + 5; }
void oe_ar_laC(void) { gl3 = 9 + gl1; }
void oe_ar_lsG(void) { gl3 = gl1 - gl2; }
void oe_ar_lsP(long a, long b) { gl3 = a - gl2; }
void oe_ar_lsQ(long a, long b) { gl3 = a - b; }
void oe_ar_lsK(void) { gl3 = gl1 - 5; }
void oe_ar_lsC(void) { gl3 = 9 - gl1; }
void oe_ar_ldG(void) { gl3 = gl1 / (gl2 & 0x7f | 1); }
void oe_ar_ldP(long a, long b) { gl3 = a / (gl2 & 0x7f | 1); }
void oe_ar_ldQ(long a, long b) { gl3 = a / (b & 0x7f | 1); }
void oe_ar_ldK(void) { gl3 = gl1 / 5; }
void oe_ar_ldC(void) { gl3 = 9 / (gl1 & 0x7f | 1); }
void oe_ar_lrG(void) { gl3 = gl1 % (gl2 & 0x7f | 1); }
void oe_ar_lrP(long a, long b) { gl3 = a % (gl2 & 0x7f | 1); }
void oe_ar_lrQ(long a, long b) { gl3 = a % (b & 0x7f | 1); }
void oe_ar_lrK(void) { gl3 = gl1 % 5; }
void oe_ar_lrC(void) { gl3 = 9 % (gl1 & 0x7f | 1); }
void oe_ar_lnG(void) { gl3 = gl1 & gl2; }
void oe_ar_lnP(long a, long b) { gl3 = a & gl2; }
void oe_ar_lnQ(long a, long b) { gl3 = a & b; }
void oe_ar_lnK(void) { gl3 = gl1 & 5; }
void oe_ar_lnC(void) { gl3 = 9 & gl1; }
void oe_ar_loG(void) { gl3 = gl1 | gl2; }
void oe_ar_loP(long a, long b) { gl3 = a | gl2; }
void oe_ar_loQ(long a, long b) { gl3 = a | b; }
void oe_ar_loK(void) { gl3 = gl1 | 5; }
void oe_ar_loC(void) { gl3 = 9 | gl1; }
void oe_ar_lxG(void) { gl3 = gl1 ^ gl2; }
void oe_ar_lxP(long a, long b) { gl3 = a ^ gl2; }
void oe_ar_lxQ(long a, long b) { gl3 = a ^ b; }
void oe_ar_lxK(void) { gl3 = gl1 ^ 5; }
void oe_ar_lxC(void) { gl3 = 9 ^ gl1; }
void oe_ar_lhG(void) { gl3 = gl1 >> 3; }
void oe_ar_lhP(long a, long b) { gl3 = a >> 3; }
void oe_ar_lLG(void) { gl3 = gl1 << (gl2 & 31); }
void oe_ar_lLP(long a, long b) { gl3 = a << (gl2 & 31); }
void oe_ar_lHG(void) { gl3 = gl1 >> (gl2 & 31); }
void oe_ar_lHP(long a, long b) { gl3 = a >> (gl2 & 31); }
void oe_cm_leT(void) { gl3 = (gl1 == gl2 ? gl1 : 7); }
void oe_cm_leI(void) { if (gl1 == gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_leR(long a, long b) { return (a == gl2 ? 1 : 2); }
int oe_cm_leB(long a, long b) { return a == b; }
void oe_cm_lnT(void) { gl3 = (gl1 != gl2 ? gl1 : 7); }
void oe_cm_lnI(void) { if (gl1 != gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_lnR(long a, long b) { return (a != gl2 ? 1 : 2); }
int oe_cm_lnB(long a, long b) { return a != b; }
void oe_cm_llT(void) { gl3 = (gl1 < gl2 ? gl1 : 7); }
void oe_cm_llI(void) { if (gl1 < gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_llR(long a, long b) { return (a < gl2 ? 1 : 2); }
int oe_cm_llB(long a, long b) { return a < b; }
void oe_cm_lgT(void) { gl3 = (gl1 > gl2 ? gl1 : 7); }
void oe_cm_lgI(void) { if (gl1 > gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_lgR(long a, long b) { return (a > gl2 ? 1 : 2); }
int oe_cm_lgB(long a, long b) { return a > b; }
void oe_cm_lLT(void) { gl3 = (gl1 <= gl2 ? gl1 : 7); }
void oe_cm_lLI(void) { if (gl1 <= gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_lLR(long a, long b) { return (a <= gl2 ? 1 : 2); }
int oe_cm_lLB(long a, long b) { return a <= b; }
void oe_cm_lGT(void) { gl3 = (gl1 >= gl2 ? gl1 : 7); }
void oe_cm_lGI(void) { if (gl1 >= gl2) gl3 = gl1; else gl3 = 3; }
int oe_cm_lGR(long a, long b) { return (a >= gl2 ? 1 : 2); }
int oe_cm_lGB(long a, long b) { return a >= b; }
void oe_lg_laT(void) { gl3 = (gl1 > 3 && gl2 != 0); }
void oe_lg_laI(void) { if (gl1 > 3 && gl2 != 0) gl3 = 1; else gl3 = 2; }
int oe_lg_laR(long a, long b) { return (a > 3 && b != 0); }
void oe_lg_loT(void) { gl3 = (gl1 > 3 || gl2 != 0); }
void oe_lg_loI(void) { if (gl1 > 3 || gl2 != 0) gl3 = 1; else gl3 = 2; }
int oe_lg_loR(long a, long b) { return (a > 3 || b != 0); }
void oe_cs_lc(void) { gc3 = (char)gl1; }
void oe_cs_lb(void) { gb3 = (unsigned char)gl1; }
void oe_cs_li(void) { gi3 = (int)gl1; }
void oe_cs_lu(void) { gu3 = (unsigned int)gl1; }
void oe_cs_ln(void) { gn3 = (unsigned long)gl1; }
void oe_ca_laL(void) { gl3 = rl() + gl1; }
void oe_ca_laR(void) { gl3 = gl1 + rl(); }
void oe_ca_lsL(void) { gl3 = rl() - gl1; }
void oe_ca_lsR(void) { gl3 = gl1 - rl(); }
void oe_ca_lxL(void) { gl3 = rl() ^ gl1; }
void oe_ca_lxR(void) { gl3 = gl1 ^ rl(); }
void oe_un_lnG(void) { gl3 = -gl1; }
void oe_un_lnP(long a, long b) { gl3 = -a; }
void oe_un_lcG(void) { gl3 = ~gl1; }
void oe_un_lcP(long a, long b) { gl3 = ~a; }
void oe_un_ltG(void) { gl3 = !gl1; }
void oe_un_ltP(long a, long b) { gl3 = !a; }
void oe_oa_laG(void) { gl1 += gl2; }
void oe_oa_laL(void) { long t = gl1; t += gl2; gl3 = t; }
void oe_oa_laP(long a, long b) { a += gl2; gl3 = a; }
void oe_oa_lsG(void) { gl1 -= gl2; }
void oe_oa_lsL(void) { long t = gl1; t -= gl2; gl3 = t; }
void oe_oa_lsP(long a, long b) { a -= gl2; gl3 = a; }
void oe_oa_lxG(void) { gl1 ^= gl2; }
void oe_oa_lxL(void) { long t = gl1; t ^= gl2; gl3 = t; }
void oe_oa_lxP(long a, long b) { a ^= gl2; gl3 = a; }
void oe_oa_lnG(void) { gl1 &= gl2; }
void oe_oa_lnL(void) { long t = gl1; t &= gl2; gl3 = t; }
void oe_oa_lnP(long a, long b) { a &= gl2; gl3 = a; }
void oe_oa_loG(void) { gl1 |= gl2; }
void oe_oa_loL(void) { long t = gl1; t |= gl2; gl3 = t; }
void oe_oa_loP(long a, long b) { a |= gl2; gl3 = a; }
void oe_oa_lhG(void) { gl1 >>= 3; }
void oe_oa_lhL(void) { long t = gl1; t >>= 3; gl3 = t; }
void oe_oa_lhP(long a, long b) { a >>= 3; gl3 = a; }
void oe_oa_liG(void) { gl1++; }
void oe_oa_liL(void) { long t = gl1; t++; gl3 = t; }
void oe_oa_liP(long a, long b) { a++; gl3 = a; }
void oe_oa_ljG(void) { gl1--; }
void oe_oa_ljL(void) { long t = gl1; t--; gl3 = t; }
void oe_oa_ljP(long a, long b) { a--; gl3 = a; }
long oe_rp_la(long a, long b, long c) { return (a + b) ^ c; }
long oe_rp_ls(long a, long b, long c) { return (a - b) ^ c; }
long oe_rp_ln(long a, long b, long c) { return (a & b) ^ c; }
long oe_rp_lo(long a, long b, long c) { return (a | b) ^ c; }
long oe_rp_lx(long a, long b, long c) { return (a ^ b) + c; }
void oe_ck_leT(void) { gl3 = (gl1 == 5 ? gl2 : gl1); }
int oe_ck_leI(long a, long b) { if (a == 0) return 4; return 9; }
void oe_ck_lnT(void) { gl3 = (gl1 != 5 ? gl2 : gl1); }
int oe_ck_lnI(long a, long b) { if (a != 0) return 4; return 9; }
void oe_ck_llT(void) { gl3 = (gl1 < 5 ? gl2 : gl1); }
int oe_ck_llI(long a, long b) { if (a < 0) return 4; return 9; }
void oe_ck_lgT(void) { gl3 = (gl1 > 5 ? gl2 : gl1); }
int oe_ck_lgI(long a, long b) { if (a > 0) return 4; return 9; }
void oe_ck_lLT(void) { gl3 = (gl1 <= 5 ? gl2 : gl1); }
int oe_ck_lLI(long a, long b) { if (a <= 0) return 4; return 9; }
void oe_ck_lGT(void) { gl3 = (gl1 >= 5 ? gl2 : gl1); }
int oe_ck_lGI(long a, long b) { if (a >= 0) return 4; return 9; }
void oe_el_laP(long a, long b) { gl3 = gla[a & 7] + gl2; }
void oe_el_laS(long a, long b) { gla[b & 7] = gl1 + a; }
void oe_el_lsP(long a, long b) { gl3 = gla[a & 7] - gl2; }
void oe_el_lsS(long a, long b) { gla[b & 7] = gl1 - a; }
void oe_el_lnP(long a, long b) { gl3 = gla[a & 7] & gl2; }
void oe_el_lnS(long a, long b) { gla[b & 7] = gl1 & a; }
void oe_el_loP(long a, long b) { gl3 = gla[a & 7] | gl2; }
void oe_el_loS(long a, long b) { gla[b & 7] = gl1 | a; }
void oe_el_lxP(long a, long b) { gl3 = gla[a & 7] ^ gl2; }
void oe_el_lxS(long a, long b) { gla[b & 7] = gl1 ^ a; }
void oe_mx_lcA(void) { gc3 = gl1 + gc2; }
void oe_mx_lcX(void) { gl3 = gl1 ^ gc2; }
int oe_mx_lcC(void) { return gl1 < gc2; }
void oe_mx_lbA(void) { gb3 = gl1 + gb2; }
void oe_mx_lbX(void) { gl3 = gl1 ^ gb2; }
int oe_mx_lbC(void) { return gl1 < gb2; }
void oe_mx_liA(void) { gi3 = gl1 + gi2; }
void oe_mx_liX(void) { gl3 = gl1 ^ gi2; }
int oe_mx_liC(void) { return gl1 < gi2; }
void oe_mx_luA(void) { gu3 = gl1 + gu2; }
void oe_mx_luX(void) { gl3 = gl1 ^ gu2; }
int oe_mx_luC(void) { return gl1 < gu2; }
void oe_mx_lnA(void) { gn3 = gl1 + gn2; }
void oe_mx_lnX(void) { gl3 = gl1 ^ gn2; }
int oe_mx_lnC(void) { return gl1 < gn2; }
void oe_pa_lS(void) { gs.c = (char)gl1; gs.i = (int)gl2; gs.l = (long)gl3; }
void oe_pa_lC(void) { long t = gl1; gl2 = t + gl3; }
void oe_pa_lR(void) { gl2 = gl1 + 1; gl3 = gl1; }
void oe_pa_lE(void) { gla[1] = gl1; gla[5] = gla[1] + gl2; }
void oe_pa_lA(void) { gps->i = (int)gl1; gps->i2 = gps->i + (int)gl2; }
void oe_pa_lW(void) { gl1 = gl2 + 3; gl3 = gl1 - gl2; }
void oe_ar_naG(void) { gn3 = gn1 + gn2; }
void oe_ar_naP(unsigned long a, unsigned long b) { gn3 = a + gn2; }
void oe_ar_naQ(unsigned long a, unsigned long b) { gn3 = a + b; }
void oe_ar_naK(void) { gn3 = gn1 + 5; }
void oe_ar_naC(void) { gn3 = 9 + gn1; }
void oe_ar_nsG(void) { gn3 = gn1 - gn2; }
void oe_ar_nsP(unsigned long a, unsigned long b) { gn3 = a - gn2; }
void oe_ar_nsQ(unsigned long a, unsigned long b) { gn3 = a - b; }
void oe_ar_nsK(void) { gn3 = gn1 - 5; }
void oe_ar_nsC(void) { gn3 = 9 - gn1; }
void oe_ar_nmG(void) { gn3 = gn1 * gn2; }
void oe_ar_nmP(unsigned long a, unsigned long b) { gn3 = a * gn2; }
void oe_ar_nmQ(unsigned long a, unsigned long b) { gn3 = a * b; }
void oe_ar_nmK(void) { gn3 = gn1 * 5; }
void oe_ar_nmC(void) { gn3 = 9 * gn1; }
void oe_ar_ndG(void) { gn3 = gn1 / (gn2 | 1); }
void oe_ar_ndP(unsigned long a, unsigned long b) { gn3 = a / (gn2 | 1); }
void oe_ar_ndQ(unsigned long a, unsigned long b) { gn3 = a / (b | 1); }
void oe_ar_ndK(void) { gn3 = gn1 / 5; }
void oe_ar_ndC(void) { gn3 = 9 / (gn1 | 1); }
void oe_ar_nrG(void) { gn3 = gn1 % (gn2 | 1); }
void oe_ar_nrP(unsigned long a, unsigned long b) { gn3 = a % (gn2 | 1); }
void oe_ar_nrQ(unsigned long a, unsigned long b) { gn3 = a % (b | 1); }
void oe_ar_nrK(void) { gn3 = gn1 % 5; }
void oe_ar_nrC(void) { gn3 = 9 % (gn1 | 1); }
void oe_ar_nnG(void) { gn3 = gn1 & gn2; }
void oe_ar_nnP(unsigned long a, unsigned long b) { gn3 = a & gn2; }
void oe_ar_nnQ(unsigned long a, unsigned long b) { gn3 = a & b; }
void oe_ar_nnK(void) { gn3 = gn1 & 5; }
void oe_ar_nnC(void) { gn3 = 9 & gn1; }
void oe_ar_noG(void) { gn3 = gn1 | gn2; }
void oe_ar_noP(unsigned long a, unsigned long b) { gn3 = a | gn2; }
void oe_ar_noQ(unsigned long a, unsigned long b) { gn3 = a | b; }
void oe_ar_noK(void) { gn3 = gn1 | 5; }
void oe_ar_noC(void) { gn3 = 9 | gn1; }
void oe_ar_nxG(void) { gn3 = gn1 ^ gn2; }
void oe_ar_nxP(unsigned long a, unsigned long b) { gn3 = a ^ gn2; }
void oe_ar_nxQ(unsigned long a, unsigned long b) { gn3 = a ^ b; }
void oe_ar_nxK(void) { gn3 = gn1 ^ 5; }
void oe_ar_nxC(void) { gn3 = 9 ^ gn1; }
void oe_ar_nlG(void) { gn3 = gn1 << 3; }
void oe_ar_nlP(unsigned long a, unsigned long b) { gn3 = a << 3; }
void oe_ar_nhG(void) { gn3 = gn1 >> 3; }
void oe_ar_nhP(unsigned long a, unsigned long b) { gn3 = a >> 3; }
void oe_ar_nLG(void) { gn3 = gn1 << (gn2 & 31); }
void oe_ar_nLP(unsigned long a, unsigned long b) { gn3 = a << (gn2 & 31); }
void oe_ar_nHG(void) { gn3 = gn1 >> (gn2 & 31); }
void oe_ar_nHP(unsigned long a, unsigned long b) { gn3 = a >> (gn2 & 31); }
void oe_cm_neT(void) { gn3 = (gn1 == gn2 ? gn1 : 7); }
void oe_cm_neI(void) { if (gn1 == gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_neR(unsigned long a, unsigned long b) { return (a == gn2 ? 1 : 2); }
int oe_cm_neB(unsigned long a, unsigned long b) { return a == b; }
void oe_cm_nnT(void) { gn3 = (gn1 != gn2 ? gn1 : 7); }
void oe_cm_nnI(void) { if (gn1 != gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_nnR(unsigned long a, unsigned long b) { return (a != gn2 ? 1 : 2); }
int oe_cm_nnB(unsigned long a, unsigned long b) { return a != b; }
void oe_cm_nlT(void) { gn3 = (gn1 < gn2 ? gn1 : 7); }
void oe_cm_nlI(void) { if (gn1 < gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_nlR(unsigned long a, unsigned long b) { return (a < gn2 ? 1 : 2); }
int oe_cm_nlB(unsigned long a, unsigned long b) { return a < b; }
void oe_cm_ngT(void) { gn3 = (gn1 > gn2 ? gn1 : 7); }
void oe_cm_ngI(void) { if (gn1 > gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_ngR(unsigned long a, unsigned long b) { return (a > gn2 ? 1 : 2); }
int oe_cm_ngB(unsigned long a, unsigned long b) { return a > b; }
void oe_cm_nLT(void) { gn3 = (gn1 <= gn2 ? gn1 : 7); }
void oe_cm_nLI(void) { if (gn1 <= gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_nLR(unsigned long a, unsigned long b) { return (a <= gn2 ? 1 : 2); }
int oe_cm_nLB(unsigned long a, unsigned long b) { return a <= b; }
void oe_cm_nGT(void) { gn3 = (gn1 >= gn2 ? gn1 : 7); }
void oe_cm_nGI(void) { if (gn1 >= gn2) gn3 = gn1; else gn3 = 3; }
int oe_cm_nGR(unsigned long a, unsigned long b) { return (a >= gn2 ? 1 : 2); }
int oe_cm_nGB(unsigned long a, unsigned long b) { return a >= b; }
void oe_lg_naT(void) { gn3 = (gn1 > 3 && gn2 != 0); }
void oe_lg_naI(void) { if (gn1 > 3 && gn2 != 0) gn3 = 1; else gn3 = 2; }
int oe_lg_naR(unsigned long a, unsigned long b) { return (a > 3 && b != 0); }
void oe_lg_noT(void) { gn3 = (gn1 > 3 || gn2 != 0); }
void oe_lg_noI(void) { if (gn1 > 3 || gn2 != 0) gn3 = 1; else gn3 = 2; }
int oe_lg_noR(unsigned long a, unsigned long b) { return (a > 3 || b != 0); }
void oe_cs_nc(void) { gc3 = (char)gn1; }
void oe_cs_nb(void) { gb3 = (unsigned char)gn1; }
void oe_cs_ni(void) { gi3 = (int)gn1; }
void oe_cs_nu(void) { gu3 = (unsigned int)gn1; }
void oe_cs_nl(void) { gl3 = (long)gn1; }
void oe_ca_naL(void) { gn3 = rn() + gn1; }
void oe_ca_naR(void) { gn3 = gn1 + rn(); }
void oe_ca_nsL(void) { gn3 = rn() - gn1; }
void oe_ca_nsR(void) { gn3 = gn1 - rn(); }
void oe_ca_nmL(void) { gn3 = rn() * gn1; }
void oe_ca_nmR(void) { gn3 = gn1 * rn(); }
void oe_ca_nxL(void) { gn3 = rn() ^ gn1; }
void oe_ca_nxR(void) { gn3 = gn1 ^ rn(); }
void oe_un_nnG(void) { gn3 = -gn1; }
void oe_un_nnP(unsigned long a, unsigned long b) { gn3 = -a; }
void oe_un_ncG(void) { gn3 = ~gn1; }
void oe_un_ncP(unsigned long a, unsigned long b) { gn3 = ~a; }
void oe_un_ntG(void) { gn3 = !gn1; }
void oe_un_ntP(unsigned long a, unsigned long b) { gn3 = !a; }
void oe_oa_naG(void) { gn1 += gn2; }
void oe_oa_naL(void) { unsigned long t = gn1; t += gn2; gn3 = t; }
void oe_oa_naP(unsigned long a, unsigned long b) { a += gn2; gn3 = a; }
void oe_oa_nsG(void) { gn1 -= gn2; }
void oe_oa_nsL(void) { unsigned long t = gn1; t -= gn2; gn3 = t; }
void oe_oa_nsP(unsigned long a, unsigned long b) { a -= gn2; gn3 = a; }
void oe_oa_nxG(void) { gn1 ^= gn2; }
void oe_oa_nxL(void) { unsigned long t = gn1; t ^= gn2; gn3 = t; }
void oe_oa_nxP(unsigned long a, unsigned long b) { a ^= gn2; gn3 = a; }
void oe_oa_nnG(void) { gn1 &= gn2; }
void oe_oa_nnL(void) { unsigned long t = gn1; t &= gn2; gn3 = t; }
void oe_oa_nnP(unsigned long a, unsigned long b) { a &= gn2; gn3 = a; }
void oe_oa_noG(void) { gn1 |= gn2; }
void oe_oa_noL(void) { unsigned long t = gn1; t |= gn2; gn3 = t; }
void oe_oa_noP(unsigned long a, unsigned long b) { a |= gn2; gn3 = a; }
void oe_oa_nlG(void) { gn1 <<= 3; }
void oe_oa_nlL(void) { unsigned long t = gn1; t <<= 3; gn3 = t; }
void oe_oa_nlP(unsigned long a, unsigned long b) { a <<= 3; gn3 = a; }
void oe_oa_nhG(void) { gn1 >>= 3; }
void oe_oa_nhL(void) { unsigned long t = gn1; t >>= 3; gn3 = t; }
void oe_oa_nhP(unsigned long a, unsigned long b) { a >>= 3; gn3 = a; }
void oe_oa_nmG(void) { gn1 *= 3; }
void oe_oa_nmL(void) { unsigned long t = gn1; t *= 3; gn3 = t; }
void oe_oa_nmP(unsigned long a, unsigned long b) { a *= 3; gn3 = a; }
void oe_oa_niG(void) { gn1++; }
void oe_oa_niL(void) { unsigned long t = gn1; t++; gn3 = t; }
void oe_oa_niP(unsigned long a, unsigned long b) { a++; gn3 = a; }
void oe_oa_njG(void) { gn1--; }
void oe_oa_njL(void) { unsigned long t = gn1; t--; gn3 = t; }
void oe_oa_njP(unsigned long a, unsigned long b) { a--; gn3 = a; }
unsigned long oe_rp_na(unsigned long a, unsigned long b, unsigned long c) { return (a + b) ^ c; }
unsigned long oe_rp_ns(unsigned long a, unsigned long b, unsigned long c) { return (a - b) ^ c; }
unsigned long oe_rp_nn(unsigned long a, unsigned long b, unsigned long c) { return (a & b) ^ c; }
unsigned long oe_rp_no(unsigned long a, unsigned long b, unsigned long c) { return (a | b) ^ c; }
unsigned long oe_rp_nx(unsigned long a, unsigned long b, unsigned long c) { return (a ^ b) + c; }
void oe_ck_neT(void) { gn3 = (gn1 == 5 ? gn2 : gn1); }
int oe_ck_neI(unsigned long a, unsigned long b) { if (a == 0) return 4; return 9; }
void oe_ck_nnT(void) { gn3 = (gn1 != 5 ? gn2 : gn1); }
int oe_ck_nnI(unsigned long a, unsigned long b) { if (a != 0) return 4; return 9; }
void oe_ck_nlT(void) { gn3 = (gn1 < 5 ? gn2 : gn1); }
int oe_ck_nlI(unsigned long a, unsigned long b) { if (a < 0) return 4; return 9; }
void oe_ck_ngT(void) { gn3 = (gn1 > 5 ? gn2 : gn1); }
int oe_ck_ngI(unsigned long a, unsigned long b) { if (a > 0) return 4; return 9; }
void oe_ck_nLT(void) { gn3 = (gn1 <= 5 ? gn2 : gn1); }
int oe_ck_nLI(unsigned long a, unsigned long b) { if (a <= 0) return 4; return 9; }
void oe_ck_nGT(void) { gn3 = (gn1 >= 5 ? gn2 : gn1); }
int oe_ck_nGI(unsigned long a, unsigned long b) { if (a >= 0) return 4; return 9; }
void oe_el_naP(unsigned long a, unsigned long b) { gn3 = gna[a & 7] + gn2; }
void oe_el_naS(unsigned long a, unsigned long b) { gna[b & 7] = gn1 + a; }
void oe_el_nsP(unsigned long a, unsigned long b) { gn3 = gna[a & 7] - gn2; }
void oe_el_nsS(unsigned long a, unsigned long b) { gna[b & 7] = gn1 - a; }
void oe_el_nnP(unsigned long a, unsigned long b) { gn3 = gna[a & 7] & gn2; }
void oe_el_nnS(unsigned long a, unsigned long b) { gna[b & 7] = gn1 & a; }
void oe_el_noP(unsigned long a, unsigned long b) { gn3 = gna[a & 7] | gn2; }
void oe_el_noS(unsigned long a, unsigned long b) { gna[b & 7] = gn1 | a; }
void oe_el_nxP(unsigned long a, unsigned long b) { gn3 = gna[a & 7] ^ gn2; }
void oe_el_nxS(unsigned long a, unsigned long b) { gna[b & 7] = gn1 ^ a; }
void oe_mx_ncA(void) { gc3 = gn1 + gc2; }
void oe_mx_ncX(void) { gn3 = gn1 ^ gc2; }
int oe_mx_ncC(void) { return gn1 < gc2; }
void oe_mx_nbA(void) { gb3 = gn1 + gb2; }
void oe_mx_nbX(void) { gn3 = gn1 ^ gb2; }
int oe_mx_nbC(void) { return gn1 < gb2; }
void oe_mx_niA(void) { gi3 = gn1 + gi2; }
void oe_mx_niX(void) { gn3 = gn1 ^ gi2; }
int oe_mx_niC(void) { return gn1 < gi2; }
void oe_mx_nuA(void) { gu3 = gn1 + gu2; }
void oe_mx_nuX(void) { gn3 = gn1 ^ gu2; }
int oe_mx_nuC(void) { return gn1 < gu2; }
void oe_mx_nlA(void) { gl3 = gn1 + gl2; }
void oe_mx_nlX(void) { gn3 = gn1 ^ gl2; }
int oe_mx_nlC(void) { return gn1 < gl2; }
void oe_pa_nS(void) { gs.c = (char)gn1; gs.i = (int)gn2; gs.l = (long)gn3; }
void oe_pa_nC(void) { unsigned long t = gn1; gn2 = t + gn3; }
void oe_pa_nR(void) { gn2 = gn1 + 1; gn3 = gn1; }
void oe_pa_nE(void) { gna[1] = gn1; gna[5] = gna[1] + gn2; }
void oe_pa_nA(void) { gps->i = (int)gn1; gps->i2 = gps->i + (int)gn2; }
void oe_pa_nW(void) { gn1 = gn2 * 3; gn3 = gn1 - gn2; }
