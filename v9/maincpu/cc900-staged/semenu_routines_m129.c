/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_IsPartEnabled SeMenu_LoadMasterPtr SeMenu_LoadPartParam SeMenu_SetCurrentPart SeMenu_SetObjectFlags SeMenu_SetupMenuDisplay SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetCurrentPart(int);
extern void SeMenu_SetupMenuDisplay(int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SelectPartAndRedraw(unsigned char, unsigned char, unsigned char);
extern void SeMenu_SelectPartAndRedraw(unsigned char field, unsigned char part, unsigned char check);

void SeMenu_SelectPartAndRedraw(unsigned char field, unsigned char part, unsigned char check)
{
    unsigned char cur;

    SeMenu_LoadPartParam(0, &cur);
    if (part == cur)
        return;
    if (check == 1 && SeMenu_IsPartEnabled(part) == 0)
        return;
    SeMenu_SetCurrentPart(part);
    SeMenu_StorePartParam(0, part);
    SeTitle_DrawField(field, 0);
    SeMenu_SetupMenuDisplay(1);
}
