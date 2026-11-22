/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_Q_20r1m203a.c (2026-11-21-2-p6-r58)
   sha256 f7074433fcaa55e38a1cae9e0ec3c4d2596605924613a4a1825fa9760aa42e09 (tar-sha256); compiled at -O3 -XS -Xr */
/* helper Q, round 20r1, module 203 (demo/demo_seq_bridge.s and ui/ui_playback_modes.s): CD-like title event posts. */
/* cc900-module: CDlikeSwTtl_ShowDocTitle CDlikeSwTtl_ShowPdTitle SeqRecPlay_DisableBoth SeqRecPlay_EnablePlayOnly SeqRecPlay_EnableRecordOnly */

extern unsigned char ram_21090;
extern unsigned char ram_21092;
extern unsigned char ram_21094;
extern unsigned char __near ram_1d4a;
extern long Demo_SongViewIdTable[];
extern long ApPostEvent(long, long, long);
extern int SeqState_GetFlags(void);
extern void CDlikeSwTtl_ShowDocTitle(void);
extern void CDlikeSwTtl_ShowPdTitle(void);
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_EnableRecordOnly(void);
extern void SeqRecPlay_DisableBoth(void);
extern void Song_AbortPlayback(void);
extern void Acc_StartFillIn(void);
extern void Acc_TransitionPlayMode(void);
extern void Acc_StopPlayMode(void);

#define EVT_SHOW 0x1c00001L
#define EVT_REPAINT 0x1c0000cL
#define EVT_LYRICS_ALL_CLEAR 0x1c70009L
#define EVT_SET_VISIBLE 0x1e0009cL
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
#define NAKA_VIEW_DemoMed1 0xe1000bL
#define NAKA_VIEW_DemoMed2 0xe2000bL
#define NAKA_VIEW_DemoMed3 0xe3000bL

void SeqInit_PostEventSequence(void)
{
  ram_21090 = 0;
  ApPostEvent(NAKA_VIEW_DemoMed1, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed2, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed3, EVT_REPAINT, 0L);
}

void SeqRecPlay_EnablePlayOnly(void)
{
  ram_21092 = 0;
  ram_21094 = 1;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}

void PlayMode_SendStopEvent(void)
{
  ApPostEvent(0x6f0026L, EVT_LYRICS_ALL_CLEAR, 0L);
}

void CDlikeSwTtl_SendEvent8C_A(void)
{
  ApPostEvent(0x8c000aL, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendStopEvtD(void)
{
  ApPostEvent(0x8b000dL, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendStartEvt(void)
{
  ApPostEvent(0x8b0003L, EVT_SET_VISIBLE, 0L);
}

long SeqInit_LookupDispatchEntry(unsigned char i)
{
  return Demo_SongViewIdTable[i];
}

void CDlikeSwTtl_DocConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowDocTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}

void CDlikeSwTtl_SongConfirmDispatch(void)
{
  switch (ram_1d4a) {
  case 3:
  case 1:
    SeqRecPlay_EnablePlayOnly();
    Acc_TransitionPlayMode();
    break;
  case 2:
    SeqRecPlay_EnableRecordOnly();
    Acc_StopPlayMode();
    break;
  }
}

void CDlikeSwTtl_PdBitCheck(void)
{
  if (!(SeqState_GetFlags() & 2) && !(SeqState_GetFlags() & 1))
    CDlikeSwTtl_ShowPdTitle();
  else {
    SeqRecPlay_DisableBoth();
    Song_AbortPlayback();
  }
}

void SqTrSel_CaseF(void)
{
  SeqRecPlay_DisableBoth();
  Song_AbortPlayback();
  ram_1d4a = 0;
}
