/* cc900 FP frame temporaries, E3 (slot count and sharing), round 1.  Our own C89; research-scratch
   sessions/2026-11-10_cc900-fp-e3 (README there has the questions, predictions and results).
   Families:
     e*  the second half of the temporary region (region = 2 x D): which statements remove it (fpp8 mv10 / nv10:
         `gi = gi2;` after the FP statements gives region = D; the library's _sqrt / _pow / _fmod have no second half)
     s*  _sqrt / _fmod shapes: an int local declared after the doubles
     p*  an operation on two temporaries: which operand's slot takes the result
     f*  an operation slot free again inside a statement once its value was read (pushed or consumed)
     l*  which free slot an operation inside a loop body takes
     r*  reserved slots: a global store whose computed operand is a call; O statements
     d*  the long shadow (region = D + D') */
extern double gd, gd2, gd3, gd4, gd5, gd6, gd7, gd8, gd9, e1, e2, e3, e4;
extern int gi, gi2, gi3, gia[4];
extern long gl, gl2;
extern char gc, gc2;
extern unsigned gu, gu2;
extern int *gp, *gp2;
extern double fd(double);
extern void vd(double);
extern double frexp(double, int *);
extern double ldexp(double, int);

void e00(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); }
void e01(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; }
void e02(void) { gi = gi2; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); }
void e03(void) { fd(e1); gi = gi2; fd(e2); gd = (gd2 - 1.0) * (gd3 + 1.0); }
void e04(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 + 1; }
void e05(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = -gi2; }
void e06(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi2 = gi; }
void e07(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gl = gl2; }
void e08(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gc = gc2; }
void e09(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gd3 = gd4; }
void e10(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gp = gp2; }
void e11(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi; }
void e12(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gd4 = gd5 * gd6; }
void e13(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; fd(e3); }
void e14(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); if (gi) gi = gi2; }
void e15(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 & 1; }
void e16(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2 == 3; }
void e17(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi = 9; }
void e18(int n) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = n; }
void e19(int n) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); n = gi; gi2 = n; }
void e20(void) { int i; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); i = gi; gi2 = i; }
void e21(void) { int i; i = gi2; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = i; }
void e22(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gia[1]; }
void e23(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gia[1] = gi; }
void e24(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); *gp = gi; }
void e25(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = *gp; }
void e26(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = (int)gl; }
void e27(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gl = gi; }
void e28(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gu = gu2; }
double e30(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; return gd; }
double e31(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; return gd * gd2; }
void e32(void) { fd(gd * gd2); gi = gi2; }
void e33(void) { gd = gd2 * gd3 + gd4; gi = gi2; }
void e34(void) { gi = gi2; gi = gi3; gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); }
void e35(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gi2; gi2 = gi3; }
void e36(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gc = gi; }
void e37(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); fd(e1); fd(e2); gi = gc; }

double s01(double x) { double f, y; int n; f = frexp(x, &n); y = f * 2.0 + f / y; return y; }
double s02(double x) { int n; double f, y; f = frexp(x, &n); y = f * 2.0 + f / y; return y; }
double s03(double x) { double f, y; f = frexp(x, &gi); y = f * 2.0 + f / y; return y; }
double s04(double x) { double f, y; int n; f = frexp(x, &n); y = f * 2.0 + f / y; return ldexp(y, n / 2); }
double s05(double x) { double f, y; int n; n = gi; f = x * 2.0 + x / y; return f * n; }
double s06(double x, double y) { double x1, y1, val; int ex; ex = gi; val = ldexp(y, ex); x1 = x - val * 0.5; return x1; }
double s07(double x) { int ex; double v; ex = gi; v = x - gd * 0.5; return v; }
double s08(double x) { double v; int ex; ex = gi; v = x - gd * 0.5; return v; }
double s09(double x) { double v; int ex; v = x - gd * 0.5; ex = gi; gi2 = ex; return v; }
double s10(double x) { double f, y; int n; f = frexp(x, &n); y = f * 2.0 + f / y; gi = gi2; return y; }

