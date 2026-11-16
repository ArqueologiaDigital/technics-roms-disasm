/* Phase 6, lane_p6 helper D, round 2, form b: round-1 misses refined after run 2026-11-16-31-p6-r1b, plus new
   leaf functions of the pool, each under its firmware name (or a short C name with a cc900-name comment).
   Form a (p6_D_2a.c) has the same names; this file holds the alternatives.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label).
   One declarator per __near declaration. */

typedef unsigned char *ucp;

struct bit0 { unsigned char b0 : 1; unsigned char rest : 7; };
struct res12 { long a; char *p; long c; };
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct sram_rgn { volatile unsigned char *start; unsigned long size; unsigned char flag, pad; };
struct sname { int key; char name[16]; };
struct box { int x0, y0, x1, y1; };
struct pt { int x, y; };
struct heap { unsigned int count; unsigned char data[16384]; };

/* sequencer/seq_audio_mode.s */
extern unsigned char __near ram_3310;
extern unsigned char __near ram_32f9;
extern unsigned char __near ram_3306;
extern unsigned char __near ram_3338;
extern unsigned char __near ACC_VARIATION_REQUEST;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_STYLE_NUMBER;
extern unsigned char __near ACC_STYLE_ARRANGER_ON;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern struct bit0 __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
/* sequencer/bmdredit_routines.s */
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2746[];
extern unsigned char __near ram_27a4[];
extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern unsigned int __near ram_279e;
extern unsigned int __near ram_27ce;
extern unsigned int __near ram_27d0;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2782;
extern unsigned int __near ram_27b2;
extern unsigned int __near ram_2744;
extern unsigned int ram_210a6, ram_210a4;
extern unsigned char ram_b0000[];
extern unsigned char WidgetData_DrawbarPositionTable[];
/* storage/fdc_routines.s */
extern volatile unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_PROBE_FLAG;
extern unsigned int __near FDC_REQ_SECTOR;
extern unsigned char FDC_Set_Status(int);
/* storage/flash_floppy_handlers.s */
extern ucp __near MSP_SETTINGS;
extern ucp __near RHYTHM_PATTERN_BUF_PTR;
extern ucp __near STYLE_WORK_IMAGE_PTR;
extern ucp __near FLASH_SECTOR_IMAGE_PTR;
extern ucp __near FLASH_SECTION_PTR_0;
extern ucp __near FLASH_SECTION_PTR_1;
extern ucp __near FLASH_SECTION_PTR_2;
extern ucp __near FLASH_SECTION_PTR_3;
extern ucp __near FLASH_SECTION_PTR_4;
extern ucp __near FLASH_SECTION_PTR_5;
extern ucp __near FLASH_SECTION_PTR_6;
extern ucp __near FLASH_SECTION_PTR_7;
extern unsigned char RHYTHM_PATTERN_BUF_A[], ram_300000[], ram_69800[];
extern unsigned char Composer_SettingsBlock[], Composer_DefaultHeaderFields[], MSP_Default_PartBankMap[];
extern unsigned char Composer_DefaultEmptyRecord[], Composer_DefaultUserBankNames[];
/* audio/semenu_routines.s */
extern unsigned char ram_20bf3[], ram_20c03[], ram_20c13[], ram_20c23[];
/* audio/audio_control_engine.s */
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near ram_90f9;
extern unsigned int __near ram_9163;
extern unsigned char SplitPoint_LedMaskByPreset[];
/* audio/dsp_config_sysex.s */
extern void *DspFxRecListPtrTable[];
/* audio/audioinit_routines.s */
extern unsigned char __near ram_7f0b;
extern unsigned char __near AUDIO_STATE[];
extern unsigned int __near AUDIO_STATE_CHANGES;
/* audio/sndparam_routines.s */
extern long __near ram_97d8[];
extern struct heap ram_380f8;
/* audio/tonegen_fileio_handlers.s: none */
/* ui/bitmap_out_routines.s */
extern unsigned int __near ram_90e2;
extern unsigned char __near ram_bf39[];
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
/* ui/ui_mode_handlers.s */
extern struct sram_rgn SramTest_IC21Regions[];
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
/* ui/cpanel_routines.s */
extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;
/* ui/ui_control_panel.s */
extern unsigned int TITLE_FLAGS_LATCHED;
/* ui/ui_widget_defs.s */
extern int ram_3247c[];
extern ucp ram_32466, DRAW_QUEUE_WRITE_PTR;
extern unsigned char DRAW_QUEUE[];
/* demo/fdemotext_routines.s */
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern char *ram_24fd8[];
/* midi/midipkt_routines.s */
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
/* file_io/smf_operations.s */
extern unsigned char CType_ClassTable[];

