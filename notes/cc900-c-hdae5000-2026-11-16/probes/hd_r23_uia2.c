/* hd_r23_uia2.c (helper h_nm3b, lane_hd round 23): second form of hd_r23_uia.c (HDAE5000_FlsItem_Remove).  The
   destination address goes through an INTEGER local, `a = (unsigned long)&FlsRecords[o] + index;
   *(unsigned char *)a = FLSB(...)`, instead of a pointer local; the aim is the same, the ROM's
   `lda xiy,(HDAE5000_RAM_FlsRecords+16:24); add xiy,xhl` with no scratch copy.
   cc900-options: -Xr
*/
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
