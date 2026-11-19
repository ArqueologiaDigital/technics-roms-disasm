/* Phase 6, lane_p6 helper M, round 11, module 129 (audio/semenu_routines.s), form b: the pitch ENV 1 / ENV 2 /
   LFO 1 pages (SePitEnv1_*, SePitEnv2_*, SePitLfo1_*), copies of the filter pages in p6_M_11m128a.c with the pitch
   ids and titles (LFO index 1).  The column stubs reach the shared bodies with jp (absolute, another module). */
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
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10; these handlers are table entries, not call
   targets, so modules_v10.tsv gives them no module number; the file is named after the hand source's module) */

#define TT_SEMENU    0x20
#define TT_SEPITPIT1 0x27
#define TT_SEPITENV1 0x28
#define TT_SEPITENV2 0x29
#define TT_SEPITLFO1 0x2a

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

extern void SePitEnv1_OnColumn1(unsigned char a);
extern void SePitEnv1_OnColumn2(unsigned char a);
extern void SePitEnv1_OnColumn3(unsigned char a);
extern void SePitEnv1_OnColumn4(unsigned char a);
extern void SePitEnv1_OnColumn5(unsigned char a);
extern void SePitEnv1_OnColumn6(unsigned char a);
extern void SePitEnv1_OnColumn7(unsigned char a);
extern void SePitEnv1_OnSideRow1(unsigned char a);
extern void SePitEnv1_OnSideRow2(unsigned char a);
extern void SePitEnv1_OnSideRow3(unsigned char a);
extern void SePitEnv1_OnSideRow4(unsigned char a);
extern void SePitEnv1_OnSideRow5(unsigned char a);
extern void SePitEnv1_OnSwitch25(unsigned char a);
extern void SePitEnv1_OnSwitch15(unsigned char a);
extern void SePitEnv2_OnColumn2(unsigned char a);
extern void SePitEnv2_OnColumn3(unsigned char a);
extern void SePitEnv2_OnColumn4(unsigned char a);
extern void SePitEnv2_OnColumn5(unsigned char a);
extern void SePitEnv2_OnColumn7(unsigned char a);
extern void SePitEnv2_OnColumn8(unsigned char a);
extern void SePitEnv2_OnSideRow1(unsigned char a);
extern void SePitEnv2_OnSideRow2(unsigned char a);
extern void SePitEnv2_OnSideRow3(unsigned char a);
extern void SePitEnv2_OnSideRow4(unsigned char a);
extern void SePitEnv2_OnSideRow5(unsigned char a);
extern void SePitEnv2_OnSwitch25(unsigned char a);
extern void SePitEnv2_OnSwitch15(unsigned char a);
extern void SePitLfo1_OnColumn2(unsigned char a);
extern void SePitLfo1_OnColumn3(unsigned char a);
extern void SePitLfo1_OnColumn4(unsigned char a);
extern void SePitLfo1_OnColumn5(unsigned char a);
extern void SePitLfo1_OnColumn6(unsigned char a);
extern void SePitLfo1_OnColumn7(unsigned char a);
extern void SePitLfo1_OnColumn8(unsigned char a);
extern void SePitLfo1_OnSideRow1(unsigned char a);
extern void SePitLfo1_OnSideRow2(unsigned char a);
extern void SePitLfo1_OnSideRow3(unsigned char a);
extern void SePitLfo1_OnSideRow4(unsigned char a);
extern void SePitLfo1_OnSideRow5(unsigned char a);
extern void SePitLfo1_OnSwitch15(unsigned char a);

/* ---- pitch ENV 1 ---- */
void SePitEnv1_OnColumn1(unsigned char a) { SeAPE_J8(a, 9, 0); }
void SePitEnv1_OnColumn2(unsigned char a) { SeAPE_J9(a, 10, 0); }
void SePitEnv1_OnColumn3(unsigned char a) { SeAPE_J10(a, 8, 11); }
void SePitEnv1_OnColumn4(unsigned char a) { SeAPE_J11(a, 12, 0); }
void SePitEnv1_OnColumn5(unsigned char a) { SeAPE_J12(a, 16, 13); }
void SePitEnv1_OnColumn6(unsigned char a) { SeAPE_J13(a, 14, 0); }
void SePitEnv1_OnColumn7(unsigned char a) { SeAPE_J14(a, 7, 15); }

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

void SePitEnv1_OnSideRow4(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(0);
	else if (SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

void SePitEnv1_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(1);
	else if (SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

void SePitEnv1_OnSwitch25(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEPITENV2, 0);
}

void SePitEnv1_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- pitch ENV 2 ---- */
void SePitEnv2_OnColumn2(unsigned char a) { SeAPE_J15(a, 20); }
void SePitEnv2_OnColumn3(unsigned char a) { SeAPE_J16(a, 21); }
void SePitEnv2_OnColumn4(unsigned char a) { SeAPE_J17(a, 22); }
void SePitEnv2_OnColumn5(unsigned char a) { SeAPE_J18(a, 19); }
void SePitEnv2_OnColumn7(unsigned char a) { SeAPE_J19(a, 17); }
void SePitEnv2_OnColumn8(unsigned char a) { SeAPE_J20(a, 18); }

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

void SePitEnv2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 0);
}

void SePitEnv2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

/* ---- pitch LFO 1 ---- */
void SePitLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 1); }
void SePitLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 1); }
void SePitLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 1); }
void SePitLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 1); }
void SePitLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 1); }
void SePitLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 1); }
void SePitLfo1_OnColumn8(unsigned char a) { SeAPE_J6(a, 1); }

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
