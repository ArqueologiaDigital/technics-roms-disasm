/* Phase 6, lane_p6 helper J, round 2, module 234 (sequencer/sequencer_engine.s, -O3 -Xr), form a:
   SeqBuf_WriteMidiEvent.  A note-on (0x9n) flushes pending controller events first (flag 0x1d86), anything else
   pending note events (flag 0x1d84); then, when fewer than 15 bytes are free, the other kind; then the bytes are
   written (SeqBuf_WriteBytes is a __cdecl link-frame routine: n at +8, the pointer at +10) and the flag of this
   kind is set.  The ROM's conditional calls are V4.23's `cal cc`. */

extern unsigned char __near ram_1d84;
extern unsigned char __near ram_1d86;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);

void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d86 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d84 = 1;
	} else {
		if (ram_1d84 != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d86 = 1;
	}
}
