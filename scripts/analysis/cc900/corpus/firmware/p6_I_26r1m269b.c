/* lane_p6 helper I, round 26r1, form b: module 269 (file_io/medley.s), the file-list formatters only
   (DocMed_FormatFileList, PdMed_FormatFileList; form a has the slot lists too).  The ROM builds the name field's
   address as 0x850c + (1 + i * 32), adding the 1 before the base: here the byte offset is written out instead of
   form a's &row[i].s[1], and the file record comes through a pointer local.
   cc900-options: -O3 -Xr
*/

#define EVT_PARA_DRAW 0x1c0000fL
struct ftxt { unsigned char s[32]; };
extern struct ftxt __near ram_850c[];
extern long ApPostEvent(long, long, void *);
extern void *FileIO_GetFileEntryWithRefresh(unsigned int);
extern void *GetFileRecordPtr(unsigned int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);

void DocMed_FormatFileList(long obj, unsigned int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i].s[0] = i;
        p = FileIO_GetFileEntryWithRefresh(first + i);
        FileIO_ReadHeader_ParseLoop(ram_850c[0].s + (1 + i * 32), p, first + i + 1, 12, 0);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}

void PdMed_FormatFileList(long obj, unsigned int first)
{
    int i;
    void *p;

    for (i = 0; i < 10; i++) {
        ram_850c[i].s[0] = i;
        p = GetFileRecordPtr(first + i);
        FileIO_ReadHeader_ParseLoop(ram_850c[0].s + (1 + i * 32), p, first + i + 1, 20, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i].s);
    }
}
