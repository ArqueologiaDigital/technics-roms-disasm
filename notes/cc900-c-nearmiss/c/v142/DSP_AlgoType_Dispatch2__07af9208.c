/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_13a.c (2026-11-16-99-sub-r13-idioms)
   sha256 07af92085d60f74ae617b901622900e04ec8ef299af678c92733e4f109cccacf (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41368[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_AlgoChannel_SelectorRecords[];
extern unsigned char DSP_ChanFreq_CurvePool[];
unsigned int DSP_AlgoType_Dispatch2(unsigned char part, unsigned char ch)
{
    unsigned int r;
    unsigned char t;
    unsigned char s;

    r = 0;
    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    switch (t) {
    case 0: case 1: case 2: case 3:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        break;
    case 4: case 5: case 7:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        if (ch == 0)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[95]];
        else if (ch == 1)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[(*(unsigned char **)&ram_4136e[part * 0x11f])[97]];
        break;
    case 10: case 11:
        s = *(unsigned char *)((unsigned long)&(DSP_AlgoChannel_SelectorRecords + (long)((int)t * 6))[(int)ch * 2] + 1);
        if (s != 0xff)
            r = ((int *)(DSP_ChanFreq_CurvePool + (long)((int)s * 102)))[*(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)((int)t * 39))[(int)ch * 3] + 1)];
        break;
    }
    *(unsigned int *)((unsigned long)&(ram_41368 + (long)((int)part * 0x11f))[((int)ch * 4) + 0x57] + 2) = r;
    return r;
}
