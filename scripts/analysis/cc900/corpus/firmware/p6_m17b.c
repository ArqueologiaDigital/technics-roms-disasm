/* Phase 6, probe m17 (form b): the FileIO_* shifts as an unsigned variable shifted in place (m <<= a gave sll in
   m15); TrimAndPadSmfFilename's padding loop guarded by the reversed comparison n > i. */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { unsigned int m = 1; if (a < 10) { m <<= a; ram_272ce |= m; } }
void FileIO_FormatName_Loop(unsigned char a) { unsigned int m = 1; if (a < 10) { m <<= a; ram_272cc |= m; } }
void FileIO_BuildRecordPath_Return(unsigned char a) { unsigned int m = 1; if (a < 10) { m <<= a; ram_272ce &= m ^ 0xffff; } }
void FileIO_FormatName_Copy(unsigned char a) { unsigned int m = 1; if (a < 10) { m <<= a; ram_272cc &= ~m; } }
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
    if (n > i) do { *s++ = ' '; i++; } while (i < n);
    *s = 0;
}
