/* lane_p6 helper N, round 4, form a: module 266 (demo/file_demo_proc.s), new functions.
   DemoMode_Main_Operation: enters demo mode -- saves the live panel records (PANEL_RECORDS .. 0xffbe + 2) to
   0x3cf04 (the destination pushed as two word halves: an extern object, not a number), resets voices, MIDI flags
   and the demo state, and starts the main sequencer control (tail jump).
   Demo_SelectionEntryHandler: resets the demo selection state and restarts playback (tail jump to
   Banner_Loop_Check).  SwbtB3_CodeA9_Listener0: the demo selection button's debounce (16 while a button of mask
   0x13 is newly pressed, else 0).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_WaitForReady Banner_Loop_Check Demo_PreSetup Demo_ReleaseGlidePedal Voice_CopyPreset Voice_LoadVoiceTable */

extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near PANEL_RECORDS;
extern unsigned char __near ram_ffbe;
extern unsigned char ram_3cf04;
extern unsigned char __near PANEL_MIDI[];
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

extern unsigned char __near ram_2966;
extern unsigned char __near DEMO_DEBOUNCE;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern void Audio_WaitForReady(void);
extern void SeqStep_PlaybackStateMachine(void);
extern void TempoRingBuf_Init(void);
extern void SeqBuf_Init(void);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Banner_Loop_Check(void);

void Demo_SelectionEntryHandler(void)
{
	Demo_PreSetup();
	ram_2966 = 0;
	DEMO_DEBOUNCE = 0;
	DEMO_TIMER_COUNTDOWN = 0;
	Audio_WaitForReady();
	SeqStep_PlaybackStateMachine();
	DEMO_CONTROL_FLAGS &= ~0x08;
	SeqInit_PostEventSequence();
	TempoRingBuf_Init();
	SeqBuf_Init();
	CtrlPanel_SetIndicatorLED(0x22);
	Banner_Loop_Check();
}

extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near SWBTWR_PAYLOAD_3;

void SwbtB3_CodeA9_Listener0(void)
{
	if (SWBTWR_PAYLOAD_1 != 32)
		return;
	if ((SWBTWR_PAYLOAD_3 & 0x13) == 0)
		return;
	if (SWBTWR_PAYLOAD_2 & 0x13)
		DEMO_DEBOUNCE = 16;
	else
		DEMO_DEBOUNCE = 0;
}
