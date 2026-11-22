/* hd_r97_fi.c (lane_hd round 97, 2026-11-21, UNRUN: written while the VM was blocked): HDAE5000_FlsItem_Insert
   (hdae5000_ui_display.s, 384 B), three forms.
   cc900-options: -Xr
   cc900-name: FlsIns_x=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_y=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_z=HDAE5000_FlsItem_Insert
   ROM: i in IY, each copy's destination in XIZ (pushed), the record offsets built in XIX.  Function-scope locals
   (rounds 36-52): (i, a) gives i IY, a XIX; (a, i) a XIY, i IX; a third local moves everything.  New idea: the
   destination is a local of the loop BODY's blocks, one per copy, so its live range is a single statement pair
   and V4.23 may pick it after the temporaries it needs (XIX) are reserved:
     FlsIns_x  { unsigned long a = FLSI(..); *(unsigned char *)a = FLSB(..); } four blocks
     FlsIns_y  the same with `unsigned char *a`
     FlsIns_z  as x, `register unsigned long a`
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

int FlsIns_y(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        { unsigned char *a = (unsigned char *)FLSI(16, fls, i); *a = FLSB(16, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(48, fls, i); *a = FLSB(48, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(80, fls, i); *a = FLSB(80, fls, i - 1); }
        { unsigned char *a = (unsigned char *)FLSI(112, fls, i); *a = FLSB(112, fls, i - 1); }
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_z(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        { register unsigned long a = FLSI(16, fls, i); *(unsigned char *)a = FLSB(16, fls, i - 1); }
        { register unsigned long a = FLSI(48, fls, i); *(unsigned char *)a = FLSB(48, fls, i - 1); }
        { register unsigned long a = FLSI(80, fls, i); *(unsigned char *)a = FLSB(80, fls, i - 1); }
        { register unsigned long a = FLSI(112, fls, i); *(unsigned char *)a = FLSB(112, fls, i - 1); }
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
