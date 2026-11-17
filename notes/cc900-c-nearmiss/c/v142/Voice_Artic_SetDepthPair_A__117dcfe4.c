/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3a.c (2026-11-16-58-sub-r3)
   sha256 117dcfe4c69ab73765948417bed771add93ad5e8a4aacafd170500b351b44157 (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = (v << 4 >> 4) * 2;
}
