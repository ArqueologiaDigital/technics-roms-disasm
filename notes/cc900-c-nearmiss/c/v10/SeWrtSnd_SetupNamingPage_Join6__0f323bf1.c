/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_11m132a.c (2026-11-16-118-p6-r23)
   sha256 0f323bf16ee604b5c27d4415b0313e4248fa1ec74f9b02130ab8db1bfa6c6b47 (tar-sha256); compiled at -O3 -Xr */
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
        pos--;
        SeMenu_StorePartParam(0, pos);
        SeMenu_GetNameBufferChar(pos, &ch);
        SeMenu_CharToNameCharIndex(ch, &idx);
        SeMenu_StorePartParam(1, idx);
        SeTitle_DrawField(63, 0);
        SeTitle_DrawField(63, 1);
    }
}
