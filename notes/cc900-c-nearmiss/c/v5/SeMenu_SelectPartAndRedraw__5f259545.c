/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/semenu_routines_m129.c (2026-11-22-24-p6-r91)
   sha256 5f259545659cd8177218d89014ab039fb46882b020e201c2344699be1f013238 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetCurrentPart(int);
extern void SeMenu_SetupMenuDisplay(int);
extern void __cdecl SeTitle_DrawField(int, int);
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
