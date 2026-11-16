/* Phase 6, probe m18 (form a).  The FileIO_* bit functions with only the 1 cast, (unsigned int)1 << a: m17's casts of
   the count added an extz WA the ROM lacks.  TrimAndPadSmfFilename as in the model build (plain while loops), for
   the option-level question: at -O3 -XS -Xr V4.23 jumps to the padding loop's bottom test, at -Xr it copies the test
   to the entry as the ROM does but with other registers.  Does -O1 or -O2 give both? */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= (unsigned int)1 << a; }
void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)1 << a; }
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= ((unsigned int)1 << a) ^ 0xffff; }
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) ram_272cc &= ~((unsigned int)1 << a); }
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
