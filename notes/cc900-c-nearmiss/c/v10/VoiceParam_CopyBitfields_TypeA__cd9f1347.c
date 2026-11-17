/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4b.c (2026-11-16-39-p6-r7)
   sha256 cd9f134746513c7c9c77d7c0d599b0c4008c48aed497a7f2cb2fa6c3e2f78376 (tar-sha256); compiled at -O3 -XS -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct a4 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char lo : 3; };
struct a6 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1; unsigned char lo : 4; };
void VoiceParam_CopyBitfields_TypeA(unsigned char *s, unsigned char *d)
{
    d[2] = s[2];
    ((struct l7 *)(d + 3))->v = ((struct a6 *)(s + 6))->lo;
    ((struct l7 *)(d + 5))->v = ((struct l7 *)(s + 3))->v;
    ((struct a4 *)(d + 6))->b7 = ((struct a4 *)(s + 4))->b7;
    ((struct a4 *)(d + 6))->b6 = ((struct a4 *)(s + 4))->b6;
    ((struct a4 *)(d + 6))->b3 = ((struct a4 *)(s + 4))->b3;
    ((struct a4 *)(d + 6))->lo = ((struct a4 *)(s + 4))->lo;
    if (((struct a4 *)(s + 4))->b5) ((struct l7 *)(d + 7))->v = 0x50;
    else ((struct l7 *)(d + 7))->v = 0;
    if (((struct l7 *)(s + 5))->h) ((struct l7 *)(d + 9))->v = 0x5a;
    else ((struct l7 *)(d + 9))->v = 0;
    ((struct a6 *)(d + 14))->b5 = ((struct a6 *)(s + 9))->b5;
    ((struct l7 *)(d + 16))->v = ((struct l7 *)(s + 8))->v;
    ((struct l7 *)(d + 16))->h = ((struct l7 *)(s + 8))->h;
    d[17] = s[11];
    ((struct a6 *)(d + 15))->b6 = ((struct a6 *)(s + 6))->b6;
    ((struct a6 *)(d + 15))->b5 = ((struct a6 *)(s + 6))->b5;
}
