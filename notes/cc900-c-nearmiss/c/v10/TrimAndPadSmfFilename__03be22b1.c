/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m15b.c (2026-11-16-28-p6-m15)
   sha256 03be22b1ef334bd2235f1486a044efa220f9eb65e4dd2b2b7faff2cd6b69b6c6 (tar-sha256); compiled at -O3 -XS -Xr */
void TrimAndPadSmfFilename(unsigned char *s, unsigned int n)
{
    unsigned int i = 0;
    unsigned char *p = s;
    unsigned char c;
    if (i < n && (c = *p) != 0) do {
        if (c == '~') c = '_';
        else { c = *s; if (c >= ' ') goto next; c = ' '; }
        *s = c;
    next:
        i++; s++; p++;
    } while (i < n && (c = *p) != 0);
    if (i < n) do { *s++ = ' '; i++; } while (i < n);
    *s = 0;
}
