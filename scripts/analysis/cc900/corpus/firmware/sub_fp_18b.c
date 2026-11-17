/* lane_sub round 18: does V4.23 at -Xr refuse a function that RETURNS float or double, and with which message?
   (An earlier round lost a file to it; the exact message was not recorded.)  Each form is in a file of its own
   so that one refusal does not hide the other: this file returns float, with a prototype. */

float fp_ret_float(float a, float b);

float fp_ret_float(float a, float b)
{
    return a + b;
}
