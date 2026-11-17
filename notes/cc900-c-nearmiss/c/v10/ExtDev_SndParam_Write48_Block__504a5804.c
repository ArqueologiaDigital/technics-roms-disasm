/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m277b.c (2026-11-16-118-p6-r23)
   sha256 504a58044b65cb00c266349b78f7482879320a3421911886f4e628439bb169f1 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	unsigned char *p, *q;

	if (SndParam_LookupReadOnly(192) == 0) {
		ram_90f9 |= 2;
		e[0] = 72;
		e[1] = 4;
		p = e + 2;
		q = e + 3;
		if (*q & *p) *p = 64;
		else *p = 0;
		*q = 64;
		PanelEvent_Post(e);
	}
}
