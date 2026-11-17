/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-17-1-p6-r28-staged)
   sha256 460a23c5371a011ebee93dcc5c797fab9a58c5d0c9b3fb421353093190faf023 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);
struct editrecu { unsigned char val, b1, b2, out, b4, b5, mask, shift, max, min; signed char step; };
int SeMenu_StepParamFieldUnsigned(struct editrecu *r)
{
    unsigned char orig;
    unsigned char *dst;
    unsigned char mask;
    unsigned char shift;
    unsigned char max;
    unsigned char min;
    signed char step;
    unsigned char *v;
    v = &r->val;
    dst = &r->out;
    mask = r->mask;
    shift = r->shift;
    max = r->max;
    min = r->min;
    step = r->step;
    orig = *v;
    orig &= ~SeMenu_BitShiftMask(mask, shift);
    *v = SeMenu_BitShiftMask_End(*v, shift);
    *v &= mask;
    if (step > 0) {
        if (*v == max)
            return 0;
        if ((unsigned char)(max - *v) <= (unsigned char)step)
            *v = max;
        else
            *v += step;
    } else {
        if (*v == min)
            return 0;
        if ((unsigned char)(min - step) >= *v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}
