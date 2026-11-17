/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-16-68-p6-r12)
   sha256 c017d7ed30858a1b5eda6f56cc1d35dcce29bb852184269843a59d5a89317c68 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern unsigned int __near ram_2859;
extern unsigned char __near ram_2889;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);
void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2859;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_2889 |= 0x01;
  } else ram_2889 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}
