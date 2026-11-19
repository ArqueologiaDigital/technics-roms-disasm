/* Phase 6, lane_p6 helper M, round 11, module 128 (display/scoop_editor_data.s), form a: the filter ENV 1 / ENV 2 /
   LFO 1 pages (SeFilEnv1_*, SeFilEnv2_*, SeFilLfo1_*).  Column stubs widen the switch and tail-jump (jp, another
   module) to the shared bodies SeMenu_ApplyPartEdit_AltStore_Join* in audio/semenu_routines.s with int arguments
   (K&R declarations; the bodies' names share their first 31 characters, so each has a cc900-name alias).  Side rows
   and switches in the matched shapes (the if / else of two tail calls; a call + ret inside an if). */
/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
/* cc900-name: SeAPE_J8=SeMenu_ApplyPartEdit_AltStore_Join8 */
/* cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
/* cc900-name: SeAPE_J10=SeMenu_ApplyPartEdit_AltStore_Join10 */
/* cc900-name: SeAPE_J11=SeMenu_ApplyPartEdit_AltStore_Join11 */
/* cc900-name: SeAPE_J12=SeMenu_ApplyPartEdit_AltStore_Join12 */
/* cc900-name: SeAPE_J13=SeMenu_ApplyPartEdit_AltStore_Join13 */
/* cc900-name: SeAPE_J14=SeMenu_ApplyPartEdit_AltStore_Join14 */
/* cc900-name: SeAPE_J15=SeMenu_ApplyPartEdit_AltStore_Join15 */
/* cc900-name: SeAPE_J16=SeMenu_ApplyPartEdit_AltStore_Join16 */
/* cc900-name: SeAPE_J17=SeMenu_ApplyPartEdit_AltStore_Join17 */
/* cc900-name: SeAPE_J18=SeMenu_ApplyPartEdit_AltStore_Join18 */
/* cc900-name: SeAPE_J19=SeMenu_ApplyPartEdit_AltStore_Join19 */
/* cc900-name: SeAPE_J20=SeMenu_ApplyPartEdit_AltStore_Join20 */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILENV1 0x37
#define TT_SEFILENV2 0x38
#define TT_SEFILLFO1 0x39

extern void SeAPE_J();
extern void SeAPE_J2();
extern void SeAPE_J3();
extern void SeAPE_J4();
extern void SeAPE_J5();
extern void SeAPE_J6();
extern void SeAPE_J7();
extern void SeAPE_J8();
extern void SeAPE_J9();
extern void SeAPE_J10();
extern void SeAPE_J11();
extern void SeAPE_J12();
extern void SeAPE_J13();
extern void SeAPE_J14();
extern void SeAPE_J15();
extern void SeAPE_J16();
extern void SeAPE_J17();
extern void SeAPE_J18();
extern void SeAPE_J19();
extern void SeAPE_J20();
extern void SeLfo1_StepSelectorAndReload();
extern void SeMenu_CyclePartLfoState(int, int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);

