/* lane_ws probe round 1: small leaf functions of the SX-WSA1R prom_b (CPU 1, wsa1/prom_b).  Names are the tree's
   labels.  The ROM reads every argument from the stack, so the functions are plain (cdecl). */

struct range { signed char lo; char pad; signed char hi; char rest[3]; };
extern const unsigned char BitMask_F4C3E9[];
extern const struct range EffectValueRanges[];

unsigned char CreatorSelect_ButtonCodeToBit(unsigned char c)
{
    if (c > 8) c = 0;
    return BitMask_F4C3E9[c];
}

unsigned long Pack3x7BitFields_Bytes6To8(unsigned char *p)
{
    unsigned long a = (unsigned long)(p[6] & 0x7f) << 14;
    unsigned long b = (unsigned long)(p[7] & 0x7f) << 7;
    unsigned long c = p[8] & 0x7f;
    return b | a | c;
}

unsigned long Pack3x7BitFields_Bytes9To11(unsigned char *p)
{
    unsigned long a = (unsigned long)(p[9] & 0x7f) << 14;
    unsigned long b = (unsigned long)(p[10] & 0x7f) << 7;
    unsigned long c = p[11] & 0x7f;
    return b | a | c;
}

void Queue2C00_Append4(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    unsigned int *n = (unsigned int *)0x60f000;
    unsigned char *q;
    if (*n < 508) {
        q = (unsigned char *)(unsigned int)(0x2c00 + *n);
        q[0] = a;
        q[1] = b;
        q[2] = c;
        q[3] = d;
        q[4] = 255;
        *n += 4;
    }
}

void DspEffect_RepairS8(unsigned int idx, unsigned int off, signed char *rec, signed char *def)
{
    signed char hi = EffectValueRanges[idx].hi;
    signed char lo = EffectValueRanges[idx].lo;
    signed char v = rec[off];
    if (v > hi || v < lo)
        rec[off] = def[off];
}

void DspEffect_RepairU8(unsigned int idx, unsigned int off, unsigned char *rec, unsigned char *def)
{
    unsigned char hi = (unsigned char)EffectValueRanges[idx].hi;
    unsigned char lo = (unsigned char)EffectValueRanges[idx].lo;
    unsigned char v = rec[off];
    if (v > hi || v < lo)
        rec[off] = def[off];
}
