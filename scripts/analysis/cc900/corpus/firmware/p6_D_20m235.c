/* Phase 6, lane_p6 helper D, round 20, module 235 (v10 sequencer/sequencer_engine.s), form a (poolnew_D):
   MainExe_SequencerStop's 543-byte label distance covers it and four procedures after it:
   - MainExe_SequencerStop: the sequencer's stop sequence, ending in a tail jump to UI_ChangeModeByIndex(MD_SEQ_REAL);
     the part writers are called with int arguments (K&R prototypes, as sequencer_engine_m234_b.c does).
   - MainPanic, HelpLangChkMain, HelpFlashFunc: Kubo method procedures (object, event) returning 0L; the two with
     several events are switches whose cases are written last-first against the ROM's compare order.
   - HelpLang_DispatchDataBlock: a help-page switch event from the panel: picks the language's page-group table,
     shows that group's switch screen and title string (the four last ApPostEvent calls are one call in the ROM).
   The help slide table at 0x988018 is indexed by HELP_LANGUAGE * 4 computed in 8 bits, as the ROM does.
   Form b (p6_D_20m235b.c) varies the expressions noted there. */
/* cc900-module: SoundCtrl_SaveAndSendCmd_EE */   /* from scripts/analysis/cc900/module_calls.py v10 */

#define MD_SEQ_REAL              0xb
#define EVT_SHOW                 0x1c00001L
#define EVT_PANIC                0x1e80076L
#define EVT_SET_LANG             0x1e80070L
#define EVT_KUBO_FLASH_WRITE     0x1e80074L
#define EVT_KUBO_FLASH_LOAD      0x1e80075L
#define NAKA_VIEW_HelpNotXWin    0xe70005L
#define NAKA_VIEW_HelpXWin       0xe7000aL
#define NAKA_VIEW_HelpSwTtl1Scr  0xe7000eL
#define NAKA_VIEW_HelpTtlStr1    0xe70010L
#define NAKA_VIEW_HelpSwTtl2Scr  0xe70017L
#define NAKA_VIEW_HelpTtlStr2    0xe70019L
#define NAKA_VIEW_HelpSwTtl3Scr  0xe70024L
#define NAKA_VIEW_HelpTtlStr3    0xe70026L
#define NAKA_VIEW_HelpSwTtl4Scr  0xe7002cL
#define NAKA_VIEW_HelpTtlStr4    0xe7002fL

extern void SeqPlay_SaveStateAndCleanup(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern unsigned char SeqStatus_CheckBit2(void);
extern void Part_WriteAllVoiceSubBlocks_A();
extern void Part_WriteAllVoiceSubBlocks_B();
extern void Part_WriteWord();
extern void Part_ReleaseVoicesForRange();
extern void Audio_CheckSubsystemReady(void);
extern void AccWrap_PositionClear(void);
extern void Part_DetectSingleVoiceType(void);
extern void UI_ChangeModeByIndex(unsigned int);
extern void NoteMap_ProcessAndMerge(void);
extern void MIDI_BroadcastControlChange(void);
extern void SeqData_SendVoiceTableBlock(void);
extern long ApPostEvent(long, long, long);
extern unsigned char Get_Region_Code(void);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void CtrlPanel_IndicatorJumpTable(unsigned int);
extern void Audio_DispatchCommand(unsigned int);

extern unsigned char __near ram_1d94;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_28a6;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char __near ram_26fc;
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near ram_296e;
extern unsigned char __near ram_2970;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char HELP_LANGUAGE;
extern unsigned char HelpLang_ByteTable0[], HelpLang_ByteTable1[], HelpLang_ByteTable2[], HelpLang_ByteTable3[];
extern unsigned char FontPalette_Gradient7[];

void MainExe_SequencerStop(void)
{
	ram_1d94 = 0;
	SeqPlay_SaveStateAndCleanup();
	CtrlPanel_SetIndicatorBit(0x4c);
	SEQ_CYCLE_FLAGS &= ~2;
	if (SeqStatus_CheckBit2() == 0) Part_WriteAllVoiceSubBlocks_A(0);
	else Part_WriteAllVoiceSubBlocks_B(0);
	Part_WriteWord(0, 0x50, 0xffff);
	Part_ReleaseVoicesForRange(0, 0x32);
	SEQ_TRACK_MASK = 0;
	Audio_CheckSubsystemReady();
	AccWrap_PositionClear();
	ram_28a6 &= ~1;
	SEQ_TRACK_MASK_COPY = 0;
	ram_26fc = 1;
	Part_DetectSingleVoiceType();
	UI_ChangeModeByIndex(MD_SEQ_REAL);
}

long MainPanic(long obj, long ev)
{
	if (ev == EVT_PANIC) {
		NoteMap_ProcessAndMerge();
		MIDI_BroadcastControlChange();
		SeqData_SendVoiceTableBlock();
	}
	return 0;
}

void HelpLang_DispatchDataBlock(void)
{
	unsigned char a;
	unsigned char *t;

	if (SWBTWR_PAYLOAD_1 != 19) return;
	a = SWBTWR_PAYLOAD_2;
	ram_296e = a;
	if (a == ram_2970) return;
	if (a > 49) return;
	ram_2970 = a;
	if (ACTIVE_TITLE != 231) return;
	switch (HELP_LANGUAGE) {
	case 1:
		t = HelpLang_ByteTable1;
		break;
	case 2:
		t = HelpLang_ByteTable2;
		break;
	case 3:
		t = HelpLang_ByteTable3;
		break;
	case 5:
		t = FontPalette_Gradient7;
		break;
	default:
		t = HelpLang_ByteTable0;
		break;
	}
	a = t[ram_296e];
	if (a == 1) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl1Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr1, EVT_SHOW, 0);
	} else if (a == 2) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl2Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr2, EVT_SHOW, 0);
	} else if (a == 3) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl3Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr3, EVT_SHOW, 0);
	} else {
		ApPostEvent(NAKA_VIEW_HelpSwTtl4Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr4, EVT_SHOW, 0);
	}
}

long HelpLangChkMain(long obj, long ev)
{
	switch (ev) {
	case EVT_SHOW:
		if (ACTIVE_TITLE == 231 && ACTIVE_TITLE_PREVIOUS != 238) {
			if (Get_Region_Code() == 3) ApPostEvent(NAKA_VIEW_HelpXWin, EVT_SHOW, 0);
			else ApPostEvent(NAKA_VIEW_HelpNotXWin, EVT_SHOW, 0);
		}
		ram_2970 = 255;
		SLIDE_Parse_Header(*(long *)(0x988018L + (unsigned char)(HELP_LANGUAGE << 2)), (unsigned char *)0x69800L);
		break;
	case EVT_SET_LANG:
		SLIDE_Parse_Header(*(long *)(0x988018L + (unsigned char)(HELP_LANGUAGE << 2)), (unsigned char *)0x69800L);
		break;
	}
	return 0;
}

long HelpFlashFunc(long obj, long ev)
{
	switch (ev) {
	case EVT_KUBO_FLASH_WRITE:
		SoundCtrl_SaveAndSendCmd_EE(0x25);
		CtrlPanel_IndicatorJumpTable(4);
		SoundCtrl_SaveAndSendCmd_EE(0x23);
		break;
	case EVT_KUBO_FLASH_LOAD:
		Audio_DispatchCommand(4);
		break;
	}
	return 0;
}
