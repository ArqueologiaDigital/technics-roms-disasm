/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 06dfe6fa7a117df5db566656e6249d5d0321451819f4c2f7fff32c0cda00e4dc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_Write98_Block(unsigned char *e)
{
	if (SndParam_LookupViaEncode(PART_SELECT, 1539) != 1) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 2;
	if (e[2] & e[3]) e[2] = 128;
	else e[2] = 0;
	e[3] = 128;
	PanelEvent_Post(e);
}
