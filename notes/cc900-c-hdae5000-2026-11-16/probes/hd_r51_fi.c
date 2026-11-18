/* hd_r51_fi.c (lane_hd round 51): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s, 384 B), three forms.
   cc900-options: -Xr
   cc900-name: FlsIns_q=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_r=HDAE5000_FlsItem_Insert

   Run 2026-11-18-4-hd-r50 (hd_r50_fi.c): an unused local between i and a takes no register; a stays in XIX.
   Reading the ROM again: the record offset fls * 144 + i is BUILT IN XIX (`ld xix,xde; sll; add; sll; add xix,xhl`),
   the destination is `lda xiz,base; add xiz,xix`, and the source offset is built in XIX again before
   `lda xde,base; add xde,xix`.  So the offset is a register local too, o in XIX, assigned twice per field, and
   a, the destination, the third register local (XIZ):
     HDAE5000_FlsItem_Insert  declared i, o, a;  o = IDX(i); a = base + o; o = IDX(i - 1); *a = *(base + o);
     FlsIns_q                 the same, declared i, a, o;
     FlsIns_r                 no a: o = IDX(i); then the store through base + o, its source through FLSB(i - 1).
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
#define BASE(o) ((unsigned long)&HDAE5000_RAM_FlsRecords[o])

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long o;
    unsigned long a;
    for (i = 31; i > item; i--) {
        o = IDX(fls, i);
        a = BASE(16) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(16) + o);
        o = IDX(fls, i);
        a = BASE(48) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(48) + o);
        o = IDX(fls, i);
        a = BASE(80) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(80) + o);
        o = IDX(fls, i);
        a = BASE(112) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(112) + o);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_q(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long a;
    unsigned long o;
    for (i = 31; i > item; i--) {
        o = IDX(fls, i);
        a = BASE(16) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(16) + o);
        o = IDX(fls, i);
        a = BASE(48) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(48) + o);
        o = IDX(fls, i);
        a = BASE(80) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(80) + o);
        o = IDX(fls, i);
        a = BASE(112) + o;
        o = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(BASE(112) + o);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_r(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long o;
    for (i = 31; i > item; i--) {
        o = IDX(fls, i);
        *(unsigned char *)(BASE(16) + o) = FLSB(16, fls, i - 1);
        o = IDX(fls, i);
        *(unsigned char *)(BASE(48) + o) = FLSB(48, fls, i - 1);
        o = IDX(fls, i);
        *(unsigned char *)(BASE(80) + o) = FLSB(80, fls, i - 1);
        o = IDX(fls, i);
        *(unsigned char *)(BASE(112) + o) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
