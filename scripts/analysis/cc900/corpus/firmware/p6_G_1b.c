/* Phase 6, lane_p6 helper G, round 1, form b: functions inside the spans of poolbig_G (NAKA view procs of
   ui/ui_window_procs.s, the FtLangText* language-text functions of storage/flash_floppy_handlers.s, the SeqDMA_*
   writers of boot/system_handlers.s, the option-block routines of audio/tonegen_fileio_handlers.s), each under its
   firmware name.  Form a (p6_G_1a.c) has the same names with other shapes.
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_DRAW              0x1c0000dL
#define EVT_GET_LANGUAGE_PTR  0x1e0009fL
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

/* view instance records as the procs read them */
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };

/* callees */
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawString(struct rect *, struct pt *, char *, int, int, long);
extern void DrawBitmap(struct pt *, unsigned char *);
extern void DrawBitmapSPFast(struct pt *, unsigned char *, int, int);
extern long ApFuncCall(long, long, long);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
extern void DrawLine(struct pt *, struct pt *, int);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern unsigned char *FDemo_LinkedListLookupField(char *);
extern void DrawBitmapFile(struct pt *, unsigned char *);
extern void ChangePalette(int);
extern void __cdecl SeqBuf_DmaChan0_WriteByte(unsigned char);
extern void __cdecl SeqBuf_VoiceMap_WriteByte(unsigned char);
extern void __cdecl SeqBuf_DspSysEx_WriteByte(unsigned char);
extern void __cdecl SeqBuf_SoundEdit_BytecodeBlock(unsigned char);
extern void __cdecl SeqBuf_NoteEvent_WriteByte(unsigned char);
extern void FlashWrite(int, unsigned char *, unsigned int, long);
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void Gfx_ClearFrameBuffers(void);
extern void SndParamBank_WriteFlashDefaults(void);

/* data */
extern unsigned char UserBitmapCheck_Bitmap24x24[];
extern char VwUserBitmapByName_Str_BmpExt[];
extern long NAKA_InitDataBlock_PtrTable[], FDemo_BassPortSpanishHeading_Texts[], NAKA_InitDataBlock_PtrTable_3[];
extern long NAKA_InitDataBlock_PtrTable_4[], NAKA_InitDataBlock_PtrTable_5[], NAKA_InitDataBlock_PtrTable_6[];
extern long NAKA_InitDataBlock_PtrTable_7[], NAKA_InitDataBlock_PtrTable_8[], NAKA_InitDataBlock_PtrTable_9[];
extern long NAKA_InitDataBlock_PtrTable_10[], NAKA_InitDataBlock_PtrTable_11[], FtLangText11_Texts[];
extern long NAKA_InitDataBlock_PtrTable_13[], NAKA_InitDataBlock_PtrTable_14[], NAKA_InitDataBlock_PtrTable_15[];
extern long NAKA_InitDataBlock_PtrTable_16[], FtLangText16_LangStrings[], FtLangText17_Texts[];
extern unsigned char SndParamBank_DefaultHeader[], SndParamBank_Default1[], SndParamBank_Default2[];
extern unsigned char SndParamBank_OptionDefault_00[], SndParamBank_OptionDefault_10[], SndParamBank_OptionDefault_20[];
extern unsigned char SndParamBank_OptionDefault_30[], SndParamBank_OptionDefault_40[];
extern unsigned char HELP_LANGUAGE;
extern unsigned char ram_340e6[], ram_340f2[], ram_340f6[], ram_340fa[];

/* ---- ui/ui_window_procs.s: view procs ---- */

long LabelProc(long obj, long evt, long p)
{
	struct rect r;
	struct pt pt;
	struct vinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	r = h->r;
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 1;
	DrawString(&r, &pt, (char *)h->l22, 0xf7, h->i30, h->l26);
	return 0;
}

long BitmapProc(long obj, long evt, long p)
{
	struct pt pt;
	struct vinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	DrawBitmap(&pt, (unsigned char *)h->l22);
	return 0;
}

long VwUserBitmapProc(long obj, long evt, long p)
{
	int w;
	unsigned char *data;
	struct pt pt;
	struct vinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	data = (unsigned char *)ApFuncCall(h->l22, EVT_GET_BITMAP_DATA, 0);
	if (data != 0) {
		w = ApFuncCall(h->l22, EVT_GET_BITMAP_WIDTH, 0);
		DrawBitmapSPFast(&pt, data, w, (int)ApFuncCall(h->l22, EVT_GET_BITMAP_HEIGHT, 0));
	} else
		DrawBitmap(&pt, 0);
	return 0;
}

long UserBitmapCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_BITMAP_DATA:
		return (long)UserBitmapCheck_Bitmap24x24;
	case EVT_GET_BITMAP_WIDTH:
	case EVT_GET_BITMAP_HEIGHT:
		return 24;
	default:
		return 0;
	}
}

long VwUserBitmapByNameProc(long obj, long evt, long p)
{
	char name[16];
	struct pt pt;
	struct vinst *h;
	unsigned char *f;

	switch (evt) {
	case EVT_SHOW:
		ViewableProc(obj, evt, p);
		return 0;
	case EVT_DRAW:
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		pt.x = h->r.x1;
		pt.y = h->r.y1;
		Strcpy(name, (char *)h->l22);
		Strcat(name, VwUserBitmapByName_Str_BmpExt);
		f = FDemo_LinkedListLookupField(name);
		if (f != 0) DrawBitmapFile(&pt, f);
		else DrawBitmap(&pt, 0);
		return 0;
	case EVT_HIDE:
		ChangePalette(2);
		ViewableProc(obj, evt, p);
		return 0;
	}
	return ViewableProc(obj, evt, p);
}

