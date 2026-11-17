/* cc900-module: InitializeOperationState ResetProgressIndication SignalProgressUpdate */
/* Phase 6, lane_p6 helper A, round 21, form a: module 269 (file_io/disk_operations.s), DiskNameFunc (new): the
   disk-name box's proc.  PAINT: reload the name into the 11-character buffer 0x878c and draw it; GET_STRING: reload it,
   turn every character whose class (CType_ClassTable) has none of bits 0-2 into '_', pad with '_' to 11 and
   terminate, and post it as the string; SET_STRING: copy the new name in and apply it as the volume label, then back
   to the DISK menu title.  Cases in the ROM body order (PAINT, GET_STRING, SET_STRING). */
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
        ApPostEvent(par, EVT_PARA_DRAW, (long)ram_878c);
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
        FileIO_CopyString((unsigned char *)0x878c, (unsigned char *)par);
        InitializeOperationState(0);
        FileIO_CheckPathAndVolumeLabel((unsigned char *)0x878c);
        SignalProgressUpdate();
        ResetProgressIndication();
        UI_ChangeTitleByIndex(TT_DKMENU);
        break;
    }
    return 0;
}
