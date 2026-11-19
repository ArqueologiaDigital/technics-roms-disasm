/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd06;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0a;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd12;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd16;
extern void MidiSeq_SyncToneStates_Upper(void);

void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bd18 & 0x40) {
        ram_bd00 &= ~0x80;
        ram_bd02 = ram_bd00;
        ram_bd04 &= ~0x80;
        ram_bd06 = ram_bd04;
        ram_bd08 &= ~0x80;
        ram_bd0a = ram_bd08;
    } else {
        ram_bd0c &= ~0x80;
        ram_bd0e = ram_bd0c;
        ram_bd10 &= ~0x80;
        ram_bd12 = ram_bd10;
        ram_bd14 &= ~0x80;
        ram_bd16 = ram_bd14;
    }
}

extern unsigned char __near ram_bd1c;
extern void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e);
extern void ParaLoadOpt_AudioFlagCheck_B(unsigned char a, unsigned char c, unsigned char e);
extern void MidiSeq_ApplyPendingParams(void);

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
