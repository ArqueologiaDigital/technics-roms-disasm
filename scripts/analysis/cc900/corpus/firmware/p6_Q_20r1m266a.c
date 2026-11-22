/* helper Q, round 20r1, module 266 (demo/file_demo_proc.s): demo setup helpers. */
/* cc900-module: Demo_SelectEntry_Debounce */

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

void FDemo_IndicatorSetup(void)
{
  CtrlPanel_IndicatorDispatch(0x22, 0, 0);
  DEMO_PLAY_STATE = 4;
}

void Demo_SelectEntry_CheckCPanel(void)
{
  if (CURRENT_MODE == 19)
    Demo_SelectEntry_Debounce();
}
