/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
void Voice_Artic_SetDepthPair_B(unsigned char part, char v)
{
    ram_41474[part * 287] = (v >> 4) << 2;
    ram_41475[part * 287] = (char)(v * 16) / 16 << 3;
}