void BmDrEdit_CalcSongPosition(void);

/* ---- refined round-1 misses ---- */

void AudioMode_MergeOutputBits(void)
{
	unsigned char a, w;

	a = ram_3310 & 0xf8;
	w = ram_32f9 & 7;
	ram_3310 = a | w;
}

void BmDrEdit_ClampScrollPos(void)
{
	unsigned int s, m;

	m = ram_2774 * 96;
	m--;
	s = ram_27ce;
	if (s + ram_27d0 <= m) return;
	m -= s;
	ram_27d0 = m;
}

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 1;
		for (;;) {
			if (ram_27a4[i] != 0) ram_25d8 = 0;
			i++;
			if ((ram_2772 = ram_2772 - 1) == 0) break;
			ram_25d8++;
		}
	}
	ram_2782 = ram_25d8;
	ram_2784 = ram_279a % 96;
	BmDrEdit_CalcSongPosition();
}

void BmDrEdit_CalcSongPosition(void)
{
	unsigned int n, i;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 0;
		do {
			if (ram_27a4[i] != 0) ram_25d8++;
			i++;
		} while ((ram_2772 = ram_2772 - 1) != 0);
	}
	ram_2744 = ram_27b2 + (unsigned int)ram_25d8;
}

int FDC_DETECT_CHECK(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	return FDC_REQ_SECTOR == 1 ? -1 : 0;
}

unsigned char FDC_Exception_Status_Decoder(void)
{
	unsigned char c = FDC_RESULT[1];

	switch (c & 0xc0) {
	case 0:
		return 0;
	case 0xc0:
		ram_8b00 = 255;
		return 0;
	case 0x80:
		return 0;
	case 0x40:
		if (c & 8) return 0x31;
		if (c & 0x10) return 0x32;
		c = FDC_RESULT[2];
		if (c & 1) return FDC_Set_Status(0x35);
		if (c & 2) return FDC_Set_Status(0x2f);
		if (c & 4) return FDC_Set_Status(0x33);
		if (c & 0x10) return FDC_Set_Status(0x34);
		if (c & 0x20) return FDC_Set_Status(0x36);
		if (c & 0x80) return FDC_Set_Status(0x37);
		return FDC_Set_Status(8);
	default:
		return 8;
	}
}

unsigned char FDC_ValidateOpcode(void)
{
	unsigned char c;

	switch (FDC_CMD_OPCODE) {
	case 53: case 71: case 52: case 51: case 79:
		return 0;
	}
	switch (c = FDC_CMD_OPCODE & 31) {
	case 17:
		return 0;
	case 16:
		return 1;
	case 25: case 29: case 30:
		return 0;
	default:
		if (c > 15 || c < 2) return 1;
		return 0;
	}
}

