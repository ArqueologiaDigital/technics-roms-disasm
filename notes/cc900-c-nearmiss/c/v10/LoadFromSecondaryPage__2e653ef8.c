/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_8b.c (2026-11-16-53-p6-r11)
   sha256 2e653ef8b65fbca41cde47c6cf85f0d99977fce6cf00e855ff8dcb59f7554120 (tar-sha256); compiled at -O3 -Xr */
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
        if (FileIO_OpenWithMode(e, (char *)0xea0264) < 0) return FileIO_ReturnError();
    }
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}
