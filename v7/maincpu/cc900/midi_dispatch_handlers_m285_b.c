/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiChan_SetStateMode MidiChan_SetVoiceBaseState MidiSeq_ApplyPendingParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_bc64;
extern unsigned char __near ram_bc66;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc6a;
extern unsigned char __near ram_bc6c;
extern unsigned char __near ram_bc6e;
extern unsigned char __near ram_bc70;
extern unsigned char __near ram_bc72;
extern unsigned char __near ram_bc74;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
extern unsigned char __near ram_bc7a;
extern unsigned char __near ram_bc9a;
extern unsigned char __near ram_bc9c;
extern void MidiChan_SetStateMode(void);
extern void MidiChan_SetVoiceBaseState(void);
extern void MidiSeq_ApplyPendingParams(void);
extern void MidiChan_ClearAllStates(void);

void MidiChan_ClearAllStates(void)
{
	ram_bc64 = 0;
	ram_bc66 = 0;
	ram_bc68 = 0;
	ram_bc6a = 0;
	ram_bc6c = 0;
	ram_bc6e = 0;
	ram_bc70 = 0;
	ram_bc72 = 0;
	ram_bc74 = 0;
	ram_bc76 = 0;
	ram_bc78 = 0;
	ram_bc7a = 0;
	ram_bc9a = 0;
	ram_bc9c = 0;
	MidiChan_SetStateMode();
	MidiChan_SetVoiceBaseState();
	MidiSeq_ApplyPendingParams();
}
