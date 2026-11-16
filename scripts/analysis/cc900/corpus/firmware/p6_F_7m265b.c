/* lane_p6 helper F, round 7, module 265 (demo/file_demo_proc.s), form b: as form a with the path blanked by an
   indexed for loop (left to V4.23's strength reduction) and the first block's buffer pointer kept unnamed.
   FDemo_DisplayResourceData: build "<name, 8 chars>" + ".SQT"-style suffix in a blank-filled 32-byte path, open it
   "rb", and copy the file in 256-byte blocks into buffers from FDemo_AllocBuffer (the first block's byte 4 is a
   format flag; with flag 1 the 72 blocks after the first 8 are skipped).  Returns the open result.
   Run 88 (Fade_Cancel) showed V4.23 at -O3 -Xr loads a long constant such as 256 with `ld`, as the ROM does. */

/* cc900-module: FDemo_AllocBuffer FDemo_ResetAllocBuffer */

extern int __cdecl Strlen(char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern char *__cdecl Strcat(char *, char *);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern int FileIO_OpenWithMode(char *, char *);
extern long FileIO_ReadBlock(void *, unsigned long);
extern void FileIO_CloseHandle(void);
extern void FDemo_ResetAllocBuffer(void);
extern void *FDemo_AllocBuffer(unsigned long);
extern char FDemo_DisplayResourceData_Str_SQT[];
extern char FDemo_DisplayResourceData_Str_rb[];

int FDemo_DisplayResourceData(char *name)
{
    char path[32];
    unsigned char buf[256];
    int r;
    int fmt;
    int i;

    fmt = 0;
    for (i = 0; i < 32; i++) path[i] = ' ';
    Strncpy(path, name, Strlen(name));
    path[8] = 0;
    Strcat(path, FDemo_DisplayResourceData_Str_SQT);
    r = FileIO_OpenWithMode(path, FDemo_DisplayResourceData_Str_rb);
    if (r >= 0) {
        FDemo_ResetAllocBuffer();
        if (FileIO_ReadBlock(buf, 256) != 0) {
            Mem_Copy(FDemo_AllocBuffer(256), (fmt = buf[4], buf), 256);
        }
        for (i = 1; i < 8; i++) {
            if (FileIO_ReadBlock(buf, 256) != 0) Mem_Copy(FDemo_AllocBuffer(256), buf, 256);
        }
        if (fmt == 1) {
            for (i = 0; i < 72; i++) FileIO_ReadBlock(buf, 256);
        }
        while (FileIO_ReadBlock(buf, 256) != 0) Mem_Copy(FDemo_AllocBuffer(256), buf, 256);
        FileIO_CloseHandle();
    }
    return r;
}
