/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m17a.c (2026-11-16-30-p6-r1)
   sha256 4108bbf0bdcc17ce8617a11b94614744679f91da164a15ae5e06c1b358cbc962 (tar-sha256); compiled at -O3 -XS -Xr */
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
    if (i >= n) goto done;
pad:
    *s++ = ' '; i++;
    if (i < n) goto pad;
done:
    *s = 0;
}
