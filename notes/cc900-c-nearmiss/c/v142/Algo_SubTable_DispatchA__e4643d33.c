/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_8b.c (2026-11-16-82-sub-r8)
   sha256 e4643d333cc84b5363239a62ec397d2578b34ce950ddd7fbbf8f40659745ce7a (name+funcs); compiled at -Xr */
struct algodesc { char pad[0x13]; struct { unsigned char b0, b1, b2, b3, b4; } e[4]; };
extern unsigned char ram_4136e[];
extern struct algodesc DSP_AlgoDescriptor_Records[];
unsigned char Algo_SubTable_DispatchA(unsigned char part, unsigned char k)
{
    unsigned char t;
    unsigned char r;

    t = (*(unsigned char **)&ram_4136e[part * 0x11f])[93] & 0xf;
    r = DSP_AlgoDescriptor_Records[t].e[k].b1;
    if (t == 8 && k == 1)
        r = (*(unsigned char **)&ram_4136e[part * 0x11f])[96];
    return r;
}
