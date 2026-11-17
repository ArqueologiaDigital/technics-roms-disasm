/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m129b.c (2026-11-16-128-p6-r27)
   sha256 640bffc912434aa0493d91924e34e7da69e6cc00cf3ef9d036d4781ef5918240 (tar-sha256); compiled at -O3 -Xr */
struct editrecs { signed char val, b1, b2, out, b4, b5; unsigned char mask, shift; signed char max, min, step; };
extern unsigned char SeMenu_BitShiftMask(unsigned char a, unsigned char n);
extern unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n);
int SeMenu_StepParamFieldSigned(struct editrecs *r)
{
    signed char orig;
    signed char *dst;
    unsigned char mask;
    unsigned char shift;
    signed char max;
    signed char min;
    signed char step;
    signed char *v;
    signed char t;
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
        t = *v;
        if ((unsigned char)(max - t) <= (unsigned char)step)
            *v = max;
        else
            *v += step;
    } else {
        if (*v == min)
            return 0;
        t = *v;
        if ((signed char)(min - step) >= t)
            *v = min;
        else
            *v += step;
    }
    *dst = SeMenu_BitShiftMask(*v & mask, shift);
    *dst |= orig;
    return 1;
}
