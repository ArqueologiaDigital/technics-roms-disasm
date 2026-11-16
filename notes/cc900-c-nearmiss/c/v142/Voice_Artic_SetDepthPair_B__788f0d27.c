/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3b.c (2026-11-16-58-sub-r3)
   sha256 788f0d271359aef4ace536ce58c994c054403ce241712b29d2f7e0b99f5470cf (name+funcs); compiled at -Xr */
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_Artic_SetDepthPair_B(unsigned char part, char v)
{
    ram_41474[part * 287] = (v >> 4) << 2;
    ram_41475[part * 287] = ((char)v << 4 >> 4) << 3;
}
