/* lane_p6 helper N, round 5, form a: module 266 (demo/file_demo_proc.s), DemoMode_Main_Operation only, retry of
   p6_N_4m266a (p6-r46 O3Xr: +45).  V4.23 merged `PANEL_MIDI[0] |= 0x10; PANEL_MIDI[0] &= ~4` into one load,
   set, store, res, store through a pointer; the ROM sets and resets the bits in memory, each on its own
   (`set 4,(PANEL_MIDI)`, `res 2,(PANEL_MIDI)`, `res 2,(PANEL_MIDI+2)`).  Form a: PANEL_MIDI volatile.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Demo_PreSetup Demo_ReleaseGlidePedal Voice_CopyPreset Voice_LoadVoiceTable */

extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near PANEL_RECORDS;
extern unsigned char __near ram_ffbe;
extern unsigned char ram_3cf04;
extern volatile unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_45b;
extern unsigned char __near ram_b7e2;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void Voice_InitializeAll(void);
extern void Fade_Cancel(void);
extern void Voice_LoadVoiceTable(void);
extern void Demo_PreSetup(void);
extern void AccompSeq_StopSequence(void);
extern void Voice_CopyPreset(void);
extern void MIDI_BroadcastPitchReset(void);
extern void Demo_ReleaseGlidePedal(void);
extern void Audio_CheckSubsystemReady(void);
extern void SeqInit_PostEventSequence(void);
extern void SeqInit_FinalEvent(void);
extern void Seq_StartMainControl(void);

void DemoMode_Main_Operation(void)
{
	SEQ_CYCLE_FLAGS &= ~0x01;
	Voice_InitializeAll();
	Mem_Copy(&ram_3cf04, &PANEL_RECORDS, &ram_ffbe - &PANEL_RECORDS + 2);
	Fade_Cancel();
	Voice_LoadVoiceTable();
	PANEL_MIDI[0] |= 0x10;
	PANEL_MIDI[0] &= ~0x04;
	PANEL_MIDI[2] &= ~0x04;
	Demo_PreSetup();
	ram_45b &= ~0x01;
	AccompSeq_StopSequence();
	Voice_CopyPreset();
	MIDI_BroadcastPitchReset();
	Demo_ReleaseGlidePedal();
	Audio_CheckSubsystemReady();
	ram_b7e2 |= 0x40;
	DEMO_CONTROL_FLAGS &= ~0x08;
	SeqInit_PostEventSequence();
	SeqInit_FinalEvent();
	Seq_StartMainControl();
}
