/* Phase 6, lane_p6 helper M, round 4, module 234, form b: SeqPart_ConsumeTicksFromBuffer retry (alternative to
   p6_M_4m234a.c).  The block word stored first and tested through the cell: `*blk = ReadWord(*blk)` is not the
   ROM's order (it tests before storing), so this form keeps the test first but stores the call's value and passes
   *blk to PartCtrl_TestBit7 (a reload the ROM may have kept in HL -> WA). */
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
		b = PartCtrl_ReadWord(*blk);
		if (b > 0x4d8) {
			SEQ_ERROR_CODE = 10;
			return;
		}
		if (PartCtrl_TestBit7(*blk = b) == 0) {
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
