/* Phase 6, probe m3c: TrimAndPadSmfFilename's padding loop.  V4.23 at -O3 -XS -Xr reproduces the first 42 bytes from
   trim_a (p6_m3.c) but compiles a while, for or explicit do-while padding loop as a jump to a bottom test; the ROM
   tests before entering and loops on a bottom test.  The firmware's C uses goto (FormatMedleyNumber, p6_m3b.c
   fmt_e), so these variants build the loop by hand. */

void trim_g(unsigned char *s, unsigned int n)
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
    *s++ = ' ';
    i++;
    if (i < n) goto pad;
done:
    *s = 0;
}

void trim_h(unsigned char *s, unsigned int n)
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
    if (i < n) {
    pad:
        *s++ = ' ';
        if (++i < n) goto pad;
    }
    *s = 0;
}
