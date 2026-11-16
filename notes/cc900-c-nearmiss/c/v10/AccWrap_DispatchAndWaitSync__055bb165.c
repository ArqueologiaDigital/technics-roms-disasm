/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_7b.c (2026-11-16-53-p6-r11)
   sha256 055bb165f17e4ada5d5cffdf53f6b5255200d3f65d0bb47ed27a1f253a00f0f7 (tar-sha256); compiled at -O3 -Xr */
extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;
void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  if (PLAY_TRANSPORT_STATE & 0x04) do {
    if ((n -= 1) == 0) return;
  } while (PLAY_TRANSPORT_STATE & 0x04);
}
