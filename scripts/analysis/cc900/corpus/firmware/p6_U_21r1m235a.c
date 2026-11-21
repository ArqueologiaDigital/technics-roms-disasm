/* helper U, round 21r1, module 235 (sequencer/sequencer_engine.s), form a: run r59's near misses of p6_R_20r1m235a
   had no cc900-module line, so their relative tail jumps / calls came out absolute.  This form adds the line;
   SeqEvent_AccumulateQueue also narrows the compare result to a byte with a cast (the ROM's scc on L). */
/* cc900-module: Portamento_ScanInitAndLoop SeqEvt_SelectNearestTiming SeqScan_CheckBarBitAndProcess SeqScan_ComparePosition14vs1052 SeqStep_PostEventAndUpdate SeqTick_InitAndScanParts */

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

unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return (unsigned char)(ram_258e > SEQ_BEAT_COUNT);
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
