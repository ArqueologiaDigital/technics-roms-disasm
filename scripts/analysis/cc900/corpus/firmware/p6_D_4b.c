/* Phase 6, lane_p6 helper D, round 4, form b: new leaf functions of the pool (and two single-spot refinements of
   round 3), each under its firmware name (or a short C name with a cc900-name comment).
   Form a (p6_D_4a.c) has the same names; this file holds the alternatives (identical where only one form was guessed).
   __near: the ROM reaches the cell with a 16-bit absolute operand; __tiny: 8-bit; plain: 24-bit (or a ROM label).
   One declarator per __near / __tiny declaration.  V4.23 allocates unsigned char bitfields from bit 7 down. */

struct hpb { unsigned char pad[8]; unsigned char f8 : 8; unsigned char r9 : 7; unsigned char b9 : 1; };
struct song { unsigned char pad[0x1c]; unsigned int v; unsigned char rest[2018]; };
struct eo { unsigned int h0, h1; struct { unsigned int x, y; } e[50]; };
struct mprec { unsigned char pad[7]; unsigned char b7, b8; };
struct mpkt { unsigned char b0, b1, b2, b3; };
struct fs { unsigned int w, h; long x; };
struct pt { int x, y; };

typedef unsigned char *ucp;

/* display/graphics_text_vga.s */
extern unsigned char Text_CharGlyphMap[];
/* ui/ui_mode_handlers.s */
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near PLAY_TRANSPORT_STATE;
/* file_io/medley.s */
extern struct song SEQ_SONG_SLOTS[];
extern struct song SEQ_SONG_RECORD;
extern unsigned char SEQ_CURRENT_SONG;
/* kn5000_v10_program.s, storage/fdc_routines.s: SFRs */
extern unsigned char __tiny INTE0AD;
extern unsigned char __tiny INTE45;
extern unsigned char __tiny INTE67;
extern unsigned char __tiny INTE89;
extern unsigned char __tiny INTEAB;
extern unsigned char __tiny INTET01;
extern unsigned char __tiny INTET23;
extern unsigned char __tiny INTET45;
extern unsigned char __tiny INTET67;
extern unsigned char __tiny INTET89;
extern unsigned char __tiny INTETAB;
extern unsigned char __tiny INTES0;
extern unsigned char __tiny INTES1;
extern unsigned char __tiny INTETC01;
extern unsigned char __tiny INTETC23;
extern unsigned char __tiny INTETC45;
extern unsigned char __tiny INTETC67;
extern unsigned char __tiny INTCLR;
/* storage/fdc_routines.s */
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near SYSTEM_TIMESTAMP;
/* sequencer/sequencer_ui.s */
extern unsigned char TrAsGrid_ByteData1_Table[], TrAsGrid_ByteData1_Table_2[];
/* storage/flash_floppy_handlers.s */
extern struct eo __near FLASH_SLOT_ASSIGN_LIST;
extern struct eo __near ram_86c;
/* midi/midi_serial_routines.s */
extern unsigned char __near MIDI_RX_CONTEXT[];
/* midi/midipkt_routines.s */
extern struct mprec MidiCtl_NullRecord;
/* audio/audio_control_engine.s */
extern unsigned char __near ram_8f4c;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near ram_8f50;
extern unsigned char __near ram_8f52;
extern unsigned char __near ram_8f54;
extern unsigned char __near ram_8f56;
extern unsigned char PanelInput_EventIndexByHeader[];
/* audio/dsp_config_sysex.s */
extern void *DspFxRecListPtrTable[];
extern unsigned char DspFxParamCountTable[], DspCfg_Data002_ByteTable[];
/* ui/ui_playback_modes.s */
extern unsigned int DkMdlyPly_BitMaskByIndex[];
extern unsigned int __near ram_2875;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CONTROL_FLAGS;
/* sequencer/smf_config_routines.s */
extern unsigned int __near SEQ_DATA_BLOCK;
extern int __near SEQ_DATA_OFFSET;
extern ucp __near SEQ_BLOCK_POOL;
/* sequencer/accompseq_routines.s */
extern unsigned int __near ram_7e1c;
extern unsigned int __near ram_7e20;
extern unsigned char __near ram_7e1e;
extern unsigned char __near ram_7e1f;
extern unsigned char __near ram_7e22;
extern unsigned char __near ram_7e23;
/* audio/semenu_routines.s */
extern unsigned char GUI_DisplayStructData_0x1129[];
extern unsigned char ram_20c39[], ram_20bf3[];
extern unsigned char __near ram_6ba[];
/* ui/cpanel_routines.s */
extern unsigned int __near TIMESTAMP_FOR_DELAY;
/* sequencer/seq_audio_mode.s */
extern unsigned int __near ram_32e3;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char __near ACC_DEFER_SECTION_LANES;
/* audio/presentation_sound_nav.s */
extern unsigned int DIAL_ENABLE;
extern long DIAL_FOCUS;

