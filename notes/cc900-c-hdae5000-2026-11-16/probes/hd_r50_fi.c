/* hd_r50_fi.c (lane_hd round 50): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s, 384 B), three forms.
   cc900-options: -Xr
   cc900-name: FlsIns_u=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_v=HDAE5000_FlsItem_Insert

   Read-out of run 2026-11-17-12-hd-r41 (hd_r39_m2b.c, selectlist/cmp.py with the label):
   - the ROM: i in IY, the destination local a in XIZ, the index products in XIX;
   - Remove's form (a declared before i): a in XIY, i in IX;  FlsIns_j (i before a): i in IY, a in XIX, and the
     product moves out of XIX to make room.  So the FIRST declared register local got IY, the SECOND IX: a has to
     be the THIRD, which should take XIZ.
   The forms put an unused local between i and a (no code of its own, if V4.23 gives it a register anyway):
     HDAE5000_FlsItem_Insert  unsigned long z;      FlsIns_u  unsigned int z;      FlsIns_v  unsigned char *z;
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long z;
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

int FlsIns_u(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned int z;
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

int FlsIns_v(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned char *z;
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
