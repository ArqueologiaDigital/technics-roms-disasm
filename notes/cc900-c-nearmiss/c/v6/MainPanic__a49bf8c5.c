/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 a49bf8c5aa90747416ff226e4e49ae3d855194255b51ed63ee5430116a78e03e (tar-sha256); compiled at -O3 -XS -Xr
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
