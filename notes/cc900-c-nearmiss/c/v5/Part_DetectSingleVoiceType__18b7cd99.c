/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-19-29-p6-r46)
   sha256 18b7cd99d8b231daba0ba4aeddb6c2117e2469124ca962e1ec140c8521983203 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_26c8;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
void Part_DetectSingleVoiceType(void)
{
	unsigned char i;
	unsigned char n;
	unsigned char f;
	unsigned char v;

	ram_26c8 &= ~0x01;
	n = 0;
	i = 1;
	do {
		if ((1 << (i - 1)) & SEQ_REC_TRACKS) {
			n++;
			f = i;
		}
	} while (n <= 1 && ++i <= 16);
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
	ram_26c8 |= 0x01;
	PART_SELECT = f;
	AddswbWr(0x90, 0x10, f, 0xff);
}
