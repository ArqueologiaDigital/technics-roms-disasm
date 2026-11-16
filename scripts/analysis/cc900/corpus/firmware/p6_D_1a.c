/* Phase 6, lane_p6 helper D, round 1, form a: leaf functions of v10 storage/flash_floppy_handlers.s,
   storage/fdc_routines.s, sequencer/bmdredit_routines.s, sequencer/seq_audio_mode.s, audio/audioinit_routines.s,
   audio/semenu_routines.s, audio/audio_control_engine.s, audio/dsp_config_sysex.s, audio/sprintf_core.s,
   ui/bitmap_out_routines.s, ui/ui_widget_defs.s, ui/ui_mode_handlers.s, demo/fdemotext_routines.s,
   midi/midipkt_routines.s and file_io/smf_operations.s, each under its firmware name.
   Guesses for V4.23; form b (p6_D_1b.c) has the same names with other types / shapes.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label). */

typedef unsigned char *ucp;

struct sec96 { unsigned char pad[34]; unsigned char b0; unsigned char p1[7]; unsigned char b1; unsigned char p2[7];
	unsigned char b2; unsigned char p3[7]; unsigned char b3; unsigned char rest[37]; };
struct fdlay { unsigned int x, y; };
struct res12 { long a; char *p; long c; };
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct mode_ent { long func; long a; int b; char *name; };
struct sram_rgn { volatile unsigned char *start; unsigned long size; unsigned char flag, pad; };

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
extern unsigned char RHYTHM_PATTERN_BUF_A[];
extern unsigned char Composer_SettingsBlock[], Composer_DefaultHeaderFields[], MSP_Default_PartBankMap[];
extern unsigned char Composer_DefaultCompileBankNames[], Composer_DefaultUserBankNames[], Composer_DefaultEmptyRecord[];
/* storage/fdc_routines.s */
extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near ram_8b00;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_PROBE_FLAG;
extern unsigned int __near FDC_REQ_SECTOR;
extern unsigned char FDC_Set_Status(int);
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
extern unsigned char WidgetData_DrawbarPositionTable[];
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
extern unsigned char __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
/* audio/audioinit_routines.s */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near PANEL_MIDI[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned int __near AUDIO_CONFIG_UPDATE;
/* audio/semenu_routines.s */
extern unsigned char __near ram_68d;
extern unsigned char __near ram_68e;
extern unsigned char __near ram_68f;
/* audio/audio_control_engine.s */
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near ram_90f9;
extern unsigned int __near ram_9163;
extern unsigned char ExtData_ToneParam_MultiChannel_Data[];
/* audio/dsp_config_sysex.s */
extern void *DspFxRecListPtrTable[];
/* audio/sprintf_core.s */
extern char ram_3c224[];
extern unsigned int ram_3c284[];
/* ui/bitmap_out_routines.s */
extern unsigned int __near ram_90e2;
extern unsigned char __near ram_bf39[];
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
/* ui/ui_mode_handlers.s */
extern struct sram_rgn SramTest_IC21Regions[];
/* ui/ui_widget_defs.s */
extern char Mode_UnregisteredName[];
/* demo/fdemotext_routines.s */
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
/* midi/midipkt_routines.s */
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
/* file_io/smf_operations.s */
extern unsigned char CType_ClassTable[];

void BmDrEdit_CalcSongPosition(void);

/* ---- storage/flash_floppy_handlers.s ---- */

void ToneData_SetupCopyPointers(void)
{
	unsigned char *d, *s, *e, *p;
	unsigned long o;

	d = MSP_SETTINGS + 256; e = d + 512;
	do *d++ = 0; while (d < e);
	s = Composer_SettingsBlock; d = MSP_SETTINGS; e = s + 6;
	do *d++ = *s++; while (s < e);
	s = Composer_DefaultHeaderFields; d = MSP_SETTINGS + 16; e = s + 16;
	do *d++ = *s++; while (s < e);
	s = MSP_Default_PartBankMap; d = MSP_SETTINGS + 512; e = s + 64;
	do *d++ = *s++; while (s < e);
	s = Composer_DefaultCompileBankNames; d = MSP_SETTINGS + 576; e = s + 64;
	do *d++ = *s++; while (s < e);
	s = Composer_DefaultUserBankNames; d = MSP_SETTINGS + 640; e = s + 64;
	do *d++ = *s++; while (s < e);
	p = MSP_SETTINGS + 32; o = 0;
	do {
		if (*p == 0) {
			s = Composer_DefaultEmptyRecord; d = MSP_SETTINGS + 32 + o; e = s + 16;
			do *d++ = *s++; while (s < e);
		}
		o += 16; p += 16;
	} while (o < 0xc0);
}

void Flash_InitExtMemAddrs(void)
{
	unsigned char *p = (unsigned char *)0x300000;
	unsigned char *w;

	FLASH_SECTION_PTR_0 = p;
	FLASH_SECTION_PTR_1 = p + 0x19800;
	FLASH_SECTION_PTR_2 = p + 0x30000;
	FLASH_SECTION_PTR_3 = p + 0x49800;
	FLASH_SECTION_PTR_4 = p + 0x60000;
	FLASH_SECTION_PTR_5 = p + 0x79800;
	FLASH_SECTION_PTR_6 = p + 0x90000;
	FLASH_SECTION_PTR_7 = p + 0xb0000;
	RHYTHM_PATTERN_BUF_PTR = RHYTHM_PATTERN_BUF_A;
	w = (unsigned char *)0x69800;
	STYLE_WORK_IMAGE_PTR = w;
	FLASH_SECTOR_IMAGE_PTR = w;
}

void AccPatch_ResetSectionPartByte2Defaults(void)
{
	unsigned char i;
	int o, j;

	i = 0; o = 0;
	do {
		j = o + 96;
		((struct sec96 *)(RHYTHM_PATTERN_BUF_PTR + j))->b0 = 64;
		((struct sec96 *)(RHYTHM_PATTERN_BUF_PTR + j))->b1 = 12;
		((struct sec96 *)(RHYTHM_PATTERN_BUF_PTR + j))->b2 = 116;
		((struct sec96 *)(RHYTHM_PATTERN_BUF_PTR + j))->b3 = 64;
		i++; o += 96;
	} while (i < 30);
}

void Flash_InitBytecodeBlock_Helper4_Helper2(void)
{
	unsigned int *p = (unsigned int *)0xb9c;
	unsigned char i;

	*p = 0xffff;
	for (i = 0; i < 50; i++) p[i + 1] = 0xffff;
}

unsigned char Flash_CountFreeOrOwnedSlots(unsigned char mode, unsigned char owner)
{
	unsigned char n, i, h;
	unsigned char *p;

	n = 0; p = FLASH_SECTION_PTR_7; i = 0;
	if (mode == 0) {
		do { h = p[i + 16]; if (h == 0 || h == owner) n++; i++; } while (i < 40);
	} else {
		do { h = p[i + 80]; if (h == 0 || h == owner) n++; i++; } while (i < 4);
	}
	return n;
}

/* ---- storage/fdc_routines.s ---- */

unsigned char FDC_ValidateOpcode(void)
{
	unsigned char c;

	if (FDC_CMD_OPCODE == 79 || FDC_CMD_OPCODE == 51 || FDC_CMD_OPCODE == 52 || FDC_CMD_OPCODE == 71
	    || FDC_CMD_OPCODE == 53)
		return 0;
	c = FDC_CMD_OPCODE & 31;
	if (c == 30 || c == 29 || c == 25) return 0;
	if (c == 16) return 1;
	if (c == 17) return 0;
	if (c > 15 || c < 2) return 1;
	return 0;
}

int FDC_DRIVE_DETECT(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	if (FDC_REQ_SECTOR == 2 || FDC_REQ_SECTOR == 255) return -1;
	return 0;
}

int FDC_DETECT_CHECK(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	if (FDC_REQ_SECTOR == 1) return -1;
	return 0;
}

unsigned char FDC_Exception_Status_Decoder(void)
{
	unsigned char *r = FDC_RESULT;
	unsigned char c = r[1];

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
		c = r[2];
		if (c & 1) return FDC_Set_Status(0x35);
		if (c & 2) return FDC_Set_Status(0x2f);
		if (c & 4) return FDC_Set_Status(0x33);
		if (c & 0x10) return FDC_Set_Status(0x34);
		if (c & 0x20) return FDC_Set_Status(0x36);
		if (c & 0x80) return FDC_Set_Status(0x37);
		return FDC_Set_Status(8);
	}
	return 8;
}

