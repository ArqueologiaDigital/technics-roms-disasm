/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3a.c (2026-11-16-58-sub-r3)
   sha256 99e952f60a590931da21e8c6184efc818dce0d30099b96db61b5a5c174d03956 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (int)p[12] & 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else {
            d = (int)q[34] - (int)q[35];
            h = ((int)q[34] - h) * -64;
            h /= d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            d = (int)q[37] - (int)q[36];
            h = (h - (int)q[36]) * -64;
            h /= d;
        }
    } else h = 0;
    return h;
}
