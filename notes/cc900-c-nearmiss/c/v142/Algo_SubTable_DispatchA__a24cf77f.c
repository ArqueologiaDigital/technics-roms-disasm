/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4a.c (2026-11-16-62-sub-r4)
   sha256 a24cf77f8f049afccae4323475659f7526d8e2c4b8ca651c8900655a87adb798 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[][0x27];
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    r = *(unsigned char *)((unsigned long)(DSP_AlgoDescriptor_Records[t] + ((int)slot * 5 + 0x13)) + 1);
    switch (t) {
    case 8:
        if (slot == 1) r = (*(unsigned char **)(ram_4136e + part * 0x11f))[96];
    }
    return r;
}
