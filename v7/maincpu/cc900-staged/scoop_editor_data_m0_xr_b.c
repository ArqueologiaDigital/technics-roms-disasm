/* Functions of display/scoop_editor_data.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

#define TT_SEFILLPQ1 0x30
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SeFilLpq1_OnSideRow4_Join30(unsigned char a);

void SeFilLpq1_OnSideRow4_Join30(unsigned char a)
{
	unsigned char obj;

	SeMenu_LoadObjEntries(&obj);
	if (a != 0 && obj != 1 && SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEFILLPQ1, 0);
}
