/* Phase 6, probe m3b: follow-up of p6_m3.c.  In run 2026-11-16-9-p6-m3, V4.23 at -O3 -XS -Xr reproduced the first 42
   bytes of TrimAndPadSmfFilename from trim_a, all but the padding loop, which the ROM tests before entering, and the
   instructions of FormatMedleyNumber from fmt_a in a different block order (the ROM puts the space padding after
   the 'M' arm).  These variants change only those two shapes. */

void trim_e(unsigned char *s, unsigned int n)
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

void trim_f(unsigned char *s, unsigned int n)
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
    if (i < n) { do { *s++ = ' '; } while (++i < n); }
    *s = 0;
}

void fmt_d(unsigned char *p, unsigned char n, unsigned char first)
{
    *p++ = first;
    switch (n) {
    case 0xff: n = ' '; break;
    case 0xfe: n = 'M'; break;
    default:
        n++;
        if (n >= 100) { *p++ = n / 100 + '0'; n = n % 100; }
        else *p++ = 'M';
        if (n < 10) { *p++ = '0'; *p = n + '0'; }
        else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
        return;
    }
    *p++ = n; *p++ = ' '; *p = ' ';
}

void fmt_e(unsigned char *p, unsigned char n, unsigned char first)
{
    *p++ = first;
    if (n == 0xff) n = ' ';
    else if (n == 0xfe) n = 'M';
    else goto number;
    *p++ = n; *p++ = ' '; *p = ' ';
    return;
number:
    n++;
    if (n >= 100) { *p++ = n / 100 + '0'; n = n % 100; }
    else *p++ = 'M';
    if (n < 10) { *p++ = '0'; *p = n + '0'; }
    else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
}

void fmt_f(unsigned char *p, unsigned char n, unsigned char first)
{
    *p++ = first;
    if (n != 0xff) {
        if (n != 0xfe) {
            n++;
            if (n >= 100) { *p++ = n / 100 + '0'; n = n % 100; }
            else *p++ = 'M';
            if (n < 10) { *p++ = '0'; *p = n + '0'; }
            else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
            return;
        }
        n = 'M';
    } else n = ' ';
    *p++ = n; *p++ = ' '; *p = ' ';
}
