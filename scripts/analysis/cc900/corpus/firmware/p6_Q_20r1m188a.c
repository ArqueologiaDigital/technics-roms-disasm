/* helper Q, round 20r1, module 188 (ui/ui_playback_modes.s). */

extern unsigned char __near PLAYBACK_START_ARMED;
extern void SongMode_InitFlagBlock_Helper2(void);

void SongMode_InitFlagBlock_Helper(void)
{
  if (PLAYBACK_START_ARMED == 0) {
    PLAYBACK_START_ARMED = 1;
    SongMode_InitFlagBlock_Helper2();
  }
}
