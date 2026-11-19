/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiChan_SetStateMode MidiChan_SetVoiceBaseState MidiSeq_ApplyPendingParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_bc40;
extern unsigned char __near ram_bc42;
extern unsigned char __near ram_bc44;
extern unsigned char __near ram_bc46;
extern unsigned char __near ram_bc48;
extern unsigned char __near ram_bc4a;
extern unsigned char __near ram_bc4c;
extern unsigned char __near ram_bc4e;
extern unsigned char __near ram_bc50;
extern unsigned char __near ram_bc52;
extern unsigned char __near ram_bc54;
extern unsigned char __near ram_bc56;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
extern void MidiChan_SetStateMode(void);
extern void MidiChan_SetVoiceBaseState(void);
extern void MidiSeq_ApplyPendingParams(void);
extern void MidiChan_ClearAllStates(void);

void MidiChan_ClearAllStates(void)
{
	ram_bc40 = 0;
	ram_bc42 = 0;
	ram_bc44 = 0;
	ram_bc46 = 0;
	ram_bc48 = 0;
	ram_bc4a = 0;
	ram_bc4c = 0;
	ram_bc4e = 0;
	ram_bc50 = 0;
	ram_bc52 = 0;
	ram_bc54 = 0;
	ram_bc56 = 0;
	ram_bc76 = 0;
	ram_bc78 = 0;
	MidiChan_SetStateMode();
	MidiChan_SetVoiceBaseState();
	MidiSeq_ApplyPendingParams();
}
