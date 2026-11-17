/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_loadsong_tlx.c (2026-11-17-5-hd-r38-ports)
   sha256 ce7b397f6a6c77ac81ad3631e5893468009f5e748617c5cba5fed8246b17e658 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: LdTlx_u=HDAE5000_LoadSong_Tlx */
struct ResInfo { unsigned long addr; unsigned long size; };
extern int HDAE5000_HD_ReadFile();
extern void HDAE5000_Lyrics_ClearBuffer(void);
extern int HDAE5000_TlxPart_Describe();
extern unsigned char HDAE5000_RAM_DirNames[];
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
unsigned int LdTlx_u(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    unsigned int ret = 0;

    if (SLOT(8, dir, song) != -1L) {
        HDAE5000_Lyrics_ClearBuffer();
        HDAE5000_TlxPart_Describe(10, (char *)&info);
        ret = HDAE5000_HD_ReadFile(info.addr, 0x16L, &SLOT(8, dir, song));
        if (ret != 0xffff) {
            HDAE5000_TlxPart_Describe(10, (char *)&info);
            ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(8, dir, song));
        }
    }
    return ret;
}
