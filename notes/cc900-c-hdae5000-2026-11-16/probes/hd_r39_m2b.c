/* hd_r39_m2b.c (helper h_m2, lane_hd round 39): four FLS item functions of hdae5000_ui_display.s, in ROM address
   order: HDAE5000_FlsItem_SongRecord, HDAE5000_FlsItem_Get, HDAE5000_FlsItem_Insert, HDAE5000_FlsItem_Set, each
   with variants.  HDAE5000_FlsItem_IsSet and HDAE5000_HD_StoreTables (the ROM's calr targets) are built from
   hdae5000/cc900/: declared here, the calr by the module line.
   cc900-options: -Xr
   cc900-module: HDAE5000_FlsItem_IsSet HDAE5000_HD_StoreTables
   cc900-name: SongRec_t=HDAE5000_FlsItem_SongRecord
   cc900-name: SongRec_b=HDAE5000_FlsItem_SongRecord
   cc900-name: SongRec_s=HDAE5000_FlsItem_SongRecord
   cc900-name: SongRec_k=HDAE5000_FlsItem_SongRecord
   cc900-name: FlsGet_f=HDAE5000_FlsItem_Get
   cc900-name: FlsGet_i=HDAE5000_FlsItem_Get
   cc900-name: FlsGet_e=HDAE5000_FlsItem_Get
   cc900-name: FlsGet_n=HDAE5000_FlsItem_Get
   cc900-name: FlsIns_j=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_p=HDAE5000_FlsItem_Insert
   cc900-name: FlsIns_n=HDAE5000_FlsItem_Insert
   cc900-name: FlsSet_i=HDAE5000_FlsItem_Set
   cc900-name: FlsSet_v=HDAE5000_FlsItem_Set
   cc900-name: FlsSet_w=HDAE5000_FlsItem_Set
   cc900-name: FlsSet_c=HDAE5000_FlsItem_Set

   What the earlier runs showed (57, 66, 83, 119 and 2026-11-17-3-hd-r36), function by function.

   SongRecord, Get: the bodies were the ROM's; what differed is WHICH value gets IZ, the only register that
   survives the call to IsSet.  The ROM: item in IZ, fls in a stack word (and in SongRecord the song offset in a
   second stack word, +2).  V4.23 gave IZ to fls or to item from one spelling of the IsSet test to the next
   (`register` and a K&R declaration order changed nothing, run 83), and in SongRecord to the local sofs before
   either parameter.  Seen: Get block form, unsigned r assigned in the test (the ROM's `ld wa,hl; cp wa,0xffff`):
   fls; the same with int r (`cp hl,0xffff`): item; SetAutoStart early-return form: the reverse (and matched).
   So these forms each change ONE thing that may decide it, and no code:
   - an address-of that is thrown away, `(void)&fls;`: a variable whose address is taken cannot be in a register;
   - a reference that is thrown away, `(void)fls;` / `(void)item;` / `(void)sofs;`, written last: one more use, and
     a later last use, of that variable;
   - sofs declared in the inner block;
   - Get in SetAutoStart's early-return form; Get without r (the call's result converted in the test).
   SongRecord also returns the address CONVERTED, (void *)(base + sum): the ROM loads the table base as an
   immediate after the index (run 70's idiom); run 83's plain pointer gave lda.

   Insert (run 36: +7, one difference four times): the destination address.  The ROM loads the base with lda
   straight into XIZ and adds the index; V4.23 loaded it into XDE and copied it for every expression spelling.
   The matched HDAE5000_FlsItem_Remove (hdae5000/cc900/hdae5000_flsitem_remove.c) has the same code shape and got
   it from an integer local assigned first, `a = FLSI(o, f, i - 1); *(unsigned char *)a = FLSB(o, f, i);`, with
   `unsigned long a` declared BEFORE i.  Run 36's FlsIns_e had three locals (i, x, a) and got other registers.
   - HDAE5000_FlsItem_Insert: Remove's form (a, then i);
   - FlsIns_j: i declared before a;
   - FlsIns_p: a as a pointer local;
   - FlsIns_n: the assignment inside the statement, *(unsigned char *)(a = ...) = ...

   Set (runs 57-83: different from +0): the ROM moves fls out of WA at entry (`ld hl,wa`), keeps item in BC and
   uses WA / A for the values; V4.23 moved item (`ld hl,bc`) and used BC.  The brief's rule for a parameter
   copied at entry is a local copy:
   - HDAE5000_FlsItem_Set: `unsigned int f; f = fls;` and f in the four stores;
   - FlsSet_i: the copy as an initialiser;
   - FlsSet_v: no copy, `(void)fls;` after the last store;  FlsSet_w: `(void)item;` there (the control);
   - FlsSet_c: no copy, fls named last in the last store through a comma expression.
*/
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_FlsItem_SongRecord_Str_Blank26[];

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define IDX(f, i) ((unsigned long)(f) * 144 + (i))
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
#define FLSI(o, f, i) ((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i)))
/* the song record of the item's directory byte, as an offset into the tables */
#define DIRPART(f, i) ((unsigned long)(unsigned char)(FLSB(16, f, i) - 1) * 0x4c0 + 0x780)

