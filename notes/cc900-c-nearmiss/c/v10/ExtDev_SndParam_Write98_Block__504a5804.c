/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277b.c (2026-11-16-118-p6-r23)
   sha256 504a58044b65cb00c266349b78f7482879320a3421911886f4e628439bb169f1 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_90f9;
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_Write98_Block(unsigned char *e)
{
	unsigned char *p, *q;

	if (SndParam_LookupViaEncode(PART_SELECT, 1539) == 1) {
		ram_90f9 |= 2;
		e[0] = 152;
		e[1] = 2;
		p = e + 2;
		q = e + 3;
		if (*q & *p) *p = 128;
		else *p = 0;
		*q = 128;
		PanelEvent_Post(e);
	}
}
