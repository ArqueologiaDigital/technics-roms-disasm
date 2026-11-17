/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SoundCtrl_SaveAndSendCmd_EE */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_KUBO_FLASH_WRITE     0x1e80074L
#define EVT_KUBO_FLASH_LOAD      0x1e80075L
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void CtrlPanel_IndicatorJumpTable(unsigned int);
extern void Audio_DispatchCommand(unsigned int);
extern long HelpFlashFunc(long obj, long ev);
#define EVT_SHOW                 0x1c00001L
#define EVT_SET_LANG             0x1e80070L
#define NAKA_VIEW_HelpNotXWin    0xe70005L
#define NAKA_VIEW_HelpXWin       0xe7000aL
extern long ApPostEvent(long, long, long);
extern unsigned char Get_Region_Code(void);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern unsigned char __near ram_2970;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char HELP_LANGUAGE;
extern long HelpLangChkMain(long obj, long ev);
#define EVT_PANIC                0x1e80076L
extern void NoteMap_ProcessAndMerge(void);
extern void MIDI_BroadcastControlChange(void);
extern void SeqData_SendVoiceTableBlock(void);
extern long MainPanic(long obj, long ev);

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

long MainPanic(long obj, long ev)
{
	if (ev == EVT_PANIC) {
		NoteMap_ProcessAndMerge();
		MIDI_BroadcastControlChange();
		SeqData_SendVoiceTableBlock();
	}
	return 0;
}
