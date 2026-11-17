/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_song_module.c (2026-11-16-105-hd-r23b)
   sha256 c27a78f36756345cf752a3815f3cb259fdc3962d7d3131aba5733203a7d06edb (tar-sha256); compiled at -Xr
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
