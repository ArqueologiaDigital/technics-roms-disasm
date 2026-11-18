/* Functions of file_io/smf_operations.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: InitializeOperationState RenderSmfFilename ResetProgressIndication SignalProgressUpdate */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_8798[];
extern long __near ram_7fd4;
extern char SaveFN_HandleApply_Str_MID[];
extern unsigned char *FileIO_GetRecordPtrAlt(void);
extern void FileIO_CopyString(unsigned char *, unsigned char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern void FileIO_GetRecordType_Extended(unsigned char *);
extern void FileIO_BuildFilePath(unsigned char *, unsigned char *);
extern void FileIO_WriteRecordName(unsigned char *);
extern void RenderSmfFilename(unsigned char *name, unsigned char len);
extern long ApPostEvent(long, long, long);
#define EVT_PAINT 0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GET_STRING 0x1e0003aL
#define EVT_SET_STRING 0x1e00086L
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
#define SAVEBUF ((unsigned char *)0x8850)
extern long SaveFileNameSmfFunc(unsigned long obj, long evt, long par);

long SaveFileNameSmfFunc(unsigned long obj, long evt, long par)
{
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_7fd4 = par;
        break;
    case EVT_PAINT:
        ram_8798[0] = 0;
        FileIO_CopyString(&ram_8798[1], FileIO_GetRecordPtrAlt());
        FileIO_GetRecordType_Extended(&ram_8798[1]);
        ApPostEvent(ram_7fd4, EVT_PARA_DRAW, (long)SAVEBUF);
        break;
    case EVT_GET_STRING:
        FileIO_CopyString(ram_8798, FileIO_GetRecordPtrAlt());
        RenderSmfFilename(SAVEBUF, 8);
        ApPostEvent(par, EVT_SET_STRING, (long)SAVEBUF);
        break;
    case EVT_SET_STRING:
        FileIO_CopyString_WriteNull(ram_8798, (unsigned char *)par, 8);
        RenderSmfFilename(SAVEBUF, 8);
        FileIO_BuildFilePath(SAVEBUF, (unsigned char *)SaveFN_HandleApply_Str_MID);
        FileIO_WriteRecordName(SAVEBUF);
        break;
    }
    return 0;
}
