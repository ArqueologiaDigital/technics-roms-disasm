/* hd_r23_uia.c (helper h_nm3b, lane_hd round 23): HDAE5000_FlsItem_Remove (hdae5000_ui_display.s), a calr
   singleton; round 20's hd_r20_uia.c with one change.  Run 95 matched everything except the four copies in the
   loop: the ROM loads the destination's base straight into the register that holds it across the source's
   evaluation, `lda xiy,(HDAE5000_RAM_FlsRecords+16:24); add xiy,xhl`, where V4.23 loaded it into a scratch and
   copied it, `lda xbc,(..); ld xiy,xbc; add xiy,xhl` (the same copy the ROM itself has in FlsItem_SetAutoStart,
   where the address is a plain `*(T *)(integer) = v`).  Here the destination address goes through a pointer local
   first, `p = (unsigned char *)(...); *p = FLSB(...)`, so that the sum is evaluated into p's register.
   cc900-options: -Xr
*/
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
