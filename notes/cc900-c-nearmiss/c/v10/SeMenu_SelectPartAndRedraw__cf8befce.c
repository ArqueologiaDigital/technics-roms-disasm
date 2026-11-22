/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m129a.c (2026-11-22-23-p6-r90)
   sha256 cf8befce8e9bb8e2c6500ac12d4f88083ef8f9f0fc9353590141e1660cb78bbe (tar-sha256); compiled at -Xr */
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
