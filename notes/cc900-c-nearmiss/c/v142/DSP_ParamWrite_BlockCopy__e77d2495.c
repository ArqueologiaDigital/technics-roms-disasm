/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -O3 -Xr */
void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}
