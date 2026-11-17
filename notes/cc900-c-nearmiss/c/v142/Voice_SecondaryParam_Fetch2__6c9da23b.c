/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    switch (r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[r * 0x27];
        else
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[100];
        break;
    default:
        r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[100];
        break;
    }
    return r;
}
