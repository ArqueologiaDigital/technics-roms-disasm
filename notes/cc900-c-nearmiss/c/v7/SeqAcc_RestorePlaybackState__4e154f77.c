/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m234.c (2026-11-16-68-p6-r12)
   sha256 4e154f77a4c3d6c34becc86d752c3600e1f7b56ac2a5fa494e2cd92234668cc4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern unsigned int __near ram_2875;
extern unsigned char __near ram_28a5;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);
void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2875;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_28a5 |= 0x01;
  } else ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}
