/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_12m132b.c (2026-11-16-123-p6-r25)
   sha256 3cab0a415ee0caacdd9c660c9af79af862e4169c5f8dfc3e860a58b6694997a3 (tar-sha256); compiled at -Xr */
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void SeMenu_CharToNameCharIndex(int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
void SeWrtSnd_SetupNamingPage_Join6(void)
{
    unsigned char pos;
    unsigned char ch;
    unsigned char idx;

    SeMenu_LoadPartParam(0, &pos);
    if (pos != 0) {
        pos--;
        SeMenu_StorePartParam(0, pos);
        SeMenu_GetNameBufferChar(pos, &ch);
        SeMenu_CharToNameCharIndex(ch, &idx);
        SeMenu_StorePartParam(1, idx);
        SeTitle_DrawField(63, 0);
        SeTitle_DrawField(63, 1);
    }
}
