/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AD_20a.c (2026-11-18-6-sub-r20a)
   sha256 8d205696704d19cde930fd2f245296e8098d145f2b7f30d3059fc4b55cb75ba3 (tar-sha256); compiled at -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    unsigned char c;
    int h, r;
    c = p[12];
    h = c;
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
