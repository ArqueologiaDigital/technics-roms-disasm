/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;
    unsigned char t;
    r = 0;
    if (!((unsigned long)*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = t;
    switch (t) {
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