void p01(void) { gd = (gd2 - 1.0) * (gd3 + 1.0) + gd4; }
void p02(void) { gd = gi * gd2 + gd3 * gd4; }
void p03(void) { gd = gd3 * gd4 + gi * gd2; }
void p04(void) { gd = (fd(e1) * gd2 - 1.0) * (gd3 + 1.0) + gd4; }
void p05(void) { gd = (gd3 + 1.0) * (fd(e1) * gd2 - 1.0) + gd4; }
double p06(double x) { return (x - 3.0) / (x + 4.0); }
void p07(void) { gd = (gd2 - 1.0) * (gd3 + 2.0); gd4 = (gd5 - 3.0) / (gd6 + 4.0) + gd7; }
void p08(void) { gd = gd2 * gd3 + gd4; gd5 = (gd6 - 1.0) * (gd7 + 1.0) + gd8; }
void p09(void) { gd = gd2 * gd3 + gd4; gd5 = (gd6 - 1.0) / (gd7 + 1.0) + gd8; }
void p10(void) { gd = gd2 * gd3 + gd4; gd5 = (gd6 - 1.0) - (gd7 + 1.0) + gd8; }
void p11(void) { gd = gd2 * gd3 + gd4; gd5 = (gd6 - 1.0) + (gd7 + 1.0) + gd8; }
void p12(void) { gd = gd2 * gd3 + gd4; gd5 = ((gd6 - 1.0) * (gd7 + 1.0)) * ((gd8 + 2.0) * (gd9 + 3.0)); }
double p13(int n, double s) { double t; t = s; return gd * n + 2 * t; }
double p14(int n, double s) { return gd * n + 2 * s; }
void p15(void) { gd = gd2 * gd3 + gd4; gd5 = (gd7 + 1.0) * (gd6 - 1.0) + gd8; }
void p16(void) { gd = gd2 * gd3 + gd4; gd5 = (gd6 - 1.0) * (gd7 + 1.0); }

void f01(void) { gd = fd(-gd2) + fd(gd3); }
void f02(void) { gd = fd(gd3) + fd(-gd2); }
void f03(void) { gd = fd(-gd2) + gd3; }
void f04(void) { gd = fd(-gd2) * fd(-gd3); }
void f05(void) { gd = fd(gd2 - 1.0) + (gd3 + 1.0); }
void f06(void) { gd = (gd3 + 1.0) + fd(gd2 - 1.0); }
void f07(void) { fd(fd(-gd2)); }
void f08(void) { gd = fd(-gd2) + fd(gd3) + fd(-gd4); }
void f09(void) { gd = (gd2 - 1.0) * gd3 + fd(gd4 + 1.0); }
void f10(void) { gd = fd(gd2 - 1.0) * (gd3 + 1.0) + (gd4 + 2.0); }
void f11(void) { gd = fd(fd(-gd2) + 1.0) + gd3; }
void f12(void) { gd = fd(-gd2) + fd(gd3) + gd4; }

void l01(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); do { gd4 = gd5 * gd6 + gd7; } while (gi--); }
void l02(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); while (gi--) { gd4 = gd5 * gd6 + gd7; } }
void l03(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); for (; gi; gi--) { gd4 = gd5 * gd6 + gd7; } }
void l04(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); if (gi) { gd4 = gd5 * gd6 + gd7; } }
void l05(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd5 * gd6 + gd7; }
void l06(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); do { gd4 = gd5 * gd6 + gd7; gd8 = (gd9 - 1.0) * (gd2 + 1.0); } while (gi--); }
void l07(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); do { gd4 = (gd5 - 1.0) * (gd6 + 1.0) + gd7; } while (gi--); }
void l08(void) { do { gd4 = gd5 * gd6 + gd7; } while (gi--); gd = (gd2 - 1.0) * (gd3 + 1.0); }
void l09(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); L1: gd4 = gd5 * gd6 + gd7; if (gi--) goto L1; }
void l10(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); do { gd4 += gd5 / gi; } while (gd4 != gd8); }

void r01(void) { gd = fd(gd2) * gd3; }
void r02(void) { gd = gd3 * fd(gd2); }
double r03(void) { double t; t = fd(gd2) * gd3; return t; }
double r04(void) { return fd(gd2) * gd3; }
void r05(void) { gd = fd(gd2) * gd3; gd4 = fd(gd5) * gd6; }
void r06(void) { gd = fd(gd2) * gd3; fd(e1); }
void r07(void) { gd = fd(gd2) * fd(gd3); }
void r08(void) { gd = fd(gd2) + fd(gd3) + gd4; }
void r09(void) { gd = -fd(gd2); }
void r10(void) { gd = fd(gd2) - 1.0; }
void r11(void) { gd3 = gd4 * gd; }
void r12(void) { gd3 = gd4 * gd; gd5 = gd6 * gd7; }
void r13(void) { gd3 = gd4 * gd; fd(e1); }
void r14(void) { fd(e1); gd3 = gd4 * gd; }

void d01(void) { gd = gi * gd2; }
void d02(void) { gd = gi * gd2 + gd3; }
void d03(void) { gd = gi * gd2; gd3 = gi2 * gd4; }