/* ---- sequencer/bmdredit_routines.s ---- */

void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
		return;
	}
	*a = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY * 2];
	*b = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY * 2 + 1];
}

void BmDrEdit_AdvanceStreamPos(void)
{
	unsigned int p;
	unsigned char *b;
	unsigned long o;

	p = ram_210a6;
	if (p < 0xff) { ram_210a6 = p + 1; return; }
	o = (unsigned long)(ram_210a4 - 1) << 8;
	b = (unsigned char *)0xb0000;
	ram_210a4 = (b[o + 4] << 8) + b[o + 3];
	ram_210a6 = 5;
}

void BmDrEdit_ClampScrollPos(void)
{
	unsigned int m, s;

	m = ram_2774 * 96 - 1;
	s = ram_27ce;
	if (s + ram_27d0 <= m) return;
	ram_27d0 = m - s;
}

unsigned int BmDrEdit_FindNoteInSlots(void)
{
	unsigned int n, i, o;
	unsigned char f;

	n = 8;
	if (ram_2742 & 1) n = 1;
	i = 0;
	if (i < n) do {
		o = i * 3;
		f = ram_2746[o];
		if (f & 0x80) {
			if (ram_2746[o + 1] == ram_2960) {
				ram_2746[o] = f & ~0x80;
				return ram_2746[o + 1];
			}
		}
		i++;
	} while (i < n);
	return 0xff;
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
			if (--ram_2772 == 0) break;
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
		} while (--ram_2772 != 0);
	}
	ram_2744 = ram_27b2 + ram_25d8;
}

