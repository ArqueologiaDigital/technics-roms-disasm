/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = *p + d;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
}
