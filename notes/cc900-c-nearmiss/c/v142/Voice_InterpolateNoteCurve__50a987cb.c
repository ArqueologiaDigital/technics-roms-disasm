/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char n;
    int h, s, d, r;
    n = p[12];
    h = n;
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) r = -512;
        else {
            s = q[35];
            d = q[34] - s;
            r = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) r = -512;
        else {
            s = q[36];
            d = q[37] - s;
            r = (h - (int)q[36]) * -64 / d;
        }
    } else r = 0;
    return r;
}
