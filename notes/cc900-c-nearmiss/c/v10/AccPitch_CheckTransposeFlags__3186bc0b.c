/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACC_SECTION_BUTTONS_HELD;
extern unsigned char __near ram_3281;
extern unsigned char __near ram_3280;
extern unsigned char __near ACC_BEATS_PER_BAR;
extern unsigned char __near ram_3329;
void AccPitch_CheckTransposeFlags(void)
{
	if (!(ACC_SECTION_BUTTONS_HELD & 0x40) && (ram_3281 & 0x40) && ram_3280 + 1 == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
	if (!(ACC_SECTION_BUTTONS_HELD & 0x80) && (ram_3281 & 0x80) && ram_3280 + 1 == ACC_BEATS_PER_BAR)
		ram_3329 |= 63;
}
