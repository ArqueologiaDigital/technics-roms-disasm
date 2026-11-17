/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 a6b01d6069afdc83f7c9f29a667a198dd9ccc4e0ed611ca6836cb5e7d3cc3447 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_9039;
extern unsigned char __near CURRENT_MODE;
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_3415;
extern unsigned char __near ram_903b[];
void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned char v, a;
	unsigned int i;

	if (CURRENT_MODE == 17) return;
	if (ram_3415 & 8) return;
	ram_9039 |= 2;
	a = e[2] & e[3];
	v = 0;
	if (a != 0) v = 8;
	i = 0;
	do {
		if (ram_903b[i] == 255) break;
		if (SndParam_LookupViaEncode(ram_903b[i], 0x601) == 1) {
			e[0] = ram_903b[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	} while (++i < 16);
}
