/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
void VoiceParam_CopyFields_TypeD(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2];
    ((struct l2 *)(d + 2))->v = t;
    t = s[3];
    d[4] = t;
    t = s[5];
    ((struct l4 *)(d + 6))->v = t;
    ((struct l7 *)(d + 3))->v = s[17] & 0x7f;
}
