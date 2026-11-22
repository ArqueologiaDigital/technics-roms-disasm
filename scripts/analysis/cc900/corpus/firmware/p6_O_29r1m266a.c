/* lane_p6 helper O, round 29r1, form a: module 266 (demo/file_demo_proc.s), DemoMode_Initialize (100 B,
   singletons29_O): the demo-mode set-up sequence: clears the demo cells, resets the MIDI channels, runs the
   sequencer / tone / tempo initialisers, lights indicator 0x22, copies SEQ_TRACK_MASK_COPY to SEQ_TRACK_MASK when
   bit 0 of 0x28a5 is set (the ROM's word memory-to-memory move: the __near cell is the destination), then the banner
   check.  Form a: plain cells (the word move needs no volatile).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_WaitForReady Banner_Loop_Check Demo_PreSetup Voice_SavePreset */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void Demo_PreSetup(void);
extern void MidiChannel_ResetAndConfigure(void);
extern void Audio_WaitForReady(void);
extern void SeqStep_PlaybackStateMachine(void);
extern void Voice_SavePreset(void);
extern void SeqInit_PostEventSequence(void);
extern void ToneGen_FileIO_RestoreFromBkup(void);
extern void SeqTimer_UpdateTempoReg(void);
extern void Voice_InitializeAll(void);
extern void Seq_StartMainControlAlt(void);
extern void TempoRingBuf_Init(void);
extern void SeqBuf_Init(void);
extern void CtrlPanel_SetIndicatorLED(int);
extern void Banner_Loop_Check(void);
extern void Audio_CheckSubsystemReady(void);
extern unsigned char __near ram_2966;
extern unsigned char __near DEMO_DEBOUNCE;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near ram_28ae;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ram_28a5;
extern unsigned char __near ram_b7e2;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void DemoMode_Initialize(void);

/* cc900-name: ToneGen_FileIO_RestoreFromBkup=ToneGen_FileIO_RestoreFromBackup */
void DemoMode_Initialize(void)
{
	Demo_PreSetup();
	ram_2966 = 0;
	DEMO_DEBOUNCE = 0;
	DEMO_TIMER_COUNTDOWN = 0;
	ram_28ae &= ~0x80;
	MidiChannel_ResetAndConfigure();
	Audio_WaitForReady();
	SeqStep_PlaybackStateMachine();
	Voice_SavePreset();
	DEMO_CONTROL_FLAGS &= ~0x08;
	SeqInit_PostEventSequence();
	ToneGen_FileIO_RestoreFromBkup();
	SeqTimer_UpdateTempoReg();
	Voice_InitializeAll();
	Seq_StartMainControlAlt();
	TempoRingBuf_Init();
	SeqBuf_Init();
	CtrlPanel_SetIndicatorLED(0x22);
	if (ram_28a5 & 0x01)
		SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
	Banner_Loop_Check();
	Audio_CheckSubsystemReady();
	ram_b7e2 &= ~0x40;
}
