/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void SeqError_MapToGlobal(unsigned char *t);

void SeqError_MapToGlobal(unsigned char *t)
{
  GLOBAL_ERROR_CODE = t[SEQ_ERROR_CODE];
}

/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */
extern unsigned int __near ram_29b2[];
#define TBL_29CE ((unsigned int *)ram_29b2)
extern long FileIO_SeekAndRead16BitValue(unsigned long, unsigned int);
extern void SeqData_SetErrorCode(unsigned char);
extern long SeqLoad_ReadPartDataBlock(unsigned char a);

long SeqLoad_ReadPartDataBlock(unsigned char a)
{
  unsigned long pos;
  unsigned int i, sum;
  long r;
  if (TBL_29CE[a] == 0) return 0;
  pos = 0x800;
  sum = 0;
  for (i = 0; i < a; i++) {
    pos += (unsigned long)ram_29b2[i] << 8;
    sum += ram_29b2[i];
  }
  pos += 1;
  for (i = 1; i < TBL_29CE[a]; i++) {
    if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(200); return r; }
    if ((r = FileIO_SeekAndRead16BitValue(pos + 2, sum + i + 1)) != 0) { SeqData_SetErrorCode(201); return r; }
    pos += 256;
  }
  if ((r = FileIO_SeekAndRead16BitValue(pos, sum + i - 1)) != 0) { SeqData_SetErrorCode(202); return r; }
  if ((r = FileIO_SeekAndRead16BitValue(pos + 2, 0xffff)) != 0) { SeqData_SetErrorCode(203); return r; }
  return r;
}

/* cc900-module: SoundCtrl_SaveAndSendCmd_EE */
#define EVT_SHOW                 0x1c00001L
#define EVT_SET_LANG             0x1e80070L
#define NAKA_VIEW_HelpNotXWin    0xe70005L
#define NAKA_VIEW_HelpXWin       0xe7000aL
extern long ApPostEvent(long, long, long);
extern unsigned char Get_Region_Code(void);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern unsigned char __near ram_2954;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char HELP_LANGUAGE;
extern long HelpLangChkMain(long obj, long ev);
#define EVT_PANIC                0x1e80076L
extern void NoteMap_ProcessAndMerge(void);
extern void MIDI_BroadcastControlChange(void);
extern void SeqData_SendVoiceTableBlock(void);
extern long MainPanic(long obj, long ev);

long HelpLangChkMain(long obj, long ev)
{
	switch (ev) {
	case EVT_SHOW:
		if (ACTIVE_TITLE == 231 && ACTIVE_TITLE_PREVIOUS != 238) {
			if (Get_Region_Code() == 3) ApPostEvent(NAKA_VIEW_HelpXWin, EVT_SHOW, 0);
			else ApPostEvent(NAKA_VIEW_HelpNotXWin, EVT_SHOW, 0);
		}
		ram_2954 = 255;
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
