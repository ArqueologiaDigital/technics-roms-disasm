/* Phase 6, lane_p6 helper K, round 2, module 234 (sequencer/sequencer_engine.s, an -O file), form a:
   PartCtrl_FindActiveByLimit(blk, pos).  n = *pos - 4 (unsigned long) against the __near long at 0x25da (the hand
   source spells the address 9690): above it, *pos = n - limit + 4; otherwise it follows the sequence-data block
   chain from *blk (PartCtrl_ReadWord_Off1, at most 0x4d8, else SEQ_ERROR_CODE 10; the block must have bit 7 set,
   PartCtrl_TestBit7, else 11), stepping 0xfb bytes per block, and stores 0xff - remainder. */
/* cc900-module: PartCtrl_ReadWord_Off1 PartCtrl_TestBit7 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned long __near ram_25da;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);

void PartCtrl_FindActiveByLimit(unsigned int *blk, unsigned int *pos)
{
	unsigned long n;
	unsigned long k;
	unsigned int w;

	n = (unsigned long)*pos - 4;
	if (n > ram_25da)
		n = n - ram_25da + 4;
	else {
		k = ram_25da - n;
		for (;;) {
			w = PartCtrl_ReadWord_Off1(*blk);
			if (w > 0x4d8) {
				SEQ_ERROR_CODE = 10;
				return;
			}
			*blk = w;
			if (PartCtrl_TestBit7(w) == 0) {
				SEQ_ERROR_CODE = 11;
				return;
			}
			if (k <= 0xfb)
				break;
			k -= 0xfb;
		}
		n = 0xff - k;
	}
	*pos = n;
}
