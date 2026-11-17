/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_song.c (2026-11-16-119-hd-r30)
   sha256 1b0b3425565dbcd8f801136a0c450ece38c98939f682467189952383017fc424 (tar-sha256); compiled at -Xr
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
