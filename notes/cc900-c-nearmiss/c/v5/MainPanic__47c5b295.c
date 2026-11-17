/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 47c5b2956267f854bb877a6f5af62d2cc7db83834a7450cc4cedd184de662582 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_PANIC                0x1e80076L
extern void NoteMap_ProcessAndMerge(void);
extern void MIDI_BroadcastControlChange(void);
extern void SeqData_SendVoiceTableBlock(void);
long MainPanic(long obj, long ev)
{
	if (ev == EVT_PANIC) {
		NoteMap_ProcessAndMerge();
		MIDI_BroadcastControlChange();
		SeqData_SendVoiceTableBlock();
	}
	return 0;
}
