/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ACC_PENDING_STYLE;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
void AccChannel_CheckActivitySetDirty(void)
{
	if (((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2 | ACC_LANES_INTRO1 | ACC_LANES_COUNTIN | ACC_LANES_INTRO2) & 0x3f)
	    && ACC_PENDING_STYLE >= 128)
		ACC_DEFER_ENDING_LANES |= 63;
}
