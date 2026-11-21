/* helper Q, round 20r1, module 269 (file_io/smf_operations.s, demo/file_demo_proc.s): SMF LOAD AS handler (sibling of
   the built SaveFileNameSmfFunc), cancel cleanup, progress signal. */

extern long __near ram_819c;
extern unsigned char __near ram_8946;
extern long SmfLoadAs_ModeTexts[];
extern unsigned char __near SEQ_RTMCFG;
extern long ApPostEvent(long, long, long);
extern void SeqAcc_InitPlaybackState(void);
extern void MidiIn_AcceptClockTransport(void);
extern void CPanel_InitButtonState_SaveRegs(void);
extern void RefreshSwEvent(void);

#define EVT_PAINT 0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_PS_FILE_NAME_BOX_ID 0x1e50004L

long SmfLoadAsFunc(unsigned long obj, long evt, long par)
{
  switch (evt) {
  case EVT_PS_FILE_NAME_BOX_ID:
    ram_819c = par;
    break;
  case EVT_PAINT:
    ApPostEvent(ram_819c, EVT_PARA_DRAW, SmfLoadAs_ModeTexts[ram_8946]);
    break;
  }
  return 0;
}

void CancelOperationCleanup(void)
{
  unsigned char f;
  f = SEQ_RTMCFG;
  if (f & 0x04) {
    f &= ~0x04;
    SEQ_RTMCFG = f;
  }
  SEQ_RTMCFG &= ~0x08;
  SeqAcc_InitPlaybackState();
  MidiIn_AcceptClockTransport();
}

void SignalProgressUpdate(void)
{
  CPanel_InitButtonState_SaveRegs();
  RefreshSwEvent();
}
