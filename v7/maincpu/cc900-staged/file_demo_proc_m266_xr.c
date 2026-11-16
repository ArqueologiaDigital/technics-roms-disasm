/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
