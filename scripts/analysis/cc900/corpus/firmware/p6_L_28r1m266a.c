/* lane_p6 helper L, round 28r1, form a: module 266 (demo/file_demo_proc.s), Voice_SavePreset / Voice_CopyPreset
   (families28_L's three-member Mem_Copy family, 23 B each; the third, PanelMemory_BackupLivePanel, is module 274:
   p6_L_28r1m274a.c): 16 bytes between RAM 0xcce and 0xf1a0, one way each, through the __cdecl Mem_Copy (both
   pointers pushed as word halves, high half first: the addresses of __near objects).
   Form a: __near char arrays passed by name.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_cce[];
extern unsigned char __near ram_f1a0[];
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);

void Voice_SavePreset(void)
{
	Mem_Copy(ram_f1a0, ram_cce, 16);
}

void Voice_CopyPreset(void)
{
	Mem_Copy(ram_cce, ram_f1a0, 16);
}
