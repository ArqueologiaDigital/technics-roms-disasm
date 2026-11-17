/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = (char)(v * 16) / 16 * 2;
}
