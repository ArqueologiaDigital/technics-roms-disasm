/* Phase 6, lane_p6 helper L, round 2, form a: module 285 (midi/midi_dispatch_handlers.s).
   - MidiChan_ClearAllStates: clear fourteen __near state bytes, then the state mode, the voice base state and
     the pending parameters (a tail jrl).  Cell names as the matched cc900/midi_dispatch_handlers.c has them. */
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
