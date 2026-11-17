/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_flsitem.c (2026-11-16-63-hd-r9s-staged)
   sha256 6cb15bd13ce8a62b10fadf79e86ed6d036c10aa99f5c65d4ea411f19005f9e7f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item)
{
    int r = 0;
    if (FLSB(16, fls, item) == 0 || FLSB(48, fls, item) == 0)
        r = -1;
    return r;
}
