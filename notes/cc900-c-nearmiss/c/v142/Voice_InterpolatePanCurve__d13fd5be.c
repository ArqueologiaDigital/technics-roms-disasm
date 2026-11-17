/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18c.c (2026-11-17-7-sub-r18)
   sha256 d13fd5bee4c588924605a2019e3ca34a97ebaef977587618bf65aafcfba32384 (name+funcs); compiled at -Xr */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else {
            d = q[30] - (int)q[31];
            h = ((int)q[30] - h) * -64 / d;
        }
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else {
            d = q[33] - (int)q[32];
            h = (h - (int)q[32]) * -64 / d;
        }
    } else h = 0;
    return h;
}
