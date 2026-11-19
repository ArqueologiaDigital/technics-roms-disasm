/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void SeAPE_J8();
extern void SeFilEnv1_OnColumn1(unsigned char a);
extern void SeAPE_J9();
extern void SeFilEnv1_OnColumn2(unsigned char a);
extern void SeAPE_J10();
extern void SeFilEnv1_OnColumn3(unsigned char a);
extern void SeAPE_J11();
extern void SeFilEnv1_OnColumn4(unsigned char a);
extern void SeAPE_J12();
extern void SeFilEnv1_OnColumn5(unsigned char a);
extern void SeAPE_J13();
extern void SeFilEnv1_OnColumn6(unsigned char a);
extern void SeAPE_J14();
extern void SeFilEnv1_OnColumn7(unsigned char a);
extern void SeMenu_ToggleSolo(void);
extern void SeFilEnv1_OnSideRow1(unsigned char a);
#define TT_SEFILENV1 0x37
extern void SeAPE_J7();
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilEnv1_OnSideRow4(unsigned char a);
extern void SeFilEnv1_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeFilEnv1_OnSwitch15(unsigned char a);
#define TT_SEFILENV2 0x38
extern void SeFilEnv1_OnSwitch25(unsigned char a);
extern void SeAPE_J15();
extern void SeFilEnv2_OnColumn2(unsigned char a);
extern void SeAPE_J16();
extern void SeFilEnv2_OnColumn3(unsigned char a);
extern void SeAPE_J17();
extern void SeFilEnv2_OnColumn4(unsigned char a);
extern void SeAPE_J18();
extern void SeFilEnv2_OnColumn5(unsigned char a);
extern void SeAPE_J19();
extern void SeFilEnv2_OnColumn7(unsigned char a);
extern void SeAPE_J20();
extern void SeFilEnv2_OnColumn8(unsigned char a);
extern void SeFilEnv2_OnSideRow1(unsigned char a);
extern void SeFilEnv2_OnSideRow4(unsigned char a);
extern void SeFilEnv2_OnSideRow5(unsigned char a);
extern void SeFilEnv2_OnSwitch15(unsigned char a);
extern void SeFilEnv2_OnSwitch25(unsigned char a);
extern void SeLfo1_StepSelectorAndReload();
extern void SeFilLfo1_OnColumn2(unsigned char a);
extern void SeAPE_J();
extern void SeFilLfo1_OnColumn3(unsigned char a);
extern void SeAPE_J2();
extern void SeFilLfo1_OnColumn4(unsigned char a);
extern void SeAPE_J3();
extern void SeFilLfo1_OnColumn5(unsigned char a);
extern void SeAPE_J4();
extern void SeFilLfo1_OnColumn6(unsigned char a);
extern void SeAPE_J5();
extern void SeFilLfo1_OnColumn7(unsigned char a);
extern void SeAPE_J6();
extern void SeFilLfo1_OnColumn8(unsigned char a);
extern void SeFilLfo1_OnSideRow1(unsigned char a);
#define TT_SEFILLPQ1 0x30
extern void SeMenu_CyclePartLfoState(int, int);
extern void SeFilLfo1_OnSideRow2(unsigned char a);
extern void SeFilLfo1_OnSideRow3(unsigned char a);
extern void SeFilLfo1_OnSideRow4(unsigned char a);
extern void SeFilLfo1_OnSideRow5(unsigned char a);
extern void SeFilLfo1_OnSwitch15(unsigned char a);
extern void SeAmpLfo1_OnColumn2(unsigned char a);
extern void SeAmpLfo1_OnColumn3(unsigned char a);
extern void SeAmpLfo1_OnColumn4(unsigned char a);
extern void SeAmpLfo1_OnColumn5(unsigned char a);
extern void SeAmpLfo1_OnColumn6(unsigned char a);
extern void SeAmpLfo1_OnColumn7(unsigned char a);
extern void SeAmpLfo1_OnColumn8(unsigned char a);
#define TT_SEAMPENV1 0x2d
extern void SeAmpLfo1_OnSideRow1(unsigned char a);
#define TT_SEAMPAMP1 0x2b
extern void SeAmpLfo1_OnSideRow2(unsigned char a);
extern void SeAmpLfo1_OnSideRow3(unsigned char a);
extern void SeAmpLfo1_OnSideRow4(unsigned char a);
extern void SeAmpLfo1_OnSideRow5(unsigned char a);
extern void SeAmpLfo1_OnSwitch15(unsigned char a);

