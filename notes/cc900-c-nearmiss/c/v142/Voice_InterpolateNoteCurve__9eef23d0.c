/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18a.c (2026-11-17-7-sub-r18)
   sha256 9eef23d0a39d7cf39458941b073b5213578f8b8a83c8f8dff63b8de5e10de4e9 (name+funcs); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h;
    h = p[12];
    h &= 0x7f;
    if (h < q[34]) {
        if (h < q[35]) h = -512;
        else h = ((int)q[34] - h) * -64 / (q[34] - (int)q[35]);
    } else if (h > q[36]) {
        if (h > q[37]) h = -512;
        else h = (h - (int)q[36]) * -64 / (q[37] - (int)q[36]);
    } else h = 0;
    return h;
}
