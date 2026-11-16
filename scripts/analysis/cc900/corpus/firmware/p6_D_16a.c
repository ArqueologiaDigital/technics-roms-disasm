/* Phase 6, lane_p6 helper D, round 16, form a: MIDI_WriteResetSequence (v10 audio/audio_control_engine.s) after
   run 107.  At -O3 -Xr round 15 differed only in two registers: V4.23 kept the queue base in XDE and the conductor
   base in XBC, the ROM the other way round.  Here both bases are user pointer locals, assigned where the ROM first
   loads them (after the first index), so the allocator sees variables instead of common subexpressions.  Form b
   (p6_D_16b.c) declares the conductor pointer first and the queue pointer `register`. */

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;
	unsigned char *q, *c;
	unsigned int i;

	if (!(a & 1)) return;
	i = SWBTWR_WRITE_INDEX++;
	q = SWBTWR_EVENT_QUEUE;
	q[i] = 0x90;
	i = SWBTWR_WRITE_INDEX++;
	q[i] = 0;
	i = SWBTWR_WRITE_INDEX++;
	c = PANEL_CONDUCTOR;
	q[i] = c[0];
	i = SWBTWR_WRITE_INDEX++;
	q[i] = 0x1f;
	i = SWBTWR_WRITE_INDEX++;
	q[i] = 0x90;
	i = SWBTWR_WRITE_INDEX++;
	q[i] = 1;
	i = SWBTWR_WRITE_INDEX++;
	q[i] = c[1];
	i = SWBTWR_WRITE_INDEX++;
	q[i] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
