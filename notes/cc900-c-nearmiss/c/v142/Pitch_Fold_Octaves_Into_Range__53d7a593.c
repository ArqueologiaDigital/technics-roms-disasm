/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
int Pitch_Fold_Octaves_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    while (v & 0x8000) {
        if (v > -0x4000) v += 0xc00;
        else v -= 0xc00;
    }
    while (v < (lo << 8) + 0x80) v += 0xc00;
    while (v > (hi << 8) + 0x80) v -= 0xc00;
    return v;
}
