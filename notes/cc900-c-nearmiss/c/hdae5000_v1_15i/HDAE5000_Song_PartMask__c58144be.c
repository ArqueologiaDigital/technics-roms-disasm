/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_song_module__partmask_r72.c (2026-11-19-61-hd-r73-staged)
   sha256 c58144be7f97dc01e24299953d0e23d63a117d3853e102055869f69bf4809896 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern unsigned char HDAE5000_RAM_DirNames[];
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song)
{
    unsigned int mask;

    mask = 0;
    if (HDAE5000_Song_IsUsed(dir, song) != -1) {
        if (SLOT(0, dir, song) != -1L) mask |= 0x001;
        if (SLOT(1, dir, song) != -1L) mask |= 0x002;
        if (SLOT(2, dir, song) != -1L) mask |= 0x004;
        if (SLOT(3, dir, song) != -1L) mask |= 0x008;
        if (SLOT(4, dir, song) != -1L) mask |= 0x010;
        if (SLOT(5, dir, song) != -1L) mask |= 0x020;
        if (SLOT(6, dir, song) != -1L) mask |= 0x040;
        if (SLOT(7, dir, song) != -1L) mask |= 0x080;
    } else
        mask = 0xffff;
    return mask;
}
