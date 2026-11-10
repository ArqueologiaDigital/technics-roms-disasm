/* cc900 FP frame temporaries, E3 round 2.  Our own C89; research-scratch sessions/2026-11-10_cc900-fp-e3.
   Families:
     t*  the region size as a counter kept across two passes (fpp10 e13: `T; gi = gi2; fd(e3)` is 40 = 8 + 32):
         several resetting copies with FP code of different sizes between them
     w*  which statements reset (fpp10: an int / pointer copy between memory objects does, `gi = -gi2`,
         conversions, a copy through a register local and `gi = gi` do not)
     q*  the library's _sqrt / _fmod / _pow shapes, which have no second half without any such copy
     d*  the long shadow (D' in region = D + D')
     lg* _log clones (the loop's slot, the return's result slot, the longs) */
struct S { int a; double d; };
extern double gd, gd2, gd3, gd4, gd5, gd6, gd7, gd8, e1, e2, e3, e4;
extern float gf, gf2;
extern int gi, gi2, gi3, gi4, gia[4];
extern unsigned gu, gu2;
extern long gl, gl2;
extern char gc, gca[4];
extern int *gp, *gp2;
extern struct S gs, *gps;
extern double fd(double);
extern int fi(int);
extern void vi(int *);
extern double frexp(double, int *);
extern double ldexp(double, int);

/* B1 = fd(e1); fd(e2);   B2 = gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2);   B3 = fd(e1); */
void t01(void) { fd(e1); fd(e2); gi = gi2; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi3 = gi4; fd(e1); }
void t02(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; fd(e1); gi3 = gi4; fd(e1); fd(e2); }
void t03(void) { fd(e1); gi = gi2; fd(e1); fd(e2); gi3 = gi4; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); }
void t04(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; fd(e1); }
void t05(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gd4 = (gd5 - 1.0) * (gd6 + 1.0); fd(e3); fd(e4); }
void t06(void) { fd(e1); fd(e2); gi = gi2; fd(e3); fd(e4); gi3 = gi4; fd(e1); fd(e2); }
void t07(void) { gi = gi2; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi3 = gi4; }
void t08(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi3 = gi4; }
void t09(void) { fd(e1); fd(e2); gi = gi2; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi3 = gi4; }
void t10(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; fd(e1); fd(e2); gi3 = gi4; }
void t11(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gi = gi2; gd4 = gd5 * gd6 + gd7; }
void t12(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gi = gi2; gd4 = (gd5 - 1.0) * (gd6 + 1.0); }
void t13(void) { fd(e1); gi = gi2; fd(e2); gi3 = gi4; fd(e3); gi = gi4; fd(e4); }
void t14(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); fd(e3); gi = gi2; fd(e4); fd(e1); }

void w01(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gia[gi2]; }
void w02(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gia[gi2] = gi; }
void w03(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gs.a; }
void w04(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gs.a = gi; }
void w05(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gps->a; }
void w06(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gp = &gi; }
void w07(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2, gi3 = gi4; }
void w08(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 = gi3; }
void w09(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = (int)gu2; }
void w10(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gu = gi2; }
void w11(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gf = gf2; }
void w12(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); ++gi; }
void w13(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi++; }
void w14(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi += 1; }
void w15(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi += gi2; }
void w16(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi + 1; }
void w17(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi--; }
void w18(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gl++; }
void w19(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); *gp = *gp2; }
void w20(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gc = gca[1]; }
void w21(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi = -gi; }
void w22(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = -gi; gi = gi2; }
void w23(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); while (gi) gi = gi2; }
void w24(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); for (gi = gi2; gi; gi--) ; }
void w25(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); if (gi) gi = gi2; else gi = gi3; }
void w26(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 ? gi3 : gi4; }
void w27(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi2 = gi; }
void w28(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi3 = gi; }
void w29(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi3 = gi2; }
void w30(void) { int n; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); n = gi; vi(&n); }
void w31(void) { int n; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); vi(&n); gi = n; }
void w32(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 + 0; }
void w33(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = +gi2; }
void w34(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = (gi2); }
void w35(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); fi(gi); }
void w36(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = fi(1); }
void w37(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = fi(gi2); }
void w38(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gia[1]; gi2 = gia[2]; }
void w39(int *p) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); *p = gi; }
void w40(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gd3 = fd(gd4); }
void w41(void) { gi = 1; gd3 = gi * gd4; fd(e1); fd(e2); }
void w42(void) { gi = 1; gd3 = gi * gd4; gi = gi + 1; fd(e1); fd(e2); }
void w43(void) { gd3 = gi * gd4; fd(e1); fd(e2); gi = gi + 1; }
void w44(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi = 1; gi = gi + 1; }
void w45(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi + gi2; }
void w46(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gl = gl2 + 1; }
void w47(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); if (gi & 1) gi2 = 1; }
void w48(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); if (gi) gi2 = 1; }
void w49(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); if (gi == gi2) gi3 = 1; }
void w50(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 * gi3; }

