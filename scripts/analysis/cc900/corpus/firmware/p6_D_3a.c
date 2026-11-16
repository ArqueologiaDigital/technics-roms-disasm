/* Phase 6, lane_p6 helper D, round 3, form a: round-2 misses refined after run 2026-11-16-35-p6-r3 (sets O3Xr / Xr),
   plus new leaf functions of the pool, each under its firmware name (or a short C name with a cc900-name comment).
   Form b (p6_D_3b.c) has the same names with other types / shapes.
   __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit (or a ROM label).
   One declarator per __near declaration.  V4.23 allocates unsigned char bitfields from bit 7 down. */

struct lo3 { unsigned char rest : 5; unsigned char v : 3; };
struct bit0 { unsigned char rest : 7; unsigned char b0 : 1; };
struct sname { int key; char name[16]; };
struct w10 { unsigned char *bmp; unsigned char rest[6]; };
struct r44 { unsigned int a, b; unsigned char rest[40]; };
struct aptimer { unsigned int a; unsigned int b; unsigned int pad[2]; long c; unsigned char rest[12]; };

/* sequencer/seq_audio_mode.s */
extern struct lo3 __near ram_3310;
extern struct lo3 __near ram_32f9;
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
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ACC_CHORD_PREV_TYPE;
extern unsigned char __near ACC_CHORD_BASS;
extern unsigned char __near ACC_CHORD_PREV_BASS;
extern unsigned char __near ram_32f3;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ACC_PENDING_STYLE;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ACC_SECTION_BUTTONS_HELD;
extern unsigned char __near ram_3281;
extern unsigned char __near ram_3280;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char __near ram_3329;
/* sequencer/bmdredit_routines.s */
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2746[];
extern unsigned int __near ram_281e;
extern unsigned int __near ram_27c2;
extern unsigned int __near ram_27c4;
extern unsigned int __near ram_27c6;
extern unsigned int __near ram_27c8;
extern unsigned int ram_210b2;
extern unsigned char ram_210b0;
extern unsigned int BmDrEdit_RenderVertical_Table[];
/* sequencer/smf_event_processor.s */
extern struct r44 ram_235a6[];
extern unsigned int ram_2358c, ram_2474e;
extern unsigned long ram_3e3e8;
/* audio/tonegen_fileio_handlers.s: none */
/* audio/sndparam_routines.s: none */
/* audio/semenu_routines.s */
extern unsigned char GUI_DisplayStructData_0x1110[];
/* audio/audio_control_engine.s */
extern unsigned char *PanelTlv_CompanionByPart[];
extern unsigned char __near PANEL_VARI_STYLE[];
/* storage/fdc_routines.s */
extern unsigned int __near SYSTEM_TIMESTAMP;
/* ui/ui_mode_handlers.s */
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
/* ui/ui_window_procs.s */
extern struct w10 ChangeWall_WallpaperTable[];
extern unsigned int ram_3ef9c;
extern unsigned char *ram_3ef98, *WALLPAPER_BITMAP;
/* ui/ui_widget_defs.s */
extern struct aptimer ram_2f844[];
extern long ram_30444;
extern unsigned int ram_30448;

/* ---- refined round-2 misses ---- */

void AudioMode_MergeOutputBits(void)
{
	ram_3310.v = ram_32f9.v;
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

int PanelTlv_Rule_ResetOutsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char m;

	rec += r[1];
	m = r[2];
	if (r[3] > (m & *rec) || r[4] < (m & *rec)) {
		*rec &= ~m;
		*rec |= r[5];
	}
	return 6;
}

int PanelTlv_Rule_ResetInsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char m;

	rec += r[1];
	m = r[2];
	if (r[3] <= (m & *rec) && r[4] >= (m & *rec)) {
		*rec &= ~m;
		*rec |= r[5];
	}
	return 6;
}

