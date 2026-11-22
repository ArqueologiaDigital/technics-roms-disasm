/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m199a.c (2026-11-21-2-p6-r58)
   sha256 f345f9ea5406570a078113a0e1f5557882ed8081e6139da2e0c81ad25d957db6 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near PLAYBACK_START_ARMED;
extern unsigned char __near CURRENT_TITLE;
void DpMdlySmfLyr_DisarmStartCountdown(void)
{
  if (CURRENT_TITLE == 108)
    PLAYBACK_START_ARMED = 0;
}
