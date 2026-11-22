/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m219c.c (2026-11-22-11-p6-r78)
   sha256 35fd54ea9eb96927f9d1325475128b22692465e2c35f71da5ababfc0043a46c1 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near SEQ_EVENT_ABORT;
extern void ToneGen_DispatchAndLinkBlock(void);
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
