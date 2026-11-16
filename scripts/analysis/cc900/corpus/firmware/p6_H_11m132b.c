/* Form b: as form a, but _Join7's bound test written with the bound on the left and the cursor steps as
   assignments (pos = pos - 1 / pos + 1).
   lane_p6 helper H, round 11, module 132 (audio/sound_editor_ui.s), form b: SeWrtSnd_SetupNamingPage and the two
   naming-page cursor steps after it, SeWrtSnd_SetupNamingPage_Join6 (cursor left) and _Join7 (cursor right) (new).
   The part-parameter helpers of module 129 are called with int arguments (the ROM widens every byte with extz and
   loads constants into WA / BC / DE); SeTitle_DrawStaticScreen / SeTitle_DrawField take stack arguments that the
   caller pops (cdecl, the two DrawField pops merged).  Byte locals whose address is passed live in the frame in
   declaration order, lowest first. */

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
    unsigned char idx;
    unsigned char ch;
    unsigned char n;

    n = len & 31;
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

void SeWrtSnd_SetupNamingPage_Join7(void)
{
    unsigned char len;
    unsigned char idx;
    unsigned char ch;
    unsigned char pos;

    SeMenu_LoadPartParam(0, &pos);
    SeMenu_LoadPartParam(2, &len);
    if ((unsigned char)(len - 1) > pos) {
        pos = pos + 1;
        SeMenu_StorePartParam(0, pos);
        SeMenu_GetNameBufferChar(pos, &ch);
        SeMenu_CharToNameCharIndex(ch, &idx);
        SeMenu_StorePartParam(1, idx);
        SeTitle_DrawField(63, 0);
        SeTitle_DrawField(63, 1);
    }
}
