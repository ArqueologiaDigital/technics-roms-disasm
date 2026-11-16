/* Phase 6, lane_p6 helper D, round 5, form b: routines WITH calls from poolc_D2 (adecl callees declared with
   their tree names), plus one leaf refinement, each under its firmware name.
   Form a (p6_D_5a.c) has the same names; this file holds the alternatives.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label).
   One declarator per __near declaration.  Event codes and title ids are written as numbers (their .equ values):
   EVT_PAINT 0x1c0000b, EVT_PARA_DRAW 0x1c0000f, EVT_PS_FILE_NAME_BOX_ID 0x1e50004, EVT_DRAW 0x1c0000d,
   EVT_GET_BOX_BORDER 0x1e000b1, EVT_GET_BOX_COLOR 0x1e000b2, EVT_CHANGE_MODE 0x1c00014, EVT_CHANGE_TITLE 0x1c00015,
   EVT_INTERRUPT_TITLE 0x1c00016, TITLE_PS 0x1a00000, NAKA_MODE_MD_PS 0x1800000. */

typedef unsigned char *ucp;

struct view { unsigned char pad[14]; unsigned char box[8]; int f22; int f24; };

/* callees */
extern void DeleteEvent(long, long);
extern long ApPostEvent(long, long, long);
extern long ViewableProc(long, long, long);
extern struct view *GetViewInstance(long);
extern void DrawDesignBox(unsigned char *, int, int);
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_SkipToNextEvent(void);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void PartCtrl_AdvanceReadPos(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void SoundParam_NotifyChange(long, unsigned int, unsigned int);
extern void sendCOMM(int, int, unsigned char *);

/* data */
extern unsigned char Text_CharGlyphMap[];
extern long StorageArea_NameTable[], StorageArea_UnitNames[], SingleLoad_BankCaptionByMode[];
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near ram_8a0a;
extern long __near ram_81b6;
extern long __near ram_81ba;
extern long __near ram_81be;
extern long __near ram_81c2;
extern long __near ram_81c6;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2772;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;
extern ucp __near SEQ_BLOCK_POOL;
extern unsigned char __near ram_8d54;
extern unsigned char __near ram_8d52;

/* ---- leaf refinement ---- */

void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;

	if (*in == 32 || *in == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (*in == Text_CharGlyphMap[i]) {
			*out = i;
			break;
		}
	if (i == 256) *out = 32;
}

/* ---- ui/ui_control_panel.s ---- */

void UI_InterruptTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00016L);
	ApPostEvent(-1L, 0x1c00016L, 0x1a00000L + i);
}

void UI_ChangeTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00015L);
	ApPostEvent(-1L, 0x1c00015L, 0x1a00000L + i);
}

void UI_ChangeModeByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00014L);
	ApPostEvent(-1L, 0x1c00014L, 0x1800000L + i);
}

long BoxProc(long obj, long evt, long p)
{
	struct view *h;
	long off;

	if (evt == 0x1e000b2L) {
		off = 0x16;
	} else if (evt == 0x1e000b1L) {
		off = 0x18;
	} else if (evt == 0x1c0000dL) {
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		DrawDesignBox(h->box, h->f24, h->f22);
		return 0;
	} else {
		return ViewableProc(obj, evt, p);
	}
	return *(int *)((unsigned char *)GetViewInstance(obj) + off);
}

/* ---- file_io/single_load.s ---- */

long SingleLoadModeFunc(long a, long evt, long p)
{
	if (evt == 0x1c0000bL) ApPostEvent(ram_81b6, 0x1c0000fL, StorageArea_NameTable[SINGLE_LOAD_AREA]);
	else if (evt == 0x1e50004L) ram_81b6 = p;
	return 0;
}

long SingleLoadDstBankFunc(long a, long evt, long p)
{
	if (evt == 0x1c0000bL) ApPostEvent(ram_81ba, 0x1c0000fL, SingleLoad_BankCaptionByMode[SINGLE_LOAD_AREA]);
	else if (evt == 0x1e50004L) ram_81ba = p;
	return 0;
}

long SingleLoadDstMemFunc(long a, long evt, long p)
{
	long o, *t, v;

	switch (evt) {
	case 0x1e50004L:
		ram_81be = p;
		break;
	case 0x1c0000bL:
		o = ram_81be;
		t = StorageArea_UnitNames;
		if (SINGLE_LOAD_ALL != 0 && SINGLE_LOAD_AREA != 1) v = t[4];
		else v = t[SINGLE_LOAD_AREA];
		ApPostEvent(o, 0x1c0000fL, v);
		break;
	}
	return 0;
}

