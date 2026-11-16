/* Phase 6, lane_p6 helper D, round 15, form a: MIDI_WriteResetSequence (v10 audio/audio_control_engine.s) after
   run 100 (round 12 loaded the queue base before the index; round 10 had the right order with base and index in each
   other's registers).  Form a takes each index into a local first; form b (p6_D_15b.c) adds to the base instead of
   indexing. */

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;
	unsigned int i;

	if (!(a & 1)) return;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 0x90;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 0;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = PANEL_CONDUCTOR[0];
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 0x1f;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 0x90;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 1;
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = PANEL_CONDUCTOR[1];
	i = SWBTWR_WRITE_INDEX++;
	SWBTWR_EVENT_QUEUE[i] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
