/* helper Q, round 20r1, module 259 (sequencer/accompaniment_engine.s): two one-call wrappers. */

extern long ApPostEvent(long, long, long);
extern void Kernel_SemaSignal(int);

#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL

void AccSeq_PostEvent9E_Enable(void)
{
  ApPostEvent(-1L, EVT_SET_NOT_DRAW_FLAG, 1L);
}

void AccAudio_LockRelease(void)
{
  Kernel_SemaSignal(8);
}
