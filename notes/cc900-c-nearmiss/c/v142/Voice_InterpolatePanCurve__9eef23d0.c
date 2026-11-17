/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18a.c (2026-11-17-7-sub-r18)
   sha256 9eef23d0a39d7cf39458941b073b5213578f8b8a83c8f8dff63b8de5e10de4e9 (name+funcs); compiled at -Xr */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else h = ((int)q[30] - h) * -64 / (q[30] - (int)q[31]);
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else h = (h - (int)q[32]) * -64 / (q[33] - (int)q[32]);
    } else h = 0;
    return h;
}
