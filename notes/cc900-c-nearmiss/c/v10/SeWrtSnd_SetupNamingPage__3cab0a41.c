/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_12m132b.c (2026-11-16-123-p6-r25)
   sha256 3cab0a415ee0caacdd9c660c9af79af862e4169c5f8dfc3e860a58b6694997a3 (tar-sha256); compiled at -Xr */
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void SeMenu_CharToNameCharIndex(int, unsigned char *);
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
extern void __cdecl SeTitle_DrawStaticScreen(int);
void SeWrtSnd_SetupNamingPage(unsigned char len)
{
    unsigned char n;
    unsigned char ch;
    unsigned char idx;

    n = len;
    if ((n &= 31) > 16)
        n = 16;
    SeMenu_StorePartParam(2, n);
    SeMenu_GetNameBufferChar(0, &ch);
    SeMenu_CharToNameCharIndex(ch, &idx);
    SeMenu_StorePartParam(1, idx);
    SeMenu_StorePartParam(0, 0);
    SeTitle_DrawStaticScreen(63);
    SeMenu_PostDialEnable(1);
    SeMenu_PostEditUpDownSet(0, 8, 0);
    SeMenu_PostEditUpDownSet(1, 6, 0);
}
