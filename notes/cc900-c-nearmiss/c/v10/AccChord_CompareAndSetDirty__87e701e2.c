/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACC_CHORD_TYPE;
extern unsigned char __near ACC_CHORD_PREV_TYPE;
extern unsigned char __near ACC_CHORD_BASS;
extern unsigned char __near ACC_CHORD_PREV_BASS;
extern unsigned char __near ram_32f3;
void AccChord_CompareAndSetDirty(void)
{
	if (ACC_CHORD_TYPE != ACC_CHORD_PREV_TYPE) goto dirty;
	if (ACC_CHORD_BASS == ACC_CHORD_PREV_BASS) goto zero;
dirty:
	ram_32f3 = ram_32f3 | 0x20;
zero:
	if (ACC_CHORD_PREV_TYPE != 0) return;
	ram_32f3 = ram_32f3 & 0xdf;
}
