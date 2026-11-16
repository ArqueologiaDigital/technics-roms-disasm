/* Phase 6, lane_p6 helper D, round 12, form b: MIDI_WriteResetSequence (v10 audio/audio_control_engine.s), refined
   after run 88, where V4.23 put the queue base in XDE and the index in BC (the ROM: base in XBC, index in DE / HL).
   Form b keeps both the queue base and the PANEL_CONDUCTOR pointer in locals. */

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;
	unsigned char *q, *c;

	if (!(a & 1)) return;
	q = SWBTWR_EVENT_QUEUE;
	q[SWBTWR_WRITE_INDEX++] = 0x90;
	q[SWBTWR_WRITE_INDEX++] = 0;
	c = PANEL_CONDUCTOR;
	q[SWBTWR_WRITE_INDEX++] = c[0];
	q[SWBTWR_WRITE_INDEX++] = 0x1f;
	q[SWBTWR_WRITE_INDEX++] = 0x90;
	q[SWBTWR_WRITE_INDEX++] = 1;
	q[SWBTWR_WRITE_INDEX++] = c[1];
	q[SWBTWR_WRITE_INDEX++] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
