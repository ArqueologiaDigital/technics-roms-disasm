/* Phase 6, lane_p6 helper D, round 12, form a: MIDI_WriteResetSequence (v10 audio/audio_control_engine.s), refined
   after run 88, where V4.23 put the queue base in XDE and the index in BC (the ROM: base in XBC, index in DE / HL).
   Form a keeps the queue base in a local pointer; form b (p6_D_12b.c) also the PANEL_CONDUCTOR pointer. */

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;
	unsigned char *q;

	if (!(a & 1)) return;
	q = SWBTWR_EVENT_QUEUE;
	q[SWBTWR_WRITE_INDEX++] = 0x90;
	q[SWBTWR_WRITE_INDEX++] = 0;
	q[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[0];
	q[SWBTWR_WRITE_INDEX++] = 0x1f;
	q[SWBTWR_WRITE_INDEX++] = 0x90;
	q[SWBTWR_WRITE_INDEX++] = 1;
	q[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[1];
	q[SWBTWR_WRITE_INDEX++] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
