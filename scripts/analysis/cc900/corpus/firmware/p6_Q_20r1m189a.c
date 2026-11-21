/* helper Q, round 20r1, module 189 (ui/ui_playback_modes.s). */

extern unsigned char __near PLAYBACK_START_ARMED;

void DpMdlyDoc_DisarmStartCountdown(void)
{
  PLAYBACK_START_ARMED = 0;
}
