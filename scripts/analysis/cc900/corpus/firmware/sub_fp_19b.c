/* lane_sub round 19: the math library through __cdecl prototypes.  At -Xr a function returning double is refused
   (THC1-Error-373) when it has the register convention; the library's pow / sin / cos / tan / fabs are stack
   (__cdecl) functions, so their prototypes say so here.  Does V4.23 accept that, and what does the call look like? */

extern double __cdecl pow(double, double);
extern double __cdecl sin(double);
extern double __cdecl cos(double);
extern double __cdecl tan(double);
extern double __cdecl fabs(double);

float fp_gf;
double fp_gd;
double fp_ge;

void fp_pow(void) { fp_gd = pow(fp_gd, fp_ge); }
void fp_sin(void) { fp_gd = sin(fp_gd); }
void fp_cos(void) { fp_gd = cos(fp_gd); }
void fp_tan(void) { fp_gd = tan(fp_gd); }
void fp_fabs(void) { fp_gd = fabs(fp_gd); }
void fp_powf(void) { fp_gf = pow(fp_gf, 2.0); }
