/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 06dfe6fa7a117df5db566656e6249d5d0321451819f4c2f7fff32c0cda00e4dc (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_34cd;
extern unsigned char __near ram_90fb[];
void PanelAction_PedalFn_Code40(unsigned char *e)
{
	unsigned char v, a;
	unsigned int i;

	if (CURRENT_MODE == 17) return;
	if (ram_34cd & 8) return;
	ram_90f9 |= 2;
	a = e[2] & e[3];
	v = 0;
	if (a != 0) v = 8;
	i = 0;
	do {
		if (ram_90fb[i] == 255) break;
		if (SndParam_LookupViaEncode(ram_90fb[i], 0x601) == 1) {
			e[0] = ram_90fb[i];
			e[1] = 4;
			e[2] = v;
			e[3] = 8;
			PanelEvent_Post(e);
		}
	} while (++i < 16);
}
