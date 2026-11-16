/* hd_r20_uia.c (helper h_ui, lane_hd round 20): HDAE5000_FlsItem_Remove (hdae5000_ui_display.s), a calr
   singleton.  FLS record fields as in cc900/hdae5000_flsitem.c: four 32-byte item columns at +16/+48/+80/+112
   of a 144-byte record; the integer-address idiom gives lda xR,(HDAE5000_RAM_FlsRecords+N) after the index.
   The four clears of item 31 index from HDAE5000_RAM_DirNames + 0x24180 (= HDAE5000_RAM_FlsRecords).
   cc900-options: -Xr
*/
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))

int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        FLSB(16, fls, i - 1) = FLSB(16, fls, i);
        FLSB(48, fls, i - 1) = FLSB(48, fls, i);
        FLSB(80, fls, i - 1) = FLSB(80, fls, i);
        FLSB(112, fls, i - 1) = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}
