/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8a.c (2026-11-16-53-p6-r11)
   sha256 059fc1dbc74e38faafb386fe8d5405b2a2d3d26241e37ac23ba5310d1dcc5b81 (tar-sha256); compiled at -O3 -Xr */
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
    if (FileIO_OpenWithMode(FileIO_GetWallpaperEntry(i), (char *)0xea0264) < 0) return FileIO_ReturnError();
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}
