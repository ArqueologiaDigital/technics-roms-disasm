/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2b.c (2026-11-16-47-sub-r2)
   sha256 fd571eb4a11710ee3f94b685837fcd101aa3642b5af3b15ed9bdb7a9eba8f3f4 (name+funcs); compiled at -O3 -Xr */
void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d)
{
    unsigned int i;
    i = 0;
    while (i < n) {
        *d++ = *s++;
        i++;
    }
}
