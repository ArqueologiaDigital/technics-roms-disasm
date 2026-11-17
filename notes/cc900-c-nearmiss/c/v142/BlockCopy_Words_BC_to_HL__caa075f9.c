/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_1b.c (2026-11-16-43-sub-r1)
   sha256 caa075f9e2f355946df32cabf8a6cca8b9b0df9ffd1184f435a2d1d419429885 (name+funcs); compiled at -O3 -Xr */
void BlockCopy_Words_BC_to_HL(char *s, char *d, int n)
{
    int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}
