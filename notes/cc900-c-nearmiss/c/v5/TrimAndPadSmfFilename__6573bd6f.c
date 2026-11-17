/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/smf_operations.c (2026-11-16-34-p6-firmware)
   sha256 6573bd6f64aa81c2788191d06e0709e80f53e1fb7c80441468477a7f5603569b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
