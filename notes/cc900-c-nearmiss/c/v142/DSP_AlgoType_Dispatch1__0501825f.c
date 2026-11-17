/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_13b.c (2026-11-16-99-sub-r13-idioms)
   sha256 0501825fad663d83e955d81b7d85b3bb7a70d125b2c417ebb8e80ecbb1b7e3de (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41368[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_Dispatch1_Curves[];
extern int EGEnv_ModeBits_Table[];
unsigned int DSP_AlgoType_Dispatch1(unsigned char part, unsigned char ch)
{
    unsigned char t;
    unsigned int r;
    unsigned char s;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
        break;
    case 4: case 5: case 7:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        if (ch == 0)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
        else if (ch == 1)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[96]];
        break;
    case 10: case 11:
        s = (DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2];
        if (s != 0xff)
            r = ((int *)(DSP_ChanFreq_Dispatch1_Curves + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[96]];
        r |= EGEnv_ModeBits_Table[(*(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)ch * 3] + 2) & 0xc0) >> 6];
        break;
    }
    *(unsigned int *)&(ram_41368 + (long)((int)part * 0x11f))[((int)ch * 4) + 0x57] = r;
    return r;
}
