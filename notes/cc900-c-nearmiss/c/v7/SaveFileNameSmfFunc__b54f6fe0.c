/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_operations_m269.c (2026-11-18-12-p6-r35)
   sha256 b54f6fe0aa056534f9b5825e01b9fe6be68fadc64cd6b779380be671f96e8907 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_87b4[];
extern long __near ram_7ff0;
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
        ram_7ff0 = par;
        break;
    case EVT_PAINT:
        ram_87b4[0] = 0;
        FileIO_CopyString(&ram_87b4[1], FileIO_GetRecordPtrAlt());
        FileIO_GetRecordType_Extended(&ram_87b4[1]);
        ApPostEvent(ram_7ff0, EVT_PARA_DRAW, (long)SAVEBUF);
        break;
    case EVT_GET_STRING:
        FileIO_CopyString(ram_87b4, FileIO_GetRecordPtrAlt());
        RenderSmfFilename(SAVEBUF, 8);
        ApPostEvent(par, EVT_SET_STRING, (long)SAVEBUF);
        break;
    case EVT_SET_STRING:
        FileIO_CopyString_WriteNull(ram_87b4, (unsigned char *)par, 8);
        RenderSmfFilename(SAVEBUF, 8);
        FileIO_BuildFilePath(SAVEBUF, (unsigned char *)SaveFN_HandleApply_Str_MID);
        FileIO_WriteRecordName(SAVEBUF);
        break;
    }
    return 0;
}
