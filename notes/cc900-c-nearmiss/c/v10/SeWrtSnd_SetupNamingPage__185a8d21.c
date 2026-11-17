/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m132.c (2026-11-16-125-p6-r26-staged)
   sha256 185a8d210ee05999e1065d985d6cf90273a03b1cead0b9928aaef1ccdc1ccecc (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
