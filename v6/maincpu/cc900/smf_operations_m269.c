/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near ram_8454[][32];
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
        ram_8454[i][0] = i;
        p = GetRecordPtrForFile(first + i);
        FileIO_ReadHeader_ParseLoop(&ram_8454[i][1], p, first + i + 1, 12, 1);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8454[i]);
    }
}
