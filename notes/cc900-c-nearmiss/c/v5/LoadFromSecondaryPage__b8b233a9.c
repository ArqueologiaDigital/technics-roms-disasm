/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m266_xr.c (2026-11-16-68-p6-r12)
   sha256 b8b233a94f03971b458d8ff54d5e058190863d5a5da4315b52ef77802a1eab35 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
    if (FileIO_OpenWithMode(FileIO_GetWallpaperEntry(i), (char *)0xea0150) < 0) return FileIO_ReturnError();
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}
