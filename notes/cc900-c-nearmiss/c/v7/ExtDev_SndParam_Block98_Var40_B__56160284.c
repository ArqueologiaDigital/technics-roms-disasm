/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 56160284579d556a793e9a9d23ebccdab87b5932fbf80734233f4a43f0f96eb5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_905d;
void ExtDev_SndParam_Block98_Var40_B(unsigned char *e)
{
	ram_905d |= 2;
	e[0] = 152;
	e[1] = 11;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
