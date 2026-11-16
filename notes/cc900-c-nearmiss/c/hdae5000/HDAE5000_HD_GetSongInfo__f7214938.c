/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_module.c (2026-11-16-105-hd-r23b)
   sha256 f721493898ffe347f63ad95ec5c545423ef33b04332f244f5af5436afc2e1b69 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern unsigned char HDAE5000_RAM_DirNames[];
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *info)
{
    unsigned int ret;

    if ((ret = HDAE5000_Song_PartMask(dir, song)) != 0xffff) {
        info->mask = ret;
        HDAE5000_MemCopy(info->dirname, &HDAE5000_RAM_DirNames[(unsigned long)dir * 16], 16);
        HDAE5000_MemCopy(info->songname, &HDAE5000_RAM_DirNames[SONG_OFS(dir, song)], 26);
        HDAE5000_MemCopy(info->has, &HAS(0, dir, song), 10);
        ret = 0;
    }
    return ret;
}
