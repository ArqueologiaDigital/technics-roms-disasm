/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -O3 -Xr */
extern char LoadSecondary_OpenFile_Str_rb[];
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern void FileIO_CloseHandle(void);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern char *FileIO_GetWallpaperEntry(int);
extern int Gfx_LoadSplashBMP(void);
int LoadFromSecondaryPage(void)
{
    int i, r;
    i = FileIO_GetCurrentWallpaperIndex();
    if (i < 0) return -104;
    {
        char *e = FileIO_GetWallpaperEntry(i);
        if (FileIO_OpenWithMode(e, LoadSecondary_OpenFile_Str_rb) < 0) return FileIO_ReturnError();
    }
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}
