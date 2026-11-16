/* Phase 6, probe m15 (form b): TrimAndPadSmfFilename with both loops as guarded do-whiles. */
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