/* ---- refinements (one spot each) ---- */

void SOME_DELAY(unsigned int n)
{
	unsigned int i, t;

	n >>= 1;
	t = SYSTEM_TIMESTAMP;
	for (i = 0; i < 0xffff; i++)
		if (SYSTEM_TIMESTAMP - t > n) return;
}

void SeMenu_ComputeParamTableAddr(unsigned char n, unsigned char *s)
{
	unsigned char *d, *e;

	d = (unsigned char *)0x205f3 + (unsigned int)(unsigned char)(n - 1) * 10;
	e = s + 10;
	do *d++ = *s++; while (s < e);
}

/* ---- new functions ---- */

void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;

	if (*in == 32 || *in == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (Text_CharGlyphMap[i] == *in) {
			*out = i;
			break;
		}
	if (i == 256) *out = 32;
}

/* cc900-name: Flash_StoreBaseAccPatch_Helper=Flash_StoreBaseAndInitAccPatch_Helper (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = a + 48;
	else if (a < 20) r = a + 38;
	else if (a < 30) r = a + 28;
	else if (a < 40) r = a + 18;
	else r = a + 8;
	return r;
}

void EffectMode_CopyHoldPedalBits(struct hpb *s, struct hpb *d)
{
	if (ACTIVE_TITLE == 0xc0 || ACTIVE_TITLE == 0xc2 || ACTIVE_TITLE == 0xc5) return;
	if (!(PLAY_TRANSPORT_STATE & 4)) return;
	d->f8 = s->f8;
	d->b9 = s->b9;
}

void SetSongSlotValue(unsigned int i, unsigned int v)
{
	unsigned int *p;

	if (i >= 10) return;
	p = (unsigned int *)((unsigned char *)SEQ_SONG_SLOTS + (unsigned long)(i << 11) + 0x1c);
	*p = v;
	if (SEQ_CURRENT_SONG != i) return;
	p = (unsigned int *)((unsigned char *)&SEQ_SONG_RECORD + 0x1c);
	*p = v;
}

unsigned int GetSongSlotValue(unsigned int i)
{
	unsigned int r = 0;

	if (i < 10) r = *(unsigned int *)((unsigned char *)SEQ_SONG_SLOTS + (unsigned long)(i << 11) + 0x1c);
	return r;
}

void Boot_ClearAllInterruptEnables(void)
{
	INTE0AD = 0;
	INTE45 = 0;
	INTE67 = 0;
	INTE89 = 0;
	INTEAB = 0;
	INTET01 = 0;
	INTET23 = 0;
	INTET45 = 0;
	INTET67 = 0;
	INTET89 = 0;
	INTETAB = 0;
	INTES0 = 0;
	INTES1 = 0;
	INTETC01 = 0;
	INTETC23 = 0;
	INTETC45 = 0;
	INTETC67 = 0;
}

unsigned char HexCharToNibble(unsigned char a)
{
	if (a < 0x30 || a > 0x39) goto lower;
	return a - 0x30;
lower:
	if (a < 0x61 || a > 0x66) goto upper;
	return a - 0x57;
upper:
	if (a < 0x41 || a > 0x46) return 0;
	return a - 0x37;
}

int SdpartScrollDelta(long evt, int a, int b)
{
	switch (evt) {
	case 0x1c00018L:
		return b * -1;
	case 0x1c0001aL:
		return a * -1;
	case 0x1c00017L:
		return b;
	case 0x1c00019L:
		return a;
	default:
		return 0;
	}
}

void FDC_HardwareSetup(void)
{
	INTCLR = 11;
	INTE45 = (INTE45 & 0xf8) | 4;
	INTCLR = 40;
	INTETC23 = (INTETC23 & 0x8f) | 0x50;
	INTCLR = 12;
	INTE45 = (INTE45 & 0x8f) | 0x60;
}

unsigned char TrAsGrid_StepListValue(unsigned char i, unsigned char dir)
{
	unsigned char v = TrAsGrid_ByteData1_Table[i];

	if (dir == 0) {
		if (v < 19) v++;
	} else if (v != 0) {
		v--;
	}
	return (TrAsGrid_ByteData1_Table + 20)[v];
}

void SlotTable_ExtendedOpsBlock(void)
{
	struct eo *p = &FLASH_SLOT_ASSIGN_LIST;
	unsigned int *x, *y, *e;

	p->h0 = 0xffff;
	p->h1 = 0xffff;
	y = &p->e[0].y;
	x = &p->e[0].x;
	e = y + 100;
	do { *x = 0xffff; x += 2; *y = 0xffff; y += 2; } while (y < e);
}

/* cc900-name: Flash_InitBcBlock_Helper4_Helper=Flash_InitBytecodeBlock_Helper4_Helper (the label shares its first 31
   characters with Flash_InitBytecodeBlock_Helper4_Helper2) */
