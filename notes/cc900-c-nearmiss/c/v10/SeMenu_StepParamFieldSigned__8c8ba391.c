/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m129a.c (2026-11-16-128-p6-r27)
   sha256 8c8ba391c64a17365075a0923e7a410784c02f6a4fc163182071aed13bfe385f (tar-sha256); compiled at -Xr */
struct editrecx { unsigned char val, b1, b2, out, b4, b5, mask, shift; signed char max, min, step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);
int SeMenu_StepParamFieldSigned(struct editrecx *r)
{
    unsigned char orig;
    unsigned char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
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
        if ((signed char)*v == max)
            return 0;
        if ((unsigned char)(max - (signed char)*v) <= (unsigned char)step)
            *v = max;
        else
            *v += step;
    } else {
        if ((signed char)*v == min)
            return 0;
        if ((signed char)(min - step) >= (signed char)*v)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}
