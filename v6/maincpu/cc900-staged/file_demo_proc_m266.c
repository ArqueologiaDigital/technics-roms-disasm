/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
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
extern unsigned char __near ram_294a;
extern unsigned char __near DEMO_DEBOUNCE;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near ram_2892;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ram_2889;
extern unsigned char __near ram_b722;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void DemoMode_Initialize(void);

/* cc900-name: ToneGen_FileIO_RestoreFromBkup=ToneGen_FileIO_RestoreFromBackup */
void DemoMode_Initialize(void)
{
	Demo_PreSetup();
	ram_294a = 0;
	DEMO_DEBOUNCE = 0;
	DEMO_TIMER_COUNTDOWN = 0;
	ram_2892 &= ~0x80;
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
	if (ram_2889 & 0x01)
		SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
	Banner_Loop_Check();
	Audio_CheckSubsystemReady();
	ram_b722 &= ~0x40;
}
