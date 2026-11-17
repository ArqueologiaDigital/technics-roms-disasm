/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -Xr */
struct bit0 { unsigned char rest : 7; unsigned char b0 : 1; };
extern unsigned char __near ram_3306;
extern unsigned char __near ram_3338;
extern unsigned char __near ACC_VARIATION_REQUEST;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_STYLE_NUMBER;
extern unsigned char __near ACC_STYLE_ARRANGER_ON;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern struct bit0 __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
void AccentVoice_DetectAndMarkChange(void)
{
	if (ACC_VARIATION_REQUEST != ram_3306 && !((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & 0x3f)
	    && ACC_STYLE_NUMBER < 240 && ACC_STYLE_NUMBER < 128) {
		if (!(ACC_STYLE_ARRANGER_ON & 1) || !((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2) & 0x3f)) {
			if ((ACC_VARIATION_REQUEST & 3) != ram_3338) ACC_VARIATION_CHANGE_PENDING.b0 = 1;
		}
	}
	ACC_VARIATION_NEXT = ACC_VARIATION_REQUEST & 3;
}
