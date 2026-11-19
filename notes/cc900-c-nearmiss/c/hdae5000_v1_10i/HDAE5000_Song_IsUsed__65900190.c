/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_check.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 65900190886c91dcc38e03a2832dd16d9f19e9995ccb5ec56129f74e5fce99ec (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song)
{
    if (SLOT(0, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(1, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(2, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(3, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(4, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(5, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(6, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(7, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(8, dir, song) != 0xffffffffUL) return 0;
    return -1;
}
