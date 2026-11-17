/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/smf_operations.c (2026-11-16-18-p6-firmware)
   sha256 11131a8f5b5e63f769117767f532fe274a138507b8511387aad5a225c354d4a4 (tar-sha256); compiled at -O3 -XS -Xr */
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
    while (i < n) { *s++ = ' '; i++; }
    *s = 0;
}
