/* lane_p6 helper K, round 27r1, form c: module 269 (file_io/medley.s), one-spot retry of DocMed_FormatFileList /
   PdMed_FormatFileList from p6_I_26r1m269b (run 2026-11-22-5-p6-r72, O3Xr equal to +11).  There the int counter
   made V4.23 load it before `first` (and share that load with the row address) and fold the 1 of 1 + i * 32 into
   the base with sla / exts; the ROM uses sll / extz everywhere, loads `first` before adding the counter and adds 1
   to the shifted index before zero-extending it.  Form c: unsigned counter, the rows as a two-dimensional byte
   array, the name field as &ram_850c[i][1].
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

    for (i = 0; i < 10; i++) {
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

    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}
