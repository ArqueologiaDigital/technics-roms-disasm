/* A bare-declared int loop counter (gen_loopctr.py): lc_<L><B><P>.  L: D do { } while (--i > 0) from 7, F for
   (i = 0; i < 8; i++), W while (i < 8) { ... i++; } from 0.  B: E gia[i] = gi3 + 100, G gc2 ^= 8 & gc, T both,
   C vi(i), X gi2 += gia[i].  P: N nothing before, F a double expression before the loop. */
extern int gia[8], gi2, gi3; extern char gc, gc2; extern double gd, gd2, gda[4]; void vi(int);

int lc_DEN(void) { int i; i = 7; do { gia[i] = gi3 + 100; } while (--i > 0); return gi3; }
int lc_DEF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 7; do { gia[i] = gi3 + 100; } while (--i > 0); return gi3; }
int lc_DGN(void) { int i; i = 7; do { gc2 ^= 8 & gc; } while (--i > 0); return gi3; }
int lc_DGF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 7; do { gc2 ^= 8 & gc; } while (--i > 0); return gi3; }
int lc_DTN(void) { int i; i = 7; do { gia[i] = gi3 + 100; gc2 ^= 8 & gc; } while (--i > 0); return gi3; }
int lc_DTF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 7; do { gia[i] = gi3 + 100; gc2 ^= 8 & gc; } while (--i > 0); return gi3; }
int lc_DCN(void) { int i; i = 7; do { vi(i); } while (--i > 0); return gi3; }
int lc_DCF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 7; do { vi(i); } while (--i > 0); return gi3; }
int lc_DXN(void) { int i; i = 7; do { gi2 += gia[i]; } while (--i > 0); return gi3; }
int lc_DXF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 7; do { gi2 += gia[i]; } while (--i > 0); return gi3; }
int lc_FEN(void) { int i; for (i = 0; i < 8; i++) { gia[i] = gi3 + 100; } return gi3; }
int lc_FEF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); for (i = 0; i < 8; i++) { gia[i] = gi3 + 100; } return gi3; }
int lc_FGN(void) { int i; for (i = 0; i < 8; i++) { gc2 ^= 8 & gc; } return gi3; }
int lc_FGF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); for (i = 0; i < 8; i++) { gc2 ^= 8 & gc; } return gi3; }
int lc_FTN(void) { int i; for (i = 0; i < 8; i++) { gia[i] = gi3 + 100; gc2 ^= 8 & gc; } return gi3; }
int lc_FTF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); for (i = 0; i < 8; i++) { gia[i] = gi3 + 100; gc2 ^= 8 & gc; } return gi3; }
int lc_FCN(void) { int i; for (i = 0; i < 8; i++) { vi(i); } return gi3; }
int lc_FCF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); for (i = 0; i < 8; i++) { vi(i); } return gi3; }
int lc_FXN(void) { int i; for (i = 0; i < 8; i++) { gi2 += gia[i]; } return gi3; }
int lc_FXF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); for (i = 0; i < 8; i++) { gi2 += gia[i]; } return gi3; }
int lc_WEN(void) { int i; i = 0; while (i < 8) { gia[i] = gi3 + 100; i++; } return gi3; }
int lc_WEF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 0; while (i < 8) { gia[i] = gi3 + 100; i++; } return gi3; }
int lc_WGN(void) { int i; i = 0; while (i < 8) { gc2 ^= 8 & gc; i++; } return gi3; }
int lc_WGF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 0; while (i < 8) { gc2 ^= 8 & gc; i++; } return gi3; }
int lc_WTN(void) { int i; i = 0; while (i < 8) { gia[i] = gi3 + 100; gc2 ^= 8 & gc; i++; } return gi3; }
int lc_WTF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 0; while (i < 8) { gia[i] = gi3 + 100; gc2 ^= 8 & gc; i++; } return gi3; }
int lc_WCN(void) { int i; i = 0; while (i < 8) { vi(i); i++; } return gi3; }
int lc_WCF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 0; while (i < 8) { vi(i); i++; } return gi3; }
int lc_WXN(void) { int i; i = 0; while (i < 8) { gi2 += gia[i]; i++; } return gi3; }
int lc_WXF(void) { int i; gd = (2.5 + gda[3]) * (gd2 * gd2); i = 0; while (i < 8) { gi2 += gia[i]; i++; } return gi3; }
