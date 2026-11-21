/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeWrtSnd_ClearName_Join SeWrtSnd_SetupNamingPage_Join6 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeAPE_J21();
extern void SeCtr2_OnColumn2(unsigned char a);
extern void SeAPE_J22();
extern void SeCtr2_OnColumn4(unsigned char a);
extern void SeCtr2_OnPartColumn();
extern void SeCtr2_OnColumn5(unsigned char a);
extern void SeCtr2_OnColumn6(unsigned char a);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeCtr2_OnColumn7(unsigned char a);
extern void SeCtr2_OnColumn8(unsigned char a);
#define TT_SECTR2    0x3b
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeCtr2_SetSelection(int);
extern void SeCtr2_OnSideRow2(unsigned char a);
extern void SeCtr2_OnSideRow3(unsigned char a);
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeCtr2_OnSwitch15(unsigned char a);
#define TT_SECTR3    0x3c
extern void SeCtr2_OnSwitch25(unsigned char a);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeCtr3_OnColumn3(unsigned char a);
extern void SeCtr3_OnColumn6(unsigned char a);
extern void SeCtr3_OnSwitch15(unsigned char a);
extern void SeCtr3_OnSwitch25(unsigned char a);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeTonHyb1_OnColumn8(unsigned char a);
extern void SeMenu_SetupMenuDisplay(int mode);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetPartEnabled();
extern void SeTonTon1_OnColumn1(unsigned char a);
extern void SeMenu_ToggleSolo(void);
extern void SeTonHyb1_OnSideRow1(unsigned char a);
#define TT_SETONHYB1 0x26
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeTonHyb1_OnSideRow2(unsigned char a);
extern void SeTonHyb1_OnSideRow3(unsigned char a);
extern void SeTonHyb1_OnSideRow4(unsigned char a);
extern void SeTonHyb1_OnSideRow5(unsigned char a);
extern void SeTonHyb1_OnSwitch15(unsigned char a);
#define TT_SETONTON1 0x22
#define TT_SETONTON2 0x23
extern void SeTonHyb1_OnSwitch25(unsigned char a);
extern void SeTonRan1_OnSideRow1(unsigned char a);
#define TT_SETONRAN1 0x24
extern void SeTonRan1_OnSideRow2(unsigned char a);
#define TT_SETONRAN2 0x25
extern void SeTonRan1_OnSideRow3(unsigned char a);
extern void SeTonRan1_OnSideRow4(unsigned char a);
extern void SeTonRan1_OnSideRow5(unsigned char a);
extern void SeTonRan1_OnSwitch15(unsigned char a);
extern void SeTonRan2_OnSideRow1(unsigned char a);
extern void SeTonRan2_OnSideRow2(unsigned char a);
extern void SeTonRan2_OnSideRow3(unsigned char a);
extern void SeTonRan2_OnSideRow4(unsigned char a);
extern void SeTonRan2_OnSideRow5(unsigned char a);
extern void SeTonRan2_OnSwitch15(unsigned char a);
extern void SeMenu_StoreParamByte(int, int);
extern void SeTonTon1_OnColumn6(unsigned char a);
extern void SeTonTon1_OnColumn7(unsigned char a);
extern void SeTonTon1_OnColumn8(unsigned char a);
extern void SeTonTon1_OnSideRow1(unsigned char a);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SeTonTon1_OnSideRow2(unsigned char a);
extern void SeTonTon1_OnSideRow3(unsigned char a);
extern void SeTonTon1_OnSideRow4(unsigned char a);
extern void SeTonTon1_OnSideRow5(unsigned char a);
extern void SeMenu_GoToPageOnEnabledPart(int);
extern void SeTonTon1_OnSwitch15(unsigned char a);
extern void SeTonTon1_OnSwitch25(unsigned char a);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeTonTon2_OnColumn4(unsigned char a);
extern void SeTonTon2_OnColumn7(unsigned char a);
extern void SeTonTon2_OnSideRow1(unsigned char a);
extern void SeTonTon2_OnSideRow2(unsigned char a);
extern void SeTonTon2_OnSideRow3(unsigned char a);
extern void SeTonTon2_OnSideRow4(unsigned char a);
extern void SeTonTon2_OnSideRow5(unsigned char a);
extern void SeTonTon2_OnSwitch15(unsigned char a);
extern void SeTonTon2_OnSwitch25(unsigned char a);
extern void SeDigEff_OnSwitch15(unsigned char a);
#define TT_SEWRTMEM  0x3e
extern void SeM_CWU_S3H14(int);
extern void SeEasy_OnSideRow1(unsigned char a);
extern void SeEasy_OnSideRow2(unsigned char a);
extern void SeEasy_OnSideRow3(unsigned char a);
extern void SeEasy_OnSideRow4(unsigned char a);
extern void SeEasy_OnSideRow5(unsigned char a);
extern void SeEasy_OnSwitch15(unsigned char a);
extern void SeMenu_SetSelectedRow(int);
extern void SeMenu_TriggerNotification(int);
extern void SeMenu_GetWriteMemSlot(unsigned char *);
extern void SeWrtMem_SelectMemorySlotSound(int);
extern void SeM_CWU_S3C3H(int, int);
extern void SeWrtMem_OnSideRow1(unsigned char a);
#define TT_SEWRTSND  0x3f
extern void SeWrtMem_OnSideRow5(unsigned char a);
extern void SeWrtMem_OnSwitch15(unsigned char a);

