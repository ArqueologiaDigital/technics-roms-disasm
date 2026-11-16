/* Phase 6, lane_p6 helper D, round 1, form b: the functions of p6_D_1a.c under the same names, with other types /
   shapes (index loops instead of pointer loops, swapped compare operands, switch tails, goto exits).
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label). */

typedef unsigned char *ucp;

struct fdlay { unsigned int x, y; };
struct res12 { long a; char *p; long c; };
struct gate { unsigned char *p; unsigned char mask, val; };
struct pkt { unsigned char pad[12]; unsigned char g1, g2; };
struct mode_ent { long func; long a; int b; char *name; };
struct sram_rgn { volatile unsigned char *start; unsigned long size; unsigned char flag, pad; };
struct blk50 { unsigned int head; unsigned int e[50]; };
struct rec256 { unsigned char pad[3]; unsigned char lo, hi; unsigned char rest[251]; };
struct slot3 { unsigned char f, note, x; };
struct ps { unsigned char f, g; };
struct pair { unsigned char a, b; };

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
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern struct slot3 __near ram_2746[];
extern unsigned char __near ram_27a4[];
extern unsigned int __near ram_279e;
extern unsigned int __near ram_27ce;
extern unsigned int __near ram_27d0;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2782;
extern unsigned int __near ram_27b2;
extern unsigned int __near ram_2744;
extern unsigned int ram_210a6, ram_210a4;
extern struct pair WidgetData_DrawbarPositionTable[];
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
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near PANEL_MIDI[];
extern unsigned int __near AUDIO_STATE_CHANGES;
extern unsigned int __near AUDIO_CONFIG_UPDATE;
extern unsigned char __near ram_68d;
extern unsigned char __near ram_68e;
extern unsigned char __near ram_68f;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near ram_90f9;
extern unsigned int __near ram_9163;
extern unsigned char ExtData_ToneParam_MultiChannel_Data[];
extern void *DspFxRecListPtrTable[];
extern char ram_3c224[];
extern unsigned int ram_3c284[];
extern unsigned int __near ram_90e2;
extern unsigned char __near ram_bf39[];
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
extern struct sram_rgn SramTest_IC21Regions[];
extern char Mode_UnregisteredName[];
extern struct mode_ent ram_328fc[];
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern long ram_25b40[];
extern unsigned int ram_25b3e, ram_25b60, ram_25b62[], ram_25b72;
extern struct fdlay ram_25b3a;
extern unsigned char ram_25b74[], ram_251da[][40];
extern char *ram_24fd8[];
extern struct gate MidiCtl_GateRecords[], MidiCtl_SecondGateRecords[];
extern unsigned char CType_ClassTable[];

void BmDrEdit_CalcSongPosition(void);

