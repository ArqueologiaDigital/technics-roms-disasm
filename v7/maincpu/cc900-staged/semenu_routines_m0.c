/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SePitPit1_OnColumn2(unsigned char a);
extern void SePitPit1_OnColumn3(unsigned char a);
extern void SePitPit1_OnColumn4(unsigned char a);
#define TT_SEPITENV1 0x28
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SePitPit1_OnSideRow1(unsigned char a);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SePitPit1_OnSideRow2(unsigned char a);
#define TT_SEPITLFO1 0x2a
extern void SePitPit1_OnSideRow3(unsigned char a);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SePitPit1_OnSideRow4(unsigned char a);
extern void SePitPit1_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SePitPit1_OnSwitch15(unsigned char a);
extern void SePitEnv1_OnSideRow1(unsigned char a);
#define TT_SEPITPIT1 0x27
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SePitEnv1_OnSideRow2(unsigned char a);
extern void SePitEnv1_OnSideRow3(unsigned char a);
extern void SePitEnv1_OnSwitch15(unsigned char a);
#define TT_SEPITENV2 0x29
extern void SePitEnv1_OnSwitch25(unsigned char a);
extern void SeAPE_J18();
extern void SePitEnv2_OnColumn5(unsigned char a);
extern void SePitEnv2_OnSideRow1(unsigned char a);
extern void SePitEnv2_OnSideRow2(unsigned char a);
extern void SePitEnv2_OnSideRow3(unsigned char a);
extern void SePitEnv2_OnSideRow4(unsigned char a);
extern void SePitEnv2_OnSideRow5(unsigned char a);
extern void SePitEnv2_OnSwitch15(unsigned char a);
extern void SePitEnv2_OnSwitch25(unsigned char a);
extern void SeLfo1_StepSelectorAndReload();
extern void SePitLfo1_OnColumn2(unsigned char a);
extern void SePitLfo1_OnSideRow1(unsigned char a);
extern void SeMenu_CyclePartLfoState(int, int);
extern void SePitLfo1_OnSideRow2(unsigned char a);
extern void SePitLfo1_OnSideRow3(unsigned char a);
extern void SePitLfo1_OnSideRow4(unsigned char a);
extern void SePitLfo1_OnSideRow5(unsigned char a);
extern void SePitLfo1_OnSwitch15(unsigned char a);

void SePitPit1_OnColumn2(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	blk -= 2;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 24;
	p[9] = 232;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 4, buf);
	SeMenu_BindDialToColumn(2);
}

void SePitPit1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	blk--;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 255;
	p[7] = 0;
	p[8] = 50;
	p[9] = 206;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 5, buf);
	SeMenu_BindDialToColumn(3);
}

void SePitPit1_OnColumn4(unsigned char a)
{
	unsigned char part;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_ValidatePartNumber(&part);
	blk = part * 3;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 7;
	p[7] = 0;
	p[8] = 7;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	SeMenu_StepParamFieldAndSend(39, blk, part, 6, buf);
	SeMenu_BindDialToColumn(4);
}

void SePitPit1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEPITENV1, 0);
}

void SePitPit1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(39, 1, 1);
}

void SePitPit1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else
		SeMenu_SelectPartAndRedraw(39, 2, 1);
}

void SePitPit1_OnSideRow4(unsigned char a)
{
	unsigned char v;

	if (a == 0) {
		SeMenu_LoadPartParam(13, &v);
		if (v > 1) {
			v--;
			SeMenu_StorePartParam(13, v);
			SeTitle_DrawField(39, 13);
		}
	} else
		SeMenu_SelectPartAndRedraw(39, 3, 1);
}

void SePitPit1_OnSideRow5(unsigned char a)
{
	unsigned char v;

	if (a == 0) {
		SeMenu_LoadPartParam(13, &v);
		if (v < 4) {
			v++;
			SeMenu_StorePartParam(13, v);
			SeTitle_DrawField(39, 13);
		}
	} else
		SeMenu_SelectPartAndRedraw(39, 4, 1);
}

void SePitPit1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SePitEnv1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SePitEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITPIT1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

void SePitEnv1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

void SePitEnv1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SePitEnv1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITENV2, 0);
}

/* cc900-name: SeAPE_J18=SeMenu_ApplyPartEdit_AltStore_Join18 */
void SePitEnv2_OnColumn5(unsigned char a) { SeAPE_J18(a, 19); }

void SePitEnv2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SePitEnv2_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITPIT1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEPITENV2, 1);
}

void SePitEnv2_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEPITENV2, 1);
}

void SePitEnv2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEPITENV2, 1);
	}
}

void SePitEnv2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEPITENV2, 1);
	}
}

void SePitEnv2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SePitEnv2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 0);
}

void SePitLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 1); }

void SePitLfo1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEPITENV1, 0);
}

void SePitLfo1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITPIT1, 0);
	else
		SeMenu_CyclePartLfoState(1, 1);
}

void SePitLfo1_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(1, 2);
}

void SePitLfo1_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(1, 3);
}

void SePitLfo1_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(1, 4);
}

void SePitLfo1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
