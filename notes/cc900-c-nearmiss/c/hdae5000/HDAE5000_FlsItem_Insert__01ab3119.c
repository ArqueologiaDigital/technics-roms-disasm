/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r36_fix3.c (2026-11-17-3-hd-r36)
   sha256 01ab3119b3883377faebbd827efc7f04c7114235d596207fba1dbfa330a07e30 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define DSTP(o, f, i) (*((unsigned char *)(unsigned long)&HDAE5000_RAM_FlsRecords[o] + IDX(f, i)))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        DSTP(16, fls, i) = FLSB(16, fls, i - 1);
        DSTP(48, fls, i) = FLSB(48, fls, i - 1);
        DSTP(80, fls, i) = FLSB(80, fls, i - 1);
        DSTP(112, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
