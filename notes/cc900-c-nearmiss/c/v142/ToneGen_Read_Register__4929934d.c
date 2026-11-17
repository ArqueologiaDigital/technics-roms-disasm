/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
unsigned int ToneGen_Read_Register(unsigned int r)
{
    ram_18 &= ~0x80;
    ram_100000 = r;
    return ram_100000;
}
