/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4a.c (2026-11-16-39-p6-r7)
   sha256 3463f1aae6c33574e20f2ee81cb11a9209f625d63976be3d448a39b81d910ff2 (tar-sha256); compiled at -O3 -XS -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = ((struct l7 *)(s + 2))->v;
    ((struct l7 *)(d + 10))->v = t;
    t = ((struct l7 *)(s + 3))->v;
    ((struct l7 *)(d + 11))->v = t;
    t = ((struct l7 *)(s + 4))->v;
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = ((struct l7 *)(s + 6))->v;
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}
