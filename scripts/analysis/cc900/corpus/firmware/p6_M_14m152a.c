/* Phase 6, lane_p6 helper M, round 14, hand source audio/sound_editor_ui.s, form a: retries of round 13 and copies
   of its matched shapes.
   SeTonTon2_OnColumn6 (r56 +0): V4.23 put the block byte in QIZL; the ROM keeps it in the frame (+2) with only the
     direction in QIZH: a no-code `&blk;` keeps it there.  The down step through a register temporary (the ROM:
     ld a,(v); add a,(step); ld (v),a; cp a,0).
   SeWrtMem_OnSideRow3 (+1): the ROM's frame is 6 (digits +0..+3, slot +4): the digit array as 4 bytes; row 4 copy.
   SeWrtSnd_OnColumn1..6 / 8 (r56 +0: V4.23 widened the switch byte): the bodies called without arguments (the
     switch byte stays in A, the ROM's bare jrl).  SeWrtSnd_OnSideRow2 (+4): `if (a != 0) return;` then the tail
     call (the ROM's ret nz + jrl).
   SeTonHyb1_OnColumn2 / 3: copies of the matched SeTonTon1_OnColumn2 / 3 with the part (SeMenu_SendToneIndex,
     SeMenu_InitDisplayField_Alt). */
/* cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */
/* cc900-module: SeWrtSnd_ClearName_Join SeWrtSnd_SetupNamingPage_Join SeWrtSnd_SetupNamingPage_Join2 SeWrtSnd_SetupNamingPage_Join3 SeWrtSnd_SetupNamingPage_Join5 SeWrtSnd_SetupNamingPage_Join6 SeWrtSnd_SetupNamingPage_Join7 SeWrtSnd_SetupNamingPage_Join8 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_ApplyPartEdit(int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeMenu_SetWriteMemSlot(int);
extern void SeM_CWU_S3H11(int, int, unsigned char *);
extern void SeMenu_GetEntryCount(unsigned char *);
extern void SeMenu_GetGroupFirstToneIndex(int, int, unsigned int *);
extern void SeMenu_SendToneIndex(int, int, unsigned int);
extern void SeMenu_InitDisplayField_Alt();
extern void SeMenu_GetToneIndex(int, unsigned int *);
extern void SeMenu_GetWordEntryCount(unsigned int *);
extern void SeWrtSnd_SetupNamingPage_Join(void);
extern void SeWrtSnd_SetupNamingPage_Join2(void);
extern void SeWrtSnd_SetupNamingPage_Join3(void);
extern void SeWrtSnd_SetupNamingPage_Join5(void);
extern void SeWrtSnd_SetupNamingPage_Join6(void);
extern void SeWrtSnd_SetupNamingPage_Join7(void);
extern void SeWrtSnd_SetupNamingPage_Join8(void);
extern void SeWrtSnd_ClearName_Join(void);

extern void SeTonTon2_OnColumn6(unsigned char a);
extern void SeWrtMem_OnSideRow3(unsigned char a);
extern void SeWrtMem_OnSideRow4(unsigned char a);
extern void SeWrtSnd_OnColumn1(unsigned char a);
extern void SeWrtSnd_OnColumn2(unsigned char a);
extern void SeWrtSnd_OnColumn3(unsigned char a);
extern void SeWrtSnd_OnColumn4(unsigned char a);
extern void SeWrtSnd_OnColumn5(unsigned char a);
extern void SeWrtSnd_OnColumn6(unsigned char a);
extern void SeWrtSnd_OnColumn8(unsigned char a);
extern void SeWrtSnd_OnSideRow2(unsigned char a);
extern void SeTonHyb1_OnColumn2(unsigned char a);
extern void SeTonHyb1_OnColumn3(unsigned char a);

void SeTonTon2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char v;
	unsigned char step;
	unsigned char blk;
	unsigned char dir;
	unsigned char t;

	&blk;
	SeMenu_ValidatePartNumber(&part);
	blk = part + 5;
	SeMenu_SwitchToValueStep(a, &step);
	dir = a & 0x7f;
	SeMenu_LoadPartParam(blk, &v);
	v &= 0x7f;
	if (dir == 0) {
		if (v >= 127)
			return;
		v += step;
		if (v >= 127)
			v = 127;
	} else {
		if (v == 0)
			return;
		t = v + step;
		v = t;
		if ((signed char)t < 0)
			v = 0;
	}
	SeMenu_StorePartParam(blk, v);
	SeMenu_RegisterElement_Extended(part, 1, &v, 127);
	SeMenu_ApplyPartEdit(part);
	blk = part + 11;
	SeTitle_DrawField(35, blk);
	SeMenu_BindDialToColumn(6);
}

void SeWrtMem_OnSideRow3(unsigned char a)
{
	unsigned char slot;
	unsigned char d[4];
	unsigned char *p;
	unsigned char *q;

	if (a != 0)
		return;
	SeMenu_GetWriteMemSlot(&slot);
	if (slot >= 39)
		return;
	slot++;
	SeMenu_SetWriteMemSlot(slot);
	p = d;
	*p = slot / 20;
	q = &p[1];
	*q = slot % 20;
	(*p)++;
	(*q)++;
	SeMenu_StorePartParam(0, *p);
	SeMenu_StorePartParam(1, d[1]);
	SeTitle_DrawField(62, 0);
	SeTitle_DrawField(62, 1);
}

void SeWrtMem_OnSideRow4(unsigned char a)
{
	unsigned char slot;
	unsigned char d[4];
	unsigned char *p;
	unsigned char *q;

	if (a != 0)
		return;
	SeMenu_GetWriteMemSlot(&slot);
	if (slot == 0)
		return;
	slot--;
	SeMenu_SetWriteMemSlot(slot);
	p = d;
	*p = slot / 20;
	q = &p[1];
	*q = slot % 20;
	(*p)++;
	(*q)++;
	SeMenu_StorePartParam(0, *p);
	SeMenu_StorePartParam(1, d[1]);
	SeTitle_DrawField(62, 0);
	SeTitle_DrawField(62, 1);
}

void SeWrtSnd_OnColumn1(unsigned char a) { SeWrtSnd_SetupNamingPage_Join6(); }
void SeWrtSnd_OnColumn2(unsigned char a) { SeWrtSnd_SetupNamingPage_Join7(); }
void SeWrtSnd_OnColumn3(unsigned char a) { SeWrtSnd_SetupNamingPage_Join8(); }
void SeWrtSnd_OnColumn4(unsigned char a) { SeWrtSnd_SetupNamingPage_Join(); }
void SeWrtSnd_OnColumn5(unsigned char a) { SeWrtSnd_SetupNamingPage_Join2(); }
void SeWrtSnd_OnColumn6(unsigned char a) { SeWrtSnd_SetupNamingPage_Join3(); }
void SeWrtSnd_OnColumn8(unsigned char a) { SeWrtSnd_SetupNamingPage_Join5(); }

void SeWrtSnd_OnSideRow2(unsigned char a)
{
	if (a != 0)
		return;
	SeWrtSnd_ClearName_Join();
}

void SeTonHyb1_OnColumn2(unsigned char a)
{
	unsigned char idx;
	unsigned char n;
	unsigned char part;
	unsigned char p;
	unsigned int tone;

	SeMenu_LoadPartParam(0, &p);
	SeMenu_ValidatePartNumber(&part);
	SeM_CWU_S3H11(1, p, &idx);
	SeMenu_GetEntryCount(&n);
	if ((a & 0x7f) == 0) {
		if (idx >= (unsigned char)(n - 1))
			return;
		idx++;
	} else {
		if (idx == 0)
			return;
		idx--;
	}
	SeMenu_GetGroupFirstToneIndex(1, idx, &tone);
	SeMenu_SendToneIndex(part, p, tone);
	SeMenu_InitDisplayField_Alt(part, p, 16);
	SeMenu_BindDialToColumn(2);
}

void SeTonHyb1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char p;
	unsigned int idx;
	unsigned int cnt;

	SeMenu_LoadPartParam(0, &p);
	SeMenu_ValidatePartNumber(&part);
	SeMenu_GetToneIndex(p, &idx);
	SeMenu_GetWordEntryCount(&cnt);
	if ((a & 0x7f) == 0) {
		if (idx >= cnt - 1)
			return;
		idx++;
	} else {
		if (idx == 0)
			return;
		idx--;
	}
	SeMenu_SendToneIndex(part, p, idx);
	SeMenu_InitDisplayField_Alt(part, p, 16);
	SeMenu_BindDialToColumn(3);
}
