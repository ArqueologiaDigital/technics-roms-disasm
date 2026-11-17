/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = ((char)(v << 4) >> 4) << 1;
}
