/* hdae5000_v2_01i: FlsItem_Insert (hdae5000_ui_display.s), v2.06i's C of round 97 (2026-11-21); the same hand text and FLS records (0x2257b2) in this tree
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r97_fi.c.
   cc900-options: -Xr
   cc900-name: FlsIns_x=HDAE5000_FlsItem_Insert
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))

int FlsIns_x(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        { unsigned long a = FLSI(16, fls, i); *(unsigned char *)a = FLSB(16, fls, i - 1); }
        { unsigned long a = FLSI(48, fls, i); *(unsigned char *)a = FLSB(48, fls, i - 1); }
        { unsigned long a = FLSI(80, fls, i); *(unsigned char *)a = FLSB(80, fls, i - 1); }
        { unsigned long a = FLSI(112, fls, i); *(unsigned char *)a = FLSB(112, fls, i - 1); }
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
