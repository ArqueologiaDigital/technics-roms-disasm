/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);
extern void Kernel_SemaSignal(int);
#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL

void AccAudio_LockRelease(void)
{
  Kernel_SemaSignal(8);
}

void AccSeq_PostEvent9E_Enable(void)
{
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1L);
}

extern unsigned long __near ram_3293;
extern unsigned char __near ram_3422;
extern unsigned char __near ram_3423;
extern unsigned char Chord_TypeFamilyTable[];
extern unsigned char __near STYLE_SECTION_LAST_MEASURE;
extern void Kernel_SemaWait(int);

void AccAudio_LockAcquire(void)
{
  Kernel_SemaWait(8);
}

unsigned long AccSeq_AdvancePointer(void)
{
  return ++ram_3293;
}

void Chord_LookupTypeFamily(void)
{
  ram_3422 = Chord_TypeFamilyTable[ram_3423];
}

void DrumParam_ReadMaxCount_Helper4(void)
{
  STYLE_SECTION_LAST_MEASURE = 3;
}

void SoundMem_ClearRegion(void)
{
  unsigned char *p = (unsigned char *)0xffc00L;
  do
    *p++ = 0;
  while (p < (unsigned char *)0x100000L);
}
