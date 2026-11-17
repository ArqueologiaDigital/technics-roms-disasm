/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r23_uib.c (2026-11-16-102-hd-r23a)
   sha256 5545da64936b348b9843e4225abfbc5a3267962c0dd452321c9044b647393fcd (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSA(o, f, i) ((unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned char *p;
    for (i = 31; i > item; i--) {
        p = FLSA(16, fls, i);
        *p = FLSB(16, fls, i - 1);
        p = FLSA(48, fls, i);
        *p = FLSB(48, fls, i - 1);
        p = FLSA(80, fls, i);
        *p = FLSB(80, fls, i - 1);
        p = FLSA(112, fls, i);
        *p = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
