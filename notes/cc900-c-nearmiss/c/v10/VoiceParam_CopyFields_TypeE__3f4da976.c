/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2];
    ((struct l7 *)(d + 10))->v = t;
    t = s[3];
    ((struct l7 *)(d + 11))->v = t;
    t = s[4];
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = s[6];
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}
