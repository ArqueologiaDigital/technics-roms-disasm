/* cc900 FP frame temporaries, round 2: does a statement that needs no temporary change where a later statement's
   temporaries go?  (fpp1 c6 / c7 / c8: the same statement, three layouts.)  Our own C89. */
extern double gd, gd2, gd3, gd4; extern int gi;
extern double fd(double); extern void vd(double);

/* X = r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)) after various first statements */
double x0(double x) { double r; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x1(double x) { double r; r = x * gd; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x2(double x) { double r; if (x > gd) return x; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x3(double x) { double r; r = x; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x4(double x) { double r; gi = 1; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x5(double x) { double r; if (x > gd) gi = 1; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x6(double x) { double r; r = x * gd; r = r * gd; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x7(double x) { double r; r = -x; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x8(double x) { double r; r = x * gd + gd2; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x9(double x) { double r; gd = x; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x10(double x) { double r; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); gd = x * gd2; return r; }
double x11(double x) { double r; if (x > gd) return gd2; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x12(double x) { double r; if (x > gd) return x * 2.0; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x13(double x) { double r; r = x * gd; r = x * gd2; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x14(double x) { double r; r = x * gd; r = x * gd2; r = x * gd3; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x15(double x) { double r; r = fd(x); r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x16(double x) { double r; r = gd2 + gd3; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double x17(double x) { double r; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r + 1.0; }

/* Y = the same shape with globals only, after first statements */
void y0(void) { gd = (fd(gd2) - fd(-gd3)) / (fd(gd4) + fd(-gd)); }
void y1(void) { gd = gd2 * gd3; gd = (fd(gd2) - fd(-gd3)) / (fd(gd4) + fd(-gd)); }
void y2(void) { gd = gd2 * gd3; gd4 = gd2 * gd; gd = (fd(gd2) - fd(-gd3)) / (fd(gd4) + fd(-gd)); }
void y3(void) { gi = 1; gd = (fd(gd2) - fd(-gd3)) / (fd(gd4) + fd(-gd)); }
void y4(void) { gd = gd2; gd = (fd(gd2) - fd(-gd3)) / (fd(gd4) + fd(-gd)); }

/* W: a discarded call with a computed argument, then a statement that needs no temporary */
void w1(void) { fd(gd * gd2); gd3 = gd4 * gd; }
void w2(void) { fd(gd * gd2); gd3 = gd4; }
void w3(void) { fd(gd * gd2); gi = 1; }
void w4(void) { gd3 = gd4 * gd; fd(gd * gd2); }
void w5(void) { fd(gd); gd3 = gd4 * gd; }
void w6(void) { fd(gd); gd3 = gd4; }
void w7(void) { fd(gd); if (gd4 > gd) gi = 1; }
void w8(void) { fd(gd * gd2); gd3 = gd4 * gd; gd2 = gd3 * gd; }
void w9(void) { fd(gd * gd2); gd3 = -gd4; }
void w10(void) { fd(gd * gd2); gd3 = gd4 * gd + gd2; gd2 = gd3 * gd + gd4; }
void w11(void) { fd(gd); fd(gd2); }
void w12(void) { fd(gd); gd3 = gd4 * gd; fd(gd2); }
void w13(void) { fd(gd); gd3 = gd4 * gd + gd2; fd(gd2); }
void w14(void) { gd3 = gd4 * gd + gd2; fd(gd); }
void w15(void) { fd(gd * gd2); gd3 = (gd4 - 1.0) * (gd + 1.0); }

/* Z: compared values */
void z1(void) { if (gd * gd2 >= 0.5) gi = 1; fd(gd3); }
void z2(void) { if (gd * gd2 >= 0.5) gi = 1; gd3 = gd4 * gd + gd2; }
void z3(void) { if (gd * gd2 >= 0.5) gi = 1; vd(gd3); }
void z4(void) { if (gd > gd2) gi = 1; if (gd * gd2 >= 0.5) gi = 1; if (fd(gd3) != gd) gi = 2; }
void z5(void) { if (gd * gd2 >= 0.5) gi = 1; if (gd * gd3 >= 0.5) gi = 2; if (fd(gd3) != gd) gi = 3; }
void z6(void) { if (fd(gd) >= 0.5) gi = 1; gd3 = gd4 * gd + gd2; }
void z7(void) { if (fd(gd * gd2) >= 0.5) gi = 1; }
void z8(void) { if (fd(gd * gd2) >= 0.5) gi = 1; fd(gd3); }
void z9(void) { if (fd(gd * gd2) >= 0.5) gi = 1; gd3 = gd4 * gd; }
void z10(void) { if (fd(gd * gd2) >= 0.5) gi = 1; gd3 = gd4 * gd + gd2; }
void z11(void) { gi = fd(gd * gd2) >= 0.5; gi = fd(gd3) != gd; }