long SingleLoadSrcMemFunc(long a, long evt, long p)
{
	long o, *t, v;
	unsigned char c;

	switch (evt) {
	case 0x1e50004L:
		ram_81c6 = p;
		break;
	case 0x1c0000bL:
		o = ram_81c6;
		t = StorageArea_UnitNames;
		c = SINGLE_LOAD_AREA;
		if (c == 1 || SINGLE_LOAD_ALL != 0) v = t[4];
		else v = t[c];
		ApPostEvent(o, 0x1c0000fL, v);
		break;
	}
	return 0;
}

long SingleLoadSrcBankFunc(long a, long evt, long p)
{
	long o, *t, v;
	unsigned char c;

	switch (evt) {
	case 0x1e50004L:
		ram_81c2 = p;
		break;
	case 0x1c0000bL:
		o = ram_81c2;
		t = SingleLoad_BankCaptionByMode;
		c = SINGLE_LOAD_AREA;
		if (c == 0 && ram_8a0a != 0) v = t[4];
		else v = t[c];
		ApPostEvent(o, 0x1c0000fL, v);
		break;
	}
	return 0;
}

/* ---- sequencer/seq_step_routines.s ---- */

int SeqStep_SkipThreeEvents(void)
{
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) return -1;
	if (SeqPart_ReadByte_Secondary() != 0) return -1;
	return 0;
}

int SeqStep_WalkReadNext(void)
{
	unsigned int b;

	if (SQSTEP_SCAN_OFFSET == 5) {
		b = PartCtrl_ReadWord_Off1(SQSTEP_SCAN_BLOCK);
		if (b == 0) return -1;
		SQSTEP_SCAN_BLOCK = b;
		SQSTEP_SCAN_OFFSET = 255;
	} else {
		SQSTEP_SCAN_OFFSET++;
	}
	return 0;
}

void SeqStep_CopyPartData(unsigned int a, unsigned int b)
{
	unsigned char *src, *dst;
	unsigned long s, d;
	unsigned int i;

	src = SEQ_BLOCK_POOL;
	s = ((unsigned long)a - 1) << 8;
	dst = src;
	d = ((unsigned long)b - 1) << 8;
	i = 0;
	do {
		dst[(unsigned long)i + d] = src[(unsigned long)i + s];
		i++;
	} while (i < 0x100);
	PartCtrl_SetClearBit7(a, 0);
}

/* ---- sequencer/bmdredit_routines.s ---- */

void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2772 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2772++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE == 0) return;
	SeqData_SetErrorCode(0xce);
}

void BmDrEdit_ClearAndScanToEnd(void)
{
	unsigned int o, b;

	SEQ_ERROR_CODE = 0;
	for (;;) {
		o = SEQ_DATA_OFFSET;
		if (o > 5) {
			SEQ_DATA_OFFSET = o - 1;
		} else {
			b = PartCtrl_ReadWord_Off1(SEQ_DATA_BLOCK);
			if (b == 0) {
				SEQ_ERROR_CODE = 255;
				return;
			}
			SEQ_DATA_BLOCK = b;
			SEQ_DATA_OFFSET = 255;
		}
		if (SeqData_ReadNextByte() & 0x80) return;
	}
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck (32 characters) */
int PartCtrl_ReadWordWithBoundsChk(unsigned int *blk, unsigned int *off)
{
	if (++*off <= 0xff) return 0;
	*blk = PartCtrl_ReadWord(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa1);
		return -1;
	}
	*off = 5;
	return 0;
}

/* cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter (36 characters) */
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	if (--*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}

/* ---- ui/ui_mode_handlers.s ---- */

/* cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam (34 characters) */
void SndOutput_ReinitByMode_Notify(void)
{
	SoundParam_NotifyChange(0x300, ram_8d54 + 1, 3);
	if (ram_8d52 & 0x20) ram_8d52 = ram_8d52 | 4;
	if (ram_8d52 & 8) ram_8d52 = ram_8d52 | 2;
}

/* ---- demo/fdemotext_routines.s ---- */

void FDemoText_SendResetMessage(unsigned char c)
{
	unsigned char b[6];

	b[0] = 0x82;
	b[1] = c;
	b[2] = 2;
	b[3] = 2;
	b[4] = 1;
	b[5] = 0xea;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[0] = 0x83;
	b[2] = 2;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
}
