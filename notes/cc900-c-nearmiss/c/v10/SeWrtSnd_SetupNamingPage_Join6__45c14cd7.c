/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_11m132b.c (2026-11-16-118-p6-r23)
   sha256 45c14cd700465fcd8a70b576239e88b8751a28db797d023de99898c84401f6cf (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void SeMenu_CharToNameCharIndex(int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
void SeWrtSnd_SetupNamingPage_Join6(void)
{
    unsigned char idx;
    unsigned char ch;
    unsigned char pos;

    SeMenu_LoadPartParam(0, &pos);
    if (pos != 0) {
        pos = pos - 1;
        SeMenu_StorePartParam(0, pos);
        SeMenu_GetNameBufferChar(pos, &ch);
        SeMenu_CharToNameCharIndex(ch, &idx);
        SeMenu_StorePartParam(1, idx);
        SeTitle_DrawField(63, 0);
        SeTitle_DrawField(63, 1);
    }
}
