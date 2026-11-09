/* Floating point: helpers, temporaries, conversions */
extern double gd, gd2, gd3; extern float gf, gf2; extern int gi; extern long gl; extern unsigned int gu;
extern unsigned long gul; extern char gc; extern unsigned char guc; extern double gda[4];
struct sd { int k; double v; }; extern struct sd gs; extern double fd(double); extern double fd2(double, double);
extern void vd(double); extern int fi(void); extern double *gpd;
double d_add_gg(void) { return gd + gd2; }
double d_add_pp(double a, double b) { return a + b; }
double d_add_pk(double a) { return a + 2.5; }
void d_add_st(void) { gd = gd2 + gd3; }
float f_add_gg(void) { return gf + gf2; }
void d_add_asg(void) { gd += gd2; }
double d_sub_gg(void) { return gd - gd2; }
double d_sub_pp(double a, double b) { return a - b; }
double d_sub_pk(double a) { return a - 2.5; }
void d_sub_st(void) { gd = gd2 - gd3; }
float f_sub_gg(void) { return gf - gf2; }
void d_sub_asg(void) { gd -= gd2; }
double d_mul_gg(void) { return gd * gd2; }
double d_mul_pp(double a, double b) { return a * b; }
double d_mul_pk(double a) { return a * 2.5; }
void d_mul_st(void) { gd = gd2 * gd3; }
float f_mul_gg(void) { return gf * gf2; }
void d_mul_asg(void) { gd *= gd2; }
double d_div_gg(void) { return gd / gd2; }
double d_div_pp(double a, double b) { return a / b; }
double d_div_pk(double a) { return a / 2.5; }
void d_div_st(void) { gd = gd2 / gd3; }
float f_div_gg(void) { return gf / gf2; }
void d_div_asg(void) { gd /= gd2; }
double d_three(void) { return gd * gd2 + gd3; }
double d_three2(void) { return gd + gd2 * gd3; }
double d_four(double a, double b) { return (a + b) * (a - b); }
double d_neg(double a) { return -a; }
double d_ret_p(double a) { return a; }
double d_ret_g(void) { return gd; }
double d_ret_k(void) { return 1.0; }
double d_ret_0(void) { return 0.0; }
void d_st_k(void) { gd = 3.0; }
void d_st_0(void) { gd = 0; }
void d_copy(void) { gd = gd2; }
double d_loc(double a) { double t = a * a; return t + t; }
double d_loc2(double a, double b) { double t = a * b; double u = a + b; return t / u; }
int d_ceq_gg(void) { return gd == gd2; }
int d_ceq_z(double a) { return a == 0.0; }
int d_beq_gg(void) { if (gd == gd2) return 1; return 2; }
int d_beq_z(double a) { if (a == 0.0) return 1; return 2; }
int d_cne_gg(void) { return gd != gd2; }
int d_cne_z(double a) { return a != 0.0; }
int d_bne_gg(void) { if (gd != gd2) return 1; return 2; }
int d_bne_z(double a) { if (a != 0.0) return 1; return 2; }
int d_clt_gg(void) { return gd < gd2; }
int d_clt_z(double a) { return a < 0.0; }
int d_blt_gg(void) { if (gd < gd2) return 1; return 2; }
int d_blt_z(double a) { if (a < 0.0) return 1; return 2; }
int d_cle_gg(void) { return gd <= gd2; }
int d_cle_z(double a) { return a <= 0.0; }
int d_ble_gg(void) { if (gd <= gd2) return 1; return 2; }
int d_ble_z(double a) { if (a <= 0.0) return 1; return 2; }
int d_cgt_gg(void) { return gd > gd2; }
int d_cgt_z(double a) { return a > 0.0; }
int d_bgt_gg(void) { if (gd > gd2) return 1; return 2; }
int d_bgt_z(double a) { if (a > 0.0) return 1; return 2; }
int d_cge_gg(void) { return gd >= gd2; }
int d_cge_z(double a) { return a >= 0.0; }
int d_bge_gg(void) { if (gd >= gd2) return 1; return 2; }
int d_bge_z(double a) { if (a >= 0.0) return 1; return 2; }
int d_bk(double a) { if (a < 1.5) return 1; return 2; }
int d_not(double a) { return !a; }
int d_if(double a) { if (a) return 1; return 2; }
int f_clt(void) { return gf < gf2; }
double d_from_i(void) { return gi; }
int d_to_i(void) { return gd; }
void d_st_i(void) { gd = gi; }
void d_to_i_st(void) { gi = gd; }
double d_from_l(void) { return gl; }
long d_to_l(void) { return gd; }
void d_st_l(void) { gd = gl; }
void d_to_l_st(void) { gl = gd; }
double d_from_u(void) { return gu; }
unsigned int d_to_u(void) { return gd; }
void d_st_u(void) { gd = gu; }
void d_to_u_st(void) { gu = gd; }
double d_from_ul(void) { return gul; }
unsigned long d_to_ul(void) { return gd; }
void d_st_ul(void) { gd = gul; }
void d_to_ul_st(void) { gul = gd; }
double d_from_c(void) { return gc; }
char d_to_c(void) { return gd; }
void d_st_c(void) { gd = gc; }
void d_to_c_st(void) { gc = gd; }
double d_from_uc(void) { return guc; }
unsigned char d_to_uc(void) { return gd; }
void d_st_uc(void) { gd = guc; }
void d_to_uc_st(void) { guc = gd; }
double d_from_f(void) { return gf; }
float f_from_d(void) { return gd; }
double d_from_ip(int i) { return i; }
int d_to_ip(double a) { return a; }
double d_mix(int i) { return gd * i; }
double d_call1(double a) { return fd(a); }
double d_call2(void) { return fd2(gd, gd2); }
double d_call_e(double a) { return fd(a * 2.0) + a; }
void d_call_v(void) { vd(gd + gd2); }
double d_call_i(void) { return fi() * gd; }
double d_arr(int i) { return gda[i]; }
void d_arr_st(int i, double v) { gda[i] = v; }
double d_mem(void) { return gs.v; }
double d_ptr(double *p) { return *p; }
void d_ptr_st(double *p, double v) { *p = v; }
double d_gptr(void) { return *gpd * 2.0; }
double d_cond(double a, double b) { return a > b ? a : b; }
double d_loop(int n) { double s = 0.0; int i; for (i = 0; i < n; i++) s += gda[i]; return s; }
double d_inc(double a) { a += 1.0; return a; }
