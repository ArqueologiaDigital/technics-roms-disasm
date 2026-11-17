/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 06dfe6fa7a117df5db566656e6249d5d0321451819f4c2f7fff32c0cda00e4dc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
void ExtDev_SndParam_Block70_Var04(unsigned char *e)
{
	ram_90f9 |= 2;
	e[0] = 112;
	e[1] = 0;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}
