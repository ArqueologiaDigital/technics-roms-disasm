/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r20_uib.c (2026-11-16-95-hd-r20)
   sha256 9d986575c7cb5e60f0fd6dc8ac0e25620d99ba691793d8daced76011fbb8a302 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        FLSB(16, fls, i) = FLSB(16, fls, i - 1);
        FLSB(48, fls, i) = FLSB(48, fls, i - 1);
        FLSB(80, fls, i) = FLSB(80, fls, i - 1);
        FLSB(112, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
