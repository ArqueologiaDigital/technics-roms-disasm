/* lane_p6 helper N, round 5, form a: module 233 (sequencer/sequencer_engine.s), new function.
   SeqPlay_CheckDrumAndStart: with mode 0x1d92 = 1 and a track armed, and (in the second transport mode) or with
   the current track's bit set in 0x2316, starts playback: clears the buffers, (first mode) scans the channel
   positions and initialises playback, then sets the playback position from beat count + 0x1d78 and the beat
   tick.  0 when started, else -1.  The track bit as `(1 << (t - 1)) & cell` (the built Part_DetectSingleVoiceType).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPlay_InitializePlayback SeqPlay_ScanAndStoreChannelPos */

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
