/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: SeFilL241_OnColumn6_Join33 SeFilL241_OnColumn6_Join34 SeFilL241_OnColumn6_Join35 SeFilL241_OnSideRow4_Join11 SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeFilLpq1_OnColumn4_Join23 SeFilLpq1_OnColumn4_Join24 SeFilLpq1_OnColumn4_Join25 SeFilLpq1_OnColumn4_Join26 SeFilLpq1_OnColumn4_Join27 SeFilLpq1_OnColumn4_Join28 SeFilLpq1_OnSideRow4_Join30 SeMenu_EditFilterCutoff SeMenu_EditFilterResonance */   /* scripts/analysis/cc900/module_calls.py v10 */

#define TT_SEAMPENV1 0x2d
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeAmpEnv1_OnSideRow4(unsigned char a);
#define TT_SEAMPENV2 0x2e
extern void SeAmpEnv1_OnSwitch25(unsigned char a);
extern void SeMenu_EditFilterCutoff();
extern void SeMenu_DrawFilterGraph();
extern void SeFilHpq1_OnColumn1(unsigned char a);
extern void SeMenu_EditFilterResonance();
extern void SeFilHpq1_OnColumn2(unsigned char a);
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilHpq1_OnColumn3(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeFilHpq1_OnColumn4(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join23();
extern void SeFilHpq1_OnColumn6(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join24();
extern void SeFilHpq1_OnColumn7(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join25();
extern void SeFilHpq1_OnColumn8(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join26();
extern void SeFilHpq1_OnSideRow1(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join27();
extern void SeFilHpq1_OnSideRow2(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join28();
extern void SeFilHpq1_OnSideRow3(unsigned char a);
extern void SeFilLpq1_OnSideRow4_Join30();
extern void SeFilHpq1_OnSideRow5(unsigned char a);
#define TT_SEFILFIL2 0x36
extern void SeFilHpq1_OnSwitch25(unsigned char a);
extern void SeFilLpq1_OnSwitch25(unsigned char a);
extern void SeFilL241_OnColumn3(unsigned char a);
extern void SeFilL241_OnColumn4(unsigned char a);
extern void SeFilL241_OnColumn5(unsigned char a);
extern void SeFilL241_OnColumn6(unsigned char a);
#define TT_SEFILENV1 0x37
extern void SeMenu_ToggleSolo(void);
extern void SeFilL241_OnColumn6_Join33(unsigned char a);
#define TT_SEFILLPQ1 0x30
extern void SeFilL241_OnColumn6_Join34(unsigned char a);
extern void SeFilL241_OnSideRow4_Join11(unsigned char a);
extern void SeFilL241_OnSwitch25(unsigned char a);
extern void SeMenu_DrawBandPassCurve(void);
extern void SeFilBpf1_OnColumn3(unsigned char a);
extern void SeFilBpf1_OnColumn6(unsigned char a);
extern void SeFilBpf1_OnColumn7(unsigned char a);
extern void SeFilBpf1_OnSideRow1(unsigned char a);
extern void SeFilBpf1_OnSideRow2(unsigned char a);
extern void SeFilBpf1_OnSideRow5(unsigned char a);
extern void SeFilBpf1_OnSwitch25(unsigned char a);
extern void SeFilBcf1_OnSideRow1(unsigned char a);
extern void SeFilBcf1_OnSideRow2(unsigned char a);
extern void SeFilBcf1_OnSideRow5(unsigned char a);
extern void SeFilBcf1_OnSwitch25(unsigned char a);
extern void SeFilFil2_OnSideRow1(unsigned char a);
extern void SeFilFil2_OnSideRow2(unsigned char a);
extern void SeFilFil2_OnSideRow4(unsigned char a);
extern void SeFilFil2_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeFilFil2_OnSwitch15(unsigned char a);
extern void SeFilFil2_OnSwitch25(unsigned char a);
extern void SeFilH241_OnColumn3(unsigned char a);
extern void SeFilH241_OnColumn4(unsigned char a);
extern void SeFilH241_OnColumn5(unsigned char a);
extern void SeFilH241_OnColumn6(unsigned char a);
extern void SeFilL241_OnColumn6_Join35();
extern void SeFilH241_OnSideRow3(unsigned char a);
extern void SeFilH241_OnSwitch25(unsigned char a);

void SeAmpEnv1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}

void SeAmpEnv1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEAMPENV2, 0);
}

void SeFilHpq1_OnColumn1(unsigned char a)
{
	SeMenu_EditFilterCutoff(a, 1, 49);
	SeMenu_DrawFilterGraph(1, 0);
}

void SeFilHpq1_OnColumn2(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 2, 49);
	SeMenu_DrawFilterGraph(1, 0);
}

void SeFilHpq1_OnColumn3(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 3, 49);
}

void SeFilHpq1_OnColumn4(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 4, 49);
}

void SeFilHpq1_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join23(a);
}

void SeFilHpq1_OnColumn7(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join24(a);
}

void SeFilHpq1_OnColumn8(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join25(a);
}

void SeFilHpq1_OnSideRow1(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join26(a);
}

void SeFilHpq1_OnSideRow2(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join27(a);
}

void SeFilHpq1_OnSideRow3(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join28(a);
}

void SeFilHpq1_OnSideRow5(unsigned char a)
{
	SeFilLpq1_OnSideRow4_Join30(a);
}

void SeFilHpq1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0 && obj == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilLpq1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilL241_OnColumn3(unsigned char a)
{
	SeMenu_EditFilterCutoff(a, 3, 50);
	SeMenu_DrawFilterGraph(0, 1);
}

void SeFilL241_OnColumn4(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 4, 50);
	SeMenu_DrawFilterGraph(0, 1);
}

void SeFilL241_OnColumn5(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 5, 50);
}

void SeFilL241_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 6, 50);
}

void SeFilL241_OnColumn6_Join33(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}

void SeFilL241_OnColumn6_Join34(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilL241_OnSideRow4_Join11(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilL241_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilBpf1_OnColumn3(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 3, 52);
	SeMenu_DrawBandPassCurve();
}

void SeFilBpf1_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 6, 52);
}

void SeFilBpf1_OnColumn7(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 7, 52);
}

void SeFilBpf1_OnSideRow1(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}

void SeFilBpf1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBpf1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilBpf1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilBcf1_OnSideRow1(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}

void SeFilBcf1_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBcf1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilBcf1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilFil2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEFILENV1, 0);
}

void SeFilFil2_OnSideRow2(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEFILFIL2, 1);
	}
}

void SeFilFil2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeFilFil2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilH241_OnColumn3(unsigned char a)
{
	SeMenu_EditFilterCutoff(a, 3, 51);
	SeMenu_DrawFilterGraph(1, 1);
}

void SeFilH241_OnColumn4(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 4, 51);
	SeMenu_DrawFilterGraph(1, 1);
}

void SeFilH241_OnColumn5(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 5, 51);
}

void SeFilH241_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 6, 51);
}

void SeFilH241_OnSideRow3(unsigned char a)
{
	SeFilL241_OnColumn6_Join35(a);
}

void SeFilH241_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}
