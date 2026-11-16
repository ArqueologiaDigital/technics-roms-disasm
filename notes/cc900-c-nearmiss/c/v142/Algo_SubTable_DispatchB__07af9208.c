/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_13a.c (2026-11-16-99-sub-r13-idioms)
   sha256 07af92085d60f74ae617b901622900e04ec8ef299af678c92733e4f109cccacf (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char DSP_AlgoDescriptor_Records[];
unsigned char Algo_SubTable_DispatchB(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;
    int c;
    int o;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    c = (int)k * 5 + 0x13;
    o = (int)t * 39;
    r = *(unsigned char *)((unsigned long)&(DSP_AlgoDescriptor_Records + (long)o)[c] + 2);
    switch (t) {
    case 0: case 1: case 2: case 3:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
            r += r;
        }
        break;
    case 4: case 5:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[98];
            r += r;
        }
        break;
    case 8:
        if (k == 1)
            {
            r = (*(unsigned char **)&ram_4136e[part * 0x11f])[95];
            r += r;
        }
        break;
    }
    return r;
}
