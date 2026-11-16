/* Functions of midi/midi_serial_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near MIDI_RX_CONTEXT[];

void SC0Init_ClearContextSlots(void)
{
	MIDI_RX_CONTEXT[0] = 0;
	MIDI_RX_CONTEXT[4] = 0;
	MIDI_RX_CONTEXT[8] = 0;
	MIDI_RX_CONTEXT[12] = 0;
	MIDI_RX_CONTEXT[16] = 0;
	MIDI_RX_CONTEXT[20] = 0;
	MIDI_RX_CONTEXT[24] = 0;
}
