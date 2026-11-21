/* Functions of sequencer/accompaniment_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ACTIVE_TITLE;
extern void ApDeliveryEvent(unsigned long, unsigned long, unsigned long);

void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE == 201)
        ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}

void SoundCtrl_SendAccTempo(void)
{
    if (ACTIVE_TITLE == 181)
        ApDeliveryEvent(0xb5001eL, 0x1c0000bL, 0L);
}

extern void Kernel_SemaSignal(int);
extern void AccAudio_LockRelease(void);
extern long ApPostEvent(long, long, long);
#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL
extern void AccSeq_PostEvent9E_Enable(void);
extern void Kernel_SemaWait(int);
extern void AccAudio_LockAcquire(void);

void AccAudio_LockRelease(void)
{
  Kernel_SemaSignal(8);
}
void AccSeq_PostEvent9E_Enable(void)
{
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1L);
}
void AccAudio_LockAcquire(void)
{
  Kernel_SemaWait(8);
}
