/* Phase 6, lane_p6 helper M, round 13, hand source audio/sound_editor_ui.s, form a: one representative of each new
   handler shape of the sound-editor pages, plus the CONTROLLER pages (mostly matched shapes).
   SeTonTon1_OnColumn1: part on / off: a QIZ byte flag (switch & 0x7f) against SeMenu_IsPartEnabled.
   SeTonTon1_OnColumn2: a byte index stepped within the group count (the frame byte incremented / decremented in
     memory), then the group's first tone sent; _OnColumn3: the same with a word tone index.
   SeTonTon2_OnColumn6: a clamped step of a byte parameter (0..127), re-registered, title field part + 11.
   SeTonHyb1_OnColumn8: part parameter 0 stepped 1..4 (QIZ flag), up only while the next block's value is not 127.
   SeWrtMem_OnSideRow3: the write-memory slot up to 39, shown as bank / number (slot / 20 + 1, slot % 20 + 1).
   SeWrtSnd_OnColumn1 / _OnSideRow2: tail jumps to the naming page's bodies (same module: jrl).
   SeCtr2_* / SeCtr3_*: column stubs, obj-gated part columns, side rows in the Join7 shape, switches. */
/* cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */
/* cc900-name: SeAPE_J21=SeMenu_ApplyPartEdit_AltStore_Join21 */
/* cc900-name: SeAPE_J22=SeMenu_ApplyPartEdit_AltStore_Join22 */
/* cc900-module: SeWrtSnd_ClearName_Join SeWrtSnd_SetupNamingPage_Join6 */   /* scripts/analysis/cc900/module_calls.py v10 */

#define TT_SEMENU    0x20
#define TT_SECTR2    0x3b
#define TT_SECTR3    0x3c
#define TT_SECOPY    0x3d

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetPartEnabled();
extern void SeM_CWU_S3H11(int, int, unsigned char *);
extern void SeMenu_GetEntryCount(unsigned char *);
extern void SeMenu_GetGroupFirstToneIndex(int, int, unsigned int *);
extern void SeMenu_SendPartToneIndex(int, unsigned int);
extern void SeMenu_InitDisplayField();
extern void SeMenu_GetToneIndex(int, unsigned int *);
extern void SeMenu_GetWordEntryCount(unsigned int *);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_ApplyPartEdit(int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeMenu_SetWriteMemSlot(int);
extern void SeWrtSnd_SetupNamingPage_Join6(unsigned char a);
extern void SeWrtSnd_ClearName_Join(void);
extern void SeAPE_J21();
extern void SeAPE_J22();
extern void SeCtr2_OnPartColumn();
extern void SeCtr2_SetSelection(int);

extern void SeTonTon1_OnColumn1(unsigned char a);
extern void SeTonTon1_OnColumn2(unsigned char a);
extern void SeTonTon1_OnColumn3(unsigned char a);
extern void SeTonTon2_OnColumn6(unsigned char a);
extern void SeTonHyb1_OnColumn8(unsigned char a);
extern void SeWrtMem_OnSideRow3(unsigned char a);
extern void SeWrtSnd_OnColumn1(unsigned char a);
extern void SeWrtSnd_OnSideRow2(unsigned char a);
extern void SeCtr2_OnColumn2(unsigned char a);
extern void SeCtr2_OnColumn4(unsigned char a);
extern void SeCtr2_OnColumn5(unsigned char a);
extern void SeCtr2_OnColumn6(unsigned char a);
extern void SeCtr2_OnColumn7(unsigned char a);
extern void SeCtr2_OnColumn8(unsigned char a);
extern void SeCtr2_OnSideRow2(unsigned char a);
extern void SeCtr2_OnSideRow3(unsigned char a);
extern void SeCtr2_OnSwitch25(unsigned char a);
extern void SeCtr2_OnSwitch15(unsigned char a);
extern void SeCtr3_OnColumn3(unsigned char a);
extern void SeCtr3_OnColumn6(unsigned char a);
extern void SeCtr3_OnSwitch25(unsigned char a);
extern void SeCtr3_OnSwitch15(unsigned char a);

void SeTonTon1_OnColumn1(unsigned char a)
{
	unsigned char p;
	unsigned char flag;

	SeMenu_LoadPartParam(0, &p);
	flag = a & 0x7f;
	if (SeMenu_IsPartEnabled(p) != 0) {
		if (flag == 0)
			return;
		SeMenu_SetPartEnabled(p, 0);
	} else {
		if (flag != 0)
			return;
		SeMenu_SetPartEnabled(p, 1);
	}
	SeTitle_DrawField(34, 1);
	SeMenu_SetupMenuDisplay(1);
}

void SeTonTon1_OnColumn2(unsigned char a)
{
	unsigned char idx;
	unsigned char n;
	unsigned char p;
	unsigned int tone;

	SeMenu_LoadPartParam(0, &p);
	SeM_CWU_S3H11(0, p, &idx);
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
	SeMenu_GetGroupFirstToneIndex(0, idx, &tone);
	SeMenu_SendPartToneIndex(p, tone);
	SeMenu_InitDisplayField(p, 16);
	SeMenu_BindDialToColumn(2);
}

void SeTonTon1_OnColumn3(unsigned char a)
{
	unsigned char p;
	unsigned int idx;
	unsigned int cnt;

	SeMenu_LoadPartParam(0, &p);
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
	SeMenu_SendPartToneIndex(p, idx);
	SeMenu_InitDisplayField(p, 16);
	SeMenu_BindDialToColumn(3);
}

void SeTonTon2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char v;
	unsigned char step;
	unsigned char blk;
	unsigned char dir;

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
		v = v + step;
		if ((signed char)v < 0)
			v = 0;
	}
	SeMenu_StorePartParam(blk, v);
	SeMenu_RegisterElement_Extended(part, 1, &v, 127);
	SeMenu_ApplyPartEdit(part);
	blk = part + 11;
	SeTitle_DrawField(35, blk);
	SeMenu_BindDialToColumn(6);
}

