/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_431;
extern unsigned char __near DEMO_PLAY_STATE;
extern unsigned char __near CURRENT_MODE;
extern void AccWrap_PlayModeDispatch(void);
extern void SeqBuf_Init(void);
extern void SeqPlay_EmergencyStopAll(void);
extern void CtrlPanel_IndicatorDispatch(unsigned int, unsigned int, unsigned int);
extern void Demo_SelectEntry_Debounce(void);

void Demo_PreSetup(void)
{
  AccWrap_PlayModeDispatch();
  SeqBuf_Init();
  SeqPlay_EmergencyStopAll();
  ram_431 = 0;
}

void Demo_SelectEntry_CheckCPanel(void)
{
  if (CURRENT_MODE == 19)
    Demo_SelectEntry_Debounce();
}

void FDemo_IndicatorSetup(void)
{
  CtrlPanel_IndicatorDispatch(0x22, 0, 0);
  DEMO_PLAY_STATE = 4;
}

extern unsigned char __near SEQ_RTMCFG;
extern void SeqAcc_InitPlaybackState(void);
extern void MidiIn_AcceptClockTransport(void);
extern void CPanel_InitButtonState_SaveRegs(void);
extern void RefreshSwEvent(void);

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

struct disk { long freesz; long total; };
extern struct disk ram_25d6c;
extern void GetDiskFreeSpace(long *, long *);

long FileIO_GetDiskFreeSpace(void)
{
  GetDiskFreeSpace(&ram_25d6c.freesz, &ram_25d6c.total);
  return ram_25d6c.freesz;
}
