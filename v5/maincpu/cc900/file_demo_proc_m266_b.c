/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_WaitForReady Banner_Loop_Check Demo_ParseSlideHeader Demo_PreSetup Demo_ReleaseGlidePedal Demo_SelectEntry_CheckCPanel Demo_SelectEntry_PlaySong Demo_SelectEntry_StartPlayback Voice_CopyPreset Voice_LoadVoiceTable */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_25b84;
extern unsigned char __near ram_294a;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern void Demo_SelectEntry_CheckCPanel(void);
extern void Banner_Loop_Check(void);
extern void Demo_ParseSlideHeader(int n);
extern void Demo_SelectEntry_PlaySong(void);
extern void Demo_SelectEntry_StartPlayback(void);
extern void Demo_SelectEntry_TimerTick(void);
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
extern void DemoMode_Main_Operation(void);
extern unsigned char __near DEMO_DEBOUNCE;
extern void Audio_WaitForReady(void);
extern void SeqStep_PlaybackStateMachine(void);
extern void TempoRingBuf_Init(void);
extern void SeqBuf_Init(void);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Demo_SelectionEntryHandler(void);

void Demo_SelectEntry_TimerTick(void)
{
	Demo_SelectEntry_CheckCPanel();
	if (ram_25b84 != 0)
		Banner_Loop_Check();
	if (DEMO_TIMER_COUNTDOWN == 0)
		return;
	if (--DEMO_TIMER_COUNTDOWN == 10) {
		Demo_ParseSlideHeader(DEMO_ACTIVE_ENTRY);
		Demo_SelectEntry_PlaySong();
		return;
	}
	if (DEMO_TIMER_COUNTDOWN == 3) {
		Demo_SelectEntry_StartPlayback();
		return;
	}
	if (DEMO_TIMER_COUNTDOWN == 1)
		ram_294a = 133;
}

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

void Demo_SelectionEntryHandler(void)
{
	Demo_PreSetup();
	ram_294a = 0;
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
