/* lane_p6 helper L, round 28r1, form b: module 266 (demo/file_demo_proc.s), Voice_SavePreset / Voice_CopyPreset
   (see p6_L_28r1m266a.c).
   Form b: the two RAM blocks as constant pointers (in case V4.23 pushes those as word halves too).
   cc900-options: -O3 -Xr
*/

extern void *__cdecl Mem_Copy(void *, void *, unsigned int);

void Voice_SavePreset(void)
{
	Mem_Copy((void *)0xf1a0L, (void *)0xcceL, 16);
}

void Voice_CopyPreset(void)
{
	Mem_Copy((void *)0xcceL, (void *)0xf1a0L, 16);
}
