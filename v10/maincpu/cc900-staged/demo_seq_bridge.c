/* Functions of demo/demo_seq_bridge.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char ram_21090;
extern unsigned char ram_21092;
extern unsigned char ram_21094;
extern unsigned char __near ram_1d4a;
extern long Demo_SongViewIdTable[];
extern long ApPostEvent(long, long, long);
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_DisableBoth(void);
extern void Song_AbortPlayback(void);
#define EVT_SHOW 0x1c00001L
#define EVT_REPAINT 0x1c0000cL
#define EVT_LYRICS_ALL_CLEAR 0x1c70009L
#define EVT_SET_VISIBLE 0x1e0009cL
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
#define NAKA_VIEW_DemoMed1 0xe1000bL
#define NAKA_VIEW_DemoMed2 0xe2000bL
#define NAKA_VIEW_DemoMed3 0xe3000bL

void CDlikeSwTtl_SendEvent8C_A(void)
{
  ApPostEvent(0x8c000aL, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendStartEvt(void)
{
  ApPostEvent(0x8b0003L, EVT_SET_VISIBLE, 0L);
}

void CDlikeSwTtl_SendStopEvtD(void)
{
  ApPostEvent(0x8b000dL, EVT_SHOW, 0L);
}

void PlayMode_SendStopEvent(void)
{
  ApPostEvent(0x6f0026L, EVT_LYRICS_ALL_CLEAR, 0L);
}

long SeqInit_LookupDispatchEntry(unsigned char i)
{
  return Demo_SongViewIdTable[i];
}

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

void SqTrSel_CaseF(void)
{
  SeqRecPlay_DisableBoth();
  Song_AbortPlayback();
  ram_1d4a = 0;
}

#define EVT_SET_SELECTED 0x1e0004dL
#define EVT_INDEX_SELECT 0x1c0001bL
#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL
#define TT_SQTRAS 0x8b
#define TT_MESAGE 0xee
extern void ApDeliveryEvent(long, long, long);
extern long SeqInit_LookupDispatchEntry(unsigned int);
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_ChangeTitleByIndex(unsigned int);
extern void UI_InterruptTitleByIndex(unsigned int);

void CDlikeSwTtl_SendEvent8C_0(void)
{
  ApPostEvent(0x8c0000L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendEvent8C_13(void)
{
  ApPostEvent(0x8c0013L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendResetEvent(void)
{
  ApPostEvent(0x8b0000L, EVT_SHOW, 0L);
}

void CDlikeSwTtl_SendStartEvtArg1(void)
{
  ApPostEvent(0x8b0003L, EVT_SET_VISIBLE, 1L);
}

void CDlikeSwTtl_SetRecordAndNotify(void)
{
  ram_21090 = 1;
  ApPostEvent(NAKA_VIEW_DemoMed1, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed2, EVT_REPAINT, 0L);
  ApPostEvent(NAKA_VIEW_DemoMed3, EVT_REPAINT, 0L);
}

void PlayMode_SwitchToModeAndNotify(void)
{
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1L);
  UI_ChangeTitleByIndex(TT_SQTRAS);
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 0L);
  GLOBAL_ERROR_CODE = 35;
  UI_InterruptTitleByIndex(TT_MESAGE);
}

void SeqInit_FinalEvent(void)
{
  ApPostEvent(-1L, EVT_INDEX_SELECT, 0L);
}

void SeqInit_PostDispatchEvent(void)
{
  ApDeliveryEvent(SeqInit_LookupDispatchEntry(DEMO_ACTIVE_ENTRY), EVT_SET_SELECTED, 1L);
}

void SeqRecPlay_DisableBoth(void)
{
  ram_21092 = 0;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}

void SeqRecPlay_EnableRecordOnly(void)
{
  ram_21092 = 1;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 1L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, ram_21094);
}

void SqTrSel_CaseD(void)
{
  SeqRecPlay_DisableBoth();
  Song_AbortPlayback();
  ram_1d4a = 0;
}
