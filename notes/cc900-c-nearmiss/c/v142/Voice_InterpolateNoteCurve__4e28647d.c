/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17b.c (2026-11-16-126-sub-r17)
   sha256 4e28647d6d2b9926d95f4c28b496455f9e4be5e2370c5e8065683c79b3734760 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char n;
    int h, t;
    n = p[12];
    h = (int)n & 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else h = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            t = h - (int)q[36];
            h = t * -64 / (q[37] - (int)q[36]);
        }
    } else h = 0;
    return h;
}
