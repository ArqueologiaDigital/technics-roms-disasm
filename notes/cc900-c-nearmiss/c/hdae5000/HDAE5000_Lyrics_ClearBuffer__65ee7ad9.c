/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_lyrics.c (2026-11-16-63-hd-r9s-staged)
   sha256 65ee7ad9fda77da488ee5d76396483b3b62bb35b8fe47710a93540aa2ce8888b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern unsigned char HDAE5000_RAM_LyricLoaded;
extern unsigned long HDAE5000_RAM_LyricFileLength;
void HDAE5000_Lyrics_ClearBuffer(void)
{
    HDAE5000_MemFill(HDAE5000_RAM_LyricBuffer, 0, 0x5000);
    HDAE5000_RAM_LyricFileLength = 0;
    HDAE5000_RAM_LyricLoaded = 0;
}
