/* Phase 6, probe m15 (form a): does V4.23 copy a loop's test to the entry for `if (c) do { ... } while (c);`?  The
   firmware's loops mostly have the test at the entry and again at the bottom (loop-entry-copy, rules.md), where
   `while (c)` gives V4.23's jump to a bottom test.  TrimAndPadSmfFilename (file_io/smf_operations.s), padding loop
   written as a guarded do-while. */
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
    if (i < n) do { *s++ = ' '; i++; } while (i < n);
    *s = 0;
}
