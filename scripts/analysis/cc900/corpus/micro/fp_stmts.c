/* FP temporaries over several statements */
extern double gd, gd2, gd3, gd4; extern double fd(double); extern int gi; extern long gl;
void s_two(void) { gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; }
void s_two_b(void) { gd = gd2 * gd3 + gd4; gd2 = (gd3 + gd4) * (gd + gd2); }
void s_three(void) { gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; gd3 = gd * gd2 + gd4; }
void s_conv2(void) { gd = gd2 * gi; gd2 = gd3 * gi + gd; }
void s_conv_first(void) { gd = gi * gd2 + gd3; gd2 = gd3 * gd4 + gd; }
void s_call2(void) { gd = fd(gd2) + gd3; gd2 = fd(gd3 * gd4) + gd; }
double s_loc(double a) { double t; t = a * a + gd; t = t * a + gd2; return t; }
double s_loc2(double a) { double t, u; t = a * a + gd; u = t * a + gd2; return t + u; }
void s_if(int c) { if (c) gd = gd2 * gd3 + gd4; else gd = gd3 * gd4 + gd2; }
void s_if2(int c) { if (c) gd = gd2 * gd3 + gd4; gd2 = gd3 * gd4 + gd; }
void s_loop(int n) { int i; for (i = 0; i < n; i++) gd = gd * gd2 + gd3; }
void s_loop2(int n) { int i; gd4 = gd * gd2 + gd3; for (i = 0; i < n; i++) gd = gd * gd2 + i; }
void s_loop3(int n) { int i; for (i = 0; i < n; i++) { gd = gd * gd2 + gd3; gd2 = gd2 * gd3 + i; } }
double s_ret2(double a) { gd = a * a + gd2; return a * gd + gd3; }
long s_mix(double a) { gd = a * a + gd2; return (long)(a * gd); }
void s_conv_l(void) { gd = gd2 * gl; gl = gd * gd3; }
