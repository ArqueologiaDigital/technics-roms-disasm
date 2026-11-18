/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ad_20b.c (2026-11-18-8-sub-r20b-staged)
   sha256 3fe4f4b7026dc75077407b9814f33d40b5155c96c06030603cb483c96a800a03 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
int Voice_InterpolateNoteCurve(unsigned char *p, unsigned char *q)
{
    int h, r;
    h = (unsigned char)p[12];
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
