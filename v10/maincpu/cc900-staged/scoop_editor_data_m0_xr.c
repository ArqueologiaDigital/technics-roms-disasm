/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

#define TT_SEAMPAMP2 0x2c
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeAmpAmp2_OnSideRow5(unsigned char a);
#define TT_SEMENU    0x20
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeAmpAmp2_OnSwitch15(unsigned char a);
#define TT_SEAMPAMP1 0x2b
extern void SeAmpAmp2_OnSwitch25(unsigned char a);
extern void SeMenu_ToggleSolo(void);
extern void SeAmpEnv1_OnSideRow1(unsigned char a);
#define TT_SEFILLPQ1 0x30
extern void SeFilLpq1_OnColumn4_Join27(unsigned char a);
#define TT_SEAMPENV1 0x2d
extern void SeAmpAmp2_OnSideRow1(unsigned char a);

void SeAmpAmp2_OnSideRow5(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(4) != 0)
			SeMenu_SendEvent(TT_SEAMPAMP2, 1);
	}
}

void SeAmpAmp2_OnSwitch15(unsigned char a)
{
	if (a == 0) {
		SeMenu_SetupMenuDisplay(0);
		SeMenu_SendEvent(TT_SEMENU, 0);
	}
}

void SeAmpAmp2_OnSwitch25(unsigned char a)
{
	if (a != 0)
		SeMenu_SendEvent(TT_SEAMPAMP1, 0);
}

void SeAmpEnv1_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
}

void SeFilLpq1_OnColumn4_Join27(unsigned char a)
{
	if (a != 0) {
		if (SeMenu_SelectPartIfEnabled(1) != 0)
			SeMenu_SendEvent(TT_SEFILLPQ1, 0);
	}
}

void SeAmpAmp2_OnSideRow1(unsigned char a)
{
	if (a != 0)
		SeMenu_ToggleSolo();
	else
		SeMenu_SendEvent(TT_SEAMPENV1, 0);
}
