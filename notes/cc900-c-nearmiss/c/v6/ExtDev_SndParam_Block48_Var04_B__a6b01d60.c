/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 a6b01d6069afdc83f7c9f29a667a198dd9ccc4e0ed611ca6836cb5e7d3cc3447 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_9039;
void ExtDev_SndParam_Block48_Var04_B(unsigned char *e)
{
	ram_9039 |= 2;
	e[0] = 72;
	e[1] = 6;
	if (e[2] & e[3]) e[2] = 4;
	else e[2] = 0;
	e[3] = 4;
	PanelEvent_Post(e);
}