void Flash_InitBcBlock_Helper4_Helper(void)
{
	struct eo *p = &ram_86c;
	unsigned int *x, *y, *e;

	p->h0 = 0xffff;
	p->h1 = 0xffff;
	y = &p->e[0].y;
	x = &p->e[0].x;
	e = y + 100;
	do { *x = 0xffff; x += 2; *y = 0xffff; y += 2; } while (y < e);
}

void SC0Init_ClearContextSlots(void)
{
	MIDI_RX_CONTEXT[0] = 0;
	MIDI_RX_CONTEXT[4] = 0;
	MIDI_RX_CONTEXT[8] = 0;
	MIDI_RX_CONTEXT[12] = 0;
	MIDI_RX_CONTEXT[16] = 0;
	MIDI_RX_CONTEXT[20] = 0;
	MIDI_RX_CONTEXT[24] = 0;
}

char *__cdecl Sprintf_OctalToStr(char *p, unsigned long v)
{
	char *q;

	do {
		q = p++;
		*q = (char)((v & 7) + 0x30);
		v >>= 3;
	} while (v != 0);
	*p = 0;
	return p;
}

unsigned int __cdecl SeqStep_FileSectorRead(unsigned char **pp)
{
	unsigned int lo, hi;

	lo = *(*pp)++;
	hi = *(*pp)++;
	hi <<= 8;
	return lo + hi;
}

int SdpartLookupPartId(int *p, int v)
{
	int n = 0;

	while (*p != -1 && *p != v) {
		p++;
		n++;
	}
	if (*p == -1) return -1;
	return n;
}

struct mprec *MidiPkt_MatchParamInTable(struct mpkt *k, struct mprec **l)
{
	struct mprec *r;

	for (;;) {
		r = *l++;
		if (r == &MidiCtl_NullRecord) return r;
		if (r->b7 == k->b1 && (r->b8 & k->b3)) return r;
	}
}

void Audio_InitChannelTimers(void)
{
	ram_8f4c = 5;
	DEMO_PLAY_STATE = 5;
	ram_8f50 = 5;
	ram_8f52 = 5;
	ram_8f54 = 5;
	ram_8f56 = 5;
}

int DSPCfg_CheckParamTableEntry(unsigned int a)
{
	int r = 0;

	if (a > 0x63) goto nf;
	if (DspFxRecListPtrTable[a] != 0) return r;
nf:
	return -1;
}

int DkMdlyPly_FindLowestSetBit(unsigned int m)
{
	int i;

	for (i = 0; i < 16; i++)
		if (DkMdlyPly_BitMaskByIndex[i] & m) return i;
	return i;
}

int IsColorValid(int c)
{
	if (c >= 0 && c <= 0xff) return 1;
	if (c >= 0x100 && c <= 0x100) return 1;
	return 0;
}

unsigned int DSPCfg_GetSlotCount(unsigned int i)
{
	return *(DspFxParamCountTable + (unsigned long)i);
}

unsigned int DSPCfg_Data_002(unsigned int i)
{
	return *(DspCfg_Data002_ByteTable + (unsigned long)i);
}

