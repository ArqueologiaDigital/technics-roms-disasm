/* lane_p6 helper N, round 29r1, form c: module 219 (sequencer/smf_tonegen_core.s), ToneGen_AdvancePosition /
   ToneGen_AdvPosForRefresh (identical bodies).  One-spot retry of helper M's p6_M_28r1m219a (run r76, Xr, +9: the
   ROM ends the out-of-memory case with a jump to the function's one `ret`, where V4.23 returned in place for
   M's early `return`).  Form c: form a as a do { } while (0) with `break`.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near SEQ_EVENT_ABORT;
extern void ToneGen_DispatchAndLinkBlock(void);

void ToneGen_AdvancePosition(void)
{
	unsigned int o;

	o = SEQ_DATA_OFFSET;
	do {
		if (o == 0xff) {
			if (SEQ_FREE_BLOCKS == 0) {
				SEQ_EVENT_ABORT = 0xff;
				break;
			}
			ToneGen_DispatchAndLinkBlock();
		} else
			SEQ_DATA_OFFSET = o + 1;
		SEQ_EVENT_ABORT = 0;
	} while (0);
}

void ToneGen_AdvPosForRefresh(void)
{
	unsigned int o;

	o = SEQ_DATA_OFFSET;
	do {
		if (o == 0xff) {
			if (SEQ_FREE_BLOCKS == 0) {
				SEQ_EVENT_ABORT = 0xff;
				break;
			}
			ToneGen_DispatchAndLinkBlock();
		} else
			SEQ_DATA_OFFSET = o + 1;
		SEQ_EVENT_ABORT = 0;
	} while (0);
}
