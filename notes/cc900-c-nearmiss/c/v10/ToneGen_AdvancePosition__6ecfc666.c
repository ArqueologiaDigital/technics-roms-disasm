/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m219a.c (2026-11-22-11-p6-r78)
   sha256 6ecfc6665e714d50bba02df7b0df9567cc8a1521ac94c6d009eff7b70f03c2b1 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
			goto out;
		}
		ToneGen_DispatchAndLinkBlock();
	} else
		SEQ_DATA_OFFSET = o + 1;
	SEQ_EVENT_ABORT = 0;
out:
	;
}
