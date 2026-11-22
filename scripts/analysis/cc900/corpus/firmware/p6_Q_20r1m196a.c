/* helper Q, round 20r1, module 196 (ui/ui_playback_modes.s). */

extern unsigned char __near PLAYBACK_START_ARMED;
extern void PlayModeStop_InitFlagBlock_Helper2(void);

void PlayModeStop_InitFlagBlock_Helper(void)
{
  if (PLAYBACK_START_ARMED == 0) {
    PLAYBACK_START_ARMED = 1;
    PlayModeStop_InitFlagBlock_Helper2();
  }
}
