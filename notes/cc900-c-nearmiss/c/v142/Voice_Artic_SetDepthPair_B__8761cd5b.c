/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4a.c (2026-11-16-62-sub-r4)
   sha256 8761cd5b09c02ab4a3dcf319bf8f33d0a140160a7f99178b636c4330cd768909 (name+funcs); compiled at -Xr */
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_Artic_SetDepthPair_B(unsigned char part, unsigned char v)
{
    ram_41474[part * 287] = ((char)v >> 4) << 2;
    ram_41475[part * 287] = ((char)((char)v << 4) >> 4) << 3;
}
