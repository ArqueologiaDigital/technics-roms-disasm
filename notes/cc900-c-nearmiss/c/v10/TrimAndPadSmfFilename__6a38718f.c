/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17b.c (2026-11-16-30-p6-r1)
   sha256 6a38718f6b18d9e47c48879c226f2366390c0d8c002d28c6f6cd3bce8510a3b2 (tar-sha256); compiled at -O3 -XS -Xr */
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
    if (n > i) do { *s++ = ' '; i++; } while (i < n);
    *s = 0;
}
