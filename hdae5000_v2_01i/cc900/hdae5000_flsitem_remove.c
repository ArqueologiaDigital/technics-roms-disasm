/* Functions of hdae5000_ui_display.s.  (hdae5000_flsitem_remove.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_flsitem_remove.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: FlsRm_e=HDAE5000_FlsItem_Remove
*/
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
/* HDAE5000_RAM_FlsRecords + 16, + 48, + 80, + 112 */
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))

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
