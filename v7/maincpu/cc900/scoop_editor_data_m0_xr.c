/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterResonance */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeMenu_EditFilterResonance();
extern void SeMenu_DrawFilterGraph();
extern void SeFilLpq1_OnColumn2(unsigned char a);
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn3(unsigned char a);
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeFilLpq1_OnColumn4(unsigned char a);
#define TT_SEFILENV1 0x37
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_ToggleSolo(void);
extern void SeFilLpq1_OnColumn4_Join26(unsigned char a);

void SeFilLpq1_OnColumn2(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 2, 48);
	SeMenu_DrawFilterGraph(0, 0);
}

void SeFilLpq1_OnColumn3(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 3, 48);
}

void SeFilLpq1_OnColumn4(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 4, 48);
}

void SeFilLpq1_OnColumn4_Join26(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a == 0) {
		if (obj == 0)
			SeMenu_SendEvent(TT_SEFILENV1, 0);
	} else
		SeMenu_ToggleSolo();
}
