/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;
void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  if (PLAY_TRANSPORT_STATE & 0x04) do {
    if (--n == 0) return;
  } while (PLAY_TRANSPORT_STATE & 0x04);
}
