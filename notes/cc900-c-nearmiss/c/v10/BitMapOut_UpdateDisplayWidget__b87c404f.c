/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_9m274a.c (2026-11-19-75-p6-r54)
   sha256 b87c404f37242a86d23abe92ff8cb848ceca3600994568c670f641c79c1958a5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: BmoUpdWidget_Str_NonPanelMem=BitMapOut_UpdateDisplayWidget_Str_Non_Panel_Memory */
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char BmoUpdWidget_Str_NonPanelMem;
extern unsigned char *PanelMemory_SlotAddresses[];
extern unsigned char __near PANEL_STYLIST_NAME;
extern unsigned char __near LIVE_PANEL_BLOCK;
void BitMapOut_UpdateDisplayWidget(unsigned char n, char *d)
{
	unsigned char *s;

	if (n == 0)
		Mem_Copy(d, &BmoUpdWidget_Str_NonPanelMem, 16);
	else {
		s = PanelMemory_SlotAddresses[n - 1];
		Mem_Copy(d, (&PANEL_STYLIST_NAME - &LIVE_PANEL_BLOCK - 0x20) + s, 16);
	}
	d[16] = 0;
}
