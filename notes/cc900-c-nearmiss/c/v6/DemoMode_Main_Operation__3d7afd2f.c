/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc_m266.c (2026-11-19-43-p6-r48)
   sha256 3d7afd2f7783c5ee2d41e46492f2d7ef32313d4cfbcc0b03ae4805dd2889f287 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near PANEL_RECORDS;
extern unsigned char __near ram_ffbe;
extern unsigned char ram_3cf04;
extern volatile unsigned char __near PANEL_MIDI[];
extern unsigned char __near ram_45b;
extern unsigned char __near ram_b722;
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
	ram_b722 |= 0x40;
	DEMO_CONTROL_FLAGS &= ~0x08;
	SeqInit_PostEventSequence();
	SeqInit_FinalEvent();
	Seq_StartMainControl();
}
