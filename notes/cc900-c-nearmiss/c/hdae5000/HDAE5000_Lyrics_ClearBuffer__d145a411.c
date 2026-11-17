/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics.c (2026-11-16-78-hd-r15-ports)
   sha256 d145a4110744569645fe5fa90b81074d74009d813cb945de0f2b13be7d48739e (tar-sha256); compiled at -Xr
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
