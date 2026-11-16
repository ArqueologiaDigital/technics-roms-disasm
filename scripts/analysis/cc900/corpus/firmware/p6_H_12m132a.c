/* lane_p6 helper H, round 12, module 132 (audio/sound_editor_ui.s), form a: SeWrtSnd_SetupNamingPage, _Join6, _Join7
   from round 11 (run 118: +3 / +2 / +2, the frame slots).  V4.23 gives scalar locals their frame slots in REVERSE
   declaration order (the last declared lowest), so the declarations are reversed to put them where the ROM has
   them (SetupNamingPage: index +0, char +2; Join6: index +0, char +2, cursor +4; Join7: length +0, index +2,
   char +4, cursor +6).  SetupNamingPage copies the length byte before masking it (the ROM's ld c,a / and c,31). */

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
