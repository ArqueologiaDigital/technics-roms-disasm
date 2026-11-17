/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_8c.c (2026-11-16-82-sub-r8)
   sha256 59f7cd102d33d2589991b614c982a6d170c222696864131c7f870e198fc4160b (name+funcs); compiled at -Xr */
struct algodesc { char pad[0x13]; struct { unsigned char b0, b1, b2, b3, b4; } e[4]; };
extern unsigned char ram_4136e[];
extern struct algodesc DSP_AlgoDescriptor_Records[];
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)(ram_4136e + part * 0x11f))[93] & 0xf;
    r = DSP_AlgoDescriptor_Records[t].e[k].b1;
    if (t == 8 && k == 1)
        r = (*(unsigned char **)(ram_4136e + part * 0x11f))[96];
    return r;
}
