/* lane_p6 helper N, round 5, form a: module 286 (midi/midi_dispatch_handlers.s), new function.
   MidiSeq_ApplyPendingParams: when the sync-dirty bit 6 of 0xbd1c is set (MidiSeq_CheckSyncDirty, built), applies
   the three pending 7-bit values of the upper (bit 6 of 0xbd18) or lower set through the built ParaLoadOpt pair
   and clears the bit.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd14;
extern void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e);
extern void ParaLoadOpt_AudioFlagCheck_B(unsigned char a, unsigned char c, unsigned char e);

void MidiSeq_ApplyPendingParams(void)
{
	if (!(ram_bd1c & 0x40))
		return;
	if (ram_bd18 & 0x40)
		ParaLoadOpt_AudioFlagCheck(ram_bd00 & 0x7f, ram_bd04 & 0x7f, ram_bd08 & 0x7f);
	else
		ParaLoadOpt_AudioFlagCheck_B(ram_bd0c & 0x7f, ram_bd10 & 0x7f, ram_bd14 & 0x7f);
	ram_bd1c &= ~0x40;
}
