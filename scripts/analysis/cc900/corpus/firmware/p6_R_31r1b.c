/* Probe round 31r1, helper R, form b (d+9 as a conditional expression, d[10] bit first): midi/midi_dispatch_handlers.s, twin of the built
   VoiceParam_CopyBitfields_TypeC (cc900/midi_dispatch_handlers.c) and of helper C's TypeA attempt (+106). */

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
