/* lane_sub round 19, floating-point library probe (KN5000 sub-CPU payload), second try.  Round 18's sub_fp_18a.c
   was refused whole: V4.23 at -Xr gives THC1-Error-373 "Illegal function return type" for every declaration of a
   function returning float or double, the prototypes of pow / sin / cos / tan / fabs included.  This file has the
   operators and conversions only: no function, declared or defined, returns float or double.  Only the callee
   names in the listing matter. */

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
void fp_mixed(void) { fp_gf = fp_gf * 1.5 + fp_gi; }
