/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_song_check.c (2026-11-16-78-hd-r15-ports)
   sha256 e94908fb5497b8fe9ecc663e19efb5a1a1c6f5c1dbadcc6f20b4106758ff9b20 (tar-sha256); compiled at -Xr
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
