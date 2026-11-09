/* cc900 FP frame temporaries, round 1: call slots against argument and operation slots (E2), the pool's choice
   (E3), long temporaries.  Our own C89; research-scratch sessions/2026-11-09_cc900-fp-prepass. */
extern double gd, gd2, gd3, gd4; extern int gi; extern long gl;
extern double fd(double); extern double fx(double, int *); extern double fdi(double, int); extern void vd(double);

/* A: a discarded call with a computed argument (_log's frexp(x/SQRT2, &nptr)) */
void a1(void) { fd(gd * gd2); }
void a2(void) { fd(gd * gd2); gd3 = gd4 * gd + gd2; }
void a3(void) { fd(gd * gd2); gd3 /= fd(gd4); }
void a4(void) { fd(gd); gd3 = gd4 * gd + gd2; }
double a5(double x) { fd(x / gd); x /= fd(gd2); x = (x - 1.0) / (x + 1.0); return x * 2.0 + gd; }
void a6(void) { fx(gd / gd2, &gi); gd3 /= fdi(1.0, gi); }
void a7(void) { vd(gd * gd2); gd3 = gd4 * gd + gd2; }
double a8(double x) { int n; fx(x / gd, &n); x /= fdi(1.0, n); return x; }
double a9(double x) { int n; fx(x / gd, &n); x /= fdi(1.0, n); x = (x - 1.0) / (x + 1.0); return gd2 * n + 2.0 * x; }
void a10(void) { fd(gd); fd(gd * gd2); }
void a11(void) { fd(gd * gd2); fd(gd3); }

/* B: an argument temporary against the calls of later statements (__trig's y * C1) */
void b1(void) { if (fd(gd * gd2) >= 0.5) gi = 1; if (fd(gd3) != gd) gi = 2; }
void b2(void) { if (fd(gd * gd2) >= 0.5) gi = 1; gd3 = fd(gd4) + gd; }
void b3(void) { gd = fd(gd2 * gd3) + gd4; if (fd(gd3) != gd) gi = 2; }
void b4(void) { if (fd(gd3) != gd) gi = 2; if (fd(gd * gd2) >= 0.5) gi = 1; }
void b5(void) { gd4 = gd * gd2 + gd3; if (fd(gd3) != gd) gi = 2; }
void b6(void) { vd(gd * gd2); if (fd(gd3) != gd) gi = 2; }
void b7(void) { if (gd * gd2 >= 0.5) gi = 1; if (fd(gd3) != gd) gi = 2; }

/* C: _cosh / _tanh shapes */
void c1(void) { if (fd(gd) - gd2 > gd3) gi = 1; gd4 = (fd(gd) + fd(-gd)) / 2.0; }
void c2(void) { gd2 = fd(gd) - gd3; gd4 = (fd(gd) + fd(-gd)) / 2.0; }
void c3(void) { if (fd(gd) > gd3) gi = 1; gd4 = (fd(gd) + fd(-gd)) / 2.0; }
void c4(void) { if (gd - gd2 > gd3) gi = 1; gd4 = (fd(gd) + fd(-gd)) / 2.0; }
double c5(double x) { double r; if (fd(x) - gd2 > gd3) return gd; r = (fd(x) + fd(-x)) / 2.0; return r; }
double c6(double x) { double r; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double c7(double x) { double r; if (x > gd) return x; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
double c8(double x) { double r; r = x * gd; r = (fd(x) - fd(-x)) / (fd(x) + fd(-x)); return r; }
void c9(void) { gd = (fd(gd2) - fd(gd3)) / (fd(gd4) + fd(gd)); }
void c10(void) { gd = (fd(gd2) - fd(-gd3)) / 2.0; }

/* D: _pow's call in a loop ahead of an earlier statement's operation */
void d1(int n) { if (gd != (double)gl) gi = 1; while (n--) fd(gd); }
void d2(void) { if (gd != (double)gl) gi = 1; fd(gd); }
void d3(int n) { if (gd != (double)gl) gi = 1; while (n--) fd(gd); fd(gd2); }
void d4(int n) { gd2 = gd * gd3; while (n--) fd(gd); }
void d5(int n) { gd2 = gd * gd3; if (n) fd(gd); }
void d6(void) { if (gd != gd2 * gd3) gi = 1; fd(gd); }
void d7(int n) { if (gd != gd2 * gd3) gi = 1; while (n--) fd(gd); }

/* E: _asin: an operation slot ahead of the first statement's call */
double e1(double x) { if (fd(x) > 1.0) return 0.0; return fd(x / fd(1.0 - x * x)); }
double e2(double x) { if (fd(x) > 1.0) return 0.0; return x / fd(1.0 - x * x); }
double e3(double x) { if (fd(x) > 1.0) return 0.0; return fd(x * x); }
double e4(double x) { if (fd(x) > 1.0) return 0.0; return fd(x) * 2.0; }
double e5(double x) { if (x > 1.0) return 0.0; return fd(x / fd(1.0 - x * x)); }
double e6(double x) { if (fd(x) > 1.0) return 0.0; return x * 2.0 + gd; }

/* F: which free slot a statement takes (E3) */
void f1(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = (gd2 - 1.0) / (gd3 + 1.0); }
double f2(double x) { x = (x - 1.0) * (x + 2.0); x = (x - 3.0) / (x + 4.0); return x; }
double f3(double x) { double t; t = (x - 1.0) * (x + 2.0); t = (t - 3.0) / (t + 4.0); return t; }
void f4(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd2 * gd3 + gd; }
double f5(double x) { x = (x - 1.0) * (x + 2.0); return x * 3.0 + gd; }
void f6(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = (gd - 1.0) * (gd2 + 1.0); gd2 = gd * gd3 + gd4; }
void f7(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = (gd2 - 1.0) * (gd3 + 1.0) * (gd + 2.0); }
double f8(double x) { x = (x - 1.0) * (x + 2.0); return (x - 3.0) / (x + 4.0); }
double f9(double x) { double t; t = (x - 1.0) * (x + 2.0); return t * 3.0 - x * 2.0; }
void f10(void) { gd = gd2 * gd3 - (gd4 + gd); gd4 = gd * gd2 + gd3; }

/* G: long temporaries */
double g1(int n, int m) { return n * gd + m * gd2; }
void g2(int n, int m) { gd = n * gd2 + m * gd3; }
double g3(int n, int m) { double t; t = n * gd2 + m * gd3; return t; }
double g4(int n, int m) { return (double)n + m; }
void g5(int n, int m) { gd = (double)n * m; }
double g6(int n) { return gd * n + gd2 * n; }
void g7(int n) { gd = gd2 * n; gd3 = gd4 * n; }
double g8(int n, double s) { return s * 3.0 + n; }
double g9(int n, double s) { return n + s * 3.0; }
void g10(int n, double s) { gd = s * 3.0 + n * 2.0; }
void g11(int n, double s) { gd = n * 2.0 + s * 3.0; }
double g12(int n, double s) { double t; t = n * 2.0 + s * 3.0; return t; }
double g13(int n) { double t; t = gd * n; return t; }
double g14(int n) { double t; t = gd * n + gd2; return t; }
double g15(int n) { double t; t = gd2 * (gd / n); return t; }
double g16(int n) { double t; t = gd; t *= gd2 / n; return t; }
void g17(int n) { gd *= gd2 / n; }
void g18(int n) { gd = gd2 * (gd3 / n); }
double g19(int n, int m) { double t; t = (double)n * m; return t; }
void g20(int n, int m) { gd = gd2 * n; gd3 = gd4 * m + gd; }
