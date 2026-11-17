/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = (int)d + *p;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
}
