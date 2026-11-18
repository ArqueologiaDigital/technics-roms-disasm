/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fls_small.c (2026-11-18-24-hd-r56)
   sha256 8e6a821fa4639e31727455fa0fbbea86b8941dad1aceeb2e120f3a022c6ec78a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_SetSong(unsigned int fls, unsigned int item, unsigned int song)
{
    FLSB(48, fls, item) = song + 1;
    return 0;
}
