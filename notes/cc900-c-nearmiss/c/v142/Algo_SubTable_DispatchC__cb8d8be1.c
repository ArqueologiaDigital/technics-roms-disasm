/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr
   cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
struct algorec { unsigned char b[40]; };
struct b5 { unsigned char f0; unsigned char f1; unsigned char f2; unsigned char f3; unsigned char f4; };
extern char Algo_PanTrim_From_PartFlags(unsigned char, unsigned char);
unsigned char Algo_SubTable_DispatchC(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = ((struct b5 *)((unsigned long)&((struct algorec *)(DSP_AlgoDescriptor_Records + (int)(t) * 39))->b[(int)(k) * 5 + 0x13]))->f3;
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[98] - 100;
        r += Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 4: case 5:
        r = Algo_PanTrim_From_PartFlags(part, k);
        break;
    case 6: case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[97] - 100;
        break;
    }
    return r;
}
