/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_23m269a.c (2026-11-18-1-p6-r33)
   sha256 3c9b256875d444cc6812d45b875a32abdc5f291cbafecf705acef7f015f1e777 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_8850[];
extern long __near ram_808c;
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
