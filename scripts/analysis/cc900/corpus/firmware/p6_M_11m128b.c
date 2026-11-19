/* Phase 6, lane_p6 helper M, round 11, module 128 (display/scoop_editor_data.s), form b: the AMP LFO 1 page
   (SeAmpLfo1_*), a copy of the filter LFO 1 page (p6_M_11m128a.c) with LFO index 0 and the AMP page titles. */
/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPENV1 0x2d

extern void SeAPE_J();
extern void SeAPE_J2();
extern void SeAPE_J3();
extern void SeAPE_J4();
extern void SeAPE_J5();
extern void SeAPE_J6();
extern void SeLfo1_StepSelectorAndReload();
extern void SeMenu_CyclePartLfoState(int, int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeAmpLfo1_OnColumn2(unsigned char a);
extern void SeAmpLfo1_OnColumn3(unsigned char a);
extern void SeAmpLfo1_OnColumn4(unsigned char a);
extern void SeAmpLfo1_OnColumn5(unsigned char a);
extern void SeAmpLfo1_OnColumn6(unsigned char a);
extern void SeAmpLfo1_OnColumn7(unsigned char a);
extern void SeAmpLfo1_OnColumn8(unsigned char a);
extern void SeAmpLfo1_OnSideRow1(unsigned char a);
extern void SeAmpLfo1_OnSideRow2(unsigned char a);
extern void SeAmpLfo1_OnSideRow3(unsigned char a);
extern void SeAmpLfo1_OnSideRow4(unsigned char a);
extern void SeAmpLfo1_OnSideRow5(unsigned char a);
extern void SeAmpLfo1_OnSwitch15(unsigned char a);

void SeAmpLfo1_OnColumn2(unsigned char a) { SeLfo1_StepSelectorAndReload(a, 0); }
void SeAmpLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 0); }
void SeAmpLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 0); }
void SeAmpLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 0); }
void SeAmpLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 0); }
void SeAmpLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 0); }
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
