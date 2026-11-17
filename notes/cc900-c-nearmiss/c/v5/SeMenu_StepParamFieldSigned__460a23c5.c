/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/semenu_routines_m129.c (2026-11-17-1-p6-r28-staged)
   sha256 460a23c5371a011ebee93dcc5c797fab9a58c5d0c9b3fb421353093190faf023 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
