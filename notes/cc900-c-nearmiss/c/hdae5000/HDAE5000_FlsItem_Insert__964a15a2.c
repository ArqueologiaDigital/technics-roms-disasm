/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r97_fi.c (2026-11-21-25-hd-r97)
   sha256 964a15a2fee996eacd0bd35f5da67427b578677926bfe139e8c12ef13839db7d (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FlsIns_y=HDAE5000_FlsItem_Insert */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
int FlsIns_y(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        { unsigned char *a = (unsigned char *)FLSI(16, fls, i); *a = FLSB(16, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(48, fls, i); *a = FLSB(48, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(80, fls, i); *a = FLSB(80, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(112, fls, i); *a = FLSB(112, fls, i - 1); }
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
