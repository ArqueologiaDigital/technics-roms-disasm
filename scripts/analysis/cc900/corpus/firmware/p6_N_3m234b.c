/* lane_p6 helper N, round 3, form b: module 234 (sequencer/sequencer_engine.s), Part_DetectSingleVoiceType only.
   Form b against a: the locals declared in reverse (v, f, n, i), the count and the track still swapped against
   round 1's D / L.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Part_ReadVoiceByte */

extern unsigned char __near ram_26e2;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void Part_DetectSingleVoiceType(void)
{
	unsigned char v;
	unsigned char f;
	unsigned char n;
	unsigned char i;

	ram_26e2 &= ~0x01;
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
	ram_26e2 |= 0x01;
	PART_SELECT = f;
	AddswbWr(0x90, 0x10, f, 0xff);
}
