/* Helper R, round 1 of 2026-11-20: modules 240-261 (sequencer/smf_event_processor.s,
   sequencer/accompaniment_engine.s), one-cell accessors.  Form a. */

extern unsigned int ram_3e3e6;
extern unsigned long __near ram_3293;
extern unsigned char __near ram_32e2;
extern void SeqVoice_SendNoteOffAndFlush(void);
extern volatile unsigned char __near ram_3391;
extern unsigned char __near ram_3392;
extern unsigned char __near ram_3422;
extern unsigned char __near ram_3423;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char __near STYLE_SECTION_LAST_MEASURE;
extern void Kernel_SemaWait(int);
extern void Voice_RefreshBankData(void);

unsigned int FDC_ReadDiskChangeStatus(void)
{
  return ram_3e3e6;
}

unsigned long AccSeq_AdvancePointer(void)
{
  return ++ram_3293;
}

void AccInit_ResetSongCounter(void)
{
  if (ram_32e2 == 0) SeqVoice_SendNoteOffAndFlush();
  ram_32e2 = 0;
}

void AccTuning_SaveState(void)
{
  ram_3392 = ram_3391;
}

void Chord_LookupTypeFamily(void)
{
  ram_3422 = Chord_TypeFamilyTable[ram_3423];
}

void DrumParam_ReadMaxCount_Helper4(void)
{
  STYLE_SECTION_LAST_MEASURE = 3;
}

void AccAudio_LockAcquire(void)
{
  Kernel_SemaWait(8);
}

unsigned long MspSave_InitAndCalcSize(void)
{
  Voice_RefreshBankData();
  return (unsigned long)*(unsigned int *)0x1e881cL << 4;
}

void SoundMem_ClearRegion(void)
{
  unsigned char *p = (unsigned char *)0xffc00L;
  do
    *p++ = 0;
  while (p < (unsigned char *)0x100000L);
}
