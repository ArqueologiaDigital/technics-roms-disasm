/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18c.c (2026-11-17-7-sub-r18)
   sha256 d13fd5bee4c588924605a2019e3ca34a97ebaef977587618bf65aafcfba32384 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = p[12] & 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else {
            d = q[34] - (int)q[35];
            h = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            d = q[37] - (int)q[36];
            h = (h - (int)q[36]) * -64 / d;
        }
    } else h = 0;
    return h;
}
