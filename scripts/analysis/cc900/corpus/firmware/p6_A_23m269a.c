/* cc900-module: InitializeOperationState RenderSmfFilename ResetProgressIndication SignalProgressUpdate */
/* Phase 6, lane_p6 helper A, round 23, form a: module 269, DiskNameFunc (file_io/disk_operations.s) and
   SaveFileNameSmfFunc (file_io/smf_operations.s, new).  DiskNameFunc: round 22b with SET_STRING's buffer argument
   as (unsigned char *)(long)ram_878c.  SaveFileNameSmfFunc: the array used directly, the converted uses as the constant address. */
extern unsigned char __near ram_878c[];
extern unsigned char __near ram_8870[];
extern unsigned char __near ram_8850[];
extern long __near ram_808c;
extern unsigned char CType_ClassTable[];
extern char SaveFN_HandleApply_Str_MID[];
extern void InitializeOperationState(int);
extern void SignalProgressUpdate(void);
extern void ResetProgressIndication(void);
extern unsigned char *FileIO_SearchAndLoadFile(void);
extern unsigned char *FileIO_GetRecordPtrAlt(void);
extern void FileIO_CopyString(unsigned char *, unsigned char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);
extern void FileIO_GetRecordType_Extended(unsigned char *);
extern void FileIO_BuildFilePath(unsigned char *, unsigned char *);
extern void FileIO_WriteRecordName(unsigned char *);
extern void RenderSmfFilename(unsigned char *name, unsigned char len);
extern long ApPostEvent(long, long, long);
extern void UI_ChangeTitleByIndex(unsigned int);
#define EVT_PAINT 0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GET_STRING 0x1e0003aL
#define EVT_SET_STRING 0x1e00086L
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L
#define TT_DKMENU 0x60
#define SAVEBUF ((unsigned char *)0x8850)

long DiskNameFunc(unsigned long obj, long evt, long par)
{
    int i;
    switch (evt) {
    case EVT_PAINT:
        InitializeOperationState(0);
        FileIO_CopyString(ram_878c, FileIO_SearchAndLoadFile());
        ApPostEvent(par, EVT_PARA_DRAW, (long)(unsigned char *)0x878c);
        break;
    case EVT_GET_STRING:
        InitializeOperationState(0);
        FileIO_CopyString(ram_878c, FileIO_SearchAndLoadFile());
        for (i = 0; i < 11 && ram_878c[i] != 0; i++)
            if ((CType_ClassTable[ram_8870[i]] & 7) == 0)
                ram_878c[i] = '_';
        for (; i < 11; i++)
            ram_878c[i] = '_';
        ram_878c[11] = 0;
        ApPostEvent(par, EVT_SET_STRING, (long)ram_878c);
        break;
    case EVT_SET_STRING:
        FileIO_CopyString((unsigned char *)(long)ram_878c, (unsigned char *)par);
        InitializeOperationState(0);
        FileIO_CheckPathAndVolumeLabel((unsigned char *)0x878c);
        SignalProgressUpdate();
        ResetProgressIndication();
        UI_ChangeTitleByIndex(TT_DKMENU);
        break;
    }
    return 0;
}

long SaveFileNameSmfFunc(unsigned long obj, long evt, long par)
{
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_808c = par;
        break;
    case EVT_PAINT:
        ram_8850[0] = 0;
        FileIO_CopyString(&ram_8850[1], FileIO_GetRecordPtrAlt());
        FileIO_GetRecordType_Extended(&ram_8850[1]);
        ApPostEvent(ram_808c, EVT_PARA_DRAW, (long)SAVEBUF);
        break;
    case EVT_GET_STRING:
        FileIO_CopyString(ram_8850, FileIO_GetRecordPtrAlt());
        RenderSmfFilename(SAVEBUF, 8);
        ApPostEvent(par, EVT_SET_STRING, (long)SAVEBUF);
        break;
    case EVT_SET_STRING:
        FileIO_CopyString_WriteNull(ram_8850, (unsigned char *)par, 8);
        RenderSmfFilename(SAVEBUF, 8);
        FileIO_BuildFilePath(SAVEBUF, (unsigned char *)SaveFN_HandleApply_Str_MID);
        FileIO_WriteRecordName(SAVEBUF);
        break;
    }
    return 0;
}
