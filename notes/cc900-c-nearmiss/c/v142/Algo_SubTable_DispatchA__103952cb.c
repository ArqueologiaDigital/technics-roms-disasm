/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17b.c (2026-11-16-126-sub-r17)
   sha256 103952cb479afdc1c60db40fc3853c5ae181d89a51e462c0596d12a2a476ff39 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[][39];
struct algorec { unsigned char b[40]; };
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[93] & 0xf;
    r = (&((struct algorec *)DSP_AlgoDescriptor_Records[t])->b[(int)(k) * 5 + 0x13])[1];
    switch (t) {
    case 8:
        if (k == 1)
            r = (*(unsigned char **)&ram_4136e[(part) * 0x11f])[96];
        break;
    }
    return r;
}