void ToneData_SetupCopyPointers(void)
{
	int i, j;

	for (i = 0; i < 512; i++) MSP_SETTINGS[256 + i] = 0;
	for (i = 0; i < 6; i++) MSP_SETTINGS[i] = Composer_SettingsBlock[i];
	for (i = 0; i < 16; i++) MSP_SETTINGS[16 + i] = Composer_DefaultHeaderFields[i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[512 + i] = MSP_Default_PartBankMap[i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[576 + i] = Composer_DefaultCompileBankNames[i];
	for (i = 0; i < 64; i++) MSP_SETTINGS[640 + i] = Composer_DefaultUserBankNames[i];
	for (i = 0; i < 12; i++)
		if (MSP_SETTINGS[32 + i * 16] == 0)
			for (j = 0; j < 16; j++) MSP_SETTINGS[32 + i * 16 + j] = Composer_DefaultEmptyRecord[j];
}

void Flash_InitExtMemAddrs(void)
{
	unsigned char *p = (unsigned char *)0x300000;

	FLASH_SECTION_PTR_0 = p;
	FLASH_SECTION_PTR_1 = p + 0x19800;
	FLASH_SECTION_PTR_2 = p + 0x30000;
	FLASH_SECTION_PTR_3 = p + 0x49800;
	FLASH_SECTION_PTR_4 = p + 0x60000;
	FLASH_SECTION_PTR_5 = p + 0x79800;
	FLASH_SECTION_PTR_6 = p + 0x90000;
	FLASH_SECTION_PTR_7 = p + 0xb0000;
	RHYTHM_PATTERN_BUF_PTR = RHYTHM_PATTERN_BUF_A;
	FLASH_SECTOR_IMAGE_PTR = STYLE_WORK_IMAGE_PTR = (unsigned char *)0x69800;
}

void AccPatch_ResetSectionPartByte2Defaults(void)
{
	unsigned char i;
	int o;

	for (i = 0, o = 0; i < 30; i++, o += 96) {
		(RHYTHM_PATTERN_BUF_PTR + (o + 96))[34] = 64;
		(RHYTHM_PATTERN_BUF_PTR + (o + 96))[42] = 12;
		(RHYTHM_PATTERN_BUF_PTR + (o + 96))[50] = 116;
		(RHYTHM_PATTERN_BUF_PTR + (o + 96))[58] = 64;
	}
}

void Flash_InitBytecodeBlock_Helper4_Helper2(void)
{
	struct blk50 *p = (struct blk50 *)0xb9c;
	unsigned char i;

	p->head = 0xffff;
	i = 0;
	do { p->e[i] = 0xffff; i++; } while (i < 50);
}

unsigned char Flash_CountFreeOrOwnedSlots(unsigned char mode, unsigned char owner)
{
	unsigned char n, i;
	unsigned char *p;

	n = 0;
	p = FLASH_SECTION_PTR_7;
	if (mode == 0) {
		for (i = 0; i < 40; i++) if (p[i + 16] == 0 || p[i + 16] == owner) n++;
	} else {
		for (i = 0; i < 4; i++) if (p[i + 80] == 0 || p[i + 80] == owner) n++;
	}
	return n;
}

unsigned char FDC_ValidateOpcode(void)
{
	switch (FDC_CMD_OPCODE) {
	case 79: case 51: case 52: case 71: case 53:
		return 0;
	}
	switch (FDC_CMD_OPCODE & 31) {
	case 30: case 29: case 25:
		return 0;
	case 16:
		return 1;
	case 17:
		return 0;
	}
	if ((FDC_CMD_OPCODE & 31) > 15 || (FDC_CMD_OPCODE & 31) < 2) return 1;
	return 0;
}

int FDC_DRIVE_DETECT(void)
{
	if (FDC_REQ_TRACK == 0 && FDC_REQ_HEAD == 0 && FDC_COMMAND_INDEX == 3 && FDC_REQ_COUNT == 1
	    && FDC_PROBE_FLAG == 0xffff && (FDC_REQ_SECTOR == 2 || FDC_REQ_SECTOR == 255))
		return -1;
	return 0;
}

int FDC_DETECT_CHECK(void)
{
	if (FDC_REQ_TRACK == 0 && FDC_REQ_HEAD == 0 && FDC_COMMAND_INDEX == 3 && FDC_REQ_COUNT == 1
	    && FDC_PROBE_FLAG == 0xffff && FDC_REQ_SECTOR == 1)
		return -1;
	return 0;
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

void BmDrEdit_SetupScrollRegion(unsigned char *a, unsigned char *b)
{
	if (ram_2742 & 1) {
		*a = ram_279e;
		*b = ram_279e;
		*b += 11;
	} else {
		*a = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY].a;
		*b = WidgetData_DrawbarPositionTable[NOTEEDIT_BASE_KEY].b;
	}
}

void BmDrEdit_AdvanceStreamPos(void)
{
	struct rec256 *r;

	if (ram_210a6 < 0xff) { ram_210a6++; return; }
	r = (struct rec256 *)0xb0000 + (ram_210a4 - 1);
	ram_210a4 = (r->hi << 8) + r->lo;
	ram_210a6 = 5;
}

void BmDrEdit_ClampScrollPos(void)
{
	unsigned int m;

	m = ram_2774 * 96 - 1;
	if (ram_27ce + ram_27d0 > m) ram_27d0 = m - ram_27ce;
}

unsigned int BmDrEdit_FindNoteInSlots(void)
{
	unsigned int n, i;

	n = 8;
	if (ram_2742 & 1) n = 1;
	for (i = 0; i < n; i++) {
		if ((ram_2746[i].f & 0x80) && ram_2746[i].note == ram_2960) {
			ram_2746[i].f &= 0x7f;
			return ram_2746[i].note;
		}
	}
	return 0xff;
}

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int i;

	ram_25d8 = 0;
	ram_2772 = ram_279a / 96;
	if (ram_2772 != 0) {
		i = 1;
		ram_25d8 = 1;
		for (;;) {
			if (ram_27a4[i] != 0) ram_25d8 = 0;
			i++;
			ram_2772--;
			if (ram_2772 == 0) break;
			ram_25d8++;
		}
	}
	ram_2782 = ram_25d8;
	ram_2784 = ram_279a % 96;
	BmDrEdit_CalcSongPosition();
}

void BmDrEdit_CalcSongPosition(void)
{
	unsigned int i;

	ram_25d8 = 0;
	ram_2772 = ram_279a / 96;
	if (ram_2772 != 0) {
		i = 1;
		ram_25d8 = 0;
		do {
			if (ram_27a4[i] != 0) ram_25d8++;
			i++;
			ram_2772--;
		} while (ram_2772 != 0);
	}
	ram_2744 = ram_27b2 + ram_25d8;
}

void AudioMode_MergeOutputBits(void)
{
	ram_3310 = (ram_32f9 & 7) | (ram_3310 & 0xf8);
}

void AccentVoice_DetectAndMarkChange(void)
{
	if (ram_3306 == ACC_VARIATION_REQUEST) goto upd;
	if ((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & 0x3f) goto upd;
	if (ACC_STYLE_NUMBER >= 240) goto upd;
	if (ACC_STYLE_NUMBER >= 128) goto upd;
	if ((ACC_STYLE_ARRANGER_ON & 1) && ((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2) & 0x3f)) goto upd;
	if ((ACC_VARIATION_REQUEST & 3) != ram_3338) ACC_VARIATION_CHANGE_PENDING |= 1;
upd:
	ACC_VARIATION_NEXT = ACC_VARIATION_REQUEST & 3;
}

void AudioInit_SelectPriority(void)
{
	switch (CMP_RECORD_PART) {
	case 1:
		AUDIO_STATE[84] = 0; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 2:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 1; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 4:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 2; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	case 8:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 3; AUDIO_STATE[88] = 255;
		break;
	case 16:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 4;
		break;
	default:
		AUDIO_STATE[84] = 255; AUDIO_STATE[85] = 255; AUDIO_STATE[86] = 255; AUDIO_STATE[87] = 255; AUDIO_STATE[88] = 255;
		break;
	}
	AUDIO_STATE_CHANGES |= 16;
}

void AudioInit_ClearPartFlags_ByMode(void)
{
	unsigned int i;

	if (AUDIO_CONFIG_UPDATE & 3) {
		for (i = 0; i < 26; i++) {
			((struct ps *)(AUDIO_STATE + 292))[i].f &= ~0x20;
			AUDIO_STATE_CHANGES |= 8;
		}
		return;
	}
	for (i = 0; i < 16; i++) ((struct ps *)(AUDIO_STATE + 292))[i].f |= 0x20;
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

void SeMenu_SetupPartDisplay(unsigned char m, unsigned char *s, unsigned char n)
{
	unsigned char i;

	if (m == 1) {
		for (i = 0; i < n; i++) ((unsigned char *)0x20bf3)[i] = s[i];
	} else if (m == 2) {
		for (i = 0; i < n; i++) ((unsigned char *)0x20c03)[i] = s[i];
	} else if (m == 3) {
		for (i = 0; i < n; i++) ((unsigned char *)0x20c13)[i] = s[i];
	} else if (m == 4) {
		for (i = 0; i < n; i++) ((unsigned char *)0x20c23)[i] = s[i];
	}
}

void SeMenu_SetupPartDisplay_End(unsigned char m, unsigned char *d, unsigned char n)
{
	unsigned char i;

	if (m == 1) {
		for (i = 0; i < n; i++) d[i] = ((unsigned char *)0x20bf3)[i];
	} else if (m == 2) {
		for (i = 0; i < n; i++) d[i] = ((unsigned char *)0x20c03)[i];
	} else if (m == 3) {
		for (i = 0; i < n; i++) d[i] = ((unsigned char *)0x20c13)[i];
	} else if (m == 4) {
		for (i = 0; i < n; i++) d[i] = ((unsigned char *)0x20c23)[i];
	}
}

void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out)
{
	if (m == 1) {
		if (ram_68e == 0 || ram_68e > 4) ram_68e = 1;
		*out = ram_68e;
	} else if (m == 0) {
		if (ram_68d == 0 || ram_68d > 4) ram_68d = 1;
		*out = ram_68d;
	} else if (m == 2) {
		if (ram_68f == 0 || ram_68f > 4) ram_68f = 1;
		*out = ram_68f;
	} else {
		*out = 1;
	}
}

/* cc900-name: ExtData_ToneParamMC_Helper2=ExtData_ToneParam_MultiChannel_Helper2 (the label shares its first 31
   characters with ExtData_ToneParam_MultiChannel_Data) */
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
	PANEL_CONDUCTOR[0] = ExtData_ToneParam_MultiChannel_Data[a[0] & 3];
	if ((PANEL_CONDUCTOR[1] << 8) + PANEL_CONDUCTOR[0] != ram_9163) ram_90f9 |= 1;
}

int DSPCfg_ValidateSlotForWrite(unsigned int a, int s)
{
	if (a > 0x63) goto bad;
	if (DspFxRecListPtrTable[a] == 0) goto bad;
	switch (s) {
	case 0:
		if (a < 0x10 || a > 0x1b) goto ok;
		break;
	case 1:
		if (a == 9 || a == 10) goto ok;
		if (a < 0x10 || a > 0x1b) break;
		goto ok;
	case 2:
		if (a < 0x39 || a > 0x3c) break;
		goto ok;
	case 3:
		if (a < 0x58 || a > 0x5b) break;
		goto ok;
	case 4:
		if (a != 0x4f) break;
		goto ok;
	}
bad:
	return -1;
ok:
	return 0;
}

void __cdecl Sprintf_MultiplyDigitsByTen(unsigned int *p)
{
	int i, j;

	for (i = 0; i < 16; i++) {
		p[i] *= 10;
		if (i != 0) {
			j = i;
			while (j > 0 && p[j] > 0xff) {
				p[j - 1] += p[j] >> 8;
				p[j] &= 0xff;
				j--;
			}
		}
	}
	if (p[15] & 0x80) p[14]++;
	p[15] = 0;
}

void __cdecl Sprintf_MultiplyBCDByTen(void)
{
	unsigned int *p, *e;
	int i;

	p = ram_3c284; e = p + 10;
	do { if (*p != 0) *p *= 10; p++; } while (p < e);
	for (i = 9; i > 0; i--)
		if (ram_3c284[i] > 0xff) {
			ram_3c284[i - 1] += ram_3c284[i] >> 8;
			ram_3c284[i] &= 0xff;
		}
}

void __cdecl Sprintf_InsertCarry(int v, int pos)
{
	if (pos < 32) ram_3c224[pos] += (char)v;
	while (pos >= 32) pos--;
	while (ram_3c224[pos] >= 10 && pos > 0) {
		ram_3c224[pos - 1]++;
		ram_3c224[pos] -= 10;
		pos--;
	}
}

void BitMapOut_PrepareRenderState(void)
{
	unsigned int i;
	unsigned char *p, *q;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	p = PANEL_STYLE + 4;
	q = PANEL_RECALL_BACKUP + (p - (unsigned char *)0xf9a0);
	if ((*q & 0x40) != (*p & 0x40)) {
		ram_bf39[i++] = 0x48;
		ram_bf39[i++] = 4;
		ram_bf39[i++] = *p & 0x40;
		ram_bf39[i++] = 0x40;
	}
	ram_bf39[i] = 0xff;
	ram_90e2 = i;
	*q = (*q & ~0x40) | (*p & 0x40);
}

void BitMapOut_CalcDisplayMetrics(void)
{
	unsigned int i;
	unsigned char *p, *q;

	i = ram_90e2;
	if (0x100 - i <= 8) return;
	p = PANEL_PLAY_SETTINGS + 3;
	q = PANEL_RECALL_BACKUP + (p - (unsigned char *)0xf9a0);
	if (*q != *p) {
		ram_bf39[i++] = 0x70;
		ram_bf39[i++] = 3;
		ram_bf39[i++] = *p;
		ram_bf39[i++] = 0xff;
	}
	ram_bf39[i] = 0xff;
	ram_90e2 = i;
	*q = *p;
}

int Test_SRAM_IC21(unsigned char r)
{
	unsigned char k, w;
	volatile unsigned char *p;
	unsigned long n;

	for (k = 0; k < 1; k++) {
		p = SramTest_IC21Regions[k].start;
		for (n = SramTest_IC21Regions[k].size >> 1; n != 0; n--) {
			w = *p;
			*p = 0x5a;
			if (*p != 0x5a) r |= SramTest_IC21Regions[k].flag;
			*p++ = w;
			w = *p;
			*p = 0xa5;
			if (*p != 0xa5) r |= SramTest_IC21Regions[k].flag;
			*p++ = w;
		}
	}
	return r;
}

void RegisterMode(long id, long func, long a, int b, char *name)
{
	ram_328fc[id].func = func;
	ram_328fc[id].a = a;
	ram_328fc[id].b = b;
	ram_328fc[id].name = name;
}

void UnregisteredMode(long id)
{
	ram_328fc[id].func = 0x1200000;
	ram_328fc[id].a = -1;
	ram_328fc[id].b = -1;
	ram_328fc[id].name = Mode_UnregisteredName;
}

void FDemoText_ResetLayoutState(void)
{
	int i, j;

	for (i = 0; i < 60; i++)
		for (j = 0; j < 40; j++) ram_251da[i][j] = 84;
	ram_25b3a.x = 0;
	ram_25b3a.y = 0;
	ram_25b3e = 0;
	ram_25b60 = 0;
	ram_25b72 = 0;
	for (i = 0; i < 8; i++) {
		ram_25b40[i] = 5;
		ram_25b62[i] = 0xff;
		ram_25b74[i] = 1;
	}
}

void Seq_CopyResourcePtrs(int n)
{
	int i;

	for (i = 0; i < 128; i++) ram_24fd8[i] = Seq_CopyResourcePtrs_Str_Empty;
	if (n < 18 || n > 18) ram_249cc = ram_249d0;
	else ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	ram_249d4 = ram_249cc;
}

int MidiPkt_CheckGateCondition(struct pkt *k)
{
	struct gate *g;

	if (k->g1 != 0) {
		g = &MidiCtl_GateRecords[k->g1];
		if (g->val != (g->mask & *g->p)) return -1;
	}
	if (k->g2 != 0) {
		g = &MidiCtl_SecondGateRecords[k->g2];
		if (g->val == (g->mask & *g->p)) return 0;
		return -1;
	}
	return 0;
}

void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;

	name[len] = 0;
	for (i = 0; i < 8 && name[i] != 0; i++)
		if ((CType_ClassTable[name[i]] & 7) == 0) name[i] = 0x5f;
	for (; i < 8; i++) name[i] = 0x5f;
}
