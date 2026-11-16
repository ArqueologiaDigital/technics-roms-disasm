/* ---- refined round-2 misses ---- */

void AudioMode_MergeOutputBits(void)
{
	unsigned char w, a;

	a = ram_3310 & 0xf8;
	w = ram_32f9 & 7;
	a |= w;
	ram_3310 = a;
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

int PanelTlv_Rule_ResetOutsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char m;

	rec += r[1];
	m = r[2];
	if (r[3] <= (m & *rec) && r[4] >= (m & *rec)) return 6;
	*rec &= ~m;
	*rec |= r[5];
	return 6;
}

int PanelTlv_Rule_ResetInsideRange(unsigned char *rec, unsigned char *r)
{
	unsigned char m;

	rec += r[1];
	m = r[2];
	if (r[3] > (m & *rec) || r[4] < (m & *rec)) return 6;
	*rec &= ~m;
	*rec |= r[5];
	return 6;
}

char *StyleName_FindOverride_C2C5(int key)
{
	unsigned int i;
	struct sname *e;

	for (i = 0; i < 22; i++) {
		e = &StyleNameOverride_C2C5[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}

char *StyleName_FindOverride_Default(int key)
{
	unsigned int i;
	struct sname *e;

	for (i = 0; i < 5; i++) {
		e = &StyleNameOverride_Default[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}

unsigned int BmDrEdit_FindNoteInSlots(void)
{
	unsigned int i, n, o;
	unsigned char *t, *p;
	unsigned char f;

	n = 8;
	if (ram_2742 & 1) n = 1;
	i = 0;
	if (n <= 0) goto nf;
	t = ram_2746;
	do {
		o = i * 3;
		p = &t[o];
		f = *p;
		if (f & 0x80) {
			if (t[1 + o] == ram_2960) {
				*p = f & ~0x80;
				return t[1 + o];
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
	if (ACC_CHORD_TYPE != ACC_CHORD_PREV_TYPE) goto dirty;
	if (ACC_CHORD_BASS == ACC_CHORD_PREV_BASS) goto zero;
dirty:
	ram_32f3 = ram_32f3 | 0x20;
zero:
	if (ACC_CHORD_PREV_TYPE != 0) return;
	ram_32f3 = ram_32f3 & 0xdf;
}

void AccChannel_CheckActivitySetDirty(void)
{
	unsigned char a;

	a = ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2 | ACC_LANES_INTRO1 | ACC_LANES_COUNTIN | ACC_LANES_INTRO2;
	if (!(a & 0x3f)) return;
	if (ACC_PENDING_STYLE < 128) return;
	ACC_DEFER_ENDING_LANES |= 63;
}

void AccPitch_CheckTransposeFlags(void)
{
	if (!(ACC_SECTION_BUTTONS_HELD & 0x40) && (ram_3281 & 0x40)
	    && (unsigned char)(ram_3280 + 1) == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
	if (!(ACC_SECTION_BUTTONS_HELD & 0x80) && (ram_3281 & 0x80)
	    && (unsigned char)(ram_3280 + 1) == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
}

void AccentData_ComparePart1(void)
{
	unsigned char *p = (unsigned char *)0x3214, *q = (unsigned char *)0x3246;

	if (*(long *)p == *(long *)q && p[1] == q[1]) ACC_LANES_RESYNC = ACC_LANES_RESYNC & 0xfc;
}

void AccentData_ComparePart2(void)
{
	unsigned char *p = (unsigned char *)0x3214, *q = (unsigned char *)0x3246;

	if (*(long *)(p + 5) == *(long *)(q + 7) && p[1] == q[1]) ACC_LANES_RESYNC = ACC_LANES_RESYNC & 0xfb;
}

void AccentData_ComparePart3(void)
{
	unsigned char *p = (unsigned char *)0x3214, *q = (unsigned char *)0x3246;

	if (*(long *)(p + 10) == *(long *)(q + 14) && p[1] == q[1]) ACC_LANES_RESYNC = ACC_LANES_RESYNC & 0xf7;
}

void AccentData_ComparePart4(void)
{
	unsigned char *p = (unsigned char *)0x3214, *q = (unsigned char *)0x3246;

	if (*(long *)(p + 15) == *(long *)(q + 21) && p[1] == q[1]) ACC_LANES_RESYNC = ACC_LANES_RESYNC & 0xef;
}

void AccentData_ComparePart5(void)
{
	unsigned char *p = (unsigned char *)0x3214, *q = (unsigned char *)0x3246;

	if (*(long *)(p + 20) == *(long *)(q + 28) && p[1] == q[1]) ACC_LANES_RESYNC = ACC_LANES_RESYNC & 0xdf;
}

void BmDrEdit_RenderSecondaryVert(void)
{
	ram_27c2 = (ram_281e >> 2) + 0x5b;
	ram_27c4 = (ram_210b2 >> 2) + ram_27c2;
	ram_27c6 = BmDrEdit_RenderVertical_Table[ram_210b0];
	ram_27c8 = ram_27c6 + 3;
	ram_27c6 -= 2;
	ram_27c8 += 2;
}

int SndTable_LookupD_CalcAddr(int i)
{
	ram_2358c = ram_235a6[i].b;
	ram_2474e = ram_235a6[i].a;
	ram_3e3e8 = ram_2474e;
	ram_3e3e8 <<= 9;
	return 0;
}

void SeMenu_NoteToKeyboardX(unsigned char a, unsigned int *out)
{
	unsigned char q, r;

	if (a < 20) a = 20;
	else if (a > 108) a = 108;
	a -= 12;
	q = a / 12;
	r = a % 12;
	*out = (unsigned char)(q * 28 + GUI_DisplayStructData_0x1110[r] - 18);
}

void SeMenu_ComputeParamTableAddr(unsigned char n, unsigned char *s)
{
	unsigned char *d, *e;

	d = (unsigned char *)0x205f3 + (n - 1) * 10;
	e = s + 10;
	do *d++ = *s++; while (s < e);
}

void SeMenu_ComputeParamTableAddr_Data(unsigned char n, unsigned char *d)
{
	unsigned char *s, *e;

	s = (unsigned char *)0x205f3 + (n - 1) * 10;
	e = s + 10;
	do *d++ = *s++; while (s < e);
}

unsigned char *PanelTlv_CompanionOfPart(unsigned char a)
{
	if (a < 0x20) return PanelTlv_CompanionByPart[a];
	else if (a == 0x48) return PANEL_VARI_STYLE;
	else return (unsigned char *)0xffffffffL;
}

/* cc900-name: Flash_StoreBaseAccPatch_Helper2=Flash_StoreBaseAndInitAccPatch_Helper2 (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper2(unsigned char a)
{
	if (a < 10) return 48;
	if (a < 20) return 49;
	if (a < 30) return 50;
	if (a >= 40) return 52;
	return 51;
}

void SOME_DELAY(unsigned int n)
{
	unsigned int t, i;

	n >>= 1;
	t = SYSTEM_TIMESTAMP;
	i = 0;
	while (i < 0xffff) {
		if (SYSTEM_TIMESTAMP - t > n) return;
		i++;
	}
}

unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b)
{
	unsigned long r;

	r = 0x8000 + (unsigned long)((a & 0x3f) << 10);
	r |= (unsigned long)(b & 0x3ff);
	if (b >= 0x400) r += 0x10000;
	return r;
}

void ChangeWall_Impl(unsigned int w)
{
	unsigned char *p;

	ram_3ef9c = w;
	p = ChangeWall_WallpaperTable[w].bmp;
	ram_3ef98 = p;
	WALLPAPER_BITMAP = p;
}

unsigned char ValidateSmfFilename(unsigned char *name, unsigned int n)
{
	int i;
	unsigned int k;

	i = 0;
	k = 0;
	while (name[i] != 0 && k < n) {
		if (name[i] != 0x20) return 0;
		i++;
		k++;
	}
	return 1;
}

void DELAY_3000_LOOPS(void)
{
	unsigned int i = 3000;

	while (--i != 0)
		;
}

void InitializeTimer(void)
{
	unsigned char *a, *b, *c, *e;

	ram_30444 = 0;
	ram_30448 = 0xffff;
	a = (unsigned char *)ram_2f844;
	c = a + 8;
	b = a + 2;
	e = a + 3072;
	do {
		*(unsigned int *)a = 0xffff;
		*(unsigned int *)b = 0xffff;
		*(long *)c = -1;
		a += 24; b += 24; c += 24;
	} while (a < e);
}
