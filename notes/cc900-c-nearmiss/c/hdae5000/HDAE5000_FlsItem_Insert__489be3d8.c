/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r23_uib2.c (2026-11-16-102-hd-r23a)
   sha256 489be3d86ef49ebbdbdab33d679db372396d86089aaa4999366bc96817f5151b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long a;
    for (i = 31; i > item; i--) {
        a = FLSI(16, fls, i);
        *(unsigned char *)a = FLSB(16, fls, i - 1);
        a = FLSI(48, fls, i);
        *(unsigned char *)a = FLSB(48, fls, i - 1);
        a = FLSI(80, fls, i);
        *(unsigned char *)a = FLSB(80, fls, i - 1);
        a = FLSI(112, fls, i);
        *(unsigned char *)a = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
