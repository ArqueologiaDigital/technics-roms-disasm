/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4c.c (2026-11-16-62-sub-r4)
   sha256 5fa07bbc698c05cdf1499ef39438f01891abf5d3f8e20a0d5e7cd774bd8f0d32 (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
void Voice_Artic_SetDepthPair_A(unsigned char part, unsigned char v)
{
    ram_41472[part * 287] = ((char)v >> 4) << 2;
    ram_41473[part * 287] = ((char)(unsigned char)(v << 4) >> 4) * 2;
}
