/* lane_p6 helper S, round 31r1: file_io/smf_operations.s (module 269), form a.
   DisplaySmfFileList: twin of the built PdMed_FormatFileList (cc900/medley_m269.c), with InitializeOperationState(0)
   first, GetRecordPtrForFile and the parse arguments 12, 1.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near ram_850c[][32];
extern long ApPostEvent(long, long, void *);
extern void InitializeOperationState(int);
extern char *GetRecordPtrForFile(int);
extern void FileIO_ReadHeader_ParseLoop(unsigned char *, void *, unsigned int, int, int);
extern void DisplaySmfFileList(long obj, int first);

void DisplaySmfFileList(long obj, int first)
{
    int i;
    void *p;

    InitializeOperationState(0);
    for (i = 0; i < 10; i++) {
        ram_850c[i][0] = i;
        p = GetRecordPtrForFile(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_850c[i][1], p, first + i + 1, 12, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_850c[i]);
    }
}