/* cc900-name: SeAPE_J21=SeMenu_ApplyPartEdit_AltStore_Join21 */
void SeCtr2_OnColumn2(unsigned char a) { SeAPE_J21(a, 2); }

/* cc900-name: SeAPE_J22=SeMenu_ApplyPartEdit_AltStore_Join22 */
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

void SeCtr2_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SECTR3, 0);
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

void SeCtr3_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}

void SeCtr3_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SECTR2, 0);
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

/* cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */


void SeTonHyb1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonHyb1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SETONHYB1, 1);
	}
}

void SeTonHyb1_OnSideRow3(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SETONHYB1, 1);
	}
}

void SeTonHyb1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 1);
}

void SeTonHyb1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 1);
}

void SeTonHyb1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_LoadObjEntries(&obj);
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}

void SeTonHyb1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1) {
		if (a == 0)
			SeMenu_SendEvent(TT_SETONTON2, 0);
		else
			SeMenu_SendEvent(TT_SETONTON1, 0);
	}
}

void SeTonRan1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonRan1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SETONRAN2, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SETONRAN1, 1);
}

void SeTonRan1_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SETONRAN1, 1);
	}
}

void SeTonRan1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeTonRan2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonRan2_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SETONRAN1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SETONRAN2, 1);
}

void SeTonRan2_OnSideRow3(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SETONRAN2, 1);
	}
}

void SeTonRan2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeTonTon1_OnColumn6(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	blk--;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(34, blk, t, 23, buf) == 1)
		SeMenu_StoreParamByte(t, buf[3]);
	SeMenu_BindDialToColumn(6);
}

void SeTonTon1_OnColumn7(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 24;
	p[9] = 232;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(34, blk, t, 4, buf);
	SeMenu_BindDialToColumn(7);
}

void SeTonTon1_OnColumn8(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	blk++;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(34, blk, t, 5, buf);
	SeMenu_BindDialToColumn(8);
}

void SeTonTon1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonTon1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 1, 0);
}

void SeTonTon1_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 2, 0);
}

void SeTonTon1_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 3, 0);
}

void SeTonTon1_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(34, 4, 0);
}

void SeTonTon1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_GoToPageOnEnabledPart(TT_SEMENU);
		SeMenu_SetupMenuDisplay(0);
	}
}

void SeTonTon1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_GoToPageOnEnabledPart(TT_SETONHYB1);
}

void SeTonTon2_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part + 1;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 63;
	p[7] = 0;
	p[8] = 50;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(35, blk, part, 0, buf);
	SeMenu_BindDialToColumn(4);
}

void SeTonTon2_OnColumn7(unsigned char a)
{
	unsigned char buf[12];
	unsigned char *p;

	SeMenu_LoadPartParam(10, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(35, 10, 0, 92, buf);
	SeMenu_BindDialToColumn(7);
}

void SeTonTon2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeTonTon2_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 1, 1);
}

void SeTonTon2_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 2, 1);
}

void SeTonTon2_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 3, 1);
}

void SeTonTon2_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 4, 1);
}

void SeTonTon2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeTonTon2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SETONHYB1, 0);
}

void SeDigEff_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}

/* cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
void SeEasy_OnSideRow1(unsigned char a)
{
	if (a != 0) {
		SeM_CWU_S3H14(0);
		SeMenu_SendEvent(TT_SEWRTMEM, 0);
	}
}

void SeEasy_OnSideRow2(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 5)
			return;
		SeMenu_StorePartParam(0, 5);
	} else {
		if (v == 1)
			return;
		SeMenu_StorePartParam(0, 1);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow3(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 6)
			return;
		SeMenu_StorePartParam(0, 6);
	} else {
		if (v == 2)
			return;
		SeMenu_StorePartParam(0, 2);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow4(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 7)
			return;
		SeMenu_StorePartParam(0, 7);
	} else {
		if (v == 3)
			return;
		SeMenu_StorePartParam(0, 3);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSideRow5(unsigned char a)
{
	unsigned char v;

	SeMenu_LoadPartParam(0, &v);
	if (a == 0) {
		if (v == 8)
			return;
		SeMenu_StorePartParam(0, 8);
	} else {
		if (v == 4)
			return;
		SeMenu_StorePartParam(0, 4);
	}
	SeTitle_DrawField(33, 0);
}

void SeEasy_OnSwitch15(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEMENU, 0);
}

/* cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
/* cc900-name: SeM_CWU_S3C3H=SeMenu_CopyWriteUpdate_Step3_Code_3_Helper */
void SeWrtMem_OnSideRow1(unsigned char a)
{
	unsigned char slot;

	if (a != 0) {
		SeMenu_GetWriteMemSlot(&slot);
		SeM_CWU_S3C3H(slot, 62);
		SeWrtMem_SelectMemorySlotSound(slot);
		SeMenu_TriggerNotification(35);
		SeM_CWU_S3H14(1);
		SeMenu_SetSelectedRow(0);
	}
}

void SeWrtMem_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEWRTSND, 0);
}

void SeWrtMem_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetSelectedRow(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