/* cc900-name: SeAPE_J8=SeMenu_ApplyPartEdit_AltStore_Join8 */
void SeFilEnv1_OnColumn1(unsigned char a) { SeAPE_J8(a, 63, 0); }

/* cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
void SeFilEnv1_OnColumn2(unsigned char a) { SeAPE_J9(a, 64, 0); }

/* cc900-name: SeAPE_J10=SeMenu_ApplyPartEdit_AltStore_Join10 */
void SeFilEnv1_OnColumn3(unsigned char a) { SeAPE_J10(a, 62, 65); }

/* cc900-name: SeAPE_J11=SeMenu_ApplyPartEdit_AltStore_Join11 */
void SeFilEnv1_OnColumn4(unsigned char a) { SeAPE_J11(a, 66, 0); }

/* cc900-name: SeAPE_J12=SeMenu_ApplyPartEdit_AltStore_Join12 */
void SeFilEnv1_OnColumn5(unsigned char a) { SeAPE_J12(a, 70, 67); }

/* cc900-name: SeAPE_J13=SeMenu_ApplyPartEdit_AltStore_Join13 */
void SeFilEnv1_OnColumn6(unsigned char a) { SeAPE_J13(a, 68, 0); }

/* cc900-name: SeAPE_J14=SeMenu_ApplyPartEdit_AltStore_Join14 */
void SeFilEnv1_OnColumn7(unsigned char a) { SeAPE_J14(a, 61, 69); }

void SeFilEnv1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
void SeFilEnv1_OnSideRow4(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(0);
	else if (SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
void SeFilEnv1_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(1);
	else if (SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

void SeFilEnv1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeFilEnv1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILENV2, 0);
}

/* cc900-name: SeAPE_J15=SeMenu_ApplyPartEdit_AltStore_Join15 */
void SeFilEnv2_OnColumn2(unsigned char a) { SeAPE_J15(a, 74); }

/* cc900-name: SeAPE_J16=SeMenu_ApplyPartEdit_AltStore_Join16 */
void SeFilEnv2_OnColumn3(unsigned char a) { SeAPE_J16(a, 75); }

/* cc900-name: SeAPE_J17=SeMenu_ApplyPartEdit_AltStore_Join17 */
void SeFilEnv2_OnColumn4(unsigned char a) { SeAPE_J17(a, 76); }

/* cc900-name: SeAPE_J18=SeMenu_ApplyPartEdit_AltStore_Join18 */
void SeFilEnv2_OnColumn5(unsigned char a) { SeAPE_J18(a, 73); }

/* cc900-name: SeAPE_J19=SeMenu_ApplyPartEdit_AltStore_Join19 */
void SeFilEnv2_OnColumn7(unsigned char a) { SeAPE_J19(a, 71); }

/* cc900-name: SeAPE_J20=SeMenu_ApplyPartEdit_AltStore_Join20 */
void SeFilEnv2_OnColumn8(unsigned char a) { SeAPE_J20(a, 72); }

void SeFilEnv2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeFilEnv2_OnSideRow4(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILENV2, 1);
	}
}

void SeFilEnv2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEFILENV2, 1);
	}
}

void SeFilEnv2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeFilEnv2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 0);
}

void SeFilLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 2); }

/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
void SeFilLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 2); }

/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
void SeFilLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 2); }

/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
void SeFilLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 2); }

/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
void SeFilLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 2); }

/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
void SeFilLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 2); }

/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
void SeFilLfo1_OnColumn8(unsigned char a) { SeAPE_J6(a, 2); }

void SeFilLfo1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEFILENV1, 0);
}

void SeFilLfo1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	else
		SeMenu_CyclePartLfoState(2, 1);
}

void SeFilLfo1_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(2, 2);
}

void SeFilLfo1_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(2, 3);
}

void SeFilLfo1_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(2, 4);
}

void SeFilLfo1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeAmpLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 0); }

/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
void SeAmpLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 0); }

/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
void SeAmpLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 0); }

/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
void SeAmpLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 0); }

/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
void SeAmpLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 0); }

/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
void SeAmpLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 0); }

/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
void SeAmpLfo1_OnColumn8(unsigned char a) { SeAPE_J6(a, 0); }

void SeAmpLfo1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}

void SeAmpLfo1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
	else
		SeMenu_CyclePartLfoState(0, 1);
}

void SeAmpLfo1_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(0, 2);
}

void SeAmpLfo1_OnSideRow4(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(0, 3);
}

void SeAmpLfo1_OnSideRow5(unsigned char a)
{
	if (a != 0)
		SeMenu_CyclePartLfoState(0, 4);
}

void SeAmpLfo1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
