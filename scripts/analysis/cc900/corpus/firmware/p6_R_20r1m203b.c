/* Helper R, round 1 of 2026-11-20: module 203, form b (alternative spellings of form a's uncertain spots). */
/* cc900-module: CDlikeSwTtl_ShowDocTitle SeqInit_LookupDispatchEntry SeqRecPlay_DisableBoth */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SET_SELECTED 0x1e0004dL
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L

extern long ApPostEvent(long, long, long);
extern void ApDeliveryEvent(long, long, long);
extern long SeqInit_LookupDispatchEntry(unsigned int);
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned char ram_21092;
extern volatile unsigned char ram_21094;
extern void Song_AbortPlayback(void);
extern int SeqState_GetFlags(void);
extern void CDlikeSwTtl_ShowDocTitle(void);
extern void SeqRecPlay_DisableBoth(void);

void SeqInit_PostDispatchEvent(void)
{
  long p;

  p = SeqInit_LookupDispatchEntry(DEMO_ACTIVE_ENTRY);
  ApDeliveryEvent(p, EVT_SET_SELECTED, 1L);
}

void SeqRecPlay_EnableRecordOnly(void)
{
  ram_21092 = 1;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 1L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, (unsigned long)ram_21094);
}

void SeqRecPlay_DisableBoth(void)
{
  ram_21092 = 0;
  ram_21094 = 0;
  ApPostEvent(0x6f0025L, EVT_REFRESH_PARA_DRAW, 0L);
  ApPostEvent(0x6f0024L, EVT_REFRESH_PARA_DRAW, (unsigned long)ram_21094);
}

void CDlikeSwTtl_DocBitCheck(void)
{
  if ((SeqState_GetFlags() & 2) || (SeqState_GetFlags() & 1)) {
    SeqRecPlay_DisableBoth();
    Song_AbortPlayback();
    return;
  }
  CDlikeSwTtl_ShowDocTitle();
}
