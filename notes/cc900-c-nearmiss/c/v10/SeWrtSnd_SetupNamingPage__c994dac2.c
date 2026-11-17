/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_12m132a.c (2026-11-16-123-p6-r25)
   sha256 c994dac24a60008fd2509b93d2afe860b2a8f07ae39a2715ba767a2481eccd65 (tar-sha256); compiled at -Xr */
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
    n &= 31;
    if (n > 16)
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
