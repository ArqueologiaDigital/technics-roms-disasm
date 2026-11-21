/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Portamento_ScanInitAndLoop SeqEvt_SelectNearestTiming SeqScan_CheckBarBitAndProcess SeqScan_ComparePosition14vs1052 SeqStep_PostEventAndUpdate SeqTick_InitAndScanParts */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char __near ram_256d;
extern void SeqScan_ComparePosition14vs1052(void);
extern void SeqScan_RefreshReadAndCompare(void);
extern unsigned int __near ram_258e;
extern unsigned char __near ram_2590;
extern unsigned int __near ram_25a4;
extern unsigned int __near ram_259a;
extern void SeqEvt_SelectNearestTiming(void);
extern void SeqSearch_InitNotFound(void);
extern void SeqStep_PostEventAndUpdate(void);
extern void SeqScan_CheckBarBitAndProcess(void);
extern void Portamento_ScanInitAndLoop(void);
extern void SeqTick_InitAndScanParts(void);
extern void VoiceAlloc_TestBitRead(void);

void SeqScan_RefreshReadAndCompare(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_256d = SeqData_ReadNextByte();
  PartCtrl_RefreshWordPeriodic();
  SeqScan_ComparePosition14vs1052();
}

void SeqSearch_InitNotFound(void)
{
  ram_258e = 0xffff;
  ram_2590 = 255;
  ram_25a4 = ram_259a;
  SeqEvt_SelectNearestTiming();
}

void VoiceAlloc_TestBitRead(void)
{
  SeqStep_PostEventAndUpdate();
  SeqScan_CheckBarBitAndProcess();
  Portamento_ScanInitAndLoop();
  SeqTick_InitAndScanParts();
}
