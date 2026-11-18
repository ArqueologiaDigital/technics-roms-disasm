/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_23m269b.c (2026-11-18-1-p6-r33)
   sha256 123c9747435a46b522adcbca54af29c7d0f51724b429c96fd94b2f3cf5739051 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_878c[];
extern unsigned char __near ram_8870[];
extern unsigned char CType_ClassTable[];
extern void InitializeOperationState(int);
extern void SignalProgressUpdate(void);
extern void ResetProgressIndication(void);
extern unsigned char *FileIO_SearchAndLoadFile(void);
extern void FileIO_CopyString(unsigned char *, unsigned char *);
extern void FileIO_CheckPathAndVolumeLabel(unsigned char *);
extern long ApPostEvent(long, long, long);
extern void UI_ChangeTitleByIndex(unsigned int);
#define EVT_PAINT 0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GET_STRING 0x1e0003aL
#define EVT_SET_STRING 0x1e00086L
#define TT_DKMENU 0x60
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
        FileIO_CopyString((unsigned char *)(void *)ram_878c, (unsigned char *)par);
        InitializeOperationState(0);
        FileIO_CheckPathAndVolumeLabel((unsigned char *)0x878c);
        SignalProgressUpdate();
        ResetProgressIndication();
        UI_ChangeTitleByIndex(TT_DKMENU);
        break;
    }
    return 0;
}