void SeTonHyb1_OnColumn8(unsigned char a)
{
	unsigned char v;
	unsigned char v2;
	unsigned char flag;

	flag = a;
	flag &= 0x7f;
	SeMenu_LoadPartParam(0, &v);
	if (flag == 0) {
		if (v == 1)
			return;
		v--;
		SeMenu_StorePartParam(0, v);
	} else {
		if (v == 4)
			return;
		SeMenu_LoadPartParam(v, &v2);
		if (v2 == 127)
			return;
		v++;
		SeMenu_StorePartParam(0, v);
	}
	SeTitle_DrawField(38, 0);
}

void SeWrtMem_OnSideRow3(unsigned char a)
{
	unsigned char slot;
	unsigned char d[2];
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

void SeWrtSnd_OnColumn1(unsigned char a)
{
	SeWrtSnd_SetupNamingPage_Join6(a);
}

void SeWrtSnd_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeWrtSnd_ClearName_Join();
}

/* ---- CONTROLLER 2 / 3 ---- */
void SeCtr2_OnColumn2(unsigned char a) { SeAPE_J21(a, 2); }
void SeCtr2_OnColumn4(unsigned char a) { SeAPE_J22(a); }
void SeCtr2_OnColumn5(unsigned char a) { SeCtr2_OnPartColumn(1, a); }
void SeCtr2_OnColumn6(unsigned char a) { SeCtr2_OnPartColumn(2, a); }

void SeCtr2_OnColumn7(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1)
		SeCtr2_OnPartColumn(3, a);
}

void SeCtr2_OnColumn8(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1)
		SeCtr2_OnPartColumn(4, a);
}

void SeCtr2_OnSideRow2(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 2)
			return;
		SeCtr2_SetSelection(2);
	} else {
		if (v == 1)
			return;
		SeCtr2_SetSelection(1);
	}
	SeMenu_SendEvent(TT_SECTR2, 1);
}

void SeCtr2_OnSideRow3(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 6)
			return;
		SeCtr2_SetSelection(6);
	} else {
		if (v == 5)
			return;
		SeCtr2_SetSelection(5);
	}
	SeMenu_SendEvent(TT_SECTR2, 1);
}

void SeCtr2_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SECTR3, 0);
}

void SeCtr2_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}

void SeCtr3_OnColumn3(unsigned char a)
{
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 1;
	p[7] = 4;
	p[8] = 1;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(60, 0, 0, 16, buf);
	SeMenu_BindDialToColumn(3);
}

void SeCtr3_OnColumn6(unsigned char a)
{
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(0, buf);
	p = buf;
	p[6] = 1;
	p[7] = 5;
	p[8] = 1;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(60, 0, 0, 16, buf);
	SeMenu_BindDialToColumn(6);
}

void SeCtr3_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SECTR2, 0);
}

void SeCtr3_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}
