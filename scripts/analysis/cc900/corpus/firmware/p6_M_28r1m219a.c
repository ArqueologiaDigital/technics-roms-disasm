/* lane_p6 helper M, round 28r1, form a: module 219 (sequencer/smf_tonegen_core.s), the family
   ToneGen_AdvancePosition / ToneGen_AdvPosForRefresh (identical bodies): step the SMF write position
   SEQ_DATA_OFFSET; at 0xff link a new block (ToneGen_DispatchAndLinkBlock) unless SEQ_FREE_BLOCKS is 0,
   which sets SEQ_EVENT_ABORT = 0xff (out of memory); SEQ_EVENT_ABORT = 0 otherwise.  Form a: the end-of-block case first.
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
	if (o == 0xff) {
		if (SEQ_FREE_BLOCKS == 0) {
			SEQ_EVENT_ABORT = 0xff;
			return;
		}
		ToneGen_DispatchAndLinkBlock();
	} else
		SEQ_DATA_OFFSET = o + 1;
	SEQ_EVENT_ABORT = 0;
}

void ToneGen_AdvPosForRefresh(void)
{
	unsigned int o;

	o = SEQ_DATA_OFFSET;
	if (o == 0xff) {
		if (SEQ_FREE_BLOCKS == 0) {
			SEQ_EVENT_ABORT = 0xff;
			return;
		}
		ToneGen_DispatchAndLinkBlock();
	} else
		SEQ_DATA_OFFSET = o + 1;
	SEQ_EVENT_ABORT = 0;
}
