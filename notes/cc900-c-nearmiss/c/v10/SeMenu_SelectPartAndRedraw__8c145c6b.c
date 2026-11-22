/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m129b.c (2026-11-22-23-p6-r90)
   sha256 8c145c6b24d5f419c17766e2d0722239af64730ca87d0ddc3c3bba21b599f7af (tar-sha256); compiled at -O3 -Xr */
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
    if (part != cur) {
        if (check != 1 || SeMenu_IsPartEnabled(part) != 0) {
            SeMenu_SetCurrentPart(part);
            SeMenu_StorePartParam(0, part);
            SeTitle_DrawField(field, 0);
            SeMenu_SetupMenuDisplay(1);
        }
    }
}
