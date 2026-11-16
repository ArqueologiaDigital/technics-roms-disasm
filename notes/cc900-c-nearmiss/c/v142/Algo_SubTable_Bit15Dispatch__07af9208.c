/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_13a.c (2026-11-16-99-sub-r13-idioms)
   sha256 07af92085d60f74ae617b901622900e04ec8ef299af678c92733e4f109cccacf (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char DSP_AlgoDescriptor_Records[];
extern unsigned char DSP_ChanFreq_IndexMap[];
unsigned char Algo_SubTable_Bit15Dispatch(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    int c;
    int o;

    if (*(unsigned int *)&ram_41372[part * 0x11f] & 0x8000L) {
        t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
        c = (int)k * 5 + 0x13;
        o = (int)t * 39;
        r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)o)[c] + 4);
        switch (t) {
        case 0: case 1: case 2: case 3:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[97]];
            break;
        case 4: case 5:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[99]];
            break;
        case 8:
            if (k == 1)
                r = DSP_ChanFreq_IndexMap[(*(unsigned char **)&ram_4136e[part * 0x11f])[94]];
            break;
        }
    } else
        r = 0;
    return r;
}
