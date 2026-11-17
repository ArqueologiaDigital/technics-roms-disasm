/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2] & 0x7f;
    ((struct l7 *)(d + 10))->v = t;
    t = s[3] & 0x7f;
    ((struct l7 *)(d + 11))->v = t;
    t = s[4] & 0x7f;
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = s[6] & 0x7f;
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}
