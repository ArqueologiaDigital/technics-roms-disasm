/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4b.c (2026-11-16-62-sub-r4)
   sha256 2930891c0f4cc37037eb6f8318034f85e7213280edee0124175fee577eb1783d (name+funcs); compiled at -Xr */
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_Artic_SetDepthPair_B(unsigned char part, unsigned char v)
{
    ram_41474[part * 287] = ((char)v >> 4) << 2;
    ram_41475[part * 287] = ((char)(v << 4) >> 4) << 3;
}
