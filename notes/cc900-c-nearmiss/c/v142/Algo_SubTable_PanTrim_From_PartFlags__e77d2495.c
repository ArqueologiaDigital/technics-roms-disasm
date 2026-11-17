/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -Xr
   cc900-name: Algo_PanTrim_From_PartFlags=Algo_SubTable_PanTrim_From_PartFlags */
extern unsigned char ram_4136a[];
#define PART_PRESENT(p) (*(unsigned int *)(ram_4136a + (p) * 0x11f))
char Algo_PanTrim_From_PartFlags(unsigned char part, unsigned char side)
{
    if (PART_PRESENT(part) & 0xc000L) {
        switch (side) {
        case 0: return -4;
        case 1: return -16;
        default: return 0;
        }
    }
    return 0;
}
