/* Helper R, round 1 of 2026-11-20: module 203 (demo/demo_seq_bridge.s, ui/ui_playback_modes.s), small event posters.
   Form a. */
/* cc900-module: CDlikeSwTtl_ShowDocTitle CDlikeSwTtl_ShowPdTitle CDlikeSwTtl_ShowSongTitle SeqInit_LookupDispatchEntry SeqRecPlay_DisableBoth SeqRecPlay_EnablePlayOnly */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SET_VISIBLE 0x1e0009cL
#define EVT_SHOW 0x1c00001L
#define EVT_REPAINT 0x1c0000cL
#define EVT_SET_SELECTED 0x1e0004dL
#define EVT_INDEX_SELECT 0x1c0001bL
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL
#define NAKA_VIEW_DemoMed1 0xe1000bL
#define NAKA_VIEW_DemoMed2 0xe2000bL
#define NAKA_VIEW_DemoMed3 0xe3000bL
#define TT_SQTRAS 0x8b
#define TT_MESAGE 0xee

extern long ApPostEvent(long, long, long);
extern void ApDeliveryEvent(long, long, long);
extern long SeqInit_LookupDispatchEntry(unsigned int);
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned char ram_21090;
extern unsigned char ram_21092;
extern unsigned char ram_21094;
extern unsigned char __near ram_1d4a;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void Song_AbortPlayback(void);
extern void Acc_StartFillIn(void);
extern int SeqState_GetFlags(void);
extern void CDlikeSwTtl_ShowDocTitle(void);
extern void CDlikeSwTtl_ShowSongTitle(void);
extern void CDlikeSwTtl_ShowPdTitle(void);
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_DisableBoth(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);

void CDlikeSwTtl_SendStartEvtArg1(void)
{
  ApPostEvent(0x8b0003L, EVT_SET_VISIBLE, 1L);
}

void CDlikeSwTtl_SendResetEvent(void)
{
  ApPostEvent(0x8b0000L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendEvent8C_0(void)
{
  ApPostEvent(0x8c0000L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendEvent8C_13(void)
{
  ApPostEvent(0x8c0013L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SetRecordAndNotify(void)
{
  ram_21090 = 1;
  ApPostEvent(NAKA_VIEW_DemoMed1, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed2, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed3, EVT_REPAINT, 0L);
}

void SeqInit_PostDispatchEvent(void)
{
  ApDeliveryEvent(SeqInit_LookupDispatchEntry(DEMO_ACTIVE_ENTRY), EVT_SET_SELECTED, 1L);
}

void SeqInit_FinalEvent(void)
{
  ApPostEvent(-1L, EVT_INDEX_SELECT, 0L);
}

void SeqRecPlay_EnableRecordOnly(void)
{
  ram_21092 = 1;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 1L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}

void SeqRecPlay_DisableBoth(void)
{
  ram_21092 = 0;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}

void SqTrSel_CaseD(void)
{
  SeqRecPlay_DisableBoth();
  Song_AbortPlayback();
  ram_1d4a = 0;
}

void PlayMode_SwitchToModeAndNotify(void)
{
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1L);
  UI_ChangeTitleByIndex(TT_SQTRAS);
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 0L);
  GLOBAL_ERROR_CODE = 35;
  UI_InterruptTitleByIndex(TT_MESAGE);
}

void CDlikeSwTtl_DocBitCheck(void)
{
  if (!(SeqState_GetFlags() & 2) && !(SeqState_GetFlags() & 1))
    CDlikeSwTtl_ShowDocTitle();
  else {
    SeqRecPlay_DisableBoth();
    Song_AbortPlayback();
  }
}

void CDlikeSwTtl_SongConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowSongTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}

void CDlikeSwTtl_PdConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowPdTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}
