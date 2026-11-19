/* lane_p6 helper N, round 9, form a: module 274 (ui/bitmap_out_routines.s), retry of p6_N_8m274a (p6-r52 Xr: +6).
   BitMapOut_UpdateDisplayWidget: the ROM pushes the string's address in word halves (an extern object taken with
   `&`, as ram_3cf04 in the matched DemoMode_Main_Operation; the decayed array gave lda + push) and, for a memory
   slot, reads the slot address before pushing the count (a local assigned first).
   cc900-options: -O3 -Xr
*/
/* cc900-name: BmoUpdWidget_Str_NonPanelMem=BitMapOut_UpdateDisplayWidget_Str_Non_Panel_Memory */

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
