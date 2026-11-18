/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r52_fi.c (2026-11-18-13-hd-r52)
   sha256 e8bee724045bab7564480569448d99020f1535c247eeb3162531538c77017eb0 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned char *a;
    for (i = 31; i > item; i--) {
        a = (unsigned char *)FLSI(16, fls, i);
        *a = FLSB(16, fls, i - 1);
        a = (unsigned char *)FLSI(48, fls, i);
        *a = FLSB(48, fls, i - 1);
        a = (unsigned char *)FLSI(80, fls, i);
        *a = FLSB(80, fls, i - 1);
        a = (unsigned char *)FLSI(112, fls, i);
        *a = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
