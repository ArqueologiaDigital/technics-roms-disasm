/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17c.c (2026-11-16-30-p6-r1)
   sha256 26834bdafa64fa092691633e44bd4c9260e99cbee53eaf2178a64d3ca92b3811 (tar-sha256); compiled at -O3 -XS -Xr */
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
    if (i < n) { pad: *s++ = ' '; if (++i < n) goto pad; }
    *s = 0;
}
