/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_4b.c (2026-11-16-62-sub-r4)
   sha256 b0df8e0b49e3477310bfbc8eb1db4d0a27fc8cbcb08ab817f13c8569d38158d2 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[][0x27];
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char slot)
{
    unsigned char t;
    unsigned char r;
    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    r = ((unsigned char *)((unsigned long)DSP_AlgoDescriptor_Records[t] + ((int)slot * 5 + 0x13)))[1];
    switch (t) {
    case 8:
        if (slot == 1) r = (*(unsigned char **)(ram_4136e + part * 0x11f))[96];
    }
    return r;
}
