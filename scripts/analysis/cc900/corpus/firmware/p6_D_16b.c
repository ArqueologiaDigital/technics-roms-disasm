/* Phase 6, lane_p6 helper D, round 16, form b: MIDI_WriteResetSequence (see p6_D_16a.c) with the conductor pointer
   declared first (extern and local) and the queue pointer `register`, to flip V4.23's XBC / XDE choice. */

extern unsigned char __near ram_90f9;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;
	unsigned char *c;
	register unsigned char *q;
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
