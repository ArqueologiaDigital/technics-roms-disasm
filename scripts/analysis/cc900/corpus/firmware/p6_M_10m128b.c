/* Phase 6, lane_p6 helper M, round 10, module 128 (display/scoop_editor_data.s), form b: the HPF 24 dB page
   (SeFilH241_*): column stubs (DrawFilterGraph(1, 1)), side-row stubs that tail-jump to the L241 bodies
   (Join33 / 34 / 35, Join11), side row 4 (filter type 5, obj tested first), the switches. */
/* cc900-module: SeFilL241_OnColumn6_Join33 SeFilL241_OnColumn6_Join34 SeFilL241_OnColumn6_Join35 SeFilL241_OnSideRow4_Join11 SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterCutoff SeMenu_EditFilterResonance */

#define TT_SEMENU    0x20
#define TT_SEFILLPQ1 0x30
#define TT_SEFILFIL2 0x36
#define TT_SECOPY    0x3d

extern void SeMenu_EditFilterCutoff();
extern void SeMenu_EditFilterResonance();
extern void SeMenu_DrawFilterGraph();
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeFilL241_OnColumn6_Join33();
extern void SeFilL241_OnColumn6_Join34();
extern void SeFilL241_OnColumn6_Join35();
extern void SeFilL241_OnSideRow4_Join11();
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SetFilterType(int);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_SetupMenuDisplay(int mode);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilH241_OnColumn3(unsigned char a);
extern void SeFilH241_OnColumn4(unsigned char a);
extern void SeFilH241_OnColumn5(unsigned char a);
extern void SeFilH241_OnColumn6(unsigned char a);
extern void SeFilH241_OnSideRow1(unsigned char a);
extern void SeFilH241_OnSideRow2(unsigned char a);
extern void SeFilH241_OnSideRow3(unsigned char a);
extern void SeFilH241_OnSideRow4(unsigned char a);
extern void SeFilH241_OnSideRow5(unsigned char a);
extern void SeFilH241_OnSwitch25(unsigned char a);
extern void SeFilH241_OnSwitch15(unsigned char a);

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

void SeFilH241_OnSideRow1(unsigned char a)
{
	SeFilL241_OnColumn6_Join33(a);
}

void SeFilH241_OnSideRow2(unsigned char a)
{
	SeFilL241_OnColumn6_Join34(a);
}

void SeFilH241_OnSideRow3(unsigned char a)
{
	SeFilL241_OnColumn6_Join35(a);
}

void SeFilH241_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x05;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilH241_OnSideRow5(unsigned char a)
{
	SeFilL241_OnSideRow4_Join11(a);
}

void SeFilH241_OnSwitch25(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (obj != 1 && a == 0)
		SeMenu_SendEvent(TT_SEFILFIL2, 0);
}

void SeFilH241_OnSwitch15(unsigned char a)
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
