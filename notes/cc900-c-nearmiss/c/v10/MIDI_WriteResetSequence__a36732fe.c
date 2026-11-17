/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_12a.c (2026-11-16-100-p6-r19)
   sha256 a36732fe43436a2d8000bd059e1b87f18d5dd20b217c19bf2529a36fa60bd70b (tar-sha256); compiled at -O3 -Xr */
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
