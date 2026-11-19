/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: SeFilL241_OnColumn6_Join33 SeFilL241_OnColumn6_Join34 SeFilL241_OnColumn6_Join35 SeFilL241_OnSideRow4_Join11 SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterCutoff SeMenu_EditFilterResonance */   /* scripts/analysis/cc900/module_calls.py v10 */

#define TT_SEFILLPQ1 0x30
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilLpq1_OnSideRow4_Join30(unsigned char a);
extern void SeFilL241_OnColumn6_Join33();
extern void SeFilH241_OnSideRow1(unsigned char a);
extern void SeFilL241_OnColumn6_Join34();
extern void SeFilH241_OnSideRow2(unsigned char a);
extern void SeFilL241_OnSideRow4_Join11();
extern void SeFilH241_OnSideRow5(unsigned char a);

void SeFilLpq1_OnSideRow4_Join30(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a != 0 && obj != 1 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}

void SeFilH241_OnSideRow1(unsigned char a)
{
	SeFilL241_OnColumn6_Join33(a);
}

void SeFilH241_OnSideRow2(unsigned char a)
{
	SeFilL241_OnColumn6_Join34(a);
}

void SeFilH241_OnSideRow5(unsigned char a)
{
	SeFilL241_OnSideRow4_Join11(a);
}
