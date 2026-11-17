/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_uib.c (2026-11-16-119-hd-r30)
   sha256 a345e4d22274b28ab72626b1bd30a3d37804e55c811dca63128eae278e3734cf (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        ram_2257c2[IDX(fls, i)] = FLSB(16, fls, i - 1);
        ram_2257e2[IDX(fls, i)] = FLSB(48, fls, i - 1);
        ram_225802[IDX(fls, i)] = FLSB(80, fls, i - 1);
        ram_225822[IDX(fls, i)] = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
