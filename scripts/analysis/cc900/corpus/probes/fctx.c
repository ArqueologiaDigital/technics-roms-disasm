/* lane_o3 wrong-code probe: multi-statement context; see gen_fctx.py for the name letters */
extern char gc1, gc2, gc3, gca[8], gcb[8], *gcp;
extern void vc(char); extern char rc(void); extern void wc(char, char);
extern unsigned char gb1, gb2, gb3, gba[8], gbb[8], *gbp;
extern void vb(unsigned char); extern unsigned char rb(void); extern void wb(unsigned char, unsigned char);
extern int gi1, gi2, gi3, gia[8], gib[8], *gip;
extern void vi(int); extern int ri(void); extern void wi(int, int);
extern unsigned int gu1, gu2, gu3, gua[8], gub[8], *gup;
extern void vu(unsigned int); extern unsigned int ru(void); extern void wu(unsigned int, unsigned int);
extern long gl1, gl2, gl3, gla[8], glb[8], *glp;
extern void vl(long); extern long rl(void); extern void wl(long, long);
extern unsigned long gn1, gn2, gn3, gna[8], gnb[8], *gnp;
extern void vn(unsigned long); extern unsigned long rn(void); extern void wn(unsigned long, unsigned long);
struct sv { char c; unsigned char b; int i; unsigned int u; long l; unsigned long n; int a[4]; };
extern struct sv gs, *gps;
extern void v0(void); extern int ri(void);
extern long gl4; extern unsigned long gn4;
void fx_lc_c0(void) { char t = gc1 + gc2; v0(); gc3 = t ^ gc1; }
void fx_lc_c1(void) { char t = gc1 ^ gc2; vc(t); gc3 = t + gc2; }
void fx_lc_c2(void) { char t = gc1 - gc2; gc2 = rc(); gc3 = t | gc2; }
void fx_lc_c3(void) { char t = gc1 & gc2; v0(); vc(gc1); gc3 = t; }
void fx_lc_c4(void) { char t = gc1; gc2 = t + gc2; v0(); gc3 = t - gc2; }
void fx_lh_c0(void) { char t = gc1 + 1; gn4 = gn1 * gn2; gc3 = t ^ gc2; }
void fx_lh_c1(void) { char t = gc1 ^ gc2; gl4 = gl1 / (gl2 & 0x7fff | 1); gc3 = t; }
void fx_lh_c2(void) { char t = gc1 | 3; gn4 = gn1 % (gn2 | 1); gc3 = t + gc1; }
void fx_lh_c3(void) { char t = gc1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gc3 = t - gc2; }
void fx_lh_c4(void) { char t = gc1 & gc2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gc3 = t ^ gc1; }
void fx_lp_c0(void) { char t = gc1; int i; char s = 0; for (i = 0; i < 8; i++) s += gca[i]; gc3 = t ^ s; }
void fx_lp_c1(void) { char t = gc1 + gc2; int n = 5; while (n-- > 0) gc2 ^= gc1; gc3 = t; }
void fx_lp_c2(void) { char t = gc2; int n = 0; do { gcb[n] = t; n++; } while (n < 6); gc3 = t + gc1; }
void fx_lp_c3(void) { char t = gc1 | gc2; int i; for (i = 0; i < 4; i++) vc(gca[i]); gc3 = t; }
char fx_lp_c4(void) { char t = gc1; int i; for (i = 0; i < 8; i++) t ^= gca[i]; return t; }
char fx_rp_c0(char a, char b) { v0(); return a + b; }
char fx_rp_c1(char a, char b) { vc(a); return a ^ b; }
char fx_rp_c2(char a, char b, char c) { vc(b); v0(); return (a - c) | b; }
char fx_rp_c3(char a, char b) { gc1 = rc(); a += b; return a ^ gc1; }
int fx_rp_c4(char a, char b) { v0(); if (a > b) return 1; return 2; }
char fx_lo_c0(void) { char s = 0; int i; for (i = 0; i < 8; i++) s += gca[i]; return s; }
char fx_lo_c1(void) { char s = gc1; int n = 7; while (n > 0) { s ^= gca[n]; n--; } return s; }
char fx_lo_c2(void) { char *p = gca; char s = 0; while (p < gca + 8) s += *p++; return s; }
void fx_lo_c3(void) { int i = 0; do { gcb[i] = gca[i] ^ gc1; i++; } while (i < 8); gc3 = gcb[7]; }
char fx_lo_c4(void) { char s = 0; int i; for (i = 0; i < 8; i++) s += gca[i] & gcb[i]; return s; }
void fx_lo_c5(void) { int i; for (i = 0; i < 8; i++) gcb[i] = gc1 + gca[i]; gc3 = gcb[3]; }
void fx_ie_c0(void) { char t; if (gc1 > gc2) t = gc1; else t = gc2; gc3 = t; }
void fx_ie_c1(void) { char t; if (gc1 > gc2) t = gc1; else if (gc1 == gc2) t = 5; else t = gc2; gc3 = t + gc1; }
void fx_ie_c2(void) { char t; if (gc1 != 0) t = rc(); else t = gc2; gc3 = t ^ gc1; }
void fx_ie_c3(void) { char t = gc2; if (gc1 > 2) { if (gc1 < gc2) t = gc1; else t = 9; } gc3 = t; }
int fx_ie_c4(void) { char t; if (gc1 > gc2) t = gc1; else t = gc2; if (t == gc3) return 1; return 0; }
int fx_rl_c0(void) { int i; for (i = 0; i < 8; i++) if (gca[i] == gc1) return i; return 9; }
char fx_rl_c1(void) { int i; for (i = 0; i < 8; i++) if (gca[i] > gc1) return gca[i]; return gc2; }
int fx_rl_c2(char a) { int i; for (i = 0; i < 8; i++) { if (gca[i] == a) return i; gcb[i] = a; } return 9; }
int fx_rl_c3(void) { int i = 0; while (i < 8) { if (gca[i] != gcb[i]) return i; i++; } return 9; }
char fx_rl_c4(void) { char s = 0; int i; for (i = 0; i < 8; i++) { s = gca[i]; if (s == gc1) break; } return s; }
void fx_ss_c0(void) { gca[1] = gc1; gca[2] = gc2; gca[3] = gca[1] ^ gca[2]; }
void fx_ss_c1(void) { gs.c = gc1; gs.i = gi1; gs.l = gl1; gc3 = gs.c; }
void fx_ss_c2(void) { gps->c = gc1; gps->i = gi2; gps->a[2] = gi1; gc3 = gps->c; }
void fx_ss_c3(struct sv *p) { p->c = gc1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gc3 = p->c; }
void fx_ss_c4(void) { gcp[1] = gc1; gcp[4] = gc2; gc3 = gcp[1] + gcp[4]; }
char fx_ss_c5(void) { gca[5] = gc1 + gc2; gca[6] = gca[5] ^ gc1; return gca[6]; }
void fx_cv_c0(void) { char t = gc1 ^ gc2; vc(gc3); gc2 = t; }
char fx_cv_c1(void) { char t = gc1 + gc2; v0(); return t; }
int fx_cv_c2(void) { char t = gc1; gc2 = rc(); return t == gc2; }
void fx_cv_c3(void) { char t = gc1 - gc2; v0(); wc(t, gc1); }
char fx_cv_c4(void) { char t = gc1 | gc2; return t ^ rc(); }
void fx_lc_b0(void) { unsigned char t = gb1 + gb2; v0(); gb3 = t ^ gb1; }
void fx_lc_b1(void) { unsigned char t = gb1 ^ gb2; vb(t); gb3 = t + gb2; }
void fx_lc_b2(void) { unsigned char t = gb1 - gb2; gb2 = rb(); gb3 = t | gb2; }
void fx_lc_b3(void) { unsigned char t = gb1 & gb2; v0(); vb(gb1); gb3 = t; }
void fx_lc_b4(void) { unsigned char t = gb1; gb2 = t + gb2; v0(); gb3 = t - gb2; }
void fx_lh_b0(void) { unsigned char t = gb1 + 1; gn4 = gn1 * gn2; gb3 = t ^ gb2; }
void fx_lh_b1(void) { unsigned char t = gb1 ^ gb2; gl4 = gl1 / (gl2 & 0x7fff | 1); gb3 = t; }
void fx_lh_b2(void) { unsigned char t = gb1 | 3; gn4 = gn1 % (gn2 | 1); gb3 = t + gb1; }
void fx_lh_b3(void) { unsigned char t = gb1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gb3 = t - gb2; }
void fx_lh_b4(void) { unsigned char t = gb1 & gb2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gb3 = t ^ gb1; }
void fx_lp_b0(void) { unsigned char t = gb1; int i; unsigned char s = 0; for (i = 0; i < 8; i++) s += gba[i]; gb3 = t ^ s; }
void fx_lp_b1(void) { unsigned char t = gb1 + gb2; int n = 5; while (n-- > 0) gb2 ^= gb1; gb3 = t; }
void fx_lp_b2(void) { unsigned char t = gb2; int n = 0; do { gbb[n] = t; n++; } while (n < 6); gb3 = t + gb1; }
void fx_lp_b3(void) { unsigned char t = gb1 | gb2; int i; for (i = 0; i < 4; i++) vb(gba[i]); gb3 = t; }
unsigned char fx_lp_b4(void) { unsigned char t = gb1; int i; for (i = 0; i < 8; i++) t ^= gba[i]; return t; }
unsigned char fx_rp_b0(unsigned char a, unsigned char b) { v0(); return a + b; }
unsigned char fx_rp_b1(unsigned char a, unsigned char b) { vb(a); return a ^ b; }
unsigned char fx_rp_b2(unsigned char a, unsigned char b, unsigned char c) { vb(b); v0(); return (a - c) | b; }
unsigned char fx_rp_b3(unsigned char a, unsigned char b) { gb1 = rb(); a += b; return a ^ gb1; }
int fx_rp_b4(unsigned char a, unsigned char b) { v0(); if (a > b) return 1; return 2; }
unsigned char fx_lo_b0(void) { unsigned char s = 0; int i; for (i = 0; i < 8; i++) s += gba[i]; return s; }
unsigned char fx_lo_b1(void) { unsigned char s = gb1; int n = 7; while (n > 0) { s ^= gba[n]; n--; } return s; }
unsigned char fx_lo_b2(void) { unsigned char *p = gba; unsigned char s = 0; while (p < gba + 8) s += *p++; return s; }
void fx_lo_b3(void) { int i = 0; do { gbb[i] = gba[i] ^ gb1; i++; } while (i < 8); gb3 = gbb[7]; }
unsigned char fx_lo_b4(void) { unsigned char s = 0; int i; for (i = 0; i < 8; i++) s += gba[i] & gbb[i]; return s; }
void fx_lo_b5(void) { int i; for (i = 0; i < 8; i++) gbb[i] = gb1 + gba[i]; gb3 = gbb[3]; }
void fx_ie_b0(void) { unsigned char t; if (gb1 > gb2) t = gb1; else t = gb2; gb3 = t; }
void fx_ie_b1(void) { unsigned char t; if (gb1 > gb2) t = gb1; else if (gb1 == gb2) t = 5; else t = gb2; gb3 = t + gb1; }
void fx_ie_b2(void) { unsigned char t; if (gb1 != 0) t = rb(); else t = gb2; gb3 = t ^ gb1; }
void fx_ie_b3(void) { unsigned char t = gb2; if (gb1 > 2) { if (gb1 < gb2) t = gb1; else t = 9; } gb3 = t; }
int fx_ie_b4(void) { unsigned char t; if (gb1 > gb2) t = gb1; else t = gb2; if (t == gb3) return 1; return 0; }
int fx_rl_b0(void) { int i; for (i = 0; i < 8; i++) if (gba[i] == gb1) return i; return 9; }
unsigned char fx_rl_b1(void) { int i; for (i = 0; i < 8; i++) if (gba[i] > gb1) return gba[i]; return gb2; }
int fx_rl_b2(unsigned char a) { int i; for (i = 0; i < 8; i++) { if (gba[i] == a) return i; gbb[i] = a; } return 9; }
int fx_rl_b3(void) { int i = 0; while (i < 8) { if (gba[i] != gbb[i]) return i; i++; } return 9; }
unsigned char fx_rl_b4(void) { unsigned char s = 0; int i; for (i = 0; i < 8; i++) { s = gba[i]; if (s == gb1) break; } return s; }
void fx_ss_b0(void) { gba[1] = gb1; gba[2] = gb2; gba[3] = gba[1] ^ gba[2]; }
void fx_ss_b1(void) { gs.b = gb1; gs.i = gi1; gs.l = gl1; gb3 = gs.b; }
void fx_ss_b2(void) { gps->b = gb1; gps->i = gi2; gps->a[2] = gi1; gb3 = gps->b; }
void fx_ss_b3(struct sv *p) { p->b = gb1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gb3 = p->b; }
void fx_ss_b4(void) { gbp[1] = gb1; gbp[4] = gb2; gb3 = gbp[1] + gbp[4]; }
unsigned char fx_ss_b5(void) { gba[5] = gb1 + gb2; gba[6] = gba[5] ^ gb1; return gba[6]; }
void fx_cv_b0(void) { unsigned char t = gb1 ^ gb2; vb(gb3); gb2 = t; }
unsigned char fx_cv_b1(void) { unsigned char t = gb1 + gb2; v0(); return t; }
int fx_cv_b2(void) { unsigned char t = gb1; gb2 = rb(); return t == gb2; }
void fx_cv_b3(void) { unsigned char t = gb1 - gb2; v0(); wb(t, gb1); }
unsigned char fx_cv_b4(void) { unsigned char t = gb1 | gb2; return t ^ rb(); }
void fx_lc_i0(void) { int t = gi1 + gi2; v0(); gi3 = t ^ gi1; }
void fx_lc_i1(void) { int t = gi1 ^ gi2; vi(t); gi3 = t + gi2; }
void fx_lc_i2(void) { int t = gi1 - gi2; gi2 = ri(); gi3 = t | gi2; }
void fx_lc_i3(void) { int t = gi1 & gi2; v0(); vi(gi1); gi3 = t; }
void fx_lc_i4(void) { int t = gi1; gi2 = t + gi2; v0(); gi3 = t - gi2; }
void fx_lh_i0(void) { int t = gi1 + 1; gn4 = gn1 * gn2; gi3 = t ^ gi2; }
void fx_lh_i1(void) { int t = gi1 ^ gi2; gl4 = gl1 / (gl2 & 0x7fff | 1); gi3 = t; }
void fx_lh_i2(void) { int t = gi1 | 3; gn4 = gn1 % (gn2 | 1); gi3 = t + gi1; }
void fx_lh_i3(void) { int t = gi1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gi3 = t - gi2; }
void fx_lh_i4(void) { int t = gi1 & gi2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gi3 = t ^ gi1; }
void fx_lp_i0(void) { int t = gi1; int i; int s = 0; for (i = 0; i < 8; i++) s += gia[i]; gi3 = t ^ s; }
void fx_lp_i1(void) { int t = gi1 + gi2; int n = 5; while (n-- > 0) gi2 ^= gi1; gi3 = t; }
void fx_lp_i2(void) { int t = gi2; int n = 0; do { gib[n] = t; n++; } while (n < 6); gi3 = t + gi1; }
void fx_lp_i3(void) { int t = gi1 | gi2; int i; for (i = 0; i < 4; i++) vi(gia[i]); gi3 = t; }
int fx_lp_i4(void) { int t = gi1; int i; for (i = 0; i < 8; i++) t ^= gia[i]; return t; }
int fx_rp_i0(int a, int b) { v0(); return a + b; }
int fx_rp_i1(int a, int b) { vi(a); return a ^ b; }
int fx_rp_i2(int a, int b, int c) { vi(b); v0(); return (a - c) | b; }
int fx_rp_i3(int a, int b) { gi1 = ri(); a += b; return a ^ gi1; }
int fx_rp_i4(int a, int b) { v0(); if (a > b) return 1; return 2; }
int fx_lo_i0(void) { int s = 0; int i; for (i = 0; i < 8; i++) s += gia[i]; return s; }
int fx_lo_i1(void) { int s = gi1; int n = 7; while (n > 0) { s ^= gia[n]; n--; } return s; }
int fx_lo_i2(void) { int *p = gia; int s = 0; while (p < gia + 8) s += *p++; return s; }
void fx_lo_i3(void) { int i = 0; do { gib[i] = gia[i] ^ gi1; i++; } while (i < 8); gi3 = gib[7]; }
int fx_lo_i4(void) { int s = 0; int i; for (i = 0; i < 8; i++) s += gia[i] & gib[i]; return s; }
void fx_lo_i5(void) { int i; for (i = 0; i < 8; i++) gib[i] = gi1 + gia[i]; gi3 = gib[3]; }
void fx_ie_i0(void) { int t; if (gi1 > gi2) t = gi1; else t = gi2; gi3 = t; }
void fx_ie_i1(void) { int t; if (gi1 > gi2) t = gi1; else if (gi1 == gi2) t = 5; else t = gi2; gi3 = t + gi1; }
void fx_ie_i2(void) { int t; if (gi1 != 0) t = ri(); else t = gi2; gi3 = t ^ gi1; }
void fx_ie_i3(void) { int t = gi2; if (gi1 > 2) { if (gi1 < gi2) t = gi1; else t = 9; } gi3 = t; }
int fx_ie_i4(void) { int t; if (gi1 > gi2) t = gi1; else t = gi2; if (t == gi3) return 1; return 0; }
int fx_rl_i0(void) { int i; for (i = 0; i < 8; i++) if (gia[i] == gi1) return i; return 9; }
int fx_rl_i1(void) { int i; for (i = 0; i < 8; i++) if (gia[i] > gi1) return gia[i]; return gi2; }
int fx_rl_i2(int a) { int i; for (i = 0; i < 8; i++) { if (gia[i] == a) return i; gib[i] = a; } return 9; }
int fx_rl_i3(void) { int i = 0; while (i < 8) { if (gia[i] != gib[i]) return i; i++; } return 9; }
int fx_rl_i4(void) { int s = 0; int i; for (i = 0; i < 8; i++) { s = gia[i]; if (s == gi1) break; } return s; }
void fx_ss_i0(void) { gia[1] = gi1; gia[2] = gi2; gia[3] = gia[1] ^ gia[2]; }
void fx_ss_i1(void) { gs.i = gi1; gs.i = gi1; gs.l = gl1; gi3 = gs.i; }
void fx_ss_i2(void) { gps->i = gi1; gps->i = gi2; gps->a[2] = gi1; gi3 = gps->i; }
void fx_ss_i3(struct sv *p) { p->i = gi1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gi3 = p->i; }
void fx_ss_i4(void) { gip[1] = gi1; gip[4] = gi2; gi3 = gip[1] + gip[4]; }
int fx_ss_i5(void) { gia[5] = gi1 + gi2; gia[6] = gia[5] ^ gi1; return gia[6]; }
void fx_cv_i0(void) { int t = gi1 ^ gi2; vi(gi3); gi2 = t; }
int fx_cv_i1(void) { int t = gi1 + gi2; v0(); return t; }
int fx_cv_i2(void) { int t = gi1; gi2 = ri(); return t == gi2; }
void fx_cv_i3(void) { int t = gi1 - gi2; v0(); wi(t, gi1); }
int fx_cv_i4(void) { int t = gi1 | gi2; return t ^ ri(); }
void fx_lc_u0(void) { unsigned int t = gu1 + gu2; v0(); gu3 = t ^ gu1; }
void fx_lc_u1(void) { unsigned int t = gu1 ^ gu2; vu(t); gu3 = t + gu2; }
void fx_lc_u2(void) { unsigned int t = gu1 - gu2; gu2 = ru(); gu3 = t | gu2; }
void fx_lc_u3(void) { unsigned int t = gu1 & gu2; v0(); vu(gu1); gu3 = t; }
void fx_lc_u4(void) { unsigned int t = gu1; gu2 = t + gu2; v0(); gu3 = t - gu2; }
void fx_lh_u0(void) { unsigned int t = gu1 + 1; gn4 = gn1 * gn2; gu3 = t ^ gu2; }
void fx_lh_u1(void) { unsigned int t = gu1 ^ gu2; gl4 = gl1 / (gl2 & 0x7fff | 1); gu3 = t; }
void fx_lh_u2(void) { unsigned int t = gu1 | 3; gn4 = gn1 % (gn2 | 1); gu3 = t + gu1; }
void fx_lh_u3(void) { unsigned int t = gu1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gu3 = t - gu2; }
void fx_lh_u4(void) { unsigned int t = gu1 & gu2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gu3 = t ^ gu1; }
void fx_lp_u0(void) { unsigned int t = gu1; int i; unsigned int s = 0; for (i = 0; i < 8; i++) s += gua[i]; gu3 = t ^ s; }
void fx_lp_u1(void) { unsigned int t = gu1 + gu2; int n = 5; while (n-- > 0) gu2 ^= gu1; gu3 = t; }
void fx_lp_u2(void) { unsigned int t = gu2; int n = 0; do { gub[n] = t; n++; } while (n < 6); gu3 = t + gu1; }
void fx_lp_u3(void) { unsigned int t = gu1 | gu2; int i; for (i = 0; i < 4; i++) vu(gua[i]); gu3 = t; }
unsigned int fx_lp_u4(void) { unsigned int t = gu1; int i; for (i = 0; i < 8; i++) t ^= gua[i]; return t; }
unsigned int fx_rp_u0(unsigned int a, unsigned int b) { v0(); return a + b; }
unsigned int fx_rp_u1(unsigned int a, unsigned int b) { vu(a); return a ^ b; }
unsigned int fx_rp_u2(unsigned int a, unsigned int b, unsigned int c) { vu(b); v0(); return (a - c) | b; }
unsigned int fx_rp_u3(unsigned int a, unsigned int b) { gu1 = ru(); a += b; return a ^ gu1; }
int fx_rp_u4(unsigned int a, unsigned int b) { v0(); if (a > b) return 1; return 2; }
unsigned int fx_lo_u0(void) { unsigned int s = 0; int i; for (i = 0; i < 8; i++) s += gua[i]; return s; }
unsigned int fx_lo_u1(void) { unsigned int s = gu1; int n = 7; while (n > 0) { s ^= gua[n]; n--; } return s; }
unsigned int fx_lo_u2(void) { unsigned int *p = gua; unsigned int s = 0; while (p < gua + 8) s += *p++; return s; }
void fx_lo_u3(void) { int i = 0; do { gub[i] = gua[i] ^ gu1; i++; } while (i < 8); gu3 = gub[7]; }
unsigned int fx_lo_u4(void) { unsigned int s = 0; int i; for (i = 0; i < 8; i++) s += gua[i] & gub[i]; return s; }
void fx_lo_u5(void) { int i; for (i = 0; i < 8; i++) gub[i] = gu1 + gua[i]; gu3 = gub[3]; }
void fx_ie_u0(void) { unsigned int t; if (gu1 > gu2) t = gu1; else t = gu2; gu3 = t; }
void fx_ie_u1(void) { unsigned int t; if (gu1 > gu2) t = gu1; else if (gu1 == gu2) t = 5; else t = gu2; gu3 = t + gu1; }
void fx_ie_u2(void) { unsigned int t; if (gu1 != 0) t = ru(); else t = gu2; gu3 = t ^ gu1; }
void fx_ie_u3(void) { unsigned int t = gu2; if (gu1 > 2) { if (gu1 < gu2) t = gu1; else t = 9; } gu3 = t; }
int fx_ie_u4(void) { unsigned int t; if (gu1 > gu2) t = gu1; else t = gu2; if (t == gu3) return 1; return 0; }
int fx_rl_u0(void) { int i; for (i = 0; i < 8; i++) if (gua[i] == gu1) return i; return 9; }
unsigned int fx_rl_u1(void) { int i; for (i = 0; i < 8; i++) if (gua[i] > gu1) return gua[i]; return gu2; }
int fx_rl_u2(unsigned int a) { int i; for (i = 0; i < 8; i++) { if (gua[i] == a) return i; gub[i] = a; } return 9; }
int fx_rl_u3(void) { int i = 0; while (i < 8) { if (gua[i] != gub[i]) return i; i++; } return 9; }
unsigned int fx_rl_u4(void) { unsigned int s = 0; int i; for (i = 0; i < 8; i++) { s = gua[i]; if (s == gu1) break; } return s; }
void fx_ss_u0(void) { gua[1] = gu1; gua[2] = gu2; gua[3] = gua[1] ^ gua[2]; }
void fx_ss_u1(void) { gs.u = gu1; gs.i = gi1; gs.l = gl1; gu3 = gs.u; }
void fx_ss_u2(void) { gps->u = gu1; gps->i = gi2; gps->a[2] = gi1; gu3 = gps->u; }
void fx_ss_u3(struct sv *p) { p->u = gu1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gu3 = p->u; }
void fx_ss_u4(void) { gup[1] = gu1; gup[4] = gu2; gu3 = gup[1] + gup[4]; }
unsigned int fx_ss_u5(void) { gua[5] = gu1 + gu2; gua[6] = gua[5] ^ gu1; return gua[6]; }
void fx_cv_u0(void) { unsigned int t = gu1 ^ gu2; vu(gu3); gu2 = t; }
unsigned int fx_cv_u1(void) { unsigned int t = gu1 + gu2; v0(); return t; }
int fx_cv_u2(void) { unsigned int t = gu1; gu2 = ru(); return t == gu2; }
void fx_cv_u3(void) { unsigned int t = gu1 - gu2; v0(); wu(t, gu1); }
unsigned int fx_cv_u4(void) { unsigned int t = gu1 | gu2; return t ^ ru(); }
void fx_lc_l0(void) { long t = gl1 + gl2; v0(); gl3 = t ^ gl1; }
void fx_lc_l1(void) { long t = gl1 ^ gl2; vl(t); gl3 = t + gl2; }
void fx_lc_l2(void) { long t = gl1 - gl2; gl2 = rl(); gl3 = t | gl2; }
void fx_lc_l3(void) { long t = gl1 & gl2; v0(); vl(gl1); gl3 = t; }
void fx_lc_l4(void) { long t = gl1; gl2 = t + gl2; v0(); gl3 = t - gl2; }
void fx_lh_l0(void) { long t = gl1 + 1; gn4 = gn1 * gn2; gl3 = t ^ gl2; }
void fx_lh_l1(void) { long t = gl1 ^ gl2; gl4 = gl1 / (gl2 & 0x7fff | 1); gl3 = t; }
void fx_lh_l2(void) { long t = gl1 | 3; gn4 = gn1 % (gn2 | 1); gl3 = t + gl1; }
void fx_lh_l3(void) { long t = gl1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gl3 = t - gl2; }
void fx_lh_l4(void) { long t = gl1 & gl2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gl3 = t ^ gl1; }
void fx_lp_l0(void) { long t = gl1; int i; long s = 0; for (i = 0; i < 8; i++) s += gla[i]; gl3 = t ^ s; }
void fx_lp_l1(void) { long t = gl1 + gl2; int n = 5; while (n-- > 0) gl2 ^= gl1; gl3 = t; }
void fx_lp_l2(void) { long t = gl2; int n = 0; do { glb[n] = t; n++; } while (n < 6); gl3 = t + gl1; }
void fx_lp_l3(void) { long t = gl1 | gl2; int i; for (i = 0; i < 4; i++) vl(gla[i]); gl3 = t; }
long fx_lp_l4(void) { long t = gl1; int i; for (i = 0; i < 8; i++) t ^= gla[i]; return t; }
long fx_rp_l0(long a, long b) { v0(); return a + b; }
long fx_rp_l1(long a, long b) { vl(a); return a ^ b; }
long fx_rp_l2(long a, long b, long c) { vl(b); v0(); return (a - c) | b; }
long fx_rp_l3(long a, long b) { gl1 = rl(); a += b; return a ^ gl1; }
int fx_rp_l4(long a, long b) { v0(); if (a > b) return 1; return 2; }
long fx_lo_l0(void) { long s = 0; int i; for (i = 0; i < 8; i++) s += gla[i]; return s; }
long fx_lo_l1(void) { long s = gl1; int n = 7; while (n > 0) { s ^= gla[n]; n--; } return s; }
long fx_lo_l2(void) { long *p = gla; long s = 0; while (p < gla + 8) s += *p++; return s; }
void fx_lo_l3(void) { int i = 0; do { glb[i] = gla[i] ^ gl1; i++; } while (i < 8); gl3 = glb[7]; }
long fx_lo_l4(void) { long s = 0; int i; for (i = 0; i < 8; i++) s += gla[i] & glb[i]; return s; }
void fx_lo_l5(void) { int i; for (i = 0; i < 8; i++) glb[i] = gl1 + gla[i]; gl3 = glb[3]; }
void fx_ie_l0(void) { long t; if (gl1 > gl2) t = gl1; else t = gl2; gl3 = t; }
void fx_ie_l1(void) { long t; if (gl1 > gl2) t = gl1; else if (gl1 == gl2) t = 5; else t = gl2; gl3 = t + gl1; }
void fx_ie_l2(void) { long t; if (gl1 != 0) t = rl(); else t = gl2; gl3 = t ^ gl1; }
void fx_ie_l3(void) { long t = gl2; if (gl1 > 2) { if (gl1 < gl2) t = gl1; else t = 9; } gl3 = t; }
int fx_ie_l4(void) { long t; if (gl1 > gl2) t = gl1; else t = gl2; if (t == gl3) return 1; return 0; }
int fx_rl_l0(void) { int i; for (i = 0; i < 8; i++) if (gla[i] == gl1) return i; return 9; }
long fx_rl_l1(void) { int i; for (i = 0; i < 8; i++) if (gla[i] > gl1) return gla[i]; return gl2; }
int fx_rl_l2(long a) { int i; for (i = 0; i < 8; i++) { if (gla[i] == a) return i; glb[i] = a; } return 9; }
int fx_rl_l3(void) { int i = 0; while (i < 8) { if (gla[i] != glb[i]) return i; i++; } return 9; }
long fx_rl_l4(void) { long s = 0; int i; for (i = 0; i < 8; i++) { s = gla[i]; if (s == gl1) break; } return s; }
void fx_ss_l0(void) { gla[1] = gl1; gla[2] = gl2; gla[3] = gla[1] ^ gla[2]; }
void fx_ss_l1(void) { gs.l = gl1; gs.i = gi1; gs.l = gl1; gl3 = gs.l; }
void fx_ss_l2(void) { gps->l = gl1; gps->i = gi2; gps->a[2] = gi1; gl3 = gps->l; }
void fx_ss_l3(struct sv *p) { p->l = gl1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gl3 = p->l; }
void fx_ss_l4(void) { glp[1] = gl1; glp[4] = gl2; gl3 = glp[1] + glp[4]; }
long fx_ss_l5(void) { gla[5] = gl1 + gl2; gla[6] = gla[5] ^ gl1; return gla[6]; }
void fx_cv_l0(void) { long t = gl1 ^ gl2; vl(gl3); gl2 = t; }
long fx_cv_l1(void) { long t = gl1 + gl2; v0(); return t; }
int fx_cv_l2(void) { long t = gl1; gl2 = rl(); return t == gl2; }
void fx_cv_l3(void) { long t = gl1 - gl2; v0(); wl(t, gl1); }
long fx_cv_l4(void) { long t = gl1 | gl2; return t ^ rl(); }
void fx_lc_n0(void) { unsigned long t = gn1 + gn2; v0(); gn3 = t ^ gn1; }
void fx_lc_n1(void) { unsigned long t = gn1 ^ gn2; vn(t); gn3 = t + gn2; }
void fx_lc_n2(void) { unsigned long t = gn1 - gn2; gn2 = rn(); gn3 = t | gn2; }
void fx_lc_n3(void) { unsigned long t = gn1 & gn2; v0(); vn(gn1); gn3 = t; }
void fx_lc_n4(void) { unsigned long t = gn1; gn2 = t + gn2; v0(); gn3 = t - gn2; }
void fx_lh_n0(void) { unsigned long t = gn1 + 1; gn4 = gn1 * gn2; gn3 = t ^ gn2; }
void fx_lh_n1(void) { unsigned long t = gn1 ^ gn2; gl4 = gl1 / (gl2 & 0x7fff | 1); gn3 = t; }
void fx_lh_n2(void) { unsigned long t = gn1 | 3; gn4 = gn1 % (gn2 | 1); gn3 = t + gn1; }
void fx_lh_n3(void) { unsigned long t = gn1; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gn3 = t - gn2; }
void fx_lh_n4(void) { unsigned long t = gn1 & gn2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gn3 = t ^ gn1; }
void fx_lp_n0(void) { unsigned long t = gn1; int i; unsigned long s = 0; for (i = 0; i < 8; i++) s += gna[i]; gn3 = t ^ s; }
void fx_lp_n1(void) { unsigned long t = gn1 + gn2; int n = 5; while (n-- > 0) gn2 ^= gn1; gn3 = t; }
void fx_lp_n2(void) { unsigned long t = gn2; int n = 0; do { gnb[n] = t; n++; } while (n < 6); gn3 = t + gn1; }
void fx_lp_n3(void) { unsigned long t = gn1 | gn2; int i; for (i = 0; i < 4; i++) vn(gna[i]); gn3 = t; }
unsigned long fx_lp_n4(void) { unsigned long t = gn1; int i; for (i = 0; i < 8; i++) t ^= gna[i]; return t; }
unsigned long fx_rp_n0(unsigned long a, unsigned long b) { v0(); return a + b; }
unsigned long fx_rp_n1(unsigned long a, unsigned long b) { vn(a); return a ^ b; }
unsigned long fx_rp_n2(unsigned long a, unsigned long b, unsigned long c) { vn(b); v0(); return (a - c) | b; }
unsigned long fx_rp_n3(unsigned long a, unsigned long b) { gn1 = rn(); a += b; return a ^ gn1; }
int fx_rp_n4(unsigned long a, unsigned long b) { v0(); if (a > b) return 1; return 2; }
unsigned long fx_lo_n0(void) { unsigned long s = 0; int i; for (i = 0; i < 8; i++) s += gna[i]; return s; }
unsigned long fx_lo_n1(void) { unsigned long s = gn1; int n = 7; while (n > 0) { s ^= gna[n]; n--; } return s; }
unsigned long fx_lo_n2(void) { unsigned long *p = gna; unsigned long s = 0; while (p < gna + 8) s += *p++; return s; }
void fx_lo_n3(void) { int i = 0; do { gnb[i] = gna[i] ^ gn1; i++; } while (i < 8); gn3 = gnb[7]; }
unsigned long fx_lo_n4(void) { unsigned long s = 0; int i; for (i = 0; i < 8; i++) s += gna[i] & gnb[i]; return s; }
void fx_lo_n5(void) { int i; for (i = 0; i < 8; i++) gnb[i] = gn1 + gna[i]; gn3 = gnb[3]; }
void fx_ie_n0(void) { unsigned long t; if (gn1 > gn2) t = gn1; else t = gn2; gn3 = t; }
void fx_ie_n1(void) { unsigned long t; if (gn1 > gn2) t = gn1; else if (gn1 == gn2) t = 5; else t = gn2; gn3 = t + gn1; }
void fx_ie_n2(void) { unsigned long t; if (gn1 != 0) t = rn(); else t = gn2; gn3 = t ^ gn1; }
void fx_ie_n3(void) { unsigned long t = gn2; if (gn1 > 2) { if (gn1 < gn2) t = gn1; else t = 9; } gn3 = t; }
int fx_ie_n4(void) { unsigned long t; if (gn1 > gn2) t = gn1; else t = gn2; if (t == gn3) return 1; return 0; }
int fx_rl_n0(void) { int i; for (i = 0; i < 8; i++) if (gna[i] == gn1) return i; return 9; }
unsigned long fx_rl_n1(void) { int i; for (i = 0; i < 8; i++) if (gna[i] > gn1) return gna[i]; return gn2; }
int fx_rl_n2(unsigned long a) { int i; for (i = 0; i < 8; i++) { if (gna[i] == a) return i; gnb[i] = a; } return 9; }
int fx_rl_n3(void) { int i = 0; while (i < 8) { if (gna[i] != gnb[i]) return i; i++; } return 9; }
unsigned long fx_rl_n4(void) { unsigned long s = 0; int i; for (i = 0; i < 8; i++) { s = gna[i]; if (s == gn1) break; } return s; }
void fx_ss_n0(void) { gna[1] = gn1; gna[2] = gn2; gna[3] = gna[1] ^ gna[2]; }
void fx_ss_n1(void) { gs.n = gn1; gs.i = gi1; gs.l = gl1; gn3 = gs.n; }
void fx_ss_n2(void) { gps->n = gn1; gps->i = gi2; gps->a[2] = gi1; gn3 = gps->n; }
void fx_ss_n3(struct sv *p) { p->n = gn1; p->a[1] = gi2; p->a[3] = p->a[1] + gi1; gn3 = p->n; }
void fx_ss_n4(void) { gnp[1] = gn1; gnp[4] = gn2; gn3 = gnp[1] + gnp[4]; }
unsigned long fx_ss_n5(void) { gna[5] = gn1 + gn2; gna[6] = gna[5] ^ gn1; return gna[6]; }
void fx_cv_n0(void) { unsigned long t = gn1 ^ gn2; vn(gn3); gn2 = t; }
unsigned long fx_cv_n1(void) { unsigned long t = gn1 + gn2; v0(); return t; }
int fx_cv_n2(void) { unsigned long t = gn1; gn2 = rn(); return t == gn2; }
void fx_cv_n3(void) { unsigned long t = gn1 - gn2; v0(); wn(t, gn1); }
unsigned long fx_cv_n4(void) { unsigned long t = gn1 | gn2; return t ^ rn(); }
void fx_lp_c5(void) { char t = gc1 ^ gc2; int i; for (i = 0; i < 4; i++) gcb[i] = t; for (i = 4; i < 8; i++) gcb[i] = gc1; gc3 = t + gcb[2]; }
char fx_lo_c6(char *p) { char s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
char fx_lo_c7(char *p) { char s = gc1; int n = 8; while (n--) s ^= *p++; return s; }
char fx_rp_c5(char a, char b) { char t = a + b; v0(); return t ^ a; }
void fx_rp_c6(char a, char b, char c) { gc1 = a; vc(b); gc3 = c ^ a; }
void fx_ie_c5(void) { char t; if (gc1 > gc2) t = rc(); else t = rc() ^ gc1; gc3 = t; }
void fx_cv_c5(void) { char t = gc1 + gc2; v0(); gca[3] = t; gca[4] = t ^ gc1; }
void fx_lc_c5(void) { char t = gc1; int i; for (i = 0; i < 3; i++) { v0(); gcb[i] = t; } gc3 = t; }
void fx_lp_b5(void) { unsigned char t = gb1 ^ gb2; int i; for (i = 0; i < 4; i++) gbb[i] = t; for (i = 4; i < 8; i++) gbb[i] = gb1; gb3 = t + gbb[2]; }
unsigned char fx_lo_b6(unsigned char *p) { unsigned char s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
unsigned char fx_lo_b7(unsigned char *p) { unsigned char s = gb1; int n = 8; while (n--) s ^= *p++; return s; }
unsigned char fx_rp_b5(unsigned char a, unsigned char b) { unsigned char t = a + b; v0(); return t ^ a; }
void fx_rp_b6(unsigned char a, unsigned char b, unsigned char c) { gb1 = a; vb(b); gb3 = c ^ a; }
void fx_ie_b5(void) { unsigned char t; if (gb1 > gb2) t = rb(); else t = rb() ^ gb1; gb3 = t; }
void fx_cv_b5(void) { unsigned char t = gb1 + gb2; v0(); gba[3] = t; gba[4] = t ^ gb1; }
void fx_lc_b5(void) { unsigned char t = gb1; int i; for (i = 0; i < 3; i++) { v0(); gbb[i] = t; } gb3 = t; }
void fx_lp_i5(void) { int t = gi1 ^ gi2; int i; for (i = 0; i < 4; i++) gib[i] = t; for (i = 4; i < 8; i++) gib[i] = gi1; gi3 = t + gib[2]; }
int fx_lo_i6(int *p) { int s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
int fx_lo_i7(int *p) { int s = gi1; int n = 8; while (n--) s ^= *p++; return s; }
int fx_rp_i5(int a, int b) { int t = a + b; v0(); return t ^ a; }
void fx_rp_i6(int a, int b, int c) { gi1 = a; vi(b); gi3 = c ^ a; }
void fx_ie_i5(void) { int t; if (gi1 > gi2) t = ri(); else t = ri() ^ gi1; gi3 = t; }
void fx_cv_i5(void) { int t = gi1 + gi2; v0(); gia[3] = t; gia[4] = t ^ gi1; }
void fx_lc_i5(void) { int t = gi1; int i; for (i = 0; i < 3; i++) { v0(); gib[i] = t; } gi3 = t; }
void fx_lp_u5(void) { unsigned int t = gu1 ^ gu2; int i; for (i = 0; i < 4; i++) gub[i] = t; for (i = 4; i < 8; i++) gub[i] = gu1; gu3 = t + gub[2]; }
unsigned int fx_lo_u6(unsigned int *p) { unsigned int s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
unsigned int fx_lo_u7(unsigned int *p) { unsigned int s = gu1; int n = 8; while (n--) s ^= *p++; return s; }
unsigned int fx_rp_u5(unsigned int a, unsigned int b) { unsigned int t = a + b; v0(); return t ^ a; }
void fx_rp_u6(unsigned int a, unsigned int b, unsigned int c) { gu1 = a; vu(b); gu3 = c ^ a; }
void fx_ie_u5(void) { unsigned int t; if (gu1 > gu2) t = ru(); else t = ru() ^ gu1; gu3 = t; }
void fx_cv_u5(void) { unsigned int t = gu1 + gu2; v0(); gua[3] = t; gua[4] = t ^ gu1; }
void fx_lc_u5(void) { unsigned int t = gu1; int i; for (i = 0; i < 3; i++) { v0(); gub[i] = t; } gu3 = t; }
void fx_lp_l5(void) { long t = gl1 ^ gl2; int i; for (i = 0; i < 4; i++) glb[i] = t; for (i = 4; i < 8; i++) glb[i] = gl1; gl3 = t + glb[2]; }
long fx_lo_l6(long *p) { long s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
long fx_lo_l7(long *p) { long s = gl1; int n = 8; while (n--) s ^= *p++; return s; }
long fx_rp_l5(long a, long b) { long t = a + b; v0(); return t ^ a; }
void fx_rp_l6(long a, long b, long c) { gl1 = a; vl(b); gl3 = c ^ a; }
void fx_ie_l5(void) { long t; if (gl1 > gl2) t = rl(); else t = rl() ^ gl1; gl3 = t; }
void fx_cv_l5(void) { long t = gl1 + gl2; v0(); gla[3] = t; gla[4] = t ^ gl1; }
void fx_lc_l5(void) { long t = gl1; int i; for (i = 0; i < 3; i++) { v0(); glb[i] = t; } gl3 = t; }
void fx_lp_n5(void) { unsigned long t = gn1 ^ gn2; int i; for (i = 0; i < 4; i++) gnb[i] = t; for (i = 4; i < 8; i++) gnb[i] = gn1; gn3 = t + gnb[2]; }
unsigned long fx_lo_n6(unsigned long *p) { unsigned long s = 0; int i; for (i = 0; i < 8; i++) s += p[i]; return s; }
unsigned long fx_lo_n7(unsigned long *p) { unsigned long s = gn1; int n = 8; while (n--) s ^= *p++; return s; }
unsigned long fx_rp_n5(unsigned long a, unsigned long b) { unsigned long t = a + b; v0(); return t ^ a; }
void fx_rp_n6(unsigned long a, unsigned long b, unsigned long c) { gn1 = a; vn(b); gn3 = c ^ a; }
void fx_ie_n5(void) { unsigned long t; if (gn1 > gn2) t = rn(); else t = rn() ^ gn1; gn3 = t; }
void fx_cv_n5(void) { unsigned long t = gn1 + gn2; v0(); gna[3] = t; gna[4] = t ^ gn1; }
void fx_lc_n5(void) { unsigned long t = gn1; int i; for (i = 0; i < 3; i++) { v0(); gnb[i] = t; } gn3 = t; }
void fx_lc_c0p(char a) { char t = a + gc2; v0(); gc3 = t ^ a; }
void fx_lc_c1p(char a) { char t = a ^ gc2; vc(t); gc3 = t + gc2; }
void fx_lc_c2p(char a) { char t = a - gc2; gc2 = rc(); gc3 = t | gc2; }
void fx_lc_c3p(char a) { char t = a & gc2; v0(); vc(a); gc3 = t; }
void fx_lc_c4p(char a) { char t = a; gc2 = t + gc2; v0(); gc3 = t - gc2; }
void fx_lh_c0p(char a) { char t = a + 1; gn4 = gn1 * gn2; gc3 = t ^ gc2; }
void fx_lh_c1p(char a) { char t = a ^ gc2; gl4 = gl1 / (gl2 & 0x7fff | 1); gc3 = t; }
void fx_lh_c2p(char a) { char t = a | 3; gn4 = gn1 % (gn2 | 1); gc3 = t + a; }
void fx_lh_c3p(char a) { char t = a; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gc3 = t - gc2; }
void fx_lh_c4p(char a) { char t = a & gc2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gc3 = t ^ a; }
void fx_lp_c0p(char a) { char t = a; int i; char s = 0; for (i = 0; i < 8; i++) s += gca[i]; gc3 = t ^ s; }
void fx_lp_c1p(char a) { char t = a + gc2; int n = 5; while (n-- > 0) gc2 ^= a; gc3 = t; }
void fx_lp_c2p(char a) { char t = gc2; int n = 0; do { gcb[n] = t; n++; } while (n < 6); gc3 = t + a; }
void fx_lp_c3p(char a) { char t = a | gc2; int i; for (i = 0; i < 4; i++) vc(gca[i]); gc3 = t; }
char fx_lp_c4p(char a) { char t = a; int i; for (i = 0; i < 8; i++) t ^= gca[i]; return t; }
void fx_ie_c0p(char a) { char t; if (a > gc2) t = a; else t = gc2; gc3 = t; }
void fx_ie_c1p(char a) { char t; if (a > gc2) t = a; else if (a == gc2) t = 5; else t = gc2; gc3 = t + a; }
void fx_ie_c2p(char a) { char t; if (a != 0) t = rc(); else t = gc2; gc3 = t ^ a; }
void fx_ie_c3p(char a) { char t = gc2; if (a > 2) { if (a < gc2) t = a; else t = 9; } gc3 = t; }
int fx_ie_c4p(char a) { char t; if (a > gc2) t = a; else t = gc2; if (t == gc3) return 1; return 0; }
void fx_ss_c0p(char a) { gca[1] = a; gca[2] = gc2; gca[3] = gca[1] ^ gca[2]; }
void fx_ss_c1p(char a) { gs.c = a; gs.i = gi1; gs.l = gl1; gc3 = gs.c; }
void fx_ss_c2p(char a) { gps->c = a; gps->i = gi2; gps->a[2] = gi1; gc3 = gps->c; }
void fx_ss_c4p(char a) { gcp[1] = a; gcp[4] = gc2; gc3 = gcp[1] + gcp[4]; }
char fx_ss_c5p(char a) { gca[5] = a + gc2; gca[6] = gca[5] ^ a; return gca[6]; }
void fx_cv_c0p(char a) { char t = a ^ gc2; vc(gc3); gc2 = t; }
char fx_cv_c1p(char a) { char t = a + gc2; v0(); return t; }
int fx_cv_c2p(char a) { char t = a; gc2 = rc(); return t == gc2; }
void fx_cv_c3p(char a) { char t = a - gc2; v0(); wc(t, a); }
char fx_cv_c4p(char a) { char t = a | gc2; return t ^ rc(); }
void fx_lc_b0p(unsigned char a) { unsigned char t = a + gb2; v0(); gb3 = t ^ a; }
void fx_lc_b1p(unsigned char a) { unsigned char t = a ^ gb2; vb(t); gb3 = t + gb2; }
void fx_lc_b2p(unsigned char a) { unsigned char t = a - gb2; gb2 = rb(); gb3 = t | gb2; }
void fx_lc_b3p(unsigned char a) { unsigned char t = a & gb2; v0(); vb(a); gb3 = t; }
void fx_lc_b4p(unsigned char a) { unsigned char t = a; gb2 = t + gb2; v0(); gb3 = t - gb2; }
void fx_lh_b0p(unsigned char a) { unsigned char t = a + 1; gn4 = gn1 * gn2; gb3 = t ^ gb2; }
void fx_lh_b1p(unsigned char a) { unsigned char t = a ^ gb2; gl4 = gl1 / (gl2 & 0x7fff | 1); gb3 = t; }
void fx_lh_b2p(unsigned char a) { unsigned char t = a | 3; gn4 = gn1 % (gn2 | 1); gb3 = t + a; }
void fx_lh_b3p(unsigned char a) { unsigned char t = a; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gb3 = t - gb2; }
void fx_lh_b4p(unsigned char a) { unsigned char t = a & gb2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gb3 = t ^ a; }
void fx_lp_b0p(unsigned char a) { unsigned char t = a; int i; unsigned char s = 0; for (i = 0; i < 8; i++) s += gba[i]; gb3 = t ^ s; }
void fx_lp_b1p(unsigned char a) { unsigned char t = a + gb2; int n = 5; while (n-- > 0) gb2 ^= a; gb3 = t; }
void fx_lp_b2p(unsigned char a) { unsigned char t = gb2; int n = 0; do { gbb[n] = t; n++; } while (n < 6); gb3 = t + a; }
void fx_lp_b3p(unsigned char a) { unsigned char t = a | gb2; int i; for (i = 0; i < 4; i++) vb(gba[i]); gb3 = t; }
unsigned char fx_lp_b4p(unsigned char a) { unsigned char t = a; int i; for (i = 0; i < 8; i++) t ^= gba[i]; return t; }
void fx_ie_b0p(unsigned char a) { unsigned char t; if (a > gb2) t = a; else t = gb2; gb3 = t; }
void fx_ie_b1p(unsigned char a) { unsigned char t; if (a > gb2) t = a; else if (a == gb2) t = 5; else t = gb2; gb3 = t + a; }
void fx_ie_b2p(unsigned char a) { unsigned char t; if (a != 0) t = rb(); else t = gb2; gb3 = t ^ a; }
void fx_ie_b3p(unsigned char a) { unsigned char t = gb2; if (a > 2) { if (a < gb2) t = a; else t = 9; } gb3 = t; }
int fx_ie_b4p(unsigned char a) { unsigned char t; if (a > gb2) t = a; else t = gb2; if (t == gb3) return 1; return 0; }
void fx_ss_b0p(unsigned char a) { gba[1] = a; gba[2] = gb2; gba[3] = gba[1] ^ gba[2]; }
void fx_ss_b1p(unsigned char a) { gs.b = a; gs.i = gi1; gs.l = gl1; gb3 = gs.b; }
void fx_ss_b2p(unsigned char a) { gps->b = a; gps->i = gi2; gps->a[2] = gi1; gb3 = gps->b; }
void fx_ss_b4p(unsigned char a) { gbp[1] = a; gbp[4] = gb2; gb3 = gbp[1] + gbp[4]; }
unsigned char fx_ss_b5p(unsigned char a) { gba[5] = a + gb2; gba[6] = gba[5] ^ a; return gba[6]; }
void fx_cv_b0p(unsigned char a) { unsigned char t = a ^ gb2; vb(gb3); gb2 = t; }
unsigned char fx_cv_b1p(unsigned char a) { unsigned char t = a + gb2; v0(); return t; }
int fx_cv_b2p(unsigned char a) { unsigned char t = a; gb2 = rb(); return t == gb2; }
void fx_cv_b3p(unsigned char a) { unsigned char t = a - gb2; v0(); wb(t, a); }
unsigned char fx_cv_b4p(unsigned char a) { unsigned char t = a | gb2; return t ^ rb(); }
void fx_lc_i0p(int a) { int t = a + gi2; v0(); gi3 = t ^ a; }
void fx_lc_i1p(int a) { int t = a ^ gi2; vi(t); gi3 = t + gi2; }
void fx_lc_i2p(int a) { int t = a - gi2; gi2 = ri(); gi3 = t | gi2; }
void fx_lc_i3p(int a) { int t = a & gi2; v0(); vi(a); gi3 = t; }
void fx_lc_i4p(int a) { int t = a; gi2 = t + gi2; v0(); gi3 = t - gi2; }
void fx_lh_i0p(int a) { int t = a + 1; gn4 = gn1 * gn2; gi3 = t ^ gi2; }
void fx_lh_i1p(int a) { int t = a ^ gi2; gl4 = gl1 / (gl2 & 0x7fff | 1); gi3 = t; }
void fx_lh_i2p(int a) { int t = a | 3; gn4 = gn1 % (gn2 | 1); gi3 = t + a; }
void fx_lh_i3p(int a) { int t = a; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gi3 = t - gi2; }
void fx_lh_i4p(int a) { int t = a & gi2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gi3 = t ^ a; }
void fx_lp_i0p(int a) { int t = a; int i; int s = 0; for (i = 0; i < 8; i++) s += gia[i]; gi3 = t ^ s; }
void fx_lp_i1p(int a) { int t = a + gi2; int n = 5; while (n-- > 0) gi2 ^= a; gi3 = t; }
void fx_lp_i2p(int a) { int t = gi2; int n = 0; do { gib[n] = t; n++; } while (n < 6); gi3 = t + a; }
void fx_lp_i3p(int a) { int t = a | gi2; int i; for (i = 0; i < 4; i++) vi(gia[i]); gi3 = t; }
int fx_lp_i4p(int a) { int t = a; int i; for (i = 0; i < 8; i++) t ^= gia[i]; return t; }
void fx_ie_i0p(int a) { int t; if (a > gi2) t = a; else t = gi2; gi3 = t; }
void fx_ie_i1p(int a) { int t; if (a > gi2) t = a; else if (a == gi2) t = 5; else t = gi2; gi3 = t + a; }
void fx_ie_i2p(int a) { int t; if (a != 0) t = ri(); else t = gi2; gi3 = t ^ a; }
void fx_ie_i3p(int a) { int t = gi2; if (a > 2) { if (a < gi2) t = a; else t = 9; } gi3 = t; }
int fx_ie_i4p(int a) { int t; if (a > gi2) t = a; else t = gi2; if (t == gi3) return 1; return 0; }
void fx_ss_i0p(int a) { gia[1] = a; gia[2] = gi2; gia[3] = gia[1] ^ gia[2]; }
void fx_ss_i1p(int a) { gs.i = a; gs.i = a; gs.l = gl1; gi3 = gs.i; }
void fx_ss_i2p(int a) { gps->i = a; gps->i = gi2; gps->a[2] = a; gi3 = gps->i; }
void fx_ss_i4p(int a) { gip[1] = a; gip[4] = gi2; gi3 = gip[1] + gip[4]; }
int fx_ss_i5p(int a) { gia[5] = a + gi2; gia[6] = gia[5] ^ a; return gia[6]; }
void fx_cv_i0p(int a) { int t = a ^ gi2; vi(gi3); gi2 = t; }
int fx_cv_i1p(int a) { int t = a + gi2; v0(); return t; }
int fx_cv_i2p(int a) { int t = a; gi2 = ri(); return t == gi2; }
void fx_cv_i3p(int a) { int t = a - gi2; v0(); wi(t, a); }
int fx_cv_i4p(int a) { int t = a | gi2; return t ^ ri(); }
void fx_lc_u0p(unsigned int a) { unsigned int t = a + gu2; v0(); gu3 = t ^ a; }
void fx_lc_u1p(unsigned int a) { unsigned int t = a ^ gu2; vu(t); gu3 = t + gu2; }
void fx_lc_u2p(unsigned int a) { unsigned int t = a - gu2; gu2 = ru(); gu3 = t | gu2; }
void fx_lc_u3p(unsigned int a) { unsigned int t = a & gu2; v0(); vu(a); gu3 = t; }
void fx_lc_u4p(unsigned int a) { unsigned int t = a; gu2 = t + gu2; v0(); gu3 = t - gu2; }
void fx_lh_u0p(unsigned int a) { unsigned int t = a + 1; gn4 = gn1 * gn2; gu3 = t ^ gu2; }
void fx_lh_u1p(unsigned int a) { unsigned int t = a ^ gu2; gl4 = gl1 / (gl2 & 0x7fff | 1); gu3 = t; }
void fx_lh_u2p(unsigned int a) { unsigned int t = a | 3; gn4 = gn1 % (gn2 | 1); gu3 = t + a; }
void fx_lh_u3p(unsigned int a) { unsigned int t = a; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gu3 = t - gu2; }
void fx_lh_u4p(unsigned int a) { unsigned int t = a & gu2; gn4 = gn1 * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gu3 = t ^ a; }
void fx_lp_u0p(unsigned int a) { unsigned int t = a; int i; unsigned int s = 0; for (i = 0; i < 8; i++) s += gua[i]; gu3 = t ^ s; }
void fx_lp_u1p(unsigned int a) { unsigned int t = a + gu2; int n = 5; while (n-- > 0) gu2 ^= a; gu3 = t; }
void fx_lp_u2p(unsigned int a) { unsigned int t = gu2; int n = 0; do { gub[n] = t; n++; } while (n < 6); gu3 = t + a; }
void fx_lp_u3p(unsigned int a) { unsigned int t = a | gu2; int i; for (i = 0; i < 4; i++) vu(gua[i]); gu3 = t; }
unsigned int fx_lp_u4p(unsigned int a) { unsigned int t = a; int i; for (i = 0; i < 8; i++) t ^= gua[i]; return t; }
void fx_ie_u0p(unsigned int a) { unsigned int t; if (a > gu2) t = a; else t = gu2; gu3 = t; }
void fx_ie_u1p(unsigned int a) { unsigned int t; if (a > gu2) t = a; else if (a == gu2) t = 5; else t = gu2; gu3 = t + a; }
void fx_ie_u2p(unsigned int a) { unsigned int t; if (a != 0) t = ru(); else t = gu2; gu3 = t ^ a; }
void fx_ie_u3p(unsigned int a) { unsigned int t = gu2; if (a > 2) { if (a < gu2) t = a; else t = 9; } gu3 = t; }
int fx_ie_u4p(unsigned int a) { unsigned int t; if (a > gu2) t = a; else t = gu2; if (t == gu3) return 1; return 0; }
void fx_ss_u0p(unsigned int a) { gua[1] = a; gua[2] = gu2; gua[3] = gua[1] ^ gua[2]; }
void fx_ss_u1p(unsigned int a) { gs.u = a; gs.i = gi1; gs.l = gl1; gu3 = gs.u; }
void fx_ss_u2p(unsigned int a) { gps->u = a; gps->i = gi2; gps->a[2] = gi1; gu3 = gps->u; }
void fx_ss_u4p(unsigned int a) { gup[1] = a; gup[4] = gu2; gu3 = gup[1] + gup[4]; }
unsigned int fx_ss_u5p(unsigned int a) { gua[5] = a + gu2; gua[6] = gua[5] ^ a; return gua[6]; }
void fx_cv_u0p(unsigned int a) { unsigned int t = a ^ gu2; vu(gu3); gu2 = t; }
unsigned int fx_cv_u1p(unsigned int a) { unsigned int t = a + gu2; v0(); return t; }
int fx_cv_u2p(unsigned int a) { unsigned int t = a; gu2 = ru(); return t == gu2; }
void fx_cv_u3p(unsigned int a) { unsigned int t = a - gu2; v0(); wu(t, a); }
unsigned int fx_cv_u4p(unsigned int a) { unsigned int t = a | gu2; return t ^ ru(); }
void fx_lc_l0p(long a) { long t = a + gl2; v0(); gl3 = t ^ a; }
void fx_lc_l1p(long a) { long t = a ^ gl2; vl(t); gl3 = t + gl2; }
void fx_lc_l2p(long a) { long t = a - gl2; gl2 = rl(); gl3 = t | gl2; }
void fx_lc_l3p(long a) { long t = a & gl2; v0(); vl(a); gl3 = t; }
void fx_lc_l4p(long a) { long t = a; gl2 = t + gl2; v0(); gl3 = t - gl2; }
void fx_lh_l0p(long a) { long t = a + 1; gn4 = gn1 * gn2; gl3 = t ^ gl2; }
void fx_lh_l1p(long a) { long t = a ^ gl2; gl4 = a / (gl2 & 0x7fff | 1); gl3 = t; }
void fx_lh_l2p(long a) { long t = a | 3; gn4 = gn1 % (gn2 | 1); gl3 = t + a; }
void fx_lh_l3p(long a) { long t = a; gl4 = (long)t + a / (gl2 & 0x7fff | 1); gl3 = t - gl2; }
void fx_lh_l4p(long a) { long t = a & gl2; gn4 = gn1 * gn2; gl4 = a % (gl2 & 0x7fff | 1); gl3 = t ^ a; }
void fx_lp_l0p(long a) { long t = a; int i; long s = 0; for (i = 0; i < 8; i++) s += gla[i]; gl3 = t ^ s; }
void fx_lp_l1p(long a) { long t = a + gl2; int n = 5; while (n-- > 0) gl2 ^= a; gl3 = t; }
void fx_lp_l2p(long a) { long t = gl2; int n = 0; do { glb[n] = t; n++; } while (n < 6); gl3 = t + a; }
void fx_lp_l3p(long a) { long t = a | gl2; int i; for (i = 0; i < 4; i++) vl(gla[i]); gl3 = t; }
long fx_lp_l4p(long a) { long t = a; int i; for (i = 0; i < 8; i++) t ^= gla[i]; return t; }
void fx_ie_l0p(long a) { long t; if (a > gl2) t = a; else t = gl2; gl3 = t; }
void fx_ie_l1p(long a) { long t; if (a > gl2) t = a; else if (a == gl2) t = 5; else t = gl2; gl3 = t + a; }
void fx_ie_l2p(long a) { long t; if (a != 0) t = rl(); else t = gl2; gl3 = t ^ a; }
void fx_ie_l3p(long a) { long t = gl2; if (a > 2) { if (a < gl2) t = a; else t = 9; } gl3 = t; }
int fx_ie_l4p(long a) { long t; if (a > gl2) t = a; else t = gl2; if (t == gl3) return 1; return 0; }
void fx_ss_l0p(long a) { gla[1] = a; gla[2] = gl2; gla[3] = gla[1] ^ gla[2]; }
void fx_ss_l1p(long a) { gs.l = a; gs.i = gi1; gs.l = a; gl3 = gs.l; }
void fx_ss_l2p(long a) { gps->l = a; gps->i = gi2; gps->a[2] = gi1; gl3 = gps->l; }
void fx_ss_l4p(long a) { glp[1] = a; glp[4] = gl2; gl3 = glp[1] + glp[4]; }
long fx_ss_l5p(long a) { gla[5] = a + gl2; gla[6] = gla[5] ^ a; return gla[6]; }
void fx_cv_l0p(long a) { long t = a ^ gl2; vl(gl3); gl2 = t; }
long fx_cv_l1p(long a) { long t = a + gl2; v0(); return t; }
int fx_cv_l2p(long a) { long t = a; gl2 = rl(); return t == gl2; }
void fx_cv_l3p(long a) { long t = a - gl2; v0(); wl(t, a); }
long fx_cv_l4p(long a) { long t = a | gl2; return t ^ rl(); }
void fx_lc_n0p(unsigned long a) { unsigned long t = a + gn2; v0(); gn3 = t ^ a; }
void fx_lc_n1p(unsigned long a) { unsigned long t = a ^ gn2; vn(t); gn3 = t + gn2; }
void fx_lc_n2p(unsigned long a) { unsigned long t = a - gn2; gn2 = rn(); gn3 = t | gn2; }
void fx_lc_n3p(unsigned long a) { unsigned long t = a & gn2; v0(); vn(a); gn3 = t; }
void fx_lc_n4p(unsigned long a) { unsigned long t = a; gn2 = t + gn2; v0(); gn3 = t - gn2; }
void fx_lh_n0p(unsigned long a) { unsigned long t = a + 1; gn4 = a * gn2; gn3 = t ^ gn2; }
void fx_lh_n1p(unsigned long a) { unsigned long t = a ^ gn2; gl4 = gl1 / (gl2 & 0x7fff | 1); gn3 = t; }
void fx_lh_n2p(unsigned long a) { unsigned long t = a | 3; gn4 = a % (gn2 | 1); gn3 = t + a; }
void fx_lh_n3p(unsigned long a) { unsigned long t = a; gl4 = (long)t + gl1 / (gl2 & 0x7fff | 1); gn3 = t - gn2; }
void fx_lh_n4p(unsigned long a) { unsigned long t = a & gn2; gn4 = a * gn2; gl4 = gl1 % (gl2 & 0x7fff | 1); gn3 = t ^ a; }
void fx_lp_n0p(unsigned long a) { unsigned long t = a; int i; unsigned long s = 0; for (i = 0; i < 8; i++) s += gna[i]; gn3 = t ^ s; }
void fx_lp_n1p(unsigned long a) { unsigned long t = a + gn2; int n = 5; while (n-- > 0) gn2 ^= a; gn3 = t; }
void fx_lp_n2p(unsigned long a) { unsigned long t = gn2; int n = 0; do { gnb[n] = t; n++; } while (n < 6); gn3 = t + a; }
void fx_lp_n3p(unsigned long a) { unsigned long t = a | gn2; int i; for (i = 0; i < 4; i++) vn(gna[i]); gn3 = t; }
unsigned long fx_lp_n4p(unsigned long a) { unsigned long t = a; int i; for (i = 0; i < 8; i++) t ^= gna[i]; return t; }
void fx_ie_n0p(unsigned long a) { unsigned long t; if (a > gn2) t = a; else t = gn2; gn3 = t; }
void fx_ie_n1p(unsigned long a) { unsigned long t; if (a > gn2) t = a; else if (a == gn2) t = 5; else t = gn2; gn3 = t + a; }
void fx_ie_n2p(unsigned long a) { unsigned long t; if (a != 0) t = rn(); else t = gn2; gn3 = t ^ a; }
void fx_ie_n3p(unsigned long a) { unsigned long t = gn2; if (a > 2) { if (a < gn2) t = a; else t = 9; } gn3 = t; }
int fx_ie_n4p(unsigned long a) { unsigned long t; if (a > gn2) t = a; else t = gn2; if (t == gn3) return 1; return 0; }
void fx_ss_n0p(unsigned long a) { gna[1] = a; gna[2] = gn2; gna[3] = gna[1] ^ gna[2]; }
void fx_ss_n1p(unsigned long a) { gs.n = a; gs.i = gi1; gs.l = gl1; gn3 = gs.n; }
void fx_ss_n2p(unsigned long a) { gps->n = a; gps->i = gi2; gps->a[2] = gi1; gn3 = gps->n; }
void fx_ss_n4p(unsigned long a) { gnp[1] = a; gnp[4] = gn2; gn3 = gnp[1] + gnp[4]; }
unsigned long fx_ss_n5p(unsigned long a) { gna[5] = a + gn2; gna[6] = gna[5] ^ a; return gna[6]; }
void fx_cv_n0p(unsigned long a) { unsigned long t = a ^ gn2; vn(gn3); gn2 = t; }
unsigned long fx_cv_n1p(unsigned long a) { unsigned long t = a + gn2; v0(); return t; }
int fx_cv_n2p(unsigned long a) { unsigned long t = a; gn2 = rn(); return t == gn2; }
void fx_cv_n3p(unsigned long a) { unsigned long t = a - gn2; v0(); wn(t, a); }
unsigned long fx_cv_n4p(unsigned long a) { unsigned long t = a | gn2; return t ^ rn(); }
void fx_lp_c5p(char a) { char t = a ^ gc2; int i; for (i = 0; i < 4; i++) gcb[i] = t; for (i = 4; i < 8; i++) gcb[i] = a; gc3 = t + gcb[2]; }
void fx_ie_c5p(char a) { char t; if (a > gc2) t = rc(); else t = rc() ^ a; gc3 = t; }
void fx_cv_c5p(char a) { char t = a + gc2; v0(); gca[3] = t; gca[4] = t ^ a; }
void fx_lc_c5p(char a) { char t = a; int i; for (i = 0; i < 3; i++) { v0(); gcb[i] = t; } gc3 = t; }
void fx_lp_b5p(unsigned char a) { unsigned char t = a ^ gb2; int i; for (i = 0; i < 4; i++) gbb[i] = t; for (i = 4; i < 8; i++) gbb[i] = a; gb3 = t + gbb[2]; }
void fx_ie_b5p(unsigned char a) { unsigned char t; if (a > gb2) t = rb(); else t = rb() ^ a; gb3 = t; }
void fx_cv_b5p(unsigned char a) { unsigned char t = a + gb2; v0(); gba[3] = t; gba[4] = t ^ a; }
void fx_lc_b5p(unsigned char a) { unsigned char t = a; int i; for (i = 0; i < 3; i++) { v0(); gbb[i] = t; } gb3 = t; }
void fx_lp_i5p(int a) { int t = a ^ gi2; int i; for (i = 0; i < 4; i++) gib[i] = t; for (i = 4; i < 8; i++) gib[i] = a; gi3 = t + gib[2]; }
void fx_ie_i5p(int a) { int t; if (a > gi2) t = ri(); else t = ri() ^ a; gi3 = t; }
void fx_cv_i5p(int a) { int t = a + gi2; v0(); gia[3] = t; gia[4] = t ^ a; }
void fx_lc_i5p(int a) { int t = a; int i; for (i = 0; i < 3; i++) { v0(); gib[i] = t; } gi3 = t; }
void fx_lp_u5p(unsigned int a) { unsigned int t = a ^ gu2; int i; for (i = 0; i < 4; i++) gub[i] = t; for (i = 4; i < 8; i++) gub[i] = a; gu3 = t + gub[2]; }
void fx_ie_u5p(unsigned int a) { unsigned int t; if (a > gu2) t = ru(); else t = ru() ^ a; gu3 = t; }
void fx_cv_u5p(unsigned int a) { unsigned int t = a + gu2; v0(); gua[3] = t; gua[4] = t ^ a; }
void fx_lc_u5p(unsigned int a) { unsigned int t = a; int i; for (i = 0; i < 3; i++) { v0(); gub[i] = t; } gu3 = t; }
void fx_lp_l5p(long a) { long t = a ^ gl2; int i; for (i = 0; i < 4; i++) glb[i] = t; for (i = 4; i < 8; i++) glb[i] = a; gl3 = t + glb[2]; }
void fx_ie_l5p(long a) { long t; if (a > gl2) t = rl(); else t = rl() ^ a; gl3 = t; }
void fx_cv_l5p(long a) { long t = a + gl2; v0(); gla[3] = t; gla[4] = t ^ a; }
void fx_lc_l5p(long a) { long t = a; int i; for (i = 0; i < 3; i++) { v0(); glb[i] = t; } gl3 = t; }
void fx_lp_n5p(unsigned long a) { unsigned long t = a ^ gn2; int i; for (i = 0; i < 4; i++) gnb[i] = t; for (i = 4; i < 8; i++) gnb[i] = a; gn3 = t + gnb[2]; }
void fx_ie_n5p(unsigned long a) { unsigned long t; if (a > gn2) t = rn(); else t = rn() ^ a; gn3 = t; }
void fx_cv_n5p(unsigned long a) { unsigned long t = a + gn2; v0(); gna[3] = t; gna[4] = t ^ a; }
void fx_lc_n5p(unsigned long a) { unsigned long t = a; int i; for (i = 0; i < 3; i++) { v0(); gnb[i] = t; } gn3 = t; }
void fx_mx_cb0(void) { char t = (char)(gb1 + gb2); v0(); gc3 = t; }
char fx_mx_cb1(void) { char t = (char)gb1; int i; for (i = 0; i < 4; i++) t ^= (char)gba[i]; return t; }
char fx_mr_cb(char a, unsigned char b) { v0(); return a ^ (char)b; }
void fx_mx_ci0(void) { char t = (char)(gi1 + gi2); v0(); gc3 = t; }
char fx_mx_ci1(void) { char t = (char)gi1; int i; for (i = 0; i < 4; i++) t ^= (char)gia[i]; return t; }
char fx_mr_ci(char a, int b) { v0(); return a ^ (char)b; }
void fx_mx_cu0(void) { char t = (char)(gu1 + gu2); v0(); gc3 = t; }
char fx_mx_cu1(void) { char t = (char)gu1; int i; for (i = 0; i < 4; i++) t ^= (char)gua[i]; return t; }
char fx_mr_cu(char a, unsigned int b) { v0(); return a ^ (char)b; }
void fx_mx_cl0(void) { char t = (char)(gl1 + gl2); v0(); gc3 = t; }
char fx_mx_cl1(void) { char t = (char)gl1; int i; for (i = 0; i < 4; i++) t ^= (char)gla[i]; return t; }
char fx_mr_cl(char a, long b) { v0(); return a ^ (char)b; }
void fx_mx_cn0(void) { char t = (char)(gn1 + gn2); v0(); gc3 = t; }
char fx_mx_cn1(void) { char t = (char)gn1; int i; for (i = 0; i < 4; i++) t ^= (char)gna[i]; return t; }
char fx_mr_cn(char a, unsigned long b) { v0(); return a ^ (char)b; }
void fx_mx_bc0(void) { unsigned char t = (unsigned char)(gc1 + gc2); v0(); gb3 = t; }
unsigned char fx_mx_bc1(void) { unsigned char t = (unsigned char)gc1; int i; for (i = 0; i < 4; i++) t ^= (unsigned char)gca[i]; return t; }
unsigned char fx_mr_bc(unsigned char a, char b) { v0(); return a ^ (unsigned char)b; }
void fx_mx_bi0(void) { unsigned char t = (unsigned char)(gi1 + gi2); v0(); gb3 = t; }
unsigned char fx_mx_bi1(void) { unsigned char t = (unsigned char)gi1; int i; for (i = 0; i < 4; i++) t ^= (unsigned char)gia[i]; return t; }
unsigned char fx_mr_bi(unsigned char a, int b) { v0(); return a ^ (unsigned char)b; }
void fx_mx_bu0(void) { unsigned char t = (unsigned char)(gu1 + gu2); v0(); gb3 = t; }
unsigned char fx_mx_bu1(void) { unsigned char t = (unsigned char)gu1; int i; for (i = 0; i < 4; i++) t ^= (unsigned char)gua[i]; return t; }
unsigned char fx_mr_bu(unsigned char a, unsigned int b) { v0(); return a ^ (unsigned char)b; }
void fx_mx_bl0(void) { unsigned char t = (unsigned char)(gl1 + gl2); v0(); gb3 = t; }
unsigned char fx_mx_bl1(void) { unsigned char t = (unsigned char)gl1; int i; for (i = 0; i < 4; i++) t ^= (unsigned char)gla[i]; return t; }
unsigned char fx_mr_bl(unsigned char a, long b) { v0(); return a ^ (unsigned char)b; }
void fx_mx_bn0(void) { unsigned char t = (unsigned char)(gn1 + gn2); v0(); gb3 = t; }
unsigned char fx_mx_bn1(void) { unsigned char t = (unsigned char)gn1; int i; for (i = 0; i < 4; i++) t ^= (unsigned char)gna[i]; return t; }
unsigned char fx_mr_bn(unsigned char a, unsigned long b) { v0(); return a ^ (unsigned char)b; }
void fx_mx_ic0(void) { int t = (int)(gc1 + gc2); v0(); gi3 = t; }
int fx_mx_ic1(void) { int t = (int)gc1; int i; for (i = 0; i < 4; i++) t ^= (int)gca[i]; return t; }
int fx_mr_ic(int a, char b) { v0(); return a ^ (int)b; }
void fx_mx_ib0(void) { int t = (int)(gb1 + gb2); v0(); gi3 = t; }
int fx_mx_ib1(void) { int t = (int)gb1; int i; for (i = 0; i < 4; i++) t ^= (int)gba[i]; return t; }
int fx_mr_ib(int a, unsigned char b) { v0(); return a ^ (int)b; }
void fx_mx_iu0(void) { int t = (int)(gu1 + gu2); v0(); gi3 = t; }
int fx_mx_iu1(void) { int t = (int)gu1; int i; for (i = 0; i < 4; i++) t ^= (int)gua[i]; return t; }
int fx_mr_iu(int a, unsigned int b) { v0(); return a ^ (int)b; }
void fx_mx_il0(void) { int t = (int)(gl1 + gl2); v0(); gi3 = t; }
int fx_mx_il1(void) { int t = (int)gl1; int i; for (i = 0; i < 4; i++) t ^= (int)gla[i]; return t; }
int fx_mr_il(int a, long b) { v0(); return a ^ (int)b; }
void fx_mx_in0(void) { int t = (int)(gn1 + gn2); v0(); gi3 = t; }
int fx_mx_in1(void) { int t = (int)gn1; int i; for (i = 0; i < 4; i++) t ^= (int)gna[i]; return t; }
int fx_mr_in(int a, unsigned long b) { v0(); return a ^ (int)b; }
void fx_mx_uc0(void) { unsigned int t = (unsigned int)(gc1 + gc2); v0(); gu3 = t; }
unsigned int fx_mx_uc1(void) { unsigned int t = (unsigned int)gc1; int i; for (i = 0; i < 4; i++) t ^= (unsigned int)gca[i]; return t; }
unsigned int fx_mr_uc(unsigned int a, char b) { v0(); return a ^ (unsigned int)b; }
void fx_mx_ub0(void) { unsigned int t = (unsigned int)(gb1 + gb2); v0(); gu3 = t; }
unsigned int fx_mx_ub1(void) { unsigned int t = (unsigned int)gb1; int i; for (i = 0; i < 4; i++) t ^= (unsigned int)gba[i]; return t; }
unsigned int fx_mr_ub(unsigned int a, unsigned char b) { v0(); return a ^ (unsigned int)b; }
void fx_mx_ui0(void) { unsigned int t = (unsigned int)(gi1 + gi2); v0(); gu3 = t; }
unsigned int fx_mx_ui1(void) { unsigned int t = (unsigned int)gi1; int i; for (i = 0; i < 4; i++) t ^= (unsigned int)gia[i]; return t; }
unsigned int fx_mr_ui(unsigned int a, int b) { v0(); return a ^ (unsigned int)b; }
void fx_mx_ul0(void) { unsigned int t = (unsigned int)(gl1 + gl2); v0(); gu3 = t; }
unsigned int fx_mx_ul1(void) { unsigned int t = (unsigned int)gl1; int i; for (i = 0; i < 4; i++) t ^= (unsigned int)gla[i]; return t; }
unsigned int fx_mr_ul(unsigned int a, long b) { v0(); return a ^ (unsigned int)b; }
void fx_mx_un0(void) { unsigned int t = (unsigned int)(gn1 + gn2); v0(); gu3 = t; }
unsigned int fx_mx_un1(void) { unsigned int t = (unsigned int)gn1; int i; for (i = 0; i < 4; i++) t ^= (unsigned int)gna[i]; return t; }
unsigned int fx_mr_un(unsigned int a, unsigned long b) { v0(); return a ^ (unsigned int)b; }
void fx_mx_lc0(void) { long t = (long)(gc1 + gc2); v0(); gl3 = t; }
long fx_mx_lc1(void) { long t = (long)gc1; int i; for (i = 0; i < 4; i++) t ^= (long)gca[i]; return t; }
long fx_mr_lc(long a, char b) { v0(); return a ^ (long)b; }
void fx_mx_lb0(void) { long t = (long)(gb1 + gb2); v0(); gl3 = t; }
long fx_mx_lb1(void) { long t = (long)gb1; int i; for (i = 0; i < 4; i++) t ^= (long)gba[i]; return t; }
long fx_mr_lb(long a, unsigned char b) { v0(); return a ^ (long)b; }
void fx_mx_li0(void) { long t = (long)(gi1 + gi2); v0(); gl3 = t; }
long fx_mx_li1(void) { long t = (long)gi1; int i; for (i = 0; i < 4; i++) t ^= (long)gia[i]; return t; }
long fx_mr_li(long a, int b) { v0(); return a ^ (long)b; }
void fx_mx_lu0(void) { long t = (long)(gu1 + gu2); v0(); gl3 = t; }
long fx_mx_lu1(void) { long t = (long)gu1; int i; for (i = 0; i < 4; i++) t ^= (long)gua[i]; return t; }
long fx_mr_lu(long a, unsigned int b) { v0(); return a ^ (long)b; }
void fx_mx_ln0(void) { long t = (long)(gn1 + gn2); v0(); gl3 = t; }
long fx_mx_ln1(void) { long t = (long)gn1; int i; for (i = 0; i < 4; i++) t ^= (long)gna[i]; return t; }
long fx_mr_ln(long a, unsigned long b) { v0(); return a ^ (long)b; }
void fx_mx_nc0(void) { unsigned long t = (unsigned long)(gc1 + gc2); v0(); gn3 = t; }
unsigned long fx_mx_nc1(void) { unsigned long t = (unsigned long)gc1; int i; for (i = 0; i < 4; i++) t ^= (unsigned long)gca[i]; return t; }
unsigned long fx_mr_nc(unsigned long a, char b) { v0(); return a ^ (unsigned long)b; }
void fx_mx_nb0(void) { unsigned long t = (unsigned long)(gb1 + gb2); v0(); gn3 = t; }
unsigned long fx_mx_nb1(void) { unsigned long t = (unsigned long)gb1; int i; for (i = 0; i < 4; i++) t ^= (unsigned long)gba[i]; return t; }
unsigned long fx_mr_nb(unsigned long a, unsigned char b) { v0(); return a ^ (unsigned long)b; }
void fx_mx_ni0(void) { unsigned long t = (unsigned long)(gi1 + gi2); v0(); gn3 = t; }
unsigned long fx_mx_ni1(void) { unsigned long t = (unsigned long)gi1; int i; for (i = 0; i < 4; i++) t ^= (unsigned long)gia[i]; return t; }
unsigned long fx_mr_ni(unsigned long a, int b) { v0(); return a ^ (unsigned long)b; }
void fx_mx_nu0(void) { unsigned long t = (unsigned long)(gu1 + gu2); v0(); gn3 = t; }
unsigned long fx_mx_nu1(void) { unsigned long t = (unsigned long)gu1; int i; for (i = 0; i < 4; i++) t ^= (unsigned long)gua[i]; return t; }
unsigned long fx_mr_nu(unsigned long a, unsigned int b) { v0(); return a ^ (unsigned long)b; }
void fx_mx_nl0(void) { unsigned long t = (unsigned long)(gl1 + gl2); v0(); gn3 = t; }
unsigned long fx_mx_nl1(void) { unsigned long t = (unsigned long)gl1; int i; for (i = 0; i < 4; i++) t ^= (unsigned long)gla[i]; return t; }
unsigned long fx_mr_nl(unsigned long a, long b) { v0(); return a ^ (unsigned long)b; }
