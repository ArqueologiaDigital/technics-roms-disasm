/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = ((char)(v << 4) >> 4) * 2;
}
