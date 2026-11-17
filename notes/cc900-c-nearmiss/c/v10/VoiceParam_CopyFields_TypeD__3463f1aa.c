/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4a.c (2026-11-16-39-p6-r7)
   sha256 3463f1aae6c33574e20f2ee81cb11a9209f625d63976be3d448a39b81d910ff2 (tar-sha256); compiled at -O3 -XS -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
void VoiceParam_CopyFields_TypeD(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = ((struct l2 *)(s + 2))->v;
    ((struct l2 *)(d + 2))->v = t;
    t = s[3];
    d[4] = t;
    t = ((struct l4 *)(s + 5))->v;
    ((struct l4 *)(d + 6))->v = t;
    ((struct l7 *)(d + 3))->v = s[17];
}
