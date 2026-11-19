/* Phase 6, lane_p6 helper M, round 10, module 128 (display/scoop_editor_data.s), form d: the band-cut page's side
   rows and switches (SeFilBcf1_*), copies of the band-pass page's (filter type 1 on row 4). */
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILFIL2 0x36
#define TT_SEFILENV1 0x37
#define TT_SEFILLFO1 0x39
#define TT_SECOPY    0x3d

extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilBcf1_OnSideRow1(unsigned char a);
extern void SeFilBcf1_OnSideRow2(unsigned char a);
extern void SeFilBcf1_OnSideRow3(unsigned char a);
extern void SeFilBcf1_OnSideRow4(unsigned char a);
extern void SeFilBcf1_OnSideRow5(unsigned char a);
extern void SeFilBcf1_OnSwitch25(unsigned char a);
extern void SeFilBcf1_OnSwitch15(unsigned char a);

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

void SeFilBcf1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilBcf1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x01;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
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

void SeFilBcf1_OnSwitch15(unsigned char a)
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
