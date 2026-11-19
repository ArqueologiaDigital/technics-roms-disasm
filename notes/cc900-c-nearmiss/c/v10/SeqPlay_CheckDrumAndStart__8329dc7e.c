/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m233a.c (2026-11-19-37-p6-r47)
   sha256 8329dc7ed6e52b78bebebac7a39a9c04cc71db54ce75aa866dff14ee7dd1ec41 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d92;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ram_231a;
extern unsigned int __near ram_2316;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ram_1d62;
extern unsigned int __near ram_1d64;
extern unsigned int __near ram_1d66;
extern unsigned int __near ram_1d78;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char __near SEQ_BEAT_TICK;
extern void SeqBuffer_ClearAndInitIteration(void);
extern void SeqPlay_ScanAndStoreChannelPos(void);
extern void SeqPlay_InitializePlayback(void);
int SeqPlay_CheckDrumAndStart(void)
{
	unsigned char t;

	if (ram_1d92 != 1)
		return -1;
	if (SEQ_REC_TRACKS == 0)
		return -1;
	t = ram_231a;
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		if (((1 << (t - 1)) & ram_2316) == 0)
			return -1;
	}
	SeqBuffer_ClearAndInitIteration();
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		SeqPlay_ScanAndStoreChannelPos();
		ram_1d62 = 0;
		SeqPlay_InitializePlayback();
	}
	ram_1d62 = 1;
	ram_1d64 = SEQ_BEAT_COUNT + ram_1d78;
	ram_1d66 = SEQ_BEAT_TICK;
	return 0;
}
