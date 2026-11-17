/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 56160284579d556a793e9a9d23ebccdab87b5932fbf80734233f4a43f0f96eb5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_905d;
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_90f1[];
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[2] & e[3])) return;
	ram_905d |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_90f1[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}
