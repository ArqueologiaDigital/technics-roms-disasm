/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r23_uia2.c (2026-11-16-102-hd-r23a)
   sha256 487d1d8e1c32c2f08adfd7d434bfaa5822f2273fe97d67362af292c3902e2732 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long a;
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
