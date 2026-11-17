/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129a.c (2026-11-16-100-p6-r19)
   sha256 701b50862cea8afdb7d4731ed7801af5090888e61b80a277453a14a39b81a886 (tar-sha256); compiled at -O3 -Xr */
struct sfrec { unsigned char old, f1, f2, merged, f4, f5, mask, shift, max; signed char min, step; };
extern unsigned char SeMenu_StepParamFieldUnsigned(struct sfrec *r);
extern unsigned char SeMenu_StepParamFieldSigned(struct sfrec *r);
unsigned char SeMenu_StepParamField(struct sfrec *r)
{
    unsigned char c;
    if (r->mask == 0 || r->shift > 7 || r->step == 0)
        return 0;
    if (r->min < 0)
        c = SeMenu_StepParamFieldSigned(r);
    else
        c = SeMenu_StepParamFieldUnsigned(r);
    return c;
}
