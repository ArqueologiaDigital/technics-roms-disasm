/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_W_18c.c (2026-11-17-7-sub-r18)
   sha256 11cd90f719c686bf95df843efa1165d230f4ca93f1f4a74de11f60b2fcf7bbb8 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
#define PATCH(p) (*(unsigned char **)&ram_4136e[(p) * 0x11f])
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    unsigned char t;

    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    t = PATCH(part)[93] & 0xf;
    r = t;
    switch (t) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[(unsigned int)r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[(unsigned int)r * 0x27];
        else
            r = PATCH(part)[100];
        break;
    default:
        r = PATCH(part)[100];
        break;
    }
    return r;
}
