/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define TT_SEAMPAMP1 0x2b
#define TT_SEAMPENV1 0x2d
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeAmpEnv1_OnSideRow2(unsigned char a);
#define TT_SEAMPLFO1 0x2f
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeAmpEnv1_OnSideRow3(unsigned char a);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_DrawAmpEnvGraph(void);
extern void SeMenu_SetupDisplayObject_Alt1(int, int, unsigned char *, unsigned int);
extern void SeAmpEnv1_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
#define TT_SECOPY    0x3d
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeAmpEnv1_OnSwitch15(unsigned char a);
#define TT_SEFILLPQ1 0x30
extern void SeMenu_SetFilterType(int);
extern void SeFilHpq1_OnSideRow4(unsigned char a);
extern void SeFilHpq1_OnSwitch15(unsigned char a);
extern void SeFilLpq1_OnSideRow4(unsigned char a);
extern void SeFilLpq1_OnSwitch15(unsigned char a);

void SeAmpEnv1_OnSideRow2(unsigned char a)
{
	if (a == 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
	else if (SeMenu_SelectPartIfEnabled(1) != 0)
		SeMenu_SendEvent(TT_SEAMPENV1, 1);
}

void SeAmpEnv1_OnSideRow3(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEAMPLFO1, 0);
	} else {
		if (SeMenu_SelectPartIfEnabled(2) != 0)
			SeMenu_SendEvent(TT_SEAMPENV1, 1);
	}
}

void SeAmpEnv1_OnSideRow5(unsigned char a)
{
	unsigned char obj;
	unsigned char v;
	unsigned char *q;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0)
		return;
	if (obj == 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEAMPENV1, 1);
	} else {
		SeMenu_LoadPartParam(0, &v);
		if (v & 0x20)
			v &= ~0x20;
		else
			v |= 0x20;
		SeMenu_StorePartParam(0, v);
		SeTitle_DrawField(45, 0);
		q = &v;
		SeMenu_SetupDisplayObject_Alt1(0, 13, q, 32);
		SeMenu_DrawAmpEnvGraph();
	}
}

void SeAmpEnv1_OnSwitch15(unsigned char a)
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




void SeFilHpq1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x03;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj == 0 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilHpq1_OnSwitch15(unsigned char a)
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

void SeFilLpq1_OnSideRow4(unsigned char a)
{
	unsigned char v;
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		SeMenu_LoadPartParam(0, &v);
		v &= 0xf8;
		v |= 0x02;
		SeMenu_SetFilterType(v);
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	} else {
		if (obj != 1 && SeMenu_SelectPartIfEnabled(3) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeFilLpq1_OnSwitch15(unsigned char a)
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
