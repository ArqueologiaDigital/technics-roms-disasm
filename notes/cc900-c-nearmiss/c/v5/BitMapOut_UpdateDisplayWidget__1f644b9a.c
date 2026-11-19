/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bitmap_out_routines_m274.c (2026-11-19-92-p6-r57)
   sha256 1f644b9a8029354c94e9d7e32c81fe2dfe2fce06aca98a2b35b275183a4dee9f (tar-sha256); compiled at -Xr
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
