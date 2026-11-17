/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277b.c (2026-11-16-118-p6-r23)
   sha256 504a58044b65cb00c266349b78f7482879320a3421911886f4e628439bb169f1 (tar-sha256); compiled at -O3 -Xr
   cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1 */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char BitMapOut_PrepRender_CheckBit1(void);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void ExtDev_SndParam_DispatchComplex(unsigned char *e, unsigned char c)
{
	unsigned char m, r;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[3] & e[2])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	r = BitMapOut_PrepRender_CheckBit1();
	r <<= 3;
	e[2] = c - 191 + r;
	e[3] = 127;
	PanelEvent_Post(e);
}
