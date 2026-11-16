/* hd_r27_b_uib.c (helper h_r27b, lane_hd round 27): HDAE5000_FlsItem_Insert (hdae5000_ui_display.s), a calr
   singleton, with named variants; the reasoning is hd_r27_b_uia.c's.  Run 102 (hd_r23_uib.c / uib2.c): the natural
   form matched except the destination of the four copies (ROM `lda xiz,(HDAE5000_RAM_FlsRecords+16:24); add
   xiz,xix`; V4.23 `lda xde,(..); ld xiz,xde; add xiz,xix`), and a local for the address took XIX, which moved the
   index temporaries.  The destination is pointer arithmetic here (run 70, DNA_s2: a pointer plus a long loads its
   base straight into the result register); the fields are separate externs ram_<hex> (HDAE5000_RAM_FlsRecords +
   16 / 48 / 80 / 112) so that no constant offset is folded into the index.
   - HDAE5000_FlsItem_Insert: destination `ram_X[index]`, source the integer form FLSB (which matched).
   - FlsIns_b: destination and source both `ram_X[index]`.
   - FlsIns_c: destination `*(ram_X + index)`, source FLSB.
   - FlsIns_d: destination `*(&HDAE5000_RAM_FlsRecords[16] + index)` (may fold the 16 into the index).
   The four clears after the loop keep the integer form, which matched.
   cc900-options: -Xr
   cc900-name: FlsIns_b=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_c=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_d=HDAE5000_FlsItem_Insert
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];
/* HDAE5000_RAM_FlsRecords + 16, + 48, + 80, + 112 */
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))

int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        ram_2257c2[IDX(fls, i)] = FLSB(16, fls, i - 1);
        ram_2257e2[IDX(fls, i)] = FLSB(48, fls, i - 1);
        ram_225802[IDX(fls, i)] = FLSB(80, fls, i - 1);
        ram_225822[IDX(fls, i)] = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_b(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        ram_2257c2[IDX(fls, i)] = ram_2257c2[IDX(fls, i - 1)];
        ram_2257e2[IDX(fls, i)] = ram_2257e2[IDX(fls, i - 1)];
        ram_225802[IDX(fls, i)] = ram_225802[IDX(fls, i - 1)];
        ram_225822[IDX(fls, i)] = ram_225822[IDX(fls, i - 1)];
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_c(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        *(ram_2257c2 + IDX(fls, i)) = FLSB(16, fls, i - 1);
        *(ram_2257e2 + IDX(fls, i)) = FLSB(48, fls, i - 1);
        *(ram_225802 + IDX(fls, i)) = FLSB(80, fls, i - 1);
        *(ram_225822 + IDX(fls, i)) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

int FlsIns_d(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = 31; i > item; i--) {
        *(&HDAE5000_RAM_FlsRecords[16] + IDX(fls, i)) = FLSB(16, fls, i - 1);
        *(&HDAE5000_RAM_FlsRecords[48] + IDX(fls, i)) = FLSB(48, fls, i - 1);
        *(&HDAE5000_RAM_FlsRecords[80] + IDX(fls, i)) = FLSB(80, fls, i - 1);
        *(&HDAE5000_RAM_FlsRecords[112] + IDX(fls, i)) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}
