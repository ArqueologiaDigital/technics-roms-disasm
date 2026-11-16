/* Phase 6, probe m3: guessed C for two larger v10 leaf functions, to learn which option set (-O3 -XS -Xr or -Xr)
   reproduces them.  The reference model refuses the first guesses, so the oracle's object bytes are compared with
   the ROM (rel_vs_rom.py).  trim_*: TrimAndPadSmfFilename (XWA = the name, in place; BC = its width): '~' becomes
   '_', a control character a space, the rest is padded with spaces and a NUL is written at the width.  fmt_*:
   FormatMedleyNumber (XWA = destination, C = entry byte, E = first character; see v10/maincpu/file_io/medley.s). */

void trim_a(unsigned char *s, unsigned int n)
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

void trim_b(unsigned char *s, unsigned int n)
{
    unsigned int i;
    unsigned char *p = s;
    unsigned char c;
    for (i = 0; i < n && (c = *p) != 0; i++, s++, p++) {
        if (c == '~') *s = '_';
        else if ((c = *s) < ' ') *s = ' ';
    }
    for (; i < n; i++) *s++ = ' ';
    *s = 0;
}

void trim_c(unsigned char *s, unsigned int n)
{
    unsigned int i;
    unsigned char *p = s;
    unsigned char c;
    for (i = 0; i < n; i++, s++, p++) {
        if ((c = *p) == 0) break;
        if (c == '~') c = '_';
        else if ((c = *s) < ' ') c = ' ';
        else continue;
        *s = c;
    }
    for (; i < n; i++) *s++ = ' ';
    *s = 0;
}

void trim_d(char *s, int n)
{
    int i = 0;
    char *p = s;
    unsigned char c;
    while (i < n && (c = *p) != '\0') {
        if (c == '~') c = '_';
        else { c = *s; if (c >= 0x20) goto next; c = 0x20; }
        *s = c;
    next:
        i++; s++; p++;
    }
    while (i < n) { *s++ = ' '; i++; }
    *s = '\0';
}

void fmt_a(unsigned char *p, unsigned char n, unsigned char first)
{
    *p++ = first;
    if (n == 0xff) n = ' ';
    else if (n == 0xfe) n = 'M';
    else {
        n++;
        if (n >= 100) { *p++ = n / 100 + '0'; n = n % 100; }
        else *p++ = 'M';
        if (n < 10) { *p++ = '0'; *p = n + '0'; }
        else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
        return;
    }
    *p++ = n; *p++ = ' '; *p = ' ';
}

void fmt_b(char *p, unsigned char n, char first)
{
    *p++ = first;
    if (n == 0xff || n == 0xfe) {
        *p++ = (n == 0xff) ? ' ' : 'M';
        *p++ = ' '; *p = ' ';
        return;
    }
    n++;
    if (n >= 100) { *p++ = n / 100 + '0'; n %= 100; }
    else *p++ = 'M';
    if (n < 10) { *p++ = '0'; *p = n + '0'; }
    else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
}

void fmt_c(char *p, unsigned char n, char first)
{
    *p++ = first;
    if (n == 0xff) { n = ' '; goto pad; }
    if (n == 0xfe) { n = 'M'; goto pad; }
    n++;
    if (n >= 100) { *p++ = n / 100 + '0'; n %= 100; }
    else *p++ = 'M';
    if (n < 10) { *p++ = '0'; *p = n + '0'; }
    else { *p++ = n / 10 + '0'; *p = n % 10 + '0'; }
    return;
pad:
    *p++ = n; *p++ = ' '; *p = ' ';
}
