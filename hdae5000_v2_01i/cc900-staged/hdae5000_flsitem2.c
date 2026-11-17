/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_flsitem2.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_flsitem2.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FlsItem_IsSet HDAE5000_HD_StoreTables
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

/* sofs declared in the inner block */

/* only the address of sofs taken */

/* sofs in the inner block, the address of fls taken, the call tested directly (no r) */

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

/* item named last */

/* the early-return form of the matched FlsItemSetAS_u (hdae5000/cc900/hdae5000_flsitem_set.c) */

/* no local: the call's result converted in the test */

/* ---- HDAE5000_FlsItem_Insert ----------------------------------------------------------------------------- */

/* the matched FlsItem_Remove's form: the destination in an integer local declared before i */

/* i declared before a */

/* the destination in a pointer local */

/* the assignment to the local inside the store */

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

/* no copy; fls named after the last store */

/* no copy; item named after the last store (the control for FlsSet_v) */

/* no copy; fls named last in the last store, through a comma expression */
