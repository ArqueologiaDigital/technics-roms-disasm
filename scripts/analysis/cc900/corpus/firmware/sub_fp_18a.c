/* lane_sub round 18, floating-point library probe (KN5000 sub-CPU payload): which library routine does V4.23 call
   for each float / double operation at -Xr?  The functions are not the ROM's; only the callee names in the listing
   matter.  Results go into scripts/build/cc900_runtime_names.tsv, each paired with the tree label at the address
   the ROM calls for the same operation.  No function here returns float or double (see sub_fp_18b.c). */

extern double pow(double, double);
extern double sin(double);
extern double cos(double);
extern double tan(double);
extern double fabs(double);

float fp_gf;
float fp_gg;
double fp_gd;
double fp_ge;
int fp_gi;
long fp_gl;
unsigned int fp_gu;
unsigned long fp_gul;

void fp_fadd(void) { fp_gf = fp_gf + fp_gg; }
void fp_fsub(void) { fp_gf = fp_gf - fp_gg; }
void fp_fmul(void) { fp_gf = fp_gf * fp_gg; }
void fp_fdiv(void) { fp_gf = fp_gf / fp_gg; }
void fp_fneg(void) { fp_gf = -fp_gg; }
int fp_fcmp_lt(void) { return fp_gf < fp_gg; }
int fp_fcmp_eq(void) { return fp_gf == fp_gg; }
int fp_fcmp_zero(void) { return fp_gf == 0; }

void fp_dadd(void) { fp_gd = fp_gd + fp_ge; }
void fp_dsub(void) { fp_gd = fp_gd - fp_ge; }
void fp_dmul(void) { fp_gd = fp_gd * fp_ge; }
void fp_ddiv(void) { fp_gd = fp_gd / fp_ge; }
void fp_dneg(void) { fp_gd = -fp_ge; }
int fp_dcmp_lt(void) { return fp_gd < fp_ge; }
int fp_dcmp_eq(void) { return fp_gd == fp_ge; }

void fp_ftod(void) { fp_gd = fp_gf; }
void fp_dtof(void) { fp_gf = fp_gd; }
void fp_ftoi(void) { fp_gi = fp_gf; }
void fp_ftol(void) { fp_gl = fp_gf; }
void fp_ftou(void) { fp_gu = fp_gf; }
void fp_ftoul(void) { fp_gul = fp_gf; }
void fp_dtoi(void) { fp_gi = fp_gd; }
void fp_dtol(void) { fp_gl = fp_gd; }
void fp_itof(void) { fp_gf = fp_gi; }
void fp_ltof(void) { fp_gf = fp_gl; }
void fp_utof(void) { fp_gf = fp_gu; }
void fp_ultof(void) { fp_gf = fp_gul; }
void fp_itod(void) { fp_gd = fp_gi; }
void fp_ltod(void) { fp_gd = fp_gl; }
void fp_ultod(void) { fp_gd = fp_gul; }

void fp_pow(void) { fp_gd = pow(fp_gd, fp_ge); }
void fp_sin(void) { fp_gd = sin(fp_gd); }
void fp_cos(void) { fp_gd = cos(fp_gd); }
void fp_tan(void) { fp_gd = tan(fp_gd); }
void fp_fabs(void) { fp_gd = fabs(fp_gd); }
void fp_powf(void) { fp_gf = pow(fp_gf, 2.0); }
void fp_mixed(void) { fp_gf = fp_gf * 1.5 + fp_gi; }
