/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if (a & 0x8000) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}