void AccentVoice_DetectAndMarkChange(void)
{
	if (ACC_VARIATION_REQUEST != ram_3306 && !((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & 0x3f)
	    && ACC_STYLE_NUMBER < 240 && ACC_STYLE_NUMBER < 128) {
		if (!(ACC_STYLE_ARRANGER_ON & 1) || !((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2) & 0x3f)) {
			if ((ACC_VARIATION_REQUEST & 3) != ram_3338) ACC_VARIATION_CHANGE_PENDING.b0 = 1;
		}
	}
	ACC_VARIATION_NEXT = ACC_VARIATION_REQUEST & 3;
}

void SeMenu_SetupPartDisplay(unsigned char m, unsigned char *s, unsigned char n)
{
	int j;
	unsigned char i;
	unsigned char *t;

	if (m == 1) {
		i = 0;
		if (n == 0) return;
		t = ram_20bf3; j = 0;
		do { t[j] = s[j]; i++; j++; } while (i < n);
	} else if (m == 2) {
		i = 0;
		if (n == 0) return;
		t = ram_20c03; j = 0;
		do { t[j] = s[j]; i++; j++; } while (i < n);
	} else if (m == 3) {
		i = 0;
		if (n == 0) return;
		t = ram_20c13; j = 0;
		do { t[j] = s[j]; i++; j++; } while (i < n);
	} else if (m == 4) {
		i = 0;
		if (n == 0) return;
		t = ram_20c23; j = 0;
		do { t[j] = s[j]; i++; j++; } while (i < n);
	}
}

void SeMenu_SetupPartDisplay_End(unsigned char m, unsigned char *d, unsigned char n)
{
	int j;
	unsigned char i;
	unsigned char *t;

	if (m == 1) {
		i = 0;
		if (n == 0) return;
		t = ram_20bf3; j = 0;
		do { d[j] = t[j]; i++; j++; } while (i < n);
	} else if (m == 2) {
		i = 0;
		if (n == 0) return;
		t = ram_20c03; j = 0;
		do { d[j] = t[j]; i++; j++; } while (i < n);
	} else if (m == 3) {
		i = 0;
		if (n == 0) return;
		t = ram_20c13; j = 0;
		do { d[j] = t[j]; i++; j++; } while (i < n);
	} else if (m == 4) {
		i = 0;
		if (n == 0) return;
		t = ram_20c23; j = 0;
		do { d[j] = t[j]; i++; j++; } while (i < n);
	}
}

void Seq_CopyResourcePtrs(int n)
{
	char **p, **e;
	char *s;

	p = ram_24fd8; s = Seq_CopyResourcePtrs_Str_Empty; e = &ram_24fd8[127];
	do *p++ = s; while (p <= e);
	if (n >= 18 && n <= 18) ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	else ram_249cc = ram_249d0;
	ram_249d4 = ram_249cc;
}

void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[(int)NOTEEDIT_BASE_KEY * 2 + 1];
}

int MidiPkt_CheckGateCondition(struct pkt *k)
{
	if (k->g1 != 0) {
		if ((*MidiCtl_GateRecords[k->g1].p & MidiCtl_GateRecords[k->g1].mask) != MidiCtl_GateRecords[k->g1].val)
			return -1;
	}
	if (k->g2 != 0) {
		if ((*MidiCtl_SecondGateRecords[k->g2].p & MidiCtl_SecondGateRecords[k->g2].mask)
		    != MidiCtl_SecondGateRecords[k->g2].val)
			return -1;
	}
	return 0;
}

