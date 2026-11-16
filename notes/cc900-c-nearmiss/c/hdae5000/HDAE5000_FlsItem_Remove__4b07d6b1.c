/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r20_uia.c (2026-11-16-95-hd-r20)
   sha256 4b07d6b18cce7780fd35d28410525e28d3db1db51e14a0f903514cb6988e4d67 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        FLSB(16, fls, i - 1) = FLSB(16, fls, i);
        FLSB(48, fls, i - 1) = FLSB(48, fls, i);
        FLSB(80, fls, i - 1) = FLSB(80, fls, i);
        FLSB(112, fls, i - 1) = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}
