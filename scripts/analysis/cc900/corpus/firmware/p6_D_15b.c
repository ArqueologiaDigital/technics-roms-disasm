/* Phase 6, lane_p6 helper D, round 15, form b: MIDI_WriteResetSequence (see p6_D_15a.c), written as base plus
   post-incremented index. */

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;

	if (!(a & 1)) return;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 0x90;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 0;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = PANEL_CONDUCTOR[0];
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 0x1f;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 0x90;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 1;
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = PANEL_CONDUCTOR[1];
	*(SWBTWR_EVENT_QUEUE + SWBTWR_WRITE_INDEX++) = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
