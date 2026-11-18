/* Phase 6, lane_p6 helper J, round 4, module 233 (sequencer/sequencer_engine.s, -O3 -Xr), form a:
   SeqVoice_ProcessAndAssign.  For an event 0x80 the record track at 0x2324, for 0x85 / 0x86 the tracks at 0x2324
   and 0x2322, each when set (!= 0xff) and recording (bit c-1 of SEQ_RECORDING_TRACKS): assign the channel -- 0x12
   in cycle mode (SEQ_CYCLE_FLAGS bit 1), else the track number.  `1 << (c - 1)` is V4.23's and a,0xf / jr z /
   slaa; the shared calr after the two argument loads is a conditional expression. */
/* cc900-module: ToneVoice_AssignChannel */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2324;
extern unsigned char __near ram_2322;
extern unsigned int __near SEQ_RECORDING_TRACKS;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern void ToneVoice_AssignChannel(int ch, unsigned char *ev, int kind);

void SeqVoice_ProcessAndAssign(unsigned char *ev)
{
	unsigned char c;

	if (*ev == 0x80) {
		c = ram_2324;
		if (c != 0xff && ((1 << (c - 1)) & SEQ_RECORDING_TRACKS))
			ToneVoice_AssignChannel((SEQ_CYCLE_FLAGS & 2) ? 0x12 : c, ev, 4);
	}
	if (*ev == 0x85 || *ev == 0x86) {
		c = ram_2324;
		if (c != 0xff && ((1 << (c - 1)) & SEQ_RECORDING_TRACKS))
			ToneVoice_AssignChannel((SEQ_CYCLE_FLAGS & 2) ? 0x12 : c, ev, 2);
		c = ram_2322;
		if (c != 0xff && ((1 << (c - 1)) & SEQ_RECORDING_TRACKS))
			ToneVoice_AssignChannel((SEQ_CYCLE_FLAGS & 2) ? 0x12 : c, ev, 2);
	}
}