/* ---- sequencer/seq_audio_mode.s ---- */

void AudioMode_MergeOutputBits(void)
{
	ram_3310 = (ram_3310 & 0xf8) | (ram_32f9 & 7);
}

void AccentVoice_DetectAndMarkChange(void)
{
	if (ACC_VARIATION_REQUEST != ram_3306 && !((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & 0x3f)
	    && ACC_STYLE_NUMBER < 240 && ACC_STYLE_NUMBER < 128) {
		if (!(ACC_STYLE_ARRANGER_ON & 1) || !((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2) & 0x3f)) {
			if ((ACC_VARIATION_REQUEST & 3) != ram_3338) ACC_VARIATION_CHANGE_PENDING |= 1;
		}
	}
	ACC_VARIATION_NEXT = ACC_VARIATION_REQUEST & 3;
}

/* ---- audio/audioinit_routines.s ---- */

void AudioInit_SelectPriority(void)
{
	switch (CMP_RECORD_PART) {
	case 1:
		AUDIO_STATE[84] = 0; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 2:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 1; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 4:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 2; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 8:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 3; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	case 16:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 4;
		AUDIO_STATE_CHANGES |= 16;
		return;
	default:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		AUDIO_STATE_CHANGES |= 16;
		return;
	}
}

void AudioInit_ClearPartFlags_ByMode(void)
{
	unsigned int i;

	if (AUDIO_CONFIG_UPDATE & 3) {
		i = 0;
		if (i < 26) do {
			AUDIO_STATE[292 + i * 2] &= ~0x20;
			AUDIO_STATE_CHANGES |= 8;
			i++;
		} while (i < 26);
		return;
	}
	i = 0;
	if (i < 16) do {
		AUDIO_STATE[292 + i * 2] |= 0x20;
		i++;
	} while (i < 16);
	if (PANEL_MIDI[3] & 0x40) {
		AUDIO_STATE[324] |= 0x20; AUDIO_STATE[326] |= 0x20; AUDIO_STATE[328] |= 0x20; AUDIO_STATE[330] |= 0x20;
		AUDIO_STATE[334] |= 0x20;
	} else {
		AUDIO_STATE[324] &= ~0x20; AUDIO_STATE[326] &= ~0x20; AUDIO_STATE[328] &= ~0x20; AUDIO_STATE[330] &= ~0x20;
		AUDIO_STATE[334] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[0] & 0x40) {
		AUDIO_STATE[332] |= 0x20;
	} else {
		AUDIO_STATE[332] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
	if (PANEL_MIDI[3] & 0x80) {
		AUDIO_STATE[342] |= 0x20;
	} else {
		AUDIO_STATE[342] &= ~0x20;
		AUDIO_STATE_CHANGES |= 8;
	}
}

/* ---- audio/semenu_routines.s ---- */

void SeMenu_SetupPartDisplay(unsigned char m, unsigned char *s, unsigned char n)
{
	unsigned char i;

	if (m == 1) {
		i = 0;
		if (i < n) do { ((unsigned char *)0x20bf3)[i] = s[i]; i++; } while (i < n);
	} else if (m == 2) {
		i = 0;
		if (i < n) do { ((unsigned char *)0x20c03)[i] = s[i]; i++; } while (i < n);
	} else if (m == 3) {
		i = 0;
		if (i < n) do { ((unsigned char *)0x20c13)[i] = s[i]; i++; } while (i < n);
	} else if (m == 4) {
		i = 0;
		if (i < n) do { ((unsigned char *)0x20c23)[i] = s[i]; i++; } while (i < n);
	}
}

void SeMenu_SetupPartDisplay_End(unsigned char m, unsigned char *d, unsigned char n)
{
	unsigned char i;

	if (m == 1) {
		i = 0;
		if (i < n) do { d[i] = ((unsigned char *)0x20bf3)[i]; i++; } while (i < n);
	} else if (m == 2) {
		i = 0;
		if (i < n) do { d[i] = ((unsigned char *)0x20c03)[i]; i++; } while (i < n);
	} else if (m == 3) {
		i = 0;
		if (i < n) do { d[i] = ((unsigned char *)0x20c13)[i]; i++; } while (i < n);
	} else if (m == 4) {
		i = 0;
		if (i < n) do { d[i] = ((unsigned char *)0x20c23)[i]; i++; } while (i < n);
	}
}

void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out)
{
	unsigned char v;

	if (m == 1) {
		if (ram_68e < 1 || ram_68e > 4) ram_68e = 1;
		v = ram_68e;
	} else if (m == 0) {
		if (ram_68d < 1 || ram_68d > 4) ram_68d = 1;
		v = ram_68d;
	} else if (m == 2) {
		if (ram_68f < 1 || ram_68f > 4) ram_68f = 1;
		v = ram_68f;
	} else {
		v = 1;
	}
	*out = v;
}

/* ---- audio/audio_control_engine.s ---- */

/* cc900-name: ExtData_ToneParamMC_Helper2=ExtData_ToneParam_MultiChannel_Helper2 (the label shares its first 31
   characters with ExtData_ToneParam_MultiChannel_Data) */
void ExtData_ToneParamMC_Helper2(void)
{
	unsigned char *a, *b;
	unsigned char k;

	if (EXTDATA_MASK == 0) return;
	a = (unsigned char *)0x915f;
	b = (unsigned char *)0x9161;
	a[EXTDATA_TLV_OFFSET] |= EXTDATA_VALUE & EXTDATA_MASK;
	b[EXTDATA_TLV_OFFSET] &= ~EXTDATA_MASK;
	b[EXTDATA_TLV_OFFSET] |= EXTDATA_VALUE & EXTDATA_MASK;
	if (b[0] == 0 && b[1] == 0) { a[0] = 0; a[1] = 0; return; }
	k = a[0] & 3;
	if (k == 0 && !(b[0] & 2)) return;
	PANEL_CONDUCTOR[0] = ExtData_ToneParam_MultiChannel_Data[k];
	if (PANEL_CONDUCTOR[0] + (PANEL_CONDUCTOR[1] << 8) != ram_9163) ram_90f9 |= 1;
}

/* ---- audio/dsp_config_sysex.s ---- */

int DSPCfg_ValidateSlotForWrite(unsigned int a, int s)
{
	if (a > 0x63) return -1;
	if (DspFxRecListPtrTable[a] == 0) return -1;
	switch (s) {
	case 0:
		if (a >= 0x10 && a <= 0x1b) return -1;
		return 0;
	case 1:
		if (a == 9 || a == 10) return 0;
		if (a < 0x10 || a > 0x1b) return -1;
		return 0;
	case 2:
		if (a < 0x39 || a > 0x3c) return -1;
		return 0;
	case 3:
		if (a < 0x58 || a > 0x5b) return -1;
		return 0;
	case 4:
		if (a != 0x4f) return -1;
		return 0;
	}
	return -1;
}

/* ---- audio/sprintf_core.s (library, cdecl) ---- */

void __cdecl Sprintf_MultiplyDigitsByTen(unsigned int *p)
{
	int i, j;

	for (i = 0; i < 16; i++) {
		p[i] *= 10;
		if (i == 0) continue;
		for (j = i; j > 0 && p[j] > 0xff; j--) {
			p[j - 1] += p[j] >> 8;
			p[j] &= 0xff;
		}
	}
	if (p[15] & 0x80) p[14]++;
	p[15] = 0;
}

void __cdecl Sprintf_MultiplyBCDByTen(void)
{
	int i;

	for (i = 0; i < 10; i++)
		if (ram_3c284[i] != 0) ram_3c284[i] *= 10;
	for (i = 9; i > 0; i--)
		if (ram_3c284[i] >= 0x100) {
			ram_3c284[i - 1] += ram_3c284[i] >> 8;
			ram_3c284[i] &= 0xff;
		}
}

void __cdecl Sprintf_InsertCarry(int v, int pos)
{
	if (pos < 32) ram_3c224[pos] += v;
	while (pos >= 32) pos--;
	while (ram_3c224[pos] >= 10 && pos > 0) {
		ram_3c224[pos - 1]++;
		ram_3c224[pos--] -= 10;
	}
}

/* ---- ui/bitmap_out_routines.s ---- */

void BitMapOut_PrepareRenderState(void)
{
	unsigned int i;
	unsigned char *p, *q;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	p = PANEL_STYLE + 4;
	q = PANEL_RECALL_BACKUP + ((unsigned long)p - 0xf9a0);
	if ((*p & 0x40) != (*q & 0x40)) {
		ram_bf39[i++] = 0x48;
		ram_bf39[i++] = 4;
		ram_bf39[i++] = *p & 0x40;
		ram_bf39[i++] = 0x40;
	}
	ram_bf39[i] = 0xff;
	ram_90e2 = i;
	*q &= ~0x40;
	*q |= *p & 0x40;
}

void BitMapOut_CalcDisplayMetrics(void)
{
	unsigned int i;
	unsigned char *p, *q;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	p = PANEL_PLAY_SETTINGS + 3;
	q = PANEL_RECALL_BACKUP + ((unsigned long)p - 0xf9a0);
	if (*p != *q) {
		ram_bf39[i++] = 0x70;
		ram_bf39[i++] = 3;
		ram_bf39[i++] = *p;
		ram_bf39[i++] = 0xff;
	}
	ram_bf39[i] = 0xff;
	ram_90e2 = i;
	*q = *p;
}

/* ---- ui/ui_mode_handlers.s ---- */

int Test_SRAM_IC21(unsigned char r)
{
	unsigned char k, w;
	struct sram_rgn *g;
	volatile unsigned char *p;
	unsigned long n;

	k = 0;
	do {
		g = &SramTest_IC21Regions[k];
		p = g->start;
		n = g->size >> 1;
		if (n != 0) do {
			w = *p;
			*p = 0x5a;
			if (*p != 0x5a) r |= g->flag;
			*p++ = w;
			w = *p;
			*p = 0xa5;
			if (*p != 0xa5) r |= g->flag;
			*p++ = w;
		} while (--n != 0);
		k++;
	} while (k != 1);
	return r;
}

/* ---- ui/ui_widget_defs.s ---- */

void RegisterMode(long id, long func, long a, int b, char *name)
{
	struct mode_ent *e = (struct mode_ent *)0x328fc + id;

	e->func = func;
	e->a = a;
	e->b = b;
	e->name = name;
}

void UnregisteredMode(long id)
{
	struct mode_ent *e = (struct mode_ent *)0x328fc + id;

	e->func = 0x1200000;
	e->a = -1;
	e->b = -1;
	e->name = Mode_UnregisteredName;
}

/* ---- demo/fdemotext_routines.s ---- */

void FDemoText_ResetLayoutState(void)
{
	unsigned char *r, *re, *q, *qe, *c, *ce;
	long *a;
	unsigned int *b;
	struct fdlay *s;

	r = (unsigned char *)0x251da; re = r + 2400;
	do {
		q = r; qe = r + 40;
		do *q++ = 84; while (q < qe);
		r += 40;
	} while (r < re);
	s = (struct fdlay *)0x25b3a;
	s->x = 0;
	s->y = 0;
	*(unsigned int *)0x25b3e = 0;
	*(unsigned int *)0x25b60 = 0;
	*(unsigned int *)0x25b72 = 0;
	a = (long *)0x25b40; b = (unsigned int *)0x25b62; c = (unsigned char *)0x25b74; ce = c + 8;
	do { *a++ = 5; *b++ = 0xff; *c++ = 1; } while (c < ce);
}

void Seq_CopyResourcePtrs(int n)
{
	char **p, **e;
	char *s;

	p = (char **)0x24fd8; s = Seq_CopyResourcePtrs_Str_Empty; e = p + 127;
	do *p++ = s; while (p <= e);
	if (n >= 18 && n <= 18) ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	else ram_249cc = ram_249d0;
	ram_249d4 = ram_249cc;
}

/* ---- midi/midipkt_routines.s ---- */

int MidiPkt_CheckGateCondition(struct pkt *k)
{
	struct gate *g;

	if (k->g1 != 0) {
		g = &MidiCtl_GateRecords[k->g1];
		if ((*g->p & g->mask) != g->val) return -1;
	}
	if (k->g2 != 0) {
		g = &MidiCtl_SecondGateRecords[k->g2];
		if ((*g->p & g->mask) != g->val) return -1;
	}
	return 0;
}

/* ---- file_io/smf_operations.s ---- */

void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;

	name[len] = 0;
	for (i = 0; i < 8 && name[i] != 0; i++)
		if (!(CType_ClassTable[name[i]] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}
