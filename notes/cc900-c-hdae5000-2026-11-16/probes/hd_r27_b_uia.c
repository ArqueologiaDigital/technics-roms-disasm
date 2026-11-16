/* hd_r27_b_uia.c (helper h_r27b, lane_hd round 27): HDAE5000_FlsItem_Remove (hdae5000_ui_display.s), a calr
   singleton, with named variants.  Run 102 (hd_r23_uia.c / uia2.c): everything matched except the destination of
   the four copies in the loop: the ROM loads the base straight into the register that survives the source's
   evaluation, `lda xiy,(HDAE5000_RAM_FlsRecords+16:24); add xiy,xhl`; V4.23 loaded a scratch and copied it for the
   integer address (`lda xbc,(..); ld xiy,xbc; add xiy,xhl`), and with a local for the address it swapped IX / IY.
   Run 70 (hd_r13_v.c) shows which sum loads its base directly: a POINTER plus a long (DNA_s2: `lda xhl,(sym); add
   xhl,xwa`), where the INTEGER sum (DNA_s1) copies (`lda xwa,(sym); ld xhl,xwa; add xhl,xbc`).  So the destination
   is written as pointer arithmetic here.  A pointer spelling folds a constant element offset into the index, so
   the four fields are separate externs ram_<hex> (HDAE5000_RAM_FlsRecords + 16 / 48 / 80 / 112).
   - HDAE5000_FlsItem_Remove: destination `ram_X[index]`, source the integer form FLSB (which matched).
   - FlsRm_b: destination and source both `ram_X[index]`.
   - FlsRm_c: destination `*(ram_X + index)`, source FLSB.
   - FlsRm_d: destination `*(&HDAE5000_RAM_FlsRecords[16] + index)` (may fold the 16 into the index).
   - FlsRm_e: hd_r23_uia2.c (integer local for the address) with the local declared BEFORE i (run 102 gave i IY
     and a XIX; the ROM has i in IX and the address in XIY).
   - FlsRm_f: as FlsRm_e with `register` on i.
   cc900-options: -Xr
   cc900-name: FlsRm_b=HDAE5000_FlsItem_Remove
   cc900-name: FlsRm_c=HDAE5000_FlsItem_Remove
   cc900-name: FlsRm_d=HDAE5000_FlsItem_Remove
   cc900-name: FlsRm_e=HDAE5000_FlsItem_Remove
   cc900-name: FlsRm_f=HDAE5000_FlsItem_Remove
*/
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
/* HDAE5000_RAM_FlsRecords + 16, + 48, + 80, + 112 */
extern unsigned char ram_2257c2[], ram_2257e2[], ram_225802[], ram_225822[];

#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
#define FLSD(o, f) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[o] + ((unsigned long)(f) * 144 + 0x24180L)))
#define IDX(f, i) ((unsigned long)(f) * 144 + (i))

int HDAE5000_FlsItem_Remove(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        ram_2257c2[IDX(fls, i - 1)] = FLSB(16, fls, i);
        ram_2257e2[IDX(fls, i - 1)] = FLSB(48, fls, i);
        ram_225802[IDX(fls, i - 1)] = FLSB(80, fls, i);
        ram_225822[IDX(fls, i - 1)] = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}

int FlsRm_b(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        ram_2257c2[IDX(fls, i - 1)] = ram_2257c2[IDX(fls, i)];
        ram_2257e2[IDX(fls, i - 1)] = ram_2257e2[IDX(fls, i)];
        ram_225802[IDX(fls, i - 1)] = ram_225802[IDX(fls, i)];
        ram_225822[IDX(fls, i - 1)] = ram_225822[IDX(fls, i)];
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}

int FlsRm_c(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        *(ram_2257c2 + IDX(fls, i - 1)) = FLSB(16, fls, i);
        *(ram_2257e2 + IDX(fls, i - 1)) = FLSB(48, fls, i);
        *(ram_225802 + IDX(fls, i - 1)) = FLSB(80, fls, i);
        *(ram_225822 + IDX(fls, i - 1)) = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}

int FlsRm_d(unsigned int fls, unsigned int item)
{
    unsigned int i;
    for (i = item + 1; i < 32; i++) {
        *(&HDAE5000_RAM_FlsRecords[16] + IDX(fls, i - 1)) = FLSB(16, fls, i);
        *(&HDAE5000_RAM_FlsRecords[48] + IDX(fls, i - 1)) = FLSB(48, fls, i);
        *(&HDAE5000_RAM_FlsRecords[80] + IDX(fls, i - 1)) = FLSB(80, fls, i);
        *(&HDAE5000_RAM_FlsRecords[112] + IDX(fls, i - 1)) = FLSB(112, fls, i);
    }
    FLSD(16 + 31, fls) = 0;
    FLSD(48 + 31, fls) = 0;
    FLSD(80 + 31, fls) = 0;
    FLSD(112 + 31, fls) = 0;
    return 0;
}

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

int FlsRm_f(unsigned int fls, unsigned int item)
{
    unsigned long a;
    register unsigned int i;
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