void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;
	unsigned char c;

	name[len] = 0;
	for (i = 0; i < 8 && (c = name[i]) != 0; i++)
		if (!(CType_ClassTable[c] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}

void Flash_InitExtMemAddrs(void)
{
	unsigned char *p;

	FLASH_SECTION_PTR_0 = p = ram_300000;
	FLASH_SECTION_PTR_1 = p + 0x19800;
	FLASH_SECTION_PTR_2 = p + 0x30000;
	FLASH_SECTION_PTR_3 = p + 0x49800;
	FLASH_SECTION_PTR_4 = p + 0x60000;
	FLASH_SECTION_PTR_5 = p + 0x79800;
	FLASH_SECTION_PTR_6 = p + 0x90000;
	FLASH_SECTION_PTR_7 = p + 0xb0000;
	RHYTHM_PATTERN_BUF_PTR = RHYTHM_PATTERN_BUF_A;
	FLASH_SECTOR_IMAGE_PTR = STYLE_WORK_IMAGE_PTR = ram_69800;
}

void BmDrEdit_AdvanceStreamPos(void)
{
	unsigned long o;
	unsigned int h;

	if (ram_210a6 < 0xff) { ram_210a6++; return; }
	o = (unsigned long)(ram_210a4 - 1) << 8;
	h = ram_b0000[o + 4];
	h <<= 8;
	ram_210a4 = ram_b0000[o + 3] + h;
	ram_210a6 = 5;
}

/* cc900-name: AccPatch_ResetSecByte2Defaults=AccPatch_ResetSectionPartByte2Defaults (the label shares its first 31
   characters with AccPatch_ResetSectionPartByte2Defaults_Loop) */
void AccPatch_ResetSecByte2Defaults(void)
{
	int o, j;
	unsigned char i;

	i = 0; o = 0;
	do {
		j = o + 96;
		(RHYTHM_PATTERN_BUF_PTR + j)[34] = 64;
		(RHYTHM_PATTERN_BUF_PTR + j)[42] = 12;
		(RHYTHM_PATTERN_BUF_PTR + j)[50] = 116;
		(RHYTHM_PATTERN_BUF_PTR + j)[58] = 64;
		i++; o += 96;
	} while (i < 30);
}

unsigned char Flash_CountFreeOrOwnedSlots(unsigned char mode, unsigned char owner)
{
	int j;
	unsigned char n, i, h;
	unsigned char *p;

	n = 0; p = FLASH_SECTION_PTR_7; i = 0;
	if (mode == 0) {
		j = 0;
		do { h = p[j + 16]; if (h == 0 || h == owner) n++; i++; j++; } while (i < 40);
	} else {
		j = 0;
		do { h = p[j + 80]; if (h == 0 || h == owner) n++; i++; j++; } while (i < 4);
	}
	return n;
}

int DSPCfg_ValidateSlotForWrite(unsigned int a, int s)
{
	if (a > 0x63) return -1;
	if (DspFxRecListPtrTable[a] == 0) return -1;
	switch (s) {
	case 0:
		if (a < 0x10 || a > 0x1b) goto ok;
		return -1;
	case 1:
		if (a == 9 || a == 10) goto ok;
		if (a < 0x10 || a > 0x1b) return -1;
		goto ok;
	case 2:
		if (a < 0x39 || a > 0x3c) return -1;
		goto ok;
	case 3:
		if (a < 0x58 || a > 0x5b) return -1;
		goto ok;
	case 4:
		if (a != 0x4f) return -1;
		goto ok;
	default:
		return -1;
	}
ok:
	return 0;
}

int Test_SRAM_IC21(unsigned char r)
{
	unsigned char k, w;
	struct sram_rgn *g;
	volatile unsigned char *p;
	unsigned long n;
	unsigned char *f;

	k = 0;
	do {
		g = &SramTest_IC21Regions[k];
		p = g->start;
		for (n = g->size >> 1; n != 0; n--) {
			w = *p;
			*p = 0x5a;
			f = &g->flag;
			if (*p != 0x5a) r |= *f;
			*p++ = w;
			w = *p;
			*p = 0xa5;
			if (*p != 0xa5) r |= *f;
			*p++ = w;
		}
		k++;
	} while (k != 1);
	return r;
}

void ToneData_SetupCopyPointers(void)
{
	int i, j;

	for (i = 0; i < 512; i++) MSP_SETTINGS[256 + i] = 0;
	for (i = 0; i < 6; i++) MSP_SETTINGS[i] = Composer_SettingsBlock[i];
	for (i = 0; i < 16; i++) MSP_SETTINGS[16 + i] = Composer_DefaultHeaderFields[i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[512 + i] = MSP_Default_PartBankMap[i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[576 + i] = Composer_DefaultEmptyRecord[16 + i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[640 + i] = Composer_DefaultUserBankNames[i];
	for (i = 0; i < 12; i++)
		if (MSP_SETTINGS[32 + i * 16] == 0)
			for (j = 0; j < 16; j++) MSP_SETTINGS[32 + i * 16 + j] = Composer_DefaultEmptyRecord[j];
}

/* cc900-name: ExtData_ToneParamMC_Helper2=ExtData_ToneParam_MultiChannel_Helper2 (the label shares its first 31
   characters with ExtData_ToneParam_MultiChannel_Data, which is therefore reached as SplitPoint_LedMaskByPreset - 4) */
void ExtData_ToneParamMC_Helper2(void)
{
	unsigned char *a, *b;

	if (EXTDATA_MASK == 0) return;
	a = (unsigned char *)0x915f;
	b = (unsigned char *)0x9161;
	a[EXTDATA_TLV_OFFSET] |= EXTDATA_VALUE & EXTDATA_MASK;
	b[EXTDATA_TLV_OFFSET] &= ~EXTDATA_MASK;
	b[EXTDATA_TLV_OFFSET] |= EXTDATA_VALUE & EXTDATA_MASK;
	if (b[0] == 0 && b[1] == 0) { a[0] = 0; a[1] = 0; return; }
	if ((a[0] & 3) == 0 && !(b[0] & 2)) return;
	PANEL_CONDUCTOR[0] = (SplitPoint_LedMaskByPreset - 4)[a[0] & 3];
	if ((PANEL_CONDUCTOR[1] << 8) + PANEL_CONDUCTOR[0] != ram_9163) ram_90f9 |= 1;
}

unsigned int BmDrEdit_FindNoteInSlots(void)
{
	unsigned int n, i, o;
	unsigned char f;

	n = 8;
	if (ram_2742 & 1) n = 1;
	i = 0;
	if (n == 0) return 0xff;
	do {
		o = i * 3;
		f = ram_2746[o];
		if (f & 0x80) {
			if (ram_2746[1 + o] == ram_2960) {
				ram_2746[o] = f & ~0x80;
				return ram_2746[1 + o];
			}
		}
		i++;
	} while (i < n);
	return 0xff;
}

void BitMapOut_PrepareRenderState(void)
{
	unsigned int i;
	unsigned char *buf, *p, *q;
	unsigned char w, c;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	buf = ram_bf39;
	p = PANEL_STYLE + 4;
	q = PANEL_RECALL_BACKUP + ((unsigned long)p - 0xf9a0);
	w = *q & 0x40;
	if ((*p & 0x40) != w) {
		buf[i++] = 0x48;
		buf[i++] = 4;
		buf[i++] = *p & 0x40;
		buf[i++] = 0x40;
	}
	buf[i] = 0xff;
	ram_90e2 = i;
	c = *q;
	c &= ~0x40;
	*q = c;
	c |= *p & 0x40;
	*q = c;
}

void BitMapOut_CalcDisplayMetrics(void)
{
	unsigned int i;
	unsigned char *buf, *p, *q;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	buf = ram_bf39;
	p = PANEL_PLAY_SETTINGS + 3;
	q = PANEL_RECALL_BACKUP + ((unsigned long)p - 0xf9a0);
	if (*p != *q) {
		buf[i++] = 0x70;
		buf[i++] = 3;
		buf[i++] = *p;
		buf[i++] = 0xff;
	}
	buf[i] = 0xff;
	ram_90e2 = i;
	*q = *p;
}

/* ---- new functions of the pool ---- */

int CPanel_CheckSpecialCombos(void)
{
	if (ram_8e5e == 108) return 3;
	if (ram_8e4b == 112) return 2;
	if (ram_8e60 == 56) return 1;
	if (ram_8e50 == 15) return 4;
	return 0;
}

char *StyleName_FindOverride_C2C5(int key)
{
	unsigned int i;

	i = 0;
	do {
		if (key == StyleNameOverride_C2C5[i].key) return StyleNameOverride_C2C5[i].name;
		i++;
	} while (i < 22);
	return (char *)0xffffffffL;
}

char *StyleName_FindOverride_Default(int key)
{
	unsigned int i;

	i = 0;
	do {
		if (key == StyleNameOverride_Default[i].key) return StyleNameOverride_Default[i].name;
		i++;
	} while (i < 5);
	return (char *)0xffffffffL;
}

void DrawRing_Init(void)
{
	int *p;
	unsigned char *q;

	p = ram_3247c;
	p[-5] = 0;
	p[-4] = 0;
	p[-2] = 0;
	p[-3] = 0;
	p[-1] = 0x7f;
	q = DRAW_QUEUE;
	ram_32466 = q;
	DRAW_QUEUE_WRITE_PTR = q;
}

void AudioInit_CheckMIDIStatus(void)
{
	if (ram_7f0b != 0) {
		AUDIO_STATE[123] = 0;
		AUDIO_STATE[124] = 255;
	} else {
		AUDIO_STATE[123] = 255;
		AUDIO_STATE[124] = 255;
	}
	AUDIO_STATE_CHANGES |= 32;
}

void GetBoxCenter(struct box *b, struct pt *c)
{
	c->x = b->x0 + (b->x1 - b->x0 + 1) / 2;
	c->y = b->y0 + (b->y1 - b->y0 + 1) / 2;
}

int PanelTlv_Rule_ResetOutsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char *p;
	unsigned char m;

	p = rec + r[1];
	m = r[2];
	if (r[3] <= (m & *p) && r[4] >= (m & *p)) return 6;
	*p &= ~m;
	*p |= r[5];
	return 6;
}

int PanelTlv_Rule_ResetInsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char *p;
	unsigned char m;

	p = rec + r[1];
	m = r[2];
	if (r[3] > (m & *p) || r[4] < (m & *p)) return 6;
	*p &= ~m;
	*p |= r[5];
	return 6;
}

int CtrlPanel_GetSelectionState(void)
{
	if (TITLE_FLAGS_LATCHED & 1) return 1;
	if ((TITLE_FLAGS_LATCHED & 2) && !(TITLE_FLAGS_LATCHED & 0x18)) return 2;
	return 0;
}

void SndParam_ClearHashTable(void)
{
	int i;

	for (i = 0; i < 2047; i++) ram_97d8[i] = 0;
	for (i = 0; i < 16384; i++) ram_380f8.data[i] = 0;
	ram_380f8.count = 0;
}
