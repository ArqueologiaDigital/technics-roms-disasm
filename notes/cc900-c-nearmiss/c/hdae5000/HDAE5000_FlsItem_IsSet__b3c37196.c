/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_flsitem.c (2026-11-16-78-hd-r15-ports)
   sha256 b3c371965bf73c3a9351daf7b253be4c4f59b441caa48b9db92519eac745b9a0 (tar-sha256); compiled at -Xr
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
