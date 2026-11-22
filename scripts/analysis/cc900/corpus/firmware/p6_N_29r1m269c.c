/* lane_p6 helper N, round 29r1, form c: module 269 (file_io/medley.s), DocMed_FormatFileList /
   PdMed_FormatFileList (2 x 131 B).  One-spot retry of helper M's p6_M_28r1m269c (run r76, O3Xr, +84: the posted
   row's address built in XWA where the ROM uses XBC, and `(int)i < 10` copied the counter to WA where the ROM
   compares IZ, signed).  Helper I's p6_I_26r1m269b (run r72) had both right with an int counter, but then V4.23
   kept (unsigned)i in BC for `first + i` (the ROM reloads `first` and adds IZ).
   Form c: M's form c with only the counter made int (unsigned `first`, the row ram_850c[0] + i * 32).
   cc900-options: -O3 -Xr
*/

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near ram_850c[][32];
extern long ApPostEvent(long, long, void *);
extern void *FileIO_GetFileEntryWithRefresh(unsigned int);
extern void *GetFileRecordPtr(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);

void DocMed_FormatFileList(long obj, unsigned int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = FileIO_GetFileEntryWithRefresh(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 12, 0);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[0] + i * 32);
    }
}

void PdMed_FormatFileList(long obj, unsigned int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[0] + i * 32);
    }
}
