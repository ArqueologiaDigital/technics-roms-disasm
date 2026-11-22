/* Helper R, round 1 of 2026-11-20: module 235 (sequencer/sequencer_engine.s), note-edit event posters and small
   wrappers.  Form a. */

#define EVT_SET_PARAM 0x1e0003bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GRAPH_DRAW 0x1c80004L

extern void ApDeliveryEvent(long, long, long);
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_2788;
extern void SetVisible(long, unsigned int);
extern void Part_ClearAllVoiceChannels(void);
extern void Part_UnlinkVoiceFromChain(void);
extern unsigned char SEQ_SONG_SLOTS[];
extern long FileIO_WriteByte_Impl(void *, long);
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char __near ram_2587;
extern void SeqScan_ComparePosition14vs1052(void);
extern unsigned int __near ram_25a8;
extern unsigned char __near ram_25aa;
extern unsigned int __near ram_25be;
extern unsigned int __near ram_25b4;
extern void SeqEvt_SelectNearestTiming(void);
extern void SeqStep_PostEventAndUpdate(void);
extern void SeqScan_CheckBarBitAndProcess(void);
extern void Portamento_ScanInitAndLoop(void);
extern void SeqTick_InitAndScanParts(void);

void AppEvent_SendVoiceUpdate(long v)
{
  ApDeliveryEvent(0x810003L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollReset(long v)
{
  ApDeliveryEvent(0x850006L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollCase1(long v)
{
  ApDeliveryEvent(0x87000dL, EVT_SET_PARAM, v);
}

void NoteEditSy_SendScrollCmd1(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
}

void NoteEditSy_SendWidgetCmd0(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 0L);
}

void NoteEditSy_SendWidgetCmd2(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 2L);
}

void NoteEditSy_SendWidgetCmd3or4(void)
{
  long d = 3;
  if (ram_2742 & 1) d = 4;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, d);
}

void NoteEditSy_SendGateCmd(void)
{
  ram_296a = ram_2788;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 4L);
}

void NoteEditSy_SendScrollCmd5(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 5L);
}

void SeqIndicator_HideBoth(void)
{
  SetVisible(0x850013L, 0);
  SetVisible(0x850014L, 0);
}

void SeqLoadPre(void)
{
  Part_ClearAllVoiceChannels();
  Part_UnlinkVoiceFromChain();
}

void SeqSave_WriteBlockToFile(unsigned char a)
{
  FileIO_WriteByte_Impl((void *)(SEQ_SONG_SLOTS + ((unsigned long)a << 11)), 0x800L);
}

unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return ram_258e > SEQ_BEAT_COUNT;
}

void SeqScan_RefreshReadAndCompare(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_2587 = SeqData_ReadNextByte();
  PartCtrl_RefreshWordPeriodic();
  SeqScan_ComparePosition14vs1052();
}

void SeqSearch_InitNotFound(void)
{
  ram_25a8 = 0xffff;
  ram_25aa = 255;
  ram_25be = ram_25b4;
  SeqEvt_SelectNearestTiming();
}

void VoiceAlloc_TestBitRead(void)
{
  SeqStep_PostEventAndUpdate();
  SeqScan_CheckBarBitAndProcess();
  Portamento_ScanInitAndLoop();
  SeqTick_InitAndScanParts();
}
