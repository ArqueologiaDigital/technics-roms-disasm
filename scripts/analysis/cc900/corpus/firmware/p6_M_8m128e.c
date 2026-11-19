/* Phase 6, lane_p6 helper M, round 8, module 128 (display/scoop_editor_data.s), form e: the AMP1 page's side rows
   and switches (siblings of the matched SeAmpAmp2_OnSideRow1 / _OnSwitch15 / _OnSwitch25 and
   SeFilLpq1_OnColumn4_Join26 / _Join28).  Row 1: an if / else of two tail calls; rows 2-5 and switches: the last
   call inside an if, behind a frame (obj +0, the switch +2) where the handler reads obj.  The callees take ints. */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEAMPAMP2 0x2c
#define TT_SEAMPENV1 0x2d
#define TT_SEAMPLFO1 0x2f
#define TT_SECOPY    0x3d

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_SelectPartAndRedraw(int, int, int);
extern void SeAmpAmp1_OnSideRow1(unsigned char a);
extern void SeAmpAmp1_OnSideRow2(unsigned char a);
extern void SeAmpAmp1_OnSideRow3(unsigned char a);
extern void SeAmpAmp1_OnSideRow4(unsigned char a);
extern void SeAmpAmp1_OnSideRow5(unsigned char a);
extern void SeAmpAmp1_OnSwitch25(unsigned char a);
extern void SeAmpAmp1_OnSwitch15(unsigned char a);

void SeAmpAmp1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}

void SeAmpAmp1_OnSideRow2(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(43, 1, 1);
}

void SeAmpAmp1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj != 1)
			SeMenu_SendEvent(TT_SEAMPLFO1, 0);
	} else
		SeMenu_SelectPartAndRedraw(43, 2, 1);
}

void SeAmpAmp1_OnSideRow4(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0)
		SeMenu_SelectPartAndRedraw(43, 3, 1);
}

void SeAmpAmp1_OnSideRow5(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a != 0)
		SeMenu_SelectPartAndRedraw(43, 4, 1);
}

void SeAmpAmp1_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP2, 0);
}

void SeAmpAmp1_OnSwitch15(unsigned char a)
{
	unsigned char obj;

	SeMenu_SetupMenuDisplay(0);
	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEMENU, 0);
		else
			SeMenu_SendEvent(TT_SECOPY, 0);
	}
}