long IconProc(long obj, long evt, long p)
{
	struct pt pt;
	struct rect r;
	struct vinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 2;
	r.x1 = pt.x - 2;
	r.x2 = pt.x + 25;
	r.y1 = pt.y - 2;
	r.y2 = pt.y + 25;
	DrawDesignBox(&r, 0xc4, 0xf0);
	DrawIcons(&pt, h->l22);
	return 0;
}

long LineProc(long obj, long evt, long p)
{
	struct pt a, b;
	struct lineinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->dir == 1) {
		a.x = h->x1;
		a.y = h->y1;
		b.x = h->x2;
		b.y = h->y2;
	} else {
		a.x = h->x1;
		a.y = h->y2;
		b.x = h->x2;
		b.y = h->y1;
	}
	DrawLine(&a, &b, h->color);
	return 0;
}

/* ---- storage/flash_floppy_handlers.s: an empty function and the FtLangText* language-text functions ---- */

void NAKA_InitDataBlock(void)
{
}

long FtLangText01(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable;
}

long FtLangText01S(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)FDemo_BassPortSpanishHeading_Texts;
}

long FtLangText02(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_3;
}

long FtLangText03(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_4;
}

long FtLangText04(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_5;
}

long FtLangText05(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_6;
}

long FtLangText06(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_7;
}

long FtLangText07(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_8;
}

long FtLangText08(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_9;
}

long FtLangText09(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_10;
}

long FtLangText10(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_11;
}

long FtLangText11(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)FtLangText11_Texts;
}

long FtLangText12(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_13;
}

long FtLangText13(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_14;
}

long FtLangText14(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_15;
}

long FtLangText15(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)NAKA_InitDataBlock_PtrTable_16;
}

long FtLangText16(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)FtLangText16_LangStrings;
}

long FtLangText17(long obj, long evt)
{
	if (evt != EVT_GET_LANGUAGE_PTR) return 0;
	return (long)FtLangText17_Texts;
}

/* ---- boot/system_handlers.s: SeqDMA_* writers ---- */

void SeqDMA_Nop(void)
{
}

void SeqDMA_MultiWrite_NoteEvent(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DmaChan0_WriteByte(*p++);
}

void SeqDMA_MultiWrite_VoiceMap(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_VoiceMap_WriteByte(*p++);
}

void SeqDMA_MultiWrite_DspSysEx(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_DspSysEx_WriteByte(*p++);
}

void SeqDMA_MultiWrite_SoundEdit(unsigned char n, unsigned char *p)
{
	unsigned int i;

	for (i = 0; i < n; i++)
		SeqBuf_SoundEdit_BytecodeBlock(*p++);
}

void SeqDMA_WriteMidi_NoteOn(unsigned char ch, unsigned char *p)
{
	if (*p == 0x90) {
		SeqBuf_NoteEvent_WriteByte(*++p);
		SeqBuf_NoteEvent_WriteByte(*++p);
	}
}

/* ---- audio/tonegen_fileio_handlers.s: the sound-parameter bank's option block ---- */

struct tlvrec { long off; unsigned char pad[4]; unsigned char tag, len; };

void PanelTlv_WriteRecordHeader(unsigned char *buf, struct tlvrec *rec)
{
	unsigned char *q;

	q = buf + rec->off;
	q[0] = rec->tag;
	q[1] = rec->len;
}

void SndParamBank_CheckFlash(void)
{
	unsigned char *s, *d;
	unsigned int i;

	s = SndParamBank_DefaultHeader;
	d = (unsigned char *)0x3d3000L;
	for (i = 0; i < 3; i++)
		if (*s++ != *d++) {
			SndParamBank_WriteFlashDefaults();
			return;
		}
}

void SndParamBank_WriteFlashDefaults(void)
{
	unsigned char *b;

	FlashWrite(1, SndParamBank_DefaultHeader, 0xfa, 0x3d3000L);
	FlashWrite(1, SndParamBank_Default1, 0xea, 0x3d3110L);
	FlashWrite(1, SndParamBank_Default2, 0xea, 0x3d3210L);
	b = Malloc(0x50);
	if (b != 0) {
		Memset(b, 0x50, 0);
		Mem_Copy(b, SndParamBank_OptionDefault_00, 2);
		Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
		Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
		Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
		Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
		FlashWrite(1, b, 0x50, 0x3d3400L);
		Free(b);
	}
}

void SndParamBank_RestoreOptionBlock(void)
{
	unsigned char *b;

	b = Malloc(0x50);
	if (b != 0) {
		Memset(b, 0x50, 0);
		Mem_Copy(b, (void *)0x3d3400L, 2);
		Mem_Copy(b + 16, SndParamBank_OptionDefault_10, 12);
		Mem_Copy(b + 32, SndParamBank_OptionDefault_20, 4);
		Mem_Copy(b + 48, SndParamBank_OptionDefault_30, 4);
		Mem_Copy(b + 64, SndParamBank_OptionDefault_40, 6);
		FlashWrite(1, b, 0x50, 0x3d3400L);
		Free(b);
		Gfx_ClearFrameBuffers();
	}
}

void SndParamBank_LoadOptionBlock(void)
{
	Mem_Copy(&HELP_LANGUAGE, (void *)0x3d3400L, 2);
	Mem_Copy(ram_340e6, (void *)0x3d3410L, 12);
	Mem_Copy(ram_340f2, (void *)0x3d3420L, 4);
	Mem_Copy(ram_340f6, (void *)0x3d3430L, 4);
	Mem_Copy(ram_340fa, (void *)0x3d3440L, 6);
}
