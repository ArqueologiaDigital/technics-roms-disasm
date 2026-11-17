/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_10m280.c (2026-11-16-88-p6-r16)
   sha256 4f58ab5b83d626e83ac980db8742e788b904a09f13869de835b8b78640ff1592 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];
void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;

	if (!(a & 1)) return;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x90;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[0];
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x1f;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x90;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 1;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[1];
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}
