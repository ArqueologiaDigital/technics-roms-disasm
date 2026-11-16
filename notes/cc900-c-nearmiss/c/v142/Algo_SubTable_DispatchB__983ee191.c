/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_12c.c (2026-11-16-97-sub-r12)
   sha256 983ee191b3d635eb8ab5c7c66bccf4d566c10914633ec1b0c7a1864891b9da5f (name+funcs); compiled at -Xr */
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
