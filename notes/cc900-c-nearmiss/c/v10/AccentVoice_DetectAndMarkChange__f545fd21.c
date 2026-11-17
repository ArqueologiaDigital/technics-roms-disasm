/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_3306;
extern unsigned char __near ram_3338;
extern unsigned char __near ACC_VARIATION_REQUEST;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_STYLE_NUMBER;
extern unsigned char __near ACC_STYLE_ARRANGER_ON;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern unsigned char __near ACC_VARIATION_CHANGE_PENDING;
extern unsigned char __near ACC_VARIATION_NEXT;
void AccentVoice_DetectAndMarkChange(void)
{
	if (ram_3306 == ACC_VARIATION_REQUEST) goto upd;
	if ((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & 0x3f) goto upd;
	if (ACC_STYLE_NUMBER >= 240) goto upd;
	if (ACC_STYLE_NUMBER >= 128) goto upd;
	if ((ACC_STYLE_ARRANGER_ON & 1) && ((ACC_LANES_FILLIN1 | ACC_LANES_FILLIN2) & 0x3f)) goto upd;
	if ((ACC_VARIATION_REQUEST & 3) != ram_3338) ACC_VARIATION_CHANGE_PENDING |= 1;
upd:
	ACC_VARIATION_NEXT = ACC_VARIATION_REQUEST & 3;
}
