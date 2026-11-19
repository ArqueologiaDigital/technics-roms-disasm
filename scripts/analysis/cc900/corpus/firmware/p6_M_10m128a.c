/* Phase 6, lane_p6 helper M, round 10, module 128 (display/scoop_editor_data.s), form a: the LPF 24 dB page
   (SeFilL241_*), copies of the matched LPF+Q / HPF+Q handlers: the column stubs (edit body + DrawFilterGraph(0, 1),
   or a tail jump to the shared bodies Join21 / Join22, K&R declarations), the side-button bodies Join33 / 34 / 35
   (shapes of the matched SeFilLpq1_OnColumn4_Join26 / 27 / 28), side row 4 (filter type 4) and its Join11 (part 4,
   obj tested first), the switches. */
/* cc900-module: SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterCutoff SeMenu_EditFilterResonance */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILFIL2 0x36
#define TT_SEFILENV1 0x37
#define TT_SEFILLFO1 0x39
#define TT_SECOPY    0x3d

extern void SeMenu_EditFilterCutoff();
extern void SeMenu_EditFilterResonance();
extern void SeMenu_DrawFilterGraph();
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilL241_OnColumn3(unsigned char a);
extern void SeFilL241_OnColumn4(unsigned char a);
extern void SeFilL241_OnColumn5(unsigned char a);
extern void SeFilL241_OnColumn6(unsigned char a);
extern void SeFilL241_OnColumn6_Join33(unsigned char a);
extern void SeFilL241_OnColumn6_Join34(unsigned char a);
extern void SeFilL241_OnColumn6_Join35(unsigned char a);
extern void SeFilL241_OnSideRow4(unsigned char a);
extern void SeFilL241_OnSideRow4_Join11(unsigned char a);
extern void SeFilL241_OnSwitch25(unsigned char a);
extern void SeFilL241_OnSwitch15(unsigned char a);

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

void SeFilL241_OnColumn6_Join35(unsigned char a)
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

void SeFilL241_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x04;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
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

void SeFilL241_OnSwitch15(unsigned char a)
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
