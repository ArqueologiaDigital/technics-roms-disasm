/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18b.c (2026-11-17-7-sub-r18)
   sha256 e23f8bbda13185568e9ea1e50b00b3980e963e23e491a0d490f247ed0b2500bf (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, r;
    h = (unsigned int)p[12];
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) r = -512;
        else r = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) r = -512;
        else r = (h - (int)q[36]) * -64 / (q[37] - (int)q[36]);
    } else r = 0;
    return r;
}
