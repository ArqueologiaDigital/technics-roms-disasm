/* hd_r36_fix3.c (helper h_fix3, lane_hd round 36): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s), a calr
   singleton, with named variants.  Run 119 (hd_r27_b_uib.c, FlsIns_c) differs from the ROM in one thing only, four
   times: the destination address of each copy in the loop.  The ROM loads the base with `lda` straight into the
   register that survives the source's evaluation (XIZ) and adds the index (XIX); V4.23 gave an immediate `ld` for
   every pointer-plus-long destination (run 119), a scratch load plus a copy for the integer sum (run 102), and
   put an address local into XIX, which moved the index temporaries (run 102, hd_r23_uib2.c).  Everything else
   (the index temporaries, the sources, the four clears, the frame) is already the ROM's.
   - HDAE5000_FlsItem_Insert: destination = the integer address converted BACK to a pointer before the index is
     added, `*((unsigned char *)(unsigned long)&FlsRecords[o] + index)`: a converted base (so `lda`, not an
     immediate) that is the left operand of a pointer sum (run 70's DNA_s2 loads such a base straight into the
     result register).
   - FlsIns_e: locals in the order i, x, a: the index is a local (wanted in XIX, the second register variable),
     the destination an integer local (wanted in XIZ, the third); run 102 shows that an assignment to a register
     local loads the base straight into it.  The last clear is written inline because the ROM computes it without
     XIX.
   - FlsIns_f: as the first form, with the four fields as separate externs ram_<hex> (no element offset in the
     converted address).
   - FlsIns_g: the base converted through `void *` instead of an integer.
   The sources and the clears keep the integer form FLSB, which matched.
   cc900-options: -Xr
   cc900-name: FlsIns_e=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_f=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_g=HDAE5000_FlsItem_Insert
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];
/* HDAE5000_RAM_FlsRecords + 16, + 48, + 80, + 112 */
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];

#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
#define FLSI(o) ((unsigned long)&HDAE5000_RAM_FlsRecords[o])
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
/* destination forms */
#define DSTP(o, f, i) (*((unsigned char *)(unsigned long)&HDAE5000_RAM_FlsRecords[o] + IDX(f, i)))
#define DSTR(r, f, i) (*((unsigned char *)(unsigned long)(r) + IDX(f, i)))
#define DSTV(o, f, i) (*((unsigned char *)(void *)&HDAE5000_RAM_FlsRecords[o] + IDX(f, i)))

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        DSTP(16, fls, i) = FLSB(16, fls, i - 1);
        DSTP(48, fls, i) = FLSB(48, fls, i - 1);
        DSTP(80, fls, i) = FLSB(80, fls, i - 1);
        DSTP(112, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_e(unsigned int fls, unsigned int item)
{
    unsigned int i;
    unsigned long x;
    unsigned long a;
    for (i = 31; i > item; i--) {
        x = IDX(fls, i);
        a = FLSI(16) + x;
        x = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(FLSI(16) + x);
        x = IDX(fls, i);
        a = FLSI(48) + x;
        x = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(FLSI(48) + x);
        x = IDX(fls, i);
        a = FLSI(80) + x;
        x = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(FLSI(80) + x);
        x = IDX(fls, i);
        a = FLSI(112) + x;
        x = IDX(fls, i - 1);
        *(unsigned char *)a = *(unsigned char *)(FLSI(112) + x);
    }
    x = IDX(fls, item);
    *(unsigned char *)(FLSI(16) + x) = 0;
    x = IDX(fls, item);
    *(unsigned char *)(FLSI(48) + x) = 0;
    x = IDX(fls, item);
    *(unsigned char *)(FLSI(80) + x) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_f(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        DSTR(ram_2257c2, fls, i) = FLSB(16, fls, i - 1);
        DSTR(ram_2257e2, fls, i) = FLSB(48, fls, i - 1);
        DSTR(ram_225802, fls, i) = FLSB(80, fls, i - 1);
        DSTR(ram_225822, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_g(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        DSTV(16, fls, i) = FLSB(16, fls, i - 1);
        DSTV(48, fls, i) = FLSB(48, fls, i - 1);
        DSTV(80, fls, i) = FLSB(80, fls, i - 1);
        DSTV(112, fls, i) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
