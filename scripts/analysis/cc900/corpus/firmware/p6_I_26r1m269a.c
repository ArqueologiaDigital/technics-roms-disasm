/* lane_p6 helper I, round 26r1, form a: module 269 (file_io/medley.s), the slot-list formatters of the DOC and PD
   medleys (family of 2 x 207 B: DocMed_FormatSlotList, PdMed_FormatSlotList), written exactly as the built
   SmfMed_FormatSlotList (medley_m269.c) with their own text rows (0x84a4 / 0x8444) and file-name functions.
   Also the two file-list formatters (family of 2 x 113 B: DocMed_FormatFileList, PdMed_FormatFileList).
   cc900-options: -O3 -Xr
*/
/* cc900-module: FmmDocFileNameFunc FmmPdFileNameFunc FormatMedleyNumber */

#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_84a4[];
extern struct mtxt __near ram_8444[];
extern unsigned char __near ram_88a0[];
extern long FmmDocFileNameFunc(long, long, long);
extern long FmmPdFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
struct ftxt { unsigned char s[32]; };
extern struct ftxt __near ram_850c[];
extern void *FileIO_GetFileEntryWithRefresh(unsigned int);
extern void *GetFileRecordPtr(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);

void DocMed_FormatFileList(long obj, unsigned int first)
{
    int i;

    for (i = 0; i < 10; i++) {
        ram_850c[i].s[0] = i;
        FileIO_ReadHeader_ParseLoop(&ram_850c[i].s[1], FileIO_GetFileEntryWithRefresh(first + i), first + i + 1, 12, 0);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}

void PdMed_FormatFileList(long obj, unsigned int first)
{
    int i;

    for (i = 0; i < 10; i++) {
        ram_850c[i].s[0] = i;
        FileIO_ReadHeader_ParseLoop(&ram_850c[i].s[1], GetFileRecordPtr(first + i), first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}

void DocMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmDocFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    for (i = 0; i < n; i++) {
        FormatMedleyNumber(ram_84a4[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_84a4[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_84a4[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_84a4[i].s);
    }
}

void PdMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmPdFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    for (i = 0; i < n; i++) {
        FormatMedleyNumber(ram_8444[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8444[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
}