extern void SeFilEnv1_OnColumn1(unsigned char a);
extern void SeFilEnv1_OnColumn2(unsigned char a);
extern void SeFilEnv1_OnColumn3(unsigned char a);
extern void SeFilEnv1_OnColumn4(unsigned char a);
extern void SeFilEnv1_OnColumn5(unsigned char a);
extern void SeFilEnv1_OnColumn6(unsigned char a);
extern void SeFilEnv1_OnColumn7(unsigned char a);
extern void SeFilEnv1_OnSideRow1(unsigned char a);
extern void SeFilEnv1_OnSideRow2(unsigned char a);
extern void SeFilEnv1_OnSideRow3(unsigned char a);
extern void SeFilEnv1_OnSideRow4(unsigned char a);
extern void SeFilEnv1_OnSideRow5(unsigned char a);
extern void SeFilEnv1_OnSwitch25(unsigned char a);
extern void SeFilEnv1_OnSwitch15(unsigned char a);
extern void SeFilEnv2_OnColumn2(unsigned char a);
extern void SeFilEnv2_OnColumn3(unsigned char a);
extern void SeFilEnv2_OnColumn4(unsigned char a);
extern void SeFilEnv2_OnColumn5(unsigned char a);
extern void SeFilEnv2_OnColumn7(unsigned char a);
extern void SeFilEnv2_OnColumn8(unsigned char a);
extern void SeFilEnv2_OnSideRow1(unsigned char a);
extern void SeFilEnv2_OnSideRow2(unsigned char a);
extern void SeFilEnv2_OnSideRow3(unsigned char a);
extern void SeFilEnv2_OnSideRow4(unsigned char a);
extern void SeFilEnv2_OnSideRow5(unsigned char a);
extern void SeFilEnv2_OnSwitch25(unsigned char a);
extern void SeFilEnv2_OnSwitch15(unsigned char a);
extern void SeFilLfo1_OnColumn2(unsigned char a);
extern void SeFilLfo1_OnColumn3(unsigned char a);
extern void SeFilLfo1_OnColumn4(unsigned char a);
extern void SeFilLfo1_OnColumn5(unsigned char a);
extern void SeFilLfo1_OnColumn6(unsigned char a);
extern void SeFilLfo1_OnColumn7(unsigned char a);
extern void SeFilLfo1_OnColumn8(unsigned char a);
extern void SeFilLfo1_OnSideRow1(unsigned char a);
extern void SeFilLfo1_OnSideRow2(unsigned char a);
extern void SeFilLfo1_OnSideRow3(unsigned char a);
extern void SeFilLfo1_OnSideRow4(unsigned char a);
extern void SeFilLfo1_OnSideRow5(unsigned char a);
extern void SeFilLfo1_OnSwitch15(unsigned char a);

/* ---- filter ENV 1 ---- */
void SeFilEnv1_OnColumn1(unsigned char a) { SeAPE_J8(a, 63, 0); }
void SeFilEnv1_OnColumn2(unsigned char a) { SeAPE_J9(a, 64, 0); }
void SeFilEnv1_OnColumn3(unsigned char a) { SeAPE_J10(a, 62, 65); }
void SeFilEnv1_OnColumn4(unsigned char a) { SeAPE_J11(a, 66, 0); }
void SeFilEnv1_OnColumn5(unsigned char a) { SeAPE_J12(a, 70, 67); }
void SeFilEnv1_OnColumn6(unsigned char a) { SeAPE_J13(a, 68, 0); }
void SeFilEnv1_OnColumn7(unsigned char a) { SeAPE_J14(a, 61, 69); }

void SeFilEnv1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeFilEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

void SeFilEnv1_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

void SeFilEnv1_OnSideRow4(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(0);
	else if (SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

void SeFilEnv1_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(1);
	else if (SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 1);
}

void SeFilEnv1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILENV2, 0);
}

void SeFilEnv1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- filter ENV 2 ---- */
void SeFilEnv2_OnColumn2(unsigned char a) { SeAPE_J15(a, 74); }
void SeFilEnv2_OnColumn3(unsigned char a) { SeAPE_J16(a, 75); }
void SeFilEnv2_OnColumn4(unsigned char a) { SeAPE_J17(a, 76); }
void SeFilEnv2_OnColumn5(unsigned char a) { SeAPE_J18(a, 73); }
void SeFilEnv2_OnColumn7(unsigned char a) { SeAPE_J19(a, 71); }
void SeFilEnv2_OnColumn8(unsigned char a) { SeAPE_J20(a, 72); }

void SeFilEnv2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeFilEnv2_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEFILENV2, 1);
}

void SeFilEnv2_OnSideRow3(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEFILLFO1, 0);
	else if (SeMenu_SelectPartIfEnabled(2) != 0)
		SeMenu_SendEvent(TT_SEFILENV2, 1);
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

void SeFilEnv2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEFILENV1, 0);
}

void SeFilEnv2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- filter LFO 1 ---- */
void SeFilLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 2); }
void SeFilLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 2); }
void SeFilLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 2); }
void SeFilLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 2); }
void SeFilLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 2); }
void SeFilLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 2); }
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
