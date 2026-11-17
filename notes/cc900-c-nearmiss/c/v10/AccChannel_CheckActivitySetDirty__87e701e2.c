/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ACC_PENDING_STYLE;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
void AccChannel_CheckActivitySetDirty(void)
{
	unsigned char a;

	a = ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2 | ACC_LANES_INTRO1 | ACC_LANES_COUNTIN | ACC_LANES_INTRO2;
	if (!(a & 0x3f)) return;
	if (ACC_PENDING_STYLE < 128) return;
	ACC_DEFER_ENDING_LANES |= 63;
}
