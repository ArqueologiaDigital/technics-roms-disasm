/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3b.c (2026-11-19-10-sub-r23w-asm)
   sha256 d20e29023118a40f2a271ad82f83ef4675b92a35036e76a09e526311c9db51e7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, d;
    h = (int)p[12] & 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else {
            d = (int)q[34] - (int)q[35];
            h = ((int)q[34] - h) * -64 / d;
        }
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else {
            d = (int)q[37] - (int)q[36];
            h = (h - (int)q[36]) * -64 / d;
        }
    } else h = 0;
    return h;
}
