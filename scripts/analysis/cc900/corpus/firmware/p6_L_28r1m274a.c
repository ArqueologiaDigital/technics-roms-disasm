/* lane_p6 helper L, round 28r1, form a: module 274 (ui/bitmap_out_routines.s), PanelMemory_BackupLivePanel
   (families28_L's Mem_Copy family with Voice_SavePreset / Voice_CopyPreset, 23 B): 960 bytes from RAM 0xf9a0 to
   0x3c8e4 through the __cdecl Mem_Copy (both pointers pushed as word halves, high half first).
   Form a: the source a __near array, the destination a plain (24-bit) extern array, passed by name.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_f9a0[];
extern unsigned char ram_3c8e4[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);

void PanelMemory_BackupLivePanel(void)
{
	Mem_Copy(ram_3c8e4, ram_f9a0, 960);
}
