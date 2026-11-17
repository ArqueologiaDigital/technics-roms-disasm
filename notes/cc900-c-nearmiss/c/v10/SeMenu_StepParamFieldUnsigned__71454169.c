/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m129a.c (2026-11-16-123-p6-r25)
   sha256 714541692376cc0fb6e80b6afe9e1047f48a0f2cf505dcfb261b01797f701360 (tar-sha256); compiled at -O3 -Xr */
struct editrecu { unsigned char val, b1, b2, out, b4, b5, mask, shift, max, min; signed char step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);
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
        if ((unsigned char)(max - *v) > (unsigned char)step)
            *v += step;
        else
            *v = max;
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