char *StyleName_FindOverride_C2C5(int key)
{
	unsigned int i;
	struct sname *t, *e;

	t = StyleNameOverride_C2C5;
	for (i = 0; i < 22; i++) {
		e = &t[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}

char *StyleName_FindOverride_Default(int key)
{
	unsigned int i;
	struct sname *t, *e;

	t = StyleNameOverride_Default;
	for (i = 0; i < 5; i++) {
		e = &t[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}

unsigned int BmDrEdit_FindNoteInSlots(void)
{
	unsigned int i, n;
	unsigned char *t, *p, *q;
	unsigned char f;

	n = 8;
	if (ram_2742 & 1) n = 1;
	i = 0;
	if (n <= 0) goto nf;
	t = ram_2746;
	do {
		p = &t[i * 3];
		f = *p;
		if (f & 0x80) {
			q = &t[1 + i * 3];
			if (*q == ram_2960) {
				*p = f & ~0x80;
				return *q;
			}
		}
		i++;
	} while (i < n);
nf:
	return 0xff;
}

/* ---- new functions of the pool ---- */

void AccChord_CompareAndSetDirty(void)
{
	if (ACC_CHORD_TYPE != ACC_CHORD_PREV_TYPE || ACC_CHORD_BASS != ACC_CHORD_PREV_BASS) ram_32f3 |= 32;
	if (ACC_CHORD_PREV_TYPE == 0) ram_32f3 &= 223;
}

void AccChannel_CheckActivitySetDirty(void)
{
	if (((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2 | ACC_LANES_INTRO1 | ACC_LANES_COUNTIN | ACC_LANES_INTRO2) & 0x3f)
	    && ACC_PENDING_STYLE >= 128)
		ACC_DEFER_ENDING_LANES |= 63;
}

void AccPitch_CheckTransposeFlags(void)
{
	if (!(ACC_SECTION_BUTTONS_HELD & 0x40) && (ram_3281 & 0x40) && ram_3280 + 1 == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
	if (!(ACC_SECTION_BUTTONS_HELD & 0x80) && (ram_3281 & 0x80) && ram_3280 + 1 == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
}

void AccentData_ComparePart1(void)
{
	unsigned char *p, *q;
	long a, b;
	unsigned char c, d;

	p = (unsigned char *)0x3214; q = (unsigned char *)0x3246;
	a = *(long *)p; b = *(long *)q; c = p[1]; d = q[1];
	if (a == b && c == d) ACC_LANES_RESYNC &= 252;
}

void AccentData_ComparePart2(void)
{
	unsigned char *p, *q;
	long a, b;
	unsigned char c, d;

	p = (unsigned char *)0x3214; q = (unsigned char *)0x3246;
	a = *(long *)(p + 5); b = *(long *)(q + 7); c = p[1]; d = q[1];
	if (a == b && c == d) ACC_LANES_RESYNC &= 251;
}

void AccentData_ComparePart3(void)
{
	unsigned char *p, *q;
	long a, b;
	unsigned char c, d;

	p = (unsigned char *)0x3214; q = (unsigned char *)0x3246;
	a = *(long *)(p + 10); b = *(long *)(q + 14); c = p[1]; d = q[1];
	if (a == b && c == d) ACC_LANES_RESYNC &= 247;
}

void AccentData_ComparePart4(void)
{
	unsigned char *p, *q;
	long a, b;
	unsigned char c, d;

	p = (unsigned char *)0x3214; q = (unsigned char *)0x3246;
	a = *(long *)(p + 15); b = *(long *)(q + 21); c = p[1]; d = q[1];
	if (a == b && c == d) ACC_LANES_RESYNC &= 239;
}

void AccentData_ComparePart5(void)
{
	unsigned char *p, *q;
	long a, b;
	unsigned char c, d;

	p = (unsigned char *)0x3214; q = (unsigned char *)0x3246;
	a = *(long *)(p + 20); b = *(long *)(q + 28); c = p[1]; d = q[1];
	if (a == b && c == d) ACC_LANES_RESYNC &= 223;
}

void BmDrEdit_RenderSecondaryVert(void)
{
	ram_27c2 = (ram_281e >> 2) + 0x5b;
	ram_27c4 = (ram_210b2 >> 2) + ram_27c2;
	ram_27c8 = (ram_27c6 = BmDrEdit_RenderVertical_Table[ram_210b0]) + 3;
	ram_27c6 -= 2;
	ram_27c8 += 2;
}

int SndTable_LookupD_CalcAddr(int i)
{
	ram_2358c = ram_235a6[i].b;
	ram_2474e = ram_235a6[i].a;
	ram_3e3e8 = (unsigned long)ram_2474e << 9;
	return 0;
}

void SeMenu_NoteToKeyboardX(unsigned char a, unsigned int *out)
{
	if (a < 20) a = 20;
	else if (a > 108) a = 108;
	a -= 12;
	*out = (unsigned char)(a / 12 * 28 + GUI_DisplayStructData_0x1110[a % 12] - 18);
}

void SeMenu_ComputeParamTableAddr(unsigned char n, unsigned char *s)
{
	unsigned char *d, *e;

	d = (unsigned char *)0x205f3 + (unsigned char)(n - 1) * 10;
	e = s + 10;
	do *d++ = *s++; while (s < e);
}

void SeMenu_ComputeParamTableAddr_Data(unsigned char n, unsigned char *d)
{
	unsigned char *s, *e;

	s = (unsigned char *)0x205f3 + (unsigned char)(n - 1) * 10;
	e = s + 10;
	do *d++ = *s++; while (s < e);
}

unsigned char *PanelTlv_CompanionOfPart(unsigned char a)
{
	if (a <= 0x1f) return PanelTlv_CompanionByPart[a];
	if (a == 0x48) return PANEL_VARI_STYLE;
	return (unsigned char *)-1L;
}

/* cc900-name: Flash_StoreBaseAccPatch_Helper2=Flash_StoreBaseAndInitAccPatch_Helper2 (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper2(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = 48;
	else if (a < 20) r = 49;
	else if (a < 30) r = 50;
	else {
		r = 52;
		if (a >= 40) return r;
		r = 51;
	}
	return r;
}

void SOME_DELAY(unsigned int n)
{
	unsigned int t, i;

	n >>= 1;
	t = SYSTEM_TIMESTAMP;
	for (i = 0; i < 0xffff; i++)
		if (SYSTEM_TIMESTAMP - t > n) return;
}

unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b)
{
	unsigned long r;

	r = 0x8000;
	r += (unsigned int)((a & 0x3f) << 10);
	r |= b & 0x3ff;
	if (b < 0x400) return r;
	return r + 0x10000;
}

void ChangeWall_Impl(unsigned int w)
{
	ram_3ef9c = w;
	WALLPAPER_BITMAP = ram_3ef98 = ChangeWall_WallpaperTable[w].bmp;
}

unsigned char ValidateSmfFilename(unsigned char *name, unsigned int n)
{
	int i;
	unsigned int k;
	unsigned char c;

	for (i = 0, k = 0; (c = name[i]) != 0 && k < n; i++, k++)
		if (c != 0x20) return 0;
	return 1;
}

void DELAY_3000_LOOPS(void)
{
	unsigned int i = 3000;

	for (;;) {
		i--;
		if (i == 0) break;
	}
}

void InitializeTimer(void)
{
	int i;

	ram_30444 = 0;
	ram_30448 = 0xffff;
	for (i = 0; i < 128; i++) {
		ram_2f844[i].a = 0xffff;
		ram_2f844[i].b = 0xffff;
		ram_2f844[i].c = -1;
	}
}
