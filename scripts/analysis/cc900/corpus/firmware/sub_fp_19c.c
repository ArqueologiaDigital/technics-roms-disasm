/* lane_sub round 19: a DEFINED function that returns double / float with __cdecl at -Xr: accepted or refused?
   (Without __cdecl: THC1-Error-373 "Illegal function return type", round 18's sub_fp_18b.c / sub_fp_18c.c.) */

double __cdecl fp_ret_double(double a, double b);
float __cdecl fp_ret_float(float a, float b);
double fp_use_gd;

double __cdecl fp_ret_double(double a, double b)
{
    return a * b;
}

float __cdecl fp_ret_float(float a, float b)
{
    return a + b;
}

void fp_use_ret(void)
{
    fp_use_gd = fp_ret_double(fp_use_gd, 2.0);
}
