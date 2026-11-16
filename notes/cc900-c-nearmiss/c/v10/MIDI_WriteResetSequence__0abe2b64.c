/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15a.c (2026-11-16-107-p6-r21)
   sha256 0abe2b64530475194714819e4afc1b2d0bc2cdc552da99358e6d3424e0c9c9dc (tar-sha256); compiled at -O3 -Xr */
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
