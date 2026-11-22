/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m269b.c (2026-11-22-9-p6-r76)
   sha256 84c8d33a2e47d663f546528d5937a6cb69e3419be9cc3f079a4e6a8cf7f4f517 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near ram_850c[][32];
extern long ApPostEvent(long, long, void *);
extern void *GetFileRecordPtr(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);
void PdMed_FormatFileList(long obj, unsigned int first)
{
    unsigned int i;
    void *p;

    for (i = 0; (int)i < 10; i++) {
        ram_850c[i][0] = i;
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}
