/* lane_sub round 18: as sub_fp_18b.c, a function that returns double, with a prototype and a caller that uses
   the result. */

double fp_ret_double(double a, double b);
double fp_use_gd;

double fp_ret_double(double a, double b)
{
    return a * b;
}

void fp_use_ret(void)
{
    fp_use_gd = fp_ret_double(fp_use_gd, 2.0);
}
