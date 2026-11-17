/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17b.c (2026-11-16-126-sub-r17)
   sha256 4e28647d6d2b9926d95f4c28b496455f9e4be5e2370c5e8065683c79b3734760 (name+funcs); compiled at -Xr */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, t;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) h = -512;
        else h = ((int)q[30] - h) * -64 / (q[30] - (int)q[31]);
    } else if (h > q[32]) {
        if (h > q[33]) h = -512;
        else {
            t = h - (int)q[32];
            h = t * -64 / (q[33] - (int)q[32]);
        }
    } else h = 0;
    return h;
}
