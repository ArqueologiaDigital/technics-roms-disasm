/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/audio_control_engine_m0.c (2026-11-16-125-p6-r26-staged)
   sha256 06dfe6fa7a117df5db566656e6249d5d0321451819f4c2f7fff32c0cda00e4dc (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1 */
extern void PanelEvent_Post(unsigned char *);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
extern int SndParam_LookupReadOnly(long);
extern unsigned char BitMapOut_PrepRender_CheckBit1(void);
void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c)
{
	unsigned char m, r;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	r = BitMapOut_PrepRender_CheckBit1();
	r <<= 3;
	e[2] = c - 191 + r;
	e[3] = 127;
	PanelEvent_Post(e);
}
