/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m129c.c (2026-11-16-123-p6-r25)
   sha256 9d395ce3453ee0111fbd9d95b58cec7128ae8285eddbff31d2f97f2cfac7e3ec (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);
int SeMenu_StepParamFieldSigned(signed char *r)
{
    signed char orig;
    signed char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
    signed char step;
    signed char *v;
    v = &r[0];
    dst = &r[3];
    mask = r[6];
    shift = r[7];
    max = r[8];
    min = r[9];
    step = r[10];
    orig = *v;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    *v = SeMenu_BitShiftMask_End(*v, shift);
    *v &= mask;
    if (step > 0) {
        if (*v == max)
            return 0;
        if ((unsigned char)(max - *v) > (unsigned char)step)
            *v += step;
        else
            *v = max;
    } else {
        if (*v == min)
            return 0;
        if ((signed char)(min - step) >= *v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}
