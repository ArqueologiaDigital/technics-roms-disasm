/* Nested double expressions: temporaries and the result pointer */
extern double gd, gd2, gd3, gd4; extern double fd(double); extern void g0(void); extern int gi;
double t_mla(void) { return gd * gd2 + gd3; }
double t_amla(void) { return gd3 + gd * gd2; }
double t_mm(void) { return gd * gd2 + gd3 * gd4; }
double t_am(void) { return (gd + gd2) * gd3; }
double t_ma(void) { return gd3 * (gd + gd2); }
double t_chain3(void) { return gd * gd2 * gd3; }
double t_chain4(void) { return gd * gd2 * gd3 * gd4; }
double t_neg(void) { return -(gd * gd2); }
double t_negl(void) { return -gd * gd2; }
double t_mla_p(double a, double b, double c) { return a * b + c; }
double t_mm_p(double a, double b) { return (a + b) * (a - b); }
double t_mm_p2(double a, double b, double c, double d) { return a * b + c * d; }
double t_ci(int i) { return gd * i; }
double t_ic(int i) { return i * gd; }
double t_ci2(int i) { return gd * i + gd2; }
double t_call_a(double a) { return fd(a) + gd; }
double t_a_call(double a) { return gd + fd(a); }
double t_call_only(double a) { return fd(a); }
double t_g0_mla(void) { g0(); return gd * gd2 + gd3; }
double t_mla_g0(void) { double t = gd * gd2 + gd3; g0(); return t; }
void t_st_mla(void) { gd = gd2 * gd3 + gd4; }
void t_st_mm(void) { gd = gd2 * gd3 + gd4 * gd2; }
void t_st_am(void) { gd = (gd2 + gd3) * gd4; }
double t_loc_mla(void) { double t = gd * gd2 + gd3; return t; }
double t_loc_mla2(void) { double t = gd * gd2 + gd3; return t * t; }
double t_two_loc(void) { double t = gd * gd2; double u = t + gd3; return u * gd4; }
double t_cond(double a, double b) { return a > b ? a : b; }
double t_cond_e(double a, double b) { return a > b ? a * b : a + b; }
int t_cmp_mla(void) { return gd * gd2 + gd3 < gd4; }
int t_cmp_e(void) { if (gd * gd2 < gd3) return 1; return 2; }
long t_to_l(void) { return (long)(gd * gd2); }
int t_to_i_e(void) { return (int)(gd * gd2 + gd3); }
double t_i_e(void) { return (double)(gi * 2) + gd; }
