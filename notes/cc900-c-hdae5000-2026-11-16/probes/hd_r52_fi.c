/* hd_r52_fi.c (lane_hd round 52): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s, 384 B), four forms.
   cc900-options: -Xr
   cc900-name: FlsIns_s=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_t=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_w=HDAE5000_FlsItem_Insert

   ROM: i in IY, the destination a in XIZ, the record offsets built in XIX, HL / DE as temporaries.
   Seen so far: (a, i) -> a XIY, i IX (run 36's Remove form); (i, a) -> i IY, a XIX (FlsIns_j, run hd-r41: right
   but for a, and the offsets then move out of XIX); an unused third local takes no register (run hd-r50); an offset
   local o (i, o, a or i, a, o; run hd-r51) -> i HL, o XIZ, a XIX, 384 B as the ROM but every register different.
   These keep j's (i, a) and change only a's kind:
     HDAE5000_FlsItem_Insert  a an `unsigned char *` (the stores through a, no cast)
     FlsIns_s                 `register unsigned long a;`
     FlsIns_t                 `register` on both
     FlsIns_w                 a an `unsigned char *`, declared `register`
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned char *a;
    for (i = 31; i > item; i--) {
        a = (unsigned char *)FLSI(16, fls, i);
        *a = FLSB(16, fls, i - 1);
        a = (unsigned char *)FLSI(48, fls, i);
        *a = FLSB(48, fls, i - 1);
        a = (unsigned char *)FLSI(80, fls, i);
        *a = FLSB(80, fls, i - 1);
        a = (unsigned char *)FLSI(112, fls, i);
        *a = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_s(unsigned int fls, unsigned int item)
{
    unsigned int i;
    register unsigned long a;
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

int FlsIns_t(unsigned int fls, unsigned int item)
{
    register unsigned int i;
    register unsigned long a;
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

int FlsIns_w(unsigned int fls, unsigned int item)
{
    unsigned int i;
    register unsigned char *a;
    for (i = 31; i > item; i--) {
        a = (unsigned char *)FLSI(16, fls, i);
        *a = FLSB(16, fls, i - 1);
        a = (unsigned char *)FLSI(48, fls, i);
        *a = FLSB(48, fls, i - 1);
        a = (unsigned char *)FLSI(80, fls, i);
        *a = FLSB(80, fls, i - 1);
        a = (unsigned char *)FLSI(112, fls, i);
        *a = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
