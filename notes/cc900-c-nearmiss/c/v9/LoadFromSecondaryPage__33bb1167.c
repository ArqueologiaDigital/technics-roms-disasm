/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc_m266_xr.c (2026-11-16-68-p6-r12)
   sha256 33bb1167e958e73c3ac6dba0cb8875091b27113db27b57f223baaff7f6726e9e (tar-sha256); compiled at -O3 -Xr
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
    if (FileIO_OpenWithMode(FileIO_GetWallpaperEntry(i), (char *)0xea0264) < 0) return FileIO_ReturnError();
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}
