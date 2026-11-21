/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_GetNameBufferChar(int, unsigned char *);
extern void SeMenu_CharToNameCharIndex(int, unsigned char *);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeWrtSnd_SetupNamingPage_Join6(void);
extern void SeWrtSnd_SetupNamingPage_Join7(void);

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

/* cc900-module: SeWrtSnd_ClearName SeWrtSnd_SetupNamingPage_Join4 */
extern void SeWrtSnd_SetupNamingPage_Join4(unsigned int w);
extern void SeWrtSnd_OnColumn7(unsigned char a);

void SeWrtSnd_OnColumn7(unsigned char a)
{
	unsigned int w;
	unsigned char c;

	c = a & 0x7f;
	w = 0x8000;
	if (c == 0)
		w = 0;
	SeWrtSnd_SetupNamingPage_Join4(w);
}

extern void SeMenu_SetSoundBank(int);
extern void SeMenu_SetPatchBank(int);
extern void AccWrap_PlayModeDispatch(void);
extern void SeMenu_SetEditEnable(int);
extern void SeMenu_OrPartConfig(int);
extern void SeMenu_SetConfirmState(int);
extern void SeMenu_ClearDisplayBuffer(void);
extern void InitializeSeMenuDefaults(void);

void InitializeSeMenuDefaults(void)
{
	SeMenu_SetSoundBank(0);
	SeMenu_SetPatchBank(0);
	AccWrap_PlayModeDispatch();
	SeMenu_SetEditEnable(1);
	SeMenu_OrPartConfig(1);
	SeMenu_SetConfirmState(0);
	SeMenu_ClearDisplayBuffer();
}
