/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
unsigned int ToneGen_Read_Register(unsigned int r)
{
    ram_18 &= 0x7f;
    ram_100000 = r;
    return ram_100000;
}