double q01(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; ++n; } return ldexp(y, n / 2); }
double q02(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); return ldexp(y, n / 2); }
double q03(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; } return ldexp(y, n / 2); }
double q04(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; n += 1; } return ldexp(y, n / 2); }
double q05(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; n = n + 1; } return ldexp(y, n / 2); }
double q06(double x) { double f, y; int n; f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; ++n; } return ldexp(y, n / 2); }
double q07(double x) { double f, y; int n; if (x == 0.0) return x; if (x < 0.0) { gi = 33; return 0.0; } f = frexp(x, &n); y = e1 + e2 * f; y = (y + f / y); y = ldexp(y, -2) + f / y; y = ldexp(y + f / y, -1); y = ldexp(y + f / y, -1); if (n & 1) { y *= e3; ++n; } return ldexp(y, n); }
double q08(double x) { int n; double f; f = frexp(x, &n); ++n; return f * n; }
double q09(double x) { int n; double f; f = frexp(x, &n); return f * n; }
double q10(double x) { int n; double f; f = frexp(x, &n); n = n + 1; return f * n; }
double q11(double x) { double f; f = frexp(x, &gi); ++gi; return f * gi; }
double q12(double x) { int n; double f; f = frexp(x, &n); if (n & 1) f *= 2.0; return f; }
double q13(double x) { int n; double f; f = frexp(x, &n); if (n) f *= 2.0; return f; }
double q14(double x) { int n; double f; f = frexp(x, &n); if (n & 1) f *= 2.0; ++n; return f * n; }
double q15(double x) { int n; double f; f = frexp(x, &n); return ldexp(f * 2.0, n / 2); }
double q16(double x) { int n; double f; f = frexp(x, &n); if (n & 1) { f *= 2.0; ++n; } return ldexp(f * 2.0, n / 2); }
double q17(double x, double y) { unsigned short *p; double x1, val; p = (unsigned short *)&y; gi = (p[3] >> 4) & 0x7ff; x1 = x; val = ldexp(y, gi); x1 -= val * 0.5; return x1; }
double q18(double x, double y) { double x1, val; x1 = x; val = ldexp(y, gi); x1 -= val * 0.5; return x1; }
double q19(double x, double y) { long yy; double ret; int bk; bk = gi; yy = (long)y; ret = x * yy; gi = bk; return ret; }
double q20(double x, double y) { long yy; double ret; yy = (long)y; ret = x * yy; return ret; }
double q21(double x, double y) { long yy; double ret; yy = (long)y; if (yy < 0) yy = -yy; ret = x * yy; return ret; }
double q22(double x) { int n; double f; f = frexp(x, &n); if (n & 1) { f *= 2.0; ++n; } return f; }
double q23(double x) { int n; double f; f = frexp(x, &n); if (n & 1) { f *= 2.0; } ++n; return f; }

void d10(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gi * gd5; }
void d11(void) { gd4 = gi * gd5; gd = (gd2 - 1.0) * (gd3 + 1.0); }
void d12(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gi * gd5 + gi2 * gd6; }
void d13(void) { gd = gi * gd2; gd3 = gi2 * gd4; gd5 = gi3 * gd6; }
void d14(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gi * gd5; gd6 = gi2 * gd7; }
void d15(void) { fd(e1); gd4 = gi * gd5; }
void d16(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); gd4 = gi * gd5; }
void d17(void) { gd = gd2 * gd3 + gd4; gd5 = gi * gd6; }

void lg1(void) { frexp(gd / gd2, &gi); gd /= ldexp(1.0, gi); gd = (gd - 1.0) / (gd + 1.0); gd3 = gd * gd; gi2 = 1; gd4 = gd; do { gd *= gd3; gi2 += 2; gd5 = gd4; gd4 += gd / gi2; } while (gd5 != gd4); gd6 = gd7 * gi + 2.0 * gd4; }
double lg2(double x) { int nptr; double x2, s, last; frexp(x / gd2, &nptr); x /= ldexp(1.0, nptr); x = (x - 1.0) / (x + 1.0); x2 = x * x; gi = 1; s = x; do { x *= x2; gi += 2; last = s; s += x / gi; } while (last != s); return gd7 * nptr + 2.0 * s; }
double lg3(double x) { int i, nptr; double x2, s, last; frexp(x / gd2, &nptr); x /= ldexp(1.0, nptr); x = (x - 1.0) / (x + 1.0); x2 = x * x; i = 1; s = x; do { x *= x2; i += 2; last = s; s += x / i; } while (last != s); return gd7 * nptr + 2.0 * s; }
double lg4(double x) { int nptr; double s; frexp(x / gd2, &nptr); x = (x - 1.0) / (x + 1.0); s = x; do { s += x / gi; } while (gd5 != s); return gd7 * nptr + 2.0 * s; }
