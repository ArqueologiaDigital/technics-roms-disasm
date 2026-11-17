/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_flsitem_remove.c (2026-11-16-121-hd-r32-staged)
   sha256 0fb88081a23db1ca55bf5a37d8088b17b8daa3988778c25a0028dc9f02191d30 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: FlsRm_e=HDAE5000_FlsItem_Remove */
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
int FlsRm_e(unsigned int fls, unsigned int item)
{
    unsigned long a;
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        a = FLSI(16, fls, i - 1);
        *(unsigned char *)a = FLSB(16, fls, i);
        a = FLSI(48, fls, i - 1);
        *(unsigned char *)a = FLSB(48, fls, i);
        a = FLSI(80, fls, i - 1);
        *(unsigned char *)a = FLSB(80, fls, i);
        a = FLSI(112, fls, i - 1);
        *(unsigned char *)a = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}
