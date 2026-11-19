/* Phase 6, lane_p6 helper M, round 4, module 234, form a: SeqPart_ConsumeTicksFromBuffer retry (run r42: +46
   @O3Xr; everything else was the ROM's code).  The spot: the block word read by PartCtrl_ReadWord; the ROM compares
   and stores HL itself and copies it to WA only for PartCtrl_TestBit7, where V4.23 moved it into a local in WA
   first.  This form: the call's value assigned inside the test (`(b = ...) > 0x4d8`). */
/* cc900-module: PartCtrl_ReadWord PartCtrl_TestBit7 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned long __near ram_25da;
extern void SeqPart_ConsumeTicksFromBuffer(unsigned int *blk, unsigned int *pos);

void SeqPart_ConsumeTicksFromBuffer(unsigned int *blk, unsigned int *pos)
{
	unsigned long room;
	unsigned long r;
	unsigned int b;

	room = (unsigned int)(0x100 - *pos);
	if (room > ram_25da) {
		*pos += ram_25da;
		return;
	}
	r = ram_25da - room;
	for (;;) {
		if ((b = PartCtrl_ReadWord(*blk)) > 0x4d8) {
			SEQ_ERROR_CODE = 10;
			return;
		}
		*blk = b;
		if (PartCtrl_TestBit7(b) == 0) {
			SEQ_ERROR_CODE = 11;
			return;
		}
		if (r <= 0xfb) {
			*pos = r + 5;
			return;
		}
		r -= 0xfb;
	}
}
