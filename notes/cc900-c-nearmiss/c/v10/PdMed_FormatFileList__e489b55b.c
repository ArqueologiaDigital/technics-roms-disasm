/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m269a.c (2026-11-22-7-p6-r74)
   sha256 e489b55b23b02189b9880742e56be022257579ff3b7de44eaf79e8f1b406183f (tar-sha256); compiled at -O3 -Xr
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
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(ram_850c[0].s + (1 + i * 32), p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}
