/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_uia.c (2026-11-16-119-hd-r30)
   sha256 7f36aaf9e8c1a4565dcb749e08b033e1fb1702b4c27b8f3ead99cf1b3edf3e5f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        ram_2257c2[IDX(fls, i - 1)] = FLSB(16, fls, i);
        ram_2257e2[IDX(fls, i - 1)] = FLSB(48, fls, i);
        ram_225802[IDX(fls, i - 1)] = FLSB(80, fls, i);
        ram_225822[IDX(fls, i - 1)] = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}
