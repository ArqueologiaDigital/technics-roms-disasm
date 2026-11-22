/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m219a.c (2026-11-22-9-p6-r76)
   sha256 5ab46aa61d6288174e004ea21e7aad6344f6ad256fd3d66619f80bbc1acec8e9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near SEQ_EVENT_ABORT;
extern void ToneGen_DispatchAndLinkBlock(void);
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
