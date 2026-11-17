/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
extern struct slot __near ram_4496[];
struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        return &ram_4496[i];
    default:
        return (struct slot *)0xffffffff;
    }
}
