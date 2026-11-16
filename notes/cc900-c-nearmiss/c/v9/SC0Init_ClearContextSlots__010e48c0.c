/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_serial_routines_xr.c (2026-11-16-55-p6-r10)
   sha256 010e48c071671c67a73827234c1140531e717c7aceb183b81e0763d2a8fa2685 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
