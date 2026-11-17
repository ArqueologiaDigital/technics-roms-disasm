/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, s, d, r;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) r = -512;
        else {
            s = q[31];
            d = q[30] - s;
            r = ((int)q[30] - h) * -64 / d;
        }
    } else if (h > q[32]) {
        if (h > q[33]) r = -512;
        else {
            s = q[32];
            d = q[33] - s;
            r = (h - (int)q[32]) * -64 / d;
        }
    } else r = 0;
    return r;
}
