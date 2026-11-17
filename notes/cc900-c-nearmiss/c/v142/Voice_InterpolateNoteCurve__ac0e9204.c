/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char n;
    int h, s, d, t;
    n = p[12];
    h = n;
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else {
            s = q[35];
            d = q[34];
            d -= s;
            h = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            s = q[36];
            d = q[37];
            d -= s;
            t = h - (int)q[36];
            h = t * -64 / d;
        }
    } else h = 0;
    return h;
}