/* ---- this module (calr) ---- */
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
int HDAE5000_HD_StoreTables(int keep);

/* ---- HDAE5000_FlsItem_SongRecord ------------------------------------------------------------------------- */

/* the addresses of sofs and fls taken and thrown away */
unsigned char *HDAE5000_FlsItem_SongRecord(unsigned int fls, unsigned int item)
{
    int r;
    int sofs;
    (void)&sofs;
    (void)&fls;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}

/* fls and sofs named last (after the returns; no code) */
unsigned char *SongRec_t(unsigned int fls, unsigned int item)
{
    int r;
    int sofs;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
    (void)fls;
    (void)sofs;
}

/* sofs declared in the inner block */
unsigned char *SongRec_b(unsigned int fls, unsigned int item)
{
    int r;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        int sofs;
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}

/* only the address of sofs taken */
unsigned char *SongRec_s(unsigned int fls, unsigned int item)
{
    int r;
    int sofs;
    (void)&sofs;
    r = HDAE5000_FlsItem_IsSet(fls, item);
    if (r != -1) {
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}

/* sofs in the inner block, the address of fls taken, the call tested directly (no r) */
unsigned char *SongRec_k(unsigned int fls, unsigned int item)
{
    (void)&fls;
    if (HDAE5000_FlsItem_IsSet(fls, item) != -1) {
        int sofs;
        sofs = (int)(FLSB(48, fls, item) - 1) * 76;
        return (void *)(HDAE5000_RAM_DirNames + ((long)sofs + DIRPART(fls, item)));
    } else
        return HDAE5000_FlsItem_SongRecord_Str_Blank26;
}

/* ---- HDAE5000_FlsItem_Get -------------------------------------------------------------------------------- */

/* run 83's form (unsigned r assigned in the test) with the address of fls taken and thrown away */
void HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    (void)&fls;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

/* fls named last */
void FlsGet_f(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
    (void)fls;
}

/* item named last */
void FlsGet_i(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
    (void)item;
}

/* the early-return form of the matched FlsItemSetAS_u (hdae5000/cc900/hdae5000_flsitem_set.c) */
void FlsGet_e(unsigned int fls, register unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) == 0xffff)
        return;
    out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
    out->song = (unsigned char)(FLSB(48, fls, item) - 1);
    out->as = FLSB(80, fls, item);
    out->al = FLSB(112, fls, item);
}

/* no local: the call's result converted in the test */
void FlsGet_n(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    if ((unsigned int)HDAE5000_FlsItem_IsSet(fls, item) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}

/* ---- HDAE5000_FlsItem_Insert ----------------------------------------------------------------------------- */

/* the matched FlsItem_Remove's form: the destination in an integer local declared before i */
int HDAE5000_FlsItem_Insert(unsigned int fls, unsigned int item)
{
    unsigned long a;
    unsigned int i;
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

/* i declared before a */
int FlsIns_j(unsigned int fls, unsigned int item)
{
    unsigned int i;
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

/* the destination in a pointer local */
int FlsIns_p(unsigned int fls, unsigned int item)
{
    unsigned char *a;
    unsigned int i;
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

/* the assignment to the local inside the store */
int FlsIns_n(unsigned int fls, unsigned int item)
{
    unsigned long a;
    unsigned int i;
    for (i = 31; i > item; i--) {
        *(unsigned char *)(a = FLSI(16, fls, i)) = FLSB(16, fls, i - 1);
        *(unsigned char *)(a = FLSI(48, fls, i)) = FLSB(48, fls, i - 1);
        *(unsigned char *)(a = FLSI(80, fls, i)) = FLSB(80, fls, i - 1);
        *(unsigned char *)(a = FLSI(112, fls, i)) = FLSB(112, fls, i - 1);
    }
    FLSB(16, fls, item) = 0;
    FLSB(48, fls, item) = 0;
    FLSB(80, fls, item) = 0;
    FLSB(112, fls, item) = 0;
    return 0;
}

/* ---- HDAE5000_FlsItem_Set -------------------------------------------------------------------------------- */

/* a local copy of fls */
int HDAE5000_FlsItem_Set(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    unsigned int f;
    f = fls;
    FLSB(16, f, item) = src->dir + 1;
    FLSB(48, f, item) = src->song + 1;
    FLSB(80, f, item) = src->as;
    FLSB(112, f, item) = src->al;
    return HDAE5000_HD_StoreTables(keep);
}

/* the copy as an initialiser */
int FlsSet_i(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    unsigned int f = fls;
    FLSB(16, f, item) = src->dir + 1;
    FLSB(48, f, item) = src->song + 1;
    FLSB(80, f, item) = src->as;
    FLSB(112, f, item) = src->al;
    return HDAE5000_HD_StoreTables(keep);
}

/* no copy; fls named after the last store */
int FlsSet_v(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = src->al;
    (void)fls;
    return HDAE5000_HD_StoreTables(keep);
}

/* no copy; item named after the last store (the control for FlsSet_v) */
int FlsSet_w(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = src->al;
    (void)item;
    return HDAE5000_HD_StoreTables(keep);
}

/* no copy; fls named last in the last store, through a comma expression */
int FlsSet_c(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = (fls, src->al);
    return HDAE5000_HD_StoreTables(keep);
}
