/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m234a.c (2026-11-19-15-p6-r42)
   sha256 d7efe7eef9f2d9d9a7938278db54022cb6ec94fce706eeaafc7243941223c5ad (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_26e2;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
void Part_DetectSingleVoiceType(void)
{
	unsigned char n;
	unsigned char i;
	unsigned char f;
	unsigned char v;

	ram_26e2 &= ~0x01;
	n = 0;
	for (i = 1; i <= 16; i++) {
		if (SEQ_REC_TRACKS & (1 << (i - 1))) {
			n++;
			f = i;
		}
		if (n > 1)
			break;
	}
	if (n != 1) {
		PartSelect_UpdateDisplayState();
		return;
	}
	v = Part_ReadVoiceByte(0, f);
	if (v == 15)
		return;
	if (v > 0x13)
		v = 0;
	f = PartDetect_LookupAndApply_Table[v];
	ram_26e2 |= 0x01;
	PART_SELECT = f;
	AddswbWr(0x90, 0x10, f, 0xff);
}
