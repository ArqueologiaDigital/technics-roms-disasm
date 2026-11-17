/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ACC_CHORD_PREV_TYPE;
extern unsigned char __near ACC_CHORD_BASS;
extern unsigned char __near ACC_CHORD_PREV_BASS;
extern unsigned char __near ram_32f3;
void AccChord_CompareAndSetDirty(void)
{
	if (ACC_CHORD_TYPE != ACC_CHORD_PREV_TYPE || ACC_CHORD_BASS != ACC_CHORD_PREV_BASS) ram_32f3 |= 32;
	if (ACC_CHORD_PREV_TYPE == 0) ram_32f3 &= 223;
}
