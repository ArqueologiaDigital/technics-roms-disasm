/* helper Q, round 20r1, module 199 (ui/ui_playback_modes.s). */

extern unsigned char __near PLAYBACK_START_ARMED;
extern unsigned char __near CURRENT_TITLE;

void DpMdlySmfLyr_DisarmStartCountdown(void)
{
  if (CURRENT_TITLE == 108)
    PLAYBACK_START_ARMED = 0;
}
