/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m233.c (2026-11-19-43-p6-r48)
   sha256 e8a678ddc893d954887abc8d1d5bdb283b1ae063160bc5a501677bf2039c6ac3 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_1d8c;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ram_2314;
extern unsigned int __near ram_2310;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ram_1d5e;
extern unsigned int __near ram_1d60;
extern unsigned int __near ram_1d62;
extern unsigned int __near ram_1d72;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char __near SEQ_BEAT_TICK;
extern void SeqBuffer_ClearAndInitIteration(void);
extern void SeqPlay_ScanAndStoreChannelPos(void);
extern void SeqPlay_InitializePlayback(void);
int SeqPlay_CheckDrumAndStart(void)
{
	unsigned char t;

	if (ram_1d8c != 1)
		return -1;
	if (SEQ_REC_TRACKS == 0)
		return -1;
	t = ram_2314;
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		if (((1 << (t - 1)) & ram_2310) == 0)
			return -1;
	}
	SeqBuffer_ClearAndInitIteration();
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		SeqPlay_ScanAndStoreChannelPos();
		ram_1d5e = 0;
		SeqPlay_InitializePlayback();
	}
	ram_1d5e = 1;
	ram_1d60 = SEQ_BEAT_COUNT + ram_1d72;
	ram_1d62 = SEQ_BEAT_TICK;
	return 0;
}
