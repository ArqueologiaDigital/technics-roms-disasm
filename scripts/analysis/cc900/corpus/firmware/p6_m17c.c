/* Phase 6, probe m17 (form c): the FileIO_* shifts with an unsigned int count, (unsigned int)1 << (unsigned int)a
   written through a local count; TrimAndPadSmfFilename's padding as a for loop over the remaining count. */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { unsigned int b = a; if (b < 10) ram_272ce |= (unsigned int)1 << b; }
void FileIO_FormatName_Loop(unsigned char a) { unsigned int b = a; if (b < 10) ram_272cc |= (unsigned int)1 << b; }
void FileIO_BuildRecordPath_Return(unsigned char a) { unsigned int b = a; if (b < 10) ram_272ce &= ((unsigned int)1 << b) ^ 0xffff; }
void FileIO_FormatName_Copy(unsigned char a) { unsigned int b = a; if (b < 10) ram_272cc &= ~((unsigned int)1 << b); }
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
    if (i < n) { pad: *s++ = ' '; if (++i < n) goto pad; }
    *s = 0;
}
