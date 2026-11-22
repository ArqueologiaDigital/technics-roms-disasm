/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m219b.c (2026-11-22-11-p6-r78)
   sha256 7173bb0c9bda8c99a38a3fac176dc595e279f1f633d4500a7eefffeb907e65f9 (tar-sha256); compiled at -O3 -Xr
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
		if (SEQ_FREE_BLOCKS == 0)
			SEQ_EVENT_ABORT = 0xff;
		else {
			ToneGen_DispatchAndLinkBlock();
			SEQ_EVENT_ABORT = 0;
		}
	} else {
		SEQ_DATA_OFFSET = o + 1;
		SEQ_EVENT_ABORT = 0;
	}
}
