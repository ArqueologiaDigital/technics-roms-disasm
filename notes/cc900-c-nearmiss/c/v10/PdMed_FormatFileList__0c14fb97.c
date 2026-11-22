/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m269b.c (2026-11-22-7-p6-r74)
   sha256 0c14fb973a80715301dd702f7a9c47a1587ed40ad97daa050247fc3123fd41bf (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_PARA_DRAW 0x1c0000fL
struct ftxt { unsigned char s[32]; };
extern struct ftxt __near ram_850c[];
extern long ApPostEvent(long, long, void *);
extern void *GetFileRecordPtr(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);
void PdMed_FormatFileList(long obj, unsigned int first)
{
    unsigned int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i].s[0] = i;
        p = GetFileRecordPtr(i + first);
        FileIO_ReadHeader_ParseLoop(ram_850c[0].s + (1 + i * 32), p, i + first + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}