unsigned char PanelInput_EventIndexOfHeader(unsigned char h)
{
	unsigned char c = h & 0x1f;

	h &= 0xc0;
	h >>= 1;
	return PanelInput_EventIndexByHeader[h | c];
}

int FDC_DRIVE_STATUS(void)
{
	if (FDC_REQ_COUNT != 0xffff) return 0;
	if (FDC_COMMAND_INDEX != 0) return 0;
	return -1;
}

void SMF_LookupSongBank(unsigned char v)
{
	unsigned char *p;

	p = SEQ_BLOCK_POOL + ((unsigned long)(SEQ_DATA_BLOCK - 1) << 8);
	p[SEQ_DATA_OFFSET] = v;
}

void PlayMode_TeardownAndRestore(void)
{
	SEQ_TRACK_MASK = ram_2875;
	SEQ_RTMCFG = SEQ_RTMCFG & 0xfb;
	SEQ_CONTROL_FLAGS = SEQ_CONTROL_FLAGS | 0x10;
	SEQ_RTMCFG = SEQ_RTMCFG & 0xf7;
}

void AccompSeq_SaveTimerSnapshot(void)
{
	ram_7e20 = ram_7e1c;
	ram_7e22 = ram_7e1e;
	ram_7e23 = ram_7e1f;
}

void SeMenu_NameCharIndexToChar(unsigned char c, unsigned char *out)
{
	if (c >= 97) {
		*out = 32;
		return;
	}
	*out = GUI_DisplayStructData_0x1129[c];
}

long GetWallPaletteRGB(unsigned int a, unsigned int b)
{
	long *p = ((long **)0x3f1e4)[a];

	return p[b];
}

void SeMenu_GetToneIndex(unsigned char n, unsigned int *out)
{
	n--;
	*out = ((unsigned int *)0x6a2)[n];
}

void SeMenu_FillObjTable(unsigned char *d)
{
	unsigned char *s, *e;

	s = ram_20c39;
	e = s + 25;
	do *d++ = *s++; while (s < e);
}

void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}

void FDemoText_ScaleDownCoords(int *s, int *d)
{
	d[0] = s[0] / 8;
	d[1] = s[1] / 4;
}

void DELAY_51_TICKS(void)
{
	TIMESTAMP_FOR_DELAY = SYSTEM_TIMESTAMP;
	do ; while ((int)(SYSTEM_TIMESTAMP - TIMESTAMP_FOR_DELAY) < 51);
}

void DELAY_6_TICKS(void)
{
	TIMESTAMP_FOR_DELAY = SYSTEM_TIMESTAMP;
	do ; while ((int)(SYSTEM_TIMESTAMP - TIMESTAMP_FOR_DELAY) < 6);
}

unsigned char VariScreen_CalcValidNoteRow(unsigned char a, unsigned char c)
{
	unsigned char e;

	e = (a >> 1) + c;
	if (a < (unsigned char)(e + 1)) return 0;
	return ++e;
}

void SeMenu_LoadParamByte(unsigned char n, unsigned char *out)
{
	*out = ram_6ba[(unsigned char)(n - 1)];
}

unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}

void A_Short_Pause(void)
{
	unsigned int i, j;

	i = 0;
	do {
		j = 0;
		do j++; while (j < 0x100);
		i++;
	} while (i < 0x1000);
}

void AccSection_DeferToBarIfLastBeat(void)
{
	unsigned int w = ram_32e3;

	if ((unsigned char)((w >> 8) & 7) + 1 == ACC_BEATS_PER_BAR) ACC_DEFER_SECTION_LANES |= 63;
}

long GetDialFocus(void)
{
	if (DIAL_ENABLE == 0) return -1;
	return DIAL_FOCUS;
}

void SeMenu_CopyNameChars(unsigned char *d, unsigned char *s, unsigned char n)
{
	unsigned char i;

	i = 0;
	if (i < n) do { *d++ = *s++; i++; } while (i < n);
}

int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	unsigned char m = ~r[2];

	rec[r[1]] &= m;
	return 3;
}

unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}

void SeMenu_GetNameBufferChar(unsigned char i, unsigned char *out)
{
	if (i > 15) return;
	*out = ram_20bf3[i];
}

unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned int i;

	for (i = 0; i < n; i++) a >>= 1;
	return a;
}
