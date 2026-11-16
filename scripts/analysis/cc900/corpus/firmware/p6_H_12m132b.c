/* lane_p6 helper H, round 12, module 132 (audio/sound_editor_ui.s), form b: as form a (declarations reversed for
   the ROM's frame slots), but SetupNamingPage masks the copied length inside the bound test. */

extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void SeMenu_CharToNameCharIndex(int, unsigned char *);
extern void SeMenu_PostDialEnable(int on);
extern void SeMenu_PostEditUpDownSet(int which, int col, int flag);
extern void __cdecl SeTitle_DrawStaticScreen(int);
extern void __cdecl SeTitle_DrawField(int, int);

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

void SeWrtSnd_SetupNamingPage_Join7(void)
{
    unsigned char pos;
    unsigned char ch;
    unsigned char idx;
    unsigned char len;

    SeMenu_LoadPartParam(0, &pos);
    SeMenu_LoadPartParam(2, &len);
    if (pos < (unsigned char)(len - 1)) {
        pos++;
        SeMenu_StorePartParam(0, pos);
        SeMenu_GetNameBufferChar(pos, &ch);
        SeMenu_CharToNameCharIndex(ch, &idx);
        SeMenu_StorePartParam(1, idx);
        SeTitle_DrawField(63, 0);
        SeTitle_DrawField(63, 1);
    }
}
