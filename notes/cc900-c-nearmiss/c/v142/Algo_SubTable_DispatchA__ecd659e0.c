/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_10c.c (2026-11-16-90-sub-r10)
   sha256 ecd659e02d856f795e8e5bc4d2071af22ef5d0dc0758d1b8896dd134179ad82d (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (int)t * 39)[(int)k * 5 + 0x13] + 1);
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
        break;
    }
    return r;
}
