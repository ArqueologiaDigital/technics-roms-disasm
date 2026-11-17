/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2b.c (2026-11-16-47-sub-r2)
   sha256 fd571eb4a11710ee3f94b685837fcd101aa3642b5af3b15ed9bdb7a9eba8f3f4 (name+funcs); compiled at -O3 -Xr
   cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
extern unsigned char ram_4136a[];
#define PART_PRESENT(p) (((unsigned int *)(ram_4136a + (p) * 0x11f))[0])
char Algo_PanTrim_From_PartFlags(unsigned char part, unsigned char side)
{
    char r;
    if ((unsigned long)PART_PRESENT(part) & 0xc000) {
        switch (side) {
        case 0: r = -4; break;
        case 1: r = -16; break;
        default: r = 0; break;
        }
    } else r = 0;
    return r;
}
