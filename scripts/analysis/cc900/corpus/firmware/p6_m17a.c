/* Phase 6, probe m17 (form a).  The FileIO_* bit functions of demo/file_demo_proc.s with the shift written
   (unsigned int)1 << (unsigned int)a, which gave V4.23's logical sll A,BC in probe m15 (1U << a gives sla).
   TrimAndPadSmfFilename (file_io/smf_operations.s) with the padding loop written with goto: does V4.23 keep a test
   at the entry and one at the bottom, as the ROM has?  (`if (c) do ... while (c)` did not: m15.) */
extern unsigned int ram_272cc, ram_272ce;
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= (unsigned int)1 << (unsigned int)a; }
void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)1 << (unsigned int)a; }
void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= ((unsigned int)1 << (unsigned int)a) ^ 0xffff; }
void FileIO_FormatName_Copy(unsigned char a) { if (a < 10) ram_272cc &= ~((unsigned int)1 << (unsigned int)a); }
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
    if (i >= n) goto done;
pad:
    *s++ = ' '; i++;
    if (i < n) goto pad;
done:
    *s = 0;
}
