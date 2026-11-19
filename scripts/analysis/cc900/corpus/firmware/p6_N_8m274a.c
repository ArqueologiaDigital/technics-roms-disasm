/* lane_p6 helper N, round 8, form a: module 274 (ui/bitmap_out_routines.s), new function.
   BitMapOut_UpdateDisplayWidget: copies 16 characters into d -- "Non Panel Memory" for slot 0, else the stylist
   name of panel memory n (its slot address + the name's offset in the live panel block) -- and terminates them.
   The two Mem_Copy calls share their tail from the destination push (V4.23's cross jump); the string is an
   extern pushed in word halves.
   cc900-options: -O3 -Xr
*/
/* cc900-name: BmoUpdWidget_Str_NonPanelMem=BitMapOut_UpdateDisplayWidget_Str_Non_Panel_Memory */

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char BmoUpdWidget_Str_NonPanelMem[];
extern unsigned char *PanelMemory_SlotAddresses[];
extern unsigned char __near PANEL_STYLIST_NAME;
extern unsigned char __near LIVE_PANEL_BLOCK;

void BitMapOut_UpdateDisplayWidget(unsigned char n, char *d)
{
	if (n == 0)
		Mem_Copy(d, BmoUpdWidget_Str_NonPanelMem, 16);
	else
		Mem_Copy(d, (&PANEL_STYLIST_NAME - &LIVE_PANEL_BLOCK - 0x20) + PanelMemory_SlotAddresses[n - 1], 16);
	d[16] = 0;
}
