/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
struct panp { char pad[8]; int w; };
struct curvp { char pad[30]; unsigned char lo1; unsigned char lo0; unsigned char hi0; unsigned char hi1; };
int Voice_InterpolatePanCurve(struct panp *p, struct curvp *q)
{
    int h;
    h = (p->w & 0x7f00) >> 8;
    if (h < q->lo1) {
        if (h < q->lo0) h = -512;
        else h = (q->lo1 - h) * -64 / (q->lo1 - q->lo0);
    } else if (h > q->hi0) {
        if (h > q->hi1) h = -512;
        else h = (h - q->hi0) * -64 / (q->hi1 - q->hi0);
    } else h = 0;
    return h;
}
