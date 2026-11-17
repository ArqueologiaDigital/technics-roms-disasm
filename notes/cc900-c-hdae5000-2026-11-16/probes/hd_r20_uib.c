/* hd_r20_uib.c (helper h_ui, lane_hd round 20): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s), a calr
   singleton.  Opens a gap at item `item` of FLS record `fls`: items item..30 move up one, item `item` is zeroed.
   FLS record fields as in cc900/hdae5000_flsitem.c (integer-address idiom).
   cc900-options: -Xr
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        FLSB(16, fls, i) = FLSB(16, fls, i - 1);
        FLSB(48, fls, i) = FLSB(48, fls, i - 1);
        FLSB(80, fls, i) = FLSB(80, fls, i - 1);
        FLSB(112, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
