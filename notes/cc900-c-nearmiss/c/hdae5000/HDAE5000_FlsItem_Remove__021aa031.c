/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r23_uia.c (2026-11-16-102-hd-r23a)
   sha256 021aa0311d85ff3931c7c4033404ac8454610e7a25914c54cab596402589bbb4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSA(o, f, i) ((unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned char *p;
    for (i = item + 1; i < 32; i++) {
        p = FLSA(16, fls, i - 1);
        *p = FLSB(16, fls, i);
        p = FLSA(48, fls, i - 1);
        *p = FLSB(48, fls, i);
        p = FLSA(80, fls, i - 1);
        *p = FLSB(80, fls, i);
        p = FLSA(112, fls, i - 1);
        *p = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}
