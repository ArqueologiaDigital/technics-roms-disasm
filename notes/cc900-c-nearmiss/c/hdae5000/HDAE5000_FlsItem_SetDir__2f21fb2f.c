/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_fls_small.c (2026-11-18-26-hd-r56-ports)
   sha256 2f21fb2fbd9da944370fff660f77c16abdd46a929d52b43872efd1c6dc487e25 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_SetDir(unsigned int fls, unsigned int item, unsigned int dir)
{
    FLSB(16, fls, item) = dir + 1;
    return 0;
}
