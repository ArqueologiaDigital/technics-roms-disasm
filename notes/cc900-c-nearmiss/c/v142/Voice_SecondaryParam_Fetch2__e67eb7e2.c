/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_9c.c (2026-11-16-86-sub-r9)
   sha256 e67eb7e2c0c66eb6b52a53b2f206995f13036598ffdb92b26d1921ab65cda84b (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_FlagsAB[];
extern unsigned char DSP_AlgoDescriptor_ValueAB[];
unsigned char Voice_SecondaryParam_Fetch2(unsigned char part)
{
    unsigned char r;

    r = 0;
    if (!(*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000))
        return r;
    r = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (r) {
    case 0x0a: case 0x0b:
        if (DSP_AlgoDescriptor_FlagsAB[r * 0x27] & 0x80)
            r = DSP_AlgoDescriptor_ValueAB[r * 0x27];
        else
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[100];
        break;
    default:
        r = (*(unsigned char **)&ram_4136e[part * 0x11f])[100];
        break;
    }
    return r;
}
