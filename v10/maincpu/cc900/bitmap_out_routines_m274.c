/* Functions of ui/bitmap_out_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char BmoUpdWidget_Str_NonPanelMem;
extern unsigned char *PanelMemory_SlotAddresses[];
extern unsigned char __near PANEL_STYLIST_NAME;
extern unsigned char __near LIVE_PANEL_BLOCK;
extern void BitMapOut_UpdateDisplayWidget(unsigned char n, char *d);

/* cc900-name: BmoUpdWidget_Str_NonPanelMem=BitMapOut_UpdateDisplayWidget_Str_Non_Panel_Memory */
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
