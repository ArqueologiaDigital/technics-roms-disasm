/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near ram_850c[][32];
extern long ApPostEvent(long, long, void *);
extern void *FileIO_GetFileEntryWithRefresh(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);
extern void DocMed_FormatFileList(long obj, int first);
extern void *GetFileRecordPtr(unsigned int);
extern void PdMed_FormatFileList(long obj, int first);

void DocMed_FormatFileList(long obj, int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = FileIO_GetFileEntryWithRefresh(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 12, 0);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}

void PdMed_FormatFileList(long obj, int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}
