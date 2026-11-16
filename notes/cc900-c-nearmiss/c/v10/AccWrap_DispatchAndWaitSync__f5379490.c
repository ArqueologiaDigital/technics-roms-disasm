/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
extern void AccWrap_PlayModeDispatch(void);
extern unsigned char __near PLAY_TRANSPORT_STATE;
void AccWrap_DispatchAndWaitSync(void)
{
  unsigned int n;
  AccWrap_PlayModeDispatch();
  n = 0xffff;
  while (PLAY_TRANSPORT_STATE & 0x04) {
    if (--n == 0) return;
  }
}
