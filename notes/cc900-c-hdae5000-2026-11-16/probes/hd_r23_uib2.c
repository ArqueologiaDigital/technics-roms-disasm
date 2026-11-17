/* hd_r23_uib2.c (helper h_nm3b, lane_hd round 23): second form of hd_r23_uib.c (HDAE5000_FlsItem_Insert): the
   destination address goes through an INTEGER local, `a = (unsigned long)&FlsRecords[o] + index;
   *(unsigned char *)a = ...`, as hd_r23_uia2.c.
   cc900-options: -Xr
*/
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
