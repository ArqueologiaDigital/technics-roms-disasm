/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_12a.c (2026-11-16-97-sub-r12)
   sha256 a26ad5b47b56cde0f4da35a3785755237745283648c4046b289962d353272a79 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)k * 5 + 0x13] + 2);
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96] * 2;
        break;
    case 4: case 5:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[98] * 2;
        break;
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[95] * 2;
        break;
    }
    return r;
}
