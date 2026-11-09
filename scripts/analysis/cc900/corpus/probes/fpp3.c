/* cc900 FP frame temporaries, round 3 (E2): how statements that need no temporary in the final code move the
   temporaries of other statements.  Families with only call slots (p), only operation slots (t, s), both (u, v, m,
   n), and the kind of statement that moves them (k).  O = an operation stored straight to a global.  Our own C89;
   research-scratch sessions/2026-11-09_cc900-fp-e2. */
extern double gd, gd2, gd3, gd4; extern int gi;
extern double fd(double); extern void vd(double);

/* P: call slots only, O statements after / before / between */
void p0(void) { fd(gd); fd(gd2); }
void p1(void) { fd(gd); fd(gd2); gd3 = gd4 * gd; }
void p2(void) { fd(gd); fd(gd2); gd3 = gd4 * gd; gd4 = gd3 * gd2; }
void p3(void) { fd(gd); fd(gd2); gd3 = gd4 * gd; gd4 = gd3 * gd2; gd = gd2 * gd3; }
void p4(void) { gd3 = gd4 * gd; fd(gd); fd(gd2); }
void p5(void) { fd(gd); fd(gd2); fd(gd3); }
void p6(void) { fd(gd); fd(gd2); fd(gd3); gd3 = gd4 * gd; }
void p7(void) { fd(gd); fd(gd2); fd(gd3); gd3 = gd4 * gd; gd4 = gd3 * gd2; }
void p8(void) { fd(gd); fd(gd2); fd(gd3); gd3 = gd4 * gd; gd4 = gd3 * gd2; gd = gd2 * gd3; }
void p9(void) { fd(gd); gd3 = gd4 * gd; fd(gd2); gd4 = gd3 * gd2; fd(gd3); }
void p10(void) { fd(gd); fd(gd2); fd(gd3); fd(gd4); }
void p11(void) { fd(gd); fd(gd2); fd(gd3); fd(gd4); gd3 = gd4 * gd; }
void p12(void) { gd3 = gd4 * gd; gd4 = gd3 * gd2; fd(gd); fd(gd2); fd(gd3); }

/* T: two operation slots in one statement */
void t0(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); }
void t1(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd * gd2; }
void t2(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd * gd2; gd3 = gd4 * gd; }
void t3(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd * gd2; gd3 = gd4 * gd; gd2 = gd3 * gd; }
void t4(void) { gd4 = gd * gd2; gd = (gd2 - 1.0) * (gd3 + 1.0); }
void t5(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd * gd2 + gd3; }
void t6(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = gd * gd2 + gd3; gd3 = gd4 * gd + gd2; }
void t7(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd4 = (gd - 2.0) * (gd2 + 2.0); }
void t8(void) { gd = (gd2 - 1.0) * (gd3 + 1.0); gd3 = gd4 * gd; gd4 = (gd - 2.0) * (gd2 + 2.0); }
void t9(void) { gd4 = gd * gd2; gd3 = gd4 * gd; gd = (gd2 - 1.0) * (gd3 + 1.0); }

/* S: three operation slots in one statement */
void s0(void) { gd = (gd2 - 1.0) * (gd3 + 1.0) * (gd4 + 2.0); }
void s1(void) { gd = (gd2 - 1.0) * (gd3 + 1.0) * (gd4 + 2.0); gd4 = gd * gd2; }
void s2(void) { gd = (gd2 - 1.0) * (gd3 + 1.0) * (gd4 + 2.0); gd4 = gd * gd2; gd3 = gd4 * gd; }
void s3(void) { gd = (gd2 - 1.0) * (gd3 + 1.0) * (gd4 + 2.0); gd4 = gd * gd2; gd3 = gd4 * gd; gd2 = gd3 * gd; }
void s4(void) { gd4 = gd * gd2; gd = (gd2 - 1.0) * (gd3 + 1.0) * (gd4 + 2.0); }

/* V: a discarded call with a computed argument, then 3 / 4 O statements (parity beyond two) */
void v3(void) { fd(gd * gd2); gd3 = gd4 * gd; gd4 = gd3 * gd2; gd = gd2 * gd3; }
void v4(void) { fd(gd * gd2); gd3 = gd4 * gd; gd4 = gd3 * gd2; gd = gd2 * gd3; gd2 = gd * gd4; }
void v5(void) { fd(gd * gd2); gd3 = gd4 * gd + gd2; gd4 = gd3 * gd2; }

/* U: a call statement and an operation statement (a4) with O statements */
void u0(void) { fd(gd); gd3 = gd4 * gd + gd2; }
void u1(void) { fd(gd); gd3 = gd4 * gd + gd2; gd4 = gd3 * gd2; }
void u2(void) { fd(gd); gd3 = gd4 * gd + gd2; gd4 = gd3 * gd2; gd = gd2 * gd3; }
void u3(void) { fd(gd); gd4 = gd3 * gd2; gd3 = gd4 * gd + gd2; }
void u4(void) { gd3 = gd4 * gd + gd2; fd(gd); gd4 = gd3 * gd2; }
void u5(void) { gd3 = gd4 * gd + gd2; gd4 = gd3 * gd2; fd(gd); }

/* K: which kinds of statement move the slots of fd(gd * gd2) (w1: an O does, w2: a copy does not) */
void k1(void) { fd(gd * gd2); gi = gd4 > gd; }
void k2(void) { fd(gd * gd2); if (gd4 > gd) gi = 1; }
void k3(void) { fd(gd * gd2); gd3 = gd4 + 1.0; }
void k4(void) { fd(gd * gd2); gd3 = (double)gi; }
void k5(void) { fd(gd * gd2); gi = (int)gd4; }
void k6(void) { fd(gd * gd2); vd(gd4); }
void k7(void) { fd(gd * gd2); gd3 = fd(gd4); }
void k8(void) { fd(gd * gd2); gd3 = gd4 * gd; gd3 = gd4; }
void k9(void) { fd(gd * gd2); gd3 = -gd4; gd = -gd2; }
void k10(void) { fd(gd * gd2); gd3 += gd4; }

/* M: calls with and without a computed argument */
void m1(void) { fd(gd * gd2); fd(gd3); fd(gd4); }
void m2(void) { fd(gd); fd(gd2 * gd3); }
void m3(void) { fd(gd); fd(gd2); fd(gd3 * gd4); }
void m4(void) { fd(gd); fd(gd2 * gd3); fd(gd4); }

/* N: one operation slot and two calls in one statement */
void n0(void) { gd = fd(-gd2) + fd(gd3); }
void n1(void) { gd = fd(gd2) + fd(-gd3); }
void n2(void) { gd4 = gd * gd2; gd = fd(gd2) + fd(-gd3); }
void n3(void) { gd = fd(gd2) + fd(-gd3); gd4 = gd * gd2; }
void n4(void) { gd4 = gd * gd2; gd3 = gd4 * gd; gd = fd(gd2) + fd(-gd3); }
void n5(void) { gd = fd(gd2) + fd(-gd3); gd4 = gd * gd2; gd3 = gd4 * gd; }
double n6(double x) { return fd(x) + fd(-x); }
double n7(double x) { gd = x * gd2; return fd(x) + fd(-x); }
