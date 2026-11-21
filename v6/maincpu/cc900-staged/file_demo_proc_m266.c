/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Demo_SelectEntry_Debounce */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_431;
extern void AccWrap_PlayModeDispatch(void);
extern void SeqBuf_Init(void);
extern void SeqPlay_EmergencyStopAll(void);
extern void Demo_PreSetup(void);
extern unsigned char __near CURRENT_MODE;
extern void Demo_SelectEntry_Debounce(void);
extern void Demo_SelectEntry_CheckCPanel(void);
extern unsigned char __near DEMO_PLAY_STATE;
extern void CtrlPanel_IndicatorDispatch(unsigned int, unsigned int, unsigned int);
extern void FDemo_IndicatorSetup(void);

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
