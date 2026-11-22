/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1b.c (2026-11-22-15-p6-r82)
   sha256 e7abcd49f012f10209bf1b7dbf9e8a67fab856ac65670d712e6e211b564fbddd (tar-sha256); compiled at -O3 -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct r8 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char b2 : 1; unsigned char b1 : 1; unsigned char b0 : 1; };
struct eq2 { unsigned char h : 2; unsigned char f54 : 2; unsigned char b3 : 1; unsigned char b2 : 1; unsigned char l : 2; };
struct a4 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char lo : 3; };
struct a6 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1; unsigned char lo : 4; };
void VoiceParam_CopyBitfields_TypeB(unsigned char *s, unsigned char *d)
{
    d[2] = s[2];
    ((struct l7 *)(d + 3))->v = ((struct a6 *)(s + 12))->lo;
    ((struct a4 *)(d + 5))->lo = ((struct l2 *)(s + 4))->v;
    ((struct a4 *)(d + 5))->b3 = ((struct r8 *)(s + 4))->b2;
    ((struct a4 *)(d + 6))->lo = ((struct l2 *)(s + 6))->v;
    ((struct a4 *)(d + 6))->b6 = ((struct a4 *)(s + 6))->b6;
    ((struct r8 *)(d + 7))->b0 = ((struct r8 *)(s + 7))->b0;
    ((struct r8 *)(d + 7))->b1 = ((struct r8 *)(s + 7))->b1;
    ((struct r8 *)(d + 7))->b2 = ((struct r8 *)(s + 7))->b2;
    ((struct r8 *)(d + 7))->b3 = ((struct r8 *)(s + 7))->b3;
    ((struct r8 *)(d + 7))->b4 = ((struct r8 *)(s + 7))->b4;
    ((struct r8 *)(d + 7))->b5 = ((struct r8 *)(s + 7))->b5;
    ((struct r8 *)(d + 7))->b6 = ((struct r8 *)(s + 7))->b6;
    ((struct r8 *)(d + 7))->h = ((struct r8 *)(s + 7))->h;
    ((struct eq2 *)(d + 9))->f54 = ((struct a6 *)(s + 12))->b4 ? 2 : 0;
    d[10] = ((struct r8 *)(s + 15))->b0 + (s[14] << 1);
    ((struct r8 *)(d + 11))->b0 = (s[14] >> 7) & 1;
}
