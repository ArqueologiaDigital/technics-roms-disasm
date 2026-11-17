/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m15a.c (2026-11-16-28-p6-m15)
   sha256 0a541a1b87f00f3c99d3b42866062051fe7af1ce1642b90ec4632de808876237 (tar-sha256); compiled at -O3 -XS -Xr */
void TrimAndPadSmfFilename(unsigned char *s, unsigned int n)
{
    unsigned int i = 0;
    unsigned char *p = s;
    unsigned char c;
    while (i < n && (c = *p) != 0) {
        if (c == '~') c = '_';
        else { c = *s; if (c >= ' ') goto next; c = ' '; }
        *s = c;
    next:
        i++; s++; p++;
    }
    if (i < n) do { *s++ = ' '; i++; } while (i < n);
    *s = 0;
}
