/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13_ng1.c (2026-11-16-83-hd-r16)
   sha256 a5d4ae1c14d5ea1f308e2aeb68987bb95ca7eeb34e86923f7f85bbd37f803592 (tar-sha256); compiled at -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = -1;
    return r;
}
