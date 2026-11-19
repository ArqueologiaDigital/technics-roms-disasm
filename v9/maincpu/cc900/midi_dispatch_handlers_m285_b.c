/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiChan_SetStateMode MidiChan_SetVoiceBaseState MidiSeq_ApplyPendingParams */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd38;
extern void MidiChan_SetStateMode(void);
extern void MidiChan_SetVoiceBaseState(void);
extern void MidiSeq_ApplyPendingParams(void);
extern void MidiChan_ClearAllStates(void);

void MidiChan_ClearAllStates(void)
{
	ram_bd00 = 0;
	ram_bd02 = 0;
	ram_bd04 = 0;
	ram_bd06 = 0;
	ram_bd08 = 0;
	ram_bd0a = 0;
	ram_bd0c = 0;
	ram_bd0e = 0;
	ram_bd10 = 0;
	ram_bd12 = 0;
	ram_bd14 = 0;
	ram_bd16 = 0;
	ram_bd36 = 0;
	ram_bd38 = 0;
	MidiChan_SetStateMode();
	MidiChan_SetVoiceBaseState();
	MidiSeq_ApplyPendingParams();
}
