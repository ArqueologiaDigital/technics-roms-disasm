/* hd_r23_uib.c (helper h_nm3b, lane_hd round 23): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s), a calr
   singleton; round 20's hd_r20_uib.c with one change, the one of hd_r23_uia.c.  Run 95 matched everything except
   the four copies in the loop, where the ROM loads the destination base straight into XIZ,
   `lda xiz,(HDAE5000_RAM_FlsRecords+16:24); add xiz,xix`, and V4.23 went through a scratch,
   `lda xde,(..); ld xiz,xde`.  Here the destination address goes through a pointer local first.
   cc900-options: -Xr
*/
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
