/* Phase 6, lane_p6 helper M, round 7, module 128 (display/scoop_editor_data.s), form b: the small side-button /
   switch handlers of the same pages.  The ROM ends each with `call; ret` behind a `ret z` test: the final call is
   written inside an if (V4.23 turns an unconditional last call into a jump: SeFilLpq1_OnColumn4_Join27, run r47,
   +19, retried here the same way).  The callees take ints (wa / bc loads). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPAMP2 0x2c
#define TT_SEFILLPQ1 0x30

extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilLpq1_OnColumn4_Join27(unsigned char a);
extern void SeAmpEnv1_OnSideRow1(unsigned char a);
extern void SeAmpAmp2_OnSideRow5(unsigned char a);
extern void SeAmpAmp2_OnSwitch25(unsigned char a);
extern void SeAmpAmp2_OnSwitch15(unsigned char a);

void SeFilLpq1_OnColumn4_Join27(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeAmpEnv1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeAmpAmp2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEAMPAMP2, 1);
	}
}

void SeAmpAmp2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
}

void SeAmpAmp2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}
