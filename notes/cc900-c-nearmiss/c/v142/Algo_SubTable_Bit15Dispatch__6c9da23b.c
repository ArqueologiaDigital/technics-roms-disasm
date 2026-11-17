/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17a.c (2026-11-16-126-sub-r17)
   sha256 6c9da23be1740b125262337d35d6419d9e17f20c3d4204d47661ba77eaf9761b (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_ChanFreq_IndexMap[];
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
        r = ((struct b5 *)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13])->f4;
        switch (t) {
        case 0: case 1: case 2: case 3:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[97]];
            break;
        case 4: case 5:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[99]];
            break;
        case 8:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[(part) * 0x11f])[94]];
            break;
        }
    } else
        r = 0;
    return r;
}
