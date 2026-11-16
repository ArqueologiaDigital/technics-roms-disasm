/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15b.c (2026-11-16-107-p6-r21)
   sha256 8a4cf10633ca2db483befb3c9488d7177ee17d9c40f9da020b4e69a99d13df6a (tar-sha256); compiled at -O3 -Xr */
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
