/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_SetEditEnable(int);
extern void SeMenu_SetConfirmState(int);
extern void SeMenu_SetSelectedRow(int);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern void SeMenu_SetupMenuDisplay(int mode);
extern void SeMenu_RefreshPartDisplay(void);
extern void UpdateSeMenuSelection(void);

void UpdateSeMenuSelection(void)
{
	unsigned char k;

	SeMenu_SetSelectedRow(0);
	SeMenu_SetEditEnable(0);
	SeMenu_LoadObjEntries(&k);
	if (k != 2)
		SeMenu_SetupMenuDisplay(0);
	SeMenu_SetConfirmState(0);
	SeMenu_RefreshPartDisplay();
}
