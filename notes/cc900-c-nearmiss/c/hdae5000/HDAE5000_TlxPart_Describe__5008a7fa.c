/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_song_module.c (2026-11-16-78-hd-r15-ports)
   sha256 5008a7fa33f3136b9b89f8207958a8ad56b608e39b4e89b5b925b23e9ebcac81 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct ResInfo { unsigned long addr; unsigned long size; };
extern int HDAE5000_SwapBytes32();
extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern unsigned long HDAE5000_RAM_LyricFileLength;
#define TLX_TRLEN (*(unsigned long *)&HDAE5000_RAM_LyricBuffer[18])
int HDAE5000_TlxPart_Describe(int part, struct ResInfo *info)
{
    info->addr = (unsigned long)HDAE5000_RAM_LyricBuffer;
    HDAE5000_RAM_LyricFileLength = info->size = HDAE5000_SwapBytes32(TLX_TRLEN) + 0x16;
    return part;
}
