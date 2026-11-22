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

/* cc900-module: PaintArrow_DrawFilled PaintArrow_DrawOutline */
#define EVT_GET_LANGUAGE_PTR  0x1e0009fL
extern long AttLangCheck_PtrTable[];
extern long AttLangCheck(long obj, long evt);
#define EVT_DRAW              0x1c0000dL
#define EVT_PARA_DRAW         0x1c0000fL
extern unsigned char __near STYLE_SECTION;
extern long InheritedProc(long, long, long);
extern long SendEvent(long, long, long);
extern long CmpNameMenuBoxProc(long obj, long evt, long p);
extern long Memful2LangCheck_PtrTable[];
extern long Memful2LangCheck(long obj, long evt);
extern long MemfulLangCheck_PtrTable[];
extern long MemfulLangCheck(long obj, long evt);
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_GET_STR_PTR       0x1e00089L
extern char __near ram_3eb0[];
extern char *__cdecl Strcpy(char *, char *);
extern long PsStylCnvVerProc(long obj, long evt, long p);
extern long Hama_ModeInit_Table[];
extern long SndArrLangCheck(long obj, long evt);
extern long SndMem1LangCheck_PtrTable[];
extern long SndMem1LangCheck(long obj, long evt);
extern long SndMemLangCheck_PtrTable[];
extern long SndMemLangCheck(long obj, long evt);
extern long StylCnvLangCheck_PtrTable[];
extern long StylCnvLangCheck(long obj, long evt);
extern long SureLangCheck_PtrTable[];
extern long SureLangCheck(long obj, long evt);

long AttLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)AttLangCheck_PtrTable;
	return 0;
}
long CmpNameMenuBoxProc(long obj, long evt, long p)
{
	if (evt != EVT_DRAW)
		return InheritedProc(obj, evt, p);
	if (STYLE_SECTION < 12) {
		InheritedProc(obj, evt, p);
		SendEvent(obj, EVT_PARA_DRAW, 0L);
	}
	return 0;
}
long Memful2LangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)Memful2LangCheck_PtrTable;
	return 0;
}
long MemfulLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)MemfulLangCheck_PtrTable;
	return 0;
}
long PsStylCnvVerProc(long obj, long evt, long p)
{
	char buf[512];

	switch (evt) {
	default:
		return InheritedProc(obj, evt, p);
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		break;
	case EVT_HIDE:
		InheritedProc(obj, evt, p);
		break;
	case EVT_GET_STR_PTR:
		return (long)ram_3eb0;
	case EVT_PAINT:
	case EVT_REPAINT:
		InheritedProc(obj, evt, p);
		Strcpy(buf, ram_3eb0);
		SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		break;
	}
	return 0;
}
long SndArrLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)Hama_ModeInit_Table;
	return 0;
}
long SndMem1LangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SndMem1LangCheck_PtrTable;
	return 0;
}
long SndMemLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SndMemLangCheck_PtrTable;
	return 0;
}
long StylCnvLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)StylCnvLangCheck_PtrTable;
	return 0;
}
long SureLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SureLangCheck_PtrTable;
	return 0;
}
