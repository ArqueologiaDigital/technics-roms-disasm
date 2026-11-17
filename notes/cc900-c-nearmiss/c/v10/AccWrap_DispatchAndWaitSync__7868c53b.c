/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7a.c (2026-11-16-53-p6-r11)
   sha256 7868c53b4be9ae7e465581991b52a8087d74fac06d150e81c007ed067f52a205 (tar-sha256); compiled at -O3 -Xr */
extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;
void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  if (PLAY_TRANSPORT_STATE & 0x04) do {
    n -= 1;
    if (n == 0) return;
  } while (PLAY_TRANSPORT_STATE & 0x04);
}
