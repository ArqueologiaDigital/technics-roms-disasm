/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m188a.c (2026-11-21-2-p6-r58)
   sha256 f00655f5ea2a753ca9c782511a446be4d7603ddc12c5b625102a4ba2ae25634f (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near PLAYBACK_START_ARMED;
extern void SongMode_InitFlagBlock_Helper2(void);
void SongMode_InitFlagBlock_Helper(void)
{
  if (PLAYBACK_START_ARMED == 0) {
    PLAYBACK_START_ARMED = 1;
    SongMode_InitFlagBlock_Helper2();
  }
}
