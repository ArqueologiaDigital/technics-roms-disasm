/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_4b.c (2026-11-16-62-sub-r4)
   sha256 f89fddaf3be0b8e16077861bf8cd0ad246fe92612aa0c7bcc7e50604383f7dad (name+funcs); compiled at -Xr */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else {
            d = (int)q[30] - (int)q[31];
            h = ((int)q[30] - h) * -64 / d;
        }
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else {
            d = (int)q[33] - (int)q[32];
            h = (h - (int)q[32]) * -64 / d;
        }
    } else h = 0;
    return h;
}
