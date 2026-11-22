/* lane_p6 helper M, round 28r1, form b: module 269 (file_io/medley.s), DocMed_FormatFileList /
   PdMed_FormatFileList, one-spot retry of helper K's p6_K_27r1m269c (run r74, O3Xr equal to +84: the ROM
   builds the posted row's address in XBC where V4.23 used XWA, and ends the loop with a signed test).
   K's form c with the loop test (int)i < 10 only (the posted row as before).
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
    unsigned int i;
    void *p;

    for (i = 0; (int)i < 10; i++) {
        ram_850c[i][0] = i;
        p = FileIO_GetFileEntryWithRefresh(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 12, 0);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}

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
